{.experimental: "codeReordering".}

import os
import osproc
import strutils
import strformat
import app_settings
import app_check
import cli_text
import cli_cmd
import eh


proc checkValidDataName(name: string): bool =
  result = not(name.contains("/") or name.contains("\\")) and name.isValidFilename()


proc cmdHelp*(this: CommandObject, inputArgs: seq[string]): ref Exception =
  for cmd_i, cmd in commandObjects:
    say &"{cmd.commandType}: {cmd.desc}"
    say "Keywords", ":"
    for keyword in cmd.keywords: stdout.write(" " & keyword)
    stdout.write "\n"
    if cmd.args.len != 0:
      say "Args", ":"
      for arg in cmd.args: stdout.write(" " & arg)
      stdout.write "\n"
    if cmd_i != commandObjects.high: say ""


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
    return nil
  if swapName == settings.currentDataName:
    say &"Already set to \"{swapName}\"."
    return nil
  if not swapPath.existsDir():
    say &"Can't find target data directory! \"{swapPath}\""
    return nil
  
  catchException:
    vscDataPath.moveDir(joinPath(settings.vscodePath, settings.dataPrefix & settings.currentDataName))
    swapPath.moveDir(swapPath)
    say &"Successfully swapped! \"{settings.currentDataName}\" -> \"{swapName}\""
    saveSettingsFile(swapName)


proc cmdSwapAndRun*(this: CommandObject, inputArgs: seq[string]): ref Exception =
  cmdSwapData(this, inputArgs[0 .. 0]).whenOK:
    if inputArgs.len > 1:
      discard cmdRunVSCode(this, inputArgs[1 .. ^1])


proc cmdNewData*(this: CommandObject, inputArgs: seq[string]): ref Exception =
  if settings.currentDataName == inputArgs[0]:
    say &"It's same name as Current Data!"
    return nil
  let path = joinPath(settings.vscodePath, settings.dataPrefix & inputArgs[0])
  if path.existsDir():
    say &"This name already exists! \"{path}\"" 
    return nil
  if not inputArgs[0].checkValidDataName():
    say &"Invalid name!"
    return nil
  catchException:
    createDir(path)
    say &"Successfully created! \"{path}\""


proc cmdDeleteData*(this: CommandObject, inputArgs: seq[string]): ref Exception =
  if settings.currentDataName == inputArgs[0]:
    say &"You can't delete Current Data!"
    return nil
  catchException:
    let path = joinPath(settings.vscodePath, settings.dataPrefix & inputArgs[0])
    if path.existsDir():
      removeDir(path)
      say "Enter \"del\" to confirm", ": "
      if stdin.readLine() == "del": say &"Successfully removed: \"{path}\""
      else: say &"Delete canceled!"
    else:
      say &"Can't find directory! \"{path}\""


proc cmdRenameData*(this: CommandObject, inputArgs: seq[string]): ref Exception =
  let oldName = inputArgs[0]
  let newName = inputArgs[1]
  let changeCurData = oldName == settings.currentDataName
  let oldPath = if changeCurData: vscDataPath else: joinPath(settings.vscodePath, settings.dataPrefix & oldName)
  let newPath = joinPath(settings.vscodePath, settings.dataPrefix & newName)
  
  if not oldPath.existsDir():
    say &"Can't find directory! \"{oldPath}\"!"
    if changeCurData: discard checkVscDataExists()
    return nil
  if settings.currentDataName == newName:
    say &"It's same name as Current Data! \"{settings.currentDataName}\""
    return nil
  if newPath.existsDir():
    say &"This name already exists! \"{newPath}\"" 
    return nil
  if not newName.checkValidDataName():
    say &"Invalid name!"
    return nil
  if oldName == newName:
    say &"It's already that name."
    return nil
  
  catchException:
    if changeCurData: saveSettingsFile(newName)
    else: oldPath.moveDir(newPath)
    say &"Successfully renamed! \"{oldName}\" -> \"{newName}\""


proc cmdListAll*(this: CommandObject, inputArgs: seq[string]): ref Exception =
  if checkVscDataExists(): say &"{settings.currentDataName} (current)"
  for dir in settings.vscodePath.walkDir(true, false):
    if dir.path.contains(settings.dataPrefix):
      say dir.path.replace(settings.dataPrefix, "")


proc cmdRunVSCode*(this: CommandObject, inputArgs: seq[string]): ref Exception =
  catchException:
    discard startProcess(settings.vscodeRunCommand, args = inputArgs)
    say "Running VSCode..."


proc cmdRevealVSCodeDirectory*(this: CommandObject, inputArgs: seq[string]): ref Exception =
  catchException:
    # explorer.exe is launched successfully, it returns "1"
    let exitCode = execCmd(settings.vscodeRevealCommand)
    say &"Command exit code: {exitCode}"
