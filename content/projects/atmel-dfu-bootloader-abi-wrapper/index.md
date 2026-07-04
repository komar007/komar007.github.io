+++
title = "Atmel DFU Bootloader ABI wrapper"
weight = 10
date = 2013-02-01

[extra]
local_image = "atmel-dfu-bootloader-abi-wrapper/cover.png"
github = "https://github.com/komar007/atmel_bootloader"
comment = true
+++
# What it is

This project consists of one header file and one source file and it includes wrapper functions which
allow to access the flash and fuse-bit programming functions in the stock bootloader on some of the
Atmel's USB-enabled AVR chips. It also provides a convenient function which writes a whole page to
the flash memory.

# Why I wrote it

While developing my mechanical keyboard project, the GH60, I came across the need to program the
flash memory during runtime. The avr-gcc compiler has the necessary headers to write your own
bootloader code, which would allow me to achieve exactly what I needed, but since the chip I was
using (ATmega32u4) already had a stock bootloader, I wanted to use it instead.

Unfortunately, I couldn't find any libraries to use the functions it provided, so I decided to write
my own.

Check out the [original
article](../../posts/using-atmels-dfu-bootloader-abi-on-atmega32u4-in-avr-gcc/), where I describe
how it works.

# Using

The library provides static inlines for all the bootloader's functions:

``` c
static inline void flash_page_erase_and_write(uint32_t addr);
static inline uint8_t flash_read_sig(uint32_t addr);
static inline uint8_t flash_read_fuse(uint32_t addr);
static inline void flash_fill_temp_buffer(uint16_t data, uint16_t addr);
static inline void flash_prg_page(uint32_t addr);
static inline void flash_page_erase(uint32_t addr);
static inline void flash_lock_wr_bits(uint8_t bits);
```

The meaning of arguments should be self-explanatory. Further documentation can be found in Atmel's
[datasheet](https://ww1.microchip.com/downloads/en/DeviceDoc/doc7618.pdf).

Except for those functions, there are two higher-level functions:

``` c
static inline void run_bootloader();
void flash_write_page(uint32_t addr, const uint8_t *data);
```

The first one performs a jump to the bootloader section and gets the chip into DFU mode and the
second one writes a whole flash page (at address `addr`) with provided data.

# Compatibility

The code was tested on the following devices:

- ATmega32u4,
- ATmega32u2.

It should also work on the those chips, though compatibility hasn't been verified:

- ATmega16u4,
- ATmega8u4,
- ATmega16u2,
- ATmega8u2,
- AT90USB128x,
- AT90USB64x,
- AT90USB162,
- AT90USB82.

If you have successfully run the code on any of those devices or made modifications which allowed it
to run, please let me know in the comments.

# Download

You can download the files from my [github
repository](https://github.com/komar007/atmel_bootloader).

----------------------------------------------------------------------------------------------------

# Archived comments

**Alex** — *October 28, 2014 at 2:35 pm*

> Hi,
>
> Slightly off topic question. Do you know if it is feasible to do the oposite, wire/configure the
> Atmel to not allow flashing unless physical switch is pressed?
>
> Thanks, Alx

<div class="reply">

**komar** — *October 30, 2014 at 12:09 pm*

> Hi Alex,
>
> normally the atmega32u4 will run the bootloader only when reset while the HWB is low. So you can
> connect HWB to ground through a switch and then you can run the bootloader if you press this
> button, hold it and then reset (probably by pressing another button).
>
> Except for that, you can disable the bootloader by disabling the HWBE fuse bit or even remove the
> bootloader code completely while programming via SPI.

</div>

**Gabriel F.** — *August 24, 2015 at 5:01 pm*

> Nice!

**Tilak Marupilla** — *June 2, 2018 at 7:00 am*

> Hi,
>
> Can I know if it works for ATmega 8A PU ?

----------------------------------------------------------------------------------------------------
