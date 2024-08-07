段描述符格式：
    0-15    段界限0-15
    16-31   段基址0-15
    32-39   段基址16-23
    40-43   type
    44      S
    45-46   DPL
    47      P
    48-51   段界限16-19
    52      AVL
    53      L 为1表示64位代码段，为0表示32位代码段
    54      D/B
    55      G 粒度 为0表示1字节，为1表示4KB
    56-63   段基址24-31
    对于其中的type字段:
                            3   2   1   0
            代码段           X   C   R   A                   
        非                  1   0   0   *   只执行代码段   
        系                  1   0   1   *   可执行、可读代码段
        统                  1   1   0   *   可执行、一致性代码段
        段                  1   1   1   *   可执行、可读、一致性代码段
            数据段           X  E   W   A
                            0   0   0   *   只读数据段
                            0   0   1   *   可读写数据段
                            0   1   0   *   只读、向下扩展的数据段（由高地址向低地址扩展）
                            0   1   1   *   可读写、向下扩展的数据段

GDT、LDT、选择子：
    GDT全局描述符表，它的位置存在GDTR寄存器(48位)中
    对于gdtr，不能直接用mov访问。必须使用lgdt
    gdtr:
        0-15    GDT界限以字节为单位； 最后GDT实际大小=界限+1 个字节
        16-47   32位的GDT内存起始地址
    GDT界限最大可达到2^16=65536字节，每个段描述符64位（8字节），所以GDT中最多能容纳65536/8=8192个段描述符
    选择子：
        0-2     RPL