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

_This is a subjective, primarily developer-ergonomics-based comparison of the
three languages from the perspective of a Python developer, but you can [skip to
performance comparison](#performance) if you want some hard numbers, [the
takeaway](#takeaway) for the tl;dr, or go straight to the
[Python](https://github.com/nicolashahn/diffimg),
[Go](https://github.com/nicolashahn/diffimg-go), and
[Rust](https://github.com/nicolashahn/diffimg-rs) `diffimg` implementations._

A few years ago, I was tasked with rewriting an image processing service so we could
host it in AWS Lambda. To tell whether my new service was creating the same output as
the old given an image and one or more transforms (resize to X by Y, make a circular
crop, etc.), I had to inspect the images myself. Clearly I needed to automate this, but
I could find no existing Python library that simply told me how different two images
were on a per-pixel basis.  Hence [diffimg](https://github.com/nicolashahn/diffimg),
which can give you a difference ratio/percentage, or generate a diff image (check out
the readme to see an example).

The initial implementation was in Python (the language I'm most comfortable in), with
the heavy lifting was done by
[Pillow](https://pillow.readthedocs.io/en/stable/). It's usable as a library or a
command line tool. The actual
[meat](https://github.com/nicolashahn/diffimg/blob/master/diffimg/diff.py) of the
program is very small, only a few dozen lines.  This is due to making use of Pillow's
`ImageChops.difference()` function, which generates the diff image - the ratio
calculation is only a few more lines. Not a lot of effort went into building this tool
([xkcd was right](https://xkcd.com/353/), there's a Python module for nearly
everything), but it's been very handy to many people.

A few months ago, I joined a company that had several services written in Go, and I need
to get up to speed quickly on the language. Writing
[diffimg-go](https://github.com/nicolashahn/diffimg-go) seemed like an fun and possibly
even useful way to do this. Here are a few points of interest that came out of the
experience, along with some that came up while using it at work: 

## Comparing Python and Go

(Again, the code: [diffimg](https://github.com/nicolashahn/diffimg) (python) and
[diffimg-go](https://github.com/nicolashahn/diffimg-go))

- __Standard Library__: Go comes with a decent [image](https://golang.org/pkg/image/)
  standard library module, as well as a command line argument parsing library. I didn't
  feel that I had to look for any external dependencies, and I ended up not needing them
  -- the `diffimg-go` implementation has none, where the Python implementation uses the
  fairly heavy third party module (ironically) named Pillow. I think Go's standard
  library in general is more structured and well thought out, Python's feels as if it
  were organically evolved, created by many authors over years, with many differing
  conventions. The Go standard library's consistency makes it easier to predict how any
  given module will function, and the source code is extremely well documented. 
  - One downside of using the standard image library is that it does not automatically
    detect if the image has an alpha channel, pixel values have four channels (RGBA) for
    all image types.  The `diffimg-go` implementation therefore requires the user to
    indicate whether or not they want to use the alpha channel for the calculation/image
    generation. This small inconvenience wasn't worth finding a third party library to
    fix, in my opinion.
  - One big upside is that there's enough in the standard library that you don't need a
    web framework like Django. You can build out a real, usable API without any
    dependencies. Python's claim in the past has been that it's batteries-included, but
    Go does it better, in my opinion.

- __Static Type System__: I've used typed languages in the past, but my programming for
  the past few years has mostly been in Python. The experience was somewhat annoying at
  first, it felt as though it was simply slowing me down and forcing me to be
  excessively explicit whereas Python would just let me do what I wanted, even if I got
  it wrong occasionally.  Somewhat like giving instructions to someone who always stops
  you to ask you to clarify what you mean, versus someone who always nods along and
  seems to understand you, though you're not always sure they're absorbing everything.
  It will decrease the amount of a certain class of bugs for free, but I've found that I
  still need to spend nearly the same amount of time writing tests.
  - One of the common complaints of Go is that it does not have user-implementable
    generic types. While this is not a must-have feature for building a large,
    extensible application, it certainly slows development speed.
    [Alternative patterns](https://appliedgo.net/generics/) have been suggested, but
    none of them are as effective as having real generic types.

- __Verbosity__: Go is much more verbose (though not Java verbose). Part of that is
  because type system does not have generics, but mainly the fact that the language
  itself is very small and not overloaded with features (you only get [one looping
  construct!](https://tour.golang.org/flowcontrol/1) I missed having list comprehensions
  and other functional programming features), not that Python is. If you're comfortable
  with Python, you can go through the [Tour of Go](https://tour.golang.org/welcome/1) in
  a day or two, and you'll have been exposed to the entirety of the language. How I felt
  at the end of it:

  ![travolta_meme.gif](/images/travolta_meme.gif?style=centered)

- __Interfaces and Structs__: Go uses interfaces and structs where Python would use
  classes. This was probably the most interesting difference to me, as it forced me to
  differentiate the concept of a type that defines behavior versus a type that holds
  information.  Python and other "classically object-oriented" languages would encourage
  you to mash these together, but there are pros and cons to both paradigms:
  - Go heavily encourages [composition over
    inheritance](https://en.wikipedia.org/wiki/Composition_over_inheritance). While it
    has [inheritance via embedding](https://golang.org/doc/effective_go.html#embedding),
    without classes, it's not easy to forward both data and methods. I generally agree
    that composition is the better default pattern to reach for, but I'm not an
    absolutist and some solutions are a better fit for inheritance, so I'd prefer not to
    have the language make this decision for me. I assume once you're more comfortable
    with the pattern, it's not an issue anymore, and coming up with composition-only
    code is second nature.
  - Divorcing implementations for interfaces means you need to write similar code
    several times if you have many types that are similar to each other. Because of the
    lack of generic types, there are situations in Go where I wouldn't be able to reuse
    code, though I would in Python.
  - However, because Go is statically typed, the compiler/linter will tell you when
    you're writing code that would have caused a runtime error in Python when you try to
    access a method or attribute that may not exist. Python linters can get a bit of
    this functionality, but because of the language's dynamicity, the linter can't know
    exactly what methods/attributes will exist until runtime. Statically defined
    interfaces and structs are the only way to know what's available at compile time and
    during development, making Go that compiles more trustworthy than Python that runs. 

- __Error Handling__: Python has exceptions, whereas Go propagates errors by returning
  tuples: `value, error` from functions wherever something may go wrong. Python lets
  you catch errors at any point in the call stack as opposed to requiring you to
  manually pass them back up over and over again. This again results in brevity and
  code that isn't littered with Go's infamous `if err != nil` pattern, though you do
  need to be aware of what possible exceptions can be thrown by a function and all(!) of
  its internal calls (using `except Exception:` is a bad-practice workaround for this).
  Good docstrings and tests can help here, which you should be writing in either
  language.  Go's system is definitely safer. You're still allowed to shoot yourself in
  the foot by just ignoring the `err` second tuple value, but it's more obvious that
  this is a bad idea.

- __Optional Arguments__: Go only has [variadic
  functions](https://gobyexample.com/variadic-functions) which are similar to Python's
  keyword arguments, but less useful, since the arguments need to be of the same type. I
  found keyword arguments to be something I really missed, mainly for how much easier
  refactoring is if you can just throw a `kwarg` of any type onto whatever function
  needs it without having to rewrite every one of its calls. This made my implementation
  for how to handle whether or not the diff image should be created based on the command
  line flags somewhat clumsy.

- __Third Party Modules__: Prior to [Go modules](https://blog.golang.org/modules2019),
  Go's package manager would just throw all downloaded packages into `$GOPATH/src`
  instead of the project's directory (like most other languages). The path for these
  modules inside `$GOPATH` would also be built from the URL where the package is hosted,
  so your import would look something like `import "github.com/someuser/somepackage"`.
  Embedding `github.com` inside the source code of almost all Go codebases seems like a
  strange choice. In any case, Go now allows the conventional way of doing things, but
  Go modules are still new so this quirk will not disappear from Go source code any time
  soon.

- __Asynchronicity__: Goroutines are a very convenient way to fire off asynchronous
  tasks. Before `async/await`, Python's asynchronous solutions were somewhat hairy.
  Unfortunately I haven't written much real-world async code and the simplicity of
  `diffimg` didn't seem to lend itself to the added overhead of asynchronicity, so I
  don't have too much to say here, though I do like Go's
  [channels](https://gobyexample.com/channels) as a way to handle multiple async tasks.
  My understanding is that for performance, Go still has the upper hand here as
  goroutines can make use of full multiprocessor parallelism, where Python's basic
  `async/await` is still stuck on one processor, so mainly useful for I/O bound tasks.

- __Debugging__: Python wins. `pdb` (and more sophisticated options like
  [ipdb](https://pypi.org/project/ipdb/) are available) is extremely flexible, once
  you've entered the REPL, you're able to write whatever code you want.
  [Delve](https://github.com/go-delve/delve) is a good debugger, but it's not the same
  as dropping straight into an interpreter.

### Go summary

At a high level, my experience with Go (from both writing `diffimg-go` and my
professional work) is that it's a programming language safer for large codebases than
Python is.  Due to the fact that the language is small and there aren't many ways to
write the same thing, code ends up looking more uniform. Combine this with the static
type system, and it really does make for a language that can comfortably scale to a huge
codebase, and developers coming from a variety of other languages can quickly begin
contributing idiomatic and understandable code. If I had to say what Go would be
a replacement for, it'd probably be Java, not Python. It's a statically-typed language
that can gracefully scale to "enterprise software"-sized codebases, but without the
overly object-oriented paradigm and the boilerplate that comes with it.

However, because its ability to abstract is fairly limited, it's not as _fun_ a language
as Python is. Go actively tries to stop you from being "clever." I might even go as far
as saying that Go's strength is that it's boring. In Python, there's several ways to do
anything which allows for more "clever" solutions, and it won't complain if you want to
do something that may be ill-advised. Since the language has more features and is
dynamically typed, writing code can be significantly faster.  Because of this, Python is
an excellent prototyping language, but it's also been proven to scale to support
enormous applications such as Dropbox (with the help of optional static typing through
[mypy](http://mypy-lang.org/)) and Youtube.  It will almost never be as performant as
Go, though if most of the work in your Python code [is being done by
C](https://docs.python.org/3/extending/building.html), things get more complicated.

While I can definitely recommend Go for build a large, scalable, robust system with many
developers from many backgrounds, I have little desire to use it for my personal
projects.  It doesn't spark joy for me the way Python does.

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
  now, but Rust's is significantly more powerful and complicated. Generic types,
  enumerated types, traits, reference types, lifetimes are all additional concepts that
  I had to learn on top of Go's much simpler interfaces and structs. Additionally, Rust
  uses its type system to implement features that other languages don't use the type
  system for (example: the [Result](https://doc.rust-lang.org/std/result/) type, which
  I'll talk about soon).  Luckily, the compiler/linter is extremely helpful in telling
  you what you're doing wrong, and often even tells you exactly how to fix it. I've
  spent significantly more time than I did learning Go's type system and I'm still not
  comfortable with all the features yet.
  - There was one place where because of the type system, the implementation of the
    imaging library I was using [would have led to an uncomfortable amount of code
    repetition.](https://github.com/nicolashahn/diffimg-rs/blob/e9dd3f0331b3e32d2f62241b4d576d1da3d3cd42/src/lib.rs#L105)
    I only ended up matching the two most important enum types, but matching the others
    would lead another half dozen or so lines of nearly identical code. This rubs me the
    wrong way, and maybe it's a good candidate for using macros, which I still need to
    experiment with.

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

- __Functional Features__: Rust strongly encourages a functional approach: it has a
  FP-friendly type system like Haskell, immutable types, closures, iterators, pattern
  matching, and more, but also allows imperative code. It's similar to writing OCaml
  (interestingly, the original Rust compiler [was written in
  OCaml](https://github.com/rust-lang/rust/tree/ef75860a0a72f79f97216f8aaa5b388d98da6480/src/boot)).
  Because of this, code is more concise than you'd expect for a language that competes
  with C (my Rust `diffimg` implementation is actually [a bit
  shorter](https://github.com/nicolashahn/diffimg-rs/blob/master/src/lib.rs) than [the
  Go
  version](https://github.com/nicolashahn/diffimg-go/blob/master/pkg/diffimg/diffimg.go)).

- __Error Handling__: Instead of the exception model that Python uses or the tuple
  returns that Go uses for error handling, Rust makes use of its enumerated types:
  `Result` returns either `Ok(value)` or `Err(error)`. This is closer to Go's way if you
  squint, but is a bit more explicit and leverages the type system.

- __Asynchronicity__: Async/await hasn't quite landed for Rust yet, but the final syntax
  has [just been agreed
  upon](https://boats.gitlab.io/blog/post/await-decision-ii/). Rust also has some basic
  threading features in the standard library that seem a bit easier to use than
  Python's, but I haven't spent much time with it. Go still seems to have the best
  offerings here.

- __Tooling__: `rustup` and `cargo` are extremely polished implementations of a
  language version manager and package/module manager, respectively. Everything "just
  works." I especially love the autogenerated docs. The Python options for these are
  somewhat organic and finicky, and as I mentioned before, Go has a strange way of
  managing modules, though aside from that, its tooling is in a much better state than
  Python's.

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

- __Debugging__: I haven't tried out a debugger with Rust yet (since the type system and
  `println!` take you pretty far), but you can use `rust-gdb` and `rust-lldb`, wrappers
  around the `gdb` and `lldb` debuggers that are installed with the initial `rustup`.
  The experience should be predictable if you've used those debuggers before with C.

### Rust summary

I definitely wouldn't recommend attempting to write Rust without at least
going through the first few chapters of the book, even if you're already familiar with C
and memory management. With Go and Python, as long as you have some experience with
another modern imperative programming language, they're not difficult to just start
writing, referring to the docs when necessary. Rust is a large language.  Python also
has a lot of features, but they're mostly opt-in. You can get a lot done just by
understanding a few primitive data structures and some builtin functions. With Rust, you
really need to understand the complexity inherent to the type system and borrow checker,
or you're going to be getting tangled up a lot.

As far as how I feel when I write the language, it's a lot of fun, like Python. It's
very expressive and while the compiler stops you a lot, it's also very helpful, and its
suggestions on how to solve your borrowing/typing problems usually work. The tooling as
I've mentioned is the best I've encountered for any language and doesn't bring me a lot
of headaches like some other languages I've used. I really like using the language and
will continue to look for opportunities to do so, where the performance of Python isn't
good enough.

## [Performance](#performance)

Now for something resembling an objective comparison. I first generated three random
images of different sizes: 1x1, 2000x2000, and 10,000x10,000. Then I measured each
(language, image size) combination's performance 10 times for each `diffimg` ratio
calculation and averaged them, using the values given by the `real` values from the
`time` command. `diffimg-rs` was built using `--release`, `diffimg-go` with just `go
build`, and the Python `diffimg` invoked with `python3 -m diffimg`. The results, on a
2015 Macbook Pro:

| Image size: | 1x1             | 2000x2000          | 10,000x10,000        |
|-------------|-----------------|--------------------|--------------------|
| Rust        | 0.001s          | 0.490s             | 5.871s             |
| Go          | 0.002s __(2x)__ | 0.756s __(1.54x)__ | 14.060s __(2.39x)__|
| Python      | 0.095s __(95x)__| 1.419s __(2.90x)__ | 28.751s __(4.89x)__|

I'm losing a lot of precision because `time` only goes down to 10ms resolution (one more
digit is shown here because of the averaging). The task only requires a very specific
type of calculation as well, so a different or more complex one could have very
different numbers.  Despite these caveats, we can still learn something from the data.

With the 1x1 image, virtually all the time is spent in setup, not ratio calculation.
Rust wins, despite using two third-party libraries
([clap](https://github.com/clap-rs/clap) and [image](https://github.com/image-rs/image))
and Go only using the standard library. I'm not surprised Python's startup is as slow as
it is, since importing a large library (Pillow) is one of its steps, and even just `time
python -c ''` takes 0.030s.

At 2000x2000, the gap narrows for both Go and Python compared to Rust, presumably
because less of the overall time is spent in setup compared to calculation. However,
at 10,000x10,000, Rust is more performant in comparison, which I would guess is due to
its compiler's optimizations producing the smallest block of machine code that is looped
through 100,000,000 times, never needing to pause for garbage collection.

The Python implementation definitely has room for improvement, because as efficient as
Pillow is, we're still creating a diff image in memory (traversing both input images)
and then adding up each of its pixel's channel values. Effectively, we're looping over
three images instead of two like the Rust and Go implementations, so I would expect a
similar but more direct approach would cut its run time by roughly a third. However, a
pure Python implementation would be wildly slower, since Pillow does its main work in C.
Because the other two are pure language implementations, this isn't really a fair
comparison, though in some ways it is, because Python has an absurd amount of libraries
available to you that are performant thanks to C extensions.

I should also mention the binary sizes: Rust's is 2.1mb with the `--release` build, and
Go's is comparable at 2.5mb. Python doesn't create binaries, but `.pyc` files are
somewhat comparable, and `diffimg`'s `.pyc` files are about 3kb in total. Its source
code is also only about 3kb, but including the Pillow dependency, it weighs in at
24mb(!). Again, not a fair comparison because I'm using a third party imaging library,
but it should be mentioned.

## [The takeaway](#takeaway)

Obviously, these are three very different languages fulfilling different niches. I've
heard Go and Rust often mentioned together, but I think Go and Python are the two more
similar/competing languages. They're both good for writing server-side application logic
(what I spend most of my time doing at work). Comparing just native code performance, Go
blows Python away, but many of Python's libraries that require speed are wrappers around
fast C implementations - in practice, it's more complicated than a naive comparison.
Writing a C extension for Python doesn't really count as Python anymore, but the option
is open to you.

For your backend server needs, Python has proven itself to be "fast enough" for
most applications, though if you need more performance, Go has it. Rust even more so,
but I think you pay for it with development time. Go is not far off from Python in this
regard, though it certainly is slower to develop, primarily due to its small feature
set. Rust is very fully featured, but managing memory will always take more time than
having the language do it, and I think this outweighs having to deal with Go's
minimality.

It should also be mentioned that there are many, many Python developers in the world,
some with literally decades of experience. It will likely never be hard to find more
people with language experience to add to your backend team if you choose Python.
However, Go developers are not particularly rare, and can easily be created because the
language is so easy to learn.  Rust developers are both rarer and harder to make since
the language takes longer to internalize.

With respect to the type systems: static type systems make it easier to write more
correct code, but it's not a panacea.  You still need to write comprehensive tests no
matter the language you use.  It requires a bit more discipline, but I've found that the
code I write in Python is not necessarily more error prone than Go as long as I'm able
to write a good suite of tests. That said, I much prefer Rust's type system to Go's, for
two reasons: it supports generics, and it leverages the type system for error handling
and other language features.

In the end, this comparison is a bit silly, because though the use cases of these
languages overlap, they occupy very different niches. Python is high on the
development-speed, low on the performance scale, while Rust is the opposite, and Go is
in the middle, though I enjoy writing Python and Rust more than Go ([this may be
unsurprising](https://insights.stackoverflow.com/survey/2019#technology-_-most-loved-dreaded-and-wanted-languages)).
I'll continue to use Go at work happily (along with Python) since it really is a great
language for building stable and maintainable applications with many contributors from
many backgrounds. If I had to choose the language for the backend of a new web
application, it would be Go.

I'm pretty satisfied with the range of programming tasks that are covered by these three
languages - there's virtually no project that one of them wouldn't be a great choice
for.
