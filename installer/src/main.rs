use anyhow::{Context, Result};
use clap::Parser;
use minifb::{Key, Window, WindowOptions};

/// TruthDB Installer - EFI installer executable for TruthDB
#[derive(Parser, Debug)]
#[command(name = "truthdb-installer")]
#[command(author, version, about, long_about = None)]
struct Args {
    /// Width of the graphics window
    #[arg(long, default_value_t = 1024)]
    width: usize,

    /// Height of the graphics window
    #[arg(long, default_value_t = 768)]
    height: usize,

    /// Skip graphics mode (for testing)
    #[arg(long, default_value_t = false)]
    no_graphics: bool,
}

#[derive(Debug, thiserror::Error)]
enum InstallerError {
    #[error("Failed to initialize graphics mode: {0}")]
    GraphicsInitError(String),
}

fn main() -> Result<()> {
    let args = Args::parse();

    if args.no_graphics {
        println!("TruthDB Installer started (no graphics mode)");
        return Ok(());
    }

    run_installer(args)
}

fn run_installer(args: Args) -> Result<()> {
    // Initialize graphics mode
    let mut window = Window::new(
        "TruthDB Installer",
        args.width,
        args.height,
        WindowOptions::default(),
    )
    .context("Failed to create graphics window")?;

    // Limit to max ~60 fps update rate
    window.set_target_fps(60);

    // Create a buffer to hold the pixel data
    let mut buffer: Vec<u32> = vec![0; args.width * args.height];

    // Display TruthDB logo (placeholder - simple pattern for now)
    display_logo(&mut buffer, args.width, args.height)?;

    // Main event loop
    while window.is_open() && !window.is_key_down(Key::Escape) {
        // Update the window with the buffer
        window
            .update_with_buffer(&buffer, args.width, args.height)
            .map_err(|e| InstallerError::GraphicsInitError(e.to_string()))?;
    }

    Ok(())
}

fn display_logo(buffer: &mut [u32], width: usize, height: usize) -> Result<()> {
    // Simple placeholder: Create a blue background with white text area
    // representing where the TruthDB logo would be displayed
    
    // Background color (dark blue)
    let bg_color = 0x001F3F;
    
    // Fill background
    for pixel in buffer.iter_mut() {
        *pixel = bg_color;
    }
    
    // Create a white rectangle in the center to represent logo area
    let logo_width = 400;
    let logo_height = 200;
    let start_x = (width - logo_width) / 2;
    let start_y = (height - logo_height) / 2;
    let logo_color = 0xFFFFFF;
    
    for y in start_y..start_y + logo_height {
        for x in start_x..start_x + logo_width {
            if y < height && x < width {
                buffer[y * width + x] = logo_color;
            }
        }
    }
    
    Ok(())
}
