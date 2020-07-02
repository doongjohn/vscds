import math
import streams
import strutils
import strformat
import terminal




proc say*(msg: string, prefix: string = "| ", lineBreak: bool = true) =
  var indent = 0
  for ch in msg:
    if ch != ' ': break
    indent.inc()
  
  proc lineWrap(line: string): string =
    let termWidth = terminalWidth() - prefix.len
    if line.len <= termWidth: return line
    let wrapped = newStringStream("")
    var i = 0
    while i < (line.len.float / termWidth.float).ceil.int:
      var curLine = ""
      try: curLine = line[i*termWidth .. i*termWidth+termWidth]
      except: curLine = line[i*termWidth .. ^1]
      # if i != 0: wrapped.write &"{prefix}{' '.repeat(indent)}"
      if i != 0: wrapped.write &"{prefix}"
      wrapped.write curLine
      i.inc()
    wrapped.setPosition(0)
    result = wrapped.readAll()
    wrapped.close()
  
  var splited = msg.split('\n')
  var res = newStringStream("")
  var i = 0
  while i < splited.len:
    splited[i] = splited[i].lineWrap()
    # res.write(if i == 0: &"{prefix}" else: &"\n{prefix}{' '.repeat(indent)}")
    res.write(if i == 0: &"{prefix}" else: &"\n{prefix}")
    res.write(splited[i])
    i.inc()
  res.setPosition(0)
  if lineBreak: echo res.readAll()
  else: stdout.write res.readAll()
  res.close()


proc showTitle*() =
  eraseScreen()
  setCursorPos(0, 0)
  say "<VSCode Data Swapper>"


proc showBasicInfo*() =
  say "Welcome back!"
  say "Enter \"help\" or \"?\" for help."


proc showExitText*() =
  say "See you soon!"