CPU - IO --------- 外部设备
      显卡         显示器
      硬盘控制器    硬盘

通过内存地址访问：
    把一部分IO端口映射到内存地址上
通过端口号访问：
    所有IO接口编号，x86上最多编到0-65535 (0xFFFF)
    读端口有4种情况：
        in al, dx           源操作数：端口号  将端口中的数据读到al/ax中
        in ax, dx           端口有8位也有16位，接收要用al或ax
        in al, 立即数
        in ax, 立即数       
    写端口有4中情况：
        out dx, al          源操作数：al，ax
        out dx, ax
        out 立即数, al
        out 立即数, ax
    读写操作源操作数和被操作数顺序相反

硬盘读写
    硬盘控制器有IDE、SATA
    IDE是IO端口
    
        IO端口号              端口用途            端口位数
    主控器  从控器      读取操作    写入操作        
    0x1f0   0x170       Data        Data            16
    0x1f1   0x171       Error       Features        8
    0x1f2   0x172       SectorCount SecotrCount     8
    0x1f3   0x173       LBA low     LBA low         8
    0x1f4   0x174       LBA mid     LBA mid         8
    0x1f5   0x175       LBA high    LBA high        8    
    0x1f6   0x176       Device      Device          8
    0x1f7   0x177       Status      Command         8
    *在从硬盘读写数据时，数据都是通过0x1f0/0x170这个端口传输的。因为其位数16位，一次可以传输2字节数据，
    对于一个扇区为512字节的硬盘而言，一个扇区的操作需要对该端口循环操作256次。
    *0x1f2是操作的扇区数量。  0x1f3-0x1f6存放了起始扇区号。 其中0x1f3-0x1f5总共占了24位，另外
    4位在0x1f6端口的低4位中。
    *0x1f6分布图：  bit7 固定为1 |  bit6 选择寻址模式，0是CHS模式，1是LBA模式 |  bit5 固定为1 |  bit4 选择磁盘启动器，0为主盘，1为从盘 |  bit3-0 LBAaddress
    *在执行in操作时，0x1f7会返回状态标志
        bit 内容    说明
        7   BSY     硬盘繁忙
        6   DRDY    设备就绪，等待指令
        3   DRQ     硬盘以及准备好数据，随时可以输出
        0   ERR     有错误发生 
    *执行out操作时，相当于将命令写入到0x1f7端口中    命令只有两个 读：0x20   写：0x30

