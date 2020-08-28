{.experimental: "codeReordering".}

import sugar
import tables
import strutils
import strformat
import math
import utils/eh
import cli_say
import cmd_common
import cmd_proc
import nimlevenshtein


#----------------------------------------------------------------------------------
# Command Procs
#----------------------------------------------------------------------------------
const commands = {
  Command.Help: cmdHelp,
  Command.Clear: cmdClear,
  Command.Exit: cmdExit,
  Command.OpenSettings: cmdOpenSettings,
  Command.SwapData: cmdSwapData,
  Command.SwapAndRun: cmdSwapAndRun,
  Command.NewData: cmdNewData,
  Command.DeleteData: cmdDeleteData,
  Command.RenameData: cmdRenameData,
  Command.ListAll: cmdListAll,
  Command.RunVSCode: cmdRunVSCode,
  Command.RevealVSCodeDirectory: cmdRevealVSCodeDirectory
}.toTable()


#----------------------------------------------------------------------------------
# Check Command args
#----------------------------------------------------------------------------------
proc checkArgs(this: CommandInfo, inputArgs: seq[string]): bool =
  result = true

  if this.args.len == 0 and inputArgs.len > 0:
    say("This command needs no argument!")
    return false
  
  let noArgLimit = this.args.len > 0 and this.args[^1] == "[Args...]"
  let minArgsCount = if this.args.len > 0 and noArgLimit: this.args.high else: this.args.len
  
  if not noArgLimit and inputArgs.len > minArgsCount:
    say("Too many args!")
    return false
  
  if inputArgs.len < minArgsCount:
    say("Please specify:", lineBreak = false)
    for arg in this.args: stdout.write(" " & arg)
    stdout.write "\n"
    return false


#----------------------------------------------------------------------------------
# Get input and run commands
#----------------------------------------------------------------------------------
proc startCommandLoop*() =
  while true:
    block theLoop:
      say("")
      say("", ">> ", lineBreak = false)
      let inputs = stdin.readLine().toLowerAscii().splitWhitespace()
      if inputs.len == 0 or inputs[0] == "":
        say("Invalid Command!")
        break theLoop
      
      let inputKeyword = inputs[0]
      let inputArgs = if inputs.len > 1: inputs[1 .. ^1] else: @[]

      for cmdInfo in commandInfos:
        for keyword in cmdInfo.keywords:
          if inputKeyword == keyword:
            if cmdInfo.checkArgs(inputArgs):
              commands[cmdInfo.commandType](inputArgs).whenErr((err: Exception) => say &"※ ERROR ※\n{err.msg}")
            break theLoop
      
      say("Invalid Command!")
      
      var suggestions = newSeq[string]()
      for cmdInfo in commandInfos:
        for keyword in cmdInfo.keywords:
          if keyword.len == 1:
            if contains(inputKeyword, keyword):
              suggestions.add("  " & keyword)
          elif distance(inputKeyword, keyword) <= round(keyword.len.float * 0.5).int or 
               jaro_winkler(inputKeyword, keyword) >= 0.9:
            suggestions.add("  " & keyword)
      
      if suggestions.len() != 0:
        say("\nSuggestions:")
        for s in suggestions:
          say(s)

