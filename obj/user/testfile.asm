
obj/user/testfile.debug:     file format elf32-i386


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
  80002c:	e8 ef 05 00 00       	call   800620 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 10             	sub    $0x10,%esp
	extern union Fsipc fsipcbuf;
	envid_t fsenv;
	
	strcpy(fsipcbuf.open.req_path, path);
  80003a:	ff 75 08             	pushl  0x8(%ebp)
  80003d:	68 00 50 80 00       	push   $0x805000
  800042:	e8 15 0c 00 00       	call   800c5c <strcpy>
	fsipcbuf.open.req_omode = mode;
  800047:	8b 45 0c             	mov    0xc(%ebp),%eax
  80004a:	a3 00 54 80 00       	mov    %eax,0x805400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  80004f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800056:	e8 b6 12 00 00       	call   801311 <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80005b:	6a 07                	push   $0x7
  80005d:	68 00 50 80 00       	push   $0x805000
  800062:	6a 01                	push   $0x1
  800064:	50                   	push   %eax
  800065:	e8 46 12 00 00       	call   8012b0 <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  80006a:	83 c4 1c             	add    $0x1c,%esp
  80006d:	6a 00                	push   $0x0
  80006f:	68 00 c0 cc cc       	push   $0xccccc000
  800074:	6a 00                	push   $0x0
  800076:	e8 c5 11 00 00       	call   801240 <ipc_recv>
}
  80007b:	c9                   	leave  
  80007c:	c3                   	ret    

0080007d <umain>:

void
umain(int argc, char **argv)
{
  80007d:	55                   	push   %ebp
  80007e:	89 e5                	mov    %esp,%ebp
  800080:	57                   	push   %edi
  800081:	56                   	push   %esi
  800082:	53                   	push   %ebx
  800083:	81 ec b4 02 00 00    	sub    $0x2b4,%esp
	struct Fd *fd;
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];
	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  800089:	6a 00                	push   $0x0
  80008b:	68 03 20 80 00       	push   $0x802003
  800090:	e8 9f ff ff ff       	call   800034 <xopen>
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	85 c0                	test   %eax,%eax
  80009a:	79 1b                	jns    8000b7 <umain+0x3a>
  80009c:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80009f:	74 12                	je     8000b3 <umain+0x36>
		panic("serve_open /not-found: %e", r);
  8000a1:	50                   	push   %eax
  8000a2:	68 0e 20 80 00       	push   $0x80200e
  8000a7:	6a 1f                	push   $0x1f
  8000a9:	68 28 20 80 00       	push   $0x802028
  8000ae:	e8 c9 05 00 00       	call   80067c <_panic>
	else if (r >= 0)
  8000b3:	85 c0                	test   %eax,%eax
  8000b5:	78 14                	js     8000cb <umain+0x4e>
		panic("serve_open /not-found succeeded!");
  8000b7:	83 ec 04             	sub    $0x4,%esp
  8000ba:	68 28 1e 80 00       	push   $0x801e28
  8000bf:	6a 21                	push   $0x21
  8000c1:	68 28 20 80 00       	push   $0x802028
  8000c6:	e8 b1 05 00 00       	call   80067c <_panic>


	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  8000cb:	83 ec 08             	sub    $0x8,%esp
  8000ce:	6a 00                	push   $0x0
  8000d0:	68 38 20 80 00       	push   $0x802038
  8000d5:	e8 5a ff ff ff       	call   800034 <xopen>
  8000da:	83 c4 10             	add    $0x10,%esp
  8000dd:	85 c0                	test   %eax,%eax
  8000df:	79 12                	jns    8000f3 <umain+0x76>
		panic("serve_open /newmotd: %e", r);
  8000e1:	50                   	push   %eax
  8000e2:	68 41 20 80 00       	push   $0x802041
  8000e7:	6a 25                	push   $0x25
  8000e9:	68 28 20 80 00       	push   $0x802028
  8000ee:	e8 89 05 00 00       	call   80067c <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  8000f3:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  8000fa:	75 12                	jne    80010e <umain+0x91>
  8000fc:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  800103:	75 09                	jne    80010e <umain+0x91>
  800105:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  80010c:	74 14                	je     800122 <umain+0xa5>
		panic("serve_open did not fill struct Fd correctly\n");
  80010e:	83 ec 04             	sub    $0x4,%esp
  800111:	68 4c 1e 80 00       	push   $0x801e4c
  800116:	6a 27                	push   $0x27
  800118:	68 28 20 80 00       	push   $0x802028
  80011d:	e8 5a 05 00 00       	call   80067c <_panic>
	cprintf("serve_open is good\n");
  800122:	83 ec 0c             	sub    $0xc,%esp
  800125:	68 59 20 80 00       	push   $0x802059
  80012a:	e8 29 06 00 00       	call   800758 <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  80012f:	83 c4 08             	add    $0x8,%esp
  800132:	8d 85 48 ff ff ff    	lea    -0xb8(%ebp),%eax
  800138:	50                   	push   %eax
  800139:	68 00 c0 cc cc       	push   $0xccccc000
  80013e:	ff 15 24 30 80 00    	call   *0x803024
  800144:	83 c4 10             	add    $0x10,%esp
  800147:	85 c0                	test   %eax,%eax
  800149:	79 12                	jns    80015d <umain+0xe0>
		panic("file_stat: %e", r);
  80014b:	50                   	push   %eax
  80014c:	68 6d 20 80 00       	push   $0x80206d
  800151:	6a 2b                	push   $0x2b
  800153:	68 28 20 80 00       	push   $0x802028
  800158:	e8 1f 05 00 00       	call   80067c <_panic>
	if (strlen(msg) != st.st_size)
  80015d:	83 ec 0c             	sub    $0xc,%esp
  800160:	ff 35 00 30 80 00    	pushl  0x803000
  800166:	e8 b5 0a 00 00       	call   800c20 <strlen>
  80016b:	83 c4 10             	add    $0x10,%esp
  80016e:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  800171:	74 25                	je     800198 <umain+0x11b>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  800173:	83 ec 0c             	sub    $0xc,%esp
  800176:	ff 35 00 30 80 00    	pushl  0x803000
  80017c:	e8 9f 0a 00 00       	call   800c20 <strlen>
  800181:	89 04 24             	mov    %eax,(%esp)
  800184:	ff 75 c8             	pushl  -0x38(%ebp)
  800187:	68 7c 1e 80 00       	push   $0x801e7c
  80018c:	6a 2d                	push   $0x2d
  80018e:	68 28 20 80 00       	push   $0x802028
  800193:	e8 e4 04 00 00       	call   80067c <_panic>
	cprintf("file_stat is good\n");
  800198:	83 ec 0c             	sub    $0xc,%esp
  80019b:	68 7b 20 80 00       	push   $0x80207b
  8001a0:	e8 b3 05 00 00       	call   800758 <cprintf>

	memset(buf, 0, sizeof buf);
  8001a5:	83 c4 0c             	add    $0xc,%esp
  8001a8:	68 00 02 00 00       	push   $0x200
  8001ad:	6a 00                	push   $0x0
  8001af:	8d 9d 48 fd ff ff    	lea    -0x2b8(%ebp),%ebx
  8001b5:	53                   	push   %ebx
  8001b6:	e8 ea 0b 00 00       	call   800da5 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  8001bb:	83 c4 0c             	add    $0xc,%esp
  8001be:	68 00 02 00 00       	push   $0x200
  8001c3:	53                   	push   %ebx
  8001c4:	68 00 c0 cc cc       	push   $0xccccc000
  8001c9:	ff 15 18 30 80 00    	call   *0x803018
  8001cf:	83 c4 10             	add    $0x10,%esp
  8001d2:	85 c0                	test   %eax,%eax
  8001d4:	79 12                	jns    8001e8 <umain+0x16b>
		panic("file_read: %e", r);
  8001d6:	50                   	push   %eax
  8001d7:	68 8e 20 80 00       	push   $0x80208e
  8001dc:	6a 32                	push   $0x32
  8001de:	68 28 20 80 00       	push   $0x802028
  8001e3:	e8 94 04 00 00       	call   80067c <_panic>
	if (strcmp(buf, msg) != 0)
  8001e8:	83 ec 08             	sub    $0x8,%esp
  8001eb:	ff 35 00 30 80 00    	pushl  0x803000
  8001f1:	8d 85 48 fd ff ff    	lea    -0x2b8(%ebp),%eax
  8001f7:	50                   	push   %eax
  8001f8:	e8 00 0b 00 00       	call   800cfd <strcmp>
  8001fd:	83 c4 10             	add    $0x10,%esp
  800200:	85 c0                	test   %eax,%eax
  800202:	74 14                	je     800218 <umain+0x19b>
		panic("file_read returned wrong data");
  800204:	83 ec 04             	sub    $0x4,%esp
  800207:	68 9c 20 80 00       	push   $0x80209c
  80020c:	6a 34                	push   $0x34
  80020e:	68 28 20 80 00       	push   $0x802028
  800213:	e8 64 04 00 00       	call   80067c <_panic>
	cprintf("file_read is good\n");
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	68 ba 20 80 00       	push   $0x8020ba
  800220:	e8 33 05 00 00       	call   800758 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  800225:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  80022c:	ff 15 20 30 80 00    	call   *0x803020
  800232:	83 c4 10             	add    $0x10,%esp
  800235:	85 c0                	test   %eax,%eax
  800237:	79 12                	jns    80024b <umain+0x1ce>
		panic("file_close: %e", r);
  800239:	50                   	push   %eax
  80023a:	68 cd 20 80 00       	push   $0x8020cd
  80023f:	6a 38                	push   $0x38
  800241:	68 28 20 80 00       	push   $0x802028
  800246:	e8 31 04 00 00       	call   80067c <_panic>
	cprintf("file_close is good\n");
  80024b:	83 ec 0c             	sub    $0xc,%esp
  80024e:	68 dc 20 80 00       	push   $0x8020dc
  800253:	e8 00 05 00 00       	call   800758 <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  800258:	a1 00 c0 cc cc       	mov    0xccccc000,%eax
  80025d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800260:	a1 04 c0 cc cc       	mov    0xccccc004,%eax
  800265:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800268:	a1 08 c0 cc cc       	mov    0xccccc008,%eax
  80026d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800270:	a1 0c c0 cc cc       	mov    0xccccc00c,%eax
  800275:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	sys_page_unmap(0, FVA);
  800278:	83 c4 08             	add    $0x8,%esp
  80027b:	68 00 c0 cc cc       	push   $0xccccc000
  800280:	6a 00                	push   $0x0
  800282:	e8 4c 0e 00 00       	call   8010d3 <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  800287:	83 c4 0c             	add    $0xc,%esp
  80028a:	68 00 02 00 00       	push   $0x200
  80028f:	8d 85 48 fd ff ff    	lea    -0x2b8(%ebp),%eax
  800295:	50                   	push   %eax
  800296:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800299:	50                   	push   %eax
  80029a:	ff 15 18 30 80 00    	call   *0x803018
  8002a0:	83 c4 10             	add    $0x10,%esp
  8002a3:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8002a6:	74 12                	je     8002ba <umain+0x23d>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  8002a8:	50                   	push   %eax
  8002a9:	68 a4 1e 80 00       	push   $0x801ea4
  8002ae:	6a 43                	push   $0x43
  8002b0:	68 28 20 80 00       	push   $0x802028
  8002b5:	e8 c2 03 00 00       	call   80067c <_panic>
	cprintf("stale fileid is good\n");
  8002ba:	83 ec 0c             	sub    $0xc,%esp
  8002bd:	68 f0 20 80 00       	push   $0x8020f0
  8002c2:	e8 91 04 00 00       	call   800758 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  8002c7:	83 c4 08             	add    $0x8,%esp
  8002ca:	68 02 01 00 00       	push   $0x102
  8002cf:	68 06 21 80 00       	push   $0x802106
  8002d4:	e8 5b fd ff ff       	call   800034 <xopen>
  8002d9:	83 c4 10             	add    $0x10,%esp
  8002dc:	85 c0                	test   %eax,%eax
  8002de:	79 12                	jns    8002f2 <umain+0x275>
		panic("serve_open /new-file: %e", r);
  8002e0:	50                   	push   %eax
  8002e1:	68 10 21 80 00       	push   $0x802110
  8002e6:	6a 48                	push   $0x48
  8002e8:	68 28 20 80 00       	push   $0x802028
  8002ed:	e8 8a 03 00 00       	call   80067c <_panic>

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  8002f2:	83 ec 0c             	sub    $0xc,%esp
  8002f5:	ff 35 00 30 80 00    	pushl  0x803000
  8002fb:	e8 20 09 00 00       	call   800c20 <strlen>
  800300:	83 c4 0c             	add    $0xc,%esp
  800303:	50                   	push   %eax
  800304:	ff 35 00 30 80 00    	pushl  0x803000
  80030a:	68 00 c0 cc cc       	push   $0xccccc000
  80030f:	ff 15 1c 30 80 00    	call   *0x80301c
  800315:	89 c3                	mov    %eax,%ebx
  800317:	83 c4 04             	add    $0x4,%esp
  80031a:	ff 35 00 30 80 00    	pushl  0x803000
  800320:	e8 fb 08 00 00       	call   800c20 <strlen>
  800325:	83 c4 10             	add    $0x10,%esp
  800328:	39 c3                	cmp    %eax,%ebx
  80032a:	74 12                	je     80033e <umain+0x2c1>
		panic("file_write: %e", r);
  80032c:	53                   	push   %ebx
  80032d:	68 29 21 80 00       	push   $0x802129
  800332:	6a 4b                	push   $0x4b
  800334:	68 28 20 80 00       	push   $0x802028
  800339:	e8 3e 03 00 00       	call   80067c <_panic>
	cprintf("file_write is good\n");
  80033e:	83 ec 0c             	sub    $0xc,%esp
  800341:	68 38 21 80 00       	push   $0x802138
  800346:	e8 0d 04 00 00       	call   800758 <cprintf>

	FVA->fd_offset = 0;
  80034b:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  800352:	00 00 00 
	memset(buf, 0, sizeof buf);
  800355:	83 c4 0c             	add    $0xc,%esp
  800358:	68 00 02 00 00       	push   $0x200
  80035d:	6a 00                	push   $0x0
  80035f:	8d 9d 48 fd ff ff    	lea    -0x2b8(%ebp),%ebx
  800365:	53                   	push   %ebx
  800366:	e8 3a 0a 00 00       	call   800da5 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  80036b:	83 c4 0c             	add    $0xc,%esp
  80036e:	68 00 02 00 00       	push   $0x200
  800373:	53                   	push   %ebx
  800374:	68 00 c0 cc cc       	push   $0xccccc000
  800379:	ff 15 18 30 80 00    	call   *0x803018
  80037f:	89 c3                	mov    %eax,%ebx
  800381:	83 c4 10             	add    $0x10,%esp
  800384:	85 c0                	test   %eax,%eax
  800386:	79 12                	jns    80039a <umain+0x31d>
		panic("file_read after file_write: %e", r);
  800388:	50                   	push   %eax
  800389:	68 dc 1e 80 00       	push   $0x801edc
  80038e:	6a 51                	push   $0x51
  800390:	68 28 20 80 00       	push   $0x802028
  800395:	e8 e2 02 00 00       	call   80067c <_panic>
	if (r != strlen(msg))
  80039a:	83 ec 0c             	sub    $0xc,%esp
  80039d:	ff 35 00 30 80 00    	pushl  0x803000
  8003a3:	e8 78 08 00 00       	call   800c20 <strlen>
  8003a8:	83 c4 10             	add    $0x10,%esp
  8003ab:	39 d8                	cmp    %ebx,%eax
  8003ad:	74 12                	je     8003c1 <umain+0x344>
		panic("file_read after file_write returned wrong length: %d", r);
  8003af:	53                   	push   %ebx
  8003b0:	68 fc 1e 80 00       	push   $0x801efc
  8003b5:	6a 53                	push   $0x53
  8003b7:	68 28 20 80 00       	push   $0x802028
  8003bc:	e8 bb 02 00 00       	call   80067c <_panic>
	if (strcmp(buf, msg) != 0)
  8003c1:	83 ec 08             	sub    $0x8,%esp
  8003c4:	ff 35 00 30 80 00    	pushl  0x803000
  8003ca:	8d 85 48 fd ff ff    	lea    -0x2b8(%ebp),%eax
  8003d0:	50                   	push   %eax
  8003d1:	e8 27 09 00 00       	call   800cfd <strcmp>
  8003d6:	83 c4 10             	add    $0x10,%esp
  8003d9:	85 c0                	test   %eax,%eax
  8003db:	74 14                	je     8003f1 <umain+0x374>
		panic("file_read after file_write returned wrong data");
  8003dd:	83 ec 04             	sub    $0x4,%esp
  8003e0:	68 34 1f 80 00       	push   $0x801f34
  8003e5:	6a 55                	push   $0x55
  8003e7:	68 28 20 80 00       	push   $0x802028
  8003ec:	e8 8b 02 00 00       	call   80067c <_panic>
	cprintf("file_read after file_write is good\n");
  8003f1:	83 ec 0c             	sub    $0xc,%esp
  8003f4:	68 64 1f 80 00       	push   $0x801f64
  8003f9:	e8 5a 03 00 00       	call   800758 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  8003fe:	83 c4 08             	add    $0x8,%esp
  800401:	6a 00                	push   $0x0
  800403:	68 03 20 80 00       	push   $0x802003
  800408:	e8 32 15 00 00       	call   80193f <open>
  80040d:	83 c4 10             	add    $0x10,%esp
  800410:	85 c0                	test   %eax,%eax
  800412:	79 1b                	jns    80042f <umain+0x3b2>
  800414:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800417:	74 12                	je     80042b <umain+0x3ae>
		panic("open /not-found: %e", r);
  800419:	50                   	push   %eax
  80041a:	68 14 20 80 00       	push   $0x802014
  80041f:	6a 5a                	push   $0x5a
  800421:	68 28 20 80 00       	push   $0x802028
  800426:	e8 51 02 00 00       	call   80067c <_panic>
	else if (r >= 0)
  80042b:	85 c0                	test   %eax,%eax
  80042d:	78 14                	js     800443 <umain+0x3c6>
		panic("open /not-found succeeded!");
  80042f:	83 ec 04             	sub    $0x4,%esp
  800432:	68 4c 21 80 00       	push   $0x80214c
  800437:	6a 5c                	push   $0x5c
  800439:	68 28 20 80 00       	push   $0x802028
  80043e:	e8 39 02 00 00       	call   80067c <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  800443:	83 ec 08             	sub    $0x8,%esp
  800446:	6a 00                	push   $0x0
  800448:	68 38 20 80 00       	push   $0x802038
  80044d:	e8 ed 14 00 00       	call   80193f <open>
  800452:	83 c4 10             	add    $0x10,%esp
  800455:	85 c0                	test   %eax,%eax
  800457:	79 12                	jns    80046b <umain+0x3ee>
		panic("open /newmotd: %e", r);
  800459:	50                   	push   %eax
  80045a:	68 47 20 80 00       	push   $0x802047
  80045f:	6a 5f                	push   $0x5f
  800461:	68 28 20 80 00       	push   $0x802028
  800466:	e8 11 02 00 00       	call   80067c <_panic>
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  80046b:	c1 e0 0c             	shl    $0xc,%eax
  80046e:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  800474:	83 b8 00 00 00 d0 66 	cmpl   $0x66,-0x30000000(%eax)
  80047b:	75 0c                	jne    800489 <umain+0x40c>
  80047d:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
  800481:	75 06                	jne    800489 <umain+0x40c>
  800483:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  800487:	74 14                	je     80049d <umain+0x420>
		panic("open did not fill struct Fd correctly\n");
  800489:	83 ec 04             	sub    $0x4,%esp
  80048c:	68 88 1f 80 00       	push   $0x801f88
  800491:	6a 62                	push   $0x62
  800493:	68 28 20 80 00       	push   $0x802028
  800498:	e8 df 01 00 00       	call   80067c <_panic>
	cprintf("open is good\n");
  80049d:	83 ec 0c             	sub    $0xc,%esp
  8004a0:	68 5f 20 80 00       	push   $0x80205f
  8004a5:	e8 ae 02 00 00       	call   800758 <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  8004aa:	83 c4 08             	add    $0x8,%esp
  8004ad:	68 01 01 00 00       	push   $0x101
  8004b2:	68 67 21 80 00       	push   $0x802167
  8004b7:	e8 83 14 00 00       	call   80193f <open>
  8004bc:	89 c6                	mov    %eax,%esi
  8004be:	83 c4 10             	add    $0x10,%esp
  8004c1:	85 c0                	test   %eax,%eax
  8004c3:	79 12                	jns    8004d7 <umain+0x45a>
		panic("creat /big: %e", f);
  8004c5:	50                   	push   %eax
  8004c6:	68 6c 21 80 00       	push   $0x80216c
  8004cb:	6a 67                	push   $0x67
  8004cd:	68 28 20 80 00       	push   $0x802028
  8004d2:	e8 a5 01 00 00       	call   80067c <_panic>
	memset(buf, 0, sizeof(buf));
  8004d7:	83 ec 04             	sub    $0x4,%esp
  8004da:	68 00 02 00 00       	push   $0x200
  8004df:	6a 00                	push   $0x0
  8004e1:	8d 85 48 fd ff ff    	lea    -0x2b8(%ebp),%eax
  8004e7:	50                   	push   %eax
  8004e8:	e8 b8 08 00 00       	call   800da5 <memset>
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8004ed:	bf 00 00 00 00       	mov    $0x0,%edi
  8004f2:	83 c4 10             	add    $0x10,%esp
		*(int*)buf = i;
  8004f5:	89 bd 48 fd ff ff    	mov    %edi,-0x2b8(%ebp)
		if ((r = write(f, buf, sizeof(buf))) < 0)
  8004fb:	83 ec 04             	sub    $0x4,%esp
  8004fe:	68 00 02 00 00       	push   $0x200
  800503:	8d 85 48 fd ff ff    	lea    -0x2b8(%ebp),%eax
  800509:	50                   	push   %eax
  80050a:	56                   	push   %esi
  80050b:	e8 f9 11 00 00       	call   801709 <write>
  800510:	83 c4 10             	add    $0x10,%esp
  800513:	85 c0                	test   %eax,%eax
  800515:	79 16                	jns    80052d <umain+0x4b0>
			panic("write /big@%d: %e", i, r);
  800517:	83 ec 0c             	sub    $0xc,%esp
  80051a:	50                   	push   %eax
  80051b:	57                   	push   %edi
  80051c:	68 7b 21 80 00       	push   $0x80217b
  800521:	6a 6c                	push   $0x6c
  800523:	68 28 20 80 00       	push   $0x802028
  800528:	e8 4f 01 00 00       	call   80067c <_panic>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  80052d:	81 c7 00 02 00 00    	add    $0x200,%edi
  800533:	81 ff ff df 01 00    	cmp    $0x1dfff,%edi
  800539:	7e ba                	jle    8004f5 <umain+0x478>
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %e", i, r);
	}
	close(f);
  80053b:	83 ec 0c             	sub    $0xc,%esp
  80053e:	56                   	push   %esi
  80053f:	e8 bd 0f 00 00       	call   801501 <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  800544:	83 c4 08             	add    $0x8,%esp
  800547:	6a 00                	push   $0x0
  800549:	68 67 21 80 00       	push   $0x802167
  80054e:	e8 ec 13 00 00       	call   80193f <open>
  800553:	89 c6                	mov    %eax,%esi
  800555:	83 c4 10             	add    $0x10,%esp
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  800558:	bf 00 00 00 00       	mov    $0x0,%edi
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %e", i, r);
	}
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
  80055d:	85 c0                	test   %eax,%eax
  80055f:	79 12                	jns    800573 <umain+0x4f6>
		panic("open /big: %e", f);
  800561:	50                   	push   %eax
  800562:	68 8d 21 80 00       	push   $0x80218d
  800567:	6a 71                	push   $0x71
  800569:	68 28 20 80 00       	push   $0x802028
  80056e:	e8 09 01 00 00       	call   80067c <_panic>
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800573:	89 bd 48 fd ff ff    	mov    %edi,-0x2b8(%ebp)
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  800579:	83 ec 04             	sub    $0x4,%esp
  80057c:	68 00 02 00 00       	push   $0x200
  800581:	8d 85 48 fd ff ff    	lea    -0x2b8(%ebp),%eax
  800587:	50                   	push   %eax
  800588:	56                   	push   %esi
  800589:	e8 34 11 00 00       	call   8016c2 <readn>
  80058e:	83 c4 10             	add    $0x10,%esp
  800591:	85 c0                	test   %eax,%eax
  800593:	79 16                	jns    8005ab <umain+0x52e>
			panic("read /big@%d: %e", i, r);
  800595:	83 ec 0c             	sub    $0xc,%esp
  800598:	50                   	push   %eax
  800599:	57                   	push   %edi
  80059a:	68 9b 21 80 00       	push   $0x80219b
  80059f:	6a 75                	push   $0x75
  8005a1:	68 28 20 80 00       	push   $0x802028
  8005a6:	e8 d1 00 00 00       	call   80067c <_panic>
		if (r != sizeof(buf))
  8005ab:	3d 00 02 00 00       	cmp    $0x200,%eax
  8005b0:	74 1b                	je     8005cd <umain+0x550>
			panic("read /big from %d returned %d < %d bytes",
  8005b2:	83 ec 08             	sub    $0x8,%esp
  8005b5:	68 00 02 00 00       	push   $0x200
  8005ba:	50                   	push   %eax
  8005bb:	57                   	push   %edi
  8005bc:	68 b0 1f 80 00       	push   $0x801fb0
  8005c1:	6a 78                	push   $0x78
  8005c3:	68 28 20 80 00       	push   $0x802028
  8005c8:	e8 af 00 00 00       	call   80067c <_panic>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  8005cd:	39 bd 48 fd ff ff    	cmp    %edi,-0x2b8(%ebp)
  8005d3:	74 1b                	je     8005f0 <umain+0x573>
			panic("read /big from %d returned bad data %d",
  8005d5:	83 ec 0c             	sub    $0xc,%esp
  8005d8:	ff b5 48 fd ff ff    	pushl  -0x2b8(%ebp)
  8005de:	57                   	push   %edi
  8005df:	68 dc 1f 80 00       	push   $0x801fdc
  8005e4:	6a 7b                	push   $0x7b
  8005e6:	68 28 20 80 00       	push   $0x802028
  8005eb:	e8 8c 00 00 00       	call   80067c <_panic>
	}
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8005f0:	81 c7 00 02 00 00    	add    $0x200,%edi
  8005f6:	81 ff ff df 01 00    	cmp    $0x1dfff,%edi
  8005fc:	0f 8e 71 ff ff ff    	jle    800573 <umain+0x4f6>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
			panic("read /big from %d returned bad data %d",
			      i, *(int*)buf);
	}
	close(f);
  800602:	83 ec 0c             	sub    $0xc,%esp
  800605:	56                   	push   %esi
  800606:	e8 f6 0e 00 00       	call   801501 <close>
	cprintf("large file is good\n");
  80060b:	c7 04 24 ac 21 80 00 	movl   $0x8021ac,(%esp)
  800612:	e8 41 01 00 00       	call   800758 <cprintf>
}
  800617:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80061a:	5b                   	pop    %ebx
  80061b:	5e                   	pop    %esi
  80061c:	5f                   	pop    %edi
  80061d:	c9                   	leave  
  80061e:	c3                   	ret    
	...

