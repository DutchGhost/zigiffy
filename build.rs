use std::env;
use std::path::Path;

use std::process::Command;

fn main() {
    let compiler = env::var("ZIG_COMPILER").expect("Failed to find compiler");

    let dir = env::var("CARGO_MANIFEST_DIR").unwrap();
    let path = Path::new(&dir);

    env::set_current_dir(path.join("zig/src")).unwrap();

    Command::new(compiler)
        .args(&[
            "build-lib",
            "-fPIC",
            "zig.zig",
            "-Drelease-fast",
            "--bundle-compiler-rt",
        ])
        .output()
        .expect("Failed to compile Zig lib");

    env::set_current_dir(path).unwrap();

    println!(
        "cargo:rustc-link-search=native={}",
        Path::new(&dir).join("zig/src/").display()
    );
}
