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

## Configuration

The default configuration should work for most setups. If you need to modify any settings, you can edit the `config.sh` file in the installation directory.

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