00800620 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800620:	55                   	push   %ebp
  800621:	89 e5                	mov    %esp,%ebp
  800623:	56                   	push   %esi
  800624:	53                   	push   %ebx
  800625:	8b 75 08             	mov    0x8(%ebp),%esi
  800628:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];	
  80062b:	e8 e0 09 00 00       	call   801010 <sys_getenvid>
  800630:	25 ff 03 00 00       	and    $0x3ff,%eax
  800635:	89 c2                	mov    %eax,%edx
  800637:	c1 e2 05             	shl    $0x5,%edx
  80063a:	29 c2                	sub    %eax,%edx
  80063c:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  800643:	89 15 04 40 80 00    	mov    %edx,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800649:	85 f6                	test   %esi,%esi
  80064b:	7e 07                	jle    800654 <libmain+0x34>
		binaryname = argv[0];
  80064d:	8b 03                	mov    (%ebx),%eax
  80064f:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  800654:	83 ec 08             	sub    $0x8,%esp
  800657:	53                   	push   %ebx
  800658:	56                   	push   %esi
  800659:	e8 1f fa ff ff       	call   80007d <umain>

	// exit gracefully
	exit();
  80065e:	e8 09 00 00 00       	call   80066c <exit>
}
  800663:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800666:	5b                   	pop    %ebx
  800667:	5e                   	pop    %esi
  800668:	c9                   	leave  
  800669:	c3                   	ret    
	...

0080066c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80066c:	55                   	push   %ebp
  80066d:	89 e5                	mov    %esp,%ebp
  80066f:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  800672:	6a 00                	push   $0x0
  800674:	e8 56 09 00 00       	call   800fcf <sys_env_destroy>
}
  800679:	c9                   	leave  
  80067a:	c3                   	ret    
	...

0080067c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80067c:	55                   	push   %ebp
  80067d:	89 e5                	mov    %esp,%ebp
  80067f:	53                   	push   %ebx
  800680:	83 ec 10             	sub    $0x10,%esp
	va_list ap;

	va_start(ap, fmt);
  800683:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800686:	ff 75 0c             	pushl  0xc(%ebp)
  800689:	ff 75 08             	pushl  0x8(%ebp)
  80068c:	ff 35 04 30 80 00    	pushl  0x803004
  800692:	83 ec 08             	sub    $0x8,%esp
  800695:	e8 76 09 00 00       	call   801010 <sys_getenvid>
  80069a:	83 c4 08             	add    $0x8,%esp
  80069d:	50                   	push   %eax
  80069e:	68 cc 21 80 00       	push   $0x8021cc
  8006a3:	e8 b0 00 00 00       	call   800758 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8006a8:	83 c4 18             	add    $0x18,%esp
  8006ab:	53                   	push   %ebx
  8006ac:	ff 75 10             	pushl  0x10(%ebp)
  8006af:	e8 53 00 00 00       	call   800707 <vcprintf>
	cprintf("\n");
  8006b4:	c7 04 24 cb 20 80 00 	movl   $0x8020cb,(%esp)
  8006bb:	e8 98 00 00 00       	call   800758 <cprintf>

	// Cause a breakpoint exception
	while (1)
  8006c0:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  8006c3:	cc                   	int3   
  8006c4:	eb fd                	jmp    8006c3 <_panic+0x47>
	...

008006c8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8006c8:	55                   	push   %ebp
  8006c9:	89 e5                	mov    %esp,%ebp
  8006cb:	53                   	push   %ebx
  8006cc:	83 ec 04             	sub    $0x4,%esp
  8006cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8006d2:	8b 03                	mov    (%ebx),%eax
  8006d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8006d7:	88 54 18 08          	mov    %dl,0x8(%eax,%ebx,1)
  8006db:	40                   	inc    %eax
  8006dc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8006de:	3d ff 00 00 00       	cmp    $0xff,%eax
  8006e3:	75 1a                	jne    8006ff <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8006e5:	83 ec 08             	sub    $0x8,%esp
  8006e8:	68 ff 00 00 00       	push   $0xff
  8006ed:	8d 43 08             	lea    0x8(%ebx),%eax
  8006f0:	50                   	push   %eax
  8006f1:	e8 96 08 00 00       	call   800f8c <sys_cputs>
		b->idx = 0;
  8006f6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8006fc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8006ff:	ff 43 04             	incl   0x4(%ebx)
}
  800702:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800705:	c9                   	leave  
  800706:	c3                   	ret    

00800707 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800707:	55                   	push   %ebp
  800708:	89 e5                	mov    %esp,%ebp
  80070a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800710:	c7 85 e8 fe ff ff 00 	movl   $0x0,-0x118(%ebp)
  800717:	00 00 00 
	b.cnt = 0;
  80071a:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  800721:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800724:	ff 75 0c             	pushl  0xc(%ebp)
  800727:	ff 75 08             	pushl  0x8(%ebp)
  80072a:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800730:	50                   	push   %eax
  800731:	68 c8 06 80 00       	push   $0x8006c8
  800736:	e8 49 01 00 00       	call   800884 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80073b:	83 c4 08             	add    $0x8,%esp
  80073e:	ff b5 e8 fe ff ff    	pushl  -0x118(%ebp)
  800744:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80074a:	50                   	push   %eax
  80074b:	e8 3c 08 00 00       	call   800f8c <sys_cputs>

	return b.cnt;
  800750:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
}
  800756:	c9                   	leave  
  800757:	c3                   	ret    

00800758 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80075e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800761:	50                   	push   %eax
  800762:	ff 75 08             	pushl  0x8(%ebp)
  800765:	e8 9d ff ff ff       	call   800707 <vcprintf>
	va_end(ap);

	return cnt;
}
  80076a:	c9                   	leave  
  80076b:	c3                   	ret    

0080076c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
  80076f:	57                   	push   %edi
  800770:	56                   	push   %esi
  800771:	53                   	push   %ebx
  800772:	83 ec 0c             	sub    $0xc,%esp
  800775:	8b 75 10             	mov    0x10(%ebp),%esi
  800778:	8b 7d 14             	mov    0x14(%ebp),%edi
  80077b:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80077e:	8b 45 18             	mov    0x18(%ebp),%eax
  800781:	ba 00 00 00 00       	mov    $0x0,%edx
  800786:	39 fa                	cmp    %edi,%edx
  800788:	77 39                	ja     8007c3 <printnum+0x57>
  80078a:	72 04                	jb     800790 <printnum+0x24>
  80078c:	39 f0                	cmp    %esi,%eax
  80078e:	77 33                	ja     8007c3 <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800790:	83 ec 04             	sub    $0x4,%esp
  800793:	ff 75 20             	pushl  0x20(%ebp)
  800796:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800799:	50                   	push   %eax
  80079a:	ff 75 18             	pushl  0x18(%ebp)
  80079d:	8b 45 18             	mov    0x18(%ebp),%eax
  8007a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a5:	52                   	push   %edx
  8007a6:	50                   	push   %eax
  8007a7:	57                   	push   %edi
  8007a8:	56                   	push   %esi
  8007a9:	e8 92 13 00 00       	call   801b40 <__udivdi3>
  8007ae:	83 c4 10             	add    $0x10,%esp
  8007b1:	52                   	push   %edx
  8007b2:	50                   	push   %eax
  8007b3:	ff 75 0c             	pushl  0xc(%ebp)
  8007b6:	ff 75 08             	pushl  0x8(%ebp)
  8007b9:	e8 ae ff ff ff       	call   80076c <printnum>
  8007be:	83 c4 20             	add    $0x20,%esp
  8007c1:	eb 19                	jmp    8007dc <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007c3:	4b                   	dec    %ebx
  8007c4:	85 db                	test   %ebx,%ebx
  8007c6:	7e 14                	jle    8007dc <printnum+0x70>
  8007c8:	83 ec 08             	sub    $0x8,%esp
  8007cb:	ff 75 0c             	pushl  0xc(%ebp)
  8007ce:	ff 75 20             	pushl  0x20(%ebp)
  8007d1:	ff 55 08             	call   *0x8(%ebp)
  8007d4:	83 c4 10             	add    $0x10,%esp
  8007d7:	4b                   	dec    %ebx
  8007d8:	85 db                	test   %ebx,%ebx
  8007da:	7f ec                	jg     8007c8 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	ff 75 0c             	pushl  0xc(%ebp)
  8007e2:	8b 45 18             	mov    0x18(%ebp),%eax
  8007e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ea:	83 ec 04             	sub    $0x4,%esp
  8007ed:	52                   	push   %edx
  8007ee:	50                   	push   %eax
  8007ef:	57                   	push   %edi
  8007f0:	56                   	push   %esi
  8007f1:	e8 56 14 00 00       	call   801c4c <__umoddi3>
  8007f6:	83 c4 14             	add    $0x14,%esp
  8007f9:	0f be 80 01 23 80 00 	movsbl 0x802301(%eax),%eax
  800800:	50                   	push   %eax
  800801:	ff 55 08             	call   *0x8(%ebp)
}
  800804:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800807:	5b                   	pop    %ebx
  800808:	5e                   	pop    %esi
  800809:	5f                   	pop    %edi
  80080a:	c9                   	leave  
  80080b:	c3                   	ret    

0080080c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80080c:	55                   	push   %ebp
  80080d:	89 e5                	mov    %esp,%ebp
  80080f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800812:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800815:	83 f8 01             	cmp    $0x1,%eax
  800818:	7e 0e                	jle    800828 <getuint+0x1c>
		return va_arg(*ap, unsigned long long);
  80081a:	8b 11                	mov    (%ecx),%edx
  80081c:	8d 42 08             	lea    0x8(%edx),%eax
  80081f:	89 01                	mov    %eax,(%ecx)
  800821:	8b 02                	mov    (%edx),%eax
  800823:	8b 52 04             	mov    0x4(%edx),%edx
  800826:	eb 22                	jmp    80084a <getuint+0x3e>
	else if (lflag)
  800828:	85 c0                	test   %eax,%eax
  80082a:	74 10                	je     80083c <getuint+0x30>
		return va_arg(*ap, unsigned long);
  80082c:	8b 11                	mov    (%ecx),%edx
  80082e:	8d 42 04             	lea    0x4(%edx),%eax
  800831:	89 01                	mov    %eax,(%ecx)
  800833:	8b 02                	mov    (%edx),%eax
  800835:	ba 00 00 00 00       	mov    $0x0,%edx
  80083a:	eb 0e                	jmp    80084a <getuint+0x3e>
	else
		return va_arg(*ap, unsigned int);
  80083c:	8b 11                	mov    (%ecx),%edx
  80083e:	8d 42 04             	lea    0x4(%edx),%eax
  800841:	89 01                	mov    %eax,(%ecx)
  800843:	8b 02                	mov    (%edx),%eax
  800845:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80084a:	c9                   	leave  
  80084b:	c3                   	ret    

