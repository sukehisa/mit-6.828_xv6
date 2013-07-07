
obj/user/evilhello.debug:     file format elf32-i386


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
  80002c:	e8 17 00 00 00       	call   800048 <libmain>
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
  800037:	83 ec 10             	sub    $0x10,%esp
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  80003a:	6a 64                	push   $0x64
  80003c:	68 0c 00 10 f0       	push   $0xf010000c
  800041:	e8 5e 00 00 00       	call   8000a4 <sys_cputs>
}
  800046:	c9                   	leave  
  800047:	c3                   	ret    

00800048 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800048:	55                   	push   %ebp
  800049:	89 e5                	mov    %esp,%ebp
  80004b:	56                   	push   %esi
  80004c:	53                   	push   %ebx
  80004d:	8b 75 08             	mov    0x8(%ebp),%esi
  800050:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];	
  800053:	e8 d0 00 00 00       	call   800128 <sys_getenvid>
  800058:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005d:	89 c2                	mov    %eax,%edx
  80005f:	c1 e2 05             	shl    $0x5,%edx
  800062:	29 c2                	sub    %eax,%edx
  800064:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  80006b:	89 15 04 20 80 00    	mov    %edx,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800071:	85 f6                	test   %esi,%esi
  800073:	7e 07                	jle    80007c <libmain+0x34>
		binaryname = argv[0];
  800075:	8b 03                	mov    (%ebx),%eax
  800077:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80007c:	83 ec 08             	sub    $0x8,%esp
  80007f:	53                   	push   %ebx
  800080:	56                   	push   %esi
  800081:	e8 ae ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800086:	e8 09 00 00 00       	call   800094 <exit>
}
  80008b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008e:	5b                   	pop    %ebx
  80008f:	5e                   	pop    %esi
  800090:	c9                   	leave  
  800091:	c3                   	ret    
	...

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  80009a:	6a 00                	push   $0x0
  80009c:	e8 46 00 00 00       	call   8000e7 <sys_env_destroy>
}
  8000a1:	c9                   	leave  
  8000a2:	c3                   	ret    
	...

008000a4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	57                   	push   %edi
  8000a8:	56                   	push   %esi
  8000a9:	53                   	push   %ebx
  8000aa:	83 ec 04             	sub    $0x4,%esp
  8000ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000b3:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b8:	89 f8                	mov    %edi,%eax
  8000ba:	89 fb                	mov    %edi,%ebx
  8000bc:	89 fe                	mov    %edi,%esi
  8000be:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c0:	83 c4 04             	add    $0x4,%esp
  8000c3:	5b                   	pop    %ebx
  8000c4:	5e                   	pop    %esi
  8000c5:	5f                   	pop    %edi
  8000c6:	c9                   	leave  
  8000c7:	c3                   	ret    

008000c8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	57                   	push   %edi
  8000cc:	56                   	push   %esi
  8000cd:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000ce:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d3:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d8:	89 fa                	mov    %edi,%edx
  8000da:	89 f9                	mov    %edi,%ecx
  8000dc:	89 fb                	mov    %edi,%ebx
  8000de:	89 fe                	mov    %edi,%esi
  8000e0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e2:	5b                   	pop    %ebx
  8000e3:	5e                   	pop    %esi
  8000e4:	5f                   	pop    %edi
  8000e5:	c9                   	leave  
  8000e6:	c3                   	ret    

008000e7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	57                   	push   %edi
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
  8000ed:	83 ec 0c             	sub    $0xc,%esp
  8000f0:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000f3:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f8:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fd:	89 f9                	mov    %edi,%ecx
  8000ff:	89 fb                	mov    %edi,%ebx
  800101:	89 fe                	mov    %edi,%esi
  800103:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800105:	85 c0                	test   %eax,%eax
  800107:	7e 17                	jle    800120 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800109:	83 ec 0c             	sub    $0xc,%esp
  80010c:	50                   	push   %eax
  80010d:	6a 03                	push   $0x3
  80010f:	68 2a 0f 80 00       	push   $0x800f2a
  800114:	6a 23                	push   $0x23
  800116:	68 47 0f 80 00       	push   $0x800f47
  80011b:	e8 38 02 00 00       	call   800358 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800120:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5f                   	pop    %edi
  800126:	c9                   	leave  
  800127:	c3                   	ret    

00800128 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	57                   	push   %edi
  80012c:	56                   	push   %esi
  80012d:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80012e:	b8 02 00 00 00       	mov    $0x2,%eax
  800133:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800138:	89 fa                	mov    %edi,%edx
  80013a:	89 f9                	mov    %edi,%ecx
  80013c:	89 fb                	mov    %edi,%ebx
  80013e:	89 fe                	mov    %edi,%esi
  800140:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	c9                   	leave  
  800146:	c3                   	ret    

00800147 <sys_yield>:

void
sys_yield(void)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	57                   	push   %edi
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80014d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800152:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800157:	89 fa                	mov    %edi,%edx
  800159:	89 f9                	mov    %edi,%ecx
  80015b:	89 fb                	mov    %edi,%ebx
  80015d:	89 fe                	mov    %edi,%esi
  80015f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800161:	5b                   	pop    %ebx
  800162:	5e                   	pop    %esi
  800163:	5f                   	pop    %edi
  800164:	c9                   	leave  
  800165:	c3                   	ret    

00800166 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	57                   	push   %edi
  80016a:	56                   	push   %esi
  80016b:	53                   	push   %ebx
  80016c:	83 ec 0c             	sub    $0xc,%esp
  80016f:	8b 55 08             	mov    0x8(%ebp),%edx
  800172:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800175:	8b 5d 10             	mov    0x10(%ebp),%ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800178:	b8 04 00 00 00       	mov    $0x4,%eax
  80017d:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800182:	89 fe                	mov    %edi,%esi
  800184:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800186:	85 c0                	test   %eax,%eax
  800188:	7e 17                	jle    8001a1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018a:	83 ec 0c             	sub    $0xc,%esp
  80018d:	50                   	push   %eax
  80018e:	6a 04                	push   $0x4
  800190:	68 2a 0f 80 00       	push   $0x800f2a
  800195:	6a 23                	push   $0x23
  800197:	68 47 0f 80 00       	push   $0x800f47
  80019c:	e8 b7 01 00 00       	call   800358 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a4:	5b                   	pop    %ebx
  8001a5:	5e                   	pop    %esi
  8001a6:	5f                   	pop    %edi
  8001a7:	c9                   	leave  
  8001a8:	c3                   	ret    

008001a9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	57                   	push   %edi
  8001ad:	56                   	push   %esi
  8001ae:	53                   	push   %ebx
  8001af:	83 ec 0c             	sub    $0xc,%esp
  8001b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001be:	8b 75 18             	mov    0x18(%ebp),%esi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8001c1:	b8 05 00 00 00       	mov    $0x5,%eax
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001c6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001c8:	85 c0                	test   %eax,%eax
  8001ca:	7e 17                	jle    8001e3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	50                   	push   %eax
  8001d0:	6a 05                	push   $0x5
  8001d2:	68 2a 0f 80 00       	push   $0x800f2a
  8001d7:	6a 23                	push   $0x23
  8001d9:	68 47 0f 80 00       	push   $0x800f47
  8001de:	e8 75 01 00 00       	call   800358 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e6:	5b                   	pop    %ebx
  8001e7:	5e                   	pop    %esi
  8001e8:	5f                   	pop    %edi
  8001e9:	c9                   	leave  
  8001ea:	c3                   	ret    

008001eb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001eb:	55                   	push   %ebp
  8001ec:	89 e5                	mov    %esp,%ebp
  8001ee:	57                   	push   %edi
  8001ef:	56                   	push   %esi
  8001f0:	53                   	push   %ebx
  8001f1:	83 ec 0c             	sub    $0xc,%esp
  8001f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8001fa:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ff:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800204:	89 fb                	mov    %edi,%ebx
  800206:	89 fe                	mov    %edi,%esi
  800208:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80020a:	85 c0                	test   %eax,%eax
  80020c:	7e 17                	jle    800225 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	6a 06                	push   $0x6
  800214:	68 2a 0f 80 00       	push   $0x800f2a
  800219:	6a 23                	push   $0x23
  80021b:	68 47 0f 80 00       	push   $0x800f47
  800220:	e8 33 01 00 00       	call   800358 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800225:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800228:	5b                   	pop    %ebx
  800229:	5e                   	pop    %esi
  80022a:	5f                   	pop    %edi
  80022b:	c9                   	leave  
  80022c:	c3                   	ret    

0080022d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022d:	55                   	push   %ebp
  80022e:	89 e5                	mov    %esp,%ebp
  800230:	57                   	push   %edi
  800231:	56                   	push   %esi
  800232:	53                   	push   %ebx
  800233:	83 ec 0c             	sub    $0xc,%esp
  800236:	8b 55 08             	mov    0x8(%ebp),%edx
  800239:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80023c:	b8 08 00 00 00       	mov    $0x8,%eax
  800241:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800246:	89 fb                	mov    %edi,%ebx
  800248:	89 fe                	mov    %edi,%esi
  80024a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80024c:	85 c0                	test   %eax,%eax
  80024e:	7e 17                	jle    800267 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800250:	83 ec 0c             	sub    $0xc,%esp
  800253:	50                   	push   %eax
  800254:	6a 08                	push   $0x8
  800256:	68 2a 0f 80 00       	push   $0x800f2a
  80025b:	6a 23                	push   $0x23
  80025d:	68 47 0f 80 00       	push   $0x800f47
  800262:	e8 f1 00 00 00       	call   800358 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800267:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026a:	5b                   	pop    %ebx
  80026b:	5e                   	pop    %esi
  80026c:	5f                   	pop    %edi
  80026d:	c9                   	leave  
  80026e:	c3                   	ret    

