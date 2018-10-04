use std::path::Path;
use std::env;

use std::process::Command;


fn main() {
    let dir = env::var("CARGO_MANIFEST_DIR").unwrap();
    let path = Path::new(&dir);
    
    env::set_current_dir(path.join("zig"));
    
    let zig_compiler = path.parent().unwrap().join("zig-0.3").join("zig.exe");

    let zig_compile = Command::new(zig_compiler.to_str().expect("Could not find zig compiler"))
        .args(&["build-lib", "hello.zig"])
        .output()
        .expect("Could not compile zig library");

    env::set_current_dir(path);
   
    println!("cargo:rustc-link-search=native={}", Path::new(&dir).join("zig").display());
}
