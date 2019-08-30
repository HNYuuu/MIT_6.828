
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 00 11 00       	mov    $0x110000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 56 00 00 00       	call   f0100094 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 0c             	sub    $0xc,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	53                   	push   %ebx
f010004b:	68 e0 18 10 f0       	push   $0xf01018e0
f0100050:	e8 15 09 00 00       	call   f010096a <cprintf>
	if (x > 0)
f0100055:	83 c4 10             	add    $0x10,%esp
f0100058:	85 db                	test   %ebx,%ebx
f010005a:	7e 11                	jle    f010006d <test_backtrace+0x2d>
		test_backtrace(x-1);
f010005c:	83 ec 0c             	sub    $0xc,%esp
f010005f:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100062:	50                   	push   %eax
f0100063:	e8 d8 ff ff ff       	call   f0100040 <test_backtrace>
f0100068:	83 c4 10             	add    $0x10,%esp
f010006b:	eb 11                	jmp    f010007e <test_backtrace+0x3e>
	else
		mon_backtrace(0, 0, 0);
f010006d:	83 ec 04             	sub    $0x4,%esp
f0100070:	6a 00                	push   $0x0
f0100072:	6a 00                	push   $0x0
f0100074:	6a 00                	push   $0x0
f0100076:	e8 0a 07 00 00       	call   f0100785 <mon_backtrace>
f010007b:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007e:	83 ec 08             	sub    $0x8,%esp
f0100081:	53                   	push   %ebx
f0100082:	68 fc 18 10 f0       	push   $0xf01018fc
f0100087:	e8 de 08 00 00       	call   f010096a <cprintf>
}
f010008c:	83 c4 10             	add    $0x10,%esp
f010008f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100092:	c9                   	leave  
f0100093:	c3                   	ret    

f0100094 <i386_init>:

void
i386_init(void)
{
f0100094:	55                   	push   %ebp
f0100095:	89 e5                	mov    %esp,%ebp
f0100097:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f010009a:	b8 40 29 11 f0       	mov    $0xf0112940,%eax
f010009f:	2d 00 23 11 f0       	sub    $0xf0112300,%eax
f01000a4:	50                   	push   %eax
f01000a5:	6a 00                	push   $0x0
f01000a7:	68 00 23 11 f0       	push   $0xf0112300
f01000ac:	e8 81 13 00 00       	call   f0101432 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 9d 04 00 00       	call   f0100553 <cons_init>

	// cprintf("x=%d y=%d\n", 3);

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 17 19 10 f0       	push   $0xf0101917
f01000c3:	e8 a2 08 00 00       	call   f010096a <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000c8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000cf:	e8 6c ff ff ff       	call   f0100040 <test_backtrace>
f01000d4:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000d7:	83 ec 0c             	sub    $0xc,%esp
f01000da:	6a 00                	push   $0x0
f01000dc:	e8 1c 07 00 00       	call   f01007fd <monitor>
f01000e1:	83 c4 10             	add    $0x10,%esp
f01000e4:	eb f1                	jmp    f01000d7 <i386_init+0x43>

f01000e6 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000e6:	55                   	push   %ebp
f01000e7:	89 e5                	mov    %esp,%ebp
f01000e9:	56                   	push   %esi
f01000ea:	53                   	push   %ebx
f01000eb:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000ee:	83 3d 44 29 11 f0 00 	cmpl   $0x0,0xf0112944
f01000f5:	75 37                	jne    f010012e <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01000f7:	89 35 44 29 11 f0    	mov    %esi,0xf0112944

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f01000fd:	fa                   	cli    
f01000fe:	fc                   	cld    

	va_start(ap, fmt);
f01000ff:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100102:	83 ec 04             	sub    $0x4,%esp
f0100105:	ff 75 0c             	pushl  0xc(%ebp)
f0100108:	ff 75 08             	pushl  0x8(%ebp)
f010010b:	68 32 19 10 f0       	push   $0xf0101932
f0100110:	e8 55 08 00 00       	call   f010096a <cprintf>
	vcprintf(fmt, ap);
f0100115:	83 c4 08             	add    $0x8,%esp
f0100118:	53                   	push   %ebx
f0100119:	56                   	push   %esi
f010011a:	e8 25 08 00 00       	call   f0100944 <vcprintf>
	cprintf("\n");
f010011f:	c7 04 24 6e 19 10 f0 	movl   $0xf010196e,(%esp)
f0100126:	e8 3f 08 00 00       	call   f010096a <cprintf>
	va_end(ap);
f010012b:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010012e:	83 ec 0c             	sub    $0xc,%esp
f0100131:	6a 00                	push   $0x0
f0100133:	e8 c5 06 00 00       	call   f01007fd <monitor>
f0100138:	83 c4 10             	add    $0x10,%esp
f010013b:	eb f1                	jmp    f010012e <_panic+0x48>

f010013d <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010013d:	55                   	push   %ebp
f010013e:	89 e5                	mov    %esp,%ebp
f0100140:	53                   	push   %ebx
f0100141:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100144:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100147:	ff 75 0c             	pushl  0xc(%ebp)
f010014a:	ff 75 08             	pushl  0x8(%ebp)
f010014d:	68 4a 19 10 f0       	push   $0xf010194a
f0100152:	e8 13 08 00 00       	call   f010096a <cprintf>
	vcprintf(fmt, ap);
f0100157:	83 c4 08             	add    $0x8,%esp
f010015a:	53                   	push   %ebx
f010015b:	ff 75 10             	pushl  0x10(%ebp)
f010015e:	e8 e1 07 00 00       	call   f0100944 <vcprintf>
	cprintf("\n");
f0100163:	c7 04 24 6e 19 10 f0 	movl   $0xf010196e,(%esp)
f010016a:	e8 fb 07 00 00       	call   f010096a <cprintf>
	va_end(ap);
}
f010016f:	83 c4 10             	add    $0x10,%esp
f0100172:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100175:	c9                   	leave  
f0100176:	c3                   	ret    

f0100177 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100177:	55                   	push   %ebp
f0100178:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010017a:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010017f:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100180:	a8 01                	test   $0x1,%al
f0100182:	74 0b                	je     f010018f <serial_proc_data+0x18>
f0100184:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100189:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010018a:	0f b6 c0             	movzbl %al,%eax
f010018d:	eb 05                	jmp    f0100194 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010018f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100194:	5d                   	pop    %ebp
f0100195:	c3                   	ret    

f0100196 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100196:	55                   	push   %ebp
f0100197:	89 e5                	mov    %esp,%ebp
f0100199:	53                   	push   %ebx
f010019a:	83 ec 04             	sub    $0x4,%esp
f010019d:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010019f:	eb 2b                	jmp    f01001cc <cons_intr+0x36>
		if (c == 0)
f01001a1:	85 c0                	test   %eax,%eax
f01001a3:	74 27                	je     f01001cc <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01001a5:	8b 0d 24 25 11 f0    	mov    0xf0112524,%ecx
f01001ab:	8d 51 01             	lea    0x1(%ecx),%edx
f01001ae:	89 15 24 25 11 f0    	mov    %edx,0xf0112524
f01001b4:	88 81 20 23 11 f0    	mov    %al,-0xfeedce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01001ba:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001c0:	75 0a                	jne    f01001cc <cons_intr+0x36>
			cons.wpos = 0;
f01001c2:	c7 05 24 25 11 f0 00 	movl   $0x0,0xf0112524
f01001c9:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001cc:	ff d3                	call   *%ebx
f01001ce:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001d1:	75 ce                	jne    f01001a1 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001d3:	83 c4 04             	add    $0x4,%esp
f01001d6:	5b                   	pop    %ebx
f01001d7:	5d                   	pop    %ebp
f01001d8:	c3                   	ret    

f01001d9 <kbd_proc_data>:
f01001d9:	ba 64 00 00 00       	mov    $0x64,%edx
f01001de:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f01001df:	a8 01                	test   $0x1,%al
f01001e1:	0f 84 f8 00 00 00    	je     f01002df <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01001e7:	a8 20                	test   $0x20,%al
f01001e9:	0f 85 f6 00 00 00    	jne    f01002e5 <kbd_proc_data+0x10c>
f01001ef:	ba 60 00 00 00       	mov    $0x60,%edx
f01001f4:	ec                   	in     (%dx),%al
f01001f5:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001f7:	3c e0                	cmp    $0xe0,%al
f01001f9:	75 0d                	jne    f0100208 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01001fb:	83 0d 00 23 11 f0 40 	orl    $0x40,0xf0112300
		return 0;
f0100202:	b8 00 00 00 00       	mov    $0x0,%eax
f0100207:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100208:	55                   	push   %ebp
f0100209:	89 e5                	mov    %esp,%ebp
f010020b:	53                   	push   %ebx
f010020c:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f010020f:	84 c0                	test   %al,%al
f0100211:	79 36                	jns    f0100249 <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100213:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f0100219:	89 cb                	mov    %ecx,%ebx
f010021b:	83 e3 40             	and    $0x40,%ebx
f010021e:	83 e0 7f             	and    $0x7f,%eax
f0100221:	85 db                	test   %ebx,%ebx
f0100223:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100226:	0f b6 d2             	movzbl %dl,%edx
f0100229:	0f b6 82 c0 1a 10 f0 	movzbl -0xfefe540(%edx),%eax
f0100230:	83 c8 40             	or     $0x40,%eax
f0100233:	0f b6 c0             	movzbl %al,%eax
f0100236:	f7 d0                	not    %eax
f0100238:	21 c8                	and    %ecx,%eax
f010023a:	a3 00 23 11 f0       	mov    %eax,0xf0112300
		return 0;
f010023f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100244:	e9 a4 00 00 00       	jmp    f01002ed <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f0100249:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f010024f:	f6 c1 40             	test   $0x40,%cl
f0100252:	74 0e                	je     f0100262 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100254:	83 c8 80             	or     $0xffffff80,%eax
f0100257:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100259:	83 e1 bf             	and    $0xffffffbf,%ecx
f010025c:	89 0d 00 23 11 f0    	mov    %ecx,0xf0112300
	}

	shift |= shiftcode[data];
f0100262:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100265:	0f b6 82 c0 1a 10 f0 	movzbl -0xfefe540(%edx),%eax
f010026c:	0b 05 00 23 11 f0    	or     0xf0112300,%eax
f0100272:	0f b6 8a c0 19 10 f0 	movzbl -0xfefe640(%edx),%ecx
f0100279:	31 c8                	xor    %ecx,%eax
f010027b:	a3 00 23 11 f0       	mov    %eax,0xf0112300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100280:	89 c1                	mov    %eax,%ecx
f0100282:	83 e1 03             	and    $0x3,%ecx
f0100285:	8b 0c 8d a0 19 10 f0 	mov    -0xfefe660(,%ecx,4),%ecx
f010028c:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100290:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100293:	a8 08                	test   $0x8,%al
f0100295:	74 1b                	je     f01002b2 <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f0100297:	89 da                	mov    %ebx,%edx
f0100299:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010029c:	83 f9 19             	cmp    $0x19,%ecx
f010029f:	77 05                	ja     f01002a6 <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f01002a1:	83 eb 20             	sub    $0x20,%ebx
f01002a4:	eb 0c                	jmp    f01002b2 <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f01002a6:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002a9:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01002ac:	83 fa 19             	cmp    $0x19,%edx
f01002af:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002b2:	f7 d0                	not    %eax
f01002b4:	a8 06                	test   $0x6,%al
f01002b6:	75 33                	jne    f01002eb <kbd_proc_data+0x112>
f01002b8:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002be:	75 2b                	jne    f01002eb <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f01002c0:	83 ec 0c             	sub    $0xc,%esp
f01002c3:	68 64 19 10 f0       	push   $0xf0101964
f01002c8:	e8 9d 06 00 00       	call   f010096a <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002cd:	ba 92 00 00 00       	mov    $0x92,%edx
f01002d2:	b8 03 00 00 00       	mov    $0x3,%eax
f01002d7:	ee                   	out    %al,(%dx)
f01002d8:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002db:	89 d8                	mov    %ebx,%eax
f01002dd:	eb 0e                	jmp    f01002ed <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f01002df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01002e4:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f01002e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002ea:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002eb:	89 d8                	mov    %ebx,%eax
}
f01002ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002f0:	c9                   	leave  
f01002f1:	c3                   	ret    

f01002f2 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002f2:	55                   	push   %ebp
f01002f3:	89 e5                	mov    %esp,%ebp
f01002f5:	57                   	push   %edi
f01002f6:	56                   	push   %esi
f01002f7:	53                   	push   %ebx
f01002f8:	83 ec 1c             	sub    $0x1c,%esp
f01002fb:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002fd:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100302:	be fd 03 00 00       	mov    $0x3fd,%esi
f0100307:	b9 84 00 00 00       	mov    $0x84,%ecx
f010030c:	eb 09                	jmp    f0100317 <cons_putc+0x25>
f010030e:	89 ca                	mov    %ecx,%edx
f0100310:	ec                   	in     (%dx),%al
f0100311:	ec                   	in     (%dx),%al
f0100312:	ec                   	in     (%dx),%al
f0100313:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100314:	83 c3 01             	add    $0x1,%ebx
f0100317:	89 f2                	mov    %esi,%edx
f0100319:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010031a:	a8 20                	test   $0x20,%al
f010031c:	75 08                	jne    f0100326 <cons_putc+0x34>
f010031e:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100324:	7e e8                	jle    f010030e <cons_putc+0x1c>
f0100326:	89 f8                	mov    %edi,%eax
f0100328:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010032b:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100330:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100331:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100336:	be 79 03 00 00       	mov    $0x379,%esi
f010033b:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100340:	eb 09                	jmp    f010034b <cons_putc+0x59>
f0100342:	89 ca                	mov    %ecx,%edx
f0100344:	ec                   	in     (%dx),%al
f0100345:	ec                   	in     (%dx),%al
f0100346:	ec                   	in     (%dx),%al
f0100347:	ec                   	in     (%dx),%al
f0100348:	83 c3 01             	add    $0x1,%ebx
f010034b:	89 f2                	mov    %esi,%edx
f010034d:	ec                   	in     (%dx),%al
f010034e:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100354:	7f 04                	jg     f010035a <cons_putc+0x68>
f0100356:	84 c0                	test   %al,%al
f0100358:	79 e8                	jns    f0100342 <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010035a:	ba 78 03 00 00       	mov    $0x378,%edx
f010035f:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100363:	ee                   	out    %al,(%dx)
f0100364:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100369:	b8 0d 00 00 00       	mov    $0xd,%eax
f010036e:	ee                   	out    %al,(%dx)
f010036f:	b8 08 00 00 00       	mov    $0x8,%eax
f0100374:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100375:	89 fa                	mov    %edi,%edx
f0100377:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0200;
f010037d:	89 f8                	mov    %edi,%eax
f010037f:	80 cc 02             	or     $0x2,%ah
f0100382:	85 d2                	test   %edx,%edx
f0100384:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100387:	89 f8                	mov    %edi,%eax
f0100389:	0f b6 c0             	movzbl %al,%eax
f010038c:	83 f8 09             	cmp    $0x9,%eax
f010038f:	74 74                	je     f0100405 <cons_putc+0x113>
f0100391:	83 f8 09             	cmp    $0x9,%eax
f0100394:	7f 0a                	jg     f01003a0 <cons_putc+0xae>
f0100396:	83 f8 08             	cmp    $0x8,%eax
f0100399:	74 14                	je     f01003af <cons_putc+0xbd>
f010039b:	e9 99 00 00 00       	jmp    f0100439 <cons_putc+0x147>
f01003a0:	83 f8 0a             	cmp    $0xa,%eax
f01003a3:	74 3a                	je     f01003df <cons_putc+0xed>
f01003a5:	83 f8 0d             	cmp    $0xd,%eax
f01003a8:	74 3d                	je     f01003e7 <cons_putc+0xf5>
f01003aa:	e9 8a 00 00 00       	jmp    f0100439 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f01003af:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f01003b6:	66 85 c0             	test   %ax,%ax
f01003b9:	0f 84 e6 00 00 00    	je     f01004a5 <cons_putc+0x1b3>
			crt_pos--;
