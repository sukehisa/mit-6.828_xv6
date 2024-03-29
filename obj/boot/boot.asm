
obj/boot/boot.out:     file format elf32-i386


Disassembly of section .text:

00007c00 <start>:
.set CR0_PE_ON,      0x1         # protected mode enable flag

.globl start
start:
  .code16                     # Assemble for 16-bit mode
  cli                         # Disable interrupts
    7c00:	fa                   	cli    
  cld                         # String operations increment
    7c01:	fc                   	cld    

  # Set up the important data segment registers (DS, ES, SS).
  xorw    %ax,%ax             # Segment number zero
    7c02:	31 c0                	xor    %eax,%eax
  movw    %ax,%ds             # -> Data Segment
    7c04:	8e d8                	mov    %eax,%ds
  movw    %ax,%es             # -> Extra Segment
    7c06:	8e c0                	mov    %eax,%es
  movw    %ax,%ss             # -> Stack Segment
    7c08:	8e d0                	mov    %eax,%ss

00007c0a <seta20.1>:
  # Enable A20:
  #   For backwards compatibility with the earliest PCs, physical
  #   address line 20 is tied low, so that addresses higher than
  #   1MB wrap around to zero by default.  This code undoes this.
seta20.1:
  inb     $0x64,%al               # Wait for not busy
    7c0a:	e4 64                	in     $0x64,%al
  testb   $0x2,%al
    7c0c:	a8 02                	test   $0x2,%al
  jnz     seta20.1
    7c0e:	75 fa                	jne    7c0a <seta20.1>

  movb    $0xd1,%al               # 0xd1 -> port 0x64
    7c10:	b0 d1                	mov    $0xd1,%al
  outb    %al,$0x64
    7c12:	e6 64                	out    %al,$0x64

00007c14 <seta20.2>:

seta20.2:
  inb     $0x64,%al               # Wait for not busy
    7c14:	e4 64                	in     $0x64,%al
  testb   $0x2,%al
    7c16:	a8 02                	test   $0x2,%al
  jnz     seta20.2
    7c18:	75 fa                	jne    7c14 <seta20.2>

  movb    $0xdf,%al               # 0xdf -> port 0x60
    7c1a:	b0 df                	mov    $0xdf,%al
  outb    %al,$0x60
    7c1c:	e6 60                	out    %al,$0x60

  # Switch from real to protected mode, using a bootstrap GDT
  # and segment translation that makes virtual addresses 
  # identical to their physical addresses, so that the 
  # effective memory map does not change during the switch.
  lgdt    gdtdesc
    7c1e:	0f 01 16             	lgdtl  (%esi)
    7c21:	64                   	fs
    7c22:	7c 0f                	jl     7c33 <protcseg+0x1>
  movl    %cr0, %eax
    7c24:	20 c0                	and    %al,%al
  orl     $CR0_PE_ON, %eax
    7c26:	66 83 c8 01          	or     $0x1,%ax
  movl    %eax, %cr0
    7c2a:	0f 22 c0             	mov    %eax,%cr0
  
  # Jump to next instruction, but in 32-bit code segment.
  # Switches processor into 32-bit mode.
  ljmp    $PROT_MODE_CSEG, $protcseg
    7c2d:	ea 32 7c 08 00 66 b8 	ljmp   $0xb866,$0x87c32

00007c32 <protcseg>:

  .code32                     # Assemble for 32-bit mode
protcseg:
  # Set up the protected-mode data segment registers
  movw    $PROT_MODE_DSEG, %ax    # Our data segment selector
    7c32:	66 b8 10 00          	mov    $0x10,%ax
  movw    %ax, %ds                # -> DS: Data Segment
    7c36:	8e d8                	mov    %eax,%ds
  movw    %ax, %es                # -> ES: Extra Segment
    7c38:	8e c0                	mov    %eax,%es
  movw    %ax, %fs                # -> FS
    7c3a:	8e e0                	mov    %eax,%fs
  movw    %ax, %gs                # -> GS
    7c3c:	8e e8                	mov    %eax,%gs
  movw    %ax, %ss                # -> SS: Stack Segment
    7c3e:	8e d0                	mov    %eax,%ss
  
  # Set up the stack pointer and call into C.
  movl    $start, %esp
    7c40:	bc 00 7c 00 00       	mov    $0x7c00,%esp
  call bootmain
    7c45:	e8 c5 00 00 00       	call   7d0f <bootmain>