0080026f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	57                   	push   %edi
  800273:	56                   	push   %esi
  800274:	53                   	push   %ebx
  800275:	83 ec 0c             	sub    $0xc,%esp
  800278:	8b 55 08             	mov    0x8(%ebp),%edx
  80027b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80027e:	b8 09 00 00 00       	mov    $0x9,%eax
  800283:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800288:	89 fb                	mov    %edi,%ebx
  80028a:	89 fe                	mov    %edi,%esi
  80028c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80028e:	85 c0                	test   %eax,%eax
  800290:	7e 17                	jle    8002a9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800292:	83 ec 0c             	sub    $0xc,%esp
  800295:	50                   	push   %eax
  800296:	6a 09                	push   $0x9
  800298:	68 2a 0f 80 00       	push   $0x800f2a
  80029d:	6a 23                	push   $0x23
  80029f:	68 47 0f 80 00       	push   $0x800f47
  8002a4:	e8 af 00 00 00       	call   800358 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ac:	5b                   	pop    %ebx
  8002ad:	5e                   	pop    %esi
  8002ae:	5f                   	pop    %edi
  8002af:	c9                   	leave  
  8002b0:	c3                   	ret    

008002b1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	57                   	push   %edi
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	83 ec 0c             	sub    $0xc,%esp
  8002ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8002bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8002c0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c5:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ca:	89 fb                	mov    %edi,%ebx
  8002cc:	89 fe                	mov    %edi,%esi
  8002ce:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002d0:	85 c0                	test   %eax,%eax
  8002d2:	7e 17                	jle    8002eb <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d4:	83 ec 0c             	sub    $0xc,%esp
  8002d7:	50                   	push   %eax
  8002d8:	6a 0a                	push   $0xa
  8002da:	68 2a 0f 80 00       	push   $0x800f2a
  8002df:	6a 23                	push   $0x23
  8002e1:	68 47 0f 80 00       	push   $0x800f47
  8002e6:	e8 6d 00 00 00       	call   800358 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ee:	5b                   	pop    %ebx
  8002ef:	5e                   	pop    %esi
  8002f0:	5f                   	pop    %edi
  8002f1:	c9                   	leave  
  8002f2:	c3                   	ret    

008002f3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	57                   	push   %edi
  8002f7:	56                   	push   %esi
  8002f8:	53                   	push   %ebx
  8002f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800302:	8b 7d 14             	mov    0x14(%ebp),%edi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800305:	b8 0c 00 00 00       	mov    $0xc,%eax
  80030a:	be 00 00 00 00       	mov    $0x0,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800311:	5b                   	pop    %ebx
  800312:	5e                   	pop    %esi
  800313:	5f                   	pop    %edi
  800314:	c9                   	leave  
  800315:	c3                   	ret    

00800316 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
  800319:	57                   	push   %edi
  80031a:	56                   	push   %esi
  80031b:	53                   	push   %ebx
  80031c:	83 ec 0c             	sub    $0xc,%esp
  80031f:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800322:	b8 0d 00 00 00       	mov    $0xd,%eax
  800327:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80032c:	89 f9                	mov    %edi,%ecx
  80032e:	89 fb                	mov    %edi,%ebx
  800330:	89 fe                	mov    %edi,%esi
  800332:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800334:	85 c0                	test   %eax,%eax
  800336:	7e 17                	jle    80034f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800338:	83 ec 0c             	sub    $0xc,%esp
  80033b:	50                   	push   %eax
  80033c:	6a 0d                	push   $0xd
  80033e:	68 2a 0f 80 00       	push   $0x800f2a
  800343:	6a 23                	push   $0x23
  800345:	68 47 0f 80 00       	push   $0x800f47
  80034a:	e8 09 00 00 00       	call   800358 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80034f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800352:	5b                   	pop    %ebx
  800353:	5e                   	pop    %esi
  800354:	5f                   	pop    %edi
  800355:	c9                   	leave  
  800356:	c3                   	ret    
	...

00800358 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
  80035b:	53                   	push   %ebx
  80035c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;

	va_start(ap, fmt);
  80035f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800362:	ff 75 0c             	pushl  0xc(%ebp)
  800365:	ff 75 08             	pushl  0x8(%ebp)
  800368:	ff 35 00 20 80 00    	pushl  0x802000
  80036e:	83 ec 08             	sub    $0x8,%esp
  800371:	e8 b2 fd ff ff       	call   800128 <sys_getenvid>
  800376:	83 c4 08             	add    $0x8,%esp
  800379:	50                   	push   %eax
  80037a:	68 58 0f 80 00       	push   $0x800f58
  80037f:	e8 b0 00 00 00       	call   800434 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800384:	83 c4 18             	add    $0x18,%esp
  800387:	53                   	push   %ebx
  800388:	ff 75 10             	pushl  0x10(%ebp)
  80038b:	e8 53 00 00 00       	call   8003e3 <vcprintf>
	cprintf("\n");
  800390:	c7 04 24 7b 0f 80 00 	movl   $0x800f7b,(%esp)
  800397:	e8 98 00 00 00       	call   800434 <cprintf>

	// Cause a breakpoint exception
	while (1)
  80039c:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  80039f:	cc                   	int3   
  8003a0:	eb fd                	jmp    80039f <_panic+0x47>
	...

008003a4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003a4:	55                   	push   %ebp
  8003a5:	89 e5                	mov    %esp,%ebp
  8003a7:	53                   	push   %ebx
  8003a8:	83 ec 04             	sub    $0x4,%esp
  8003ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003ae:	8b 03                	mov    (%ebx),%eax
  8003b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b3:	88 54 18 08          	mov    %dl,0x8(%eax,%ebx,1)
  8003b7:	40                   	inc    %eax
  8003b8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8003ba:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003bf:	75 1a                	jne    8003db <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8003c1:	83 ec 08             	sub    $0x8,%esp
  8003c4:	68 ff 00 00 00       	push   $0xff
  8003c9:	8d 43 08             	lea    0x8(%ebx),%eax
  8003cc:	50                   	push   %eax
  8003cd:	e8 d2 fc ff ff       	call   8000a4 <sys_cputs>
		b->idx = 0;
  8003d2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003d8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003db:	ff 43 04             	incl   0x4(%ebx)
}
  8003de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003e1:	c9                   	leave  
  8003e2:	c3                   	ret    

008003e3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003e3:	55                   	push   %ebp
  8003e4:	89 e5                	mov    %esp,%ebp
  8003e6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003ec:	c7 85 e8 fe ff ff 00 	movl   $0x0,-0x118(%ebp)
  8003f3:	00 00 00 
	b.cnt = 0;
  8003f6:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8003fd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800400:	ff 75 0c             	pushl  0xc(%ebp)
  800403:	ff 75 08             	pushl  0x8(%ebp)
  800406:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80040c:	50                   	push   %eax
  80040d:	68 a4 03 80 00       	push   $0x8003a4
  800412:	e8 49 01 00 00       	call   800560 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800417:	83 c4 08             	add    $0x8,%esp
  80041a:	ff b5 e8 fe ff ff    	pushl  -0x118(%ebp)
  800420:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800426:	50                   	push   %eax
  800427:	e8 78 fc ff ff       	call   8000a4 <sys_cputs>

	return b.cnt;
  80042c:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
}
  800432:	c9                   	leave  
  800433:	c3                   	ret    

00800434 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800434:	55                   	push   %ebp
  800435:	89 e5                	mov    %esp,%ebp
  800437:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80043a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80043d:	50                   	push   %eax
  80043e:	ff 75 08             	pushl  0x8(%ebp)
  800441:	e8 9d ff ff ff       	call   8003e3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800446:	c9                   	leave  
  800447:	c3                   	ret    

00800448 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800448:	55                   	push   %ebp
  800449:	89 e5                	mov    %esp,%ebp
  80044b:	57                   	push   %edi
  80044c:	56                   	push   %esi
  80044d:	53                   	push   %ebx
  80044e:	83 ec 0c             	sub    $0xc,%esp
  800451:	8b 75 10             	mov    0x10(%ebp),%esi
  800454:	8b 7d 14             	mov    0x14(%ebp),%edi
  800457:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80045a:	8b 45 18             	mov    0x18(%ebp),%eax
  80045d:	ba 00 00 00 00       	mov    $0x0,%edx
  800462:	39 fa                	cmp    %edi,%edx
  800464:	77 39                	ja     80049f <printnum+0x57>
  800466:	72 04                	jb     80046c <printnum+0x24>
  800468:	39 f0                	cmp    %esi,%eax
  80046a:	77 33                	ja     80049f <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80046c:	83 ec 04             	sub    $0x4,%esp
  80046f:	ff 75 20             	pushl  0x20(%ebp)
  800472:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800475:	50                   	push   %eax
  800476:	ff 75 18             	pushl  0x18(%ebp)
  800479:	8b 45 18             	mov    0x18(%ebp),%eax
  80047c:	ba 00 00 00 00       	mov    $0x0,%edx
  800481:	52                   	push   %edx
  800482:	50                   	push   %eax
  800483:	57                   	push   %edi
  800484:	56                   	push   %esi
  800485:	e8 de 07 00 00       	call   800c68 <__udivdi3>
  80048a:	83 c4 10             	add    $0x10,%esp
  80048d:	52                   	push   %edx
  80048e:	50                   	push   %eax
  80048f:	ff 75 0c             	pushl  0xc(%ebp)
  800492:	ff 75 08             	pushl  0x8(%ebp)
  800495:	e8 ae ff ff ff       	call   800448 <printnum>
  80049a:	83 c4 20             	add    $0x20,%esp
  80049d:	eb 19                	jmp    8004b8 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80049f:	4b                   	dec    %ebx
  8004a0:	85 db                	test   %ebx,%ebx
  8004a2:	7e 14                	jle    8004b8 <printnum+0x70>
  8004a4:	83 ec 08             	sub    $0x8,%esp
  8004a7:	ff 75 0c             	pushl  0xc(%ebp)
  8004aa:	ff 75 20             	pushl  0x20(%ebp)
  8004ad:	ff 55 08             	call   *0x8(%ebp)
  8004b0:	83 c4 10             	add    $0x10,%esp
  8004b3:	4b                   	dec    %ebx
  8004b4:	85 db                	test   %ebx,%ebx
  8004b6:	7f ec                	jg     8004a4 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004b8:	83 ec 08             	sub    $0x8,%esp
  8004bb:	ff 75 0c             	pushl  0xc(%ebp)
  8004be:	8b 45 18             	mov    0x18(%ebp),%eax
  8004c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c6:	83 ec 04             	sub    $0x4,%esp
  8004c9:	52                   	push   %edx
  8004ca:	50                   	push   %eax
  8004cb:	57                   	push   %edi
  8004cc:	56                   	push   %esi
  8004cd:	e8 a2 08 00 00       	call   800d74 <__umoddi3>
  8004d2:	83 c4 14             	add    $0x14,%esp
  8004d5:	0f be 80 8f 10 80 00 	movsbl 0x80108f(%eax),%eax
  8004dc:	50                   	push   %eax
  8004dd:	ff 55 08             	call   *0x8(%ebp)
}
  8004e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004e3:	5b                   	pop    %ebx
  8004e4:	5e                   	pop    %esi
  8004e5:	5f                   	pop    %edi
  8004e6:	c9                   	leave  
  8004e7:	c3                   	ret    

