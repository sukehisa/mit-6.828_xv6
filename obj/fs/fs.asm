
obj/fs/fs:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 73 1a 00 00       	call   801aa4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	b9 f7 01 00 00       	mov    $0x1f7,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  80003c:	89 ca                	mov    %ecx,%edx
  80003e:	ec                   	in     (%dx),%al
	__asm __volatile("int3");
}

static __inline uint8_t
inb(int port)
{
  80003f:	0f b6 d0             	movzbl %al,%edx
  800042:	89 d0                	mov    %edx,%eax
  800044:	25 c0 00 00 00       	and    $0xc0,%eax
  800049:	83 f8 40             	cmp    $0x40,%eax
  80004c:	75 ee                	jne    80003c <ide_wait_ready+0x8>
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  80004e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800052:	74 0a                	je     80005e <ide_wait_ready+0x2a>
		return -1;
  800054:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  800059:	f6 c2 21             	test   $0x21,%dl
  80005c:	75 05                	jne    800063 <ide_wait_ready+0x2f>
		return -1;
	return 0;
  80005e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  800065:	55                   	push   %ebp
  800066:	89 e5                	mov    %esp,%ebp
  800068:	53                   	push   %ebx
  800069:	83 ec 04             	sub    $0x4,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  80006c:	6a 00                	push   $0x0
  80006e:	e8 c1 ff ff ff       	call   800034 <ide_wait_ready>
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
  800073:	83 c4 04             	add    $0x4,%esp
  800076:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80007b:	b0 f0                	mov    $0xf0,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  80007d:	ee                   	out    %al,(%dx)

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80007e:	b9 00 00 00 00       	mov    $0x0,%ecx
	__asm __volatile("int3");
}

static __inline uint8_t
inb(int port)
{
  800083:	b2 f7                	mov    $0xf7,%dl
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800085:	ec                   	in     (%dx),%al
	__asm __volatile("int3");
}

static __inline uint8_t
inb(int port)
{
  800086:	a8 a1                	test   $0xa1,%al
  800088:	74 0e                	je     800098 <ide_probe_disk1+0x33>
  80008a:	41                   	inc    %ecx
  80008b:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
  800091:	7f 05                	jg     800098 <ide_probe_disk1+0x33>
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800093:	ec                   	in     (%dx),%al
	__asm __volatile("int3");
}

static __inline uint8_t
inb(int port)
{
  800094:	a8 a1                	test   $0xa1,%al
  800096:	75 f2                	jne    80008a <ide_probe_disk1+0x25>
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
  800098:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80009d:	b0 e0                	mov    $0xe0,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  80009f:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  8000a0:	83 ec 08             	sub    $0x8,%esp
  8000a3:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
  8000a9:	0f 9e c0             	setle  %al
  8000ac:	0f b6 d8             	movzbl %al,%ebx
  8000af:	53                   	push   %ebx
  8000b0:	68 40 33 80 00       	push   $0x803340
  8000b5:	e8 22 1b 00 00       	call   801bdc <cprintf>
	return (x < 1000);
  8000ba:	83 c4 10             	add    $0x10,%esp
}
  8000bd:	89 d8                	mov    %ebx,%eax
  8000bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c2:	c9                   	leave  
  8000c3:	c3                   	ret    

008000c4 <ide_set_disk>:

void
ide_set_disk(int d)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	83 ec 08             	sub    $0x8,%esp
  8000ca:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8000cd:	83 f8 01             	cmp    $0x1,%eax
  8000d0:	76 14                	jbe    8000e6 <ide_set_disk+0x22>
		panic("bad disk number");
  8000d2:	83 ec 04             	sub    $0x4,%esp
  8000d5:	68 57 33 80 00       	push   $0x803357
  8000da:	6a 3a                	push   $0x3a
  8000dc:	68 67 33 80 00       	push   $0x803367
  8000e1:	e8 1a 1a 00 00       	call   801b00 <_panic>
	diskno = d;
  8000e6:	a3 00 40 80 00       	mov    %eax,0x804000
}
  8000eb:	c9                   	leave  
  8000ec:	c3                   	ret    

008000ed <ide_read>:

int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	57                   	push   %edi
  8000f1:	56                   	push   %esi
  8000f2:	53                   	push   %ebx
  8000f3:	83 ec 0c             	sub    $0xc,%esp
  8000f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000f9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	assert(nsecs <= 256);
  8000fc:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  800102:	76 16                	jbe    80011a <ide_read+0x2d>
  800104:	68 70 33 80 00       	push   $0x803370
  800109:	68 7d 33 80 00       	push   $0x80337d
  80010e:	6a 43                	push   $0x43
  800110:	68 67 33 80 00       	push   $0x803367
  800115:	e8 e6 19 00 00       	call   801b00 <_panic>

	ide_wait_ready(0);
  80011a:	6a 00                	push   $0x0
  80011c:	e8 13 ff ff ff       	call   800034 <ide_wait_ready>
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
  800121:	83 c4 04             	add    $0x4,%esp
  800124:	ba f2 01 00 00       	mov    $0x1f2,%edx
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800129:	89 f0                	mov    %esi,%eax
  80012b:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
  80012c:	b2 f3                	mov    $0xf3,%dl
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  80012e:	88 d8                	mov    %bl,%al
  800130:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
  800131:	b2 f4                	mov    $0xf4,%dl
  800133:	89 d8                	mov    %ebx,%eax
  800135:	c1 e8 08             	shr    $0x8,%eax
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800138:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
  800139:	b2 f5                	mov    $0xf5,%dl
  80013b:	89 d8                	mov    %ebx,%eax
  80013d:	c1 e8 10             	shr    $0x10,%eax
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800140:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
  800141:	b9 f6 01 00 00       	mov    $0x1f6,%ecx
  800146:	a0 00 40 80 00       	mov    0x804000,%al
  80014b:	83 e0 01             	and    $0x1,%eax
  80014e:	c1 e0 04             	shl    $0x4,%eax
  800151:	89 da                	mov    %ebx,%edx
  800153:	c1 ea 18             	shr    $0x18,%edx
  800156:	83 e2 0f             	and    $0xf,%edx
  800159:	09 d0                	or     %edx,%eax
  80015b:	83 c8 e0             	or     $0xffffffe0,%eax
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  80015e:	89 ca                	mov    %ecx,%edx
  800160:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
  800161:	b2 f7                	mov    $0xf7,%dl
  800163:	b0 20                	mov    $0x20,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800165:	ee                   	out    %al,(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  800166:	85 f6                	test   %esi,%esi
  800168:	74 2a                	je     800194 <ide_read+0xa7>
  80016a:	bb f0 01 00 00       	mov    $0x1f0,%ebx
		if ((r = ide_wait_ready(1)) < 0)
  80016f:	6a 01                	push   $0x1
  800171:	e8 be fe ff ff       	call   800034 <ide_wait_ready>
  800176:	83 c4 04             	add    $0x4,%esp
  800179:	85 c0                	test   %eax,%eax
  80017b:	78 1c                	js     800199 <ide_read+0xac>
	return data;
}

static __inline void
insl(int port, void *addr, int cnt)
{
  80017d:	b9 80 00 00 00       	mov    $0x80,%ecx
	__asm __volatile("cld\n\trepne\n\tinsl"			:
  800182:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800185:	89 da                	mov    %ebx,%edx
  800187:	fc                   	cld    
  800188:	f2 6d                	repnz insl (%dx),%es:(%edi)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  80018a:	81 45 0c 00 02 00 00 	addl   $0x200,0xc(%ebp)
  800191:	4e                   	dec    %esi
  800192:	75 db                	jne    80016f <ide_read+0x82>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
  800194:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800199:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80019c:	5b                   	pop    %ebx
  80019d:	5e                   	pop    %esi
  80019e:	5f                   	pop    %edi
  80019f:	c9                   	leave  
  8001a0:	c3                   	ret    

008001a1 <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	57                   	push   %edi
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 0c             	sub    $0xc,%esp
  8001aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001ad:	8b 7d 10             	mov    0x10(%ebp),%edi
	int r;

	assert(nsecs <= 256);
  8001b0:	81 ff 00 01 00 00    	cmp    $0x100,%edi
  8001b6:	76 16                	jbe    8001ce <ide_write+0x2d>
  8001b8:	68 70 33 80 00       	push   $0x803370
  8001bd:	68 7d 33 80 00       	push   $0x80337d
  8001c2:	6a 5c                	push   $0x5c
  8001c4:	68 67 33 80 00       	push   $0x803367
  8001c9:	e8 32 19 00 00       	call   801b00 <_panic>

	ide_wait_ready(0);
  8001ce:	6a 00                	push   $0x0
  8001d0:	e8 5f fe ff ff       	call   800034 <ide_wait_ready>
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
  8001d5:	83 c4 04             	add    $0x4,%esp
  8001d8:	ba f2 01 00 00       	mov    $0x1f2,%edx
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001dd:	89 f8                	mov    %edi,%eax
  8001df:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
  8001e0:	b2 f3                	mov    $0xf3,%dl
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001e2:	88 d8                	mov    %bl,%al
  8001e4:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
  8001e5:	b2 f4                	mov    $0xf4,%dl
  8001e7:	89 d8                	mov    %ebx,%eax
  8001e9:	c1 e8 08             	shr    $0x8,%eax
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001ec:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
  8001ed:	b2 f5                	mov    $0xf5,%dl
  8001ef:	89 d8                	mov    %ebx,%eax
  8001f1:	c1 e8 10             	shr    $0x10,%eax
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001f4:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
  8001f5:	b9 f6 01 00 00       	mov    $0x1f6,%ecx
  8001fa:	a0 00 40 80 00       	mov    0x804000,%al
  8001ff:	83 e0 01             	and    $0x1,%eax
  800202:	c1 e0 04             	shl    $0x4,%eax
  800205:	89 da                	mov    %ebx,%edx
  800207:	c1 ea 18             	shr    $0x18,%edx
  80020a:	83 e2 0f             	and    $0xf,%edx
  80020d:	09 d0                	or     %edx,%eax
  80020f:	83 c8 e0             	or     $0xffffffe0,%eax
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800212:	89 ca                	mov    %ecx,%edx
  800214:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
  800215:	b2 f7                	mov    $0xf7,%dl
  800217:	b0 30                	mov    $0x30,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800219:	ee                   	out    %al,(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  80021a:	85 ff                	test   %edi,%edi
  80021c:	74 2a                	je     800248 <ide_write+0xa7>
  80021e:	bb f0 01 00 00       	mov    $0x1f0,%ebx
		if ((r = ide_wait_ready(1)) < 0)
  800223:	6a 01                	push   $0x1
  800225:	e8 0a fe ff ff       	call   800034 <ide_wait_ready>
  80022a:	83 c4 04             	add    $0x4,%esp
  80022d:	85 c0                	test   %eax,%eax
  80022f:	78 1c                	js     80024d <ide_write+0xac>
			 "cc");
}

static __inline void
outsl(int port, const void *addr, int cnt)
{
  800231:	b9 80 00 00 00       	mov    $0x80,%ecx
	__asm __volatile("cld\n\trepne\n\toutsl"		:
  800236:	8b 75 0c             	mov    0xc(%ebp),%esi
  800239:	89 da                	mov    %ebx,%edx
  80023b:	fc                   	cld    
  80023c:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  80023e:	81 45 0c 00 02 00 00 	addl   $0x200,0xc(%ebp)
  800245:	4f                   	dec    %edi
  800246:	75 db                	jne    800223 <ide_write+0x82>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
  800248:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80024d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800250:	5b                   	pop    %ebx
  800251:	5e                   	pop    %esi
  800252:	5f                   	pop    %edi
  800253:	c9                   	leave  
  800254:	c3                   	ret    
  800255:	00 00                	add    %al,(%eax)
	...

00800258 <diskaddr>:
#include "fs.h"

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  800258:	55                   	push   %ebp
  800259:	89 e5                	mov    %esp,%ebp
  80025b:	83 ec 08             	sub    $0x8,%esp
  80025e:	8b 55 08             	mov    0x8(%ebp),%edx
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  800261:	85 d2                	test   %edx,%edx
  800263:	74 13                	je     800278 <diskaddr+0x20>
  800265:	83 3d 08 90 80 00 00 	cmpl   $0x0,0x809008
  80026c:	74 1c                	je     80028a <diskaddr+0x32>
  80026e:	a1 08 90 80 00       	mov    0x809008,%eax
  800273:	39 50 04             	cmp    %edx,0x4(%eax)
  800276:	77 12                	ja     80028a <diskaddr+0x32>
		panic("bad block number %08x in diskaddr", blockno);
  800278:	52                   	push   %edx
  800279:	68 94 33 80 00       	push   $0x803394
  80027e:	6a 09                	push   $0x9
  800280:	68 1c 35 80 00       	push   $0x80351c
  800285:	e8 76 18 00 00       	call   801b00 <_panic>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  80028a:	89 d0                	mov    %edx,%eax
  80028c:	c1 e0 0c             	shl    $0xc,%eax
  80028f:	05 00 00 00 10       	add    $0x10000000,%eax
}
  800294:	c9                   	leave  
  800295:	c3                   	ret    

00800296 <va_is_mapped>:

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
  800296:	55                   	push   %ebp
  800297:	89 e5                	mov    %esp,%ebp
  800299:	8b 55 08             	mov    0x8(%ebp),%edx
	return (vpd[PDX(va)] & PTE_P) && (vpt[PGNUM(va)] & PTE_P);
  80029c:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002a1:	89 d0                	mov    %edx,%eax
  8002a3:	c1 e8 16             	shr    $0x16,%eax
  8002a6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8002ad:	a8 01                	test   $0x1,%al
  8002af:	74 12                	je     8002c3 <va_is_mapped+0x2d>
  8002b1:	89 d0                	mov    %edx,%eax
  8002b3:	c1 e8 0c             	shr    $0xc,%eax
  8002b6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8002bd:	a8 01                	test   $0x1,%al
  8002bf:	74 02                	je     8002c3 <va_is_mapped+0x2d>
  8002c1:	b1 01                	mov    $0x1,%cl
}
  8002c3:	89 c8                	mov    %ecx,%eax
  8002c5:	c9                   	leave  
  8002c6:	c3                   	ret    

008002c7 <va_is_dirty>:

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
  8002c7:	55                   	push   %ebp
  8002c8:	89 e5                	mov    %esp,%ebp
	return (vpt[PGNUM(va)] & PTE_D) != 0;
  8002ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cd:	c1 e8 0c             	shr    $0xc,%eax
  8002d0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8002d7:	c1 e8 06             	shr    $0x6,%eax
  8002da:	83 e0 01             	and    $0x1,%eax
}
  8002dd:	c9                   	leave  
  8002de:	c3                   	ret    

008002df <bc_pgfault>:
// Fault any disk block that is read or written in to memory by
// loading it from disk.
// Hint: Use ide_read and BLKSECTS.
static void
bc_pgfault(struct UTrapframe *utf)
{
  8002df:	55                   	push   %ebp
  8002e0:	89 e5                	mov    %esp,%ebp
  8002e2:	56                   	push   %esi
  8002e3:	53                   	push   %ebx
  8002e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	void *addr = (void *) utf->utf_fault_va;
  8002e7:	8b 11                	mov    (%ecx),%edx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  8002e9:	8d b2 00 00 00 f0    	lea    -0x10000000(%edx),%esi
  8002ef:	c1 ee 0c             	shr    $0xc,%esi
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  8002f2:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
  8002f8:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  8002fd:	76 1b                	jbe    80031a <bc_pgfault+0x3b>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  8002ff:	83 ec 08             	sub    $0x8,%esp
  800302:	ff 71 04             	pushl  0x4(%ecx)
  800305:	52                   	push   %edx
  800306:	ff 71 28             	pushl  0x28(%ecx)
  800309:	68 b8 33 80 00       	push   $0x8033b8
  80030e:	6a 28                	push   $0x28
  800310:	68 1c 35 80 00       	push   $0x80351c
  800315:	e8 e6 17 00 00       	call   801b00 <_panic>
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  80031a:	83 3d 08 90 80 00 00 	cmpl   $0x0,0x809008
  800321:	74 1c                	je     80033f <bc_pgfault+0x60>
  800323:	a1 08 90 80 00       	mov    0x809008,%eax
  800328:	39 70 04             	cmp    %esi,0x4(%eax)
  80032b:	77 12                	ja     80033f <bc_pgfault+0x60>
		panic("reading non-existent block %08x\n", blockno);
  80032d:	56                   	push   %esi
  80032e:	68 e8 33 80 00       	push   $0x8033e8
  800333:	6a 2c                	push   $0x2c
  800335:	68 1c 35 80 00       	push   $0x80351c
  80033a:	e8 c1 17 00 00       	call   801b00 <_panic>
	// of the block from the disk into that page, and mark the
	// page not-dirty (since reading the data from disk will mark
	// the page dirty).
	//
	// LAB 5: Your code here 
	void *blkaddr = ROUNDDOWN(addr, PGSIZE);
  80033f:	89 d3                	mov    %edx,%ebx
  800341:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (sys_page_alloc(thisenv->env_id, blkaddr,  PTE_SYSCALL) < 0)
  800347:	83 ec 04             	sub    $0x4,%esp
  80034a:	68 07 0e 00 00       	push   $0xe07
  80034f:	53                   	push   %ebx
  800350:	a1 0c 90 80 00       	mov    0x80900c,%eax
  800355:	8b 40 48             	mov    0x48(%eax),%eax
  800358:	50                   	push   %eax
  800359:	e8 74 21 00 00       	call   8024d2 <sys_page_alloc>
  80035e:	83 c4 10             	add    $0x10,%esp
  800361:	85 c0                	test   %eax,%eax
  800363:	79 14                	jns    800379 <bc_pgfault+0x9a>
		panic("bc_pgfault: can not allocate new page\n");
  800365:	83 ec 04             	sub    $0x4,%esp
  800368:	68 0c 34 80 00       	push   $0x80340c
  80036d:	6a 36                	push   $0x36
  80036f:	68 1c 35 80 00       	push   $0x80351c
  800374:	e8 87 17 00 00       	call   801b00 <_panic>
	if (ide_read(blockno*BLKSECTS, blkaddr,  BLKSECTS) < 0)
  800379:	83 ec 04             	sub    $0x4,%esp
  80037c:	6a 08                	push   $0x8
  80037e:	53                   	push   %ebx
  80037f:	8d 04 f5 00 00 00 00 	lea    0x0(,%esi,8),%eax
  800386:	50                   	push   %eax
  800387:	e8 61 fd ff ff       	call   8000ed <ide_read>
  80038c:	83 c4 10             	add    $0x10,%esp
  80038f:	85 c0                	test   %eax,%eax
  800391:	79 14                	jns    8003a7 <bc_pgfault+0xc8>
		panic("bc_pgfault: failed to read block from disk\n");	
  800393:	83 ec 04             	sub    $0x4,%esp
  800396:	68 34 34 80 00       	push   $0x803434
  80039b:	6a 38                	push   $0x38
  80039d:	68 1c 35 80 00       	push   $0x80351c
  8003a2:	e8 59 17 00 00       	call   801b00 <_panic>
    if (sys_page_map(thisenv->env_id, blkaddr, 
  8003a7:	83 ec 0c             	sub    $0xc,%esp
  8003aa:	68 07 0e 00 00       	push   $0xe07
  8003af:	53                   	push   %ebx
  8003b0:	8b 15 0c 90 80 00    	mov    0x80900c,%edx
  8003b6:	8b 42 48             	mov    0x48(%edx),%eax
  8003b9:	50                   	push   %eax
  8003ba:	53                   	push   %ebx
  8003bb:	8b 42 48             	mov    0x48(%edx),%eax
  8003be:	50                   	push   %eax
  8003bf:	e8 51 21 00 00       	call   802515 <sys_page_map>
  8003c4:	83 c4 20             	add    $0x20,%esp
  8003c7:	85 c0                	test   %eax,%eax
  8003c9:	79 14                	jns    8003df <bc_pgfault+0x100>
				     thisenv->env_id, blkaddr, PTE_SYSCALL) < 0)
       panic("bc_pgfault: failed to mark disk page as non dirty\n");
  8003cb:	83 ec 04             	sub    $0x4,%esp
  8003ce:	68 60 34 80 00       	push   $0x803460
  8003d3:	6a 3b                	push   $0x3b
  8003d5:	68 1c 35 80 00       	push   $0x80351c
  8003da:	e8 21 17 00 00       	call   801b00 <_panic>
	//panic("bc_pgfault not implemented");

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  8003df:	83 3d 04 90 80 00 00 	cmpl   $0x0,0x809004
  8003e6:	74 22                	je     80040a <bc_pgfault+0x12b>
  8003e8:	83 ec 0c             	sub    $0xc,%esp
  8003eb:	56                   	push   %esi
  8003ec:	e8 bf 02 00 00       	call   8006b0 <block_is_free>
  8003f1:	83 c4 10             	add    $0x10,%esp
  8003f4:	85 c0                	test   %eax,%eax
  8003f6:	74 12                	je     80040a <bc_pgfault+0x12b>
		panic("reading free block %08x\n", blockno);
  8003f8:	56                   	push   %esi
  8003f9:	68 24 35 80 00       	push   $0x803524
  8003fe:	6a 43                	push   $0x43
  800400:	68 1c 35 80 00       	push   $0x80351c
  800405:	e8 f6 16 00 00       	call   801b00 <_panic>
}
  80040a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80040d:	5b                   	pop    %ebx
  80040e:	5e                   	pop    %esi
  80040f:	c9                   	leave  
  800410:	c3                   	ret    

00800411 <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	57                   	push   %edi
  800415:	56                   	push   %esi
  800416:	53                   	push   %ebx
  800417:	83 ec 0c             	sub    $0xc,%esp
  80041a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  80041d:	8d b3 00 00 00 f0    	lea    -0x10000000(%ebx),%esi
  800423:	c1 ee 0c             	shr    $0xc,%esi

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800426:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  80042c:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  800431:	76 12                	jbe    800445 <flush_block+0x34>
		panic("flush_block of bad va %08x", addr);
  800433:	53                   	push   %ebx
  800434:	68 3d 35 80 00       	push   $0x80353d
  800439:	6a 53                	push   $0x53
  80043b:	68 1c 35 80 00       	push   $0x80351c
  800440:	e8 bb 16 00 00       	call   801b00 <_panic>

	// LAB 5: Your code here.
	void *blkaddr = ROUNDDOWN(addr, PGSIZE);
  800445:	89 df                	mov    %ebx,%edi
  800447:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	if (va_is_mapped(addr) && va_is_dirty(addr)) {
  80044d:	53                   	push   %ebx
  80044e:	e8 43 fe ff ff       	call   800296 <va_is_mapped>
  800453:	83 c4 04             	add    $0x4,%esp
  800456:	85 c0                	test   %eax,%eax
  800458:	74 73                	je     8004cd <flush_block+0xbc>
  80045a:	53                   	push   %ebx
  80045b:	e8 67 fe ff ff       	call   8002c7 <va_is_dirty>
  800460:	83 c4 04             	add    $0x4,%esp
  800463:	85 c0                	test   %eax,%eax
  800465:	74 66                	je     8004cd <flush_block+0xbc>
		if (ide_write(blockno*BLKSECTS, blkaddr, BLKSECTS) < 0)
  800467:	83 ec 04             	sub    $0x4,%esp
  80046a:	6a 08                	push   $0x8
  80046c:	57                   	push   %edi
  80046d:	8d 04 f5 00 00 00 00 	lea    0x0(,%esi,8),%eax
  800474:	50                   	push   %eax
  800475:	e8 27 fd ff ff       	call   8001a1 <ide_write>
  80047a:	83 c4 10             	add    $0x10,%esp
  80047d:	85 c0                	test   %eax,%eax
  80047f:	79 14                	jns    800495 <flush_block+0x84>
			panic("flush_block: failed to write a block to disk\n");
  800481:	83 ec 04             	sub    $0x4,%esp
  800484:	68 94 34 80 00       	push   $0x803494
  800489:	6a 59                	push   $0x59
  80048b:	68 1c 35 80 00       	push   $0x80351c
  800490:	e8 6b 16 00 00       	call   801b00 <_panic>
		if (sys_page_map(thisenv->env_id, blkaddr, 
  800495:	83 ec 0c             	sub    $0xc,%esp
  800498:	68 07 0e 00 00       	push   $0xe07
  80049d:	57                   	push   %edi
  80049e:	8b 15 0c 90 80 00    	mov    0x80900c,%edx
  8004a4:	8b 42 48             	mov    0x48(%edx),%eax
  8004a7:	50                   	push   %eax
  8004a8:	57                   	push   %edi
  8004a9:	8b 42 48             	mov    0x48(%edx),%eax
  8004ac:	50                   	push   %eax
  8004ad:	e8 63 20 00 00       	call   802515 <sys_page_map>
  8004b2:	83 c4 20             	add    $0x20,%esp
  8004b5:	85 c0                	test   %eax,%eax
  8004b7:	79 14                	jns    8004cd <flush_block+0xbc>
					     thisenv->env_id, blkaddr, PTE_SYSCALL) < 0)
			panic("flush_block: failed to mark disk page as non dirty\n");
  8004b9:	83 ec 04             	sub    $0x4,%esp
  8004bc:	68 c4 34 80 00       	push   $0x8034c4
  8004c1:	6a 5c                	push   $0x5c
  8004c3:	68 1c 35 80 00       	push   $0x80351c
  8004c8:	e8 33 16 00 00       	call   801b00 <_panic>
	}

	//panic("flush_block not implemented");
}
  8004cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004d0:	5b                   	pop    %ebx
  8004d1:	5e                   	pop    %esi
  8004d2:	5f                   	pop    %edi
  8004d3:	c9                   	leave  
  8004d4:	c3                   	ret    

008004d5 <check_bc>:

// Test that the block cache works, by smashing the superblock and
// reading it back.
static void
check_bc(void)
{
  8004d5:	55                   	push   %ebp
  8004d6:	89 e5                	mov    %esp,%ebp
  8004d8:	81 ec 1c 01 00 00    	sub    $0x11c,%esp
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  8004de:	68 08 01 00 00       	push   $0x108
  8004e3:	83 ec 04             	sub    $0x4,%esp
  8004e6:	6a 01                	push   $0x1
  8004e8:	e8 6b fd ff ff       	call   800258 <diskaddr>
  8004ed:	83 c4 08             	add    $0x8,%esp
  8004f0:	50                   	push   %eax
  8004f1:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8004f7:	50                   	push   %eax
  8004f8:	e8 7f 1d 00 00       	call   80227c <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  8004fd:	83 c4 08             	add    $0x8,%esp
  800500:	68 58 35 80 00       	push   $0x803558
  800505:	6a 01                	push   $0x1
  800507:	e8 4c fd ff ff       	call   800258 <diskaddr>
  80050c:	89 04 24             	mov    %eax,(%esp)
  80050f:	e8 cc 1b 00 00       	call   8020e0 <strcpy>
	flush_block(diskaddr(1));
  800514:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80051b:	e8 38 fd ff ff       	call   800258 <diskaddr>
  800520:	89 04 24             	mov    %eax,(%esp)
  800523:	e8 e9 fe ff ff       	call   800411 <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  800528:	83 ec 0c             	sub    $0xc,%esp
  80052b:	6a 01                	push   $0x1
  80052d:	e8 26 fd ff ff       	call   800258 <diskaddr>
  800532:	83 c4 10             	add    $0x10,%esp
  800535:	50                   	push   %eax
  800536:	e8 5b fd ff ff       	call   800296 <va_is_mapped>
  80053b:	83 c4 14             	add    $0x14,%esp
  80053e:	85 c0                	test   %eax,%eax
  800540:	75 16                	jne    800558 <check_bc+0x83>
  800542:	68 7a 35 80 00       	push   $0x80357a
  800547:	68 7d 33 80 00       	push   $0x80337d
  80054c:	6a 6f                	push   $0x6f
  80054e:	68 1c 35 80 00       	push   $0x80351c
  800553:	e8 a8 15 00 00       	call   801b00 <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  800558:	83 ec 0c             	sub    $0xc,%esp
  80055b:	6a 01                	push   $0x1
  80055d:	e8 f6 fc ff ff       	call   800258 <diskaddr>
  800562:	83 c4 10             	add    $0x10,%esp
  800565:	50                   	push   %eax
  800566:	e8 5c fd ff ff       	call   8002c7 <va_is_dirty>
  80056b:	83 c4 04             	add    $0x4,%esp
  80056e:	85 c0                	test   %eax,%eax
  800570:	74 16                	je     800588 <check_bc+0xb3>
  800572:	68 5f 35 80 00       	push   $0x80355f
  800577:	68 7d 33 80 00       	push   $0x80337d
  80057c:	6a 70                	push   $0x70
  80057e:	68 1c 35 80 00       	push   $0x80351c
  800583:	e8 78 15 00 00       	call   801b00 <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  800588:	83 ec 0c             	sub    $0xc,%esp
  80058b:	6a 01                	push   $0x1
  80058d:	e8 c6 fc ff ff       	call   800258 <diskaddr>
  800592:	83 c4 08             	add    $0x8,%esp
  800595:	50                   	push   %eax
  800596:	6a 00                	push   $0x0
  800598:	e8 ba 1f 00 00       	call   802557 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  80059d:	83 ec 0c             	sub    $0xc,%esp
  8005a0:	6a 01                	push   $0x1
  8005a2:	e8 b1 fc ff ff       	call   800258 <diskaddr>
  8005a7:	83 c4 10             	add    $0x10,%esp
  8005aa:	50                   	push   %eax
  8005ab:	e8 e6 fc ff ff       	call   800296 <va_is_mapped>
  8005b0:	83 c4 14             	add    $0x14,%esp
  8005b3:	85 c0                	test   %eax,%eax
  8005b5:	74 16                	je     8005cd <check_bc+0xf8>
  8005b7:	68 79 35 80 00       	push   $0x803579
  8005bc:	68 7d 33 80 00       	push   $0x80337d
  8005c1:	6a 74                	push   $0x74
  8005c3:	68 1c 35 80 00       	push   $0x80351c
  8005c8:	e8 33 15 00 00       	call   801b00 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8005cd:	83 ec 08             	sub    $0x8,%esp
  8005d0:	68 58 35 80 00       	push   $0x803558
  8005d5:	6a 01                	push   $0x1
  8005d7:	e8 7c fc ff ff       	call   800258 <diskaddr>
  8005dc:	89 04 24             	mov    %eax,(%esp)
  8005df:	e8 9d 1b 00 00       	call   802181 <strcmp>
  8005e4:	83 c4 10             	add    $0x10,%esp
  8005e7:	85 c0                	test   %eax,%eax
  8005e9:	74 16                	je     800601 <check_bc+0x12c>
  8005eb:	68 f8 34 80 00       	push   $0x8034f8
  8005f0:	68 7d 33 80 00       	push   $0x80337d
  8005f5:	6a 77                	push   $0x77
  8005f7:	68 1c 35 80 00       	push   $0x80351c
  8005fc:	e8 ff 14 00 00       	call   801b00 <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  800601:	83 ec 04             	sub    $0x4,%esp
  800604:	68 08 01 00 00       	push   $0x108
  800609:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80060f:	50                   	push   %eax
  800610:	6a 01                	push   $0x1
  800612:	e8 41 fc ff ff       	call   800258 <diskaddr>
  800617:	89 04 24             	mov    %eax,(%esp)
  80061a:	e8 5d 1c 00 00       	call   80227c <memmove>
	flush_block(diskaddr(1));
  80061f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800626:	e8 2d fc ff ff       	call   800258 <diskaddr>
  80062b:	89 04 24             	mov    %eax,(%esp)
  80062e:	e8 de fd ff ff       	call   800411 <flush_block>

	cprintf("block cache is good\n");
  800633:	c7 04 24 94 35 80 00 	movl   $0x803594,(%esp)
  80063a:	e8 9d 15 00 00       	call   801bdc <cprintf>
}
  80063f:	c9                   	leave  
  800640:	c3                   	ret    

00800641 <bc_init>:

void
bc_init(void)
{
  800641:	55                   	push   %ebp
  800642:	89 e5                	mov    %esp,%ebp
  800644:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(bc_pgfault);
  800647:	68 df 02 80 00       	push   $0x8002df
  80064c:	e8 73 20 00 00       	call   8026c4 <set_pgfault_handler>
	check_bc();
  800651:	e8 7f fe ff ff       	call   8004d5 <check_bc>
}
  800656:	c9                   	leave  
  800657:	c3                   	ret    

00800658 <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  800658:	55                   	push   %ebp
  800659:	89 e5                	mov    %esp,%ebp
  80065b:	83 ec 08             	sub    $0x8,%esp
	if (super->s_magic != FS_MAGIC)
  80065e:	a1 08 90 80 00       	mov    0x809008,%eax
  800663:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  800669:	74 14                	je     80067f <check_super+0x27>
		panic("bad file system magic number");
  80066b:	83 ec 04             	sub    $0x4,%esp
  80066e:	68 a9 35 80 00       	push   $0x8035a9
  800673:	6a 0e                	push   $0xe
  800675:	68 c6 35 80 00       	push   $0x8035c6
  80067a:	e8 81 14 00 00       	call   801b00 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  80067f:	a1 08 90 80 00       	mov    0x809008,%eax
  800684:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  80068b:	76 14                	jbe    8006a1 <check_super+0x49>
		panic("file system is too large");
  80068d:	83 ec 04             	sub    $0x4,%esp
  800690:	68 ce 35 80 00       	push   $0x8035ce
  800695:	6a 11                	push   $0x11
  800697:	68 c6 35 80 00       	push   $0x8035c6
  80069c:	e8 5f 14 00 00       	call   801b00 <_panic>

	cprintf("superblock is good\n");
  8006a1:	83 ec 0c             	sub    $0xc,%esp
  8006a4:	68 e7 35 80 00       	push   $0x8035e7
  8006a9:	e8 2e 15 00 00       	call   801bdc <cprintf>
}
  8006ae:	c9                   	leave  
  8006af:	c3                   	ret    

008006b0 <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  8006b0:	55                   	push   %ebp
  8006b1:	89 e5                	mov    %esp,%ebp
  8006b3:	53                   	push   %ebx
  8006b4:	8b 55 08             	mov    0x8(%ebp),%edx
	if (super == 0 || blockno >= super->s_nblocks)
  8006b7:	83 3d 08 90 80 00 00 	cmpl   $0x0,0x809008
  8006be:	74 0a                	je     8006ca <block_is_free+0x1a>
  8006c0:	a1 08 90 80 00       	mov    0x809008,%eax
  8006c5:	39 50 04             	cmp    %edx,0x4(%eax)
  8006c8:	77 07                	ja     8006d1 <block_is_free+0x21>
		return 0;
  8006ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8006cf:	eb 20                	jmp    8006f1 <block_is_free+0x41>
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  8006d1:	89 d3                	mov    %edx,%ebx
  8006d3:	c1 eb 05             	shr    $0x5,%ebx
  8006d6:	89 d1                	mov    %edx,%ecx
  8006d8:	83 e1 1f             	and    $0x1f,%ecx
  8006db:	b8 01 00 00 00       	mov    $0x1,%eax
  8006e0:	d3 e0                	shl    %cl,%eax
		return 1;
  8006e2:	8b 15 04 90 80 00    	mov    0x809004,%edx
  8006e8:	85 04 9a             	test   %eax,(%edx,%ebx,4)
  8006eb:	0f 95 c0             	setne  %al
  8006ee:	0f b6 c0             	movzbl %al,%eax
	return 0;
}
  8006f1:	5b                   	pop    %ebx
  8006f2:	c9                   	leave  
  8006f3:	c3                   	ret    

