
obj/user/faultevilhandler.debug:     file format elf32-i386


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
  80002c:	e8 33 00 00 00       	call   800064 <libmain>
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
  800037:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  80003a:	6a 07                	push   $0x7
  80003c:	68 00 f0 bf ee       	push   $0xeebff000
  800041:	6a 00                	push   $0x0
  800043:	e8 3a 01 00 00       	call   800182 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800048:	83 c4 08             	add    $0x8,%esp
  80004b:	68 20 00 10 f0       	push   $0xf0100020
  800050:	6a 00                	push   $0x0
  800052:	e8 76 02 00 00       	call   8002cd <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800057:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80005e:	00 00 00 
}
  800061:	c9                   	leave  
  800062:	c3                   	ret    
	...

00800064 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800064:	55                   	push   %ebp
  800065:	89 e5                	mov    %esp,%ebp
  800067:	56                   	push   %esi
  800068:	53                   	push   %ebx
  800069:	8b 75 08             	mov    0x8(%ebp),%esi
  80006c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];	
  80006f:	e8 d0 00 00 00       	call   800144 <sys_getenvid>
  800074:	25 ff 03 00 00       	and    $0x3ff,%eax
  800079:	89 c2                	mov    %eax,%edx
  80007b:	c1 e2 05             	shl    $0x5,%edx
  80007e:	29 c2                	sub    %eax,%edx
  800080:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  800087:	89 15 04 20 80 00    	mov    %edx,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008d:	85 f6                	test   %esi,%esi
  80008f:	7e 07                	jle    800098 <libmain+0x34>
		binaryname = argv[0];
  800091:	8b 03                	mov    (%ebx),%eax
  800093:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800098:	83 ec 08             	sub    $0x8,%esp
  80009b:	53                   	push   %ebx
  80009c:	56                   	push   %esi
  80009d:	e8 92 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a2:	e8 09 00 00 00       	call   8000b0 <exit>
}
  8000a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000aa:	5b                   	pop    %ebx
  8000ab:	5e                   	pop    %esi
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    
	...

008000b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  8000b6:	6a 00                	push   $0x0
  8000b8:	e8 46 00 00 00       	call   800103 <sys_env_destroy>
}
  8000bd:	c9                   	leave  
  8000be:	c3                   	ret    
	...

008000c0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
  8000c6:	83 ec 04             	sub    $0x4,%esp
  8000c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000cf:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d4:	89 f8                	mov    %edi,%eax
  8000d6:	89 fb                	mov    %edi,%ebx
  8000d8:	89 fe                	mov    %edi,%esi
  8000da:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000dc:	83 c4 04             	add    $0x4,%esp
  8000df:	5b                   	pop    %ebx
  8000e0:	5e                   	pop    %esi
  8000e1:	5f                   	pop    %edi
  8000e2:	c9                   	leave  
  8000e3:	c3                   	ret    

008000e4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	57                   	push   %edi
  8000e8:	56                   	push   %esi
  8000e9:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000ea:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ef:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f4:	89 fa                	mov    %edi,%edx
  8000f6:	89 f9                	mov    %edi,%ecx
  8000f8:	89 fb                	mov    %edi,%ebx
  8000fa:	89 fe                	mov    %edi,%esi
  8000fc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fe:	5b                   	pop    %ebx
  8000ff:	5e                   	pop    %esi
  800100:	5f                   	pop    %edi
  800101:	c9                   	leave  
  800102:	c3                   	ret    

00800103 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800103:	55                   	push   %ebp
  800104:	89 e5                	mov    %esp,%ebp
  800106:	57                   	push   %edi
  800107:	56                   	push   %esi
  800108:	53                   	push   %ebx
  800109:	83 ec 0c             	sub    $0xc,%esp
  80010c:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80010f:	b8 03 00 00 00       	mov    $0x3,%eax
  800114:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800119:	89 f9                	mov    %edi,%ecx
  80011b:	89 fb                	mov    %edi,%ebx
  80011d:	89 fe                	mov    %edi,%esi
  80011f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800121:	85 c0                	test   %eax,%eax
  800123:	7e 17                	jle    80013c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800125:	83 ec 0c             	sub    $0xc,%esp
  800128:	50                   	push   %eax
  800129:	6a 03                	push   $0x3
  80012b:	68 4a 0f 80 00       	push   $0x800f4a
  800130:	6a 23                	push   $0x23
  800132:	68 67 0f 80 00       	push   $0x800f67
  800137:	e8 38 02 00 00       	call   800374 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80013c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80013f:	5b                   	pop    %ebx
  800140:	5e                   	pop    %esi
  800141:	5f                   	pop    %edi
  800142:	c9                   	leave  
  800143:	c3                   	ret    

00800144 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	57                   	push   %edi
  800148:	56                   	push   %esi
  800149:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80014a:	b8 02 00 00 00       	mov    $0x2,%eax
  80014f:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800154:	89 fa                	mov    %edi,%edx
  800156:	89 f9                	mov    %edi,%ecx
  800158:	89 fb                	mov    %edi,%ebx
  80015a:	89 fe                	mov    %edi,%esi
  80015c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015e:	5b                   	pop    %ebx
  80015f:	5e                   	pop    %esi
  800160:	5f                   	pop    %edi
  800161:	c9                   	leave  
  800162:	c3                   	ret    

00800163 <sys_yield>:

void
sys_yield(void)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	57                   	push   %edi
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800169:	b8 0b 00 00 00       	mov    $0xb,%eax
  80016e:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800173:	89 fa                	mov    %edi,%edx
  800175:	89 f9                	mov    %edi,%ecx
  800177:	89 fb                	mov    %edi,%ebx
  800179:	89 fe                	mov    %edi,%esi
  80017b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80017d:	5b                   	pop    %ebx
  80017e:	5e                   	pop    %esi
  80017f:	5f                   	pop    %edi
  800180:	c9                   	leave  
  800181:	c3                   	ret    

00800182 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800182:	55                   	push   %ebp
  800183:	89 e5                	mov    %esp,%ebp
  800185:	57                   	push   %edi
  800186:	56                   	push   %esi
  800187:	53                   	push   %ebx
  800188:	83 ec 0c             	sub    $0xc,%esp
  80018b:	8b 55 08             	mov    0x8(%ebp),%edx
  80018e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800191:	8b 5d 10             	mov    0x10(%ebp),%ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800194:	b8 04 00 00 00       	mov    $0x4,%eax
  800199:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80019e:	89 fe                	mov    %edi,%esi
  8001a0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001a2:	85 c0                	test   %eax,%eax
  8001a4:	7e 17                	jle    8001bd <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a6:	83 ec 0c             	sub    $0xc,%esp
  8001a9:	50                   	push   %eax
  8001aa:	6a 04                	push   $0x4
  8001ac:	68 4a 0f 80 00       	push   $0x800f4a
  8001b1:	6a 23                	push   $0x23
  8001b3:	68 67 0f 80 00       	push   $0x800f67
  8001b8:	e8 b7 01 00 00       	call   800374 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c0:	5b                   	pop    %ebx
  8001c1:	5e                   	pop    %esi
  8001c2:	5f                   	pop    %edi
  8001c3:	c9                   	leave  
  8001c4:	c3                   	ret    

008001c5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c5:	55                   	push   %ebp
  8001c6:	89 e5                	mov    %esp,%ebp
  8001c8:	57                   	push   %edi
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	83 ec 0c             	sub    $0xc,%esp
  8001ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001da:	8b 75 18             	mov    0x18(%ebp),%esi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8001dd:	b8 05 00 00 00       	mov    $0x5,%eax
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001e4:	85 c0                	test   %eax,%eax
  8001e6:	7e 17                	jle    8001ff <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e8:	83 ec 0c             	sub    $0xc,%esp
  8001eb:	50                   	push   %eax
  8001ec:	6a 05                	push   $0x5
  8001ee:	68 4a 0f 80 00       	push   $0x800f4a
  8001f3:	6a 23                	push   $0x23
  8001f5:	68 67 0f 80 00       	push   $0x800f67
  8001fa:	e8 75 01 00 00       	call   800374 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800202:	5b                   	pop    %ebx
  800203:	5e                   	pop    %esi
  800204:	5f                   	pop    %edi
  800205:	c9                   	leave  
  800206:	c3                   	ret    

00800207 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800207:	55                   	push   %ebp
  800208:	89 e5                	mov    %esp,%ebp
  80020a:	57                   	push   %edi
  80020b:	56                   	push   %esi
  80020c:	53                   	push   %ebx
  80020d:	83 ec 0c             	sub    $0xc,%esp
  800210:	8b 55 08             	mov    0x8(%ebp),%edx
  800213:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800216:	b8 06 00 00 00       	mov    $0x6,%eax
  80021b:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800220:	89 fb                	mov    %edi,%ebx
  800222:	89 fe                	mov    %edi,%esi
  800224:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800226:	85 c0                	test   %eax,%eax
  800228:	7e 17                	jle    800241 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80022a:	83 ec 0c             	sub    $0xc,%esp
  80022d:	50                   	push   %eax
  80022e:	6a 06                	push   $0x6
  800230:	68 4a 0f 80 00       	push   $0x800f4a
  800235:	6a 23                	push   $0x23
  800237:	68 67 0f 80 00       	push   $0x800f67
  80023c:	e8 33 01 00 00       	call   800374 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800241:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800244:	5b                   	pop    %ebx
  800245:	5e                   	pop    %esi
  800246:	5f                   	pop    %edi
  800247:	c9                   	leave  
  800248:	c3                   	ret    