008004e8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004e8:	55                   	push   %ebp
  8004e9:	89 e5                	mov    %esp,%ebp
  8004eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004ee:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  8004f1:	83 f8 01             	cmp    $0x1,%eax
  8004f4:	7e 0e                	jle    800504 <getuint+0x1c>
		return va_arg(*ap, unsigned long long);
  8004f6:	8b 11                	mov    (%ecx),%edx
  8004f8:	8d 42 08             	lea    0x8(%edx),%eax
  8004fb:	89 01                	mov    %eax,(%ecx)
  8004fd:	8b 02                	mov    (%edx),%eax
  8004ff:	8b 52 04             	mov    0x4(%edx),%edx
  800502:	eb 22                	jmp    800526 <getuint+0x3e>
	else if (lflag)
  800504:	85 c0                	test   %eax,%eax
  800506:	74 10                	je     800518 <getuint+0x30>
		return va_arg(*ap, unsigned long);
  800508:	8b 11                	mov    (%ecx),%edx
  80050a:	8d 42 04             	lea    0x4(%edx),%eax
  80050d:	89 01                	mov    %eax,(%ecx)
  80050f:	8b 02                	mov    (%edx),%eax
  800511:	ba 00 00 00 00       	mov    $0x0,%edx
  800516:	eb 0e                	jmp    800526 <getuint+0x3e>
	else
		return va_arg(*ap, unsigned int);
  800518:	8b 11                	mov    (%ecx),%edx
  80051a:	8d 42 04             	lea    0x4(%edx),%eax
  80051d:	89 01                	mov    %eax,(%ecx)
  80051f:	8b 02                	mov    (%edx),%eax
  800521:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800526:	c9                   	leave  
  800527:	c3                   	ret    

00800528 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800528:	55                   	push   %ebp
  800529:	89 e5                	mov    %esp,%ebp
  80052b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80052e:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800531:	83 f8 01             	cmp    $0x1,%eax
  800534:	7e 0e                	jle    800544 <getint+0x1c>
		return va_arg(*ap, long long);
  800536:	8b 11                	mov    (%ecx),%edx
  800538:	8d 42 08             	lea    0x8(%edx),%eax
  80053b:	89 01                	mov    %eax,(%ecx)
  80053d:	8b 02                	mov    (%edx),%eax
  80053f:	8b 52 04             	mov    0x4(%edx),%edx
  800542:	eb 1a                	jmp    80055e <getint+0x36>
	else if (lflag)
  800544:	85 c0                	test   %eax,%eax
  800546:	74 0c                	je     800554 <getint+0x2c>
		return va_arg(*ap, long);
  800548:	8b 01                	mov    (%ecx),%eax
  80054a:	8d 50 04             	lea    0x4(%eax),%edx
  80054d:	89 11                	mov    %edx,(%ecx)
  80054f:	8b 00                	mov    (%eax),%eax
  800551:	99                   	cltd   
  800552:	eb 0a                	jmp    80055e <getint+0x36>
	else
		return va_arg(*ap, int);
  800554:	8b 01                	mov    (%ecx),%eax
  800556:	8d 50 04             	lea    0x4(%eax),%edx
  800559:	89 11                	mov    %edx,(%ecx)
  80055b:	8b 00                	mov    (%eax),%eax
  80055d:	99                   	cltd   
}
  80055e:	c9                   	leave  
  80055f:	c3                   	ret    