008006f4 <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	53                   	push   %ebx
  8006f8:	83 ec 04             	sub    $0x4,%esp
  8006fb:	8b 45 08             	mov    0x8(%ebp),%eax
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  8006fe:	85 c0                	test   %eax,%eax
  800700:	75 14                	jne    800716 <free_block+0x22>
		panic("attempt to free zero block");
  800702:	83 ec 04             	sub    $0x4,%esp
  800705:	68 fb 35 80 00       	push   $0x8035fb
  80070a:	6a 2c                	push   $0x2c
  80070c:	68 c6 35 80 00       	push   $0x8035c6
  800711:	e8 ea 13 00 00       	call   801b00 <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  800716:	89 c3                	mov    %eax,%ebx
  800718:	c1 eb 05             	shr    $0x5,%ebx
  80071b:	8b 15 04 90 80 00    	mov    0x809004,%edx
  800721:	89 c1                	mov    %eax,%ecx
  800723:	83 e1 1f             	and    $0x1f,%ecx
  800726:	b8 01 00 00 00       	mov    $0x1,%eax
  80072b:	d3 e0                	shl    %cl,%eax
  80072d:	09 04 9a             	or     %eax,(%edx,%ebx,4)
}
  800730:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800733:	c9                   	leave  
  800734:	c3                   	ret    

00800735 <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  800735:	55                   	push   %ebp
  800736:	89 e5                	mov    %esp,%ebp
  800738:	53                   	push   %ebx
  800739:	83 ec 04             	sub    $0x4,%esp
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	int i, j;
	for (i = 0; i < super->s_nblocks; i++) {
  80073c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800741:	a1 08 90 80 00       	mov    0x809008,%eax
  800746:	3b 58 04             	cmp    0x4(%eax),%ebx
  800749:	73 6a                	jae    8007b5 <alloc_block+0x80>
		int word = bitmap[i/32];
  80074b:	89 d8                	mov    %ebx,%eax
  80074d:	85 db                	test   %ebx,%ebx
  80074f:	79 03                	jns    800754 <alloc_block+0x1f>
  800751:	8d 43 1f             	lea    0x1f(%ebx),%eax
  800754:	89 c2                	mov    %eax,%edx
  800756:	c1 fa 05             	sar    $0x5,%edx
  800759:	a1 04 90 80 00       	mov    0x809004,%eax
  80075e:	8b 14 90             	mov    (%eax,%edx,4),%edx
		int shift = i % 32;
  800761:	89 d8                	mov    %ebx,%eax
  800763:	85 db                	test   %ebx,%ebx
  800765:	79 03                	jns    80076a <alloc_block+0x35>
  800767:	8d 43 1f             	lea    0x1f(%ebx),%eax
  80076a:	83 e0 e0             	and    $0xffffffe0,%eax
  80076d:	89 d9                	mov    %ebx,%ecx
  80076f:	29 c1                	sub    %eax,%ecx
		int match = 0x1 << shift;
  800771:	b8 01 00 00 00       	mov    $0x1,%eax
  800776:	d3 e0                	shl    %cl,%eax
		if (word & match) {
  800778:	85 c2                	test   %eax,%edx
  80077a:	74 2e                	je     8007aa <alloc_block+0x75>
			bitmap[i/32] &= ~match;
  80077c:	89 da                	mov    %ebx,%edx
  80077e:	85 db                	test   %ebx,%ebx
  800780:	79 03                	jns    800785 <alloc_block+0x50>
  800782:	8d 53 1f             	lea    0x1f(%ebx),%edx
  800785:	89 d1                	mov    %edx,%ecx
  800787:	c1 f9 05             	sar    $0x5,%ecx
  80078a:	8b 15 04 90 80 00    	mov    0x809004,%edx
  800790:	f7 d0                	not    %eax
  800792:	21 04 8a             	and    %eax,(%edx,%ecx,4)
			flush_block(diskaddr(i));
  800795:	83 ec 0c             	sub    $0xc,%esp
  800798:	53                   	push   %ebx
  800799:	e8 ba fa ff ff       	call   800258 <diskaddr>
  80079e:	89 04 24             	mov    %eax,(%esp)
  8007a1:	e8 6b fc ff ff       	call   800411 <flush_block>
			return i;
  8007a6:	89 d8                	mov    %ebx,%eax
  8007a8:	eb 10                	jmp    8007ba <alloc_block+0x85>
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	int i, j;
	for (i = 0; i < super->s_nblocks; i++) {
  8007aa:	43                   	inc    %ebx
  8007ab:	a1 08 90 80 00       	mov    0x809008,%eax
  8007b0:	3b 58 04             	cmp    0x4(%eax),%ebx
  8007b3:	72 96                	jb     80074b <alloc_block+0x16>
			return i;
		}
	}

//	panic("alloc_block not implemented");
	return -E_NO_DISK;
  8007b5:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
}
  8007ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007bd:	c9                   	leave  
  8007be:	c3                   	ret    

008007bf <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	53                   	push   %ebx
  8007c3:	83 ec 04             	sub    $0x4,%esp
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  8007c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007cb:	a1 08 90 80 00       	mov    0x809008,%eax
  8007d0:	3b 58 04             	cmp    0x4(%eax),%ebx
  8007d3:	73 36                	jae    80080b <check_bitmap+0x4c>
		assert(!block_is_free(2+i));
  8007d5:	8d 43 02             	lea    0x2(%ebx),%eax
  8007d8:	50                   	push   %eax
  8007d9:	e8 d2 fe ff ff       	call   8006b0 <block_is_free>
  8007de:	83 c4 04             	add    $0x4,%esp
  8007e1:	85 c0                	test   %eax,%eax
  8007e3:	74 16                	je     8007fb <check_bitmap+0x3c>
  8007e5:	68 16 36 80 00       	push   $0x803616
  8007ea:	68 7d 33 80 00       	push   $0x80337d
  8007ef:	6a 5b                	push   $0x5b
  8007f1:	68 c6 35 80 00       	push   $0x8035c6
  8007f6:	e8 05 13 00 00       	call   801b00 <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  8007fb:	43                   	inc    %ebx
  8007fc:	89 da                	mov    %ebx,%edx
  8007fe:	c1 e2 0f             	shl    $0xf,%edx
  800801:	a1 08 90 80 00       	mov    0x809008,%eax
  800806:	3b 50 04             	cmp    0x4(%eax),%edx
  800809:	72 ca                	jb     8007d5 <check_bitmap+0x16>
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  80080b:	6a 00                	push   $0x0
  80080d:	e8 9e fe ff ff       	call   8006b0 <block_is_free>
  800812:	83 c4 04             	add    $0x4,%esp
  800815:	85 c0                	test   %eax,%eax
  800817:	74 16                	je     80082f <check_bitmap+0x70>
  800819:	68 2a 36 80 00       	push   $0x80362a
  80081e:	68 7d 33 80 00       	push   $0x80337d
  800823:	6a 5e                	push   $0x5e
  800825:	68 c6 35 80 00       	push   $0x8035c6
  80082a:	e8 d1 12 00 00       	call   801b00 <_panic>
	assert(!block_is_free(1));
  80082f:	6a 01                	push   $0x1
  800831:	e8 7a fe ff ff       	call   8006b0 <block_is_free>
  800836:	83 c4 04             	add    $0x4,%esp
  800839:	85 c0                	test   %eax,%eax
  80083b:	74 16                	je     800853 <check_bitmap+0x94>
  80083d:	68 3c 36 80 00       	push   $0x80363c
  800842:	68 7d 33 80 00       	push   $0x80337d
  800847:	6a 5f                	push   $0x5f
  800849:	68 c6 35 80 00       	push   $0x8035c6
  80084e:	e8 ad 12 00 00       	call   801b00 <_panic>

	cprintf("bitmap is good\n");
  800853:	83 ec 0c             	sub    $0xc,%esp
  800856:	68 4e 36 80 00       	push   $0x80364e
  80085b:	e8 7c 13 00 00       	call   801bdc <cprintf>
}
  800860:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800863:	c9                   	leave  
  800864:	c3                   	ret    

00800865 <fs_init>:
// --------------------------------------------------------------

// Initialize the file system
void
fs_init(void)
{
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	83 ec 08             	sub    $0x8,%esp
	static_assert(sizeof(struct File) == 256);

	// Find a JOS disk.  Use the second IDE disk (number 1) if available.
	if (ide_probe_disk1())
  80086b:	e8 f5 f7 ff ff       	call   800065 <ide_probe_disk1>
  800870:	85 c0                	test   %eax,%eax
  800872:	74 0f                	je     800883 <fs_init+0x1e>
		ide_set_disk(1);
  800874:	83 ec 0c             	sub    $0xc,%esp
  800877:	6a 01                	push   $0x1
  800879:	e8 46 f8 ff ff       	call   8000c4 <ide_set_disk>
  80087e:	83 c4 10             	add    $0x10,%esp
  800881:	eb 0d                	jmp    800890 <fs_init+0x2b>
	else
		ide_set_disk(0);
  800883:	83 ec 0c             	sub    $0xc,%esp
  800886:	6a 00                	push   $0x0
  800888:	e8 37 f8 ff ff       	call   8000c4 <ide_set_disk>
  80088d:	83 c4 10             	add    $0x10,%esp

	bc_init();
  800890:	e8 ac fd ff ff       	call   800641 <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  800895:	83 ec 0c             	sub    $0xc,%esp
  800898:	6a 01                	push   $0x1
  80089a:	e8 b9 f9 ff ff       	call   800258 <diskaddr>
  80089f:	a3 08 90 80 00       	mov    %eax,0x809008
	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  8008a4:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8008ab:	e8 a8 f9 ff ff       	call   800258 <diskaddr>
  8008b0:	a3 04 90 80 00       	mov    %eax,0x809004

	check_super();
  8008b5:	e8 9e fd ff ff       	call   800658 <check_super>
	check_bitmap();
  8008ba:	e8 00 ff ff ff       	call   8007bf <check_bitmap>
}
  8008bf:	c9                   	leave  
  8008c0:	c3                   	ret    

