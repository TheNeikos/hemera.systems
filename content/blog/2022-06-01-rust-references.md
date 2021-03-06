---
date: "2022-06-01T09:29:32+02:00"
---

# Returning Rust References

In [[rust]] you can easily take a reference of any value with the `&` operator.
But something I've been having in the back of my head recently is why the
following works:

```rust
struct FancyString(String);

impl FancyString {
    fn get_str(&self) -> &str {
        &self.0
    }
}
```

After all we are creating a reference _in the function and returning it_! For
some reason this bothered me. You can only return something that outlives the
scope it is created in, so what bothered me? Well, the fact that we are
'reaching into' the `&self` reference and take a reference to a value inside of
that to return it! Since `self.0` is a `String` this feels like we 'taking'
something out of a shared reference (`&`) and then referencing _that_! This
didn't seem right to me, since Rust exactly prevents shenanigans like that.

But this code does compile so somewhere my assumption was wrong. After a nice
chat in the [\#rust matrix channel](https://matrix.to/#/#rust:matrix.org) I've
found where I went wrong:

`self.0` is _not_ a 'value' expression! There is no value that exists, but this
is something called a 'place' expression. You can read more about them in the
[rust
reference](https://doc.rust-lang.org/reference/expressions.html#place-expressions-and-value-expressions).

But basically place expression evaluate to a _place in memory_, and value
expressions represent an actual value. Since I am taking a reference to a place
in memory, the rust compiler can attach to that reference the same lifetime it
took to get to it in the first place (i.e. the lifetime of `&self`).

And that's why returning that reference is fine, since:

- We are pointing to memory with a 'live' lifetime once we exit (it was an input)
- We never 'took' the `String` out of `self`, and thus never had a value