00800249 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800249:	55                   	push   %ebp
  80024a:	89 e5                	mov    %esp,%ebp
  80024c:	57                   	push   %edi
  80024d:	56                   	push   %esi
  80024e:	53                   	push   %ebx
  80024f:	83 ec 0c             	sub    $0xc,%esp
  800252:	8b 55 08             	mov    0x8(%ebp),%edx
  800255:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800258:	b8 08 00 00 00       	mov    $0x8,%eax
  80025d:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800262:	89 fb                	mov    %edi,%ebx
  800264:	89 fe                	mov    %edi,%esi
  800266:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800268:	85 c0                	test   %eax,%eax
  80026a:	7e 17                	jle    800283 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80026c:	83 ec 0c             	sub    $0xc,%esp
  80026f:	50                   	push   %eax
  800270:	6a 08                	push   $0x8
  800272:	68 4a 0f 80 00       	push   $0x800f4a
  800277:	6a 23                	push   $0x23
  800279:	68 67 0f 80 00       	push   $0x800f67
  80027e:	e8 f1 00 00 00       	call   800374 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800283:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800286:	5b                   	pop    %ebx
  800287:	5e                   	pop    %esi
  800288:	5f                   	pop    %edi
  800289:	c9                   	leave  
  80028a:	c3                   	ret    

0080028b <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80028b:	55                   	push   %ebp
  80028c:	89 e5                	mov    %esp,%ebp
  80028e:	57                   	push   %edi
  80028f:	56                   	push   %esi
  800290:	53                   	push   %ebx
  800291:	83 ec 0c             	sub    $0xc,%esp
  800294:	8b 55 08             	mov    0x8(%ebp),%edx
  800297:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80029a:	b8 09 00 00 00       	mov    $0x9,%eax
  80029f:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a4:	89 fb                	mov    %edi,%ebx
  8002a6:	89 fe                	mov    %edi,%esi
  8002a8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002aa:	85 c0                	test   %eax,%eax
  8002ac:	7e 17                	jle    8002c5 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ae:	83 ec 0c             	sub    $0xc,%esp
  8002b1:	50                   	push   %eax
  8002b2:	6a 09                	push   $0x9
  8002b4:	68 4a 0f 80 00       	push   $0x800f4a
  8002b9:	6a 23                	push   $0x23
  8002bb:	68 67 0f 80 00       	push   $0x800f67
  8002c0:	e8 af 00 00 00       	call   800374 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c8:	5b                   	pop    %ebx
  8002c9:	5e                   	pop    %esi
  8002ca:	5f                   	pop    %edi
  8002cb:	c9                   	leave  
  8002cc:	c3                   	ret    

008002cd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002cd:	55                   	push   %ebp
  8002ce:	89 e5                	mov    %esp,%ebp
  8002d0:	57                   	push   %edi
  8002d1:	56                   	push   %esi
  8002d2:	53                   	push   %ebx
  8002d3:	83 ec 0c             	sub    $0xc,%esp
  8002d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8002dc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002e1:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e6:	89 fb                	mov    %edi,%ebx
  8002e8:	89 fe                	mov    %edi,%esi
  8002ea:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002ec:	85 c0                	test   %eax,%eax
  8002ee:	7e 17                	jle    800307 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f0:	83 ec 0c             	sub    $0xc,%esp
  8002f3:	50                   	push   %eax
  8002f4:	6a 0a                	push   $0xa
  8002f6:	68 4a 0f 80 00       	push   $0x800f4a
  8002fb:	6a 23                	push   $0x23
  8002fd:	68 67 0f 80 00       	push   $0x800f67
  800302:	e8 6d 00 00 00       	call   800374 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800307:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80030a:	5b                   	pop    %ebx
  80030b:	5e                   	pop    %esi
  80030c:	5f                   	pop    %edi
  80030d:	c9                   	leave  
  80030e:	c3                   	ret    

0080030f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	57                   	push   %edi
  800313:	56                   	push   %esi
  800314:	53                   	push   %ebx
  800315:	8b 55 08             	mov    0x8(%ebp),%edx
  800318:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80031b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80031e:	8b 7d 14             	mov    0x14(%ebp),%edi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800321:	b8 0c 00 00 00       	mov    $0xc,%eax
  800326:	be 00 00 00 00       	mov    $0x0,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80032b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80032d:	5b                   	pop    %ebx
  80032e:	5e                   	pop    %esi
  80032f:	5f                   	pop    %edi
  800330:	c9                   	leave  
  800331:	c3                   	ret    

00800332 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800332:	55                   	push   %ebp
  800333:	89 e5                	mov    %esp,%ebp
  800335:	57                   	push   %edi
  800336:	56                   	push   %esi
  800337:	53                   	push   %ebx
  800338:	83 ec 0c             	sub    $0xc,%esp
  80033b:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80033e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800343:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800348:	89 f9                	mov    %edi,%ecx
  80034a:	89 fb                	mov    %edi,%ebx
  80034c:	89 fe                	mov    %edi,%esi
  80034e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800350:	85 c0                	test   %eax,%eax
  800352:	7e 17                	jle    80036b <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800354:	83 ec 0c             	sub    $0xc,%esp
  800357:	50                   	push   %eax
  800358:	6a 0d                	push   $0xd
  80035a:	68 4a 0f 80 00       	push   $0x800f4a
  80035f:	6a 23                	push   $0x23
  800361:	68 67 0f 80 00       	push   $0x800f67
  800366:	e8 09 00 00 00       	call   800374 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80036b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80036e:	5b                   	pop    %ebx
  80036f:	5e                   	pop    %esi
  800370:	5f                   	pop    %edi
  800371:	c9                   	leave  
  800372:	c3                   	ret    
	...

00800374 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800374:	55                   	push   %ebp
  800375:	89 e5                	mov    %esp,%ebp
  800377:	53                   	push   %ebx
  800378:	83 ec 10             	sub    $0x10,%esp
	va_list ap;

	va_start(ap, fmt);
  80037b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80037e:	ff 75 0c             	pushl  0xc(%ebp)
  800381:	ff 75 08             	pushl  0x8(%ebp)
  800384:	ff 35 00 20 80 00    	pushl  0x802000
  80038a:	83 ec 08             	sub    $0x8,%esp
  80038d:	e8 b2 fd ff ff       	call   800144 <sys_getenvid>
  800392:	83 c4 08             	add    $0x8,%esp
  800395:	50                   	push   %eax
  800396:	68 78 0f 80 00       	push   $0x800f78
  80039b:	e8 b0 00 00 00       	call   800450 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003a0:	83 c4 18             	add    $0x18,%esp
  8003a3:	53                   	push   %ebx
  8003a4:	ff 75 10             	pushl  0x10(%ebp)
  8003a7:	e8 53 00 00 00       	call   8003ff <vcprintf>
	cprintf("\n");
  8003ac:	c7 04 24 9b 0f 80 00 	movl   $0x800f9b,(%esp)
  8003b3:	e8 98 00 00 00       	call   800450 <cprintf>

	// Cause a breakpoint exception
	while (1)
  8003b8:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  8003bb:	cc                   	int3   
  8003bc:	eb fd                	jmp    8003bb <_panic+0x47>
	...

008003c0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003c0:	55                   	push   %ebp
  8003c1:	89 e5                	mov    %esp,%ebp
  8003c3:	53                   	push   %ebx
  8003c4:	83 ec 04             	sub    $0x4,%esp
  8003c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003ca:	8b 03                	mov    (%ebx),%eax
  8003cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8003cf:	88 54 18 08          	mov    %dl,0x8(%eax,%ebx,1)
  8003d3:	40                   	inc    %eax
  8003d4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8003d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003db:	75 1a                	jne    8003f7 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8003dd:	83 ec 08             	sub    $0x8,%esp
  8003e0:	68 ff 00 00 00       	push   $0xff
  8003e5:	8d 43 08             	lea    0x8(%ebx),%eax
  8003e8:	50                   	push   %eax
  8003e9:	e8 d2 fc ff ff       	call   8000c0 <sys_cputs>
		b->idx = 0;
  8003ee:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003f4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003f7:	ff 43 04             	incl   0x4(%ebx)
}
  8003fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003fd:	c9                   	leave  
  8003fe:	c3                   	ret    

008003ff <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800408:	c7 85 e8 fe ff ff 00 	movl   $0x0,-0x118(%ebp)
  80040f:	00 00 00 
	b.cnt = 0;
  800412:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  800419:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80041c:	ff 75 0c             	pushl  0xc(%ebp)
  80041f:	ff 75 08             	pushl  0x8(%ebp)
  800422:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800428:	50                   	push   %eax
  800429:	68 c0 03 80 00       	push   $0x8003c0
  80042e:	e8 49 01 00 00       	call   80057c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800433:	83 c4 08             	add    $0x8,%esp
  800436:	ff b5 e8 fe ff ff    	pushl  -0x118(%ebp)
  80043c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800442:	50                   	push   %eax
  800443:	e8 78 fc ff ff       	call   8000c0 <sys_cputs>

	return b.cnt;
  800448:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
}
  80044e:	c9                   	leave  
  80044f:	c3                   	ret    

00800450 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800450:	55                   	push   %ebp
  800451:	89 e5                	mov    %esp,%ebp
  800453:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800456:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800459:	50                   	push   %eax
  80045a:	ff 75 08             	pushl  0x8(%ebp)
  80045d:	e8 9d ff ff ff       	call   8003ff <vcprintf>
	va_end(ap);

	return cnt;
}
  800462:	c9                   	leave  
  800463:	c3                   	ret    

