+++
title = "Single file applications"
date = "2020-11-03"
author = "Ricardo"
categories = ["python"]
tags = ["python", "api", "fastapi", "monolith"]
thumbnail = "img/social/building_ricardo_gomez_angel_unsplash.jpg"
+++

Storytelling is part of the human essence. Stories have let humans survive until today, they became the medium to move information between individuals.

Programming can be considered another form of moving information. With different levels of abstraction, programming becomes a medium to transfer information between humans and computers.

A programming paradigm mixing those two concepts is **literate programming**. According to its definition:

*Literate programming is a methodology that combines a programming language with a documentation language, thereby making programs more robust, more portable, more easily maintained, and arguably more fun to write than programs that are written only in a high-level language. The main idea is to treat a program as a piece of literature, addressed to human beings rather than to a computer.* [1]

When I read that definition I think *"Why are we not doing it this way?"*. I guess throughout the years, software engineering practices and the available tools have modelled the way to structure applications and libraries. However, similar tools could be created for literate programming when the language allows it. The best example right now is [nbdev](https://nbdev.fast.ai/). Many people argue this type of programming leads to worse engineering, but I've found the opposite. Writing documentation and tests can be easily left for later (maybe meaning less energy for it). With a literate programming environment you can do the 3 things at the same time.

However, even if you don't (or can't) use notebooks, I believe there are other methods to explore. One of those is writing everything in a single file. Yes, one single `.py` / `.php` / `.whatever` file. This means harder collaboration, but if you are on your own, it can work out for [apps](https://twitter.com/levelsio/status/1308145873843560449) or [libraries](https://github.com/piku/piku/blob/master/piku.py).

This had me thinking about other side benefits of the approach. Deployment and management becomes easier. Just one file (plus maybe the config) to copy around. You can also exploit this to practice literate programming, at least with documentation. That can leave you wondering, *"But how do you?"*:

**Find symbols.**

Ctrl/Cmd + F. Also, finding all the symbols in a single file can be faster than making the IDE traverse a tree of files and folders.
  
**Organize the app.**

I include comments with a specific pattern to separate sections like: `## ¡¡ settings`. With tools like [ripgrep](https://github.com/BurntSushi/ripgrep) inside the IDE, finding them is instant.
  
**Do literate programming.**

This is my favorite part. I structure the app like a book. The first part is usually the settings, then resource initialization, followed by utility functions, crud functions, views, etc. Everything in the app relies on something written above itself. Add comments into the mix as literate explanations of what you are doing. Now you have a file, probably with a few 1000s lines of code, that you can read top-to-bottom and understand everything that is going on. If you have a problem, the fix will be in, or above the line causing it.
  
The final folder layout of the app is somewhat easier to navigate. Many times I've found myself wanting to explore an open source app. Then I found 10s of files with a single class or function inside, making it hard to understand everything fast.

Example organization of a simple CRUD app:

```
├── Dockerfile
├── Taskfile
├── app
│   ├── __init__.py
│   ├── api_v1.py
|   ├── cli.py
|   ├── config.py
|   ├── crud.py
|   ├── db.py
|   ├── deps.py
|   ├── documentation
|   ...
|   │   ├── index.html
|   ...
|   ├── download_assets.py
|   ├── exceptions.py
|   ├── files
|   │   ├── stuff.json
|   ...
|   ├── forms.py
|   ├── utils.py
|   ├── loggers.py
|   ├── main.py
|   ├── resources.py
|   ├── schemas.py
|   ├── security.py
|   ├── static
|   ...
|   ├── templates
|   │   ├── base.html
|   │   ├── contact.html
|   ...
|   ├── tests
|   │   ├── conftest.py
|   ...
|   ├── utils.py
|   └── views.py
├── docker-compose.yml
├── gunicorn_conf.py
├── requirements
│   ├── dev.txt
│   └── main.txt
...
```

Same app in a single file. All the resources (html templates, js files, images, etc.) live in the `files` folder.

```
├── Dockerfile (also simpler than the one above)
├── Taskfile
├── deploy.sh
├── docker-compose.yaml
├── files
├── gunicorn_conf.py
├── main.py
├── requirements
│   ├── dev.txt
│   └── main.txt
...
```

This form of programming also has downsides like faster namespace pollution. The good thing is that separating part of the code to an external file is easier than merging multiple files together.

An example of structure for this kind of app can be found [here](https://gist.github.com/polyrand/501d76cae0c06d5ba275183e93636127).


## Sources:

* [1] https://www-cs-faculty.stanford.edu/~knuth/lp.html