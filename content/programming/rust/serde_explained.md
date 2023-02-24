# Serde Explained

## Overview

[`serde`](https://serde.rs/) is the most used Serialization/Deserialization library in the Rust ecosystem. 
It is easy to use, thanks to its annotation based macros and, due to the community, has a multitude of supported formats.
But how does it work? How does `serde` manage to take your data structure and seamlessly serialize and deserialize it?
How can code from two different crates interoperate so well?
I will try to answer these questions with this small workshop. 
In the process we will make our own toy implementation of `serde`, and then expand it to understand why `serde` is written the way it is.



## Getting Started

> If you want to follow at home, be sure to have an up-to-date rust compiler.

Let's start by defining the end product of what we want to achieve for now: Deserializing a custom struct.

```rust
#[derive(Debug)]
struct Information {
  orders: Vec<u32>,
  name: String,
  value: f32,
}

impl Deserialize for Information {
 // To be determined
}

let input = r#"
orders = 25, 123, 42
name = "Hello World"
value = 13.37
"#;

let info: Information = deserialize_from_string(input);
println!("{info:#?}");
```

It's a rough outline, but it shows what we want to ultimately achieve: Given a string of data, we want to deserialize it into our typed struct.
