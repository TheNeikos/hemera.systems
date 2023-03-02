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


## Writing the `Deserialize` definition and implementation

To get a good idea of what kind of data we might need, let's start by writing the `Deserialize` implementation. Designing data flow from the back to the front is in my opinion the ideal way to proceed, as this allows you to see what is required from what comes before.

An example `Deserialize` definition could look like this:

```rust
trait Deserialize {
  fn deserialize(input: &[u8]) -> Result<Self, DeserializeError>;
}
```

But I consider multiple things problematic already:

1. `input` is formless data. What kind of format is this? JSON? TOML? It's unclear
1. `DeserializeError` could either not be exhaustive enough, if its an enum, or not typed when it's just a custom string

To fix point 1 we have to think about what it means to "input data" from an implementors point of view.

Imagine this implementation (input type intentionally left blank):

```rust
impl Deserialize for Information {
  fn deserialize(input: _) -> Result<Self, DeserializeError> {
     let orders: Vec<u32> = input.get_vector();
     let name: String = input.get_string();
     let value: f32 = input.get_f32();
     
     Ok(Information { orders, name, value })
  }
}
```

Aha! We make it easy for ourselves, instead of trying to decode the input, we just... ask the input to provide that information to us! 
This allows us to add a layer of indirection in between the type to-be-deserialized and the deserializer (who calls 'deserialize').


To rephrase this step: Instead of receiving the raw input data directly, we put a 'something' between that input and the implementation, and use that something to get the much more convenient methods like `get_string`.
This is called an indirection and it decouples the method from the input. 
I can at least imagine that requesting a string from JSON or YAML should both work, or any other similar format.



Thinking a bit more about this step we notice another issue, it seems to not only be order dependent, but we don't even tell it what kind of fields we're expecting...

Let's try to fix that.


```rust
impl Deserialize for Information {
  fn deserialize(input: _) -> Result<Self, DeserializeError> {
     let orders: Vec<u32> = input.get_vector("orders");
     let name: String = input.get_string("name");
     let value: f32 = input.get_f32("value");
     
     Ok(Information { orders, name, value })
  }
}
```

A simple change, but what does it mean for our input? Not good news sadly. 
By choosing this interface, we are _forcing_ `input` to _first_ give us something that corresponds to the the "orders" field, even if maybe "name" came first! 
This is bad news for all but the most pedantic encoding formats. 
I don't think that forcing your input to be in a specific order is a good thing. 
It also makes it harder for you, the programmer! 
Because now you can't change the field order without breaking all existing inputs!
Is there something we can do to fix this?

### Going deeper

To recap, we want to be able to say 'give me a string' or 'give me an f32', but we should not be forced to specify the order!
This sounds like another indirection to me!
Let's think about how such a data flow could look like for our `Information` object:

1. `input` tells us we have a "name" object, thus we know that we are about to receive a `String`!
2. `input` tells us we have a "value" object, thus we know that we are about to receive a `f32`!
3. `input` tells us we have a "orders" object, thus we know that we are about to receive a `Vec<u32>`!


One thing has become apparent, it is no longer _us_ that dictate what we are about to receive, but the `input` object.
This pattern of an outside object calling specific methods on an object you provide is called the visitor pattern in this instance!

> A small side note. I consider most online resources on the visitor pattern to be more confusing than helpful.
> While I still think that you should try to see if you can find something that clicks for you online, I can try to resume it here in a few sentences:
> The visitor pattern allows you to decouple (i.e. seperate) the form of an object (its structure) and an algorithm operating on it.
> In our concrete situation, the structure is the `Information` struct, and the algorithm is "I have decoded a specific field, how do you want to handle it?"

Let's just call the trait `Visitor` so that there is a common interface. 
It will have methods for all the kinds of 'shape' of data we want to handle and return the object it can collect from any of the calls.

In our case, we just have the ability to receive structs so far.

```rust
trait Visitor {
  type Output;
  fn visit_struct(self, st: SI) -> Output where SI: StructInfo;
}

trait StructInfo {
  fn next_key(&mut self) -> Option<String>;
  fn next_value<T>(&mut self) -> T;
}
```

Let's go over what we just defined. The `Visitor` trait methods will be called by the `input` we receive. Currently we can only visit structs. We also receive a `StructInfo` object where the actual data is encoded. The reason why we have to go through the StructInfo trait is because we don't know how the data looks like! (Remember our first try, and how that did not work at all).

From here, implementing our Deserialize could go something like this:

```rust
impl Deserialize for Information {
  fn deserialize(input: _) -> Result<Self, DeserializeError> {
    struct InformationVisitor;
    
    impl Visitor for InformationVisitor {
      type Output = Information;
      
      fn visit_struct(self, mut st: SI) -> Information 
        where SI: StructInfo {
        let mut orders: Option<Vec<u32>> = None;
        let mut name: Option<String> = None;
        let mut value: Option<f32> = None;

        while let Some(key) = st.next_key() {
          match key {
            "orders" => {
              orders = Some(st.next_value::<Vec<u32>>());
            }
            "name" => {
              name = Some(st.next_value::<String>());
            }
            "value" => {
              value = Some(st.next_value::<f32>());
            }
            key => {
              panic!("Unknown key '{key}'");
            }
          }
        }
        
        Information {
          orders: orders.unwrap(),
          name: name.unwrap(),
          value: value.unwrap(),
        }
      }
    }
    
    input.deserialize(InformationVisitor);
  }
}
```

Phew, that's a lot of typing, but it should be clear what we're doing. 
First we declare the new `InformationVisitor` and have it use the given `StructInfo` to construct an `Information` object. 
As you can see we are also order independent! 
There are still some minor tweaks one can do, like for example check for duplicates, but those are left as an exercise to the reader 😉 !

## Nailing down what `input` is