0080084c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80084c:	55                   	push   %ebp
  80084d:	89 e5                	mov    %esp,%ebp
  80084f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800852:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800855:	83 f8 01             	cmp    $0x1,%eax
  800858:	7e 0e                	jle    800868 <getint+0x1c>
		return va_arg(*ap, long long);
  80085a:	8b 11                	mov    (%ecx),%edx
  80085c:	8d 42 08             	lea    0x8(%edx),%eax
  80085f:	89 01                	mov    %eax,(%ecx)
  800861:	8b 02                	mov    (%edx),%eax
  800863:	8b 52 04             	mov    0x4(%edx),%edx
  800866:	eb 1a                	jmp    800882 <getint+0x36>
	else if (lflag)
  800868:	85 c0                	test   %eax,%eax
  80086a:	74 0c                	je     800878 <getint+0x2c>
		return va_arg(*ap, long);
  80086c:	8b 01                	mov    (%ecx),%eax
  80086e:	8d 50 04             	lea    0x4(%eax),%edx
  800871:	89 11                	mov    %edx,(%ecx)
  800873:	8b 00                	mov    (%eax),%eax
  800875:	99                   	cltd   
  800876:	eb 0a                	jmp    800882 <getint+0x36>
	else
		return va_arg(*ap, int);
  800878:	8b 01                	mov    (%ecx),%eax
  80087a:	8d 50 04             	lea    0x4(%eax),%edx
  80087d:	89 11                	mov    %edx,(%ecx)
  80087f:	8b 00                	mov    (%eax),%eax
  800881:	99                   	cltd   
}
  800882:	c9                   	leave  
  800883:	c3                   	ret    

00800884 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	57                   	push   %edi
  800888:	56                   	push   %esi
  800889:	53                   	push   %ebx
  80088a:	83 ec 1c             	sub    $0x1c,%esp
  80088d:	8b 5d 10             	mov    0x10(%ebp),%ebx

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
			putch(ch, putdat);
  800890:	0f b6 0b             	movzbl (%ebx),%ecx
  800893:	43                   	inc    %ebx
  800894:	83 f9 25             	cmp    $0x25,%ecx
  800897:	74 1e                	je     8008b7 <vprintfmt+0x33>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800899:	85 c9                	test   %ecx,%ecx
  80089b:	0f 84 dc 02 00 00    	je     800b7d <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  8008a1:	83 ec 08             	sub    $0x8,%esp
  8008a4:	ff 75 0c             	pushl  0xc(%ebp)
  8008a7:	51                   	push   %ecx
  8008a8:	ff 55 08             	call   *0x8(%ebp)
  8008ab:	83 c4 10             	add    $0x10,%esp
  8008ae:	0f b6 0b             	movzbl (%ebx),%ecx
  8008b1:	43                   	inc    %ebx
  8008b2:	83 f9 25             	cmp    $0x25,%ecx
  8008b5:	75 e2                	jne    800899 <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  8008b7:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
		width = -1;
  8008bb:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
		precision = -1;
  8008c2:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  8008c7:	bf 00 00 00 00       	mov    $0x0,%edi
		altflag = 0;
  8008cc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d3:	0f b6 0b             	movzbl (%ebx),%ecx
  8008d6:	8d 41 dd             	lea    -0x23(%ecx),%eax
  8008d9:	43                   	inc    %ebx
  8008da:	83 f8 55             	cmp    $0x55,%eax
  8008dd:	0f 87 75 02 00 00    	ja     800b58 <vprintfmt+0x2d4>
  8008e3:	ff 24 85 a0 23 80 00 	jmp    *0x8023a0(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  8008ea:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
			goto reswitch;
  8008ee:	eb e3                	jmp    8008d3 <vprintfmt+0x4f>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8008f0:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
			goto reswitch;
  8008f4:	eb dd                	jmp    8008d3 <vprintfmt+0x4f>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008f6:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  8008fb:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  8008fe:	8d 74 41 d0          	lea    -0x30(%ecx,%eax,2),%esi
				ch = *fmt;
  800902:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  800905:	8d 41 d0             	lea    -0x30(%ecx),%eax
  800908:	83 f8 09             	cmp    $0x9,%eax
  80090b:	77 28                	ja     800935 <vprintfmt+0xb1>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80090d:	43                   	inc    %ebx
  80090e:	eb eb                	jmp    8008fb <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800910:	8b 55 14             	mov    0x14(%ebp),%edx
  800913:	8d 42 04             	lea    0x4(%edx),%eax
  800916:	89 45 14             	mov    %eax,0x14(%ebp)
  800919:	8b 32                	mov    (%edx),%esi
			goto process_precision;
  80091b:	eb 18                	jmp    800935 <vprintfmt+0xb1>

		case '.':
			if (width < 0)
  80091d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800921:	79 b0                	jns    8008d3 <vprintfmt+0x4f>
				width = 0;
  800923:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
			goto reswitch;
  80092a:	eb a7                	jmp    8008d3 <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  80092c:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
			goto reswitch;
  800933:	eb 9e                	jmp    8008d3 <vprintfmt+0x4f>

		process_precision:
			if (width < 0)
  800935:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800939:	79 98                	jns    8008d3 <vprintfmt+0x4f>
				width = precision, precision = -1;
  80093b:	89 75 f0             	mov    %esi,-0x10(%ebp)
  80093e:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  800943:	eb 8e                	jmp    8008d3 <vprintfmt+0x4f>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800945:	47                   	inc    %edi
			goto reswitch;
  800946:	eb 8b                	jmp    8008d3 <vprintfmt+0x4f>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800948:	83 ec 08             	sub    $0x8,%esp
  80094b:	ff 75 0c             	pushl  0xc(%ebp)
  80094e:	8b 55 14             	mov    0x14(%ebp),%edx
  800951:	8d 42 04             	lea    0x4(%edx),%eax
  800954:	89 45 14             	mov    %eax,0x14(%ebp)
  800957:	ff 32                	pushl  (%edx)
  800959:	ff 55 08             	call   *0x8(%ebp)
			break;
  80095c:	83 c4 10             	add    $0x10,%esp
  80095f:	e9 2c ff ff ff       	jmp    800890 <vprintfmt+0xc>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800964:	8b 55 14             	mov    0x14(%ebp),%edx
  800967:	8d 42 04             	lea    0x4(%edx),%eax
  80096a:	89 45 14             	mov    %eax,0x14(%ebp)
  80096d:	8b 02                	mov    (%edx),%eax
			if (err < 0)
  80096f:	85 c0                	test   %eax,%eax
  800971:	79 02                	jns    800975 <vprintfmt+0xf1>
				err = -err;
  800973:	f7 d8                	neg    %eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800975:	83 f8 0f             	cmp    $0xf,%eax
  800978:	7f 0b                	jg     800985 <vprintfmt+0x101>
  80097a:	8b 3c 85 60 23 80 00 	mov    0x802360(,%eax,4),%edi
  800981:	85 ff                	test   %edi,%edi
  800983:	75 19                	jne    80099e <vprintfmt+0x11a>
				printfmt(putch, putdat, "error %d", err);
  800985:	50                   	push   %eax
  800986:	68 12 23 80 00       	push   $0x802312
  80098b:	ff 75 0c             	pushl  0xc(%ebp)
  80098e:	ff 75 08             	pushl  0x8(%ebp)
  800991:	e8 ef 01 00 00       	call   800b85 <printfmt>
  800996:	83 c4 10             	add    $0x10,%esp
  800999:	e9 f2 fe ff ff       	jmp    800890 <vprintfmt+0xc>
			else
				printfmt(putch, putdat, "%s", p);
  80099e:	57                   	push   %edi
  80099f:	68 1b 23 80 00       	push   $0x80231b
  8009a4:	ff 75 0c             	pushl  0xc(%ebp)
  8009a7:	ff 75 08             	pushl  0x8(%ebp)
  8009aa:	e8 d6 01 00 00       	call   800b85 <printfmt>
  8009af:	83 c4 10             	add    $0x10,%esp
			break;
  8009b2:	e9 d9 fe ff ff       	jmp    800890 <vprintfmt+0xc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8009b7:	8b 55 14             	mov    0x14(%ebp),%edx
  8009ba:	8d 42 04             	lea    0x4(%edx),%eax
  8009bd:	89 45 14             	mov    %eax,0x14(%ebp)
  8009c0:	8b 3a                	mov    (%edx),%edi
  8009c2:	85 ff                	test   %edi,%edi
  8009c4:	75 05                	jne    8009cb <vprintfmt+0x147>
				p = "(null)";
  8009c6:	bf 1e 23 80 00       	mov    $0x80231e,%edi
			if (width > 0 && padc != '-')
  8009cb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8009cf:	7e 3b                	jle    800a0c <vprintfmt+0x188>
  8009d1:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  8009d5:	74 35                	je     800a0c <vprintfmt+0x188>
				for (width -= strnlen(p, precision); width > 0; width--)
  8009d7:	83 ec 08             	sub    $0x8,%esp
  8009da:	56                   	push   %esi
  8009db:	57                   	push   %edi
  8009dc:	e8 58 02 00 00       	call   800c39 <strnlen>
  8009e1:	29 45 f0             	sub    %eax,-0x10(%ebp)
  8009e4:	83 c4 10             	add    $0x10,%esp
  8009e7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8009eb:	7e 1f                	jle    800a0c <vprintfmt+0x188>
  8009ed:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  8009f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
					putch(padc, putdat);
  8009f4:	83 ec 08             	sub    $0x8,%esp
  8009f7:	ff 75 0c             	pushl  0xc(%ebp)
  8009fa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8009fd:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a00:	83 c4 10             	add    $0x10,%esp
  800a03:	ff 4d f0             	decl   -0x10(%ebp)
  800a06:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800a0a:	7f e8                	jg     8009f4 <vprintfmt+0x170>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a0c:	0f be 0f             	movsbl (%edi),%ecx
  800a0f:	47                   	inc    %edi
  800a10:	85 c9                	test   %ecx,%ecx
  800a12:	74 44                	je     800a58 <vprintfmt+0x1d4>
  800a14:	85 f6                	test   %esi,%esi
  800a16:	78 03                	js     800a1b <vprintfmt+0x197>
  800a18:	4e                   	dec    %esi
  800a19:	78 3d                	js     800a58 <vprintfmt+0x1d4>
				if (altflag && (ch < ' ' || ch > '~'))
  800a1b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  800a1f:	74 18                	je     800a39 <vprintfmt+0x1b5>
  800a21:	8d 41 e0             	lea    -0x20(%ecx),%eax
  800a24:	83 f8 5e             	cmp    $0x5e,%eax
  800a27:	76 10                	jbe    800a39 <vprintfmt+0x1b5>
					putch('?', putdat);
  800a29:	83 ec 08             	sub    $0x8,%esp
  800a2c:	ff 75 0c             	pushl  0xc(%ebp)
  800a2f:	6a 3f                	push   $0x3f
  800a31:	ff 55 08             	call   *0x8(%ebp)
  800a34:	83 c4 10             	add    $0x10,%esp
  800a37:	eb 0d                	jmp    800a46 <vprintfmt+0x1c2>
				else
					putch(ch, putdat);
  800a39:	83 ec 08             	sub    $0x8,%esp
  800a3c:	ff 75 0c             	pushl  0xc(%ebp)
  800a3f:	51                   	push   %ecx
  800a40:	ff 55 08             	call   *0x8(%ebp)
  800a43:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a46:	ff 4d f0             	decl   -0x10(%ebp)
  800a49:	0f be 0f             	movsbl (%edi),%ecx
  800a4c:	47                   	inc    %edi
  800a4d:	85 c9                	test   %ecx,%ecx
  800a4f:	74 07                	je     800a58 <vprintfmt+0x1d4>
  800a51:	85 f6                	test   %esi,%esi
  800a53:	78 c6                	js     800a1b <vprintfmt+0x197>
  800a55:	4e                   	dec    %esi
  800a56:	79 c3                	jns    800a1b <vprintfmt+0x197>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a58:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800a5c:	0f 8e 2e fe ff ff    	jle    800890 <vprintfmt+0xc>
				putch(' ', putdat);
  800a62:	83 ec 08             	sub    $0x8,%esp
  800a65:	ff 75 0c             	pushl  0xc(%ebp)
  800a68:	6a 20                	push   $0x20
  800a6a:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a6d:	83 c4 10             	add    $0x10,%esp
  800a70:	ff 4d f0             	decl   -0x10(%ebp)
  800a73:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800a77:	7f e9                	jg     800a62 <vprintfmt+0x1de>
				putch(' ', putdat);
			break;
  800a79:	e9 12 fe ff ff       	jmp    800890 <vprintfmt+0xc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800a7e:	57                   	push   %edi
  800a7f:	8d 45 14             	lea    0x14(%ebp),%eax
  800a82:	50                   	push   %eax
  800a83:	e8 c4 fd ff ff       	call   80084c <getint>
  800a88:	89 c6                	mov    %eax,%esi
  800a8a:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800a8c:	83 c4 08             	add    $0x8,%esp
  800a8f:	85 d2                	test   %edx,%edx
  800a91:	79 15                	jns    800aa8 <vprintfmt+0x224>
				putch('-', putdat);
  800a93:	83 ec 08             	sub    $0x8,%esp
  800a96:	ff 75 0c             	pushl  0xc(%ebp)
  800a99:	6a 2d                	push   $0x2d
  800a9b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800a9e:	f7 de                	neg    %esi
  800aa0:	83 d7 00             	adc    $0x0,%edi
  800aa3:	f7 df                	neg    %edi
  800aa5:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800aa8:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  800aad:	eb 76                	jmp    800b25 <vprintfmt+0x2a1>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800aaf:	57                   	push   %edi
  800ab0:	8d 45 14             	lea    0x14(%ebp),%eax
  800ab3:	50                   	push   %eax
  800ab4:	e8 53 fd ff ff       	call   80080c <getuint>
  800ab9:	89 c6                	mov    %eax,%esi
  800abb:	89 d7                	mov    %edx,%edi
			base = 10;
  800abd:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  800ac2:	83 c4 08             	add    $0x8,%esp
  800ac5:	eb 5e                	jmp    800b25 <vprintfmt+0x2a1>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800ac7:	57                   	push   %edi
  800ac8:	8d 45 14             	lea    0x14(%ebp),%eax
  800acb:	50                   	push   %eax
  800acc:	e8 3b fd ff ff       	call   80080c <getuint>
  800ad1:	89 c6                	mov    %eax,%esi
  800ad3:	89 d7                	mov    %edx,%edi
			base = 8;
  800ad5:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  800ada:	83 c4 08             	add    $0x8,%esp
  800add:	eb 46                	jmp    800b25 <vprintfmt+0x2a1>

		// pointer
		case 'p':
			putch('0', putdat);
  800adf:	83 ec 08             	sub    $0x8,%esp
  800ae2:	ff 75 0c             	pushl  0xc(%ebp)
  800ae5:	6a 30                	push   $0x30
  800ae7:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800aea:	83 c4 08             	add    $0x8,%esp
  800aed:	ff 75 0c             	pushl  0xc(%ebp)
  800af0:	6a 78                	push   $0x78
  800af2:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800af5:	8b 55 14             	mov    0x14(%ebp),%edx
  800af8:	8d 42 04             	lea    0x4(%edx),%eax
  800afb:	89 45 14             	mov    %eax,0x14(%ebp)
  800afe:	8b 32                	mov    (%edx),%esi
  800b00:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b05:	ba 10 00 00 00       	mov    $0x10,%edx
			goto number;
  800b0a:	83 c4 10             	add    $0x10,%esp
  800b0d:	eb 16                	jmp    800b25 <vprintfmt+0x2a1>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b0f:	57                   	push   %edi
  800b10:	8d 45 14             	lea    0x14(%ebp),%eax
  800b13:	50                   	push   %eax
  800b14:	e8 f3 fc ff ff       	call   80080c <getuint>
  800b19:	89 c6                	mov    %eax,%esi
  800b1b:	89 d7                	mov    %edx,%edi
			base = 16;
  800b1d:	ba 10 00 00 00       	mov    $0x10,%edx
  800b22:	83 c4 08             	add    $0x8,%esp
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b25:	83 ec 04             	sub    $0x4,%esp
  800b28:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  800b2c:	50                   	push   %eax
  800b2d:	ff 75 f0             	pushl  -0x10(%ebp)
  800b30:	52                   	push   %edx
  800b31:	57                   	push   %edi
  800b32:	56                   	push   %esi
  800b33:	ff 75 0c             	pushl  0xc(%ebp)
  800b36:	ff 75 08             	pushl  0x8(%ebp)
  800b39:	e8 2e fc ff ff       	call   80076c <printnum>
			break;
  800b3e:	83 c4 20             	add    $0x20,%esp
  800b41:	e9 4a fd ff ff       	jmp    800890 <vprintfmt+0xc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b46:	83 ec 08             	sub    $0x8,%esp
  800b49:	ff 75 0c             	pushl  0xc(%ebp)
  800b4c:	51                   	push   %ecx
  800b4d:	ff 55 08             	call   *0x8(%ebp)
			break;
  800b50:	83 c4 10             	add    $0x10,%esp
  800b53:	e9 38 fd ff ff       	jmp    800890 <vprintfmt+0xc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b58:	83 ec 08             	sub    $0x8,%esp
  800b5b:	ff 75 0c             	pushl  0xc(%ebp)
  800b5e:	6a 25                	push   $0x25
  800b60:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b63:	4b                   	dec    %ebx
  800b64:	83 c4 10             	add    $0x10,%esp
  800b67:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800b6b:	0f 84 1f fd ff ff    	je     800890 <vprintfmt+0xc>
  800b71:	4b                   	dec    %ebx
  800b72:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800b76:	75 f9                	jne    800b71 <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  800b78:	e9 13 fd ff ff       	jmp    800890 <vprintfmt+0xc>
		}
	}
}
  800b7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5f                   	pop    %edi
  800b83:	c9                   	leave  
  800b84:	c3                   	ret    

00800b85 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800b8b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800b8e:	50                   	push   %eax
  800b8f:	ff 75 10             	pushl  0x10(%ebp)
  800b92:	ff 75 0c             	pushl  0xc(%ebp)
  800b95:	ff 75 08             	pushl  0x8(%ebp)
  800b98:	e8 e7 fc ff ff       	call   800884 <vprintfmt>
	va_end(ap);
}
  800b9d:	c9                   	leave  
  800b9e:	c3                   	ret    

00800b9f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  800ba5:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  800ba8:	8b 0a                	mov    (%edx),%ecx
  800baa:	3b 4a 04             	cmp    0x4(%edx),%ecx
  800bad:	73 07                	jae    800bb6 <sprintputch+0x17>
		*b->buf++ = ch;
  800baf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb2:	88 01                	mov    %al,(%ecx)
  800bb4:	ff 02                	incl   (%edx)
}
  800bb6:	c9                   	leave  
  800bb7:	c3                   	ret    

00800bb8 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	83 ec 18             	sub    $0x18,%esp
  800bbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bc4:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800bc7:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
  800bcb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bce:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

	if (buf == NULL || n < 1)
  800bd5:	85 d2                	test   %edx,%edx
  800bd7:	74 04                	je     800bdd <vsnprintf+0x25>
  800bd9:	85 c9                	test   %ecx,%ecx
  800bdb:	7f 07                	jg     800be4 <vsnprintf+0x2c>
		return -E_INVAL;
  800bdd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800be2:	eb 1d                	jmp    800c01 <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800be4:	ff 75 14             	pushl  0x14(%ebp)
  800be7:	ff 75 10             	pushl  0x10(%ebp)
  800bea:	8d 45 e8             	lea    -0x18(%ebp),%eax
  800bed:	50                   	push   %eax
  800bee:	68 9f 0b 80 00       	push   $0x800b9f
  800bf3:	e8 8c fc ff ff       	call   800884 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bf8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800bfb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800c01:	c9                   	leave  
  800c02:	c3                   	ret    

