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