# TruthDB Installer

The TruthDB Installer is an EFI executable written in Rust that provides a graphical installation interface for TruthDB.

## Features

- Command-line argument parsing using `clap`
- Error handling with `anyhow` and `thiserror`
- Graphics mode using `minifb` for wide hardware compatibility
- Displays TruthDB logo on startup
- Designed to run on the TruthDB installer Linux kernel

## Building

```bash
cargo build --release
```

The compiled binary will be located at `target/release/truthdb-installer`.

## Usage

```bash
# Run with default settings (1024x768)
./truthdb-installer

# Run with custom resolution
./truthdb-installer --width 1920 --height 1080

# Run in text mode (for testing)
./truthdb-installer --no-graphics

# Show help
./truthdb-installer --help
```

## Options

- `--width <WIDTH>`: Set the graphics window width (default: 1024)
- `--height <HEIGHT>`: Set the graphics window height (default: 768)
- `--no-graphics`: Skip graphics mode for testing
- `-h, --help`: Print help information
- `-V, --version`: Print version information

## Architecture

The installer is designed to:
1. Parse command line arguments quickly
2. Initialize graphics mode as soon as possible
3. Display the TruthDB logo
4. Provide a platform for future installer functionality

The current implementation is a skeleton that demonstrates the core graphics initialization and logo display functionality.
