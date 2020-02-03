+++
title = "Divide ➗ Search 🔍 Abstract 🔭"
date = "2019-11-28"
author = "Ricardo"
categories = ["tips", "problem", "solving", "abstraction", "thinking"]
tags = ["problem", "solving", "abstraction", "thinking"]
+++


Some problems are harder than others, but having a system to approach them makes a big difference.
<!--more-->

Yesterday I finished teaching my first Python course. Apart from teaching about generators, decorators, coroutines, multiprocessing, pandas, flask, pytest, docker... and a long list of development tools and Python modules, I tried to transmit an important message I believe is a lot more fundamental than knowing all the technicalities, and it is problem solving.

We, not only as programmers but in life in general, have to solve things constantly, wether it's at work, at home, or with ourselves. Facing the problem as such can become daunting and look impossible at first, having techniques to work through them can be an incredibly helpful tool. For me that technique can be summarized in three words: Divide. Search. Abstract.

To illustrate the method I will use a simple problem: writing a function to generate random email strings.

First, we **divide** the problem as much as we can or need. In our case the first division may be:

* Make random choices for things.
* Generate username.
* Generate domain `(gmail hotmail outlook ...)`.
* Generate domain root `(.com .es .org .edu ...)`.

Lets now tackle the first part. We need to be able to make random choices, that looks like a very common problem, so the chances someone has already worked on that are very high. A quick Google **search** lands us on the Python documentation from the [random](https://docs.python.org/3/library/random.html) module, and it seems the method `random.choice()` does just that.

Now we need to generate the username, we can **divide** that problem as well:

* Generate username:
  * Create a set of all the possible characters we want.
  * Choose random elements from that set.
  * Make the user able to choose the length of the username created.

For the first part, another quick **search** tells us about `string.ascii_lowercase`, which is just what we need. The second part was already solved before. Lets see if they work together.


```python
from random import choice
from string import ascii_lowercase as letters

choice(letters)
```




    'l'



Fantastic, we have already solve a tiny bit of our problem, we only need to make a loop and generate many random letters. For this part, a list comprehension together with `range()` will make it for us.


```python
[choice(letters) for _ in range(10)]
```




    ['k', 'm', 'm', 'o', 'i', 'd', 'x', 't', 'j', 'f']



Lastly, we need to concatenate those characters. Another **search** will show us the `str.join()` method:


```python
"".join([choice(letters) for _ in range(10)])
```




    'dgiqtxxlmg'



Awesome 🎉, we have done the first part of our problem, and not only that, now we are more prepared for the next parts.

Choosing random letters to get a valid domain and root doesn't look appropiate, having our own lists for that seems easier:


```python
domains = ["gmail", "hotmail", "outlook","yahoo"]
roots = [".com", ".xyz", ".es", ".org"]
```

We can check if our previous knowledge can be used here too:


```python
print(choice(domains))
print(choice(roots))
```

    outlook
    .xyz


We have already solved many important points of our problem, so it may be a good idea to start **abstracting** them inside a function. By **abtracting** it we are not only freeing space in our minds, but also making it easier for other people to use, work with and build upon what we have created.


```python
def mail_generator():
    domains = ["gmail", "hotmail", "outlook", "yahoo"]
    roots = [".com", ".xyz", ".es", ".org", ".pl"]

    username = "".join([choice(letters) for _ in range(10)])
    
    domain = choice(domains)
    root = choice(roots)
    
    final_string = f"{username}@{domain}{root}"
    
    return final_string
```


```python
mail_generator()
```




    'udirqpnyft@hotmail.xyz'



It works 🥳. But wait! All of our emails will have the same length, maybe we want to let our users choose a length interval. If we want, we can **divide** that part as well:

* Let the user choose the length:
  * Generate a random integer.
  * Use it for our length.

Another **search** gives us the answer, that `random` makes a comeback with its `randint()` method, which solves our problem all at once, since it lets us pick an interval.


```python
from random import randint

randint(3, 12)
```




    9



We can wrap everything up by refactoring our function, we need to give it two parameters and put the `randint()` inside our `range()`:


```python
def mail_generator(minimum: int = 3, maximum: int = 15) -> str:
    domains = ["gmail", "hotmail", "outlook", "yahoo"]
    roots = [".com", ".xyz", ".es", ".org", ".pl"]

    username = "".join([choice(letters) for _ in range(randint(minimum, maximum))])

    domain = choice(domains)
    root = choice(roots)

    final_string = f"{username}@{domain}{root}"

    return final_string
```


```python
mail_generator(5, 20)
```




    'xeuxgsfvu@outlook.xyz'



Finally! We have finished our function. Now we can keep working on it adding features as we want (choosing domain roots depending on the domain name, adding numbers to the username, etc), but our main problem is done.

I know the problem showed here is quite simple, but it's more than enough to illustrate the technique.

Problems may be more or less tedious to solve, but by dividing them into smaller parts, seraching for information to solve those smaller parts (Google, documentation, books...), and finally abstracting those, will get us a lot closer to solving it than if we just try to approach it as a whole.

In the end, if we are where we are, solving the problems of our current time is because some people in the past took the problems of their time, solved their little parts and then abstracted that solution into a tool we can use.
