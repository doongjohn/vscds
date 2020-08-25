{.experimental: "codeReordering".}

import sugar
import osproc
import tables
import strutils
import strformat
import math
import cli_text
import eh
import nimlevenshtein


#----------------------------------------------------------------------------------
# Command
#----------------------------------------------------------------------------------
type Command* {.pure.} = enum
  Help,
  Clear,
  Exit,
  OpenSettings,
  SwapData,
  SwapAndRun,
  NewData,
  DeleteData,
  RenameData,
  ListAll,
  RunVSCode,
  RevealVSCodeDirectory


#----------------------------------------------------------------------------------
# Command Info
#----------------------------------------------------------------------------------
type CommandInfo* = object
  commandType: Command
  desc: string
  keywords: seq[string]
  args: seq[string]

func commandType*(this: CommandInfo): auto = this.commandType
func desc*(this: CommandInfo): auto = this.desc
func keywords*(this: CommandInfo): auto = this.keywords
func args*(this: CommandInfo): auto = this.args


const commandInfos* = [
  CommandInfo(
    commandType: Command.Help,
    desc: "Show help.",
    keywords: @["help", "?"],
  ),
  CommandInfo(
    commandType: Command.Clear,
    desc: "Clear screen.",
    keywords: @["clear", "cls"],
  ),
  CommandInfo(
    commandType: Command.Exit,
    desc: "Exit vscds.",
    keywords: @["exit", "quit", "q"],
  ),
  CommandInfo(
    commandType: Command.OpenSettings,
    desc: "Open \"settings.json\" with VS Code.",
    keywords: @["settings", "setting"],
  ),
  CommandInfo(
    commandType: Command.SwapData,
    desc: "Swap data folder.",
    keywords: @["swap", "to"],
    args: @["[Data Name]"],
  ),
  CommandInfo(
    commandType: Command.SwapAndRun,
    desc: "Swap data folder and run VS Code.",
    keywords: @["as"],
    args: @["[Data Name]", "[Args...]"],
  ),
  CommandInfo(
    commandType: Command.NewData,
    desc: "Create a new data folder.",
    keywords: @["create", "new"],
    args: @["[Data Name]"],
  ),
  CommandInfo(
    commandType: Command.DeleteData,
    desc: "Delete an existing data folder.",
    keywords: @["delete", "del"],
    args: @["[Data Name]"],
  ),
  CommandInfo(
    commandType: Command.RenameData,
    desc: "Rename existing data folder.",
    keywords: @["rename", "rn"],
    args: @["[Old Name]", "[New Name]"],
  ),
  CommandInfo(
    commandType: Command.ListAll,
    desc: "List exising data folders.",
    keywords: @["list"],
  ),
  CommandInfo(
    commandType: Command.RunVSCode,
    desc: "Run VS Code.",
    keywords: @["run", "r"],
    args: @["[Args...]"],
  ),
  CommandInfo(
    commandType: Command.RevealVSCodeDirectory,
    desc: "Reveal VS Code Directory.",
    keywords: @["reveal"],
  )
]


#----------------------------------------------------------------------------------
# Command Procs
#----------------------------------------------------------------------------------
import cli_cmd_proc

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
    say "This command needs no argument!"
    return false
  
  let noArgLimit = this.args.len > 0 and this.args[^1] == "[Args...]"
  let minArgsCount = if this.args.len > 0 and noArgLimit: this.args.high else: this.args.len
  
  if not noArgLimit and inputArgs.len > minArgsCount:
    say "Too many args!"
    return false
  
  if inputArgs.len < minArgsCount:
    say "Please specify:", lineBreak = false
    for arg in this.args: stdout.write(" " & arg)
    stdout.write "\n"
    return false


#----------------------------------------------------------------------------------
# Get input and run commands
#----------------------------------------------------------------------------------
proc startCommandLoop*() =
  while true:
    block theLoop:
      say ""
      say "", ">> ", false
      let inputs = stdin.readLine().toLowerAscii().splitWhitespace()
      if inputs.len == 0 or inputs[0] == "":
        say "Invalid Command!"
        break theLoop
      
      let inputKeyword = inputs[0]
      let inputArgs = if inputs.len > 1: inputs[1 .. ^1] else: @[]

      for cmdInfo in commandInfos:
        for keyword in cmdInfo.keywords:
          if inputKeyword == keyword:
            if cmdInfo.checkArgs(inputArgs):
              commands[cmdInfo.commandType](inputArgs).whenErr((err: Exception) => say &"※ ERROR ※\n{err.msg}")
            break theLoop
      
      say "Invalid Command!"
      say "Suggestions:"
      for cmdInfo in commandInfos:
        for keyword in cmdInfo.keywords:
          if keyword.len == 1:
            if contains(inputKeyword, keyword):
              say "  " & keyword
          elif distance(inputKeyword, keyword) <= round(keyword.len.float * 0.5).int or 
               jaro_winkler(inputKeyword, keyword) >= 0.9:
            say "  " & keyword

