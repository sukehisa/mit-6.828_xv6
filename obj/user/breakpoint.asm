
obj/user/breakpoint.debug:     file format elf32-i386


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
  80002c:	e8 0b 00 00 00       	call   80003c <libmain>
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
	asm volatile("int $3");
  800037:	cc                   	int3   
}
  800038:	c9                   	leave  
  800039:	c3                   	ret    
	...

0080003c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003c:	55                   	push   %ebp
  80003d:	89 e5                	mov    %esp,%ebp
  80003f:	56                   	push   %esi
  800040:	53                   	push   %ebx
  800041:	8b 75 08             	mov    0x8(%ebp),%esi
  800044:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];	
  800047:	e8 d0 00 00 00       	call   80011c <sys_getenvid>
  80004c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800051:	89 c2                	mov    %eax,%edx
  800053:	c1 e2 05             	shl    $0x5,%edx
  800056:	29 c2                	sub    %eax,%edx
  800058:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  80005f:	89 15 04 20 80 00    	mov    %edx,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800065:	85 f6                	test   %esi,%esi
  800067:	7e 07                	jle    800070 <libmain+0x34>
		binaryname = argv[0];
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800070:	83 ec 08             	sub    $0x8,%esp
  800073:	53                   	push   %ebx
  800074:	56                   	push   %esi
  800075:	e8 ba ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80007a:	e8 09 00 00 00       	call   800088 <exit>
}
  80007f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800082:	5b                   	pop    %ebx
  800083:	5e                   	pop    %esi
  800084:	c9                   	leave  
  800085:	c3                   	ret    
	...

00800088 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  80008e:	6a 00                	push   $0x0
  800090:	e8 46 00 00 00       	call   8000db <sys_env_destroy>
}
  800095:	c9                   	leave  
  800096:	c3                   	ret    
	...

00800098 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	57                   	push   %edi
  80009c:	56                   	push   %esi
  80009d:	53                   	push   %ebx
  80009e:	83 ec 04             	sub    $0x4,%esp
  8000a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000a7:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ac:	89 f8                	mov    %edi,%eax
  8000ae:	89 fb                	mov    %edi,%ebx
  8000b0:	89 fe                	mov    %edi,%esi
  8000b2:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b4:	83 c4 04             	add    $0x4,%esp
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	5f                   	pop    %edi
  8000ba:	c9                   	leave  
  8000bb:	c3                   	ret    

008000bc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c7:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cc:	89 fa                	mov    %edi,%edx
  8000ce:	89 f9                	mov    %edi,%ecx
  8000d0:	89 fb                	mov    %edi,%ebx
  8000d2:	89 fe                	mov    %edi,%esi
  8000d4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5f                   	pop    %edi
  8000d9:	c9                   	leave  
  8000da:	c3                   	ret    

008000db <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	57                   	push   %edi
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	83 ec 0c             	sub    $0xc,%esp
  8000e4:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000e7:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ec:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f1:	89 f9                	mov    %edi,%ecx
  8000f3:	89 fb                	mov    %edi,%ebx
  8000f5:	89 fe                	mov    %edi,%esi
  8000f7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f9:	85 c0                	test   %eax,%eax
  8000fb:	7e 17                	jle    800114 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fd:	83 ec 0c             	sub    $0xc,%esp
  800100:	50                   	push   %eax
  800101:	6a 03                	push   $0x3
  800103:	68 2a 0f 80 00       	push   $0x800f2a
  800108:	6a 23                	push   $0x23
  80010a:	68 47 0f 80 00       	push   $0x800f47
  80010f:	e8 38 02 00 00       	call   80034c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800114:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800117:	5b                   	pop    %ebx
  800118:	5e                   	pop    %esi
  800119:	5f                   	pop    %edi
  80011a:	c9                   	leave  
  80011b:	c3                   	ret    

0080011c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	57                   	push   %edi
  800120:	56                   	push   %esi
  800121:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800122:	b8 02 00 00 00       	mov    $0x2,%eax
  800127:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012c:	89 fa                	mov    %edi,%edx
  80012e:	89 f9                	mov    %edi,%ecx
  800130:	89 fb                	mov    %edi,%ebx
  800132:	89 fe                	mov    %edi,%esi
  800134:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800136:	5b                   	pop    %ebx
  800137:	5e                   	pop    %esi
  800138:	5f                   	pop    %edi
  800139:	c9                   	leave  
  80013a:	c3                   	ret    

0080013b <sys_yield>:

void
sys_yield(void)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	57                   	push   %edi
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800141:	b8 0b 00 00 00       	mov    $0xb,%eax
  800146:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014b:	89 fa                	mov    %edi,%edx
  80014d:	89 f9                	mov    %edi,%ecx
  80014f:	89 fb                	mov    %edi,%ebx
  800151:	89 fe                	mov    %edi,%esi
  800153:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5f                   	pop    %edi
  800158:	c9                   	leave  
  800159:	c3                   	ret    

0080015a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	8b 55 08             	mov    0x8(%ebp),%edx
  800166:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800169:	8b 5d 10             	mov    0x10(%ebp),%ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80016c:	b8 04 00 00 00       	mov    $0x4,%eax
  800171:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800176:	89 fe                	mov    %edi,%esi
  800178:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80017a:	85 c0                	test   %eax,%eax
  80017c:	7e 17                	jle    800195 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80017e:	83 ec 0c             	sub    $0xc,%esp
  800181:	50                   	push   %eax
  800182:	6a 04                	push   $0x4
  800184:	68 2a 0f 80 00       	push   $0x800f2a
  800189:	6a 23                	push   $0x23
  80018b:	68 47 0f 80 00       	push   $0x800f47
  800190:	e8 b7 01 00 00       	call   80034c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800195:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800198:	5b                   	pop    %ebx
  800199:	5e                   	pop    %esi
  80019a:	5f                   	pop    %edi
  80019b:	c9                   	leave  
  80019c:	c3                   	ret    

0080019d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	57                   	push   %edi
  8001a1:	56                   	push   %esi
  8001a2:	53                   	push   %ebx
  8001a3:	83 ec 0c             	sub    $0xc,%esp
  8001a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001af:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b2:	8b 75 18             	mov    0x18(%ebp),%esi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8001b5:	b8 05 00 00 00       	mov    $0x5,%eax
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ba:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001bc:	85 c0                	test   %eax,%eax
  8001be:	7e 17                	jle    8001d7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c0:	83 ec 0c             	sub    $0xc,%esp
  8001c3:	50                   	push   %eax
  8001c4:	6a 05                	push   $0x5
  8001c6:	68 2a 0f 80 00       	push   $0x800f2a
  8001cb:	6a 23                	push   $0x23
  8001cd:	68 47 0f 80 00       	push   $0x800f47
  8001d2:	e8 75 01 00 00       	call   80034c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001da:	5b                   	pop    %ebx
  8001db:	5e                   	pop    %esi
  8001dc:	5f                   	pop    %edi
  8001dd:	c9                   	leave  
  8001de:	c3                   	ret    

008001df <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	57                   	push   %edi
  8001e3:	56                   	push   %esi
  8001e4:	53                   	push   %ebx
  8001e5:	83 ec 0c             	sub    $0xc,%esp
  8001e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8001ee:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f3:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f8:	89 fb                	mov    %edi,%ebx
  8001fa:	89 fe                	mov    %edi,%esi
  8001fc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001fe:	85 c0                	test   %eax,%eax
  800200:	7e 17                	jle    800219 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	50                   	push   %eax
  800206:	6a 06                	push   $0x6
  800208:	68 2a 0f 80 00       	push   $0x800f2a
  80020d:	6a 23                	push   $0x23
  80020f:	68 47 0f 80 00       	push   $0x800f47
  800214:	e8 33 01 00 00       	call   80034c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800219:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021c:	5b                   	pop    %ebx
  80021d:	5e                   	pop    %esi
  80021e:	5f                   	pop    %edi
  80021f:	c9                   	leave  
  800220:	c3                   	ret    

00800221 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	57                   	push   %edi
  800225:	56                   	push   %esi
  800226:	53                   	push   %ebx
  800227:	83 ec 0c             	sub    $0xc,%esp
  80022a:	8b 55 08             	mov    0x8(%ebp),%edx
  80022d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800230:	b8 08 00 00 00       	mov    $0x8,%eax
  800235:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80023a:	89 fb                	mov    %edi,%ebx
  80023c:	89 fe                	mov    %edi,%esi
  80023e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800240:	85 c0                	test   %eax,%eax
  800242:	7e 17                	jle    80025b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800244:	83 ec 0c             	sub    $0xc,%esp
  800247:	50                   	push   %eax
  800248:	6a 08                	push   $0x8
  80024a:	68 2a 0f 80 00       	push   $0x800f2a
  80024f:	6a 23                	push   $0x23
  800251:	68 47 0f 80 00       	push   $0x800f47
  800256:	e8 f1 00 00 00       	call   80034c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025e:	5b                   	pop    %ebx
  80025f:	5e                   	pop    %esi
  800260:	5f                   	pop    %edi
  800261:	c9                   	leave  
  800262:	c3                   	ret    