008008c1 <file_block_walk>:
//
// Analogy: This is like pgdir_walk for files.
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	57                   	push   %edi
  8008c5:	56                   	push   %esi
  8008c6:	53                   	push   %ebx
  8008c7:	83 ec 0c             	sub    $0xc,%esp
  8008ca:	8b 75 08             	mov    0x8(%ebp),%esi
  8008cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008d0:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 5: Your code here.
	if (filebno >= (NDIRECT+NINDIRECT))
		return -E_INVAL;
  8008d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
	// LAB 5: Your code here.
	if (filebno >= (NDIRECT+NINDIRECT))
  8008d8:	81 fb 09 04 00 00    	cmp    $0x409,%ebx
  8008de:	77 71                	ja     800951 <file_block_walk+0x90>
		return -E_INVAL;
	if (filebno < NDIRECT) {
  8008e0:	83 fb 09             	cmp    $0x9,%ebx
  8008e3:	77 0b                	ja     8008f0 <file_block_walk+0x2f>
		*ppdiskbno = &f->f_direct[filebno];
  8008e5:	8d 84 9e 88 00 00 00 	lea    0x88(%esi,%ebx,4),%eax
  8008ec:	89 07                	mov    %eax,(%edi)
  8008ee:	eb 5c                	jmp    80094c <file_block_walk+0x8b>
	} else {
		if (!f->f_indirect) {
  8008f0:	83 be b0 00 00 00 00 	cmpl   $0x0,0xb0(%esi)
  8008f7:	75 3c                	jne    800935 <file_block_walk+0x74>
				if ((blkno = alloc_block()) < 0)
					return -E_NO_DISK; 
				f->f_indirect = blkno;
				memset(diskaddr(blkno), 0, BLKSIZE);
			} else 
				return -E_NOT_FOUND;
  8008f9:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
		return -E_INVAL;
	if (filebno < NDIRECT) {
		*ppdiskbno = &f->f_direct[filebno];
	} else {
		if (!f->f_indirect) {
			if (alloc) {
  8008fe:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
  800902:	74 4d                	je     800951 <file_block_walk+0x90>
				int blkno;
				if ((blkno = alloc_block()) < 0)
  800904:	e8 2c fe ff ff       	call   800735 <alloc_block>
  800909:	89 c2                	mov    %eax,%edx
					return -E_NO_DISK; 
  80090b:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
		*ppdiskbno = &f->f_direct[filebno];
	} else {
		if (!f->f_indirect) {
			if (alloc) {
				int blkno;
				if ((blkno = alloc_block()) < 0)
  800910:	85 d2                	test   %edx,%edx
  800912:	78 3d                	js     800951 <file_block_walk+0x90>
					return -E_NO_DISK; 
				f->f_indirect = blkno;
  800914:	89 96 b0 00 00 00    	mov    %edx,0xb0(%esi)
				memset(diskaddr(blkno), 0, BLKSIZE);
  80091a:	83 ec 04             	sub    $0x4,%esp
  80091d:	68 00 10 00 00       	push   $0x1000
  800922:	6a 00                	push   $0x0
  800924:	52                   	push   %edx
  800925:	e8 2e f9 ff ff       	call   800258 <diskaddr>
  80092a:	89 04 24             	mov    %eax,(%esp)
  80092d:	e8 f7 18 00 00       	call   802229 <memset>
  800932:	83 c4 10             	add    $0x10,%esp
			} else 
				return -E_NOT_FOUND;
		}
		*ppdiskbno = &((int *)diskaddr(f->f_indirect))[filebno-NDIRECT];
  800935:	83 ec 0c             	sub    $0xc,%esp
  800938:	ff b6 b0 00 00 00    	pushl  0xb0(%esi)
  80093e:	e8 15 f9 ff ff       	call   800258 <diskaddr>
  800943:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
  800947:	89 07                	mov    %eax,(%edi)
  800949:	83 c4 10             	add    $0x10,%esp
	}
	return 0;
  80094c:	b8 00 00 00 00       	mov    $0x0,%eax

	//panic("file_block_walk not implemented");
}
  800951:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800954:	5b                   	pop    %ebx
  800955:	5e                   	pop    %esi
  800956:	5f                   	pop    %edi
  800957:	c9                   	leave  
  800958:	c3                   	ret    

00800959 <file_get_block>:
//
// Hint: Use file_block_walk and alloc_block.
//^&^ entry in struct File contains block number, not addr of that block...
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	83 ec 08             	sub    $0x8,%esp
	// LAB 5: Your code here.
	uint32_t *ppdiskbno;
	int r;
	if ((r = file_block_walk(f, filebno, &ppdiskbno, 1)) < 0)
  80095f:	6a 01                	push   $0x1
  800961:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800964:	50                   	push   %eax
  800965:	ff 75 0c             	pushl  0xc(%ebp)
  800968:	ff 75 08             	pushl  0x8(%ebp)
  80096b:	e8 51 ff ff ff       	call   8008c1 <file_block_walk>
  800970:	83 c4 10             	add    $0x10,%esp
		return r;
  800973:	89 c2                	mov    %eax,%edx
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
	// LAB 5: Your code here.
	uint32_t *ppdiskbno;
	int r;
	if ((r = file_block_walk(f, filebno, &ppdiskbno, 1)) < 0)
  800975:	85 c0                	test   %eax,%eax
  800977:	78 34                	js     8009ad <file_get_block+0x54>
		return r;
	if (!*ppdiskbno) {
  800979:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80097c:	83 38 00             	cmpl   $0x0,(%eax)
  80097f:	75 15                	jne    800996 <file_get_block+0x3d>
		int blkno = alloc_block();
  800981:	e8 af fd ff ff       	call   800735 <alloc_block>
  800986:	89 c1                	mov    %eax,%ecx
		if (blkno < 0)
			return -E_NO_DISK;
  800988:	ba f7 ff ff ff       	mov    $0xfffffff7,%edx
	int r;
	if ((r = file_block_walk(f, filebno, &ppdiskbno, 1)) < 0)
		return r;
	if (!*ppdiskbno) {
		int blkno = alloc_block();
		if (blkno < 0)
  80098d:	85 c0                	test   %eax,%eax
  80098f:	78 1c                	js     8009ad <file_get_block+0x54>
			return -E_NO_DISK;
		*ppdiskbno = blkno;
  800991:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800994:	89 08                	mov    %ecx,(%eax)
	}
	*blk = (char *) diskaddr(*ppdiskbno);
  800996:	83 ec 0c             	sub    $0xc,%esp
  800999:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80099c:	ff 30                	pushl  (%eax)
  80099e:	e8 b5 f8 ff ff       	call   800258 <diskaddr>
  8009a3:	8b 55 10             	mov    0x10(%ebp),%edx
  8009a6:	89 02                	mov    %eax,(%edx)
	return 0;
  8009a8:	ba 00 00 00 00       	mov    $0x0,%edx
//	panic("file_get_block not implemented");
}
  8009ad:	89 d0                	mov    %edx,%eax
  8009af:	c9                   	leave  
  8009b0:	c3                   	ret    

008009b1 <dir_lookup>:
//
// Returns 0 and sets *file on success, < 0 on error.  Errors are:
//	-E_NOT_FOUND if the file is not found
static int
dir_lookup(struct File *dir, const char *name, struct File **file)
{
  8009b1:	55                   	push   %ebp
  8009b2:	89 e5                	mov    %esp,%ebp
  8009b4:	57                   	push   %edi
  8009b5:	56                   	push   %esi
  8009b6:	53                   	push   %ebx
  8009b7:	83 ec 0c             	sub    $0xc,%esp
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  8009ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bd:	66 f7 80 80 00 00 00 	testw  $0xfff,0x80(%eax)
  8009c4:	ff 0f 
  8009c6:	74 25                	je     8009ed <dir_lookup+0x3c>
  8009c8:	68 5e 36 80 00       	push   $0x80365e
  8009cd:	68 7d 33 80 00       	push   $0x80337d
  8009d2:	68 d5 00 00 00       	push   $0xd5
  8009d7:	68 c6 35 80 00       	push   $0x8035c6
  8009dc:	e8 1f 11 00 00       	call   801b00 <_panic>
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
				*file = &f[j];
  8009e1:	8b 45 10             	mov    0x10(%ebp),%eax
  8009e4:	89 30                	mov    %esi,(%eax)
				return 0;
  8009e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009eb:	eb 76                	jmp    800a63 <dir_lookup+0xb2>

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
  8009ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f0:	8b 82 80 00 00 00    	mov    0x80(%edx),%eax
  8009f6:	85 c0                	test   %eax,%eax
  8009f8:	79 05                	jns    8009ff <dir_lookup+0x4e>
  8009fa:	05 ff 0f 00 00       	add    $0xfff,%eax
  8009ff:	c1 f8 0c             	sar    $0xc,%eax
  800a02:	89 45 e8             	mov    %eax,-0x18(%ebp)
	for (i = 0; i < nblock; i++) {
  800a05:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  800a0c:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  800a0f:	73 4d                	jae    800a5e <dir_lookup+0xad>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800a11:	83 ec 04             	sub    $0x4,%esp
  800a14:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a17:	50                   	push   %eax
  800a18:	ff 75 ec             	pushl  -0x14(%ebp)
  800a1b:	ff 75 08             	pushl  0x8(%ebp)
  800a1e:	e8 36 ff ff ff       	call   800959 <file_get_block>
  800a23:	83 c4 10             	add    $0x10,%esp
  800a26:	85 c0                	test   %eax,%eax
  800a28:	78 39                	js     800a63 <dir_lookup+0xb2>
			return r;
		f = (struct File*) blk;
  800a2a:	8b 7d f0             	mov    -0x10(%ebp),%edi
		for (j = 0; j < BLKFILES; j++)
  800a2d:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (strcmp(f[j].f_name, name) == 0) {
  800a32:	83 ec 08             	sub    $0x8,%esp
  800a35:	ff 75 0c             	pushl  0xc(%ebp)
  800a38:	89 d8                	mov    %ebx,%eax
  800a3a:	c1 e0 08             	shl    $0x8,%eax
  800a3d:	8d 34 38             	lea    (%eax,%edi,1),%esi
  800a40:	56                   	push   %esi
  800a41:	e8 3b 17 00 00       	call   802181 <strcmp>
  800a46:	83 c4 10             	add    $0x10,%esp
  800a49:	85 c0                	test   %eax,%eax
  800a4b:	74 94                	je     8009e1 <dir_lookup+0x30>
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800a4d:	43                   	inc    %ebx
  800a4e:	83 fb 0f             	cmp    $0xf,%ebx
  800a51:	76 df                	jbe    800a32 <dir_lookup+0x81>
	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800a53:	ff 45 ec             	incl   -0x14(%ebp)
  800a56:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a59:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  800a5c:	72 b3                	jb     800a11 <dir_lookup+0x60>
			if (strcmp(f[j].f_name, name) == 0) {
				*file = &f[j];
				return 0;
			}
	}
	return -E_NOT_FOUND;
  800a5e:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
}
  800a63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a66:	5b                   	pop    %ebx
  800a67:	5e                   	pop    %esi
  800a68:	5f                   	pop    %edi
  800a69:	c9                   	leave  
  800a6a:	c3                   	ret    

00800a6b <dir_alloc_file>:

// Set *file to point at a free File structure in dir.  The caller is
// responsible for filling in the File fields.
static int
dir_alloc_file(struct File *dir, struct File **file)
{
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	57                   	push   %edi
  800a6f:	56                   	push   %esi
  800a70:	53                   	push   %ebx
  800a71:	83 ec 0c             	sub    $0xc,%esp
  800a74:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  800a77:	66 f7 86 80 00 00 00 	testw  $0xfff,0x80(%esi)
  800a7e:	ff 0f 
  800a80:	74 19                	je     800a9b <dir_alloc_file+0x30>
  800a82:	68 5e 36 80 00       	push   $0x80365e
  800a87:	68 7d 33 80 00       	push   $0x80337d
  800a8c:	68 ee 00 00 00       	push   $0xee
  800a91:	68 c6 35 80 00       	push   $0x8035c6
  800a96:	e8 65 10 00 00       	call   801b00 <_panic>
	nblock = dir->f_size / BLKSIZE;
  800a9b:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800aa1:	85 c0                	test   %eax,%eax
  800aa3:	79 05                	jns    800aaa <dir_alloc_file+0x3f>
  800aa5:	05 ff 0f 00 00       	add    $0xfff,%eax
  800aaa:	89 c7                	mov    %eax,%edi
  800aac:	c1 ff 0c             	sar    $0xc,%edi
	for (i = 0; i < nblock; i++) {
  800aaf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ab4:	39 fb                	cmp    %edi,%ebx
  800ab6:	73 33                	jae    800aeb <dir_alloc_file+0x80>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800ab8:	83 ec 04             	sub    $0x4,%esp
  800abb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800abe:	50                   	push   %eax
  800abf:	53                   	push   %ebx
  800ac0:	56                   	push   %esi
  800ac1:	e8 93 fe ff ff       	call   800959 <file_get_block>
  800ac6:	83 c4 10             	add    $0x10,%esp
  800ac9:	85 c0                	test   %eax,%eax
  800acb:	78 41                	js     800b0e <dir_alloc_file+0xa3>
			return r;
		f = (struct File*) blk;
  800acd:	8b 4d f0             	mov    -0x10(%ebp),%ecx
		for (j = 0; j < BLKFILES; j++)
  800ad0:	ba 00 00 00 00       	mov    $0x0,%edx
			if (f[j].f_name[0] == '\0') {
  800ad5:	89 d0                	mov    %edx,%eax
  800ad7:	c1 e0 08             	shl    $0x8,%eax
  800ada:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  800ade:	74 32                	je     800b12 <dir_alloc_file+0xa7>
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800ae0:	42                   	inc    %edx
  800ae1:	83 fa 0f             	cmp    $0xf,%edx
  800ae4:	76 ef                	jbe    800ad5 <dir_alloc_file+0x6a>
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800ae6:	43                   	inc    %ebx
  800ae7:	39 fb                	cmp    %edi,%ebx
  800ae9:	72 cd                	jb     800ab8 <dir_alloc_file+0x4d>
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
  800aeb:	81 86 80 00 00 00 00 	addl   $0x1000,0x80(%esi)
  800af2:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  800af5:	83 ec 04             	sub    $0x4,%esp
  800af8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800afb:	50                   	push   %eax
  800afc:	53                   	push   %ebx
  800afd:	56                   	push   %esi
  800afe:	e8 56 fe ff ff       	call   800959 <file_get_block>
  800b03:	83 c4 10             	add    $0x10,%esp
		return r;
  800b06:	89 c2                	mov    %eax,%edx
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
	if ((r = file_get_block(dir, i, &blk)) < 0)
  800b08:	85 c0                	test   %eax,%eax
  800b0a:	78 21                	js     800b2d <dir_alloc_file+0xc2>
  800b0c:	eb 12                	jmp    800b20 <dir_alloc_file+0xb5>

	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
  800b0e:	89 c2                	mov    %eax,%edx
  800b10:	eb 1b                	jmp    800b2d <dir_alloc_file+0xc2>
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
  800b12:	01 c8                	add    %ecx,%eax
  800b14:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b17:	89 02                	mov    %eax,(%edx)
				return 0;
  800b19:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1e:	eb 0d                	jmp    800b2d <dir_alloc_file+0xc2>
			}
	}
	dir->f_size += BLKSIZE;
	if ((r = file_get_block(dir, i, &blk)) < 0)
		return r;
	f = (struct File*) blk;
  800b20:	8b 4d f0             	mov    -0x10(%ebp),%ecx
	*file = &f[0];
  800b23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b26:	89 08                	mov    %ecx,(%eax)
	return 0;
  800b28:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800b2d:	89 d0                	mov    %edx,%eax
  800b2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b32:	5b                   	pop    %ebx
  800b33:	5e                   	pop    %esi
  800b34:	5f                   	pop    %edi
  800b35:	c9                   	leave  
  800b36:	c3                   	ret    

00800b37 <skip_slash>:

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	8b 45 08             	mov    0x8(%ebp),%eax
	while (*p == '/')
		p++;
  800b3d:	80 38 2f             	cmpb   $0x2f,(%eax)
  800b40:	75 06                	jne    800b48 <skip_slash+0x11>
  800b42:	40                   	inc    %eax
  800b43:	80 38 2f             	cmpb   $0x2f,(%eax)
  800b46:	74 fa                	je     800b42 <skip_slash+0xb>
	return p;
}
  800b48:	c9                   	leave  
  800b49:	c3                   	ret    

00800b4a <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	57                   	push   %edi
  800b4e:	56                   	push   %esi
  800b4f:	53                   	push   %ebx
  800b50:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	struct File *dir, *f;
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
  800b56:	ff 75 08             	pushl  0x8(%ebp)
  800b59:	e8 d9 ff ff ff       	call   800b37 <skip_slash>
  800b5e:	89 c6                	mov    %eax,%esi
	f = &super->s_root;
  800b60:	a1 08 90 80 00       	mov    0x809008,%eax
  800b65:	83 c0 08             	add    $0x8,%eax
  800b68:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
	dir = 0;
  800b6e:	bf 00 00 00 00       	mov    $0x0,%edi
	name[0] = 0;
  800b73:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  800b7a:	83 c4 04             	add    $0x4,%esp
  800b7d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b81:	74 09                	je     800b8c <walk_path+0x42>
		*pdir = 0;
  800b83:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b86:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pf = 0;
  800b8c:	8b 55 10             	mov    0x10(%ebp),%edx
  800b8f:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  800b95:	80 3e 00             	cmpb   $0x0,(%esi)
  800b98:	0f 84 d1 00 00 00    	je     800c6f <walk_path+0x125>

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
  800b9e:	8b bd 64 ff ff ff    	mov    -0x9c(%ebp),%edi
		p = path;
  800ba4:	89 f2                	mov    %esi,%edx
		while (*path != '/' && *path != '\0')
			path++;
  800ba6:	80 3e 2f             	cmpb   $0x2f,(%esi)
  800ba9:	74 10                	je     800bbb <walk_path+0x71>
  800bab:	80 3e 00             	cmpb   $0x0,(%esi)
  800bae:	74 0b                	je     800bbb <walk_path+0x71>
  800bb0:	46                   	inc    %esi
  800bb1:	80 3e 2f             	cmpb   $0x2f,(%esi)
  800bb4:	74 05                	je     800bbb <walk_path+0x71>
  800bb6:	80 3e 00             	cmpb   $0x0,(%esi)
  800bb9:	75 f5                	jne    800bb0 <walk_path+0x66>
		if (path - p >= MAXNAMELEN)
  800bbb:	89 f0                	mov    %esi,%eax
  800bbd:	29 d0                	sub    %edx,%eax
  800bbf:	83 f8 7f             	cmp    $0x7f,%eax
  800bc2:	7e 0a                	jle    800bce <walk_path+0x84>
			return -E_BAD_PATH;
  800bc4:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800bc9:	e9 bc 00 00 00       	jmp    800c8a <walk_path+0x140>
		memmove(name, p, path - p);
  800bce:	83 ec 04             	sub    $0x4,%esp
  800bd1:	89 f3                	mov    %esi,%ebx
  800bd3:	29 d3                	sub    %edx,%ebx
  800bd5:	53                   	push   %ebx
  800bd6:	52                   	push   %edx
  800bd7:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800bdd:	50                   	push   %eax
  800bde:	e8 99 16 00 00       	call   80227c <memmove>
		name[path - p] = '\0';
  800be3:	c6 84 1d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%ebx,1)
  800bea:	00 
		path = skip_slash(path);
  800beb:	56                   	push   %esi
  800bec:	e8 46 ff ff ff       	call   800b37 <skip_slash>
  800bf1:	89 c6                	mov    %eax,%esi

		if (dir->f_type != FTYPE_DIR)
  800bf3:	83 c4 14             	add    $0x14,%esp
  800bf6:	83 bf 84 00 00 00 01 	cmpl   $0x1,0x84(%edi)
  800bfd:	74 0a                	je     800c09 <walk_path+0xbf>
			return -E_NOT_FOUND;
  800bff:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800c04:	e9 81 00 00 00       	jmp    800c8a <walk_path+0x140>

		if ((r = dir_lookup(dir, name, &f)) < 0) {
  800c09:	83 ec 04             	sub    $0x4,%esp
  800c0c:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  800c12:	50                   	push   %eax
  800c13:	8d 95 68 ff ff ff    	lea    -0x98(%ebp),%edx
  800c19:	52                   	push   %edx
  800c1a:	57                   	push   %edi
  800c1b:	e8 91 fd ff ff       	call   8009b1 <dir_lookup>
  800c20:	89 c3                	mov    %eax,%ebx
  800c22:	83 c4 10             	add    $0x10,%esp
  800c25:	85 c0                	test   %eax,%eax
  800c27:	79 3d                	jns    800c66 <walk_path+0x11c>
			if (r == -E_NOT_FOUND && *path == '\0') {
  800c29:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800c2c:	75 34                	jne    800c62 <walk_path+0x118>
  800c2e:	80 3e 00             	cmpb   $0x0,(%esi)
  800c31:	75 2f                	jne    800c62 <walk_path+0x118>
				if (pdir)
  800c33:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c37:	74 05                	je     800c3e <walk_path+0xf4>
					*pdir = dir;
  800c39:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c3c:	89 38                	mov    %edi,(%eax)
				if (lastelem)
  800c3e:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
  800c42:	74 15                	je     800c59 <walk_path+0x10f>
					strcpy(lastelem, name);
  800c44:	83 ec 08             	sub    $0x8,%esp
  800c47:	8d 95 68 ff ff ff    	lea    -0x98(%ebp),%edx
  800c4d:	52                   	push   %edx
  800c4e:	ff 75 14             	pushl  0x14(%ebp)
  800c51:	e8 8a 14 00 00       	call   8020e0 <strcpy>
  800c56:	83 c4 10             	add    $0x10,%esp
				*pf = 0;
  800c59:	8b 45 10             	mov    0x10(%ebp),%eax
  800c5c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			}
			return r;
  800c62:	89 d8                	mov    %ebx,%eax
  800c64:	eb 24                	jmp    800c8a <walk_path+0x140>
  800c66:	80 3e 00             	cmpb   $0x0,(%esi)
  800c69:	0f 85 2f ff ff ff    	jne    800b9e <walk_path+0x54>
		}
	}

	if (pdir)
  800c6f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c73:	74 05                	je     800c7a <walk_path+0x130>
		*pdir = dir;
  800c75:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c78:	89 3a                	mov    %edi,(%edx)
	*pf = f;
  800c7a:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
  800c80:	8b 55 10             	mov    0x10(%ebp),%edx
  800c83:	89 02                	mov    %eax,(%edx)
	return 0;
  800c85:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8d:	5b                   	pop    %ebx
  800c8e:	5e                   	pop    %esi
  800c8f:	5f                   	pop    %edi
  800c90:	c9                   	leave  
  800c91:	c3                   	ret    

00800c92 <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  800c92:	55                   	push   %ebp
  800c93:	89 e5                	mov    %esp,%ebp
  800c95:	81 ec 98 00 00 00    	sub    $0x98,%esp
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  800c9b:	8d 85 78 ff ff ff    	lea    -0x88(%ebp),%eax
  800ca1:	50                   	push   %eax
  800ca2:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
  800ca8:	50                   	push   %eax
  800ca9:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
  800caf:	50                   	push   %eax
  800cb0:	ff 75 08             	pushl  0x8(%ebp)
  800cb3:	e8 92 fe ff ff       	call   800b4a <walk_path>
  800cb8:	83 c4 10             	add    $0x10,%esp
		return -E_FILE_EXISTS;
  800cbb:	ba f3 ff ff ff       	mov    $0xfffffff3,%edx
{
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  800cc0:	85 c0                	test   %eax,%eax
  800cc2:	74 63                	je     800d27 <file_create+0x95>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  800cc4:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800cc7:	75 09                	jne    800cd2 <file_create+0x40>
  800cc9:	83 bd 70 ff ff ff 00 	cmpl   $0x0,-0x90(%ebp)
  800cd0:	75 04                	jne    800cd6 <file_create+0x44>
		return r;
  800cd2:	89 c2                	mov    %eax,%edx
  800cd4:	eb 51                	jmp    800d27 <file_create+0x95>
	if ((r = dir_alloc_file(dir, &f)) < 0)
  800cd6:	83 ec 08             	sub    $0x8,%esp
  800cd9:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
  800cdf:	50                   	push   %eax
  800ce0:	ff b5 70 ff ff ff    	pushl  -0x90(%ebp)
  800ce6:	e8 80 fd ff ff       	call   800a6b <dir_alloc_file>
  800ceb:	83 c4 10             	add    $0x10,%esp
		return r;
  800cee:	89 c2                	mov    %eax,%edx

	if ((r = walk_path(path, &dir, &f, name)) == 0)
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
		return r;
	if ((r = dir_alloc_file(dir, &f)) < 0)
  800cf0:	85 c0                	test   %eax,%eax
  800cf2:	78 33                	js     800d27 <file_create+0x95>
		return r;
	strcpy(f->f_name, name);
  800cf4:	83 ec 08             	sub    $0x8,%esp
  800cf7:	8d 85 78 ff ff ff    	lea    -0x88(%ebp),%eax
  800cfd:	50                   	push   %eax
  800cfe:	ff b5 74 ff ff ff    	pushl  -0x8c(%ebp)
  800d04:	e8 d7 13 00 00       	call   8020e0 <strcpy>
	*pf = f;
  800d09:	8b 95 74 ff ff ff    	mov    -0x8c(%ebp),%edx
  800d0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d12:	89 10                	mov    %edx,(%eax)
	file_flush(dir);
  800d14:	83 c4 04             	add    $0x4,%esp
  800d17:	ff b5 70 ff ff ff    	pushl  -0x90(%ebp)
  800d1d:	e8 09 03 00 00       	call   80102b <file_flush>
	return 0;
  800d22:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800d27:	89 d0                	mov    %edx,%eax
  800d29:	c9                   	leave  
  800d2a:	c3                   	ret    

00800d2b <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	83 ec 08             	sub    $0x8,%esp
	return walk_path(path, 0, pf, 0);
  800d31:	6a 00                	push   $0x0
  800d33:	ff 75 0c             	pushl  0xc(%ebp)
  800d36:	6a 00                	push   $0x0
  800d38:	ff 75 08             	pushl  0x8(%ebp)
  800d3b:	e8 0a fe ff ff       	call   800b4a <walk_path>
}
  800d40:	c9                   	leave  
  800d41:	c3                   	ret    

00800d42 <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800d42:	55                   	push   %ebp
  800d43:	89 e5                	mov    %esp,%ebp
  800d45:	57                   	push   %edi
  800d46:	56                   	push   %esi
  800d47:	53                   	push   %ebx
  800d48:	83 ec 0c             	sub    $0xc,%esp
  800d4b:	8b 7d 10             	mov    0x10(%ebp),%edi
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
		return 0;
  800d4e:	b8 00 00 00 00       	mov    $0x0,%eax
{
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800d53:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800d56:	8b 55 08             	mov    0x8(%ebp),%edx
  800d59:	39 8a 80 00 00 00    	cmp    %ecx,0x80(%edx)
  800d5f:	0f 8e b3 00 00 00    	jle    800e18 <file_read+0xd6>
		return 0;

	count = MIN(count, f->f_size - offset);
  800d65:	8b 55 08             	mov    0x8(%ebp),%edx
  800d68:	8b 82 80 00 00 00    	mov    0x80(%edx),%eax
  800d6e:	2b 45 14             	sub    0x14(%ebp),%eax
  800d71:	89 fa                	mov    %edi,%edx
  800d73:	39 c7                	cmp    %eax,%edi
  800d75:	76 02                	jbe    800d79 <file_read+0x37>
  800d77:	89 c2                	mov    %eax,%edx
  800d79:	89 d7                	mov    %edx,%edi

	for (pos = offset; pos < offset + count; ) {
  800d7b:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800d7e:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  800d81:	39 c3                	cmp    %eax,%ebx
  800d83:	0f 83 8d 00 00 00    	jae    800e16 <file_read+0xd4>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0) {
  800d89:	83 ec 04             	sub    $0x4,%esp
  800d8c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d8f:	50                   	push   %eax
  800d90:	89 d8                	mov    %ebx,%eax
  800d92:	85 db                	test   %ebx,%ebx
  800d94:	79 06                	jns    800d9c <file_read+0x5a>
  800d96:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  800d9c:	c1 f8 0c             	sar    $0xc,%eax
  800d9f:	50                   	push   %eax
  800da0:	ff 75 08             	pushl  0x8(%ebp)
  800da3:	e8 b1 fb ff ff       	call   800959 <file_get_block>
  800da8:	83 c4 10             	add    $0x10,%esp
  800dab:	85 c0                	test   %eax,%eax
  800dad:	78 69                	js     800e18 <file_read+0xd6>
			return r;
		}
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800daf:	89 d8                	mov    %ebx,%eax
  800db1:	85 db                	test   %ebx,%ebx
  800db3:	79 06                	jns    800dbb <file_read+0x79>
  800db5:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  800dbb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800dc0:	89 da                	mov    %ebx,%edx
  800dc2:	29 c2                	sub    %eax,%edx
  800dc4:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800dc7:	01 f9                	add    %edi,%ecx
  800dc9:	29 d9                	sub    %ebx,%ecx
  800dcb:	b8 00 10 00 00       	mov    $0x1000,%eax
  800dd0:	29 d0                	sub    %edx,%eax
  800dd2:	39 c8                	cmp    %ecx,%eax
  800dd4:	76 02                	jbe    800dd8 <file_read+0x96>
  800dd6:	89 c8                	mov    %ecx,%eax
  800dd8:	89 c6                	mov    %eax,%esi
		memmove(buf, blk + pos % BLKSIZE, bn);
  800dda:	83 ec 04             	sub    $0x4,%esp
  800ddd:	50                   	push   %eax
  800dde:	89 d8                	mov    %ebx,%eax
  800de0:	85 db                	test   %ebx,%ebx
  800de2:	79 06                	jns    800dea <file_read+0xa8>
  800de4:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  800dea:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800def:	89 d9                	mov    %ebx,%ecx
  800df1:	29 c1                	sub    %eax,%ecx
  800df3:	89 c8                	mov    %ecx,%eax
  800df5:	03 45 f0             	add    -0x10(%ebp),%eax
  800df8:	50                   	push   %eax
  800df9:	ff 75 0c             	pushl  0xc(%ebp)
  800dfc:	e8 7b 14 00 00       	call   80227c <memmove>
		pos += bn;
  800e01:	01 f3                	add    %esi,%ebx
		buf += bn;
  800e03:	01 75 0c             	add    %esi,0xc(%ebp)
	if (offset >= f->f_size)
		return 0;

	count = MIN(count, f->f_size - offset);

	for (pos = offset; pos < offset + count; ) {
  800e06:	83 c4 10             	add    $0x10,%esp
  800e09:	8b 45 14             	mov    0x14(%ebp),%eax
  800e0c:	01 f8                	add    %edi,%eax
  800e0e:	39 c3                	cmp    %eax,%ebx
  800e10:	0f 82 73 ff ff ff    	jb     800d89 <file_read+0x47>
		memmove(buf, blk + pos % BLKSIZE, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800e16:	89 f8                	mov    %edi,%eax
}
  800e18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1b:	5b                   	pop    %ebx
  800e1c:	5e                   	pop    %esi
  800e1d:	5f                   	pop    %edi
  800e1e:	c9                   	leave  
  800e1f:	c3                   	ret    

00800e20 <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  800e20:	55                   	push   %ebp
  800e21:	89 e5                	mov    %esp,%ebp
  800e23:	57                   	push   %edi
  800e24:	56                   	push   %esi
  800e25:	53                   	push   %ebx
  800e26:	83 ec 0c             	sub    $0xc,%esp
  800e29:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e2c:	8b 75 14             	mov    0x14(%ebp),%esi
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
  800e2f:	8b 55 10             	mov    0x10(%ebp),%edx
  800e32:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800e35:	8b 55 08             	mov    0x8(%ebp),%edx
  800e38:	3b 82 80 00 00 00    	cmp    0x80(%edx),%eax
  800e3e:	76 20                	jbe    800e60 <file_write+0x40>
		if ((r = file_set_size(f, offset + count)) < 0)
  800e40:	83 ec 08             	sub    $0x8,%esp
  800e43:	50                   	push   %eax
  800e44:	52                   	push   %edx
  800e45:	e8 a6 01 00 00       	call   800ff0 <file_set_size>
  800e4a:	83 c4 10             	add    $0x10,%esp
			return r;
  800e4d:	89 c2                	mov    %eax,%edx
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
		if ((r = file_set_size(f, offset + count)) < 0)
  800e4f:	85 c0                	test   %eax,%eax
  800e51:	0f 88 9f 00 00 00    	js     800ef6 <file_write+0xd6>
  800e57:	eb 07                	jmp    800e60 <file_write+0x40>
			return r;

	for (pos = offset; pos < offset + count; ) {
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
			return r;
  800e59:	89 c2                	mov    %eax,%edx
  800e5b:	e9 96 00 00 00       	jmp    800ef6 <file_write+0xd6>
	// Extend file if necessary
	if (offset + count > f->f_size)
		if ((r = file_set_size(f, offset + count)) < 0)
			return r;

	for (pos = offset; pos < offset + count; ) {
  800e60:	89 f3                	mov    %esi,%ebx
  800e62:	8b 55 10             	mov    0x10(%ebp),%edx
  800e65:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800e68:	39 c6                	cmp    %eax,%esi
  800e6a:	0f 83 83 00 00 00    	jae    800ef3 <file_write+0xd3>
  800e70:	89 45 ec             	mov    %eax,-0x14(%ebp)
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800e73:	83 ec 04             	sub    $0x4,%esp
  800e76:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e79:	50                   	push   %eax
  800e7a:	89 d8                	mov    %ebx,%eax
  800e7c:	85 db                	test   %ebx,%ebx
  800e7e:	79 06                	jns    800e86 <file_write+0x66>
  800e80:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  800e86:	c1 f8 0c             	sar    $0xc,%eax
  800e89:	50                   	push   %eax
  800e8a:	ff 75 08             	pushl  0x8(%ebp)
  800e8d:	e8 c7 fa ff ff       	call   800959 <file_get_block>
  800e92:	83 c4 10             	add    $0x10,%esp
  800e95:	85 c0                	test   %eax,%eax
  800e97:	78 c0                	js     800e59 <file_write+0x39>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800e99:	89 d8                	mov    %ebx,%eax
  800e9b:	85 db                	test   %ebx,%ebx
  800e9d:	79 06                	jns    800ea5 <file_write+0x85>
  800e9f:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  800ea5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800eaa:	89 da                	mov    %ebx,%edx
  800eac:	29 c2                	sub    %eax,%edx
  800eae:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800eb1:	29 d9                	sub    %ebx,%ecx
  800eb3:	b8 00 10 00 00       	mov    $0x1000,%eax
  800eb8:	29 d0                	sub    %edx,%eax
  800eba:	39 c8                	cmp    %ecx,%eax
  800ebc:	76 02                	jbe    800ec0 <file_write+0xa0>
  800ebe:	89 c8                	mov    %ecx,%eax
  800ec0:	89 c6                	mov    %eax,%esi
		memmove(blk + pos % BLKSIZE, buf, bn);
  800ec2:	83 ec 04             	sub    $0x4,%esp
  800ec5:	50                   	push   %eax
  800ec6:	57                   	push   %edi
  800ec7:	89 d8                	mov    %ebx,%eax
  800ec9:	85 db                	test   %ebx,%ebx
  800ecb:	79 06                	jns    800ed3 <file_write+0xb3>
  800ecd:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  800ed3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ed8:	89 da                	mov    %ebx,%edx
  800eda:	29 c2                	sub    %eax,%edx
  800edc:	89 d0                	mov    %edx,%eax
  800ede:	03 45 f0             	add    -0x10(%ebp),%eax
  800ee1:	50                   	push   %eax
  800ee2:	e8 95 13 00 00       	call   80227c <memmove>
		pos += bn;
  800ee7:	01 f3                	add    %esi,%ebx
		buf += bn;
  800ee9:	01 f7                	add    %esi,%edi
	// Extend file if necessary
	if (offset + count > f->f_size)
		if ((r = file_set_size(f, offset + count)) < 0)
			return r;

	for (pos = offset; pos < offset + count; ) {
  800eeb:	83 c4 10             	add    $0x10,%esp
  800eee:	3b 5d ec             	cmp    -0x14(%ebp),%ebx
  800ef1:	72 80                	jb     800e73 <file_write+0x53>
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800ef3:	8b 55 10             	mov    0x10(%ebp),%edx
}
  800ef6:	89 d0                	mov    %edx,%eax
  800ef8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800efb:	5b                   	pop    %ebx
  800efc:	5e                   	pop    %esi
  800efd:	5f                   	pop    %edi
  800efe:	c9                   	leave  
  800eff:	c3                   	ret    

00800f00 <file_free_block>:

// Remove a block from file f.  If it's not there, just silently succeed.
// Returns 0 on success, < 0 on error.
static int
file_free_block(struct File *f, uint32_t filebno)
{
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	83 ec 08             	sub    $0x8,%esp
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800f06:	6a 00                	push   $0x0
  800f08:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800f0b:	50                   	push   %eax
  800f0c:	ff 75 0c             	pushl  0xc(%ebp)
  800f0f:	ff 75 08             	pushl  0x8(%ebp)
  800f12:	e8 aa f9 ff ff       	call   8008c1 <file_block_walk>
  800f17:	83 c4 10             	add    $0x10,%esp
		return r;
  800f1a:	89 c2                	mov    %eax,%edx
file_free_block(struct File *f, uint32_t filebno)
{
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800f1c:	85 c0                	test   %eax,%eax
  800f1e:	78 23                	js     800f43 <file_free_block+0x43>
		return r;
	if (*ptr) {
  800f20:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800f23:	83 38 00             	cmpl   $0x0,(%eax)
  800f26:	74 16                	je     800f3e <file_free_block+0x3e>
		free_block(*ptr);
  800f28:	83 ec 0c             	sub    $0xc,%esp
  800f2b:	ff 30                	pushl  (%eax)
  800f2d:	e8 c2 f7 ff ff       	call   8006f4 <free_block>
		*ptr = 0;
  800f32:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800f35:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800f3b:	83 c4 10             	add    $0x10,%esp
	}
	return 0;
  800f3e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800f43:	89 d0                	mov    %edx,%eax
  800f45:	c9                   	leave  
  800f46:	c3                   	ret    

00800f47 <file_truncate_blocks>:
// (Remember to clear the f->f_indirect pointer so you'll know
// whether it's valid!)
// Do not change f->f_size.
static void
file_truncate_blocks(struct File *f, off_t newsize)
{
  800f47:	55                   	push   %ebp
  800f48:	89 e5                	mov    %esp,%ebp
  800f4a:	57                   	push   %edi
  800f4b:	56                   	push   %esi
  800f4c:	53                   	push   %ebx
  800f4d:	83 ec 0c             	sub    $0xc,%esp
  800f50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800f53:	8b 45 08             	mov    0x8(%ebp),%eax
  800f56:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
  800f5c:	8d b2 ff 0f 00 00    	lea    0xfff(%edx),%esi
  800f62:	89 f0                	mov    %esi,%eax
  800f64:	85 f6                	test   %esi,%esi
  800f66:	79 06                	jns    800f6e <file_truncate_blocks+0x27>
  800f68:	8d 82 fe 1f 00 00    	lea    0x1ffe(%edx),%eax
  800f6e:	89 c6                	mov    %eax,%esi
  800f70:	c1 fe 0c             	sar    $0xc,%esi
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800f73:	8d b9 ff 0f 00 00    	lea    0xfff(%ecx),%edi
  800f79:	89 f8                	mov    %edi,%eax
  800f7b:	85 ff                	test   %edi,%edi
  800f7d:	79 06                	jns    800f85 <file_truncate_blocks+0x3e>
  800f7f:	8d 81 fe 1f 00 00    	lea    0x1ffe(%ecx),%eax
  800f85:	89 c7                	mov    %eax,%edi
  800f87:	c1 ff 0c             	sar    $0xc,%edi
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800f8a:	89 fb                	mov    %edi,%ebx
  800f8c:	39 f7                	cmp    %esi,%edi
  800f8e:	73 29                	jae    800fb9 <file_truncate_blocks+0x72>
		if ((r = file_free_block(f, bno)) < 0)
  800f90:	83 ec 08             	sub    $0x8,%esp
  800f93:	53                   	push   %ebx
  800f94:	ff 75 08             	pushl  0x8(%ebp)
  800f97:	e8 64 ff ff ff       	call   800f00 <file_free_block>
  800f9c:	83 c4 10             	add    $0x10,%esp
  800f9f:	85 c0                	test   %eax,%eax
  800fa1:	79 11                	jns    800fb4 <file_truncate_blocks+0x6d>
			cprintf("warning: file_free_block: %e", r);
  800fa3:	83 ec 08             	sub    $0x8,%esp
  800fa6:	50                   	push   %eax
  800fa7:	68 7b 36 80 00       	push   $0x80367b
  800fac:	e8 2b 0c 00 00       	call   801bdc <cprintf>
  800fb1:	83 c4 10             	add    $0x10,%esp
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800fb4:	43                   	inc    %ebx
  800fb5:	39 f3                	cmp    %esi,%ebx
  800fb7:	72 d7                	jb     800f90 <file_truncate_blocks+0x49>
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800fb9:	83 ff 0a             	cmp    $0xa,%edi
  800fbc:	77 2a                	ja     800fe8 <file_truncate_blocks+0xa1>
  800fbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc1:	83 b8 b0 00 00 00 00 	cmpl   $0x0,0xb0(%eax)
  800fc8:	74 1e                	je     800fe8 <file_truncate_blocks+0xa1>
		free_block(f->f_indirect);
  800fca:	83 ec 0c             	sub    $0xc,%esp
  800fcd:	ff b0 b0 00 00 00    	pushl  0xb0(%eax)
  800fd3:	e8 1c f7 ff ff       	call   8006f4 <free_block>
		f->f_indirect = 0;
  800fd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800fdb:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
  800fe2:	00 00 00 
  800fe5:	83 c4 10             	add    $0x10,%esp
	}
}
  800fe8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800feb:	5b                   	pop    %ebx
  800fec:	5e                   	pop    %esi
  800fed:	5f                   	pop    %edi
  800fee:	c9                   	leave  
  800fef:	c3                   	ret    

00800ff0 <file_set_size>:

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	56                   	push   %esi
  800ff4:	53                   	push   %ebx
  800ff5:	8b 75 08             	mov    0x8(%ebp),%esi
  800ff8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if (f->f_size > newsize)
  800ffb:	39 9e 80 00 00 00    	cmp    %ebx,0x80(%esi)
  801001:	7e 0d                	jle    801010 <file_set_size+0x20>
		file_truncate_blocks(f, newsize);
  801003:	83 ec 08             	sub    $0x8,%esp
  801006:	53                   	push   %ebx
  801007:	56                   	push   %esi
  801008:	e8 3a ff ff ff       	call   800f47 <file_truncate_blocks>
  80100d:	83 c4 10             	add    $0x10,%esp
	f->f_size = newsize;
  801010:	89 9e 80 00 00 00    	mov    %ebx,0x80(%esi)
	flush_block(f);
  801016:	83 ec 0c             	sub    $0xc,%esp
  801019:	56                   	push   %esi
  80101a:	e8 f2 f3 ff ff       	call   800411 <flush_block>
	return 0;
}
  80101f:	b8 00 00 00 00       	mov    $0x0,%eax
  801024:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801027:	5b                   	pop    %ebx
  801028:	5e                   	pop    %esi
  801029:	c9                   	leave  
  80102a:	c3                   	ret    

0080102b <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  80102b:	55                   	push   %ebp
  80102c:	89 e5                	mov    %esp,%ebp
  80102e:	56                   	push   %esi
  80102f:	53                   	push   %ebx
  801030:	83 ec 10             	sub    $0x10,%esp
  801033:	8b 75 08             	mov    0x8(%ebp),%esi
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  801036:	bb 00 00 00 00       	mov    $0x0,%ebx
  80103b:	eb 38                	jmp    801075 <file_flush+0x4a>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  80103d:	6a 00                	push   $0x0
  80103f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801042:	50                   	push   %eax
  801043:	53                   	push   %ebx
  801044:	56                   	push   %esi
  801045:	e8 77 f8 ff ff       	call   8008c1 <file_block_walk>
  80104a:	83 c4 10             	add    $0x10,%esp
  80104d:	85 c0                	test   %eax,%eax
  80104f:	78 23                	js     801074 <file_flush+0x49>
  801051:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  801055:	74 1d                	je     801074 <file_flush+0x49>
  801057:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80105a:	83 38 00             	cmpl   $0x0,(%eax)
  80105d:	74 15                	je     801074 <file_flush+0x49>
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
  80105f:	83 ec 0c             	sub    $0xc,%esp
  801062:	ff 30                	pushl  (%eax)
  801064:	e8 ef f1 ff ff       	call   800258 <diskaddr>
  801069:	89 04 24             	mov    %eax,(%esp)
  80106c:	e8 a0 f3 ff ff       	call   800411 <flush_block>
file_flush(struct File *f)
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  801071:	83 c4 10             	add    $0x10,%esp
  801074:	43                   	inc    %ebx
  801075:	8b 96 80 00 00 00    	mov    0x80(%esi),%edx
  80107b:	89 d0                	mov    %edx,%eax
  80107d:	05 ff 0f 00 00       	add    $0xfff,%eax
  801082:	79 06                	jns    80108a <file_flush+0x5f>
  801084:	8d 82 fe 1f 00 00    	lea    0x1ffe(%edx),%eax
  80108a:	c1 f8 0c             	sar    $0xc,%eax
  80108d:	39 d8                	cmp    %ebx,%eax
  80108f:	7f ac                	jg     80103d <file_flush+0x12>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
  801091:	83 ec 0c             	sub    $0xc,%esp
  801094:	56                   	push   %esi
  801095:	e8 77 f3 ff ff       	call   800411 <flush_block>
	if (f->f_indirect)
  80109a:	83 c4 10             	add    $0x10,%esp
  80109d:	83 be b0 00 00 00 00 	cmpl   $0x0,0xb0(%esi)
  8010a4:	74 19                	je     8010bf <file_flush+0x94>
		flush_block(diskaddr(f->f_indirect));
  8010a6:	83 ec 0c             	sub    $0xc,%esp
  8010a9:	ff b6 b0 00 00 00    	pushl  0xb0(%esi)
  8010af:	e8 a4 f1 ff ff       	call   800258 <diskaddr>
  8010b4:	89 04 24             	mov    %eax,(%esp)
  8010b7:	e8 55 f3 ff ff       	call   800411 <flush_block>
  8010bc:	83 c4 10             	add    $0x10,%esp
}
  8010bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010c2:	5b                   	pop    %ebx
  8010c3:	5e                   	pop    %esi
  8010c4:	c9                   	leave  
  8010c5:	c3                   	ret    

008010c6 <file_remove>:

// Remove a file by truncating it and then zeroing the name.
int
file_remove(const char *path)
{
  8010c6:	55                   	push   %ebp
  8010c7:	89 e5                	mov    %esp,%ebp
  8010c9:	83 ec 08             	sub    $0x8,%esp
	int r;
	struct File *f;

	if ((r = walk_path(path, 0, &f, 0)) < 0)
  8010cc:	6a 00                	push   $0x0
  8010ce:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8010d1:	50                   	push   %eax
  8010d2:	6a 00                	push   $0x0
  8010d4:	ff 75 08             	pushl  0x8(%ebp)
  8010d7:	e8 6e fa ff ff       	call   800b4a <walk_path>
  8010dc:	83 c4 10             	add    $0x10,%esp
		return r;
  8010df:	89 c2                	mov    %eax,%edx
file_remove(const char *path)
{
	int r;
	struct File *f;

	if ((r = walk_path(path, 0, &f, 0)) < 0)
  8010e1:	85 c0                	test   %eax,%eax
  8010e3:	78 30                	js     801115 <file_remove+0x4f>
		return r;

	file_truncate_blocks(f, 0);
  8010e5:	83 ec 08             	sub    $0x8,%esp
  8010e8:	6a 00                	push   $0x0
  8010ea:	ff 75 fc             	pushl  -0x4(%ebp)
  8010ed:	e8 55 fe ff ff       	call   800f47 <file_truncate_blocks>
	f->f_name[0] = '\0';
  8010f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8010f5:	c6 00 00             	movb   $0x0,(%eax)
	f->f_size = 0;
  8010f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8010fb:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
  801102:	00 00 00 
	flush_block(f);
  801105:	83 c4 04             	add    $0x4,%esp
  801108:	ff 75 fc             	pushl  -0x4(%ebp)
  80110b:	e8 01 f3 ff ff       	call   800411 <flush_block>

	return 0;
  801110:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801115:	89 d0                	mov    %edx,%eax
  801117:	c9                   	leave  
  801118:	c3                   	ret    

00801119 <fs_sync>:

// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  801119:	55                   	push   %ebp
  80111a:	89 e5                	mov    %esp,%ebp
  80111c:	53                   	push   %ebx
  80111d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  801120:	bb 01 00 00 00       	mov    $0x1,%ebx
  801125:	a1 08 90 80 00       	mov    0x809008,%eax
  80112a:	3b 58 04             	cmp    0x4(%eax),%ebx
  80112d:	73 1f                	jae    80114e <fs_sync+0x35>
		flush_block(diskaddr(i));
  80112f:	83 ec 0c             	sub    $0xc,%esp
  801132:	53                   	push   %ebx
  801133:	e8 20 f1 ff ff       	call   800258 <diskaddr>
  801138:	89 04 24             	mov    %eax,(%esp)
  80113b:	e8 d1 f2 ff ff       	call   800411 <flush_block>
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  801140:	83 c4 10             	add    $0x10,%esp
  801143:	43                   	inc    %ebx
  801144:	a1 08 90 80 00       	mov    0x809008,%eax
  801149:	3b 58 04             	cmp    0x4(%eax),%ebx
  80114c:	72 e1                	jb     80112f <fs_sync+0x16>
		flush_block(diskaddr(i));
}
  80114e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801151:	c9                   	leave  
  801152:	c3                   	ret    
	...

00801154 <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  801154:	55                   	push   %ebp
  801155:	89 e5                	mov    %esp,%ebp
	int i;
	uintptr_t va = FILEVA;
  801157:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  80115c:	ba 00 00 00 00       	mov    $0x0,%edx
		opentab[i].o_fileid = i;
  801161:	89 d0                	mov    %edx,%eax
  801163:	c1 e0 04             	shl    $0x4,%eax
  801166:	89 90 20 40 80 00    	mov    %edx,0x804020(%eax)
		opentab[i].o_fd = (struct Fd*) va;
  80116c:	89 88 2c 40 80 00    	mov    %ecx,0x80402c(%eax)
		va += PGSIZE;
  801172:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  801178:	42                   	inc    %edx
  801179:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  80117f:	7e e0                	jle    801161 <serve_init+0xd>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  801181:	c9                   	leave  
  801182:	c3                   	ret    

00801183 <openfile_alloc>:

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  801183:	55                   	push   %ebp
  801184:	89 e5                	mov    %esp,%ebp
  801186:	56                   	push   %esi
  801187:	53                   	push   %ebx
  801188:	8b 75 08             	mov    0x8(%ebp),%esi
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  80118b:	bb 00 00 00 00       	mov    $0x0,%ebx
		switch (pageref(opentab[i].o_fd)) {
  801190:	83 ec 0c             	sub    $0xc,%esp
  801193:	89 d8                	mov    %ebx,%eax
  801195:	c1 e0 04             	shl    $0x4,%eax
  801198:	ff b0 2c 40 80 00    	pushl  0x80402c(%eax)
  80119e:	e8 f9 18 00 00       	call   802a9c <pageref>
  8011a3:	83 c4 10             	add    $0x10,%esp
  8011a6:	85 c0                	test   %eax,%eax
  8011a8:	74 07                	je     8011b1 <openfile_alloc+0x2e>
  8011aa:	83 f8 01             	cmp    $0x1,%eax
  8011ad:	74 22                	je     8011d1 <openfile_alloc+0x4e>
  8011af:	eb 52                	jmp    801203 <openfile_alloc+0x80>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  8011b1:	83 ec 04             	sub    $0x4,%esp
  8011b4:	6a 07                	push   $0x7
  8011b6:	89 d8                	mov    %ebx,%eax
  8011b8:	c1 e0 04             	shl    $0x4,%eax
  8011bb:	ff b0 2c 40 80 00    	pushl  0x80402c(%eax)
  8011c1:	6a 00                	push   $0x0
  8011c3:	e8 0a 13 00 00       	call   8024d2 <sys_page_alloc>
  8011c8:	83 c4 10             	add    $0x10,%esp
				return r;
  8011cb:	89 c2                	mov    %eax,%edx

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
		switch (pageref(opentab[i].o_fd)) {
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  8011cd:	85 c0                	test   %eax,%eax
  8011cf:	78 40                	js     801211 <openfile_alloc+0x8e>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  8011d1:	89 d8                	mov    %ebx,%eax
  8011d3:	c1 e0 04             	shl    $0x4,%eax
  8011d6:	81 80 20 40 80 00 00 	addl   $0x400,0x804020(%eax)
  8011dd:	04 00 00 
			*o = &opentab[i];
  8011e0:	8d 90 20 40 80 00    	lea    0x804020(%eax),%edx
  8011e6:	89 16                	mov    %edx,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  8011e8:	83 ec 04             	sub    $0x4,%esp
  8011eb:	68 00 10 00 00       	push   $0x1000
  8011f0:	6a 00                	push   $0x0
  8011f2:	ff b0 2c 40 80 00    	pushl  0x80402c(%eax)
  8011f8:	e8 2c 10 00 00       	call   802229 <memset>
			return (*o)->o_fileid;
  8011fd:	8b 06                	mov    (%esi),%eax
  8011ff:	8b 10                	mov    (%eax),%edx
  801201:	eb 0e                	jmp    801211 <openfile_alloc+0x8e>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  801203:	43                   	inc    %ebx
  801204:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
  80120a:	7e 84                	jle    801190 <openfile_alloc+0xd>
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
  80120c:	ba f6 ff ff ff       	mov    $0xfffffff6,%edx
}
  801211:	89 d0                	mov    %edx,%eax
  801213:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801216:	5b                   	pop    %ebx
  801217:	5e                   	pop    %esi
  801218:	c9                   	leave  
  801219:	c3                   	ret    

0080121a <openfile_lookup>:

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  80121a:	55                   	push   %ebp
  80121b:	89 e5                	mov    %esp,%ebp
  80121d:	57                   	push   %edi
  80121e:	56                   	push   %esi
  80121f:	53                   	push   %ebx
  801220:	83 ec 18             	sub    $0x18,%esp
  801223:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  801226:	89 f8                	mov    %edi,%eax
  801228:	25 ff 03 00 00       	and    $0x3ff,%eax
  80122d:	89 c3                	mov    %eax,%ebx
  80122f:	c1 e3 04             	shl    $0x4,%ebx
  801232:	8d b3 20 40 80 00    	lea    0x804020(%ebx),%esi
	if (pageref(o->o_fd) == 1 || o->o_fileid != fileid)
  801238:	ff 76 0c             	pushl  0xc(%esi)
  80123b:	e8 5c 18 00 00       	call   802a9c <pageref>
  801240:	83 c4 10             	add    $0x10,%esp
  801243:	83 f8 01             	cmp    $0x1,%eax
  801246:	74 08                	je     801250 <openfile_lookup+0x36>
  801248:	39 bb 20 40 80 00    	cmp    %edi,0x804020(%ebx)
  80124e:	74 07                	je     801257 <openfile_lookup+0x3d>
		return -E_INVAL;
  801250:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801255:	eb 0a                	jmp    801261 <openfile_lookup+0x47>
	*po = o;
  801257:	8b 45 10             	mov    0x10(%ebp),%eax
  80125a:	89 30                	mov    %esi,(%eax)
	return 0;
  80125c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801261:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801264:	5b                   	pop    %ebx
  801265:	5e                   	pop    %esi
  801266:	5f                   	pop    %edi
  801267:	c9                   	leave  
  801268:	c3                   	ret    

00801269 <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  801269:	55                   	push   %ebp
  80126a:	89 e5                	mov    %esp,%ebp
  80126c:	53                   	push   %ebx
  80126d:	81 ec 18 04 00 00    	sub    $0x418,%esp
  801273:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  801276:	68 00 04 00 00       	push   $0x400
  80127b:	53                   	push   %ebx
  80127c:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801282:	50                   	push   %eax
  801283:	e8 f4 0f 00 00       	call   80227c <memmove>
	path[MAXPATHLEN-1] = 0;
  801288:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  80128c:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801292:	89 04 24             	mov    %eax,(%esp)
  801295:	e8 e9 fe ff ff       	call   801183 <openfile_alloc>
  80129a:	83 c4 10             	add    $0x10,%esp
		if (debug)
			cprintf("openfile_alloc failed: %e", r);
		return r;
  80129d:	89 c2                	mov    %eax,%edx
	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
	path[MAXPATHLEN-1] = 0;

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  80129f:	85 c0                	test   %eax,%eax
  8012a1:	0f 88 ed 00 00 00    	js     801394 <serve_open+0x12b>
		return r;
	}
	fileid = r;

	// Open the file
	if (req->req_omode & O_CREAT) {
  8012a7:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  8012ae:	74 32                	je     8012e2 <serve_open+0x79>
		if ((r = file_create(path, &f)) < 0) {
  8012b0:	83 ec 08             	sub    $0x8,%esp
  8012b3:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  8012b9:	50                   	push   %eax
  8012ba:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8012c0:	50                   	push   %eax
  8012c1:	e8 cc f9 ff ff       	call   800c92 <file_create>
  8012c6:	83 c4 10             	add    $0x10,%esp
  8012c9:	85 c0                	test   %eax,%eax
  8012cb:	79 38                	jns    801305 <serve_open+0x9c>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  8012cd:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  8012d4:	75 05                	jne    8012db <serve_open+0x72>
  8012d6:	83 f8 f3             	cmp    $0xfffffff3,%eax
  8012d9:	74 07                	je     8012e2 <serve_open+0x79>
				goto try_open;
			if (debug)
				cprintf("file_create failed: %e", r);
			return r;
  8012db:	89 c2                	mov    %eax,%edx
  8012dd:	e9 b2 00 00 00       	jmp    801394 <serve_open+0x12b>
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  8012e2:	83 ec 08             	sub    $0x8,%esp
  8012e5:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  8012eb:	50                   	push   %eax
  8012ec:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8012f2:	50                   	push   %eax
  8012f3:	e8 33 fa ff ff       	call   800d2b <file_open>
  8012f8:	83 c4 10             	add    $0x10,%esp
			if (debug)
				cprintf("file_open failed: %e", r);
			return r;
  8012fb:	89 c2                	mov    %eax,%edx
				cprintf("file_create failed: %e", r);
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  8012fd:	85 c0                	test   %eax,%eax
  8012ff:	0f 88 8f 00 00 00    	js     801394 <serve_open+0x12b>
			return r;
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  801305:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  80130c:	74 19                	je     801327 <serve_open+0xbe>
		if ((r = file_set_size(f, 0)) < 0) {
  80130e:	83 ec 08             	sub    $0x8,%esp
  801311:	6a 00                	push   $0x0
  801313:	ff b5 f0 fb ff ff    	pushl  -0x410(%ebp)
  801319:	e8 d2 fc ff ff       	call   800ff0 <file_set_size>
  80131e:	83 c4 10             	add    $0x10,%esp
			if (debug)
				cprintf("file_set_size failed: %e", r);
			return r;
  801321:	89 c2                	mov    %eax,%edx
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
		if ((r = file_set_size(f, 0)) < 0) {
  801323:	85 c0                	test   %eax,%eax
  801325:	78 6d                	js     801394 <serve_open+0x12b>
			return r;
		}
	}

	// Save the file pointer
	o->o_file = f;
  801327:	8b 95 f0 fb ff ff    	mov    -0x410(%ebp),%edx
  80132d:	8b 85 f4 fb ff ff    	mov    -0x40c(%ebp),%eax
  801333:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  801336:	8b 85 f4 fb ff ff    	mov    -0x40c(%ebp),%eax
  80133c:	8b 50 0c             	mov    0xc(%eax),%edx
  80133f:	8b 00                	mov    (%eax),%eax
  801341:	89 42 0c             	mov    %eax,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  801344:	8b 85 f4 fb ff ff    	mov    -0x40c(%ebp),%eax
  80134a:	8b 50 0c             	mov    0xc(%eax),%edx
  80134d:	8b 83 00 04 00 00    	mov    0x400(%ebx),%eax
  801353:	83 e0 03             	and    $0x3,%eax
  801356:	89 42 08             	mov    %eax,0x8(%edx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  801359:	8b 85 f4 fb ff ff    	mov    -0x40c(%ebp),%eax
  80135f:	8b 50 0c             	mov    0xc(%eax),%edx
  801362:	a1 6c 80 80 00       	mov    0x80806c,%eax
  801367:	89 02                	mov    %eax,(%edx)
	o->o_mode = req->req_omode;
  801369:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  80136f:	8b 85 f4 fb ff ff    	mov    -0x40c(%ebp),%eax
  801375:	89 50 08             	mov    %edx,0x8(%eax)

	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller
	*pg_store = o->o_fd;
  801378:	8b 85 f4 fb ff ff    	mov    -0x40c(%ebp),%eax
  80137e:	8b 50 0c             	mov    0xc(%eax),%edx
  801381:	8b 45 10             	mov    0x10(%ebp),%eax
  801384:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W;
  801386:	8b 45 14             	mov    0x14(%ebp),%eax
  801389:	c7 00 07 00 00 00    	movl   $0x7,(%eax)
	return 0;
  80138f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801394:	89 d0                	mov    %edx,%eax
  801396:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801399:	c9                   	leave  
  80139a:	c3                   	ret    

0080139b <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  80139b:	55                   	push   %ebp
  80139c:	89 e5                	mov    %esp,%ebp
  80139e:	53                   	push   %ebx
  80139f:	83 ec 08             	sub    $0x8,%esp
  8013a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8013a5:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8013a8:	50                   	push   %eax
  8013a9:	ff 33                	pushl  (%ebx)
  8013ab:	ff 75 08             	pushl  0x8(%ebp)
  8013ae:	e8 67 fe ff ff       	call   80121a <openfile_lookup>
  8013b3:	83 c4 10             	add    $0x10,%esp
		return r;
  8013b6:	89 c2                	mov    %eax,%edx
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8013b8:	85 c0                	test   %eax,%eax
  8013ba:	78 13                	js     8013cf <serve_set_size+0x34>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  8013bc:	83 ec 08             	sub    $0x8,%esp
  8013bf:	ff 73 04             	pushl  0x4(%ebx)
  8013c2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8013c5:	ff 70 04             	pushl  0x4(%eax)
  8013c8:	e8 23 fc ff ff       	call   800ff0 <file_set_size>
  8013cd:	89 c2                	mov    %eax,%edx
}
  8013cf:	89 d0                	mov    %edx,%eax
  8013d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d4:	c9                   	leave  
  8013d5:	c3                   	ret    

008013d6 <serve_read>:
// Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  
// Returns the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  8013d6:	55                   	push   %ebp
  8013d7:	89 e5                	mov    %esp,%ebp
  8013d9:	57                   	push   %edi
  8013da:	56                   	push   %esi
  8013db:	53                   	push   %ebx
  8013dc:	83 ec 10             	sub    $0x10,%esp
	struct Fsreq_read *req = &ipc->read;
  8013df:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 5: Your code here
	
	struct OpenFile *of;
	int r;

	if ((r = openfile_lookup(envid, req->req_fileid, &of)) < 0) {
  8013e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e5:	50                   	push   %eax
  8013e6:	ff 36                	pushl  (%esi)
  8013e8:	ff 75 08             	pushl  0x8(%ebp)
  8013eb:	e8 2a fe ff ff       	call   80121a <openfile_lookup>
  8013f0:	89 c3                	mov    %eax,%ebx
  8013f2:	83 c4 10             	add    $0x10,%esp
  8013f5:	85 c0                	test   %eax,%eax
  8013f7:	79 11                	jns    80140a <serve_read+0x34>
		cprintf("serve_read: failed to lookup open file\n");
  8013f9:	83 ec 0c             	sub    $0xc,%esp
  8013fc:	68 98 36 80 00       	push   $0x803698
  801401:	e8 d6 07 00 00       	call   801bdc <cprintf>
		return r;
  801406:	89 d8                	mov    %ebx,%eax
  801408:	eb 37                	jmp    801441 <serve_read+0x6b>
	}

	if ((r = file_read(of->o_file, (void *)ret->ret_buf, 
				       MIN(req->req_n, PGSIZE),  of->o_fd->fd_offset)) < 0)
  80140a:	8b 4e 04             	mov    0x4(%esi),%ecx
  80140d:	81 f9 00 10 00 00    	cmp    $0x1000,%ecx
  801413:	76 05                	jbe    80141a <serve_read+0x44>
  801415:	b9 00 10 00 00       	mov    $0x1000,%ecx
  80141a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80141d:	8b 42 0c             	mov    0xc(%edx),%eax
  801420:	ff 70 04             	pushl  0x4(%eax)
  801423:	51                   	push   %ecx
  801424:	56                   	push   %esi
  801425:	ff 72 04             	pushl  0x4(%edx)
  801428:	e8 15 f9 ff ff       	call   800d42 <file_read>
  80142d:	89 c3                	mov    %eax,%ebx
  80142f:	83 c4 10             	add    $0x10,%esp
  801432:	85 db                	test   %ebx,%ebx
  801434:	78 0b                	js     801441 <serve_read+0x6b>
		return r;
	
	of->o_fd->fd_offset += r;
  801436:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801439:	8b 40 0c             	mov    0xc(%eax),%eax
  80143c:	01 58 04             	add    %ebx,0x4(%eax)
	return r;
  80143f:	89 d8                	mov    %ebx,%eax
}
  801441:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801444:	5b                   	pop    %ebx
  801445:	5e                   	pop    %esi
  801446:	5f                   	pop    %edi
  801447:	c9                   	leave  
  801448:	c3                   	ret    

00801449 <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  801449:	55                   	push   %ebp
  80144a:	89 e5                	mov    %esp,%ebp
  80144c:	56                   	push   %esi
  80144d:	53                   	push   %ebx
  80144e:	83 ec 14             	sub    $0x14,%esp
  801451:	8b 75 0c             	mov    0xc(%ebp),%esi
		cprintf("serve_write %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// LAB 5: Your code here.
	struct OpenFile *of;
	int r;
	if ((r = openfile_lookup(envid, req->req_fileid, &of)) < 0) {
  801454:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801457:	50                   	push   %eax
  801458:	ff 36                	pushl  (%esi)
  80145a:	ff 75 08             	pushl  0x8(%ebp)
  80145d:	e8 b8 fd ff ff       	call   80121a <openfile_lookup>
  801462:	89 c3                	mov    %eax,%ebx
  801464:	83 c4 10             	add    $0x10,%esp
  801467:	85 c0                	test   %eax,%eax
  801469:	79 11                	jns    80147c <serve_write+0x33>
		cprintf("serve_write: failed to lookup open file\n");
  80146b:	83 ec 0c             	sub    $0xc,%esp
  80146e:	68 c0 36 80 00       	push   $0x8036c0
  801473:	e8 64 07 00 00       	call   801bdc <cprintf>
		return r;
  801478:	89 d8                	mov    %ebx,%eax
  80147a:	eb 2c                	jmp    8014a8 <serve_write+0x5f>
	}
	if ((r = file_write(of->o_file, (void *)req->req_buf, req->req_n,  
  80147c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80147f:	8b 50 0c             	mov    0xc(%eax),%edx
  801482:	ff 72 04             	pushl  0x4(%edx)
  801485:	ff 76 04             	pushl  0x4(%esi)
  801488:	8d 56 08             	lea    0x8(%esi),%edx
  80148b:	52                   	push   %edx
  80148c:	ff 70 04             	pushl  0x4(%eax)
  80148f:	e8 8c f9 ff ff       	call   800e20 <file_write>
  801494:	89 c3                	mov    %eax,%ebx
  801496:	83 c4 10             	add    $0x10,%esp
  801499:	85 db                	test   %ebx,%ebx
  80149b:	78 0b                	js     8014a8 <serve_write+0x5f>
					    of->o_fd->fd_offset)) < 0)
		return r;
	
	of->o_fd->fd_offset += r;
  80149d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014a0:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a3:	01 58 04             	add    %ebx,0x4(%eax)
	return r;
  8014a6:	89 d8                	mov    %ebx,%eax
}
  8014a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014ab:	5b                   	pop    %ebx
  8014ac:	5e                   	pop    %esi
  8014ad:	c9                   	leave  
  8014ae:	c3                   	ret    

008014af <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  8014af:	55                   	push   %ebp
  8014b0:	89 e5                	mov    %esp,%ebp
  8014b2:	53                   	push   %ebx
  8014b3:	83 ec 08             	sub    $0x8,%esp
	struct Fsreq_stat *req = &ipc->stat;
	struct Fsret_stat *ret = &ipc->statRet;
  8014b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8014b9:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8014bc:	50                   	push   %eax
  8014bd:	ff 33                	pushl  (%ebx)
  8014bf:	ff 75 08             	pushl  0x8(%ebp)
  8014c2:	e8 53 fd ff ff       	call   80121a <openfile_lookup>
  8014c7:	83 c4 10             	add    $0x10,%esp
		return r;
  8014ca:	89 c2                	mov    %eax,%edx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8014cc:	85 c0                	test   %eax,%eax
  8014ce:	78 3f                	js     80150f <serve_stat+0x60>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  8014d0:	83 ec 08             	sub    $0x8,%esp
  8014d3:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8014d6:	ff 70 04             	pushl  0x4(%eax)
  8014d9:	53                   	push   %ebx
  8014da:	e8 01 0c 00 00       	call   8020e0 <strcpy>
	ret->ret_size = o->o_file->f_size;
  8014df:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8014e2:	8b 42 04             	mov    0x4(%edx),%eax
  8014e5:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  8014eb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  8014f1:	8b 42 04             	mov    0x4(%edx),%eax
  8014f4:	83 c4 10             	add    $0x10,%esp
  8014f7:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  8014fe:	0f 94 c0             	sete   %al
  801501:	0f b6 c0             	movzbl %al,%eax
  801504:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80150a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80150f:	89 d0                	mov    %edx,%eax
  801511:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801514:	c9                   	leave  
  801515:	c3                   	ret    

00801516 <serve_flush>:

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  801516:	55                   	push   %ebp
  801517:	89 e5                	mov    %esp,%ebp
  801519:	83 ec 0c             	sub    $0xc,%esp
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80151c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80151f:	50                   	push   %eax
  801520:	8b 45 0c             	mov    0xc(%ebp),%eax
  801523:	ff 30                	pushl  (%eax)
  801525:	ff 75 08             	pushl  0x8(%ebp)
  801528:	e8 ed fc ff ff       	call   80121a <openfile_lookup>
  80152d:	83 c4 10             	add    $0x10,%esp
		return r;
  801530:	89 c2                	mov    %eax,%edx
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801532:	85 c0                	test   %eax,%eax
  801534:	78 13                	js     801549 <serve_flush+0x33>
		return r;
	file_flush(o->o_file);
  801536:	83 ec 0c             	sub    $0xc,%esp
  801539:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80153c:	ff 70 04             	pushl  0x4(%eax)
  80153f:	e8 e7 fa ff ff       	call   80102b <file_flush>
	return 0;
  801544:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801549:	89 d0                	mov    %edx,%eax
  80154b:	c9                   	leave  
  80154c:	c3                   	ret    

0080154d <serve_remove>:

// Remove the file req->req_path.
int
serve_remove(envid_t envid, struct Fsreq_remove *req)
{
  80154d:	55                   	push   %ebp
  80154e:	89 e5                	mov    %esp,%ebp
  801550:	53                   	push   %ebx
  801551:	81 ec 08 04 00 00    	sub    $0x408,%esp

	// Delete the named file.
	// Note: This request doesn't refer to an open file.

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  801557:	68 00 04 00 00       	push   $0x400
  80155c:	ff 75 0c             	pushl  0xc(%ebp)
  80155f:	8d 9d f8 fb ff ff    	lea    -0x408(%ebp),%ebx
  801565:	53                   	push   %ebx
  801566:	e8 11 0d 00 00       	call   80227c <memmove>
	path[MAXPATHLEN-1] = 0;
  80156b:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Delete the specified file
	return file_remove(path);
  80156f:	89 1c 24             	mov    %ebx,(%esp)
  801572:	e8 4f fb ff ff       	call   8010c6 <file_remove>
}
  801577:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157a:	c9                   	leave  
  80157b:	c3                   	ret    

0080157c <serve_sync>:

// Sync the file system.
int
serve_sync(envid_t envid, union Fsipc *req)
{
  80157c:	55                   	push   %ebp
  80157d:	89 e5                	mov    %esp,%ebp
  80157f:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  801582:	e8 92 fb ff ff       	call   801119 <fs_sync>
	return 0;
}
  801587:	b8 00 00 00 00       	mov    $0x0,%eax
  80158c:	c9                   	leave  
  80158d:	c3                   	ret    

0080158e <serve>:
};
#define NHANDLERS (sizeof(handlers)/sizeof(handlers[0]))

void
serve(void)
{
  80158e:	55                   	push   %ebp
  80158f:	89 e5                	mov    %esp,%ebp
  801591:	83 ec 18             	sub    $0x18,%esp
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  801594:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);	
  80159b:	83 ec 04             	sub    $0x4,%esp
  80159e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015a1:	50                   	push   %eax
  8015a2:	ff 35 20 80 80 00    	pushl  0x808020
  8015a8:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8015ab:	50                   	push   %eax
  8015ac:	e8 8f 11 00 00       	call   802740 <ipc_recv>

		if (debug)
  8015b1:	83 c4 10             	add    $0x10,%esp
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, vpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  8015b4:	f6 45 fc 01          	testb  $0x1,-0x4(%ebp)
  8015b8:	75 15                	jne    8015cf <serve+0x41>
			cprintf("Invalid request from %08x: no argument page\n",
  8015ba:	83 ec 08             	sub    $0x8,%esp
  8015bd:	ff 75 f8             	pushl  -0x8(%ebp)
  8015c0:	68 ec 36 80 00       	push   $0x8036ec
  8015c5:	e8 12 06 00 00       	call   801bdc <cprintf>
				whom);
			continue; // just leave it hanging...
  8015ca:	83 c4 10             	add    $0x10,%esp
  8015cd:	eb c5                	jmp    801594 <serve+0x6>
		}

		pg = NULL;
  8015cf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
		if (req == FSREQ_OPEN) {
  8015d6:	83 f8 01             	cmp    $0x1,%eax
  8015d9:	75 1b                	jne    8015f6 <serve+0x68>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  8015db:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015de:	50                   	push   %eax
  8015df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e2:	50                   	push   %eax
  8015e3:	ff 35 20 80 80 00    	pushl  0x808020
  8015e9:	ff 75 f8             	pushl  -0x8(%ebp)
  8015ec:	e8 78 fc ff ff       	call   801269 <serve_open>
  8015f1:	83 c4 10             	add    $0x10,%esp
  8015f4:	eb 3d                	jmp    801633 <serve+0xa5>
		} else if (req < NHANDLERS && handlers[req]) {
  8015f6:	83 f8 08             	cmp    $0x8,%eax
  8015f9:	77 1f                	ja     80161a <serve+0x8c>
  8015fb:	ba 40 80 80 00       	mov    $0x808040,%edx
  801600:	83 3c 82 00          	cmpl   $0x0,(%edx,%eax,4)
  801604:	74 14                	je     80161a <serve+0x8c>
			r = handlers[req](whom, fsreq);
  801606:	83 ec 08             	sub    $0x8,%esp
  801609:	ff 35 20 80 80 00    	pushl  0x808020
  80160f:	ff 75 f8             	pushl  -0x8(%ebp)
  801612:	ff 14 82             	call   *(%edx,%eax,4)
  801615:	83 c4 10             	add    $0x10,%esp
  801618:	eb 19                	jmp    801633 <serve+0xa5>
		} else {
			cprintf("Invalid request code %d from %08x\n", whom, req);
  80161a:	83 ec 04             	sub    $0x4,%esp
  80161d:	50                   	push   %eax
  80161e:	ff 75 f8             	pushl  -0x8(%ebp)
  801621:	68 1c 37 80 00       	push   $0x80371c
  801626:	e8 b1 05 00 00       	call   801bdc <cprintf>
			r = -E_INVAL;
  80162b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801630:	83 c4 10             	add    $0x10,%esp
		}

		ipc_send(whom, r, pg, perm);
  801633:	ff 75 fc             	pushl  -0x4(%ebp)
  801636:	ff 75 f4             	pushl  -0xc(%ebp)
  801639:	50                   	push   %eax
  80163a:	ff 75 f8             	pushl  -0x8(%ebp)
  80163d:	e8 6e 11 00 00       	call   8027b0 <ipc_send>
		sys_page_unmap(0, fsreq);
  801642:	83 c4 08             	add    $0x8,%esp
  801645:	ff 35 20 80 80 00    	pushl  0x808020
  80164b:	6a 00                	push   $0x0
  80164d:	e8 05 0f 00 00       	call   802557 <sys_page_unmap>
  801652:	83 c4 10             	add    $0x10,%esp
  801655:	e9 3a ff ff ff       	jmp    801594 <serve+0x6>

0080165a <umain>:
	}
}

void
umain(int argc, char **argv)
{
  80165a:	55                   	push   %ebp
  80165b:	89 e5                	mov    %esp,%ebp
  80165d:	83 ec 14             	sub    $0x14,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  801660:	c7 05 68 80 80 00 3f 	movl   $0x80373f,0x808068
  801667:	37 80 00 
	cprintf("FS is running\n");
  80166a:	68 42 37 80 00       	push   $0x803742
  80166f:	e8 68 05 00 00       	call   801bdc <cprintf>
			 "cc");
}

static __inline void
outw(int port, uint16_t data)
{
  801674:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  801679:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
	__asm __volatile("outw %0,%w1" : : "a" (data), "d" (port));
  80167e:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  801680:	c7 04 24 51 37 80 00 	movl   $0x803751,(%esp)
  801687:	e8 50 05 00 00       	call   801bdc <cprintf>

	serve_init();
  80168c:	e8 c3 fa ff ff       	call   801154 <serve_init>
	fs_init();
  801691:	e8 cf f1 ff ff       	call   800865 <fs_init>
	fs_test();
  801696:	e8 09 00 00 00       	call   8016a4 <fs_test>
	serve();
  80169b:	e8 ee fe ff ff       	call   80158e <serve>
}
  8016a0:	c9                   	leave  
  8016a1:	c3                   	ret    
	...

008016a4 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  8016a4:	55                   	push   %ebp
  8016a5:	89 e5                	mov    %esp,%ebp
  8016a7:	56                   	push   %esi
  8016a8:	53                   	push   %ebx
  8016a9:	83 ec 14             	sub    $0x14,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  8016ac:	6a 07                	push   $0x7
  8016ae:	68 00 10 00 00       	push   $0x1000
  8016b3:	6a 00                	push   $0x0
  8016b5:	e8 18 0e 00 00       	call   8024d2 <sys_page_alloc>
  8016ba:	83 c4 10             	add    $0x10,%esp
  8016bd:	85 c0                	test   %eax,%eax
  8016bf:	79 12                	jns    8016d3 <fs_test+0x2f>
		panic("sys_page_alloc: %e", r);
  8016c1:	50                   	push   %eax
  8016c2:	68 eb 37 80 00       	push   $0x8037eb
  8016c7:	6a 13                	push   $0x13
  8016c9:	68 fe 37 80 00       	push   $0x8037fe
  8016ce:	e8 2d 04 00 00       	call   801b00 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  8016d3:	83 ec 04             	sub    $0x4,%esp
  8016d6:	68 00 10 00 00       	push   $0x1000
  8016db:	ff 35 04 90 80 00    	pushl  0x809004
  8016e1:	68 00 10 00 00       	push   $0x1000
  8016e6:	e8 91 0b 00 00       	call   80227c <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  8016eb:	e8 45 f0 ff ff       	call   800735 <alloc_block>
  8016f0:	89 c2                	mov    %eax,%edx
  8016f2:	83 c4 10             	add    $0x10,%esp
  8016f5:	85 c0                	test   %eax,%eax
  8016f7:	79 12                	jns    80170b <fs_test+0x67>
		panic("alloc_block: %e", r);
  8016f9:	50                   	push   %eax
  8016fa:	68 08 38 80 00       	push   $0x803808
  8016ff:	6a 18                	push   $0x18
  801701:	68 fe 37 80 00       	push   $0x8037fe
  801706:	e8 f5 03 00 00       	call   801b00 <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  80170b:	85 d2                	test   %edx,%edx
  80170d:	79 03                	jns    801712 <fs_test+0x6e>
  80170f:	8d 42 1f             	lea    0x1f(%edx),%eax
  801712:	89 c3                	mov    %eax,%ebx
  801714:	c1 fb 05             	sar    $0x5,%ebx
  801717:	89 d0                	mov    %edx,%eax
  801719:	85 d2                	test   %edx,%edx
  80171b:	79 03                	jns    801720 <fs_test+0x7c>
  80171d:	8d 42 1f             	lea    0x1f(%edx),%eax
  801720:	83 e0 e0             	and    $0xffffffe0,%eax
  801723:	89 d1                	mov    %edx,%ecx
  801725:	29 c1                	sub    %eax,%ecx
  801727:	b8 01 00 00 00       	mov    $0x1,%eax
  80172c:	d3 e0                	shl    %cl,%eax
  80172e:	85 04 9d 00 10 00 00 	test   %eax,0x1000(,%ebx,4)
  801735:	75 16                	jne    80174d <fs_test+0xa9>
  801737:	68 18 38 80 00       	push   $0x803818
  80173c:	68 7d 33 80 00       	push   $0x80337d
  801741:	6a 1a                	push   $0x1a
  801743:	68 fe 37 80 00       	push   $0x8037fe
  801748:	e8 b3 03 00 00       	call   801b00 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  80174d:	89 d0                	mov    %edx,%eax
  80174f:	85 d2                	test   %edx,%edx
  801751:	79 03                	jns    801756 <fs_test+0xb2>
  801753:	8d 42 1f             	lea    0x1f(%edx),%eax
  801756:	89 c6                	mov    %eax,%esi
  801758:	c1 fe 05             	sar    $0x5,%esi
  80175b:	8b 1d 04 90 80 00    	mov    0x809004,%ebx
  801761:	89 d0                	mov    %edx,%eax
  801763:	85 d2                	test   %edx,%edx
  801765:	79 03                	jns    80176a <fs_test+0xc6>
  801767:	8d 42 1f             	lea    0x1f(%edx),%eax
  80176a:	83 e0 e0             	and    $0xffffffe0,%eax
  80176d:	89 d1                	mov    %edx,%ecx
  80176f:	29 c1                	sub    %eax,%ecx
  801771:	b8 01 00 00 00       	mov    $0x1,%eax
  801776:	d3 e0                	shl    %cl,%eax
  801778:	85 04 b3             	test   %eax,(%ebx,%esi,4)
  80177b:	74 16                	je     801793 <fs_test+0xef>
  80177d:	68 88 37 80 00       	push   $0x803788
  801782:	68 7d 33 80 00       	push   $0x80337d
  801787:	6a 1c                	push   $0x1c
  801789:	68 fe 37 80 00       	push   $0x8037fe
  80178e:	e8 6d 03 00 00       	call   801b00 <_panic>
	cprintf("alloc_block is good\n");
  801793:	83 ec 0c             	sub    $0xc,%esp
  801796:	68 33 38 80 00       	push   $0x803833
  80179b:	e8 3c 04 00 00       	call   801bdc <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  8017a0:	83 c4 08             	add    $0x8,%esp
  8017a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a6:	50                   	push   %eax
  8017a7:	68 48 38 80 00       	push   $0x803848
  8017ac:	e8 7a f5 ff ff       	call   800d2b <file_open>
  8017b1:	89 c2                	mov    %eax,%edx
  8017b3:	83 c4 10             	add    $0x10,%esp
  8017b6:	85 c0                	test   %eax,%eax
  8017b8:	79 17                	jns    8017d1 <fs_test+0x12d>
  8017ba:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8017bd:	74 12                	je     8017d1 <fs_test+0x12d>
		panic("file_open /not-found: %e", r);
  8017bf:	50                   	push   %eax
  8017c0:	68 53 38 80 00       	push   $0x803853
  8017c5:	6a 20                	push   $0x20
  8017c7:	68 fe 37 80 00       	push   $0x8037fe
  8017cc:	e8 2f 03 00 00       	call   801b00 <_panic>
	else if (r == 0)
  8017d1:	85 d2                	test   %edx,%edx
  8017d3:	75 14                	jne    8017e9 <fs_test+0x145>
		panic("file_open /not-found succeeded!");
  8017d5:	83 ec 04             	sub    $0x4,%esp
  8017d8:	68 a8 37 80 00       	push   $0x8037a8
  8017dd:	6a 22                	push   $0x22
  8017df:	68 fe 37 80 00       	push   $0x8037fe
  8017e4:	e8 17 03 00 00       	call   801b00 <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  8017e9:	83 ec 08             	sub    $0x8,%esp
  8017ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ef:	50                   	push   %eax
  8017f0:	68 6c 38 80 00       	push   $0x80386c
  8017f5:	e8 31 f5 ff ff       	call   800d2b <file_open>
  8017fa:	83 c4 10             	add    $0x10,%esp
  8017fd:	85 c0                	test   %eax,%eax
  8017ff:	79 12                	jns    801813 <fs_test+0x16f>
		panic("file_open /newmotd: %e", r);
  801801:	50                   	push   %eax
  801802:	68 75 38 80 00       	push   $0x803875
  801807:	6a 24                	push   $0x24
  801809:	68 fe 37 80 00       	push   $0x8037fe
  80180e:	e8 ed 02 00 00       	call   801b00 <_panic>
	cprintf("file_open is good\n");
  801813:	83 ec 0c             	sub    $0xc,%esp
  801816:	68 8c 38 80 00       	push   $0x80388c
  80181b:	e8 bc 03 00 00       	call   801bdc <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  801820:	83 c4 0c             	add    $0xc,%esp
  801823:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801826:	50                   	push   %eax
  801827:	6a 00                	push   $0x0
  801829:	ff 75 f4             	pushl  -0xc(%ebp)
  80182c:	e8 28 f1 ff ff       	call   800959 <file_get_block>
  801831:	83 c4 10             	add    $0x10,%esp
  801834:	85 c0                	test   %eax,%eax
  801836:	79 12                	jns    80184a <fs_test+0x1a6>
		panic("file_get_block: %e", r);
  801838:	50                   	push   %eax
  801839:	68 9f 38 80 00       	push   $0x80389f
  80183e:	6a 28                	push   $0x28
  801840:	68 fe 37 80 00       	push   $0x8037fe
  801845:	e8 b6 02 00 00       	call   801b00 <_panic>
	if (strcmp(blk, msg) != 0)
  80184a:	83 ec 08             	sub    $0x8,%esp
  80184d:	ff 35 64 80 80 00    	pushl  0x808064
  801853:	ff 75 f0             	pushl  -0x10(%ebp)
  801856:	e8 26 09 00 00       	call   802181 <strcmp>
  80185b:	83 c4 10             	add    $0x10,%esp
  80185e:	85 c0                	test   %eax,%eax
  801860:	74 14                	je     801876 <fs_test+0x1d2>
		panic("file_get_block returned wrong data");
  801862:	83 ec 04             	sub    $0x4,%esp
  801865:	68 c8 37 80 00       	push   $0x8037c8
  80186a:	6a 2a                	push   $0x2a
  80186c:	68 fe 37 80 00       	push   $0x8037fe
  801871:	e8 8a 02 00 00       	call   801b00 <_panic>
	cprintf("file_get_block is good\n");
  801876:	83 ec 0c             	sub    $0xc,%esp
  801879:	68 b2 38 80 00       	push   $0x8038b2
  80187e:	e8 59 03 00 00       	call   801bdc <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  801883:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801886:	8a 02                	mov    (%edx),%al
  801888:	88 02                	mov    %al,(%edx)
	assert((vpt[PGNUM(blk)] & PTE_D));
  80188a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80188d:	c1 e8 0c             	shr    $0xc,%eax
  801890:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801897:	83 c4 10             	add    $0x10,%esp
  80189a:	a8 40                	test   $0x40,%al
  80189c:	75 16                	jne    8018b4 <fs_test+0x210>
  80189e:	68 cb 38 80 00       	push   $0x8038cb
  8018a3:	68 7d 33 80 00       	push   $0x80337d
  8018a8:	6a 2e                	push   $0x2e
  8018aa:	68 fe 37 80 00       	push   $0x8037fe
  8018af:	e8 4c 02 00 00       	call   801b00 <_panic>
	file_flush(f);
  8018b4:	83 ec 0c             	sub    $0xc,%esp
  8018b7:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ba:	e8 6c f7 ff ff       	call   80102b <file_flush>
	assert(!(vpt[PGNUM(blk)] & PTE_D));
  8018bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c2:	c1 e8 0c             	shr    $0xc,%eax
  8018c5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018cc:	83 c4 10             	add    $0x10,%esp
  8018cf:	a8 40                	test   $0x40,%al
  8018d1:	74 16                	je     8018e9 <fs_test+0x245>
  8018d3:	68 ca 38 80 00       	push   $0x8038ca
  8018d8:	68 7d 33 80 00       	push   $0x80337d
  8018dd:	6a 30                	push   $0x30
  8018df:	68 fe 37 80 00       	push   $0x8037fe
  8018e4:	e8 17 02 00 00       	call   801b00 <_panic>
	cprintf("file_flush is good\n");
  8018e9:	83 ec 0c             	sub    $0xc,%esp
  8018ec:	68 e5 38 80 00       	push   $0x8038e5
  8018f1:	e8 e6 02 00 00       	call   801bdc <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  8018f6:	83 c4 08             	add    $0x8,%esp
  8018f9:	6a 00                	push   $0x0
  8018fb:	ff 75 f4             	pushl  -0xc(%ebp)
  8018fe:	e8 ed f6 ff ff       	call   800ff0 <file_set_size>
  801903:	83 c4 10             	add    $0x10,%esp
  801906:	85 c0                	test   %eax,%eax
  801908:	79 12                	jns    80191c <fs_test+0x278>
		panic("file_set_size: %e", r);
  80190a:	50                   	push   %eax
  80190b:	68 f9 38 80 00       	push   $0x8038f9
  801910:	6a 34                	push   $0x34
  801912:	68 fe 37 80 00       	push   $0x8037fe
  801917:	e8 e4 01 00 00       	call   801b00 <_panic>
	assert(f->f_direct[0] == 0);
  80191c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80191f:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  801926:	74 16                	je     80193e <fs_test+0x29a>
  801928:	68 0b 39 80 00       	push   $0x80390b
  80192d:	68 7d 33 80 00       	push   $0x80337d
  801932:	6a 35                	push   $0x35
  801934:	68 fe 37 80 00       	push   $0x8037fe
  801939:	e8 c2 01 00 00       	call   801b00 <_panic>
	assert(!(vpt[PGNUM(f)] & PTE_D));
  80193e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801941:	c1 e8 0c             	shr    $0xc,%eax
  801944:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80194b:	a8 40                	test   $0x40,%al
  80194d:	74 16                	je     801965 <fs_test+0x2c1>
  80194f:	68 1f 39 80 00       	push   $0x80391f
  801954:	68 7d 33 80 00       	push   $0x80337d
  801959:	6a 36                	push   $0x36
  80195b:	68 fe 37 80 00       	push   $0x8037fe
  801960:	e8 9b 01 00 00       	call   801b00 <_panic>
	cprintf("file_truncate is good\n");
  801965:	83 ec 0c             	sub    $0xc,%esp
  801968:	68 38 39 80 00       	push   $0x803938
  80196d:	e8 6a 02 00 00       	call   801bdc <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  801972:	83 c4 04             	add    $0x4,%esp
  801975:	ff 35 64 80 80 00    	pushl  0x808064
  80197b:	e8 24 07 00 00       	call   8020a4 <strlen>
  801980:	83 c4 08             	add    $0x8,%esp
  801983:	50                   	push   %eax
  801984:	ff 75 f4             	pushl  -0xc(%ebp)
  801987:	e8 64 f6 ff ff       	call   800ff0 <file_set_size>
  80198c:	83 c4 10             	add    $0x10,%esp
  80198f:	85 c0                	test   %eax,%eax
  801991:	79 12                	jns    8019a5 <fs_test+0x301>
		panic("file_set_size 2: %e", r);
  801993:	50                   	push   %eax
  801994:	68 4f 39 80 00       	push   $0x80394f
  801999:	6a 3a                	push   $0x3a
  80199b:	68 fe 37 80 00       	push   $0x8037fe
  8019a0:	e8 5b 01 00 00       	call   801b00 <_panic>
	assert(!(vpt[PGNUM(f)] & PTE_D));
  8019a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a8:	c1 e8 0c             	shr    $0xc,%eax
  8019ab:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019b2:	a8 40                	test   $0x40,%al
  8019b4:	74 16                	je     8019cc <fs_test+0x328>
  8019b6:	68 1f 39 80 00       	push   $0x80391f
  8019bb:	68 7d 33 80 00       	push   $0x80337d
  8019c0:	6a 3b                	push   $0x3b
  8019c2:	68 fe 37 80 00       	push   $0x8037fe
  8019c7:	e8 34 01 00 00       	call   801b00 <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  8019cc:	83 ec 04             	sub    $0x4,%esp
  8019cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019d2:	50                   	push   %eax
  8019d3:	6a 00                	push   $0x0
  8019d5:	ff 75 f4             	pushl  -0xc(%ebp)
  8019d8:	e8 7c ef ff ff       	call   800959 <file_get_block>
  8019dd:	83 c4 10             	add    $0x10,%esp
  8019e0:	85 c0                	test   %eax,%eax
  8019e2:	79 12                	jns    8019f6 <fs_test+0x352>
		panic("file_get_block 2: %e", r);
  8019e4:	50                   	push   %eax
  8019e5:	68 63 39 80 00       	push   $0x803963
  8019ea:	6a 3d                	push   $0x3d
  8019ec:	68 fe 37 80 00       	push   $0x8037fe
  8019f1:	e8 0a 01 00 00       	call   801b00 <_panic>
	strcpy(blk, msg);
  8019f6:	83 ec 08             	sub    $0x8,%esp
  8019f9:	ff 35 64 80 80 00    	pushl  0x808064
  8019ff:	ff 75 f0             	pushl  -0x10(%ebp)
  801a02:	e8 d9 06 00 00       	call   8020e0 <strcpy>
	assert((vpt[PGNUM(blk)] & PTE_D));
  801a07:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a0a:	c1 e8 0c             	shr    $0xc,%eax
  801a0d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a14:	83 c4 10             	add    $0x10,%esp
  801a17:	a8 40                	test   $0x40,%al
  801a19:	75 16                	jne    801a31 <fs_test+0x38d>
  801a1b:	68 cb 38 80 00       	push   $0x8038cb
  801a20:	68 7d 33 80 00       	push   $0x80337d
  801a25:	6a 3f                	push   $0x3f
  801a27:	68 fe 37 80 00       	push   $0x8037fe
  801a2c:	e8 cf 00 00 00       	call   801b00 <_panic>
	file_flush(f);
  801a31:	83 ec 0c             	sub    $0xc,%esp
  801a34:	ff 75 f4             	pushl  -0xc(%ebp)
  801a37:	e8 ef f5 ff ff       	call   80102b <file_flush>
	assert(!(vpt[PGNUM(blk)] & PTE_D));
  801a3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a3f:	c1 e8 0c             	shr    $0xc,%eax
  801a42:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a49:	83 c4 10             	add    $0x10,%esp
  801a4c:	a8 40                	test   $0x40,%al
  801a4e:	74 16                	je     801a66 <fs_test+0x3c2>
  801a50:	68 ca 38 80 00       	push   $0x8038ca
  801a55:	68 7d 33 80 00       	push   $0x80337d
  801a5a:	6a 41                	push   $0x41
  801a5c:	68 fe 37 80 00       	push   $0x8037fe
  801a61:	e8 9a 00 00 00       	call   801b00 <_panic>
	assert(!(vpt[PGNUM(f)] & PTE_D));
  801a66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a69:	c1 e8 0c             	shr    $0xc,%eax
  801a6c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a73:	a8 40                	test   $0x40,%al
  801a75:	74 16                	je     801a8d <fs_test+0x3e9>
  801a77:	68 1f 39 80 00       	push   $0x80391f
  801a7c:	68 7d 33 80 00       	push   $0x80337d
  801a81:	6a 42                	push   $0x42
  801a83:	68 fe 37 80 00       	push   $0x8037fe
  801a88:	e8 73 00 00 00       	call   801b00 <_panic>
	cprintf("file rewrite is good\n");
  801a8d:	83 ec 0c             	sub    $0xc,%esp
  801a90:	68 78 39 80 00       	push   $0x803978
  801a95:	e8 42 01 00 00       	call   801bdc <cprintf>
}
  801a9a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a9d:	5b                   	pop    %ebx
  801a9e:	5e                   	pop    %esi
  801a9f:	c9                   	leave  
  801aa0:	c3                   	ret    
  801aa1:	00 00                	add    %al,(%eax)
	...

