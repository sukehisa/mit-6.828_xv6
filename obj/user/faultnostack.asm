
obj/user/faultnostack.debug:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  80003a:	68 64 03 80 00       	push   $0x800364
  80003f:	6a 00                	push   $0x0
  800041:	e8 77 02 00 00       	call   8002bd <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800046:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004d:	00 00 00 
}
  800050:	c9                   	leave  
  800051:	c3                   	ret    
	...

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	8b 75 08             	mov    0x8(%ebp),%esi
  80005c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];	
  80005f:	e8 d0 00 00 00       	call   800134 <sys_getenvid>
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	89 c2                	mov    %eax,%edx
  80006b:	c1 e2 05             	shl    $0x5,%edx
  80006e:	29 c2                	sub    %eax,%edx
  800070:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  800077:	89 15 04 20 80 00    	mov    %edx,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007d:	85 f6                	test   %esi,%esi
  80007f:	7e 07                	jle    800088 <libmain+0x34>
		binaryname = argv[0];
  800081:	8b 03                	mov    (%ebx),%eax
  800083:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800088:	83 ec 08             	sub    $0x8,%esp
  80008b:	53                   	push   %ebx
  80008c:	56                   	push   %esi
  80008d:	e8 a2 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800092:	e8 09 00 00 00       	call   8000a0 <exit>
}
  800097:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80009a:	5b                   	pop    %ebx
  80009b:	5e                   	pop    %esi
  80009c:	c9                   	leave  
  80009d:	c3                   	ret    
	...

008000a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  8000a6:	6a 00                	push   $0x0
  8000a8:	e8 46 00 00 00       	call   8000f3 <sys_env_destroy>
}
  8000ad:	c9                   	leave  
  8000ae:	c3                   	ret    
	...

008000b0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	57                   	push   %edi
  8000b4:	56                   	push   %esi
  8000b5:	53                   	push   %ebx
  8000b6:	83 ec 04             	sub    $0x4,%esp
  8000b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000bf:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c4:	89 f8                	mov    %edi,%eax
  8000c6:	89 fb                	mov    %edi,%ebx
  8000c8:	89 fe                	mov    %edi,%esi
  8000ca:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000cc:	83 c4 04             	add    $0x4,%esp
  8000cf:	5b                   	pop    %ebx
  8000d0:	5e                   	pop    %esi
  8000d1:	5f                   	pop    %edi
  8000d2:	c9                   	leave  
  8000d3:	c3                   	ret    

008000d4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d4:	55                   	push   %ebp
  8000d5:	89 e5                	mov    %esp,%ebp
  8000d7:	57                   	push   %edi
  8000d8:	56                   	push   %esi
  8000d9:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000da:	b8 01 00 00 00       	mov    $0x1,%eax
  8000df:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e4:	89 fa                	mov    %edi,%edx
  8000e6:	89 f9                	mov    %edi,%ecx
  8000e8:	89 fb                	mov    %edi,%ebx
  8000ea:	89 fe                	mov    %edi,%esi
  8000ec:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ee:	5b                   	pop    %ebx
  8000ef:	5e                   	pop    %esi
  8000f0:	5f                   	pop    %edi
  8000f1:	c9                   	leave  
  8000f2:	c3                   	ret    

008000f3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	57                   	push   %edi
  8000f7:	56                   	push   %esi
  8000f8:	53                   	push   %ebx
  8000f9:	83 ec 0c             	sub    $0xc,%esp
  8000fc:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000ff:	b8 03 00 00 00       	mov    $0x3,%eax
  800104:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800109:	89 f9                	mov    %edi,%ecx
  80010b:	89 fb                	mov    %edi,%ebx
  80010d:	89 fe                	mov    %edi,%esi
  80010f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800111:	85 c0                	test   %eax,%eax
  800113:	7e 17                	jle    80012c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	50                   	push   %eax
  800119:	6a 03                	push   $0x3
  80011b:	68 ca 0f 80 00       	push   $0x800fca
  800120:	6a 23                	push   $0x23
  800122:	68 e7 0f 80 00       	push   $0x800fe7
  800127:	e8 64 02 00 00       	call   800390 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012f:	5b                   	pop    %ebx
  800130:	5e                   	pop    %esi
  800131:	5f                   	pop    %edi
  800132:	c9                   	leave  
  800133:	c3                   	ret    

00800134 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	57                   	push   %edi
  800138:	56                   	push   %esi
  800139:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80013a:	b8 02 00 00 00       	mov    $0x2,%eax
  80013f:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800144:	89 fa                	mov    %edi,%edx
  800146:	89 f9                	mov    %edi,%ecx
  800148:	89 fb                	mov    %edi,%ebx
  80014a:	89 fe                	mov    %edi,%esi
  80014c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014e:	5b                   	pop    %ebx
  80014f:	5e                   	pop    %esi
  800150:	5f                   	pop    %edi
  800151:	c9                   	leave  
  800152:	c3                   	ret    

00800153 <sys_yield>:

void
sys_yield(void)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	57                   	push   %edi
  800157:	56                   	push   %esi
  800158:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800159:	b8 0b 00 00 00       	mov    $0xb,%eax
  80015e:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800163:	89 fa                	mov    %edi,%edx
  800165:	89 f9                	mov    %edi,%ecx
  800167:	89 fb                	mov    %edi,%ebx
  800169:	89 fe                	mov    %edi,%esi
  80016b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80016d:	5b                   	pop    %ebx
  80016e:	5e                   	pop    %esi
  80016f:	5f                   	pop    %edi
  800170:	c9                   	leave  
  800171:	c3                   	ret    

00800172 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800172:	55                   	push   %ebp
  800173:	89 e5                	mov    %esp,%ebp
  800175:	57                   	push   %edi
  800176:	56                   	push   %esi
  800177:	53                   	push   %ebx
  800178:	83 ec 0c             	sub    $0xc,%esp
  80017b:	8b 55 08             	mov    0x8(%ebp),%edx
  80017e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800181:	8b 5d 10             	mov    0x10(%ebp),%ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800184:	b8 04 00 00 00       	mov    $0x4,%eax
  800189:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018e:	89 fe                	mov    %edi,%esi
  800190:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800192:	85 c0                	test   %eax,%eax
  800194:	7e 17                	jle    8001ad <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800196:	83 ec 0c             	sub    $0xc,%esp
  800199:	50                   	push   %eax
  80019a:	6a 04                	push   $0x4
  80019c:	68 ca 0f 80 00       	push   $0x800fca
  8001a1:	6a 23                	push   $0x23
  8001a3:	68 e7 0f 80 00       	push   $0x800fe7
  8001a8:	e8 e3 01 00 00       	call   800390 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b0:	5b                   	pop    %ebx
  8001b1:	5e                   	pop    %esi
  8001b2:	5f                   	pop    %edi
  8001b3:	c9                   	leave  
  8001b4:	c3                   	ret    

008001b5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b5:	55                   	push   %ebp
  8001b6:	89 e5                	mov    %esp,%ebp
  8001b8:	57                   	push   %edi
  8001b9:	56                   	push   %esi
  8001ba:	53                   	push   %ebx
  8001bb:	83 ec 0c             	sub    $0xc,%esp
  8001be:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001ca:	8b 75 18             	mov    0x18(%ebp),%esi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8001cd:	b8 05 00 00 00       	mov    $0x5,%eax
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001d2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001d4:	85 c0                	test   %eax,%eax
  8001d6:	7e 17                	jle    8001ef <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d8:	83 ec 0c             	sub    $0xc,%esp
  8001db:	50                   	push   %eax
  8001dc:	6a 05                	push   $0x5
  8001de:	68 ca 0f 80 00       	push   $0x800fca
  8001e3:	6a 23                	push   $0x23
  8001e5:	68 e7 0f 80 00       	push   $0x800fe7
  8001ea:	e8 a1 01 00 00       	call   800390 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f2:	5b                   	pop    %ebx
  8001f3:	5e                   	pop    %esi
  8001f4:	5f                   	pop    %edi
  8001f5:	c9                   	leave  
  8001f6:	c3                   	ret    

008001f7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f7:	55                   	push   %ebp
  8001f8:	89 e5                	mov    %esp,%ebp
  8001fa:	57                   	push   %edi
  8001fb:	56                   	push   %esi
  8001fc:	53                   	push   %ebx
  8001fd:	83 ec 0c             	sub    $0xc,%esp
  800200:	8b 55 08             	mov    0x8(%ebp),%edx
  800203:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800206:	b8 06 00 00 00       	mov    $0x6,%eax
  80020b:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800210:	89 fb                	mov    %edi,%ebx
  800212:	89 fe                	mov    %edi,%esi
  800214:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800216:	85 c0                	test   %eax,%eax
  800218:	7e 17                	jle    800231 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80021a:	83 ec 0c             	sub    $0xc,%esp
  80021d:	50                   	push   %eax
  80021e:	6a 06                	push   $0x6
  800220:	68 ca 0f 80 00       	push   $0x800fca
  800225:	6a 23                	push   $0x23
  800227:	68 e7 0f 80 00       	push   $0x800fe7
  80022c:	e8 5f 01 00 00       	call   800390 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800231:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800234:	5b                   	pop    %ebx
  800235:	5e                   	pop    %esi
  800236:	5f                   	pop    %edi
  800237:	c9                   	leave  
  800238:	c3                   	ret    

00800239 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800239:	55                   	push   %ebp
  80023a:	89 e5                	mov    %esp,%ebp
  80023c:	57                   	push   %edi
  80023d:	56                   	push   %esi
  80023e:	53                   	push   %ebx
  80023f:	83 ec 0c             	sub    $0xc,%esp
  800242:	8b 55 08             	mov    0x8(%ebp),%edx
  800245:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800248:	b8 08 00 00 00       	mov    $0x8,%eax
  80024d:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800252:	89 fb                	mov    %edi,%ebx
  800254:	89 fe                	mov    %edi,%esi
  800256:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800258:	85 c0                	test   %eax,%eax
  80025a:	7e 17                	jle    800273 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80025c:	83 ec 0c             	sub    $0xc,%esp
  80025f:	50                   	push   %eax
  800260:	6a 08                	push   $0x8
  800262:	68 ca 0f 80 00       	push   $0x800fca
  800267:	6a 23                	push   $0x23
  800269:	68 e7 0f 80 00       	push   $0x800fe7
  80026e:	e8 1d 01 00 00       	call   800390 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800273:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800276:	5b                   	pop    %ebx
  800277:	5e                   	pop    %esi
  800278:	5f                   	pop    %edi
  800279:	c9                   	leave  
  80027a:	c3                   	ret    

