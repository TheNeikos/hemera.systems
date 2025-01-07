# Building for other Distributions and Architectures

> [!info]
>
> This page was written on the 11th December 2024, so this might be outdated if
you read it in the future.

NixOS is great! It gets you 99% to a reproducible and
write-once-work-everywhere software chain. Sadly, it is not used everywhere so
from time to time you might find yourself having to build for other
distributions.

Now, for anyone who has ever tried to run executables built for let's say
Debian, will have found that it won't just work. Debian's file structure is way
different to NixOS' and as such the linker will not find the dynamic libraries
it needs. They might not even be available!

Well, anything you build on NixOS has the reverse problem: None of the
'classical' other distributions do it like NixOS.

This means things are just incompatible. On top of that, the versions might be
quite different, so it might be that either distributions uses ABI-incompatible versions.

This has conceptually an easy solution: statically link everything.

But that is boring, not easy, and maybe not something you always want. I'm not
gonna go into pro/cons here. Nor how to statically link stuff.

Instead, I'll explain how I made a pretty cursed setup to solve a problem I was facing.

I was tasked to compile and package software that has to run on Debian
Bookworm, on a 64-bit ARM device. Aka, produce a `deb` file that can be installed there.

The problem was: I am running on a x86-64 NixOS system. So not only do I have
to compile for another distribution, but I also have to _cross-compile_ my
software.

### Prelude

Luckily I had several things going for me:

- The software in question is written in Rust. Rust has a __great__
  cross-compilation story! (Maybe I am saying this because I know other
  systems, but frankly its really not the worst).
- The software only had `openssl` as its more complicated library. `glibc` is
  pmuch always there in this scenario.
- I got it working in a docker container beforehand

The last part is important, as doing the whole iteration on required libraries
etc... would have been extremely tedious in another situation.


### The components

Conceptually nixpkgs gives us these components to realize what we need:

- The ability to specify packages from the debian repository
- The ability to splice them together as a FHS
- Start a container/virtual machine with a given set of debian packages
- Run commands in that container and copy it out again


> ![NOTE]
> TODO: Finish this part!
