#[link(name = "hello")]
extern "C" {
    fn printing(buf: *const u8, len: usize);
}

fn print<S: AsRef<str>>(s: S) {
    let s: &str = s.as_ref();

    unsafe {
        printing(s.as_ptr(), s.len());
    }
}

fn main() {
    let s = String::from("hello");

    print(&s);
}