0080027b <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
  80027e:	57                   	push   %edi
  80027f:	56                   	push   %esi
  800280:	53                   	push   %ebx
  800281:	83 ec 0c             	sub    $0xc,%esp
  800284:	8b 55 08             	mov    0x8(%ebp),%edx
  800287:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80028a:	b8 09 00 00 00       	mov    $0x9,%eax
  80028f:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800294:	89 fb                	mov    %edi,%ebx
  800296:	89 fe                	mov    %edi,%esi
  800298:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80029a:	85 c0                	test   %eax,%eax
  80029c:	7e 17                	jle    8002b5 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029e:	83 ec 0c             	sub    $0xc,%esp
  8002a1:	50                   	push   %eax
  8002a2:	6a 09                	push   $0x9
  8002a4:	68 ca 0f 80 00       	push   $0x800fca
  8002a9:	6a 23                	push   $0x23
  8002ab:	68 e7 0f 80 00       	push   $0x800fe7
  8002b0:	e8 db 00 00 00       	call   800390 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b8:	5b                   	pop    %ebx
  8002b9:	5e                   	pop    %esi
  8002ba:	5f                   	pop    %edi
  8002bb:	c9                   	leave  
  8002bc:	c3                   	ret    

008002bd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	57                   	push   %edi
  8002c1:	56                   	push   %esi
  8002c2:	53                   	push   %ebx
  8002c3:	83 ec 0c             	sub    $0xc,%esp
  8002c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8002cc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002d1:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d6:	89 fb                	mov    %edi,%ebx
  8002d8:	89 fe                	mov    %edi,%esi
  8002da:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002dc:	85 c0                	test   %eax,%eax
  8002de:	7e 17                	jle    8002f7 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e0:	83 ec 0c             	sub    $0xc,%esp
  8002e3:	50                   	push   %eax
  8002e4:	6a 0a                	push   $0xa
  8002e6:	68 ca 0f 80 00       	push   $0x800fca
  8002eb:	6a 23                	push   $0x23
  8002ed:	68 e7 0f 80 00       	push   $0x800fe7
  8002f2:	e8 99 00 00 00       	call   800390 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fa:	5b                   	pop    %ebx
  8002fb:	5e                   	pop    %esi
  8002fc:	5f                   	pop    %edi
  8002fd:	c9                   	leave  
  8002fe:	c3                   	ret    

008002ff <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002ff:	55                   	push   %ebp
  800300:	89 e5                	mov    %esp,%ebp
  800302:	57                   	push   %edi
  800303:	56                   	push   %esi
  800304:	53                   	push   %ebx
  800305:	8b 55 08             	mov    0x8(%ebp),%edx
  800308:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80030b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80030e:	8b 7d 14             	mov    0x14(%ebp),%edi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800311:	b8 0c 00 00 00       	mov    $0xc,%eax
  800316:	be 00 00 00 00       	mov    $0x0,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80031d:	5b                   	pop    %ebx
  80031e:	5e                   	pop    %esi
  80031f:	5f                   	pop    %edi
  800320:	c9                   	leave  
  800321:	c3                   	ret    

00800322 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800322:	55                   	push   %ebp
  800323:	89 e5                	mov    %esp,%ebp
  800325:	57                   	push   %edi
  800326:	56                   	push   %esi
  800327:	53                   	push   %ebx
  800328:	83 ec 0c             	sub    $0xc,%esp
  80032b:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80032e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800333:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800338:	89 f9                	mov    %edi,%ecx
  80033a:	89 fb                	mov    %edi,%ebx
  80033c:	89 fe                	mov    %edi,%esi
  80033e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800340:	85 c0                	test   %eax,%eax
  800342:	7e 17                	jle    80035b <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800344:	83 ec 0c             	sub    $0xc,%esp
  800347:	50                   	push   %eax
  800348:	6a 0d                	push   $0xd
  80034a:	68 ca 0f 80 00       	push   $0x800fca
  80034f:	6a 23                	push   $0x23
  800351:	68 e7 0f 80 00       	push   $0x800fe7
  800356:	e8 35 00 00 00       	call   800390 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80035b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80035e:	5b                   	pop    %ebx
  80035f:	5e                   	pop    %esi
  800360:	5f                   	pop    %edi
  800361:	c9                   	leave  
  800362:	c3                   	ret    
	...

00800364 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTrapframe
  800364:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800365:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80036a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80036c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx
  80036f:	89 e3                	mov    %esp,%ebx

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// trap-time esp
	movl 48(%esp), %ecx
  800371:	8b 4c 24 30          	mov    0x30(%esp),%ecx
	// trap-time eip
	movl 40(%esp), %edx 
  800375:	8b 54 24 28          	mov    0x28(%esp),%edx
	// switch to trap-time esp 
	movl %ecx, %esp 
  800379:	89 cc                	mov    %ecx,%esp
	// push trap-time eip to trap-time stack 
	pushl %edx 
  80037b:	52                   	push   %edx
	// return to user exception stack 
	movl %ebx, %esp 
  80037c:	89 dc                	mov    %ebx,%esp
	// update the trap-time esp stored in exception stack(because of pushed eip
	subl $4, %ecx
  80037e:	83 e9 04             	sub    $0x4,%ecx
	movl %ecx, 48(%esp)
  800381:	89 4c 24 30          	mov    %ecx,0x30(%esp)
	// restore general registars, ignoring fault_va & err
	addl $8, %esp
  800385:	83 c4 08             	add    $0x8,%esp
	popal
  800388:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	// skipping trap-time eip 
	addl $4, %esp
  800389:	83 c4 04             	add    $0x4,%esp
	// restore eflags
	popfl
  80038c:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80038d:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	ret
  80038e:	c3                   	ret    
	...

00800390 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	53                   	push   %ebx
  800394:	83 ec 10             	sub    $0x10,%esp
	va_list ap;

	va_start(ap, fmt);
  800397:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80039a:	ff 75 0c             	pushl  0xc(%ebp)
  80039d:	ff 75 08             	pushl  0x8(%ebp)
  8003a0:	ff 35 00 20 80 00    	pushl  0x802000
  8003a6:	83 ec 08             	sub    $0x8,%esp
  8003a9:	e8 86 fd ff ff       	call   800134 <sys_getenvid>
  8003ae:	83 c4 08             	add    $0x8,%esp
  8003b1:	50                   	push   %eax
  8003b2:	68 f8 0f 80 00       	push   $0x800ff8
  8003b7:	e8 b0 00 00 00       	call   80046c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003bc:	83 c4 18             	add    $0x18,%esp
  8003bf:	53                   	push   %ebx
  8003c0:	ff 75 10             	pushl  0x10(%ebp)
  8003c3:	e8 53 00 00 00       	call   80041b <vcprintf>
	cprintf("\n");
  8003c8:	c7 04 24 1b 10 80 00 	movl   $0x80101b,(%esp)
  8003cf:	e8 98 00 00 00       	call   80046c <cprintf>

	// Cause a breakpoint exception
	while (1)
  8003d4:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  8003d7:	cc                   	int3   
  8003d8:	eb fd                	jmp    8003d7 <_panic+0x47>
	...

008003dc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003dc:	55                   	push   %ebp
  8003dd:	89 e5                	mov    %esp,%ebp
  8003df:	53                   	push   %ebx
  8003e0:	83 ec 04             	sub    $0x4,%esp
  8003e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003e6:	8b 03                	mov    (%ebx),%eax
  8003e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8003eb:	88 54 18 08          	mov    %dl,0x8(%eax,%ebx,1)
  8003ef:	40                   	inc    %eax
  8003f0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8003f2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003f7:	75 1a                	jne    800413 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8003f9:	83 ec 08             	sub    $0x8,%esp
  8003fc:	68 ff 00 00 00       	push   $0xff
  800401:	8d 43 08             	lea    0x8(%ebx),%eax
  800404:	50                   	push   %eax
  800405:	e8 a6 fc ff ff       	call   8000b0 <sys_cputs>
		b->idx = 0;
  80040a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800410:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800413:	ff 43 04             	incl   0x4(%ebx)
}
  800416:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800419:	c9                   	leave  
  80041a:	c3                   	ret    

0080041b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80041b:	55                   	push   %ebp
  80041c:	89 e5                	mov    %esp,%ebp
  80041e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800424:	c7 85 e8 fe ff ff 00 	movl   $0x0,-0x118(%ebp)
  80042b:	00 00 00 
	b.cnt = 0;
  80042e:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  800435:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800438:	ff 75 0c             	pushl  0xc(%ebp)
  80043b:	ff 75 08             	pushl  0x8(%ebp)
  80043e:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800444:	50                   	push   %eax
  800445:	68 dc 03 80 00       	push   $0x8003dc
  80044a:	e8 49 01 00 00       	call   800598 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80044f:	83 c4 08             	add    $0x8,%esp
  800452:	ff b5 e8 fe ff ff    	pushl  -0x118(%ebp)
  800458:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80045e:	50                   	push   %eax
  80045f:	e8 4c fc ff ff       	call   8000b0 <sys_cputs>

	return b.cnt;
  800464:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
}
  80046a:	c9                   	leave  
  80046b:	c3                   	ret    

0080046c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80046c:	55                   	push   %ebp
  80046d:	89 e5                	mov    %esp,%ebp
  80046f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800472:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800475:	50                   	push   %eax
  800476:	ff 75 08             	pushl  0x8(%ebp)
  800479:	e8 9d ff ff ff       	call   80041b <vcprintf>
	va_end(ap);

	return cnt;
}
  80047e:	c9                   	leave  
  80047f:	c3                   	ret    