00800464 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800464:	55                   	push   %ebp
  800465:	89 e5                	mov    %esp,%ebp
  800467:	57                   	push   %edi
  800468:	56                   	push   %esi
  800469:	53                   	push   %ebx
  80046a:	83 ec 0c             	sub    $0xc,%esp
  80046d:	8b 75 10             	mov    0x10(%ebp),%esi
  800470:	8b 7d 14             	mov    0x14(%ebp),%edi
  800473:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800476:	8b 45 18             	mov    0x18(%ebp),%eax
  800479:	ba 00 00 00 00       	mov    $0x0,%edx
  80047e:	39 fa                	cmp    %edi,%edx
  800480:	77 39                	ja     8004bb <printnum+0x57>
  800482:	72 04                	jb     800488 <printnum+0x24>
  800484:	39 f0                	cmp    %esi,%eax
  800486:	77 33                	ja     8004bb <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800488:	83 ec 04             	sub    $0x4,%esp
  80048b:	ff 75 20             	pushl  0x20(%ebp)
  80048e:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800491:	50                   	push   %eax
  800492:	ff 75 18             	pushl  0x18(%ebp)
  800495:	8b 45 18             	mov    0x18(%ebp),%eax
  800498:	ba 00 00 00 00       	mov    $0x0,%edx
  80049d:	52                   	push   %edx
  80049e:	50                   	push   %eax
  80049f:	57                   	push   %edi
  8004a0:	56                   	push   %esi
  8004a1:	e8 de 07 00 00       	call   800c84 <__udivdi3>
  8004a6:	83 c4 10             	add    $0x10,%esp
  8004a9:	52                   	push   %edx
  8004aa:	50                   	push   %eax
  8004ab:	ff 75 0c             	pushl  0xc(%ebp)
  8004ae:	ff 75 08             	pushl  0x8(%ebp)
  8004b1:	e8 ae ff ff ff       	call   800464 <printnum>
  8004b6:	83 c4 20             	add    $0x20,%esp
  8004b9:	eb 19                	jmp    8004d4 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004bb:	4b                   	dec    %ebx
  8004bc:	85 db                	test   %ebx,%ebx
  8004be:	7e 14                	jle    8004d4 <printnum+0x70>
  8004c0:	83 ec 08             	sub    $0x8,%esp
  8004c3:	ff 75 0c             	pushl  0xc(%ebp)
  8004c6:	ff 75 20             	pushl  0x20(%ebp)
  8004c9:	ff 55 08             	call   *0x8(%ebp)
  8004cc:	83 c4 10             	add    $0x10,%esp
  8004cf:	4b                   	dec    %ebx
  8004d0:	85 db                	test   %ebx,%ebx
  8004d2:	7f ec                	jg     8004c0 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004d4:	83 ec 08             	sub    $0x8,%esp
  8004d7:	ff 75 0c             	pushl  0xc(%ebp)
  8004da:	8b 45 18             	mov    0x18(%ebp),%eax
  8004dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e2:	83 ec 04             	sub    $0x4,%esp
  8004e5:	52                   	push   %edx
  8004e6:	50                   	push   %eax
  8004e7:	57                   	push   %edi
  8004e8:	56                   	push   %esi
  8004e9:	e8 a2 08 00 00       	call   800d90 <__umoddi3>
  8004ee:	83 c4 14             	add    $0x14,%esp
  8004f1:	0f be 80 af 10 80 00 	movsbl 0x8010af(%eax),%eax
  8004f8:	50                   	push   %eax
  8004f9:	ff 55 08             	call   *0x8(%ebp)
}
  8004fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004ff:	5b                   	pop    %ebx
  800500:	5e                   	pop    %esi
  800501:	5f                   	pop    %edi
  800502:	c9                   	leave  
  800503:	c3                   	ret    

00800504 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800504:	55                   	push   %ebp
  800505:	89 e5                	mov    %esp,%ebp
  800507:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80050a:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  80050d:	83 f8 01             	cmp    $0x1,%eax
  800510:	7e 0e                	jle    800520 <getuint+0x1c>
		return va_arg(*ap, unsigned long long);
  800512:	8b 11                	mov    (%ecx),%edx
  800514:	8d 42 08             	lea    0x8(%edx),%eax
  800517:	89 01                	mov    %eax,(%ecx)
  800519:	8b 02                	mov    (%edx),%eax
  80051b:	8b 52 04             	mov    0x4(%edx),%edx
  80051e:	eb 22                	jmp    800542 <getuint+0x3e>
	else if (lflag)
  800520:	85 c0                	test   %eax,%eax
  800522:	74 10                	je     800534 <getuint+0x30>
		return va_arg(*ap, unsigned long);
  800524:	8b 11                	mov    (%ecx),%edx
  800526:	8d 42 04             	lea    0x4(%edx),%eax
  800529:	89 01                	mov    %eax,(%ecx)
  80052b:	8b 02                	mov    (%edx),%eax
  80052d:	ba 00 00 00 00       	mov    $0x0,%edx
  800532:	eb 0e                	jmp    800542 <getuint+0x3e>
	else
		return va_arg(*ap, unsigned int);
  800534:	8b 11                	mov    (%ecx),%edx
  800536:	8d 42 04             	lea    0x4(%edx),%eax
  800539:	89 01                	mov    %eax,(%ecx)
  80053b:	8b 02                	mov    (%edx),%eax
  80053d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800542:	c9                   	leave  
  800543:	c3                   	ret    

00800544 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800544:	55                   	push   %ebp
  800545:	89 e5                	mov    %esp,%ebp
  800547:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80054a:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  80054d:	83 f8 01             	cmp    $0x1,%eax
  800550:	7e 0e                	jle    800560 <getint+0x1c>
		return va_arg(*ap, long long);
  800552:	8b 11                	mov    (%ecx),%edx
  800554:	8d 42 08             	lea    0x8(%edx),%eax
  800557:	89 01                	mov    %eax,(%ecx)
  800559:	8b 02                	mov    (%edx),%eax
  80055b:	8b 52 04             	mov    0x4(%edx),%edx
  80055e:	eb 1a                	jmp    80057a <getint+0x36>
	else if (lflag)
  800560:	85 c0                	test   %eax,%eax
  800562:	74 0c                	je     800570 <getint+0x2c>
		return va_arg(*ap, long);
  800564:	8b 01                	mov    (%ecx),%eax
  800566:	8d 50 04             	lea    0x4(%eax),%edx
  800569:	89 11                	mov    %edx,(%ecx)
  80056b:	8b 00                	mov    (%eax),%eax
  80056d:	99                   	cltd   
  80056e:	eb 0a                	jmp    80057a <getint+0x36>
	else
		return va_arg(*ap, int);
  800570:	8b 01                	mov    (%ecx),%eax
  800572:	8d 50 04             	lea    0x4(%eax),%edx
  800575:	89 11                	mov    %edx,(%ecx)
  800577:	8b 00                	mov    (%eax),%eax
  800579:	99                   	cltd   
}
  80057a:	c9                   	leave  
  80057b:	c3                   	ret    

