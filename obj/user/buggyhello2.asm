
obj/user/buggyhello2.debug:     file format elf32-i386


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
  80002c:	e8 1b 00 00 00       	call   80004c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  80003a:	68 00 00 10 00       	push   $0x100000
  80003f:	ff 35 00 20 80 00    	pushl  0x802000
  800045:	e8 5e 00 00 00       	call   8000a8 <sys_cputs>
}
  80004a:	c9                   	leave  
  80004b:	c3                   	ret    

0080004c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004c:	55                   	push   %ebp
  80004d:	89 e5                	mov    %esp,%ebp
  80004f:	56                   	push   %esi
  800050:	53                   	push   %ebx
  800051:	8b 75 08             	mov    0x8(%ebp),%esi
  800054:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];	
  800057:	e8 d0 00 00 00       	call   80012c <sys_getenvid>
  80005c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800061:	89 c2                	mov    %eax,%edx
  800063:	c1 e2 05             	shl    $0x5,%edx
  800066:	29 c2                	sub    %eax,%edx
  800068:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  80006f:	89 15 08 20 80 00    	mov    %edx,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800075:	85 f6                	test   %esi,%esi
  800077:	7e 07                	jle    800080 <libmain+0x34>
		binaryname = argv[0];
  800079:	8b 03                	mov    (%ebx),%eax
  80007b:	a3 04 20 80 00       	mov    %eax,0x802004

	// call user main routine
	umain(argc, argv);
  800080:	83 ec 08             	sub    $0x8,%esp
  800083:	53                   	push   %ebx
  800084:	56                   	push   %esi
  800085:	e8 aa ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80008a:	e8 09 00 00 00       	call   800098 <exit>
}
  80008f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800092:	5b                   	pop    %ebx
  800093:	5e                   	pop    %esi
  800094:	c9                   	leave  
  800095:	c3                   	ret    
	...

00800098 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  80009e:	6a 00                	push   $0x0
  8000a0:	e8 46 00 00 00       	call   8000eb <sys_env_destroy>
}
  8000a5:	c9                   	leave  
  8000a6:	c3                   	ret    
	...

008000a8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	57                   	push   %edi
  8000ac:	56                   	push   %esi
  8000ad:	53                   	push   %ebx
  8000ae:	83 ec 04             	sub    $0x4,%esp
  8000b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000b7:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bc:	89 f8                	mov    %edi,%eax
  8000be:	89 fb                	mov    %edi,%ebx
  8000c0:	89 fe                	mov    %edi,%esi
  8000c2:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c4:	83 c4 04             	add    $0x4,%esp
  8000c7:	5b                   	pop    %ebx
  8000c8:	5e                   	pop    %esi
  8000c9:	5f                   	pop    %edi
  8000ca:	c9                   	leave  
  8000cb:	c3                   	ret    

008000cc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	57                   	push   %edi
  8000d0:	56                   	push   %esi
  8000d1:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d7:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000dc:	89 fa                	mov    %edi,%edx
  8000de:	89 f9                	mov    %edi,%ecx
  8000e0:	89 fb                	mov    %edi,%ebx
  8000e2:	89 fe                	mov    %edi,%esi
  8000e4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	c9                   	leave  
  8000ea:	c3                   	ret    

008000eb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 0c             	sub    $0xc,%esp
  8000f4:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000f7:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fc:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800101:	89 f9                	mov    %edi,%ecx
  800103:	89 fb                	mov    %edi,%ebx
  800105:	89 fe                	mov    %edi,%esi
  800107:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800109:	85 c0                	test   %eax,%eax
  80010b:	7e 17                	jle    800124 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010d:	83 ec 0c             	sub    $0xc,%esp
  800110:	50                   	push   %eax
  800111:	6a 03                	push   $0x3
  800113:	68 58 0f 80 00       	push   $0x800f58
  800118:	6a 23                	push   $0x23
  80011a:	68 75 0f 80 00       	push   $0x800f75
  80011f:	e8 38 02 00 00       	call   80035c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800124:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800127:	5b                   	pop    %ebx
  800128:	5e                   	pop    %esi
  800129:	5f                   	pop    %edi
  80012a:	c9                   	leave  
  80012b:	c3                   	ret    

0080012c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	57                   	push   %edi
  800130:	56                   	push   %esi
  800131:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800132:	b8 02 00 00 00       	mov    $0x2,%eax
  800137:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013c:	89 fa                	mov    %edi,%edx
  80013e:	89 f9                	mov    %edi,%ecx
  800140:	89 fb                	mov    %edi,%ebx
  800142:	89 fe                	mov    %edi,%esi
  800144:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800146:	5b                   	pop    %ebx
  800147:	5e                   	pop    %esi
  800148:	5f                   	pop    %edi
  800149:	c9                   	leave  
  80014a:	c3                   	ret    

0080014b <sys_yield>:

void
sys_yield(void)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	57                   	push   %edi
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800151:	b8 0b 00 00 00       	mov    $0xb,%eax
  800156:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015b:	89 fa                	mov    %edi,%edx
  80015d:	89 f9                	mov    %edi,%ecx
  80015f:	89 fb                	mov    %edi,%ebx
  800161:	89 fe                	mov    %edi,%esi
  800163:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800165:	5b                   	pop    %ebx
  800166:	5e                   	pop    %esi
  800167:	5f                   	pop    %edi
  800168:	c9                   	leave  
  800169:	c3                   	ret    

0080016a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	57                   	push   %edi
  80016e:	56                   	push   %esi
  80016f:	53                   	push   %ebx
  800170:	83 ec 0c             	sub    $0xc,%esp
  800173:	8b 55 08             	mov    0x8(%ebp),%edx
  800176:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800179:	8b 5d 10             	mov    0x10(%ebp),%ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80017c:	b8 04 00 00 00       	mov    $0x4,%eax
  800181:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800186:	89 fe                	mov    %edi,%esi
  800188:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80018a:	85 c0                	test   %eax,%eax
  80018c:	7e 17                	jle    8001a5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018e:	83 ec 0c             	sub    $0xc,%esp
  800191:	50                   	push   %eax
  800192:	6a 04                	push   $0x4
  800194:	68 58 0f 80 00       	push   $0x800f58
  800199:	6a 23                	push   $0x23
  80019b:	68 75 0f 80 00       	push   $0x800f75
  8001a0:	e8 b7 01 00 00       	call   80035c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a8:	5b                   	pop    %ebx
  8001a9:	5e                   	pop    %esi
  8001aa:	5f                   	pop    %edi
  8001ab:	c9                   	leave  
  8001ac:	c3                   	ret    

008001ad <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ad:	55                   	push   %ebp
  8001ae:	89 e5                	mov    %esp,%ebp
  8001b0:	57                   	push   %edi
  8001b1:	56                   	push   %esi
  8001b2:	53                   	push   %ebx
  8001b3:	83 ec 0c             	sub    $0xc,%esp
  8001b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bf:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c2:	8b 75 18             	mov    0x18(%ebp),%esi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8001c5:	b8 05 00 00 00       	mov    $0x5,%eax
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ca:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001cc:	85 c0                	test   %eax,%eax
  8001ce:	7e 17                	jle    8001e7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d0:	83 ec 0c             	sub    $0xc,%esp
  8001d3:	50                   	push   %eax
  8001d4:	6a 05                	push   $0x5
  8001d6:	68 58 0f 80 00       	push   $0x800f58
  8001db:	6a 23                	push   $0x23
  8001dd:	68 75 0f 80 00       	push   $0x800f75
  8001e2:	e8 75 01 00 00       	call   80035c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ea:	5b                   	pop    %ebx
  8001eb:	5e                   	pop    %esi
  8001ec:	5f                   	pop    %edi
  8001ed:	c9                   	leave  
  8001ee:	c3                   	ret    

008001ef <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	57                   	push   %edi
  8001f3:	56                   	push   %esi
  8001f4:	53                   	push   %ebx
  8001f5:	83 ec 0c             	sub    $0xc,%esp
  8001f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8001fe:	b8 06 00 00 00       	mov    $0x6,%eax
  800203:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800208:	89 fb                	mov    %edi,%ebx
  80020a:	89 fe                	mov    %edi,%esi
  80020c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80020e:	85 c0                	test   %eax,%eax
  800210:	7e 17                	jle    800229 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	50                   	push   %eax
  800216:	6a 06                	push   $0x6
  800218:	68 58 0f 80 00       	push   $0x800f58
  80021d:	6a 23                	push   $0x23
  80021f:	68 75 0f 80 00       	push   $0x800f75
  800224:	e8 33 01 00 00       	call   80035c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800229:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022c:	5b                   	pop    %ebx
  80022d:	5e                   	pop    %esi
  80022e:	5f                   	pop    %edi
  80022f:	c9                   	leave  
  800230:	c3                   	ret    

00800231 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	57                   	push   %edi
  800235:	56                   	push   %esi
  800236:	53                   	push   %ebx
  800237:	83 ec 0c             	sub    $0xc,%esp
  80023a:	8b 55 08             	mov    0x8(%ebp),%edx
  80023d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800240:	b8 08 00 00 00       	mov    $0x8,%eax
  800245:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80024a:	89 fb                	mov    %edi,%ebx
  80024c:	89 fe                	mov    %edi,%esi
  80024e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800250:	85 c0                	test   %eax,%eax
  800252:	7e 17                	jle    80026b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800254:	83 ec 0c             	sub    $0xc,%esp
  800257:	50                   	push   %eax
  800258:	6a 08                	push   $0x8
  80025a:	68 58 0f 80 00       	push   $0x800f58
  80025f:	6a 23                	push   $0x23
  800261:	68 75 0f 80 00       	push   $0x800f75
  800266:	e8 f1 00 00 00       	call   80035c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80026b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026e:	5b                   	pop    %ebx
  80026f:	5e                   	pop    %esi
  800270:	5f                   	pop    %edi
  800271:	c9                   	leave  
  800272:	c3                   	ret    