f01003bf:	83 e8 01             	sub    $0x1,%eax
f01003c2:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003c8:	0f b7 c0             	movzwl %ax,%eax
f01003cb:	66 81 e7 00 ff       	and    $0xff00,%di
f01003d0:	83 cf 20             	or     $0x20,%edi
f01003d3:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f01003d9:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003dd:	eb 78                	jmp    f0100457 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003df:	66 83 05 28 25 11 f0 	addw   $0x50,0xf0112528
f01003e6:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003e7:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f01003ee:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003f4:	c1 e8 16             	shr    $0x16,%eax
f01003f7:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003fa:	c1 e0 04             	shl    $0x4,%eax
f01003fd:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
f0100403:	eb 52                	jmp    f0100457 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f0100405:	b8 20 00 00 00       	mov    $0x20,%eax
f010040a:	e8 e3 fe ff ff       	call   f01002f2 <cons_putc>
		cons_putc(' ');
f010040f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100414:	e8 d9 fe ff ff       	call   f01002f2 <cons_putc>
		cons_putc(' ');
f0100419:	b8 20 00 00 00       	mov    $0x20,%eax
f010041e:	e8 cf fe ff ff       	call   f01002f2 <cons_putc>
		cons_putc(' ');
f0100423:	b8 20 00 00 00       	mov    $0x20,%eax
f0100428:	e8 c5 fe ff ff       	call   f01002f2 <cons_putc>
		cons_putc(' ');
f010042d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100432:	e8 bb fe ff ff       	call   f01002f2 <cons_putc>
f0100437:	eb 1e                	jmp    f0100457 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100439:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f0100440:	8d 50 01             	lea    0x1(%eax),%edx
f0100443:	66 89 15 28 25 11 f0 	mov    %dx,0xf0112528
f010044a:	0f b7 c0             	movzwl %ax,%eax
f010044d:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100453:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100457:	66 81 3d 28 25 11 f0 	cmpw   $0x7cf,0xf0112528
f010045e:	cf 07 
f0100460:	76 43                	jbe    f01004a5 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100462:	a1 2c 25 11 f0       	mov    0xf011252c,%eax
f0100467:	83 ec 04             	sub    $0x4,%esp
f010046a:	68 00 0f 00 00       	push   $0xf00
f010046f:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100475:	52                   	push   %edx
f0100476:	50                   	push   %eax
f0100477:	e8 03 10 00 00       	call   f010147f <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010047c:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100482:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100488:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010048e:	83 c4 10             	add    $0x10,%esp
f0100491:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100496:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100499:	39 d0                	cmp    %edx,%eax
f010049b:	75 f4                	jne    f0100491 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010049d:	66 83 2d 28 25 11 f0 	subw   $0x50,0xf0112528
f01004a4:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004a5:	8b 0d 30 25 11 f0    	mov    0xf0112530,%ecx
f01004ab:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004b0:	89 ca                	mov    %ecx,%edx
f01004b2:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004b3:	0f b7 1d 28 25 11 f0 	movzwl 0xf0112528,%ebx
f01004ba:	8d 71 01             	lea    0x1(%ecx),%esi
f01004bd:	89 d8                	mov    %ebx,%eax
f01004bf:	66 c1 e8 08          	shr    $0x8,%ax
f01004c3:	89 f2                	mov    %esi,%edx
f01004c5:	ee                   	out    %al,(%dx)
f01004c6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004cb:	89 ca                	mov    %ecx,%edx
f01004cd:	ee                   	out    %al,(%dx)
f01004ce:	89 d8                	mov    %ebx,%eax
f01004d0:	89 f2                	mov    %esi,%edx
f01004d2:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004d6:	5b                   	pop    %ebx
f01004d7:	5e                   	pop    %esi
f01004d8:	5f                   	pop    %edi
f01004d9:	5d                   	pop    %ebp
f01004da:	c3                   	ret    

f01004db <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01004db:	80 3d 34 25 11 f0 00 	cmpb   $0x0,0xf0112534
f01004e2:	74 11                	je     f01004f5 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004e4:	55                   	push   %ebp
f01004e5:	89 e5                	mov    %esp,%ebp
f01004e7:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01004ea:	b8 77 01 10 f0       	mov    $0xf0100177,%eax
f01004ef:	e8 a2 fc ff ff       	call   f0100196 <cons_intr>
}
f01004f4:	c9                   	leave  
f01004f5:	f3 c3                	repz ret 

f01004f7 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004f7:	55                   	push   %ebp
f01004f8:	89 e5                	mov    %esp,%ebp
f01004fa:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004fd:	b8 d9 01 10 f0       	mov    $0xf01001d9,%eax
f0100502:	e8 8f fc ff ff       	call   f0100196 <cons_intr>
}
f0100507:	c9                   	leave  
f0100508:	c3                   	ret    

f0100509 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100509:	55                   	push   %ebp
f010050a:	89 e5                	mov    %esp,%ebp
f010050c:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010050f:	e8 c7 ff ff ff       	call   f01004db <serial_intr>
	kbd_intr();
f0100514:	e8 de ff ff ff       	call   f01004f7 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100519:	a1 20 25 11 f0       	mov    0xf0112520,%eax
f010051e:	3b 05 24 25 11 f0    	cmp    0xf0112524,%eax
f0100524:	74 26                	je     f010054c <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100526:	8d 50 01             	lea    0x1(%eax),%edx
f0100529:	89 15 20 25 11 f0    	mov    %edx,0xf0112520
f010052f:	0f b6 88 20 23 11 f0 	movzbl -0xfeedce0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100536:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100538:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010053e:	75 11                	jne    f0100551 <cons_getc+0x48>
			cons.rpos = 0;
f0100540:	c7 05 20 25 11 f0 00 	movl   $0x0,0xf0112520
f0100547:	00 00 00 
f010054a:	eb 05                	jmp    f0100551 <cons_getc+0x48>
		return c;
	}
	return 0;
f010054c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100551:	c9                   	leave  
f0100552:	c3                   	ret    

f0100553 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100553:	55                   	push   %ebp
f0100554:	89 e5                	mov    %esp,%ebp
f0100556:	57                   	push   %edi
f0100557:	56                   	push   %esi
f0100558:	53                   	push   %ebx
f0100559:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010055c:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100563:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010056a:	5a a5 
	if (*cp != 0xA55A) {
f010056c:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100573:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100577:	74 11                	je     f010058a <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100579:	c7 05 30 25 11 f0 b4 	movl   $0x3b4,0xf0112530
f0100580:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100583:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100588:	eb 16                	jmp    f01005a0 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010058a:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100591:	c7 05 30 25 11 f0 d4 	movl   $0x3d4,0xf0112530
f0100598:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010059b:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01005a0:	8b 3d 30 25 11 f0    	mov    0xf0112530,%edi
f01005a6:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005ab:	89 fa                	mov    %edi,%edx
f01005ad:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005ae:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005b1:	89 da                	mov    %ebx,%edx
f01005b3:	ec                   	in     (%dx),%al
f01005b4:	0f b6 c8             	movzbl %al,%ecx
f01005b7:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005ba:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005bf:	89 fa                	mov    %edi,%edx
f01005c1:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005c2:	89 da                	mov    %ebx,%edx
f01005c4:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01005c5:	89 35 2c 25 11 f0    	mov    %esi,0xf011252c
	crt_pos = pos;
f01005cb:	0f b6 c0             	movzbl %al,%eax
f01005ce:	09 c8                	or     %ecx,%eax
f01005d0:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005d6:	be fa 03 00 00       	mov    $0x3fa,%esi
f01005db:	b8 00 00 00 00       	mov    $0x0,%eax
f01005e0:	89 f2                	mov    %esi,%edx
f01005e2:	ee                   	out    %al,(%dx)
f01005e3:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005e8:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005ed:	ee                   	out    %al,(%dx)
f01005ee:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01005f3:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005f8:	89 da                	mov    %ebx,%edx
f01005fa:	ee                   	out    %al,(%dx)
f01005fb:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100600:	b8 00 00 00 00       	mov    $0x0,%eax
f0100605:	ee                   	out    %al,(%dx)
f0100606:	ba fb 03 00 00       	mov    $0x3fb,%edx
f010060b:	b8 03 00 00 00       	mov    $0x3,%eax
f0100610:	ee                   	out    %al,(%dx)
f0100611:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100616:	b8 00 00 00 00       	mov    $0x0,%eax
f010061b:	ee                   	out    %al,(%dx)
f010061c:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100621:	b8 01 00 00 00       	mov    $0x1,%eax
f0100626:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100627:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010062c:	ec                   	in     (%dx),%al
f010062d:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010062f:	3c ff                	cmp    $0xff,%al
f0100631:	0f 95 05 34 25 11 f0 	setne  0xf0112534
f0100638:	89 f2                	mov    %esi,%edx
f010063a:	ec                   	in     (%dx),%al
f010063b:	89 da                	mov    %ebx,%edx
f010063d:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010063e:	80 f9 ff             	cmp    $0xff,%cl
f0100641:	75 10                	jne    f0100653 <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f0100643:	83 ec 0c             	sub    $0xc,%esp
f0100646:	68 70 19 10 f0       	push   $0xf0101970
f010064b:	e8 1a 03 00 00       	call   f010096a <cprintf>
f0100650:	83 c4 10             	add    $0x10,%esp
}
f0100653:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100656:	5b                   	pop    %ebx
f0100657:	5e                   	pop    %esi
f0100658:	5f                   	pop    %edi
f0100659:	5d                   	pop    %ebp
f010065a:	c3                   	ret    

f010065b <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010065b:	55                   	push   %ebp
f010065c:	89 e5                	mov    %esp,%ebp
f010065e:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100661:	8b 45 08             	mov    0x8(%ebp),%eax
f0100664:	e8 89 fc ff ff       	call   f01002f2 <cons_putc>
}
f0100669:	c9                   	leave  
f010066a:	c3                   	ret    

f010066b <getchar>:

