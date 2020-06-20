+++
title = "Put your bash code in functions"
date = "2020-06-16"
author = "Ricardo"
categories = ["bash"]
tags = ["bash", "scripting", "parallel"]
thumbnail = "img/social/bash_function.png"
+++
android-chrome-512x512

I wrote my degree dissertation in jupyter notebooks. Then I converted them to markdown and finally to pdf with pandoc. I also had to output an office file so that my tutor could work on it too. The initial code was:

```bash
#!/usr/bin/env bash


ProcessName="PDF Expert"
number=$(ps aux | grep -v grep | grep -ci "$ProcessName")
# echo $number
if [ "$number" -le 0 ]
then
    open -a 'PDF Expert'
fi
pandoc final.md \
    format.yaml \
    --filter pandoc-citeproc \
    --table-of-contents \
    --number-sections \
    --pdf-engine=xelatex \
    --indented-code-classes=python \
    --highlight-style=pygments \
    --template=./eisvogel2.tex \
    --listings \
    -o final.pdf
pandoc final.md \
    format.yaml \
    --filter pandoc-citeproc \
    --table-of-contents \
    --number-sections \
    --indented-code-classes=python \
    --highlight-style=pygments \
    --template=./eisvogel.tex \
    -V lang=es \
    -o final.docx

open final.pdf
```

This code does the following:

* check if PDF Expert is open, if not, open it.
* convert the merged (from many jupyter notebooks) markdown file to pdf.
* convert the merged markdown file to docx.
* open the created pdf file.

With PDF Expert not running first, the script takes more than 30 seconds to finish:

```
real	0m31.182s
user	0m20.514s
sys	0m1.821s
```

In this script I am doing different things that are independent of each other. This is the perfect opportunity to parallelize it. Luckily, by wrapping the different steps into bash functions it is easy to do it:

```bash
#!/usr/bin/env bash

function openapp () {
    ProcessName="PDF Expert"
    number=$(ps aux | grep -v grep | grep -ci "$ProcessName")
    # echo $number
    if [ "$number" -le 0 ]
    then
        open -a 'PDF Expert'
    fi
}

function makepdf () {
    pandoc final.md \
        format.yaml \
        --filter pandoc-citeproc \
        --table-of-contents \
        --number-sections \
        --pdf-engine=xelatex \
        --indented-code-classes=python \
        --highlight-style=pygments \
        --template=./eisvogel2.tex \
        --listings \
        -o final.pdf
}

function makedoc () {
    pandoc final.md \
        format.yaml \
        --filter pandoc-citeproc \
        --table-of-contents \
        --number-sections \
        --indented-code-classes=python \
        --highlight-style=pygments \
        --template=./eisvogel.tex \
        -V lang=es \
        -o final.docx
}

makepdf & makedoc & openapp
wait

open final.pdf
```

This code does the same as above, with the different steps wrapped into functions. Notice the line `makepdf & makedoc & openapp`. Here I am are running the 3 functions in parallel. The `wait` command does exactly that, waiting for the previous things to finish. When everything is done, the pdf file opens. Let's look at the timing now:

```
real	0m24.677s
user	0m21.669s
sys	0m1.746s
```

It is running ~27% faster. Only by wrapping the code in different functions.

As an extra, in bash the code is not evaluated all at once. If you edit a script while it is being executed, [the script behaves differently](https://thomask.sdf.org/blog/2019/11/09/take-care-editing-bash-scripts.html). Wrapping it in functions solves that problem too.