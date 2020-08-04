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