int
getchar(void)
{
f010066b:	55                   	push   %ebp
f010066c:	89 e5                	mov    %esp,%ebp
f010066e:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100671:	e8 93 fe ff ff       	call   f0100509 <cons_getc>
f0100676:	85 c0                	test   %eax,%eax
f0100678:	74 f7                	je     f0100671 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010067a:	c9                   	leave  
f010067b:	c3                   	ret    

f010067c <iscons>:

int
iscons(int fdnum)
{
f010067c:	55                   	push   %ebp
f010067d:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010067f:	b8 01 00 00 00       	mov    $0x1,%eax
f0100684:	5d                   	pop    %ebp
f0100685:	c3                   	ret    

f0100686 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100686:	55                   	push   %ebp
f0100687:	89 e5                	mov    %esp,%ebp
f0100689:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010068c:	68 c0 1b 10 f0       	push   $0xf0101bc0
f0100691:	68 de 1b 10 f0       	push   $0xf0101bde
f0100696:	68 e3 1b 10 f0       	push   $0xf0101be3
f010069b:	e8 ca 02 00 00       	call   f010096a <cprintf>
f01006a0:	83 c4 0c             	add    $0xc,%esp
f01006a3:	68 80 1c 10 f0       	push   $0xf0101c80
f01006a8:	68 ec 1b 10 f0       	push   $0xf0101bec
f01006ad:	68 e3 1b 10 f0       	push   $0xf0101be3
f01006b2:	e8 b3 02 00 00       	call   f010096a <cprintf>
f01006b7:	83 c4 0c             	add    $0xc,%esp
f01006ba:	68 a8 1c 10 f0       	push   $0xf0101ca8
f01006bf:	68 f5 1b 10 f0       	push   $0xf0101bf5
f01006c4:	68 e3 1b 10 f0       	push   $0xf0101be3
f01006c9:	e8 9c 02 00 00       	call   f010096a <cprintf>
	return 0;
}
f01006ce:	b8 00 00 00 00       	mov    $0x0,%eax
f01006d3:	c9                   	leave  
f01006d4:	c3                   	ret    

f01006d5 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006d5:	55                   	push   %ebp
f01006d6:	89 e5                	mov    %esp,%ebp
f01006d8:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006db:	68 ff 1b 10 f0       	push   $0xf0101bff
f01006e0:	e8 85 02 00 00       	call   f010096a <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006e5:	83 c4 08             	add    $0x8,%esp
f01006e8:	68 0c 00 10 00       	push   $0x10000c
f01006ed:	68 d0 1c 10 f0       	push   $0xf0101cd0
f01006f2:	e8 73 02 00 00       	call   f010096a <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006f7:	83 c4 0c             	add    $0xc,%esp
f01006fa:	68 0c 00 10 00       	push   $0x10000c
f01006ff:	68 0c 00 10 f0       	push   $0xf010000c
f0100704:	68 f8 1c 10 f0       	push   $0xf0101cf8
f0100709:	e8 5c 02 00 00       	call   f010096a <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010070e:	83 c4 0c             	add    $0xc,%esp
f0100711:	68 c1 18 10 00       	push   $0x1018c1
f0100716:	68 c1 18 10 f0       	push   $0xf01018c1
f010071b:	68 1c 1d 10 f0       	push   $0xf0101d1c
f0100720:	e8 45 02 00 00       	call   f010096a <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100725:	83 c4 0c             	add    $0xc,%esp
f0100728:	68 00 23 11 00       	push   $0x112300
f010072d:	68 00 23 11 f0       	push   $0xf0112300
f0100732:	68 40 1d 10 f0       	push   $0xf0101d40
f0100737:	e8 2e 02 00 00       	call   f010096a <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010073c:	83 c4 0c             	add    $0xc,%esp
f010073f:	68 40 29 11 00       	push   $0x112940
f0100744:	68 40 29 11 f0       	push   $0xf0112940
f0100749:	68 64 1d 10 f0       	push   $0xf0101d64
f010074e:	e8 17 02 00 00       	call   f010096a <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100753:	b8 3f 2d 11 f0       	mov    $0xf0112d3f,%eax
f0100758:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010075d:	83 c4 08             	add    $0x8,%esp
f0100760:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100765:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010076b:	85 c0                	test   %eax,%eax
f010076d:	0f 48 c2             	cmovs  %edx,%eax
f0100770:	c1 f8 0a             	sar    $0xa,%eax
f0100773:	50                   	push   %eax
f0100774:	68 88 1d 10 f0       	push   $0xf0101d88
f0100779:	e8 ec 01 00 00       	call   f010096a <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f010077e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100783:	c9                   	leave  
f0100784:	c3                   	ret    

f0100785 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100785:	55                   	push   %ebp
f0100786:	89 e5                	mov    %esp,%ebp
f0100788:	57                   	push   %edi
f0100789:	56                   	push   %esi
f010078a:	53                   	push   %ebx
f010078b:	83 ec 38             	sub    $0x38,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f010078e:	89 eb                	mov    %ebp,%ebx
	int j;

	uint32_t ebp = read_ebp();
	uint32_t eip = 0;
	#define TO_INT(x)  *((uint32_t*)(x))
	cprintf("Stack backtrace:\n");
f0100790:	68 18 1c 10 f0       	push   $0xf0101c18
f0100795:	e8 d0 01 00 00       	call   f010096a <cprintf>
	while (ebp) {
f010079a:	83 c4 10             	add    $0x10,%esp
			TO_INT((ebp+20)),
			TO_INT((ebp+24)));
		
		// stab here
		struct Eipdebuginfo eip_debug_info;
		debuginfo_eip(eip, &eip_debug_info);
f010079d:	8d 7d d0             	lea    -0x30(%ebp),%edi

	uint32_t ebp = read_ebp();
	uint32_t eip = 0;
	#define TO_INT(x)  *((uint32_t*)(x))
	cprintf("Stack backtrace:\n");
	while (ebp) {
f01007a0:	eb 4a                	jmp    f01007ec <mon_backtrace+0x67>
		eip = TO_INT((ebp+4));
f01007a2:	8b 73 04             	mov    0x4(%ebx),%esi
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n",
f01007a5:	ff 73 18             	pushl  0x18(%ebx)
f01007a8:	ff 73 14             	pushl  0x14(%ebx)
f01007ab:	ff 73 10             	pushl  0x10(%ebx)
f01007ae:	ff 73 0c             	pushl  0xc(%ebx)
f01007b1:	ff 73 08             	pushl  0x8(%ebx)
f01007b4:	56                   	push   %esi
f01007b5:	53                   	push   %ebx
f01007b6:	68 b4 1d 10 f0       	push   $0xf0101db4
f01007bb:	e8 aa 01 00 00       	call   f010096a <cprintf>
			TO_INT((ebp+20)),
			TO_INT((ebp+24)));
		
		// stab here
		struct Eipdebuginfo eip_debug_info;
		debuginfo_eip(eip, &eip_debug_info);
f01007c0:	83 c4 18             	add    $0x18,%esp
f01007c3:	57                   	push   %edi
f01007c4:	56                   	push   %esi
f01007c5:	e8 aa 02 00 00       	call   f0100a74 <debuginfo_eip>

		uint32_t offset = eip - eip_debug_info.eip_fn_addr;
		cprintf("         %s:%d: %.*s+%d\n", eip_debug_info.eip_file, eip_debug_info.eip_line, eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name, offset);
f01007ca:	83 c4 08             	add    $0x8,%esp
f01007cd:	2b 75 e0             	sub    -0x20(%ebp),%esi
f01007d0:	56                   	push   %esi
f01007d1:	ff 75 d8             	pushl  -0x28(%ebp)
f01007d4:	ff 75 dc             	pushl  -0x24(%ebp)
f01007d7:	ff 75 d4             	pushl  -0x2c(%ebp)
f01007da:	ff 75 d0             	pushl  -0x30(%ebp)
f01007dd:	68 2a 1c 10 f0       	push   $0xf0101c2a
f01007e2:	e8 83 01 00 00       	call   f010096a <cprintf>

		ebp = TO_INT(ebp);
f01007e7:	8b 1b                	mov    (%ebx),%ebx
f01007e9:	83 c4 20             	add    $0x20,%esp

	uint32_t ebp = read_ebp();
	uint32_t eip = 0;
	#define TO_INT(x)  *((uint32_t*)(x))
	cprintf("Stack backtrace:\n");
	while (ebp) {
f01007ec:	85 db                	test   %ebx,%ebx
f01007ee:	75 b2                	jne    f01007a2 <mon_backtrace+0x1d>
		cprintf("         %s:%d: %.*s+%d\n", eip_debug_info.eip_file, eip_debug_info.eip_line, eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name, offset);

		ebp = TO_INT(ebp);
	}
	return 0;
}
f01007f0:	b8 00 00 00 00       	mov    $0x0,%eax
f01007f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01007f8:	5b                   	pop    %ebx
f01007f9:	5e                   	pop    %esi
f01007fa:	5f                   	pop    %edi
f01007fb:	5d                   	pop    %ebp
f01007fc:	c3                   	ret    

f01007fd <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01007fd:	55                   	push   %ebp
f01007fe:	89 e5                	mov    %esp,%ebp
f0100800:	57                   	push   %edi
f0100801:	56                   	push   %esi
f0100802:	53                   	push   %ebx
f0100803:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100806:	68 ec 1d 10 f0       	push   $0xf0101dec
f010080b:	e8 5a 01 00 00       	call   f010096a <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100810:	c7 04 24 10 1e 10 f0 	movl   $0xf0101e10,(%esp)
f0100817:	e8 4e 01 00 00       	call   f010096a <cprintf>
f010081c:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f010081f:	83 ec 0c             	sub    $0xc,%esp
f0100822:	68 43 1c 10 f0       	push   $0xf0101c43
f0100827:	e8 af 09 00 00       	call   f01011db <readline>
f010082c:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010082e:	83 c4 10             	add    $0x10,%esp
f0100831:	85 c0                	test   %eax,%eax
f0100833:	74 ea                	je     f010081f <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100835:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010083c:	be 00 00 00 00       	mov    $0x0,%esi
f0100841:	eb 0a                	jmp    f010084d <monitor+0x50>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100843:	c6 03 00             	movb   $0x0,(%ebx)
f0100846:	89 f7                	mov    %esi,%edi
f0100848:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010084b:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010084d:	0f b6 03             	movzbl (%ebx),%eax
f0100850:	84 c0                	test   %al,%al
f0100852:	74 63                	je     f01008b7 <monitor+0xba>
f0100854:	83 ec 08             	sub    $0x8,%esp
f0100857:	0f be c0             	movsbl %al,%eax
f010085a:	50                   	push   %eax
f010085b:	68 47 1c 10 f0       	push   $0xf0101c47
f0100860:	e8 90 0b 00 00       	call   f01013f5 <strchr>
f0100865:	83 c4 10             	add    $0x10,%esp
f0100868:	85 c0                	test   %eax,%eax
f010086a:	75 d7                	jne    f0100843 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f010086c:	80 3b 00             	cmpb   $0x0,(%ebx)
f010086f:	74 46                	je     f01008b7 <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100871:	83 fe 0f             	cmp    $0xf,%esi
f0100874:	75 14                	jne    f010088a <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100876:	83 ec 08             	sub    $0x8,%esp
f0100879:	6a 10                	push   $0x10
f010087b:	68 4c 1c 10 f0       	push   $0xf0101c4c
f0100880:	e8 e5 00 00 00       	call   f010096a <cprintf>
f0100885:	83 c4 10             	add    $0x10,%esp
f0100888:	eb 95                	jmp    f010081f <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f010088a:	8d 7e 01             	lea    0x1(%esi),%edi
f010088d:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100891:	eb 03                	jmp    f0100896 <monitor+0x99>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100893:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100896:	0f b6 03             	movzbl (%ebx),%eax
f0100899:	84 c0                	test   %al,%al
f010089b:	74 ae                	je     f010084b <monitor+0x4e>
f010089d:	83 ec 08             	sub    $0x8,%esp
f01008a0:	0f be c0             	movsbl %al,%eax
f01008a3:	50                   	push   %eax
f01008a4:	68 47 1c 10 f0       	push   $0xf0101c47
f01008a9:	e8 47 0b 00 00       	call   f01013f5 <strchr>
f01008ae:	83 c4 10             	add    $0x10,%esp
f01008b1:	85 c0                	test   %eax,%eax
f01008b3:	74 de                	je     f0100893 <monitor+0x96>
f01008b5:	eb 94                	jmp    f010084b <monitor+0x4e>
			buf++;
	}
	argv[argc] = 0;
f01008b7:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008be:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008bf:	85 f6                	test   %esi,%esi
f01008c1:	0f 84 58 ff ff ff    	je     f010081f <monitor+0x22>
f01008c7:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008cc:	83 ec 08             	sub    $0x8,%esp
f01008cf:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01008d2:	ff 34 85 40 1e 10 f0 	pushl  -0xfefe1c0(,%eax,4)
f01008d9:	ff 75 a8             	pushl  -0x58(%ebp)
f01008dc:	e8 b6 0a 00 00       	call   f0101397 <strcmp>
f01008e1:	83 c4 10             	add    $0x10,%esp
f01008e4:	85 c0                	test   %eax,%eax
f01008e6:	75 21                	jne    f0100909 <monitor+0x10c>
			return commands[i].func(argc, argv, tf);
f01008e8:	83 ec 04             	sub    $0x4,%esp
f01008eb:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01008ee:	ff 75 08             	pushl  0x8(%ebp)
f01008f1:	8d 55 a8             	lea    -0x58(%ebp),%edx
f01008f4:	52                   	push   %edx
f01008f5:	56                   	push   %esi
f01008f6:	ff 14 85 48 1e 10 f0 	call   *-0xfefe1b8(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01008fd:	83 c4 10             	add    $0x10,%esp
f0100900:	85 c0                	test   %eax,%eax
f0100902:	78 25                	js     f0100929 <monitor+0x12c>
f0100904:	e9 16 ff ff ff       	jmp    f010081f <monitor+0x22>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100909:	83 c3 01             	add    $0x1,%ebx
f010090c:	83 fb 03             	cmp    $0x3,%ebx
f010090f:	75 bb                	jne    f01008cc <monitor+0xcf>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100911:	83 ec 08             	sub    $0x8,%esp
f0100914:	ff 75 a8             	pushl  -0x58(%ebp)
f0100917:	68 69 1c 10 f0       	push   $0xf0101c69
f010091c:	e8 49 00 00 00       	call   f010096a <cprintf>
f0100921:	83 c4 10             	add    $0x10,%esp
f0100924:	e9 f6 fe ff ff       	jmp    f010081f <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100929:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010092c:	5b                   	pop    %ebx
f010092d:	5e                   	pop    %esi
f010092e:	5f                   	pop    %edi
f010092f:	5d                   	pop    %ebp
f0100930:	c3                   	ret    

f0100931 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100931:	55                   	push   %ebp
f0100932:	89 e5                	mov    %esp,%ebp
f0100934:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0100937:	ff 75 08             	pushl  0x8(%ebp)
f010093a:	e8 1c fd ff ff       	call   f010065b <cputchar>
	*cnt++;
}
f010093f:	83 c4 10             	add    $0x10,%esp
f0100942:	c9                   	leave  
f0100943:	c3                   	ret    

f0100944 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100944:	55                   	push   %ebp
f0100945:	89 e5                	mov    %esp,%ebp
f0100947:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010094a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100951:	ff 75 0c             	pushl  0xc(%ebp)
f0100954:	ff 75 08             	pushl  0x8(%ebp)
f0100957:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010095a:	50                   	push   %eax
f010095b:	68 31 09 10 f0       	push   $0xf0100931
f0100960:	e8 61 04 00 00       	call   f0100dc6 <vprintfmt>
	return cnt;
}
f0100965:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100968:	c9                   	leave  
f0100969:	c3                   	ret    

f010096a <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010096a:	55                   	push   %ebp
f010096b:	89 e5                	mov    %esp,%ebp
f010096d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100970:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100973:	50                   	push   %eax
f0100974:	ff 75 08             	pushl  0x8(%ebp)
f0100977:	e8 c8 ff ff ff       	call   f0100944 <vcprintf>
	va_end(ap);

	return cnt;
}
f010097c:	c9                   	leave  
f010097d:	c3                   	ret    

f010097e <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010097e:	55                   	push   %ebp
f010097f:	89 e5                	mov    %esp,%ebp
f0100981:	57                   	push   %edi
f0100982:	56                   	push   %esi
f0100983:	53                   	push   %ebx
f0100984:	83 ec 14             	sub    $0x14,%esp
f0100987:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010098a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010098d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100990:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100993:	8b 1a                	mov    (%edx),%ebx
f0100995:	8b 01                	mov    (%ecx),%eax
f0100997:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010099a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01009a1:	eb 7f                	jmp    f0100a22 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f01009a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01009a6:	01 d8                	add    %ebx,%eax
f01009a8:	89 c6                	mov    %eax,%esi
f01009aa:	c1 ee 1f             	shr    $0x1f,%esi
f01009ad:	01 c6                	add    %eax,%esi
f01009af:	d1 fe                	sar    %esi
f01009b1:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01009b4:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01009b7:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01009ba:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01009bc:	eb 03                	jmp    f01009c1 <stab_binsearch+0x43>
			m--;
f01009be:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01009c1:	39 c3                	cmp    %eax,%ebx
f01009c3:	7f 0d                	jg     f01009d2 <stab_binsearch+0x54>
f01009c5:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01009c9:	83 ea 0c             	sub    $0xc,%edx
f01009cc:	39 f9                	cmp    %edi,%ecx
f01009ce:	75 ee                	jne    f01009be <stab_binsearch+0x40>
f01009d0:	eb 05                	jmp    f01009d7 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01009d2:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f01009d5:	eb 4b                	jmp    f0100a22 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01009d7:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01009da:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01009dd:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01009e1:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01009e4:	76 11                	jbe    f01009f7 <stab_binsearch+0x79>
			*region_left = m;
f01009e6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01009e9:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f01009eb:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01009ee:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01009f5:	eb 2b                	jmp    f0100a22 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01009f7:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01009fa:	73 14                	jae    f0100a10 <stab_binsearch+0x92>
			*region_right = m - 1;
