+++
title = "Notes on Simple Made Easy"
date = "2020-09-22"
author = "Ricardo"
categories = ["notes"]
tags = ["notes", "personal", "simplicity"]
thumbnail = "img/social/simple_vs_easy.png"
+++

These are my notes on the talks ["Simple Made Easy" by Rich Hickey](https://www.youtube.com/watch?v=kGlVcSMgtV4).

*Simplicity is a prerequisite for reliability* - Dijkstra

Simple:

* One role.
* One task.
* One concept.
* One dimension.
* Lack of interleaving. (Does not mean there's only one thing)

Easy:

* "Near". To our understanding, skill/set or capabilities.
* Easy is relative.

We can only make reliable those things we can understand.

We can only consider a few things at a time. If a piece is intertwined with another we already have to keep both in mind. It's combinatorial.

**Complexity undermines understanding.**

Ignoring complexity slows you in the long haul.

![](https://ricardoanderegg.com/img/social/simple_vs_easy.png)

The simple route is slower at the beginning because it requires thought.

Benefits of simplicity:

* Ease of understanding.
* Ease of change
* Ease of debugging
* Flexibility
	* Policy
	* Location 


Complect = interleave, entwine, braid.
Compose = place together.

Modularity != simplicity. Partition and stratification (modularity) != simplicity.
Modularity = simplicity; when we limit what those modules are allowed to think about.

*Programming, when stripped of all its circumstantial irrelevancies, boils down to no more and no less than **very effective thinking** so as to avoid unmastered complexity, to very vigorous separation of your many different concerns* - Dijkstra


*Simplicity is the ultimate sophistication* - Da Vinci

## Simple made easy

* Chose simple constructs over  complexity-generating constructs.
	* It's the artifacts, not the authoring.
* Create abstractions with simplicity as a basis.
* Simplify the problem space before you start.
* Simplicity often means making more things, not fewer. 


## The simplicity toolkit

|Construct|Get via|
|:--:|:--:|
|Values|final, persistent collections...|
|Functions|stateless methods|
|Namespace|language support|
|Data|Maps, arrays, sets, JSON...|
|Polymorphism *a la carte*|Protocols, type classes|
|Set functions|Libraries|
|Queues|Libraries|
|Declarative manipulation|SQL, Prolog|
|Rules|Libraries, Prolog|
|Consistency|Transactions, values...|
