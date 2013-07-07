
obj/user/badsegment.debug:     file format elf32-i386


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
  80002c:	e8 0f 00 00 00       	call   800040 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800037:	66 b8 28 00          	mov    $0x28,%ax
  80003b:	8e d8                	mov    %eax,%ds
}
  80003d:	c9                   	leave  
  80003e:	c3                   	ret    
	...

00800040 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	8b 75 08             	mov    0x8(%ebp),%esi
  800048:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];	
  80004b:	e8 d0 00 00 00       	call   800120 <sys_getenvid>
  800050:	25 ff 03 00 00       	and    $0x3ff,%eax
  800055:	89 c2                	mov    %eax,%edx
  800057:	c1 e2 05             	shl    $0x5,%edx
  80005a:	29 c2                	sub    %eax,%edx
  80005c:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  800063:	89 15 04 20 80 00    	mov    %edx,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 f6                	test   %esi,%esi
  80006b:	7e 07                	jle    800074 <libmain+0x34>
		binaryname = argv[0];
  80006d:	8b 03                	mov    (%ebx),%eax
  80006f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800074:	83 ec 08             	sub    $0x8,%esp
  800077:	53                   	push   %ebx
  800078:	56                   	push   %esi
  800079:	e8 b6 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80007e:	e8 09 00 00 00       	call   80008c <exit>
}
  800083:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800086:	5b                   	pop    %ebx
  800087:	5e                   	pop    %esi
  800088:	c9                   	leave  
  800089:	c3                   	ret    
	...

0080008c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  800092:	6a 00                	push   $0x0
  800094:	e8 46 00 00 00       	call   8000df <sys_env_destroy>
}
  800099:	c9                   	leave  
  80009a:	c3                   	ret    
	...

0080009c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	57                   	push   %edi
  8000a0:	56                   	push   %esi
  8000a1:	53                   	push   %ebx
  8000a2:	83 ec 04             	sub    $0x4,%esp
  8000a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000ab:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b0:	89 f8                	mov    %edi,%eax
  8000b2:	89 fb                	mov    %edi,%ebx
  8000b4:	89 fe                	mov    %edi,%esi
  8000b6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b8:	83 c4 04             	add    $0x4,%esp
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5f                   	pop    %edi
  8000be:	c9                   	leave  
  8000bf:	c3                   	ret    

008000c0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cb:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d0:	89 fa                	mov    %edi,%edx
  8000d2:	89 f9                	mov    %edi,%ecx
  8000d4:	89 fb                	mov    %edi,%ebx
  8000d6:	89 fe                	mov    %edi,%esi
  8000d8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000da:	5b                   	pop    %ebx
  8000db:	5e                   	pop    %esi
  8000dc:	5f                   	pop    %edi
  8000dd:	c9                   	leave  
  8000de:	c3                   	ret    

008000df <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	57                   	push   %edi
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	83 ec 0c             	sub    $0xc,%esp
  8000e8:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000eb:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f0:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f5:	89 f9                	mov    %edi,%ecx
  8000f7:	89 fb                	mov    %edi,%ebx
  8000f9:	89 fe                	mov    %edi,%esi
  8000fb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000fd:	85 c0                	test   %eax,%eax
  8000ff:	7e 17                	jle    800118 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800101:	83 ec 0c             	sub    $0xc,%esp
  800104:	50                   	push   %eax
  800105:	6a 03                	push   $0x3
  800107:	68 2a 0f 80 00       	push   $0x800f2a
  80010c:	6a 23                	push   $0x23
  80010e:	68 47 0f 80 00       	push   $0x800f47
  800113:	e8 38 02 00 00       	call   800350 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800118:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011b:	5b                   	pop    %ebx
  80011c:	5e                   	pop    %esi
  80011d:	5f                   	pop    %edi
  80011e:	c9                   	leave  
  80011f:	c3                   	ret    

00800120 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	57                   	push   %edi
  800124:	56                   	push   %esi
  800125:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800126:	b8 02 00 00 00       	mov    $0x2,%eax
  80012b:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800130:	89 fa                	mov    %edi,%edx
  800132:	89 f9                	mov    %edi,%ecx
  800134:	89 fb                	mov    %edi,%ebx
  800136:	89 fe                	mov    %edi,%esi
  800138:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5f                   	pop    %edi
  80013d:	c9                   	leave  
  80013e:	c3                   	ret    

0080013f <sys_yield>:

void
sys_yield(void)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	57                   	push   %edi
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800145:	b8 0b 00 00 00       	mov    $0xb,%eax
  80014a:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014f:	89 fa                	mov    %edi,%edx
  800151:	89 f9                	mov    %edi,%ecx
  800153:	89 fb                	mov    %edi,%ebx
  800155:	89 fe                	mov    %edi,%esi
  800157:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800159:	5b                   	pop    %ebx
  80015a:	5e                   	pop    %esi
  80015b:	5f                   	pop    %edi
  80015c:	c9                   	leave  
  80015d:	c3                   	ret    

0080015e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	57                   	push   %edi
  800162:	56                   	push   %esi
  800163:	53                   	push   %ebx
  800164:	83 ec 0c             	sub    $0xc,%esp
  800167:	8b 55 08             	mov    0x8(%ebp),%edx
  80016a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016d:	8b 5d 10             	mov    0x10(%ebp),%ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800170:	b8 04 00 00 00       	mov    $0x4,%eax
  800175:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80017a:	89 fe                	mov    %edi,%esi
  80017c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80017e:	85 c0                	test   %eax,%eax
  800180:	7e 17                	jle    800199 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800182:	83 ec 0c             	sub    $0xc,%esp
  800185:	50                   	push   %eax
  800186:	6a 04                	push   $0x4
  800188:	68 2a 0f 80 00       	push   $0x800f2a
  80018d:	6a 23                	push   $0x23
  80018f:	68 47 0f 80 00       	push   $0x800f47
  800194:	e8 b7 01 00 00       	call   800350 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800199:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80019c:	5b                   	pop    %ebx
  80019d:	5e                   	pop    %esi
  80019e:	5f                   	pop    %edi
  80019f:	c9                   	leave  
  8001a0:	c3                   	ret    

008001a1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	57                   	push   %edi
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 0c             	sub    $0xc,%esp
  8001aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b6:	8b 75 18             	mov    0x18(%ebp),%esi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8001b9:	b8 05 00 00 00       	mov    $0x5,%eax
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001be:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001c0:	85 c0                	test   %eax,%eax
  8001c2:	7e 17                	jle    8001db <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c4:	83 ec 0c             	sub    $0xc,%esp
  8001c7:	50                   	push   %eax
  8001c8:	6a 05                	push   $0x5
  8001ca:	68 2a 0f 80 00       	push   $0x800f2a
  8001cf:	6a 23                	push   $0x23
  8001d1:	68 47 0f 80 00       	push   $0x800f47
  8001d6:	e8 75 01 00 00       	call   800350 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001de:	5b                   	pop    %ebx
  8001df:	5e                   	pop    %esi
  8001e0:	5f                   	pop    %edi
  8001e1:	c9                   	leave  
  8001e2:	c3                   	ret    

008001e3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	57                   	push   %edi
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8001f2:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f7:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001fc:	89 fb                	mov    %edi,%ebx
  8001fe:	89 fe                	mov    %edi,%esi
  800200:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800202:	85 c0                	test   %eax,%eax
  800204:	7e 17                	jle    80021d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800206:	83 ec 0c             	sub    $0xc,%esp
  800209:	50                   	push   %eax
  80020a:	6a 06                	push   $0x6
  80020c:	68 2a 0f 80 00       	push   $0x800f2a
  800211:	6a 23                	push   $0x23
  800213:	68 47 0f 80 00       	push   $0x800f47
  800218:	e8 33 01 00 00       	call   800350 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80021d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800220:	5b                   	pop    %ebx
  800221:	5e                   	pop    %esi
  800222:	5f                   	pop    %edi
  800223:	c9                   	leave  
  800224:	c3                   	ret    

00800225 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	57                   	push   %edi
  800229:	56                   	push   %esi
  80022a:	53                   	push   %ebx
  80022b:	83 ec 0c             	sub    $0xc,%esp
  80022e:	8b 55 08             	mov    0x8(%ebp),%edx
  800231:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800234:	b8 08 00 00 00       	mov    $0x8,%eax
  800239:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80023e:	89 fb                	mov    %edi,%ebx
  800240:	89 fe                	mov    %edi,%esi
  800242:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800244:	85 c0                	test   %eax,%eax
  800246:	7e 17                	jle    80025f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800248:	83 ec 0c             	sub    $0xc,%esp
  80024b:	50                   	push   %eax
  80024c:	6a 08                	push   $0x8
  80024e:	68 2a 0f 80 00       	push   $0x800f2a
  800253:	6a 23                	push   $0x23
  800255:	68 47 0f 80 00       	push   $0x800f47
  80025a:	e8 f1 00 00 00       	call   800350 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800262:	5b                   	pop    %ebx
  800263:	5e                   	pop    %esi
  800264:	5f                   	pop    %edi
  800265:	c9                   	leave  
  800266:	c3                   	ret    