00800273 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	57                   	push   %edi
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	83 ec 0c             	sub    $0xc,%esp
  80027c:	8b 55 08             	mov    0x8(%ebp),%edx
  80027f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800282:	b8 09 00 00 00       	mov    $0x9,%eax
  800287:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80028c:	89 fb                	mov    %edi,%ebx
  80028e:	89 fe                	mov    %edi,%esi
  800290:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800292:	85 c0                	test   %eax,%eax
  800294:	7e 17                	jle    8002ad <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800296:	83 ec 0c             	sub    $0xc,%esp
  800299:	50                   	push   %eax
  80029a:	6a 09                	push   $0x9
  80029c:	68 58 0f 80 00       	push   $0x800f58
  8002a1:	6a 23                	push   $0x23
  8002a3:	68 75 0f 80 00       	push   $0x800f75
  8002a8:	e8 af 00 00 00       	call   80035c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b0:	5b                   	pop    %ebx
  8002b1:	5e                   	pop    %esi
  8002b2:	5f                   	pop    %edi
  8002b3:	c9                   	leave  
  8002b4:	c3                   	ret    

008002b5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	57                   	push   %edi
  8002b9:	56                   	push   %esi
  8002ba:	53                   	push   %ebx
  8002bb:	83 ec 0c             	sub    $0xc,%esp
  8002be:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8002c4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c9:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ce:	89 fb                	mov    %edi,%ebx
  8002d0:	89 fe                	mov    %edi,%esi
  8002d2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002d4:	85 c0                	test   %eax,%eax
  8002d6:	7e 17                	jle    8002ef <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d8:	83 ec 0c             	sub    $0xc,%esp
  8002db:	50                   	push   %eax
  8002dc:	6a 0a                	push   $0xa
  8002de:	68 58 0f 80 00       	push   $0x800f58
  8002e3:	6a 23                	push   $0x23
  8002e5:	68 75 0f 80 00       	push   $0x800f75
  8002ea:	e8 6d 00 00 00       	call   80035c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f2:	5b                   	pop    %ebx
  8002f3:	5e                   	pop    %esi
  8002f4:	5f                   	pop    %edi
  8002f5:	c9                   	leave  
  8002f6:	c3                   	ret    

008002f7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	57                   	push   %edi
  8002fb:	56                   	push   %esi
  8002fc:	53                   	push   %ebx
  8002fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800300:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800303:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800306:	8b 7d 14             	mov    0x14(%ebp),%edi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800309:	b8 0c 00 00 00       	mov    $0xc,%eax
  80030e:	be 00 00 00 00       	mov    $0x0,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800313:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800315:	5b                   	pop    %ebx
  800316:	5e                   	pop    %esi
  800317:	5f                   	pop    %edi
  800318:	c9                   	leave  
  800319:	c3                   	ret    

0080031a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	57                   	push   %edi
  80031e:	56                   	push   %esi
  80031f:	53                   	push   %ebx
  800320:	83 ec 0c             	sub    $0xc,%esp
  800323:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800326:	b8 0d 00 00 00       	mov    $0xd,%eax
  80032b:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800330:	89 f9                	mov    %edi,%ecx
  800332:	89 fb                	mov    %edi,%ebx
  800334:	89 fe                	mov    %edi,%esi
  800336:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800338:	85 c0                	test   %eax,%eax
  80033a:	7e 17                	jle    800353 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80033c:	83 ec 0c             	sub    $0xc,%esp
  80033f:	50                   	push   %eax
  800340:	6a 0d                	push   $0xd
  800342:	68 58 0f 80 00       	push   $0x800f58
  800347:	6a 23                	push   $0x23
  800349:	68 75 0f 80 00       	push   $0x800f75
  80034e:	e8 09 00 00 00       	call   80035c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800353:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800356:	5b                   	pop    %ebx
  800357:	5e                   	pop    %esi
  800358:	5f                   	pop    %edi
  800359:	c9                   	leave  
  80035a:	c3                   	ret    
	...

0080035c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80035c:	55                   	push   %ebp
  80035d:	89 e5                	mov    %esp,%ebp
  80035f:	53                   	push   %ebx
  800360:	83 ec 10             	sub    $0x10,%esp
	va_list ap;

	va_start(ap, fmt);
  800363:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800366:	ff 75 0c             	pushl  0xc(%ebp)
  800369:	ff 75 08             	pushl  0x8(%ebp)
  80036c:	ff 35 04 20 80 00    	pushl  0x802004
  800372:	83 ec 08             	sub    $0x8,%esp
  800375:	e8 b2 fd ff ff       	call   80012c <sys_getenvid>
  80037a:	83 c4 08             	add    $0x8,%esp
  80037d:	50                   	push   %eax
  80037e:	68 84 0f 80 00       	push   $0x800f84
  800383:	e8 b0 00 00 00       	call   800438 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800388:	83 c4 18             	add    $0x18,%esp
  80038b:	53                   	push   %ebx
  80038c:	ff 75 10             	pushl  0x10(%ebp)
  80038f:	e8 53 00 00 00       	call   8003e7 <vcprintf>
	cprintf("\n");
  800394:	c7 04 24 4c 0f 80 00 	movl   $0x800f4c,(%esp)
  80039b:	e8 98 00 00 00       	call   800438 <cprintf>

	// Cause a breakpoint exception
	while (1)
  8003a0:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  8003a3:	cc                   	int3   
  8003a4:	eb fd                	jmp    8003a3 <_panic+0x47>
	...

008003a8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003a8:	55                   	push   %ebp
  8003a9:	89 e5                	mov    %esp,%ebp
  8003ab:	53                   	push   %ebx
  8003ac:	83 ec 04             	sub    $0x4,%esp
  8003af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003b2:	8b 03                	mov    (%ebx),%eax
  8003b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b7:	88 54 18 08          	mov    %dl,0x8(%eax,%ebx,1)
  8003bb:	40                   	inc    %eax
  8003bc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8003be:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003c3:	75 1a                	jne    8003df <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8003c5:	83 ec 08             	sub    $0x8,%esp
  8003c8:	68 ff 00 00 00       	push   $0xff
  8003cd:	8d 43 08             	lea    0x8(%ebx),%eax
  8003d0:	50                   	push   %eax
  8003d1:	e8 d2 fc ff ff       	call   8000a8 <sys_cputs>
		b->idx = 0;
  8003d6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003dc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003df:	ff 43 04             	incl   0x4(%ebx)
}
  8003e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003e5:	c9                   	leave  
  8003e6:	c3                   	ret    

008003e7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003e7:	55                   	push   %ebp
  8003e8:	89 e5                	mov    %esp,%ebp
  8003ea:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003f0:	c7 85 e8 fe ff ff 00 	movl   $0x0,-0x118(%ebp)
  8003f7:	00 00 00 
	b.cnt = 0;
  8003fa:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  800401:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800404:	ff 75 0c             	pushl  0xc(%ebp)
  800407:	ff 75 08             	pushl  0x8(%ebp)
  80040a:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800410:	50                   	push   %eax
  800411:	68 a8 03 80 00       	push   $0x8003a8
  800416:	e8 49 01 00 00       	call   800564 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80041b:	83 c4 08             	add    $0x8,%esp
  80041e:	ff b5 e8 fe ff ff    	pushl  -0x118(%ebp)
  800424:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80042a:	50                   	push   %eax
  80042b:	e8 78 fc ff ff       	call   8000a8 <sys_cputs>

	return b.cnt;
  800430:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
}
  800436:	c9                   	leave  
  800437:	c3                   	ret    

00800438 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800438:	55                   	push   %ebp
  800439:	89 e5                	mov    %esp,%ebp
  80043b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80043e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800441:	50                   	push   %eax
  800442:	ff 75 08             	pushl  0x8(%ebp)
  800445:	e8 9d ff ff ff       	call   8003e7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80044a:	c9                   	leave  
  80044b:	c3                   	ret    