00800480 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800480:	55                   	push   %ebp
  800481:	89 e5                	mov    %esp,%ebp
  800483:	57                   	push   %edi
  800484:	56                   	push   %esi
  800485:	53                   	push   %ebx
  800486:	83 ec 0c             	sub    $0xc,%esp
  800489:	8b 75 10             	mov    0x10(%ebp),%esi
  80048c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80048f:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800492:	8b 45 18             	mov    0x18(%ebp),%eax
  800495:	ba 00 00 00 00       	mov    $0x0,%edx
  80049a:	39 fa                	cmp    %edi,%edx
  80049c:	77 39                	ja     8004d7 <printnum+0x57>
  80049e:	72 04                	jb     8004a4 <printnum+0x24>
  8004a0:	39 f0                	cmp    %esi,%eax
  8004a2:	77 33                	ja     8004d7 <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004a4:	83 ec 04             	sub    $0x4,%esp
  8004a7:	ff 75 20             	pushl  0x20(%ebp)
  8004aa:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8004ad:	50                   	push   %eax
  8004ae:	ff 75 18             	pushl  0x18(%ebp)
  8004b1:	8b 45 18             	mov    0x18(%ebp),%eax
  8004b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8004b9:	52                   	push   %edx
  8004ba:	50                   	push   %eax
  8004bb:	57                   	push   %edi
  8004bc:	56                   	push   %esi
  8004bd:	e8 2e 08 00 00       	call   800cf0 <__udivdi3>
  8004c2:	83 c4 10             	add    $0x10,%esp
  8004c5:	52                   	push   %edx
  8004c6:	50                   	push   %eax
  8004c7:	ff 75 0c             	pushl  0xc(%ebp)
  8004ca:	ff 75 08             	pushl  0x8(%ebp)
  8004cd:	e8 ae ff ff ff       	call   800480 <printnum>
  8004d2:	83 c4 20             	add    $0x20,%esp
  8004d5:	eb 19                	jmp    8004f0 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004d7:	4b                   	dec    %ebx
  8004d8:	85 db                	test   %ebx,%ebx
  8004da:	7e 14                	jle    8004f0 <printnum+0x70>
  8004dc:	83 ec 08             	sub    $0x8,%esp
  8004df:	ff 75 0c             	pushl  0xc(%ebp)
  8004e2:	ff 75 20             	pushl  0x20(%ebp)
  8004e5:	ff 55 08             	call   *0x8(%ebp)
  8004e8:	83 c4 10             	add    $0x10,%esp
  8004eb:	4b                   	dec    %ebx
  8004ec:	85 db                	test   %ebx,%ebx
  8004ee:	7f ec                	jg     8004dc <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004f0:	83 ec 08             	sub    $0x8,%esp
  8004f3:	ff 75 0c             	pushl  0xc(%ebp)
  8004f6:	8b 45 18             	mov    0x18(%ebp),%eax
  8004f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004fe:	83 ec 04             	sub    $0x4,%esp
  800501:	52                   	push   %edx
  800502:	50                   	push   %eax
  800503:	57                   	push   %edi
  800504:	56                   	push   %esi
  800505:	e8 f2 08 00 00       	call   800dfc <__umoddi3>
  80050a:	83 c4 14             	add    $0x14,%esp
  80050d:	0f be 80 2f 11 80 00 	movsbl 0x80112f(%eax),%eax
  800514:	50                   	push   %eax
  800515:	ff 55 08             	call   *0x8(%ebp)
}
  800518:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80051b:	5b                   	pop    %ebx
  80051c:	5e                   	pop    %esi
  80051d:	5f                   	pop    %edi
  80051e:	c9                   	leave  
  80051f:	c3                   	ret    

00800520 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800520:	55                   	push   %ebp
  800521:	89 e5                	mov    %esp,%ebp
  800523:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800526:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800529:	83 f8 01             	cmp    $0x1,%eax
  80052c:	7e 0e                	jle    80053c <getuint+0x1c>
		return va_arg(*ap, unsigned long long);
  80052e:	8b 11                	mov    (%ecx),%edx
  800530:	8d 42 08             	lea    0x8(%edx),%eax
  800533:	89 01                	mov    %eax,(%ecx)
  800535:	8b 02                	mov    (%edx),%eax
  800537:	8b 52 04             	mov    0x4(%edx),%edx
  80053a:	eb 22                	jmp    80055e <getuint+0x3e>
	else if (lflag)
  80053c:	85 c0                	test   %eax,%eax
  80053e:	74 10                	je     800550 <getuint+0x30>
		return va_arg(*ap, unsigned long);
  800540:	8b 11                	mov    (%ecx),%edx
  800542:	8d 42 04             	lea    0x4(%edx),%eax
  800545:	89 01                	mov    %eax,(%ecx)
  800547:	8b 02                	mov    (%edx),%eax
  800549:	ba 00 00 00 00       	mov    $0x0,%edx
  80054e:	eb 0e                	jmp    80055e <getuint+0x3e>
	else
		return va_arg(*ap, unsigned int);
  800550:	8b 11                	mov    (%ecx),%edx
  800552:	8d 42 04             	lea    0x4(%edx),%eax
  800555:	89 01                	mov    %eax,(%ecx)
  800557:	8b 02                	mov    (%edx),%eax
  800559:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80055e:	c9                   	leave  
  80055f:	c3                   	ret    

00800560 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800560:	55                   	push   %ebp
  800561:	89 e5                	mov    %esp,%ebp
  800563:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800566:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800569:	83 f8 01             	cmp    $0x1,%eax
  80056c:	7e 0e                	jle    80057c <getint+0x1c>
		return va_arg(*ap, long long);
  80056e:	8b 11                	mov    (%ecx),%edx
  800570:	8d 42 08             	lea    0x8(%edx),%eax
  800573:	89 01                	mov    %eax,(%ecx)
  800575:	8b 02                	mov    (%edx),%eax
  800577:	8b 52 04             	mov    0x4(%edx),%edx
  80057a:	eb 1a                	jmp    800596 <getint+0x36>
	else if (lflag)
  80057c:	85 c0                	test   %eax,%eax
  80057e:	74 0c                	je     80058c <getint+0x2c>
		return va_arg(*ap, long);
  800580:	8b 01                	mov    (%ecx),%eax
  800582:	8d 50 04             	lea    0x4(%eax),%edx
  800585:	89 11                	mov    %edx,(%ecx)
  800587:	8b 00                	mov    (%eax),%eax
  800589:	99                   	cltd   
  80058a:	eb 0a                	jmp    800596 <getint+0x36>
	else
		return va_arg(*ap, int);
  80058c:	8b 01                	mov    (%ecx),%eax
  80058e:	8d 50 04             	lea    0x4(%eax),%edx
  800591:	89 11                	mov    %edx,(%ecx)
  800593:	8b 00                	mov    (%eax),%eax
  800595:	99                   	cltd   
}
  800596:	c9                   	leave  
  800597:	c3                   	ret    