00800267 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	57                   	push   %edi
  80026b:	56                   	push   %esi
  80026c:	53                   	push   %ebx
  80026d:	83 ec 0c             	sub    $0xc,%esp
  800270:	8b 55 08             	mov    0x8(%ebp),%edx
  800273:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800276:	b8 09 00 00 00       	mov    $0x9,%eax
  80027b:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800280:	89 fb                	mov    %edi,%ebx
  800282:	89 fe                	mov    %edi,%esi
  800284:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800286:	85 c0                	test   %eax,%eax
  800288:	7e 17                	jle    8002a1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028a:	83 ec 0c             	sub    $0xc,%esp
  80028d:	50                   	push   %eax
  80028e:	6a 09                	push   $0x9
  800290:	68 2a 0f 80 00       	push   $0x800f2a
  800295:	6a 23                	push   $0x23
  800297:	68 47 0f 80 00       	push   $0x800f47
  80029c:	e8 af 00 00 00       	call   800350 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a4:	5b                   	pop    %ebx
  8002a5:	5e                   	pop    %esi
  8002a6:	5f                   	pop    %edi
  8002a7:	c9                   	leave  
  8002a8:	c3                   	ret    

008002a9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	57                   	push   %edi
  8002ad:	56                   	push   %esi
  8002ae:	53                   	push   %ebx
  8002af:	83 ec 0c             	sub    $0xc,%esp
  8002b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8002b8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002bd:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c2:	89 fb                	mov    %edi,%ebx
  8002c4:	89 fe                	mov    %edi,%esi
  8002c6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002c8:	85 c0                	test   %eax,%eax
  8002ca:	7e 17                	jle    8002e3 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002cc:	83 ec 0c             	sub    $0xc,%esp
  8002cf:	50                   	push   %eax
  8002d0:	6a 0a                	push   $0xa
  8002d2:	68 2a 0f 80 00       	push   $0x800f2a
  8002d7:	6a 23                	push   $0x23
  8002d9:	68 47 0f 80 00       	push   $0x800f47
  8002de:	e8 6d 00 00 00       	call   800350 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e6:	5b                   	pop    %ebx
  8002e7:	5e                   	pop    %esi
  8002e8:	5f                   	pop    %edi
  8002e9:	c9                   	leave  
  8002ea:	c3                   	ret    

008002eb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	57                   	push   %edi
  8002ef:	56                   	push   %esi
  8002f0:	53                   	push   %ebx
  8002f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fa:	8b 7d 14             	mov    0x14(%ebp),%edi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8002fd:	b8 0c 00 00 00       	mov    $0xc,%eax
  800302:	be 00 00 00 00       	mov    $0x0,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800307:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5f                   	pop    %edi
  80030c:	c9                   	leave  
  80030d:	c3                   	ret    

0080030e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
  800314:	83 ec 0c             	sub    $0xc,%esp
  800317:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80031a:	b8 0d 00 00 00       	mov    $0xd,%eax
  80031f:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800324:	89 f9                	mov    %edi,%ecx
  800326:	89 fb                	mov    %edi,%ebx
  800328:	89 fe                	mov    %edi,%esi
  80032a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80032c:	85 c0                	test   %eax,%eax
  80032e:	7e 17                	jle    800347 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	50                   	push   %eax
  800334:	6a 0d                	push   $0xd
  800336:	68 2a 0f 80 00       	push   $0x800f2a
  80033b:	6a 23                	push   $0x23
  80033d:	68 47 0f 80 00       	push   $0x800f47
  800342:	e8 09 00 00 00       	call   800350 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800347:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034a:	5b                   	pop    %ebx
  80034b:	5e                   	pop    %esi
  80034c:	5f                   	pop    %edi
  80034d:	c9                   	leave  
  80034e:	c3                   	ret    
	...

00800350 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800350:	55                   	push   %ebp
  800351:	89 e5                	mov    %esp,%ebp
  800353:	53                   	push   %ebx
  800354:	83 ec 10             	sub    $0x10,%esp
	va_list ap;

	va_start(ap, fmt);
  800357:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80035a:	ff 75 0c             	pushl  0xc(%ebp)
  80035d:	ff 75 08             	pushl  0x8(%ebp)
  800360:	ff 35 00 20 80 00    	pushl  0x802000
  800366:	83 ec 08             	sub    $0x8,%esp
  800369:	e8 b2 fd ff ff       	call   800120 <sys_getenvid>
  80036e:	83 c4 08             	add    $0x8,%esp
  800371:	50                   	push   %eax
  800372:	68 58 0f 80 00       	push   $0x800f58
  800377:	e8 b0 00 00 00       	call   80042c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80037c:	83 c4 18             	add    $0x18,%esp
  80037f:	53                   	push   %ebx
  800380:	ff 75 10             	pushl  0x10(%ebp)
  800383:	e8 53 00 00 00       	call   8003db <vcprintf>
	cprintf("\n");
  800388:	c7 04 24 7b 0f 80 00 	movl   $0x800f7b,(%esp)
  80038f:	e8 98 00 00 00       	call   80042c <cprintf>

	// Cause a breakpoint exception
	while (1)
  800394:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  800397:	cc                   	int3   
  800398:	eb fd                	jmp    800397 <_panic+0x47>
	...

0080039c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80039c:	55                   	push   %ebp
  80039d:	89 e5                	mov    %esp,%ebp
  80039f:	53                   	push   %ebx
  8003a0:	83 ec 04             	sub    $0x4,%esp
  8003a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003a6:	8b 03                	mov    (%ebx),%eax
  8003a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ab:	88 54 18 08          	mov    %dl,0x8(%eax,%ebx,1)
  8003af:	40                   	inc    %eax
  8003b0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8003b2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003b7:	75 1a                	jne    8003d3 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8003b9:	83 ec 08             	sub    $0x8,%esp
  8003bc:	68 ff 00 00 00       	push   $0xff
  8003c1:	8d 43 08             	lea    0x8(%ebx),%eax
  8003c4:	50                   	push   %eax
  8003c5:	e8 d2 fc ff ff       	call   80009c <sys_cputs>
		b->idx = 0;
  8003ca:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003d0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003d3:	ff 43 04             	incl   0x4(%ebx)
}
  8003d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003d9:	c9                   	leave  
  8003da:	c3                   	ret    

008003db <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003db:	55                   	push   %ebp
  8003dc:	89 e5                	mov    %esp,%ebp
  8003de:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003e4:	c7 85 e8 fe ff ff 00 	movl   $0x0,-0x118(%ebp)
  8003eb:	00 00 00 
	b.cnt = 0;
  8003ee:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8003f5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003f8:	ff 75 0c             	pushl  0xc(%ebp)
  8003fb:	ff 75 08             	pushl  0x8(%ebp)
  8003fe:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800404:	50                   	push   %eax
  800405:	68 9c 03 80 00       	push   $0x80039c
  80040a:	e8 49 01 00 00       	call   800558 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80040f:	83 c4 08             	add    $0x8,%esp
  800412:	ff b5 e8 fe ff ff    	pushl  -0x118(%ebp)
  800418:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80041e:	50                   	push   %eax
  80041f:	e8 78 fc ff ff       	call   80009c <sys_cputs>

	return b.cnt;
  800424:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
}
  80042a:	c9                   	leave  
  80042b:	c3                   	ret    

0080042c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80042c:	55                   	push   %ebp
  80042d:	89 e5                	mov    %esp,%ebp
  80042f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800432:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800435:	50                   	push   %eax
  800436:	ff 75 08             	pushl  0x8(%ebp)
  800439:	e8 9d ff ff ff       	call   8003db <vcprintf>
	va_end(ap);

	return cnt;
}
  80043e:	c9                   	leave  
  80043f:	c3                   	ret    

00800440 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800440:	55                   	push   %ebp
  800441:	89 e5                	mov    %esp,%ebp
  800443:	57                   	push   %edi
  800444:	56                   	push   %esi
  800445:	53                   	push   %ebx
  800446:	83 ec 0c             	sub    $0xc,%esp
  800449:	8b 75 10             	mov    0x10(%ebp),%esi
  80044c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80044f:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800452:	8b 45 18             	mov    0x18(%ebp),%eax
  800455:	ba 00 00 00 00       	mov    $0x0,%edx
  80045a:	39 fa                	cmp    %edi,%edx
  80045c:	77 39                	ja     800497 <printnum+0x57>
  80045e:	72 04                	jb     800464 <printnum+0x24>
  800460:	39 f0                	cmp    %esi,%eax
  800462:	77 33                	ja     800497 <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800464:	83 ec 04             	sub    $0x4,%esp
  800467:	ff 75 20             	pushl  0x20(%ebp)
  80046a:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80046d:	50                   	push   %eax
  80046e:	ff 75 18             	pushl  0x18(%ebp)
  800471:	8b 45 18             	mov    0x18(%ebp),%eax
  800474:	ba 00 00 00 00       	mov    $0x0,%edx
  800479:	52                   	push   %edx
  80047a:	50                   	push   %eax
  80047b:	57                   	push   %edi
  80047c:	56                   	push   %esi
  80047d:	e8 de 07 00 00       	call   800c60 <__udivdi3>
  800482:	83 c4 10             	add    $0x10,%esp
  800485:	52                   	push   %edx
  800486:	50                   	push   %eax
  800487:	ff 75 0c             	pushl  0xc(%ebp)
  80048a:	ff 75 08             	pushl  0x8(%ebp)
  80048d:	e8 ae ff ff ff       	call   800440 <printnum>
  800492:	83 c4 20             	add    $0x20,%esp
  800495:	eb 19                	jmp    8004b0 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800497:	4b                   	dec    %ebx
  800498:	85 db                	test   %ebx,%ebx
  80049a:	7e 14                	jle    8004b0 <printnum+0x70>
  80049c:	83 ec 08             	sub    $0x8,%esp
  80049f:	ff 75 0c             	pushl  0xc(%ebp)
  8004a2:	ff 75 20             	pushl  0x20(%ebp)
  8004a5:	ff 55 08             	call   *0x8(%ebp)
  8004a8:	83 c4 10             	add    $0x10,%esp
  8004ab:	4b                   	dec    %ebx
  8004ac:	85 db                	test   %ebx,%ebx
  8004ae:	7f ec                	jg     80049c <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004b0:	83 ec 08             	sub    $0x8,%esp
  8004b3:	ff 75 0c             	pushl  0xc(%ebp)
  8004b6:	8b 45 18             	mov    0x18(%ebp),%eax
  8004b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004be:	83 ec 04             	sub    $0x4,%esp
  8004c1:	52                   	push   %edx
  8004c2:	50                   	push   %eax
  8004c3:	57                   	push   %edi
  8004c4:	56                   	push   %esi
  8004c5:	e8 a2 08 00 00       	call   800d6c <__umoddi3>
  8004ca:	83 c4 14             	add    $0x14,%esp
  8004cd:	0f be 80 8f 10 80 00 	movsbl 0x80108f(%eax),%eax
  8004d4:	50                   	push   %eax
  8004d5:	ff 55 08             	call   *0x8(%ebp)
}
  8004d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004db:	5b                   	pop    %ebx
  8004dc:	5e                   	pop    %esi
  8004dd:	5f                   	pop    %edi
  8004de:	c9                   	leave  
  8004df:	c3                   	ret    

