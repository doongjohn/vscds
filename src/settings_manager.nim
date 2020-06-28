import os
import json
import strformat
import console_interface


type SettingsError = object of Defect


type Settings* = ref object
  vscodeRunCommand: string
  vscodeRevealCommand: string
  vscodePath: string
  dataPrefix: string
  currentDataName: string

func vscodeRunCommand*(this: Settings): auto = this.vscodeRunCommand
func vscodeRevealCommand*(this: Settings): auto = this.vscodeRevealCommand
func vscodePath*(this: Settings): auto = this.vscodePath
func dataPrefix*(this: Settings): auto =
  if this.dataPrefix == "": raise newException(SettingsError, "dataPrefix can't be empty!")
  this.dataPrefix
func currentDataName*(this: Settings): auto =
  if this.currentDataName == "": raise newException(SettingsError, "currentDataName can't be empty!")
  this.currentDataName


var settings*: Settings = nil
let settingsFileName = "settings.json"
let settingsFilePath = joinPath(getCurrentDir(), settingsFileName)
let settingsJson = %*
  {
    "vscodeRunCommand": "code",
    "vscodeRevealCommand": "explorer vscode-path",
    "vscodePath": "vscode-path",
    "dataPrefix": "data-vsd-",
    "currentDataName": "default"
  }


proc newSettingsFile() =
  settingsFilePath.writeFile(settingsJson.pretty())
  say &"New \"{settingsFileName}\" has been created at \"{settingsFilePath}\"\nPlease configure it."


proc validateSettings() =
  try:
    if settings.dataPrefix == "": raise newException(SettingsError, "dataPrefix can't be empty!")
    if settings.currentDataName == "": raise newException(SettingsError, "currentDataName can't be empty!")
  except: 
    echo getCurrentExceptionMsg()
    quit()


proc loadSettingsFile*() =
  if settingsFilePath.existsFile():
    let jsonNode = settingsFilePath.parseFile()
    try:
      settings = jsonNode.to Settings
      validateSettings()
    except:
      say &"Corrupted \"{settingsFileName}\"!"
    return
  else:
    say &"Can't find \"{settingsFileName}\"!"
  newSettingsFile()
  quit()


proc saveSettingsFile*(currentDataName: string) =
  try:
    if settingsFilePath.existsFile():
      let jsonNode = settingsFilePath.parseFile()
      jsonNode["currentDataName"] = %currentDataName
      settings = jsonNode.to Settings
      validateSettings()
      settingsFilePath.writeFile(jsonNode.pretty())
  except:
    echo getCurrentExceptionMsg()