f01009fc:	83 e8 01             	sub    $0x1,%eax
f01009ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100a02:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100a05:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a07:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100a0e:	eb 12                	jmp    f0100a22 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100a10:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a13:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100a15:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100a19:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a1b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100a22:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100a25:	0f 8e 78 ff ff ff    	jle    f01009a3 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100a2b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100a2f:	75 0f                	jne    f0100a40 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0100a31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a34:	8b 00                	mov    (%eax),%eax
f0100a36:	83 e8 01             	sub    $0x1,%eax
f0100a39:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100a3c:	89 06                	mov    %eax,(%esi)
f0100a3e:	eb 2c                	jmp    f0100a6c <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a40:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a43:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100a45:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a48:	8b 0e                	mov    (%esi),%ecx
f0100a4a:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100a4d:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100a50:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a53:	eb 03                	jmp    f0100a58 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100a55:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a58:	39 c8                	cmp    %ecx,%eax
f0100a5a:	7e 0b                	jle    f0100a67 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0100a5c:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0100a60:	83 ea 0c             	sub    $0xc,%edx
f0100a63:	39 df                	cmp    %ebx,%edi
f0100a65:	75 ee                	jne    f0100a55 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100a67:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a6a:	89 06                	mov    %eax,(%esi)
	}
}
f0100a6c:	83 c4 14             	add    $0x14,%esp
f0100a6f:	5b                   	pop    %ebx
f0100a70:	5e                   	pop    %esi
f0100a71:	5f                   	pop    %edi
f0100a72:	5d                   	pop    %ebp
f0100a73:	c3                   	ret    

f0100a74 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100a74:	55                   	push   %ebp
f0100a75:	89 e5                	mov    %esp,%ebp
f0100a77:	57                   	push   %edi
f0100a78:	56                   	push   %esi
f0100a79:	53                   	push   %ebx
f0100a7a:	83 ec 3c             	sub    $0x3c,%esp
f0100a7d:	8b 75 08             	mov    0x8(%ebp),%esi
f0100a80:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100a83:	c7 03 64 1e 10 f0    	movl   $0xf0101e64,(%ebx)
	info->eip_line = 0;
f0100a89:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100a90:	c7 43 08 64 1e 10 f0 	movl   $0xf0101e64,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100a97:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100a9e:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100aa1:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100aa8:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100aae:	76 11                	jbe    f0100ac1 <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100ab0:	b8 a0 73 10 f0       	mov    $0xf01073a0,%eax
f0100ab5:	3d 75 5a 10 f0       	cmp    $0xf0105a75,%eax
f0100aba:	77 19                	ja     f0100ad5 <debuginfo_eip+0x61>
f0100abc:	e9 b9 01 00 00       	jmp    f0100c7a <debuginfo_eip+0x206>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100ac1:	83 ec 04             	sub    $0x4,%esp
f0100ac4:	68 6e 1e 10 f0       	push   $0xf0101e6e
f0100ac9:	6a 7f                	push   $0x7f
f0100acb:	68 7b 1e 10 f0       	push   $0xf0101e7b
f0100ad0:	e8 11 f6 ff ff       	call   f01000e6 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100ad5:	80 3d 9f 73 10 f0 00 	cmpb   $0x0,0xf010739f
f0100adc:	0f 85 9f 01 00 00    	jne    f0100c81 <debuginfo_eip+0x20d>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100ae2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100ae9:	b8 74 5a 10 f0       	mov    $0xf0105a74,%eax
f0100aee:	2d 9c 20 10 f0       	sub    $0xf010209c,%eax
f0100af3:	c1 f8 02             	sar    $0x2,%eax
f0100af6:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100afc:	83 e8 01             	sub    $0x1,%eax
f0100aff:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100b02:	83 ec 08             	sub    $0x8,%esp
f0100b05:	56                   	push   %esi
f0100b06:	6a 64                	push   $0x64
f0100b08:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100b0b:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100b0e:	b8 9c 20 10 f0       	mov    $0xf010209c,%eax
f0100b13:	e8 66 fe ff ff       	call   f010097e <stab_binsearch>
	if (lfile == 0)