008004e0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004e0:	55                   	push   %ebp
  8004e1:	89 e5                	mov    %esp,%ebp
  8004e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004e6:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  8004e9:	83 f8 01             	cmp    $0x1,%eax
  8004ec:	7e 0e                	jle    8004fc <getuint+0x1c>
		return va_arg(*ap, unsigned long long);
  8004ee:	8b 11                	mov    (%ecx),%edx
  8004f0:	8d 42 08             	lea    0x8(%edx),%eax
  8004f3:	89 01                	mov    %eax,(%ecx)
  8004f5:	8b 02                	mov    (%edx),%eax
  8004f7:	8b 52 04             	mov    0x4(%edx),%edx
  8004fa:	eb 22                	jmp    80051e <getuint+0x3e>
	else if (lflag)
  8004fc:	85 c0                	test   %eax,%eax
  8004fe:	74 10                	je     800510 <getuint+0x30>
		return va_arg(*ap, unsigned long);
  800500:	8b 11                	mov    (%ecx),%edx
  800502:	8d 42 04             	lea    0x4(%edx),%eax
  800505:	89 01                	mov    %eax,(%ecx)
  800507:	8b 02                	mov    (%edx),%eax
  800509:	ba 00 00 00 00       	mov    $0x0,%edx
  80050e:	eb 0e                	jmp    80051e <getuint+0x3e>
	else
		return va_arg(*ap, unsigned int);
  800510:	8b 11                	mov    (%ecx),%edx
  800512:	8d 42 04             	lea    0x4(%edx),%eax
  800515:	89 01                	mov    %eax,(%ecx)
  800517:	8b 02                	mov    (%edx),%eax
  800519:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80051e:	c9                   	leave  
  80051f:	c3                   	ret    

00800520 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800520:	55                   	push   %ebp
  800521:	89 e5                	mov    %esp,%ebp
  800523:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800526:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800529:	83 f8 01             	cmp    $0x1,%eax
  80052c:	7e 0e                	jle    80053c <getint+0x1c>
		return va_arg(*ap, long long);
  80052e:	8b 11                	mov    (%ecx),%edx
  800530:	8d 42 08             	lea    0x8(%edx),%eax
  800533:	89 01                	mov    %eax,(%ecx)
  800535:	8b 02                	mov    (%edx),%eax
  800537:	8b 52 04             	mov    0x4(%edx),%edx
  80053a:	eb 1a                	jmp    800556 <getint+0x36>
	else if (lflag)
  80053c:	85 c0                	test   %eax,%eax
  80053e:	74 0c                	je     80054c <getint+0x2c>
		return va_arg(*ap, long);
  800540:	8b 01                	mov    (%ecx),%eax
  800542:	8d 50 04             	lea    0x4(%eax),%edx
  800545:	89 11                	mov    %edx,(%ecx)
  800547:	8b 00                	mov    (%eax),%eax
  800549:	99                   	cltd   
  80054a:	eb 0a                	jmp    800556 <getint+0x36>
	else
		return va_arg(*ap, int);
  80054c:	8b 01                	mov    (%ecx),%eax
  80054e:	8d 50 04             	lea    0x4(%eax),%edx
  800551:	89 11                	mov    %edx,(%ecx)
  800553:	8b 00                	mov    (%eax),%eax
  800555:	99                   	cltd   
}
  800556:	c9                   	leave  
  800557:	c3                   	ret    