00800560 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800560:	55                   	push   %ebp
  800561:	89 e5                	mov    %esp,%ebp
  800563:	57                   	push   %edi
  800564:	56                   	push   %esi
  800565:	53                   	push   %ebx
  800566:	83 ec 1c             	sub    $0x1c,%esp
  800569:	8b 5d 10             	mov    0x10(%ebp),%ebx

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
			putch(ch, putdat);
  80056c:	0f b6 0b             	movzbl (%ebx),%ecx
  80056f:	43                   	inc    %ebx
  800570:	83 f9 25             	cmp    $0x25,%ecx
  800573:	74 1e                	je     800593 <vprintfmt+0x33>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800575:	85 c9                	test   %ecx,%ecx
  800577:	0f 84 dc 02 00 00    	je     800859 <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  80057d:	83 ec 08             	sub    $0x8,%esp
  800580:	ff 75 0c             	pushl  0xc(%ebp)
  800583:	51                   	push   %ecx
  800584:	ff 55 08             	call   *0x8(%ebp)
  800587:	83 c4 10             	add    $0x10,%esp
  80058a:	0f b6 0b             	movzbl (%ebx),%ecx
  80058d:	43                   	inc    %ebx
  80058e:	83 f9 25             	cmp    $0x25,%ecx
  800591:	75 e2                	jne    800575 <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  800593:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
		width = -1;
  800597:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
		precision = -1;
  80059e:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  8005a3:	bf 00 00 00 00       	mov    $0x0,%edi
		altflag = 0;
  8005a8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005af:	0f b6 0b             	movzbl (%ebx),%ecx
  8005b2:	8d 41 dd             	lea    -0x23(%ecx),%eax
  8005b5:	43                   	inc    %ebx
  8005b6:	83 f8 55             	cmp    $0x55,%eax
  8005b9:	0f 87 75 02 00 00    	ja     800834 <vprintfmt+0x2d4>
  8005bf:	ff 24 85 20 11 80 00 	jmp    *0x801120(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  8005c6:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
			goto reswitch;
  8005ca:	eb e3                	jmp    8005af <vprintfmt+0x4f>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005cc:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
			goto reswitch;
  8005d0:	eb dd                	jmp    8005af <vprintfmt+0x4f>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005d2:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  8005d7:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  8005da:	8d 74 41 d0          	lea    -0x30(%ecx,%eax,2),%esi
				ch = *fmt;
  8005de:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  8005e1:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8005e4:	83 f8 09             	cmp    $0x9,%eax
  8005e7:	77 28                	ja     800611 <vprintfmt+0xb1>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005e9:	43                   	inc    %ebx
  8005ea:	eb eb                	jmp    8005d7 <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005ec:	8b 55 14             	mov    0x14(%ebp),%edx
  8005ef:	8d 42 04             	lea    0x4(%edx),%eax
  8005f2:	89 45 14             	mov    %eax,0x14(%ebp)
  8005f5:	8b 32                	mov    (%edx),%esi
			goto process_precision;
  8005f7:	eb 18                	jmp    800611 <vprintfmt+0xb1>

		case '.':
			if (width < 0)
  8005f9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8005fd:	79 b0                	jns    8005af <vprintfmt+0x4f>
				width = 0;
  8005ff:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
			goto reswitch;
  800606:	eb a7                	jmp    8005af <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  800608:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
			goto reswitch;
  80060f:	eb 9e                	jmp    8005af <vprintfmt+0x4f>

		process_precision:
			if (width < 0)
  800611:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800615:	79 98                	jns    8005af <vprintfmt+0x4f>
				width = precision, precision = -1;
  800617:	89 75 f0             	mov    %esi,-0x10(%ebp)
  80061a:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  80061f:	eb 8e                	jmp    8005af <vprintfmt+0x4f>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800621:	47                   	inc    %edi
			goto reswitch;
  800622:	eb 8b                	jmp    8005af <vprintfmt+0x4f>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800624:	83 ec 08             	sub    $0x8,%esp
  800627:	ff 75 0c             	pushl  0xc(%ebp)
  80062a:	8b 55 14             	mov    0x14(%ebp),%edx
  80062d:	8d 42 04             	lea    0x4(%edx),%eax
  800630:	89 45 14             	mov    %eax,0x14(%ebp)
  800633:	ff 32                	pushl  (%edx)
  800635:	ff 55 08             	call   *0x8(%ebp)
			break;
  800638:	83 c4 10             	add    $0x10,%esp
  80063b:	e9 2c ff ff ff       	jmp    80056c <vprintfmt+0xc>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800640:	8b 55 14             	mov    0x14(%ebp),%edx
  800643:	8d 42 04             	lea    0x4(%edx),%eax
  800646:	89 45 14             	mov    %eax,0x14(%ebp)
  800649:	8b 02                	mov    (%edx),%eax
			if (err < 0)
  80064b:	85 c0                	test   %eax,%eax
  80064d:	79 02                	jns    800651 <vprintfmt+0xf1>
				err = -err;
  80064f:	f7 d8                	neg    %eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800651:	83 f8 0f             	cmp    $0xf,%eax
  800654:	7f 0b                	jg     800661 <vprintfmt+0x101>
  800656:	8b 3c 85 e0 10 80 00 	mov    0x8010e0(,%eax,4),%edi
  80065d:	85 ff                	test   %edi,%edi
  80065f:	75 19                	jne    80067a <vprintfmt+0x11a>
				printfmt(putch, putdat, "error %d", err);
  800661:	50                   	push   %eax
  800662:	68 a0 10 80 00       	push   $0x8010a0
  800667:	ff 75 0c             	pushl  0xc(%ebp)
  80066a:	ff 75 08             	pushl  0x8(%ebp)
  80066d:	e8 ef 01 00 00       	call   800861 <printfmt>
  800672:	83 c4 10             	add    $0x10,%esp
  800675:	e9 f2 fe ff ff       	jmp    80056c <vprintfmt+0xc>
			else
				printfmt(putch, putdat, "%s", p);
  80067a:	57                   	push   %edi
  80067b:	68 a9 10 80 00       	push   $0x8010a9
  800680:	ff 75 0c             	pushl  0xc(%ebp)
  800683:	ff 75 08             	pushl  0x8(%ebp)
  800686:	e8 d6 01 00 00       	call   800861 <printfmt>
  80068b:	83 c4 10             	add    $0x10,%esp
			break;
  80068e:	e9 d9 fe ff ff       	jmp    80056c <vprintfmt+0xc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800693:	8b 55 14             	mov    0x14(%ebp),%edx
  800696:	8d 42 04             	lea    0x4(%edx),%eax
  800699:	89 45 14             	mov    %eax,0x14(%ebp)
  80069c:	8b 3a                	mov    (%edx),%edi
  80069e:	85 ff                	test   %edi,%edi
  8006a0:	75 05                	jne    8006a7 <vprintfmt+0x147>
				p = "(null)";
  8006a2:	bf ac 10 80 00       	mov    $0x8010ac,%edi
			if (width > 0 && padc != '-')
  8006a7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8006ab:	7e 3b                	jle    8006e8 <vprintfmt+0x188>
  8006ad:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  8006b1:	74 35                	je     8006e8 <vprintfmt+0x188>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b3:	83 ec 08             	sub    $0x8,%esp
  8006b6:	56                   	push   %esi
  8006b7:	57                   	push   %edi
  8006b8:	e8 58 02 00 00       	call   800915 <strnlen>
  8006bd:	29 45 f0             	sub    %eax,-0x10(%ebp)
  8006c0:	83 c4 10             	add    $0x10,%esp
  8006c3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8006c7:	7e 1f                	jle    8006e8 <vprintfmt+0x188>
  8006c9:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  8006cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
					putch(padc, putdat);
  8006d0:	83 ec 08             	sub    $0x8,%esp
  8006d3:	ff 75 0c             	pushl  0xc(%ebp)
  8006d6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006d9:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006dc:	83 c4 10             	add    $0x10,%esp
  8006df:	ff 4d f0             	decl   -0x10(%ebp)
  8006e2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8006e6:	7f e8                	jg     8006d0 <vprintfmt+0x170>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006e8:	0f be 0f             	movsbl (%edi),%ecx
  8006eb:	47                   	inc    %edi
  8006ec:	85 c9                	test   %ecx,%ecx
  8006ee:	74 44                	je     800734 <vprintfmt+0x1d4>
  8006f0:	85 f6                	test   %esi,%esi
  8006f2:	78 03                	js     8006f7 <vprintfmt+0x197>
  8006f4:	4e                   	dec    %esi
  8006f5:	78 3d                	js     800734 <vprintfmt+0x1d4>
				if (altflag && (ch < ' ' || ch > '~'))
  8006f7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8006fb:	74 18                	je     800715 <vprintfmt+0x1b5>
  8006fd:	8d 41 e0             	lea    -0x20(%ecx),%eax
  800700:	83 f8 5e             	cmp    $0x5e,%eax
  800703:	76 10                	jbe    800715 <vprintfmt+0x1b5>
					putch('?', putdat);
  800705:	83 ec 08             	sub    $0x8,%esp
  800708:	ff 75 0c             	pushl  0xc(%ebp)
  80070b:	6a 3f                	push   $0x3f
  80070d:	ff 55 08             	call   *0x8(%ebp)
  800710:	83 c4 10             	add    $0x10,%esp
  800713:	eb 0d                	jmp    800722 <vprintfmt+0x1c2>
				else
					putch(ch, putdat);
  800715:	83 ec 08             	sub    $0x8,%esp
  800718:	ff 75 0c             	pushl  0xc(%ebp)
  80071b:	51                   	push   %ecx
  80071c:	ff 55 08             	call   *0x8(%ebp)
  80071f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800722:	ff 4d f0             	decl   -0x10(%ebp)
  800725:	0f be 0f             	movsbl (%edi),%ecx
  800728:	47                   	inc    %edi
  800729:	85 c9                	test   %ecx,%ecx
  80072b:	74 07                	je     800734 <vprintfmt+0x1d4>
  80072d:	85 f6                	test   %esi,%esi
  80072f:	78 c6                	js     8006f7 <vprintfmt+0x197>
  800731:	4e                   	dec    %esi
  800732:	79 c3                	jns    8006f7 <vprintfmt+0x197>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800734:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800738:	0f 8e 2e fe ff ff    	jle    80056c <vprintfmt+0xc>
				putch(' ', putdat);
  80073e:	83 ec 08             	sub    $0x8,%esp
  800741:	ff 75 0c             	pushl  0xc(%ebp)
  800744:	6a 20                	push   $0x20
  800746:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800749:	83 c4 10             	add    $0x10,%esp
  80074c:	ff 4d f0             	decl   -0x10(%ebp)
  80074f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800753:	7f e9                	jg     80073e <vprintfmt+0x1de>
				putch(' ', putdat);
			break;
  800755:	e9 12 fe ff ff       	jmp    80056c <vprintfmt+0xc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80075a:	57                   	push   %edi
  80075b:	8d 45 14             	lea    0x14(%ebp),%eax
  80075e:	50                   	push   %eax
  80075f:	e8 c4 fd ff ff       	call   800528 <getint>
  800764:	89 c6                	mov    %eax,%esi
  800766:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800768:	83 c4 08             	add    $0x8,%esp
  80076b:	85 d2                	test   %edx,%edx
  80076d:	79 15                	jns    800784 <vprintfmt+0x224>
				putch('-', putdat);
  80076f:	83 ec 08             	sub    $0x8,%esp
  800772:	ff 75 0c             	pushl  0xc(%ebp)
  800775:	6a 2d                	push   $0x2d
  800777:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80077a:	f7 de                	neg    %esi
  80077c:	83 d7 00             	adc    $0x0,%edi
  80077f:	f7 df                	neg    %edi
  800781:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800784:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  800789:	eb 76                	jmp    800801 <vprintfmt+0x2a1>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80078b:	57                   	push   %edi
  80078c:	8d 45 14             	lea    0x14(%ebp),%eax
  80078f:	50                   	push   %eax
  800790:	e8 53 fd ff ff       	call   8004e8 <getuint>
  800795:	89 c6                	mov    %eax,%esi
  800797:	89 d7                	mov    %edx,%edi
			base = 10;
  800799:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  80079e:	83 c4 08             	add    $0x8,%esp
  8007a1:	eb 5e                	jmp    800801 <vprintfmt+0x2a1>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8007a3:	57                   	push   %edi
  8007a4:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a7:	50                   	push   %eax
  8007a8:	e8 3b fd ff ff       	call   8004e8 <getuint>
  8007ad:	89 c6                	mov    %eax,%esi
  8007af:	89 d7                	mov    %edx,%edi
			base = 8;
  8007b1:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  8007b6:	83 c4 08             	add    $0x8,%esp
  8007b9:	eb 46                	jmp    800801 <vprintfmt+0x2a1>

		// pointer
		case 'p':
			putch('0', putdat);
  8007bb:	83 ec 08             	sub    $0x8,%esp
  8007be:	ff 75 0c             	pushl  0xc(%ebp)
  8007c1:	6a 30                	push   $0x30
  8007c3:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007c6:	83 c4 08             	add    $0x8,%esp
  8007c9:	ff 75 0c             	pushl  0xc(%ebp)
  8007cc:	6a 78                	push   $0x78
  8007ce:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8007d1:	8b 55 14             	mov    0x14(%ebp),%edx
  8007d4:	8d 42 04             	lea    0x4(%edx),%eax
  8007d7:	89 45 14             	mov    %eax,0x14(%ebp)
  8007da:	8b 32                	mov    (%edx),%esi
  8007dc:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007e1:	ba 10 00 00 00       	mov    $0x10,%edx
			goto number;
  8007e6:	83 c4 10             	add    $0x10,%esp
  8007e9:	eb 16                	jmp    800801 <vprintfmt+0x2a1>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007eb:	57                   	push   %edi
  8007ec:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ef:	50                   	push   %eax
  8007f0:	e8 f3 fc ff ff       	call   8004e8 <getuint>
  8007f5:	89 c6                	mov    %eax,%esi
  8007f7:	89 d7                	mov    %edx,%edi
			base = 16;
  8007f9:	ba 10 00 00 00       	mov    $0x10,%edx
  8007fe:	83 c4 08             	add    $0x8,%esp
		number:
			printnum(putch, putdat, num, base, width, padc);
  800801:	83 ec 04             	sub    $0x4,%esp
  800804:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  800808:	50                   	push   %eax
  800809:	ff 75 f0             	pushl  -0x10(%ebp)
  80080c:	52                   	push   %edx
  80080d:	57                   	push   %edi
  80080e:	56                   	push   %esi
  80080f:	ff 75 0c             	pushl  0xc(%ebp)
  800812:	ff 75 08             	pushl  0x8(%ebp)
  800815:	e8 2e fc ff ff       	call   800448 <printnum>
			break;
  80081a:	83 c4 20             	add    $0x20,%esp
  80081d:	e9 4a fd ff ff       	jmp    80056c <vprintfmt+0xc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800822:	83 ec 08             	sub    $0x8,%esp
  800825:	ff 75 0c             	pushl  0xc(%ebp)
  800828:	51                   	push   %ecx
  800829:	ff 55 08             	call   *0x8(%ebp)
			break;
  80082c:	83 c4 10             	add    $0x10,%esp
  80082f:	e9 38 fd ff ff       	jmp    80056c <vprintfmt+0xc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800834:	83 ec 08             	sub    $0x8,%esp
  800837:	ff 75 0c             	pushl  0xc(%ebp)
  80083a:	6a 25                	push   $0x25
  80083c:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80083f:	4b                   	dec    %ebx
  800840:	83 c4 10             	add    $0x10,%esp
  800843:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800847:	0f 84 1f fd ff ff    	je     80056c <vprintfmt+0xc>
  80084d:	4b                   	dec    %ebx
  80084e:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800852:	75 f9                	jne    80084d <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  800854:	e9 13 fd ff ff       	jmp    80056c <vprintfmt+0xc>
		}
	}
}
  800859:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80085c:	5b                   	pop    %ebx
  80085d:	5e                   	pop    %esi
  80085e:	5f                   	pop    %edi
  80085f:	c9                   	leave  
  800860:	c3                   	ret    