00800598 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800598:	55                   	push   %ebp
  800599:	89 e5                	mov    %esp,%ebp
  80059b:	57                   	push   %edi
  80059c:	56                   	push   %esi
  80059d:	53                   	push   %ebx
  80059e:	83 ec 1c             	sub    $0x1c,%esp
  8005a1:	8b 5d 10             	mov    0x10(%ebp),%ebx

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
			putch(ch, putdat);
  8005a4:	0f b6 0b             	movzbl (%ebx),%ecx
  8005a7:	43                   	inc    %ebx
  8005a8:	83 f9 25             	cmp    $0x25,%ecx
  8005ab:	74 1e                	je     8005cb <vprintfmt+0x33>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8005ad:	85 c9                	test   %ecx,%ecx
  8005af:	0f 84 dc 02 00 00    	je     800891 <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  8005b5:	83 ec 08             	sub    $0x8,%esp
  8005b8:	ff 75 0c             	pushl  0xc(%ebp)
  8005bb:	51                   	push   %ecx
  8005bc:	ff 55 08             	call   *0x8(%ebp)
  8005bf:	83 c4 10             	add    $0x10,%esp
  8005c2:	0f b6 0b             	movzbl (%ebx),%ecx
  8005c5:	43                   	inc    %ebx
  8005c6:	83 f9 25             	cmp    $0x25,%ecx
  8005c9:	75 e2                	jne    8005ad <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  8005cb:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
		width = -1;
  8005cf:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
		precision = -1;
  8005d6:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  8005db:	bf 00 00 00 00       	mov    $0x0,%edi
		altflag = 0;
  8005e0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e7:	0f b6 0b             	movzbl (%ebx),%ecx
  8005ea:	8d 41 dd             	lea    -0x23(%ecx),%eax
  8005ed:	43                   	inc    %ebx
  8005ee:	83 f8 55             	cmp    $0x55,%eax
  8005f1:	0f 87 75 02 00 00    	ja     80086c <vprintfmt+0x2d4>
  8005f7:	ff 24 85 c0 11 80 00 	jmp    *0x8011c0(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  8005fe:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
			goto reswitch;
  800602:	eb e3                	jmp    8005e7 <vprintfmt+0x4f>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800604:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
			goto reswitch;
  800608:	eb dd                	jmp    8005e7 <vprintfmt+0x4f>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80060a:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  80060f:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  800612:	8d 74 41 d0          	lea    -0x30(%ecx,%eax,2),%esi
				ch = *fmt;
  800616:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  800619:	8d 41 d0             	lea    -0x30(%ecx),%eax
  80061c:	83 f8 09             	cmp    $0x9,%eax
  80061f:	77 28                	ja     800649 <vprintfmt+0xb1>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800621:	43                   	inc    %ebx
  800622:	eb eb                	jmp    80060f <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800624:	8b 55 14             	mov    0x14(%ebp),%edx
  800627:	8d 42 04             	lea    0x4(%edx),%eax
  80062a:	89 45 14             	mov    %eax,0x14(%ebp)
  80062d:	8b 32                	mov    (%edx),%esi
			goto process_precision;
  80062f:	eb 18                	jmp    800649 <vprintfmt+0xb1>

		case '.':
			if (width < 0)
  800631:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800635:	79 b0                	jns    8005e7 <vprintfmt+0x4f>
				width = 0;
  800637:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
			goto reswitch;
  80063e:	eb a7                	jmp    8005e7 <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  800640:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
			goto reswitch;
  800647:	eb 9e                	jmp    8005e7 <vprintfmt+0x4f>

		process_precision:
			if (width < 0)
  800649:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80064d:	79 98                	jns    8005e7 <vprintfmt+0x4f>
				width = precision, precision = -1;
  80064f:	89 75 f0             	mov    %esi,-0x10(%ebp)
  800652:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  800657:	eb 8e                	jmp    8005e7 <vprintfmt+0x4f>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800659:	47                   	inc    %edi
			goto reswitch;
  80065a:	eb 8b                	jmp    8005e7 <vprintfmt+0x4f>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80065c:	83 ec 08             	sub    $0x8,%esp
  80065f:	ff 75 0c             	pushl  0xc(%ebp)
  800662:	8b 55 14             	mov    0x14(%ebp),%edx
  800665:	8d 42 04             	lea    0x4(%edx),%eax
  800668:	89 45 14             	mov    %eax,0x14(%ebp)
  80066b:	ff 32                	pushl  (%edx)
  80066d:	ff 55 08             	call   *0x8(%ebp)
			break;
  800670:	83 c4 10             	add    $0x10,%esp
  800673:	e9 2c ff ff ff       	jmp    8005a4 <vprintfmt+0xc>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800678:	8b 55 14             	mov    0x14(%ebp),%edx
  80067b:	8d 42 04             	lea    0x4(%edx),%eax
  80067e:	89 45 14             	mov    %eax,0x14(%ebp)
  800681:	8b 02                	mov    (%edx),%eax
			if (err < 0)
  800683:	85 c0                	test   %eax,%eax
  800685:	79 02                	jns    800689 <vprintfmt+0xf1>
				err = -err;
  800687:	f7 d8                	neg    %eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800689:	83 f8 0f             	cmp    $0xf,%eax
  80068c:	7f 0b                	jg     800699 <vprintfmt+0x101>
  80068e:	8b 3c 85 80 11 80 00 	mov    0x801180(,%eax,4),%edi
  800695:	85 ff                	test   %edi,%edi
  800697:	75 19                	jne    8006b2 <vprintfmt+0x11a>
				printfmt(putch, putdat, "error %d", err);
  800699:	50                   	push   %eax
  80069a:	68 40 11 80 00       	push   $0x801140
  80069f:	ff 75 0c             	pushl  0xc(%ebp)
  8006a2:	ff 75 08             	pushl  0x8(%ebp)
  8006a5:	e8 ef 01 00 00       	call   800899 <printfmt>
  8006aa:	83 c4 10             	add    $0x10,%esp
  8006ad:	e9 f2 fe ff ff       	jmp    8005a4 <vprintfmt+0xc>
			else
				printfmt(putch, putdat, "%s", p);
  8006b2:	57                   	push   %edi
  8006b3:	68 49 11 80 00       	push   $0x801149
  8006b8:	ff 75 0c             	pushl  0xc(%ebp)
  8006bb:	ff 75 08             	pushl  0x8(%ebp)
  8006be:	e8 d6 01 00 00       	call   800899 <printfmt>
  8006c3:	83 c4 10             	add    $0x10,%esp
			break;
  8006c6:	e9 d9 fe ff ff       	jmp    8005a4 <vprintfmt+0xc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006cb:	8b 55 14             	mov    0x14(%ebp),%edx
  8006ce:	8d 42 04             	lea    0x4(%edx),%eax
  8006d1:	89 45 14             	mov    %eax,0x14(%ebp)
  8006d4:	8b 3a                	mov    (%edx),%edi
  8006d6:	85 ff                	test   %edi,%edi
  8006d8:	75 05                	jne    8006df <vprintfmt+0x147>
				p = "(null)";
  8006da:	bf 4c 11 80 00       	mov    $0x80114c,%edi
			if (width > 0 && padc != '-')
  8006df:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8006e3:	7e 3b                	jle    800720 <vprintfmt+0x188>
  8006e5:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  8006e9:	74 35                	je     800720 <vprintfmt+0x188>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006eb:	83 ec 08             	sub    $0x8,%esp
  8006ee:	56                   	push   %esi
  8006ef:	57                   	push   %edi
  8006f0:	e8 58 02 00 00       	call   80094d <strnlen>
  8006f5:	29 45 f0             	sub    %eax,-0x10(%ebp)
  8006f8:	83 c4 10             	add    $0x10,%esp
  8006fb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8006ff:	7e 1f                	jle    800720 <vprintfmt+0x188>
  800701:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  800705:	89 45 e4             	mov    %eax,-0x1c(%ebp)
					putch(padc, putdat);
  800708:	83 ec 08             	sub    $0x8,%esp
  80070b:	ff 75 0c             	pushl  0xc(%ebp)
  80070e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800711:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800714:	83 c4 10             	add    $0x10,%esp
  800717:	ff 4d f0             	decl   -0x10(%ebp)
  80071a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80071e:	7f e8                	jg     800708 <vprintfmt+0x170>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800720:	0f be 0f             	movsbl (%edi),%ecx
  800723:	47                   	inc    %edi
  800724:	85 c9                	test   %ecx,%ecx
  800726:	74 44                	je     80076c <vprintfmt+0x1d4>
  800728:	85 f6                	test   %esi,%esi
  80072a:	78 03                	js     80072f <vprintfmt+0x197>
  80072c:	4e                   	dec    %esi
  80072d:	78 3d                	js     80076c <vprintfmt+0x1d4>
				if (altflag && (ch < ' ' || ch > '~'))
  80072f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  800733:	74 18                	je     80074d <vprintfmt+0x1b5>
  800735:	8d 41 e0             	lea    -0x20(%ecx),%eax
  800738:	83 f8 5e             	cmp    $0x5e,%eax
  80073b:	76 10                	jbe    80074d <vprintfmt+0x1b5>
					putch('?', putdat);
  80073d:	83 ec 08             	sub    $0x8,%esp
  800740:	ff 75 0c             	pushl  0xc(%ebp)
  800743:	6a 3f                	push   $0x3f
  800745:	ff 55 08             	call   *0x8(%ebp)
  800748:	83 c4 10             	add    $0x10,%esp
  80074b:	eb 0d                	jmp    80075a <vprintfmt+0x1c2>
				else
					putch(ch, putdat);
  80074d:	83 ec 08             	sub    $0x8,%esp
  800750:	ff 75 0c             	pushl  0xc(%ebp)
  800753:	51                   	push   %ecx
  800754:	ff 55 08             	call   *0x8(%ebp)
  800757:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80075a:	ff 4d f0             	decl   -0x10(%ebp)
  80075d:	0f be 0f             	movsbl (%edi),%ecx
  800760:	47                   	inc    %edi
  800761:	85 c9                	test   %ecx,%ecx
  800763:	74 07                	je     80076c <vprintfmt+0x1d4>
  800765:	85 f6                	test   %esi,%esi
  800767:	78 c6                	js     80072f <vprintfmt+0x197>
  800769:	4e                   	dec    %esi
  80076a:	79 c3                	jns    80072f <vprintfmt+0x197>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80076c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800770:	0f 8e 2e fe ff ff    	jle    8005a4 <vprintfmt+0xc>
				putch(' ', putdat);
  800776:	83 ec 08             	sub    $0x8,%esp
  800779:	ff 75 0c             	pushl  0xc(%ebp)
  80077c:	6a 20                	push   $0x20
  80077e:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800781:	83 c4 10             	add    $0x10,%esp
  800784:	ff 4d f0             	decl   -0x10(%ebp)
  800787:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80078b:	7f e9                	jg     800776 <vprintfmt+0x1de>
				putch(' ', putdat);
			break;
  80078d:	e9 12 fe ff ff       	jmp    8005a4 <vprintfmt+0xc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800792:	57                   	push   %edi
  800793:	8d 45 14             	lea    0x14(%ebp),%eax
  800796:	50                   	push   %eax
  800797:	e8 c4 fd ff ff       	call   800560 <getint>
  80079c:	89 c6                	mov    %eax,%esi
  80079e:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  8007a0:	83 c4 08             	add    $0x8,%esp
  8007a3:	85 d2                	test   %edx,%edx
  8007a5:	79 15                	jns    8007bc <vprintfmt+0x224>
				putch('-', putdat);
  8007a7:	83 ec 08             	sub    $0x8,%esp
  8007aa:	ff 75 0c             	pushl  0xc(%ebp)
  8007ad:	6a 2d                	push   $0x2d
  8007af:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007b2:	f7 de                	neg    %esi
  8007b4:	83 d7 00             	adc    $0x0,%edi
  8007b7:	f7 df                	neg    %edi
  8007b9:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007bc:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8007c1:	eb 76                	jmp    800839 <vprintfmt+0x2a1>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007c3:	57                   	push   %edi
  8007c4:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c7:	50                   	push   %eax
  8007c8:	e8 53 fd ff ff       	call   800520 <getuint>
  8007cd:	89 c6                	mov    %eax,%esi
  8007cf:	89 d7                	mov    %edx,%edi
			base = 10;
  8007d1:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8007d6:	83 c4 08             	add    $0x8,%esp
  8007d9:	eb 5e                	jmp    800839 <vprintfmt+0x2a1>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8007db:	57                   	push   %edi
  8007dc:	8d 45 14             	lea    0x14(%ebp),%eax
  8007df:	50                   	push   %eax
  8007e0:	e8 3b fd ff ff       	call   800520 <getuint>
  8007e5:	89 c6                	mov    %eax,%esi
  8007e7:	89 d7                	mov    %edx,%edi
			base = 8;
  8007e9:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  8007ee:	83 c4 08             	add    $0x8,%esp
  8007f1:	eb 46                	jmp    800839 <vprintfmt+0x2a1>

		// pointer
		case 'p':
			putch('0', putdat);
  8007f3:	83 ec 08             	sub    $0x8,%esp
  8007f6:	ff 75 0c             	pushl  0xc(%ebp)
  8007f9:	6a 30                	push   $0x30
  8007fb:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007fe:	83 c4 08             	add    $0x8,%esp
  800801:	ff 75 0c             	pushl  0xc(%ebp)
  800804:	6a 78                	push   $0x78
  800806:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800809:	8b 55 14             	mov    0x14(%ebp),%edx
  80080c:	8d 42 04             	lea    0x4(%edx),%eax
  80080f:	89 45 14             	mov    %eax,0x14(%ebp)
  800812:	8b 32                	mov    (%edx),%esi
  800814:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800819:	ba 10 00 00 00       	mov    $0x10,%edx
			goto number;
  80081e:	83 c4 10             	add    $0x10,%esp
  800821:	eb 16                	jmp    800839 <vprintfmt+0x2a1>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800823:	57                   	push   %edi
  800824:	8d 45 14             	lea    0x14(%ebp),%eax
  800827:	50                   	push   %eax
  800828:	e8 f3 fc ff ff       	call   800520 <getuint>
  80082d:	89 c6                	mov    %eax,%esi
  80082f:	89 d7                	mov    %edx,%edi
			base = 16;
  800831:	ba 10 00 00 00       	mov    $0x10,%edx
  800836:	83 c4 08             	add    $0x8,%esp
		number:
			printnum(putch, putdat, num, base, width, padc);
  800839:	83 ec 04             	sub    $0x4,%esp
  80083c:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  800840:	50                   	push   %eax
  800841:	ff 75 f0             	pushl  -0x10(%ebp)
  800844:	52                   	push   %edx
  800845:	57                   	push   %edi
  800846:	56                   	push   %esi
  800847:	ff 75 0c             	pushl  0xc(%ebp)
  80084a:	ff 75 08             	pushl  0x8(%ebp)
  80084d:	e8 2e fc ff ff       	call   800480 <printnum>
			break;
  800852:	83 c4 20             	add    $0x20,%esp
  800855:	e9 4a fd ff ff       	jmp    8005a4 <vprintfmt+0xc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80085a:	83 ec 08             	sub    $0x8,%esp
  80085d:	ff 75 0c             	pushl  0xc(%ebp)
  800860:	51                   	push   %ecx
  800861:	ff 55 08             	call   *0x8(%ebp)
			break;
  800864:	83 c4 10             	add    $0x10,%esp
  800867:	e9 38 fd ff ff       	jmp    8005a4 <vprintfmt+0xc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80086c:	83 ec 08             	sub    $0x8,%esp
  80086f:	ff 75 0c             	pushl  0xc(%ebp)
  800872:	6a 25                	push   $0x25
  800874:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800877:	4b                   	dec    %ebx
  800878:	83 c4 10             	add    $0x10,%esp
  80087b:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80087f:	0f 84 1f fd ff ff    	je     8005a4 <vprintfmt+0xc>
  800885:	4b                   	dec    %ebx
  800886:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80088a:	75 f9                	jne    800885 <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  80088c:	e9 13 fd ff ff       	jmp    8005a4 <vprintfmt+0xc>
		}
	}
}
  800891:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800894:	5b                   	pop    %ebx
  800895:	5e                   	pop    %esi
  800896:	5f                   	pop    %edi
  800897:	c9                   	leave  
  800898:	c3                   	ret    

