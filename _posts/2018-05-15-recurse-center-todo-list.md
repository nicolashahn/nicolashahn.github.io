---
layout:     post
title:      Recurse Center TODO List
date:       2018-05-15
summary:    Some things I might get done at the Recurse Center.
categories: recurse-center
---

Less than a week to go until my batch at the [Recurse Center](https://www.recurse.com/) starts. I've spent a good amount of time coming up with things to work on - for fun, profit, and hopefully a bit more direction on where I want to take this whole "programming as a vocation" thing.

The last few weeks I've spent traveling, relaxing, taking care of things I've been putting off, but all the while jotting down various ideas for how I want to spend the batch. Here they are, in no particular order, with apologies in advance for the brain-dump format:

* Receipt image itemization app
  * Scans a receipt, itemizes, map items to people, create Venmo requests
  * [Taggun](https://www.taggun.io/) for the receipt image to text transformation
  * Research prior art, like Smart Receipts app
* Raspberry Pi that can detect the beat of ambient nearby house/techno music (for Burning Man art project)
  * Generate dataset from top 40 house music list
  * [Detecting BPM using Neural Networks](https://nlml.github.io/neural-networks/detecting-bpm-neural-networks/)
  * [Aubio](https://github.com/aubio/aubio/blob/master/README.md)
* Custom journaling mobile app
  * There are tons out there, but I'd like to make a very personalized version that allows you to build a dataset of yourself
  * Choose the fields and types you want, store and export a CSV w/`datetime`, `field1`, `field2`, etc.
  * Create prompts with subsets of these fields that the app notifies you with at certain times of day
* Lisp
  * Build something with Clojure - but what?
  * SICP - there's always a few people that want to tackle it in each RC batch, right?
  * Play with [Portacle](https://portacle.github.io/) (Common Lisp)
  * Play with [Carp](https://github.com/carp-lang/Carp), maybe contribute?
* Build your own...
  * Database: [SQLite clone in C](https://cstack.github.io/db_tutorial/) 
  * Ray tracer: [Ray Tracing in One Weekend](http://in1weekend.blogspot.com/2016/01/ray-tracing-in-one-weekend.html)
  * Various other ideas: [https://news.ycombinator.com/item?id=16591918](https://news.ycombinator.com/item?id=16591918) 
* Cryptocurrency momentum detector
  * Monitor the level of activity/mentions on Twitter and Reddit of each coin on Coinmarketcap
  * If popularity seems to be growing, but the price has yet to spike, buy
* Teach myself more about neural nets, applied to audio, CV, NLP
  * Audio: Create a net that trains on raw sound files -> mastered versions to create a net that can automatically master audio
  * CV: Mobile app or Raspberry Pi w/camera that tells you a joke when it detects a frowning face, insults you when it sees a smiling face
  * NLP: Ideas for this one? Text classification?
* An art project
  * Sound sensitive shirt/sleeve/glove - directional mic on the palm, LEDs that pulse with the music when you point it at the source
  * Style transfer
  * Some artistic data visualization
* Polish my existing Github projects
  * Make the user experience for [diffimg](https://github.com/nicolashahn/diffimg) completely painless, ensure it works with both Python 2 and 3
  * Beautify the graph, debug [USAA-Transaction-Graph](https://github.com/nicolashahn/USAA-Transaction-Graph), UX here could also use work
  * Finish writing the docs for [py-search-hn](https://github.com/nicolashahn/py-search-hn)
  * Add to [lisp-in-python](https://github.com/nicolashahn/lisp-in-python), get the game of life testfile working, add macro support to start
* An application involving mapping data
  * Location based reminder app
    * Pin a location, write a note, when you get near, app notifies to do the thing
* Do some MIT/Stanford Youtube courses
  * Finish Stanford CS231N (computer vision course) videos
  * Other MOOCs: [https://news.ycombinator.com/item?id=16745042](https://news.ycombinator.com/item?id=16745042)
* Write a Vim plugin or do something with Vimscript
  * [Learn Vimscript the Hard Way](http://learnvimscriptthehardway.stevelosh.com/)
* Give Spacemacs a chance - use it for a full week or two (after configuration is settled)
  * Learn Org mode 
  * Maybe VScode too? Spacemacs first
* Read the [Competitive Programmer's Handbook](https://cses.fi/book.html)
  * Learn some C++ along the way
* Day where I pick a technical paper/discussion, and every time I come across a term I don’t fully understand, I do a recursive Wikipedia (and other resources) deep dive 
* Fully grok git: [https://news.ycombinator.com/item?id=16587174](https://news.ycombinator.com/item?id=16587174)
* Learn to habitually use `pdb` (and other debuggers)
* Do some stats on a [Kaggle](https://www.kaggle.com/) dataset
* Gain a true understanding of the tools I use, and plug the holes in my knowledge of them - a lot of the time I learn just enough to complete the task given, but I want to cover more ground - Python, Javascript/Typescript, Flask, React
* Code reviews - give and receive feedback, hopefully daily
* Pair program - learn and share some good habits and tips
* Write more - hopefully this post is only the first of many that will be generated by these projects
* And of course, help other Recursers who have interesting projects (or if any of these projects sound interesting to you, contact me and let's work on one together!)

Some of these items are very vague, and I'm hoping that talking to the rest of my batch will help me clarify the murkier ones. I'm also aware that accomplishing this all this may not be possible for a 12 week program.

I've worked as a full-stack web developer for the past couple of years, but becoming a human function with the signature `ZeplinDesign -> ReactComponent`, pushing pixels around in CSS, and dealing with frontend JS infrastructure has me wondering if I should look at another specialization.

A recent trip to Mexico has also sparked the idea of becoming a digital nomad, writing software and visiting a new city every week. I'm considering remote contracting, hopefully some of my batch have relevant experience. I already put 90% of my worldly possessions in a storage unit to move to NY, so why not just keep exploring while my life fits into two bags?

Anyways, there's my brain-dump of projects that'll possibly bring me a little closer to an idea of how I want the rest of my programming career to look. Wander around in the grass until I find a road.
