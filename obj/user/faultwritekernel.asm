
obj/user/faultwritekernel.debug:     file format elf32-i386


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
  80002c:	e8 13 00 00 00       	call   800044 <libmain>
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
	*(unsigned*)0xf0100000 = 0;
  800037:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003e:	00 00 00 
}
  800041:	c9                   	leave  
  800042:	c3                   	ret    
	...

00800044 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800044:	55                   	push   %ebp
  800045:	89 e5                	mov    %esp,%ebp
  800047:	56                   	push   %esi
  800048:	53                   	push   %ebx
  800049:	8b 75 08             	mov    0x8(%ebp),%esi
  80004c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];	
  80004f:	e8 d0 00 00 00       	call   800124 <sys_getenvid>
  800054:	25 ff 03 00 00       	and    $0x3ff,%eax
  800059:	89 c2                	mov    %eax,%edx
  80005b:	c1 e2 05             	shl    $0x5,%edx
  80005e:	29 c2                	sub    %eax,%edx
  800060:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  800067:	89 15 04 20 80 00    	mov    %edx,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006d:	85 f6                	test   %esi,%esi
  80006f:	7e 07                	jle    800078 <libmain+0x34>
		binaryname = argv[0];
  800071:	8b 03                	mov    (%ebx),%eax
  800073:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800078:	83 ec 08             	sub    $0x8,%esp
  80007b:	53                   	push   %ebx
  80007c:	56                   	push   %esi
  80007d:	e8 b2 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800082:	e8 09 00 00 00       	call   800090 <exit>
}
  800087:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008a:	5b                   	pop    %ebx
  80008b:	5e                   	pop    %esi
  80008c:	c9                   	leave  
  80008d:	c3                   	ret    
	...

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  800096:	6a 00                	push   $0x0
  800098:	e8 46 00 00 00       	call   8000e3 <sys_env_destroy>
}
  80009d:	c9                   	leave  
  80009e:	c3                   	ret    
	...

008000a0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	57                   	push   %edi
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
  8000a6:	83 ec 04             	sub    $0x4,%esp
  8000a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000af:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b4:	89 f8                	mov    %edi,%eax
  8000b6:	89 fb                	mov    %edi,%ebx
  8000b8:	89 fe                	mov    %edi,%esi
  8000ba:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bc:	83 c4 04             	add    $0x4,%esp
  8000bf:	5b                   	pop    %ebx
  8000c0:	5e                   	pop    %esi
  8000c1:	5f                   	pop    %edi
  8000c2:	c9                   	leave  
  8000c3:	c3                   	ret    

008000c4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	57                   	push   %edi
  8000c8:	56                   	push   %esi
  8000c9:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000ca:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cf:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d4:	89 fa                	mov    %edi,%edx
  8000d6:	89 f9                	mov    %edi,%ecx
  8000d8:	89 fb                	mov    %edi,%ebx
  8000da:	89 fe                	mov    %edi,%esi
  8000dc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5f                   	pop    %edi
  8000e1:	c9                   	leave  
  8000e2:	c3                   	ret    

008000e3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
  8000e9:	83 ec 0c             	sub    $0xc,%esp
  8000ec:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000ef:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f4:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f9:	89 f9                	mov    %edi,%ecx
  8000fb:	89 fb                	mov    %edi,%ebx
  8000fd:	89 fe                	mov    %edi,%esi
  8000ff:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800101:	85 c0                	test   %eax,%eax
  800103:	7e 17                	jle    80011c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800105:	83 ec 0c             	sub    $0xc,%esp
  800108:	50                   	push   %eax
  800109:	6a 03                	push   $0x3
  80010b:	68 2a 0f 80 00       	push   $0x800f2a
  800110:	6a 23                	push   $0x23
  800112:	68 47 0f 80 00       	push   $0x800f47
  800117:	e8 38 02 00 00       	call   800354 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011f:	5b                   	pop    %ebx
  800120:	5e                   	pop    %esi
  800121:	5f                   	pop    %edi
  800122:	c9                   	leave  
  800123:	c3                   	ret    

00800124 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	57                   	push   %edi
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80012a:	b8 02 00 00 00       	mov    $0x2,%eax
  80012f:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800134:	89 fa                	mov    %edi,%edx
  800136:	89 f9                	mov    %edi,%ecx
  800138:	89 fb                	mov    %edi,%ebx
  80013a:	89 fe                	mov    %edi,%esi
  80013c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	5f                   	pop    %edi
  800141:	c9                   	leave  
  800142:	c3                   	ret    

00800143 <sys_yield>:

void
sys_yield(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	57                   	push   %edi
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800149:	b8 0b 00 00 00       	mov    $0xb,%eax
  80014e:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800153:	89 fa                	mov    %edi,%edx
  800155:	89 f9                	mov    %edi,%ecx
  800157:	89 fb                	mov    %edi,%ebx
  800159:	89 fe                	mov    %edi,%esi
  80015b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	c9                   	leave  
  800161:	c3                   	ret    

00800162 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
  800168:	83 ec 0c             	sub    $0xc,%esp
  80016b:	8b 55 08             	mov    0x8(%ebp),%edx
  80016e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800171:	8b 5d 10             	mov    0x10(%ebp),%ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800174:	b8 04 00 00 00       	mov    $0x4,%eax
  800179:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80017e:	89 fe                	mov    %edi,%esi
  800180:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800182:	85 c0                	test   %eax,%eax
  800184:	7e 17                	jle    80019d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800186:	83 ec 0c             	sub    $0xc,%esp
  800189:	50                   	push   %eax
  80018a:	6a 04                	push   $0x4
  80018c:	68 2a 0f 80 00       	push   $0x800f2a
  800191:	6a 23                	push   $0x23
  800193:	68 47 0f 80 00       	push   $0x800f47
  800198:	e8 b7 01 00 00       	call   800354 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80019d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a0:	5b                   	pop    %ebx
  8001a1:	5e                   	pop    %esi
  8001a2:	5f                   	pop    %edi
  8001a3:	c9                   	leave  
  8001a4:	c3                   	ret    

008001a5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a5:	55                   	push   %ebp
  8001a6:	89 e5                	mov    %esp,%ebp
  8001a8:	57                   	push   %edi
  8001a9:	56                   	push   %esi
  8001aa:	53                   	push   %ebx
  8001ab:	83 ec 0c             	sub    $0xc,%esp
  8001ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001ba:	8b 75 18             	mov    0x18(%ebp),%esi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8001bd:	b8 05 00 00 00       	mov    $0x5,%eax
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001c2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001c4:	85 c0                	test   %eax,%eax
  8001c6:	7e 17                	jle    8001df <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c8:	83 ec 0c             	sub    $0xc,%esp
  8001cb:	50                   	push   %eax
  8001cc:	6a 05                	push   $0x5
  8001ce:	68 2a 0f 80 00       	push   $0x800f2a
  8001d3:	6a 23                	push   $0x23
  8001d5:	68 47 0f 80 00       	push   $0x800f47
  8001da:	e8 75 01 00 00       	call   800354 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e2:	5b                   	pop    %ebx
  8001e3:	5e                   	pop    %esi
  8001e4:	5f                   	pop    %edi
  8001e5:	c9                   	leave  
  8001e6:	c3                   	ret    

008001e7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e7:	55                   	push   %ebp
  8001e8:	89 e5                	mov    %esp,%ebp
  8001ea:	57                   	push   %edi
  8001eb:	56                   	push   %esi
  8001ec:	53                   	push   %ebx
  8001ed:	83 ec 0c             	sub    $0xc,%esp
  8001f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8001f6:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fb:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800200:	89 fb                	mov    %edi,%ebx
  800202:	89 fe                	mov    %edi,%esi
  800204:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800206:	85 c0                	test   %eax,%eax
  800208:	7e 17                	jle    800221 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020a:	83 ec 0c             	sub    $0xc,%esp
  80020d:	50                   	push   %eax
  80020e:	6a 06                	push   $0x6
  800210:	68 2a 0f 80 00       	push   $0x800f2a
  800215:	6a 23                	push   $0x23
  800217:	68 47 0f 80 00       	push   $0x800f47
  80021c:	e8 33 01 00 00       	call   800354 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800221:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800224:	5b                   	pop    %ebx
  800225:	5e                   	pop    %esi
  800226:	5f                   	pop    %edi
  800227:	c9                   	leave  
  800228:	c3                   	ret    

00800229 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	57                   	push   %edi
  80022d:	56                   	push   %esi
  80022e:	53                   	push   %ebx
  80022f:	83 ec 0c             	sub    $0xc,%esp
  800232:	8b 55 08             	mov    0x8(%ebp),%edx
  800235:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800238:	b8 08 00 00 00       	mov    $0x8,%eax
  80023d:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800242:	89 fb                	mov    %edi,%ebx
  800244:	89 fe                	mov    %edi,%esi
  800246:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800248:	85 c0                	test   %eax,%eax
  80024a:	7e 17                	jle    800263 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024c:	83 ec 0c             	sub    $0xc,%esp
  80024f:	50                   	push   %eax
  800250:	6a 08                	push   $0x8
  800252:	68 2a 0f 80 00       	push   $0x800f2a
  800257:	6a 23                	push   $0x23
  800259:	68 47 0f 80 00       	push   $0x800f47
  80025e:	e8 f1 00 00 00       	call   800354 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800263:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800266:	5b                   	pop    %ebx
  800267:	5e                   	pop    %esi
  800268:	5f                   	pop    %edi
  800269:	c9                   	leave  
  80026a:	c3                   	ret    

0080026b <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	57                   	push   %edi
  80026f:	56                   	push   %esi
  800270:	53                   	push   %ebx
  800271:	83 ec 0c             	sub    $0xc,%esp
  800274:	8b 55 08             	mov    0x8(%ebp),%edx
  800277:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80027a:	b8 09 00 00 00       	mov    $0x9,%eax
  80027f:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800284:	89 fb                	mov    %edi,%ebx
  800286:	89 fe                	mov    %edi,%esi
  800288:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80028a:	85 c0                	test   %eax,%eax
  80028c:	7e 17                	jle    8002a5 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028e:	83 ec 0c             	sub    $0xc,%esp
  800291:	50                   	push   %eax
  800292:	6a 09                	push   $0x9
  800294:	68 2a 0f 80 00       	push   $0x800f2a
  800299:	6a 23                	push   $0x23
  80029b:	68 47 0f 80 00       	push   $0x800f47
  8002a0:	e8 af 00 00 00       	call   800354 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a8:	5b                   	pop    %ebx
  8002a9:	5e                   	pop    %esi
  8002aa:	5f                   	pop    %edi
  8002ab:	c9                   	leave  
  8002ac:	c3                   	ret    

008002ad <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002ad:	55                   	push   %ebp
  8002ae:	89 e5                	mov    %esp,%ebp
  8002b0:	57                   	push   %edi
  8002b1:	56                   	push   %esi
  8002b2:	53                   	push   %ebx
  8002b3:	83 ec 0c             	sub    $0xc,%esp
  8002b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8002bc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c1:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c6:	89 fb                	mov    %edi,%ebx
  8002c8:	89 fe                	mov    %edi,%esi
  8002ca:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002cc:	85 c0                	test   %eax,%eax
  8002ce:	7e 17                	jle    8002e7 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d0:	83 ec 0c             	sub    $0xc,%esp
  8002d3:	50                   	push   %eax
  8002d4:	6a 0a                	push   $0xa
  8002d6:	68 2a 0f 80 00       	push   $0x800f2a
  8002db:	6a 23                	push   $0x23
  8002dd:	68 47 0f 80 00       	push   $0x800f47
  8002e2:	e8 6d 00 00 00       	call   800354 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ea:	5b                   	pop    %ebx
  8002eb:	5e                   	pop    %esi
  8002ec:	5f                   	pop    %edi
  8002ed:	c9                   	leave  
  8002ee:	c3                   	ret    

008002ef <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002ef:	55                   	push   %ebp
  8002f0:	89 e5                	mov    %esp,%ebp
  8002f2:	57                   	push   %edi
  8002f3:	56                   	push   %esi
  8002f4:	53                   	push   %ebx
  8002f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fe:	8b 7d 14             	mov    0x14(%ebp),%edi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800301:	b8 0c 00 00 00       	mov    $0xc,%eax
  800306:	be 00 00 00 00       	mov    $0x0,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80030d:	5b                   	pop    %ebx
  80030e:	5e                   	pop    %esi
  80030f:	5f                   	pop    %edi
  800310:	c9                   	leave  
  800311:	c3                   	ret    

00800312 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	57                   	push   %edi
  800316:	56                   	push   %esi
  800317:	53                   	push   %ebx
  800318:	83 ec 0c             	sub    $0xc,%esp
  80031b:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80031e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800323:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800328:	89 f9                	mov    %edi,%ecx
  80032a:	89 fb                	mov    %edi,%ebx
  80032c:	89 fe                	mov    %edi,%esi
  80032e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800330:	85 c0                	test   %eax,%eax
  800332:	7e 17                	jle    80034b <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800334:	83 ec 0c             	sub    $0xc,%esp
  800337:	50                   	push   %eax
  800338:	6a 0d                	push   $0xd
  80033a:	68 2a 0f 80 00       	push   $0x800f2a
  80033f:	6a 23                	push   $0x23
  800341:	68 47 0f 80 00       	push   $0x800f47
  800346:	e8 09 00 00 00       	call   800354 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80034b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034e:	5b                   	pop    %ebx
  80034f:	5e                   	pop    %esi
  800350:	5f                   	pop    %edi
  800351:	c9                   	leave  
  800352:	c3                   	ret    
	...

00800354 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	53                   	push   %ebx
  800358:	83 ec 10             	sub    $0x10,%esp
	va_list ap;

	va_start(ap, fmt);
  80035b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80035e:	ff 75 0c             	pushl  0xc(%ebp)
  800361:	ff 75 08             	pushl  0x8(%ebp)
  800364:	ff 35 00 20 80 00    	pushl  0x802000
  80036a:	83 ec 08             	sub    $0x8,%esp
  80036d:	e8 b2 fd ff ff       	call   800124 <sys_getenvid>
  800372:	83 c4 08             	add    $0x8,%esp
  800375:	50                   	push   %eax
  800376:	68 58 0f 80 00       	push   $0x800f58
  80037b:	e8 b0 00 00 00       	call   800430 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800380:	83 c4 18             	add    $0x18,%esp
  800383:	53                   	push   %ebx
  800384:	ff 75 10             	pushl  0x10(%ebp)
  800387:	e8 53 00 00 00       	call   8003df <vcprintf>
	cprintf("\n");
  80038c:	c7 04 24 7b 0f 80 00 	movl   $0x800f7b,(%esp)
  800393:	e8 98 00 00 00       	call   800430 <cprintf>

	// Cause a breakpoint exception
	while (1)
  800398:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  80039b:	cc                   	int3   
  80039c:	eb fd                	jmp    80039b <_panic+0x47>
	...

008003a0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	53                   	push   %ebx
  8003a4:	83 ec 04             	sub    $0x4,%esp
  8003a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003aa:	8b 03                	mov    (%ebx),%eax
  8003ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8003af:	88 54 18 08          	mov    %dl,0x8(%eax,%ebx,1)
  8003b3:	40                   	inc    %eax
  8003b4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8003b6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003bb:	75 1a                	jne    8003d7 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8003bd:	83 ec 08             	sub    $0x8,%esp
  8003c0:	68 ff 00 00 00       	push   $0xff
  8003c5:	8d 43 08             	lea    0x8(%ebx),%eax
  8003c8:	50                   	push   %eax
  8003c9:	e8 d2 fc ff ff       	call   8000a0 <sys_cputs>
		b->idx = 0;
  8003ce:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003d4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003d7:	ff 43 04             	incl   0x4(%ebx)
}
  8003da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003dd:	c9                   	leave  
  8003de:	c3                   	ret    

008003df <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003df:	55                   	push   %ebp
  8003e0:	89 e5                	mov    %esp,%ebp
  8003e2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003e8:	c7 85 e8 fe ff ff 00 	movl   $0x0,-0x118(%ebp)
  8003ef:	00 00 00 
	b.cnt = 0;
  8003f2:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8003f9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003fc:	ff 75 0c             	pushl  0xc(%ebp)
  8003ff:	ff 75 08             	pushl  0x8(%ebp)
  800402:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800408:	50                   	push   %eax
  800409:	68 a0 03 80 00       	push   $0x8003a0
  80040e:	e8 49 01 00 00       	call   80055c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800413:	83 c4 08             	add    $0x8,%esp
  800416:	ff b5 e8 fe ff ff    	pushl  -0x118(%ebp)
  80041c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800422:	50                   	push   %eax
  800423:	e8 78 fc ff ff       	call   8000a0 <sys_cputs>

	return b.cnt;
  800428:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
}
  80042e:	c9                   	leave  
  80042f:	c3                   	ret    

00800430 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800430:	55                   	push   %ebp
  800431:	89 e5                	mov    %esp,%ebp
  800433:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800436:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800439:	50                   	push   %eax
  80043a:	ff 75 08             	pushl  0x8(%ebp)
  80043d:	e8 9d ff ff ff       	call   8003df <vcprintf>
	va_end(ap);

	return cnt;
}
  800442:	c9                   	leave  
  800443:	c3                   	ret    

00800444 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800444:	55                   	push   %ebp
  800445:	89 e5                	mov    %esp,%ebp
  800447:	57                   	push   %edi
  800448:	56                   	push   %esi
  800449:	53                   	push   %ebx
  80044a:	83 ec 0c             	sub    $0xc,%esp
  80044d:	8b 75 10             	mov    0x10(%ebp),%esi
  800450:	8b 7d 14             	mov    0x14(%ebp),%edi
  800453:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800456:	8b 45 18             	mov    0x18(%ebp),%eax
  800459:	ba 00 00 00 00       	mov    $0x0,%edx
  80045e:	39 fa                	cmp    %edi,%edx
  800460:	77 39                	ja     80049b <printnum+0x57>
  800462:	72 04                	jb     800468 <printnum+0x24>
  800464:	39 f0                	cmp    %esi,%eax
  800466:	77 33                	ja     80049b <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800468:	83 ec 04             	sub    $0x4,%esp
  80046b:	ff 75 20             	pushl  0x20(%ebp)
  80046e:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800471:	50                   	push   %eax
  800472:	ff 75 18             	pushl  0x18(%ebp)
  800475:	8b 45 18             	mov    0x18(%ebp),%eax
  800478:	ba 00 00 00 00       	mov    $0x0,%edx
  80047d:	52                   	push   %edx
  80047e:	50                   	push   %eax
  80047f:	57                   	push   %edi
  800480:	56                   	push   %esi
  800481:	e8 de 07 00 00       	call   800c64 <__udivdi3>
  800486:	83 c4 10             	add    $0x10,%esp
  800489:	52                   	push   %edx
  80048a:	50                   	push   %eax
  80048b:	ff 75 0c             	pushl  0xc(%ebp)
  80048e:	ff 75 08             	pushl  0x8(%ebp)
  800491:	e8 ae ff ff ff       	call   800444 <printnum>
  800496:	83 c4 20             	add    $0x20,%esp
  800499:	eb 19                	jmp    8004b4 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80049b:	4b                   	dec    %ebx
  80049c:	85 db                	test   %ebx,%ebx
  80049e:	7e 14                	jle    8004b4 <printnum+0x70>
  8004a0:	83 ec 08             	sub    $0x8,%esp
  8004a3:	ff 75 0c             	pushl  0xc(%ebp)
  8004a6:	ff 75 20             	pushl  0x20(%ebp)
  8004a9:	ff 55 08             	call   *0x8(%ebp)
  8004ac:	83 c4 10             	add    $0x10,%esp
  8004af:	4b                   	dec    %ebx
  8004b0:	85 db                	test   %ebx,%ebx
  8004b2:	7f ec                	jg     8004a0 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004b4:	83 ec 08             	sub    $0x8,%esp
  8004b7:	ff 75 0c             	pushl  0xc(%ebp)
  8004ba:	8b 45 18             	mov    0x18(%ebp),%eax
  8004bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c2:	83 ec 04             	sub    $0x4,%esp
  8004c5:	52                   	push   %edx
  8004c6:	50                   	push   %eax
  8004c7:	57                   	push   %edi
  8004c8:	56                   	push   %esi
  8004c9:	e8 a2 08 00 00       	call   800d70 <__umoddi3>
  8004ce:	83 c4 14             	add    $0x14,%esp
  8004d1:	0f be 80 8f 10 80 00 	movsbl 0x80108f(%eax),%eax
  8004d8:	50                   	push   %eax
  8004d9:	ff 55 08             	call   *0x8(%ebp)
}
  8004dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004df:	5b                   	pop    %ebx
  8004e0:	5e                   	pop    %esi
  8004e1:	5f                   	pop    %edi
  8004e2:	c9                   	leave  
  8004e3:	c3                   	ret    