0080044c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80044c:	55                   	push   %ebp
  80044d:	89 e5                	mov    %esp,%ebp
  80044f:	57                   	push   %edi
  800450:	56                   	push   %esi
  800451:	53                   	push   %ebx
  800452:	83 ec 0c             	sub    $0xc,%esp
  800455:	8b 75 10             	mov    0x10(%ebp),%esi
  800458:	8b 7d 14             	mov    0x14(%ebp),%edi
  80045b:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80045e:	8b 45 18             	mov    0x18(%ebp),%eax
  800461:	ba 00 00 00 00       	mov    $0x0,%edx
  800466:	39 fa                	cmp    %edi,%edx
  800468:	77 39                	ja     8004a3 <printnum+0x57>
  80046a:	72 04                	jb     800470 <printnum+0x24>
  80046c:	39 f0                	cmp    %esi,%eax
  80046e:	77 33                	ja     8004a3 <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800470:	83 ec 04             	sub    $0x4,%esp
  800473:	ff 75 20             	pushl  0x20(%ebp)
  800476:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800479:	50                   	push   %eax
  80047a:	ff 75 18             	pushl  0x18(%ebp)
  80047d:	8b 45 18             	mov    0x18(%ebp),%eax
  800480:	ba 00 00 00 00       	mov    $0x0,%edx
  800485:	52                   	push   %edx
  800486:	50                   	push   %eax
  800487:	57                   	push   %edi
  800488:	56                   	push   %esi
  800489:	e8 de 07 00 00       	call   800c6c <__udivdi3>
  80048e:	83 c4 10             	add    $0x10,%esp
  800491:	52                   	push   %edx
  800492:	50                   	push   %eax
  800493:	ff 75 0c             	pushl  0xc(%ebp)
  800496:	ff 75 08             	pushl  0x8(%ebp)
  800499:	e8 ae ff ff ff       	call   80044c <printnum>
  80049e:	83 c4 20             	add    $0x20,%esp
  8004a1:	eb 19                	jmp    8004bc <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004a3:	4b                   	dec    %ebx
  8004a4:	85 db                	test   %ebx,%ebx
  8004a6:	7e 14                	jle    8004bc <printnum+0x70>
  8004a8:	83 ec 08             	sub    $0x8,%esp
  8004ab:	ff 75 0c             	pushl  0xc(%ebp)
  8004ae:	ff 75 20             	pushl  0x20(%ebp)
  8004b1:	ff 55 08             	call   *0x8(%ebp)
  8004b4:	83 c4 10             	add    $0x10,%esp
  8004b7:	4b                   	dec    %ebx
  8004b8:	85 db                	test   %ebx,%ebx
  8004ba:	7f ec                	jg     8004a8 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004bc:	83 ec 08             	sub    $0x8,%esp
  8004bf:	ff 75 0c             	pushl  0xc(%ebp)
  8004c2:	8b 45 18             	mov    0x18(%ebp),%eax
  8004c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ca:	83 ec 04             	sub    $0x4,%esp
  8004cd:	52                   	push   %edx
  8004ce:	50                   	push   %eax
  8004cf:	57                   	push   %edi
  8004d0:	56                   	push   %esi
  8004d1:	e8 a2 08 00 00       	call   800d78 <__umoddi3>
  8004d6:	83 c4 14             	add    $0x14,%esp
  8004d9:	0f be 80 b9 10 80 00 	movsbl 0x8010b9(%eax),%eax
  8004e0:	50                   	push   %eax
  8004e1:	ff 55 08             	call   *0x8(%ebp)
}
  8004e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004e7:	5b                   	pop    %ebx
  8004e8:	5e                   	pop    %esi
  8004e9:	5f                   	pop    %edi
  8004ea:	c9                   	leave  
  8004eb:	c3                   	ret    

008004ec <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004ec:	55                   	push   %ebp
  8004ed:	89 e5                	mov    %esp,%ebp
  8004ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004f2:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  8004f5:	83 f8 01             	cmp    $0x1,%eax
  8004f8:	7e 0e                	jle    800508 <getuint+0x1c>
		return va_arg(*ap, unsigned long long);
  8004fa:	8b 11                	mov    (%ecx),%edx
  8004fc:	8d 42 08             	lea    0x8(%edx),%eax
  8004ff:	89 01                	mov    %eax,(%ecx)
  800501:	8b 02                	mov    (%edx),%eax
  800503:	8b 52 04             	mov    0x4(%edx),%edx
  800506:	eb 22                	jmp    80052a <getuint+0x3e>
	else if (lflag)
  800508:	85 c0                	test   %eax,%eax
  80050a:	74 10                	je     80051c <getuint+0x30>
		return va_arg(*ap, unsigned long);
  80050c:	8b 11                	mov    (%ecx),%edx
  80050e:	8d 42 04             	lea    0x4(%edx),%eax
  800511:	89 01                	mov    %eax,(%ecx)
  800513:	8b 02                	mov    (%edx),%eax
  800515:	ba 00 00 00 00       	mov    $0x0,%edx
  80051a:	eb 0e                	jmp    80052a <getuint+0x3e>
	else
		return va_arg(*ap, unsigned int);
  80051c:	8b 11                	mov    (%ecx),%edx
  80051e:	8d 42 04             	lea    0x4(%edx),%eax
  800521:	89 01                	mov    %eax,(%ecx)
  800523:	8b 02                	mov    (%edx),%eax
  800525:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80052a:	c9                   	leave  
  80052b:	c3                   	ret    

0080052c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80052c:	55                   	push   %ebp
  80052d:	89 e5                	mov    %esp,%ebp
  80052f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800532:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800535:	83 f8 01             	cmp    $0x1,%eax
  800538:	7e 0e                	jle    800548 <getint+0x1c>
		return va_arg(*ap, long long);
  80053a:	8b 11                	mov    (%ecx),%edx
  80053c:	8d 42 08             	lea    0x8(%edx),%eax
  80053f:	89 01                	mov    %eax,(%ecx)
  800541:	8b 02                	mov    (%edx),%eax
  800543:	8b 52 04             	mov    0x4(%edx),%edx
  800546:	eb 1a                	jmp    800562 <getint+0x36>
	else if (lflag)
  800548:	85 c0                	test   %eax,%eax
  80054a:	74 0c                	je     800558 <getint+0x2c>
		return va_arg(*ap, long);
  80054c:	8b 01                	mov    (%ecx),%eax
  80054e:	8d 50 04             	lea    0x4(%eax),%edx
  800551:	89 11                	mov    %edx,(%ecx)
  800553:	8b 00                	mov    (%eax),%eax
  800555:	99                   	cltd   
  800556:	eb 0a                	jmp    800562 <getint+0x36>
	else
		return va_arg(*ap, int);
  800558:	8b 01                	mov    (%ecx),%eax
  80055a:	8d 50 04             	lea    0x4(%eax),%edx
  80055d:	89 11                	mov    %edx,(%ecx)
  80055f:	8b 00                	mov    (%eax),%eax
  800561:	99                   	cltd   
}
  800562:	c9                   	leave  
  800563:	c3                   	ret    

