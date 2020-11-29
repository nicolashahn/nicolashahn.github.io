---
layout:     post
title:      Why doesn't Rust's BTreeMap have a with_capacity() method?
date:       2020-11-30
summary:    ...and HashMap does?
categories: 
published: true
---

*Disclaimer: I discovered a previous explanation
[here](https://users.rust-lang.org/t/btreemap-with-capacity/39770/3){:target="_blank"}
but I found it a little confusing, so I'm hoping mine is easier to follow.*

Rust's `HashMap` (and `HashSet` and `Vec`) collections both offer an initialization
method `fn with_capacity(capacity: usize)` that allocates enough memory up front to hold
`capacity` elements. Why don't `BTreeMap` (and `BTreeSet`) also have this method? 

The answer lies in the difference between how the two structs are laid out in memory.
In short, `HashMap`, like `Vec`, uses an array (a contiguous block of memory), which is
required to get O(1) insertion and lookup by element index. In `Vec`, this is done
explicitly, but in `HashMap`, the key is hashed and then translated to the index where
the value resides in the array.

Let's take a `HashMap` with room for four entries (I'm going to omit real-world
implementation details like bucketing in the case of collisions, for the sake of
simplicity). It's in essence a four element array. Here's a representation of the memory
for a `HashMap` with three entries (let's say a byte each) and room for one more (light
green is a filled byte of memory and dark is empty, though reserved for the struct).

![4 element hashmap](/images/btreemap/1.png?style=centered)

Say we insert two more elements. Now we'll need to allocate more memory in order to hold
the fifth. Usual implementations double the size of the array (so we don't need to
allocate for every single insertion). Under ideal conditions, we can just take the next
four bytes of memory.

![8 element hashmap](/images/btreemap/2.png?style=centered)

*(In actuality, the elements are unlikely to be filled contiguously like this, since the
hasher will output an array index with roughly even random distribution)*

However, what if some other struct has been allocated some of those next four bytes?

![4 element hashmap blocked from extending](/images/btreemap/3.png?style=centered)

In this case, we need to move the entire `HashMap` to a place in memory where there's
room for eight entries. Instead of allocating just four more bytes, we need to first
deallocate four bytes and then allocate eight, which is much more expensive.

![8 element hashmap reallocated elsewhere](/images/btreemap/4.png?style=centered)

This is where `with_capacity()` comes in. If we know we're going to eventually have at
least five elements, it makes sense to allocate all eight bytes up front so we don't
need to deallocate and reallocate, which is exactly what `with_capacity()` does.

So why doesn't `BTreeMap` have this method? [Take a look at how a BTree
works.](http://cglab.ca/~abeinges/blah/rust-btree-case/#what's-a-b-tree?-why's-a-b-tree?){:target="_blank"}
For this example, I'm going to simplify it into a regular binary search tree. The
difference between the two is essentially that a BST has a single value and two pointers
per node, but a BTree has an array of values and an array of pointers:

![BTree example](https://upload.wikimedia.org/wikipedia/commons/6/65/B-tree.svg)
For the purposes of this explanation, they're more or less equivalent.

Each node in the BST consists of a value and pointers to its left and right children.
Here's a `BTreeMap` with a single node and value (light blue). The second and third dark
blue bytes are reserved for pointers to its children, which are empty at present.

![BTreeMap with one node](/images/btreemap/5.png?style=centered)

When an element is inserted, a new node is created and memory for it is allocated. Since
pointers can point to any memory address, there's no need to require the nodes to be in
sequential bytes of memory as with `HashMap`. Here's what it might look like if we were
to insert a new entry:

![BTreeMap with two elements](/images/btreemap/6.png?style=centered)

We can put it anywhere we have at least three bytes of memory free. Nodes of a
`BTreeMap` can be spread out over the program's memory, since we're free of the
constraint of having to keep the entries contiguously. This means that we will never
have to deallocate and reallocate old entries, so we don't get to save any cycles (over
the program's entire runtime) by allocating extra memory at `BTreeMap`'s initialization.

Maybe `BTreeMap::with_capacity()` would make sense if you'd explicitly like to pay for
the allocation ahead of time in order to save time during insertion, if latency is more
costly at that point, but I suppose this use case may be a bit too specific for a
standard library function. There's a delicate balance between usefulness and bloat.

