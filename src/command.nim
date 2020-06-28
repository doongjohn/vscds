import strutils
import strformat
import settings_manager
import console_interface


type Command* {.pure.} = enum
  Help,
  Clear,
  Exit,
  SwapData,
  NewData,
  DeleteData,
  RenameData,
  ListAll,
  RunVSCode,
  RevealVSCodeDirectory

type CommandObject* = object
  commandType: Command
  desc: string
  keywords: seq[string]
  options: seq[string]
  action: proc(this: CommandObject, inputOptions: seq[string]): void

func commandType*(this: CommandObject): auto = this.commandType
func desc*(this: CommandObject): auto = this.desc
func keywords*(this: CommandObject): auto = this.keywords
func options*(this: CommandObject): auto = this.options


var commandObjects* = newSeq[CommandObject]()


import command_action


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
    keywords: @["swap", "set"],
    options: @["[DATA NAME]"],
    action: cmdSwapData
  ))
  commandObjects.add(CommandObject(
    commandType: Command.NewData,
    desc: "Creates new data folder.",
    keywords: @["new"],
    options: @["[DATA NAME]"],
    action: cmdNewData
  ))
  commandObjects.add(CommandObject(
    commandType: Command.DeleteData,
    desc: "Deletes existing data folder.",
    keywords: @["delete", "del"],
    options: @["[DATA NAME]"],
    action: cmdDeleteData
  ))
  commandObjects.add(CommandObject(
    commandType: Command.RenameData,
    desc: "Renames existing data folder.",
    keywords: @["rename", "rn"],
    options: @["[OLD NAME]", "[NEW NAME]"],
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
    options: @["[args...]"],
    action: cmdRunVSCode
  ))
  commandObjects.add(CommandObject(
    commandType: Command.RevealVSCodeDirectory,
    desc: &"Reveals VSCode Directory using command = \"{settings.vscodeRevealCommand}\"",
    keywords: @["reveal"],
    action: cmdRevealVSCodeDirectory
  ))


template checkOptions(this: CommandObject, inputOptions: seq[string]) =
  if this.options.len != 0 and this.options[0] != "[args...]":
    if inputOptions.len > this.options.len:
      say "Too many options!"
      return
    if inputOptions.len < this.options.len:
      say "Please specify", ":"
      for i in this.options:
        stdout.write(" " & i)
      stdout.write "\n"
      return


proc getInputAndRunCommand*() =
  say ""
  say "", "> "
  let input = stdin.readLine().toLowerAscii().splitWhitespace()
  let inputKeyword: string = if input.len > 0: input[0] else: ""
  let inputOptions: seq[string] = if input.len > 1: input[1..^1] else: @[]
  for obj in commandObjects:
    for keyword in obj.keywords:
      if inputKeyword == keyword:
        obj.checkOptions(inputOptions)
        obj.action(obj, inputOptions)
        return
  
  say "Invalid Command!"