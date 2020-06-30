import sugar
import strutils
import strformat
import app_settings
import cli_text
import eh


#----------------------------------------------------------------------------------
# Command enum
#----------------------------------------------------------------------------------
type Command* {.pure.} = enum
  Help,
  Clear,
  Exit,
  SwapData,
  SwapAndRun,
  NewData,
  DeleteData,
  RenameData,
  ListAll,
  RunVSCode,
  RevealVSCodeDirectory


#----------------------------------------------------------------------------------
# Command object
#----------------------------------------------------------------------------------
type CommandObject* = object
  commandType: Command
  desc: string
  keywords: seq[string]
  args: seq[string]
  action: proc(this: CommandObject, inputargs: seq[string]): ref Exception

func commandType*(this: CommandObject): auto = this.commandType
func desc*(this: CommandObject): auto = this.desc
func keywords*(this: CommandObject): auto = this.keywords
func args*(this: CommandObject): auto = this.args


#----------------------------------------------------------------------------------
# All Command objects
#----------------------------------------------------------------------------------
var commandObjects* = newSeq[CommandObject]()


#----------------------------------------------------------------------------------
# Setup Command objects
#----------------------------------------------------------------------------------
import cli_cmd_action


proc setupCommandObjects*() =
  commandObjects.add(CommandObject(
    commandType: Command.Help,
    desc: "Shows help.",
    keywords: @["help", "?"],
    action: cmdHelp
  ))
  commandObjects.add(CommandObject(
    commandType: Command.Clear,
    desc: "Clears screen.",
    keywords: @["clear", "cls"],
    action: cmdClear
  ))
  commandObjects.add(CommandObject(
    commandType: Command.Exit,
    desc: "Exits.",
    keywords: @["exit", "quit", "q"],
    action: cmdExit
  ))
  commandObjects.add(CommandObject(
    commandType: Command.SwapData,
    desc: "Swaps data folder.",
    keywords: @["swap", "to"],
    args: @["[Data Name]"],
    action: cmdSwapData
  ))
  commandObjects.add(CommandObject(
    commandType: Command.SwapAndRun,
    desc: "Swaps data folder and run VSCode.",
    keywords: @["as"],
    args: @["[Data Name] [Args...]"],
    action: cmdSwapAndRun
  ))
  commandObjects.add(CommandObject(
    commandType: Command.NewData,
    desc: "Creates new data folder.",
    keywords: @["create", "new"],
    args: @["[Data Name]"],
    action: cmdNewData
  ))
  commandObjects.add(CommandObject(
    commandType: Command.DeleteData,
    desc: "Deletes existing data folder.",
    keywords: @["delete", "del"],
    args: @["[Data Name]"],
    action: cmdDeleteData
  ))
  commandObjects.add(CommandObject(
    commandType: Command.RenameData,
    desc: "Renames existing data folder.",
    keywords: @["rename", "rn"],
    args: @["[Old Name]", "[New Name]"],
    action: cmdRenameData
  ))
  commandObjects.add(CommandObject(
    commandType: Command.ListAll,
    desc: "Lists exising data folders.",
    keywords: @["list"],
    action: cmdListAll
  ))
  commandObjects.add(CommandObject(
    commandType: Command.RunVSCode,
    desc: &"Runs VSCode by using command = \"{settings.vscodeRunCommand}\".",
    keywords: @["run", "r"],
    args: @["[Args...]"],
    action: cmdRunVSCode
  ))
  commandObjects.add(CommandObject(
    commandType: Command.RevealVSCodeDirectory,
    desc: &"Reveals VSCode Directory using command = \"{settings.vscodeRevealCommand}\"",
    keywords: @["reveal"],
    action: cmdRevealVSCodeDirectory
  ))


#----------------------------------------------------------------------------------
# Check Command args
#----------------------------------------------------------------------------------
template checkArgs(this: CommandObject, inputargs: seq[string]) =
  let argsCount = if this.args.len > 0 and this.args[^1] == "[Args...]": this.args.high else: this.args.len
  if argsCount > 0:
    if inputargs.len > argsCount:
      say "Too many args!"
      return
    if inputargs.len < argsCount:
      say "Please specify", ":"
      for i in this.args:
        stdout.write(" " & i)
      stdout.write "\n"
      return


#----------------------------------------------------------------------------------
# Get input and run command (Run this in a loop)
#----------------------------------------------------------------------------------
proc getInputAndRunCommand*() =
  say ""
  say "", "> "
  let input = stdin.readLine().toLowerAscii().splitWhitespace()
  let inputKeyword: string = if input.len > 0: input[0] else: ""
  let inputArgs: seq[string] = if input.len > 1: input[1..^1] else: @[]
  for obj in commandObjects:
    for keyword in obj.keywords:
      if inputKeyword == keyword:
        obj.checkArgs(inputArgs)
        obj.action(obj, inputArgs).whenErr((err: Exception) => echo err.msg)
        return
  say "Invalid Command!"
