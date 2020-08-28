import terminal
import cli_say
import app_settings
import cmd_run


proc quitProc() {.noconv.} =
  resetAttributes()
  showCursor()


proc main() =
  addQuitProc(quitProc)
  showTitle()
  loadSettingsFile()
  showWelcomeText()
  startCommandLoop()


when isMainModule:
  main()