+++
title = "My way of handling PDFs in XMonad"
date = 2012-11-26
taxonomies.tags = ["imported", "xmonad", "programming", "dotfiles"]

[extra]
comment = true
+++
I read a lot of PDFs. In fact most of my time at the computer I spend reading PDFs. I read
documentation, datasheets and lots of school stuff, so this definitely requires a good choice of a
PDF reader.

Because I'm also a user of XMonad, just opening a PDF reader and reading a document is not what
satisfies me. I need a sensible way to organize opened documents and a quick way of opening just
downloaded files.

For the last couple of years I've been successfully using xpdf - the reader which remained my
favourite for a pretty long time. Unfortunately, recently gentoo dropped support for it, because of
its bugginess and stalled development (or no development at all:D), so after some time of providing
my own ebuilds, when it failed to start after a poppler upgrade, I decided to search for something
else.

# The choice of PDF reader

The requirements I have are:

- support for both continuous and non-continuous mode,
- easy zooming - including *fit page*, *fit width*,
- remote controllability - at least *reload* command (absolutely crucial for working with LaTeX),
- stability (well, xpdf is stable, but single-threaded, so it can simply hang for a minute while
  loading a complicated page and won't react at all... not acceptable).

There are also features which would be a nice addition, but not a requirement, like easy selection
and copy and those I couldn't care less about, like PDF forms support.

The program which attracted my attention was qpdfview
([<https://launchpad.net/qpdfview>](https://launchpad.net/qpdfview)). Most other readers were
driving me mad not supporting the really basic functionality which I can't live without.

So obviously it does all I need and also supports tabs and remote opening of new tabs in already
running window (see `--unique` commandline option).

# XMonad support

I currently have 3 workspaces in XMonad which I planned on using for documents, but ended using just
my web workspace for both the browser and instances of xpdf, so I decided to do something about it
and enhance my reading experience.

## Assumptions

The assumptions are simple: there are 3 workspaces (topics in fact, see [TopicSpace
documentation](https://xmonad.github.io/xmonad-docs/xmonad-contrib/XMonad-Actions-TopicSpace.html))
called pdf1, pdf2, pdf3. I want a default action which spawns the last downloaded PDF document on
the pdf workspace which I'm on. Since qpdfview supports tabs, this functionality should be used, and
each next spawn should open a new tab.

Why so complicated? Well, chrome can't seem to be so kind to allow the user to choose programs to
open particular types of downloaded documents with if you're not using a "supported desktop
environment", like firefox does. But even if it could do that, it would still suck. I want control
over what I open where, so rearranging documents after they're opened wouldn't be good enough. With
this approach I download a document, then go to the workspace where I want it and press mod-shift-p
and I have it. Simple and useful.

## Implementation

Finding the most recent pdf file is rather simple:

``` sh
ls --color=none -tr ~/Downloads/*.pdf | tail -n 1
```

There are other ways, though. Using `find` would probably be better, but who cares.

If you're already using TopicSpaces in XMonad, you can easily connect that command to the pdf
workspaces. I use the following data type to define my topics concisely in one place of the config
file (I took it from Brent Yorgey's config file in the [XMonad config file
archive](https://wiki.haskell.org/Xmonad/Config_archive)):

``` haskell
data TopicItem = TI { topicName :: Topic -- (22b)
                    , topicDir   :: Dir
                    , topicAction :: X () }
```

Then goes my topic list:

``` haskell
myTopics :: [TopicItem]
myTopics =
    [ ti "NSP"   ""
-- ...
    , TI "pdf1"  "~/Downloads"
        (runLastPdf)
    , TI "pdf2"  "~/Downloads"
        (runLastPdf)
    , TI "pdf3"  "~/Downloads"
        (runLastPdf)
-- ...
    ]
    where
        ti t d = TI t d shell
-- ...
        runLastPdf = spawnHere $ "qpdfview --unique \"`ls --color=none -tr ~/Downloads/*.pdf | tail -n 1`\""
-- ...
```

The `--unique` option causes qpdfview to register in dbus and the next invocations of this type will
open new tabs in the currently running window instead of opening a new one. Pretty neat.

# Modifying qpdfview

So far no matter on which pdf workspace I run the action, it will open the file in a single window.
But this can be better. Unfortunately qpdfview doesn't have multiple instances support, but I
decided to write it. Since it was rather a trivial task, I won't go into details. I made a branch in
the launchpad the functionality is already in trunk; it supports multiple named instances and
storing the list of opened tabs on a per-instance basis. It behaves exactly as the original program,
but it has one additional parameter.

The usage is simple:

Run a couple of instances:

``` sh
qpdfview --unique --instance pdf1 &
qpdfview --unique --instance pdf2 &
qpdfview --unique --instance pdf3 &
```

And then you can open new tabs in any of the instances, by specifying the instance name again:

``` sh
qpdfview --unique --instance pdf1 "file1.pdf" "file2.pdf"
qpdfview --unique --instance pdf2 "otherfile.pdf"
qpdfview --unique --instance pdf2 "onemorefile.pdf"
qpdfview --unique --instance pdf3 "somefile.pdf"
```

Now it's only a matter of using that in XMonad config. `runLastPdf` got an argument which specifies
which instance to use (instance names are the same as workspace names), and the config file changed
into this:

``` haskell
myTopics = -- ...
        , TI "pdf1"  "~/Downloads"
            (runLastPdf "pdf1")
        , TI "pdf2"  "~/Downloads"
            (runLastPdf "pdf2")
        , TI "pdf3"  "~/Downloads"
            (runLastPdf "pdf3")
    ]
    where
-- ...
        runLastPdf w = spawnHere $ "~/.xmonad/run_pdf.sh " ++ w
-- ...
```

I extracted the qpdfview logic into a separate file, for clarity, so here it is:

`run_pdf.sh`:

``` sh
#!/bin/bash

# usage: ./run_pdf.sh instance_name

f=`ls --color=none -tr ~/Downloads/*.pdf | tail -n 1`
qpdfview --unique --instance $1 "$f"
```

And now at last I feel comfortable with reading PDFs. Hopefully I won't change my mind soon. Too
much hassle.
