{.experimental: "codeReordering".}
import os
import osproc
import strutils
import strformat
import settings_manager
import console_interface
import command


proc checkValidDataName(name: string): bool =
  result = not(name.contains("/") or name.contains("\\")) and name.isValidFilename()


proc cmdHelp*(this: CommandObject, inputArgs: seq[string]) =
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


proc cmdClear*(this: CommandObject, inputArgs: seq[string]) =
  showTitle()
  showBasicInfo()


proc cmdExit*(this: CommandObject, inputArgs: seq[string]) =
  say "See you soon!"
  quit()


proc cmdSwapData*(this: CommandObject, inputArgs: seq[string]) =
  let newName = inputArgs[0]
  let curPath = joinPath(settings.vscodePath, "data")
  let newPath = joinPath(settings.vscodePath, settings.dataPrefix & newName)

  if not curPath.existsDir():
    say &"Can't find current data directory! \"{curPath}\""
    createDir(curPath)
    say &"Empty data folder has been created at \"{curPath}\"."
    return
  if newName == settings.currentDataName:
    say &"Already set to \"{settings.currentDataName}\"."
    return
  if not newName.checkValidDataName():
    say &"Invalid name!"
    return
  
  try:
    curPath.moveDir(joinPath(settings.vscodePath, settings.dataPrefix & settings.currentDataName))
    newPath.moveDir(curPath)
    say &"Successfully swapped! \"{settings.currentDataName}\" -> \"{newName}\""
    saveSettingsFile(newName)
  except:
    echo getCurrentExceptionMsg()


proc cmdSwapAndRun*(this: CommandObject, inputArgs: seq[string]) =
  cmdSwapData(this, inputArgs[0 .. 0])
  if inputArgs.len > 1:
    cmdRunVSCode(this, inputArgs[1 .. ^1])


proc cmdNewData*(this: CommandObject, inputArgs: seq[string]) =
  if settings.currentDataName == inputArgs[0]:
    say &"It's same name as Current Data!"
    return
  let path = joinPath(settings.vscodePath, settings.dataPrefix & inputArgs[0])
  if path.existsDir():
    say &"This name already exists! \"{path}\"" 
    return
  if not inputArgs[0].checkValidDataName():
    say &"Invalid name!"
    return
  try:
    createDir(path)
    say &"Successfully created! \"{path}\""
  except:
    echo getCurrentExceptionMsg()


proc cmdDeleteData*(this: CommandObject, inputArgs: seq[string]) =
  if settings.currentDataName == inputArgs[0]:
    say &"You can't delete Current Data!"
    return
  try:
    let path = joinPath(settings.vscodePath, settings.dataPrefix & inputArgs[0])
    if path.existsDir():
      removeDir(path)
      say "Enter \"del\" to confirm", ": "
      if stdin.readLine() == "del": say &"Successfully removed: \"{path}\""
      else: say &"Delete canceled!"
    else:
      say &"Can't find directory! \"{path}\""
  except:
    echo getCurrentExceptionMsg()


proc cmdRenameData*(this: CommandObject, inputArgs: seq[string]) =
  let oldName = inputArgs[0]
  let newName = inputArgs[1]
  let changeCurData = oldName == settings.currentDataName
  let oldPath = joinPath(settings.vscodePath, if changeCurData: "data" else: settings.dataPrefix & oldName)
  let newPath = joinPath(settings.vscodePath, settings.dataPrefix & newName)
  
  if not oldPath.existsDir():
    say &"Can't find directory! \"{oldPath}\"!"
    if changeCurData:
      createDir(oldPath)
      say &"Empty data folder has been created at \"{oldPath}\"."
    return
  if settings.currentDataName == newName:
    say &"It's same name as Current Data! \"{settings.currentDataName}\""
    return
  if newPath.existsDir():
    say &"This name already exists! \"{newPath}\"" 
    return
  if not newName.checkValidDataName():
    say &"Invalid name!"
    return
  if oldName == newName:
    say &"It's already that name."
    return
  
  try:
    if changeCurData:
      saveSettingsFile(newName)
    else:
      oldPath.moveDir(newPath)
    say &"Successfully renamed! \"{oldName}\" -> \"{newName}\""
  except:
    echo getCurrentExceptionMsg()


proc cmdListAll*(this: CommandObject, inputArgs: seq[string]) =
  let curPath = joinPath(settings.vscodePath, "data")
  if curPath.existsDir():
    say &"{settings.currentDataName} (current)"
  else:
    say &"Can't find \"{curPath}\"!"
    createDir(curPath)
    say &"Empty data folder has been created at \"{curPath}\"."
  for dir in settings.vscodePath.walkDir(true, false):
    if dir.path.contains(settings.dataPrefix):
      say dir.path.replace(settings.dataPrefix, "")


proc cmdRunVSCode*(this: CommandObject, inputArgs: seq[string]) =
  discard startProcess(settings.vscodeRunCommand, args = inputArgs)
  say "Running VSCode..."


proc cmdRevealVSCodeDirectory*(this: CommandObject, inputArgs: seq[string]) =
  # explorer.exe is launched successfully, it returns "1"
  let exitCode = execCmd(settings.vscodeRevealCommand)
  say &"Command exit code: {exitCode}"