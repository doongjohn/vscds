# VS Code Data Swapper

This console app takes advantage of [VS Code Portable Mode](https://code.visualstudio.com/docs/editor/portable) to make your VS Code Environment more Organized.

**※ Currently only tested on Windows 10!**  
**※ Currently it does not work on MacOS!**

## What it does

It simply swaps `data` folder!  
_see [VS Code Portable Mode](https://code.visualstudio.com/docs/editor/portable)_

## Installing

using [nimble](https://github.com/nim-lang/nimble):

```nimble
nimble install vscds
```

## How to use

1. install vscds
1. run vscds using a terminal
1. configure settings.json
1. run vscds and enter `help` or `?` for help

## Settings

`settings.json`

```jsonc
// Command for starting VS Code.
// (Uses startProcess())
"vscodeRunCommand": "code",

// Command for Revealing VS Code directory.
// (Uses execCmd())
// (If a explorer.exe is launched successfully, it returns  exit code 1)
"vscodeRevealCommand": "explorer \"D:\\My Apps\\VS-Code\"",

// Location of the VS Code executable.
"vscodePath": "D:\\My Apps\\VS-Code",

// Inactive data folders will be stored inside this folder.
"inactiveFolderName": "data-inactive",

// Currently active Data name.
// (If it becomes inactive it will be renamed and moved to '<VS Code Path>/data-inactive/nim')
"currentDataName": "nim"
```

## Features
- [x] CMD: Show help.
- [x] CMD: Open settings file.
- [x] CMD: Swap data folder.
- [x] CMD: Create data folder.
- [x] CMD: Delete data folder.
- [x] CMD: Rename data folder.
- [x] CMD: List all data folders.
- [x] CMD: Run VS Code.
- [x] CMD: Reveal VS Code directory in explorer.

## TODO
- [ ] ADD: MacOS Support(?).
- [ ] FIX: Exterminate bugs.

## Change Log

[CHANGELOG.md](https://github.com/doongjohn/vscds/blob/master/CHANGELOG.md)