008004e4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004e4:	55                   	push   %ebp
  8004e5:	89 e5                	mov    %esp,%ebp
  8004e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004ea:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  8004ed:	83 f8 01             	cmp    $0x1,%eax
  8004f0:	7e 0e                	jle    800500 <getuint+0x1c>
		return va_arg(*ap, unsigned long long);
  8004f2:	8b 11                	mov    (%ecx),%edx
  8004f4:	8d 42 08             	lea    0x8(%edx),%eax
  8004f7:	89 01                	mov    %eax,(%ecx)
  8004f9:	8b 02                	mov    (%edx),%eax
  8004fb:	8b 52 04             	mov    0x4(%edx),%edx
  8004fe:	eb 22                	jmp    800522 <getuint+0x3e>
	else if (lflag)
  800500:	85 c0                	test   %eax,%eax
  800502:	74 10                	je     800514 <getuint+0x30>
		return va_arg(*ap, unsigned long);
  800504:	8b 11                	mov    (%ecx),%edx
  800506:	8d 42 04             	lea    0x4(%edx),%eax
  800509:	89 01                	mov    %eax,(%ecx)
  80050b:	8b 02                	mov    (%edx),%eax
  80050d:	ba 00 00 00 00       	mov    $0x0,%edx
  800512:	eb 0e                	jmp    800522 <getuint+0x3e>
	else
		return va_arg(*ap, unsigned int);
  800514:	8b 11                	mov    (%ecx),%edx
  800516:	8d 42 04             	lea    0x4(%edx),%eax
  800519:	89 01                	mov    %eax,(%ecx)
  80051b:	8b 02                	mov    (%edx),%eax
  80051d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800522:	c9                   	leave  
  800523:	c3                   	ret    

00800524 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800524:	55                   	push   %ebp
  800525:	89 e5                	mov    %esp,%ebp
  800527:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80052a:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  80052d:	83 f8 01             	cmp    $0x1,%eax
  800530:	7e 0e                	jle    800540 <getint+0x1c>
		return va_arg(*ap, long long);
  800532:	8b 11                	mov    (%ecx),%edx
  800534:	8d 42 08             	lea    0x8(%edx),%eax
  800537:	89 01                	mov    %eax,(%ecx)
  800539:	8b 02                	mov    (%edx),%eax
  80053b:	8b 52 04             	mov    0x4(%edx),%edx
  80053e:	eb 1a                	jmp    80055a <getint+0x36>
	else if (lflag)
  800540:	85 c0                	test   %eax,%eax
  800542:	74 0c                	je     800550 <getint+0x2c>
		return va_arg(*ap, long);
  800544:	8b 01                	mov    (%ecx),%eax
  800546:	8d 50 04             	lea    0x4(%eax),%edx
  800549:	89 11                	mov    %edx,(%ecx)
  80054b:	8b 00                	mov    (%eax),%eax
  80054d:	99                   	cltd   
  80054e:	eb 0a                	jmp    80055a <getint+0x36>
	else
		return va_arg(*ap, int);
  800550:	8b 01                	mov    (%ecx),%eax
  800552:	8d 50 04             	lea    0x4(%eax),%edx
  800555:	89 11                	mov    %edx,(%ecx)
  800557:	8b 00                	mov    (%eax),%eax
  800559:	99                   	cltd   
}
  80055a:	c9                   	leave  
  80055b:	c3                   	ret    