00800263 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	57                   	push   %edi
  800267:	56                   	push   %esi
  800268:	53                   	push   %ebx
  800269:	83 ec 0c             	sub    $0xc,%esp
  80026c:	8b 55 08             	mov    0x8(%ebp),%edx
  80026f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800272:	b8 09 00 00 00       	mov    $0x9,%eax
  800277:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027c:	89 fb                	mov    %edi,%ebx
  80027e:	89 fe                	mov    %edi,%esi
  800280:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800282:	85 c0                	test   %eax,%eax
  800284:	7e 17                	jle    80029d <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800286:	83 ec 0c             	sub    $0xc,%esp
  800289:	50                   	push   %eax
  80028a:	6a 09                	push   $0x9
  80028c:	68 2a 0f 80 00       	push   $0x800f2a
  800291:	6a 23                	push   $0x23
  800293:	68 47 0f 80 00       	push   $0x800f47
  800298:	e8 af 00 00 00       	call   80034c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80029d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a0:	5b                   	pop    %ebx
  8002a1:	5e                   	pop    %esi
  8002a2:	5f                   	pop    %edi
  8002a3:	c9                   	leave  
  8002a4:	c3                   	ret    

008002a5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	57                   	push   %edi
  8002a9:	56                   	push   %esi
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 0c             	sub    $0xc,%esp
  8002ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8002b4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b9:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002be:	89 fb                	mov    %edi,%ebx
  8002c0:	89 fe                	mov    %edi,%esi
  8002c2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002c4:	85 c0                	test   %eax,%eax
  8002c6:	7e 17                	jle    8002df <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c8:	83 ec 0c             	sub    $0xc,%esp
  8002cb:	50                   	push   %eax
  8002cc:	6a 0a                	push   $0xa
  8002ce:	68 2a 0f 80 00       	push   $0x800f2a
  8002d3:	6a 23                	push   $0x23
  8002d5:	68 47 0f 80 00       	push   $0x800f47
  8002da:	e8 6d 00 00 00       	call   80034c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e2:	5b                   	pop    %ebx
  8002e3:	5e                   	pop    %esi
  8002e4:	5f                   	pop    %edi
  8002e5:	c9                   	leave  
  8002e6:	c3                   	ret    

008002e7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	57                   	push   %edi
  8002eb:	56                   	push   %esi
  8002ec:	53                   	push   %ebx
  8002ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002f6:	8b 7d 14             	mov    0x14(%ebp),%edi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8002f9:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002fe:	be 00 00 00 00       	mov    $0x0,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800303:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800305:	5b                   	pop    %ebx
  800306:	5e                   	pop    %esi
  800307:	5f                   	pop    %edi
  800308:	c9                   	leave  
  800309:	c3                   	ret    

0080030a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	57                   	push   %edi
  80030e:	56                   	push   %esi
  80030f:	53                   	push   %ebx
  800310:	83 ec 0c             	sub    $0xc,%esp
  800313:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800316:	b8 0d 00 00 00       	mov    $0xd,%eax
  80031b:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800320:	89 f9                	mov    %edi,%ecx
  800322:	89 fb                	mov    %edi,%ebx
  800324:	89 fe                	mov    %edi,%esi
  800326:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800328:	85 c0                	test   %eax,%eax
  80032a:	7e 17                	jle    800343 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80032c:	83 ec 0c             	sub    $0xc,%esp
  80032f:	50                   	push   %eax
  800330:	6a 0d                	push   $0xd
  800332:	68 2a 0f 80 00       	push   $0x800f2a
  800337:	6a 23                	push   $0x23
  800339:	68 47 0f 80 00       	push   $0x800f47
  80033e:	e8 09 00 00 00       	call   80034c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800343:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800346:	5b                   	pop    %ebx
  800347:	5e                   	pop    %esi
  800348:	5f                   	pop    %edi
  800349:	c9                   	leave  
  80034a:	c3                   	ret    
	...

0080034c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80034c:	55                   	push   %ebp
  80034d:	89 e5                	mov    %esp,%ebp
  80034f:	53                   	push   %ebx
  800350:	83 ec 10             	sub    $0x10,%esp
	va_list ap;

	va_start(ap, fmt);
  800353:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800356:	ff 75 0c             	pushl  0xc(%ebp)
  800359:	ff 75 08             	pushl  0x8(%ebp)
  80035c:	ff 35 00 20 80 00    	pushl  0x802000
  800362:	83 ec 08             	sub    $0x8,%esp
  800365:	e8 b2 fd ff ff       	call   80011c <sys_getenvid>
  80036a:	83 c4 08             	add    $0x8,%esp
  80036d:	50                   	push   %eax
  80036e:	68 58 0f 80 00       	push   $0x800f58
  800373:	e8 b0 00 00 00       	call   800428 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800378:	83 c4 18             	add    $0x18,%esp
  80037b:	53                   	push   %ebx
  80037c:	ff 75 10             	pushl  0x10(%ebp)
  80037f:	e8 53 00 00 00       	call   8003d7 <vcprintf>
	cprintf("\n");
  800384:	c7 04 24 7b 0f 80 00 	movl   $0x800f7b,(%esp)
  80038b:	e8 98 00 00 00       	call   800428 <cprintf>

	// Cause a breakpoint exception
	while (1)
  800390:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  800393:	cc                   	int3   
  800394:	eb fd                	jmp    800393 <_panic+0x47>
	...

00800398 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800398:	55                   	push   %ebp
  800399:	89 e5                	mov    %esp,%ebp
  80039b:	53                   	push   %ebx
  80039c:	83 ec 04             	sub    $0x4,%esp
  80039f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003a2:	8b 03                	mov    (%ebx),%eax
  8003a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a7:	88 54 18 08          	mov    %dl,0x8(%eax,%ebx,1)
  8003ab:	40                   	inc    %eax
  8003ac:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8003ae:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003b3:	75 1a                	jne    8003cf <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8003b5:	83 ec 08             	sub    $0x8,%esp
  8003b8:	68 ff 00 00 00       	push   $0xff
  8003bd:	8d 43 08             	lea    0x8(%ebx),%eax
  8003c0:	50                   	push   %eax
  8003c1:	e8 d2 fc ff ff       	call   800098 <sys_cputs>
		b->idx = 0;
  8003c6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003cc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003cf:	ff 43 04             	incl   0x4(%ebx)
}
  8003d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003d5:	c9                   	leave  
  8003d6:	c3                   	ret    

008003d7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003d7:	55                   	push   %ebp
  8003d8:	89 e5                	mov    %esp,%ebp
  8003da:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003e0:	c7 85 e8 fe ff ff 00 	movl   $0x0,-0x118(%ebp)
  8003e7:	00 00 00 
	b.cnt = 0;
  8003ea:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8003f1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003f4:	ff 75 0c             	pushl  0xc(%ebp)
  8003f7:	ff 75 08             	pushl  0x8(%ebp)
  8003fa:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800400:	50                   	push   %eax
  800401:	68 98 03 80 00       	push   $0x800398
  800406:	e8 49 01 00 00       	call   800554 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80040b:	83 c4 08             	add    $0x8,%esp
  80040e:	ff b5 e8 fe ff ff    	pushl  -0x118(%ebp)
  800414:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80041a:	50                   	push   %eax
  80041b:	e8 78 fc ff ff       	call   800098 <sys_cputs>

	return b.cnt;
  800420:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
}
  800426:	c9                   	leave  
  800427:	c3                   	ret    

00800428 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800428:	55                   	push   %ebp
  800429:	89 e5                	mov    %esp,%ebp
  80042b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80042e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800431:	50                   	push   %eax
  800432:	ff 75 08             	pushl  0x8(%ebp)
  800435:	e8 9d ff ff ff       	call   8003d7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80043a:	c9                   	leave  
  80043b:	c3                   	ret    

0080043c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80043c:	55                   	push   %ebp
  80043d:	89 e5                	mov    %esp,%ebp
  80043f:	57                   	push   %edi
  800440:	56                   	push   %esi
  800441:	53                   	push   %ebx
  800442:	83 ec 0c             	sub    $0xc,%esp
  800445:	8b 75 10             	mov    0x10(%ebp),%esi
  800448:	8b 7d 14             	mov    0x14(%ebp),%edi
  80044b:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80044e:	8b 45 18             	mov    0x18(%ebp),%eax
  800451:	ba 00 00 00 00       	mov    $0x0,%edx
  800456:	39 fa                	cmp    %edi,%edx
  800458:	77 39                	ja     800493 <printnum+0x57>
  80045a:	72 04                	jb     800460 <printnum+0x24>
  80045c:	39 f0                	cmp    %esi,%eax
  80045e:	77 33                	ja     800493 <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800460:	83 ec 04             	sub    $0x4,%esp
  800463:	ff 75 20             	pushl  0x20(%ebp)
  800466:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800469:	50                   	push   %eax
  80046a:	ff 75 18             	pushl  0x18(%ebp)
  80046d:	8b 45 18             	mov    0x18(%ebp),%eax
  800470:	ba 00 00 00 00       	mov    $0x0,%edx
  800475:	52                   	push   %edx
  800476:	50                   	push   %eax
  800477:	57                   	push   %edi
  800478:	56                   	push   %esi
  800479:	e8 de 07 00 00       	call   800c5c <__udivdi3>
  80047e:	83 c4 10             	add    $0x10,%esp
  800481:	52                   	push   %edx
  800482:	50                   	push   %eax
  800483:	ff 75 0c             	pushl  0xc(%ebp)
  800486:	ff 75 08             	pushl  0x8(%ebp)
  800489:	e8 ae ff ff ff       	call   80043c <printnum>
  80048e:	83 c4 20             	add    $0x20,%esp
  800491:	eb 19                	jmp    8004ac <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800493:	4b                   	dec    %ebx
  800494:	85 db                	test   %ebx,%ebx
  800496:	7e 14                	jle    8004ac <printnum+0x70>
  800498:	83 ec 08             	sub    $0x8,%esp
  80049b:	ff 75 0c             	pushl  0xc(%ebp)
  80049e:	ff 75 20             	pushl  0x20(%ebp)
  8004a1:	ff 55 08             	call   *0x8(%ebp)
  8004a4:	83 c4 10             	add    $0x10,%esp
  8004a7:	4b                   	dec    %ebx
  8004a8:	85 db                	test   %ebx,%ebx
  8004aa:	7f ec                	jg     800498 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004ac:	83 ec 08             	sub    $0x8,%esp
  8004af:	ff 75 0c             	pushl  0xc(%ebp)
  8004b2:	8b 45 18             	mov    0x18(%ebp),%eax
  8004b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ba:	83 ec 04             	sub    $0x4,%esp
  8004bd:	52                   	push   %edx
  8004be:	50                   	push   %eax
  8004bf:	57                   	push   %edi
  8004c0:	56                   	push   %esi
  8004c1:	e8 a2 08 00 00       	call   800d68 <__umoddi3>
  8004c6:	83 c4 14             	add    $0x14,%esp
  8004c9:	0f be 80 8f 10 80 00 	movsbl 0x80108f(%eax),%eax
  8004d0:	50                   	push   %eax
  8004d1:	ff 55 08             	call   *0x8(%ebp)
}
  8004d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004d7:	5b                   	pop    %ebx
  8004d8:	5e                   	pop    %esi
  8004d9:	5f                   	pop    %edi
  8004da:	c9                   	leave  
  8004db:	c3                   	ret    