00800558 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800558:	55                   	push   %ebp
  800559:	89 e5                	mov    %esp,%ebp
  80055b:	57                   	push   %edi
  80055c:	56                   	push   %esi
  80055d:	53                   	push   %ebx
  80055e:	83 ec 1c             	sub    $0x1c,%esp
  800561:	8b 5d 10             	mov    0x10(%ebp),%ebx

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
			putch(ch, putdat);
  800564:	0f b6 0b             	movzbl (%ebx),%ecx
  800567:	43                   	inc    %ebx
  800568:	83 f9 25             	cmp    $0x25,%ecx
  80056b:	74 1e                	je     80058b <vprintfmt+0x33>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80056d:	85 c9                	test   %ecx,%ecx
  80056f:	0f 84 dc 02 00 00    	je     800851 <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  800575:	83 ec 08             	sub    $0x8,%esp
  800578:	ff 75 0c             	pushl  0xc(%ebp)
  80057b:	51                   	push   %ecx
  80057c:	ff 55 08             	call   *0x8(%ebp)
  80057f:	83 c4 10             	add    $0x10,%esp
  800582:	0f b6 0b             	movzbl (%ebx),%ecx
  800585:	43                   	inc    %ebx
  800586:	83 f9 25             	cmp    $0x25,%ecx
  800589:	75 e2                	jne    80056d <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  80058b:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
		width = -1;
  80058f:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
		precision = -1;
  800596:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  80059b:	bf 00 00 00 00       	mov    $0x0,%edi
		altflag = 0;
  8005a0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a7:	0f b6 0b             	movzbl (%ebx),%ecx
  8005aa:	8d 41 dd             	lea    -0x23(%ecx),%eax
  8005ad:	43                   	inc    %ebx
  8005ae:	83 f8 55             	cmp    $0x55,%eax
  8005b1:	0f 87 75 02 00 00    	ja     80082c <vprintfmt+0x2d4>
  8005b7:	ff 24 85 20 11 80 00 	jmp    *0x801120(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  8005be:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
			goto reswitch;
  8005c2:	eb e3                	jmp    8005a7 <vprintfmt+0x4f>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005c4:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
			goto reswitch;
  8005c8:	eb dd                	jmp    8005a7 <vprintfmt+0x4f>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005ca:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  8005cf:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  8005d2:	8d 74 41 d0          	lea    -0x30(%ecx,%eax,2),%esi
				ch = *fmt;
  8005d6:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  8005d9:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8005dc:	83 f8 09             	cmp    $0x9,%eax
  8005df:	77 28                	ja     800609 <vprintfmt+0xb1>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005e1:	43                   	inc    %ebx
  8005e2:	eb eb                	jmp    8005cf <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005e4:	8b 55 14             	mov    0x14(%ebp),%edx
  8005e7:	8d 42 04             	lea    0x4(%edx),%eax
  8005ea:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ed:	8b 32                	mov    (%edx),%esi
			goto process_precision;
  8005ef:	eb 18                	jmp    800609 <vprintfmt+0xb1>

		case '.':
			if (width < 0)
  8005f1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8005f5:	79 b0                	jns    8005a7 <vprintfmt+0x4f>
				width = 0;
  8005f7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
			goto reswitch;
  8005fe:	eb a7                	jmp    8005a7 <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  800600:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
			goto reswitch;
  800607:	eb 9e                	jmp    8005a7 <vprintfmt+0x4f>

		process_precision:
			if (width < 0)
  800609:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80060d:	79 98                	jns    8005a7 <vprintfmt+0x4f>
				width = precision, precision = -1;
  80060f:	89 75 f0             	mov    %esi,-0x10(%ebp)
  800612:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  800617:	eb 8e                	jmp    8005a7 <vprintfmt+0x4f>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800619:	47                   	inc    %edi
			goto reswitch;
  80061a:	eb 8b                	jmp    8005a7 <vprintfmt+0x4f>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80061c:	83 ec 08             	sub    $0x8,%esp
  80061f:	ff 75 0c             	pushl  0xc(%ebp)
  800622:	8b 55 14             	mov    0x14(%ebp),%edx
  800625:	8d 42 04             	lea    0x4(%edx),%eax
  800628:	89 45 14             	mov    %eax,0x14(%ebp)
  80062b:	ff 32                	pushl  (%edx)
  80062d:	ff 55 08             	call   *0x8(%ebp)
			break;
  800630:	83 c4 10             	add    $0x10,%esp
  800633:	e9 2c ff ff ff       	jmp    800564 <vprintfmt+0xc>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800638:	8b 55 14             	mov    0x14(%ebp),%edx
  80063b:	8d 42 04             	lea    0x4(%edx),%eax
  80063e:	89 45 14             	mov    %eax,0x14(%ebp)
  800641:	8b 02                	mov    (%edx),%eax
			if (err < 0)
  800643:	85 c0                	test   %eax,%eax
  800645:	79 02                	jns    800649 <vprintfmt+0xf1>
				err = -err;
  800647:	f7 d8                	neg    %eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800649:	83 f8 0f             	cmp    $0xf,%eax
  80064c:	7f 0b                	jg     800659 <vprintfmt+0x101>
  80064e:	8b 3c 85 e0 10 80 00 	mov    0x8010e0(,%eax,4),%edi
  800655:	85 ff                	test   %edi,%edi
  800657:	75 19                	jne    800672 <vprintfmt+0x11a>
				printfmt(putch, putdat, "error %d", err);
  800659:	50                   	push   %eax
  80065a:	68 a0 10 80 00       	push   $0x8010a0
  80065f:	ff 75 0c             	pushl  0xc(%ebp)
  800662:	ff 75 08             	pushl  0x8(%ebp)
  800665:	e8 ef 01 00 00       	call   800859 <printfmt>
  80066a:	83 c4 10             	add    $0x10,%esp
  80066d:	e9 f2 fe ff ff       	jmp    800564 <vprintfmt+0xc>
			else
				printfmt(putch, putdat, "%s", p);
  800672:	57                   	push   %edi
  800673:	68 a9 10 80 00       	push   $0x8010a9
  800678:	ff 75 0c             	pushl  0xc(%ebp)
  80067b:	ff 75 08             	pushl  0x8(%ebp)
  80067e:	e8 d6 01 00 00       	call   800859 <printfmt>
  800683:	83 c4 10             	add    $0x10,%esp
			break;
  800686:	e9 d9 fe ff ff       	jmp    800564 <vprintfmt+0xc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80068b:	8b 55 14             	mov    0x14(%ebp),%edx
  80068e:	8d 42 04             	lea    0x4(%edx),%eax
  800691:	89 45 14             	mov    %eax,0x14(%ebp)
  800694:	8b 3a                	mov    (%edx),%edi
  800696:	85 ff                	test   %edi,%edi
  800698:	75 05                	jne    80069f <vprintfmt+0x147>
				p = "(null)";
  80069a:	bf ac 10 80 00       	mov    $0x8010ac,%edi
			if (width > 0 && padc != '-')
  80069f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8006a3:	7e 3b                	jle    8006e0 <vprintfmt+0x188>
  8006a5:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  8006a9:	74 35                	je     8006e0 <vprintfmt+0x188>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ab:	83 ec 08             	sub    $0x8,%esp
  8006ae:	56                   	push   %esi
  8006af:	57                   	push   %edi
  8006b0:	e8 58 02 00 00       	call   80090d <strnlen>
  8006b5:	29 45 f0             	sub    %eax,-0x10(%ebp)
  8006b8:	83 c4 10             	add    $0x10,%esp
  8006bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8006bf:	7e 1f                	jle    8006e0 <vprintfmt+0x188>
  8006c1:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  8006c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
					putch(padc, putdat);
  8006c8:	83 ec 08             	sub    $0x8,%esp
  8006cb:	ff 75 0c             	pushl  0xc(%ebp)
  8006ce:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006d1:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d4:	83 c4 10             	add    $0x10,%esp
  8006d7:	ff 4d f0             	decl   -0x10(%ebp)
  8006da:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8006de:	7f e8                	jg     8006c8 <vprintfmt+0x170>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006e0:	0f be 0f             	movsbl (%edi),%ecx
  8006e3:	47                   	inc    %edi
  8006e4:	85 c9                	test   %ecx,%ecx
  8006e6:	74 44                	je     80072c <vprintfmt+0x1d4>
  8006e8:	85 f6                	test   %esi,%esi
  8006ea:	78 03                	js     8006ef <vprintfmt+0x197>
  8006ec:	4e                   	dec    %esi
  8006ed:	78 3d                	js     80072c <vprintfmt+0x1d4>
				if (altflag && (ch < ' ' || ch > '~'))
  8006ef:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8006f3:	74 18                	je     80070d <vprintfmt+0x1b5>
  8006f5:	8d 41 e0             	lea    -0x20(%ecx),%eax
  8006f8:	83 f8 5e             	cmp    $0x5e,%eax
  8006fb:	76 10                	jbe    80070d <vprintfmt+0x1b5>
					putch('?', putdat);
  8006fd:	83 ec 08             	sub    $0x8,%esp
  800700:	ff 75 0c             	pushl  0xc(%ebp)
  800703:	6a 3f                	push   $0x3f
  800705:	ff 55 08             	call   *0x8(%ebp)
  800708:	83 c4 10             	add    $0x10,%esp
  80070b:	eb 0d                	jmp    80071a <vprintfmt+0x1c2>
				else
					putch(ch, putdat);
  80070d:	83 ec 08             	sub    $0x8,%esp
  800710:	ff 75 0c             	pushl  0xc(%ebp)
  800713:	51                   	push   %ecx
  800714:	ff 55 08             	call   *0x8(%ebp)
  800717:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80071a:	ff 4d f0             	decl   -0x10(%ebp)
  80071d:	0f be 0f             	movsbl (%edi),%ecx
  800720:	47                   	inc    %edi
  800721:	85 c9                	test   %ecx,%ecx
  800723:	74 07                	je     80072c <vprintfmt+0x1d4>
  800725:	85 f6                	test   %esi,%esi
  800727:	78 c6                	js     8006ef <vprintfmt+0x197>
  800729:	4e                   	dec    %esi
  80072a:	79 c3                	jns    8006ef <vprintfmt+0x197>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80072c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800730:	0f 8e 2e fe ff ff    	jle    800564 <vprintfmt+0xc>
				putch(' ', putdat);
  800736:	83 ec 08             	sub    $0x8,%esp
  800739:	ff 75 0c             	pushl  0xc(%ebp)
  80073c:	6a 20                	push   $0x20
  80073e:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800741:	83 c4 10             	add    $0x10,%esp
  800744:	ff 4d f0             	decl   -0x10(%ebp)
  800747:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80074b:	7f e9                	jg     800736 <vprintfmt+0x1de>
				putch(' ', putdat);
			break;
  80074d:	e9 12 fe ff ff       	jmp    800564 <vprintfmt+0xc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800752:	57                   	push   %edi
  800753:	8d 45 14             	lea    0x14(%ebp),%eax
  800756:	50                   	push   %eax
  800757:	e8 c4 fd ff ff       	call   800520 <getint>
  80075c:	89 c6                	mov    %eax,%esi
  80075e:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800760:	83 c4 08             	add    $0x8,%esp
  800763:	85 d2                	test   %edx,%edx
  800765:	79 15                	jns    80077c <vprintfmt+0x224>
				putch('-', putdat);
  800767:	83 ec 08             	sub    $0x8,%esp
  80076a:	ff 75 0c             	pushl  0xc(%ebp)
  80076d:	6a 2d                	push   $0x2d
  80076f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800772:	f7 de                	neg    %esi
  800774:	83 d7 00             	adc    $0x0,%edi
  800777:	f7 df                	neg    %edi
  800779:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80077c:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  800781:	eb 76                	jmp    8007f9 <vprintfmt+0x2a1>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800783:	57                   	push   %edi
  800784:	8d 45 14             	lea    0x14(%ebp),%eax
  800787:	50                   	push   %eax
  800788:	e8 53 fd ff ff       	call   8004e0 <getuint>
  80078d:	89 c6                	mov    %eax,%esi
  80078f:	89 d7                	mov    %edx,%edi
			base = 10;
  800791:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  800796:	83 c4 08             	add    $0x8,%esp
  800799:	eb 5e                	jmp    8007f9 <vprintfmt+0x2a1>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80079b:	57                   	push   %edi
  80079c:	8d 45 14             	lea    0x14(%ebp),%eax
  80079f:	50                   	push   %eax
  8007a0:	e8 3b fd ff ff       	call   8004e0 <getuint>
  8007a5:	89 c6                	mov    %eax,%esi
  8007a7:	89 d7                	mov    %edx,%edi
			base = 8;
  8007a9:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  8007ae:	83 c4 08             	add    $0x8,%esp
  8007b1:	eb 46                	jmp    8007f9 <vprintfmt+0x2a1>

		// pointer
		case 'p':
			putch('0', putdat);
  8007b3:	83 ec 08             	sub    $0x8,%esp
  8007b6:	ff 75 0c             	pushl  0xc(%ebp)
  8007b9:	6a 30                	push   $0x30
  8007bb:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007be:	83 c4 08             	add    $0x8,%esp
  8007c1:	ff 75 0c             	pushl  0xc(%ebp)
  8007c4:	6a 78                	push   $0x78
  8007c6:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8007c9:	8b 55 14             	mov    0x14(%ebp),%edx
  8007cc:	8d 42 04             	lea    0x4(%edx),%eax
  8007cf:	89 45 14             	mov    %eax,0x14(%ebp)
  8007d2:	8b 32                	mov    (%edx),%esi
  8007d4:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007d9:	ba 10 00 00 00       	mov    $0x10,%edx
			goto number;
  8007de:	83 c4 10             	add    $0x10,%esp
  8007e1:	eb 16                	jmp    8007f9 <vprintfmt+0x2a1>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007e3:	57                   	push   %edi
  8007e4:	8d 45 14             	lea    0x14(%ebp),%eax
  8007e7:	50                   	push   %eax
  8007e8:	e8 f3 fc ff ff       	call   8004e0 <getuint>
  8007ed:	89 c6                	mov    %eax,%esi
  8007ef:	89 d7                	mov    %edx,%edi
			base = 16;
  8007f1:	ba 10 00 00 00       	mov    $0x10,%edx
  8007f6:	83 c4 08             	add    $0x8,%esp
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007f9:	83 ec 04             	sub    $0x4,%esp
  8007fc:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  800800:	50                   	push   %eax
  800801:	ff 75 f0             	pushl  -0x10(%ebp)
  800804:	52                   	push   %edx
  800805:	57                   	push   %edi
  800806:	56                   	push   %esi
  800807:	ff 75 0c             	pushl  0xc(%ebp)
  80080a:	ff 75 08             	pushl  0x8(%ebp)
  80080d:	e8 2e fc ff ff       	call   800440 <printnum>
			break;
  800812:	83 c4 20             	add    $0x20,%esp
  800815:	e9 4a fd ff ff       	jmp    800564 <vprintfmt+0xc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80081a:	83 ec 08             	sub    $0x8,%esp
  80081d:	ff 75 0c             	pushl  0xc(%ebp)
  800820:	51                   	push   %ecx
  800821:	ff 55 08             	call   *0x8(%ebp)
			break;
  800824:	83 c4 10             	add    $0x10,%esp
  800827:	e9 38 fd ff ff       	jmp    800564 <vprintfmt+0xc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80082c:	83 ec 08             	sub    $0x8,%esp
  80082f:	ff 75 0c             	pushl  0xc(%ebp)
  800832:	6a 25                	push   $0x25
  800834:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800837:	4b                   	dec    %ebx
  800838:	83 c4 10             	add    $0x10,%esp
  80083b:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80083f:	0f 84 1f fd ff ff    	je     800564 <vprintfmt+0xc>
  800845:	4b                   	dec    %ebx
  800846:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80084a:	75 f9                	jne    800845 <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  80084c:	e9 13 fd ff ff       	jmp    800564 <vprintfmt+0xc>
		}
	}
}
  800851:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800854:	5b                   	pop    %ebx
  800855:	5e                   	pop    %esi
  800856:	5f                   	pop    %edi
  800857:	c9                   	leave  
  800858:	c3                   	ret    

