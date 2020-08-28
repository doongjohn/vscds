{.experimental: "codeReordering".}

import os
import strformat
import json
import cli_say


#----------------------------------------------------------------------------------
# Error
#----------------------------------------------------------------------------------
type SettingsError = object of Defect


#----------------------------------------------------------------------------------
# Settings Object
#----------------------------------------------------------------------------------
type Settings* = ref object
  vscodeRunCommand: string
  vscodeRevealCommand: string
  vscodePath: string
  inactiveFolderName: string
  currentDataName: string

func vscodeRunCommand*(this: Settings): auto = this.vscodeRunCommand
func vscodeRevealCommand*(this: Settings): auto = this.vscodeRevealCommand
func vscodePath*(this: Settings): auto =
  if this.vscodePath == "": raise newException(SettingsError, "Error [settings.json]: \"vscodePath\" can't be empty!")
  this.vscodePath
func inactiveFolderName*(this: Settings): auto =
  if this.inactiveFolderName == "": raise newException(SettingsError, "Error [settings.json]: \"inactiveFolderName\" can't be empty!")
  this.inactiveFolderName
func currentDataName*(this: Settings): auto =
  if this.currentDataName == "": raise newException(SettingsError, "Error[settings.json]: \"currentDataName\" can't be empty!")
  this.currentDataName


#----------------------------------------------------------------------------------
# Settings json
#----------------------------------------------------------------------------------
var settings*: Settings = nil
let settingsFileName = "settings.json"
let settingsFilePath* = joinPath(getAppDir(), settingsFileName)
let settingsJson = %*
  {
    "vscodeRunCommand": "code",
    "vscodeRevealCommand": "explorer vscode-path",
    "vscodePath": "vscode-path",
    "inactiveFolderName": "data-inactive",
    "currentDataName": "default"
  }


#----------------------------------------------------------------------------------
# Data
#----------------------------------------------------------------------------------
var vscDataPath* = ""
var inactiveDataPath* = ""


#----------------------------------------------------------------------------------
# Check Settings
#----------------------------------------------------------------------------------
proc checkSettingsFileExists(): bool =
  result = true
  if not settingsFilePath.existsFile():
    say(&"Error [settings.json]: Can't find \"settings.json\"!")
    newSettingsFile()
    result = false


proc validateSettings() =
  var hasError = false
  template check(thing: untyped) =
    try:
      discard thing
    except:
      hasError = true
      echo getCurrentExceptionMsg()

  check(vscodePath(settings))
  check(inactiveFolderName(settings))
  check(currentDataName(settings))
  if hasError: quit()


#----------------------------------------------------------------------------------
# Create Settings file
#----------------------------------------------------------------------------------
proc newSettingsFile() =
  settingsFilePath.writeFile(settingsJson.pretty())
  say(&"New \"{settingsFileName}\" has been created at \"{settingsFilePath}\"\nPlease configure it.")


#----------------------------------------------------------------------------------
# Load Settings file
#----------------------------------------------------------------------------------
proc loadSettingsFile*() =
  if not checkSettingsFileExists(): quit()
  try:
    # parse json file
    settings = settingsFilePath.parseFile().to Settings
    # validate json file
    validateSettings()
    # init variables
    vscDataPath = joinPath(settings.vscodePath, "data")
    inactiveDataPath = joinPath(settings.vscodePath, settings.inactiveFolderName)
  except:
    say(&"Error [settings.json]: Can't parse JSON file!")
    newSettingsFile()
    quit()


#----------------------------------------------------------------------------------
# Save Settings file
#----------------------------------------------------------------------------------
proc saveSettingsFile*(currentDataName: string) =
  if not checkSettingsFileExists(): return
  try:
    let jsonNode = settingsFilePath.parseFile()
    jsonNode["currentDataName"] = %currentDataName
    settings = jsonNode.to Settings
    settingsFilePath.writeFile(jsonNode.pretty())
  except:
    echo getCurrentExceptionMsg()