---
date: "2022-06-07T10:39:36+02:00"
---

# My Thoughts on NixOS

I really enjoy [[nixos|NixOS]], and have been using it for about two years now.
However there's one thing that has really started to annoy me lately: You
cannot easily do partial updates due to how nixpkgs is built.

What I mean by this is, that I want to update only a single piece of software
from version 1.2 to 1.3. So I update my nixpkgs input to my flake and rebuild
that. However, now _every other package_ that is also part of that nixpkgs
input gets rebuild/downloaded. This is not what I intended to do, and there is
no clear way of being more precise when it comes to versioning without defining
_every single package_ as a different input.

-----


When I first heard of NixOS I had a quite different idea of what it actually
is. Instead of being a large repository of packages, I thought that it was a
large repository of different build instructions, and one can easily specify
each version one needs. For example, I wanted to be able to somehow say: "I
want firefox at version 72 as well as NodeJS version 8.2". But what you
actually specify is the revision of the whole package tree and pluck things
from there.

Hopefully with flakes this becomes easier to manage. However, downloading N
revisions of nixpkgs (each about 30MB) does not sound like a great time
either...
