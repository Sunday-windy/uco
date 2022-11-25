
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 90 11 00       	mov    $0x119000,%eax
    movl %eax, %cr3
c0100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
c0100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
c010000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
c0100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
c0100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
c0100016:	8d 05 1e 00 10 c0    	lea    0xc010001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
c010001c:	ff e0                	jmp    *%eax

c010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
c010001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
c0100020:	a3 00 90 11 c0       	mov    %eax,0xc0119000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 80 11 c0       	mov    $0xc0118000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c010002f:	e8 02 00 00 00       	call   c0100036 <kern_init>

c0100034 <spin>:

# should never get here
spin:
    jmp spin
c0100034:	eb fe                	jmp    c0100034 <spin>

c0100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
c0100036:	55                   	push   %ebp
c0100037:	89 e5                	mov    %esp,%ebp
c0100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c010003c:	b8 2c bf 11 c0       	mov    $0xc011bf2c,%eax
c0100041:	2d 00 b0 11 c0       	sub    $0xc011b000,%eax
c0100046:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100051:	00 
c0100052:	c7 04 24 00 b0 11 c0 	movl   $0xc011b000,(%esp)
c0100059:	e8 9f 5d 00 00       	call   c0105dfd <memset>

    cons_init();                // init the console
c010005e:	e8 ea 15 00 00       	call   c010164d <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100063:	c7 45 f4 a0 5f 10 c0 	movl   $0xc0105fa0,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010006d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100071:	c7 04 24 bc 5f 10 c0 	movl   $0xc0105fbc,(%esp)
c0100078:	e8 d9 02 00 00       	call   c0100356 <cprintf>

    print_kerninfo();
c010007d:	e8 f7 07 00 00       	call   c0100879 <print_kerninfo>

    grade_backtrace();
c0100082:	e8 90 00 00 00       	call   c0100117 <grade_backtrace>

    pmm_init();                 // init physical memory management
c0100087:	e8 e8 42 00 00       	call   c0104374 <pmm_init>

    pic_init();                 // init interrupt controller
c010008c:	e8 3d 17 00 00       	call   c01017ce <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100091:	e8 c4 18 00 00       	call   c010195a <idt_init>

    clock_init();               // init clock interrupt
c0100096:	e8 11 0d 00 00       	call   c0100dac <clock_init>
    intr_enable();              // enable irq interrupt
c010009b:	e8 8c 16 00 00       	call   c010172c <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
c01000a0:	eb fe                	jmp    c01000a0 <kern_init+0x6a>

c01000a2 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000a2:	55                   	push   %ebp
c01000a3:	89 e5                	mov    %esp,%ebp
c01000a5:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000af:	00 
c01000b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000b7:	00 
c01000b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000bf:	e8 03 0c 00 00       	call   c0100cc7 <mon_backtrace>
}
c01000c4:	90                   	nop
c01000c5:	89 ec                	mov    %ebp,%esp
c01000c7:	5d                   	pop    %ebp
c01000c8:	c3                   	ret    

c01000c9 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000c9:	55                   	push   %ebp
c01000ca:	89 e5                	mov    %esp,%ebp
c01000cc:	83 ec 18             	sub    $0x18,%esp
c01000cf:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000d2:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c01000d5:	8b 55 0c             	mov    0xc(%ebp),%edx
c01000d8:	8d 5d 08             	lea    0x8(%ebp),%ebx
c01000db:	8b 45 08             	mov    0x8(%ebp),%eax
c01000de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01000e2:	89 54 24 08          	mov    %edx,0x8(%esp)
c01000e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01000ea:	89 04 24             	mov    %eax,(%esp)
c01000ed:	e8 b0 ff ff ff       	call   c01000a2 <grade_backtrace2>
}
c01000f2:	90                   	nop
c01000f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01000f6:	89 ec                	mov    %ebp,%esp
c01000f8:	5d                   	pop    %ebp
c01000f9:	c3                   	ret    

c01000fa <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c01000fa:	55                   	push   %ebp
c01000fb:	89 e5                	mov    %esp,%ebp
c01000fd:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c0100100:	8b 45 10             	mov    0x10(%ebp),%eax
c0100103:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100107:	8b 45 08             	mov    0x8(%ebp),%eax
c010010a:	89 04 24             	mov    %eax,(%esp)
c010010d:	e8 b7 ff ff ff       	call   c01000c9 <grade_backtrace1>
}
c0100112:	90                   	nop
c0100113:	89 ec                	mov    %ebp,%esp
c0100115:	5d                   	pop    %ebp
c0100116:	c3                   	ret    

c0100117 <grade_backtrace>:

void
grade_backtrace(void) {
c0100117:	55                   	push   %ebp
c0100118:	89 e5                	mov    %esp,%ebp
c010011a:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c010011d:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c0100122:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c0100129:	ff 
c010012a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010012e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100135:	e8 c0 ff ff ff       	call   c01000fa <grade_backtrace0>
}
c010013a:	90                   	nop
c010013b:	89 ec                	mov    %ebp,%esp
c010013d:	5d                   	pop    %ebp
c010013e:	c3                   	ret    

c010013f <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c010013f:	55                   	push   %ebp
c0100140:	89 e5                	mov    %esp,%ebp
c0100142:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100145:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c0100148:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c010014b:	8c 45 f2             	mov    %es,-0xe(%ebp)
c010014e:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100151:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100155:	83 e0 03             	and    $0x3,%eax
c0100158:	89 c2                	mov    %eax,%edx
c010015a:	a1 00 b0 11 c0       	mov    0xc011b000,%eax
c010015f:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100163:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100167:	c7 04 24 c1 5f 10 c0 	movl   $0xc0105fc1,(%esp)
c010016e:	e8 e3 01 00 00       	call   c0100356 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c0100173:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100177:	89 c2                	mov    %eax,%edx
c0100179:	a1 00 b0 11 c0       	mov    0xc011b000,%eax
c010017e:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100182:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100186:	c7 04 24 cf 5f 10 c0 	movl   $0xc0105fcf,(%esp)
c010018d:	e8 c4 01 00 00       	call   c0100356 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c0100192:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100196:	89 c2                	mov    %eax,%edx
c0100198:	a1 00 b0 11 c0       	mov    0xc011b000,%eax
c010019d:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001a1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001a5:	c7 04 24 dd 5f 10 c0 	movl   $0xc0105fdd,(%esp)
c01001ac:	e8 a5 01 00 00       	call   c0100356 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001b1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001b5:	89 c2                	mov    %eax,%edx
c01001b7:	a1 00 b0 11 c0       	mov    0xc011b000,%eax
c01001bc:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001c0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001c4:	c7 04 24 eb 5f 10 c0 	movl   $0xc0105feb,(%esp)
c01001cb:	e8 86 01 00 00       	call   c0100356 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001d0:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001d4:	89 c2                	mov    %eax,%edx
c01001d6:	a1 00 b0 11 c0       	mov    0xc011b000,%eax
c01001db:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001df:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001e3:	c7 04 24 f9 5f 10 c0 	movl   $0xc0105ff9,(%esp)
c01001ea:	e8 67 01 00 00       	call   c0100356 <cprintf>
    round ++;
c01001ef:	a1 00 b0 11 c0       	mov    0xc011b000,%eax
c01001f4:	40                   	inc    %eax
c01001f5:	a3 00 b0 11 c0       	mov    %eax,0xc011b000
}
c01001fa:	90                   	nop
c01001fb:	89 ec                	mov    %ebp,%esp
c01001fd:	5d                   	pop    %ebp
c01001fe:	c3                   	ret    

c01001ff <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c01001ff:	55                   	push   %ebp
c0100200:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c0100202:	90                   	nop
c0100203:	5d                   	pop    %ebp
c0100204:	c3                   	ret    

c0100205 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c0100205:	55                   	push   %ebp
c0100206:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c0100208:	90                   	nop
c0100209:	5d                   	pop    %ebp
c010020a:	c3                   	ret    

c010020b <lab1_switch_test>:

static void
lab1_switch_test(void) {
c010020b:	55                   	push   %ebp
c010020c:	89 e5                	mov    %esp,%ebp
c010020e:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c0100211:	e8 29 ff ff ff       	call   c010013f <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c0100216:	c7 04 24 08 60 10 c0 	movl   $0xc0106008,(%esp)
c010021d:	e8 34 01 00 00       	call   c0100356 <cprintf>
    lab1_switch_to_user();
c0100222:	e8 d8 ff ff ff       	call   c01001ff <lab1_switch_to_user>
    lab1_print_cur_status();
c0100227:	e8 13 ff ff ff       	call   c010013f <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c010022c:	c7 04 24 28 60 10 c0 	movl   $0xc0106028,(%esp)
c0100233:	e8 1e 01 00 00       	call   c0100356 <cprintf>
    lab1_switch_to_kernel();
c0100238:	e8 c8 ff ff ff       	call   c0100205 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c010023d:	e8 fd fe ff ff       	call   c010013f <lab1_print_cur_status>
}
c0100242:	90                   	nop
c0100243:	89 ec                	mov    %ebp,%esp
c0100245:	5d                   	pop    %ebp
c0100246:	c3                   	ret    

c0100247 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c0100247:	55                   	push   %ebp
c0100248:	89 e5                	mov    %esp,%ebp
c010024a:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c010024d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100251:	74 13                	je     c0100266 <readline+0x1f>
        cprintf("%s", prompt);
c0100253:	8b 45 08             	mov    0x8(%ebp),%eax
c0100256:	89 44 24 04          	mov    %eax,0x4(%esp)
c010025a:	c7 04 24 47 60 10 c0 	movl   $0xc0106047,(%esp)
c0100261:	e8 f0 00 00 00       	call   c0100356 <cprintf>
    }
    int i = 0, c;
c0100266:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c010026d:	e8 73 01 00 00       	call   c01003e5 <getchar>
c0100272:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c0100275:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100279:	79 07                	jns    c0100282 <readline+0x3b>
            return NULL;
c010027b:	b8 00 00 00 00       	mov    $0x0,%eax
c0100280:	eb 78                	jmp    c01002fa <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c0100282:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c0100286:	7e 28                	jle    c01002b0 <readline+0x69>
c0100288:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c010028f:	7f 1f                	jg     c01002b0 <readline+0x69>
            cputchar(c);
c0100291:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100294:	89 04 24             	mov    %eax,(%esp)
c0100297:	e8 e2 00 00 00       	call   c010037e <cputchar>
            buf[i ++] = c;
c010029c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010029f:	8d 50 01             	lea    0x1(%eax),%edx
c01002a2:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01002a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01002a8:	88 90 20 b0 11 c0    	mov    %dl,-0x3fee4fe0(%eax)
c01002ae:	eb 45                	jmp    c01002f5 <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
c01002b0:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01002b4:	75 16                	jne    c01002cc <readline+0x85>
c01002b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01002ba:	7e 10                	jle    c01002cc <readline+0x85>
            cputchar(c);
c01002bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002bf:	89 04 24             	mov    %eax,(%esp)
c01002c2:	e8 b7 00 00 00       	call   c010037e <cputchar>
            i --;
c01002c7:	ff 4d f4             	decl   -0xc(%ebp)
c01002ca:	eb 29                	jmp    c01002f5 <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
c01002cc:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01002d0:	74 06                	je     c01002d8 <readline+0x91>
c01002d2:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01002d6:	75 95                	jne    c010026d <readline+0x26>
            cputchar(c);
c01002d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002db:	89 04 24             	mov    %eax,(%esp)
c01002de:	e8 9b 00 00 00       	call   c010037e <cputchar>
            buf[i] = '\0';
c01002e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002e6:	05 20 b0 11 c0       	add    $0xc011b020,%eax
c01002eb:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01002ee:	b8 20 b0 11 c0       	mov    $0xc011b020,%eax
c01002f3:	eb 05                	jmp    c01002fa <readline+0xb3>
        c = getchar();
c01002f5:	e9 73 ff ff ff       	jmp    c010026d <readline+0x26>
        }
    }
}
c01002fa:	89 ec                	mov    %ebp,%esp
c01002fc:	5d                   	pop    %ebp
c01002fd:	c3                   	ret    

c01002fe <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c01002fe:	55                   	push   %ebp
c01002ff:	89 e5                	mov    %esp,%ebp
c0100301:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100304:	8b 45 08             	mov    0x8(%ebp),%eax
c0100307:	89 04 24             	mov    %eax,(%esp)
c010030a:	e8 6d 13 00 00       	call   c010167c <cons_putc>
    (*cnt) ++;
c010030f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100312:	8b 00                	mov    (%eax),%eax
c0100314:	8d 50 01             	lea    0x1(%eax),%edx
c0100317:	8b 45 0c             	mov    0xc(%ebp),%eax
c010031a:	89 10                	mov    %edx,(%eax)
}
c010031c:	90                   	nop
c010031d:	89 ec                	mov    %ebp,%esp
c010031f:	5d                   	pop    %ebp
c0100320:	c3                   	ret    

c0100321 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100321:	55                   	push   %ebp
c0100322:	89 e5                	mov    %esp,%ebp
c0100324:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100327:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c010032e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100331:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100335:	8b 45 08             	mov    0x8(%ebp),%eax
c0100338:	89 44 24 08          	mov    %eax,0x8(%esp)
c010033c:	8d 45 f4             	lea    -0xc(%ebp),%eax
c010033f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100343:	c7 04 24 fe 02 10 c0 	movl   $0xc01002fe,(%esp)
c010034a:	e8 d9 52 00 00       	call   c0105628 <vprintfmt>
    return cnt;
c010034f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100352:	89 ec                	mov    %ebp,%esp
c0100354:	5d                   	pop    %ebp
c0100355:	c3                   	ret    

c0100356 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c0100356:	55                   	push   %ebp
c0100357:	89 e5                	mov    %esp,%ebp
c0100359:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010035c:	8d 45 0c             	lea    0xc(%ebp),%eax
c010035f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c0100362:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100365:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100369:	8b 45 08             	mov    0x8(%ebp),%eax
c010036c:	89 04 24             	mov    %eax,(%esp)
c010036f:	e8 ad ff ff ff       	call   c0100321 <vcprintf>
c0100374:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0100377:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010037a:	89 ec                	mov    %ebp,%esp
c010037c:	5d                   	pop    %ebp
c010037d:	c3                   	ret    

c010037e <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c010037e:	55                   	push   %ebp
c010037f:	89 e5                	mov    %esp,%ebp
c0100381:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100384:	8b 45 08             	mov    0x8(%ebp),%eax
c0100387:	89 04 24             	mov    %eax,(%esp)
c010038a:	e8 ed 12 00 00       	call   c010167c <cons_putc>
}
c010038f:	90                   	nop
c0100390:	89 ec                	mov    %ebp,%esp
c0100392:	5d                   	pop    %ebp
c0100393:	c3                   	ret    

c0100394 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c0100394:	55                   	push   %ebp
c0100395:	89 e5                	mov    %esp,%ebp
c0100397:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c010039a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01003a1:	eb 13                	jmp    c01003b6 <cputs+0x22>
        cputch(c, &cnt);
c01003a3:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01003a7:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01003aa:	89 54 24 04          	mov    %edx,0x4(%esp)
c01003ae:	89 04 24             	mov    %eax,(%esp)
c01003b1:	e8 48 ff ff ff       	call   c01002fe <cputch>
    while ((c = *str ++) != '\0') {
c01003b6:	8b 45 08             	mov    0x8(%ebp),%eax
c01003b9:	8d 50 01             	lea    0x1(%eax),%edx
c01003bc:	89 55 08             	mov    %edx,0x8(%ebp)
c01003bf:	0f b6 00             	movzbl (%eax),%eax
c01003c2:	88 45 f7             	mov    %al,-0x9(%ebp)
c01003c5:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c01003c9:	75 d8                	jne    c01003a3 <cputs+0xf>
    }
    cputch('\n', &cnt);
c01003cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
c01003ce:	89 44 24 04          	mov    %eax,0x4(%esp)
c01003d2:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c01003d9:	e8 20 ff ff ff       	call   c01002fe <cputch>
    return cnt;
c01003de:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01003e1:	89 ec                	mov    %ebp,%esp
c01003e3:	5d                   	pop    %ebp
c01003e4:	c3                   	ret    

c01003e5 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c01003e5:	55                   	push   %ebp
c01003e6:	89 e5                	mov    %esp,%ebp
c01003e8:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c01003eb:	90                   	nop
c01003ec:	e8 ca 12 00 00       	call   c01016bb <cons_getc>
c01003f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01003f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003f8:	74 f2                	je     c01003ec <getchar+0x7>
        /* do nothing */;
    return c;
c01003fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01003fd:	89 ec                	mov    %ebp,%esp
c01003ff:	5d                   	pop    %ebp
c0100400:	c3                   	ret    

c0100401 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c0100401:	55                   	push   %ebp
c0100402:	89 e5                	mov    %esp,%ebp
c0100404:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c0100407:	8b 45 0c             	mov    0xc(%ebp),%eax
c010040a:	8b 00                	mov    (%eax),%eax
c010040c:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010040f:	8b 45 10             	mov    0x10(%ebp),%eax
c0100412:	8b 00                	mov    (%eax),%eax
c0100414:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0100417:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c010041e:	e9 ca 00 00 00       	jmp    c01004ed <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
c0100423:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100426:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100429:	01 d0                	add    %edx,%eax
c010042b:	89 c2                	mov    %eax,%edx
c010042d:	c1 ea 1f             	shr    $0x1f,%edx
c0100430:	01 d0                	add    %edx,%eax
c0100432:	d1 f8                	sar    %eax
c0100434:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0100437:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010043a:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c010043d:	eb 03                	jmp    c0100442 <stab_binsearch+0x41>
            m --;
c010043f:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
c0100442:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100445:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100448:	7c 1f                	jl     c0100469 <stab_binsearch+0x68>
c010044a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010044d:	89 d0                	mov    %edx,%eax
c010044f:	01 c0                	add    %eax,%eax
c0100451:	01 d0                	add    %edx,%eax
c0100453:	c1 e0 02             	shl    $0x2,%eax
c0100456:	89 c2                	mov    %eax,%edx
c0100458:	8b 45 08             	mov    0x8(%ebp),%eax
c010045b:	01 d0                	add    %edx,%eax
c010045d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100461:	0f b6 c0             	movzbl %al,%eax
c0100464:	39 45 14             	cmp    %eax,0x14(%ebp)
c0100467:	75 d6                	jne    c010043f <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
c0100469:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010046c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010046f:	7d 09                	jge    c010047a <stab_binsearch+0x79>
            l = true_m + 1;
c0100471:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100474:	40                   	inc    %eax
c0100475:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c0100478:	eb 73                	jmp    c01004ed <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
c010047a:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0100481:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100484:	89 d0                	mov    %edx,%eax
c0100486:	01 c0                	add    %eax,%eax
c0100488:	01 d0                	add    %edx,%eax
c010048a:	c1 e0 02             	shl    $0x2,%eax
c010048d:	89 c2                	mov    %eax,%edx
c010048f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100492:	01 d0                	add    %edx,%eax
c0100494:	8b 40 08             	mov    0x8(%eax),%eax
c0100497:	39 45 18             	cmp    %eax,0x18(%ebp)
c010049a:	76 11                	jbe    c01004ad <stab_binsearch+0xac>
            *region_left = m;
c010049c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010049f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004a2:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c01004a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01004a7:	40                   	inc    %eax
c01004a8:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004ab:	eb 40                	jmp    c01004ed <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
c01004ad:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004b0:	89 d0                	mov    %edx,%eax
c01004b2:	01 c0                	add    %eax,%eax
c01004b4:	01 d0                	add    %edx,%eax
c01004b6:	c1 e0 02             	shl    $0x2,%eax
c01004b9:	89 c2                	mov    %eax,%edx
c01004bb:	8b 45 08             	mov    0x8(%ebp),%eax
c01004be:	01 d0                	add    %edx,%eax
c01004c0:	8b 40 08             	mov    0x8(%eax),%eax
c01004c3:	39 45 18             	cmp    %eax,0x18(%ebp)
c01004c6:	73 14                	jae    c01004dc <stab_binsearch+0xdb>
            *region_right = m - 1;
c01004c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004cb:	8d 50 ff             	lea    -0x1(%eax),%edx
c01004ce:	8b 45 10             	mov    0x10(%ebp),%eax
c01004d1:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01004d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004d6:	48                   	dec    %eax
c01004d7:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004da:	eb 11                	jmp    c01004ed <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01004dc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004df:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004e2:	89 10                	mov    %edx,(%eax)
            l = m;
c01004e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004e7:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01004ea:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r) {
c01004ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01004f0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01004f3:	0f 8e 2a ff ff ff    	jle    c0100423 <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
c01004f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01004fd:	75 0f                	jne    c010050e <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
c01004ff:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100502:	8b 00                	mov    (%eax),%eax
c0100504:	8d 50 ff             	lea    -0x1(%eax),%edx
c0100507:	8b 45 10             	mov    0x10(%ebp),%eax
c010050a:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c010050c:	eb 3e                	jmp    c010054c <stab_binsearch+0x14b>
        l = *region_right;
c010050e:	8b 45 10             	mov    0x10(%ebp),%eax
c0100511:	8b 00                	mov    (%eax),%eax
c0100513:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c0100516:	eb 03                	jmp    c010051b <stab_binsearch+0x11a>
c0100518:	ff 4d fc             	decl   -0x4(%ebp)
c010051b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010051e:	8b 00                	mov    (%eax),%eax
c0100520:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c0100523:	7e 1f                	jle    c0100544 <stab_binsearch+0x143>
c0100525:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100528:	89 d0                	mov    %edx,%eax
c010052a:	01 c0                	add    %eax,%eax
c010052c:	01 d0                	add    %edx,%eax
c010052e:	c1 e0 02             	shl    $0x2,%eax
c0100531:	89 c2                	mov    %eax,%edx
c0100533:	8b 45 08             	mov    0x8(%ebp),%eax
c0100536:	01 d0                	add    %edx,%eax
c0100538:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010053c:	0f b6 c0             	movzbl %al,%eax
c010053f:	39 45 14             	cmp    %eax,0x14(%ebp)
c0100542:	75 d4                	jne    c0100518 <stab_binsearch+0x117>
        *region_left = l;
c0100544:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100547:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010054a:	89 10                	mov    %edx,(%eax)
}
c010054c:	90                   	nop
c010054d:	89 ec                	mov    %ebp,%esp
c010054f:	5d                   	pop    %ebp
c0100550:	c3                   	ret    

c0100551 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c0100551:	55                   	push   %ebp
c0100552:	89 e5                	mov    %esp,%ebp
c0100554:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0100557:	8b 45 0c             	mov    0xc(%ebp),%eax
c010055a:	c7 00 4c 60 10 c0    	movl   $0xc010604c,(%eax)
    info->eip_line = 0;
c0100560:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100563:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c010056a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010056d:	c7 40 08 4c 60 10 c0 	movl   $0xc010604c,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100574:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100577:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c010057e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100581:	8b 55 08             	mov    0x8(%ebp),%edx
c0100584:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0100587:	8b 45 0c             	mov    0xc(%ebp),%eax
c010058a:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c0100591:	c7 45 f4 c8 72 10 c0 	movl   $0xc01072c8,-0xc(%ebp)
    stab_end = __STAB_END__;
c0100598:	c7 45 f0 8c 29 11 c0 	movl   $0xc011298c,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c010059f:	c7 45 ec 8d 29 11 c0 	movl   $0xc011298d,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c01005a6:	c7 45 e8 25 5f 11 c0 	movl   $0xc0115f25,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c01005ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005b0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01005b3:	76 0b                	jbe    c01005c0 <debuginfo_eip+0x6f>
c01005b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005b8:	48                   	dec    %eax
c01005b9:	0f b6 00             	movzbl (%eax),%eax
c01005bc:	84 c0                	test   %al,%al
c01005be:	74 0a                	je     c01005ca <debuginfo_eip+0x79>
        return -1;
c01005c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01005c5:	e9 ab 02 00 00       	jmp    c0100875 <debuginfo_eip+0x324>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c01005ca:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c01005d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005d4:	2b 45 f4             	sub    -0xc(%ebp),%eax
c01005d7:	c1 f8 02             	sar    $0x2,%eax
c01005da:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01005e0:	48                   	dec    %eax
c01005e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01005e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01005e7:	89 44 24 10          	mov    %eax,0x10(%esp)
c01005eb:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01005f2:	00 
c01005f3:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01005f6:	89 44 24 08          	mov    %eax,0x8(%esp)
c01005fa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c01005fd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100601:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100604:	89 04 24             	mov    %eax,(%esp)
c0100607:	e8 f5 fd ff ff       	call   c0100401 <stab_binsearch>
    if (lfile == 0)
c010060c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010060f:	85 c0                	test   %eax,%eax
c0100611:	75 0a                	jne    c010061d <debuginfo_eip+0xcc>
        return -1;
c0100613:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100618:	e9 58 02 00 00       	jmp    c0100875 <debuginfo_eip+0x324>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c010061d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100620:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0100623:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100626:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c0100629:	8b 45 08             	mov    0x8(%ebp),%eax
c010062c:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100630:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c0100637:	00 
c0100638:	8d 45 d8             	lea    -0x28(%ebp),%eax
c010063b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010063f:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100642:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100646:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100649:	89 04 24             	mov    %eax,(%esp)
c010064c:	e8 b0 fd ff ff       	call   c0100401 <stab_binsearch>

    if (lfun <= rfun) {
c0100651:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100654:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100657:	39 c2                	cmp    %eax,%edx
c0100659:	7f 78                	jg     c01006d3 <debuginfo_eip+0x182>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c010065b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010065e:	89 c2                	mov    %eax,%edx
c0100660:	89 d0                	mov    %edx,%eax
c0100662:	01 c0                	add    %eax,%eax
c0100664:	01 d0                	add    %edx,%eax
c0100666:	c1 e0 02             	shl    $0x2,%eax
c0100669:	89 c2                	mov    %eax,%edx
c010066b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010066e:	01 d0                	add    %edx,%eax
c0100670:	8b 10                	mov    (%eax),%edx
c0100672:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100675:	2b 45 ec             	sub    -0x14(%ebp),%eax
c0100678:	39 c2                	cmp    %eax,%edx
c010067a:	73 22                	jae    c010069e <debuginfo_eip+0x14d>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c010067c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010067f:	89 c2                	mov    %eax,%edx
c0100681:	89 d0                	mov    %edx,%eax
c0100683:	01 c0                	add    %eax,%eax
c0100685:	01 d0                	add    %edx,%eax
c0100687:	c1 e0 02             	shl    $0x2,%eax
c010068a:	89 c2                	mov    %eax,%edx
c010068c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010068f:	01 d0                	add    %edx,%eax
c0100691:	8b 10                	mov    (%eax),%edx
c0100693:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100696:	01 c2                	add    %eax,%edx
c0100698:	8b 45 0c             	mov    0xc(%ebp),%eax
c010069b:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c010069e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006a1:	89 c2                	mov    %eax,%edx
c01006a3:	89 d0                	mov    %edx,%eax
c01006a5:	01 c0                	add    %eax,%eax
c01006a7:	01 d0                	add    %edx,%eax
c01006a9:	c1 e0 02             	shl    $0x2,%eax
c01006ac:	89 c2                	mov    %eax,%edx
c01006ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006b1:	01 d0                	add    %edx,%eax
c01006b3:	8b 50 08             	mov    0x8(%eax),%edx
c01006b6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006b9:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c01006bc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006bf:	8b 40 10             	mov    0x10(%eax),%eax
c01006c2:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c01006c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006c8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c01006cb:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01006ce:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01006d1:	eb 15                	jmp    c01006e8 <debuginfo_eip+0x197>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01006d3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006d6:	8b 55 08             	mov    0x8(%ebp),%edx
c01006d9:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01006dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006df:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c01006e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006e5:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01006e8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006eb:	8b 40 08             	mov    0x8(%eax),%eax
c01006ee:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01006f5:	00 
c01006f6:	89 04 24             	mov    %eax,(%esp)
c01006f9:	e8 77 55 00 00       	call   c0105c75 <strfind>
c01006fe:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100701:	8b 4a 08             	mov    0x8(%edx),%ecx
c0100704:	29 c8                	sub    %ecx,%eax
c0100706:	89 c2                	mov    %eax,%edx
c0100708:	8b 45 0c             	mov    0xc(%ebp),%eax
c010070b:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c010070e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100711:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100715:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c010071c:	00 
c010071d:	8d 45 d0             	lea    -0x30(%ebp),%eax
c0100720:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100724:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c0100727:	89 44 24 04          	mov    %eax,0x4(%esp)
c010072b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010072e:	89 04 24             	mov    %eax,(%esp)
c0100731:	e8 cb fc ff ff       	call   c0100401 <stab_binsearch>
    if (lline <= rline) {
c0100736:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100739:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010073c:	39 c2                	cmp    %eax,%edx
c010073e:	7f 23                	jg     c0100763 <debuginfo_eip+0x212>
        info->eip_line = stabs[rline].n_desc;
c0100740:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100743:	89 c2                	mov    %eax,%edx
c0100745:	89 d0                	mov    %edx,%eax
c0100747:	01 c0                	add    %eax,%eax
c0100749:	01 d0                	add    %edx,%eax
c010074b:	c1 e0 02             	shl    $0x2,%eax
c010074e:	89 c2                	mov    %eax,%edx
c0100750:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100753:	01 d0                	add    %edx,%eax
c0100755:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100759:	89 c2                	mov    %eax,%edx
c010075b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010075e:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100761:	eb 11                	jmp    c0100774 <debuginfo_eip+0x223>
        return -1;
c0100763:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100768:	e9 08 01 00 00       	jmp    c0100875 <debuginfo_eip+0x324>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c010076d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100770:	48                   	dec    %eax
c0100771:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
c0100774:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100777:	8b 45 e4             	mov    -0x1c(%ebp),%eax
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c010077a:	39 c2                	cmp    %eax,%edx
c010077c:	7c 56                	jl     c01007d4 <debuginfo_eip+0x283>
           && stabs[lline].n_type != N_SOL
c010077e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100781:	89 c2                	mov    %eax,%edx
c0100783:	89 d0                	mov    %edx,%eax
c0100785:	01 c0                	add    %eax,%eax
c0100787:	01 d0                	add    %edx,%eax
c0100789:	c1 e0 02             	shl    $0x2,%eax
c010078c:	89 c2                	mov    %eax,%edx
c010078e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100791:	01 d0                	add    %edx,%eax
c0100793:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100797:	3c 84                	cmp    $0x84,%al
c0100799:	74 39                	je     c01007d4 <debuginfo_eip+0x283>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c010079b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010079e:	89 c2                	mov    %eax,%edx
c01007a0:	89 d0                	mov    %edx,%eax
c01007a2:	01 c0                	add    %eax,%eax
c01007a4:	01 d0                	add    %edx,%eax
c01007a6:	c1 e0 02             	shl    $0x2,%eax
c01007a9:	89 c2                	mov    %eax,%edx
c01007ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007ae:	01 d0                	add    %edx,%eax
c01007b0:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01007b4:	3c 64                	cmp    $0x64,%al
c01007b6:	75 b5                	jne    c010076d <debuginfo_eip+0x21c>
c01007b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007bb:	89 c2                	mov    %eax,%edx
c01007bd:	89 d0                	mov    %edx,%eax
c01007bf:	01 c0                	add    %eax,%eax
c01007c1:	01 d0                	add    %edx,%eax
c01007c3:	c1 e0 02             	shl    $0x2,%eax
c01007c6:	89 c2                	mov    %eax,%edx
c01007c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007cb:	01 d0                	add    %edx,%eax
c01007cd:	8b 40 08             	mov    0x8(%eax),%eax
c01007d0:	85 c0                	test   %eax,%eax
c01007d2:	74 99                	je     c010076d <debuginfo_eip+0x21c>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01007d4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01007d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01007da:	39 c2                	cmp    %eax,%edx
c01007dc:	7c 42                	jl     c0100820 <debuginfo_eip+0x2cf>
c01007de:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007e1:	89 c2                	mov    %eax,%edx
c01007e3:	89 d0                	mov    %edx,%eax
c01007e5:	01 c0                	add    %eax,%eax
c01007e7:	01 d0                	add    %edx,%eax
c01007e9:	c1 e0 02             	shl    $0x2,%eax
c01007ec:	89 c2                	mov    %eax,%edx
c01007ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007f1:	01 d0                	add    %edx,%eax
c01007f3:	8b 10                	mov    (%eax),%edx
c01007f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01007f8:	2b 45 ec             	sub    -0x14(%ebp),%eax
c01007fb:	39 c2                	cmp    %eax,%edx
c01007fd:	73 21                	jae    c0100820 <debuginfo_eip+0x2cf>
        info->eip_file = stabstr + stabs[lline].n_strx;
c01007ff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100802:	89 c2                	mov    %eax,%edx
c0100804:	89 d0                	mov    %edx,%eax
c0100806:	01 c0                	add    %eax,%eax
c0100808:	01 d0                	add    %edx,%eax
c010080a:	c1 e0 02             	shl    $0x2,%eax
c010080d:	89 c2                	mov    %eax,%edx
c010080f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100812:	01 d0                	add    %edx,%eax
c0100814:	8b 10                	mov    (%eax),%edx
c0100816:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100819:	01 c2                	add    %eax,%edx
c010081b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010081e:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c0100820:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100823:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100826:	39 c2                	cmp    %eax,%edx
c0100828:	7d 46                	jge    c0100870 <debuginfo_eip+0x31f>
        for (lline = lfun + 1;
c010082a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010082d:	40                   	inc    %eax
c010082e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100831:	eb 16                	jmp    c0100849 <debuginfo_eip+0x2f8>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100833:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100836:	8b 40 14             	mov    0x14(%eax),%eax
c0100839:	8d 50 01             	lea    0x1(%eax),%edx
c010083c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010083f:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
c0100842:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100845:	40                   	inc    %eax
c0100846:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100849:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010084c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010084f:	39 c2                	cmp    %eax,%edx
c0100851:	7d 1d                	jge    c0100870 <debuginfo_eip+0x31f>
c0100853:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100856:	89 c2                	mov    %eax,%edx
c0100858:	89 d0                	mov    %edx,%eax
c010085a:	01 c0                	add    %eax,%eax
c010085c:	01 d0                	add    %edx,%eax
c010085e:	c1 e0 02             	shl    $0x2,%eax
c0100861:	89 c2                	mov    %eax,%edx
c0100863:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100866:	01 d0                	add    %edx,%eax
c0100868:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010086c:	3c a0                	cmp    $0xa0,%al
c010086e:	74 c3                	je     c0100833 <debuginfo_eip+0x2e2>
        }
    }
    return 0;
c0100870:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100875:	89 ec                	mov    %ebp,%esp
c0100877:	5d                   	pop    %ebp
c0100878:	c3                   	ret    

c0100879 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0100879:	55                   	push   %ebp
c010087a:	89 e5                	mov    %esp,%ebp
c010087c:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c010087f:	c7 04 24 56 60 10 c0 	movl   $0xc0106056,(%esp)
c0100886:	e8 cb fa ff ff       	call   c0100356 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010088b:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c0100892:	c0 
c0100893:	c7 04 24 6f 60 10 c0 	movl   $0xc010606f,(%esp)
c010089a:	e8 b7 fa ff ff       	call   c0100356 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c010089f:	c7 44 24 04 89 5f 10 	movl   $0xc0105f89,0x4(%esp)
c01008a6:	c0 
c01008a7:	c7 04 24 87 60 10 c0 	movl   $0xc0106087,(%esp)
c01008ae:	e8 a3 fa ff ff       	call   c0100356 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c01008b3:	c7 44 24 04 00 b0 11 	movl   $0xc011b000,0x4(%esp)
c01008ba:	c0 
c01008bb:	c7 04 24 9f 60 10 c0 	movl   $0xc010609f,(%esp)
c01008c2:	e8 8f fa ff ff       	call   c0100356 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01008c7:	c7 44 24 04 2c bf 11 	movl   $0xc011bf2c,0x4(%esp)
c01008ce:	c0 
c01008cf:	c7 04 24 b7 60 10 c0 	movl   $0xc01060b7,(%esp)
c01008d6:	e8 7b fa ff ff       	call   c0100356 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01008db:	b8 2c bf 11 c0       	mov    $0xc011bf2c,%eax
c01008e0:	2d 36 00 10 c0       	sub    $0xc0100036,%eax
c01008e5:	05 ff 03 00 00       	add    $0x3ff,%eax
c01008ea:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01008f0:	85 c0                	test   %eax,%eax
c01008f2:	0f 48 c2             	cmovs  %edx,%eax
c01008f5:	c1 f8 0a             	sar    $0xa,%eax
c01008f8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01008fc:	c7 04 24 d0 60 10 c0 	movl   $0xc01060d0,(%esp)
c0100903:	e8 4e fa ff ff       	call   c0100356 <cprintf>
}
c0100908:	90                   	nop
c0100909:	89 ec                	mov    %ebp,%esp
c010090b:	5d                   	pop    %ebp
c010090c:	c3                   	ret    

c010090d <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c010090d:	55                   	push   %ebp
c010090e:	89 e5                	mov    %esp,%ebp
c0100910:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c0100916:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100919:	89 44 24 04          	mov    %eax,0x4(%esp)
c010091d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100920:	89 04 24             	mov    %eax,(%esp)
c0100923:	e8 29 fc ff ff       	call   c0100551 <debuginfo_eip>
c0100928:	85 c0                	test   %eax,%eax
c010092a:	74 15                	je     c0100941 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c010092c:	8b 45 08             	mov    0x8(%ebp),%eax
c010092f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100933:	c7 04 24 fa 60 10 c0 	movl   $0xc01060fa,(%esp)
c010093a:	e8 17 fa ff ff       	call   c0100356 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c010093f:	eb 6c                	jmp    c01009ad <print_debuginfo+0xa0>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100941:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100948:	eb 1b                	jmp    c0100965 <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
c010094a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010094d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100950:	01 d0                	add    %edx,%eax
c0100952:	0f b6 10             	movzbl (%eax),%edx
c0100955:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c010095b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010095e:	01 c8                	add    %ecx,%eax
c0100960:	88 10                	mov    %dl,(%eax)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100962:	ff 45 f4             	incl   -0xc(%ebp)
c0100965:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100968:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010096b:	7c dd                	jl     c010094a <print_debuginfo+0x3d>
        fnname[j] = '\0';
c010096d:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100973:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100976:	01 d0                	add    %edx,%eax
c0100978:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
c010097b:	8b 55 ec             	mov    -0x14(%ebp),%edx
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c010097e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100981:	29 d0                	sub    %edx,%eax
c0100983:	89 c1                	mov    %eax,%ecx
c0100985:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100988:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010098b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c010098f:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100995:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100999:	89 54 24 08          	mov    %edx,0x8(%esp)
c010099d:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009a1:	c7 04 24 16 61 10 c0 	movl   $0xc0106116,(%esp)
c01009a8:	e8 a9 f9 ff ff       	call   c0100356 <cprintf>
}
c01009ad:	90                   	nop
c01009ae:	89 ec                	mov    %ebp,%esp
c01009b0:	5d                   	pop    %ebp
c01009b1:	c3                   	ret    

c01009b2 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c01009b2:	55                   	push   %ebp
c01009b3:	89 e5                	mov    %esp,%ebp
c01009b5:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c01009b8:	8b 45 04             	mov    0x4(%ebp),%eax
c01009bb:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c01009be:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01009c1:	89 ec                	mov    %ebp,%esp
c01009c3:	5d                   	pop    %ebp
c01009c4:	c3                   	ret    

c01009c5 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c01009c5:	55                   	push   %ebp
c01009c6:	89 e5                	mov    %esp,%ebp
c01009c8:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c01009cb:	89 e8                	mov    %ebp,%eax
c01009cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c01009d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
      uint32_t ebp = read_ebp(), eip = read_eip();
c01009d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01009d6:	e8 d7 ff ff ff       	call   c01009b2 <read_eip>
c01009db:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c01009de:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01009e5:	e9 84 00 00 00       	jmp    c0100a6e <print_stackframe+0xa9>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c01009ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01009ed:	89 44 24 08          	mov    %eax,0x8(%esp)
c01009f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009f4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009f8:	c7 04 24 28 61 10 c0 	movl   $0xc0106128,(%esp)
c01009ff:	e8 52 f9 ff ff       	call   c0100356 <cprintf>
        uint32_t *args = (uint32_t *)ebp + 2;
c0100a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a07:	83 c0 08             	add    $0x8,%eax
c0100a0a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (j = 0; j < 4; j ++) {
c0100a0d:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0100a14:	eb 24                	jmp    c0100a3a <print_stackframe+0x75>
            cprintf("0x%08x ", args[j]);
c0100a16:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a19:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100a20:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100a23:	01 d0                	add    %edx,%eax
c0100a25:	8b 00                	mov    (%eax),%eax
c0100a27:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a2b:	c7 04 24 44 61 10 c0 	movl   $0xc0106144,(%esp)
c0100a32:	e8 1f f9 ff ff       	call   c0100356 <cprintf>
        for (j = 0; j < 4; j ++) {
c0100a37:	ff 45 e8             	incl   -0x18(%ebp)
c0100a3a:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100a3e:	7e d6                	jle    c0100a16 <print_stackframe+0x51>
        }
        cprintf("\n");
c0100a40:	c7 04 24 4c 61 10 c0 	movl   $0xc010614c,(%esp)
c0100a47:	e8 0a f9 ff ff       	call   c0100356 <cprintf>
        print_debuginfo(eip - 1);
c0100a4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a4f:	48                   	dec    %eax
c0100a50:	89 04 24             	mov    %eax,(%esp)
c0100a53:	e8 b5 fe ff ff       	call   c010090d <print_debuginfo>
        eip = ((uint32_t *)ebp)[1];
c0100a58:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a5b:	83 c0 04             	add    $0x4,%eax
c0100a5e:	8b 00                	mov    (%eax),%eax
c0100a60:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0];
c0100a63:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a66:	8b 00                	mov    (%eax),%eax
c0100a68:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c0100a6b:	ff 45 ec             	incl   -0x14(%ebp)
c0100a6e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100a72:	74 0a                	je     c0100a7e <print_stackframe+0xb9>
c0100a74:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100a78:	0f 8e 6c ff ff ff    	jle    c01009ea <print_stackframe+0x25>
    }
}
c0100a7e:	90                   	nop
c0100a7f:	89 ec                	mov    %ebp,%esp
c0100a81:	5d                   	pop    %ebp
c0100a82:	c3                   	ret    

c0100a83 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100a83:	55                   	push   %ebp
c0100a84:	89 e5                	mov    %esp,%ebp
c0100a86:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100a89:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100a90:	eb 0c                	jmp    c0100a9e <parse+0x1b>
            *buf ++ = '\0';
c0100a92:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a95:	8d 50 01             	lea    0x1(%eax),%edx
c0100a98:	89 55 08             	mov    %edx,0x8(%ebp)
c0100a9b:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100a9e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100aa1:	0f b6 00             	movzbl (%eax),%eax
c0100aa4:	84 c0                	test   %al,%al
c0100aa6:	74 1d                	je     c0100ac5 <parse+0x42>
c0100aa8:	8b 45 08             	mov    0x8(%ebp),%eax
c0100aab:	0f b6 00             	movzbl (%eax),%eax
c0100aae:	0f be c0             	movsbl %al,%eax
c0100ab1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ab5:	c7 04 24 d0 61 10 c0 	movl   $0xc01061d0,(%esp)
c0100abc:	e8 80 51 00 00       	call   c0105c41 <strchr>
c0100ac1:	85 c0                	test   %eax,%eax
c0100ac3:	75 cd                	jne    c0100a92 <parse+0xf>
        }
        if (*buf == '\0') {
c0100ac5:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ac8:	0f b6 00             	movzbl (%eax),%eax
c0100acb:	84 c0                	test   %al,%al
c0100acd:	74 65                	je     c0100b34 <parse+0xb1>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100acf:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100ad3:	75 14                	jne    c0100ae9 <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100ad5:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100adc:	00 
c0100add:	c7 04 24 d5 61 10 c0 	movl   $0xc01061d5,(%esp)
c0100ae4:	e8 6d f8 ff ff       	call   c0100356 <cprintf>
        }
        argv[argc ++] = buf;
c0100ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100aec:	8d 50 01             	lea    0x1(%eax),%edx
c0100aef:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100af2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100af9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100afc:	01 c2                	add    %eax,%edx
c0100afe:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b01:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b03:	eb 03                	jmp    c0100b08 <parse+0x85>
            buf ++;
c0100b05:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b08:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b0b:	0f b6 00             	movzbl (%eax),%eax
c0100b0e:	84 c0                	test   %al,%al
c0100b10:	74 8c                	je     c0100a9e <parse+0x1b>
c0100b12:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b15:	0f b6 00             	movzbl (%eax),%eax
c0100b18:	0f be c0             	movsbl %al,%eax
c0100b1b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b1f:	c7 04 24 d0 61 10 c0 	movl   $0xc01061d0,(%esp)
c0100b26:	e8 16 51 00 00       	call   c0105c41 <strchr>
c0100b2b:	85 c0                	test   %eax,%eax
c0100b2d:	74 d6                	je     c0100b05 <parse+0x82>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b2f:	e9 6a ff ff ff       	jmp    c0100a9e <parse+0x1b>
            break;
c0100b34:	90                   	nop
        }
    }
    return argc;
c0100b35:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100b38:	89 ec                	mov    %ebp,%esp
c0100b3a:	5d                   	pop    %ebp
c0100b3b:	c3                   	ret    

c0100b3c <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100b3c:	55                   	push   %ebp
c0100b3d:	89 e5                	mov    %esp,%ebp
c0100b3f:	83 ec 68             	sub    $0x68,%esp
c0100b42:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100b45:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100b48:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b4c:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b4f:	89 04 24             	mov    %eax,(%esp)
c0100b52:	e8 2c ff ff ff       	call   c0100a83 <parse>
c0100b57:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100b5a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100b5e:	75 0a                	jne    c0100b6a <runcmd+0x2e>
        return 0;
c0100b60:	b8 00 00 00 00       	mov    $0x0,%eax
c0100b65:	e9 83 00 00 00       	jmp    c0100bed <runcmd+0xb1>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100b6a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100b71:	eb 5a                	jmp    c0100bcd <runcmd+0x91>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100b73:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0100b76:	8b 4d f4             	mov    -0xc(%ebp),%ecx
c0100b79:	89 c8                	mov    %ecx,%eax
c0100b7b:	01 c0                	add    %eax,%eax
c0100b7d:	01 c8                	add    %ecx,%eax
c0100b7f:	c1 e0 02             	shl    $0x2,%eax
c0100b82:	05 00 80 11 c0       	add    $0xc0118000,%eax
c0100b87:	8b 00                	mov    (%eax),%eax
c0100b89:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100b8d:	89 04 24             	mov    %eax,(%esp)
c0100b90:	e8 10 50 00 00       	call   c0105ba5 <strcmp>
c0100b95:	85 c0                	test   %eax,%eax
c0100b97:	75 31                	jne    c0100bca <runcmd+0x8e>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100b99:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100b9c:	89 d0                	mov    %edx,%eax
c0100b9e:	01 c0                	add    %eax,%eax
c0100ba0:	01 d0                	add    %edx,%eax
c0100ba2:	c1 e0 02             	shl    $0x2,%eax
c0100ba5:	05 08 80 11 c0       	add    $0xc0118008,%eax
c0100baa:	8b 10                	mov    (%eax),%edx
c0100bac:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100baf:	83 c0 04             	add    $0x4,%eax
c0100bb2:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100bb5:	8d 59 ff             	lea    -0x1(%ecx),%ebx
c0100bb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c0100bbb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100bbf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bc3:	89 1c 24             	mov    %ebx,(%esp)
c0100bc6:	ff d2                	call   *%edx
c0100bc8:	eb 23                	jmp    c0100bed <runcmd+0xb1>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100bca:	ff 45 f4             	incl   -0xc(%ebp)
c0100bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bd0:	83 f8 02             	cmp    $0x2,%eax
c0100bd3:	76 9e                	jbe    c0100b73 <runcmd+0x37>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100bd5:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100bd8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bdc:	c7 04 24 f3 61 10 c0 	movl   $0xc01061f3,(%esp)
c0100be3:	e8 6e f7 ff ff       	call   c0100356 <cprintf>
    return 0;
c0100be8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100bed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0100bf0:	89 ec                	mov    %ebp,%esp
c0100bf2:	5d                   	pop    %ebp
c0100bf3:	c3                   	ret    

c0100bf4 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100bf4:	55                   	push   %ebp
c0100bf5:	89 e5                	mov    %esp,%ebp
c0100bf7:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100bfa:	c7 04 24 0c 62 10 c0 	movl   $0xc010620c,(%esp)
c0100c01:	e8 50 f7 ff ff       	call   c0100356 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100c06:	c7 04 24 34 62 10 c0 	movl   $0xc0106234,(%esp)
c0100c0d:	e8 44 f7 ff ff       	call   c0100356 <cprintf>

    if (tf != NULL) {
c0100c12:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100c16:	74 0b                	je     c0100c23 <kmonitor+0x2f>
        print_trapframe(tf);
c0100c18:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c1b:	89 04 24             	mov    %eax,(%esp)
c0100c1e:	e8 74 0e 00 00       	call   c0101a97 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100c23:	c7 04 24 59 62 10 c0 	movl   $0xc0106259,(%esp)
c0100c2a:	e8 18 f6 ff ff       	call   c0100247 <readline>
c0100c2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100c32:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100c36:	74 eb                	je     c0100c23 <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
c0100c38:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c3b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c42:	89 04 24             	mov    %eax,(%esp)
c0100c45:	e8 f2 fe ff ff       	call   c0100b3c <runcmd>
c0100c4a:	85 c0                	test   %eax,%eax
c0100c4c:	78 02                	js     c0100c50 <kmonitor+0x5c>
        if ((buf = readline("K> ")) != NULL) {
c0100c4e:	eb d3                	jmp    c0100c23 <kmonitor+0x2f>
                break;
c0100c50:	90                   	nop
            }
        }
    }
}
c0100c51:	90                   	nop
c0100c52:	89 ec                	mov    %ebp,%esp
c0100c54:	5d                   	pop    %ebp
c0100c55:	c3                   	ret    

c0100c56 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100c56:	55                   	push   %ebp
c0100c57:	89 e5                	mov    %esp,%ebp
c0100c59:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c5c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c63:	eb 3d                	jmp    c0100ca2 <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100c65:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c68:	89 d0                	mov    %edx,%eax
c0100c6a:	01 c0                	add    %eax,%eax
c0100c6c:	01 d0                	add    %edx,%eax
c0100c6e:	c1 e0 02             	shl    $0x2,%eax
c0100c71:	05 04 80 11 c0       	add    $0xc0118004,%eax
c0100c76:	8b 10                	mov    (%eax),%edx
c0100c78:	8b 4d f4             	mov    -0xc(%ebp),%ecx
c0100c7b:	89 c8                	mov    %ecx,%eax
c0100c7d:	01 c0                	add    %eax,%eax
c0100c7f:	01 c8                	add    %ecx,%eax
c0100c81:	c1 e0 02             	shl    $0x2,%eax
c0100c84:	05 00 80 11 c0       	add    $0xc0118000,%eax
c0100c89:	8b 00                	mov    (%eax),%eax
c0100c8b:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100c8f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c93:	c7 04 24 5d 62 10 c0 	movl   $0xc010625d,(%esp)
c0100c9a:	e8 b7 f6 ff ff       	call   c0100356 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c9f:	ff 45 f4             	incl   -0xc(%ebp)
c0100ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ca5:	83 f8 02             	cmp    $0x2,%eax
c0100ca8:	76 bb                	jbe    c0100c65 <mon_help+0xf>
    }
    return 0;
c0100caa:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100caf:	89 ec                	mov    %ebp,%esp
c0100cb1:	5d                   	pop    %ebp
c0100cb2:	c3                   	ret    

c0100cb3 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100cb3:	55                   	push   %ebp
c0100cb4:	89 e5                	mov    %esp,%ebp
c0100cb6:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100cb9:	e8 bb fb ff ff       	call   c0100879 <print_kerninfo>
    return 0;
c0100cbe:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cc3:	89 ec                	mov    %ebp,%esp
c0100cc5:	5d                   	pop    %ebp
c0100cc6:	c3                   	ret    

c0100cc7 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100cc7:	55                   	push   %ebp
c0100cc8:	89 e5                	mov    %esp,%ebp
c0100cca:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100ccd:	e8 f3 fc ff ff       	call   c01009c5 <print_stackframe>
    return 0;
c0100cd2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cd7:	89 ec                	mov    %ebp,%esp
c0100cd9:	5d                   	pop    %ebp
c0100cda:	c3                   	ret    

c0100cdb <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100cdb:	55                   	push   %ebp
c0100cdc:	89 e5                	mov    %esp,%ebp
c0100cde:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100ce1:	a1 20 b4 11 c0       	mov    0xc011b420,%eax
c0100ce6:	85 c0                	test   %eax,%eax
c0100ce8:	75 5b                	jne    c0100d45 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
c0100cea:	c7 05 20 b4 11 c0 01 	movl   $0x1,0xc011b420
c0100cf1:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100cf4:	8d 45 14             	lea    0x14(%ebp),%eax
c0100cf7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100cfa:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100cfd:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100d01:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d04:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d08:	c7 04 24 66 62 10 c0 	movl   $0xc0106266,(%esp)
c0100d0f:	e8 42 f6 ff ff       	call   c0100356 <cprintf>
    vcprintf(fmt, ap);
c0100d14:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d17:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d1b:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d1e:	89 04 24             	mov    %eax,(%esp)
c0100d21:	e8 fb f5 ff ff       	call   c0100321 <vcprintf>
    cprintf("\n");
c0100d26:	c7 04 24 82 62 10 c0 	movl   $0xc0106282,(%esp)
c0100d2d:	e8 24 f6 ff ff       	call   c0100356 <cprintf>
    
    cprintf("stack trackback:\n");
c0100d32:	c7 04 24 84 62 10 c0 	movl   $0xc0106284,(%esp)
c0100d39:	e8 18 f6 ff ff       	call   c0100356 <cprintf>
    print_stackframe();
c0100d3e:	e8 82 fc ff ff       	call   c01009c5 <print_stackframe>
c0100d43:	eb 01                	jmp    c0100d46 <__panic+0x6b>
        goto panic_dead;
c0100d45:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100d46:	e8 e9 09 00 00       	call   c0101734 <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100d4b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100d52:	e8 9d fe ff ff       	call   c0100bf4 <kmonitor>
c0100d57:	eb f2                	jmp    c0100d4b <__panic+0x70>

c0100d59 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100d59:	55                   	push   %ebp
c0100d5a:	89 e5                	mov    %esp,%ebp
c0100d5c:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100d5f:	8d 45 14             	lea    0x14(%ebp),%eax
c0100d62:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100d65:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100d68:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100d6c:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d6f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d73:	c7 04 24 96 62 10 c0 	movl   $0xc0106296,(%esp)
c0100d7a:	e8 d7 f5 ff ff       	call   c0100356 <cprintf>
    vcprintf(fmt, ap);
c0100d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d82:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d86:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d89:	89 04 24             	mov    %eax,(%esp)
c0100d8c:	e8 90 f5 ff ff       	call   c0100321 <vcprintf>
    cprintf("\n");
c0100d91:	c7 04 24 82 62 10 c0 	movl   $0xc0106282,(%esp)
c0100d98:	e8 b9 f5 ff ff       	call   c0100356 <cprintf>
    va_end(ap);
}
c0100d9d:	90                   	nop
c0100d9e:	89 ec                	mov    %ebp,%esp
c0100da0:	5d                   	pop    %ebp
c0100da1:	c3                   	ret    

c0100da2 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0100da2:	55                   	push   %ebp
c0100da3:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100da5:	a1 20 b4 11 c0       	mov    0xc011b420,%eax
}
c0100daa:	5d                   	pop    %ebp
c0100dab:	c3                   	ret    

c0100dac <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100dac:	55                   	push   %ebp
c0100dad:	89 e5                	mov    %esp,%ebp
c0100daf:	83 ec 28             	sub    $0x28,%esp
c0100db2:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
c0100db8:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100dbc:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100dc0:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100dc4:	ee                   	out    %al,(%dx)
}
c0100dc5:	90                   	nop
c0100dc6:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100dcc:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100dd0:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100dd4:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100dd8:	ee                   	out    %al,(%dx)
}
c0100dd9:	90                   	nop
c0100dda:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
c0100de0:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100de4:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100de8:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100dec:	ee                   	out    %al,(%dx)
}
c0100ded:	90                   	nop
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100dee:	c7 05 24 b4 11 c0 00 	movl   $0x0,0xc011b424
c0100df5:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100df8:	c7 04 24 b4 62 10 c0 	movl   $0xc01062b4,(%esp)
c0100dff:	e8 52 f5 ff ff       	call   c0100356 <cprintf>
    pic_enable(IRQ_TIMER);
c0100e04:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100e0b:	e8 89 09 00 00       	call   c0101799 <pic_enable>
}
c0100e10:	90                   	nop
c0100e11:	89 ec                	mov    %ebp,%esp
c0100e13:	5d                   	pop    %ebp
c0100e14:	c3                   	ret    

c0100e15 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100e15:	55                   	push   %ebp
c0100e16:	89 e5                	mov    %esp,%ebp
c0100e18:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100e1b:	9c                   	pushf  
c0100e1c:	58                   	pop    %eax
c0100e1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100e20:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100e23:	25 00 02 00 00       	and    $0x200,%eax
c0100e28:	85 c0                	test   %eax,%eax
c0100e2a:	74 0c                	je     c0100e38 <__intr_save+0x23>
        intr_disable();
c0100e2c:	e8 03 09 00 00       	call   c0101734 <intr_disable>
        return 1;
c0100e31:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e36:	eb 05                	jmp    c0100e3d <__intr_save+0x28>
    }
    return 0;
c0100e38:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e3d:	89 ec                	mov    %ebp,%esp
c0100e3f:	5d                   	pop    %ebp
c0100e40:	c3                   	ret    

c0100e41 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100e41:	55                   	push   %ebp
c0100e42:	89 e5                	mov    %esp,%ebp
c0100e44:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100e47:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100e4b:	74 05                	je     c0100e52 <__intr_restore+0x11>
        intr_enable();
c0100e4d:	e8 da 08 00 00       	call   c010172c <intr_enable>
    }
}
c0100e52:	90                   	nop
c0100e53:	89 ec                	mov    %ebp,%esp
c0100e55:	5d                   	pop    %ebp
c0100e56:	c3                   	ret    

c0100e57 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100e57:	55                   	push   %ebp
c0100e58:	89 e5                	mov    %esp,%ebp
c0100e5a:	83 ec 10             	sub    $0x10,%esp
c0100e5d:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e63:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100e67:	89 c2                	mov    %eax,%edx
c0100e69:	ec                   	in     (%dx),%al
c0100e6a:	88 45 f1             	mov    %al,-0xf(%ebp)
c0100e6d:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100e73:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e77:	89 c2                	mov    %eax,%edx
c0100e79:	ec                   	in     (%dx),%al
c0100e7a:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100e7d:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100e83:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100e87:	89 c2                	mov    %eax,%edx
c0100e89:	ec                   	in     (%dx),%al
c0100e8a:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100e8d:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
c0100e93:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100e97:	89 c2                	mov    %eax,%edx
c0100e99:	ec                   	in     (%dx),%al
c0100e9a:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100e9d:	90                   	nop
c0100e9e:	89 ec                	mov    %ebp,%esp
c0100ea0:	5d                   	pop    %ebp
c0100ea1:	c3                   	ret    

c0100ea2 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100ea2:	55                   	push   %ebp
c0100ea3:	89 e5                	mov    %esp,%ebp
c0100ea5:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100ea8:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100eaf:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100eb2:	0f b7 00             	movzwl (%eax),%eax
c0100eb5:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100eb9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ebc:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100ec1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ec4:	0f b7 00             	movzwl (%eax),%eax
c0100ec7:	0f b7 c0             	movzwl %ax,%eax
c0100eca:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
c0100ecf:	74 12                	je     c0100ee3 <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100ed1:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100ed8:	66 c7 05 46 b4 11 c0 	movw   $0x3b4,0xc011b446
c0100edf:	b4 03 
c0100ee1:	eb 13                	jmp    c0100ef6 <cga_init+0x54>
    } else {
        *cp = was;
c0100ee3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ee6:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100eea:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100eed:	66 c7 05 46 b4 11 c0 	movw   $0x3d4,0xc011b446
c0100ef4:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100ef6:	0f b7 05 46 b4 11 c0 	movzwl 0xc011b446,%eax
c0100efd:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c0100f01:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f05:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100f09:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100f0d:	ee                   	out    %al,(%dx)
}
c0100f0e:	90                   	nop
    pos = inb(addr_6845 + 1) << 8;
c0100f0f:	0f b7 05 46 b4 11 c0 	movzwl 0xc011b446,%eax
c0100f16:	40                   	inc    %eax
c0100f17:	0f b7 c0             	movzwl %ax,%eax
c0100f1a:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f1e:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100f22:	89 c2                	mov    %eax,%edx
c0100f24:	ec                   	in     (%dx),%al
c0100f25:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
c0100f28:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100f2c:	0f b6 c0             	movzbl %al,%eax
c0100f2f:	c1 e0 08             	shl    $0x8,%eax
c0100f32:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100f35:	0f b7 05 46 b4 11 c0 	movzwl 0xc011b446,%eax
c0100f3c:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0100f40:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f44:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f48:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100f4c:	ee                   	out    %al,(%dx)
}
c0100f4d:	90                   	nop
    pos |= inb(addr_6845 + 1);
c0100f4e:	0f b7 05 46 b4 11 c0 	movzwl 0xc011b446,%eax
c0100f55:	40                   	inc    %eax
c0100f56:	0f b7 c0             	movzwl %ax,%eax
c0100f59:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f5d:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100f61:	89 c2                	mov    %eax,%edx
c0100f63:	ec                   	in     (%dx),%al
c0100f64:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
c0100f67:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100f6b:	0f b6 c0             	movzbl %al,%eax
c0100f6e:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100f71:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f74:	a3 40 b4 11 c0       	mov    %eax,0xc011b440
    crt_pos = pos;
c0100f79:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100f7c:	0f b7 c0             	movzwl %ax,%eax
c0100f7f:	66 a3 44 b4 11 c0    	mov    %ax,0xc011b444
}
c0100f85:	90                   	nop
c0100f86:	89 ec                	mov    %ebp,%esp
c0100f88:	5d                   	pop    %ebp
c0100f89:	c3                   	ret    

c0100f8a <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100f8a:	55                   	push   %ebp
c0100f8b:	89 e5                	mov    %esp,%ebp
c0100f8d:	83 ec 48             	sub    $0x48,%esp
c0100f90:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
c0100f96:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f9a:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0100f9e:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0100fa2:	ee                   	out    %al,(%dx)
}
c0100fa3:	90                   	nop
c0100fa4:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
c0100faa:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100fae:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0100fb2:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0100fb6:	ee                   	out    %al,(%dx)
}
c0100fb7:	90                   	nop
c0100fb8:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
c0100fbe:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100fc2:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0100fc6:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0100fca:	ee                   	out    %al,(%dx)
}
c0100fcb:	90                   	nop
c0100fcc:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0100fd2:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100fd6:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0100fda:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0100fde:	ee                   	out    %al,(%dx)
}
c0100fdf:	90                   	nop
c0100fe0:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
c0100fe6:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100fea:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0100fee:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0100ff2:	ee                   	out    %al,(%dx)
}
c0100ff3:	90                   	nop
c0100ff4:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
c0100ffa:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ffe:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101002:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101006:	ee                   	out    %al,(%dx)
}
c0101007:	90                   	nop
c0101008:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c010100e:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101012:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101016:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010101a:	ee                   	out    %al,(%dx)
}
c010101b:	90                   	nop
c010101c:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101022:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0101026:	89 c2                	mov    %eax,%edx
c0101028:	ec                   	in     (%dx),%al
c0101029:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c010102c:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0101030:	3c ff                	cmp    $0xff,%al
c0101032:	0f 95 c0             	setne  %al
c0101035:	0f b6 c0             	movzbl %al,%eax
c0101038:	a3 48 b4 11 c0       	mov    %eax,0xc011b448
c010103d:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101043:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101047:	89 c2                	mov    %eax,%edx
c0101049:	ec                   	in     (%dx),%al
c010104a:	88 45 f1             	mov    %al,-0xf(%ebp)
c010104d:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101053:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101057:	89 c2                	mov    %eax,%edx
c0101059:	ec                   	in     (%dx),%al
c010105a:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c010105d:	a1 48 b4 11 c0       	mov    0xc011b448,%eax
c0101062:	85 c0                	test   %eax,%eax
c0101064:	74 0c                	je     c0101072 <serial_init+0xe8>
        pic_enable(IRQ_COM1);
c0101066:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c010106d:	e8 27 07 00 00       	call   c0101799 <pic_enable>
    }
}
c0101072:	90                   	nop
c0101073:	89 ec                	mov    %ebp,%esp
c0101075:	5d                   	pop    %ebp
c0101076:	c3                   	ret    

c0101077 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c0101077:	55                   	push   %ebp
c0101078:	89 e5                	mov    %esp,%ebp
c010107a:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c010107d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101084:	eb 08                	jmp    c010108e <lpt_putc_sub+0x17>
        delay();
c0101086:	e8 cc fd ff ff       	call   c0100e57 <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c010108b:	ff 45 fc             	incl   -0x4(%ebp)
c010108e:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c0101094:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101098:	89 c2                	mov    %eax,%edx
c010109a:	ec                   	in     (%dx),%al
c010109b:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c010109e:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01010a2:	84 c0                	test   %al,%al
c01010a4:	78 09                	js     c01010af <lpt_putc_sub+0x38>
c01010a6:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01010ad:	7e d7                	jle    c0101086 <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
c01010af:	8b 45 08             	mov    0x8(%ebp),%eax
c01010b2:	0f b6 c0             	movzbl %al,%eax
c01010b5:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
c01010bb:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010be:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01010c2:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01010c6:	ee                   	out    %al,(%dx)
}
c01010c7:	90                   	nop
c01010c8:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c01010ce:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010d2:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01010d6:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01010da:	ee                   	out    %al,(%dx)
}
c01010db:	90                   	nop
c01010dc:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c01010e2:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010e6:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01010ea:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01010ee:	ee                   	out    %al,(%dx)
}
c01010ef:	90                   	nop
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c01010f0:	90                   	nop
c01010f1:	89 ec                	mov    %ebp,%esp
c01010f3:	5d                   	pop    %ebp
c01010f4:	c3                   	ret    

c01010f5 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c01010f5:	55                   	push   %ebp
c01010f6:	89 e5                	mov    %esp,%ebp
c01010f8:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01010fb:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01010ff:	74 0d                	je     c010110e <lpt_putc+0x19>
        lpt_putc_sub(c);
c0101101:	8b 45 08             	mov    0x8(%ebp),%eax
c0101104:	89 04 24             	mov    %eax,(%esp)
c0101107:	e8 6b ff ff ff       	call   c0101077 <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c010110c:	eb 24                	jmp    c0101132 <lpt_putc+0x3d>
        lpt_putc_sub('\b');
c010110e:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101115:	e8 5d ff ff ff       	call   c0101077 <lpt_putc_sub>
        lpt_putc_sub(' ');
c010111a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101121:	e8 51 ff ff ff       	call   c0101077 <lpt_putc_sub>
        lpt_putc_sub('\b');
c0101126:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010112d:	e8 45 ff ff ff       	call   c0101077 <lpt_putc_sub>
}
c0101132:	90                   	nop
c0101133:	89 ec                	mov    %ebp,%esp
c0101135:	5d                   	pop    %ebp
c0101136:	c3                   	ret    

c0101137 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0101137:	55                   	push   %ebp
c0101138:	89 e5                	mov    %esp,%ebp
c010113a:	83 ec 38             	sub    $0x38,%esp
c010113d:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    // set black on white
    if (!(c & ~0xFF)) {
c0101140:	8b 45 08             	mov    0x8(%ebp),%eax
c0101143:	25 00 ff ff ff       	and    $0xffffff00,%eax
c0101148:	85 c0                	test   %eax,%eax
c010114a:	75 07                	jne    c0101153 <cga_putc+0x1c>
        c |= 0x0700;
c010114c:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0101153:	8b 45 08             	mov    0x8(%ebp),%eax
c0101156:	0f b6 c0             	movzbl %al,%eax
c0101159:	83 f8 0d             	cmp    $0xd,%eax
c010115c:	74 72                	je     c01011d0 <cga_putc+0x99>
c010115e:	83 f8 0d             	cmp    $0xd,%eax
c0101161:	0f 8f a3 00 00 00    	jg     c010120a <cga_putc+0xd3>
c0101167:	83 f8 08             	cmp    $0x8,%eax
c010116a:	74 0a                	je     c0101176 <cga_putc+0x3f>
c010116c:	83 f8 0a             	cmp    $0xa,%eax
c010116f:	74 4c                	je     c01011bd <cga_putc+0x86>
c0101171:	e9 94 00 00 00       	jmp    c010120a <cga_putc+0xd3>
    case '\b':
        if (crt_pos > 0) {
c0101176:	0f b7 05 44 b4 11 c0 	movzwl 0xc011b444,%eax
c010117d:	85 c0                	test   %eax,%eax
c010117f:	0f 84 af 00 00 00    	je     c0101234 <cga_putc+0xfd>
            crt_pos --;
c0101185:	0f b7 05 44 b4 11 c0 	movzwl 0xc011b444,%eax
c010118c:	48                   	dec    %eax
c010118d:	0f b7 c0             	movzwl %ax,%eax
c0101190:	66 a3 44 b4 11 c0    	mov    %ax,0xc011b444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c0101196:	8b 45 08             	mov    0x8(%ebp),%eax
c0101199:	98                   	cwtl   
c010119a:	25 00 ff ff ff       	and    $0xffffff00,%eax
c010119f:	98                   	cwtl   
c01011a0:	83 c8 20             	or     $0x20,%eax
c01011a3:	98                   	cwtl   
c01011a4:	8b 0d 40 b4 11 c0    	mov    0xc011b440,%ecx
c01011aa:	0f b7 15 44 b4 11 c0 	movzwl 0xc011b444,%edx
c01011b1:	01 d2                	add    %edx,%edx
c01011b3:	01 ca                	add    %ecx,%edx
c01011b5:	0f b7 c0             	movzwl %ax,%eax
c01011b8:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c01011bb:	eb 77                	jmp    c0101234 <cga_putc+0xfd>
    case '\n':
        crt_pos += CRT_COLS;
c01011bd:	0f b7 05 44 b4 11 c0 	movzwl 0xc011b444,%eax
c01011c4:	83 c0 50             	add    $0x50,%eax
c01011c7:	0f b7 c0             	movzwl %ax,%eax
c01011ca:	66 a3 44 b4 11 c0    	mov    %ax,0xc011b444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c01011d0:	0f b7 1d 44 b4 11 c0 	movzwl 0xc011b444,%ebx
c01011d7:	0f b7 0d 44 b4 11 c0 	movzwl 0xc011b444,%ecx
c01011de:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
c01011e3:	89 c8                	mov    %ecx,%eax
c01011e5:	f7 e2                	mul    %edx
c01011e7:	c1 ea 06             	shr    $0x6,%edx
c01011ea:	89 d0                	mov    %edx,%eax
c01011ec:	c1 e0 02             	shl    $0x2,%eax
c01011ef:	01 d0                	add    %edx,%eax
c01011f1:	c1 e0 04             	shl    $0x4,%eax
c01011f4:	29 c1                	sub    %eax,%ecx
c01011f6:	89 ca                	mov    %ecx,%edx
c01011f8:	0f b7 d2             	movzwl %dx,%edx
c01011fb:	89 d8                	mov    %ebx,%eax
c01011fd:	29 d0                	sub    %edx,%eax
c01011ff:	0f b7 c0             	movzwl %ax,%eax
c0101202:	66 a3 44 b4 11 c0    	mov    %ax,0xc011b444
        break;
c0101208:	eb 2b                	jmp    c0101235 <cga_putc+0xfe>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c010120a:	8b 0d 40 b4 11 c0    	mov    0xc011b440,%ecx
c0101210:	0f b7 05 44 b4 11 c0 	movzwl 0xc011b444,%eax
c0101217:	8d 50 01             	lea    0x1(%eax),%edx
c010121a:	0f b7 d2             	movzwl %dx,%edx
c010121d:	66 89 15 44 b4 11 c0 	mov    %dx,0xc011b444
c0101224:	01 c0                	add    %eax,%eax
c0101226:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c0101229:	8b 45 08             	mov    0x8(%ebp),%eax
c010122c:	0f b7 c0             	movzwl %ax,%eax
c010122f:	66 89 02             	mov    %ax,(%edx)
        break;
c0101232:	eb 01                	jmp    c0101235 <cga_putc+0xfe>
        break;
c0101234:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c0101235:	0f b7 05 44 b4 11 c0 	movzwl 0xc011b444,%eax
c010123c:	3d cf 07 00 00       	cmp    $0x7cf,%eax
c0101241:	76 5e                	jbe    c01012a1 <cga_putc+0x16a>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0101243:	a1 40 b4 11 c0       	mov    0xc011b440,%eax
c0101248:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c010124e:	a1 40 b4 11 c0       	mov    0xc011b440,%eax
c0101253:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c010125a:	00 
c010125b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010125f:	89 04 24             	mov    %eax,(%esp)
c0101262:	e8 d8 4b 00 00       	call   c0105e3f <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101267:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c010126e:	eb 15                	jmp    c0101285 <cga_putc+0x14e>
            crt_buf[i] = 0x0700 | ' ';
c0101270:	8b 15 40 b4 11 c0    	mov    0xc011b440,%edx
c0101276:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101279:	01 c0                	add    %eax,%eax
c010127b:	01 d0                	add    %edx,%eax
c010127d:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101282:	ff 45 f4             	incl   -0xc(%ebp)
c0101285:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c010128c:	7e e2                	jle    c0101270 <cga_putc+0x139>
        }
        crt_pos -= CRT_COLS;
c010128e:	0f b7 05 44 b4 11 c0 	movzwl 0xc011b444,%eax
c0101295:	83 e8 50             	sub    $0x50,%eax
c0101298:	0f b7 c0             	movzwl %ax,%eax
c010129b:	66 a3 44 b4 11 c0    	mov    %ax,0xc011b444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c01012a1:	0f b7 05 46 b4 11 c0 	movzwl 0xc011b446,%eax
c01012a8:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c01012ac:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01012b0:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01012b4:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01012b8:	ee                   	out    %al,(%dx)
}
c01012b9:	90                   	nop
    outb(addr_6845 + 1, crt_pos >> 8);
c01012ba:	0f b7 05 44 b4 11 c0 	movzwl 0xc011b444,%eax
c01012c1:	c1 e8 08             	shr    $0x8,%eax
c01012c4:	0f b7 c0             	movzwl %ax,%eax
c01012c7:	0f b6 c0             	movzbl %al,%eax
c01012ca:	0f b7 15 46 b4 11 c0 	movzwl 0xc011b446,%edx
c01012d1:	42                   	inc    %edx
c01012d2:	0f b7 d2             	movzwl %dx,%edx
c01012d5:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c01012d9:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01012dc:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01012e0:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01012e4:	ee                   	out    %al,(%dx)
}
c01012e5:	90                   	nop
    outb(addr_6845, 15);
c01012e6:	0f b7 05 46 b4 11 c0 	movzwl 0xc011b446,%eax
c01012ed:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c01012f1:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01012f5:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01012f9:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01012fd:	ee                   	out    %al,(%dx)
}
c01012fe:	90                   	nop
    outb(addr_6845 + 1, crt_pos);
c01012ff:	0f b7 05 44 b4 11 c0 	movzwl 0xc011b444,%eax
c0101306:	0f b6 c0             	movzbl %al,%eax
c0101309:	0f b7 15 46 b4 11 c0 	movzwl 0xc011b446,%edx
c0101310:	42                   	inc    %edx
c0101311:	0f b7 d2             	movzwl %dx,%edx
c0101314:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
c0101318:	88 45 f1             	mov    %al,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010131b:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010131f:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101323:	ee                   	out    %al,(%dx)
}
c0101324:	90                   	nop
}
c0101325:	90                   	nop
c0101326:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0101329:	89 ec                	mov    %ebp,%esp
c010132b:	5d                   	pop    %ebp
c010132c:	c3                   	ret    

c010132d <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c010132d:	55                   	push   %ebp
c010132e:	89 e5                	mov    %esp,%ebp
c0101330:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101333:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010133a:	eb 08                	jmp    c0101344 <serial_putc_sub+0x17>
        delay();
c010133c:	e8 16 fb ff ff       	call   c0100e57 <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101341:	ff 45 fc             	incl   -0x4(%ebp)
c0101344:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010134a:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c010134e:	89 c2                	mov    %eax,%edx
c0101350:	ec                   	in     (%dx),%al
c0101351:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101354:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101358:	0f b6 c0             	movzbl %al,%eax
c010135b:	83 e0 20             	and    $0x20,%eax
c010135e:	85 c0                	test   %eax,%eax
c0101360:	75 09                	jne    c010136b <serial_putc_sub+0x3e>
c0101362:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101369:	7e d1                	jle    c010133c <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
c010136b:	8b 45 08             	mov    0x8(%ebp),%eax
c010136e:	0f b6 c0             	movzbl %al,%eax
c0101371:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101377:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010137a:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010137e:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101382:	ee                   	out    %al,(%dx)
}
c0101383:	90                   	nop
}
c0101384:	90                   	nop
c0101385:	89 ec                	mov    %ebp,%esp
c0101387:	5d                   	pop    %ebp
c0101388:	c3                   	ret    

c0101389 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101389:	55                   	push   %ebp
c010138a:	89 e5                	mov    %esp,%ebp
c010138c:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c010138f:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101393:	74 0d                	je     c01013a2 <serial_putc+0x19>
        serial_putc_sub(c);
c0101395:	8b 45 08             	mov    0x8(%ebp),%eax
c0101398:	89 04 24             	mov    %eax,(%esp)
c010139b:	e8 8d ff ff ff       	call   c010132d <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c01013a0:	eb 24                	jmp    c01013c6 <serial_putc+0x3d>
        serial_putc_sub('\b');
c01013a2:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01013a9:	e8 7f ff ff ff       	call   c010132d <serial_putc_sub>
        serial_putc_sub(' ');
c01013ae:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01013b5:	e8 73 ff ff ff       	call   c010132d <serial_putc_sub>
        serial_putc_sub('\b');
c01013ba:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01013c1:	e8 67 ff ff ff       	call   c010132d <serial_putc_sub>
}
c01013c6:	90                   	nop
c01013c7:	89 ec                	mov    %ebp,%esp
c01013c9:	5d                   	pop    %ebp
c01013ca:	c3                   	ret    

c01013cb <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c01013cb:	55                   	push   %ebp
c01013cc:	89 e5                	mov    %esp,%ebp
c01013ce:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c01013d1:	eb 33                	jmp    c0101406 <cons_intr+0x3b>
        if (c != 0) {
c01013d3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01013d7:	74 2d                	je     c0101406 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c01013d9:	a1 64 b6 11 c0       	mov    0xc011b664,%eax
c01013de:	8d 50 01             	lea    0x1(%eax),%edx
c01013e1:	89 15 64 b6 11 c0    	mov    %edx,0xc011b664
c01013e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01013ea:	88 90 60 b4 11 c0    	mov    %dl,-0x3fee4ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c01013f0:	a1 64 b6 11 c0       	mov    0xc011b664,%eax
c01013f5:	3d 00 02 00 00       	cmp    $0x200,%eax
c01013fa:	75 0a                	jne    c0101406 <cons_intr+0x3b>
                cons.wpos = 0;
c01013fc:	c7 05 64 b6 11 c0 00 	movl   $0x0,0xc011b664
c0101403:	00 00 00 
    while ((c = (*proc)()) != -1) {
c0101406:	8b 45 08             	mov    0x8(%ebp),%eax
c0101409:	ff d0                	call   *%eax
c010140b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010140e:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0101412:	75 bf                	jne    c01013d3 <cons_intr+0x8>
            }
        }
    }
}
c0101414:	90                   	nop
c0101415:	90                   	nop
c0101416:	89 ec                	mov    %ebp,%esp
c0101418:	5d                   	pop    %ebp
c0101419:	c3                   	ret    

c010141a <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c010141a:	55                   	push   %ebp
c010141b:	89 e5                	mov    %esp,%ebp
c010141d:	83 ec 10             	sub    $0x10,%esp
c0101420:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101426:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c010142a:	89 c2                	mov    %eax,%edx
c010142c:	ec                   	in     (%dx),%al
c010142d:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101430:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c0101434:	0f b6 c0             	movzbl %al,%eax
c0101437:	83 e0 01             	and    $0x1,%eax
c010143a:	85 c0                	test   %eax,%eax
c010143c:	75 07                	jne    c0101445 <serial_proc_data+0x2b>
        return -1;
c010143e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101443:	eb 2a                	jmp    c010146f <serial_proc_data+0x55>
c0101445:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010144b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010144f:	89 c2                	mov    %eax,%edx
c0101451:	ec                   	in     (%dx),%al
c0101452:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c0101455:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c0101459:	0f b6 c0             	movzbl %al,%eax
c010145c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c010145f:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101463:	75 07                	jne    c010146c <serial_proc_data+0x52>
        c = '\b';
c0101465:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c010146c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010146f:	89 ec                	mov    %ebp,%esp
c0101471:	5d                   	pop    %ebp
c0101472:	c3                   	ret    

c0101473 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101473:	55                   	push   %ebp
c0101474:	89 e5                	mov    %esp,%ebp
c0101476:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c0101479:	a1 48 b4 11 c0       	mov    0xc011b448,%eax
c010147e:	85 c0                	test   %eax,%eax
c0101480:	74 0c                	je     c010148e <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c0101482:	c7 04 24 1a 14 10 c0 	movl   $0xc010141a,(%esp)
c0101489:	e8 3d ff ff ff       	call   c01013cb <cons_intr>
    }
}
c010148e:	90                   	nop
c010148f:	89 ec                	mov    %ebp,%esp
c0101491:	5d                   	pop    %ebp
c0101492:	c3                   	ret    

c0101493 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101493:	55                   	push   %ebp
c0101494:	89 e5                	mov    %esp,%ebp
c0101496:	83 ec 38             	sub    $0x38,%esp
c0101499:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010149f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01014a2:	89 c2                	mov    %eax,%edx
c01014a4:	ec                   	in     (%dx),%al
c01014a5:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c01014a8:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c01014ac:	0f b6 c0             	movzbl %al,%eax
c01014af:	83 e0 01             	and    $0x1,%eax
c01014b2:	85 c0                	test   %eax,%eax
c01014b4:	75 0a                	jne    c01014c0 <kbd_proc_data+0x2d>
        return -1;
c01014b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01014bb:	e9 56 01 00 00       	jmp    c0101616 <kbd_proc_data+0x183>
c01014c0:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01014c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01014c9:	89 c2                	mov    %eax,%edx
c01014cb:	ec                   	in     (%dx),%al
c01014cc:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c01014cf:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c01014d3:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c01014d6:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c01014da:	75 17                	jne    c01014f3 <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
c01014dc:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c01014e1:	83 c8 40             	or     $0x40,%eax
c01014e4:	a3 68 b6 11 c0       	mov    %eax,0xc011b668
        return 0;
c01014e9:	b8 00 00 00 00       	mov    $0x0,%eax
c01014ee:	e9 23 01 00 00       	jmp    c0101616 <kbd_proc_data+0x183>
    } else if (data & 0x80) {
c01014f3:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014f7:	84 c0                	test   %al,%al
c01014f9:	79 45                	jns    c0101540 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c01014fb:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c0101500:	83 e0 40             	and    $0x40,%eax
c0101503:	85 c0                	test   %eax,%eax
c0101505:	75 08                	jne    c010150f <kbd_proc_data+0x7c>
c0101507:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010150b:	24 7f                	and    $0x7f,%al
c010150d:	eb 04                	jmp    c0101513 <kbd_proc_data+0x80>
c010150f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101513:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c0101516:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010151a:	0f b6 80 40 80 11 c0 	movzbl -0x3fee7fc0(%eax),%eax
c0101521:	0c 40                	or     $0x40,%al
c0101523:	0f b6 c0             	movzbl %al,%eax
c0101526:	f7 d0                	not    %eax
c0101528:	89 c2                	mov    %eax,%edx
c010152a:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c010152f:	21 d0                	and    %edx,%eax
c0101531:	a3 68 b6 11 c0       	mov    %eax,0xc011b668
        return 0;
c0101536:	b8 00 00 00 00       	mov    $0x0,%eax
c010153b:	e9 d6 00 00 00       	jmp    c0101616 <kbd_proc_data+0x183>
    } else if (shift & E0ESC) {
c0101540:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c0101545:	83 e0 40             	and    $0x40,%eax
c0101548:	85 c0                	test   %eax,%eax
c010154a:	74 11                	je     c010155d <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c010154c:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0101550:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c0101555:	83 e0 bf             	and    $0xffffffbf,%eax
c0101558:	a3 68 b6 11 c0       	mov    %eax,0xc011b668
    }

    shift |= shiftcode[data];
c010155d:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101561:	0f b6 80 40 80 11 c0 	movzbl -0x3fee7fc0(%eax),%eax
c0101568:	0f b6 d0             	movzbl %al,%edx
c010156b:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c0101570:	09 d0                	or     %edx,%eax
c0101572:	a3 68 b6 11 c0       	mov    %eax,0xc011b668
    shift ^= togglecode[data];
c0101577:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010157b:	0f b6 80 40 81 11 c0 	movzbl -0x3fee7ec0(%eax),%eax
c0101582:	0f b6 d0             	movzbl %al,%edx
c0101585:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c010158a:	31 d0                	xor    %edx,%eax
c010158c:	a3 68 b6 11 c0       	mov    %eax,0xc011b668

    c = charcode[shift & (CTL | SHIFT)][data];
c0101591:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c0101596:	83 e0 03             	and    $0x3,%eax
c0101599:	8b 14 85 40 85 11 c0 	mov    -0x3fee7ac0(,%eax,4),%edx
c01015a0:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015a4:	01 d0                	add    %edx,%eax
c01015a6:	0f b6 00             	movzbl (%eax),%eax
c01015a9:	0f b6 c0             	movzbl %al,%eax
c01015ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c01015af:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c01015b4:	83 e0 08             	and    $0x8,%eax
c01015b7:	85 c0                	test   %eax,%eax
c01015b9:	74 22                	je     c01015dd <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
c01015bb:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c01015bf:	7e 0c                	jle    c01015cd <kbd_proc_data+0x13a>
c01015c1:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c01015c5:	7f 06                	jg     c01015cd <kbd_proc_data+0x13a>
            c += 'A' - 'a';
c01015c7:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c01015cb:	eb 10                	jmp    c01015dd <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
c01015cd:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c01015d1:	7e 0a                	jle    c01015dd <kbd_proc_data+0x14a>
c01015d3:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c01015d7:	7f 04                	jg     c01015dd <kbd_proc_data+0x14a>
            c += 'a' - 'A';
c01015d9:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c01015dd:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c01015e2:	f7 d0                	not    %eax
c01015e4:	83 e0 06             	and    $0x6,%eax
c01015e7:	85 c0                	test   %eax,%eax
c01015e9:	75 28                	jne    c0101613 <kbd_proc_data+0x180>
c01015eb:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c01015f2:	75 1f                	jne    c0101613 <kbd_proc_data+0x180>
        cprintf("Rebooting!\n");
c01015f4:	c7 04 24 cf 62 10 c0 	movl   $0xc01062cf,(%esp)
c01015fb:	e8 56 ed ff ff       	call   c0100356 <cprintf>
c0101600:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c0101606:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010160a:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c010160e:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0101611:	ee                   	out    %al,(%dx)
}
c0101612:	90                   	nop
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c0101613:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101616:	89 ec                	mov    %ebp,%esp
c0101618:	5d                   	pop    %ebp
c0101619:	c3                   	ret    

c010161a <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c010161a:	55                   	push   %ebp
c010161b:	89 e5                	mov    %esp,%ebp
c010161d:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c0101620:	c7 04 24 93 14 10 c0 	movl   $0xc0101493,(%esp)
c0101627:	e8 9f fd ff ff       	call   c01013cb <cons_intr>
}
c010162c:	90                   	nop
c010162d:	89 ec                	mov    %ebp,%esp
c010162f:	5d                   	pop    %ebp
c0101630:	c3                   	ret    

c0101631 <kbd_init>:

static void
kbd_init(void) {
c0101631:	55                   	push   %ebp
c0101632:	89 e5                	mov    %esp,%ebp
c0101634:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c0101637:	e8 de ff ff ff       	call   c010161a <kbd_intr>
    pic_enable(IRQ_KBD);
c010163c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0101643:	e8 51 01 00 00       	call   c0101799 <pic_enable>
}
c0101648:	90                   	nop
c0101649:	89 ec                	mov    %ebp,%esp
c010164b:	5d                   	pop    %ebp
c010164c:	c3                   	ret    

c010164d <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c010164d:	55                   	push   %ebp
c010164e:	89 e5                	mov    %esp,%ebp
c0101650:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c0101653:	e8 4a f8 ff ff       	call   c0100ea2 <cga_init>
    serial_init();
c0101658:	e8 2d f9 ff ff       	call   c0100f8a <serial_init>
    kbd_init();
c010165d:	e8 cf ff ff ff       	call   c0101631 <kbd_init>
    if (!serial_exists) {
c0101662:	a1 48 b4 11 c0       	mov    0xc011b448,%eax
c0101667:	85 c0                	test   %eax,%eax
c0101669:	75 0c                	jne    c0101677 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c010166b:	c7 04 24 db 62 10 c0 	movl   $0xc01062db,(%esp)
c0101672:	e8 df ec ff ff       	call   c0100356 <cprintf>
    }
}
c0101677:	90                   	nop
c0101678:	89 ec                	mov    %ebp,%esp
c010167a:	5d                   	pop    %ebp
c010167b:	c3                   	ret    

c010167c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c010167c:	55                   	push   %ebp
c010167d:	89 e5                	mov    %esp,%ebp
c010167f:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101682:	e8 8e f7 ff ff       	call   c0100e15 <__intr_save>
c0101687:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c010168a:	8b 45 08             	mov    0x8(%ebp),%eax
c010168d:	89 04 24             	mov    %eax,(%esp)
c0101690:	e8 60 fa ff ff       	call   c01010f5 <lpt_putc>
        cga_putc(c);
c0101695:	8b 45 08             	mov    0x8(%ebp),%eax
c0101698:	89 04 24             	mov    %eax,(%esp)
c010169b:	e8 97 fa ff ff       	call   c0101137 <cga_putc>
        serial_putc(c);
c01016a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01016a3:	89 04 24             	mov    %eax,(%esp)
c01016a6:	e8 de fc ff ff       	call   c0101389 <serial_putc>
    }
    local_intr_restore(intr_flag);
c01016ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01016ae:	89 04 24             	mov    %eax,(%esp)
c01016b1:	e8 8b f7 ff ff       	call   c0100e41 <__intr_restore>
}
c01016b6:	90                   	nop
c01016b7:	89 ec                	mov    %ebp,%esp
c01016b9:	5d                   	pop    %ebp
c01016ba:	c3                   	ret    

c01016bb <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c01016bb:	55                   	push   %ebp
c01016bc:	89 e5                	mov    %esp,%ebp
c01016be:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c01016c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c01016c8:	e8 48 f7 ff ff       	call   c0100e15 <__intr_save>
c01016cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c01016d0:	e8 9e fd ff ff       	call   c0101473 <serial_intr>
        kbd_intr();
c01016d5:	e8 40 ff ff ff       	call   c010161a <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c01016da:	8b 15 60 b6 11 c0    	mov    0xc011b660,%edx
c01016e0:	a1 64 b6 11 c0       	mov    0xc011b664,%eax
c01016e5:	39 c2                	cmp    %eax,%edx
c01016e7:	74 31                	je     c010171a <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c01016e9:	a1 60 b6 11 c0       	mov    0xc011b660,%eax
c01016ee:	8d 50 01             	lea    0x1(%eax),%edx
c01016f1:	89 15 60 b6 11 c0    	mov    %edx,0xc011b660
c01016f7:	0f b6 80 60 b4 11 c0 	movzbl -0x3fee4ba0(%eax),%eax
c01016fe:	0f b6 c0             	movzbl %al,%eax
c0101701:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c0101704:	a1 60 b6 11 c0       	mov    0xc011b660,%eax
c0101709:	3d 00 02 00 00       	cmp    $0x200,%eax
c010170e:	75 0a                	jne    c010171a <cons_getc+0x5f>
                cons.rpos = 0;
c0101710:	c7 05 60 b6 11 c0 00 	movl   $0x0,0xc011b660
c0101717:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c010171a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010171d:	89 04 24             	mov    %eax,(%esp)
c0101720:	e8 1c f7 ff ff       	call   c0100e41 <__intr_restore>
    return c;
c0101725:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101728:	89 ec                	mov    %ebp,%esp
c010172a:	5d                   	pop    %ebp
c010172b:	c3                   	ret    

c010172c <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c010172c:	55                   	push   %ebp
c010172d:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
c010172f:	fb                   	sti    
}
c0101730:	90                   	nop
    sti();
}
c0101731:	90                   	nop
c0101732:	5d                   	pop    %ebp
c0101733:	c3                   	ret    

c0101734 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c0101734:	55                   	push   %ebp
c0101735:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
c0101737:	fa                   	cli    
}
c0101738:	90                   	nop
    cli();
}
c0101739:	90                   	nop
c010173a:	5d                   	pop    %ebp
c010173b:	c3                   	ret    

c010173c <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c010173c:	55                   	push   %ebp
c010173d:	89 e5                	mov    %esp,%ebp
c010173f:	83 ec 14             	sub    $0x14,%esp
c0101742:	8b 45 08             	mov    0x8(%ebp),%eax
c0101745:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c0101749:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010174c:	66 a3 50 85 11 c0    	mov    %ax,0xc0118550
    if (did_init) {
c0101752:	a1 6c b6 11 c0       	mov    0xc011b66c,%eax
c0101757:	85 c0                	test   %eax,%eax
c0101759:	74 39                	je     c0101794 <pic_setmask+0x58>
        outb(IO_PIC1 + 1, mask);
c010175b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010175e:	0f b6 c0             	movzbl %al,%eax
c0101761:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
c0101767:	88 45 f9             	mov    %al,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010176a:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010176e:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101772:	ee                   	out    %al,(%dx)
}
c0101773:	90                   	nop
        outb(IO_PIC2 + 1, mask >> 8);
c0101774:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101778:	c1 e8 08             	shr    $0x8,%eax
c010177b:	0f b7 c0             	movzwl %ax,%eax
c010177e:	0f b6 c0             	movzbl %al,%eax
c0101781:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
c0101787:	88 45 fd             	mov    %al,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010178a:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c010178e:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101792:	ee                   	out    %al,(%dx)
}
c0101793:	90                   	nop
    }
}
c0101794:	90                   	nop
c0101795:	89 ec                	mov    %ebp,%esp
c0101797:	5d                   	pop    %ebp
c0101798:	c3                   	ret    

c0101799 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0101799:	55                   	push   %ebp
c010179a:	89 e5                	mov    %esp,%ebp
c010179c:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c010179f:	8b 45 08             	mov    0x8(%ebp),%eax
c01017a2:	ba 01 00 00 00       	mov    $0x1,%edx
c01017a7:	88 c1                	mov    %al,%cl
c01017a9:	d3 e2                	shl    %cl,%edx
c01017ab:	89 d0                	mov    %edx,%eax
c01017ad:	98                   	cwtl   
c01017ae:	f7 d0                	not    %eax
c01017b0:	0f bf d0             	movswl %ax,%edx
c01017b3:	0f b7 05 50 85 11 c0 	movzwl 0xc0118550,%eax
c01017ba:	98                   	cwtl   
c01017bb:	21 d0                	and    %edx,%eax
c01017bd:	98                   	cwtl   
c01017be:	0f b7 c0             	movzwl %ax,%eax
c01017c1:	89 04 24             	mov    %eax,(%esp)
c01017c4:	e8 73 ff ff ff       	call   c010173c <pic_setmask>
}
c01017c9:	90                   	nop
c01017ca:	89 ec                	mov    %ebp,%esp
c01017cc:	5d                   	pop    %ebp
c01017cd:	c3                   	ret    

c01017ce <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c01017ce:	55                   	push   %ebp
c01017cf:	89 e5                	mov    %esp,%ebp
c01017d1:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c01017d4:	c7 05 6c b6 11 c0 01 	movl   $0x1,0xc011b66c
c01017db:	00 00 00 
c01017de:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
c01017e4:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01017e8:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c01017ec:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c01017f0:	ee                   	out    %al,(%dx)
}
c01017f1:	90                   	nop
c01017f2:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
c01017f8:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01017fc:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0101800:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0101804:	ee                   	out    %al,(%dx)
}
c0101805:	90                   	nop
c0101806:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c010180c:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101810:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0101814:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0101818:	ee                   	out    %al,(%dx)
}
c0101819:	90                   	nop
c010181a:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
c0101820:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101824:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101828:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c010182c:	ee                   	out    %al,(%dx)
}
c010182d:	90                   	nop
c010182e:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
c0101834:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101838:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c010183c:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101840:	ee                   	out    %al,(%dx)
}
c0101841:	90                   	nop
c0101842:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
c0101848:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010184c:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101850:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101854:	ee                   	out    %al,(%dx)
}
c0101855:	90                   	nop
c0101856:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
c010185c:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101860:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101864:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101868:	ee                   	out    %al,(%dx)
}
c0101869:	90                   	nop
c010186a:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
c0101870:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101874:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101878:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010187c:	ee                   	out    %al,(%dx)
}
c010187d:	90                   	nop
c010187e:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
c0101884:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101888:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c010188c:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101890:	ee                   	out    %al,(%dx)
}
c0101891:	90                   	nop
c0101892:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c0101898:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010189c:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01018a0:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01018a4:	ee                   	out    %al,(%dx)
}
c01018a5:	90                   	nop
c01018a6:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
c01018ac:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018b0:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01018b4:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01018b8:	ee                   	out    %al,(%dx)
}
c01018b9:	90                   	nop
c01018ba:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c01018c0:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018c4:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01018c8:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01018cc:	ee                   	out    %al,(%dx)
}
c01018cd:	90                   	nop
c01018ce:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
c01018d4:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018d8:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01018dc:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c01018e0:	ee                   	out    %al,(%dx)
}
c01018e1:	90                   	nop
c01018e2:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
c01018e8:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018ec:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c01018f0:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c01018f4:	ee                   	out    %al,(%dx)
}
c01018f5:	90                   	nop
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c01018f6:	0f b7 05 50 85 11 c0 	movzwl 0xc0118550,%eax
c01018fd:	3d ff ff 00 00       	cmp    $0xffff,%eax
c0101902:	74 0f                	je     c0101913 <pic_init+0x145>
        pic_setmask(irq_mask);
c0101904:	0f b7 05 50 85 11 c0 	movzwl 0xc0118550,%eax
c010190b:	89 04 24             	mov    %eax,(%esp)
c010190e:	e8 29 fe ff ff       	call   c010173c <pic_setmask>
    }
}
c0101913:	90                   	nop
c0101914:	89 ec                	mov    %ebp,%esp
c0101916:	5d                   	pop    %ebp
c0101917:	c3                   	ret    

c0101918 <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c0101918:	55                   	push   %ebp
c0101919:	89 e5                	mov    %esp,%ebp
c010191b:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c010191e:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0101925:	00 
c0101926:	c7 04 24 00 63 10 c0 	movl   $0xc0106300,(%esp)
c010192d:	e8 24 ea ff ff       	call   c0100356 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
c0101932:	c7 04 24 0a 63 10 c0 	movl   $0xc010630a,(%esp)
c0101939:	e8 18 ea ff ff       	call   c0100356 <cprintf>
    panic("EOT: kernel seems ok.");
c010193e:	c7 44 24 08 18 63 10 	movl   $0xc0106318,0x8(%esp)
c0101945:	c0 
c0101946:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
c010194d:	00 
c010194e:	c7 04 24 2e 63 10 c0 	movl   $0xc010632e,(%esp)
c0101955:	e8 81 f3 ff ff       	call   c0100cdb <__panic>

c010195a <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c010195a:	55                   	push   %ebp
c010195b:	89 e5                	mov    %esp,%ebp
c010195d:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c0101960:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101967:	e9 c4 00 00 00       	jmp    c0101a30 <idt_init+0xd6>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c010196c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010196f:	8b 04 85 e0 85 11 c0 	mov    -0x3fee7a20(,%eax,4),%eax
c0101976:	0f b7 d0             	movzwl %ax,%edx
c0101979:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010197c:	66 89 14 c5 80 b6 11 	mov    %dx,-0x3fee4980(,%eax,8)
c0101983:	c0 
c0101984:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101987:	66 c7 04 c5 82 b6 11 	movw   $0x8,-0x3fee497e(,%eax,8)
c010198e:	c0 08 00 
c0101991:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101994:	0f b6 14 c5 84 b6 11 	movzbl -0x3fee497c(,%eax,8),%edx
c010199b:	c0 
c010199c:	80 e2 e0             	and    $0xe0,%dl
c010199f:	88 14 c5 84 b6 11 c0 	mov    %dl,-0x3fee497c(,%eax,8)
c01019a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019a9:	0f b6 14 c5 84 b6 11 	movzbl -0x3fee497c(,%eax,8),%edx
c01019b0:	c0 
c01019b1:	80 e2 1f             	and    $0x1f,%dl
c01019b4:	88 14 c5 84 b6 11 c0 	mov    %dl,-0x3fee497c(,%eax,8)
c01019bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019be:	0f b6 14 c5 85 b6 11 	movzbl -0x3fee497b(,%eax,8),%edx
c01019c5:	c0 
c01019c6:	80 e2 f0             	and    $0xf0,%dl
c01019c9:	80 ca 0e             	or     $0xe,%dl
c01019cc:	88 14 c5 85 b6 11 c0 	mov    %dl,-0x3fee497b(,%eax,8)
c01019d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019d6:	0f b6 14 c5 85 b6 11 	movzbl -0x3fee497b(,%eax,8),%edx
c01019dd:	c0 
c01019de:	80 e2 ef             	and    $0xef,%dl
c01019e1:	88 14 c5 85 b6 11 c0 	mov    %dl,-0x3fee497b(,%eax,8)
c01019e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019eb:	0f b6 14 c5 85 b6 11 	movzbl -0x3fee497b(,%eax,8),%edx
c01019f2:	c0 
c01019f3:	80 e2 9f             	and    $0x9f,%dl
c01019f6:	88 14 c5 85 b6 11 c0 	mov    %dl,-0x3fee497b(,%eax,8)
c01019fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a00:	0f b6 14 c5 85 b6 11 	movzbl -0x3fee497b(,%eax,8),%edx
c0101a07:	c0 
c0101a08:	80 ca 80             	or     $0x80,%dl
c0101a0b:	88 14 c5 85 b6 11 c0 	mov    %dl,-0x3fee497b(,%eax,8)
c0101a12:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a15:	8b 04 85 e0 85 11 c0 	mov    -0x3fee7a20(,%eax,4),%eax
c0101a1c:	c1 e8 10             	shr    $0x10,%eax
c0101a1f:	0f b7 d0             	movzwl %ax,%edx
c0101a22:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a25:	66 89 14 c5 86 b6 11 	mov    %dx,-0x3fee497a(,%eax,8)
c0101a2c:	c0 
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c0101a2d:	ff 45 fc             	incl   -0x4(%ebp)
c0101a30:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a33:	3d ff 00 00 00       	cmp    $0xff,%eax
c0101a38:	0f 86 2e ff ff ff    	jbe    c010196c <idt_init+0x12>
c0101a3e:	c7 45 f8 60 85 11 c0 	movl   $0xc0118560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0101a45:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0101a48:	0f 01 18             	lidtl  (%eax)
}
c0101a4b:	90                   	nop
    }
    lidt(&idt_pd);
}
c0101a4c:	90                   	nop
c0101a4d:	89 ec                	mov    %ebp,%esp
c0101a4f:	5d                   	pop    %ebp
c0101a50:	c3                   	ret    

c0101a51 <trapname>:

static const char *
trapname(int trapno) {
c0101a51:	55                   	push   %ebp
c0101a52:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c0101a54:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a57:	83 f8 13             	cmp    $0x13,%eax
c0101a5a:	77 0c                	ja     c0101a68 <trapname+0x17>
        return excnames[trapno];
c0101a5c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a5f:	8b 04 85 80 66 10 c0 	mov    -0x3fef9980(,%eax,4),%eax
c0101a66:	eb 18                	jmp    c0101a80 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c0101a68:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0101a6c:	7e 0d                	jle    c0101a7b <trapname+0x2a>
c0101a6e:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0101a72:	7f 07                	jg     c0101a7b <trapname+0x2a>
        return "Hardware Interrupt";
c0101a74:	b8 3f 63 10 c0       	mov    $0xc010633f,%eax
c0101a79:	eb 05                	jmp    c0101a80 <trapname+0x2f>
    }
    return "(unknown trap)";
c0101a7b:	b8 52 63 10 c0       	mov    $0xc0106352,%eax
}
c0101a80:	5d                   	pop    %ebp
c0101a81:	c3                   	ret    

c0101a82 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c0101a82:	55                   	push   %ebp
c0101a83:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c0101a85:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a88:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101a8c:	83 f8 08             	cmp    $0x8,%eax
c0101a8f:	0f 94 c0             	sete   %al
c0101a92:	0f b6 c0             	movzbl %al,%eax
}
c0101a95:	5d                   	pop    %ebp
c0101a96:	c3                   	ret    

c0101a97 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0101a97:	55                   	push   %ebp
c0101a98:	89 e5                	mov    %esp,%ebp
c0101a9a:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c0101a9d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aa0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101aa4:	c7 04 24 93 63 10 c0 	movl   $0xc0106393,(%esp)
c0101aab:	e8 a6 e8 ff ff       	call   c0100356 <cprintf>
    print_regs(&tf->tf_regs);
c0101ab0:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ab3:	89 04 24             	mov    %eax,(%esp)
c0101ab6:	e8 8f 01 00 00       	call   c0101c4a <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0101abb:	8b 45 08             	mov    0x8(%ebp),%eax
c0101abe:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0101ac2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ac6:	c7 04 24 a4 63 10 c0 	movl   $0xc01063a4,(%esp)
c0101acd:	e8 84 e8 ff ff       	call   c0100356 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0101ad2:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ad5:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101ad9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101add:	c7 04 24 b7 63 10 c0 	movl   $0xc01063b7,(%esp)
c0101ae4:	e8 6d e8 ff ff       	call   c0100356 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0101ae9:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aec:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0101af0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101af4:	c7 04 24 ca 63 10 c0 	movl   $0xc01063ca,(%esp)
c0101afb:	e8 56 e8 ff ff       	call   c0100356 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0101b00:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b03:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0101b07:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b0b:	c7 04 24 dd 63 10 c0 	movl   $0xc01063dd,(%esp)
c0101b12:	e8 3f e8 ff ff       	call   c0100356 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0101b17:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b1a:	8b 40 30             	mov    0x30(%eax),%eax
c0101b1d:	89 04 24             	mov    %eax,(%esp)
c0101b20:	e8 2c ff ff ff       	call   c0101a51 <trapname>
c0101b25:	8b 55 08             	mov    0x8(%ebp),%edx
c0101b28:	8b 52 30             	mov    0x30(%edx),%edx
c0101b2b:	89 44 24 08          	mov    %eax,0x8(%esp)
c0101b2f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101b33:	c7 04 24 f0 63 10 c0 	movl   $0xc01063f0,(%esp)
c0101b3a:	e8 17 e8 ff ff       	call   c0100356 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0101b3f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b42:	8b 40 34             	mov    0x34(%eax),%eax
c0101b45:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b49:	c7 04 24 02 64 10 c0 	movl   $0xc0106402,(%esp)
c0101b50:	e8 01 e8 ff ff       	call   c0100356 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0101b55:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b58:	8b 40 38             	mov    0x38(%eax),%eax
c0101b5b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b5f:	c7 04 24 11 64 10 c0 	movl   $0xc0106411,(%esp)
c0101b66:	e8 eb e7 ff ff       	call   c0100356 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0101b6b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b6e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101b72:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b76:	c7 04 24 20 64 10 c0 	movl   $0xc0106420,(%esp)
c0101b7d:	e8 d4 e7 ff ff       	call   c0100356 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0101b82:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b85:	8b 40 40             	mov    0x40(%eax),%eax
c0101b88:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b8c:	c7 04 24 33 64 10 c0 	movl   $0xc0106433,(%esp)
c0101b93:	e8 be e7 ff ff       	call   c0100356 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101b98:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101b9f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0101ba6:	eb 3d                	jmp    c0101be5 <print_trapframe+0x14e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0101ba8:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bab:	8b 50 40             	mov    0x40(%eax),%edx
c0101bae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101bb1:	21 d0                	and    %edx,%eax
c0101bb3:	85 c0                	test   %eax,%eax
c0101bb5:	74 28                	je     c0101bdf <print_trapframe+0x148>
c0101bb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101bba:	8b 04 85 80 85 11 c0 	mov    -0x3fee7a80(,%eax,4),%eax
c0101bc1:	85 c0                	test   %eax,%eax
c0101bc3:	74 1a                	je     c0101bdf <print_trapframe+0x148>
            cprintf("%s,", IA32flags[i]);
c0101bc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101bc8:	8b 04 85 80 85 11 c0 	mov    -0x3fee7a80(,%eax,4),%eax
c0101bcf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bd3:	c7 04 24 42 64 10 c0 	movl   $0xc0106442,(%esp)
c0101bda:	e8 77 e7 ff ff       	call   c0100356 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101bdf:	ff 45 f4             	incl   -0xc(%ebp)
c0101be2:	d1 65 f0             	shll   -0x10(%ebp)
c0101be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101be8:	83 f8 17             	cmp    $0x17,%eax
c0101beb:	76 bb                	jbe    c0101ba8 <print_trapframe+0x111>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0101bed:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bf0:	8b 40 40             	mov    0x40(%eax),%eax
c0101bf3:	c1 e8 0c             	shr    $0xc,%eax
c0101bf6:	83 e0 03             	and    $0x3,%eax
c0101bf9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bfd:	c7 04 24 46 64 10 c0 	movl   $0xc0106446,(%esp)
c0101c04:	e8 4d e7 ff ff       	call   c0100356 <cprintf>

    if (!trap_in_kernel(tf)) {
c0101c09:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c0c:	89 04 24             	mov    %eax,(%esp)
c0101c0f:	e8 6e fe ff ff       	call   c0101a82 <trap_in_kernel>
c0101c14:	85 c0                	test   %eax,%eax
c0101c16:	75 2d                	jne    c0101c45 <print_trapframe+0x1ae>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0101c18:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c1b:	8b 40 44             	mov    0x44(%eax),%eax
c0101c1e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c22:	c7 04 24 4f 64 10 c0 	movl   $0xc010644f,(%esp)
c0101c29:	e8 28 e7 ff ff       	call   c0100356 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0101c2e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c31:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0101c35:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c39:	c7 04 24 5e 64 10 c0 	movl   $0xc010645e,(%esp)
c0101c40:	e8 11 e7 ff ff       	call   c0100356 <cprintf>
    }
}
c0101c45:	90                   	nop
c0101c46:	89 ec                	mov    %ebp,%esp
c0101c48:	5d                   	pop    %ebp
c0101c49:	c3                   	ret    

c0101c4a <print_regs>:

void
print_regs(struct pushregs *regs) {
c0101c4a:	55                   	push   %ebp
c0101c4b:	89 e5                	mov    %esp,%ebp
c0101c4d:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0101c50:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c53:	8b 00                	mov    (%eax),%eax
c0101c55:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c59:	c7 04 24 71 64 10 c0 	movl   $0xc0106471,(%esp)
c0101c60:	e8 f1 e6 ff ff       	call   c0100356 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0101c65:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c68:	8b 40 04             	mov    0x4(%eax),%eax
c0101c6b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c6f:	c7 04 24 80 64 10 c0 	movl   $0xc0106480,(%esp)
c0101c76:	e8 db e6 ff ff       	call   c0100356 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0101c7b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c7e:	8b 40 08             	mov    0x8(%eax),%eax
c0101c81:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c85:	c7 04 24 8f 64 10 c0 	movl   $0xc010648f,(%esp)
c0101c8c:	e8 c5 e6 ff ff       	call   c0100356 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0101c91:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c94:	8b 40 0c             	mov    0xc(%eax),%eax
c0101c97:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c9b:	c7 04 24 9e 64 10 c0 	movl   $0xc010649e,(%esp)
c0101ca2:	e8 af e6 ff ff       	call   c0100356 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0101ca7:	8b 45 08             	mov    0x8(%ebp),%eax
c0101caa:	8b 40 10             	mov    0x10(%eax),%eax
c0101cad:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cb1:	c7 04 24 ad 64 10 c0 	movl   $0xc01064ad,(%esp)
c0101cb8:	e8 99 e6 ff ff       	call   c0100356 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0101cbd:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cc0:	8b 40 14             	mov    0x14(%eax),%eax
c0101cc3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cc7:	c7 04 24 bc 64 10 c0 	movl   $0xc01064bc,(%esp)
c0101cce:	e8 83 e6 ff ff       	call   c0100356 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0101cd3:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cd6:	8b 40 18             	mov    0x18(%eax),%eax
c0101cd9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cdd:	c7 04 24 cb 64 10 c0 	movl   $0xc01064cb,(%esp)
c0101ce4:	e8 6d e6 ff ff       	call   c0100356 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0101ce9:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cec:	8b 40 1c             	mov    0x1c(%eax),%eax
c0101cef:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cf3:	c7 04 24 da 64 10 c0 	movl   $0xc01064da,(%esp)
c0101cfa:	e8 57 e6 ff ff       	call   c0100356 <cprintf>
}
c0101cff:	90                   	nop
c0101d00:	89 ec                	mov    %ebp,%esp
c0101d02:	5d                   	pop    %ebp
c0101d03:	c3                   	ret    

c0101d04 <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
c0101d04:	55                   	push   %ebp
c0101d05:	89 e5                	mov    %esp,%ebp
c0101d07:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
c0101d0a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d0d:	8b 40 30             	mov    0x30(%eax),%eax
c0101d10:	83 f8 79             	cmp    $0x79,%eax
c0101d13:	0f 87 e6 00 00 00    	ja     c0101dff <trap_dispatch+0xfb>
c0101d19:	83 f8 78             	cmp    $0x78,%eax
c0101d1c:	0f 83 c1 00 00 00    	jae    c0101de3 <trap_dispatch+0xdf>
c0101d22:	83 f8 2f             	cmp    $0x2f,%eax
c0101d25:	0f 87 d4 00 00 00    	ja     c0101dff <trap_dispatch+0xfb>
c0101d2b:	83 f8 2e             	cmp    $0x2e,%eax
c0101d2e:	0f 83 00 01 00 00    	jae    c0101e34 <trap_dispatch+0x130>
c0101d34:	83 f8 24             	cmp    $0x24,%eax
c0101d37:	74 5e                	je     c0101d97 <trap_dispatch+0x93>
c0101d39:	83 f8 24             	cmp    $0x24,%eax
c0101d3c:	0f 87 bd 00 00 00    	ja     c0101dff <trap_dispatch+0xfb>
c0101d42:	83 f8 20             	cmp    $0x20,%eax
c0101d45:	74 0a                	je     c0101d51 <trap_dispatch+0x4d>
c0101d47:	83 f8 21             	cmp    $0x21,%eax
c0101d4a:	74 71                	je     c0101dbd <trap_dispatch+0xb9>
c0101d4c:	e9 ae 00 00 00       	jmp    c0101dff <trap_dispatch+0xfb>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
c0101d51:	a1 24 b4 11 c0       	mov    0xc011b424,%eax
c0101d56:	40                   	inc    %eax
c0101d57:	a3 24 b4 11 c0       	mov    %eax,0xc011b424
        if (ticks % TICK_NUM == 0) {
c0101d5c:	8b 0d 24 b4 11 c0    	mov    0xc011b424,%ecx
c0101d62:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0101d67:	89 c8                	mov    %ecx,%eax
c0101d69:	f7 e2                	mul    %edx
c0101d6b:	c1 ea 05             	shr    $0x5,%edx
c0101d6e:	89 d0                	mov    %edx,%eax
c0101d70:	c1 e0 02             	shl    $0x2,%eax
c0101d73:	01 d0                	add    %edx,%eax
c0101d75:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101d7c:	01 d0                	add    %edx,%eax
c0101d7e:	c1 e0 02             	shl    $0x2,%eax
c0101d81:	29 c1                	sub    %eax,%ecx
c0101d83:	89 ca                	mov    %ecx,%edx
c0101d85:	85 d2                	test   %edx,%edx
c0101d87:	0f 85 aa 00 00 00    	jne    c0101e37 <trap_dispatch+0x133>
            print_ticks();
c0101d8d:	e8 86 fb ff ff       	call   c0101918 <print_ticks>
        }
        break;
c0101d92:	e9 a0 00 00 00       	jmp    c0101e37 <trap_dispatch+0x133>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0101d97:	e8 1f f9 ff ff       	call   c01016bb <cons_getc>
c0101d9c:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0101d9f:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101da3:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101da7:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101dab:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101daf:	c7 04 24 e9 64 10 c0 	movl   $0xc01064e9,(%esp)
c0101db6:	e8 9b e5 ff ff       	call   c0100356 <cprintf>
        break;
c0101dbb:	eb 7b                	jmp    c0101e38 <trap_dispatch+0x134>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0101dbd:	e8 f9 f8 ff ff       	call   c01016bb <cons_getc>
c0101dc2:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0101dc5:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101dc9:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101dcd:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101dd1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101dd5:	c7 04 24 fb 64 10 c0 	movl   $0xc01064fb,(%esp)
c0101ddc:	e8 75 e5 ff ff       	call   c0100356 <cprintf>
        break;
c0101de1:	eb 55                	jmp    c0101e38 <trap_dispatch+0x134>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0101de3:	c7 44 24 08 0a 65 10 	movl   $0xc010650a,0x8(%esp)
c0101dea:	c0 
c0101deb:	c7 44 24 04 ac 00 00 	movl   $0xac,0x4(%esp)
c0101df2:	00 
c0101df3:	c7 04 24 2e 63 10 c0 	movl   $0xc010632e,(%esp)
c0101dfa:	e8 dc ee ff ff       	call   c0100cdb <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0101dff:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e02:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101e06:	83 e0 03             	and    $0x3,%eax
c0101e09:	85 c0                	test   %eax,%eax
c0101e0b:	75 2b                	jne    c0101e38 <trap_dispatch+0x134>
            print_trapframe(tf);
c0101e0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e10:	89 04 24             	mov    %eax,(%esp)
c0101e13:	e8 7f fc ff ff       	call   c0101a97 <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0101e18:	c7 44 24 08 1a 65 10 	movl   $0xc010651a,0x8(%esp)
c0101e1f:	c0 
c0101e20:	c7 44 24 04 b6 00 00 	movl   $0xb6,0x4(%esp)
c0101e27:	00 
c0101e28:	c7 04 24 2e 63 10 c0 	movl   $0xc010632e,(%esp)
c0101e2f:	e8 a7 ee ff ff       	call   c0100cdb <__panic>
        break;
c0101e34:	90                   	nop
c0101e35:	eb 01                	jmp    c0101e38 <trap_dispatch+0x134>
        break;
c0101e37:	90                   	nop
        }
    }
}
c0101e38:	90                   	nop
c0101e39:	89 ec                	mov    %ebp,%esp
c0101e3b:	5d                   	pop    %ebp
c0101e3c:	c3                   	ret    

c0101e3d <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0101e3d:	55                   	push   %ebp
c0101e3e:	89 e5                	mov    %esp,%ebp
c0101e40:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0101e43:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e46:	89 04 24             	mov    %eax,(%esp)
c0101e49:	e8 b6 fe ff ff       	call   c0101d04 <trap_dispatch>
}
c0101e4e:	90                   	nop
c0101e4f:	89 ec                	mov    %ebp,%esp
c0101e51:	5d                   	pop    %ebp
c0101e52:	c3                   	ret    

c0101e53 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0101e53:	1e                   	push   %ds
    pushl %es
c0101e54:	06                   	push   %es
    pushl %fs
c0101e55:	0f a0                	push   %fs
    pushl %gs
c0101e57:	0f a8                	push   %gs
    pushal
c0101e59:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0101e5a:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0101e5f:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0101e61:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0101e63:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0101e64:	e8 d4 ff ff ff       	call   c0101e3d <trap>

    # pop the pushed stack pointer
    popl %esp
c0101e69:	5c                   	pop    %esp

c0101e6a <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0101e6a:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0101e6b:	0f a9                	pop    %gs
    popl %fs
c0101e6d:	0f a1                	pop    %fs
    popl %es
c0101e6f:	07                   	pop    %es
    popl %ds
c0101e70:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0101e71:	83 c4 08             	add    $0x8,%esp
    iret
c0101e74:	cf                   	iret   

c0101e75 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0101e75:	6a 00                	push   $0x0
  pushl $0
c0101e77:	6a 00                	push   $0x0
  jmp __alltraps
c0101e79:	e9 d5 ff ff ff       	jmp    c0101e53 <__alltraps>

c0101e7e <vector1>:
.globl vector1
vector1:
  pushl $0
c0101e7e:	6a 00                	push   $0x0
  pushl $1
c0101e80:	6a 01                	push   $0x1
  jmp __alltraps
c0101e82:	e9 cc ff ff ff       	jmp    c0101e53 <__alltraps>

c0101e87 <vector2>:
.globl vector2
vector2:
  pushl $0
c0101e87:	6a 00                	push   $0x0
  pushl $2
c0101e89:	6a 02                	push   $0x2
  jmp __alltraps
c0101e8b:	e9 c3 ff ff ff       	jmp    c0101e53 <__alltraps>

c0101e90 <vector3>:
.globl vector3
vector3:
  pushl $0
c0101e90:	6a 00                	push   $0x0
  pushl $3
c0101e92:	6a 03                	push   $0x3
  jmp __alltraps
c0101e94:	e9 ba ff ff ff       	jmp    c0101e53 <__alltraps>

c0101e99 <vector4>:
.globl vector4
vector4:
  pushl $0
c0101e99:	6a 00                	push   $0x0
  pushl $4
c0101e9b:	6a 04                	push   $0x4
  jmp __alltraps
c0101e9d:	e9 b1 ff ff ff       	jmp    c0101e53 <__alltraps>

c0101ea2 <vector5>:
.globl vector5
vector5:
  pushl $0
c0101ea2:	6a 00                	push   $0x0
  pushl $5
c0101ea4:	6a 05                	push   $0x5
  jmp __alltraps
c0101ea6:	e9 a8 ff ff ff       	jmp    c0101e53 <__alltraps>

c0101eab <vector6>:
.globl vector6
vector6:
  pushl $0
c0101eab:	6a 00                	push   $0x0
  pushl $6
c0101ead:	6a 06                	push   $0x6
  jmp __alltraps
c0101eaf:	e9 9f ff ff ff       	jmp    c0101e53 <__alltraps>

c0101eb4 <vector7>:
.globl vector7
vector7:
  pushl $0
c0101eb4:	6a 00                	push   $0x0
  pushl $7
c0101eb6:	6a 07                	push   $0x7
  jmp __alltraps
c0101eb8:	e9 96 ff ff ff       	jmp    c0101e53 <__alltraps>

c0101ebd <vector8>:
.globl vector8
vector8:
  pushl $8
c0101ebd:	6a 08                	push   $0x8
  jmp __alltraps
c0101ebf:	e9 8f ff ff ff       	jmp    c0101e53 <__alltraps>

c0101ec4 <vector9>:
.globl vector9
vector9:
  pushl $0
c0101ec4:	6a 00                	push   $0x0
  pushl $9
c0101ec6:	6a 09                	push   $0x9
  jmp __alltraps
c0101ec8:	e9 86 ff ff ff       	jmp    c0101e53 <__alltraps>

c0101ecd <vector10>:
.globl vector10
vector10:
  pushl $10
c0101ecd:	6a 0a                	push   $0xa
  jmp __alltraps
c0101ecf:	e9 7f ff ff ff       	jmp    c0101e53 <__alltraps>

c0101ed4 <vector11>:
.globl vector11
vector11:
  pushl $11
c0101ed4:	6a 0b                	push   $0xb
  jmp __alltraps
c0101ed6:	e9 78 ff ff ff       	jmp    c0101e53 <__alltraps>

c0101edb <vector12>:
.globl vector12
vector12:
  pushl $12
c0101edb:	6a 0c                	push   $0xc
  jmp __alltraps
c0101edd:	e9 71 ff ff ff       	jmp    c0101e53 <__alltraps>

c0101ee2 <vector13>:
.globl vector13
vector13:
  pushl $13
c0101ee2:	6a 0d                	push   $0xd
  jmp __alltraps
c0101ee4:	e9 6a ff ff ff       	jmp    c0101e53 <__alltraps>

c0101ee9 <vector14>:
.globl vector14
vector14:
  pushl $14
c0101ee9:	6a 0e                	push   $0xe
  jmp __alltraps
c0101eeb:	e9 63 ff ff ff       	jmp    c0101e53 <__alltraps>

c0101ef0 <vector15>:
.globl vector15
vector15:
  pushl $0
c0101ef0:	6a 00                	push   $0x0
  pushl $15
c0101ef2:	6a 0f                	push   $0xf
  jmp __alltraps
c0101ef4:	e9 5a ff ff ff       	jmp    c0101e53 <__alltraps>

c0101ef9 <vector16>:
.globl vector16
vector16:
  pushl $0
c0101ef9:	6a 00                	push   $0x0
  pushl $16
c0101efb:	6a 10                	push   $0x10
  jmp __alltraps
c0101efd:	e9 51 ff ff ff       	jmp    c0101e53 <__alltraps>

c0101f02 <vector17>:
.globl vector17
vector17:
  pushl $17
c0101f02:	6a 11                	push   $0x11
  jmp __alltraps
c0101f04:	e9 4a ff ff ff       	jmp    c0101e53 <__alltraps>

c0101f09 <vector18>:
.globl vector18
vector18:
  pushl $0
c0101f09:	6a 00                	push   $0x0
  pushl $18
c0101f0b:	6a 12                	push   $0x12
  jmp __alltraps
c0101f0d:	e9 41 ff ff ff       	jmp    c0101e53 <__alltraps>

c0101f12 <vector19>:
.globl vector19
vector19:
  pushl $0
c0101f12:	6a 00                	push   $0x0
  pushl $19
c0101f14:	6a 13                	push   $0x13
  jmp __alltraps
c0101f16:	e9 38 ff ff ff       	jmp    c0101e53 <__alltraps>

c0101f1b <vector20>:
.globl vector20
vector20:
  pushl $0
c0101f1b:	6a 00                	push   $0x0
  pushl $20
c0101f1d:	6a 14                	push   $0x14
  jmp __alltraps
c0101f1f:	e9 2f ff ff ff       	jmp    c0101e53 <__alltraps>

c0101f24 <vector21>:
.globl vector21
vector21:
  pushl $0
c0101f24:	6a 00                	push   $0x0
  pushl $21
c0101f26:	6a 15                	push   $0x15
  jmp __alltraps
c0101f28:	e9 26 ff ff ff       	jmp    c0101e53 <__alltraps>

c0101f2d <vector22>:
.globl vector22
vector22:
  pushl $0
c0101f2d:	6a 00                	push   $0x0
  pushl $22
c0101f2f:	6a 16                	push   $0x16
  jmp __alltraps
c0101f31:	e9 1d ff ff ff       	jmp    c0101e53 <__alltraps>

c0101f36 <vector23>:
.globl vector23
vector23:
  pushl $0
c0101f36:	6a 00                	push   $0x0
  pushl $23
c0101f38:	6a 17                	push   $0x17
  jmp __alltraps
c0101f3a:	e9 14 ff ff ff       	jmp    c0101e53 <__alltraps>

c0101f3f <vector24>:
.globl vector24
vector24:
  pushl $0
c0101f3f:	6a 00                	push   $0x0
  pushl $24
c0101f41:	6a 18                	push   $0x18
  jmp __alltraps
c0101f43:	e9 0b ff ff ff       	jmp    c0101e53 <__alltraps>

c0101f48 <vector25>:
.globl vector25
vector25:
  pushl $0
c0101f48:	6a 00                	push   $0x0
  pushl $25
c0101f4a:	6a 19                	push   $0x19
  jmp __alltraps
c0101f4c:	e9 02 ff ff ff       	jmp    c0101e53 <__alltraps>

c0101f51 <vector26>:
.globl vector26
vector26:
  pushl $0
c0101f51:	6a 00                	push   $0x0
  pushl $26
c0101f53:	6a 1a                	push   $0x1a
  jmp __alltraps
c0101f55:	e9 f9 fe ff ff       	jmp    c0101e53 <__alltraps>

c0101f5a <vector27>:
.globl vector27
vector27:
  pushl $0
c0101f5a:	6a 00                	push   $0x0
  pushl $27
c0101f5c:	6a 1b                	push   $0x1b
  jmp __alltraps
c0101f5e:	e9 f0 fe ff ff       	jmp    c0101e53 <__alltraps>

c0101f63 <vector28>:
.globl vector28
vector28:
  pushl $0
c0101f63:	6a 00                	push   $0x0
  pushl $28
c0101f65:	6a 1c                	push   $0x1c
  jmp __alltraps
c0101f67:	e9 e7 fe ff ff       	jmp    c0101e53 <__alltraps>

c0101f6c <vector29>:
.globl vector29
vector29:
  pushl $0
c0101f6c:	6a 00                	push   $0x0
  pushl $29
c0101f6e:	6a 1d                	push   $0x1d
  jmp __alltraps
c0101f70:	e9 de fe ff ff       	jmp    c0101e53 <__alltraps>

c0101f75 <vector30>:
.globl vector30
vector30:
  pushl $0
c0101f75:	6a 00                	push   $0x0
  pushl $30
c0101f77:	6a 1e                	push   $0x1e
  jmp __alltraps
c0101f79:	e9 d5 fe ff ff       	jmp    c0101e53 <__alltraps>

c0101f7e <vector31>:
.globl vector31
vector31:
  pushl $0
c0101f7e:	6a 00                	push   $0x0
  pushl $31
c0101f80:	6a 1f                	push   $0x1f
  jmp __alltraps
c0101f82:	e9 cc fe ff ff       	jmp    c0101e53 <__alltraps>

c0101f87 <vector32>:
.globl vector32
vector32:
  pushl $0
c0101f87:	6a 00                	push   $0x0
  pushl $32
c0101f89:	6a 20                	push   $0x20
  jmp __alltraps
c0101f8b:	e9 c3 fe ff ff       	jmp    c0101e53 <__alltraps>

c0101f90 <vector33>:
.globl vector33
vector33:
  pushl $0
c0101f90:	6a 00                	push   $0x0
  pushl $33
c0101f92:	6a 21                	push   $0x21
  jmp __alltraps
c0101f94:	e9 ba fe ff ff       	jmp    c0101e53 <__alltraps>

c0101f99 <vector34>:
.globl vector34
vector34:
  pushl $0
c0101f99:	6a 00                	push   $0x0
  pushl $34
c0101f9b:	6a 22                	push   $0x22
  jmp __alltraps
c0101f9d:	e9 b1 fe ff ff       	jmp    c0101e53 <__alltraps>

c0101fa2 <vector35>:
.globl vector35
vector35:
  pushl $0
c0101fa2:	6a 00                	push   $0x0
  pushl $35
c0101fa4:	6a 23                	push   $0x23
  jmp __alltraps
c0101fa6:	e9 a8 fe ff ff       	jmp    c0101e53 <__alltraps>

c0101fab <vector36>:
.globl vector36
vector36:
  pushl $0
c0101fab:	6a 00                	push   $0x0
  pushl $36
c0101fad:	6a 24                	push   $0x24
  jmp __alltraps
c0101faf:	e9 9f fe ff ff       	jmp    c0101e53 <__alltraps>

c0101fb4 <vector37>:
.globl vector37
vector37:
  pushl $0
c0101fb4:	6a 00                	push   $0x0
  pushl $37
c0101fb6:	6a 25                	push   $0x25
  jmp __alltraps
c0101fb8:	e9 96 fe ff ff       	jmp    c0101e53 <__alltraps>

c0101fbd <vector38>:
.globl vector38
vector38:
  pushl $0
c0101fbd:	6a 00                	push   $0x0
  pushl $38
c0101fbf:	6a 26                	push   $0x26
  jmp __alltraps
c0101fc1:	e9 8d fe ff ff       	jmp    c0101e53 <__alltraps>

c0101fc6 <vector39>:
.globl vector39
vector39:
  pushl $0
c0101fc6:	6a 00                	push   $0x0
  pushl $39
c0101fc8:	6a 27                	push   $0x27
  jmp __alltraps
c0101fca:	e9 84 fe ff ff       	jmp    c0101e53 <__alltraps>

c0101fcf <vector40>:
.globl vector40
vector40:
  pushl $0
c0101fcf:	6a 00                	push   $0x0
  pushl $40
c0101fd1:	6a 28                	push   $0x28
  jmp __alltraps
c0101fd3:	e9 7b fe ff ff       	jmp    c0101e53 <__alltraps>

c0101fd8 <vector41>:
.globl vector41
vector41:
  pushl $0
c0101fd8:	6a 00                	push   $0x0
  pushl $41
c0101fda:	6a 29                	push   $0x29
  jmp __alltraps
c0101fdc:	e9 72 fe ff ff       	jmp    c0101e53 <__alltraps>

c0101fe1 <vector42>:
.globl vector42
vector42:
  pushl $0
c0101fe1:	6a 00                	push   $0x0
  pushl $42
c0101fe3:	6a 2a                	push   $0x2a
  jmp __alltraps
c0101fe5:	e9 69 fe ff ff       	jmp    c0101e53 <__alltraps>

c0101fea <vector43>:
.globl vector43
vector43:
  pushl $0
c0101fea:	6a 00                	push   $0x0
  pushl $43
c0101fec:	6a 2b                	push   $0x2b
  jmp __alltraps
c0101fee:	e9 60 fe ff ff       	jmp    c0101e53 <__alltraps>

c0101ff3 <vector44>:
.globl vector44
vector44:
  pushl $0
c0101ff3:	6a 00                	push   $0x0
  pushl $44
c0101ff5:	6a 2c                	push   $0x2c
  jmp __alltraps
c0101ff7:	e9 57 fe ff ff       	jmp    c0101e53 <__alltraps>

c0101ffc <vector45>:
.globl vector45
vector45:
  pushl $0
c0101ffc:	6a 00                	push   $0x0
  pushl $45
c0101ffe:	6a 2d                	push   $0x2d
  jmp __alltraps
c0102000:	e9 4e fe ff ff       	jmp    c0101e53 <__alltraps>

c0102005 <vector46>:
.globl vector46
vector46:
  pushl $0
c0102005:	6a 00                	push   $0x0
  pushl $46
c0102007:	6a 2e                	push   $0x2e
  jmp __alltraps
c0102009:	e9 45 fe ff ff       	jmp    c0101e53 <__alltraps>

c010200e <vector47>:
.globl vector47
vector47:
  pushl $0
c010200e:	6a 00                	push   $0x0
  pushl $47
c0102010:	6a 2f                	push   $0x2f
  jmp __alltraps
c0102012:	e9 3c fe ff ff       	jmp    c0101e53 <__alltraps>

c0102017 <vector48>:
.globl vector48
vector48:
  pushl $0
c0102017:	6a 00                	push   $0x0
  pushl $48
c0102019:	6a 30                	push   $0x30
  jmp __alltraps
c010201b:	e9 33 fe ff ff       	jmp    c0101e53 <__alltraps>

c0102020 <vector49>:
.globl vector49
vector49:
  pushl $0
c0102020:	6a 00                	push   $0x0
  pushl $49
c0102022:	6a 31                	push   $0x31
  jmp __alltraps
c0102024:	e9 2a fe ff ff       	jmp    c0101e53 <__alltraps>

c0102029 <vector50>:
.globl vector50
vector50:
  pushl $0
c0102029:	6a 00                	push   $0x0
  pushl $50
c010202b:	6a 32                	push   $0x32
  jmp __alltraps
c010202d:	e9 21 fe ff ff       	jmp    c0101e53 <__alltraps>

c0102032 <vector51>:
.globl vector51
vector51:
  pushl $0
c0102032:	6a 00                	push   $0x0
  pushl $51
c0102034:	6a 33                	push   $0x33
  jmp __alltraps
c0102036:	e9 18 fe ff ff       	jmp    c0101e53 <__alltraps>

c010203b <vector52>:
.globl vector52
vector52:
  pushl $0
c010203b:	6a 00                	push   $0x0
  pushl $52
c010203d:	6a 34                	push   $0x34
  jmp __alltraps
c010203f:	e9 0f fe ff ff       	jmp    c0101e53 <__alltraps>

c0102044 <vector53>:
.globl vector53
vector53:
  pushl $0
c0102044:	6a 00                	push   $0x0
  pushl $53
c0102046:	6a 35                	push   $0x35
  jmp __alltraps
c0102048:	e9 06 fe ff ff       	jmp    c0101e53 <__alltraps>

c010204d <vector54>:
.globl vector54
vector54:
  pushl $0
c010204d:	6a 00                	push   $0x0
  pushl $54
c010204f:	6a 36                	push   $0x36
  jmp __alltraps
c0102051:	e9 fd fd ff ff       	jmp    c0101e53 <__alltraps>

c0102056 <vector55>:
.globl vector55
vector55:
  pushl $0
c0102056:	6a 00                	push   $0x0
  pushl $55
c0102058:	6a 37                	push   $0x37
  jmp __alltraps
c010205a:	e9 f4 fd ff ff       	jmp    c0101e53 <__alltraps>

c010205f <vector56>:
.globl vector56
vector56:
  pushl $0
c010205f:	6a 00                	push   $0x0
  pushl $56
c0102061:	6a 38                	push   $0x38
  jmp __alltraps
c0102063:	e9 eb fd ff ff       	jmp    c0101e53 <__alltraps>

c0102068 <vector57>:
.globl vector57
vector57:
  pushl $0
c0102068:	6a 00                	push   $0x0
  pushl $57
c010206a:	6a 39                	push   $0x39
  jmp __alltraps
c010206c:	e9 e2 fd ff ff       	jmp    c0101e53 <__alltraps>

c0102071 <vector58>:
.globl vector58
vector58:
  pushl $0
c0102071:	6a 00                	push   $0x0
  pushl $58
c0102073:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102075:	e9 d9 fd ff ff       	jmp    c0101e53 <__alltraps>

c010207a <vector59>:
.globl vector59
vector59:
  pushl $0
c010207a:	6a 00                	push   $0x0
  pushl $59
c010207c:	6a 3b                	push   $0x3b
  jmp __alltraps
c010207e:	e9 d0 fd ff ff       	jmp    c0101e53 <__alltraps>

c0102083 <vector60>:
.globl vector60
vector60:
  pushl $0
c0102083:	6a 00                	push   $0x0
  pushl $60
c0102085:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102087:	e9 c7 fd ff ff       	jmp    c0101e53 <__alltraps>

c010208c <vector61>:
.globl vector61
vector61:
  pushl $0
c010208c:	6a 00                	push   $0x0
  pushl $61
c010208e:	6a 3d                	push   $0x3d
  jmp __alltraps
c0102090:	e9 be fd ff ff       	jmp    c0101e53 <__alltraps>

c0102095 <vector62>:
.globl vector62
vector62:
  pushl $0
c0102095:	6a 00                	push   $0x0
  pushl $62
c0102097:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102099:	e9 b5 fd ff ff       	jmp    c0101e53 <__alltraps>

c010209e <vector63>:
.globl vector63
vector63:
  pushl $0
c010209e:	6a 00                	push   $0x0
  pushl $63
c01020a0:	6a 3f                	push   $0x3f
  jmp __alltraps
c01020a2:	e9 ac fd ff ff       	jmp    c0101e53 <__alltraps>

c01020a7 <vector64>:
.globl vector64
vector64:
  pushl $0
c01020a7:	6a 00                	push   $0x0
  pushl $64
c01020a9:	6a 40                	push   $0x40
  jmp __alltraps
c01020ab:	e9 a3 fd ff ff       	jmp    c0101e53 <__alltraps>

c01020b0 <vector65>:
.globl vector65
vector65:
  pushl $0
c01020b0:	6a 00                	push   $0x0
  pushl $65
c01020b2:	6a 41                	push   $0x41
  jmp __alltraps
c01020b4:	e9 9a fd ff ff       	jmp    c0101e53 <__alltraps>

c01020b9 <vector66>:
.globl vector66
vector66:
  pushl $0
c01020b9:	6a 00                	push   $0x0
  pushl $66
c01020bb:	6a 42                	push   $0x42
  jmp __alltraps
c01020bd:	e9 91 fd ff ff       	jmp    c0101e53 <__alltraps>

c01020c2 <vector67>:
.globl vector67
vector67:
  pushl $0
c01020c2:	6a 00                	push   $0x0
  pushl $67
c01020c4:	6a 43                	push   $0x43
  jmp __alltraps
c01020c6:	e9 88 fd ff ff       	jmp    c0101e53 <__alltraps>

c01020cb <vector68>:
.globl vector68
vector68:
  pushl $0
c01020cb:	6a 00                	push   $0x0
  pushl $68
c01020cd:	6a 44                	push   $0x44
  jmp __alltraps
c01020cf:	e9 7f fd ff ff       	jmp    c0101e53 <__alltraps>

c01020d4 <vector69>:
.globl vector69
vector69:
  pushl $0
c01020d4:	6a 00                	push   $0x0
  pushl $69
c01020d6:	6a 45                	push   $0x45
  jmp __alltraps
c01020d8:	e9 76 fd ff ff       	jmp    c0101e53 <__alltraps>

c01020dd <vector70>:
.globl vector70
vector70:
  pushl $0
c01020dd:	6a 00                	push   $0x0
  pushl $70
c01020df:	6a 46                	push   $0x46
  jmp __alltraps
c01020e1:	e9 6d fd ff ff       	jmp    c0101e53 <__alltraps>

c01020e6 <vector71>:
.globl vector71
vector71:
  pushl $0
c01020e6:	6a 00                	push   $0x0
  pushl $71
c01020e8:	6a 47                	push   $0x47
  jmp __alltraps
c01020ea:	e9 64 fd ff ff       	jmp    c0101e53 <__alltraps>

c01020ef <vector72>:
.globl vector72
vector72:
  pushl $0
c01020ef:	6a 00                	push   $0x0
  pushl $72
c01020f1:	6a 48                	push   $0x48
  jmp __alltraps
c01020f3:	e9 5b fd ff ff       	jmp    c0101e53 <__alltraps>

c01020f8 <vector73>:
.globl vector73
vector73:
  pushl $0
c01020f8:	6a 00                	push   $0x0
  pushl $73
c01020fa:	6a 49                	push   $0x49
  jmp __alltraps
c01020fc:	e9 52 fd ff ff       	jmp    c0101e53 <__alltraps>

c0102101 <vector74>:
.globl vector74
vector74:
  pushl $0
c0102101:	6a 00                	push   $0x0
  pushl $74
c0102103:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102105:	e9 49 fd ff ff       	jmp    c0101e53 <__alltraps>

c010210a <vector75>:
.globl vector75
vector75:
  pushl $0
c010210a:	6a 00                	push   $0x0
  pushl $75
c010210c:	6a 4b                	push   $0x4b
  jmp __alltraps
c010210e:	e9 40 fd ff ff       	jmp    c0101e53 <__alltraps>

c0102113 <vector76>:
.globl vector76
vector76:
  pushl $0
c0102113:	6a 00                	push   $0x0
  pushl $76
c0102115:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102117:	e9 37 fd ff ff       	jmp    c0101e53 <__alltraps>

c010211c <vector77>:
.globl vector77
vector77:
  pushl $0
c010211c:	6a 00                	push   $0x0
  pushl $77
c010211e:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102120:	e9 2e fd ff ff       	jmp    c0101e53 <__alltraps>

c0102125 <vector78>:
.globl vector78
vector78:
  pushl $0
c0102125:	6a 00                	push   $0x0
  pushl $78
c0102127:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102129:	e9 25 fd ff ff       	jmp    c0101e53 <__alltraps>

c010212e <vector79>:
.globl vector79
vector79:
  pushl $0
c010212e:	6a 00                	push   $0x0
  pushl $79
c0102130:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102132:	e9 1c fd ff ff       	jmp    c0101e53 <__alltraps>

c0102137 <vector80>:
.globl vector80
vector80:
  pushl $0
c0102137:	6a 00                	push   $0x0
  pushl $80
c0102139:	6a 50                	push   $0x50
  jmp __alltraps
c010213b:	e9 13 fd ff ff       	jmp    c0101e53 <__alltraps>

c0102140 <vector81>:
.globl vector81
vector81:
  pushl $0
c0102140:	6a 00                	push   $0x0
  pushl $81
c0102142:	6a 51                	push   $0x51
  jmp __alltraps
c0102144:	e9 0a fd ff ff       	jmp    c0101e53 <__alltraps>

c0102149 <vector82>:
.globl vector82
vector82:
  pushl $0
c0102149:	6a 00                	push   $0x0
  pushl $82
c010214b:	6a 52                	push   $0x52
  jmp __alltraps
c010214d:	e9 01 fd ff ff       	jmp    c0101e53 <__alltraps>

c0102152 <vector83>:
.globl vector83
vector83:
  pushl $0
c0102152:	6a 00                	push   $0x0
  pushl $83
c0102154:	6a 53                	push   $0x53
  jmp __alltraps
c0102156:	e9 f8 fc ff ff       	jmp    c0101e53 <__alltraps>

c010215b <vector84>:
.globl vector84
vector84:
  pushl $0
c010215b:	6a 00                	push   $0x0
  pushl $84
c010215d:	6a 54                	push   $0x54
  jmp __alltraps
c010215f:	e9 ef fc ff ff       	jmp    c0101e53 <__alltraps>

c0102164 <vector85>:
.globl vector85
vector85:
  pushl $0
c0102164:	6a 00                	push   $0x0
  pushl $85
c0102166:	6a 55                	push   $0x55
  jmp __alltraps
c0102168:	e9 e6 fc ff ff       	jmp    c0101e53 <__alltraps>

c010216d <vector86>:
.globl vector86
vector86:
  pushl $0
c010216d:	6a 00                	push   $0x0
  pushl $86
c010216f:	6a 56                	push   $0x56
  jmp __alltraps
c0102171:	e9 dd fc ff ff       	jmp    c0101e53 <__alltraps>

c0102176 <vector87>:
.globl vector87
vector87:
  pushl $0
c0102176:	6a 00                	push   $0x0
  pushl $87
c0102178:	6a 57                	push   $0x57
  jmp __alltraps
c010217a:	e9 d4 fc ff ff       	jmp    c0101e53 <__alltraps>

c010217f <vector88>:
.globl vector88
vector88:
  pushl $0
c010217f:	6a 00                	push   $0x0
  pushl $88
c0102181:	6a 58                	push   $0x58
  jmp __alltraps
c0102183:	e9 cb fc ff ff       	jmp    c0101e53 <__alltraps>

c0102188 <vector89>:
.globl vector89
vector89:
  pushl $0
c0102188:	6a 00                	push   $0x0
  pushl $89
c010218a:	6a 59                	push   $0x59
  jmp __alltraps
c010218c:	e9 c2 fc ff ff       	jmp    c0101e53 <__alltraps>

c0102191 <vector90>:
.globl vector90
vector90:
  pushl $0
c0102191:	6a 00                	push   $0x0
  pushl $90
c0102193:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102195:	e9 b9 fc ff ff       	jmp    c0101e53 <__alltraps>

c010219a <vector91>:
.globl vector91
vector91:
  pushl $0
c010219a:	6a 00                	push   $0x0
  pushl $91
c010219c:	6a 5b                	push   $0x5b
  jmp __alltraps
c010219e:	e9 b0 fc ff ff       	jmp    c0101e53 <__alltraps>

c01021a3 <vector92>:
.globl vector92
vector92:
  pushl $0
c01021a3:	6a 00                	push   $0x0
  pushl $92
c01021a5:	6a 5c                	push   $0x5c
  jmp __alltraps
c01021a7:	e9 a7 fc ff ff       	jmp    c0101e53 <__alltraps>

c01021ac <vector93>:
.globl vector93
vector93:
  pushl $0
c01021ac:	6a 00                	push   $0x0
  pushl $93
c01021ae:	6a 5d                	push   $0x5d
  jmp __alltraps
c01021b0:	e9 9e fc ff ff       	jmp    c0101e53 <__alltraps>

c01021b5 <vector94>:
.globl vector94
vector94:
  pushl $0
c01021b5:	6a 00                	push   $0x0
  pushl $94
c01021b7:	6a 5e                	push   $0x5e
  jmp __alltraps
c01021b9:	e9 95 fc ff ff       	jmp    c0101e53 <__alltraps>

c01021be <vector95>:
.globl vector95
vector95:
  pushl $0
c01021be:	6a 00                	push   $0x0
  pushl $95
c01021c0:	6a 5f                	push   $0x5f
  jmp __alltraps
c01021c2:	e9 8c fc ff ff       	jmp    c0101e53 <__alltraps>

c01021c7 <vector96>:
.globl vector96
vector96:
  pushl $0
c01021c7:	6a 00                	push   $0x0
  pushl $96
c01021c9:	6a 60                	push   $0x60
  jmp __alltraps
c01021cb:	e9 83 fc ff ff       	jmp    c0101e53 <__alltraps>

c01021d0 <vector97>:
.globl vector97
vector97:
  pushl $0
c01021d0:	6a 00                	push   $0x0
  pushl $97
c01021d2:	6a 61                	push   $0x61
  jmp __alltraps
c01021d4:	e9 7a fc ff ff       	jmp    c0101e53 <__alltraps>

c01021d9 <vector98>:
.globl vector98
vector98:
  pushl $0
c01021d9:	6a 00                	push   $0x0
  pushl $98
c01021db:	6a 62                	push   $0x62
  jmp __alltraps
c01021dd:	e9 71 fc ff ff       	jmp    c0101e53 <__alltraps>

c01021e2 <vector99>:
.globl vector99
vector99:
  pushl $0
c01021e2:	6a 00                	push   $0x0
  pushl $99
c01021e4:	6a 63                	push   $0x63
  jmp __alltraps
c01021e6:	e9 68 fc ff ff       	jmp    c0101e53 <__alltraps>

c01021eb <vector100>:
.globl vector100
vector100:
  pushl $0
c01021eb:	6a 00                	push   $0x0
  pushl $100
c01021ed:	6a 64                	push   $0x64
  jmp __alltraps
c01021ef:	e9 5f fc ff ff       	jmp    c0101e53 <__alltraps>

c01021f4 <vector101>:
.globl vector101
vector101:
  pushl $0
c01021f4:	6a 00                	push   $0x0
  pushl $101
c01021f6:	6a 65                	push   $0x65
  jmp __alltraps
c01021f8:	e9 56 fc ff ff       	jmp    c0101e53 <__alltraps>

c01021fd <vector102>:
.globl vector102
vector102:
  pushl $0
c01021fd:	6a 00                	push   $0x0
  pushl $102
c01021ff:	6a 66                	push   $0x66
  jmp __alltraps
c0102201:	e9 4d fc ff ff       	jmp    c0101e53 <__alltraps>

c0102206 <vector103>:
.globl vector103
vector103:
  pushl $0
c0102206:	6a 00                	push   $0x0
  pushl $103
c0102208:	6a 67                	push   $0x67
  jmp __alltraps
c010220a:	e9 44 fc ff ff       	jmp    c0101e53 <__alltraps>

c010220f <vector104>:
.globl vector104
vector104:
  pushl $0
c010220f:	6a 00                	push   $0x0
  pushl $104
c0102211:	6a 68                	push   $0x68
  jmp __alltraps
c0102213:	e9 3b fc ff ff       	jmp    c0101e53 <__alltraps>

c0102218 <vector105>:
.globl vector105
vector105:
  pushl $0
c0102218:	6a 00                	push   $0x0
  pushl $105
c010221a:	6a 69                	push   $0x69
  jmp __alltraps
c010221c:	e9 32 fc ff ff       	jmp    c0101e53 <__alltraps>

c0102221 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102221:	6a 00                	push   $0x0
  pushl $106
c0102223:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102225:	e9 29 fc ff ff       	jmp    c0101e53 <__alltraps>

c010222a <vector107>:
.globl vector107
vector107:
  pushl $0
c010222a:	6a 00                	push   $0x0
  pushl $107
c010222c:	6a 6b                	push   $0x6b
  jmp __alltraps
c010222e:	e9 20 fc ff ff       	jmp    c0101e53 <__alltraps>

c0102233 <vector108>:
.globl vector108
vector108:
  pushl $0
c0102233:	6a 00                	push   $0x0
  pushl $108
c0102235:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102237:	e9 17 fc ff ff       	jmp    c0101e53 <__alltraps>

c010223c <vector109>:
.globl vector109
vector109:
  pushl $0
c010223c:	6a 00                	push   $0x0
  pushl $109
c010223e:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102240:	e9 0e fc ff ff       	jmp    c0101e53 <__alltraps>

c0102245 <vector110>:
.globl vector110
vector110:
  pushl $0
c0102245:	6a 00                	push   $0x0
  pushl $110
c0102247:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102249:	e9 05 fc ff ff       	jmp    c0101e53 <__alltraps>

c010224e <vector111>:
.globl vector111
vector111:
  pushl $0
c010224e:	6a 00                	push   $0x0
  pushl $111
c0102250:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102252:	e9 fc fb ff ff       	jmp    c0101e53 <__alltraps>

c0102257 <vector112>:
.globl vector112
vector112:
  pushl $0
c0102257:	6a 00                	push   $0x0
  pushl $112
c0102259:	6a 70                	push   $0x70
  jmp __alltraps
c010225b:	e9 f3 fb ff ff       	jmp    c0101e53 <__alltraps>

c0102260 <vector113>:
.globl vector113
vector113:
  pushl $0
c0102260:	6a 00                	push   $0x0
  pushl $113
c0102262:	6a 71                	push   $0x71
  jmp __alltraps
c0102264:	e9 ea fb ff ff       	jmp    c0101e53 <__alltraps>

c0102269 <vector114>:
.globl vector114
vector114:
  pushl $0
c0102269:	6a 00                	push   $0x0
  pushl $114
c010226b:	6a 72                	push   $0x72
  jmp __alltraps
c010226d:	e9 e1 fb ff ff       	jmp    c0101e53 <__alltraps>

c0102272 <vector115>:
.globl vector115
vector115:
  pushl $0
c0102272:	6a 00                	push   $0x0
  pushl $115
c0102274:	6a 73                	push   $0x73
  jmp __alltraps
c0102276:	e9 d8 fb ff ff       	jmp    c0101e53 <__alltraps>

c010227b <vector116>:
.globl vector116
vector116:
  pushl $0
c010227b:	6a 00                	push   $0x0
  pushl $116
c010227d:	6a 74                	push   $0x74
  jmp __alltraps
c010227f:	e9 cf fb ff ff       	jmp    c0101e53 <__alltraps>

c0102284 <vector117>:
.globl vector117
vector117:
  pushl $0
c0102284:	6a 00                	push   $0x0
  pushl $117
c0102286:	6a 75                	push   $0x75
  jmp __alltraps
c0102288:	e9 c6 fb ff ff       	jmp    c0101e53 <__alltraps>

c010228d <vector118>:
.globl vector118
vector118:
  pushl $0
c010228d:	6a 00                	push   $0x0
  pushl $118
c010228f:	6a 76                	push   $0x76
  jmp __alltraps
c0102291:	e9 bd fb ff ff       	jmp    c0101e53 <__alltraps>

c0102296 <vector119>:
.globl vector119
vector119:
  pushl $0
c0102296:	6a 00                	push   $0x0
  pushl $119
c0102298:	6a 77                	push   $0x77
  jmp __alltraps
c010229a:	e9 b4 fb ff ff       	jmp    c0101e53 <__alltraps>

c010229f <vector120>:
.globl vector120
vector120:
  pushl $0
c010229f:	6a 00                	push   $0x0
  pushl $120
c01022a1:	6a 78                	push   $0x78
  jmp __alltraps
c01022a3:	e9 ab fb ff ff       	jmp    c0101e53 <__alltraps>

c01022a8 <vector121>:
.globl vector121
vector121:
  pushl $0
c01022a8:	6a 00                	push   $0x0
  pushl $121
c01022aa:	6a 79                	push   $0x79
  jmp __alltraps
c01022ac:	e9 a2 fb ff ff       	jmp    c0101e53 <__alltraps>

c01022b1 <vector122>:
.globl vector122
vector122:
  pushl $0
c01022b1:	6a 00                	push   $0x0
  pushl $122
c01022b3:	6a 7a                	push   $0x7a
  jmp __alltraps
c01022b5:	e9 99 fb ff ff       	jmp    c0101e53 <__alltraps>

c01022ba <vector123>:
.globl vector123
vector123:
  pushl $0
c01022ba:	6a 00                	push   $0x0
  pushl $123
c01022bc:	6a 7b                	push   $0x7b
  jmp __alltraps
c01022be:	e9 90 fb ff ff       	jmp    c0101e53 <__alltraps>

c01022c3 <vector124>:
.globl vector124
vector124:
  pushl $0
c01022c3:	6a 00                	push   $0x0
  pushl $124
c01022c5:	6a 7c                	push   $0x7c
  jmp __alltraps
c01022c7:	e9 87 fb ff ff       	jmp    c0101e53 <__alltraps>

c01022cc <vector125>:
.globl vector125
vector125:
  pushl $0
c01022cc:	6a 00                	push   $0x0
  pushl $125
c01022ce:	6a 7d                	push   $0x7d
  jmp __alltraps
c01022d0:	e9 7e fb ff ff       	jmp    c0101e53 <__alltraps>

c01022d5 <vector126>:
.globl vector126
vector126:
  pushl $0
c01022d5:	6a 00                	push   $0x0
  pushl $126
c01022d7:	6a 7e                	push   $0x7e
  jmp __alltraps
c01022d9:	e9 75 fb ff ff       	jmp    c0101e53 <__alltraps>

c01022de <vector127>:
.globl vector127
vector127:
  pushl $0
c01022de:	6a 00                	push   $0x0
  pushl $127
c01022e0:	6a 7f                	push   $0x7f
  jmp __alltraps
c01022e2:	e9 6c fb ff ff       	jmp    c0101e53 <__alltraps>

c01022e7 <vector128>:
.globl vector128
vector128:
  pushl $0
c01022e7:	6a 00                	push   $0x0
  pushl $128
c01022e9:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c01022ee:	e9 60 fb ff ff       	jmp    c0101e53 <__alltraps>

c01022f3 <vector129>:
.globl vector129
vector129:
  pushl $0
c01022f3:	6a 00                	push   $0x0
  pushl $129
c01022f5:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c01022fa:	e9 54 fb ff ff       	jmp    c0101e53 <__alltraps>

c01022ff <vector130>:
.globl vector130
vector130:
  pushl $0
c01022ff:	6a 00                	push   $0x0
  pushl $130
c0102301:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102306:	e9 48 fb ff ff       	jmp    c0101e53 <__alltraps>

c010230b <vector131>:
.globl vector131
vector131:
  pushl $0
c010230b:	6a 00                	push   $0x0
  pushl $131
c010230d:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102312:	e9 3c fb ff ff       	jmp    c0101e53 <__alltraps>

c0102317 <vector132>:
.globl vector132
vector132:
  pushl $0
c0102317:	6a 00                	push   $0x0
  pushl $132
c0102319:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c010231e:	e9 30 fb ff ff       	jmp    c0101e53 <__alltraps>

c0102323 <vector133>:
.globl vector133
vector133:
  pushl $0
c0102323:	6a 00                	push   $0x0
  pushl $133
c0102325:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c010232a:	e9 24 fb ff ff       	jmp    c0101e53 <__alltraps>

c010232f <vector134>:
.globl vector134
vector134:
  pushl $0
c010232f:	6a 00                	push   $0x0
  pushl $134
c0102331:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102336:	e9 18 fb ff ff       	jmp    c0101e53 <__alltraps>

c010233b <vector135>:
.globl vector135
vector135:
  pushl $0
c010233b:	6a 00                	push   $0x0
  pushl $135
c010233d:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102342:	e9 0c fb ff ff       	jmp    c0101e53 <__alltraps>

c0102347 <vector136>:
.globl vector136
vector136:
  pushl $0
c0102347:	6a 00                	push   $0x0
  pushl $136
c0102349:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c010234e:	e9 00 fb ff ff       	jmp    c0101e53 <__alltraps>

c0102353 <vector137>:
.globl vector137
vector137:
  pushl $0
c0102353:	6a 00                	push   $0x0
  pushl $137
c0102355:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c010235a:	e9 f4 fa ff ff       	jmp    c0101e53 <__alltraps>

c010235f <vector138>:
.globl vector138
vector138:
  pushl $0
c010235f:	6a 00                	push   $0x0
  pushl $138
c0102361:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102366:	e9 e8 fa ff ff       	jmp    c0101e53 <__alltraps>

c010236b <vector139>:
.globl vector139
vector139:
  pushl $0
c010236b:	6a 00                	push   $0x0
  pushl $139
c010236d:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102372:	e9 dc fa ff ff       	jmp    c0101e53 <__alltraps>

c0102377 <vector140>:
.globl vector140
vector140:
  pushl $0
c0102377:	6a 00                	push   $0x0
  pushl $140
c0102379:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c010237e:	e9 d0 fa ff ff       	jmp    c0101e53 <__alltraps>

c0102383 <vector141>:
.globl vector141
vector141:
  pushl $0
c0102383:	6a 00                	push   $0x0
  pushl $141
c0102385:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c010238a:	e9 c4 fa ff ff       	jmp    c0101e53 <__alltraps>

c010238f <vector142>:
.globl vector142
vector142:
  pushl $0
c010238f:	6a 00                	push   $0x0
  pushl $142
c0102391:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102396:	e9 b8 fa ff ff       	jmp    c0101e53 <__alltraps>

c010239b <vector143>:
.globl vector143
vector143:
  pushl $0
c010239b:	6a 00                	push   $0x0
  pushl $143
c010239d:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c01023a2:	e9 ac fa ff ff       	jmp    c0101e53 <__alltraps>

c01023a7 <vector144>:
.globl vector144
vector144:
  pushl $0
c01023a7:	6a 00                	push   $0x0
  pushl $144
c01023a9:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c01023ae:	e9 a0 fa ff ff       	jmp    c0101e53 <__alltraps>

c01023b3 <vector145>:
.globl vector145
vector145:
  pushl $0
c01023b3:	6a 00                	push   $0x0
  pushl $145
c01023b5:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c01023ba:	e9 94 fa ff ff       	jmp    c0101e53 <__alltraps>

c01023bf <vector146>:
.globl vector146
vector146:
  pushl $0
c01023bf:	6a 00                	push   $0x0
  pushl $146
c01023c1:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c01023c6:	e9 88 fa ff ff       	jmp    c0101e53 <__alltraps>

c01023cb <vector147>:
.globl vector147
vector147:
  pushl $0
c01023cb:	6a 00                	push   $0x0
  pushl $147
c01023cd:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c01023d2:	e9 7c fa ff ff       	jmp    c0101e53 <__alltraps>

c01023d7 <vector148>:
.globl vector148
vector148:
  pushl $0
c01023d7:	6a 00                	push   $0x0
  pushl $148
c01023d9:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c01023de:	e9 70 fa ff ff       	jmp    c0101e53 <__alltraps>

c01023e3 <vector149>:
.globl vector149
vector149:
  pushl $0
c01023e3:	6a 00                	push   $0x0
  pushl $149
c01023e5:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c01023ea:	e9 64 fa ff ff       	jmp    c0101e53 <__alltraps>

c01023ef <vector150>:
.globl vector150
vector150:
  pushl $0
c01023ef:	6a 00                	push   $0x0
  pushl $150
c01023f1:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c01023f6:	e9 58 fa ff ff       	jmp    c0101e53 <__alltraps>

c01023fb <vector151>:
.globl vector151
vector151:
  pushl $0
c01023fb:	6a 00                	push   $0x0
  pushl $151
c01023fd:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102402:	e9 4c fa ff ff       	jmp    c0101e53 <__alltraps>

c0102407 <vector152>:
.globl vector152
vector152:
  pushl $0
c0102407:	6a 00                	push   $0x0
  pushl $152
c0102409:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c010240e:	e9 40 fa ff ff       	jmp    c0101e53 <__alltraps>

c0102413 <vector153>:
.globl vector153
vector153:
  pushl $0
c0102413:	6a 00                	push   $0x0
  pushl $153
c0102415:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c010241a:	e9 34 fa ff ff       	jmp    c0101e53 <__alltraps>

c010241f <vector154>:
.globl vector154
vector154:
  pushl $0
c010241f:	6a 00                	push   $0x0
  pushl $154
c0102421:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0102426:	e9 28 fa ff ff       	jmp    c0101e53 <__alltraps>

c010242b <vector155>:
.globl vector155
vector155:
  pushl $0
c010242b:	6a 00                	push   $0x0
  pushl $155
c010242d:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102432:	e9 1c fa ff ff       	jmp    c0101e53 <__alltraps>

c0102437 <vector156>:
.globl vector156
vector156:
  pushl $0
c0102437:	6a 00                	push   $0x0
  pushl $156
c0102439:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c010243e:	e9 10 fa ff ff       	jmp    c0101e53 <__alltraps>

c0102443 <vector157>:
.globl vector157
vector157:
  pushl $0
c0102443:	6a 00                	push   $0x0
  pushl $157
c0102445:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c010244a:	e9 04 fa ff ff       	jmp    c0101e53 <__alltraps>

c010244f <vector158>:
.globl vector158
vector158:
  pushl $0
c010244f:	6a 00                	push   $0x0
  pushl $158
c0102451:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0102456:	e9 f8 f9 ff ff       	jmp    c0101e53 <__alltraps>

c010245b <vector159>:
.globl vector159
vector159:
  pushl $0
c010245b:	6a 00                	push   $0x0
  pushl $159
c010245d:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0102462:	e9 ec f9 ff ff       	jmp    c0101e53 <__alltraps>

c0102467 <vector160>:
.globl vector160
vector160:
  pushl $0
c0102467:	6a 00                	push   $0x0
  pushl $160
c0102469:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c010246e:	e9 e0 f9 ff ff       	jmp    c0101e53 <__alltraps>

c0102473 <vector161>:
.globl vector161
vector161:
  pushl $0
c0102473:	6a 00                	push   $0x0
  pushl $161
c0102475:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c010247a:	e9 d4 f9 ff ff       	jmp    c0101e53 <__alltraps>

c010247f <vector162>:
.globl vector162
vector162:
  pushl $0
c010247f:	6a 00                	push   $0x0
  pushl $162
c0102481:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0102486:	e9 c8 f9 ff ff       	jmp    c0101e53 <__alltraps>

c010248b <vector163>:
.globl vector163
vector163:
  pushl $0
c010248b:	6a 00                	push   $0x0
  pushl $163
c010248d:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0102492:	e9 bc f9 ff ff       	jmp    c0101e53 <__alltraps>

c0102497 <vector164>:
.globl vector164
vector164:
  pushl $0
c0102497:	6a 00                	push   $0x0
  pushl $164
c0102499:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c010249e:	e9 b0 f9 ff ff       	jmp    c0101e53 <__alltraps>

c01024a3 <vector165>:
.globl vector165
vector165:
  pushl $0
c01024a3:	6a 00                	push   $0x0
  pushl $165
c01024a5:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c01024aa:	e9 a4 f9 ff ff       	jmp    c0101e53 <__alltraps>

c01024af <vector166>:
.globl vector166
vector166:
  pushl $0
c01024af:	6a 00                	push   $0x0
  pushl $166
c01024b1:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c01024b6:	e9 98 f9 ff ff       	jmp    c0101e53 <__alltraps>

c01024bb <vector167>:
.globl vector167
vector167:
  pushl $0
c01024bb:	6a 00                	push   $0x0
  pushl $167
c01024bd:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c01024c2:	e9 8c f9 ff ff       	jmp    c0101e53 <__alltraps>

c01024c7 <vector168>:
.globl vector168
vector168:
  pushl $0
c01024c7:	6a 00                	push   $0x0
  pushl $168
c01024c9:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c01024ce:	e9 80 f9 ff ff       	jmp    c0101e53 <__alltraps>

c01024d3 <vector169>:
.globl vector169
vector169:
  pushl $0
c01024d3:	6a 00                	push   $0x0
  pushl $169
c01024d5:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c01024da:	e9 74 f9 ff ff       	jmp    c0101e53 <__alltraps>

c01024df <vector170>:
.globl vector170
vector170:
  pushl $0
c01024df:	6a 00                	push   $0x0
  pushl $170
c01024e1:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c01024e6:	e9 68 f9 ff ff       	jmp    c0101e53 <__alltraps>

c01024eb <vector171>:
.globl vector171
vector171:
  pushl $0
c01024eb:	6a 00                	push   $0x0
  pushl $171
c01024ed:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c01024f2:	e9 5c f9 ff ff       	jmp    c0101e53 <__alltraps>

c01024f7 <vector172>:
.globl vector172
vector172:
  pushl $0
c01024f7:	6a 00                	push   $0x0
  pushl $172
c01024f9:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c01024fe:	e9 50 f9 ff ff       	jmp    c0101e53 <__alltraps>

c0102503 <vector173>:
.globl vector173
vector173:
  pushl $0
c0102503:	6a 00                	push   $0x0
  pushl $173
c0102505:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c010250a:	e9 44 f9 ff ff       	jmp    c0101e53 <__alltraps>

c010250f <vector174>:
.globl vector174
vector174:
  pushl $0
c010250f:	6a 00                	push   $0x0
  pushl $174
c0102511:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0102516:	e9 38 f9 ff ff       	jmp    c0101e53 <__alltraps>

c010251b <vector175>:
.globl vector175
vector175:
  pushl $0
c010251b:	6a 00                	push   $0x0
  pushl $175
c010251d:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0102522:	e9 2c f9 ff ff       	jmp    c0101e53 <__alltraps>

c0102527 <vector176>:
.globl vector176
vector176:
  pushl $0
c0102527:	6a 00                	push   $0x0
  pushl $176
c0102529:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c010252e:	e9 20 f9 ff ff       	jmp    c0101e53 <__alltraps>

c0102533 <vector177>:
.globl vector177
vector177:
  pushl $0
c0102533:	6a 00                	push   $0x0
  pushl $177
c0102535:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c010253a:	e9 14 f9 ff ff       	jmp    c0101e53 <__alltraps>

c010253f <vector178>:
.globl vector178
vector178:
  pushl $0
c010253f:	6a 00                	push   $0x0
  pushl $178
c0102541:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0102546:	e9 08 f9 ff ff       	jmp    c0101e53 <__alltraps>

c010254b <vector179>:
.globl vector179
vector179:
  pushl $0
c010254b:	6a 00                	push   $0x0
  pushl $179
c010254d:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0102552:	e9 fc f8 ff ff       	jmp    c0101e53 <__alltraps>

c0102557 <vector180>:
.globl vector180
vector180:
  pushl $0
c0102557:	6a 00                	push   $0x0
  pushl $180
c0102559:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c010255e:	e9 f0 f8 ff ff       	jmp    c0101e53 <__alltraps>

c0102563 <vector181>:
.globl vector181
vector181:
  pushl $0
c0102563:	6a 00                	push   $0x0
  pushl $181
c0102565:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c010256a:	e9 e4 f8 ff ff       	jmp    c0101e53 <__alltraps>

c010256f <vector182>:
.globl vector182
vector182:
  pushl $0
c010256f:	6a 00                	push   $0x0
  pushl $182
c0102571:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0102576:	e9 d8 f8 ff ff       	jmp    c0101e53 <__alltraps>

c010257b <vector183>:
.globl vector183
vector183:
  pushl $0
c010257b:	6a 00                	push   $0x0
  pushl $183
c010257d:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0102582:	e9 cc f8 ff ff       	jmp    c0101e53 <__alltraps>

c0102587 <vector184>:
.globl vector184
vector184:
  pushl $0
c0102587:	6a 00                	push   $0x0
  pushl $184
c0102589:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c010258e:	e9 c0 f8 ff ff       	jmp    c0101e53 <__alltraps>

c0102593 <vector185>:
.globl vector185
vector185:
  pushl $0
c0102593:	6a 00                	push   $0x0
  pushl $185
c0102595:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c010259a:	e9 b4 f8 ff ff       	jmp    c0101e53 <__alltraps>

c010259f <vector186>:
.globl vector186
vector186:
  pushl $0
c010259f:	6a 00                	push   $0x0
  pushl $186
c01025a1:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c01025a6:	e9 a8 f8 ff ff       	jmp    c0101e53 <__alltraps>

c01025ab <vector187>:
.globl vector187
vector187:
  pushl $0
c01025ab:	6a 00                	push   $0x0
  pushl $187
c01025ad:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c01025b2:	e9 9c f8 ff ff       	jmp    c0101e53 <__alltraps>

c01025b7 <vector188>:
.globl vector188
vector188:
  pushl $0
c01025b7:	6a 00                	push   $0x0
  pushl $188
c01025b9:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c01025be:	e9 90 f8 ff ff       	jmp    c0101e53 <__alltraps>

c01025c3 <vector189>:
.globl vector189
vector189:
  pushl $0
c01025c3:	6a 00                	push   $0x0
  pushl $189
c01025c5:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c01025ca:	e9 84 f8 ff ff       	jmp    c0101e53 <__alltraps>

c01025cf <vector190>:
.globl vector190
vector190:
  pushl $0
c01025cf:	6a 00                	push   $0x0
  pushl $190
c01025d1:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c01025d6:	e9 78 f8 ff ff       	jmp    c0101e53 <__alltraps>

c01025db <vector191>:
.globl vector191
vector191:
  pushl $0
c01025db:	6a 00                	push   $0x0
  pushl $191
c01025dd:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c01025e2:	e9 6c f8 ff ff       	jmp    c0101e53 <__alltraps>

c01025e7 <vector192>:
.globl vector192
vector192:
  pushl $0
c01025e7:	6a 00                	push   $0x0
  pushl $192
c01025e9:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c01025ee:	e9 60 f8 ff ff       	jmp    c0101e53 <__alltraps>

c01025f3 <vector193>:
.globl vector193
vector193:
  pushl $0
c01025f3:	6a 00                	push   $0x0
  pushl $193
c01025f5:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c01025fa:	e9 54 f8 ff ff       	jmp    c0101e53 <__alltraps>

c01025ff <vector194>:
.globl vector194
vector194:
  pushl $0
c01025ff:	6a 00                	push   $0x0
  pushl $194
c0102601:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c0102606:	e9 48 f8 ff ff       	jmp    c0101e53 <__alltraps>

c010260b <vector195>:
.globl vector195
vector195:
  pushl $0
c010260b:	6a 00                	push   $0x0
  pushl $195
c010260d:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0102612:	e9 3c f8 ff ff       	jmp    c0101e53 <__alltraps>

c0102617 <vector196>:
.globl vector196
vector196:
  pushl $0
c0102617:	6a 00                	push   $0x0
  pushl $196
c0102619:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c010261e:	e9 30 f8 ff ff       	jmp    c0101e53 <__alltraps>

c0102623 <vector197>:
.globl vector197
vector197:
  pushl $0
c0102623:	6a 00                	push   $0x0
  pushl $197
c0102625:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c010262a:	e9 24 f8 ff ff       	jmp    c0101e53 <__alltraps>

c010262f <vector198>:
.globl vector198
vector198:
  pushl $0
c010262f:	6a 00                	push   $0x0
  pushl $198
c0102631:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0102636:	e9 18 f8 ff ff       	jmp    c0101e53 <__alltraps>

c010263b <vector199>:
.globl vector199
vector199:
  pushl $0
c010263b:	6a 00                	push   $0x0
  pushl $199
c010263d:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0102642:	e9 0c f8 ff ff       	jmp    c0101e53 <__alltraps>

c0102647 <vector200>:
.globl vector200
vector200:
  pushl $0
c0102647:	6a 00                	push   $0x0
  pushl $200
c0102649:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c010264e:	e9 00 f8 ff ff       	jmp    c0101e53 <__alltraps>

c0102653 <vector201>:
.globl vector201
vector201:
  pushl $0
c0102653:	6a 00                	push   $0x0
  pushl $201
c0102655:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c010265a:	e9 f4 f7 ff ff       	jmp    c0101e53 <__alltraps>

c010265f <vector202>:
.globl vector202
vector202:
  pushl $0
c010265f:	6a 00                	push   $0x0
  pushl $202
c0102661:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0102666:	e9 e8 f7 ff ff       	jmp    c0101e53 <__alltraps>

c010266b <vector203>:
.globl vector203
vector203:
  pushl $0
c010266b:	6a 00                	push   $0x0
  pushl $203
c010266d:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0102672:	e9 dc f7 ff ff       	jmp    c0101e53 <__alltraps>

c0102677 <vector204>:
.globl vector204
vector204:
  pushl $0
c0102677:	6a 00                	push   $0x0
  pushl $204
c0102679:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c010267e:	e9 d0 f7 ff ff       	jmp    c0101e53 <__alltraps>

c0102683 <vector205>:
.globl vector205
vector205:
  pushl $0
c0102683:	6a 00                	push   $0x0
  pushl $205
c0102685:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c010268a:	e9 c4 f7 ff ff       	jmp    c0101e53 <__alltraps>

c010268f <vector206>:
.globl vector206
vector206:
  pushl $0
c010268f:	6a 00                	push   $0x0
  pushl $206
c0102691:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c0102696:	e9 b8 f7 ff ff       	jmp    c0101e53 <__alltraps>

c010269b <vector207>:
.globl vector207
vector207:
  pushl $0
c010269b:	6a 00                	push   $0x0
  pushl $207
c010269d:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c01026a2:	e9 ac f7 ff ff       	jmp    c0101e53 <__alltraps>

c01026a7 <vector208>:
.globl vector208
vector208:
  pushl $0
c01026a7:	6a 00                	push   $0x0
  pushl $208
c01026a9:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c01026ae:	e9 a0 f7 ff ff       	jmp    c0101e53 <__alltraps>

c01026b3 <vector209>:
.globl vector209
vector209:
  pushl $0
c01026b3:	6a 00                	push   $0x0
  pushl $209
c01026b5:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c01026ba:	e9 94 f7 ff ff       	jmp    c0101e53 <__alltraps>

c01026bf <vector210>:
.globl vector210
vector210:
  pushl $0
c01026bf:	6a 00                	push   $0x0
  pushl $210
c01026c1:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c01026c6:	e9 88 f7 ff ff       	jmp    c0101e53 <__alltraps>

c01026cb <vector211>:
.globl vector211
vector211:
  pushl $0
c01026cb:	6a 00                	push   $0x0
  pushl $211
c01026cd:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c01026d2:	e9 7c f7 ff ff       	jmp    c0101e53 <__alltraps>

c01026d7 <vector212>:
.globl vector212
vector212:
  pushl $0
c01026d7:	6a 00                	push   $0x0
  pushl $212
c01026d9:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c01026de:	e9 70 f7 ff ff       	jmp    c0101e53 <__alltraps>

c01026e3 <vector213>:
.globl vector213
vector213:
  pushl $0
c01026e3:	6a 00                	push   $0x0
  pushl $213
c01026e5:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c01026ea:	e9 64 f7 ff ff       	jmp    c0101e53 <__alltraps>

c01026ef <vector214>:
.globl vector214
vector214:
  pushl $0
c01026ef:	6a 00                	push   $0x0
  pushl $214
c01026f1:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c01026f6:	e9 58 f7 ff ff       	jmp    c0101e53 <__alltraps>

c01026fb <vector215>:
.globl vector215
vector215:
  pushl $0
c01026fb:	6a 00                	push   $0x0
  pushl $215
c01026fd:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0102702:	e9 4c f7 ff ff       	jmp    c0101e53 <__alltraps>

c0102707 <vector216>:
.globl vector216
vector216:
  pushl $0
c0102707:	6a 00                	push   $0x0
  pushl $216
c0102709:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c010270e:	e9 40 f7 ff ff       	jmp    c0101e53 <__alltraps>

c0102713 <vector217>:
.globl vector217
vector217:
  pushl $0
c0102713:	6a 00                	push   $0x0
  pushl $217
c0102715:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c010271a:	e9 34 f7 ff ff       	jmp    c0101e53 <__alltraps>

c010271f <vector218>:
.globl vector218
vector218:
  pushl $0
c010271f:	6a 00                	push   $0x0
  pushl $218
c0102721:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0102726:	e9 28 f7 ff ff       	jmp    c0101e53 <__alltraps>

c010272b <vector219>:
.globl vector219
vector219:
  pushl $0
c010272b:	6a 00                	push   $0x0
  pushl $219
c010272d:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0102732:	e9 1c f7 ff ff       	jmp    c0101e53 <__alltraps>

c0102737 <vector220>:
.globl vector220
vector220:
  pushl $0
c0102737:	6a 00                	push   $0x0
  pushl $220
c0102739:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c010273e:	e9 10 f7 ff ff       	jmp    c0101e53 <__alltraps>

c0102743 <vector221>:
.globl vector221
vector221:
  pushl $0
c0102743:	6a 00                	push   $0x0
  pushl $221
c0102745:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c010274a:	e9 04 f7 ff ff       	jmp    c0101e53 <__alltraps>

c010274f <vector222>:
.globl vector222
vector222:
  pushl $0
c010274f:	6a 00                	push   $0x0
  pushl $222
c0102751:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0102756:	e9 f8 f6 ff ff       	jmp    c0101e53 <__alltraps>

c010275b <vector223>:
.globl vector223
vector223:
  pushl $0
c010275b:	6a 00                	push   $0x0
  pushl $223
c010275d:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0102762:	e9 ec f6 ff ff       	jmp    c0101e53 <__alltraps>

c0102767 <vector224>:
.globl vector224
vector224:
  pushl $0
c0102767:	6a 00                	push   $0x0
  pushl $224
c0102769:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c010276e:	e9 e0 f6 ff ff       	jmp    c0101e53 <__alltraps>

c0102773 <vector225>:
.globl vector225
vector225:
  pushl $0
c0102773:	6a 00                	push   $0x0
  pushl $225
c0102775:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c010277a:	e9 d4 f6 ff ff       	jmp    c0101e53 <__alltraps>

c010277f <vector226>:
.globl vector226
vector226:
  pushl $0
c010277f:	6a 00                	push   $0x0
  pushl $226
c0102781:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c0102786:	e9 c8 f6 ff ff       	jmp    c0101e53 <__alltraps>

c010278b <vector227>:
.globl vector227
vector227:
  pushl $0
c010278b:	6a 00                	push   $0x0
  pushl $227
c010278d:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c0102792:	e9 bc f6 ff ff       	jmp    c0101e53 <__alltraps>

c0102797 <vector228>:
.globl vector228
vector228:
  pushl $0
c0102797:	6a 00                	push   $0x0
  pushl $228
c0102799:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c010279e:	e9 b0 f6 ff ff       	jmp    c0101e53 <__alltraps>

c01027a3 <vector229>:
.globl vector229
vector229:
  pushl $0
c01027a3:	6a 00                	push   $0x0
  pushl $229
c01027a5:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c01027aa:	e9 a4 f6 ff ff       	jmp    c0101e53 <__alltraps>

c01027af <vector230>:
.globl vector230
vector230:
  pushl $0
c01027af:	6a 00                	push   $0x0
  pushl $230
c01027b1:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c01027b6:	e9 98 f6 ff ff       	jmp    c0101e53 <__alltraps>

c01027bb <vector231>:
.globl vector231
vector231:
  pushl $0
c01027bb:	6a 00                	push   $0x0
  pushl $231
c01027bd:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c01027c2:	e9 8c f6 ff ff       	jmp    c0101e53 <__alltraps>

c01027c7 <vector232>:
.globl vector232
vector232:
  pushl $0
c01027c7:	6a 00                	push   $0x0
  pushl $232
c01027c9:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c01027ce:	e9 80 f6 ff ff       	jmp    c0101e53 <__alltraps>

c01027d3 <vector233>:
.globl vector233
vector233:
  pushl $0
c01027d3:	6a 00                	push   $0x0
  pushl $233
c01027d5:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c01027da:	e9 74 f6 ff ff       	jmp    c0101e53 <__alltraps>

c01027df <vector234>:
.globl vector234
vector234:
  pushl $0
c01027df:	6a 00                	push   $0x0
  pushl $234
c01027e1:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c01027e6:	e9 68 f6 ff ff       	jmp    c0101e53 <__alltraps>

c01027eb <vector235>:
.globl vector235
vector235:
  pushl $0
c01027eb:	6a 00                	push   $0x0
  pushl $235
c01027ed:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c01027f2:	e9 5c f6 ff ff       	jmp    c0101e53 <__alltraps>

c01027f7 <vector236>:
.globl vector236
vector236:
  pushl $0
c01027f7:	6a 00                	push   $0x0
  pushl $236
c01027f9:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c01027fe:	e9 50 f6 ff ff       	jmp    c0101e53 <__alltraps>

c0102803 <vector237>:
.globl vector237
vector237:
  pushl $0
c0102803:	6a 00                	push   $0x0
  pushl $237
c0102805:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c010280a:	e9 44 f6 ff ff       	jmp    c0101e53 <__alltraps>

c010280f <vector238>:
.globl vector238
vector238:
  pushl $0
c010280f:	6a 00                	push   $0x0
  pushl $238
c0102811:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c0102816:	e9 38 f6 ff ff       	jmp    c0101e53 <__alltraps>

c010281b <vector239>:
.globl vector239
vector239:
  pushl $0
c010281b:	6a 00                	push   $0x0
  pushl $239
c010281d:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0102822:	e9 2c f6 ff ff       	jmp    c0101e53 <__alltraps>

c0102827 <vector240>:
.globl vector240
vector240:
  pushl $0
c0102827:	6a 00                	push   $0x0
  pushl $240
c0102829:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c010282e:	e9 20 f6 ff ff       	jmp    c0101e53 <__alltraps>

c0102833 <vector241>:
.globl vector241
vector241:
  pushl $0
c0102833:	6a 00                	push   $0x0
  pushl $241
c0102835:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c010283a:	e9 14 f6 ff ff       	jmp    c0101e53 <__alltraps>

c010283f <vector242>:
.globl vector242
vector242:
  pushl $0
c010283f:	6a 00                	push   $0x0
  pushl $242
c0102841:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c0102846:	e9 08 f6 ff ff       	jmp    c0101e53 <__alltraps>

c010284b <vector243>:
.globl vector243
vector243:
  pushl $0
c010284b:	6a 00                	push   $0x0
  pushl $243
c010284d:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0102852:	e9 fc f5 ff ff       	jmp    c0101e53 <__alltraps>

c0102857 <vector244>:
.globl vector244
vector244:
  pushl $0
c0102857:	6a 00                	push   $0x0
  pushl $244
c0102859:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c010285e:	e9 f0 f5 ff ff       	jmp    c0101e53 <__alltraps>

c0102863 <vector245>:
.globl vector245
vector245:
  pushl $0
c0102863:	6a 00                	push   $0x0
  pushl $245
c0102865:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c010286a:	e9 e4 f5 ff ff       	jmp    c0101e53 <__alltraps>

c010286f <vector246>:
.globl vector246
vector246:
  pushl $0
c010286f:	6a 00                	push   $0x0
  pushl $246
c0102871:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c0102876:	e9 d8 f5 ff ff       	jmp    c0101e53 <__alltraps>

c010287b <vector247>:
.globl vector247
vector247:
  pushl $0
c010287b:	6a 00                	push   $0x0
  pushl $247
c010287d:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c0102882:	e9 cc f5 ff ff       	jmp    c0101e53 <__alltraps>

c0102887 <vector248>:
.globl vector248
vector248:
  pushl $0
c0102887:	6a 00                	push   $0x0
  pushl $248
c0102889:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c010288e:	e9 c0 f5 ff ff       	jmp    c0101e53 <__alltraps>

c0102893 <vector249>:
.globl vector249
vector249:
  pushl $0
c0102893:	6a 00                	push   $0x0
  pushl $249
c0102895:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c010289a:	e9 b4 f5 ff ff       	jmp    c0101e53 <__alltraps>

c010289f <vector250>:
.globl vector250
vector250:
  pushl $0
c010289f:	6a 00                	push   $0x0
  pushl $250
c01028a1:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c01028a6:	e9 a8 f5 ff ff       	jmp    c0101e53 <__alltraps>

c01028ab <vector251>:
.globl vector251
vector251:
  pushl $0
c01028ab:	6a 00                	push   $0x0
  pushl $251
c01028ad:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c01028b2:	e9 9c f5 ff ff       	jmp    c0101e53 <__alltraps>

c01028b7 <vector252>:
.globl vector252
vector252:
  pushl $0
c01028b7:	6a 00                	push   $0x0
  pushl $252
c01028b9:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c01028be:	e9 90 f5 ff ff       	jmp    c0101e53 <__alltraps>

c01028c3 <vector253>:
.globl vector253
vector253:
  pushl $0
c01028c3:	6a 00                	push   $0x0
  pushl $253
c01028c5:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c01028ca:	e9 84 f5 ff ff       	jmp    c0101e53 <__alltraps>

c01028cf <vector254>:
.globl vector254
vector254:
  pushl $0
c01028cf:	6a 00                	push   $0x0
  pushl $254
c01028d1:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c01028d6:	e9 78 f5 ff ff       	jmp    c0101e53 <__alltraps>

c01028db <vector255>:
.globl vector255
vector255:
  pushl $0
c01028db:	6a 00                	push   $0x0
  pushl $255
c01028dd:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c01028e2:	e9 6c f5 ff ff       	jmp    c0101e53 <__alltraps>

c01028e7 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01028e7:	55                   	push   %ebp
c01028e8:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01028ea:	8b 15 a0 be 11 c0    	mov    0xc011bea0,%edx
c01028f0:	8b 45 08             	mov    0x8(%ebp),%eax
c01028f3:	29 d0                	sub    %edx,%eax
c01028f5:	c1 f8 02             	sar    $0x2,%eax
c01028f8:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c01028fe:	5d                   	pop    %ebp
c01028ff:	c3                   	ret    

c0102900 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0102900:	55                   	push   %ebp
c0102901:	89 e5                	mov    %esp,%ebp
c0102903:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0102906:	8b 45 08             	mov    0x8(%ebp),%eax
c0102909:	89 04 24             	mov    %eax,(%esp)
c010290c:	e8 d6 ff ff ff       	call   c01028e7 <page2ppn>
c0102911:	c1 e0 0c             	shl    $0xc,%eax
}
c0102914:	89 ec                	mov    %ebp,%esp
c0102916:	5d                   	pop    %ebp
c0102917:	c3                   	ret    

c0102918 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c0102918:	55                   	push   %ebp
c0102919:	89 e5                	mov    %esp,%ebp
    return page->ref;
c010291b:	8b 45 08             	mov    0x8(%ebp),%eax
c010291e:	8b 00                	mov    (%eax),%eax
}
c0102920:	5d                   	pop    %ebp
c0102921:	c3                   	ret    

c0102922 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0102922:	55                   	push   %ebp
c0102923:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0102925:	8b 45 08             	mov    0x8(%ebp),%eax
c0102928:	8b 55 0c             	mov    0xc(%ebp),%edx
c010292b:	89 10                	mov    %edx,(%eax)
}
c010292d:	90                   	nop
c010292e:	5d                   	pop    %ebp
c010292f:	c3                   	ret    

c0102930 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {//初始化双向链表
c0102930:	55                   	push   %ebp
c0102931:	89 e5                	mov    %esp,%ebp
c0102933:	83 ec 10             	sub    $0x10,%esp
c0102936:	c7 45 fc 80 be 11 c0 	movl   $0xc011be80,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010293d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102940:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0102943:	89 50 04             	mov    %edx,0x4(%eax)
c0102946:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102949:	8b 50 04             	mov    0x4(%eax),%edx
c010294c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010294f:	89 10                	mov    %edx,(%eax)
}
c0102951:	90                   	nop
    list_init(&free_list);
    nr_free = 0;
c0102952:	c7 05 88 be 11 c0 00 	movl   $0x0,0xc011be88
c0102959:	00 00 00 
}
c010295c:	90                   	nop
c010295d:	89 ec                	mov    %ebp,%esp
c010295f:	5d                   	pop    %ebp
c0102960:	c3                   	ret    

c0102961 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {//
c0102961:	55                   	push   %ebp
c0102962:	89 e5                	mov    %esp,%ebp
c0102964:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);//物理页个数
c0102967:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010296b:	75 24                	jne    c0102991 <default_init_memmap+0x30>
c010296d:	c7 44 24 0c d0 66 10 	movl   $0xc01066d0,0xc(%esp)
c0102974:	c0 
c0102975:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c010297c:	c0 
c010297d:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0102984:	00 
c0102985:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c010298c:	e8 4a e3 ff ff       	call   c0100cdb <__panic>
    struct Page *p = base;
c0102991:	8b 45 08             	mov    0x8(%ebp),%eax
c0102994:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0102997:	e9 97 00 00 00       	jmp    c0102a33 <default_init_memmap+0xd2>
        assert(PageReserved(p));//判断是不是保留页，防止被分配或者破坏
c010299c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010299f:	83 c0 04             	add    $0x4,%eax
c01029a2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c01029a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01029ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01029af:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01029b2:	0f a3 10             	bt     %edx,(%eax)
c01029b5:	19 c0                	sbb    %eax,%eax
c01029b7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c01029ba:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01029be:	0f 95 c0             	setne  %al
c01029c1:	0f b6 c0             	movzbl %al,%eax
c01029c4:	85 c0                	test   %eax,%eax
c01029c6:	75 24                	jne    c01029ec <default_init_memmap+0x8b>
c01029c8:	c7 44 24 0c 01 67 10 	movl   $0xc0106701,0xc(%esp)
c01029cf:	c0 
c01029d0:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c01029d7:	c0 
c01029d8:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c01029df:	00 
c01029e0:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c01029e7:	e8 ef e2 ff ff       	call   c0100cdb <__panic>
        p->flags = p->property = 0;
c01029ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01029ef:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c01029f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01029f9:	8b 50 08             	mov    0x8(%eax),%edx
c01029fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01029ff:	89 50 04             	mov    %edx,0x4(%eax)
        SetPageProperty(base);//设置标志位p->property=0
c0102a02:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a05:	83 c0 04             	add    $0x4,%eax
c0102a08:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c0102a0f:	89 45 e0             	mov    %eax,-0x20(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102a12:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102a15:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102a18:	0f ab 10             	bts    %edx,(%eax)
}
c0102a1b:	90                   	nop
        set_page_ref(p, 0);//设置引用此页的虚拟页为0
c0102a1c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0102a23:	00 
c0102a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102a27:	89 04 24             	mov    %eax,(%esp)
c0102a2a:	e8 f3 fe ff ff       	call   c0102922 <set_page_ref>
    for (; p != base + n; p ++) {
c0102a2f:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0102a33:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102a36:	89 d0                	mov    %edx,%eax
c0102a38:	c1 e0 02             	shl    $0x2,%eax
c0102a3b:	01 d0                	add    %edx,%eax
c0102a3d:	c1 e0 02             	shl    $0x2,%eax
c0102a40:	89 c2                	mov    %eax,%edx
c0102a42:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a45:	01 d0                	add    %edx,%eax
c0102a47:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0102a4a:	0f 85 4c ff ff ff    	jne    c010299c <default_init_memmap+0x3b>
        
    }
    base->property = n;
c0102a50:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a53:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102a56:	89 50 08             	mov    %edx,0x8(%eax)
    nr_free += n;//本Page有n个空闲页
c0102a59:	8b 15 88 be 11 c0    	mov    0xc011be88,%edx
c0102a5f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102a62:	01 d0                	add    %edx,%eax
c0102a64:	a3 88 be 11 c0       	mov    %eax,0xc011be88
    list_add_before(&free_list, &(base->page_link));
c0102a69:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a6c:	83 c0 0c             	add    $0xc,%eax
c0102a6f:	c7 45 dc 80 be 11 c0 	movl   $0xc011be80,-0x24(%ebp)
c0102a76:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0102a79:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102a7c:	8b 00                	mov    (%eax),%eax
c0102a7e:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0102a81:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0102a84:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102a87:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102a8a:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0102a8d:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102a90:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102a93:	89 10                	mov    %edx,(%eax)
c0102a95:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102a98:	8b 10                	mov    (%eax),%edx
c0102a9a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102a9d:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102aa0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102aa3:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102aa6:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102aa9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102aac:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102aaf:	89 10                	mov    %edx,(%eax)
}
c0102ab1:	90                   	nop
}
c0102ab2:	90                   	nop
    
}
c0102ab3:	90                   	nop
c0102ab4:	89 ec                	mov    %ebp,%esp
c0102ab6:	5d                   	pop    %ebp
c0102ab7:	c3                   	ret    

c0102ab8 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c0102ab8:	55                   	push   %ebp
c0102ab9:	89 e5                	mov    %esp,%ebp
c0102abb:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c0102abe:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0102ac2:	75 24                	jne    c0102ae8 <default_alloc_pages+0x30>
c0102ac4:	c7 44 24 0c d0 66 10 	movl   $0xc01066d0,0xc(%esp)
c0102acb:	c0 
c0102acc:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0102ad3:	c0 
c0102ad4:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
c0102adb:	00 
c0102adc:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0102ae3:	e8 f3 e1 ff ff       	call   c0100cdb <__panic>
    if (n > nr_free) {//判断分配的页数和实际空闲的页数
c0102ae8:	a1 88 be 11 c0       	mov    0xc011be88,%eax
c0102aed:	39 45 08             	cmp    %eax,0x8(%ebp)
c0102af0:	76 0a                	jbe    c0102afc <default_alloc_pages+0x44>
        return NULL;
c0102af2:	b8 00 00 00 00       	mov    $0x0,%eax
c0102af7:	e9 43 01 00 00       	jmp    c0102c3f <default_alloc_pages+0x187>
    }
    struct Page *page = NULL;
c0102afc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;//获得空闲页表的长度和头部
c0102b03:	c7 45 f0 80 be 11 c0 	movl   $0xc011be80,-0x10(%ebp)
    // TODO: optimize (next-fit)
    while ((le = list_next(le)) != &free_list) {
c0102b0a:	eb 1c                	jmp    c0102b28 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);//链表地址转换为Page结构指针
c0102b0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102b0f:	83 e8 0c             	sub    $0xc,%eax
c0102b12:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {//找到第一个页数足够的块
c0102b15:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102b18:	8b 40 08             	mov    0x8(%eax),%eax
c0102b1b:	39 45 08             	cmp    %eax,0x8(%ebp)
c0102b1e:	77 08                	ja     c0102b28 <default_alloc_pages+0x70>
            page = p;
c0102b20:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102b23:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c0102b26:	eb 18                	jmp    c0102b40 <default_alloc_pages+0x88>
c0102b28:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102b2b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c0102b2e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102b31:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0102b34:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102b37:	81 7d f0 80 be 11 c0 	cmpl   $0xc011be80,-0x10(%ebp)
c0102b3e:	75 cc                	jne    c0102b0c <default_alloc_pages+0x54>
        }
    }
    if (page != NULL) {
c0102b40:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102b44:	0f 84 f2 00 00 00    	je     c0102c3c <default_alloc_pages+0x184>
        if (page->property > n) {
c0102b4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b4d:	8b 40 08             	mov    0x8(%eax),%eax
c0102b50:	39 45 08             	cmp    %eax,0x8(%ebp)
c0102b53:	0f 83 8f 00 00 00    	jae    c0102be8 <default_alloc_pages+0x130>
            struct Page *p = page + n;//分离出的新的小空闲首页位置
c0102b59:	8b 55 08             	mov    0x8(%ebp),%edx
c0102b5c:	89 d0                	mov    %edx,%eax
c0102b5e:	c1 e0 02             	shl    $0x2,%eax
c0102b61:	01 d0                	add    %edx,%eax
c0102b63:	c1 e0 02             	shl    $0x2,%eax
c0102b66:	89 c2                	mov    %eax,%edx
c0102b68:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b6b:	01 d0                	add    %edx,%eax
c0102b6d:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;//更新大小信息
c0102b70:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b73:	8b 40 08             	mov    0x8(%eax),%eax
c0102b76:	2b 45 08             	sub    0x8(%ebp),%eax
c0102b79:	89 c2                	mov    %eax,%edx
c0102b7b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102b7e:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
c0102b81:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102b84:	83 c0 04             	add    $0x4,%eax
c0102b87:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
c0102b8e:	89 45 c8             	mov    %eax,-0x38(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102b91:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102b94:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102b97:	0f ab 10             	bts    %edx,(%eax)
}
c0102b9a:	90                   	nop
            list_add_after(&(page->page_link), &(p->page_link));
c0102b9b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102b9e:	83 c0 0c             	add    $0xc,%eax
c0102ba1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102ba4:	83 c2 0c             	add    $0xc,%edx
c0102ba7:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0102baa:	89 45 dc             	mov    %eax,-0x24(%ebp)
    __list_add(elm, listelm, listelm->next);
c0102bad:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102bb0:	8b 40 04             	mov    0x4(%eax),%eax
c0102bb3:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102bb6:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0102bb9:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0102bbc:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0102bbf:	89 45 d0             	mov    %eax,-0x30(%ebp)
    prev->next = next->prev = elm;
c0102bc2:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102bc5:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0102bc8:	89 10                	mov    %edx,(%eax)
c0102bca:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102bcd:	8b 10                	mov    (%eax),%edx
c0102bcf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102bd2:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102bd5:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0102bd8:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102bdb:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102bde:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0102be1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102be4:	89 10                	mov    %edx,(%eax)
}
c0102be6:	90                   	nop
}
c0102be7:	90                   	nop
        }
        list_del(&(page->page_link));//删除分配出去的块
c0102be8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102beb:	83 c0 0c             	add    $0xc,%eax
c0102bee:	89 45 bc             	mov    %eax,-0x44(%ebp)
    __list_del(listelm->prev, listelm->next);
c0102bf1:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102bf4:	8b 40 04             	mov    0x4(%eax),%eax
c0102bf7:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0102bfa:	8b 12                	mov    (%edx),%edx
c0102bfc:	89 55 b8             	mov    %edx,-0x48(%ebp)
c0102bff:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0102c02:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102c05:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0102c08:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102c0b:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102c0e:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0102c11:	89 10                	mov    %edx,(%eax)
}
c0102c13:	90                   	nop
}
c0102c14:	90                   	nop
        nr_free -= n;//全局空闲页更新
c0102c15:	a1 88 be 11 c0       	mov    0xc011be88,%eax
c0102c1a:	2b 45 08             	sub    0x8(%ebp),%eax
c0102c1d:	a3 88 be 11 c0       	mov    %eax,0xc011be88
        ClearPageProperty(page);
c0102c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c25:	83 c0 04             	add    $0x4,%eax
c0102c28:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0102c2f:	89 45 c0             	mov    %eax,-0x40(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102c32:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0102c35:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0102c38:	0f b3 10             	btr    %edx,(%eax)
}
c0102c3b:	90                   	nop
    }
    return page;
c0102c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102c3f:	89 ec                	mov    %ebp,%esp
c0102c41:	5d                   	pop    %ebp
c0102c42:	c3                   	ret    

c0102c43 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c0102c43:	55                   	push   %ebp
c0102c44:	89 e5                	mov    %esp,%ebp
c0102c46:	81 ec 88 00 00 00    	sub    $0x88,%esp
    assert(n > 0);
c0102c4c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0102c50:	75 24                	jne    c0102c76 <default_free_pages+0x33>
c0102c52:	c7 44 24 0c d0 66 10 	movl   $0xc01066d0,0xc(%esp)
c0102c59:	c0 
c0102c5a:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0102c61:	c0 
c0102c62:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c0102c69:	00 
c0102c6a:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0102c71:	e8 65 e0 ff ff       	call   c0100cdb <__panic>
    struct Page *p = base;
c0102c76:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c79:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0102c7c:	e9 9d 00 00 00       	jmp    c0102d1e <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));//检查各个页是被占用或者已经分配出去，否则异常
c0102c81:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c84:	83 c0 04             	add    $0x4,%eax
c0102c87:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0102c8e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102c91:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102c94:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0102c97:	0f a3 10             	bt     %edx,(%eax)
c0102c9a:	19 c0                	sbb    %eax,%eax
c0102c9c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c0102c9f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102ca3:	0f 95 c0             	setne  %al
c0102ca6:	0f b6 c0             	movzbl %al,%eax
c0102ca9:	85 c0                	test   %eax,%eax
c0102cab:	75 2c                	jne    c0102cd9 <default_free_pages+0x96>
c0102cad:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102cb0:	83 c0 04             	add    $0x4,%eax
c0102cb3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0102cba:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102cbd:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102cc0:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0102cc3:	0f a3 10             	bt     %edx,(%eax)
c0102cc6:	19 c0                	sbb    %eax,%eax
c0102cc8:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c0102ccb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0102ccf:	0f 95 c0             	setne  %al
c0102cd2:	0f b6 c0             	movzbl %al,%eax
c0102cd5:	85 c0                	test   %eax,%eax
c0102cd7:	74 24                	je     c0102cfd <default_free_pages+0xba>
c0102cd9:	c7 44 24 0c 14 67 10 	movl   $0xc0106714,0xc(%esp)
c0102ce0:	c0 
c0102ce1:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0102ce8:	c0 
c0102ce9:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c0102cf0:	00 
c0102cf1:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0102cf8:	e8 de df ff ff       	call   c0100cdb <__panic>
        p->flags = 0;
c0102cfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d00:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);//重置
c0102d07:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0102d0e:	00 
c0102d0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d12:	89 04 24             	mov    %eax,(%esp)
c0102d15:	e8 08 fc ff ff       	call   c0102922 <set_page_ref>
    for (; p != base + n; p ++) {
c0102d1a:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0102d1e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102d21:	89 d0                	mov    %edx,%eax
c0102d23:	c1 e0 02             	shl    $0x2,%eax
c0102d26:	01 d0                	add    %edx,%eax
c0102d28:	c1 e0 02             	shl    $0x2,%eax
c0102d2b:	89 c2                	mov    %eax,%edx
c0102d2d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d30:	01 d0                	add    %edx,%eax
c0102d32:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0102d35:	0f 85 46 ff ff ff    	jne    c0102c81 <default_free_pages+0x3e>
    }
    base->property = n;
c0102d3b:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d3e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102d41:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0102d44:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d47:	83 c0 04             	add    $0x4,%eax
c0102d4a:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0102d51:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102d54:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102d57:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102d5a:	0f ab 10             	bts    %edx,(%eax)
}
c0102d5d:	90                   	nop
c0102d5e:	c7 45 d4 80 be 11 c0 	movl   $0xc011be80,-0x2c(%ebp)
    return listelm->next;
c0102d65:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102d68:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list); //下一块空闲
c0102d6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0102d6e:	e9 0e 01 00 00       	jmp    c0102e81 <default_free_pages+0x23e>
        p = le2page(le, page_link);
c0102d73:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102d76:	83 e8 0c             	sub    $0xc,%eax
c0102d79:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102d7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102d7f:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0102d82:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102d85:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0102d88:	89 45 f0             	mov    %eax,-0x10(%ebp)
        // TODO: optimize
        if (base + base->property == p) {//两块儿相邻
c0102d8b:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d8e:	8b 50 08             	mov    0x8(%eax),%edx
c0102d91:	89 d0                	mov    %edx,%eax
c0102d93:	c1 e0 02             	shl    $0x2,%eax
c0102d96:	01 d0                	add    %edx,%eax
c0102d98:	c1 e0 02             	shl    $0x2,%eax
c0102d9b:	89 c2                	mov    %eax,%edx
c0102d9d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102da0:	01 d0                	add    %edx,%eax
c0102da2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0102da5:	75 5d                	jne    c0102e04 <default_free_pages+0x1c1>
            base->property += p->property;
c0102da7:	8b 45 08             	mov    0x8(%ebp),%eax
c0102daa:	8b 50 08             	mov    0x8(%eax),%edx
c0102dad:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102db0:	8b 40 08             	mov    0x8(%eax),%eax
c0102db3:	01 c2                	add    %eax,%edx
c0102db5:	8b 45 08             	mov    0x8(%ebp),%eax
c0102db8:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c0102dbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102dbe:	83 c0 04             	add    $0x4,%eax
c0102dc1:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c0102dc8:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102dcb:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102dce:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0102dd1:	0f b3 10             	btr    %edx,(%eax)
}
c0102dd4:	90                   	nop
            list_del(&(p->page_link));
c0102dd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102dd8:	83 c0 0c             	add    $0xc,%eax
c0102ddb:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    __list_del(listelm->prev, listelm->next);
c0102dde:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102de1:	8b 40 04             	mov    0x4(%eax),%eax
c0102de4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0102de7:	8b 12                	mov    (%edx),%edx
c0102de9:	89 55 c0             	mov    %edx,-0x40(%ebp)
c0102dec:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next;
c0102def:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0102df2:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0102df5:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102df8:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102dfb:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0102dfe:	89 10                	mov    %edx,(%eax)
}
c0102e00:	90                   	nop
}
c0102e01:	90                   	nop
c0102e02:	eb 7d                	jmp    c0102e81 <default_free_pages+0x23e>
        }
        else if (p + p->property == base) {
c0102e04:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102e07:	8b 50 08             	mov    0x8(%eax),%edx
c0102e0a:	89 d0                	mov    %edx,%eax
c0102e0c:	c1 e0 02             	shl    $0x2,%eax
c0102e0f:	01 d0                	add    %edx,%eax
c0102e11:	c1 e0 02             	shl    $0x2,%eax
c0102e14:	89 c2                	mov    %eax,%edx
c0102e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102e19:	01 d0                	add    %edx,%eax
c0102e1b:	39 45 08             	cmp    %eax,0x8(%ebp)
c0102e1e:	75 61                	jne    c0102e81 <default_free_pages+0x23e>
            p->property += base->property;
c0102e20:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102e23:	8b 50 08             	mov    0x8(%eax),%edx
c0102e26:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e29:	8b 40 08             	mov    0x8(%eax),%eax
c0102e2c:	01 c2                	add    %eax,%edx
c0102e2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102e31:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c0102e34:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e37:	83 c0 04             	add    $0x4,%eax
c0102e3a:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
c0102e41:	89 45 a0             	mov    %eax,-0x60(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102e44:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102e47:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0102e4a:	0f b3 10             	btr    %edx,(%eax)
}
c0102e4d:	90                   	nop
            base = p;
c0102e4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102e51:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0102e54:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102e57:	83 c0 0c             	add    $0xc,%eax
c0102e5a:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
c0102e5d:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0102e60:	8b 40 04             	mov    0x4(%eax),%eax
c0102e63:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0102e66:	8b 12                	mov    (%edx),%edx
c0102e68:	89 55 ac             	mov    %edx,-0x54(%ebp)
c0102e6b:	89 45 a8             	mov    %eax,-0x58(%ebp)
    prev->next = next;
c0102e6e:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0102e71:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0102e74:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102e77:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0102e7a:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0102e7d:	89 10                	mov    %edx,(%eax)
}
c0102e7f:	90                   	nop
}
c0102e80:	90                   	nop
    while (le != &free_list) {
c0102e81:	81 7d f0 80 be 11 c0 	cmpl   $0xc011be80,-0x10(%ebp)
c0102e88:	0f 85 e5 fe ff ff    	jne    c0102d73 <default_free_pages+0x130>
        }
    }
    nr_free += n;
c0102e8e:	8b 15 88 be 11 c0    	mov    0xc011be88,%edx
c0102e94:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102e97:	01 d0                	add    %edx,%eax
c0102e99:	a3 88 be 11 c0       	mov    %eax,0xc011be88
    list_add_before(le, &(base->page_link));
c0102e9e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ea1:	8d 50 0c             	lea    0xc(%eax),%edx
c0102ea4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102ea7:	89 45 9c             	mov    %eax,-0x64(%ebp)
c0102eaa:	89 55 98             	mov    %edx,-0x68(%ebp)
    __list_add(elm, listelm->prev, listelm);
c0102ead:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0102eb0:	8b 00                	mov    (%eax),%eax
c0102eb2:	8b 55 98             	mov    -0x68(%ebp),%edx
c0102eb5:	89 55 94             	mov    %edx,-0x6c(%ebp)
c0102eb8:	89 45 90             	mov    %eax,-0x70(%ebp)
c0102ebb:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0102ebe:	89 45 8c             	mov    %eax,-0x74(%ebp)
    prev->next = next->prev = elm;
c0102ec1:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0102ec4:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0102ec7:	89 10                	mov    %edx,(%eax)
c0102ec9:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0102ecc:	8b 10                	mov    (%eax),%edx
c0102ece:	8b 45 90             	mov    -0x70(%ebp),%eax
c0102ed1:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102ed4:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0102ed7:	8b 55 8c             	mov    -0x74(%ebp),%edx
c0102eda:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102edd:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0102ee0:	8b 55 90             	mov    -0x70(%ebp),%edx
c0102ee3:	89 10                	mov    %edx,(%eax)
}
c0102ee5:	90                   	nop
}
c0102ee6:	90                   	nop
}
c0102ee7:	90                   	nop
c0102ee8:	89 ec                	mov    %ebp,%esp
c0102eea:	5d                   	pop    %ebp
c0102eeb:	c3                   	ret    

c0102eec <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0102eec:	55                   	push   %ebp
c0102eed:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0102eef:	a1 88 be 11 c0       	mov    0xc011be88,%eax
}
c0102ef4:	5d                   	pop    %ebp
c0102ef5:	c3                   	ret    

c0102ef6 <basic_check>:

static void
basic_check(void) {
c0102ef6:	55                   	push   %ebp
c0102ef7:	89 e5                	mov    %esp,%ebp
c0102ef9:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0102efc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0102f03:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102f06:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102f09:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102f0c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0102f0f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0102f16:	e8 af 0e 00 00       	call   c0103dca <alloc_pages>
c0102f1b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0102f1e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0102f22:	75 24                	jne    c0102f48 <basic_check+0x52>
c0102f24:	c7 44 24 0c 39 67 10 	movl   $0xc0106739,0xc(%esp)
c0102f2b:	c0 
c0102f2c:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0102f33:	c0 
c0102f34:	c7 44 24 04 c3 00 00 	movl   $0xc3,0x4(%esp)
c0102f3b:	00 
c0102f3c:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0102f43:	e8 93 dd ff ff       	call   c0100cdb <__panic>
    assert((p1 = alloc_page()) != NULL);
c0102f48:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0102f4f:	e8 76 0e 00 00       	call   c0103dca <alloc_pages>
c0102f54:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102f57:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0102f5b:	75 24                	jne    c0102f81 <basic_check+0x8b>
c0102f5d:	c7 44 24 0c 55 67 10 	movl   $0xc0106755,0xc(%esp)
c0102f64:	c0 
c0102f65:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0102f6c:	c0 
c0102f6d:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
c0102f74:	00 
c0102f75:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0102f7c:	e8 5a dd ff ff       	call   c0100cdb <__panic>
    assert((p2 = alloc_page()) != NULL);
c0102f81:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0102f88:	e8 3d 0e 00 00       	call   c0103dca <alloc_pages>
c0102f8d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102f90:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102f94:	75 24                	jne    c0102fba <basic_check+0xc4>
c0102f96:	c7 44 24 0c 71 67 10 	movl   $0xc0106771,0xc(%esp)
c0102f9d:	c0 
c0102f9e:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0102fa5:	c0 
c0102fa6:	c7 44 24 04 c5 00 00 	movl   $0xc5,0x4(%esp)
c0102fad:	00 
c0102fae:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0102fb5:	e8 21 dd ff ff       	call   c0100cdb <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0102fba:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102fbd:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0102fc0:	74 10                	je     c0102fd2 <basic_check+0xdc>
c0102fc2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102fc5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102fc8:	74 08                	je     c0102fd2 <basic_check+0xdc>
c0102fca:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102fcd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102fd0:	75 24                	jne    c0102ff6 <basic_check+0x100>
c0102fd2:	c7 44 24 0c 90 67 10 	movl   $0xc0106790,0xc(%esp)
c0102fd9:	c0 
c0102fda:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0102fe1:	c0 
c0102fe2:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
c0102fe9:	00 
c0102fea:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0102ff1:	e8 e5 dc ff ff       	call   c0100cdb <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0102ff6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102ff9:	89 04 24             	mov    %eax,(%esp)
c0102ffc:	e8 17 f9 ff ff       	call   c0102918 <page_ref>
c0103001:	85 c0                	test   %eax,%eax
c0103003:	75 1e                	jne    c0103023 <basic_check+0x12d>
c0103005:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103008:	89 04 24             	mov    %eax,(%esp)
c010300b:	e8 08 f9 ff ff       	call   c0102918 <page_ref>
c0103010:	85 c0                	test   %eax,%eax
c0103012:	75 0f                	jne    c0103023 <basic_check+0x12d>
c0103014:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103017:	89 04 24             	mov    %eax,(%esp)
c010301a:	e8 f9 f8 ff ff       	call   c0102918 <page_ref>
c010301f:	85 c0                	test   %eax,%eax
c0103021:	74 24                	je     c0103047 <basic_check+0x151>
c0103023:	c7 44 24 0c b4 67 10 	movl   $0xc01067b4,0xc(%esp)
c010302a:	c0 
c010302b:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0103032:	c0 
c0103033:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
c010303a:	00 
c010303b:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0103042:	e8 94 dc ff ff       	call   c0100cdb <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0103047:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010304a:	89 04 24             	mov    %eax,(%esp)
c010304d:	e8 ae f8 ff ff       	call   c0102900 <page2pa>
c0103052:	8b 15 a4 be 11 c0    	mov    0xc011bea4,%edx
c0103058:	c1 e2 0c             	shl    $0xc,%edx
c010305b:	39 d0                	cmp    %edx,%eax
c010305d:	72 24                	jb     c0103083 <basic_check+0x18d>
c010305f:	c7 44 24 0c f0 67 10 	movl   $0xc01067f0,0xc(%esp)
c0103066:	c0 
c0103067:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c010306e:	c0 
c010306f:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
c0103076:	00 
c0103077:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c010307e:	e8 58 dc ff ff       	call   c0100cdb <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0103083:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103086:	89 04 24             	mov    %eax,(%esp)
c0103089:	e8 72 f8 ff ff       	call   c0102900 <page2pa>
c010308e:	8b 15 a4 be 11 c0    	mov    0xc011bea4,%edx
c0103094:	c1 e2 0c             	shl    $0xc,%edx
c0103097:	39 d0                	cmp    %edx,%eax
c0103099:	72 24                	jb     c01030bf <basic_check+0x1c9>
c010309b:	c7 44 24 0c 0d 68 10 	movl   $0xc010680d,0xc(%esp)
c01030a2:	c0 
c01030a3:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c01030aa:	c0 
c01030ab:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c01030b2:	00 
c01030b3:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c01030ba:	e8 1c dc ff ff       	call   c0100cdb <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c01030bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01030c2:	89 04 24             	mov    %eax,(%esp)
c01030c5:	e8 36 f8 ff ff       	call   c0102900 <page2pa>
c01030ca:	8b 15 a4 be 11 c0    	mov    0xc011bea4,%edx
c01030d0:	c1 e2 0c             	shl    $0xc,%edx
c01030d3:	39 d0                	cmp    %edx,%eax
c01030d5:	72 24                	jb     c01030fb <basic_check+0x205>
c01030d7:	c7 44 24 0c 2a 68 10 	movl   $0xc010682a,0xc(%esp)
c01030de:	c0 
c01030df:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c01030e6:	c0 
c01030e7:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c01030ee:	00 
c01030ef:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c01030f6:	e8 e0 db ff ff       	call   c0100cdb <__panic>

    list_entry_t free_list_store = free_list;
c01030fb:	a1 80 be 11 c0       	mov    0xc011be80,%eax
c0103100:	8b 15 84 be 11 c0    	mov    0xc011be84,%edx
c0103106:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103109:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010310c:	c7 45 dc 80 be 11 c0 	movl   $0xc011be80,-0x24(%ebp)
    elm->prev = elm->next = elm;
c0103113:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103116:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103119:	89 50 04             	mov    %edx,0x4(%eax)
c010311c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010311f:	8b 50 04             	mov    0x4(%eax),%edx
c0103122:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103125:	89 10                	mov    %edx,(%eax)
}
c0103127:	90                   	nop
c0103128:	c7 45 e0 80 be 11 c0 	movl   $0xc011be80,-0x20(%ebp)
    return list->next == list;
c010312f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103132:	8b 40 04             	mov    0x4(%eax),%eax
c0103135:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0103138:	0f 94 c0             	sete   %al
c010313b:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c010313e:	85 c0                	test   %eax,%eax
c0103140:	75 24                	jne    c0103166 <basic_check+0x270>
c0103142:	c7 44 24 0c 47 68 10 	movl   $0xc0106847,0xc(%esp)
c0103149:	c0 
c010314a:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0103151:	c0 
c0103152:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c0103159:	00 
c010315a:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0103161:	e8 75 db ff ff       	call   c0100cdb <__panic>

    unsigned int nr_free_store = nr_free;
c0103166:	a1 88 be 11 c0       	mov    0xc011be88,%eax
c010316b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c010316e:	c7 05 88 be 11 c0 00 	movl   $0x0,0xc011be88
c0103175:	00 00 00 

    assert(alloc_page() == NULL);
c0103178:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010317f:	e8 46 0c 00 00       	call   c0103dca <alloc_pages>
c0103184:	85 c0                	test   %eax,%eax
c0103186:	74 24                	je     c01031ac <basic_check+0x2b6>
c0103188:	c7 44 24 0c 5e 68 10 	movl   $0xc010685e,0xc(%esp)
c010318f:	c0 
c0103190:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0103197:	c0 
c0103198:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
c010319f:	00 
c01031a0:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c01031a7:	e8 2f db ff ff       	call   c0100cdb <__panic>

    free_page(p0);
c01031ac:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01031b3:	00 
c01031b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01031b7:	89 04 24             	mov    %eax,(%esp)
c01031ba:	e8 45 0c 00 00       	call   c0103e04 <free_pages>
    free_page(p1);
c01031bf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01031c6:	00 
c01031c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01031ca:	89 04 24             	mov    %eax,(%esp)
c01031cd:	e8 32 0c 00 00       	call   c0103e04 <free_pages>
    free_page(p2);
c01031d2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01031d9:	00 
c01031da:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01031dd:	89 04 24             	mov    %eax,(%esp)
c01031e0:	e8 1f 0c 00 00       	call   c0103e04 <free_pages>
    assert(nr_free == 3);
c01031e5:	a1 88 be 11 c0       	mov    0xc011be88,%eax
c01031ea:	83 f8 03             	cmp    $0x3,%eax
c01031ed:	74 24                	je     c0103213 <basic_check+0x31d>
c01031ef:	c7 44 24 0c 73 68 10 	movl   $0xc0106873,0xc(%esp)
c01031f6:	c0 
c01031f7:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c01031fe:	c0 
c01031ff:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c0103206:	00 
c0103207:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c010320e:	e8 c8 da ff ff       	call   c0100cdb <__panic>

    assert((p0 = alloc_page()) != NULL);
c0103213:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010321a:	e8 ab 0b 00 00       	call   c0103dca <alloc_pages>
c010321f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103222:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103226:	75 24                	jne    c010324c <basic_check+0x356>
c0103228:	c7 44 24 0c 39 67 10 	movl   $0xc0106739,0xc(%esp)
c010322f:	c0 
c0103230:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0103237:	c0 
c0103238:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c010323f:	00 
c0103240:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0103247:	e8 8f da ff ff       	call   c0100cdb <__panic>
    assert((p1 = alloc_page()) != NULL);
c010324c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103253:	e8 72 0b 00 00       	call   c0103dca <alloc_pages>
c0103258:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010325b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010325f:	75 24                	jne    c0103285 <basic_check+0x38f>
c0103261:	c7 44 24 0c 55 67 10 	movl   $0xc0106755,0xc(%esp)
c0103268:	c0 
c0103269:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0103270:	c0 
c0103271:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
c0103278:	00 
c0103279:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0103280:	e8 56 da ff ff       	call   c0100cdb <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103285:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010328c:	e8 39 0b 00 00       	call   c0103dca <alloc_pages>
c0103291:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103294:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103298:	75 24                	jne    c01032be <basic_check+0x3c8>
c010329a:	c7 44 24 0c 71 67 10 	movl   $0xc0106771,0xc(%esp)
c01032a1:	c0 
c01032a2:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c01032a9:	c0 
c01032aa:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c01032b1:	00 
c01032b2:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c01032b9:	e8 1d da ff ff       	call   c0100cdb <__panic>

    assert(alloc_page() == NULL);
c01032be:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01032c5:	e8 00 0b 00 00       	call   c0103dca <alloc_pages>
c01032ca:	85 c0                	test   %eax,%eax
c01032cc:	74 24                	je     c01032f2 <basic_check+0x3fc>
c01032ce:	c7 44 24 0c 5e 68 10 	movl   $0xc010685e,0xc(%esp)
c01032d5:	c0 
c01032d6:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c01032dd:	c0 
c01032de:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c01032e5:	00 
c01032e6:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c01032ed:	e8 e9 d9 ff ff       	call   c0100cdb <__panic>

    free_page(p0);
c01032f2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01032f9:	00 
c01032fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01032fd:	89 04 24             	mov    %eax,(%esp)
c0103300:	e8 ff 0a 00 00       	call   c0103e04 <free_pages>
c0103305:	c7 45 d8 80 be 11 c0 	movl   $0xc011be80,-0x28(%ebp)
c010330c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010330f:	8b 40 04             	mov    0x4(%eax),%eax
c0103312:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0103315:	0f 94 c0             	sete   %al
c0103318:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c010331b:	85 c0                	test   %eax,%eax
c010331d:	74 24                	je     c0103343 <basic_check+0x44d>
c010331f:	c7 44 24 0c 80 68 10 	movl   $0xc0106880,0xc(%esp)
c0103326:	c0 
c0103327:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c010332e:	c0 
c010332f:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c0103336:	00 
c0103337:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c010333e:	e8 98 d9 ff ff       	call   c0100cdb <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0103343:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010334a:	e8 7b 0a 00 00       	call   c0103dca <alloc_pages>
c010334f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103352:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103355:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103358:	74 24                	je     c010337e <basic_check+0x488>
c010335a:	c7 44 24 0c 98 68 10 	movl   $0xc0106898,0xc(%esp)
c0103361:	c0 
c0103362:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0103369:	c0 
c010336a:	c7 44 24 04 e6 00 00 	movl   $0xe6,0x4(%esp)
c0103371:	00 
c0103372:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0103379:	e8 5d d9 ff ff       	call   c0100cdb <__panic>
    assert(alloc_page() == NULL);
c010337e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103385:	e8 40 0a 00 00       	call   c0103dca <alloc_pages>
c010338a:	85 c0                	test   %eax,%eax
c010338c:	74 24                	je     c01033b2 <basic_check+0x4bc>
c010338e:	c7 44 24 0c 5e 68 10 	movl   $0xc010685e,0xc(%esp)
c0103395:	c0 
c0103396:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c010339d:	c0 
c010339e:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c01033a5:	00 
c01033a6:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c01033ad:	e8 29 d9 ff ff       	call   c0100cdb <__panic>

    assert(nr_free == 0);
c01033b2:	a1 88 be 11 c0       	mov    0xc011be88,%eax
c01033b7:	85 c0                	test   %eax,%eax
c01033b9:	74 24                	je     c01033df <basic_check+0x4e9>
c01033bb:	c7 44 24 0c b1 68 10 	movl   $0xc01068b1,0xc(%esp)
c01033c2:	c0 
c01033c3:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c01033ca:	c0 
c01033cb:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c01033d2:	00 
c01033d3:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c01033da:	e8 fc d8 ff ff       	call   c0100cdb <__panic>
    free_list = free_list_store;
c01033df:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01033e2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01033e5:	a3 80 be 11 c0       	mov    %eax,0xc011be80
c01033ea:	89 15 84 be 11 c0    	mov    %edx,0xc011be84
    nr_free = nr_free_store;
c01033f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01033f3:	a3 88 be 11 c0       	mov    %eax,0xc011be88

    free_page(p);
c01033f8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01033ff:	00 
c0103400:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103403:	89 04 24             	mov    %eax,(%esp)
c0103406:	e8 f9 09 00 00       	call   c0103e04 <free_pages>
    free_page(p1);
c010340b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103412:	00 
c0103413:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103416:	89 04 24             	mov    %eax,(%esp)
c0103419:	e8 e6 09 00 00       	call   c0103e04 <free_pages>
    free_page(p2);
c010341e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103425:	00 
c0103426:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103429:	89 04 24             	mov    %eax,(%esp)
c010342c:	e8 d3 09 00 00       	call   c0103e04 <free_pages>
}
c0103431:	90                   	nop
c0103432:	89 ec                	mov    %ebp,%esp
c0103434:	5d                   	pop    %ebp
c0103435:	c3                   	ret    

c0103436 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0103436:	55                   	push   %ebp
c0103437:	89 e5                	mov    %esp,%ebp
c0103439:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c010343f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103446:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c010344d:	c7 45 ec 80 be 11 c0 	movl   $0xc011be80,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0103454:	eb 6a                	jmp    c01034c0 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
c0103456:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103459:	83 e8 0c             	sub    $0xc,%eax
c010345c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
c010345f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103462:	83 c0 04             	add    $0x4,%eax
c0103465:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c010346c:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010346f:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103472:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103475:	0f a3 10             	bt     %edx,(%eax)
c0103478:	19 c0                	sbb    %eax,%eax
c010347a:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c010347d:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0103481:	0f 95 c0             	setne  %al
c0103484:	0f b6 c0             	movzbl %al,%eax
c0103487:	85 c0                	test   %eax,%eax
c0103489:	75 24                	jne    c01034af <default_check+0x79>
c010348b:	c7 44 24 0c be 68 10 	movl   $0xc01068be,0xc(%esp)
c0103492:	c0 
c0103493:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c010349a:	c0 
c010349b:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c01034a2:	00 
c01034a3:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c01034aa:	e8 2c d8 ff ff       	call   c0100cdb <__panic>
        count ++, total += p->property;
c01034af:	ff 45 f4             	incl   -0xc(%ebp)
c01034b2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01034b5:	8b 50 08             	mov    0x8(%eax),%edx
c01034b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01034bb:	01 d0                	add    %edx,%eax
c01034bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01034c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01034c3:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c01034c6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01034c9:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c01034cc:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01034cf:	81 7d ec 80 be 11 c0 	cmpl   $0xc011be80,-0x14(%ebp)
c01034d6:	0f 85 7a ff ff ff    	jne    c0103456 <default_check+0x20>
    }
    assert(total == nr_free_pages());
c01034dc:	e8 58 09 00 00       	call   c0103e39 <nr_free_pages>
c01034e1:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01034e4:	39 d0                	cmp    %edx,%eax
c01034e6:	74 24                	je     c010350c <default_check+0xd6>
c01034e8:	c7 44 24 0c ce 68 10 	movl   $0xc01068ce,0xc(%esp)
c01034ef:	c0 
c01034f0:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c01034f7:	c0 
c01034f8:	c7 44 24 04 fd 00 00 	movl   $0xfd,0x4(%esp)
c01034ff:	00 
c0103500:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0103507:	e8 cf d7 ff ff       	call   c0100cdb <__panic>

    basic_check();
c010350c:	e8 e5 f9 ff ff       	call   c0102ef6 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0103511:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0103518:	e8 ad 08 00 00       	call   c0103dca <alloc_pages>
c010351d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
c0103520:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103524:	75 24                	jne    c010354a <default_check+0x114>
c0103526:	c7 44 24 0c e7 68 10 	movl   $0xc01068e7,0xc(%esp)
c010352d:	c0 
c010352e:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0103535:	c0 
c0103536:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
c010353d:	00 
c010353e:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0103545:	e8 91 d7 ff ff       	call   c0100cdb <__panic>
    assert(!PageProperty(p0));
c010354a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010354d:	83 c0 04             	add    $0x4,%eax
c0103550:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0103557:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010355a:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010355d:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0103560:	0f a3 10             	bt     %edx,(%eax)
c0103563:	19 c0                	sbb    %eax,%eax
c0103565:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0103568:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c010356c:	0f 95 c0             	setne  %al
c010356f:	0f b6 c0             	movzbl %al,%eax
c0103572:	85 c0                	test   %eax,%eax
c0103574:	74 24                	je     c010359a <default_check+0x164>
c0103576:	c7 44 24 0c f2 68 10 	movl   $0xc01068f2,0xc(%esp)
c010357d:	c0 
c010357e:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0103585:	c0 
c0103586:	c7 44 24 04 03 01 00 	movl   $0x103,0x4(%esp)
c010358d:	00 
c010358e:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0103595:	e8 41 d7 ff ff       	call   c0100cdb <__panic>

    list_entry_t free_list_store = free_list;
c010359a:	a1 80 be 11 c0       	mov    0xc011be80,%eax
c010359f:	8b 15 84 be 11 c0    	mov    0xc011be84,%edx
c01035a5:	89 45 80             	mov    %eax,-0x80(%ebp)
c01035a8:	89 55 84             	mov    %edx,-0x7c(%ebp)
c01035ab:	c7 45 b0 80 be 11 c0 	movl   $0xc011be80,-0x50(%ebp)
    elm->prev = elm->next = elm;
c01035b2:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01035b5:	8b 55 b0             	mov    -0x50(%ebp),%edx
c01035b8:	89 50 04             	mov    %edx,0x4(%eax)
c01035bb:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01035be:	8b 50 04             	mov    0x4(%eax),%edx
c01035c1:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01035c4:	89 10                	mov    %edx,(%eax)
}
c01035c6:	90                   	nop
c01035c7:	c7 45 b4 80 be 11 c0 	movl   $0xc011be80,-0x4c(%ebp)
    return list->next == list;
c01035ce:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01035d1:	8b 40 04             	mov    0x4(%eax),%eax
c01035d4:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
c01035d7:	0f 94 c0             	sete   %al
c01035da:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c01035dd:	85 c0                	test   %eax,%eax
c01035df:	75 24                	jne    c0103605 <default_check+0x1cf>
c01035e1:	c7 44 24 0c 47 68 10 	movl   $0xc0106847,0xc(%esp)
c01035e8:	c0 
c01035e9:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c01035f0:	c0 
c01035f1:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
c01035f8:	00 
c01035f9:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0103600:	e8 d6 d6 ff ff       	call   c0100cdb <__panic>
    assert(alloc_page() == NULL);
c0103605:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010360c:	e8 b9 07 00 00       	call   c0103dca <alloc_pages>
c0103611:	85 c0                	test   %eax,%eax
c0103613:	74 24                	je     c0103639 <default_check+0x203>
c0103615:	c7 44 24 0c 5e 68 10 	movl   $0xc010685e,0xc(%esp)
c010361c:	c0 
c010361d:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0103624:	c0 
c0103625:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
c010362c:	00 
c010362d:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0103634:	e8 a2 d6 ff ff       	call   c0100cdb <__panic>

    unsigned int nr_free_store = nr_free;
c0103639:	a1 88 be 11 c0       	mov    0xc011be88,%eax
c010363e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
c0103641:	c7 05 88 be 11 c0 00 	movl   $0x0,0xc011be88
c0103648:	00 00 00 

    free_pages(p0 + 2, 3);
c010364b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010364e:	83 c0 28             	add    $0x28,%eax
c0103651:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0103658:	00 
c0103659:	89 04 24             	mov    %eax,(%esp)
c010365c:	e8 a3 07 00 00       	call   c0103e04 <free_pages>
    assert(alloc_pages(4) == NULL);
c0103661:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0103668:	e8 5d 07 00 00       	call   c0103dca <alloc_pages>
c010366d:	85 c0                	test   %eax,%eax
c010366f:	74 24                	je     c0103695 <default_check+0x25f>
c0103671:	c7 44 24 0c 04 69 10 	movl   $0xc0106904,0xc(%esp)
c0103678:	c0 
c0103679:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0103680:	c0 
c0103681:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
c0103688:	00 
c0103689:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0103690:	e8 46 d6 ff ff       	call   c0100cdb <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0103695:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103698:	83 c0 28             	add    $0x28,%eax
c010369b:	83 c0 04             	add    $0x4,%eax
c010369e:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c01036a5:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01036a8:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01036ab:	8b 55 ac             	mov    -0x54(%ebp),%edx
c01036ae:	0f a3 10             	bt     %edx,(%eax)
c01036b1:	19 c0                	sbb    %eax,%eax
c01036b3:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c01036b6:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c01036ba:	0f 95 c0             	setne  %al
c01036bd:	0f b6 c0             	movzbl %al,%eax
c01036c0:	85 c0                	test   %eax,%eax
c01036c2:	74 0e                	je     c01036d2 <default_check+0x29c>
c01036c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01036c7:	83 c0 28             	add    $0x28,%eax
c01036ca:	8b 40 08             	mov    0x8(%eax),%eax
c01036cd:	83 f8 03             	cmp    $0x3,%eax
c01036d0:	74 24                	je     c01036f6 <default_check+0x2c0>
c01036d2:	c7 44 24 0c 1c 69 10 	movl   $0xc010691c,0xc(%esp)
c01036d9:	c0 
c01036da:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c01036e1:	c0 
c01036e2:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
c01036e9:	00 
c01036ea:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c01036f1:	e8 e5 d5 ff ff       	call   c0100cdb <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c01036f6:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c01036fd:	e8 c8 06 00 00       	call   c0103dca <alloc_pages>
c0103702:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103705:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0103709:	75 24                	jne    c010372f <default_check+0x2f9>
c010370b:	c7 44 24 0c 48 69 10 	movl   $0xc0106948,0xc(%esp)
c0103712:	c0 
c0103713:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c010371a:	c0 
c010371b:	c7 44 24 04 10 01 00 	movl   $0x110,0x4(%esp)
c0103722:	00 
c0103723:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c010372a:	e8 ac d5 ff ff       	call   c0100cdb <__panic>
    assert(alloc_page() == NULL);
c010372f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103736:	e8 8f 06 00 00       	call   c0103dca <alloc_pages>
c010373b:	85 c0                	test   %eax,%eax
c010373d:	74 24                	je     c0103763 <default_check+0x32d>
c010373f:	c7 44 24 0c 5e 68 10 	movl   $0xc010685e,0xc(%esp)
c0103746:	c0 
c0103747:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c010374e:	c0 
c010374f:	c7 44 24 04 11 01 00 	movl   $0x111,0x4(%esp)
c0103756:	00 
c0103757:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c010375e:	e8 78 d5 ff ff       	call   c0100cdb <__panic>
    assert(p0 + 2 == p1);
c0103763:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103766:	83 c0 28             	add    $0x28,%eax
c0103769:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c010376c:	74 24                	je     c0103792 <default_check+0x35c>
c010376e:	c7 44 24 0c 66 69 10 	movl   $0xc0106966,0xc(%esp)
c0103775:	c0 
c0103776:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c010377d:	c0 
c010377e:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
c0103785:	00 
c0103786:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c010378d:	e8 49 d5 ff ff       	call   c0100cdb <__panic>

    p2 = p0 + 1;
c0103792:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103795:	83 c0 14             	add    $0x14,%eax
c0103798:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
c010379b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01037a2:	00 
c01037a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01037a6:	89 04 24             	mov    %eax,(%esp)
c01037a9:	e8 56 06 00 00       	call   c0103e04 <free_pages>
    free_pages(p1, 3);
c01037ae:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c01037b5:	00 
c01037b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01037b9:	89 04 24             	mov    %eax,(%esp)
c01037bc:	e8 43 06 00 00       	call   c0103e04 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c01037c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01037c4:	83 c0 04             	add    $0x4,%eax
c01037c7:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c01037ce:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01037d1:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01037d4:	8b 55 a0             	mov    -0x60(%ebp),%edx
c01037d7:	0f a3 10             	bt     %edx,(%eax)
c01037da:	19 c0                	sbb    %eax,%eax
c01037dc:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c01037df:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c01037e3:	0f 95 c0             	setne  %al
c01037e6:	0f b6 c0             	movzbl %al,%eax
c01037e9:	85 c0                	test   %eax,%eax
c01037eb:	74 0b                	je     c01037f8 <default_check+0x3c2>
c01037ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01037f0:	8b 40 08             	mov    0x8(%eax),%eax
c01037f3:	83 f8 01             	cmp    $0x1,%eax
c01037f6:	74 24                	je     c010381c <default_check+0x3e6>
c01037f8:	c7 44 24 0c 74 69 10 	movl   $0xc0106974,0xc(%esp)
c01037ff:	c0 
c0103800:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0103807:	c0 
c0103808:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
c010380f:	00 
c0103810:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0103817:	e8 bf d4 ff ff       	call   c0100cdb <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c010381c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010381f:	83 c0 04             	add    $0x4,%eax
c0103822:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c0103829:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010382c:	8b 45 90             	mov    -0x70(%ebp),%eax
c010382f:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0103832:	0f a3 10             	bt     %edx,(%eax)
c0103835:	19 c0                	sbb    %eax,%eax
c0103837:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c010383a:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c010383e:	0f 95 c0             	setne  %al
c0103841:	0f b6 c0             	movzbl %al,%eax
c0103844:	85 c0                	test   %eax,%eax
c0103846:	74 0b                	je     c0103853 <default_check+0x41d>
c0103848:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010384b:	8b 40 08             	mov    0x8(%eax),%eax
c010384e:	83 f8 03             	cmp    $0x3,%eax
c0103851:	74 24                	je     c0103877 <default_check+0x441>
c0103853:	c7 44 24 0c 9c 69 10 	movl   $0xc010699c,0xc(%esp)
c010385a:	c0 
c010385b:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0103862:	c0 
c0103863:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
c010386a:	00 
c010386b:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0103872:	e8 64 d4 ff ff       	call   c0100cdb <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c0103877:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010387e:	e8 47 05 00 00       	call   c0103dca <alloc_pages>
c0103883:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103886:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103889:	83 e8 14             	sub    $0x14,%eax
c010388c:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c010388f:	74 24                	je     c01038b5 <default_check+0x47f>
c0103891:	c7 44 24 0c c2 69 10 	movl   $0xc01069c2,0xc(%esp)
c0103898:	c0 
c0103899:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c01038a0:	c0 
c01038a1:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c01038a8:	00 
c01038a9:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c01038b0:	e8 26 d4 ff ff       	call   c0100cdb <__panic>
    free_page(p0);
c01038b5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01038bc:	00 
c01038bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01038c0:	89 04 24             	mov    %eax,(%esp)
c01038c3:	e8 3c 05 00 00       	call   c0103e04 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c01038c8:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c01038cf:	e8 f6 04 00 00       	call   c0103dca <alloc_pages>
c01038d4:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01038d7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01038da:	83 c0 14             	add    $0x14,%eax
c01038dd:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01038e0:	74 24                	je     c0103906 <default_check+0x4d0>
c01038e2:	c7 44 24 0c e0 69 10 	movl   $0xc01069e0,0xc(%esp)
c01038e9:	c0 
c01038ea:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c01038f1:	c0 
c01038f2:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
c01038f9:	00 
c01038fa:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0103901:	e8 d5 d3 ff ff       	call   c0100cdb <__panic>

    free_pages(p0, 2);
c0103906:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c010390d:	00 
c010390e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103911:	89 04 24             	mov    %eax,(%esp)
c0103914:	e8 eb 04 00 00       	call   c0103e04 <free_pages>
    free_page(p2);
c0103919:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103920:	00 
c0103921:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103924:	89 04 24             	mov    %eax,(%esp)
c0103927:	e8 d8 04 00 00       	call   c0103e04 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c010392c:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0103933:	e8 92 04 00 00       	call   c0103dca <alloc_pages>
c0103938:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010393b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010393f:	75 24                	jne    c0103965 <default_check+0x52f>
c0103941:	c7 44 24 0c 00 6a 10 	movl   $0xc0106a00,0xc(%esp)
c0103948:	c0 
c0103949:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0103950:	c0 
c0103951:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
c0103958:	00 
c0103959:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0103960:	e8 76 d3 ff ff       	call   c0100cdb <__panic>
    assert(alloc_page() == NULL);
c0103965:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010396c:	e8 59 04 00 00       	call   c0103dca <alloc_pages>
c0103971:	85 c0                	test   %eax,%eax
c0103973:	74 24                	je     c0103999 <default_check+0x563>
c0103975:	c7 44 24 0c 5e 68 10 	movl   $0xc010685e,0xc(%esp)
c010397c:	c0 
c010397d:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0103984:	c0 
c0103985:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
c010398c:	00 
c010398d:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0103994:	e8 42 d3 ff ff       	call   c0100cdb <__panic>

    assert(nr_free == 0);
c0103999:	a1 88 be 11 c0       	mov    0xc011be88,%eax
c010399e:	85 c0                	test   %eax,%eax
c01039a0:	74 24                	je     c01039c6 <default_check+0x590>
c01039a2:	c7 44 24 0c b1 68 10 	movl   $0xc01068b1,0xc(%esp)
c01039a9:	c0 
c01039aa:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c01039b1:	c0 
c01039b2:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
c01039b9:	00 
c01039ba:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c01039c1:	e8 15 d3 ff ff       	call   c0100cdb <__panic>
    nr_free = nr_free_store;
c01039c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01039c9:	a3 88 be 11 c0       	mov    %eax,0xc011be88

    free_list = free_list_store;
c01039ce:	8b 45 80             	mov    -0x80(%ebp),%eax
c01039d1:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01039d4:	a3 80 be 11 c0       	mov    %eax,0xc011be80
c01039d9:	89 15 84 be 11 c0    	mov    %edx,0xc011be84
    free_pages(p0, 5);
c01039df:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c01039e6:	00 
c01039e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01039ea:	89 04 24             	mov    %eax,(%esp)
c01039ed:	e8 12 04 00 00       	call   c0103e04 <free_pages>

    le = &free_list;
c01039f2:	c7 45 ec 80 be 11 c0 	movl   $0xc011be80,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01039f9:	eb 1c                	jmp    c0103a17 <default_check+0x5e1>
        struct Page *p = le2page(le, page_link);
c01039fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01039fe:	83 e8 0c             	sub    $0xc,%eax
c0103a01:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
c0103a04:	ff 4d f4             	decl   -0xc(%ebp)
c0103a07:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0103a0a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103a0d:	8b 48 08             	mov    0x8(%eax),%ecx
c0103a10:	89 d0                	mov    %edx,%eax
c0103a12:	29 c8                	sub    %ecx,%eax
c0103a14:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103a17:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103a1a:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c0103a1d:	8b 45 88             	mov    -0x78(%ebp),%eax
c0103a20:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0103a23:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103a26:	81 7d ec 80 be 11 c0 	cmpl   $0xc011be80,-0x14(%ebp)
c0103a2d:	75 cc                	jne    c01039fb <default_check+0x5c5>
    }
    assert(count == 0);
c0103a2f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103a33:	74 24                	je     c0103a59 <default_check+0x623>
c0103a35:	c7 44 24 0c 1e 6a 10 	movl   $0xc0106a1e,0xc(%esp)
c0103a3c:	c0 
c0103a3d:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0103a44:	c0 
c0103a45:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
c0103a4c:	00 
c0103a4d:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0103a54:	e8 82 d2 ff ff       	call   c0100cdb <__panic>
    assert(total == 0);
c0103a59:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103a5d:	74 24                	je     c0103a83 <default_check+0x64d>
c0103a5f:	c7 44 24 0c 29 6a 10 	movl   $0xc0106a29,0xc(%esp)
c0103a66:	c0 
c0103a67:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0103a6e:	c0 
c0103a6f:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
c0103a76:	00 
c0103a77:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0103a7e:	e8 58 d2 ff ff       	call   c0100cdb <__panic>
}
c0103a83:	90                   	nop
c0103a84:	89 ec                	mov    %ebp,%esp
c0103a86:	5d                   	pop    %ebp
c0103a87:	c3                   	ret    

c0103a88 <page2ppn>:
page2ppn(struct Page *page) {
c0103a88:	55                   	push   %ebp
c0103a89:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0103a8b:	8b 15 a0 be 11 c0    	mov    0xc011bea0,%edx
c0103a91:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a94:	29 d0                	sub    %edx,%eax
c0103a96:	c1 f8 02             	sar    $0x2,%eax
c0103a99:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0103a9f:	5d                   	pop    %ebp
c0103aa0:	c3                   	ret    

c0103aa1 <page2pa>:
page2pa(struct Page *page) {
c0103aa1:	55                   	push   %ebp
c0103aa2:	89 e5                	mov    %esp,%ebp
c0103aa4:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0103aa7:	8b 45 08             	mov    0x8(%ebp),%eax
c0103aaa:	89 04 24             	mov    %eax,(%esp)
c0103aad:	e8 d6 ff ff ff       	call   c0103a88 <page2ppn>
c0103ab2:	c1 e0 0c             	shl    $0xc,%eax
}
c0103ab5:	89 ec                	mov    %ebp,%esp
c0103ab7:	5d                   	pop    %ebp
c0103ab8:	c3                   	ret    

c0103ab9 <pa2page>:
pa2page(uintptr_t pa) {
c0103ab9:	55                   	push   %ebp
c0103aba:	89 e5                	mov    %esp,%ebp
c0103abc:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0103abf:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ac2:	c1 e8 0c             	shr    $0xc,%eax
c0103ac5:	89 c2                	mov    %eax,%edx
c0103ac7:	a1 a4 be 11 c0       	mov    0xc011bea4,%eax
c0103acc:	39 c2                	cmp    %eax,%edx
c0103ace:	72 1c                	jb     c0103aec <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0103ad0:	c7 44 24 08 64 6a 10 	movl   $0xc0106a64,0x8(%esp)
c0103ad7:	c0 
c0103ad8:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c0103adf:	00 
c0103ae0:	c7 04 24 83 6a 10 c0 	movl   $0xc0106a83,(%esp)
c0103ae7:	e8 ef d1 ff ff       	call   c0100cdb <__panic>
    return &pages[PPN(pa)];
c0103aec:	8b 0d a0 be 11 c0    	mov    0xc011bea0,%ecx
c0103af2:	8b 45 08             	mov    0x8(%ebp),%eax
c0103af5:	c1 e8 0c             	shr    $0xc,%eax
c0103af8:	89 c2                	mov    %eax,%edx
c0103afa:	89 d0                	mov    %edx,%eax
c0103afc:	c1 e0 02             	shl    $0x2,%eax
c0103aff:	01 d0                	add    %edx,%eax
c0103b01:	c1 e0 02             	shl    $0x2,%eax
c0103b04:	01 c8                	add    %ecx,%eax
}
c0103b06:	89 ec                	mov    %ebp,%esp
c0103b08:	5d                   	pop    %ebp
c0103b09:	c3                   	ret    

c0103b0a <page2kva>:
page2kva(struct Page *page) {
c0103b0a:	55                   	push   %ebp
c0103b0b:	89 e5                	mov    %esp,%ebp
c0103b0d:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0103b10:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b13:	89 04 24             	mov    %eax,(%esp)
c0103b16:	e8 86 ff ff ff       	call   c0103aa1 <page2pa>
c0103b1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103b1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b21:	c1 e8 0c             	shr    $0xc,%eax
c0103b24:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103b27:	a1 a4 be 11 c0       	mov    0xc011bea4,%eax
c0103b2c:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0103b2f:	72 23                	jb     c0103b54 <page2kva+0x4a>
c0103b31:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b34:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103b38:	c7 44 24 08 94 6a 10 	movl   $0xc0106a94,0x8(%esp)
c0103b3f:	c0 
c0103b40:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c0103b47:	00 
c0103b48:	c7 04 24 83 6a 10 c0 	movl   $0xc0106a83,(%esp)
c0103b4f:	e8 87 d1 ff ff       	call   c0100cdb <__panic>
c0103b54:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b57:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0103b5c:	89 ec                	mov    %ebp,%esp
c0103b5e:	5d                   	pop    %ebp
c0103b5f:	c3                   	ret    

c0103b60 <pte2page>:
pte2page(pte_t pte) {
c0103b60:	55                   	push   %ebp
c0103b61:	89 e5                	mov    %esp,%ebp
c0103b63:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0103b66:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b69:	83 e0 01             	and    $0x1,%eax
c0103b6c:	85 c0                	test   %eax,%eax
c0103b6e:	75 1c                	jne    c0103b8c <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0103b70:	c7 44 24 08 b8 6a 10 	movl   $0xc0106ab8,0x8(%esp)
c0103b77:	c0 
c0103b78:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c0103b7f:	00 
c0103b80:	c7 04 24 83 6a 10 c0 	movl   $0xc0106a83,(%esp)
c0103b87:	e8 4f d1 ff ff       	call   c0100cdb <__panic>
    return pa2page(PTE_ADDR(pte));
c0103b8c:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b8f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103b94:	89 04 24             	mov    %eax,(%esp)
c0103b97:	e8 1d ff ff ff       	call   c0103ab9 <pa2page>
}
c0103b9c:	89 ec                	mov    %ebp,%esp
c0103b9e:	5d                   	pop    %ebp
c0103b9f:	c3                   	ret    

c0103ba0 <pde2page>:
pde2page(pde_t pde) {
c0103ba0:	55                   	push   %ebp
c0103ba1:	89 e5                	mov    %esp,%ebp
c0103ba3:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0103ba6:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ba9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103bae:	89 04 24             	mov    %eax,(%esp)
c0103bb1:	e8 03 ff ff ff       	call   c0103ab9 <pa2page>
}
c0103bb6:	89 ec                	mov    %ebp,%esp
c0103bb8:	5d                   	pop    %ebp
c0103bb9:	c3                   	ret    

c0103bba <page_ref>:
page_ref(struct Page *page) {
c0103bba:	55                   	push   %ebp
c0103bbb:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0103bbd:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bc0:	8b 00                	mov    (%eax),%eax
}
c0103bc2:	5d                   	pop    %ebp
c0103bc3:	c3                   	ret    

c0103bc4 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c0103bc4:	55                   	push   %ebp
c0103bc5:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0103bc7:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bca:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103bcd:	89 10                	mov    %edx,(%eax)
}
c0103bcf:	90                   	nop
c0103bd0:	5d                   	pop    %ebp
c0103bd1:	c3                   	ret    

c0103bd2 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0103bd2:	55                   	push   %ebp
c0103bd3:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0103bd5:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bd8:	8b 00                	mov    (%eax),%eax
c0103bda:	8d 50 01             	lea    0x1(%eax),%edx
c0103bdd:	8b 45 08             	mov    0x8(%ebp),%eax
c0103be0:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0103be2:	8b 45 08             	mov    0x8(%ebp),%eax
c0103be5:	8b 00                	mov    (%eax),%eax
}
c0103be7:	5d                   	pop    %ebp
c0103be8:	c3                   	ret    

c0103be9 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0103be9:	55                   	push   %ebp
c0103bea:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0103bec:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bef:	8b 00                	mov    (%eax),%eax
c0103bf1:	8d 50 ff             	lea    -0x1(%eax),%edx
c0103bf4:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bf7:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0103bf9:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bfc:	8b 00                	mov    (%eax),%eax
}
c0103bfe:	5d                   	pop    %ebp
c0103bff:	c3                   	ret    

c0103c00 <__intr_save>:
__intr_save(void) {
c0103c00:	55                   	push   %ebp
c0103c01:	89 e5                	mov    %esp,%ebp
c0103c03:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0103c06:	9c                   	pushf  
c0103c07:	58                   	pop    %eax
c0103c08:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0103c0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0103c0e:	25 00 02 00 00       	and    $0x200,%eax
c0103c13:	85 c0                	test   %eax,%eax
c0103c15:	74 0c                	je     c0103c23 <__intr_save+0x23>
        intr_disable();
c0103c17:	e8 18 db ff ff       	call   c0101734 <intr_disable>
        return 1;
c0103c1c:	b8 01 00 00 00       	mov    $0x1,%eax
c0103c21:	eb 05                	jmp    c0103c28 <__intr_save+0x28>
    return 0;
c0103c23:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103c28:	89 ec                	mov    %ebp,%esp
c0103c2a:	5d                   	pop    %ebp
c0103c2b:	c3                   	ret    

c0103c2c <__intr_restore>:
__intr_restore(bool flag) {
c0103c2c:	55                   	push   %ebp
c0103c2d:	89 e5                	mov    %esp,%ebp
c0103c2f:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0103c32:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0103c36:	74 05                	je     c0103c3d <__intr_restore+0x11>
        intr_enable();
c0103c38:	e8 ef da ff ff       	call   c010172c <intr_enable>
}
c0103c3d:	90                   	nop
c0103c3e:	89 ec                	mov    %ebp,%esp
c0103c40:	5d                   	pop    %ebp
c0103c41:	c3                   	ret    

c0103c42 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0103c42:	55                   	push   %ebp
c0103c43:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0103c45:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c48:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0103c4b:	b8 23 00 00 00       	mov    $0x23,%eax
c0103c50:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0103c52:	b8 23 00 00 00       	mov    $0x23,%eax
c0103c57:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0103c59:	b8 10 00 00 00       	mov    $0x10,%eax
c0103c5e:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0103c60:	b8 10 00 00 00       	mov    $0x10,%eax
c0103c65:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0103c67:	b8 10 00 00 00       	mov    $0x10,%eax
c0103c6c:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0103c6e:	ea 75 3c 10 c0 08 00 	ljmp   $0x8,$0xc0103c75
}
c0103c75:	90                   	nop
c0103c76:	5d                   	pop    %ebp
c0103c77:	c3                   	ret    

c0103c78 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0103c78:	55                   	push   %ebp
c0103c79:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0103c7b:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c7e:	a3 c4 be 11 c0       	mov    %eax,0xc011bec4
}
c0103c83:	90                   	nop
c0103c84:	5d                   	pop    %ebp
c0103c85:	c3                   	ret    

c0103c86 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0103c86:	55                   	push   %ebp
c0103c87:	89 e5                	mov    %esp,%ebp
c0103c89:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0103c8c:	b8 00 80 11 c0       	mov    $0xc0118000,%eax
c0103c91:	89 04 24             	mov    %eax,(%esp)
c0103c94:	e8 df ff ff ff       	call   c0103c78 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0103c99:	66 c7 05 c8 be 11 c0 	movw   $0x10,0xc011bec8
c0103ca0:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0103ca2:	66 c7 05 28 8a 11 c0 	movw   $0x68,0xc0118a28
c0103ca9:	68 00 
c0103cab:	b8 c0 be 11 c0       	mov    $0xc011bec0,%eax
c0103cb0:	0f b7 c0             	movzwl %ax,%eax
c0103cb3:	66 a3 2a 8a 11 c0    	mov    %ax,0xc0118a2a
c0103cb9:	b8 c0 be 11 c0       	mov    $0xc011bec0,%eax
c0103cbe:	c1 e8 10             	shr    $0x10,%eax
c0103cc1:	a2 2c 8a 11 c0       	mov    %al,0xc0118a2c
c0103cc6:	0f b6 05 2d 8a 11 c0 	movzbl 0xc0118a2d,%eax
c0103ccd:	24 f0                	and    $0xf0,%al
c0103ccf:	0c 09                	or     $0x9,%al
c0103cd1:	a2 2d 8a 11 c0       	mov    %al,0xc0118a2d
c0103cd6:	0f b6 05 2d 8a 11 c0 	movzbl 0xc0118a2d,%eax
c0103cdd:	24 ef                	and    $0xef,%al
c0103cdf:	a2 2d 8a 11 c0       	mov    %al,0xc0118a2d
c0103ce4:	0f b6 05 2d 8a 11 c0 	movzbl 0xc0118a2d,%eax
c0103ceb:	24 9f                	and    $0x9f,%al
c0103ced:	a2 2d 8a 11 c0       	mov    %al,0xc0118a2d
c0103cf2:	0f b6 05 2d 8a 11 c0 	movzbl 0xc0118a2d,%eax
c0103cf9:	0c 80                	or     $0x80,%al
c0103cfb:	a2 2d 8a 11 c0       	mov    %al,0xc0118a2d
c0103d00:	0f b6 05 2e 8a 11 c0 	movzbl 0xc0118a2e,%eax
c0103d07:	24 f0                	and    $0xf0,%al
c0103d09:	a2 2e 8a 11 c0       	mov    %al,0xc0118a2e
c0103d0e:	0f b6 05 2e 8a 11 c0 	movzbl 0xc0118a2e,%eax
c0103d15:	24 ef                	and    $0xef,%al
c0103d17:	a2 2e 8a 11 c0       	mov    %al,0xc0118a2e
c0103d1c:	0f b6 05 2e 8a 11 c0 	movzbl 0xc0118a2e,%eax
c0103d23:	24 df                	and    $0xdf,%al
c0103d25:	a2 2e 8a 11 c0       	mov    %al,0xc0118a2e
c0103d2a:	0f b6 05 2e 8a 11 c0 	movzbl 0xc0118a2e,%eax
c0103d31:	0c 40                	or     $0x40,%al
c0103d33:	a2 2e 8a 11 c0       	mov    %al,0xc0118a2e
c0103d38:	0f b6 05 2e 8a 11 c0 	movzbl 0xc0118a2e,%eax
c0103d3f:	24 7f                	and    $0x7f,%al
c0103d41:	a2 2e 8a 11 c0       	mov    %al,0xc0118a2e
c0103d46:	b8 c0 be 11 c0       	mov    $0xc011bec0,%eax
c0103d4b:	c1 e8 18             	shr    $0x18,%eax
c0103d4e:	a2 2f 8a 11 c0       	mov    %al,0xc0118a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0103d53:	c7 04 24 30 8a 11 c0 	movl   $0xc0118a30,(%esp)
c0103d5a:	e8 e3 fe ff ff       	call   c0103c42 <lgdt>
c0103d5f:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0103d65:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0103d69:	0f 00 d8             	ltr    %ax
}
c0103d6c:	90                   	nop

    // load the TSS
    ltr(GD_TSS);
}
c0103d6d:	90                   	nop
c0103d6e:	89 ec                	mov    %ebp,%esp
c0103d70:	5d                   	pop    %ebp
c0103d71:	c3                   	ret    

c0103d72 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0103d72:	55                   	push   %ebp
c0103d73:	89 e5                	mov    %esp,%ebp
c0103d75:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0103d78:	c7 05 ac be 11 c0 48 	movl   $0xc0106a48,0xc011beac
c0103d7f:	6a 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0103d82:	a1 ac be 11 c0       	mov    0xc011beac,%eax
c0103d87:	8b 00                	mov    (%eax),%eax
c0103d89:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103d8d:	c7 04 24 e4 6a 10 c0 	movl   $0xc0106ae4,(%esp)
c0103d94:	e8 bd c5 ff ff       	call   c0100356 <cprintf>
    pmm_manager->init();
c0103d99:	a1 ac be 11 c0       	mov    0xc011beac,%eax
c0103d9e:	8b 40 04             	mov    0x4(%eax),%eax
c0103da1:	ff d0                	call   *%eax
}
c0103da3:	90                   	nop
c0103da4:	89 ec                	mov    %ebp,%esp
c0103da6:	5d                   	pop    %ebp
c0103da7:	c3                   	ret    

c0103da8 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0103da8:	55                   	push   %ebp
c0103da9:	89 e5                	mov    %esp,%ebp
c0103dab:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0103dae:	a1 ac be 11 c0       	mov    0xc011beac,%eax
c0103db3:	8b 40 08             	mov    0x8(%eax),%eax
c0103db6:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103db9:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103dbd:	8b 55 08             	mov    0x8(%ebp),%edx
c0103dc0:	89 14 24             	mov    %edx,(%esp)
c0103dc3:	ff d0                	call   *%eax
}
c0103dc5:	90                   	nop
c0103dc6:	89 ec                	mov    %ebp,%esp
c0103dc8:	5d                   	pop    %ebp
c0103dc9:	c3                   	ret    

c0103dca <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0103dca:	55                   	push   %ebp
c0103dcb:	89 e5                	mov    %esp,%ebp
c0103dcd:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0103dd0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0103dd7:	e8 24 fe ff ff       	call   c0103c00 <__intr_save>
c0103ddc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
c0103ddf:	a1 ac be 11 c0       	mov    0xc011beac,%eax
c0103de4:	8b 40 0c             	mov    0xc(%eax),%eax
c0103de7:	8b 55 08             	mov    0x8(%ebp),%edx
c0103dea:	89 14 24             	mov    %edx,(%esp)
c0103ded:	ff d0                	call   *%eax
c0103def:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
c0103df2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103df5:	89 04 24             	mov    %eax,(%esp)
c0103df8:	e8 2f fe ff ff       	call   c0103c2c <__intr_restore>
    return page;
c0103dfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103e00:	89 ec                	mov    %ebp,%esp
c0103e02:	5d                   	pop    %ebp
c0103e03:	c3                   	ret    

c0103e04 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0103e04:	55                   	push   %ebp
c0103e05:	89 e5                	mov    %esp,%ebp
c0103e07:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0103e0a:	e8 f1 fd ff ff       	call   c0103c00 <__intr_save>
c0103e0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0103e12:	a1 ac be 11 c0       	mov    0xc011beac,%eax
c0103e17:	8b 40 10             	mov    0x10(%eax),%eax
c0103e1a:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103e1d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103e21:	8b 55 08             	mov    0x8(%ebp),%edx
c0103e24:	89 14 24             	mov    %edx,(%esp)
c0103e27:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0103e29:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103e2c:	89 04 24             	mov    %eax,(%esp)
c0103e2f:	e8 f8 fd ff ff       	call   c0103c2c <__intr_restore>
}
c0103e34:	90                   	nop
c0103e35:	89 ec                	mov    %ebp,%esp
c0103e37:	5d                   	pop    %ebp
c0103e38:	c3                   	ret    

c0103e39 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0103e39:	55                   	push   %ebp
c0103e3a:	89 e5                	mov    %esp,%ebp
c0103e3c:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0103e3f:	e8 bc fd ff ff       	call   c0103c00 <__intr_save>
c0103e44:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0103e47:	a1 ac be 11 c0       	mov    0xc011beac,%eax
c0103e4c:	8b 40 14             	mov    0x14(%eax),%eax
c0103e4f:	ff d0                	call   *%eax
c0103e51:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0103e54:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103e57:	89 04 24             	mov    %eax,(%esp)
c0103e5a:	e8 cd fd ff ff       	call   c0103c2c <__intr_restore>
    return ret;
c0103e5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0103e62:	89 ec                	mov    %ebp,%esp
c0103e64:	5d                   	pop    %ebp
c0103e65:	c3                   	ret    

c0103e66 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0103e66:	55                   	push   %ebp
c0103e67:	89 e5                	mov    %esp,%ebp
c0103e69:	57                   	push   %edi
c0103e6a:	56                   	push   %esi
c0103e6b:	53                   	push   %ebx
c0103e6c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0103e72:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0103e79:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0103e80:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0103e87:	c7 04 24 fb 6a 10 c0 	movl   $0xc0106afb,(%esp)
c0103e8e:	e8 c3 c4 ff ff       	call   c0100356 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0103e93:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0103e9a:	e9 0c 01 00 00       	jmp    c0103fab <page_init+0x145>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0103e9f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103ea2:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103ea5:	89 d0                	mov    %edx,%eax
c0103ea7:	c1 e0 02             	shl    $0x2,%eax
c0103eaa:	01 d0                	add    %edx,%eax
c0103eac:	c1 e0 02             	shl    $0x2,%eax
c0103eaf:	01 c8                	add    %ecx,%eax
c0103eb1:	8b 50 08             	mov    0x8(%eax),%edx
c0103eb4:	8b 40 04             	mov    0x4(%eax),%eax
c0103eb7:	89 45 a0             	mov    %eax,-0x60(%ebp)
c0103eba:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c0103ebd:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103ec0:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103ec3:	89 d0                	mov    %edx,%eax
c0103ec5:	c1 e0 02             	shl    $0x2,%eax
c0103ec8:	01 d0                	add    %edx,%eax
c0103eca:	c1 e0 02             	shl    $0x2,%eax
c0103ecd:	01 c8                	add    %ecx,%eax
c0103ecf:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103ed2:	8b 58 10             	mov    0x10(%eax),%ebx
c0103ed5:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0103ed8:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0103edb:	01 c8                	add    %ecx,%eax
c0103edd:	11 da                	adc    %ebx,%edx
c0103edf:	89 45 98             	mov    %eax,-0x68(%ebp)
c0103ee2:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0103ee5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103ee8:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103eeb:	89 d0                	mov    %edx,%eax
c0103eed:	c1 e0 02             	shl    $0x2,%eax
c0103ef0:	01 d0                	add    %edx,%eax
c0103ef2:	c1 e0 02             	shl    $0x2,%eax
c0103ef5:	01 c8                	add    %ecx,%eax
c0103ef7:	83 c0 14             	add    $0x14,%eax
c0103efa:	8b 00                	mov    (%eax),%eax
c0103efc:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c0103f02:	8b 45 98             	mov    -0x68(%ebp),%eax
c0103f05:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0103f08:	83 c0 ff             	add    $0xffffffff,%eax
c0103f0b:	83 d2 ff             	adc    $0xffffffff,%edx
c0103f0e:	89 c6                	mov    %eax,%esi
c0103f10:	89 d7                	mov    %edx,%edi
c0103f12:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103f15:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103f18:	89 d0                	mov    %edx,%eax
c0103f1a:	c1 e0 02             	shl    $0x2,%eax
c0103f1d:	01 d0                	add    %edx,%eax
c0103f1f:	c1 e0 02             	shl    $0x2,%eax
c0103f22:	01 c8                	add    %ecx,%eax
c0103f24:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103f27:	8b 58 10             	mov    0x10(%eax),%ebx
c0103f2a:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0103f30:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c0103f34:	89 74 24 14          	mov    %esi,0x14(%esp)
c0103f38:	89 7c 24 18          	mov    %edi,0x18(%esp)
c0103f3c:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0103f3f:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0103f42:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103f46:	89 54 24 10          	mov    %edx,0x10(%esp)
c0103f4a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0103f4e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0103f52:	c7 04 24 08 6b 10 c0 	movl   $0xc0106b08,(%esp)
c0103f59:	e8 f8 c3 ff ff       	call   c0100356 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0103f5e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103f61:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103f64:	89 d0                	mov    %edx,%eax
c0103f66:	c1 e0 02             	shl    $0x2,%eax
c0103f69:	01 d0                	add    %edx,%eax
c0103f6b:	c1 e0 02             	shl    $0x2,%eax
c0103f6e:	01 c8                	add    %ecx,%eax
c0103f70:	83 c0 14             	add    $0x14,%eax
c0103f73:	8b 00                	mov    (%eax),%eax
c0103f75:	83 f8 01             	cmp    $0x1,%eax
c0103f78:	75 2e                	jne    c0103fa8 <page_init+0x142>
            if (maxpa < end && begin < KMEMSIZE) {
c0103f7a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103f7d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103f80:	3b 45 98             	cmp    -0x68(%ebp),%eax
c0103f83:	89 d0                	mov    %edx,%eax
c0103f85:	1b 45 9c             	sbb    -0x64(%ebp),%eax
c0103f88:	73 1e                	jae    c0103fa8 <page_init+0x142>
c0103f8a:	ba ff ff ff 37       	mov    $0x37ffffff,%edx
c0103f8f:	b8 00 00 00 00       	mov    $0x0,%eax
c0103f94:	3b 55 a0             	cmp    -0x60(%ebp),%edx
c0103f97:	1b 45 a4             	sbb    -0x5c(%ebp),%eax
c0103f9a:	72 0c                	jb     c0103fa8 <page_init+0x142>
                maxpa = end;
c0103f9c:	8b 45 98             	mov    -0x68(%ebp),%eax
c0103f9f:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0103fa2:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103fa5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
c0103fa8:	ff 45 dc             	incl   -0x24(%ebp)
c0103fab:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103fae:	8b 00                	mov    (%eax),%eax
c0103fb0:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0103fb3:	0f 8c e6 fe ff ff    	jl     c0103e9f <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0103fb9:	ba 00 00 00 38       	mov    $0x38000000,%edx
c0103fbe:	b8 00 00 00 00       	mov    $0x0,%eax
c0103fc3:	3b 55 e0             	cmp    -0x20(%ebp),%edx
c0103fc6:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
c0103fc9:	73 0e                	jae    c0103fd9 <page_init+0x173>
        maxpa = KMEMSIZE;
c0103fcb:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0103fd2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0103fd9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103fdc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103fdf:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0103fe3:	c1 ea 0c             	shr    $0xc,%edx
c0103fe6:	a3 a4 be 11 c0       	mov    %eax,0xc011bea4
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0103feb:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
c0103ff2:	b8 2c bf 11 c0       	mov    $0xc011bf2c,%eax
c0103ff7:	8d 50 ff             	lea    -0x1(%eax),%edx
c0103ffa:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0103ffd:	01 d0                	add    %edx,%eax
c0103fff:	89 45 bc             	mov    %eax,-0x44(%ebp)
c0104002:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104005:	ba 00 00 00 00       	mov    $0x0,%edx
c010400a:	f7 75 c0             	divl   -0x40(%ebp)
c010400d:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104010:	29 d0                	sub    %edx,%eax
c0104012:	a3 a0 be 11 c0       	mov    %eax,0xc011bea0

    for (i = 0; i < npage; i ++) {
c0104017:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010401e:	eb 2f                	jmp    c010404f <page_init+0x1e9>
        SetPageReserved(pages + i);
c0104020:	8b 0d a0 be 11 c0    	mov    0xc011bea0,%ecx
c0104026:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104029:	89 d0                	mov    %edx,%eax
c010402b:	c1 e0 02             	shl    $0x2,%eax
c010402e:	01 d0                	add    %edx,%eax
c0104030:	c1 e0 02             	shl    $0x2,%eax
c0104033:	01 c8                	add    %ecx,%eax
c0104035:	83 c0 04             	add    $0x4,%eax
c0104038:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
c010403f:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104042:	8b 45 90             	mov    -0x70(%ebp),%eax
c0104045:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0104048:	0f ab 10             	bts    %edx,(%eax)
}
c010404b:	90                   	nop
    for (i = 0; i < npage; i ++) {
c010404c:	ff 45 dc             	incl   -0x24(%ebp)
c010404f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104052:	a1 a4 be 11 c0       	mov    0xc011bea4,%eax
c0104057:	39 c2                	cmp    %eax,%edx
c0104059:	72 c5                	jb     c0104020 <page_init+0x1ba>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c010405b:	8b 15 a4 be 11 c0    	mov    0xc011bea4,%edx
c0104061:	89 d0                	mov    %edx,%eax
c0104063:	c1 e0 02             	shl    $0x2,%eax
c0104066:	01 d0                	add    %edx,%eax
c0104068:	c1 e0 02             	shl    $0x2,%eax
c010406b:	89 c2                	mov    %eax,%edx
c010406d:	a1 a0 be 11 c0       	mov    0xc011bea0,%eax
c0104072:	01 d0                	add    %edx,%eax
c0104074:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0104077:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c010407e:	77 23                	ja     c01040a3 <page_init+0x23d>
c0104080:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104083:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104087:	c7 44 24 08 38 6b 10 	movl   $0xc0106b38,0x8(%esp)
c010408e:	c0 
c010408f:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c0104096:	00 
c0104097:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c010409e:	e8 38 cc ff ff       	call   c0100cdb <__panic>
c01040a3:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01040a6:	05 00 00 00 40       	add    $0x40000000,%eax
c01040ab:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c01040ae:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01040b5:	e9 53 01 00 00       	jmp    c010420d <page_init+0x3a7>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c01040ba:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01040bd:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01040c0:	89 d0                	mov    %edx,%eax
c01040c2:	c1 e0 02             	shl    $0x2,%eax
c01040c5:	01 d0                	add    %edx,%eax
c01040c7:	c1 e0 02             	shl    $0x2,%eax
c01040ca:	01 c8                	add    %ecx,%eax
c01040cc:	8b 50 08             	mov    0x8(%eax),%edx
c01040cf:	8b 40 04             	mov    0x4(%eax),%eax
c01040d2:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01040d5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01040d8:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01040db:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01040de:	89 d0                	mov    %edx,%eax
c01040e0:	c1 e0 02             	shl    $0x2,%eax
c01040e3:	01 d0                	add    %edx,%eax
c01040e5:	c1 e0 02             	shl    $0x2,%eax
c01040e8:	01 c8                	add    %ecx,%eax
c01040ea:	8b 48 0c             	mov    0xc(%eax),%ecx
c01040ed:	8b 58 10             	mov    0x10(%eax),%ebx
c01040f0:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01040f3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01040f6:	01 c8                	add    %ecx,%eax
c01040f8:	11 da                	adc    %ebx,%edx
c01040fa:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01040fd:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0104100:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104103:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104106:	89 d0                	mov    %edx,%eax
c0104108:	c1 e0 02             	shl    $0x2,%eax
c010410b:	01 d0                	add    %edx,%eax
c010410d:	c1 e0 02             	shl    $0x2,%eax
c0104110:	01 c8                	add    %ecx,%eax
c0104112:	83 c0 14             	add    $0x14,%eax
c0104115:	8b 00                	mov    (%eax),%eax
c0104117:	83 f8 01             	cmp    $0x1,%eax
c010411a:	0f 85 ea 00 00 00    	jne    c010420a <page_init+0x3a4>
            if (begin < freemem) {
c0104120:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104123:	ba 00 00 00 00       	mov    $0x0,%edx
c0104128:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c010412b:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c010412e:	19 d1                	sbb    %edx,%ecx
c0104130:	73 0d                	jae    c010413f <page_init+0x2d9>
                begin = freemem;
c0104132:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104135:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104138:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c010413f:	ba 00 00 00 38       	mov    $0x38000000,%edx
c0104144:	b8 00 00 00 00       	mov    $0x0,%eax
c0104149:	3b 55 c8             	cmp    -0x38(%ebp),%edx
c010414c:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c010414f:	73 0e                	jae    c010415f <page_init+0x2f9>
                end = KMEMSIZE;
c0104151:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0104158:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c010415f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104162:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104165:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0104168:	89 d0                	mov    %edx,%eax
c010416a:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c010416d:	0f 83 97 00 00 00    	jae    c010420a <page_init+0x3a4>
                begin = ROUNDUP(begin, PGSIZE);
c0104173:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
c010417a:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010417d:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104180:	01 d0                	add    %edx,%eax
c0104182:	48                   	dec    %eax
c0104183:	89 45 ac             	mov    %eax,-0x54(%ebp)
c0104186:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0104189:	ba 00 00 00 00       	mov    $0x0,%edx
c010418e:	f7 75 b0             	divl   -0x50(%ebp)
c0104191:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0104194:	29 d0                	sub    %edx,%eax
c0104196:	ba 00 00 00 00       	mov    $0x0,%edx
c010419b:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010419e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c01041a1:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01041a4:	89 45 a8             	mov    %eax,-0x58(%ebp)
c01041a7:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01041aa:	ba 00 00 00 00       	mov    $0x0,%edx
c01041af:	89 c7                	mov    %eax,%edi
c01041b1:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c01041b7:	89 7d 80             	mov    %edi,-0x80(%ebp)
c01041ba:	89 d0                	mov    %edx,%eax
c01041bc:	83 e0 00             	and    $0x0,%eax
c01041bf:	89 45 84             	mov    %eax,-0x7c(%ebp)
c01041c2:	8b 45 80             	mov    -0x80(%ebp),%eax
c01041c5:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01041c8:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01041cb:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c01041ce:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01041d1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01041d4:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c01041d7:	89 d0                	mov    %edx,%eax
c01041d9:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c01041dc:	73 2c                	jae    c010420a <page_init+0x3a4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c01041de:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01041e1:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01041e4:	2b 45 d0             	sub    -0x30(%ebp),%eax
c01041e7:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c01041ea:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01041ee:	c1 ea 0c             	shr    $0xc,%edx
c01041f1:	89 c3                	mov    %eax,%ebx
c01041f3:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01041f6:	89 04 24             	mov    %eax,(%esp)
c01041f9:	e8 bb f8 ff ff       	call   c0103ab9 <pa2page>
c01041fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0104202:	89 04 24             	mov    %eax,(%esp)
c0104205:	e8 9e fb ff ff       	call   c0103da8 <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
c010420a:	ff 45 dc             	incl   -0x24(%ebp)
c010420d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104210:	8b 00                	mov    (%eax),%eax
c0104212:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0104215:	0f 8c 9f fe ff ff    	jl     c01040ba <page_init+0x254>
                }
            }
        }
    }
}
c010421b:	90                   	nop
c010421c:	90                   	nop
c010421d:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c0104223:	5b                   	pop    %ebx
c0104224:	5e                   	pop    %esi
c0104225:	5f                   	pop    %edi
c0104226:	5d                   	pop    %ebp
c0104227:	c3                   	ret    

c0104228 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c0104228:	55                   	push   %ebp
c0104229:	89 e5                	mov    %esp,%ebp
c010422b:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c010422e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104231:	33 45 14             	xor    0x14(%ebp),%eax
c0104234:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104239:	85 c0                	test   %eax,%eax
c010423b:	74 24                	je     c0104261 <boot_map_segment+0x39>
c010423d:	c7 44 24 0c 6a 6b 10 	movl   $0xc0106b6a,0xc(%esp)
c0104244:	c0 
c0104245:	c7 44 24 08 81 6b 10 	movl   $0xc0106b81,0x8(%esp)
c010424c:	c0 
c010424d:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c0104254:	00 
c0104255:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c010425c:	e8 7a ca ff ff       	call   c0100cdb <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0104261:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0104268:	8b 45 0c             	mov    0xc(%ebp),%eax
c010426b:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104270:	89 c2                	mov    %eax,%edx
c0104272:	8b 45 10             	mov    0x10(%ebp),%eax
c0104275:	01 c2                	add    %eax,%edx
c0104277:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010427a:	01 d0                	add    %edx,%eax
c010427c:	48                   	dec    %eax
c010427d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104280:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104283:	ba 00 00 00 00       	mov    $0x0,%edx
c0104288:	f7 75 f0             	divl   -0x10(%ebp)
c010428b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010428e:	29 d0                	sub    %edx,%eax
c0104290:	c1 e8 0c             	shr    $0xc,%eax
c0104293:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0104296:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104299:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010429c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010429f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01042a4:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c01042a7:	8b 45 14             	mov    0x14(%ebp),%eax
c01042aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01042ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01042b0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01042b5:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01042b8:	eb 68                	jmp    c0104322 <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
c01042ba:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01042c1:	00 
c01042c2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01042c5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01042c9:	8b 45 08             	mov    0x8(%ebp),%eax
c01042cc:	89 04 24             	mov    %eax,(%esp)
c01042cf:	e8 88 01 00 00       	call   c010445c <get_pte>
c01042d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c01042d7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01042db:	75 24                	jne    c0104301 <boot_map_segment+0xd9>
c01042dd:	c7 44 24 0c 96 6b 10 	movl   $0xc0106b96,0xc(%esp)
c01042e4:	c0 
c01042e5:	c7 44 24 08 81 6b 10 	movl   $0xc0106b81,0x8(%esp)
c01042ec:	c0 
c01042ed:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c01042f4:	00 
c01042f5:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c01042fc:	e8 da c9 ff ff       	call   c0100cdb <__panic>
        *ptep = pa | PTE_P | perm;
c0104301:	8b 45 14             	mov    0x14(%ebp),%eax
c0104304:	0b 45 18             	or     0x18(%ebp),%eax
c0104307:	83 c8 01             	or     $0x1,%eax
c010430a:	89 c2                	mov    %eax,%edx
c010430c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010430f:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0104311:	ff 4d f4             	decl   -0xc(%ebp)
c0104314:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c010431b:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0104322:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104326:	75 92                	jne    c01042ba <boot_map_segment+0x92>
    }
}
c0104328:	90                   	nop
c0104329:	90                   	nop
c010432a:	89 ec                	mov    %ebp,%esp
c010432c:	5d                   	pop    %ebp
c010432d:	c3                   	ret    

c010432e <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c010432e:	55                   	push   %ebp
c010432f:	89 e5                	mov    %esp,%ebp
c0104331:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c0104334:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010433b:	e8 8a fa ff ff       	call   c0103dca <alloc_pages>
c0104340:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0104343:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104347:	75 1c                	jne    c0104365 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c0104349:	c7 44 24 08 a3 6b 10 	movl   $0xc0106ba3,0x8(%esp)
c0104350:	c0 
c0104351:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c0104358:	00 
c0104359:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c0104360:	e8 76 c9 ff ff       	call   c0100cdb <__panic>
    }
    return page2kva(p);
c0104365:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104368:	89 04 24             	mov    %eax,(%esp)
c010436b:	e8 9a f7 ff ff       	call   c0103b0a <page2kva>
}
c0104370:	89 ec                	mov    %ebp,%esp
c0104372:	5d                   	pop    %ebp
c0104373:	c3                   	ret    

c0104374 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c0104374:	55                   	push   %ebp
c0104375:	89 e5                	mov    %esp,%ebp
c0104377:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c010437a:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c010437f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104382:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0104389:	77 23                	ja     c01043ae <pmm_init+0x3a>
c010438b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010438e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104392:	c7 44 24 08 38 6b 10 	movl   $0xc0106b38,0x8(%esp)
c0104399:	c0 
c010439a:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c01043a1:	00 
c01043a2:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c01043a9:	e8 2d c9 ff ff       	call   c0100cdb <__panic>
c01043ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01043b1:	05 00 00 00 40       	add    $0x40000000,%eax
c01043b6:	a3 a8 be 11 c0       	mov    %eax,0xc011bea8
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c01043bb:	e8 b2 f9 ff ff       	call   c0103d72 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c01043c0:	e8 a1 fa ff ff       	call   c0103e66 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c01043c5:	e8 ed 03 00 00       	call   c01047b7 <check_alloc_page>

    check_pgdir();
c01043ca:	e8 09 04 00 00       	call   c01047d8 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c01043cf:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c01043d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01043d7:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c01043de:	77 23                	ja     c0104403 <pmm_init+0x8f>
c01043e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01043e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01043e7:	c7 44 24 08 38 6b 10 	movl   $0xc0106b38,0x8(%esp)
c01043ee:	c0 
c01043ef:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c01043f6:	00 
c01043f7:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c01043fe:	e8 d8 c8 ff ff       	call   c0100cdb <__panic>
c0104403:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104406:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c010440c:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104411:	05 ac 0f 00 00       	add    $0xfac,%eax
c0104416:	83 ca 03             	or     $0x3,%edx
c0104419:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c010441b:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104420:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c0104427:	00 
c0104428:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010442f:	00 
c0104430:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c0104437:	38 
c0104438:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c010443f:	c0 
c0104440:	89 04 24             	mov    %eax,(%esp)
c0104443:	e8 e0 fd ff ff       	call   c0104228 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0104448:	e8 39 f8 ff ff       	call   c0103c86 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c010444d:	e8 24 0a 00 00       	call   c0104e76 <check_boot_pgdir>

    print_pgdir();
c0104452:	e8 a1 0e 00 00       	call   c01052f8 <print_pgdir>

}
c0104457:	90                   	nop
c0104458:	89 ec                	mov    %ebp,%esp
c010445a:	5d                   	pop    %ebp
c010445b:	c3                   	ret    

c010445c <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c010445c:	55                   	push   %ebp
c010445d:	89 e5                	mov    %esp,%ebp
c010445f:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)];
c0104462:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104465:	c1 e8 16             	shr    $0x16,%eax
c0104468:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010446f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104472:	01 d0                	add    %edx,%eax
c0104474:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {
c0104477:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010447a:	8b 00                	mov    (%eax),%eax
c010447c:	83 e0 01             	and    $0x1,%eax
c010447f:	85 c0                	test   %eax,%eax
c0104481:	0f 85 af 00 00 00    	jne    c0104536 <get_pte+0xda>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
c0104487:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010448b:	74 15                	je     c01044a2 <get_pte+0x46>
c010448d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104494:	e8 31 f9 ff ff       	call   c0103dca <alloc_pages>
c0104499:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010449c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01044a0:	75 0a                	jne    c01044ac <get_pte+0x50>
            return NULL;
c01044a2:	b8 00 00 00 00       	mov    $0x0,%eax
c01044a7:	e9 e7 00 00 00       	jmp    c0104593 <get_pte+0x137>
        }
        set_page_ref(page, 1);
c01044ac:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01044b3:	00 
c01044b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01044b7:	89 04 24             	mov    %eax,(%esp)
c01044ba:	e8 05 f7 ff ff       	call   c0103bc4 <set_page_ref>
        uintptr_t pa = page2pa(page);
c01044bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01044c2:	89 04 24             	mov    %eax,(%esp)
c01044c5:	e8 d7 f5 ff ff       	call   c0103aa1 <page2pa>
c01044ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
c01044cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01044d0:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01044d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01044d6:	c1 e8 0c             	shr    $0xc,%eax
c01044d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01044dc:	a1 a4 be 11 c0       	mov    0xc011bea4,%eax
c01044e1:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c01044e4:	72 23                	jb     c0104509 <get_pte+0xad>
c01044e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01044e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01044ed:	c7 44 24 08 94 6a 10 	movl   $0xc0106a94,0x8(%esp)
c01044f4:	c0 
c01044f5:	c7 44 24 04 72 01 00 	movl   $0x172,0x4(%esp)
c01044fc:	00 
c01044fd:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c0104504:	e8 d2 c7 ff ff       	call   c0100cdb <__panic>
c0104509:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010450c:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104511:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104518:	00 
c0104519:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104520:	00 
c0104521:	89 04 24             	mov    %eax,(%esp)
c0104524:	e8 d4 18 00 00       	call   c0105dfd <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P;
c0104529:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010452c:	83 c8 07             	or     $0x7,%eax
c010452f:	89 c2                	mov    %eax,%edx
c0104531:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104534:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c0104536:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104539:	8b 00                	mov    (%eax),%eax
c010453b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104540:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0104543:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104546:	c1 e8 0c             	shr    $0xc,%eax
c0104549:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010454c:	a1 a4 be 11 c0       	mov    0xc011bea4,%eax
c0104551:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0104554:	72 23                	jb     c0104579 <get_pte+0x11d>
c0104556:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104559:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010455d:	c7 44 24 08 94 6a 10 	movl   $0xc0106a94,0x8(%esp)
c0104564:	c0 
c0104565:	c7 44 24 04 75 01 00 	movl   $0x175,0x4(%esp)
c010456c:	00 
c010456d:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c0104574:	e8 62 c7 ff ff       	call   c0100cdb <__panic>
c0104579:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010457c:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104581:	89 c2                	mov    %eax,%edx
c0104583:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104586:	c1 e8 0c             	shr    $0xc,%eax
c0104589:	25 ff 03 00 00       	and    $0x3ff,%eax
c010458e:	c1 e0 02             	shl    $0x2,%eax
c0104591:	01 d0                	add    %edx,%eax
}
c0104593:	89 ec                	mov    %ebp,%esp
c0104595:	5d                   	pop    %ebp
c0104596:	c3                   	ret    

c0104597 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c0104597:	55                   	push   %ebp
c0104598:	89 e5                	mov    %esp,%ebp
c010459a:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c010459d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01045a4:	00 
c01045a5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01045a8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01045ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01045af:	89 04 24             	mov    %eax,(%esp)
c01045b2:	e8 a5 fe ff ff       	call   c010445c <get_pte>
c01045b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c01045ba:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01045be:	74 08                	je     c01045c8 <get_page+0x31>
        *ptep_store = ptep;
c01045c0:	8b 45 10             	mov    0x10(%ebp),%eax
c01045c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01045c6:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c01045c8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01045cc:	74 1b                	je     c01045e9 <get_page+0x52>
c01045ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045d1:	8b 00                	mov    (%eax),%eax
c01045d3:	83 e0 01             	and    $0x1,%eax
c01045d6:	85 c0                	test   %eax,%eax
c01045d8:	74 0f                	je     c01045e9 <get_page+0x52>
        return pte2page(*ptep);
c01045da:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045dd:	8b 00                	mov    (%eax),%eax
c01045df:	89 04 24             	mov    %eax,(%esp)
c01045e2:	e8 79 f5 ff ff       	call   c0103b60 <pte2page>
c01045e7:	eb 05                	jmp    c01045ee <get_page+0x57>
    }
    return NULL;
c01045e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01045ee:	89 ec                	mov    %ebp,%esp
c01045f0:	5d                   	pop    %ebp
c01045f1:	c3                   	ret    

c01045f2 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c01045f2:	55                   	push   %ebp
c01045f3:	89 e5                	mov    %esp,%ebp
c01045f5:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {
c01045f8:	8b 45 10             	mov    0x10(%ebp),%eax
c01045fb:	8b 00                	mov    (%eax),%eax
c01045fd:	83 e0 01             	and    $0x1,%eax
c0104600:	85 c0                	test   %eax,%eax
c0104602:	74 4d                	je     c0104651 <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);
c0104604:	8b 45 10             	mov    0x10(%ebp),%eax
c0104607:	8b 00                	mov    (%eax),%eax
c0104609:	89 04 24             	mov    %eax,(%esp)
c010460c:	e8 4f f5 ff ff       	call   c0103b60 <pte2page>
c0104611:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
c0104614:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104617:	89 04 24             	mov    %eax,(%esp)
c010461a:	e8 ca f5 ff ff       	call   c0103be9 <page_ref_dec>
c010461f:	85 c0                	test   %eax,%eax
c0104621:	75 13                	jne    c0104636 <page_remove_pte+0x44>
            free_page(page);
c0104623:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010462a:	00 
c010462b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010462e:	89 04 24             	mov    %eax,(%esp)
c0104631:	e8 ce f7 ff ff       	call   c0103e04 <free_pages>
        }
        *ptep = 0;
c0104636:	8b 45 10             	mov    0x10(%ebp),%eax
c0104639:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c010463f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104642:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104646:	8b 45 08             	mov    0x8(%ebp),%eax
c0104649:	89 04 24             	mov    %eax,(%esp)
c010464c:	e8 07 01 00 00       	call   c0104758 <tlb_invalidate>
    }
}
c0104651:	90                   	nop
c0104652:	89 ec                	mov    %ebp,%esp
c0104654:	5d                   	pop    %ebp
c0104655:	c3                   	ret    

c0104656 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0104656:	55                   	push   %ebp
c0104657:	89 e5                	mov    %esp,%ebp
c0104659:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c010465c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104663:	00 
c0104664:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104667:	89 44 24 04          	mov    %eax,0x4(%esp)
c010466b:	8b 45 08             	mov    0x8(%ebp),%eax
c010466e:	89 04 24             	mov    %eax,(%esp)
c0104671:	e8 e6 fd ff ff       	call   c010445c <get_pte>
c0104676:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c0104679:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010467d:	74 19                	je     c0104698 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c010467f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104682:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104686:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104689:	89 44 24 04          	mov    %eax,0x4(%esp)
c010468d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104690:	89 04 24             	mov    %eax,(%esp)
c0104693:	e8 5a ff ff ff       	call   c01045f2 <page_remove_pte>
    }
}
c0104698:	90                   	nop
c0104699:	89 ec                	mov    %ebp,%esp
c010469b:	5d                   	pop    %ebp
c010469c:	c3                   	ret    

c010469d <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c010469d:	55                   	push   %ebp
c010469e:	89 e5                	mov    %esp,%ebp
c01046a0:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c01046a3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01046aa:	00 
c01046ab:	8b 45 10             	mov    0x10(%ebp),%eax
c01046ae:	89 44 24 04          	mov    %eax,0x4(%esp)
c01046b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01046b5:	89 04 24             	mov    %eax,(%esp)
c01046b8:	e8 9f fd ff ff       	call   c010445c <get_pte>
c01046bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c01046c0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01046c4:	75 0a                	jne    c01046d0 <page_insert+0x33>
        return -E_NO_MEM;
c01046c6:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c01046cb:	e9 84 00 00 00       	jmp    c0104754 <page_insert+0xb7>
    }
    page_ref_inc(page);
c01046d0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01046d3:	89 04 24             	mov    %eax,(%esp)
c01046d6:	e8 f7 f4 ff ff       	call   c0103bd2 <page_ref_inc>
    if (*ptep & PTE_P) {
c01046db:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046de:	8b 00                	mov    (%eax),%eax
c01046e0:	83 e0 01             	and    $0x1,%eax
c01046e3:	85 c0                	test   %eax,%eax
c01046e5:	74 3e                	je     c0104725 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c01046e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046ea:	8b 00                	mov    (%eax),%eax
c01046ec:	89 04 24             	mov    %eax,(%esp)
c01046ef:	e8 6c f4 ff ff       	call   c0103b60 <pte2page>
c01046f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c01046f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01046fa:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01046fd:	75 0d                	jne    c010470c <page_insert+0x6f>
            page_ref_dec(page);
c01046ff:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104702:	89 04 24             	mov    %eax,(%esp)
c0104705:	e8 df f4 ff ff       	call   c0103be9 <page_ref_dec>
c010470a:	eb 19                	jmp    c0104725 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c010470c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010470f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104713:	8b 45 10             	mov    0x10(%ebp),%eax
c0104716:	89 44 24 04          	mov    %eax,0x4(%esp)
c010471a:	8b 45 08             	mov    0x8(%ebp),%eax
c010471d:	89 04 24             	mov    %eax,(%esp)
c0104720:	e8 cd fe ff ff       	call   c01045f2 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0104725:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104728:	89 04 24             	mov    %eax,(%esp)
c010472b:	e8 71 f3 ff ff       	call   c0103aa1 <page2pa>
c0104730:	0b 45 14             	or     0x14(%ebp),%eax
c0104733:	83 c8 01             	or     $0x1,%eax
c0104736:	89 c2                	mov    %eax,%edx
c0104738:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010473b:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c010473d:	8b 45 10             	mov    0x10(%ebp),%eax
c0104740:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104744:	8b 45 08             	mov    0x8(%ebp),%eax
c0104747:	89 04 24             	mov    %eax,(%esp)
c010474a:	e8 09 00 00 00       	call   c0104758 <tlb_invalidate>
    return 0;
c010474f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104754:	89 ec                	mov    %ebp,%esp
c0104756:	5d                   	pop    %ebp
c0104757:	c3                   	ret    

c0104758 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c0104758:	55                   	push   %ebp
c0104759:	89 e5                	mov    %esp,%ebp
c010475b:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c010475e:	0f 20 d8             	mov    %cr3,%eax
c0104761:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c0104764:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c0104767:	8b 45 08             	mov    0x8(%ebp),%eax
c010476a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010476d:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0104774:	77 23                	ja     c0104799 <tlb_invalidate+0x41>
c0104776:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104779:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010477d:	c7 44 24 08 38 6b 10 	movl   $0xc0106b38,0x8(%esp)
c0104784:	c0 
c0104785:	c7 44 24 04 d7 01 00 	movl   $0x1d7,0x4(%esp)
c010478c:	00 
c010478d:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c0104794:	e8 42 c5 ff ff       	call   c0100cdb <__panic>
c0104799:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010479c:	05 00 00 00 40       	add    $0x40000000,%eax
c01047a1:	39 d0                	cmp    %edx,%eax
c01047a3:	75 0d                	jne    c01047b2 <tlb_invalidate+0x5a>
        invlpg((void *)la);
c01047a5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01047a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c01047ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01047ae:	0f 01 38             	invlpg (%eax)
}
c01047b1:	90                   	nop
    }
}
c01047b2:	90                   	nop
c01047b3:	89 ec                	mov    %ebp,%esp
c01047b5:	5d                   	pop    %ebp
c01047b6:	c3                   	ret    

c01047b7 <check_alloc_page>:

static void
check_alloc_page(void) {
c01047b7:	55                   	push   %ebp
c01047b8:	89 e5                	mov    %esp,%ebp
c01047ba:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c01047bd:	a1 ac be 11 c0       	mov    0xc011beac,%eax
c01047c2:	8b 40 18             	mov    0x18(%eax),%eax
c01047c5:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c01047c7:	c7 04 24 bc 6b 10 c0 	movl   $0xc0106bbc,(%esp)
c01047ce:	e8 83 bb ff ff       	call   c0100356 <cprintf>
}
c01047d3:	90                   	nop
c01047d4:	89 ec                	mov    %ebp,%esp
c01047d6:	5d                   	pop    %ebp
c01047d7:	c3                   	ret    

c01047d8 <check_pgdir>:

static void
check_pgdir(void) {
c01047d8:	55                   	push   %ebp
c01047d9:	89 e5                	mov    %esp,%ebp
c01047db:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c01047de:	a1 a4 be 11 c0       	mov    0xc011bea4,%eax
c01047e3:	3d 00 80 03 00       	cmp    $0x38000,%eax
c01047e8:	76 24                	jbe    c010480e <check_pgdir+0x36>
c01047ea:	c7 44 24 0c db 6b 10 	movl   $0xc0106bdb,0xc(%esp)
c01047f1:	c0 
c01047f2:	c7 44 24 08 81 6b 10 	movl   $0xc0106b81,0x8(%esp)
c01047f9:	c0 
c01047fa:	c7 44 24 04 e4 01 00 	movl   $0x1e4,0x4(%esp)
c0104801:	00 
c0104802:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c0104809:	e8 cd c4 ff ff       	call   c0100cdb <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c010480e:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104813:	85 c0                	test   %eax,%eax
c0104815:	74 0e                	je     c0104825 <check_pgdir+0x4d>
c0104817:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c010481c:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104821:	85 c0                	test   %eax,%eax
c0104823:	74 24                	je     c0104849 <check_pgdir+0x71>
c0104825:	c7 44 24 0c f8 6b 10 	movl   $0xc0106bf8,0xc(%esp)
c010482c:	c0 
c010482d:	c7 44 24 08 81 6b 10 	movl   $0xc0106b81,0x8(%esp)
c0104834:	c0 
c0104835:	c7 44 24 04 e5 01 00 	movl   $0x1e5,0x4(%esp)
c010483c:	00 
c010483d:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c0104844:	e8 92 c4 ff ff       	call   c0100cdb <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c0104849:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c010484e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104855:	00 
c0104856:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010485d:	00 
c010485e:	89 04 24             	mov    %eax,(%esp)
c0104861:	e8 31 fd ff ff       	call   c0104597 <get_page>
c0104866:	85 c0                	test   %eax,%eax
c0104868:	74 24                	je     c010488e <check_pgdir+0xb6>
c010486a:	c7 44 24 0c 30 6c 10 	movl   $0xc0106c30,0xc(%esp)
c0104871:	c0 
c0104872:	c7 44 24 08 81 6b 10 	movl   $0xc0106b81,0x8(%esp)
c0104879:	c0 
c010487a:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
c0104881:	00 
c0104882:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c0104889:	e8 4d c4 ff ff       	call   c0100cdb <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c010488e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104895:	e8 30 f5 ff ff       	call   c0103dca <alloc_pages>
c010489a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c010489d:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c01048a2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01048a9:	00 
c01048aa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01048b1:	00 
c01048b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01048b5:	89 54 24 04          	mov    %edx,0x4(%esp)
c01048b9:	89 04 24             	mov    %eax,(%esp)
c01048bc:	e8 dc fd ff ff       	call   c010469d <page_insert>
c01048c1:	85 c0                	test   %eax,%eax
c01048c3:	74 24                	je     c01048e9 <check_pgdir+0x111>
c01048c5:	c7 44 24 0c 58 6c 10 	movl   $0xc0106c58,0xc(%esp)
c01048cc:	c0 
c01048cd:	c7 44 24 08 81 6b 10 	movl   $0xc0106b81,0x8(%esp)
c01048d4:	c0 
c01048d5:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
c01048dc:	00 
c01048dd:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c01048e4:	e8 f2 c3 ff ff       	call   c0100cdb <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c01048e9:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c01048ee:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01048f5:	00 
c01048f6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01048fd:	00 
c01048fe:	89 04 24             	mov    %eax,(%esp)
c0104901:	e8 56 fb ff ff       	call   c010445c <get_pte>
c0104906:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104909:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010490d:	75 24                	jne    c0104933 <check_pgdir+0x15b>
c010490f:	c7 44 24 0c 84 6c 10 	movl   $0xc0106c84,0xc(%esp)
c0104916:	c0 
c0104917:	c7 44 24 08 81 6b 10 	movl   $0xc0106b81,0x8(%esp)
c010491e:	c0 
c010491f:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
c0104926:	00 
c0104927:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c010492e:	e8 a8 c3 ff ff       	call   c0100cdb <__panic>
    assert(pte2page(*ptep) == p1);
c0104933:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104936:	8b 00                	mov    (%eax),%eax
c0104938:	89 04 24             	mov    %eax,(%esp)
c010493b:	e8 20 f2 ff ff       	call   c0103b60 <pte2page>
c0104940:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0104943:	74 24                	je     c0104969 <check_pgdir+0x191>
c0104945:	c7 44 24 0c b1 6c 10 	movl   $0xc0106cb1,0xc(%esp)
c010494c:	c0 
c010494d:	c7 44 24 08 81 6b 10 	movl   $0xc0106b81,0x8(%esp)
c0104954:	c0 
c0104955:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
c010495c:	00 
c010495d:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c0104964:	e8 72 c3 ff ff       	call   c0100cdb <__panic>
    assert(page_ref(p1) == 1);
c0104969:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010496c:	89 04 24             	mov    %eax,(%esp)
c010496f:	e8 46 f2 ff ff       	call   c0103bba <page_ref>
c0104974:	83 f8 01             	cmp    $0x1,%eax
c0104977:	74 24                	je     c010499d <check_pgdir+0x1c5>
c0104979:	c7 44 24 0c c7 6c 10 	movl   $0xc0106cc7,0xc(%esp)
c0104980:	c0 
c0104981:	c7 44 24 08 81 6b 10 	movl   $0xc0106b81,0x8(%esp)
c0104988:	c0 
c0104989:	c7 44 24 04 ef 01 00 	movl   $0x1ef,0x4(%esp)
c0104990:	00 
c0104991:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c0104998:	e8 3e c3 ff ff       	call   c0100cdb <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c010499d:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c01049a2:	8b 00                	mov    (%eax),%eax
c01049a4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01049a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01049ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01049af:	c1 e8 0c             	shr    $0xc,%eax
c01049b2:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01049b5:	a1 a4 be 11 c0       	mov    0xc011bea4,%eax
c01049ba:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01049bd:	72 23                	jb     c01049e2 <check_pgdir+0x20a>
c01049bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01049c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01049c6:	c7 44 24 08 94 6a 10 	movl   $0xc0106a94,0x8(%esp)
c01049cd:	c0 
c01049ce:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
c01049d5:	00 
c01049d6:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c01049dd:	e8 f9 c2 ff ff       	call   c0100cdb <__panic>
c01049e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01049e5:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01049ea:	83 c0 04             	add    $0x4,%eax
c01049ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c01049f0:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c01049f5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01049fc:	00 
c01049fd:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104a04:	00 
c0104a05:	89 04 24             	mov    %eax,(%esp)
c0104a08:	e8 4f fa ff ff       	call   c010445c <get_pte>
c0104a0d:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104a10:	74 24                	je     c0104a36 <check_pgdir+0x25e>
c0104a12:	c7 44 24 0c dc 6c 10 	movl   $0xc0106cdc,0xc(%esp)
c0104a19:	c0 
c0104a1a:	c7 44 24 08 81 6b 10 	movl   $0xc0106b81,0x8(%esp)
c0104a21:	c0 
c0104a22:	c7 44 24 04 f2 01 00 	movl   $0x1f2,0x4(%esp)
c0104a29:	00 
c0104a2a:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c0104a31:	e8 a5 c2 ff ff       	call   c0100cdb <__panic>

    p2 = alloc_page();
c0104a36:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104a3d:	e8 88 f3 ff ff       	call   c0103dca <alloc_pages>
c0104a42:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0104a45:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104a4a:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c0104a51:	00 
c0104a52:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104a59:	00 
c0104a5a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104a5d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104a61:	89 04 24             	mov    %eax,(%esp)
c0104a64:	e8 34 fc ff ff       	call   c010469d <page_insert>
c0104a69:	85 c0                	test   %eax,%eax
c0104a6b:	74 24                	je     c0104a91 <check_pgdir+0x2b9>
c0104a6d:	c7 44 24 0c 04 6d 10 	movl   $0xc0106d04,0xc(%esp)
c0104a74:	c0 
c0104a75:	c7 44 24 08 81 6b 10 	movl   $0xc0106b81,0x8(%esp)
c0104a7c:	c0 
c0104a7d:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
c0104a84:	00 
c0104a85:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c0104a8c:	e8 4a c2 ff ff       	call   c0100cdb <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0104a91:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104a96:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104a9d:	00 
c0104a9e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104aa5:	00 
c0104aa6:	89 04 24             	mov    %eax,(%esp)
c0104aa9:	e8 ae f9 ff ff       	call   c010445c <get_pte>
c0104aae:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104ab1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104ab5:	75 24                	jne    c0104adb <check_pgdir+0x303>
c0104ab7:	c7 44 24 0c 3c 6d 10 	movl   $0xc0106d3c,0xc(%esp)
c0104abe:	c0 
c0104abf:	c7 44 24 08 81 6b 10 	movl   $0xc0106b81,0x8(%esp)
c0104ac6:	c0 
c0104ac7:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
c0104ace:	00 
c0104acf:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c0104ad6:	e8 00 c2 ff ff       	call   c0100cdb <__panic>
    assert(*ptep & PTE_U);
c0104adb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ade:	8b 00                	mov    (%eax),%eax
c0104ae0:	83 e0 04             	and    $0x4,%eax
c0104ae3:	85 c0                	test   %eax,%eax
c0104ae5:	75 24                	jne    c0104b0b <check_pgdir+0x333>
c0104ae7:	c7 44 24 0c 6c 6d 10 	movl   $0xc0106d6c,0xc(%esp)
c0104aee:	c0 
c0104aef:	c7 44 24 08 81 6b 10 	movl   $0xc0106b81,0x8(%esp)
c0104af6:	c0 
c0104af7:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
c0104afe:	00 
c0104aff:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c0104b06:	e8 d0 c1 ff ff       	call   c0100cdb <__panic>
    assert(*ptep & PTE_W);
c0104b0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b0e:	8b 00                	mov    (%eax),%eax
c0104b10:	83 e0 02             	and    $0x2,%eax
c0104b13:	85 c0                	test   %eax,%eax
c0104b15:	75 24                	jne    c0104b3b <check_pgdir+0x363>
c0104b17:	c7 44 24 0c 7a 6d 10 	movl   $0xc0106d7a,0xc(%esp)
c0104b1e:	c0 
c0104b1f:	c7 44 24 08 81 6b 10 	movl   $0xc0106b81,0x8(%esp)
c0104b26:	c0 
c0104b27:	c7 44 24 04 f8 01 00 	movl   $0x1f8,0x4(%esp)
c0104b2e:	00 
c0104b2f:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c0104b36:	e8 a0 c1 ff ff       	call   c0100cdb <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0104b3b:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104b40:	8b 00                	mov    (%eax),%eax
c0104b42:	83 e0 04             	and    $0x4,%eax
c0104b45:	85 c0                	test   %eax,%eax
c0104b47:	75 24                	jne    c0104b6d <check_pgdir+0x395>
c0104b49:	c7 44 24 0c 88 6d 10 	movl   $0xc0106d88,0xc(%esp)
c0104b50:	c0 
c0104b51:	c7 44 24 08 81 6b 10 	movl   $0xc0106b81,0x8(%esp)
c0104b58:	c0 
c0104b59:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
c0104b60:	00 
c0104b61:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c0104b68:	e8 6e c1 ff ff       	call   c0100cdb <__panic>
    assert(page_ref(p2) == 1);
c0104b6d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104b70:	89 04 24             	mov    %eax,(%esp)
c0104b73:	e8 42 f0 ff ff       	call   c0103bba <page_ref>
c0104b78:	83 f8 01             	cmp    $0x1,%eax
c0104b7b:	74 24                	je     c0104ba1 <check_pgdir+0x3c9>
c0104b7d:	c7 44 24 0c 9e 6d 10 	movl   $0xc0106d9e,0xc(%esp)
c0104b84:	c0 
c0104b85:	c7 44 24 08 81 6b 10 	movl   $0xc0106b81,0x8(%esp)
c0104b8c:	c0 
c0104b8d:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
c0104b94:	00 
c0104b95:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c0104b9c:	e8 3a c1 ff ff       	call   c0100cdb <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0104ba1:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104ba6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104bad:	00 
c0104bae:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104bb5:	00 
c0104bb6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104bb9:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104bbd:	89 04 24             	mov    %eax,(%esp)
c0104bc0:	e8 d8 fa ff ff       	call   c010469d <page_insert>
c0104bc5:	85 c0                	test   %eax,%eax
c0104bc7:	74 24                	je     c0104bed <check_pgdir+0x415>
c0104bc9:	c7 44 24 0c b0 6d 10 	movl   $0xc0106db0,0xc(%esp)
c0104bd0:	c0 
c0104bd1:	c7 44 24 08 81 6b 10 	movl   $0xc0106b81,0x8(%esp)
c0104bd8:	c0 
c0104bd9:	c7 44 24 04 fc 01 00 	movl   $0x1fc,0x4(%esp)
c0104be0:	00 
c0104be1:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c0104be8:	e8 ee c0 ff ff       	call   c0100cdb <__panic>
    assert(page_ref(p1) == 2);
c0104bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bf0:	89 04 24             	mov    %eax,(%esp)
c0104bf3:	e8 c2 ef ff ff       	call   c0103bba <page_ref>
c0104bf8:	83 f8 02             	cmp    $0x2,%eax
c0104bfb:	74 24                	je     c0104c21 <check_pgdir+0x449>
c0104bfd:	c7 44 24 0c dc 6d 10 	movl   $0xc0106ddc,0xc(%esp)
c0104c04:	c0 
c0104c05:	c7 44 24 08 81 6b 10 	movl   $0xc0106b81,0x8(%esp)
c0104c0c:	c0 
c0104c0d:	c7 44 24 04 fd 01 00 	movl   $0x1fd,0x4(%esp)
c0104c14:	00 
c0104c15:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c0104c1c:	e8 ba c0 ff ff       	call   c0100cdb <__panic>
    assert(page_ref(p2) == 0);
c0104c21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104c24:	89 04 24             	mov    %eax,(%esp)
c0104c27:	e8 8e ef ff ff       	call   c0103bba <page_ref>
c0104c2c:	85 c0                	test   %eax,%eax
c0104c2e:	74 24                	je     c0104c54 <check_pgdir+0x47c>
c0104c30:	c7 44 24 0c ee 6d 10 	movl   $0xc0106dee,0xc(%esp)
c0104c37:	c0 
c0104c38:	c7 44 24 08 81 6b 10 	movl   $0xc0106b81,0x8(%esp)
c0104c3f:	c0 
c0104c40:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
c0104c47:	00 
c0104c48:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c0104c4f:	e8 87 c0 ff ff       	call   c0100cdb <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0104c54:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104c59:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104c60:	00 
c0104c61:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104c68:	00 
c0104c69:	89 04 24             	mov    %eax,(%esp)
c0104c6c:	e8 eb f7 ff ff       	call   c010445c <get_pte>
c0104c71:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104c74:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104c78:	75 24                	jne    c0104c9e <check_pgdir+0x4c6>
c0104c7a:	c7 44 24 0c 3c 6d 10 	movl   $0xc0106d3c,0xc(%esp)
c0104c81:	c0 
c0104c82:	c7 44 24 08 81 6b 10 	movl   $0xc0106b81,0x8(%esp)
c0104c89:	c0 
c0104c8a:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
c0104c91:	00 
c0104c92:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c0104c99:	e8 3d c0 ff ff       	call   c0100cdb <__panic>
    assert(pte2page(*ptep) == p1);
c0104c9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ca1:	8b 00                	mov    (%eax),%eax
c0104ca3:	89 04 24             	mov    %eax,(%esp)
c0104ca6:	e8 b5 ee ff ff       	call   c0103b60 <pte2page>
c0104cab:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0104cae:	74 24                	je     c0104cd4 <check_pgdir+0x4fc>
c0104cb0:	c7 44 24 0c b1 6c 10 	movl   $0xc0106cb1,0xc(%esp)
c0104cb7:	c0 
c0104cb8:	c7 44 24 08 81 6b 10 	movl   $0xc0106b81,0x8(%esp)
c0104cbf:	c0 
c0104cc0:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
c0104cc7:	00 
c0104cc8:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c0104ccf:	e8 07 c0 ff ff       	call   c0100cdb <__panic>
    assert((*ptep & PTE_U) == 0);
c0104cd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104cd7:	8b 00                	mov    (%eax),%eax
c0104cd9:	83 e0 04             	and    $0x4,%eax
c0104cdc:	85 c0                	test   %eax,%eax
c0104cde:	74 24                	je     c0104d04 <check_pgdir+0x52c>
c0104ce0:	c7 44 24 0c 00 6e 10 	movl   $0xc0106e00,0xc(%esp)
c0104ce7:	c0 
c0104ce8:	c7 44 24 08 81 6b 10 	movl   $0xc0106b81,0x8(%esp)
c0104cef:	c0 
c0104cf0:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
c0104cf7:	00 
c0104cf8:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c0104cff:	e8 d7 bf ff ff       	call   c0100cdb <__panic>

    page_remove(boot_pgdir, 0x0);
c0104d04:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104d09:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104d10:	00 
c0104d11:	89 04 24             	mov    %eax,(%esp)
c0104d14:	e8 3d f9 ff ff       	call   c0104656 <page_remove>
    assert(page_ref(p1) == 1);
c0104d19:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d1c:	89 04 24             	mov    %eax,(%esp)
c0104d1f:	e8 96 ee ff ff       	call   c0103bba <page_ref>
c0104d24:	83 f8 01             	cmp    $0x1,%eax
c0104d27:	74 24                	je     c0104d4d <check_pgdir+0x575>
c0104d29:	c7 44 24 0c c7 6c 10 	movl   $0xc0106cc7,0xc(%esp)
c0104d30:	c0 
c0104d31:	c7 44 24 08 81 6b 10 	movl   $0xc0106b81,0x8(%esp)
c0104d38:	c0 
c0104d39:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
c0104d40:	00 
c0104d41:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c0104d48:	e8 8e bf ff ff       	call   c0100cdb <__panic>
    assert(page_ref(p2) == 0);
c0104d4d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104d50:	89 04 24             	mov    %eax,(%esp)
c0104d53:	e8 62 ee ff ff       	call   c0103bba <page_ref>
c0104d58:	85 c0                	test   %eax,%eax
c0104d5a:	74 24                	je     c0104d80 <check_pgdir+0x5a8>
c0104d5c:	c7 44 24 0c ee 6d 10 	movl   $0xc0106dee,0xc(%esp)
c0104d63:	c0 
c0104d64:	c7 44 24 08 81 6b 10 	movl   $0xc0106b81,0x8(%esp)
c0104d6b:	c0 
c0104d6c:	c7 44 24 04 05 02 00 	movl   $0x205,0x4(%esp)
c0104d73:	00 
c0104d74:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c0104d7b:	e8 5b bf ff ff       	call   c0100cdb <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0104d80:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104d85:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104d8c:	00 
c0104d8d:	89 04 24             	mov    %eax,(%esp)
c0104d90:	e8 c1 f8 ff ff       	call   c0104656 <page_remove>
    assert(page_ref(p1) == 0);
c0104d95:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d98:	89 04 24             	mov    %eax,(%esp)
c0104d9b:	e8 1a ee ff ff       	call   c0103bba <page_ref>
c0104da0:	85 c0                	test   %eax,%eax
c0104da2:	74 24                	je     c0104dc8 <check_pgdir+0x5f0>
c0104da4:	c7 44 24 0c 15 6e 10 	movl   $0xc0106e15,0xc(%esp)
c0104dab:	c0 
c0104dac:	c7 44 24 08 81 6b 10 	movl   $0xc0106b81,0x8(%esp)
c0104db3:	c0 
c0104db4:	c7 44 24 04 08 02 00 	movl   $0x208,0x4(%esp)
c0104dbb:	00 
c0104dbc:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c0104dc3:	e8 13 bf ff ff       	call   c0100cdb <__panic>
    assert(page_ref(p2) == 0);
c0104dc8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104dcb:	89 04 24             	mov    %eax,(%esp)
c0104dce:	e8 e7 ed ff ff       	call   c0103bba <page_ref>
c0104dd3:	85 c0                	test   %eax,%eax
c0104dd5:	74 24                	je     c0104dfb <check_pgdir+0x623>
c0104dd7:	c7 44 24 0c ee 6d 10 	movl   $0xc0106dee,0xc(%esp)
c0104dde:	c0 
c0104ddf:	c7 44 24 08 81 6b 10 	movl   $0xc0106b81,0x8(%esp)
c0104de6:	c0 
c0104de7:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
c0104dee:	00 
c0104def:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c0104df6:	e8 e0 be ff ff       	call   c0100cdb <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0104dfb:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104e00:	8b 00                	mov    (%eax),%eax
c0104e02:	89 04 24             	mov    %eax,(%esp)
c0104e05:	e8 96 ed ff ff       	call   c0103ba0 <pde2page>
c0104e0a:	89 04 24             	mov    %eax,(%esp)
c0104e0d:	e8 a8 ed ff ff       	call   c0103bba <page_ref>
c0104e12:	83 f8 01             	cmp    $0x1,%eax
c0104e15:	74 24                	je     c0104e3b <check_pgdir+0x663>
c0104e17:	c7 44 24 0c 28 6e 10 	movl   $0xc0106e28,0xc(%esp)
c0104e1e:	c0 
c0104e1f:	c7 44 24 08 81 6b 10 	movl   $0xc0106b81,0x8(%esp)
c0104e26:	c0 
c0104e27:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
c0104e2e:	00 
c0104e2f:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c0104e36:	e8 a0 be ff ff       	call   c0100cdb <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0104e3b:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104e40:	8b 00                	mov    (%eax),%eax
c0104e42:	89 04 24             	mov    %eax,(%esp)
c0104e45:	e8 56 ed ff ff       	call   c0103ba0 <pde2page>
c0104e4a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104e51:	00 
c0104e52:	89 04 24             	mov    %eax,(%esp)
c0104e55:	e8 aa ef ff ff       	call   c0103e04 <free_pages>
    boot_pgdir[0] = 0;
c0104e5a:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104e5f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0104e65:	c7 04 24 4f 6e 10 c0 	movl   $0xc0106e4f,(%esp)
c0104e6c:	e8 e5 b4 ff ff       	call   c0100356 <cprintf>
}
c0104e71:	90                   	nop
c0104e72:	89 ec                	mov    %ebp,%esp
c0104e74:	5d                   	pop    %ebp
c0104e75:	c3                   	ret    

c0104e76 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0104e76:	55                   	push   %ebp
c0104e77:	89 e5                	mov    %esp,%ebp
c0104e79:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0104e7c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104e83:	e9 ca 00 00 00       	jmp    c0104f52 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0104e88:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e8b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104e8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104e91:	c1 e8 0c             	shr    $0xc,%eax
c0104e94:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0104e97:	a1 a4 be 11 c0       	mov    0xc011bea4,%eax
c0104e9c:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0104e9f:	72 23                	jb     c0104ec4 <check_boot_pgdir+0x4e>
c0104ea1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104ea4:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104ea8:	c7 44 24 08 94 6a 10 	movl   $0xc0106a94,0x8(%esp)
c0104eaf:	c0 
c0104eb0:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
c0104eb7:	00 
c0104eb8:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c0104ebf:	e8 17 be ff ff       	call   c0100cdb <__panic>
c0104ec4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104ec7:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104ecc:	89 c2                	mov    %eax,%edx
c0104ece:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104ed3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104eda:	00 
c0104edb:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104edf:	89 04 24             	mov    %eax,(%esp)
c0104ee2:	e8 75 f5 ff ff       	call   c010445c <get_pte>
c0104ee7:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0104eea:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0104eee:	75 24                	jne    c0104f14 <check_boot_pgdir+0x9e>
c0104ef0:	c7 44 24 0c 6c 6e 10 	movl   $0xc0106e6c,0xc(%esp)
c0104ef7:	c0 
c0104ef8:	c7 44 24 08 81 6b 10 	movl   $0xc0106b81,0x8(%esp)
c0104eff:	c0 
c0104f00:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
c0104f07:	00 
c0104f08:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c0104f0f:	e8 c7 bd ff ff       	call   c0100cdb <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0104f14:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104f17:	8b 00                	mov    (%eax),%eax
c0104f19:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104f1e:	89 c2                	mov    %eax,%edx
c0104f20:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f23:	39 c2                	cmp    %eax,%edx
c0104f25:	74 24                	je     c0104f4b <check_boot_pgdir+0xd5>
c0104f27:	c7 44 24 0c a9 6e 10 	movl   $0xc0106ea9,0xc(%esp)
c0104f2e:	c0 
c0104f2f:	c7 44 24 08 81 6b 10 	movl   $0xc0106b81,0x8(%esp)
c0104f36:	c0 
c0104f37:	c7 44 24 04 18 02 00 	movl   $0x218,0x4(%esp)
c0104f3e:	00 
c0104f3f:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c0104f46:	e8 90 bd ff ff       	call   c0100cdb <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
c0104f4b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0104f52:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104f55:	a1 a4 be 11 c0       	mov    0xc011bea4,%eax
c0104f5a:	39 c2                	cmp    %eax,%edx
c0104f5c:	0f 82 26 ff ff ff    	jb     c0104e88 <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0104f62:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104f67:	05 ac 0f 00 00       	add    $0xfac,%eax
c0104f6c:	8b 00                	mov    (%eax),%eax
c0104f6e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104f73:	89 c2                	mov    %eax,%edx
c0104f75:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104f7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104f7d:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0104f84:	77 23                	ja     c0104fa9 <check_boot_pgdir+0x133>
c0104f86:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f89:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104f8d:	c7 44 24 08 38 6b 10 	movl   $0xc0106b38,0x8(%esp)
c0104f94:	c0 
c0104f95:	c7 44 24 04 1b 02 00 	movl   $0x21b,0x4(%esp)
c0104f9c:	00 
c0104f9d:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c0104fa4:	e8 32 bd ff ff       	call   c0100cdb <__panic>
c0104fa9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104fac:	05 00 00 00 40       	add    $0x40000000,%eax
c0104fb1:	39 d0                	cmp    %edx,%eax
c0104fb3:	74 24                	je     c0104fd9 <check_boot_pgdir+0x163>
c0104fb5:	c7 44 24 0c c0 6e 10 	movl   $0xc0106ec0,0xc(%esp)
c0104fbc:	c0 
c0104fbd:	c7 44 24 08 81 6b 10 	movl   $0xc0106b81,0x8(%esp)
c0104fc4:	c0 
c0104fc5:	c7 44 24 04 1b 02 00 	movl   $0x21b,0x4(%esp)
c0104fcc:	00 
c0104fcd:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c0104fd4:	e8 02 bd ff ff       	call   c0100cdb <__panic>

    assert(boot_pgdir[0] == 0);
c0104fd9:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104fde:	8b 00                	mov    (%eax),%eax
c0104fe0:	85 c0                	test   %eax,%eax
c0104fe2:	74 24                	je     c0105008 <check_boot_pgdir+0x192>
c0104fe4:	c7 44 24 0c f4 6e 10 	movl   $0xc0106ef4,0xc(%esp)
c0104feb:	c0 
c0104fec:	c7 44 24 08 81 6b 10 	movl   $0xc0106b81,0x8(%esp)
c0104ff3:	c0 
c0104ff4:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
c0104ffb:	00 
c0104ffc:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c0105003:	e8 d3 bc ff ff       	call   c0100cdb <__panic>

    struct Page *p;
    p = alloc_page();
c0105008:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010500f:	e8 b6 ed ff ff       	call   c0103dca <alloc_pages>
c0105014:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0105017:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c010501c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0105023:	00 
c0105024:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c010502b:	00 
c010502c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010502f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105033:	89 04 24             	mov    %eax,(%esp)
c0105036:	e8 62 f6 ff ff       	call   c010469d <page_insert>
c010503b:	85 c0                	test   %eax,%eax
c010503d:	74 24                	je     c0105063 <check_boot_pgdir+0x1ed>
c010503f:	c7 44 24 0c 08 6f 10 	movl   $0xc0106f08,0xc(%esp)
c0105046:	c0 
c0105047:	c7 44 24 08 81 6b 10 	movl   $0xc0106b81,0x8(%esp)
c010504e:	c0 
c010504f:	c7 44 24 04 21 02 00 	movl   $0x221,0x4(%esp)
c0105056:	00 
c0105057:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c010505e:	e8 78 bc ff ff       	call   c0100cdb <__panic>
    assert(page_ref(p) == 1);
c0105063:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105066:	89 04 24             	mov    %eax,(%esp)
c0105069:	e8 4c eb ff ff       	call   c0103bba <page_ref>
c010506e:	83 f8 01             	cmp    $0x1,%eax
c0105071:	74 24                	je     c0105097 <check_boot_pgdir+0x221>
c0105073:	c7 44 24 0c 36 6f 10 	movl   $0xc0106f36,0xc(%esp)
c010507a:	c0 
c010507b:	c7 44 24 08 81 6b 10 	movl   $0xc0106b81,0x8(%esp)
c0105082:	c0 
c0105083:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
c010508a:	00 
c010508b:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c0105092:	e8 44 bc ff ff       	call   c0100cdb <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0105097:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c010509c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c01050a3:	00 
c01050a4:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c01050ab:	00 
c01050ac:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01050af:	89 54 24 04          	mov    %edx,0x4(%esp)
c01050b3:	89 04 24             	mov    %eax,(%esp)
c01050b6:	e8 e2 f5 ff ff       	call   c010469d <page_insert>
c01050bb:	85 c0                	test   %eax,%eax
c01050bd:	74 24                	je     c01050e3 <check_boot_pgdir+0x26d>
c01050bf:	c7 44 24 0c 48 6f 10 	movl   $0xc0106f48,0xc(%esp)
c01050c6:	c0 
c01050c7:	c7 44 24 08 81 6b 10 	movl   $0xc0106b81,0x8(%esp)
c01050ce:	c0 
c01050cf:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
c01050d6:	00 
c01050d7:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c01050de:	e8 f8 bb ff ff       	call   c0100cdb <__panic>
    assert(page_ref(p) == 2);
c01050e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01050e6:	89 04 24             	mov    %eax,(%esp)
c01050e9:	e8 cc ea ff ff       	call   c0103bba <page_ref>
c01050ee:	83 f8 02             	cmp    $0x2,%eax
c01050f1:	74 24                	je     c0105117 <check_boot_pgdir+0x2a1>
c01050f3:	c7 44 24 0c 7f 6f 10 	movl   $0xc0106f7f,0xc(%esp)
c01050fa:	c0 
c01050fb:	c7 44 24 08 81 6b 10 	movl   $0xc0106b81,0x8(%esp)
c0105102:	c0 
c0105103:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
c010510a:	00 
c010510b:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c0105112:	e8 c4 bb ff ff       	call   c0100cdb <__panic>

    const char *str = "ucore: Hello world!!";
c0105117:	c7 45 e8 90 6f 10 c0 	movl   $0xc0106f90,-0x18(%ebp)
    strcpy((void *)0x100, str);
c010511e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105121:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105125:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c010512c:	e8 fc 09 00 00       	call   c0105b2d <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0105131:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0105138:	00 
c0105139:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105140:	e8 60 0a 00 00       	call   c0105ba5 <strcmp>
c0105145:	85 c0                	test   %eax,%eax
c0105147:	74 24                	je     c010516d <check_boot_pgdir+0x2f7>
c0105149:	c7 44 24 0c a8 6f 10 	movl   $0xc0106fa8,0xc(%esp)
c0105150:	c0 
c0105151:	c7 44 24 08 81 6b 10 	movl   $0xc0106b81,0x8(%esp)
c0105158:	c0 
c0105159:	c7 44 24 04 28 02 00 	movl   $0x228,0x4(%esp)
c0105160:	00 
c0105161:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c0105168:	e8 6e bb ff ff       	call   c0100cdb <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c010516d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105170:	89 04 24             	mov    %eax,(%esp)
c0105173:	e8 92 e9 ff ff       	call   c0103b0a <page2kva>
c0105178:	05 00 01 00 00       	add    $0x100,%eax
c010517d:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0105180:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105187:	e8 47 09 00 00       	call   c0105ad3 <strlen>
c010518c:	85 c0                	test   %eax,%eax
c010518e:	74 24                	je     c01051b4 <check_boot_pgdir+0x33e>
c0105190:	c7 44 24 0c e0 6f 10 	movl   $0xc0106fe0,0xc(%esp)
c0105197:	c0 
c0105198:	c7 44 24 08 81 6b 10 	movl   $0xc0106b81,0x8(%esp)
c010519f:	c0 
c01051a0:	c7 44 24 04 2b 02 00 	movl   $0x22b,0x4(%esp)
c01051a7:	00 
c01051a8:	c7 04 24 5c 6b 10 c0 	movl   $0xc0106b5c,(%esp)
c01051af:	e8 27 bb ff ff       	call   c0100cdb <__panic>

    free_page(p);
c01051b4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01051bb:	00 
c01051bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01051bf:	89 04 24             	mov    %eax,(%esp)
c01051c2:	e8 3d ec ff ff       	call   c0103e04 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c01051c7:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c01051cc:	8b 00                	mov    (%eax),%eax
c01051ce:	89 04 24             	mov    %eax,(%esp)
c01051d1:	e8 ca e9 ff ff       	call   c0103ba0 <pde2page>
c01051d6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01051dd:	00 
c01051de:	89 04 24             	mov    %eax,(%esp)
c01051e1:	e8 1e ec ff ff       	call   c0103e04 <free_pages>
    boot_pgdir[0] = 0;
c01051e6:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c01051eb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c01051f1:	c7 04 24 04 70 10 c0 	movl   $0xc0107004,(%esp)
c01051f8:	e8 59 b1 ff ff       	call   c0100356 <cprintf>
}
c01051fd:	90                   	nop
c01051fe:	89 ec                	mov    %ebp,%esp
c0105200:	5d                   	pop    %ebp
c0105201:	c3                   	ret    

c0105202 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0105202:	55                   	push   %ebp
c0105203:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0105205:	8b 45 08             	mov    0x8(%ebp),%eax
c0105208:	83 e0 04             	and    $0x4,%eax
c010520b:	85 c0                	test   %eax,%eax
c010520d:	74 04                	je     c0105213 <perm2str+0x11>
c010520f:	b0 75                	mov    $0x75,%al
c0105211:	eb 02                	jmp    c0105215 <perm2str+0x13>
c0105213:	b0 2d                	mov    $0x2d,%al
c0105215:	a2 28 bf 11 c0       	mov    %al,0xc011bf28
    str[1] = 'r';
c010521a:	c6 05 29 bf 11 c0 72 	movb   $0x72,0xc011bf29
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0105221:	8b 45 08             	mov    0x8(%ebp),%eax
c0105224:	83 e0 02             	and    $0x2,%eax
c0105227:	85 c0                	test   %eax,%eax
c0105229:	74 04                	je     c010522f <perm2str+0x2d>
c010522b:	b0 77                	mov    $0x77,%al
c010522d:	eb 02                	jmp    c0105231 <perm2str+0x2f>
c010522f:	b0 2d                	mov    $0x2d,%al
c0105231:	a2 2a bf 11 c0       	mov    %al,0xc011bf2a
    str[3] = '\0';
c0105236:	c6 05 2b bf 11 c0 00 	movb   $0x0,0xc011bf2b
    return str;
c010523d:	b8 28 bf 11 c0       	mov    $0xc011bf28,%eax
}
c0105242:	5d                   	pop    %ebp
c0105243:	c3                   	ret    

c0105244 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0105244:	55                   	push   %ebp
c0105245:	89 e5                	mov    %esp,%ebp
c0105247:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c010524a:	8b 45 10             	mov    0x10(%ebp),%eax
c010524d:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105250:	72 0d                	jb     c010525f <get_pgtable_items+0x1b>
        return 0;
c0105252:	b8 00 00 00 00       	mov    $0x0,%eax
c0105257:	e9 98 00 00 00       	jmp    c01052f4 <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c010525c:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
c010525f:	8b 45 10             	mov    0x10(%ebp),%eax
c0105262:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105265:	73 18                	jae    c010527f <get_pgtable_items+0x3b>
c0105267:	8b 45 10             	mov    0x10(%ebp),%eax
c010526a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105271:	8b 45 14             	mov    0x14(%ebp),%eax
c0105274:	01 d0                	add    %edx,%eax
c0105276:	8b 00                	mov    (%eax),%eax
c0105278:	83 e0 01             	and    $0x1,%eax
c010527b:	85 c0                	test   %eax,%eax
c010527d:	74 dd                	je     c010525c <get_pgtable_items+0x18>
    }
    if (start < right) {
c010527f:	8b 45 10             	mov    0x10(%ebp),%eax
c0105282:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105285:	73 68                	jae    c01052ef <get_pgtable_items+0xab>
        if (left_store != NULL) {
c0105287:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c010528b:	74 08                	je     c0105295 <get_pgtable_items+0x51>
            *left_store = start;
c010528d:	8b 45 18             	mov    0x18(%ebp),%eax
c0105290:	8b 55 10             	mov    0x10(%ebp),%edx
c0105293:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0105295:	8b 45 10             	mov    0x10(%ebp),%eax
c0105298:	8d 50 01             	lea    0x1(%eax),%edx
c010529b:	89 55 10             	mov    %edx,0x10(%ebp)
c010529e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01052a5:	8b 45 14             	mov    0x14(%ebp),%eax
c01052a8:	01 d0                	add    %edx,%eax
c01052aa:	8b 00                	mov    (%eax),%eax
c01052ac:	83 e0 07             	and    $0x7,%eax
c01052af:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c01052b2:	eb 03                	jmp    c01052b7 <get_pgtable_items+0x73>
            start ++;
c01052b4:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c01052b7:	8b 45 10             	mov    0x10(%ebp),%eax
c01052ba:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01052bd:	73 1d                	jae    c01052dc <get_pgtable_items+0x98>
c01052bf:	8b 45 10             	mov    0x10(%ebp),%eax
c01052c2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01052c9:	8b 45 14             	mov    0x14(%ebp),%eax
c01052cc:	01 d0                	add    %edx,%eax
c01052ce:	8b 00                	mov    (%eax),%eax
c01052d0:	83 e0 07             	and    $0x7,%eax
c01052d3:	89 c2                	mov    %eax,%edx
c01052d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01052d8:	39 c2                	cmp    %eax,%edx
c01052da:	74 d8                	je     c01052b4 <get_pgtable_items+0x70>
        }
        if (right_store != NULL) {
c01052dc:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c01052e0:	74 08                	je     c01052ea <get_pgtable_items+0xa6>
            *right_store = start;
c01052e2:	8b 45 1c             	mov    0x1c(%ebp),%eax
c01052e5:	8b 55 10             	mov    0x10(%ebp),%edx
c01052e8:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c01052ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01052ed:	eb 05                	jmp    c01052f4 <get_pgtable_items+0xb0>
    }
    return 0;
c01052ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01052f4:	89 ec                	mov    %ebp,%esp
c01052f6:	5d                   	pop    %ebp
c01052f7:	c3                   	ret    

c01052f8 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c01052f8:	55                   	push   %ebp
c01052f9:	89 e5                	mov    %esp,%ebp
c01052fb:	57                   	push   %edi
c01052fc:	56                   	push   %esi
c01052fd:	53                   	push   %ebx
c01052fe:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0105301:	c7 04 24 24 70 10 c0 	movl   $0xc0107024,(%esp)
c0105308:	e8 49 b0 ff ff       	call   c0100356 <cprintf>
    size_t left, right = 0, perm;
c010530d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0105314:	e9 f2 00 00 00       	jmp    c010540b <print_pgdir+0x113>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0105319:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010531c:	89 04 24             	mov    %eax,(%esp)
c010531f:	e8 de fe ff ff       	call   c0105202 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0105324:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105327:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c010532a:	29 ca                	sub    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c010532c:	89 d6                	mov    %edx,%esi
c010532e:	c1 e6 16             	shl    $0x16,%esi
c0105331:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105334:	89 d3                	mov    %edx,%ebx
c0105336:	c1 e3 16             	shl    $0x16,%ebx
c0105339:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010533c:	89 d1                	mov    %edx,%ecx
c010533e:	c1 e1 16             	shl    $0x16,%ecx
c0105341:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105344:	8b 7d e0             	mov    -0x20(%ebp),%edi
c0105347:	29 fa                	sub    %edi,%edx
c0105349:	89 44 24 14          	mov    %eax,0x14(%esp)
c010534d:	89 74 24 10          	mov    %esi,0x10(%esp)
c0105351:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0105355:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0105359:	89 54 24 04          	mov    %edx,0x4(%esp)
c010535d:	c7 04 24 55 70 10 c0 	movl   $0xc0107055,(%esp)
c0105364:	e8 ed af ff ff       	call   c0100356 <cprintf>
        size_t l, r = left * NPTEENTRY;
c0105369:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010536c:	c1 e0 0a             	shl    $0xa,%eax
c010536f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0105372:	eb 50                	jmp    c01053c4 <print_pgdir+0xcc>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0105374:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105377:	89 04 24             	mov    %eax,(%esp)
c010537a:	e8 83 fe ff ff       	call   c0105202 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c010537f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105382:	8b 4d d8             	mov    -0x28(%ebp),%ecx
c0105385:	29 ca                	sub    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0105387:	89 d6                	mov    %edx,%esi
c0105389:	c1 e6 0c             	shl    $0xc,%esi
c010538c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010538f:	89 d3                	mov    %edx,%ebx
c0105391:	c1 e3 0c             	shl    $0xc,%ebx
c0105394:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105397:	89 d1                	mov    %edx,%ecx
c0105399:	c1 e1 0c             	shl    $0xc,%ecx
c010539c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010539f:	8b 7d d8             	mov    -0x28(%ebp),%edi
c01053a2:	29 fa                	sub    %edi,%edx
c01053a4:	89 44 24 14          	mov    %eax,0x14(%esp)
c01053a8:	89 74 24 10          	mov    %esi,0x10(%esp)
c01053ac:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01053b0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01053b4:	89 54 24 04          	mov    %edx,0x4(%esp)
c01053b8:	c7 04 24 74 70 10 c0 	movl   $0xc0107074,(%esp)
c01053bf:	e8 92 af ff ff       	call   c0100356 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c01053c4:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c01053c9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01053cc:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01053cf:	89 d3                	mov    %edx,%ebx
c01053d1:	c1 e3 0a             	shl    $0xa,%ebx
c01053d4:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01053d7:	89 d1                	mov    %edx,%ecx
c01053d9:	c1 e1 0a             	shl    $0xa,%ecx
c01053dc:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c01053df:	89 54 24 14          	mov    %edx,0x14(%esp)
c01053e3:	8d 55 d8             	lea    -0x28(%ebp),%edx
c01053e6:	89 54 24 10          	mov    %edx,0x10(%esp)
c01053ea:	89 74 24 0c          	mov    %esi,0xc(%esp)
c01053ee:	89 44 24 08          	mov    %eax,0x8(%esp)
c01053f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01053f6:	89 0c 24             	mov    %ecx,(%esp)
c01053f9:	e8 46 fe ff ff       	call   c0105244 <get_pgtable_items>
c01053fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105401:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105405:	0f 85 69 ff ff ff    	jne    c0105374 <print_pgdir+0x7c>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c010540b:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c0105410:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105413:	8d 55 dc             	lea    -0x24(%ebp),%edx
c0105416:	89 54 24 14          	mov    %edx,0x14(%esp)
c010541a:	8d 55 e0             	lea    -0x20(%ebp),%edx
c010541d:	89 54 24 10          	mov    %edx,0x10(%esp)
c0105421:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0105425:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105429:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c0105430:	00 
c0105431:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0105438:	e8 07 fe ff ff       	call   c0105244 <get_pgtable_items>
c010543d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105440:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105444:	0f 85 cf fe ff ff    	jne    c0105319 <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c010544a:	c7 04 24 98 70 10 c0 	movl   $0xc0107098,(%esp)
c0105451:	e8 00 af ff ff       	call   c0100356 <cprintf>
}
c0105456:	90                   	nop
c0105457:	83 c4 4c             	add    $0x4c,%esp
c010545a:	5b                   	pop    %ebx
c010545b:	5e                   	pop    %esi
c010545c:	5f                   	pop    %edi
c010545d:	5d                   	pop    %ebp
c010545e:	c3                   	ret    

c010545f <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c010545f:	55                   	push   %ebp
c0105460:	89 e5                	mov    %esp,%ebp
c0105462:	83 ec 58             	sub    $0x58,%esp
c0105465:	8b 45 10             	mov    0x10(%ebp),%eax
c0105468:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010546b:	8b 45 14             	mov    0x14(%ebp),%eax
c010546e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c0105471:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105474:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105477:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010547a:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c010547d:	8b 45 18             	mov    0x18(%ebp),%eax
c0105480:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105483:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105486:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105489:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010548c:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010548f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105492:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105495:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105499:	74 1c                	je     c01054b7 <printnum+0x58>
c010549b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010549e:	ba 00 00 00 00       	mov    $0x0,%edx
c01054a3:	f7 75 e4             	divl   -0x1c(%ebp)
c01054a6:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01054a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01054ac:	ba 00 00 00 00       	mov    $0x0,%edx
c01054b1:	f7 75 e4             	divl   -0x1c(%ebp)
c01054b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01054b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01054ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01054bd:	f7 75 e4             	divl   -0x1c(%ebp)
c01054c0:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01054c3:	89 55 dc             	mov    %edx,-0x24(%ebp)
c01054c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01054c9:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01054cc:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01054cf:	89 55 ec             	mov    %edx,-0x14(%ebp)
c01054d2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01054d5:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c01054d8:	8b 45 18             	mov    0x18(%ebp),%eax
c01054db:	ba 00 00 00 00       	mov    $0x0,%edx
c01054e0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c01054e3:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c01054e6:	19 d1                	sbb    %edx,%ecx
c01054e8:	72 4c                	jb     c0105536 <printnum+0xd7>
        printnum(putch, putdat, result, base, width - 1, padc);
c01054ea:	8b 45 1c             	mov    0x1c(%ebp),%eax
c01054ed:	8d 50 ff             	lea    -0x1(%eax),%edx
c01054f0:	8b 45 20             	mov    0x20(%ebp),%eax
c01054f3:	89 44 24 18          	mov    %eax,0x18(%esp)
c01054f7:	89 54 24 14          	mov    %edx,0x14(%esp)
c01054fb:	8b 45 18             	mov    0x18(%ebp),%eax
c01054fe:	89 44 24 10          	mov    %eax,0x10(%esp)
c0105502:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105505:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105508:	89 44 24 08          	mov    %eax,0x8(%esp)
c010550c:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105510:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105513:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105517:	8b 45 08             	mov    0x8(%ebp),%eax
c010551a:	89 04 24             	mov    %eax,(%esp)
c010551d:	e8 3d ff ff ff       	call   c010545f <printnum>
c0105522:	eb 1b                	jmp    c010553f <printnum+0xe0>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c0105524:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105527:	89 44 24 04          	mov    %eax,0x4(%esp)
c010552b:	8b 45 20             	mov    0x20(%ebp),%eax
c010552e:	89 04 24             	mov    %eax,(%esp)
c0105531:	8b 45 08             	mov    0x8(%ebp),%eax
c0105534:	ff d0                	call   *%eax
        while (-- width > 0)
c0105536:	ff 4d 1c             	decl   0x1c(%ebp)
c0105539:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c010553d:	7f e5                	jg     c0105524 <printnum+0xc5>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c010553f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105542:	05 4c 71 10 c0       	add    $0xc010714c,%eax
c0105547:	0f b6 00             	movzbl (%eax),%eax
c010554a:	0f be c0             	movsbl %al,%eax
c010554d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105550:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105554:	89 04 24             	mov    %eax,(%esp)
c0105557:	8b 45 08             	mov    0x8(%ebp),%eax
c010555a:	ff d0                	call   *%eax
}
c010555c:	90                   	nop
c010555d:	89 ec                	mov    %ebp,%esp
c010555f:	5d                   	pop    %ebp
c0105560:	c3                   	ret    

c0105561 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c0105561:	55                   	push   %ebp
c0105562:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0105564:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0105568:	7e 14                	jle    c010557e <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c010556a:	8b 45 08             	mov    0x8(%ebp),%eax
c010556d:	8b 00                	mov    (%eax),%eax
c010556f:	8d 48 08             	lea    0x8(%eax),%ecx
c0105572:	8b 55 08             	mov    0x8(%ebp),%edx
c0105575:	89 0a                	mov    %ecx,(%edx)
c0105577:	8b 50 04             	mov    0x4(%eax),%edx
c010557a:	8b 00                	mov    (%eax),%eax
c010557c:	eb 30                	jmp    c01055ae <getuint+0x4d>
    }
    else if (lflag) {
c010557e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105582:	74 16                	je     c010559a <getuint+0x39>
        return va_arg(*ap, unsigned long);
c0105584:	8b 45 08             	mov    0x8(%ebp),%eax
c0105587:	8b 00                	mov    (%eax),%eax
c0105589:	8d 48 04             	lea    0x4(%eax),%ecx
c010558c:	8b 55 08             	mov    0x8(%ebp),%edx
c010558f:	89 0a                	mov    %ecx,(%edx)
c0105591:	8b 00                	mov    (%eax),%eax
c0105593:	ba 00 00 00 00       	mov    $0x0,%edx
c0105598:	eb 14                	jmp    c01055ae <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c010559a:	8b 45 08             	mov    0x8(%ebp),%eax
c010559d:	8b 00                	mov    (%eax),%eax
c010559f:	8d 48 04             	lea    0x4(%eax),%ecx
c01055a2:	8b 55 08             	mov    0x8(%ebp),%edx
c01055a5:	89 0a                	mov    %ecx,(%edx)
c01055a7:	8b 00                	mov    (%eax),%eax
c01055a9:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c01055ae:	5d                   	pop    %ebp
c01055af:	c3                   	ret    

c01055b0 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c01055b0:	55                   	push   %ebp
c01055b1:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01055b3:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01055b7:	7e 14                	jle    c01055cd <getint+0x1d>
        return va_arg(*ap, long long);
c01055b9:	8b 45 08             	mov    0x8(%ebp),%eax
c01055bc:	8b 00                	mov    (%eax),%eax
c01055be:	8d 48 08             	lea    0x8(%eax),%ecx
c01055c1:	8b 55 08             	mov    0x8(%ebp),%edx
c01055c4:	89 0a                	mov    %ecx,(%edx)
c01055c6:	8b 50 04             	mov    0x4(%eax),%edx
c01055c9:	8b 00                	mov    (%eax),%eax
c01055cb:	eb 28                	jmp    c01055f5 <getint+0x45>
    }
    else if (lflag) {
c01055cd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01055d1:	74 12                	je     c01055e5 <getint+0x35>
        return va_arg(*ap, long);
c01055d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01055d6:	8b 00                	mov    (%eax),%eax
c01055d8:	8d 48 04             	lea    0x4(%eax),%ecx
c01055db:	8b 55 08             	mov    0x8(%ebp),%edx
c01055de:	89 0a                	mov    %ecx,(%edx)
c01055e0:	8b 00                	mov    (%eax),%eax
c01055e2:	99                   	cltd   
c01055e3:	eb 10                	jmp    c01055f5 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c01055e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01055e8:	8b 00                	mov    (%eax),%eax
c01055ea:	8d 48 04             	lea    0x4(%eax),%ecx
c01055ed:	8b 55 08             	mov    0x8(%ebp),%edx
c01055f0:	89 0a                	mov    %ecx,(%edx)
c01055f2:	8b 00                	mov    (%eax),%eax
c01055f4:	99                   	cltd   
    }
}
c01055f5:	5d                   	pop    %ebp
c01055f6:	c3                   	ret    

c01055f7 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c01055f7:	55                   	push   %ebp
c01055f8:	89 e5                	mov    %esp,%ebp
c01055fa:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c01055fd:	8d 45 14             	lea    0x14(%ebp),%eax
c0105600:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c0105603:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105606:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010560a:	8b 45 10             	mov    0x10(%ebp),%eax
c010560d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105611:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105614:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105618:	8b 45 08             	mov    0x8(%ebp),%eax
c010561b:	89 04 24             	mov    %eax,(%esp)
c010561e:	e8 05 00 00 00       	call   c0105628 <vprintfmt>
    va_end(ap);
}
c0105623:	90                   	nop
c0105624:	89 ec                	mov    %ebp,%esp
c0105626:	5d                   	pop    %ebp
c0105627:	c3                   	ret    

c0105628 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c0105628:	55                   	push   %ebp
c0105629:	89 e5                	mov    %esp,%ebp
c010562b:	56                   	push   %esi
c010562c:	53                   	push   %ebx
c010562d:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105630:	eb 17                	jmp    c0105649 <vprintfmt+0x21>
            if (ch == '\0') {
c0105632:	85 db                	test   %ebx,%ebx
c0105634:	0f 84 bf 03 00 00    	je     c01059f9 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
c010563a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010563d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105641:	89 1c 24             	mov    %ebx,(%esp)
c0105644:	8b 45 08             	mov    0x8(%ebp),%eax
c0105647:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105649:	8b 45 10             	mov    0x10(%ebp),%eax
c010564c:	8d 50 01             	lea    0x1(%eax),%edx
c010564f:	89 55 10             	mov    %edx,0x10(%ebp)
c0105652:	0f b6 00             	movzbl (%eax),%eax
c0105655:	0f b6 d8             	movzbl %al,%ebx
c0105658:	83 fb 25             	cmp    $0x25,%ebx
c010565b:	75 d5                	jne    c0105632 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
c010565d:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c0105661:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c0105668:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010566b:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c010566e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0105675:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105678:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c010567b:	8b 45 10             	mov    0x10(%ebp),%eax
c010567e:	8d 50 01             	lea    0x1(%eax),%edx
c0105681:	89 55 10             	mov    %edx,0x10(%ebp)
c0105684:	0f b6 00             	movzbl (%eax),%eax
c0105687:	0f b6 d8             	movzbl %al,%ebx
c010568a:	8d 43 dd             	lea    -0x23(%ebx),%eax
c010568d:	83 f8 55             	cmp    $0x55,%eax
c0105690:	0f 87 37 03 00 00    	ja     c01059cd <vprintfmt+0x3a5>
c0105696:	8b 04 85 70 71 10 c0 	mov    -0x3fef8e90(,%eax,4),%eax
c010569d:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c010569f:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c01056a3:	eb d6                	jmp    c010567b <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c01056a5:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c01056a9:	eb d0                	jmp    c010567b <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c01056ab:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c01056b2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01056b5:	89 d0                	mov    %edx,%eax
c01056b7:	c1 e0 02             	shl    $0x2,%eax
c01056ba:	01 d0                	add    %edx,%eax
c01056bc:	01 c0                	add    %eax,%eax
c01056be:	01 d8                	add    %ebx,%eax
c01056c0:	83 e8 30             	sub    $0x30,%eax
c01056c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c01056c6:	8b 45 10             	mov    0x10(%ebp),%eax
c01056c9:	0f b6 00             	movzbl (%eax),%eax
c01056cc:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c01056cf:	83 fb 2f             	cmp    $0x2f,%ebx
c01056d2:	7e 38                	jle    c010570c <vprintfmt+0xe4>
c01056d4:	83 fb 39             	cmp    $0x39,%ebx
c01056d7:	7f 33                	jg     c010570c <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
c01056d9:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
c01056dc:	eb d4                	jmp    c01056b2 <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c01056de:	8b 45 14             	mov    0x14(%ebp),%eax
c01056e1:	8d 50 04             	lea    0x4(%eax),%edx
c01056e4:	89 55 14             	mov    %edx,0x14(%ebp)
c01056e7:	8b 00                	mov    (%eax),%eax
c01056e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c01056ec:	eb 1f                	jmp    c010570d <vprintfmt+0xe5>

        case '.':
            if (width < 0)
c01056ee:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01056f2:	79 87                	jns    c010567b <vprintfmt+0x53>
                width = 0;
c01056f4:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c01056fb:	e9 7b ff ff ff       	jmp    c010567b <vprintfmt+0x53>

        case '#':
            altflag = 1;
c0105700:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c0105707:	e9 6f ff ff ff       	jmp    c010567b <vprintfmt+0x53>
            goto process_precision;
c010570c:	90                   	nop

        process_precision:
            if (width < 0)
c010570d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105711:	0f 89 64 ff ff ff    	jns    c010567b <vprintfmt+0x53>
                width = precision, precision = -1;
c0105717:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010571a:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010571d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c0105724:	e9 52 ff ff ff       	jmp    c010567b <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c0105729:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c010572c:	e9 4a ff ff ff       	jmp    c010567b <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0105731:	8b 45 14             	mov    0x14(%ebp),%eax
c0105734:	8d 50 04             	lea    0x4(%eax),%edx
c0105737:	89 55 14             	mov    %edx,0x14(%ebp)
c010573a:	8b 00                	mov    (%eax),%eax
c010573c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010573f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105743:	89 04 24             	mov    %eax,(%esp)
c0105746:	8b 45 08             	mov    0x8(%ebp),%eax
c0105749:	ff d0                	call   *%eax
            break;
c010574b:	e9 a4 02 00 00       	jmp    c01059f4 <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
c0105750:	8b 45 14             	mov    0x14(%ebp),%eax
c0105753:	8d 50 04             	lea    0x4(%eax),%edx
c0105756:	89 55 14             	mov    %edx,0x14(%ebp)
c0105759:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c010575b:	85 db                	test   %ebx,%ebx
c010575d:	79 02                	jns    c0105761 <vprintfmt+0x139>
                err = -err;
c010575f:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c0105761:	83 fb 06             	cmp    $0x6,%ebx
c0105764:	7f 0b                	jg     c0105771 <vprintfmt+0x149>
c0105766:	8b 34 9d 30 71 10 c0 	mov    -0x3fef8ed0(,%ebx,4),%esi
c010576d:	85 f6                	test   %esi,%esi
c010576f:	75 23                	jne    c0105794 <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
c0105771:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0105775:	c7 44 24 08 5d 71 10 	movl   $0xc010715d,0x8(%esp)
c010577c:	c0 
c010577d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105780:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105784:	8b 45 08             	mov    0x8(%ebp),%eax
c0105787:	89 04 24             	mov    %eax,(%esp)
c010578a:	e8 68 fe ff ff       	call   c01055f7 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c010578f:	e9 60 02 00 00       	jmp    c01059f4 <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
c0105794:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0105798:	c7 44 24 08 66 71 10 	movl   $0xc0107166,0x8(%esp)
c010579f:	c0 
c01057a0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01057a3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01057a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01057aa:	89 04 24             	mov    %eax,(%esp)
c01057ad:	e8 45 fe ff ff       	call   c01055f7 <printfmt>
            break;
c01057b2:	e9 3d 02 00 00       	jmp    c01059f4 <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c01057b7:	8b 45 14             	mov    0x14(%ebp),%eax
c01057ba:	8d 50 04             	lea    0x4(%eax),%edx
c01057bd:	89 55 14             	mov    %edx,0x14(%ebp)
c01057c0:	8b 30                	mov    (%eax),%esi
c01057c2:	85 f6                	test   %esi,%esi
c01057c4:	75 05                	jne    c01057cb <vprintfmt+0x1a3>
                p = "(null)";
c01057c6:	be 69 71 10 c0       	mov    $0xc0107169,%esi
            }
            if (width > 0 && padc != '-') {
c01057cb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01057cf:	7e 76                	jle    c0105847 <vprintfmt+0x21f>
c01057d1:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c01057d5:	74 70                	je     c0105847 <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
c01057d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01057da:	89 44 24 04          	mov    %eax,0x4(%esp)
c01057de:	89 34 24             	mov    %esi,(%esp)
c01057e1:	e8 16 03 00 00       	call   c0105afc <strnlen>
c01057e6:	89 c2                	mov    %eax,%edx
c01057e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01057eb:	29 d0                	sub    %edx,%eax
c01057ed:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01057f0:	eb 16                	jmp    c0105808 <vprintfmt+0x1e0>
                    putch(padc, putdat);
c01057f2:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c01057f6:	8b 55 0c             	mov    0xc(%ebp),%edx
c01057f9:	89 54 24 04          	mov    %edx,0x4(%esp)
c01057fd:	89 04 24             	mov    %eax,(%esp)
c0105800:	8b 45 08             	mov    0x8(%ebp),%eax
c0105803:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
c0105805:	ff 4d e8             	decl   -0x18(%ebp)
c0105808:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010580c:	7f e4                	jg     c01057f2 <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010580e:	eb 37                	jmp    c0105847 <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
c0105810:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105814:	74 1f                	je     c0105835 <vprintfmt+0x20d>
c0105816:	83 fb 1f             	cmp    $0x1f,%ebx
c0105819:	7e 05                	jle    c0105820 <vprintfmt+0x1f8>
c010581b:	83 fb 7e             	cmp    $0x7e,%ebx
c010581e:	7e 15                	jle    c0105835 <vprintfmt+0x20d>
                    putch('?', putdat);
c0105820:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105823:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105827:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c010582e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105831:	ff d0                	call   *%eax
c0105833:	eb 0f                	jmp    c0105844 <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
c0105835:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105838:	89 44 24 04          	mov    %eax,0x4(%esp)
c010583c:	89 1c 24             	mov    %ebx,(%esp)
c010583f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105842:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0105844:	ff 4d e8             	decl   -0x18(%ebp)
c0105847:	89 f0                	mov    %esi,%eax
c0105849:	8d 70 01             	lea    0x1(%eax),%esi
c010584c:	0f b6 00             	movzbl (%eax),%eax
c010584f:	0f be d8             	movsbl %al,%ebx
c0105852:	85 db                	test   %ebx,%ebx
c0105854:	74 27                	je     c010587d <vprintfmt+0x255>
c0105856:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010585a:	78 b4                	js     c0105810 <vprintfmt+0x1e8>
c010585c:	ff 4d e4             	decl   -0x1c(%ebp)
c010585f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105863:	79 ab                	jns    c0105810 <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
c0105865:	eb 16                	jmp    c010587d <vprintfmt+0x255>
                putch(' ', putdat);
c0105867:	8b 45 0c             	mov    0xc(%ebp),%eax
c010586a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010586e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0105875:	8b 45 08             	mov    0x8(%ebp),%eax
c0105878:	ff d0                	call   *%eax
            for (; width > 0; width --) {
c010587a:	ff 4d e8             	decl   -0x18(%ebp)
c010587d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105881:	7f e4                	jg     c0105867 <vprintfmt+0x23f>
            }
            break;
c0105883:	e9 6c 01 00 00       	jmp    c01059f4 <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0105888:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010588b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010588f:	8d 45 14             	lea    0x14(%ebp),%eax
c0105892:	89 04 24             	mov    %eax,(%esp)
c0105895:	e8 16 fd ff ff       	call   c01055b0 <getint>
c010589a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010589d:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c01058a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01058a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01058a6:	85 d2                	test   %edx,%edx
c01058a8:	79 26                	jns    c01058d0 <vprintfmt+0x2a8>
                putch('-', putdat);
c01058aa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058ad:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058b1:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c01058b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01058bb:	ff d0                	call   *%eax
                num = -(long long)num;
c01058bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01058c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01058c3:	f7 d8                	neg    %eax
c01058c5:	83 d2 00             	adc    $0x0,%edx
c01058c8:	f7 da                	neg    %edx
c01058ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01058cd:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c01058d0:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c01058d7:	e9 a8 00 00 00       	jmp    c0105984 <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c01058dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01058df:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058e3:	8d 45 14             	lea    0x14(%ebp),%eax
c01058e6:	89 04 24             	mov    %eax,(%esp)
c01058e9:	e8 73 fc ff ff       	call   c0105561 <getuint>
c01058ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01058f1:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c01058f4:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c01058fb:	e9 84 00 00 00       	jmp    c0105984 <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0105900:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105903:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105907:	8d 45 14             	lea    0x14(%ebp),%eax
c010590a:	89 04 24             	mov    %eax,(%esp)
c010590d:	e8 4f fc ff ff       	call   c0105561 <getuint>
c0105912:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105915:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0105918:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c010591f:	eb 63                	jmp    c0105984 <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
c0105921:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105924:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105928:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c010592f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105932:	ff d0                	call   *%eax
            putch('x', putdat);
c0105934:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105937:	89 44 24 04          	mov    %eax,0x4(%esp)
c010593b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c0105942:	8b 45 08             	mov    0x8(%ebp),%eax
c0105945:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0105947:	8b 45 14             	mov    0x14(%ebp),%eax
c010594a:	8d 50 04             	lea    0x4(%eax),%edx
c010594d:	89 55 14             	mov    %edx,0x14(%ebp)
c0105950:	8b 00                	mov    (%eax),%eax
c0105952:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105955:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c010595c:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0105963:	eb 1f                	jmp    c0105984 <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0105965:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105968:	89 44 24 04          	mov    %eax,0x4(%esp)
c010596c:	8d 45 14             	lea    0x14(%ebp),%eax
c010596f:	89 04 24             	mov    %eax,(%esp)
c0105972:	e8 ea fb ff ff       	call   c0105561 <getuint>
c0105977:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010597a:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c010597d:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0105984:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0105988:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010598b:	89 54 24 18          	mov    %edx,0x18(%esp)
c010598f:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105992:	89 54 24 14          	mov    %edx,0x14(%esp)
c0105996:	89 44 24 10          	mov    %eax,0x10(%esp)
c010599a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010599d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01059a0:	89 44 24 08          	mov    %eax,0x8(%esp)
c01059a4:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01059a8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059ab:	89 44 24 04          	mov    %eax,0x4(%esp)
c01059af:	8b 45 08             	mov    0x8(%ebp),%eax
c01059b2:	89 04 24             	mov    %eax,(%esp)
c01059b5:	e8 a5 fa ff ff       	call   c010545f <printnum>
            break;
c01059ba:	eb 38                	jmp    c01059f4 <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c01059bc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059bf:	89 44 24 04          	mov    %eax,0x4(%esp)
c01059c3:	89 1c 24             	mov    %ebx,(%esp)
c01059c6:	8b 45 08             	mov    0x8(%ebp),%eax
c01059c9:	ff d0                	call   *%eax
            break;
c01059cb:	eb 27                	jmp    c01059f4 <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c01059cd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059d0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01059d4:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c01059db:	8b 45 08             	mov    0x8(%ebp),%eax
c01059de:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c01059e0:	ff 4d 10             	decl   0x10(%ebp)
c01059e3:	eb 03                	jmp    c01059e8 <vprintfmt+0x3c0>
c01059e5:	ff 4d 10             	decl   0x10(%ebp)
c01059e8:	8b 45 10             	mov    0x10(%ebp),%eax
c01059eb:	48                   	dec    %eax
c01059ec:	0f b6 00             	movzbl (%eax),%eax
c01059ef:	3c 25                	cmp    $0x25,%al
c01059f1:	75 f2                	jne    c01059e5 <vprintfmt+0x3bd>
                /* do nothing */;
            break;
c01059f3:	90                   	nop
    while (1) {
c01059f4:	e9 37 fc ff ff       	jmp    c0105630 <vprintfmt+0x8>
                return;
c01059f9:	90                   	nop
        }
    }
}
c01059fa:	83 c4 40             	add    $0x40,%esp
c01059fd:	5b                   	pop    %ebx
c01059fe:	5e                   	pop    %esi
c01059ff:	5d                   	pop    %ebp
c0105a00:	c3                   	ret    

c0105a01 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0105a01:	55                   	push   %ebp
c0105a02:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0105a04:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a07:	8b 40 08             	mov    0x8(%eax),%eax
c0105a0a:	8d 50 01             	lea    0x1(%eax),%edx
c0105a0d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a10:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0105a13:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a16:	8b 10                	mov    (%eax),%edx
c0105a18:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a1b:	8b 40 04             	mov    0x4(%eax),%eax
c0105a1e:	39 c2                	cmp    %eax,%edx
c0105a20:	73 12                	jae    c0105a34 <sprintputch+0x33>
        *b->buf ++ = ch;
c0105a22:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a25:	8b 00                	mov    (%eax),%eax
c0105a27:	8d 48 01             	lea    0x1(%eax),%ecx
c0105a2a:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105a2d:	89 0a                	mov    %ecx,(%edx)
c0105a2f:	8b 55 08             	mov    0x8(%ebp),%edx
c0105a32:	88 10                	mov    %dl,(%eax)
    }
}
c0105a34:	90                   	nop
c0105a35:	5d                   	pop    %ebp
c0105a36:	c3                   	ret    

c0105a37 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0105a37:	55                   	push   %ebp
c0105a38:	89 e5                	mov    %esp,%ebp
c0105a3a:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0105a3d:	8d 45 14             	lea    0x14(%ebp),%eax
c0105a40:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0105a43:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a46:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105a4a:	8b 45 10             	mov    0x10(%ebp),%eax
c0105a4d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105a51:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a54:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a58:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a5b:	89 04 24             	mov    %eax,(%esp)
c0105a5e:	e8 0a 00 00 00       	call   c0105a6d <vsnprintf>
c0105a63:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0105a66:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105a69:	89 ec                	mov    %ebp,%esp
c0105a6b:	5d                   	pop    %ebp
c0105a6c:	c3                   	ret    

c0105a6d <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0105a6d:	55                   	push   %ebp
c0105a6e:	89 e5                	mov    %esp,%ebp
c0105a70:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0105a73:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a76:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105a79:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a7c:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105a7f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a82:	01 d0                	add    %edx,%eax
c0105a84:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105a87:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0105a8e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105a92:	74 0a                	je     c0105a9e <vsnprintf+0x31>
c0105a94:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105a97:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a9a:	39 c2                	cmp    %eax,%edx
c0105a9c:	76 07                	jbe    c0105aa5 <vsnprintf+0x38>
        return -E_INVAL;
c0105a9e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0105aa3:	eb 2a                	jmp    c0105acf <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0105aa5:	8b 45 14             	mov    0x14(%ebp),%eax
c0105aa8:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105aac:	8b 45 10             	mov    0x10(%ebp),%eax
c0105aaf:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105ab3:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0105ab6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105aba:	c7 04 24 01 5a 10 c0 	movl   $0xc0105a01,(%esp)
c0105ac1:	e8 62 fb ff ff       	call   c0105628 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c0105ac6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105ac9:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0105acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105acf:	89 ec                	mov    %ebp,%esp
c0105ad1:	5d                   	pop    %ebp
c0105ad2:	c3                   	ret    

c0105ad3 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c0105ad3:	55                   	push   %ebp
c0105ad4:	89 e5                	mov    %esp,%ebp
c0105ad6:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0105ad9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0105ae0:	eb 03                	jmp    c0105ae5 <strlen+0x12>
        cnt ++;
c0105ae2:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
c0105ae5:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ae8:	8d 50 01             	lea    0x1(%eax),%edx
c0105aeb:	89 55 08             	mov    %edx,0x8(%ebp)
c0105aee:	0f b6 00             	movzbl (%eax),%eax
c0105af1:	84 c0                	test   %al,%al
c0105af3:	75 ed                	jne    c0105ae2 <strlen+0xf>
    }
    return cnt;
c0105af5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105af8:	89 ec                	mov    %ebp,%esp
c0105afa:	5d                   	pop    %ebp
c0105afb:	c3                   	ret    

c0105afc <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0105afc:	55                   	push   %ebp
c0105afd:	89 e5                	mov    %esp,%ebp
c0105aff:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0105b02:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0105b09:	eb 03                	jmp    c0105b0e <strnlen+0x12>
        cnt ++;
c0105b0b:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0105b0e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105b11:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105b14:	73 10                	jae    c0105b26 <strnlen+0x2a>
c0105b16:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b19:	8d 50 01             	lea    0x1(%eax),%edx
c0105b1c:	89 55 08             	mov    %edx,0x8(%ebp)
c0105b1f:	0f b6 00             	movzbl (%eax),%eax
c0105b22:	84 c0                	test   %al,%al
c0105b24:	75 e5                	jne    c0105b0b <strnlen+0xf>
    }
    return cnt;
c0105b26:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105b29:	89 ec                	mov    %ebp,%esp
c0105b2b:	5d                   	pop    %ebp
c0105b2c:	c3                   	ret    

c0105b2d <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0105b2d:	55                   	push   %ebp
c0105b2e:	89 e5                	mov    %esp,%ebp
c0105b30:	57                   	push   %edi
c0105b31:	56                   	push   %esi
c0105b32:	83 ec 20             	sub    $0x20,%esp
c0105b35:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b38:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105b3b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b3e:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0105b41:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b47:	89 d1                	mov    %edx,%ecx
c0105b49:	89 c2                	mov    %eax,%edx
c0105b4b:	89 ce                	mov    %ecx,%esi
c0105b4d:	89 d7                	mov    %edx,%edi
c0105b4f:	ac                   	lods   %ds:(%esi),%al
c0105b50:	aa                   	stos   %al,%es:(%edi)
c0105b51:	84 c0                	test   %al,%al
c0105b53:	75 fa                	jne    c0105b4f <strcpy+0x22>
c0105b55:	89 fa                	mov    %edi,%edx
c0105b57:	89 f1                	mov    %esi,%ecx
c0105b59:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0105b5c:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0105b5f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0105b62:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0105b65:	83 c4 20             	add    $0x20,%esp
c0105b68:	5e                   	pop    %esi
c0105b69:	5f                   	pop    %edi
c0105b6a:	5d                   	pop    %ebp
c0105b6b:	c3                   	ret    

c0105b6c <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0105b6c:	55                   	push   %ebp
c0105b6d:	89 e5                	mov    %esp,%ebp
c0105b6f:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0105b72:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b75:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0105b78:	eb 1e                	jmp    c0105b98 <strncpy+0x2c>
        if ((*p = *src) != '\0') {
c0105b7a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b7d:	0f b6 10             	movzbl (%eax),%edx
c0105b80:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105b83:	88 10                	mov    %dl,(%eax)
c0105b85:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105b88:	0f b6 00             	movzbl (%eax),%eax
c0105b8b:	84 c0                	test   %al,%al
c0105b8d:	74 03                	je     c0105b92 <strncpy+0x26>
            src ++;
c0105b8f:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c0105b92:	ff 45 fc             	incl   -0x4(%ebp)
c0105b95:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
c0105b98:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105b9c:	75 dc                	jne    c0105b7a <strncpy+0xe>
    }
    return dst;
c0105b9e:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105ba1:	89 ec                	mov    %ebp,%esp
c0105ba3:	5d                   	pop    %ebp
c0105ba4:	c3                   	ret    

c0105ba5 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0105ba5:	55                   	push   %ebp
c0105ba6:	89 e5                	mov    %esp,%ebp
c0105ba8:	57                   	push   %edi
c0105ba9:	56                   	push   %esi
c0105baa:	83 ec 20             	sub    $0x20,%esp
c0105bad:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bb0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105bb3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105bb6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c0105bb9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105bbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105bbf:	89 d1                	mov    %edx,%ecx
c0105bc1:	89 c2                	mov    %eax,%edx
c0105bc3:	89 ce                	mov    %ecx,%esi
c0105bc5:	89 d7                	mov    %edx,%edi
c0105bc7:	ac                   	lods   %ds:(%esi),%al
c0105bc8:	ae                   	scas   %es:(%edi),%al
c0105bc9:	75 08                	jne    c0105bd3 <strcmp+0x2e>
c0105bcb:	84 c0                	test   %al,%al
c0105bcd:	75 f8                	jne    c0105bc7 <strcmp+0x22>
c0105bcf:	31 c0                	xor    %eax,%eax
c0105bd1:	eb 04                	jmp    c0105bd7 <strcmp+0x32>
c0105bd3:	19 c0                	sbb    %eax,%eax
c0105bd5:	0c 01                	or     $0x1,%al
c0105bd7:	89 fa                	mov    %edi,%edx
c0105bd9:	89 f1                	mov    %esi,%ecx
c0105bdb:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105bde:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0105be1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c0105be4:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0105be7:	83 c4 20             	add    $0x20,%esp
c0105bea:	5e                   	pop    %esi
c0105beb:	5f                   	pop    %edi
c0105bec:	5d                   	pop    %ebp
c0105bed:	c3                   	ret    

c0105bee <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c0105bee:	55                   	push   %ebp
c0105bef:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0105bf1:	eb 09                	jmp    c0105bfc <strncmp+0xe>
        n --, s1 ++, s2 ++;
c0105bf3:	ff 4d 10             	decl   0x10(%ebp)
c0105bf6:	ff 45 08             	incl   0x8(%ebp)
c0105bf9:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0105bfc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105c00:	74 1a                	je     c0105c1c <strncmp+0x2e>
c0105c02:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c05:	0f b6 00             	movzbl (%eax),%eax
c0105c08:	84 c0                	test   %al,%al
c0105c0a:	74 10                	je     c0105c1c <strncmp+0x2e>
c0105c0c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c0f:	0f b6 10             	movzbl (%eax),%edx
c0105c12:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c15:	0f b6 00             	movzbl (%eax),%eax
c0105c18:	38 c2                	cmp    %al,%dl
c0105c1a:	74 d7                	je     c0105bf3 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105c1c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105c20:	74 18                	je     c0105c3a <strncmp+0x4c>
c0105c22:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c25:	0f b6 00             	movzbl (%eax),%eax
c0105c28:	0f b6 d0             	movzbl %al,%edx
c0105c2b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c2e:	0f b6 00             	movzbl (%eax),%eax
c0105c31:	0f b6 c8             	movzbl %al,%ecx
c0105c34:	89 d0                	mov    %edx,%eax
c0105c36:	29 c8                	sub    %ecx,%eax
c0105c38:	eb 05                	jmp    c0105c3f <strncmp+0x51>
c0105c3a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105c3f:	5d                   	pop    %ebp
c0105c40:	c3                   	ret    

c0105c41 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0105c41:	55                   	push   %ebp
c0105c42:	89 e5                	mov    %esp,%ebp
c0105c44:	83 ec 04             	sub    $0x4,%esp
c0105c47:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c4a:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105c4d:	eb 13                	jmp    c0105c62 <strchr+0x21>
        if (*s == c) {
c0105c4f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c52:	0f b6 00             	movzbl (%eax),%eax
c0105c55:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0105c58:	75 05                	jne    c0105c5f <strchr+0x1e>
            return (char *)s;
c0105c5a:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c5d:	eb 12                	jmp    c0105c71 <strchr+0x30>
        }
        s ++;
c0105c5f:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0105c62:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c65:	0f b6 00             	movzbl (%eax),%eax
c0105c68:	84 c0                	test   %al,%al
c0105c6a:	75 e3                	jne    c0105c4f <strchr+0xe>
    }
    return NULL;
c0105c6c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105c71:	89 ec                	mov    %ebp,%esp
c0105c73:	5d                   	pop    %ebp
c0105c74:	c3                   	ret    

c0105c75 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0105c75:	55                   	push   %ebp
c0105c76:	89 e5                	mov    %esp,%ebp
c0105c78:	83 ec 04             	sub    $0x4,%esp
c0105c7b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c7e:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105c81:	eb 0e                	jmp    c0105c91 <strfind+0x1c>
        if (*s == c) {
c0105c83:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c86:	0f b6 00             	movzbl (%eax),%eax
c0105c89:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0105c8c:	74 0f                	je     c0105c9d <strfind+0x28>
            break;
        }
        s ++;
c0105c8e:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0105c91:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c94:	0f b6 00             	movzbl (%eax),%eax
c0105c97:	84 c0                	test   %al,%al
c0105c99:	75 e8                	jne    c0105c83 <strfind+0xe>
c0105c9b:	eb 01                	jmp    c0105c9e <strfind+0x29>
            break;
c0105c9d:	90                   	nop
    }
    return (char *)s;
c0105c9e:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105ca1:	89 ec                	mov    %ebp,%esp
c0105ca3:	5d                   	pop    %ebp
c0105ca4:	c3                   	ret    

c0105ca5 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0105ca5:	55                   	push   %ebp
c0105ca6:	89 e5                	mov    %esp,%ebp
c0105ca8:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0105cab:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0105cb2:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0105cb9:	eb 03                	jmp    c0105cbe <strtol+0x19>
        s ++;
c0105cbb:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c0105cbe:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cc1:	0f b6 00             	movzbl (%eax),%eax
c0105cc4:	3c 20                	cmp    $0x20,%al
c0105cc6:	74 f3                	je     c0105cbb <strtol+0x16>
c0105cc8:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ccb:	0f b6 00             	movzbl (%eax),%eax
c0105cce:	3c 09                	cmp    $0x9,%al
c0105cd0:	74 e9                	je     c0105cbb <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
c0105cd2:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cd5:	0f b6 00             	movzbl (%eax),%eax
c0105cd8:	3c 2b                	cmp    $0x2b,%al
c0105cda:	75 05                	jne    c0105ce1 <strtol+0x3c>
        s ++;
c0105cdc:	ff 45 08             	incl   0x8(%ebp)
c0105cdf:	eb 14                	jmp    c0105cf5 <strtol+0x50>
    }
    else if (*s == '-') {
c0105ce1:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ce4:	0f b6 00             	movzbl (%eax),%eax
c0105ce7:	3c 2d                	cmp    $0x2d,%al
c0105ce9:	75 0a                	jne    c0105cf5 <strtol+0x50>
        s ++, neg = 1;
c0105ceb:	ff 45 08             	incl   0x8(%ebp)
c0105cee:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0105cf5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105cf9:	74 06                	je     c0105d01 <strtol+0x5c>
c0105cfb:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c0105cff:	75 22                	jne    c0105d23 <strtol+0x7e>
c0105d01:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d04:	0f b6 00             	movzbl (%eax),%eax
c0105d07:	3c 30                	cmp    $0x30,%al
c0105d09:	75 18                	jne    c0105d23 <strtol+0x7e>
c0105d0b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d0e:	40                   	inc    %eax
c0105d0f:	0f b6 00             	movzbl (%eax),%eax
c0105d12:	3c 78                	cmp    $0x78,%al
c0105d14:	75 0d                	jne    c0105d23 <strtol+0x7e>
        s += 2, base = 16;
c0105d16:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0105d1a:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0105d21:	eb 29                	jmp    c0105d4c <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
c0105d23:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105d27:	75 16                	jne    c0105d3f <strtol+0x9a>
c0105d29:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d2c:	0f b6 00             	movzbl (%eax),%eax
c0105d2f:	3c 30                	cmp    $0x30,%al
c0105d31:	75 0c                	jne    c0105d3f <strtol+0x9a>
        s ++, base = 8;
c0105d33:	ff 45 08             	incl   0x8(%ebp)
c0105d36:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0105d3d:	eb 0d                	jmp    c0105d4c <strtol+0xa7>
    }
    else if (base == 0) {
c0105d3f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105d43:	75 07                	jne    c0105d4c <strtol+0xa7>
        base = 10;
c0105d45:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0105d4c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d4f:	0f b6 00             	movzbl (%eax),%eax
c0105d52:	3c 2f                	cmp    $0x2f,%al
c0105d54:	7e 1b                	jle    c0105d71 <strtol+0xcc>
c0105d56:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d59:	0f b6 00             	movzbl (%eax),%eax
c0105d5c:	3c 39                	cmp    $0x39,%al
c0105d5e:	7f 11                	jg     c0105d71 <strtol+0xcc>
            dig = *s - '0';
c0105d60:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d63:	0f b6 00             	movzbl (%eax),%eax
c0105d66:	0f be c0             	movsbl %al,%eax
c0105d69:	83 e8 30             	sub    $0x30,%eax
c0105d6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105d6f:	eb 48                	jmp    c0105db9 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0105d71:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d74:	0f b6 00             	movzbl (%eax),%eax
c0105d77:	3c 60                	cmp    $0x60,%al
c0105d79:	7e 1b                	jle    c0105d96 <strtol+0xf1>
c0105d7b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d7e:	0f b6 00             	movzbl (%eax),%eax
c0105d81:	3c 7a                	cmp    $0x7a,%al
c0105d83:	7f 11                	jg     c0105d96 <strtol+0xf1>
            dig = *s - 'a' + 10;
c0105d85:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d88:	0f b6 00             	movzbl (%eax),%eax
c0105d8b:	0f be c0             	movsbl %al,%eax
c0105d8e:	83 e8 57             	sub    $0x57,%eax
c0105d91:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105d94:	eb 23                	jmp    c0105db9 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0105d96:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d99:	0f b6 00             	movzbl (%eax),%eax
c0105d9c:	3c 40                	cmp    $0x40,%al
c0105d9e:	7e 3b                	jle    c0105ddb <strtol+0x136>
c0105da0:	8b 45 08             	mov    0x8(%ebp),%eax
c0105da3:	0f b6 00             	movzbl (%eax),%eax
c0105da6:	3c 5a                	cmp    $0x5a,%al
c0105da8:	7f 31                	jg     c0105ddb <strtol+0x136>
            dig = *s - 'A' + 10;
c0105daa:	8b 45 08             	mov    0x8(%ebp),%eax
c0105dad:	0f b6 00             	movzbl (%eax),%eax
c0105db0:	0f be c0             	movsbl %al,%eax
c0105db3:	83 e8 37             	sub    $0x37,%eax
c0105db6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0105db9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105dbc:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105dbf:	7d 19                	jge    c0105dda <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
c0105dc1:	ff 45 08             	incl   0x8(%ebp)
c0105dc4:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105dc7:	0f af 45 10          	imul   0x10(%ebp),%eax
c0105dcb:	89 c2                	mov    %eax,%edx
c0105dcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105dd0:	01 d0                	add    %edx,%eax
c0105dd2:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
c0105dd5:	e9 72 ff ff ff       	jmp    c0105d4c <strtol+0xa7>
            break;
c0105dda:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
c0105ddb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105ddf:	74 08                	je     c0105de9 <strtol+0x144>
        *endptr = (char *) s;
c0105de1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105de4:	8b 55 08             	mov    0x8(%ebp),%edx
c0105de7:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0105de9:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0105ded:	74 07                	je     c0105df6 <strtol+0x151>
c0105def:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105df2:	f7 d8                	neg    %eax
c0105df4:	eb 03                	jmp    c0105df9 <strtol+0x154>
c0105df6:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0105df9:	89 ec                	mov    %ebp,%esp
c0105dfb:	5d                   	pop    %ebp
c0105dfc:	c3                   	ret    

c0105dfd <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0105dfd:	55                   	push   %ebp
c0105dfe:	89 e5                	mov    %esp,%ebp
c0105e00:	83 ec 28             	sub    $0x28,%esp
c0105e03:	89 7d fc             	mov    %edi,-0x4(%ebp)
c0105e06:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e09:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0105e0c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
c0105e10:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e13:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0105e16:	88 55 f7             	mov    %dl,-0x9(%ebp)
c0105e19:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e1c:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0105e1f:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0105e22:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0105e26:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0105e29:	89 d7                	mov    %edx,%edi
c0105e2b:	f3 aa                	rep stos %al,%es:(%edi)
c0105e2d:	89 fa                	mov    %edi,%edx
c0105e2f:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0105e32:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0105e35:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0105e38:	8b 7d fc             	mov    -0x4(%ebp),%edi
c0105e3b:	89 ec                	mov    %ebp,%esp
c0105e3d:	5d                   	pop    %ebp
c0105e3e:	c3                   	ret    

c0105e3f <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0105e3f:	55                   	push   %ebp
c0105e40:	89 e5                	mov    %esp,%ebp
c0105e42:	57                   	push   %edi
c0105e43:	56                   	push   %esi
c0105e44:	53                   	push   %ebx
c0105e45:	83 ec 30             	sub    $0x30,%esp
c0105e48:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e4b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105e4e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e51:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105e54:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e57:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0105e5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e5d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0105e60:	73 42                	jae    c0105ea4 <memmove+0x65>
c0105e62:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e65:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105e68:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105e6b:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105e6e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105e71:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0105e74:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105e77:	c1 e8 02             	shr    $0x2,%eax
c0105e7a:	89 c1                	mov    %eax,%ecx
    asm volatile (
c0105e7c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105e7f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105e82:	89 d7                	mov    %edx,%edi
c0105e84:	89 c6                	mov    %eax,%esi
c0105e86:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0105e88:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0105e8b:	83 e1 03             	and    $0x3,%ecx
c0105e8e:	74 02                	je     c0105e92 <memmove+0x53>
c0105e90:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105e92:	89 f0                	mov    %esi,%eax
c0105e94:	89 fa                	mov    %edi,%edx
c0105e96:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0105e99:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0105e9c:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c0105e9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
c0105ea2:	eb 36                	jmp    c0105eda <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0105ea4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105ea7:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105eaa:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105ead:	01 c2                	add    %eax,%edx
c0105eaf:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105eb2:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0105eb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105eb8:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c0105ebb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105ebe:	89 c1                	mov    %eax,%ecx
c0105ec0:	89 d8                	mov    %ebx,%eax
c0105ec2:	89 d6                	mov    %edx,%esi
c0105ec4:	89 c7                	mov    %eax,%edi
c0105ec6:	fd                   	std    
c0105ec7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105ec9:	fc                   	cld    
c0105eca:	89 f8                	mov    %edi,%eax
c0105ecc:	89 f2                	mov    %esi,%edx
c0105ece:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c0105ed1:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0105ed4:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c0105ed7:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c0105eda:	83 c4 30             	add    $0x30,%esp
c0105edd:	5b                   	pop    %ebx
c0105ede:	5e                   	pop    %esi
c0105edf:	5f                   	pop    %edi
c0105ee0:	5d                   	pop    %ebp
c0105ee1:	c3                   	ret    

c0105ee2 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c0105ee2:	55                   	push   %ebp
c0105ee3:	89 e5                	mov    %esp,%ebp
c0105ee5:	57                   	push   %edi
c0105ee6:	56                   	push   %esi
c0105ee7:	83 ec 20             	sub    $0x20,%esp
c0105eea:	8b 45 08             	mov    0x8(%ebp),%eax
c0105eed:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105ef0:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ef3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105ef6:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ef9:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0105efc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105eff:	c1 e8 02             	shr    $0x2,%eax
c0105f02:	89 c1                	mov    %eax,%ecx
    asm volatile (
c0105f04:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105f07:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105f0a:	89 d7                	mov    %edx,%edi
c0105f0c:	89 c6                	mov    %eax,%esi
c0105f0e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0105f10:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c0105f13:	83 e1 03             	and    $0x3,%ecx
c0105f16:	74 02                	je     c0105f1a <memcpy+0x38>
c0105f18:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105f1a:	89 f0                	mov    %esi,%eax
c0105f1c:	89 fa                	mov    %edi,%edx
c0105f1e:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0105f21:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0105f24:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c0105f27:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0105f2a:	83 c4 20             	add    $0x20,%esp
c0105f2d:	5e                   	pop    %esi
c0105f2e:	5f                   	pop    %edi
c0105f2f:	5d                   	pop    %ebp
c0105f30:	c3                   	ret    

c0105f31 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c0105f31:	55                   	push   %ebp
c0105f32:	89 e5                	mov    %esp,%ebp
c0105f34:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0105f37:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f3a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0105f3d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105f40:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c0105f43:	eb 2e                	jmp    c0105f73 <memcmp+0x42>
        if (*s1 != *s2) {
c0105f45:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105f48:	0f b6 10             	movzbl (%eax),%edx
c0105f4b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105f4e:	0f b6 00             	movzbl (%eax),%eax
c0105f51:	38 c2                	cmp    %al,%dl
c0105f53:	74 18                	je     c0105f6d <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105f55:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105f58:	0f b6 00             	movzbl (%eax),%eax
c0105f5b:	0f b6 d0             	movzbl %al,%edx
c0105f5e:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105f61:	0f b6 00             	movzbl (%eax),%eax
c0105f64:	0f b6 c8             	movzbl %al,%ecx
c0105f67:	89 d0                	mov    %edx,%eax
c0105f69:	29 c8                	sub    %ecx,%eax
c0105f6b:	eb 18                	jmp    c0105f85 <memcmp+0x54>
        }
        s1 ++, s2 ++;
c0105f6d:	ff 45 fc             	incl   -0x4(%ebp)
c0105f70:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
c0105f73:	8b 45 10             	mov    0x10(%ebp),%eax
c0105f76:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105f79:	89 55 10             	mov    %edx,0x10(%ebp)
c0105f7c:	85 c0                	test   %eax,%eax
c0105f7e:	75 c5                	jne    c0105f45 <memcmp+0x14>
    }
    return 0;
c0105f80:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105f85:	89 ec                	mov    %ebp,%esp
c0105f87:	5d                   	pop    %ebp
c0105f88:	c3                   	ret    