0080055c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80055c:	55                   	push   %ebp
  80055d:	89 e5                	mov    %esp,%ebp
  80055f:	57                   	push   %edi
  800560:	56                   	push   %esi
  800561:	53                   	push   %ebx
  800562:	83 ec 1c             	sub    $0x1c,%esp
  800565:	8b 5d 10             	mov    0x10(%ebp),%ebx

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
			putch(ch, putdat);
  800568:	0f b6 0b             	movzbl (%ebx),%ecx
  80056b:	43                   	inc    %ebx
  80056c:	83 f9 25             	cmp    $0x25,%ecx
  80056f:	74 1e                	je     80058f <vprintfmt+0x33>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800571:	85 c9                	test   %ecx,%ecx
  800573:	0f 84 dc 02 00 00    	je     800855 <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  800579:	83 ec 08             	sub    $0x8,%esp
  80057c:	ff 75 0c             	pushl  0xc(%ebp)
  80057f:	51                   	push   %ecx
  800580:	ff 55 08             	call   *0x8(%ebp)
  800583:	83 c4 10             	add    $0x10,%esp
  800586:	0f b6 0b             	movzbl (%ebx),%ecx
  800589:	43                   	inc    %ebx
  80058a:	83 f9 25             	cmp    $0x25,%ecx
  80058d:	75 e2                	jne    800571 <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  80058f:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
		width = -1;
  800593:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
		precision = -1;
  80059a:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  80059f:	bf 00 00 00 00       	mov    $0x0,%edi
		altflag = 0;
  8005a4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ab:	0f b6 0b             	movzbl (%ebx),%ecx
  8005ae:	8d 41 dd             	lea    -0x23(%ecx),%eax
  8005b1:	43                   	inc    %ebx
  8005b2:	83 f8 55             	cmp    $0x55,%eax
  8005b5:	0f 87 75 02 00 00    	ja     800830 <vprintfmt+0x2d4>
  8005bb:	ff 24 85 20 11 80 00 	jmp    *0x801120(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  8005c2:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
			goto reswitch;
  8005c6:	eb e3                	jmp    8005ab <vprintfmt+0x4f>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005c8:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
			goto reswitch;
  8005cc:	eb dd                	jmp    8005ab <vprintfmt+0x4f>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005ce:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  8005d3:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  8005d6:	8d 74 41 d0          	lea    -0x30(%ecx,%eax,2),%esi
				ch = *fmt;
  8005da:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  8005dd:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8005e0:	83 f8 09             	cmp    $0x9,%eax
  8005e3:	77 28                	ja     80060d <vprintfmt+0xb1>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005e5:	43                   	inc    %ebx
  8005e6:	eb eb                	jmp    8005d3 <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005e8:	8b 55 14             	mov    0x14(%ebp),%edx
  8005eb:	8d 42 04             	lea    0x4(%edx),%eax
  8005ee:	89 45 14             	mov    %eax,0x14(%ebp)
  8005f1:	8b 32                	mov    (%edx),%esi
			goto process_precision;
  8005f3:	eb 18                	jmp    80060d <vprintfmt+0xb1>

		case '.':
			if (width < 0)
  8005f5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8005f9:	79 b0                	jns    8005ab <vprintfmt+0x4f>
				width = 0;
  8005fb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
			goto reswitch;
  800602:	eb a7                	jmp    8005ab <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  800604:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
			goto reswitch;
  80060b:	eb 9e                	jmp    8005ab <vprintfmt+0x4f>

		process_precision:
			if (width < 0)
  80060d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800611:	79 98                	jns    8005ab <vprintfmt+0x4f>
				width = precision, precision = -1;
  800613:	89 75 f0             	mov    %esi,-0x10(%ebp)
  800616:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  80061b:	eb 8e                	jmp    8005ab <vprintfmt+0x4f>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80061d:	47                   	inc    %edi
			goto reswitch;
  80061e:	eb 8b                	jmp    8005ab <vprintfmt+0x4f>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800620:	83 ec 08             	sub    $0x8,%esp
  800623:	ff 75 0c             	pushl  0xc(%ebp)
  800626:	8b 55 14             	mov    0x14(%ebp),%edx
  800629:	8d 42 04             	lea    0x4(%edx),%eax
  80062c:	89 45 14             	mov    %eax,0x14(%ebp)
  80062f:	ff 32                	pushl  (%edx)
  800631:	ff 55 08             	call   *0x8(%ebp)
			break;
  800634:	83 c4 10             	add    $0x10,%esp
  800637:	e9 2c ff ff ff       	jmp    800568 <vprintfmt+0xc>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80063c:	8b 55 14             	mov    0x14(%ebp),%edx
  80063f:	8d 42 04             	lea    0x4(%edx),%eax
  800642:	89 45 14             	mov    %eax,0x14(%ebp)
  800645:	8b 02                	mov    (%edx),%eax
			if (err < 0)
  800647:	85 c0                	test   %eax,%eax
  800649:	79 02                	jns    80064d <vprintfmt+0xf1>
				err = -err;
  80064b:	f7 d8                	neg    %eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80064d:	83 f8 0f             	cmp    $0xf,%eax
  800650:	7f 0b                	jg     80065d <vprintfmt+0x101>
  800652:	8b 3c 85 e0 10 80 00 	mov    0x8010e0(,%eax,4),%edi
  800659:	85 ff                	test   %edi,%edi
  80065b:	75 19                	jne    800676 <vprintfmt+0x11a>
				printfmt(putch, putdat, "error %d", err);
  80065d:	50                   	push   %eax
  80065e:	68 a0 10 80 00       	push   $0x8010a0
  800663:	ff 75 0c             	pushl  0xc(%ebp)
  800666:	ff 75 08             	pushl  0x8(%ebp)
  800669:	e8 ef 01 00 00       	call   80085d <printfmt>
  80066e:	83 c4 10             	add    $0x10,%esp
  800671:	e9 f2 fe ff ff       	jmp    800568 <vprintfmt+0xc>
			else
				printfmt(putch, putdat, "%s", p);
  800676:	57                   	push   %edi
  800677:	68 a9 10 80 00       	push   $0x8010a9
  80067c:	ff 75 0c             	pushl  0xc(%ebp)
  80067f:	ff 75 08             	pushl  0x8(%ebp)
  800682:	e8 d6 01 00 00       	call   80085d <printfmt>
  800687:	83 c4 10             	add    $0x10,%esp
			break;
  80068a:	e9 d9 fe ff ff       	jmp    800568 <vprintfmt+0xc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80068f:	8b 55 14             	mov    0x14(%ebp),%edx
  800692:	8d 42 04             	lea    0x4(%edx),%eax
  800695:	89 45 14             	mov    %eax,0x14(%ebp)
  800698:	8b 3a                	mov    (%edx),%edi
  80069a:	85 ff                	test   %edi,%edi
  80069c:	75 05                	jne    8006a3 <vprintfmt+0x147>
				p = "(null)";
  80069e:	bf ac 10 80 00       	mov    $0x8010ac,%edi
			if (width > 0 && padc != '-')
  8006a3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8006a7:	7e 3b                	jle    8006e4 <vprintfmt+0x188>
  8006a9:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  8006ad:	74 35                	je     8006e4 <vprintfmt+0x188>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006af:	83 ec 08             	sub    $0x8,%esp
  8006b2:	56                   	push   %esi
  8006b3:	57                   	push   %edi
  8006b4:	e8 58 02 00 00       	call   800911 <strnlen>
  8006b9:	29 45 f0             	sub    %eax,-0x10(%ebp)
  8006bc:	83 c4 10             	add    $0x10,%esp
  8006bf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8006c3:	7e 1f                	jle    8006e4 <vprintfmt+0x188>
  8006c5:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  8006c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
					putch(padc, putdat);
  8006cc:	83 ec 08             	sub    $0x8,%esp
  8006cf:	ff 75 0c             	pushl  0xc(%ebp)
  8006d2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006d5:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d8:	83 c4 10             	add    $0x10,%esp
  8006db:	ff 4d f0             	decl   -0x10(%ebp)
  8006de:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8006e2:	7f e8                	jg     8006cc <vprintfmt+0x170>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006e4:	0f be 0f             	movsbl (%edi),%ecx
  8006e7:	47                   	inc    %edi
  8006e8:	85 c9                	test   %ecx,%ecx
  8006ea:	74 44                	je     800730 <vprintfmt+0x1d4>
  8006ec:	85 f6                	test   %esi,%esi
  8006ee:	78 03                	js     8006f3 <vprintfmt+0x197>
  8006f0:	4e                   	dec    %esi
  8006f1:	78 3d                	js     800730 <vprintfmt+0x1d4>
				if (altflag && (ch < ' ' || ch > '~'))
  8006f3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8006f7:	74 18                	je     800711 <vprintfmt+0x1b5>
  8006f9:	8d 41 e0             	lea    -0x20(%ecx),%eax
  8006fc:	83 f8 5e             	cmp    $0x5e,%eax
  8006ff:	76 10                	jbe    800711 <vprintfmt+0x1b5>
					putch('?', putdat);
  800701:	83 ec 08             	sub    $0x8,%esp
  800704:	ff 75 0c             	pushl  0xc(%ebp)
  800707:	6a 3f                	push   $0x3f
  800709:	ff 55 08             	call   *0x8(%ebp)
  80070c:	83 c4 10             	add    $0x10,%esp
  80070f:	eb 0d                	jmp    80071e <vprintfmt+0x1c2>
				else
					putch(ch, putdat);
  800711:	83 ec 08             	sub    $0x8,%esp
  800714:	ff 75 0c             	pushl  0xc(%ebp)
  800717:	51                   	push   %ecx
  800718:	ff 55 08             	call   *0x8(%ebp)
  80071b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80071e:	ff 4d f0             	decl   -0x10(%ebp)
  800721:	0f be 0f             	movsbl (%edi),%ecx
  800724:	47                   	inc    %edi
  800725:	85 c9                	test   %ecx,%ecx
  800727:	74 07                	je     800730 <vprintfmt+0x1d4>
  800729:	85 f6                	test   %esi,%esi
  80072b:	78 c6                	js     8006f3 <vprintfmt+0x197>
  80072d:	4e                   	dec    %esi
  80072e:	79 c3                	jns    8006f3 <vprintfmt+0x197>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800730:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800734:	0f 8e 2e fe ff ff    	jle    800568 <vprintfmt+0xc>
				putch(' ', putdat);
  80073a:	83 ec 08             	sub    $0x8,%esp
  80073d:	ff 75 0c             	pushl  0xc(%ebp)
  800740:	6a 20                	push   $0x20
  800742:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800745:	83 c4 10             	add    $0x10,%esp
  800748:	ff 4d f0             	decl   -0x10(%ebp)
  80074b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80074f:	7f e9                	jg     80073a <vprintfmt+0x1de>
				putch(' ', putdat);
			break;
  800751:	e9 12 fe ff ff       	jmp    800568 <vprintfmt+0xc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800756:	57                   	push   %edi
  800757:	8d 45 14             	lea    0x14(%ebp),%eax
  80075a:	50                   	push   %eax
  80075b:	e8 c4 fd ff ff       	call   800524 <getint>
  800760:	89 c6                	mov    %eax,%esi
  800762:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800764:	83 c4 08             	add    $0x8,%esp
  800767:	85 d2                	test   %edx,%edx
  800769:	79 15                	jns    800780 <vprintfmt+0x224>
				putch('-', putdat);
  80076b:	83 ec 08             	sub    $0x8,%esp
  80076e:	ff 75 0c             	pushl  0xc(%ebp)
  800771:	6a 2d                	push   $0x2d
  800773:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800776:	f7 de                	neg    %esi
  800778:	83 d7 00             	adc    $0x0,%edi
  80077b:	f7 df                	neg    %edi
  80077d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800780:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  800785:	eb 76                	jmp    8007fd <vprintfmt+0x2a1>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800787:	57                   	push   %edi
  800788:	8d 45 14             	lea    0x14(%ebp),%eax
  80078b:	50                   	push   %eax
  80078c:	e8 53 fd ff ff       	call   8004e4 <getuint>
  800791:	89 c6                	mov    %eax,%esi
  800793:	89 d7                	mov    %edx,%edi
			base = 10;
  800795:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  80079a:	83 c4 08             	add    $0x8,%esp
  80079d:	eb 5e                	jmp    8007fd <vprintfmt+0x2a1>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80079f:	57                   	push   %edi
  8007a0:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a3:	50                   	push   %eax
  8007a4:	e8 3b fd ff ff       	call   8004e4 <getuint>
  8007a9:	89 c6                	mov    %eax,%esi
  8007ab:	89 d7                	mov    %edx,%edi
			base = 8;
  8007ad:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  8007b2:	83 c4 08             	add    $0x8,%esp
  8007b5:	eb 46                	jmp    8007fd <vprintfmt+0x2a1>

		// pointer
		case 'p':
			putch('0', putdat);
  8007b7:	83 ec 08             	sub    $0x8,%esp
  8007ba:	ff 75 0c             	pushl  0xc(%ebp)
  8007bd:	6a 30                	push   $0x30
  8007bf:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007c2:	83 c4 08             	add    $0x8,%esp
  8007c5:	ff 75 0c             	pushl  0xc(%ebp)
  8007c8:	6a 78                	push   $0x78
  8007ca:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8007cd:	8b 55 14             	mov    0x14(%ebp),%edx
  8007d0:	8d 42 04             	lea    0x4(%edx),%eax
  8007d3:	89 45 14             	mov    %eax,0x14(%ebp)
  8007d6:	8b 32                	mov    (%edx),%esi
  8007d8:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007dd:	ba 10 00 00 00       	mov    $0x10,%edx
			goto number;
  8007e2:	83 c4 10             	add    $0x10,%esp
  8007e5:	eb 16                	jmp    8007fd <vprintfmt+0x2a1>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007e7:	57                   	push   %edi
  8007e8:	8d 45 14             	lea    0x14(%ebp),%eax
  8007eb:	50                   	push   %eax
  8007ec:	e8 f3 fc ff ff       	call   8004e4 <getuint>
  8007f1:	89 c6                	mov    %eax,%esi
  8007f3:	89 d7                	mov    %edx,%edi
			base = 16;
  8007f5:	ba 10 00 00 00       	mov    $0x10,%edx
  8007fa:	83 c4 08             	add    $0x8,%esp
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007fd:	83 ec 04             	sub    $0x4,%esp
  800800:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  800804:	50                   	push   %eax
  800805:	ff 75 f0             	pushl  -0x10(%ebp)
  800808:	52                   	push   %edx
  800809:	57                   	push   %edi
  80080a:	56                   	push   %esi
  80080b:	ff 75 0c             	pushl  0xc(%ebp)
  80080e:	ff 75 08             	pushl  0x8(%ebp)
  800811:	e8 2e fc ff ff       	call   800444 <printnum>
			break;
  800816:	83 c4 20             	add    $0x20,%esp
  800819:	e9 4a fd ff ff       	jmp    800568 <vprintfmt+0xc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80081e:	83 ec 08             	sub    $0x8,%esp
  800821:	ff 75 0c             	pushl  0xc(%ebp)
  800824:	51                   	push   %ecx
  800825:	ff 55 08             	call   *0x8(%ebp)
			break;
  800828:	83 c4 10             	add    $0x10,%esp
  80082b:	e9 38 fd ff ff       	jmp    800568 <vprintfmt+0xc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800830:	83 ec 08             	sub    $0x8,%esp
  800833:	ff 75 0c             	pushl  0xc(%ebp)
  800836:	6a 25                	push   $0x25
  800838:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80083b:	4b                   	dec    %ebx
  80083c:	83 c4 10             	add    $0x10,%esp
  80083f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800843:	0f 84 1f fd ff ff    	je     800568 <vprintfmt+0xc>
  800849:	4b                   	dec    %ebx
  80084a:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80084e:	75 f9                	jne    800849 <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  800850:	e9 13 fd ff ff       	jmp    800568 <vprintfmt+0xc>
		}
	}
}
  800855:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800858:	5b                   	pop    %ebx
  800859:	5e                   	pop    %esi
  80085a:	5f                   	pop    %edi
  80085b:	c9                   	leave  
  80085c:	c3                   	ret    