00800859 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800859:	55                   	push   %ebp
  80085a:	89 e5                	mov    %esp,%ebp
  80085c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80085f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800862:	50                   	push   %eax
  800863:	ff 75 10             	pushl  0x10(%ebp)
  800866:	ff 75 0c             	pushl  0xc(%ebp)
  800869:	ff 75 08             	pushl  0x8(%ebp)
  80086c:	e8 e7 fc ff ff       	call   800558 <vprintfmt>
	va_end(ap);
}
  800871:	c9                   	leave  
  800872:	c3                   	ret    

00800873 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  800879:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  80087c:	8b 0a                	mov    (%edx),%ecx
  80087e:	3b 4a 04             	cmp    0x4(%edx),%ecx
  800881:	73 07                	jae    80088a <sprintputch+0x17>
		*b->buf++ = ch;
  800883:	8b 45 08             	mov    0x8(%ebp),%eax
  800886:	88 01                	mov    %al,(%ecx)
  800888:	ff 02                	incl   (%edx)
}
  80088a:	c9                   	leave  
  80088b:	c3                   	ret    

0080088c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	83 ec 18             	sub    $0x18,%esp
  800892:	8b 55 08             	mov    0x8(%ebp),%edx
  800895:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800898:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80089b:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
  80089f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008a2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

	if (buf == NULL || n < 1)
  8008a9:	85 d2                	test   %edx,%edx
  8008ab:	74 04                	je     8008b1 <vsnprintf+0x25>
  8008ad:	85 c9                	test   %ecx,%ecx
  8008af:	7f 07                	jg     8008b8 <vsnprintf+0x2c>
		return -E_INVAL;
  8008b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008b6:	eb 1d                	jmp    8008d5 <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008b8:	ff 75 14             	pushl  0x14(%ebp)
  8008bb:	ff 75 10             	pushl  0x10(%ebp)
  8008be:	8d 45 e8             	lea    -0x18(%ebp),%eax
  8008c1:	50                   	push   %eax
  8008c2:	68 73 08 80 00       	push   $0x800873
  8008c7:	e8 8c fc ff ff       	call   800558 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8008cf:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8008d5:	c9                   	leave  
  8008d6:	c3                   	ret    

008008d7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008dd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008e0:	50                   	push   %eax
  8008e1:	ff 75 10             	pushl  0x10(%ebp)
  8008e4:	ff 75 0c             	pushl  0xc(%ebp)
  8008e7:	ff 75 08             	pushl  0x8(%ebp)
  8008ea:	e8 9d ff ff ff       	call   80088c <vsnprintf>
	va_end(ap);

	return rc;
}
  8008ef:	c9                   	leave  
  8008f0:	c3                   	ret    
  8008f1:	00 00                	add    %al,(%eax)
	...

008008f4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008f4:	55                   	push   %ebp
  8008f5:	89 e5                	mov    %esp,%ebp
  8008f7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ff:	80 3a 00             	cmpb   $0x0,(%edx)
  800902:	74 07                	je     80090b <strlen+0x17>
		n++;
  800904:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800905:	42                   	inc    %edx
  800906:	80 3a 00             	cmpb   $0x0,(%edx)
  800909:	75 f9                	jne    800904 <strlen+0x10>
		n++;
	return n;
}
  80090b:	c9                   	leave  
  80090c:	c3                   	ret    

0080090d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80090d:	55                   	push   %ebp
  80090e:	89 e5                	mov    %esp,%ebp
  800910:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800913:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800916:	b8 00 00 00 00       	mov    $0x0,%eax
  80091b:	85 d2                	test   %edx,%edx
  80091d:	74 0f                	je     80092e <strnlen+0x21>
  80091f:	80 39 00             	cmpb   $0x0,(%ecx)
  800922:	74 0a                	je     80092e <strnlen+0x21>
		n++;
  800924:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800925:	41                   	inc    %ecx
  800926:	4a                   	dec    %edx
  800927:	74 05                	je     80092e <strnlen+0x21>
  800929:	80 39 00             	cmpb   $0x0,(%ecx)
  80092c:	75 f6                	jne    800924 <strnlen+0x17>
		n++;
	return n;
}
  80092e:	c9                   	leave  
  80092f:	c3                   	ret    

00800930 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	53                   	push   %ebx
  800934:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800937:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  80093a:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  80093c:	8a 02                	mov    (%edx),%al
  80093e:	42                   	inc    %edx
  80093f:	88 01                	mov    %al,(%ecx)
  800941:	41                   	inc    %ecx
  800942:	84 c0                	test   %al,%al
  800944:	75 f6                	jne    80093c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800946:	89 d8                	mov    %ebx,%eax
  800948:	5b                   	pop    %ebx
  800949:	c9                   	leave  
  80094a:	c3                   	ret    

0080094b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	53                   	push   %ebx
  80094f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800952:	53                   	push   %ebx
  800953:	e8 9c ff ff ff       	call   8008f4 <strlen>
	strcpy(dst + len, src);
  800958:	ff 75 0c             	pushl  0xc(%ebp)
  80095b:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80095e:	50                   	push   %eax
  80095f:	e8 cc ff ff ff       	call   800930 <strcpy>
	return dst;
}
  800964:	89 d8                	mov    %ebx,%eax
  800966:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800969:	c9                   	leave  
  80096a:	c3                   	ret    

0080096b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	57                   	push   %edi
  80096f:	56                   	push   %esi
  800970:	53                   	push   %ebx
  800971:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800974:	8b 55 0c             	mov    0xc(%ebp),%edx
  800977:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  80097a:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  80097c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800981:	39 f3                	cmp    %esi,%ebx
  800983:	73 10                	jae    800995 <strncpy+0x2a>
		*dst++ = *src;
  800985:	8a 02                	mov    (%edx),%al
  800987:	88 01                	mov    %al,(%ecx)
  800989:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80098a:	80 3a 01             	cmpb   $0x1,(%edx)
  80098d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800990:	43                   	inc    %ebx
  800991:	39 f3                	cmp    %esi,%ebx
  800993:	72 f0                	jb     800985 <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800995:	89 f8                	mov    %edi,%eax
  800997:	5b                   	pop    %ebx
  800998:	5e                   	pop    %esi
  800999:	5f                   	pop    %edi
  80099a:	c9                   	leave  
  80099b:	c3                   	ret    

0080099c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	56                   	push   %esi
  8009a0:	53                   	push   %ebx
  8009a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009a7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  8009aa:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  8009ac:	85 d2                	test   %edx,%edx
  8009ae:	74 19                	je     8009c9 <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009b0:	4a                   	dec    %edx
  8009b1:	74 13                	je     8009c6 <strlcpy+0x2a>
  8009b3:	80 39 00             	cmpb   $0x0,(%ecx)
  8009b6:	74 0e                	je     8009c6 <strlcpy+0x2a>
  8009b8:	8a 01                	mov    (%ecx),%al
  8009ba:	41                   	inc    %ecx
  8009bb:	88 03                	mov    %al,(%ebx)
  8009bd:	43                   	inc    %ebx
  8009be:	4a                   	dec    %edx
  8009bf:	74 05                	je     8009c6 <strlcpy+0x2a>
  8009c1:	80 39 00             	cmpb   $0x0,(%ecx)
  8009c4:	75 f2                	jne    8009b8 <strlcpy+0x1c>
		*dst = '\0';
  8009c6:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  8009c9:	89 d8                	mov    %ebx,%eax
  8009cb:	29 f0                	sub    %esi,%eax
}
  8009cd:	5b                   	pop    %ebx
  8009ce:	5e                   	pop    %esi
  8009cf:	c9                   	leave  
  8009d0:	c3                   	ret    

