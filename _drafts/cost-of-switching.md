---
layout:     post
title:      Don't change your framework
date:       2018-06-24
summary:
categories: software engineering
published:  false

---

Programmers are presented with a myriad of options for out of the box solutions - usually if a problem has been solved, it's been solved more than once. Off the top of my head, the options for frontend web frameworks are (at least) React, Vue, Angular, Backbone, and Polymer. There are at least three established options for backend frameworks I'm aware of currently being used in production at substantial companies, [*for python alone*](https://hackernoon.com/top-10-python-web-frameworks-to-learn-in-2018-b2ebab969d1a). Obviously, this does not only apply to web frameworks, but for any project that requires working with an abstraction layer for which there is more than one reasonable choice. This may not even refer to specific code libraries, but design patterns as well: monolith architecture vs. microservice or serverless, for example.

It's obviously worth spending time looking into the tradeoffs and how they're going to apply for your particular application when starting a project, but fortunately/unfortunately, new frameworks that are legitimately superior to the current options are constantly being developed, and when that occurs, there's a temptation to switch. However, after the foundation has been set and construction is well underway, any reasons for switching to another to another framework should be looked at with caution.

These tempting new frameworks always advertise improvements over your current framework: performance or easier development are common reasons to switch. Occasionally, these are so immensely valuable that the rewrite can actually be worth it, depending on the effort required by the switch. There’s also an argument to be made for being able to hire more or better engineers - the theory being that the older a framework is, the harder it’ll be to find engineers with the proper experience, or desire to learn it. This is somewhat valid if your stack has become esoteric, but engineers with experience and 

A common reason that isn't as valid is fear of one's skills depreciating. Switching to a new abstraction because you want experience with it/to pad your resume is fine, as long as you’re building something solely for yourself. But, for example at a startup, if you’re trying to create a product or service that’s actually meant to be used by people sooner rather than later, this should not factor in at all - if you are actually aligned with your company, your primary goal should be to make the company’s value proposition a reality as soon as possible, and changing frameworks may be an impediment to this. I’m not suggesting that time to MVP is more important than developing a codebase that lasts; any reasonable framework should allow you to write organized code.

Regardless of the reasons for switching, the costs need to be considered. And from what I’ve seen so far, these costs are often not worth the benefits, and are *always* underestimated. This problem is a subset of software estimation in general, on which there are entire [books](https://www.amazon.com/Software-Estimation-Demystifying-Developer-Practices/dp/0735605351) written. 

Here are some things I’ve noticed from my own personal experience. You should be able to agree with all of these statements before switching to a new abstraction:

1. I know exactly what I will gain by switching, and have calculated how much time or money this will save me.
1. I know exactly what I will *lose* by switching, and have calculated how much time or money this will cost me. (This is much less obvious: inevitably, you will find attributes of your current abstraction you miss in the new one. Included in this is the time it will take for you and your team to gain proficiency in the new abstraction)
1. The time/money difference between the two above points is in my favor.
1. I have plotted out exactly what the steps are for switching, and have estimated how long each will take, based on the size of my current codebase and hands-on investigation, such as by converting a single piece to use the new abstraction, documenting difficulties along the way.
1. I have ensured I have at least double the total estimated amount of time to make the switch. Any deadlines that may be affected by it are well past this date.
1. Everyone I work with understands all of the above to the level I do and is in agreement with the estimations. We also agree that the benefits outweigh the costs, even if we encounter every potential setback we possibly can along the way, along with the several more we're currently unaware of but are sure to encounter.

If you cannot truthfully agree with all of these statements, you either have more research to do, or should consider sticking with what you have. While there may be some unpleasantness with your current abstraction, you know exactly what to expect and can plan with more reliability.