00801aa4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801aa4:	55                   	push   %ebp
  801aa5:	89 e5                	mov    %esp,%ebp
  801aa7:	56                   	push   %esi
  801aa8:	53                   	push   %ebx
  801aa9:	8b 75 08             	mov    0x8(%ebp),%esi
  801aac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];	
  801aaf:	e8 e0 09 00 00       	call   802494 <sys_getenvid>
  801ab4:	25 ff 03 00 00       	and    $0x3ff,%eax
  801ab9:	89 c2                	mov    %eax,%edx
  801abb:	c1 e2 05             	shl    $0x5,%edx
  801abe:	29 c2                	sub    %eax,%edx
  801ac0:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  801ac7:	89 15 0c 90 80 00    	mov    %edx,0x80900c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  801acd:	85 f6                	test   %esi,%esi
  801acf:	7e 07                	jle    801ad8 <libmain+0x34>
		binaryname = argv[0];
  801ad1:	8b 03                	mov    (%ebx),%eax
  801ad3:	a3 68 80 80 00       	mov    %eax,0x808068

	// call user main routine
	umain(argc, argv);
  801ad8:	83 ec 08             	sub    $0x8,%esp
  801adb:	53                   	push   %ebx
  801adc:	56                   	push   %esi
  801add:	e8 78 fb ff ff       	call   80165a <umain>

	// exit gracefully
	exit();
  801ae2:	e8 09 00 00 00       	call   801af0 <exit>
}
  801ae7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aea:	5b                   	pop    %ebx
  801aeb:	5e                   	pop    %esi
  801aec:	c9                   	leave  
  801aed:	c3                   	ret    
	...

