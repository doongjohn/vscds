{.experimental: "codeReordering".}

import os
import osproc
import sugar
import strutils
import strformat
import terminal
import app_settings
import app_check
import cli_text
import cli_cmd
import eh


proc cmdHelp*(inputArgs: seq[string]): ref Exception =
  for i_cmd, cmd in commandInfos:
    say &"{cmd.commandType}: {cmd.desc}"
    
    stdout.setForegroundColor(ForegroundColor.fgBlue)
    sayAdd "  Keywords:"
    for i_keyword, keyword in cmd.keywords:
      sayAdd (if i_keyword != 0: ", " else: " ")
      sayAdd keyword
    sayIt()
    
    stdout.setForegroundColor(ForegroundColor.fgGreen)
    if cmd.args.len != 0:
      sayAdd "  Args:"
      for i, arg in cmd.args:
        sayAdd " "
        sayAdd arg
      sayIt()
    
    stdout.setForegroundColor(ForegroundColor.fgWhite)
    if i_cmd != commandInfos.high:
      say ""


proc cmdClear*(inputArgs: seq[string]): ref Exception =
  showTitle()
  showWelcomeText()


proc cmdExit*(inputArgs: seq[string]): ref Exception =
  showExitText()
  quit()


proc cmdOpenSettings*(inputArgs: seq[string]): ref Exception =
  cmdRunVSCode(@[settingsFilePath])


proc cmdSwapData*(inputArgs: seq[string]): ref Exception =
  let swapName = inputArgs[0]
  let swapPath = joinPath(inactiveDataPath, swapName)

  if not checkVscDataExists():
    return noDataFolderFoundError()
  if swapName == settings.currentDataName:
    return newException(Exception, &"Already set to \"{swapName}\".")
  if not swapPath.existsDir():
    return newException(Exception, &"Can't find target data directory! \"{swapPath}\"")
  
  returnException:
    vscDataPath.moveDir(joinPath(inactiveDataPath, settings.currentDataName))
    swapPath.moveDir(vscDataPath)
    say &"Successfully swapped! \"{settings.currentDataName}\" -> \"{swapName}\""
    saveSettingsFile(swapName)


proc cmdSwapAndRun*(inputArgs: seq[string]): ref Exception =
  var res = result
  cmdSwapData(inputArgs[0 .. 0])
    .whenOK(() => (res = cmdRunVSCode(if inputArgs.len > 1: inputArgs[1 .. ^1] else: @[])))
    .whenErr((err: ref Exception) => (res = err))
  return res


proc cmdNewData*(inputArgs: seq[string]): ref Exception =
  let newName = inputArgs[0]
  let newPath = joinPath(inactiveDataPath, newName)

  if newName == settings.currentDataName:
    return newException(Exception, &"\"{newName}\" = Current Data!")
  if newPath.existsDir():
    return newException(Exception, &"\"{newName}\" already exists!")
  if not newName.checkValidFileName():
    return newException(Exception, &"Invalid name!")
  
  returnException:
    createDir(newPath)
    say &"Successfully created! \"{newPath}\""


proc cmdDeleteData*(inputArgs: seq[string]): ref Exception =
  if inputArgs[0] == settings.currentDataName:
    return newException(Exception, &"You can't delete Current Data!")

  let delName = inputArgs[0]
  let delPath = joinPath(inactiveDataPath, delName)

  if delPath.existsDir():
      say "Enter \"del\" to confirm: ", lineBreak = false
      if stdin.readLine() == "del":
        returnException:
          removeDir(delPath)
          say &"Successfully removed: \"{delPath}\""
      else:
        say &"Delete canceled!"
  else:
    return newException(Exception, &"Can't find directory! \"{delPath}\"")


proc cmdRenameData*(inputArgs: seq[string]): ref Exception =
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
  if newPath.existsDir():
    return newException(Exception, &"This name already exists! \"{newPath}\"")
  if not newName.checkValidFileName():
    return newException(Exception, &"Invalid name!")
  if oldName == newName:
    return newException(Exception, &"It's already that name.")
  
  returnException:
    if changeCurData: saveSettingsFile(newName)
    else: oldPath.moveDir(newPath)
    say &"Successfully renamed! \"{oldName}\" -> \"{newName}\""


proc cmdListAll*(inputArgs: seq[string]): ref Exception =
  if checkVscDataExists(): say &"{settings.currentDataName} (current)"
  for dir in inactiveDataPath.walkDir(true, false):
    say dir.path.extractFileName()


proc cmdRunVSCode*(inputArgs: seq[string]): ref Exception =
  returnException:
    discard startProcess(settings.vscodeRunCommand, args = inputArgs)
    say "Running VS Code..."


proc cmdRevealVSCodeDirectory*(inputArgs: seq[string]): ref Exception =
  returnException:
    let exitCode = execCmd(settings.vscodeRevealCommand)
    say &"Command exit code: {exitCode}"