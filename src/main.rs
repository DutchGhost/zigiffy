#[link(name = "zig", kind = "static")]
extern "C" {
    //    #[no_mangle]
    fn printing(buf: *const u8, len: usize);

    //#[no_mangle]
    fn itoa_u64(n: u64, buf: *mut u8, len: usize);
}

fn print<S: AsRef<str>>(s: S) {
    let s: &str = s.as_ref();

    unsafe {
        printing(s.as_ptr(), s.len());
    }
}

fn itoa(n: u64, buf: &mut [u8]) {
    let len = buf.len();
    let ptr = buf.as_mut_ptr();

    unsafe {
        itoa_u64(n, ptr, len);
    }
}
fn main() {
    let s = String::from("hello");

    print(&s);

    let n: u64 = 123456;

    let mut buff = vec![0; 6];

    itoa(n, &mut buff);

    println!("{:?}", std::str::from_utf8(&buff));
}
