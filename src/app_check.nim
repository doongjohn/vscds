import os
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