00800899 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80089f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8008a2:	50                   	push   %eax
  8008a3:	ff 75 10             	pushl  0x10(%ebp)
  8008a6:	ff 75 0c             	pushl  0xc(%ebp)
  8008a9:	ff 75 08             	pushl  0x8(%ebp)
  8008ac:	e8 e7 fc ff ff       	call   800598 <vprintfmt>
	va_end(ap);
}
  8008b1:	c9                   	leave  
  8008b2:	c3                   	ret    

008008b3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  8008b9:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  8008bc:	8b 0a                	mov    (%edx),%ecx
  8008be:	3b 4a 04             	cmp    0x4(%edx),%ecx
  8008c1:	73 07                	jae    8008ca <sprintputch+0x17>
		*b->buf++ = ch;
  8008c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c6:	88 01                	mov    %al,(%ecx)
  8008c8:	ff 02                	incl   (%edx)
}
  8008ca:	c9                   	leave  
  8008cb:	c3                   	ret    

008008cc <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	83 ec 18             	sub    $0x18,%esp
  8008d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8008d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008d8:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8008db:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
  8008df:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008e2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

	if (buf == NULL || n < 1)
  8008e9:	85 d2                	test   %edx,%edx
  8008eb:	74 04                	je     8008f1 <vsnprintf+0x25>
  8008ed:	85 c9                	test   %ecx,%ecx
  8008ef:	7f 07                	jg     8008f8 <vsnprintf+0x2c>
		return -E_INVAL;
  8008f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008f6:	eb 1d                	jmp    800915 <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008f8:	ff 75 14             	pushl  0x14(%ebp)
  8008fb:	ff 75 10             	pushl  0x10(%ebp)
  8008fe:	8d 45 e8             	lea    -0x18(%ebp),%eax
  800901:	50                   	push   %eax
  800902:	68 b3 08 80 00       	push   $0x8008b3
  800907:	e8 8c fc ff ff       	call   800598 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80090c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80090f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800912:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800915:	c9                   	leave  
  800916:	c3                   	ret    

00800917 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80091d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800920:	50                   	push   %eax
  800921:	ff 75 10             	pushl  0x10(%ebp)
  800924:	ff 75 0c             	pushl  0xc(%ebp)
  800927:	ff 75 08             	pushl  0x8(%ebp)
  80092a:	e8 9d ff ff ff       	call   8008cc <vsnprintf>
	va_end(ap);

	return rc;
}
  80092f:	c9                   	leave  
  800930:	c3                   	ret    
  800931:	00 00                	add    %al,(%eax)
	...

00800934 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80093a:	b8 00 00 00 00       	mov    $0x0,%eax
  80093f:	80 3a 00             	cmpb   $0x0,(%edx)
  800942:	74 07                	je     80094b <strlen+0x17>
		n++;
  800944:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800945:	42                   	inc    %edx
  800946:	80 3a 00             	cmpb   $0x0,(%edx)
  800949:	75 f9                	jne    800944 <strlen+0x10>
		n++;
	return n;
}
  80094b:	c9                   	leave  
  80094c:	c3                   	ret    

0080094d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800953:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800956:	b8 00 00 00 00       	mov    $0x0,%eax
  80095b:	85 d2                	test   %edx,%edx
  80095d:	74 0f                	je     80096e <strnlen+0x21>
  80095f:	80 39 00             	cmpb   $0x0,(%ecx)
  800962:	74 0a                	je     80096e <strnlen+0x21>
		n++;
  800964:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800965:	41                   	inc    %ecx
  800966:	4a                   	dec    %edx
  800967:	74 05                	je     80096e <strnlen+0x21>
  800969:	80 39 00             	cmpb   $0x0,(%ecx)
  80096c:	75 f6                	jne    800964 <strnlen+0x17>
		n++;
	return n;
}
  80096e:	c9                   	leave  
  80096f:	c3                   	ret    

00800970 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	53                   	push   %ebx
  800974:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800977:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  80097a:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  80097c:	8a 02                	mov    (%edx),%al
  80097e:	42                   	inc    %edx
  80097f:	88 01                	mov    %al,(%ecx)
  800981:	41                   	inc    %ecx
  800982:	84 c0                	test   %al,%al
  800984:	75 f6                	jne    80097c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800986:	89 d8                	mov    %ebx,%eax
  800988:	5b                   	pop    %ebx
  800989:	c9                   	leave  
  80098a:	c3                   	ret    

0080098b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	53                   	push   %ebx
  80098f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800992:	53                   	push   %ebx
  800993:	e8 9c ff ff ff       	call   800934 <strlen>
	strcpy(dst + len, src);
  800998:	ff 75 0c             	pushl  0xc(%ebp)
  80099b:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80099e:	50                   	push   %eax
  80099f:	e8 cc ff ff ff       	call   800970 <strcpy>
	return dst;
}
  8009a4:	89 d8                	mov    %ebx,%eax
  8009a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009a9:	c9                   	leave  
  8009aa:	c3                   	ret    

008009ab <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	57                   	push   %edi
  8009af:	56                   	push   %esi
  8009b0:	53                   	push   %ebx
  8009b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b7:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  8009ba:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  8009bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8009c1:	39 f3                	cmp    %esi,%ebx
  8009c3:	73 10                	jae    8009d5 <strncpy+0x2a>
		*dst++ = *src;
  8009c5:	8a 02                	mov    (%edx),%al
  8009c7:	88 01                	mov    %al,(%ecx)
  8009c9:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009ca:	80 3a 01             	cmpb   $0x1,(%edx)
  8009cd:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009d0:	43                   	inc    %ebx
  8009d1:	39 f3                	cmp    %esi,%ebx
  8009d3:	72 f0                	jb     8009c5 <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009d5:	89 f8                	mov    %edi,%eax
  8009d7:	5b                   	pop    %ebx
  8009d8:	5e                   	pop    %esi
  8009d9:	5f                   	pop    %edi
  8009da:	c9                   	leave  
  8009db:	c3                   	ret    

008009dc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	56                   	push   %esi
  8009e0:	53                   	push   %ebx
  8009e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009e7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  8009ea:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  8009ec:	85 d2                	test   %edx,%edx
  8009ee:	74 19                	je     800a09 <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009f0:	4a                   	dec    %edx
  8009f1:	74 13                	je     800a06 <strlcpy+0x2a>
  8009f3:	80 39 00             	cmpb   $0x0,(%ecx)
  8009f6:	74 0e                	je     800a06 <strlcpy+0x2a>
  8009f8:	8a 01                	mov    (%ecx),%al
  8009fa:	41                   	inc    %ecx
  8009fb:	88 03                	mov    %al,(%ebx)
  8009fd:	43                   	inc    %ebx
  8009fe:	4a                   	dec    %edx
  8009ff:	74 05                	je     800a06 <strlcpy+0x2a>
  800a01:	80 39 00             	cmpb   $0x0,(%ecx)
  800a04:	75 f2                	jne    8009f8 <strlcpy+0x1c>
		*dst = '\0';
  800a06:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  800a09:	89 d8                	mov    %ebx,%eax
  800a0b:	29 f0                	sub    %esi,%eax
}
  800a0d:	5b                   	pop    %ebx
  800a0e:	5e                   	pop    %esi
  800a0f:	c9                   	leave  
  800a10:	c3                   	ret    