0080085d <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800863:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800866:	50                   	push   %eax
  800867:	ff 75 10             	pushl  0x10(%ebp)
  80086a:	ff 75 0c             	pushl  0xc(%ebp)
  80086d:	ff 75 08             	pushl  0x8(%ebp)
  800870:	e8 e7 fc ff ff       	call   80055c <vprintfmt>
	va_end(ap);
}
  800875:	c9                   	leave  
  800876:	c3                   	ret    

00800877 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  80087d:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  800880:	8b 0a                	mov    (%edx),%ecx
  800882:	3b 4a 04             	cmp    0x4(%edx),%ecx
  800885:	73 07                	jae    80088e <sprintputch+0x17>
		*b->buf++ = ch;
  800887:	8b 45 08             	mov    0x8(%ebp),%eax
  80088a:	88 01                	mov    %al,(%ecx)
  80088c:	ff 02                	incl   (%edx)
}
  80088e:	c9                   	leave  
  80088f:	c3                   	ret    

00800890 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	83 ec 18             	sub    $0x18,%esp
  800896:	8b 55 08             	mov    0x8(%ebp),%edx
  800899:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80089c:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80089f:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
  8008a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008a6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

	if (buf == NULL || n < 1)
  8008ad:	85 d2                	test   %edx,%edx
  8008af:	74 04                	je     8008b5 <vsnprintf+0x25>
  8008b1:	85 c9                	test   %ecx,%ecx
  8008b3:	7f 07                	jg     8008bc <vsnprintf+0x2c>
		return -E_INVAL;
  8008b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008ba:	eb 1d                	jmp    8008d9 <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008bc:	ff 75 14             	pushl  0x14(%ebp)
  8008bf:	ff 75 10             	pushl  0x10(%ebp)
  8008c2:	8d 45 e8             	lea    -0x18(%ebp),%eax
  8008c5:	50                   	push   %eax
  8008c6:	68 77 08 80 00       	push   $0x800877
  8008cb:	e8 8c fc ff ff       	call   80055c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008d0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8008d3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8008d9:	c9                   	leave  
  8008da:	c3                   	ret    

008008db <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008e1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008e4:	50                   	push   %eax
  8008e5:	ff 75 10             	pushl  0x10(%ebp)
  8008e8:	ff 75 0c             	pushl  0xc(%ebp)
  8008eb:	ff 75 08             	pushl  0x8(%ebp)
  8008ee:	e8 9d ff ff ff       	call   800890 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008f3:	c9                   	leave  
  8008f4:	c3                   	ret    
  8008f5:	00 00                	add    %al,(%eax)
	...

008008f8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800903:	80 3a 00             	cmpb   $0x0,(%edx)
  800906:	74 07                	je     80090f <strlen+0x17>
		n++;
  800908:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800909:	42                   	inc    %edx
  80090a:	80 3a 00             	cmpb   $0x0,(%edx)
  80090d:	75 f9                	jne    800908 <strlen+0x10>
		n++;
	return n;
}
  80090f:	c9                   	leave  
  800910:	c3                   	ret    

00800911 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800917:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80091a:	b8 00 00 00 00       	mov    $0x0,%eax
  80091f:	85 d2                	test   %edx,%edx
  800921:	74 0f                	je     800932 <strnlen+0x21>
  800923:	80 39 00             	cmpb   $0x0,(%ecx)
  800926:	74 0a                	je     800932 <strnlen+0x21>
		n++;
  800928:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800929:	41                   	inc    %ecx
  80092a:	4a                   	dec    %edx
  80092b:	74 05                	je     800932 <strnlen+0x21>
  80092d:	80 39 00             	cmpb   $0x0,(%ecx)
  800930:	75 f6                	jne    800928 <strnlen+0x17>
		n++;
	return n;
}
  800932:	c9                   	leave  
  800933:	c3                   	ret    

00800934 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	53                   	push   %ebx
  800938:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80093b:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  80093e:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  800940:	8a 02                	mov    (%edx),%al
  800942:	42                   	inc    %edx
  800943:	88 01                	mov    %al,(%ecx)
  800945:	41                   	inc    %ecx
  800946:	84 c0                	test   %al,%al
  800948:	75 f6                	jne    800940 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80094a:	89 d8                	mov    %ebx,%eax
  80094c:	5b                   	pop    %ebx
  80094d:	c9                   	leave  
  80094e:	c3                   	ret    

0080094f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	53                   	push   %ebx
  800953:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800956:	53                   	push   %ebx
  800957:	e8 9c ff ff ff       	call   8008f8 <strlen>
	strcpy(dst + len, src);
  80095c:	ff 75 0c             	pushl  0xc(%ebp)
  80095f:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800962:	50                   	push   %eax
  800963:	e8 cc ff ff ff       	call   800934 <strcpy>
	return dst;
}
  800968:	89 d8                	mov    %ebx,%eax
  80096a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80096d:	c9                   	leave  
  80096e:	c3                   	ret    

0080096f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	57                   	push   %edi
  800973:	56                   	push   %esi
  800974:	53                   	push   %ebx
  800975:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800978:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097b:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  80097e:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  800980:	bb 00 00 00 00       	mov    $0x0,%ebx
  800985:	39 f3                	cmp    %esi,%ebx
  800987:	73 10                	jae    800999 <strncpy+0x2a>
		*dst++ = *src;
  800989:	8a 02                	mov    (%edx),%al
  80098b:	88 01                	mov    %al,(%ecx)
  80098d:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80098e:	80 3a 01             	cmpb   $0x1,(%edx)
  800991:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800994:	43                   	inc    %ebx
  800995:	39 f3                	cmp    %esi,%ebx
  800997:	72 f0                	jb     800989 <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800999:	89 f8                	mov    %edi,%eax
  80099b:	5b                   	pop    %ebx
  80099c:	5e                   	pop    %esi
  80099d:	5f                   	pop    %edi
  80099e:	c9                   	leave  
  80099f:	c3                   	ret    

008009a0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	56                   	push   %esi
  8009a4:	53                   	push   %ebx
  8009a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ab:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  8009ae:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  8009b0:	85 d2                	test   %edx,%edx
  8009b2:	74 19                	je     8009cd <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009b4:	4a                   	dec    %edx
  8009b5:	74 13                	je     8009ca <strlcpy+0x2a>
  8009b7:	80 39 00             	cmpb   $0x0,(%ecx)
  8009ba:	74 0e                	je     8009ca <strlcpy+0x2a>
  8009bc:	8a 01                	mov    (%ecx),%al
  8009be:	41                   	inc    %ecx
  8009bf:	88 03                	mov    %al,(%ebx)
  8009c1:	43                   	inc    %ebx
  8009c2:	4a                   	dec    %edx
  8009c3:	74 05                	je     8009ca <strlcpy+0x2a>
  8009c5:	80 39 00             	cmpb   $0x0,(%ecx)
  8009c8:	75 f2                	jne    8009bc <strlcpy+0x1c>
		*dst = '\0';
  8009ca:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  8009cd:	89 d8                	mov    %ebx,%eax
  8009cf:	29 f0                	sub    %esi,%eax
}
  8009d1:	5b                   	pop    %ebx
  8009d2:	5e                   	pop    %esi
  8009d3:	c9                   	leave  
  8009d4:	c3                   	ret    

