# Petricad

This is Petricad, a modern PetriNet editor/simulator/analyser made in flutter for Linux and Windows.

# Summary
- [Petricad](#petricad)
- [Summary](#summary)
- [Command palette](#command-palette)
- [Configuration](#configuration)
- [Themes](#themes)

# Command palette

Access various options and commands via the command palette by pressing `ctrl+p` !

# Configuration

This application automatically creates a config folder named `.petricad` in your home folder.

Examples:

- Windows: `C:\Users\YourUser\.petricad`  
- Linux: `~/.petricad`  

The file [config.json](assets/config.json) contains configurations about shortcuts/language/[themes](#themes)/etc...

# Themes

Theming is made in an awesome way, you can just drag and drop Visual Studio Code themes (.json files) directly inside `.petricad/themes`, they will be made available upon opening the app or by using the command `Application: Reload resources` using the [command palette](#command-palette).