00800564 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800564:	55                   	push   %ebp
  800565:	89 e5                	mov    %esp,%ebp
  800567:	57                   	push   %edi
  800568:	56                   	push   %esi
  800569:	53                   	push   %ebx
  80056a:	83 ec 1c             	sub    $0x1c,%esp
  80056d:	8b 5d 10             	mov    0x10(%ebp),%ebx

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
			putch(ch, putdat);
  800570:	0f b6 0b             	movzbl (%ebx),%ecx
  800573:	43                   	inc    %ebx
  800574:	83 f9 25             	cmp    $0x25,%ecx
  800577:	74 1e                	je     800597 <vprintfmt+0x33>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800579:	85 c9                	test   %ecx,%ecx
  80057b:	0f 84 dc 02 00 00    	je     80085d <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  800581:	83 ec 08             	sub    $0x8,%esp
  800584:	ff 75 0c             	pushl  0xc(%ebp)
  800587:	51                   	push   %ecx
  800588:	ff 55 08             	call   *0x8(%ebp)
  80058b:	83 c4 10             	add    $0x10,%esp
  80058e:	0f b6 0b             	movzbl (%ebx),%ecx
  800591:	43                   	inc    %ebx
  800592:	83 f9 25             	cmp    $0x25,%ecx
  800595:	75 e2                	jne    800579 <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  800597:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
		width = -1;
  80059b:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
		precision = -1;
  8005a2:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  8005a7:	bf 00 00 00 00       	mov    $0x0,%edi
		altflag = 0;
  8005ac:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b3:	0f b6 0b             	movzbl (%ebx),%ecx
  8005b6:	8d 41 dd             	lea    -0x23(%ecx),%eax
  8005b9:	43                   	inc    %ebx
  8005ba:	83 f8 55             	cmp    $0x55,%eax
  8005bd:	0f 87 75 02 00 00    	ja     800838 <vprintfmt+0x2d4>
  8005c3:	ff 24 85 40 11 80 00 	jmp    *0x801140(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  8005ca:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
			goto reswitch;
  8005ce:	eb e3                	jmp    8005b3 <vprintfmt+0x4f>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005d0:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
			goto reswitch;
  8005d4:	eb dd                	jmp    8005b3 <vprintfmt+0x4f>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005d6:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  8005db:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  8005de:	8d 74 41 d0          	lea    -0x30(%ecx,%eax,2),%esi
				ch = *fmt;
  8005e2:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  8005e5:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8005e8:	83 f8 09             	cmp    $0x9,%eax
  8005eb:	77 28                	ja     800615 <vprintfmt+0xb1>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005ed:	43                   	inc    %ebx
  8005ee:	eb eb                	jmp    8005db <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005f0:	8b 55 14             	mov    0x14(%ebp),%edx
  8005f3:	8d 42 04             	lea    0x4(%edx),%eax
  8005f6:	89 45 14             	mov    %eax,0x14(%ebp)
  8005f9:	8b 32                	mov    (%edx),%esi
			goto process_precision;
  8005fb:	eb 18                	jmp    800615 <vprintfmt+0xb1>

		case '.':
			if (width < 0)
  8005fd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800601:	79 b0                	jns    8005b3 <vprintfmt+0x4f>
				width = 0;
  800603:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
			goto reswitch;
  80060a:	eb a7                	jmp    8005b3 <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  80060c:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
			goto reswitch;
  800613:	eb 9e                	jmp    8005b3 <vprintfmt+0x4f>

		process_precision:
			if (width < 0)
  800615:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800619:	79 98                	jns    8005b3 <vprintfmt+0x4f>
				width = precision, precision = -1;
  80061b:	89 75 f0             	mov    %esi,-0x10(%ebp)
  80061e:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  800623:	eb 8e                	jmp    8005b3 <vprintfmt+0x4f>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800625:	47                   	inc    %edi
			goto reswitch;
  800626:	eb 8b                	jmp    8005b3 <vprintfmt+0x4f>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800628:	83 ec 08             	sub    $0x8,%esp
  80062b:	ff 75 0c             	pushl  0xc(%ebp)
  80062e:	8b 55 14             	mov    0x14(%ebp),%edx
  800631:	8d 42 04             	lea    0x4(%edx),%eax
  800634:	89 45 14             	mov    %eax,0x14(%ebp)
  800637:	ff 32                	pushl  (%edx)
  800639:	ff 55 08             	call   *0x8(%ebp)
			break;
  80063c:	83 c4 10             	add    $0x10,%esp
  80063f:	e9 2c ff ff ff       	jmp    800570 <vprintfmt+0xc>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800644:	8b 55 14             	mov    0x14(%ebp),%edx
  800647:	8d 42 04             	lea    0x4(%edx),%eax
  80064a:	89 45 14             	mov    %eax,0x14(%ebp)
  80064d:	8b 02                	mov    (%edx),%eax
			if (err < 0)
  80064f:	85 c0                	test   %eax,%eax
  800651:	79 02                	jns    800655 <vprintfmt+0xf1>
				err = -err;
  800653:	f7 d8                	neg    %eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800655:	83 f8 0f             	cmp    $0xf,%eax
  800658:	7f 0b                	jg     800665 <vprintfmt+0x101>
  80065a:	8b 3c 85 00 11 80 00 	mov    0x801100(,%eax,4),%edi
  800661:	85 ff                	test   %edi,%edi
  800663:	75 19                	jne    80067e <vprintfmt+0x11a>
				printfmt(putch, putdat, "error %d", err);
  800665:	50                   	push   %eax
  800666:	68 ca 10 80 00       	push   $0x8010ca
  80066b:	ff 75 0c             	pushl  0xc(%ebp)
  80066e:	ff 75 08             	pushl  0x8(%ebp)
  800671:	e8 ef 01 00 00       	call   800865 <printfmt>
  800676:	83 c4 10             	add    $0x10,%esp
  800679:	e9 f2 fe ff ff       	jmp    800570 <vprintfmt+0xc>
			else
				printfmt(putch, putdat, "%s", p);
  80067e:	57                   	push   %edi
  80067f:	68 d3 10 80 00       	push   $0x8010d3
  800684:	ff 75 0c             	pushl  0xc(%ebp)
  800687:	ff 75 08             	pushl  0x8(%ebp)
  80068a:	e8 d6 01 00 00       	call   800865 <printfmt>
  80068f:	83 c4 10             	add    $0x10,%esp
			break;
  800692:	e9 d9 fe ff ff       	jmp    800570 <vprintfmt+0xc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800697:	8b 55 14             	mov    0x14(%ebp),%edx
  80069a:	8d 42 04             	lea    0x4(%edx),%eax
  80069d:	89 45 14             	mov    %eax,0x14(%ebp)
  8006a0:	8b 3a                	mov    (%edx),%edi
  8006a2:	85 ff                	test   %edi,%edi
  8006a4:	75 05                	jne    8006ab <vprintfmt+0x147>
				p = "(null)";
  8006a6:	bf d6 10 80 00       	mov    $0x8010d6,%edi
			if (width > 0 && padc != '-')
  8006ab:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8006af:	7e 3b                	jle    8006ec <vprintfmt+0x188>
  8006b1:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  8006b5:	74 35                	je     8006ec <vprintfmt+0x188>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b7:	83 ec 08             	sub    $0x8,%esp
  8006ba:	56                   	push   %esi
  8006bb:	57                   	push   %edi
  8006bc:	e8 58 02 00 00       	call   800919 <strnlen>
  8006c1:	29 45 f0             	sub    %eax,-0x10(%ebp)
  8006c4:	83 c4 10             	add    $0x10,%esp
  8006c7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8006cb:	7e 1f                	jle    8006ec <vprintfmt+0x188>
  8006cd:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  8006d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
					putch(padc, putdat);
  8006d4:	83 ec 08             	sub    $0x8,%esp
  8006d7:	ff 75 0c             	pushl  0xc(%ebp)
  8006da:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006dd:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e0:	83 c4 10             	add    $0x10,%esp
  8006e3:	ff 4d f0             	decl   -0x10(%ebp)
  8006e6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8006ea:	7f e8                	jg     8006d4 <vprintfmt+0x170>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ec:	0f be 0f             	movsbl (%edi),%ecx
  8006ef:	47                   	inc    %edi
  8006f0:	85 c9                	test   %ecx,%ecx
  8006f2:	74 44                	je     800738 <vprintfmt+0x1d4>
  8006f4:	85 f6                	test   %esi,%esi
  8006f6:	78 03                	js     8006fb <vprintfmt+0x197>
  8006f8:	4e                   	dec    %esi
  8006f9:	78 3d                	js     800738 <vprintfmt+0x1d4>
				if (altflag && (ch < ' ' || ch > '~'))
  8006fb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8006ff:	74 18                	je     800719 <vprintfmt+0x1b5>
  800701:	8d 41 e0             	lea    -0x20(%ecx),%eax
  800704:	83 f8 5e             	cmp    $0x5e,%eax
  800707:	76 10                	jbe    800719 <vprintfmt+0x1b5>
					putch('?', putdat);
  800709:	83 ec 08             	sub    $0x8,%esp
  80070c:	ff 75 0c             	pushl  0xc(%ebp)
  80070f:	6a 3f                	push   $0x3f
  800711:	ff 55 08             	call   *0x8(%ebp)
  800714:	83 c4 10             	add    $0x10,%esp
  800717:	eb 0d                	jmp    800726 <vprintfmt+0x1c2>
				else
					putch(ch, putdat);
  800719:	83 ec 08             	sub    $0x8,%esp
  80071c:	ff 75 0c             	pushl  0xc(%ebp)
  80071f:	51                   	push   %ecx
  800720:	ff 55 08             	call   *0x8(%ebp)
  800723:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800726:	ff 4d f0             	decl   -0x10(%ebp)
  800729:	0f be 0f             	movsbl (%edi),%ecx
  80072c:	47                   	inc    %edi
  80072d:	85 c9                	test   %ecx,%ecx
  80072f:	74 07                	je     800738 <vprintfmt+0x1d4>
  800731:	85 f6                	test   %esi,%esi
  800733:	78 c6                	js     8006fb <vprintfmt+0x197>
  800735:	4e                   	dec    %esi
  800736:	79 c3                	jns    8006fb <vprintfmt+0x197>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800738:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80073c:	0f 8e 2e fe ff ff    	jle    800570 <vprintfmt+0xc>
				putch(' ', putdat);
  800742:	83 ec 08             	sub    $0x8,%esp
  800745:	ff 75 0c             	pushl  0xc(%ebp)
  800748:	6a 20                	push   $0x20
  80074a:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80074d:	83 c4 10             	add    $0x10,%esp
  800750:	ff 4d f0             	decl   -0x10(%ebp)
  800753:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800757:	7f e9                	jg     800742 <vprintfmt+0x1de>
				putch(' ', putdat);
			break;
  800759:	e9 12 fe ff ff       	jmp    800570 <vprintfmt+0xc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80075e:	57                   	push   %edi
  80075f:	8d 45 14             	lea    0x14(%ebp),%eax
  800762:	50                   	push   %eax
  800763:	e8 c4 fd ff ff       	call   80052c <getint>
  800768:	89 c6                	mov    %eax,%esi
  80076a:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  80076c:	83 c4 08             	add    $0x8,%esp
  80076f:	85 d2                	test   %edx,%edx
  800771:	79 15                	jns    800788 <vprintfmt+0x224>
				putch('-', putdat);
  800773:	83 ec 08             	sub    $0x8,%esp
  800776:	ff 75 0c             	pushl  0xc(%ebp)
  800779:	6a 2d                	push   $0x2d
  80077b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80077e:	f7 de                	neg    %esi
  800780:	83 d7 00             	adc    $0x0,%edi
  800783:	f7 df                	neg    %edi
  800785:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800788:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  80078d:	eb 76                	jmp    800805 <vprintfmt+0x2a1>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80078f:	57                   	push   %edi
  800790:	8d 45 14             	lea    0x14(%ebp),%eax
  800793:	50                   	push   %eax
  800794:	e8 53 fd ff ff       	call   8004ec <getuint>
  800799:	89 c6                	mov    %eax,%esi
  80079b:	89 d7                	mov    %edx,%edi
			base = 10;
  80079d:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8007a2:	83 c4 08             	add    $0x8,%esp
  8007a5:	eb 5e                	jmp    800805 <vprintfmt+0x2a1>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8007a7:	57                   	push   %edi
  8007a8:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ab:	50                   	push   %eax
  8007ac:	e8 3b fd ff ff       	call   8004ec <getuint>
  8007b1:	89 c6                	mov    %eax,%esi
  8007b3:	89 d7                	mov    %edx,%edi
			base = 8;
  8007b5:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  8007ba:	83 c4 08             	add    $0x8,%esp
  8007bd:	eb 46                	jmp    800805 <vprintfmt+0x2a1>

		// pointer
		case 'p':
			putch('0', putdat);
  8007bf:	83 ec 08             	sub    $0x8,%esp
  8007c2:	ff 75 0c             	pushl  0xc(%ebp)
  8007c5:	6a 30                	push   $0x30
  8007c7:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007ca:	83 c4 08             	add    $0x8,%esp
  8007cd:	ff 75 0c             	pushl  0xc(%ebp)
  8007d0:	6a 78                	push   $0x78
  8007d2:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8007d5:	8b 55 14             	mov    0x14(%ebp),%edx
  8007d8:	8d 42 04             	lea    0x4(%edx),%eax
  8007db:	89 45 14             	mov    %eax,0x14(%ebp)
  8007de:	8b 32                	mov    (%edx),%esi
  8007e0:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007e5:	ba 10 00 00 00       	mov    $0x10,%edx
			goto number;
  8007ea:	83 c4 10             	add    $0x10,%esp
  8007ed:	eb 16                	jmp    800805 <vprintfmt+0x2a1>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007ef:	57                   	push   %edi
  8007f0:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f3:	50                   	push   %eax
  8007f4:	e8 f3 fc ff ff       	call   8004ec <getuint>
  8007f9:	89 c6                	mov    %eax,%esi
  8007fb:	89 d7                	mov    %edx,%edi
			base = 16;
  8007fd:	ba 10 00 00 00       	mov    $0x10,%edx
  800802:	83 c4 08             	add    $0x8,%esp
		number:
			printnum(putch, putdat, num, base, width, padc);
  800805:	83 ec 04             	sub    $0x4,%esp
  800808:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  80080c:	50                   	push   %eax
  80080d:	ff 75 f0             	pushl  -0x10(%ebp)
  800810:	52                   	push   %edx
  800811:	57                   	push   %edi
  800812:	56                   	push   %esi
  800813:	ff 75 0c             	pushl  0xc(%ebp)
  800816:	ff 75 08             	pushl  0x8(%ebp)
  800819:	e8 2e fc ff ff       	call   80044c <printnum>
			break;
  80081e:	83 c4 20             	add    $0x20,%esp
  800821:	e9 4a fd ff ff       	jmp    800570 <vprintfmt+0xc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800826:	83 ec 08             	sub    $0x8,%esp
  800829:	ff 75 0c             	pushl  0xc(%ebp)
  80082c:	51                   	push   %ecx
  80082d:	ff 55 08             	call   *0x8(%ebp)
			break;
  800830:	83 c4 10             	add    $0x10,%esp
  800833:	e9 38 fd ff ff       	jmp    800570 <vprintfmt+0xc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800838:	83 ec 08             	sub    $0x8,%esp
  80083b:	ff 75 0c             	pushl  0xc(%ebp)
  80083e:	6a 25                	push   $0x25
  800840:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800843:	4b                   	dec    %ebx
  800844:	83 c4 10             	add    $0x10,%esp
  800847:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80084b:	0f 84 1f fd ff ff    	je     800570 <vprintfmt+0xc>
  800851:	4b                   	dec    %ebx
  800852:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800856:	75 f9                	jne    800851 <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  800858:	e9 13 fd ff ff       	jmp    800570 <vprintfmt+0xc>
		}
	}
}
  80085d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800860:	5b                   	pop    %ebx
  800861:	5e                   	pop    %esi
  800862:	5f                   	pop    %edi
  800863:	c9                   	leave  
  800864:	c3                   	ret    

