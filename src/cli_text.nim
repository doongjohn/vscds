import terminal

proc say*(msg: string) =
  echo "| ", msg


proc say*(msg: string, ending: string) =
  stdout.write "| ", msg, ending


proc showTitle*() =
  eraseScreen()
  setCursorPos(0, 0)
  say "<VSCode Data Swapper>"


proc showBasicInfo*() =
  say "Version: 0.1.0"
  say "Enter \"help\" or \"?\" for help."