00800c03 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c09:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c0c:	50                   	push   %eax
  800c0d:	ff 75 10             	pushl  0x10(%ebp)
  800c10:	ff 75 0c             	pushl  0xc(%ebp)
  800c13:	ff 75 08             	pushl  0x8(%ebp)
  800c16:	e8 9d ff ff ff       	call   800bb8 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c1b:	c9                   	leave  
  800c1c:	c3                   	ret    
  800c1d:	00 00                	add    %al,(%eax)
	...

00800c20 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c26:	b8 00 00 00 00       	mov    $0x0,%eax
  800c2b:	80 3a 00             	cmpb   $0x0,(%edx)
  800c2e:	74 07                	je     800c37 <strlen+0x17>
		n++;
  800c30:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c31:	42                   	inc    %edx
  800c32:	80 3a 00             	cmpb   $0x0,(%edx)
  800c35:	75 f9                	jne    800c30 <strlen+0x10>
		n++;
	return n;
}
  800c37:	c9                   	leave  
  800c38:	c3                   	ret    

00800c39 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c3f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c42:	b8 00 00 00 00       	mov    $0x0,%eax
  800c47:	85 d2                	test   %edx,%edx
  800c49:	74 0f                	je     800c5a <strnlen+0x21>
  800c4b:	80 39 00             	cmpb   $0x0,(%ecx)
  800c4e:	74 0a                	je     800c5a <strnlen+0x21>
		n++;
  800c50:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c51:	41                   	inc    %ecx
  800c52:	4a                   	dec    %edx
  800c53:	74 05                	je     800c5a <strnlen+0x21>
  800c55:	80 39 00             	cmpb   $0x0,(%ecx)
  800c58:	75 f6                	jne    800c50 <strnlen+0x17>
		n++;
	return n;
}
  800c5a:	c9                   	leave  
  800c5b:	c3                   	ret    

00800c5c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	53                   	push   %ebx
  800c60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c63:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  800c66:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  800c68:	8a 02                	mov    (%edx),%al
  800c6a:	42                   	inc    %edx
  800c6b:	88 01                	mov    %al,(%ecx)
  800c6d:	41                   	inc    %ecx
  800c6e:	84 c0                	test   %al,%al
  800c70:	75 f6                	jne    800c68 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800c72:	89 d8                	mov    %ebx,%eax
  800c74:	5b                   	pop    %ebx
  800c75:	c9                   	leave  
  800c76:	c3                   	ret    

00800c77 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c77:	55                   	push   %ebp
  800c78:	89 e5                	mov    %esp,%ebp
  800c7a:	53                   	push   %ebx
  800c7b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c7e:	53                   	push   %ebx
  800c7f:	e8 9c ff ff ff       	call   800c20 <strlen>
	strcpy(dst + len, src);
  800c84:	ff 75 0c             	pushl  0xc(%ebp)
  800c87:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800c8a:	50                   	push   %eax
  800c8b:	e8 cc ff ff ff       	call   800c5c <strcpy>
	return dst;
}
  800c90:	89 d8                	mov    %ebx,%eax
  800c92:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c95:	c9                   	leave  
  800c96:	c3                   	ret    

00800c97 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	57                   	push   %edi
  800c9b:	56                   	push   %esi
  800c9c:	53                   	push   %ebx
  800c9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ca0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ca3:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  800ca6:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  800ca8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cad:	39 f3                	cmp    %esi,%ebx
  800caf:	73 10                	jae    800cc1 <strncpy+0x2a>
		*dst++ = *src;
  800cb1:	8a 02                	mov    (%edx),%al
  800cb3:	88 01                	mov    %al,(%ecx)
  800cb5:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800cb6:	80 3a 01             	cmpb   $0x1,(%edx)
  800cb9:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cbc:	43                   	inc    %ebx
  800cbd:	39 f3                	cmp    %esi,%ebx
  800cbf:	72 f0                	jb     800cb1 <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800cc1:	89 f8                	mov    %edi,%eax
  800cc3:	5b                   	pop    %ebx
  800cc4:	5e                   	pop    %esi
  800cc5:	5f                   	pop    %edi
  800cc6:	c9                   	leave  
  800cc7:	c3                   	ret    

00800cc8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	56                   	push   %esi
  800ccc:	53                   	push   %ebx
  800ccd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800cd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd3:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  800cd6:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  800cd8:	85 d2                	test   %edx,%edx
  800cda:	74 19                	je     800cf5 <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800cdc:	4a                   	dec    %edx
  800cdd:	74 13                	je     800cf2 <strlcpy+0x2a>
  800cdf:	80 39 00             	cmpb   $0x0,(%ecx)
  800ce2:	74 0e                	je     800cf2 <strlcpy+0x2a>
  800ce4:	8a 01                	mov    (%ecx),%al
  800ce6:	41                   	inc    %ecx
  800ce7:	88 03                	mov    %al,(%ebx)
  800ce9:	43                   	inc    %ebx
  800cea:	4a                   	dec    %edx
  800ceb:	74 05                	je     800cf2 <strlcpy+0x2a>
  800ced:	80 39 00             	cmpb   $0x0,(%ecx)
  800cf0:	75 f2                	jne    800ce4 <strlcpy+0x1c>
		*dst = '\0';
  800cf2:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  800cf5:	89 d8                	mov    %ebx,%eax
  800cf7:	29 f0                	sub    %esi,%eax
}
  800cf9:	5b                   	pop    %ebx
  800cfa:	5e                   	pop    %esi
  800cfb:	c9                   	leave  
  800cfc:	c3                   	ret    

00800cfd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800cfd:	55                   	push   %ebp
  800cfe:	89 e5                	mov    %esp,%ebp
  800d00:	8b 55 08             	mov    0x8(%ebp),%edx
  800d03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
		p++, q++;
  800d06:	80 3a 00             	cmpb   $0x0,(%edx)
  800d09:	74 13                	je     800d1e <strcmp+0x21>
  800d0b:	8a 02                	mov    (%edx),%al
  800d0d:	3a 01                	cmp    (%ecx),%al
  800d0f:	75 0d                	jne    800d1e <strcmp+0x21>
  800d11:	42                   	inc    %edx
  800d12:	41                   	inc    %ecx
  800d13:	80 3a 00             	cmpb   $0x0,(%edx)
  800d16:	74 06                	je     800d1e <strcmp+0x21>
  800d18:	8a 02                	mov    (%edx),%al
  800d1a:	3a 01                	cmp    (%ecx),%al
  800d1c:	74 f3                	je     800d11 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d1e:	0f b6 02             	movzbl (%edx),%eax
  800d21:	0f b6 11             	movzbl (%ecx),%edx
  800d24:	29 d0                	sub    %edx,%eax
}
  800d26:	c9                   	leave  
  800d27:	c3                   	ret    

00800d28 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	53                   	push   %ebx
  800d2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d32:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800d35:	85 c9                	test   %ecx,%ecx
  800d37:	74 1f                	je     800d58 <strncmp+0x30>
  800d39:	80 3a 00             	cmpb   $0x0,(%edx)
  800d3c:	74 16                	je     800d54 <strncmp+0x2c>
  800d3e:	8a 02                	mov    (%edx),%al
  800d40:	3a 03                	cmp    (%ebx),%al
  800d42:	75 10                	jne    800d54 <strncmp+0x2c>
  800d44:	42                   	inc    %edx
  800d45:	43                   	inc    %ebx
  800d46:	49                   	dec    %ecx
  800d47:	74 0f                	je     800d58 <strncmp+0x30>
  800d49:	80 3a 00             	cmpb   $0x0,(%edx)
  800d4c:	74 06                	je     800d54 <strncmp+0x2c>
  800d4e:	8a 02                	mov    (%edx),%al
  800d50:	3a 03                	cmp    (%ebx),%al
  800d52:	74 f0                	je     800d44 <strncmp+0x1c>
	if (n == 0)
  800d54:	85 c9                	test   %ecx,%ecx
  800d56:	75 07                	jne    800d5f <strncmp+0x37>
		return 0;
  800d58:	b8 00 00 00 00       	mov    $0x0,%eax
  800d5d:	eb 0a                	jmp    800d69 <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d5f:	0f b6 12             	movzbl (%edx),%edx
  800d62:	0f b6 03             	movzbl (%ebx),%eax
  800d65:	29 c2                	sub    %eax,%edx
  800d67:	89 d0                	mov    %edx,%eax
}
  800d69:	5b                   	pop    %ebx
  800d6a:	c9                   	leave  
  800d6b:	c3                   	ret    

00800d6c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d72:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800d75:	80 38 00             	cmpb   $0x0,(%eax)
  800d78:	74 0a                	je     800d84 <strchr+0x18>
		if (*s == c)
  800d7a:	38 10                	cmp    %dl,(%eax)
  800d7c:	74 0b                	je     800d89 <strchr+0x1d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d7e:	40                   	inc    %eax
  800d7f:	80 38 00             	cmpb   $0x0,(%eax)
  800d82:	75 f6                	jne    800d7a <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800d84:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d89:	c9                   	leave  
  800d8a:	c3                   	ret    

00800d8b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d91:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800d94:	80 38 00             	cmpb   $0x0,(%eax)
  800d97:	74 0a                	je     800da3 <strfind+0x18>
		if (*s == c)
  800d99:	38 10                	cmp    %dl,(%eax)
  800d9b:	74 06                	je     800da3 <strfind+0x18>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d9d:	40                   	inc    %eax
  800d9e:	80 38 00             	cmpb   $0x0,(%eax)
  800da1:	75 f6                	jne    800d99 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
}
  800da3:	c9                   	leave  
  800da4:	c3                   	ret    

00800da5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	57                   	push   %edi
  800da9:	8b 7d 08             	mov    0x8(%ebp),%edi
  800dac:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
		return v;
  800daf:	89 f8                	mov    %edi,%eax
void *
memset(void *v, int c, size_t n)
{
	char *p;

	if (n == 0)
  800db1:	85 c9                	test   %ecx,%ecx
  800db3:	74 40                	je     800df5 <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800db5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800dbb:	75 30                	jne    800ded <memset+0x48>
  800dbd:	f6 c1 03             	test   $0x3,%cl
  800dc0:	75 2b                	jne    800ded <memset+0x48>
		c &= 0xFF;
  800dc2:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800dc9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dcc:	c1 e0 18             	shl    $0x18,%eax
  800dcf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dd2:	c1 e2 10             	shl    $0x10,%edx
  800dd5:	09 d0                	or     %edx,%eax
  800dd7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dda:	c1 e2 08             	shl    $0x8,%edx
  800ddd:	09 d0                	or     %edx,%eax
  800ddf:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  800de2:	c1 e9 02             	shr    $0x2,%ecx
  800de5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de8:	fc                   	cld    
  800de9:	f3 ab                	rep stos %eax,%es:(%edi)
  800deb:	eb 06                	jmp    800df3 <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ded:	8b 45 0c             	mov    0xc(%ebp),%eax
  800df0:	fc                   	cld    
  800df1:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800df3:	89 f8                	mov    %edi,%eax
}
  800df5:	5f                   	pop    %edi
  800df6:	c9                   	leave  
  800df7:	c3                   	ret    

00800df8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800df8:	55                   	push   %ebp
  800df9:	89 e5                	mov    %esp,%ebp
  800dfb:	57                   	push   %edi
  800dfc:	56                   	push   %esi
  800dfd:	8b 45 08             	mov    0x8(%ebp),%eax
  800e00:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800e03:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800e06:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800e08:	39 c6                	cmp    %eax,%esi
  800e0a:	73 34                	jae    800e40 <memmove+0x48>
  800e0c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e0f:	39 c2                	cmp    %eax,%edx
  800e11:	76 2d                	jbe    800e40 <memmove+0x48>
		s += n;
  800e13:	89 d6                	mov    %edx,%esi
		d += n;
  800e15:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e18:	f6 c2 03             	test   $0x3,%dl
  800e1b:	75 1b                	jne    800e38 <memmove+0x40>
  800e1d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e23:	75 13                	jne    800e38 <memmove+0x40>
  800e25:	f6 c1 03             	test   $0x3,%cl
  800e28:	75 0e                	jne    800e38 <memmove+0x40>
			asm volatile("std; rep movsl\n"
  800e2a:	83 ef 04             	sub    $0x4,%edi
  800e2d:	83 ee 04             	sub    $0x4,%esi
  800e30:	c1 e9 02             	shr    $0x2,%ecx
  800e33:	fd                   	std    
  800e34:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e36:	eb 05                	jmp    800e3d <memmove+0x45>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e38:	4f                   	dec    %edi
  800e39:	4e                   	dec    %esi
  800e3a:	fd                   	std    
  800e3b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e3d:	fc                   	cld    
  800e3e:	eb 20                	jmp    800e60 <memmove+0x68>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e40:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e46:	75 15                	jne    800e5d <memmove+0x65>
  800e48:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e4e:	75 0d                	jne    800e5d <memmove+0x65>
  800e50:	f6 c1 03             	test   $0x3,%cl
  800e53:	75 08                	jne    800e5d <memmove+0x65>
			asm volatile("cld; rep movsl\n"
  800e55:	c1 e9 02             	shr    $0x2,%ecx
  800e58:	fc                   	cld    
  800e59:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e5b:	eb 03                	jmp    800e60 <memmove+0x68>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e5d:	fc                   	cld    
  800e5e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e60:	5e                   	pop    %esi
  800e61:	5f                   	pop    %edi
  800e62:	c9                   	leave  
  800e63:	c3                   	ret    

00800e64 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800e64:	55                   	push   %ebp
  800e65:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800e67:	ff 75 10             	pushl  0x10(%ebp)
  800e6a:	ff 75 0c             	pushl  0xc(%ebp)
  800e6d:	ff 75 08             	pushl  0x8(%ebp)
  800e70:	e8 83 ff ff ff       	call   800df8 <memmove>
}
  800e75:	c9                   	leave  
  800e76:	c3                   	ret    

00800e77 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e77:	55                   	push   %ebp
  800e78:	89 e5                	mov    %esp,%ebp
  800e7a:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
  800e7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  800e7e:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800e81:	8b 55 10             	mov    0x10(%ebp),%edx
  800e84:	4a                   	dec    %edx
  800e85:	83 fa ff             	cmp    $0xffffffff,%edx
  800e88:	74 1a                	je     800ea4 <memcmp+0x2d>
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  800e8a:	8a 01                	mov    (%ecx),%al
  800e8c:	3a 03                	cmp    (%ebx),%al
  800e8e:	74 0c                	je     800e9c <memcmp+0x25>
			return (int) *s1 - (int) *s2;
  800e90:	0f b6 d0             	movzbl %al,%edx
  800e93:	0f b6 03             	movzbl (%ebx),%eax
  800e96:	29 c2                	sub    %eax,%edx
  800e98:	89 d0                	mov    %edx,%eax
  800e9a:	eb 0d                	jmp    800ea9 <memcmp+0x32>
		s1++, s2++;
  800e9c:	41                   	inc    %ecx
  800e9d:	43                   	inc    %ebx
  800e9e:	4a                   	dec    %edx
  800e9f:	83 fa ff             	cmp    $0xffffffff,%edx
  800ea2:	75 e6                	jne    800e8a <memcmp+0x13>
	}

	return 0;
  800ea4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ea9:	5b                   	pop    %ebx
  800eaa:	c9                   	leave  
  800eab:	c3                   	ret    

00800eac <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800eb5:	89 c2                	mov    %eax,%edx
  800eb7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800eba:	39 d0                	cmp    %edx,%eax
  800ebc:	73 09                	jae    800ec7 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ebe:	38 08                	cmp    %cl,(%eax)
  800ec0:	74 05                	je     800ec7 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ec2:	40                   	inc    %eax
  800ec3:	39 d0                	cmp    %edx,%eax
  800ec5:	72 f7                	jb     800ebe <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ec7:	c9                   	leave  
  800ec8:	c3                   	ret    

00800ec9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ec9:	55                   	push   %ebp
  800eca:	89 e5                	mov    %esp,%ebp
  800ecc:	57                   	push   %edi
  800ecd:	56                   	push   %esi
  800ece:	53                   	push   %ebx
  800ecf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ed5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  800ed8:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  800edd:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  800ee2:	80 3a 20             	cmpb   $0x20,(%edx)
  800ee5:	74 05                	je     800eec <strtol+0x23>
  800ee7:	80 3a 09             	cmpb   $0x9,(%edx)
  800eea:	75 0b                	jne    800ef7 <strtol+0x2e>
  800eec:	42                   	inc    %edx
  800eed:	80 3a 20             	cmpb   $0x20,(%edx)
  800ef0:	74 fa                	je     800eec <strtol+0x23>
  800ef2:	80 3a 09             	cmpb   $0x9,(%edx)
  800ef5:	74 f5                	je     800eec <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  800ef7:	80 3a 2b             	cmpb   $0x2b,(%edx)
  800efa:	75 03                	jne    800eff <strtol+0x36>
		s++;
  800efc:	42                   	inc    %edx
  800efd:	eb 0b                	jmp    800f0a <strtol+0x41>
	else if (*s == '-')
  800eff:	80 3a 2d             	cmpb   $0x2d,(%edx)
  800f02:	75 06                	jne    800f0a <strtol+0x41>
		s++, neg = 1;
  800f04:	42                   	inc    %edx
  800f05:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f0a:	85 c9                	test   %ecx,%ecx
  800f0c:	74 05                	je     800f13 <strtol+0x4a>
  800f0e:	83 f9 10             	cmp    $0x10,%ecx
  800f11:	75 15                	jne    800f28 <strtol+0x5f>
  800f13:	80 3a 30             	cmpb   $0x30,(%edx)
  800f16:	75 10                	jne    800f28 <strtol+0x5f>
  800f18:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f1c:	75 0a                	jne    800f28 <strtol+0x5f>
		s += 2, base = 16;
  800f1e:	83 c2 02             	add    $0x2,%edx
  800f21:	b9 10 00 00 00       	mov    $0x10,%ecx
  800f26:	eb 14                	jmp    800f3c <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800f28:	85 c9                	test   %ecx,%ecx
  800f2a:	75 10                	jne    800f3c <strtol+0x73>
  800f2c:	80 3a 30             	cmpb   $0x30,(%edx)
  800f2f:	75 05                	jne    800f36 <strtol+0x6d>
		s++, base = 8;
  800f31:	42                   	inc    %edx
  800f32:	b1 08                	mov    $0x8,%cl
  800f34:	eb 06                	jmp    800f3c <strtol+0x73>
	else if (base == 0)
  800f36:	85 c9                	test   %ecx,%ecx
  800f38:	75 02                	jne    800f3c <strtol+0x73>
		base = 10;
  800f3a:	b1 0a                	mov    $0xa,%cl

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f3c:	8a 02                	mov    (%edx),%al
  800f3e:	83 e8 30             	sub    $0x30,%eax
  800f41:	3c 09                	cmp    $0x9,%al
  800f43:	77 08                	ja     800f4d <strtol+0x84>
			dig = *s - '0';
  800f45:	0f be 02             	movsbl (%edx),%eax
  800f48:	83 e8 30             	sub    $0x30,%eax
  800f4b:	eb 20                	jmp    800f6d <strtol+0xa4>
		else if (*s >= 'a' && *s <= 'z')
  800f4d:	8a 02                	mov    (%edx),%al
  800f4f:	83 e8 61             	sub    $0x61,%eax
  800f52:	3c 19                	cmp    $0x19,%al
  800f54:	77 08                	ja     800f5e <strtol+0x95>
			dig = *s - 'a' + 10;
  800f56:	0f be 02             	movsbl (%edx),%eax
  800f59:	83 e8 57             	sub    $0x57,%eax
  800f5c:	eb 0f                	jmp    800f6d <strtol+0xa4>
		else if (*s >= 'A' && *s <= 'Z')
  800f5e:	8a 02                	mov    (%edx),%al
  800f60:	83 e8 41             	sub    $0x41,%eax
  800f63:	3c 19                	cmp    $0x19,%al
  800f65:	77 12                	ja     800f79 <strtol+0xb0>
			dig = *s - 'A' + 10;
  800f67:	0f be 02             	movsbl (%edx),%eax
  800f6a:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  800f6d:	39 c8                	cmp    %ecx,%eax
  800f6f:	7d 08                	jge    800f79 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800f71:	42                   	inc    %edx
  800f72:	0f af d9             	imul   %ecx,%ebx
  800f75:	01 c3                	add    %eax,%ebx
  800f77:	eb c3                	jmp    800f3c <strtol+0x73>
		// we don't properly detect overflow!
	}

	if (endptr)
  800f79:	85 f6                	test   %esi,%esi
  800f7b:	74 02                	je     800f7f <strtol+0xb6>
		*endptr = (char *) s;
  800f7d:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800f7f:	89 d8                	mov    %ebx,%eax
  800f81:	85 ff                	test   %edi,%edi
  800f83:	74 02                	je     800f87 <strtol+0xbe>
  800f85:	f7 d8                	neg    %eax
}
  800f87:	5b                   	pop    %ebx
  800f88:	5e                   	pop    %esi
  800f89:	5f                   	pop    %edi
  800f8a:	c9                   	leave  
  800f8b:	c3                   	ret    

