// fn main() {
//     println!("cargo:rustc-link-search=native=/zig");
//     println!("cargo:rustc-link-lib=static=hello");
// }

use std::path::Path;
use std::env;

fn main() {
    let dir = env::var("CARGO_MANIFEST_DIR").unwrap();
    println!("cargo:rustc-link-search=native={}", Path::new(&dir).join("zig").display());

    println!("cargo:rustc-link-lib=static=hello");
}