00800861 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800867:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80086a:	50                   	push   %eax
  80086b:	ff 75 10             	pushl  0x10(%ebp)
  80086e:	ff 75 0c             	pushl  0xc(%ebp)
  800871:	ff 75 08             	pushl  0x8(%ebp)
  800874:	e8 e7 fc ff ff       	call   800560 <vprintfmt>
	va_end(ap);
}
  800879:	c9                   	leave  
  80087a:	c3                   	ret    

0080087b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  800881:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  800884:	8b 0a                	mov    (%edx),%ecx
  800886:	3b 4a 04             	cmp    0x4(%edx),%ecx
  800889:	73 07                	jae    800892 <sprintputch+0x17>
		*b->buf++ = ch;
  80088b:	8b 45 08             	mov    0x8(%ebp),%eax
  80088e:	88 01                	mov    %al,(%ecx)
  800890:	ff 02                	incl   (%edx)
}
  800892:	c9                   	leave  
  800893:	c3                   	ret    

00800894 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	83 ec 18             	sub    $0x18,%esp
  80089a:	8b 55 08             	mov    0x8(%ebp),%edx
  80089d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008a0:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8008a3:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
  8008a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008aa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

	if (buf == NULL || n < 1)
  8008b1:	85 d2                	test   %edx,%edx
  8008b3:	74 04                	je     8008b9 <vsnprintf+0x25>
  8008b5:	85 c9                	test   %ecx,%ecx
  8008b7:	7f 07                	jg     8008c0 <vsnprintf+0x2c>
		return -E_INVAL;
  8008b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008be:	eb 1d                	jmp    8008dd <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008c0:	ff 75 14             	pushl  0x14(%ebp)
  8008c3:	ff 75 10             	pushl  0x10(%ebp)
  8008c6:	8d 45 e8             	lea    -0x18(%ebp),%eax
  8008c9:	50                   	push   %eax
  8008ca:	68 7b 08 80 00       	push   $0x80087b
  8008cf:	e8 8c fc ff ff       	call   800560 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008d4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8008d7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008da:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8008dd:	c9                   	leave  
  8008de:	c3                   	ret    

008008df <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008e5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008e8:	50                   	push   %eax
  8008e9:	ff 75 10             	pushl  0x10(%ebp)
  8008ec:	ff 75 0c             	pushl  0xc(%ebp)
  8008ef:	ff 75 08             	pushl  0x8(%ebp)
  8008f2:	e8 9d ff ff ff       	call   800894 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008f7:	c9                   	leave  
  8008f8:	c3                   	ret    
  8008f9:	00 00                	add    %al,(%eax)
	...

008008fc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800902:	b8 00 00 00 00       	mov    $0x0,%eax
  800907:	80 3a 00             	cmpb   $0x0,(%edx)
  80090a:	74 07                	je     800913 <strlen+0x17>
		n++;
  80090c:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80090d:	42                   	inc    %edx
  80090e:	80 3a 00             	cmpb   $0x0,(%edx)
  800911:	75 f9                	jne    80090c <strlen+0x10>
		n++;
	return n;
}
  800913:	c9                   	leave  
  800914:	c3                   	ret    

00800915 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80091b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80091e:	b8 00 00 00 00       	mov    $0x0,%eax
  800923:	85 d2                	test   %edx,%edx
  800925:	74 0f                	je     800936 <strnlen+0x21>
  800927:	80 39 00             	cmpb   $0x0,(%ecx)
  80092a:	74 0a                	je     800936 <strnlen+0x21>
		n++;
  80092c:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80092d:	41                   	inc    %ecx
  80092e:	4a                   	dec    %edx
  80092f:	74 05                	je     800936 <strnlen+0x21>
  800931:	80 39 00             	cmpb   $0x0,(%ecx)
  800934:	75 f6                	jne    80092c <strnlen+0x17>
		n++;
	return n;
}
  800936:	c9                   	leave  
  800937:	c3                   	ret    

00800938 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	53                   	push   %ebx
  80093c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80093f:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  800942:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  800944:	8a 02                	mov    (%edx),%al
  800946:	42                   	inc    %edx
  800947:	88 01                	mov    %al,(%ecx)
  800949:	41                   	inc    %ecx
  80094a:	84 c0                	test   %al,%al
  80094c:	75 f6                	jne    800944 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80094e:	89 d8                	mov    %ebx,%eax
  800950:	5b                   	pop    %ebx
  800951:	c9                   	leave  
  800952:	c3                   	ret    

00800953 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
  800956:	53                   	push   %ebx
  800957:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80095a:	53                   	push   %ebx
  80095b:	e8 9c ff ff ff       	call   8008fc <strlen>
	strcpy(dst + len, src);
  800960:	ff 75 0c             	pushl  0xc(%ebp)
  800963:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800966:	50                   	push   %eax
  800967:	e8 cc ff ff ff       	call   800938 <strcpy>
	return dst;
}
  80096c:	89 d8                	mov    %ebx,%eax
  80096e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800971:	c9                   	leave  
  800972:	c3                   	ret    

00800973 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	57                   	push   %edi
  800977:	56                   	push   %esi
  800978:	53                   	push   %ebx
  800979:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80097c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097f:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  800982:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  800984:	bb 00 00 00 00       	mov    $0x0,%ebx
  800989:	39 f3                	cmp    %esi,%ebx
  80098b:	73 10                	jae    80099d <strncpy+0x2a>
		*dst++ = *src;
  80098d:	8a 02                	mov    (%edx),%al
  80098f:	88 01                	mov    %al,(%ecx)
  800991:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800992:	80 3a 01             	cmpb   $0x1,(%edx)
  800995:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800998:	43                   	inc    %ebx
  800999:	39 f3                	cmp    %esi,%ebx
  80099b:	72 f0                	jb     80098d <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80099d:	89 f8                	mov    %edi,%eax
  80099f:	5b                   	pop    %ebx
  8009a0:	5e                   	pop    %esi
  8009a1:	5f                   	pop    %edi
  8009a2:	c9                   	leave  
  8009a3:	c3                   	ret    

008009a4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009a4:	55                   	push   %ebp
  8009a5:	89 e5                	mov    %esp,%ebp
  8009a7:	56                   	push   %esi
  8009a8:	53                   	push   %ebx
  8009a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009af:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  8009b2:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  8009b4:	85 d2                	test   %edx,%edx
  8009b6:	74 19                	je     8009d1 <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009b8:	4a                   	dec    %edx
  8009b9:	74 13                	je     8009ce <strlcpy+0x2a>
  8009bb:	80 39 00             	cmpb   $0x0,(%ecx)
  8009be:	74 0e                	je     8009ce <strlcpy+0x2a>
  8009c0:	8a 01                	mov    (%ecx),%al
  8009c2:	41                   	inc    %ecx
  8009c3:	88 03                	mov    %al,(%ebx)
  8009c5:	43                   	inc    %ebx
  8009c6:	4a                   	dec    %edx
  8009c7:	74 05                	je     8009ce <strlcpy+0x2a>
  8009c9:	80 39 00             	cmpb   $0x0,(%ecx)
  8009cc:	75 f2                	jne    8009c0 <strlcpy+0x1c>
		*dst = '\0';
  8009ce:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  8009d1:	89 d8                	mov    %ebx,%eax
  8009d3:	29 f0                	sub    %esi,%eax
}
  8009d5:	5b                   	pop    %ebx
  8009d6:	5e                   	pop    %esi
  8009d7:	c9                   	leave  
  8009d8:	c3                   	ret    

