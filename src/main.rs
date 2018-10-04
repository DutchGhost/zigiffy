#[link(name = "hello")]
extern {
    fn add(a: i32, b: i32) -> i32;
    fn printing(buf: *const u8, len: usize);
}

fn main() {
    unsafe {
        println!("{:?}", add(2, 10));

        let s = "hello";

        printing(s.as_ptr(), s.len());
    }
}

