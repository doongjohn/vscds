import times
import terminal
import cli_say


var loadingThread: Thread[tuple[loadingMsg, completeMsg: string]]
var loadingChan: Channel[bool]
loadingChan.open()


proc loadingSpinner(msgs: tuple[loadingMsg, completeMsg: string]) {.thread.} =
  hideCursor()
  const spinnerAnim = ["⠋", "⠙", "⠹", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
  var animIter = 0
  var animFrame = 0
  
  var frameStartTime = 0.0
  var deltaTime = 0.0
  var curTime = 0.0

  while true:
    let tryMsg = loadingChan.tryRecv()
    if tryMsg.dataAvailable and not tryMsg.msg:
      break
    
    frameStartTime = cpuTime()
    if curTime >= 0.05:
      curTime = 0
      animFrame = animIter mod spinnerAnim.len
      animIter.inc()
    curTime += deltaTime
    
    stdout.setCursorXPos(0)
    say(spinnerAnim[animFrame] & " " & msgs.loadingMsg, lineBreak = false)
    deltaTime = cpuTime() - frameStartTime
  
  eraseLine()
  say msgs.completeMsg
  showCursor()


proc startLoadingSpinner*(loadingMsg, completeMsg: string) =
  loadingThread.createThread(loadingSpinner, (loadingMsg, completeMsg))


proc endLoadingSpinner*() =
  loadingChan.send(false)
  loadingThread.joinThread()