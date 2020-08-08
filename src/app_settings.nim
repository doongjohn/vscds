{.experimental: "codeReordering".}

import os
import strformat
import json
import cli_text


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
    "dataPrefix": "data-vscds-",
    "currentDataName": "default"
  }


#----------------------------------------------------------------------------------
# Data
#----------------------------------------------------------------------------------
var vscDataPath* = ""


#----------------------------------------------------------------------------------
# Check Settings
#----------------------------------------------------------------------------------
proc checkSettingsFileExists(): bool =
  result = true
  if not settingsFilePath.existsFile():
    say &"Can't find \"{settingsFileName}\"!"
    newSettingsFile()
    result = false


proc validateSettings() =
  try:
    if settings.dataPrefix == "": raise newException(SettingsError, "dataPrefix can't be empty!")
    if settings.currentDataName == "": raise newException(SettingsError, "currentDataName can't be empty!")
    vscDataPath = joinPath(settings.vscodePath, "data")
  except: 
    echo getCurrentExceptionMsg()
    quit()


#----------------------------------------------------------------------------------
# Create Settings file
#----------------------------------------------------------------------------------
proc newSettingsFile() =
  settingsFilePath.writeFile(settingsJson.pretty())
  say &"New \"{settingsFileName}\" has been created at \"{settingsFilePath}\"\nPlease configure it."


#----------------------------------------------------------------------------------
# Load Settings file
#----------------------------------------------------------------------------------
proc loadSettingsFile*() =
  if not checkSettingsFileExists(): quit()
  try:
    settings = settingsFilePath.parseFile().to Settings
    validateSettings()
  except:
    say &"Corrupted \"{settingsFileName}\"!"
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