import app_settings
import cli_say
import cmd_run


proc main() =
  showTitle()
  loadSettingsFile()
  showWelcomeText()
  startCommandLoop()


when isMainModule:
  main()