00800f8c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f8c:	55                   	push   %ebp
  800f8d:	89 e5                	mov    %esp,%ebp
  800f8f:	57                   	push   %edi
  800f90:	56                   	push   %esi
  800f91:	53                   	push   %ebx
  800f92:	83 ec 04             	sub    $0x4,%esp
  800f95:	8b 55 08             	mov    0x8(%ebp),%edx
  800f98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800f9b:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa0:	89 f8                	mov    %edi,%eax
  800fa2:	89 fb                	mov    %edi,%ebx
  800fa4:	89 fe                	mov    %edi,%esi
  800fa6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800fa8:	83 c4 04             	add    $0x4,%esp
  800fab:	5b                   	pop    %ebx
  800fac:	5e                   	pop    %esi
  800fad:	5f                   	pop    %edi
  800fae:	c9                   	leave  
  800faf:	c3                   	ret    

00800fb0 <sys_cgetc>:

int
sys_cgetc(void)
{
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
  800fb3:	57                   	push   %edi
  800fb4:	56                   	push   %esi
  800fb5:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800fb6:	b8 01 00 00 00       	mov    $0x1,%eax
  800fbb:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc0:	89 fa                	mov    %edi,%edx
  800fc2:	89 f9                	mov    %edi,%ecx
  800fc4:	89 fb                	mov    %edi,%ebx
  800fc6:	89 fe                	mov    %edi,%esi
  800fc8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fca:	5b                   	pop    %ebx
  800fcb:	5e                   	pop    %esi
  800fcc:	5f                   	pop    %edi
  800fcd:	c9                   	leave  
  800fce:	c3                   	ret    

00800fcf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800fcf:	55                   	push   %ebp
  800fd0:	89 e5                	mov    %esp,%ebp
  800fd2:	57                   	push   %edi
  800fd3:	56                   	push   %esi
  800fd4:	53                   	push   %ebx
  800fd5:	83 ec 0c             	sub    $0xc,%esp
  800fd8:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800fdb:	b8 03 00 00 00       	mov    $0x3,%eax
  800fe0:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe5:	89 f9                	mov    %edi,%ecx
  800fe7:	89 fb                	mov    %edi,%ebx
  800fe9:	89 fe                	mov    %edi,%esi
  800feb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fed:	85 c0                	test   %eax,%eax
  800fef:	7e 17                	jle    801008 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff1:	83 ec 0c             	sub    $0xc,%esp
  800ff4:	50                   	push   %eax
  800ff5:	6a 03                	push   $0x3
  800ff7:	68 f8 24 80 00       	push   $0x8024f8
  800ffc:	6a 23                	push   $0x23
  800ffe:	68 15 25 80 00       	push   $0x802515
  801003:	e8 74 f6 ff ff       	call   80067c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801008:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80100b:	5b                   	pop    %ebx
  80100c:	5e                   	pop    %esi
  80100d:	5f                   	pop    %edi
  80100e:	c9                   	leave  
  80100f:	c3                   	ret    

00801010 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801010:	55                   	push   %ebp
  801011:	89 e5                	mov    %esp,%ebp
  801013:	57                   	push   %edi
  801014:	56                   	push   %esi
  801015:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  801016:	b8 02 00 00 00       	mov    $0x2,%eax
  80101b:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801020:	89 fa                	mov    %edi,%edx
  801022:	89 f9                	mov    %edi,%ecx
  801024:	89 fb                	mov    %edi,%ebx
  801026:	89 fe                	mov    %edi,%esi
  801028:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80102a:	5b                   	pop    %ebx
  80102b:	5e                   	pop    %esi
  80102c:	5f                   	pop    %edi
  80102d:	c9                   	leave  
  80102e:	c3                   	ret    

0080102f <sys_yield>:

void
sys_yield(void)
{
  80102f:	55                   	push   %ebp
  801030:	89 e5                	mov    %esp,%ebp
  801032:	57                   	push   %edi
  801033:	56                   	push   %esi
  801034:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  801035:	b8 0b 00 00 00       	mov    $0xb,%eax
  80103a:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80103f:	89 fa                	mov    %edi,%edx
  801041:	89 f9                	mov    %edi,%ecx
  801043:	89 fb                	mov    %edi,%ebx
  801045:	89 fe                	mov    %edi,%esi
  801047:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801049:	5b                   	pop    %ebx
  80104a:	5e                   	pop    %esi
  80104b:	5f                   	pop    %edi
  80104c:	c9                   	leave  
  80104d:	c3                   	ret    

0080104e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80104e:	55                   	push   %ebp
  80104f:	89 e5                	mov    %esp,%ebp
  801051:	57                   	push   %edi
  801052:	56                   	push   %esi
  801053:	53                   	push   %ebx
  801054:	83 ec 0c             	sub    $0xc,%esp
  801057:	8b 55 08             	mov    0x8(%ebp),%edx
  80105a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80105d:	8b 5d 10             	mov    0x10(%ebp),%ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  801060:	b8 04 00 00 00       	mov    $0x4,%eax
  801065:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80106a:	89 fe                	mov    %edi,%esi
  80106c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80106e:	85 c0                	test   %eax,%eax
  801070:	7e 17                	jle    801089 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801072:	83 ec 0c             	sub    $0xc,%esp
  801075:	50                   	push   %eax
  801076:	6a 04                	push   $0x4
  801078:	68 f8 24 80 00       	push   $0x8024f8
  80107d:	6a 23                	push   $0x23
  80107f:	68 15 25 80 00       	push   $0x802515
  801084:	e8 f3 f5 ff ff       	call   80067c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801089:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108c:	5b                   	pop    %ebx
  80108d:	5e                   	pop    %esi
  80108e:	5f                   	pop    %edi
  80108f:	c9                   	leave  
  801090:	c3                   	ret    

00801091 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801091:	55                   	push   %ebp
  801092:	89 e5                	mov    %esp,%ebp
  801094:	57                   	push   %edi
  801095:	56                   	push   %esi
  801096:	53                   	push   %ebx
  801097:	83 ec 0c             	sub    $0xc,%esp
  80109a:	8b 55 08             	mov    0x8(%ebp),%edx
  80109d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010a3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010a6:	8b 75 18             	mov    0x18(%ebp),%esi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8010a9:	b8 05 00 00 00       	mov    $0x5,%eax
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ae:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010b0:	85 c0                	test   %eax,%eax
  8010b2:	7e 17                	jle    8010cb <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b4:	83 ec 0c             	sub    $0xc,%esp
  8010b7:	50                   	push   %eax
  8010b8:	6a 05                	push   $0x5
  8010ba:	68 f8 24 80 00       	push   $0x8024f8
  8010bf:	6a 23                	push   $0x23
  8010c1:	68 15 25 80 00       	push   $0x802515
  8010c6:	e8 b1 f5 ff ff       	call   80067c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8010cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ce:	5b                   	pop    %ebx
  8010cf:	5e                   	pop    %esi
  8010d0:	5f                   	pop    %edi
  8010d1:	c9                   	leave  
  8010d2:	c3                   	ret    

008010d3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010d3:	55                   	push   %ebp
  8010d4:	89 e5                	mov    %esp,%ebp
  8010d6:	57                   	push   %edi
  8010d7:	56                   	push   %esi
  8010d8:	53                   	push   %ebx
  8010d9:	83 ec 0c             	sub    $0xc,%esp
  8010dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8010df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8010e2:	b8 06 00 00 00       	mov    $0x6,%eax
  8010e7:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ec:	89 fb                	mov    %edi,%ebx
  8010ee:	89 fe                	mov    %edi,%esi
  8010f0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010f2:	85 c0                	test   %eax,%eax
  8010f4:	7e 17                	jle    80110d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010f6:	83 ec 0c             	sub    $0xc,%esp
  8010f9:	50                   	push   %eax
  8010fa:	6a 06                	push   $0x6
  8010fc:	68 f8 24 80 00       	push   $0x8024f8
  801101:	6a 23                	push   $0x23
  801103:	68 15 25 80 00       	push   $0x802515
  801108:	e8 6f f5 ff ff       	call   80067c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80110d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801110:	5b                   	pop    %ebx
  801111:	5e                   	pop    %esi
  801112:	5f                   	pop    %edi
  801113:	c9                   	leave  
  801114:	c3                   	ret    

00801115 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801115:	55                   	push   %ebp
  801116:	89 e5                	mov    %esp,%ebp
  801118:	57                   	push   %edi
  801119:	56                   	push   %esi
  80111a:	53                   	push   %ebx
  80111b:	83 ec 0c             	sub    $0xc,%esp
  80111e:	8b 55 08             	mov    0x8(%ebp),%edx
  801121:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  801124:	b8 08 00 00 00       	mov    $0x8,%eax
  801129:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80112e:	89 fb                	mov    %edi,%ebx
  801130:	89 fe                	mov    %edi,%esi
  801132:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801134:	85 c0                	test   %eax,%eax
  801136:	7e 17                	jle    80114f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801138:	83 ec 0c             	sub    $0xc,%esp
  80113b:	50                   	push   %eax
  80113c:	6a 08                	push   $0x8
  80113e:	68 f8 24 80 00       	push   $0x8024f8
  801143:	6a 23                	push   $0x23
  801145:	68 15 25 80 00       	push   $0x802515
  80114a:	e8 2d f5 ff ff       	call   80067c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80114f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801152:	5b                   	pop    %ebx
  801153:	5e                   	pop    %esi
  801154:	5f                   	pop    %edi
  801155:	c9                   	leave  
  801156:	c3                   	ret    

00801157 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801157:	55                   	push   %ebp
  801158:	89 e5                	mov    %esp,%ebp
  80115a:	57                   	push   %edi
  80115b:	56                   	push   %esi
  80115c:	53                   	push   %ebx
  80115d:	83 ec 0c             	sub    $0xc,%esp
  801160:	8b 55 08             	mov    0x8(%ebp),%edx
  801163:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  801166:	b8 09 00 00 00       	mov    $0x9,%eax
  80116b:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801170:	89 fb                	mov    %edi,%ebx
  801172:	89 fe                	mov    %edi,%esi
  801174:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801176:	85 c0                	test   %eax,%eax
  801178:	7e 17                	jle    801191 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80117a:	83 ec 0c             	sub    $0xc,%esp
  80117d:	50                   	push   %eax
  80117e:	6a 09                	push   $0x9
  801180:	68 f8 24 80 00       	push   $0x8024f8
  801185:	6a 23                	push   $0x23
  801187:	68 15 25 80 00       	push   $0x802515
  80118c:	e8 eb f4 ff ff       	call   80067c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801191:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801194:	5b                   	pop    %ebx
  801195:	5e                   	pop    %esi
  801196:	5f                   	pop    %edi
  801197:	c9                   	leave  
  801198:	c3                   	ret    

00801199 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801199:	55                   	push   %ebp
  80119a:	89 e5                	mov    %esp,%ebp
  80119c:	57                   	push   %edi
  80119d:	56                   	push   %esi
  80119e:	53                   	push   %ebx
  80119f:	83 ec 0c             	sub    $0xc,%esp
  8011a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8011a8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8011ad:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011b2:	89 fb                	mov    %edi,%ebx
  8011b4:	89 fe                	mov    %edi,%esi
  8011b6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011b8:	85 c0                	test   %eax,%eax
  8011ba:	7e 17                	jle    8011d3 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011bc:	83 ec 0c             	sub    $0xc,%esp
  8011bf:	50                   	push   %eax
  8011c0:	6a 0a                	push   $0xa
  8011c2:	68 f8 24 80 00       	push   $0x8024f8
  8011c7:	6a 23                	push   $0x23
  8011c9:	68 15 25 80 00       	push   $0x802515
  8011ce:	e8 a9 f4 ff ff       	call   80067c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d6:	5b                   	pop    %ebx
  8011d7:	5e                   	pop    %esi
  8011d8:	5f                   	pop    %edi
  8011d9:	c9                   	leave  
  8011da:	c3                   	ret    

008011db <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011db:	55                   	push   %ebp
  8011dc:	89 e5                	mov    %esp,%ebp
  8011de:	57                   	push   %edi
  8011df:	56                   	push   %esi
  8011e0:	53                   	push   %ebx
  8011e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8011e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011ea:	8b 7d 14             	mov    0x14(%ebp),%edi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8011ed:	b8 0c 00 00 00       	mov    $0xc,%eax
  8011f2:	be 00 00 00 00       	mov    $0x0,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011f7:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8011f9:	5b                   	pop    %ebx
  8011fa:	5e                   	pop    %esi
  8011fb:	5f                   	pop    %edi
  8011fc:	c9                   	leave  
  8011fd:	c3                   	ret    

008011fe <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8011fe:	55                   	push   %ebp
  8011ff:	89 e5                	mov    %esp,%ebp
  801201:	57                   	push   %edi
  801202:	56                   	push   %esi
  801203:	53                   	push   %ebx
  801204:	83 ec 0c             	sub    $0xc,%esp
  801207:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80120a:	b8 0d 00 00 00       	mov    $0xd,%eax
  80120f:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801214:	89 f9                	mov    %edi,%ecx
  801216:	89 fb                	mov    %edi,%ebx
  801218:	89 fe                	mov    %edi,%esi
  80121a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80121c:	85 c0                	test   %eax,%eax
  80121e:	7e 17                	jle    801237 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801220:	83 ec 0c             	sub    $0xc,%esp
  801223:	50                   	push   %eax
  801224:	6a 0d                	push   $0xd
  801226:	68 f8 24 80 00       	push   $0x8024f8
  80122b:	6a 23                	push   $0x23
  80122d:	68 15 25 80 00       	push   $0x802515
  801232:	e8 45 f4 ff ff       	call   80067c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801237:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80123a:	5b                   	pop    %ebx
  80123b:	5e                   	pop    %esi
  80123c:	5f                   	pop    %edi
  80123d:	c9                   	leave  
  80123e:	c3                   	ret    
	...

00801240 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
  801243:	56                   	push   %esi
  801244:	53                   	push   %ebx
  801245:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801248:	8b 45 0c             	mov    0xc(%ebp),%eax
  80124b:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg == NULL)
  80124e:	85 c0                	test   %eax,%eax
  801250:	75 05                	jne    801257 <ipc_recv+0x17>
		pg = (void *) UTOP; // UTOP as "no page"
  801252:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	if ((r = sys_ipc_recv(pg)) < 0) {
  801257:	83 ec 0c             	sub    $0xc,%esp
  80125a:	50                   	push   %eax
  80125b:	e8 9e ff ff ff       	call   8011fe <sys_ipc_recv>
  801260:	83 c4 10             	add    $0x10,%esp
  801263:	85 c0                	test   %eax,%eax
  801265:	79 16                	jns    80127d <ipc_recv+0x3d>
		if (from_env_store)
  801267:	85 db                	test   %ebx,%ebx
  801269:	74 06                	je     801271 <ipc_recv+0x31>
			*from_env_store = 0;
  80126b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store)
  801271:	85 f6                	test   %esi,%esi
  801273:	74 34                	je     8012a9 <ipc_recv+0x69>
			*perm_store = 0;
  801275:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return r;
  80127b:	eb 2c                	jmp    8012a9 <ipc_recv+0x69>
	}

	if (from_env_store)
  80127d:	85 db                	test   %ebx,%ebx
  80127f:	74 0a                	je     80128b <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  801281:	a1 04 40 80 00       	mov    0x804004,%eax
  801286:	8b 40 74             	mov    0x74(%eax),%eax
  801289:	89 03                	mov    %eax,(%ebx)
	if (perm_store && thisenv->env_ipc_perm != 0) {
  80128b:	85 f6                	test   %esi,%esi
  80128d:	74 12                	je     8012a1 <ipc_recv+0x61>
  80128f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801295:	8b 42 78             	mov    0x78(%edx),%eax
  801298:	85 c0                	test   %eax,%eax
  80129a:	74 05                	je     8012a1 <ipc_recv+0x61>
		*perm_store = thisenv->env_ipc_perm;
  80129c:	8b 42 78             	mov    0x78(%edx),%eax
  80129f:	89 06                	mov    %eax,(%esi)
//		sys_page_map(thisenv->env_id, pg, thisenv->env_id, pg, *perm_store);
	}	

	return thisenv->env_ipc_value;
  8012a1:	a1 04 40 80 00       	mov    0x804004,%eax
  8012a6:	8b 40 70             	mov    0x70(%eax),%eax
}
  8012a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012ac:	5b                   	pop    %ebx
  8012ad:	5e                   	pop    %esi
  8012ae:	c9                   	leave  
  8012af:	c3                   	ret    