008009d1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
  8009d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8009d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
		p++, q++;
  8009da:	80 3a 00             	cmpb   $0x0,(%edx)
  8009dd:	74 13                	je     8009f2 <strcmp+0x21>
  8009df:	8a 02                	mov    (%edx),%al
  8009e1:	3a 01                	cmp    (%ecx),%al
  8009e3:	75 0d                	jne    8009f2 <strcmp+0x21>
  8009e5:	42                   	inc    %edx
  8009e6:	41                   	inc    %ecx
  8009e7:	80 3a 00             	cmpb   $0x0,(%edx)
  8009ea:	74 06                	je     8009f2 <strcmp+0x21>
  8009ec:	8a 02                	mov    (%edx),%al
  8009ee:	3a 01                	cmp    (%ecx),%al
  8009f0:	74 f3                	je     8009e5 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009f2:	0f b6 02             	movzbl (%edx),%eax
  8009f5:	0f b6 11             	movzbl (%ecx),%edx
  8009f8:	29 d0                	sub    %edx,%eax
}
  8009fa:	c9                   	leave  
  8009fb:	c3                   	ret    

008009fc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	53                   	push   %ebx
  800a00:	8b 55 08             	mov    0x8(%ebp),%edx
  800a03:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a06:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800a09:	85 c9                	test   %ecx,%ecx
  800a0b:	74 1f                	je     800a2c <strncmp+0x30>
  800a0d:	80 3a 00             	cmpb   $0x0,(%edx)
  800a10:	74 16                	je     800a28 <strncmp+0x2c>
  800a12:	8a 02                	mov    (%edx),%al
  800a14:	3a 03                	cmp    (%ebx),%al
  800a16:	75 10                	jne    800a28 <strncmp+0x2c>
  800a18:	42                   	inc    %edx
  800a19:	43                   	inc    %ebx
  800a1a:	49                   	dec    %ecx
  800a1b:	74 0f                	je     800a2c <strncmp+0x30>
  800a1d:	80 3a 00             	cmpb   $0x0,(%edx)
  800a20:	74 06                	je     800a28 <strncmp+0x2c>
  800a22:	8a 02                	mov    (%edx),%al
  800a24:	3a 03                	cmp    (%ebx),%al
  800a26:	74 f0                	je     800a18 <strncmp+0x1c>
	if (n == 0)
  800a28:	85 c9                	test   %ecx,%ecx
  800a2a:	75 07                	jne    800a33 <strncmp+0x37>
		return 0;
  800a2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a31:	eb 0a                	jmp    800a3d <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a33:	0f b6 12             	movzbl (%edx),%edx
  800a36:	0f b6 03             	movzbl (%ebx),%eax
  800a39:	29 c2                	sub    %eax,%edx
  800a3b:	89 d0                	mov    %edx,%eax
}
  800a3d:	5b                   	pop    %ebx
  800a3e:	c9                   	leave  
  800a3f:	c3                   	ret    

00800a40 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	8b 45 08             	mov    0x8(%ebp),%eax
  800a46:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800a49:	80 38 00             	cmpb   $0x0,(%eax)
  800a4c:	74 0a                	je     800a58 <strchr+0x18>
		if (*s == c)
  800a4e:	38 10                	cmp    %dl,(%eax)
  800a50:	74 0b                	je     800a5d <strchr+0x1d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a52:	40                   	inc    %eax
  800a53:	80 38 00             	cmpb   $0x0,(%eax)
  800a56:	75 f6                	jne    800a4e <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800a58:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a5d:	c9                   	leave  
  800a5e:	c3                   	ret    

00800a5f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
  800a62:	8b 45 08             	mov    0x8(%ebp),%eax
  800a65:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800a68:	80 38 00             	cmpb   $0x0,(%eax)
  800a6b:	74 0a                	je     800a77 <strfind+0x18>
		if (*s == c)
  800a6d:	38 10                	cmp    %dl,(%eax)
  800a6f:	74 06                	je     800a77 <strfind+0x18>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a71:	40                   	inc    %eax
  800a72:	80 38 00             	cmpb   $0x0,(%eax)
  800a75:	75 f6                	jne    800a6d <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
}
  800a77:	c9                   	leave  
  800a78:	c3                   	ret    

00800a79 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a79:	55                   	push   %ebp
  800a7a:	89 e5                	mov    %esp,%ebp
  800a7c:	57                   	push   %edi
  800a7d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a80:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
		return v;
  800a83:	89 f8                	mov    %edi,%eax
void *
memset(void *v, int c, size_t n)
{
	char *p;

	if (n == 0)
  800a85:	85 c9                	test   %ecx,%ecx
  800a87:	74 40                	je     800ac9 <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a89:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a8f:	75 30                	jne    800ac1 <memset+0x48>
  800a91:	f6 c1 03             	test   $0x3,%cl
  800a94:	75 2b                	jne    800ac1 <memset+0x48>
		c &= 0xFF;
  800a96:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa0:	c1 e0 18             	shl    $0x18,%eax
  800aa3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa6:	c1 e2 10             	shl    $0x10,%edx
  800aa9:	09 d0                	or     %edx,%eax
  800aab:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aae:	c1 e2 08             	shl    $0x8,%edx
  800ab1:	09 d0                	or     %edx,%eax
  800ab3:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  800ab6:	c1 e9 02             	shr    $0x2,%ecx
  800ab9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abc:	fc                   	cld    
  800abd:	f3 ab                	rep stos %eax,%es:(%edi)
  800abf:	eb 06                	jmp    800ac7 <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ac1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac4:	fc                   	cld    
  800ac5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800ac7:	89 f8                	mov    %edi,%eax
}
  800ac9:	5f                   	pop    %edi
  800aca:	c9                   	leave  
  800acb:	c3                   	ret    

00800acc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	57                   	push   %edi
  800ad0:	56                   	push   %esi
  800ad1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800ad7:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800ada:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800adc:	39 c6                	cmp    %eax,%esi
  800ade:	73 34                	jae    800b14 <memmove+0x48>
  800ae0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ae3:	39 c2                	cmp    %eax,%edx
  800ae5:	76 2d                	jbe    800b14 <memmove+0x48>
		s += n;
  800ae7:	89 d6                	mov    %edx,%esi
		d += n;
  800ae9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aec:	f6 c2 03             	test   $0x3,%dl
  800aef:	75 1b                	jne    800b0c <memmove+0x40>
  800af1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800af7:	75 13                	jne    800b0c <memmove+0x40>
  800af9:	f6 c1 03             	test   $0x3,%cl
  800afc:	75 0e                	jne    800b0c <memmove+0x40>
			asm volatile("std; rep movsl\n"
  800afe:	83 ef 04             	sub    $0x4,%edi
  800b01:	83 ee 04             	sub    $0x4,%esi
  800b04:	c1 e9 02             	shr    $0x2,%ecx
  800b07:	fd                   	std    
  800b08:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b0a:	eb 05                	jmp    800b11 <memmove+0x45>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b0c:	4f                   	dec    %edi
  800b0d:	4e                   	dec    %esi
  800b0e:	fd                   	std    
  800b0f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b11:	fc                   	cld    
  800b12:	eb 20                	jmp    800b34 <memmove+0x68>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b14:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b1a:	75 15                	jne    800b31 <memmove+0x65>
  800b1c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b22:	75 0d                	jne    800b31 <memmove+0x65>
  800b24:	f6 c1 03             	test   $0x3,%cl
  800b27:	75 08                	jne    800b31 <memmove+0x65>
			asm volatile("cld; rep movsl\n"
  800b29:	c1 e9 02             	shr    $0x2,%ecx
  800b2c:	fc                   	cld    
  800b2d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b2f:	eb 03                	jmp    800b34 <memmove+0x68>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b31:	fc                   	cld    
  800b32:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b34:	5e                   	pop    %esi
  800b35:	5f                   	pop    %edi
  800b36:	c9                   	leave  
  800b37:	c3                   	ret    

00800b38 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b3b:	ff 75 10             	pushl  0x10(%ebp)
  800b3e:	ff 75 0c             	pushl  0xc(%ebp)
  800b41:	ff 75 08             	pushl  0x8(%ebp)
  800b44:	e8 83 ff ff ff       	call   800acc <memmove>
}
  800b49:	c9                   	leave  
  800b4a:	c3                   	ret    

00800b4b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
  800b4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  800b52:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b55:	8b 55 10             	mov    0x10(%ebp),%edx
  800b58:	4a                   	dec    %edx
  800b59:	83 fa ff             	cmp    $0xffffffff,%edx
  800b5c:	74 1a                	je     800b78 <memcmp+0x2d>
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  800b5e:	8a 01                	mov    (%ecx),%al
  800b60:	3a 03                	cmp    (%ebx),%al
  800b62:	74 0c                	je     800b70 <memcmp+0x25>
			return (int) *s1 - (int) *s2;
  800b64:	0f b6 d0             	movzbl %al,%edx
  800b67:	0f b6 03             	movzbl (%ebx),%eax
  800b6a:	29 c2                	sub    %eax,%edx
  800b6c:	89 d0                	mov    %edx,%eax
  800b6e:	eb 0d                	jmp    800b7d <memcmp+0x32>
		s1++, s2++;
  800b70:	41                   	inc    %ecx
  800b71:	43                   	inc    %ebx
  800b72:	4a                   	dec    %edx
  800b73:	83 fa ff             	cmp    $0xffffffff,%edx
  800b76:	75 e6                	jne    800b5e <memcmp+0x13>
	}

	return 0;
  800b78:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b7d:	5b                   	pop    %ebx
  800b7e:	c9                   	leave  
  800b7f:	c3                   	ret    

00800b80 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	8b 45 08             	mov    0x8(%ebp),%eax
  800b86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b89:	89 c2                	mov    %eax,%edx
  800b8b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b8e:	39 d0                	cmp    %edx,%eax
  800b90:	73 09                	jae    800b9b <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b92:	38 08                	cmp    %cl,(%eax)
  800b94:	74 05                	je     800b9b <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b96:	40                   	inc    %eax
  800b97:	39 d0                	cmp    %edx,%eax
  800b99:	72 f7                	jb     800b92 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b9b:	c9                   	leave  
  800b9c:	c3                   	ret    

