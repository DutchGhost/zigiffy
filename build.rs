use std::env;
use std::path::Path;

use std::process::Command;

fn main() {
    println!("cargo:rerun-if-changed=build.rs");
    let compiler = env::var("ZIG_COMPILER").expect("Failed to find compiler");

    let dir = env::var("CARGO_MANIFEST_DIR").unwrap();
    let path = Path::new(&dir);

    env::set_current_dir(path.join("zig")).unwrap();

    Command::new(compiler)
        .args(&["build", "-Drelease-fast"])
        .output()
        .expect("Failed to compile Zig lib");

    env::set_current_dir(path).unwrap();

    println!(
        "cargo:rustc-link-search=native={}",
        Path::new(&dir).join("zig/zig-cache/lib").display()
    );

    // // On windows, link against ntdll
    // #[cfg(target_os = "windows")]
    // {
    //     println!("cargo:rustc-link-lib={}={}", "dylib", "ntdll");
    // }
}