f0100b18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b1b:	83 c4 10             	add    $0x10,%esp
f0100b1e:	85 c0                	test   %eax,%eax
f0100b20:	0f 84 62 01 00 00    	je     f0100c88 <debuginfo_eip+0x214>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100b26:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100b29:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b2c:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100b2f:	83 ec 08             	sub    $0x8,%esp
f0100b32:	56                   	push   %esi
f0100b33:	6a 24                	push   $0x24
f0100b35:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100b38:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b3b:	b8 9c 20 10 f0       	mov    $0xf010209c,%eax
f0100b40:	e8 39 fe ff ff       	call   f010097e <stab_binsearch>

	if (lfun <= rfun) {
f0100b45:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100b48:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100b4b:	83 c4 10             	add    $0x10,%esp
f0100b4e:	39 d0                	cmp    %edx,%eax
f0100b50:	7f 40                	jg     f0100b92 <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100b52:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100b55:	c1 e1 02             	shl    $0x2,%ecx
f0100b58:	8d b9 9c 20 10 f0    	lea    -0xfefdf64(%ecx),%edi
f0100b5e:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0100b61:	8b b9 9c 20 10 f0    	mov    -0xfefdf64(%ecx),%edi
f0100b67:	b9 a0 73 10 f0       	mov    $0xf01073a0,%ecx
f0100b6c:	81 e9 75 5a 10 f0    	sub    $0xf0105a75,%ecx
f0100b72:	39 cf                	cmp    %ecx,%edi
f0100b74:	73 09                	jae    f0100b7f <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100b76:	81 c7 75 5a 10 f0    	add    $0xf0105a75,%edi
f0100b7c:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100b7f:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100b82:	8b 4f 08             	mov    0x8(%edi),%ecx
f0100b85:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0100b88:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0100b8a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100b8d:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0100b90:	eb 0f                	jmp    f0100ba1 <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100b92:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100b95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b98:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100b9b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b9e:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100ba1:	83 ec 08             	sub    $0x8,%esp
f0100ba4:	6a 3a                	push   $0x3a
f0100ba6:	ff 73 08             	pushl  0x8(%ebx)
f0100ba9:	e8 68 08 00 00       	call   f0101416 <strfind>
f0100bae:	2b 43 08             	sub    0x8(%ebx),%eax
f0100bb1:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100bb4:	83 c4 08             	add    $0x8,%esp
f0100bb7:	56                   	push   %esi
f0100bb8:	6a 44                	push   $0x44
f0100bba:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100bbd:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100bc0:	b8 9c 20 10 f0       	mov    $0xf010209c,%eax
f0100bc5:	e8 b4 fd ff ff       	call   f010097e <stab_binsearch>
	if (lline <= rline) {
f0100bca:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100bcd:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0100bd0:	83 c4 10             	add    $0x10,%esp
f0100bd3:	39 d0                	cmp    %edx,%eax
f0100bd5:	7f 0e                	jg     f0100be5 <debuginfo_eip+0x171>
		// found
		info->eip_line = stabs[rline].n_desc;
f0100bd7:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100bda:	0f b7 14 95 a2 20 10 	movzwl -0xfefdf5e(,%edx,4),%edx
f0100be1:	f0 
f0100be2:	89 53 04             	mov    %edx,0x4(%ebx)
	}
	if (lline == 0) {
f0100be5:	85 c0                	test   %eax,%eax
f0100be7:	0f 84 a2 00 00 00    	je     f0100c8f <debuginfo_eip+0x21b>
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100bed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100bf0:	89 c2                	mov    %eax,%edx
f0100bf2:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100bf5:	8d 04 85 9c 20 10 f0 	lea    -0xfefdf64(,%eax,4),%eax
f0100bfc:	eb 06                	jmp    f0100c04 <debuginfo_eip+0x190>
f0100bfe:	83 ea 01             	sub    $0x1,%edx
f0100c01:	83 e8 0c             	sub    $0xc,%eax
f0100c04:	39 d7                	cmp    %edx,%edi
f0100c06:	7f 34                	jg     f0100c3c <debuginfo_eip+0x1c8>
	       && stabs[lline].n_type != N_SOL
f0100c08:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f0100c0c:	80 f9 84             	cmp    $0x84,%cl
f0100c0f:	74 0b                	je     f0100c1c <debuginfo_eip+0x1a8>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100c11:	80 f9 64             	cmp    $0x64,%cl
f0100c14:	75 e8                	jne    f0100bfe <debuginfo_eip+0x18a>
f0100c16:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0100c1a:	74 e2                	je     f0100bfe <debuginfo_eip+0x18a>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100c1c:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0100c1f:	8b 14 85 9c 20 10 f0 	mov    -0xfefdf64(,%eax,4),%edx
f0100c26:	b8 a0 73 10 f0       	mov    $0xf01073a0,%eax
f0100c2b:	2d 75 5a 10 f0       	sub    $0xf0105a75,%eax
f0100c30:	39 c2                	cmp    %eax,%edx
f0100c32:	73 08                	jae    f0100c3c <debuginfo_eip+0x1c8>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100c34:	81 c2 75 5a 10 f0    	add    $0xf0105a75,%edx
f0100c3a:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100c3c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100c3f:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c42:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100c47:	39 f2                	cmp    %esi,%edx
f0100c49:	7d 50                	jge    f0100c9b <debuginfo_eip+0x227>
		for (lline = lfun + 1;
f0100c4b:	83 c2 01             	add    $0x1,%edx
f0100c4e:	89 d0                	mov    %edx,%eax
f0100c50:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100c53:	8d 14 95 9c 20 10 f0 	lea    -0xfefdf64(,%edx,4),%edx
f0100c5a:	eb 04                	jmp    f0100c60 <debuginfo_eip+0x1ec>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100c5c:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100c60:	39 c6                	cmp    %eax,%esi
f0100c62:	7e 32                	jle    f0100c96 <debuginfo_eip+0x222>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100c64:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100c68:	83 c0 01             	add    $0x1,%eax
f0100c6b:	83 c2 0c             	add    $0xc,%edx
f0100c6e:	80 f9 a0             	cmp    $0xa0,%cl
f0100c71:	74 e9                	je     f0100c5c <debuginfo_eip+0x1e8>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c73:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c78:	eb 21                	jmp    f0100c9b <debuginfo_eip+0x227>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100c7a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c7f:	eb 1a                	jmp    f0100c9b <debuginfo_eip+0x227>
f0100c81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c86:	eb 13                	jmp    f0100c9b <debuginfo_eip+0x227>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0100c88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c8d:	eb 0c                	jmp    f0100c9b <debuginfo_eip+0x227>
	if (lline <= rline) {
		// found
		info->eip_line = stabs[rline].n_desc;
	}
	if (lline == 0) {
		return -1;
f0100c8f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c94:	eb 05                	jmp    f0100c9b <debuginfo_eip+0x227>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c96:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100c9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c9e:	5b                   	pop    %ebx
f0100c9f:	5e                   	pop    %esi
f0100ca0:	5f                   	pop    %edi
f0100ca1:	5d                   	pop    %ebp
f0100ca2:	c3                   	ret    

f0100ca3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100ca3:	55                   	push   %ebp
f0100ca4:	89 e5                	mov    %esp,%ebp
f0100ca6:	57                   	push   %edi
f0100ca7:	56                   	push   %esi
f0100ca8:	53                   	push   %ebx
f0100ca9:	83 ec 1c             	sub    $0x1c,%esp
f0100cac:	89 c7                	mov    %eax,%edi
f0100cae:	89 d6                	mov    %edx,%esi
f0100cb0:	8b 45 08             	mov    0x8(%ebp),%eax
f0100cb3:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100cb6:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100cb9:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100cbc:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100cbf:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100cc4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100cc7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0100cca:	39 d3                	cmp    %edx,%ebx
f0100ccc:	72 05                	jb     f0100cd3 <printnum+0x30>
f0100cce:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100cd1:	77 45                	ja     f0100d18 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100cd3:	83 ec 0c             	sub    $0xc,%esp
f0100cd6:	ff 75 18             	pushl  0x18(%ebp)
f0100cd9:	8b 45 14             	mov    0x14(%ebp),%eax
f0100cdc:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100cdf:	53                   	push   %ebx
f0100ce0:	ff 75 10             	pushl  0x10(%ebp)
f0100ce3:	83 ec 08             	sub    $0x8,%esp
f0100ce6:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100ce9:	ff 75 e0             	pushl  -0x20(%ebp)
f0100cec:	ff 75 dc             	pushl  -0x24(%ebp)
f0100cef:	ff 75 d8             	pushl  -0x28(%ebp)
f0100cf2:	e8 49 09 00 00       	call   f0101640 <__udivdi3>
f0100cf7:	83 c4 18             	add    $0x18,%esp
f0100cfa:	52                   	push   %edx
f0100cfb:	50                   	push   %eax
f0100cfc:	89 f2                	mov    %esi,%edx
f0100cfe:	89 f8                	mov    %edi,%eax
f0100d00:	e8 9e ff ff ff       	call   f0100ca3 <printnum>
f0100d05:	83 c4 20             	add    $0x20,%esp
f0100d08:	eb 18                	jmp    f0100d22 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100d0a:	83 ec 08             	sub    $0x8,%esp
f0100d0d:	56                   	push   %esi
f0100d0e:	ff 75 18             	pushl  0x18(%ebp)
f0100d11:	ff d7                	call   *%edi
f0100d13:	83 c4 10             	add    $0x10,%esp
f0100d16:	eb 03                	jmp    f0100d1b <printnum+0x78>
f0100d18:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100d1b:	83 eb 01             	sub    $0x1,%ebx
f0100d1e:	85 db                	test   %ebx,%ebx
f0100d20:	7f e8                	jg     f0100d0a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100d22:	83 ec 08             	sub    $0x8,%esp
f0100d25:	56                   	push   %esi
f0100d26:	83 ec 04             	sub    $0x4,%esp
f0100d29:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100d2c:	ff 75 e0             	pushl  -0x20(%ebp)
f0100d2f:	ff 75 dc             	pushl  -0x24(%ebp)
f0100d32:	ff 75 d8             	pushl  -0x28(%ebp)
f0100d35:	e8 36 0a 00 00       	call   f0101770 <__umoddi3>
f0100d3a:	83 c4 14             	add    $0x14,%esp
f0100d3d:	0f be 80 89 1e 10 f0 	movsbl -0xfefe177(%eax),%eax
f0100d44:	50                   	push   %eax
f0100d45:	ff d7                	call   *%edi
}
f0100d47:	83 c4 10             	add    $0x10,%esp
f0100d4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d4d:	5b                   	pop    %ebx
f0100d4e:	5e                   	pop    %esi
f0100d4f:	5f                   	pop    %edi
f0100d50:	5d                   	pop    %ebp
f0100d51:	c3                   	ret    

f0100d52 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100d52:	55                   	push   %ebp
f0100d53:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100d55:	83 fa 01             	cmp    $0x1,%edx
f0100d58:	7e 0e                	jle    f0100d68 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100d5a:	8b 10                	mov    (%eax),%edx
f0100d5c:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100d5f:	89 08                	mov    %ecx,(%eax)
f0100d61:	8b 02                	mov    (%edx),%eax
f0100d63:	8b 52 04             	mov    0x4(%edx),%edx
f0100d66:	eb 22                	jmp    f0100d8a <getuint+0x38>
	else if (lflag)
f0100d68:	85 d2                	test   %edx,%edx
f0100d6a:	74 10                	je     f0100d7c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100d6c:	8b 10                	mov    (%eax),%edx
f0100d6e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100d71:	89 08                	mov    %ecx,(%eax)
f0100d73:	8b 02                	mov    (%edx),%eax
f0100d75:	ba 00 00 00 00       	mov    $0x0,%edx
f0100d7a:	eb 0e                	jmp    f0100d8a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100d7c:	8b 10                	mov    (%eax),%edx
f0100d7e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100d81:	89 08                	mov    %ecx,(%eax)
f0100d83:	8b 02                	mov    (%edx),%eax
f0100d85:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100d8a:	5d                   	pop    %ebp
f0100d8b:	c3                   	ret    

f0100d8c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100d8c:	55                   	push   %ebp
f0100d8d:	89 e5                	mov    %esp,%ebp
f0100d8f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100d92:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100d96:	8b 10                	mov    (%eax),%edx
f0100d98:	3b 50 04             	cmp    0x4(%eax),%edx
f0100d9b:	73 0a                	jae    f0100da7 <sprintputch+0x1b>
		*b->buf++ = ch;
f0100d9d:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100da0:	89 08                	mov    %ecx,(%eax)
f0100da2:	8b 45 08             	mov    0x8(%ebp),%eax
f0100da5:	88 02                	mov    %al,(%edx)
}
f0100da7:	5d                   	pop    %ebp
f0100da8:	c3                   	ret    

f0100da9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100da9:	55                   	push   %ebp
f0100daa:	89 e5                	mov    %esp,%ebp
f0100dac:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100daf:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100db2:	50                   	push   %eax
f0100db3:	ff 75 10             	pushl  0x10(%ebp)
f0100db6:	ff 75 0c             	pushl  0xc(%ebp)
f0100db9:	ff 75 08             	pushl  0x8(%ebp)
f0100dbc:	e8 05 00 00 00       	call   f0100dc6 <vprintfmt>
	va_end(ap);
}
f0100dc1:	83 c4 10             	add    $0x10,%esp
f0100dc4:	c9                   	leave  
f0100dc5:	c3                   	ret    

f0100dc6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100dc6:	55                   	push   %ebp
f0100dc7:	89 e5                	mov    %esp,%ebp
f0100dc9:	57                   	push   %edi
f0100dca:	56                   	push   %esi
f0100dcb:	53                   	push   %ebx
f0100dcc:	83 ec 2c             	sub    $0x2c,%esp
f0100dcf:	8b 75 08             	mov    0x8(%ebp),%esi
f0100dd2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100dd5:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100dd8:	eb 12                	jmp    f0100dec <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100dda:	85 c0                	test   %eax,%eax
f0100ddc:	0f 84 89 03 00 00    	je     f010116b <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0100de2:	83 ec 08             	sub    $0x8,%esp
f0100de5:	53                   	push   %ebx
f0100de6:	50                   	push   %eax
f0100de7:	ff d6                	call   *%esi
f0100de9:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100dec:	83 c7 01             	add    $0x1,%edi
f0100def:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0100df3:	83 f8 25             	cmp    $0x25,%eax
f0100df6:	75 e2                	jne    f0100dda <vprintfmt+0x14>
f0100df8:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0100dfc:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100e03:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100e0a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0100e11:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e16:	eb 07                	jmp    f0100e1f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e18:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0100e1b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e1f:	8d 47 01             	lea    0x1(%edi),%eax
f0100e22:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100e25:	0f b6 07             	movzbl (%edi),%eax
f0100e28:	0f b6 c8             	movzbl %al,%ecx
f0100e2b:	83 e8 23             	sub    $0x23,%eax
f0100e2e:	3c 55                	cmp    $0x55,%al
f0100e30:	0f 87 1a 03 00 00    	ja     f0101150 <vprintfmt+0x38a>
f0100e36:	0f b6 c0             	movzbl %al,%eax
f0100e39:	ff 24 85 18 1f 10 f0 	jmp    *-0xfefe0e8(,%eax,4)
f0100e40:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100e43:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100e47:	eb d6                	jmp    f0100e1f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e49:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100e4c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e51:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100e54:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100e57:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0100e5b:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0100e5e:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0100e61:	83 fa 09             	cmp    $0x9,%edx
f0100e64:	77 39                	ja     f0100e9f <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100e66:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0100e69:	eb e9                	jmp    f0100e54 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100e6b:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e6e:	8d 48 04             	lea    0x4(%eax),%ecx
f0100e71:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0100e74:	8b 00                	mov    (%eax),%eax
f0100e76:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e79:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0100e7c:	eb 27                	jmp    f0100ea5 <vprintfmt+0xdf>
f0100e7e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e81:	85 c0                	test   %eax,%eax
f0100e83:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100e88:	0f 49 c8             	cmovns %eax,%ecx
f0100e8b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e8e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100e91:	eb 8c                	jmp    f0100e1f <vprintfmt+0x59>
f0100e93:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0100e96:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0100e9d:	eb 80                	jmp    f0100e1f <vprintfmt+0x59>
f0100e9f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100ea2:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0100ea5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100ea9:	0f 89 70 ff ff ff    	jns    f0100e1f <vprintfmt+0x59>
				width = precision, precision = -1;
f0100eaf:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100eb2:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100eb5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100ebc:	e9 5e ff ff ff       	jmp    f0100e1f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100ec1:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ec4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0100ec7:	e9 53 ff ff ff       	jmp    f0100e1f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100ecc:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ecf:	8d 50 04             	lea    0x4(%eax),%edx
f0100ed2:	89 55 14             	mov    %edx,0x14(%ebp)
f0100ed5:	83 ec 08             	sub    $0x8,%esp
f0100ed8:	53                   	push   %ebx
f0100ed9:	ff 30                	pushl  (%eax)
f0100edb:	ff d6                	call   *%esi
			break;
f0100edd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ee0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0100ee3:	e9 04 ff ff ff       	jmp    f0100dec <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100ee8:	8b 45 14             	mov    0x14(%ebp),%eax
f0100eeb:	8d 50 04             	lea    0x4(%eax),%edx
f0100eee:	89 55 14             	mov    %edx,0x14(%ebp)
f0100ef1:	8b 00                	mov    (%eax),%eax
f0100ef3:	99                   	cltd   
f0100ef4:	31 d0                	xor    %edx,%eax
f0100ef6:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100ef8:	83 f8 06             	cmp    $0x6,%eax
f0100efb:	7f 0b                	jg     f0100f08 <vprintfmt+0x142>
f0100efd:	8b 14 85 70 20 10 f0 	mov    -0xfefdf90(,%eax,4),%edx
f0100f04:	85 d2                	test   %edx,%edx
f0100f06:	75 18                	jne    f0100f20 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0100f08:	50                   	push   %eax
f0100f09:	68 a1 1e 10 f0       	push   $0xf0101ea1
f0100f0e:	53                   	push   %ebx
f0100f0f:	56                   	push   %esi
f0100f10:	e8 94 fe ff ff       	call   f0100da9 <printfmt>
f0100f15:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f18:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0100f1b:	e9 cc fe ff ff       	jmp    f0100dec <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0100f20:	52                   	push   %edx
f0100f21:	68 aa 1e 10 f0       	push   $0xf0101eaa
f0100f26:	53                   	push   %ebx
f0100f27:	56                   	push   %esi
f0100f28:	e8 7c fe ff ff       	call   f0100da9 <printfmt>
f0100f2d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f30:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100f33:	e9 b4 fe ff ff       	jmp    f0100dec <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100f38:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f3b:	8d 50 04             	lea    0x4(%eax),%edx
f0100f3e:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f41:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0100f43:	85 ff                	test   %edi,%edi
f0100f45:	b8 9a 1e 10 f0       	mov    $0xf0101e9a,%eax
f0100f4a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0100f4d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100f51:	0f 8e 94 00 00 00    	jle    f0100feb <vprintfmt+0x225>
f0100f57:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0100f5b:	0f 84 98 00 00 00    	je     f0100ff9 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f61:	83 ec 08             	sub    $0x8,%esp
f0100f64:	ff 75 d0             	pushl  -0x30(%ebp)
f0100f67:	57                   	push   %edi
f0100f68:	e8 5f 03 00 00       	call   f01012cc <strnlen>
f0100f6d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100f70:	29 c1                	sub    %eax,%ecx
f0100f72:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0100f75:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0100f78:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0100f7c:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100f7f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100f82:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f84:	eb 0f                	jmp    f0100f95 <vprintfmt+0x1cf>
					putch(padc, putdat);
f0100f86:	83 ec 08             	sub    $0x8,%esp
f0100f89:	53                   	push   %ebx
f0100f8a:	ff 75 e0             	pushl  -0x20(%ebp)
f0100f8d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f8f:	83 ef 01             	sub    $0x1,%edi
f0100f92:	83 c4 10             	add    $0x10,%esp
f0100f95:	85 ff                	test   %edi,%edi
f0100f97:	7f ed                	jg     f0100f86 <vprintfmt+0x1c0>
f0100f99:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100f9c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0100f9f:	85 c9                	test   %ecx,%ecx
f0100fa1:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fa6:	0f 49 c1             	cmovns %ecx,%eax
f0100fa9:	29 c1                	sub    %eax,%ecx
f0100fab:	89 75 08             	mov    %esi,0x8(%ebp)
f0100fae:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100fb1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100fb4:	89 cb                	mov    %ecx,%ebx
f0100fb6:	eb 4d                	jmp    f0101005 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0100fb8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0100fbc:	74 1b                	je     f0100fd9 <vprintfmt+0x213>
f0100fbe:	0f be c0             	movsbl %al,%eax
f0100fc1:	83 e8 20             	sub    $0x20,%eax
f0100fc4:	83 f8 5e             	cmp    $0x5e,%eax
f0100fc7:	76 10                	jbe    f0100fd9 <vprintfmt+0x213>
					putch('?', putdat);
f0100fc9:	83 ec 08             	sub    $0x8,%esp
f0100fcc:	ff 75 0c             	pushl  0xc(%ebp)
f0100fcf:	6a 3f                	push   $0x3f
f0100fd1:	ff 55 08             	call   *0x8(%ebp)
f0100fd4:	83 c4 10             	add    $0x10,%esp
f0100fd7:	eb 0d                	jmp    f0100fe6 <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0100fd9:	83 ec 08             	sub    $0x8,%esp
f0100fdc:	ff 75 0c             	pushl  0xc(%ebp)
f0100fdf:	52                   	push   %edx
f0100fe0:	ff 55 08             	call   *0x8(%ebp)
f0100fe3:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100fe6:	83 eb 01             	sub    $0x1,%ebx
f0100fe9:	eb 1a                	jmp    f0101005 <vprintfmt+0x23f>
f0100feb:	89 75 08             	mov    %esi,0x8(%ebp)
f0100fee:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100ff1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100ff4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100ff7:	eb 0c                	jmp    f0101005 <vprintfmt+0x23f>
f0100ff9:	89 75 08             	mov    %esi,0x8(%ebp)
f0100ffc:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100fff:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101002:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101005:	83 c7 01             	add    $0x1,%edi
f0101008:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010100c:	0f be d0             	movsbl %al,%edx
f010100f:	85 d2                	test   %edx,%edx
f0101011:	74 23                	je     f0101036 <vprintfmt+0x270>
f0101013:	85 f6                	test   %esi,%esi
f0101015:	78 a1                	js     f0100fb8 <vprintfmt+0x1f2>
f0101017:	83 ee 01             	sub    $0x1,%esi
f010101a:	79 9c                	jns    f0100fb8 <vprintfmt+0x1f2>
f010101c:	89 df                	mov    %ebx,%edi
f010101e:	8b 75 08             	mov    0x8(%ebp),%esi
f0101021:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101024:	eb 18                	jmp    f010103e <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0101026:	83 ec 08             	sub    $0x8,%esp
f0101029:	53                   	push   %ebx
f010102a:	6a 20                	push   $0x20
f010102c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010102e:	83 ef 01             	sub    $0x1,%edi
f0101031:	83 c4 10             	add    $0x10,%esp
f0101034:	eb 08                	jmp    f010103e <vprintfmt+0x278>
f0101036:	89 df                	mov    %ebx,%edi
f0101038:	8b 75 08             	mov    0x8(%ebp),%esi
f010103b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010103e:	85 ff                	test   %edi,%edi
f0101040:	7f e4                	jg     f0101026 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101042:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101045:	e9 a2 fd ff ff       	jmp    f0100dec <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010104a:	83 fa 01             	cmp    $0x1,%edx
f010104d:	7e 16                	jle    f0101065 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f010104f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101052:	8d 50 08             	lea    0x8(%eax),%edx
f0101055:	89 55 14             	mov    %edx,0x14(%ebp)
f0101058:	8b 50 04             	mov    0x4(%eax),%edx
f010105b:	8b 00                	mov    (%eax),%eax
f010105d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101060:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101063:	eb 32                	jmp    f0101097 <vprintfmt+0x2d1>
	else if (lflag)
f0101065:	85 d2                	test   %edx,%edx
f0101067:	74 18                	je     f0101081 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0101069:	8b 45 14             	mov    0x14(%ebp),%eax
f010106c:	8d 50 04             	lea    0x4(%eax),%edx
f010106f:	89 55 14             	mov    %edx,0x14(%ebp)
f0101072:	8b 00                	mov    (%eax),%eax
f0101074:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101077:	89 c1                	mov    %eax,%ecx
f0101079:	c1 f9 1f             	sar    $0x1f,%ecx
f010107c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010107f:	eb 16                	jmp    f0101097 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0101081:	8b 45 14             	mov    0x14(%ebp),%eax
f0101084:	8d 50 04             	lea    0x4(%eax),%edx
f0101087:	89 55 14             	mov    %edx,0x14(%ebp)
f010108a:	8b 00                	mov    (%eax),%eax
f010108c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010108f:	89 c1                	mov    %eax,%ecx
f0101091:	c1 f9 1f             	sar    $0x1f,%ecx
f0101094:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0101097:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010109a:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010109d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01010a2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01010a6:	79 74                	jns    f010111c <vprintfmt+0x356>
				putch('-', putdat);
f01010a8:	83 ec 08             	sub    $0x8,%esp
f01010ab:	53                   	push   %ebx
f01010ac:	6a 2d                	push   $0x2d
f01010ae:	ff d6                	call   *%esi
				num = -(long long) num;
f01010b0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01010b3:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01010b6:	f7 d8                	neg    %eax
f01010b8:	83 d2 00             	adc    $0x0,%edx
f01010bb:	f7 da                	neg    %edx
f01010bd:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f01010c0:	b9 0a 00 00 00       	mov    $0xa,%ecx
f01010c5:	eb 55                	jmp    f010111c <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01010c7:	8d 45 14             	lea    0x14(%ebp),%eax
f01010ca:	e8 83 fc ff ff       	call   f0100d52 <getuint>
			base = 10;
f01010cf:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f01010d4:	eb 46                	jmp    f010111c <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f01010d6:	8d 45 14             	lea    0x14(%ebp),%eax
f01010d9:	e8 74 fc ff ff       	call   f0100d52 <getuint>
			base = 8;
f01010de:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f01010e3:	eb 37                	jmp    f010111c <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f01010e5:	83 ec 08             	sub    $0x8,%esp
f01010e8:	53                   	push   %ebx
f01010e9:	6a 30                	push   $0x30
f01010eb:	ff d6                	call   *%esi
			putch('x', putdat);
f01010ed:	83 c4 08             	add    $0x8,%esp
f01010f0:	53                   	push   %ebx
f01010f1:	6a 78                	push   $0x78
f01010f3:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01010f5:	8b 45 14             	mov    0x14(%ebp),%eax
f01010f8:	8d 50 04             	lea    0x4(%eax),%edx
f01010fb:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01010fe:	8b 00                	mov    (%eax),%eax
f0101100:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0101105:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0101108:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f010110d:	eb 0d                	jmp    f010111c <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010110f:	8d 45 14             	lea    0x14(%ebp),%eax
f0101112:	e8 3b fc ff ff       	call   f0100d52 <getuint>
			base = 16;
f0101117:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f010111c:	83 ec 0c             	sub    $0xc,%esp
f010111f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0101123:	57                   	push   %edi
f0101124:	ff 75 e0             	pushl  -0x20(%ebp)
f0101127:	51                   	push   %ecx
f0101128:	52                   	push   %edx
f0101129:	50                   	push   %eax
f010112a:	89 da                	mov    %ebx,%edx
f010112c:	89 f0                	mov    %esi,%eax
f010112e:	e8 70 fb ff ff       	call   f0100ca3 <printnum>
			break;
f0101133:	83 c4 20             	add    $0x20,%esp
f0101136:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101139:	e9 ae fc ff ff       	jmp    f0100dec <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010113e:	83 ec 08             	sub    $0x8,%esp
f0101141:	53                   	push   %ebx
f0101142:	51                   	push   %ecx
f0101143:	ff d6                	call   *%esi
			break;
f0101145:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101148:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f010114b:	e9 9c fc ff ff       	jmp    f0100dec <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0101150:	83 ec 08             	sub    $0x8,%esp
f0101153:	53                   	push   %ebx
f0101154:	6a 25                	push   $0x25
f0101156:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101158:	83 c4 10             	add    $0x10,%esp
f010115b:	eb 03                	jmp    f0101160 <vprintfmt+0x39a>
f010115d:	83 ef 01             	sub    $0x1,%edi
f0101160:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0101164:	75 f7                	jne    f010115d <vprintfmt+0x397>
f0101166:	e9 81 fc ff ff       	jmp    f0100dec <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f010116b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010116e:	5b                   	pop    %ebx
f010116f:	5e                   	pop    %esi
f0101170:	5f                   	pop    %edi
f0101171:	5d                   	pop    %ebp
f0101172:	c3                   	ret    

f0101173 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101173:	55                   	push   %ebp
f0101174:	89 e5                	mov    %esp,%ebp
f0101176:	83 ec 18             	sub    $0x18,%esp
f0101179:	8b 45 08             	mov    0x8(%ebp),%eax
f010117c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010117f:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101182:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101186:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101189:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0101190:	85 c0                	test   %eax,%eax
f0101192:	74 26                	je     f01011ba <vsnprintf+0x47>
f0101194:	85 d2                	test   %edx,%edx
f0101196:	7e 22                	jle    f01011ba <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101198:	ff 75 14             	pushl  0x14(%ebp)
f010119b:	ff 75 10             	pushl  0x10(%ebp)
f010119e:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01011a1:	50                   	push   %eax
f01011a2:	68 8c 0d 10 f0       	push   $0xf0100d8c
f01011a7:	e8 1a fc ff ff       	call   f0100dc6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01011ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01011af:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01011b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01011b5:	83 c4 10             	add    $0x10,%esp
f01011b8:	eb 05                	jmp    f01011bf <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01011ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01011bf:	c9                   	leave  
f01011c0:	c3                   	ret    

f01011c1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01011c1:	55                   	push   %ebp
f01011c2:	89 e5                	mov    %esp,%ebp
f01011c4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01011c7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01011ca:	50                   	push   %eax
f01011cb:	ff 75 10             	pushl  0x10(%ebp)
f01011ce:	ff 75 0c             	pushl  0xc(%ebp)
f01011d1:	ff 75 08             	pushl  0x8(%ebp)
f01011d4:	e8 9a ff ff ff       	call   f0101173 <vsnprintf>
	va_end(ap);

	return rc;
}
f01011d9:	c9                   	leave  
f01011da:	c3                   	ret    

