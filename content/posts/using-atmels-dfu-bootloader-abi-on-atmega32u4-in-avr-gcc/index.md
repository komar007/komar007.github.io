+++
title = "Using Atmel's DFU Bootloader ABI on ATMega32U4 in avr-gcc"
date = 2013-01-22
description = "adventures in assembly and C"
taxonomies.tags = ["imported", "electronics", "programming"]

[extra]
comment = true
+++
I've recently used Atmel's ATMega32u4 and I liked it a lot. 32 kilobytes of flash, USB transceiver
and bootloader support are the most important features of this rather inexpensive device, which make
it very easy to use for prototyping USB devices.

A nice addition is that the device comes preflashed with Atmel's DFU bootloader, which makes it
possible to program the device over USB without connecting SPI or JTAG. It doesn't support any
debugging, but it's good enough for simple projects.

I've been working on a project recently, where I assumed JTAG or SPI wouldn't be necessary and
decided to rely on the stock bootloader. The problem is, I needed to change the contents of the
flash memory in run-time. This is possible with the bootloader's ABI, but as it turned out, not that
easy.

# Understanding the bootloader

There's a lot of information available about writing bootloaders for these chips, the avr-libc even
has all the necessary routines implemented. But that's if you want to write your own bootloader.
What if you just don't want to? Why wouldn't you - one could ask. Well, at least because you don't
want to require the users of your device to program its bootloader with additional tools, which they
may not have, and because you don't want to program the bootloader for them, as this requires
additional headers on the board.

And that is just what I thought when I designed this board. No JTAG, no ISP, just USB, and I decided
to rely on Atmel's bootloader.

Strangely, I found absolutely nothing about the bootloader on the Internet, except for Atmel's
documentation, which is, to say the least, a bit misleading.

The last 3 days (shame to admit that...) I spent trying to make the bootloader save data to the
program memory during run-time (i.e. without the bootloader actually running and the device
enumerating as DFU), so I decided to share the conclusions here.

# The ABI

The starting point to understanding how to call the bootloader's functions is its source code. Atmel
provides the sources for bootloader's functions which are capable of programming flash and fuses in
runtime. The main reason I failed the first time I tried to use them is because I didn't read it,
trying to understand the documentation instead.

Atmel provides the documentation in [USB DFU Bootloader Datasheet
Complete](https://ww1.microchip.com/downloads/en/DeviceDoc/doc7618.pdf). Looking at "C Code Example"
doesn't help, since the functions are not gcc-compatible. Let's take a look at one of the functions
instead (original formatting):

``` asm
;*F**************************************************************************
; NAME: flash_prg_page
;----------------------------------------------------------------------------
; PARAMS: R18:17:R16: The byte address of the page
;----------------------------------------------------------------------------
; PURPOSE:  Launch the prog sequence of the target page
;****************************************************************************
flash_prg_page:
    RCALL WAIT_SPMEN ;Wait for SPMEN flag cleared
    MOV R31,R17
    MOV R30,R16 ;move adress to z pointer (R31=ZH R30=ZL)
    OUT RAMPZ, R18
    LDI R20,$05 ;(1<<PGWRT) + (1<<SPMEN))
    OUT SPMCSR,R20; argument 2 decides function (r18)
    SPM ;Store program memory
    RCALL WAIT_SPMEN ;Wait for SPMEN flag cleared
    RCALL flash_rww_enable
    RET
```

It takes its only parameter from three registers: `r18`, `r17` and `r16` and that is not the C
calling convention that avr-gcc has. Why Atmel claims this bootloader is C-compatible, I don't know,
since they are using gcc as part of Atmel Studio 6...

Anyway, according to gcc's documentation, registers `r2`-`r17` and `r28`-`r29` are call-saved, which
means that the compiler is assuming their values won't change when a function returns (with respect
to what they were before the call). Unfortunately, some of them (namely `r16` and `r17`) are used to
pass the argument, so we have to make sure to save them before and restore after the call.

To call this function from C, we'll need the following assembler inline:

``` c
int addr = 0xdeadbeef; /* function's address */
int arg = 0x112233; /* argument */
__asm__ __volatile__(
    "push r16"    "\n\t"
    "push r17"    "\n\t"
    "mov r18, %0" "\n\t"
    "mov r17, %1" "\n\t"
    "mov r16, %2" "\n\t"
    "call %3"     "\n\t"
    "pop r17"     "\n\t"
    "pop r16"     "\n\t"
    :
    : "r" (((arg) >> 16) & 0xff),
      "r" (((arg) >>  8) & 0xff),
      "r" (((arg) >>  0) & 0xff),
      "i" ((addr))
    : "r16", "r17", "r18", "r20", "r30", "r31"
);
```

