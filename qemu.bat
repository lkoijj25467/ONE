%echo off
qemu-system-i386 D:\ONE\disk.img -S -s
&
gdb target remote localhost:1234