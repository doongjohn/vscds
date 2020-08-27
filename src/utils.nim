template loop*(condition: bool, after: untyped, body: untyped) =
  while condition:
    body
    after