00801af0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801af0:	55                   	push   %ebp
  801af1:	89 e5                	mov    %esp,%ebp
  801af3:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  801af6:	6a 00                	push   $0x0
  801af8:	e8 56 09 00 00       	call   802453 <sys_env_destroy>
}
  801afd:	c9                   	leave  
  801afe:	c3                   	ret    
	...

00801b00 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b00:	55                   	push   %ebp
  801b01:	89 e5                	mov    %esp,%ebp
  801b03:	53                   	push   %ebx
  801b04:	83 ec 10             	sub    $0x10,%esp
	va_list ap;

	va_start(ap, fmt);
  801b07:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b0a:	ff 75 0c             	pushl  0xc(%ebp)
  801b0d:	ff 75 08             	pushl  0x8(%ebp)
  801b10:	ff 35 68 80 80 00    	pushl  0x808068
  801b16:	83 ec 08             	sub    $0x8,%esp
  801b19:	e8 76 09 00 00       	call   802494 <sys_getenvid>
  801b1e:	83 c4 08             	add    $0x8,%esp
  801b21:	50                   	push   %eax
  801b22:	68 98 39 80 00       	push   $0x803998
  801b27:	e8 b0 00 00 00       	call   801bdc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b2c:	83 c4 18             	add    $0x18,%esp
  801b2f:	53                   	push   %ebx
  801b30:	ff 75 10             	pushl  0x10(%ebp)
  801b33:	e8 53 00 00 00       	call   801b8b <vcprintf>
	cprintf("\n");
  801b38:	c7 04 24 5d 35 80 00 	movl   $0x80355d,(%esp)
  801b3f:	e8 98 00 00 00       	call   801bdc <cprintf>

	// Cause a breakpoint exception
	while (1)
  801b44:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  801b47:	cc                   	int3   
  801b48:	eb fd                	jmp    801b47 <_panic+0x47>
	...

00801b4c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	53                   	push   %ebx
  801b50:	83 ec 04             	sub    $0x4,%esp
  801b53:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801b56:	8b 03                	mov    (%ebx),%eax
  801b58:	8b 55 08             	mov    0x8(%ebp),%edx
  801b5b:	88 54 18 08          	mov    %dl,0x8(%eax,%ebx,1)
  801b5f:	40                   	inc    %eax
  801b60:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801b62:	3d ff 00 00 00       	cmp    $0xff,%eax
  801b67:	75 1a                	jne    801b83 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  801b69:	83 ec 08             	sub    $0x8,%esp
  801b6c:	68 ff 00 00 00       	push   $0xff
  801b71:	8d 43 08             	lea    0x8(%ebx),%eax
  801b74:	50                   	push   %eax
  801b75:	e8 96 08 00 00       	call   802410 <sys_cputs>
		b->idx = 0;
  801b7a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b80:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801b83:	ff 43 04             	incl   0x4(%ebx)
}
  801b86:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b89:	c9                   	leave  
  801b8a:	c3                   	ret    

00801b8b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801b8b:	55                   	push   %ebp
  801b8c:	89 e5                	mov    %esp,%ebp
  801b8e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801b94:	c7 85 e8 fe ff ff 00 	movl   $0x0,-0x118(%ebp)
  801b9b:	00 00 00 
	b.cnt = 0;
  801b9e:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801ba5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801ba8:	ff 75 0c             	pushl  0xc(%ebp)
  801bab:	ff 75 08             	pushl  0x8(%ebp)
  801bae:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801bb4:	50                   	push   %eax
  801bb5:	68 4c 1b 80 00       	push   $0x801b4c
  801bba:	e8 49 01 00 00       	call   801d08 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801bbf:	83 c4 08             	add    $0x8,%esp
  801bc2:	ff b5 e8 fe ff ff    	pushl  -0x118(%ebp)
  801bc8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801bce:	50                   	push   %eax
  801bcf:	e8 3c 08 00 00       	call   802410 <sys_cputs>

	return b.cnt;
  801bd4:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
}
  801bda:	c9                   	leave  
  801bdb:	c3                   	ret    

00801bdc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801bdc:	55                   	push   %ebp
  801bdd:	89 e5                	mov    %esp,%ebp
  801bdf:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801be2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801be5:	50                   	push   %eax
  801be6:	ff 75 08             	pushl  0x8(%ebp)
  801be9:	e8 9d ff ff ff       	call   801b8b <vcprintf>
	va_end(ap);

	return cnt;
}
  801bee:	c9                   	leave  
  801bef:	c3                   	ret    

00801bf0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801bf0:	55                   	push   %ebp
  801bf1:	89 e5                	mov    %esp,%ebp
  801bf3:	57                   	push   %edi
  801bf4:	56                   	push   %esi
  801bf5:	53                   	push   %ebx
  801bf6:	83 ec 0c             	sub    $0xc,%esp
  801bf9:	8b 75 10             	mov    0x10(%ebp),%esi
  801bfc:	8b 7d 14             	mov    0x14(%ebp),%edi
  801bff:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801c02:	8b 45 18             	mov    0x18(%ebp),%eax
  801c05:	ba 00 00 00 00       	mov    $0x0,%edx
  801c0a:	39 fa                	cmp    %edi,%edx
  801c0c:	77 39                	ja     801c47 <printnum+0x57>
  801c0e:	72 04                	jb     801c14 <printnum+0x24>
  801c10:	39 f0                	cmp    %esi,%eax
  801c12:	77 33                	ja     801c47 <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801c14:	83 ec 04             	sub    $0x4,%esp
  801c17:	ff 75 20             	pushl  0x20(%ebp)
  801c1a:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801c1d:	50                   	push   %eax
  801c1e:	ff 75 18             	pushl  0x18(%ebp)
  801c21:	8b 45 18             	mov    0x18(%ebp),%eax
  801c24:	ba 00 00 00 00       	mov    $0x0,%edx
  801c29:	52                   	push   %edx
  801c2a:	50                   	push   %eax
  801c2b:	57                   	push   %edi
  801c2c:	56                   	push   %esi
  801c2d:	e8 52 14 00 00       	call   803084 <__udivdi3>
  801c32:	83 c4 10             	add    $0x10,%esp
  801c35:	52                   	push   %edx
  801c36:	50                   	push   %eax
  801c37:	ff 75 0c             	pushl  0xc(%ebp)
  801c3a:	ff 75 08             	pushl  0x8(%ebp)
  801c3d:	e8 ae ff ff ff       	call   801bf0 <printnum>
  801c42:	83 c4 20             	add    $0x20,%esp
  801c45:	eb 19                	jmp    801c60 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801c47:	4b                   	dec    %ebx
  801c48:	85 db                	test   %ebx,%ebx
  801c4a:	7e 14                	jle    801c60 <printnum+0x70>
  801c4c:	83 ec 08             	sub    $0x8,%esp
  801c4f:	ff 75 0c             	pushl  0xc(%ebp)
  801c52:	ff 75 20             	pushl  0x20(%ebp)
  801c55:	ff 55 08             	call   *0x8(%ebp)
  801c58:	83 c4 10             	add    $0x10,%esp
  801c5b:	4b                   	dec    %ebx
  801c5c:	85 db                	test   %ebx,%ebx
  801c5e:	7f ec                	jg     801c4c <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801c60:	83 ec 08             	sub    $0x8,%esp
  801c63:	ff 75 0c             	pushl  0xc(%ebp)
  801c66:	8b 45 18             	mov    0x18(%ebp),%eax
  801c69:	ba 00 00 00 00       	mov    $0x0,%edx
  801c6e:	83 ec 04             	sub    $0x4,%esp
  801c71:	52                   	push   %edx
  801c72:	50                   	push   %eax
  801c73:	57                   	push   %edi
  801c74:	56                   	push   %esi
  801c75:	e8 16 15 00 00       	call   803190 <__umoddi3>
  801c7a:	83 c4 14             	add    $0x14,%esp
  801c7d:	0f be 80 cd 3a 80 00 	movsbl 0x803acd(%eax),%eax
  801c84:	50                   	push   %eax
  801c85:	ff 55 08             	call   *0x8(%ebp)
}
  801c88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c8b:	5b                   	pop    %ebx
  801c8c:	5e                   	pop    %esi
  801c8d:	5f                   	pop    %edi
  801c8e:	c9                   	leave  
  801c8f:	c3                   	ret    

00801c90 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801c90:	55                   	push   %ebp
  801c91:	89 e5                	mov    %esp,%ebp
  801c93:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c96:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  801c99:	83 f8 01             	cmp    $0x1,%eax
  801c9c:	7e 0e                	jle    801cac <getuint+0x1c>
		return va_arg(*ap, unsigned long long);
  801c9e:	8b 11                	mov    (%ecx),%edx
  801ca0:	8d 42 08             	lea    0x8(%edx),%eax
  801ca3:	89 01                	mov    %eax,(%ecx)
  801ca5:	8b 02                	mov    (%edx),%eax
  801ca7:	8b 52 04             	mov    0x4(%edx),%edx
  801caa:	eb 22                	jmp    801cce <getuint+0x3e>
	else if (lflag)
  801cac:	85 c0                	test   %eax,%eax
  801cae:	74 10                	je     801cc0 <getuint+0x30>
		return va_arg(*ap, unsigned long);
  801cb0:	8b 11                	mov    (%ecx),%edx
  801cb2:	8d 42 04             	lea    0x4(%edx),%eax
  801cb5:	89 01                	mov    %eax,(%ecx)
  801cb7:	8b 02                	mov    (%edx),%eax
  801cb9:	ba 00 00 00 00       	mov    $0x0,%edx
  801cbe:	eb 0e                	jmp    801cce <getuint+0x3e>
	else
		return va_arg(*ap, unsigned int);
  801cc0:	8b 11                	mov    (%ecx),%edx
  801cc2:	8d 42 04             	lea    0x4(%edx),%eax
  801cc5:	89 01                	mov    %eax,(%ecx)
  801cc7:	8b 02                	mov    (%edx),%eax
  801cc9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801cce:	c9                   	leave  
  801ccf:	c3                   	ret    

00801cd0 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  801cd0:	55                   	push   %ebp
  801cd1:	89 e5                	mov    %esp,%ebp
  801cd3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cd6:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  801cd9:	83 f8 01             	cmp    $0x1,%eax
  801cdc:	7e 0e                	jle    801cec <getint+0x1c>
		return va_arg(*ap, long long);
  801cde:	8b 11                	mov    (%ecx),%edx
  801ce0:	8d 42 08             	lea    0x8(%edx),%eax
  801ce3:	89 01                	mov    %eax,(%ecx)
  801ce5:	8b 02                	mov    (%edx),%eax
  801ce7:	8b 52 04             	mov    0x4(%edx),%edx
  801cea:	eb 1a                	jmp    801d06 <getint+0x36>
	else if (lflag)
  801cec:	85 c0                	test   %eax,%eax
  801cee:	74 0c                	je     801cfc <getint+0x2c>
		return va_arg(*ap, long);
  801cf0:	8b 01                	mov    (%ecx),%eax
  801cf2:	8d 50 04             	lea    0x4(%eax),%edx
  801cf5:	89 11                	mov    %edx,(%ecx)
  801cf7:	8b 00                	mov    (%eax),%eax
  801cf9:	99                   	cltd   
  801cfa:	eb 0a                	jmp    801d06 <getint+0x36>
	else
		return va_arg(*ap, int);
  801cfc:	8b 01                	mov    (%ecx),%eax
  801cfe:	8d 50 04             	lea    0x4(%eax),%edx
  801d01:	89 11                	mov    %edx,(%ecx)
  801d03:	8b 00                	mov    (%eax),%eax
  801d05:	99                   	cltd   
}
  801d06:	c9                   	leave  
  801d07:	c3                   	ret    

00801d08 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801d08:	55                   	push   %ebp
  801d09:	89 e5                	mov    %esp,%ebp
  801d0b:	57                   	push   %edi
  801d0c:	56                   	push   %esi
  801d0d:	53                   	push   %ebx
  801d0e:	83 ec 1c             	sub    $0x1c,%esp
  801d11:	8b 5d 10             	mov    0x10(%ebp),%ebx

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
			putch(ch, putdat);
  801d14:	0f b6 0b             	movzbl (%ebx),%ecx
  801d17:	43                   	inc    %ebx
  801d18:	83 f9 25             	cmp    $0x25,%ecx
  801d1b:	74 1e                	je     801d3b <vprintfmt+0x33>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801d1d:	85 c9                	test   %ecx,%ecx
  801d1f:	0f 84 dc 02 00 00    	je     802001 <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  801d25:	83 ec 08             	sub    $0x8,%esp
  801d28:	ff 75 0c             	pushl  0xc(%ebp)
  801d2b:	51                   	push   %ecx
  801d2c:	ff 55 08             	call   *0x8(%ebp)
  801d2f:	83 c4 10             	add    $0x10,%esp
  801d32:	0f b6 0b             	movzbl (%ebx),%ecx
  801d35:	43                   	inc    %ebx
  801d36:	83 f9 25             	cmp    $0x25,%ecx
  801d39:	75 e2                	jne    801d1d <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  801d3b:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
		width = -1;
  801d3f:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
		precision = -1;
  801d46:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  801d4b:	bf 00 00 00 00       	mov    $0x0,%edi
		altflag = 0;
  801d50:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d57:	0f b6 0b             	movzbl (%ebx),%ecx
  801d5a:	8d 41 dd             	lea    -0x23(%ecx),%eax
  801d5d:	43                   	inc    %ebx
  801d5e:	83 f8 55             	cmp    $0x55,%eax
  801d61:	0f 87 75 02 00 00    	ja     801fdc <vprintfmt+0x2d4>
  801d67:	ff 24 85 60 3b 80 00 	jmp    *0x803b60(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  801d6e:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
			goto reswitch;
  801d72:	eb e3                	jmp    801d57 <vprintfmt+0x4f>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801d74:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
			goto reswitch;
  801d78:	eb dd                	jmp    801d57 <vprintfmt+0x4f>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801d7a:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  801d7f:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  801d82:	8d 74 41 d0          	lea    -0x30(%ecx,%eax,2),%esi
				ch = *fmt;
  801d86:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  801d89:	8d 41 d0             	lea    -0x30(%ecx),%eax
  801d8c:	83 f8 09             	cmp    $0x9,%eax
  801d8f:	77 28                	ja     801db9 <vprintfmt+0xb1>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801d91:	43                   	inc    %ebx
  801d92:	eb eb                	jmp    801d7f <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801d94:	8b 55 14             	mov    0x14(%ebp),%edx
  801d97:	8d 42 04             	lea    0x4(%edx),%eax
  801d9a:	89 45 14             	mov    %eax,0x14(%ebp)
  801d9d:	8b 32                	mov    (%edx),%esi
			goto process_precision;
  801d9f:	eb 18                	jmp    801db9 <vprintfmt+0xb1>

		case '.':
			if (width < 0)
  801da1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801da5:	79 b0                	jns    801d57 <vprintfmt+0x4f>
				width = 0;
  801da7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
			goto reswitch;
  801dae:	eb a7                	jmp    801d57 <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  801db0:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
			goto reswitch;
  801db7:	eb 9e                	jmp    801d57 <vprintfmt+0x4f>

		process_precision:
			if (width < 0)
  801db9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801dbd:	79 98                	jns    801d57 <vprintfmt+0x4f>
				width = precision, precision = -1;
  801dbf:	89 75 f0             	mov    %esi,-0x10(%ebp)
  801dc2:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  801dc7:	eb 8e                	jmp    801d57 <vprintfmt+0x4f>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801dc9:	47                   	inc    %edi
			goto reswitch;
  801dca:	eb 8b                	jmp    801d57 <vprintfmt+0x4f>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801dcc:	83 ec 08             	sub    $0x8,%esp
  801dcf:	ff 75 0c             	pushl  0xc(%ebp)
  801dd2:	8b 55 14             	mov    0x14(%ebp),%edx
  801dd5:	8d 42 04             	lea    0x4(%edx),%eax
  801dd8:	89 45 14             	mov    %eax,0x14(%ebp)
  801ddb:	ff 32                	pushl  (%edx)
  801ddd:	ff 55 08             	call   *0x8(%ebp)
			break;
  801de0:	83 c4 10             	add    $0x10,%esp
  801de3:	e9 2c ff ff ff       	jmp    801d14 <vprintfmt+0xc>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801de8:	8b 55 14             	mov    0x14(%ebp),%edx
  801deb:	8d 42 04             	lea    0x4(%edx),%eax
  801dee:	89 45 14             	mov    %eax,0x14(%ebp)
  801df1:	8b 02                	mov    (%edx),%eax
			if (err < 0)
  801df3:	85 c0                	test   %eax,%eax
  801df5:	79 02                	jns    801df9 <vprintfmt+0xf1>
				err = -err;
  801df7:	f7 d8                	neg    %eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801df9:	83 f8 0f             	cmp    $0xf,%eax
  801dfc:	7f 0b                	jg     801e09 <vprintfmt+0x101>
  801dfe:	8b 3c 85 20 3b 80 00 	mov    0x803b20(,%eax,4),%edi
  801e05:	85 ff                	test   %edi,%edi
  801e07:	75 19                	jne    801e22 <vprintfmt+0x11a>
				printfmt(putch, putdat, "error %d", err);
  801e09:	50                   	push   %eax
  801e0a:	68 de 3a 80 00       	push   $0x803ade
  801e0f:	ff 75 0c             	pushl  0xc(%ebp)
  801e12:	ff 75 08             	pushl  0x8(%ebp)
  801e15:	e8 ef 01 00 00       	call   802009 <printfmt>
  801e1a:	83 c4 10             	add    $0x10,%esp
  801e1d:	e9 f2 fe ff ff       	jmp    801d14 <vprintfmt+0xc>
			else
				printfmt(putch, putdat, "%s", p);
  801e22:	57                   	push   %edi
  801e23:	68 8f 33 80 00       	push   $0x80338f
  801e28:	ff 75 0c             	pushl  0xc(%ebp)
  801e2b:	ff 75 08             	pushl  0x8(%ebp)
  801e2e:	e8 d6 01 00 00       	call   802009 <printfmt>
  801e33:	83 c4 10             	add    $0x10,%esp
			break;
  801e36:	e9 d9 fe ff ff       	jmp    801d14 <vprintfmt+0xc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801e3b:	8b 55 14             	mov    0x14(%ebp),%edx
  801e3e:	8d 42 04             	lea    0x4(%edx),%eax
  801e41:	89 45 14             	mov    %eax,0x14(%ebp)
  801e44:	8b 3a                	mov    (%edx),%edi
  801e46:	85 ff                	test   %edi,%edi
  801e48:	75 05                	jne    801e4f <vprintfmt+0x147>
				p = "(null)";
  801e4a:	bf e7 3a 80 00       	mov    $0x803ae7,%edi
			if (width > 0 && padc != '-')
  801e4f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801e53:	7e 3b                	jle    801e90 <vprintfmt+0x188>
  801e55:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  801e59:	74 35                	je     801e90 <vprintfmt+0x188>
				for (width -= strnlen(p, precision); width > 0; width--)
  801e5b:	83 ec 08             	sub    $0x8,%esp
  801e5e:	56                   	push   %esi
  801e5f:	57                   	push   %edi
  801e60:	e8 58 02 00 00       	call   8020bd <strnlen>
  801e65:	29 45 f0             	sub    %eax,-0x10(%ebp)
  801e68:	83 c4 10             	add    $0x10,%esp
  801e6b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801e6f:	7e 1f                	jle    801e90 <vprintfmt+0x188>
  801e71:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  801e75:	89 45 e4             	mov    %eax,-0x1c(%ebp)
					putch(padc, putdat);
  801e78:	83 ec 08             	sub    $0x8,%esp
  801e7b:	ff 75 0c             	pushl  0xc(%ebp)
  801e7e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e81:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801e84:	83 c4 10             	add    $0x10,%esp
  801e87:	ff 4d f0             	decl   -0x10(%ebp)
  801e8a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801e8e:	7f e8                	jg     801e78 <vprintfmt+0x170>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801e90:	0f be 0f             	movsbl (%edi),%ecx
  801e93:	47                   	inc    %edi
  801e94:	85 c9                	test   %ecx,%ecx
  801e96:	74 44                	je     801edc <vprintfmt+0x1d4>
  801e98:	85 f6                	test   %esi,%esi
  801e9a:	78 03                	js     801e9f <vprintfmt+0x197>
  801e9c:	4e                   	dec    %esi
  801e9d:	78 3d                	js     801edc <vprintfmt+0x1d4>
				if (altflag && (ch < ' ' || ch > '~'))
  801e9f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801ea3:	74 18                	je     801ebd <vprintfmt+0x1b5>
  801ea5:	8d 41 e0             	lea    -0x20(%ecx),%eax
  801ea8:	83 f8 5e             	cmp    $0x5e,%eax
  801eab:	76 10                	jbe    801ebd <vprintfmt+0x1b5>
					putch('?', putdat);
  801ead:	83 ec 08             	sub    $0x8,%esp
  801eb0:	ff 75 0c             	pushl  0xc(%ebp)
  801eb3:	6a 3f                	push   $0x3f
  801eb5:	ff 55 08             	call   *0x8(%ebp)
  801eb8:	83 c4 10             	add    $0x10,%esp
  801ebb:	eb 0d                	jmp    801eca <vprintfmt+0x1c2>
				else
					putch(ch, putdat);
  801ebd:	83 ec 08             	sub    $0x8,%esp
  801ec0:	ff 75 0c             	pushl  0xc(%ebp)
  801ec3:	51                   	push   %ecx
  801ec4:	ff 55 08             	call   *0x8(%ebp)
  801ec7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801eca:	ff 4d f0             	decl   -0x10(%ebp)
  801ecd:	0f be 0f             	movsbl (%edi),%ecx
  801ed0:	47                   	inc    %edi
  801ed1:	85 c9                	test   %ecx,%ecx
  801ed3:	74 07                	je     801edc <vprintfmt+0x1d4>
  801ed5:	85 f6                	test   %esi,%esi
  801ed7:	78 c6                	js     801e9f <vprintfmt+0x197>
  801ed9:	4e                   	dec    %esi
  801eda:	79 c3                	jns    801e9f <vprintfmt+0x197>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801edc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801ee0:	0f 8e 2e fe ff ff    	jle    801d14 <vprintfmt+0xc>
				putch(' ', putdat);
  801ee6:	83 ec 08             	sub    $0x8,%esp
  801ee9:	ff 75 0c             	pushl  0xc(%ebp)
  801eec:	6a 20                	push   $0x20
  801eee:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801ef1:	83 c4 10             	add    $0x10,%esp
  801ef4:	ff 4d f0             	decl   -0x10(%ebp)
  801ef7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801efb:	7f e9                	jg     801ee6 <vprintfmt+0x1de>
				putch(' ', putdat);
			break;
  801efd:	e9 12 fe ff ff       	jmp    801d14 <vprintfmt+0xc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801f02:	57                   	push   %edi
  801f03:	8d 45 14             	lea    0x14(%ebp),%eax
  801f06:	50                   	push   %eax
  801f07:	e8 c4 fd ff ff       	call   801cd0 <getint>
  801f0c:	89 c6                	mov    %eax,%esi
  801f0e:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  801f10:	83 c4 08             	add    $0x8,%esp
  801f13:	85 d2                	test   %edx,%edx
  801f15:	79 15                	jns    801f2c <vprintfmt+0x224>
				putch('-', putdat);
  801f17:	83 ec 08             	sub    $0x8,%esp
  801f1a:	ff 75 0c             	pushl  0xc(%ebp)
  801f1d:	6a 2d                	push   $0x2d
  801f1f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801f22:	f7 de                	neg    %esi
  801f24:	83 d7 00             	adc    $0x0,%edi
  801f27:	f7 df                	neg    %edi
  801f29:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801f2c:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  801f31:	eb 76                	jmp    801fa9 <vprintfmt+0x2a1>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801f33:	57                   	push   %edi
  801f34:	8d 45 14             	lea    0x14(%ebp),%eax
  801f37:	50                   	push   %eax
  801f38:	e8 53 fd ff ff       	call   801c90 <getuint>
  801f3d:	89 c6                	mov    %eax,%esi
  801f3f:	89 d7                	mov    %edx,%edi
			base = 10;
  801f41:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  801f46:	83 c4 08             	add    $0x8,%esp
  801f49:	eb 5e                	jmp    801fa9 <vprintfmt+0x2a1>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801f4b:	57                   	push   %edi
  801f4c:	8d 45 14             	lea    0x14(%ebp),%eax
  801f4f:	50                   	push   %eax
  801f50:	e8 3b fd ff ff       	call   801c90 <getuint>
  801f55:	89 c6                	mov    %eax,%esi
  801f57:	89 d7                	mov    %edx,%edi
			base = 8;
  801f59:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  801f5e:	83 c4 08             	add    $0x8,%esp
  801f61:	eb 46                	jmp    801fa9 <vprintfmt+0x2a1>

		// pointer
		case 'p':
			putch('0', putdat);
  801f63:	83 ec 08             	sub    $0x8,%esp
  801f66:	ff 75 0c             	pushl  0xc(%ebp)
  801f69:	6a 30                	push   $0x30
  801f6b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801f6e:	83 c4 08             	add    $0x8,%esp
  801f71:	ff 75 0c             	pushl  0xc(%ebp)
  801f74:	6a 78                	push   $0x78
  801f76:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  801f79:	8b 55 14             	mov    0x14(%ebp),%edx
  801f7c:	8d 42 04             	lea    0x4(%edx),%eax
  801f7f:	89 45 14             	mov    %eax,0x14(%ebp)
  801f82:	8b 32                	mov    (%edx),%esi
  801f84:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801f89:	ba 10 00 00 00       	mov    $0x10,%edx
			goto number;
  801f8e:	83 c4 10             	add    $0x10,%esp
  801f91:	eb 16                	jmp    801fa9 <vprintfmt+0x2a1>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801f93:	57                   	push   %edi
  801f94:	8d 45 14             	lea    0x14(%ebp),%eax
  801f97:	50                   	push   %eax
  801f98:	e8 f3 fc ff ff       	call   801c90 <getuint>
  801f9d:	89 c6                	mov    %eax,%esi
  801f9f:	89 d7                	mov    %edx,%edi
			base = 16;
  801fa1:	ba 10 00 00 00       	mov    $0x10,%edx
  801fa6:	83 c4 08             	add    $0x8,%esp
		number:
			printnum(putch, putdat, num, base, width, padc);
  801fa9:	83 ec 04             	sub    $0x4,%esp
  801fac:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  801fb0:	50                   	push   %eax
  801fb1:	ff 75 f0             	pushl  -0x10(%ebp)
  801fb4:	52                   	push   %edx
  801fb5:	57                   	push   %edi
  801fb6:	56                   	push   %esi
  801fb7:	ff 75 0c             	pushl  0xc(%ebp)
  801fba:	ff 75 08             	pushl  0x8(%ebp)
  801fbd:	e8 2e fc ff ff       	call   801bf0 <printnum>
			break;
  801fc2:	83 c4 20             	add    $0x20,%esp
  801fc5:	e9 4a fd ff ff       	jmp    801d14 <vprintfmt+0xc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801fca:	83 ec 08             	sub    $0x8,%esp
  801fcd:	ff 75 0c             	pushl  0xc(%ebp)
  801fd0:	51                   	push   %ecx
  801fd1:	ff 55 08             	call   *0x8(%ebp)
			break;
  801fd4:	83 c4 10             	add    $0x10,%esp
  801fd7:	e9 38 fd ff ff       	jmp    801d14 <vprintfmt+0xc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801fdc:	83 ec 08             	sub    $0x8,%esp
  801fdf:	ff 75 0c             	pushl  0xc(%ebp)
  801fe2:	6a 25                	push   $0x25
  801fe4:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801fe7:	4b                   	dec    %ebx
  801fe8:	83 c4 10             	add    $0x10,%esp
  801feb:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  801fef:	0f 84 1f fd ff ff    	je     801d14 <vprintfmt+0xc>
  801ff5:	4b                   	dec    %ebx
  801ff6:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  801ffa:	75 f9                	jne    801ff5 <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  801ffc:	e9 13 fd ff ff       	jmp    801d14 <vprintfmt+0xc>
		}
	}
}
  802001:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802004:	5b                   	pop    %ebx
  802005:	5e                   	pop    %esi
  802006:	5f                   	pop    %edi
  802007:	c9                   	leave  
  802008:	c3                   	ret    

00802009 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  802009:	55                   	push   %ebp
  80200a:	89 e5                	mov    %esp,%ebp
  80200c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80200f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  802012:	50                   	push   %eax
  802013:	ff 75 10             	pushl  0x10(%ebp)
  802016:	ff 75 0c             	pushl  0xc(%ebp)
  802019:	ff 75 08             	pushl  0x8(%ebp)
  80201c:	e8 e7 fc ff ff       	call   801d08 <vprintfmt>
	va_end(ap);
}
  802021:	c9                   	leave  
  802022:	c3                   	ret    

00802023 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  802023:	55                   	push   %ebp
  802024:	89 e5                	mov    %esp,%ebp
  802026:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  802029:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  80202c:	8b 0a                	mov    (%edx),%ecx
  80202e:	3b 4a 04             	cmp    0x4(%edx),%ecx
  802031:	73 07                	jae    80203a <sprintputch+0x17>
		*b->buf++ = ch;
  802033:	8b 45 08             	mov    0x8(%ebp),%eax
  802036:	88 01                	mov    %al,(%ecx)
  802038:	ff 02                	incl   (%edx)
}
  80203a:	c9                   	leave  
  80203b:	c3                   	ret    

0080203c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80203c:	55                   	push   %ebp
  80203d:	89 e5                	mov    %esp,%ebp
  80203f:	83 ec 18             	sub    $0x18,%esp
  802042:	8b 55 08             	mov    0x8(%ebp),%edx
  802045:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = {buf, buf+n-1, 0};
  802048:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80204b:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
  80204f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802052:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

	if (buf == NULL || n < 1)
  802059:	85 d2                	test   %edx,%edx
  80205b:	74 04                	je     802061 <vsnprintf+0x25>
  80205d:	85 c9                	test   %ecx,%ecx
  80205f:	7f 07                	jg     802068 <vsnprintf+0x2c>
		return -E_INVAL;
  802061:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802066:	eb 1d                	jmp    802085 <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  802068:	ff 75 14             	pushl  0x14(%ebp)
  80206b:	ff 75 10             	pushl  0x10(%ebp)
  80206e:	8d 45 e8             	lea    -0x18(%ebp),%eax
  802071:	50                   	push   %eax
  802072:	68 23 20 80 00       	push   $0x802023
  802077:	e8 8c fc ff ff       	call   801d08 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80207c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80207f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  802082:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  802085:	c9                   	leave  
  802086:	c3                   	ret    