00800a11 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	8b 55 08             	mov    0x8(%ebp),%edx
  800a17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
		p++, q++;
  800a1a:	80 3a 00             	cmpb   $0x0,(%edx)
  800a1d:	74 13                	je     800a32 <strcmp+0x21>
  800a1f:	8a 02                	mov    (%edx),%al
  800a21:	3a 01                	cmp    (%ecx),%al
  800a23:	75 0d                	jne    800a32 <strcmp+0x21>
  800a25:	42                   	inc    %edx
  800a26:	41                   	inc    %ecx
  800a27:	80 3a 00             	cmpb   $0x0,(%edx)
  800a2a:	74 06                	je     800a32 <strcmp+0x21>
  800a2c:	8a 02                	mov    (%edx),%al
  800a2e:	3a 01                	cmp    (%ecx),%al
  800a30:	74 f3                	je     800a25 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a32:	0f b6 02             	movzbl (%edx),%eax
  800a35:	0f b6 11             	movzbl (%ecx),%edx
  800a38:	29 d0                	sub    %edx,%eax
}
  800a3a:	c9                   	leave  
  800a3b:	c3                   	ret    

00800a3c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	53                   	push   %ebx
  800a40:	8b 55 08             	mov    0x8(%ebp),%edx
  800a43:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a46:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800a49:	85 c9                	test   %ecx,%ecx
  800a4b:	74 1f                	je     800a6c <strncmp+0x30>
  800a4d:	80 3a 00             	cmpb   $0x0,(%edx)
  800a50:	74 16                	je     800a68 <strncmp+0x2c>
  800a52:	8a 02                	mov    (%edx),%al
  800a54:	3a 03                	cmp    (%ebx),%al
  800a56:	75 10                	jne    800a68 <strncmp+0x2c>
  800a58:	42                   	inc    %edx
  800a59:	43                   	inc    %ebx
  800a5a:	49                   	dec    %ecx
  800a5b:	74 0f                	je     800a6c <strncmp+0x30>
  800a5d:	80 3a 00             	cmpb   $0x0,(%edx)
  800a60:	74 06                	je     800a68 <strncmp+0x2c>
  800a62:	8a 02                	mov    (%edx),%al
  800a64:	3a 03                	cmp    (%ebx),%al
  800a66:	74 f0                	je     800a58 <strncmp+0x1c>
	if (n == 0)
  800a68:	85 c9                	test   %ecx,%ecx
  800a6a:	75 07                	jne    800a73 <strncmp+0x37>
		return 0;
  800a6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a71:	eb 0a                	jmp    800a7d <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a73:	0f b6 12             	movzbl (%edx),%edx
  800a76:	0f b6 03             	movzbl (%ebx),%eax
  800a79:	29 c2                	sub    %eax,%edx
  800a7b:	89 d0                	mov    %edx,%eax
}
  800a7d:	5b                   	pop    %ebx
  800a7e:	c9                   	leave  
  800a7f:	c3                   	ret    

00800a80 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	8b 45 08             	mov    0x8(%ebp),%eax
  800a86:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800a89:	80 38 00             	cmpb   $0x0,(%eax)
  800a8c:	74 0a                	je     800a98 <strchr+0x18>
		if (*s == c)
  800a8e:	38 10                	cmp    %dl,(%eax)
  800a90:	74 0b                	je     800a9d <strchr+0x1d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a92:	40                   	inc    %eax
  800a93:	80 38 00             	cmpb   $0x0,(%eax)
  800a96:	75 f6                	jne    800a8e <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800a98:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a9d:	c9                   	leave  
  800a9e:	c3                   	ret    

00800a9f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa5:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800aa8:	80 38 00             	cmpb   $0x0,(%eax)
  800aab:	74 0a                	je     800ab7 <strfind+0x18>
		if (*s == c)
  800aad:	38 10                	cmp    %dl,(%eax)
  800aaf:	74 06                	je     800ab7 <strfind+0x18>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ab1:	40                   	inc    %eax
  800ab2:	80 38 00             	cmpb   $0x0,(%eax)
  800ab5:	75 f6                	jne    800aad <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
}
  800ab7:	c9                   	leave  
  800ab8:	c3                   	ret    

00800ab9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ab9:	55                   	push   %ebp
  800aba:	89 e5                	mov    %esp,%ebp
  800abc:	57                   	push   %edi
  800abd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ac0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
		return v;
  800ac3:	89 f8                	mov    %edi,%eax
void *
memset(void *v, int c, size_t n)
{
	char *p;

	if (n == 0)
  800ac5:	85 c9                	test   %ecx,%ecx
  800ac7:	74 40                	je     800b09 <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ac9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800acf:	75 30                	jne    800b01 <memset+0x48>
  800ad1:	f6 c1 03             	test   $0x3,%cl
  800ad4:	75 2b                	jne    800b01 <memset+0x48>
		c &= 0xFF;
  800ad6:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800add:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae0:	c1 e0 18             	shl    $0x18,%eax
  800ae3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae6:	c1 e2 10             	shl    $0x10,%edx
  800ae9:	09 d0                	or     %edx,%eax
  800aeb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aee:	c1 e2 08             	shl    $0x8,%edx
  800af1:	09 d0                	or     %edx,%eax
  800af3:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  800af6:	c1 e9 02             	shr    $0x2,%ecx
  800af9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afc:	fc                   	cld    
  800afd:	f3 ab                	rep stos %eax,%es:(%edi)
  800aff:	eb 06                	jmp    800b07 <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b01:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b04:	fc                   	cld    
  800b05:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800b07:	89 f8                	mov    %edi,%eax
}
  800b09:	5f                   	pop    %edi
  800b0a:	c9                   	leave  
  800b0b:	c3                   	ret    

00800b0c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	57                   	push   %edi
  800b10:	56                   	push   %esi
  800b11:	8b 45 08             	mov    0x8(%ebp),%eax
  800b14:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800b17:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800b1a:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800b1c:	39 c6                	cmp    %eax,%esi
  800b1e:	73 34                	jae    800b54 <memmove+0x48>
  800b20:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b23:	39 c2                	cmp    %eax,%edx
  800b25:	76 2d                	jbe    800b54 <memmove+0x48>
		s += n;
  800b27:	89 d6                	mov    %edx,%esi
		d += n;
  800b29:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b2c:	f6 c2 03             	test   $0x3,%dl
  800b2f:	75 1b                	jne    800b4c <memmove+0x40>
  800b31:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b37:	75 13                	jne    800b4c <memmove+0x40>
  800b39:	f6 c1 03             	test   $0x3,%cl
  800b3c:	75 0e                	jne    800b4c <memmove+0x40>
			asm volatile("std; rep movsl\n"
  800b3e:	83 ef 04             	sub    $0x4,%edi
  800b41:	83 ee 04             	sub    $0x4,%esi
  800b44:	c1 e9 02             	shr    $0x2,%ecx
  800b47:	fd                   	std    
  800b48:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b4a:	eb 05                	jmp    800b51 <memmove+0x45>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b4c:	4f                   	dec    %edi
  800b4d:	4e                   	dec    %esi
  800b4e:	fd                   	std    
  800b4f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b51:	fc                   	cld    
  800b52:	eb 20                	jmp    800b74 <memmove+0x68>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b54:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b5a:	75 15                	jne    800b71 <memmove+0x65>
  800b5c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b62:	75 0d                	jne    800b71 <memmove+0x65>
  800b64:	f6 c1 03             	test   $0x3,%cl
  800b67:	75 08                	jne    800b71 <memmove+0x65>
			asm volatile("cld; rep movsl\n"
  800b69:	c1 e9 02             	shr    $0x2,%ecx
  800b6c:	fc                   	cld    
  800b6d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b6f:	eb 03                	jmp    800b74 <memmove+0x68>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b71:	fc                   	cld    
  800b72:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b74:	5e                   	pop    %esi
  800b75:	5f                   	pop    %edi
  800b76:	c9                   	leave  
  800b77:	c3                   	ret    

00800b78 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b7b:	ff 75 10             	pushl  0x10(%ebp)
  800b7e:	ff 75 0c             	pushl  0xc(%ebp)
  800b81:	ff 75 08             	pushl  0x8(%ebp)
  800b84:	e8 83 ff ff ff       	call   800b0c <memmove>
}
  800b89:	c9                   	leave  
  800b8a:	c3                   	ret    

00800b8b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
  800b8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  800b92:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b95:	8b 55 10             	mov    0x10(%ebp),%edx
  800b98:	4a                   	dec    %edx
  800b99:	83 fa ff             	cmp    $0xffffffff,%edx
  800b9c:	74 1a                	je     800bb8 <memcmp+0x2d>
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  800b9e:	8a 01                	mov    (%ecx),%al
  800ba0:	3a 03                	cmp    (%ebx),%al
  800ba2:	74 0c                	je     800bb0 <memcmp+0x25>
			return (int) *s1 - (int) *s2;
  800ba4:	0f b6 d0             	movzbl %al,%edx
  800ba7:	0f b6 03             	movzbl (%ebx),%eax
  800baa:	29 c2                	sub    %eax,%edx
  800bac:	89 d0                	mov    %edx,%eax
  800bae:	eb 0d                	jmp    800bbd <memcmp+0x32>
		s1++, s2++;
  800bb0:	41                   	inc    %ecx
  800bb1:	43                   	inc    %ebx
  800bb2:	4a                   	dec    %edx
  800bb3:	83 fa ff             	cmp    $0xffffffff,%edx
  800bb6:	75 e6                	jne    800b9e <memcmp+0x13>
	}

	return 0;
  800bb8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bbd:	5b                   	pop    %ebx
  800bbe:	c9                   	leave  
  800bbf:	c3                   	ret    

00800bc0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bc9:	89 c2                	mov    %eax,%edx
  800bcb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bce:	39 d0                	cmp    %edx,%eax
  800bd0:	73 09                	jae    800bdb <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bd2:	38 08                	cmp    %cl,(%eax)
  800bd4:	74 05                	je     800bdb <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bd6:	40                   	inc    %eax
  800bd7:	39 d0                	cmp    %edx,%eax
  800bd9:	72 f7                	jb     800bd2 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bdb:	c9                   	leave  
  800bdc:	c3                   	ret    