f01011db <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01011db:	55                   	push   %ebp
f01011dc:	89 e5                	mov    %esp,%ebp
f01011de:	57                   	push   %edi
f01011df:	56                   	push   %esi
f01011e0:	53                   	push   %ebx
f01011e1:	83 ec 0c             	sub    $0xc,%esp
f01011e4:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01011e7:	85 c0                	test   %eax,%eax
f01011e9:	74 11                	je     f01011fc <readline+0x21>
		cprintf("%s", prompt);
f01011eb:	83 ec 08             	sub    $0x8,%esp
f01011ee:	50                   	push   %eax
f01011ef:	68 aa 1e 10 f0       	push   $0xf0101eaa
f01011f4:	e8 71 f7 ff ff       	call   f010096a <cprintf>
f01011f9:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01011fc:	83 ec 0c             	sub    $0xc,%esp
f01011ff:	6a 00                	push   $0x0
f0101201:	e8 76 f4 ff ff       	call   f010067c <iscons>
f0101206:	89 c7                	mov    %eax,%edi
f0101208:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010120b:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0101210:	e8 56 f4 ff ff       	call   f010066b <getchar>
f0101215:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0101217:	85 c0                	test   %eax,%eax
f0101219:	79 18                	jns    f0101233 <readline+0x58>
			cprintf("read error: %e\n", c);
f010121b:	83 ec 08             	sub    $0x8,%esp
f010121e:	50                   	push   %eax
f010121f:	68 8c 20 10 f0       	push   $0xf010208c
f0101224:	e8 41 f7 ff ff       	call   f010096a <cprintf>
			return NULL;
f0101229:	83 c4 10             	add    $0x10,%esp
f010122c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101231:	eb 79                	jmp    f01012ac <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101233:	83 f8 08             	cmp    $0x8,%eax
f0101236:	0f 94 c2             	sete   %dl
f0101239:	83 f8 7f             	cmp    $0x7f,%eax
f010123c:	0f 94 c0             	sete   %al
f010123f:	08 c2                	or     %al,%dl
f0101241:	74 1a                	je     f010125d <readline+0x82>
f0101243:	85 f6                	test   %esi,%esi
f0101245:	7e 16                	jle    f010125d <readline+0x82>
			if (echoing)
f0101247:	85 ff                	test   %edi,%edi
f0101249:	74 0d                	je     f0101258 <readline+0x7d>
				cputchar('\b');
f010124b:	83 ec 0c             	sub    $0xc,%esp
f010124e:	6a 08                	push   $0x8
f0101250:	e8 06 f4 ff ff       	call   f010065b <cputchar>
f0101255:	83 c4 10             	add    $0x10,%esp
			i--;
f0101258:	83 ee 01             	sub    $0x1,%esi
f010125b:	eb b3                	jmp    f0101210 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010125d:	83 fb 1f             	cmp    $0x1f,%ebx
f0101260:	7e 23                	jle    f0101285 <readline+0xaa>
f0101262:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101268:	7f 1b                	jg     f0101285 <readline+0xaa>
			if (echoing)
f010126a:	85 ff                	test   %edi,%edi
f010126c:	74 0c                	je     f010127a <readline+0x9f>
				cputchar(c);
f010126e:	83 ec 0c             	sub    $0xc,%esp
f0101271:	53                   	push   %ebx
f0101272:	e8 e4 f3 ff ff       	call   f010065b <cputchar>
f0101277:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f010127a:	88 9e 40 25 11 f0    	mov    %bl,-0xfeedac0(%esi)
f0101280:	8d 76 01             	lea    0x1(%esi),%esi
f0101283:	eb 8b                	jmp    f0101210 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0101285:	83 fb 0a             	cmp    $0xa,%ebx
f0101288:	74 05                	je     f010128f <readline+0xb4>
f010128a:	83 fb 0d             	cmp    $0xd,%ebx
f010128d:	75 81                	jne    f0101210 <readline+0x35>
			if (echoing)
f010128f:	85 ff                	test   %edi,%edi
f0101291:	74 0d                	je     f01012a0 <readline+0xc5>
				cputchar('\n');
f0101293:	83 ec 0c             	sub    $0xc,%esp
f0101296:	6a 0a                	push   $0xa
f0101298:	e8 be f3 ff ff       	call   f010065b <cputchar>
f010129d:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01012a0:	c6 86 40 25 11 f0 00 	movb   $0x0,-0xfeedac0(%esi)
			return buf;
f01012a7:	b8 40 25 11 f0       	mov    $0xf0112540,%eax
		}
	}
}
f01012ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012af:	5b                   	pop    %ebx
f01012b0:	5e                   	pop    %esi
f01012b1:	5f                   	pop    %edi
f01012b2:	5d                   	pop    %ebp
f01012b3:	c3                   	ret    

f01012b4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01012b4:	55                   	push   %ebp
f01012b5:	89 e5                	mov    %esp,%ebp
f01012b7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01012ba:	b8 00 00 00 00       	mov    $0x0,%eax
f01012bf:	eb 03                	jmp    f01012c4 <strlen+0x10>
		n++;
f01012c1:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01012c4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01012c8:	75 f7                	jne    f01012c1 <strlen+0xd>
		n++;
	return n;
}
f01012ca:	5d                   	pop    %ebp
f01012cb:	c3                   	ret    

f01012cc <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01012cc:	55                   	push   %ebp
f01012cd:	89 e5                	mov    %esp,%ebp
f01012cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01012d2:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01012d5:	ba 00 00 00 00       	mov    $0x0,%edx
f01012da:	eb 03                	jmp    f01012df <strnlen+0x13>
		n++;
f01012dc:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01012df:	39 c2                	cmp    %eax,%edx
f01012e1:	74 08                	je     f01012eb <strnlen+0x1f>
f01012e3:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f01012e7:	75 f3                	jne    f01012dc <strnlen+0x10>
f01012e9:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f01012eb:	5d                   	pop    %ebp
f01012ec:	c3                   	ret    

f01012ed <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01012ed:	55                   	push   %ebp
f01012ee:	89 e5                	mov    %esp,%ebp
f01012f0:	53                   	push   %ebx
f01012f1:	8b 45 08             	mov    0x8(%ebp),%eax
f01012f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01012f7:	89 c2                	mov    %eax,%edx
f01012f9:	83 c2 01             	add    $0x1,%edx
f01012fc:	83 c1 01             	add    $0x1,%ecx
f01012ff:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0101303:	88 5a ff             	mov    %bl,-0x1(%edx)
f0101306:	84 db                	test   %bl,%bl
f0101308:	75 ef                	jne    f01012f9 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010130a:	5b                   	pop    %ebx
f010130b:	5d                   	pop    %ebp
f010130c:	c3                   	ret    

f010130d <strcat>:

char *
strcat(char *dst, const char *src)
{
f010130d:	55                   	push   %ebp
f010130e:	89 e5                	mov    %esp,%ebp
f0101310:	53                   	push   %ebx
f0101311:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101314:	53                   	push   %ebx
f0101315:	e8 9a ff ff ff       	call   f01012b4 <strlen>
f010131a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010131d:	ff 75 0c             	pushl  0xc(%ebp)
f0101320:	01 d8                	add    %ebx,%eax
f0101322:	50                   	push   %eax
f0101323:	e8 c5 ff ff ff       	call   f01012ed <strcpy>
	return dst;
}
f0101328:	89 d8                	mov    %ebx,%eax
f010132a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010132d:	c9                   	leave  
f010132e:	c3                   	ret    

f010132f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010132f:	55                   	push   %ebp
f0101330:	89 e5                	mov    %esp,%ebp
f0101332:	56                   	push   %esi
f0101333:	53                   	push   %ebx
f0101334:	8b 75 08             	mov    0x8(%ebp),%esi
f0101337:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010133a:	89 f3                	mov    %esi,%ebx
f010133c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010133f:	89 f2                	mov    %esi,%edx
f0101341:	eb 0f                	jmp    f0101352 <strncpy+0x23>
		*dst++ = *src;
f0101343:	83 c2 01             	add    $0x1,%edx
f0101346:	0f b6 01             	movzbl (%ecx),%eax
f0101349:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010134c:	80 39 01             	cmpb   $0x1,(%ecx)
f010134f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101352:	39 da                	cmp    %ebx,%edx
f0101354:	75 ed                	jne    f0101343 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0101356:	89 f0                	mov    %esi,%eax
f0101358:	5b                   	pop    %ebx
f0101359:	5e                   	pop    %esi
f010135a:	5d                   	pop    %ebp
f010135b:	c3                   	ret    

f010135c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010135c:	55                   	push   %ebp
f010135d:	89 e5                	mov    %esp,%ebp
f010135f:	56                   	push   %esi
f0101360:	53                   	push   %ebx
f0101361:	8b 75 08             	mov    0x8(%ebp),%esi
f0101364:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101367:	8b 55 10             	mov    0x10(%ebp),%edx
f010136a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010136c:	85 d2                	test   %edx,%edx
f010136e:	74 21                	je     f0101391 <strlcpy+0x35>
f0101370:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0101374:	89 f2                	mov    %esi,%edx
f0101376:	eb 09                	jmp    f0101381 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101378:	83 c2 01             	add    $0x1,%edx
f010137b:	83 c1 01             	add    $0x1,%ecx
f010137e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0101381:	39 c2                	cmp    %eax,%edx
f0101383:	74 09                	je     f010138e <strlcpy+0x32>
f0101385:	0f b6 19             	movzbl (%ecx),%ebx
f0101388:	84 db                	test   %bl,%bl
f010138a:	75 ec                	jne    f0101378 <strlcpy+0x1c>
f010138c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f010138e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0101391:	29 f0                	sub    %esi,%eax
}
f0101393:	5b                   	pop    %ebx
f0101394:	5e                   	pop    %esi
f0101395:	5d                   	pop    %ebp
f0101396:	c3                   	ret    

f0101397 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101397:	55                   	push   %ebp
f0101398:	89 e5                	mov    %esp,%ebp
f010139a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010139d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01013a0:	eb 06                	jmp    f01013a8 <strcmp+0x11>
		p++, q++;
f01013a2:	83 c1 01             	add    $0x1,%ecx
f01013a5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01013a8:	0f b6 01             	movzbl (%ecx),%eax
f01013ab:	84 c0                	test   %al,%al
f01013ad:	74 04                	je     f01013b3 <strcmp+0x1c>
f01013af:	3a 02                	cmp    (%edx),%al
f01013b1:	74 ef                	je     f01013a2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01013b3:	0f b6 c0             	movzbl %al,%eax
f01013b6:	0f b6 12             	movzbl (%edx),%edx
f01013b9:	29 d0                	sub    %edx,%eax
}
f01013bb:	5d                   	pop    %ebp
f01013bc:	c3                   	ret    

