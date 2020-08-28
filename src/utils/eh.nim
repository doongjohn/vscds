import sugar


proc whenOk*(err: ref Exception, fun: () -> void): ref Exception {.discardable.} =
  if err == nil:
    fun()
  else:
    return err


proc whenErr*(err: ref Exception, fun: (err: Exception) -> void): ref Exception {.discardable.} =
  if err != nil:
    fun(err[])
    return err


proc whenErr*(err: ref Exception, fun: (err: ref Exception) -> void): ref Exception {.discardable.} =
  if err != nil:
    fun(err)
    return err


template returnException*(body: untyped) =
  try:
    body
  except:
    return getCurrentException()
