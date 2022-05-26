# Being Dynamic in a Static Language

[[rust]] is a statically compiled language. 
As such it excels, and is geared towards, static program structures.
This means that some restrictions apply:

- Every type needs to have a known size or, if its a trait, it needs to be
  behind a `dyn T` reference
- Traits need to be [object
  safe](https://doc.rust-lang.org/reference/items/traits.html#object-safety) to
  qualify being allowed in a `dyn T` reference

During my work the following requirements came up:

1. Have a known list of possible components
2. Be able to instantiate any number and combination of these components
3. Establish _typed_ connections between the instances of the components

In this case, the idea is be to have a precompiled binary that is
'batteries-included' in which the user can then activate a number of instances
of its components and wire-up a data flow between them. After several months of
trying out different systems and continously refining our ideas we've found a
nice pattern that I want to document here.

**Note**: This is not a tutorial, and more of a guided explanation. __Rust
knowledge is required!__

---

## Laying the groundwork

Let's assume the components we care about are called 'Plugin's. So we will need a trait for that:

```rust
trait Plugin {
    async fn starting(&mut self) -> Result<()> {
        Ok(())
    }
    async fn run(&self) -> Result<()>;
    async fn stopping(&mut self) -> Result<()> {
        Ok(())
    }
}
```
(I'm using async fns in traits, if that's not yet available feel free to use [`async-trait`](https://docs.rs/async-trait) to work around it.)

The `Plugin` trait will be the heart piece of this whole endeavour. It can be used as such for example:

```rust

struct WatchFolder {
    path: PathBuf,
}

impl Plugin for WatchFolder {
    async fn run(&self) -> Result<()> {
        while let Ok(event) = watch_folder(self.path).await {
            info!(?event, "Received folder event");
        }
    }
}
```

> What is that `watch_folder` function and the `info!` macro? And why are you
> not specifiying the Error in those `Results`?

Good that you mention those Neikos, they are just placeholders, so that anyone
reading this doesn't have to think in 'foos' or 'bars' and instead can just
focus on the heart of the issue. Whereas for the error type, its not important
and readers are expected to fill that in. It's not meant to be copy-pasted!


> Won't it just confuse them even more?

Maybe? But who knows, I prefer writing semi-realistic code. Moving on...



Now that we've seen how the `Plugin` object is meant to be seen, let's use it!

```rust
async fn main() -> Result<()> {
    let mut watcher = WatchFolder { path: PathBuf::from("./src") };

    watcher.starting().await?;
    watcher.run().await?;
    watcher.stopping().await?;
}
```

Great! That's easy and fairly straightforward. Now comes the first hurdle. We
want to spawn several of them. How could we do this?

Well, we're programmers, and if we have several, we'll just loop!

```rust
async fn main() -> Result<()> {
    let paths = ["./src", "/etc/hosts"];

    let watchers = paths.iter()
        .map(|p| WatchFolder { path: p.into() })
        .collect::<Vec<_>>();

    for watcher in watchers {
        watcher.starting().await?;
    }

    let done_watchers = watchers
        .into_iter()
        .map(|watcher| async move {
            watcher.run().await; 
            watcher 
        })
        .collect::<FuturesUnordered>()
        .collect::<Result<Vec<_>>>().await?;

    for watcher in watchers {
        watcher.stopping().await?;
    }
}
```

> Whew that got more complicated!

Yeah, well we're doing async stuff! But don't worry, it's all fairly straightforward:

- First we get a list of paths (Could just as well be from user input, or a config file, etc...)
- We then `.iter`ate over that list and construct some `WatchFolder` instances, and put everything into a `Vec`
- We then start each of them one after the other
- Then, I create a future, _but don't await it yet_, which I then collect into a `FuturesUnordered` through the `Extend` trait.
- Since `FuturesUnordered` is a `Stream` I can then collect from that and make
  it a `Result<Vec<_>>`, pass on any errors and get back the watchers!
    - They had to be moved into the future, since we don't want to have borrows in our `Future`s (its generally a headache)


## Stepping up the difficulty

What if we now have multiple _kinds_ of plugins? Let's define a new one!

```rust
struct SimpleWebserver {
    port: u16,
    directory: PathBuf,
    server_handle: Option<ServerHandle>,
}

impl SimpleWebserver {
    pub fn new(port: u16, directory: PathBuf) -> Self {
        SimpleWebserver {
            port, 
            directory, 
            server_handle: None,
        }
    }
}

impl Plugin for SimpleWebserver {
    async fn starting(&mut self) -> Result<()> {
        self.server_handle = Some(webserver::start(self.port, &self.directory).await?);

        Ok(())
    }
}
```

> What does the webserver do?

That's just a detail, it could do whatever you want! It's just Rust code after all.

Now, let's try to instantiate both a `WatchFolder` and a `SimpleWebserver`!

```rust
async fn main() -> Result<()> {
    let plugins = vec![WatchFolder { path: PathBuf::from("./src") }, SimpleWebserver::new(3456, PathBuf::from(".")];

    // .. call starting, run, and stopping
}
```

> Oh-oh! That doesn't compile! They are not of the same type.

Yup, and now we're leaving the static world and making our first steps into the dynamic world.

#### Trait Objects to the rescue

All the way at the top, we've defined our `Plugin` trait. It's a fairly simple
trait, and thus allows us to pack it behind a fat pointer and 'erase' the
concrete type, keeping only the information conveyed by the `Plugin` trait.
This is then called a 'Trait object'. If you want to read more, check the [rust
reference](https://doc.rust-lang.org/reference/types/trait-object.html) on it!

> What's a fat pointer?

A fat pointer is a pointer with some associated metadata. In this case it would
be a table of methods that correspond to the methods in the `Plugin` trait.

The concept of the so-called 'call table' is represented through `dyn Plugin`.
_Everytime you see a `dyn`, you should think "Ah! It could be anything, so I
can only do generic stuff to it"_

Now, the issue is that `dyn Plugin` is just 'something' represented as a table
of methods, so how big is it? We can't know! So Rust prevents us to use it
'as-is' and requires us to put it behind some form of pointer. There's a few we
can pick from:

- `&dyn Plugin`
- `Box<dyn Plugin>`
- `Rc<dyn Plugin>`
- `Arc<dyn Plugin>`

And surely more that I've missed, they all have different properties, but since
we want to 'own' the resulting `Plugin`s we will use `Box<dyn Plugin>`.


## Stepping up the difficulty (contd.)

TODO:

- Explain how to use `Vec<Box<dyn Plugin>>`
- Explain how a second trait is needed to construct it based on a given config
- Explain how communication can be done
- Explain how this communication can be typed by using `Box<dyn Any>`

