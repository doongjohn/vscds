import math
import strutils
import terminal


proc getIndentCount*(text: string): int =
  for c in text:
    if c != ' ': break
    result.inc()


proc getLineCount*(text: string): int =
  let width = terminalWidth()
  for line in text.splitLines():
    if line.len <= width:
      result += 1
    else:
      result += (line.len.float / width.float).ceil.int
