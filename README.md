# hx-utils

hx-utils is a collection of utility scripts designed to enhance the Helix editor experience, particularly when used with terminal multiplexers like tmux or WezTerm.

## Acknowledgements

This project was inspired by and initially based on the work of Quan Tong Anh:

- Original scripts: [helix-wezterm](https://github.com/quantonganh/helix-wezterm)
- Blog post: [Turning Helix into an IDE with the help of WezTerm and CLI tools](https://quantonganh.com/2023/08/19/turn-helix-into-ide.md)

The original scripts have been significantly modified and extended to support multiple terminal multiplexers and provide additional functionality.

## Features

- Open files in Helix from the terminal
- Integrate Helix with other tools (git blame, file explorer, fuzzy finder)
- Cross-multiplexer window management (supports tmux and WezTerm)
- Fuzzy file search and opening

## Prerequisites

- Helix editor
- Either tmux or WezTerm
- ripgrep (rg)
- fzf
- bat

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/hx-utils.git
   cd hx-utils
   ```

2. Run the setup script:
   ```bash
   ./setup.sh
   ```

   This script will check for dependencies, install the utilities, and add them to your PATH.

## Usage

### Example helix config

```toml
[keys.normal.space]
e = ":sh hx-utils explorer"

[keys.normal.";"]
b = ":sh hx-utils blame"
o = ":sh hx-utils open"
f = ":sh winmux sp hx-fzf > /dev/null"
t = ":sh winmux sp fish > /dev/null"
```

### hx-utils

The main utility script. Use it to open files or integrate with other tools.

```bash
hx-utils open [FILE]
hx-utils blame
hx-utils explorer
hx-utils fzf
hx-utils browse
```

### winmux

A cross-multiplexer window management utility.

```bash
winmux [OPTION]... [COMMAND] [ARGS]...
```

Options:
- `-m, --mode`: Set the mode to 'tmux' or 'wezterm'
- `-p, --percent`: Set the size of the panel as a percentage
- `-h, --help`: Display help and exit

Commands:
- `vsp`: Split vertically
- `sp`: Split horizontally
- `focus-left`, `focus-right`, `focus-up`, `focus-down`: Focus on adjacent panes
- `popup`: Create a popup window

### hx-fzf

A fuzzy finder utility for Helix.

```bash
hx-fzf
```

### hx-open

`hx-open` is a standalone script designed to open files in the Helix editor from the terminal or other programs. It supports both tmux and WezTerm terminal multiplexers.

#### Usage

```bash
hx-open [OPTIONS] [FILE]
```

#### Options

- `-m, --mode [tmux|wezterm]`: Specify the multiplexer mode. Auto-detected if not specified.
- `-d, --direction [DIRECTION]`: Specify the pane direction ('top', 'bottom', 'left', 'right'). Default is 'right'.
- `-s, --split [TYPE]`: Specify the split type ('v' for vertical, 'h' for horizontal, 'none' for no split).
- `-p, --percent [PERCENT]`: Specify the default panel size percentage. Default is 80.
- `-h, --help`: Display help and exit.

#### Examples

1. Open a file in the default right pane:
   ```bash
   hx-open /path/to/file.txt
   ```

2. Open a file in a new vertical split with 70% width:
   ```bash
   hx-open -d right -s v -p 70 /path/to/file.txt
   ```

3. Open a file in a new horizontal split at the bottom:
   ```bash
   hx-open -d bottom -s h /path/to/file.txt
   ```

4. Explicitly specify the multiplexer mode:
   ```bash
   hx-open -m tmux /path/to/file.txt
   ```

#### Integration with Other Programs

You can set `hx-open` as the default editor for various programs. For example:

- Git: `git config --global core.editor "hx-open"`
- Environment variable: Add `export EDITOR="hx-open"` to your shell configuration file (e.g., `.bashrc` or `.zshrc`)

This allows `hx-open` to be used seamlessly with other command-line tools that invoke an editor.

#### Notes

- `hx-open` requires either tmux or WezTerm to be running.
- It attempts to reuse existing Helix instances if possible, opening new files in splits within the same instance.
- The script sources `config.sh` from the hx-utils installation, ensuring consistent behavior with other hx-utils scripts.

## Updating

To update hx-utils to the latest version:

1. Pull the latest changes from the repository
2. Run `make update`

## Uninstalling

To uninstall hx-utils:

```bash
make uninstall
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
