import os
import strutils
import strformat
import cli_text
import app_settings

#----------------------------------------------------------------------------------
# Check vscode data folder exists
#----------------------------------------------------------------------------------
proc checkVscDataExists*(): bool =
  result = true
  if not vscDataPath.existsDir():
    say &"Can't find \"{vscDataPath}\"!"
    createDir(vscDataPath)
    say &"Empty data folder has been created at \"{vscDataPath}\"."
    result = false


#----------------------------------------------------------------------------------
# Check valid file name
#----------------------------------------------------------------------------------
proc checkValidFileName*(name: string): bool =
  result = not(name.contains("/") or name.contains("\\")) and name.isValidFilename()