00800bdd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	57                   	push   %edi
  800be1:	56                   	push   %esi
  800be2:	53                   	push   %ebx
  800be3:	8b 55 08             	mov    0x8(%ebp),%edx
  800be6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800be9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  800bec:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  800bf1:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  800bf6:	80 3a 20             	cmpb   $0x20,(%edx)
  800bf9:	74 05                	je     800c00 <strtol+0x23>
  800bfb:	80 3a 09             	cmpb   $0x9,(%edx)
  800bfe:	75 0b                	jne    800c0b <strtol+0x2e>
  800c00:	42                   	inc    %edx
  800c01:	80 3a 20             	cmpb   $0x20,(%edx)
  800c04:	74 fa                	je     800c00 <strtol+0x23>
  800c06:	80 3a 09             	cmpb   $0x9,(%edx)
  800c09:	74 f5                	je     800c00 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  800c0b:	80 3a 2b             	cmpb   $0x2b,(%edx)
  800c0e:	75 03                	jne    800c13 <strtol+0x36>
		s++;
  800c10:	42                   	inc    %edx
  800c11:	eb 0b                	jmp    800c1e <strtol+0x41>
	else if (*s == '-')
  800c13:	80 3a 2d             	cmpb   $0x2d,(%edx)
  800c16:	75 06                	jne    800c1e <strtol+0x41>
		s++, neg = 1;
  800c18:	42                   	inc    %edx
  800c19:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c1e:	85 c9                	test   %ecx,%ecx
  800c20:	74 05                	je     800c27 <strtol+0x4a>
  800c22:	83 f9 10             	cmp    $0x10,%ecx
  800c25:	75 15                	jne    800c3c <strtol+0x5f>
  800c27:	80 3a 30             	cmpb   $0x30,(%edx)
  800c2a:	75 10                	jne    800c3c <strtol+0x5f>
  800c2c:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c30:	75 0a                	jne    800c3c <strtol+0x5f>
		s += 2, base = 16;
  800c32:	83 c2 02             	add    $0x2,%edx
  800c35:	b9 10 00 00 00       	mov    $0x10,%ecx
  800c3a:	eb 14                	jmp    800c50 <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800c3c:	85 c9                	test   %ecx,%ecx
  800c3e:	75 10                	jne    800c50 <strtol+0x73>
  800c40:	80 3a 30             	cmpb   $0x30,(%edx)
  800c43:	75 05                	jne    800c4a <strtol+0x6d>
		s++, base = 8;
  800c45:	42                   	inc    %edx
  800c46:	b1 08                	mov    $0x8,%cl
  800c48:	eb 06                	jmp    800c50 <strtol+0x73>
	else if (base == 0)
  800c4a:	85 c9                	test   %ecx,%ecx
  800c4c:	75 02                	jne    800c50 <strtol+0x73>
		base = 10;
  800c4e:	b1 0a                	mov    $0xa,%cl

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c50:	8a 02                	mov    (%edx),%al
  800c52:	83 e8 30             	sub    $0x30,%eax
  800c55:	3c 09                	cmp    $0x9,%al
  800c57:	77 08                	ja     800c61 <strtol+0x84>
			dig = *s - '0';
  800c59:	0f be 02             	movsbl (%edx),%eax
  800c5c:	83 e8 30             	sub    $0x30,%eax
  800c5f:	eb 20                	jmp    800c81 <strtol+0xa4>
		else if (*s >= 'a' && *s <= 'z')
  800c61:	8a 02                	mov    (%edx),%al
  800c63:	83 e8 61             	sub    $0x61,%eax
  800c66:	3c 19                	cmp    $0x19,%al
  800c68:	77 08                	ja     800c72 <strtol+0x95>
			dig = *s - 'a' + 10;
  800c6a:	0f be 02             	movsbl (%edx),%eax
  800c6d:	83 e8 57             	sub    $0x57,%eax
  800c70:	eb 0f                	jmp    800c81 <strtol+0xa4>
		else if (*s >= 'A' && *s <= 'Z')
  800c72:	8a 02                	mov    (%edx),%al
  800c74:	83 e8 41             	sub    $0x41,%eax
  800c77:	3c 19                	cmp    $0x19,%al
  800c79:	77 12                	ja     800c8d <strtol+0xb0>
			dig = *s - 'A' + 10;
  800c7b:	0f be 02             	movsbl (%edx),%eax
  800c7e:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  800c81:	39 c8                	cmp    %ecx,%eax
  800c83:	7d 08                	jge    800c8d <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800c85:	42                   	inc    %edx
  800c86:	0f af d9             	imul   %ecx,%ebx
  800c89:	01 c3                	add    %eax,%ebx
  800c8b:	eb c3                	jmp    800c50 <strtol+0x73>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c8d:	85 f6                	test   %esi,%esi
  800c8f:	74 02                	je     800c93 <strtol+0xb6>
		*endptr = (char *) s;
  800c91:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800c93:	89 d8                	mov    %ebx,%eax
  800c95:	85 ff                	test   %edi,%edi
  800c97:	74 02                	je     800c9b <strtol+0xbe>
  800c99:	f7 d8                	neg    %eax
}
  800c9b:	5b                   	pop    %ebx
  800c9c:	5e                   	pop    %esi
  800c9d:	5f                   	pop    %edi
  800c9e:	c9                   	leave  
  800c9f:	c3                   	ret    

00800ca0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800ca6:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800cad:	75 35                	jne    800ce4 <set_pgfault_handler+0x44>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_W | PTE_U | PTE_P);
  800caf:	83 ec 04             	sub    $0x4,%esp
  800cb2:	6a 07                	push   $0x7
  800cb4:	68 00 f0 bf ee       	push   $0xeebff000
  800cb9:	83 ec 04             	sub    $0x4,%esp
  800cbc:	e8 73 f4 ff ff       	call   800134 <sys_getenvid>
  800cc1:	89 04 24             	mov    %eax,(%esp)
  800cc4:	e8 a9 f4 ff ff       	call   800172 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);		
  800cc9:	83 c4 08             	add    $0x8,%esp
  800ccc:	68 64 03 80 00       	push   $0x800364
  800cd1:	83 ec 04             	sub    $0x4,%esp
  800cd4:	e8 5b f4 ff ff       	call   800134 <sys_getenvid>
  800cd9:	89 04 24             	mov    %eax,(%esp)
  800cdc:	e8 dc f5 ff ff       	call   8002bd <sys_env_set_pgfault_upcall>
  800ce1:	83 c4 10             	add    $0x10,%esp
//		panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800ce4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce7:	a3 08 20 80 00       	mov    %eax,0x802008
//	cprintf("_pgfault_upcall: %08x\n", thisenv->env_pgfault_upcall);
//	cprintf("_pgfault_handler is %08x\n", _pgfault_handler);
}
  800cec:	c9                   	leave  
  800ced:	c3                   	ret    
	...

