import os
import osproc
import strutils
import strformat
import settings_manager
import console_interface
import command


proc checkValidDataName(name: string): bool =
  result = not(name.contains("/") or name.contains("\\")) and name.isValidFilename()


proc cmdHelp*(this: CommandObject, inputOptions: seq[string]) =
  for cmd_i, cmd in commandObjects:
    say &"{cmd.commandType}: {cmd.desc}"
    say "Keys", ":"
    for key in cmd.keywords: stdout.write(" " & key)
    stdout.write "\n"
    if cmd.options.len != 0:
      say "Options", ":"
      for option in cmd.options: stdout.write(" " & option)
      stdout.write "\n"
    if cmd_i != commandObjects.high: say ""


proc cmdClear*(this: CommandObject, inputOptions: seq[string]) =
  showTitle()
  showBasicInfo()


proc cmdExit*(this: CommandObject, inputOptions: seq[string]) =
  say "See you soon!"
  quit()


proc cmdSwapData*(this: CommandObject, inputOptions: seq[string]) =
  let newName = inputOptions[0]
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


proc cmdNewData*(this: CommandObject, inputOptions: seq[string]) =
  if settings.currentDataName == inputOptions[0]:
    say &"It's same name as Current Data!"
    return
  let path = joinPath(settings.vscodePath, settings.dataPrefix & inputOptions[0])
  if path.existsDir():
    say &"This name already exists! \"{path}\"" 
    return
  if not inputOptions[0].checkValidDataName():
    say &"Invalid name!"
    return
  try:
    createDir(path)
    say &"Successfully created! \"{path}\""
  except:
    echo getCurrentExceptionMsg()


proc cmdDeleteData*(this: CommandObject, inputOptions: seq[string]) =
  if settings.currentDataName == inputOptions[0]:
    say &"You can't delete Current Data!"
    return
  try:
    let path = joinPath(settings.vscodePath, settings.dataPrefix & inputOptions[0])
    if path.existsDir():
      removeDir(path)
      say "Enter \"del\" to confirm", ": "
      if stdin.readLine() == "del": say &"Successfully removed: \"{path}\""
      else: say &"Delete canceled!"
    else:
      say &"Can't find directory! \"{path}\""
  except:
    echo getCurrentExceptionMsg()


proc cmdRenameData*(this: CommandObject, inputOptions: seq[string]) =
  let oldName = inputOptions[0]
  let newName = inputOptions[1]
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


proc cmdListAll*(this: CommandObject, inputOptions: seq[string]) =
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


proc cmdRunVSCode*(this: CommandObject, inputOptions: seq[string]) =
  let execCommand = block:
    var res = settings.vscodeRunCommand
    if inputOptions.len != 0: 
      for i in inputOptions: res &= " " & i
    res
  say &"Command result: {execCmdEx(execCommand)}"


proc cmdRevealVSCodeDirectory*(this: CommandObject, inputOptions: seq[string]) =
  # explorer.exe is launched successfully, it returns "1"
  say &"Command result: {execCmdEx(settings.vscodeRevealCommand)}"