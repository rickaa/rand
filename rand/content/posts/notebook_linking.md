+++
title = "Linking notebooks"
date = "2019-07-25"
author = "Ricardo"
categories = ["tips", "jupyter", "notebook", "trick"]
tags = ["jupyter", "notebook", "trick"]
+++


There is a little trick I just found about, which I think can be very useful when you split tasks across different notebooks.
<!--more-->

Jupyter notebooks keep gaining popularity and use cases, the rapid growth of the tooling ecosystem around it is just one proof (for example [voilà](https://github.com/QuantStack/voila) or [panel](https://panel.pyviz.org/)).

Most people choose Jupyter when publishing a course or tutorial on Github and that's great, but wheen there are a lot of notebooks it can become messy.

I am now working on a project and I'm separating tasks in different notebooks like:

```markdown
01.task1.ipynb
02.task2.ipynb
03.task3.ipynb
.
.
.
```

And I found you can link a notebook from another one like you would link to a normal website:

```markdown

[task foo](../notebooks/02.task2.ipynb)
```

Even though this is something very simple, I think it can be useful at work or if you are distributing a book as Jupyter notebooks and need to refer to a previous notebook/chapter. This way you are only one click away and don't need to llok for it!
