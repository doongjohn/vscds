{.experimental: "codeReordering".}

import os
import osproc
import sugar
import strformat
import terminal
import utils/eh
import cli_say
import cli_spinner
import app_settings
import app_check
import cmd_common


proc cmdHelp*(inputArgs: seq[string]): ref Exception =
  returnException:
    for i_cmd, cmd in commandInfos:
      say(&"{cmd.commandType}: {cmd.desc}")
      sayAdd("  Keywords:")
      for i_keyword, keyword in cmd.keywords:
        sayAdd((if i_keyword != 0: ", " else: " "), keyword)
      sayIt(fgColor = fgBlue)
      if cmd.args.len != 0:
        sayAdd("  Args:")
        for i, arg in cmd.args:
          sayAdd(" ", arg)
        sayIt(fgColor = fgGreen)
      if i_cmd != commandInfos.high: say ""


proc cmdClear*(inputArgs: seq[string]): ref Exception =
  showTitle()


proc cmdExit*(inputArgs: seq[string]): ref Exception =
  showExitText()
  quit()


proc cmdOpenSettings*(inputArgs: seq[string]): ref Exception =
  cmdRunVSCode(@[settingsFilePath])


proc cmdSwapData*(inputArgs: seq[string]): ref Exception =
  returnException:
    let swapName = inputArgs[0]
    let swapPath = joinPath(inactiveDataPath, swapName)

    if not checkVscDataExists():
      return noDataFolderFoundError()
    if not swapPath.existsDir():
      return newException(Exception, &"Can't find target data directory! \"{swapPath}\"")
    if swapName == settings.currentDataName:
      return newException(Exception, &"Already set to \"{swapName}\".")
    
    vscDataPath.moveDir(joinPath(inactiveDataPath, settings.currentDataName))
    swapPath.moveDir(vscDataPath)
    say(&"Successfully swapped! \"{settings.currentDataName}\" -> \"{swapName}\"")
    saveSettingsFile(swapName)


proc cmdSwapAndRun*(inputArgs: seq[string]): ref Exception =
  var res = result
  cmdSwapData(inputArgs[0 .. 0])
    .whenOK(() => (res = cmdRunVSCode(if inputArgs.len > 1: inputArgs[1 .. ^1] else: @[])))
    .whenErr((err: ref Exception) => (res = err))
  return res


proc cmdNewData*(inputArgs: seq[string]): ref Exception =
  returnException:
    let newName = inputArgs[0]
    let newPath = joinPath(inactiveDataPath, newName)

    if newPath.existsDir() or newName == settings.currentDataName:
      return newException(Exception, &"\"{newName}\" already exists!")
    if not newName.checkValidFileName():
      return newException(Exception, &"Invalid name!")
    
    createDir(newPath)
    say(&"Successfully created! \"{newPath}\"")


proc cmdDeleteData*(inputArgs: seq[string]): ref Exception =
  returnException:
    if inputArgs[0] == settings.currentDataName:
      return newException(Exception, &"You can't delete Current Data!")

    let delName = inputArgs[0]
    let delPath = joinPath(inactiveDataPath, delName)
    if not delPath.existsDir():
      return newException(Exception, &"Can't find directory! \"{delPath}\"")

    say("Enter \"del\" to confirm: ", lineBreak = false)
    if stdin.readLine() != "del":
      say("Delete canceled!")
      return
    
    startSpinner(cli_spinner.dots, "removing..."):
      removeDir(delPath)
    say(&"Successfully removed: \"{delPath}\"")


proc cmdRenameData*(inputArgs: seq[string]): ref Exception =
  returnException:
    let oldName = inputArgs[0]
    let newName = inputArgs[1]
    let changeCurData = oldName == settings.currentDataName
    let oldPath = if changeCurData: vscDataPath else: joinPath(inactiveDataPath, oldName)
    let newPath = joinPath(inactiveDataPath, newName)
    
    if not oldPath.existsDir():
      if changeCurData and not checkVscDataExists():
        return noDataFolderFoundError()
      else:
        return newException(Exception, &"Can't find directory! \"{oldPath}\"!")
    if settings.currentDataName == newName:
      return newException(Exception, &"It's same name as Current Data! \"{settings.currentDataName}\"")
    if not newName.checkValidFileName():
      return newException(Exception, &"Invalid name!")
    if newPath.existsDir():
      return newException(Exception, &"This name already exists! \"{newPath}\"")
    if oldName == newName:
      return newException(Exception, &"It's already that name.")
    
    if changeCurData: saveSettingsFile(newName)
    else: oldPath.moveDir(newPath)
    say(&"Successfully renamed! \"{oldName}\" -> \"{newName}\"")


proc cmdListAll*(inputArgs: seq[string]): ref Exception =
  returnException:
    if checkVscDataExists(): say &"{settings.currentDataName} (current)"
    for dir in inactiveDataPath.walkDir(true, false):
      say(dir.path.extractFileName())


proc cmdRunVSCode*(inputArgs: seq[string]): ref Exception =
  returnException:
    say(&"Running command: {settings.vscodeRunCommand}")
    discard startProcess(settings.vscodeRunCommand, args = inputArgs)


proc cmdRevealVSCodeDirectory*(inputArgs: seq[string]): ref Exception =
  returnException:
    say(&"Running command: {settings.vscodeRevealCommand}")
    let exitCode = execCmd(settings.vscodeRevealCommand)
    say(&"Command exit code: {exitCode}")