import times
import terminal
import utils/loop
import cli_say
import cli_utils
import cli_spinner_anim

export cli_spinner_anim


type SpinnerOptions = tuple[
  spinnerAnim: SpinnerAnim,
  spinnerMsg: string,
]


var spinnerThread: Thread[SpinnerOptions]
var spinnerChan: Channel[bool]
spinnerChan.open()


proc spinnerMain(spinnerOptions: SpinnerOptions) {.thread.} =
  let (spinnerAnim, spinnerMsg) = spinnerOptions
  let interval = spinnerAnim.interval
  let anim = spinnerAnim.anim
  var frameStartTime = 0.0
  var deltaTime = 0.0
  var curTime = 0.0
  var animFrame = 0
  var showMsg = ""
  
  hideCursor()
  defer:
    showCursor()
    var i = 0
    var lineCount = showMsg.getLineCount()
    loop(i < lineCount, i.inc()):
      stdout.eraseLine()
      if i != lineCount - 1: stdout.cursorUp()

  while true:
    let chanMsg = spinnerChan.tryRecv()
    if chanMsg.dataAvailable and not chanMsg.msg:
      break
    
    frameStartTime = cpuTime()
    defer: deltaTime = cpuTime() - frameStartTime
    
    if curTime >= interval:
      curTime = 0
      animFrame.inc()
      animFrame = animFrame mod anim.len
    curTime += deltaTime
    
    stdout.setCursorXPos(0)
    stdout.cursorUp(showMsg.getLineCount() - 1)
    showMsg = getSayString(anim[animFrame] & " " & spinnerMsg, lineBreak = false)
    stdout.write(showMsg)
  

proc endSpinner*() =
  if not spinnerThread.running(): return
  spinnerChan.send(false)
  spinnerThread.joinThread()


proc startSpinner*(spinnerOptions: SpinnerOptions) =
  if spinnerThread.running(): return
  spinnerThread.createThread(spinnerMain, spinnerOptions)


proc startSpinner*(anim: static SpinnerAnim, loadingMsg: string) =
  if spinnerThread.running(): return
  spinnerThread.createThread(spinnerMain, (anim, loadingMsg))


template startSpinner*(anim: SpinnerAnim, loadingMsg: string, body: untyped) =
  block:
    startSpinner(anim, loadingMsg)
    defer: endSpinner()
    body
