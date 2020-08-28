import os
import strutils
import strformat
import utils/eh
import cli_say
import app_settings


type NoDataFolderFoundError = object of Defect


#----------------------------------------------------------------------------------
# Check vscode data folder exists
#----------------------------------------------------------------------------------
proc checkVscDataExists*(): bool =
  vscDataPath.existsDir()


proc noDataFolderFoundError*(): ref Exception =
  result = newException(NoDataFolderFoundError, &"Error [data folder]: Can't find \"{vscDataPath}\"!")
  returnException:
    createDir(vscDataPath)
    say(&"Empty data folder has been created at \"{vscDataPath}\".")


#----------------------------------------------------------------------------------
# Check valid file name
#----------------------------------------------------------------------------------
proc checkValidFileName*(name: string): bool =
  result = not(name.contains("/") or name.contains("\\")) and name.isValidFilename()