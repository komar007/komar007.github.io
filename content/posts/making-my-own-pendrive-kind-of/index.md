+++
title = "Making my own pendrive (kind of)"
date = 2013-06-19
taxonomies.tags = ["imported", "electronics", "hack"]

[extra]
comment = true
+++
This time not about electrical design, electronics or programming!

<!-- more -->

I had a pendrive which I didn't need at all, and because I found it really ugly I decided to remove
all the unnecessary parts to strip it down to the PCB and possibly reduce the size. The device I'm
talking about is a Kingston DT108 8GB flash drive. And here's what I found when I broke it apart:

[![Kingston DT108](pen_thumb.jpg "Kingston DT108")](pen.jpg)
[![parts](parts_thumb.jpg "parts")](parts.jpg) [![Toshiba
chip](chip_thumb.jpg "Toshiba chip")](chip.jpg) [![chip2](chip2_thumb.jpg "chip2")](chip2.jpg)

The most interesting thing about this pendrive is the Toshiba THNU38N00PH07 chip which is in fact an
integrated USB flash disk (it's called UDP flash chip). Everything else is just junk. When I
realized I could have such a small pendrive, the first thing I did was to connect it to a USB port,
but it was too slim and fell out. I measured the plastic case it was sitting in and it's 0.8mm
thick. If 0.8mm doesn't ring a bell, think about 0.030" — that's close enough and it's the thickness
of a standard [ISO/IEC 7810](https://en.wikipedia.org/wiki/ISO/IEC_7810) plastic card. This also
explains the presence of such a card in all the photos above.

# Building the pendrive

So I cut out a rectangular piece of the card to glue it to the chip. Then I trimmed it to the right
size very carefully. I attempted it two times and got a sensible result at the second attempt. For
cutting and grinding I used my Proxxon FBS 240/E drill set to the lowest RPM not to melt the plastic
and one of the standard cutting disks which came with it.

[![plastic](plastic_thumb.jpg "plastic")](plastic.jpg)
[![plastic2](plastic2_thumb.jpg "plastic2")](plastic2.jpg)
[![plastic3](plastic3_thumb.jpg "plastic3")](plastic3.jpg)
[![plastic4](plastic4_thumb.jpg "plastic4")](plastic4.jpg)

The final thing to do was to glue the two pieces together. I used glue for hard plastics by UHU.
Gluing wasn't hard, I applied a drop of the glue, joined the pieces together, removed the excess
glue and put the whole thing into a vice for a couple of minutes. I wanted to avoid using superglue
because it leaves very bad looking stains on everything and I wouldn't have had enough time to align
the two surfaces with required precision. So far everything seems all right, but I'll see how the
connection behaves in time.

[![glued](glued_thumb.jpg "glued")](glued.jpg) [![glued2](glued2_thumb.jpg "glued2")](glued2.jpg)

After gluing I went ahead and finished the surface first with 600 grit and then 1200 grit sandpaper
and cleaned the device thoroughly. Here are some photos of the finished work.

[![final2](final2_thumb.jpg "final2")](final2.jpg)
[![final1](final1_thumb.jpg "final1")](final1.jpg) [![final](final_thumb.jpg "final")](final.jpg)
[![final4](final4_thumb.jpg "final4")](final4.jpg)

[![final3](final3_thumb.jpg "final3")](final3.jpg)
[![final6](final6_thumb.jpg "final6")](final6.jpg)
[![final5](final5_thumb.jpg "final5")](final5.jpg)
[![final7](final7_thumb.jpg "final7")](final7.jpg)

The final dimensions are 24.8 × 11.3 × 2.2mm and it weighs less than 2 grams.

Well, as you can see, I didn't actually *make* a pendrive. Not that it's a problem with the
availability of memory and microcontroller chips these days, but making something this small at home
may be hard. Fortunately, you can use existing devices to make what you want with little effort.

----------------------------------------------------------------------------------------------------

# Archived comments

*Below are the comments imported from the previous wordpress blog*

**Raja Islam** — *November 18, 2013 at 11:13 am*

> Thanks mate its helpful.

**mobile** — *March 27, 2014 at 11:34 am*

> Posts like this brighten up my day. Thanks for taking the time.

**Vivek** — *November 17, 2014 at 2:11 am*

> where can i buy this "UDP flash chip" ? Can anyone suggest ??

<div style="padding-left: 4em;">

**komar** — *November 17, 2014 at 9:12 am*

> You can try Alibaba and Aliexpress

</div>

**sen** — *March 15, 2015 at 2:55 am*

> I have lot of broken mouth SanDisk cruzer blade pendrive which can be retrofitted this method,
> thanks buddy;);););););)

**Akshay sharma** — *September 25, 2015 at 4:31 pm*

> OH!!! NICE IDEA I HAD ALSO CONSTRUCTED THE SAME IN MY HOME TOO

**hugo** — *February 7, 2016 at 6:08 am*

> The USB didn´t had reconize for several PC, aparently don´t have a phisical damage, someone have
> an idea to solve this problem

----------------------------------------------------------------------------------------------------