0080057c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80057c:	55                   	push   %ebp
  80057d:	89 e5                	mov    %esp,%ebp
  80057f:	57                   	push   %edi
  800580:	56                   	push   %esi
  800581:	53                   	push   %ebx
  800582:	83 ec 1c             	sub    $0x1c,%esp
  800585:	8b 5d 10             	mov    0x10(%ebp),%ebx

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
			putch(ch, putdat);
  800588:	0f b6 0b             	movzbl (%ebx),%ecx
  80058b:	43                   	inc    %ebx
  80058c:	83 f9 25             	cmp    $0x25,%ecx
  80058f:	74 1e                	je     8005af <vprintfmt+0x33>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800591:	85 c9                	test   %ecx,%ecx
  800593:	0f 84 dc 02 00 00    	je     800875 <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  800599:	83 ec 08             	sub    $0x8,%esp
  80059c:	ff 75 0c             	pushl  0xc(%ebp)
  80059f:	51                   	push   %ecx
  8005a0:	ff 55 08             	call   *0x8(%ebp)
  8005a3:	83 c4 10             	add    $0x10,%esp
  8005a6:	0f b6 0b             	movzbl (%ebx),%ecx
  8005a9:	43                   	inc    %ebx
  8005aa:	83 f9 25             	cmp    $0x25,%ecx
  8005ad:	75 e2                	jne    800591 <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  8005af:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
		width = -1;
  8005b3:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
		precision = -1;
  8005ba:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  8005bf:	bf 00 00 00 00       	mov    $0x0,%edi
		altflag = 0;
  8005c4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cb:	0f b6 0b             	movzbl (%ebx),%ecx
  8005ce:	8d 41 dd             	lea    -0x23(%ecx),%eax
  8005d1:	43                   	inc    %ebx
  8005d2:	83 f8 55             	cmp    $0x55,%eax
  8005d5:	0f 87 75 02 00 00    	ja     800850 <vprintfmt+0x2d4>
  8005db:	ff 24 85 40 11 80 00 	jmp    *0x801140(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  8005e2:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
			goto reswitch;
  8005e6:	eb e3                	jmp    8005cb <vprintfmt+0x4f>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005e8:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
			goto reswitch;
  8005ec:	eb dd                	jmp    8005cb <vprintfmt+0x4f>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005ee:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  8005f3:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  8005f6:	8d 74 41 d0          	lea    -0x30(%ecx,%eax,2),%esi
				ch = *fmt;
  8005fa:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  8005fd:	8d 41 d0             	lea    -0x30(%ecx),%eax
  800600:	83 f8 09             	cmp    $0x9,%eax
  800603:	77 28                	ja     80062d <vprintfmt+0xb1>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800605:	43                   	inc    %ebx
  800606:	eb eb                	jmp    8005f3 <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800608:	8b 55 14             	mov    0x14(%ebp),%edx
  80060b:	8d 42 04             	lea    0x4(%edx),%eax
  80060e:	89 45 14             	mov    %eax,0x14(%ebp)
  800611:	8b 32                	mov    (%edx),%esi
			goto process_precision;
  800613:	eb 18                	jmp    80062d <vprintfmt+0xb1>

		case '.':
			if (width < 0)
  800615:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800619:	79 b0                	jns    8005cb <vprintfmt+0x4f>
				width = 0;
  80061b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
			goto reswitch;
  800622:	eb a7                	jmp    8005cb <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  800624:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
			goto reswitch;
  80062b:	eb 9e                	jmp    8005cb <vprintfmt+0x4f>

		process_precision:
			if (width < 0)
  80062d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800631:	79 98                	jns    8005cb <vprintfmt+0x4f>
				width = precision, precision = -1;
  800633:	89 75 f0             	mov    %esi,-0x10(%ebp)
  800636:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  80063b:	eb 8e                	jmp    8005cb <vprintfmt+0x4f>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80063d:	47                   	inc    %edi
			goto reswitch;
  80063e:	eb 8b                	jmp    8005cb <vprintfmt+0x4f>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800640:	83 ec 08             	sub    $0x8,%esp
  800643:	ff 75 0c             	pushl  0xc(%ebp)
  800646:	8b 55 14             	mov    0x14(%ebp),%edx
  800649:	8d 42 04             	lea    0x4(%edx),%eax
  80064c:	89 45 14             	mov    %eax,0x14(%ebp)
  80064f:	ff 32                	pushl  (%edx)
  800651:	ff 55 08             	call   *0x8(%ebp)
			break;
  800654:	83 c4 10             	add    $0x10,%esp
  800657:	e9 2c ff ff ff       	jmp    800588 <vprintfmt+0xc>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80065c:	8b 55 14             	mov    0x14(%ebp),%edx
  80065f:	8d 42 04             	lea    0x4(%edx),%eax
  800662:	89 45 14             	mov    %eax,0x14(%ebp)
  800665:	8b 02                	mov    (%edx),%eax
			if (err < 0)
  800667:	85 c0                	test   %eax,%eax
  800669:	79 02                	jns    80066d <vprintfmt+0xf1>
				err = -err;
  80066b:	f7 d8                	neg    %eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80066d:	83 f8 0f             	cmp    $0xf,%eax
  800670:	7f 0b                	jg     80067d <vprintfmt+0x101>
  800672:	8b 3c 85 00 11 80 00 	mov    0x801100(,%eax,4),%edi
  800679:	85 ff                	test   %edi,%edi
  80067b:	75 19                	jne    800696 <vprintfmt+0x11a>
				printfmt(putch, putdat, "error %d", err);
  80067d:	50                   	push   %eax
  80067e:	68 c0 10 80 00       	push   $0x8010c0
  800683:	ff 75 0c             	pushl  0xc(%ebp)
  800686:	ff 75 08             	pushl  0x8(%ebp)
  800689:	e8 ef 01 00 00       	call   80087d <printfmt>
  80068e:	83 c4 10             	add    $0x10,%esp
  800691:	e9 f2 fe ff ff       	jmp    800588 <vprintfmt+0xc>
			else
				printfmt(putch, putdat, "%s", p);
  800696:	57                   	push   %edi
  800697:	68 c9 10 80 00       	push   $0x8010c9
  80069c:	ff 75 0c             	pushl  0xc(%ebp)
  80069f:	ff 75 08             	pushl  0x8(%ebp)
  8006a2:	e8 d6 01 00 00       	call   80087d <printfmt>
  8006a7:	83 c4 10             	add    $0x10,%esp
			break;
  8006aa:	e9 d9 fe ff ff       	jmp    800588 <vprintfmt+0xc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006af:	8b 55 14             	mov    0x14(%ebp),%edx
  8006b2:	8d 42 04             	lea    0x4(%edx),%eax
  8006b5:	89 45 14             	mov    %eax,0x14(%ebp)
  8006b8:	8b 3a                	mov    (%edx),%edi
  8006ba:	85 ff                	test   %edi,%edi
  8006bc:	75 05                	jne    8006c3 <vprintfmt+0x147>
				p = "(null)";
  8006be:	bf cc 10 80 00       	mov    $0x8010cc,%edi
			if (width > 0 && padc != '-')
  8006c3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8006c7:	7e 3b                	jle    800704 <vprintfmt+0x188>
  8006c9:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  8006cd:	74 35                	je     800704 <vprintfmt+0x188>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cf:	83 ec 08             	sub    $0x8,%esp
  8006d2:	56                   	push   %esi
  8006d3:	57                   	push   %edi
  8006d4:	e8 58 02 00 00       	call   800931 <strnlen>
  8006d9:	29 45 f0             	sub    %eax,-0x10(%ebp)
  8006dc:	83 c4 10             	add    $0x10,%esp
  8006df:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8006e3:	7e 1f                	jle    800704 <vprintfmt+0x188>
  8006e5:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  8006e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
					putch(padc, putdat);
  8006ec:	83 ec 08             	sub    $0x8,%esp
  8006ef:	ff 75 0c             	pushl  0xc(%ebp)
  8006f2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006f5:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f8:	83 c4 10             	add    $0x10,%esp
  8006fb:	ff 4d f0             	decl   -0x10(%ebp)
  8006fe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800702:	7f e8                	jg     8006ec <vprintfmt+0x170>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800704:	0f be 0f             	movsbl (%edi),%ecx
  800707:	47                   	inc    %edi
  800708:	85 c9                	test   %ecx,%ecx
  80070a:	74 44                	je     800750 <vprintfmt+0x1d4>
  80070c:	85 f6                	test   %esi,%esi
  80070e:	78 03                	js     800713 <vprintfmt+0x197>
  800710:	4e                   	dec    %esi
  800711:	78 3d                	js     800750 <vprintfmt+0x1d4>
				if (altflag && (ch < ' ' || ch > '~'))
  800713:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  800717:	74 18                	je     800731 <vprintfmt+0x1b5>
  800719:	8d 41 e0             	lea    -0x20(%ecx),%eax
  80071c:	83 f8 5e             	cmp    $0x5e,%eax
  80071f:	76 10                	jbe    800731 <vprintfmt+0x1b5>
					putch('?', putdat);
  800721:	83 ec 08             	sub    $0x8,%esp
  800724:	ff 75 0c             	pushl  0xc(%ebp)
  800727:	6a 3f                	push   $0x3f
  800729:	ff 55 08             	call   *0x8(%ebp)
  80072c:	83 c4 10             	add    $0x10,%esp
  80072f:	eb 0d                	jmp    80073e <vprintfmt+0x1c2>
				else
					putch(ch, putdat);
  800731:	83 ec 08             	sub    $0x8,%esp
  800734:	ff 75 0c             	pushl  0xc(%ebp)
  800737:	51                   	push   %ecx
  800738:	ff 55 08             	call   *0x8(%ebp)
  80073b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80073e:	ff 4d f0             	decl   -0x10(%ebp)
  800741:	0f be 0f             	movsbl (%edi),%ecx
  800744:	47                   	inc    %edi
  800745:	85 c9                	test   %ecx,%ecx
  800747:	74 07                	je     800750 <vprintfmt+0x1d4>
  800749:	85 f6                	test   %esi,%esi
  80074b:	78 c6                	js     800713 <vprintfmt+0x197>
  80074d:	4e                   	dec    %esi
  80074e:	79 c3                	jns    800713 <vprintfmt+0x197>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800750:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800754:	0f 8e 2e fe ff ff    	jle    800588 <vprintfmt+0xc>
				putch(' ', putdat);
  80075a:	83 ec 08             	sub    $0x8,%esp
  80075d:	ff 75 0c             	pushl  0xc(%ebp)
  800760:	6a 20                	push   $0x20
  800762:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800765:	83 c4 10             	add    $0x10,%esp
  800768:	ff 4d f0             	decl   -0x10(%ebp)
  80076b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80076f:	7f e9                	jg     80075a <vprintfmt+0x1de>
				putch(' ', putdat);
			break;
  800771:	e9 12 fe ff ff       	jmp    800588 <vprintfmt+0xc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800776:	57                   	push   %edi
  800777:	8d 45 14             	lea    0x14(%ebp),%eax
  80077a:	50                   	push   %eax
  80077b:	e8 c4 fd ff ff       	call   800544 <getint>
  800780:	89 c6                	mov    %eax,%esi
  800782:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800784:	83 c4 08             	add    $0x8,%esp
  800787:	85 d2                	test   %edx,%edx
  800789:	79 15                	jns    8007a0 <vprintfmt+0x224>
				putch('-', putdat);
  80078b:	83 ec 08             	sub    $0x8,%esp
  80078e:	ff 75 0c             	pushl  0xc(%ebp)
  800791:	6a 2d                	push   $0x2d
  800793:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800796:	f7 de                	neg    %esi
  800798:	83 d7 00             	adc    $0x0,%edi
  80079b:	f7 df                	neg    %edi
  80079d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007a0:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8007a5:	eb 76                	jmp    80081d <vprintfmt+0x2a1>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007a7:	57                   	push   %edi
  8007a8:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ab:	50                   	push   %eax
  8007ac:	e8 53 fd ff ff       	call   800504 <getuint>
  8007b1:	89 c6                	mov    %eax,%esi
  8007b3:	89 d7                	mov    %edx,%edi
			base = 10;
  8007b5:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8007ba:	83 c4 08             	add    $0x8,%esp
  8007bd:	eb 5e                	jmp    80081d <vprintfmt+0x2a1>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8007bf:	57                   	push   %edi
  8007c0:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c3:	50                   	push   %eax
  8007c4:	e8 3b fd ff ff       	call   800504 <getuint>
  8007c9:	89 c6                	mov    %eax,%esi
  8007cb:	89 d7                	mov    %edx,%edi
			base = 8;
  8007cd:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  8007d2:	83 c4 08             	add    $0x8,%esp
  8007d5:	eb 46                	jmp    80081d <vprintfmt+0x2a1>

		// pointer
		case 'p':
			putch('0', putdat);
  8007d7:	83 ec 08             	sub    $0x8,%esp
  8007da:	ff 75 0c             	pushl  0xc(%ebp)
  8007dd:	6a 30                	push   $0x30
  8007df:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007e2:	83 c4 08             	add    $0x8,%esp
  8007e5:	ff 75 0c             	pushl  0xc(%ebp)
  8007e8:	6a 78                	push   $0x78
  8007ea:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8007ed:	8b 55 14             	mov    0x14(%ebp),%edx
  8007f0:	8d 42 04             	lea    0x4(%edx),%eax
  8007f3:	89 45 14             	mov    %eax,0x14(%ebp)
  8007f6:	8b 32                	mov    (%edx),%esi
  8007f8:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007fd:	ba 10 00 00 00       	mov    $0x10,%edx
			goto number;
  800802:	83 c4 10             	add    $0x10,%esp
  800805:	eb 16                	jmp    80081d <vprintfmt+0x2a1>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800807:	57                   	push   %edi
  800808:	8d 45 14             	lea    0x14(%ebp),%eax
  80080b:	50                   	push   %eax
  80080c:	e8 f3 fc ff ff       	call   800504 <getuint>
  800811:	89 c6                	mov    %eax,%esi
  800813:	89 d7                	mov    %edx,%edi
			base = 16;
  800815:	ba 10 00 00 00       	mov    $0x10,%edx
  80081a:	83 c4 08             	add    $0x8,%esp
		number:
			printnum(putch, putdat, num, base, width, padc);
  80081d:	83 ec 04             	sub    $0x4,%esp
  800820:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  800824:	50                   	push   %eax
  800825:	ff 75 f0             	pushl  -0x10(%ebp)
  800828:	52                   	push   %edx
  800829:	57                   	push   %edi
  80082a:	56                   	push   %esi
  80082b:	ff 75 0c             	pushl  0xc(%ebp)
  80082e:	ff 75 08             	pushl  0x8(%ebp)
  800831:	e8 2e fc ff ff       	call   800464 <printnum>
			break;
  800836:	83 c4 20             	add    $0x20,%esp
  800839:	e9 4a fd ff ff       	jmp    800588 <vprintfmt+0xc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80083e:	83 ec 08             	sub    $0x8,%esp
  800841:	ff 75 0c             	pushl  0xc(%ebp)
  800844:	51                   	push   %ecx
  800845:	ff 55 08             	call   *0x8(%ebp)
			break;
  800848:	83 c4 10             	add    $0x10,%esp
  80084b:	e9 38 fd ff ff       	jmp    800588 <vprintfmt+0xc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800850:	83 ec 08             	sub    $0x8,%esp
  800853:	ff 75 0c             	pushl  0xc(%ebp)
  800856:	6a 25                	push   $0x25
  800858:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80085b:	4b                   	dec    %ebx
  80085c:	83 c4 10             	add    $0x10,%esp
  80085f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800863:	0f 84 1f fd ff ff    	je     800588 <vprintfmt+0xc>
  800869:	4b                   	dec    %ebx
  80086a:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80086e:	75 f9                	jne    800869 <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  800870:	e9 13 fd ff ff       	jmp    800588 <vprintfmt+0xc>
		}
	}
}
  800875:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800878:	5b                   	pop    %ebx
  800879:	5e                   	pop    %esi
  80087a:	5f                   	pop    %edi
  80087b:	c9                   	leave  
  80087c:	c3                   	ret    