008009d9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8009df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
		p++, q++;
  8009e2:	80 3a 00             	cmpb   $0x0,(%edx)
  8009e5:	74 13                	je     8009fa <strcmp+0x21>
  8009e7:	8a 02                	mov    (%edx),%al
  8009e9:	3a 01                	cmp    (%ecx),%al
  8009eb:	75 0d                	jne    8009fa <strcmp+0x21>
  8009ed:	42                   	inc    %edx
  8009ee:	41                   	inc    %ecx
  8009ef:	80 3a 00             	cmpb   $0x0,(%edx)
  8009f2:	74 06                	je     8009fa <strcmp+0x21>
  8009f4:	8a 02                	mov    (%edx),%al
  8009f6:	3a 01                	cmp    (%ecx),%al
  8009f8:	74 f3                	je     8009ed <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009fa:	0f b6 02             	movzbl (%edx),%eax
  8009fd:	0f b6 11             	movzbl (%ecx),%edx
  800a00:	29 d0                	sub    %edx,%eax
}
  800a02:	c9                   	leave  
  800a03:	c3                   	ret    

00800a04 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	53                   	push   %ebx
  800a08:	8b 55 08             	mov    0x8(%ebp),%edx
  800a0b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800a11:	85 c9                	test   %ecx,%ecx
  800a13:	74 1f                	je     800a34 <strncmp+0x30>
  800a15:	80 3a 00             	cmpb   $0x0,(%edx)
  800a18:	74 16                	je     800a30 <strncmp+0x2c>
  800a1a:	8a 02                	mov    (%edx),%al
  800a1c:	3a 03                	cmp    (%ebx),%al
  800a1e:	75 10                	jne    800a30 <strncmp+0x2c>
  800a20:	42                   	inc    %edx
  800a21:	43                   	inc    %ebx
  800a22:	49                   	dec    %ecx
  800a23:	74 0f                	je     800a34 <strncmp+0x30>
  800a25:	80 3a 00             	cmpb   $0x0,(%edx)
  800a28:	74 06                	je     800a30 <strncmp+0x2c>
  800a2a:	8a 02                	mov    (%edx),%al
  800a2c:	3a 03                	cmp    (%ebx),%al
  800a2e:	74 f0                	je     800a20 <strncmp+0x1c>
	if (n == 0)
  800a30:	85 c9                	test   %ecx,%ecx
  800a32:	75 07                	jne    800a3b <strncmp+0x37>
		return 0;
  800a34:	b8 00 00 00 00       	mov    $0x0,%eax
  800a39:	eb 0a                	jmp    800a45 <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a3b:	0f b6 12             	movzbl (%edx),%edx
  800a3e:	0f b6 03             	movzbl (%ebx),%eax
  800a41:	29 c2                	sub    %eax,%edx
  800a43:	89 d0                	mov    %edx,%eax
}
  800a45:	5b                   	pop    %ebx
  800a46:	c9                   	leave  
  800a47:	c3                   	ret    

00800a48 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
  800a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4e:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800a51:	80 38 00             	cmpb   $0x0,(%eax)
  800a54:	74 0a                	je     800a60 <strchr+0x18>
		if (*s == c)
  800a56:	38 10                	cmp    %dl,(%eax)
  800a58:	74 0b                	je     800a65 <strchr+0x1d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a5a:	40                   	inc    %eax
  800a5b:	80 38 00             	cmpb   $0x0,(%eax)
  800a5e:	75 f6                	jne    800a56 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800a60:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a65:	c9                   	leave  
  800a66:	c3                   	ret    

00800a67 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6d:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800a70:	80 38 00             	cmpb   $0x0,(%eax)
  800a73:	74 0a                	je     800a7f <strfind+0x18>
		if (*s == c)
  800a75:	38 10                	cmp    %dl,(%eax)
  800a77:	74 06                	je     800a7f <strfind+0x18>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a79:	40                   	inc    %eax
  800a7a:	80 38 00             	cmpb   $0x0,(%eax)
  800a7d:	75 f6                	jne    800a75 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
}
  800a7f:	c9                   	leave  
  800a80:	c3                   	ret    

00800a81 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	57                   	push   %edi
  800a85:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a88:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
		return v;
  800a8b:	89 f8                	mov    %edi,%eax
void *
memset(void *v, int c, size_t n)
{
	char *p;

	if (n == 0)
  800a8d:	85 c9                	test   %ecx,%ecx
  800a8f:	74 40                	je     800ad1 <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a91:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a97:	75 30                	jne    800ac9 <memset+0x48>
  800a99:	f6 c1 03             	test   $0x3,%cl
  800a9c:	75 2b                	jne    800ac9 <memset+0x48>
		c &= 0xFF;
  800a9e:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aa5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa8:	c1 e0 18             	shl    $0x18,%eax
  800aab:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aae:	c1 e2 10             	shl    $0x10,%edx
  800ab1:	09 d0                	or     %edx,%eax
  800ab3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab6:	c1 e2 08             	shl    $0x8,%edx
  800ab9:	09 d0                	or     %edx,%eax
  800abb:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  800abe:	c1 e9 02             	shr    $0x2,%ecx
  800ac1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac4:	fc                   	cld    
  800ac5:	f3 ab                	rep stos %eax,%es:(%edi)
  800ac7:	eb 06                	jmp    800acf <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ac9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800acc:	fc                   	cld    
  800acd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800acf:	89 f8                	mov    %edi,%eax
}
  800ad1:	5f                   	pop    %edi
  800ad2:	c9                   	leave  
  800ad3:	c3                   	ret    

00800ad4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	57                   	push   %edi
  800ad8:	56                   	push   %esi
  800ad9:	8b 45 08             	mov    0x8(%ebp),%eax
  800adc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800adf:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800ae2:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800ae4:	39 c6                	cmp    %eax,%esi
  800ae6:	73 34                	jae    800b1c <memmove+0x48>
  800ae8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aeb:	39 c2                	cmp    %eax,%edx
  800aed:	76 2d                	jbe    800b1c <memmove+0x48>
		s += n;
  800aef:	89 d6                	mov    %edx,%esi
		d += n;
  800af1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af4:	f6 c2 03             	test   $0x3,%dl
  800af7:	75 1b                	jne    800b14 <memmove+0x40>
  800af9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aff:	75 13                	jne    800b14 <memmove+0x40>
  800b01:	f6 c1 03             	test   $0x3,%cl
  800b04:	75 0e                	jne    800b14 <memmove+0x40>
			asm volatile("std; rep movsl\n"
  800b06:	83 ef 04             	sub    $0x4,%edi
  800b09:	83 ee 04             	sub    $0x4,%esi
  800b0c:	c1 e9 02             	shr    $0x2,%ecx
  800b0f:	fd                   	std    
  800b10:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b12:	eb 05                	jmp    800b19 <memmove+0x45>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b14:	4f                   	dec    %edi
  800b15:	4e                   	dec    %esi
  800b16:	fd                   	std    
  800b17:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b19:	fc                   	cld    
  800b1a:	eb 20                	jmp    800b3c <memmove+0x68>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b1c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b22:	75 15                	jne    800b39 <memmove+0x65>
  800b24:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b2a:	75 0d                	jne    800b39 <memmove+0x65>
  800b2c:	f6 c1 03             	test   $0x3,%cl
  800b2f:	75 08                	jne    800b39 <memmove+0x65>
			asm volatile("cld; rep movsl\n"
  800b31:	c1 e9 02             	shr    $0x2,%ecx
  800b34:	fc                   	cld    
  800b35:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b37:	eb 03                	jmp    800b3c <memmove+0x68>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b39:	fc                   	cld    
  800b3a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b3c:	5e                   	pop    %esi
  800b3d:	5f                   	pop    %edi
  800b3e:	c9                   	leave  
  800b3f:	c3                   	ret    

00800b40 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b43:	ff 75 10             	pushl  0x10(%ebp)
  800b46:	ff 75 0c             	pushl  0xc(%ebp)
  800b49:	ff 75 08             	pushl  0x8(%ebp)
  800b4c:	e8 83 ff ff ff       	call   800ad4 <memmove>
}
  800b51:	c9                   	leave  
  800b52:	c3                   	ret    

00800b53 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
  800b57:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  800b5a:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b5d:	8b 55 10             	mov    0x10(%ebp),%edx
  800b60:	4a                   	dec    %edx
  800b61:	83 fa ff             	cmp    $0xffffffff,%edx
  800b64:	74 1a                	je     800b80 <memcmp+0x2d>
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  800b66:	8a 01                	mov    (%ecx),%al
  800b68:	3a 03                	cmp    (%ebx),%al
  800b6a:	74 0c                	je     800b78 <memcmp+0x25>
			return (int) *s1 - (int) *s2;
  800b6c:	0f b6 d0             	movzbl %al,%edx
  800b6f:	0f b6 03             	movzbl (%ebx),%eax
  800b72:	29 c2                	sub    %eax,%edx
  800b74:	89 d0                	mov    %edx,%eax
  800b76:	eb 0d                	jmp    800b85 <memcmp+0x32>
		s1++, s2++;
  800b78:	41                   	inc    %ecx
  800b79:	43                   	inc    %ebx
  800b7a:	4a                   	dec    %edx
  800b7b:	83 fa ff             	cmp    $0xffffffff,%edx
  800b7e:	75 e6                	jne    800b66 <memcmp+0x13>
	}

	return 0;
  800b80:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b85:	5b                   	pop    %ebx
  800b86:	c9                   	leave  
  800b87:	c3                   	ret    

00800b88 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b91:	89 c2                	mov    %eax,%edx
  800b93:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b96:	39 d0                	cmp    %edx,%eax
  800b98:	73 09                	jae    800ba3 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b9a:	38 08                	cmp    %cl,(%eax)
  800b9c:	74 05                	je     800ba3 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b9e:	40                   	inc    %eax
  800b9f:	39 d0                	cmp    %edx,%eax
  800ba1:	72 f7                	jb     800b9a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ba3:	c9                   	leave  
  800ba4:	c3                   	ret    