f01013bd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01013bd:	55                   	push   %ebp
f01013be:	89 e5                	mov    %esp,%ebp
f01013c0:	53                   	push   %ebx
f01013c1:	8b 45 08             	mov    0x8(%ebp),%eax
f01013c4:	8b 55 0c             	mov    0xc(%ebp),%edx
f01013c7:	89 c3                	mov    %eax,%ebx
f01013c9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01013cc:	eb 06                	jmp    f01013d4 <strncmp+0x17>
		n--, p++, q++;
f01013ce:	83 c0 01             	add    $0x1,%eax
f01013d1:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01013d4:	39 d8                	cmp    %ebx,%eax
f01013d6:	74 15                	je     f01013ed <strncmp+0x30>
f01013d8:	0f b6 08             	movzbl (%eax),%ecx
f01013db:	84 c9                	test   %cl,%cl
f01013dd:	74 04                	je     f01013e3 <strncmp+0x26>
f01013df:	3a 0a                	cmp    (%edx),%cl
f01013e1:	74 eb                	je     f01013ce <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01013e3:	0f b6 00             	movzbl (%eax),%eax
f01013e6:	0f b6 12             	movzbl (%edx),%edx
f01013e9:	29 d0                	sub    %edx,%eax
f01013eb:	eb 05                	jmp    f01013f2 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01013ed:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01013f2:	5b                   	pop    %ebx
f01013f3:	5d                   	pop    %ebp
f01013f4:	c3                   	ret    

f01013f5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01013f5:	55                   	push   %ebp
f01013f6:	89 e5                	mov    %esp,%ebp
f01013f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01013fb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01013ff:	eb 07                	jmp    f0101408 <strchr+0x13>
		if (*s == c)
f0101401:	38 ca                	cmp    %cl,%dl
f0101403:	74 0f                	je     f0101414 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0101405:	83 c0 01             	add    $0x1,%eax
f0101408:	0f b6 10             	movzbl (%eax),%edx
f010140b:	84 d2                	test   %dl,%dl
f010140d:	75 f2                	jne    f0101401 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f010140f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101414:	5d                   	pop    %ebp
f0101415:	c3                   	ret    

f0101416 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101416:	55                   	push   %ebp
f0101417:	89 e5                	mov    %esp,%ebp
f0101419:	8b 45 08             	mov    0x8(%ebp),%eax
f010141c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101420:	eb 03                	jmp    f0101425 <strfind+0xf>
f0101422:	83 c0 01             	add    $0x1,%eax
f0101425:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0101428:	38 ca                	cmp    %cl,%dl
f010142a:	74 04                	je     f0101430 <strfind+0x1a>
f010142c:	84 d2                	test   %dl,%dl
f010142e:	75 f2                	jne    f0101422 <strfind+0xc>
			break;
	return (char *) s;
}
f0101430:	5d                   	pop    %ebp
f0101431:	c3                   	ret    

f0101432 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101432:	55                   	push   %ebp
f0101433:	89 e5                	mov    %esp,%ebp
f0101435:	57                   	push   %edi
f0101436:	56                   	push   %esi
f0101437:	53                   	push   %ebx
f0101438:	8b 7d 08             	mov    0x8(%ebp),%edi
f010143b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010143e:	85 c9                	test   %ecx,%ecx
f0101440:	74 36                	je     f0101478 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101442:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101448:	75 28                	jne    f0101472 <memset+0x40>
f010144a:	f6 c1 03             	test   $0x3,%cl
f010144d:	75 23                	jne    f0101472 <memset+0x40>
		c &= 0xFF;
f010144f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101453:	89 d3                	mov    %edx,%ebx
f0101455:	c1 e3 08             	shl    $0x8,%ebx
f0101458:	89 d6                	mov    %edx,%esi
f010145a:	c1 e6 18             	shl    $0x18,%esi
f010145d:	89 d0                	mov    %edx,%eax
f010145f:	c1 e0 10             	shl    $0x10,%eax
f0101462:	09 f0                	or     %esi,%eax
f0101464:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0101466:	89 d8                	mov    %ebx,%eax
f0101468:	09 d0                	or     %edx,%eax
f010146a:	c1 e9 02             	shr    $0x2,%ecx
f010146d:	fc                   	cld    
f010146e:	f3 ab                	rep stos %eax,%es:(%edi)
f0101470:	eb 06                	jmp    f0101478 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101472:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101475:	fc                   	cld    
f0101476:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101478:	89 f8                	mov    %edi,%eax
f010147a:	5b                   	pop    %ebx
f010147b:	5e                   	pop    %esi
f010147c:	5f                   	pop    %edi
f010147d:	5d                   	pop    %ebp
f010147e:	c3                   	ret    

f010147f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010147f:	55                   	push   %ebp
f0101480:	89 e5                	mov    %esp,%ebp
f0101482:	57                   	push   %edi
f0101483:	56                   	push   %esi
f0101484:	8b 45 08             	mov    0x8(%ebp),%eax
f0101487:	8b 75 0c             	mov    0xc(%ebp),%esi
f010148a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010148d:	39 c6                	cmp    %eax,%esi
f010148f:	73 35                	jae    f01014c6 <memmove+0x47>
f0101491:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101494:	39 d0                	cmp    %edx,%eax
f0101496:	73 2e                	jae    f01014c6 <memmove+0x47>
		s += n;
		d += n;
f0101498:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010149b:	89 d6                	mov    %edx,%esi
f010149d:	09 fe                	or     %edi,%esi
f010149f:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01014a5:	75 13                	jne    f01014ba <memmove+0x3b>
f01014a7:	f6 c1 03             	test   $0x3,%cl
f01014aa:	75 0e                	jne    f01014ba <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01014ac:	83 ef 04             	sub    $0x4,%edi
f01014af:	8d 72 fc             	lea    -0x4(%edx),%esi
f01014b2:	c1 e9 02             	shr    $0x2,%ecx
f01014b5:	fd                   	std    
f01014b6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01014b8:	eb 09                	jmp    f01014c3 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01014ba:	83 ef 01             	sub    $0x1,%edi
f01014bd:	8d 72 ff             	lea    -0x1(%edx),%esi
f01014c0:	fd                   	std    
f01014c1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01014c3:	fc                   	cld    
f01014c4:	eb 1d                	jmp    f01014e3 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01014c6:	89 f2                	mov    %esi,%edx
f01014c8:	09 c2                	or     %eax,%edx
f01014ca:	f6 c2 03             	test   $0x3,%dl
f01014cd:	75 0f                	jne    f01014de <memmove+0x5f>
f01014cf:	f6 c1 03             	test   $0x3,%cl
f01014d2:	75 0a                	jne    f01014de <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f01014d4:	c1 e9 02             	shr    $0x2,%ecx
f01014d7:	89 c7                	mov    %eax,%edi
f01014d9:	fc                   	cld    
f01014da:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01014dc:	eb 05                	jmp    f01014e3 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01014de:	89 c7                	mov    %eax,%edi
f01014e0:	fc                   	cld    
f01014e1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01014e3:	5e                   	pop    %esi
f01014e4:	5f                   	pop    %edi
f01014e5:	5d                   	pop    %ebp
f01014e6:	c3                   	ret    

f01014e7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01014e7:	55                   	push   %ebp
f01014e8:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01014ea:	ff 75 10             	pushl  0x10(%ebp)
f01014ed:	ff 75 0c             	pushl  0xc(%ebp)
f01014f0:	ff 75 08             	pushl  0x8(%ebp)
f01014f3:	e8 87 ff ff ff       	call   f010147f <memmove>
}
f01014f8:	c9                   	leave  
f01014f9:	c3                   	ret    

f01014fa <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01014fa:	55                   	push   %ebp
f01014fb:	89 e5                	mov    %esp,%ebp
f01014fd:	56                   	push   %esi
f01014fe:	53                   	push   %ebx
f01014ff:	8b 45 08             	mov    0x8(%ebp),%eax
f0101502:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101505:	89 c6                	mov    %eax,%esi
f0101507:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010150a:	eb 1a                	jmp    f0101526 <memcmp+0x2c>
		if (*s1 != *s2)
f010150c:	0f b6 08             	movzbl (%eax),%ecx
f010150f:	0f b6 1a             	movzbl (%edx),%ebx
f0101512:	38 d9                	cmp    %bl,%cl
f0101514:	74 0a                	je     f0101520 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0101516:	0f b6 c1             	movzbl %cl,%eax
f0101519:	0f b6 db             	movzbl %bl,%ebx
f010151c:	29 d8                	sub    %ebx,%eax
f010151e:	eb 0f                	jmp    f010152f <memcmp+0x35>
		s1++, s2++;
f0101520:	83 c0 01             	add    $0x1,%eax
f0101523:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101526:	39 f0                	cmp    %esi,%eax
f0101528:	75 e2                	jne    f010150c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010152a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010152f:	5b                   	pop    %ebx
f0101530:	5e                   	pop    %esi
f0101531:	5d                   	pop    %ebp
f0101532:	c3                   	ret    

f0101533 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101533:	55                   	push   %ebp
f0101534:	89 e5                	mov    %esp,%ebp
f0101536:	53                   	push   %ebx
f0101537:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010153a:	89 c1                	mov    %eax,%ecx
f010153c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f010153f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101543:	eb 0a                	jmp    f010154f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101545:	0f b6 10             	movzbl (%eax),%edx
f0101548:	39 da                	cmp    %ebx,%edx
f010154a:	74 07                	je     f0101553 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010154c:	83 c0 01             	add    $0x1,%eax
f010154f:	39 c8                	cmp    %ecx,%eax
f0101551:	72 f2                	jb     f0101545 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101553:	5b                   	pop    %ebx
f0101554:	5d                   	pop    %ebp
f0101555:	c3                   	ret    

f0101556 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101556:	55                   	push   %ebp
f0101557:	89 e5                	mov    %esp,%ebp
f0101559:	57                   	push   %edi
f010155a:	56                   	push   %esi
f010155b:	53                   	push   %ebx
f010155c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010155f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101562:	eb 03                	jmp    f0101567 <strtol+0x11>
		s++;
f0101564:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101567:	0f b6 01             	movzbl (%ecx),%eax
f010156a:	3c 20                	cmp    $0x20,%al
f010156c:	74 f6                	je     f0101564 <strtol+0xe>
f010156e:	3c 09                	cmp    $0x9,%al
f0101570:	74 f2                	je     f0101564 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0101572:	3c 2b                	cmp    $0x2b,%al
f0101574:	75 0a                	jne    f0101580 <strtol+0x2a>
		s++;
f0101576:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101579:	bf 00 00 00 00       	mov    $0x0,%edi
f010157e:	eb 11                	jmp    f0101591 <strtol+0x3b>
f0101580:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0101585:	3c 2d                	cmp    $0x2d,%al
f0101587:	75 08                	jne    f0101591 <strtol+0x3b>
		s++, neg = 1;
f0101589:	83 c1 01             	add    $0x1,%ecx
f010158c:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101591:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0101597:	75 15                	jne    f01015ae <strtol+0x58>
f0101599:	80 39 30             	cmpb   $0x30,(%ecx)
f010159c:	75 10                	jne    f01015ae <strtol+0x58>
f010159e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01015a2:	75 7c                	jne    f0101620 <strtol+0xca>
		s += 2, base = 16;
f01015a4:	83 c1 02             	add    $0x2,%ecx
f01015a7:	bb 10 00 00 00       	mov    $0x10,%ebx
f01015ac:	eb 16                	jmp    f01015c4 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f01015ae:	85 db                	test   %ebx,%ebx
f01015b0:	75 12                	jne    f01015c4 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01015b2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01015b7:	80 39 30             	cmpb   $0x30,(%ecx)
f01015ba:	75 08                	jne    f01015c4 <strtol+0x6e>
		s++, base = 8;
f01015bc:	83 c1 01             	add    $0x1,%ecx
f01015bf:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f01015c4:	b8 00 00 00 00       	mov    $0x0,%eax
f01015c9:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01015cc:	0f b6 11             	movzbl (%ecx),%edx
f01015cf:	8d 72 d0             	lea    -0x30(%edx),%esi
f01015d2:	89 f3                	mov    %esi,%ebx
f01015d4:	80 fb 09             	cmp    $0x9,%bl
f01015d7:	77 08                	ja     f01015e1 <strtol+0x8b>
			dig = *s - '0';
f01015d9:	0f be d2             	movsbl %dl,%edx
f01015dc:	83 ea 30             	sub    $0x30,%edx
f01015df:	eb 22                	jmp    f0101603 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f01015e1:	8d 72 9f             	lea    -0x61(%edx),%esi
f01015e4:	89 f3                	mov    %esi,%ebx
f01015e6:	80 fb 19             	cmp    $0x19,%bl
f01015e9:	77 08                	ja     f01015f3 <strtol+0x9d>
			dig = *s - 'a' + 10;
f01015eb:	0f be d2             	movsbl %dl,%edx
f01015ee:	83 ea 57             	sub    $0x57,%edx
f01015f1:	eb 10                	jmp    f0101603 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f01015f3:	8d 72 bf             	lea    -0x41(%edx),%esi
f01015f6:	89 f3                	mov    %esi,%ebx
f01015f8:	80 fb 19             	cmp    $0x19,%bl
f01015fb:	77 16                	ja     f0101613 <strtol+0xbd>
			dig = *s - 'A' + 10;
f01015fd:	0f be d2             	movsbl %dl,%edx
f0101600:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0101603:	3b 55 10             	cmp    0x10(%ebp),%edx
f0101606:	7d 0b                	jge    f0101613 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f0101608:	83 c1 01             	add    $0x1,%ecx
f010160b:	0f af 45 10          	imul   0x10(%ebp),%eax
f010160f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0101611:	eb b9                	jmp    f01015cc <strtol+0x76>

	if (endptr)
f0101613:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101617:	74 0d                	je     f0101626 <strtol+0xd0>
		*endptr = (char *) s;
f0101619:	8b 75 0c             	mov    0xc(%ebp),%esi
f010161c:	89 0e                	mov    %ecx,(%esi)
f010161e:	eb 06                	jmp    f0101626 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101620:	85 db                	test   %ebx,%ebx
f0101622:	74 98                	je     f01015bc <strtol+0x66>
f0101624:	eb 9e                	jmp    f01015c4 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0101626:	89 c2                	mov    %eax,%edx
f0101628:	f7 da                	neg    %edx
f010162a:	85 ff                	test   %edi,%edi
f010162c:	0f 45 c2             	cmovne %edx,%eax
}
f010162f:	5b                   	pop    %ebx
f0101630:	5e                   	pop    %esi
f0101631:	5f                   	pop    %edi
f0101632:	5d                   	pop    %ebp
f0101633:	c3                   	ret    
f0101634:	66 90                	xchg   %ax,%ax
f0101636:	66 90                	xchg   %ax,%ax
f0101638:	66 90                	xchg   %ax,%ax
f010163a:	66 90                	xchg   %ax,%ax
f010163c:	66 90                	xchg   %ax,%ax
f010163e:	66 90                	xchg   %ax,%ax