0080087d <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800883:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800886:	50                   	push   %eax
  800887:	ff 75 10             	pushl  0x10(%ebp)
  80088a:	ff 75 0c             	pushl  0xc(%ebp)
  80088d:	ff 75 08             	pushl  0x8(%ebp)
  800890:	e8 e7 fc ff ff       	call   80057c <vprintfmt>
	va_end(ap);
}
  800895:	c9                   	leave  
  800896:	c3                   	ret    

00800897 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  80089d:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  8008a0:	8b 0a                	mov    (%edx),%ecx
  8008a2:	3b 4a 04             	cmp    0x4(%edx),%ecx
  8008a5:	73 07                	jae    8008ae <sprintputch+0x17>
		*b->buf++ = ch;
  8008a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008aa:	88 01                	mov    %al,(%ecx)
  8008ac:	ff 02                	incl   (%edx)
}
  8008ae:	c9                   	leave  
  8008af:	c3                   	ret    

008008b0 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	83 ec 18             	sub    $0x18,%esp
  8008b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8008b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008bc:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8008bf:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
  8008c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008c6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

	if (buf == NULL || n < 1)
  8008cd:	85 d2                	test   %edx,%edx
  8008cf:	74 04                	je     8008d5 <vsnprintf+0x25>
  8008d1:	85 c9                	test   %ecx,%ecx
  8008d3:	7f 07                	jg     8008dc <vsnprintf+0x2c>
		return -E_INVAL;
  8008d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008da:	eb 1d                	jmp    8008f9 <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008dc:	ff 75 14             	pushl  0x14(%ebp)
  8008df:	ff 75 10             	pushl  0x10(%ebp)
  8008e2:	8d 45 e8             	lea    -0x18(%ebp),%eax
  8008e5:	50                   	push   %eax
  8008e6:	68 97 08 80 00       	push   $0x800897
  8008eb:	e8 8c fc ff ff       	call   80057c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8008f3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8008f9:	c9                   	leave  
  8008fa:	c3                   	ret    

008008fb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800901:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800904:	50                   	push   %eax
  800905:	ff 75 10             	pushl  0x10(%ebp)
  800908:	ff 75 0c             	pushl  0xc(%ebp)
  80090b:	ff 75 08             	pushl  0x8(%ebp)
  80090e:	e8 9d ff ff ff       	call   8008b0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800913:	c9                   	leave  
  800914:	c3                   	ret    
  800915:	00 00                	add    %al,(%eax)
	...

00800918 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80091e:	b8 00 00 00 00       	mov    $0x0,%eax
  800923:	80 3a 00             	cmpb   $0x0,(%edx)
  800926:	74 07                	je     80092f <strlen+0x17>
		n++;
  800928:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800929:	42                   	inc    %edx
  80092a:	80 3a 00             	cmpb   $0x0,(%edx)
  80092d:	75 f9                	jne    800928 <strlen+0x10>
		n++;
	return n;
}
  80092f:	c9                   	leave  
  800930:	c3                   	ret    

00800931 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800931:	55                   	push   %ebp
  800932:	89 e5                	mov    %esp,%ebp
  800934:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800937:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80093a:	b8 00 00 00 00       	mov    $0x0,%eax
  80093f:	85 d2                	test   %edx,%edx
  800941:	74 0f                	je     800952 <strnlen+0x21>
  800943:	80 39 00             	cmpb   $0x0,(%ecx)
  800946:	74 0a                	je     800952 <strnlen+0x21>
		n++;
  800948:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800949:	41                   	inc    %ecx
  80094a:	4a                   	dec    %edx
  80094b:	74 05                	je     800952 <strnlen+0x21>
  80094d:	80 39 00             	cmpb   $0x0,(%ecx)
  800950:	75 f6                	jne    800948 <strnlen+0x17>
		n++;
	return n;
}
  800952:	c9                   	leave  
  800953:	c3                   	ret    

00800954 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	53                   	push   %ebx
  800958:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095b:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  80095e:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  800960:	8a 02                	mov    (%edx),%al
  800962:	42                   	inc    %edx
  800963:	88 01                	mov    %al,(%ecx)
  800965:	41                   	inc    %ecx
  800966:	84 c0                	test   %al,%al
  800968:	75 f6                	jne    800960 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80096a:	89 d8                	mov    %ebx,%eax
  80096c:	5b                   	pop    %ebx
  80096d:	c9                   	leave  
  80096e:	c3                   	ret    

0080096f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	53                   	push   %ebx
  800973:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800976:	53                   	push   %ebx
  800977:	e8 9c ff ff ff       	call   800918 <strlen>
	strcpy(dst + len, src);
  80097c:	ff 75 0c             	pushl  0xc(%ebp)
  80097f:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800982:	50                   	push   %eax
  800983:	e8 cc ff ff ff       	call   800954 <strcpy>
	return dst;
}
  800988:	89 d8                	mov    %ebx,%eax
  80098a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80098d:	c9                   	leave  
  80098e:	c3                   	ret    

0080098f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
  800992:	57                   	push   %edi
  800993:	56                   	push   %esi
  800994:	53                   	push   %ebx
  800995:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800998:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099b:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  80099e:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  8009a0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8009a5:	39 f3                	cmp    %esi,%ebx
  8009a7:	73 10                	jae    8009b9 <strncpy+0x2a>
		*dst++ = *src;
  8009a9:	8a 02                	mov    (%edx),%al
  8009ab:	88 01                	mov    %al,(%ecx)
  8009ad:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009ae:	80 3a 01             	cmpb   $0x1,(%edx)
  8009b1:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009b4:	43                   	inc    %ebx
  8009b5:	39 f3                	cmp    %esi,%ebx
  8009b7:	72 f0                	jb     8009a9 <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009b9:	89 f8                	mov    %edi,%eax
  8009bb:	5b                   	pop    %ebx
  8009bc:	5e                   	pop    %esi
  8009bd:	5f                   	pop    %edi
  8009be:	c9                   	leave  
  8009bf:	c3                   	ret    

008009c0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	56                   	push   %esi
  8009c4:	53                   	push   %ebx
  8009c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009cb:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  8009ce:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  8009d0:	85 d2                	test   %edx,%edx
  8009d2:	74 19                	je     8009ed <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009d4:	4a                   	dec    %edx
  8009d5:	74 13                	je     8009ea <strlcpy+0x2a>
  8009d7:	80 39 00             	cmpb   $0x0,(%ecx)
  8009da:	74 0e                	je     8009ea <strlcpy+0x2a>
  8009dc:	8a 01                	mov    (%ecx),%al
  8009de:	41                   	inc    %ecx
  8009df:	88 03                	mov    %al,(%ebx)
  8009e1:	43                   	inc    %ebx
  8009e2:	4a                   	dec    %edx
  8009e3:	74 05                	je     8009ea <strlcpy+0x2a>
  8009e5:	80 39 00             	cmpb   $0x0,(%ecx)
  8009e8:	75 f2                	jne    8009dc <strlcpy+0x1c>
		*dst = '\0';
  8009ea:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  8009ed:	89 d8                	mov    %ebx,%eax
  8009ef:	29 f0                	sub    %esi,%eax
}
  8009f1:	5b                   	pop    %ebx
  8009f2:	5e                   	pop    %esi
  8009f3:	c9                   	leave  
  8009f4:	c3                   	ret    

