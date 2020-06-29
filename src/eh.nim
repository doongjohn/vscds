template whenOk*(e: ref Exception, body: untyped) =
  if e == nil:
    body
  else:
    echo e.msg


template catchException*(body: untyped) =
  try:
    body
  except:
    result = getCurrentException()
    echo result.msg
  