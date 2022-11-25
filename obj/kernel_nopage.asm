
bin/kernel_nopage：     文件格式 elf32-i386


Disassembly of section .text:

00100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
  100000:	b8 00 90 11 40       	mov    $0x40119000,%eax
    movl %eax, %cr3
  100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
  100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
  10000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
  100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
  100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
  100016:	8d 05 1e 00 10 00    	lea    0x10001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
  10001c:	ff e0                	jmp    *%eax

0010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
  10001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
  100020:	a3 00 90 11 00       	mov    %eax,0x119000

    # set ebp, esp
    movl $0x0, %ebp
  100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
  10002a:	bc 00 80 11 00       	mov    $0x118000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
  10002f:	e8 02 00 00 00       	call   100036 <kern_init>

00100034 <spin>:

# should never get here
spin:
    jmp spin
  100034:	eb fe                	jmp    100034 <spin>

00100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
  100036:	55                   	push   %ebp
  100037:	89 e5                	mov    %esp,%ebp
  100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  10003c:	b8 2c bf 11 00       	mov    $0x11bf2c,%eax
  100041:	2d 36 8a 11 00       	sub    $0x118a36,%eax
  100046:	89 44 24 08          	mov    %eax,0x8(%esp)
  10004a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  100051:	00 
  100052:	c7 04 24 36 8a 11 00 	movl   $0x118a36,(%esp)
  100059:	e8 9f 5d 00 00       	call   105dfd <memset>

    cons_init();                // init the console
  10005e:	e8 ea 15 00 00       	call   10164d <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100063:	c7 45 f4 a0 5f 10 00 	movl   $0x105fa0,-0xc(%ebp)
    cprintf("%s\n\n", message);
  10006a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10006d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100071:	c7 04 24 bc 5f 10 00 	movl   $0x105fbc,(%esp)
  100078:	e8 d9 02 00 00       	call   100356 <cprintf>

    print_kerninfo();
  10007d:	e8 f7 07 00 00       	call   100879 <print_kerninfo>

    grade_backtrace();
  100082:	e8 90 00 00 00       	call   100117 <grade_backtrace>

    pmm_init();                 // init physical memory management
  100087:	e8 e8 42 00 00       	call   104374 <pmm_init>

    pic_init();                 // init interrupt controller
  10008c:	e8 3d 17 00 00       	call   1017ce <pic_init>
    idt_init();                 // init interrupt descriptor table
  100091:	e8 c4 18 00 00       	call   10195a <idt_init>

    clock_init();               // init clock interrupt
  100096:	e8 11 0d 00 00       	call   100dac <clock_init>
    intr_enable();              // enable irq interrupt
  10009b:	e8 8c 16 00 00       	call   10172c <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
  1000a0:	eb fe                	jmp    1000a0 <kern_init+0x6a>

001000a2 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  1000a2:	55                   	push   %ebp
  1000a3:	89 e5                	mov    %esp,%ebp
  1000a5:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
  1000a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1000af:	00 
  1000b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1000b7:	00 
  1000b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1000bf:	e8 03 0c 00 00       	call   100cc7 <mon_backtrace>
}
  1000c4:	90                   	nop
  1000c5:	89 ec                	mov    %ebp,%esp
  1000c7:	5d                   	pop    %ebp
  1000c8:	c3                   	ret    

001000c9 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  1000c9:	55                   	push   %ebp
  1000ca:	89 e5                	mov    %esp,%ebp
  1000cc:	83 ec 18             	sub    $0x18,%esp
  1000cf:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  1000d2:	8d 4d 0c             	lea    0xc(%ebp),%ecx
  1000d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  1000d8:	8d 5d 08             	lea    0x8(%ebp),%ebx
  1000db:	8b 45 08             	mov    0x8(%ebp),%eax
  1000de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  1000e2:	89 54 24 08          	mov    %edx,0x8(%esp)
  1000e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1000ea:	89 04 24             	mov    %eax,(%esp)
  1000ed:	e8 b0 ff ff ff       	call   1000a2 <grade_backtrace2>
}
  1000f2:	90                   	nop
  1000f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  1000f6:	89 ec                	mov    %ebp,%esp
  1000f8:	5d                   	pop    %ebp
  1000f9:	c3                   	ret    

001000fa <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000fa:	55                   	push   %ebp
  1000fb:	89 e5                	mov    %esp,%ebp
  1000fd:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
  100100:	8b 45 10             	mov    0x10(%ebp),%eax
  100103:	89 44 24 04          	mov    %eax,0x4(%esp)
  100107:	8b 45 08             	mov    0x8(%ebp),%eax
  10010a:	89 04 24             	mov    %eax,(%esp)
  10010d:	e8 b7 ff ff ff       	call   1000c9 <grade_backtrace1>
}
  100112:	90                   	nop
  100113:	89 ec                	mov    %ebp,%esp
  100115:	5d                   	pop    %ebp
  100116:	c3                   	ret    

00100117 <grade_backtrace>:

void
grade_backtrace(void) {
  100117:	55                   	push   %ebp
  100118:	89 e5                	mov    %esp,%ebp
  10011a:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  10011d:	b8 36 00 10 00       	mov    $0x100036,%eax
  100122:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
  100129:	ff 
  10012a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10012e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100135:	e8 c0 ff ff ff       	call   1000fa <grade_backtrace0>
}
  10013a:	90                   	nop
  10013b:	89 ec                	mov    %ebp,%esp
  10013d:	5d                   	pop    %ebp
  10013e:	c3                   	ret    

0010013f <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  10013f:	55                   	push   %ebp
  100140:	89 e5                	mov    %esp,%ebp
  100142:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  100145:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  100148:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  10014b:	8c 45 f2             	mov    %es,-0xe(%ebp)
  10014e:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  100151:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100155:	83 e0 03             	and    $0x3,%eax
  100158:	89 c2                	mov    %eax,%edx
  10015a:	a1 00 b0 11 00       	mov    0x11b000,%eax
  10015f:	89 54 24 08          	mov    %edx,0x8(%esp)
  100163:	89 44 24 04          	mov    %eax,0x4(%esp)
  100167:	c7 04 24 c1 5f 10 00 	movl   $0x105fc1,(%esp)
  10016e:	e8 e3 01 00 00       	call   100356 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  100173:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100177:	89 c2                	mov    %eax,%edx
  100179:	a1 00 b0 11 00       	mov    0x11b000,%eax
  10017e:	89 54 24 08          	mov    %edx,0x8(%esp)
  100182:	89 44 24 04          	mov    %eax,0x4(%esp)
  100186:	c7 04 24 cf 5f 10 00 	movl   $0x105fcf,(%esp)
  10018d:	e8 c4 01 00 00       	call   100356 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  100192:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100196:	89 c2                	mov    %eax,%edx
  100198:	a1 00 b0 11 00       	mov    0x11b000,%eax
  10019d:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001a5:	c7 04 24 dd 5f 10 00 	movl   $0x105fdd,(%esp)
  1001ac:	e8 a5 01 00 00       	call   100356 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  1001b1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1001b5:	89 c2                	mov    %eax,%edx
  1001b7:	a1 00 b0 11 00       	mov    0x11b000,%eax
  1001bc:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001c4:	c7 04 24 eb 5f 10 00 	movl   $0x105feb,(%esp)
  1001cb:	e8 86 01 00 00       	call   100356 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  1001d0:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001d4:	89 c2                	mov    %eax,%edx
  1001d6:	a1 00 b0 11 00       	mov    0x11b000,%eax
  1001db:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001df:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001e3:	c7 04 24 f9 5f 10 00 	movl   $0x105ff9,(%esp)
  1001ea:	e8 67 01 00 00       	call   100356 <cprintf>
    round ++;
  1001ef:	a1 00 b0 11 00       	mov    0x11b000,%eax
  1001f4:	40                   	inc    %eax
  1001f5:	a3 00 b0 11 00       	mov    %eax,0x11b000
}
  1001fa:	90                   	nop
  1001fb:	89 ec                	mov    %ebp,%esp
  1001fd:	5d                   	pop    %ebp
  1001fe:	c3                   	ret    

001001ff <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  1001ff:	55                   	push   %ebp
  100200:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
  100202:	90                   	nop
  100203:	5d                   	pop    %ebp
  100204:	c3                   	ret    

00100205 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  100205:	55                   	push   %ebp
  100206:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
  100208:	90                   	nop
  100209:	5d                   	pop    %ebp
  10020a:	c3                   	ret    

0010020b <lab1_switch_test>:

static void
lab1_switch_test(void) {
  10020b:	55                   	push   %ebp
  10020c:	89 e5                	mov    %esp,%ebp
  10020e:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
  100211:	e8 29 ff ff ff       	call   10013f <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  100216:	c7 04 24 08 60 10 00 	movl   $0x106008,(%esp)
  10021d:	e8 34 01 00 00       	call   100356 <cprintf>
    lab1_switch_to_user();
  100222:	e8 d8 ff ff ff       	call   1001ff <lab1_switch_to_user>
    lab1_print_cur_status();
  100227:	e8 13 ff ff ff       	call   10013f <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  10022c:	c7 04 24 28 60 10 00 	movl   $0x106028,(%esp)
  100233:	e8 1e 01 00 00       	call   100356 <cprintf>
    lab1_switch_to_kernel();
  100238:	e8 c8 ff ff ff       	call   100205 <lab1_switch_to_kernel>
    lab1_print_cur_status();
  10023d:	e8 fd fe ff ff       	call   10013f <lab1_print_cur_status>
}
  100242:	90                   	nop
  100243:	89 ec                	mov    %ebp,%esp
  100245:	5d                   	pop    %ebp
  100246:	c3                   	ret    

00100247 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  100247:	55                   	push   %ebp
  100248:	89 e5                	mov    %esp,%ebp
  10024a:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
  10024d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100251:	74 13                	je     100266 <readline+0x1f>
        cprintf("%s", prompt);
  100253:	8b 45 08             	mov    0x8(%ebp),%eax
  100256:	89 44 24 04          	mov    %eax,0x4(%esp)
  10025a:	c7 04 24 47 60 10 00 	movl   $0x106047,(%esp)
  100261:	e8 f0 00 00 00       	call   100356 <cprintf>
    }
    int i = 0, c;
  100266:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  10026d:	e8 73 01 00 00       	call   1003e5 <getchar>
  100272:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  100275:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100279:	79 07                	jns    100282 <readline+0x3b>
            return NULL;
  10027b:	b8 00 00 00 00       	mov    $0x0,%eax
  100280:	eb 78                	jmp    1002fa <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  100282:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  100286:	7e 28                	jle    1002b0 <readline+0x69>
  100288:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  10028f:	7f 1f                	jg     1002b0 <readline+0x69>
            cputchar(c);
  100291:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100294:	89 04 24             	mov    %eax,(%esp)
  100297:	e8 e2 00 00 00       	call   10037e <cputchar>
            buf[i ++] = c;
  10029c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10029f:	8d 50 01             	lea    0x1(%eax),%edx
  1002a2:	89 55 f4             	mov    %edx,-0xc(%ebp)
  1002a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1002a8:	88 90 20 b0 11 00    	mov    %dl,0x11b020(%eax)
  1002ae:	eb 45                	jmp    1002f5 <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
  1002b0:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  1002b4:	75 16                	jne    1002cc <readline+0x85>
  1002b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1002ba:	7e 10                	jle    1002cc <readline+0x85>
            cputchar(c);
  1002bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002bf:	89 04 24             	mov    %eax,(%esp)
  1002c2:	e8 b7 00 00 00       	call   10037e <cputchar>
            i --;
  1002c7:	ff 4d f4             	decl   -0xc(%ebp)
  1002ca:	eb 29                	jmp    1002f5 <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
  1002cc:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  1002d0:	74 06                	je     1002d8 <readline+0x91>
  1002d2:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  1002d6:	75 95                	jne    10026d <readline+0x26>
            cputchar(c);
  1002d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002db:	89 04 24             	mov    %eax,(%esp)
  1002de:	e8 9b 00 00 00       	call   10037e <cputchar>
            buf[i] = '\0';
  1002e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1002e6:	05 20 b0 11 00       	add    $0x11b020,%eax
  1002eb:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1002ee:	b8 20 b0 11 00       	mov    $0x11b020,%eax
  1002f3:	eb 05                	jmp    1002fa <readline+0xb3>
        c = getchar();
  1002f5:	e9 73 ff ff ff       	jmp    10026d <readline+0x26>
        }
    }
}
  1002fa:	89 ec                	mov    %ebp,%esp
  1002fc:	5d                   	pop    %ebp
  1002fd:	c3                   	ret    

001002fe <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  1002fe:	55                   	push   %ebp
  1002ff:	89 e5                	mov    %esp,%ebp
  100301:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100304:	8b 45 08             	mov    0x8(%ebp),%eax
  100307:	89 04 24             	mov    %eax,(%esp)
  10030a:	e8 6d 13 00 00       	call   10167c <cons_putc>
    (*cnt) ++;
  10030f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100312:	8b 00                	mov    (%eax),%eax
  100314:	8d 50 01             	lea    0x1(%eax),%edx
  100317:	8b 45 0c             	mov    0xc(%ebp),%eax
  10031a:	89 10                	mov    %edx,(%eax)
}
  10031c:	90                   	nop
  10031d:	89 ec                	mov    %ebp,%esp
  10031f:	5d                   	pop    %ebp
  100320:	c3                   	ret    

00100321 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  100321:	55                   	push   %ebp
  100322:	89 e5                	mov    %esp,%ebp
  100324:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  100327:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  10032e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100331:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100335:	8b 45 08             	mov    0x8(%ebp),%eax
  100338:	89 44 24 08          	mov    %eax,0x8(%esp)
  10033c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  10033f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100343:	c7 04 24 fe 02 10 00 	movl   $0x1002fe,(%esp)
  10034a:	e8 d9 52 00 00       	call   105628 <vprintfmt>
    return cnt;
  10034f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100352:	89 ec                	mov    %ebp,%esp
  100354:	5d                   	pop    %ebp
  100355:	c3                   	ret    

00100356 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  100356:	55                   	push   %ebp
  100357:	89 e5                	mov    %esp,%ebp
  100359:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  10035c:	8d 45 0c             	lea    0xc(%ebp),%eax
  10035f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  100362:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100365:	89 44 24 04          	mov    %eax,0x4(%esp)
  100369:	8b 45 08             	mov    0x8(%ebp),%eax
  10036c:	89 04 24             	mov    %eax,(%esp)
  10036f:	e8 ad ff ff ff       	call   100321 <vcprintf>
  100374:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  100377:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10037a:	89 ec                	mov    %ebp,%esp
  10037c:	5d                   	pop    %ebp
  10037d:	c3                   	ret    

0010037e <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  10037e:	55                   	push   %ebp
  10037f:	89 e5                	mov    %esp,%ebp
  100381:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100384:	8b 45 08             	mov    0x8(%ebp),%eax
  100387:	89 04 24             	mov    %eax,(%esp)
  10038a:	e8 ed 12 00 00       	call   10167c <cons_putc>
}
  10038f:	90                   	nop
  100390:	89 ec                	mov    %ebp,%esp
  100392:	5d                   	pop    %ebp
  100393:	c3                   	ret    

00100394 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  100394:	55                   	push   %ebp
  100395:	89 e5                	mov    %esp,%ebp
  100397:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  10039a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  1003a1:	eb 13                	jmp    1003b6 <cputs+0x22>
        cputch(c, &cnt);
  1003a3:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  1003a7:	8d 55 f0             	lea    -0x10(%ebp),%edx
  1003aa:	89 54 24 04          	mov    %edx,0x4(%esp)
  1003ae:	89 04 24             	mov    %eax,(%esp)
  1003b1:	e8 48 ff ff ff       	call   1002fe <cputch>
    while ((c = *str ++) != '\0') {
  1003b6:	8b 45 08             	mov    0x8(%ebp),%eax
  1003b9:	8d 50 01             	lea    0x1(%eax),%edx
  1003bc:	89 55 08             	mov    %edx,0x8(%ebp)
  1003bf:	0f b6 00             	movzbl (%eax),%eax
  1003c2:	88 45 f7             	mov    %al,-0x9(%ebp)
  1003c5:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  1003c9:	75 d8                	jne    1003a3 <cputs+0xf>
    }
    cputch('\n', &cnt);
  1003cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  1003ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  1003d2:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  1003d9:	e8 20 ff ff ff       	call   1002fe <cputch>
    return cnt;
  1003de:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  1003e1:	89 ec                	mov    %ebp,%esp
  1003e3:	5d                   	pop    %ebp
  1003e4:	c3                   	ret    

001003e5 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  1003e5:	55                   	push   %ebp
  1003e6:	89 e5                	mov    %esp,%ebp
  1003e8:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  1003eb:	90                   	nop
  1003ec:	e8 ca 12 00 00       	call   1016bb <cons_getc>
  1003f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1003f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1003f8:	74 f2                	je     1003ec <getchar+0x7>
        /* do nothing */;
    return c;
  1003fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1003fd:	89 ec                	mov    %ebp,%esp
  1003ff:	5d                   	pop    %ebp
  100400:	c3                   	ret    

00100401 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  100401:	55                   	push   %ebp
  100402:	89 e5                	mov    %esp,%ebp
  100404:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  100407:	8b 45 0c             	mov    0xc(%ebp),%eax
  10040a:	8b 00                	mov    (%eax),%eax
  10040c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  10040f:	8b 45 10             	mov    0x10(%ebp),%eax
  100412:	8b 00                	mov    (%eax),%eax
  100414:	89 45 f8             	mov    %eax,-0x8(%ebp)
  100417:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  10041e:	e9 ca 00 00 00       	jmp    1004ed <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
  100423:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100426:	8b 45 f8             	mov    -0x8(%ebp),%eax
  100429:	01 d0                	add    %edx,%eax
  10042b:	89 c2                	mov    %eax,%edx
  10042d:	c1 ea 1f             	shr    $0x1f,%edx
  100430:	01 d0                	add    %edx,%eax
  100432:	d1 f8                	sar    %eax
  100434:	89 45 ec             	mov    %eax,-0x14(%ebp)
  100437:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10043a:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  10043d:	eb 03                	jmp    100442 <stab_binsearch+0x41>
            m --;
  10043f:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
  100442:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100445:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100448:	7c 1f                	jl     100469 <stab_binsearch+0x68>
  10044a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10044d:	89 d0                	mov    %edx,%eax
  10044f:	01 c0                	add    %eax,%eax
  100451:	01 d0                	add    %edx,%eax
  100453:	c1 e0 02             	shl    $0x2,%eax
  100456:	89 c2                	mov    %eax,%edx
  100458:	8b 45 08             	mov    0x8(%ebp),%eax
  10045b:	01 d0                	add    %edx,%eax
  10045d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100461:	0f b6 c0             	movzbl %al,%eax
  100464:	39 45 14             	cmp    %eax,0x14(%ebp)
  100467:	75 d6                	jne    10043f <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
  100469:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10046c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  10046f:	7d 09                	jge    10047a <stab_binsearch+0x79>
            l = true_m + 1;
  100471:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100474:	40                   	inc    %eax
  100475:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  100478:	eb 73                	jmp    1004ed <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
  10047a:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  100481:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100484:	89 d0                	mov    %edx,%eax
  100486:	01 c0                	add    %eax,%eax
  100488:	01 d0                	add    %edx,%eax
  10048a:	c1 e0 02             	shl    $0x2,%eax
  10048d:	89 c2                	mov    %eax,%edx
  10048f:	8b 45 08             	mov    0x8(%ebp),%eax
  100492:	01 d0                	add    %edx,%eax
  100494:	8b 40 08             	mov    0x8(%eax),%eax
  100497:	39 45 18             	cmp    %eax,0x18(%ebp)
  10049a:	76 11                	jbe    1004ad <stab_binsearch+0xac>
            *region_left = m;
  10049c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10049f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004a2:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  1004a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1004a7:	40                   	inc    %eax
  1004a8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  1004ab:	eb 40                	jmp    1004ed <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
  1004ad:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004b0:	89 d0                	mov    %edx,%eax
  1004b2:	01 c0                	add    %eax,%eax
  1004b4:	01 d0                	add    %edx,%eax
  1004b6:	c1 e0 02             	shl    $0x2,%eax
  1004b9:	89 c2                	mov    %eax,%edx
  1004bb:	8b 45 08             	mov    0x8(%ebp),%eax
  1004be:	01 d0                	add    %edx,%eax
  1004c0:	8b 40 08             	mov    0x8(%eax),%eax
  1004c3:	39 45 18             	cmp    %eax,0x18(%ebp)
  1004c6:	73 14                	jae    1004dc <stab_binsearch+0xdb>
            *region_right = m - 1;
  1004c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004cb:	8d 50 ff             	lea    -0x1(%eax),%edx
  1004ce:	8b 45 10             	mov    0x10(%ebp),%eax
  1004d1:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  1004d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004d6:	48                   	dec    %eax
  1004d7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1004da:	eb 11                	jmp    1004ed <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  1004dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004df:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004e2:	89 10                	mov    %edx,(%eax)
            l = m;
  1004e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004e7:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  1004ea:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r) {
  1004ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1004f0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  1004f3:	0f 8e 2a ff ff ff    	jle    100423 <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
  1004f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1004fd:	75 0f                	jne    10050e <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
  1004ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  100502:	8b 00                	mov    (%eax),%eax
  100504:	8d 50 ff             	lea    -0x1(%eax),%edx
  100507:	8b 45 10             	mov    0x10(%ebp),%eax
  10050a:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
  10050c:	eb 3e                	jmp    10054c <stab_binsearch+0x14b>
        l = *region_right;
  10050e:	8b 45 10             	mov    0x10(%ebp),%eax
  100511:	8b 00                	mov    (%eax),%eax
  100513:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  100516:	eb 03                	jmp    10051b <stab_binsearch+0x11a>
  100518:	ff 4d fc             	decl   -0x4(%ebp)
  10051b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10051e:	8b 00                	mov    (%eax),%eax
  100520:	39 45 fc             	cmp    %eax,-0x4(%ebp)
  100523:	7e 1f                	jle    100544 <stab_binsearch+0x143>
  100525:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100528:	89 d0                	mov    %edx,%eax
  10052a:	01 c0                	add    %eax,%eax
  10052c:	01 d0                	add    %edx,%eax
  10052e:	c1 e0 02             	shl    $0x2,%eax
  100531:	89 c2                	mov    %eax,%edx
  100533:	8b 45 08             	mov    0x8(%ebp),%eax
  100536:	01 d0                	add    %edx,%eax
  100538:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10053c:	0f b6 c0             	movzbl %al,%eax
  10053f:	39 45 14             	cmp    %eax,0x14(%ebp)
  100542:	75 d4                	jne    100518 <stab_binsearch+0x117>
        *region_left = l;
  100544:	8b 45 0c             	mov    0xc(%ebp),%eax
  100547:	8b 55 fc             	mov    -0x4(%ebp),%edx
  10054a:	89 10                	mov    %edx,(%eax)
}
  10054c:	90                   	nop
  10054d:	89 ec                	mov    %ebp,%esp
  10054f:	5d                   	pop    %ebp
  100550:	c3                   	ret    

00100551 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  100551:	55                   	push   %ebp
  100552:	89 e5                	mov    %esp,%ebp
  100554:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  100557:	8b 45 0c             	mov    0xc(%ebp),%eax
  10055a:	c7 00 4c 60 10 00    	movl   $0x10604c,(%eax)
    info->eip_line = 0;
  100560:	8b 45 0c             	mov    0xc(%ebp),%eax
  100563:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  10056a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10056d:	c7 40 08 4c 60 10 00 	movl   $0x10604c,0x8(%eax)
    info->eip_fn_namelen = 9;
  100574:	8b 45 0c             	mov    0xc(%ebp),%eax
  100577:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  10057e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100581:	8b 55 08             	mov    0x8(%ebp),%edx
  100584:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  100587:	8b 45 0c             	mov    0xc(%ebp),%eax
  10058a:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  100591:	c7 45 f4 c8 72 10 00 	movl   $0x1072c8,-0xc(%ebp)
    stab_end = __STAB_END__;
  100598:	c7 45 f0 8c 29 11 00 	movl   $0x11298c,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  10059f:	c7 45 ec 8d 29 11 00 	movl   $0x11298d,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  1005a6:	c7 45 e8 25 5f 11 00 	movl   $0x115f25,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  1005ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1005b0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1005b3:	76 0b                	jbe    1005c0 <debuginfo_eip+0x6f>
  1005b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1005b8:	48                   	dec    %eax
  1005b9:	0f b6 00             	movzbl (%eax),%eax
  1005bc:	84 c0                	test   %al,%al
  1005be:	74 0a                	je     1005ca <debuginfo_eip+0x79>
        return -1;
  1005c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1005c5:	e9 ab 02 00 00       	jmp    100875 <debuginfo_eip+0x324>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  1005ca:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  1005d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1005d4:	2b 45 f4             	sub    -0xc(%ebp),%eax
  1005d7:	c1 f8 02             	sar    $0x2,%eax
  1005da:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  1005e0:	48                   	dec    %eax
  1005e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  1005e4:	8b 45 08             	mov    0x8(%ebp),%eax
  1005e7:	89 44 24 10          	mov    %eax,0x10(%esp)
  1005eb:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
  1005f2:	00 
  1005f3:	8d 45 e0             	lea    -0x20(%ebp),%eax
  1005f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  1005fa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  1005fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  100601:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100604:	89 04 24             	mov    %eax,(%esp)
  100607:	e8 f5 fd ff ff       	call   100401 <stab_binsearch>
    if (lfile == 0)
  10060c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10060f:	85 c0                	test   %eax,%eax
  100611:	75 0a                	jne    10061d <debuginfo_eip+0xcc>
        return -1;
  100613:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100618:	e9 58 02 00 00       	jmp    100875 <debuginfo_eip+0x324>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  10061d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100620:	89 45 dc             	mov    %eax,-0x24(%ebp)
  100623:	8b 45 e0             	mov    -0x20(%ebp),%eax
  100626:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  100629:	8b 45 08             	mov    0x8(%ebp),%eax
  10062c:	89 44 24 10          	mov    %eax,0x10(%esp)
  100630:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
  100637:	00 
  100638:	8d 45 d8             	lea    -0x28(%ebp),%eax
  10063b:	89 44 24 08          	mov    %eax,0x8(%esp)
  10063f:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100642:	89 44 24 04          	mov    %eax,0x4(%esp)
  100646:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100649:	89 04 24             	mov    %eax,(%esp)
  10064c:	e8 b0 fd ff ff       	call   100401 <stab_binsearch>

    if (lfun <= rfun) {
  100651:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100654:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100657:	39 c2                	cmp    %eax,%edx
  100659:	7f 78                	jg     1006d3 <debuginfo_eip+0x182>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  10065b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10065e:	89 c2                	mov    %eax,%edx
  100660:	89 d0                	mov    %edx,%eax
  100662:	01 c0                	add    %eax,%eax
  100664:	01 d0                	add    %edx,%eax
  100666:	c1 e0 02             	shl    $0x2,%eax
  100669:	89 c2                	mov    %eax,%edx
  10066b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10066e:	01 d0                	add    %edx,%eax
  100670:	8b 10                	mov    (%eax),%edx
  100672:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100675:	2b 45 ec             	sub    -0x14(%ebp),%eax
  100678:	39 c2                	cmp    %eax,%edx
  10067a:	73 22                	jae    10069e <debuginfo_eip+0x14d>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  10067c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10067f:	89 c2                	mov    %eax,%edx
  100681:	89 d0                	mov    %edx,%eax
  100683:	01 c0                	add    %eax,%eax
  100685:	01 d0                	add    %edx,%eax
  100687:	c1 e0 02             	shl    $0x2,%eax
  10068a:	89 c2                	mov    %eax,%edx
  10068c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10068f:	01 d0                	add    %edx,%eax
  100691:	8b 10                	mov    (%eax),%edx
  100693:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100696:	01 c2                	add    %eax,%edx
  100698:	8b 45 0c             	mov    0xc(%ebp),%eax
  10069b:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  10069e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1006a1:	89 c2                	mov    %eax,%edx
  1006a3:	89 d0                	mov    %edx,%eax
  1006a5:	01 c0                	add    %eax,%eax
  1006a7:	01 d0                	add    %edx,%eax
  1006a9:	c1 e0 02             	shl    $0x2,%eax
  1006ac:	89 c2                	mov    %eax,%edx
  1006ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006b1:	01 d0                	add    %edx,%eax
  1006b3:	8b 50 08             	mov    0x8(%eax),%edx
  1006b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006b9:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  1006bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006bf:	8b 40 10             	mov    0x10(%eax),%eax
  1006c2:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  1006c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1006c8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  1006cb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1006ce:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1006d1:	eb 15                	jmp    1006e8 <debuginfo_eip+0x197>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  1006d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006d6:	8b 55 08             	mov    0x8(%ebp),%edx
  1006d9:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  1006dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006df:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  1006e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1006e5:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  1006e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006eb:	8b 40 08             	mov    0x8(%eax),%eax
  1006ee:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  1006f5:	00 
  1006f6:	89 04 24             	mov    %eax,(%esp)
  1006f9:	e8 77 55 00 00       	call   105c75 <strfind>
  1006fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  100701:	8b 4a 08             	mov    0x8(%edx),%ecx
  100704:	29 c8                	sub    %ecx,%eax
  100706:	89 c2                	mov    %eax,%edx
  100708:	8b 45 0c             	mov    0xc(%ebp),%eax
  10070b:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  10070e:	8b 45 08             	mov    0x8(%ebp),%eax
  100711:	89 44 24 10          	mov    %eax,0x10(%esp)
  100715:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
  10071c:	00 
  10071d:	8d 45 d0             	lea    -0x30(%ebp),%eax
  100720:	89 44 24 08          	mov    %eax,0x8(%esp)
  100724:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  100727:	89 44 24 04          	mov    %eax,0x4(%esp)
  10072b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10072e:	89 04 24             	mov    %eax,(%esp)
  100731:	e8 cb fc ff ff       	call   100401 <stab_binsearch>
    if (lline <= rline) {
  100736:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100739:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10073c:	39 c2                	cmp    %eax,%edx
  10073e:	7f 23                	jg     100763 <debuginfo_eip+0x212>
        info->eip_line = stabs[rline].n_desc;
  100740:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100743:	89 c2                	mov    %eax,%edx
  100745:	89 d0                	mov    %edx,%eax
  100747:	01 c0                	add    %eax,%eax
  100749:	01 d0                	add    %edx,%eax
  10074b:	c1 e0 02             	shl    $0x2,%eax
  10074e:	89 c2                	mov    %eax,%edx
  100750:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100753:	01 d0                	add    %edx,%eax
  100755:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  100759:	89 c2                	mov    %eax,%edx
  10075b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10075e:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  100761:	eb 11                	jmp    100774 <debuginfo_eip+0x223>
        return -1;
  100763:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100768:	e9 08 01 00 00       	jmp    100875 <debuginfo_eip+0x324>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  10076d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100770:	48                   	dec    %eax
  100771:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
  100774:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100777:	8b 45 e4             	mov    -0x1c(%ebp),%eax
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  10077a:	39 c2                	cmp    %eax,%edx
  10077c:	7c 56                	jl     1007d4 <debuginfo_eip+0x283>
           && stabs[lline].n_type != N_SOL
  10077e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100781:	89 c2                	mov    %eax,%edx
  100783:	89 d0                	mov    %edx,%eax
  100785:	01 c0                	add    %eax,%eax
  100787:	01 d0                	add    %edx,%eax
  100789:	c1 e0 02             	shl    $0x2,%eax
  10078c:	89 c2                	mov    %eax,%edx
  10078e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100791:	01 d0                	add    %edx,%eax
  100793:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100797:	3c 84                	cmp    $0x84,%al
  100799:	74 39                	je     1007d4 <debuginfo_eip+0x283>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  10079b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10079e:	89 c2                	mov    %eax,%edx
  1007a0:	89 d0                	mov    %edx,%eax
  1007a2:	01 c0                	add    %eax,%eax
  1007a4:	01 d0                	add    %edx,%eax
  1007a6:	c1 e0 02             	shl    $0x2,%eax
  1007a9:	89 c2                	mov    %eax,%edx
  1007ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007ae:	01 d0                	add    %edx,%eax
  1007b0:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1007b4:	3c 64                	cmp    $0x64,%al
  1007b6:	75 b5                	jne    10076d <debuginfo_eip+0x21c>
  1007b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007bb:	89 c2                	mov    %eax,%edx
  1007bd:	89 d0                	mov    %edx,%eax
  1007bf:	01 c0                	add    %eax,%eax
  1007c1:	01 d0                	add    %edx,%eax
  1007c3:	c1 e0 02             	shl    $0x2,%eax
  1007c6:	89 c2                	mov    %eax,%edx
  1007c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007cb:	01 d0                	add    %edx,%eax
  1007cd:	8b 40 08             	mov    0x8(%eax),%eax
  1007d0:	85 c0                	test   %eax,%eax
  1007d2:	74 99                	je     10076d <debuginfo_eip+0x21c>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  1007d4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1007d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1007da:	39 c2                	cmp    %eax,%edx
  1007dc:	7c 42                	jl     100820 <debuginfo_eip+0x2cf>
  1007de:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007e1:	89 c2                	mov    %eax,%edx
  1007e3:	89 d0                	mov    %edx,%eax
  1007e5:	01 c0                	add    %eax,%eax
  1007e7:	01 d0                	add    %edx,%eax
  1007e9:	c1 e0 02             	shl    $0x2,%eax
  1007ec:	89 c2                	mov    %eax,%edx
  1007ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007f1:	01 d0                	add    %edx,%eax
  1007f3:	8b 10                	mov    (%eax),%edx
  1007f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1007f8:	2b 45 ec             	sub    -0x14(%ebp),%eax
  1007fb:	39 c2                	cmp    %eax,%edx
  1007fd:	73 21                	jae    100820 <debuginfo_eip+0x2cf>
        info->eip_file = stabstr + stabs[lline].n_strx;
  1007ff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100802:	89 c2                	mov    %eax,%edx
  100804:	89 d0                	mov    %edx,%eax
  100806:	01 c0                	add    %eax,%eax
  100808:	01 d0                	add    %edx,%eax
  10080a:	c1 e0 02             	shl    $0x2,%eax
  10080d:	89 c2                	mov    %eax,%edx
  10080f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100812:	01 d0                	add    %edx,%eax
  100814:	8b 10                	mov    (%eax),%edx
  100816:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100819:	01 c2                	add    %eax,%edx
  10081b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10081e:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  100820:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100823:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100826:	39 c2                	cmp    %eax,%edx
  100828:	7d 46                	jge    100870 <debuginfo_eip+0x31f>
        for (lline = lfun + 1;
  10082a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10082d:	40                   	inc    %eax
  10082e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  100831:	eb 16                	jmp    100849 <debuginfo_eip+0x2f8>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  100833:	8b 45 0c             	mov    0xc(%ebp),%eax
  100836:	8b 40 14             	mov    0x14(%eax),%eax
  100839:	8d 50 01             	lea    0x1(%eax),%edx
  10083c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10083f:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
  100842:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100845:	40                   	inc    %eax
  100846:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100849:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10084c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10084f:	39 c2                	cmp    %eax,%edx
  100851:	7d 1d                	jge    100870 <debuginfo_eip+0x31f>
  100853:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100856:	89 c2                	mov    %eax,%edx
  100858:	89 d0                	mov    %edx,%eax
  10085a:	01 c0                	add    %eax,%eax
  10085c:	01 d0                	add    %edx,%eax
  10085e:	c1 e0 02             	shl    $0x2,%eax
  100861:	89 c2                	mov    %eax,%edx
  100863:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100866:	01 d0                	add    %edx,%eax
  100868:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10086c:	3c a0                	cmp    $0xa0,%al
  10086e:	74 c3                	je     100833 <debuginfo_eip+0x2e2>
        }
    }
    return 0;
  100870:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100875:	89 ec                	mov    %ebp,%esp
  100877:	5d                   	pop    %ebp
  100878:	c3                   	ret    

00100879 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  100879:	55                   	push   %ebp
  10087a:	89 e5                	mov    %esp,%ebp
  10087c:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  10087f:	c7 04 24 56 60 10 00 	movl   $0x106056,(%esp)
  100886:	e8 cb fa ff ff       	call   100356 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  10088b:	c7 44 24 04 36 00 10 	movl   $0x100036,0x4(%esp)
  100892:	00 
  100893:	c7 04 24 6f 60 10 00 	movl   $0x10606f,(%esp)
  10089a:	e8 b7 fa ff ff       	call   100356 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  10089f:	c7 44 24 04 89 5f 10 	movl   $0x105f89,0x4(%esp)
  1008a6:	00 
  1008a7:	c7 04 24 87 60 10 00 	movl   $0x106087,(%esp)
  1008ae:	e8 a3 fa ff ff       	call   100356 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  1008b3:	c7 44 24 04 36 8a 11 	movl   $0x118a36,0x4(%esp)
  1008ba:	00 
  1008bb:	c7 04 24 9f 60 10 00 	movl   $0x10609f,(%esp)
  1008c2:	e8 8f fa ff ff       	call   100356 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  1008c7:	c7 44 24 04 2c bf 11 	movl   $0x11bf2c,0x4(%esp)
  1008ce:	00 
  1008cf:	c7 04 24 b7 60 10 00 	movl   $0x1060b7,(%esp)
  1008d6:	e8 7b fa ff ff       	call   100356 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  1008db:	b8 2c bf 11 00       	mov    $0x11bf2c,%eax
  1008e0:	2d 36 00 10 00       	sub    $0x100036,%eax
  1008e5:	05 ff 03 00 00       	add    $0x3ff,%eax
  1008ea:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1008f0:	85 c0                	test   %eax,%eax
  1008f2:	0f 48 c2             	cmovs  %edx,%eax
  1008f5:	c1 f8 0a             	sar    $0xa,%eax
  1008f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  1008fc:	c7 04 24 d0 60 10 00 	movl   $0x1060d0,(%esp)
  100903:	e8 4e fa ff ff       	call   100356 <cprintf>
}
  100908:	90                   	nop
  100909:	89 ec                	mov    %ebp,%esp
  10090b:	5d                   	pop    %ebp
  10090c:	c3                   	ret    

0010090d <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  10090d:	55                   	push   %ebp
  10090e:	89 e5                	mov    %esp,%ebp
  100910:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  100916:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100919:	89 44 24 04          	mov    %eax,0x4(%esp)
  10091d:	8b 45 08             	mov    0x8(%ebp),%eax
  100920:	89 04 24             	mov    %eax,(%esp)
  100923:	e8 29 fc ff ff       	call   100551 <debuginfo_eip>
  100928:	85 c0                	test   %eax,%eax
  10092a:	74 15                	je     100941 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  10092c:	8b 45 08             	mov    0x8(%ebp),%eax
  10092f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100933:	c7 04 24 fa 60 10 00 	movl   $0x1060fa,(%esp)
  10093a:	e8 17 fa ff ff       	call   100356 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
  10093f:	eb 6c                	jmp    1009ad <print_debuginfo+0xa0>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100941:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100948:	eb 1b                	jmp    100965 <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
  10094a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10094d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100950:	01 d0                	add    %edx,%eax
  100952:	0f b6 10             	movzbl (%eax),%edx
  100955:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  10095b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10095e:	01 c8                	add    %ecx,%eax
  100960:	88 10                	mov    %dl,(%eax)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100962:	ff 45 f4             	incl   -0xc(%ebp)
  100965:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100968:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  10096b:	7c dd                	jl     10094a <print_debuginfo+0x3d>
        fnname[j] = '\0';
  10096d:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  100973:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100976:	01 d0                	add    %edx,%eax
  100978:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
  10097b:	8b 55 ec             	mov    -0x14(%ebp),%edx
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  10097e:	8b 45 08             	mov    0x8(%ebp),%eax
  100981:	29 d0                	sub    %edx,%eax
  100983:	89 c1                	mov    %eax,%ecx
  100985:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100988:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10098b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  10098f:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100995:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100999:	89 54 24 08          	mov    %edx,0x8(%esp)
  10099d:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009a1:	c7 04 24 16 61 10 00 	movl   $0x106116,(%esp)
  1009a8:	e8 a9 f9 ff ff       	call   100356 <cprintf>
}
  1009ad:	90                   	nop
  1009ae:	89 ec                	mov    %ebp,%esp
  1009b0:	5d                   	pop    %ebp
  1009b1:	c3                   	ret    

001009b2 <read_eip>:

static __noinline uint32_t
read_eip(void) {
  1009b2:	55                   	push   %ebp
  1009b3:	89 e5                	mov    %esp,%ebp
  1009b5:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  1009b8:	8b 45 04             	mov    0x4(%ebp),%eax
  1009bb:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  1009be:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1009c1:	89 ec                	mov    %ebp,%esp
  1009c3:	5d                   	pop    %ebp
  1009c4:	c3                   	ret    

001009c5 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  1009c5:	55                   	push   %ebp
  1009c6:	89 e5                	mov    %esp,%ebp
  1009c8:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  1009cb:	89 e8                	mov    %ebp,%eax
  1009cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
  1009d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
      uint32_t ebp = read_ebp(), eip = read_eip();
  1009d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1009d6:	e8 d7 ff ff ff       	call   1009b2 <read_eip>
  1009db:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
  1009de:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  1009e5:	e9 84 00 00 00       	jmp    100a6e <print_stackframe+0xa9>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
  1009ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1009ed:	89 44 24 08          	mov    %eax,0x8(%esp)
  1009f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1009f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009f8:	c7 04 24 28 61 10 00 	movl   $0x106128,(%esp)
  1009ff:	e8 52 f9 ff ff       	call   100356 <cprintf>
        uint32_t *args = (uint32_t *)ebp + 2;
  100a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a07:	83 c0 08             	add    $0x8,%eax
  100a0a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (j = 0; j < 4; j ++) {
  100a0d:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  100a14:	eb 24                	jmp    100a3a <print_stackframe+0x75>
            cprintf("0x%08x ", args[j]);
  100a16:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a19:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100a20:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100a23:	01 d0                	add    %edx,%eax
  100a25:	8b 00                	mov    (%eax),%eax
  100a27:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a2b:	c7 04 24 44 61 10 00 	movl   $0x106144,(%esp)
  100a32:	e8 1f f9 ff ff       	call   100356 <cprintf>
        for (j = 0; j < 4; j ++) {
  100a37:	ff 45 e8             	incl   -0x18(%ebp)
  100a3a:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
  100a3e:	7e d6                	jle    100a16 <print_stackframe+0x51>
        }
        cprintf("\n");
  100a40:	c7 04 24 4c 61 10 00 	movl   $0x10614c,(%esp)
  100a47:	e8 0a f9 ff ff       	call   100356 <cprintf>
        print_debuginfo(eip - 1);
  100a4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100a4f:	48                   	dec    %eax
  100a50:	89 04 24             	mov    %eax,(%esp)
  100a53:	e8 b5 fe ff ff       	call   10090d <print_debuginfo>
        eip = ((uint32_t *)ebp)[1];
  100a58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a5b:	83 c0 04             	add    $0x4,%eax
  100a5e:	8b 00                	mov    (%eax),%eax
  100a60:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0];
  100a63:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a66:	8b 00                	mov    (%eax),%eax
  100a68:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
  100a6b:	ff 45 ec             	incl   -0x14(%ebp)
  100a6e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100a72:	74 0a                	je     100a7e <print_stackframe+0xb9>
  100a74:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100a78:	0f 8e 6c ff ff ff    	jle    1009ea <print_stackframe+0x25>
    }
}
  100a7e:	90                   	nop
  100a7f:	89 ec                	mov    %ebp,%esp
  100a81:	5d                   	pop    %ebp
  100a82:	c3                   	ret    

00100a83 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100a83:	55                   	push   %ebp
  100a84:	89 e5                	mov    %esp,%ebp
  100a86:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  100a89:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100a90:	eb 0c                	jmp    100a9e <parse+0x1b>
            *buf ++ = '\0';
  100a92:	8b 45 08             	mov    0x8(%ebp),%eax
  100a95:	8d 50 01             	lea    0x1(%eax),%edx
  100a98:	89 55 08             	mov    %edx,0x8(%ebp)
  100a9b:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  100aa1:	0f b6 00             	movzbl (%eax),%eax
  100aa4:	84 c0                	test   %al,%al
  100aa6:	74 1d                	je     100ac5 <parse+0x42>
  100aa8:	8b 45 08             	mov    0x8(%ebp),%eax
  100aab:	0f b6 00             	movzbl (%eax),%eax
  100aae:	0f be c0             	movsbl %al,%eax
  100ab1:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ab5:	c7 04 24 d0 61 10 00 	movl   $0x1061d0,(%esp)
  100abc:	e8 80 51 00 00       	call   105c41 <strchr>
  100ac1:	85 c0                	test   %eax,%eax
  100ac3:	75 cd                	jne    100a92 <parse+0xf>
        }
        if (*buf == '\0') {
  100ac5:	8b 45 08             	mov    0x8(%ebp),%eax
  100ac8:	0f b6 00             	movzbl (%eax),%eax
  100acb:	84 c0                	test   %al,%al
  100acd:	74 65                	je     100b34 <parse+0xb1>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100acf:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100ad3:	75 14                	jne    100ae9 <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100ad5:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100adc:	00 
  100add:	c7 04 24 d5 61 10 00 	movl   $0x1061d5,(%esp)
  100ae4:	e8 6d f8 ff ff       	call   100356 <cprintf>
        }
        argv[argc ++] = buf;
  100ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100aec:	8d 50 01             	lea    0x1(%eax),%edx
  100aef:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100af2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100af9:	8b 45 0c             	mov    0xc(%ebp),%eax
  100afc:	01 c2                	add    %eax,%edx
  100afe:	8b 45 08             	mov    0x8(%ebp),%eax
  100b01:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100b03:	eb 03                	jmp    100b08 <parse+0x85>
            buf ++;
  100b05:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100b08:	8b 45 08             	mov    0x8(%ebp),%eax
  100b0b:	0f b6 00             	movzbl (%eax),%eax
  100b0e:	84 c0                	test   %al,%al
  100b10:	74 8c                	je     100a9e <parse+0x1b>
  100b12:	8b 45 08             	mov    0x8(%ebp),%eax
  100b15:	0f b6 00             	movzbl (%eax),%eax
  100b18:	0f be c0             	movsbl %al,%eax
  100b1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b1f:	c7 04 24 d0 61 10 00 	movl   $0x1061d0,(%esp)
  100b26:	e8 16 51 00 00       	call   105c41 <strchr>
  100b2b:	85 c0                	test   %eax,%eax
  100b2d:	74 d6                	je     100b05 <parse+0x82>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b2f:	e9 6a ff ff ff       	jmp    100a9e <parse+0x1b>
            break;
  100b34:	90                   	nop
        }
    }
    return argc;
  100b35:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100b38:	89 ec                	mov    %ebp,%esp
  100b3a:	5d                   	pop    %ebp
  100b3b:	c3                   	ret    

00100b3c <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100b3c:	55                   	push   %ebp
  100b3d:	89 e5                	mov    %esp,%ebp
  100b3f:	83 ec 68             	sub    $0x68,%esp
  100b42:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100b45:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100b48:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b4c:	8b 45 08             	mov    0x8(%ebp),%eax
  100b4f:	89 04 24             	mov    %eax,(%esp)
  100b52:	e8 2c ff ff ff       	call   100a83 <parse>
  100b57:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100b5a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100b5e:	75 0a                	jne    100b6a <runcmd+0x2e>
        return 0;
  100b60:	b8 00 00 00 00       	mov    $0x0,%eax
  100b65:	e9 83 00 00 00       	jmp    100bed <runcmd+0xb1>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100b6a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100b71:	eb 5a                	jmp    100bcd <runcmd+0x91>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100b73:	8b 55 b0             	mov    -0x50(%ebp),%edx
  100b76:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  100b79:	89 c8                	mov    %ecx,%eax
  100b7b:	01 c0                	add    %eax,%eax
  100b7d:	01 c8                	add    %ecx,%eax
  100b7f:	c1 e0 02             	shl    $0x2,%eax
  100b82:	05 00 80 11 00       	add    $0x118000,%eax
  100b87:	8b 00                	mov    (%eax),%eax
  100b89:	89 54 24 04          	mov    %edx,0x4(%esp)
  100b8d:	89 04 24             	mov    %eax,(%esp)
  100b90:	e8 10 50 00 00       	call   105ba5 <strcmp>
  100b95:	85 c0                	test   %eax,%eax
  100b97:	75 31                	jne    100bca <runcmd+0x8e>
            return commands[i].func(argc - 1, argv + 1, tf);
  100b99:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100b9c:	89 d0                	mov    %edx,%eax
  100b9e:	01 c0                	add    %eax,%eax
  100ba0:	01 d0                	add    %edx,%eax
  100ba2:	c1 e0 02             	shl    $0x2,%eax
  100ba5:	05 08 80 11 00       	add    $0x118008,%eax
  100baa:	8b 10                	mov    (%eax),%edx
  100bac:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100baf:	83 c0 04             	add    $0x4,%eax
  100bb2:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  100bb5:	8d 59 ff             	lea    -0x1(%ecx),%ebx
  100bb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  100bbb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100bbf:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bc3:	89 1c 24             	mov    %ebx,(%esp)
  100bc6:	ff d2                	call   *%edx
  100bc8:	eb 23                	jmp    100bed <runcmd+0xb1>
    for (i = 0; i < NCOMMANDS; i ++) {
  100bca:	ff 45 f4             	incl   -0xc(%ebp)
  100bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100bd0:	83 f8 02             	cmp    $0x2,%eax
  100bd3:	76 9e                	jbe    100b73 <runcmd+0x37>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100bd5:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100bd8:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bdc:	c7 04 24 f3 61 10 00 	movl   $0x1061f3,(%esp)
  100be3:	e8 6e f7 ff ff       	call   100356 <cprintf>
    return 0;
  100be8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100bed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  100bf0:	89 ec                	mov    %ebp,%esp
  100bf2:	5d                   	pop    %ebp
  100bf3:	c3                   	ret    

00100bf4 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100bf4:	55                   	push   %ebp
  100bf5:	89 e5                	mov    %esp,%ebp
  100bf7:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100bfa:	c7 04 24 0c 62 10 00 	movl   $0x10620c,(%esp)
  100c01:	e8 50 f7 ff ff       	call   100356 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100c06:	c7 04 24 34 62 10 00 	movl   $0x106234,(%esp)
  100c0d:	e8 44 f7 ff ff       	call   100356 <cprintf>

    if (tf != NULL) {
  100c12:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100c16:	74 0b                	je     100c23 <kmonitor+0x2f>
        print_trapframe(tf);
  100c18:	8b 45 08             	mov    0x8(%ebp),%eax
  100c1b:	89 04 24             	mov    %eax,(%esp)
  100c1e:	e8 74 0e 00 00       	call   101a97 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100c23:	c7 04 24 59 62 10 00 	movl   $0x106259,(%esp)
  100c2a:	e8 18 f6 ff ff       	call   100247 <readline>
  100c2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100c32:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100c36:	74 eb                	je     100c23 <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
  100c38:	8b 45 08             	mov    0x8(%ebp),%eax
  100c3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c42:	89 04 24             	mov    %eax,(%esp)
  100c45:	e8 f2 fe ff ff       	call   100b3c <runcmd>
  100c4a:	85 c0                	test   %eax,%eax
  100c4c:	78 02                	js     100c50 <kmonitor+0x5c>
        if ((buf = readline("K> ")) != NULL) {
  100c4e:	eb d3                	jmp    100c23 <kmonitor+0x2f>
                break;
  100c50:	90                   	nop
            }
        }
    }
}
  100c51:	90                   	nop
  100c52:	89 ec                	mov    %ebp,%esp
  100c54:	5d                   	pop    %ebp
  100c55:	c3                   	ret    

00100c56 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100c56:	55                   	push   %ebp
  100c57:	89 e5                	mov    %esp,%ebp
  100c59:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c5c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c63:	eb 3d                	jmp    100ca2 <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100c65:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c68:	89 d0                	mov    %edx,%eax
  100c6a:	01 c0                	add    %eax,%eax
  100c6c:	01 d0                	add    %edx,%eax
  100c6e:	c1 e0 02             	shl    $0x2,%eax
  100c71:	05 04 80 11 00       	add    $0x118004,%eax
  100c76:	8b 10                	mov    (%eax),%edx
  100c78:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  100c7b:	89 c8                	mov    %ecx,%eax
  100c7d:	01 c0                	add    %eax,%eax
  100c7f:	01 c8                	add    %ecx,%eax
  100c81:	c1 e0 02             	shl    $0x2,%eax
  100c84:	05 00 80 11 00       	add    $0x118000,%eax
  100c89:	8b 00                	mov    (%eax),%eax
  100c8b:	89 54 24 08          	mov    %edx,0x8(%esp)
  100c8f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c93:	c7 04 24 5d 62 10 00 	movl   $0x10625d,(%esp)
  100c9a:	e8 b7 f6 ff ff       	call   100356 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
  100c9f:	ff 45 f4             	incl   -0xc(%ebp)
  100ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ca5:	83 f8 02             	cmp    $0x2,%eax
  100ca8:	76 bb                	jbe    100c65 <mon_help+0xf>
    }
    return 0;
  100caa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100caf:	89 ec                	mov    %ebp,%esp
  100cb1:	5d                   	pop    %ebp
  100cb2:	c3                   	ret    

00100cb3 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100cb3:	55                   	push   %ebp
  100cb4:	89 e5                	mov    %esp,%ebp
  100cb6:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100cb9:	e8 bb fb ff ff       	call   100879 <print_kerninfo>
    return 0;
  100cbe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cc3:	89 ec                	mov    %ebp,%esp
  100cc5:	5d                   	pop    %ebp
  100cc6:	c3                   	ret    

00100cc7 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100cc7:	55                   	push   %ebp
  100cc8:	89 e5                	mov    %esp,%ebp
  100cca:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100ccd:	e8 f3 fc ff ff       	call   1009c5 <print_stackframe>
    return 0;
  100cd2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cd7:	89 ec                	mov    %ebp,%esp
  100cd9:	5d                   	pop    %ebp
  100cda:	c3                   	ret    

00100cdb <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  100cdb:	55                   	push   %ebp
  100cdc:	89 e5                	mov    %esp,%ebp
  100cde:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  100ce1:	a1 20 b4 11 00       	mov    0x11b420,%eax
  100ce6:	85 c0                	test   %eax,%eax
  100ce8:	75 5b                	jne    100d45 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
  100cea:	c7 05 20 b4 11 00 01 	movl   $0x1,0x11b420
  100cf1:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  100cf4:	8d 45 14             	lea    0x14(%ebp),%eax
  100cf7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  100cfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  100cfd:	89 44 24 08          	mov    %eax,0x8(%esp)
  100d01:	8b 45 08             	mov    0x8(%ebp),%eax
  100d04:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d08:	c7 04 24 66 62 10 00 	movl   $0x106266,(%esp)
  100d0f:	e8 42 f6 ff ff       	call   100356 <cprintf>
    vcprintf(fmt, ap);
  100d14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d17:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d1b:	8b 45 10             	mov    0x10(%ebp),%eax
  100d1e:	89 04 24             	mov    %eax,(%esp)
  100d21:	e8 fb f5 ff ff       	call   100321 <vcprintf>
    cprintf("\n");
  100d26:	c7 04 24 82 62 10 00 	movl   $0x106282,(%esp)
  100d2d:	e8 24 f6 ff ff       	call   100356 <cprintf>
    
    cprintf("stack trackback:\n");
  100d32:	c7 04 24 84 62 10 00 	movl   $0x106284,(%esp)
  100d39:	e8 18 f6 ff ff       	call   100356 <cprintf>
    print_stackframe();
  100d3e:	e8 82 fc ff ff       	call   1009c5 <print_stackframe>
  100d43:	eb 01                	jmp    100d46 <__panic+0x6b>
        goto panic_dead;
  100d45:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
  100d46:	e8 e9 09 00 00       	call   101734 <intr_disable>
    while (1) {
        kmonitor(NULL);
  100d4b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100d52:	e8 9d fe ff ff       	call   100bf4 <kmonitor>
  100d57:	eb f2                	jmp    100d4b <__panic+0x70>

00100d59 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100d59:	55                   	push   %ebp
  100d5a:	89 e5                	mov    %esp,%ebp
  100d5c:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  100d5f:	8d 45 14             	lea    0x14(%ebp),%eax
  100d62:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  100d65:	8b 45 0c             	mov    0xc(%ebp),%eax
  100d68:	89 44 24 08          	mov    %eax,0x8(%esp)
  100d6c:	8b 45 08             	mov    0x8(%ebp),%eax
  100d6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d73:	c7 04 24 96 62 10 00 	movl   $0x106296,(%esp)
  100d7a:	e8 d7 f5 ff ff       	call   100356 <cprintf>
    vcprintf(fmt, ap);
  100d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d82:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d86:	8b 45 10             	mov    0x10(%ebp),%eax
  100d89:	89 04 24             	mov    %eax,(%esp)
  100d8c:	e8 90 f5 ff ff       	call   100321 <vcprintf>
    cprintf("\n");
  100d91:	c7 04 24 82 62 10 00 	movl   $0x106282,(%esp)
  100d98:	e8 b9 f5 ff ff       	call   100356 <cprintf>
    va_end(ap);
}
  100d9d:	90                   	nop
  100d9e:	89 ec                	mov    %ebp,%esp
  100da0:	5d                   	pop    %ebp
  100da1:	c3                   	ret    

00100da2 <is_kernel_panic>:

bool
is_kernel_panic(void) {
  100da2:	55                   	push   %ebp
  100da3:	89 e5                	mov    %esp,%ebp
    return is_panic;
  100da5:	a1 20 b4 11 00       	mov    0x11b420,%eax
}
  100daa:	5d                   	pop    %ebp
  100dab:	c3                   	ret    

00100dac <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100dac:	55                   	push   %ebp
  100dad:	89 e5                	mov    %esp,%ebp
  100daf:	83 ec 28             	sub    $0x28,%esp
  100db2:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
  100db8:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100dbc:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100dc0:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100dc4:	ee                   	out    %al,(%dx)
}
  100dc5:	90                   	nop
  100dc6:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100dcc:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100dd0:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100dd4:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100dd8:	ee                   	out    %al,(%dx)
}
  100dd9:	90                   	nop
  100dda:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
  100de0:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100de4:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100de8:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100dec:	ee                   	out    %al,(%dx)
}
  100ded:	90                   	nop
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100dee:	c7 05 24 b4 11 00 00 	movl   $0x0,0x11b424
  100df5:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100df8:	c7 04 24 b4 62 10 00 	movl   $0x1062b4,(%esp)
  100dff:	e8 52 f5 ff ff       	call   100356 <cprintf>
    pic_enable(IRQ_TIMER);
  100e04:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100e0b:	e8 89 09 00 00       	call   101799 <pic_enable>
}
  100e10:	90                   	nop
  100e11:	89 ec                	mov    %ebp,%esp
  100e13:	5d                   	pop    %ebp
  100e14:	c3                   	ret    

00100e15 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  100e15:	55                   	push   %ebp
  100e16:	89 e5                	mov    %esp,%ebp
  100e18:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  100e1b:	9c                   	pushf  
  100e1c:	58                   	pop    %eax
  100e1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  100e20:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  100e23:	25 00 02 00 00       	and    $0x200,%eax
  100e28:	85 c0                	test   %eax,%eax
  100e2a:	74 0c                	je     100e38 <__intr_save+0x23>
        intr_disable();
  100e2c:	e8 03 09 00 00       	call   101734 <intr_disable>
        return 1;
  100e31:	b8 01 00 00 00       	mov    $0x1,%eax
  100e36:	eb 05                	jmp    100e3d <__intr_save+0x28>
    }
    return 0;
  100e38:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100e3d:	89 ec                	mov    %ebp,%esp
  100e3f:	5d                   	pop    %ebp
  100e40:	c3                   	ret    

00100e41 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  100e41:	55                   	push   %ebp
  100e42:	89 e5                	mov    %esp,%ebp
  100e44:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  100e47:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100e4b:	74 05                	je     100e52 <__intr_restore+0x11>
        intr_enable();
  100e4d:	e8 da 08 00 00       	call   10172c <intr_enable>
    }
}
  100e52:	90                   	nop
  100e53:	89 ec                	mov    %ebp,%esp
  100e55:	5d                   	pop    %ebp
  100e56:	c3                   	ret    

00100e57 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100e57:	55                   	push   %ebp
  100e58:	89 e5                	mov    %esp,%ebp
  100e5a:	83 ec 10             	sub    $0x10,%esp
  100e5d:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100e63:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100e67:	89 c2                	mov    %eax,%edx
  100e69:	ec                   	in     (%dx),%al
  100e6a:	88 45 f1             	mov    %al,-0xf(%ebp)
  100e6d:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
  100e73:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100e77:	89 c2                	mov    %eax,%edx
  100e79:	ec                   	in     (%dx),%al
  100e7a:	88 45 f5             	mov    %al,-0xb(%ebp)
  100e7d:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100e83:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100e87:	89 c2                	mov    %eax,%edx
  100e89:	ec                   	in     (%dx),%al
  100e8a:	88 45 f9             	mov    %al,-0x7(%ebp)
  100e8d:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
  100e93:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100e97:	89 c2                	mov    %eax,%edx
  100e99:	ec                   	in     (%dx),%al
  100e9a:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100e9d:	90                   	nop
  100e9e:	89 ec                	mov    %ebp,%esp
  100ea0:	5d                   	pop    %ebp
  100ea1:	c3                   	ret    

00100ea2 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
  100ea2:	55                   	push   %ebp
  100ea3:	89 e5                	mov    %esp,%ebp
  100ea5:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
  100ea8:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
  100eaf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100eb2:	0f b7 00             	movzwl (%eax),%eax
  100eb5:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
  100eb9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ebc:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
  100ec1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ec4:	0f b7 00             	movzwl (%eax),%eax
  100ec7:	0f b7 c0             	movzwl %ax,%eax
  100eca:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
  100ecf:	74 12                	je     100ee3 <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
  100ed1:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
  100ed8:	66 c7 05 46 b4 11 00 	movw   $0x3b4,0x11b446
  100edf:	b4 03 
  100ee1:	eb 13                	jmp    100ef6 <cga_init+0x54>
    } else {
        *cp = was;
  100ee3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ee6:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100eea:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
  100eed:	66 c7 05 46 b4 11 00 	movw   $0x3d4,0x11b446
  100ef4:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
  100ef6:	0f b7 05 46 b4 11 00 	movzwl 0x11b446,%eax
  100efd:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  100f01:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f05:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100f09:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100f0d:	ee                   	out    %al,(%dx)
}
  100f0e:	90                   	nop
    pos = inb(addr_6845 + 1) << 8;
  100f0f:	0f b7 05 46 b4 11 00 	movzwl 0x11b446,%eax
  100f16:	40                   	inc    %eax
  100f17:	0f b7 c0             	movzwl %ax,%eax
  100f1a:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f1e:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
  100f22:	89 c2                	mov    %eax,%edx
  100f24:	ec                   	in     (%dx),%al
  100f25:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
  100f28:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100f2c:	0f b6 c0             	movzbl %al,%eax
  100f2f:	c1 e0 08             	shl    $0x8,%eax
  100f32:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100f35:	0f b7 05 46 b4 11 00 	movzwl 0x11b446,%eax
  100f3c:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  100f40:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f44:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100f48:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100f4c:	ee                   	out    %al,(%dx)
}
  100f4d:	90                   	nop
    pos |= inb(addr_6845 + 1);
  100f4e:	0f b7 05 46 b4 11 00 	movzwl 0x11b446,%eax
  100f55:	40                   	inc    %eax
  100f56:	0f b7 c0             	movzwl %ax,%eax
  100f59:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f5d:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100f61:	89 c2                	mov    %eax,%edx
  100f63:	ec                   	in     (%dx),%al
  100f64:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
  100f67:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100f6b:	0f b6 c0             	movzbl %al,%eax
  100f6e:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
  100f71:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f74:	a3 40 b4 11 00       	mov    %eax,0x11b440
    crt_pos = pos;
  100f79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100f7c:	0f b7 c0             	movzwl %ax,%eax
  100f7f:	66 a3 44 b4 11 00    	mov    %ax,0x11b444
}
  100f85:	90                   	nop
  100f86:	89 ec                	mov    %ebp,%esp
  100f88:	5d                   	pop    %ebp
  100f89:	c3                   	ret    

00100f8a <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100f8a:	55                   	push   %ebp
  100f8b:	89 e5                	mov    %esp,%ebp
  100f8d:	83 ec 48             	sub    $0x48,%esp
  100f90:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
  100f96:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f9a:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  100f9e:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  100fa2:	ee                   	out    %al,(%dx)
}
  100fa3:	90                   	nop
  100fa4:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
  100faa:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100fae:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  100fb2:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  100fb6:	ee                   	out    %al,(%dx)
}
  100fb7:	90                   	nop
  100fb8:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
  100fbe:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100fc2:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  100fc6:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  100fca:	ee                   	out    %al,(%dx)
}
  100fcb:	90                   	nop
  100fcc:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
  100fd2:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100fd6:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100fda:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  100fde:	ee                   	out    %al,(%dx)
}
  100fdf:	90                   	nop
  100fe0:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
  100fe6:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100fea:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  100fee:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  100ff2:	ee                   	out    %al,(%dx)
}
  100ff3:	90                   	nop
  100ff4:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
  100ffa:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100ffe:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  101002:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  101006:	ee                   	out    %al,(%dx)
}
  101007:	90                   	nop
  101008:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  10100e:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101012:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101016:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  10101a:	ee                   	out    %al,(%dx)
}
  10101b:	90                   	nop
  10101c:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101022:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  101026:	89 c2                	mov    %eax,%edx
  101028:	ec                   	in     (%dx),%al
  101029:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  10102c:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  101030:	3c ff                	cmp    $0xff,%al
  101032:	0f 95 c0             	setne  %al
  101035:	0f b6 c0             	movzbl %al,%eax
  101038:	a3 48 b4 11 00       	mov    %eax,0x11b448
  10103d:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101043:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  101047:	89 c2                	mov    %eax,%edx
  101049:	ec                   	in     (%dx),%al
  10104a:	88 45 f1             	mov    %al,-0xf(%ebp)
  10104d:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  101053:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  101057:	89 c2                	mov    %eax,%edx
  101059:	ec                   	in     (%dx),%al
  10105a:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  10105d:	a1 48 b4 11 00       	mov    0x11b448,%eax
  101062:	85 c0                	test   %eax,%eax
  101064:	74 0c                	je     101072 <serial_init+0xe8>
        pic_enable(IRQ_COM1);
  101066:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  10106d:	e8 27 07 00 00       	call   101799 <pic_enable>
    }
}
  101072:	90                   	nop
  101073:	89 ec                	mov    %ebp,%esp
  101075:	5d                   	pop    %ebp
  101076:	c3                   	ret    

00101077 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  101077:	55                   	push   %ebp
  101078:	89 e5                	mov    %esp,%ebp
  10107a:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  10107d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101084:	eb 08                	jmp    10108e <lpt_putc_sub+0x17>
        delay();
  101086:	e8 cc fd ff ff       	call   100e57 <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  10108b:	ff 45 fc             	incl   -0x4(%ebp)
  10108e:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
  101094:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101098:	89 c2                	mov    %eax,%edx
  10109a:	ec                   	in     (%dx),%al
  10109b:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  10109e:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  1010a2:	84 c0                	test   %al,%al
  1010a4:	78 09                	js     1010af <lpt_putc_sub+0x38>
  1010a6:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  1010ad:	7e d7                	jle    101086 <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
  1010af:	8b 45 08             	mov    0x8(%ebp),%eax
  1010b2:	0f b6 c0             	movzbl %al,%eax
  1010b5:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
  1010bb:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1010be:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1010c2:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1010c6:	ee                   	out    %al,(%dx)
}
  1010c7:	90                   	nop
  1010c8:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
  1010ce:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1010d2:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1010d6:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1010da:	ee                   	out    %al,(%dx)
}
  1010db:	90                   	nop
  1010dc:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
  1010e2:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1010e6:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1010ea:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1010ee:	ee                   	out    %al,(%dx)
}
  1010ef:	90                   	nop
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  1010f0:	90                   	nop
  1010f1:	89 ec                	mov    %ebp,%esp
  1010f3:	5d                   	pop    %ebp
  1010f4:	c3                   	ret    

001010f5 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  1010f5:	55                   	push   %ebp
  1010f6:	89 e5                	mov    %esp,%ebp
  1010f8:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  1010fb:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1010ff:	74 0d                	je     10110e <lpt_putc+0x19>
        lpt_putc_sub(c);
  101101:	8b 45 08             	mov    0x8(%ebp),%eax
  101104:	89 04 24             	mov    %eax,(%esp)
  101107:	e8 6b ff ff ff       	call   101077 <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
  10110c:	eb 24                	jmp    101132 <lpt_putc+0x3d>
        lpt_putc_sub('\b');
  10110e:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101115:	e8 5d ff ff ff       	call   101077 <lpt_putc_sub>
        lpt_putc_sub(' ');
  10111a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  101121:	e8 51 ff ff ff       	call   101077 <lpt_putc_sub>
        lpt_putc_sub('\b');
  101126:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10112d:	e8 45 ff ff ff       	call   101077 <lpt_putc_sub>
}
  101132:	90                   	nop
  101133:	89 ec                	mov    %ebp,%esp
  101135:	5d                   	pop    %ebp
  101136:	c3                   	ret    

00101137 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  101137:	55                   	push   %ebp
  101138:	89 e5                	mov    %esp,%ebp
  10113a:	83 ec 38             	sub    $0x38,%esp
  10113d:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    // set black on white
    if (!(c & ~0xFF)) {
  101140:	8b 45 08             	mov    0x8(%ebp),%eax
  101143:	25 00 ff ff ff       	and    $0xffffff00,%eax
  101148:	85 c0                	test   %eax,%eax
  10114a:	75 07                	jne    101153 <cga_putc+0x1c>
        c |= 0x0700;
  10114c:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  101153:	8b 45 08             	mov    0x8(%ebp),%eax
  101156:	0f b6 c0             	movzbl %al,%eax
  101159:	83 f8 0d             	cmp    $0xd,%eax
  10115c:	74 72                	je     1011d0 <cga_putc+0x99>
  10115e:	83 f8 0d             	cmp    $0xd,%eax
  101161:	0f 8f a3 00 00 00    	jg     10120a <cga_putc+0xd3>
  101167:	83 f8 08             	cmp    $0x8,%eax
  10116a:	74 0a                	je     101176 <cga_putc+0x3f>
  10116c:	83 f8 0a             	cmp    $0xa,%eax
  10116f:	74 4c                	je     1011bd <cga_putc+0x86>
  101171:	e9 94 00 00 00       	jmp    10120a <cga_putc+0xd3>
    case '\b':
        if (crt_pos > 0) {
  101176:	0f b7 05 44 b4 11 00 	movzwl 0x11b444,%eax
  10117d:	85 c0                	test   %eax,%eax
  10117f:	0f 84 af 00 00 00    	je     101234 <cga_putc+0xfd>
            crt_pos --;
  101185:	0f b7 05 44 b4 11 00 	movzwl 0x11b444,%eax
  10118c:	48                   	dec    %eax
  10118d:	0f b7 c0             	movzwl %ax,%eax
  101190:	66 a3 44 b4 11 00    	mov    %ax,0x11b444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  101196:	8b 45 08             	mov    0x8(%ebp),%eax
  101199:	98                   	cwtl   
  10119a:	25 00 ff ff ff       	and    $0xffffff00,%eax
  10119f:	98                   	cwtl   
  1011a0:	83 c8 20             	or     $0x20,%eax
  1011a3:	98                   	cwtl   
  1011a4:	8b 0d 40 b4 11 00    	mov    0x11b440,%ecx
  1011aa:	0f b7 15 44 b4 11 00 	movzwl 0x11b444,%edx
  1011b1:	01 d2                	add    %edx,%edx
  1011b3:	01 ca                	add    %ecx,%edx
  1011b5:	0f b7 c0             	movzwl %ax,%eax
  1011b8:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  1011bb:	eb 77                	jmp    101234 <cga_putc+0xfd>
    case '\n':
        crt_pos += CRT_COLS;
  1011bd:	0f b7 05 44 b4 11 00 	movzwl 0x11b444,%eax
  1011c4:	83 c0 50             	add    $0x50,%eax
  1011c7:	0f b7 c0             	movzwl %ax,%eax
  1011ca:	66 a3 44 b4 11 00    	mov    %ax,0x11b444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  1011d0:	0f b7 1d 44 b4 11 00 	movzwl 0x11b444,%ebx
  1011d7:	0f b7 0d 44 b4 11 00 	movzwl 0x11b444,%ecx
  1011de:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
  1011e3:	89 c8                	mov    %ecx,%eax
  1011e5:	f7 e2                	mul    %edx
  1011e7:	c1 ea 06             	shr    $0x6,%edx
  1011ea:	89 d0                	mov    %edx,%eax
  1011ec:	c1 e0 02             	shl    $0x2,%eax
  1011ef:	01 d0                	add    %edx,%eax
  1011f1:	c1 e0 04             	shl    $0x4,%eax
  1011f4:	29 c1                	sub    %eax,%ecx
  1011f6:	89 ca                	mov    %ecx,%edx
  1011f8:	0f b7 d2             	movzwl %dx,%edx
  1011fb:	89 d8                	mov    %ebx,%eax
  1011fd:	29 d0                	sub    %edx,%eax
  1011ff:	0f b7 c0             	movzwl %ax,%eax
  101202:	66 a3 44 b4 11 00    	mov    %ax,0x11b444
        break;
  101208:	eb 2b                	jmp    101235 <cga_putc+0xfe>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  10120a:	8b 0d 40 b4 11 00    	mov    0x11b440,%ecx
  101210:	0f b7 05 44 b4 11 00 	movzwl 0x11b444,%eax
  101217:	8d 50 01             	lea    0x1(%eax),%edx
  10121a:	0f b7 d2             	movzwl %dx,%edx
  10121d:	66 89 15 44 b4 11 00 	mov    %dx,0x11b444
  101224:	01 c0                	add    %eax,%eax
  101226:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  101229:	8b 45 08             	mov    0x8(%ebp),%eax
  10122c:	0f b7 c0             	movzwl %ax,%eax
  10122f:	66 89 02             	mov    %ax,(%edx)
        break;
  101232:	eb 01                	jmp    101235 <cga_putc+0xfe>
        break;
  101234:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  101235:	0f b7 05 44 b4 11 00 	movzwl 0x11b444,%eax
  10123c:	3d cf 07 00 00       	cmp    $0x7cf,%eax
  101241:	76 5e                	jbe    1012a1 <cga_putc+0x16a>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  101243:	a1 40 b4 11 00       	mov    0x11b440,%eax
  101248:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  10124e:	a1 40 b4 11 00       	mov    0x11b440,%eax
  101253:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  10125a:	00 
  10125b:	89 54 24 04          	mov    %edx,0x4(%esp)
  10125f:	89 04 24             	mov    %eax,(%esp)
  101262:	e8 d8 4b 00 00       	call   105e3f <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101267:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  10126e:	eb 15                	jmp    101285 <cga_putc+0x14e>
            crt_buf[i] = 0x0700 | ' ';
  101270:	8b 15 40 b4 11 00    	mov    0x11b440,%edx
  101276:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101279:	01 c0                	add    %eax,%eax
  10127b:	01 d0                	add    %edx,%eax
  10127d:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101282:	ff 45 f4             	incl   -0xc(%ebp)
  101285:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  10128c:	7e e2                	jle    101270 <cga_putc+0x139>
        }
        crt_pos -= CRT_COLS;
  10128e:	0f b7 05 44 b4 11 00 	movzwl 0x11b444,%eax
  101295:	83 e8 50             	sub    $0x50,%eax
  101298:	0f b7 c0             	movzwl %ax,%eax
  10129b:	66 a3 44 b4 11 00    	mov    %ax,0x11b444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  1012a1:	0f b7 05 46 b4 11 00 	movzwl 0x11b446,%eax
  1012a8:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  1012ac:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1012b0:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  1012b4:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  1012b8:	ee                   	out    %al,(%dx)
}
  1012b9:	90                   	nop
    outb(addr_6845 + 1, crt_pos >> 8);
  1012ba:	0f b7 05 44 b4 11 00 	movzwl 0x11b444,%eax
  1012c1:	c1 e8 08             	shr    $0x8,%eax
  1012c4:	0f b7 c0             	movzwl %ax,%eax
  1012c7:	0f b6 c0             	movzbl %al,%eax
  1012ca:	0f b7 15 46 b4 11 00 	movzwl 0x11b446,%edx
  1012d1:	42                   	inc    %edx
  1012d2:	0f b7 d2             	movzwl %dx,%edx
  1012d5:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
  1012d9:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1012dc:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1012e0:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  1012e4:	ee                   	out    %al,(%dx)
}
  1012e5:	90                   	nop
    outb(addr_6845, 15);
  1012e6:	0f b7 05 46 b4 11 00 	movzwl 0x11b446,%eax
  1012ed:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  1012f1:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1012f5:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1012f9:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1012fd:	ee                   	out    %al,(%dx)
}
  1012fe:	90                   	nop
    outb(addr_6845 + 1, crt_pos);
  1012ff:	0f b7 05 44 b4 11 00 	movzwl 0x11b444,%eax
  101306:	0f b6 c0             	movzbl %al,%eax
  101309:	0f b7 15 46 b4 11 00 	movzwl 0x11b446,%edx
  101310:	42                   	inc    %edx
  101311:	0f b7 d2             	movzwl %dx,%edx
  101314:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
  101318:	88 45 f1             	mov    %al,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10131b:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  10131f:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101323:	ee                   	out    %al,(%dx)
}
  101324:	90                   	nop
}
  101325:	90                   	nop
  101326:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  101329:	89 ec                	mov    %ebp,%esp
  10132b:	5d                   	pop    %ebp
  10132c:	c3                   	ret    

0010132d <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  10132d:	55                   	push   %ebp
  10132e:	89 e5                	mov    %esp,%ebp
  101330:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  101333:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  10133a:	eb 08                	jmp    101344 <serial_putc_sub+0x17>
        delay();
  10133c:	e8 16 fb ff ff       	call   100e57 <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  101341:	ff 45 fc             	incl   -0x4(%ebp)
  101344:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10134a:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  10134e:	89 c2                	mov    %eax,%edx
  101350:	ec                   	in     (%dx),%al
  101351:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101354:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101358:	0f b6 c0             	movzbl %al,%eax
  10135b:	83 e0 20             	and    $0x20,%eax
  10135e:	85 c0                	test   %eax,%eax
  101360:	75 09                	jne    10136b <serial_putc_sub+0x3e>
  101362:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101369:	7e d1                	jle    10133c <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
  10136b:	8b 45 08             	mov    0x8(%ebp),%eax
  10136e:	0f b6 c0             	movzbl %al,%eax
  101371:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  101377:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10137a:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  10137e:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101382:	ee                   	out    %al,(%dx)
}
  101383:	90                   	nop
}
  101384:	90                   	nop
  101385:	89 ec                	mov    %ebp,%esp
  101387:	5d                   	pop    %ebp
  101388:	c3                   	ret    

00101389 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  101389:	55                   	push   %ebp
  10138a:	89 e5                	mov    %esp,%ebp
  10138c:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  10138f:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  101393:	74 0d                	je     1013a2 <serial_putc+0x19>
        serial_putc_sub(c);
  101395:	8b 45 08             	mov    0x8(%ebp),%eax
  101398:	89 04 24             	mov    %eax,(%esp)
  10139b:	e8 8d ff ff ff       	call   10132d <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
  1013a0:	eb 24                	jmp    1013c6 <serial_putc+0x3d>
        serial_putc_sub('\b');
  1013a2:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1013a9:	e8 7f ff ff ff       	call   10132d <serial_putc_sub>
        serial_putc_sub(' ');
  1013ae:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1013b5:	e8 73 ff ff ff       	call   10132d <serial_putc_sub>
        serial_putc_sub('\b');
  1013ba:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1013c1:	e8 67 ff ff ff       	call   10132d <serial_putc_sub>
}
  1013c6:	90                   	nop
  1013c7:	89 ec                	mov    %ebp,%esp
  1013c9:	5d                   	pop    %ebp
  1013ca:	c3                   	ret    

001013cb <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  1013cb:	55                   	push   %ebp
  1013cc:	89 e5                	mov    %esp,%ebp
  1013ce:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  1013d1:	eb 33                	jmp    101406 <cons_intr+0x3b>
        if (c != 0) {
  1013d3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1013d7:	74 2d                	je     101406 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  1013d9:	a1 64 b6 11 00       	mov    0x11b664,%eax
  1013de:	8d 50 01             	lea    0x1(%eax),%edx
  1013e1:	89 15 64 b6 11 00    	mov    %edx,0x11b664
  1013e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1013ea:	88 90 60 b4 11 00    	mov    %dl,0x11b460(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  1013f0:	a1 64 b6 11 00       	mov    0x11b664,%eax
  1013f5:	3d 00 02 00 00       	cmp    $0x200,%eax
  1013fa:	75 0a                	jne    101406 <cons_intr+0x3b>
                cons.wpos = 0;
  1013fc:	c7 05 64 b6 11 00 00 	movl   $0x0,0x11b664
  101403:	00 00 00 
    while ((c = (*proc)()) != -1) {
  101406:	8b 45 08             	mov    0x8(%ebp),%eax
  101409:	ff d0                	call   *%eax
  10140b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10140e:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  101412:	75 bf                	jne    1013d3 <cons_intr+0x8>
            }
        }
    }
}
  101414:	90                   	nop
  101415:	90                   	nop
  101416:	89 ec                	mov    %ebp,%esp
  101418:	5d                   	pop    %ebp
  101419:	c3                   	ret    

0010141a <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  10141a:	55                   	push   %ebp
  10141b:	89 e5                	mov    %esp,%ebp
  10141d:	83 ec 10             	sub    $0x10,%esp
  101420:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101426:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  10142a:	89 c2                	mov    %eax,%edx
  10142c:	ec                   	in     (%dx),%al
  10142d:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101430:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  101434:	0f b6 c0             	movzbl %al,%eax
  101437:	83 e0 01             	and    $0x1,%eax
  10143a:	85 c0                	test   %eax,%eax
  10143c:	75 07                	jne    101445 <serial_proc_data+0x2b>
        return -1;
  10143e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  101443:	eb 2a                	jmp    10146f <serial_proc_data+0x55>
  101445:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10144b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10144f:	89 c2                	mov    %eax,%edx
  101451:	ec                   	in     (%dx),%al
  101452:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
  101455:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  101459:	0f b6 c0             	movzbl %al,%eax
  10145c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  10145f:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  101463:	75 07                	jne    10146c <serial_proc_data+0x52>
        c = '\b';
  101465:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  10146c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10146f:	89 ec                	mov    %ebp,%esp
  101471:	5d                   	pop    %ebp
  101472:	c3                   	ret    

00101473 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  101473:	55                   	push   %ebp
  101474:	89 e5                	mov    %esp,%ebp
  101476:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  101479:	a1 48 b4 11 00       	mov    0x11b448,%eax
  10147e:	85 c0                	test   %eax,%eax
  101480:	74 0c                	je     10148e <serial_intr+0x1b>
        cons_intr(serial_proc_data);
  101482:	c7 04 24 1a 14 10 00 	movl   $0x10141a,(%esp)
  101489:	e8 3d ff ff ff       	call   1013cb <cons_intr>
    }
}
  10148e:	90                   	nop
  10148f:	89 ec                	mov    %ebp,%esp
  101491:	5d                   	pop    %ebp
  101492:	c3                   	ret    

00101493 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  101493:	55                   	push   %ebp
  101494:	89 e5                	mov    %esp,%ebp
  101496:	83 ec 38             	sub    $0x38,%esp
  101499:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10149f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1014a2:	89 c2                	mov    %eax,%edx
  1014a4:	ec                   	in     (%dx),%al
  1014a5:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
  1014a8:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  1014ac:	0f b6 c0             	movzbl %al,%eax
  1014af:	83 e0 01             	and    $0x1,%eax
  1014b2:	85 c0                	test   %eax,%eax
  1014b4:	75 0a                	jne    1014c0 <kbd_proc_data+0x2d>
        return -1;
  1014b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1014bb:	e9 56 01 00 00       	jmp    101616 <kbd_proc_data+0x183>
  1014c0:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1014c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1014c9:	89 c2                	mov    %eax,%edx
  1014cb:	ec                   	in     (%dx),%al
  1014cc:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  1014cf:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
  1014d3:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  1014d6:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  1014da:	75 17                	jne    1014f3 <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
  1014dc:	a1 68 b6 11 00       	mov    0x11b668,%eax
  1014e1:	83 c8 40             	or     $0x40,%eax
  1014e4:	a3 68 b6 11 00       	mov    %eax,0x11b668
        return 0;
  1014e9:	b8 00 00 00 00       	mov    $0x0,%eax
  1014ee:	e9 23 01 00 00       	jmp    101616 <kbd_proc_data+0x183>
    } else if (data & 0x80) {
  1014f3:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014f7:	84 c0                	test   %al,%al
  1014f9:	79 45                	jns    101540 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  1014fb:	a1 68 b6 11 00       	mov    0x11b668,%eax
  101500:	83 e0 40             	and    $0x40,%eax
  101503:	85 c0                	test   %eax,%eax
  101505:	75 08                	jne    10150f <kbd_proc_data+0x7c>
  101507:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10150b:	24 7f                	and    $0x7f,%al
  10150d:	eb 04                	jmp    101513 <kbd_proc_data+0x80>
  10150f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101513:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  101516:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10151a:	0f b6 80 40 80 11 00 	movzbl 0x118040(%eax),%eax
  101521:	0c 40                	or     $0x40,%al
  101523:	0f b6 c0             	movzbl %al,%eax
  101526:	f7 d0                	not    %eax
  101528:	89 c2                	mov    %eax,%edx
  10152a:	a1 68 b6 11 00       	mov    0x11b668,%eax
  10152f:	21 d0                	and    %edx,%eax
  101531:	a3 68 b6 11 00       	mov    %eax,0x11b668
        return 0;
  101536:	b8 00 00 00 00       	mov    $0x0,%eax
  10153b:	e9 d6 00 00 00       	jmp    101616 <kbd_proc_data+0x183>
    } else if (shift & E0ESC) {
  101540:	a1 68 b6 11 00       	mov    0x11b668,%eax
  101545:	83 e0 40             	and    $0x40,%eax
  101548:	85 c0                	test   %eax,%eax
  10154a:	74 11                	je     10155d <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  10154c:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  101550:	a1 68 b6 11 00       	mov    0x11b668,%eax
  101555:	83 e0 bf             	and    $0xffffffbf,%eax
  101558:	a3 68 b6 11 00       	mov    %eax,0x11b668
    }

    shift |= shiftcode[data];
  10155d:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101561:	0f b6 80 40 80 11 00 	movzbl 0x118040(%eax),%eax
  101568:	0f b6 d0             	movzbl %al,%edx
  10156b:	a1 68 b6 11 00       	mov    0x11b668,%eax
  101570:	09 d0                	or     %edx,%eax
  101572:	a3 68 b6 11 00       	mov    %eax,0x11b668
    shift ^= togglecode[data];
  101577:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10157b:	0f b6 80 40 81 11 00 	movzbl 0x118140(%eax),%eax
  101582:	0f b6 d0             	movzbl %al,%edx
  101585:	a1 68 b6 11 00       	mov    0x11b668,%eax
  10158a:	31 d0                	xor    %edx,%eax
  10158c:	a3 68 b6 11 00       	mov    %eax,0x11b668

    c = charcode[shift & (CTL | SHIFT)][data];
  101591:	a1 68 b6 11 00       	mov    0x11b668,%eax
  101596:	83 e0 03             	and    $0x3,%eax
  101599:	8b 14 85 40 85 11 00 	mov    0x118540(,%eax,4),%edx
  1015a0:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1015a4:	01 d0                	add    %edx,%eax
  1015a6:	0f b6 00             	movzbl (%eax),%eax
  1015a9:	0f b6 c0             	movzbl %al,%eax
  1015ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  1015af:	a1 68 b6 11 00       	mov    0x11b668,%eax
  1015b4:	83 e0 08             	and    $0x8,%eax
  1015b7:	85 c0                	test   %eax,%eax
  1015b9:	74 22                	je     1015dd <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
  1015bb:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  1015bf:	7e 0c                	jle    1015cd <kbd_proc_data+0x13a>
  1015c1:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  1015c5:	7f 06                	jg     1015cd <kbd_proc_data+0x13a>
            c += 'A' - 'a';
  1015c7:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  1015cb:	eb 10                	jmp    1015dd <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
  1015cd:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  1015d1:	7e 0a                	jle    1015dd <kbd_proc_data+0x14a>
  1015d3:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  1015d7:	7f 04                	jg     1015dd <kbd_proc_data+0x14a>
            c += 'a' - 'A';
  1015d9:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  1015dd:	a1 68 b6 11 00       	mov    0x11b668,%eax
  1015e2:	f7 d0                	not    %eax
  1015e4:	83 e0 06             	and    $0x6,%eax
  1015e7:	85 c0                	test   %eax,%eax
  1015e9:	75 28                	jne    101613 <kbd_proc_data+0x180>
  1015eb:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  1015f2:	75 1f                	jne    101613 <kbd_proc_data+0x180>
        cprintf("Rebooting!\n");
  1015f4:	c7 04 24 cf 62 10 00 	movl   $0x1062cf,(%esp)
  1015fb:	e8 56 ed ff ff       	call   100356 <cprintf>
  101600:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
  101606:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10160a:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  10160e:	8b 55 e8             	mov    -0x18(%ebp),%edx
  101611:	ee                   	out    %al,(%dx)
}
  101612:	90                   	nop
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  101613:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  101616:	89 ec                	mov    %ebp,%esp
  101618:	5d                   	pop    %ebp
  101619:	c3                   	ret    

0010161a <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  10161a:	55                   	push   %ebp
  10161b:	89 e5                	mov    %esp,%ebp
  10161d:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  101620:	c7 04 24 93 14 10 00 	movl   $0x101493,(%esp)
  101627:	e8 9f fd ff ff       	call   1013cb <cons_intr>
}
  10162c:	90                   	nop
  10162d:	89 ec                	mov    %ebp,%esp
  10162f:	5d                   	pop    %ebp
  101630:	c3                   	ret    

00101631 <kbd_init>:

static void
kbd_init(void) {
  101631:	55                   	push   %ebp
  101632:	89 e5                	mov    %esp,%ebp
  101634:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  101637:	e8 de ff ff ff       	call   10161a <kbd_intr>
    pic_enable(IRQ_KBD);
  10163c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  101643:	e8 51 01 00 00       	call   101799 <pic_enable>
}
  101648:	90                   	nop
  101649:	89 ec                	mov    %ebp,%esp
  10164b:	5d                   	pop    %ebp
  10164c:	c3                   	ret    

0010164d <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  10164d:	55                   	push   %ebp
  10164e:	89 e5                	mov    %esp,%ebp
  101650:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  101653:	e8 4a f8 ff ff       	call   100ea2 <cga_init>
    serial_init();
  101658:	e8 2d f9 ff ff       	call   100f8a <serial_init>
    kbd_init();
  10165d:	e8 cf ff ff ff       	call   101631 <kbd_init>
    if (!serial_exists) {
  101662:	a1 48 b4 11 00       	mov    0x11b448,%eax
  101667:	85 c0                	test   %eax,%eax
  101669:	75 0c                	jne    101677 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  10166b:	c7 04 24 db 62 10 00 	movl   $0x1062db,(%esp)
  101672:	e8 df ec ff ff       	call   100356 <cprintf>
    }
}
  101677:	90                   	nop
  101678:	89 ec                	mov    %ebp,%esp
  10167a:	5d                   	pop    %ebp
  10167b:	c3                   	ret    

0010167c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  10167c:	55                   	push   %ebp
  10167d:	89 e5                	mov    %esp,%ebp
  10167f:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  101682:	e8 8e f7 ff ff       	call   100e15 <__intr_save>
  101687:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
  10168a:	8b 45 08             	mov    0x8(%ebp),%eax
  10168d:	89 04 24             	mov    %eax,(%esp)
  101690:	e8 60 fa ff ff       	call   1010f5 <lpt_putc>
        cga_putc(c);
  101695:	8b 45 08             	mov    0x8(%ebp),%eax
  101698:	89 04 24             	mov    %eax,(%esp)
  10169b:	e8 97 fa ff ff       	call   101137 <cga_putc>
        serial_putc(c);
  1016a0:	8b 45 08             	mov    0x8(%ebp),%eax
  1016a3:	89 04 24             	mov    %eax,(%esp)
  1016a6:	e8 de fc ff ff       	call   101389 <serial_putc>
    }
    local_intr_restore(intr_flag);
  1016ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1016ae:	89 04 24             	mov    %eax,(%esp)
  1016b1:	e8 8b f7 ff ff       	call   100e41 <__intr_restore>
}
  1016b6:	90                   	nop
  1016b7:	89 ec                	mov    %ebp,%esp
  1016b9:	5d                   	pop    %ebp
  1016ba:	c3                   	ret    

001016bb <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  1016bb:	55                   	push   %ebp
  1016bc:	89 e5                	mov    %esp,%ebp
  1016be:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
  1016c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  1016c8:	e8 48 f7 ff ff       	call   100e15 <__intr_save>
  1016cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
  1016d0:	e8 9e fd ff ff       	call   101473 <serial_intr>
        kbd_intr();
  1016d5:	e8 40 ff ff ff       	call   10161a <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
  1016da:	8b 15 60 b6 11 00    	mov    0x11b660,%edx
  1016e0:	a1 64 b6 11 00       	mov    0x11b664,%eax
  1016e5:	39 c2                	cmp    %eax,%edx
  1016e7:	74 31                	je     10171a <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
  1016e9:	a1 60 b6 11 00       	mov    0x11b660,%eax
  1016ee:	8d 50 01             	lea    0x1(%eax),%edx
  1016f1:	89 15 60 b6 11 00    	mov    %edx,0x11b660
  1016f7:	0f b6 80 60 b4 11 00 	movzbl 0x11b460(%eax),%eax
  1016fe:	0f b6 c0             	movzbl %al,%eax
  101701:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
  101704:	a1 60 b6 11 00       	mov    0x11b660,%eax
  101709:	3d 00 02 00 00       	cmp    $0x200,%eax
  10170e:	75 0a                	jne    10171a <cons_getc+0x5f>
                cons.rpos = 0;
  101710:	c7 05 60 b6 11 00 00 	movl   $0x0,0x11b660
  101717:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
  10171a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10171d:	89 04 24             	mov    %eax,(%esp)
  101720:	e8 1c f7 ff ff       	call   100e41 <__intr_restore>
    return c;
  101725:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  101728:	89 ec                	mov    %ebp,%esp
  10172a:	5d                   	pop    %ebp
  10172b:	c3                   	ret    

0010172c <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  10172c:	55                   	push   %ebp
  10172d:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
  10172f:	fb                   	sti    
}
  101730:	90                   	nop
    sti();
}
  101731:	90                   	nop
  101732:	5d                   	pop    %ebp
  101733:	c3                   	ret    

00101734 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  101734:	55                   	push   %ebp
  101735:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
  101737:	fa                   	cli    
}
  101738:	90                   	nop
    cli();
}
  101739:	90                   	nop
  10173a:	5d                   	pop    %ebp
  10173b:	c3                   	ret    

0010173c <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  10173c:	55                   	push   %ebp
  10173d:	89 e5                	mov    %esp,%ebp
  10173f:	83 ec 14             	sub    $0x14,%esp
  101742:	8b 45 08             	mov    0x8(%ebp),%eax
  101745:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  101749:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10174c:	66 a3 50 85 11 00    	mov    %ax,0x118550
    if (did_init) {
  101752:	a1 6c b6 11 00       	mov    0x11b66c,%eax
  101757:	85 c0                	test   %eax,%eax
  101759:	74 39                	je     101794 <pic_setmask+0x58>
        outb(IO_PIC1 + 1, mask);
  10175b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10175e:	0f b6 c0             	movzbl %al,%eax
  101761:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
  101767:	88 45 f9             	mov    %al,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10176a:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  10176e:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101772:	ee                   	out    %al,(%dx)
}
  101773:	90                   	nop
        outb(IO_PIC2 + 1, mask >> 8);
  101774:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101778:	c1 e8 08             	shr    $0x8,%eax
  10177b:	0f b7 c0             	movzwl %ax,%eax
  10177e:	0f b6 c0             	movzbl %al,%eax
  101781:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
  101787:	88 45 fd             	mov    %al,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10178a:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  10178e:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101792:	ee                   	out    %al,(%dx)
}
  101793:	90                   	nop
    }
}
  101794:	90                   	nop
  101795:	89 ec                	mov    %ebp,%esp
  101797:	5d                   	pop    %ebp
  101798:	c3                   	ret    

00101799 <pic_enable>:

void
pic_enable(unsigned int irq) {
  101799:	55                   	push   %ebp
  10179a:	89 e5                	mov    %esp,%ebp
  10179c:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  10179f:	8b 45 08             	mov    0x8(%ebp),%eax
  1017a2:	ba 01 00 00 00       	mov    $0x1,%edx
  1017a7:	88 c1                	mov    %al,%cl
  1017a9:	d3 e2                	shl    %cl,%edx
  1017ab:	89 d0                	mov    %edx,%eax
  1017ad:	98                   	cwtl   
  1017ae:	f7 d0                	not    %eax
  1017b0:	0f bf d0             	movswl %ax,%edx
  1017b3:	0f b7 05 50 85 11 00 	movzwl 0x118550,%eax
  1017ba:	98                   	cwtl   
  1017bb:	21 d0                	and    %edx,%eax
  1017bd:	98                   	cwtl   
  1017be:	0f b7 c0             	movzwl %ax,%eax
  1017c1:	89 04 24             	mov    %eax,(%esp)
  1017c4:	e8 73 ff ff ff       	call   10173c <pic_setmask>
}
  1017c9:	90                   	nop
  1017ca:	89 ec                	mov    %ebp,%esp
  1017cc:	5d                   	pop    %ebp
  1017cd:	c3                   	ret    

001017ce <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  1017ce:	55                   	push   %ebp
  1017cf:	89 e5                	mov    %esp,%ebp
  1017d1:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
  1017d4:	c7 05 6c b6 11 00 01 	movl   $0x1,0x11b66c
  1017db:	00 00 00 
  1017de:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
  1017e4:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1017e8:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
  1017ec:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
  1017f0:	ee                   	out    %al,(%dx)
}
  1017f1:	90                   	nop
  1017f2:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
  1017f8:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1017fc:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
  101800:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
  101804:	ee                   	out    %al,(%dx)
}
  101805:	90                   	nop
  101806:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
  10180c:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101810:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  101814:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  101818:	ee                   	out    %al,(%dx)
}
  101819:	90                   	nop
  10181a:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
  101820:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101824:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  101828:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  10182c:	ee                   	out    %al,(%dx)
}
  10182d:	90                   	nop
  10182e:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
  101834:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101838:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  10183c:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  101840:	ee                   	out    %al,(%dx)
}
  101841:	90                   	nop
  101842:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
  101848:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10184c:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  101850:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  101854:	ee                   	out    %al,(%dx)
}
  101855:	90                   	nop
  101856:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
  10185c:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101860:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  101864:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  101868:	ee                   	out    %al,(%dx)
}
  101869:	90                   	nop
  10186a:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
  101870:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101874:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  101878:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  10187c:	ee                   	out    %al,(%dx)
}
  10187d:	90                   	nop
  10187e:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
  101884:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101888:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  10188c:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101890:	ee                   	out    %al,(%dx)
}
  101891:	90                   	nop
  101892:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
  101898:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10189c:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1018a0:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1018a4:	ee                   	out    %al,(%dx)
}
  1018a5:	90                   	nop
  1018a6:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
  1018ac:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1018b0:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1018b4:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1018b8:	ee                   	out    %al,(%dx)
}
  1018b9:	90                   	nop
  1018ba:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
  1018c0:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1018c4:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1018c8:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1018cc:	ee                   	out    %al,(%dx)
}
  1018cd:	90                   	nop
  1018ce:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
  1018d4:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1018d8:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  1018dc:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  1018e0:	ee                   	out    %al,(%dx)
}
  1018e1:	90                   	nop
  1018e2:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
  1018e8:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1018ec:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  1018f0:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  1018f4:	ee                   	out    %al,(%dx)
}
  1018f5:	90                   	nop
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  1018f6:	0f b7 05 50 85 11 00 	movzwl 0x118550,%eax
  1018fd:	3d ff ff 00 00       	cmp    $0xffff,%eax
  101902:	74 0f                	je     101913 <pic_init+0x145>
        pic_setmask(irq_mask);
  101904:	0f b7 05 50 85 11 00 	movzwl 0x118550,%eax
  10190b:	89 04 24             	mov    %eax,(%esp)
  10190e:	e8 29 fe ff ff       	call   10173c <pic_setmask>
    }
}
  101913:	90                   	nop
  101914:	89 ec                	mov    %ebp,%esp
  101916:	5d                   	pop    %ebp
  101917:	c3                   	ret    

00101918 <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
  101918:	55                   	push   %ebp
  101919:	89 e5                	mov    %esp,%ebp
  10191b:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  10191e:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  101925:	00 
  101926:	c7 04 24 00 63 10 00 	movl   $0x106300,(%esp)
  10192d:	e8 24 ea ff ff       	call   100356 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
  101932:	c7 04 24 0a 63 10 00 	movl   $0x10630a,(%esp)
  101939:	e8 18 ea ff ff       	call   100356 <cprintf>
    panic("EOT: kernel seems ok.");
  10193e:	c7 44 24 08 18 63 10 	movl   $0x106318,0x8(%esp)
  101945:	00 
  101946:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  10194d:	00 
  10194e:	c7 04 24 2e 63 10 00 	movl   $0x10632e,(%esp)
  101955:	e8 81 f3 ff ff       	call   100cdb <__panic>

0010195a <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  10195a:	55                   	push   %ebp
  10195b:	89 e5                	mov    %esp,%ebp
  10195d:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
  101960:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101967:	e9 c4 00 00 00       	jmp    101a30 <idt_init+0xd6>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
  10196c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10196f:	8b 04 85 e0 85 11 00 	mov    0x1185e0(,%eax,4),%eax
  101976:	0f b7 d0             	movzwl %ax,%edx
  101979:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10197c:	66 89 14 c5 80 b6 11 	mov    %dx,0x11b680(,%eax,8)
  101983:	00 
  101984:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101987:	66 c7 04 c5 82 b6 11 	movw   $0x8,0x11b682(,%eax,8)
  10198e:	00 08 00 
  101991:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101994:	0f b6 14 c5 84 b6 11 	movzbl 0x11b684(,%eax,8),%edx
  10199b:	00 
  10199c:	80 e2 e0             	and    $0xe0,%dl
  10199f:	88 14 c5 84 b6 11 00 	mov    %dl,0x11b684(,%eax,8)
  1019a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019a9:	0f b6 14 c5 84 b6 11 	movzbl 0x11b684(,%eax,8),%edx
  1019b0:	00 
  1019b1:	80 e2 1f             	and    $0x1f,%dl
  1019b4:	88 14 c5 84 b6 11 00 	mov    %dl,0x11b684(,%eax,8)
  1019bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019be:	0f b6 14 c5 85 b6 11 	movzbl 0x11b685(,%eax,8),%edx
  1019c5:	00 
  1019c6:	80 e2 f0             	and    $0xf0,%dl
  1019c9:	80 ca 0e             	or     $0xe,%dl
  1019cc:	88 14 c5 85 b6 11 00 	mov    %dl,0x11b685(,%eax,8)
  1019d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019d6:	0f b6 14 c5 85 b6 11 	movzbl 0x11b685(,%eax,8),%edx
  1019dd:	00 
  1019de:	80 e2 ef             	and    $0xef,%dl
  1019e1:	88 14 c5 85 b6 11 00 	mov    %dl,0x11b685(,%eax,8)
  1019e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019eb:	0f b6 14 c5 85 b6 11 	movzbl 0x11b685(,%eax,8),%edx
  1019f2:	00 
  1019f3:	80 e2 9f             	and    $0x9f,%dl
  1019f6:	88 14 c5 85 b6 11 00 	mov    %dl,0x11b685(,%eax,8)
  1019fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a00:	0f b6 14 c5 85 b6 11 	movzbl 0x11b685(,%eax,8),%edx
  101a07:	00 
  101a08:	80 ca 80             	or     $0x80,%dl
  101a0b:	88 14 c5 85 b6 11 00 	mov    %dl,0x11b685(,%eax,8)
  101a12:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a15:	8b 04 85 e0 85 11 00 	mov    0x1185e0(,%eax,4),%eax
  101a1c:	c1 e8 10             	shr    $0x10,%eax
  101a1f:	0f b7 d0             	movzwl %ax,%edx
  101a22:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a25:	66 89 14 c5 86 b6 11 	mov    %dx,0x11b686(,%eax,8)
  101a2c:	00 
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
  101a2d:	ff 45 fc             	incl   -0x4(%ebp)
  101a30:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a33:	3d ff 00 00 00       	cmp    $0xff,%eax
  101a38:	0f 86 2e ff ff ff    	jbe    10196c <idt_init+0x12>
  101a3e:	c7 45 f8 60 85 11 00 	movl   $0x118560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
  101a45:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101a48:	0f 01 18             	lidtl  (%eax)
}
  101a4b:	90                   	nop
    }
    lidt(&idt_pd);
}
  101a4c:	90                   	nop
  101a4d:	89 ec                	mov    %ebp,%esp
  101a4f:	5d                   	pop    %ebp
  101a50:	c3                   	ret    

00101a51 <trapname>:

static const char *
trapname(int trapno) {
  101a51:	55                   	push   %ebp
  101a52:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  101a54:	8b 45 08             	mov    0x8(%ebp),%eax
  101a57:	83 f8 13             	cmp    $0x13,%eax
  101a5a:	77 0c                	ja     101a68 <trapname+0x17>
        return excnames[trapno];
  101a5c:	8b 45 08             	mov    0x8(%ebp),%eax
  101a5f:	8b 04 85 80 66 10 00 	mov    0x106680(,%eax,4),%eax
  101a66:	eb 18                	jmp    101a80 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  101a68:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101a6c:	7e 0d                	jle    101a7b <trapname+0x2a>
  101a6e:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101a72:	7f 07                	jg     101a7b <trapname+0x2a>
        return "Hardware Interrupt";
  101a74:	b8 3f 63 10 00       	mov    $0x10633f,%eax
  101a79:	eb 05                	jmp    101a80 <trapname+0x2f>
    }
    return "(unknown trap)";
  101a7b:	b8 52 63 10 00       	mov    $0x106352,%eax
}
  101a80:	5d                   	pop    %ebp
  101a81:	c3                   	ret    

00101a82 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  101a82:	55                   	push   %ebp
  101a83:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  101a85:	8b 45 08             	mov    0x8(%ebp),%eax
  101a88:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101a8c:	83 f8 08             	cmp    $0x8,%eax
  101a8f:	0f 94 c0             	sete   %al
  101a92:	0f b6 c0             	movzbl %al,%eax
}
  101a95:	5d                   	pop    %ebp
  101a96:	c3                   	ret    

00101a97 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  101a97:	55                   	push   %ebp
  101a98:	89 e5                	mov    %esp,%ebp
  101a9a:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  101a9d:	8b 45 08             	mov    0x8(%ebp),%eax
  101aa0:	89 44 24 04          	mov    %eax,0x4(%esp)
  101aa4:	c7 04 24 93 63 10 00 	movl   $0x106393,(%esp)
  101aab:	e8 a6 e8 ff ff       	call   100356 <cprintf>
    print_regs(&tf->tf_regs);
  101ab0:	8b 45 08             	mov    0x8(%ebp),%eax
  101ab3:	89 04 24             	mov    %eax,(%esp)
  101ab6:	e8 8f 01 00 00       	call   101c4a <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101abb:	8b 45 08             	mov    0x8(%ebp),%eax
  101abe:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101ac2:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ac6:	c7 04 24 a4 63 10 00 	movl   $0x1063a4,(%esp)
  101acd:	e8 84 e8 ff ff       	call   100356 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  101ad5:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101ad9:	89 44 24 04          	mov    %eax,0x4(%esp)
  101add:	c7 04 24 b7 63 10 00 	movl   $0x1063b7,(%esp)
  101ae4:	e8 6d e8 ff ff       	call   100356 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101ae9:	8b 45 08             	mov    0x8(%ebp),%eax
  101aec:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101af0:	89 44 24 04          	mov    %eax,0x4(%esp)
  101af4:	c7 04 24 ca 63 10 00 	movl   $0x1063ca,(%esp)
  101afb:	e8 56 e8 ff ff       	call   100356 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101b00:	8b 45 08             	mov    0x8(%ebp),%eax
  101b03:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101b07:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b0b:	c7 04 24 dd 63 10 00 	movl   $0x1063dd,(%esp)
  101b12:	e8 3f e8 ff ff       	call   100356 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101b17:	8b 45 08             	mov    0x8(%ebp),%eax
  101b1a:	8b 40 30             	mov    0x30(%eax),%eax
  101b1d:	89 04 24             	mov    %eax,(%esp)
  101b20:	e8 2c ff ff ff       	call   101a51 <trapname>
  101b25:	8b 55 08             	mov    0x8(%ebp),%edx
  101b28:	8b 52 30             	mov    0x30(%edx),%edx
  101b2b:	89 44 24 08          	mov    %eax,0x8(%esp)
  101b2f:	89 54 24 04          	mov    %edx,0x4(%esp)
  101b33:	c7 04 24 f0 63 10 00 	movl   $0x1063f0,(%esp)
  101b3a:	e8 17 e8 ff ff       	call   100356 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101b3f:	8b 45 08             	mov    0x8(%ebp),%eax
  101b42:	8b 40 34             	mov    0x34(%eax),%eax
  101b45:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b49:	c7 04 24 02 64 10 00 	movl   $0x106402,(%esp)
  101b50:	e8 01 e8 ff ff       	call   100356 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101b55:	8b 45 08             	mov    0x8(%ebp),%eax
  101b58:	8b 40 38             	mov    0x38(%eax),%eax
  101b5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b5f:	c7 04 24 11 64 10 00 	movl   $0x106411,(%esp)
  101b66:	e8 eb e7 ff ff       	call   100356 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101b6b:	8b 45 08             	mov    0x8(%ebp),%eax
  101b6e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101b72:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b76:	c7 04 24 20 64 10 00 	movl   $0x106420,(%esp)
  101b7d:	e8 d4 e7 ff ff       	call   100356 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101b82:	8b 45 08             	mov    0x8(%ebp),%eax
  101b85:	8b 40 40             	mov    0x40(%eax),%eax
  101b88:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b8c:	c7 04 24 33 64 10 00 	movl   $0x106433,(%esp)
  101b93:	e8 be e7 ff ff       	call   100356 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101b98:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101b9f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101ba6:	eb 3d                	jmp    101be5 <print_trapframe+0x14e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101ba8:	8b 45 08             	mov    0x8(%ebp),%eax
  101bab:	8b 50 40             	mov    0x40(%eax),%edx
  101bae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101bb1:	21 d0                	and    %edx,%eax
  101bb3:	85 c0                	test   %eax,%eax
  101bb5:	74 28                	je     101bdf <print_trapframe+0x148>
  101bb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101bba:	8b 04 85 80 85 11 00 	mov    0x118580(,%eax,4),%eax
  101bc1:	85 c0                	test   %eax,%eax
  101bc3:	74 1a                	je     101bdf <print_trapframe+0x148>
            cprintf("%s,", IA32flags[i]);
  101bc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101bc8:	8b 04 85 80 85 11 00 	mov    0x118580(,%eax,4),%eax
  101bcf:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bd3:	c7 04 24 42 64 10 00 	movl   $0x106442,(%esp)
  101bda:	e8 77 e7 ff ff       	call   100356 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101bdf:	ff 45 f4             	incl   -0xc(%ebp)
  101be2:	d1 65 f0             	shll   -0x10(%ebp)
  101be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101be8:	83 f8 17             	cmp    $0x17,%eax
  101beb:	76 bb                	jbe    101ba8 <print_trapframe+0x111>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101bed:	8b 45 08             	mov    0x8(%ebp),%eax
  101bf0:	8b 40 40             	mov    0x40(%eax),%eax
  101bf3:	c1 e8 0c             	shr    $0xc,%eax
  101bf6:	83 e0 03             	and    $0x3,%eax
  101bf9:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bfd:	c7 04 24 46 64 10 00 	movl   $0x106446,(%esp)
  101c04:	e8 4d e7 ff ff       	call   100356 <cprintf>

    if (!trap_in_kernel(tf)) {
  101c09:	8b 45 08             	mov    0x8(%ebp),%eax
  101c0c:	89 04 24             	mov    %eax,(%esp)
  101c0f:	e8 6e fe ff ff       	call   101a82 <trap_in_kernel>
  101c14:	85 c0                	test   %eax,%eax
  101c16:	75 2d                	jne    101c45 <print_trapframe+0x1ae>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101c18:	8b 45 08             	mov    0x8(%ebp),%eax
  101c1b:	8b 40 44             	mov    0x44(%eax),%eax
  101c1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c22:	c7 04 24 4f 64 10 00 	movl   $0x10644f,(%esp)
  101c29:	e8 28 e7 ff ff       	call   100356 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101c2e:	8b 45 08             	mov    0x8(%ebp),%eax
  101c31:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101c35:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c39:	c7 04 24 5e 64 10 00 	movl   $0x10645e,(%esp)
  101c40:	e8 11 e7 ff ff       	call   100356 <cprintf>
    }
}
  101c45:	90                   	nop
  101c46:	89 ec                	mov    %ebp,%esp
  101c48:	5d                   	pop    %ebp
  101c49:	c3                   	ret    

00101c4a <print_regs>:

void
print_regs(struct pushregs *regs) {
  101c4a:	55                   	push   %ebp
  101c4b:	89 e5                	mov    %esp,%ebp
  101c4d:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101c50:	8b 45 08             	mov    0x8(%ebp),%eax
  101c53:	8b 00                	mov    (%eax),%eax
  101c55:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c59:	c7 04 24 71 64 10 00 	movl   $0x106471,(%esp)
  101c60:	e8 f1 e6 ff ff       	call   100356 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101c65:	8b 45 08             	mov    0x8(%ebp),%eax
  101c68:	8b 40 04             	mov    0x4(%eax),%eax
  101c6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c6f:	c7 04 24 80 64 10 00 	movl   $0x106480,(%esp)
  101c76:	e8 db e6 ff ff       	call   100356 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101c7b:	8b 45 08             	mov    0x8(%ebp),%eax
  101c7e:	8b 40 08             	mov    0x8(%eax),%eax
  101c81:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c85:	c7 04 24 8f 64 10 00 	movl   $0x10648f,(%esp)
  101c8c:	e8 c5 e6 ff ff       	call   100356 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101c91:	8b 45 08             	mov    0x8(%ebp),%eax
  101c94:	8b 40 0c             	mov    0xc(%eax),%eax
  101c97:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c9b:	c7 04 24 9e 64 10 00 	movl   $0x10649e,(%esp)
  101ca2:	e8 af e6 ff ff       	call   100356 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101ca7:	8b 45 08             	mov    0x8(%ebp),%eax
  101caa:	8b 40 10             	mov    0x10(%eax),%eax
  101cad:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cb1:	c7 04 24 ad 64 10 00 	movl   $0x1064ad,(%esp)
  101cb8:	e8 99 e6 ff ff       	call   100356 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101cbd:	8b 45 08             	mov    0x8(%ebp),%eax
  101cc0:	8b 40 14             	mov    0x14(%eax),%eax
  101cc3:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cc7:	c7 04 24 bc 64 10 00 	movl   $0x1064bc,(%esp)
  101cce:	e8 83 e6 ff ff       	call   100356 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101cd3:	8b 45 08             	mov    0x8(%ebp),%eax
  101cd6:	8b 40 18             	mov    0x18(%eax),%eax
  101cd9:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cdd:	c7 04 24 cb 64 10 00 	movl   $0x1064cb,(%esp)
  101ce4:	e8 6d e6 ff ff       	call   100356 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101ce9:	8b 45 08             	mov    0x8(%ebp),%eax
  101cec:	8b 40 1c             	mov    0x1c(%eax),%eax
  101cef:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cf3:	c7 04 24 da 64 10 00 	movl   $0x1064da,(%esp)
  101cfa:	e8 57 e6 ff ff       	call   100356 <cprintf>
}
  101cff:	90                   	nop
  101d00:	89 ec                	mov    %ebp,%esp
  101d02:	5d                   	pop    %ebp
  101d03:	c3                   	ret    

00101d04 <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101d04:	55                   	push   %ebp
  101d05:	89 e5                	mov    %esp,%ebp
  101d07:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
  101d0a:	8b 45 08             	mov    0x8(%ebp),%eax
  101d0d:	8b 40 30             	mov    0x30(%eax),%eax
  101d10:	83 f8 79             	cmp    $0x79,%eax
  101d13:	0f 87 e6 00 00 00    	ja     101dff <trap_dispatch+0xfb>
  101d19:	83 f8 78             	cmp    $0x78,%eax
  101d1c:	0f 83 c1 00 00 00    	jae    101de3 <trap_dispatch+0xdf>
  101d22:	83 f8 2f             	cmp    $0x2f,%eax
  101d25:	0f 87 d4 00 00 00    	ja     101dff <trap_dispatch+0xfb>
  101d2b:	83 f8 2e             	cmp    $0x2e,%eax
  101d2e:	0f 83 00 01 00 00    	jae    101e34 <trap_dispatch+0x130>
  101d34:	83 f8 24             	cmp    $0x24,%eax
  101d37:	74 5e                	je     101d97 <trap_dispatch+0x93>
  101d39:	83 f8 24             	cmp    $0x24,%eax
  101d3c:	0f 87 bd 00 00 00    	ja     101dff <trap_dispatch+0xfb>
  101d42:	83 f8 20             	cmp    $0x20,%eax
  101d45:	74 0a                	je     101d51 <trap_dispatch+0x4d>
  101d47:	83 f8 21             	cmp    $0x21,%eax
  101d4a:	74 71                	je     101dbd <trap_dispatch+0xb9>
  101d4c:	e9 ae 00 00 00       	jmp    101dff <trap_dispatch+0xfb>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
  101d51:	a1 24 b4 11 00       	mov    0x11b424,%eax
  101d56:	40                   	inc    %eax
  101d57:	a3 24 b4 11 00       	mov    %eax,0x11b424
        if (ticks % TICK_NUM == 0) {
  101d5c:	8b 0d 24 b4 11 00    	mov    0x11b424,%ecx
  101d62:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101d67:	89 c8                	mov    %ecx,%eax
  101d69:	f7 e2                	mul    %edx
  101d6b:	c1 ea 05             	shr    $0x5,%edx
  101d6e:	89 d0                	mov    %edx,%eax
  101d70:	c1 e0 02             	shl    $0x2,%eax
  101d73:	01 d0                	add    %edx,%eax
  101d75:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  101d7c:	01 d0                	add    %edx,%eax
  101d7e:	c1 e0 02             	shl    $0x2,%eax
  101d81:	29 c1                	sub    %eax,%ecx
  101d83:	89 ca                	mov    %ecx,%edx
  101d85:	85 d2                	test   %edx,%edx
  101d87:	0f 85 aa 00 00 00    	jne    101e37 <trap_dispatch+0x133>
            print_ticks();
  101d8d:	e8 86 fb ff ff       	call   101918 <print_ticks>
        }
        break;
  101d92:	e9 a0 00 00 00       	jmp    101e37 <trap_dispatch+0x133>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101d97:	e8 1f f9 ff ff       	call   1016bb <cons_getc>
  101d9c:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101d9f:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101da3:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101da7:	89 54 24 08          	mov    %edx,0x8(%esp)
  101dab:	89 44 24 04          	mov    %eax,0x4(%esp)
  101daf:	c7 04 24 e9 64 10 00 	movl   $0x1064e9,(%esp)
  101db6:	e8 9b e5 ff ff       	call   100356 <cprintf>
        break;
  101dbb:	eb 7b                	jmp    101e38 <trap_dispatch+0x134>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101dbd:	e8 f9 f8 ff ff       	call   1016bb <cons_getc>
  101dc2:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101dc5:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101dc9:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101dcd:	89 54 24 08          	mov    %edx,0x8(%esp)
  101dd1:	89 44 24 04          	mov    %eax,0x4(%esp)
  101dd5:	c7 04 24 fb 64 10 00 	movl   $0x1064fb,(%esp)
  101ddc:	e8 75 e5 ff ff       	call   100356 <cprintf>
        break;
  101de1:	eb 55                	jmp    101e38 <trap_dispatch+0x134>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
  101de3:	c7 44 24 08 0a 65 10 	movl   $0x10650a,0x8(%esp)
  101dea:	00 
  101deb:	c7 44 24 04 ac 00 00 	movl   $0xac,0x4(%esp)
  101df2:	00 
  101df3:	c7 04 24 2e 63 10 00 	movl   $0x10632e,(%esp)
  101dfa:	e8 dc ee ff ff       	call   100cdb <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101dff:	8b 45 08             	mov    0x8(%ebp),%eax
  101e02:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101e06:	83 e0 03             	and    $0x3,%eax
  101e09:	85 c0                	test   %eax,%eax
  101e0b:	75 2b                	jne    101e38 <trap_dispatch+0x134>
            print_trapframe(tf);
  101e0d:	8b 45 08             	mov    0x8(%ebp),%eax
  101e10:	89 04 24             	mov    %eax,(%esp)
  101e13:	e8 7f fc ff ff       	call   101a97 <print_trapframe>
            panic("unexpected trap in kernel.\n");
  101e18:	c7 44 24 08 1a 65 10 	movl   $0x10651a,0x8(%esp)
  101e1f:	00 
  101e20:	c7 44 24 04 b6 00 00 	movl   $0xb6,0x4(%esp)
  101e27:	00 
  101e28:	c7 04 24 2e 63 10 00 	movl   $0x10632e,(%esp)
  101e2f:	e8 a7 ee ff ff       	call   100cdb <__panic>
        break;
  101e34:	90                   	nop
  101e35:	eb 01                	jmp    101e38 <trap_dispatch+0x134>
        break;
  101e37:	90                   	nop
        }
    }
}
  101e38:	90                   	nop
  101e39:	89 ec                	mov    %ebp,%esp
  101e3b:	5d                   	pop    %ebp
  101e3c:	c3                   	ret    

00101e3d <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101e3d:	55                   	push   %ebp
  101e3e:	89 e5                	mov    %esp,%ebp
  101e40:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101e43:	8b 45 08             	mov    0x8(%ebp),%eax
  101e46:	89 04 24             	mov    %eax,(%esp)
  101e49:	e8 b6 fe ff ff       	call   101d04 <trap_dispatch>
}
  101e4e:	90                   	nop
  101e4f:	89 ec                	mov    %ebp,%esp
  101e51:	5d                   	pop    %ebp
  101e52:	c3                   	ret    

00101e53 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  101e53:	1e                   	push   %ds
    pushl %es
  101e54:	06                   	push   %es
    pushl %fs
  101e55:	0f a0                	push   %fs
    pushl %gs
  101e57:	0f a8                	push   %gs
    pushal
  101e59:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  101e5a:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  101e5f:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  101e61:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  101e63:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  101e64:	e8 d4 ff ff ff       	call   101e3d <trap>

    # pop the pushed stack pointer
    popl %esp
  101e69:	5c                   	pop    %esp

00101e6a <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  101e6a:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  101e6b:	0f a9                	pop    %gs
    popl %fs
  101e6d:	0f a1                	pop    %fs
    popl %es
  101e6f:	07                   	pop    %es
    popl %ds
  101e70:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  101e71:	83 c4 08             	add    $0x8,%esp
    iret
  101e74:	cf                   	iret   

00101e75 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101e75:	6a 00                	push   $0x0
  pushl $0
  101e77:	6a 00                	push   $0x0
  jmp __alltraps
  101e79:	e9 d5 ff ff ff       	jmp    101e53 <__alltraps>

00101e7e <vector1>:
.globl vector1
vector1:
  pushl $0
  101e7e:	6a 00                	push   $0x0
  pushl $1
  101e80:	6a 01                	push   $0x1
  jmp __alltraps
  101e82:	e9 cc ff ff ff       	jmp    101e53 <__alltraps>

00101e87 <vector2>:
.globl vector2
vector2:
  pushl $0
  101e87:	6a 00                	push   $0x0
  pushl $2
  101e89:	6a 02                	push   $0x2
  jmp __alltraps
  101e8b:	e9 c3 ff ff ff       	jmp    101e53 <__alltraps>

00101e90 <vector3>:
.globl vector3
vector3:
  pushl $0
  101e90:	6a 00                	push   $0x0
  pushl $3
  101e92:	6a 03                	push   $0x3
  jmp __alltraps
  101e94:	e9 ba ff ff ff       	jmp    101e53 <__alltraps>

00101e99 <vector4>:
.globl vector4
vector4:
  pushl $0
  101e99:	6a 00                	push   $0x0
  pushl $4
  101e9b:	6a 04                	push   $0x4
  jmp __alltraps
  101e9d:	e9 b1 ff ff ff       	jmp    101e53 <__alltraps>

00101ea2 <vector5>:
.globl vector5
vector5:
  pushl $0
  101ea2:	6a 00                	push   $0x0
  pushl $5
  101ea4:	6a 05                	push   $0x5
  jmp __alltraps
  101ea6:	e9 a8 ff ff ff       	jmp    101e53 <__alltraps>

00101eab <vector6>:
.globl vector6
vector6:
  pushl $0
  101eab:	6a 00                	push   $0x0
  pushl $6
  101ead:	6a 06                	push   $0x6
  jmp __alltraps
  101eaf:	e9 9f ff ff ff       	jmp    101e53 <__alltraps>

00101eb4 <vector7>:
.globl vector7
vector7:
  pushl $0
  101eb4:	6a 00                	push   $0x0
  pushl $7
  101eb6:	6a 07                	push   $0x7
  jmp __alltraps
  101eb8:	e9 96 ff ff ff       	jmp    101e53 <__alltraps>

00101ebd <vector8>:
.globl vector8
vector8:
  pushl $8
  101ebd:	6a 08                	push   $0x8
  jmp __alltraps
  101ebf:	e9 8f ff ff ff       	jmp    101e53 <__alltraps>

00101ec4 <vector9>:
.globl vector9
vector9:
  pushl $0
  101ec4:	6a 00                	push   $0x0
  pushl $9
  101ec6:	6a 09                	push   $0x9
  jmp __alltraps
  101ec8:	e9 86 ff ff ff       	jmp    101e53 <__alltraps>

00101ecd <vector10>:
.globl vector10
vector10:
  pushl $10
  101ecd:	6a 0a                	push   $0xa
  jmp __alltraps
  101ecf:	e9 7f ff ff ff       	jmp    101e53 <__alltraps>

00101ed4 <vector11>:
.globl vector11
vector11:
  pushl $11
  101ed4:	6a 0b                	push   $0xb
  jmp __alltraps
  101ed6:	e9 78 ff ff ff       	jmp    101e53 <__alltraps>

00101edb <vector12>:
.globl vector12
vector12:
  pushl $12
  101edb:	6a 0c                	push   $0xc
  jmp __alltraps
  101edd:	e9 71 ff ff ff       	jmp    101e53 <__alltraps>

00101ee2 <vector13>:
.globl vector13
vector13:
  pushl $13
  101ee2:	6a 0d                	push   $0xd
  jmp __alltraps
  101ee4:	e9 6a ff ff ff       	jmp    101e53 <__alltraps>

00101ee9 <vector14>:
.globl vector14
vector14:
  pushl $14
  101ee9:	6a 0e                	push   $0xe
  jmp __alltraps
  101eeb:	e9 63 ff ff ff       	jmp    101e53 <__alltraps>

00101ef0 <vector15>:
.globl vector15
vector15:
  pushl $0
  101ef0:	6a 00                	push   $0x0
  pushl $15
  101ef2:	6a 0f                	push   $0xf
  jmp __alltraps
  101ef4:	e9 5a ff ff ff       	jmp    101e53 <__alltraps>

00101ef9 <vector16>:
.globl vector16
vector16:
  pushl $0
  101ef9:	6a 00                	push   $0x0
  pushl $16
  101efb:	6a 10                	push   $0x10
  jmp __alltraps
  101efd:	e9 51 ff ff ff       	jmp    101e53 <__alltraps>

00101f02 <vector17>:
.globl vector17
vector17:
  pushl $17
  101f02:	6a 11                	push   $0x11
  jmp __alltraps
  101f04:	e9 4a ff ff ff       	jmp    101e53 <__alltraps>

00101f09 <vector18>:
.globl vector18
vector18:
  pushl $0
  101f09:	6a 00                	push   $0x0
  pushl $18
  101f0b:	6a 12                	push   $0x12
  jmp __alltraps
  101f0d:	e9 41 ff ff ff       	jmp    101e53 <__alltraps>

00101f12 <vector19>:
.globl vector19
vector19:
  pushl $0
  101f12:	6a 00                	push   $0x0
  pushl $19
  101f14:	6a 13                	push   $0x13
  jmp __alltraps
  101f16:	e9 38 ff ff ff       	jmp    101e53 <__alltraps>

00101f1b <vector20>:
.globl vector20
vector20:
  pushl $0
  101f1b:	6a 00                	push   $0x0
  pushl $20
  101f1d:	6a 14                	push   $0x14
  jmp __alltraps
  101f1f:	e9 2f ff ff ff       	jmp    101e53 <__alltraps>

00101f24 <vector21>:
.globl vector21
vector21:
  pushl $0
  101f24:	6a 00                	push   $0x0
  pushl $21
  101f26:	6a 15                	push   $0x15
  jmp __alltraps
  101f28:	e9 26 ff ff ff       	jmp    101e53 <__alltraps>

00101f2d <vector22>:
.globl vector22
vector22:
  pushl $0
  101f2d:	6a 00                	push   $0x0
  pushl $22
  101f2f:	6a 16                	push   $0x16
  jmp __alltraps
  101f31:	e9 1d ff ff ff       	jmp    101e53 <__alltraps>

00101f36 <vector23>:
.globl vector23
vector23:
  pushl $0
  101f36:	6a 00                	push   $0x0
  pushl $23
  101f38:	6a 17                	push   $0x17
  jmp __alltraps
  101f3a:	e9 14 ff ff ff       	jmp    101e53 <__alltraps>

00101f3f <vector24>:
.globl vector24
vector24:
  pushl $0
  101f3f:	6a 00                	push   $0x0
  pushl $24
  101f41:	6a 18                	push   $0x18
  jmp __alltraps
  101f43:	e9 0b ff ff ff       	jmp    101e53 <__alltraps>

00101f48 <vector25>:
.globl vector25
vector25:
  pushl $0
  101f48:	6a 00                	push   $0x0
  pushl $25
  101f4a:	6a 19                	push   $0x19
  jmp __alltraps
  101f4c:	e9 02 ff ff ff       	jmp    101e53 <__alltraps>

00101f51 <vector26>:
.globl vector26
vector26:
  pushl $0
  101f51:	6a 00                	push   $0x0
  pushl $26
  101f53:	6a 1a                	push   $0x1a
  jmp __alltraps
  101f55:	e9 f9 fe ff ff       	jmp    101e53 <__alltraps>

00101f5a <vector27>:
.globl vector27
vector27:
  pushl $0
  101f5a:	6a 00                	push   $0x0
  pushl $27
  101f5c:	6a 1b                	push   $0x1b
  jmp __alltraps
  101f5e:	e9 f0 fe ff ff       	jmp    101e53 <__alltraps>

00101f63 <vector28>:
.globl vector28
vector28:
  pushl $0
  101f63:	6a 00                	push   $0x0
  pushl $28
  101f65:	6a 1c                	push   $0x1c
  jmp __alltraps
  101f67:	e9 e7 fe ff ff       	jmp    101e53 <__alltraps>

00101f6c <vector29>:
.globl vector29
vector29:
  pushl $0
  101f6c:	6a 00                	push   $0x0
  pushl $29
  101f6e:	6a 1d                	push   $0x1d
  jmp __alltraps
  101f70:	e9 de fe ff ff       	jmp    101e53 <__alltraps>

00101f75 <vector30>:
.globl vector30
vector30:
  pushl $0
  101f75:	6a 00                	push   $0x0
  pushl $30
  101f77:	6a 1e                	push   $0x1e
  jmp __alltraps
  101f79:	e9 d5 fe ff ff       	jmp    101e53 <__alltraps>

00101f7e <vector31>:
.globl vector31
vector31:
  pushl $0
  101f7e:	6a 00                	push   $0x0
  pushl $31
  101f80:	6a 1f                	push   $0x1f
  jmp __alltraps
  101f82:	e9 cc fe ff ff       	jmp    101e53 <__alltraps>

00101f87 <vector32>:
.globl vector32
vector32:
  pushl $0
  101f87:	6a 00                	push   $0x0
  pushl $32
  101f89:	6a 20                	push   $0x20
  jmp __alltraps
  101f8b:	e9 c3 fe ff ff       	jmp    101e53 <__alltraps>

00101f90 <vector33>:
.globl vector33
vector33:
  pushl $0
  101f90:	6a 00                	push   $0x0
  pushl $33
  101f92:	6a 21                	push   $0x21
  jmp __alltraps
  101f94:	e9 ba fe ff ff       	jmp    101e53 <__alltraps>

00101f99 <vector34>:
.globl vector34
vector34:
  pushl $0
  101f99:	6a 00                	push   $0x0
  pushl $34
  101f9b:	6a 22                	push   $0x22
  jmp __alltraps
  101f9d:	e9 b1 fe ff ff       	jmp    101e53 <__alltraps>

00101fa2 <vector35>:
.globl vector35
vector35:
  pushl $0
  101fa2:	6a 00                	push   $0x0
  pushl $35
  101fa4:	6a 23                	push   $0x23
  jmp __alltraps
  101fa6:	e9 a8 fe ff ff       	jmp    101e53 <__alltraps>

00101fab <vector36>:
.globl vector36
vector36:
  pushl $0
  101fab:	6a 00                	push   $0x0
  pushl $36
  101fad:	6a 24                	push   $0x24
  jmp __alltraps
  101faf:	e9 9f fe ff ff       	jmp    101e53 <__alltraps>

00101fb4 <vector37>:
.globl vector37
vector37:
  pushl $0
  101fb4:	6a 00                	push   $0x0
  pushl $37
  101fb6:	6a 25                	push   $0x25
  jmp __alltraps
  101fb8:	e9 96 fe ff ff       	jmp    101e53 <__alltraps>

00101fbd <vector38>:
.globl vector38
vector38:
  pushl $0
  101fbd:	6a 00                	push   $0x0
  pushl $38
  101fbf:	6a 26                	push   $0x26
  jmp __alltraps
  101fc1:	e9 8d fe ff ff       	jmp    101e53 <__alltraps>

00101fc6 <vector39>:
.globl vector39
vector39:
  pushl $0
  101fc6:	6a 00                	push   $0x0
  pushl $39
  101fc8:	6a 27                	push   $0x27
  jmp __alltraps
  101fca:	e9 84 fe ff ff       	jmp    101e53 <__alltraps>

00101fcf <vector40>:
.globl vector40
vector40:
  pushl $0
  101fcf:	6a 00                	push   $0x0
  pushl $40
  101fd1:	6a 28                	push   $0x28
  jmp __alltraps
  101fd3:	e9 7b fe ff ff       	jmp    101e53 <__alltraps>

00101fd8 <vector41>:
.globl vector41
vector41:
  pushl $0
  101fd8:	6a 00                	push   $0x0
  pushl $41
  101fda:	6a 29                	push   $0x29
  jmp __alltraps
  101fdc:	e9 72 fe ff ff       	jmp    101e53 <__alltraps>

00101fe1 <vector42>:
.globl vector42
vector42:
  pushl $0
  101fe1:	6a 00                	push   $0x0
  pushl $42
  101fe3:	6a 2a                	push   $0x2a
  jmp __alltraps
  101fe5:	e9 69 fe ff ff       	jmp    101e53 <__alltraps>

00101fea <vector43>:
.globl vector43
vector43:
  pushl $0
  101fea:	6a 00                	push   $0x0
  pushl $43
  101fec:	6a 2b                	push   $0x2b
  jmp __alltraps
  101fee:	e9 60 fe ff ff       	jmp    101e53 <__alltraps>

00101ff3 <vector44>:
.globl vector44
vector44:
  pushl $0
  101ff3:	6a 00                	push   $0x0
  pushl $44
  101ff5:	6a 2c                	push   $0x2c
  jmp __alltraps
  101ff7:	e9 57 fe ff ff       	jmp    101e53 <__alltraps>

00101ffc <vector45>:
.globl vector45
vector45:
  pushl $0
  101ffc:	6a 00                	push   $0x0
  pushl $45
  101ffe:	6a 2d                	push   $0x2d
  jmp __alltraps
  102000:	e9 4e fe ff ff       	jmp    101e53 <__alltraps>

00102005 <vector46>:
.globl vector46
vector46:
  pushl $0
  102005:	6a 00                	push   $0x0
  pushl $46
  102007:	6a 2e                	push   $0x2e
  jmp __alltraps
  102009:	e9 45 fe ff ff       	jmp    101e53 <__alltraps>

0010200e <vector47>:
.globl vector47
vector47:
  pushl $0
  10200e:	6a 00                	push   $0x0
  pushl $47
  102010:	6a 2f                	push   $0x2f
  jmp __alltraps
  102012:	e9 3c fe ff ff       	jmp    101e53 <__alltraps>

00102017 <vector48>:
.globl vector48
vector48:
  pushl $0
  102017:	6a 00                	push   $0x0
  pushl $48
  102019:	6a 30                	push   $0x30
  jmp __alltraps
  10201b:	e9 33 fe ff ff       	jmp    101e53 <__alltraps>

00102020 <vector49>:
.globl vector49
vector49:
  pushl $0
  102020:	6a 00                	push   $0x0
  pushl $49
  102022:	6a 31                	push   $0x31
  jmp __alltraps
  102024:	e9 2a fe ff ff       	jmp    101e53 <__alltraps>

00102029 <vector50>:
.globl vector50
vector50:
  pushl $0
  102029:	6a 00                	push   $0x0
  pushl $50
  10202b:	6a 32                	push   $0x32
  jmp __alltraps
  10202d:	e9 21 fe ff ff       	jmp    101e53 <__alltraps>

00102032 <vector51>:
.globl vector51
vector51:
  pushl $0
  102032:	6a 00                	push   $0x0
  pushl $51
  102034:	6a 33                	push   $0x33
  jmp __alltraps
  102036:	e9 18 fe ff ff       	jmp    101e53 <__alltraps>

0010203b <vector52>:
.globl vector52
vector52:
  pushl $0
  10203b:	6a 00                	push   $0x0
  pushl $52
  10203d:	6a 34                	push   $0x34
  jmp __alltraps
  10203f:	e9 0f fe ff ff       	jmp    101e53 <__alltraps>

00102044 <vector53>:
.globl vector53
vector53:
  pushl $0
  102044:	6a 00                	push   $0x0
  pushl $53
  102046:	6a 35                	push   $0x35
  jmp __alltraps
  102048:	e9 06 fe ff ff       	jmp    101e53 <__alltraps>

0010204d <vector54>:
.globl vector54
vector54:
  pushl $0
  10204d:	6a 00                	push   $0x0
  pushl $54
  10204f:	6a 36                	push   $0x36
  jmp __alltraps
  102051:	e9 fd fd ff ff       	jmp    101e53 <__alltraps>

00102056 <vector55>:
.globl vector55
vector55:
  pushl $0
  102056:	6a 00                	push   $0x0
  pushl $55
  102058:	6a 37                	push   $0x37
  jmp __alltraps
  10205a:	e9 f4 fd ff ff       	jmp    101e53 <__alltraps>

0010205f <vector56>:
.globl vector56
vector56:
  pushl $0
  10205f:	6a 00                	push   $0x0
  pushl $56
  102061:	6a 38                	push   $0x38
  jmp __alltraps
  102063:	e9 eb fd ff ff       	jmp    101e53 <__alltraps>

00102068 <vector57>:
.globl vector57
vector57:
  pushl $0
  102068:	6a 00                	push   $0x0
  pushl $57
  10206a:	6a 39                	push   $0x39
  jmp __alltraps
  10206c:	e9 e2 fd ff ff       	jmp    101e53 <__alltraps>

00102071 <vector58>:
.globl vector58
vector58:
  pushl $0
  102071:	6a 00                	push   $0x0
  pushl $58
  102073:	6a 3a                	push   $0x3a
  jmp __alltraps
  102075:	e9 d9 fd ff ff       	jmp    101e53 <__alltraps>

0010207a <vector59>:
.globl vector59
vector59:
  pushl $0
  10207a:	6a 00                	push   $0x0
  pushl $59
  10207c:	6a 3b                	push   $0x3b
  jmp __alltraps
  10207e:	e9 d0 fd ff ff       	jmp    101e53 <__alltraps>

00102083 <vector60>:
.globl vector60
vector60:
  pushl $0
  102083:	6a 00                	push   $0x0
  pushl $60
  102085:	6a 3c                	push   $0x3c
  jmp __alltraps
  102087:	e9 c7 fd ff ff       	jmp    101e53 <__alltraps>

0010208c <vector61>:
.globl vector61
vector61:
  pushl $0
  10208c:	6a 00                	push   $0x0
  pushl $61
  10208e:	6a 3d                	push   $0x3d
  jmp __alltraps
  102090:	e9 be fd ff ff       	jmp    101e53 <__alltraps>

00102095 <vector62>:
.globl vector62
vector62:
  pushl $0
  102095:	6a 00                	push   $0x0
  pushl $62
  102097:	6a 3e                	push   $0x3e
  jmp __alltraps
  102099:	e9 b5 fd ff ff       	jmp    101e53 <__alltraps>

0010209e <vector63>:
.globl vector63
vector63:
  pushl $0
  10209e:	6a 00                	push   $0x0
  pushl $63
  1020a0:	6a 3f                	push   $0x3f
  jmp __alltraps
  1020a2:	e9 ac fd ff ff       	jmp    101e53 <__alltraps>

001020a7 <vector64>:
.globl vector64
vector64:
  pushl $0
  1020a7:	6a 00                	push   $0x0
  pushl $64
  1020a9:	6a 40                	push   $0x40
  jmp __alltraps
  1020ab:	e9 a3 fd ff ff       	jmp    101e53 <__alltraps>

001020b0 <vector65>:
.globl vector65
vector65:
  pushl $0
  1020b0:	6a 00                	push   $0x0
  pushl $65
  1020b2:	6a 41                	push   $0x41
  jmp __alltraps
  1020b4:	e9 9a fd ff ff       	jmp    101e53 <__alltraps>

001020b9 <vector66>:
.globl vector66
vector66:
  pushl $0
  1020b9:	6a 00                	push   $0x0
  pushl $66
  1020bb:	6a 42                	push   $0x42
  jmp __alltraps
  1020bd:	e9 91 fd ff ff       	jmp    101e53 <__alltraps>

001020c2 <vector67>:
.globl vector67
vector67:
  pushl $0
  1020c2:	6a 00                	push   $0x0
  pushl $67
  1020c4:	6a 43                	push   $0x43
  jmp __alltraps
  1020c6:	e9 88 fd ff ff       	jmp    101e53 <__alltraps>

001020cb <vector68>:
.globl vector68
vector68:
  pushl $0
  1020cb:	6a 00                	push   $0x0
  pushl $68
  1020cd:	6a 44                	push   $0x44
  jmp __alltraps
  1020cf:	e9 7f fd ff ff       	jmp    101e53 <__alltraps>

001020d4 <vector69>:
.globl vector69
vector69:
  pushl $0
  1020d4:	6a 00                	push   $0x0
  pushl $69
  1020d6:	6a 45                	push   $0x45
  jmp __alltraps
  1020d8:	e9 76 fd ff ff       	jmp    101e53 <__alltraps>

001020dd <vector70>:
.globl vector70
vector70:
  pushl $0
  1020dd:	6a 00                	push   $0x0
  pushl $70
  1020df:	6a 46                	push   $0x46
  jmp __alltraps
  1020e1:	e9 6d fd ff ff       	jmp    101e53 <__alltraps>

001020e6 <vector71>:
.globl vector71
vector71:
  pushl $0
  1020e6:	6a 00                	push   $0x0
  pushl $71
  1020e8:	6a 47                	push   $0x47
  jmp __alltraps
  1020ea:	e9 64 fd ff ff       	jmp    101e53 <__alltraps>

001020ef <vector72>:
.globl vector72
vector72:
  pushl $0
  1020ef:	6a 00                	push   $0x0
  pushl $72
  1020f1:	6a 48                	push   $0x48
  jmp __alltraps
  1020f3:	e9 5b fd ff ff       	jmp    101e53 <__alltraps>

001020f8 <vector73>:
.globl vector73
vector73:
  pushl $0
  1020f8:	6a 00                	push   $0x0
  pushl $73
  1020fa:	6a 49                	push   $0x49
  jmp __alltraps
  1020fc:	e9 52 fd ff ff       	jmp    101e53 <__alltraps>

00102101 <vector74>:
.globl vector74
vector74:
  pushl $0
  102101:	6a 00                	push   $0x0
  pushl $74
  102103:	6a 4a                	push   $0x4a
  jmp __alltraps
  102105:	e9 49 fd ff ff       	jmp    101e53 <__alltraps>

0010210a <vector75>:
.globl vector75
vector75:
  pushl $0
  10210a:	6a 00                	push   $0x0
  pushl $75
  10210c:	6a 4b                	push   $0x4b
  jmp __alltraps
  10210e:	e9 40 fd ff ff       	jmp    101e53 <__alltraps>

00102113 <vector76>:
.globl vector76
vector76:
  pushl $0
  102113:	6a 00                	push   $0x0
  pushl $76
  102115:	6a 4c                	push   $0x4c
  jmp __alltraps
  102117:	e9 37 fd ff ff       	jmp    101e53 <__alltraps>

0010211c <vector77>:
.globl vector77
vector77:
  pushl $0
  10211c:	6a 00                	push   $0x0
  pushl $77
  10211e:	6a 4d                	push   $0x4d
  jmp __alltraps
  102120:	e9 2e fd ff ff       	jmp    101e53 <__alltraps>

00102125 <vector78>:
.globl vector78
vector78:
  pushl $0
  102125:	6a 00                	push   $0x0
  pushl $78
  102127:	6a 4e                	push   $0x4e
  jmp __alltraps
  102129:	e9 25 fd ff ff       	jmp    101e53 <__alltraps>

0010212e <vector79>:
.globl vector79
vector79:
  pushl $0
  10212e:	6a 00                	push   $0x0
  pushl $79
  102130:	6a 4f                	push   $0x4f
  jmp __alltraps
  102132:	e9 1c fd ff ff       	jmp    101e53 <__alltraps>

00102137 <vector80>:
.globl vector80
vector80:
  pushl $0
  102137:	6a 00                	push   $0x0
  pushl $80
  102139:	6a 50                	push   $0x50
  jmp __alltraps
  10213b:	e9 13 fd ff ff       	jmp    101e53 <__alltraps>

00102140 <vector81>:
.globl vector81
vector81:
  pushl $0
  102140:	6a 00                	push   $0x0
  pushl $81
  102142:	6a 51                	push   $0x51
  jmp __alltraps
  102144:	e9 0a fd ff ff       	jmp    101e53 <__alltraps>

00102149 <vector82>:
.globl vector82
vector82:
  pushl $0
  102149:	6a 00                	push   $0x0
  pushl $82
  10214b:	6a 52                	push   $0x52
  jmp __alltraps
  10214d:	e9 01 fd ff ff       	jmp    101e53 <__alltraps>

00102152 <vector83>:
.globl vector83
vector83:
  pushl $0
  102152:	6a 00                	push   $0x0
  pushl $83
  102154:	6a 53                	push   $0x53
  jmp __alltraps
  102156:	e9 f8 fc ff ff       	jmp    101e53 <__alltraps>

0010215b <vector84>:
.globl vector84
vector84:
  pushl $0
  10215b:	6a 00                	push   $0x0
  pushl $84
  10215d:	6a 54                	push   $0x54
  jmp __alltraps
  10215f:	e9 ef fc ff ff       	jmp    101e53 <__alltraps>

00102164 <vector85>:
.globl vector85
vector85:
  pushl $0
  102164:	6a 00                	push   $0x0
  pushl $85
  102166:	6a 55                	push   $0x55
  jmp __alltraps
  102168:	e9 e6 fc ff ff       	jmp    101e53 <__alltraps>

0010216d <vector86>:
.globl vector86
vector86:
  pushl $0
  10216d:	6a 00                	push   $0x0
  pushl $86
  10216f:	6a 56                	push   $0x56
  jmp __alltraps
  102171:	e9 dd fc ff ff       	jmp    101e53 <__alltraps>

00102176 <vector87>:
.globl vector87
vector87:
  pushl $0
  102176:	6a 00                	push   $0x0
  pushl $87
  102178:	6a 57                	push   $0x57
  jmp __alltraps
  10217a:	e9 d4 fc ff ff       	jmp    101e53 <__alltraps>

0010217f <vector88>:
.globl vector88
vector88:
  pushl $0
  10217f:	6a 00                	push   $0x0
  pushl $88
  102181:	6a 58                	push   $0x58
  jmp __alltraps
  102183:	e9 cb fc ff ff       	jmp    101e53 <__alltraps>

00102188 <vector89>:
.globl vector89
vector89:
  pushl $0
  102188:	6a 00                	push   $0x0
  pushl $89
  10218a:	6a 59                	push   $0x59
  jmp __alltraps
  10218c:	e9 c2 fc ff ff       	jmp    101e53 <__alltraps>

00102191 <vector90>:
.globl vector90
vector90:
  pushl $0
  102191:	6a 00                	push   $0x0
  pushl $90
  102193:	6a 5a                	push   $0x5a
  jmp __alltraps
  102195:	e9 b9 fc ff ff       	jmp    101e53 <__alltraps>

0010219a <vector91>:
.globl vector91
vector91:
  pushl $0
  10219a:	6a 00                	push   $0x0
  pushl $91
  10219c:	6a 5b                	push   $0x5b
  jmp __alltraps
  10219e:	e9 b0 fc ff ff       	jmp    101e53 <__alltraps>

001021a3 <vector92>:
.globl vector92
vector92:
  pushl $0
  1021a3:	6a 00                	push   $0x0
  pushl $92
  1021a5:	6a 5c                	push   $0x5c
  jmp __alltraps
  1021a7:	e9 a7 fc ff ff       	jmp    101e53 <__alltraps>

001021ac <vector93>:
.globl vector93
vector93:
  pushl $0
  1021ac:	6a 00                	push   $0x0
  pushl $93
  1021ae:	6a 5d                	push   $0x5d
  jmp __alltraps
  1021b0:	e9 9e fc ff ff       	jmp    101e53 <__alltraps>

001021b5 <vector94>:
.globl vector94
vector94:
  pushl $0
  1021b5:	6a 00                	push   $0x0
  pushl $94
  1021b7:	6a 5e                	push   $0x5e
  jmp __alltraps
  1021b9:	e9 95 fc ff ff       	jmp    101e53 <__alltraps>

001021be <vector95>:
.globl vector95
vector95:
  pushl $0
  1021be:	6a 00                	push   $0x0
  pushl $95
  1021c0:	6a 5f                	push   $0x5f
  jmp __alltraps
  1021c2:	e9 8c fc ff ff       	jmp    101e53 <__alltraps>

001021c7 <vector96>:
.globl vector96
vector96:
  pushl $0
  1021c7:	6a 00                	push   $0x0
  pushl $96
  1021c9:	6a 60                	push   $0x60
  jmp __alltraps
  1021cb:	e9 83 fc ff ff       	jmp    101e53 <__alltraps>

001021d0 <vector97>:
.globl vector97
vector97:
  pushl $0
  1021d0:	6a 00                	push   $0x0
  pushl $97
  1021d2:	6a 61                	push   $0x61
  jmp __alltraps
  1021d4:	e9 7a fc ff ff       	jmp    101e53 <__alltraps>

001021d9 <vector98>:
.globl vector98
vector98:
  pushl $0
  1021d9:	6a 00                	push   $0x0
  pushl $98
  1021db:	6a 62                	push   $0x62
  jmp __alltraps
  1021dd:	e9 71 fc ff ff       	jmp    101e53 <__alltraps>

001021e2 <vector99>:
.globl vector99
vector99:
  pushl $0
  1021e2:	6a 00                	push   $0x0
  pushl $99
  1021e4:	6a 63                	push   $0x63
  jmp __alltraps
  1021e6:	e9 68 fc ff ff       	jmp    101e53 <__alltraps>

001021eb <vector100>:
.globl vector100
vector100:
  pushl $0
  1021eb:	6a 00                	push   $0x0
  pushl $100
  1021ed:	6a 64                	push   $0x64
  jmp __alltraps
  1021ef:	e9 5f fc ff ff       	jmp    101e53 <__alltraps>

001021f4 <vector101>:
.globl vector101
vector101:
  pushl $0
  1021f4:	6a 00                	push   $0x0
  pushl $101
  1021f6:	6a 65                	push   $0x65
  jmp __alltraps
  1021f8:	e9 56 fc ff ff       	jmp    101e53 <__alltraps>

001021fd <vector102>:
.globl vector102
vector102:
  pushl $0
  1021fd:	6a 00                	push   $0x0
  pushl $102
  1021ff:	6a 66                	push   $0x66
  jmp __alltraps
  102201:	e9 4d fc ff ff       	jmp    101e53 <__alltraps>

00102206 <vector103>:
.globl vector103
vector103:
  pushl $0
  102206:	6a 00                	push   $0x0
  pushl $103
  102208:	6a 67                	push   $0x67
  jmp __alltraps
  10220a:	e9 44 fc ff ff       	jmp    101e53 <__alltraps>

0010220f <vector104>:
.globl vector104
vector104:
  pushl $0
  10220f:	6a 00                	push   $0x0
  pushl $104
  102211:	6a 68                	push   $0x68
  jmp __alltraps
  102213:	e9 3b fc ff ff       	jmp    101e53 <__alltraps>

00102218 <vector105>:
.globl vector105
vector105:
  pushl $0
  102218:	6a 00                	push   $0x0
  pushl $105
  10221a:	6a 69                	push   $0x69
  jmp __alltraps
  10221c:	e9 32 fc ff ff       	jmp    101e53 <__alltraps>

00102221 <vector106>:
.globl vector106
vector106:
  pushl $0
  102221:	6a 00                	push   $0x0
  pushl $106
  102223:	6a 6a                	push   $0x6a
  jmp __alltraps
  102225:	e9 29 fc ff ff       	jmp    101e53 <__alltraps>

0010222a <vector107>:
.globl vector107
vector107:
  pushl $0
  10222a:	6a 00                	push   $0x0
  pushl $107
  10222c:	6a 6b                	push   $0x6b
  jmp __alltraps
  10222e:	e9 20 fc ff ff       	jmp    101e53 <__alltraps>

00102233 <vector108>:
.globl vector108
vector108:
  pushl $0
  102233:	6a 00                	push   $0x0
  pushl $108
  102235:	6a 6c                	push   $0x6c
  jmp __alltraps
  102237:	e9 17 fc ff ff       	jmp    101e53 <__alltraps>

0010223c <vector109>:
.globl vector109
vector109:
  pushl $0
  10223c:	6a 00                	push   $0x0
  pushl $109
  10223e:	6a 6d                	push   $0x6d
  jmp __alltraps
  102240:	e9 0e fc ff ff       	jmp    101e53 <__alltraps>

00102245 <vector110>:
.globl vector110
vector110:
  pushl $0
  102245:	6a 00                	push   $0x0
  pushl $110
  102247:	6a 6e                	push   $0x6e
  jmp __alltraps
  102249:	e9 05 fc ff ff       	jmp    101e53 <__alltraps>

0010224e <vector111>:
.globl vector111
vector111:
  pushl $0
  10224e:	6a 00                	push   $0x0
  pushl $111
  102250:	6a 6f                	push   $0x6f
  jmp __alltraps
  102252:	e9 fc fb ff ff       	jmp    101e53 <__alltraps>

00102257 <vector112>:
.globl vector112
vector112:
  pushl $0
  102257:	6a 00                	push   $0x0
  pushl $112
  102259:	6a 70                	push   $0x70
  jmp __alltraps
  10225b:	e9 f3 fb ff ff       	jmp    101e53 <__alltraps>

00102260 <vector113>:
.globl vector113
vector113:
  pushl $0
  102260:	6a 00                	push   $0x0
  pushl $113
  102262:	6a 71                	push   $0x71
  jmp __alltraps
  102264:	e9 ea fb ff ff       	jmp    101e53 <__alltraps>

00102269 <vector114>:
.globl vector114
vector114:
  pushl $0
  102269:	6a 00                	push   $0x0
  pushl $114
  10226b:	6a 72                	push   $0x72
  jmp __alltraps
  10226d:	e9 e1 fb ff ff       	jmp    101e53 <__alltraps>

00102272 <vector115>:
.globl vector115
vector115:
  pushl $0
  102272:	6a 00                	push   $0x0
  pushl $115
  102274:	6a 73                	push   $0x73
  jmp __alltraps
  102276:	e9 d8 fb ff ff       	jmp    101e53 <__alltraps>

0010227b <vector116>:
.globl vector116
vector116:
  pushl $0
  10227b:	6a 00                	push   $0x0
  pushl $116
  10227d:	6a 74                	push   $0x74
  jmp __alltraps
  10227f:	e9 cf fb ff ff       	jmp    101e53 <__alltraps>

00102284 <vector117>:
.globl vector117
vector117:
  pushl $0
  102284:	6a 00                	push   $0x0
  pushl $117
  102286:	6a 75                	push   $0x75
  jmp __alltraps
  102288:	e9 c6 fb ff ff       	jmp    101e53 <__alltraps>

0010228d <vector118>:
.globl vector118
vector118:
  pushl $0
  10228d:	6a 00                	push   $0x0
  pushl $118
  10228f:	6a 76                	push   $0x76
  jmp __alltraps
  102291:	e9 bd fb ff ff       	jmp    101e53 <__alltraps>

00102296 <vector119>:
.globl vector119
vector119:
  pushl $0
  102296:	6a 00                	push   $0x0
  pushl $119
  102298:	6a 77                	push   $0x77
  jmp __alltraps
  10229a:	e9 b4 fb ff ff       	jmp    101e53 <__alltraps>

0010229f <vector120>:
.globl vector120
vector120:
  pushl $0
  10229f:	6a 00                	push   $0x0
  pushl $120
  1022a1:	6a 78                	push   $0x78
  jmp __alltraps
  1022a3:	e9 ab fb ff ff       	jmp    101e53 <__alltraps>

001022a8 <vector121>:
.globl vector121
vector121:
  pushl $0
  1022a8:	6a 00                	push   $0x0
  pushl $121
  1022aa:	6a 79                	push   $0x79
  jmp __alltraps
  1022ac:	e9 a2 fb ff ff       	jmp    101e53 <__alltraps>

001022b1 <vector122>:
.globl vector122
vector122:
  pushl $0
  1022b1:	6a 00                	push   $0x0
  pushl $122
  1022b3:	6a 7a                	push   $0x7a
  jmp __alltraps
  1022b5:	e9 99 fb ff ff       	jmp    101e53 <__alltraps>

001022ba <vector123>:
.globl vector123
vector123:
  pushl $0
  1022ba:	6a 00                	push   $0x0
  pushl $123
  1022bc:	6a 7b                	push   $0x7b
  jmp __alltraps
  1022be:	e9 90 fb ff ff       	jmp    101e53 <__alltraps>

001022c3 <vector124>:
.globl vector124
vector124:
  pushl $0
  1022c3:	6a 00                	push   $0x0
  pushl $124
  1022c5:	6a 7c                	push   $0x7c
  jmp __alltraps
  1022c7:	e9 87 fb ff ff       	jmp    101e53 <__alltraps>

001022cc <vector125>:
.globl vector125
vector125:
  pushl $0
  1022cc:	6a 00                	push   $0x0
  pushl $125
  1022ce:	6a 7d                	push   $0x7d
  jmp __alltraps
  1022d0:	e9 7e fb ff ff       	jmp    101e53 <__alltraps>

001022d5 <vector126>:
.globl vector126
vector126:
  pushl $0
  1022d5:	6a 00                	push   $0x0
  pushl $126
  1022d7:	6a 7e                	push   $0x7e
  jmp __alltraps
  1022d9:	e9 75 fb ff ff       	jmp    101e53 <__alltraps>

001022de <vector127>:
.globl vector127
vector127:
  pushl $0
  1022de:	6a 00                	push   $0x0
  pushl $127
  1022e0:	6a 7f                	push   $0x7f
  jmp __alltraps
  1022e2:	e9 6c fb ff ff       	jmp    101e53 <__alltraps>

001022e7 <vector128>:
.globl vector128
vector128:
  pushl $0
  1022e7:	6a 00                	push   $0x0
  pushl $128
  1022e9:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  1022ee:	e9 60 fb ff ff       	jmp    101e53 <__alltraps>

001022f3 <vector129>:
.globl vector129
vector129:
  pushl $0
  1022f3:	6a 00                	push   $0x0
  pushl $129
  1022f5:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  1022fa:	e9 54 fb ff ff       	jmp    101e53 <__alltraps>

001022ff <vector130>:
.globl vector130
vector130:
  pushl $0
  1022ff:	6a 00                	push   $0x0
  pushl $130
  102301:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  102306:	e9 48 fb ff ff       	jmp    101e53 <__alltraps>

0010230b <vector131>:
.globl vector131
vector131:
  pushl $0
  10230b:	6a 00                	push   $0x0
  pushl $131
  10230d:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  102312:	e9 3c fb ff ff       	jmp    101e53 <__alltraps>

00102317 <vector132>:
.globl vector132
vector132:
  pushl $0
  102317:	6a 00                	push   $0x0
  pushl $132
  102319:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  10231e:	e9 30 fb ff ff       	jmp    101e53 <__alltraps>

00102323 <vector133>:
.globl vector133
vector133:
  pushl $0
  102323:	6a 00                	push   $0x0
  pushl $133
  102325:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  10232a:	e9 24 fb ff ff       	jmp    101e53 <__alltraps>

0010232f <vector134>:
.globl vector134
vector134:
  pushl $0
  10232f:	6a 00                	push   $0x0
  pushl $134
  102331:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  102336:	e9 18 fb ff ff       	jmp    101e53 <__alltraps>

0010233b <vector135>:
.globl vector135
vector135:
  pushl $0
  10233b:	6a 00                	push   $0x0
  pushl $135
  10233d:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  102342:	e9 0c fb ff ff       	jmp    101e53 <__alltraps>

00102347 <vector136>:
.globl vector136
vector136:
  pushl $0
  102347:	6a 00                	push   $0x0
  pushl $136
  102349:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  10234e:	e9 00 fb ff ff       	jmp    101e53 <__alltraps>

00102353 <vector137>:
.globl vector137
vector137:
  pushl $0
  102353:	6a 00                	push   $0x0
  pushl $137
  102355:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  10235a:	e9 f4 fa ff ff       	jmp    101e53 <__alltraps>

0010235f <vector138>:
.globl vector138
vector138:
  pushl $0
  10235f:	6a 00                	push   $0x0
  pushl $138
  102361:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  102366:	e9 e8 fa ff ff       	jmp    101e53 <__alltraps>

0010236b <vector139>:
.globl vector139
vector139:
  pushl $0
  10236b:	6a 00                	push   $0x0
  pushl $139
  10236d:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  102372:	e9 dc fa ff ff       	jmp    101e53 <__alltraps>

00102377 <vector140>:
.globl vector140
vector140:
  pushl $0
  102377:	6a 00                	push   $0x0
  pushl $140
  102379:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  10237e:	e9 d0 fa ff ff       	jmp    101e53 <__alltraps>

00102383 <vector141>:
.globl vector141
vector141:
  pushl $0
  102383:	6a 00                	push   $0x0
  pushl $141
  102385:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  10238a:	e9 c4 fa ff ff       	jmp    101e53 <__alltraps>

0010238f <vector142>:
.globl vector142
vector142:
  pushl $0
  10238f:	6a 00                	push   $0x0
  pushl $142
  102391:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  102396:	e9 b8 fa ff ff       	jmp    101e53 <__alltraps>

0010239b <vector143>:
.globl vector143
vector143:
  pushl $0
  10239b:	6a 00                	push   $0x0
  pushl $143
  10239d:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  1023a2:	e9 ac fa ff ff       	jmp    101e53 <__alltraps>

001023a7 <vector144>:
.globl vector144
vector144:
  pushl $0
  1023a7:	6a 00                	push   $0x0
  pushl $144
  1023a9:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  1023ae:	e9 a0 fa ff ff       	jmp    101e53 <__alltraps>

001023b3 <vector145>:
.globl vector145
vector145:
  pushl $0
  1023b3:	6a 00                	push   $0x0
  pushl $145
  1023b5:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  1023ba:	e9 94 fa ff ff       	jmp    101e53 <__alltraps>

001023bf <vector146>:
.globl vector146
vector146:
  pushl $0
  1023bf:	6a 00                	push   $0x0
  pushl $146
  1023c1:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  1023c6:	e9 88 fa ff ff       	jmp    101e53 <__alltraps>

001023cb <vector147>:
.globl vector147
vector147:
  pushl $0
  1023cb:	6a 00                	push   $0x0
  pushl $147
  1023cd:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  1023d2:	e9 7c fa ff ff       	jmp    101e53 <__alltraps>

001023d7 <vector148>:
.globl vector148
vector148:
  pushl $0
  1023d7:	6a 00                	push   $0x0
  pushl $148
  1023d9:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  1023de:	e9 70 fa ff ff       	jmp    101e53 <__alltraps>

001023e3 <vector149>:
.globl vector149
vector149:
  pushl $0
  1023e3:	6a 00                	push   $0x0
  pushl $149
  1023e5:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  1023ea:	e9 64 fa ff ff       	jmp    101e53 <__alltraps>

001023ef <vector150>:
.globl vector150
vector150:
  pushl $0
  1023ef:	6a 00                	push   $0x0
  pushl $150
  1023f1:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  1023f6:	e9 58 fa ff ff       	jmp    101e53 <__alltraps>

001023fb <vector151>:
.globl vector151
vector151:
  pushl $0
  1023fb:	6a 00                	push   $0x0
  pushl $151
  1023fd:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  102402:	e9 4c fa ff ff       	jmp    101e53 <__alltraps>

00102407 <vector152>:
.globl vector152
vector152:
  pushl $0
  102407:	6a 00                	push   $0x0
  pushl $152
  102409:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  10240e:	e9 40 fa ff ff       	jmp    101e53 <__alltraps>

00102413 <vector153>:
.globl vector153
vector153:
  pushl $0
  102413:	6a 00                	push   $0x0
  pushl $153
  102415:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  10241a:	e9 34 fa ff ff       	jmp    101e53 <__alltraps>

0010241f <vector154>:
.globl vector154
vector154:
  pushl $0
  10241f:	6a 00                	push   $0x0
  pushl $154
  102421:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  102426:	e9 28 fa ff ff       	jmp    101e53 <__alltraps>

0010242b <vector155>:
.globl vector155
vector155:
  pushl $0
  10242b:	6a 00                	push   $0x0
  pushl $155
  10242d:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  102432:	e9 1c fa ff ff       	jmp    101e53 <__alltraps>

00102437 <vector156>:
.globl vector156
vector156:
  pushl $0
  102437:	6a 00                	push   $0x0
  pushl $156
  102439:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  10243e:	e9 10 fa ff ff       	jmp    101e53 <__alltraps>

00102443 <vector157>:
.globl vector157
vector157:
  pushl $0
  102443:	6a 00                	push   $0x0
  pushl $157
  102445:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  10244a:	e9 04 fa ff ff       	jmp    101e53 <__alltraps>

0010244f <vector158>:
.globl vector158
vector158:
  pushl $0
  10244f:	6a 00                	push   $0x0
  pushl $158
  102451:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  102456:	e9 f8 f9 ff ff       	jmp    101e53 <__alltraps>

0010245b <vector159>:
.globl vector159
vector159:
  pushl $0
  10245b:	6a 00                	push   $0x0
  pushl $159
  10245d:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  102462:	e9 ec f9 ff ff       	jmp    101e53 <__alltraps>

00102467 <vector160>:
.globl vector160
vector160:
  pushl $0
  102467:	6a 00                	push   $0x0
  pushl $160
  102469:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  10246e:	e9 e0 f9 ff ff       	jmp    101e53 <__alltraps>

00102473 <vector161>:
.globl vector161
vector161:
  pushl $0
  102473:	6a 00                	push   $0x0
  pushl $161
  102475:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  10247a:	e9 d4 f9 ff ff       	jmp    101e53 <__alltraps>

0010247f <vector162>:
.globl vector162
vector162:
  pushl $0
  10247f:	6a 00                	push   $0x0
  pushl $162
  102481:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  102486:	e9 c8 f9 ff ff       	jmp    101e53 <__alltraps>

0010248b <vector163>:
.globl vector163
vector163:
  pushl $0
  10248b:	6a 00                	push   $0x0
  pushl $163
  10248d:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  102492:	e9 bc f9 ff ff       	jmp    101e53 <__alltraps>

00102497 <vector164>:
.globl vector164
vector164:
  pushl $0
  102497:	6a 00                	push   $0x0
  pushl $164
  102499:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  10249e:	e9 b0 f9 ff ff       	jmp    101e53 <__alltraps>

001024a3 <vector165>:
.globl vector165
vector165:
  pushl $0
  1024a3:	6a 00                	push   $0x0
  pushl $165
  1024a5:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  1024aa:	e9 a4 f9 ff ff       	jmp    101e53 <__alltraps>

001024af <vector166>:
.globl vector166
vector166:
  pushl $0
  1024af:	6a 00                	push   $0x0
  pushl $166
  1024b1:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  1024b6:	e9 98 f9 ff ff       	jmp    101e53 <__alltraps>

001024bb <vector167>:
.globl vector167
vector167:
  pushl $0
  1024bb:	6a 00                	push   $0x0
  pushl $167
  1024bd:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  1024c2:	e9 8c f9 ff ff       	jmp    101e53 <__alltraps>

001024c7 <vector168>:
.globl vector168
vector168:
  pushl $0
  1024c7:	6a 00                	push   $0x0
  pushl $168
  1024c9:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  1024ce:	e9 80 f9 ff ff       	jmp    101e53 <__alltraps>

001024d3 <vector169>:
.globl vector169
vector169:
  pushl $0
  1024d3:	6a 00                	push   $0x0
  pushl $169
  1024d5:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  1024da:	e9 74 f9 ff ff       	jmp    101e53 <__alltraps>

001024df <vector170>:
.globl vector170
vector170:
  pushl $0
  1024df:	6a 00                	push   $0x0
  pushl $170
  1024e1:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  1024e6:	e9 68 f9 ff ff       	jmp    101e53 <__alltraps>

001024eb <vector171>:
.globl vector171
vector171:
  pushl $0
  1024eb:	6a 00                	push   $0x0
  pushl $171
  1024ed:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  1024f2:	e9 5c f9 ff ff       	jmp    101e53 <__alltraps>

001024f7 <vector172>:
.globl vector172
vector172:
  pushl $0
  1024f7:	6a 00                	push   $0x0
  pushl $172
  1024f9:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  1024fe:	e9 50 f9 ff ff       	jmp    101e53 <__alltraps>

00102503 <vector173>:
.globl vector173
vector173:
  pushl $0
  102503:	6a 00                	push   $0x0
  pushl $173
  102505:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  10250a:	e9 44 f9 ff ff       	jmp    101e53 <__alltraps>

0010250f <vector174>:
.globl vector174
vector174:
  pushl $0
  10250f:	6a 00                	push   $0x0
  pushl $174
  102511:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  102516:	e9 38 f9 ff ff       	jmp    101e53 <__alltraps>

0010251b <vector175>:
.globl vector175
vector175:
  pushl $0
  10251b:	6a 00                	push   $0x0
  pushl $175
  10251d:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  102522:	e9 2c f9 ff ff       	jmp    101e53 <__alltraps>

00102527 <vector176>:
.globl vector176
vector176:
  pushl $0
  102527:	6a 00                	push   $0x0
  pushl $176
  102529:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  10252e:	e9 20 f9 ff ff       	jmp    101e53 <__alltraps>

00102533 <vector177>:
.globl vector177
vector177:
  pushl $0
  102533:	6a 00                	push   $0x0
  pushl $177
  102535:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  10253a:	e9 14 f9 ff ff       	jmp    101e53 <__alltraps>

0010253f <vector178>:
.globl vector178
vector178:
  pushl $0
  10253f:	6a 00                	push   $0x0
  pushl $178
  102541:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  102546:	e9 08 f9 ff ff       	jmp    101e53 <__alltraps>

0010254b <vector179>:
.globl vector179
vector179:
  pushl $0
  10254b:	6a 00                	push   $0x0
  pushl $179
  10254d:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  102552:	e9 fc f8 ff ff       	jmp    101e53 <__alltraps>

00102557 <vector180>:
.globl vector180
vector180:
  pushl $0
  102557:	6a 00                	push   $0x0
  pushl $180
  102559:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  10255e:	e9 f0 f8 ff ff       	jmp    101e53 <__alltraps>

00102563 <vector181>:
.globl vector181
vector181:
  pushl $0
  102563:	6a 00                	push   $0x0
  pushl $181
  102565:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  10256a:	e9 e4 f8 ff ff       	jmp    101e53 <__alltraps>

0010256f <vector182>:
.globl vector182
vector182:
  pushl $0
  10256f:	6a 00                	push   $0x0
  pushl $182
  102571:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  102576:	e9 d8 f8 ff ff       	jmp    101e53 <__alltraps>

0010257b <vector183>:
.globl vector183
vector183:
  pushl $0
  10257b:	6a 00                	push   $0x0
  pushl $183
  10257d:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  102582:	e9 cc f8 ff ff       	jmp    101e53 <__alltraps>

00102587 <vector184>:
.globl vector184
vector184:
  pushl $0
  102587:	6a 00                	push   $0x0
  pushl $184
  102589:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  10258e:	e9 c0 f8 ff ff       	jmp    101e53 <__alltraps>

00102593 <vector185>:
.globl vector185
vector185:
  pushl $0
  102593:	6a 00                	push   $0x0
  pushl $185
  102595:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  10259a:	e9 b4 f8 ff ff       	jmp    101e53 <__alltraps>

0010259f <vector186>:
.globl vector186
vector186:
  pushl $0
  10259f:	6a 00                	push   $0x0
  pushl $186
  1025a1:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  1025a6:	e9 a8 f8 ff ff       	jmp    101e53 <__alltraps>

001025ab <vector187>:
.globl vector187
vector187:
  pushl $0
  1025ab:	6a 00                	push   $0x0
  pushl $187
  1025ad:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  1025b2:	e9 9c f8 ff ff       	jmp    101e53 <__alltraps>

001025b7 <vector188>:
.globl vector188
vector188:
  pushl $0
  1025b7:	6a 00                	push   $0x0
  pushl $188
  1025b9:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  1025be:	e9 90 f8 ff ff       	jmp    101e53 <__alltraps>

001025c3 <vector189>:
.globl vector189
vector189:
  pushl $0
  1025c3:	6a 00                	push   $0x0
  pushl $189
  1025c5:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  1025ca:	e9 84 f8 ff ff       	jmp    101e53 <__alltraps>

001025cf <vector190>:
.globl vector190
vector190:
  pushl $0
  1025cf:	6a 00                	push   $0x0
  pushl $190
  1025d1:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  1025d6:	e9 78 f8 ff ff       	jmp    101e53 <__alltraps>

001025db <vector191>:
.globl vector191
vector191:
  pushl $0
  1025db:	6a 00                	push   $0x0
  pushl $191
  1025dd:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  1025e2:	e9 6c f8 ff ff       	jmp    101e53 <__alltraps>

001025e7 <vector192>:
.globl vector192
vector192:
  pushl $0
  1025e7:	6a 00                	push   $0x0
  pushl $192
  1025e9:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  1025ee:	e9 60 f8 ff ff       	jmp    101e53 <__alltraps>

001025f3 <vector193>:
.globl vector193
vector193:
  pushl $0
  1025f3:	6a 00                	push   $0x0
  pushl $193
  1025f5:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  1025fa:	e9 54 f8 ff ff       	jmp    101e53 <__alltraps>

001025ff <vector194>:
.globl vector194
vector194:
  pushl $0
  1025ff:	6a 00                	push   $0x0
  pushl $194
  102601:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  102606:	e9 48 f8 ff ff       	jmp    101e53 <__alltraps>

0010260b <vector195>:
.globl vector195
vector195:
  pushl $0
  10260b:	6a 00                	push   $0x0
  pushl $195
  10260d:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  102612:	e9 3c f8 ff ff       	jmp    101e53 <__alltraps>

00102617 <vector196>:
.globl vector196
vector196:
  pushl $0
  102617:	6a 00                	push   $0x0
  pushl $196
  102619:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  10261e:	e9 30 f8 ff ff       	jmp    101e53 <__alltraps>

00102623 <vector197>:
.globl vector197
vector197:
  pushl $0
  102623:	6a 00                	push   $0x0
  pushl $197
  102625:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  10262a:	e9 24 f8 ff ff       	jmp    101e53 <__alltraps>

0010262f <vector198>:
.globl vector198
vector198:
  pushl $0
  10262f:	6a 00                	push   $0x0
  pushl $198
  102631:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  102636:	e9 18 f8 ff ff       	jmp    101e53 <__alltraps>

0010263b <vector199>:
.globl vector199
vector199:
  pushl $0
  10263b:	6a 00                	push   $0x0
  pushl $199
  10263d:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  102642:	e9 0c f8 ff ff       	jmp    101e53 <__alltraps>

00102647 <vector200>:
.globl vector200
vector200:
  pushl $0
  102647:	6a 00                	push   $0x0
  pushl $200
  102649:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  10264e:	e9 00 f8 ff ff       	jmp    101e53 <__alltraps>

00102653 <vector201>:
.globl vector201
vector201:
  pushl $0
  102653:	6a 00                	push   $0x0
  pushl $201
  102655:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  10265a:	e9 f4 f7 ff ff       	jmp    101e53 <__alltraps>

0010265f <vector202>:
.globl vector202
vector202:
  pushl $0
  10265f:	6a 00                	push   $0x0
  pushl $202
  102661:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  102666:	e9 e8 f7 ff ff       	jmp    101e53 <__alltraps>

0010266b <vector203>:
.globl vector203
vector203:
  pushl $0
  10266b:	6a 00                	push   $0x0
  pushl $203
  10266d:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  102672:	e9 dc f7 ff ff       	jmp    101e53 <__alltraps>

00102677 <vector204>:
.globl vector204
vector204:
  pushl $0
  102677:	6a 00                	push   $0x0
  pushl $204
  102679:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  10267e:	e9 d0 f7 ff ff       	jmp    101e53 <__alltraps>

00102683 <vector205>:
.globl vector205
vector205:
  pushl $0
  102683:	6a 00                	push   $0x0
  pushl $205
  102685:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  10268a:	e9 c4 f7 ff ff       	jmp    101e53 <__alltraps>

0010268f <vector206>:
.globl vector206
vector206:
  pushl $0
  10268f:	6a 00                	push   $0x0
  pushl $206
  102691:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  102696:	e9 b8 f7 ff ff       	jmp    101e53 <__alltraps>

0010269b <vector207>:
.globl vector207
vector207:
  pushl $0
  10269b:	6a 00                	push   $0x0
  pushl $207
  10269d:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  1026a2:	e9 ac f7 ff ff       	jmp    101e53 <__alltraps>

001026a7 <vector208>:
.globl vector208
vector208:
  pushl $0
  1026a7:	6a 00                	push   $0x0
  pushl $208
  1026a9:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  1026ae:	e9 a0 f7 ff ff       	jmp    101e53 <__alltraps>

001026b3 <vector209>:
.globl vector209
vector209:
  pushl $0
  1026b3:	6a 00                	push   $0x0
  pushl $209
  1026b5:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  1026ba:	e9 94 f7 ff ff       	jmp    101e53 <__alltraps>

001026bf <vector210>:
.globl vector210
vector210:
  pushl $0
  1026bf:	6a 00                	push   $0x0
  pushl $210
  1026c1:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  1026c6:	e9 88 f7 ff ff       	jmp    101e53 <__alltraps>

001026cb <vector211>:
.globl vector211
vector211:
  pushl $0
  1026cb:	6a 00                	push   $0x0
  pushl $211
  1026cd:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  1026d2:	e9 7c f7 ff ff       	jmp    101e53 <__alltraps>

001026d7 <vector212>:
.globl vector212
vector212:
  pushl $0
  1026d7:	6a 00                	push   $0x0
  pushl $212
  1026d9:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  1026de:	e9 70 f7 ff ff       	jmp    101e53 <__alltraps>

001026e3 <vector213>:
.globl vector213
vector213:
  pushl $0
  1026e3:	6a 00                	push   $0x0
  pushl $213
  1026e5:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  1026ea:	e9 64 f7 ff ff       	jmp    101e53 <__alltraps>

001026ef <vector214>:
.globl vector214
vector214:
  pushl $0
  1026ef:	6a 00                	push   $0x0
  pushl $214
  1026f1:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  1026f6:	e9 58 f7 ff ff       	jmp    101e53 <__alltraps>

001026fb <vector215>:
.globl vector215
vector215:
  pushl $0
  1026fb:	6a 00                	push   $0x0
  pushl $215
  1026fd:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  102702:	e9 4c f7 ff ff       	jmp    101e53 <__alltraps>

00102707 <vector216>:
.globl vector216
vector216:
  pushl $0
  102707:	6a 00                	push   $0x0
  pushl $216
  102709:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  10270e:	e9 40 f7 ff ff       	jmp    101e53 <__alltraps>

00102713 <vector217>:
.globl vector217
vector217:
  pushl $0
  102713:	6a 00                	push   $0x0
  pushl $217
  102715:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  10271a:	e9 34 f7 ff ff       	jmp    101e53 <__alltraps>

0010271f <vector218>:
.globl vector218
vector218:
  pushl $0
  10271f:	6a 00                	push   $0x0
  pushl $218
  102721:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  102726:	e9 28 f7 ff ff       	jmp    101e53 <__alltraps>

0010272b <vector219>:
.globl vector219
vector219:
  pushl $0
  10272b:	6a 00                	push   $0x0
  pushl $219
  10272d:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  102732:	e9 1c f7 ff ff       	jmp    101e53 <__alltraps>

00102737 <vector220>:
.globl vector220
vector220:
  pushl $0
  102737:	6a 00                	push   $0x0
  pushl $220
  102739:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  10273e:	e9 10 f7 ff ff       	jmp    101e53 <__alltraps>

00102743 <vector221>:
.globl vector221
vector221:
  pushl $0
  102743:	6a 00                	push   $0x0
  pushl $221
  102745:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  10274a:	e9 04 f7 ff ff       	jmp    101e53 <__alltraps>

0010274f <vector222>:
.globl vector222
vector222:
  pushl $0
  10274f:	6a 00                	push   $0x0
  pushl $222
  102751:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  102756:	e9 f8 f6 ff ff       	jmp    101e53 <__alltraps>

0010275b <vector223>:
.globl vector223
vector223:
  pushl $0
  10275b:	6a 00                	push   $0x0
  pushl $223
  10275d:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  102762:	e9 ec f6 ff ff       	jmp    101e53 <__alltraps>

00102767 <vector224>:
.globl vector224
vector224:
  pushl $0
  102767:	6a 00                	push   $0x0
  pushl $224
  102769:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  10276e:	e9 e0 f6 ff ff       	jmp    101e53 <__alltraps>

00102773 <vector225>:
.globl vector225
vector225:
  pushl $0
  102773:	6a 00                	push   $0x0
  pushl $225
  102775:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  10277a:	e9 d4 f6 ff ff       	jmp    101e53 <__alltraps>

0010277f <vector226>:
.globl vector226
vector226:
  pushl $0
  10277f:	6a 00                	push   $0x0
  pushl $226
  102781:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  102786:	e9 c8 f6 ff ff       	jmp    101e53 <__alltraps>

0010278b <vector227>:
.globl vector227
vector227:
  pushl $0
  10278b:	6a 00                	push   $0x0
  pushl $227
  10278d:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  102792:	e9 bc f6 ff ff       	jmp    101e53 <__alltraps>

00102797 <vector228>:
.globl vector228
vector228:
  pushl $0
  102797:	6a 00                	push   $0x0
  pushl $228
  102799:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  10279e:	e9 b0 f6 ff ff       	jmp    101e53 <__alltraps>

001027a3 <vector229>:
.globl vector229
vector229:
  pushl $0
  1027a3:	6a 00                	push   $0x0
  pushl $229
  1027a5:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  1027aa:	e9 a4 f6 ff ff       	jmp    101e53 <__alltraps>

001027af <vector230>:
.globl vector230
vector230:
  pushl $0
  1027af:	6a 00                	push   $0x0
  pushl $230
  1027b1:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  1027b6:	e9 98 f6 ff ff       	jmp    101e53 <__alltraps>

001027bb <vector231>:
.globl vector231
vector231:
  pushl $0
  1027bb:	6a 00                	push   $0x0
  pushl $231
  1027bd:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  1027c2:	e9 8c f6 ff ff       	jmp    101e53 <__alltraps>

001027c7 <vector232>:
.globl vector232
vector232:
  pushl $0
  1027c7:	6a 00                	push   $0x0
  pushl $232
  1027c9:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  1027ce:	e9 80 f6 ff ff       	jmp    101e53 <__alltraps>

001027d3 <vector233>:
.globl vector233
vector233:
  pushl $0
  1027d3:	6a 00                	push   $0x0
  pushl $233
  1027d5:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  1027da:	e9 74 f6 ff ff       	jmp    101e53 <__alltraps>

001027df <vector234>:
.globl vector234
vector234:
  pushl $0
  1027df:	6a 00                	push   $0x0
  pushl $234
  1027e1:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  1027e6:	e9 68 f6 ff ff       	jmp    101e53 <__alltraps>

001027eb <vector235>:
.globl vector235
vector235:
  pushl $0
  1027eb:	6a 00                	push   $0x0
  pushl $235
  1027ed:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  1027f2:	e9 5c f6 ff ff       	jmp    101e53 <__alltraps>

001027f7 <vector236>:
.globl vector236
vector236:
  pushl $0
  1027f7:	6a 00                	push   $0x0
  pushl $236
  1027f9:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  1027fe:	e9 50 f6 ff ff       	jmp    101e53 <__alltraps>

00102803 <vector237>:
.globl vector237
vector237:
  pushl $0
  102803:	6a 00                	push   $0x0
  pushl $237
  102805:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  10280a:	e9 44 f6 ff ff       	jmp    101e53 <__alltraps>

0010280f <vector238>:
.globl vector238
vector238:
  pushl $0
  10280f:	6a 00                	push   $0x0
  pushl $238
  102811:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  102816:	e9 38 f6 ff ff       	jmp    101e53 <__alltraps>

0010281b <vector239>:
.globl vector239
vector239:
  pushl $0
  10281b:	6a 00                	push   $0x0
  pushl $239
  10281d:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  102822:	e9 2c f6 ff ff       	jmp    101e53 <__alltraps>

00102827 <vector240>:
.globl vector240
vector240:
  pushl $0
  102827:	6a 00                	push   $0x0
  pushl $240
  102829:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  10282e:	e9 20 f6 ff ff       	jmp    101e53 <__alltraps>

00102833 <vector241>:
.globl vector241
vector241:
  pushl $0
  102833:	6a 00                	push   $0x0
  pushl $241
  102835:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  10283a:	e9 14 f6 ff ff       	jmp    101e53 <__alltraps>

0010283f <vector242>:
.globl vector242
vector242:
  pushl $0
  10283f:	6a 00                	push   $0x0
  pushl $242
  102841:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  102846:	e9 08 f6 ff ff       	jmp    101e53 <__alltraps>

0010284b <vector243>:
.globl vector243
vector243:
  pushl $0
  10284b:	6a 00                	push   $0x0
  pushl $243
  10284d:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  102852:	e9 fc f5 ff ff       	jmp    101e53 <__alltraps>

00102857 <vector244>:
.globl vector244
vector244:
  pushl $0
  102857:	6a 00                	push   $0x0
  pushl $244
  102859:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  10285e:	e9 f0 f5 ff ff       	jmp    101e53 <__alltraps>

00102863 <vector245>:
.globl vector245
vector245:
  pushl $0
  102863:	6a 00                	push   $0x0
  pushl $245
  102865:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  10286a:	e9 e4 f5 ff ff       	jmp    101e53 <__alltraps>

0010286f <vector246>:
.globl vector246
vector246:
  pushl $0
  10286f:	6a 00                	push   $0x0
  pushl $246
  102871:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  102876:	e9 d8 f5 ff ff       	jmp    101e53 <__alltraps>

0010287b <vector247>:
.globl vector247
vector247:
  pushl $0
  10287b:	6a 00                	push   $0x0
  pushl $247
  10287d:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  102882:	e9 cc f5 ff ff       	jmp    101e53 <__alltraps>

00102887 <vector248>:
.globl vector248
vector248:
  pushl $0
  102887:	6a 00                	push   $0x0
  pushl $248
  102889:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  10288e:	e9 c0 f5 ff ff       	jmp    101e53 <__alltraps>

00102893 <vector249>:
.globl vector249
vector249:
  pushl $0
  102893:	6a 00                	push   $0x0
  pushl $249
  102895:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  10289a:	e9 b4 f5 ff ff       	jmp    101e53 <__alltraps>

0010289f <vector250>:
.globl vector250
vector250:
  pushl $0
  10289f:	6a 00                	push   $0x0
  pushl $250
  1028a1:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  1028a6:	e9 a8 f5 ff ff       	jmp    101e53 <__alltraps>

001028ab <vector251>:
.globl vector251
vector251:
  pushl $0
  1028ab:	6a 00                	push   $0x0
  pushl $251
  1028ad:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  1028b2:	e9 9c f5 ff ff       	jmp    101e53 <__alltraps>

001028b7 <vector252>:
.globl vector252
vector252:
  pushl $0
  1028b7:	6a 00                	push   $0x0
  pushl $252
  1028b9:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  1028be:	e9 90 f5 ff ff       	jmp    101e53 <__alltraps>

001028c3 <vector253>:
.globl vector253
vector253:
  pushl $0
  1028c3:	6a 00                	push   $0x0
  pushl $253
  1028c5:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  1028ca:	e9 84 f5 ff ff       	jmp    101e53 <__alltraps>

001028cf <vector254>:
.globl vector254
vector254:
  pushl $0
  1028cf:	6a 00                	push   $0x0
  pushl $254
  1028d1:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  1028d6:	e9 78 f5 ff ff       	jmp    101e53 <__alltraps>

001028db <vector255>:
.globl vector255
vector255:
  pushl $0
  1028db:	6a 00                	push   $0x0
  pushl $255
  1028dd:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  1028e2:	e9 6c f5 ff ff       	jmp    101e53 <__alltraps>

001028e7 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  1028e7:	55                   	push   %ebp
  1028e8:	89 e5                	mov    %esp,%ebp
    return page - pages;
  1028ea:	8b 15 a0 be 11 00    	mov    0x11bea0,%edx
  1028f0:	8b 45 08             	mov    0x8(%ebp),%eax
  1028f3:	29 d0                	sub    %edx,%eax
  1028f5:	c1 f8 02             	sar    $0x2,%eax
  1028f8:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  1028fe:	5d                   	pop    %ebp
  1028ff:	c3                   	ret    

00102900 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  102900:	55                   	push   %ebp
  102901:	89 e5                	mov    %esp,%ebp
  102903:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  102906:	8b 45 08             	mov    0x8(%ebp),%eax
  102909:	89 04 24             	mov    %eax,(%esp)
  10290c:	e8 d6 ff ff ff       	call   1028e7 <page2ppn>
  102911:	c1 e0 0c             	shl    $0xc,%eax
}
  102914:	89 ec                	mov    %ebp,%esp
  102916:	5d                   	pop    %ebp
  102917:	c3                   	ret    

00102918 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
  102918:	55                   	push   %ebp
  102919:	89 e5                	mov    %esp,%ebp
    return page->ref;
  10291b:	8b 45 08             	mov    0x8(%ebp),%eax
  10291e:	8b 00                	mov    (%eax),%eax
}
  102920:	5d                   	pop    %ebp
  102921:	c3                   	ret    

00102922 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  102922:	55                   	push   %ebp
  102923:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  102925:	8b 45 08             	mov    0x8(%ebp),%eax
  102928:	8b 55 0c             	mov    0xc(%ebp),%edx
  10292b:	89 10                	mov    %edx,(%eax)
}
  10292d:	90                   	nop
  10292e:	5d                   	pop    %ebp
  10292f:	c3                   	ret    

00102930 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {//初始化双向链表
  102930:	55                   	push   %ebp
  102931:	89 e5                	mov    %esp,%ebp
  102933:	83 ec 10             	sub    $0x10,%esp
  102936:	c7 45 fc 80 be 11 00 	movl   $0x11be80,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  10293d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102940:	8b 55 fc             	mov    -0x4(%ebp),%edx
  102943:	89 50 04             	mov    %edx,0x4(%eax)
  102946:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102949:	8b 50 04             	mov    0x4(%eax),%edx
  10294c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10294f:	89 10                	mov    %edx,(%eax)
}
  102951:	90                   	nop
    list_init(&free_list);
    nr_free = 0;
  102952:	c7 05 88 be 11 00 00 	movl   $0x0,0x11be88
  102959:	00 00 00 
}
  10295c:	90                   	nop
  10295d:	89 ec                	mov    %ebp,%esp
  10295f:	5d                   	pop    %ebp
  102960:	c3                   	ret    

00102961 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {//
  102961:	55                   	push   %ebp
  102962:	89 e5                	mov    %esp,%ebp
  102964:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);//物理页个数
  102967:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  10296b:	75 24                	jne    102991 <default_init_memmap+0x30>
  10296d:	c7 44 24 0c d0 66 10 	movl   $0x1066d0,0xc(%esp)
  102974:	00 
  102975:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  10297c:	00 
  10297d:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  102984:	00 
  102985:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  10298c:	e8 4a e3 ff ff       	call   100cdb <__panic>
    struct Page *p = base;
  102991:	8b 45 08             	mov    0x8(%ebp),%eax
  102994:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  102997:	e9 97 00 00 00       	jmp    102a33 <default_init_memmap+0xd2>
        assert(PageReserved(p));//判断是不是保留页，防止被分配或者破坏
  10299c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10299f:	83 c0 04             	add    $0x4,%eax
  1029a2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  1029a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1029ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1029af:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1029b2:	0f a3 10             	bt     %edx,(%eax)
  1029b5:	19 c0                	sbb    %eax,%eax
  1029b7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
  1029ba:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1029be:	0f 95 c0             	setne  %al
  1029c1:	0f b6 c0             	movzbl %al,%eax
  1029c4:	85 c0                	test   %eax,%eax
  1029c6:	75 24                	jne    1029ec <default_init_memmap+0x8b>
  1029c8:	c7 44 24 0c 01 67 10 	movl   $0x106701,0xc(%esp)
  1029cf:	00 
  1029d0:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  1029d7:	00 
  1029d8:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  1029df:	00 
  1029e0:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  1029e7:	e8 ef e2 ff ff       	call   100cdb <__panic>
        p->flags = p->property = 0;
  1029ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1029ef:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  1029f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1029f9:	8b 50 08             	mov    0x8(%eax),%edx
  1029fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1029ff:	89 50 04             	mov    %edx,0x4(%eax)
        SetPageProperty(base);//设置标志位p->property=0
  102a02:	8b 45 08             	mov    0x8(%ebp),%eax
  102a05:	83 c0 04             	add    $0x4,%eax
  102a08:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  102a0f:	89 45 e0             	mov    %eax,-0x20(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102a12:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102a15:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102a18:	0f ab 10             	bts    %edx,(%eax)
}
  102a1b:	90                   	nop
        set_page_ref(p, 0);//设置引用此页的虚拟页为0
  102a1c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  102a23:	00 
  102a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102a27:	89 04 24             	mov    %eax,(%esp)
  102a2a:	e8 f3 fe ff ff       	call   102922 <set_page_ref>
    for (; p != base + n; p ++) {
  102a2f:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  102a33:	8b 55 0c             	mov    0xc(%ebp),%edx
  102a36:	89 d0                	mov    %edx,%eax
  102a38:	c1 e0 02             	shl    $0x2,%eax
  102a3b:	01 d0                	add    %edx,%eax
  102a3d:	c1 e0 02             	shl    $0x2,%eax
  102a40:	89 c2                	mov    %eax,%edx
  102a42:	8b 45 08             	mov    0x8(%ebp),%eax
  102a45:	01 d0                	add    %edx,%eax
  102a47:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  102a4a:	0f 85 4c ff ff ff    	jne    10299c <default_init_memmap+0x3b>
        
    }
    base->property = n;
  102a50:	8b 45 08             	mov    0x8(%ebp),%eax
  102a53:	8b 55 0c             	mov    0xc(%ebp),%edx
  102a56:	89 50 08             	mov    %edx,0x8(%eax)
    nr_free += n;//本Page有n个空闲页
  102a59:	8b 15 88 be 11 00    	mov    0x11be88,%edx
  102a5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  102a62:	01 d0                	add    %edx,%eax
  102a64:	a3 88 be 11 00       	mov    %eax,0x11be88
    list_add_before(&free_list, &(base->page_link));
  102a69:	8b 45 08             	mov    0x8(%ebp),%eax
  102a6c:	83 c0 0c             	add    $0xc,%eax
  102a6f:	c7 45 dc 80 be 11 00 	movl   $0x11be80,-0x24(%ebp)
  102a76:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  102a79:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102a7c:	8b 00                	mov    (%eax),%eax
  102a7e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  102a81:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  102a84:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102a87:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102a8a:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  102a8d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102a90:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102a93:	89 10                	mov    %edx,(%eax)
  102a95:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102a98:	8b 10                	mov    (%eax),%edx
  102a9a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102a9d:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  102aa0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  102aa3:	8b 55 cc             	mov    -0x34(%ebp),%edx
  102aa6:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102aa9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  102aac:	8b 55 d0             	mov    -0x30(%ebp),%edx
  102aaf:	89 10                	mov    %edx,(%eax)
}
  102ab1:	90                   	nop
}
  102ab2:	90                   	nop
    
}
  102ab3:	90                   	nop
  102ab4:	89 ec                	mov    %ebp,%esp
  102ab6:	5d                   	pop    %ebp
  102ab7:	c3                   	ret    

00102ab8 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
  102ab8:	55                   	push   %ebp
  102ab9:	89 e5                	mov    %esp,%ebp
  102abb:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
  102abe:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  102ac2:	75 24                	jne    102ae8 <default_alloc_pages+0x30>
  102ac4:	c7 44 24 0c d0 66 10 	movl   $0x1066d0,0xc(%esp)
  102acb:	00 
  102acc:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  102ad3:	00 
  102ad4:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  102adb:	00 
  102adc:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  102ae3:	e8 f3 e1 ff ff       	call   100cdb <__panic>
    if (n > nr_free) {//判断分配的页数和实际空闲的页数
  102ae8:	a1 88 be 11 00       	mov    0x11be88,%eax
  102aed:	39 45 08             	cmp    %eax,0x8(%ebp)
  102af0:	76 0a                	jbe    102afc <default_alloc_pages+0x44>
        return NULL;
  102af2:	b8 00 00 00 00       	mov    $0x0,%eax
  102af7:	e9 43 01 00 00       	jmp    102c3f <default_alloc_pages+0x187>
    }
    struct Page *page = NULL;
  102afc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;//获得空闲页表的长度和头部
  102b03:	c7 45 f0 80 be 11 00 	movl   $0x11be80,-0x10(%ebp)
    // TODO: optimize (next-fit)
    while ((le = list_next(le)) != &free_list) {
  102b0a:	eb 1c                	jmp    102b28 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);//链表地址转换为Page结构指针
  102b0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102b0f:	83 e8 0c             	sub    $0xc,%eax
  102b12:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {//找到第一个页数足够的块
  102b15:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102b18:	8b 40 08             	mov    0x8(%eax),%eax
  102b1b:	39 45 08             	cmp    %eax,0x8(%ebp)
  102b1e:	77 08                	ja     102b28 <default_alloc_pages+0x70>
            page = p;
  102b20:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102b23:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
  102b26:	eb 18                	jmp    102b40 <default_alloc_pages+0x88>
  102b28:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102b2b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
  102b2e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102b31:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  102b34:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102b37:	81 7d f0 80 be 11 00 	cmpl   $0x11be80,-0x10(%ebp)
  102b3e:	75 cc                	jne    102b0c <default_alloc_pages+0x54>
        }
    }
    if (page != NULL) {
  102b40:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  102b44:	0f 84 f2 00 00 00    	je     102c3c <default_alloc_pages+0x184>
        if (page->property > n) {
  102b4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102b4d:	8b 40 08             	mov    0x8(%eax),%eax
  102b50:	39 45 08             	cmp    %eax,0x8(%ebp)
  102b53:	0f 83 8f 00 00 00    	jae    102be8 <default_alloc_pages+0x130>
            struct Page *p = page + n;//分离出的新的小空闲首页位置
  102b59:	8b 55 08             	mov    0x8(%ebp),%edx
  102b5c:	89 d0                	mov    %edx,%eax
  102b5e:	c1 e0 02             	shl    $0x2,%eax
  102b61:	01 d0                	add    %edx,%eax
  102b63:	c1 e0 02             	shl    $0x2,%eax
  102b66:	89 c2                	mov    %eax,%edx
  102b68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102b6b:	01 d0                	add    %edx,%eax
  102b6d:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;//更新大小信息
  102b70:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102b73:	8b 40 08             	mov    0x8(%eax),%eax
  102b76:	2b 45 08             	sub    0x8(%ebp),%eax
  102b79:	89 c2                	mov    %eax,%edx
  102b7b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102b7e:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
  102b81:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102b84:	83 c0 04             	add    $0x4,%eax
  102b87:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
  102b8e:	89 45 c8             	mov    %eax,-0x38(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102b91:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102b94:	8b 55 cc             	mov    -0x34(%ebp),%edx
  102b97:	0f ab 10             	bts    %edx,(%eax)
}
  102b9a:	90                   	nop
            list_add_after(&(page->page_link), &(p->page_link));
  102b9b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102b9e:	83 c0 0c             	add    $0xc,%eax
  102ba1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102ba4:	83 c2 0c             	add    $0xc,%edx
  102ba7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  102baa:	89 45 dc             	mov    %eax,-0x24(%ebp)
    __list_add(elm, listelm, listelm->next);
  102bad:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102bb0:	8b 40 04             	mov    0x4(%eax),%eax
  102bb3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102bb6:	89 55 d8             	mov    %edx,-0x28(%ebp)
  102bb9:	8b 55 e0             	mov    -0x20(%ebp),%edx
  102bbc:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  102bbf:	89 45 d0             	mov    %eax,-0x30(%ebp)
    prev->next = next->prev = elm;
  102bc2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102bc5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  102bc8:	89 10                	mov    %edx,(%eax)
  102bca:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102bcd:	8b 10                	mov    (%eax),%edx
  102bcf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  102bd2:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  102bd5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102bd8:	8b 55 d0             	mov    -0x30(%ebp),%edx
  102bdb:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102bde:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102be1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102be4:	89 10                	mov    %edx,(%eax)
}
  102be6:	90                   	nop
}
  102be7:	90                   	nop
        }
        list_del(&(page->page_link));//删除分配出去的块
  102be8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102beb:	83 c0 0c             	add    $0xc,%eax
  102bee:	89 45 bc             	mov    %eax,-0x44(%ebp)
    __list_del(listelm->prev, listelm->next);
  102bf1:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102bf4:	8b 40 04             	mov    0x4(%eax),%eax
  102bf7:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102bfa:	8b 12                	mov    (%edx),%edx
  102bfc:	89 55 b8             	mov    %edx,-0x48(%ebp)
  102bff:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  102c02:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102c05:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  102c08:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102c0b:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102c0e:	8b 55 b8             	mov    -0x48(%ebp),%edx
  102c11:	89 10                	mov    %edx,(%eax)
}
  102c13:	90                   	nop
}
  102c14:	90                   	nop
        nr_free -= n;//全局空闲页更新
  102c15:	a1 88 be 11 00       	mov    0x11be88,%eax
  102c1a:	2b 45 08             	sub    0x8(%ebp),%eax
  102c1d:	a3 88 be 11 00       	mov    %eax,0x11be88
        ClearPageProperty(page);
  102c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c25:	83 c0 04             	add    $0x4,%eax
  102c28:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  102c2f:	89 45 c0             	mov    %eax,-0x40(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102c32:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102c35:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  102c38:	0f b3 10             	btr    %edx,(%eax)
}
  102c3b:	90                   	nop
    }
    return page;
  102c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  102c3f:	89 ec                	mov    %ebp,%esp
  102c41:	5d                   	pop    %ebp
  102c42:	c3                   	ret    

00102c43 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
  102c43:	55                   	push   %ebp
  102c44:	89 e5                	mov    %esp,%ebp
  102c46:	81 ec 88 00 00 00    	sub    $0x88,%esp
    assert(n > 0);
  102c4c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102c50:	75 24                	jne    102c76 <default_free_pages+0x33>
  102c52:	c7 44 24 0c d0 66 10 	movl   $0x1066d0,0xc(%esp)
  102c59:	00 
  102c5a:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  102c61:	00 
  102c62:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  102c69:	00 
  102c6a:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  102c71:	e8 65 e0 ff ff       	call   100cdb <__panic>
    struct Page *p = base;
  102c76:	8b 45 08             	mov    0x8(%ebp),%eax
  102c79:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  102c7c:	e9 9d 00 00 00       	jmp    102d1e <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));//检查各个页是被占用或者已经分配出去，否则异常
  102c81:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c84:	83 c0 04             	add    $0x4,%eax
  102c87:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  102c8e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102c91:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102c94:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102c97:	0f a3 10             	bt     %edx,(%eax)
  102c9a:	19 c0                	sbb    %eax,%eax
  102c9c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
  102c9f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102ca3:	0f 95 c0             	setne  %al
  102ca6:	0f b6 c0             	movzbl %al,%eax
  102ca9:	85 c0                	test   %eax,%eax
  102cab:	75 2c                	jne    102cd9 <default_free_pages+0x96>
  102cad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102cb0:	83 c0 04             	add    $0x4,%eax
  102cb3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  102cba:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102cbd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102cc0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  102cc3:	0f a3 10             	bt     %edx,(%eax)
  102cc6:	19 c0                	sbb    %eax,%eax
  102cc8:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
  102ccb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  102ccf:	0f 95 c0             	setne  %al
  102cd2:	0f b6 c0             	movzbl %al,%eax
  102cd5:	85 c0                	test   %eax,%eax
  102cd7:	74 24                	je     102cfd <default_free_pages+0xba>
  102cd9:	c7 44 24 0c 14 67 10 	movl   $0x106714,0xc(%esp)
  102ce0:	00 
  102ce1:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  102ce8:	00 
  102ce9:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
  102cf0:	00 
  102cf1:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  102cf8:	e8 de df ff ff       	call   100cdb <__panic>
        p->flags = 0;
  102cfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d00:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);//重置
  102d07:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  102d0e:	00 
  102d0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d12:	89 04 24             	mov    %eax,(%esp)
  102d15:	e8 08 fc ff ff       	call   102922 <set_page_ref>
    for (; p != base + n; p ++) {
  102d1a:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  102d1e:	8b 55 0c             	mov    0xc(%ebp),%edx
  102d21:	89 d0                	mov    %edx,%eax
  102d23:	c1 e0 02             	shl    $0x2,%eax
  102d26:	01 d0                	add    %edx,%eax
  102d28:	c1 e0 02             	shl    $0x2,%eax
  102d2b:	89 c2                	mov    %eax,%edx
  102d2d:	8b 45 08             	mov    0x8(%ebp),%eax
  102d30:	01 d0                	add    %edx,%eax
  102d32:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  102d35:	0f 85 46 ff ff ff    	jne    102c81 <default_free_pages+0x3e>
    }
    base->property = n;
  102d3b:	8b 45 08             	mov    0x8(%ebp),%eax
  102d3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  102d41:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  102d44:	8b 45 08             	mov    0x8(%ebp),%eax
  102d47:	83 c0 04             	add    $0x4,%eax
  102d4a:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  102d51:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102d54:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102d57:	8b 55 d0             	mov    -0x30(%ebp),%edx
  102d5a:	0f ab 10             	bts    %edx,(%eax)
}
  102d5d:	90                   	nop
  102d5e:	c7 45 d4 80 be 11 00 	movl   $0x11be80,-0x2c(%ebp)
    return listelm->next;
  102d65:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  102d68:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list); //下一块空闲
  102d6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
  102d6e:	e9 0e 01 00 00       	jmp    102e81 <default_free_pages+0x23e>
        p = le2page(le, page_link);
  102d73:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102d76:	83 e8 0c             	sub    $0xc,%eax
  102d79:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102d7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102d7f:	89 45 c8             	mov    %eax,-0x38(%ebp)
  102d82:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102d85:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
  102d88:	89 45 f0             	mov    %eax,-0x10(%ebp)
        // TODO: optimize
        if (base + base->property == p) {//两块儿相邻
  102d8b:	8b 45 08             	mov    0x8(%ebp),%eax
  102d8e:	8b 50 08             	mov    0x8(%eax),%edx
  102d91:	89 d0                	mov    %edx,%eax
  102d93:	c1 e0 02             	shl    $0x2,%eax
  102d96:	01 d0                	add    %edx,%eax
  102d98:	c1 e0 02             	shl    $0x2,%eax
  102d9b:	89 c2                	mov    %eax,%edx
  102d9d:	8b 45 08             	mov    0x8(%ebp),%eax
  102da0:	01 d0                	add    %edx,%eax
  102da2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  102da5:	75 5d                	jne    102e04 <default_free_pages+0x1c1>
            base->property += p->property;
  102da7:	8b 45 08             	mov    0x8(%ebp),%eax
  102daa:	8b 50 08             	mov    0x8(%eax),%edx
  102dad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102db0:	8b 40 08             	mov    0x8(%eax),%eax
  102db3:	01 c2                	add    %eax,%edx
  102db5:	8b 45 08             	mov    0x8(%ebp),%eax
  102db8:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
  102dbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102dbe:	83 c0 04             	add    $0x4,%eax
  102dc1:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
  102dc8:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102dcb:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102dce:	8b 55 b8             	mov    -0x48(%ebp),%edx
  102dd1:	0f b3 10             	btr    %edx,(%eax)
}
  102dd4:	90                   	nop
            list_del(&(p->page_link));
  102dd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102dd8:	83 c0 0c             	add    $0xc,%eax
  102ddb:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    __list_del(listelm->prev, listelm->next);
  102dde:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102de1:	8b 40 04             	mov    0x4(%eax),%eax
  102de4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  102de7:	8b 12                	mov    (%edx),%edx
  102de9:	89 55 c0             	mov    %edx,-0x40(%ebp)
  102dec:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next;
  102def:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102df2:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102df5:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102df8:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102dfb:	8b 55 c0             	mov    -0x40(%ebp),%edx
  102dfe:	89 10                	mov    %edx,(%eax)
}
  102e00:	90                   	nop
}
  102e01:	90                   	nop
  102e02:	eb 7d                	jmp    102e81 <default_free_pages+0x23e>
        }
        else if (p + p->property == base) {
  102e04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102e07:	8b 50 08             	mov    0x8(%eax),%edx
  102e0a:	89 d0                	mov    %edx,%eax
  102e0c:	c1 e0 02             	shl    $0x2,%eax
  102e0f:	01 d0                	add    %edx,%eax
  102e11:	c1 e0 02             	shl    $0x2,%eax
  102e14:	89 c2                	mov    %eax,%edx
  102e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102e19:	01 d0                	add    %edx,%eax
  102e1b:	39 45 08             	cmp    %eax,0x8(%ebp)
  102e1e:	75 61                	jne    102e81 <default_free_pages+0x23e>
            p->property += base->property;
  102e20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102e23:	8b 50 08             	mov    0x8(%eax),%edx
  102e26:	8b 45 08             	mov    0x8(%ebp),%eax
  102e29:	8b 40 08             	mov    0x8(%eax),%eax
  102e2c:	01 c2                	add    %eax,%edx
  102e2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102e31:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
  102e34:	8b 45 08             	mov    0x8(%ebp),%eax
  102e37:	83 c0 04             	add    $0x4,%eax
  102e3a:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
  102e41:	89 45 a0             	mov    %eax,-0x60(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102e44:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102e47:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  102e4a:	0f b3 10             	btr    %edx,(%eax)
}
  102e4d:	90                   	nop
            base = p;
  102e4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102e51:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
  102e54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102e57:	83 c0 0c             	add    $0xc,%eax
  102e5a:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
  102e5d:	8b 45 b0             	mov    -0x50(%ebp),%eax
  102e60:	8b 40 04             	mov    0x4(%eax),%eax
  102e63:	8b 55 b0             	mov    -0x50(%ebp),%edx
  102e66:	8b 12                	mov    (%edx),%edx
  102e68:	89 55 ac             	mov    %edx,-0x54(%ebp)
  102e6b:	89 45 a8             	mov    %eax,-0x58(%ebp)
    prev->next = next;
  102e6e:	8b 45 ac             	mov    -0x54(%ebp),%eax
  102e71:	8b 55 a8             	mov    -0x58(%ebp),%edx
  102e74:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102e77:	8b 45 a8             	mov    -0x58(%ebp),%eax
  102e7a:	8b 55 ac             	mov    -0x54(%ebp),%edx
  102e7d:	89 10                	mov    %edx,(%eax)
}
  102e7f:	90                   	nop
}
  102e80:	90                   	nop
    while (le != &free_list) {
  102e81:	81 7d f0 80 be 11 00 	cmpl   $0x11be80,-0x10(%ebp)
  102e88:	0f 85 e5 fe ff ff    	jne    102d73 <default_free_pages+0x130>
        }
    }
    nr_free += n;
  102e8e:	8b 15 88 be 11 00    	mov    0x11be88,%edx
  102e94:	8b 45 0c             	mov    0xc(%ebp),%eax
  102e97:	01 d0                	add    %edx,%eax
  102e99:	a3 88 be 11 00       	mov    %eax,0x11be88
    list_add_before(le, &(base->page_link));
  102e9e:	8b 45 08             	mov    0x8(%ebp),%eax
  102ea1:	8d 50 0c             	lea    0xc(%eax),%edx
  102ea4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102ea7:	89 45 9c             	mov    %eax,-0x64(%ebp)
  102eaa:	89 55 98             	mov    %edx,-0x68(%ebp)
    __list_add(elm, listelm->prev, listelm);
  102ead:	8b 45 9c             	mov    -0x64(%ebp),%eax
  102eb0:	8b 00                	mov    (%eax),%eax
  102eb2:	8b 55 98             	mov    -0x68(%ebp),%edx
  102eb5:	89 55 94             	mov    %edx,-0x6c(%ebp)
  102eb8:	89 45 90             	mov    %eax,-0x70(%ebp)
  102ebb:	8b 45 9c             	mov    -0x64(%ebp),%eax
  102ebe:	89 45 8c             	mov    %eax,-0x74(%ebp)
    prev->next = next->prev = elm;
  102ec1:	8b 45 8c             	mov    -0x74(%ebp),%eax
  102ec4:	8b 55 94             	mov    -0x6c(%ebp),%edx
  102ec7:	89 10                	mov    %edx,(%eax)
  102ec9:	8b 45 8c             	mov    -0x74(%ebp),%eax
  102ecc:	8b 10                	mov    (%eax),%edx
  102ece:	8b 45 90             	mov    -0x70(%ebp),%eax
  102ed1:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  102ed4:	8b 45 94             	mov    -0x6c(%ebp),%eax
  102ed7:	8b 55 8c             	mov    -0x74(%ebp),%edx
  102eda:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102edd:	8b 45 94             	mov    -0x6c(%ebp),%eax
  102ee0:	8b 55 90             	mov    -0x70(%ebp),%edx
  102ee3:	89 10                	mov    %edx,(%eax)
}
  102ee5:	90                   	nop
}
  102ee6:	90                   	nop
}
  102ee7:	90                   	nop
  102ee8:	89 ec                	mov    %ebp,%esp
  102eea:	5d                   	pop    %ebp
  102eeb:	c3                   	ret    

00102eec <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
  102eec:	55                   	push   %ebp
  102eed:	89 e5                	mov    %esp,%ebp
    return nr_free;
  102eef:	a1 88 be 11 00       	mov    0x11be88,%eax
}
  102ef4:	5d                   	pop    %ebp
  102ef5:	c3                   	ret    

00102ef6 <basic_check>:

static void
basic_check(void) {
  102ef6:	55                   	push   %ebp
  102ef7:	89 e5                	mov    %esp,%ebp
  102ef9:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
  102efc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  102f03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102f06:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102f09:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102f0c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
  102f0f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  102f16:	e8 af 0e 00 00       	call   103dca <alloc_pages>
  102f1b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  102f1e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  102f22:	75 24                	jne    102f48 <basic_check+0x52>
  102f24:	c7 44 24 0c 39 67 10 	movl   $0x106739,0xc(%esp)
  102f2b:	00 
  102f2c:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  102f33:	00 
  102f34:	c7 44 24 04 c3 00 00 	movl   $0xc3,0x4(%esp)
  102f3b:	00 
  102f3c:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  102f43:	e8 93 dd ff ff       	call   100cdb <__panic>
    assert((p1 = alloc_page()) != NULL);
  102f48:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  102f4f:	e8 76 0e 00 00       	call   103dca <alloc_pages>
  102f54:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102f57:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  102f5b:	75 24                	jne    102f81 <basic_check+0x8b>
  102f5d:	c7 44 24 0c 55 67 10 	movl   $0x106755,0xc(%esp)
  102f64:	00 
  102f65:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  102f6c:	00 
  102f6d:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
  102f74:	00 
  102f75:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  102f7c:	e8 5a dd ff ff       	call   100cdb <__panic>
    assert((p2 = alloc_page()) != NULL);
  102f81:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  102f88:	e8 3d 0e 00 00       	call   103dca <alloc_pages>
  102f8d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102f90:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  102f94:	75 24                	jne    102fba <basic_check+0xc4>
  102f96:	c7 44 24 0c 71 67 10 	movl   $0x106771,0xc(%esp)
  102f9d:	00 
  102f9e:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  102fa5:	00 
  102fa6:	c7 44 24 04 c5 00 00 	movl   $0xc5,0x4(%esp)
  102fad:	00 
  102fae:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  102fb5:	e8 21 dd ff ff       	call   100cdb <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
  102fba:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102fbd:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  102fc0:	74 10                	je     102fd2 <basic_check+0xdc>
  102fc2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102fc5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102fc8:	74 08                	je     102fd2 <basic_check+0xdc>
  102fca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102fcd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102fd0:	75 24                	jne    102ff6 <basic_check+0x100>
  102fd2:	c7 44 24 0c 90 67 10 	movl   $0x106790,0xc(%esp)
  102fd9:	00 
  102fda:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  102fe1:	00 
  102fe2:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
  102fe9:	00 
  102fea:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  102ff1:	e8 e5 dc ff ff       	call   100cdb <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  102ff6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102ff9:	89 04 24             	mov    %eax,(%esp)
  102ffc:	e8 17 f9 ff ff       	call   102918 <page_ref>
  103001:	85 c0                	test   %eax,%eax
  103003:	75 1e                	jne    103023 <basic_check+0x12d>
  103005:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103008:	89 04 24             	mov    %eax,(%esp)
  10300b:	e8 08 f9 ff ff       	call   102918 <page_ref>
  103010:	85 c0                	test   %eax,%eax
  103012:	75 0f                	jne    103023 <basic_check+0x12d>
  103014:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103017:	89 04 24             	mov    %eax,(%esp)
  10301a:	e8 f9 f8 ff ff       	call   102918 <page_ref>
  10301f:	85 c0                	test   %eax,%eax
  103021:	74 24                	je     103047 <basic_check+0x151>
  103023:	c7 44 24 0c b4 67 10 	movl   $0x1067b4,0xc(%esp)
  10302a:	00 
  10302b:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  103032:	00 
  103033:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
  10303a:	00 
  10303b:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  103042:	e8 94 dc ff ff       	call   100cdb <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  103047:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10304a:	89 04 24             	mov    %eax,(%esp)
  10304d:	e8 ae f8 ff ff       	call   102900 <page2pa>
  103052:	8b 15 a4 be 11 00    	mov    0x11bea4,%edx
  103058:	c1 e2 0c             	shl    $0xc,%edx
  10305b:	39 d0                	cmp    %edx,%eax
  10305d:	72 24                	jb     103083 <basic_check+0x18d>
  10305f:	c7 44 24 0c f0 67 10 	movl   $0x1067f0,0xc(%esp)
  103066:	00 
  103067:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  10306e:	00 
  10306f:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
  103076:	00 
  103077:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  10307e:	e8 58 dc ff ff       	call   100cdb <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  103083:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103086:	89 04 24             	mov    %eax,(%esp)
  103089:	e8 72 f8 ff ff       	call   102900 <page2pa>
  10308e:	8b 15 a4 be 11 00    	mov    0x11bea4,%edx
  103094:	c1 e2 0c             	shl    $0xc,%edx
  103097:	39 d0                	cmp    %edx,%eax
  103099:	72 24                	jb     1030bf <basic_check+0x1c9>
  10309b:	c7 44 24 0c 0d 68 10 	movl   $0x10680d,0xc(%esp)
  1030a2:	00 
  1030a3:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  1030aa:	00 
  1030ab:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
  1030b2:	00 
  1030b3:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  1030ba:	e8 1c dc ff ff       	call   100cdb <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  1030bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1030c2:	89 04 24             	mov    %eax,(%esp)
  1030c5:	e8 36 f8 ff ff       	call   102900 <page2pa>
  1030ca:	8b 15 a4 be 11 00    	mov    0x11bea4,%edx
  1030d0:	c1 e2 0c             	shl    $0xc,%edx
  1030d3:	39 d0                	cmp    %edx,%eax
  1030d5:	72 24                	jb     1030fb <basic_check+0x205>
  1030d7:	c7 44 24 0c 2a 68 10 	movl   $0x10682a,0xc(%esp)
  1030de:	00 
  1030df:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  1030e6:	00 
  1030e7:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
  1030ee:	00 
  1030ef:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  1030f6:	e8 e0 db ff ff       	call   100cdb <__panic>

    list_entry_t free_list_store = free_list;
  1030fb:	a1 80 be 11 00       	mov    0x11be80,%eax
  103100:	8b 15 84 be 11 00    	mov    0x11be84,%edx
  103106:	89 45 d0             	mov    %eax,-0x30(%ebp)
  103109:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  10310c:	c7 45 dc 80 be 11 00 	movl   $0x11be80,-0x24(%ebp)
    elm->prev = elm->next = elm;
  103113:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103116:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103119:	89 50 04             	mov    %edx,0x4(%eax)
  10311c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10311f:	8b 50 04             	mov    0x4(%eax),%edx
  103122:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103125:	89 10                	mov    %edx,(%eax)
}
  103127:	90                   	nop
  103128:	c7 45 e0 80 be 11 00 	movl   $0x11be80,-0x20(%ebp)
    return list->next == list;
  10312f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103132:	8b 40 04             	mov    0x4(%eax),%eax
  103135:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  103138:	0f 94 c0             	sete   %al
  10313b:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  10313e:	85 c0                	test   %eax,%eax
  103140:	75 24                	jne    103166 <basic_check+0x270>
  103142:	c7 44 24 0c 47 68 10 	movl   $0x106847,0xc(%esp)
  103149:	00 
  10314a:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  103151:	00 
  103152:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
  103159:	00 
  10315a:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  103161:	e8 75 db ff ff       	call   100cdb <__panic>

    unsigned int nr_free_store = nr_free;
  103166:	a1 88 be 11 00       	mov    0x11be88,%eax
  10316b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
  10316e:	c7 05 88 be 11 00 00 	movl   $0x0,0x11be88
  103175:	00 00 00 

    assert(alloc_page() == NULL);
  103178:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10317f:	e8 46 0c 00 00       	call   103dca <alloc_pages>
  103184:	85 c0                	test   %eax,%eax
  103186:	74 24                	je     1031ac <basic_check+0x2b6>
  103188:	c7 44 24 0c 5e 68 10 	movl   $0x10685e,0xc(%esp)
  10318f:	00 
  103190:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  103197:	00 
  103198:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
  10319f:	00 
  1031a0:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  1031a7:	e8 2f db ff ff       	call   100cdb <__panic>

    free_page(p0);
  1031ac:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1031b3:	00 
  1031b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1031b7:	89 04 24             	mov    %eax,(%esp)
  1031ba:	e8 45 0c 00 00       	call   103e04 <free_pages>
    free_page(p1);
  1031bf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1031c6:	00 
  1031c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1031ca:	89 04 24             	mov    %eax,(%esp)
  1031cd:	e8 32 0c 00 00       	call   103e04 <free_pages>
    free_page(p2);
  1031d2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1031d9:	00 
  1031da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1031dd:	89 04 24             	mov    %eax,(%esp)
  1031e0:	e8 1f 0c 00 00       	call   103e04 <free_pages>
    assert(nr_free == 3);
  1031e5:	a1 88 be 11 00       	mov    0x11be88,%eax
  1031ea:	83 f8 03             	cmp    $0x3,%eax
  1031ed:	74 24                	je     103213 <basic_check+0x31d>
  1031ef:	c7 44 24 0c 73 68 10 	movl   $0x106873,0xc(%esp)
  1031f6:	00 
  1031f7:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  1031fe:	00 
  1031ff:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
  103206:	00 
  103207:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  10320e:	e8 c8 da ff ff       	call   100cdb <__panic>

    assert((p0 = alloc_page()) != NULL);
  103213:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10321a:	e8 ab 0b 00 00       	call   103dca <alloc_pages>
  10321f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103222:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  103226:	75 24                	jne    10324c <basic_check+0x356>
  103228:	c7 44 24 0c 39 67 10 	movl   $0x106739,0xc(%esp)
  10322f:	00 
  103230:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  103237:	00 
  103238:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
  10323f:	00 
  103240:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  103247:	e8 8f da ff ff       	call   100cdb <__panic>
    assert((p1 = alloc_page()) != NULL);
  10324c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103253:	e8 72 0b 00 00       	call   103dca <alloc_pages>
  103258:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10325b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10325f:	75 24                	jne    103285 <basic_check+0x38f>
  103261:	c7 44 24 0c 55 67 10 	movl   $0x106755,0xc(%esp)
  103268:	00 
  103269:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  103270:	00 
  103271:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
  103278:	00 
  103279:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  103280:	e8 56 da ff ff       	call   100cdb <__panic>
    assert((p2 = alloc_page()) != NULL);
  103285:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10328c:	e8 39 0b 00 00       	call   103dca <alloc_pages>
  103291:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103294:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103298:	75 24                	jne    1032be <basic_check+0x3c8>
  10329a:	c7 44 24 0c 71 67 10 	movl   $0x106771,0xc(%esp)
  1032a1:	00 
  1032a2:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  1032a9:	00 
  1032aa:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
  1032b1:	00 
  1032b2:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  1032b9:	e8 1d da ff ff       	call   100cdb <__panic>

    assert(alloc_page() == NULL);
  1032be:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1032c5:	e8 00 0b 00 00       	call   103dca <alloc_pages>
  1032ca:	85 c0                	test   %eax,%eax
  1032cc:	74 24                	je     1032f2 <basic_check+0x3fc>
  1032ce:	c7 44 24 0c 5e 68 10 	movl   $0x10685e,0xc(%esp)
  1032d5:	00 
  1032d6:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  1032dd:	00 
  1032de:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
  1032e5:	00 
  1032e6:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  1032ed:	e8 e9 d9 ff ff       	call   100cdb <__panic>

    free_page(p0);
  1032f2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1032f9:	00 
  1032fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1032fd:	89 04 24             	mov    %eax,(%esp)
  103300:	e8 ff 0a 00 00       	call   103e04 <free_pages>
  103305:	c7 45 d8 80 be 11 00 	movl   $0x11be80,-0x28(%ebp)
  10330c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10330f:	8b 40 04             	mov    0x4(%eax),%eax
  103312:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  103315:	0f 94 c0             	sete   %al
  103318:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
  10331b:	85 c0                	test   %eax,%eax
  10331d:	74 24                	je     103343 <basic_check+0x44d>
  10331f:	c7 44 24 0c 80 68 10 	movl   $0x106880,0xc(%esp)
  103326:	00 
  103327:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  10332e:	00 
  10332f:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
  103336:	00 
  103337:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  10333e:	e8 98 d9 ff ff       	call   100cdb <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
  103343:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10334a:	e8 7b 0a 00 00       	call   103dca <alloc_pages>
  10334f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103352:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103355:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  103358:	74 24                	je     10337e <basic_check+0x488>
  10335a:	c7 44 24 0c 98 68 10 	movl   $0x106898,0xc(%esp)
  103361:	00 
  103362:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  103369:	00 
  10336a:	c7 44 24 04 e6 00 00 	movl   $0xe6,0x4(%esp)
  103371:	00 
  103372:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  103379:	e8 5d d9 ff ff       	call   100cdb <__panic>
    assert(alloc_page() == NULL);
  10337e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103385:	e8 40 0a 00 00       	call   103dca <alloc_pages>
  10338a:	85 c0                	test   %eax,%eax
  10338c:	74 24                	je     1033b2 <basic_check+0x4bc>
  10338e:	c7 44 24 0c 5e 68 10 	movl   $0x10685e,0xc(%esp)
  103395:	00 
  103396:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  10339d:	00 
  10339e:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
  1033a5:	00 
  1033a6:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  1033ad:	e8 29 d9 ff ff       	call   100cdb <__panic>

    assert(nr_free == 0);
  1033b2:	a1 88 be 11 00       	mov    0x11be88,%eax
  1033b7:	85 c0                	test   %eax,%eax
  1033b9:	74 24                	je     1033df <basic_check+0x4e9>
  1033bb:	c7 44 24 0c b1 68 10 	movl   $0x1068b1,0xc(%esp)
  1033c2:	00 
  1033c3:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  1033ca:	00 
  1033cb:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
  1033d2:	00 
  1033d3:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  1033da:	e8 fc d8 ff ff       	call   100cdb <__panic>
    free_list = free_list_store;
  1033df:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1033e2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1033e5:	a3 80 be 11 00       	mov    %eax,0x11be80
  1033ea:	89 15 84 be 11 00    	mov    %edx,0x11be84
    nr_free = nr_free_store;
  1033f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1033f3:	a3 88 be 11 00       	mov    %eax,0x11be88

    free_page(p);
  1033f8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1033ff:	00 
  103400:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103403:	89 04 24             	mov    %eax,(%esp)
  103406:	e8 f9 09 00 00       	call   103e04 <free_pages>
    free_page(p1);
  10340b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103412:	00 
  103413:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103416:	89 04 24             	mov    %eax,(%esp)
  103419:	e8 e6 09 00 00       	call   103e04 <free_pages>
    free_page(p2);
  10341e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103425:	00 
  103426:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103429:	89 04 24             	mov    %eax,(%esp)
  10342c:	e8 d3 09 00 00       	call   103e04 <free_pages>
}
  103431:	90                   	nop
  103432:	89 ec                	mov    %ebp,%esp
  103434:	5d                   	pop    %ebp
  103435:	c3                   	ret    

00103436 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
  103436:	55                   	push   %ebp
  103437:	89 e5                	mov    %esp,%ebp
  103439:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
  10343f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  103446:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
  10344d:	c7 45 ec 80 be 11 00 	movl   $0x11be80,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  103454:	eb 6a                	jmp    1034c0 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
  103456:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103459:	83 e8 0c             	sub    $0xc,%eax
  10345c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
  10345f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  103462:	83 c0 04             	add    $0x4,%eax
  103465:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  10346c:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10346f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  103472:	8b 55 d0             	mov    -0x30(%ebp),%edx
  103475:	0f a3 10             	bt     %edx,(%eax)
  103478:	19 c0                	sbb    %eax,%eax
  10347a:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
  10347d:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  103481:	0f 95 c0             	setne  %al
  103484:	0f b6 c0             	movzbl %al,%eax
  103487:	85 c0                	test   %eax,%eax
  103489:	75 24                	jne    1034af <default_check+0x79>
  10348b:	c7 44 24 0c be 68 10 	movl   $0x1068be,0xc(%esp)
  103492:	00 
  103493:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  10349a:	00 
  10349b:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
  1034a2:	00 
  1034a3:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  1034aa:	e8 2c d8 ff ff       	call   100cdb <__panic>
        count ++, total += p->property;
  1034af:	ff 45 f4             	incl   -0xc(%ebp)
  1034b2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1034b5:	8b 50 08             	mov    0x8(%eax),%edx
  1034b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1034bb:	01 d0                	add    %edx,%eax
  1034bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1034c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1034c3:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
  1034c6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1034c9:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  1034cc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1034cf:	81 7d ec 80 be 11 00 	cmpl   $0x11be80,-0x14(%ebp)
  1034d6:	0f 85 7a ff ff ff    	jne    103456 <default_check+0x20>
    }
    assert(total == nr_free_pages());
  1034dc:	e8 58 09 00 00       	call   103e39 <nr_free_pages>
  1034e1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1034e4:	39 d0                	cmp    %edx,%eax
  1034e6:	74 24                	je     10350c <default_check+0xd6>
  1034e8:	c7 44 24 0c ce 68 10 	movl   $0x1068ce,0xc(%esp)
  1034ef:	00 
  1034f0:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  1034f7:	00 
  1034f8:	c7 44 24 04 fd 00 00 	movl   $0xfd,0x4(%esp)
  1034ff:	00 
  103500:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  103507:	e8 cf d7 ff ff       	call   100cdb <__panic>

    basic_check();
  10350c:	e8 e5 f9 ff ff       	call   102ef6 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
  103511:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  103518:	e8 ad 08 00 00       	call   103dca <alloc_pages>
  10351d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
  103520:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  103524:	75 24                	jne    10354a <default_check+0x114>
  103526:	c7 44 24 0c e7 68 10 	movl   $0x1068e7,0xc(%esp)
  10352d:	00 
  10352e:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  103535:	00 
  103536:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
  10353d:	00 
  10353e:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  103545:	e8 91 d7 ff ff       	call   100cdb <__panic>
    assert(!PageProperty(p0));
  10354a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10354d:	83 c0 04             	add    $0x4,%eax
  103550:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  103557:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10355a:	8b 45 bc             	mov    -0x44(%ebp),%eax
  10355d:	8b 55 c0             	mov    -0x40(%ebp),%edx
  103560:	0f a3 10             	bt     %edx,(%eax)
  103563:	19 c0                	sbb    %eax,%eax
  103565:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
  103568:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  10356c:	0f 95 c0             	setne  %al
  10356f:	0f b6 c0             	movzbl %al,%eax
  103572:	85 c0                	test   %eax,%eax
  103574:	74 24                	je     10359a <default_check+0x164>
  103576:	c7 44 24 0c f2 68 10 	movl   $0x1068f2,0xc(%esp)
  10357d:	00 
  10357e:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  103585:	00 
  103586:	c7 44 24 04 03 01 00 	movl   $0x103,0x4(%esp)
  10358d:	00 
  10358e:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  103595:	e8 41 d7 ff ff       	call   100cdb <__panic>

    list_entry_t free_list_store = free_list;
  10359a:	a1 80 be 11 00       	mov    0x11be80,%eax
  10359f:	8b 15 84 be 11 00    	mov    0x11be84,%edx
  1035a5:	89 45 80             	mov    %eax,-0x80(%ebp)
  1035a8:	89 55 84             	mov    %edx,-0x7c(%ebp)
  1035ab:	c7 45 b0 80 be 11 00 	movl   $0x11be80,-0x50(%ebp)
    elm->prev = elm->next = elm;
  1035b2:	8b 45 b0             	mov    -0x50(%ebp),%eax
  1035b5:	8b 55 b0             	mov    -0x50(%ebp),%edx
  1035b8:	89 50 04             	mov    %edx,0x4(%eax)
  1035bb:	8b 45 b0             	mov    -0x50(%ebp),%eax
  1035be:	8b 50 04             	mov    0x4(%eax),%edx
  1035c1:	8b 45 b0             	mov    -0x50(%ebp),%eax
  1035c4:	89 10                	mov    %edx,(%eax)
}
  1035c6:	90                   	nop
  1035c7:	c7 45 b4 80 be 11 00 	movl   $0x11be80,-0x4c(%ebp)
    return list->next == list;
  1035ce:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1035d1:	8b 40 04             	mov    0x4(%eax),%eax
  1035d4:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
  1035d7:	0f 94 c0             	sete   %al
  1035da:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  1035dd:	85 c0                	test   %eax,%eax
  1035df:	75 24                	jne    103605 <default_check+0x1cf>
  1035e1:	c7 44 24 0c 47 68 10 	movl   $0x106847,0xc(%esp)
  1035e8:	00 
  1035e9:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  1035f0:	00 
  1035f1:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
  1035f8:	00 
  1035f9:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  103600:	e8 d6 d6 ff ff       	call   100cdb <__panic>
    assert(alloc_page() == NULL);
  103605:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10360c:	e8 b9 07 00 00       	call   103dca <alloc_pages>
  103611:	85 c0                	test   %eax,%eax
  103613:	74 24                	je     103639 <default_check+0x203>
  103615:	c7 44 24 0c 5e 68 10 	movl   $0x10685e,0xc(%esp)
  10361c:	00 
  10361d:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  103624:	00 
  103625:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
  10362c:	00 
  10362d:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  103634:	e8 a2 d6 ff ff       	call   100cdb <__panic>

    unsigned int nr_free_store = nr_free;
  103639:	a1 88 be 11 00       	mov    0x11be88,%eax
  10363e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
  103641:	c7 05 88 be 11 00 00 	movl   $0x0,0x11be88
  103648:	00 00 00 

    free_pages(p0 + 2, 3);
  10364b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10364e:	83 c0 28             	add    $0x28,%eax
  103651:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  103658:	00 
  103659:	89 04 24             	mov    %eax,(%esp)
  10365c:	e8 a3 07 00 00       	call   103e04 <free_pages>
    assert(alloc_pages(4) == NULL);
  103661:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  103668:	e8 5d 07 00 00       	call   103dca <alloc_pages>
  10366d:	85 c0                	test   %eax,%eax
  10366f:	74 24                	je     103695 <default_check+0x25f>
  103671:	c7 44 24 0c 04 69 10 	movl   $0x106904,0xc(%esp)
  103678:	00 
  103679:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  103680:	00 
  103681:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
  103688:	00 
  103689:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  103690:	e8 46 d6 ff ff       	call   100cdb <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
  103695:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103698:	83 c0 28             	add    $0x28,%eax
  10369b:	83 c0 04             	add    $0x4,%eax
  10369e:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  1036a5:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1036a8:	8b 45 a8             	mov    -0x58(%ebp),%eax
  1036ab:	8b 55 ac             	mov    -0x54(%ebp),%edx
  1036ae:	0f a3 10             	bt     %edx,(%eax)
  1036b1:	19 c0                	sbb    %eax,%eax
  1036b3:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
  1036b6:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  1036ba:	0f 95 c0             	setne  %al
  1036bd:	0f b6 c0             	movzbl %al,%eax
  1036c0:	85 c0                	test   %eax,%eax
  1036c2:	74 0e                	je     1036d2 <default_check+0x29c>
  1036c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1036c7:	83 c0 28             	add    $0x28,%eax
  1036ca:	8b 40 08             	mov    0x8(%eax),%eax
  1036cd:	83 f8 03             	cmp    $0x3,%eax
  1036d0:	74 24                	je     1036f6 <default_check+0x2c0>
  1036d2:	c7 44 24 0c 1c 69 10 	movl   $0x10691c,0xc(%esp)
  1036d9:	00 
  1036da:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  1036e1:	00 
  1036e2:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
  1036e9:	00 
  1036ea:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  1036f1:	e8 e5 d5 ff ff       	call   100cdb <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
  1036f6:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  1036fd:	e8 c8 06 00 00       	call   103dca <alloc_pages>
  103702:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103705:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  103709:	75 24                	jne    10372f <default_check+0x2f9>
  10370b:	c7 44 24 0c 48 69 10 	movl   $0x106948,0xc(%esp)
  103712:	00 
  103713:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  10371a:	00 
  10371b:	c7 44 24 04 10 01 00 	movl   $0x110,0x4(%esp)
  103722:	00 
  103723:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  10372a:	e8 ac d5 ff ff       	call   100cdb <__panic>
    assert(alloc_page() == NULL);
  10372f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103736:	e8 8f 06 00 00       	call   103dca <alloc_pages>
  10373b:	85 c0                	test   %eax,%eax
  10373d:	74 24                	je     103763 <default_check+0x32d>
  10373f:	c7 44 24 0c 5e 68 10 	movl   $0x10685e,0xc(%esp)
  103746:	00 
  103747:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  10374e:	00 
  10374f:	c7 44 24 04 11 01 00 	movl   $0x111,0x4(%esp)
  103756:	00 
  103757:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  10375e:	e8 78 d5 ff ff       	call   100cdb <__panic>
    assert(p0 + 2 == p1);
  103763:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103766:	83 c0 28             	add    $0x28,%eax
  103769:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  10376c:	74 24                	je     103792 <default_check+0x35c>
  10376e:	c7 44 24 0c 66 69 10 	movl   $0x106966,0xc(%esp)
  103775:	00 
  103776:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  10377d:	00 
  10377e:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
  103785:	00 
  103786:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  10378d:	e8 49 d5 ff ff       	call   100cdb <__panic>

    p2 = p0 + 1;
  103792:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103795:	83 c0 14             	add    $0x14,%eax
  103798:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
  10379b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1037a2:	00 
  1037a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1037a6:	89 04 24             	mov    %eax,(%esp)
  1037a9:	e8 56 06 00 00       	call   103e04 <free_pages>
    free_pages(p1, 3);
  1037ae:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  1037b5:	00 
  1037b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1037b9:	89 04 24             	mov    %eax,(%esp)
  1037bc:	e8 43 06 00 00       	call   103e04 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
  1037c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1037c4:	83 c0 04             	add    $0x4,%eax
  1037c7:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
  1037ce:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1037d1:	8b 45 9c             	mov    -0x64(%ebp),%eax
  1037d4:	8b 55 a0             	mov    -0x60(%ebp),%edx
  1037d7:	0f a3 10             	bt     %edx,(%eax)
  1037da:	19 c0                	sbb    %eax,%eax
  1037dc:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
  1037df:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
  1037e3:	0f 95 c0             	setne  %al
  1037e6:	0f b6 c0             	movzbl %al,%eax
  1037e9:	85 c0                	test   %eax,%eax
  1037eb:	74 0b                	je     1037f8 <default_check+0x3c2>
  1037ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1037f0:	8b 40 08             	mov    0x8(%eax),%eax
  1037f3:	83 f8 01             	cmp    $0x1,%eax
  1037f6:	74 24                	je     10381c <default_check+0x3e6>
  1037f8:	c7 44 24 0c 74 69 10 	movl   $0x106974,0xc(%esp)
  1037ff:	00 
  103800:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  103807:	00 
  103808:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
  10380f:	00 
  103810:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  103817:	e8 bf d4 ff ff       	call   100cdb <__panic>
    assert(PageProperty(p1) && p1->property == 3);
  10381c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10381f:	83 c0 04             	add    $0x4,%eax
  103822:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
  103829:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10382c:	8b 45 90             	mov    -0x70(%ebp),%eax
  10382f:	8b 55 94             	mov    -0x6c(%ebp),%edx
  103832:	0f a3 10             	bt     %edx,(%eax)
  103835:	19 c0                	sbb    %eax,%eax
  103837:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
  10383a:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
  10383e:	0f 95 c0             	setne  %al
  103841:	0f b6 c0             	movzbl %al,%eax
  103844:	85 c0                	test   %eax,%eax
  103846:	74 0b                	je     103853 <default_check+0x41d>
  103848:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10384b:	8b 40 08             	mov    0x8(%eax),%eax
  10384e:	83 f8 03             	cmp    $0x3,%eax
  103851:	74 24                	je     103877 <default_check+0x441>
  103853:	c7 44 24 0c 9c 69 10 	movl   $0x10699c,0xc(%esp)
  10385a:	00 
  10385b:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  103862:	00 
  103863:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
  10386a:	00 
  10386b:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  103872:	e8 64 d4 ff ff       	call   100cdb <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
  103877:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10387e:	e8 47 05 00 00       	call   103dca <alloc_pages>
  103883:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103886:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103889:	83 e8 14             	sub    $0x14,%eax
  10388c:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  10388f:	74 24                	je     1038b5 <default_check+0x47f>
  103891:	c7 44 24 0c c2 69 10 	movl   $0x1069c2,0xc(%esp)
  103898:	00 
  103899:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  1038a0:	00 
  1038a1:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
  1038a8:	00 
  1038a9:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  1038b0:	e8 26 d4 ff ff       	call   100cdb <__panic>
    free_page(p0);
  1038b5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1038bc:	00 
  1038bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1038c0:	89 04 24             	mov    %eax,(%esp)
  1038c3:	e8 3c 05 00 00       	call   103e04 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
  1038c8:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1038cf:	e8 f6 04 00 00       	call   103dca <alloc_pages>
  1038d4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1038d7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1038da:	83 c0 14             	add    $0x14,%eax
  1038dd:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  1038e0:	74 24                	je     103906 <default_check+0x4d0>
  1038e2:	c7 44 24 0c e0 69 10 	movl   $0x1069e0,0xc(%esp)
  1038e9:	00 
  1038ea:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  1038f1:	00 
  1038f2:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
  1038f9:	00 
  1038fa:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  103901:	e8 d5 d3 ff ff       	call   100cdb <__panic>

    free_pages(p0, 2);
  103906:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  10390d:	00 
  10390e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103911:	89 04 24             	mov    %eax,(%esp)
  103914:	e8 eb 04 00 00       	call   103e04 <free_pages>
    free_page(p2);
  103919:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103920:	00 
  103921:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103924:	89 04 24             	mov    %eax,(%esp)
  103927:	e8 d8 04 00 00       	call   103e04 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
  10392c:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  103933:	e8 92 04 00 00       	call   103dca <alloc_pages>
  103938:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10393b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10393f:	75 24                	jne    103965 <default_check+0x52f>
  103941:	c7 44 24 0c 00 6a 10 	movl   $0x106a00,0xc(%esp)
  103948:	00 
  103949:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  103950:	00 
  103951:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
  103958:	00 
  103959:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  103960:	e8 76 d3 ff ff       	call   100cdb <__panic>
    assert(alloc_page() == NULL);
  103965:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10396c:	e8 59 04 00 00       	call   103dca <alloc_pages>
  103971:	85 c0                	test   %eax,%eax
  103973:	74 24                	je     103999 <default_check+0x563>
  103975:	c7 44 24 0c 5e 68 10 	movl   $0x10685e,0xc(%esp)
  10397c:	00 
  10397d:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  103984:	00 
  103985:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
  10398c:	00 
  10398d:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  103994:	e8 42 d3 ff ff       	call   100cdb <__panic>

    assert(nr_free == 0);
  103999:	a1 88 be 11 00       	mov    0x11be88,%eax
  10399e:	85 c0                	test   %eax,%eax
  1039a0:	74 24                	je     1039c6 <default_check+0x590>
  1039a2:	c7 44 24 0c b1 68 10 	movl   $0x1068b1,0xc(%esp)
  1039a9:	00 
  1039aa:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  1039b1:	00 
  1039b2:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  1039b9:	00 
  1039ba:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  1039c1:	e8 15 d3 ff ff       	call   100cdb <__panic>
    nr_free = nr_free_store;
  1039c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1039c9:	a3 88 be 11 00       	mov    %eax,0x11be88

    free_list = free_list_store;
  1039ce:	8b 45 80             	mov    -0x80(%ebp),%eax
  1039d1:	8b 55 84             	mov    -0x7c(%ebp),%edx
  1039d4:	a3 80 be 11 00       	mov    %eax,0x11be80
  1039d9:	89 15 84 be 11 00    	mov    %edx,0x11be84
    free_pages(p0, 5);
  1039df:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  1039e6:	00 
  1039e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1039ea:	89 04 24             	mov    %eax,(%esp)
  1039ed:	e8 12 04 00 00       	call   103e04 <free_pages>

    le = &free_list;
  1039f2:	c7 45 ec 80 be 11 00 	movl   $0x11be80,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  1039f9:	eb 1c                	jmp    103a17 <default_check+0x5e1>
        struct Page *p = le2page(le, page_link);
  1039fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1039fe:	83 e8 0c             	sub    $0xc,%eax
  103a01:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
  103a04:	ff 4d f4             	decl   -0xc(%ebp)
  103a07:	8b 55 f0             	mov    -0x10(%ebp),%edx
  103a0a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103a0d:	8b 48 08             	mov    0x8(%eax),%ecx
  103a10:	89 d0                	mov    %edx,%eax
  103a12:	29 c8                	sub    %ecx,%eax
  103a14:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103a17:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103a1a:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
  103a1d:	8b 45 88             	mov    -0x78(%ebp),%eax
  103a20:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  103a23:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103a26:	81 7d ec 80 be 11 00 	cmpl   $0x11be80,-0x14(%ebp)
  103a2d:	75 cc                	jne    1039fb <default_check+0x5c5>
    }
    assert(count == 0);
  103a2f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103a33:	74 24                	je     103a59 <default_check+0x623>
  103a35:	c7 44 24 0c 1e 6a 10 	movl   $0x106a1e,0xc(%esp)
  103a3c:	00 
  103a3d:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  103a44:	00 
  103a45:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
  103a4c:	00 
  103a4d:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  103a54:	e8 82 d2 ff ff       	call   100cdb <__panic>
    assert(total == 0);
  103a59:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103a5d:	74 24                	je     103a83 <default_check+0x64d>
  103a5f:	c7 44 24 0c 29 6a 10 	movl   $0x106a29,0xc(%esp)
  103a66:	00 
  103a67:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  103a6e:	00 
  103a6f:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
  103a76:	00 
  103a77:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  103a7e:	e8 58 d2 ff ff       	call   100cdb <__panic>
}
  103a83:	90                   	nop
  103a84:	89 ec                	mov    %ebp,%esp
  103a86:	5d                   	pop    %ebp
  103a87:	c3                   	ret    

00103a88 <page2ppn>:
page2ppn(struct Page *page) {
  103a88:	55                   	push   %ebp
  103a89:	89 e5                	mov    %esp,%ebp
    return page - pages;
  103a8b:	8b 15 a0 be 11 00    	mov    0x11bea0,%edx
  103a91:	8b 45 08             	mov    0x8(%ebp),%eax
  103a94:	29 d0                	sub    %edx,%eax
  103a96:	c1 f8 02             	sar    $0x2,%eax
  103a99:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  103a9f:	5d                   	pop    %ebp
  103aa0:	c3                   	ret    

00103aa1 <page2pa>:
page2pa(struct Page *page) {
  103aa1:	55                   	push   %ebp
  103aa2:	89 e5                	mov    %esp,%ebp
  103aa4:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  103aa7:	8b 45 08             	mov    0x8(%ebp),%eax
  103aaa:	89 04 24             	mov    %eax,(%esp)
  103aad:	e8 d6 ff ff ff       	call   103a88 <page2ppn>
  103ab2:	c1 e0 0c             	shl    $0xc,%eax
}
  103ab5:	89 ec                	mov    %ebp,%esp
  103ab7:	5d                   	pop    %ebp
  103ab8:	c3                   	ret    

00103ab9 <pa2page>:
pa2page(uintptr_t pa) {
  103ab9:	55                   	push   %ebp
  103aba:	89 e5                	mov    %esp,%ebp
  103abc:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
  103abf:	8b 45 08             	mov    0x8(%ebp),%eax
  103ac2:	c1 e8 0c             	shr    $0xc,%eax
  103ac5:	89 c2                	mov    %eax,%edx
  103ac7:	a1 a4 be 11 00       	mov    0x11bea4,%eax
  103acc:	39 c2                	cmp    %eax,%edx
  103ace:	72 1c                	jb     103aec <pa2page+0x33>
        panic("pa2page called with invalid pa");
  103ad0:	c7 44 24 08 64 6a 10 	movl   $0x106a64,0x8(%esp)
  103ad7:	00 
  103ad8:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  103adf:	00 
  103ae0:	c7 04 24 83 6a 10 00 	movl   $0x106a83,(%esp)
  103ae7:	e8 ef d1 ff ff       	call   100cdb <__panic>
    return &pages[PPN(pa)];
  103aec:	8b 0d a0 be 11 00    	mov    0x11bea0,%ecx
  103af2:	8b 45 08             	mov    0x8(%ebp),%eax
  103af5:	c1 e8 0c             	shr    $0xc,%eax
  103af8:	89 c2                	mov    %eax,%edx
  103afa:	89 d0                	mov    %edx,%eax
  103afc:	c1 e0 02             	shl    $0x2,%eax
  103aff:	01 d0                	add    %edx,%eax
  103b01:	c1 e0 02             	shl    $0x2,%eax
  103b04:	01 c8                	add    %ecx,%eax
}
  103b06:	89 ec                	mov    %ebp,%esp
  103b08:	5d                   	pop    %ebp
  103b09:	c3                   	ret    

00103b0a <page2kva>:
page2kva(struct Page *page) {
  103b0a:	55                   	push   %ebp
  103b0b:	89 e5                	mov    %esp,%ebp
  103b0d:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
  103b10:	8b 45 08             	mov    0x8(%ebp),%eax
  103b13:	89 04 24             	mov    %eax,(%esp)
  103b16:	e8 86 ff ff ff       	call   103aa1 <page2pa>
  103b1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103b1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103b21:	c1 e8 0c             	shr    $0xc,%eax
  103b24:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103b27:	a1 a4 be 11 00       	mov    0x11bea4,%eax
  103b2c:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  103b2f:	72 23                	jb     103b54 <page2kva+0x4a>
  103b31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103b34:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103b38:	c7 44 24 08 94 6a 10 	movl   $0x106a94,0x8(%esp)
  103b3f:	00 
  103b40:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  103b47:	00 
  103b48:	c7 04 24 83 6a 10 00 	movl   $0x106a83,(%esp)
  103b4f:	e8 87 d1 ff ff       	call   100cdb <__panic>
  103b54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103b57:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
  103b5c:	89 ec                	mov    %ebp,%esp
  103b5e:	5d                   	pop    %ebp
  103b5f:	c3                   	ret    

00103b60 <pte2page>:
pte2page(pte_t pte) {
  103b60:	55                   	push   %ebp
  103b61:	89 e5                	mov    %esp,%ebp
  103b63:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
  103b66:	8b 45 08             	mov    0x8(%ebp),%eax
  103b69:	83 e0 01             	and    $0x1,%eax
  103b6c:	85 c0                	test   %eax,%eax
  103b6e:	75 1c                	jne    103b8c <pte2page+0x2c>
        panic("pte2page called with invalid pte");
  103b70:	c7 44 24 08 b8 6a 10 	movl   $0x106ab8,0x8(%esp)
  103b77:	00 
  103b78:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  103b7f:	00 
  103b80:	c7 04 24 83 6a 10 00 	movl   $0x106a83,(%esp)
  103b87:	e8 4f d1 ff ff       	call   100cdb <__panic>
    return pa2page(PTE_ADDR(pte));
  103b8c:	8b 45 08             	mov    0x8(%ebp),%eax
  103b8f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103b94:	89 04 24             	mov    %eax,(%esp)
  103b97:	e8 1d ff ff ff       	call   103ab9 <pa2page>
}
  103b9c:	89 ec                	mov    %ebp,%esp
  103b9e:	5d                   	pop    %ebp
  103b9f:	c3                   	ret    

00103ba0 <pde2page>:
pde2page(pde_t pde) {
  103ba0:	55                   	push   %ebp
  103ba1:	89 e5                	mov    %esp,%ebp
  103ba3:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
  103ba6:	8b 45 08             	mov    0x8(%ebp),%eax
  103ba9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103bae:	89 04 24             	mov    %eax,(%esp)
  103bb1:	e8 03 ff ff ff       	call   103ab9 <pa2page>
}
  103bb6:	89 ec                	mov    %ebp,%esp
  103bb8:	5d                   	pop    %ebp
  103bb9:	c3                   	ret    

00103bba <page_ref>:
page_ref(struct Page *page) {
  103bba:	55                   	push   %ebp
  103bbb:	89 e5                	mov    %esp,%ebp
    return page->ref;
  103bbd:	8b 45 08             	mov    0x8(%ebp),%eax
  103bc0:	8b 00                	mov    (%eax),%eax
}
  103bc2:	5d                   	pop    %ebp
  103bc3:	c3                   	ret    

00103bc4 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
  103bc4:	55                   	push   %ebp
  103bc5:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  103bc7:	8b 45 08             	mov    0x8(%ebp),%eax
  103bca:	8b 55 0c             	mov    0xc(%ebp),%edx
  103bcd:	89 10                	mov    %edx,(%eax)
}
  103bcf:	90                   	nop
  103bd0:	5d                   	pop    %ebp
  103bd1:	c3                   	ret    

00103bd2 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
  103bd2:	55                   	push   %ebp
  103bd3:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
  103bd5:	8b 45 08             	mov    0x8(%ebp),%eax
  103bd8:	8b 00                	mov    (%eax),%eax
  103bda:	8d 50 01             	lea    0x1(%eax),%edx
  103bdd:	8b 45 08             	mov    0x8(%ebp),%eax
  103be0:	89 10                	mov    %edx,(%eax)
    return page->ref;
  103be2:	8b 45 08             	mov    0x8(%ebp),%eax
  103be5:	8b 00                	mov    (%eax),%eax
}
  103be7:	5d                   	pop    %ebp
  103be8:	c3                   	ret    

00103be9 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
  103be9:	55                   	push   %ebp
  103bea:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
  103bec:	8b 45 08             	mov    0x8(%ebp),%eax
  103bef:	8b 00                	mov    (%eax),%eax
  103bf1:	8d 50 ff             	lea    -0x1(%eax),%edx
  103bf4:	8b 45 08             	mov    0x8(%ebp),%eax
  103bf7:	89 10                	mov    %edx,(%eax)
    return page->ref;
  103bf9:	8b 45 08             	mov    0x8(%ebp),%eax
  103bfc:	8b 00                	mov    (%eax),%eax
}
  103bfe:	5d                   	pop    %ebp
  103bff:	c3                   	ret    

00103c00 <__intr_save>:
__intr_save(void) {
  103c00:	55                   	push   %ebp
  103c01:	89 e5                	mov    %esp,%ebp
  103c03:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  103c06:	9c                   	pushf  
  103c07:	58                   	pop    %eax
  103c08:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  103c0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  103c0e:	25 00 02 00 00       	and    $0x200,%eax
  103c13:	85 c0                	test   %eax,%eax
  103c15:	74 0c                	je     103c23 <__intr_save+0x23>
        intr_disable();
  103c17:	e8 18 db ff ff       	call   101734 <intr_disable>
        return 1;
  103c1c:	b8 01 00 00 00       	mov    $0x1,%eax
  103c21:	eb 05                	jmp    103c28 <__intr_save+0x28>
    return 0;
  103c23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103c28:	89 ec                	mov    %ebp,%esp
  103c2a:	5d                   	pop    %ebp
  103c2b:	c3                   	ret    

00103c2c <__intr_restore>:
__intr_restore(bool flag) {
  103c2c:	55                   	push   %ebp
  103c2d:	89 e5                	mov    %esp,%ebp
  103c2f:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  103c32:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  103c36:	74 05                	je     103c3d <__intr_restore+0x11>
        intr_enable();
  103c38:	e8 ef da ff ff       	call   10172c <intr_enable>
}
  103c3d:	90                   	nop
  103c3e:	89 ec                	mov    %ebp,%esp
  103c40:	5d                   	pop    %ebp
  103c41:	c3                   	ret    

00103c42 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  103c42:	55                   	push   %ebp
  103c43:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  103c45:	8b 45 08             	mov    0x8(%ebp),%eax
  103c48:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  103c4b:	b8 23 00 00 00       	mov    $0x23,%eax
  103c50:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  103c52:	b8 23 00 00 00       	mov    $0x23,%eax
  103c57:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  103c59:	b8 10 00 00 00       	mov    $0x10,%eax
  103c5e:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  103c60:	b8 10 00 00 00       	mov    $0x10,%eax
  103c65:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  103c67:	b8 10 00 00 00       	mov    $0x10,%eax
  103c6c:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  103c6e:	ea 75 3c 10 00 08 00 	ljmp   $0x8,$0x103c75
}
  103c75:	90                   	nop
  103c76:	5d                   	pop    %ebp
  103c77:	c3                   	ret    

00103c78 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
  103c78:	55                   	push   %ebp
  103c79:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
  103c7b:	8b 45 08             	mov    0x8(%ebp),%eax
  103c7e:	a3 c4 be 11 00       	mov    %eax,0x11bec4
}
  103c83:	90                   	nop
  103c84:	5d                   	pop    %ebp
  103c85:	c3                   	ret    

00103c86 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  103c86:	55                   	push   %ebp
  103c87:	89 e5                	mov    %esp,%ebp
  103c89:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
  103c8c:	b8 00 80 11 00       	mov    $0x118000,%eax
  103c91:	89 04 24             	mov    %eax,(%esp)
  103c94:	e8 df ff ff ff       	call   103c78 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
  103c99:	66 c7 05 c8 be 11 00 	movw   $0x10,0x11bec8
  103ca0:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
  103ca2:	66 c7 05 28 8a 11 00 	movw   $0x68,0x118a28
  103ca9:	68 00 
  103cab:	b8 c0 be 11 00       	mov    $0x11bec0,%eax
  103cb0:	0f b7 c0             	movzwl %ax,%eax
  103cb3:	66 a3 2a 8a 11 00    	mov    %ax,0x118a2a
  103cb9:	b8 c0 be 11 00       	mov    $0x11bec0,%eax
  103cbe:	c1 e8 10             	shr    $0x10,%eax
  103cc1:	a2 2c 8a 11 00       	mov    %al,0x118a2c
  103cc6:	0f b6 05 2d 8a 11 00 	movzbl 0x118a2d,%eax
  103ccd:	24 f0                	and    $0xf0,%al
  103ccf:	0c 09                	or     $0x9,%al
  103cd1:	a2 2d 8a 11 00       	mov    %al,0x118a2d
  103cd6:	0f b6 05 2d 8a 11 00 	movzbl 0x118a2d,%eax
  103cdd:	24 ef                	and    $0xef,%al
  103cdf:	a2 2d 8a 11 00       	mov    %al,0x118a2d
  103ce4:	0f b6 05 2d 8a 11 00 	movzbl 0x118a2d,%eax
  103ceb:	24 9f                	and    $0x9f,%al
  103ced:	a2 2d 8a 11 00       	mov    %al,0x118a2d
  103cf2:	0f b6 05 2d 8a 11 00 	movzbl 0x118a2d,%eax
  103cf9:	0c 80                	or     $0x80,%al
  103cfb:	a2 2d 8a 11 00       	mov    %al,0x118a2d
  103d00:	0f b6 05 2e 8a 11 00 	movzbl 0x118a2e,%eax
  103d07:	24 f0                	and    $0xf0,%al
  103d09:	a2 2e 8a 11 00       	mov    %al,0x118a2e
  103d0e:	0f b6 05 2e 8a 11 00 	movzbl 0x118a2e,%eax
  103d15:	24 ef                	and    $0xef,%al
  103d17:	a2 2e 8a 11 00       	mov    %al,0x118a2e
  103d1c:	0f b6 05 2e 8a 11 00 	movzbl 0x118a2e,%eax
  103d23:	24 df                	and    $0xdf,%al
  103d25:	a2 2e 8a 11 00       	mov    %al,0x118a2e
  103d2a:	0f b6 05 2e 8a 11 00 	movzbl 0x118a2e,%eax
  103d31:	0c 40                	or     $0x40,%al
  103d33:	a2 2e 8a 11 00       	mov    %al,0x118a2e
  103d38:	0f b6 05 2e 8a 11 00 	movzbl 0x118a2e,%eax
  103d3f:	24 7f                	and    $0x7f,%al
  103d41:	a2 2e 8a 11 00       	mov    %al,0x118a2e
  103d46:	b8 c0 be 11 00       	mov    $0x11bec0,%eax
  103d4b:	c1 e8 18             	shr    $0x18,%eax
  103d4e:	a2 2f 8a 11 00       	mov    %al,0x118a2f

    // reload all segment registers
    lgdt(&gdt_pd);
  103d53:	c7 04 24 30 8a 11 00 	movl   $0x118a30,(%esp)
  103d5a:	e8 e3 fe ff ff       	call   103c42 <lgdt>
  103d5f:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
  103d65:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  103d69:	0f 00 d8             	ltr    %ax
}
  103d6c:	90                   	nop

    // load the TSS
    ltr(GD_TSS);
}
  103d6d:	90                   	nop
  103d6e:	89 ec                	mov    %ebp,%esp
  103d70:	5d                   	pop    %ebp
  103d71:	c3                   	ret    

00103d72 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
  103d72:	55                   	push   %ebp
  103d73:	89 e5                	mov    %esp,%ebp
  103d75:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
  103d78:	c7 05 ac be 11 00 48 	movl   $0x106a48,0x11beac
  103d7f:	6a 10 00 
    cprintf("memory management: %s\n", pmm_manager->name);
  103d82:	a1 ac be 11 00       	mov    0x11beac,%eax
  103d87:	8b 00                	mov    (%eax),%eax
  103d89:	89 44 24 04          	mov    %eax,0x4(%esp)
  103d8d:	c7 04 24 e4 6a 10 00 	movl   $0x106ae4,(%esp)
  103d94:	e8 bd c5 ff ff       	call   100356 <cprintf>
    pmm_manager->init();
  103d99:	a1 ac be 11 00       	mov    0x11beac,%eax
  103d9e:	8b 40 04             	mov    0x4(%eax),%eax
  103da1:	ff d0                	call   *%eax
}
  103da3:	90                   	nop
  103da4:	89 ec                	mov    %ebp,%esp
  103da6:	5d                   	pop    %ebp
  103da7:	c3                   	ret    

00103da8 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
  103da8:	55                   	push   %ebp
  103da9:	89 e5                	mov    %esp,%ebp
  103dab:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
  103dae:	a1 ac be 11 00       	mov    0x11beac,%eax
  103db3:	8b 40 08             	mov    0x8(%eax),%eax
  103db6:	8b 55 0c             	mov    0xc(%ebp),%edx
  103db9:	89 54 24 04          	mov    %edx,0x4(%esp)
  103dbd:	8b 55 08             	mov    0x8(%ebp),%edx
  103dc0:	89 14 24             	mov    %edx,(%esp)
  103dc3:	ff d0                	call   *%eax
}
  103dc5:	90                   	nop
  103dc6:	89 ec                	mov    %ebp,%esp
  103dc8:	5d                   	pop    %ebp
  103dc9:	c3                   	ret    

00103dca <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
  103dca:	55                   	push   %ebp
  103dcb:	89 e5                	mov    %esp,%ebp
  103dcd:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
  103dd0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  103dd7:	e8 24 fe ff ff       	call   103c00 <__intr_save>
  103ddc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
  103ddf:	a1 ac be 11 00       	mov    0x11beac,%eax
  103de4:	8b 40 0c             	mov    0xc(%eax),%eax
  103de7:	8b 55 08             	mov    0x8(%ebp),%edx
  103dea:	89 14 24             	mov    %edx,(%esp)
  103ded:	ff d0                	call   *%eax
  103def:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
  103df2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103df5:	89 04 24             	mov    %eax,(%esp)
  103df8:	e8 2f fe ff ff       	call   103c2c <__intr_restore>
    return page;
  103dfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  103e00:	89 ec                	mov    %ebp,%esp
  103e02:	5d                   	pop    %ebp
  103e03:	c3                   	ret    

00103e04 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
  103e04:	55                   	push   %ebp
  103e05:	89 e5                	mov    %esp,%ebp
  103e07:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  103e0a:	e8 f1 fd ff ff       	call   103c00 <__intr_save>
  103e0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
  103e12:	a1 ac be 11 00       	mov    0x11beac,%eax
  103e17:	8b 40 10             	mov    0x10(%eax),%eax
  103e1a:	8b 55 0c             	mov    0xc(%ebp),%edx
  103e1d:	89 54 24 04          	mov    %edx,0x4(%esp)
  103e21:	8b 55 08             	mov    0x8(%ebp),%edx
  103e24:	89 14 24             	mov    %edx,(%esp)
  103e27:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
  103e29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103e2c:	89 04 24             	mov    %eax,(%esp)
  103e2f:	e8 f8 fd ff ff       	call   103c2c <__intr_restore>
}
  103e34:	90                   	nop
  103e35:	89 ec                	mov    %ebp,%esp
  103e37:	5d                   	pop    %ebp
  103e38:	c3                   	ret    

00103e39 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
  103e39:	55                   	push   %ebp
  103e3a:	89 e5                	mov    %esp,%ebp
  103e3c:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
  103e3f:	e8 bc fd ff ff       	call   103c00 <__intr_save>
  103e44:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
  103e47:	a1 ac be 11 00       	mov    0x11beac,%eax
  103e4c:	8b 40 14             	mov    0x14(%eax),%eax
  103e4f:	ff d0                	call   *%eax
  103e51:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
  103e54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103e57:	89 04 24             	mov    %eax,(%esp)
  103e5a:	e8 cd fd ff ff       	call   103c2c <__intr_restore>
    return ret;
  103e5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  103e62:	89 ec                	mov    %ebp,%esp
  103e64:	5d                   	pop    %ebp
  103e65:	c3                   	ret    

00103e66 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
  103e66:	55                   	push   %ebp
  103e67:	89 e5                	mov    %esp,%ebp
  103e69:	57                   	push   %edi
  103e6a:	56                   	push   %esi
  103e6b:	53                   	push   %ebx
  103e6c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
  103e72:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
  103e79:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  103e80:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
  103e87:	c7 04 24 fb 6a 10 00 	movl   $0x106afb,(%esp)
  103e8e:	e8 c3 c4 ff ff       	call   100356 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  103e93:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  103e9a:	e9 0c 01 00 00       	jmp    103fab <page_init+0x145>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  103e9f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103ea2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103ea5:	89 d0                	mov    %edx,%eax
  103ea7:	c1 e0 02             	shl    $0x2,%eax
  103eaa:	01 d0                	add    %edx,%eax
  103eac:	c1 e0 02             	shl    $0x2,%eax
  103eaf:	01 c8                	add    %ecx,%eax
  103eb1:	8b 50 08             	mov    0x8(%eax),%edx
  103eb4:	8b 40 04             	mov    0x4(%eax),%eax
  103eb7:	89 45 a0             	mov    %eax,-0x60(%ebp)
  103eba:	89 55 a4             	mov    %edx,-0x5c(%ebp)
  103ebd:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103ec0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103ec3:	89 d0                	mov    %edx,%eax
  103ec5:	c1 e0 02             	shl    $0x2,%eax
  103ec8:	01 d0                	add    %edx,%eax
  103eca:	c1 e0 02             	shl    $0x2,%eax
  103ecd:	01 c8                	add    %ecx,%eax
  103ecf:	8b 48 0c             	mov    0xc(%eax),%ecx
  103ed2:	8b 58 10             	mov    0x10(%eax),%ebx
  103ed5:	8b 45 a0             	mov    -0x60(%ebp),%eax
  103ed8:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  103edb:	01 c8                	add    %ecx,%eax
  103edd:	11 da                	adc    %ebx,%edx
  103edf:	89 45 98             	mov    %eax,-0x68(%ebp)
  103ee2:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
  103ee5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103ee8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103eeb:	89 d0                	mov    %edx,%eax
  103eed:	c1 e0 02             	shl    $0x2,%eax
  103ef0:	01 d0                	add    %edx,%eax
  103ef2:	c1 e0 02             	shl    $0x2,%eax
  103ef5:	01 c8                	add    %ecx,%eax
  103ef7:	83 c0 14             	add    $0x14,%eax
  103efa:	8b 00                	mov    (%eax),%eax
  103efc:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
  103f02:	8b 45 98             	mov    -0x68(%ebp),%eax
  103f05:	8b 55 9c             	mov    -0x64(%ebp),%edx
  103f08:	83 c0 ff             	add    $0xffffffff,%eax
  103f0b:	83 d2 ff             	adc    $0xffffffff,%edx
  103f0e:	89 c6                	mov    %eax,%esi
  103f10:	89 d7                	mov    %edx,%edi
  103f12:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103f15:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103f18:	89 d0                	mov    %edx,%eax
  103f1a:	c1 e0 02             	shl    $0x2,%eax
  103f1d:	01 d0                	add    %edx,%eax
  103f1f:	c1 e0 02             	shl    $0x2,%eax
  103f22:	01 c8                	add    %ecx,%eax
  103f24:	8b 48 0c             	mov    0xc(%eax),%ecx
  103f27:	8b 58 10             	mov    0x10(%eax),%ebx
  103f2a:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  103f30:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  103f34:	89 74 24 14          	mov    %esi,0x14(%esp)
  103f38:	89 7c 24 18          	mov    %edi,0x18(%esp)
  103f3c:	8b 45 a0             	mov    -0x60(%ebp),%eax
  103f3f:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  103f42:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103f46:	89 54 24 10          	mov    %edx,0x10(%esp)
  103f4a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  103f4e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  103f52:	c7 04 24 08 6b 10 00 	movl   $0x106b08,(%esp)
  103f59:	e8 f8 c3 ff ff       	call   100356 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
  103f5e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103f61:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103f64:	89 d0                	mov    %edx,%eax
  103f66:	c1 e0 02             	shl    $0x2,%eax
  103f69:	01 d0                	add    %edx,%eax
  103f6b:	c1 e0 02             	shl    $0x2,%eax
  103f6e:	01 c8                	add    %ecx,%eax
  103f70:	83 c0 14             	add    $0x14,%eax
  103f73:	8b 00                	mov    (%eax),%eax
  103f75:	83 f8 01             	cmp    $0x1,%eax
  103f78:	75 2e                	jne    103fa8 <page_init+0x142>
            if (maxpa < end && begin < KMEMSIZE) {
  103f7a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103f7d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103f80:	3b 45 98             	cmp    -0x68(%ebp),%eax
  103f83:	89 d0                	mov    %edx,%eax
  103f85:	1b 45 9c             	sbb    -0x64(%ebp),%eax
  103f88:	73 1e                	jae    103fa8 <page_init+0x142>
  103f8a:	ba ff ff ff 37       	mov    $0x37ffffff,%edx
  103f8f:	b8 00 00 00 00       	mov    $0x0,%eax
  103f94:	3b 55 a0             	cmp    -0x60(%ebp),%edx
  103f97:	1b 45 a4             	sbb    -0x5c(%ebp),%eax
  103f9a:	72 0c                	jb     103fa8 <page_init+0x142>
                maxpa = end;
  103f9c:	8b 45 98             	mov    -0x68(%ebp),%eax
  103f9f:	8b 55 9c             	mov    -0x64(%ebp),%edx
  103fa2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103fa5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
  103fa8:	ff 45 dc             	incl   -0x24(%ebp)
  103fab:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  103fae:	8b 00                	mov    (%eax),%eax
  103fb0:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  103fb3:	0f 8c e6 fe ff ff    	jl     103e9f <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
  103fb9:	ba 00 00 00 38       	mov    $0x38000000,%edx
  103fbe:	b8 00 00 00 00       	mov    $0x0,%eax
  103fc3:	3b 55 e0             	cmp    -0x20(%ebp),%edx
  103fc6:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
  103fc9:	73 0e                	jae    103fd9 <page_init+0x173>
        maxpa = KMEMSIZE;
  103fcb:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
  103fd2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
  103fd9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103fdc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103fdf:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  103fe3:	c1 ea 0c             	shr    $0xc,%edx
  103fe6:	a3 a4 be 11 00       	mov    %eax,0x11bea4
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
  103feb:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
  103ff2:	b8 2c bf 11 00       	mov    $0x11bf2c,%eax
  103ff7:	8d 50 ff             	lea    -0x1(%eax),%edx
  103ffa:	8b 45 c0             	mov    -0x40(%ebp),%eax
  103ffd:	01 d0                	add    %edx,%eax
  103fff:	89 45 bc             	mov    %eax,-0x44(%ebp)
  104002:	8b 45 bc             	mov    -0x44(%ebp),%eax
  104005:	ba 00 00 00 00       	mov    $0x0,%edx
  10400a:	f7 75 c0             	divl   -0x40(%ebp)
  10400d:	8b 45 bc             	mov    -0x44(%ebp),%eax
  104010:	29 d0                	sub    %edx,%eax
  104012:	a3 a0 be 11 00       	mov    %eax,0x11bea0

    for (i = 0; i < npage; i ++) {
  104017:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  10401e:	eb 2f                	jmp    10404f <page_init+0x1e9>
        SetPageReserved(pages + i);
  104020:	8b 0d a0 be 11 00    	mov    0x11bea0,%ecx
  104026:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104029:	89 d0                	mov    %edx,%eax
  10402b:	c1 e0 02             	shl    $0x2,%eax
  10402e:	01 d0                	add    %edx,%eax
  104030:	c1 e0 02             	shl    $0x2,%eax
  104033:	01 c8                	add    %ecx,%eax
  104035:	83 c0 04             	add    $0x4,%eax
  104038:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
  10403f:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104042:	8b 45 90             	mov    -0x70(%ebp),%eax
  104045:	8b 55 94             	mov    -0x6c(%ebp),%edx
  104048:	0f ab 10             	bts    %edx,(%eax)
}
  10404b:	90                   	nop
    for (i = 0; i < npage; i ++) {
  10404c:	ff 45 dc             	incl   -0x24(%ebp)
  10404f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104052:	a1 a4 be 11 00       	mov    0x11bea4,%eax
  104057:	39 c2                	cmp    %eax,%edx
  104059:	72 c5                	jb     104020 <page_init+0x1ba>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
  10405b:	8b 15 a4 be 11 00    	mov    0x11bea4,%edx
  104061:	89 d0                	mov    %edx,%eax
  104063:	c1 e0 02             	shl    $0x2,%eax
  104066:	01 d0                	add    %edx,%eax
  104068:	c1 e0 02             	shl    $0x2,%eax
  10406b:	89 c2                	mov    %eax,%edx
  10406d:	a1 a0 be 11 00       	mov    0x11bea0,%eax
  104072:	01 d0                	add    %edx,%eax
  104074:	89 45 b8             	mov    %eax,-0x48(%ebp)
  104077:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
  10407e:	77 23                	ja     1040a3 <page_init+0x23d>
  104080:	8b 45 b8             	mov    -0x48(%ebp),%eax
  104083:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104087:	c7 44 24 08 38 6b 10 	movl   $0x106b38,0x8(%esp)
  10408e:	00 
  10408f:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
  104096:	00 
  104097:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  10409e:	e8 38 cc ff ff       	call   100cdb <__panic>
  1040a3:	8b 45 b8             	mov    -0x48(%ebp),%eax
  1040a6:	05 00 00 00 40       	add    $0x40000000,%eax
  1040ab:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
  1040ae:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  1040b5:	e9 53 01 00 00       	jmp    10420d <page_init+0x3a7>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  1040ba:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  1040bd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1040c0:	89 d0                	mov    %edx,%eax
  1040c2:	c1 e0 02             	shl    $0x2,%eax
  1040c5:	01 d0                	add    %edx,%eax
  1040c7:	c1 e0 02             	shl    $0x2,%eax
  1040ca:	01 c8                	add    %ecx,%eax
  1040cc:	8b 50 08             	mov    0x8(%eax),%edx
  1040cf:	8b 40 04             	mov    0x4(%eax),%eax
  1040d2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1040d5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  1040d8:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  1040db:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1040de:	89 d0                	mov    %edx,%eax
  1040e0:	c1 e0 02             	shl    $0x2,%eax
  1040e3:	01 d0                	add    %edx,%eax
  1040e5:	c1 e0 02             	shl    $0x2,%eax
  1040e8:	01 c8                	add    %ecx,%eax
  1040ea:	8b 48 0c             	mov    0xc(%eax),%ecx
  1040ed:	8b 58 10             	mov    0x10(%eax),%ebx
  1040f0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1040f3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1040f6:	01 c8                	add    %ecx,%eax
  1040f8:	11 da                	adc    %ebx,%edx
  1040fa:	89 45 c8             	mov    %eax,-0x38(%ebp)
  1040fd:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
  104100:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104103:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104106:	89 d0                	mov    %edx,%eax
  104108:	c1 e0 02             	shl    $0x2,%eax
  10410b:	01 d0                	add    %edx,%eax
  10410d:	c1 e0 02             	shl    $0x2,%eax
  104110:	01 c8                	add    %ecx,%eax
  104112:	83 c0 14             	add    $0x14,%eax
  104115:	8b 00                	mov    (%eax),%eax
  104117:	83 f8 01             	cmp    $0x1,%eax
  10411a:	0f 85 ea 00 00 00    	jne    10420a <page_init+0x3a4>
            if (begin < freemem) {
  104120:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104123:	ba 00 00 00 00       	mov    $0x0,%edx
  104128:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  10412b:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  10412e:	19 d1                	sbb    %edx,%ecx
  104130:	73 0d                	jae    10413f <page_init+0x2d9>
                begin = freemem;
  104132:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104135:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104138:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
  10413f:	ba 00 00 00 38       	mov    $0x38000000,%edx
  104144:	b8 00 00 00 00       	mov    $0x0,%eax
  104149:	3b 55 c8             	cmp    -0x38(%ebp),%edx
  10414c:	1b 45 cc             	sbb    -0x34(%ebp),%eax
  10414f:	73 0e                	jae    10415f <page_init+0x2f9>
                end = KMEMSIZE;
  104151:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
  104158:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
  10415f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104162:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104165:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  104168:	89 d0                	mov    %edx,%eax
  10416a:	1b 45 cc             	sbb    -0x34(%ebp),%eax
  10416d:	0f 83 97 00 00 00    	jae    10420a <page_init+0x3a4>
                begin = ROUNDUP(begin, PGSIZE);
  104173:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
  10417a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  10417d:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104180:	01 d0                	add    %edx,%eax
  104182:	48                   	dec    %eax
  104183:	89 45 ac             	mov    %eax,-0x54(%ebp)
  104186:	8b 45 ac             	mov    -0x54(%ebp),%eax
  104189:	ba 00 00 00 00       	mov    $0x0,%edx
  10418e:	f7 75 b0             	divl   -0x50(%ebp)
  104191:	8b 45 ac             	mov    -0x54(%ebp),%eax
  104194:	29 d0                	sub    %edx,%eax
  104196:	ba 00 00 00 00       	mov    $0x0,%edx
  10419b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10419e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
  1041a1:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1041a4:	89 45 a8             	mov    %eax,-0x58(%ebp)
  1041a7:	8b 45 a8             	mov    -0x58(%ebp),%eax
  1041aa:	ba 00 00 00 00       	mov    $0x0,%edx
  1041af:	89 c7                	mov    %eax,%edi
  1041b1:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  1041b7:	89 7d 80             	mov    %edi,-0x80(%ebp)
  1041ba:	89 d0                	mov    %edx,%eax
  1041bc:	83 e0 00             	and    $0x0,%eax
  1041bf:	89 45 84             	mov    %eax,-0x7c(%ebp)
  1041c2:	8b 45 80             	mov    -0x80(%ebp),%eax
  1041c5:	8b 55 84             	mov    -0x7c(%ebp),%edx
  1041c8:	89 45 c8             	mov    %eax,-0x38(%ebp)
  1041cb:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
  1041ce:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1041d1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1041d4:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  1041d7:	89 d0                	mov    %edx,%eax
  1041d9:	1b 45 cc             	sbb    -0x34(%ebp),%eax
  1041dc:	73 2c                	jae    10420a <page_init+0x3a4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
  1041de:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1041e1:	8b 55 cc             	mov    -0x34(%ebp),%edx
  1041e4:	2b 45 d0             	sub    -0x30(%ebp),%eax
  1041e7:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
  1041ea:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  1041ee:	c1 ea 0c             	shr    $0xc,%edx
  1041f1:	89 c3                	mov    %eax,%ebx
  1041f3:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1041f6:	89 04 24             	mov    %eax,(%esp)
  1041f9:	e8 bb f8 ff ff       	call   103ab9 <pa2page>
  1041fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  104202:	89 04 24             	mov    %eax,(%esp)
  104205:	e8 9e fb ff ff       	call   103da8 <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
  10420a:	ff 45 dc             	incl   -0x24(%ebp)
  10420d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104210:	8b 00                	mov    (%eax),%eax
  104212:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  104215:	0f 8c 9f fe ff ff    	jl     1040ba <page_init+0x254>
                }
            }
        }
    }
}
  10421b:	90                   	nop
  10421c:	90                   	nop
  10421d:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  104223:	5b                   	pop    %ebx
  104224:	5e                   	pop    %esi
  104225:	5f                   	pop    %edi
  104226:	5d                   	pop    %ebp
  104227:	c3                   	ret    

00104228 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
  104228:	55                   	push   %ebp
  104229:	89 e5                	mov    %esp,%ebp
  10422b:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
  10422e:	8b 45 0c             	mov    0xc(%ebp),%eax
  104231:	33 45 14             	xor    0x14(%ebp),%eax
  104234:	25 ff 0f 00 00       	and    $0xfff,%eax
  104239:	85 c0                	test   %eax,%eax
  10423b:	74 24                	je     104261 <boot_map_segment+0x39>
  10423d:	c7 44 24 0c 6a 6b 10 	movl   $0x106b6a,0xc(%esp)
  104244:	00 
  104245:	c7 44 24 08 81 6b 10 	movl   $0x106b81,0x8(%esp)
  10424c:	00 
  10424d:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
  104254:	00 
  104255:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  10425c:	e8 7a ca ff ff       	call   100cdb <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
  104261:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  104268:	8b 45 0c             	mov    0xc(%ebp),%eax
  10426b:	25 ff 0f 00 00       	and    $0xfff,%eax
  104270:	89 c2                	mov    %eax,%edx
  104272:	8b 45 10             	mov    0x10(%ebp),%eax
  104275:	01 c2                	add    %eax,%edx
  104277:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10427a:	01 d0                	add    %edx,%eax
  10427c:	48                   	dec    %eax
  10427d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104280:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104283:	ba 00 00 00 00       	mov    $0x0,%edx
  104288:	f7 75 f0             	divl   -0x10(%ebp)
  10428b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10428e:	29 d0                	sub    %edx,%eax
  104290:	c1 e8 0c             	shr    $0xc,%eax
  104293:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
  104296:	8b 45 0c             	mov    0xc(%ebp),%eax
  104299:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10429c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10429f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1042a4:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
  1042a7:	8b 45 14             	mov    0x14(%ebp),%eax
  1042aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1042ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1042b0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1042b5:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  1042b8:	eb 68                	jmp    104322 <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
  1042ba:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  1042c1:	00 
  1042c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1042c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1042c9:	8b 45 08             	mov    0x8(%ebp),%eax
  1042cc:	89 04 24             	mov    %eax,(%esp)
  1042cf:	e8 88 01 00 00       	call   10445c <get_pte>
  1042d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
  1042d7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  1042db:	75 24                	jne    104301 <boot_map_segment+0xd9>
  1042dd:	c7 44 24 0c 96 6b 10 	movl   $0x106b96,0xc(%esp)
  1042e4:	00 
  1042e5:	c7 44 24 08 81 6b 10 	movl   $0x106b81,0x8(%esp)
  1042ec:	00 
  1042ed:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
  1042f4:	00 
  1042f5:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  1042fc:	e8 da c9 ff ff       	call   100cdb <__panic>
        *ptep = pa | PTE_P | perm;
  104301:	8b 45 14             	mov    0x14(%ebp),%eax
  104304:	0b 45 18             	or     0x18(%ebp),%eax
  104307:	83 c8 01             	or     $0x1,%eax
  10430a:	89 c2                	mov    %eax,%edx
  10430c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10430f:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  104311:	ff 4d f4             	decl   -0xc(%ebp)
  104314:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
  10431b:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  104322:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104326:	75 92                	jne    1042ba <boot_map_segment+0x92>
    }
}
  104328:	90                   	nop
  104329:	90                   	nop
  10432a:	89 ec                	mov    %ebp,%esp
  10432c:	5d                   	pop    %ebp
  10432d:	c3                   	ret    

0010432e <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
  10432e:	55                   	push   %ebp
  10432f:	89 e5                	mov    %esp,%ebp
  104331:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
  104334:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10433b:	e8 8a fa ff ff       	call   103dca <alloc_pages>
  104340:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
  104343:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104347:	75 1c                	jne    104365 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
  104349:	c7 44 24 08 a3 6b 10 	movl   $0x106ba3,0x8(%esp)
  104350:	00 
  104351:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
  104358:	00 
  104359:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  104360:	e8 76 c9 ff ff       	call   100cdb <__panic>
    }
    return page2kva(p);
  104365:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104368:	89 04 24             	mov    %eax,(%esp)
  10436b:	e8 9a f7 ff ff       	call   103b0a <page2kva>
}
  104370:	89 ec                	mov    %ebp,%esp
  104372:	5d                   	pop    %ebp
  104373:	c3                   	ret    

00104374 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
  104374:	55                   	push   %ebp
  104375:	89 e5                	mov    %esp,%ebp
  104377:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
  10437a:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  10437f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104382:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  104389:	77 23                	ja     1043ae <pmm_init+0x3a>
  10438b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10438e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104392:	c7 44 24 08 38 6b 10 	movl   $0x106b38,0x8(%esp)
  104399:	00 
  10439a:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
  1043a1:	00 
  1043a2:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  1043a9:	e8 2d c9 ff ff       	call   100cdb <__panic>
  1043ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1043b1:	05 00 00 00 40       	add    $0x40000000,%eax
  1043b6:	a3 a8 be 11 00       	mov    %eax,0x11bea8
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
  1043bb:	e8 b2 f9 ff ff       	call   103d72 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
  1043c0:	e8 a1 fa ff ff       	call   103e66 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
  1043c5:	e8 ed 03 00 00       	call   1047b7 <check_alloc_page>

    check_pgdir();
  1043ca:	e8 09 04 00 00       	call   1047d8 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
  1043cf:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  1043d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1043d7:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  1043de:	77 23                	ja     104403 <pmm_init+0x8f>
  1043e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1043e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1043e7:	c7 44 24 08 38 6b 10 	movl   $0x106b38,0x8(%esp)
  1043ee:	00 
  1043ef:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
  1043f6:	00 
  1043f7:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  1043fe:	e8 d8 c8 ff ff       	call   100cdb <__panic>
  104403:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104406:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
  10440c:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104411:	05 ac 0f 00 00       	add    $0xfac,%eax
  104416:	83 ca 03             	or     $0x3,%edx
  104419:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
  10441b:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104420:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
  104427:	00 
  104428:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  10442f:	00 
  104430:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
  104437:	38 
  104438:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
  10443f:	c0 
  104440:	89 04 24             	mov    %eax,(%esp)
  104443:	e8 e0 fd ff ff       	call   104228 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
  104448:	e8 39 f8 ff ff       	call   103c86 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
  10444d:	e8 24 0a 00 00       	call   104e76 <check_boot_pgdir>

    print_pgdir();
  104452:	e8 a1 0e 00 00       	call   1052f8 <print_pgdir>

}
  104457:	90                   	nop
  104458:	89 ec                	mov    %ebp,%esp
  10445a:	5d                   	pop    %ebp
  10445b:	c3                   	ret    

0010445c <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
  10445c:	55                   	push   %ebp
  10445d:	89 e5                	mov    %esp,%ebp
  10445f:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)];
  104462:	8b 45 0c             	mov    0xc(%ebp),%eax
  104465:	c1 e8 16             	shr    $0x16,%eax
  104468:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  10446f:	8b 45 08             	mov    0x8(%ebp),%eax
  104472:	01 d0                	add    %edx,%eax
  104474:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {
  104477:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10447a:	8b 00                	mov    (%eax),%eax
  10447c:	83 e0 01             	and    $0x1,%eax
  10447f:	85 c0                	test   %eax,%eax
  104481:	0f 85 af 00 00 00    	jne    104536 <get_pte+0xda>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
  104487:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10448b:	74 15                	je     1044a2 <get_pte+0x46>
  10448d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104494:	e8 31 f9 ff ff       	call   103dca <alloc_pages>
  104499:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10449c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1044a0:	75 0a                	jne    1044ac <get_pte+0x50>
            return NULL;
  1044a2:	b8 00 00 00 00       	mov    $0x0,%eax
  1044a7:	e9 e7 00 00 00       	jmp    104593 <get_pte+0x137>
        }
        set_page_ref(page, 1);
  1044ac:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1044b3:	00 
  1044b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1044b7:	89 04 24             	mov    %eax,(%esp)
  1044ba:	e8 05 f7 ff ff       	call   103bc4 <set_page_ref>
        uintptr_t pa = page2pa(page);
  1044bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1044c2:	89 04 24             	mov    %eax,(%esp)
  1044c5:	e8 d7 f5 ff ff       	call   103aa1 <page2pa>
  1044ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
  1044cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1044d0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1044d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1044d6:	c1 e8 0c             	shr    $0xc,%eax
  1044d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1044dc:	a1 a4 be 11 00       	mov    0x11bea4,%eax
  1044e1:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  1044e4:	72 23                	jb     104509 <get_pte+0xad>
  1044e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1044e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1044ed:	c7 44 24 08 94 6a 10 	movl   $0x106a94,0x8(%esp)
  1044f4:	00 
  1044f5:	c7 44 24 04 72 01 00 	movl   $0x172,0x4(%esp)
  1044fc:	00 
  1044fd:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  104504:	e8 d2 c7 ff ff       	call   100cdb <__panic>
  104509:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10450c:	2d 00 00 00 40       	sub    $0x40000000,%eax
  104511:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  104518:	00 
  104519:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104520:	00 
  104521:	89 04 24             	mov    %eax,(%esp)
  104524:	e8 d4 18 00 00       	call   105dfd <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P;
  104529:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10452c:	83 c8 07             	or     $0x7,%eax
  10452f:	89 c2                	mov    %eax,%edx
  104531:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104534:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
  104536:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104539:	8b 00                	mov    (%eax),%eax
  10453b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104540:	89 45 e0             	mov    %eax,-0x20(%ebp)
  104543:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104546:	c1 e8 0c             	shr    $0xc,%eax
  104549:	89 45 dc             	mov    %eax,-0x24(%ebp)
  10454c:	a1 a4 be 11 00       	mov    0x11bea4,%eax
  104551:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  104554:	72 23                	jb     104579 <get_pte+0x11d>
  104556:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104559:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10455d:	c7 44 24 08 94 6a 10 	movl   $0x106a94,0x8(%esp)
  104564:	00 
  104565:	c7 44 24 04 75 01 00 	movl   $0x175,0x4(%esp)
  10456c:	00 
  10456d:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  104574:	e8 62 c7 ff ff       	call   100cdb <__panic>
  104579:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10457c:	2d 00 00 00 40       	sub    $0x40000000,%eax
  104581:	89 c2                	mov    %eax,%edx
  104583:	8b 45 0c             	mov    0xc(%ebp),%eax
  104586:	c1 e8 0c             	shr    $0xc,%eax
  104589:	25 ff 03 00 00       	and    $0x3ff,%eax
  10458e:	c1 e0 02             	shl    $0x2,%eax
  104591:	01 d0                	add    %edx,%eax
}
  104593:	89 ec                	mov    %ebp,%esp
  104595:	5d                   	pop    %ebp
  104596:	c3                   	ret    

00104597 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
  104597:	55                   	push   %ebp
  104598:	89 e5                	mov    %esp,%ebp
  10459a:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  10459d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1045a4:	00 
  1045a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1045a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  1045ac:	8b 45 08             	mov    0x8(%ebp),%eax
  1045af:	89 04 24             	mov    %eax,(%esp)
  1045b2:	e8 a5 fe ff ff       	call   10445c <get_pte>
  1045b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
  1045ba:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1045be:	74 08                	je     1045c8 <get_page+0x31>
        *ptep_store = ptep;
  1045c0:	8b 45 10             	mov    0x10(%ebp),%eax
  1045c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1045c6:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
  1045c8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1045cc:	74 1b                	je     1045e9 <get_page+0x52>
  1045ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045d1:	8b 00                	mov    (%eax),%eax
  1045d3:	83 e0 01             	and    $0x1,%eax
  1045d6:	85 c0                	test   %eax,%eax
  1045d8:	74 0f                	je     1045e9 <get_page+0x52>
        return pte2page(*ptep);
  1045da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045dd:	8b 00                	mov    (%eax),%eax
  1045df:	89 04 24             	mov    %eax,(%esp)
  1045e2:	e8 79 f5 ff ff       	call   103b60 <pte2page>
  1045e7:	eb 05                	jmp    1045ee <get_page+0x57>
    }
    return NULL;
  1045e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1045ee:	89 ec                	mov    %ebp,%esp
  1045f0:	5d                   	pop    %ebp
  1045f1:	c3                   	ret    

001045f2 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
  1045f2:	55                   	push   %ebp
  1045f3:	89 e5                	mov    %esp,%ebp
  1045f5:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {
  1045f8:	8b 45 10             	mov    0x10(%ebp),%eax
  1045fb:	8b 00                	mov    (%eax),%eax
  1045fd:	83 e0 01             	and    $0x1,%eax
  104600:	85 c0                	test   %eax,%eax
  104602:	74 4d                	je     104651 <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);
  104604:	8b 45 10             	mov    0x10(%ebp),%eax
  104607:	8b 00                	mov    (%eax),%eax
  104609:	89 04 24             	mov    %eax,(%esp)
  10460c:	e8 4f f5 ff ff       	call   103b60 <pte2page>
  104611:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
  104614:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104617:	89 04 24             	mov    %eax,(%esp)
  10461a:	e8 ca f5 ff ff       	call   103be9 <page_ref_dec>
  10461f:	85 c0                	test   %eax,%eax
  104621:	75 13                	jne    104636 <page_remove_pte+0x44>
            free_page(page);
  104623:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10462a:	00 
  10462b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10462e:	89 04 24             	mov    %eax,(%esp)
  104631:	e8 ce f7 ff ff       	call   103e04 <free_pages>
        }
        *ptep = 0;
  104636:	8b 45 10             	mov    0x10(%ebp),%eax
  104639:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
  10463f:	8b 45 0c             	mov    0xc(%ebp),%eax
  104642:	89 44 24 04          	mov    %eax,0x4(%esp)
  104646:	8b 45 08             	mov    0x8(%ebp),%eax
  104649:	89 04 24             	mov    %eax,(%esp)
  10464c:	e8 07 01 00 00       	call   104758 <tlb_invalidate>
    }
}
  104651:	90                   	nop
  104652:	89 ec                	mov    %ebp,%esp
  104654:	5d                   	pop    %ebp
  104655:	c3                   	ret    

00104656 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
  104656:	55                   	push   %ebp
  104657:	89 e5                	mov    %esp,%ebp
  104659:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  10465c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104663:	00 
  104664:	8b 45 0c             	mov    0xc(%ebp),%eax
  104667:	89 44 24 04          	mov    %eax,0x4(%esp)
  10466b:	8b 45 08             	mov    0x8(%ebp),%eax
  10466e:	89 04 24             	mov    %eax,(%esp)
  104671:	e8 e6 fd ff ff       	call   10445c <get_pte>
  104676:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
  104679:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10467d:	74 19                	je     104698 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
  10467f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104682:	89 44 24 08          	mov    %eax,0x8(%esp)
  104686:	8b 45 0c             	mov    0xc(%ebp),%eax
  104689:	89 44 24 04          	mov    %eax,0x4(%esp)
  10468d:	8b 45 08             	mov    0x8(%ebp),%eax
  104690:	89 04 24             	mov    %eax,(%esp)
  104693:	e8 5a ff ff ff       	call   1045f2 <page_remove_pte>
    }
}
  104698:	90                   	nop
  104699:	89 ec                	mov    %ebp,%esp
  10469b:	5d                   	pop    %ebp
  10469c:	c3                   	ret    

0010469d <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
  10469d:	55                   	push   %ebp
  10469e:	89 e5                	mov    %esp,%ebp
  1046a0:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
  1046a3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  1046aa:	00 
  1046ab:	8b 45 10             	mov    0x10(%ebp),%eax
  1046ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  1046b2:	8b 45 08             	mov    0x8(%ebp),%eax
  1046b5:	89 04 24             	mov    %eax,(%esp)
  1046b8:	e8 9f fd ff ff       	call   10445c <get_pte>
  1046bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
  1046c0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1046c4:	75 0a                	jne    1046d0 <page_insert+0x33>
        return -E_NO_MEM;
  1046c6:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  1046cb:	e9 84 00 00 00       	jmp    104754 <page_insert+0xb7>
    }
    page_ref_inc(page);
  1046d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1046d3:	89 04 24             	mov    %eax,(%esp)
  1046d6:	e8 f7 f4 ff ff       	call   103bd2 <page_ref_inc>
    if (*ptep & PTE_P) {
  1046db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046de:	8b 00                	mov    (%eax),%eax
  1046e0:	83 e0 01             	and    $0x1,%eax
  1046e3:	85 c0                	test   %eax,%eax
  1046e5:	74 3e                	je     104725 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
  1046e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046ea:	8b 00                	mov    (%eax),%eax
  1046ec:	89 04 24             	mov    %eax,(%esp)
  1046ef:	e8 6c f4 ff ff       	call   103b60 <pte2page>
  1046f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
  1046f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1046fa:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1046fd:	75 0d                	jne    10470c <page_insert+0x6f>
            page_ref_dec(page);
  1046ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  104702:	89 04 24             	mov    %eax,(%esp)
  104705:	e8 df f4 ff ff       	call   103be9 <page_ref_dec>
  10470a:	eb 19                	jmp    104725 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
  10470c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10470f:	89 44 24 08          	mov    %eax,0x8(%esp)
  104713:	8b 45 10             	mov    0x10(%ebp),%eax
  104716:	89 44 24 04          	mov    %eax,0x4(%esp)
  10471a:	8b 45 08             	mov    0x8(%ebp),%eax
  10471d:	89 04 24             	mov    %eax,(%esp)
  104720:	e8 cd fe ff ff       	call   1045f2 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
  104725:	8b 45 0c             	mov    0xc(%ebp),%eax
  104728:	89 04 24             	mov    %eax,(%esp)
  10472b:	e8 71 f3 ff ff       	call   103aa1 <page2pa>
  104730:	0b 45 14             	or     0x14(%ebp),%eax
  104733:	83 c8 01             	or     $0x1,%eax
  104736:	89 c2                	mov    %eax,%edx
  104738:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10473b:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
  10473d:	8b 45 10             	mov    0x10(%ebp),%eax
  104740:	89 44 24 04          	mov    %eax,0x4(%esp)
  104744:	8b 45 08             	mov    0x8(%ebp),%eax
  104747:	89 04 24             	mov    %eax,(%esp)
  10474a:	e8 09 00 00 00       	call   104758 <tlb_invalidate>
    return 0;
  10474f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  104754:	89 ec                	mov    %ebp,%esp
  104756:	5d                   	pop    %ebp
  104757:	c3                   	ret    

00104758 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
  104758:	55                   	push   %ebp
  104759:	89 e5                	mov    %esp,%ebp
  10475b:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
  10475e:	0f 20 d8             	mov    %cr3,%eax
  104761:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
  104764:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
  104767:	8b 45 08             	mov    0x8(%ebp),%eax
  10476a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10476d:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  104774:	77 23                	ja     104799 <tlb_invalidate+0x41>
  104776:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104779:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10477d:	c7 44 24 08 38 6b 10 	movl   $0x106b38,0x8(%esp)
  104784:	00 
  104785:	c7 44 24 04 d7 01 00 	movl   $0x1d7,0x4(%esp)
  10478c:	00 
  10478d:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  104794:	e8 42 c5 ff ff       	call   100cdb <__panic>
  104799:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10479c:	05 00 00 00 40       	add    $0x40000000,%eax
  1047a1:	39 d0                	cmp    %edx,%eax
  1047a3:	75 0d                	jne    1047b2 <tlb_invalidate+0x5a>
        invlpg((void *)la);
  1047a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1047a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
  1047ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1047ae:	0f 01 38             	invlpg (%eax)
}
  1047b1:	90                   	nop
    }
}
  1047b2:	90                   	nop
  1047b3:	89 ec                	mov    %ebp,%esp
  1047b5:	5d                   	pop    %ebp
  1047b6:	c3                   	ret    

001047b7 <check_alloc_page>:

static void
check_alloc_page(void) {
  1047b7:	55                   	push   %ebp
  1047b8:	89 e5                	mov    %esp,%ebp
  1047ba:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
  1047bd:	a1 ac be 11 00       	mov    0x11beac,%eax
  1047c2:	8b 40 18             	mov    0x18(%eax),%eax
  1047c5:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
  1047c7:	c7 04 24 bc 6b 10 00 	movl   $0x106bbc,(%esp)
  1047ce:	e8 83 bb ff ff       	call   100356 <cprintf>
}
  1047d3:	90                   	nop
  1047d4:	89 ec                	mov    %ebp,%esp
  1047d6:	5d                   	pop    %ebp
  1047d7:	c3                   	ret    

001047d8 <check_pgdir>:

static void
check_pgdir(void) {
  1047d8:	55                   	push   %ebp
  1047d9:	89 e5                	mov    %esp,%ebp
  1047db:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
  1047de:	a1 a4 be 11 00       	mov    0x11bea4,%eax
  1047e3:	3d 00 80 03 00       	cmp    $0x38000,%eax
  1047e8:	76 24                	jbe    10480e <check_pgdir+0x36>
  1047ea:	c7 44 24 0c db 6b 10 	movl   $0x106bdb,0xc(%esp)
  1047f1:	00 
  1047f2:	c7 44 24 08 81 6b 10 	movl   $0x106b81,0x8(%esp)
  1047f9:	00 
  1047fa:	c7 44 24 04 e4 01 00 	movl   $0x1e4,0x4(%esp)
  104801:	00 
  104802:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  104809:	e8 cd c4 ff ff       	call   100cdb <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
  10480e:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104813:	85 c0                	test   %eax,%eax
  104815:	74 0e                	je     104825 <check_pgdir+0x4d>
  104817:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  10481c:	25 ff 0f 00 00       	and    $0xfff,%eax
  104821:	85 c0                	test   %eax,%eax
  104823:	74 24                	je     104849 <check_pgdir+0x71>
  104825:	c7 44 24 0c f8 6b 10 	movl   $0x106bf8,0xc(%esp)
  10482c:	00 
  10482d:	c7 44 24 08 81 6b 10 	movl   $0x106b81,0x8(%esp)
  104834:	00 
  104835:	c7 44 24 04 e5 01 00 	movl   $0x1e5,0x4(%esp)
  10483c:	00 
  10483d:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  104844:	e8 92 c4 ff ff       	call   100cdb <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
  104849:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  10484e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104855:	00 
  104856:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10485d:	00 
  10485e:	89 04 24             	mov    %eax,(%esp)
  104861:	e8 31 fd ff ff       	call   104597 <get_page>
  104866:	85 c0                	test   %eax,%eax
  104868:	74 24                	je     10488e <check_pgdir+0xb6>
  10486a:	c7 44 24 0c 30 6c 10 	movl   $0x106c30,0xc(%esp)
  104871:	00 
  104872:	c7 44 24 08 81 6b 10 	movl   $0x106b81,0x8(%esp)
  104879:	00 
  10487a:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
  104881:	00 
  104882:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  104889:	e8 4d c4 ff ff       	call   100cdb <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
  10488e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104895:	e8 30 f5 ff ff       	call   103dca <alloc_pages>
  10489a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
  10489d:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  1048a2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  1048a9:	00 
  1048aa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1048b1:	00 
  1048b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1048b5:	89 54 24 04          	mov    %edx,0x4(%esp)
  1048b9:	89 04 24             	mov    %eax,(%esp)
  1048bc:	e8 dc fd ff ff       	call   10469d <page_insert>
  1048c1:	85 c0                	test   %eax,%eax
  1048c3:	74 24                	je     1048e9 <check_pgdir+0x111>
  1048c5:	c7 44 24 0c 58 6c 10 	movl   $0x106c58,0xc(%esp)
  1048cc:	00 
  1048cd:	c7 44 24 08 81 6b 10 	movl   $0x106b81,0x8(%esp)
  1048d4:	00 
  1048d5:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
  1048dc:	00 
  1048dd:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  1048e4:	e8 f2 c3 ff ff       	call   100cdb <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
  1048e9:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  1048ee:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1048f5:	00 
  1048f6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1048fd:	00 
  1048fe:	89 04 24             	mov    %eax,(%esp)
  104901:	e8 56 fb ff ff       	call   10445c <get_pte>
  104906:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104909:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10490d:	75 24                	jne    104933 <check_pgdir+0x15b>
  10490f:	c7 44 24 0c 84 6c 10 	movl   $0x106c84,0xc(%esp)
  104916:	00 
  104917:	c7 44 24 08 81 6b 10 	movl   $0x106b81,0x8(%esp)
  10491e:	00 
  10491f:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
  104926:	00 
  104927:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  10492e:	e8 a8 c3 ff ff       	call   100cdb <__panic>
    assert(pte2page(*ptep) == p1);
  104933:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104936:	8b 00                	mov    (%eax),%eax
  104938:	89 04 24             	mov    %eax,(%esp)
  10493b:	e8 20 f2 ff ff       	call   103b60 <pte2page>
  104940:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  104943:	74 24                	je     104969 <check_pgdir+0x191>
  104945:	c7 44 24 0c b1 6c 10 	movl   $0x106cb1,0xc(%esp)
  10494c:	00 
  10494d:	c7 44 24 08 81 6b 10 	movl   $0x106b81,0x8(%esp)
  104954:	00 
  104955:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
  10495c:	00 
  10495d:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  104964:	e8 72 c3 ff ff       	call   100cdb <__panic>
    assert(page_ref(p1) == 1);
  104969:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10496c:	89 04 24             	mov    %eax,(%esp)
  10496f:	e8 46 f2 ff ff       	call   103bba <page_ref>
  104974:	83 f8 01             	cmp    $0x1,%eax
  104977:	74 24                	je     10499d <check_pgdir+0x1c5>
  104979:	c7 44 24 0c c7 6c 10 	movl   $0x106cc7,0xc(%esp)
  104980:	00 
  104981:	c7 44 24 08 81 6b 10 	movl   $0x106b81,0x8(%esp)
  104988:	00 
  104989:	c7 44 24 04 ef 01 00 	movl   $0x1ef,0x4(%esp)
  104990:	00 
  104991:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  104998:	e8 3e c3 ff ff       	call   100cdb <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
  10499d:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  1049a2:	8b 00                	mov    (%eax),%eax
  1049a4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1049a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1049ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1049af:	c1 e8 0c             	shr    $0xc,%eax
  1049b2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1049b5:	a1 a4 be 11 00       	mov    0x11bea4,%eax
  1049ba:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  1049bd:	72 23                	jb     1049e2 <check_pgdir+0x20a>
  1049bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1049c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1049c6:	c7 44 24 08 94 6a 10 	movl   $0x106a94,0x8(%esp)
  1049cd:	00 
  1049ce:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
  1049d5:	00 
  1049d6:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  1049dd:	e8 f9 c2 ff ff       	call   100cdb <__panic>
  1049e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1049e5:	2d 00 00 00 40       	sub    $0x40000000,%eax
  1049ea:	83 c0 04             	add    $0x4,%eax
  1049ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
  1049f0:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  1049f5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1049fc:	00 
  1049fd:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104a04:	00 
  104a05:	89 04 24             	mov    %eax,(%esp)
  104a08:	e8 4f fa ff ff       	call   10445c <get_pte>
  104a0d:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  104a10:	74 24                	je     104a36 <check_pgdir+0x25e>
  104a12:	c7 44 24 0c dc 6c 10 	movl   $0x106cdc,0xc(%esp)
  104a19:	00 
  104a1a:	c7 44 24 08 81 6b 10 	movl   $0x106b81,0x8(%esp)
  104a21:	00 
  104a22:	c7 44 24 04 f2 01 00 	movl   $0x1f2,0x4(%esp)
  104a29:	00 
  104a2a:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  104a31:	e8 a5 c2 ff ff       	call   100cdb <__panic>

    p2 = alloc_page();
  104a36:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104a3d:	e8 88 f3 ff ff       	call   103dca <alloc_pages>
  104a42:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
  104a45:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104a4a:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  104a51:	00 
  104a52:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  104a59:	00 
  104a5a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  104a5d:	89 54 24 04          	mov    %edx,0x4(%esp)
  104a61:	89 04 24             	mov    %eax,(%esp)
  104a64:	e8 34 fc ff ff       	call   10469d <page_insert>
  104a69:	85 c0                	test   %eax,%eax
  104a6b:	74 24                	je     104a91 <check_pgdir+0x2b9>
  104a6d:	c7 44 24 0c 04 6d 10 	movl   $0x106d04,0xc(%esp)
  104a74:	00 
  104a75:	c7 44 24 08 81 6b 10 	movl   $0x106b81,0x8(%esp)
  104a7c:	00 
  104a7d:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
  104a84:	00 
  104a85:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  104a8c:	e8 4a c2 ff ff       	call   100cdb <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  104a91:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104a96:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104a9d:	00 
  104a9e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104aa5:	00 
  104aa6:	89 04 24             	mov    %eax,(%esp)
  104aa9:	e8 ae f9 ff ff       	call   10445c <get_pte>
  104aae:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104ab1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104ab5:	75 24                	jne    104adb <check_pgdir+0x303>
  104ab7:	c7 44 24 0c 3c 6d 10 	movl   $0x106d3c,0xc(%esp)
  104abe:	00 
  104abf:	c7 44 24 08 81 6b 10 	movl   $0x106b81,0x8(%esp)
  104ac6:	00 
  104ac7:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
  104ace:	00 
  104acf:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  104ad6:	e8 00 c2 ff ff       	call   100cdb <__panic>
    assert(*ptep & PTE_U);
  104adb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104ade:	8b 00                	mov    (%eax),%eax
  104ae0:	83 e0 04             	and    $0x4,%eax
  104ae3:	85 c0                	test   %eax,%eax
  104ae5:	75 24                	jne    104b0b <check_pgdir+0x333>
  104ae7:	c7 44 24 0c 6c 6d 10 	movl   $0x106d6c,0xc(%esp)
  104aee:	00 
  104aef:	c7 44 24 08 81 6b 10 	movl   $0x106b81,0x8(%esp)
  104af6:	00 
  104af7:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
  104afe:	00 
  104aff:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  104b06:	e8 d0 c1 ff ff       	call   100cdb <__panic>
    assert(*ptep & PTE_W);
  104b0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104b0e:	8b 00                	mov    (%eax),%eax
  104b10:	83 e0 02             	and    $0x2,%eax
  104b13:	85 c0                	test   %eax,%eax
  104b15:	75 24                	jne    104b3b <check_pgdir+0x363>
  104b17:	c7 44 24 0c 7a 6d 10 	movl   $0x106d7a,0xc(%esp)
  104b1e:	00 
  104b1f:	c7 44 24 08 81 6b 10 	movl   $0x106b81,0x8(%esp)
  104b26:	00 
  104b27:	c7 44 24 04 f8 01 00 	movl   $0x1f8,0x4(%esp)
  104b2e:	00 
  104b2f:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  104b36:	e8 a0 c1 ff ff       	call   100cdb <__panic>
    assert(boot_pgdir[0] & PTE_U);
  104b3b:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104b40:	8b 00                	mov    (%eax),%eax
  104b42:	83 e0 04             	and    $0x4,%eax
  104b45:	85 c0                	test   %eax,%eax
  104b47:	75 24                	jne    104b6d <check_pgdir+0x395>
  104b49:	c7 44 24 0c 88 6d 10 	movl   $0x106d88,0xc(%esp)
  104b50:	00 
  104b51:	c7 44 24 08 81 6b 10 	movl   $0x106b81,0x8(%esp)
  104b58:	00 
  104b59:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
  104b60:	00 
  104b61:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  104b68:	e8 6e c1 ff ff       	call   100cdb <__panic>
    assert(page_ref(p2) == 1);
  104b6d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104b70:	89 04 24             	mov    %eax,(%esp)
  104b73:	e8 42 f0 ff ff       	call   103bba <page_ref>
  104b78:	83 f8 01             	cmp    $0x1,%eax
  104b7b:	74 24                	je     104ba1 <check_pgdir+0x3c9>
  104b7d:	c7 44 24 0c 9e 6d 10 	movl   $0x106d9e,0xc(%esp)
  104b84:	00 
  104b85:	c7 44 24 08 81 6b 10 	movl   $0x106b81,0x8(%esp)
  104b8c:	00 
  104b8d:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
  104b94:	00 
  104b95:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  104b9c:	e8 3a c1 ff ff       	call   100cdb <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
  104ba1:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104ba6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  104bad:	00 
  104bae:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  104bb5:	00 
  104bb6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104bb9:	89 54 24 04          	mov    %edx,0x4(%esp)
  104bbd:	89 04 24             	mov    %eax,(%esp)
  104bc0:	e8 d8 fa ff ff       	call   10469d <page_insert>
  104bc5:	85 c0                	test   %eax,%eax
  104bc7:	74 24                	je     104bed <check_pgdir+0x415>
  104bc9:	c7 44 24 0c b0 6d 10 	movl   $0x106db0,0xc(%esp)
  104bd0:	00 
  104bd1:	c7 44 24 08 81 6b 10 	movl   $0x106b81,0x8(%esp)
  104bd8:	00 
  104bd9:	c7 44 24 04 fc 01 00 	movl   $0x1fc,0x4(%esp)
  104be0:	00 
  104be1:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  104be8:	e8 ee c0 ff ff       	call   100cdb <__panic>
    assert(page_ref(p1) == 2);
  104bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104bf0:	89 04 24             	mov    %eax,(%esp)
  104bf3:	e8 c2 ef ff ff       	call   103bba <page_ref>
  104bf8:	83 f8 02             	cmp    $0x2,%eax
  104bfb:	74 24                	je     104c21 <check_pgdir+0x449>
  104bfd:	c7 44 24 0c dc 6d 10 	movl   $0x106ddc,0xc(%esp)
  104c04:	00 
  104c05:	c7 44 24 08 81 6b 10 	movl   $0x106b81,0x8(%esp)
  104c0c:	00 
  104c0d:	c7 44 24 04 fd 01 00 	movl   $0x1fd,0x4(%esp)
  104c14:	00 
  104c15:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  104c1c:	e8 ba c0 ff ff       	call   100cdb <__panic>
    assert(page_ref(p2) == 0);
  104c21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104c24:	89 04 24             	mov    %eax,(%esp)
  104c27:	e8 8e ef ff ff       	call   103bba <page_ref>
  104c2c:	85 c0                	test   %eax,%eax
  104c2e:	74 24                	je     104c54 <check_pgdir+0x47c>
  104c30:	c7 44 24 0c ee 6d 10 	movl   $0x106dee,0xc(%esp)
  104c37:	00 
  104c38:	c7 44 24 08 81 6b 10 	movl   $0x106b81,0x8(%esp)
  104c3f:	00 
  104c40:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
  104c47:	00 
  104c48:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  104c4f:	e8 87 c0 ff ff       	call   100cdb <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  104c54:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104c59:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104c60:	00 
  104c61:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104c68:	00 
  104c69:	89 04 24             	mov    %eax,(%esp)
  104c6c:	e8 eb f7 ff ff       	call   10445c <get_pte>
  104c71:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104c74:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104c78:	75 24                	jne    104c9e <check_pgdir+0x4c6>
  104c7a:	c7 44 24 0c 3c 6d 10 	movl   $0x106d3c,0xc(%esp)
  104c81:	00 
  104c82:	c7 44 24 08 81 6b 10 	movl   $0x106b81,0x8(%esp)
  104c89:	00 
  104c8a:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
  104c91:	00 
  104c92:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  104c99:	e8 3d c0 ff ff       	call   100cdb <__panic>
    assert(pte2page(*ptep) == p1);
  104c9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104ca1:	8b 00                	mov    (%eax),%eax
  104ca3:	89 04 24             	mov    %eax,(%esp)
  104ca6:	e8 b5 ee ff ff       	call   103b60 <pte2page>
  104cab:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  104cae:	74 24                	je     104cd4 <check_pgdir+0x4fc>
  104cb0:	c7 44 24 0c b1 6c 10 	movl   $0x106cb1,0xc(%esp)
  104cb7:	00 
  104cb8:	c7 44 24 08 81 6b 10 	movl   $0x106b81,0x8(%esp)
  104cbf:	00 
  104cc0:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
  104cc7:	00 
  104cc8:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  104ccf:	e8 07 c0 ff ff       	call   100cdb <__panic>
    assert((*ptep & PTE_U) == 0);
  104cd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104cd7:	8b 00                	mov    (%eax),%eax
  104cd9:	83 e0 04             	and    $0x4,%eax
  104cdc:	85 c0                	test   %eax,%eax
  104cde:	74 24                	je     104d04 <check_pgdir+0x52c>
  104ce0:	c7 44 24 0c 00 6e 10 	movl   $0x106e00,0xc(%esp)
  104ce7:	00 
  104ce8:	c7 44 24 08 81 6b 10 	movl   $0x106b81,0x8(%esp)
  104cef:	00 
  104cf0:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
  104cf7:	00 
  104cf8:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  104cff:	e8 d7 bf ff ff       	call   100cdb <__panic>

    page_remove(boot_pgdir, 0x0);
  104d04:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104d09:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104d10:	00 
  104d11:	89 04 24             	mov    %eax,(%esp)
  104d14:	e8 3d f9 ff ff       	call   104656 <page_remove>
    assert(page_ref(p1) == 1);
  104d19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104d1c:	89 04 24             	mov    %eax,(%esp)
  104d1f:	e8 96 ee ff ff       	call   103bba <page_ref>
  104d24:	83 f8 01             	cmp    $0x1,%eax
  104d27:	74 24                	je     104d4d <check_pgdir+0x575>
  104d29:	c7 44 24 0c c7 6c 10 	movl   $0x106cc7,0xc(%esp)
  104d30:	00 
  104d31:	c7 44 24 08 81 6b 10 	movl   $0x106b81,0x8(%esp)
  104d38:	00 
  104d39:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
  104d40:	00 
  104d41:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  104d48:	e8 8e bf ff ff       	call   100cdb <__panic>
    assert(page_ref(p2) == 0);
  104d4d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104d50:	89 04 24             	mov    %eax,(%esp)
  104d53:	e8 62 ee ff ff       	call   103bba <page_ref>
  104d58:	85 c0                	test   %eax,%eax
  104d5a:	74 24                	je     104d80 <check_pgdir+0x5a8>
  104d5c:	c7 44 24 0c ee 6d 10 	movl   $0x106dee,0xc(%esp)
  104d63:	00 
  104d64:	c7 44 24 08 81 6b 10 	movl   $0x106b81,0x8(%esp)
  104d6b:	00 
  104d6c:	c7 44 24 04 05 02 00 	movl   $0x205,0x4(%esp)
  104d73:	00 
  104d74:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  104d7b:	e8 5b bf ff ff       	call   100cdb <__panic>

    page_remove(boot_pgdir, PGSIZE);
  104d80:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104d85:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104d8c:	00 
  104d8d:	89 04 24             	mov    %eax,(%esp)
  104d90:	e8 c1 f8 ff ff       	call   104656 <page_remove>
    assert(page_ref(p1) == 0);
  104d95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104d98:	89 04 24             	mov    %eax,(%esp)
  104d9b:	e8 1a ee ff ff       	call   103bba <page_ref>
  104da0:	85 c0                	test   %eax,%eax
  104da2:	74 24                	je     104dc8 <check_pgdir+0x5f0>
  104da4:	c7 44 24 0c 15 6e 10 	movl   $0x106e15,0xc(%esp)
  104dab:	00 
  104dac:	c7 44 24 08 81 6b 10 	movl   $0x106b81,0x8(%esp)
  104db3:	00 
  104db4:	c7 44 24 04 08 02 00 	movl   $0x208,0x4(%esp)
  104dbb:	00 
  104dbc:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  104dc3:	e8 13 bf ff ff       	call   100cdb <__panic>
    assert(page_ref(p2) == 0);
  104dc8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104dcb:	89 04 24             	mov    %eax,(%esp)
  104dce:	e8 e7 ed ff ff       	call   103bba <page_ref>
  104dd3:	85 c0                	test   %eax,%eax
  104dd5:	74 24                	je     104dfb <check_pgdir+0x623>
  104dd7:	c7 44 24 0c ee 6d 10 	movl   $0x106dee,0xc(%esp)
  104dde:	00 
  104ddf:	c7 44 24 08 81 6b 10 	movl   $0x106b81,0x8(%esp)
  104de6:	00 
  104de7:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
  104dee:	00 
  104def:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  104df6:	e8 e0 be ff ff       	call   100cdb <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
  104dfb:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104e00:	8b 00                	mov    (%eax),%eax
  104e02:	89 04 24             	mov    %eax,(%esp)
  104e05:	e8 96 ed ff ff       	call   103ba0 <pde2page>
  104e0a:	89 04 24             	mov    %eax,(%esp)
  104e0d:	e8 a8 ed ff ff       	call   103bba <page_ref>
  104e12:	83 f8 01             	cmp    $0x1,%eax
  104e15:	74 24                	je     104e3b <check_pgdir+0x663>
  104e17:	c7 44 24 0c 28 6e 10 	movl   $0x106e28,0xc(%esp)
  104e1e:	00 
  104e1f:	c7 44 24 08 81 6b 10 	movl   $0x106b81,0x8(%esp)
  104e26:	00 
  104e27:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
  104e2e:	00 
  104e2f:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  104e36:	e8 a0 be ff ff       	call   100cdb <__panic>
    free_page(pde2page(boot_pgdir[0]));
  104e3b:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104e40:	8b 00                	mov    (%eax),%eax
  104e42:	89 04 24             	mov    %eax,(%esp)
  104e45:	e8 56 ed ff ff       	call   103ba0 <pde2page>
  104e4a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104e51:	00 
  104e52:	89 04 24             	mov    %eax,(%esp)
  104e55:	e8 aa ef ff ff       	call   103e04 <free_pages>
    boot_pgdir[0] = 0;
  104e5a:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104e5f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
  104e65:	c7 04 24 4f 6e 10 00 	movl   $0x106e4f,(%esp)
  104e6c:	e8 e5 b4 ff ff       	call   100356 <cprintf>
}
  104e71:	90                   	nop
  104e72:	89 ec                	mov    %ebp,%esp
  104e74:	5d                   	pop    %ebp
  104e75:	c3                   	ret    

00104e76 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
  104e76:	55                   	push   %ebp
  104e77:	89 e5                	mov    %esp,%ebp
  104e79:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  104e7c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104e83:	e9 ca 00 00 00       	jmp    104f52 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
  104e88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104e8b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104e8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104e91:	c1 e8 0c             	shr    $0xc,%eax
  104e94:	89 45 e0             	mov    %eax,-0x20(%ebp)
  104e97:	a1 a4 be 11 00       	mov    0x11bea4,%eax
  104e9c:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  104e9f:	72 23                	jb     104ec4 <check_boot_pgdir+0x4e>
  104ea1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104ea4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104ea8:	c7 44 24 08 94 6a 10 	movl   $0x106a94,0x8(%esp)
  104eaf:	00 
  104eb0:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
  104eb7:	00 
  104eb8:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  104ebf:	e8 17 be ff ff       	call   100cdb <__panic>
  104ec4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104ec7:	2d 00 00 00 40       	sub    $0x40000000,%eax
  104ecc:	89 c2                	mov    %eax,%edx
  104ece:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104ed3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104eda:	00 
  104edb:	89 54 24 04          	mov    %edx,0x4(%esp)
  104edf:	89 04 24             	mov    %eax,(%esp)
  104ee2:	e8 75 f5 ff ff       	call   10445c <get_pte>
  104ee7:	89 45 dc             	mov    %eax,-0x24(%ebp)
  104eea:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  104eee:	75 24                	jne    104f14 <check_boot_pgdir+0x9e>
  104ef0:	c7 44 24 0c 6c 6e 10 	movl   $0x106e6c,0xc(%esp)
  104ef7:	00 
  104ef8:	c7 44 24 08 81 6b 10 	movl   $0x106b81,0x8(%esp)
  104eff:	00 
  104f00:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
  104f07:	00 
  104f08:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  104f0f:	e8 c7 bd ff ff       	call   100cdb <__panic>
        assert(PTE_ADDR(*ptep) == i);
  104f14:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104f17:	8b 00                	mov    (%eax),%eax
  104f19:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104f1e:	89 c2                	mov    %eax,%edx
  104f20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104f23:	39 c2                	cmp    %eax,%edx
  104f25:	74 24                	je     104f4b <check_boot_pgdir+0xd5>
  104f27:	c7 44 24 0c a9 6e 10 	movl   $0x106ea9,0xc(%esp)
  104f2e:	00 
  104f2f:	c7 44 24 08 81 6b 10 	movl   $0x106b81,0x8(%esp)
  104f36:	00 
  104f37:	c7 44 24 04 18 02 00 	movl   $0x218,0x4(%esp)
  104f3e:	00 
  104f3f:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  104f46:	e8 90 bd ff ff       	call   100cdb <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
  104f4b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  104f52:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104f55:	a1 a4 be 11 00       	mov    0x11bea4,%eax
  104f5a:	39 c2                	cmp    %eax,%edx
  104f5c:	0f 82 26 ff ff ff    	jb     104e88 <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
  104f62:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104f67:	05 ac 0f 00 00       	add    $0xfac,%eax
  104f6c:	8b 00                	mov    (%eax),%eax
  104f6e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104f73:	89 c2                	mov    %eax,%edx
  104f75:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104f7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104f7d:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  104f84:	77 23                	ja     104fa9 <check_boot_pgdir+0x133>
  104f86:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104f89:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104f8d:	c7 44 24 08 38 6b 10 	movl   $0x106b38,0x8(%esp)
  104f94:	00 
  104f95:	c7 44 24 04 1b 02 00 	movl   $0x21b,0x4(%esp)
  104f9c:	00 
  104f9d:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  104fa4:	e8 32 bd ff ff       	call   100cdb <__panic>
  104fa9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104fac:	05 00 00 00 40       	add    $0x40000000,%eax
  104fb1:	39 d0                	cmp    %edx,%eax
  104fb3:	74 24                	je     104fd9 <check_boot_pgdir+0x163>
  104fb5:	c7 44 24 0c c0 6e 10 	movl   $0x106ec0,0xc(%esp)
  104fbc:	00 
  104fbd:	c7 44 24 08 81 6b 10 	movl   $0x106b81,0x8(%esp)
  104fc4:	00 
  104fc5:	c7 44 24 04 1b 02 00 	movl   $0x21b,0x4(%esp)
  104fcc:	00 
  104fcd:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  104fd4:	e8 02 bd ff ff       	call   100cdb <__panic>

    assert(boot_pgdir[0] == 0);
  104fd9:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104fde:	8b 00                	mov    (%eax),%eax
  104fe0:	85 c0                	test   %eax,%eax
  104fe2:	74 24                	je     105008 <check_boot_pgdir+0x192>
  104fe4:	c7 44 24 0c f4 6e 10 	movl   $0x106ef4,0xc(%esp)
  104feb:	00 
  104fec:	c7 44 24 08 81 6b 10 	movl   $0x106b81,0x8(%esp)
  104ff3:	00 
  104ff4:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
  104ffb:	00 
  104ffc:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  105003:	e8 d3 bc ff ff       	call   100cdb <__panic>

    struct Page *p;
    p = alloc_page();
  105008:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10500f:	e8 b6 ed ff ff       	call   103dca <alloc_pages>
  105014:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
  105017:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  10501c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  105023:	00 
  105024:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  10502b:	00 
  10502c:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10502f:	89 54 24 04          	mov    %edx,0x4(%esp)
  105033:	89 04 24             	mov    %eax,(%esp)
  105036:	e8 62 f6 ff ff       	call   10469d <page_insert>
  10503b:	85 c0                	test   %eax,%eax
  10503d:	74 24                	je     105063 <check_boot_pgdir+0x1ed>
  10503f:	c7 44 24 0c 08 6f 10 	movl   $0x106f08,0xc(%esp)
  105046:	00 
  105047:	c7 44 24 08 81 6b 10 	movl   $0x106b81,0x8(%esp)
  10504e:	00 
  10504f:	c7 44 24 04 21 02 00 	movl   $0x221,0x4(%esp)
  105056:	00 
  105057:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  10505e:	e8 78 bc ff ff       	call   100cdb <__panic>
    assert(page_ref(p) == 1);
  105063:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105066:	89 04 24             	mov    %eax,(%esp)
  105069:	e8 4c eb ff ff       	call   103bba <page_ref>
  10506e:	83 f8 01             	cmp    $0x1,%eax
  105071:	74 24                	je     105097 <check_boot_pgdir+0x221>
  105073:	c7 44 24 0c 36 6f 10 	movl   $0x106f36,0xc(%esp)
  10507a:	00 
  10507b:	c7 44 24 08 81 6b 10 	movl   $0x106b81,0x8(%esp)
  105082:	00 
  105083:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
  10508a:	00 
  10508b:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  105092:	e8 44 bc ff ff       	call   100cdb <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
  105097:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  10509c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  1050a3:	00 
  1050a4:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
  1050ab:	00 
  1050ac:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1050af:	89 54 24 04          	mov    %edx,0x4(%esp)
  1050b3:	89 04 24             	mov    %eax,(%esp)
  1050b6:	e8 e2 f5 ff ff       	call   10469d <page_insert>
  1050bb:	85 c0                	test   %eax,%eax
  1050bd:	74 24                	je     1050e3 <check_boot_pgdir+0x26d>
  1050bf:	c7 44 24 0c 48 6f 10 	movl   $0x106f48,0xc(%esp)
  1050c6:	00 
  1050c7:	c7 44 24 08 81 6b 10 	movl   $0x106b81,0x8(%esp)
  1050ce:	00 
  1050cf:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
  1050d6:	00 
  1050d7:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  1050de:	e8 f8 bb ff ff       	call   100cdb <__panic>
    assert(page_ref(p) == 2);
  1050e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1050e6:	89 04 24             	mov    %eax,(%esp)
  1050e9:	e8 cc ea ff ff       	call   103bba <page_ref>
  1050ee:	83 f8 02             	cmp    $0x2,%eax
  1050f1:	74 24                	je     105117 <check_boot_pgdir+0x2a1>
  1050f3:	c7 44 24 0c 7f 6f 10 	movl   $0x106f7f,0xc(%esp)
  1050fa:	00 
  1050fb:	c7 44 24 08 81 6b 10 	movl   $0x106b81,0x8(%esp)
  105102:	00 
  105103:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
  10510a:	00 
  10510b:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  105112:	e8 c4 bb ff ff       	call   100cdb <__panic>

    const char *str = "ucore: Hello world!!";
  105117:	c7 45 e8 90 6f 10 00 	movl   $0x106f90,-0x18(%ebp)
    strcpy((void *)0x100, str);
  10511e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105121:	89 44 24 04          	mov    %eax,0x4(%esp)
  105125:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  10512c:	e8 fc 09 00 00       	call   105b2d <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
  105131:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
  105138:	00 
  105139:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  105140:	e8 60 0a 00 00       	call   105ba5 <strcmp>
  105145:	85 c0                	test   %eax,%eax
  105147:	74 24                	je     10516d <check_boot_pgdir+0x2f7>
  105149:	c7 44 24 0c a8 6f 10 	movl   $0x106fa8,0xc(%esp)
  105150:	00 
  105151:	c7 44 24 08 81 6b 10 	movl   $0x106b81,0x8(%esp)
  105158:	00 
  105159:	c7 44 24 04 28 02 00 	movl   $0x228,0x4(%esp)
  105160:	00 
  105161:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  105168:	e8 6e bb ff ff       	call   100cdb <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
  10516d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105170:	89 04 24             	mov    %eax,(%esp)
  105173:	e8 92 e9 ff ff       	call   103b0a <page2kva>
  105178:	05 00 01 00 00       	add    $0x100,%eax
  10517d:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
  105180:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  105187:	e8 47 09 00 00       	call   105ad3 <strlen>
  10518c:	85 c0                	test   %eax,%eax
  10518e:	74 24                	je     1051b4 <check_boot_pgdir+0x33e>
  105190:	c7 44 24 0c e0 6f 10 	movl   $0x106fe0,0xc(%esp)
  105197:	00 
  105198:	c7 44 24 08 81 6b 10 	movl   $0x106b81,0x8(%esp)
  10519f:	00 
  1051a0:	c7 44 24 04 2b 02 00 	movl   $0x22b,0x4(%esp)
  1051a7:	00 
  1051a8:	c7 04 24 5c 6b 10 00 	movl   $0x106b5c,(%esp)
  1051af:	e8 27 bb ff ff       	call   100cdb <__panic>

    free_page(p);
  1051b4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1051bb:	00 
  1051bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1051bf:	89 04 24             	mov    %eax,(%esp)
  1051c2:	e8 3d ec ff ff       	call   103e04 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
  1051c7:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  1051cc:	8b 00                	mov    (%eax),%eax
  1051ce:	89 04 24             	mov    %eax,(%esp)
  1051d1:	e8 ca e9 ff ff       	call   103ba0 <pde2page>
  1051d6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1051dd:	00 
  1051de:	89 04 24             	mov    %eax,(%esp)
  1051e1:	e8 1e ec ff ff       	call   103e04 <free_pages>
    boot_pgdir[0] = 0;
  1051e6:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  1051eb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
  1051f1:	c7 04 24 04 70 10 00 	movl   $0x107004,(%esp)
  1051f8:	e8 59 b1 ff ff       	call   100356 <cprintf>
}
  1051fd:	90                   	nop
  1051fe:	89 ec                	mov    %ebp,%esp
  105200:	5d                   	pop    %ebp
  105201:	c3                   	ret    

00105202 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
  105202:	55                   	push   %ebp
  105203:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
  105205:	8b 45 08             	mov    0x8(%ebp),%eax
  105208:	83 e0 04             	and    $0x4,%eax
  10520b:	85 c0                	test   %eax,%eax
  10520d:	74 04                	je     105213 <perm2str+0x11>
  10520f:	b0 75                	mov    $0x75,%al
  105211:	eb 02                	jmp    105215 <perm2str+0x13>
  105213:	b0 2d                	mov    $0x2d,%al
  105215:	a2 28 bf 11 00       	mov    %al,0x11bf28
    str[1] = 'r';
  10521a:	c6 05 29 bf 11 00 72 	movb   $0x72,0x11bf29
    str[2] = (perm & PTE_W) ? 'w' : '-';
  105221:	8b 45 08             	mov    0x8(%ebp),%eax
  105224:	83 e0 02             	and    $0x2,%eax
  105227:	85 c0                	test   %eax,%eax
  105229:	74 04                	je     10522f <perm2str+0x2d>
  10522b:	b0 77                	mov    $0x77,%al
  10522d:	eb 02                	jmp    105231 <perm2str+0x2f>
  10522f:	b0 2d                	mov    $0x2d,%al
  105231:	a2 2a bf 11 00       	mov    %al,0x11bf2a
    str[3] = '\0';
  105236:	c6 05 2b bf 11 00 00 	movb   $0x0,0x11bf2b
    return str;
  10523d:	b8 28 bf 11 00       	mov    $0x11bf28,%eax
}
  105242:	5d                   	pop    %ebp
  105243:	c3                   	ret    

00105244 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
  105244:	55                   	push   %ebp
  105245:	89 e5                	mov    %esp,%ebp
  105247:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
  10524a:	8b 45 10             	mov    0x10(%ebp),%eax
  10524d:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105250:	72 0d                	jb     10525f <get_pgtable_items+0x1b>
        return 0;
  105252:	b8 00 00 00 00       	mov    $0x0,%eax
  105257:	e9 98 00 00 00       	jmp    1052f4 <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
  10525c:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
  10525f:	8b 45 10             	mov    0x10(%ebp),%eax
  105262:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105265:	73 18                	jae    10527f <get_pgtable_items+0x3b>
  105267:	8b 45 10             	mov    0x10(%ebp),%eax
  10526a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  105271:	8b 45 14             	mov    0x14(%ebp),%eax
  105274:	01 d0                	add    %edx,%eax
  105276:	8b 00                	mov    (%eax),%eax
  105278:	83 e0 01             	and    $0x1,%eax
  10527b:	85 c0                	test   %eax,%eax
  10527d:	74 dd                	je     10525c <get_pgtable_items+0x18>
    }
    if (start < right) {
  10527f:	8b 45 10             	mov    0x10(%ebp),%eax
  105282:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105285:	73 68                	jae    1052ef <get_pgtable_items+0xab>
        if (left_store != NULL) {
  105287:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
  10528b:	74 08                	je     105295 <get_pgtable_items+0x51>
            *left_store = start;
  10528d:	8b 45 18             	mov    0x18(%ebp),%eax
  105290:	8b 55 10             	mov    0x10(%ebp),%edx
  105293:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
  105295:	8b 45 10             	mov    0x10(%ebp),%eax
  105298:	8d 50 01             	lea    0x1(%eax),%edx
  10529b:	89 55 10             	mov    %edx,0x10(%ebp)
  10529e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1052a5:	8b 45 14             	mov    0x14(%ebp),%eax
  1052a8:	01 d0                	add    %edx,%eax
  1052aa:	8b 00                	mov    (%eax),%eax
  1052ac:	83 e0 07             	and    $0x7,%eax
  1052af:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  1052b2:	eb 03                	jmp    1052b7 <get_pgtable_items+0x73>
            start ++;
  1052b4:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  1052b7:	8b 45 10             	mov    0x10(%ebp),%eax
  1052ba:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1052bd:	73 1d                	jae    1052dc <get_pgtable_items+0x98>
  1052bf:	8b 45 10             	mov    0x10(%ebp),%eax
  1052c2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1052c9:	8b 45 14             	mov    0x14(%ebp),%eax
  1052cc:	01 d0                	add    %edx,%eax
  1052ce:	8b 00                	mov    (%eax),%eax
  1052d0:	83 e0 07             	and    $0x7,%eax
  1052d3:	89 c2                	mov    %eax,%edx
  1052d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1052d8:	39 c2                	cmp    %eax,%edx
  1052da:	74 d8                	je     1052b4 <get_pgtable_items+0x70>
        }
        if (right_store != NULL) {
  1052dc:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  1052e0:	74 08                	je     1052ea <get_pgtable_items+0xa6>
            *right_store = start;
  1052e2:	8b 45 1c             	mov    0x1c(%ebp),%eax
  1052e5:	8b 55 10             	mov    0x10(%ebp),%edx
  1052e8:	89 10                	mov    %edx,(%eax)
        }
        return perm;
  1052ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1052ed:	eb 05                	jmp    1052f4 <get_pgtable_items+0xb0>
    }
    return 0;
  1052ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1052f4:	89 ec                	mov    %ebp,%esp
  1052f6:	5d                   	pop    %ebp
  1052f7:	c3                   	ret    

001052f8 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  1052f8:	55                   	push   %ebp
  1052f9:	89 e5                	mov    %esp,%ebp
  1052fb:	57                   	push   %edi
  1052fc:	56                   	push   %esi
  1052fd:	53                   	push   %ebx
  1052fe:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
  105301:	c7 04 24 24 70 10 00 	movl   $0x107024,(%esp)
  105308:	e8 49 b0 ff ff       	call   100356 <cprintf>
    size_t left, right = 0, perm;
  10530d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  105314:	e9 f2 00 00 00       	jmp    10540b <print_pgdir+0x113>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  105319:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10531c:	89 04 24             	mov    %eax,(%esp)
  10531f:	e8 de fe ff ff       	call   105202 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
  105324:	8b 55 dc             	mov    -0x24(%ebp),%edx
  105327:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  10532a:	29 ca                	sub    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  10532c:	89 d6                	mov    %edx,%esi
  10532e:	c1 e6 16             	shl    $0x16,%esi
  105331:	8b 55 dc             	mov    -0x24(%ebp),%edx
  105334:	89 d3                	mov    %edx,%ebx
  105336:	c1 e3 16             	shl    $0x16,%ebx
  105339:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10533c:	89 d1                	mov    %edx,%ecx
  10533e:	c1 e1 16             	shl    $0x16,%ecx
  105341:	8b 55 dc             	mov    -0x24(%ebp),%edx
  105344:	8b 7d e0             	mov    -0x20(%ebp),%edi
  105347:	29 fa                	sub    %edi,%edx
  105349:	89 44 24 14          	mov    %eax,0x14(%esp)
  10534d:	89 74 24 10          	mov    %esi,0x10(%esp)
  105351:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  105355:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  105359:	89 54 24 04          	mov    %edx,0x4(%esp)
  10535d:	c7 04 24 55 70 10 00 	movl   $0x107055,(%esp)
  105364:	e8 ed af ff ff       	call   100356 <cprintf>
        size_t l, r = left * NPTEENTRY;
  105369:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10536c:	c1 e0 0a             	shl    $0xa,%eax
  10536f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  105372:	eb 50                	jmp    1053c4 <print_pgdir+0xcc>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  105374:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105377:	89 04 24             	mov    %eax,(%esp)
  10537a:	e8 83 fe ff ff       	call   105202 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
  10537f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  105382:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  105385:	29 ca                	sub    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  105387:	89 d6                	mov    %edx,%esi
  105389:	c1 e6 0c             	shl    $0xc,%esi
  10538c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10538f:	89 d3                	mov    %edx,%ebx
  105391:	c1 e3 0c             	shl    $0xc,%ebx
  105394:	8b 55 d8             	mov    -0x28(%ebp),%edx
  105397:	89 d1                	mov    %edx,%ecx
  105399:	c1 e1 0c             	shl    $0xc,%ecx
  10539c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10539f:	8b 7d d8             	mov    -0x28(%ebp),%edi
  1053a2:	29 fa                	sub    %edi,%edx
  1053a4:	89 44 24 14          	mov    %eax,0x14(%esp)
  1053a8:	89 74 24 10          	mov    %esi,0x10(%esp)
  1053ac:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1053b0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  1053b4:	89 54 24 04          	mov    %edx,0x4(%esp)
  1053b8:	c7 04 24 74 70 10 00 	movl   $0x107074,(%esp)
  1053bf:	e8 92 af ff ff       	call   100356 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  1053c4:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
  1053c9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1053cc:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1053cf:	89 d3                	mov    %edx,%ebx
  1053d1:	c1 e3 0a             	shl    $0xa,%ebx
  1053d4:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1053d7:	89 d1                	mov    %edx,%ecx
  1053d9:	c1 e1 0a             	shl    $0xa,%ecx
  1053dc:	8d 55 d4             	lea    -0x2c(%ebp),%edx
  1053df:	89 54 24 14          	mov    %edx,0x14(%esp)
  1053e3:	8d 55 d8             	lea    -0x28(%ebp),%edx
  1053e6:	89 54 24 10          	mov    %edx,0x10(%esp)
  1053ea:	89 74 24 0c          	mov    %esi,0xc(%esp)
  1053ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  1053f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1053f6:	89 0c 24             	mov    %ecx,(%esp)
  1053f9:	e8 46 fe ff ff       	call   105244 <get_pgtable_items>
  1053fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105401:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105405:	0f 85 69 ff ff ff    	jne    105374 <print_pgdir+0x7c>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  10540b:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
  105410:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105413:	8d 55 dc             	lea    -0x24(%ebp),%edx
  105416:	89 54 24 14          	mov    %edx,0x14(%esp)
  10541a:	8d 55 e0             	lea    -0x20(%ebp),%edx
  10541d:	89 54 24 10          	mov    %edx,0x10(%esp)
  105421:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  105425:	89 44 24 08          	mov    %eax,0x8(%esp)
  105429:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  105430:	00 
  105431:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  105438:	e8 07 fe ff ff       	call   105244 <get_pgtable_items>
  10543d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105440:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105444:	0f 85 cf fe ff ff    	jne    105319 <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
  10544a:	c7 04 24 98 70 10 00 	movl   $0x107098,(%esp)
  105451:	e8 00 af ff ff       	call   100356 <cprintf>
}
  105456:	90                   	nop
  105457:	83 c4 4c             	add    $0x4c,%esp
  10545a:	5b                   	pop    %ebx
  10545b:	5e                   	pop    %esi
  10545c:	5f                   	pop    %edi
  10545d:	5d                   	pop    %ebp
  10545e:	c3                   	ret    

0010545f <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  10545f:	55                   	push   %ebp
  105460:	89 e5                	mov    %esp,%ebp
  105462:	83 ec 58             	sub    $0x58,%esp
  105465:	8b 45 10             	mov    0x10(%ebp),%eax
  105468:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10546b:	8b 45 14             	mov    0x14(%ebp),%eax
  10546e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  105471:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105474:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  105477:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10547a:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  10547d:	8b 45 18             	mov    0x18(%ebp),%eax
  105480:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105483:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105486:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105489:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10548c:	89 55 f0             	mov    %edx,-0x10(%ebp)
  10548f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105492:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105495:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  105499:	74 1c                	je     1054b7 <printnum+0x58>
  10549b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10549e:	ba 00 00 00 00       	mov    $0x0,%edx
  1054a3:	f7 75 e4             	divl   -0x1c(%ebp)
  1054a6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  1054a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1054ac:	ba 00 00 00 00       	mov    $0x0,%edx
  1054b1:	f7 75 e4             	divl   -0x1c(%ebp)
  1054b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1054b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1054ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1054bd:	f7 75 e4             	divl   -0x1c(%ebp)
  1054c0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1054c3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  1054c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1054c9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1054cc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1054cf:	89 55 ec             	mov    %edx,-0x14(%ebp)
  1054d2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1054d5:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  1054d8:	8b 45 18             	mov    0x18(%ebp),%eax
  1054db:	ba 00 00 00 00       	mov    $0x0,%edx
  1054e0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  1054e3:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  1054e6:	19 d1                	sbb    %edx,%ecx
  1054e8:	72 4c                	jb     105536 <printnum+0xd7>
        printnum(putch, putdat, result, base, width - 1, padc);
  1054ea:	8b 45 1c             	mov    0x1c(%ebp),%eax
  1054ed:	8d 50 ff             	lea    -0x1(%eax),%edx
  1054f0:	8b 45 20             	mov    0x20(%ebp),%eax
  1054f3:	89 44 24 18          	mov    %eax,0x18(%esp)
  1054f7:	89 54 24 14          	mov    %edx,0x14(%esp)
  1054fb:	8b 45 18             	mov    0x18(%ebp),%eax
  1054fe:	89 44 24 10          	mov    %eax,0x10(%esp)
  105502:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105505:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105508:	89 44 24 08          	mov    %eax,0x8(%esp)
  10550c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105510:	8b 45 0c             	mov    0xc(%ebp),%eax
  105513:	89 44 24 04          	mov    %eax,0x4(%esp)
  105517:	8b 45 08             	mov    0x8(%ebp),%eax
  10551a:	89 04 24             	mov    %eax,(%esp)
  10551d:	e8 3d ff ff ff       	call   10545f <printnum>
  105522:	eb 1b                	jmp    10553f <printnum+0xe0>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  105524:	8b 45 0c             	mov    0xc(%ebp),%eax
  105527:	89 44 24 04          	mov    %eax,0x4(%esp)
  10552b:	8b 45 20             	mov    0x20(%ebp),%eax
  10552e:	89 04 24             	mov    %eax,(%esp)
  105531:	8b 45 08             	mov    0x8(%ebp),%eax
  105534:	ff d0                	call   *%eax
        while (-- width > 0)
  105536:	ff 4d 1c             	decl   0x1c(%ebp)
  105539:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  10553d:	7f e5                	jg     105524 <printnum+0xc5>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  10553f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  105542:	05 4c 71 10 00       	add    $0x10714c,%eax
  105547:	0f b6 00             	movzbl (%eax),%eax
  10554a:	0f be c0             	movsbl %al,%eax
  10554d:	8b 55 0c             	mov    0xc(%ebp),%edx
  105550:	89 54 24 04          	mov    %edx,0x4(%esp)
  105554:	89 04 24             	mov    %eax,(%esp)
  105557:	8b 45 08             	mov    0x8(%ebp),%eax
  10555a:	ff d0                	call   *%eax
}
  10555c:	90                   	nop
  10555d:	89 ec                	mov    %ebp,%esp
  10555f:	5d                   	pop    %ebp
  105560:	c3                   	ret    

00105561 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  105561:	55                   	push   %ebp
  105562:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  105564:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  105568:	7e 14                	jle    10557e <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  10556a:	8b 45 08             	mov    0x8(%ebp),%eax
  10556d:	8b 00                	mov    (%eax),%eax
  10556f:	8d 48 08             	lea    0x8(%eax),%ecx
  105572:	8b 55 08             	mov    0x8(%ebp),%edx
  105575:	89 0a                	mov    %ecx,(%edx)
  105577:	8b 50 04             	mov    0x4(%eax),%edx
  10557a:	8b 00                	mov    (%eax),%eax
  10557c:	eb 30                	jmp    1055ae <getuint+0x4d>
    }
    else if (lflag) {
  10557e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105582:	74 16                	je     10559a <getuint+0x39>
        return va_arg(*ap, unsigned long);
  105584:	8b 45 08             	mov    0x8(%ebp),%eax
  105587:	8b 00                	mov    (%eax),%eax
  105589:	8d 48 04             	lea    0x4(%eax),%ecx
  10558c:	8b 55 08             	mov    0x8(%ebp),%edx
  10558f:	89 0a                	mov    %ecx,(%edx)
  105591:	8b 00                	mov    (%eax),%eax
  105593:	ba 00 00 00 00       	mov    $0x0,%edx
  105598:	eb 14                	jmp    1055ae <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  10559a:	8b 45 08             	mov    0x8(%ebp),%eax
  10559d:	8b 00                	mov    (%eax),%eax
  10559f:	8d 48 04             	lea    0x4(%eax),%ecx
  1055a2:	8b 55 08             	mov    0x8(%ebp),%edx
  1055a5:	89 0a                	mov    %ecx,(%edx)
  1055a7:	8b 00                	mov    (%eax),%eax
  1055a9:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  1055ae:	5d                   	pop    %ebp
  1055af:	c3                   	ret    

001055b0 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  1055b0:	55                   	push   %ebp
  1055b1:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  1055b3:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  1055b7:	7e 14                	jle    1055cd <getint+0x1d>
        return va_arg(*ap, long long);
  1055b9:	8b 45 08             	mov    0x8(%ebp),%eax
  1055bc:	8b 00                	mov    (%eax),%eax
  1055be:	8d 48 08             	lea    0x8(%eax),%ecx
  1055c1:	8b 55 08             	mov    0x8(%ebp),%edx
  1055c4:	89 0a                	mov    %ecx,(%edx)
  1055c6:	8b 50 04             	mov    0x4(%eax),%edx
  1055c9:	8b 00                	mov    (%eax),%eax
  1055cb:	eb 28                	jmp    1055f5 <getint+0x45>
    }
    else if (lflag) {
  1055cd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1055d1:	74 12                	je     1055e5 <getint+0x35>
        return va_arg(*ap, long);
  1055d3:	8b 45 08             	mov    0x8(%ebp),%eax
  1055d6:	8b 00                	mov    (%eax),%eax
  1055d8:	8d 48 04             	lea    0x4(%eax),%ecx
  1055db:	8b 55 08             	mov    0x8(%ebp),%edx
  1055de:	89 0a                	mov    %ecx,(%edx)
  1055e0:	8b 00                	mov    (%eax),%eax
  1055e2:	99                   	cltd   
  1055e3:	eb 10                	jmp    1055f5 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  1055e5:	8b 45 08             	mov    0x8(%ebp),%eax
  1055e8:	8b 00                	mov    (%eax),%eax
  1055ea:	8d 48 04             	lea    0x4(%eax),%ecx
  1055ed:	8b 55 08             	mov    0x8(%ebp),%edx
  1055f0:	89 0a                	mov    %ecx,(%edx)
  1055f2:	8b 00                	mov    (%eax),%eax
  1055f4:	99                   	cltd   
    }
}
  1055f5:	5d                   	pop    %ebp
  1055f6:	c3                   	ret    

001055f7 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  1055f7:	55                   	push   %ebp
  1055f8:	89 e5                	mov    %esp,%ebp
  1055fa:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  1055fd:	8d 45 14             	lea    0x14(%ebp),%eax
  105600:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  105603:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105606:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10560a:	8b 45 10             	mov    0x10(%ebp),%eax
  10560d:	89 44 24 08          	mov    %eax,0x8(%esp)
  105611:	8b 45 0c             	mov    0xc(%ebp),%eax
  105614:	89 44 24 04          	mov    %eax,0x4(%esp)
  105618:	8b 45 08             	mov    0x8(%ebp),%eax
  10561b:	89 04 24             	mov    %eax,(%esp)
  10561e:	e8 05 00 00 00       	call   105628 <vprintfmt>
    va_end(ap);
}
  105623:	90                   	nop
  105624:	89 ec                	mov    %ebp,%esp
  105626:	5d                   	pop    %ebp
  105627:	c3                   	ret    

00105628 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  105628:	55                   	push   %ebp
  105629:	89 e5                	mov    %esp,%ebp
  10562b:	56                   	push   %esi
  10562c:	53                   	push   %ebx
  10562d:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105630:	eb 17                	jmp    105649 <vprintfmt+0x21>
            if (ch == '\0') {
  105632:	85 db                	test   %ebx,%ebx
  105634:	0f 84 bf 03 00 00    	je     1059f9 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
  10563a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10563d:	89 44 24 04          	mov    %eax,0x4(%esp)
  105641:	89 1c 24             	mov    %ebx,(%esp)
  105644:	8b 45 08             	mov    0x8(%ebp),%eax
  105647:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105649:	8b 45 10             	mov    0x10(%ebp),%eax
  10564c:	8d 50 01             	lea    0x1(%eax),%edx
  10564f:	89 55 10             	mov    %edx,0x10(%ebp)
  105652:	0f b6 00             	movzbl (%eax),%eax
  105655:	0f b6 d8             	movzbl %al,%ebx
  105658:	83 fb 25             	cmp    $0x25,%ebx
  10565b:	75 d5                	jne    105632 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
  10565d:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  105661:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  105668:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10566b:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  10566e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  105675:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105678:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  10567b:	8b 45 10             	mov    0x10(%ebp),%eax
  10567e:	8d 50 01             	lea    0x1(%eax),%edx
  105681:	89 55 10             	mov    %edx,0x10(%ebp)
  105684:	0f b6 00             	movzbl (%eax),%eax
  105687:	0f b6 d8             	movzbl %al,%ebx
  10568a:	8d 43 dd             	lea    -0x23(%ebx),%eax
  10568d:	83 f8 55             	cmp    $0x55,%eax
  105690:	0f 87 37 03 00 00    	ja     1059cd <vprintfmt+0x3a5>
  105696:	8b 04 85 70 71 10 00 	mov    0x107170(,%eax,4),%eax
  10569d:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  10569f:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  1056a3:	eb d6                	jmp    10567b <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  1056a5:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  1056a9:	eb d0                	jmp    10567b <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  1056ab:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  1056b2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1056b5:	89 d0                	mov    %edx,%eax
  1056b7:	c1 e0 02             	shl    $0x2,%eax
  1056ba:	01 d0                	add    %edx,%eax
  1056bc:	01 c0                	add    %eax,%eax
  1056be:	01 d8                	add    %ebx,%eax
  1056c0:	83 e8 30             	sub    $0x30,%eax
  1056c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  1056c6:	8b 45 10             	mov    0x10(%ebp),%eax
  1056c9:	0f b6 00             	movzbl (%eax),%eax
  1056cc:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  1056cf:	83 fb 2f             	cmp    $0x2f,%ebx
  1056d2:	7e 38                	jle    10570c <vprintfmt+0xe4>
  1056d4:	83 fb 39             	cmp    $0x39,%ebx
  1056d7:	7f 33                	jg     10570c <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
  1056d9:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
  1056dc:	eb d4                	jmp    1056b2 <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  1056de:	8b 45 14             	mov    0x14(%ebp),%eax
  1056e1:	8d 50 04             	lea    0x4(%eax),%edx
  1056e4:	89 55 14             	mov    %edx,0x14(%ebp)
  1056e7:	8b 00                	mov    (%eax),%eax
  1056e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  1056ec:	eb 1f                	jmp    10570d <vprintfmt+0xe5>

        case '.':
            if (width < 0)
  1056ee:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1056f2:	79 87                	jns    10567b <vprintfmt+0x53>
                width = 0;
  1056f4:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  1056fb:	e9 7b ff ff ff       	jmp    10567b <vprintfmt+0x53>

        case '#':
            altflag = 1;
  105700:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  105707:	e9 6f ff ff ff       	jmp    10567b <vprintfmt+0x53>
            goto process_precision;
  10570c:	90                   	nop

        process_precision:
            if (width < 0)
  10570d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105711:	0f 89 64 ff ff ff    	jns    10567b <vprintfmt+0x53>
                width = precision, precision = -1;
  105717:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10571a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10571d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  105724:	e9 52 ff ff ff       	jmp    10567b <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  105729:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
  10572c:	e9 4a ff ff ff       	jmp    10567b <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  105731:	8b 45 14             	mov    0x14(%ebp),%eax
  105734:	8d 50 04             	lea    0x4(%eax),%edx
  105737:	89 55 14             	mov    %edx,0x14(%ebp)
  10573a:	8b 00                	mov    (%eax),%eax
  10573c:	8b 55 0c             	mov    0xc(%ebp),%edx
  10573f:	89 54 24 04          	mov    %edx,0x4(%esp)
  105743:	89 04 24             	mov    %eax,(%esp)
  105746:	8b 45 08             	mov    0x8(%ebp),%eax
  105749:	ff d0                	call   *%eax
            break;
  10574b:	e9 a4 02 00 00       	jmp    1059f4 <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
  105750:	8b 45 14             	mov    0x14(%ebp),%eax
  105753:	8d 50 04             	lea    0x4(%eax),%edx
  105756:	89 55 14             	mov    %edx,0x14(%ebp)
  105759:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  10575b:	85 db                	test   %ebx,%ebx
  10575d:	79 02                	jns    105761 <vprintfmt+0x139>
                err = -err;
  10575f:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  105761:	83 fb 06             	cmp    $0x6,%ebx
  105764:	7f 0b                	jg     105771 <vprintfmt+0x149>
  105766:	8b 34 9d 30 71 10 00 	mov    0x107130(,%ebx,4),%esi
  10576d:	85 f6                	test   %esi,%esi
  10576f:	75 23                	jne    105794 <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
  105771:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  105775:	c7 44 24 08 5d 71 10 	movl   $0x10715d,0x8(%esp)
  10577c:	00 
  10577d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105780:	89 44 24 04          	mov    %eax,0x4(%esp)
  105784:	8b 45 08             	mov    0x8(%ebp),%eax
  105787:	89 04 24             	mov    %eax,(%esp)
  10578a:	e8 68 fe ff ff       	call   1055f7 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  10578f:	e9 60 02 00 00       	jmp    1059f4 <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
  105794:	89 74 24 0c          	mov    %esi,0xc(%esp)
  105798:	c7 44 24 08 66 71 10 	movl   $0x107166,0x8(%esp)
  10579f:	00 
  1057a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1057a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1057a7:	8b 45 08             	mov    0x8(%ebp),%eax
  1057aa:	89 04 24             	mov    %eax,(%esp)
  1057ad:	e8 45 fe ff ff       	call   1055f7 <printfmt>
            break;
  1057b2:	e9 3d 02 00 00       	jmp    1059f4 <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  1057b7:	8b 45 14             	mov    0x14(%ebp),%eax
  1057ba:	8d 50 04             	lea    0x4(%eax),%edx
  1057bd:	89 55 14             	mov    %edx,0x14(%ebp)
  1057c0:	8b 30                	mov    (%eax),%esi
  1057c2:	85 f6                	test   %esi,%esi
  1057c4:	75 05                	jne    1057cb <vprintfmt+0x1a3>
                p = "(null)";
  1057c6:	be 69 71 10 00       	mov    $0x107169,%esi
            }
            if (width > 0 && padc != '-') {
  1057cb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1057cf:	7e 76                	jle    105847 <vprintfmt+0x21f>
  1057d1:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  1057d5:	74 70                	je     105847 <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
  1057d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1057da:	89 44 24 04          	mov    %eax,0x4(%esp)
  1057de:	89 34 24             	mov    %esi,(%esp)
  1057e1:	e8 16 03 00 00       	call   105afc <strnlen>
  1057e6:	89 c2                	mov    %eax,%edx
  1057e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1057eb:	29 d0                	sub    %edx,%eax
  1057ed:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1057f0:	eb 16                	jmp    105808 <vprintfmt+0x1e0>
                    putch(padc, putdat);
  1057f2:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  1057f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  1057f9:	89 54 24 04          	mov    %edx,0x4(%esp)
  1057fd:	89 04 24             	mov    %eax,(%esp)
  105800:	8b 45 08             	mov    0x8(%ebp),%eax
  105803:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
  105805:	ff 4d e8             	decl   -0x18(%ebp)
  105808:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10580c:	7f e4                	jg     1057f2 <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  10580e:	eb 37                	jmp    105847 <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
  105810:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  105814:	74 1f                	je     105835 <vprintfmt+0x20d>
  105816:	83 fb 1f             	cmp    $0x1f,%ebx
  105819:	7e 05                	jle    105820 <vprintfmt+0x1f8>
  10581b:	83 fb 7e             	cmp    $0x7e,%ebx
  10581e:	7e 15                	jle    105835 <vprintfmt+0x20d>
                    putch('?', putdat);
  105820:	8b 45 0c             	mov    0xc(%ebp),%eax
  105823:	89 44 24 04          	mov    %eax,0x4(%esp)
  105827:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  10582e:	8b 45 08             	mov    0x8(%ebp),%eax
  105831:	ff d0                	call   *%eax
  105833:	eb 0f                	jmp    105844 <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
  105835:	8b 45 0c             	mov    0xc(%ebp),%eax
  105838:	89 44 24 04          	mov    %eax,0x4(%esp)
  10583c:	89 1c 24             	mov    %ebx,(%esp)
  10583f:	8b 45 08             	mov    0x8(%ebp),%eax
  105842:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105844:	ff 4d e8             	decl   -0x18(%ebp)
  105847:	89 f0                	mov    %esi,%eax
  105849:	8d 70 01             	lea    0x1(%eax),%esi
  10584c:	0f b6 00             	movzbl (%eax),%eax
  10584f:	0f be d8             	movsbl %al,%ebx
  105852:	85 db                	test   %ebx,%ebx
  105854:	74 27                	je     10587d <vprintfmt+0x255>
  105856:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10585a:	78 b4                	js     105810 <vprintfmt+0x1e8>
  10585c:	ff 4d e4             	decl   -0x1c(%ebp)
  10585f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105863:	79 ab                	jns    105810 <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
  105865:	eb 16                	jmp    10587d <vprintfmt+0x255>
                putch(' ', putdat);
  105867:	8b 45 0c             	mov    0xc(%ebp),%eax
  10586a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10586e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  105875:	8b 45 08             	mov    0x8(%ebp),%eax
  105878:	ff d0                	call   *%eax
            for (; width > 0; width --) {
  10587a:	ff 4d e8             	decl   -0x18(%ebp)
  10587d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105881:	7f e4                	jg     105867 <vprintfmt+0x23f>
            }
            break;
  105883:	e9 6c 01 00 00       	jmp    1059f4 <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  105888:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10588b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10588f:	8d 45 14             	lea    0x14(%ebp),%eax
  105892:	89 04 24             	mov    %eax,(%esp)
  105895:	e8 16 fd ff ff       	call   1055b0 <getint>
  10589a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10589d:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  1058a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1058a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1058a6:	85 d2                	test   %edx,%edx
  1058a8:	79 26                	jns    1058d0 <vprintfmt+0x2a8>
                putch('-', putdat);
  1058aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  1058ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  1058b1:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  1058b8:	8b 45 08             	mov    0x8(%ebp),%eax
  1058bb:	ff d0                	call   *%eax
                num = -(long long)num;
  1058bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1058c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1058c3:	f7 d8                	neg    %eax
  1058c5:	83 d2 00             	adc    $0x0,%edx
  1058c8:	f7 da                	neg    %edx
  1058ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1058cd:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  1058d0:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  1058d7:	e9 a8 00 00 00       	jmp    105984 <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  1058dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1058df:	89 44 24 04          	mov    %eax,0x4(%esp)
  1058e3:	8d 45 14             	lea    0x14(%ebp),%eax
  1058e6:	89 04 24             	mov    %eax,(%esp)
  1058e9:	e8 73 fc ff ff       	call   105561 <getuint>
  1058ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1058f1:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  1058f4:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  1058fb:	e9 84 00 00 00       	jmp    105984 <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  105900:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105903:	89 44 24 04          	mov    %eax,0x4(%esp)
  105907:	8d 45 14             	lea    0x14(%ebp),%eax
  10590a:	89 04 24             	mov    %eax,(%esp)
  10590d:	e8 4f fc ff ff       	call   105561 <getuint>
  105912:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105915:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  105918:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  10591f:	eb 63                	jmp    105984 <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
  105921:	8b 45 0c             	mov    0xc(%ebp),%eax
  105924:	89 44 24 04          	mov    %eax,0x4(%esp)
  105928:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  10592f:	8b 45 08             	mov    0x8(%ebp),%eax
  105932:	ff d0                	call   *%eax
            putch('x', putdat);
  105934:	8b 45 0c             	mov    0xc(%ebp),%eax
  105937:	89 44 24 04          	mov    %eax,0x4(%esp)
  10593b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  105942:	8b 45 08             	mov    0x8(%ebp),%eax
  105945:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  105947:	8b 45 14             	mov    0x14(%ebp),%eax
  10594a:	8d 50 04             	lea    0x4(%eax),%edx
  10594d:	89 55 14             	mov    %edx,0x14(%ebp)
  105950:	8b 00                	mov    (%eax),%eax
  105952:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105955:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  10595c:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  105963:	eb 1f                	jmp    105984 <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  105965:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105968:	89 44 24 04          	mov    %eax,0x4(%esp)
  10596c:	8d 45 14             	lea    0x14(%ebp),%eax
  10596f:	89 04 24             	mov    %eax,(%esp)
  105972:	e8 ea fb ff ff       	call   105561 <getuint>
  105977:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10597a:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  10597d:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  105984:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  105988:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10598b:	89 54 24 18          	mov    %edx,0x18(%esp)
  10598f:	8b 55 e8             	mov    -0x18(%ebp),%edx
  105992:	89 54 24 14          	mov    %edx,0x14(%esp)
  105996:	89 44 24 10          	mov    %eax,0x10(%esp)
  10599a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10599d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1059a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  1059a4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  1059a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  1059af:	8b 45 08             	mov    0x8(%ebp),%eax
  1059b2:	89 04 24             	mov    %eax,(%esp)
  1059b5:	e8 a5 fa ff ff       	call   10545f <printnum>
            break;
  1059ba:	eb 38                	jmp    1059f4 <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  1059bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  1059c3:	89 1c 24             	mov    %ebx,(%esp)
  1059c6:	8b 45 08             	mov    0x8(%ebp),%eax
  1059c9:	ff d0                	call   *%eax
            break;
  1059cb:	eb 27                	jmp    1059f4 <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  1059cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1059d4:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  1059db:	8b 45 08             	mov    0x8(%ebp),%eax
  1059de:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  1059e0:	ff 4d 10             	decl   0x10(%ebp)
  1059e3:	eb 03                	jmp    1059e8 <vprintfmt+0x3c0>
  1059e5:	ff 4d 10             	decl   0x10(%ebp)
  1059e8:	8b 45 10             	mov    0x10(%ebp),%eax
  1059eb:	48                   	dec    %eax
  1059ec:	0f b6 00             	movzbl (%eax),%eax
  1059ef:	3c 25                	cmp    $0x25,%al
  1059f1:	75 f2                	jne    1059e5 <vprintfmt+0x3bd>
                /* do nothing */;
            break;
  1059f3:	90                   	nop
    while (1) {
  1059f4:	e9 37 fc ff ff       	jmp    105630 <vprintfmt+0x8>
                return;
  1059f9:	90                   	nop
        }
    }
}
  1059fa:	83 c4 40             	add    $0x40,%esp
  1059fd:	5b                   	pop    %ebx
  1059fe:	5e                   	pop    %esi
  1059ff:	5d                   	pop    %ebp
  105a00:	c3                   	ret    

00105a01 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  105a01:	55                   	push   %ebp
  105a02:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  105a04:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a07:	8b 40 08             	mov    0x8(%eax),%eax
  105a0a:	8d 50 01             	lea    0x1(%eax),%edx
  105a0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a10:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  105a13:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a16:	8b 10                	mov    (%eax),%edx
  105a18:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a1b:	8b 40 04             	mov    0x4(%eax),%eax
  105a1e:	39 c2                	cmp    %eax,%edx
  105a20:	73 12                	jae    105a34 <sprintputch+0x33>
        *b->buf ++ = ch;
  105a22:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a25:	8b 00                	mov    (%eax),%eax
  105a27:	8d 48 01             	lea    0x1(%eax),%ecx
  105a2a:	8b 55 0c             	mov    0xc(%ebp),%edx
  105a2d:	89 0a                	mov    %ecx,(%edx)
  105a2f:	8b 55 08             	mov    0x8(%ebp),%edx
  105a32:	88 10                	mov    %dl,(%eax)
    }
}
  105a34:	90                   	nop
  105a35:	5d                   	pop    %ebp
  105a36:	c3                   	ret    

00105a37 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  105a37:	55                   	push   %ebp
  105a38:	89 e5                	mov    %esp,%ebp
  105a3a:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  105a3d:	8d 45 14             	lea    0x14(%ebp),%eax
  105a40:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  105a43:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105a46:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105a4a:	8b 45 10             	mov    0x10(%ebp),%eax
  105a4d:	89 44 24 08          	mov    %eax,0x8(%esp)
  105a51:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a54:	89 44 24 04          	mov    %eax,0x4(%esp)
  105a58:	8b 45 08             	mov    0x8(%ebp),%eax
  105a5b:	89 04 24             	mov    %eax,(%esp)
  105a5e:	e8 0a 00 00 00       	call   105a6d <vsnprintf>
  105a63:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  105a66:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105a69:	89 ec                	mov    %ebp,%esp
  105a6b:	5d                   	pop    %ebp
  105a6c:	c3                   	ret    

00105a6d <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  105a6d:	55                   	push   %ebp
  105a6e:	89 e5                	mov    %esp,%ebp
  105a70:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  105a73:	8b 45 08             	mov    0x8(%ebp),%eax
  105a76:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105a79:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a7c:	8d 50 ff             	lea    -0x1(%eax),%edx
  105a7f:	8b 45 08             	mov    0x8(%ebp),%eax
  105a82:	01 d0                	add    %edx,%eax
  105a84:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105a87:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  105a8e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  105a92:	74 0a                	je     105a9e <vsnprintf+0x31>
  105a94:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105a97:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105a9a:	39 c2                	cmp    %eax,%edx
  105a9c:	76 07                	jbe    105aa5 <vsnprintf+0x38>
        return -E_INVAL;
  105a9e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  105aa3:	eb 2a                	jmp    105acf <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  105aa5:	8b 45 14             	mov    0x14(%ebp),%eax
  105aa8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105aac:	8b 45 10             	mov    0x10(%ebp),%eax
  105aaf:	89 44 24 08          	mov    %eax,0x8(%esp)
  105ab3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  105ab6:	89 44 24 04          	mov    %eax,0x4(%esp)
  105aba:	c7 04 24 01 5a 10 00 	movl   $0x105a01,(%esp)
  105ac1:	e8 62 fb ff ff       	call   105628 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  105ac6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105ac9:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  105acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105acf:	89 ec                	mov    %ebp,%esp
  105ad1:	5d                   	pop    %ebp
  105ad2:	c3                   	ret    

00105ad3 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  105ad3:	55                   	push   %ebp
  105ad4:	89 e5                	mov    %esp,%ebp
  105ad6:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  105ad9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  105ae0:	eb 03                	jmp    105ae5 <strlen+0x12>
        cnt ++;
  105ae2:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
  105ae5:	8b 45 08             	mov    0x8(%ebp),%eax
  105ae8:	8d 50 01             	lea    0x1(%eax),%edx
  105aeb:	89 55 08             	mov    %edx,0x8(%ebp)
  105aee:	0f b6 00             	movzbl (%eax),%eax
  105af1:	84 c0                	test   %al,%al
  105af3:	75 ed                	jne    105ae2 <strlen+0xf>
    }
    return cnt;
  105af5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  105af8:	89 ec                	mov    %ebp,%esp
  105afa:	5d                   	pop    %ebp
  105afb:	c3                   	ret    

00105afc <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  105afc:	55                   	push   %ebp
  105afd:	89 e5                	mov    %esp,%ebp
  105aff:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  105b02:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  105b09:	eb 03                	jmp    105b0e <strnlen+0x12>
        cnt ++;
  105b0b:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  105b0e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105b11:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105b14:	73 10                	jae    105b26 <strnlen+0x2a>
  105b16:	8b 45 08             	mov    0x8(%ebp),%eax
  105b19:	8d 50 01             	lea    0x1(%eax),%edx
  105b1c:	89 55 08             	mov    %edx,0x8(%ebp)
  105b1f:	0f b6 00             	movzbl (%eax),%eax
  105b22:	84 c0                	test   %al,%al
  105b24:	75 e5                	jne    105b0b <strnlen+0xf>
    }
    return cnt;
  105b26:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  105b29:	89 ec                	mov    %ebp,%esp
  105b2b:	5d                   	pop    %ebp
  105b2c:	c3                   	ret    

00105b2d <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  105b2d:	55                   	push   %ebp
  105b2e:	89 e5                	mov    %esp,%ebp
  105b30:	57                   	push   %edi
  105b31:	56                   	push   %esi
  105b32:	83 ec 20             	sub    $0x20,%esp
  105b35:	8b 45 08             	mov    0x8(%ebp),%eax
  105b38:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105b3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b3e:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  105b41:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105b47:	89 d1                	mov    %edx,%ecx
  105b49:	89 c2                	mov    %eax,%edx
  105b4b:	89 ce                	mov    %ecx,%esi
  105b4d:	89 d7                	mov    %edx,%edi
  105b4f:	ac                   	lods   %ds:(%esi),%al
  105b50:	aa                   	stos   %al,%es:(%edi)
  105b51:	84 c0                	test   %al,%al
  105b53:	75 fa                	jne    105b4f <strcpy+0x22>
  105b55:	89 fa                	mov    %edi,%edx
  105b57:	89 f1                	mov    %esi,%ecx
  105b59:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  105b5c:	89 55 e8             	mov    %edx,-0x18(%ebp)
  105b5f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  105b62:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  105b65:	83 c4 20             	add    $0x20,%esp
  105b68:	5e                   	pop    %esi
  105b69:	5f                   	pop    %edi
  105b6a:	5d                   	pop    %ebp
  105b6b:	c3                   	ret    

00105b6c <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  105b6c:	55                   	push   %ebp
  105b6d:	89 e5                	mov    %esp,%ebp
  105b6f:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  105b72:	8b 45 08             	mov    0x8(%ebp),%eax
  105b75:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  105b78:	eb 1e                	jmp    105b98 <strncpy+0x2c>
        if ((*p = *src) != '\0') {
  105b7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b7d:	0f b6 10             	movzbl (%eax),%edx
  105b80:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105b83:	88 10                	mov    %dl,(%eax)
  105b85:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105b88:	0f b6 00             	movzbl (%eax),%eax
  105b8b:	84 c0                	test   %al,%al
  105b8d:	74 03                	je     105b92 <strncpy+0x26>
            src ++;
  105b8f:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
  105b92:	ff 45 fc             	incl   -0x4(%ebp)
  105b95:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
  105b98:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105b9c:	75 dc                	jne    105b7a <strncpy+0xe>
    }
    return dst;
  105b9e:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105ba1:	89 ec                	mov    %ebp,%esp
  105ba3:	5d                   	pop    %ebp
  105ba4:	c3                   	ret    

00105ba5 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  105ba5:	55                   	push   %ebp
  105ba6:	89 e5                	mov    %esp,%ebp
  105ba8:	57                   	push   %edi
  105ba9:	56                   	push   %esi
  105baa:	83 ec 20             	sub    $0x20,%esp
  105bad:	8b 45 08             	mov    0x8(%ebp),%eax
  105bb0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105bb3:	8b 45 0c             	mov    0xc(%ebp),%eax
  105bb6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  105bb9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105bbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105bbf:	89 d1                	mov    %edx,%ecx
  105bc1:	89 c2                	mov    %eax,%edx
  105bc3:	89 ce                	mov    %ecx,%esi
  105bc5:	89 d7                	mov    %edx,%edi
  105bc7:	ac                   	lods   %ds:(%esi),%al
  105bc8:	ae                   	scas   %es:(%edi),%al
  105bc9:	75 08                	jne    105bd3 <strcmp+0x2e>
  105bcb:	84 c0                	test   %al,%al
  105bcd:	75 f8                	jne    105bc7 <strcmp+0x22>
  105bcf:	31 c0                	xor    %eax,%eax
  105bd1:	eb 04                	jmp    105bd7 <strcmp+0x32>
  105bd3:	19 c0                	sbb    %eax,%eax
  105bd5:	0c 01                	or     $0x1,%al
  105bd7:	89 fa                	mov    %edi,%edx
  105bd9:	89 f1                	mov    %esi,%ecx
  105bdb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105bde:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  105be1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  105be4:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  105be7:	83 c4 20             	add    $0x20,%esp
  105bea:	5e                   	pop    %esi
  105beb:	5f                   	pop    %edi
  105bec:	5d                   	pop    %ebp
  105bed:	c3                   	ret    

00105bee <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  105bee:	55                   	push   %ebp
  105bef:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  105bf1:	eb 09                	jmp    105bfc <strncmp+0xe>
        n --, s1 ++, s2 ++;
  105bf3:	ff 4d 10             	decl   0x10(%ebp)
  105bf6:	ff 45 08             	incl   0x8(%ebp)
  105bf9:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  105bfc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105c00:	74 1a                	je     105c1c <strncmp+0x2e>
  105c02:	8b 45 08             	mov    0x8(%ebp),%eax
  105c05:	0f b6 00             	movzbl (%eax),%eax
  105c08:	84 c0                	test   %al,%al
  105c0a:	74 10                	je     105c1c <strncmp+0x2e>
  105c0c:	8b 45 08             	mov    0x8(%ebp),%eax
  105c0f:	0f b6 10             	movzbl (%eax),%edx
  105c12:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c15:	0f b6 00             	movzbl (%eax),%eax
  105c18:	38 c2                	cmp    %al,%dl
  105c1a:	74 d7                	je     105bf3 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  105c1c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105c20:	74 18                	je     105c3a <strncmp+0x4c>
  105c22:	8b 45 08             	mov    0x8(%ebp),%eax
  105c25:	0f b6 00             	movzbl (%eax),%eax
  105c28:	0f b6 d0             	movzbl %al,%edx
  105c2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c2e:	0f b6 00             	movzbl (%eax),%eax
  105c31:	0f b6 c8             	movzbl %al,%ecx
  105c34:	89 d0                	mov    %edx,%eax
  105c36:	29 c8                	sub    %ecx,%eax
  105c38:	eb 05                	jmp    105c3f <strncmp+0x51>
  105c3a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105c3f:	5d                   	pop    %ebp
  105c40:	c3                   	ret    

00105c41 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  105c41:	55                   	push   %ebp
  105c42:	89 e5                	mov    %esp,%ebp
  105c44:	83 ec 04             	sub    $0x4,%esp
  105c47:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c4a:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105c4d:	eb 13                	jmp    105c62 <strchr+0x21>
        if (*s == c) {
  105c4f:	8b 45 08             	mov    0x8(%ebp),%eax
  105c52:	0f b6 00             	movzbl (%eax),%eax
  105c55:	38 45 fc             	cmp    %al,-0x4(%ebp)
  105c58:	75 05                	jne    105c5f <strchr+0x1e>
            return (char *)s;
  105c5a:	8b 45 08             	mov    0x8(%ebp),%eax
  105c5d:	eb 12                	jmp    105c71 <strchr+0x30>
        }
        s ++;
  105c5f:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  105c62:	8b 45 08             	mov    0x8(%ebp),%eax
  105c65:	0f b6 00             	movzbl (%eax),%eax
  105c68:	84 c0                	test   %al,%al
  105c6a:	75 e3                	jne    105c4f <strchr+0xe>
    }
    return NULL;
  105c6c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105c71:	89 ec                	mov    %ebp,%esp
  105c73:	5d                   	pop    %ebp
  105c74:	c3                   	ret    

00105c75 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  105c75:	55                   	push   %ebp
  105c76:	89 e5                	mov    %esp,%ebp
  105c78:	83 ec 04             	sub    $0x4,%esp
  105c7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c7e:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105c81:	eb 0e                	jmp    105c91 <strfind+0x1c>
        if (*s == c) {
  105c83:	8b 45 08             	mov    0x8(%ebp),%eax
  105c86:	0f b6 00             	movzbl (%eax),%eax
  105c89:	38 45 fc             	cmp    %al,-0x4(%ebp)
  105c8c:	74 0f                	je     105c9d <strfind+0x28>
            break;
        }
        s ++;
  105c8e:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  105c91:	8b 45 08             	mov    0x8(%ebp),%eax
  105c94:	0f b6 00             	movzbl (%eax),%eax
  105c97:	84 c0                	test   %al,%al
  105c99:	75 e8                	jne    105c83 <strfind+0xe>
  105c9b:	eb 01                	jmp    105c9e <strfind+0x29>
            break;
  105c9d:	90                   	nop
    }
    return (char *)s;
  105c9e:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105ca1:	89 ec                	mov    %ebp,%esp
  105ca3:	5d                   	pop    %ebp
  105ca4:	c3                   	ret    

00105ca5 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  105ca5:	55                   	push   %ebp
  105ca6:	89 e5                	mov    %esp,%ebp
  105ca8:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  105cab:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  105cb2:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  105cb9:	eb 03                	jmp    105cbe <strtol+0x19>
        s ++;
  105cbb:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  105cbe:	8b 45 08             	mov    0x8(%ebp),%eax
  105cc1:	0f b6 00             	movzbl (%eax),%eax
  105cc4:	3c 20                	cmp    $0x20,%al
  105cc6:	74 f3                	je     105cbb <strtol+0x16>
  105cc8:	8b 45 08             	mov    0x8(%ebp),%eax
  105ccb:	0f b6 00             	movzbl (%eax),%eax
  105cce:	3c 09                	cmp    $0x9,%al
  105cd0:	74 e9                	je     105cbb <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
  105cd2:	8b 45 08             	mov    0x8(%ebp),%eax
  105cd5:	0f b6 00             	movzbl (%eax),%eax
  105cd8:	3c 2b                	cmp    $0x2b,%al
  105cda:	75 05                	jne    105ce1 <strtol+0x3c>
        s ++;
  105cdc:	ff 45 08             	incl   0x8(%ebp)
  105cdf:	eb 14                	jmp    105cf5 <strtol+0x50>
    }
    else if (*s == '-') {
  105ce1:	8b 45 08             	mov    0x8(%ebp),%eax
  105ce4:	0f b6 00             	movzbl (%eax),%eax
  105ce7:	3c 2d                	cmp    $0x2d,%al
  105ce9:	75 0a                	jne    105cf5 <strtol+0x50>
        s ++, neg = 1;
  105ceb:	ff 45 08             	incl   0x8(%ebp)
  105cee:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  105cf5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105cf9:	74 06                	je     105d01 <strtol+0x5c>
  105cfb:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  105cff:	75 22                	jne    105d23 <strtol+0x7e>
  105d01:	8b 45 08             	mov    0x8(%ebp),%eax
  105d04:	0f b6 00             	movzbl (%eax),%eax
  105d07:	3c 30                	cmp    $0x30,%al
  105d09:	75 18                	jne    105d23 <strtol+0x7e>
  105d0b:	8b 45 08             	mov    0x8(%ebp),%eax
  105d0e:	40                   	inc    %eax
  105d0f:	0f b6 00             	movzbl (%eax),%eax
  105d12:	3c 78                	cmp    $0x78,%al
  105d14:	75 0d                	jne    105d23 <strtol+0x7e>
        s += 2, base = 16;
  105d16:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  105d1a:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  105d21:	eb 29                	jmp    105d4c <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
  105d23:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105d27:	75 16                	jne    105d3f <strtol+0x9a>
  105d29:	8b 45 08             	mov    0x8(%ebp),%eax
  105d2c:	0f b6 00             	movzbl (%eax),%eax
  105d2f:	3c 30                	cmp    $0x30,%al
  105d31:	75 0c                	jne    105d3f <strtol+0x9a>
        s ++, base = 8;
  105d33:	ff 45 08             	incl   0x8(%ebp)
  105d36:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  105d3d:	eb 0d                	jmp    105d4c <strtol+0xa7>
    }
    else if (base == 0) {
  105d3f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105d43:	75 07                	jne    105d4c <strtol+0xa7>
        base = 10;
  105d45:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  105d4c:	8b 45 08             	mov    0x8(%ebp),%eax
  105d4f:	0f b6 00             	movzbl (%eax),%eax
  105d52:	3c 2f                	cmp    $0x2f,%al
  105d54:	7e 1b                	jle    105d71 <strtol+0xcc>
  105d56:	8b 45 08             	mov    0x8(%ebp),%eax
  105d59:	0f b6 00             	movzbl (%eax),%eax
  105d5c:	3c 39                	cmp    $0x39,%al
  105d5e:	7f 11                	jg     105d71 <strtol+0xcc>
            dig = *s - '0';
  105d60:	8b 45 08             	mov    0x8(%ebp),%eax
  105d63:	0f b6 00             	movzbl (%eax),%eax
  105d66:	0f be c0             	movsbl %al,%eax
  105d69:	83 e8 30             	sub    $0x30,%eax
  105d6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105d6f:	eb 48                	jmp    105db9 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
  105d71:	8b 45 08             	mov    0x8(%ebp),%eax
  105d74:	0f b6 00             	movzbl (%eax),%eax
  105d77:	3c 60                	cmp    $0x60,%al
  105d79:	7e 1b                	jle    105d96 <strtol+0xf1>
  105d7b:	8b 45 08             	mov    0x8(%ebp),%eax
  105d7e:	0f b6 00             	movzbl (%eax),%eax
  105d81:	3c 7a                	cmp    $0x7a,%al
  105d83:	7f 11                	jg     105d96 <strtol+0xf1>
            dig = *s - 'a' + 10;
  105d85:	8b 45 08             	mov    0x8(%ebp),%eax
  105d88:	0f b6 00             	movzbl (%eax),%eax
  105d8b:	0f be c0             	movsbl %al,%eax
  105d8e:	83 e8 57             	sub    $0x57,%eax
  105d91:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105d94:	eb 23                	jmp    105db9 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  105d96:	8b 45 08             	mov    0x8(%ebp),%eax
  105d99:	0f b6 00             	movzbl (%eax),%eax
  105d9c:	3c 40                	cmp    $0x40,%al
  105d9e:	7e 3b                	jle    105ddb <strtol+0x136>
  105da0:	8b 45 08             	mov    0x8(%ebp),%eax
  105da3:	0f b6 00             	movzbl (%eax),%eax
  105da6:	3c 5a                	cmp    $0x5a,%al
  105da8:	7f 31                	jg     105ddb <strtol+0x136>
            dig = *s - 'A' + 10;
  105daa:	8b 45 08             	mov    0x8(%ebp),%eax
  105dad:	0f b6 00             	movzbl (%eax),%eax
  105db0:	0f be c0             	movsbl %al,%eax
  105db3:	83 e8 37             	sub    $0x37,%eax
  105db6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  105db9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105dbc:	3b 45 10             	cmp    0x10(%ebp),%eax
  105dbf:	7d 19                	jge    105dda <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
  105dc1:	ff 45 08             	incl   0x8(%ebp)
  105dc4:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105dc7:	0f af 45 10          	imul   0x10(%ebp),%eax
  105dcb:	89 c2                	mov    %eax,%edx
  105dcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105dd0:	01 d0                	add    %edx,%eax
  105dd2:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
  105dd5:	e9 72 ff ff ff       	jmp    105d4c <strtol+0xa7>
            break;
  105dda:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
  105ddb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105ddf:	74 08                	je     105de9 <strtol+0x144>
        *endptr = (char *) s;
  105de1:	8b 45 0c             	mov    0xc(%ebp),%eax
  105de4:	8b 55 08             	mov    0x8(%ebp),%edx
  105de7:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  105de9:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  105ded:	74 07                	je     105df6 <strtol+0x151>
  105def:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105df2:	f7 d8                	neg    %eax
  105df4:	eb 03                	jmp    105df9 <strtol+0x154>
  105df6:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  105df9:	89 ec                	mov    %ebp,%esp
  105dfb:	5d                   	pop    %ebp
  105dfc:	c3                   	ret    

00105dfd <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  105dfd:	55                   	push   %ebp
  105dfe:	89 e5                	mov    %esp,%ebp
  105e00:	83 ec 28             	sub    $0x28,%esp
  105e03:	89 7d fc             	mov    %edi,-0x4(%ebp)
  105e06:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e09:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  105e0c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  105e10:	8b 45 08             	mov    0x8(%ebp),%eax
  105e13:	89 45 f8             	mov    %eax,-0x8(%ebp)
  105e16:	88 55 f7             	mov    %dl,-0x9(%ebp)
  105e19:	8b 45 10             	mov    0x10(%ebp),%eax
  105e1c:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  105e1f:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  105e22:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  105e26:	8b 55 f8             	mov    -0x8(%ebp),%edx
  105e29:	89 d7                	mov    %edx,%edi
  105e2b:	f3 aa                	rep stos %al,%es:(%edi)
  105e2d:	89 fa                	mov    %edi,%edx
  105e2f:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  105e32:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  105e35:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  105e38:	8b 7d fc             	mov    -0x4(%ebp),%edi
  105e3b:	89 ec                	mov    %ebp,%esp
  105e3d:	5d                   	pop    %ebp
  105e3e:	c3                   	ret    

00105e3f <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  105e3f:	55                   	push   %ebp
  105e40:	89 e5                	mov    %esp,%ebp
  105e42:	57                   	push   %edi
  105e43:	56                   	push   %esi
  105e44:	53                   	push   %ebx
  105e45:	83 ec 30             	sub    $0x30,%esp
  105e48:	8b 45 08             	mov    0x8(%ebp),%eax
  105e4b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105e4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e51:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105e54:	8b 45 10             	mov    0x10(%ebp),%eax
  105e57:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  105e5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105e5d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  105e60:	73 42                	jae    105ea4 <memmove+0x65>
  105e62:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105e65:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105e68:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105e6b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105e6e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105e71:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  105e74:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105e77:	c1 e8 02             	shr    $0x2,%eax
  105e7a:	89 c1                	mov    %eax,%ecx
    asm volatile (
  105e7c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105e7f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105e82:	89 d7                	mov    %edx,%edi
  105e84:	89 c6                	mov    %eax,%esi
  105e86:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  105e88:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  105e8b:	83 e1 03             	and    $0x3,%ecx
  105e8e:	74 02                	je     105e92 <memmove+0x53>
  105e90:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105e92:	89 f0                	mov    %esi,%eax
  105e94:	89 fa                	mov    %edi,%edx
  105e96:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  105e99:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  105e9c:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
  105e9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
  105ea2:	eb 36                	jmp    105eda <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  105ea4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105ea7:	8d 50 ff             	lea    -0x1(%eax),%edx
  105eaa:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105ead:	01 c2                	add    %eax,%edx
  105eaf:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105eb2:	8d 48 ff             	lea    -0x1(%eax),%ecx
  105eb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105eb8:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  105ebb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105ebe:	89 c1                	mov    %eax,%ecx
  105ec0:	89 d8                	mov    %ebx,%eax
  105ec2:	89 d6                	mov    %edx,%esi
  105ec4:	89 c7                	mov    %eax,%edi
  105ec6:	fd                   	std    
  105ec7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105ec9:	fc                   	cld    
  105eca:	89 f8                	mov    %edi,%eax
  105ecc:	89 f2                	mov    %esi,%edx
  105ece:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  105ed1:	89 55 c8             	mov    %edx,-0x38(%ebp)
  105ed4:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  105ed7:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  105eda:	83 c4 30             	add    $0x30,%esp
  105edd:	5b                   	pop    %ebx
  105ede:	5e                   	pop    %esi
  105edf:	5f                   	pop    %edi
  105ee0:	5d                   	pop    %ebp
  105ee1:	c3                   	ret    

00105ee2 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  105ee2:	55                   	push   %ebp
  105ee3:	89 e5                	mov    %esp,%ebp
  105ee5:	57                   	push   %edi
  105ee6:	56                   	push   %esi
  105ee7:	83 ec 20             	sub    $0x20,%esp
  105eea:	8b 45 08             	mov    0x8(%ebp),%eax
  105eed:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105ef0:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ef3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105ef6:	8b 45 10             	mov    0x10(%ebp),%eax
  105ef9:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  105efc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105eff:	c1 e8 02             	shr    $0x2,%eax
  105f02:	89 c1                	mov    %eax,%ecx
    asm volatile (
  105f04:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105f07:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105f0a:	89 d7                	mov    %edx,%edi
  105f0c:	89 c6                	mov    %eax,%esi
  105f0e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  105f10:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  105f13:	83 e1 03             	and    $0x3,%ecx
  105f16:	74 02                	je     105f1a <memcpy+0x38>
  105f18:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105f1a:	89 f0                	mov    %esi,%eax
  105f1c:	89 fa                	mov    %edi,%edx
  105f1e:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  105f21:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  105f24:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  105f27:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  105f2a:	83 c4 20             	add    $0x20,%esp
  105f2d:	5e                   	pop    %esi
  105f2e:	5f                   	pop    %edi
  105f2f:	5d                   	pop    %ebp
  105f30:	c3                   	ret    

00105f31 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  105f31:	55                   	push   %ebp
  105f32:	89 e5                	mov    %esp,%ebp
  105f34:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  105f37:	8b 45 08             	mov    0x8(%ebp),%eax
  105f3a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  105f3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105f40:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  105f43:	eb 2e                	jmp    105f73 <memcmp+0x42>
        if (*s1 != *s2) {
  105f45:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105f48:	0f b6 10             	movzbl (%eax),%edx
  105f4b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105f4e:	0f b6 00             	movzbl (%eax),%eax
  105f51:	38 c2                	cmp    %al,%dl
  105f53:	74 18                	je     105f6d <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  105f55:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105f58:	0f b6 00             	movzbl (%eax),%eax
  105f5b:	0f b6 d0             	movzbl %al,%edx
  105f5e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105f61:	0f b6 00             	movzbl (%eax),%eax
  105f64:	0f b6 c8             	movzbl %al,%ecx
  105f67:	89 d0                	mov    %edx,%eax
  105f69:	29 c8                	sub    %ecx,%eax
  105f6b:	eb 18                	jmp    105f85 <memcmp+0x54>
        }
        s1 ++, s2 ++;
  105f6d:	ff 45 fc             	incl   -0x4(%ebp)
  105f70:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
  105f73:	8b 45 10             	mov    0x10(%ebp),%eax
  105f76:	8d 50 ff             	lea    -0x1(%eax),%edx
  105f79:	89 55 10             	mov    %edx,0x10(%ebp)
  105f7c:	85 c0                	test   %eax,%eax
  105f7e:	75 c5                	jne    105f45 <memcmp+0x14>
    }
    return 0;
  105f80:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105f85:	89 ec                	mov    %ebp,%esp
  105f87:	5d                   	pop    %ebp
  105f88:	c3                   	ret    
