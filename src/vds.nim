# TODO:
# - [X] Show help.
# - [X] Swap data folder. (check if already runing.)
# - [X] Create data folder.
# - [X] Delete data folder.
# - [X] Rename data foler.
# - [X] List all data folers.
# - [X] Run VSCode.
# - [X] Reveal VSCode directory in explorer.

import app_settings
import cli_text
import cli_cmd


proc main() =
  showTitle()
  loadSettingsFile()
  showBasicInfo()
  setupCommandObjects()
  while true:
    getInputAndRunCommand()


when isMainModule:
  main()