008004dc <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004dc:	55                   	push   %ebp
  8004dd:	89 e5                	mov    %esp,%ebp
  8004df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004e2:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  8004e5:	83 f8 01             	cmp    $0x1,%eax
  8004e8:	7e 0e                	jle    8004f8 <getuint+0x1c>
		return va_arg(*ap, unsigned long long);
  8004ea:	8b 11                	mov    (%ecx),%edx
  8004ec:	8d 42 08             	lea    0x8(%edx),%eax
  8004ef:	89 01                	mov    %eax,(%ecx)
  8004f1:	8b 02                	mov    (%edx),%eax
  8004f3:	8b 52 04             	mov    0x4(%edx),%edx
  8004f6:	eb 22                	jmp    80051a <getuint+0x3e>
	else if (lflag)
  8004f8:	85 c0                	test   %eax,%eax
  8004fa:	74 10                	je     80050c <getuint+0x30>
		return va_arg(*ap, unsigned long);
  8004fc:	8b 11                	mov    (%ecx),%edx
  8004fe:	8d 42 04             	lea    0x4(%edx),%eax
  800501:	89 01                	mov    %eax,(%ecx)
  800503:	8b 02                	mov    (%edx),%eax
  800505:	ba 00 00 00 00       	mov    $0x0,%edx
  80050a:	eb 0e                	jmp    80051a <getuint+0x3e>
	else
		return va_arg(*ap, unsigned int);
  80050c:	8b 11                	mov    (%ecx),%edx
  80050e:	8d 42 04             	lea    0x4(%edx),%eax
  800511:	89 01                	mov    %eax,(%ecx)
  800513:	8b 02                	mov    (%edx),%eax
  800515:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80051a:	c9                   	leave  
  80051b:	c3                   	ret    

0080051c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80051c:	55                   	push   %ebp
  80051d:	89 e5                	mov    %esp,%ebp
  80051f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800522:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800525:	83 f8 01             	cmp    $0x1,%eax
  800528:	7e 0e                	jle    800538 <getint+0x1c>
		return va_arg(*ap, long long);
  80052a:	8b 11                	mov    (%ecx),%edx
  80052c:	8d 42 08             	lea    0x8(%edx),%eax
  80052f:	89 01                	mov    %eax,(%ecx)
  800531:	8b 02                	mov    (%edx),%eax
  800533:	8b 52 04             	mov    0x4(%edx),%edx
  800536:	eb 1a                	jmp    800552 <getint+0x36>
	else if (lflag)
  800538:	85 c0                	test   %eax,%eax
  80053a:	74 0c                	je     800548 <getint+0x2c>
		return va_arg(*ap, long);
  80053c:	8b 01                	mov    (%ecx),%eax
  80053e:	8d 50 04             	lea    0x4(%eax),%edx
  800541:	89 11                	mov    %edx,(%ecx)
  800543:	8b 00                	mov    (%eax),%eax
  800545:	99                   	cltd   
  800546:	eb 0a                	jmp    800552 <getint+0x36>
	else
		return va_arg(*ap, int);
  800548:	8b 01                	mov    (%ecx),%eax
  80054a:	8d 50 04             	lea    0x4(%eax),%edx
  80054d:	89 11                	mov    %edx,(%ecx)
  80054f:	8b 00                	mov    (%eax),%eax
  800551:	99                   	cltd   
}
  800552:	c9                   	leave  
  800553:	c3                   	ret    