00800ba5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	57                   	push   %edi
  800ba9:	56                   	push   %esi
  800baa:	53                   	push   %ebx
  800bab:	8b 55 08             	mov    0x8(%ebp),%edx
  800bae:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bb1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  800bb4:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  800bb9:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  800bbe:	80 3a 20             	cmpb   $0x20,(%edx)
  800bc1:	74 05                	je     800bc8 <strtol+0x23>
  800bc3:	80 3a 09             	cmpb   $0x9,(%edx)
  800bc6:	75 0b                	jne    800bd3 <strtol+0x2e>
  800bc8:	42                   	inc    %edx
  800bc9:	80 3a 20             	cmpb   $0x20,(%edx)
  800bcc:	74 fa                	je     800bc8 <strtol+0x23>
  800bce:	80 3a 09             	cmpb   $0x9,(%edx)
  800bd1:	74 f5                	je     800bc8 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  800bd3:	80 3a 2b             	cmpb   $0x2b,(%edx)
  800bd6:	75 03                	jne    800bdb <strtol+0x36>
		s++;
  800bd8:	42                   	inc    %edx
  800bd9:	eb 0b                	jmp    800be6 <strtol+0x41>
	else if (*s == '-')
  800bdb:	80 3a 2d             	cmpb   $0x2d,(%edx)
  800bde:	75 06                	jne    800be6 <strtol+0x41>
		s++, neg = 1;
  800be0:	42                   	inc    %edx
  800be1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800be6:	85 c9                	test   %ecx,%ecx
  800be8:	74 05                	je     800bef <strtol+0x4a>
  800bea:	83 f9 10             	cmp    $0x10,%ecx
  800bed:	75 15                	jne    800c04 <strtol+0x5f>
  800bef:	80 3a 30             	cmpb   $0x30,(%edx)
  800bf2:	75 10                	jne    800c04 <strtol+0x5f>
  800bf4:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bf8:	75 0a                	jne    800c04 <strtol+0x5f>
		s += 2, base = 16;
  800bfa:	83 c2 02             	add    $0x2,%edx
  800bfd:	b9 10 00 00 00       	mov    $0x10,%ecx
  800c02:	eb 14                	jmp    800c18 <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800c04:	85 c9                	test   %ecx,%ecx
  800c06:	75 10                	jne    800c18 <strtol+0x73>
  800c08:	80 3a 30             	cmpb   $0x30,(%edx)
  800c0b:	75 05                	jne    800c12 <strtol+0x6d>
		s++, base = 8;
  800c0d:	42                   	inc    %edx
  800c0e:	b1 08                	mov    $0x8,%cl
  800c10:	eb 06                	jmp    800c18 <strtol+0x73>
	else if (base == 0)
  800c12:	85 c9                	test   %ecx,%ecx
  800c14:	75 02                	jne    800c18 <strtol+0x73>
		base = 10;
  800c16:	b1 0a                	mov    $0xa,%cl

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c18:	8a 02                	mov    (%edx),%al
  800c1a:	83 e8 30             	sub    $0x30,%eax
  800c1d:	3c 09                	cmp    $0x9,%al
  800c1f:	77 08                	ja     800c29 <strtol+0x84>
			dig = *s - '0';
  800c21:	0f be 02             	movsbl (%edx),%eax
  800c24:	83 e8 30             	sub    $0x30,%eax
  800c27:	eb 20                	jmp    800c49 <strtol+0xa4>
		else if (*s >= 'a' && *s <= 'z')
  800c29:	8a 02                	mov    (%edx),%al
  800c2b:	83 e8 61             	sub    $0x61,%eax
  800c2e:	3c 19                	cmp    $0x19,%al
  800c30:	77 08                	ja     800c3a <strtol+0x95>
			dig = *s - 'a' + 10;
  800c32:	0f be 02             	movsbl (%edx),%eax
  800c35:	83 e8 57             	sub    $0x57,%eax
  800c38:	eb 0f                	jmp    800c49 <strtol+0xa4>
		else if (*s >= 'A' && *s <= 'Z')
  800c3a:	8a 02                	mov    (%edx),%al
  800c3c:	83 e8 41             	sub    $0x41,%eax
  800c3f:	3c 19                	cmp    $0x19,%al
  800c41:	77 12                	ja     800c55 <strtol+0xb0>
			dig = *s - 'A' + 10;
  800c43:	0f be 02             	movsbl (%edx),%eax
  800c46:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  800c49:	39 c8                	cmp    %ecx,%eax
  800c4b:	7d 08                	jge    800c55 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800c4d:	42                   	inc    %edx
  800c4e:	0f af d9             	imul   %ecx,%ebx
  800c51:	01 c3                	add    %eax,%ebx
  800c53:	eb c3                	jmp    800c18 <strtol+0x73>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c55:	85 f6                	test   %esi,%esi
  800c57:	74 02                	je     800c5b <strtol+0xb6>
		*endptr = (char *) s;
  800c59:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800c5b:	89 d8                	mov    %ebx,%eax
  800c5d:	85 ff                	test   %edi,%edi
  800c5f:	74 02                	je     800c63 <strtol+0xbe>
  800c61:	f7 d8                	neg    %eax
}
  800c63:	5b                   	pop    %ebx
  800c64:	5e                   	pop    %esi
  800c65:	5f                   	pop    %edi
  800c66:	c9                   	leave  
  800c67:	c3                   	ret    