00802087 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  802087:	55                   	push   %ebp
  802088:	89 e5                	mov    %esp,%ebp
  80208a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80208d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  802090:	50                   	push   %eax
  802091:	ff 75 10             	pushl  0x10(%ebp)
  802094:	ff 75 0c             	pushl  0xc(%ebp)
  802097:	ff 75 08             	pushl  0x8(%ebp)
  80209a:	e8 9d ff ff ff       	call   80203c <vsnprintf>
	va_end(ap);

	return rc;
}
  80209f:	c9                   	leave  
  8020a0:	c3                   	ret    
  8020a1:	00 00                	add    %al,(%eax)
	...

008020a4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8020a4:	55                   	push   %ebp
  8020a5:	89 e5                	mov    %esp,%ebp
  8020a7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8020aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8020af:	80 3a 00             	cmpb   $0x0,(%edx)
  8020b2:	74 07                	je     8020bb <strlen+0x17>
		n++;
  8020b4:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8020b5:	42                   	inc    %edx
  8020b6:	80 3a 00             	cmpb   $0x0,(%edx)
  8020b9:	75 f9                	jne    8020b4 <strlen+0x10>
		n++;
	return n;
}
  8020bb:	c9                   	leave  
  8020bc:	c3                   	ret    

008020bd <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8020bd:	55                   	push   %ebp
  8020be:	89 e5                	mov    %esp,%ebp
  8020c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020c3:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8020c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8020cb:	85 d2                	test   %edx,%edx
  8020cd:	74 0f                	je     8020de <strnlen+0x21>
  8020cf:	80 39 00             	cmpb   $0x0,(%ecx)
  8020d2:	74 0a                	je     8020de <strnlen+0x21>
		n++;
  8020d4:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8020d5:	41                   	inc    %ecx
  8020d6:	4a                   	dec    %edx
  8020d7:	74 05                	je     8020de <strnlen+0x21>
  8020d9:	80 39 00             	cmpb   $0x0,(%ecx)
  8020dc:	75 f6                	jne    8020d4 <strnlen+0x17>
		n++;
	return n;
}
  8020de:	c9                   	leave  
  8020df:	c3                   	ret    

008020e0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8020e0:	55                   	push   %ebp
  8020e1:	89 e5                	mov    %esp,%ebp
  8020e3:	53                   	push   %ebx
  8020e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020e7:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  8020ea:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  8020ec:	8a 02                	mov    (%edx),%al
  8020ee:	42                   	inc    %edx
  8020ef:	88 01                	mov    %al,(%ecx)
  8020f1:	41                   	inc    %ecx
  8020f2:	84 c0                	test   %al,%al
  8020f4:	75 f6                	jne    8020ec <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8020f6:	89 d8                	mov    %ebx,%eax
  8020f8:	5b                   	pop    %ebx
  8020f9:	c9                   	leave  
  8020fa:	c3                   	ret    

008020fb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8020fb:	55                   	push   %ebp
  8020fc:	89 e5                	mov    %esp,%ebp
  8020fe:	53                   	push   %ebx
  8020ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  802102:	53                   	push   %ebx
  802103:	e8 9c ff ff ff       	call   8020a4 <strlen>
	strcpy(dst + len, src);
  802108:	ff 75 0c             	pushl  0xc(%ebp)
  80210b:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80210e:	50                   	push   %eax
  80210f:	e8 cc ff ff ff       	call   8020e0 <strcpy>
	return dst;
}
  802114:	89 d8                	mov    %ebx,%eax
  802116:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802119:	c9                   	leave  
  80211a:	c3                   	ret    

0080211b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80211b:	55                   	push   %ebp
  80211c:	89 e5                	mov    %esp,%ebp
  80211e:	57                   	push   %edi
  80211f:	56                   	push   %esi
  802120:	53                   	push   %ebx
  802121:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802124:	8b 55 0c             	mov    0xc(%ebp),%edx
  802127:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  80212a:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  80212c:	bb 00 00 00 00       	mov    $0x0,%ebx
  802131:	39 f3                	cmp    %esi,%ebx
  802133:	73 10                	jae    802145 <strncpy+0x2a>
		*dst++ = *src;
  802135:	8a 02                	mov    (%edx),%al
  802137:	88 01                	mov    %al,(%ecx)
  802139:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80213a:	80 3a 01             	cmpb   $0x1,(%edx)
  80213d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802140:	43                   	inc    %ebx
  802141:	39 f3                	cmp    %esi,%ebx
  802143:	72 f0                	jb     802135 <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  802145:	89 f8                	mov    %edi,%eax
  802147:	5b                   	pop    %ebx
  802148:	5e                   	pop    %esi
  802149:	5f                   	pop    %edi
  80214a:	c9                   	leave  
  80214b:	c3                   	ret    

0080214c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80214c:	55                   	push   %ebp
  80214d:	89 e5                	mov    %esp,%ebp
  80214f:	56                   	push   %esi
  802150:	53                   	push   %ebx
  802151:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802154:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802157:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  80215a:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  80215c:	85 d2                	test   %edx,%edx
  80215e:	74 19                	je     802179 <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  802160:	4a                   	dec    %edx
  802161:	74 13                	je     802176 <strlcpy+0x2a>
  802163:	80 39 00             	cmpb   $0x0,(%ecx)
  802166:	74 0e                	je     802176 <strlcpy+0x2a>
  802168:	8a 01                	mov    (%ecx),%al
  80216a:	41                   	inc    %ecx
  80216b:	88 03                	mov    %al,(%ebx)
  80216d:	43                   	inc    %ebx
  80216e:	4a                   	dec    %edx
  80216f:	74 05                	je     802176 <strlcpy+0x2a>
  802171:	80 39 00             	cmpb   $0x0,(%ecx)
  802174:	75 f2                	jne    802168 <strlcpy+0x1c>
		*dst = '\0';
  802176:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  802179:	89 d8                	mov    %ebx,%eax
  80217b:	29 f0                	sub    %esi,%eax
}
  80217d:	5b                   	pop    %ebx
  80217e:	5e                   	pop    %esi
  80217f:	c9                   	leave  
  802180:	c3                   	ret    

00802181 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  802181:	55                   	push   %ebp
  802182:	89 e5                	mov    %esp,%ebp
  802184:	8b 55 08             	mov    0x8(%ebp),%edx
  802187:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
		p++, q++;
  80218a:	80 3a 00             	cmpb   $0x0,(%edx)
  80218d:	74 13                	je     8021a2 <strcmp+0x21>
  80218f:	8a 02                	mov    (%edx),%al
  802191:	3a 01                	cmp    (%ecx),%al
  802193:	75 0d                	jne    8021a2 <strcmp+0x21>
  802195:	42                   	inc    %edx
  802196:	41                   	inc    %ecx
  802197:	80 3a 00             	cmpb   $0x0,(%edx)
  80219a:	74 06                	je     8021a2 <strcmp+0x21>
  80219c:	8a 02                	mov    (%edx),%al
  80219e:	3a 01                	cmp    (%ecx),%al
  8021a0:	74 f3                	je     802195 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8021a2:	0f b6 02             	movzbl (%edx),%eax
  8021a5:	0f b6 11             	movzbl (%ecx),%edx
  8021a8:	29 d0                	sub    %edx,%eax
}
  8021aa:	c9                   	leave  
  8021ab:	c3                   	ret    

008021ac <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8021ac:	55                   	push   %ebp
  8021ad:	89 e5                	mov    %esp,%ebp
  8021af:	53                   	push   %ebx
  8021b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8021b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8021b6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  8021b9:	85 c9                	test   %ecx,%ecx
  8021bb:	74 1f                	je     8021dc <strncmp+0x30>
  8021bd:	80 3a 00             	cmpb   $0x0,(%edx)
  8021c0:	74 16                	je     8021d8 <strncmp+0x2c>
  8021c2:	8a 02                	mov    (%edx),%al
  8021c4:	3a 03                	cmp    (%ebx),%al
  8021c6:	75 10                	jne    8021d8 <strncmp+0x2c>
  8021c8:	42                   	inc    %edx
  8021c9:	43                   	inc    %ebx
  8021ca:	49                   	dec    %ecx
  8021cb:	74 0f                	je     8021dc <strncmp+0x30>
  8021cd:	80 3a 00             	cmpb   $0x0,(%edx)
  8021d0:	74 06                	je     8021d8 <strncmp+0x2c>
  8021d2:	8a 02                	mov    (%edx),%al
  8021d4:	3a 03                	cmp    (%ebx),%al
  8021d6:	74 f0                	je     8021c8 <strncmp+0x1c>
	if (n == 0)
  8021d8:	85 c9                	test   %ecx,%ecx
  8021da:	75 07                	jne    8021e3 <strncmp+0x37>
		return 0;
  8021dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8021e1:	eb 0a                	jmp    8021ed <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8021e3:	0f b6 12             	movzbl (%edx),%edx
  8021e6:	0f b6 03             	movzbl (%ebx),%eax
  8021e9:	29 c2                	sub    %eax,%edx
  8021eb:	89 d0                	mov    %edx,%eax
}
  8021ed:	5b                   	pop    %ebx
  8021ee:	c9                   	leave  
  8021ef:	c3                   	ret    

008021f0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8021f0:	55                   	push   %ebp
  8021f1:	89 e5                	mov    %esp,%ebp
  8021f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8021f6:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  8021f9:	80 38 00             	cmpb   $0x0,(%eax)
  8021fc:	74 0a                	je     802208 <strchr+0x18>
		if (*s == c)
  8021fe:	38 10                	cmp    %dl,(%eax)
  802200:	74 0b                	je     80220d <strchr+0x1d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  802202:	40                   	inc    %eax
  802203:	80 38 00             	cmpb   $0x0,(%eax)
  802206:	75 f6                	jne    8021fe <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  802208:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80220d:	c9                   	leave  
  80220e:	c3                   	ret    

0080220f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80220f:	55                   	push   %ebp
  802210:	89 e5                	mov    %esp,%ebp
  802212:	8b 45 08             	mov    0x8(%ebp),%eax
  802215:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  802218:	80 38 00             	cmpb   $0x0,(%eax)
  80221b:	74 0a                	je     802227 <strfind+0x18>
		if (*s == c)
  80221d:	38 10                	cmp    %dl,(%eax)
  80221f:	74 06                	je     802227 <strfind+0x18>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  802221:	40                   	inc    %eax
  802222:	80 38 00             	cmpb   $0x0,(%eax)
  802225:	75 f6                	jne    80221d <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
}
  802227:	c9                   	leave  
  802228:	c3                   	ret    

00802229 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  802229:	55                   	push   %ebp
  80222a:	89 e5                	mov    %esp,%ebp
  80222c:	57                   	push   %edi
  80222d:	8b 7d 08             	mov    0x8(%ebp),%edi
  802230:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
		return v;
  802233:	89 f8                	mov    %edi,%eax
void *
memset(void *v, int c, size_t n)
{
	char *p;

	if (n == 0)
  802235:	85 c9                	test   %ecx,%ecx
  802237:	74 40                	je     802279 <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  802239:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80223f:	75 30                	jne    802271 <memset+0x48>
  802241:	f6 c1 03             	test   $0x3,%cl
  802244:	75 2b                	jne    802271 <memset+0x48>
		c &= 0xFF;
  802246:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80224d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802250:	c1 e0 18             	shl    $0x18,%eax
  802253:	8b 55 0c             	mov    0xc(%ebp),%edx
  802256:	c1 e2 10             	shl    $0x10,%edx
  802259:	09 d0                	or     %edx,%eax
  80225b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80225e:	c1 e2 08             	shl    $0x8,%edx
  802261:	09 d0                	or     %edx,%eax
  802263:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  802266:	c1 e9 02             	shr    $0x2,%ecx
  802269:	8b 45 0c             	mov    0xc(%ebp),%eax
  80226c:	fc                   	cld    
  80226d:	f3 ab                	rep stos %eax,%es:(%edi)
  80226f:	eb 06                	jmp    802277 <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  802271:	8b 45 0c             	mov    0xc(%ebp),%eax
  802274:	fc                   	cld    
  802275:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  802277:	89 f8                	mov    %edi,%eax
}
  802279:	5f                   	pop    %edi
  80227a:	c9                   	leave  
  80227b:	c3                   	ret    

0080227c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80227c:	55                   	push   %ebp
  80227d:	89 e5                	mov    %esp,%ebp
  80227f:	57                   	push   %edi
  802280:	56                   	push   %esi
  802281:	8b 45 08             	mov    0x8(%ebp),%eax
  802284:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  802287:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  80228a:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  80228c:	39 c6                	cmp    %eax,%esi
  80228e:	73 34                	jae    8022c4 <memmove+0x48>
  802290:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  802293:	39 c2                	cmp    %eax,%edx
  802295:	76 2d                	jbe    8022c4 <memmove+0x48>
		s += n;
  802297:	89 d6                	mov    %edx,%esi
		d += n;
  802299:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80229c:	f6 c2 03             	test   $0x3,%dl
  80229f:	75 1b                	jne    8022bc <memmove+0x40>
  8022a1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8022a7:	75 13                	jne    8022bc <memmove+0x40>
  8022a9:	f6 c1 03             	test   $0x3,%cl
  8022ac:	75 0e                	jne    8022bc <memmove+0x40>
			asm volatile("std; rep movsl\n"
  8022ae:	83 ef 04             	sub    $0x4,%edi
  8022b1:	83 ee 04             	sub    $0x4,%esi
  8022b4:	c1 e9 02             	shr    $0x2,%ecx
  8022b7:	fd                   	std    
  8022b8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8022ba:	eb 05                	jmp    8022c1 <memmove+0x45>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8022bc:	4f                   	dec    %edi
  8022bd:	4e                   	dec    %esi
  8022be:	fd                   	std    
  8022bf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8022c1:	fc                   	cld    
  8022c2:	eb 20                	jmp    8022e4 <memmove+0x68>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8022c4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8022ca:	75 15                	jne    8022e1 <memmove+0x65>
  8022cc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8022d2:	75 0d                	jne    8022e1 <memmove+0x65>
  8022d4:	f6 c1 03             	test   $0x3,%cl
  8022d7:	75 08                	jne    8022e1 <memmove+0x65>
			asm volatile("cld; rep movsl\n"
  8022d9:	c1 e9 02             	shr    $0x2,%ecx
  8022dc:	fc                   	cld    
  8022dd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8022df:	eb 03                	jmp    8022e4 <memmove+0x68>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8022e1:	fc                   	cld    
  8022e2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8022e4:	5e                   	pop    %esi
  8022e5:	5f                   	pop    %edi
  8022e6:	c9                   	leave  
  8022e7:	c3                   	ret    

008022e8 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  8022e8:	55                   	push   %ebp
  8022e9:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8022eb:	ff 75 10             	pushl  0x10(%ebp)
  8022ee:	ff 75 0c             	pushl  0xc(%ebp)
  8022f1:	ff 75 08             	pushl  0x8(%ebp)
  8022f4:	e8 83 ff ff ff       	call   80227c <memmove>
}
  8022f9:	c9                   	leave  
  8022fa:	c3                   	ret    

008022fb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8022fb:	55                   	push   %ebp
  8022fc:	89 e5                	mov    %esp,%ebp
  8022fe:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
  8022ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  802302:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  802305:	8b 55 10             	mov    0x10(%ebp),%edx
  802308:	4a                   	dec    %edx
  802309:	83 fa ff             	cmp    $0xffffffff,%edx
  80230c:	74 1a                	je     802328 <memcmp+0x2d>
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  80230e:	8a 01                	mov    (%ecx),%al
  802310:	3a 03                	cmp    (%ebx),%al
  802312:	74 0c                	je     802320 <memcmp+0x25>
			return (int) *s1 - (int) *s2;
  802314:	0f b6 d0             	movzbl %al,%edx
  802317:	0f b6 03             	movzbl (%ebx),%eax
  80231a:	29 c2                	sub    %eax,%edx
  80231c:	89 d0                	mov    %edx,%eax
  80231e:	eb 0d                	jmp    80232d <memcmp+0x32>
		s1++, s2++;
  802320:	41                   	inc    %ecx
  802321:	43                   	inc    %ebx
  802322:	4a                   	dec    %edx
  802323:	83 fa ff             	cmp    $0xffffffff,%edx
  802326:	75 e6                	jne    80230e <memcmp+0x13>
	}

	return 0;
  802328:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80232d:	5b                   	pop    %ebx
  80232e:	c9                   	leave  
  80232f:	c3                   	ret    

00802330 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  802330:	55                   	push   %ebp
  802331:	89 e5                	mov    %esp,%ebp
  802333:	8b 45 08             	mov    0x8(%ebp),%eax
  802336:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  802339:	89 c2                	mov    %eax,%edx
  80233b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80233e:	39 d0                	cmp    %edx,%eax
  802340:	73 09                	jae    80234b <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  802342:	38 08                	cmp    %cl,(%eax)
  802344:	74 05                	je     80234b <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  802346:	40                   	inc    %eax
  802347:	39 d0                	cmp    %edx,%eax
  802349:	72 f7                	jb     802342 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80234b:	c9                   	leave  
  80234c:	c3                   	ret    

0080234d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80234d:	55                   	push   %ebp
  80234e:	89 e5                	mov    %esp,%ebp
  802350:	57                   	push   %edi
  802351:	56                   	push   %esi
  802352:	53                   	push   %ebx
  802353:	8b 55 08             	mov    0x8(%ebp),%edx
  802356:	8b 75 0c             	mov    0xc(%ebp),%esi
  802359:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  80235c:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  802361:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  802366:	80 3a 20             	cmpb   $0x20,(%edx)
  802369:	74 05                	je     802370 <strtol+0x23>
  80236b:	80 3a 09             	cmpb   $0x9,(%edx)
  80236e:	75 0b                	jne    80237b <strtol+0x2e>
  802370:	42                   	inc    %edx
  802371:	80 3a 20             	cmpb   $0x20,(%edx)
  802374:	74 fa                	je     802370 <strtol+0x23>
  802376:	80 3a 09             	cmpb   $0x9,(%edx)
  802379:	74 f5                	je     802370 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  80237b:	80 3a 2b             	cmpb   $0x2b,(%edx)
  80237e:	75 03                	jne    802383 <strtol+0x36>
		s++;
  802380:	42                   	inc    %edx
  802381:	eb 0b                	jmp    80238e <strtol+0x41>
	else if (*s == '-')
  802383:	80 3a 2d             	cmpb   $0x2d,(%edx)
  802386:	75 06                	jne    80238e <strtol+0x41>
		s++, neg = 1;
  802388:	42                   	inc    %edx
  802389:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80238e:	85 c9                	test   %ecx,%ecx
  802390:	74 05                	je     802397 <strtol+0x4a>
  802392:	83 f9 10             	cmp    $0x10,%ecx
  802395:	75 15                	jne    8023ac <strtol+0x5f>
  802397:	80 3a 30             	cmpb   $0x30,(%edx)
  80239a:	75 10                	jne    8023ac <strtol+0x5f>
  80239c:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8023a0:	75 0a                	jne    8023ac <strtol+0x5f>
		s += 2, base = 16;
  8023a2:	83 c2 02             	add    $0x2,%edx
  8023a5:	b9 10 00 00 00       	mov    $0x10,%ecx
  8023aa:	eb 14                	jmp    8023c0 <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  8023ac:	85 c9                	test   %ecx,%ecx
  8023ae:	75 10                	jne    8023c0 <strtol+0x73>
  8023b0:	80 3a 30             	cmpb   $0x30,(%edx)
  8023b3:	75 05                	jne    8023ba <strtol+0x6d>
		s++, base = 8;
  8023b5:	42                   	inc    %edx
  8023b6:	b1 08                	mov    $0x8,%cl
  8023b8:	eb 06                	jmp    8023c0 <strtol+0x73>
	else if (base == 0)
  8023ba:	85 c9                	test   %ecx,%ecx
  8023bc:	75 02                	jne    8023c0 <strtol+0x73>
		base = 10;
  8023be:	b1 0a                	mov    $0xa,%cl

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8023c0:	8a 02                	mov    (%edx),%al
  8023c2:	83 e8 30             	sub    $0x30,%eax
  8023c5:	3c 09                	cmp    $0x9,%al
  8023c7:	77 08                	ja     8023d1 <strtol+0x84>
			dig = *s - '0';
  8023c9:	0f be 02             	movsbl (%edx),%eax
  8023cc:	83 e8 30             	sub    $0x30,%eax
  8023cf:	eb 20                	jmp    8023f1 <strtol+0xa4>
		else if (*s >= 'a' && *s <= 'z')
  8023d1:	8a 02                	mov    (%edx),%al
  8023d3:	83 e8 61             	sub    $0x61,%eax
  8023d6:	3c 19                	cmp    $0x19,%al
  8023d8:	77 08                	ja     8023e2 <strtol+0x95>
			dig = *s - 'a' + 10;
  8023da:	0f be 02             	movsbl (%edx),%eax
  8023dd:	83 e8 57             	sub    $0x57,%eax
  8023e0:	eb 0f                	jmp    8023f1 <strtol+0xa4>
		else if (*s >= 'A' && *s <= 'Z')
  8023e2:	8a 02                	mov    (%edx),%al
  8023e4:	83 e8 41             	sub    $0x41,%eax
  8023e7:	3c 19                	cmp    $0x19,%al
  8023e9:	77 12                	ja     8023fd <strtol+0xb0>
			dig = *s - 'A' + 10;
  8023eb:	0f be 02             	movsbl (%edx),%eax
  8023ee:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  8023f1:	39 c8                	cmp    %ecx,%eax
  8023f3:	7d 08                	jge    8023fd <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  8023f5:	42                   	inc    %edx
  8023f6:	0f af d9             	imul   %ecx,%ebx
  8023f9:	01 c3                	add    %eax,%ebx
  8023fb:	eb c3                	jmp    8023c0 <strtol+0x73>
		// we don't properly detect overflow!
	}

	if (endptr)
  8023fd:	85 f6                	test   %esi,%esi
  8023ff:	74 02                	je     802403 <strtol+0xb6>
		*endptr = (char *) s;
  802401:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  802403:	89 d8                	mov    %ebx,%eax
  802405:	85 ff                	test   %edi,%edi
  802407:	74 02                	je     80240b <strtol+0xbe>
  802409:	f7 d8                	neg    %eax
}
  80240b:	5b                   	pop    %ebx
  80240c:	5e                   	pop    %esi
  80240d:	5f                   	pop    %edi
  80240e:	c9                   	leave  
  80240f:	c3                   	ret    

00802410 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  802410:	55                   	push   %ebp
  802411:	89 e5                	mov    %esp,%ebp
  802413:	57                   	push   %edi
  802414:	56                   	push   %esi
  802415:	53                   	push   %ebx
  802416:	83 ec 04             	sub    $0x4,%esp
  802419:	8b 55 08             	mov    0x8(%ebp),%edx
  80241c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80241f:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802424:	89 f8                	mov    %edi,%eax
  802426:	89 fb                	mov    %edi,%ebx
  802428:	89 fe                	mov    %edi,%esi
  80242a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80242c:	83 c4 04             	add    $0x4,%esp
  80242f:	5b                   	pop    %ebx
  802430:	5e                   	pop    %esi
  802431:	5f                   	pop    %edi
  802432:	c9                   	leave  
  802433:	c3                   	ret    

00802434 <sys_cgetc>:

int
sys_cgetc(void)
{
  802434:	55                   	push   %ebp
  802435:	89 e5                	mov    %esp,%ebp
  802437:	57                   	push   %edi
  802438:	56                   	push   %esi
  802439:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80243a:	b8 01 00 00 00       	mov    $0x1,%eax
  80243f:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802444:	89 fa                	mov    %edi,%edx
  802446:	89 f9                	mov    %edi,%ecx
  802448:	89 fb                	mov    %edi,%ebx
  80244a:	89 fe                	mov    %edi,%esi
  80244c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80244e:	5b                   	pop    %ebx
  80244f:	5e                   	pop    %esi
  802450:	5f                   	pop    %edi
  802451:	c9                   	leave  
  802452:	c3                   	ret    

00802453 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  802453:	55                   	push   %ebp
  802454:	89 e5                	mov    %esp,%ebp
  802456:	57                   	push   %edi
  802457:	56                   	push   %esi
  802458:	53                   	push   %ebx
  802459:	83 ec 0c             	sub    $0xc,%esp
  80245c:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80245f:	b8 03 00 00 00       	mov    $0x3,%eax
  802464:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802469:	89 f9                	mov    %edi,%ecx
  80246b:	89 fb                	mov    %edi,%ebx
  80246d:	89 fe                	mov    %edi,%esi
  80246f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802471:	85 c0                	test   %eax,%eax
  802473:	7e 17                	jle    80248c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  802475:	83 ec 0c             	sub    $0xc,%esp
  802478:	50                   	push   %eax
  802479:	6a 03                	push   $0x3
  80247b:	68 b8 3c 80 00       	push   $0x803cb8
  802480:	6a 23                	push   $0x23
  802482:	68 d5 3c 80 00       	push   $0x803cd5
  802487:	e8 74 f6 ff ff       	call   801b00 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80248c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80248f:	5b                   	pop    %ebx
  802490:	5e                   	pop    %esi
  802491:	5f                   	pop    %edi
  802492:	c9                   	leave  
  802493:	c3                   	ret    

00802494 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  802494:	55                   	push   %ebp
  802495:	89 e5                	mov    %esp,%ebp
  802497:	57                   	push   %edi
  802498:	56                   	push   %esi
  802499:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80249a:	b8 02 00 00 00       	mov    $0x2,%eax
  80249f:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024a4:	89 fa                	mov    %edi,%edx
  8024a6:	89 f9                	mov    %edi,%ecx
  8024a8:	89 fb                	mov    %edi,%ebx
  8024aa:	89 fe                	mov    %edi,%esi
  8024ac:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8024ae:	5b                   	pop    %ebx
  8024af:	5e                   	pop    %esi
  8024b0:	5f                   	pop    %edi
  8024b1:	c9                   	leave  
  8024b2:	c3                   	ret    

008024b3 <sys_yield>:

void
sys_yield(void)
{
  8024b3:	55                   	push   %ebp
  8024b4:	89 e5                	mov    %esp,%ebp
  8024b6:	57                   	push   %edi
  8024b7:	56                   	push   %esi
  8024b8:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8024b9:	b8 0b 00 00 00       	mov    $0xb,%eax
  8024be:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024c3:	89 fa                	mov    %edi,%edx
  8024c5:	89 f9                	mov    %edi,%ecx
  8024c7:	89 fb                	mov    %edi,%ebx
  8024c9:	89 fe                	mov    %edi,%esi
  8024cb:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8024cd:	5b                   	pop    %ebx
  8024ce:	5e                   	pop    %esi
  8024cf:	5f                   	pop    %edi
  8024d0:	c9                   	leave  
  8024d1:	c3                   	ret    

008024d2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8024d2:	55                   	push   %ebp
  8024d3:	89 e5                	mov    %esp,%ebp
  8024d5:	57                   	push   %edi
  8024d6:	56                   	push   %esi
  8024d7:	53                   	push   %ebx
  8024d8:	83 ec 0c             	sub    $0xc,%esp
  8024db:	8b 55 08             	mov    0x8(%ebp),%edx
  8024de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024e1:	8b 5d 10             	mov    0x10(%ebp),%ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8024e4:	b8 04 00 00 00       	mov    $0x4,%eax
  8024e9:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024ee:	89 fe                	mov    %edi,%esi
  8024f0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8024f2:	85 c0                	test   %eax,%eax
  8024f4:	7e 17                	jle    80250d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8024f6:	83 ec 0c             	sub    $0xc,%esp
  8024f9:	50                   	push   %eax
  8024fa:	6a 04                	push   $0x4
  8024fc:	68 b8 3c 80 00       	push   $0x803cb8
  802501:	6a 23                	push   $0x23
  802503:	68 d5 3c 80 00       	push   $0x803cd5
  802508:	e8 f3 f5 ff ff       	call   801b00 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80250d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802510:	5b                   	pop    %ebx
  802511:	5e                   	pop    %esi
  802512:	5f                   	pop    %edi
  802513:	c9                   	leave  
  802514:	c3                   	ret    

00802515 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  802515:	55                   	push   %ebp
  802516:	89 e5                	mov    %esp,%ebp
  802518:	57                   	push   %edi
  802519:	56                   	push   %esi
  80251a:	53                   	push   %ebx
  80251b:	83 ec 0c             	sub    $0xc,%esp
  80251e:	8b 55 08             	mov    0x8(%ebp),%edx
  802521:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802524:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802527:	8b 7d 14             	mov    0x14(%ebp),%edi
  80252a:	8b 75 18             	mov    0x18(%ebp),%esi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80252d:	b8 05 00 00 00       	mov    $0x5,%eax
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802532:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802534:	85 c0                	test   %eax,%eax
  802536:	7e 17                	jle    80254f <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802538:	83 ec 0c             	sub    $0xc,%esp
  80253b:	50                   	push   %eax
  80253c:	6a 05                	push   $0x5
  80253e:	68 b8 3c 80 00       	push   $0x803cb8
  802543:	6a 23                	push   $0x23
  802545:	68 d5 3c 80 00       	push   $0x803cd5
  80254a:	e8 b1 f5 ff ff       	call   801b00 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80254f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802552:	5b                   	pop    %ebx
  802553:	5e                   	pop    %esi
  802554:	5f                   	pop    %edi
  802555:	c9                   	leave  
  802556:	c3                   	ret    

00802557 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  802557:	55                   	push   %ebp
  802558:	89 e5                	mov    %esp,%ebp
  80255a:	57                   	push   %edi
  80255b:	56                   	push   %esi
  80255c:	53                   	push   %ebx
  80255d:	83 ec 0c             	sub    $0xc,%esp
  802560:	8b 55 08             	mov    0x8(%ebp),%edx
  802563:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  802566:	b8 06 00 00 00       	mov    $0x6,%eax
  80256b:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802570:	89 fb                	mov    %edi,%ebx
  802572:	89 fe                	mov    %edi,%esi
  802574:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802576:	85 c0                	test   %eax,%eax
  802578:	7e 17                	jle    802591 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80257a:	83 ec 0c             	sub    $0xc,%esp
  80257d:	50                   	push   %eax
  80257e:	6a 06                	push   $0x6
  802580:	68 b8 3c 80 00       	push   $0x803cb8
  802585:	6a 23                	push   $0x23
  802587:	68 d5 3c 80 00       	push   $0x803cd5
  80258c:	e8 6f f5 ff ff       	call   801b00 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  802591:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802594:	5b                   	pop    %ebx
  802595:	5e                   	pop    %esi
  802596:	5f                   	pop    %edi
  802597:	c9                   	leave  
  802598:	c3                   	ret    

00802599 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  802599:	55                   	push   %ebp
  80259a:	89 e5                	mov    %esp,%ebp
  80259c:	57                   	push   %edi
  80259d:	56                   	push   %esi
  80259e:	53                   	push   %ebx
  80259f:	83 ec 0c             	sub    $0xc,%esp
  8025a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8025a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8025a8:	b8 08 00 00 00       	mov    $0x8,%eax
  8025ad:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025b2:	89 fb                	mov    %edi,%ebx
  8025b4:	89 fe                	mov    %edi,%esi
  8025b6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8025b8:	85 c0                	test   %eax,%eax
  8025ba:	7e 17                	jle    8025d3 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8025bc:	83 ec 0c             	sub    $0xc,%esp
  8025bf:	50                   	push   %eax
  8025c0:	6a 08                	push   $0x8
  8025c2:	68 b8 3c 80 00       	push   $0x803cb8
  8025c7:	6a 23                	push   $0x23
  8025c9:	68 d5 3c 80 00       	push   $0x803cd5
  8025ce:	e8 2d f5 ff ff       	call   801b00 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8025d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025d6:	5b                   	pop    %ebx
  8025d7:	5e                   	pop    %esi
  8025d8:	5f                   	pop    %edi
  8025d9:	c9                   	leave  
  8025da:	c3                   	ret    

008025db <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8025db:	55                   	push   %ebp
  8025dc:	89 e5                	mov    %esp,%ebp
  8025de:	57                   	push   %edi
  8025df:	56                   	push   %esi
  8025e0:	53                   	push   %ebx
  8025e1:	83 ec 0c             	sub    $0xc,%esp
  8025e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8025e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8025ea:	b8 09 00 00 00       	mov    $0x9,%eax
  8025ef:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025f4:	89 fb                	mov    %edi,%ebx
  8025f6:	89 fe                	mov    %edi,%esi
  8025f8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8025fa:	85 c0                	test   %eax,%eax
  8025fc:	7e 17                	jle    802615 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8025fe:	83 ec 0c             	sub    $0xc,%esp
  802601:	50                   	push   %eax
  802602:	6a 09                	push   $0x9
  802604:	68 b8 3c 80 00       	push   $0x803cb8
  802609:	6a 23                	push   $0x23
  80260b:	68 d5 3c 80 00       	push   $0x803cd5
  802610:	e8 eb f4 ff ff       	call   801b00 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  802615:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802618:	5b                   	pop    %ebx
  802619:	5e                   	pop    %esi
  80261a:	5f                   	pop    %edi
  80261b:	c9                   	leave  
  80261c:	c3                   	ret    

0080261d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80261d:	55                   	push   %ebp
  80261e:	89 e5                	mov    %esp,%ebp
  802620:	57                   	push   %edi
  802621:	56                   	push   %esi
  802622:	53                   	push   %ebx
  802623:	83 ec 0c             	sub    $0xc,%esp
  802626:	8b 55 08             	mov    0x8(%ebp),%edx
  802629:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80262c:	b8 0a 00 00 00       	mov    $0xa,%eax
  802631:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802636:	89 fb                	mov    %edi,%ebx
  802638:	89 fe                	mov    %edi,%esi
  80263a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80263c:	85 c0                	test   %eax,%eax
  80263e:	7e 17                	jle    802657 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802640:	83 ec 0c             	sub    $0xc,%esp
  802643:	50                   	push   %eax
  802644:	6a 0a                	push   $0xa
  802646:	68 b8 3c 80 00       	push   $0x803cb8
  80264b:	6a 23                	push   $0x23
  80264d:	68 d5 3c 80 00       	push   $0x803cd5
  802652:	e8 a9 f4 ff ff       	call   801b00 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  802657:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80265a:	5b                   	pop    %ebx
  80265b:	5e                   	pop    %esi
  80265c:	5f                   	pop    %edi
  80265d:	c9                   	leave  
  80265e:	c3                   	ret    

0080265f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80265f:	55                   	push   %ebp
  802660:	89 e5                	mov    %esp,%ebp
  802662:	57                   	push   %edi
  802663:	56                   	push   %esi
  802664:	53                   	push   %ebx
  802665:	8b 55 08             	mov    0x8(%ebp),%edx
  802668:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80266b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80266e:	8b 7d 14             	mov    0x14(%ebp),%edi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  802671:	b8 0c 00 00 00       	mov    $0xc,%eax
  802676:	be 00 00 00 00       	mov    $0x0,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80267b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80267d:	5b                   	pop    %ebx
  80267e:	5e                   	pop    %esi
  80267f:	5f                   	pop    %edi
  802680:	c9                   	leave  
  802681:	c3                   	ret    

00802682 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  802682:	55                   	push   %ebp
  802683:	89 e5                	mov    %esp,%ebp
  802685:	57                   	push   %edi
  802686:	56                   	push   %esi
  802687:	53                   	push   %ebx
  802688:	83 ec 0c             	sub    $0xc,%esp
  80268b:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80268e:	b8 0d 00 00 00       	mov    $0xd,%eax
  802693:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802698:	89 f9                	mov    %edi,%ecx
  80269a:	89 fb                	mov    %edi,%ebx
  80269c:	89 fe                	mov    %edi,%esi
  80269e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8026a0:	85 c0                	test   %eax,%eax
  8026a2:	7e 17                	jle    8026bb <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8026a4:	83 ec 0c             	sub    $0xc,%esp
  8026a7:	50                   	push   %eax
  8026a8:	6a 0d                	push   $0xd
  8026aa:	68 b8 3c 80 00       	push   $0x803cb8
  8026af:	6a 23                	push   $0x23
  8026b1:	68 d5 3c 80 00       	push   $0x803cd5
  8026b6:	e8 45 f4 ff ff       	call   801b00 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8026bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026be:	5b                   	pop    %ebx
  8026bf:	5e                   	pop    %esi
  8026c0:	5f                   	pop    %edi
  8026c1:	c9                   	leave  
  8026c2:	c3                   	ret    
	...

008026c4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8026c4:	55                   	push   %ebp
  8026c5:	89 e5                	mov    %esp,%ebp
  8026c7:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8026ca:	83 3d 10 90 80 00 00 	cmpl   $0x0,0x809010
  8026d1:	75 35                	jne    802708 <set_pgfault_handler+0x44>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_W | PTE_U | PTE_P);
  8026d3:	83 ec 04             	sub    $0x4,%esp
  8026d6:	6a 07                	push   $0x7
  8026d8:	68 00 f0 bf ee       	push   $0xeebff000
  8026dd:	83 ec 04             	sub    $0x4,%esp
  8026e0:	e8 af fd ff ff       	call   802494 <sys_getenvid>
  8026e5:	89 04 24             	mov    %eax,(%esp)
  8026e8:	e8 e5 fd ff ff       	call   8024d2 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);		
  8026ed:	83 c4 08             	add    $0x8,%esp
  8026f0:	68 14 27 80 00       	push   $0x802714
  8026f5:	83 ec 04             	sub    $0x4,%esp
  8026f8:	e8 97 fd ff ff       	call   802494 <sys_getenvid>
  8026fd:	89 04 24             	mov    %eax,(%esp)
  802700:	e8 18 ff ff ff       	call   80261d <sys_env_set_pgfault_upcall>
  802705:	83 c4 10             	add    $0x10,%esp
