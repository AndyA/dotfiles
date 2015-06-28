terminal-panel
==============

Terminal-panel executes your commands and displays the output. This means you can do all sorts of useful stuff right inside Atom, like:
* run build scripts
* start servers
* npm/apm (install, publish, etc)
* grunt
* etc. etc.

Some things it can't do (yet):
* The "terminal" isn't interactive so it can't do tab-autocomplete
* Or ask for a commit message
* ... stuff like that.

## Usage
Just press ``ctrl-` ``.

## Screenshot

![A screenshot of terminal-status package](https://raw.githubusercontent.com/thedaniel/terminal-panel/master/terminal-demo.gif)

## Feature

* multiple terminals
* status icon
* kill long running processes
* optional fancy ls

## Hotkeys

* ``ctrl-` `` toggle current terminal
* `command-shift-t` new terminal
* `command-shift-j` next terminal
* `command-shift-k` prev terminal
* `command-shift-x` destroy terminal
* `up` and `down` for "command history"

---
A fork of [guileen/terminal-status](https://github.com/guileen/terminal-status).
