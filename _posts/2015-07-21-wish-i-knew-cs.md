---
layout:     post
title:      What I Wish I Knew Going Into A Computer Science Degree
date:       2015-07-20
summary:    Tips for other students who just wanted a technical degree, but found themselves enjoying it
categories: 
---

I was floating through college at University of California Santa Cruz. As a freshman, I picked an Art degree because it was vaguely related to graphic design, which was vaguely what I wanted to do when I graduated high school. Because I was so directionless, I just wanted the college experience - my actual education was secondary. In hindsight, this _may_ have been a mistake. 

I eventually took on Computer Science as a second major once I realized that:

* I'm not particularly interested in art history, dead artists, or even conceptual pieces as much as I'm interested in technical mastery
* I don't like sharing my feelings and personal struggles with anyone who'll listen (what most art projects end up being, at least at my school)
* Problem solving is highly satisfying, much more so than making something pretty

At first it was a lot of rote memorization of seemingly unrelated facts, tedious handwritten computation in the form of calculus and linear algebra, and convoluted programming assignments which seemed completely arbitrary at the time (though I would later find valuable). My motivation initially stemmed from the fact that I would get to (have to?) spend another year in college, and I was beginning to highly enjoy the social aspects of being an older member in a fraternity. Later, when the real world started to loom large on the horizon, I was further motivated by the promise of an above-minimum-wage job.

However, if what I really wanted was to enjoy to the fullest the perks of being big boy in greek life, I wouldn't have spent most of my last year in front of a computer monitor instead of going to social events. Likewise, if I was really in it for the money, what was I doing spending my free time learning Haskell and doing Project Euler problems instead of learning the latest .js framework? 

At some point I realized I actually enjoy learning Computer Science. I realize I've just stuck a toe in the waters, only dabbled in a couple fields within CS. Having completed what's essentially supposed to be 'the important parts' of a four year degree in two (I was in a program that skipped the hardcore CS classes - compilers, computational models, higher math classes - in exchange for more focus on 'marketable' skills, like web/mobile/graphics), there are definitely gaps in my knowledge that I'm trying to fill in. I honestly wish I could have stayed another year. I miss the teachers that were genuinely passionate and brilliant, and that tangible, succulent feeling of progression when you compare your level of knowledge and skill to your one-quarter-ago self. Before I switched to Computer Science, college was just something you did after high school and before your 30-40 years of wage slavery.

The point is that if you've just started a CS degree, switched from something else, or are thinking about doing so, the following tips may make your life significantly easier. If you've already started, then you've probably figured out some of these on your own.

### 1. Google your problems and errors

99% of the time, if you're stuck on some problem or can't figure out why the compiler's throwing you that error, someone else has been there, done that. The sooner you figure out how to craft queries that get you the exact StackOverflow link you want, the less time you'll spend frustrated. Never go to the documentation first, always google the error or keywords of whatever problem you're trying to solve. If you can learn to make this your initial reflex when you're stumped, you'll save a _lot_ of time.

Also, if this process is taking you longer than you expected, don't be discouraged. Know that the time you spend failing to find the solution to your current problem is not wasted; you're learning things that will be useful for future problems.

### 2. Read ALL the starter code before writing your own

When given an assignment, you're generally given some code to start from. Sometimes, this is a lot of code, written in a different style than yours, and you have a pretty good idea of what you need to do, so why bother reading all of it? In the long run, if you read at all through once, just to get a general idea of what it does, you'll save a lot of time. You won't be implementing things that already exist, searching through the code later for a specific method, and it'll give hints on how you should be tackling the problem. This shouldn't need to be said, but read all the assignment specifications first as well before doing anything. 

### 3. When in doubt, write/draw it out

For sufficiently large or complicated problems, it's going to be very difficult hold all the information necessary for solving it in your head. Whenever this is the case, whip out a notebook. Draw out the structure of the problem, and write down any information that will be immediately useful in solving it. Visualizing the problem is especially useful wherever arrays or graphs are used. This one tip almost singlehandedly got me through my algorithms class. Once you draw out the problem, sometimes the answer immediately becomes obvious.

### 4. Abstract away smaller problems to solve larger ones

What I mean by this is that whenever you have a large problem, it can almost certainly be broken down into smaller pieces. Solve these pieces independently using their own functions, and ensure they work properly before using them in a larger function. 

For example, if you're trying to sum all the numbers in a certain range whose digits add to a certain amount (for example, 147's digits are 1 + 4 + 7 = 12), first write a function called `addDigits(n)` that takes a number `n` and returns the sum of its digits. Then use this function in a larger one called `sumNumbers(i,j,n)` that, in the range from `i` to `j`, sums all the numbers whose digits add to `n`.

### 5. Make your code readable

This isn't just for working with other people. Whenever you're writing code, imagine that your memory is going to be wiped immediately after you finish, then you'll be asked what the code does. This is essentially what's going to happen when you try to look up how you solved a problem weeks or months later and you can't figure out what you were doing because you're a sloppy coder.

In general, this means using well thought out variable and function names, and comments anywhere that might be useful. Comment what each function does right above it. Any slightly tricky maneuver, comment exactly what you're trying to do above it. I also like to add a Haskell type binding, so you can look up exactly what type the function takes and returns. This makes debugging far easier as well.

A good formula for writing a nontrivial function:

* Write accurate, well thought out function and argument names
* Put the types of expected input and output above it
* In comments, write high-level pseudo code inside the function
* Under each step of the pseudo code, fill in the actual code

### 6. Master git as soon as you can

And start using it for every project, whether solo or with a team. The ability to roll back catastrophes is invaluable, and if you can learn to efficiently manage a code base with multiple contributers and merge teammate's code, you'll be the coolest kid on the block when working in a group.

### 7. Work with other people whenever possible

You're going to work in groups on certain projects and sometimes have the option not to. Always work in teams. You'll be learning how to communicate your ideas effectively, be working in an environment a lot closer to what you'll most likely be doing after college in either the industry or academia, and expanding your network. Be friendly to everyone you meet, even if they don't seem like the type of person you'd like to spend time with. Also, working with other people is just more fun and motivating than working alone.

### 8. Be articulate, persuasive, and friendly

I would argue that your interpersonal and language skills are just as important as your technical ones. I picked these three traits because I think they're going to be what helps you the most, no matter what you decide to do. Even if you're brilliant, that's not going to come across if you're not articulate. If you're not persuasive, any goal that involves other people is going to be much harder to meet. And no one's going to want to work with you if you're not friendly. 

Unless you're so technically impressive that you don't need interpersonal skills, actively practice and take steps to build them.

### 9. The quickest way to learn is by doing

You can read articles, books, documentation for hours, but unless you have a project with a specific goal in mind, you're not going to retain nearly as much as if you applied it to a project. Instead of reading about Android, build an app. Pick a project you find interesting - if you don't, you'll retain a lot less and likely end up not finishing it.

So stop reading this article, pick an interesting project, and start doing it.