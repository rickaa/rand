+++
title = "Fixing a bug in the Haskell installer"
date = "2020-01-16"
author = "Ricardo Ander-Egg Aguilar"
categories = ["open source", "haskell", "bugs"]
tags = ["haskell", "ghcup", "open source", "git", "gitlab", "github"]
+++


The story of a bug fix. I found a bug in the default Haskell installer [ghcup](https://gitlab.haskell.org/haskell/ghcup), fixed it in my computer and had the fix merged to the public installer.
<!--more-->

I started doing the MIT course [Programming with Categories](http://brendanfong.com/programmingcats.html), so I had to install Haskell on my computer. But following the recommended method kept throwing me an error: `mktemp: too few X's in template ‘ghcup’`. After some time searching I could only find 1 discussion where someone had had a similar problem.

After learning a bit about [mktemp](https://www.gnu.org/software/coreutils/manual/html_node/mktemp-invocation.html) and digging into the installer [script](https://gitlab.haskell.org/haskell/ghcup/blob/master/ghcup), I discovered that different versions of mktemp had different behaviors. In my case I had two installed, the one coming by default with macOS, placed in `/usr/bin` and a different one installed by brew when installing [coreutils](https://formulae.brew.sh/formula/coreutils). 

I modified the installer script like so:

`mktemp -d -t ghcup` => `mktemp -d -t ghcup.XXXXXXX`

Everything suddenly worked. I opened an issue and a [pull request in the ghcup repository](https://gitlab.haskell.org/haskell/ghcup/merge_requests/137), and a few hours later it was merged!

The only problem we could think of was breaking the installer for other macOS / OS X versions, and that's something I also asked myself at first.

My guess is that "ghcup.XXXXXXX" would be evaluated as a string anyway, the same way "ghcup" alone is evaluated. I'm currently not planning to upgrade to the latest macOS version, so I couldn't test it with macOS Catalina or with older versions. I made some tests on my computer though:

Using **native** mktemp, the one that comes with macOS (`/usr/bin/mktemp`):

* `/usr/bin/mktemp -d -t ghcup.XXXX` creates a folder named: *ghcup.XXXX.r2OBbQRF*

* `/usr/bin/mktemp -d -t ghcupXXXX` (without the dot) creates a folder named: *ghcupXXXX.wEPBMrGh*

* `/usr/bin/mktemp -d -t ghcup` (the one that runs in macOS **without** coreutils installed) creates a folder named: *ghcup.8fAcY5LC*

Using **coreutils** (GNU) mktemp v. 8.31, the default one in my computer, installed with homebrew (`/usr/local/opt/coreutils/libexec/gnubin/mktemp`):

* `mktemp -d -t ghcup.XXXX` creates a folder named: *ghcup.7Gwj*

* `mktemp -d -t ghcup.XXXX` (without the dot) creates a folder named: *ghcup3jJS*

* `mktemp -d -t ghcup`(the one throwing the error) returns: *mktemp: too few X's in template ‘ghcup’*

After the merge I tried installing Haskell with the default installation [method/command](https://www.haskell.org/ghcup/) and boom 💥, everything worked smoothly. 

I know this is a very subtle bug that did not require extensive research for months to fix, but maybe someone else had, could, or will run into the same problem; and thinking that this could be the fix for it makes me feel fantastic 😄.
