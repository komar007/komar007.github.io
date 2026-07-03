+++
title = "Introducing the GH60 keyboard project"
date = 2013-01-23
taxonomies.tags = ["imported", "keyboards", "electronics", "gh60"]

[extra]
comment = true
+++
The GH60, a 60% mechanical keyboard project, will soon be ready for production. In this post I'm
going to present what it is and for whom it is.

<!-- more -->

The idea was first proposed by jdcarpe @ [geekhack](http://geekhack.org). It was to design a
portable, fully programmable mechanical keyboard, which fits cases available in the mechanical
keyboard market.

# Project assumptions

The basic assumptions were:

- 60% form-factor - that means the keyboard is limited to the block of keys from tilde to right
  control; no arrows, numpad, page up/down or F keys,
- persistent, programmable layout - it had to allow for easy changing of which scancode each key
  sends,
- compatible with existing cases: KBC Poker plastic case and other custom Poker cases,
- support for both ISO and ANSI, making it the first ISO 60% mechanical keyboard,
- support for both PCB- and plate-mounted Cherry MX switches.

The GH60 is not a complete keyboard for an end-user, but a so-called custom keyboard, which means
that its users will only get the PCB populated with all the SMD components, but will have to solder
the switches themselves. A switch assembly service will be provided and two custom aluminum cases
are already being designed by other geekhack members WildFireDragon and The_Beast.

After a long discussion and getting a number of propositions concerning the available layouts, I got
down to designing the first revision of the PCB.

# Physical layout

The revision A includes support for a few layouts by providing a non-configurable base set of keys
along with 4 configurable clusters. In each of the clusters the keys can be arranged in 2 or more
ways to fit the user's needs.

The clusters are shown in the picture and listed below:

[![ghlays](ghlays_invertible__thumb_1012x.png "ghlays")](ghlays_invertible_.png)

- enter - the enter cluster can be configured in 3 ways:
  - standard ANSI - 2¼-unit enter and 1½-unit backslash,
  - modified ANSI - 1¼-unit enter and one extra key to the left from enter,
  - standard ISO - vertical enter and 1-unit hash,
- left shift - the left shift cluster can be configured in 2 ways:
  - ANSI - 2¼-unit shift,
  - ISO - 1¼-unit shift and 1-unit backslash,
- right shift - the right shift cluster can be configured in 3 ways:
  - standard - 2¾-unit shift,
  - with fn key - 1¾-unit shift and 1-unit fn-key to the right from shift,
  - with extra key - 1¾-unit shift and 1-unit extra key to the left from shift,
- bottom row - the bottom row cluster can be configured in 3 ways:
  - modern - three 1¼-unit modifiers, 6¼-unit spacebar, four 1¼-unit modifiers,
  - retro (aka Model M) - 1½-1-1½ modifier layout on both sides of a 7-unit spacebar,
  - lysol's layout - an interesting idea proposed by lysol @ geekhack - two 1½-unit modifiers,
    7-unit spacebar, and 1½-1-1-1½ modifier layout to the right from spacebar.

The key names, like *enter* or *fn* are for illustrative purposes only, since they can be assigned
arbitrary functions. In the final version I'm also considering adding an option to split the
backspace into two 1-unit keys.

# The prototype

The prototype was produced with the help of 16 people who decided to buy the PCB and test it. I had
the revision A of the PCB made with black matte soldermask and gold-plating.

<figure>

[![PCB front (switches side)](revA_front_thumb.jpg "PCB front (switches side)")](revA_front.jpg)

<figcaption class="fig-plain">PCB front (switches side)</figcaption>
</figure>
<figure>

[![PCB back (controller side)](revA_back_thumb.jpg "PCB back (controller side)")](revA_back.jpg)

<figcaption class="fig-plain">PCB back (controller side)</figcaption>
</figure>

We discovered a few errors in the prototype, and I'm going to fix them in the final version:

- one part, C3, is positioned wrong, which prevents the PCB from fitting into the original Poker
  case,
- some people reported that rotated cherry switches make it hard to put the keycaps on and may even
  break their stems, I will try to put as many switches without rotations as possible,
- there is no silkscreen indication of caps-lock LED polarity,
- other minor dimension problems: some holes are too close to the edges, the USB connector is
  slightly off-center.

The first built prototype looks like this:

[![First prototype](P1140964_thumb_1000x.jpg "First prototype")](P1140964.jpg)

# What next

We are currently ending the testing phase. The first round groupbuy will start shortly. Except for
the fully assembled PCB we are going to have a number of stainless steel plate layouts made and
possibly an aluminum case.

# Download

You can download the schematic, PCB renders and gerber files of the revision A PCB (prototype) here:
[gh60_reva](gh60_reva.zip) (the license is CC BY-SA 3.0)

There is also a [repository with all the CAD files](https://github.com/komar007/gh60).

# Further reading

You can read more about the project on the [GH60 project
page](../projects/gh60-programmable-keyboard).

----------------------------------------------------------------------------------------------------

# Archived comments

**HuyNX** — *June 6, 2013 at 10:26 am*

> Hi, Iam very interest with GH60 keyboard, thanks you I can't open (import) cad file with Altium
> Designer Summer 09, what is cad software you use?
>
> Thanks

<div style="padding-left: 4em;">

**komar** — *June 19, 2013 at 4:20 pm*

> Thanks for your feedback. It was made in a recent build of kicad. This version can be most
> probably obtained here: [Re: \[Prototyping\] GH60
> Keyboard](http://geekhack.org/index.php?topic=34959.msg809187#msg809187)

</div>

----------------------------------------------------------------------------------------------------