00800b9d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	57                   	push   %edi
  800ba1:	56                   	push   %esi
  800ba2:	53                   	push   %ebx
  800ba3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ba9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  800bac:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  800bb1:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  800bb6:	80 3a 20             	cmpb   $0x20,(%edx)
  800bb9:	74 05                	je     800bc0 <strtol+0x23>
  800bbb:	80 3a 09             	cmpb   $0x9,(%edx)
  800bbe:	75 0b                	jne    800bcb <strtol+0x2e>
  800bc0:	42                   	inc    %edx
  800bc1:	80 3a 20             	cmpb   $0x20,(%edx)
  800bc4:	74 fa                	je     800bc0 <strtol+0x23>
  800bc6:	80 3a 09             	cmpb   $0x9,(%edx)
  800bc9:	74 f5                	je     800bc0 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  800bcb:	80 3a 2b             	cmpb   $0x2b,(%edx)
  800bce:	75 03                	jne    800bd3 <strtol+0x36>
		s++;
  800bd0:	42                   	inc    %edx
  800bd1:	eb 0b                	jmp    800bde <strtol+0x41>
	else if (*s == '-')
  800bd3:	80 3a 2d             	cmpb   $0x2d,(%edx)
  800bd6:	75 06                	jne    800bde <strtol+0x41>
		s++, neg = 1;
  800bd8:	42                   	inc    %edx
  800bd9:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bde:	85 c9                	test   %ecx,%ecx
  800be0:	74 05                	je     800be7 <strtol+0x4a>
  800be2:	83 f9 10             	cmp    $0x10,%ecx
  800be5:	75 15                	jne    800bfc <strtol+0x5f>
  800be7:	80 3a 30             	cmpb   $0x30,(%edx)
  800bea:	75 10                	jne    800bfc <strtol+0x5f>
  800bec:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bf0:	75 0a                	jne    800bfc <strtol+0x5f>
		s += 2, base = 16;
  800bf2:	83 c2 02             	add    $0x2,%edx
  800bf5:	b9 10 00 00 00       	mov    $0x10,%ecx
  800bfa:	eb 14                	jmp    800c10 <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800bfc:	85 c9                	test   %ecx,%ecx
  800bfe:	75 10                	jne    800c10 <strtol+0x73>
  800c00:	80 3a 30             	cmpb   $0x30,(%edx)
  800c03:	75 05                	jne    800c0a <strtol+0x6d>
		s++, base = 8;
  800c05:	42                   	inc    %edx
  800c06:	b1 08                	mov    $0x8,%cl
  800c08:	eb 06                	jmp    800c10 <strtol+0x73>
	else if (base == 0)
  800c0a:	85 c9                	test   %ecx,%ecx
  800c0c:	75 02                	jne    800c10 <strtol+0x73>
		base = 10;
  800c0e:	b1 0a                	mov    $0xa,%cl

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c10:	8a 02                	mov    (%edx),%al
  800c12:	83 e8 30             	sub    $0x30,%eax
  800c15:	3c 09                	cmp    $0x9,%al
  800c17:	77 08                	ja     800c21 <strtol+0x84>
			dig = *s - '0';
  800c19:	0f be 02             	movsbl (%edx),%eax
  800c1c:	83 e8 30             	sub    $0x30,%eax
  800c1f:	eb 20                	jmp    800c41 <strtol+0xa4>
		else if (*s >= 'a' && *s <= 'z')
  800c21:	8a 02                	mov    (%edx),%al
  800c23:	83 e8 61             	sub    $0x61,%eax
  800c26:	3c 19                	cmp    $0x19,%al
  800c28:	77 08                	ja     800c32 <strtol+0x95>
			dig = *s - 'a' + 10;
  800c2a:	0f be 02             	movsbl (%edx),%eax
  800c2d:	83 e8 57             	sub    $0x57,%eax
  800c30:	eb 0f                	jmp    800c41 <strtol+0xa4>
		else if (*s >= 'A' && *s <= 'Z')
  800c32:	8a 02                	mov    (%edx),%al
  800c34:	83 e8 41             	sub    $0x41,%eax
  800c37:	3c 19                	cmp    $0x19,%al
  800c39:	77 12                	ja     800c4d <strtol+0xb0>
			dig = *s - 'A' + 10;
  800c3b:	0f be 02             	movsbl (%edx),%eax
  800c3e:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  800c41:	39 c8                	cmp    %ecx,%eax
  800c43:	7d 08                	jge    800c4d <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800c45:	42                   	inc    %edx
  800c46:	0f af d9             	imul   %ecx,%ebx
  800c49:	01 c3                	add    %eax,%ebx
  800c4b:	eb c3                	jmp    800c10 <strtol+0x73>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c4d:	85 f6                	test   %esi,%esi
  800c4f:	74 02                	je     800c53 <strtol+0xb6>
		*endptr = (char *) s;
  800c51:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800c53:	89 d8                	mov    %ebx,%eax
  800c55:	85 ff                	test   %edi,%edi
  800c57:	74 02                	je     800c5b <strtol+0xbe>
  800c59:	f7 d8                	neg    %eax
}
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	c9                   	leave  
  800c5f:	c3                   	ret    