00007c4a <spin>:

  # If bootmain returns (it shouldn't), loop.
spin:
  jmp spin
    7c4a:	eb fe                	jmp    7c4a <spin>

00007c4c <gdt>:
	...
    7c54:	ff                   	(bad)  
    7c55:	ff 00                	incl   (%eax)
    7c57:	00 00                	add    %al,(%eax)
    7c59:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
    7c60:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

00007c64 <gdtdesc>:
    7c64:	17                   	pop    %ss
    7c65:	00 4c 7c 00          	add    %cl,0x0(%esp,%edi,2)
    7c69:	00 90 90 55 89 e5    	add    %dl,-0x1a76aa70(%eax)

00007c6c <waitdisk>:
	}
}

void
waitdisk(void)
{
    7c6c:	55                   	push   %ebp
    7c6d:	89 e5                	mov    %esp,%ebp
	__asm __volatile("int3");
}

static __inline uint8_t
inb(int port)
{
    7c6f:	ba f7 01 00 00       	mov    $0x1f7,%edx
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
    7c74:	ec                   	in     (%dx),%al
	__asm __volatile("int3");
}

static __inline uint8_t
inb(int port)
{
    7c75:	25 c0 00 00 00       	and    $0xc0,%eax
    7c7a:	83 f8 40             	cmp    $0x40,%eax
    7c7d:	75 f0                	jne    7c6f <waitdisk+0x3>
    7c7f:	c9                   	leave  
    7c80:	c3                   	ret    

00007c81 <readsect>:
		/* do nothing */;
}

void
readsect(void *dst, uint32_t offset)
{
    7c81:	55                   	push   %ebp
    7c82:	89 e5                	mov    %esp,%ebp
    7c84:	57                   	push   %edi
    7c85:	53                   	push   %ebx
    7c86:	8b 7d 08             	mov    0x8(%ebp),%edi
    7c89:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// wait for disk to be ready
	waitdisk();
    7c8c:	e8 db ff ff ff       	call   7c6c <waitdisk>
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
    7c91:	ba f2 01 00 00       	mov    $0x1f2,%edx
    7c96:	b0 01                	mov    $0x1,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
    7c98:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
    7c99:	b2 f3                	mov    $0xf3,%dl
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
    7c9b:	88 d8                	mov    %bl,%al
    7c9d:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
    7c9e:	89 d8                	mov    %ebx,%eax
    7ca0:	b2 f4                	mov    $0xf4,%dl
    7ca2:	c1 e8 08             	shr    $0x8,%eax
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
    7ca5:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
    7ca6:	89 d8                	mov    %ebx,%eax
    7ca8:	b2 f5                	mov    $0xf5,%dl
    7caa:	c1 e8 10             	shr    $0x10,%eax
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
    7cad:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
    7cae:	c1 eb 18             	shr    $0x18,%ebx
    7cb1:	83 cb e0             	or     $0xffffffe0,%ebx
    7cb4:	b2 f6                	mov    $0xf6,%dl
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
    7cb6:	88 d8                	mov    %bl,%al
    7cb8:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
    7cb9:	b0 20                	mov    $0x20,%al
    7cbb:	b2 f7                	mov    $0xf7,%dl
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
    7cbd:	ee                   	out    %al,(%dx)
	outb(0x1F5, offset >> 16);
	outb(0x1F6, (offset >> 24) | 0xE0);
	outb(0x1F7, 0x20);	// cmd 0x20 - read sectors

	// wait for disk to be ready
	waitdisk();
    7cbe:	e8 a9 ff ff ff       	call   7c6c <waitdisk>
	return data;
}

