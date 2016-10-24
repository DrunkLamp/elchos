-------------
start tftp

sudo dnsmasq -p0 --enable-tftp --tftp-root=`pwd` -d --user=`whoami`
--------------

CC

Hit any key to stop autoboot in the uboot and set goflexnet ip, tftp-server ip, goflexnet mac:

setenv ipaddr '192.168.1.1'
setenv serverip '192.168.1.2'
setenv ethaddr '00:10:75:26:71:da'
makefu 
setenv ethaddr '00:10:75:26:73:16'


https://www.dropbox.com/s/c7kevnx68hgoldw/uboot.2016.05-tld-1.goflexnet.bodhi.tar
via http://forum.doozan.com/read.php?3,12381

download from tftp-server file uboot.2016.05-tld-1.goflexnet.mtd0.kwb to RAM start offset 0x6400000
>> tftp 0x6400000 uboot.2016.05-tld-1.goflexnet.mtd0.kwb

Bytes transferred = 524288 (80000 hex) ← this number is needed for nand write
erase nand start from 0 size 0x100000
>> nand erase 0x0 0x100000

write nand from RAM start offset 0x6400000 to nand start 0x0 size 0x80000
>>nand write.e 0x6400000 0x0 0x80000

download from tftp-server file openwrt-15.05.1-kirkwood-goflexnet-uImage to RAM start offset 0x6400000
>>tftp 0x6400000 openwrt-15.05.1-kirkwood-goflexnet-uImage

Bytes transferred = 1740617 (1a8f49 hex) ← this number is needed for nand write
erase nand start from 0x100000 size 0x400000
>>nand erase 0x100000 0x400000

write nand from RAM start offset 0x6400000 to nand start 0x100000 size 1a8f49
>>nand write.e 0x6400000 0x100000 1a8f49

erase nand rootfs
>>nand erase.part rootfs
NAND erase.part: device 0 offset 0x500000, size 0x2000000
Erasing at 0x24e0000 -- 100% complete.
OK

>>ubi part rootfs
ubi0: attaching mtd1
ubi0: scanning is finished
ubi0: empty MTD device detected
ubi0: attached mtd1 (name "mtd=2", size 32 MiB)
ubi0: PEB size: 131072 bytes (128 KiB), LEB size: 129024 bytes
ubi0: min./max. I/O unit sizes: 2048/2048, sub-page size 512
ubi0: VID header offset: 512 (aligned 512), data offset: 2048
ubi0: good PEBs: 256, bad PEBs: 0, corrupted PEBs: 0
ubi0: user volume: 0, internal volumes: 1, max. volumes count: 128
ubi0: max/mean erase counter: 1/0, WL threshold: 4096, image sequence number: 0 
ubi0: available PEBs: 212, total reserved PEBs: 44, PEBs reserved for bad PEB h0
>>ubi create rootfs
No size specified -> Using max size (27353088)
Creating dynamic volume rootfs of size 27353088 

############################### not working yet
>> nand erase.part data
NAND erase.part: device 0 offset 0x2500000, size 0xdb00000
Erasing at 0xffe0000 -- 100% complete.
OK 

>>ubi part data
ubi0: attaching mtd1
ubi0: scanning is finished
ubi0: empty MTD device detected
ubi0: attached mtd1 (name "mtd=3", size 219 MiB)
ubi0: PEB size: 131072 bytes (128 KiB), LEB size: 129024 bytes
ubi0: min./max. I/O unit sizes: 2048/2048, sub-page size 512
ubi0: VID header offset: 512 (aligned 512), data offset: 2048
ubi0: good PEBs: 1752, bad PEBs: 0, corrupted PEBs: 0
ubi0: user volume: 0, internal volumes: 1, max. volumes count: 128
ubi0: max/mean erase counter: 1/0, WL threshold: 4096, image sequence number: 0 
ubi0: available PEBs: 1708, total reserved PEBs: 44, PEBs reserved for bad PEB 0

ubi create data
No size specified -> Using max size (220372992)
Creating dynamic volume data of size 220372992 
###############################

download from tftp-server openwrt-15.05.1-kirkwood-goflexnet-rootfs.ubifs to RAM start offset 0x6400000
>>tftp 0x6400000 openwrt-15.05.1-kirkwood-goflexnet-rootfs.ubifs

Bytes transferred = 4644864 (46e000 hex) ← this number is needed for nand write

##erase nand start from 0x500000 size 0x02000000
##>>nand erase 0x500000 0x02000000

write nand from RAM start offset 0x6400000 to nand start 0x500000 size 4c0000
>>ubi write 0x6400000 rootfs 46e000
##test nand write.e 0x6400000 0x500000 46e000
4644864 bytes written to volume rootfs

reboot
>>reset

Hit any key to stop autoboot! and set your mac-address from bottom side of the box (if you don't do this - ethernet wont work) and set other openwrt's environment
>>
setenv baudrate '115200'
setenv bootcmd '${x_bootcmd_kernel}; setenv bootargs ${x_bootargs} ${x_bootargs_root}; ${x_bootcmd_usb}; bootm 0x6400000;'
setenv bootdelay '3'
setenv ethact 'egiga0'
setenv ethaddr '00:10:75:26:71:da'
setenv ipaddr '192.168.1.1'
setenv serverip '192.168.1.2'
setenv stderr 'serial'
setenv stdin 'serial'
setenv stdout 'serial'
##old - works (but why) setenv x_bootargs 'console=ttyS0,115200 mtdparts=orion_nand:1M(u-boot),4M@1M(kernel),251M@5M(rootfs) rw'
setenv x_bootargs 'console=ttyS0,115200 mtdparts=orion_nand:1M(u-boot),4M@1M(kernel),32M@5M(rootfs),-(data) rw'
##old - works setenv x_bootargs_root 'ubi.mtd=2 root=ubi0:rootfs rootfstype=ubifs'
setenv x_bootargs_root 'ubi.mtd=2  rootfstype=ubifs'
##test>>setenv x_bootargs_root 'ubi.mtd=1 root=ubi0:root rootfstype=ubifs ro'
setenv x_bootcmd_kernel 'nand read 0x6400000 0x100000 0x400000'
setenv x_bootcmd_usb 'usb start'
setenv machid c11
saveenv

reboot device
>>reset


------make data ubi partition working
ubiformat /dev/mtd3 -y
ubiattach /dev/ubi_ctrl -m 3
(size ubinfo /dev/ubi1)
ubimkvol /dev/ubi1 -s 210MiB -N data
mkdir /data
mount -t ubifs ubi1:data /data/


next steps
opkg install wget
opkg install ca-certificates

wget https://github.com/kraiz/eiskaltdcpp-daemon-openwrt/releases/download/0.1.2-1/eiskaltdcpp_0.1.2-2_ar71xx.ipk

makefu
	HWaddr 00:10:75:26:71:DA
	inet addr:10.42.21.220

exco
	HWaddr 00:10:75:26:73:16
        inet addr:10.42.22.163


? 251 to ubi
[    0.000000] Kernel command line: console=ttyS0,115200 mtdparts=orion_nand:1Ms
[    0.819692] mtd: device 2 (rootfs) set to be root filesystem                 
[    0.825479] mtdsplit: no squashfs found in "rootfs"                          
[    0.830485] mtdsplit: no squashfs found in "orion_nand"                      
[    1.015712] UBI: attaching mtd2 to ubi0                                      
[    1.487769] UBI: attached mtd2 (name "rootfs", size 251 MiB) to ubi0 