008009f5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009f5:	55                   	push   %ebp
  8009f6:	89 e5                	mov    %esp,%ebp
  8009f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8009fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
		p++, q++;
  8009fe:	80 3a 00             	cmpb   $0x0,(%edx)
  800a01:	74 13                	je     800a16 <strcmp+0x21>
  800a03:	8a 02                	mov    (%edx),%al
  800a05:	3a 01                	cmp    (%ecx),%al
  800a07:	75 0d                	jne    800a16 <strcmp+0x21>
  800a09:	42                   	inc    %edx
  800a0a:	41                   	inc    %ecx
  800a0b:	80 3a 00             	cmpb   $0x0,(%edx)
  800a0e:	74 06                	je     800a16 <strcmp+0x21>
  800a10:	8a 02                	mov    (%edx),%al
  800a12:	3a 01                	cmp    (%ecx),%al
  800a14:	74 f3                	je     800a09 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a16:	0f b6 02             	movzbl (%edx),%eax
  800a19:	0f b6 11             	movzbl (%ecx),%edx
  800a1c:	29 d0                	sub    %edx,%eax
}
  800a1e:	c9                   	leave  
  800a1f:	c3                   	ret    

00800a20 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	53                   	push   %ebx
  800a24:	8b 55 08             	mov    0x8(%ebp),%edx
  800a27:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a2a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800a2d:	85 c9                	test   %ecx,%ecx
  800a2f:	74 1f                	je     800a50 <strncmp+0x30>
  800a31:	80 3a 00             	cmpb   $0x0,(%edx)
  800a34:	74 16                	je     800a4c <strncmp+0x2c>
  800a36:	8a 02                	mov    (%edx),%al
  800a38:	3a 03                	cmp    (%ebx),%al
  800a3a:	75 10                	jne    800a4c <strncmp+0x2c>
  800a3c:	42                   	inc    %edx
  800a3d:	43                   	inc    %ebx
  800a3e:	49                   	dec    %ecx
  800a3f:	74 0f                	je     800a50 <strncmp+0x30>
  800a41:	80 3a 00             	cmpb   $0x0,(%edx)
  800a44:	74 06                	je     800a4c <strncmp+0x2c>
  800a46:	8a 02                	mov    (%edx),%al
  800a48:	3a 03                	cmp    (%ebx),%al
  800a4a:	74 f0                	je     800a3c <strncmp+0x1c>
	if (n == 0)
  800a4c:	85 c9                	test   %ecx,%ecx
  800a4e:	75 07                	jne    800a57 <strncmp+0x37>
		return 0;
  800a50:	b8 00 00 00 00       	mov    $0x0,%eax
  800a55:	eb 0a                	jmp    800a61 <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a57:	0f b6 12             	movzbl (%edx),%edx
  800a5a:	0f b6 03             	movzbl (%ebx),%eax
  800a5d:	29 c2                	sub    %eax,%edx
  800a5f:	89 d0                	mov    %edx,%eax
}
  800a61:	5b                   	pop    %ebx
  800a62:	c9                   	leave  
  800a63:	c3                   	ret    

00800a64 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6a:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800a6d:	80 38 00             	cmpb   $0x0,(%eax)
  800a70:	74 0a                	je     800a7c <strchr+0x18>
		if (*s == c)
  800a72:	38 10                	cmp    %dl,(%eax)
  800a74:	74 0b                	je     800a81 <strchr+0x1d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a76:	40                   	inc    %eax
  800a77:	80 38 00             	cmpb   $0x0,(%eax)
  800a7a:	75 f6                	jne    800a72 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800a7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a81:	c9                   	leave  
  800a82:	c3                   	ret    

00800a83 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	8b 45 08             	mov    0x8(%ebp),%eax
  800a89:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800a8c:	80 38 00             	cmpb   $0x0,(%eax)
  800a8f:	74 0a                	je     800a9b <strfind+0x18>
		if (*s == c)
  800a91:	38 10                	cmp    %dl,(%eax)
  800a93:	74 06                	je     800a9b <strfind+0x18>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a95:	40                   	inc    %eax
  800a96:	80 38 00             	cmpb   $0x0,(%eax)
  800a99:	75 f6                	jne    800a91 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
}
  800a9b:	c9                   	leave  
  800a9c:	c3                   	ret    

00800a9d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	57                   	push   %edi
  800aa1:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aa4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
		return v;
  800aa7:	89 f8                	mov    %edi,%eax
void *
memset(void *v, int c, size_t n)
{
	char *p;

	if (n == 0)
  800aa9:	85 c9                	test   %ecx,%ecx
  800aab:	74 40                	je     800aed <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aad:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ab3:	75 30                	jne    800ae5 <memset+0x48>
  800ab5:	f6 c1 03             	test   $0x3,%cl
  800ab8:	75 2b                	jne    800ae5 <memset+0x48>
		c &= 0xFF;
  800aba:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ac1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac4:	c1 e0 18             	shl    $0x18,%eax
  800ac7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aca:	c1 e2 10             	shl    $0x10,%edx
  800acd:	09 d0                	or     %edx,%eax
  800acf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad2:	c1 e2 08             	shl    $0x8,%edx
  800ad5:	09 d0                	or     %edx,%eax
  800ad7:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  800ada:	c1 e9 02             	shr    $0x2,%ecx
  800add:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae0:	fc                   	cld    
  800ae1:	f3 ab                	rep stos %eax,%es:(%edi)
  800ae3:	eb 06                	jmp    800aeb <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ae5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae8:	fc                   	cld    
  800ae9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800aeb:	89 f8                	mov    %edi,%eax
}
  800aed:	5f                   	pop    %edi
  800aee:	c9                   	leave  
  800aef:	c3                   	ret    

00800af0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	57                   	push   %edi
  800af4:	56                   	push   %esi
  800af5:	8b 45 08             	mov    0x8(%ebp),%eax
  800af8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800afb:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800afe:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800b00:	39 c6                	cmp    %eax,%esi
  800b02:	73 34                	jae    800b38 <memmove+0x48>
  800b04:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b07:	39 c2                	cmp    %eax,%edx
  800b09:	76 2d                	jbe    800b38 <memmove+0x48>
		s += n;
  800b0b:	89 d6                	mov    %edx,%esi
		d += n;
  800b0d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b10:	f6 c2 03             	test   $0x3,%dl
  800b13:	75 1b                	jne    800b30 <memmove+0x40>
  800b15:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b1b:	75 13                	jne    800b30 <memmove+0x40>
  800b1d:	f6 c1 03             	test   $0x3,%cl
  800b20:	75 0e                	jne    800b30 <memmove+0x40>
			asm volatile("std; rep movsl\n"
  800b22:	83 ef 04             	sub    $0x4,%edi
  800b25:	83 ee 04             	sub    $0x4,%esi
  800b28:	c1 e9 02             	shr    $0x2,%ecx
  800b2b:	fd                   	std    
  800b2c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b2e:	eb 05                	jmp    800b35 <memmove+0x45>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b30:	4f                   	dec    %edi
  800b31:	4e                   	dec    %esi
  800b32:	fd                   	std    
  800b33:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b35:	fc                   	cld    
  800b36:	eb 20                	jmp    800b58 <memmove+0x68>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b38:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b3e:	75 15                	jne    800b55 <memmove+0x65>
  800b40:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b46:	75 0d                	jne    800b55 <memmove+0x65>
  800b48:	f6 c1 03             	test   $0x3,%cl
  800b4b:	75 08                	jne    800b55 <memmove+0x65>
			asm volatile("cld; rep movsl\n"
  800b4d:	c1 e9 02             	shr    $0x2,%ecx
  800b50:	fc                   	cld    
  800b51:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b53:	eb 03                	jmp    800b58 <memmove+0x68>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b55:	fc                   	cld    
  800b56:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b58:	5e                   	pop    %esi
  800b59:	5f                   	pop    %edi
  800b5a:	c9                   	leave  
  800b5b:	c3                   	ret    

00800b5c <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b5f:	ff 75 10             	pushl  0x10(%ebp)
  800b62:	ff 75 0c             	pushl  0xc(%ebp)
  800b65:	ff 75 08             	pushl  0x8(%ebp)
  800b68:	e8 83 ff ff ff       	call   800af0 <memmove>
}
  800b6d:	c9                   	leave  
  800b6e:	c3                   	ret    

00800b6f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b6f:	55                   	push   %ebp
  800b70:	89 e5                	mov    %esp,%ebp
  800b72:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
  800b73:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  800b76:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b79:	8b 55 10             	mov    0x10(%ebp),%edx
  800b7c:	4a                   	dec    %edx
  800b7d:	83 fa ff             	cmp    $0xffffffff,%edx
  800b80:	74 1a                	je     800b9c <memcmp+0x2d>
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  800b82:	8a 01                	mov    (%ecx),%al
  800b84:	3a 03                	cmp    (%ebx),%al
  800b86:	74 0c                	je     800b94 <memcmp+0x25>
			return (int) *s1 - (int) *s2;
  800b88:	0f b6 d0             	movzbl %al,%edx
  800b8b:	0f b6 03             	movzbl (%ebx),%eax
  800b8e:	29 c2                	sub    %eax,%edx
  800b90:	89 d0                	mov    %edx,%eax
  800b92:	eb 0d                	jmp    800ba1 <memcmp+0x32>
		s1++, s2++;
  800b94:	41                   	inc    %ecx
  800b95:	43                   	inc    %ebx
  800b96:	4a                   	dec    %edx
  800b97:	83 fa ff             	cmp    $0xffffffff,%edx
  800b9a:	75 e6                	jne    800b82 <memcmp+0x13>
	}

	return 0;
  800b9c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ba1:	5b                   	pop    %ebx
  800ba2:	c9                   	leave  
  800ba3:	c3                   	ret    

