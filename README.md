# Hornet RISC-V Core
Hornet is a simple, fully open-source, FPGA-proven 32-bit RISC-V core.

## Highlights
* RV32IM instructions
* Machine mode support
* 5-stage pipelined microarchitecture
* Misaligned access support
* FPGA proven

In this repo, in addition to the core itself, you can also find supporting peripherals, software and SoC examples to help you get started.

We also provide a reference manual that explains how the core is designed and how it works, in detail; and a user guide that describes how
you can use the core.

|<span style="font-size:1.5em;">Simplified Pipeline Diagram</span>
|:---:
|![Simplified Pipeline Diagram](/simplified_pipeline.png) |

# Set-up Hornet
This set-up contains build of toolchain, Hornet Core and simulation of bubble_sort.c file which can be found in /test/bubble_sort directory. Also the waveforms can be observed through GTKWave by this way, simulation and debugging of .c source files can be done.

## Install Toolchain
#### Install main prerequisites: 
~~~
sudo apt install autoconf automake autotools-dev curl python3 python3-pip libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build git cmake libglib2.0-dev
~~~

#### Install additional prerequisites: 
~~~
sudo apt install python-is-python3 expect device-tree-compiler libglib2.0-dev pip
~~~

#### Clone
~~~
cd ~/Downloads
git clone https://github.com/riscv-collab/riscv-gnu-toolchain
~~~

#### Configure
~~~
cd riscv-gnu-toolchain
./configure --prefix=`pwd`/installed-tools --with-multilib-generator="rv32gc-ilp32d--;rv32i-ilp32--"
~~~

#### Build
~~~
make 2>&1 | tee build.log
~~~

#### If python can't be found below code should be tried
~~~
# Install python 2
sudo apt install python
# Make python refer to python3
sudo apt install python-is-python3
~~~

#### If python case is done, then make is needed again
~~~
# Prepare for a clean build
make distclean
sudo rm -rf <prefix-dir-specified-at-configure-time>
# Configure and make
./configure --prefix=... --with-multilib-generator="..."
make 2>&1 | tee build.log
~~~

#### After make, toolchain directory should be added to path. It can be done by opening .bashrc folder in home directory then pasting 
~~~
cd ~/
sudo nano .bashrc
~~~

#### Paste the below directory to the end of .bashrc folder. Then press "CTRL+O", "enter", "CTRL+X"
~~~
export PATH=$PATH:~/Desktop/riscv-gnu-toolchain/installed-tools/bin
~~~

## Install Verilator and GTKWave
~~~
sudo apt-get install verilator
sudo apt-get install gtkwave
~~~

## Compile a Code
#### Clone Hornet Git
~~~
cd Downloads
git clone https://github.com/mskertem/RISC-V
~~~

#### Generate .elf file
~~~
cd RISC-V/test/bubble_sort
riscv64-unknown-elf-gcc bubble_sort.c ../crt0.s -march=rv32i -mabi=ilp32 -T ../linksc.ld -nostartfiles -ffunction-sections -fdata-sections -Wl,--gc-sections -o bubble_sort.elf
~~~

#### Generate .bin file
~~~
riscv64-unknown-elf-objcopy -O binary -j .init -j .text -j .rodata bubble_sort.elf bubble_sort.bin
~~~

#### Compile a Code
~~~
cd ..
g++ rom_generator.c -o rom_generator 
cd bubble_sort
~~~

#### Generate the .data file
~~~
../rom_generator bubble_sort.bin
~~~

## Simulating with Verilator
#### To use the wrapper file, change the file name according to C source file name (In this case bubble_sort.c)
~~~
./bubble_sort_script
~~~

#### Change Directory to Launch GTKWave
~~~
cd obj_dir
~~~

#### Launch GTKWave
~~~
gtkwave simx.vcd
~~~

# Troubleshooting, Bugs & Suggestions
Feel free to create an issue on GitHub or send an e-mail.
* 0yavuz0@gmail.com
* yasinxyilmaz@gmail.com
