# VS Code Data Swapper

_This is a recreation of [VSCodeManager](https://github.com/doongjohn/VSCodeManager) using the [Nim](https://nim-lang.org/)_ language.

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

## Features
- [x] CMD: Show help.
- [x] CMD: Open settings file.
- [x] CMD: Swap data folder.
- [x] CMD: Create data folder.
- [x] CMD: Delete data folder.
- [x] CMD: Rename data foler.
- [x] CMD: List all data folers.
- [x] CMD: Run VS Code. _(command can be configured.)_
- [x] CMD: Reveal VS Code directory in explorer. _(command can be configured.)_
- [ ] ADD: MacOS Support(?).
- [ ] FIX: Exterminate bugs.
