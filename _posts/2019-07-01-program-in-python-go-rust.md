---
layout:     post
title:      One Program Written in Python, Go, and Rust
date:       2019-07-01
summary:    Image differentiation in three languages
categories: python go rust programming
published:  true
---

<!-- NOTE use textwidth=88 when wrapping -->

![Python, Go, Rust logos](/images/program-in-python-go-rust/python-go-rust.png)

_This is a subjective, primarily developer-ergonomics-based comparison of the
three languages from the perspective of a Python developer, but you can skip the prose
and go to [the code samples](#code-samples), [the performance comparison](#performance)
if you want some hard numbers, [the takeaway](#the-takeaway) for the tl;dr, or the
[Python](https://github.com/nicolashahn/diffimg),
[Go](https://github.com/nicolashahn/diffimg-go), and
[Rust](https://github.com/nicolashahn/diffimg-rs) `diffimg` implementations._

A few years ago, I was tasked with rewriting an image processing service. To tell
whether my new service was creating the same output as the old given an image and one or
more transforms (resize, make a circular crop, change formats, etc.), I had to inspect
the images myself. Clearly I needed to automate this, but I could find no existing
Python library that simply told me how different two images were on a per-pixel basis.
Hence [diffimg](https://github.com/nicolashahn/diffimg), which can give you a difference
ratio/percentage, or generate a diff image (check out the readme to see an example).

The initial implementation was in Python (the language I'm most comfortable in), with
the heavy lifting done by
[Pillow](https://pillow.readthedocs.io/en/stable/). It's usable as a library or a
command line tool. The actual
[meat](https://github.com/nicolashahn/diffimg/blob/master/diffimg/diff.py) of the
program is very small, only a few dozen lines, thanks to Pillow. Not a lot of effort
went into building this tool ([xkcd was right](https://xkcd.com/353/), there's a Python
module for nearly everything), but it's at least been useful for a few dozen people
other than myself.

A few months ago, I joined a company that had several services written in Go, and I
needed to get up to speed quickly on the language. Writing
[diffimg-go](https://github.com/nicolashahn/diffimg-go) seemed like an fun and possibly
even useful way to do this. Here are a few points of interest that came out of the
experience, along with some that came up while using it at work: 

## Comparing Python and Go

(Again, the code: [diffimg](https://github.com/nicolashahn/diffimg) (python) and
[diffimg-go](https://github.com/nicolashahn/diffimg-go))

- __Standard Library__: Go comes with a decent [image](https://golang.org/pkg/image/)
  standard library module, as well as a command line
  [flag](https://golang.org/pkg/flag/) parsing library. I didn't need to look for any
  external dependencies; the `diffimg-go` implementation has none, where the Python
  implementation uses the fairly heavy third party module (ironically) named Pillow.
  Go's standard library in general is more structured and well thought out, while
  Python's is organically evolved, created by many authors over years, with many
  differing conventions. The Go standard library's consistency makes it easier to
  predict how any given module will function, and the source code is extremely well
  documented. 
  - One downside of using the standard image library is that it does not automatically
    detect if the image has an alpha channel; pixel values have four channels (RGBA) for
    all image types.  The `diffimg-go` implementation therefore requires the user to
    indicate whether or not they want to use the alpha channel. This small inconvenience
    wasn't worth finding a third party library to fix.
  - One big upside is that there's enough in the standard library that you don't need a
    web framework like Django. It's possible to build a real, usable web service in Go
    without any dependencies. Python's claim is that it's batteries-included, but Go
    does it better, in my opinion.

- __Static Type System__: I've used statically typed languages in the past, but my
  programming for the past few years has mostly been in Python. The experience was
  somewhat annoying at first, it felt as though it was simply slowing me down and
  forcing me to be excessively explicit whereas Python would just let me do what I
  wanted, even if I got it wrong occasionally.  Somewhat like giving instructions to
  someone who always stops you to ask you to clarify what you mean, versus someone who
  always nods along and seems to understand you, though you're not always sure they're
  absorbing everything.  It will decrease the amount of type-related bugs for free, but
  I've found that I still need to spend nearly the same amount of time writing tests.
  - One of the common complaints of Go is that it does not have user-implementable
    generic types. While this is not a must-have feature for building a large,
    extensible application, it certainly slows development speed.
    [Alternative patterns](https://appliedgo.net/generics/) have been suggested, but
    none of them are as effective as having real generic types.
  - One upside of the static type system is that it reading through an unfamiliar
    codebase is easier and faster. Good use of types imbues a lot of extra information
    that is lost with a dynamic type system.

- __Interfaces and Structs__: Go uses interfaces and structs where Python would use
  classes. This was probably the most interesting difference to me, as it forced me to
  differentiate the concept of a type that defines behavior versus a type that holds
  information.  Python and other "traditionally object-oriented" languages would
  encourage you to mash these together, but there are pros and cons to both paradigms:
  - Go heavily encourages [composition over
    inheritance](https://en.wikipedia.org/wiki/Composition_over_inheritance). While it
    has [inheritance via embedding](https://golang.org/doc/effective_go.html#embedding),
    without classes, it's not as easy to forward both data and methods. I generally
    agree that composition is the better default pattern to reach for, but I'm not an
    absolutist and some situations are a better fit for inheritance, so I'd prefer not
    to have the language make this decision for me. 
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

- __No Optional Arguments__: Go only has [variadic
  functions](https://gobyexample.com/variadic-functions) which are similar to Python's
  keyword arguments, but less useful, since the arguments need to be of the same type. I
  found keyword arguments to be something I really missed, mainly for how much easier
  refactoring is if you can just throw a `kwarg` of any type onto whatever function
  needs it without having to rewrite every one of its calls. I use this feature quite
  often in at work, it's saved me a lot of time over the years. Not having the feature
  made my implementation for how to handle whether or not the diff image should be
  created based on the command line flags somewhat clumsy.

- __Verbosity__: Go is a bit more verbose (though not Java verbose). Part of that is
  because type system does not have generics, but mainly the fact that the language
  itself is very small and not heavily loaded with features (you only get [one looping
  construct!](https://tour.golang.org/flowcontrol/1)). I missed having Python's list
  comprehensions and other functional programming features. If you're comfortable
  with Python, you can go through the [Tour of Go](https://tour.golang.org/welcome/1) in
  a day or two, and you'll have been exposed to the entirety of the language. 

- __Error Handling__: Python has exceptions, whereas Go propagates errors by returning
  tuples: `value, error` from functions wherever something may go wrong. Python lets
  you catch errors at any point in the call stack as opposed to requiring you to
  manually pass them back up over and over again. This again results in brevity and
  code that isn't littered with Go's infamous `if err != nil` pattern, though you do
  need to be aware of what possible exceptions can be thrown by a function and all(!) of
  its internal calls (using `except Exception:` is a usually-bad-practice workaround for
  this).  Good docstrings and tests can help here, which you should be writing in either
  language.  Go's system is definitely safer. You're still allowed to shoot yourself in
  the foot by ignoring the `err` value, but the system makes it obvious that this is a
  bad idea.

- __Third Party Modules__: Prior to [Go modules](https://blog.golang.org/modules2019),
  Go's package manager would just throw all downloaded packages into `$GOPATH/src`
  instead of the project's directory (like most other languages). The path for these
  modules inside `$GOPATH` would also be built from the URL where the package is hosted,
  so your import would look something like `import "github.com/someuser/somepackage"`.
  Embedding `github.com` inside the source code of almost all Go codebases seems like a
  strange choice. In any case, Go now allows the conventional way of doing things, but
  Go modules are still new so this quirk will remain common in wild Go code for some
  time.

- __Asynchronicity__: Goroutines are a very convenient way to fire off asynchronous
  tasks. Before `async/await`, Python's asynchronous solutions were somewhat hairy.
  Unfortunately I haven't written much real-world async code in Python or Go, and the
  simplicity of `diffimg` didn't seem to lend itself to the added overhead of
  asynchronicity, so I don't have too much to say here, though I do like Go's
  [channels](https://gobyexample.com/channels) as a way to handle multiple async tasks.
  My understanding is that for performance, Go still has the upper hand here as
  goroutines can make use of full multiprocessor parallelism, where Python's basic
  `async/await` is still stuck on one processor, so mainly useful for I/O bound tasks.

- __Debugging__: Python wins. `pdb` (and more sophisticated options like
  [ipdb](https://pypi.org/project/ipdb/) are available) is extremely flexible, once
  you've entered the REPL, you're able to write whatever code you want.
  [Delve](https://github.com/go-delve/delve) is a good debugger, but it's not the same
  as dropping straight into an interpreter, the full power of the language at your
  fingertips.

### Go summary

My initial impression of Go is that because its ability to abstract is (purposely)
limited, it's not as _fun_ a language as Python is. Python has more features and thus
more ways of doing something, and it can be a lot of fun to find the fastest, most
readable, or "cleverest" solution. Go actively tries to stop you from being "clever." I
would go as far as saying that Go's strength is that it's *not* clever.

Its minimalism and lack of freedom are constraining as a single developer just trying to
materialize an idea. However, this weakness becomes its strength when the project scales
to dozens or hundreds of developers - because everyone's working with the same small
toolset of language features, it's more likely to be uniform and thus understandable by
others. It's still very possible to write bad Go, but it's more difficult to create
monstrosities that more "powerful" languages will let you produce.

After using it for a while, it makes sense to me why a company like Google would want a
language like this. New engineers are being introduced to enormous codebases constantly,
and in a messier/more powerful language and under the pressure of deadlines, complexity
could be introduced faster than it can be removed. The best way to prevent that is with
a language that has less capacity for it.

With that said, I'm happy to work on a Go codebase in the context of a large application
with a diverse and ever-growing team. In fact, I think I'd prefer it. I just have no
desire to use it for my own personal projects.

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
  now, but Rust's is significantly more powerful (and complicated). Generic types,
  enumerated types, traits, reference types, lifetimes are all additional concepts that
  I had to learn on top of Go's much simpler interfaces and structs. Additionally, Rust
  uses its type system to implement features that other languages don't use the type
  system for (example: the [Result](https://doc.rust-lang.org/std/result/) type, which
  I'll talk about soon).  Luckily, the compiler/linter is extremely helpful in telling
  you what you're doing wrong, and often even tells you exactly how to fix it. Despite
  this, I've spent significantly more time than I did learning Go's type system and I'm
  still not comfortable with all the features yet.
  - There was one place where because of the type system, the implementation of the
    imaging library I was using [would have led to an uncomfortable amount of code
    repetition.](https://github.com/nicolashahn/diffimg-rs/blob/e9dd3f0331b3e32d2f62241b4d576d1da3d3cd42/src/lib.rs#L105)
    I only ended up matching the two most important enum types, but matching the others
    would lead another half dozen or so lines of nearly identical code. At this scale
    it's not an issue, but it rubs me the wrong way. Maybe it's a good candidate for
    using macros, which I still need to experiment with.
    ```rust
    let mut diff = match image1.color() {
        image::ColorType::RGB(_) => image::DynamicImage::new_rgb8(w, h),
        image::ColorType::RGBA(_) => image::DynamicImage::new_rgba8(w, h),
        // keep going for all 7 types?
        _ => return Err(
            format!("color mode {:?} not yet supported", image1.color())
        ),
    };
    ```

- __Manual Memory Management__: Python and Go pick up your trash for you. C lets you
  litter everywhere, but throws a fit when it steps on your banana peel. Rust slaps you
  and demands that you clean up after yourself. This stung at first, since I'm spoiled
  and usually have my languages pick up after me, moreso even than moving from a dynamic
  to a statically typed language. Again, the compiler tries to help you as much as is
  possible, but there's still a good amount of studying you'll need to do to understand
  what's really going on.
  - One nice part about having such direct access to the memory (and the functional
    programming features of Rust) is that it simplified the [difference ratio
    calculation](https://github.com/nicolashahn/diffimg-rs/blob/623fb06272f696da9673ccc0cb7ea5bd55582b49/src/lib.rs#L80)
    because I could simply map over the raw byte arrays instead of having to index each
    pixel by coordinate.

- __Functional Features__: Rust strongly encourages a functional approach: it has a
  FP-friendly type system like Haskell, immutable types, closures, iterators, pattern
  matching, and more, but also allows imperative code. It's similar to writing OCaml
  (interestingly, the original Rust compiler [was written in
  OCaml](https://github.com/rust-lang/rust/tree/ef75860a0a72f79f97216f8aaa5b388d98da6480/src/boot)).
  Because of this, code is more concise than you'd expect for a language that competes
  with C.

- __Error Handling__: Instead of the exception model that Python uses or the tuple
  returns that Go uses for error handling, Rust makes use of its enumerated types:
  `Result` returns either `Ok(value)` or `Err(error)`. This is closer to Go's way if you
  squint, but is a bit more explicit and leverages the type system. There's also
  syntactic sugar for checking a statement for an `Err` and returning early: [the `?`
  operator](https://doc.rust-lang.org/stable/edition-guide/rust-2018/error-handling-and-panics/the-question-mark-operator-for-easier-error-handling.html) (Go could use something like this, IMO).

- __Asynchronicity__: Async/await hasn't quite landed for Rust yet, but the final syntax
  has [recently been agreed
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
  and Go, but the Rust plugins were easier to set up, more helpful, and more consistent
  compared to the other two languages. The
  [rust.vim](https://github.com/rust-lang/rust.vim) and
  [vim-lsp](https://github.com/prabirshrestha/vim-lsp) plugins (along with [the Rust
  Language Server](https://github.com/rust-lang/rls)) were all I needed to get an
  extremely powerful configuration. I haven't tested out other editors with Rust but
  with the excellent editor-agnostic tooling that Rust comes with, I'd expect them to be
  just as helpful. The setup provides the best go-to-definition I've ever used. It works
  perfectly on local, standard library, and third-party code out of the box. 

- __Debugging__: I haven't tried out a debugger with Rust yet (since the type system and
  `println!` take you pretty far), but you can use `rust-gdb` and `rust-lldb`, wrappers
  around the `gdb` and `lldb` debuggers that are installed with the initial `rustup`.
  The experience should be predictable if you've used those debuggers before with C. As
  mentioned previously, the compiler error messages are extremely helpful.

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

As far as how I feel when I write Rust, it's a lot of fun, like Python. Its breadth of
features makes it very expressive. While the compiler stops you a lot, it's also very
helpful, and its suggestions on how to solve your borrowing/typing problems usually
work. The tooling as I've mentioned is the best I've encountered for any language and
doesn't bring me a lot of headaches like some other languages I've used. I really like
using the language and will continue to look for opportunities to do so, where the
performance of Python isn't good enough.

## [Code Samples](#code-samples)

I've extracted the chunks of each `diffimg` which calculate the difference ratio.  To
summarize how it works for Python, this takes the diff image generated by Pillow, sums
the values of all channels of all pixels, and returns the ratio produced by dividing the
maximum possible value (a pure white image of the same size) by this sum.

__Python__:
```python

diff_img = ImageChops.difference(im1, im2)
stat = ImageStat.Stat(diff_img)
sum_channel_values = sum(stat.mean)
max_all_channels = len(stat.mean) * 255
diff_ratio = sum_channel_values / max_all_channels

```

For Go and Rust, the method is a little different: Instead of creating a diff image, we
just loop over both input images and keep a running sum of the differences of each
pixel. In Go, we're indexing into each image by coordinate...

__Go__:
```go

func GetRatio(im1, im2 image.Image, ignoreAlpha bool) float64 {
  var sum uint64
  width, height := getWidthAndHeight(im1)
  for y := 0; y < height; y++ {
    for x := 0; x < width; x++ {
      sum += uint64(sumPixelDiff(im1, im2, x, y, ignoreAlpha))
    }
  }
  var numChannels = 4
  if ignoreAlpha {
    numChannels = 3
  }
  totalPixVals := (height * width) * (maxChannelVal * numChannels)
  return float64(sum) / float64(totalPixVals)
}

```

... but in Rust, we're treating the images as what they really are in memory, a series
of bytes that we can just zip together and consume.

__Rust__:
```rust

pub fn calculate_diff(
    image1: DynamicImage,
    image2: DynamicImage
  ) -> f64 {
  let max_val = u64::pow(2, 8) - 1;
  let mut diffsum: u64 = 0;
  for (&p1, &p2) in image1
      .raw_pixels()
      .iter()
      .zip(image2.raw_pixels().iter()) {
    diffsum += u64::from(abs_diff(p1, p2));
  }
  let total_possible = max_val * image1.raw_pixels().len() as u64;
  let ratio = diffsum as f64 / total_possible as f64;

  ratio
}

```

Some things to take note of in these examples:
- Python has the least code by far. Obviously, it's leaning heavily on features of the
  image library it's using, but this is indicative of the general experience of using
  Python. In many cases, a lot of the work has been done for you because the ecosystem
  is so developed that there are mature pre-existing solutions for everything.
- There's type conversion in the Go and Rust examples. In each block there are three
  numerical types being used: `uint8`/`u8` for the pixel channel values (the type is
  inferred in both Go and Rust, so you don't see any explicit mention of either type),
  `uint64`/`u64` for the sum, and `float64`/`f64` for the final ratio. For Go and Rust,
  there was time spent getting the types to line up, whereas Python converts everything
  implicitly.
- The Go implementation's style is very imperative, but also explicit and
  understandable (minus the `ignoreAlpha` part I mentioned earlier), even to those
  unaccustomed to the language. The Python example is fairly clear as well, once you
  understand what `ImageStat` is doing. Rust is definitely murkier to those unfamiliar
  with the language:
  - `.raw_pixels()` gets the image as a vector of unsigned 8-bit integers.
  - `.iter()` creates an iterator for that vector. Vectors by default are not iterable.
  - `.zip()` you may be familiar with, it takes two iterators and produces one, with
    each element being a tuple: (element from first vector, element from second vector).
  - We need a `mut` in our `diffsum` declaration because by default, variables are
    immutable.
  - If you're familiar with C you can probably figure out why we have the `&`s in `for
    (&p1, &p2)`: The iterator produces references to the pixel values, but `abs_diff()`
    takes the values themselves. Go supports pointers ([which are not quite the same as
    references](https://spf13.com/post/go-pointers-vs-references/)), but they're not as
    commonly used as references are in Rust.
  - The last statement in a function is used as the return value if there isn't a
    line-ending `;`. A few other functional languages do this as well.

  This snippet gives you some insight into how much language-specific knowledge you'll
  need to pick up to be effective in Rust.


## [Performance](#performance)

Now for something resembling a scientific comparison. I first generated three random
images of different sizes: 1x1, 2000x2000, and 10,000x10,000. Then I measured each
(language, image size) combination's performance 10 times for each `diffimg` ratio
calculation and averaged them, using the values given by the `real` values from the
`time` command. `diffimg-rs` was built using `--release`, `diffimg-go` with just `go
build`, and the Python `diffimg` invoked with `python3 -m diffimg`. The results, on a
2015 Macbook Pro:

| Image size: | 1x1             | 2000x2000          | 10,000x10,000      |
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
through 100,000,000 times, dwarfing the setup time. Never needing to pause for garbage
collection could also be a factor.

The Python implementation definitely has room for improvement, because as efficient as
Pillow is, we're still creating a diff image in memory (traversing both input images)
and _then_ adding up each of its pixel's channel values. A more direct approach like the
Go and Rust implementations would probably be marginally faster. However, a _pure_
Python implementation would be wildly slower, since Pillow does its main work in C.
Because the other two are pure language implementations, this isn't really a fair
comparison, though in some ways it is, because Python has an absurd amount of libraries
available to you that are performant thanks to C extensions (and Python and C have a
very tight relationship in general).

I should also mention the binary sizes: Rust's is 2.1mb with the `--release` build, and
Go's is comparable at 2.5mb. Python doesn't create binaries, but `.pyc` files are
_sort of_ comparable, and `diffimg`'s `.pyc` files are about 3kb in total. Its source
code is also only about 3kb, but including the Pillow dependency, it weighs in at
24mb(!). Again, not a fair comparison because I'm using a third party imaging library,
but it should be mentioned.

## [The takeaway](#the-takeaway)

Obviously, these are three very different languages fulfilling different niches. I've
heard Go and Rust often mentioned together, but I think Go and Python are the two more
similar/competing languages. They're both good for writing server-side application logic
(what I spend most of my time doing at work). Comparing just native code performance, Go
blows Python away, but many of Python's libraries that require speed are wrappers around
fast C implementations - in practice, it's more complicated than a naive comparison.
Writing a C extension for Python doesn't really count as Python anymore (and then you'll
need to know C), but the option is open to you.

For your backend server needs, Python has proven itself to be "fast enough" for
most applications, though if you need more performance, Go has it. Rust even more so,
but you pay for it with development time. Go is not far off from Python in this regard,
though it certainly is slower to develop, primarily due to its small feature set. Rust
is very fully featured, but managing memory will always take more time than having the
language do it, and this outweighs having to deal with Go's minimality.

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
to write a good suite of tests. That said, I much prefer Rust's type system to Go's: it
supports generics, pattern matching, handles errors, and just does more for you in
general.

In the end, this comparison is a bit silly, because though the use cases of these
languages overlap, they occupy very different niches. Python is high on the
development-speed, low on the performance scale, while Rust is the opposite, and Go is
in the middle. I enjoy writing Python and Rust more than Go ([this may be
unsurprising](https://insights.stackoverflow.com/survey/2019#technology-_-most-loved-dreaded-and-wanted-languages)),
though I'll continue to use Go at work happily (along with Python) since it really is a
great language for building stable and maintainable applications with many contributors
from many backgrounds. Its inflexibility and minimalism which makes it less enjoyable to
use (for me) becomes its strength here. If I had to choose the language for the backend
of a new web application, it would be Go.

I'm pretty satisfied with the range of programming tasks that are covered by these three
languages - there's virtually no project that one of them wouldn't be a great choice
for.