00800554 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800554:	55                   	push   %ebp
  800555:	89 e5                	mov    %esp,%ebp
  800557:	57                   	push   %edi
  800558:	56                   	push   %esi
  800559:	53                   	push   %ebx
  80055a:	83 ec 1c             	sub    $0x1c,%esp
  80055d:	8b 5d 10             	mov    0x10(%ebp),%ebx

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
			putch(ch, putdat);
  800560:	0f b6 0b             	movzbl (%ebx),%ecx
  800563:	43                   	inc    %ebx
  800564:	83 f9 25             	cmp    $0x25,%ecx
  800567:	74 1e                	je     800587 <vprintfmt+0x33>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800569:	85 c9                	test   %ecx,%ecx
  80056b:	0f 84 dc 02 00 00    	je     80084d <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	ff 75 0c             	pushl  0xc(%ebp)
  800577:	51                   	push   %ecx
  800578:	ff 55 08             	call   *0x8(%ebp)
  80057b:	83 c4 10             	add    $0x10,%esp
  80057e:	0f b6 0b             	movzbl (%ebx),%ecx
  800581:	43                   	inc    %ebx
  800582:	83 f9 25             	cmp    $0x25,%ecx
  800585:	75 e2                	jne    800569 <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  800587:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
		width = -1;
  80058b:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
		precision = -1;
  800592:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  800597:	bf 00 00 00 00       	mov    $0x0,%edi
		altflag = 0;
  80059c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a3:	0f b6 0b             	movzbl (%ebx),%ecx
  8005a6:	8d 41 dd             	lea    -0x23(%ecx),%eax
  8005a9:	43                   	inc    %ebx
  8005aa:	83 f8 55             	cmp    $0x55,%eax
  8005ad:	0f 87 75 02 00 00    	ja     800828 <vprintfmt+0x2d4>
  8005b3:	ff 24 85 20 11 80 00 	jmp    *0x801120(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  8005ba:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
			goto reswitch;
  8005be:	eb e3                	jmp    8005a3 <vprintfmt+0x4f>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005c0:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
			goto reswitch;
  8005c4:	eb dd                	jmp    8005a3 <vprintfmt+0x4f>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005c6:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  8005cb:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  8005ce:	8d 74 41 d0          	lea    -0x30(%ecx,%eax,2),%esi
				ch = *fmt;
  8005d2:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  8005d5:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8005d8:	83 f8 09             	cmp    $0x9,%eax
  8005db:	77 28                	ja     800605 <vprintfmt+0xb1>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005dd:	43                   	inc    %ebx
  8005de:	eb eb                	jmp    8005cb <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005e0:	8b 55 14             	mov    0x14(%ebp),%edx
  8005e3:	8d 42 04             	lea    0x4(%edx),%eax
  8005e6:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e9:	8b 32                	mov    (%edx),%esi
			goto process_precision;
  8005eb:	eb 18                	jmp    800605 <vprintfmt+0xb1>

		case '.':
			if (width < 0)
  8005ed:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8005f1:	79 b0                	jns    8005a3 <vprintfmt+0x4f>
				width = 0;
  8005f3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
			goto reswitch;
  8005fa:	eb a7                	jmp    8005a3 <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  8005fc:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
			goto reswitch;
  800603:	eb 9e                	jmp    8005a3 <vprintfmt+0x4f>

		process_precision:
			if (width < 0)
  800605:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800609:	79 98                	jns    8005a3 <vprintfmt+0x4f>
				width = precision, precision = -1;
  80060b:	89 75 f0             	mov    %esi,-0x10(%ebp)
  80060e:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  800613:	eb 8e                	jmp    8005a3 <vprintfmt+0x4f>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800615:	47                   	inc    %edi
			goto reswitch;
  800616:	eb 8b                	jmp    8005a3 <vprintfmt+0x4f>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800618:	83 ec 08             	sub    $0x8,%esp
  80061b:	ff 75 0c             	pushl  0xc(%ebp)
  80061e:	8b 55 14             	mov    0x14(%ebp),%edx
  800621:	8d 42 04             	lea    0x4(%edx),%eax
  800624:	89 45 14             	mov    %eax,0x14(%ebp)
  800627:	ff 32                	pushl  (%edx)
  800629:	ff 55 08             	call   *0x8(%ebp)
			break;
  80062c:	83 c4 10             	add    $0x10,%esp
  80062f:	e9 2c ff ff ff       	jmp    800560 <vprintfmt+0xc>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800634:	8b 55 14             	mov    0x14(%ebp),%edx
  800637:	8d 42 04             	lea    0x4(%edx),%eax
  80063a:	89 45 14             	mov    %eax,0x14(%ebp)
  80063d:	8b 02                	mov    (%edx),%eax
			if (err < 0)
  80063f:	85 c0                	test   %eax,%eax
  800641:	79 02                	jns    800645 <vprintfmt+0xf1>
				err = -err;
  800643:	f7 d8                	neg    %eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800645:	83 f8 0f             	cmp    $0xf,%eax
  800648:	7f 0b                	jg     800655 <vprintfmt+0x101>
  80064a:	8b 3c 85 e0 10 80 00 	mov    0x8010e0(,%eax,4),%edi
  800651:	85 ff                	test   %edi,%edi
  800653:	75 19                	jne    80066e <vprintfmt+0x11a>
				printfmt(putch, putdat, "error %d", err);
  800655:	50                   	push   %eax
  800656:	68 a0 10 80 00       	push   $0x8010a0
  80065b:	ff 75 0c             	pushl  0xc(%ebp)
  80065e:	ff 75 08             	pushl  0x8(%ebp)
  800661:	e8 ef 01 00 00       	call   800855 <printfmt>
  800666:	83 c4 10             	add    $0x10,%esp
  800669:	e9 f2 fe ff ff       	jmp    800560 <vprintfmt+0xc>
			else
				printfmt(putch, putdat, "%s", p);
  80066e:	57                   	push   %edi
  80066f:	68 a9 10 80 00       	push   $0x8010a9
  800674:	ff 75 0c             	pushl  0xc(%ebp)
  800677:	ff 75 08             	pushl  0x8(%ebp)
  80067a:	e8 d6 01 00 00       	call   800855 <printfmt>
  80067f:	83 c4 10             	add    $0x10,%esp
			break;
  800682:	e9 d9 fe ff ff       	jmp    800560 <vprintfmt+0xc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800687:	8b 55 14             	mov    0x14(%ebp),%edx
  80068a:	8d 42 04             	lea    0x4(%edx),%eax
  80068d:	89 45 14             	mov    %eax,0x14(%ebp)
  800690:	8b 3a                	mov    (%edx),%edi
  800692:	85 ff                	test   %edi,%edi
  800694:	75 05                	jne    80069b <vprintfmt+0x147>
				p = "(null)";
  800696:	bf ac 10 80 00       	mov    $0x8010ac,%edi
			if (width > 0 && padc != '-')
  80069b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80069f:	7e 3b                	jle    8006dc <vprintfmt+0x188>
  8006a1:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  8006a5:	74 35                	je     8006dc <vprintfmt+0x188>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a7:	83 ec 08             	sub    $0x8,%esp
  8006aa:	56                   	push   %esi
  8006ab:	57                   	push   %edi
  8006ac:	e8 58 02 00 00       	call   800909 <strnlen>
  8006b1:	29 45 f0             	sub    %eax,-0x10(%ebp)
  8006b4:	83 c4 10             	add    $0x10,%esp
  8006b7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8006bb:	7e 1f                	jle    8006dc <vprintfmt+0x188>
  8006bd:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  8006c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
					putch(padc, putdat);
  8006c4:	83 ec 08             	sub    $0x8,%esp
  8006c7:	ff 75 0c             	pushl  0xc(%ebp)
  8006ca:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006cd:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d0:	83 c4 10             	add    $0x10,%esp
  8006d3:	ff 4d f0             	decl   -0x10(%ebp)
  8006d6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8006da:	7f e8                	jg     8006c4 <vprintfmt+0x170>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006dc:	0f be 0f             	movsbl (%edi),%ecx
  8006df:	47                   	inc    %edi
  8006e0:	85 c9                	test   %ecx,%ecx
  8006e2:	74 44                	je     800728 <vprintfmt+0x1d4>
  8006e4:	85 f6                	test   %esi,%esi
  8006e6:	78 03                	js     8006eb <vprintfmt+0x197>
  8006e8:	4e                   	dec    %esi
  8006e9:	78 3d                	js     800728 <vprintfmt+0x1d4>
				if (altflag && (ch < ' ' || ch > '~'))
  8006eb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8006ef:	74 18                	je     800709 <vprintfmt+0x1b5>
  8006f1:	8d 41 e0             	lea    -0x20(%ecx),%eax
  8006f4:	83 f8 5e             	cmp    $0x5e,%eax
  8006f7:	76 10                	jbe    800709 <vprintfmt+0x1b5>
					putch('?', putdat);
  8006f9:	83 ec 08             	sub    $0x8,%esp
  8006fc:	ff 75 0c             	pushl  0xc(%ebp)
  8006ff:	6a 3f                	push   $0x3f
  800701:	ff 55 08             	call   *0x8(%ebp)
  800704:	83 c4 10             	add    $0x10,%esp
  800707:	eb 0d                	jmp    800716 <vprintfmt+0x1c2>
				else
					putch(ch, putdat);
  800709:	83 ec 08             	sub    $0x8,%esp
  80070c:	ff 75 0c             	pushl  0xc(%ebp)
  80070f:	51                   	push   %ecx
  800710:	ff 55 08             	call   *0x8(%ebp)
  800713:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800716:	ff 4d f0             	decl   -0x10(%ebp)
  800719:	0f be 0f             	movsbl (%edi),%ecx
  80071c:	47                   	inc    %edi
  80071d:	85 c9                	test   %ecx,%ecx
  80071f:	74 07                	je     800728 <vprintfmt+0x1d4>
  800721:	85 f6                	test   %esi,%esi
  800723:	78 c6                	js     8006eb <vprintfmt+0x197>
  800725:	4e                   	dec    %esi
  800726:	79 c3                	jns    8006eb <vprintfmt+0x197>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800728:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80072c:	0f 8e 2e fe ff ff    	jle    800560 <vprintfmt+0xc>
				putch(' ', putdat);
  800732:	83 ec 08             	sub    $0x8,%esp
  800735:	ff 75 0c             	pushl  0xc(%ebp)
  800738:	6a 20                	push   $0x20
  80073a:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80073d:	83 c4 10             	add    $0x10,%esp
  800740:	ff 4d f0             	decl   -0x10(%ebp)
  800743:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800747:	7f e9                	jg     800732 <vprintfmt+0x1de>
				putch(' ', putdat);
			break;
  800749:	e9 12 fe ff ff       	jmp    800560 <vprintfmt+0xc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80074e:	57                   	push   %edi
  80074f:	8d 45 14             	lea    0x14(%ebp),%eax
  800752:	50                   	push   %eax
  800753:	e8 c4 fd ff ff       	call   80051c <getint>
  800758:	89 c6                	mov    %eax,%esi
  80075a:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  80075c:	83 c4 08             	add    $0x8,%esp
  80075f:	85 d2                	test   %edx,%edx
  800761:	79 15                	jns    800778 <vprintfmt+0x224>
				putch('-', putdat);
  800763:	83 ec 08             	sub    $0x8,%esp
  800766:	ff 75 0c             	pushl  0xc(%ebp)
  800769:	6a 2d                	push   $0x2d
  80076b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80076e:	f7 de                	neg    %esi
  800770:	83 d7 00             	adc    $0x0,%edi
  800773:	f7 df                	neg    %edi
  800775:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800778:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  80077d:	eb 76                	jmp    8007f5 <vprintfmt+0x2a1>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80077f:	57                   	push   %edi
  800780:	8d 45 14             	lea    0x14(%ebp),%eax
  800783:	50                   	push   %eax
  800784:	e8 53 fd ff ff       	call   8004dc <getuint>
  800789:	89 c6                	mov    %eax,%esi
  80078b:	89 d7                	mov    %edx,%edi
			base = 10;
  80078d:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  800792:	83 c4 08             	add    $0x8,%esp
  800795:	eb 5e                	jmp    8007f5 <vprintfmt+0x2a1>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800797:	57                   	push   %edi
  800798:	8d 45 14             	lea    0x14(%ebp),%eax
  80079b:	50                   	push   %eax
  80079c:	e8 3b fd ff ff       	call   8004dc <getuint>
  8007a1:	89 c6                	mov    %eax,%esi
  8007a3:	89 d7                	mov    %edx,%edi
			base = 8;
  8007a5:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  8007aa:	83 c4 08             	add    $0x8,%esp
  8007ad:	eb 46                	jmp    8007f5 <vprintfmt+0x2a1>

		// pointer
		case 'p':
			putch('0', putdat);
  8007af:	83 ec 08             	sub    $0x8,%esp
  8007b2:	ff 75 0c             	pushl  0xc(%ebp)
  8007b5:	6a 30                	push   $0x30
  8007b7:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007ba:	83 c4 08             	add    $0x8,%esp
  8007bd:	ff 75 0c             	pushl  0xc(%ebp)
  8007c0:	6a 78                	push   $0x78
  8007c2:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8007c5:	8b 55 14             	mov    0x14(%ebp),%edx
  8007c8:	8d 42 04             	lea    0x4(%edx),%eax
  8007cb:	89 45 14             	mov    %eax,0x14(%ebp)
  8007ce:	8b 32                	mov    (%edx),%esi
  8007d0:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007d5:	ba 10 00 00 00       	mov    $0x10,%edx
			goto number;
  8007da:	83 c4 10             	add    $0x10,%esp
  8007dd:	eb 16                	jmp    8007f5 <vprintfmt+0x2a1>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007df:	57                   	push   %edi
  8007e0:	8d 45 14             	lea    0x14(%ebp),%eax
  8007e3:	50                   	push   %eax
  8007e4:	e8 f3 fc ff ff       	call   8004dc <getuint>
  8007e9:	89 c6                	mov    %eax,%esi
  8007eb:	89 d7                	mov    %edx,%edi
			base = 16;
  8007ed:	ba 10 00 00 00       	mov    $0x10,%edx
  8007f2:	83 c4 08             	add    $0x8,%esp
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007f5:	83 ec 04             	sub    $0x4,%esp
  8007f8:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  8007fc:	50                   	push   %eax
  8007fd:	ff 75 f0             	pushl  -0x10(%ebp)
  800800:	52                   	push   %edx
  800801:	57                   	push   %edi
  800802:	56                   	push   %esi
  800803:	ff 75 0c             	pushl  0xc(%ebp)
  800806:	ff 75 08             	pushl  0x8(%ebp)
  800809:	e8 2e fc ff ff       	call   80043c <printnum>
			break;
  80080e:	83 c4 20             	add    $0x20,%esp
  800811:	e9 4a fd ff ff       	jmp    800560 <vprintfmt+0xc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800816:	83 ec 08             	sub    $0x8,%esp
  800819:	ff 75 0c             	pushl  0xc(%ebp)
  80081c:	51                   	push   %ecx
  80081d:	ff 55 08             	call   *0x8(%ebp)
			break;
  800820:	83 c4 10             	add    $0x10,%esp
  800823:	e9 38 fd ff ff       	jmp    800560 <vprintfmt+0xc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800828:	83 ec 08             	sub    $0x8,%esp
  80082b:	ff 75 0c             	pushl  0xc(%ebp)
  80082e:	6a 25                	push   $0x25
  800830:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800833:	4b                   	dec    %ebx
  800834:	83 c4 10             	add    $0x10,%esp
  800837:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80083b:	0f 84 1f fd ff ff    	je     800560 <vprintfmt+0xc>
  800841:	4b                   	dec    %ebx
  800842:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800846:	75 f9                	jne    800841 <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  800848:	e9 13 fd ff ff       	jmp    800560 <vprintfmt+0xc>
		}
	}
}
  80084d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800850:	5b                   	pop    %ebx
  800851:	5e                   	pop    %esi
  800852:	5f                   	pop    %edi
  800853:	c9                   	leave  
  800854:	c3                   	ret    