00800c60 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	83 ec 14             	sub    $0x14,%esp
  800c68:	8b 55 14             	mov    0x14(%ebp),%edx
  800c6b:	8b 75 08             	mov    0x8(%ebp),%esi
  800c6e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c71:	8b 45 10             	mov    0x10(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800c74:	85 d2                	test   %edx,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800c76:	89 75 f0             	mov    %esi,-0x10(%ebp)
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800c79:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  d1 = dd.s.high;
  800c7c:	89 55 f4             	mov    %edx,-0xc(%ebp)
  n0 = nn.s.low;
  n1 = nn.s.high;
  800c7f:	89 fe                	mov    %edi,%esi

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800c81:	75 11                	jne    800c94 <__udivdi3+0x34>
    {
      if (d0 > n1)
  800c83:	39 f8                	cmp    %edi,%eax
  800c85:	76 4d                	jbe    800cd4 <__udivdi3+0x74>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800c87:	89 fa                	mov    %edi,%edx
  800c89:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c8c:	f7 75 e4             	divl   -0x1c(%ebp)
  800c8f:	89 c7                	mov    %eax,%edi
  800c91:	eb 09                	jmp    800c9c <__udivdi3+0x3c>
  800c93:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800c94:	39 7d f4             	cmp    %edi,-0xc(%ebp)
  800c97:	76 17                	jbe    800cb0 <__udivdi3+0x50>
	{
	  /* 00 = nn / DD */

	  q0 = 0;
  800c99:	31 ff                	xor    %edi,%edi
  800c9b:	90                   	nop
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
		}

	      q1 = 0;
  800c9c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ca3:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ca6:	83 c4 14             	add    $0x14,%esp
  800ca9:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800caa:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800cac:	5f                   	pop    %edi
  800cad:	c9                   	leave  
  800cae:	c3                   	ret    
  800caf:	90                   	nop
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800cb0:	0f bd 45 f4          	bsr    -0xc(%ebp),%eax
	  if (bm == 0)
  800cb4:	89 c7                	mov    %eax,%edi
  800cb6:	83 f7 1f             	xor    $0x1f,%edi
  800cb9:	75 4d                	jne    800d08 <__udivdi3+0xa8>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800cbb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800cbe:	77 0a                	ja     800cca <__udivdi3+0x6a>
  800cc0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
		}
	      else
		q0 = 0;
  800cc3:	31 ff                	xor    %edi,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800cc5:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  800cc8:	72 d2                	jb     800c9c <__udivdi3+0x3c>
		{
		  q0 = 1;
  800cca:	bf 01 00 00 00       	mov    $0x1,%edi
  800ccf:	eb cb                	jmp    800c9c <__udivdi3+0x3c>
  800cd1:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800cd4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800cd7:	85 c0                	test   %eax,%eax
  800cd9:	75 0e                	jne    800ce9 <__udivdi3+0x89>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800cdb:	b8 01 00 00 00       	mov    $0x1,%eax
  800ce0:	31 c9                	xor    %ecx,%ecx
  800ce2:	31 d2                	xor    %edx,%edx
  800ce4:	f7 f1                	div    %ecx
  800ce6:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800ce9:	89 f0                	mov    %esi,%eax
  800ceb:	31 d2                	xor    %edx,%edx
  800ced:	f7 75 e4             	divl   -0x1c(%ebp)
  800cf0:	89 45 ec             	mov    %eax,-0x14(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800cf3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cf6:	f7 75 e4             	divl   -0x1c(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cf9:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800cfc:	83 c4 14             	add    $0x14,%esp

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800cff:	89 c7                	mov    %eax,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d01:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d02:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d04:	5f                   	pop    %edi
  800d05:	c9                   	leave  
  800d06:	c3                   	ret    
  800d07:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d08:	b8 20 00 00 00       	mov    $0x20,%eax
  800d0d:	29 f8                	sub    %edi,%eax
  800d0f:	89 45 e8             	mov    %eax,-0x18(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  800d12:	89 f9                	mov    %edi,%ecx
  800d14:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d17:	d3 e2                	shl    %cl,%edx
  800d19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d1c:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800d1f:	d3 e8                	shr    %cl,%eax
  800d21:	09 c2                	or     %eax,%edx
	      d0 = d0 << bm;
  800d23:	89 f9                	mov    %edi,%ecx
  800d25:	d3 65 e4             	shll   %cl,-0x1c(%ebp)
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d28:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800d2b:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800d2e:	89 f2                	mov    %esi,%edx
  800d30:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  800d32:	89 f9                	mov    %edi,%ecx
  800d34:	d3 e6                	shl    %cl,%esi
  800d36:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d39:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800d3c:	d3 e8                	shr    %cl,%eax
  800d3e:	09 c6                	or     %eax,%esi
	      n0 = n0 << bm;
  800d40:	89 f9                	mov    %edi,%ecx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d42:	89 f0                	mov    %esi,%eax
  800d44:	f7 75 f4             	divl   -0xc(%ebp)
  800d47:	89 d6                	mov    %edx,%esi
  800d49:	89 c7                	mov    %eax,%edi

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800d4b:	d3 65 f0             	shll   %cl,-0x10(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800d4e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d51:	f7 e7                	mul    %edi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d53:	39 f2                	cmp    %esi,%edx
  800d55:	77 0f                	ja     800d66 <__udivdi3+0x106>
  800d57:	0f 85 3f ff ff ff    	jne    800c9c <__udivdi3+0x3c>
  800d5d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800d60:	0f 86 36 ff ff ff    	jbe    800c9c <__udivdi3+0x3c>
		{
		  q0--;
  800d66:	4f                   	dec    %edi
  800d67:	e9 30 ff ff ff       	jmp    800c9c <__udivdi3+0x3c>

00800d6c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	57                   	push   %edi
  800d70:	56                   	push   %esi
  800d71:	83 ec 30             	sub    $0x30,%esp
  800d74:	8b 55 14             	mov    0x14(%ebp),%edx
  800d77:	8b 45 10             	mov    0x10(%ebp),%eax
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  800d7a:	89 d7                	mov    %edx,%edi
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  800d7c:	8d 4d f0             	lea    -0x10(%ebp),%ecx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800d7f:	89 c6                	mov    %eax,%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;
  800d81:	8b 55 0c             	mov    0xc(%ebp),%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800d84:	8b 45 08             	mov    0x8(%ebp),%eax
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d87:	85 ff                	test   %edi,%edi
  800d89:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800d90:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  800d97:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800d9a:	89 45 dc             	mov    %eax,-0x24(%ebp)
  n1 = nn.s.high;
  800d9d:	89 55 cc             	mov    %edx,-0x34(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800da0:	75 3e                	jne    800de0 <__umoddi3+0x74>
    {
      if (d0 > n1)
  800da2:	39 d6                	cmp    %edx,%esi
  800da4:	0f 86 a2 00 00 00    	jbe    800e4c <__umoddi3+0xe0>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800daa:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  800dac:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800daf:	85 c9                	test   %ecx,%ecx

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800db1:	89 55 dc             	mov    %edx,-0x24(%ebp)

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  800db4:	74 1b                	je     800dd1 <__umoddi3+0x65>
	{
	  rr.s.low = n0;
  800db6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800db9:	89 45 e0             	mov    %eax,-0x20(%ebp)
	  rr.s.high = 0;
  800dbc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800dc3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800dc6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800dc9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800dcc:	89 10                	mov    %edx,(%eax)
  800dce:	89 48 04             	mov    %ecx,0x4(%eax)
  800dd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dd4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800dd7:	83 c4 30             	add    $0x30,%esp
  800dda:	5e                   	pop    %esi
  800ddb:	5f                   	pop    %edi
  800ddc:	c9                   	leave  
  800ddd:	c3                   	ret    
  800dde:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800de0:	3b 7d cc             	cmp    -0x34(%ebp),%edi
  800de3:	76 1f                	jbe    800e04 <__umoddi3+0x98>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800de5:	8b 55 08             	mov    0x8(%ebp),%edx
	      rr.s.high = n1;
  800de8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800deb:	89 55 e0             	mov    %edx,-0x20(%ebp)
	      rr.s.high = n1;
  800dee:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	      *rp = rr.ll;
  800df1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800df4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800df7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800dfa:	89 55 f4             	mov    %edx,-0xc(%ebp)
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800dfd:	83 c4 30             	add    $0x30,%esp
  800e00:	5e                   	pop    %esi
  800e01:	5f                   	pop    %edi
  800e02:	c9                   	leave  
  800e03:	c3                   	ret    
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e04:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800e07:	83 f0 1f             	xor    $0x1f,%eax
  800e0a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800e0d:	75 61                	jne    800e70 <__umoddi3+0x104>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e0f:	39 7d cc             	cmp    %edi,-0x34(%ebp)
  800e12:	77 05                	ja     800e19 <__umoddi3+0xad>
  800e14:	39 75 dc             	cmp    %esi,-0x24(%ebp)
  800e17:	72 10                	jb     800e29 <__umoddi3+0xbd>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e19:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800e1c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800e1f:	29 f0                	sub    %esi,%eax
  800e21:	19 fa                	sbb    %edi,%edx
  800e23:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800e26:	89 55 cc             	mov    %edx,-0x34(%ebp)
	      else
		q0 = 0;

	      q1 = 0;

	      if (rp != 0)
  800e29:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800e2c:	85 d2                	test   %edx,%edx
  800e2e:	74 a1                	je     800dd1 <__umoddi3+0x65>
		{
		  rr.s.low = n0;
  800e30:	8b 45 dc             	mov    -0x24(%ebp),%eax
		  rr.s.high = n1;
  800e33:	8b 55 cc             	mov    -0x34(%ebp),%edx

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  800e36:	89 45 e0             	mov    %eax,-0x20(%ebp)
		  rr.s.high = n1;
  800e39:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		  *rp = rr.ll;
  800e3c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800e3f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e42:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800e45:	89 01                	mov    %eax,(%ecx)
  800e47:	89 51 04             	mov    %edx,0x4(%ecx)
  800e4a:	eb 85                	jmp    800dd1 <__umoddi3+0x65>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e4c:	85 f6                	test   %esi,%esi
  800e4e:	75 0b                	jne    800e5b <__umoddi3+0xef>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e50:	b8 01 00 00 00       	mov    $0x1,%eax
  800e55:	31 d2                	xor    %edx,%edx
  800e57:	f7 f6                	div    %esi
  800e59:	89 c6                	mov    %eax,%esi

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e5b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800e5e:	89 fa                	mov    %edi,%edx
  800e60:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e62:	8b 45 dc             	mov    -0x24(%ebp),%eax
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e65:	89 55 cc             	mov    %edx,-0x34(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e68:	f7 f6                	div    %esi
  800e6a:	e9 3d ff ff ff       	jmp    800dac <__umoddi3+0x40>
  800e6f:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e70:	b8 20 00 00 00       	mov    $0x20,%eax
  800e75:	2b 45 d4             	sub    -0x2c(%ebp),%eax
  800e78:	89 45 d8             	mov    %eax,-0x28(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  800e7b:	89 fa                	mov    %edi,%edx
  800e7d:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800e80:	d3 e2                	shl    %cl,%edx
  800e82:	89 f0                	mov    %esi,%eax
  800e84:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800e87:	d3 e8                	shr    %cl,%eax
	      d0 = d0 << bm;
  800e89:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800e8c:	d3 e6                	shl    %cl,%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e8e:	89 d7                	mov    %edx,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800e90:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800e93:	8b 55 cc             	mov    -0x34(%ebp),%edx
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e96:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800e98:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  800e9a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800e9d:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800ea0:	d3 e0                	shl    %cl,%eax
  800ea2:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800ea5:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800ea8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800eab:	d3 e8                	shr    %cl,%eax
  800ead:	0b 45 cc             	or     -0x34(%ebp),%eax
  800eb0:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n0 = n0 << bm;
  800eb3:	8a 4d d4             	mov    -0x2c(%ebp),%cl

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800eb6:	f7 f7                	div    %edi
  800eb8:	89 55 cc             	mov    %edx,-0x34(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800ebb:	d3 65 dc             	shll   %cl,-0x24(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800ebe:	f7 e6                	mul    %esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ec0:	3b 55 cc             	cmp    -0x34(%ebp),%edx
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800ec3:	89 45 c8             	mov    %eax,-0x38(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ec6:	77 0a                	ja     800ed2 <__umoddi3+0x166>
  800ec8:	75 12                	jne    800edc <__umoddi3+0x170>
  800eca:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800ecd:	39 45 c8             	cmp    %eax,-0x38(%ebp)
  800ed0:	76 0a                	jbe    800edc <__umoddi3+0x170>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800ed2:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800ed5:	29 f1                	sub    %esi,%ecx
  800ed7:	19 fa                	sbb    %edi,%edx
  800ed9:	89 4d c8             	mov    %ecx,-0x38(%ebp)
		}

	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
  800edc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800edf:	85 c0                	test   %eax,%eax
  800ee1:	0f 84 ea fe ff ff    	je     800dd1 <__umoddi3+0x65>
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800ee7:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800eea:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800eed:	2b 45 c8             	sub    -0x38(%ebp),%eax
  800ef0:	19 d1                	sbb    %edx,%ecx
  800ef2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800ef5:	89 ca                	mov    %ecx,%edx
  800ef7:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800efa:	d3 e2                	shl    %cl,%edx
  800efc:	8a 4d d4             	mov    -0x2c(%ebp),%cl
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800eff:	89 45 dc             	mov    %eax,-0x24(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f02:	d3 e8                	shr    %cl,%eax
  800f04:	09 c2                	or     %eax,%edx
		  rr.s.high = n1 >> bm;
  800f06:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800f09:	d3 e8                	shr    %cl,%eax

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f0b:	89 55 e0             	mov    %edx,-0x20(%ebp)
		  rr.s.high = n1 >> bm;
  800f0e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f11:	e9 ad fe ff ff       	jmp    800dc3 <__umoddi3+0x57>