00800865 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80086b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80086e:	50                   	push   %eax
  80086f:	ff 75 10             	pushl  0x10(%ebp)
  800872:	ff 75 0c             	pushl  0xc(%ebp)
  800875:	ff 75 08             	pushl  0x8(%ebp)
  800878:	e8 e7 fc ff ff       	call   800564 <vprintfmt>
	va_end(ap);
}
  80087d:	c9                   	leave  
  80087e:	c3                   	ret    

0080087f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  800885:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  800888:	8b 0a                	mov    (%edx),%ecx
  80088a:	3b 4a 04             	cmp    0x4(%edx),%ecx
  80088d:	73 07                	jae    800896 <sprintputch+0x17>
		*b->buf++ = ch;
  80088f:	8b 45 08             	mov    0x8(%ebp),%eax
  800892:	88 01                	mov    %al,(%ecx)
  800894:	ff 02                	incl   (%edx)
}
  800896:	c9                   	leave  
  800897:	c3                   	ret    

00800898 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	83 ec 18             	sub    $0x18,%esp
  80089e:	8b 55 08             	mov    0x8(%ebp),%edx
  8008a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008a4:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8008a7:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
  8008ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008ae:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

	if (buf == NULL || n < 1)
  8008b5:	85 d2                	test   %edx,%edx
  8008b7:	74 04                	je     8008bd <vsnprintf+0x25>
  8008b9:	85 c9                	test   %ecx,%ecx
  8008bb:	7f 07                	jg     8008c4 <vsnprintf+0x2c>
		return -E_INVAL;
  8008bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008c2:	eb 1d                	jmp    8008e1 <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008c4:	ff 75 14             	pushl  0x14(%ebp)
  8008c7:	ff 75 10             	pushl  0x10(%ebp)
  8008ca:	8d 45 e8             	lea    -0x18(%ebp),%eax
  8008cd:	50                   	push   %eax
  8008ce:	68 7f 08 80 00       	push   $0x80087f
  8008d3:	e8 8c fc ff ff       	call   800564 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8008db:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008de:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8008e1:	c9                   	leave  
  8008e2:	c3                   	ret    

008008e3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008e9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008ec:	50                   	push   %eax
  8008ed:	ff 75 10             	pushl  0x10(%ebp)
  8008f0:	ff 75 0c             	pushl  0xc(%ebp)
  8008f3:	ff 75 08             	pushl  0x8(%ebp)
  8008f6:	e8 9d ff ff ff       	call   800898 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008fb:	c9                   	leave  
  8008fc:	c3                   	ret    
  8008fd:	00 00                	add    %al,(%eax)
	...

00800900 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800906:	b8 00 00 00 00       	mov    $0x0,%eax
  80090b:	80 3a 00             	cmpb   $0x0,(%edx)
  80090e:	74 07                	je     800917 <strlen+0x17>
		n++;
  800910:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800911:	42                   	inc    %edx
  800912:	80 3a 00             	cmpb   $0x0,(%edx)
  800915:	75 f9                	jne    800910 <strlen+0x10>
		n++;
	return n;
}
  800917:	c9                   	leave  
  800918:	c3                   	ret    

00800919 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80091f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800922:	b8 00 00 00 00       	mov    $0x0,%eax
  800927:	85 d2                	test   %edx,%edx
  800929:	74 0f                	je     80093a <strnlen+0x21>
  80092b:	80 39 00             	cmpb   $0x0,(%ecx)
  80092e:	74 0a                	je     80093a <strnlen+0x21>
		n++;
  800930:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800931:	41                   	inc    %ecx
  800932:	4a                   	dec    %edx
  800933:	74 05                	je     80093a <strnlen+0x21>
  800935:	80 39 00             	cmpb   $0x0,(%ecx)
  800938:	75 f6                	jne    800930 <strnlen+0x17>
		n++;
	return n;
}
  80093a:	c9                   	leave  
  80093b:	c3                   	ret    

0080093c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
  80093f:	53                   	push   %ebx
  800940:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800943:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  800946:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  800948:	8a 02                	mov    (%edx),%al
  80094a:	42                   	inc    %edx
  80094b:	88 01                	mov    %al,(%ecx)
  80094d:	41                   	inc    %ecx
  80094e:	84 c0                	test   %al,%al
  800950:	75 f6                	jne    800948 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800952:	89 d8                	mov    %ebx,%eax
  800954:	5b                   	pop    %ebx
  800955:	c9                   	leave  
  800956:	c3                   	ret    

00800957 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	53                   	push   %ebx
  80095b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80095e:	53                   	push   %ebx
  80095f:	e8 9c ff ff ff       	call   800900 <strlen>
	strcpy(dst + len, src);
  800964:	ff 75 0c             	pushl  0xc(%ebp)
  800967:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80096a:	50                   	push   %eax
  80096b:	e8 cc ff ff ff       	call   80093c <strcpy>
	return dst;
}
  800970:	89 d8                	mov    %ebx,%eax
  800972:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800975:	c9                   	leave  
  800976:	c3                   	ret    

00800977 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	57                   	push   %edi
  80097b:	56                   	push   %esi
  80097c:	53                   	push   %ebx
  80097d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800980:	8b 55 0c             	mov    0xc(%ebp),%edx
  800983:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  800986:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  800988:	bb 00 00 00 00       	mov    $0x0,%ebx
  80098d:	39 f3                	cmp    %esi,%ebx
  80098f:	73 10                	jae    8009a1 <strncpy+0x2a>
		*dst++ = *src;
  800991:	8a 02                	mov    (%edx),%al
  800993:	88 01                	mov    %al,(%ecx)
  800995:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800996:	80 3a 01             	cmpb   $0x1,(%edx)
  800999:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80099c:	43                   	inc    %ebx
  80099d:	39 f3                	cmp    %esi,%ebx
  80099f:	72 f0                	jb     800991 <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009a1:	89 f8                	mov    %edi,%eax
  8009a3:	5b                   	pop    %ebx
  8009a4:	5e                   	pop    %esi
  8009a5:	5f                   	pop    %edi
  8009a6:	c9                   	leave  
  8009a7:	c3                   	ret    

008009a8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009a8:	55                   	push   %ebp
  8009a9:	89 e5                	mov    %esp,%ebp
  8009ab:	56                   	push   %esi
  8009ac:	53                   	push   %ebx
  8009ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009b3:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  8009b6:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  8009b8:	85 d2                	test   %edx,%edx
  8009ba:	74 19                	je     8009d5 <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009bc:	4a                   	dec    %edx
  8009bd:	74 13                	je     8009d2 <strlcpy+0x2a>
  8009bf:	80 39 00             	cmpb   $0x0,(%ecx)
  8009c2:	74 0e                	je     8009d2 <strlcpy+0x2a>
  8009c4:	8a 01                	mov    (%ecx),%al
  8009c6:	41                   	inc    %ecx
  8009c7:	88 03                	mov    %al,(%ebx)
  8009c9:	43                   	inc    %ebx
  8009ca:	4a                   	dec    %edx
  8009cb:	74 05                	je     8009d2 <strlcpy+0x2a>
  8009cd:	80 39 00             	cmpb   $0x0,(%ecx)
  8009d0:	75 f2                	jne    8009c4 <strlcpy+0x1c>
		*dst = '\0';
  8009d2:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  8009d5:	89 d8                	mov    %ebx,%eax
  8009d7:	29 f0                	sub    %esi,%eax
}
  8009d9:	5b                   	pop    %ebx
  8009da:	5e                   	pop    %esi
  8009db:	c9                   	leave  
  8009dc:	c3                   	ret    