f0101640 <__udivdi3>:
f0101640:	55                   	push   %ebp
f0101641:	57                   	push   %edi
f0101642:	56                   	push   %esi
f0101643:	53                   	push   %ebx
f0101644:	83 ec 1c             	sub    $0x1c,%esp
f0101647:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010164b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010164f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0101653:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101657:	85 f6                	test   %esi,%esi
f0101659:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010165d:	89 ca                	mov    %ecx,%edx
f010165f:	89 f8                	mov    %edi,%eax
f0101661:	75 3d                	jne    f01016a0 <__udivdi3+0x60>
f0101663:	39 cf                	cmp    %ecx,%edi
f0101665:	0f 87 c5 00 00 00    	ja     f0101730 <__udivdi3+0xf0>
f010166b:	85 ff                	test   %edi,%edi
f010166d:	89 fd                	mov    %edi,%ebp
f010166f:	75 0b                	jne    f010167c <__udivdi3+0x3c>
f0101671:	b8 01 00 00 00       	mov    $0x1,%eax
f0101676:	31 d2                	xor    %edx,%edx
f0101678:	f7 f7                	div    %edi
f010167a:	89 c5                	mov    %eax,%ebp
f010167c:	89 c8                	mov    %ecx,%eax
f010167e:	31 d2                	xor    %edx,%edx
f0101680:	f7 f5                	div    %ebp
f0101682:	89 c1                	mov    %eax,%ecx
f0101684:	89 d8                	mov    %ebx,%eax
f0101686:	89 cf                	mov    %ecx,%edi
f0101688:	f7 f5                	div    %ebp
f010168a:	89 c3                	mov    %eax,%ebx
f010168c:	89 d8                	mov    %ebx,%eax
f010168e:	89 fa                	mov    %edi,%edx
f0101690:	83 c4 1c             	add    $0x1c,%esp
f0101693:	5b                   	pop    %ebx
f0101694:	5e                   	pop    %esi
f0101695:	5f                   	pop    %edi
f0101696:	5d                   	pop    %ebp
f0101697:	c3                   	ret    
f0101698:	90                   	nop
f0101699:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01016a0:	39 ce                	cmp    %ecx,%esi
f01016a2:	77 74                	ja     f0101718 <__udivdi3+0xd8>
f01016a4:	0f bd fe             	bsr    %esi,%edi
f01016a7:	83 f7 1f             	xor    $0x1f,%edi
f01016aa:	0f 84 98 00 00 00    	je     f0101748 <__udivdi3+0x108>
f01016b0:	bb 20 00 00 00       	mov    $0x20,%ebx
f01016b5:	89 f9                	mov    %edi,%ecx
f01016b7:	89 c5                	mov    %eax,%ebp
f01016b9:	29 fb                	sub    %edi,%ebx
f01016bb:	d3 e6                	shl    %cl,%esi
f01016bd:	89 d9                	mov    %ebx,%ecx
f01016bf:	d3 ed                	shr    %cl,%ebp
f01016c1:	89 f9                	mov    %edi,%ecx
f01016c3:	d3 e0                	shl    %cl,%eax
f01016c5:	09 ee                	or     %ebp,%esi
f01016c7:	89 d9                	mov    %ebx,%ecx
f01016c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01016cd:	89 d5                	mov    %edx,%ebp
f01016cf:	8b 44 24 08          	mov    0x8(%esp),%eax
f01016d3:	d3 ed                	shr    %cl,%ebp
f01016d5:	89 f9                	mov    %edi,%ecx
f01016d7:	d3 e2                	shl    %cl,%edx
f01016d9:	89 d9                	mov    %ebx,%ecx
f01016db:	d3 e8                	shr    %cl,%eax
f01016dd:	09 c2                	or     %eax,%edx
f01016df:	89 d0                	mov    %edx,%eax
f01016e1:	89 ea                	mov    %ebp,%edx
f01016e3:	f7 f6                	div    %esi
f01016e5:	89 d5                	mov    %edx,%ebp
f01016e7:	89 c3                	mov    %eax,%ebx
f01016e9:	f7 64 24 0c          	mull   0xc(%esp)
f01016ed:	39 d5                	cmp    %edx,%ebp
f01016ef:	72 10                	jb     f0101701 <__udivdi3+0xc1>
f01016f1:	8b 74 24 08          	mov    0x8(%esp),%esi
f01016f5:	89 f9                	mov    %edi,%ecx
f01016f7:	d3 e6                	shl    %cl,%esi
f01016f9:	39 c6                	cmp    %eax,%esi
f01016fb:	73 07                	jae    f0101704 <__udivdi3+0xc4>
f01016fd:	39 d5                	cmp    %edx,%ebp
f01016ff:	75 03                	jne    f0101704 <__udivdi3+0xc4>
f0101701:	83 eb 01             	sub    $0x1,%ebx
f0101704:	31 ff                	xor    %edi,%edi
f0101706:	89 d8                	mov    %ebx,%eax
f0101708:	89 fa                	mov    %edi,%edx
f010170a:	83 c4 1c             	add    $0x1c,%esp
f010170d:	5b                   	pop    %ebx
f010170e:	5e                   	pop    %esi
f010170f:	5f                   	pop    %edi
f0101710:	5d                   	pop    %ebp
f0101711:	c3                   	ret    
f0101712:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101718:	31 ff                	xor    %edi,%edi
f010171a:	31 db                	xor    %ebx,%ebx
f010171c:	89 d8                	mov    %ebx,%eax
f010171e:	89 fa                	mov    %edi,%edx
f0101720:	83 c4 1c             	add    $0x1c,%esp
f0101723:	5b                   	pop    %ebx
f0101724:	5e                   	pop    %esi
f0101725:	5f                   	pop    %edi
f0101726:	5d                   	pop    %ebp
f0101727:	c3                   	ret    
f0101728:	90                   	nop
f0101729:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101730:	89 d8                	mov    %ebx,%eax
f0101732:	f7 f7                	div    %edi
f0101734:	31 ff                	xor    %edi,%edi
f0101736:	89 c3                	mov    %eax,%ebx
f0101738:	89 d8                	mov    %ebx,%eax
f010173a:	89 fa                	mov    %edi,%edx
f010173c:	83 c4 1c             	add    $0x1c,%esp
f010173f:	5b                   	pop    %ebx
f0101740:	5e                   	pop    %esi
f0101741:	5f                   	pop    %edi
f0101742:	5d                   	pop    %ebp
f0101743:	c3                   	ret    
f0101744:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101748:	39 ce                	cmp    %ecx,%esi
f010174a:	72 0c                	jb     f0101758 <__udivdi3+0x118>
f010174c:	31 db                	xor    %ebx,%ebx
f010174e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0101752:	0f 87 34 ff ff ff    	ja     f010168c <__udivdi3+0x4c>
f0101758:	bb 01 00 00 00       	mov    $0x1,%ebx
f010175d:	e9 2a ff ff ff       	jmp    f010168c <__udivdi3+0x4c>
f0101762:	66 90                	xchg   %ax,%ax
f0101764:	66 90                	xchg   %ax,%ax
f0101766:	66 90                	xchg   %ax,%ax
f0101768:	66 90                	xchg   %ax,%ax
f010176a:	66 90                	xchg   %ax,%ax
f010176c:	66 90                	xchg   %ax,%ax
f010176e:	66 90                	xchg   %ax,%ax

f0101770 <__umoddi3>:
f0101770:	55                   	push   %ebp
f0101771:	57                   	push   %edi
f0101772:	56                   	push   %esi
f0101773:	53                   	push   %ebx
f0101774:	83 ec 1c             	sub    $0x1c,%esp
f0101777:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010177b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010177f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101783:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101787:	85 d2                	test   %edx,%edx
f0101789:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010178d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101791:	89 f3                	mov    %esi,%ebx
f0101793:	89 3c 24             	mov    %edi,(%esp)
f0101796:	89 74 24 04          	mov    %esi,0x4(%esp)
f010179a:	75 1c                	jne    f01017b8 <__umoddi3+0x48>
f010179c:	39 f7                	cmp    %esi,%edi
f010179e:	76 50                	jbe    f01017f0 <__umoddi3+0x80>
f01017a0:	89 c8                	mov    %ecx,%eax
f01017a2:	89 f2                	mov    %esi,%edx
f01017a4:	f7 f7                	div    %edi
f01017a6:	89 d0                	mov    %edx,%eax
f01017a8:	31 d2                	xor    %edx,%edx
f01017aa:	83 c4 1c             	add    $0x1c,%esp
f01017ad:	5b                   	pop    %ebx
f01017ae:	5e                   	pop    %esi
f01017af:	5f                   	pop    %edi
f01017b0:	5d                   	pop    %ebp
f01017b1:	c3                   	ret    
f01017b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01017b8:	39 f2                	cmp    %esi,%edx
f01017ba:	89 d0                	mov    %edx,%eax
f01017bc:	77 52                	ja     f0101810 <__umoddi3+0xa0>
f01017be:	0f bd ea             	bsr    %edx,%ebp
f01017c1:	83 f5 1f             	xor    $0x1f,%ebp
f01017c4:	75 5a                	jne    f0101820 <__umoddi3+0xb0>
f01017c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
f01017ca:	0f 82 e0 00 00 00    	jb     f01018b0 <__umoddi3+0x140>
f01017d0:	39 0c 24             	cmp    %ecx,(%esp)
f01017d3:	0f 86 d7 00 00 00    	jbe    f01018b0 <__umoddi3+0x140>
f01017d9:	8b 44 24 08          	mov    0x8(%esp),%eax
f01017dd:	8b 54 24 04          	mov    0x4(%esp),%edx
f01017e1:	83 c4 1c             	add    $0x1c,%esp
f01017e4:	5b                   	pop    %ebx
f01017e5:	5e                   	pop    %esi
f01017e6:	5f                   	pop    %edi
f01017e7:	5d                   	pop    %ebp
f01017e8:	c3                   	ret    
f01017e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01017f0:	85 ff                	test   %edi,%edi
f01017f2:	89 fd                	mov    %edi,%ebp
f01017f4:	75 0b                	jne    f0101801 <__umoddi3+0x91>
f01017f6:	b8 01 00 00 00       	mov    $0x1,%eax
f01017fb:	31 d2                	xor    %edx,%edx
f01017fd:	f7 f7                	div    %edi
f01017ff:	89 c5                	mov    %eax,%ebp
f0101801:	89 f0                	mov    %esi,%eax
f0101803:	31 d2                	xor    %edx,%edx
f0101805:	f7 f5                	div    %ebp
f0101807:	89 c8                	mov    %ecx,%eax
f0101809:	f7 f5                	div    %ebp
f010180b:	89 d0                	mov    %edx,%eax
f010180d:	eb 99                	jmp    f01017a8 <__umoddi3+0x38>
f010180f:	90                   	nop
f0101810:	89 c8                	mov    %ecx,%eax
f0101812:	89 f2                	mov    %esi,%edx
f0101814:	83 c4 1c             	add    $0x1c,%esp
f0101817:	5b                   	pop    %ebx
f0101818:	5e                   	pop    %esi
f0101819:	5f                   	pop    %edi
f010181a:	5d                   	pop    %ebp
f010181b:	c3                   	ret    
f010181c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101820:	8b 34 24             	mov    (%esp),%esi
f0101823:	bf 20 00 00 00       	mov    $0x20,%edi
f0101828:	89 e9                	mov    %ebp,%ecx
f010182a:	29 ef                	sub    %ebp,%edi
f010182c:	d3 e0                	shl    %cl,%eax
f010182e:	89 f9                	mov    %edi,%ecx
f0101830:	89 f2                	mov    %esi,%edx
f0101832:	d3 ea                	shr    %cl,%edx
f0101834:	89 e9                	mov    %ebp,%ecx
f0101836:	09 c2                	or     %eax,%edx
f0101838:	89 d8                	mov    %ebx,%eax
f010183a:	89 14 24             	mov    %edx,(%esp)
f010183d:	89 f2                	mov    %esi,%edx
f010183f:	d3 e2                	shl    %cl,%edx
f0101841:	89 f9                	mov    %edi,%ecx
f0101843:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101847:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010184b:	d3 e8                	shr    %cl,%eax
f010184d:	89 e9                	mov    %ebp,%ecx
f010184f:	89 c6                	mov    %eax,%esi
f0101851:	d3 e3                	shl    %cl,%ebx
f0101853:	89 f9                	mov    %edi,%ecx
f0101855:	89 d0                	mov    %edx,%eax
f0101857:	d3 e8                	shr    %cl,%eax
f0101859:	89 e9                	mov    %ebp,%ecx
f010185b:	09 d8                	or     %ebx,%eax
f010185d:	89 d3                	mov    %edx,%ebx
f010185f:	89 f2                	mov    %esi,%edx
f0101861:	f7 34 24             	divl   (%esp)
f0101864:	89 d6                	mov    %edx,%esi
f0101866:	d3 e3                	shl    %cl,%ebx
f0101868:	f7 64 24 04          	mull   0x4(%esp)
f010186c:	39 d6                	cmp    %edx,%esi
f010186e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0101872:	89 d1                	mov    %edx,%ecx
f0101874:	89 c3                	mov    %eax,%ebx
f0101876:	72 08                	jb     f0101880 <__umoddi3+0x110>
f0101878:	75 11                	jne    f010188b <__umoddi3+0x11b>
f010187a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010187e:	73 0b                	jae    f010188b <__umoddi3+0x11b>
f0101880:	2b 44 24 04          	sub    0x4(%esp),%eax
f0101884:	1b 14 24             	sbb    (%esp),%edx
f0101887:	89 d1                	mov    %edx,%ecx
f0101889:	89 c3                	mov    %eax,%ebx
f010188b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010188f:	29 da                	sub    %ebx,%edx
f0101891:	19 ce                	sbb    %ecx,%esi
f0101893:	89 f9                	mov    %edi,%ecx
f0101895:	89 f0                	mov    %esi,%eax
f0101897:	d3 e0                	shl    %cl,%eax
f0101899:	89 e9                	mov    %ebp,%ecx
f010189b:	d3 ea                	shr    %cl,%edx
f010189d:	89 e9                	mov    %ebp,%ecx
f010189f:	d3 ee                	shr    %cl,%esi
f01018a1:	09 d0                	or     %edx,%eax
f01018a3:	89 f2                	mov    %esi,%edx
f01018a5:	83 c4 1c             	add    $0x1c,%esp
f01018a8:	5b                   	pop    %ebx
f01018a9:	5e                   	pop    %esi
f01018aa:	5f                   	pop    %edi
f01018ab:	5d                   	pop    %ebp
f01018ac:	c3                   	ret    
f01018ad:	8d 76 00             	lea    0x0(%esi),%esi
f01018b0:	29 f9                	sub    %edi,%ecx
f01018b2:	19 d6                	sbb    %edx,%esi
f01018b4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01018b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01018bc:	e9 18 ff ff ff       	jmp    f01017d9 <__umoddi3+0x69>