00800855 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80085b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80085e:	50                   	push   %eax
  80085f:	ff 75 10             	pushl  0x10(%ebp)
  800862:	ff 75 0c             	pushl  0xc(%ebp)
  800865:	ff 75 08             	pushl  0x8(%ebp)
  800868:	e8 e7 fc ff ff       	call   800554 <vprintfmt>
	va_end(ap);
}
  80086d:	c9                   	leave  
  80086e:	c3                   	ret    

0080086f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  800875:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  800878:	8b 0a                	mov    (%edx),%ecx
  80087a:	3b 4a 04             	cmp    0x4(%edx),%ecx
  80087d:	73 07                	jae    800886 <sprintputch+0x17>
		*b->buf++ = ch;
  80087f:	8b 45 08             	mov    0x8(%ebp),%eax
  800882:	88 01                	mov    %al,(%ecx)
  800884:	ff 02                	incl   (%edx)
}
  800886:	c9                   	leave  
  800887:	c3                   	ret    

00800888 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	83 ec 18             	sub    $0x18,%esp
  80088e:	8b 55 08             	mov    0x8(%ebp),%edx
  800891:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800894:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800897:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
  80089b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80089e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

	if (buf == NULL || n < 1)
  8008a5:	85 d2                	test   %edx,%edx
  8008a7:	74 04                	je     8008ad <vsnprintf+0x25>
  8008a9:	85 c9                	test   %ecx,%ecx
  8008ab:	7f 07                	jg     8008b4 <vsnprintf+0x2c>
		return -E_INVAL;
  8008ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008b2:	eb 1d                	jmp    8008d1 <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008b4:	ff 75 14             	pushl  0x14(%ebp)
  8008b7:	ff 75 10             	pushl  0x10(%ebp)
  8008ba:	8d 45 e8             	lea    -0x18(%ebp),%eax
  8008bd:	50                   	push   %eax
  8008be:	68 6f 08 80 00       	push   $0x80086f
  8008c3:	e8 8c fc ff ff       	call   800554 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8008cb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8008d1:	c9                   	leave  
  8008d2:	c3                   	ret    

008008d3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008d3:	55                   	push   %ebp
  8008d4:	89 e5                	mov    %esp,%ebp
  8008d6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008d9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008dc:	50                   	push   %eax
  8008dd:	ff 75 10             	pushl  0x10(%ebp)
  8008e0:	ff 75 0c             	pushl  0xc(%ebp)
  8008e3:	ff 75 08             	pushl  0x8(%ebp)
  8008e6:	e8 9d ff ff ff       	call   800888 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008eb:	c9                   	leave  
  8008ec:	c3                   	ret    
  8008ed:	00 00                	add    %al,(%eax)
	...

008008f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008fb:	80 3a 00             	cmpb   $0x0,(%edx)
  8008fe:	74 07                	je     800907 <strlen+0x17>
		n++;
  800900:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800901:	42                   	inc    %edx
  800902:	80 3a 00             	cmpb   $0x0,(%edx)
  800905:	75 f9                	jne    800900 <strlen+0x10>
		n++;
	return n;
}
  800907:	c9                   	leave  
  800908:	c3                   	ret    

00800909 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80090f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800912:	b8 00 00 00 00       	mov    $0x0,%eax
  800917:	85 d2                	test   %edx,%edx
  800919:	74 0f                	je     80092a <strnlen+0x21>
  80091b:	80 39 00             	cmpb   $0x0,(%ecx)
  80091e:	74 0a                	je     80092a <strnlen+0x21>
		n++;
  800920:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800921:	41                   	inc    %ecx
  800922:	4a                   	dec    %edx
  800923:	74 05                	je     80092a <strnlen+0x21>
  800925:	80 39 00             	cmpb   $0x0,(%ecx)
  800928:	75 f6                	jne    800920 <strnlen+0x17>
		n++;
	return n;
}
  80092a:	c9                   	leave  
  80092b:	c3                   	ret    

0080092c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	53                   	push   %ebx
  800930:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800933:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  800936:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  800938:	8a 02                	mov    (%edx),%al
  80093a:	42                   	inc    %edx
  80093b:	88 01                	mov    %al,(%ecx)
  80093d:	41                   	inc    %ecx
  80093e:	84 c0                	test   %al,%al
  800940:	75 f6                	jne    800938 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800942:	89 d8                	mov    %ebx,%eax
  800944:	5b                   	pop    %ebx
  800945:	c9                   	leave  
  800946:	c3                   	ret    

00800947 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	53                   	push   %ebx
  80094b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80094e:	53                   	push   %ebx
  80094f:	e8 9c ff ff ff       	call   8008f0 <strlen>
	strcpy(dst + len, src);
  800954:	ff 75 0c             	pushl  0xc(%ebp)
  800957:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80095a:	50                   	push   %eax
  80095b:	e8 cc ff ff ff       	call   80092c <strcpy>
	return dst;
}
  800960:	89 d8                	mov    %ebx,%eax
  800962:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800965:	c9                   	leave  
  800966:	c3                   	ret    

00800967 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	57                   	push   %edi
  80096b:	56                   	push   %esi
  80096c:	53                   	push   %ebx
  80096d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800970:	8b 55 0c             	mov    0xc(%ebp),%edx
  800973:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  800976:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  800978:	bb 00 00 00 00       	mov    $0x0,%ebx
  80097d:	39 f3                	cmp    %esi,%ebx
  80097f:	73 10                	jae    800991 <strncpy+0x2a>
		*dst++ = *src;
  800981:	8a 02                	mov    (%edx),%al
  800983:	88 01                	mov    %al,(%ecx)
  800985:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800986:	80 3a 01             	cmpb   $0x1,(%edx)
  800989:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80098c:	43                   	inc    %ebx
  80098d:	39 f3                	cmp    %esi,%ebx
  80098f:	72 f0                	jb     800981 <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800991:	89 f8                	mov    %edi,%eax
  800993:	5b                   	pop    %ebx
  800994:	5e                   	pop    %esi
  800995:	5f                   	pop    %edi
  800996:	c9                   	leave  
  800997:	c3                   	ret    

00800998 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	56                   	push   %esi
  80099c:	53                   	push   %ebx
  80099d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009a3:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  8009a6:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  8009a8:	85 d2                	test   %edx,%edx
  8009aa:	74 19                	je     8009c5 <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009ac:	4a                   	dec    %edx
  8009ad:	74 13                	je     8009c2 <strlcpy+0x2a>
  8009af:	80 39 00             	cmpb   $0x0,(%ecx)
  8009b2:	74 0e                	je     8009c2 <strlcpy+0x2a>
  8009b4:	8a 01                	mov    (%ecx),%al
  8009b6:	41                   	inc    %ecx
  8009b7:	88 03                	mov    %al,(%ebx)
  8009b9:	43                   	inc    %ebx
  8009ba:	4a                   	dec    %edx
  8009bb:	74 05                	je     8009c2 <strlcpy+0x2a>
  8009bd:	80 39 00             	cmpb   $0x0,(%ecx)
  8009c0:	75 f2                	jne    8009b4 <strlcpy+0x1c>
		*dst = '\0';
  8009c2:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  8009c5:	89 d8                	mov    %ebx,%eax
  8009c7:	29 f0                	sub    %esi,%eax
}
  8009c9:	5b                   	pop    %ebx
  8009ca:	5e                   	pop    %esi
  8009cb:	c9                   	leave  
  8009cc:	c3                   	ret    

008009cd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8009d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
		p++, q++;
  8009d6:	80 3a 00             	cmpb   $0x0,(%edx)
  8009d9:	74 13                	je     8009ee <strcmp+0x21>
  8009db:	8a 02                	mov    (%edx),%al
  8009dd:	3a 01                	cmp    (%ecx),%al
  8009df:	75 0d                	jne    8009ee <strcmp+0x21>
  8009e1:	42                   	inc    %edx
  8009e2:	41                   	inc    %ecx
  8009e3:	80 3a 00             	cmpb   $0x0,(%edx)
  8009e6:	74 06                	je     8009ee <strcmp+0x21>
  8009e8:	8a 02                	mov    (%edx),%al
  8009ea:	3a 01                	cmp    (%ecx),%al
  8009ec:	74 f3                	je     8009e1 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ee:	0f b6 02             	movzbl (%edx),%eax
  8009f1:	0f b6 11             	movzbl (%ecx),%edx
  8009f4:	29 d0                	sub    %edx,%eax
}
  8009f6:	c9                   	leave  
  8009f7:	c3                   	ret    

