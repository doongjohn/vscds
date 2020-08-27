# Version 0.3.3

## Added

- [CLI]
  - Added loading spinner when deleting data folder. 

## Changed

none

## Removed

none

# Version 0.3.2

## Added

none

## Changed

- [Misc]
  - Improved error msg and say proc performance.

## Removed

none

# Version 0.3.1

## Added

- [Command]
  - Added command suggestions. (using nimlevenshtein)

## Changed

none

## Removed

none

# Version 0.3.0

## Added

none

## Changed

- [Storing inactive data] **※ Breaking Change!**
  - Now stored in `vscpath/data-inactive/<data-name>` without a `dataPrefix`.

## Removed

- [Settings]
  - Removed `dataPrefix`.

# Version 0.2.1

## Added

- [Github]
  - Added `CHANGELOG.md`.
  - Added Settings section in the `README.md`.

## Changed

none

## Removed

none

## Fixed

- [Misc]
  - Fixed some typos.

# Version 0.2.0

## Added

- [Command]
  - OpenSettings: Open `settings.json` file with `VS Code`.

## Changed

- [Nimble]
  - Package name changed from `vds` to `vscds`.

## Removed

none

## Fixed

- [Misc]
  - Fixed some typos.

# Version 0.1.0 (Initial Commit)

- [Command] 
  - Help: Show all commands.
  - Clear: Clear screen.
  - Exit: Exit vscds.
  - SwapData: Swap `Data folder`.
  - SwapAndRun: Swap `Data folder` and Run `VS Code`.
  - NewData: Create a new `Data folder`.
  - DeleteData: Remove a `Data folder`.
  - RenameData: Rename an existing `Data folder`.
  - ListAll: List existing `Data folders`.
  - RunVSCode: Run `VS Code`. (needs config.)
  - RevealVSCodeDirectory: Reveal `VS Code` directory. (needs config.)