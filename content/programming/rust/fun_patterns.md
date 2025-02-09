# Fun Rust Patterns

This is a collection of Rust patterns I use when I need them.

If you have any questions feel free to reach out, and mention this website :D

## Circumventing `dyn` Safety

Well, we're not really circumventing it, but rather working around it.

The basic idea is as follows:

- You have a trait `DoStuff` that is not `dyn` safe.
- You have a type is that fully parameterized, aka no type holes!
    - This means that to call the methods you're interested in, you know their types in advance
    - This _can_ also be relaxed, but makes it more complicated and left as an exercise to the reader :)


Example trait we'll be looking at:
