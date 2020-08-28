template loop*(condition: bool, after: untyped, body: untyped) =
  while condition:
    defer: after
    body


template loop*(count: int, body: untyped) =
  var i = 0
  loop(i < count, i.inc()):
    body