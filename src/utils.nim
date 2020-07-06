import streams


template loop*(condition: bool, after: untyped, body: untyped) =
  while condition:
    body
    after


proc readAllAndClose*(stringStream: StringStream): string =
    stringStream.setPosition(0)
    result = stringStream.readAll()
    stringStream.close()