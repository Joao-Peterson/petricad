# Petricad

This is Petricad, a modern PetriNet editor/simulator/analyser made in flutter for Linux and Windows.

# Summary
- [Petricad](#petricad)
- [Summary](#summary)
- [Command palette](#command-palette)
- [Configuration](#configuration)
  - [Shortcuts](#shortcuts)
- [Themes](#themes)

# Command palette

Access various options and commands via the command palette by pressing `ctrl+p` !

# Configuration

This application automatically creates a config folder named `.petricad` in your home folder.

Examples:

- Windows: `C:\Users\YourUser\.petricad`  
- Linux: `~/.petricad`  

The file [config.json](assets/config.json) contains configurations about shortcuts/language/[themes](#themes)/etc...

## Shortcuts

Currently the flutter shortcuts supported are combinations of single keys + modifiers in a syntex like this:

- `ctrl+p`
- `ctrl+shift+esc`
- `f1`

**Only** user **one key** per shortcut and **zero or more unique modifiers**.

Possible keys:
- Modifiers
  - `ctrl`
  - `shift`
  - `alt`
  - `meta`
- Keys
  - Any lowercase alphabetic key, any number, symbols like `/`, `|`, `\`, `.`, `,`, `'`, `"`, `:`, `;`, `!`, `#`, `-`, `+`, `_`, `=`, `{}`, `[]`, `()`. (When using symbols that require a modifier like `shift`, **do not** add the modifier in the `config` file)
  - `esc`
  - `ins`
  - `del`
  - `enter`
  - `space`
  - `backspace`
  - `f1`
  - `f2`
  - `f3`
  - `f4`
  - `f5`
  - `f6`
  - `f7`
  - `f8`
  - `f9`
  - `f10`
  - `f11`
  - `f12`

As of the time for this commit, `shift` and other modifier/key combinations do not work properly on desktop/linux (for instance), see [this pull request](https://github.com/flutter/flutter/pull/102709), so **beware**. Tested shortcuts include simple combinations with `alt`, `ctrl` and alphabetic/numeric keys. 

# Themes

Theming is made in an awesome way, you can just drag and drop Visual Studio Code themes (.json files) directly inside `.petricad/themes`, they will be made available upon opening the app or by using the command `Application: Reload resources` using the [command palette](#command-palette).