//		panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802708:	8b 45 08             	mov    0x8(%ebp),%eax
  80270b:	a3 10 90 80 00       	mov    %eax,0x809010
//	cprintf("_pgfault_upcall: %08x\n", thisenv->env_pgfault_upcall);
//	cprintf("_pgfault_handler is %08x\n", _pgfault_handler);
}
  802710:	c9                   	leave  
  802711:	c3                   	ret    
	...

00802714 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTrapframe
  802714:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802715:	a1 10 90 80 00       	mov    0x809010,%eax
	call *%eax
  80271a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80271c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx
  80271f:	89 e3                	mov    %esp,%ebx

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// trap-time esp
	movl 48(%esp), %ecx
  802721:	8b 4c 24 30          	mov    0x30(%esp),%ecx
	// trap-time eip
	movl 40(%esp), %edx 
  802725:	8b 54 24 28          	mov    0x28(%esp),%edx
	// switch to trap-time esp 
	movl %ecx, %esp 
  802729:	89 cc                	mov    %ecx,%esp
	// push trap-time eip to trap-time stack 
	pushl %edx 
  80272b:	52                   	push   %edx
	// return to user exception stack 
	movl %ebx, %esp 
  80272c:	89 dc                	mov    %ebx,%esp
	// update the trap-time esp stored in exception stack(because of pushed eip
	subl $4, %ecx
  80272e:	83 e9 04             	sub    $0x4,%ecx
	movl %ecx, 48(%esp)
  802731:	89 4c 24 30          	mov    %ecx,0x30(%esp)
	// restore general registars, ignoring fault_va & err
	addl $8, %esp
  802735:	83 c4 08             	add    $0x8,%esp
	popal
  802738:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	// skipping trap-time eip 
	addl $4, %esp
  802739:	83 c4 04             	add    $0x4,%esp
	// restore eflags
	popfl
  80273c:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80273d:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	ret
  80273e:	c3                   	ret    
	...

00802740 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802740:	55                   	push   %ebp
  802741:	89 e5                	mov    %esp,%ebp
  802743:	56                   	push   %esi
  802744:	53                   	push   %ebx
  802745:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802748:	8b 45 0c             	mov    0xc(%ebp),%eax
  80274b:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg == NULL)
  80274e:	85 c0                	test   %eax,%eax
  802750:	75 05                	jne    802757 <ipc_recv+0x17>
		pg = (void *) UTOP; // UTOP as "no page"
  802752:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	if ((r = sys_ipc_recv(pg)) < 0) {
  802757:	83 ec 0c             	sub    $0xc,%esp
  80275a:	50                   	push   %eax
  80275b:	e8 22 ff ff ff       	call   802682 <sys_ipc_recv>
  802760:	83 c4 10             	add    $0x10,%esp
  802763:	85 c0                	test   %eax,%eax
  802765:	79 16                	jns    80277d <ipc_recv+0x3d>
		if (from_env_store)
  802767:	85 db                	test   %ebx,%ebx
  802769:	74 06                	je     802771 <ipc_recv+0x31>
			*from_env_store = 0;
  80276b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store)
  802771:	85 f6                	test   %esi,%esi
  802773:	74 34                	je     8027a9 <ipc_recv+0x69>
			*perm_store = 0;
  802775:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return r;
  80277b:	eb 2c                	jmp    8027a9 <ipc_recv+0x69>
	}

	if (from_env_store)
  80277d:	85 db                	test   %ebx,%ebx
  80277f:	74 0a                	je     80278b <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  802781:	a1 0c 90 80 00       	mov    0x80900c,%eax
  802786:	8b 40 74             	mov    0x74(%eax),%eax
  802789:	89 03                	mov    %eax,(%ebx)
	if (perm_store && thisenv->env_ipc_perm != 0) {
  80278b:	85 f6                	test   %esi,%esi
  80278d:	74 12                	je     8027a1 <ipc_recv+0x61>
  80278f:	8b 15 0c 90 80 00    	mov    0x80900c,%edx
  802795:	8b 42 78             	mov    0x78(%edx),%eax
  802798:	85 c0                	test   %eax,%eax
  80279a:	74 05                	je     8027a1 <ipc_recv+0x61>
		*perm_store = thisenv->env_ipc_perm;
  80279c:	8b 42 78             	mov    0x78(%edx),%eax
  80279f:	89 06                	mov    %eax,(%esi)
//		sys_page_map(thisenv->env_id, pg, thisenv->env_id, pg, *perm_store);
	}	

	return thisenv->env_ipc_value;
  8027a1:	a1 0c 90 80 00       	mov    0x80900c,%eax
  8027a6:	8b 40 70             	mov    0x70(%eax),%eax
}
  8027a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8027ac:	5b                   	pop    %ebx
  8027ad:	5e                   	pop    %esi
  8027ae:	c9                   	leave  
  8027af:	c3                   	ret    

008027b0 <ipc_send>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
//   -> UTOP as "no page"
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8027b0:	55                   	push   %ebp
  8027b1:	89 e5                	mov    %esp,%ebp
  8027b3:	57                   	push   %edi
  8027b4:	56                   	push   %esi
  8027b5:	53                   	push   %ebx
  8027b6:	83 ec 0c             	sub    $0xc,%esp
  8027b9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8027bc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8027bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1) {
		if (pg)
  8027c2:	85 db                	test   %ebx,%ebx
  8027c4:	74 10                	je     8027d6 <ipc_send+0x26>
			r = sys_ipc_try_send(to_env, val, pg, perm);
  8027c6:	ff 75 14             	pushl  0x14(%ebp)
  8027c9:	53                   	push   %ebx
  8027ca:	56                   	push   %esi
  8027cb:	57                   	push   %edi
  8027cc:	e8 8e fe ff ff       	call   80265f <sys_ipc_try_send>
  8027d1:	83 c4 10             	add    $0x10,%esp
  8027d4:	eb 11                	jmp    8027e7 <ipc_send+0x37>
		else 
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  8027d6:	6a 00                	push   $0x0
  8027d8:	68 00 00 c0 ee       	push   $0xeec00000
  8027dd:	56                   	push   %esi
  8027de:	57                   	push   %edi
  8027df:	e8 7b fe ff ff       	call   80265f <sys_ipc_try_send>
  8027e4:	83 c4 10             	add    $0x10,%esp

		if (r == 0) 
  8027e7:	85 c0                	test   %eax,%eax
  8027e9:	74 1e                	je     802809 <ipc_send+0x59>
			break;
		
		if (r != -E_IPC_NOT_RECV) {
  8027eb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8027ee:	74 12                	je     802802 <ipc_send+0x52>
			panic("sys_ipc_try_send:unexpected err, %e", r);
  8027f0:	50                   	push   %eax
  8027f1:	68 e4 3c 80 00       	push   $0x803ce4
  8027f6:	6a 4a                	push   $0x4a
  8027f8:	68 08 3d 80 00       	push   $0x803d08
  8027fd:	e8 fe f2 ff ff       	call   801b00 <_panic>
		}
		sys_yield();
  802802:	e8 ac fc ff ff       	call   8024b3 <sys_yield>
  802807:	eb b9                	jmp    8027c2 <ipc_send+0x12>
	}
//	panic("ipc_send not implemented");
}
  802809:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80280c:	5b                   	pop    %ebx
  80280d:	5e                   	pop    %esi
  80280e:	5f                   	pop    %edi
  80280f:	c9                   	leave  
  802810:	c3                   	ret    

00802811 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802811:	55                   	push   %ebp
  802812:	89 e5                	mov    %esp,%ebp
  802814:	53                   	push   %ebx
  802815:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802818:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
  80281d:	89 d0                	mov    %edx,%eax
  80281f:	c1 e0 05             	shl    $0x5,%eax
  802822:	29 d0                	sub    %edx,%eax
  802824:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80282b:	8d 81 00 00 c0 ee    	lea    -0x11400000(%ecx),%eax
  802831:	8b 40 50             	mov    0x50(%eax),%eax
  802834:	39 d8                	cmp    %ebx,%eax
  802836:	75 0b                	jne    802843 <ipc_find_env+0x32>
			return envs[i].env_id;
  802838:	8d 81 08 00 c0 ee    	lea    -0x113ffff8(%ecx),%eax
  80283e:	8b 40 40             	mov    0x40(%eax),%eax
  802841:	eb 0e                	jmp    802851 <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802843:	42                   	inc    %edx
  802844:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  80284a:	7e d1                	jle    80281d <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80284c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802851:	5b                   	pop    %ebx
  802852:	c9                   	leave  
  802853:	c3                   	ret    

00802854 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802854:	55                   	push   %ebp
  802855:	89 e5                	mov    %esp,%ebp
  802857:	83 ec 08             	sub    $0x8,%esp
	static envid_t fsenv;
	if (fsenv == 0) {
  80285a:	83 3d 00 90 80 00 00 	cmpl   $0x0,0x809000
  802861:	75 12                	jne    802875 <fsipc+0x21>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802863:	83 ec 0c             	sub    $0xc,%esp
  802866:	6a 02                	push   $0x2
  802868:	e8 a4 ff ff ff       	call   802811 <ipc_find_env>
  80286d:	a3 00 90 80 00       	mov    %eax,0x809000
  802872:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802875:	6a 07                	push   $0x7
  802877:	68 00 a0 80 00       	push   $0x80a000
  80287c:	ff 75 08             	pushl  0x8(%ebp)
  80287f:	ff 35 00 90 80 00    	pushl  0x809000
  802885:	e8 26 ff ff ff       	call   8027b0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80288a:	83 c4 0c             	add    $0xc,%esp
  80288d:	6a 00                	push   $0x0
  80288f:	ff 75 0c             	pushl  0xc(%ebp)
  802892:	6a 00                	push   $0x0
  802894:	e8 a7 fe ff ff       	call   802740 <ipc_recv>
}
  802899:	c9                   	leave  
  80289a:	c3                   	ret    

0080289b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80289b:	55                   	push   %ebp
  80289c:	89 e5                	mov    %esp,%ebp
  80289e:	56                   	push   %esi
  80289f:	53                   	push   %ebx
  8028a0:	83 ec 1c             	sub    $0x1c,%esp
  8028a3:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;

	if (strlen(path) >= MAXPATHLEN)
  8028a6:	56                   	push   %esi
  8028a7:	e8 f8 f7 ff ff       	call   8020a4 <strlen>
  8028ac:	83 c4 10             	add    $0x10,%esp
		return -E_BAD_PATH;
  8028af:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;

	if (strlen(path) >= MAXPATHLEN)
  8028b4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8028b9:	7f 5f                	jg     80291a <open+0x7f>
		return -E_BAD_PATH;
	if ((r = fd_alloc(&fd)) < 0)
  8028bb:	83 ec 0c             	sub    $0xc,%esp
  8028be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8028c1:	50                   	push   %eax
  8028c2:	e8 41 02 00 00       	call   802b08 <fd_alloc>
  8028c7:	83 c4 10             	add    $0x10,%esp
		return r;
  8028ca:	89 c2                	mov    %eax,%edx
	struct Fd *fd;
	int r;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
	if ((r = fd_alloc(&fd)) < 0)
  8028cc:	85 c0                	test   %eax,%eax
  8028ce:	78 4a                	js     80291a <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8028d0:	83 ec 08             	sub    $0x8,%esp
  8028d3:	56                   	push   %esi
  8028d4:	68 00 a0 80 00       	push   $0x80a000
  8028d9:	e8 02 f8 ff ff       	call   8020e0 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8028de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8028e1:	a3 00 a4 80 00       	mov    %eax,0x80a400


	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8028e6:	83 c4 08             	add    $0x8,%esp
  8028e9:	ff 75 f4             	pushl  -0xc(%ebp)
  8028ec:	6a 01                	push   $0x1
  8028ee:	e8 61 ff ff ff       	call   802854 <fsipc>
  8028f3:	89 c3                	mov    %eax,%ebx
  8028f5:	83 c4 10             	add    $0x10,%esp
  8028f8:	85 c0                	test   %eax,%eax
  8028fa:	79 11                	jns    80290d <open+0x72>
		fd_close(fd, 0);
  8028fc:	83 ec 08             	sub    $0x8,%esp
  8028ff:	6a 00                	push   $0x0
  802901:	ff 75 f4             	pushl  -0xc(%ebp)
  802904:	e8 a7 02 00 00       	call   802bb0 <fd_close>
		return r;
  802909:	89 da                	mov    %ebx,%edx
  80290b:	eb 0d                	jmp    80291a <open+0x7f>
	}
	
	return fd2num(fd);	
  80290d:	83 ec 0c             	sub    $0xc,%esp
  802910:	ff 75 f4             	pushl  -0xc(%ebp)
  802913:	e8 c8 01 00 00       	call   802ae0 <fd2num>
  802918:	89 c2                	mov    %eax,%edx
}
  80291a:	89 d0                	mov    %edx,%eax
  80291c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80291f:	5b                   	pop    %ebx
  802920:	5e                   	pop    %esi
  802921:	c9                   	leave  
  802922:	c3                   	ret    

00802923 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802923:	55                   	push   %ebp
  802924:	89 e5                	mov    %esp,%ebp
  802926:	83 ec 10             	sub    $0x10,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802929:	8b 45 08             	mov    0x8(%ebp),%eax
  80292c:	8b 40 0c             	mov    0xc(%eax),%eax
  80292f:	a3 00 a0 80 00       	mov    %eax,0x80a000
	return fsipc(FSREQ_FLUSH, NULL);
  802934:	6a 00                	push   $0x0
  802936:	6a 06                	push   $0x6
  802938:	e8 17 ff ff ff       	call   802854 <fsipc>
}
  80293d:	c9                   	leave  
  80293e:	c3                   	ret    

0080293f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80293f:	55                   	push   %ebp
  802940:	89 e5                	mov    %esp,%ebp
  802942:	53                   	push   %ebx
  802943:	83 ec 0c             	sub    $0xc,%esp
	// The bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802946:	8b 45 08             	mov    0x8(%ebp),%eax
  802949:	8b 40 0c             	mov    0xc(%eax),%eax
  80294c:	a3 00 a0 80 00       	mov    %eax,0x80a000
	fsipcbuf.read.req_n = n;
  802951:	8b 45 10             	mov    0x10(%ebp),%eax
  802954:	a3 04 a0 80 00       	mov    %eax,0x80a004
		

	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802959:	6a 00                	push   $0x0
  80295b:	6a 03                	push   $0x3
  80295d:	e8 f2 fe ff ff       	call   802854 <fsipc>
  802962:	89 c3                	mov    %eax,%ebx
  802964:	83 c4 10             	add    $0x10,%esp
  802967:	85 db                	test   %ebx,%ebx
  802969:	78 13                	js     80297e <devfile_read+0x3f>
		return r;

	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80296b:	83 ec 04             	sub    $0x4,%esp
  80296e:	53                   	push   %ebx
  80296f:	68 00 a0 80 00       	push   $0x80a000
  802974:	ff 75 0c             	pushl  0xc(%ebp)
  802977:	e8 00 f9 ff ff       	call   80227c <memmove>
	return r;
  80297c:	89 d8                	mov    %ebx,%eax
}
  80297e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802981:	c9                   	leave  
  802982:	c3                   	ret    

00802983 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802983:	55                   	push   %ebp
  802984:	89 e5                	mov    %esp,%ebp
  802986:	83 ec 08             	sub    $0x8,%esp
  802989:	8b 45 10             	mov    0x10(%ebp),%eax
	// Be careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80298c:	8b 55 08             	mov    0x8(%ebp),%edx
  80298f:	8b 52 0c             	mov    0xc(%edx),%edx
  802992:	89 15 00 a0 80 00    	mov    %edx,0x80a000
	fsipcbuf.write.req_n = n;
  802998:	a3 04 a0 80 00       	mov    %eax,0x80a004
	memmove(fsipcbuf.write.req_buf, buf, MIN(n, PGSIZE - (sizeof(int) + sizeof(size_t))));
  80299d:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8029a2:	76 05                	jbe    8029a9 <devfile_write+0x26>
  8029a4:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  8029a9:	83 ec 04             	sub    $0x4,%esp
  8029ac:	50                   	push   %eax
  8029ad:	ff 75 0c             	pushl  0xc(%ebp)
  8029b0:	68 08 a0 80 00       	push   $0x80a008
  8029b5:	e8 c2 f8 ff ff       	call   80227c <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8029ba:	83 c4 08             	add    $0x8,%esp
  8029bd:	6a 00                	push   $0x0
  8029bf:	6a 04                	push   $0x4
  8029c1:	e8 8e fe ff ff       	call   802854 <fsipc>
  8029c6:	83 c4 10             	add    $0x10,%esp
		return r;
	return r;
}
  8029c9:	c9                   	leave  
  8029ca:	c3                   	ret    

008029cb <devfile_stat>:

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8029cb:	55                   	push   %ebp
  8029cc:	89 e5                	mov    %esp,%ebp
  8029ce:	53                   	push   %ebx
  8029cf:	83 ec 0c             	sub    $0xc,%esp
  8029d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8029d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8029d8:	8b 40 0c             	mov    0xc(%eax),%eax
  8029db:	a3 00 a0 80 00       	mov    %eax,0x80a000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8029e0:	6a 00                	push   $0x0
  8029e2:	6a 05                	push   $0x5
  8029e4:	e8 6b fe ff ff       	call   802854 <fsipc>
  8029e9:	83 c4 10             	add    $0x10,%esp
		return r;
  8029ec:	89 c2                	mov    %eax,%edx
devfile_stat(struct Fd *fd, struct Stat *st)
{
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8029ee:	85 c0                	test   %eax,%eax
  8029f0:	78 29                	js     802a1b <devfile_stat+0x50>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8029f2:	83 ec 08             	sub    $0x8,%esp
  8029f5:	68 00 a0 80 00       	push   $0x80a000
  8029fa:	53                   	push   %ebx
  8029fb:	e8 e0 f6 ff ff       	call   8020e0 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802a00:	a1 80 a0 80 00       	mov    0x80a080,%eax
  802a05:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802a0b:	a1 84 a0 80 00       	mov    0x80a084,%eax
  802a10:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802a16:	ba 00 00 00 00       	mov    $0x0,%edx
}
  802a1b:	89 d0                	mov    %edx,%eax
  802a1d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802a20:	c9                   	leave  
  802a21:	c3                   	ret    

00802a22 <devfile_trunc>:

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802a22:	55                   	push   %ebp
  802a23:	89 e5                	mov    %esp,%ebp
  802a25:	83 ec 10             	sub    $0x10,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802a28:	8b 45 08             	mov    0x8(%ebp),%eax
  802a2b:	8b 40 0c             	mov    0xc(%eax),%eax
  802a2e:	a3 00 a0 80 00       	mov    %eax,0x80a000
	fsipcbuf.set_size.req_size = newsize;
  802a33:	8b 45 0c             	mov    0xc(%ebp),%eax
  802a36:	a3 04 a0 80 00       	mov    %eax,0x80a004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802a3b:	6a 00                	push   $0x0
  802a3d:	6a 02                	push   $0x2
  802a3f:	e8 10 fe ff ff       	call   802854 <fsipc>
}
  802a44:	c9                   	leave  
  802a45:	c3                   	ret    

00802a46 <remove>:

// Delete a file
int
remove(const char *path)
{
  802a46:	55                   	push   %ebp
  802a47:	89 e5                	mov    %esp,%ebp
  802a49:	53                   	push   %ebx
  802a4a:	83 ec 10             	sub    $0x10,%esp
  802a4d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  802a50:	53                   	push   %ebx
  802a51:	e8 4e f6 ff ff       	call   8020a4 <strlen>
  802a56:	83 c4 10             	add    $0x10,%esp
		return -E_BAD_PATH;
  802a59:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx

// Delete a file
int
remove(const char *path)
{
	if (strlen(path) >= MAXPATHLEN)
  802a5e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802a63:	7f 1c                	jg     802a81 <remove+0x3b>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  802a65:	83 ec 08             	sub    $0x8,%esp
  802a68:	53                   	push   %ebx
  802a69:	68 00 a0 80 00       	push   $0x80a000
  802a6e:	e8 6d f6 ff ff       	call   8020e0 <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  802a73:	83 c4 08             	add    $0x8,%esp
  802a76:	6a 00                	push   $0x0
  802a78:	6a 07                	push   $0x7
  802a7a:	e8 d5 fd ff ff       	call   802854 <fsipc>
  802a7f:	89 c2                	mov    %eax,%edx
}
  802a81:	89 d0                	mov    %edx,%eax
  802a83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802a86:	c9                   	leave  
  802a87:	c3                   	ret    

00802a88 <sync>:

// Synchronize disk with buffer cache
int
sync(void)
{
  802a88:	55                   	push   %ebp
  802a89:	89 e5                	mov    %esp,%ebp
  802a8b:	83 ec 10             	sub    $0x10,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802a8e:	6a 00                	push   $0x0
  802a90:	6a 08                	push   $0x8
  802a92:	e8 bd fd ff ff       	call   802854 <fsipc>
}
  802a97:	c9                   	leave  
  802a98:	c3                   	ret    
  802a99:	00 00                	add    %al,(%eax)
	...

00802a9c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802a9c:	55                   	push   %ebp
  802a9d:	89 e5                	mov    %esp,%ebp
  802a9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  802aa2:	89 c8                	mov    %ecx,%eax
  802aa4:	c1 e8 16             	shr    $0x16,%eax
  802aa7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
		return 0;
  802aae:	ba 00 00 00 00       	mov    $0x0,%edx
int
pageref(void *v)
{
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  802ab3:	a8 01                	test   $0x1,%al
  802ab5:	74 25                	je     802adc <pageref+0x40>
		return 0;
	pte = vpt[PGNUM(v)];
  802ab7:	89 c8                	mov    %ecx,%eax
  802ab9:	c1 e8 0c             	shr    $0xc,%eax
  802abc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
		return 0;
  802ac3:	ba 00 00 00 00       	mov    $0x0,%edx
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
		return 0;
	pte = vpt[PGNUM(v)];
	if (!(pte & PTE_P))
  802ac8:	a8 01                	test   $0x1,%al
  802aca:	74 10                	je     802adc <pageref+0x40>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802acc:	c1 e8 0c             	shr    $0xc,%eax
  802acf:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  802ad4:	66 8b 44 c2 04       	mov    0x4(%edx,%eax,8),%ax
  802ad9:	0f b7 d0             	movzwl %ax,%edx
}
  802adc:	89 d0                	mov    %edx,%eax
  802ade:	c9                   	leave  
  802adf:	c3                   	ret    

00802ae0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  802ae0:	55                   	push   %ebp
  802ae1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802ae3:	8b 45 08             	mov    0x8(%ebp),%eax
  802ae6:	05 00 00 00 30       	add    $0x30000000,%eax
  802aeb:	c1 e8 0c             	shr    $0xc,%eax
}
  802aee:	c9                   	leave  
  802aef:	c3                   	ret    

00802af0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  802af0:	55                   	push   %ebp
  802af1:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  802af3:	ff 75 08             	pushl  0x8(%ebp)
  802af6:	e8 e5 ff ff ff       	call   802ae0 <fd2num>
  802afb:	83 c4 04             	add    $0x4,%esp
  802afe:	c1 e0 0c             	shl    $0xc,%eax
  802b01:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  802b06:	c9                   	leave  
  802b07:	c3                   	ret    

00802b08 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  802b08:	55                   	push   %ebp
  802b09:	89 e5                	mov    %esp,%ebp
  802b0b:	57                   	push   %edi
  802b0c:	56                   	push   %esi
  802b0d:	53                   	push   %ebx
  802b0e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  802b11:	b9 00 00 00 00       	mov    $0x0,%ecx
  802b16:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  802b1b:	bb 00 00 40 ef       	mov    $0xef400000,%ebx
		fd = INDEX2FD(i);
  802b20:	89 c8                	mov    %ecx,%eax
  802b22:	c1 e0 0c             	shl    $0xc,%eax
  802b25:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  802b2b:	89 d0                	mov    %edx,%eax
  802b2d:	c1 e8 16             	shr    $0x16,%eax
  802b30:	8b 04 86             	mov    (%esi,%eax,4),%eax
  802b33:	a8 01                	test   $0x1,%al
  802b35:	74 0c                	je     802b43 <fd_alloc+0x3b>
  802b37:	89 d0                	mov    %edx,%eax
  802b39:	c1 e8 0c             	shr    $0xc,%eax
  802b3c:	8b 04 83             	mov    (%ebx,%eax,4),%eax
  802b3f:	a8 01                	test   $0x1,%al
  802b41:	75 09                	jne    802b4c <fd_alloc+0x44>
			*fd_store = fd;
  802b43:	89 17                	mov    %edx,(%edi)
			return 0;
  802b45:	b8 00 00 00 00       	mov    $0x0,%eax
  802b4a:	eb 11                	jmp    802b5d <fd_alloc+0x55>
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  802b4c:	41                   	inc    %ecx
  802b4d:	83 f9 1f             	cmp    $0x1f,%ecx
  802b50:	7e ce                	jle    802b20 <fd_alloc+0x18>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  802b52:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
	return -E_MAX_OPEN;
  802b58:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  802b5d:	5b                   	pop    %ebx
  802b5e:	5e                   	pop    %esi
  802b5f:	5f                   	pop    %edi
  802b60:	c9                   	leave  
  802b61:	c3                   	ret    

00802b62 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  802b62:	55                   	push   %ebp
  802b63:	89 e5                	mov    %esp,%ebp
  802b65:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  802b68:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  802b6d:	83 f8 1f             	cmp    $0x1f,%eax
  802b70:	77 3a                	ja     802bac <fd_lookup+0x4a>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  802b72:	c1 e0 0c             	shl    $0xc,%eax
  802b75:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	///^&^ making sure fd page exists
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  802b7b:	89 d0                	mov    %edx,%eax
  802b7d:	c1 e8 16             	shr    $0x16,%eax
  802b80:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802b87:	a8 01                	test   $0x1,%al
  802b89:	74 10                	je     802b9b <fd_lookup+0x39>
  802b8b:	89 d0                	mov    %edx,%eax
  802b8d:	c1 e8 0c             	shr    $0xc,%eax
  802b90:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802b97:	a8 01                	test   $0x1,%al
  802b99:	75 07                	jne    802ba2 <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  802b9b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802ba0:	eb 0a                	jmp    802bac <fd_lookup+0x4a>
	}
	*fd_store = fd;
  802ba2:	8b 45 0c             	mov    0xc(%ebp),%eax
  802ba5:	89 10                	mov    %edx,(%eax)
	return 0;
  802ba7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  802bac:	89 d0                	mov    %edx,%eax
  802bae:	c9                   	leave  
  802baf:	c3                   	ret    

00802bb0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  802bb0:	55                   	push   %ebp
  802bb1:	89 e5                	mov    %esp,%ebp
  802bb3:	56                   	push   %esi
  802bb4:	53                   	push   %ebx
  802bb5:	83 ec 10             	sub    $0x10,%esp
  802bb8:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802bbb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802bbe:	50                   	push   %eax
  802bbf:	56                   	push   %esi
  802bc0:	e8 1b ff ff ff       	call   802ae0 <fd2num>
  802bc5:	89 04 24             	mov    %eax,(%esp)
  802bc8:	e8 95 ff ff ff       	call   802b62 <fd_lookup>
  802bcd:	89 c3                	mov    %eax,%ebx
  802bcf:	83 c4 08             	add    $0x8,%esp
  802bd2:	85 c0                	test   %eax,%eax
  802bd4:	78 05                	js     802bdb <fd_close+0x2b>
  802bd6:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  802bd9:	74 0f                	je     802bea <fd_close+0x3a>
	    || fd != fd2)
		return (must_exist ? r : 0);
  802bdb:	89 d8                	mov    %ebx,%eax
  802bdd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802be1:	75 45                	jne    802c28 <fd_close+0x78>
  802be3:	b8 00 00 00 00       	mov    $0x0,%eax
  802be8:	eb 3e                	jmp    802c28 <fd_close+0x78>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802bea:	83 ec 08             	sub    $0x8,%esp
  802bed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802bf0:	50                   	push   %eax
  802bf1:	ff 36                	pushl  (%esi)
  802bf3:	e8 37 00 00 00       	call   802c2f <dev_lookup>
  802bf8:	89 c3                	mov    %eax,%ebx
  802bfa:	83 c4 10             	add    $0x10,%esp
  802bfd:	85 c0                	test   %eax,%eax
  802bff:	78 1a                	js     802c1b <fd_close+0x6b>
		if (dev->dev_close)
  802c01:	8b 45 f0             	mov    -0x10(%ebp),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  802c04:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  802c09:	83 78 10 00          	cmpl   $0x0,0x10(%eax)
  802c0d:	74 0c                	je     802c1b <fd_close+0x6b>
			r = (*dev->dev_close)(fd);
  802c0f:	83 ec 0c             	sub    $0xc,%esp
  802c12:	56                   	push   %esi
  802c13:	ff 50 10             	call   *0x10(%eax)
  802c16:	89 c3                	mov    %eax,%ebx
  802c18:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  802c1b:	83 ec 08             	sub    $0x8,%esp
  802c1e:	56                   	push   %esi
  802c1f:	6a 00                	push   $0x0
  802c21:	e8 31 f9 ff ff       	call   802557 <sys_page_unmap>
	return r;
  802c26:	89 d8                	mov    %ebx,%eax
}
  802c28:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802c2b:	5b                   	pop    %ebx
  802c2c:	5e                   	pop    %esi
  802c2d:	c9                   	leave  
  802c2e:	c3                   	ret    