008009d5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8009db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
		p++, q++;
  8009de:	80 3a 00             	cmpb   $0x0,(%edx)
  8009e1:	74 13                	je     8009f6 <strcmp+0x21>
  8009e3:	8a 02                	mov    (%edx),%al
  8009e5:	3a 01                	cmp    (%ecx),%al
  8009e7:	75 0d                	jne    8009f6 <strcmp+0x21>
  8009e9:	42                   	inc    %edx
  8009ea:	41                   	inc    %ecx
  8009eb:	80 3a 00             	cmpb   $0x0,(%edx)
  8009ee:	74 06                	je     8009f6 <strcmp+0x21>
  8009f0:	8a 02                	mov    (%edx),%al
  8009f2:	3a 01                	cmp    (%ecx),%al
  8009f4:	74 f3                	je     8009e9 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009f6:	0f b6 02             	movzbl (%edx),%eax
  8009f9:	0f b6 11             	movzbl (%ecx),%edx
  8009fc:	29 d0                	sub    %edx,%eax
}
  8009fe:	c9                   	leave  
  8009ff:	c3                   	ret    

00800a00 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	53                   	push   %ebx
  800a04:	8b 55 08             	mov    0x8(%ebp),%edx
  800a07:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a0a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800a0d:	85 c9                	test   %ecx,%ecx
  800a0f:	74 1f                	je     800a30 <strncmp+0x30>
  800a11:	80 3a 00             	cmpb   $0x0,(%edx)
  800a14:	74 16                	je     800a2c <strncmp+0x2c>
  800a16:	8a 02                	mov    (%edx),%al
  800a18:	3a 03                	cmp    (%ebx),%al
  800a1a:	75 10                	jne    800a2c <strncmp+0x2c>
  800a1c:	42                   	inc    %edx
  800a1d:	43                   	inc    %ebx
  800a1e:	49                   	dec    %ecx
  800a1f:	74 0f                	je     800a30 <strncmp+0x30>
  800a21:	80 3a 00             	cmpb   $0x0,(%edx)
  800a24:	74 06                	je     800a2c <strncmp+0x2c>
  800a26:	8a 02                	mov    (%edx),%al
  800a28:	3a 03                	cmp    (%ebx),%al
  800a2a:	74 f0                	je     800a1c <strncmp+0x1c>
	if (n == 0)
  800a2c:	85 c9                	test   %ecx,%ecx
  800a2e:	75 07                	jne    800a37 <strncmp+0x37>
		return 0;
  800a30:	b8 00 00 00 00       	mov    $0x0,%eax
  800a35:	eb 0a                	jmp    800a41 <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a37:	0f b6 12             	movzbl (%edx),%edx
  800a3a:	0f b6 03             	movzbl (%ebx),%eax
  800a3d:	29 c2                	sub    %eax,%edx
  800a3f:	89 d0                	mov    %edx,%eax
}
  800a41:	5b                   	pop    %ebx
  800a42:	c9                   	leave  
  800a43:	c3                   	ret    

00800a44 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4a:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800a4d:	80 38 00             	cmpb   $0x0,(%eax)
  800a50:	74 0a                	je     800a5c <strchr+0x18>
		if (*s == c)
  800a52:	38 10                	cmp    %dl,(%eax)
  800a54:	74 0b                	je     800a61 <strchr+0x1d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a56:	40                   	inc    %eax
  800a57:	80 38 00             	cmpb   $0x0,(%eax)
  800a5a:	75 f6                	jne    800a52 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800a5c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a61:	c9                   	leave  
  800a62:	c3                   	ret    

00800a63 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	8b 45 08             	mov    0x8(%ebp),%eax
  800a69:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800a6c:	80 38 00             	cmpb   $0x0,(%eax)
  800a6f:	74 0a                	je     800a7b <strfind+0x18>
		if (*s == c)
  800a71:	38 10                	cmp    %dl,(%eax)
  800a73:	74 06                	je     800a7b <strfind+0x18>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a75:	40                   	inc    %eax
  800a76:	80 38 00             	cmpb   $0x0,(%eax)
  800a79:	75 f6                	jne    800a71 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
}
  800a7b:	c9                   	leave  
  800a7c:	c3                   	ret    

00800a7d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	57                   	push   %edi
  800a81:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a84:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
		return v;
  800a87:	89 f8                	mov    %edi,%eax
void *
memset(void *v, int c, size_t n)
{
	char *p;

	if (n == 0)
  800a89:	85 c9                	test   %ecx,%ecx
  800a8b:	74 40                	je     800acd <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a8d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a93:	75 30                	jne    800ac5 <memset+0x48>
  800a95:	f6 c1 03             	test   $0x3,%cl
  800a98:	75 2b                	jne    800ac5 <memset+0x48>
		c &= 0xFF;
  800a9a:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aa1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa4:	c1 e0 18             	shl    $0x18,%eax
  800aa7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aaa:	c1 e2 10             	shl    $0x10,%edx
  800aad:	09 d0                	or     %edx,%eax
  800aaf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab2:	c1 e2 08             	shl    $0x8,%edx
  800ab5:	09 d0                	or     %edx,%eax
  800ab7:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  800aba:	c1 e9 02             	shr    $0x2,%ecx
  800abd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac0:	fc                   	cld    
  800ac1:	f3 ab                	rep stos %eax,%es:(%edi)
  800ac3:	eb 06                	jmp    800acb <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ac5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac8:	fc                   	cld    
  800ac9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800acb:	89 f8                	mov    %edi,%eax
}
  800acd:	5f                   	pop    %edi
  800ace:	c9                   	leave  
  800acf:	c3                   	ret    

00800ad0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	57                   	push   %edi
  800ad4:	56                   	push   %esi
  800ad5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800adb:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800ade:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800ae0:	39 c6                	cmp    %eax,%esi
  800ae2:	73 34                	jae    800b18 <memmove+0x48>
  800ae4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ae7:	39 c2                	cmp    %eax,%edx
  800ae9:	76 2d                	jbe    800b18 <memmove+0x48>
		s += n;
  800aeb:	89 d6                	mov    %edx,%esi
		d += n;
  800aed:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af0:	f6 c2 03             	test   $0x3,%dl
  800af3:	75 1b                	jne    800b10 <memmove+0x40>
  800af5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800afb:	75 13                	jne    800b10 <memmove+0x40>
  800afd:	f6 c1 03             	test   $0x3,%cl
  800b00:	75 0e                	jne    800b10 <memmove+0x40>
			asm volatile("std; rep movsl\n"
  800b02:	83 ef 04             	sub    $0x4,%edi
  800b05:	83 ee 04             	sub    $0x4,%esi
  800b08:	c1 e9 02             	shr    $0x2,%ecx
  800b0b:	fd                   	std    
  800b0c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b0e:	eb 05                	jmp    800b15 <memmove+0x45>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b10:	4f                   	dec    %edi
  800b11:	4e                   	dec    %esi
  800b12:	fd                   	std    
  800b13:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b15:	fc                   	cld    
  800b16:	eb 20                	jmp    800b38 <memmove+0x68>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b18:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b1e:	75 15                	jne    800b35 <memmove+0x65>
  800b20:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b26:	75 0d                	jne    800b35 <memmove+0x65>
  800b28:	f6 c1 03             	test   $0x3,%cl
  800b2b:	75 08                	jne    800b35 <memmove+0x65>
			asm volatile("cld; rep movsl\n"
  800b2d:	c1 e9 02             	shr    $0x2,%ecx
  800b30:	fc                   	cld    
  800b31:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b33:	eb 03                	jmp    800b38 <memmove+0x68>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b35:	fc                   	cld    
  800b36:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b38:	5e                   	pop    %esi
  800b39:	5f                   	pop    %edi
  800b3a:	c9                   	leave  
  800b3b:	c3                   	ret    

00800b3c <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b3f:	ff 75 10             	pushl  0x10(%ebp)
  800b42:	ff 75 0c             	pushl  0xc(%ebp)
  800b45:	ff 75 08             	pushl  0x8(%ebp)
  800b48:	e8 83 ff ff ff       	call   800ad0 <memmove>
}
  800b4d:	c9                   	leave  
  800b4e:	c3                   	ret    

00800b4f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
  800b53:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  800b56:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b59:	8b 55 10             	mov    0x10(%ebp),%edx
  800b5c:	4a                   	dec    %edx
  800b5d:	83 fa ff             	cmp    $0xffffffff,%edx
  800b60:	74 1a                	je     800b7c <memcmp+0x2d>
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  800b62:	8a 01                	mov    (%ecx),%al
  800b64:	3a 03                	cmp    (%ebx),%al
  800b66:	74 0c                	je     800b74 <memcmp+0x25>
			return (int) *s1 - (int) *s2;
  800b68:	0f b6 d0             	movzbl %al,%edx
  800b6b:	0f b6 03             	movzbl (%ebx),%eax
  800b6e:	29 c2                	sub    %eax,%edx
  800b70:	89 d0                	mov    %edx,%eax
  800b72:	eb 0d                	jmp    800b81 <memcmp+0x32>
		s1++, s2++;
  800b74:	41                   	inc    %ecx
  800b75:	43                   	inc    %ebx
  800b76:	4a                   	dec    %edx
  800b77:	83 fa ff             	cmp    $0xffffffff,%edx
  800b7a:	75 e6                	jne    800b62 <memcmp+0x13>
	}

	return 0;
  800b7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b81:	5b                   	pop    %ebx
  800b82:	c9                   	leave  
  800b83:	c3                   	ret    

00800b84 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b8d:	89 c2                	mov    %eax,%edx
  800b8f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b92:	39 d0                	cmp    %edx,%eax
  800b94:	73 09                	jae    800b9f <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b96:	38 08                	cmp    %cl,(%eax)
  800b98:	74 05                	je     800b9f <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b9a:	40                   	inc    %eax
  800b9b:	39 d0                	cmp    %edx,%eax
  800b9d:	72 f7                	jb     800b96 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b9f:	c9                   	leave  
  800ba0:	c3                   	ret    