00800cf0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	57                   	push   %edi
  800cf4:	56                   	push   %esi
  800cf5:	83 ec 14             	sub    $0x14,%esp
  800cf8:	8b 55 14             	mov    0x14(%ebp),%edx
  800cfb:	8b 75 08             	mov    0x8(%ebp),%esi
  800cfe:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d01:	8b 45 10             	mov    0x10(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d04:	85 d2                	test   %edx,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800d06:	89 75 f0             	mov    %esi,-0x10(%ebp)
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800d09:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  d1 = dd.s.high;
  800d0c:	89 55 f4             	mov    %edx,-0xc(%ebp)
  n0 = nn.s.low;
  n1 = nn.s.high;
  800d0f:	89 fe                	mov    %edi,%esi

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d11:	75 11                	jne    800d24 <__udivdi3+0x34>
    {
      if (d0 > n1)
  800d13:	39 f8                	cmp    %edi,%eax
  800d15:	76 4d                	jbe    800d64 <__udivdi3+0x74>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d17:	89 fa                	mov    %edi,%edx
  800d19:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d1c:	f7 75 e4             	divl   -0x1c(%ebp)
  800d1f:	89 c7                	mov    %eax,%edi
  800d21:	eb 09                	jmp    800d2c <__udivdi3+0x3c>
  800d23:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d24:	39 7d f4             	cmp    %edi,-0xc(%ebp)
  800d27:	76 17                	jbe    800d40 <__udivdi3+0x50>
	{
	  /* 00 = nn / DD */

	  q0 = 0;
  800d29:	31 ff                	xor    %edi,%edi
  800d2b:	90                   	nop
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
		}

	      q1 = 0;
  800d2c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d33:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d36:	83 c4 14             	add    $0x14,%esp
  800d39:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d3a:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d3c:	5f                   	pop    %edi
  800d3d:	c9                   	leave  
  800d3e:	c3                   	ret    
  800d3f:	90                   	nop
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d40:	0f bd 45 f4          	bsr    -0xc(%ebp),%eax
	  if (bm == 0)
  800d44:	89 c7                	mov    %eax,%edi
  800d46:	83 f7 1f             	xor    $0x1f,%edi
  800d49:	75 4d                	jne    800d98 <__udivdi3+0xa8>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d4b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800d4e:	77 0a                	ja     800d5a <__udivdi3+0x6a>
  800d50:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
		}
	      else
		q0 = 0;
  800d53:	31 ff                	xor    %edi,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d55:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  800d58:	72 d2                	jb     800d2c <__udivdi3+0x3c>
		{
		  q0 = 1;
  800d5a:	bf 01 00 00 00       	mov    $0x1,%edi
  800d5f:	eb cb                	jmp    800d2c <__udivdi3+0x3c>
  800d61:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d64:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d67:	85 c0                	test   %eax,%eax
  800d69:	75 0e                	jne    800d79 <__udivdi3+0x89>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d6b:	b8 01 00 00 00       	mov    $0x1,%eax
  800d70:	31 c9                	xor    %ecx,%ecx
  800d72:	31 d2                	xor    %edx,%edx
  800d74:	f7 f1                	div    %ecx
  800d76:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d79:	89 f0                	mov    %esi,%eax
  800d7b:	31 d2                	xor    %edx,%edx
  800d7d:	f7 75 e4             	divl   -0x1c(%ebp)
  800d80:	89 45 ec             	mov    %eax,-0x14(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d83:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d86:	f7 75 e4             	divl   -0x1c(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d89:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d8c:	83 c4 14             	add    $0x14,%esp

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d8f:	89 c7                	mov    %eax,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d91:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d92:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d94:	5f                   	pop    %edi
  800d95:	c9                   	leave  
  800d96:	c3                   	ret    
  800d97:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d98:	b8 20 00 00 00       	mov    $0x20,%eax
  800d9d:	29 f8                	sub    %edi,%eax
  800d9f:	89 45 e8             	mov    %eax,-0x18(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  800da2:	89 f9                	mov    %edi,%ecx
  800da4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800da7:	d3 e2                	shl    %cl,%edx
  800da9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800dac:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800daf:	d3 e8                	shr    %cl,%eax
  800db1:	09 c2                	or     %eax,%edx
	      d0 = d0 << bm;
  800db3:	89 f9                	mov    %edi,%ecx
  800db5:	d3 65 e4             	shll   %cl,-0x1c(%ebp)
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800db8:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800dbb:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800dbe:	89 f2                	mov    %esi,%edx
  800dc0:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  800dc2:	89 f9                	mov    %edi,%ecx
  800dc4:	d3 e6                	shl    %cl,%esi
  800dc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dc9:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800dcc:	d3 e8                	shr    %cl,%eax
  800dce:	09 c6                	or     %eax,%esi
	      n0 = n0 << bm;
  800dd0:	89 f9                	mov    %edi,%ecx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800dd2:	89 f0                	mov    %esi,%eax
  800dd4:	f7 75 f4             	divl   -0xc(%ebp)
  800dd7:	89 d6                	mov    %edx,%esi
  800dd9:	89 c7                	mov    %eax,%edi

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800ddb:	d3 65 f0             	shll   %cl,-0x10(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800dde:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800de1:	f7 e7                	mul    %edi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800de3:	39 f2                	cmp    %esi,%edx
  800de5:	77 0f                	ja     800df6 <__udivdi3+0x106>
  800de7:	0f 85 3f ff ff ff    	jne    800d2c <__udivdi3+0x3c>
  800ded:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800df0:	0f 86 36 ff ff ff    	jbe    800d2c <__udivdi3+0x3c>
		{
		  q0--;
  800df6:	4f                   	dec    %edi
  800df7:	e9 30 ff ff ff       	jmp    800d2c <__udivdi3+0x3c>

00800dfc <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	57                   	push   %edi
  800e00:	56                   	push   %esi
  800e01:	83 ec 30             	sub    $0x30,%esp
  800e04:	8b 55 14             	mov    0x14(%ebp),%edx
  800e07:	8b 45 10             	mov    0x10(%ebp),%eax
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  800e0a:	89 d7                	mov    %edx,%edi
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  800e0c:	8d 4d f0             	lea    -0x10(%ebp),%ecx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800e0f:	89 c6                	mov    %eax,%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;
  800e11:	8b 55 0c             	mov    0xc(%ebp),%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800e14:	8b 45 08             	mov    0x8(%ebp),%eax
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e17:	85 ff                	test   %edi,%edi
  800e19:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800e20:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  800e27:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800e2a:	89 45 dc             	mov    %eax,-0x24(%ebp)
  n1 = nn.s.high;
  800e2d:	89 55 cc             	mov    %edx,-0x34(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e30:	75 3e                	jne    800e70 <__umoddi3+0x74>
    {
      if (d0 > n1)
  800e32:	39 d6                	cmp    %edx,%esi
  800e34:	0f 86 a2 00 00 00    	jbe    800edc <__umoddi3+0xe0>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e3a:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  800e3c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800e3f:	85 c9                	test   %ecx,%ecx

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e41:	89 55 dc             	mov    %edx,-0x24(%ebp)

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  800e44:	74 1b                	je     800e61 <__umoddi3+0x65>
	{
	  rr.s.low = n0;
  800e46:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800e49:	89 45 e0             	mov    %eax,-0x20(%ebp)
	  rr.s.high = 0;
  800e4c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800e53:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e56:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800e59:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800e5c:	89 10                	mov    %edx,(%eax)
  800e5e:	89 48 04             	mov    %ecx,0x4(%eax)
  800e61:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e64:	8b 55 f4             	mov    -0xc(%ebp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e67:	83 c4 30             	add    $0x30,%esp
  800e6a:	5e                   	pop    %esi
  800e6b:	5f                   	pop    %edi
  800e6c:	c9                   	leave  
  800e6d:	c3                   	ret    
  800e6e:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e70:	3b 7d cc             	cmp    -0x34(%ebp),%edi
  800e73:	76 1f                	jbe    800e94 <__umoddi3+0x98>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800e75:	8b 55 08             	mov    0x8(%ebp),%edx
	      rr.s.high = n1;
  800e78:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800e7b:	89 55 e0             	mov    %edx,-0x20(%ebp)
	      rr.s.high = n1;
  800e7e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	      *rp = rr.ll;
  800e81:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e84:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800e87:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800e8a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e8d:	83 c4 30             	add    $0x30,%esp
  800e90:	5e                   	pop    %esi
  800e91:	5f                   	pop    %edi
  800e92:	c9                   	leave  
  800e93:	c3                   	ret    
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e94:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800e97:	83 f0 1f             	xor    $0x1f,%eax
  800e9a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800e9d:	75 61                	jne    800f00 <__umoddi3+0x104>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e9f:	39 7d cc             	cmp    %edi,-0x34(%ebp)
  800ea2:	77 05                	ja     800ea9 <__umoddi3+0xad>
  800ea4:	39 75 dc             	cmp    %esi,-0x24(%ebp)
  800ea7:	72 10                	jb     800eb9 <__umoddi3+0xbd>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ea9:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800eac:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800eaf:	29 f0                	sub    %esi,%eax
  800eb1:	19 fa                	sbb    %edi,%edx
  800eb3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800eb6:	89 55 cc             	mov    %edx,-0x34(%ebp)
	      else
		q0 = 0;

	      q1 = 0;

	      if (rp != 0)
  800eb9:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800ebc:	85 d2                	test   %edx,%edx
  800ebe:	74 a1                	je     800e61 <__umoddi3+0x65>
		{
		  rr.s.low = n0;
  800ec0:	8b 45 dc             	mov    -0x24(%ebp),%eax
		  rr.s.high = n1;
  800ec3:	8b 55 cc             	mov    -0x34(%ebp),%edx

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  800ec6:	89 45 e0             	mov    %eax,-0x20(%ebp)
		  rr.s.high = n1;
  800ec9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		  *rp = rr.ll;
  800ecc:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800ecf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ed2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800ed5:	89 01                	mov    %eax,(%ecx)
  800ed7:	89 51 04             	mov    %edx,0x4(%ecx)
  800eda:	eb 85                	jmp    800e61 <__umoddi3+0x65>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800edc:	85 f6                	test   %esi,%esi
  800ede:	75 0b                	jne    800eeb <__umoddi3+0xef>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800ee0:	b8 01 00 00 00       	mov    $0x1,%eax
  800ee5:	31 d2                	xor    %edx,%edx
  800ee7:	f7 f6                	div    %esi
  800ee9:	89 c6                	mov    %eax,%esi

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800eeb:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800eee:	89 fa                	mov    %edi,%edx
  800ef0:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ef2:	8b 45 dc             	mov    -0x24(%ebp),%eax
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800ef5:	89 55 cc             	mov    %edx,-0x34(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ef8:	f7 f6                	div    %esi
  800efa:	e9 3d ff ff ff       	jmp    800e3c <__umoddi3+0x40>
  800eff:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800f00:	b8 20 00 00 00       	mov    $0x20,%eax
  800f05:	2b 45 d4             	sub    -0x2c(%ebp),%eax
  800f08:	89 45 d8             	mov    %eax,-0x28(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  800f0b:	89 fa                	mov    %edi,%edx
  800f0d:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800f10:	d3 e2                	shl    %cl,%edx
  800f12:	89 f0                	mov    %esi,%eax
  800f14:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800f17:	d3 e8                	shr    %cl,%eax
	      d0 = d0 << bm;
  800f19:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800f1c:	d3 e6                	shl    %cl,%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f1e:	89 d7                	mov    %edx,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800f20:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800f23:	8b 55 cc             	mov    -0x34(%ebp),%edx
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f26:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800f28:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  800f2a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800f2d:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800f30:	d3 e0                	shl    %cl,%eax
  800f32:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800f35:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800f38:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800f3b:	d3 e8                	shr    %cl,%eax
  800f3d:	0b 45 cc             	or     -0x34(%ebp),%eax
  800f40:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n0 = n0 << bm;
  800f43:	8a 4d d4             	mov    -0x2c(%ebp),%cl

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f46:	f7 f7                	div    %edi
  800f48:	89 55 cc             	mov    %edx,-0x34(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800f4b:	d3 65 dc             	shll   %cl,-0x24(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800f4e:	f7 e6                	mul    %esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f50:	3b 55 cc             	cmp    -0x34(%ebp),%edx
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800f53:	89 45 c8             	mov    %eax,-0x38(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f56:	77 0a                	ja     800f62 <__umoddi3+0x166>
  800f58:	75 12                	jne    800f6c <__umoddi3+0x170>
  800f5a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800f5d:	39 45 c8             	cmp    %eax,-0x38(%ebp)
  800f60:	76 0a                	jbe    800f6c <__umoddi3+0x170>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f62:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800f65:	29 f1                	sub    %esi,%ecx
  800f67:	19 fa                	sbb    %edi,%edx
  800f69:	89 4d c8             	mov    %ecx,-0x38(%ebp)
		}

	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
  800f6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f6f:	85 c0                	test   %eax,%eax
  800f71:	0f 84 ea fe ff ff    	je     800e61 <__umoddi3+0x65>
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f77:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800f7a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800f7d:	2b 45 c8             	sub    -0x38(%ebp),%eax
  800f80:	19 d1                	sbb    %edx,%ecx
  800f82:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f85:	89 ca                	mov    %ecx,%edx
  800f87:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800f8a:	d3 e2                	shl    %cl,%edx
  800f8c:	8a 4d d4             	mov    -0x2c(%ebp),%cl
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f8f:	89 45 dc             	mov    %eax,-0x24(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f92:	d3 e8                	shr    %cl,%eax
  800f94:	09 c2                	or     %eax,%edx
		  rr.s.high = n1 >> bm;
  800f96:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800f99:	d3 e8                	shr    %cl,%eax

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f9b:	89 55 e0             	mov    %edx,-0x20(%ebp)
		  rr.s.high = n1 >> bm;
  800f9e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800fa1:	e9 ad fe ff ff       	jmp    800e53 <__umoddi3+0x57>