00800ba4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	8b 45 08             	mov    0x8(%ebp),%eax
  800baa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bad:	89 c2                	mov    %eax,%edx
  800baf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bb2:	39 d0                	cmp    %edx,%eax
  800bb4:	73 09                	jae    800bbf <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bb6:	38 08                	cmp    %cl,(%eax)
  800bb8:	74 05                	je     800bbf <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bba:	40                   	inc    %eax
  800bbb:	39 d0                	cmp    %edx,%eax
  800bbd:	72 f7                	jb     800bb6 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bbf:	c9                   	leave  
  800bc0:	c3                   	ret    

00800bc1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	57                   	push   %edi
  800bc5:	56                   	push   %esi
  800bc6:	53                   	push   %ebx
  800bc7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bca:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bcd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  800bd0:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  800bd5:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  800bda:	80 3a 20             	cmpb   $0x20,(%edx)
  800bdd:	74 05                	je     800be4 <strtol+0x23>
  800bdf:	80 3a 09             	cmpb   $0x9,(%edx)
  800be2:	75 0b                	jne    800bef <strtol+0x2e>
  800be4:	42                   	inc    %edx
  800be5:	80 3a 20             	cmpb   $0x20,(%edx)
  800be8:	74 fa                	je     800be4 <strtol+0x23>
  800bea:	80 3a 09             	cmpb   $0x9,(%edx)
  800bed:	74 f5                	je     800be4 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  800bef:	80 3a 2b             	cmpb   $0x2b,(%edx)
  800bf2:	75 03                	jne    800bf7 <strtol+0x36>
		s++;
  800bf4:	42                   	inc    %edx
  800bf5:	eb 0b                	jmp    800c02 <strtol+0x41>
	else if (*s == '-')
  800bf7:	80 3a 2d             	cmpb   $0x2d,(%edx)
  800bfa:	75 06                	jne    800c02 <strtol+0x41>
		s++, neg = 1;
  800bfc:	42                   	inc    %edx
  800bfd:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c02:	85 c9                	test   %ecx,%ecx
  800c04:	74 05                	je     800c0b <strtol+0x4a>
  800c06:	83 f9 10             	cmp    $0x10,%ecx
  800c09:	75 15                	jne    800c20 <strtol+0x5f>
  800c0b:	80 3a 30             	cmpb   $0x30,(%edx)
  800c0e:	75 10                	jne    800c20 <strtol+0x5f>
  800c10:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c14:	75 0a                	jne    800c20 <strtol+0x5f>
		s += 2, base = 16;
  800c16:	83 c2 02             	add    $0x2,%edx
  800c19:	b9 10 00 00 00       	mov    $0x10,%ecx
  800c1e:	eb 14                	jmp    800c34 <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800c20:	85 c9                	test   %ecx,%ecx
  800c22:	75 10                	jne    800c34 <strtol+0x73>
  800c24:	80 3a 30             	cmpb   $0x30,(%edx)
  800c27:	75 05                	jne    800c2e <strtol+0x6d>
		s++, base = 8;
  800c29:	42                   	inc    %edx
  800c2a:	b1 08                	mov    $0x8,%cl
  800c2c:	eb 06                	jmp    800c34 <strtol+0x73>
	else if (base == 0)
  800c2e:	85 c9                	test   %ecx,%ecx
  800c30:	75 02                	jne    800c34 <strtol+0x73>
		base = 10;
  800c32:	b1 0a                	mov    $0xa,%cl

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c34:	8a 02                	mov    (%edx),%al
  800c36:	83 e8 30             	sub    $0x30,%eax
  800c39:	3c 09                	cmp    $0x9,%al
  800c3b:	77 08                	ja     800c45 <strtol+0x84>
			dig = *s - '0';
  800c3d:	0f be 02             	movsbl (%edx),%eax
  800c40:	83 e8 30             	sub    $0x30,%eax
  800c43:	eb 20                	jmp    800c65 <strtol+0xa4>
		else if (*s >= 'a' && *s <= 'z')
  800c45:	8a 02                	mov    (%edx),%al
  800c47:	83 e8 61             	sub    $0x61,%eax
  800c4a:	3c 19                	cmp    $0x19,%al
  800c4c:	77 08                	ja     800c56 <strtol+0x95>
			dig = *s - 'a' + 10;
  800c4e:	0f be 02             	movsbl (%edx),%eax
  800c51:	83 e8 57             	sub    $0x57,%eax
  800c54:	eb 0f                	jmp    800c65 <strtol+0xa4>
		else if (*s >= 'A' && *s <= 'Z')
  800c56:	8a 02                	mov    (%edx),%al
  800c58:	83 e8 41             	sub    $0x41,%eax
  800c5b:	3c 19                	cmp    $0x19,%al
  800c5d:	77 12                	ja     800c71 <strtol+0xb0>
			dig = *s - 'A' + 10;
  800c5f:	0f be 02             	movsbl (%edx),%eax
  800c62:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  800c65:	39 c8                	cmp    %ecx,%eax
  800c67:	7d 08                	jge    800c71 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800c69:	42                   	inc    %edx
  800c6a:	0f af d9             	imul   %ecx,%ebx
  800c6d:	01 c3                	add    %eax,%ebx
  800c6f:	eb c3                	jmp    800c34 <strtol+0x73>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c71:	85 f6                	test   %esi,%esi
  800c73:	74 02                	je     800c77 <strtol+0xb6>
		*endptr = (char *) s;
  800c75:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800c77:	89 d8                	mov    %ebx,%eax
  800c79:	85 ff                	test   %edi,%edi
  800c7b:	74 02                	je     800c7f <strtol+0xbe>
  800c7d:	f7 d8                	neg    %eax
}
  800c7f:	5b                   	pop    %ebx
  800c80:	5e                   	pop    %esi
  800c81:	5f                   	pop    %edi
  800c82:	c9                   	leave  
  800c83:	c3                   	ret    