00800ba1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	57                   	push   %edi
  800ba5:	56                   	push   %esi
  800ba6:	53                   	push   %ebx
  800ba7:	8b 55 08             	mov    0x8(%ebp),%edx
  800baa:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  800bb0:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  800bb5:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  800bba:	80 3a 20             	cmpb   $0x20,(%edx)
  800bbd:	74 05                	je     800bc4 <strtol+0x23>
  800bbf:	80 3a 09             	cmpb   $0x9,(%edx)
  800bc2:	75 0b                	jne    800bcf <strtol+0x2e>
  800bc4:	42                   	inc    %edx
  800bc5:	80 3a 20             	cmpb   $0x20,(%edx)
  800bc8:	74 fa                	je     800bc4 <strtol+0x23>
  800bca:	80 3a 09             	cmpb   $0x9,(%edx)
  800bcd:	74 f5                	je     800bc4 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  800bcf:	80 3a 2b             	cmpb   $0x2b,(%edx)
  800bd2:	75 03                	jne    800bd7 <strtol+0x36>
		s++;
  800bd4:	42                   	inc    %edx
  800bd5:	eb 0b                	jmp    800be2 <strtol+0x41>
	else if (*s == '-')
  800bd7:	80 3a 2d             	cmpb   $0x2d,(%edx)
  800bda:	75 06                	jne    800be2 <strtol+0x41>
		s++, neg = 1;
  800bdc:	42                   	inc    %edx
  800bdd:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800be2:	85 c9                	test   %ecx,%ecx
  800be4:	74 05                	je     800beb <strtol+0x4a>
  800be6:	83 f9 10             	cmp    $0x10,%ecx
  800be9:	75 15                	jne    800c00 <strtol+0x5f>
  800beb:	80 3a 30             	cmpb   $0x30,(%edx)
  800bee:	75 10                	jne    800c00 <strtol+0x5f>
  800bf0:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bf4:	75 0a                	jne    800c00 <strtol+0x5f>
		s += 2, base = 16;
  800bf6:	83 c2 02             	add    $0x2,%edx
  800bf9:	b9 10 00 00 00       	mov    $0x10,%ecx
  800bfe:	eb 14                	jmp    800c14 <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800c00:	85 c9                	test   %ecx,%ecx
  800c02:	75 10                	jne    800c14 <strtol+0x73>
  800c04:	80 3a 30             	cmpb   $0x30,(%edx)
  800c07:	75 05                	jne    800c0e <strtol+0x6d>
		s++, base = 8;
  800c09:	42                   	inc    %edx
  800c0a:	b1 08                	mov    $0x8,%cl
  800c0c:	eb 06                	jmp    800c14 <strtol+0x73>
	else if (base == 0)
  800c0e:	85 c9                	test   %ecx,%ecx
  800c10:	75 02                	jne    800c14 <strtol+0x73>
		base = 10;
  800c12:	b1 0a                	mov    $0xa,%cl

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c14:	8a 02                	mov    (%edx),%al
  800c16:	83 e8 30             	sub    $0x30,%eax
  800c19:	3c 09                	cmp    $0x9,%al
  800c1b:	77 08                	ja     800c25 <strtol+0x84>
			dig = *s - '0';
  800c1d:	0f be 02             	movsbl (%edx),%eax
  800c20:	83 e8 30             	sub    $0x30,%eax
  800c23:	eb 20                	jmp    800c45 <strtol+0xa4>
		else if (*s >= 'a' && *s <= 'z')
  800c25:	8a 02                	mov    (%edx),%al
  800c27:	83 e8 61             	sub    $0x61,%eax
  800c2a:	3c 19                	cmp    $0x19,%al
  800c2c:	77 08                	ja     800c36 <strtol+0x95>
			dig = *s - 'a' + 10;
  800c2e:	0f be 02             	movsbl (%edx),%eax
  800c31:	83 e8 57             	sub    $0x57,%eax
  800c34:	eb 0f                	jmp    800c45 <strtol+0xa4>
		else if (*s >= 'A' && *s <= 'Z')
  800c36:	8a 02                	mov    (%edx),%al
  800c38:	83 e8 41             	sub    $0x41,%eax
  800c3b:	3c 19                	cmp    $0x19,%al
  800c3d:	77 12                	ja     800c51 <strtol+0xb0>
			dig = *s - 'A' + 10;
  800c3f:	0f be 02             	movsbl (%edx),%eax
  800c42:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  800c45:	39 c8                	cmp    %ecx,%eax
  800c47:	7d 08                	jge    800c51 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800c49:	42                   	inc    %edx
  800c4a:	0f af d9             	imul   %ecx,%ebx
  800c4d:	01 c3                	add    %eax,%ebx
  800c4f:	eb c3                	jmp    800c14 <strtol+0x73>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c51:	85 f6                	test   %esi,%esi
  800c53:	74 02                	je     800c57 <strtol+0xb6>
		*endptr = (char *) s;
  800c55:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800c57:	89 d8                	mov    %ebx,%eax
  800c59:	85 ff                	test   %edi,%edi
  800c5b:	74 02                	je     800c5f <strtol+0xbe>
  800c5d:	f7 d8                	neg    %eax
}
  800c5f:	5b                   	pop    %ebx
  800c60:	5e                   	pop    %esi
  800c61:	5f                   	pop    %edi
  800c62:	c9                   	leave  
  800c63:	c3                   	ret    