static __inline void
insl(int port, void *addr, int cnt)
{
    7cc3:	ba f0 01 00 00       	mov    $0x1f0,%edx
    7cc8:	b9 80 00 00 00       	mov    $0x80,%ecx
	__asm __volatile("cld\n\trepne\n\tinsl"			:
    7ccd:	fc                   	cld    
    7cce:	f2 6d                	repnz insl (%dx),%es:(%edi)
    7cd0:	5b                   	pop    %ebx
    7cd1:	5f                   	pop    %edi
    7cd2:	c9                   	leave  
    7cd3:	c3                   	ret    

00007cd4 <readseg>:

// Read 'count' bytes at 'offset' from kernel into physical address 'pa'.
// Might copy more than asked
void
readseg(uint32_t pa, uint32_t count, uint32_t offset)
{
    7cd4:	55                   	push   %ebp
    7cd5:	89 e5                	mov    %esp,%ebp
    7cd7:	57                   	push   %edi
    7cd8:	56                   	push   %esi
    7cd9:	53                   	push   %ebx
    7cda:	8b 45 10             	mov    0x10(%ebp),%eax
    7cdd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t end_pa;

	end_pa = pa + count;
    7ce0:	89 df                	mov    %ebx,%edi
	
	// round down to sector boundary
	pa &= ~(SECTSIZE - 1);

	// translate from bytes to sectors, and kernel starts at sector 1
	offset = (offset / SECTSIZE) + 1;
    7ce2:	c1 e8 09             	shr    $0x9,%eax
void
readseg(uint32_t pa, uint32_t count, uint32_t offset)
{
	uint32_t end_pa;

	end_pa = pa + count;
    7ce5:	03 7d 0c             	add    0xc(%ebp),%edi
	
	// round down to sector boundary
	pa &= ~(SECTSIZE - 1);
    7ce8:	81 e3 00 fe ff ff    	and    $0xfffffe00,%ebx

	// translate from bytes to sectors, and kernel starts at sector 1
	offset = (offset / SECTSIZE) + 1;
    7cee:	8d 70 01             	lea    0x1(%eax),%esi
		// an identity segment mapping (see boot.S), we can
		// use physical addresses directly.  This won't be the
		// case once JOS enables the MMU.
		readsect((uint8_t*) pa, offset);
		pa += SECTSIZE;
		offset++;
    7cf1:	39 fb                	cmp    %edi,%ebx
    7cf3:	73 12                	jae    7d07 <readseg+0x33>
	while (pa < end_pa) {
		// Since we haven't enabled paging yet and we're using
		// an identity segment mapping (see boot.S), we can
		// use physical addresses directly.  This won't be the
		// case once JOS enables the MMU.
		readsect((uint8_t*) pa, offset);
    7cf5:	56                   	push   %esi
    7cf6:	53                   	push   %ebx
    7cf7:	e8 85 ff ff ff       	call   7c81 <readsect>
		pa += SECTSIZE;
		offset++;
    7cfc:	58                   	pop    %eax
		// Since we haven't enabled paging yet and we're using
		// an identity segment mapping (see boot.S), we can
		// use physical addresses directly.  This won't be the
		// case once JOS enables the MMU.
		readsect((uint8_t*) pa, offset);
		pa += SECTSIZE;
    7cfd:	81 c3 00 02 00 00    	add    $0x200,%ebx
		offset++;
    7d03:	46                   	inc    %esi
    7d04:	5a                   	pop    %edx
    7d05:	eb ea                	jmp    7cf1 <readseg+0x1d>
    7d07:	8d 65 f4             	lea    -0xc(%ebp),%esp
    7d0a:	5b                   	pop    %ebx
    7d0b:	5e                   	pop    %esi
    7d0c:	5f                   	pop    %edi
    7d0d:	c9                   	leave  
    7d0e:	c3                   	ret    

00007d0f <bootmain>:
void readsect(void*, uint32_t);
void readseg(uint32_t, uint32_t, uint32_t);

void
bootmain(void)
{
    7d0f:	55                   	push   %ebp
    7d10:	89 e5                	mov    %esp,%ebp
    7d12:	56                   	push   %esi
    7d13:	53                   	push   %ebx
	struct Proghdr *ph, *eph;

	// read 1st page off disk
	readseg((uint32_t) ELFHDR, SECTSIZE*8, 0);
    7d14:	6a 00                	push   $0x0
    7d16:	68 00 10 00 00       	push   $0x1000
    7d1b:	68 00 00 01 00       	push   $0x10000
    7d20:	e8 af ff ff ff       	call   7cd4 <readseg>

	// is this a valid ELF?
	if (ELFHDR->e_magic != ELF_MAGIC)
    7d25:	83 c4 0c             	add    $0xc,%esp
    7d28:	81 3d 00 00 01 00 7f 	cmpl   $0x464c457f,0x10000
    7d2f:	45 4c 46 
    7d32:	75 39                	jne    7d6d <bootmain+0x5e>
		goto bad;

	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
    7d34:	8b 1d 1c 00 01 00    	mov    0x1001c,%ebx
	eph = ph + ELFHDR->e_phnum;
    7d3a:	0f b7 05 2c 00 01 00 	movzwl 0x1002c,%eax
	// is this a valid ELF?
	if (ELFHDR->e_magic != ELF_MAGIC)
		goto bad;

	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
    7d41:	81 c3 00 00 01 00    	add    $0x10000,%ebx
	eph = ph + ELFHDR->e_phnum;
    7d47:	c1 e0 05             	shl    $0x5,%eax
    7d4a:	8d 34 03             	lea    (%ebx,%eax,1),%esi
	for (; ph < eph; ph++)
    7d4d:	39 f3                	cmp    %esi,%ebx
    7d4f:	73 16                	jae    7d67 <bootmain+0x58>
		// p_pa is the load address of this segment (as well
		// as the physical address)
		readseg(ph->p_pa, ph->p_memsz, ph->p_offset);
    7d51:	ff 73 04             	pushl  0x4(%ebx)
    7d54:	ff 73 14             	pushl  0x14(%ebx)
    7d57:	ff 73 0c             	pushl  0xc(%ebx)
    7d5a:	e8 75 ff ff ff       	call   7cd4 <readseg>
		goto bad;

	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
	eph = ph + ELFHDR->e_phnum;
	for (; ph < eph; ph++)
    7d5f:	83 c3 20             	add    $0x20,%ebx
    7d62:	83 c4 0c             	add    $0xc,%esp
    7d65:	eb e6                	jmp    7d4d <bootmain+0x3e>
		// as the physical address)
		readseg(ph->p_pa, ph->p_memsz, ph->p_offset);

	// call the entry point from the ELF header
	// note: does not return!
	((void (*)(void)) (ELFHDR->e_entry))();
    7d67:	ff 15 18 00 01 00    	call   *0x10018
			 "cc");
}

static __inline void
outw(int port, uint16_t data)
{
    7d6d:	ba 00 8a 00 00       	mov    $0x8a00,%edx
    7d72:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
	__asm __volatile("outw %0,%w1" : : "a" (data), "d" (port));
    7d77:	66 ef                	out    %ax,(%dx)
			 "cc");
}

static __inline void
outw(int port, uint16_t data)
{
    7d79:	b8 00 8e ff ff       	mov    $0xffff8e00,%eax
	__asm __volatile("outw %0,%w1" : : "a" (data), "d" (port));
    7d7e:	66 ef                	out    %ax,(%dx)

bad:
	outw(0x8A00, 0x8A00);
	outw(0x8A00, 0x8E00);
	while (1)
    7d80:	eb fe                	jmp    7d80 <bootmain+0x71>
