{.experimental: "codeReordering".}

import math
import strutils
import terminal
import utils


const defaultPrefix = "| "
var sayBuffer = ""


proc sayAdd*(msg: string) =
  sayBuffer &= msg


proc sayIt*(prefix = defaultPrefix, lineBreak = true, keepIndent = true) =
  say(sayBuffer, prefix, lineBreak, keepIndent)
  sayBuffer = ""


proc getIndentCount(text: string): int =
  for c in text:
    if c != ' ': break
    result.inc()


proc say*(msg: string, prefix = defaultPrefix, lineBreak = true, keepIndent = true) =
  let prefixWIndent = 
    if keepIndent:
      prefix & ' '.repeat(msg.getIndentCount())
    else:
      prefix
  
  let writeWidth = terminalWidth() - (if keepIndent: prefixWIndent.len() else: prefix.len())
  
  proc lineWrap(line: string): string =
    if line.len <= writeWidth: return line
    var i = 0
    loop(i < (line.len.float / writeWidth.float).ceil.int, i.inc()):
      if i != 0:
        result &= '\n' & prefixWIndent
      let startPos = i*writeWidth-i
      let endPos = startPos+writeWidth-2
      if line.len >= endPos:
        result &= line[startPos .. endPos]
      else:
        result &= line[startPos .. ^1]
  
  var final = ""
  let splited = msg.splitLines()
  var i = 0
  loop(i < splited.len, i.inc):
    final &= (if i == 0: prefix else: '\n' & prefixWIndent)
    final &= splited[i].lineWrap()
  if lineBreak: final &= '\n'
  stdout.write(final)


proc showTitle*() =
  eraseScreen()
  setCursorPos(0, 0)
  say "----------------------"
  say "<VS Code Data Swapper>"
  say "----------------------"


proc showWelcomeText*() =
  say "Welcome back!"
  say "Enter \"help\" or \"?\" for help."


proc showExitText*() =
  say "See you soon!"