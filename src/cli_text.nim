{.experimental: "codeReordering".}

import math
import streams
import strutils
import terminal
import utils


const defaultPrefix = "| "
var sayBuffer = newStringStream()


proc sayAdd*(msg: string) =
  sayBuffer.write(msg)


proc sayIt*(prefix = defaultPrefix, lineBreak = true, keepIndent = true) =
  say(sayBuffer.readAllAndClose(), prefix, lineBreak, keepIndent)
  sayBuffer = newStringStream()


proc say*(msg: string, prefix = defaultPrefix, lineBreak = true, keepIndent = true) =
  let prefixWIndent = 
    if keepIndent:
      var indent = 0
      for ch in msg:
        if ch != ' ': break
        indent.inc
      prefix & ' '.repeat(indent)
    else:
      prefix
  
  let writeWidth = terminalWidth() - (if keepIndent: prefixWIndent.len() else: prefix.len())
  
  proc lineWrap(line: string): string =
    if line.len <= writeWidth: return line
    let wrapped = newStringStream()
    let lineCount = (line.len.float / writeWidth.float).ceil.int
    var i = 0
    loop(i < lineCount, i.inc):
      if i != 0: wrapped.write(prefixWIndent)
      try:
        let startPos = i*writeWidth
        wrapped.write(line[startPos .. startPos+writeWidth-1])
        wrapped.write('\n')
      except:
        wrapped.write(line[i*writeWidth .. ^1])
    result = wrapped.readAllAndClose()
  
  let res = newStringStream()
  let splited = msg.splitLines()
  var i = 0
  loop(i < splited.len, i.inc):
    if i == 0:
      res.write(prefix)
    else:
      res.write('\n')
      res.write(prefixWIndent)
    res.write(splited[i].lineWrap())
  if lineBreak: res.write('\n')
  stdout.write(res.readAllAndClose())


proc showTitle*() =
  eraseScreen()
  setCursorPos(0, 0)
  say "<VS Code Data Swapper>"


proc showBasicInfo*() =
  say "Welcome back!"
  say "Enter \"help\" or \"?\" for help."


proc showExitText*() =
  say "See you soon!"