00800c64 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	57                   	push   %edi
  800c68:	56                   	push   %esi
  800c69:	83 ec 14             	sub    $0x14,%esp
  800c6c:	8b 55 14             	mov    0x14(%ebp),%edx
  800c6f:	8b 75 08             	mov    0x8(%ebp),%esi
  800c72:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c75:	8b 45 10             	mov    0x10(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800c78:	85 d2                	test   %edx,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800c7a:	89 75 f0             	mov    %esi,-0x10(%ebp)
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800c7d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  d1 = dd.s.high;
  800c80:	89 55 f4             	mov    %edx,-0xc(%ebp)
  n0 = nn.s.low;
  n1 = nn.s.high;
  800c83:	89 fe                	mov    %edi,%esi

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800c85:	75 11                	jne    800c98 <__udivdi3+0x34>
    {
      if (d0 > n1)
  800c87:	39 f8                	cmp    %edi,%eax
  800c89:	76 4d                	jbe    800cd8 <__udivdi3+0x74>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800c8b:	89 fa                	mov    %edi,%edx
  800c8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c90:	f7 75 e4             	divl   -0x1c(%ebp)
  800c93:	89 c7                	mov    %eax,%edi
  800c95:	eb 09                	jmp    800ca0 <__udivdi3+0x3c>
  800c97:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800c98:	39 7d f4             	cmp    %edi,-0xc(%ebp)
  800c9b:	76 17                	jbe    800cb4 <__udivdi3+0x50>
	{
	  /* 00 = nn / DD */

	  q0 = 0;
  800c9d:	31 ff                	xor    %edi,%edi
  800c9f:	90                   	nop
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
		}

	      q1 = 0;
  800ca0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ca7:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800caa:	83 c4 14             	add    $0x14,%esp
  800cad:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cae:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800cb0:	5f                   	pop    %edi
  800cb1:	c9                   	leave  
  800cb2:	c3                   	ret    
  800cb3:	90                   	nop
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800cb4:	0f bd 45 f4          	bsr    -0xc(%ebp),%eax
	  if (bm == 0)
  800cb8:	89 c7                	mov    %eax,%edi
  800cba:	83 f7 1f             	xor    $0x1f,%edi
  800cbd:	75 4d                	jne    800d0c <__udivdi3+0xa8>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800cbf:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800cc2:	77 0a                	ja     800cce <__udivdi3+0x6a>
  800cc4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
		}
	      else
		q0 = 0;
  800cc7:	31 ff                	xor    %edi,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800cc9:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  800ccc:	72 d2                	jb     800ca0 <__udivdi3+0x3c>
		{
		  q0 = 1;
  800cce:	bf 01 00 00 00       	mov    $0x1,%edi
  800cd3:	eb cb                	jmp    800ca0 <__udivdi3+0x3c>
  800cd5:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800cd8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800cdb:	85 c0                	test   %eax,%eax
  800cdd:	75 0e                	jne    800ced <__udivdi3+0x89>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800cdf:	b8 01 00 00 00       	mov    $0x1,%eax
  800ce4:	31 c9                	xor    %ecx,%ecx
  800ce6:	31 d2                	xor    %edx,%edx
  800ce8:	f7 f1                	div    %ecx
  800cea:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800ced:	89 f0                	mov    %esi,%eax
  800cef:	31 d2                	xor    %edx,%edx
  800cf1:	f7 75 e4             	divl   -0x1c(%ebp)
  800cf4:	89 45 ec             	mov    %eax,-0x14(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800cf7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cfa:	f7 75 e4             	divl   -0x1c(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cfd:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d00:	83 c4 14             	add    $0x14,%esp

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d03:	89 c7                	mov    %eax,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d05:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d06:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d08:	5f                   	pop    %edi
  800d09:	c9                   	leave  
  800d0a:	c3                   	ret    
  800d0b:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d0c:	b8 20 00 00 00       	mov    $0x20,%eax
  800d11:	29 f8                	sub    %edi,%eax
  800d13:	89 45 e8             	mov    %eax,-0x18(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  800d16:	89 f9                	mov    %edi,%ecx
  800d18:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d1b:	d3 e2                	shl    %cl,%edx
  800d1d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d20:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800d23:	d3 e8                	shr    %cl,%eax
  800d25:	09 c2                	or     %eax,%edx
	      d0 = d0 << bm;
  800d27:	89 f9                	mov    %edi,%ecx
  800d29:	d3 65 e4             	shll   %cl,-0x1c(%ebp)
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d2c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800d2f:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800d32:	89 f2                	mov    %esi,%edx
  800d34:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  800d36:	89 f9                	mov    %edi,%ecx
  800d38:	d3 e6                	shl    %cl,%esi
  800d3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d3d:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800d40:	d3 e8                	shr    %cl,%eax
  800d42:	09 c6                	or     %eax,%esi
	      n0 = n0 << bm;
  800d44:	89 f9                	mov    %edi,%ecx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d46:	89 f0                	mov    %esi,%eax
  800d48:	f7 75 f4             	divl   -0xc(%ebp)
  800d4b:	89 d6                	mov    %edx,%esi
  800d4d:	89 c7                	mov    %eax,%edi

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800d4f:	d3 65 f0             	shll   %cl,-0x10(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800d52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d55:	f7 e7                	mul    %edi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d57:	39 f2                	cmp    %esi,%edx
  800d59:	77 0f                	ja     800d6a <__udivdi3+0x106>
  800d5b:	0f 85 3f ff ff ff    	jne    800ca0 <__udivdi3+0x3c>
  800d61:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800d64:	0f 86 36 ff ff ff    	jbe    800ca0 <__udivdi3+0x3c>
		{
		  q0--;
  800d6a:	4f                   	dec    %edi
  800d6b:	e9 30 ff ff ff       	jmp    800ca0 <__udivdi3+0x3c>

00800d70 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	57                   	push   %edi
  800d74:	56                   	push   %esi
  800d75:	83 ec 30             	sub    $0x30,%esp
  800d78:	8b 55 14             	mov    0x14(%ebp),%edx
  800d7b:	8b 45 10             	mov    0x10(%ebp),%eax
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  800d7e:	89 d7                	mov    %edx,%edi
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  800d80:	8d 4d f0             	lea    -0x10(%ebp),%ecx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800d83:	89 c6                	mov    %eax,%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;
  800d85:	8b 55 0c             	mov    0xc(%ebp),%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800d88:	8b 45 08             	mov    0x8(%ebp),%eax
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d8b:	85 ff                	test   %edi,%edi
  800d8d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800d94:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  800d9b:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800d9e:	89 45 dc             	mov    %eax,-0x24(%ebp)
  n1 = nn.s.high;
  800da1:	89 55 cc             	mov    %edx,-0x34(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800da4:	75 3e                	jne    800de4 <__umoddi3+0x74>
    {
      if (d0 > n1)
  800da6:	39 d6                	cmp    %edx,%esi
  800da8:	0f 86 a2 00 00 00    	jbe    800e50 <__umoddi3+0xe0>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800dae:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  800db0:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800db3:	85 c9                	test   %ecx,%ecx

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800db5:	89 55 dc             	mov    %edx,-0x24(%ebp)

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  800db8:	74 1b                	je     800dd5 <__umoddi3+0x65>
	{
	  rr.s.low = n0;
  800dba:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800dbd:	89 45 e0             	mov    %eax,-0x20(%ebp)
	  rr.s.high = 0;
  800dc0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800dc7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800dca:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800dcd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800dd0:	89 10                	mov    %edx,(%eax)
  800dd2:	89 48 04             	mov    %ecx,0x4(%eax)
  800dd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dd8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ddb:	83 c4 30             	add    $0x30,%esp
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	c9                   	leave  
  800de1:	c3                   	ret    
  800de2:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800de4:	3b 7d cc             	cmp    -0x34(%ebp),%edi
  800de7:	76 1f                	jbe    800e08 <__umoddi3+0x98>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800de9:	8b 55 08             	mov    0x8(%ebp),%edx
	      rr.s.high = n1;
  800dec:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800def:	89 55 e0             	mov    %edx,-0x20(%ebp)
	      rr.s.high = n1;
  800df2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	      *rp = rr.ll;
  800df5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800df8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800dfb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800dfe:	89 55 f4             	mov    %edx,-0xc(%ebp)
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e01:	83 c4 30             	add    $0x30,%esp
  800e04:	5e                   	pop    %esi
  800e05:	5f                   	pop    %edi
  800e06:	c9                   	leave  
  800e07:	c3                   	ret    
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e08:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800e0b:	83 f0 1f             	xor    $0x1f,%eax
  800e0e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800e11:	75 61                	jne    800e74 <__umoddi3+0x104>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e13:	39 7d cc             	cmp    %edi,-0x34(%ebp)
  800e16:	77 05                	ja     800e1d <__umoddi3+0xad>
  800e18:	39 75 dc             	cmp    %esi,-0x24(%ebp)
  800e1b:	72 10                	jb     800e2d <__umoddi3+0xbd>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e1d:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800e20:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800e23:	29 f0                	sub    %esi,%eax
  800e25:	19 fa                	sbb    %edi,%edx
  800e27:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800e2a:	89 55 cc             	mov    %edx,-0x34(%ebp)
	      else
		q0 = 0;

	      q1 = 0;

	      if (rp != 0)
  800e2d:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800e30:	85 d2                	test   %edx,%edx
  800e32:	74 a1                	je     800dd5 <__umoddi3+0x65>
		{
		  rr.s.low = n0;
  800e34:	8b 45 dc             	mov    -0x24(%ebp),%eax
		  rr.s.high = n1;
  800e37:	8b 55 cc             	mov    -0x34(%ebp),%edx

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  800e3a:	89 45 e0             	mov    %eax,-0x20(%ebp)
		  rr.s.high = n1;
  800e3d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		  *rp = rr.ll;
  800e40:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800e43:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e46:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800e49:	89 01                	mov    %eax,(%ecx)
  800e4b:	89 51 04             	mov    %edx,0x4(%ecx)
  800e4e:	eb 85                	jmp    800dd5 <__umoddi3+0x65>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e50:	85 f6                	test   %esi,%esi
  800e52:	75 0b                	jne    800e5f <__umoddi3+0xef>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e54:	b8 01 00 00 00       	mov    $0x1,%eax
  800e59:	31 d2                	xor    %edx,%edx
  800e5b:	f7 f6                	div    %esi
  800e5d:	89 c6                	mov    %eax,%esi

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e5f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800e62:	89 fa                	mov    %edi,%edx
  800e64:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e66:	8b 45 dc             	mov    -0x24(%ebp),%eax
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e69:	89 55 cc             	mov    %edx,-0x34(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e6c:	f7 f6                	div    %esi
  800e6e:	e9 3d ff ff ff       	jmp    800db0 <__umoddi3+0x40>
  800e73:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e74:	b8 20 00 00 00       	mov    $0x20,%eax
  800e79:	2b 45 d4             	sub    -0x2c(%ebp),%eax
  800e7c:	89 45 d8             	mov    %eax,-0x28(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  800e7f:	89 fa                	mov    %edi,%edx
  800e81:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800e84:	d3 e2                	shl    %cl,%edx
  800e86:	89 f0                	mov    %esi,%eax
  800e88:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800e8b:	d3 e8                	shr    %cl,%eax
	      d0 = d0 << bm;
  800e8d:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800e90:	d3 e6                	shl    %cl,%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e92:	89 d7                	mov    %edx,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800e94:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800e97:	8b 55 cc             	mov    -0x34(%ebp),%edx
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e9a:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800e9c:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  800e9e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800ea1:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800ea4:	d3 e0                	shl    %cl,%eax
  800ea6:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800ea9:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800eac:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800eaf:	d3 e8                	shr    %cl,%eax
  800eb1:	0b 45 cc             	or     -0x34(%ebp),%eax
  800eb4:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n0 = n0 << bm;
  800eb7:	8a 4d d4             	mov    -0x2c(%ebp),%cl

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800eba:	f7 f7                	div    %edi
  800ebc:	89 55 cc             	mov    %edx,-0x34(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800ebf:	d3 65 dc             	shll   %cl,-0x24(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800ec2:	f7 e6                	mul    %esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ec4:	3b 55 cc             	cmp    -0x34(%ebp),%edx
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800ec7:	89 45 c8             	mov    %eax,-0x38(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800eca:	77 0a                	ja     800ed6 <__umoddi3+0x166>
  800ecc:	75 12                	jne    800ee0 <__umoddi3+0x170>
  800ece:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800ed1:	39 45 c8             	cmp    %eax,-0x38(%ebp)
  800ed4:	76 0a                	jbe    800ee0 <__umoddi3+0x170>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800ed6:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800ed9:	29 f1                	sub    %esi,%ecx
  800edb:	19 fa                	sbb    %edi,%edx
  800edd:	89 4d c8             	mov    %ecx,-0x38(%ebp)
		}

	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
  800ee0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ee3:	85 c0                	test   %eax,%eax
  800ee5:	0f 84 ea fe ff ff    	je     800dd5 <__umoddi3+0x65>
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800eeb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800eee:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800ef1:	2b 45 c8             	sub    -0x38(%ebp),%eax
  800ef4:	19 d1                	sbb    %edx,%ecx
  800ef6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800ef9:	89 ca                	mov    %ecx,%edx
  800efb:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800efe:	d3 e2                	shl    %cl,%edx
  800f00:	8a 4d d4             	mov    -0x2c(%ebp),%cl
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f03:	89 45 dc             	mov    %eax,-0x24(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f06:	d3 e8                	shr    %cl,%eax
  800f08:	09 c2                	or     %eax,%edx
		  rr.s.high = n1 >> bm;
  800f0a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800f0d:	d3 e8                	shr    %cl,%eax

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f0f:	89 55 e0             	mov    %edx,-0x20(%ebp)
		  rr.s.high = n1 >> bm;
  800f12:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f15:	e9 ad fe ff ff       	jmp    800dc7 <__umoddi3+0x57>