This code saves `r16` and `17` on the stack and restores them later, because `flash_prg_page` is
going to destroy them. The clobber list contains all three argument-registers and all the other
registers which the bootloader is going to use. `r20`, `r30` and `r31` are call-used, but we still
have to declare them in the clobber list, since the compiler doesn't know there's a call - it's
inlined in assembler - so it doesn't know they're about to change!

# Where are the functions?

We know how to call the functions, but we also need their addresses. The bootloader's source code
says this:

``` asm
ASEG FLASH_END-0x0001B
entry_flash_page_erase_and_write:
   JMP flash_page_erase_and_write
entry_flash_read_sig:
   JMP  flash_read_sig
entry_flash_read_fuse:
   JMP  flash_read_fuse
entry_flash_fill_temp_buffer:
   JMP  flash_fill_temp_buffer
entry_flash_prg_page:
   JMP  flash_prg_page
entry_flash_page_erase:
   JMP  flash_page_erase_public
entry_lock_wr_bits:
   JMP  lock_wr_bits
```

The function table starts at `FLASH_END - 0x1B`, it would make sense if that was 28 bytes before the
end of flash, since there are 7 functions and that would mean 4 bytes per function, which is
correct - a jump instruction is 2 words long.

In `iom32u4.h` there is a macro named `FLASHEND` and it's defined to be `0x7FFF`, so it's the
address of the last byte of the flash memory. That means the last function, `lock_wr_bits`, is
located at `FLASHEND - 3`. And this means that the addresses of function calls should look like
this:

``` c
#define LAST_BOOT_ENTRY (FLASHEND - 3)

/* Addresses to bootloader ABI functions (in bytes) */
#define PAGE_ERASE_AND_WRITE_ADDR  (LAST_BOOT_ENTRY - 24)
#define READ_SIG_ADDR              (LAST_BOOT_ENTRY - 20)
#define READ_FUSE_ADDR             (LAST_BOOT_ENTRY - 16)
#define FILL_TEMP_BUFFER_ADDR      (LAST_BOOT_ENTRY - 12)
#define PRG_PAGE_ADDR              (LAST_BOOT_ENTRY - 8)
#define PAGE_ERASE_ADDR            (LAST_BOOT_ENTRY - 4)
#define LOCK_WR_BITS_ADDR          (LAST_BOOT_ENTRY - 0)
```

# atmel_bootloader library

I've decided to prepare macros to support all the functions and I ended up writing three: for
1-argument functions, for 1-argument functions which return a byte and for 2-argument functions.

For example the wrapper for a 1-argument function which returns a byte looks like this:

``` c
#define ATMEL_DFU_CALL_1ARG_RET(addr, arg) \
(__extension__({                           \
    uint8_t ret;                           \
    __asm__ __volatile__(                  \
        PUSH_REGS                          \
        "mov r18, %1" "\n\t"               \
        "mov r17, %2" "\n\t"               \
        "mov r16, %3" "\n\t"               \
        "call %4"     "\n\t"               \
        "mov %0, r16" "\n\t"               \
        POP_REGS                           \
        : "=r" (ret)                       \
        : "r" (((arg) >> 16) & 0xff),      \
          "r" (((arg) >>  8) & 0xff),      \
          "r" (((arg) >>  0) & 0xff),      \
          "i" ((addr))                     \
        : "r0", "r1", "r16", "r17", "r18", \
          "r20", "r30", "r31");            \
    ret;                                   \
}))
```

`PUSH_REGS` and `POP_REGS` are defined like this:

``` c
#define PUSH_REGS \
    "push r0"     "\n\t" \
    "push r1"     "\n\t" \
    "push r16"    "\n\t" \
    "push r17"    "\n\t" \

#define POP_REGS \
    "pop r17"     "\n\t" \
    "pop r16"     "\n\t" \
    "pop r1"      "\n\t" \
    "pop r0"      "\n\t" \
```

I also added `r0` and `r1`, because they are used in some of the bootloader's functions and they're
described as "Fixed registers", so gcc reads from them sometimes and I wouldn't like to overwrite
them.

In the end, calling a function like this is simple:

``` c
static inline uint8_t flash_read_fuse(uint32_t addr)
{
    return ATMEL_DFU_CALL_1ARG_RET(READ_FUSE_ADDR, addr);
}
```

I also added a couple of extra features: a function which counts the bootloader's size based on the
fuse bytes' values, a function which jumps to the bootloader, putting the device in DFU mode, and
one which writes a whole page to flash.

You can download the library from its [github
repository](https://github.com/komar007/atmel_bootloader).

----------------------------------------------------------------------------------------------------

# Archived comments

**Marcus Grant** — *June 12, 2015 at 2:29 pm*

> Great content! I'm working on my own mechanical keyboard using this chip and your information
> definitely helps. It's also very well presented.

----------------------------------------------------------------------------------------------------
