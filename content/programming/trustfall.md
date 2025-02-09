# Trustfall, querying anything

I've been looking at trustfall for quite some time already, but its seeming
complexity has always been a roadblocker for me to actually adopt it.

This time I feel like I succeeded, so here's my thoughts on what allowed me to push through.

## GraphQL

Trustfall is not a GraphQL implementation, but it uses the GraphQL language as
a frontend, so as not to re-invent the wheel on everything.

__Understanding GraphQL is vital to being able to employ trustfall__. I cannot
overstate this enough. If you do not understand GraphQL, I do not think you
will understand what trustfall is doing under the hood. If you do, then I think
you just understood how GraphQL 'works semantically'... which you could have
done without reading complicated rust code.

Once you know the concepts of properties, objects and what GraphQL is about,
you can now learn the following extra concepts:

Trustfall uses the following terminology for some of its parts:

- A Vertex is anything that is not a property or an edge
    - This makes sense if you imagine a graph, and consider properties to be edges leading 'nowhere'
- A Property of a vertex is anything that is a 'base value type', aka a String,
  Boolean, Integer or a List of a base value
    - This means that you can't have _objects_ as properties
    - If you still have this feeling, you might not yet have understood what GraphQL is (and go learn that!!!)
    or you're thinking too far ahead, and are looking at it backwards (in which case, do read on)
- An edge is anything that produces new vertices
    - For example a vertex of 'Directory' can have the property "Path", and an
      edge "Children" which returns its direct descendents

## Trustfall Architecture

To work with trustfall as of 0.8, you need the following:

- An `Adapter`
- A `Schema`
- A `query`

### Adapters

Adapters are the bread and butter of trustfall. They take the concept of "What is a Directory?" and break it down into manageable chunks.

The high level idea is that you check which kind of Vertex is currently
'active' (aka the query engine is 'evaluating'), and use the type information
you're given to resolve whatever trustfall needs: Properties or Edges.

There's the concept of 'starting vertices', which is basically an edge _from_
nowhere to a base list of vertices to kickstart the query traversal.

It also asks for 'coercion'. This concept exists here because in GraphQL you have types and interfaces. And all this asks is, "Is the given type a subtype of this other type?".

For example, a `File` is _not_ a `Directory`. But a `Directory` is a `Path`! 

Since trustfall _doesn't know what you're actually doing under the hood, you
have to tell it_. I feel that this is another important part to keep in mind.
There are no shortcuts when it comes to defining and designing your adapter.

### Schemas

Schemas in trustfall are very close to GraphQL. So there's not much else to add here. You did read the GraphQL spec or some tutorials right?