008009dd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8009e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
		p++, q++;
  8009e6:	80 3a 00             	cmpb   $0x0,(%edx)
  8009e9:	74 13                	je     8009fe <strcmp+0x21>
  8009eb:	8a 02                	mov    (%edx),%al
  8009ed:	3a 01                	cmp    (%ecx),%al
  8009ef:	75 0d                	jne    8009fe <strcmp+0x21>
  8009f1:	42                   	inc    %edx
  8009f2:	41                   	inc    %ecx
  8009f3:	80 3a 00             	cmpb   $0x0,(%edx)
  8009f6:	74 06                	je     8009fe <strcmp+0x21>
  8009f8:	8a 02                	mov    (%edx),%al
  8009fa:	3a 01                	cmp    (%ecx),%al
  8009fc:	74 f3                	je     8009f1 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009fe:	0f b6 02             	movzbl (%edx),%eax
  800a01:	0f b6 11             	movzbl (%ecx),%edx
  800a04:	29 d0                	sub    %edx,%eax
}
  800a06:	c9                   	leave  
  800a07:	c3                   	ret    

00800a08 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	53                   	push   %ebx
  800a0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a0f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a12:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800a15:	85 c9                	test   %ecx,%ecx
  800a17:	74 1f                	je     800a38 <strncmp+0x30>
  800a19:	80 3a 00             	cmpb   $0x0,(%edx)
  800a1c:	74 16                	je     800a34 <strncmp+0x2c>
  800a1e:	8a 02                	mov    (%edx),%al
  800a20:	3a 03                	cmp    (%ebx),%al
  800a22:	75 10                	jne    800a34 <strncmp+0x2c>
  800a24:	42                   	inc    %edx
  800a25:	43                   	inc    %ebx
  800a26:	49                   	dec    %ecx
  800a27:	74 0f                	je     800a38 <strncmp+0x30>
  800a29:	80 3a 00             	cmpb   $0x0,(%edx)
  800a2c:	74 06                	je     800a34 <strncmp+0x2c>
  800a2e:	8a 02                	mov    (%edx),%al
  800a30:	3a 03                	cmp    (%ebx),%al
  800a32:	74 f0                	je     800a24 <strncmp+0x1c>
	if (n == 0)
  800a34:	85 c9                	test   %ecx,%ecx
  800a36:	75 07                	jne    800a3f <strncmp+0x37>
		return 0;
  800a38:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3d:	eb 0a                	jmp    800a49 <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a3f:	0f b6 12             	movzbl (%edx),%edx
  800a42:	0f b6 03             	movzbl (%ebx),%eax
  800a45:	29 c2                	sub    %eax,%edx
  800a47:	89 d0                	mov    %edx,%eax
}
  800a49:	5b                   	pop    %ebx
  800a4a:	c9                   	leave  
  800a4b:	c3                   	ret    

00800a4c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a52:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800a55:	80 38 00             	cmpb   $0x0,(%eax)
  800a58:	74 0a                	je     800a64 <strchr+0x18>
		if (*s == c)
  800a5a:	38 10                	cmp    %dl,(%eax)
  800a5c:	74 0b                	je     800a69 <strchr+0x1d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a5e:	40                   	inc    %eax
  800a5f:	80 38 00             	cmpb   $0x0,(%eax)
  800a62:	75 f6                	jne    800a5a <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800a64:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a69:	c9                   	leave  
  800a6a:	c3                   	ret    

00800a6b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a71:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800a74:	80 38 00             	cmpb   $0x0,(%eax)
  800a77:	74 0a                	je     800a83 <strfind+0x18>
		if (*s == c)
  800a79:	38 10                	cmp    %dl,(%eax)
  800a7b:	74 06                	je     800a83 <strfind+0x18>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a7d:	40                   	inc    %eax
  800a7e:	80 38 00             	cmpb   $0x0,(%eax)
  800a81:	75 f6                	jne    800a79 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
}
  800a83:	c9                   	leave  
  800a84:	c3                   	ret    

00800a85 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	57                   	push   %edi
  800a89:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a8c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
		return v;
  800a8f:	89 f8                	mov    %edi,%eax
void *
memset(void *v, int c, size_t n)
{
	char *p;

	if (n == 0)
  800a91:	85 c9                	test   %ecx,%ecx
  800a93:	74 40                	je     800ad5 <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a95:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a9b:	75 30                	jne    800acd <memset+0x48>
  800a9d:	f6 c1 03             	test   $0x3,%cl
  800aa0:	75 2b                	jne    800acd <memset+0x48>
		c &= 0xFF;
  800aa2:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aa9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aac:	c1 e0 18             	shl    $0x18,%eax
  800aaf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab2:	c1 e2 10             	shl    $0x10,%edx
  800ab5:	09 d0                	or     %edx,%eax
  800ab7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aba:	c1 e2 08             	shl    $0x8,%edx
  800abd:	09 d0                	or     %edx,%eax
  800abf:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  800ac2:	c1 e9 02             	shr    $0x2,%ecx
  800ac5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac8:	fc                   	cld    
  800ac9:	f3 ab                	rep stos %eax,%es:(%edi)
  800acb:	eb 06                	jmp    800ad3 <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800acd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad0:	fc                   	cld    
  800ad1:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800ad3:	89 f8                	mov    %edi,%eax
}
  800ad5:	5f                   	pop    %edi
  800ad6:	c9                   	leave  
  800ad7:	c3                   	ret    

00800ad8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	57                   	push   %edi
  800adc:	56                   	push   %esi
  800add:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800ae3:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800ae6:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800ae8:	39 c6                	cmp    %eax,%esi
  800aea:	73 34                	jae    800b20 <memmove+0x48>
  800aec:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aef:	39 c2                	cmp    %eax,%edx
  800af1:	76 2d                	jbe    800b20 <memmove+0x48>
		s += n;
  800af3:	89 d6                	mov    %edx,%esi
		d += n;
  800af5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af8:	f6 c2 03             	test   $0x3,%dl
  800afb:	75 1b                	jne    800b18 <memmove+0x40>
  800afd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b03:	75 13                	jne    800b18 <memmove+0x40>
  800b05:	f6 c1 03             	test   $0x3,%cl
  800b08:	75 0e                	jne    800b18 <memmove+0x40>
			asm volatile("std; rep movsl\n"
  800b0a:	83 ef 04             	sub    $0x4,%edi
  800b0d:	83 ee 04             	sub    $0x4,%esi
  800b10:	c1 e9 02             	shr    $0x2,%ecx
  800b13:	fd                   	std    
  800b14:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b16:	eb 05                	jmp    800b1d <memmove+0x45>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b18:	4f                   	dec    %edi
  800b19:	4e                   	dec    %esi
  800b1a:	fd                   	std    
  800b1b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b1d:	fc                   	cld    
  800b1e:	eb 20                	jmp    800b40 <memmove+0x68>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b20:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b26:	75 15                	jne    800b3d <memmove+0x65>
  800b28:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b2e:	75 0d                	jne    800b3d <memmove+0x65>
  800b30:	f6 c1 03             	test   $0x3,%cl
  800b33:	75 08                	jne    800b3d <memmove+0x65>
			asm volatile("cld; rep movsl\n"
  800b35:	c1 e9 02             	shr    $0x2,%ecx
  800b38:	fc                   	cld    
  800b39:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b3b:	eb 03                	jmp    800b40 <memmove+0x68>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b3d:	fc                   	cld    
  800b3e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b40:	5e                   	pop    %esi
  800b41:	5f                   	pop    %edi
  800b42:	c9                   	leave  
  800b43:	c3                   	ret    

00800b44 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b47:	ff 75 10             	pushl  0x10(%ebp)
  800b4a:	ff 75 0c             	pushl  0xc(%ebp)
  800b4d:	ff 75 08             	pushl  0x8(%ebp)
  800b50:	e8 83 ff ff ff       	call   800ad8 <memmove>
}
  800b55:	c9                   	leave  
  800b56:	c3                   	ret    

00800b57 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
  800b5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  800b5e:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b61:	8b 55 10             	mov    0x10(%ebp),%edx
  800b64:	4a                   	dec    %edx
  800b65:	83 fa ff             	cmp    $0xffffffff,%edx
  800b68:	74 1a                	je     800b84 <memcmp+0x2d>
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  800b6a:	8a 01                	mov    (%ecx),%al
  800b6c:	3a 03                	cmp    (%ebx),%al
  800b6e:	74 0c                	je     800b7c <memcmp+0x25>
			return (int) *s1 - (int) *s2;
  800b70:	0f b6 d0             	movzbl %al,%edx
  800b73:	0f b6 03             	movzbl (%ebx),%eax
  800b76:	29 c2                	sub    %eax,%edx
  800b78:	89 d0                	mov    %edx,%eax
  800b7a:	eb 0d                	jmp    800b89 <memcmp+0x32>
		s1++, s2++;
  800b7c:	41                   	inc    %ecx
  800b7d:	43                   	inc    %ebx
  800b7e:	4a                   	dec    %edx
  800b7f:	83 fa ff             	cmp    $0xffffffff,%edx
  800b82:	75 e6                	jne    800b6a <memcmp+0x13>
	}

	return 0;
  800b84:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b89:	5b                   	pop    %ebx
  800b8a:	c9                   	leave  
  800b8b:	c3                   	ret    

00800b8c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b8c:	55                   	push   %ebp
  800b8d:	89 e5                	mov    %esp,%ebp
  800b8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b95:	89 c2                	mov    %eax,%edx
  800b97:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b9a:	39 d0                	cmp    %edx,%eax
  800b9c:	73 09                	jae    800ba7 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b9e:	38 08                	cmp    %cl,(%eax)
  800ba0:	74 05                	je     800ba7 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ba2:	40                   	inc    %eax
  800ba3:	39 d0                	cmp    %edx,%eax
  800ba5:	72 f7                	jb     800b9e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ba7:	c9                   	leave  
  800ba8:	c3                   	ret    

