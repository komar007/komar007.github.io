+++
title = "Logged in through ssh?"
date = 2013-03-28
description = "a hacky way of checking if a shell was spawned by the SSH daemon"
taxonomies.tags = ["imported", "hack"]

[extra]
comment = true
+++
I've recently come across a problem where I have to check (using bash scripting) whether I am logged
in remotely (through ssh, since I only use ssh for that purpose) or locally. This is particularly
useful if you have many machines with the same color scheme of bash prompt (and you want to keep it
that way), but work on all of them from your local computer.

In this post I'm going to show you how I decided to modify the bash prompt so that I'm sure whether
I'm working locally or remotely.

> [!TIP]
> Apparently I wasn't aware of the existence of `SSH_CONNECTION` when writing this post. From
> [ssh(1)](https://man7.org/linux/man-pages/man1/ssh.1.html#ENVIRONMENT):
>
> > <dl>
> >   <dt>SSH_CONNECTION</dt>
> >   <dd>
> >     Identifies the client and server ends of the connection. The variable contains four
> >     space-separated values: client IP address, client port  number, server IP address, and
> >     server port number.
> >   </dd>
> > </dl>
>
> I guess this makes the post obsolete.

# Using the proc filesystem

One of the ways of solving this problem I found somewhere on the Internet is to check the parent
process of the current shell. The process id of the parent process is available in the `PPID`
variable. Getting this process' name is as simple as:

``` sh
head -n 1 /proc/$PPID/status
```

Now to test if this process is `sshd` (which will be the case if the user logged in using ssh), we
can use:

``` sh
[ "`head -n 1 /proc/$PPID/status | cut -f 2`" == sshd ] && echo ssh
```

However, this approach has one major flaw. The fact that the user logged in using ssh does not imply
that the parent process of the shell is `sshd`. I noticed that when my approach stopped working at
some point, namely:

``` sh
$ su
Password:
# head -n 1 /proc/$PPID/status
Name:   su
```

So using `su` to change to a different user or even working on screen will break this method.

# Second approach: use who

`who` is a little program which shows who's logged in. I noticed that who behaves differently when
issued locally and remotely. For example when I'm logged in locally I get:

``` sh
$ who
komar    tty1         2013-03-22 11:34
```

But for remote logins:

``` sh
$ who
komar    pts/1        Mar 28 11:42 (ip38:S.0)
```

It appears it is not necessary to extract the hostname information from this output, since who has a
very useful option, which I think is a bit misdocumented, namely `-m`. The manpage for who claims
that it outputs only hostname and user associated with `stdin`, whereas what it does is it filters
out all login information for non-remote logins, if that sounds sensible. Anyway, what I observed is
that `who -m` will output a line for remote logins and nothing for local logins, and so far it's
worked very well, whether I was using `su` or `screen` or not. This simplified my test to something
like this:

``` sh
[ -n "`who -m`" ] && echo ssh
```

# Modifying the bash prompt

Now I could use the variable `PS1` to make sure I know how I'm logged in at any time. I just added
the following line to `/etc/bash/bashrc` (alternatively you can do this for just one user, by
modifying `~/.bashrc`):

``` sh
PS1="\033[1;33m"$([ -n "`who -m`" ] && echo "(ssh) ")$PS1
```

And that's it.

----------------------------------------------------------------------------------------------------
