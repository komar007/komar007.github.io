+++
title = "GH60 rev. C \"plain edition\" is out"
date = 2016-05-02
taxonomies.tags = ["imported", "electronics", "keyboards", "kicad", "gh60"]
description = "The latest edition of my 60% keyboard PCB design is released"

[extra]
comment = true
+++
I've been getting many questions concerning the files for the latest revision of
[GH60](http://gh60.info).

It took me a while to convert the KiCad files to the new version and do some final touches, but I
hope it was worth the wait!

[![PCB front](pcb_front_thumb.jpg "PCB front")](pcb_front.jpg) [![PCB
back](pcb_back_thumb.jpg "PCB back")](pcb_back.jpg)

All the development files are now available in the github repository
[komar007/gh60](https://github.com/komar007/gh60) (the name has changed, but your existing clones
will still work with the old one). The files are licensed under
[CC-BY-SA](https://creativecommons.org/licenses/by-sa/3.0/) (which you can see in the PCB artwork).

And here you can download all the production files in one zip package:
[gh60_revC_plain](gh60_revC_plain.zip). Please be advised that the files come with no warranty, and
I will take no responsibility for any loss which can be a result of a potential error in those
files.

# So what's the "plain edition" thing?

As you can see, the boards available through the geekhack group buy and from
[techkeys.us](http://techkeys.us) (USA) and [falbatech.pl](http://falbatech.pl) (Europe) contain the
geekhack community logo.

This logo is not present in the Creative Commons version just released. This is because the logo was
designed by a member of [geekhack.org](http://geekhack.org) and we believe its use should be limited
to approved vendors.

That's why the files for rev. C released publicly contain a different, more generic logo. The rest
of the board is, however, exactly the same. In particular, it does not differ electrically from the
GB PCB at all.

----------------------------------------------------------------------------------------------------

# Archived comments

**Joshua Herrin** — *September 30, 2016 at 11:48 pm*

> Has there been any update on the add-on daughter board for LED control?

**Ur Brother** — *November 3, 2016 at 4:32 pm*

> Hey komar, my man.. listen, how's that keyboard tutorial coming out tho'? i kinda need to build a
> cheap keyboard asap and need ur help.

<div style="padding-left: 4em;">

**komar** — *November 23, 2016 at 8:59 pm*

> I'm still hoping it will come out:D
>
> Thanks for your interest,
>
> Michał

</div>

**Minh Dang** — *November 30, 2016 at 2:35 pm*

> Hi komar,
>
> a few days ago I ordered a GH60 Rev C from Falbatech.pl and I have question about placing the
> little LED's inside the switches. I'm planning to do a SIP Socket Mod for easy LED Replacement but
> in order to do that the Pin Socket Strips need to be soldered into these little small holes close
> to other ones for the Mechanical Switches. On Geekhack & Reddit Forum Users are saying it's not
> possible to use the whole Keyboard with LED and I would have to get an "extension". I'm not
> intending to put a LED Strip on the backside of the PCB. I just want my keys to be illuminated. I
> hope you can help out me here since my board is going to arrive soon.
>
> Best Regards<br> M. Dang

<div style="padding-left: 4em;">

**komar** — *January 14, 2017 at 9:57 pm*

> Hi Minh,
>
> I am not sure about the SIP socket mod, but there is no support for illuminating LEDs on all keys
> in GH60, the people you talked to are right. There is an expansion connector which makes it
> possible to connect an external module which will enable the LEDs in keys though, but that module
> is not available yet.
>
> Best regards,<br> Michał

</div>

**Vince** — *February 24, 2017 at 3:08 am*

> Hey Komar! This is indeed a great PCB! I'm ordering a few for my store, I was wondering what the
> locations are for the four mounting holes XY coordinates. I'm using swillkb builder.
>
> Thanks, Vince

**Chris** — *May 13, 2017 at 12:22 am*

> Hey Komar
>
> I'm trying to add a numpad to the GH60. I see where I can extend the rows but how do I know which
> pins I can use from the expansion area for columns?

**Flint** — *September 9, 2017 at 6:41 am*

> Hey Komar,
>
> Thank you so much for the contribution to the community.
>
> How's the led driver module going?
>
> I just ordered a GH60 PCB and I have plans to make a board with individual PWM dimming LEDs for
> each switch.
>
> However, I do have some hoops to jump through, and your input would be a tremendous help. Right
> now the LED driver I have is Adafruit Charlieplex 9x16 led driver. I wish I could find an LED
> matrix with individual PWM dimming that has enough pins that is not Charlieplex, which would save
> me a lot of rewiring, but not sure how. I can deal with Charlieplex by rewiring the board,
>
> For those who are not familiar with Charlieplexing, it is basically a way to wire an LED matrix
> such that n pins can control n(n-1) LEDs individually.
>
> Then it got me thinking, maybe we could just change the PCB to Charlieplexing, and use this LED
> driver chip directly. And since there are 9x16 spots, we can even have dual color! On a second
> thought though dual colored LEDs may be harder to come by, not to say in my preferred color
> combination (white and orange). And squeezing two 2x3x4 LEDs into the switch slot probably
> requires a lot of dremeling. So in the end I am not sure if this is worth the effort to re-arrange
> the LED matrix. Not to mention the added complexity with Charlieplexing, which may confuse a lot
> of people, and limit the choice of LED drivers.
>
> However, maybe, just maybe, there is a third solution, that is to make Charlieplexing optional,
> but easily achievable by cutting a few wires, and a few dabs of solder here and there. Which would
> get the best of both worlds.
>
> I am really tempted and excited to jump in to PCB design with both feet. I reckon this would be a
> huge time commitment, but I think I can handle the learning curve. But before I start, I would
> like your input, is it even worth doing?
>
> Kind regards,<br> Flint

----------------------------------------------------------------------------------------------------
