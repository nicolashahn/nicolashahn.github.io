---
layout:     post
title:      One Program Written in Python, Go, and Rust
date:       2019-04-28
summary:    Image differentiation in three languages
categories: python go rust programming
published:  false
---

![python, go, rust logos](/images/program-in-python-go-rust/python-go-rust.png)

_Disclaimer: This is a very unscientific comparison, more of a rambling recount
of an intermediate-level Python native rewriting a program as a way to learn
two compiled, statically typed languages and a high level comparison of the
three from a primarily ergonomics-based perspective._

A few years ago, I was tasked with rewriting an image processing service so we could
host it in AWS Lambda. To tell whether my new service was creating the same output as
the old given an image and one or more transforms (resize to X by Y, make a circular
crop, etc), I had to inspect the images myself. Clearly I needed to automate this, but I
could find no existing Python library that simply told me how different two images were
on a per-pixel basis.  Hence [diffimg](https://github.com/nicolashahn/diffimg), which
can give you a difference ratio/percentage, or generate a diff image.

The initial implementation was in Python (by far the language I'm most comfortable in),
and all the heavy lifting was done by
[Pillow](https://pillow.readthedocs.io/en/stable/). It's usable as a library or a
command line tool. The actual
[meat](https://github.com/nicolashahn/diffimg/blob/master/diffimg/diff.py) of the
program is very small, only a few dozen lines.  This is due to making use of Pillow's
`ImageChops.difference()` function, which generates the diff image - the calculation is
only a few more lines. All in all, I did very little work to create this tool
([XKCD](https://xkcd.com/353/) was right, there's a Python module for nearly
everything), but it's been very handy to many people.


A few months ago, I joined a company that had several services written in Go, and I need
to get up to speed quickly on the language. Writing
[diffimg-go](https://github.com/nicolashahn/diffimg-go) seemed like an fun and possibly
even useful way to do this. Here are a few points of interest that came out of the
experience (and also from using it in a professional environment):

### Go and Python

(Again, for comparison:
[diffimg (python)](https://github.com/nicolashahn/diffimg) and
[diffimg-go](https://github.com/nicolashahn/diffimg-go))

- __Standard Library__: Go comes with a decent `image` standard library module,
  as well as a command line argument parsing library. I didn't feel that I had
  to look for any external dependencies, and I ended up not needing them - the
  `diffimg-go` implementation has none, where the Python implementation uses
  the fairly heavy third party module (ironically) named Pillow. I think Go's
  standard library in general is more structured and well thought out, Python's
  feels as if it were organically evolved, created by many authors over years,
  with many differing conventions. It's easier to predict how a Go standard
  library module will function.
- __Static Type System__: Using one was somewhat foreign to me, as almost all
  my programming for the past few years has been in Python. The experience was
  somewhat annoying at first, it felt as though it was simply slowing me down
  and forcing me to be excessively explicit whereas Python would just let me do
  what I wanted, even if I got it wrong occasionally.  Somewhat like giving
  instructions to someone who always stops you to ask you to clarify what you
  mean, versus someone who always nods along and seems to understand you,
  though you're not always sure they're absorbing everything.
- __Verbosity__: Go is much more verbose (though not Java verbose). Part of
  that is the type system, but mainly the fact that the language itself is very
  small and not overloaded with features (you only get [one looping
  construct!](https://tour.golang.org/flowcontrol/1) I missed having list
  comprehensions and other FP features), not that Python is. You can go through
  the [Tour of Go](https://tour.golang.org/welcome/1) in a day or two, and
  you'll have been exposed to the entirety of the language. How I felt at the
  end of it:
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
    "top-down". Because Go has no generic typing, this is a point for Python; in
    general, I believe less code is usually better - there are fewer chances to make
    mistakes.
  - However, because Go is statically typed, the compiler (and your IDE's linter) will
    tell you when you're writing code that would have caused a runtime error in Python
    when you try to access a method or attribute that may not exist. Forcing you to
    write implementations for specific types is a requirement for this. You can be much
    more sure of your Go code when it compiles. There are more chances to make mistakes,
    but more help in catching them. Python linters can get some of this
    functionality, but because of the language's dynamicity, it's not foolproof
    like Go is.
- __Error Handling__: Python has exceptions, whereas Go propagates errors by returning
    tuples: `value, error` from functions wherever something may go wrong. I personally
    prefer Python's exceptions, because it lets you catch errors at any point in the
    call stack as opposed to manually forcing you to pass them back up over and over
    again. This again results in brevity and code that isn't littered with `if
    err != nil`s, though you do need to be aware of what possible exceptions
    can be thrown by a function and all(!) of its internal calls (using `except
    Exception:` is a bad-practice workaround for this). Good docstrings and
    tests can help a lot here, which you should be writing in either language.
- __Optional Arguments__: Go has none, Python makes extensive use of them. A seemingly
    small feature, but found it was something I really missed, mainly for how much
    easier refactoring is if you can just throw a `kwarg` onto whatever function needs
    it without having to rewrite every one of its calls. This made my
    implementation for how to handle whether or not the diff image should be
    created somewhat clumsy.
- __Asynchronicity__: Goroutines are a very convenient way to fire off asynchronous
    tasks. Before `async/await`, Python's asynchronous solutions were somewhat hairy.
    Unfortunately I haven't written much asynchronous code and the simplicity of
    `diffimg` didn't seem to lend itself to the added overhead of asynchronicity, so I
    don't have too much to say here, but I thought I'd mention it since it's a very
    important feature for modern programming languages. My understanding is that Go
    still has the upper hand here as goroutines can make use of full multiprocessor
    parallelism, where Python's basic `async/await` is still stuck on one processor, so
    mainly useful for I/O bound tasks.

At a high level, my experience with Go (from both writing `diffimg-go` and my
professional work) is that it's a more "serious business" programming language
than Python is. Due to the fact that the language is small and there aren't
many ways to write the same thing, code ends up looking more uniform throughout
a codebase. Combine this with the static type system, and it really does make
for a language that can comfortably scale to a huge codebase, and developers
coming from a variety of other languages can quickly begin contributing
idiomatic and understandable code. If I had to say what Go would be able to
replace, it'd probably be Java, not Python. It's a language that can scale to
"enterprise software"-sized codebases, but without a lot of the boilerplate (or
features) Java has.

However, because its ability to abstract is fairly limited, it's not as _fun_ a
language as Python is. In Python, there's several ways to do anything which
allows for more "clever" solutions, and it won't complain if you want to do
something that may be ill advised. Since the language has more features and is
dynamically typed, writing code can be somewhat faster. Because of this, Python
may be the ultimate prototype language, but it's also been proven to scale to
support enormous applications such as Dropbox, though it can never reach the
performance of Go.