008012b0 <ipc_send>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
//   -> UTOP as "no page"
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8012b0:	55                   	push   %ebp
  8012b1:	89 e5                	mov    %esp,%ebp
  8012b3:	57                   	push   %edi
  8012b4:	56                   	push   %esi
  8012b5:	53                   	push   %ebx
  8012b6:	83 ec 0c             	sub    $0xc,%esp
  8012b9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012bc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1) {
		if (pg)
  8012c2:	85 db                	test   %ebx,%ebx
  8012c4:	74 10                	je     8012d6 <ipc_send+0x26>
			r = sys_ipc_try_send(to_env, val, pg, perm);
  8012c6:	ff 75 14             	pushl  0x14(%ebp)
  8012c9:	53                   	push   %ebx
  8012ca:	56                   	push   %esi
  8012cb:	57                   	push   %edi
  8012cc:	e8 0a ff ff ff       	call   8011db <sys_ipc_try_send>
  8012d1:	83 c4 10             	add    $0x10,%esp
  8012d4:	eb 11                	jmp    8012e7 <ipc_send+0x37>
		else 
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  8012d6:	6a 00                	push   $0x0
  8012d8:	68 00 00 c0 ee       	push   $0xeec00000
  8012dd:	56                   	push   %esi
  8012de:	57                   	push   %edi
  8012df:	e8 f7 fe ff ff       	call   8011db <sys_ipc_try_send>
  8012e4:	83 c4 10             	add    $0x10,%esp

		if (r == 0) 
  8012e7:	85 c0                	test   %eax,%eax
  8012e9:	74 1e                	je     801309 <ipc_send+0x59>
			break;
		
		if (r != -E_IPC_NOT_RECV) {
  8012eb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8012ee:	74 12                	je     801302 <ipc_send+0x52>
			panic("sys_ipc_try_send:unexpected err, %e", r);
  8012f0:	50                   	push   %eax
  8012f1:	68 24 25 80 00       	push   $0x802524
  8012f6:	6a 4a                	push   $0x4a
  8012f8:	68 48 25 80 00       	push   $0x802548
  8012fd:	e8 7a f3 ff ff       	call   80067c <_panic>
		}
		sys_yield();
  801302:	e8 28 fd ff ff       	call   80102f <sys_yield>
  801307:	eb b9                	jmp    8012c2 <ipc_send+0x12>
	}
//	panic("ipc_send not implemented");
}
  801309:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80130c:	5b                   	pop    %ebx
  80130d:	5e                   	pop    %esi
  80130e:	5f                   	pop    %edi
  80130f:	c9                   	leave  
  801310:	c3                   	ret    

00801311 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801311:	55                   	push   %ebp
  801312:	89 e5                	mov    %esp,%ebp
  801314:	53                   	push   %ebx
  801315:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801318:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
  80131d:	89 d0                	mov    %edx,%eax
  80131f:	c1 e0 05             	shl    $0x5,%eax
  801322:	29 d0                	sub    %edx,%eax
  801324:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80132b:	8d 81 00 00 c0 ee    	lea    -0x11400000(%ecx),%eax
  801331:	8b 40 50             	mov    0x50(%eax),%eax
  801334:	39 d8                	cmp    %ebx,%eax
  801336:	75 0b                	jne    801343 <ipc_find_env+0x32>
			return envs[i].env_id;
  801338:	8d 81 08 00 c0 ee    	lea    -0x113ffff8(%ecx),%eax
  80133e:	8b 40 40             	mov    0x40(%eax),%eax
  801341:	eb 0e                	jmp    801351 <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801343:	42                   	inc    %edx
  801344:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  80134a:	7e d1                	jle    80131d <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80134c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801351:	5b                   	pop    %ebx
  801352:	c9                   	leave  
  801353:	c3                   	ret    

00801354 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801354:	55                   	push   %ebp
  801355:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801357:	8b 45 08             	mov    0x8(%ebp),%eax
  80135a:	05 00 00 00 30       	add    $0x30000000,%eax
  80135f:	c1 e8 0c             	shr    $0xc,%eax
}
  801362:	c9                   	leave  
  801363:	c3                   	ret    

00801364 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801364:	55                   	push   %ebp
  801365:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801367:	ff 75 08             	pushl  0x8(%ebp)
  80136a:	e8 e5 ff ff ff       	call   801354 <fd2num>
  80136f:	83 c4 04             	add    $0x4,%esp
  801372:	c1 e0 0c             	shl    $0xc,%eax
  801375:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80137a:	c9                   	leave  
  80137b:	c3                   	ret    

0080137c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80137c:	55                   	push   %ebp
  80137d:	89 e5                	mov    %esp,%ebp
  80137f:	57                   	push   %edi
  801380:	56                   	push   %esi
  801381:	53                   	push   %ebx
  801382:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801385:	b9 00 00 00 00       	mov    $0x0,%ecx
  80138a:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  80138f:	bb 00 00 40 ef       	mov    $0xef400000,%ebx
		fd = INDEX2FD(i);
  801394:	89 c8                	mov    %ecx,%eax
  801396:	c1 e0 0c             	shl    $0xc,%eax
  801399:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  80139f:	89 d0                	mov    %edx,%eax
  8013a1:	c1 e8 16             	shr    $0x16,%eax
  8013a4:	8b 04 86             	mov    (%esi,%eax,4),%eax
  8013a7:	a8 01                	test   $0x1,%al
  8013a9:	74 0c                	je     8013b7 <fd_alloc+0x3b>
  8013ab:	89 d0                	mov    %edx,%eax
  8013ad:	c1 e8 0c             	shr    $0xc,%eax
  8013b0:	8b 04 83             	mov    (%ebx,%eax,4),%eax
  8013b3:	a8 01                	test   $0x1,%al
  8013b5:	75 09                	jne    8013c0 <fd_alloc+0x44>
			*fd_store = fd;
  8013b7:	89 17                	mov    %edx,(%edi)
			return 0;
  8013b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8013be:	eb 11                	jmp    8013d1 <fd_alloc+0x55>
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013c0:	41                   	inc    %ecx
  8013c1:	83 f9 1f             	cmp    $0x1f,%ecx
  8013c4:	7e ce                	jle    801394 <fd_alloc+0x18>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013c6:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
	return -E_MAX_OPEN;
  8013cc:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013d1:	5b                   	pop    %ebx
  8013d2:	5e                   	pop    %esi
  8013d3:	5f                   	pop    %edi
  8013d4:	c9                   	leave  
  8013d5:	c3                   	ret    

008013d6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013d6:	55                   	push   %ebp
  8013d7:	89 e5                	mov    %esp,%ebp
  8013d9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  8013dc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013e1:	83 f8 1f             	cmp    $0x1f,%eax
  8013e4:	77 3a                	ja     801420 <fd_lookup+0x4a>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013e6:	c1 e0 0c             	shl    $0xc,%eax
  8013e9:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	///^&^ making sure fd page exists
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8013ef:	89 d0                	mov    %edx,%eax
  8013f1:	c1 e8 16             	shr    $0x16,%eax
  8013f4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013fb:	a8 01                	test   $0x1,%al
  8013fd:	74 10                	je     80140f <fd_lookup+0x39>
  8013ff:	89 d0                	mov    %edx,%eax
  801401:	c1 e8 0c             	shr    $0xc,%eax
  801404:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80140b:	a8 01                	test   $0x1,%al
  80140d:	75 07                	jne    801416 <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  80140f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801414:	eb 0a                	jmp    801420 <fd_lookup+0x4a>
	}
	*fd_store = fd;
  801416:	8b 45 0c             	mov    0xc(%ebp),%eax
  801419:	89 10                	mov    %edx,(%eax)
	return 0;
  80141b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801420:	89 d0                	mov    %edx,%eax
  801422:	c9                   	leave  
  801423:	c3                   	ret    

00801424 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801424:	55                   	push   %ebp
  801425:	89 e5                	mov    %esp,%ebp
  801427:	56                   	push   %esi
  801428:	53                   	push   %ebx
  801429:	83 ec 10             	sub    $0x10,%esp
  80142c:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80142f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801432:	50                   	push   %eax
  801433:	56                   	push   %esi
  801434:	e8 1b ff ff ff       	call   801354 <fd2num>
  801439:	89 04 24             	mov    %eax,(%esp)
  80143c:	e8 95 ff ff ff       	call   8013d6 <fd_lookup>
  801441:	89 c3                	mov    %eax,%ebx
  801443:	83 c4 08             	add    $0x8,%esp
  801446:	85 c0                	test   %eax,%eax
  801448:	78 05                	js     80144f <fd_close+0x2b>
  80144a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80144d:	74 0f                	je     80145e <fd_close+0x3a>
	    || fd != fd2)
		return (must_exist ? r : 0);
  80144f:	89 d8                	mov    %ebx,%eax
  801451:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801455:	75 45                	jne    80149c <fd_close+0x78>
  801457:	b8 00 00 00 00       	mov    $0x0,%eax
  80145c:	eb 3e                	jmp    80149c <fd_close+0x78>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80145e:	83 ec 08             	sub    $0x8,%esp
  801461:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801464:	50                   	push   %eax
  801465:	ff 36                	pushl  (%esi)
  801467:	e8 37 00 00 00       	call   8014a3 <dev_lookup>
  80146c:	89 c3                	mov    %eax,%ebx
  80146e:	83 c4 10             	add    $0x10,%esp
  801471:	85 c0                	test   %eax,%eax
  801473:	78 1a                	js     80148f <fd_close+0x6b>
		if (dev->dev_close)
  801475:	8b 45 f0             	mov    -0x10(%ebp),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801478:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80147d:	83 78 10 00          	cmpl   $0x0,0x10(%eax)
  801481:	74 0c                	je     80148f <fd_close+0x6b>
			r = (*dev->dev_close)(fd);
  801483:	83 ec 0c             	sub    $0xc,%esp
  801486:	56                   	push   %esi
  801487:	ff 50 10             	call   *0x10(%eax)
  80148a:	89 c3                	mov    %eax,%ebx
  80148c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80148f:	83 ec 08             	sub    $0x8,%esp
  801492:	56                   	push   %esi
  801493:	6a 00                	push   $0x0
  801495:	e8 39 fc ff ff       	call   8010d3 <sys_page_unmap>
	return r;
  80149a:	89 d8                	mov    %ebx,%eax
}
  80149c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80149f:	5b                   	pop    %ebx
  8014a0:	5e                   	pop    %esi
  8014a1:	c9                   	leave  
  8014a2:	c3                   	ret    

008014a3 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014a3:	55                   	push   %ebp
  8014a4:	89 e5                	mov    %esp,%ebp
  8014a6:	56                   	push   %esi
  8014a7:	53                   	push   %ebx
  8014a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8014ab:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i;
	for (i = 0; devtab[i]; i++)
  8014ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b3:	83 3d 08 30 80 00 00 	cmpl   $0x0,0x803008
  8014ba:	74 1c                	je     8014d8 <dev_lookup+0x35>
  8014bc:	b9 08 30 80 00       	mov    $0x803008,%ecx
		if (devtab[i]->dev_id == dev_id) {
  8014c1:	8b 04 91             	mov    (%ecx,%edx,4),%eax
  8014c4:	39 18                	cmp    %ebx,(%eax)
  8014c6:	75 09                	jne    8014d1 <dev_lookup+0x2e>
			*dev = devtab[i];
  8014c8:	89 06                	mov    %eax,(%esi)
			return 0;
  8014ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8014cf:	eb 29                	jmp    8014fa <dev_lookup+0x57>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014d1:	42                   	inc    %edx
  8014d2:	83 3c 91 00          	cmpl   $0x0,(%ecx,%edx,4)
  8014d6:	75 e9                	jne    8014c1 <dev_lookup+0x1e>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014d8:	83 ec 04             	sub    $0x4,%esp
  8014db:	53                   	push   %ebx
  8014dc:	a1 04 40 80 00       	mov    0x804004,%eax
  8014e1:	8b 40 48             	mov    0x48(%eax),%eax
  8014e4:	50                   	push   %eax
  8014e5:	68 54 25 80 00       	push   $0x802554
  8014ea:	e8 69 f2 ff ff       	call   800758 <cprintf>
	*dev = 0;
  8014ef:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	return -E_INVAL;
  8014f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014fd:	5b                   	pop    %ebx
  8014fe:	5e                   	pop    %esi
  8014ff:	c9                   	leave  
  801500:	c3                   	ret    

00801501 <close>:

int
close(int fdnum)
{
  801501:	55                   	push   %ebp
  801502:	89 e5                	mov    %esp,%ebp
  801504:	83 ec 08             	sub    $0x8,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801507:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80150a:	50                   	push   %eax
  80150b:	ff 75 08             	pushl  0x8(%ebp)
  80150e:	e8 c3 fe ff ff       	call   8013d6 <fd_lookup>
  801513:	83 c4 08             	add    $0x8,%esp
		return r;
  801516:	89 c2                	mov    %eax,%edx
close(int fdnum)
{
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801518:	85 c0                	test   %eax,%eax
  80151a:	78 0f                	js     80152b <close+0x2a>
		return r;
	else
		return fd_close(fd, 1);
  80151c:	83 ec 08             	sub    $0x8,%esp
  80151f:	6a 01                	push   $0x1
  801521:	ff 75 fc             	pushl  -0x4(%ebp)
  801524:	e8 fb fe ff ff       	call   801424 <fd_close>
  801529:	89 c2                	mov    %eax,%edx
}
  80152b:	89 d0                	mov    %edx,%eax
  80152d:	c9                   	leave  
  80152e:	c3                   	ret    

0080152f <close_all>:

void
close_all(void)
{
  80152f:	55                   	push   %ebp
  801530:	89 e5                	mov    %esp,%ebp
  801532:	53                   	push   %ebx
  801533:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801536:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80153b:	83 ec 0c             	sub    $0xc,%esp
  80153e:	53                   	push   %ebx
  80153f:	e8 bd ff ff ff       	call   801501 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801544:	83 c4 10             	add    $0x10,%esp
  801547:	43                   	inc    %ebx
  801548:	83 fb 1f             	cmp    $0x1f,%ebx
  80154b:	7e ee                	jle    80153b <close_all+0xc>
		close(i);
}
  80154d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801550:	c9                   	leave  
  801551:	c3                   	ret    

00801552 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801552:	55                   	push   %ebp
  801553:	89 e5                	mov    %esp,%ebp
  801555:	57                   	push   %edi
  801556:	56                   	push   %esi
  801557:	53                   	push   %ebx
  801558:	83 ec 0c             	sub    $0xc,%esp
  80155b:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80155e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801561:	50                   	push   %eax
  801562:	ff 75 08             	pushl  0x8(%ebp)
  801565:	e8 6c fe ff ff       	call   8013d6 <fd_lookup>
  80156a:	89 c3                	mov    %eax,%ebx
  80156c:	83 c4 08             	add    $0x8,%esp
  80156f:	85 db                	test   %ebx,%ebx
  801571:	0f 88 b7 00 00 00    	js     80162e <dup+0xdc>
		return r;
	close(newfdnum);
  801577:	83 ec 0c             	sub    $0xc,%esp
  80157a:	57                   	push   %edi
  80157b:	e8 81 ff ff ff       	call   801501 <close>

	newfd = INDEX2FD(newfdnum);
  801580:	89 f8                	mov    %edi,%eax
  801582:	c1 e0 0c             	shl    $0xc,%eax
  801585:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  80158b:	ff 75 f0             	pushl  -0x10(%ebp)
  80158e:	e8 d1 fd ff ff       	call   801364 <fd2data>
  801593:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801595:	89 34 24             	mov    %esi,(%esp)
  801598:	e8 c7 fd ff ff       	call   801364 <fd2data>
  80159d:	89 45 ec             	mov    %eax,-0x14(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  8015a0:	89 d8                	mov    %ebx,%eax
  8015a2:	c1 e8 16             	shr    $0x16,%eax
  8015a5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015ac:	83 c4 14             	add    $0x14,%esp
  8015af:	a8 01                	test   $0x1,%al
  8015b1:	74 33                	je     8015e6 <dup+0x94>
  8015b3:	89 da                	mov    %ebx,%edx
  8015b5:	c1 ea 0c             	shr    $0xc,%edx
  8015b8:	b9 00 00 40 ef       	mov    $0xef400000,%ecx
  8015bd:	8b 04 91             	mov    (%ecx,%edx,4),%eax
  8015c0:	a8 01                	test   $0x1,%al
  8015c2:	74 22                	je     8015e6 <dup+0x94>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015c4:	83 ec 0c             	sub    $0xc,%esp
  8015c7:	8b 04 91             	mov    (%ecx,%edx,4),%eax
  8015ca:	25 07 0e 00 00       	and    $0xe07,%eax
  8015cf:	50                   	push   %eax
  8015d0:	ff 75 ec             	pushl  -0x14(%ebp)
  8015d3:	6a 00                	push   $0x0
  8015d5:	53                   	push   %ebx
  8015d6:	6a 00                	push   $0x0
  8015d8:	e8 b4 fa ff ff       	call   801091 <sys_page_map>
  8015dd:	89 c3                	mov    %eax,%ebx
  8015df:	83 c4 20             	add    $0x20,%esp
  8015e2:	85 c0                	test   %eax,%eax
  8015e4:	78 2e                	js     801614 <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015e6:	83 ec 0c             	sub    $0xc,%esp
  8015e9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015ec:	89 d0                	mov    %edx,%eax
  8015ee:	c1 e8 0c             	shr    $0xc,%eax
  8015f1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015f8:	25 07 0e 00 00       	and    $0xe07,%eax
  8015fd:	50                   	push   %eax
  8015fe:	56                   	push   %esi
  8015ff:	6a 00                	push   $0x0
  801601:	52                   	push   %edx
  801602:	6a 00                	push   $0x0
  801604:	e8 88 fa ff ff       	call   801091 <sys_page_map>
  801609:	89 c3                	mov    %eax,%ebx
  80160b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80160e:	89 f8                	mov    %edi,%eax
	nva = fd2data(newfd);

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801610:	85 db                	test   %ebx,%ebx
  801612:	79 1a                	jns    80162e <dup+0xdc>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801614:	83 ec 08             	sub    $0x8,%esp
  801617:	56                   	push   %esi
  801618:	6a 00                	push   $0x0
  80161a:	e8 b4 fa ff ff       	call   8010d3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80161f:	83 c4 08             	add    $0x8,%esp
  801622:	ff 75 ec             	pushl  -0x14(%ebp)
  801625:	6a 00                	push   $0x0
  801627:	e8 a7 fa ff ff       	call   8010d3 <sys_page_unmap>
	return r;
  80162c:	89 d8                	mov    %ebx,%eax
}
  80162e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801631:	5b                   	pop    %ebx
  801632:	5e                   	pop    %esi
  801633:	5f                   	pop    %edi
  801634:	c9                   	leave  
  801635:	c3                   	ret    

00801636 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801636:	55                   	push   %ebp
  801637:	89 e5                	mov    %esp,%ebp
  801639:	53                   	push   %ebx
  80163a:	83 ec 14             	sub    $0x14,%esp
  80163d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801640:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801643:	50                   	push   %eax
  801644:	53                   	push   %ebx
  801645:	e8 8c fd ff ff       	call   8013d6 <fd_lookup>
  80164a:	83 c4 08             	add    $0x8,%esp
  80164d:	85 c0                	test   %eax,%eax
  80164f:	78 18                	js     801669 <read+0x33>
  801651:	83 ec 08             	sub    $0x8,%esp
  801654:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801657:	50                   	push   %eax
  801658:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80165b:	ff 30                	pushl  (%eax)
  80165d:	e8 41 fe ff ff       	call   8014a3 <dev_lookup>
  801662:	83 c4 10             	add    $0x10,%esp
  801665:	85 c0                	test   %eax,%eax
  801667:	79 04                	jns    80166d <read+0x37>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
  801669:	89 c2                	mov    %eax,%edx
  80166b:	eb 4e                	jmp    8016bb <read+0x85>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80166d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801670:	8b 40 08             	mov    0x8(%eax),%eax
  801673:	83 e0 03             	and    $0x3,%eax
  801676:	83 f8 01             	cmp    $0x1,%eax
  801679:	75 1e                	jne    801699 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80167b:	83 ec 04             	sub    $0x4,%esp
  80167e:	53                   	push   %ebx
  80167f:	a1 04 40 80 00       	mov    0x804004,%eax
  801684:	8b 40 48             	mov    0x48(%eax),%eax
  801687:	50                   	push   %eax
  801688:	68 98 25 80 00       	push   $0x802598
  80168d:	e8 c6 f0 ff ff       	call   800758 <cprintf>
		return -E_INVAL;
  801692:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801697:	eb 22                	jmp    8016bb <read+0x85>
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801699:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80169e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016a1:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
  8016a5:	74 14                	je     8016bb <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016a7:	83 ec 04             	sub    $0x4,%esp
  8016aa:	ff 75 10             	pushl  0x10(%ebp)
  8016ad:	ff 75 0c             	pushl  0xc(%ebp)
  8016b0:	ff 75 f8             	pushl  -0x8(%ebp)
  8016b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b6:	ff 50 08             	call   *0x8(%eax)
  8016b9:	89 c2                	mov    %eax,%edx
}
  8016bb:	89 d0                	mov    %edx,%eax
  8016bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c0:	c9                   	leave  
  8016c1:	c3                   	ret    

008016c2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016c2:	55                   	push   %ebp
  8016c3:	89 e5                	mov    %esp,%ebp
  8016c5:	57                   	push   %edi
  8016c6:	56                   	push   %esi
  8016c7:	53                   	push   %ebx
  8016c8:	83 ec 0c             	sub    $0xc,%esp
  8016cb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8016ce:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016d1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016d6:	39 f3                	cmp    %esi,%ebx
  8016d8:	73 25                	jae    8016ff <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016da:	83 ec 04             	sub    $0x4,%esp
  8016dd:	89 f0                	mov    %esi,%eax
  8016df:	29 d8                	sub    %ebx,%eax
  8016e1:	50                   	push   %eax
  8016e2:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
  8016e5:	50                   	push   %eax
  8016e6:	ff 75 08             	pushl  0x8(%ebp)
  8016e9:	e8 48 ff ff ff       	call   801636 <read>
		if (m < 0)
  8016ee:	83 c4 10             	add    $0x10,%esp
  8016f1:	85 c0                	test   %eax,%eax
  8016f3:	78 0c                	js     801701 <readn+0x3f>
			return m;
		if (m == 0)
  8016f5:	85 c0                	test   %eax,%eax
  8016f7:	74 06                	je     8016ff <readn+0x3d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016f9:	01 c3                	add    %eax,%ebx
  8016fb:	39 f3                	cmp    %esi,%ebx
  8016fd:	72 db                	jb     8016da <readn+0x18>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8016ff:	89 d8                	mov    %ebx,%eax
}
  801701:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801704:	5b                   	pop    %ebx
  801705:	5e                   	pop    %esi
  801706:	5f                   	pop    %edi
  801707:	c9                   	leave  
  801708:	c3                   	ret    