00800ba9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	57                   	push   %edi
  800bad:	56                   	push   %esi
  800bae:	53                   	push   %ebx
  800baf:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bb5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  800bb8:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  800bbd:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  800bc2:	80 3a 20             	cmpb   $0x20,(%edx)
  800bc5:	74 05                	je     800bcc <strtol+0x23>
  800bc7:	80 3a 09             	cmpb   $0x9,(%edx)
  800bca:	75 0b                	jne    800bd7 <strtol+0x2e>
  800bcc:	42                   	inc    %edx
  800bcd:	80 3a 20             	cmpb   $0x20,(%edx)
  800bd0:	74 fa                	je     800bcc <strtol+0x23>
  800bd2:	80 3a 09             	cmpb   $0x9,(%edx)
  800bd5:	74 f5                	je     800bcc <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  800bd7:	80 3a 2b             	cmpb   $0x2b,(%edx)
  800bda:	75 03                	jne    800bdf <strtol+0x36>
		s++;
  800bdc:	42                   	inc    %edx
  800bdd:	eb 0b                	jmp    800bea <strtol+0x41>
	else if (*s == '-')
  800bdf:	80 3a 2d             	cmpb   $0x2d,(%edx)
  800be2:	75 06                	jne    800bea <strtol+0x41>
		s++, neg = 1;
  800be4:	42                   	inc    %edx
  800be5:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bea:	85 c9                	test   %ecx,%ecx
  800bec:	74 05                	je     800bf3 <strtol+0x4a>
  800bee:	83 f9 10             	cmp    $0x10,%ecx
  800bf1:	75 15                	jne    800c08 <strtol+0x5f>
  800bf3:	80 3a 30             	cmpb   $0x30,(%edx)
  800bf6:	75 10                	jne    800c08 <strtol+0x5f>
  800bf8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bfc:	75 0a                	jne    800c08 <strtol+0x5f>
		s += 2, base = 16;
  800bfe:	83 c2 02             	add    $0x2,%edx
  800c01:	b9 10 00 00 00       	mov    $0x10,%ecx
  800c06:	eb 14                	jmp    800c1c <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800c08:	85 c9                	test   %ecx,%ecx
  800c0a:	75 10                	jne    800c1c <strtol+0x73>
  800c0c:	80 3a 30             	cmpb   $0x30,(%edx)
  800c0f:	75 05                	jne    800c16 <strtol+0x6d>
		s++, base = 8;
  800c11:	42                   	inc    %edx
  800c12:	b1 08                	mov    $0x8,%cl
  800c14:	eb 06                	jmp    800c1c <strtol+0x73>
	else if (base == 0)
  800c16:	85 c9                	test   %ecx,%ecx
  800c18:	75 02                	jne    800c1c <strtol+0x73>
		base = 10;
  800c1a:	b1 0a                	mov    $0xa,%cl

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c1c:	8a 02                	mov    (%edx),%al
  800c1e:	83 e8 30             	sub    $0x30,%eax
  800c21:	3c 09                	cmp    $0x9,%al
  800c23:	77 08                	ja     800c2d <strtol+0x84>
			dig = *s - '0';
  800c25:	0f be 02             	movsbl (%edx),%eax
  800c28:	83 e8 30             	sub    $0x30,%eax
  800c2b:	eb 20                	jmp    800c4d <strtol+0xa4>
		else if (*s >= 'a' && *s <= 'z')
  800c2d:	8a 02                	mov    (%edx),%al
  800c2f:	83 e8 61             	sub    $0x61,%eax
  800c32:	3c 19                	cmp    $0x19,%al
  800c34:	77 08                	ja     800c3e <strtol+0x95>
			dig = *s - 'a' + 10;
  800c36:	0f be 02             	movsbl (%edx),%eax
  800c39:	83 e8 57             	sub    $0x57,%eax
  800c3c:	eb 0f                	jmp    800c4d <strtol+0xa4>
		else if (*s >= 'A' && *s <= 'Z')
  800c3e:	8a 02                	mov    (%edx),%al
  800c40:	83 e8 41             	sub    $0x41,%eax
  800c43:	3c 19                	cmp    $0x19,%al
  800c45:	77 12                	ja     800c59 <strtol+0xb0>
			dig = *s - 'A' + 10;
  800c47:	0f be 02             	movsbl (%edx),%eax
  800c4a:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  800c4d:	39 c8                	cmp    %ecx,%eax
  800c4f:	7d 08                	jge    800c59 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800c51:	42                   	inc    %edx
  800c52:	0f af d9             	imul   %ecx,%ebx
  800c55:	01 c3                	add    %eax,%ebx
  800c57:	eb c3                	jmp    800c1c <strtol+0x73>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c59:	85 f6                	test   %esi,%esi
  800c5b:	74 02                	je     800c5f <strtol+0xb6>
		*endptr = (char *) s;
  800c5d:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800c5f:	89 d8                	mov    %ebx,%eax
  800c61:	85 ff                	test   %edi,%edi
  800c63:	74 02                	je     800c67 <strtol+0xbe>
  800c65:	f7 d8                	neg    %eax
}
  800c67:	5b                   	pop    %ebx
  800c68:	5e                   	pop    %esi
  800c69:	5f                   	pop    %edi
  800c6a:	c9                   	leave  
  800c6b:	c3                   	ret    

