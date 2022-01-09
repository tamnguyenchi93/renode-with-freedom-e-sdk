# Renode with freedom-e-sdk
## Where to find
- Target: [HiFive1](https://www.sifive.com/boards/hifive1)
- Github freedom-e-sdk: https://github.com/sifive/freedom-e-sdk
- Renode: https://github.com/renode/renode
- RiscV toolchain: https://five-embeddev.com/quickref/tools.html
  - GNU RISC-V Embedded GCC.
    - https://github.com/riscv-collab/riscv-gnu-toolchain/releases
  - SiFive Freedom Tools GCC Releases
    - https://github.com/sifive/freedom-tools/releases

## Setup
- Clone freedom-e-sdk
```bash
$ git clone --recursive https://github.com/sifive/freedom-e-sdk.git
```
- Download toolchain
```bash
$ mkdir -p toolchain/sifive_gcc
$ wget -c https://static.dev.sifive.com/dev-tools/freedom-tools/v2020.12/riscv64-unknown-elf-toolchain-10.2.0-2020.12.8-x86_64-linux-ubuntu14.tar.gz -O - | tar -xz -C toolchain/sifive_gcc --strip-components 1
$ export RISCV_PATH=`pwd`/toolchain/sifive_gcc
```
## Hello world with renode
- Build Hello world sample
```
$ cd freedom-e-sdk
$ make PROGRAM=hello TARGET=sifive-hifive1 CONFIGURATION=debug software
```
- Test with renode
```bash
$ cd renode-with-freedom-e-sdk
$ renode
```
- From Renode console type
```
# s @sifive_fe310.resc
```
- Test with other application:
  - `uart-interrupt`
  - `sifive-welcome`
```bash
$ make PROGRAM=uart-interrupt TARGET=sifive-hifive1 CONFIGURATION=debug software
$ make PROGRAM=sifive-welcome TARGET=sifive-hifive1 CONFIGURATION=debug software
```

## Cross debug with Renode
- Sample `sifive-welcome`
- Build **sifive-welcome**
```bash
$ cd freedom-e-sdk
$ make PROGRAM=sifive-welcome TARGET=sifive-hifive1 CONFIGURATION=debug software
```
- Create new renode script
```
$ copy sifive_fe310.resc sifive_fe310_gdb.resc
```
- Change binary file to `$bin?=@freedom-e-sdk/software/sifive-welcome/debug/sifive-welcome.elf`
- Add  to the end of file as the tutorial: 
[Debugging with GDB](https://renode.readthedocs.io/en/latest/debugging/gdb.html#debugging-with-gdb)
```
machine StartGdbServer 3333
```
- Start renode and load resc file with command in renode console
```
(monitor) i @sifive_fe310_gdb.resc
```

- Export riscv path to $PATH
```bash
$ export PATH=$RISCV_PATH/bin:$PATH
```
- Start cross debug
```bash
renode-with-freedom-e-sdk/freedom-e-sdk$ riscv64-unknown-elf-gdb software/sifive-welcome/debug/sifive-welcome.elf
GNU gdb (SiFive GDB-Metal 10.1.0-2020.12.7) 10.1
Copyright (C) 2020 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
Type "show copying" and "show warranty" for details.
This GDB was configured as "--host=x86_64-linux-gnu --target=riscv64-unknown-elf".
Type "show configuration" for configuration details.
For bug reporting instructions, please see:
<https://github.com/sifive/freedom-tools/issues>.
Find the GDB manual and other documentation resources online at:
    <http://www.gnu.org/software/gdb/documentation/>.

For help, type "help".
Type "apropos word" to search for commands related to "word"...
Reading symbols from software/sifive-welcome/debug/sifive-welcome.elf...
(gdb) target remote localhost:3333
Remote debugging using localhost:3333
_enter () at /home/nctam/renode_ws/renode-with-freedom-e-sdk/freedom-e-sdk/freedom-metal/src/entry.S:31
31          la gp, __global_pointer$
(gdb) monitor start
(gdb) b main
(gdb) c
```

## FreeRTOS 
- Create Standlone workspace for FreeRTOS:
```bash
$ cd freedom-e-sdk
$ make PROGRAM=example-freertos-minimal TARGET=sifive-hifive1 LINK_TARGET=freertos INCLUDE_METAL_SOURCES=1 STANDALONE_DEST=../standalone-freertos-minimal standalone
```
- Compile freeRTOS source
```bash
$ cd ../standalone-freertos-minimal
$ make
```
- Start Renode
```bash
(monitor) s @sifive_fe310_freertos_gdb.resc
```

## Testing with Renode
- Run Renode robot framework with `renode-test` command
```
$ renode-test SiFive-FE310.robot
```