00801709 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801709:	55                   	push   %ebp
  80170a:	89 e5                	mov    %esp,%ebp
  80170c:	53                   	push   %ebx
  80170d:	83 ec 14             	sub    $0x14,%esp
  801710:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801713:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801716:	50                   	push   %eax
  801717:	53                   	push   %ebx
  801718:	e8 b9 fc ff ff       	call   8013d6 <fd_lookup>
  80171d:	83 c4 08             	add    $0x8,%esp
  801720:	85 c0                	test   %eax,%eax
  801722:	78 18                	js     80173c <write+0x33>
  801724:	83 ec 08             	sub    $0x8,%esp
  801727:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80172a:	50                   	push   %eax
  80172b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80172e:	ff 30                	pushl  (%eax)
  801730:	e8 6e fd ff ff       	call   8014a3 <dev_lookup>
  801735:	83 c4 10             	add    $0x10,%esp
  801738:	85 c0                	test   %eax,%eax
  80173a:	79 04                	jns    801740 <write+0x37>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
  80173c:	89 c2                	mov    %eax,%edx
  80173e:	eb 49                	jmp    801789 <write+0x80>
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801740:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801743:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801747:	75 1e                	jne    801767 <write+0x5e>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801749:	83 ec 04             	sub    $0x4,%esp
  80174c:	53                   	push   %ebx
  80174d:	a1 04 40 80 00       	mov    0x804004,%eax
  801752:	8b 40 48             	mov    0x48(%eax),%eax
  801755:	50                   	push   %eax
  801756:	68 b4 25 80 00       	push   $0x8025b4
  80175b:	e8 f8 ef ff ff       	call   800758 <cprintf>
		return -E_INVAL;
  801760:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801765:	eb 22                	jmp    801789 <write+0x80>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801767:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80176c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80176f:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801773:	74 14                	je     801789 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801775:	83 ec 04             	sub    $0x4,%esp
  801778:	ff 75 10             	pushl  0x10(%ebp)
  80177b:	ff 75 0c             	pushl  0xc(%ebp)
  80177e:	ff 75 f8             	pushl  -0x8(%ebp)
  801781:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801784:	ff 50 0c             	call   *0xc(%eax)
  801787:	89 c2                	mov    %eax,%edx
}
  801789:	89 d0                	mov    %edx,%eax
  80178b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80178e:	c9                   	leave  
  80178f:	c3                   	ret    

00801790 <seek>:

int
seek(int fdnum, off_t offset)
{
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
  801793:	83 ec 04             	sub    $0x4,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801796:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801799:	50                   	push   %eax
  80179a:	ff 75 08             	pushl  0x8(%ebp)
  80179d:	e8 34 fc ff ff       	call   8013d6 <fd_lookup>
  8017a2:	83 c4 08             	add    $0x8,%esp
		return r;
  8017a5:	89 c2                	mov    %eax,%edx
seek(int fdnum, off_t offset)
{
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017a7:	85 c0                	test   %eax,%eax
  8017a9:	78 0e                	js     8017b9 <seek+0x29>
		return r;
	fd->fd_offset = offset;
  8017ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017b1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017b4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8017b9:	89 d0                	mov    %edx,%eax
  8017bb:	c9                   	leave  
  8017bc:	c3                   	ret    

008017bd <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017bd:	55                   	push   %ebp
  8017be:	89 e5                	mov    %esp,%ebp
  8017c0:	53                   	push   %ebx
  8017c1:	83 ec 14             	sub    $0x14,%esp
  8017c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017c7:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8017ca:	50                   	push   %eax
  8017cb:	53                   	push   %ebx
  8017cc:	e8 05 fc ff ff       	call   8013d6 <fd_lookup>
  8017d1:	83 c4 08             	add    $0x8,%esp
  8017d4:	85 c0                	test   %eax,%eax
  8017d6:	78 18                	js     8017f0 <ftruncate+0x33>
  8017d8:	83 ec 08             	sub    $0x8,%esp
  8017db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017de:	50                   	push   %eax
  8017df:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8017e2:	ff 30                	pushl  (%eax)
  8017e4:	e8 ba fc ff ff       	call   8014a3 <dev_lookup>
  8017e9:	83 c4 10             	add    $0x10,%esp
  8017ec:	85 c0                	test   %eax,%eax
  8017ee:	79 04                	jns    8017f4 <ftruncate+0x37>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0) 
		return r;
  8017f0:	89 c2                	mov    %eax,%edx
  8017f2:	eb 46                	jmp    80183a <ftruncate+0x7d>
	

	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017f4:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8017f7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017fb:	75 1e                	jne    80181b <ftruncate+0x5e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017fd:	83 ec 04             	sub    $0x4,%esp
  801800:	53                   	push   %ebx
  801801:	a1 04 40 80 00       	mov    0x804004,%eax
  801806:	8b 40 48             	mov    0x48(%eax),%eax
  801809:	50                   	push   %eax
  80180a:	68 74 25 80 00       	push   $0x802574
  80180f:	e8 44 ef ff ff       	call   800758 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801814:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801819:	eb 1f                	jmp    80183a <ftruncate+0x7d>
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80181b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801820:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801823:	83 78 18 00          	cmpl   $0x0,0x18(%eax)
  801827:	74 11                	je     80183a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801829:	83 ec 08             	sub    $0x8,%esp
  80182c:	ff 75 0c             	pushl  0xc(%ebp)
  80182f:	ff 75 f8             	pushl  -0x8(%ebp)
  801832:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801835:	ff 50 18             	call   *0x18(%eax)
  801838:	89 c2                	mov    %eax,%edx
}
  80183a:	89 d0                	mov    %edx,%eax
  80183c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80183f:	c9                   	leave  
  801840:	c3                   	ret    

00801841 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801841:	55                   	push   %ebp
  801842:	89 e5                	mov    %esp,%ebp
  801844:	53                   	push   %ebx
  801845:	83 ec 14             	sub    $0x14,%esp
  801848:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80184b:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80184e:	50                   	push   %eax
  80184f:	ff 75 08             	pushl  0x8(%ebp)
  801852:	e8 7f fb ff ff       	call   8013d6 <fd_lookup>
  801857:	83 c4 08             	add    $0x8,%esp
  80185a:	85 c0                	test   %eax,%eax
  80185c:	78 18                	js     801876 <fstat+0x35>
  80185e:	83 ec 08             	sub    $0x8,%esp
  801861:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801864:	50                   	push   %eax
  801865:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801868:	ff 30                	pushl  (%eax)
  80186a:	e8 34 fc ff ff       	call   8014a3 <dev_lookup>
  80186f:	83 c4 10             	add    $0x10,%esp
  801872:	85 c0                	test   %eax,%eax
  801874:	79 04                	jns    80187a <fstat+0x39>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
  801876:	89 c2                	mov    %eax,%edx
  801878:	eb 3a                	jmp    8018b4 <fstat+0x73>
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80187a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  80187f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801882:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801886:	74 2c                	je     8018b4 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801888:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80188b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801892:	00 00 00 
	stat->st_isdir = 0;
  801895:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80189c:	00 00 00 
	stat->st_dev = dev;
  80189f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018a8:	83 ec 08             	sub    $0x8,%esp
  8018ab:	53                   	push   %ebx
  8018ac:	ff 75 f8             	pushl  -0x8(%ebp)
  8018af:	ff 50 14             	call   *0x14(%eax)
  8018b2:	89 c2                	mov    %eax,%edx
}
  8018b4:	89 d0                	mov    %edx,%eax
  8018b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b9:	c9                   	leave  
  8018ba:	c3                   	ret    

008018bb <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018bb:	55                   	push   %ebp
  8018bc:	89 e5                	mov    %esp,%ebp
  8018be:	56                   	push   %esi
  8018bf:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018c0:	83 ec 08             	sub    $0x8,%esp
  8018c3:	6a 00                	push   $0x0
  8018c5:	ff 75 08             	pushl  0x8(%ebp)
  8018c8:	e8 72 00 00 00       	call   80193f <open>
  8018cd:	89 c6                	mov    %eax,%esi
  8018cf:	83 c4 10             	add    $0x10,%esp
  8018d2:	85 f6                	test   %esi,%esi
  8018d4:	78 18                	js     8018ee <stat+0x33>
		return fd;
	r = fstat(fd, stat);
  8018d6:	83 ec 08             	sub    $0x8,%esp
  8018d9:	ff 75 0c             	pushl  0xc(%ebp)
  8018dc:	56                   	push   %esi
  8018dd:	e8 5f ff ff ff       	call   801841 <fstat>
  8018e2:	89 c3                	mov    %eax,%ebx
	close(fd);
  8018e4:	89 34 24             	mov    %esi,(%esp)
  8018e7:	e8 15 fc ff ff       	call   801501 <close>
	return r;
  8018ec:	89 d8                	mov    %ebx,%eax
}
  8018ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018f1:	5b                   	pop    %ebx
  8018f2:	5e                   	pop    %esi
  8018f3:	c9                   	leave  
  8018f4:	c3                   	ret    
  8018f5:	00 00                	add    %al,(%eax)
	...

008018f8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018f8:	55                   	push   %ebp
  8018f9:	89 e5                	mov    %esp,%ebp
  8018fb:	83 ec 08             	sub    $0x8,%esp
	static envid_t fsenv;
	if (fsenv == 0) {
  8018fe:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801905:	75 12                	jne    801919 <fsipc+0x21>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801907:	83 ec 0c             	sub    $0xc,%esp
  80190a:	6a 02                	push   $0x2
  80190c:	e8 00 fa ff ff       	call   801311 <ipc_find_env>
  801911:	a3 00 40 80 00       	mov    %eax,0x804000
  801916:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801919:	6a 07                	push   $0x7
  80191b:	68 00 50 80 00       	push   $0x805000
  801920:	ff 75 08             	pushl  0x8(%ebp)
  801923:	ff 35 00 40 80 00    	pushl  0x804000
  801929:	e8 82 f9 ff ff       	call   8012b0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80192e:	83 c4 0c             	add    $0xc,%esp
  801931:	6a 00                	push   $0x0
  801933:	ff 75 0c             	pushl  0xc(%ebp)
  801936:	6a 00                	push   $0x0
  801938:	e8 03 f9 ff ff       	call   801240 <ipc_recv>
}
  80193d:	c9                   	leave  
  80193e:	c3                   	ret    

0080193f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80193f:	55                   	push   %ebp
  801940:	89 e5                	mov    %esp,%ebp
  801942:	56                   	push   %esi
  801943:	53                   	push   %ebx
  801944:	83 ec 1c             	sub    $0x1c,%esp
  801947:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;

	if (strlen(path) >= MAXPATHLEN)
  80194a:	56                   	push   %esi
  80194b:	e8 d0 f2 ff ff       	call   800c20 <strlen>
  801950:	83 c4 10             	add    $0x10,%esp
		return -E_BAD_PATH;
  801953:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;

	if (strlen(path) >= MAXPATHLEN)
  801958:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80195d:	7f 5f                	jg     8019be <open+0x7f>
		return -E_BAD_PATH;
	if ((r = fd_alloc(&fd)) < 0)
  80195f:	83 ec 0c             	sub    $0xc,%esp
  801962:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801965:	50                   	push   %eax
  801966:	e8 11 fa ff ff       	call   80137c <fd_alloc>
  80196b:	83 c4 10             	add    $0x10,%esp
		return r;
  80196e:	89 c2                	mov    %eax,%edx
	struct Fd *fd;
	int r;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
	if ((r = fd_alloc(&fd)) < 0)
  801970:	85 c0                	test   %eax,%eax
  801972:	78 4a                	js     8019be <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801974:	83 ec 08             	sub    $0x8,%esp
  801977:	56                   	push   %esi
  801978:	68 00 50 80 00       	push   $0x805000
  80197d:	e8 da f2 ff ff       	call   800c5c <strcpy>
	fsipcbuf.open.req_omode = mode;
  801982:	8b 45 0c             	mov    0xc(%ebp),%eax
  801985:	a3 00 54 80 00       	mov    %eax,0x805400


	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80198a:	83 c4 08             	add    $0x8,%esp
  80198d:	ff 75 f4             	pushl  -0xc(%ebp)
  801990:	6a 01                	push   $0x1
  801992:	e8 61 ff ff ff       	call   8018f8 <fsipc>
  801997:	89 c3                	mov    %eax,%ebx
  801999:	83 c4 10             	add    $0x10,%esp
  80199c:	85 c0                	test   %eax,%eax
  80199e:	79 11                	jns    8019b1 <open+0x72>
		fd_close(fd, 0);
  8019a0:	83 ec 08             	sub    $0x8,%esp
  8019a3:	6a 00                	push   $0x0
  8019a5:	ff 75 f4             	pushl  -0xc(%ebp)
  8019a8:	e8 77 fa ff ff       	call   801424 <fd_close>
		return r;
  8019ad:	89 da                	mov    %ebx,%edx
  8019af:	eb 0d                	jmp    8019be <open+0x7f>
	}
	
	return fd2num(fd);	
  8019b1:	83 ec 0c             	sub    $0xc,%esp
  8019b4:	ff 75 f4             	pushl  -0xc(%ebp)
  8019b7:	e8 98 f9 ff ff       	call   801354 <fd2num>
  8019bc:	89 c2                	mov    %eax,%edx
}
  8019be:	89 d0                	mov    %edx,%eax
  8019c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019c3:	5b                   	pop    %ebx
  8019c4:	5e                   	pop    %esi
  8019c5:	c9                   	leave  
  8019c6:	c3                   	ret    

008019c7 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019c7:	55                   	push   %ebp
  8019c8:	89 e5                	mov    %esp,%ebp
  8019ca:	83 ec 10             	sub    $0x10,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d0:	8b 40 0c             	mov    0xc(%eax),%eax
  8019d3:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8019d8:	6a 00                	push   $0x0
  8019da:	6a 06                	push   $0x6
  8019dc:	e8 17 ff ff ff       	call   8018f8 <fsipc>
}
  8019e1:	c9                   	leave  
  8019e2:	c3                   	ret    

008019e3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019e3:	55                   	push   %ebp
  8019e4:	89 e5                	mov    %esp,%ebp
  8019e6:	53                   	push   %ebx
  8019e7:	83 ec 0c             	sub    $0xc,%esp
	// The bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8019f0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8019f8:	a3 04 50 80 00       	mov    %eax,0x805004
		

	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019fd:	6a 00                	push   $0x0
  8019ff:	6a 03                	push   $0x3
  801a01:	e8 f2 fe ff ff       	call   8018f8 <fsipc>
  801a06:	89 c3                	mov    %eax,%ebx
  801a08:	83 c4 10             	add    $0x10,%esp
  801a0b:	85 db                	test   %ebx,%ebx
  801a0d:	78 13                	js     801a22 <devfile_read+0x3f>
		return r;

	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a0f:	83 ec 04             	sub    $0x4,%esp
  801a12:	53                   	push   %ebx
  801a13:	68 00 50 80 00       	push   $0x805000
  801a18:	ff 75 0c             	pushl  0xc(%ebp)
  801a1b:	e8 d8 f3 ff ff       	call   800df8 <memmove>
	return r;
  801a20:	89 d8                	mov    %ebx,%eax
}
  801a22:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a25:	c9                   	leave  
  801a26:	c3                   	ret    

00801a27 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a27:	55                   	push   %ebp
  801a28:	89 e5                	mov    %esp,%ebp
  801a2a:	83 ec 08             	sub    $0x8,%esp
  801a2d:	8b 45 10             	mov    0x10(%ebp),%eax
	// Be careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a30:	8b 55 08             	mov    0x8(%ebp),%edx
  801a33:	8b 52 0c             	mov    0xc(%edx),%edx
  801a36:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801a3c:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, MIN(n, PGSIZE - (sizeof(int) + sizeof(size_t))));
  801a41:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a46:	76 05                	jbe    801a4d <devfile_write+0x26>
  801a48:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801a4d:	83 ec 04             	sub    $0x4,%esp
  801a50:	50                   	push   %eax
  801a51:	ff 75 0c             	pushl  0xc(%ebp)
  801a54:	68 08 50 80 00       	push   $0x805008
  801a59:	e8 9a f3 ff ff       	call   800df8 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801a5e:	83 c4 08             	add    $0x8,%esp
  801a61:	6a 00                	push   $0x0
  801a63:	6a 04                	push   $0x4
  801a65:	e8 8e fe ff ff       	call   8018f8 <fsipc>
  801a6a:	83 c4 10             	add    $0x10,%esp
		return r;
	return r;
}
  801a6d:	c9                   	leave  
  801a6e:	c3                   	ret    

