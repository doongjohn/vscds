type SpinnerAnim* = object
  interval*: float # second
  anim*: seq[string]


# ref link: https://github.com/sindresorhus/cli-spinners/blob/master/spinners.json
const dots* = SpinnerAnim(
  interval: 0.05,
  anim: @[
    "⠋",
    "⠙",
    "⠹",
    "⠼",
    "⠴",
    "⠦",
    "⠧",
    "⠇",
    "⠏"
  ]
)
const lines* = SpinnerAnim(
  interval: 0.1,
  anim: @[
    "-",
    "\\",
    "|",
    "/"
  ]
)
const balloon* = SpinnerAnim(
  interval: 0.08,
  anim: @[
    " ",
    ".",
    "o",
    "O",
    "@",
    "*",
    " "
  ]
)
const bouncingBar* = SpinnerAnim(
  interval: 0.07,
  anim: @[
    "[    ]",
    "[=   ]",
    "[==  ]",
    "[=== ]",
    "[ ===]",
    "[  ==]",
    "[   =]",
    "[    ]",
    "[   =]",
    "[  ==]",
    "[ ===]",
    "[====]",
    "[=== ]",
    "[==  ]",
    "[=   ]"
  ]
)