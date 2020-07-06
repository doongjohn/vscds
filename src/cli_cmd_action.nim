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


proc cmdHelp*(this: CommandObject, inputArgs: seq[string]): ref Exception =
  for i_cmd, cmd in commandObjects:
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
    if i_cmd != commandObjects.high:
      say ""


proc cmdClear*(this: CommandObject, inputArgs: seq[string]): ref Exception =
  showTitle()
  showBasicInfo()


proc cmdExit*(this: CommandObject, inputArgs: seq[string]): ref Exception =
  showExitText()
  quit()


proc cmdSwapData*(this: CommandObject, inputArgs: seq[string]): ref Exception =
  let swapName = inputArgs[0]
  let swapPath = joinPath(settings.vscodePath, settings.dataPrefix & swapName)

  if not checkVscDataExists():
    return noDataFolderFoundError()
  if swapName == settings.currentDataName:
    return newException(Exception, &"Already set to \"{swapName}\".")
  if not swapPath.existsDir():
    return newException(Exception, &"Can't find target data directory! \"{swapPath}\"")
  
  returnException:
    vscDataPath.moveDir(joinPath(settings.vscodePath, settings.dataPrefix & settings.currentDataName))
    swapPath.moveDir(vscDataPath)
    say &"Successfully swapped! \"{settings.currentDataName}\" -> \"{swapName}\""
    saveSettingsFile(swapName)


proc cmdSwapAndRun*(this: CommandObject, inputArgs: seq[string]): ref Exception =
  var res = result
  cmdSwapData(this, inputArgs[0 .. 0])
    .whenOK(() => (res = cmdRunVSCode(this, if inputArgs.len > 1: inputArgs[1 .. ^1] else: @[])))
    .whenErr((err: ref Exception) => (res = err))
  return res


proc cmdNewData*(this: CommandObject, inputArgs: seq[string]): ref Exception =
  let newName = inputArgs[0]
  let newPath = joinPath(settings.vscodePath, settings.dataPrefix & newName)

  if newName == settings.currentDataName:
    return newException(Exception, &"It's same name as Current Data!")
  if newPath.existsDir():
    return newException(Exception, &"This name already exists! \"{newPath}\"")
  if not newName.checkValidFileName():
    return newException(Exception, &"Invalid name!")

  returnException:
    createDir(newPath)
    say &"Successfully created! \"{newPath}\""


proc cmdDeleteData*(this: CommandObject, inputArgs: seq[string]): ref Exception =
  let delName = inputArgs[0]
  let delPath = joinPath(settings.vscodePath, settings.dataPrefix & delName)

  if delName == settings.currentDataName:
    return newException(Exception, &"You can't delete Current Data!")

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


proc cmdRenameData*(this: CommandObject, inputArgs: seq[string]): ref Exception =
  let oldName = inputArgs[0]
  let newName = inputArgs[1]
  let changeCurData = oldName == settings.currentDataName
  let oldPath = if changeCurData: vscDataPath else: joinPath(settings.vscodePath, settings.dataPrefix & oldName)
  let newPath = joinPath(settings.vscodePath, settings.dataPrefix & newName)
  
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


proc cmdListAll*(this: CommandObject, inputArgs: seq[string]): ref Exception =
  if checkVscDataExists(): say &"{settings.currentDataName} (current)"
  for dir in settings.vscodePath.walkDir(true, false):
    if dir.path.contains(settings.dataPrefix):
      say dir.path.replace(settings.dataPrefix, "")


proc cmdRunVSCode*(this: CommandObject, inputArgs: seq[string]): ref Exception =
  returnException:
    discard startProcess(settings.vscodeRunCommand, args = inputArgs)
    say "Running VSCode..."


proc cmdRevealVSCodeDirectory*(this: CommandObject, inputArgs: seq[string]): ref Exception =
  returnException:
    # explorer.exe is launched successfully, it returns "1"
    let exitCode = execCmd(settings.vscodeRevealCommand)
    say &"Command exit code: {exitCode}"
