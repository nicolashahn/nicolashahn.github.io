---
layout:     post
title:      One Program Written in Python, Go, and Rust
date:       2019-04-28
summary:    Image differentiation in three languages
categories: python go rust programming
published:  false
---

<!-- NOTE use textwidth=88 when wrapping -->

![Python, Go, Rust logos](/images/program-in-python-go-rust/python-go-rust.png)

_Disclaimer: This is a primarily subjective developer-ergonomics based comparison of the
three languages from the perspective of a Python developer, but you can [skip to
performance comparison](#performance) if you want something less fluffy._

A few years ago, I was tasked with rewriting an image processing service so we could
host it in AWS Lambda. To tell whether my new service was creating the same output as
the old given an image and one or more transforms (resize to X by Y, make a circular
crop, etc.), I had to inspect the images myself. Clearly I needed to automate this, but
I could find no existing Python library that simply told me how different two images
were on a per-pixel basis.  Hence [diffimg](https://github.com/nicolashahn/diffimg),
which can give you a difference ratio/percentage, or generate a diff image.

The initial implementation was in Python (by far the language I'm most comfortable in),
and all the heavy lifting was done by
[Pillow](https://pillow.readthedocs.io/en/stable/). It's usable as a library or a
command line tool. The actual
[meat](https://github.com/nicolashahn/diffimg/blob/master/diffimg/diff.py) of the
program is very small, only a few dozen lines.  This is due to making use of Pillow's
`ImageChops.difference()` function, which generates the diff image - the ratio
calculation is only a few more lines. All in all, I did very little work to create this
tool ([XKCD](https://xkcd.com/353/) was right, there's a Python module for nearly
everything), but it's been very handy to many people.


A few months ago, I joined a company that had several services written in Go, and I need
to get up to speed quickly on the language. Writing
[diffimg-go](https://github.com/nicolashahn/diffimg-go) seemed like an fun and possibly
even useful way to do this. Here are a few points of interest that came out of the
experience (and also from using it in a professional environment):

## Go and Python

(Again, for comparison:
[diffimg](https://github.com/nicolashahn/diffimg) (python) and
[diffimg-go](https://github.com/nicolashahn/diffimg-go))

- __Standard Library__: Go comes with a decent [image](https://golang.org/pkg/image/)
  standard library module, as well as a command line argument parsing library. I didn't
  feel that I had to look for any external dependencies, and I ended up not needing them
  -- the `diffimg-go` implementation has none, where the Python implementation uses the
  fairly heavy third party module (ironically) named Pillow. I think Go's standard
  library in general is more structured and well thought out, Python's feels as if it
  were organically evolved, created by many authors over years, with many differing
  conventions. The Go standard library's consistency makes it easier to predict how any
  given module will function, and the source is extremely well documented. 
  - One downside of using the standard image library is that it does not automatically
    detect if the image has an alpha channel, pixel values have four channels (RGBA) for
    all image types.  The `diffimg-go` implementation therefore requires the user to
    indicate whether or not they want to use the alpha channel for the calculation/image
    generation. This small inconvenience wasn't worth finding a third party library to
    fix, in my opinion.

- __Static Type System__: Using one was somewhat foreign to me, as almost all
  my programming for the past few years has been in Python. The experience was somewhat
  annoying at first, it felt as though it was simply slowing me down and forcing me to
  be excessively explicit whereas Python would just let me do what I wanted, even if I
  got it wrong occasionally.  Somewhat like giving instructions to someone who always
  stops you to ask you to clarify what you mean, versus someone who always nods along
  and seems to understand you, though you're not always sure they're absorbing
  everything.

- __Verbosity__: Go is much more verbose (though not Java verbose). Part of that is the
  type system, but mainly the fact that the language itself is very small and not
  overloaded with features (you only get [one looping
  construct!](https://tour.golang.org/flowcontrol/1) I missed having list comprehensions
  and other functional programming features), not that Python is. If you're comfortable
  with Python, you can go through the [Tour of Go](https://tour.golang.org/welcome/1) in
  a day or two, and you'll have been exposed to the entirety of the language. How I felt
  at the end of it:

  ![travolta_meme.gif](/images/travolta_meme.gif?style=centered)

- __Interfaces and Structs__: Go uses interfaces and structs where Python would use
  classes (you can simulate interfaces in Python by writing classes that only have
  virtual methods, though I'm not sure if this is useful). This was probably the most
  interesting difference to me, as it forced me to differentiate the concept of a type
  that defines behavior versus a type that holds information.  Python and any other OO
  language would encourage you to mash these together, but there are pros and cons to
  both paradigms:
  - Divorcing implementations for interfaces means you need to write similar code
    several times if you have many types that are similar to each other. This is seems
    to me a "bottom-up" approach to writing abstractions, whereas Python would be
    "top-down". This style is still new to me, so I'm still undecided as to whether this
    is a pattern I like - it does seem to require more code, which I'm initially put off
    by.
  - However, because Go is statically typed, the compiler/linter will tell you when
    you're writing code that would have caused a runtime error in Python when you try to
    access a method or attribute that may not exist. Forcing you to write
    implementations for specific types is a requirement for this. You can be much more
    sure of your Go code when it compiles. There are more chances to make mistakes, but
    more help in catching them. Python linters can get some of this functionality, but
    because of the language's dynamicity, it's not foolproof like Go is.

- __Error Handling__: Python has exceptions, whereas Go propagates errors by returning
  tuples: `value, error` from functions wherever something may go wrong. Python lets
  you catch errors at any point in the call stack as opposed to requiring you to
  manually pass them back up over and over again. This again results in brevity and
  code that isn't littered with `if err != nil`s, though you do need to be aware of
  what possible exceptions can be thrown by a function and all(!) of its internal
  calls (using `except Exception:` is a bad-practice workaround for this). Good
  docstrings and tests can help here, which you should be writing in either language.
  Go's system is definitely safer. You're still allowed to shoot yourself in the foot
  by just ignoring the `err` second tuple value, but it's more obvious that this is a
  bad idea.

- __Optional Arguments__: Go has none, Python makes extensive use of them. A seemingly
  small feature, but found it was something I really missed, mainly for how much
  easier refactoring is if you can just throw a `kwarg` onto whatever function needs
  it without having to rewrite every one of its calls. This made my implementation for
  how to handle whether or not the diff image should be created based on the flags
  somewhat clumsy.

- __Third Party Modules__: Prior to [Go modules](https://blog.golang.org/modules2019),
  Go's package manager would just throw all downloaded packages into `$GOPATH/src`
  instead of the project's directory like every other language. The path for these
  modules inside `$GOPATH` would also be built from the URL, so your import would look
  something like `import "github.com/someuser/somepackage"`. Embedding `github.com`
  inside the source code of almost all Go codebases seems like a strange choice. In any
  case, Go has come around to the conventional way of doing things, but Go modules are
  still new so this quirk will not go away any time soon.

- __Asynchronicity__: Goroutines are a very convenient way to fire off asynchronous
  tasks. Before `async/await`, Python's asynchronous solutions were somewhat hairy.
  Unfortunately I haven't written much asynchronous code and the simplicity of
  `diffimg` didn't seem to lend itself to the added overhead of asynchronicity, so I
  don't have too much to say here, but I thought I'd mention it since it's a very
  important feature for modern programming languages. My understanding is that Go
  still has the upper hand here as goroutines can make use of full multiprocessor
  parallelism, where Python's basic `async/await` is still stuck on one processor, so
  mainly useful for I/O bound tasks.

### Go summary

At a high level, my experience with Go (from both writing `diffimg-go` and my
professional work) is that it's a programming language safer for large codebases than
Python is.  Due to the fact that the language is small and there aren't many ways to
write the same thing, code ends up looking more uniform. Combine this with the static
type system, and it really does make for a language that can comfortably scale to a huge
codebase, and developers coming from a variety of other languages can quickly begin
contributing idiomatic and understandable code. If I had to say what Go would be able to
replace, it'd probably be Java, not Python. It's a language that can gracefully scale to
"enterprise software"-sized codebases, but without the overly object-oriented paradigm
and the boilerplate that comes with it.

However, because its ability to abstract is fairly limited, it's not as _fun_ a language
as Python is. Go actively tries to stop you from being "clever." In Python, there's
several ways to do anything which allows for more "clever" solutions, and it won't
complain if you want to do something that may be ill-advised. Since the language has
more features and is dynamically typed, writing code can be significantly faster.
Because of this, Python is an excellent prototyping language, but it's also been proven
to scale to support enormous applications such as Dropbox (with the help of optional
static typing through [mypy](http://mypy-lang.org/)).  It will almost never be as
performant as Go - though if most of the work in your Python code [is being done by
C](https://docs.python.org/3/extending/building.html), this may not be the case.

## Enter Rust

A few weeks ago, I decided to give an honest go at learning Rust. I had attempted to do
so before but found the type system and borrow checker confusing and without enough
context for why all these constraints were being forced on me, cumbersome for the tasks
I was trying to do. However, since then, I've learned a bit more about what happens with
memory during the execution of a program. I also started with [the
book](https://doc.rust-lang.org/book/) instead of just attempting to dive in headfirst.
This was massively helpful, and probably the best introduction to any programming
language I've ever experienced.

After I had gone through the first dozen or so chapters of the book, I felt confident
enough to try another implementation of `diffimg` (at this point, I had about as much
experience with Rust as I'd had with Go when I wrote `diffimg-go`). It took me a bit
longer to write than the Go implementation, which itself took longer than Python. I
think this would be true even taking into account my greater comfort with Python -
there's just more to write in both languages.

Some of the things that I took notice of when writing
[diffimg-rs](https://github.com/nicolashahn/diffimg-rs):

- __Type System__: I was comfortable with the more basic static type system of Go by
  now, but Rust's is significantly more powerful/complicated. Generic types, enumerated
  types, traits, reference types, lifetimes are all additional concepts that I had to
  learn on top of Go's much simpler interfaces and structs. Additionally, Rust uses its
  type system to implement features that other languages don't use the type system for
  (example: the [Result](https://doc.rust-lang.org/std/result/) type, which I'll talk
  about soon).  Luckily, the compiler/linter is extremely helpful in telling you what
  you're doing wrong, and often even tells you exactly how to fix it. I've spent
  significantly more time than I did learning Go's type system and I'm still not
  comfortable with all the features yet.
  - There was one place where because of the type system, the implementation of the
    imaging library I was using [would have led to an uncomfortable amount of code
    repetition.](https://github.com/nicolashahn/diffimg-rs/blob/e9dd3f0331b3e32d2f62241b4d576d1da3d3cd42/src/lib.rs#L105)
    I only ended up matching the two most important enum types, but matching the others
    would lead another half dozen or so lines of nearly identical code. This rubs me the
    wrong way, and maybe it's a good candidate for using macros.

- __Manual Memory Management__: Python and Go pick up your trash for you. C lets you
  litter everywhere, but throws a fit when it steps on your banana peel. Rust slaps you
  and demands that you clean up after yourself. This stung at first, since I'm spoiled
  and usually have my languages pick up after me, moreso even than moving from a dynamic
  to a statically typed language. Again, the compiler tries to help you as much as is
  possible, but there's still a good amount of studying you'll need to do to understand
  what's really going on.
  - One nice part about having such direct access to the memory (and the functional
    programming features of Rust) is that it simplified the [difference ratio
    calculation](https://github.com/nicolashahn/diffimg-rs/blob/e9dd3f0331b3e32d2f62241b4d576d1da3d3cd42/src/lib.rs#L87)
    because I could simply map over the raw byte arrays instead of having to index each
    pixel by coordinate. A small win but pretty neat.

- __Error Handling__: Instead of the exception model that Python uses or the tuple
  returns that Go uses for error handling, Rust makes use of its enumerated types:
  `Result` returns either `Ok(value)` or `Err(error)`. This is closer to Go's system,
  but is a bit more explicit and leverages the type system.

- __Tooling__: `rustup` and `cargo` are extremely polished implementations of a
  language version manager and package/module manager, respectively. Everything "just
  works." I especially love the autogenerated docs. The Python options for these are
  somewhat organic and finicky, and as I mentioned before, Go has a strange way of
  managing modules.

- __Editor Plugins__: My `.vimrc` is embarrassingly large, with at least three dozen
  plugins. I have some plugins for linting, autocompleting, and formatting both Python
  and Go, but the Rust plugins were easier to set up, more helpful, and more stable
  compared to the other two languages. The
  [rust.vim](https://github.com/rust-lang/rust.vim) and
  [vim-racer](https://github.com/racer-rust/vim-racer) plugins were all I needed to get
  an extremely powerful setup. I haven't tested out other editors with Rust but with the
  excellent editor-agnostic tooling that Rust comes with, I'd expect them to be just as
  helpful. [Racer](https://github.com/racer-rust/racer) provides the best
  go-to-definition I've ever used. It works perfectly on local, standard library, and
  third-party code out of the box.

### Rust summary

I definitely wouldn't recommend attempting to write Rust without at least
going through the first few chapters of the book, even if you're already familiar with C
and memory management. With Go and Python, as long as you have some experience with
another modern imperative programming language, they're not difficult to just start
writing, referring to the docs when necessary.

# TODO finish the rust summary

## [Performance](#performance)

Now for something resembling an objective comparison. I first generated three sets of
random images: 1x1, 2000x2000, and 10000x10000 (fun fact: for the difference ratio
calculation, a `u32` can only hold the sum of the maximum channel values of a square RGB
image with a width/height of 2369px, while a `u64` can do the same with a square image
of size 155284870px). Then I measured each language+image size combination's performance
10 times for each `diffimg` ratio calculation using the averaged values given by the
`time` command (the `real` measurement). `diffimg-rs` was built using `--release`,
`diffimg-go` with just `go build`, and the Python `diffimg` invoked with `python3 -m
diffimg`. The results, on a 2015 Macbook Pro:

| Image size: | 1x1             | 2000x2000          | 10000x10000        |
|-------------|-----------------|--------------------|--------------------|
| Rust        | 0.001s          | 0.490s             | 5.871s             |
| Go          | 0.002s __(2x)__ | 0.756s __(1.54x)__ | 14.060s __(2.39x)__|
| Python      | 0.095s __(95x)__| 1.419s __(2.90x)__ | 28.751s __(4.89x)__|

I'm losing a lot of precision because `time` only goes down to 10ms resolution (slightly
more is shown here because of the averaging). However, we can still learn something from
this data.

With the 1x1 image, virtually all the time is spent in setup, not ratio calculation.
Rust wins, despite me using a fairly full-featured command line argument parsing library
[clap](https://github.com/clap-rs/clap) and Go only using the standard library. I'm not
surprised Python's startup is as slow as it is, since importing a large library (Pillow)
is one of its steps, and even just `time python -c ''` takes 0.030s.

At 2000x2000, the gap narrows for both Go and Python compared to Rust, presumably
because less of the overall time is spent in setup compared to calculation. However,
at 10000x10000, Rust is more performant in comparison, which I would expect is due to
its compiler's optimizations producing the smallest block of machine code that is looped
through 100,000,000 times, combined with never needing to pause for garbage collection.

The Python implementation definitely has room for improvement, because as efficient as
Pillow is, we're still creating a diff image in memory (traversing both input images)
and then adding up each of its pixel's channel values. Effectively, we're looping over
three images instead of two like the Rust and Go implementations, so I would expect a
more direct implemention would cut its run time by roughly a third.

I should also mention the binary sizes: Rust is 2.1mb with the `--release` build, and Go
is comparable at 2.5mb. Python doesn't create binaries. Its source code is only about
3kb, but including the Pillow dependency, everything weighs in at 24mb(!).

# TODO final conclusion