00800c68 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	57                   	push   %edi
  800c6c:	56                   	push   %esi
  800c6d:	83 ec 14             	sub    $0x14,%esp
  800c70:	8b 55 14             	mov    0x14(%ebp),%edx
  800c73:	8b 75 08             	mov    0x8(%ebp),%esi
  800c76:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c79:	8b 45 10             	mov    0x10(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800c7c:	85 d2                	test   %edx,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800c7e:	89 75 f0             	mov    %esi,-0x10(%ebp)
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800c81:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  d1 = dd.s.high;
  800c84:	89 55 f4             	mov    %edx,-0xc(%ebp)
  n0 = nn.s.low;
  n1 = nn.s.high;
  800c87:	89 fe                	mov    %edi,%esi

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800c89:	75 11                	jne    800c9c <__udivdi3+0x34>
    {
      if (d0 > n1)
  800c8b:	39 f8                	cmp    %edi,%eax
  800c8d:	76 4d                	jbe    800cdc <__udivdi3+0x74>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800c8f:	89 fa                	mov    %edi,%edx
  800c91:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c94:	f7 75 e4             	divl   -0x1c(%ebp)
  800c97:	89 c7                	mov    %eax,%edi
  800c99:	eb 09                	jmp    800ca4 <__udivdi3+0x3c>
  800c9b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800c9c:	39 7d f4             	cmp    %edi,-0xc(%ebp)
  800c9f:	76 17                	jbe    800cb8 <__udivdi3+0x50>
	{
	  /* 00 = nn / DD */

	  q0 = 0;
  800ca1:	31 ff                	xor    %edi,%edi
  800ca3:	90                   	nop
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
		}

	      q1 = 0;
  800ca4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cab:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800cae:	83 c4 14             	add    $0x14,%esp
  800cb1:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cb2:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800cb4:	5f                   	pop    %edi
  800cb5:	c9                   	leave  
  800cb6:	c3                   	ret    
  800cb7:	90                   	nop
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800cb8:	0f bd 45 f4          	bsr    -0xc(%ebp),%eax
	  if (bm == 0)
  800cbc:	89 c7                	mov    %eax,%edi
  800cbe:	83 f7 1f             	xor    $0x1f,%edi
  800cc1:	75 4d                	jne    800d10 <__udivdi3+0xa8>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800cc3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800cc6:	77 0a                	ja     800cd2 <__udivdi3+0x6a>
  800cc8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
		}
	      else
		q0 = 0;
  800ccb:	31 ff                	xor    %edi,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ccd:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  800cd0:	72 d2                	jb     800ca4 <__udivdi3+0x3c>
		{
		  q0 = 1;
  800cd2:	bf 01 00 00 00       	mov    $0x1,%edi
  800cd7:	eb cb                	jmp    800ca4 <__udivdi3+0x3c>
  800cd9:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800cdc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800cdf:	85 c0                	test   %eax,%eax
  800ce1:	75 0e                	jne    800cf1 <__udivdi3+0x89>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800ce3:	b8 01 00 00 00       	mov    $0x1,%eax
  800ce8:	31 c9                	xor    %ecx,%ecx
  800cea:	31 d2                	xor    %edx,%edx
  800cec:	f7 f1                	div    %ecx
  800cee:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800cf1:	89 f0                	mov    %esi,%eax
  800cf3:	31 d2                	xor    %edx,%edx
  800cf5:	f7 75 e4             	divl   -0x1c(%ebp)
  800cf8:	89 45 ec             	mov    %eax,-0x14(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800cfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cfe:	f7 75 e4             	divl   -0x1c(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d01:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d04:	83 c4 14             	add    $0x14,%esp

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d07:	89 c7                	mov    %eax,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d09:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d0a:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d0c:	5f                   	pop    %edi
  800d0d:	c9                   	leave  
  800d0e:	c3                   	ret    
  800d0f:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d10:	b8 20 00 00 00       	mov    $0x20,%eax
  800d15:	29 f8                	sub    %edi,%eax
  800d17:	89 45 e8             	mov    %eax,-0x18(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  800d1a:	89 f9                	mov    %edi,%ecx
  800d1c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d1f:	d3 e2                	shl    %cl,%edx
  800d21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d24:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800d27:	d3 e8                	shr    %cl,%eax
  800d29:	09 c2                	or     %eax,%edx
	      d0 = d0 << bm;
  800d2b:	89 f9                	mov    %edi,%ecx
  800d2d:	d3 65 e4             	shll   %cl,-0x1c(%ebp)
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d30:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800d33:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800d36:	89 f2                	mov    %esi,%edx
  800d38:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  800d3a:	89 f9                	mov    %edi,%ecx
  800d3c:	d3 e6                	shl    %cl,%esi
  800d3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d41:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800d44:	d3 e8                	shr    %cl,%eax
  800d46:	09 c6                	or     %eax,%esi
	      n0 = n0 << bm;
  800d48:	89 f9                	mov    %edi,%ecx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d4a:	89 f0                	mov    %esi,%eax
  800d4c:	f7 75 f4             	divl   -0xc(%ebp)
  800d4f:	89 d6                	mov    %edx,%esi
  800d51:	89 c7                	mov    %eax,%edi

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800d53:	d3 65 f0             	shll   %cl,-0x10(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800d56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d59:	f7 e7                	mul    %edi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d5b:	39 f2                	cmp    %esi,%edx
  800d5d:	77 0f                	ja     800d6e <__udivdi3+0x106>
  800d5f:	0f 85 3f ff ff ff    	jne    800ca4 <__udivdi3+0x3c>
  800d65:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800d68:	0f 86 36 ff ff ff    	jbe    800ca4 <__udivdi3+0x3c>
		{
		  q0--;
  800d6e:	4f                   	dec    %edi
  800d6f:	e9 30 ff ff ff       	jmp    800ca4 <__udivdi3+0x3c>

00800d74 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	57                   	push   %edi
  800d78:	56                   	push   %esi
  800d79:	83 ec 30             	sub    $0x30,%esp
  800d7c:	8b 55 14             	mov    0x14(%ebp),%edx
  800d7f:	8b 45 10             	mov    0x10(%ebp),%eax
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  800d82:	89 d7                	mov    %edx,%edi
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  800d84:	8d 4d f0             	lea    -0x10(%ebp),%ecx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800d87:	89 c6                	mov    %eax,%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;
  800d89:	8b 55 0c             	mov    0xc(%ebp),%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800d8c:	8b 45 08             	mov    0x8(%ebp),%eax
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d8f:	85 ff                	test   %edi,%edi
  800d91:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800d98:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  800d9f:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800da2:	89 45 dc             	mov    %eax,-0x24(%ebp)
  n1 = nn.s.high;
  800da5:	89 55 cc             	mov    %edx,-0x34(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800da8:	75 3e                	jne    800de8 <__umoddi3+0x74>
    {
      if (d0 > n1)
  800daa:	39 d6                	cmp    %edx,%esi
  800dac:	0f 86 a2 00 00 00    	jbe    800e54 <__umoddi3+0xe0>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800db2:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  800db4:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800db7:	85 c9                	test   %ecx,%ecx

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800db9:	89 55 dc             	mov    %edx,-0x24(%ebp)

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  800dbc:	74 1b                	je     800dd9 <__umoddi3+0x65>
	{
	  rr.s.low = n0;
  800dbe:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800dc1:	89 45 e0             	mov    %eax,-0x20(%ebp)
	  rr.s.high = 0;
  800dc4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800dcb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800dce:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800dd1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800dd4:	89 10                	mov    %edx,(%eax)
  800dd6:	89 48 04             	mov    %ecx,0x4(%eax)
  800dd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ddc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ddf:	83 c4 30             	add    $0x30,%esp
  800de2:	5e                   	pop    %esi
  800de3:	5f                   	pop    %edi
  800de4:	c9                   	leave  
  800de5:	c3                   	ret    
  800de6:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800de8:	3b 7d cc             	cmp    -0x34(%ebp),%edi
  800deb:	76 1f                	jbe    800e0c <__umoddi3+0x98>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800ded:	8b 55 08             	mov    0x8(%ebp),%edx
	      rr.s.high = n1;
  800df0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800df3:	89 55 e0             	mov    %edx,-0x20(%ebp)
	      rr.s.high = n1;
  800df6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	      *rp = rr.ll;
  800df9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800dfc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800dff:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800e02:	89 55 f4             	mov    %edx,-0xc(%ebp)
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e05:	83 c4 30             	add    $0x30,%esp
  800e08:	5e                   	pop    %esi
  800e09:	5f                   	pop    %edi
  800e0a:	c9                   	leave  
  800e0b:	c3                   	ret    
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e0c:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800e0f:	83 f0 1f             	xor    $0x1f,%eax
  800e12:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800e15:	75 61                	jne    800e78 <__umoddi3+0x104>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e17:	39 7d cc             	cmp    %edi,-0x34(%ebp)
  800e1a:	77 05                	ja     800e21 <__umoddi3+0xad>
  800e1c:	39 75 dc             	cmp    %esi,-0x24(%ebp)
  800e1f:	72 10                	jb     800e31 <__umoddi3+0xbd>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e21:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800e24:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800e27:	29 f0                	sub    %esi,%eax
  800e29:	19 fa                	sbb    %edi,%edx
  800e2b:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800e2e:	89 55 cc             	mov    %edx,-0x34(%ebp)
	      else
		q0 = 0;

	      q1 = 0;

	      if (rp != 0)
  800e31:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800e34:	85 d2                	test   %edx,%edx
  800e36:	74 a1                	je     800dd9 <__umoddi3+0x65>
		{
		  rr.s.low = n0;
  800e38:	8b 45 dc             	mov    -0x24(%ebp),%eax
		  rr.s.high = n1;
  800e3b:	8b 55 cc             	mov    -0x34(%ebp),%edx

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  800e3e:	89 45 e0             	mov    %eax,-0x20(%ebp)
		  rr.s.high = n1;
  800e41:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		  *rp = rr.ll;
  800e44:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800e47:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e4a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800e4d:	89 01                	mov    %eax,(%ecx)
  800e4f:	89 51 04             	mov    %edx,0x4(%ecx)
  800e52:	eb 85                	jmp    800dd9 <__umoddi3+0x65>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e54:	85 f6                	test   %esi,%esi
  800e56:	75 0b                	jne    800e63 <__umoddi3+0xef>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e58:	b8 01 00 00 00       	mov    $0x1,%eax
  800e5d:	31 d2                	xor    %edx,%edx
  800e5f:	f7 f6                	div    %esi
  800e61:	89 c6                	mov    %eax,%esi

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e63:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800e66:	89 fa                	mov    %edi,%edx
  800e68:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e6a:	8b 45 dc             	mov    -0x24(%ebp),%eax
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e6d:	89 55 cc             	mov    %edx,-0x34(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e70:	f7 f6                	div    %esi
  800e72:	e9 3d ff ff ff       	jmp    800db4 <__umoddi3+0x40>
  800e77:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e78:	b8 20 00 00 00       	mov    $0x20,%eax
  800e7d:	2b 45 d4             	sub    -0x2c(%ebp),%eax
  800e80:	89 45 d8             	mov    %eax,-0x28(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  800e83:	89 fa                	mov    %edi,%edx
  800e85:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800e88:	d3 e2                	shl    %cl,%edx
  800e8a:	89 f0                	mov    %esi,%eax
  800e8c:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800e8f:	d3 e8                	shr    %cl,%eax
	      d0 = d0 << bm;
  800e91:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800e94:	d3 e6                	shl    %cl,%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e96:	89 d7                	mov    %edx,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800e98:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800e9b:	8b 55 cc             	mov    -0x34(%ebp),%edx
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e9e:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800ea0:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  800ea2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800ea5:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800ea8:	d3 e0                	shl    %cl,%eax
  800eaa:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800ead:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800eb0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800eb3:	d3 e8                	shr    %cl,%eax
  800eb5:	0b 45 cc             	or     -0x34(%ebp),%eax
  800eb8:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n0 = n0 << bm;
  800ebb:	8a 4d d4             	mov    -0x2c(%ebp),%cl

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800ebe:	f7 f7                	div    %edi
  800ec0:	89 55 cc             	mov    %edx,-0x34(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800ec3:	d3 65 dc             	shll   %cl,-0x24(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800ec6:	f7 e6                	mul    %esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ec8:	3b 55 cc             	cmp    -0x34(%ebp),%edx
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800ecb:	89 45 c8             	mov    %eax,-0x38(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ece:	77 0a                	ja     800eda <__umoddi3+0x166>
  800ed0:	75 12                	jne    800ee4 <__umoddi3+0x170>
  800ed2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800ed5:	39 45 c8             	cmp    %eax,-0x38(%ebp)
  800ed8:	76 0a                	jbe    800ee4 <__umoddi3+0x170>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800eda:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800edd:	29 f1                	sub    %esi,%ecx
  800edf:	19 fa                	sbb    %edi,%edx
  800ee1:	89 4d c8             	mov    %ecx,-0x38(%ebp)
		}

	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
  800ee4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ee7:	85 c0                	test   %eax,%eax
  800ee9:	0f 84 ea fe ff ff    	je     800dd9 <__umoddi3+0x65>
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800eef:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800ef2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800ef5:	2b 45 c8             	sub    -0x38(%ebp),%eax
  800ef8:	19 d1                	sbb    %edx,%ecx
  800efa:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800efd:	89 ca                	mov    %ecx,%edx
  800eff:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800f02:	d3 e2                	shl    %cl,%edx
  800f04:	8a 4d d4             	mov    -0x2c(%ebp),%cl
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f07:	89 45 dc             	mov    %eax,-0x24(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f0a:	d3 e8                	shr    %cl,%eax
  800f0c:	09 c2                	or     %eax,%edx
		  rr.s.high = n1 >> bm;
  800f0e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800f11:	d3 e8                	shr    %cl,%eax

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f13:	89 55 e0             	mov    %edx,-0x20(%ebp)
		  rr.s.high = n1 >> bm;
  800f16:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f19:	e9 ad fe ff ff       	jmp    800dcb <__umoddi3+0x57>