00802c2f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802c2f:	55                   	push   %ebp
  802c30:	89 e5                	mov    %esp,%ebp
  802c32:	56                   	push   %esi
  802c33:	53                   	push   %ebx
  802c34:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802c37:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i;
	for (i = 0; devtab[i]; i++)
  802c3a:	ba 00 00 00 00       	mov    $0x0,%edx
  802c3f:	83 3d 88 80 80 00 00 	cmpl   $0x0,0x808088
  802c46:	74 1c                	je     802c64 <dev_lookup+0x35>
  802c48:	b9 88 80 80 00       	mov    $0x808088,%ecx
		if (devtab[i]->dev_id == dev_id) {
  802c4d:	8b 04 91             	mov    (%ecx,%edx,4),%eax
  802c50:	39 18                	cmp    %ebx,(%eax)
  802c52:	75 09                	jne    802c5d <dev_lookup+0x2e>
			*dev = devtab[i];
  802c54:	89 06                	mov    %eax,(%esi)
			return 0;
  802c56:	b8 00 00 00 00       	mov    $0x0,%eax
  802c5b:	eb 29                	jmp    802c86 <dev_lookup+0x57>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  802c5d:	42                   	inc    %edx
  802c5e:	83 3c 91 00          	cmpl   $0x0,(%ecx,%edx,4)
  802c62:	75 e9                	jne    802c4d <dev_lookup+0x1e>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  802c64:	83 ec 04             	sub    $0x4,%esp
  802c67:	53                   	push   %ebx
  802c68:	a1 0c 90 80 00       	mov    0x80900c,%eax
  802c6d:	8b 40 48             	mov    0x48(%eax),%eax
  802c70:	50                   	push   %eax
  802c71:	68 14 3d 80 00       	push   $0x803d14
  802c76:	e8 61 ef ff ff       	call   801bdc <cprintf>
	*dev = 0;
  802c7b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	return -E_INVAL;
  802c81:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802c86:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802c89:	5b                   	pop    %ebx
  802c8a:	5e                   	pop    %esi
  802c8b:	c9                   	leave  
  802c8c:	c3                   	ret    

00802c8d <close>:

int
close(int fdnum)
{
  802c8d:	55                   	push   %ebp
  802c8e:	89 e5                	mov    %esp,%ebp
  802c90:	83 ec 08             	sub    $0x8,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802c93:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802c96:	50                   	push   %eax
  802c97:	ff 75 08             	pushl  0x8(%ebp)
  802c9a:	e8 c3 fe ff ff       	call   802b62 <fd_lookup>
  802c9f:	83 c4 08             	add    $0x8,%esp
		return r;
  802ca2:	89 c2                	mov    %eax,%edx
close(int fdnum)
{
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802ca4:	85 c0                	test   %eax,%eax
  802ca6:	78 0f                	js     802cb7 <close+0x2a>
		return r;
	else
		return fd_close(fd, 1);
  802ca8:	83 ec 08             	sub    $0x8,%esp
  802cab:	6a 01                	push   $0x1
  802cad:	ff 75 fc             	pushl  -0x4(%ebp)
  802cb0:	e8 fb fe ff ff       	call   802bb0 <fd_close>
  802cb5:	89 c2                	mov    %eax,%edx
}
  802cb7:	89 d0                	mov    %edx,%eax
  802cb9:	c9                   	leave  
  802cba:	c3                   	ret    

00802cbb <close_all>:

void
close_all(void)
{
  802cbb:	55                   	push   %ebp
  802cbc:	89 e5                	mov    %esp,%ebp
  802cbe:	53                   	push   %ebx
  802cbf:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802cc2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802cc7:	83 ec 0c             	sub    $0xc,%esp
  802cca:	53                   	push   %ebx
  802ccb:	e8 bd ff ff ff       	call   802c8d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  802cd0:	83 c4 10             	add    $0x10,%esp
  802cd3:	43                   	inc    %ebx
  802cd4:	83 fb 1f             	cmp    $0x1f,%ebx
  802cd7:	7e ee                	jle    802cc7 <close_all+0xc>
		close(i);
}
  802cd9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802cdc:	c9                   	leave  
  802cdd:	c3                   	ret    

00802cde <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802cde:	55                   	push   %ebp
  802cdf:	89 e5                	mov    %esp,%ebp
  802ce1:	57                   	push   %edi
  802ce2:	56                   	push   %esi
  802ce3:	53                   	push   %ebx
  802ce4:	83 ec 0c             	sub    $0xc,%esp
  802ce7:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802cea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802ced:	50                   	push   %eax
  802cee:	ff 75 08             	pushl  0x8(%ebp)
  802cf1:	e8 6c fe ff ff       	call   802b62 <fd_lookup>
  802cf6:	89 c3                	mov    %eax,%ebx
  802cf8:	83 c4 08             	add    $0x8,%esp
  802cfb:	85 db                	test   %ebx,%ebx
  802cfd:	0f 88 b7 00 00 00    	js     802dba <dup+0xdc>
		return r;
	close(newfdnum);
  802d03:	83 ec 0c             	sub    $0xc,%esp
  802d06:	57                   	push   %edi
  802d07:	e8 81 ff ff ff       	call   802c8d <close>

	newfd = INDEX2FD(newfdnum);
  802d0c:	89 f8                	mov    %edi,%eax
  802d0e:	c1 e0 0c             	shl    $0xc,%eax
  802d11:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  802d17:	ff 75 f0             	pushl  -0x10(%ebp)
  802d1a:	e8 d1 fd ff ff       	call   802af0 <fd2data>
  802d1f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  802d21:	89 34 24             	mov    %esi,(%esp)
  802d24:	e8 c7 fd ff ff       	call   802af0 <fd2data>
  802d29:	89 45 ec             	mov    %eax,-0x14(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  802d2c:	89 d8                	mov    %ebx,%eax
  802d2e:	c1 e8 16             	shr    $0x16,%eax
  802d31:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802d38:	83 c4 14             	add    $0x14,%esp
  802d3b:	a8 01                	test   $0x1,%al
  802d3d:	74 33                	je     802d72 <dup+0x94>
  802d3f:	89 da                	mov    %ebx,%edx
  802d41:	c1 ea 0c             	shr    $0xc,%edx
  802d44:	b9 00 00 40 ef       	mov    $0xef400000,%ecx
  802d49:	8b 04 91             	mov    (%ecx,%edx,4),%eax
  802d4c:	a8 01                	test   $0x1,%al
  802d4e:	74 22                	je     802d72 <dup+0x94>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802d50:	83 ec 0c             	sub    $0xc,%esp
  802d53:	8b 04 91             	mov    (%ecx,%edx,4),%eax
  802d56:	25 07 0e 00 00       	and    $0xe07,%eax
  802d5b:	50                   	push   %eax
  802d5c:	ff 75 ec             	pushl  -0x14(%ebp)
  802d5f:	6a 00                	push   $0x0
  802d61:	53                   	push   %ebx
  802d62:	6a 00                	push   $0x0
  802d64:	e8 ac f7 ff ff       	call   802515 <sys_page_map>
  802d69:	89 c3                	mov    %eax,%ebx
  802d6b:	83 c4 20             	add    $0x20,%esp
  802d6e:	85 c0                	test   %eax,%eax
  802d70:	78 2e                	js     802da0 <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802d72:	83 ec 0c             	sub    $0xc,%esp
  802d75:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802d78:	89 d0                	mov    %edx,%eax
  802d7a:	c1 e8 0c             	shr    $0xc,%eax
  802d7d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802d84:	25 07 0e 00 00       	and    $0xe07,%eax
  802d89:	50                   	push   %eax
  802d8a:	56                   	push   %esi
  802d8b:	6a 00                	push   $0x0
  802d8d:	52                   	push   %edx
  802d8e:	6a 00                	push   $0x0
  802d90:	e8 80 f7 ff ff       	call   802515 <sys_page_map>
  802d95:	89 c3                	mov    %eax,%ebx
  802d97:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  802d9a:	89 f8                	mov    %edi,%eax
	nva = fd2data(newfd);

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802d9c:	85 db                	test   %ebx,%ebx
  802d9e:	79 1a                	jns    802dba <dup+0xdc>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802da0:	83 ec 08             	sub    $0x8,%esp
  802da3:	56                   	push   %esi
  802da4:	6a 00                	push   $0x0
  802da6:	e8 ac f7 ff ff       	call   802557 <sys_page_unmap>
	sys_page_unmap(0, nva);
  802dab:	83 c4 08             	add    $0x8,%esp
  802dae:	ff 75 ec             	pushl  -0x14(%ebp)
  802db1:	6a 00                	push   $0x0
  802db3:	e8 9f f7 ff ff       	call   802557 <sys_page_unmap>
	return r;
  802db8:	89 d8                	mov    %ebx,%eax
}
  802dba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802dbd:	5b                   	pop    %ebx
  802dbe:	5e                   	pop    %esi
  802dbf:	5f                   	pop    %edi
  802dc0:	c9                   	leave  
  802dc1:	c3                   	ret    

00802dc2 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802dc2:	55                   	push   %ebp
  802dc3:	89 e5                	mov    %esp,%ebp
  802dc5:	53                   	push   %ebx
  802dc6:	83 ec 14             	sub    $0x14,%esp
  802dc9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802dcc:	8d 45 f8             	lea    -0x8(%ebp),%eax
  802dcf:	50                   	push   %eax
  802dd0:	53                   	push   %ebx
  802dd1:	e8 8c fd ff ff       	call   802b62 <fd_lookup>
  802dd6:	83 c4 08             	add    $0x8,%esp
  802dd9:	85 c0                	test   %eax,%eax
  802ddb:	78 18                	js     802df5 <read+0x33>
  802ddd:	83 ec 08             	sub    $0x8,%esp
  802de0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802de3:	50                   	push   %eax
  802de4:	8b 45 f8             	mov    -0x8(%ebp),%eax
  802de7:	ff 30                	pushl  (%eax)
  802de9:	e8 41 fe ff ff       	call   802c2f <dev_lookup>
  802dee:	83 c4 10             	add    $0x10,%esp
  802df1:	85 c0                	test   %eax,%eax
  802df3:	79 04                	jns    802df9 <read+0x37>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
  802df5:	89 c2                	mov    %eax,%edx
  802df7:	eb 4e                	jmp    802e47 <read+0x85>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802df9:	8b 45 f8             	mov    -0x8(%ebp),%eax
  802dfc:	8b 40 08             	mov    0x8(%eax),%eax
  802dff:	83 e0 03             	and    $0x3,%eax
  802e02:	83 f8 01             	cmp    $0x1,%eax
  802e05:	75 1e                	jne    802e25 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802e07:	83 ec 04             	sub    $0x4,%esp
  802e0a:	53                   	push   %ebx
  802e0b:	a1 0c 90 80 00       	mov    0x80900c,%eax
  802e10:	8b 40 48             	mov    0x48(%eax),%eax
  802e13:	50                   	push   %eax
  802e14:	68 58 3d 80 00       	push   $0x803d58
  802e19:	e8 be ed ff ff       	call   801bdc <cprintf>
		return -E_INVAL;
  802e1e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802e23:	eb 22                	jmp    802e47 <read+0x85>
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802e25:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  802e2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e2d:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
  802e31:	74 14                	je     802e47 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802e33:	83 ec 04             	sub    $0x4,%esp
  802e36:	ff 75 10             	pushl  0x10(%ebp)
  802e39:	ff 75 0c             	pushl  0xc(%ebp)
  802e3c:	ff 75 f8             	pushl  -0x8(%ebp)
  802e3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e42:	ff 50 08             	call   *0x8(%eax)
  802e45:	89 c2                	mov    %eax,%edx
}
  802e47:	89 d0                	mov    %edx,%eax
  802e49:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e4c:	c9                   	leave  
  802e4d:	c3                   	ret    

00802e4e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802e4e:	55                   	push   %ebp
  802e4f:	89 e5                	mov    %esp,%ebp
  802e51:	57                   	push   %edi
  802e52:	56                   	push   %esi
  802e53:	53                   	push   %ebx
  802e54:	83 ec 0c             	sub    $0xc,%esp
  802e57:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802e5a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802e5d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802e62:	39 f3                	cmp    %esi,%ebx
  802e64:	73 25                	jae    802e8b <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802e66:	83 ec 04             	sub    $0x4,%esp
  802e69:	89 f0                	mov    %esi,%eax
  802e6b:	29 d8                	sub    %ebx,%eax
  802e6d:	50                   	push   %eax
  802e6e:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
  802e71:	50                   	push   %eax
  802e72:	ff 75 08             	pushl  0x8(%ebp)
  802e75:	e8 48 ff ff ff       	call   802dc2 <read>
		if (m < 0)
  802e7a:	83 c4 10             	add    $0x10,%esp
  802e7d:	85 c0                	test   %eax,%eax
  802e7f:	78 0c                	js     802e8d <readn+0x3f>
			return m;
		if (m == 0)
  802e81:	85 c0                	test   %eax,%eax
  802e83:	74 06                	je     802e8b <readn+0x3d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802e85:	01 c3                	add    %eax,%ebx
  802e87:	39 f3                	cmp    %esi,%ebx
  802e89:	72 db                	jb     802e66 <readn+0x18>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  802e8b:	89 d8                	mov    %ebx,%eax
}
  802e8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802e90:	5b                   	pop    %ebx
  802e91:	5e                   	pop    %esi
  802e92:	5f                   	pop    %edi
  802e93:	c9                   	leave  
  802e94:	c3                   	ret    

00802e95 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802e95:	55                   	push   %ebp
  802e96:	89 e5                	mov    %esp,%ebp
  802e98:	53                   	push   %ebx
  802e99:	83 ec 14             	sub    $0x14,%esp
  802e9c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802e9f:	8d 45 f8             	lea    -0x8(%ebp),%eax
  802ea2:	50                   	push   %eax
  802ea3:	53                   	push   %ebx
  802ea4:	e8 b9 fc ff ff       	call   802b62 <fd_lookup>
  802ea9:	83 c4 08             	add    $0x8,%esp
  802eac:	85 c0                	test   %eax,%eax
  802eae:	78 18                	js     802ec8 <write+0x33>
  802eb0:	83 ec 08             	sub    $0x8,%esp
  802eb3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802eb6:	50                   	push   %eax
  802eb7:	8b 45 f8             	mov    -0x8(%ebp),%eax
  802eba:	ff 30                	pushl  (%eax)
  802ebc:	e8 6e fd ff ff       	call   802c2f <dev_lookup>
  802ec1:	83 c4 10             	add    $0x10,%esp
  802ec4:	85 c0                	test   %eax,%eax
  802ec6:	79 04                	jns    802ecc <write+0x37>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
  802ec8:	89 c2                	mov    %eax,%edx
  802eca:	eb 49                	jmp    802f15 <write+0x80>
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802ecc:	8b 45 f8             	mov    -0x8(%ebp),%eax
  802ecf:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802ed3:	75 1e                	jne    802ef3 <write+0x5e>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802ed5:	83 ec 04             	sub    $0x4,%esp
  802ed8:	53                   	push   %ebx
  802ed9:	a1 0c 90 80 00       	mov    0x80900c,%eax
  802ede:	8b 40 48             	mov    0x48(%eax),%eax
  802ee1:	50                   	push   %eax
  802ee2:	68 74 3d 80 00       	push   $0x803d74
  802ee7:	e8 f0 ec ff ff       	call   801bdc <cprintf>
		return -E_INVAL;
  802eec:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802ef1:	eb 22                	jmp    802f15 <write+0x80>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802ef3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802ef8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802efb:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  802eff:	74 14                	je     802f15 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802f01:	83 ec 04             	sub    $0x4,%esp
  802f04:	ff 75 10             	pushl  0x10(%ebp)
  802f07:	ff 75 0c             	pushl  0xc(%ebp)
  802f0a:	ff 75 f8             	pushl  -0x8(%ebp)
  802f0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802f10:	ff 50 0c             	call   *0xc(%eax)
  802f13:	89 c2                	mov    %eax,%edx
}
  802f15:	89 d0                	mov    %edx,%eax
  802f17:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802f1a:	c9                   	leave  
  802f1b:	c3                   	ret    

00802f1c <seek>:

int
seek(int fdnum, off_t offset)
{
  802f1c:	55                   	push   %ebp
  802f1d:	89 e5                	mov    %esp,%ebp
  802f1f:	83 ec 04             	sub    $0x4,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802f22:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802f25:	50                   	push   %eax
  802f26:	ff 75 08             	pushl  0x8(%ebp)
  802f29:	e8 34 fc ff ff       	call   802b62 <fd_lookup>
  802f2e:	83 c4 08             	add    $0x8,%esp
		return r;
  802f31:	89 c2                	mov    %eax,%edx
seek(int fdnum, off_t offset)
{
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802f33:	85 c0                	test   %eax,%eax
  802f35:	78 0e                	js     802f45 <seek+0x29>
		return r;
	fd->fd_offset = offset;
  802f37:	8b 55 0c             	mov    0xc(%ebp),%edx
  802f3a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802f3d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802f40:	ba 00 00 00 00       	mov    $0x0,%edx
}
  802f45:	89 d0                	mov    %edx,%eax
  802f47:	c9                   	leave  
  802f48:	c3                   	ret    

00802f49 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802f49:	55                   	push   %ebp
  802f4a:	89 e5                	mov    %esp,%ebp
  802f4c:	53                   	push   %ebx
  802f4d:	83 ec 14             	sub    $0x14,%esp
  802f50:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802f53:	8d 45 f8             	lea    -0x8(%ebp),%eax
  802f56:	50                   	push   %eax
  802f57:	53                   	push   %ebx
  802f58:	e8 05 fc ff ff       	call   802b62 <fd_lookup>
  802f5d:	83 c4 08             	add    $0x8,%esp
  802f60:	85 c0                	test   %eax,%eax
  802f62:	78 18                	js     802f7c <ftruncate+0x33>
  802f64:	83 ec 08             	sub    $0x8,%esp
  802f67:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802f6a:	50                   	push   %eax
  802f6b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  802f6e:	ff 30                	pushl  (%eax)
  802f70:	e8 ba fc ff ff       	call   802c2f <dev_lookup>
  802f75:	83 c4 10             	add    $0x10,%esp
  802f78:	85 c0                	test   %eax,%eax
  802f7a:	79 04                	jns    802f80 <ftruncate+0x37>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0) 
		return r;
  802f7c:	89 c2                	mov    %eax,%edx
  802f7e:	eb 46                	jmp    802fc6 <ftruncate+0x7d>
	

	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802f80:	8b 45 f8             	mov    -0x8(%ebp),%eax
  802f83:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802f87:	75 1e                	jne    802fa7 <ftruncate+0x5e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802f89:	83 ec 04             	sub    $0x4,%esp
  802f8c:	53                   	push   %ebx
  802f8d:	a1 0c 90 80 00       	mov    0x80900c,%eax
  802f92:	8b 40 48             	mov    0x48(%eax),%eax
  802f95:	50                   	push   %eax
  802f96:	68 34 3d 80 00       	push   $0x803d34
  802f9b:	e8 3c ec ff ff       	call   801bdc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802fa0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802fa5:	eb 1f                	jmp    802fc6 <ftruncate+0x7d>
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  802fa7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  802fac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802faf:	83 78 18 00          	cmpl   $0x0,0x18(%eax)
  802fb3:	74 11                	je     802fc6 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802fb5:	83 ec 08             	sub    $0x8,%esp
  802fb8:	ff 75 0c             	pushl  0xc(%ebp)
  802fbb:	ff 75 f8             	pushl  -0x8(%ebp)
  802fbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802fc1:	ff 50 18             	call   *0x18(%eax)
  802fc4:	89 c2                	mov    %eax,%edx
}
  802fc6:	89 d0                	mov    %edx,%eax
  802fc8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802fcb:	c9                   	leave  
  802fcc:	c3                   	ret    

00802fcd <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802fcd:	55                   	push   %ebp
  802fce:	89 e5                	mov    %esp,%ebp
  802fd0:	53                   	push   %ebx
  802fd1:	83 ec 14             	sub    $0x14,%esp
  802fd4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802fd7:	8d 45 f8             	lea    -0x8(%ebp),%eax
  802fda:	50                   	push   %eax
  802fdb:	ff 75 08             	pushl  0x8(%ebp)
  802fde:	e8 7f fb ff ff       	call   802b62 <fd_lookup>
  802fe3:	83 c4 08             	add    $0x8,%esp
  802fe6:	85 c0                	test   %eax,%eax
  802fe8:	78 18                	js     803002 <fstat+0x35>
  802fea:	83 ec 08             	sub    $0x8,%esp
  802fed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802ff0:	50                   	push   %eax
  802ff1:	8b 45 f8             	mov    -0x8(%ebp),%eax
  802ff4:	ff 30                	pushl  (%eax)
  802ff6:	e8 34 fc ff ff       	call   802c2f <dev_lookup>
  802ffb:	83 c4 10             	add    $0x10,%esp
  802ffe:	85 c0                	test   %eax,%eax
  803000:	79 04                	jns    803006 <fstat+0x39>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
  803002:	89 c2                	mov    %eax,%edx
  803004:	eb 3a                	jmp    803040 <fstat+0x73>
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  803006:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  80300b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80300e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  803012:	74 2c                	je     803040 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  803014:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  803017:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80301e:	00 00 00 
	stat->st_isdir = 0;
  803021:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  803028:	00 00 00 
	stat->st_dev = dev;
  80302b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80302e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  803034:	83 ec 08             	sub    $0x8,%esp
  803037:	53                   	push   %ebx
  803038:	ff 75 f8             	pushl  -0x8(%ebp)
  80303b:	ff 50 14             	call   *0x14(%eax)
  80303e:	89 c2                	mov    %eax,%edx
}
  803040:	89 d0                	mov    %edx,%eax
  803042:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803045:	c9                   	leave  
  803046:	c3                   	ret    

00803047 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  803047:	55                   	push   %ebp
  803048:	89 e5                	mov    %esp,%ebp
  80304a:	56                   	push   %esi
  80304b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80304c:	83 ec 08             	sub    $0x8,%esp
  80304f:	6a 00                	push   $0x0
  803051:	ff 75 08             	pushl  0x8(%ebp)
  803054:	e8 42 f8 ff ff       	call   80289b <open>
  803059:	89 c6                	mov    %eax,%esi
  80305b:	83 c4 10             	add    $0x10,%esp
  80305e:	85 f6                	test   %esi,%esi
  803060:	78 18                	js     80307a <stat+0x33>
		return fd;
	r = fstat(fd, stat);
  803062:	83 ec 08             	sub    $0x8,%esp
  803065:	ff 75 0c             	pushl  0xc(%ebp)
  803068:	56                   	push   %esi
  803069:	e8 5f ff ff ff       	call   802fcd <fstat>
  80306e:	89 c3                	mov    %eax,%ebx
	close(fd);
  803070:	89 34 24             	mov    %esi,(%esp)
  803073:	e8 15 fc ff ff       	call   802c8d <close>
	return r;
  803078:	89 d8                	mov    %ebx,%eax
}
  80307a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80307d:	5b                   	pop    %ebx
  80307e:	5e                   	pop    %esi
  80307f:	c9                   	leave  
  803080:	c3                   	ret    
  803081:	00 00                	add    %al,(%eax)
	...

00803084 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  803084:	55                   	push   %ebp
  803085:	89 e5                	mov    %esp,%ebp
  803087:	57                   	push   %edi
  803088:	56                   	push   %esi
  803089:	83 ec 14             	sub    $0x14,%esp
  80308c:	8b 55 14             	mov    0x14(%ebp),%edx
  80308f:	8b 75 08             	mov    0x8(%ebp),%esi
  803092:	8b 7d 0c             	mov    0xc(%ebp),%edi
  803095:	8b 45 10             	mov    0x10(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  803098:	85 d2                	test   %edx,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80309a:	89 75 f0             	mov    %esi,-0x10(%ebp)
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  80309d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  d1 = dd.s.high;
  8030a0:	89 55 f4             	mov    %edx,-0xc(%ebp)
  n0 = nn.s.low;
  n1 = nn.s.high;
  8030a3:	89 fe                	mov    %edi,%esi

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8030a5:	75 11                	jne    8030b8 <__udivdi3+0x34>
    {
      if (d0 > n1)
  8030a7:	39 f8                	cmp    %edi,%eax
  8030a9:	76 4d                	jbe    8030f8 <__udivdi3+0x74>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8030ab:	89 fa                	mov    %edi,%edx
  8030ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8030b0:	f7 75 e4             	divl   -0x1c(%ebp)
  8030b3:	89 c7                	mov    %eax,%edi
  8030b5:	eb 09                	jmp    8030c0 <__udivdi3+0x3c>
  8030b7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8030b8:	39 7d f4             	cmp    %edi,-0xc(%ebp)
  8030bb:	76 17                	jbe    8030d4 <__udivdi3+0x50>
	{
	  /* 00 = nn / DD */

	  q0 = 0;
  8030bd:	31 ff                	xor    %edi,%edi
  8030bf:	90                   	nop
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
		}

	      q1 = 0;
  8030c0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8030c7:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8030ca:	83 c4 14             	add    $0x14,%esp
  8030cd:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8030ce:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8030d0:	5f                   	pop    %edi
  8030d1:	c9                   	leave  
  8030d2:	c3                   	ret    
  8030d3:	90                   	nop
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8030d4:	0f bd 45 f4          	bsr    -0xc(%ebp),%eax
	  if (bm == 0)
  8030d8:	89 c7                	mov    %eax,%edi
  8030da:	83 f7 1f             	xor    $0x1f,%edi
  8030dd:	75 4d                	jne    80312c <__udivdi3+0xa8>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8030df:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8030e2:	77 0a                	ja     8030ee <__udivdi3+0x6a>
  8030e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
		}
	      else
		q0 = 0;
  8030e7:	31 ff                	xor    %edi,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8030e9:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  8030ec:	72 d2                	jb     8030c0 <__udivdi3+0x3c>
		{
		  q0 = 1;
  8030ee:	bf 01 00 00 00       	mov    $0x1,%edi
  8030f3:	eb cb                	jmp    8030c0 <__udivdi3+0x3c>
  8030f5:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8030f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8030fb:	85 c0                	test   %eax,%eax
  8030fd:	75 0e                	jne    80310d <__udivdi3+0x89>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8030ff:	b8 01 00 00 00       	mov    $0x1,%eax
  803104:	31 c9                	xor    %ecx,%ecx
  803106:	31 d2                	xor    %edx,%edx
  803108:	f7 f1                	div    %ecx
  80310a:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80310d:	89 f0                	mov    %esi,%eax
  80310f:	31 d2                	xor    %edx,%edx
  803111:	f7 75 e4             	divl   -0x1c(%ebp)
  803114:	89 45 ec             	mov    %eax,-0x14(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  803117:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80311a:	f7 75 e4             	divl   -0x1c(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80311d:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  803120:	83 c4 14             	add    $0x14,%esp

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  803123:	89 c7                	mov    %eax,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  803125:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  803126:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  803128:	5f                   	pop    %edi
  803129:	c9                   	leave  
  80312a:	c3                   	ret    
  80312b:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80312c:	b8 20 00 00 00       	mov    $0x20,%eax
  803131:	29 f8                	sub    %edi,%eax
  803133:	89 45 e8             	mov    %eax,-0x18(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  803136:	89 f9                	mov    %edi,%ecx
  803138:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80313b:	d3 e2                	shl    %cl,%edx
  80313d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803140:	8a 4d e8             	mov    -0x18(%ebp),%cl
  803143:	d3 e8                	shr    %cl,%eax
  803145:	09 c2                	or     %eax,%edx
	      d0 = d0 << bm;
  803147:	89 f9                	mov    %edi,%ecx
  803149:	d3 65 e4             	shll   %cl,-0x1c(%ebp)
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80314c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80314f:	8a 4d e8             	mov    -0x18(%ebp),%cl
  803152:	89 f2                	mov    %esi,%edx
  803154:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  803156:	89 f9                	mov    %edi,%ecx
  803158:	d3 e6                	shl    %cl,%esi
  80315a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80315d:	8a 4d e8             	mov    -0x18(%ebp),%cl
  803160:	d3 e8                	shr    %cl,%eax
  803162:	09 c6                	or     %eax,%esi
	      n0 = n0 << bm;
  803164:	89 f9                	mov    %edi,%ecx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  803166:	89 f0                	mov    %esi,%eax
  803168:	f7 75 f4             	divl   -0xc(%ebp)
  80316b:	89 d6                	mov    %edx,%esi
  80316d:	89 c7                	mov    %eax,%edi

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  80316f:	d3 65 f0             	shll   %cl,-0x10(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  803172:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803175:	f7 e7                	mul    %edi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  803177:	39 f2                	cmp    %esi,%edx
  803179:	77 0f                	ja     80318a <__udivdi3+0x106>
  80317b:	0f 85 3f ff ff ff    	jne    8030c0 <__udivdi3+0x3c>
  803181:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  803184:	0f 86 36 ff ff ff    	jbe    8030c0 <__udivdi3+0x3c>
		{
		  q0--;
  80318a:	4f                   	dec    %edi
  80318b:	e9 30 ff ff ff       	jmp    8030c0 <__udivdi3+0x3c>

00803190 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  803190:	55                   	push   %ebp
  803191:	89 e5                	mov    %esp,%ebp
  803193:	57                   	push   %edi
  803194:	56                   	push   %esi
  803195:	83 ec 30             	sub    $0x30,%esp
  803198:	8b 55 14             	mov    0x14(%ebp),%edx
  80319b:	8b 45 10             	mov    0x10(%ebp),%eax
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  80319e:	89 d7                	mov    %edx,%edi
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  8031a0:	8d 4d f0             	lea    -0x10(%ebp),%ecx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  8031a3:	89 c6                	mov    %eax,%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;
  8031a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8031a8:	8b 45 08             	mov    0x8(%ebp),%eax
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8031ab:	85 ff                	test   %edi,%edi
  8031ad:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8031b4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  8031bb:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8031be:	89 45 dc             	mov    %eax,-0x24(%ebp)
  n1 = nn.s.high;
  8031c1:	89 55 cc             	mov    %edx,-0x34(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8031c4:	75 3e                	jne    803204 <__umoddi3+0x74>
    {
      if (d0 > n1)
  8031c6:	39 d6                	cmp    %edx,%esi
  8031c8:	0f 86 a2 00 00 00    	jbe    803270 <__umoddi3+0xe0>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8031ce:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  8031d0:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  8031d3:	85 c9                	test   %ecx,%ecx

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8031d5:	89 55 dc             	mov    %edx,-0x24(%ebp)

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  8031d8:	74 1b                	je     8031f5 <__umoddi3+0x65>
	{
	  rr.s.low = n0;
  8031da:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8031dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
	  rr.s.high = 0;
  8031e0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8031e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8031ea:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8031ed:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8031f0:	89 10                	mov    %edx,(%eax)
  8031f2:	89 48 04             	mov    %ecx,0x4(%eax)
  8031f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8031f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8031fb:	83 c4 30             	add    $0x30,%esp
  8031fe:	5e                   	pop    %esi
  8031ff:	5f                   	pop    %edi
  803200:	c9                   	leave  
  803201:	c3                   	ret    
  803202:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  803204:	3b 7d cc             	cmp    -0x34(%ebp),%edi
  803207:	76 1f                	jbe    803228 <__umoddi3+0x98>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  803209:	8b 55 08             	mov    0x8(%ebp),%edx
	      rr.s.high = n1;
  80320c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  80320f:	89 55 e0             	mov    %edx,-0x20(%ebp)
	      rr.s.high = n1;
  803212:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	      *rp = rr.ll;
  803215:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803218:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80321b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80321e:	89 55 f4             	mov    %edx,-0xc(%ebp)
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  803221:	83 c4 30             	add    $0x30,%esp
  803224:	5e                   	pop    %esi
  803225:	5f                   	pop    %edi
  803226:	c9                   	leave  
  803227:	c3                   	ret    
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  803228:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  80322b:	83 f0 1f             	xor    $0x1f,%eax
  80322e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  803231:	75 61                	jne    803294 <__umoddi3+0x104>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  803233:	39 7d cc             	cmp    %edi,-0x34(%ebp)
  803236:	77 05                	ja     80323d <__umoddi3+0xad>
  803238:	39 75 dc             	cmp    %esi,-0x24(%ebp)
  80323b:	72 10                	jb     80324d <__umoddi3+0xbd>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80323d:	8b 55 cc             	mov    -0x34(%ebp),%edx
  803240:	8b 45 dc             	mov    -0x24(%ebp),%eax
  803243:	29 f0                	sub    %esi,%eax
  803245:	19 fa                	sbb    %edi,%edx
  803247:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80324a:	89 55 cc             	mov    %edx,-0x34(%ebp)
	      else
		q0 = 0;

	      q1 = 0;

	      if (rp != 0)
  80324d:	8b 55 ec             	mov    -0x14(%ebp),%edx
  803250:	85 d2                	test   %edx,%edx
  803252:	74 a1                	je     8031f5 <__umoddi3+0x65>
		{
		  rr.s.low = n0;
  803254:	8b 45 dc             	mov    -0x24(%ebp),%eax
		  rr.s.high = n1;
  803257:	8b 55 cc             	mov    -0x34(%ebp),%edx

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  80325a:	89 45 e0             	mov    %eax,-0x20(%ebp)
		  rr.s.high = n1;
  80325d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		  *rp = rr.ll;
  803260:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  803263:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803266:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  803269:	89 01                	mov    %eax,(%ecx)
  80326b:	89 51 04             	mov    %edx,0x4(%ecx)
  80326e:	eb 85                	jmp    8031f5 <__umoddi3+0x65>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  803270:	85 f6                	test   %esi,%esi
  803272:	75 0b                	jne    80327f <__umoddi3+0xef>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  803274:	b8 01 00 00 00       	mov    $0x1,%eax
  803279:	31 d2                	xor    %edx,%edx
  80327b:	f7 f6                	div    %esi
  80327d:	89 c6                	mov    %eax,%esi

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80327f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  803282:	89 fa                	mov    %edi,%edx
  803284:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  803286:	8b 45 dc             	mov    -0x24(%ebp),%eax
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  803289:	89 55 cc             	mov    %edx,-0x34(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80328c:	f7 f6                	div    %esi
  80328e:	e9 3d ff ff ff       	jmp    8031d0 <__umoddi3+0x40>
  803293:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  803294:	b8 20 00 00 00       	mov    $0x20,%eax
  803299:	2b 45 d4             	sub    -0x2c(%ebp),%eax
  80329c:	89 45 d8             	mov    %eax,-0x28(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  80329f:	89 fa                	mov    %edi,%edx
  8032a1:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  8032a4:	d3 e2                	shl    %cl,%edx
  8032a6:	89 f0                	mov    %esi,%eax
  8032a8:	8a 4d d8             	mov    -0x28(%ebp),%cl
  8032ab:	d3 e8                	shr    %cl,%eax
	      d0 = d0 << bm;
  8032ad:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  8032b0:	d3 e6                	shl    %cl,%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8032b2:	89 d7                	mov    %edx,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8032b4:	8a 4d d8             	mov    -0x28(%ebp),%cl
  8032b7:	8b 55 cc             	mov    -0x34(%ebp),%edx
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8032ba:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8032bc:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  8032be:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8032c1:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  8032c4:	d3 e0                	shl    %cl,%eax
  8032c6:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8032c9:	8a 4d d8             	mov    -0x28(%ebp),%cl
  8032cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8032cf:	d3 e8                	shr    %cl,%eax
  8032d1:	0b 45 cc             	or     -0x34(%ebp),%eax
  8032d4:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n0 = n0 << bm;
  8032d7:	8a 4d d4             	mov    -0x2c(%ebp),%cl

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8032da:	f7 f7                	div    %edi
  8032dc:	89 55 cc             	mov    %edx,-0x34(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8032df:	d3 65 dc             	shll   %cl,-0x24(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  8032e2:	f7 e6                	mul    %esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8032e4:	3b 55 cc             	cmp    -0x34(%ebp),%edx
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  8032e7:	89 45 c8             	mov    %eax,-0x38(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8032ea:	77 0a                	ja     8032f6 <__umoddi3+0x166>
  8032ec:	75 12                	jne    803300 <__umoddi3+0x170>
  8032ee:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8032f1:	39 45 c8             	cmp    %eax,-0x38(%ebp)
  8032f4:	76 0a                	jbe    803300 <__umoddi3+0x170>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8032f6:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8032f9:	29 f1                	sub    %esi,%ecx
  8032fb:	19 fa                	sbb    %edi,%edx
  8032fd:	89 4d c8             	mov    %ecx,-0x38(%ebp)
		}

	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
  803300:	8b 45 ec             	mov    -0x14(%ebp),%eax
  803303:	85 c0                	test   %eax,%eax
  803305:	0f 84 ea fe ff ff    	je     8031f5 <__umoddi3+0x65>
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80330b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80330e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  803311:	2b 45 c8             	sub    -0x38(%ebp),%eax
  803314:	19 d1                	sbb    %edx,%ecx
  803316:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  803319:	89 ca                	mov    %ecx,%edx
  80331b:	8a 4d d8             	mov    -0x28(%ebp),%cl
  80331e:	d3 e2                	shl    %cl,%edx
  803320:	8a 4d d4             	mov    -0x2c(%ebp),%cl
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  803323:	89 45 dc             	mov    %eax,-0x24(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  803326:	d3 e8                	shr    %cl,%eax
  803328:	09 c2                	or     %eax,%edx
		  rr.s.high = n1 >> bm;
  80332a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80332d:	d3 e8                	shr    %cl,%eax

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80332f:	89 55 e0             	mov    %edx,-0x20(%ebp)
		  rr.s.high = n1 >> bm;
  803332:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  803335:	e9 ad fe ff ff       	jmp    8031e7 <__umoddi3+0x57>