008009f8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
  8009fb:	53                   	push   %ebx
  8009fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8009ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a02:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800a05:	85 c9                	test   %ecx,%ecx
  800a07:	74 1f                	je     800a28 <strncmp+0x30>
  800a09:	80 3a 00             	cmpb   $0x0,(%edx)
  800a0c:	74 16                	je     800a24 <strncmp+0x2c>
  800a0e:	8a 02                	mov    (%edx),%al
  800a10:	3a 03                	cmp    (%ebx),%al
  800a12:	75 10                	jne    800a24 <strncmp+0x2c>
  800a14:	42                   	inc    %edx
  800a15:	43                   	inc    %ebx
  800a16:	49                   	dec    %ecx
  800a17:	74 0f                	je     800a28 <strncmp+0x30>
  800a19:	80 3a 00             	cmpb   $0x0,(%edx)
  800a1c:	74 06                	je     800a24 <strncmp+0x2c>
  800a1e:	8a 02                	mov    (%edx),%al
  800a20:	3a 03                	cmp    (%ebx),%al
  800a22:	74 f0                	je     800a14 <strncmp+0x1c>
	if (n == 0)
  800a24:	85 c9                	test   %ecx,%ecx
  800a26:	75 07                	jne    800a2f <strncmp+0x37>
		return 0;
  800a28:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2d:	eb 0a                	jmp    800a39 <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a2f:	0f b6 12             	movzbl (%edx),%edx
  800a32:	0f b6 03             	movzbl (%ebx),%eax
  800a35:	29 c2                	sub    %eax,%edx
  800a37:	89 d0                	mov    %edx,%eax
}
  800a39:	5b                   	pop    %ebx
  800a3a:	c9                   	leave  
  800a3b:	c3                   	ret    

00800a3c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a42:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800a45:	80 38 00             	cmpb   $0x0,(%eax)
  800a48:	74 0a                	je     800a54 <strchr+0x18>
		if (*s == c)
  800a4a:	38 10                	cmp    %dl,(%eax)
  800a4c:	74 0b                	je     800a59 <strchr+0x1d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a4e:	40                   	inc    %eax
  800a4f:	80 38 00             	cmpb   $0x0,(%eax)
  800a52:	75 f6                	jne    800a4a <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800a54:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a59:	c9                   	leave  
  800a5a:	c3                   	ret    

00800a5b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a61:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800a64:	80 38 00             	cmpb   $0x0,(%eax)
  800a67:	74 0a                	je     800a73 <strfind+0x18>
		if (*s == c)
  800a69:	38 10                	cmp    %dl,(%eax)
  800a6b:	74 06                	je     800a73 <strfind+0x18>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a6d:	40                   	inc    %eax
  800a6e:	80 38 00             	cmpb   $0x0,(%eax)
  800a71:	75 f6                	jne    800a69 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
}
  800a73:	c9                   	leave  
  800a74:	c3                   	ret    

00800a75 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a75:	55                   	push   %ebp
  800a76:	89 e5                	mov    %esp,%ebp
  800a78:	57                   	push   %edi
  800a79:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a7c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
		return v;
  800a7f:	89 f8                	mov    %edi,%eax
void *
memset(void *v, int c, size_t n)
{
	char *p;

	if (n == 0)
  800a81:	85 c9                	test   %ecx,%ecx
  800a83:	74 40                	je     800ac5 <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a85:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a8b:	75 30                	jne    800abd <memset+0x48>
  800a8d:	f6 c1 03             	test   $0x3,%cl
  800a90:	75 2b                	jne    800abd <memset+0x48>
		c &= 0xFF;
  800a92:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a99:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9c:	c1 e0 18             	shl    $0x18,%eax
  800a9f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa2:	c1 e2 10             	shl    $0x10,%edx
  800aa5:	09 d0                	or     %edx,%eax
  800aa7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aaa:	c1 e2 08             	shl    $0x8,%edx
  800aad:	09 d0                	or     %edx,%eax
  800aaf:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  800ab2:	c1 e9 02             	shr    $0x2,%ecx
  800ab5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab8:	fc                   	cld    
  800ab9:	f3 ab                	rep stos %eax,%es:(%edi)
  800abb:	eb 06                	jmp    800ac3 <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800abd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac0:	fc                   	cld    
  800ac1:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800ac3:	89 f8                	mov    %edi,%eax
}
  800ac5:	5f                   	pop    %edi
  800ac6:	c9                   	leave  
  800ac7:	c3                   	ret    

00800ac8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ac8:	55                   	push   %ebp
  800ac9:	89 e5                	mov    %esp,%ebp
  800acb:	57                   	push   %edi
  800acc:	56                   	push   %esi
  800acd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800ad3:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800ad6:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800ad8:	39 c6                	cmp    %eax,%esi
  800ada:	73 34                	jae    800b10 <memmove+0x48>
  800adc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800adf:	39 c2                	cmp    %eax,%edx
  800ae1:	76 2d                	jbe    800b10 <memmove+0x48>
		s += n;
  800ae3:	89 d6                	mov    %edx,%esi
		d += n;
  800ae5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae8:	f6 c2 03             	test   $0x3,%dl
  800aeb:	75 1b                	jne    800b08 <memmove+0x40>
  800aed:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800af3:	75 13                	jne    800b08 <memmove+0x40>
  800af5:	f6 c1 03             	test   $0x3,%cl
  800af8:	75 0e                	jne    800b08 <memmove+0x40>
			asm volatile("std; rep movsl\n"
  800afa:	83 ef 04             	sub    $0x4,%edi
  800afd:	83 ee 04             	sub    $0x4,%esi
  800b00:	c1 e9 02             	shr    $0x2,%ecx
  800b03:	fd                   	std    
  800b04:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b06:	eb 05                	jmp    800b0d <memmove+0x45>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b08:	4f                   	dec    %edi
  800b09:	4e                   	dec    %esi
  800b0a:	fd                   	std    
  800b0b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b0d:	fc                   	cld    
  800b0e:	eb 20                	jmp    800b30 <memmove+0x68>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b10:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b16:	75 15                	jne    800b2d <memmove+0x65>
  800b18:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b1e:	75 0d                	jne    800b2d <memmove+0x65>
  800b20:	f6 c1 03             	test   $0x3,%cl
  800b23:	75 08                	jne    800b2d <memmove+0x65>
			asm volatile("cld; rep movsl\n"
  800b25:	c1 e9 02             	shr    $0x2,%ecx
  800b28:	fc                   	cld    
  800b29:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b2b:	eb 03                	jmp    800b30 <memmove+0x68>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b2d:	fc                   	cld    
  800b2e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b30:	5e                   	pop    %esi
  800b31:	5f                   	pop    %edi
  800b32:	c9                   	leave  
  800b33:	c3                   	ret    

00800b34 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b37:	ff 75 10             	pushl  0x10(%ebp)
  800b3a:	ff 75 0c             	pushl  0xc(%ebp)
  800b3d:	ff 75 08             	pushl  0x8(%ebp)
  800b40:	e8 83 ff ff ff       	call   800ac8 <memmove>
}
  800b45:	c9                   	leave  
  800b46:	c3                   	ret    

00800b47 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
  800b4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  800b4e:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b51:	8b 55 10             	mov    0x10(%ebp),%edx
  800b54:	4a                   	dec    %edx
  800b55:	83 fa ff             	cmp    $0xffffffff,%edx
  800b58:	74 1a                	je     800b74 <memcmp+0x2d>
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  800b5a:	8a 01                	mov    (%ecx),%al
  800b5c:	3a 03                	cmp    (%ebx),%al
  800b5e:	74 0c                	je     800b6c <memcmp+0x25>
			return (int) *s1 - (int) *s2;
  800b60:	0f b6 d0             	movzbl %al,%edx
  800b63:	0f b6 03             	movzbl (%ebx),%eax
  800b66:	29 c2                	sub    %eax,%edx
  800b68:	89 d0                	mov    %edx,%eax
  800b6a:	eb 0d                	jmp    800b79 <memcmp+0x32>
		s1++, s2++;
  800b6c:	41                   	inc    %ecx
  800b6d:	43                   	inc    %ebx
  800b6e:	4a                   	dec    %edx
  800b6f:	83 fa ff             	cmp    $0xffffffff,%edx
  800b72:	75 e6                	jne    800b5a <memcmp+0x13>
	}

	return 0;
  800b74:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b79:	5b                   	pop    %ebx
  800b7a:	c9                   	leave  
  800b7b:	c3                   	ret    

00800b7c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b85:	89 c2                	mov    %eax,%edx
  800b87:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b8a:	39 d0                	cmp    %edx,%eax
  800b8c:	73 09                	jae    800b97 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b8e:	38 08                	cmp    %cl,(%eax)
  800b90:	74 05                	je     800b97 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b92:	40                   	inc    %eax
  800b93:	39 d0                	cmp    %edx,%eax
  800b95:	72 f7                	jb     800b8e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b97:	c9                   	leave  
  800b98:	c3                   	ret    