00801a6f <devfile_stat>:

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a6f:	55                   	push   %ebp
  801a70:	89 e5                	mov    %esp,%ebp
  801a72:	53                   	push   %ebx
  801a73:	83 ec 0c             	sub    $0xc,%esp
  801a76:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a79:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7c:	8b 40 0c             	mov    0xc(%eax),%eax
  801a7f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a84:	6a 00                	push   $0x0
  801a86:	6a 05                	push   $0x5
  801a88:	e8 6b fe ff ff       	call   8018f8 <fsipc>
  801a8d:	83 c4 10             	add    $0x10,%esp
		return r;
  801a90:	89 c2                	mov    %eax,%edx
devfile_stat(struct Fd *fd, struct Stat *st)
{
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a92:	85 c0                	test   %eax,%eax
  801a94:	78 29                	js     801abf <devfile_stat+0x50>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a96:	83 ec 08             	sub    $0x8,%esp
  801a99:	68 00 50 80 00       	push   $0x805000
  801a9e:	53                   	push   %ebx
  801a9f:	e8 b8 f1 ff ff       	call   800c5c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801aa4:	a1 80 50 80 00       	mov    0x805080,%eax
  801aa9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801aaf:	a1 84 50 80 00       	mov    0x805084,%eax
  801ab4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801aba:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801abf:	89 d0                	mov    %edx,%eax
  801ac1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ac4:	c9                   	leave  
  801ac5:	c3                   	ret    

00801ac6 <devfile_trunc>:

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801ac6:	55                   	push   %ebp
  801ac7:	89 e5                	mov    %esp,%ebp
  801ac9:	83 ec 10             	sub    $0x10,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801acc:	8b 45 08             	mov    0x8(%ebp),%eax
  801acf:	8b 40 0c             	mov    0xc(%eax),%eax
  801ad2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801ad7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ada:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801adf:	6a 00                	push   $0x0
  801ae1:	6a 02                	push   $0x2
  801ae3:	e8 10 fe ff ff       	call   8018f8 <fsipc>
}
  801ae8:	c9                   	leave  
  801ae9:	c3                   	ret    

00801aea <remove>:

// Delete a file
int
remove(const char *path)
{
  801aea:	55                   	push   %ebp
  801aeb:	89 e5                	mov    %esp,%ebp
  801aed:	53                   	push   %ebx
  801aee:	83 ec 10             	sub    $0x10,%esp
  801af1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801af4:	53                   	push   %ebx
  801af5:	e8 26 f1 ff ff       	call   800c20 <strlen>
  801afa:	83 c4 10             	add    $0x10,%esp
		return -E_BAD_PATH;
  801afd:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx

// Delete a file
int
remove(const char *path)
{
	if (strlen(path) >= MAXPATHLEN)
  801b02:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b07:	7f 1c                	jg     801b25 <remove+0x3b>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801b09:	83 ec 08             	sub    $0x8,%esp
  801b0c:	53                   	push   %ebx
  801b0d:	68 00 50 80 00       	push   $0x805000
  801b12:	e8 45 f1 ff ff       	call   800c5c <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801b17:	83 c4 08             	add    $0x8,%esp
  801b1a:	6a 00                	push   $0x0
  801b1c:	6a 07                	push   $0x7
  801b1e:	e8 d5 fd ff ff       	call   8018f8 <fsipc>
  801b23:	89 c2                	mov    %eax,%edx
}
  801b25:	89 d0                	mov    %edx,%eax
  801b27:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b2a:	c9                   	leave  
  801b2b:	c3                   	ret    

00801b2c <sync>:

// Synchronize disk with buffer cache
int
sync(void)
{
  801b2c:	55                   	push   %ebp
  801b2d:	89 e5                	mov    %esp,%ebp
  801b2f:	83 ec 10             	sub    $0x10,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b32:	6a 00                	push   $0x0
  801b34:	6a 08                	push   $0x8
  801b36:	e8 bd fd ff ff       	call   8018f8 <fsipc>
}
  801b3b:	c9                   	leave  
  801b3c:	c3                   	ret    
  801b3d:	00 00                	add    %al,(%eax)
	...

00801b40 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801b40:	55                   	push   %ebp
  801b41:	89 e5                	mov    %esp,%ebp
  801b43:	57                   	push   %edi
  801b44:	56                   	push   %esi
  801b45:	83 ec 14             	sub    $0x14,%esp
  801b48:	8b 55 14             	mov    0x14(%ebp),%edx
  801b4b:	8b 75 08             	mov    0x8(%ebp),%esi
  801b4e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801b51:	8b 45 10             	mov    0x10(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801b54:	85 d2                	test   %edx,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801b56:	89 75 f0             	mov    %esi,-0x10(%ebp)
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  801b59:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  d1 = dd.s.high;
  801b5c:	89 55 f4             	mov    %edx,-0xc(%ebp)
  n0 = nn.s.low;
  n1 = nn.s.high;
  801b5f:	89 fe                	mov    %edi,%esi

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801b61:	75 11                	jne    801b74 <__udivdi3+0x34>
    {
      if (d0 > n1)
  801b63:	39 f8                	cmp    %edi,%eax
  801b65:	76 4d                	jbe    801bb4 <__udivdi3+0x74>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801b67:	89 fa                	mov    %edi,%edx
  801b69:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b6c:	f7 75 e4             	divl   -0x1c(%ebp)
  801b6f:	89 c7                	mov    %eax,%edi
  801b71:	eb 09                	jmp    801b7c <__udivdi3+0x3c>
  801b73:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801b74:	39 7d f4             	cmp    %edi,-0xc(%ebp)
  801b77:	76 17                	jbe    801b90 <__udivdi3+0x50>
	{
	  /* 00 = nn / DD */

	  q0 = 0;
  801b79:	31 ff                	xor    %edi,%edi
  801b7b:	90                   	nop
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
		}

	      q1 = 0;
  801b7c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801b83:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801b86:	83 c4 14             	add    $0x14,%esp
  801b89:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801b8a:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801b8c:	5f                   	pop    %edi
  801b8d:	c9                   	leave  
  801b8e:	c3                   	ret    
  801b8f:	90                   	nop
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801b90:	0f bd 45 f4          	bsr    -0xc(%ebp),%eax
	  if (bm == 0)
  801b94:	89 c7                	mov    %eax,%edi
  801b96:	83 f7 1f             	xor    $0x1f,%edi
  801b99:	75 4d                	jne    801be8 <__udivdi3+0xa8>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801b9b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801b9e:	77 0a                	ja     801baa <__udivdi3+0x6a>
  801ba0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
		}
	      else
		q0 = 0;
  801ba3:	31 ff                	xor    %edi,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801ba5:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  801ba8:	72 d2                	jb     801b7c <__udivdi3+0x3c>
		{
		  q0 = 1;
  801baa:	bf 01 00 00 00       	mov    $0x1,%edi
  801baf:	eb cb                	jmp    801b7c <__udivdi3+0x3c>
  801bb1:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801bb4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bb7:	85 c0                	test   %eax,%eax
  801bb9:	75 0e                	jne    801bc9 <__udivdi3+0x89>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801bbb:	b8 01 00 00 00       	mov    $0x1,%eax
  801bc0:	31 c9                	xor    %ecx,%ecx
  801bc2:	31 d2                	xor    %edx,%edx
  801bc4:	f7 f1                	div    %ecx
  801bc6:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801bc9:	89 f0                	mov    %esi,%eax
  801bcb:	31 d2                	xor    %edx,%edx
  801bcd:	f7 75 e4             	divl   -0x1c(%ebp)
  801bd0:	89 45 ec             	mov    %eax,-0x14(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801bd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bd6:	f7 75 e4             	divl   -0x1c(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bd9:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bdc:	83 c4 14             	add    $0x14,%esp

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801bdf:	89 c7                	mov    %eax,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801be1:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801be2:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801be4:	5f                   	pop    %edi
  801be5:	c9                   	leave  
  801be6:	c3                   	ret    
  801be7:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801be8:	b8 20 00 00 00       	mov    $0x20,%eax
  801bed:	29 f8                	sub    %edi,%eax
  801bef:	89 45 e8             	mov    %eax,-0x18(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  801bf2:	89 f9                	mov    %edi,%ecx
  801bf4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bf7:	d3 e2                	shl    %cl,%edx
  801bf9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bfc:	8a 4d e8             	mov    -0x18(%ebp),%cl
  801bff:	d3 e8                	shr    %cl,%eax
  801c01:	09 c2                	or     %eax,%edx
	      d0 = d0 << bm;
  801c03:	89 f9                	mov    %edi,%ecx
  801c05:	d3 65 e4             	shll   %cl,-0x1c(%ebp)
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801c08:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801c0b:	8a 4d e8             	mov    -0x18(%ebp),%cl
  801c0e:	89 f2                	mov    %esi,%edx
  801c10:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  801c12:	89 f9                	mov    %edi,%ecx
  801c14:	d3 e6                	shl    %cl,%esi
  801c16:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c19:	8a 4d e8             	mov    -0x18(%ebp),%cl
  801c1c:	d3 e8                	shr    %cl,%eax
  801c1e:	09 c6                	or     %eax,%esi
	      n0 = n0 << bm;
  801c20:	89 f9                	mov    %edi,%ecx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801c22:	89 f0                	mov    %esi,%eax
  801c24:	f7 75 f4             	divl   -0xc(%ebp)
  801c27:	89 d6                	mov    %edx,%esi
  801c29:	89 c7                	mov    %eax,%edi

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801c2b:	d3 65 f0             	shll   %cl,-0x10(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  801c2e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c31:	f7 e7                	mul    %edi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c33:	39 f2                	cmp    %esi,%edx
  801c35:	77 0f                	ja     801c46 <__udivdi3+0x106>
  801c37:	0f 85 3f ff ff ff    	jne    801b7c <__udivdi3+0x3c>
  801c3d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  801c40:	0f 86 36 ff ff ff    	jbe    801b7c <__udivdi3+0x3c>
		{
		  q0--;
  801c46:	4f                   	dec    %edi
  801c47:	e9 30 ff ff ff       	jmp    801b7c <__udivdi3+0x3c>

00801c4c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801c4c:	55                   	push   %ebp
  801c4d:	89 e5                	mov    %esp,%ebp
  801c4f:	57                   	push   %edi
  801c50:	56                   	push   %esi
  801c51:	83 ec 30             	sub    $0x30,%esp
  801c54:	8b 55 14             	mov    0x14(%ebp),%edx
  801c57:	8b 45 10             	mov    0x10(%ebp),%eax
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  801c5a:	89 d7                	mov    %edx,%edi
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  801c5c:	8d 4d f0             	lea    -0x10(%ebp),%ecx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  801c5f:	89 c6                	mov    %eax,%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;
  801c61:	8b 55 0c             	mov    0xc(%ebp),%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801c64:	8b 45 08             	mov    0x8(%ebp),%eax
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801c67:	85 ff                	test   %edi,%edi
  801c69:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801c70:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  801c77:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801c7a:	89 45 dc             	mov    %eax,-0x24(%ebp)
  n1 = nn.s.high;
  801c7d:	89 55 cc             	mov    %edx,-0x34(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801c80:	75 3e                	jne    801cc0 <__umoddi3+0x74>
    {
      if (d0 > n1)
  801c82:	39 d6                	cmp    %edx,%esi
  801c84:	0f 86 a2 00 00 00    	jbe    801d2c <__umoddi3+0xe0>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c8a:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  801c8c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  801c8f:	85 c9                	test   %ecx,%ecx

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c91:	89 55 dc             	mov    %edx,-0x24(%ebp)

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  801c94:	74 1b                	je     801cb1 <__umoddi3+0x65>
	{
	  rr.s.low = n0;
  801c96:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801c99:	89 45 e0             	mov    %eax,-0x20(%ebp)
	  rr.s.high = 0;
  801c9c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801ca3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ca6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801ca9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801cac:	89 10                	mov    %edx,(%eax)
  801cae:	89 48 04             	mov    %ecx,0x4(%eax)
  801cb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cb4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801cb7:	83 c4 30             	add    $0x30,%esp
  801cba:	5e                   	pop    %esi
  801cbb:	5f                   	pop    %edi
  801cbc:	c9                   	leave  
  801cbd:	c3                   	ret    
  801cbe:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801cc0:	3b 7d cc             	cmp    -0x34(%ebp),%edi
  801cc3:	76 1f                	jbe    801ce4 <__umoddi3+0x98>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  801cc5:	8b 55 08             	mov    0x8(%ebp),%edx
	      rr.s.high = n1;
  801cc8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  801ccb:	89 55 e0             	mov    %edx,-0x20(%ebp)
	      rr.s.high = n1;
  801cce:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	      *rp = rr.ll;
  801cd1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801cd4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801cd7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801cda:	89 55 f4             	mov    %edx,-0xc(%ebp)
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801cdd:	83 c4 30             	add    $0x30,%esp
  801ce0:	5e                   	pop    %esi
  801ce1:	5f                   	pop    %edi
  801ce2:	c9                   	leave  
  801ce3:	c3                   	ret    
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801ce4:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801ce7:	83 f0 1f             	xor    $0x1f,%eax
  801cea:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801ced:	75 61                	jne    801d50 <__umoddi3+0x104>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801cef:	39 7d cc             	cmp    %edi,-0x34(%ebp)
  801cf2:	77 05                	ja     801cf9 <__umoddi3+0xad>
  801cf4:	39 75 dc             	cmp    %esi,-0x24(%ebp)
  801cf7:	72 10                	jb     801d09 <__umoddi3+0xbd>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801cf9:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801cfc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801cff:	29 f0                	sub    %esi,%eax
  801d01:	19 fa                	sbb    %edi,%edx
  801d03:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801d06:	89 55 cc             	mov    %edx,-0x34(%ebp)
	      else
		q0 = 0;

	      q1 = 0;

	      if (rp != 0)
  801d09:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801d0c:	85 d2                	test   %edx,%edx
  801d0e:	74 a1                	je     801cb1 <__umoddi3+0x65>
		{
		  rr.s.low = n0;
  801d10:	8b 45 dc             	mov    -0x24(%ebp),%eax
		  rr.s.high = n1;
  801d13:	8b 55 cc             	mov    -0x34(%ebp),%edx

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  801d16:	89 45 e0             	mov    %eax,-0x20(%ebp)
		  rr.s.high = n1;
  801d19:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		  *rp = rr.ll;
  801d1c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  801d1f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d22:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801d25:	89 01                	mov    %eax,(%ecx)
  801d27:	89 51 04             	mov    %edx,0x4(%ecx)
  801d2a:	eb 85                	jmp    801cb1 <__umoddi3+0x65>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d2c:	85 f6                	test   %esi,%esi
  801d2e:	75 0b                	jne    801d3b <__umoddi3+0xef>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d30:	b8 01 00 00 00       	mov    $0x1,%eax
  801d35:	31 d2                	xor    %edx,%edx
  801d37:	f7 f6                	div    %esi
  801d39:	89 c6                	mov    %eax,%esi

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d3b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801d3e:	89 fa                	mov    %edi,%edx
  801d40:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d42:	8b 45 dc             	mov    -0x24(%ebp),%eax
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d45:	89 55 cc             	mov    %edx,-0x34(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d48:	f7 f6                	div    %esi
  801d4a:	e9 3d ff ff ff       	jmp    801c8c <__umoddi3+0x40>
  801d4f:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801d50:	b8 20 00 00 00       	mov    $0x20,%eax
  801d55:	2b 45 d4             	sub    -0x2c(%ebp),%eax
  801d58:	89 45 d8             	mov    %eax,-0x28(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  801d5b:	89 fa                	mov    %edi,%edx
  801d5d:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  801d60:	d3 e2                	shl    %cl,%edx
  801d62:	89 f0                	mov    %esi,%eax
  801d64:	8a 4d d8             	mov    -0x28(%ebp),%cl
  801d67:	d3 e8                	shr    %cl,%eax
	      d0 = d0 << bm;
  801d69:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  801d6c:	d3 e6                	shl    %cl,%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801d6e:	89 d7                	mov    %edx,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801d70:	8a 4d d8             	mov    -0x28(%ebp),%cl
  801d73:	8b 55 cc             	mov    -0x34(%ebp),%edx
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801d76:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801d78:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  801d7a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801d7d:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  801d80:	d3 e0                	shl    %cl,%eax
  801d82:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801d85:	8a 4d d8             	mov    -0x28(%ebp),%cl
  801d88:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801d8b:	d3 e8                	shr    %cl,%eax
  801d8d:	0b 45 cc             	or     -0x34(%ebp),%eax
  801d90:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n0 = n0 << bm;
  801d93:	8a 4d d4             	mov    -0x2c(%ebp),%cl

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d96:	f7 f7                	div    %edi
  801d98:	89 55 cc             	mov    %edx,-0x34(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801d9b:	d3 65 dc             	shll   %cl,-0x24(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  801d9e:	f7 e6                	mul    %esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801da0:	3b 55 cc             	cmp    -0x34(%ebp),%edx
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  801da3:	89 45 c8             	mov    %eax,-0x38(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801da6:	77 0a                	ja     801db2 <__umoddi3+0x166>
  801da8:	75 12                	jne    801dbc <__umoddi3+0x170>
  801daa:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801dad:	39 45 c8             	cmp    %eax,-0x38(%ebp)
  801db0:	76 0a                	jbe    801dbc <__umoddi3+0x170>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801db2:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  801db5:	29 f1                	sub    %esi,%ecx
  801db7:	19 fa                	sbb    %edi,%edx
  801db9:	89 4d c8             	mov    %ecx,-0x38(%ebp)
		}

	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
  801dbc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801dbf:	85 c0                	test   %eax,%eax
  801dc1:	0f 84 ea fe ff ff    	je     801cb1 <__umoddi3+0x65>
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801dc7:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801dca:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801dcd:	2b 45 c8             	sub    -0x38(%ebp),%eax
  801dd0:	19 d1                	sbb    %edx,%ecx
  801dd2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801dd5:	89 ca                	mov    %ecx,%edx
  801dd7:	8a 4d d8             	mov    -0x28(%ebp),%cl
  801dda:	d3 e2                	shl    %cl,%edx
  801ddc:	8a 4d d4             	mov    -0x2c(%ebp),%cl
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801ddf:	89 45 dc             	mov    %eax,-0x24(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801de2:	d3 e8                	shr    %cl,%eax
  801de4:	09 c2                	or     %eax,%edx
		  rr.s.high = n1 >> bm;
  801de6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801de9:	d3 e8                	shr    %cl,%eax

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801deb:	89 55 e0             	mov    %edx,-0x20(%ebp)
		  rr.s.high = n1 >> bm;
  801dee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801df1:	e9 ad fe ff ff       	jmp    801ca3 <__umoddi3+0x57>