00800c6c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	57                   	push   %edi
  800c70:	56                   	push   %esi
  800c71:	83 ec 14             	sub    $0x14,%esp
  800c74:	8b 55 14             	mov    0x14(%ebp),%edx
  800c77:	8b 75 08             	mov    0x8(%ebp),%esi
  800c7a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c7d:	8b 45 10             	mov    0x10(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800c80:	85 d2                	test   %edx,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800c82:	89 75 f0             	mov    %esi,-0x10(%ebp)
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800c85:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  d1 = dd.s.high;
  800c88:	89 55 f4             	mov    %edx,-0xc(%ebp)
  n0 = nn.s.low;
  n1 = nn.s.high;
  800c8b:	89 fe                	mov    %edi,%esi

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800c8d:	75 11                	jne    800ca0 <__udivdi3+0x34>
    {
      if (d0 > n1)
  800c8f:	39 f8                	cmp    %edi,%eax
  800c91:	76 4d                	jbe    800ce0 <__udivdi3+0x74>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800c93:	89 fa                	mov    %edi,%edx
  800c95:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c98:	f7 75 e4             	divl   -0x1c(%ebp)
  800c9b:	89 c7                	mov    %eax,%edi
  800c9d:	eb 09                	jmp    800ca8 <__udivdi3+0x3c>
  800c9f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ca0:	39 7d f4             	cmp    %edi,-0xc(%ebp)
  800ca3:	76 17                	jbe    800cbc <__udivdi3+0x50>
	{
	  /* 00 = nn / DD */

	  q0 = 0;
  800ca5:	31 ff                	xor    %edi,%edi
  800ca7:	90                   	nop
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
		}

	      q1 = 0;
  800ca8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800caf:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800cb2:	83 c4 14             	add    $0x14,%esp
  800cb5:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cb6:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800cb8:	5f                   	pop    %edi
  800cb9:	c9                   	leave  
  800cba:	c3                   	ret    
  800cbb:	90                   	nop
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800cbc:	0f bd 45 f4          	bsr    -0xc(%ebp),%eax
	  if (bm == 0)
  800cc0:	89 c7                	mov    %eax,%edi
  800cc2:	83 f7 1f             	xor    $0x1f,%edi
  800cc5:	75 4d                	jne    800d14 <__udivdi3+0xa8>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800cc7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800cca:	77 0a                	ja     800cd6 <__udivdi3+0x6a>
  800ccc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
		}
	      else
		q0 = 0;
  800ccf:	31 ff                	xor    %edi,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800cd1:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  800cd4:	72 d2                	jb     800ca8 <__udivdi3+0x3c>
		{
		  q0 = 1;
  800cd6:	bf 01 00 00 00       	mov    $0x1,%edi
  800cdb:	eb cb                	jmp    800ca8 <__udivdi3+0x3c>
  800cdd:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800ce0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	75 0e                	jne    800cf5 <__udivdi3+0x89>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800ce7:	b8 01 00 00 00       	mov    $0x1,%eax
  800cec:	31 c9                	xor    %ecx,%ecx
  800cee:	31 d2                	xor    %edx,%edx
  800cf0:	f7 f1                	div    %ecx
  800cf2:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800cf5:	89 f0                	mov    %esi,%eax
  800cf7:	31 d2                	xor    %edx,%edx
  800cf9:	f7 75 e4             	divl   -0x1c(%ebp)
  800cfc:	89 45 ec             	mov    %eax,-0x14(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800cff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d02:	f7 75 e4             	divl   -0x1c(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d05:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d08:	83 c4 14             	add    $0x14,%esp

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d0b:	89 c7                	mov    %eax,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d0d:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d0e:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d10:	5f                   	pop    %edi
  800d11:	c9                   	leave  
  800d12:	c3                   	ret    
  800d13:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d14:	b8 20 00 00 00       	mov    $0x20,%eax
  800d19:	29 f8                	sub    %edi,%eax
  800d1b:	89 45 e8             	mov    %eax,-0x18(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  800d1e:	89 f9                	mov    %edi,%ecx
  800d20:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d23:	d3 e2                	shl    %cl,%edx
  800d25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d28:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800d2b:	d3 e8                	shr    %cl,%eax
  800d2d:	09 c2                	or     %eax,%edx
	      d0 = d0 << bm;
  800d2f:	89 f9                	mov    %edi,%ecx
  800d31:	d3 65 e4             	shll   %cl,-0x1c(%ebp)
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d34:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800d37:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800d3a:	89 f2                	mov    %esi,%edx
  800d3c:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  800d3e:	89 f9                	mov    %edi,%ecx
  800d40:	d3 e6                	shl    %cl,%esi
  800d42:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d45:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800d48:	d3 e8                	shr    %cl,%eax
  800d4a:	09 c6                	or     %eax,%esi
	      n0 = n0 << bm;
  800d4c:	89 f9                	mov    %edi,%ecx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d4e:	89 f0                	mov    %esi,%eax
  800d50:	f7 75 f4             	divl   -0xc(%ebp)
  800d53:	89 d6                	mov    %edx,%esi
  800d55:	89 c7                	mov    %eax,%edi

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800d57:	d3 65 f0             	shll   %cl,-0x10(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800d5a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d5d:	f7 e7                	mul    %edi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d5f:	39 f2                	cmp    %esi,%edx
  800d61:	77 0f                	ja     800d72 <__udivdi3+0x106>
  800d63:	0f 85 3f ff ff ff    	jne    800ca8 <__udivdi3+0x3c>
  800d69:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800d6c:	0f 86 36 ff ff ff    	jbe    800ca8 <__udivdi3+0x3c>
		{
		  q0--;
  800d72:	4f                   	dec    %edi
  800d73:	e9 30 ff ff ff       	jmp    800ca8 <__udivdi3+0x3c>

00800d78 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	57                   	push   %edi
  800d7c:	56                   	push   %esi
  800d7d:	83 ec 30             	sub    $0x30,%esp
  800d80:	8b 55 14             	mov    0x14(%ebp),%edx
  800d83:	8b 45 10             	mov    0x10(%ebp),%eax
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  800d86:	89 d7                	mov    %edx,%edi
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  800d88:	8d 4d f0             	lea    -0x10(%ebp),%ecx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800d8b:	89 c6                	mov    %eax,%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;
  800d8d:	8b 55 0c             	mov    0xc(%ebp),%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800d90:	8b 45 08             	mov    0x8(%ebp),%eax
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d93:	85 ff                	test   %edi,%edi
  800d95:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800d9c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  800da3:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800da6:	89 45 dc             	mov    %eax,-0x24(%ebp)
  n1 = nn.s.high;
  800da9:	89 55 cc             	mov    %edx,-0x34(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800dac:	75 3e                	jne    800dec <__umoddi3+0x74>
    {
      if (d0 > n1)
  800dae:	39 d6                	cmp    %edx,%esi
  800db0:	0f 86 a2 00 00 00    	jbe    800e58 <__umoddi3+0xe0>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800db6:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  800db8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800dbb:	85 c9                	test   %ecx,%ecx

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800dbd:	89 55 dc             	mov    %edx,-0x24(%ebp)

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  800dc0:	74 1b                	je     800ddd <__umoddi3+0x65>
	{
	  rr.s.low = n0;
  800dc2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800dc5:	89 45 e0             	mov    %eax,-0x20(%ebp)
	  rr.s.high = 0;
  800dc8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800dcf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800dd2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800dd5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800dd8:	89 10                	mov    %edx,(%eax)
  800dda:	89 48 04             	mov    %ecx,0x4(%eax)
  800ddd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800de0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800de3:	83 c4 30             	add    $0x30,%esp
  800de6:	5e                   	pop    %esi
  800de7:	5f                   	pop    %edi
  800de8:	c9                   	leave  
  800de9:	c3                   	ret    
  800dea:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800dec:	3b 7d cc             	cmp    -0x34(%ebp),%edi
  800def:	76 1f                	jbe    800e10 <__umoddi3+0x98>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800df1:	8b 55 08             	mov    0x8(%ebp),%edx
	      rr.s.high = n1;
  800df4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800df7:	89 55 e0             	mov    %edx,-0x20(%ebp)
	      rr.s.high = n1;
  800dfa:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	      *rp = rr.ll;
  800dfd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e00:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800e03:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800e06:	89 55 f4             	mov    %edx,-0xc(%ebp)
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e09:	83 c4 30             	add    $0x30,%esp
  800e0c:	5e                   	pop    %esi
  800e0d:	5f                   	pop    %edi
  800e0e:	c9                   	leave  
  800e0f:	c3                   	ret    
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e10:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800e13:	83 f0 1f             	xor    $0x1f,%eax
  800e16:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800e19:	75 61                	jne    800e7c <__umoddi3+0x104>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e1b:	39 7d cc             	cmp    %edi,-0x34(%ebp)
  800e1e:	77 05                	ja     800e25 <__umoddi3+0xad>
  800e20:	39 75 dc             	cmp    %esi,-0x24(%ebp)
  800e23:	72 10                	jb     800e35 <__umoddi3+0xbd>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e25:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800e28:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800e2b:	29 f0                	sub    %esi,%eax
  800e2d:	19 fa                	sbb    %edi,%edx
  800e2f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800e32:	89 55 cc             	mov    %edx,-0x34(%ebp)
	      else
		q0 = 0;

	      q1 = 0;

	      if (rp != 0)
  800e35:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800e38:	85 d2                	test   %edx,%edx
  800e3a:	74 a1                	je     800ddd <__umoddi3+0x65>
		{
		  rr.s.low = n0;
  800e3c:	8b 45 dc             	mov    -0x24(%ebp),%eax
		  rr.s.high = n1;
  800e3f:	8b 55 cc             	mov    -0x34(%ebp),%edx

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  800e42:	89 45 e0             	mov    %eax,-0x20(%ebp)
		  rr.s.high = n1;
  800e45:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		  *rp = rr.ll;
  800e48:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800e4b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e4e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800e51:	89 01                	mov    %eax,(%ecx)
  800e53:	89 51 04             	mov    %edx,0x4(%ecx)
  800e56:	eb 85                	jmp    800ddd <__umoddi3+0x65>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e58:	85 f6                	test   %esi,%esi
  800e5a:	75 0b                	jne    800e67 <__umoddi3+0xef>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e5c:	b8 01 00 00 00       	mov    $0x1,%eax
  800e61:	31 d2                	xor    %edx,%edx
  800e63:	f7 f6                	div    %esi
  800e65:	89 c6                	mov    %eax,%esi

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e67:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800e6a:	89 fa                	mov    %edi,%edx
  800e6c:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e6e:	8b 45 dc             	mov    -0x24(%ebp),%eax
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e71:	89 55 cc             	mov    %edx,-0x34(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e74:	f7 f6                	div    %esi
  800e76:	e9 3d ff ff ff       	jmp    800db8 <__umoddi3+0x40>
  800e7b:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e7c:	b8 20 00 00 00       	mov    $0x20,%eax
  800e81:	2b 45 d4             	sub    -0x2c(%ebp),%eax
  800e84:	89 45 d8             	mov    %eax,-0x28(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  800e87:	89 fa                	mov    %edi,%edx
  800e89:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800e8c:	d3 e2                	shl    %cl,%edx
  800e8e:	89 f0                	mov    %esi,%eax
  800e90:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800e93:	d3 e8                	shr    %cl,%eax
	      d0 = d0 << bm;
  800e95:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800e98:	d3 e6                	shl    %cl,%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e9a:	89 d7                	mov    %edx,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800e9c:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800e9f:	8b 55 cc             	mov    -0x34(%ebp),%edx
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800ea2:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800ea4:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  800ea6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800ea9:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800eac:	d3 e0                	shl    %cl,%eax
  800eae:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800eb1:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800eb4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800eb7:	d3 e8                	shr    %cl,%eax
  800eb9:	0b 45 cc             	or     -0x34(%ebp),%eax
  800ebc:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n0 = n0 << bm;
  800ebf:	8a 4d d4             	mov    -0x2c(%ebp),%cl

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800ec2:	f7 f7                	div    %edi
  800ec4:	89 55 cc             	mov    %edx,-0x34(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800ec7:	d3 65 dc             	shll   %cl,-0x24(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800eca:	f7 e6                	mul    %esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ecc:	3b 55 cc             	cmp    -0x34(%ebp),%edx
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800ecf:	89 45 c8             	mov    %eax,-0x38(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ed2:	77 0a                	ja     800ede <__umoddi3+0x166>
  800ed4:	75 12                	jne    800ee8 <__umoddi3+0x170>
  800ed6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800ed9:	39 45 c8             	cmp    %eax,-0x38(%ebp)
  800edc:	76 0a                	jbe    800ee8 <__umoddi3+0x170>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800ede:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800ee1:	29 f1                	sub    %esi,%ecx
  800ee3:	19 fa                	sbb    %edi,%edx
  800ee5:	89 4d c8             	mov    %ecx,-0x38(%ebp)
		}

	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
  800ee8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800eeb:	85 c0                	test   %eax,%eax
  800eed:	0f 84 ea fe ff ff    	je     800ddd <__umoddi3+0x65>
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800ef3:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800ef6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800ef9:	2b 45 c8             	sub    -0x38(%ebp),%eax
  800efc:	19 d1                	sbb    %edx,%ecx
  800efe:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f01:	89 ca                	mov    %ecx,%edx
  800f03:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800f06:	d3 e2                	shl    %cl,%edx
  800f08:	8a 4d d4             	mov    -0x2c(%ebp),%cl
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f0b:	89 45 dc             	mov    %eax,-0x24(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f0e:	d3 e8                	shr    %cl,%eax
  800f10:	09 c2                	or     %eax,%edx
		  rr.s.high = n1 >> bm;
  800f12:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800f15:	d3 e8                	shr    %cl,%eax

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f17:	89 55 e0             	mov    %edx,-0x20(%ebp)
		  rr.s.high = n1 >> bm;
  800f1a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f1d:	e9 ad fe ff ff       	jmp    800dcf <__umoddi3+0x57>
