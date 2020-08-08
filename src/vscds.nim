import app_settings
import cli_text
import cli_cmd


proc main() =
  showTitle()
  loadSettingsFile()
  showWelcomeText()
  startCommandLoop()


when isMainModule:
  main()