00800c84 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	57                   	push   %edi
  800c88:	56                   	push   %esi
  800c89:	83 ec 14             	sub    $0x14,%esp
  800c8c:	8b 55 14             	mov    0x14(%ebp),%edx
  800c8f:	8b 75 08             	mov    0x8(%ebp),%esi
  800c92:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c95:	8b 45 10             	mov    0x10(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800c98:	85 d2                	test   %edx,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800c9a:	89 75 f0             	mov    %esi,-0x10(%ebp)
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800c9d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  d1 = dd.s.high;
  800ca0:	89 55 f4             	mov    %edx,-0xc(%ebp)
  n0 = nn.s.low;
  n1 = nn.s.high;
  800ca3:	89 fe                	mov    %edi,%esi

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800ca5:	75 11                	jne    800cb8 <__udivdi3+0x34>
    {
      if (d0 > n1)
  800ca7:	39 f8                	cmp    %edi,%eax
  800ca9:	76 4d                	jbe    800cf8 <__udivdi3+0x74>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800cab:	89 fa                	mov    %edi,%edx
  800cad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cb0:	f7 75 e4             	divl   -0x1c(%ebp)
  800cb3:	89 c7                	mov    %eax,%edi
  800cb5:	eb 09                	jmp    800cc0 <__udivdi3+0x3c>
  800cb7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800cb8:	39 7d f4             	cmp    %edi,-0xc(%ebp)
  800cbb:	76 17                	jbe    800cd4 <__udivdi3+0x50>
	{
	  /* 00 = nn / DD */

	  q0 = 0;
  800cbd:	31 ff                	xor    %edi,%edi
  800cbf:	90                   	nop
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
		}

	      q1 = 0;
  800cc0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cc7:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800cca:	83 c4 14             	add    $0x14,%esp
  800ccd:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cce:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800cd0:	5f                   	pop    %edi
  800cd1:	c9                   	leave  
  800cd2:	c3                   	ret    
  800cd3:	90                   	nop
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800cd4:	0f bd 45 f4          	bsr    -0xc(%ebp),%eax
	  if (bm == 0)
  800cd8:	89 c7                	mov    %eax,%edi
  800cda:	83 f7 1f             	xor    $0x1f,%edi
  800cdd:	75 4d                	jne    800d2c <__udivdi3+0xa8>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800cdf:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ce2:	77 0a                	ja     800cee <__udivdi3+0x6a>
  800ce4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
		}
	      else
		q0 = 0;
  800ce7:	31 ff                	xor    %edi,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ce9:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  800cec:	72 d2                	jb     800cc0 <__udivdi3+0x3c>
		{
		  q0 = 1;
  800cee:	bf 01 00 00 00       	mov    $0x1,%edi
  800cf3:	eb cb                	jmp    800cc0 <__udivdi3+0x3c>
  800cf5:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800cf8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800cfb:	85 c0                	test   %eax,%eax
  800cfd:	75 0e                	jne    800d0d <__udivdi3+0x89>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800cff:	b8 01 00 00 00       	mov    $0x1,%eax
  800d04:	31 c9                	xor    %ecx,%ecx
  800d06:	31 d2                	xor    %edx,%edx
  800d08:	f7 f1                	div    %ecx
  800d0a:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d0d:	89 f0                	mov    %esi,%eax
  800d0f:	31 d2                	xor    %edx,%edx
  800d11:	f7 75 e4             	divl   -0x1c(%ebp)
  800d14:	89 45 ec             	mov    %eax,-0x14(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d17:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d1a:	f7 75 e4             	divl   -0x1c(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d1d:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d20:	83 c4 14             	add    $0x14,%esp

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d23:	89 c7                	mov    %eax,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d25:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d26:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d28:	5f                   	pop    %edi
  800d29:	c9                   	leave  
  800d2a:	c3                   	ret    
  800d2b:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d2c:	b8 20 00 00 00       	mov    $0x20,%eax
  800d31:	29 f8                	sub    %edi,%eax
  800d33:	89 45 e8             	mov    %eax,-0x18(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  800d36:	89 f9                	mov    %edi,%ecx
  800d38:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d3b:	d3 e2                	shl    %cl,%edx
  800d3d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d40:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800d43:	d3 e8                	shr    %cl,%eax
  800d45:	09 c2                	or     %eax,%edx
	      d0 = d0 << bm;
  800d47:	89 f9                	mov    %edi,%ecx
  800d49:	d3 65 e4             	shll   %cl,-0x1c(%ebp)
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d4c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800d4f:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800d52:	89 f2                	mov    %esi,%edx
  800d54:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  800d56:	89 f9                	mov    %edi,%ecx
  800d58:	d3 e6                	shl    %cl,%esi
  800d5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d5d:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800d60:	d3 e8                	shr    %cl,%eax
  800d62:	09 c6                	or     %eax,%esi
	      n0 = n0 << bm;
  800d64:	89 f9                	mov    %edi,%ecx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d66:	89 f0                	mov    %esi,%eax
  800d68:	f7 75 f4             	divl   -0xc(%ebp)
  800d6b:	89 d6                	mov    %edx,%esi
  800d6d:	89 c7                	mov    %eax,%edi

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800d6f:	d3 65 f0             	shll   %cl,-0x10(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800d72:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d75:	f7 e7                	mul    %edi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d77:	39 f2                	cmp    %esi,%edx
  800d79:	77 0f                	ja     800d8a <__udivdi3+0x106>
  800d7b:	0f 85 3f ff ff ff    	jne    800cc0 <__udivdi3+0x3c>
  800d81:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800d84:	0f 86 36 ff ff ff    	jbe    800cc0 <__udivdi3+0x3c>
		{
		  q0--;
  800d8a:	4f                   	dec    %edi
  800d8b:	e9 30 ff ff ff       	jmp    800cc0 <__udivdi3+0x3c>

00800d90 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	57                   	push   %edi
  800d94:	56                   	push   %esi
  800d95:	83 ec 30             	sub    $0x30,%esp
  800d98:	8b 55 14             	mov    0x14(%ebp),%edx
  800d9b:	8b 45 10             	mov    0x10(%ebp),%eax
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  800d9e:	89 d7                	mov    %edx,%edi
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  800da0:	8d 4d f0             	lea    -0x10(%ebp),%ecx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800da3:	89 c6                	mov    %eax,%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;
  800da5:	8b 55 0c             	mov    0xc(%ebp),%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800da8:	8b 45 08             	mov    0x8(%ebp),%eax
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800dab:	85 ff                	test   %edi,%edi
  800dad:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800db4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  800dbb:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800dbe:	89 45 dc             	mov    %eax,-0x24(%ebp)
  n1 = nn.s.high;
  800dc1:	89 55 cc             	mov    %edx,-0x34(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800dc4:	75 3e                	jne    800e04 <__umoddi3+0x74>
    {
      if (d0 > n1)
  800dc6:	39 d6                	cmp    %edx,%esi
  800dc8:	0f 86 a2 00 00 00    	jbe    800e70 <__umoddi3+0xe0>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800dce:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  800dd0:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800dd3:	85 c9                	test   %ecx,%ecx

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800dd5:	89 55 dc             	mov    %edx,-0x24(%ebp)

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  800dd8:	74 1b                	je     800df5 <__umoddi3+0x65>
	{
	  rr.s.low = n0;
  800dda:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800ddd:	89 45 e0             	mov    %eax,-0x20(%ebp)
	  rr.s.high = 0;
  800de0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800de7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800dea:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800ded:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800df0:	89 10                	mov    %edx,(%eax)
  800df2:	89 48 04             	mov    %ecx,0x4(%eax)
  800df5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800df8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800dfb:	83 c4 30             	add    $0x30,%esp
  800dfe:	5e                   	pop    %esi
  800dff:	5f                   	pop    %edi
  800e00:	c9                   	leave  
  800e01:	c3                   	ret    
  800e02:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e04:	3b 7d cc             	cmp    -0x34(%ebp),%edi
  800e07:	76 1f                	jbe    800e28 <__umoddi3+0x98>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800e09:	8b 55 08             	mov    0x8(%ebp),%edx
	      rr.s.high = n1;
  800e0c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800e0f:	89 55 e0             	mov    %edx,-0x20(%ebp)
	      rr.s.high = n1;
  800e12:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	      *rp = rr.ll;
  800e15:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e18:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800e1b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800e1e:	89 55 f4             	mov    %edx,-0xc(%ebp)
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e21:	83 c4 30             	add    $0x30,%esp
  800e24:	5e                   	pop    %esi
  800e25:	5f                   	pop    %edi
  800e26:	c9                   	leave  
  800e27:	c3                   	ret    
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e28:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800e2b:	83 f0 1f             	xor    $0x1f,%eax
  800e2e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800e31:	75 61                	jne    800e94 <__umoddi3+0x104>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e33:	39 7d cc             	cmp    %edi,-0x34(%ebp)
  800e36:	77 05                	ja     800e3d <__umoddi3+0xad>
  800e38:	39 75 dc             	cmp    %esi,-0x24(%ebp)
  800e3b:	72 10                	jb     800e4d <__umoddi3+0xbd>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e3d:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800e40:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800e43:	29 f0                	sub    %esi,%eax
  800e45:	19 fa                	sbb    %edi,%edx
  800e47:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800e4a:	89 55 cc             	mov    %edx,-0x34(%ebp)
	      else
		q0 = 0;

	      q1 = 0;

	      if (rp != 0)
  800e4d:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800e50:	85 d2                	test   %edx,%edx
  800e52:	74 a1                	je     800df5 <__umoddi3+0x65>
		{
		  rr.s.low = n0;
  800e54:	8b 45 dc             	mov    -0x24(%ebp),%eax
		  rr.s.high = n1;
  800e57:	8b 55 cc             	mov    -0x34(%ebp),%edx

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  800e5a:	89 45 e0             	mov    %eax,-0x20(%ebp)
		  rr.s.high = n1;
  800e5d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		  *rp = rr.ll;
  800e60:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800e63:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e66:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800e69:	89 01                	mov    %eax,(%ecx)
  800e6b:	89 51 04             	mov    %edx,0x4(%ecx)
  800e6e:	eb 85                	jmp    800df5 <__umoddi3+0x65>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e70:	85 f6                	test   %esi,%esi
  800e72:	75 0b                	jne    800e7f <__umoddi3+0xef>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e74:	b8 01 00 00 00       	mov    $0x1,%eax
  800e79:	31 d2                	xor    %edx,%edx
  800e7b:	f7 f6                	div    %esi
  800e7d:	89 c6                	mov    %eax,%esi

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e7f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800e82:	89 fa                	mov    %edi,%edx
  800e84:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e86:	8b 45 dc             	mov    -0x24(%ebp),%eax
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e89:	89 55 cc             	mov    %edx,-0x34(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e8c:	f7 f6                	div    %esi
  800e8e:	e9 3d ff ff ff       	jmp    800dd0 <__umoddi3+0x40>
  800e93:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e94:	b8 20 00 00 00       	mov    $0x20,%eax
  800e99:	2b 45 d4             	sub    -0x2c(%ebp),%eax
  800e9c:	89 45 d8             	mov    %eax,-0x28(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  800e9f:	89 fa                	mov    %edi,%edx
  800ea1:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800ea4:	d3 e2                	shl    %cl,%edx
  800ea6:	89 f0                	mov    %esi,%eax
  800ea8:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800eab:	d3 e8                	shr    %cl,%eax
	      d0 = d0 << bm;
  800ead:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800eb0:	d3 e6                	shl    %cl,%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800eb2:	89 d7                	mov    %edx,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800eb4:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800eb7:	8b 55 cc             	mov    -0x34(%ebp),%edx
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800eba:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800ebc:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  800ebe:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800ec1:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800ec4:	d3 e0                	shl    %cl,%eax
  800ec6:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800ec9:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800ecc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800ecf:	d3 e8                	shr    %cl,%eax
  800ed1:	0b 45 cc             	or     -0x34(%ebp),%eax
  800ed4:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n0 = n0 << bm;
  800ed7:	8a 4d d4             	mov    -0x2c(%ebp),%cl

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800eda:	f7 f7                	div    %edi
  800edc:	89 55 cc             	mov    %edx,-0x34(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800edf:	d3 65 dc             	shll   %cl,-0x24(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800ee2:	f7 e6                	mul    %esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ee4:	3b 55 cc             	cmp    -0x34(%ebp),%edx
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800ee7:	89 45 c8             	mov    %eax,-0x38(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800eea:	77 0a                	ja     800ef6 <__umoddi3+0x166>
  800eec:	75 12                	jne    800f00 <__umoddi3+0x170>
  800eee:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800ef1:	39 45 c8             	cmp    %eax,-0x38(%ebp)
  800ef4:	76 0a                	jbe    800f00 <__umoddi3+0x170>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800ef6:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800ef9:	29 f1                	sub    %esi,%ecx
  800efb:	19 fa                	sbb    %edi,%edx
  800efd:	89 4d c8             	mov    %ecx,-0x38(%ebp)
		}

	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
  800f00:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f03:	85 c0                	test   %eax,%eax
  800f05:	0f 84 ea fe ff ff    	je     800df5 <__umoddi3+0x65>
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f0b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800f0e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800f11:	2b 45 c8             	sub    -0x38(%ebp),%eax
  800f14:	19 d1                	sbb    %edx,%ecx
  800f16:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f19:	89 ca                	mov    %ecx,%edx
  800f1b:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800f1e:	d3 e2                	shl    %cl,%edx
  800f20:	8a 4d d4             	mov    -0x2c(%ebp),%cl
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f23:	89 45 dc             	mov    %eax,-0x24(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f26:	d3 e8                	shr    %cl,%eax
  800f28:	09 c2                	or     %eax,%edx
		  rr.s.high = n1 >> bm;
  800f2a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800f2d:	d3 e8                	shr    %cl,%eax

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f2f:	89 55 e0             	mov    %edx,-0x20(%ebp)
		  rr.s.high = n1 >> bm;
  800f32:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f35:	e9 ad fe ff ff       	jmp    800de7 <__umoddi3+0x57>