00800b99 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	57                   	push   %edi
  800b9d:	56                   	push   %esi
  800b9e:	53                   	push   %ebx
  800b9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ba5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  800ba8:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  800bad:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  800bb2:	80 3a 20             	cmpb   $0x20,(%edx)
  800bb5:	74 05                	je     800bbc <strtol+0x23>
  800bb7:	80 3a 09             	cmpb   $0x9,(%edx)
  800bba:	75 0b                	jne    800bc7 <strtol+0x2e>
  800bbc:	42                   	inc    %edx
  800bbd:	80 3a 20             	cmpb   $0x20,(%edx)
  800bc0:	74 fa                	je     800bbc <strtol+0x23>
  800bc2:	80 3a 09             	cmpb   $0x9,(%edx)
  800bc5:	74 f5                	je     800bbc <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  800bc7:	80 3a 2b             	cmpb   $0x2b,(%edx)
  800bca:	75 03                	jne    800bcf <strtol+0x36>
		s++;
  800bcc:	42                   	inc    %edx
  800bcd:	eb 0b                	jmp    800bda <strtol+0x41>
	else if (*s == '-')
  800bcf:	80 3a 2d             	cmpb   $0x2d,(%edx)
  800bd2:	75 06                	jne    800bda <strtol+0x41>
		s++, neg = 1;
  800bd4:	42                   	inc    %edx
  800bd5:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bda:	85 c9                	test   %ecx,%ecx
  800bdc:	74 05                	je     800be3 <strtol+0x4a>
  800bde:	83 f9 10             	cmp    $0x10,%ecx
  800be1:	75 15                	jne    800bf8 <strtol+0x5f>
  800be3:	80 3a 30             	cmpb   $0x30,(%edx)
  800be6:	75 10                	jne    800bf8 <strtol+0x5f>
  800be8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bec:	75 0a                	jne    800bf8 <strtol+0x5f>
		s += 2, base = 16;
  800bee:	83 c2 02             	add    $0x2,%edx
  800bf1:	b9 10 00 00 00       	mov    $0x10,%ecx
  800bf6:	eb 14                	jmp    800c0c <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800bf8:	85 c9                	test   %ecx,%ecx
  800bfa:	75 10                	jne    800c0c <strtol+0x73>
  800bfc:	80 3a 30             	cmpb   $0x30,(%edx)
  800bff:	75 05                	jne    800c06 <strtol+0x6d>
		s++, base = 8;
  800c01:	42                   	inc    %edx
  800c02:	b1 08                	mov    $0x8,%cl
  800c04:	eb 06                	jmp    800c0c <strtol+0x73>
	else if (base == 0)
  800c06:	85 c9                	test   %ecx,%ecx
  800c08:	75 02                	jne    800c0c <strtol+0x73>
		base = 10;
  800c0a:	b1 0a                	mov    $0xa,%cl

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c0c:	8a 02                	mov    (%edx),%al
  800c0e:	83 e8 30             	sub    $0x30,%eax
  800c11:	3c 09                	cmp    $0x9,%al
  800c13:	77 08                	ja     800c1d <strtol+0x84>
			dig = *s - '0';
  800c15:	0f be 02             	movsbl (%edx),%eax
  800c18:	83 e8 30             	sub    $0x30,%eax
  800c1b:	eb 20                	jmp    800c3d <strtol+0xa4>
		else if (*s >= 'a' && *s <= 'z')
  800c1d:	8a 02                	mov    (%edx),%al
  800c1f:	83 e8 61             	sub    $0x61,%eax
  800c22:	3c 19                	cmp    $0x19,%al
  800c24:	77 08                	ja     800c2e <strtol+0x95>
			dig = *s - 'a' + 10;
  800c26:	0f be 02             	movsbl (%edx),%eax
  800c29:	83 e8 57             	sub    $0x57,%eax
  800c2c:	eb 0f                	jmp    800c3d <strtol+0xa4>
		else if (*s >= 'A' && *s <= 'Z')
  800c2e:	8a 02                	mov    (%edx),%al
  800c30:	83 e8 41             	sub    $0x41,%eax
  800c33:	3c 19                	cmp    $0x19,%al
  800c35:	77 12                	ja     800c49 <strtol+0xb0>
			dig = *s - 'A' + 10;
  800c37:	0f be 02             	movsbl (%edx),%eax
  800c3a:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  800c3d:	39 c8                	cmp    %ecx,%eax
  800c3f:	7d 08                	jge    800c49 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800c41:	42                   	inc    %edx
  800c42:	0f af d9             	imul   %ecx,%ebx
  800c45:	01 c3                	add    %eax,%ebx
  800c47:	eb c3                	jmp    800c0c <strtol+0x73>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c49:	85 f6                	test   %esi,%esi
  800c4b:	74 02                	je     800c4f <strtol+0xb6>
		*endptr = (char *) s;
  800c4d:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800c4f:	89 d8                	mov    %ebx,%eax
  800c51:	85 ff                	test   %edi,%edi
  800c53:	74 02                	je     800c57 <strtol+0xbe>
  800c55:	f7 d8                	neg    %eax
}
  800c57:	5b                   	pop    %ebx
  800c58:	5e                   	pop    %esi
  800c59:	5f                   	pop    %edi
  800c5a:	c9                   	leave  
  800c5b:	c3                   	ret    

00800c5c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	57                   	push   %edi
  800c60:	56                   	push   %esi
  800c61:	83 ec 14             	sub    $0x14,%esp
  800c64:	8b 55 14             	mov    0x14(%ebp),%edx
  800c67:	8b 75 08             	mov    0x8(%ebp),%esi
  800c6a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c6d:	8b 45 10             	mov    0x10(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800c70:	85 d2                	test   %edx,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800c72:	89 75 f0             	mov    %esi,-0x10(%ebp)
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800c75:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  d1 = dd.s.high;
  800c78:	89 55 f4             	mov    %edx,-0xc(%ebp)
  n0 = nn.s.low;
  n1 = nn.s.high;
  800c7b:	89 fe                	mov    %edi,%esi

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800c7d:	75 11                	jne    800c90 <__udivdi3+0x34>
    {
      if (d0 > n1)
  800c7f:	39 f8                	cmp    %edi,%eax
  800c81:	76 4d                	jbe    800cd0 <__udivdi3+0x74>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800c83:	89 fa                	mov    %edi,%edx
  800c85:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c88:	f7 75 e4             	divl   -0x1c(%ebp)
  800c8b:	89 c7                	mov    %eax,%edi
  800c8d:	eb 09                	jmp    800c98 <__udivdi3+0x3c>
  800c8f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800c90:	39 7d f4             	cmp    %edi,-0xc(%ebp)
  800c93:	76 17                	jbe    800cac <__udivdi3+0x50>
	{
	  /* 00 = nn / DD */

	  q0 = 0;
  800c95:	31 ff                	xor    %edi,%edi
  800c97:	90                   	nop
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
		}

	      q1 = 0;
  800c98:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c9f:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ca2:	83 c4 14             	add    $0x14,%esp
  800ca5:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ca6:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ca8:	5f                   	pop    %edi
  800ca9:	c9                   	leave  
  800caa:	c3                   	ret    
  800cab:	90                   	nop
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800cac:	0f bd 45 f4          	bsr    -0xc(%ebp),%eax
	  if (bm == 0)
  800cb0:	89 c7                	mov    %eax,%edi
  800cb2:	83 f7 1f             	xor    $0x1f,%edi
  800cb5:	75 4d                	jne    800d04 <__udivdi3+0xa8>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800cb7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800cba:	77 0a                	ja     800cc6 <__udivdi3+0x6a>
  800cbc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
		}
	      else
		q0 = 0;
  800cbf:	31 ff                	xor    %edi,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800cc1:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  800cc4:	72 d2                	jb     800c98 <__udivdi3+0x3c>
		{
		  q0 = 1;
  800cc6:	bf 01 00 00 00       	mov    $0x1,%edi
  800ccb:	eb cb                	jmp    800c98 <__udivdi3+0x3c>
  800ccd:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800cd0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800cd3:	85 c0                	test   %eax,%eax
  800cd5:	75 0e                	jne    800ce5 <__udivdi3+0x89>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800cd7:	b8 01 00 00 00       	mov    $0x1,%eax
  800cdc:	31 c9                	xor    %ecx,%ecx
  800cde:	31 d2                	xor    %edx,%edx
  800ce0:	f7 f1                	div    %ecx
  800ce2:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800ce5:	89 f0                	mov    %esi,%eax
  800ce7:	31 d2                	xor    %edx,%edx
  800ce9:	f7 75 e4             	divl   -0x1c(%ebp)
  800cec:	89 45 ec             	mov    %eax,-0x14(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800cef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cf2:	f7 75 e4             	divl   -0x1c(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cf5:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800cf8:	83 c4 14             	add    $0x14,%esp

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800cfb:	89 c7                	mov    %eax,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800cfd:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cfe:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d00:	5f                   	pop    %edi
  800d01:	c9                   	leave  
  800d02:	c3                   	ret    
  800d03:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d04:	b8 20 00 00 00       	mov    $0x20,%eax
  800d09:	29 f8                	sub    %edi,%eax
  800d0b:	89 45 e8             	mov    %eax,-0x18(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  800d0e:	89 f9                	mov    %edi,%ecx
  800d10:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d13:	d3 e2                	shl    %cl,%edx
  800d15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d18:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800d1b:	d3 e8                	shr    %cl,%eax
  800d1d:	09 c2                	or     %eax,%edx
	      d0 = d0 << bm;
  800d1f:	89 f9                	mov    %edi,%ecx
  800d21:	d3 65 e4             	shll   %cl,-0x1c(%ebp)
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d24:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800d27:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800d2a:	89 f2                	mov    %esi,%edx
  800d2c:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  800d2e:	89 f9                	mov    %edi,%ecx
  800d30:	d3 e6                	shl    %cl,%esi
  800d32:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d35:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800d38:	d3 e8                	shr    %cl,%eax
  800d3a:	09 c6                	or     %eax,%esi
	      n0 = n0 << bm;
  800d3c:	89 f9                	mov    %edi,%ecx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d3e:	89 f0                	mov    %esi,%eax
  800d40:	f7 75 f4             	divl   -0xc(%ebp)
  800d43:	89 d6                	mov    %edx,%esi
  800d45:	89 c7                	mov    %eax,%edi

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800d47:	d3 65 f0             	shll   %cl,-0x10(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800d4a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d4d:	f7 e7                	mul    %edi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d4f:	39 f2                	cmp    %esi,%edx
  800d51:	77 0f                	ja     800d62 <__udivdi3+0x106>
  800d53:	0f 85 3f ff ff ff    	jne    800c98 <__udivdi3+0x3c>
  800d59:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800d5c:	0f 86 36 ff ff ff    	jbe    800c98 <__udivdi3+0x3c>
		{
		  q0--;
  800d62:	4f                   	dec    %edi
  800d63:	e9 30 ff ff ff       	jmp    800c98 <__udivdi3+0x3c>

00800d68 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	57                   	push   %edi
  800d6c:	56                   	push   %esi
  800d6d:	83 ec 30             	sub    $0x30,%esp
  800d70:	8b 55 14             	mov    0x14(%ebp),%edx
  800d73:	8b 45 10             	mov    0x10(%ebp),%eax
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  800d76:	89 d7                	mov    %edx,%edi
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  800d78:	8d 4d f0             	lea    -0x10(%ebp),%ecx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800d7b:	89 c6                	mov    %eax,%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;
  800d7d:	8b 55 0c             	mov    0xc(%ebp),%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800d80:	8b 45 08             	mov    0x8(%ebp),%eax
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d83:	85 ff                	test   %edi,%edi
  800d85:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800d8c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  800d93:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800d96:	89 45 dc             	mov    %eax,-0x24(%ebp)
  n1 = nn.s.high;
  800d99:	89 55 cc             	mov    %edx,-0x34(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d9c:	75 3e                	jne    800ddc <__umoddi3+0x74>
    {
      if (d0 > n1)
  800d9e:	39 d6                	cmp    %edx,%esi
  800da0:	0f 86 a2 00 00 00    	jbe    800e48 <__umoddi3+0xe0>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800da6:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  800da8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800dab:	85 c9                	test   %ecx,%ecx

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800dad:	89 55 dc             	mov    %edx,-0x24(%ebp)

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  800db0:	74 1b                	je     800dcd <__umoddi3+0x65>
	{
	  rr.s.low = n0;
  800db2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800db5:	89 45 e0             	mov    %eax,-0x20(%ebp)
	  rr.s.high = 0;
  800db8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800dbf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800dc2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800dc5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800dc8:	89 10                	mov    %edx,(%eax)
  800dca:	89 48 04             	mov    %ecx,0x4(%eax)
  800dcd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dd0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800dd3:	83 c4 30             	add    $0x30,%esp
  800dd6:	5e                   	pop    %esi
  800dd7:	5f                   	pop    %edi
  800dd8:	c9                   	leave  
  800dd9:	c3                   	ret    
  800dda:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ddc:	3b 7d cc             	cmp    -0x34(%ebp),%edi
  800ddf:	76 1f                	jbe    800e00 <__umoddi3+0x98>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800de1:	8b 55 08             	mov    0x8(%ebp),%edx
	      rr.s.high = n1;
  800de4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800de7:	89 55 e0             	mov    %edx,-0x20(%ebp)
	      rr.s.high = n1;
  800dea:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	      *rp = rr.ll;
  800ded:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800df0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800df3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800df6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800df9:	83 c4 30             	add    $0x30,%esp
  800dfc:	5e                   	pop    %esi
  800dfd:	5f                   	pop    %edi
  800dfe:	c9                   	leave  
  800dff:	c3                   	ret    
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e00:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800e03:	83 f0 1f             	xor    $0x1f,%eax
  800e06:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800e09:	75 61                	jne    800e6c <__umoddi3+0x104>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e0b:	39 7d cc             	cmp    %edi,-0x34(%ebp)
  800e0e:	77 05                	ja     800e15 <__umoddi3+0xad>
  800e10:	39 75 dc             	cmp    %esi,-0x24(%ebp)
  800e13:	72 10                	jb     800e25 <__umoddi3+0xbd>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e15:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800e18:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800e1b:	29 f0                	sub    %esi,%eax
  800e1d:	19 fa                	sbb    %edi,%edx
  800e1f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800e22:	89 55 cc             	mov    %edx,-0x34(%ebp)
	      else
		q0 = 0;

	      q1 = 0;

	      if (rp != 0)
  800e25:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800e28:	85 d2                	test   %edx,%edx
  800e2a:	74 a1                	je     800dcd <__umoddi3+0x65>
		{
		  rr.s.low = n0;
  800e2c:	8b 45 dc             	mov    -0x24(%ebp),%eax
		  rr.s.high = n1;
  800e2f:	8b 55 cc             	mov    -0x34(%ebp),%edx

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  800e32:	89 45 e0             	mov    %eax,-0x20(%ebp)
		  rr.s.high = n1;
  800e35:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		  *rp = rr.ll;
  800e38:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800e3b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e3e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800e41:	89 01                	mov    %eax,(%ecx)
  800e43:	89 51 04             	mov    %edx,0x4(%ecx)
  800e46:	eb 85                	jmp    800dcd <__umoddi3+0x65>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e48:	85 f6                	test   %esi,%esi
  800e4a:	75 0b                	jne    800e57 <__umoddi3+0xef>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e4c:	b8 01 00 00 00       	mov    $0x1,%eax
  800e51:	31 d2                	xor    %edx,%edx
  800e53:	f7 f6                	div    %esi
  800e55:	89 c6                	mov    %eax,%esi

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e57:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800e5a:	89 fa                	mov    %edi,%edx
  800e5c:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e5e:	8b 45 dc             	mov    -0x24(%ebp),%eax
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e61:	89 55 cc             	mov    %edx,-0x34(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e64:	f7 f6                	div    %esi
  800e66:	e9 3d ff ff ff       	jmp    800da8 <__umoddi3+0x40>
  800e6b:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e6c:	b8 20 00 00 00       	mov    $0x20,%eax
  800e71:	2b 45 d4             	sub    -0x2c(%ebp),%eax
  800e74:	89 45 d8             	mov    %eax,-0x28(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  800e77:	89 fa                	mov    %edi,%edx
  800e79:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800e7c:	d3 e2                	shl    %cl,%edx
  800e7e:	89 f0                	mov    %esi,%eax
  800e80:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800e83:	d3 e8                	shr    %cl,%eax
	      d0 = d0 << bm;
  800e85:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800e88:	d3 e6                	shl    %cl,%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e8a:	89 d7                	mov    %edx,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800e8c:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800e8f:	8b 55 cc             	mov    -0x34(%ebp),%edx
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e92:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800e94:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  800e96:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800e99:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800e9c:	d3 e0                	shl    %cl,%eax
  800e9e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800ea1:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800ea4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800ea7:	d3 e8                	shr    %cl,%eax
  800ea9:	0b 45 cc             	or     -0x34(%ebp),%eax
  800eac:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n0 = n0 << bm;
  800eaf:	8a 4d d4             	mov    -0x2c(%ebp),%cl

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800eb2:	f7 f7                	div    %edi
  800eb4:	89 55 cc             	mov    %edx,-0x34(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800eb7:	d3 65 dc             	shll   %cl,-0x24(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800eba:	f7 e6                	mul    %esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ebc:	3b 55 cc             	cmp    -0x34(%ebp),%edx
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800ebf:	89 45 c8             	mov    %eax,-0x38(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ec2:	77 0a                	ja     800ece <__umoddi3+0x166>
  800ec4:	75 12                	jne    800ed8 <__umoddi3+0x170>
  800ec6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800ec9:	39 45 c8             	cmp    %eax,-0x38(%ebp)
  800ecc:	76 0a                	jbe    800ed8 <__umoddi3+0x170>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800ece:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800ed1:	29 f1                	sub    %esi,%ecx
  800ed3:	19 fa                	sbb    %edi,%edx
  800ed5:	89 4d c8             	mov    %ecx,-0x38(%ebp)
		}

	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
  800ed8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800edb:	85 c0                	test   %eax,%eax
  800edd:	0f 84 ea fe ff ff    	je     800dcd <__umoddi3+0x65>
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800ee3:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800ee6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800ee9:	2b 45 c8             	sub    -0x38(%ebp),%eax
  800eec:	19 d1                	sbb    %edx,%ecx
  800eee:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800ef1:	89 ca                	mov    %ecx,%edx
  800ef3:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800ef6:	d3 e2                	shl    %cl,%edx
  800ef8:	8a 4d d4             	mov    -0x2c(%ebp),%cl
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800efb:	89 45 dc             	mov    %eax,-0x24(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800efe:	d3 e8                	shr    %cl,%eax
  800f00:	09 c2                	or     %eax,%edx
		  rr.s.high = n1 >> bm;
  800f02:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800f05:	d3 e8                	shr    %cl,%eax

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f07:	89 55 e0             	mov    %edx,-0x20(%ebp)
		  rr.s.high = n1 >> bm;
  800f0a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f0d:	e9 ad fe ff ff       	jmp    800dbf <__umoddi3+0x57>
