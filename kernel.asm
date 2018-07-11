
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:
8010000c:	0f 20 e0             	mov    %cr4,%eax
8010000f:	83 c8 10             	or     $0x10,%eax
80100012:	0f 22 e0             	mov    %eax,%cr4
80100015:	b8 00 b0 10 00       	mov    $0x10b000,%eax
8010001a:	0f 22 d8             	mov    %eax,%cr3
8010001d:	0f 20 c0             	mov    %cr0,%eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
80100025:	0f 22 c0             	mov    %eax,%cr0
80100028:	bc 50 d6 10 80       	mov    $0x8010d650,%esp
8010002d:	b8 e4 33 10 80       	mov    $0x801033e4,%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	c7 44 24 04 dc 89 10 	movl   $0x801089dc,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
80100049:	e8 0b 4f 00 00       	call   80104f59 <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 90 eb 10 80 84 	movl   $0x8010eb84,0x8010eb90
80100055:	eb 10 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 94 eb 10 80 84 	movl   $0x8010eb84,0x8010eb94
8010005f:	eb 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 94 d6 10 80 	movl   $0x8010d694,-0xc(%ebp)
80100069:	eb 3a                	jmp    801000a5 <binit+0x71>
    b->next = bcache.head.next;
8010006b:	8b 15 94 eb 10 80    	mov    0x8010eb94,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 0c 84 eb 10 80 	movl   $0x8010eb84,0xc(%eax)
    b->dev = -1;
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008b:	a1 94 eb 10 80       	mov    0x8010eb94,%eax
80100090:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100093:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100099:	a3 94 eb 10 80       	mov    %eax,0x8010eb94

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009e:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a5:	81 7d f4 84 eb 10 80 	cmpl   $0x8010eb84,-0xc(%ebp)
801000ac:	72 bd                	jb     8010006b <binit+0x37>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000ae:	c9                   	leave  
801000af:	c3                   	ret    

801000b0 <bget>:
// Look through buffer cache for sector on device dev.
// If not found, allocate fresh block.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint sector)
{
801000b0:	55                   	push   %ebp
801000b1:	89 e5                	mov    %esp,%ebp
801000b3:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b6:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
801000bd:	e8 b8 4e 00 00       	call   80104f7a <acquire>

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c2:	a1 94 eb 10 80       	mov    0x8010eb94,%eax
801000c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000ca:	eb 63                	jmp    8010012f <bget+0x7f>
    if(b->dev == dev && b->sector == sector){
801000cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000cf:	8b 40 04             	mov    0x4(%eax),%eax
801000d2:	3b 45 08             	cmp    0x8(%ebp),%eax
801000d5:	75 4f                	jne    80100126 <bget+0x76>
801000d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000da:	8b 40 08             	mov    0x8(%eax),%eax
801000dd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e0:	75 44                	jne    80100126 <bget+0x76>
      if(!(b->flags & B_BUSY)){
801000e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e5:	8b 00                	mov    (%eax),%eax
801000e7:	83 e0 01             	and    $0x1,%eax
801000ea:	85 c0                	test   %eax,%eax
801000ec:	75 23                	jne    80100111 <bget+0x61>
        b->flags |= B_BUSY;
801000ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f1:	8b 00                	mov    (%eax),%eax
801000f3:	83 c8 01             	or     $0x1,%eax
801000f6:	89 c2                	mov    %eax,%edx
801000f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fb:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
801000fd:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
80100104:	e8 d3 4e 00 00       	call   80104fdc <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 60 d6 10 	movl   $0x8010d660,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 c4 48 00 00       	call   801049e8 <sleep>
      goto loop;
80100124:	eb 9c                	jmp    801000c2 <bget+0x12>

  acquire(&bcache.lock);

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 10             	mov    0x10(%eax),%eax
8010012c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010012f:	81 7d f4 84 eb 10 80 	cmpl   $0x8010eb84,-0xc(%ebp)
80100136:	75 94                	jne    801000cc <bget+0x1c>
      goto loop;
    }
  }

  // Not cached; recycle some non-busy and clean buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100138:	a1 90 eb 10 80       	mov    0x8010eb90,%eax
8010013d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100140:	eb 4d                	jmp    8010018f <bget+0xdf>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
80100142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100145:	8b 00                	mov    (%eax),%eax
80100147:	83 e0 01             	and    $0x1,%eax
8010014a:	85 c0                	test   %eax,%eax
8010014c:	75 38                	jne    80100186 <bget+0xd6>
8010014e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100151:	8b 00                	mov    (%eax),%eax
80100153:	83 e0 04             	and    $0x4,%eax
80100156:	85 c0                	test   %eax,%eax
80100158:	75 2c                	jne    80100186 <bget+0xd6>
      b->dev = dev;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 55 08             	mov    0x8(%ebp),%edx
80100160:	89 50 04             	mov    %edx,0x4(%eax)
      b->sector = sector;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	8b 55 0c             	mov    0xc(%ebp),%edx
80100169:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100175:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
8010017c:	e8 5b 4e 00 00       	call   80104fdc <release>
      return b;
80100181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100184:	eb 1e                	jmp    801001a4 <bget+0xf4>
      goto loop;
    }
  }

  // Not cached; recycle some non-busy and clean buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100189:	8b 40 0c             	mov    0xc(%eax),%eax
8010018c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010018f:	81 7d f4 84 eb 10 80 	cmpl   $0x8010eb84,-0xc(%ebp)
80100196:	75 aa                	jne    80100142 <bget+0x92>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100198:	c7 04 24 e3 89 10 80 	movl   $0x801089e3,(%esp)
8010019f:	e8 96 03 00 00       	call   8010053a <panic>
}
801001a4:	c9                   	leave  
801001a5:	c3                   	ret    

801001a6 <bread>:

// Return a B_BUSY buf with the contents of the indicated disk sector.
struct buf*
bread(uint dev, uint sector)
{
801001a6:	55                   	push   %ebp
801001a7:	89 e5                	mov    %esp,%ebp
801001a9:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  b = bget(dev, sector);
801001ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801001af:	89 44 24 04          	mov    %eax,0x4(%esp)
801001b3:	8b 45 08             	mov    0x8(%ebp),%eax
801001b6:	89 04 24             	mov    %eax,(%esp)
801001b9:	e8 f2 fe ff ff       	call   801000b0 <bget>
801001be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID))
801001c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001c4:	8b 00                	mov    (%eax),%eax
801001c6:	83 e0 02             	and    $0x2,%eax
801001c9:	85 c0                	test   %eax,%eax
801001cb:	75 0b                	jne    801001d8 <bread+0x32>
    iderw(b);
801001cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d0:	89 04 24             	mov    %eax,(%esp)
801001d3:	e8 e8 25 00 00       	call   801027c0 <iderw>
  return b;
801001d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001db:	c9                   	leave  
801001dc:	c3                   	ret    

801001dd <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001dd:	55                   	push   %ebp
801001de:	89 e5                	mov    %esp,%ebp
801001e0:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
801001e3:	8b 45 08             	mov    0x8(%ebp),%eax
801001e6:	8b 00                	mov    (%eax),%eax
801001e8:	83 e0 01             	and    $0x1,%eax
801001eb:	85 c0                	test   %eax,%eax
801001ed:	75 0c                	jne    801001fb <bwrite+0x1e>
    panic("bwrite");
801001ef:	c7 04 24 f4 89 10 80 	movl   $0x801089f4,(%esp)
801001f6:	e8 3f 03 00 00       	call   8010053a <panic>
  b->flags |= B_DIRTY;
801001fb:	8b 45 08             	mov    0x8(%ebp),%eax
801001fe:	8b 00                	mov    (%eax),%eax
80100200:	83 c8 04             	or     $0x4,%eax
80100203:	89 c2                	mov    %eax,%edx
80100205:	8b 45 08             	mov    0x8(%ebp),%eax
80100208:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010020a:	8b 45 08             	mov    0x8(%ebp),%eax
8010020d:	89 04 24             	mov    %eax,(%esp)
80100210:	e8 ab 25 00 00       	call   801027c0 <iderw>
}
80100215:	c9                   	leave  
80100216:	c3                   	ret    

80100217 <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100217:	55                   	push   %ebp
80100218:	89 e5                	mov    %esp,%ebp
8010021a:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
8010021d:	8b 45 08             	mov    0x8(%ebp),%eax
80100220:	8b 00                	mov    (%eax),%eax
80100222:	83 e0 01             	and    $0x1,%eax
80100225:	85 c0                	test   %eax,%eax
80100227:	75 0c                	jne    80100235 <brelse+0x1e>
    panic("brelse");
80100229:	c7 04 24 fb 89 10 80 	movl   $0x801089fb,(%esp)
80100230:	e8 05 03 00 00       	call   8010053a <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
8010023c:	e8 39 4d 00 00       	call   80104f7a <acquire>

  b->next->prev = b->prev;
80100241:	8b 45 08             	mov    0x8(%ebp),%eax
80100244:	8b 40 10             	mov    0x10(%eax),%eax
80100247:	8b 55 08             	mov    0x8(%ebp),%edx
8010024a:	8b 52 0c             	mov    0xc(%edx),%edx
8010024d:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	8b 40 0c             	mov    0xc(%eax),%eax
80100256:	8b 55 08             	mov    0x8(%ebp),%edx
80100259:	8b 52 10             	mov    0x10(%edx),%edx
8010025c:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010025f:	8b 15 94 eb 10 80    	mov    0x8010eb94,%edx
80100265:	8b 45 08             	mov    0x8(%ebp),%eax
80100268:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	c7 40 0c 84 eb 10 80 	movl   $0x8010eb84,0xc(%eax)
  bcache.head.next->prev = b;
80100275:	a1 94 eb 10 80       	mov    0x8010eb94,%eax
8010027a:	8b 55 08             	mov    0x8(%ebp),%edx
8010027d:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100280:	8b 45 08             	mov    0x8(%ebp),%eax
80100283:	a3 94 eb 10 80       	mov    %eax,0x8010eb94

  b->flags &= ~B_BUSY;
80100288:	8b 45 08             	mov    0x8(%ebp),%eax
8010028b:	8b 00                	mov    (%eax),%eax
8010028d:	83 e0 fe             	and    $0xfffffffe,%eax
80100290:	89 c2                	mov    %eax,%edx
80100292:	8b 45 08             	mov    0x8(%ebp),%eax
80100295:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80100297:	8b 45 08             	mov    0x8(%ebp),%eax
8010029a:	89 04 24             	mov    %eax,(%esp)
8010029d:	e8 1f 48 00 00       	call   80104ac1 <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
801002a9:	e8 2e 4d 00 00       	call   80104fdc <release>
}
801002ae:	c9                   	leave  
801002af:	c3                   	ret    

801002b0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002b0:	55                   	push   %ebp
801002b1:	89 e5                	mov    %esp,%ebp
801002b3:	83 ec 14             	sub    $0x14,%esp
801002b6:	8b 45 08             	mov    0x8(%ebp),%eax
801002b9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002bd:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002c1:	89 c2                	mov    %eax,%edx
801002c3:	ec                   	in     (%dx),%al
801002c4:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002c7:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002cb:	c9                   	leave  
801002cc:	c3                   	ret    

801002cd <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002cd:	55                   	push   %ebp
801002ce:	89 e5                	mov    %esp,%ebp
801002d0:	83 ec 08             	sub    $0x8,%esp
801002d3:	8b 55 08             	mov    0x8(%ebp),%edx
801002d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801002d9:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801002dd:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801002e0:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801002e4:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801002e8:	ee                   	out    %al,(%dx)
}
801002e9:	c9                   	leave  
801002ea:	c3                   	ret    

801002eb <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801002eb:	55                   	push   %ebp
801002ec:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801002ee:	fa                   	cli    
}
801002ef:	5d                   	pop    %ebp
801002f0:	c3                   	ret    

801002f1 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	56                   	push   %esi
801002f5:	53                   	push   %ebx
801002f6:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
801002f9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801002fd:	74 1c                	je     8010031b <printint+0x2a>
801002ff:	8b 45 08             	mov    0x8(%ebp),%eax
80100302:	c1 e8 1f             	shr    $0x1f,%eax
80100305:	0f b6 c0             	movzbl %al,%eax
80100308:	89 45 10             	mov    %eax,0x10(%ebp)
8010030b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010030f:	74 0a                	je     8010031b <printint+0x2a>
    x = -xx;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	f7 d8                	neg    %eax
80100316:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100319:	eb 06                	jmp    80100321 <printint+0x30>
  else
    x = xx;
8010031b:	8b 45 08             	mov    0x8(%ebp),%eax
8010031e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100321:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100328:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010032b:	8d 41 01             	lea    0x1(%ecx),%eax
8010032e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100331:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100334:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100337:	ba 00 00 00 00       	mov    $0x0,%edx
8010033c:	f7 f3                	div    %ebx
8010033e:	89 d0                	mov    %edx,%eax
80100340:	0f b6 80 04 a0 10 80 	movzbl -0x7fef5ffc(%eax),%eax
80100347:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
8010034b:	8b 75 0c             	mov    0xc(%ebp),%esi
8010034e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100351:	ba 00 00 00 00       	mov    $0x0,%edx
80100356:	f7 f6                	div    %esi
80100358:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010035b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010035f:	75 c7                	jne    80100328 <printint+0x37>

  if(sign)
80100361:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100365:	74 10                	je     80100377 <printint+0x86>
    buf[i++] = '-';
80100367:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010036a:	8d 50 01             	lea    0x1(%eax),%edx
8010036d:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100370:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
80100375:	eb 18                	jmp    8010038f <printint+0x9e>
80100377:	eb 16                	jmp    8010038f <printint+0x9e>
    consputc(buf[i]);
80100379:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010037c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010037f:	01 d0                	add    %edx,%eax
80100381:	0f b6 00             	movzbl (%eax),%eax
80100384:	0f be c0             	movsbl %al,%eax
80100387:	89 04 24             	mov    %eax,(%esp)
8010038a:	e8 c1 03 00 00       	call   80100750 <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
8010038f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100393:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100397:	79 e0                	jns    80100379 <printint+0x88>
    consputc(buf[i]);
}
80100399:	83 c4 30             	add    $0x30,%esp
8010039c:	5b                   	pop    %ebx
8010039d:	5e                   	pop    %esi
8010039e:	5d                   	pop    %ebp
8010039f:	c3                   	ret    

801003a0 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003a0:	55                   	push   %ebp
801003a1:	89 e5                	mov    %esp,%ebp
801003a3:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003a6:	a1 f4 c5 10 80       	mov    0x8010c5f4,%eax
801003ab:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003ae:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003b2:	74 0c                	je     801003c0 <cprintf+0x20>
    acquire(&cons.lock);
801003b4:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
801003bb:	e8 ba 4b 00 00       	call   80104f7a <acquire>

  if (fmt == 0)
801003c0:	8b 45 08             	mov    0x8(%ebp),%eax
801003c3:	85 c0                	test   %eax,%eax
801003c5:	75 0c                	jne    801003d3 <cprintf+0x33>
    panic("null fmt");
801003c7:	c7 04 24 02 8a 10 80 	movl   $0x80108a02,(%esp)
801003ce:	e8 67 01 00 00       	call   8010053a <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003d3:	8d 45 0c             	lea    0xc(%ebp),%eax
801003d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801003d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801003e0:	e9 21 01 00 00       	jmp    80100506 <cprintf+0x166>
    if(c != '%'){
801003e5:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801003e9:	74 10                	je     801003fb <cprintf+0x5b>
      consputc(c);
801003eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801003ee:	89 04 24             	mov    %eax,(%esp)
801003f1:	e8 5a 03 00 00       	call   80100750 <consputc>
      continue;
801003f6:	e9 07 01 00 00       	jmp    80100502 <cprintf+0x162>
    }
    c = fmt[++i] & 0xff;
801003fb:	8b 55 08             	mov    0x8(%ebp),%edx
801003fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100402:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100405:	01 d0                	add    %edx,%eax
80100407:	0f b6 00             	movzbl (%eax),%eax
8010040a:	0f be c0             	movsbl %al,%eax
8010040d:	25 ff 00 00 00       	and    $0xff,%eax
80100412:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100415:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100419:	75 05                	jne    80100420 <cprintf+0x80>
      break;
8010041b:	e9 06 01 00 00       	jmp    80100526 <cprintf+0x186>
    switch(c){
80100420:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100423:	83 f8 70             	cmp    $0x70,%eax
80100426:	74 4f                	je     80100477 <cprintf+0xd7>
80100428:	83 f8 70             	cmp    $0x70,%eax
8010042b:	7f 13                	jg     80100440 <cprintf+0xa0>
8010042d:	83 f8 25             	cmp    $0x25,%eax
80100430:	0f 84 a6 00 00 00    	je     801004dc <cprintf+0x13c>
80100436:	83 f8 64             	cmp    $0x64,%eax
80100439:	74 14                	je     8010044f <cprintf+0xaf>
8010043b:	e9 aa 00 00 00       	jmp    801004ea <cprintf+0x14a>
80100440:	83 f8 73             	cmp    $0x73,%eax
80100443:	74 57                	je     8010049c <cprintf+0xfc>
80100445:	83 f8 78             	cmp    $0x78,%eax
80100448:	74 2d                	je     80100477 <cprintf+0xd7>
8010044a:	e9 9b 00 00 00       	jmp    801004ea <cprintf+0x14a>
    case 'd':
      printint(*argp++, 10, 1);
8010044f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100452:	8d 50 04             	lea    0x4(%eax),%edx
80100455:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100458:	8b 00                	mov    (%eax),%eax
8010045a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80100461:	00 
80100462:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80100469:	00 
8010046a:	89 04 24             	mov    %eax,(%esp)
8010046d:	e8 7f fe ff ff       	call   801002f1 <printint>
      break;
80100472:	e9 8b 00 00 00       	jmp    80100502 <cprintf+0x162>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100477:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010047a:	8d 50 04             	lea    0x4(%eax),%edx
8010047d:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100480:	8b 00                	mov    (%eax),%eax
80100482:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100489:	00 
8010048a:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80100491:	00 
80100492:	89 04 24             	mov    %eax,(%esp)
80100495:	e8 57 fe ff ff       	call   801002f1 <printint>
      break;
8010049a:	eb 66                	jmp    80100502 <cprintf+0x162>
    case 's':
      if((s = (char*)*argp++) == 0)
8010049c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049f:	8d 50 04             	lea    0x4(%eax),%edx
801004a2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a5:	8b 00                	mov    (%eax),%eax
801004a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004aa:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004ae:	75 09                	jne    801004b9 <cprintf+0x119>
        s = "(null)";
801004b0:	c7 45 ec 0b 8a 10 80 	movl   $0x80108a0b,-0x14(%ebp)
      for(; *s; s++)
801004b7:	eb 17                	jmp    801004d0 <cprintf+0x130>
801004b9:	eb 15                	jmp    801004d0 <cprintf+0x130>
        consputc(*s);
801004bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004be:	0f b6 00             	movzbl (%eax),%eax
801004c1:	0f be c0             	movsbl %al,%eax
801004c4:	89 04 24             	mov    %eax,(%esp)
801004c7:	e8 84 02 00 00       	call   80100750 <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004cc:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d3:	0f b6 00             	movzbl (%eax),%eax
801004d6:	84 c0                	test   %al,%al
801004d8:	75 e1                	jne    801004bb <cprintf+0x11b>
        consputc(*s);
      break;
801004da:	eb 26                	jmp    80100502 <cprintf+0x162>
    case '%':
      consputc('%');
801004dc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004e3:	e8 68 02 00 00       	call   80100750 <consputc>
      break;
801004e8:	eb 18                	jmp    80100502 <cprintf+0x162>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801004ea:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004f1:	e8 5a 02 00 00       	call   80100750 <consputc>
      consputc(c);
801004f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004f9:	89 04 24             	mov    %eax,(%esp)
801004fc:	e8 4f 02 00 00       	call   80100750 <consputc>
      break;
80100501:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100502:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100506:	8b 55 08             	mov    0x8(%ebp),%edx
80100509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010050c:	01 d0                	add    %edx,%eax
8010050e:	0f b6 00             	movzbl (%eax),%eax
80100511:	0f be c0             	movsbl %al,%eax
80100514:	25 ff 00 00 00       	and    $0xff,%eax
80100519:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010051c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100520:	0f 85 bf fe ff ff    	jne    801003e5 <cprintf+0x45>
      consputc(c);
      break;
    }
  }

  if(locking)
80100526:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010052a:	74 0c                	je     80100538 <cprintf+0x198>
    release(&cons.lock);
8010052c:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100533:	e8 a4 4a 00 00       	call   80104fdc <release>
}
80100538:	c9                   	leave  
80100539:	c3                   	ret    

8010053a <panic>:

void
panic(char *s)
{
8010053a:	55                   	push   %ebp
8010053b:	89 e5                	mov    %esp,%ebp
8010053d:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];
  
  cli();
80100540:	e8 a6 fd ff ff       	call   801002eb <cli>
  cons.locking = 0;
80100545:	c7 05 f4 c5 10 80 00 	movl   $0x0,0x8010c5f4
8010054c:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010054f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100555:	0f b6 00             	movzbl (%eax),%eax
80100558:	0f b6 c0             	movzbl %al,%eax
8010055b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010055f:	c7 04 24 12 8a 10 80 	movl   $0x80108a12,(%esp)
80100566:	e8 35 fe ff ff       	call   801003a0 <cprintf>
  cprintf(s);
8010056b:	8b 45 08             	mov    0x8(%ebp),%eax
8010056e:	89 04 24             	mov    %eax,(%esp)
80100571:	e8 2a fe ff ff       	call   801003a0 <cprintf>
  cprintf("\n");
80100576:	c7 04 24 21 8a 10 80 	movl   $0x80108a21,(%esp)
8010057d:	e8 1e fe ff ff       	call   801003a0 <cprintf>
  getcallerpcs(&s, pcs);
80100582:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100585:	89 44 24 04          	mov    %eax,0x4(%esp)
80100589:	8d 45 08             	lea    0x8(%ebp),%eax
8010058c:	89 04 24             	mov    %eax,(%esp)
8010058f:	e8 97 4a 00 00       	call   8010502b <getcallerpcs>
  for(i=0; i<10; i++)
80100594:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059b:	eb 1b                	jmp    801005b8 <panic+0x7e>
    cprintf(" %p", pcs[i]);
8010059d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a0:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801005a8:	c7 04 24 23 8a 10 80 	movl   $0x80108a23,(%esp)
801005af:	e8 ec fd ff ff       	call   801003a0 <cprintf>
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005b4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005b8:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005bc:	7e df                	jle    8010059d <panic+0x63>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005be:	c7 05 a0 c5 10 80 01 	movl   $0x1,0x8010c5a0
801005c5:	00 00 00 
  for(;;)
    ;
801005c8:	eb fe                	jmp    801005c8 <panic+0x8e>

801005ca <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801005ca:	55                   	push   %ebp
801005cb:	89 e5                	mov    %esp,%ebp
801005cd:	83 ec 28             	sub    $0x28,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005d0:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801005d7:	00 
801005d8:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801005df:	e8 e9 fc ff ff       	call   801002cd <outb>
  pos = inb(CRTPORT+1) << 8;
801005e4:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801005eb:	e8 c0 fc ff ff       	call   801002b0 <inb>
801005f0:	0f b6 c0             	movzbl %al,%eax
801005f3:	c1 e0 08             	shl    $0x8,%eax
801005f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
801005f9:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100600:	00 
80100601:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100608:	e8 c0 fc ff ff       	call   801002cd <outb>
  pos |= inb(CRTPORT+1);
8010060d:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100614:	e8 97 fc ff ff       	call   801002b0 <inb>
80100619:	0f b6 c0             	movzbl %al,%eax
8010061c:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
8010061f:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100623:	75 30                	jne    80100655 <cgaputc+0x8b>
    pos += 80 - pos%80;
80100625:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100628:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010062d:	89 c8                	mov    %ecx,%eax
8010062f:	f7 ea                	imul   %edx
80100631:	c1 fa 05             	sar    $0x5,%edx
80100634:	89 c8                	mov    %ecx,%eax
80100636:	c1 f8 1f             	sar    $0x1f,%eax
80100639:	29 c2                	sub    %eax,%edx
8010063b:	89 d0                	mov    %edx,%eax
8010063d:	c1 e0 02             	shl    $0x2,%eax
80100640:	01 d0                	add    %edx,%eax
80100642:	c1 e0 04             	shl    $0x4,%eax
80100645:	29 c1                	sub    %eax,%ecx
80100647:	89 ca                	mov    %ecx,%edx
80100649:	b8 50 00 00 00       	mov    $0x50,%eax
8010064e:	29 d0                	sub    %edx,%eax
80100650:	01 45 f4             	add    %eax,-0xc(%ebp)
80100653:	eb 35                	jmp    8010068a <cgaputc+0xc0>
  else if(c == BACKSPACE){
80100655:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010065c:	75 0c                	jne    8010066a <cgaputc+0xa0>
    if(pos > 0) --pos;
8010065e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100662:	7e 26                	jle    8010068a <cgaputc+0xc0>
80100664:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100668:	eb 20                	jmp    8010068a <cgaputc+0xc0>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010066a:	8b 0d 00 a0 10 80    	mov    0x8010a000,%ecx
80100670:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100673:	8d 50 01             	lea    0x1(%eax),%edx
80100676:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100679:	01 c0                	add    %eax,%eax
8010067b:	8d 14 01             	lea    (%ecx,%eax,1),%edx
8010067e:	8b 45 08             	mov    0x8(%ebp),%eax
80100681:	0f b6 c0             	movzbl %al,%eax
80100684:	80 cc 07             	or     $0x7,%ah
80100687:	66 89 02             	mov    %ax,(%edx)
  
  if((pos/80) >= 24){  // Scroll up.
8010068a:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
80100691:	7e 53                	jle    801006e6 <cgaputc+0x11c>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100693:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100698:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
8010069e:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006a3:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006aa:	00 
801006ab:	89 54 24 04          	mov    %edx,0x4(%esp)
801006af:	89 04 24             	mov    %eax,(%esp)
801006b2:	e8 e6 4b 00 00       	call   8010529d <memmove>
    pos -= 80;
801006b7:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006bb:	b8 80 07 00 00       	mov    $0x780,%eax
801006c0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006c3:	8d 14 00             	lea    (%eax,%eax,1),%edx
801006c6:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006cb:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006ce:	01 c9                	add    %ecx,%ecx
801006d0:	01 c8                	add    %ecx,%eax
801006d2:	89 54 24 08          	mov    %edx,0x8(%esp)
801006d6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801006dd:	00 
801006de:	89 04 24             	mov    %eax,(%esp)
801006e1:	e8 e8 4a 00 00       	call   801051ce <memset>
  }
  
  outb(CRTPORT, 14);
801006e6:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801006ed:	00 
801006ee:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801006f5:	e8 d3 fb ff ff       	call   801002cd <outb>
  outb(CRTPORT+1, pos>>8);
801006fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006fd:	c1 f8 08             	sar    $0x8,%eax
80100700:	0f b6 c0             	movzbl %al,%eax
80100703:	89 44 24 04          	mov    %eax,0x4(%esp)
80100707:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
8010070e:	e8 ba fb ff ff       	call   801002cd <outb>
  outb(CRTPORT, 15);
80100713:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
8010071a:	00 
8010071b:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100722:	e8 a6 fb ff ff       	call   801002cd <outb>
  outb(CRTPORT+1, pos);
80100727:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010072a:	0f b6 c0             	movzbl %al,%eax
8010072d:	89 44 24 04          	mov    %eax,0x4(%esp)
80100731:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100738:	e8 90 fb ff ff       	call   801002cd <outb>
  crt[pos] = ' ' | 0x0700;
8010073d:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100742:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100745:	01 d2                	add    %edx,%edx
80100747:	01 d0                	add    %edx,%eax
80100749:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
8010074e:	c9                   	leave  
8010074f:	c3                   	ret    

80100750 <consputc>:

void
consputc(int c)
{
80100750:	55                   	push   %ebp
80100751:	89 e5                	mov    %esp,%ebp
80100753:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
80100756:	a1 a0 c5 10 80       	mov    0x8010c5a0,%eax
8010075b:	85 c0                	test   %eax,%eax
8010075d:	74 07                	je     80100766 <consputc+0x16>
    cli();
8010075f:	e8 87 fb ff ff       	call   801002eb <cli>
    for(;;)
      ;
80100764:	eb fe                	jmp    80100764 <consputc+0x14>
  }

  if(c == BACKSPACE){
80100766:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010076d:	75 26                	jne    80100795 <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010076f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100776:	e8 72 64 00 00       	call   80106bed <uartputc>
8010077b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100782:	e8 66 64 00 00       	call   80106bed <uartputc>
80100787:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010078e:	e8 5a 64 00 00       	call   80106bed <uartputc>
80100793:	eb 0b                	jmp    801007a0 <consputc+0x50>
  } else
    uartputc(c);
80100795:	8b 45 08             	mov    0x8(%ebp),%eax
80100798:	89 04 24             	mov    %eax,(%esp)
8010079b:	e8 4d 64 00 00       	call   80106bed <uartputc>
  cgaputc(c);
801007a0:	8b 45 08             	mov    0x8(%ebp),%eax
801007a3:	89 04 24             	mov    %eax,(%esp)
801007a6:	e8 1f fe ff ff       	call   801005ca <cgaputc>
}
801007ab:	c9                   	leave  
801007ac:	c3                   	ret    

801007ad <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007ad:	55                   	push   %ebp
801007ae:	89 e5                	mov    %esp,%ebp
801007b0:	83 ec 28             	sub    $0x28,%esp
  int c;

  acquire(&input.lock);
801007b3:	c7 04 24 a0 ed 10 80 	movl   $0x8010eda0,(%esp)
801007ba:	e8 bb 47 00 00       	call   80104f7a <acquire>
  while((c = getc()) >= 0){
801007bf:	e9 37 01 00 00       	jmp    801008fb <consoleintr+0x14e>
    switch(c){
801007c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007c7:	83 f8 10             	cmp    $0x10,%eax
801007ca:	74 1e                	je     801007ea <consoleintr+0x3d>
801007cc:	83 f8 10             	cmp    $0x10,%eax
801007cf:	7f 0a                	jg     801007db <consoleintr+0x2e>
801007d1:	83 f8 08             	cmp    $0x8,%eax
801007d4:	74 64                	je     8010083a <consoleintr+0x8d>
801007d6:	e9 91 00 00 00       	jmp    8010086c <consoleintr+0xbf>
801007db:	83 f8 15             	cmp    $0x15,%eax
801007de:	74 2f                	je     8010080f <consoleintr+0x62>
801007e0:	83 f8 7f             	cmp    $0x7f,%eax
801007e3:	74 55                	je     8010083a <consoleintr+0x8d>
801007e5:	e9 82 00 00 00       	jmp    8010086c <consoleintr+0xbf>
    case C('P'):  // Process listing.
      procdump();
801007ea:	e8 75 43 00 00       	call   80104b64 <procdump>
      break;
801007ef:	e9 07 01 00 00       	jmp    801008fb <consoleintr+0x14e>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
801007f4:	a1 5c ee 10 80       	mov    0x8010ee5c,%eax
801007f9:	83 e8 01             	sub    $0x1,%eax
801007fc:	a3 5c ee 10 80       	mov    %eax,0x8010ee5c
        consputc(BACKSPACE);
80100801:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100808:	e8 43 ff ff ff       	call   80100750 <consputc>
8010080d:	eb 01                	jmp    80100810 <consoleintr+0x63>
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010080f:	90                   	nop
80100810:	8b 15 5c ee 10 80    	mov    0x8010ee5c,%edx
80100816:	a1 58 ee 10 80       	mov    0x8010ee58,%eax
8010081b:	39 c2                	cmp    %eax,%edx
8010081d:	74 16                	je     80100835 <consoleintr+0x88>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010081f:	a1 5c ee 10 80       	mov    0x8010ee5c,%eax
80100824:	83 e8 01             	sub    $0x1,%eax
80100827:	83 e0 7f             	and    $0x7f,%eax
8010082a:	0f b6 80 d4 ed 10 80 	movzbl -0x7fef122c(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100831:	3c 0a                	cmp    $0xa,%al
80100833:	75 bf                	jne    801007f4 <consoleintr+0x47>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100835:	e9 c1 00 00 00       	jmp    801008fb <consoleintr+0x14e>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
8010083a:	8b 15 5c ee 10 80    	mov    0x8010ee5c,%edx
80100840:	a1 58 ee 10 80       	mov    0x8010ee58,%eax
80100845:	39 c2                	cmp    %eax,%edx
80100847:	74 1e                	je     80100867 <consoleintr+0xba>
        input.e--;
80100849:	a1 5c ee 10 80       	mov    0x8010ee5c,%eax
8010084e:	83 e8 01             	sub    $0x1,%eax
80100851:	a3 5c ee 10 80       	mov    %eax,0x8010ee5c
        consputc(BACKSPACE);
80100856:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010085d:	e8 ee fe ff ff       	call   80100750 <consputc>
      }
      break;
80100862:	e9 94 00 00 00       	jmp    801008fb <consoleintr+0x14e>
80100867:	e9 8f 00 00 00       	jmp    801008fb <consoleintr+0x14e>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
8010086c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100870:	0f 84 84 00 00 00    	je     801008fa <consoleintr+0x14d>
80100876:	8b 15 5c ee 10 80    	mov    0x8010ee5c,%edx
8010087c:	a1 54 ee 10 80       	mov    0x8010ee54,%eax
80100881:	29 c2                	sub    %eax,%edx
80100883:	89 d0                	mov    %edx,%eax
80100885:	83 f8 7f             	cmp    $0x7f,%eax
80100888:	77 70                	ja     801008fa <consoleintr+0x14d>
        c = (c == '\r') ? '\n' : c;
8010088a:	83 7d f4 0d          	cmpl   $0xd,-0xc(%ebp)
8010088e:	74 05                	je     80100895 <consoleintr+0xe8>
80100890:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100893:	eb 05                	jmp    8010089a <consoleintr+0xed>
80100895:	b8 0a 00 00 00       	mov    $0xa,%eax
8010089a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
8010089d:	a1 5c ee 10 80       	mov    0x8010ee5c,%eax
801008a2:	8d 50 01             	lea    0x1(%eax),%edx
801008a5:	89 15 5c ee 10 80    	mov    %edx,0x8010ee5c
801008ab:	83 e0 7f             	and    $0x7f,%eax
801008ae:	89 c2                	mov    %eax,%edx
801008b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008b3:	88 82 d4 ed 10 80    	mov    %al,-0x7fef122c(%edx)
        consputc(c);
801008b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008bc:	89 04 24             	mov    %eax,(%esp)
801008bf:	e8 8c fe ff ff       	call   80100750 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801008c4:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
801008c8:	74 18                	je     801008e2 <consoleintr+0x135>
801008ca:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
801008ce:	74 12                	je     801008e2 <consoleintr+0x135>
801008d0:	a1 5c ee 10 80       	mov    0x8010ee5c,%eax
801008d5:	8b 15 54 ee 10 80    	mov    0x8010ee54,%edx
801008db:	83 ea 80             	sub    $0xffffff80,%edx
801008de:	39 d0                	cmp    %edx,%eax
801008e0:	75 18                	jne    801008fa <consoleintr+0x14d>
          input.w = input.e;
801008e2:	a1 5c ee 10 80       	mov    0x8010ee5c,%eax
801008e7:	a3 58 ee 10 80       	mov    %eax,0x8010ee58
          wakeup(&input.r);
801008ec:	c7 04 24 54 ee 10 80 	movl   $0x8010ee54,(%esp)
801008f3:	e8 c9 41 00 00       	call   80104ac1 <wakeup>
        }
      }
      break;
801008f8:	eb 00                	jmp    801008fa <consoleintr+0x14d>
801008fa:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
801008fb:	8b 45 08             	mov    0x8(%ebp),%eax
801008fe:	ff d0                	call   *%eax
80100900:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100903:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100907:	0f 89 b7 fe ff ff    	jns    801007c4 <consoleintr+0x17>
        }
      }
      break;
    }
  }
  release(&input.lock);
8010090d:	c7 04 24 a0 ed 10 80 	movl   $0x8010eda0,(%esp)
80100914:	e8 c3 46 00 00       	call   80104fdc <release>
}
80100919:	c9                   	leave  
8010091a:	c3                   	ret    

8010091b <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
8010091b:	55                   	push   %ebp
8010091c:	89 e5                	mov    %esp,%ebp
8010091e:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
80100921:	8b 45 08             	mov    0x8(%ebp),%eax
80100924:	89 04 24             	mov    %eax,(%esp)
80100927:	e8 9c 10 00 00       	call   801019c8 <iunlock>
  target = n;
8010092c:	8b 45 10             	mov    0x10(%ebp),%eax
8010092f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
80100932:	c7 04 24 a0 ed 10 80 	movl   $0x8010eda0,(%esp)
80100939:	e8 3c 46 00 00       	call   80104f7a <acquire>
  while(n > 0){
8010093e:	e9 aa 00 00 00       	jmp    801009ed <consoleread+0xd2>
    while(input.r == input.w){
80100943:	eb 42                	jmp    80100987 <consoleread+0x6c>
      if(proc->killed){
80100945:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010094b:	8b 40 24             	mov    0x24(%eax),%eax
8010094e:	85 c0                	test   %eax,%eax
80100950:	74 21                	je     80100973 <consoleread+0x58>
        release(&input.lock);
80100952:	c7 04 24 a0 ed 10 80 	movl   $0x8010eda0,(%esp)
80100959:	e8 7e 46 00 00       	call   80104fdc <release>
        ilock(ip);
8010095e:	8b 45 08             	mov    0x8(%ebp),%eax
80100961:	89 04 24             	mov    %eax,(%esp)
80100964:	e8 11 0f 00 00       	call   8010187a <ilock>
        return -1;
80100969:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010096e:	e9 a5 00 00 00       	jmp    80100a18 <consoleread+0xfd>
      }
      sleep(&input.r, &input.lock);
80100973:	c7 44 24 04 a0 ed 10 	movl   $0x8010eda0,0x4(%esp)
8010097a:	80 
8010097b:	c7 04 24 54 ee 10 80 	movl   $0x8010ee54,(%esp)
80100982:	e8 61 40 00 00       	call   801049e8 <sleep>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
80100987:	8b 15 54 ee 10 80    	mov    0x8010ee54,%edx
8010098d:	a1 58 ee 10 80       	mov    0x8010ee58,%eax
80100992:	39 c2                	cmp    %eax,%edx
80100994:	74 af                	je     80100945 <consoleread+0x2a>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100996:	a1 54 ee 10 80       	mov    0x8010ee54,%eax
8010099b:	8d 50 01             	lea    0x1(%eax),%edx
8010099e:	89 15 54 ee 10 80    	mov    %edx,0x8010ee54
801009a4:	83 e0 7f             	and    $0x7f,%eax
801009a7:	0f b6 80 d4 ed 10 80 	movzbl -0x7fef122c(%eax),%eax
801009ae:	0f be c0             	movsbl %al,%eax
801009b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
801009b4:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801009b8:	75 19                	jne    801009d3 <consoleread+0xb8>
      if(n < target){
801009ba:	8b 45 10             	mov    0x10(%ebp),%eax
801009bd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801009c0:	73 0f                	jae    801009d1 <consoleread+0xb6>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
801009c2:	a1 54 ee 10 80       	mov    0x8010ee54,%eax
801009c7:	83 e8 01             	sub    $0x1,%eax
801009ca:	a3 54 ee 10 80       	mov    %eax,0x8010ee54
      }
      break;
801009cf:	eb 26                	jmp    801009f7 <consoleread+0xdc>
801009d1:	eb 24                	jmp    801009f7 <consoleread+0xdc>
    }
    *dst++ = c;
801009d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801009d6:	8d 50 01             	lea    0x1(%eax),%edx
801009d9:	89 55 0c             	mov    %edx,0xc(%ebp)
801009dc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801009df:	88 10                	mov    %dl,(%eax)
    --n;
801009e1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
801009e5:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
801009e9:	75 02                	jne    801009ed <consoleread+0xd2>
      break;
801009eb:	eb 0a                	jmp    801009f7 <consoleread+0xdc>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
801009ed:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801009f1:	0f 8f 4c ff ff ff    	jg     80100943 <consoleread+0x28>
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
  }
  release(&input.lock);
801009f7:	c7 04 24 a0 ed 10 80 	movl   $0x8010eda0,(%esp)
801009fe:	e8 d9 45 00 00       	call   80104fdc <release>
  ilock(ip);
80100a03:	8b 45 08             	mov    0x8(%ebp),%eax
80100a06:	89 04 24             	mov    %eax,(%esp)
80100a09:	e8 6c 0e 00 00       	call   8010187a <ilock>

  return target - n;
80100a0e:	8b 45 10             	mov    0x10(%ebp),%eax
80100a11:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a14:	29 c2                	sub    %eax,%edx
80100a16:	89 d0                	mov    %edx,%eax
}
80100a18:	c9                   	leave  
80100a19:	c3                   	ret    

80100a1a <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a1a:	55                   	push   %ebp
80100a1b:	89 e5                	mov    %esp,%ebp
80100a1d:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100a20:	8b 45 08             	mov    0x8(%ebp),%eax
80100a23:	89 04 24             	mov    %eax,(%esp)
80100a26:	e8 9d 0f 00 00       	call   801019c8 <iunlock>
  acquire(&cons.lock);
80100a2b:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100a32:	e8 43 45 00 00       	call   80104f7a <acquire>
  for(i = 0; i < n; i++)
80100a37:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a3e:	eb 1d                	jmp    80100a5d <consolewrite+0x43>
    consputc(buf[i] & 0xff);
80100a40:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a43:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a46:	01 d0                	add    %edx,%eax
80100a48:	0f b6 00             	movzbl (%eax),%eax
80100a4b:	0f be c0             	movsbl %al,%eax
80100a4e:	0f b6 c0             	movzbl %al,%eax
80100a51:	89 04 24             	mov    %eax,(%esp)
80100a54:	e8 f7 fc ff ff       	call   80100750 <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100a59:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a60:	3b 45 10             	cmp    0x10(%ebp),%eax
80100a63:	7c db                	jl     80100a40 <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100a65:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100a6c:	e8 6b 45 00 00       	call   80104fdc <release>
  ilock(ip);
80100a71:	8b 45 08             	mov    0x8(%ebp),%eax
80100a74:	89 04 24             	mov    %eax,(%esp)
80100a77:	e8 fe 0d 00 00       	call   8010187a <ilock>

  return n;
80100a7c:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100a7f:	c9                   	leave  
80100a80:	c3                   	ret    

80100a81 <consoleinit>:

void
consoleinit(void)
{
80100a81:	55                   	push   %ebp
80100a82:	89 e5                	mov    %esp,%ebp
80100a84:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100a87:	c7 44 24 04 27 8a 10 	movl   $0x80108a27,0x4(%esp)
80100a8e:	80 
80100a8f:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100a96:	e8 be 44 00 00       	call   80104f59 <initlock>
  initlock(&input.lock, "input");
80100a9b:	c7 44 24 04 2f 8a 10 	movl   $0x80108a2f,0x4(%esp)
80100aa2:	80 
80100aa3:	c7 04 24 a0 ed 10 80 	movl   $0x8010eda0,(%esp)
80100aaa:	e8 aa 44 00 00       	call   80104f59 <initlock>

  devsw[CONSOLE].write = consolewrite;
80100aaf:	c7 05 0c f8 10 80 1a 	movl   $0x80100a1a,0x8010f80c
80100ab6:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100ab9:	c7 05 08 f8 10 80 1b 	movl   $0x8010091b,0x8010f808
80100ac0:	09 10 80 
  cons.locking = 1;
80100ac3:	c7 05 f4 c5 10 80 01 	movl   $0x1,0x8010c5f4
80100aca:	00 00 00 

  picenable(IRQ_KBD);
80100acd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100ad4:	e8 b8 2f 00 00       	call   80103a91 <picenable>
  ioapicenable(IRQ_KBD, 0);
80100ad9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100ae0:	00 
80100ae1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100ae8:	e8 8f 1e 00 00       	call   8010297c <ioapicenable>
}
80100aed:	c9                   	leave  
80100aee:	c3                   	ret    

80100aef <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100aef:	55                   	push   %ebp
80100af0:	89 e5                	mov    %esp,%ebp
80100af2:	53                   	push   %ebx
80100af3:	81 ec 34 01 00 00    	sub    $0x134,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  if((ip = namei(path)) == 0)
80100af9:	8b 45 08             	mov    0x8(%ebp),%eax
80100afc:	89 04 24             	mov    %eax,(%esp)
80100aff:	e8 21 19 00 00       	call   80102425 <namei>
80100b04:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100b07:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100b0b:	75 0a                	jne    80100b17 <exec+0x28>
    return -1;
80100b0d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b12:	e9 09 04 00 00       	jmp    80100f20 <exec+0x431>
  ilock(ip);
80100b17:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100b1a:	89 04 24             	mov    %eax,(%esp)
80100b1d:	e8 58 0d 00 00       	call   8010187a <ilock>
  pgdir = 0;
80100b22:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100b29:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100b30:	00 
80100b31:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100b38:	00 
80100b39:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100b3f:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b43:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100b46:	89 04 24             	mov    %eax,(%esp)
80100b49:	e8 39 12 00 00       	call   80101d87 <readi>
80100b4e:	83 f8 33             	cmp    $0x33,%eax
80100b51:	77 05                	ja     80100b58 <exec+0x69>
    goto bad;
80100b53:	e9 a1 03 00 00       	jmp    80100ef9 <exec+0x40a>
  if(elf.magic != ELF_MAGIC)
80100b58:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100b5e:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100b63:	74 05                	je     80100b6a <exec+0x7b>
    goto bad;
80100b65:	e9 8f 03 00 00       	jmp    80100ef9 <exec+0x40a>

  if((pgdir = setupkvm(kalloc)) == 0)
80100b6a:	c7 04 24 01 2b 10 80 	movl   $0x80102b01,(%esp)
80100b71:	e8 dc 71 00 00       	call   80107d52 <setupkvm>
80100b76:	89 45 d0             	mov    %eax,-0x30(%ebp)
80100b79:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
80100b7d:	75 05                	jne    80100b84 <exec+0x95>
    goto bad;
80100b7f:	e9 75 03 00 00       	jmp    80100ef9 <exec+0x40a>

  // Load program into memory.
  // TASK2 carregamos o programa a partir da segunda pagina, evitando acesso ao endereço 0
  sz = PGSIZE;
80100b84:	c7 45 e0 00 10 00 00 	movl   $0x1000,-0x20(%ebp)
  
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100b8b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100b92:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100b98:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100b9b:	e9 ef 00 00 00       	jmp    80100c8f <exec+0x1a0>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100ba0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100ba3:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100baa:	00 
80100bab:	89 44 24 08          	mov    %eax,0x8(%esp)
80100baf:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100bb5:	89 44 24 04          	mov    %eax,0x4(%esp)
80100bb9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100bbc:	89 04 24             	mov    %eax,(%esp)
80100bbf:	e8 c3 11 00 00       	call   80101d87 <readi>
80100bc4:	83 f8 20             	cmp    $0x20,%eax
80100bc7:	74 05                	je     80100bce <exec+0xdf>
      goto bad;
80100bc9:	e9 2b 03 00 00       	jmp    80100ef9 <exec+0x40a>
    if(ph.type != ELF_PROG_LOAD)
80100bce:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100bd4:	83 f8 01             	cmp    $0x1,%eax
80100bd7:	74 05                	je     80100bde <exec+0xef>
      continue;
80100bd9:	e9 a4 00 00 00       	jmp    80100c82 <exec+0x193>
    if(ph.memsz < ph.filesz)
80100bde:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100be4:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100bea:	39 c2                	cmp    %eax,%edx
80100bec:	73 05                	jae    80100bf3 <exec+0x104>
      goto bad;
80100bee:	e9 06 03 00 00       	jmp    80100ef9 <exec+0x40a>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100bf3:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100bf9:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100bff:	01 d0                	add    %edx,%eax
80100c01:	89 44 24 08          	mov    %eax,0x8(%esp)
80100c05:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c08:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c0c:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100c0f:	89 04 24             	mov    %eax,(%esp)
80100c12:	e8 23 75 00 00       	call   8010813a <allocuvm>
80100c17:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c1a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c1e:	75 05                	jne    80100c25 <exec+0x136>
      goto bad;
80100c20:	e9 d4 02 00 00       	jmp    80100ef9 <exec+0x40a>
    if (ph.flags & ELF_PROG_FLAG_WRITE)
80100c25:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c2b:	83 e0 02             	and    $0x2,%eax
80100c2e:	85 c0                	test   %eax,%eax
80100c30:	74 09                	je     80100c3b <exec+0x14c>
    	writeFlag = 1;
80100c32:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
80100c39:	eb 07                	jmp    80100c42 <exec+0x153>
    else
    	writeFlag = 0;
80100c3b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz,writeFlag) < 0)
80100c42:	8b 8d f8 fe ff ff    	mov    -0x108(%ebp),%ecx
80100c48:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100c4e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c54:	8b 5d d8             	mov    -0x28(%ebp),%ebx
80100c57:	89 5c 24 14          	mov    %ebx,0x14(%esp)
80100c5b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100c5f:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100c63:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100c66:	89 54 24 08          	mov    %edx,0x8(%esp)
80100c6a:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c6e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100c71:	89 04 24             	mov    %eax,(%esp)
80100c74:	e8 bc 73 00 00       	call   80108035 <loaduvm>
80100c79:	85 c0                	test   %eax,%eax
80100c7b:	79 05                	jns    80100c82 <exec+0x193>
    {
      goto bad;
80100c7d:	e9 77 02 00 00       	jmp    80100ef9 <exec+0x40a>

  // Load program into memory.
  // TASK2 carregamos o programa a partir da segunda pagina, evitando acesso ao endereço 0
  sz = PGSIZE;
  
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c82:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100c86:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c89:	83 c0 20             	add    $0x20,%eax
80100c8c:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c8f:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100c96:	0f b7 c0             	movzwl %ax,%eax
80100c99:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100c9c:	0f 8f fe fe ff ff    	jg     80100ba0 <exec+0xb1>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz,writeFlag) < 0)
    {
      goto bad;
    }
  }
  iunlockput(ip);
80100ca2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100ca5:	89 04 24             	mov    %eax,(%esp)
80100ca8:	e8 51 0e 00 00       	call   80101afe <iunlockput>
  ip = 0;
80100cad:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100cb4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cb7:	05 ff 0f 00 00       	add    $0xfff,%eax
80100cbc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100cc1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100cc4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cc7:	05 00 20 00 00       	add    $0x2000,%eax
80100ccc:	89 44 24 08          	mov    %eax,0x8(%esp)
80100cd0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cd3:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cd7:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100cda:	89 04 24             	mov    %eax,(%esp)
80100cdd:	e8 58 74 00 00       	call   8010813a <allocuvm>
80100ce2:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100ce5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100ce9:	75 05                	jne    80100cf0 <exec+0x201>
    goto bad;
80100ceb:	e9 09 02 00 00       	jmp    80100ef9 <exec+0x40a>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100cf0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cf3:	2d 00 20 00 00       	sub    $0x2000,%eax
80100cf8:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cfc:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100cff:	89 04 24             	mov    %eax,(%esp)
80100d02:	e8 ab 76 00 00       	call   801083b2 <clearpteu>
  sp = sz;
80100d07:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d0a:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d0d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d14:	e9 9a 00 00 00       	jmp    80100db3 <exec+0x2c4>
    if(argc >= MAXARG)
80100d19:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d1d:	76 05                	jbe    80100d24 <exec+0x235>
      goto bad;
80100d1f:	e9 d5 01 00 00       	jmp    80100ef9 <exec+0x40a>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d27:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d2e:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d31:	01 d0                	add    %edx,%eax
80100d33:	8b 00                	mov    (%eax),%eax
80100d35:	89 04 24             	mov    %eax,(%esp)
80100d38:	e8 fb 46 00 00       	call   80105438 <strlen>
80100d3d:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100d40:	29 c2                	sub    %eax,%edx
80100d42:	89 d0                	mov    %edx,%eax
80100d44:	83 e8 01             	sub    $0x1,%eax
80100d47:	83 e0 fc             	and    $0xfffffffc,%eax
80100d4a:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d4d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d50:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d57:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d5a:	01 d0                	add    %edx,%eax
80100d5c:	8b 00                	mov    (%eax),%eax
80100d5e:	89 04 24             	mov    %eax,(%esp)
80100d61:	e8 d2 46 00 00       	call   80105438 <strlen>
80100d66:	83 c0 01             	add    $0x1,%eax
80100d69:	89 c2                	mov    %eax,%edx
80100d6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d6e:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100d75:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d78:	01 c8                	add    %ecx,%eax
80100d7a:	8b 00                	mov    (%eax),%eax
80100d7c:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100d80:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d84:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d87:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d8b:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100d8e:	89 04 24             	mov    %eax,(%esp)
80100d91:	e8 9a 7b 00 00       	call   80108930 <copyout>
80100d96:	85 c0                	test   %eax,%eax
80100d98:	79 05                	jns    80100d9f <exec+0x2b0>
      goto bad;
80100d9a:	e9 5a 01 00 00       	jmp    80100ef9 <exec+0x40a>
    ustack[3+argc] = sp;
80100d9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100da2:	8d 50 03             	lea    0x3(%eax),%edx
80100da5:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100da8:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100daf:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100db3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100db6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dbd:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dc0:	01 d0                	add    %edx,%eax
80100dc2:	8b 00                	mov    (%eax),%eax
80100dc4:	85 c0                	test   %eax,%eax
80100dc6:	0f 85 4d ff ff ff    	jne    80100d19 <exec+0x22a>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100dcc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dcf:	83 c0 03             	add    $0x3,%eax
80100dd2:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100dd9:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100ddd:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100de4:	ff ff ff 
  ustack[1] = argc;
80100de7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dea:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100df0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100df3:	83 c0 01             	add    $0x1,%eax
80100df6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dfd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e00:	29 d0                	sub    %edx,%eax
80100e02:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100e08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e0b:	83 c0 04             	add    $0x4,%eax
80100e0e:	c1 e0 02             	shl    $0x2,%eax
80100e11:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e17:	83 c0 04             	add    $0x4,%eax
80100e1a:	c1 e0 02             	shl    $0x2,%eax
80100e1d:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100e21:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100e27:	89 44 24 08          	mov    %eax,0x8(%esp)
80100e2b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e2e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e32:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100e35:	89 04 24             	mov    %eax,(%esp)
80100e38:	e8 f3 7a 00 00       	call   80108930 <copyout>
80100e3d:	85 c0                	test   %eax,%eax
80100e3f:	79 05                	jns    80100e46 <exec+0x357>
    goto bad;
80100e41:	e9 b3 00 00 00       	jmp    80100ef9 <exec+0x40a>

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e46:	8b 45 08             	mov    0x8(%ebp),%eax
80100e49:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e4f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e52:	eb 17                	jmp    80100e6b <exec+0x37c>
    if(*s == '/')
80100e54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e57:	0f b6 00             	movzbl (%eax),%eax
80100e5a:	3c 2f                	cmp    $0x2f,%al
80100e5c:	75 09                	jne    80100e67 <exec+0x378>
      last = s+1;
80100e5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e61:	83 c0 01             	add    $0x1,%eax
80100e64:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e67:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e6e:	0f b6 00             	movzbl (%eax),%eax
80100e71:	84 c0                	test   %al,%al
80100e73:	75 df                	jne    80100e54 <exec+0x365>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e75:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e7b:	8d 50 6c             	lea    0x6c(%eax),%edx
80100e7e:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100e85:	00 
80100e86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100e89:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e8d:	89 14 24             	mov    %edx,(%esp)
80100e90:	e8 59 45 00 00       	call   801053ee <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100e95:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e9b:	8b 40 04             	mov    0x4(%eax),%eax
80100e9e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  proc->pgdir = pgdir;
80100ea1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ea7:	8b 55 d0             	mov    -0x30(%ebp),%edx
80100eaa:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100ead:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eb3:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100eb6:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100eb8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ebe:	8b 40 18             	mov    0x18(%eax),%eax
80100ec1:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100ec7:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100eca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ed0:	8b 40 18             	mov    0x18(%eax),%eax
80100ed3:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100ed6:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100ed9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100edf:	89 04 24             	mov    %eax,(%esp)
80100ee2:	e8 5c 6f 00 00       	call   80107e43 <switchuvm>
  freevm(oldpgdir);
80100ee7:	8b 45 cc             	mov    -0x34(%ebp),%eax
80100eea:	89 04 24             	mov    %eax,(%esp)
80100eed:	e8 26 74 00 00       	call   80108318 <freevm>
  return 0;
80100ef2:	b8 00 00 00 00       	mov    $0x0,%eax
80100ef7:	eb 27                	jmp    80100f20 <exec+0x431>

 bad:
  if(pgdir)
80100ef9:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
80100efd:	74 0b                	je     80100f0a <exec+0x41b>
    freevm(pgdir);
80100eff:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f02:	89 04 24             	mov    %eax,(%esp)
80100f05:	e8 0e 74 00 00       	call   80108318 <freevm>
  if(ip)
80100f0a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f0e:	74 0b                	je     80100f1b <exec+0x42c>
    iunlockput(ip);
80100f10:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f13:	89 04 24             	mov    %eax,(%esp)
80100f16:	e8 e3 0b 00 00       	call   80101afe <iunlockput>
  return -1;
80100f1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f20:	81 c4 34 01 00 00    	add    $0x134,%esp
80100f26:	5b                   	pop    %ebx
80100f27:	5d                   	pop    %ebp
80100f28:	c3                   	ret    

80100f29 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f29:	55                   	push   %ebp
80100f2a:	89 e5                	mov    %esp,%ebp
80100f2c:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80100f2f:	c7 44 24 04 35 8a 10 	movl   $0x80108a35,0x4(%esp)
80100f36:	80 
80100f37:	c7 04 24 60 ee 10 80 	movl   $0x8010ee60,(%esp)
80100f3e:	e8 16 40 00 00       	call   80104f59 <initlock>
}
80100f43:	c9                   	leave  
80100f44:	c3                   	ret    

80100f45 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f45:	55                   	push   %ebp
80100f46:	89 e5                	mov    %esp,%ebp
80100f48:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f4b:	c7 04 24 60 ee 10 80 	movl   $0x8010ee60,(%esp)
80100f52:	e8 23 40 00 00       	call   80104f7a <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f57:	c7 45 f4 94 ee 10 80 	movl   $0x8010ee94,-0xc(%ebp)
80100f5e:	eb 29                	jmp    80100f89 <filealloc+0x44>
    if(f->ref == 0){
80100f60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f63:	8b 40 04             	mov    0x4(%eax),%eax
80100f66:	85 c0                	test   %eax,%eax
80100f68:	75 1b                	jne    80100f85 <filealloc+0x40>
      f->ref = 1;
80100f6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f6d:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100f74:	c7 04 24 60 ee 10 80 	movl   $0x8010ee60,(%esp)
80100f7b:	e8 5c 40 00 00       	call   80104fdc <release>
      return f;
80100f80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f83:	eb 1e                	jmp    80100fa3 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f85:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100f89:	81 7d f4 f4 f7 10 80 	cmpl   $0x8010f7f4,-0xc(%ebp)
80100f90:	72 ce                	jb     80100f60 <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100f92:	c7 04 24 60 ee 10 80 	movl   $0x8010ee60,(%esp)
80100f99:	e8 3e 40 00 00       	call   80104fdc <release>
  return 0;
80100f9e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100fa3:	c9                   	leave  
80100fa4:	c3                   	ret    

80100fa5 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100fa5:	55                   	push   %ebp
80100fa6:	89 e5                	mov    %esp,%ebp
80100fa8:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80100fab:	c7 04 24 60 ee 10 80 	movl   $0x8010ee60,(%esp)
80100fb2:	e8 c3 3f 00 00       	call   80104f7a <acquire>
  if(f->ref < 1)
80100fb7:	8b 45 08             	mov    0x8(%ebp),%eax
80100fba:	8b 40 04             	mov    0x4(%eax),%eax
80100fbd:	85 c0                	test   %eax,%eax
80100fbf:	7f 0c                	jg     80100fcd <filedup+0x28>
    panic("filedup");
80100fc1:	c7 04 24 3c 8a 10 80 	movl   $0x80108a3c,(%esp)
80100fc8:	e8 6d f5 ff ff       	call   8010053a <panic>
  f->ref++;
80100fcd:	8b 45 08             	mov    0x8(%ebp),%eax
80100fd0:	8b 40 04             	mov    0x4(%eax),%eax
80100fd3:	8d 50 01             	lea    0x1(%eax),%edx
80100fd6:	8b 45 08             	mov    0x8(%ebp),%eax
80100fd9:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80100fdc:	c7 04 24 60 ee 10 80 	movl   $0x8010ee60,(%esp)
80100fe3:	e8 f4 3f 00 00       	call   80104fdc <release>
  return f;
80100fe8:	8b 45 08             	mov    0x8(%ebp),%eax
}
80100feb:	c9                   	leave  
80100fec:	c3                   	ret    

80100fed <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100fed:	55                   	push   %ebp
80100fee:	89 e5                	mov    %esp,%ebp
80100ff0:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
80100ff3:	c7 04 24 60 ee 10 80 	movl   $0x8010ee60,(%esp)
80100ffa:	e8 7b 3f 00 00       	call   80104f7a <acquire>
  if(f->ref < 1)
80100fff:	8b 45 08             	mov    0x8(%ebp),%eax
80101002:	8b 40 04             	mov    0x4(%eax),%eax
80101005:	85 c0                	test   %eax,%eax
80101007:	7f 0c                	jg     80101015 <fileclose+0x28>
    panic("fileclose");
80101009:	c7 04 24 44 8a 10 80 	movl   $0x80108a44,(%esp)
80101010:	e8 25 f5 ff ff       	call   8010053a <panic>
  if(--f->ref > 0){
80101015:	8b 45 08             	mov    0x8(%ebp),%eax
80101018:	8b 40 04             	mov    0x4(%eax),%eax
8010101b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010101e:	8b 45 08             	mov    0x8(%ebp),%eax
80101021:	89 50 04             	mov    %edx,0x4(%eax)
80101024:	8b 45 08             	mov    0x8(%ebp),%eax
80101027:	8b 40 04             	mov    0x4(%eax),%eax
8010102a:	85 c0                	test   %eax,%eax
8010102c:	7e 11                	jle    8010103f <fileclose+0x52>
    release(&ftable.lock);
8010102e:	c7 04 24 60 ee 10 80 	movl   $0x8010ee60,(%esp)
80101035:	e8 a2 3f 00 00       	call   80104fdc <release>
8010103a:	e9 82 00 00 00       	jmp    801010c1 <fileclose+0xd4>
    return;
  }
  ff = *f;
8010103f:	8b 45 08             	mov    0x8(%ebp),%eax
80101042:	8b 10                	mov    (%eax),%edx
80101044:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101047:	8b 50 04             	mov    0x4(%eax),%edx
8010104a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010104d:	8b 50 08             	mov    0x8(%eax),%edx
80101050:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101053:	8b 50 0c             	mov    0xc(%eax),%edx
80101056:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101059:	8b 50 10             	mov    0x10(%eax),%edx
8010105c:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010105f:	8b 40 14             	mov    0x14(%eax),%eax
80101062:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101065:	8b 45 08             	mov    0x8(%ebp),%eax
80101068:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010106f:	8b 45 08             	mov    0x8(%ebp),%eax
80101072:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101078:	c7 04 24 60 ee 10 80 	movl   $0x8010ee60,(%esp)
8010107f:	e8 58 3f 00 00       	call   80104fdc <release>
  
  if(ff.type == FD_PIPE)
80101084:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101087:	83 f8 01             	cmp    $0x1,%eax
8010108a:	75 18                	jne    801010a4 <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
8010108c:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101090:	0f be d0             	movsbl %al,%edx
80101093:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101096:	89 54 24 04          	mov    %edx,0x4(%esp)
8010109a:	89 04 24             	mov    %eax,(%esp)
8010109d:	e8 9f 2c 00 00       	call   80103d41 <pipeclose>
801010a2:	eb 1d                	jmp    801010c1 <fileclose+0xd4>
  else if(ff.type == FD_INODE){
801010a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010a7:	83 f8 02             	cmp    $0x2,%eax
801010aa:	75 15                	jne    801010c1 <fileclose+0xd4>
    begin_trans();
801010ac:	e8 53 21 00 00       	call   80103204 <begin_trans>
    iput(ff.ip);
801010b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801010b4:	89 04 24             	mov    %eax,(%esp)
801010b7:	e8 71 09 00 00       	call   80101a2d <iput>
    commit_trans();
801010bc:	e8 8c 21 00 00       	call   8010324d <commit_trans>
  }
}
801010c1:	c9                   	leave  
801010c2:	c3                   	ret    

801010c3 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801010c3:	55                   	push   %ebp
801010c4:	89 e5                	mov    %esp,%ebp
801010c6:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
801010c9:	8b 45 08             	mov    0x8(%ebp),%eax
801010cc:	8b 00                	mov    (%eax),%eax
801010ce:	83 f8 02             	cmp    $0x2,%eax
801010d1:	75 38                	jne    8010110b <filestat+0x48>
    ilock(f->ip);
801010d3:	8b 45 08             	mov    0x8(%ebp),%eax
801010d6:	8b 40 10             	mov    0x10(%eax),%eax
801010d9:	89 04 24             	mov    %eax,(%esp)
801010dc:	e8 99 07 00 00       	call   8010187a <ilock>
    stati(f->ip, st);
801010e1:	8b 45 08             	mov    0x8(%ebp),%eax
801010e4:	8b 40 10             	mov    0x10(%eax),%eax
801010e7:	8b 55 0c             	mov    0xc(%ebp),%edx
801010ea:	89 54 24 04          	mov    %edx,0x4(%esp)
801010ee:	89 04 24             	mov    %eax,(%esp)
801010f1:	e8 4c 0c 00 00       	call   80101d42 <stati>
    iunlock(f->ip);
801010f6:	8b 45 08             	mov    0x8(%ebp),%eax
801010f9:	8b 40 10             	mov    0x10(%eax),%eax
801010fc:	89 04 24             	mov    %eax,(%esp)
801010ff:	e8 c4 08 00 00       	call   801019c8 <iunlock>
    return 0;
80101104:	b8 00 00 00 00       	mov    $0x0,%eax
80101109:	eb 05                	jmp    80101110 <filestat+0x4d>
  }
  return -1;
8010110b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101110:	c9                   	leave  
80101111:	c3                   	ret    

80101112 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101112:	55                   	push   %ebp
80101113:	89 e5                	mov    %esp,%ebp
80101115:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
80101118:	8b 45 08             	mov    0x8(%ebp),%eax
8010111b:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010111f:	84 c0                	test   %al,%al
80101121:	75 0a                	jne    8010112d <fileread+0x1b>
    return -1;
80101123:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101128:	e9 9f 00 00 00       	jmp    801011cc <fileread+0xba>
  if(f->type == FD_PIPE)
8010112d:	8b 45 08             	mov    0x8(%ebp),%eax
80101130:	8b 00                	mov    (%eax),%eax
80101132:	83 f8 01             	cmp    $0x1,%eax
80101135:	75 1e                	jne    80101155 <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101137:	8b 45 08             	mov    0x8(%ebp),%eax
8010113a:	8b 40 0c             	mov    0xc(%eax),%eax
8010113d:	8b 55 10             	mov    0x10(%ebp),%edx
80101140:	89 54 24 08          	mov    %edx,0x8(%esp)
80101144:	8b 55 0c             	mov    0xc(%ebp),%edx
80101147:	89 54 24 04          	mov    %edx,0x4(%esp)
8010114b:	89 04 24             	mov    %eax,(%esp)
8010114e:	e8 6f 2d 00 00       	call   80103ec2 <piperead>
80101153:	eb 77                	jmp    801011cc <fileread+0xba>
  if(f->type == FD_INODE){
80101155:	8b 45 08             	mov    0x8(%ebp),%eax
80101158:	8b 00                	mov    (%eax),%eax
8010115a:	83 f8 02             	cmp    $0x2,%eax
8010115d:	75 61                	jne    801011c0 <fileread+0xae>
    ilock(f->ip);
8010115f:	8b 45 08             	mov    0x8(%ebp),%eax
80101162:	8b 40 10             	mov    0x10(%eax),%eax
80101165:	89 04 24             	mov    %eax,(%esp)
80101168:	e8 0d 07 00 00       	call   8010187a <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010116d:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101170:	8b 45 08             	mov    0x8(%ebp),%eax
80101173:	8b 50 14             	mov    0x14(%eax),%edx
80101176:	8b 45 08             	mov    0x8(%ebp),%eax
80101179:	8b 40 10             	mov    0x10(%eax),%eax
8010117c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101180:	89 54 24 08          	mov    %edx,0x8(%esp)
80101184:	8b 55 0c             	mov    0xc(%ebp),%edx
80101187:	89 54 24 04          	mov    %edx,0x4(%esp)
8010118b:	89 04 24             	mov    %eax,(%esp)
8010118e:	e8 f4 0b 00 00       	call   80101d87 <readi>
80101193:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101196:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010119a:	7e 11                	jle    801011ad <fileread+0x9b>
      f->off += r;
8010119c:	8b 45 08             	mov    0x8(%ebp),%eax
8010119f:	8b 50 14             	mov    0x14(%eax),%edx
801011a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011a5:	01 c2                	add    %eax,%edx
801011a7:	8b 45 08             	mov    0x8(%ebp),%eax
801011aa:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801011ad:	8b 45 08             	mov    0x8(%ebp),%eax
801011b0:	8b 40 10             	mov    0x10(%eax),%eax
801011b3:	89 04 24             	mov    %eax,(%esp)
801011b6:	e8 0d 08 00 00       	call   801019c8 <iunlock>
    return r;
801011bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011be:	eb 0c                	jmp    801011cc <fileread+0xba>
  }
  panic("fileread");
801011c0:	c7 04 24 4e 8a 10 80 	movl   $0x80108a4e,(%esp)
801011c7:	e8 6e f3 ff ff       	call   8010053a <panic>
}
801011cc:	c9                   	leave  
801011cd:	c3                   	ret    

801011ce <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801011ce:	55                   	push   %ebp
801011cf:	89 e5                	mov    %esp,%ebp
801011d1:	53                   	push   %ebx
801011d2:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
801011d5:	8b 45 08             	mov    0x8(%ebp),%eax
801011d8:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801011dc:	84 c0                	test   %al,%al
801011de:	75 0a                	jne    801011ea <filewrite+0x1c>
    return -1;
801011e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011e5:	e9 20 01 00 00       	jmp    8010130a <filewrite+0x13c>
  if(f->type == FD_PIPE)
801011ea:	8b 45 08             	mov    0x8(%ebp),%eax
801011ed:	8b 00                	mov    (%eax),%eax
801011ef:	83 f8 01             	cmp    $0x1,%eax
801011f2:	75 21                	jne    80101215 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801011f4:	8b 45 08             	mov    0x8(%ebp),%eax
801011f7:	8b 40 0c             	mov    0xc(%eax),%eax
801011fa:	8b 55 10             	mov    0x10(%ebp),%edx
801011fd:	89 54 24 08          	mov    %edx,0x8(%esp)
80101201:	8b 55 0c             	mov    0xc(%ebp),%edx
80101204:	89 54 24 04          	mov    %edx,0x4(%esp)
80101208:	89 04 24             	mov    %eax,(%esp)
8010120b:	e8 c3 2b 00 00       	call   80103dd3 <pipewrite>
80101210:	e9 f5 00 00 00       	jmp    8010130a <filewrite+0x13c>
  if(f->type == FD_INODE){
80101215:	8b 45 08             	mov    0x8(%ebp),%eax
80101218:	8b 00                	mov    (%eax),%eax
8010121a:	83 f8 02             	cmp    $0x2,%eax
8010121d:	0f 85 db 00 00 00    	jne    801012fe <filewrite+0x130>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
80101223:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
8010122a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101231:	e9 a8 00 00 00       	jmp    801012de <filewrite+0x110>
      int n1 = n - i;
80101236:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101239:	8b 55 10             	mov    0x10(%ebp),%edx
8010123c:	29 c2                	sub    %eax,%edx
8010123e:	89 d0                	mov    %edx,%eax
80101240:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101243:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101246:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101249:	7e 06                	jle    80101251 <filewrite+0x83>
        n1 = max;
8010124b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010124e:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_trans();
80101251:	e8 ae 1f 00 00       	call   80103204 <begin_trans>
      ilock(f->ip);
80101256:	8b 45 08             	mov    0x8(%ebp),%eax
80101259:	8b 40 10             	mov    0x10(%eax),%eax
8010125c:	89 04 24             	mov    %eax,(%esp)
8010125f:	e8 16 06 00 00       	call   8010187a <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101264:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101267:	8b 45 08             	mov    0x8(%ebp),%eax
8010126a:	8b 50 14             	mov    0x14(%eax),%edx
8010126d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101270:	8b 45 0c             	mov    0xc(%ebp),%eax
80101273:	01 c3                	add    %eax,%ebx
80101275:	8b 45 08             	mov    0x8(%ebp),%eax
80101278:	8b 40 10             	mov    0x10(%eax),%eax
8010127b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010127f:	89 54 24 08          	mov    %edx,0x8(%esp)
80101283:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80101287:	89 04 24             	mov    %eax,(%esp)
8010128a:	e8 5c 0c 00 00       	call   80101eeb <writei>
8010128f:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101292:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101296:	7e 11                	jle    801012a9 <filewrite+0xdb>
        f->off += r;
80101298:	8b 45 08             	mov    0x8(%ebp),%eax
8010129b:	8b 50 14             	mov    0x14(%eax),%edx
8010129e:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012a1:	01 c2                	add    %eax,%edx
801012a3:	8b 45 08             	mov    0x8(%ebp),%eax
801012a6:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801012a9:	8b 45 08             	mov    0x8(%ebp),%eax
801012ac:	8b 40 10             	mov    0x10(%eax),%eax
801012af:	89 04 24             	mov    %eax,(%esp)
801012b2:	e8 11 07 00 00       	call   801019c8 <iunlock>
      commit_trans();
801012b7:	e8 91 1f 00 00       	call   8010324d <commit_trans>

      if(r < 0)
801012bc:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801012c0:	79 02                	jns    801012c4 <filewrite+0xf6>
        break;
801012c2:	eb 26                	jmp    801012ea <filewrite+0x11c>
      if(r != n1)
801012c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012c7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801012ca:	74 0c                	je     801012d8 <filewrite+0x10a>
        panic("short filewrite");
801012cc:	c7 04 24 57 8a 10 80 	movl   $0x80108a57,(%esp)
801012d3:	e8 62 f2 ff ff       	call   8010053a <panic>
      i += r;
801012d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012db:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801012de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012e1:	3b 45 10             	cmp    0x10(%ebp),%eax
801012e4:	0f 8c 4c ff ff ff    	jl     80101236 <filewrite+0x68>
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801012ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012ed:	3b 45 10             	cmp    0x10(%ebp),%eax
801012f0:	75 05                	jne    801012f7 <filewrite+0x129>
801012f2:	8b 45 10             	mov    0x10(%ebp),%eax
801012f5:	eb 05                	jmp    801012fc <filewrite+0x12e>
801012f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012fc:	eb 0c                	jmp    8010130a <filewrite+0x13c>
  }
  panic("filewrite");
801012fe:	c7 04 24 67 8a 10 80 	movl   $0x80108a67,(%esp)
80101305:	e8 30 f2 ff ff       	call   8010053a <panic>
}
8010130a:	83 c4 24             	add    $0x24,%esp
8010130d:	5b                   	pop    %ebx
8010130e:	5d                   	pop    %ebp
8010130f:	c3                   	ret    

80101310 <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101310:	55                   	push   %ebp
80101311:	89 e5                	mov    %esp,%ebp
80101313:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
80101316:	8b 45 08             	mov    0x8(%ebp),%eax
80101319:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80101320:	00 
80101321:	89 04 24             	mov    %eax,(%esp)
80101324:	e8 7d ee ff ff       	call   801001a6 <bread>
80101329:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
8010132c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010132f:	83 c0 18             	add    $0x18,%eax
80101332:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80101339:	00 
8010133a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010133e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101341:	89 04 24             	mov    %eax,(%esp)
80101344:	e8 54 3f 00 00       	call   8010529d <memmove>
  brelse(bp);
80101349:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010134c:	89 04 24             	mov    %eax,(%esp)
8010134f:	e8 c3 ee ff ff       	call   80100217 <brelse>
}
80101354:	c9                   	leave  
80101355:	c3                   	ret    

80101356 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101356:	55                   	push   %ebp
80101357:	89 e5                	mov    %esp,%ebp
80101359:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
8010135c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010135f:	8b 45 08             	mov    0x8(%ebp),%eax
80101362:	89 54 24 04          	mov    %edx,0x4(%esp)
80101366:	89 04 24             	mov    %eax,(%esp)
80101369:	e8 38 ee ff ff       	call   801001a6 <bread>
8010136e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101371:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101374:	83 c0 18             	add    $0x18,%eax
80101377:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010137e:	00 
8010137f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101386:	00 
80101387:	89 04 24             	mov    %eax,(%esp)
8010138a:	e8 3f 3e 00 00       	call   801051ce <memset>
  log_write(bp);
8010138f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101392:	89 04 24             	mov    %eax,(%esp)
80101395:	e8 0b 1f 00 00       	call   801032a5 <log_write>
  brelse(bp);
8010139a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010139d:	89 04 24             	mov    %eax,(%esp)
801013a0:	e8 72 ee ff ff       	call   80100217 <brelse>
}
801013a5:	c9                   	leave  
801013a6:	c3                   	ret    

801013a7 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801013a7:	55                   	push   %ebp
801013a8:	89 e5                	mov    %esp,%ebp
801013aa:	83 ec 38             	sub    $0x38,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
801013ad:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
801013b4:	8b 45 08             	mov    0x8(%ebp),%eax
801013b7:	8d 55 d8             	lea    -0x28(%ebp),%edx
801013ba:	89 54 24 04          	mov    %edx,0x4(%esp)
801013be:	89 04 24             	mov    %eax,(%esp)
801013c1:	e8 4a ff ff ff       	call   80101310 <readsb>
  for(b = 0; b < sb.size; b += BPB){
801013c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801013cd:	e9 07 01 00 00       	jmp    801014d9 <balloc+0x132>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
801013d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013d5:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801013db:	85 c0                	test   %eax,%eax
801013dd:	0f 48 c2             	cmovs  %edx,%eax
801013e0:	c1 f8 0c             	sar    $0xc,%eax
801013e3:	8b 55 e0             	mov    -0x20(%ebp),%edx
801013e6:	c1 ea 03             	shr    $0x3,%edx
801013e9:	01 d0                	add    %edx,%eax
801013eb:	83 c0 03             	add    $0x3,%eax
801013ee:	89 44 24 04          	mov    %eax,0x4(%esp)
801013f2:	8b 45 08             	mov    0x8(%ebp),%eax
801013f5:	89 04 24             	mov    %eax,(%esp)
801013f8:	e8 a9 ed ff ff       	call   801001a6 <bread>
801013fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101400:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101407:	e9 9d 00 00 00       	jmp    801014a9 <balloc+0x102>
      m = 1 << (bi % 8);
8010140c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010140f:	99                   	cltd   
80101410:	c1 ea 1d             	shr    $0x1d,%edx
80101413:	01 d0                	add    %edx,%eax
80101415:	83 e0 07             	and    $0x7,%eax
80101418:	29 d0                	sub    %edx,%eax
8010141a:	ba 01 00 00 00       	mov    $0x1,%edx
8010141f:	89 c1                	mov    %eax,%ecx
80101421:	d3 e2                	shl    %cl,%edx
80101423:	89 d0                	mov    %edx,%eax
80101425:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101428:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010142b:	8d 50 07             	lea    0x7(%eax),%edx
8010142e:	85 c0                	test   %eax,%eax
80101430:	0f 48 c2             	cmovs  %edx,%eax
80101433:	c1 f8 03             	sar    $0x3,%eax
80101436:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101439:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
8010143e:	0f b6 c0             	movzbl %al,%eax
80101441:	23 45 e8             	and    -0x18(%ebp),%eax
80101444:	85 c0                	test   %eax,%eax
80101446:	75 5d                	jne    801014a5 <balloc+0xfe>
        bp->data[bi/8] |= m;  // Mark block in use.
80101448:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010144b:	8d 50 07             	lea    0x7(%eax),%edx
8010144e:	85 c0                	test   %eax,%eax
80101450:	0f 48 c2             	cmovs  %edx,%eax
80101453:	c1 f8 03             	sar    $0x3,%eax
80101456:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101459:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010145e:	89 d1                	mov    %edx,%ecx
80101460:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101463:	09 ca                	or     %ecx,%edx
80101465:	89 d1                	mov    %edx,%ecx
80101467:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010146a:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
8010146e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101471:	89 04 24             	mov    %eax,(%esp)
80101474:	e8 2c 1e 00 00       	call   801032a5 <log_write>
        brelse(bp);
80101479:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010147c:	89 04 24             	mov    %eax,(%esp)
8010147f:	e8 93 ed ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
80101484:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101487:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010148a:	01 c2                	add    %eax,%edx
8010148c:	8b 45 08             	mov    0x8(%ebp),%eax
8010148f:	89 54 24 04          	mov    %edx,0x4(%esp)
80101493:	89 04 24             	mov    %eax,(%esp)
80101496:	e8 bb fe ff ff       	call   80101356 <bzero>
        return b + bi;
8010149b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010149e:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014a1:	01 d0                	add    %edx,%eax
801014a3:	eb 4e                	jmp    801014f3 <balloc+0x14c>

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014a5:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801014a9:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801014b0:	7f 15                	jg     801014c7 <balloc+0x120>
801014b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014b8:	01 d0                	add    %edx,%eax
801014ba:	89 c2                	mov    %eax,%edx
801014bc:	8b 45 d8             	mov    -0x28(%ebp),%eax
801014bf:	39 c2                	cmp    %eax,%edx
801014c1:	0f 82 45 ff ff ff    	jb     8010140c <balloc+0x65>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801014c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014ca:	89 04 24             	mov    %eax,(%esp)
801014cd:	e8 45 ed ff ff       	call   80100217 <brelse>
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
801014d2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801014d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014dc:	8b 45 d8             	mov    -0x28(%ebp),%eax
801014df:	39 c2                	cmp    %eax,%edx
801014e1:	0f 82 eb fe ff ff    	jb     801013d2 <balloc+0x2b>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801014e7:	c7 04 24 71 8a 10 80 	movl   $0x80108a71,(%esp)
801014ee:	e8 47 f0 ff ff       	call   8010053a <panic>
}
801014f3:	c9                   	leave  
801014f4:	c3                   	ret    

801014f5 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801014f5:	55                   	push   %ebp
801014f6:	89 e5                	mov    %esp,%ebp
801014f8:	83 ec 38             	sub    $0x38,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
801014fb:	8d 45 dc             	lea    -0x24(%ebp),%eax
801014fe:	89 44 24 04          	mov    %eax,0x4(%esp)
80101502:	8b 45 08             	mov    0x8(%ebp),%eax
80101505:	89 04 24             	mov    %eax,(%esp)
80101508:	e8 03 fe ff ff       	call   80101310 <readsb>
  bp = bread(dev, BBLOCK(b, sb.ninodes));
8010150d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101510:	c1 e8 0c             	shr    $0xc,%eax
80101513:	89 c2                	mov    %eax,%edx
80101515:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101518:	c1 e8 03             	shr    $0x3,%eax
8010151b:	01 d0                	add    %edx,%eax
8010151d:	8d 50 03             	lea    0x3(%eax),%edx
80101520:	8b 45 08             	mov    0x8(%ebp),%eax
80101523:	89 54 24 04          	mov    %edx,0x4(%esp)
80101527:	89 04 24             	mov    %eax,(%esp)
8010152a:	e8 77 ec ff ff       	call   801001a6 <bread>
8010152f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101532:	8b 45 0c             	mov    0xc(%ebp),%eax
80101535:	25 ff 0f 00 00       	and    $0xfff,%eax
8010153a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010153d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101540:	99                   	cltd   
80101541:	c1 ea 1d             	shr    $0x1d,%edx
80101544:	01 d0                	add    %edx,%eax
80101546:	83 e0 07             	and    $0x7,%eax
80101549:	29 d0                	sub    %edx,%eax
8010154b:	ba 01 00 00 00       	mov    $0x1,%edx
80101550:	89 c1                	mov    %eax,%ecx
80101552:	d3 e2                	shl    %cl,%edx
80101554:	89 d0                	mov    %edx,%eax
80101556:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101559:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010155c:	8d 50 07             	lea    0x7(%eax),%edx
8010155f:	85 c0                	test   %eax,%eax
80101561:	0f 48 c2             	cmovs  %edx,%eax
80101564:	c1 f8 03             	sar    $0x3,%eax
80101567:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010156a:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
8010156f:	0f b6 c0             	movzbl %al,%eax
80101572:	23 45 ec             	and    -0x14(%ebp),%eax
80101575:	85 c0                	test   %eax,%eax
80101577:	75 0c                	jne    80101585 <bfree+0x90>
    panic("freeing free block");
80101579:	c7 04 24 87 8a 10 80 	movl   $0x80108a87,(%esp)
80101580:	e8 b5 ef ff ff       	call   8010053a <panic>
  bp->data[bi/8] &= ~m;
80101585:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101588:	8d 50 07             	lea    0x7(%eax),%edx
8010158b:	85 c0                	test   %eax,%eax
8010158d:	0f 48 c2             	cmovs  %edx,%eax
80101590:	c1 f8 03             	sar    $0x3,%eax
80101593:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101596:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010159b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010159e:	f7 d1                	not    %ecx
801015a0:	21 ca                	and    %ecx,%edx
801015a2:	89 d1                	mov    %edx,%ecx
801015a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015a7:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
801015ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015ae:	89 04 24             	mov    %eax,(%esp)
801015b1:	e8 ef 1c 00 00       	call   801032a5 <log_write>
  brelse(bp);
801015b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015b9:	89 04 24             	mov    %eax,(%esp)
801015bc:	e8 56 ec ff ff       	call   80100217 <brelse>
}
801015c1:	c9                   	leave  
801015c2:	c3                   	ret    

801015c3 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
801015c3:	55                   	push   %ebp
801015c4:	89 e5                	mov    %esp,%ebp
801015c6:	83 ec 18             	sub    $0x18,%esp
  initlock(&icache.lock, "icache");
801015c9:	c7 44 24 04 9a 8a 10 	movl   $0x80108a9a,0x4(%esp)
801015d0:	80 
801015d1:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
801015d8:	e8 7c 39 00 00       	call   80104f59 <initlock>
}
801015dd:	c9                   	leave  
801015de:	c3                   	ret    

801015df <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801015df:	55                   	push   %ebp
801015e0:	89 e5                	mov    %esp,%ebp
801015e2:	83 ec 38             	sub    $0x38,%esp
801015e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801015e8:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
801015ec:	8b 45 08             	mov    0x8(%ebp),%eax
801015ef:	8d 55 dc             	lea    -0x24(%ebp),%edx
801015f2:	89 54 24 04          	mov    %edx,0x4(%esp)
801015f6:	89 04 24             	mov    %eax,(%esp)
801015f9:	e8 12 fd ff ff       	call   80101310 <readsb>

  for(inum = 1; inum < sb.ninodes; inum++){
801015fe:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101605:	e9 98 00 00 00       	jmp    801016a2 <ialloc+0xc3>
    bp = bread(dev, IBLOCK(inum));
8010160a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010160d:	c1 e8 03             	shr    $0x3,%eax
80101610:	83 c0 02             	add    $0x2,%eax
80101613:	89 44 24 04          	mov    %eax,0x4(%esp)
80101617:	8b 45 08             	mov    0x8(%ebp),%eax
8010161a:	89 04 24             	mov    %eax,(%esp)
8010161d:	e8 84 eb ff ff       	call   801001a6 <bread>
80101622:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101625:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101628:	8d 50 18             	lea    0x18(%eax),%edx
8010162b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010162e:	83 e0 07             	and    $0x7,%eax
80101631:	c1 e0 06             	shl    $0x6,%eax
80101634:	01 d0                	add    %edx,%eax
80101636:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101639:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010163c:	0f b7 00             	movzwl (%eax),%eax
8010163f:	66 85 c0             	test   %ax,%ax
80101642:	75 4f                	jne    80101693 <ialloc+0xb4>
      memset(dip, 0, sizeof(*dip));
80101644:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
8010164b:	00 
8010164c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101653:	00 
80101654:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101657:	89 04 24             	mov    %eax,(%esp)
8010165a:	e8 6f 3b 00 00       	call   801051ce <memset>
      dip->type = type;
8010165f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101662:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
80101666:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101669:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010166c:	89 04 24             	mov    %eax,(%esp)
8010166f:	e8 31 1c 00 00       	call   801032a5 <log_write>
      brelse(bp);
80101674:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101677:	89 04 24             	mov    %eax,(%esp)
8010167a:	e8 98 eb ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
8010167f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101682:	89 44 24 04          	mov    %eax,0x4(%esp)
80101686:	8b 45 08             	mov    0x8(%ebp),%eax
80101689:	89 04 24             	mov    %eax,(%esp)
8010168c:	e8 e5 00 00 00       	call   80101776 <iget>
80101691:	eb 29                	jmp    801016bc <ialloc+0xdd>
    }
    brelse(bp);
80101693:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101696:	89 04 24             	mov    %eax,(%esp)
80101699:	e8 79 eb ff ff       	call   80100217 <brelse>
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
8010169e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801016a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801016a8:	39 c2                	cmp    %eax,%edx
801016aa:	0f 82 5a ff ff ff    	jb     8010160a <ialloc+0x2b>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
801016b0:	c7 04 24 a1 8a 10 80 	movl   $0x80108aa1,(%esp)
801016b7:	e8 7e ee ff ff       	call   8010053a <panic>
}
801016bc:	c9                   	leave  
801016bd:	c3                   	ret    

801016be <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
801016be:	55                   	push   %ebp
801016bf:	89 e5                	mov    %esp,%ebp
801016c1:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
801016c4:	8b 45 08             	mov    0x8(%ebp),%eax
801016c7:	8b 40 04             	mov    0x4(%eax),%eax
801016ca:	c1 e8 03             	shr    $0x3,%eax
801016cd:	8d 50 02             	lea    0x2(%eax),%edx
801016d0:	8b 45 08             	mov    0x8(%ebp),%eax
801016d3:	8b 00                	mov    (%eax),%eax
801016d5:	89 54 24 04          	mov    %edx,0x4(%esp)
801016d9:	89 04 24             	mov    %eax,(%esp)
801016dc:	e8 c5 ea ff ff       	call   801001a6 <bread>
801016e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801016e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016e7:	8d 50 18             	lea    0x18(%eax),%edx
801016ea:	8b 45 08             	mov    0x8(%ebp),%eax
801016ed:	8b 40 04             	mov    0x4(%eax),%eax
801016f0:	83 e0 07             	and    $0x7,%eax
801016f3:	c1 e0 06             	shl    $0x6,%eax
801016f6:	01 d0                	add    %edx,%eax
801016f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801016fb:	8b 45 08             	mov    0x8(%ebp),%eax
801016fe:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101702:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101705:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101708:	8b 45 08             	mov    0x8(%ebp),%eax
8010170b:	0f b7 50 12          	movzwl 0x12(%eax),%edx
8010170f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101712:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101716:	8b 45 08             	mov    0x8(%ebp),%eax
80101719:	0f b7 50 14          	movzwl 0x14(%eax),%edx
8010171d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101720:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101724:	8b 45 08             	mov    0x8(%ebp),%eax
80101727:	0f b7 50 16          	movzwl 0x16(%eax),%edx
8010172b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010172e:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101732:	8b 45 08             	mov    0x8(%ebp),%eax
80101735:	8b 50 18             	mov    0x18(%eax),%edx
80101738:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010173b:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010173e:	8b 45 08             	mov    0x8(%ebp),%eax
80101741:	8d 50 1c             	lea    0x1c(%eax),%edx
80101744:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101747:	83 c0 0c             	add    $0xc,%eax
8010174a:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101751:	00 
80101752:	89 54 24 04          	mov    %edx,0x4(%esp)
80101756:	89 04 24             	mov    %eax,(%esp)
80101759:	e8 3f 3b 00 00       	call   8010529d <memmove>
  log_write(bp);
8010175e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101761:	89 04 24             	mov    %eax,(%esp)
80101764:	e8 3c 1b 00 00       	call   801032a5 <log_write>
  brelse(bp);
80101769:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010176c:	89 04 24             	mov    %eax,(%esp)
8010176f:	e8 a3 ea ff ff       	call   80100217 <brelse>
}
80101774:	c9                   	leave  
80101775:	c3                   	ret    

80101776 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101776:	55                   	push   %ebp
80101777:	89 e5                	mov    %esp,%ebp
80101779:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
8010177c:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80101783:	e8 f2 37 00 00       	call   80104f7a <acquire>

  // Is the inode already cached?
  empty = 0;
80101788:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010178f:	c7 45 f4 94 f8 10 80 	movl   $0x8010f894,-0xc(%ebp)
80101796:	eb 59                	jmp    801017f1 <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101798:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010179b:	8b 40 08             	mov    0x8(%eax),%eax
8010179e:	85 c0                	test   %eax,%eax
801017a0:	7e 35                	jle    801017d7 <iget+0x61>
801017a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017a5:	8b 00                	mov    (%eax),%eax
801017a7:	3b 45 08             	cmp    0x8(%ebp),%eax
801017aa:	75 2b                	jne    801017d7 <iget+0x61>
801017ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017af:	8b 40 04             	mov    0x4(%eax),%eax
801017b2:	3b 45 0c             	cmp    0xc(%ebp),%eax
801017b5:	75 20                	jne    801017d7 <iget+0x61>
      ip->ref++;
801017b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ba:	8b 40 08             	mov    0x8(%eax),%eax
801017bd:	8d 50 01             	lea    0x1(%eax),%edx
801017c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017c3:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801017c6:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
801017cd:	e8 0a 38 00 00       	call   80104fdc <release>
      return ip;
801017d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017d5:	eb 6f                	jmp    80101846 <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801017d7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801017db:	75 10                	jne    801017ed <iget+0x77>
801017dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017e0:	8b 40 08             	mov    0x8(%eax),%eax
801017e3:	85 c0                	test   %eax,%eax
801017e5:	75 06                	jne    801017ed <iget+0x77>
      empty = ip;
801017e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ea:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801017ed:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
801017f1:	81 7d f4 34 08 11 80 	cmpl   $0x80110834,-0xc(%ebp)
801017f8:	72 9e                	jb     80101798 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801017fa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801017fe:	75 0c                	jne    8010180c <iget+0x96>
    panic("iget: no inodes");
80101800:	c7 04 24 b3 8a 10 80 	movl   $0x80108ab3,(%esp)
80101807:	e8 2e ed ff ff       	call   8010053a <panic>

  ip = empty;
8010180c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010180f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101812:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101815:	8b 55 08             	mov    0x8(%ebp),%edx
80101818:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
8010181a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010181d:	8b 55 0c             	mov    0xc(%ebp),%edx
80101820:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101823:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101826:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
8010182d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101830:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101837:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
8010183e:	e8 99 37 00 00       	call   80104fdc <release>

  return ip;
80101843:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101846:	c9                   	leave  
80101847:	c3                   	ret    

80101848 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101848:	55                   	push   %ebp
80101849:	89 e5                	mov    %esp,%ebp
8010184b:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
8010184e:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80101855:	e8 20 37 00 00       	call   80104f7a <acquire>
  ip->ref++;
8010185a:	8b 45 08             	mov    0x8(%ebp),%eax
8010185d:	8b 40 08             	mov    0x8(%eax),%eax
80101860:	8d 50 01             	lea    0x1(%eax),%edx
80101863:	8b 45 08             	mov    0x8(%ebp),%eax
80101866:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101869:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80101870:	e8 67 37 00 00       	call   80104fdc <release>
  return ip;
80101875:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101878:	c9                   	leave  
80101879:	c3                   	ret    

8010187a <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
8010187a:	55                   	push   %ebp
8010187b:	89 e5                	mov    %esp,%ebp
8010187d:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101880:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101884:	74 0a                	je     80101890 <ilock+0x16>
80101886:	8b 45 08             	mov    0x8(%ebp),%eax
80101889:	8b 40 08             	mov    0x8(%eax),%eax
8010188c:	85 c0                	test   %eax,%eax
8010188e:	7f 0c                	jg     8010189c <ilock+0x22>
    panic("ilock");
80101890:	c7 04 24 c3 8a 10 80 	movl   $0x80108ac3,(%esp)
80101897:	e8 9e ec ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
8010189c:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
801018a3:	e8 d2 36 00 00       	call   80104f7a <acquire>
  while(ip->flags & I_BUSY)
801018a8:	eb 13                	jmp    801018bd <ilock+0x43>
    sleep(ip, &icache.lock);
801018aa:	c7 44 24 04 60 f8 10 	movl   $0x8010f860,0x4(%esp)
801018b1:	80 
801018b2:	8b 45 08             	mov    0x8(%ebp),%eax
801018b5:	89 04 24             	mov    %eax,(%esp)
801018b8:	e8 2b 31 00 00       	call   801049e8 <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
801018bd:	8b 45 08             	mov    0x8(%ebp),%eax
801018c0:	8b 40 0c             	mov    0xc(%eax),%eax
801018c3:	83 e0 01             	and    $0x1,%eax
801018c6:	85 c0                	test   %eax,%eax
801018c8:	75 e0                	jne    801018aa <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
801018ca:	8b 45 08             	mov    0x8(%ebp),%eax
801018cd:	8b 40 0c             	mov    0xc(%eax),%eax
801018d0:	83 c8 01             	or     $0x1,%eax
801018d3:	89 c2                	mov    %eax,%edx
801018d5:	8b 45 08             	mov    0x8(%ebp),%eax
801018d8:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
801018db:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
801018e2:	e8 f5 36 00 00       	call   80104fdc <release>

  if(!(ip->flags & I_VALID)){
801018e7:	8b 45 08             	mov    0x8(%ebp),%eax
801018ea:	8b 40 0c             	mov    0xc(%eax),%eax
801018ed:	83 e0 02             	and    $0x2,%eax
801018f0:	85 c0                	test   %eax,%eax
801018f2:	0f 85 ce 00 00 00    	jne    801019c6 <ilock+0x14c>
    bp = bread(ip->dev, IBLOCK(ip->inum));
801018f8:	8b 45 08             	mov    0x8(%ebp),%eax
801018fb:	8b 40 04             	mov    0x4(%eax),%eax
801018fe:	c1 e8 03             	shr    $0x3,%eax
80101901:	8d 50 02             	lea    0x2(%eax),%edx
80101904:	8b 45 08             	mov    0x8(%ebp),%eax
80101907:	8b 00                	mov    (%eax),%eax
80101909:	89 54 24 04          	mov    %edx,0x4(%esp)
8010190d:	89 04 24             	mov    %eax,(%esp)
80101910:	e8 91 e8 ff ff       	call   801001a6 <bread>
80101915:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101918:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010191b:	8d 50 18             	lea    0x18(%eax),%edx
8010191e:	8b 45 08             	mov    0x8(%ebp),%eax
80101921:	8b 40 04             	mov    0x4(%eax),%eax
80101924:	83 e0 07             	and    $0x7,%eax
80101927:	c1 e0 06             	shl    $0x6,%eax
8010192a:	01 d0                	add    %edx,%eax
8010192c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
8010192f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101932:	0f b7 10             	movzwl (%eax),%edx
80101935:	8b 45 08             	mov    0x8(%ebp),%eax
80101938:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
8010193c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010193f:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101943:	8b 45 08             	mov    0x8(%ebp),%eax
80101946:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
8010194a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010194d:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101951:	8b 45 08             	mov    0x8(%ebp),%eax
80101954:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101958:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010195b:	0f b7 50 06          	movzwl 0x6(%eax),%edx
8010195f:	8b 45 08             	mov    0x8(%ebp),%eax
80101962:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101966:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101969:	8b 50 08             	mov    0x8(%eax),%edx
8010196c:	8b 45 08             	mov    0x8(%ebp),%eax
8010196f:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101972:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101975:	8d 50 0c             	lea    0xc(%eax),%edx
80101978:	8b 45 08             	mov    0x8(%ebp),%eax
8010197b:	83 c0 1c             	add    $0x1c,%eax
8010197e:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101985:	00 
80101986:	89 54 24 04          	mov    %edx,0x4(%esp)
8010198a:	89 04 24             	mov    %eax,(%esp)
8010198d:	e8 0b 39 00 00       	call   8010529d <memmove>
    brelse(bp);
80101992:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101995:	89 04 24             	mov    %eax,(%esp)
80101998:	e8 7a e8 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
8010199d:	8b 45 08             	mov    0x8(%ebp),%eax
801019a0:	8b 40 0c             	mov    0xc(%eax),%eax
801019a3:	83 c8 02             	or     $0x2,%eax
801019a6:	89 c2                	mov    %eax,%edx
801019a8:	8b 45 08             	mov    0x8(%ebp),%eax
801019ab:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
801019ae:	8b 45 08             	mov    0x8(%ebp),%eax
801019b1:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801019b5:	66 85 c0             	test   %ax,%ax
801019b8:	75 0c                	jne    801019c6 <ilock+0x14c>
      panic("ilock: no type");
801019ba:	c7 04 24 c9 8a 10 80 	movl   $0x80108ac9,(%esp)
801019c1:	e8 74 eb ff ff       	call   8010053a <panic>
  }
}
801019c6:	c9                   	leave  
801019c7:	c3                   	ret    

801019c8 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
801019c8:	55                   	push   %ebp
801019c9:	89 e5                	mov    %esp,%ebp
801019cb:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
801019ce:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019d2:	74 17                	je     801019eb <iunlock+0x23>
801019d4:	8b 45 08             	mov    0x8(%ebp),%eax
801019d7:	8b 40 0c             	mov    0xc(%eax),%eax
801019da:	83 e0 01             	and    $0x1,%eax
801019dd:	85 c0                	test   %eax,%eax
801019df:	74 0a                	je     801019eb <iunlock+0x23>
801019e1:	8b 45 08             	mov    0x8(%ebp),%eax
801019e4:	8b 40 08             	mov    0x8(%eax),%eax
801019e7:	85 c0                	test   %eax,%eax
801019e9:	7f 0c                	jg     801019f7 <iunlock+0x2f>
    panic("iunlock");
801019eb:	c7 04 24 d8 8a 10 80 	movl   $0x80108ad8,(%esp)
801019f2:	e8 43 eb ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
801019f7:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
801019fe:	e8 77 35 00 00       	call   80104f7a <acquire>
  ip->flags &= ~I_BUSY;
80101a03:	8b 45 08             	mov    0x8(%ebp),%eax
80101a06:	8b 40 0c             	mov    0xc(%eax),%eax
80101a09:	83 e0 fe             	and    $0xfffffffe,%eax
80101a0c:	89 c2                	mov    %eax,%edx
80101a0e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a11:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101a14:	8b 45 08             	mov    0x8(%ebp),%eax
80101a17:	89 04 24             	mov    %eax,(%esp)
80101a1a:	e8 a2 30 00 00       	call   80104ac1 <wakeup>
  release(&icache.lock);
80101a1f:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80101a26:	e8 b1 35 00 00       	call   80104fdc <release>
}
80101a2b:	c9                   	leave  
80101a2c:	c3                   	ret    

80101a2d <iput>:
// be recycled.
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
void
iput(struct inode *ip)
{
80101a2d:	55                   	push   %ebp
80101a2e:	89 e5                	mov    %esp,%ebp
80101a30:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101a33:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80101a3a:	e8 3b 35 00 00       	call   80104f7a <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101a3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a42:	8b 40 08             	mov    0x8(%eax),%eax
80101a45:	83 f8 01             	cmp    $0x1,%eax
80101a48:	0f 85 93 00 00 00    	jne    80101ae1 <iput+0xb4>
80101a4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a51:	8b 40 0c             	mov    0xc(%eax),%eax
80101a54:	83 e0 02             	and    $0x2,%eax
80101a57:	85 c0                	test   %eax,%eax
80101a59:	0f 84 82 00 00 00    	je     80101ae1 <iput+0xb4>
80101a5f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a62:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101a66:	66 85 c0             	test   %ax,%ax
80101a69:	75 76                	jne    80101ae1 <iput+0xb4>
    // inode has no links: truncate and free inode.
    if(ip->flags & I_BUSY)
80101a6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a6e:	8b 40 0c             	mov    0xc(%eax),%eax
80101a71:	83 e0 01             	and    $0x1,%eax
80101a74:	85 c0                	test   %eax,%eax
80101a76:	74 0c                	je     80101a84 <iput+0x57>
      panic("iput busy");
80101a78:	c7 04 24 e0 8a 10 80 	movl   $0x80108ae0,(%esp)
80101a7f:	e8 b6 ea ff ff       	call   8010053a <panic>
    ip->flags |= I_BUSY;
80101a84:	8b 45 08             	mov    0x8(%ebp),%eax
80101a87:	8b 40 0c             	mov    0xc(%eax),%eax
80101a8a:	83 c8 01             	or     $0x1,%eax
80101a8d:	89 c2                	mov    %eax,%edx
80101a8f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a92:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101a95:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80101a9c:	e8 3b 35 00 00       	call   80104fdc <release>
    itrunc(ip);
80101aa1:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa4:	89 04 24             	mov    %eax,(%esp)
80101aa7:	e8 7d 01 00 00       	call   80101c29 <itrunc>
    ip->type = 0;
80101aac:	8b 45 08             	mov    0x8(%ebp),%eax
80101aaf:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101ab5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab8:	89 04 24             	mov    %eax,(%esp)
80101abb:	e8 fe fb ff ff       	call   801016be <iupdate>
    acquire(&icache.lock);
80101ac0:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80101ac7:	e8 ae 34 00 00       	call   80104f7a <acquire>
    ip->flags = 0;
80101acc:	8b 45 08             	mov    0x8(%ebp),%eax
80101acf:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101ad6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad9:	89 04 24             	mov    %eax,(%esp)
80101adc:	e8 e0 2f 00 00       	call   80104ac1 <wakeup>
  }
  ip->ref--;
80101ae1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae4:	8b 40 08             	mov    0x8(%eax),%eax
80101ae7:	8d 50 ff             	lea    -0x1(%eax),%edx
80101aea:	8b 45 08             	mov    0x8(%ebp),%eax
80101aed:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101af0:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80101af7:	e8 e0 34 00 00       	call   80104fdc <release>
}
80101afc:	c9                   	leave  
80101afd:	c3                   	ret    

80101afe <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101afe:	55                   	push   %ebp
80101aff:	89 e5                	mov    %esp,%ebp
80101b01:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101b04:	8b 45 08             	mov    0x8(%ebp),%eax
80101b07:	89 04 24             	mov    %eax,(%esp)
80101b0a:	e8 b9 fe ff ff       	call   801019c8 <iunlock>
  iput(ip);
80101b0f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b12:	89 04 24             	mov    %eax,(%esp)
80101b15:	e8 13 ff ff ff       	call   80101a2d <iput>
}
80101b1a:	c9                   	leave  
80101b1b:	c3                   	ret    

80101b1c <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101b1c:	55                   	push   %ebp
80101b1d:	89 e5                	mov    %esp,%ebp
80101b1f:	53                   	push   %ebx
80101b20:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101b23:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101b27:	77 3e                	ja     80101b67 <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101b29:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2c:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b2f:	83 c2 04             	add    $0x4,%edx
80101b32:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101b36:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b39:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b3d:	75 20                	jne    80101b5f <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101b3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b42:	8b 00                	mov    (%eax),%eax
80101b44:	89 04 24             	mov    %eax,(%esp)
80101b47:	e8 5b f8 ff ff       	call   801013a7 <balloc>
80101b4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b52:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b55:	8d 4a 04             	lea    0x4(%edx),%ecx
80101b58:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b5b:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101b5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b62:	e9 bc 00 00 00       	jmp    80101c23 <bmap+0x107>
  }
  bn -= NDIRECT;
80101b67:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101b6b:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101b6f:	0f 87 a2 00 00 00    	ja     80101c17 <bmap+0xfb>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101b75:	8b 45 08             	mov    0x8(%ebp),%eax
80101b78:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b7e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b82:	75 19                	jne    80101b9d <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101b84:	8b 45 08             	mov    0x8(%ebp),%eax
80101b87:	8b 00                	mov    (%eax),%eax
80101b89:	89 04 24             	mov    %eax,(%esp)
80101b8c:	e8 16 f8 ff ff       	call   801013a7 <balloc>
80101b91:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b94:	8b 45 08             	mov    0x8(%ebp),%eax
80101b97:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b9a:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101b9d:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba0:	8b 00                	mov    (%eax),%eax
80101ba2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ba5:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ba9:	89 04 24             	mov    %eax,(%esp)
80101bac:	e8 f5 e5 ff ff       	call   801001a6 <bread>
80101bb1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101bb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bb7:	83 c0 18             	add    $0x18,%eax
80101bba:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101bbd:	8b 45 0c             	mov    0xc(%ebp),%eax
80101bc0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101bc7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101bca:	01 d0                	add    %edx,%eax
80101bcc:	8b 00                	mov    (%eax),%eax
80101bce:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bd1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101bd5:	75 30                	jne    80101c07 <bmap+0xeb>
      a[bn] = addr = balloc(ip->dev);
80101bd7:	8b 45 0c             	mov    0xc(%ebp),%eax
80101bda:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101be1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101be4:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101be7:	8b 45 08             	mov    0x8(%ebp),%eax
80101bea:	8b 00                	mov    (%eax),%eax
80101bec:	89 04 24             	mov    %eax,(%esp)
80101bef:	e8 b3 f7 ff ff       	call   801013a7 <balloc>
80101bf4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bfa:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101bfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bff:	89 04 24             	mov    %eax,(%esp)
80101c02:	e8 9e 16 00 00       	call   801032a5 <log_write>
    }
    brelse(bp);
80101c07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c0a:	89 04 24             	mov    %eax,(%esp)
80101c0d:	e8 05 e6 ff ff       	call   80100217 <brelse>
    return addr;
80101c12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c15:	eb 0c                	jmp    80101c23 <bmap+0x107>
  }

  panic("bmap: out of range");
80101c17:	c7 04 24 ea 8a 10 80 	movl   $0x80108aea,(%esp)
80101c1e:	e8 17 e9 ff ff       	call   8010053a <panic>
}
80101c23:	83 c4 24             	add    $0x24,%esp
80101c26:	5b                   	pop    %ebx
80101c27:	5d                   	pop    %ebp
80101c28:	c3                   	ret    

80101c29 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101c29:	55                   	push   %ebp
80101c2a:	89 e5                	mov    %esp,%ebp
80101c2c:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c2f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101c36:	eb 44                	jmp    80101c7c <itrunc+0x53>
    if(ip->addrs[i]){
80101c38:	8b 45 08             	mov    0x8(%ebp),%eax
80101c3b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c3e:	83 c2 04             	add    $0x4,%edx
80101c41:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c45:	85 c0                	test   %eax,%eax
80101c47:	74 2f                	je     80101c78 <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101c49:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c4f:	83 c2 04             	add    $0x4,%edx
80101c52:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101c56:	8b 45 08             	mov    0x8(%ebp),%eax
80101c59:	8b 00                	mov    (%eax),%eax
80101c5b:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c5f:	89 04 24             	mov    %eax,(%esp)
80101c62:	e8 8e f8 ff ff       	call   801014f5 <bfree>
      ip->addrs[i] = 0;
80101c67:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c6d:	83 c2 04             	add    $0x4,%edx
80101c70:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101c77:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c78:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101c7c:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101c80:	7e b6                	jle    80101c38 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101c82:	8b 45 08             	mov    0x8(%ebp),%eax
80101c85:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c88:	85 c0                	test   %eax,%eax
80101c8a:	0f 84 9b 00 00 00    	je     80101d2b <itrunc+0x102>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101c90:	8b 45 08             	mov    0x8(%ebp),%eax
80101c93:	8b 50 4c             	mov    0x4c(%eax),%edx
80101c96:	8b 45 08             	mov    0x8(%ebp),%eax
80101c99:	8b 00                	mov    (%eax),%eax
80101c9b:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c9f:	89 04 24             	mov    %eax,(%esp)
80101ca2:	e8 ff e4 ff ff       	call   801001a6 <bread>
80101ca7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101caa:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cad:	83 c0 18             	add    $0x18,%eax
80101cb0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101cb3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101cba:	eb 3b                	jmp    80101cf7 <itrunc+0xce>
      if(a[j])
80101cbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cbf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cc6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101cc9:	01 d0                	add    %edx,%eax
80101ccb:	8b 00                	mov    (%eax),%eax
80101ccd:	85 c0                	test   %eax,%eax
80101ccf:	74 22                	je     80101cf3 <itrunc+0xca>
        bfree(ip->dev, a[j]);
80101cd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cd4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cdb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101cde:	01 d0                	add    %edx,%eax
80101ce0:	8b 10                	mov    (%eax),%edx
80101ce2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce5:	8b 00                	mov    (%eax),%eax
80101ce7:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ceb:	89 04 24             	mov    %eax,(%esp)
80101cee:	e8 02 f8 ff ff       	call   801014f5 <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101cf3:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101cf7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cfa:	83 f8 7f             	cmp    $0x7f,%eax
80101cfd:	76 bd                	jbe    80101cbc <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101cff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d02:	89 04 24             	mov    %eax,(%esp)
80101d05:	e8 0d e5 ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101d0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0d:	8b 50 4c             	mov    0x4c(%eax),%edx
80101d10:	8b 45 08             	mov    0x8(%ebp),%eax
80101d13:	8b 00                	mov    (%eax),%eax
80101d15:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d19:	89 04 24             	mov    %eax,(%esp)
80101d1c:	e8 d4 f7 ff ff       	call   801014f5 <bfree>
    ip->addrs[NDIRECT] = 0;
80101d21:	8b 45 08             	mov    0x8(%ebp),%eax
80101d24:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101d2b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d2e:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101d35:	8b 45 08             	mov    0x8(%ebp),%eax
80101d38:	89 04 24             	mov    %eax,(%esp)
80101d3b:	e8 7e f9 ff ff       	call   801016be <iupdate>
}
80101d40:	c9                   	leave  
80101d41:	c3                   	ret    

80101d42 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101d42:	55                   	push   %ebp
80101d43:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101d45:	8b 45 08             	mov    0x8(%ebp),%eax
80101d48:	8b 00                	mov    (%eax),%eax
80101d4a:	89 c2                	mov    %eax,%edx
80101d4c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d4f:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101d52:	8b 45 08             	mov    0x8(%ebp),%eax
80101d55:	8b 50 04             	mov    0x4(%eax),%edx
80101d58:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d5b:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101d5e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d61:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101d65:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d68:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101d6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6e:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101d72:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d75:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101d79:	8b 45 08             	mov    0x8(%ebp),%eax
80101d7c:	8b 50 18             	mov    0x18(%eax),%edx
80101d7f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d82:	89 50 10             	mov    %edx,0x10(%eax)
}
80101d85:	5d                   	pop    %ebp
80101d86:	c3                   	ret    

80101d87 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101d87:	55                   	push   %ebp
80101d88:	89 e5                	mov    %esp,%ebp
80101d8a:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101d8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d90:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101d94:	66 83 f8 03          	cmp    $0x3,%ax
80101d98:	75 60                	jne    80101dfa <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101d9a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d9d:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101da1:	66 85 c0             	test   %ax,%ax
80101da4:	78 20                	js     80101dc6 <readi+0x3f>
80101da6:	8b 45 08             	mov    0x8(%ebp),%eax
80101da9:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101dad:	66 83 f8 09          	cmp    $0x9,%ax
80101db1:	7f 13                	jg     80101dc6 <readi+0x3f>
80101db3:	8b 45 08             	mov    0x8(%ebp),%eax
80101db6:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101dba:	98                   	cwtl   
80101dbb:	8b 04 c5 00 f8 10 80 	mov    -0x7fef0800(,%eax,8),%eax
80101dc2:	85 c0                	test   %eax,%eax
80101dc4:	75 0a                	jne    80101dd0 <readi+0x49>
      return -1;
80101dc6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101dcb:	e9 19 01 00 00       	jmp    80101ee9 <readi+0x162>
    return devsw[ip->major].read(ip, dst, n);
80101dd0:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd3:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101dd7:	98                   	cwtl   
80101dd8:	8b 04 c5 00 f8 10 80 	mov    -0x7fef0800(,%eax,8),%eax
80101ddf:	8b 55 14             	mov    0x14(%ebp),%edx
80101de2:	89 54 24 08          	mov    %edx,0x8(%esp)
80101de6:	8b 55 0c             	mov    0xc(%ebp),%edx
80101de9:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ded:	8b 55 08             	mov    0x8(%ebp),%edx
80101df0:	89 14 24             	mov    %edx,(%esp)
80101df3:	ff d0                	call   *%eax
80101df5:	e9 ef 00 00 00       	jmp    80101ee9 <readi+0x162>
  }

  if(off > ip->size || off + n < off)
80101dfa:	8b 45 08             	mov    0x8(%ebp),%eax
80101dfd:	8b 40 18             	mov    0x18(%eax),%eax
80101e00:	3b 45 10             	cmp    0x10(%ebp),%eax
80101e03:	72 0d                	jb     80101e12 <readi+0x8b>
80101e05:	8b 45 14             	mov    0x14(%ebp),%eax
80101e08:	8b 55 10             	mov    0x10(%ebp),%edx
80101e0b:	01 d0                	add    %edx,%eax
80101e0d:	3b 45 10             	cmp    0x10(%ebp),%eax
80101e10:	73 0a                	jae    80101e1c <readi+0x95>
    return -1;
80101e12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101e17:	e9 cd 00 00 00       	jmp    80101ee9 <readi+0x162>
  if(off + n > ip->size)
80101e1c:	8b 45 14             	mov    0x14(%ebp),%eax
80101e1f:	8b 55 10             	mov    0x10(%ebp),%edx
80101e22:	01 c2                	add    %eax,%edx
80101e24:	8b 45 08             	mov    0x8(%ebp),%eax
80101e27:	8b 40 18             	mov    0x18(%eax),%eax
80101e2a:	39 c2                	cmp    %eax,%edx
80101e2c:	76 0c                	jbe    80101e3a <readi+0xb3>
    n = ip->size - off;
80101e2e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e31:	8b 40 18             	mov    0x18(%eax),%eax
80101e34:	2b 45 10             	sub    0x10(%ebp),%eax
80101e37:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101e3a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e41:	e9 94 00 00 00       	jmp    80101eda <readi+0x153>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101e46:	8b 45 10             	mov    0x10(%ebp),%eax
80101e49:	c1 e8 09             	shr    $0x9,%eax
80101e4c:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e50:	8b 45 08             	mov    0x8(%ebp),%eax
80101e53:	89 04 24             	mov    %eax,(%esp)
80101e56:	e8 c1 fc ff ff       	call   80101b1c <bmap>
80101e5b:	8b 55 08             	mov    0x8(%ebp),%edx
80101e5e:	8b 12                	mov    (%edx),%edx
80101e60:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e64:	89 14 24             	mov    %edx,(%esp)
80101e67:	e8 3a e3 ff ff       	call   801001a6 <bread>
80101e6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101e6f:	8b 45 10             	mov    0x10(%ebp),%eax
80101e72:	25 ff 01 00 00       	and    $0x1ff,%eax
80101e77:	89 c2                	mov    %eax,%edx
80101e79:	b8 00 02 00 00       	mov    $0x200,%eax
80101e7e:	29 d0                	sub    %edx,%eax
80101e80:	89 c2                	mov    %eax,%edx
80101e82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e85:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101e88:	29 c1                	sub    %eax,%ecx
80101e8a:	89 c8                	mov    %ecx,%eax
80101e8c:	39 c2                	cmp    %eax,%edx
80101e8e:	0f 46 c2             	cmovbe %edx,%eax
80101e91:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101e94:	8b 45 10             	mov    0x10(%ebp),%eax
80101e97:	25 ff 01 00 00       	and    $0x1ff,%eax
80101e9c:	8d 50 10             	lea    0x10(%eax),%edx
80101e9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ea2:	01 d0                	add    %edx,%eax
80101ea4:	8d 50 08             	lea    0x8(%eax),%edx
80101ea7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101eaa:	89 44 24 08          	mov    %eax,0x8(%esp)
80101eae:	89 54 24 04          	mov    %edx,0x4(%esp)
80101eb2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb5:	89 04 24             	mov    %eax,(%esp)
80101eb8:	e8 e0 33 00 00       	call   8010529d <memmove>
    brelse(bp);
80101ebd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ec0:	89 04 24             	mov    %eax,(%esp)
80101ec3:	e8 4f e3 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101ec8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ecb:	01 45 f4             	add    %eax,-0xc(%ebp)
80101ece:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ed1:	01 45 10             	add    %eax,0x10(%ebp)
80101ed4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ed7:	01 45 0c             	add    %eax,0xc(%ebp)
80101eda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101edd:	3b 45 14             	cmp    0x14(%ebp),%eax
80101ee0:	0f 82 60 ff ff ff    	jb     80101e46 <readi+0xbf>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80101ee6:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101ee9:	c9                   	leave  
80101eea:	c3                   	ret    

80101eeb <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101eeb:	55                   	push   %ebp
80101eec:	89 e5                	mov    %esp,%ebp
80101eee:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ef1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef4:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ef8:	66 83 f8 03          	cmp    $0x3,%ax
80101efc:	75 60                	jne    80101f5e <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101efe:	8b 45 08             	mov    0x8(%ebp),%eax
80101f01:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f05:	66 85 c0             	test   %ax,%ax
80101f08:	78 20                	js     80101f2a <writei+0x3f>
80101f0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0d:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f11:	66 83 f8 09          	cmp    $0x9,%ax
80101f15:	7f 13                	jg     80101f2a <writei+0x3f>
80101f17:	8b 45 08             	mov    0x8(%ebp),%eax
80101f1a:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f1e:	98                   	cwtl   
80101f1f:	8b 04 c5 04 f8 10 80 	mov    -0x7fef07fc(,%eax,8),%eax
80101f26:	85 c0                	test   %eax,%eax
80101f28:	75 0a                	jne    80101f34 <writei+0x49>
      return -1;
80101f2a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f2f:	e9 44 01 00 00       	jmp    80102078 <writei+0x18d>
    return devsw[ip->major].write(ip, src, n);
80101f34:	8b 45 08             	mov    0x8(%ebp),%eax
80101f37:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f3b:	98                   	cwtl   
80101f3c:	8b 04 c5 04 f8 10 80 	mov    -0x7fef07fc(,%eax,8),%eax
80101f43:	8b 55 14             	mov    0x14(%ebp),%edx
80101f46:	89 54 24 08          	mov    %edx,0x8(%esp)
80101f4a:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f4d:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f51:	8b 55 08             	mov    0x8(%ebp),%edx
80101f54:	89 14 24             	mov    %edx,(%esp)
80101f57:	ff d0                	call   *%eax
80101f59:	e9 1a 01 00 00       	jmp    80102078 <writei+0x18d>
  }

  if(off > ip->size || off + n < off)
80101f5e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f61:	8b 40 18             	mov    0x18(%eax),%eax
80101f64:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f67:	72 0d                	jb     80101f76 <writei+0x8b>
80101f69:	8b 45 14             	mov    0x14(%ebp),%eax
80101f6c:	8b 55 10             	mov    0x10(%ebp),%edx
80101f6f:	01 d0                	add    %edx,%eax
80101f71:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f74:	73 0a                	jae    80101f80 <writei+0x95>
    return -1;
80101f76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f7b:	e9 f8 00 00 00       	jmp    80102078 <writei+0x18d>
  if(off + n > MAXFILE*BSIZE)
80101f80:	8b 45 14             	mov    0x14(%ebp),%eax
80101f83:	8b 55 10             	mov    0x10(%ebp),%edx
80101f86:	01 d0                	add    %edx,%eax
80101f88:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101f8d:	76 0a                	jbe    80101f99 <writei+0xae>
    return -1;
80101f8f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f94:	e9 df 00 00 00       	jmp    80102078 <writei+0x18d>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101f99:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101fa0:	e9 9f 00 00 00       	jmp    80102044 <writei+0x159>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101fa5:	8b 45 10             	mov    0x10(%ebp),%eax
80101fa8:	c1 e8 09             	shr    $0x9,%eax
80101fab:	89 44 24 04          	mov    %eax,0x4(%esp)
80101faf:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb2:	89 04 24             	mov    %eax,(%esp)
80101fb5:	e8 62 fb ff ff       	call   80101b1c <bmap>
80101fba:	8b 55 08             	mov    0x8(%ebp),%edx
80101fbd:	8b 12                	mov    (%edx),%edx
80101fbf:	89 44 24 04          	mov    %eax,0x4(%esp)
80101fc3:	89 14 24             	mov    %edx,(%esp)
80101fc6:	e8 db e1 ff ff       	call   801001a6 <bread>
80101fcb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fce:	8b 45 10             	mov    0x10(%ebp),%eax
80101fd1:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fd6:	89 c2                	mov    %eax,%edx
80101fd8:	b8 00 02 00 00       	mov    $0x200,%eax
80101fdd:	29 d0                	sub    %edx,%eax
80101fdf:	89 c2                	mov    %eax,%edx
80101fe1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fe4:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101fe7:	29 c1                	sub    %eax,%ecx
80101fe9:	89 c8                	mov    %ecx,%eax
80101feb:	39 c2                	cmp    %eax,%edx
80101fed:	0f 46 c2             	cmovbe %edx,%eax
80101ff0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80101ff3:	8b 45 10             	mov    0x10(%ebp),%eax
80101ff6:	25 ff 01 00 00       	and    $0x1ff,%eax
80101ffb:	8d 50 10             	lea    0x10(%eax),%edx
80101ffe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102001:	01 d0                	add    %edx,%eax
80102003:	8d 50 08             	lea    0x8(%eax),%edx
80102006:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102009:	89 44 24 08          	mov    %eax,0x8(%esp)
8010200d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102010:	89 44 24 04          	mov    %eax,0x4(%esp)
80102014:	89 14 24             	mov    %edx,(%esp)
80102017:	e8 81 32 00 00       	call   8010529d <memmove>
    log_write(bp);
8010201c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010201f:	89 04 24             	mov    %eax,(%esp)
80102022:	e8 7e 12 00 00       	call   801032a5 <log_write>
    brelse(bp);
80102027:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010202a:	89 04 24             	mov    %eax,(%esp)
8010202d:	e8 e5 e1 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102032:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102035:	01 45 f4             	add    %eax,-0xc(%ebp)
80102038:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010203b:	01 45 10             	add    %eax,0x10(%ebp)
8010203e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102041:	01 45 0c             	add    %eax,0xc(%ebp)
80102044:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102047:	3b 45 14             	cmp    0x14(%ebp),%eax
8010204a:	0f 82 55 ff ff ff    	jb     80101fa5 <writei+0xba>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102050:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102054:	74 1f                	je     80102075 <writei+0x18a>
80102056:	8b 45 08             	mov    0x8(%ebp),%eax
80102059:	8b 40 18             	mov    0x18(%eax),%eax
8010205c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010205f:	73 14                	jae    80102075 <writei+0x18a>
    ip->size = off;
80102061:	8b 45 08             	mov    0x8(%ebp),%eax
80102064:	8b 55 10             	mov    0x10(%ebp),%edx
80102067:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
8010206a:	8b 45 08             	mov    0x8(%ebp),%eax
8010206d:	89 04 24             	mov    %eax,(%esp)
80102070:	e8 49 f6 ff ff       	call   801016be <iupdate>
  }
  return n;
80102075:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102078:	c9                   	leave  
80102079:	c3                   	ret    

8010207a <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
8010207a:	55                   	push   %ebp
8010207b:	89 e5                	mov    %esp,%ebp
8010207d:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
80102080:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102087:	00 
80102088:	8b 45 0c             	mov    0xc(%ebp),%eax
8010208b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010208f:	8b 45 08             	mov    0x8(%ebp),%eax
80102092:	89 04 24             	mov    %eax,(%esp)
80102095:	e8 a6 32 00 00       	call   80105340 <strncmp>
}
8010209a:	c9                   	leave  
8010209b:	c3                   	ret    

8010209c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
8010209c:	55                   	push   %ebp
8010209d:	89 e5                	mov    %esp,%ebp
8010209f:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801020a2:	8b 45 08             	mov    0x8(%ebp),%eax
801020a5:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801020a9:	66 83 f8 01          	cmp    $0x1,%ax
801020ad:	74 0c                	je     801020bb <dirlookup+0x1f>
    panic("dirlookup not DIR");
801020af:	c7 04 24 fd 8a 10 80 	movl   $0x80108afd,(%esp)
801020b6:	e8 7f e4 ff ff       	call   8010053a <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801020bb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020c2:	e9 88 00 00 00       	jmp    8010214f <dirlookup+0xb3>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801020c7:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801020ce:	00 
801020cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020d2:	89 44 24 08          	mov    %eax,0x8(%esp)
801020d6:	8d 45 e0             	lea    -0x20(%ebp),%eax
801020d9:	89 44 24 04          	mov    %eax,0x4(%esp)
801020dd:	8b 45 08             	mov    0x8(%ebp),%eax
801020e0:	89 04 24             	mov    %eax,(%esp)
801020e3:	e8 9f fc ff ff       	call   80101d87 <readi>
801020e8:	83 f8 10             	cmp    $0x10,%eax
801020eb:	74 0c                	je     801020f9 <dirlookup+0x5d>
      panic("dirlink read");
801020ed:	c7 04 24 0f 8b 10 80 	movl   $0x80108b0f,(%esp)
801020f4:	e8 41 e4 ff ff       	call   8010053a <panic>
    if(de.inum == 0)
801020f9:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801020fd:	66 85 c0             	test   %ax,%ax
80102100:	75 02                	jne    80102104 <dirlookup+0x68>
      continue;
80102102:	eb 47                	jmp    8010214b <dirlookup+0xaf>
    if(namecmp(name, de.name) == 0){
80102104:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102107:	83 c0 02             	add    $0x2,%eax
8010210a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010210e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102111:	89 04 24             	mov    %eax,(%esp)
80102114:	e8 61 ff ff ff       	call   8010207a <namecmp>
80102119:	85 c0                	test   %eax,%eax
8010211b:	75 2e                	jne    8010214b <dirlookup+0xaf>
      // entry matches path element
      if(poff)
8010211d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102121:	74 08                	je     8010212b <dirlookup+0x8f>
        *poff = off;
80102123:	8b 45 10             	mov    0x10(%ebp),%eax
80102126:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102129:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010212b:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010212f:	0f b7 c0             	movzwl %ax,%eax
80102132:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102135:	8b 45 08             	mov    0x8(%ebp),%eax
80102138:	8b 00                	mov    (%eax),%eax
8010213a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010213d:	89 54 24 04          	mov    %edx,0x4(%esp)
80102141:	89 04 24             	mov    %eax,(%esp)
80102144:	e8 2d f6 ff ff       	call   80101776 <iget>
80102149:	eb 18                	jmp    80102163 <dirlookup+0xc7>
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
8010214b:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010214f:	8b 45 08             	mov    0x8(%ebp),%eax
80102152:	8b 40 18             	mov    0x18(%eax),%eax
80102155:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102158:	0f 87 69 ff ff ff    	ja     801020c7 <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
8010215e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102163:	c9                   	leave  
80102164:	c3                   	ret    

80102165 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102165:	55                   	push   %ebp
80102166:	89 e5                	mov    %esp,%ebp
80102168:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010216b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102172:	00 
80102173:	8b 45 0c             	mov    0xc(%ebp),%eax
80102176:	89 44 24 04          	mov    %eax,0x4(%esp)
8010217a:	8b 45 08             	mov    0x8(%ebp),%eax
8010217d:	89 04 24             	mov    %eax,(%esp)
80102180:	e8 17 ff ff ff       	call   8010209c <dirlookup>
80102185:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102188:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010218c:	74 15                	je     801021a3 <dirlink+0x3e>
    iput(ip);
8010218e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102191:	89 04 24             	mov    %eax,(%esp)
80102194:	e8 94 f8 ff ff       	call   80101a2d <iput>
    return -1;
80102199:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010219e:	e9 b7 00 00 00       	jmp    8010225a <dirlink+0xf5>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801021a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021aa:	eb 46                	jmp    801021f2 <dirlink+0x8d>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021af:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801021b6:	00 
801021b7:	89 44 24 08          	mov    %eax,0x8(%esp)
801021bb:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021be:	89 44 24 04          	mov    %eax,0x4(%esp)
801021c2:	8b 45 08             	mov    0x8(%ebp),%eax
801021c5:	89 04 24             	mov    %eax,(%esp)
801021c8:	e8 ba fb ff ff       	call   80101d87 <readi>
801021cd:	83 f8 10             	cmp    $0x10,%eax
801021d0:	74 0c                	je     801021de <dirlink+0x79>
      panic("dirlink read");
801021d2:	c7 04 24 0f 8b 10 80 	movl   $0x80108b0f,(%esp)
801021d9:	e8 5c e3 ff ff       	call   8010053a <panic>
    if(de.inum == 0)
801021de:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801021e2:	66 85 c0             	test   %ax,%ax
801021e5:	75 02                	jne    801021e9 <dirlink+0x84>
      break;
801021e7:	eb 16                	jmp    801021ff <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801021e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021ec:	83 c0 10             	add    $0x10,%eax
801021ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
801021f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801021f5:	8b 45 08             	mov    0x8(%ebp),%eax
801021f8:	8b 40 18             	mov    0x18(%eax),%eax
801021fb:	39 c2                	cmp    %eax,%edx
801021fd:	72 ad                	jb     801021ac <dirlink+0x47>
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
801021ff:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102206:	00 
80102207:	8b 45 0c             	mov    0xc(%ebp),%eax
8010220a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010220e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102211:	83 c0 02             	add    $0x2,%eax
80102214:	89 04 24             	mov    %eax,(%esp)
80102217:	e8 7a 31 00 00       	call   80105396 <strncpy>
  de.inum = inum;
8010221c:	8b 45 10             	mov    0x10(%ebp),%eax
8010221f:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102223:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102226:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010222d:	00 
8010222e:	89 44 24 08          	mov    %eax,0x8(%esp)
80102232:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102235:	89 44 24 04          	mov    %eax,0x4(%esp)
80102239:	8b 45 08             	mov    0x8(%ebp),%eax
8010223c:	89 04 24             	mov    %eax,(%esp)
8010223f:	e8 a7 fc ff ff       	call   80101eeb <writei>
80102244:	83 f8 10             	cmp    $0x10,%eax
80102247:	74 0c                	je     80102255 <dirlink+0xf0>
    panic("dirlink");
80102249:	c7 04 24 1c 8b 10 80 	movl   $0x80108b1c,(%esp)
80102250:	e8 e5 e2 ff ff       	call   8010053a <panic>
  
  return 0;
80102255:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010225a:	c9                   	leave  
8010225b:	c3                   	ret    

8010225c <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010225c:	55                   	push   %ebp
8010225d:	89 e5                	mov    %esp,%ebp
8010225f:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
80102262:	eb 04                	jmp    80102268 <skipelem+0xc>
    path++;
80102264:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102268:	8b 45 08             	mov    0x8(%ebp),%eax
8010226b:	0f b6 00             	movzbl (%eax),%eax
8010226e:	3c 2f                	cmp    $0x2f,%al
80102270:	74 f2                	je     80102264 <skipelem+0x8>
    path++;
  if(*path == 0)
80102272:	8b 45 08             	mov    0x8(%ebp),%eax
80102275:	0f b6 00             	movzbl (%eax),%eax
80102278:	84 c0                	test   %al,%al
8010227a:	75 0a                	jne    80102286 <skipelem+0x2a>
    return 0;
8010227c:	b8 00 00 00 00       	mov    $0x0,%eax
80102281:	e9 86 00 00 00       	jmp    8010230c <skipelem+0xb0>
  s = path;
80102286:	8b 45 08             	mov    0x8(%ebp),%eax
80102289:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010228c:	eb 04                	jmp    80102292 <skipelem+0x36>
    path++;
8010228e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102292:	8b 45 08             	mov    0x8(%ebp),%eax
80102295:	0f b6 00             	movzbl (%eax),%eax
80102298:	3c 2f                	cmp    $0x2f,%al
8010229a:	74 0a                	je     801022a6 <skipelem+0x4a>
8010229c:	8b 45 08             	mov    0x8(%ebp),%eax
8010229f:	0f b6 00             	movzbl (%eax),%eax
801022a2:	84 c0                	test   %al,%al
801022a4:	75 e8                	jne    8010228e <skipelem+0x32>
    path++;
  len = path - s;
801022a6:	8b 55 08             	mov    0x8(%ebp),%edx
801022a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022ac:	29 c2                	sub    %eax,%edx
801022ae:	89 d0                	mov    %edx,%eax
801022b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801022b3:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801022b7:	7e 1c                	jle    801022d5 <skipelem+0x79>
    memmove(name, s, DIRSIZ);
801022b9:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801022c0:	00 
801022c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022c4:	89 44 24 04          	mov    %eax,0x4(%esp)
801022c8:	8b 45 0c             	mov    0xc(%ebp),%eax
801022cb:	89 04 24             	mov    %eax,(%esp)
801022ce:	e8 ca 2f 00 00       	call   8010529d <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801022d3:	eb 2a                	jmp    801022ff <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
801022d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022d8:	89 44 24 08          	mov    %eax,0x8(%esp)
801022dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022df:	89 44 24 04          	mov    %eax,0x4(%esp)
801022e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801022e6:	89 04 24             	mov    %eax,(%esp)
801022e9:	e8 af 2f 00 00       	call   8010529d <memmove>
    name[len] = 0;
801022ee:	8b 55 f0             	mov    -0x10(%ebp),%edx
801022f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801022f4:	01 d0                	add    %edx,%eax
801022f6:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801022f9:	eb 04                	jmp    801022ff <skipelem+0xa3>
    path++;
801022fb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801022ff:	8b 45 08             	mov    0x8(%ebp),%eax
80102302:	0f b6 00             	movzbl (%eax),%eax
80102305:	3c 2f                	cmp    $0x2f,%al
80102307:	74 f2                	je     801022fb <skipelem+0x9f>
    path++;
  return path;
80102309:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010230c:	c9                   	leave  
8010230d:	c3                   	ret    

8010230e <namex>:
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010230e:	55                   	push   %ebp
8010230f:	89 e5                	mov    %esp,%ebp
80102311:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102314:	8b 45 08             	mov    0x8(%ebp),%eax
80102317:	0f b6 00             	movzbl (%eax),%eax
8010231a:	3c 2f                	cmp    $0x2f,%al
8010231c:	75 1c                	jne    8010233a <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
8010231e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102325:	00 
80102326:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010232d:	e8 44 f4 ff ff       	call   80101776 <iget>
80102332:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102335:	e9 af 00 00 00       	jmp    801023e9 <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
8010233a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102340:	8b 40 68             	mov    0x68(%eax),%eax
80102343:	89 04 24             	mov    %eax,(%esp)
80102346:	e8 fd f4 ff ff       	call   80101848 <idup>
8010234b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010234e:	e9 96 00 00 00       	jmp    801023e9 <namex+0xdb>
    ilock(ip);
80102353:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102356:	89 04 24             	mov    %eax,(%esp)
80102359:	e8 1c f5 ff ff       	call   8010187a <ilock>
    if(ip->type != T_DIR){
8010235e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102361:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102365:	66 83 f8 01          	cmp    $0x1,%ax
80102369:	74 15                	je     80102380 <namex+0x72>
      iunlockput(ip);
8010236b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010236e:	89 04 24             	mov    %eax,(%esp)
80102371:	e8 88 f7 ff ff       	call   80101afe <iunlockput>
      return 0;
80102376:	b8 00 00 00 00       	mov    $0x0,%eax
8010237b:	e9 a3 00 00 00       	jmp    80102423 <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
80102380:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102384:	74 1d                	je     801023a3 <namex+0x95>
80102386:	8b 45 08             	mov    0x8(%ebp),%eax
80102389:	0f b6 00             	movzbl (%eax),%eax
8010238c:	84 c0                	test   %al,%al
8010238e:	75 13                	jne    801023a3 <namex+0x95>
      // Stop one level early.
      iunlock(ip);
80102390:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102393:	89 04 24             	mov    %eax,(%esp)
80102396:	e8 2d f6 ff ff       	call   801019c8 <iunlock>
      return ip;
8010239b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010239e:	e9 80 00 00 00       	jmp    80102423 <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801023a3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801023aa:	00 
801023ab:	8b 45 10             	mov    0x10(%ebp),%eax
801023ae:	89 44 24 04          	mov    %eax,0x4(%esp)
801023b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023b5:	89 04 24             	mov    %eax,(%esp)
801023b8:	e8 df fc ff ff       	call   8010209c <dirlookup>
801023bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
801023c0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801023c4:	75 12                	jne    801023d8 <namex+0xca>
      iunlockput(ip);
801023c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023c9:	89 04 24             	mov    %eax,(%esp)
801023cc:	e8 2d f7 ff ff       	call   80101afe <iunlockput>
      return 0;
801023d1:	b8 00 00 00 00       	mov    $0x0,%eax
801023d6:	eb 4b                	jmp    80102423 <namex+0x115>
    }
    iunlockput(ip);
801023d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023db:	89 04 24             	mov    %eax,(%esp)
801023de:	e8 1b f7 ff ff       	call   80101afe <iunlockput>
    ip = next;
801023e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801023e9:	8b 45 10             	mov    0x10(%ebp),%eax
801023ec:	89 44 24 04          	mov    %eax,0x4(%esp)
801023f0:	8b 45 08             	mov    0x8(%ebp),%eax
801023f3:	89 04 24             	mov    %eax,(%esp)
801023f6:	e8 61 fe ff ff       	call   8010225c <skipelem>
801023fb:	89 45 08             	mov    %eax,0x8(%ebp)
801023fe:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102402:	0f 85 4b ff ff ff    	jne    80102353 <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102408:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010240c:	74 12                	je     80102420 <namex+0x112>
    iput(ip);
8010240e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102411:	89 04 24             	mov    %eax,(%esp)
80102414:	e8 14 f6 ff ff       	call   80101a2d <iput>
    return 0;
80102419:	b8 00 00 00 00       	mov    $0x0,%eax
8010241e:	eb 03                	jmp    80102423 <namex+0x115>
  }
  return ip;
80102420:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102423:	c9                   	leave  
80102424:	c3                   	ret    

80102425 <namei>:

struct inode*
namei(char *path)
{
80102425:	55                   	push   %ebp
80102426:	89 e5                	mov    %esp,%ebp
80102428:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010242b:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010242e:	89 44 24 08          	mov    %eax,0x8(%esp)
80102432:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102439:	00 
8010243a:	8b 45 08             	mov    0x8(%ebp),%eax
8010243d:	89 04 24             	mov    %eax,(%esp)
80102440:	e8 c9 fe ff ff       	call   8010230e <namex>
}
80102445:	c9                   	leave  
80102446:	c3                   	ret    

80102447 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102447:	55                   	push   %ebp
80102448:	89 e5                	mov    %esp,%ebp
8010244a:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
8010244d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102450:	89 44 24 08          	mov    %eax,0x8(%esp)
80102454:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010245b:	00 
8010245c:	8b 45 08             	mov    0x8(%ebp),%eax
8010245f:	89 04 24             	mov    %eax,(%esp)
80102462:	e8 a7 fe ff ff       	call   8010230e <namex>
}
80102467:	c9                   	leave  
80102468:	c3                   	ret    

80102469 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102469:	55                   	push   %ebp
8010246a:	89 e5                	mov    %esp,%ebp
8010246c:	83 ec 14             	sub    $0x14,%esp
8010246f:	8b 45 08             	mov    0x8(%ebp),%eax
80102472:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102476:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010247a:	89 c2                	mov    %eax,%edx
8010247c:	ec                   	in     (%dx),%al
8010247d:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102480:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102484:	c9                   	leave  
80102485:	c3                   	ret    

80102486 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102486:	55                   	push   %ebp
80102487:	89 e5                	mov    %esp,%ebp
80102489:	57                   	push   %edi
8010248a:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
8010248b:	8b 55 08             	mov    0x8(%ebp),%edx
8010248e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102491:	8b 45 10             	mov    0x10(%ebp),%eax
80102494:	89 cb                	mov    %ecx,%ebx
80102496:	89 df                	mov    %ebx,%edi
80102498:	89 c1                	mov    %eax,%ecx
8010249a:	fc                   	cld    
8010249b:	f3 6d                	rep insl (%dx),%es:(%edi)
8010249d:	89 c8                	mov    %ecx,%eax
8010249f:	89 fb                	mov    %edi,%ebx
801024a1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801024a4:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
801024a7:	5b                   	pop    %ebx
801024a8:	5f                   	pop    %edi
801024a9:	5d                   	pop    %ebp
801024aa:	c3                   	ret    

801024ab <outb>:

static inline void
outb(ushort port, uchar data)
{
801024ab:	55                   	push   %ebp
801024ac:	89 e5                	mov    %esp,%ebp
801024ae:	83 ec 08             	sub    $0x8,%esp
801024b1:	8b 55 08             	mov    0x8(%ebp),%edx
801024b4:	8b 45 0c             	mov    0xc(%ebp),%eax
801024b7:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801024bb:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801024be:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801024c2:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801024c6:	ee                   	out    %al,(%dx)
}
801024c7:	c9                   	leave  
801024c8:	c3                   	ret    

801024c9 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801024c9:	55                   	push   %ebp
801024ca:	89 e5                	mov    %esp,%ebp
801024cc:	56                   	push   %esi
801024cd:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801024ce:	8b 55 08             	mov    0x8(%ebp),%edx
801024d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801024d4:	8b 45 10             	mov    0x10(%ebp),%eax
801024d7:	89 cb                	mov    %ecx,%ebx
801024d9:	89 de                	mov    %ebx,%esi
801024db:	89 c1                	mov    %eax,%ecx
801024dd:	fc                   	cld    
801024de:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801024e0:	89 c8                	mov    %ecx,%eax
801024e2:	89 f3                	mov    %esi,%ebx
801024e4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801024e7:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801024ea:	5b                   	pop    %ebx
801024eb:	5e                   	pop    %esi
801024ec:	5d                   	pop    %ebp
801024ed:	c3                   	ret    

801024ee <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801024ee:	55                   	push   %ebp
801024ef:	89 e5                	mov    %esp,%ebp
801024f1:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
801024f4:	90                   	nop
801024f5:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801024fc:	e8 68 ff ff ff       	call   80102469 <inb>
80102501:	0f b6 c0             	movzbl %al,%eax
80102504:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102507:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010250a:	25 c0 00 00 00       	and    $0xc0,%eax
8010250f:	83 f8 40             	cmp    $0x40,%eax
80102512:	75 e1                	jne    801024f5 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102514:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102518:	74 11                	je     8010252b <idewait+0x3d>
8010251a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010251d:	83 e0 21             	and    $0x21,%eax
80102520:	85 c0                	test   %eax,%eax
80102522:	74 07                	je     8010252b <idewait+0x3d>
    return -1;
80102524:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102529:	eb 05                	jmp    80102530 <idewait+0x42>
  return 0;
8010252b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102530:	c9                   	leave  
80102531:	c3                   	ret    

80102532 <ideinit>:

void
ideinit(void)
{
80102532:	55                   	push   %ebp
80102533:	89 e5                	mov    %esp,%ebp
80102535:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
80102538:	c7 44 24 04 24 8b 10 	movl   $0x80108b24,0x4(%esp)
8010253f:	80 
80102540:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80102547:	e8 0d 2a 00 00       	call   80104f59 <initlock>
  picenable(IRQ_IDE);
8010254c:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102553:	e8 39 15 00 00       	call   80103a91 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102558:	a1 00 0f 11 80       	mov    0x80110f00,%eax
8010255d:	83 e8 01             	sub    $0x1,%eax
80102560:	89 44 24 04          	mov    %eax,0x4(%esp)
80102564:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
8010256b:	e8 0c 04 00 00       	call   8010297c <ioapicenable>
  idewait(0);
80102570:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102577:	e8 72 ff ff ff       	call   801024ee <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
8010257c:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
80102583:	00 
80102584:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010258b:	e8 1b ff ff ff       	call   801024ab <outb>
  for(i=0; i<1000; i++){
80102590:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102597:	eb 20                	jmp    801025b9 <ideinit+0x87>
    if(inb(0x1f7) != 0){
80102599:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801025a0:	e8 c4 fe ff ff       	call   80102469 <inb>
801025a5:	84 c0                	test   %al,%al
801025a7:	74 0c                	je     801025b5 <ideinit+0x83>
      havedisk1 = 1;
801025a9:	c7 05 38 c6 10 80 01 	movl   $0x1,0x8010c638
801025b0:	00 00 00 
      break;
801025b3:	eb 0d                	jmp    801025c2 <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801025b5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801025b9:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801025c0:	7e d7                	jle    80102599 <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801025c2:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
801025c9:	00 
801025ca:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801025d1:	e8 d5 fe ff ff       	call   801024ab <outb>
}
801025d6:	c9                   	leave  
801025d7:	c3                   	ret    

801025d8 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801025d8:	55                   	push   %ebp
801025d9:	89 e5                	mov    %esp,%ebp
801025db:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801025de:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025e2:	75 0c                	jne    801025f0 <idestart+0x18>
    panic("idestart");
801025e4:	c7 04 24 28 8b 10 80 	movl   $0x80108b28,(%esp)
801025eb:	e8 4a df ff ff       	call   8010053a <panic>

  idewait(0);
801025f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801025f7:	e8 f2 fe ff ff       	call   801024ee <idewait>
  outb(0x3f6, 0);  // generate interrupt
801025fc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102603:	00 
80102604:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
8010260b:	e8 9b fe ff ff       	call   801024ab <outb>
  outb(0x1f2, 1);  // number of sectors
80102610:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102617:	00 
80102618:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
8010261f:	e8 87 fe ff ff       	call   801024ab <outb>
  outb(0x1f3, b->sector & 0xff);
80102624:	8b 45 08             	mov    0x8(%ebp),%eax
80102627:	8b 40 08             	mov    0x8(%eax),%eax
8010262a:	0f b6 c0             	movzbl %al,%eax
8010262d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102631:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102638:	e8 6e fe ff ff       	call   801024ab <outb>
  outb(0x1f4, (b->sector >> 8) & 0xff);
8010263d:	8b 45 08             	mov    0x8(%ebp),%eax
80102640:	8b 40 08             	mov    0x8(%eax),%eax
80102643:	c1 e8 08             	shr    $0x8,%eax
80102646:	0f b6 c0             	movzbl %al,%eax
80102649:	89 44 24 04          	mov    %eax,0x4(%esp)
8010264d:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
80102654:	e8 52 fe ff ff       	call   801024ab <outb>
  outb(0x1f5, (b->sector >> 16) & 0xff);
80102659:	8b 45 08             	mov    0x8(%ebp),%eax
8010265c:	8b 40 08             	mov    0x8(%eax),%eax
8010265f:	c1 e8 10             	shr    $0x10,%eax
80102662:	0f b6 c0             	movzbl %al,%eax
80102665:	89 44 24 04          	mov    %eax,0x4(%esp)
80102669:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
80102670:	e8 36 fe ff ff       	call   801024ab <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
80102675:	8b 45 08             	mov    0x8(%ebp),%eax
80102678:	8b 40 04             	mov    0x4(%eax),%eax
8010267b:	83 e0 01             	and    $0x1,%eax
8010267e:	c1 e0 04             	shl    $0x4,%eax
80102681:	89 c2                	mov    %eax,%edx
80102683:	8b 45 08             	mov    0x8(%ebp),%eax
80102686:	8b 40 08             	mov    0x8(%eax),%eax
80102689:	c1 e8 18             	shr    $0x18,%eax
8010268c:	83 e0 0f             	and    $0xf,%eax
8010268f:	09 d0                	or     %edx,%eax
80102691:	83 c8 e0             	or     $0xffffffe0,%eax
80102694:	0f b6 c0             	movzbl %al,%eax
80102697:	89 44 24 04          	mov    %eax,0x4(%esp)
8010269b:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801026a2:	e8 04 fe ff ff       	call   801024ab <outb>
  if(b->flags & B_DIRTY){
801026a7:	8b 45 08             	mov    0x8(%ebp),%eax
801026aa:	8b 00                	mov    (%eax),%eax
801026ac:	83 e0 04             	and    $0x4,%eax
801026af:	85 c0                	test   %eax,%eax
801026b1:	74 34                	je     801026e7 <idestart+0x10f>
    outb(0x1f7, IDE_CMD_WRITE);
801026b3:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
801026ba:	00 
801026bb:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801026c2:	e8 e4 fd ff ff       	call   801024ab <outb>
    outsl(0x1f0, b->data, 512/4);
801026c7:	8b 45 08             	mov    0x8(%ebp),%eax
801026ca:	83 c0 18             	add    $0x18,%eax
801026cd:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801026d4:	00 
801026d5:	89 44 24 04          	mov    %eax,0x4(%esp)
801026d9:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
801026e0:	e8 e4 fd ff ff       	call   801024c9 <outsl>
801026e5:	eb 14                	jmp    801026fb <idestart+0x123>
  } else {
    outb(0x1f7, IDE_CMD_READ);
801026e7:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
801026ee:	00 
801026ef:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801026f6:	e8 b0 fd ff ff       	call   801024ab <outb>
  }
}
801026fb:	c9                   	leave  
801026fc:	c3                   	ret    

801026fd <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801026fd:	55                   	push   %ebp
801026fe:	89 e5                	mov    %esp,%ebp
80102700:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102703:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
8010270a:	e8 6b 28 00 00       	call   80104f7a <acquire>
  if((b = idequeue) == 0){
8010270f:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102714:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102717:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010271b:	75 11                	jne    8010272e <ideintr+0x31>
    release(&idelock);
8010271d:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80102724:	e8 b3 28 00 00       	call   80104fdc <release>
    // cprintf("spurious IDE interrupt\n");
    return;
80102729:	e9 90 00 00 00       	jmp    801027be <ideintr+0xc1>
  }
  idequeue = b->qnext;
8010272e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102731:	8b 40 14             	mov    0x14(%eax),%eax
80102734:	a3 34 c6 10 80       	mov    %eax,0x8010c634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102739:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010273c:	8b 00                	mov    (%eax),%eax
8010273e:	83 e0 04             	and    $0x4,%eax
80102741:	85 c0                	test   %eax,%eax
80102743:	75 2e                	jne    80102773 <ideintr+0x76>
80102745:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010274c:	e8 9d fd ff ff       	call   801024ee <idewait>
80102751:	85 c0                	test   %eax,%eax
80102753:	78 1e                	js     80102773 <ideintr+0x76>
    insl(0x1f0, b->data, 512/4);
80102755:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102758:	83 c0 18             	add    $0x18,%eax
8010275b:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102762:	00 
80102763:	89 44 24 04          	mov    %eax,0x4(%esp)
80102767:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
8010276e:	e8 13 fd ff ff       	call   80102486 <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102773:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102776:	8b 00                	mov    (%eax),%eax
80102778:	83 c8 02             	or     $0x2,%eax
8010277b:	89 c2                	mov    %eax,%edx
8010277d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102780:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102782:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102785:	8b 00                	mov    (%eax),%eax
80102787:	83 e0 fb             	and    $0xfffffffb,%eax
8010278a:	89 c2                	mov    %eax,%edx
8010278c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010278f:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102791:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102794:	89 04 24             	mov    %eax,(%esp)
80102797:	e8 25 23 00 00       	call   80104ac1 <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
8010279c:	a1 34 c6 10 80       	mov    0x8010c634,%eax
801027a1:	85 c0                	test   %eax,%eax
801027a3:	74 0d                	je     801027b2 <ideintr+0xb5>
    idestart(idequeue);
801027a5:	a1 34 c6 10 80       	mov    0x8010c634,%eax
801027aa:	89 04 24             	mov    %eax,(%esp)
801027ad:	e8 26 fe ff ff       	call   801025d8 <idestart>

  release(&idelock);
801027b2:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
801027b9:	e8 1e 28 00 00       	call   80104fdc <release>
}
801027be:	c9                   	leave  
801027bf:	c3                   	ret    

801027c0 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801027c0:	55                   	push   %ebp
801027c1:	89 e5                	mov    %esp,%ebp
801027c3:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
801027c6:	8b 45 08             	mov    0x8(%ebp),%eax
801027c9:	8b 00                	mov    (%eax),%eax
801027cb:	83 e0 01             	and    $0x1,%eax
801027ce:	85 c0                	test   %eax,%eax
801027d0:	75 0c                	jne    801027de <iderw+0x1e>
    panic("iderw: buf not busy");
801027d2:	c7 04 24 31 8b 10 80 	movl   $0x80108b31,(%esp)
801027d9:	e8 5c dd ff ff       	call   8010053a <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801027de:	8b 45 08             	mov    0x8(%ebp),%eax
801027e1:	8b 00                	mov    (%eax),%eax
801027e3:	83 e0 06             	and    $0x6,%eax
801027e6:	83 f8 02             	cmp    $0x2,%eax
801027e9:	75 0c                	jne    801027f7 <iderw+0x37>
    panic("iderw: nothing to do");
801027eb:	c7 04 24 45 8b 10 80 	movl   $0x80108b45,(%esp)
801027f2:	e8 43 dd ff ff       	call   8010053a <panic>
  if(b->dev != 0 && !havedisk1)
801027f7:	8b 45 08             	mov    0x8(%ebp),%eax
801027fa:	8b 40 04             	mov    0x4(%eax),%eax
801027fd:	85 c0                	test   %eax,%eax
801027ff:	74 15                	je     80102816 <iderw+0x56>
80102801:	a1 38 c6 10 80       	mov    0x8010c638,%eax
80102806:	85 c0                	test   %eax,%eax
80102808:	75 0c                	jne    80102816 <iderw+0x56>
    panic("iderw: ide disk 1 not present");
8010280a:	c7 04 24 5a 8b 10 80 	movl   $0x80108b5a,(%esp)
80102811:	e8 24 dd ff ff       	call   8010053a <panic>

  acquire(&idelock);  //DOC: acquire-lock
80102816:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
8010281d:	e8 58 27 00 00       	call   80104f7a <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102822:	8b 45 08             	mov    0x8(%ebp),%eax
80102825:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC: insert-queue
8010282c:	c7 45 f4 34 c6 10 80 	movl   $0x8010c634,-0xc(%ebp)
80102833:	eb 0b                	jmp    80102840 <iderw+0x80>
80102835:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102838:	8b 00                	mov    (%eax),%eax
8010283a:	83 c0 14             	add    $0x14,%eax
8010283d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102840:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102843:	8b 00                	mov    (%eax),%eax
80102845:	85 c0                	test   %eax,%eax
80102847:	75 ec                	jne    80102835 <iderw+0x75>
    ;
  *pp = b;
80102849:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010284c:	8b 55 08             	mov    0x8(%ebp),%edx
8010284f:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102851:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102856:	3b 45 08             	cmp    0x8(%ebp),%eax
80102859:	75 0d                	jne    80102868 <iderw+0xa8>
    idestart(b);
8010285b:	8b 45 08             	mov    0x8(%ebp),%eax
8010285e:	89 04 24             	mov    %eax,(%esp)
80102861:	e8 72 fd ff ff       	call   801025d8 <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102866:	eb 15                	jmp    8010287d <iderw+0xbd>
80102868:	eb 13                	jmp    8010287d <iderw+0xbd>
    sleep(b, &idelock);
8010286a:	c7 44 24 04 00 c6 10 	movl   $0x8010c600,0x4(%esp)
80102871:	80 
80102872:	8b 45 08             	mov    0x8(%ebp),%eax
80102875:	89 04 24             	mov    %eax,(%esp)
80102878:	e8 6b 21 00 00       	call   801049e8 <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010287d:	8b 45 08             	mov    0x8(%ebp),%eax
80102880:	8b 00                	mov    (%eax),%eax
80102882:	83 e0 06             	and    $0x6,%eax
80102885:	83 f8 02             	cmp    $0x2,%eax
80102888:	75 e0                	jne    8010286a <iderw+0xaa>
    sleep(b, &idelock);
  }

  release(&idelock);
8010288a:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80102891:	e8 46 27 00 00       	call   80104fdc <release>
}
80102896:	c9                   	leave  
80102897:	c3                   	ret    

80102898 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102898:	55                   	push   %ebp
80102899:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010289b:	a1 34 08 11 80       	mov    0x80110834,%eax
801028a0:	8b 55 08             	mov    0x8(%ebp),%edx
801028a3:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
801028a5:	a1 34 08 11 80       	mov    0x80110834,%eax
801028aa:	8b 40 10             	mov    0x10(%eax),%eax
}
801028ad:	5d                   	pop    %ebp
801028ae:	c3                   	ret    

801028af <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
801028af:	55                   	push   %ebp
801028b0:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801028b2:	a1 34 08 11 80       	mov    0x80110834,%eax
801028b7:	8b 55 08             	mov    0x8(%ebp),%edx
801028ba:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
801028bc:	a1 34 08 11 80       	mov    0x80110834,%eax
801028c1:	8b 55 0c             	mov    0xc(%ebp),%edx
801028c4:	89 50 10             	mov    %edx,0x10(%eax)
}
801028c7:	5d                   	pop    %ebp
801028c8:	c3                   	ret    

801028c9 <ioapicinit>:

void
ioapicinit(void)
{
801028c9:	55                   	push   %ebp
801028ca:	89 e5                	mov    %esp,%ebp
801028cc:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
801028cf:	a1 04 09 11 80       	mov    0x80110904,%eax
801028d4:	85 c0                	test   %eax,%eax
801028d6:	75 05                	jne    801028dd <ioapicinit+0x14>
    return;
801028d8:	e9 9d 00 00 00       	jmp    8010297a <ioapicinit+0xb1>

  ioapic = (volatile struct ioapic*)IOAPIC;
801028dd:	c7 05 34 08 11 80 00 	movl   $0xfec00000,0x80110834
801028e4:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
801028e7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801028ee:	e8 a5 ff ff ff       	call   80102898 <ioapicread>
801028f3:	c1 e8 10             	shr    $0x10,%eax
801028f6:	25 ff 00 00 00       	and    $0xff,%eax
801028fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801028fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102905:	e8 8e ff ff ff       	call   80102898 <ioapicread>
8010290a:	c1 e8 18             	shr    $0x18,%eax
8010290d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102910:	0f b6 05 00 09 11 80 	movzbl 0x80110900,%eax
80102917:	0f b6 c0             	movzbl %al,%eax
8010291a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010291d:	74 0c                	je     8010292b <ioapicinit+0x62>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
8010291f:	c7 04 24 78 8b 10 80 	movl   $0x80108b78,(%esp)
80102926:	e8 75 da ff ff       	call   801003a0 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
8010292b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102932:	eb 3e                	jmp    80102972 <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102934:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102937:	83 c0 20             	add    $0x20,%eax
8010293a:	0d 00 00 01 00       	or     $0x10000,%eax
8010293f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102942:	83 c2 08             	add    $0x8,%edx
80102945:	01 d2                	add    %edx,%edx
80102947:	89 44 24 04          	mov    %eax,0x4(%esp)
8010294b:	89 14 24             	mov    %edx,(%esp)
8010294e:	e8 5c ff ff ff       	call   801028af <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102953:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102956:	83 c0 08             	add    $0x8,%eax
80102959:	01 c0                	add    %eax,%eax
8010295b:	83 c0 01             	add    $0x1,%eax
8010295e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102965:	00 
80102966:	89 04 24             	mov    %eax,(%esp)
80102969:	e8 41 ff ff ff       	call   801028af <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
8010296e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102972:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102975:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102978:	7e ba                	jle    80102934 <ioapicinit+0x6b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
8010297a:	c9                   	leave  
8010297b:	c3                   	ret    

8010297c <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
8010297c:	55                   	push   %ebp
8010297d:	89 e5                	mov    %esp,%ebp
8010297f:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
80102982:	a1 04 09 11 80       	mov    0x80110904,%eax
80102987:	85 c0                	test   %eax,%eax
80102989:	75 02                	jne    8010298d <ioapicenable+0x11>
    return;
8010298b:	eb 37                	jmp    801029c4 <ioapicenable+0x48>

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
8010298d:	8b 45 08             	mov    0x8(%ebp),%eax
80102990:	83 c0 20             	add    $0x20,%eax
80102993:	8b 55 08             	mov    0x8(%ebp),%edx
80102996:	83 c2 08             	add    $0x8,%edx
80102999:	01 d2                	add    %edx,%edx
8010299b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010299f:	89 14 24             	mov    %edx,(%esp)
801029a2:	e8 08 ff ff ff       	call   801028af <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801029a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801029aa:	c1 e0 18             	shl    $0x18,%eax
801029ad:	8b 55 08             	mov    0x8(%ebp),%edx
801029b0:	83 c2 08             	add    $0x8,%edx
801029b3:	01 d2                	add    %edx,%edx
801029b5:	83 c2 01             	add    $0x1,%edx
801029b8:	89 44 24 04          	mov    %eax,0x4(%esp)
801029bc:	89 14 24             	mov    %edx,(%esp)
801029bf:	e8 eb fe ff ff       	call   801028af <ioapicwrite>
}
801029c4:	c9                   	leave  
801029c5:	c3                   	ret    

801029c6 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801029c6:	55                   	push   %ebp
801029c7:	89 e5                	mov    %esp,%ebp
801029c9:	8b 45 08             	mov    0x8(%ebp),%eax
801029cc:	05 00 00 00 80       	add    $0x80000000,%eax
801029d1:	5d                   	pop    %ebp
801029d2:	c3                   	ret    

801029d3 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
801029d3:	55                   	push   %ebp
801029d4:	89 e5                	mov    %esp,%ebp
801029d6:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
801029d9:	c7 44 24 04 aa 8b 10 	movl   $0x80108baa,0x4(%esp)
801029e0:	80 
801029e1:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
801029e8:	e8 6c 25 00 00       	call   80104f59 <initlock>
  kmem.use_lock = 0;
801029ed:	c7 05 74 08 11 80 00 	movl   $0x0,0x80110874
801029f4:	00 00 00 
  freerange(vstart, vend);
801029f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801029fa:	89 44 24 04          	mov    %eax,0x4(%esp)
801029fe:	8b 45 08             	mov    0x8(%ebp),%eax
80102a01:	89 04 24             	mov    %eax,(%esp)
80102a04:	e8 26 00 00 00       	call   80102a2f <freerange>
}
80102a09:	c9                   	leave  
80102a0a:	c3                   	ret    

80102a0b <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102a0b:	55                   	push   %ebp
80102a0c:	89 e5                	mov    %esp,%ebp
80102a0e:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102a11:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a14:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a18:	8b 45 08             	mov    0x8(%ebp),%eax
80102a1b:	89 04 24             	mov    %eax,(%esp)
80102a1e:	e8 0c 00 00 00       	call   80102a2f <freerange>
  kmem.use_lock = 1;
80102a23:	c7 05 74 08 11 80 01 	movl   $0x1,0x80110874
80102a2a:	00 00 00 
}
80102a2d:	c9                   	leave  
80102a2e:	c3                   	ret    

80102a2f <freerange>:

void
freerange(void *vstart, void *vend)
{
80102a2f:	55                   	push   %ebp
80102a30:	89 e5                	mov    %esp,%ebp
80102a32:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102a35:	8b 45 08             	mov    0x8(%ebp),%eax
80102a38:	05 ff 0f 00 00       	add    $0xfff,%eax
80102a3d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102a42:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102a45:	eb 12                	jmp    80102a59 <freerange+0x2a>
    kfree(p);
80102a47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a4a:	89 04 24             	mov    %eax,(%esp)
80102a4d:	e8 16 00 00 00       	call   80102a68 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102a52:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102a59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a5c:	05 00 10 00 00       	add    $0x1000,%eax
80102a61:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102a64:	76 e1                	jbe    80102a47 <freerange+0x18>
    kfree(p);
}
80102a66:	c9                   	leave  
80102a67:	c3                   	ret    

80102a68 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102a68:	55                   	push   %ebp
80102a69:	89 e5                	mov    %esp,%ebp
80102a6b:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102a6e:	8b 45 08             	mov    0x8(%ebp),%eax
80102a71:	25 ff 0f 00 00       	and    $0xfff,%eax
80102a76:	85 c0                	test   %eax,%eax
80102a78:	75 1b                	jne    80102a95 <kfree+0x2d>
80102a7a:	81 7d 08 40 17 12 80 	cmpl   $0x80121740,0x8(%ebp)
80102a81:	72 12                	jb     80102a95 <kfree+0x2d>
80102a83:	8b 45 08             	mov    0x8(%ebp),%eax
80102a86:	89 04 24             	mov    %eax,(%esp)
80102a89:	e8 38 ff ff ff       	call   801029c6 <v2p>
80102a8e:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102a93:	76 0c                	jbe    80102aa1 <kfree+0x39>
    panic("kfree");
80102a95:	c7 04 24 af 8b 10 80 	movl   $0x80108baf,(%esp)
80102a9c:	e8 99 da ff ff       	call   8010053a <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102aa1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102aa8:	00 
80102aa9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102ab0:	00 
80102ab1:	8b 45 08             	mov    0x8(%ebp),%eax
80102ab4:	89 04 24             	mov    %eax,(%esp)
80102ab7:	e8 12 27 00 00       	call   801051ce <memset>

  if(kmem.use_lock)
80102abc:	a1 74 08 11 80       	mov    0x80110874,%eax
80102ac1:	85 c0                	test   %eax,%eax
80102ac3:	74 0c                	je     80102ad1 <kfree+0x69>
    acquire(&kmem.lock);
80102ac5:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80102acc:	e8 a9 24 00 00       	call   80104f7a <acquire>
  r = (struct run*)v;
80102ad1:	8b 45 08             	mov    0x8(%ebp),%eax
80102ad4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102ad7:	8b 15 78 08 11 80    	mov    0x80110878,%edx
80102add:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ae0:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ae5:	a3 78 08 11 80       	mov    %eax,0x80110878
  if(kmem.use_lock)
80102aea:	a1 74 08 11 80       	mov    0x80110874,%eax
80102aef:	85 c0                	test   %eax,%eax
80102af1:	74 0c                	je     80102aff <kfree+0x97>
    release(&kmem.lock);
80102af3:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80102afa:	e8 dd 24 00 00       	call   80104fdc <release>
}
80102aff:	c9                   	leave  
80102b00:	c3                   	ret    

80102b01 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102b01:	55                   	push   %ebp
80102b02:	89 e5                	mov    %esp,%ebp
80102b04:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102b07:	a1 74 08 11 80       	mov    0x80110874,%eax
80102b0c:	85 c0                	test   %eax,%eax
80102b0e:	74 0c                	je     80102b1c <kalloc+0x1b>
    acquire(&kmem.lock);
80102b10:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80102b17:	e8 5e 24 00 00       	call   80104f7a <acquire>
  r = kmem.freelist;
80102b1c:	a1 78 08 11 80       	mov    0x80110878,%eax
80102b21:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102b24:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102b28:	74 0a                	je     80102b34 <kalloc+0x33>
    kmem.freelist = r->next;
80102b2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b2d:	8b 00                	mov    (%eax),%eax
80102b2f:	a3 78 08 11 80       	mov    %eax,0x80110878
  if(kmem.use_lock)
80102b34:	a1 74 08 11 80       	mov    0x80110874,%eax
80102b39:	85 c0                	test   %eax,%eax
80102b3b:	74 0c                	je     80102b49 <kalloc+0x48>
    release(&kmem.lock);
80102b3d:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80102b44:	e8 93 24 00 00       	call   80104fdc <release>
  return (char*)r;
80102b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102b4c:	c9                   	leave  
80102b4d:	c3                   	ret    

80102b4e <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102b4e:	55                   	push   %ebp
80102b4f:	89 e5                	mov    %esp,%ebp
80102b51:	83 ec 14             	sub    $0x14,%esp
80102b54:	8b 45 08             	mov    0x8(%ebp),%eax
80102b57:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102b5b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102b5f:	89 c2                	mov    %eax,%edx
80102b61:	ec                   	in     (%dx),%al
80102b62:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102b65:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102b69:	c9                   	leave  
80102b6a:	c3                   	ret    

80102b6b <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102b6b:	55                   	push   %ebp
80102b6c:	89 e5                	mov    %esp,%ebp
80102b6e:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102b71:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102b78:	e8 d1 ff ff ff       	call   80102b4e <inb>
80102b7d:	0f b6 c0             	movzbl %al,%eax
80102b80:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102b83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b86:	83 e0 01             	and    $0x1,%eax
80102b89:	85 c0                	test   %eax,%eax
80102b8b:	75 0a                	jne    80102b97 <kbdgetc+0x2c>
    return -1;
80102b8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102b92:	e9 25 01 00 00       	jmp    80102cbc <kbdgetc+0x151>
  data = inb(KBDATAP);
80102b97:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102b9e:	e8 ab ff ff ff       	call   80102b4e <inb>
80102ba3:	0f b6 c0             	movzbl %al,%eax
80102ba6:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102ba9:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102bb0:	75 17                	jne    80102bc9 <kbdgetc+0x5e>
    shift |= E0ESC;
80102bb2:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102bb7:	83 c8 40             	or     $0x40,%eax
80102bba:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80102bbf:	b8 00 00 00 00       	mov    $0x0,%eax
80102bc4:	e9 f3 00 00 00       	jmp    80102cbc <kbdgetc+0x151>
  } else if(data & 0x80){
80102bc9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bcc:	25 80 00 00 00       	and    $0x80,%eax
80102bd1:	85 c0                	test   %eax,%eax
80102bd3:	74 45                	je     80102c1a <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102bd5:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102bda:	83 e0 40             	and    $0x40,%eax
80102bdd:	85 c0                	test   %eax,%eax
80102bdf:	75 08                	jne    80102be9 <kbdgetc+0x7e>
80102be1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102be4:	83 e0 7f             	and    $0x7f,%eax
80102be7:	eb 03                	jmp    80102bec <kbdgetc+0x81>
80102be9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bec:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102bef:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bf2:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102bf7:	0f b6 00             	movzbl (%eax),%eax
80102bfa:	83 c8 40             	or     $0x40,%eax
80102bfd:	0f b6 c0             	movzbl %al,%eax
80102c00:	f7 d0                	not    %eax
80102c02:	89 c2                	mov    %eax,%edx
80102c04:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102c09:	21 d0                	and    %edx,%eax
80102c0b:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80102c10:	b8 00 00 00 00       	mov    $0x0,%eax
80102c15:	e9 a2 00 00 00       	jmp    80102cbc <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102c1a:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102c1f:	83 e0 40             	and    $0x40,%eax
80102c22:	85 c0                	test   %eax,%eax
80102c24:	74 14                	je     80102c3a <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102c26:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102c2d:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102c32:	83 e0 bf             	and    $0xffffffbf,%eax
80102c35:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  }

  shift |= shiftcode[data];
80102c3a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c3d:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102c42:	0f b6 00             	movzbl (%eax),%eax
80102c45:	0f b6 d0             	movzbl %al,%edx
80102c48:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102c4d:	09 d0                	or     %edx,%eax
80102c4f:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  shift ^= togglecode[data];
80102c54:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c57:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102c5c:	0f b6 00             	movzbl (%eax),%eax
80102c5f:	0f b6 d0             	movzbl %al,%edx
80102c62:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102c67:	31 d0                	xor    %edx,%eax
80102c69:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102c6e:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102c73:	83 e0 03             	and    $0x3,%eax
80102c76:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102c7d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c80:	01 d0                	add    %edx,%eax
80102c82:	0f b6 00             	movzbl (%eax),%eax
80102c85:	0f b6 c0             	movzbl %al,%eax
80102c88:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102c8b:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102c90:	83 e0 08             	and    $0x8,%eax
80102c93:	85 c0                	test   %eax,%eax
80102c95:	74 22                	je     80102cb9 <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102c97:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102c9b:	76 0c                	jbe    80102ca9 <kbdgetc+0x13e>
80102c9d:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102ca1:	77 06                	ja     80102ca9 <kbdgetc+0x13e>
      c += 'A' - 'a';
80102ca3:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102ca7:	eb 10                	jmp    80102cb9 <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102ca9:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102cad:	76 0a                	jbe    80102cb9 <kbdgetc+0x14e>
80102caf:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102cb3:	77 04                	ja     80102cb9 <kbdgetc+0x14e>
      c += 'a' - 'A';
80102cb5:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102cb9:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102cbc:	c9                   	leave  
80102cbd:	c3                   	ret    

80102cbe <kbdintr>:

void
kbdintr(void)
{
80102cbe:	55                   	push   %ebp
80102cbf:	89 e5                	mov    %esp,%ebp
80102cc1:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102cc4:	c7 04 24 6b 2b 10 80 	movl   $0x80102b6b,(%esp)
80102ccb:	e8 dd da ff ff       	call   801007ad <consoleintr>
}
80102cd0:	c9                   	leave  
80102cd1:	c3                   	ret    

80102cd2 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102cd2:	55                   	push   %ebp
80102cd3:	89 e5                	mov    %esp,%ebp
80102cd5:	83 ec 08             	sub    $0x8,%esp
80102cd8:	8b 55 08             	mov    0x8(%ebp),%edx
80102cdb:	8b 45 0c             	mov    0xc(%ebp),%eax
80102cde:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102ce2:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102ce5:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102ce9:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102ced:	ee                   	out    %al,(%dx)
}
80102cee:	c9                   	leave  
80102cef:	c3                   	ret    

80102cf0 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102cf0:	55                   	push   %ebp
80102cf1:	89 e5                	mov    %esp,%ebp
80102cf3:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102cf6:	9c                   	pushf  
80102cf7:	58                   	pop    %eax
80102cf8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102cfb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102cfe:	c9                   	leave  
80102cff:	c3                   	ret    

80102d00 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102d00:	55                   	push   %ebp
80102d01:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102d03:	a1 7c 08 11 80       	mov    0x8011087c,%eax
80102d08:	8b 55 08             	mov    0x8(%ebp),%edx
80102d0b:	c1 e2 02             	shl    $0x2,%edx
80102d0e:	01 c2                	add    %eax,%edx
80102d10:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d13:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102d15:	a1 7c 08 11 80       	mov    0x8011087c,%eax
80102d1a:	83 c0 20             	add    $0x20,%eax
80102d1d:	8b 00                	mov    (%eax),%eax
}
80102d1f:	5d                   	pop    %ebp
80102d20:	c3                   	ret    

80102d21 <lapicinit>:
//PAGEBREAK!

void
lapicinit(int c)
{
80102d21:	55                   	push   %ebp
80102d22:	89 e5                	mov    %esp,%ebp
80102d24:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
80102d27:	a1 7c 08 11 80       	mov    0x8011087c,%eax
80102d2c:	85 c0                	test   %eax,%eax
80102d2e:	75 05                	jne    80102d35 <lapicinit+0x14>
    return;
80102d30:	e9 43 01 00 00       	jmp    80102e78 <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102d35:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102d3c:	00 
80102d3d:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102d44:	e8 b7 ff ff ff       	call   80102d00 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102d49:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102d50:	00 
80102d51:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102d58:	e8 a3 ff ff ff       	call   80102d00 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102d5d:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102d64:	00 
80102d65:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102d6c:	e8 8f ff ff ff       	call   80102d00 <lapicw>
  lapicw(TICR, 10000000); 
80102d71:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102d78:	00 
80102d79:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102d80:	e8 7b ff ff ff       	call   80102d00 <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102d85:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102d8c:	00 
80102d8d:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80102d94:	e8 67 ff ff ff       	call   80102d00 <lapicw>
  lapicw(LINT1, MASKED);
80102d99:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102da0:	00 
80102da1:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80102da8:	e8 53 ff ff ff       	call   80102d00 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102dad:	a1 7c 08 11 80       	mov    0x8011087c,%eax
80102db2:	83 c0 30             	add    $0x30,%eax
80102db5:	8b 00                	mov    (%eax),%eax
80102db7:	c1 e8 10             	shr    $0x10,%eax
80102dba:	0f b6 c0             	movzbl %al,%eax
80102dbd:	83 f8 03             	cmp    $0x3,%eax
80102dc0:	76 14                	jbe    80102dd6 <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
80102dc2:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102dc9:	00 
80102dca:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80102dd1:	e8 2a ff ff ff       	call   80102d00 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102dd6:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80102ddd:	00 
80102dde:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80102de5:	e8 16 ff ff ff       	call   80102d00 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102dea:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102df1:	00 
80102df2:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102df9:	e8 02 ff ff ff       	call   80102d00 <lapicw>
  lapicw(ESR, 0);
80102dfe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e05:	00 
80102e06:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102e0d:	e8 ee fe ff ff       	call   80102d00 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102e12:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e19:	00 
80102e1a:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102e21:	e8 da fe ff ff       	call   80102d00 <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102e26:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e2d:	00 
80102e2e:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102e35:	e8 c6 fe ff ff       	call   80102d00 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102e3a:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80102e41:	00 
80102e42:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102e49:	e8 b2 fe ff ff       	call   80102d00 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102e4e:	90                   	nop
80102e4f:	a1 7c 08 11 80       	mov    0x8011087c,%eax
80102e54:	05 00 03 00 00       	add    $0x300,%eax
80102e59:	8b 00                	mov    (%eax),%eax
80102e5b:	25 00 10 00 00       	and    $0x1000,%eax
80102e60:	85 c0                	test   %eax,%eax
80102e62:	75 eb                	jne    80102e4f <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102e64:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e6b:	00 
80102e6c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80102e73:	e8 88 fe ff ff       	call   80102d00 <lapicw>
}
80102e78:	c9                   	leave  
80102e79:	c3                   	ret    

80102e7a <cpunum>:

int
cpunum(void)
{
80102e7a:	55                   	push   %ebp
80102e7b:	89 e5                	mov    %esp,%ebp
80102e7d:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102e80:	e8 6b fe ff ff       	call   80102cf0 <readeflags>
80102e85:	25 00 02 00 00       	and    $0x200,%eax
80102e8a:	85 c0                	test   %eax,%eax
80102e8c:	74 25                	je     80102eb3 <cpunum+0x39>
    static int n;
    if(n++ == 0)
80102e8e:	a1 40 c6 10 80       	mov    0x8010c640,%eax
80102e93:	8d 50 01             	lea    0x1(%eax),%edx
80102e96:	89 15 40 c6 10 80    	mov    %edx,0x8010c640
80102e9c:	85 c0                	test   %eax,%eax
80102e9e:	75 13                	jne    80102eb3 <cpunum+0x39>
      cprintf("cpu called from %x with interrupts enabled\n",
80102ea0:	8b 45 04             	mov    0x4(%ebp),%eax
80102ea3:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ea7:	c7 04 24 b8 8b 10 80 	movl   $0x80108bb8,(%esp)
80102eae:	e8 ed d4 ff ff       	call   801003a0 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
80102eb3:	a1 7c 08 11 80       	mov    0x8011087c,%eax
80102eb8:	85 c0                	test   %eax,%eax
80102eba:	74 0f                	je     80102ecb <cpunum+0x51>
    return lapic[ID]>>24;
80102ebc:	a1 7c 08 11 80       	mov    0x8011087c,%eax
80102ec1:	83 c0 20             	add    $0x20,%eax
80102ec4:	8b 00                	mov    (%eax),%eax
80102ec6:	c1 e8 18             	shr    $0x18,%eax
80102ec9:	eb 05                	jmp    80102ed0 <cpunum+0x56>
  return 0;
80102ecb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102ed0:	c9                   	leave  
80102ed1:	c3                   	ret    

80102ed2 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102ed2:	55                   	push   %ebp
80102ed3:	89 e5                	mov    %esp,%ebp
80102ed5:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80102ed8:	a1 7c 08 11 80       	mov    0x8011087c,%eax
80102edd:	85 c0                	test   %eax,%eax
80102edf:	74 14                	je     80102ef5 <lapiceoi+0x23>
    lapicw(EOI, 0);
80102ee1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ee8:	00 
80102ee9:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102ef0:	e8 0b fe ff ff       	call   80102d00 <lapicw>
}
80102ef5:	c9                   	leave  
80102ef6:	c3                   	ret    

80102ef7 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102ef7:	55                   	push   %ebp
80102ef8:	89 e5                	mov    %esp,%ebp
}
80102efa:	5d                   	pop    %ebp
80102efb:	c3                   	ret    

80102efc <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102efc:	55                   	push   %ebp
80102efd:	89 e5                	mov    %esp,%ebp
80102eff:	83 ec 1c             	sub    $0x1c,%esp
80102f02:	8b 45 08             	mov    0x8(%ebp),%eax
80102f05:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
80102f08:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80102f0f:	00 
80102f10:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80102f17:	e8 b6 fd ff ff       	call   80102cd2 <outb>
  outb(IO_RTC+1, 0x0A);
80102f1c:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80102f23:	00 
80102f24:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80102f2b:	e8 a2 fd ff ff       	call   80102cd2 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102f30:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102f37:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102f3a:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102f3f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102f42:	8d 50 02             	lea    0x2(%eax),%edx
80102f45:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f48:	c1 e8 04             	shr    $0x4,%eax
80102f4b:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102f4e:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102f52:	c1 e0 18             	shl    $0x18,%eax
80102f55:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f59:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102f60:	e8 9b fd ff ff       	call   80102d00 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102f65:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80102f6c:	00 
80102f6d:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102f74:	e8 87 fd ff ff       	call   80102d00 <lapicw>
  microdelay(200);
80102f79:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102f80:	e8 72 ff ff ff       	call   80102ef7 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
80102f85:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
80102f8c:	00 
80102f8d:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102f94:	e8 67 fd ff ff       	call   80102d00 <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102f99:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102fa0:	e8 52 ff ff ff       	call   80102ef7 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102fa5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102fac:	eb 40                	jmp    80102fee <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
80102fae:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102fb2:	c1 e0 18             	shl    $0x18,%eax
80102fb5:	89 44 24 04          	mov    %eax,0x4(%esp)
80102fb9:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102fc0:	e8 3b fd ff ff       	call   80102d00 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80102fc5:	8b 45 0c             	mov    0xc(%ebp),%eax
80102fc8:	c1 e8 0c             	shr    $0xc,%eax
80102fcb:	80 cc 06             	or     $0x6,%ah
80102fce:	89 44 24 04          	mov    %eax,0x4(%esp)
80102fd2:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102fd9:	e8 22 fd ff ff       	call   80102d00 <lapicw>
    microdelay(200);
80102fde:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102fe5:	e8 0d ff ff ff       	call   80102ef7 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102fea:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102fee:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102ff2:	7e ba                	jle    80102fae <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80102ff4:	c9                   	leave  
80102ff5:	c3                   	ret    

80102ff6 <initlog>:

static void recover_from_log(void);

void
initlog(void)
{
80102ff6:	55                   	push   %ebp
80102ff7:	89 e5                	mov    %esp,%ebp
80102ff9:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102ffc:	c7 44 24 04 e4 8b 10 	movl   $0x80108be4,0x4(%esp)
80103003:	80 
80103004:	c7 04 24 80 08 11 80 	movl   $0x80110880,(%esp)
8010300b:	e8 49 1f 00 00       	call   80104f59 <initlock>
  readsb(ROOTDEV, &sb);
80103010:	8d 45 e8             	lea    -0x18(%ebp),%eax
80103013:	89 44 24 04          	mov    %eax,0x4(%esp)
80103017:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010301e:	e8 ed e2 ff ff       	call   80101310 <readsb>
  log.start = sb.size - sb.nlog;
80103023:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103026:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103029:	29 c2                	sub    %eax,%edx
8010302b:	89 d0                	mov    %edx,%eax
8010302d:	a3 b4 08 11 80       	mov    %eax,0x801108b4
  log.size = sb.nlog;
80103032:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103035:	a3 b8 08 11 80       	mov    %eax,0x801108b8
  log.dev = ROOTDEV;
8010303a:	c7 05 c0 08 11 80 01 	movl   $0x1,0x801108c0
80103041:	00 00 00 
  recover_from_log();
80103044:	e8 9a 01 00 00       	call   801031e3 <recover_from_log>
}
80103049:	c9                   	leave  
8010304a:	c3                   	ret    

8010304b <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
8010304b:	55                   	push   %ebp
8010304c:	89 e5                	mov    %esp,%ebp
8010304e:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103051:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103058:	e9 8c 00 00 00       	jmp    801030e9 <install_trans+0x9e>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
8010305d:	8b 15 b4 08 11 80    	mov    0x801108b4,%edx
80103063:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103066:	01 d0                	add    %edx,%eax
80103068:	83 c0 01             	add    $0x1,%eax
8010306b:	89 c2                	mov    %eax,%edx
8010306d:	a1 c0 08 11 80       	mov    0x801108c0,%eax
80103072:	89 54 24 04          	mov    %edx,0x4(%esp)
80103076:	89 04 24             	mov    %eax,(%esp)
80103079:	e8 28 d1 ff ff       	call   801001a6 <bread>
8010307e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
80103081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103084:	83 c0 10             	add    $0x10,%eax
80103087:	8b 04 85 88 08 11 80 	mov    -0x7feef778(,%eax,4),%eax
8010308e:	89 c2                	mov    %eax,%edx
80103090:	a1 c0 08 11 80       	mov    0x801108c0,%eax
80103095:	89 54 24 04          	mov    %edx,0x4(%esp)
80103099:	89 04 24             	mov    %eax,(%esp)
8010309c:	e8 05 d1 ff ff       	call   801001a6 <bread>
801030a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801030a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801030a7:	8d 50 18             	lea    0x18(%eax),%edx
801030aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801030ad:	83 c0 18             	add    $0x18,%eax
801030b0:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801030b7:	00 
801030b8:	89 54 24 04          	mov    %edx,0x4(%esp)
801030bc:	89 04 24             	mov    %eax,(%esp)
801030bf:	e8 d9 21 00 00       	call   8010529d <memmove>
    bwrite(dbuf);  // write dst to disk
801030c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801030c7:	89 04 24             	mov    %eax,(%esp)
801030ca:	e8 0e d1 ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
801030cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801030d2:	89 04 24             	mov    %eax,(%esp)
801030d5:	e8 3d d1 ff ff       	call   80100217 <brelse>
    brelse(dbuf);
801030da:	8b 45 ec             	mov    -0x14(%ebp),%eax
801030dd:	89 04 24             	mov    %eax,(%esp)
801030e0:	e8 32 d1 ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801030e5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801030e9:	a1 c4 08 11 80       	mov    0x801108c4,%eax
801030ee:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801030f1:	0f 8f 66 ff ff ff    	jg     8010305d <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
801030f7:	c9                   	leave  
801030f8:	c3                   	ret    

801030f9 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801030f9:	55                   	push   %ebp
801030fa:	89 e5                	mov    %esp,%ebp
801030fc:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801030ff:	a1 b4 08 11 80       	mov    0x801108b4,%eax
80103104:	89 c2                	mov    %eax,%edx
80103106:	a1 c0 08 11 80       	mov    0x801108c0,%eax
8010310b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010310f:	89 04 24             	mov    %eax,(%esp)
80103112:	e8 8f d0 ff ff       	call   801001a6 <bread>
80103117:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
8010311a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010311d:	83 c0 18             	add    $0x18,%eax
80103120:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103123:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103126:	8b 00                	mov    (%eax),%eax
80103128:	a3 c4 08 11 80       	mov    %eax,0x801108c4
  for (i = 0; i < log.lh.n; i++) {
8010312d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103134:	eb 1b                	jmp    80103151 <read_head+0x58>
    log.lh.sector[i] = lh->sector[i];
80103136:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103139:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010313c:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103140:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103143:	83 c2 10             	add    $0x10,%edx
80103146:	89 04 95 88 08 11 80 	mov    %eax,-0x7feef778(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
8010314d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103151:	a1 c4 08 11 80       	mov    0x801108c4,%eax
80103156:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103159:	7f db                	jg     80103136 <read_head+0x3d>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
8010315b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010315e:	89 04 24             	mov    %eax,(%esp)
80103161:	e8 b1 d0 ff ff       	call   80100217 <brelse>
}
80103166:	c9                   	leave  
80103167:	c3                   	ret    

80103168 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103168:	55                   	push   %ebp
80103169:	89 e5                	mov    %esp,%ebp
8010316b:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010316e:	a1 b4 08 11 80       	mov    0x801108b4,%eax
80103173:	89 c2                	mov    %eax,%edx
80103175:	a1 c0 08 11 80       	mov    0x801108c0,%eax
8010317a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010317e:	89 04 24             	mov    %eax,(%esp)
80103181:	e8 20 d0 ff ff       	call   801001a6 <bread>
80103186:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103189:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010318c:	83 c0 18             	add    $0x18,%eax
8010318f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103192:	8b 15 c4 08 11 80    	mov    0x801108c4,%edx
80103198:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010319b:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010319d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801031a4:	eb 1b                	jmp    801031c1 <write_head+0x59>
    hb->sector[i] = log.lh.sector[i];
801031a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031a9:	83 c0 10             	add    $0x10,%eax
801031ac:	8b 0c 85 88 08 11 80 	mov    -0x7feef778(,%eax,4),%ecx
801031b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801031b9:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801031bd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801031c1:	a1 c4 08 11 80       	mov    0x801108c4,%eax
801031c6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801031c9:	7f db                	jg     801031a6 <write_head+0x3e>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
801031cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031ce:	89 04 24             	mov    %eax,(%esp)
801031d1:	e8 07 d0 ff ff       	call   801001dd <bwrite>
  brelse(buf);
801031d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031d9:	89 04 24             	mov    %eax,(%esp)
801031dc:	e8 36 d0 ff ff       	call   80100217 <brelse>
}
801031e1:	c9                   	leave  
801031e2:	c3                   	ret    

801031e3 <recover_from_log>:

static void
recover_from_log(void)
{
801031e3:	55                   	push   %ebp
801031e4:	89 e5                	mov    %esp,%ebp
801031e6:	83 ec 08             	sub    $0x8,%esp
  read_head();      
801031e9:	e8 0b ff ff ff       	call   801030f9 <read_head>
  install_trans(); // if committed, copy from log to disk
801031ee:	e8 58 fe ff ff       	call   8010304b <install_trans>
  log.lh.n = 0;
801031f3:	c7 05 c4 08 11 80 00 	movl   $0x0,0x801108c4
801031fa:	00 00 00 
  write_head(); // clear the log
801031fd:	e8 66 ff ff ff       	call   80103168 <write_head>
}
80103202:	c9                   	leave  
80103203:	c3                   	ret    

80103204 <begin_trans>:

void
begin_trans(void)
{
80103204:	55                   	push   %ebp
80103205:	89 e5                	mov    %esp,%ebp
80103207:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
8010320a:	c7 04 24 80 08 11 80 	movl   $0x80110880,(%esp)
80103211:	e8 64 1d 00 00       	call   80104f7a <acquire>
  while (log.busy) {
80103216:	eb 14                	jmp    8010322c <begin_trans+0x28>
    sleep(&log, &log.lock);
80103218:	c7 44 24 04 80 08 11 	movl   $0x80110880,0x4(%esp)
8010321f:	80 
80103220:	c7 04 24 80 08 11 80 	movl   $0x80110880,(%esp)
80103227:	e8 bc 17 00 00       	call   801049e8 <sleep>

void
begin_trans(void)
{
  acquire(&log.lock);
  while (log.busy) {
8010322c:	a1 bc 08 11 80       	mov    0x801108bc,%eax
80103231:	85 c0                	test   %eax,%eax
80103233:	75 e3                	jne    80103218 <begin_trans+0x14>
    sleep(&log, &log.lock);
  }
  log.busy = 1;
80103235:	c7 05 bc 08 11 80 01 	movl   $0x1,0x801108bc
8010323c:	00 00 00 
  release(&log.lock);
8010323f:	c7 04 24 80 08 11 80 	movl   $0x80110880,(%esp)
80103246:	e8 91 1d 00 00       	call   80104fdc <release>
}
8010324b:	c9                   	leave  
8010324c:	c3                   	ret    

8010324d <commit_trans>:

void
commit_trans(void)
{
8010324d:	55                   	push   %ebp
8010324e:	89 e5                	mov    %esp,%ebp
80103250:	83 ec 18             	sub    $0x18,%esp
  if (log.lh.n > 0) {
80103253:	a1 c4 08 11 80       	mov    0x801108c4,%eax
80103258:	85 c0                	test   %eax,%eax
8010325a:	7e 19                	jle    80103275 <commit_trans+0x28>
    write_head();    // Write header to disk -- the real commit
8010325c:	e8 07 ff ff ff       	call   80103168 <write_head>
    install_trans(); // Now install writes to home locations
80103261:	e8 e5 fd ff ff       	call   8010304b <install_trans>
    log.lh.n = 0; 
80103266:	c7 05 c4 08 11 80 00 	movl   $0x0,0x801108c4
8010326d:	00 00 00 
    write_head();    // Erase the transaction from the log
80103270:	e8 f3 fe ff ff       	call   80103168 <write_head>
  }
  
  acquire(&log.lock);
80103275:	c7 04 24 80 08 11 80 	movl   $0x80110880,(%esp)
8010327c:	e8 f9 1c 00 00       	call   80104f7a <acquire>
  log.busy = 0;
80103281:	c7 05 bc 08 11 80 00 	movl   $0x0,0x801108bc
80103288:	00 00 00 
  wakeup(&log);
8010328b:	c7 04 24 80 08 11 80 	movl   $0x80110880,(%esp)
80103292:	e8 2a 18 00 00       	call   80104ac1 <wakeup>
  release(&log.lock);
80103297:	c7 04 24 80 08 11 80 	movl   $0x80110880,(%esp)
8010329e:	e8 39 1d 00 00       	call   80104fdc <release>
}
801032a3:	c9                   	leave  
801032a4:	c3                   	ret    

801032a5 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801032a5:	55                   	push   %ebp
801032a6:	89 e5                	mov    %esp,%ebp
801032a8:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801032ab:	a1 c4 08 11 80       	mov    0x801108c4,%eax
801032b0:	83 f8 09             	cmp    $0x9,%eax
801032b3:	7f 12                	jg     801032c7 <log_write+0x22>
801032b5:	a1 c4 08 11 80       	mov    0x801108c4,%eax
801032ba:	8b 15 b8 08 11 80    	mov    0x801108b8,%edx
801032c0:	83 ea 01             	sub    $0x1,%edx
801032c3:	39 d0                	cmp    %edx,%eax
801032c5:	7c 0c                	jl     801032d3 <log_write+0x2e>
    panic("too big a transaction");
801032c7:	c7 04 24 e8 8b 10 80 	movl   $0x80108be8,(%esp)
801032ce:	e8 67 d2 ff ff       	call   8010053a <panic>
  if (!log.busy)
801032d3:	a1 bc 08 11 80       	mov    0x801108bc,%eax
801032d8:	85 c0                	test   %eax,%eax
801032da:	75 0c                	jne    801032e8 <log_write+0x43>
    panic("write outside of trans");
801032dc:	c7 04 24 fe 8b 10 80 	movl   $0x80108bfe,(%esp)
801032e3:	e8 52 d2 ff ff       	call   8010053a <panic>

  for (i = 0; i < log.lh.n; i++) {
801032e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032ef:	eb 1f                	jmp    80103310 <log_write+0x6b>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
801032f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032f4:	83 c0 10             	add    $0x10,%eax
801032f7:	8b 04 85 88 08 11 80 	mov    -0x7feef778(,%eax,4),%eax
801032fe:	89 c2                	mov    %eax,%edx
80103300:	8b 45 08             	mov    0x8(%ebp),%eax
80103303:	8b 40 08             	mov    0x8(%eax),%eax
80103306:	39 c2                	cmp    %eax,%edx
80103308:	75 02                	jne    8010330c <log_write+0x67>
      break;
8010330a:	eb 0e                	jmp    8010331a <log_write+0x75>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    panic("too big a transaction");
  if (!log.busy)
    panic("write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
8010330c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103310:	a1 c4 08 11 80       	mov    0x801108c4,%eax
80103315:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103318:	7f d7                	jg     801032f1 <log_write+0x4c>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
      break;
  }
  log.lh.sector[i] = b->sector;
8010331a:	8b 45 08             	mov    0x8(%ebp),%eax
8010331d:	8b 40 08             	mov    0x8(%eax),%eax
80103320:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103323:	83 c2 10             	add    $0x10,%edx
80103326:	89 04 95 88 08 11 80 	mov    %eax,-0x7feef778(,%edx,4)
  struct buf *lbuf = bread(b->dev, log.start+i+1);
8010332d:	8b 15 b4 08 11 80    	mov    0x801108b4,%edx
80103333:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103336:	01 d0                	add    %edx,%eax
80103338:	83 c0 01             	add    $0x1,%eax
8010333b:	89 c2                	mov    %eax,%edx
8010333d:	8b 45 08             	mov    0x8(%ebp),%eax
80103340:	8b 40 04             	mov    0x4(%eax),%eax
80103343:	89 54 24 04          	mov    %edx,0x4(%esp)
80103347:	89 04 24             	mov    %eax,(%esp)
8010334a:	e8 57 ce ff ff       	call   801001a6 <bread>
8010334f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(lbuf->data, b->data, BSIZE);
80103352:	8b 45 08             	mov    0x8(%ebp),%eax
80103355:	8d 50 18             	lea    0x18(%eax),%edx
80103358:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010335b:	83 c0 18             	add    $0x18,%eax
8010335e:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103365:	00 
80103366:	89 54 24 04          	mov    %edx,0x4(%esp)
8010336a:	89 04 24             	mov    %eax,(%esp)
8010336d:	e8 2b 1f 00 00       	call   8010529d <memmove>
  bwrite(lbuf);
80103372:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103375:	89 04 24             	mov    %eax,(%esp)
80103378:	e8 60 ce ff ff       	call   801001dd <bwrite>
  brelse(lbuf);
8010337d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103380:	89 04 24             	mov    %eax,(%esp)
80103383:	e8 8f ce ff ff       	call   80100217 <brelse>
  if (i == log.lh.n)
80103388:	a1 c4 08 11 80       	mov    0x801108c4,%eax
8010338d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103390:	75 0d                	jne    8010339f <log_write+0xfa>
    log.lh.n++;
80103392:	a1 c4 08 11 80       	mov    0x801108c4,%eax
80103397:	83 c0 01             	add    $0x1,%eax
8010339a:	a3 c4 08 11 80       	mov    %eax,0x801108c4
  b->flags |= B_DIRTY; // XXX prevent eviction
8010339f:	8b 45 08             	mov    0x8(%ebp),%eax
801033a2:	8b 00                	mov    (%eax),%eax
801033a4:	83 c8 04             	or     $0x4,%eax
801033a7:	89 c2                	mov    %eax,%edx
801033a9:	8b 45 08             	mov    0x8(%ebp),%eax
801033ac:	89 10                	mov    %edx,(%eax)
}
801033ae:	c9                   	leave  
801033af:	c3                   	ret    

801033b0 <v2p>:
801033b0:	55                   	push   %ebp
801033b1:	89 e5                	mov    %esp,%ebp
801033b3:	8b 45 08             	mov    0x8(%ebp),%eax
801033b6:	05 00 00 00 80       	add    $0x80000000,%eax
801033bb:	5d                   	pop    %ebp
801033bc:	c3                   	ret    

801033bd <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801033bd:	55                   	push   %ebp
801033be:	89 e5                	mov    %esp,%ebp
801033c0:	8b 45 08             	mov    0x8(%ebp),%eax
801033c3:	05 00 00 00 80       	add    $0x80000000,%eax
801033c8:	5d                   	pop    %ebp
801033c9:	c3                   	ret    

801033ca <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801033ca:	55                   	push   %ebp
801033cb:	89 e5                	mov    %esp,%ebp
801033cd:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801033d0:	8b 55 08             	mov    0x8(%ebp),%edx
801033d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801033d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
801033d9:	f0 87 02             	lock xchg %eax,(%edx)
801033dc:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801033df:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801033e2:	c9                   	leave  
801033e3:	c3                   	ret    

801033e4 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801033e4:	55                   	push   %ebp
801033e5:	89 e5                	mov    %esp,%ebp
801033e7:	83 e4 f0             	and    $0xfffffff0,%esp
801033ea:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801033ed:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
801033f4:	80 
801033f5:	c7 04 24 40 17 12 80 	movl   $0x80121740,(%esp)
801033fc:	e8 d2 f5 ff ff       	call   801029d3 <kinit1>
  kvmalloc();      // kernel page table
80103401:	e8 09 4a 00 00       	call   80107e0f <kvmalloc>
  mpinit();        // collect info about this machine
80103406:	e8 56 04 00 00       	call   80103861 <mpinit>
  lapicinit(mpbcpu());
8010340b:	e8 1f 02 00 00       	call   8010362f <mpbcpu>
80103410:	89 04 24             	mov    %eax,(%esp)
80103413:	e8 09 f9 ff ff       	call   80102d21 <lapicinit>
  seginit();       // set up segments
80103418:	e8 71 43 00 00       	call   8010778e <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
8010341d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103423:	0f b6 00             	movzbl (%eax),%eax
80103426:	0f b6 c0             	movzbl %al,%eax
80103429:	89 44 24 04          	mov    %eax,0x4(%esp)
8010342d:	c7 04 24 15 8c 10 80 	movl   $0x80108c15,(%esp)
80103434:	e8 67 cf ff ff       	call   801003a0 <cprintf>
  picinit();       // interrupt controller
80103439:	e8 81 06 00 00       	call   80103abf <picinit>
  ioapicinit();    // another interrupt controller
8010343e:	e8 86 f4 ff ff       	call   801028c9 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80103443:	e8 39 d6 ff ff       	call   80100a81 <consoleinit>
  uartinit();      // serial port
80103448:	e8 90 36 00 00       	call   80106add <uartinit>
  pinit();         // process table
8010344d:	e8 77 0b 00 00       	call   80103fc9 <pinit>
  tvinit();        // trap vectors
80103452:	e8 17 32 00 00       	call   8010666e <tvinit>
  binit();         // buffer cache
80103457:	e8 d8 cb ff ff       	call   80100034 <binit>
  fileinit();      // file table
8010345c:	e8 c8 da ff ff       	call   80100f29 <fileinit>
  iinit();         // inode cache
80103461:	e8 5d e1 ff ff       	call   801015c3 <iinit>
  ideinit();       // disk
80103466:	e8 c7 f0 ff ff       	call   80102532 <ideinit>
  if(!ismp)
8010346b:	a1 04 09 11 80       	mov    0x80110904,%eax
80103470:	85 c0                	test   %eax,%eax
80103472:	75 05                	jne    80103479 <main+0x95>
    timerinit();   // uniprocessor timer
80103474:	e8 35 31 00 00       	call   801065ae <timerinit>
  startothers();   // start other processors
80103479:	e8 87 00 00 00       	call   80103505 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
8010347e:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80103485:	8e 
80103486:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
8010348d:	e8 79 f5 ff ff       	call   80102a0b <kinit2>
  userinit();      // first user process
80103492:	e8 4d 0c 00 00       	call   801040e4 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103497:	e8 22 00 00 00       	call   801034be <mpmain>

8010349c <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
8010349c:	55                   	push   %ebp
8010349d:	89 e5                	mov    %esp,%ebp
8010349f:	83 ec 18             	sub    $0x18,%esp
  switchkvm(); 
801034a2:	e8 7f 49 00 00       	call   80107e26 <switchkvm>
  seginit();
801034a7:	e8 e2 42 00 00       	call   8010778e <seginit>
  lapicinit(cpunum());
801034ac:	e8 c9 f9 ff ff       	call   80102e7a <cpunum>
801034b1:	89 04 24             	mov    %eax,(%esp)
801034b4:	e8 68 f8 ff ff       	call   80102d21 <lapicinit>
  mpmain();
801034b9:	e8 00 00 00 00       	call   801034be <mpmain>

801034be <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801034be:	55                   	push   %ebp
801034bf:	89 e5                	mov    %esp,%ebp
801034c1:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
801034c4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801034ca:	0f b6 00             	movzbl (%eax),%eax
801034cd:	0f b6 c0             	movzbl %al,%eax
801034d0:	89 44 24 04          	mov    %eax,0x4(%esp)
801034d4:	c7 04 24 2c 8c 10 80 	movl   $0x80108c2c,(%esp)
801034db:	e8 c0 ce ff ff       	call   801003a0 <cprintf>
  idtinit();       // load idt register
801034e0:	e8 fd 32 00 00       	call   801067e2 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
801034e5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801034eb:	05 a8 00 00 00       	add    $0xa8,%eax
801034f0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801034f7:	00 
801034f8:	89 04 24             	mov    %eax,(%esp)
801034fb:	e8 ca fe ff ff       	call   801033ca <xchg>
  scheduler();     // start running processes
80103500:	e8 3b 13 00 00       	call   80104840 <scheduler>

80103505 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103505:	55                   	push   %ebp
80103506:	89 e5                	mov    %esp,%ebp
80103508:	53                   	push   %ebx
80103509:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
8010350c:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
80103513:	e8 a5 fe ff ff       	call   801033bd <p2v>
80103518:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010351b:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103520:	89 44 24 08          	mov    %eax,0x8(%esp)
80103524:	c7 44 24 04 0c c5 10 	movl   $0x8010c50c,0x4(%esp)
8010352b:	80 
8010352c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010352f:	89 04 24             	mov    %eax,(%esp)
80103532:	e8 66 1d 00 00       	call   8010529d <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103537:	c7 45 f4 20 09 11 80 	movl   $0x80110920,-0xc(%ebp)
8010353e:	e9 85 00 00 00       	jmp    801035c8 <startothers+0xc3>
    if(c == cpus+cpunum())  // We've started already.
80103543:	e8 32 f9 ff ff       	call   80102e7a <cpunum>
80103548:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010354e:	05 20 09 11 80       	add    $0x80110920,%eax
80103553:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103556:	75 02                	jne    8010355a <startothers+0x55>
      continue;
80103558:	eb 67                	jmp    801035c1 <startothers+0xbc>

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010355a:	e8 a2 f5 ff ff       	call   80102b01 <kalloc>
8010355f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103562:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103565:	83 e8 04             	sub    $0x4,%eax
80103568:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010356b:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103571:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103573:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103576:	83 e8 08             	sub    $0x8,%eax
80103579:	c7 00 9c 34 10 80    	movl   $0x8010349c,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
8010357f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103582:	8d 58 f4             	lea    -0xc(%eax),%ebx
80103585:	c7 04 24 00 b0 10 80 	movl   $0x8010b000,(%esp)
8010358c:	e8 1f fe ff ff       	call   801033b0 <v2p>
80103591:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80103593:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103596:	89 04 24             	mov    %eax,(%esp)
80103599:	e8 12 fe ff ff       	call   801033b0 <v2p>
8010359e:	8b 55 f4             	mov    -0xc(%ebp),%edx
801035a1:	0f b6 12             	movzbl (%edx),%edx
801035a4:	0f b6 d2             	movzbl %dl,%edx
801035a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801035ab:	89 14 24             	mov    %edx,(%esp)
801035ae:	e8 49 f9 ff ff       	call   80102efc <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801035b3:	90                   	nop
801035b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035b7:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801035bd:	85 c0                	test   %eax,%eax
801035bf:	74 f3                	je     801035b4 <startothers+0xaf>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
801035c1:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
801035c8:	a1 00 0f 11 80       	mov    0x80110f00,%eax
801035cd:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801035d3:	05 20 09 11 80       	add    $0x80110920,%eax
801035d8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801035db:	0f 87 62 ff ff ff    	ja     80103543 <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
801035e1:	83 c4 24             	add    $0x24,%esp
801035e4:	5b                   	pop    %ebx
801035e5:	5d                   	pop    %ebp
801035e6:	c3                   	ret    

801035e7 <p2v>:
801035e7:	55                   	push   %ebp
801035e8:	89 e5                	mov    %esp,%ebp
801035ea:	8b 45 08             	mov    0x8(%ebp),%eax
801035ed:	05 00 00 00 80       	add    $0x80000000,%eax
801035f2:	5d                   	pop    %ebp
801035f3:	c3                   	ret    

801035f4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801035f4:	55                   	push   %ebp
801035f5:	89 e5                	mov    %esp,%ebp
801035f7:	83 ec 14             	sub    $0x14,%esp
801035fa:	8b 45 08             	mov    0x8(%ebp),%eax
801035fd:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103601:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103605:	89 c2                	mov    %eax,%edx
80103607:	ec                   	in     (%dx),%al
80103608:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010360b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010360f:	c9                   	leave  
80103610:	c3                   	ret    

80103611 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103611:	55                   	push   %ebp
80103612:	89 e5                	mov    %esp,%ebp
80103614:	83 ec 08             	sub    $0x8,%esp
80103617:	8b 55 08             	mov    0x8(%ebp),%edx
8010361a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010361d:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103621:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103624:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103628:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010362c:	ee                   	out    %al,(%dx)
}
8010362d:	c9                   	leave  
8010362e:	c3                   	ret    

8010362f <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
8010362f:	55                   	push   %ebp
80103630:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103632:	a1 44 c6 10 80       	mov    0x8010c644,%eax
80103637:	89 c2                	mov    %eax,%edx
80103639:	b8 20 09 11 80       	mov    $0x80110920,%eax
8010363e:	29 c2                	sub    %eax,%edx
80103640:	89 d0                	mov    %edx,%eax
80103642:	c1 f8 02             	sar    $0x2,%eax
80103645:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
8010364b:	5d                   	pop    %ebp
8010364c:	c3                   	ret    

8010364d <sum>:

static uchar
sum(uchar *addr, int len)
{
8010364d:	55                   	push   %ebp
8010364e:	89 e5                	mov    %esp,%ebp
80103650:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103653:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
8010365a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103661:	eb 15                	jmp    80103678 <sum+0x2b>
    sum += addr[i];
80103663:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103666:	8b 45 08             	mov    0x8(%ebp),%eax
80103669:	01 d0                	add    %edx,%eax
8010366b:	0f b6 00             	movzbl (%eax),%eax
8010366e:	0f b6 c0             	movzbl %al,%eax
80103671:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103674:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103678:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010367b:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010367e:	7c e3                	jl     80103663 <sum+0x16>
    sum += addr[i];
  return sum;
80103680:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103683:	c9                   	leave  
80103684:	c3                   	ret    

80103685 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103685:	55                   	push   %ebp
80103686:	89 e5                	mov    %esp,%ebp
80103688:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
8010368b:	8b 45 08             	mov    0x8(%ebp),%eax
8010368e:	89 04 24             	mov    %eax,(%esp)
80103691:	e8 51 ff ff ff       	call   801035e7 <p2v>
80103696:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103699:	8b 55 0c             	mov    0xc(%ebp),%edx
8010369c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010369f:	01 d0                	add    %edx,%eax
801036a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
801036a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801036aa:	eb 3f                	jmp    801036eb <mpsearch1+0x66>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801036ac:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801036b3:	00 
801036b4:	c7 44 24 04 40 8c 10 	movl   $0x80108c40,0x4(%esp)
801036bb:	80 
801036bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036bf:	89 04 24             	mov    %eax,(%esp)
801036c2:	e8 7e 1b 00 00       	call   80105245 <memcmp>
801036c7:	85 c0                	test   %eax,%eax
801036c9:	75 1c                	jne    801036e7 <mpsearch1+0x62>
801036cb:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
801036d2:	00 
801036d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036d6:	89 04 24             	mov    %eax,(%esp)
801036d9:	e8 6f ff ff ff       	call   8010364d <sum>
801036de:	84 c0                	test   %al,%al
801036e0:	75 05                	jne    801036e7 <mpsearch1+0x62>
      return (struct mp*)p;
801036e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036e5:	eb 11                	jmp    801036f8 <mpsearch1+0x73>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
801036e7:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801036eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036ee:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801036f1:	72 b9                	jb     801036ac <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
801036f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801036f8:	c9                   	leave  
801036f9:	c3                   	ret    

801036fa <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
801036fa:	55                   	push   %ebp
801036fb:	89 e5                	mov    %esp,%ebp
801036fd:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103700:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103707:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010370a:	83 c0 0f             	add    $0xf,%eax
8010370d:	0f b6 00             	movzbl (%eax),%eax
80103710:	0f b6 c0             	movzbl %al,%eax
80103713:	c1 e0 08             	shl    $0x8,%eax
80103716:	89 c2                	mov    %eax,%edx
80103718:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010371b:	83 c0 0e             	add    $0xe,%eax
8010371e:	0f b6 00             	movzbl (%eax),%eax
80103721:	0f b6 c0             	movzbl %al,%eax
80103724:	09 d0                	or     %edx,%eax
80103726:	c1 e0 04             	shl    $0x4,%eax
80103729:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010372c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103730:	74 21                	je     80103753 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103732:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103739:	00 
8010373a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010373d:	89 04 24             	mov    %eax,(%esp)
80103740:	e8 40 ff ff ff       	call   80103685 <mpsearch1>
80103745:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103748:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010374c:	74 50                	je     8010379e <mpsearch+0xa4>
      return mp;
8010374e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103751:	eb 5f                	jmp    801037b2 <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103753:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103756:	83 c0 14             	add    $0x14,%eax
80103759:	0f b6 00             	movzbl (%eax),%eax
8010375c:	0f b6 c0             	movzbl %al,%eax
8010375f:	c1 e0 08             	shl    $0x8,%eax
80103762:	89 c2                	mov    %eax,%edx
80103764:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103767:	83 c0 13             	add    $0x13,%eax
8010376a:	0f b6 00             	movzbl (%eax),%eax
8010376d:	0f b6 c0             	movzbl %al,%eax
80103770:	09 d0                	or     %edx,%eax
80103772:	c1 e0 0a             	shl    $0xa,%eax
80103775:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103778:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010377b:	2d 00 04 00 00       	sub    $0x400,%eax
80103780:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103787:	00 
80103788:	89 04 24             	mov    %eax,(%esp)
8010378b:	e8 f5 fe ff ff       	call   80103685 <mpsearch1>
80103790:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103793:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103797:	74 05                	je     8010379e <mpsearch+0xa4>
      return mp;
80103799:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010379c:	eb 14                	jmp    801037b2 <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
8010379e:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801037a5:	00 
801037a6:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
801037ad:	e8 d3 fe ff ff       	call   80103685 <mpsearch1>
}
801037b2:	c9                   	leave  
801037b3:	c3                   	ret    

801037b4 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
801037b4:	55                   	push   %ebp
801037b5:	89 e5                	mov    %esp,%ebp
801037b7:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
801037ba:	e8 3b ff ff ff       	call   801036fa <mpsearch>
801037bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
801037c2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801037c6:	74 0a                	je     801037d2 <mpconfig+0x1e>
801037c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037cb:	8b 40 04             	mov    0x4(%eax),%eax
801037ce:	85 c0                	test   %eax,%eax
801037d0:	75 0a                	jne    801037dc <mpconfig+0x28>
    return 0;
801037d2:	b8 00 00 00 00       	mov    $0x0,%eax
801037d7:	e9 83 00 00 00       	jmp    8010385f <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
801037dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037df:	8b 40 04             	mov    0x4(%eax),%eax
801037e2:	89 04 24             	mov    %eax,(%esp)
801037e5:	e8 fd fd ff ff       	call   801035e7 <p2v>
801037ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
801037ed:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801037f4:	00 
801037f5:	c7 44 24 04 45 8c 10 	movl   $0x80108c45,0x4(%esp)
801037fc:	80 
801037fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103800:	89 04 24             	mov    %eax,(%esp)
80103803:	e8 3d 1a 00 00       	call   80105245 <memcmp>
80103808:	85 c0                	test   %eax,%eax
8010380a:	74 07                	je     80103813 <mpconfig+0x5f>
    return 0;
8010380c:	b8 00 00 00 00       	mov    $0x0,%eax
80103811:	eb 4c                	jmp    8010385f <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80103813:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103816:	0f b6 40 06          	movzbl 0x6(%eax),%eax
8010381a:	3c 01                	cmp    $0x1,%al
8010381c:	74 12                	je     80103830 <mpconfig+0x7c>
8010381e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103821:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103825:	3c 04                	cmp    $0x4,%al
80103827:	74 07                	je     80103830 <mpconfig+0x7c>
    return 0;
80103829:	b8 00 00 00 00       	mov    $0x0,%eax
8010382e:	eb 2f                	jmp    8010385f <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80103830:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103833:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103837:	0f b7 c0             	movzwl %ax,%eax
8010383a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010383e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103841:	89 04 24             	mov    %eax,(%esp)
80103844:	e8 04 fe ff ff       	call   8010364d <sum>
80103849:	84 c0                	test   %al,%al
8010384b:	74 07                	je     80103854 <mpconfig+0xa0>
    return 0;
8010384d:	b8 00 00 00 00       	mov    $0x0,%eax
80103852:	eb 0b                	jmp    8010385f <mpconfig+0xab>
  *pmp = mp;
80103854:	8b 45 08             	mov    0x8(%ebp),%eax
80103857:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010385a:	89 10                	mov    %edx,(%eax)
  return conf;
8010385c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010385f:	c9                   	leave  
80103860:	c3                   	ret    

80103861 <mpinit>:

void
mpinit(void)
{
80103861:	55                   	push   %ebp
80103862:	89 e5                	mov    %esp,%ebp
80103864:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103867:	c7 05 44 c6 10 80 20 	movl   $0x80110920,0x8010c644
8010386e:	09 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103871:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103874:	89 04 24             	mov    %eax,(%esp)
80103877:	e8 38 ff ff ff       	call   801037b4 <mpconfig>
8010387c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010387f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103883:	75 05                	jne    8010388a <mpinit+0x29>
    return;
80103885:	e9 9c 01 00 00       	jmp    80103a26 <mpinit+0x1c5>
  ismp = 1;
8010388a:	c7 05 04 09 11 80 01 	movl   $0x1,0x80110904
80103891:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103894:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103897:	8b 40 24             	mov    0x24(%eax),%eax
8010389a:	a3 7c 08 11 80       	mov    %eax,0x8011087c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
8010389f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038a2:	83 c0 2c             	add    $0x2c,%eax
801038a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801038a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038ab:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801038af:	0f b7 d0             	movzwl %ax,%edx
801038b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038b5:	01 d0                	add    %edx,%eax
801038b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
801038ba:	e9 f4 00 00 00       	jmp    801039b3 <mpinit+0x152>
    switch(*p){
801038bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038c2:	0f b6 00             	movzbl (%eax),%eax
801038c5:	0f b6 c0             	movzbl %al,%eax
801038c8:	83 f8 04             	cmp    $0x4,%eax
801038cb:	0f 87 bf 00 00 00    	ja     80103990 <mpinit+0x12f>
801038d1:	8b 04 85 88 8c 10 80 	mov    -0x7fef7378(,%eax,4),%eax
801038d8:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
801038da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038dd:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
801038e0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801038e3:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801038e7:	0f b6 d0             	movzbl %al,%edx
801038ea:	a1 00 0f 11 80       	mov    0x80110f00,%eax
801038ef:	39 c2                	cmp    %eax,%edx
801038f1:	74 2d                	je     80103920 <mpinit+0xbf>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
801038f3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801038f6:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801038fa:	0f b6 d0             	movzbl %al,%edx
801038fd:	a1 00 0f 11 80       	mov    0x80110f00,%eax
80103902:	89 54 24 08          	mov    %edx,0x8(%esp)
80103906:	89 44 24 04          	mov    %eax,0x4(%esp)
8010390a:	c7 04 24 4a 8c 10 80 	movl   $0x80108c4a,(%esp)
80103911:	e8 8a ca ff ff       	call   801003a0 <cprintf>
        ismp = 0;
80103916:	c7 05 04 09 11 80 00 	movl   $0x0,0x80110904
8010391d:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103920:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103923:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103927:	0f b6 c0             	movzbl %al,%eax
8010392a:	83 e0 02             	and    $0x2,%eax
8010392d:	85 c0                	test   %eax,%eax
8010392f:	74 15                	je     80103946 <mpinit+0xe5>
        bcpu = &cpus[ncpu];
80103931:	a1 00 0f 11 80       	mov    0x80110f00,%eax
80103936:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010393c:	05 20 09 11 80       	add    $0x80110920,%eax
80103941:	a3 44 c6 10 80       	mov    %eax,0x8010c644
      cpus[ncpu].id = ncpu;
80103946:	8b 15 00 0f 11 80    	mov    0x80110f00,%edx
8010394c:	a1 00 0f 11 80       	mov    0x80110f00,%eax
80103951:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80103957:	81 c2 20 09 11 80    	add    $0x80110920,%edx
8010395d:	88 02                	mov    %al,(%edx)
      ncpu++;
8010395f:	a1 00 0f 11 80       	mov    0x80110f00,%eax
80103964:	83 c0 01             	add    $0x1,%eax
80103967:	a3 00 0f 11 80       	mov    %eax,0x80110f00
      p += sizeof(struct mpproc);
8010396c:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103970:	eb 41                	jmp    801039b3 <mpinit+0x152>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103972:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103975:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103978:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010397b:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010397f:	a2 00 09 11 80       	mov    %al,0x80110900
      p += sizeof(struct mpioapic);
80103984:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103988:	eb 29                	jmp    801039b3 <mpinit+0x152>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
8010398a:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
8010398e:	eb 23                	jmp    801039b3 <mpinit+0x152>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103990:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103993:	0f b6 00             	movzbl (%eax),%eax
80103996:	0f b6 c0             	movzbl %al,%eax
80103999:	89 44 24 04          	mov    %eax,0x4(%esp)
8010399d:	c7 04 24 68 8c 10 80 	movl   $0x80108c68,(%esp)
801039a4:	e8 f7 c9 ff ff       	call   801003a0 <cprintf>
      ismp = 0;
801039a9:	c7 05 04 09 11 80 00 	movl   $0x0,0x80110904
801039b0:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801039b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039b6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801039b9:	0f 82 00 ff ff ff    	jb     801038bf <mpinit+0x5e>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
801039bf:	a1 04 09 11 80       	mov    0x80110904,%eax
801039c4:	85 c0                	test   %eax,%eax
801039c6:	75 1d                	jne    801039e5 <mpinit+0x184>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
801039c8:	c7 05 00 0f 11 80 01 	movl   $0x1,0x80110f00
801039cf:	00 00 00 
    lapic = 0;
801039d2:	c7 05 7c 08 11 80 00 	movl   $0x0,0x8011087c
801039d9:	00 00 00 
    ioapicid = 0;
801039dc:	c6 05 00 09 11 80 00 	movb   $0x0,0x80110900
    return;
801039e3:	eb 41                	jmp    80103a26 <mpinit+0x1c5>
  }

  if(mp->imcrp){
801039e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801039e8:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801039ec:	84 c0                	test   %al,%al
801039ee:	74 36                	je     80103a26 <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
801039f0:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
801039f7:	00 
801039f8:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
801039ff:	e8 0d fc ff ff       	call   80103611 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103a04:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103a0b:	e8 e4 fb ff ff       	call   801035f4 <inb>
80103a10:	83 c8 01             	or     $0x1,%eax
80103a13:	0f b6 c0             	movzbl %al,%eax
80103a16:	89 44 24 04          	mov    %eax,0x4(%esp)
80103a1a:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103a21:	e8 eb fb ff ff       	call   80103611 <outb>
  }
}
80103a26:	c9                   	leave  
80103a27:	c3                   	ret    

80103a28 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103a28:	55                   	push   %ebp
80103a29:	89 e5                	mov    %esp,%ebp
80103a2b:	83 ec 08             	sub    $0x8,%esp
80103a2e:	8b 55 08             	mov    0x8(%ebp),%edx
80103a31:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a34:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103a38:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103a3b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103a3f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103a43:	ee                   	out    %al,(%dx)
}
80103a44:	c9                   	leave  
80103a45:	c3                   	ret    

80103a46 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103a46:	55                   	push   %ebp
80103a47:	89 e5                	mov    %esp,%ebp
80103a49:	83 ec 0c             	sub    $0xc,%esp
80103a4c:	8b 45 08             	mov    0x8(%ebp),%eax
80103a4f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103a53:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103a57:	66 a3 00 c0 10 80    	mov    %ax,0x8010c000
  outb(IO_PIC1+1, mask);
80103a5d:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103a61:	0f b6 c0             	movzbl %al,%eax
80103a64:	89 44 24 04          	mov    %eax,0x4(%esp)
80103a68:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103a6f:	e8 b4 ff ff ff       	call   80103a28 <outb>
  outb(IO_PIC2+1, mask >> 8);
80103a74:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103a78:	66 c1 e8 08          	shr    $0x8,%ax
80103a7c:	0f b6 c0             	movzbl %al,%eax
80103a7f:	89 44 24 04          	mov    %eax,0x4(%esp)
80103a83:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103a8a:	e8 99 ff ff ff       	call   80103a28 <outb>
}
80103a8f:	c9                   	leave  
80103a90:	c3                   	ret    

80103a91 <picenable>:

void
picenable(int irq)
{
80103a91:	55                   	push   %ebp
80103a92:	89 e5                	mov    %esp,%ebp
80103a94:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103a97:	8b 45 08             	mov    0x8(%ebp),%eax
80103a9a:	ba 01 00 00 00       	mov    $0x1,%edx
80103a9f:	89 c1                	mov    %eax,%ecx
80103aa1:	d3 e2                	shl    %cl,%edx
80103aa3:	89 d0                	mov    %edx,%eax
80103aa5:	f7 d0                	not    %eax
80103aa7:	89 c2                	mov    %eax,%edx
80103aa9:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103ab0:	21 d0                	and    %edx,%eax
80103ab2:	0f b7 c0             	movzwl %ax,%eax
80103ab5:	89 04 24             	mov    %eax,(%esp)
80103ab8:	e8 89 ff ff ff       	call   80103a46 <picsetmask>
}
80103abd:	c9                   	leave  
80103abe:	c3                   	ret    

80103abf <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103abf:	55                   	push   %ebp
80103ac0:	89 e5                	mov    %esp,%ebp
80103ac2:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103ac5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103acc:	00 
80103acd:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103ad4:	e8 4f ff ff ff       	call   80103a28 <outb>
  outb(IO_PIC2+1, 0xFF);
80103ad9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103ae0:	00 
80103ae1:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103ae8:	e8 3b ff ff ff       	call   80103a28 <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103aed:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103af4:	00 
80103af5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103afc:	e8 27 ff ff ff       	call   80103a28 <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103b01:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103b08:	00 
80103b09:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103b10:	e8 13 ff ff ff       	call   80103a28 <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103b15:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103b1c:	00 
80103b1d:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103b24:	e8 ff fe ff ff       	call   80103a28 <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103b29:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103b30:	00 
80103b31:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103b38:	e8 eb fe ff ff       	call   80103a28 <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103b3d:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103b44:	00 
80103b45:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103b4c:	e8 d7 fe ff ff       	call   80103a28 <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103b51:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80103b58:	00 
80103b59:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103b60:	e8 c3 fe ff ff       	call   80103a28 <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103b65:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80103b6c:	00 
80103b6d:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103b74:	e8 af fe ff ff       	call   80103a28 <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103b79:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103b80:	00 
80103b81:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103b88:	e8 9b fe ff ff       	call   80103a28 <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103b8d:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103b94:	00 
80103b95:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103b9c:	e8 87 fe ff ff       	call   80103a28 <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103ba1:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103ba8:	00 
80103ba9:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103bb0:	e8 73 fe ff ff       	call   80103a28 <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80103bb5:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103bbc:	00 
80103bbd:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103bc4:	e8 5f fe ff ff       	call   80103a28 <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80103bc9:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103bd0:	00 
80103bd1:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103bd8:	e8 4b fe ff ff       	call   80103a28 <outb>

  if(irqmask != 0xFFFF)
80103bdd:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103be4:	66 83 f8 ff          	cmp    $0xffff,%ax
80103be8:	74 12                	je     80103bfc <picinit+0x13d>
    picsetmask(irqmask);
80103bea:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103bf1:	0f b7 c0             	movzwl %ax,%eax
80103bf4:	89 04 24             	mov    %eax,(%esp)
80103bf7:	e8 4a fe ff ff       	call   80103a46 <picsetmask>
}
80103bfc:	c9                   	leave  
80103bfd:	c3                   	ret    

80103bfe <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103bfe:	55                   	push   %ebp
80103bff:	89 e5                	mov    %esp,%ebp
80103c01:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103c04:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103c0b:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c0e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103c14:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c17:	8b 10                	mov    (%eax),%edx
80103c19:	8b 45 08             	mov    0x8(%ebp),%eax
80103c1c:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103c1e:	e8 22 d3 ff ff       	call   80100f45 <filealloc>
80103c23:	8b 55 08             	mov    0x8(%ebp),%edx
80103c26:	89 02                	mov    %eax,(%edx)
80103c28:	8b 45 08             	mov    0x8(%ebp),%eax
80103c2b:	8b 00                	mov    (%eax),%eax
80103c2d:	85 c0                	test   %eax,%eax
80103c2f:	0f 84 c8 00 00 00    	je     80103cfd <pipealloc+0xff>
80103c35:	e8 0b d3 ff ff       	call   80100f45 <filealloc>
80103c3a:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c3d:	89 02                	mov    %eax,(%edx)
80103c3f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c42:	8b 00                	mov    (%eax),%eax
80103c44:	85 c0                	test   %eax,%eax
80103c46:	0f 84 b1 00 00 00    	je     80103cfd <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103c4c:	e8 b0 ee ff ff       	call   80102b01 <kalloc>
80103c51:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c54:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103c58:	75 05                	jne    80103c5f <pipealloc+0x61>
    goto bad;
80103c5a:	e9 9e 00 00 00       	jmp    80103cfd <pipealloc+0xff>
  p->readopen = 1;
80103c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c62:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103c69:	00 00 00 
  p->writeopen = 1;
80103c6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c6f:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103c76:	00 00 00 
  p->nwrite = 0;
80103c79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c7c:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103c83:	00 00 00 
  p->nread = 0;
80103c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c89:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103c90:	00 00 00 
  initlock(&p->lock, "pipe");
80103c93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c96:	c7 44 24 04 9c 8c 10 	movl   $0x80108c9c,0x4(%esp)
80103c9d:	80 
80103c9e:	89 04 24             	mov    %eax,(%esp)
80103ca1:	e8 b3 12 00 00       	call   80104f59 <initlock>
  (*f0)->type = FD_PIPE;
80103ca6:	8b 45 08             	mov    0x8(%ebp),%eax
80103ca9:	8b 00                	mov    (%eax),%eax
80103cab:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103cb1:	8b 45 08             	mov    0x8(%ebp),%eax
80103cb4:	8b 00                	mov    (%eax),%eax
80103cb6:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103cba:	8b 45 08             	mov    0x8(%ebp),%eax
80103cbd:	8b 00                	mov    (%eax),%eax
80103cbf:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103cc3:	8b 45 08             	mov    0x8(%ebp),%eax
80103cc6:	8b 00                	mov    (%eax),%eax
80103cc8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ccb:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103cce:	8b 45 0c             	mov    0xc(%ebp),%eax
80103cd1:	8b 00                	mov    (%eax),%eax
80103cd3:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103cd9:	8b 45 0c             	mov    0xc(%ebp),%eax
80103cdc:	8b 00                	mov    (%eax),%eax
80103cde:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103ce2:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ce5:	8b 00                	mov    (%eax),%eax
80103ce7:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103ceb:	8b 45 0c             	mov    0xc(%ebp),%eax
80103cee:	8b 00                	mov    (%eax),%eax
80103cf0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cf3:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103cf6:	b8 00 00 00 00       	mov    $0x0,%eax
80103cfb:	eb 42                	jmp    80103d3f <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
80103cfd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d01:	74 0b                	je     80103d0e <pipealloc+0x110>
    kfree((char*)p);
80103d03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d06:	89 04 24             	mov    %eax,(%esp)
80103d09:	e8 5a ed ff ff       	call   80102a68 <kfree>
  if(*f0)
80103d0e:	8b 45 08             	mov    0x8(%ebp),%eax
80103d11:	8b 00                	mov    (%eax),%eax
80103d13:	85 c0                	test   %eax,%eax
80103d15:	74 0d                	je     80103d24 <pipealloc+0x126>
    fileclose(*f0);
80103d17:	8b 45 08             	mov    0x8(%ebp),%eax
80103d1a:	8b 00                	mov    (%eax),%eax
80103d1c:	89 04 24             	mov    %eax,(%esp)
80103d1f:	e8 c9 d2 ff ff       	call   80100fed <fileclose>
  if(*f1)
80103d24:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d27:	8b 00                	mov    (%eax),%eax
80103d29:	85 c0                	test   %eax,%eax
80103d2b:	74 0d                	je     80103d3a <pipealloc+0x13c>
    fileclose(*f1);
80103d2d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d30:	8b 00                	mov    (%eax),%eax
80103d32:	89 04 24             	mov    %eax,(%esp)
80103d35:	e8 b3 d2 ff ff       	call   80100fed <fileclose>
  return -1;
80103d3a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103d3f:	c9                   	leave  
80103d40:	c3                   	ret    

80103d41 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103d41:	55                   	push   %ebp
80103d42:	89 e5                	mov    %esp,%ebp
80103d44:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80103d47:	8b 45 08             	mov    0x8(%ebp),%eax
80103d4a:	89 04 24             	mov    %eax,(%esp)
80103d4d:	e8 28 12 00 00       	call   80104f7a <acquire>
  if(writable){
80103d52:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103d56:	74 1f                	je     80103d77 <pipeclose+0x36>
    p->writeopen = 0;
80103d58:	8b 45 08             	mov    0x8(%ebp),%eax
80103d5b:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103d62:	00 00 00 
    wakeup(&p->nread);
80103d65:	8b 45 08             	mov    0x8(%ebp),%eax
80103d68:	05 34 02 00 00       	add    $0x234,%eax
80103d6d:	89 04 24             	mov    %eax,(%esp)
80103d70:	e8 4c 0d 00 00       	call   80104ac1 <wakeup>
80103d75:	eb 1d                	jmp    80103d94 <pipeclose+0x53>
  } else {
    p->readopen = 0;
80103d77:	8b 45 08             	mov    0x8(%ebp),%eax
80103d7a:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103d81:	00 00 00 
    wakeup(&p->nwrite);
80103d84:	8b 45 08             	mov    0x8(%ebp),%eax
80103d87:	05 38 02 00 00       	add    $0x238,%eax
80103d8c:	89 04 24             	mov    %eax,(%esp)
80103d8f:	e8 2d 0d 00 00       	call   80104ac1 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103d94:	8b 45 08             	mov    0x8(%ebp),%eax
80103d97:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103d9d:	85 c0                	test   %eax,%eax
80103d9f:	75 25                	jne    80103dc6 <pipeclose+0x85>
80103da1:	8b 45 08             	mov    0x8(%ebp),%eax
80103da4:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103daa:	85 c0                	test   %eax,%eax
80103dac:	75 18                	jne    80103dc6 <pipeclose+0x85>
    release(&p->lock);
80103dae:	8b 45 08             	mov    0x8(%ebp),%eax
80103db1:	89 04 24             	mov    %eax,(%esp)
80103db4:	e8 23 12 00 00       	call   80104fdc <release>
    kfree((char*)p);
80103db9:	8b 45 08             	mov    0x8(%ebp),%eax
80103dbc:	89 04 24             	mov    %eax,(%esp)
80103dbf:	e8 a4 ec ff ff       	call   80102a68 <kfree>
80103dc4:	eb 0b                	jmp    80103dd1 <pipeclose+0x90>
  } else
    release(&p->lock);
80103dc6:	8b 45 08             	mov    0x8(%ebp),%eax
80103dc9:	89 04 24             	mov    %eax,(%esp)
80103dcc:	e8 0b 12 00 00       	call   80104fdc <release>
}
80103dd1:	c9                   	leave  
80103dd2:	c3                   	ret    

80103dd3 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103dd3:	55                   	push   %ebp
80103dd4:	89 e5                	mov    %esp,%ebp
80103dd6:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
80103dd9:	8b 45 08             	mov    0x8(%ebp),%eax
80103ddc:	89 04 24             	mov    %eax,(%esp)
80103ddf:	e8 96 11 00 00       	call   80104f7a <acquire>
  for(i = 0; i < n; i++){
80103de4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103deb:	e9 a6 00 00 00       	jmp    80103e96 <pipewrite+0xc3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103df0:	eb 57                	jmp    80103e49 <pipewrite+0x76>
      if(p->readopen == 0 || proc->killed){
80103df2:	8b 45 08             	mov    0x8(%ebp),%eax
80103df5:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103dfb:	85 c0                	test   %eax,%eax
80103dfd:	74 0d                	je     80103e0c <pipewrite+0x39>
80103dff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103e05:	8b 40 24             	mov    0x24(%eax),%eax
80103e08:	85 c0                	test   %eax,%eax
80103e0a:	74 15                	je     80103e21 <pipewrite+0x4e>
        release(&p->lock);
80103e0c:	8b 45 08             	mov    0x8(%ebp),%eax
80103e0f:	89 04 24             	mov    %eax,(%esp)
80103e12:	e8 c5 11 00 00       	call   80104fdc <release>
        return -1;
80103e17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e1c:	e9 9f 00 00 00       	jmp    80103ec0 <pipewrite+0xed>
      }
      wakeup(&p->nread);
80103e21:	8b 45 08             	mov    0x8(%ebp),%eax
80103e24:	05 34 02 00 00       	add    $0x234,%eax
80103e29:	89 04 24             	mov    %eax,(%esp)
80103e2c:	e8 90 0c 00 00       	call   80104ac1 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103e31:	8b 45 08             	mov    0x8(%ebp),%eax
80103e34:	8b 55 08             	mov    0x8(%ebp),%edx
80103e37:	81 c2 38 02 00 00    	add    $0x238,%edx
80103e3d:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e41:	89 14 24             	mov    %edx,(%esp)
80103e44:	e8 9f 0b 00 00       	call   801049e8 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103e49:	8b 45 08             	mov    0x8(%ebp),%eax
80103e4c:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80103e52:	8b 45 08             	mov    0x8(%ebp),%eax
80103e55:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103e5b:	05 00 02 00 00       	add    $0x200,%eax
80103e60:	39 c2                	cmp    %eax,%edx
80103e62:	74 8e                	je     80103df2 <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103e64:	8b 45 08             	mov    0x8(%ebp),%eax
80103e67:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103e6d:	8d 48 01             	lea    0x1(%eax),%ecx
80103e70:	8b 55 08             	mov    0x8(%ebp),%edx
80103e73:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103e79:	25 ff 01 00 00       	and    $0x1ff,%eax
80103e7e:	89 c1                	mov    %eax,%ecx
80103e80:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e83:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e86:	01 d0                	add    %edx,%eax
80103e88:	0f b6 10             	movzbl (%eax),%edx
80103e8b:	8b 45 08             	mov    0x8(%ebp),%eax
80103e8e:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80103e92:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103e96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e99:	3b 45 10             	cmp    0x10(%ebp),%eax
80103e9c:	0f 8c 4e ff ff ff    	jl     80103df0 <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103ea2:	8b 45 08             	mov    0x8(%ebp),%eax
80103ea5:	05 34 02 00 00       	add    $0x234,%eax
80103eaa:	89 04 24             	mov    %eax,(%esp)
80103ead:	e8 0f 0c 00 00       	call   80104ac1 <wakeup>
  release(&p->lock);
80103eb2:	8b 45 08             	mov    0x8(%ebp),%eax
80103eb5:	89 04 24             	mov    %eax,(%esp)
80103eb8:	e8 1f 11 00 00       	call   80104fdc <release>
  return n;
80103ebd:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103ec0:	c9                   	leave  
80103ec1:	c3                   	ret    

80103ec2 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103ec2:	55                   	push   %ebp
80103ec3:	89 e5                	mov    %esp,%ebp
80103ec5:	53                   	push   %ebx
80103ec6:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80103ec9:	8b 45 08             	mov    0x8(%ebp),%eax
80103ecc:	89 04 24             	mov    %eax,(%esp)
80103ecf:	e8 a6 10 00 00       	call   80104f7a <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103ed4:	eb 3a                	jmp    80103f10 <piperead+0x4e>
    if(proc->killed){
80103ed6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103edc:	8b 40 24             	mov    0x24(%eax),%eax
80103edf:	85 c0                	test   %eax,%eax
80103ee1:	74 15                	je     80103ef8 <piperead+0x36>
      release(&p->lock);
80103ee3:	8b 45 08             	mov    0x8(%ebp),%eax
80103ee6:	89 04 24             	mov    %eax,(%esp)
80103ee9:	e8 ee 10 00 00       	call   80104fdc <release>
      return -1;
80103eee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ef3:	e9 b5 00 00 00       	jmp    80103fad <piperead+0xeb>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103ef8:	8b 45 08             	mov    0x8(%ebp),%eax
80103efb:	8b 55 08             	mov    0x8(%ebp),%edx
80103efe:	81 c2 34 02 00 00    	add    $0x234,%edx
80103f04:	89 44 24 04          	mov    %eax,0x4(%esp)
80103f08:	89 14 24             	mov    %edx,(%esp)
80103f0b:	e8 d8 0a 00 00       	call   801049e8 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103f10:	8b 45 08             	mov    0x8(%ebp),%eax
80103f13:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103f19:	8b 45 08             	mov    0x8(%ebp),%eax
80103f1c:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103f22:	39 c2                	cmp    %eax,%edx
80103f24:	75 0d                	jne    80103f33 <piperead+0x71>
80103f26:	8b 45 08             	mov    0x8(%ebp),%eax
80103f29:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103f2f:	85 c0                	test   %eax,%eax
80103f31:	75 a3                	jne    80103ed6 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103f33:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103f3a:	eb 4b                	jmp    80103f87 <piperead+0xc5>
    if(p->nread == p->nwrite)
80103f3c:	8b 45 08             	mov    0x8(%ebp),%eax
80103f3f:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103f45:	8b 45 08             	mov    0x8(%ebp),%eax
80103f48:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103f4e:	39 c2                	cmp    %eax,%edx
80103f50:	75 02                	jne    80103f54 <piperead+0x92>
      break;
80103f52:	eb 3b                	jmp    80103f8f <piperead+0xcd>
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103f54:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f57:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f5a:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80103f5d:	8b 45 08             	mov    0x8(%ebp),%eax
80103f60:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103f66:	8d 48 01             	lea    0x1(%eax),%ecx
80103f69:	8b 55 08             	mov    0x8(%ebp),%edx
80103f6c:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103f72:	25 ff 01 00 00       	and    $0x1ff,%eax
80103f77:	89 c2                	mov    %eax,%edx
80103f79:	8b 45 08             	mov    0x8(%ebp),%eax
80103f7c:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
80103f81:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103f83:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103f87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f8a:	3b 45 10             	cmp    0x10(%ebp),%eax
80103f8d:	7c ad                	jl     80103f3c <piperead+0x7a>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103f8f:	8b 45 08             	mov    0x8(%ebp),%eax
80103f92:	05 38 02 00 00       	add    $0x238,%eax
80103f97:	89 04 24             	mov    %eax,(%esp)
80103f9a:	e8 22 0b 00 00       	call   80104ac1 <wakeup>
  release(&p->lock);
80103f9f:	8b 45 08             	mov    0x8(%ebp),%eax
80103fa2:	89 04 24             	mov    %eax,(%esp)
80103fa5:	e8 32 10 00 00       	call   80104fdc <release>
  return i;
80103faa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103fad:	83 c4 24             	add    $0x24,%esp
80103fb0:	5b                   	pop    %ebx
80103fb1:	5d                   	pop    %ebp
80103fb2:	c3                   	ret    

80103fb3 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80103fb3:	55                   	push   %ebp
80103fb4:	89 e5                	mov    %esp,%ebp
80103fb6:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103fb9:	9c                   	pushf  
80103fba:	58                   	pop    %eax
80103fbb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103fbe:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103fc1:	c9                   	leave  
80103fc2:	c3                   	ret    

80103fc3 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80103fc3:	55                   	push   %ebp
80103fc4:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80103fc6:	fb                   	sti    
}
80103fc7:	5d                   	pop    %ebp
80103fc8:	c3                   	ret    

80103fc9 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80103fc9:	55                   	push   %ebp
80103fca:	89 e5                	mov    %esp,%ebp
80103fcc:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80103fcf:	c7 44 24 04 a4 8c 10 	movl   $0x80108ca4,0x4(%esp)
80103fd6:	80 
80103fd7:	c7 04 24 20 0f 11 80 	movl   $0x80110f20,(%esp)
80103fde:	e8 76 0f 00 00       	call   80104f59 <initlock>
}
80103fe3:	c9                   	leave  
80103fe4:	c3                   	ret    

80103fe5 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103fe5:	55                   	push   %ebp
80103fe6:	89 e5                	mov    %esp,%ebp
80103fe8:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103feb:	c7 04 24 20 0f 11 80 	movl   $0x80110f20,(%esp)
80103ff2:	e8 83 0f 00 00       	call   80104f7a <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103ff7:	c7 45 f4 54 0f 11 80 	movl   $0x80110f54,-0xc(%ebp)
80103ffe:	eb 50                	jmp    80104050 <allocproc+0x6b>
    if(p->state == UNUSED)
80104000:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104003:	8b 40 0c             	mov    0xc(%eax),%eax
80104006:	85 c0                	test   %eax,%eax
80104008:	75 42                	jne    8010404c <allocproc+0x67>
      goto found;
8010400a:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
8010400b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010400e:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104015:	a1 04 c0 10 80       	mov    0x8010c004,%eax
8010401a:	8d 50 01             	lea    0x1(%eax),%edx
8010401d:	89 15 04 c0 10 80    	mov    %edx,0x8010c004
80104023:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104026:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
80104029:	c7 04 24 20 0f 11 80 	movl   $0x80110f20,(%esp)
80104030:	e8 a7 0f 00 00       	call   80104fdc <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104035:	e8 c7 ea ff ff       	call   80102b01 <kalloc>
8010403a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010403d:	89 42 08             	mov    %eax,0x8(%edx)
80104040:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104043:	8b 40 08             	mov    0x8(%eax),%eax
80104046:	85 c0                	test   %eax,%eax
80104048:	75 33                	jne    8010407d <allocproc+0x98>
8010404a:	eb 20                	jmp    8010406c <allocproc+0x87>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010404c:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104050:	81 7d f4 54 2e 11 80 	cmpl   $0x80112e54,-0xc(%ebp)
80104057:	72 a7                	jb     80104000 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
80104059:	c7 04 24 20 0f 11 80 	movl   $0x80110f20,(%esp)
80104060:	e8 77 0f 00 00       	call   80104fdc <release>
  return 0;
80104065:	b8 00 00 00 00       	mov    $0x0,%eax
8010406a:	eb 76                	jmp    801040e2 <allocproc+0xfd>
  p->pid = nextpid++;
  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
8010406c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010406f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104076:	b8 00 00 00 00       	mov    $0x0,%eax
8010407b:	eb 65                	jmp    801040e2 <allocproc+0xfd>
  }
  sp = p->kstack + KSTACKSIZE;
8010407d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104080:	8b 40 08             	mov    0x8(%eax),%eax
80104083:	05 00 10 00 00       	add    $0x1000,%eax
80104088:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010408b:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
8010408f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104092:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104095:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104098:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
8010409c:	ba 1e 66 10 80       	mov    $0x8010661e,%edx
801040a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801040a4:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801040a6:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
801040aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040ad:	8b 55 f0             	mov    -0x10(%ebp),%edx
801040b0:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801040b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040b6:	8b 40 1c             	mov    0x1c(%eax),%eax
801040b9:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801040c0:	00 
801040c1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801040c8:	00 
801040c9:	89 04 24             	mov    %eax,(%esp)
801040cc:	e8 fd 10 00 00       	call   801051ce <memset>
  p->context->eip = (uint)forkret;
801040d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040d4:	8b 40 1c             	mov    0x1c(%eax),%eax
801040d7:	ba bc 49 10 80       	mov    $0x801049bc,%edx
801040dc:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
801040df:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801040e2:	c9                   	leave  
801040e3:	c3                   	ret    

801040e4 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801040e4:	55                   	push   %ebp
801040e5:	89 e5                	mov    %esp,%ebp
801040e7:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
801040ea:	e8 f6 fe ff ff       	call   80103fe5 <allocproc>
801040ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
801040f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040f5:	a3 48 c6 10 80       	mov    %eax,0x8010c648
  if((p->pgdir = setupkvm(kalloc)) == 0)
801040fa:	c7 04 24 01 2b 10 80 	movl   $0x80102b01,(%esp)
80104101:	e8 4c 3c 00 00       	call   80107d52 <setupkvm>
80104106:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104109:	89 42 04             	mov    %eax,0x4(%edx)
8010410c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010410f:	8b 40 04             	mov    0x4(%eax),%eax
80104112:	85 c0                	test   %eax,%eax
80104114:	75 0c                	jne    80104122 <userinit+0x3e>
    panic("userinit: out of memory?");
80104116:	c7 04 24 ab 8c 10 80 	movl   $0x80108cab,(%esp)
8010411d:	e8 18 c4 ff ff       	call   8010053a <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104122:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104127:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010412a:	8b 40 04             	mov    0x4(%eax),%eax
8010412d:	89 54 24 08          	mov    %edx,0x8(%esp)
80104131:	c7 44 24 04 e0 c4 10 	movl   $0x8010c4e0,0x4(%esp)
80104138:	80 
80104139:	89 04 24             	mov    %eax,(%esp)
8010413c:	e8 69 3e 00 00       	call   80107faa <inituvm>
  p->sz = PGSIZE;
80104141:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104144:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
8010414a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010414d:	8b 40 18             	mov    0x18(%eax),%eax
80104150:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
80104157:	00 
80104158:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010415f:	00 
80104160:	89 04 24             	mov    %eax,(%esp)
80104163:	e8 66 10 00 00       	call   801051ce <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104168:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010416b:	8b 40 18             	mov    0x18(%eax),%eax
8010416e:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104174:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104177:	8b 40 18             	mov    0x18(%eax),%eax
8010417a:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104180:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104183:	8b 40 18             	mov    0x18(%eax),%eax
80104186:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104189:	8b 52 18             	mov    0x18(%edx),%edx
8010418c:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104190:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104194:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104197:	8b 40 18             	mov    0x18(%eax),%eax
8010419a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010419d:	8b 52 18             	mov    0x18(%edx),%edx
801041a0:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801041a4:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801041a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041ab:	8b 40 18             	mov    0x18(%eax),%eax
801041ae:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801041b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041b8:	8b 40 18             	mov    0x18(%eax),%eax
801041bb:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801041c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041c5:	8b 40 18             	mov    0x18(%eax),%eax
801041c8:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801041cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041d2:	83 c0 6c             	add    $0x6c,%eax
801041d5:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801041dc:	00 
801041dd:	c7 44 24 04 c4 8c 10 	movl   $0x80108cc4,0x4(%esp)
801041e4:	80 
801041e5:	89 04 24             	mov    %eax,(%esp)
801041e8:	e8 01 12 00 00       	call   801053ee <safestrcpy>
  p->cwd = namei("/");
801041ed:	c7 04 24 cd 8c 10 80 	movl   $0x80108ccd,(%esp)
801041f4:	e8 2c e2 ff ff       	call   80102425 <namei>
801041f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041fc:	89 42 68             	mov    %eax,0x68(%edx)

  p->state = RUNNABLE;
801041ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104202:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
80104209:	c9                   	leave  
8010420a:	c3                   	ret    

8010420b <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
8010420b:	55                   	push   %ebp
8010420c:	89 e5                	mov    %esp,%ebp
8010420e:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
80104211:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104217:	8b 00                	mov    (%eax),%eax
80104219:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
8010421c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104220:	7e 34                	jle    80104256 <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80104222:	8b 55 08             	mov    0x8(%ebp),%edx
80104225:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104228:	01 c2                	add    %eax,%edx
8010422a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104230:	8b 40 04             	mov    0x4(%eax),%eax
80104233:	89 54 24 08          	mov    %edx,0x8(%esp)
80104237:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010423a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010423e:	89 04 24             	mov    %eax,(%esp)
80104241:	e8 f4 3e 00 00       	call   8010813a <allocuvm>
80104246:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104249:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010424d:	75 41                	jne    80104290 <growproc+0x85>
      return -1;
8010424f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104254:	eb 58                	jmp    801042ae <growproc+0xa3>
  } else if(n < 0){
80104256:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010425a:	79 34                	jns    80104290 <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
8010425c:	8b 55 08             	mov    0x8(%ebp),%edx
8010425f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104262:	01 c2                	add    %eax,%edx
80104264:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010426a:	8b 40 04             	mov    0x4(%eax),%eax
8010426d:	89 54 24 08          	mov    %edx,0x8(%esp)
80104271:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104274:	89 54 24 04          	mov    %edx,0x4(%esp)
80104278:	89 04 24             	mov    %eax,(%esp)
8010427b:	e8 94 3f 00 00       	call   80108214 <deallocuvm>
80104280:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104283:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104287:	75 07                	jne    80104290 <growproc+0x85>
      return -1;
80104289:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010428e:	eb 1e                	jmp    801042ae <growproc+0xa3>
  }
  proc->sz = sz;
80104290:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104296:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104299:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
8010429b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042a1:	89 04 24             	mov    %eax,(%esp)
801042a4:	e8 9a 3b 00 00       	call   80107e43 <switchuvm>
  return 0;
801042a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801042ae:	c9                   	leave  
801042af:	c3                   	ret    

801042b0 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
801042b0:	55                   	push   %ebp
801042b1:	89 e5                	mov    %esp,%ebp
801042b3:	57                   	push   %edi
801042b4:	56                   	push   %esi
801042b5:	53                   	push   %ebx
801042b6:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
801042b9:	e8 27 fd ff ff       	call   80103fe5 <allocproc>
801042be:	89 45 e0             	mov    %eax,-0x20(%ebp)
801042c1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801042c5:	75 0a                	jne    801042d1 <fork+0x21>
    return -1;
801042c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042cc:	e9 3a 01 00 00       	jmp    8010440b <fork+0x15b>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
801042d1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042d7:	8b 10                	mov    (%eax),%edx
801042d9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042df:	8b 40 04             	mov    0x4(%eax),%eax
801042e2:	89 54 24 04          	mov    %edx,0x4(%esp)
801042e6:	89 04 24             	mov    %eax,(%esp)
801042e9:	e8 0a 41 00 00       	call   801083f8 <copyuvm>
801042ee:	8b 55 e0             	mov    -0x20(%ebp),%edx
801042f1:	89 42 04             	mov    %eax,0x4(%edx)
801042f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801042f7:	8b 40 04             	mov    0x4(%eax),%eax
801042fa:	85 c0                	test   %eax,%eax
801042fc:	75 2c                	jne    8010432a <fork+0x7a>
    kfree(np->kstack);
801042fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104301:	8b 40 08             	mov    0x8(%eax),%eax
80104304:	89 04 24             	mov    %eax,(%esp)
80104307:	e8 5c e7 ff ff       	call   80102a68 <kfree>
    np->kstack = 0;
8010430c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010430f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104316:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104319:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104320:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104325:	e9 e1 00 00 00       	jmp    8010440b <fork+0x15b>
  }
  np->sz = proc->sz;
8010432a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104330:	8b 10                	mov    (%eax),%edx
80104332:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104335:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104337:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010433e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104341:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104344:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104347:	8b 50 18             	mov    0x18(%eax),%edx
8010434a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104350:	8b 40 18             	mov    0x18(%eax),%eax
80104353:	89 c3                	mov    %eax,%ebx
80104355:	b8 13 00 00 00       	mov    $0x13,%eax
8010435a:	89 d7                	mov    %edx,%edi
8010435c:	89 de                	mov    %ebx,%esi
8010435e:	89 c1                	mov    %eax,%ecx
80104360:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104362:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104365:	8b 40 18             	mov    0x18(%eax),%eax
80104368:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010436f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104376:	eb 3d                	jmp    801043b5 <fork+0x105>
    if(proc->ofile[i])
80104378:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010437e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104381:	83 c2 08             	add    $0x8,%edx
80104384:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104388:	85 c0                	test   %eax,%eax
8010438a:	74 25                	je     801043b1 <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
8010438c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104392:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104395:	83 c2 08             	add    $0x8,%edx
80104398:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010439c:	89 04 24             	mov    %eax,(%esp)
8010439f:	e8 01 cc ff ff       	call   80100fa5 <filedup>
801043a4:	8b 55 e0             	mov    -0x20(%ebp),%edx
801043a7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801043aa:	83 c1 08             	add    $0x8,%ecx
801043ad:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
801043b1:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801043b5:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801043b9:	7e bd                	jle    80104378 <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
801043bb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801043c1:	8b 40 68             	mov    0x68(%eax),%eax
801043c4:	89 04 24             	mov    %eax,(%esp)
801043c7:	e8 7c d4 ff ff       	call   80101848 <idup>
801043cc:	8b 55 e0             	mov    -0x20(%ebp),%edx
801043cf:	89 42 68             	mov    %eax,0x68(%edx)
 
  pid = np->pid;
801043d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043d5:	8b 40 10             	mov    0x10(%eax),%eax
801043d8:	89 45 dc             	mov    %eax,-0x24(%ebp)
  np->state = RUNNABLE;
801043db:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043de:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  safestrcpy(np->name, proc->name, sizeof(proc->name));
801043e5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801043eb:	8d 50 6c             	lea    0x6c(%eax),%edx
801043ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043f1:	83 c0 6c             	add    $0x6c,%eax
801043f4:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801043fb:	00 
801043fc:	89 54 24 04          	mov    %edx,0x4(%esp)
80104400:	89 04 24             	mov    %eax,(%esp)
80104403:	e8 e6 0f 00 00       	call   801053ee <safestrcpy>
  return pid;
80104408:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
8010440b:	83 c4 2c             	add    $0x2c,%esp
8010440e:	5b                   	pop    %ebx
8010440f:	5e                   	pop    %esi
80104410:	5f                   	pop    %edi
80104411:	5d                   	pop    %ebp
80104412:	c3                   	ret    

80104413 <cowfork>:
// Create a new process with COW
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
cowfork(void)
{
80104413:	55                   	push   %ebp
80104414:	89 e5                	mov    %esp,%ebp
80104416:	57                   	push   %edi
80104417:	56                   	push   %esi
80104418:	53                   	push   %ebx
80104419:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
8010441c:	e8 c4 fb ff ff       	call   80103fe5 <allocproc>
80104421:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104424:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104428:	75 0a                	jne    80104434 <cowfork+0x21>
    return -1;
8010442a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010442f:	e9 3a 01 00 00       	jmp    8010456e <cowfork+0x15b>

  // Copy process state from p.
  if((np->pgdir = copyuvm_cow(proc->pgdir, proc->sz)) == 0){ // copyum_cow faz o compartilhamento de paginação
80104434:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010443a:	8b 10                	mov    (%eax),%edx
8010443c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104442:	8b 40 04             	mov    0x4(%eax),%eax
80104445:	89 54 24 04          	mov    %edx,0x4(%esp)
80104449:	89 04 24             	mov    %eax,(%esp)
8010444c:	e8 05 43 00 00       	call   80108756 <copyuvm_cow>
80104451:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104454:	89 42 04             	mov    %eax,0x4(%edx)
80104457:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010445a:	8b 40 04             	mov    0x4(%eax),%eax
8010445d:	85 c0                	test   %eax,%eax
8010445f:	75 2c                	jne    8010448d <cowfork+0x7a>
    kfree(np->kstack);
80104461:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104464:	8b 40 08             	mov    0x8(%eax),%eax
80104467:	89 04 24             	mov    %eax,(%esp)
8010446a:	e8 f9 e5 ff ff       	call   80102a68 <kfree>
    np->kstack = 0;
8010446f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104472:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104479:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010447c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104483:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104488:	e9 e1 00 00 00       	jmp    8010456e <cowfork+0x15b>
  }
  np->sz = proc->sz;
8010448d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104493:	8b 10                	mov    (%eax),%edx
80104495:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104498:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
8010449a:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801044a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801044a4:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
801044a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801044aa:	8b 50 18             	mov    0x18(%eax),%edx
801044ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801044b3:	8b 40 18             	mov    0x18(%eax),%eax
801044b6:	89 c3                	mov    %eax,%ebx
801044b8:	b8 13 00 00 00       	mov    $0x13,%eax
801044bd:	89 d7                	mov    %edx,%edi
801044bf:	89 de                	mov    %ebx,%esi
801044c1:	89 c1                	mov    %eax,%ecx
801044c3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801044c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801044c8:	8b 40 18             	mov    0x18(%eax),%eax
801044cb:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801044d2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801044d9:	eb 3d                	jmp    80104518 <cowfork+0x105>
    if(proc->ofile[i])
801044db:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801044e1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801044e4:	83 c2 08             	add    $0x8,%edx
801044e7:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801044eb:	85 c0                	test   %eax,%eax
801044ed:	74 25                	je     80104514 <cowfork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
801044ef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801044f5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801044f8:	83 c2 08             	add    $0x8,%edx
801044fb:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801044ff:	89 04 24             	mov    %eax,(%esp)
80104502:	e8 9e ca ff ff       	call   80100fa5 <filedup>
80104507:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010450a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010450d:	83 c1 08             	add    $0x8,%ecx
80104510:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104514:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104518:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
8010451c:	7e bd                	jle    801044db <cowfork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
8010451e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104524:	8b 40 68             	mov    0x68(%eax),%eax
80104527:	89 04 24             	mov    %eax,(%esp)
8010452a:	e8 19 d3 ff ff       	call   80101848 <idup>
8010452f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104532:	89 42 68             	mov    %eax,0x68(%edx)
 
  pid = np->pid;
80104535:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104538:	8b 40 10             	mov    0x10(%eax),%eax
8010453b:	89 45 dc             	mov    %eax,-0x24(%ebp)
  np->state = RUNNABLE;
8010453e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104541:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104548:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010454e:	8d 50 6c             	lea    0x6c(%eax),%edx
80104551:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104554:	83 c0 6c             	add    $0x6c,%eax
80104557:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010455e:	00 
8010455f:	89 54 24 04          	mov    %edx,0x4(%esp)
80104563:	89 04 24             	mov    %eax,(%esp)
80104566:	e8 83 0e 00 00       	call   801053ee <safestrcpy>
  return pid;
8010456b:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
8010456e:	83 c4 2c             	add    $0x2c,%esp
80104571:	5b                   	pop    %ebx
80104572:	5e                   	pop    %esi
80104573:	5f                   	pop    %edi
80104574:	5d                   	pop    %ebp
80104575:	c3                   	ret    

80104576 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104576:	55                   	push   %ebp
80104577:	89 e5                	mov    %esp,%ebp
80104579:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
8010457c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104583:	a1 48 c6 10 80       	mov    0x8010c648,%eax
80104588:	39 c2                	cmp    %eax,%edx
8010458a:	75 0c                	jne    80104598 <exit+0x22>
    panic("init exiting");
8010458c:	c7 04 24 cf 8c 10 80 	movl   $0x80108ccf,(%esp)
80104593:	e8 a2 bf ff ff       	call   8010053a <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104598:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010459f:	eb 44                	jmp    801045e5 <exit+0x6f>
    if(proc->ofile[fd]){
801045a1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045a7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801045aa:	83 c2 08             	add    $0x8,%edx
801045ad:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801045b1:	85 c0                	test   %eax,%eax
801045b3:	74 2c                	je     801045e1 <exit+0x6b>
      fileclose(proc->ofile[fd]);
801045b5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045bb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801045be:	83 c2 08             	add    $0x8,%edx
801045c1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801045c5:	89 04 24             	mov    %eax,(%esp)
801045c8:	e8 20 ca ff ff       	call   80100fed <fileclose>
      proc->ofile[fd] = 0;
801045cd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045d3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801045d6:	83 c2 08             	add    $0x8,%edx
801045d9:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801045e0:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801045e1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801045e5:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801045e9:	7e b6                	jle    801045a1 <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }
  
  iput(proc->cwd);
801045eb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045f1:	8b 40 68             	mov    0x68(%eax),%eax
801045f4:	89 04 24             	mov    %eax,(%esp)
801045f7:	e8 31 d4 ff ff       	call   80101a2d <iput>
  proc->cwd = 0;
801045fc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104602:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104609:	c7 04 24 20 0f 11 80 	movl   $0x80110f20,(%esp)
80104610:	e8 65 09 00 00       	call   80104f7a <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104615:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010461b:	8b 40 14             	mov    0x14(%eax),%eax
8010461e:	89 04 24             	mov    %eax,(%esp)
80104621:	e8 5d 04 00 00       	call   80104a83 <wakeup1>
  
  
  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104626:	c7 45 f4 54 0f 11 80 	movl   $0x80110f54,-0xc(%ebp)
8010462d:	eb 38                	jmp    80104667 <exit+0xf1>
    if(p->parent == proc){
8010462f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104632:	8b 50 14             	mov    0x14(%eax),%edx
80104635:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010463b:	39 c2                	cmp    %eax,%edx
8010463d:	75 24                	jne    80104663 <exit+0xed>
      p->parent = initproc;
8010463f:	8b 15 48 c6 10 80    	mov    0x8010c648,%edx
80104645:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104648:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
8010464b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010464e:	8b 40 0c             	mov    0xc(%eax),%eax
80104651:	83 f8 05             	cmp    $0x5,%eax
80104654:	75 0d                	jne    80104663 <exit+0xed>
        wakeup1(initproc);
80104656:	a1 48 c6 10 80       	mov    0x8010c648,%eax
8010465b:	89 04 24             	mov    %eax,(%esp)
8010465e:	e8 20 04 00 00       	call   80104a83 <wakeup1>
  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
  
  
  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104663:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104667:	81 7d f4 54 2e 11 80 	cmpl   $0x80112e54,-0xc(%ebp)
8010466e:	72 bf                	jb     8010462f <exit+0xb9>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104670:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104676:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
8010467d:	e8 56 02 00 00       	call   801048d8 <sched>
  panic("zombie exit");
80104682:	c7 04 24 dc 8c 10 80 	movl   $0x80108cdc,(%esp)
80104689:	e8 ac be ff ff       	call   8010053a <panic>

8010468e <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
8010468e:	55                   	push   %ebp
8010468f:	89 e5                	mov    %esp,%ebp
80104691:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104694:	c7 04 24 20 0f 11 80 	movl   $0x80110f20,(%esp)
8010469b:	e8 da 08 00 00       	call   80104f7a <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
801046a0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801046a7:	c7 45 f4 54 0f 11 80 	movl   $0x80110f54,-0xc(%ebp)
801046ae:	e9 9a 00 00 00       	jmp    8010474d <wait+0xbf>
      if(p->parent != proc)
801046b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046b6:	8b 50 14             	mov    0x14(%eax),%edx
801046b9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046bf:	39 c2                	cmp    %eax,%edx
801046c1:	74 05                	je     801046c8 <wait+0x3a>
        continue;
801046c3:	e9 81 00 00 00       	jmp    80104749 <wait+0xbb>
      havekids = 1;
801046c8:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801046cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d2:	8b 40 0c             	mov    0xc(%eax),%eax
801046d5:	83 f8 05             	cmp    $0x5,%eax
801046d8:	75 6f                	jne    80104749 <wait+0xbb>
        // Found one.
        pid = p->pid;
801046da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046dd:	8b 40 10             	mov    0x10(%eax),%eax
801046e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
801046e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046e6:	8b 40 08             	mov    0x8(%eax),%eax
801046e9:	89 04 24             	mov    %eax,(%esp)
801046ec:	e8 77 e3 ff ff       	call   80102a68 <kfree>
        p->kstack = 0;
801046f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046f4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801046fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046fe:	8b 40 04             	mov    0x4(%eax),%eax
80104701:	89 04 24             	mov    %eax,(%esp)
80104704:	e8 0f 3c 00 00       	call   80108318 <freevm>
        p->state = UNUSED;
80104709:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010470c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104713:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104716:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010471d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104720:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104727:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010472a:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010472e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104731:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104738:	c7 04 24 20 0f 11 80 	movl   $0x80110f20,(%esp)
8010473f:	e8 98 08 00 00       	call   80104fdc <release>
        return pid;
80104744:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104747:	eb 52                	jmp    8010479b <wait+0x10d>

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104749:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010474d:	81 7d f4 54 2e 11 80 	cmpl   $0x80112e54,-0xc(%ebp)
80104754:	0f 82 59 ff ff ff    	jb     801046b3 <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
8010475a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010475e:	74 0d                	je     8010476d <wait+0xdf>
80104760:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104766:	8b 40 24             	mov    0x24(%eax),%eax
80104769:	85 c0                	test   %eax,%eax
8010476b:	74 13                	je     80104780 <wait+0xf2>
      release(&ptable.lock);
8010476d:	c7 04 24 20 0f 11 80 	movl   $0x80110f20,(%esp)
80104774:	e8 63 08 00 00       	call   80104fdc <release>
      return -1;
80104779:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010477e:	eb 1b                	jmp    8010479b <wait+0x10d>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104780:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104786:	c7 44 24 04 20 0f 11 	movl   $0x80110f20,0x4(%esp)
8010478d:	80 
8010478e:	89 04 24             	mov    %eax,(%esp)
80104791:	e8 52 02 00 00       	call   801049e8 <sleep>
  }
80104796:	e9 05 ff ff ff       	jmp    801046a0 <wait+0x12>
}
8010479b:	c9                   	leave  
8010479c:	c3                   	ret    

8010479d <register_handler>:

void
register_handler(sighandler_t sighandler)
{
8010479d:	55                   	push   %ebp
8010479e:	89 e5                	mov    %esp,%ebp
801047a0:	83 ec 28             	sub    $0x28,%esp
  char* addr = uva2ka(proc->pgdir, (char*)proc->tf->esp);
801047a3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047a9:	8b 40 18             	mov    0x18(%eax),%eax
801047ac:	8b 40 44             	mov    0x44(%eax),%eax
801047af:	89 c2                	mov    %eax,%edx
801047b1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047b7:	8b 40 04             	mov    0x4(%eax),%eax
801047ba:	89 54 24 04          	mov    %edx,0x4(%esp)
801047be:	89 04 24             	mov    %eax,(%esp)
801047c1:	e8 0d 41 00 00       	call   801088d3 <uva2ka>
801047c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if ((proc->tf->esp & 0xFFF) == 0)
801047c9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047cf:	8b 40 18             	mov    0x18(%eax),%eax
801047d2:	8b 40 44             	mov    0x44(%eax),%eax
801047d5:	25 ff 0f 00 00       	and    $0xfff,%eax
801047da:	85 c0                	test   %eax,%eax
801047dc:	75 0c                	jne    801047ea <register_handler+0x4d>
    panic("esp_offset == 0");
801047de:	c7 04 24 e8 8c 10 80 	movl   $0x80108ce8,(%esp)
801047e5:	e8 50 bd ff ff       	call   8010053a <panic>

    /* open a new frame */
  *(int*)(addr + ((proc->tf->esp - 4) & 0xFFF))
801047ea:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047f0:	8b 40 18             	mov    0x18(%eax),%eax
801047f3:	8b 40 44             	mov    0x44(%eax),%eax
801047f6:	83 e8 04             	sub    $0x4,%eax
801047f9:	25 ff 0f 00 00       	and    $0xfff,%eax
801047fe:	89 c2                	mov    %eax,%edx
80104800:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104803:	01 c2                	add    %eax,%edx
          = proc->tf->eip;
80104805:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010480b:	8b 40 18             	mov    0x18(%eax),%eax
8010480e:	8b 40 38             	mov    0x38(%eax),%eax
80104811:	89 02                	mov    %eax,(%edx)
  proc->tf->esp -= 4;
80104813:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104819:	8b 40 18             	mov    0x18(%eax),%eax
8010481c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104823:	8b 52 18             	mov    0x18(%edx),%edx
80104826:	8b 52 44             	mov    0x44(%edx),%edx
80104829:	83 ea 04             	sub    $0x4,%edx
8010482c:	89 50 44             	mov    %edx,0x44(%eax)

    /* update eip */
  proc->tf->eip = (uint)sighandler;
8010482f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104835:	8b 40 18             	mov    0x18(%eax),%eax
80104838:	8b 55 08             	mov    0x8(%ebp),%edx
8010483b:	89 50 38             	mov    %edx,0x38(%eax)
}
8010483e:	c9                   	leave  
8010483f:	c3                   	ret    

80104840 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104840:	55                   	push   %ebp
80104841:	89 e5                	mov    %esp,%ebp
80104843:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104846:	e8 78 f7 ff ff       	call   80103fc3 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
8010484b:	c7 04 24 20 0f 11 80 	movl   $0x80110f20,(%esp)
80104852:	e8 23 07 00 00       	call   80104f7a <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104857:	c7 45 f4 54 0f 11 80 	movl   $0x80110f54,-0xc(%ebp)
8010485e:	eb 5e                	jmp    801048be <scheduler+0x7e>
      if(p->state != RUNNABLE)
80104860:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104863:	8b 40 0c             	mov    0xc(%eax),%eax
80104866:	83 f8 03             	cmp    $0x3,%eax
80104869:	74 02                	je     8010486d <scheduler+0x2d>
        continue;
8010486b:	eb 4d                	jmp    801048ba <scheduler+0x7a>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
8010486d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104870:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104876:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104879:	89 04 24             	mov    %eax,(%esp)
8010487c:	e8 c2 35 00 00       	call   80107e43 <switchuvm>
      p->state = RUNNING;
80104881:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104884:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
8010488b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104891:	8b 40 1c             	mov    0x1c(%eax),%eax
80104894:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010489b:	83 c2 04             	add    $0x4,%edx
8010489e:	89 44 24 04          	mov    %eax,0x4(%esp)
801048a2:	89 14 24             	mov    %edx,(%esp)
801048a5:	e8 b5 0b 00 00       	call   8010545f <swtch>
      switchkvm();
801048aa:	e8 77 35 00 00       	call   80107e26 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
801048af:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
801048b6:	00 00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048ba:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801048be:	81 7d f4 54 2e 11 80 	cmpl   $0x80112e54,-0xc(%ebp)
801048c5:	72 99                	jb     80104860 <scheduler+0x20>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
801048c7:	c7 04 24 20 0f 11 80 	movl   $0x80110f20,(%esp)
801048ce:	e8 09 07 00 00       	call   80104fdc <release>

  }
801048d3:	e9 6e ff ff ff       	jmp    80104846 <scheduler+0x6>

801048d8 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
801048d8:	55                   	push   %ebp
801048d9:	89 e5                	mov    %esp,%ebp
801048db:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
801048de:	c7 04 24 20 0f 11 80 	movl   $0x80110f20,(%esp)
801048e5:	e8 ba 07 00 00       	call   801050a4 <holding>
801048ea:	85 c0                	test   %eax,%eax
801048ec:	75 0c                	jne    801048fa <sched+0x22>
    panic("sched ptable.lock");
801048ee:	c7 04 24 f8 8c 10 80 	movl   $0x80108cf8,(%esp)
801048f5:	e8 40 bc ff ff       	call   8010053a <panic>
  if(cpu->ncli != 1)
801048fa:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104900:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104906:	83 f8 01             	cmp    $0x1,%eax
80104909:	74 0c                	je     80104917 <sched+0x3f>
    panic("sched locks");
8010490b:	c7 04 24 0a 8d 10 80 	movl   $0x80108d0a,(%esp)
80104912:	e8 23 bc ff ff       	call   8010053a <panic>
  if(proc->state == RUNNING)
80104917:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010491d:	8b 40 0c             	mov    0xc(%eax),%eax
80104920:	83 f8 04             	cmp    $0x4,%eax
80104923:	75 0c                	jne    80104931 <sched+0x59>
    panic("sched running");
80104925:	c7 04 24 16 8d 10 80 	movl   $0x80108d16,(%esp)
8010492c:	e8 09 bc ff ff       	call   8010053a <panic>
  if(readeflags()&FL_IF)
80104931:	e8 7d f6 ff ff       	call   80103fb3 <readeflags>
80104936:	25 00 02 00 00       	and    $0x200,%eax
8010493b:	85 c0                	test   %eax,%eax
8010493d:	74 0c                	je     8010494b <sched+0x73>
    panic("sched interruptible");
8010493f:	c7 04 24 24 8d 10 80 	movl   $0x80108d24,(%esp)
80104946:	e8 ef bb ff ff       	call   8010053a <panic>
  intena = cpu->intena;
8010494b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104951:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104957:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
8010495a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104960:	8b 40 04             	mov    0x4(%eax),%eax
80104963:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010496a:	83 c2 1c             	add    $0x1c,%edx
8010496d:	89 44 24 04          	mov    %eax,0x4(%esp)
80104971:	89 14 24             	mov    %edx,(%esp)
80104974:	e8 e6 0a 00 00       	call   8010545f <swtch>
  cpu->intena = intena;
80104979:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010497f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104982:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104988:	c9                   	leave  
80104989:	c3                   	ret    

8010498a <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
8010498a:	55                   	push   %ebp
8010498b:	89 e5                	mov    %esp,%ebp
8010498d:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104990:	c7 04 24 20 0f 11 80 	movl   $0x80110f20,(%esp)
80104997:	e8 de 05 00 00       	call   80104f7a <acquire>
  proc->state = RUNNABLE;
8010499c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049a2:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
801049a9:	e8 2a ff ff ff       	call   801048d8 <sched>
  release(&ptable.lock);
801049ae:	c7 04 24 20 0f 11 80 	movl   $0x80110f20,(%esp)
801049b5:	e8 22 06 00 00       	call   80104fdc <release>
}
801049ba:	c9                   	leave  
801049bb:	c3                   	ret    

801049bc <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801049bc:	55                   	push   %ebp
801049bd:	89 e5                	mov    %esp,%ebp
801049bf:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801049c2:	c7 04 24 20 0f 11 80 	movl   $0x80110f20,(%esp)
801049c9:	e8 0e 06 00 00       	call   80104fdc <release>

  if (first) {
801049ce:	a1 08 c0 10 80       	mov    0x8010c008,%eax
801049d3:	85 c0                	test   %eax,%eax
801049d5:	74 0f                	je     801049e6 <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
801049d7:	c7 05 08 c0 10 80 00 	movl   $0x0,0x8010c008
801049de:	00 00 00 
    initlog();
801049e1:	e8 10 e6 ff ff       	call   80102ff6 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
801049e6:	c9                   	leave  
801049e7:	c3                   	ret    

801049e8 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801049e8:	55                   	push   %ebp
801049e9:	89 e5                	mov    %esp,%ebp
801049eb:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
801049ee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049f4:	85 c0                	test   %eax,%eax
801049f6:	75 0c                	jne    80104a04 <sleep+0x1c>
    panic("sleep");
801049f8:	c7 04 24 38 8d 10 80 	movl   $0x80108d38,(%esp)
801049ff:	e8 36 bb ff ff       	call   8010053a <panic>

  if(lk == 0)
80104a04:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104a08:	75 0c                	jne    80104a16 <sleep+0x2e>
    panic("sleep without lk");
80104a0a:	c7 04 24 3e 8d 10 80 	movl   $0x80108d3e,(%esp)
80104a11:	e8 24 bb ff ff       	call   8010053a <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104a16:	81 7d 0c 20 0f 11 80 	cmpl   $0x80110f20,0xc(%ebp)
80104a1d:	74 17                	je     80104a36 <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104a1f:	c7 04 24 20 0f 11 80 	movl   $0x80110f20,(%esp)
80104a26:	e8 4f 05 00 00       	call   80104f7a <acquire>
    release(lk);
80104a2b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a2e:	89 04 24             	mov    %eax,(%esp)
80104a31:	e8 a6 05 00 00       	call   80104fdc <release>
  }

  // Go to sleep.
  proc->chan = chan;
80104a36:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a3c:	8b 55 08             	mov    0x8(%ebp),%edx
80104a3f:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104a42:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a48:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104a4f:	e8 84 fe ff ff       	call   801048d8 <sched>
  
  // Tidy up.
  proc->chan = 0;
80104a54:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a5a:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104a61:	81 7d 0c 20 0f 11 80 	cmpl   $0x80110f20,0xc(%ebp)
80104a68:	74 17                	je     80104a81 <sleep+0x99>
    release(&ptable.lock);
80104a6a:	c7 04 24 20 0f 11 80 	movl   $0x80110f20,(%esp)
80104a71:	e8 66 05 00 00       	call   80104fdc <release>
    acquire(lk);
80104a76:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a79:	89 04 24             	mov    %eax,(%esp)
80104a7c:	e8 f9 04 00 00       	call   80104f7a <acquire>
  }
}
80104a81:	c9                   	leave  
80104a82:	c3                   	ret    

80104a83 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104a83:	55                   	push   %ebp
80104a84:	89 e5                	mov    %esp,%ebp
80104a86:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104a89:	c7 45 fc 54 0f 11 80 	movl   $0x80110f54,-0x4(%ebp)
80104a90:	eb 24                	jmp    80104ab6 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104a92:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a95:	8b 40 0c             	mov    0xc(%eax),%eax
80104a98:	83 f8 02             	cmp    $0x2,%eax
80104a9b:	75 15                	jne    80104ab2 <wakeup1+0x2f>
80104a9d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104aa0:	8b 40 20             	mov    0x20(%eax),%eax
80104aa3:	3b 45 08             	cmp    0x8(%ebp),%eax
80104aa6:	75 0a                	jne    80104ab2 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104aa8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104aab:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104ab2:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
80104ab6:	81 7d fc 54 2e 11 80 	cmpl   $0x80112e54,-0x4(%ebp)
80104abd:	72 d3                	jb     80104a92 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104abf:	c9                   	leave  
80104ac0:	c3                   	ret    

80104ac1 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104ac1:	55                   	push   %ebp
80104ac2:	89 e5                	mov    %esp,%ebp
80104ac4:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104ac7:	c7 04 24 20 0f 11 80 	movl   $0x80110f20,(%esp)
80104ace:	e8 a7 04 00 00       	call   80104f7a <acquire>
  wakeup1(chan);
80104ad3:	8b 45 08             	mov    0x8(%ebp),%eax
80104ad6:	89 04 24             	mov    %eax,(%esp)
80104ad9:	e8 a5 ff ff ff       	call   80104a83 <wakeup1>
  release(&ptable.lock);
80104ade:	c7 04 24 20 0f 11 80 	movl   $0x80110f20,(%esp)
80104ae5:	e8 f2 04 00 00       	call   80104fdc <release>
}
80104aea:	c9                   	leave  
80104aeb:	c3                   	ret    

80104aec <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104aec:	55                   	push   %ebp
80104aed:	89 e5                	mov    %esp,%ebp
80104aef:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104af2:	c7 04 24 20 0f 11 80 	movl   $0x80110f20,(%esp)
80104af9:	e8 7c 04 00 00       	call   80104f7a <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104afe:	c7 45 f4 54 0f 11 80 	movl   $0x80110f54,-0xc(%ebp)
80104b05:	eb 41                	jmp    80104b48 <kill+0x5c>
    if(p->pid == pid){
80104b07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b0a:	8b 40 10             	mov    0x10(%eax),%eax
80104b0d:	3b 45 08             	cmp    0x8(%ebp),%eax
80104b10:	75 32                	jne    80104b44 <kill+0x58>
      p->killed = 1;
80104b12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b15:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104b1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b1f:	8b 40 0c             	mov    0xc(%eax),%eax
80104b22:	83 f8 02             	cmp    $0x2,%eax
80104b25:	75 0a                	jne    80104b31 <kill+0x45>
        p->state = RUNNABLE;
80104b27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b2a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104b31:	c7 04 24 20 0f 11 80 	movl   $0x80110f20,(%esp)
80104b38:	e8 9f 04 00 00       	call   80104fdc <release>
      return 0;
80104b3d:	b8 00 00 00 00       	mov    $0x0,%eax
80104b42:	eb 1e                	jmp    80104b62 <kill+0x76>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b44:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104b48:	81 7d f4 54 2e 11 80 	cmpl   $0x80112e54,-0xc(%ebp)
80104b4f:	72 b6                	jb     80104b07 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104b51:	c7 04 24 20 0f 11 80 	movl   $0x80110f20,(%esp)
80104b58:	e8 7f 04 00 00       	call   80104fdc <release>
  return -1;
80104b5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104b62:	c9                   	leave  
80104b63:	c3                   	ret    

80104b64 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104b64:	55                   	push   %ebp
80104b65:	89 e5                	mov    %esp,%ebp
80104b67:	83 ec 68             	sub    $0x68,%esp
  int i,j;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b6a:	c7 45 ec 54 0f 11 80 	movl   $0x80110f54,-0x14(%ebp)
80104b71:	e9 9e 03 00 00       	jmp    80104f14 <procdump+0x3b0>
    if(p->state == UNUSED)
80104b76:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b79:	8b 40 0c             	mov    0xc(%eax),%eax
80104b7c:	85 c0                	test   %eax,%eax
80104b7e:	75 05                	jne    80104b85 <procdump+0x21>
      continue;
80104b80:	e9 8b 03 00 00       	jmp    80104f10 <procdump+0x3ac>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104b85:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b88:	8b 40 0c             	mov    0xc(%eax),%eax
80104b8b:	83 f8 05             	cmp    $0x5,%eax
80104b8e:	77 23                	ja     80104bb3 <procdump+0x4f>
80104b90:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b93:	8b 40 0c             	mov    0xc(%eax),%eax
80104b96:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
80104b9d:	85 c0                	test   %eax,%eax
80104b9f:	74 12                	je     80104bb3 <procdump+0x4f>
      state = states[p->state];
80104ba1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ba4:	8b 40 0c             	mov    0xc(%eax),%eax
80104ba7:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
80104bae:	89 45 e8             	mov    %eax,-0x18(%ebp)
80104bb1:	eb 07                	jmp    80104bba <procdump+0x56>
    else
      state = "???";
80104bb3:	c7 45 e8 4f 8d 10 80 	movl   $0x80108d4f,-0x18(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104bba:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104bbd:	8d 50 6c             	lea    0x6c(%eax),%edx
80104bc0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104bc3:	8b 40 10             	mov    0x10(%eax),%eax
80104bc6:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104bca:	8b 55 e8             	mov    -0x18(%ebp),%edx
80104bcd:	89 54 24 08          	mov    %edx,0x8(%esp)
80104bd1:	89 44 24 04          	mov    %eax,0x4(%esp)
80104bd5:	c7 04 24 53 8d 10 80 	movl   $0x80108d53,(%esp)
80104bdc:	e8 bf b7 ff ff       	call   801003a0 <cprintf>
    if(p->state == SLEEPING){
80104be1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104be4:	8b 40 0c             	mov    0xc(%eax),%eax
80104be7:	83 f8 02             	cmp    $0x2,%eax
80104bea:	75 50                	jne    80104c3c <procdump+0xd8>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104bec:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104bef:	8b 40 1c             	mov    0x1c(%eax),%eax
80104bf2:	8b 40 0c             	mov    0xc(%eax),%eax
80104bf5:	83 c0 08             	add    $0x8,%eax
80104bf8:	8d 55 b4             	lea    -0x4c(%ebp),%edx
80104bfb:	89 54 24 04          	mov    %edx,0x4(%esp)
80104bff:	89 04 24             	mov    %eax,(%esp)
80104c02:	e8 24 04 00 00       	call   8010502b <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104c07:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104c0e:	eb 1b                	jmp    80104c2b <procdump+0xc7>
        cprintf(" %p", pc[i]);
80104c10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c13:	8b 44 85 b4          	mov    -0x4c(%ebp,%eax,4),%eax
80104c17:	89 44 24 04          	mov    %eax,0x4(%esp)
80104c1b:	c7 04 24 5c 8d 10 80 	movl   $0x80108d5c,(%esp)
80104c22:	e8 79 b7 ff ff       	call   801003a0 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104c27:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104c2b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104c2f:	7f 0b                	jg     80104c3c <procdump+0xd8>
80104c31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c34:	8b 44 85 b4          	mov    -0x4c(%ebp,%eax,4),%eax
80104c38:	85 c0                	test   %eax,%eax
80104c3a:	75 d4                	jne    80104c10 <procdump+0xac>
        cprintf(" %p", pc[i]);
    }
    
    pde_t * pgdir = p -> pgdir;
80104c3c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c3f:	8b 40 04             	mov    0x4(%eax),%eax
80104c42:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    cprintf("Page Tables:\n");
80104c45:	c7 04 24 60 8d 10 80 	movl   $0x80108d60,(%esp)
80104c4c:	e8 4f b7 ff ff       	call   801003a0 <cprintf>

    cprintf("    memory location of page directory = %p\n",pgdir);
80104c51:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104c54:	89 44 24 04          	mov    %eax,0x4(%esp)
80104c58:	c7 04 24 70 8d 10 80 	movl   $0x80108d70,(%esp)
80104c5f:	e8 3c b7 ff ff       	call   801003a0 <cprintf>

    for (i=0 ; i < NPDENTRIES ; i++) {
80104c64:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104c6b:	e9 63 01 00 00       	jmp    80104dd3 <procdump+0x26f>
		// Verificamos se é uma pagina do usuario e se ela esta presente, além de que é acessível
    	if ((pgdir[i] & PTE_P) && (pgdir[i] & PTE_U) && (pgdir[i] & PTE_A) ) {	
80104c70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c73:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104c7a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104c7d:	01 d0                	add    %edx,%eax
80104c7f:	8b 00                	mov    (%eax),%eax
80104c81:	83 e0 01             	and    $0x1,%eax
80104c84:	85 c0                	test   %eax,%eax
80104c86:	0f 84 43 01 00 00    	je     80104dcf <procdump+0x26b>
80104c8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c8f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104c96:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104c99:	01 d0                	add    %edx,%eax
80104c9b:	8b 00                	mov    (%eax),%eax
80104c9d:	83 e0 04             	and    $0x4,%eax
80104ca0:	85 c0                	test   %eax,%eax
80104ca2:	0f 84 27 01 00 00    	je     80104dcf <procdump+0x26b>
80104ca8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cab:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104cb2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104cb5:	01 d0                	add    %edx,%eax
80104cb7:	8b 00                	mov    (%eax),%eax
80104cb9:	83 e0 20             	and    $0x20,%eax
80104cbc:	85 c0                	test   %eax,%eax
80104cbe:	0f 84 0b 01 00 00    	je     80104dcf <procdump+0x26b>
    		cprintf("    pdir PTE %d,%d:\n",i,pgdir[i]>>12);
80104cc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cc7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104cce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104cd1:	01 d0                	add    %edx,%eax
80104cd3:	8b 00                	mov    (%eax),%eax
80104cd5:	c1 e8 0c             	shr    $0xc,%eax
80104cd8:	89 44 24 08          	mov    %eax,0x8(%esp)
80104cdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cdf:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ce3:	c7 04 24 9c 8d 10 80 	movl   $0x80108d9c,(%esp)
80104cea:	e8 b1 b6 ff ff       	call   801003a0 <cprintf>
    		pde_t * pgtbl = P2V(PTE_ADDR(pgdir[i])); // Acesso a pagetable
80104cef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cf2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104cf9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104cfc:	01 d0                	add    %edx,%eax
80104cfe:	8b 00                	mov    (%eax),%eax
80104d00:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80104d05:	05 00 00 00 80       	add    $0x80000000,%eax
80104d0a:	89 45 e0             	mov    %eax,-0x20(%ebp)
    		cprintf("        memory location of page table = %p\n",pgtbl);
80104d0d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104d10:	89 44 24 04          	mov    %eax,0x4(%esp)
80104d14:	c7 04 24 b4 8d 10 80 	movl   $0x80108db4,(%esp)
80104d1b:	e8 80 b6 ff ff       	call   801003a0 <cprintf>
			// Percorremos todas as paginas
    	    for (j=0 ; j < NPTENTRIES; j++) {
80104d20:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104d27:	e9 96 00 00 00       	jmp    80104dc2 <procdump+0x25e>
				// Verificamos se são pagians do usuario e estão presentes
    	    	if ((pgtbl[j] & PTE_P) && (pgtbl[j] & PTE_U) && (pgtbl[j] & PTE_A))
80104d2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d2f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104d36:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104d39:	01 d0                	add    %edx,%eax
80104d3b:	8b 00                	mov    (%eax),%eax
80104d3d:	83 e0 01             	and    $0x1,%eax
80104d40:	85 c0                	test   %eax,%eax
80104d42:	74 7a                	je     80104dbe <procdump+0x25a>
80104d44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d47:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104d4e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104d51:	01 d0                	add    %edx,%eax
80104d53:	8b 00                	mov    (%eax),%eax
80104d55:	83 e0 04             	and    $0x4,%eax
80104d58:	85 c0                	test   %eax,%eax
80104d5a:	74 62                	je     80104dbe <procdump+0x25a>
80104d5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d5f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104d66:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104d69:	01 d0                	add    %edx,%eax
80104d6b:	8b 00                	mov    (%eax),%eax
80104d6d:	83 e0 20             	and    $0x20,%eax
80104d70:	85 c0                	test   %eax,%eax
80104d72:	74 4a                	je     80104dbe <procdump+0x25a>
					// SHHIFT LEFT 12 temos o PPN 20 bits mais significativos
    	    		cprintf("        ptbl PTE %d,%d,%p\n",j,pgtbl[j]>>12,P2V(PTE_ADDR(pgtbl[j])));
80104d74:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d77:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104d7e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104d81:	01 d0                	add    %edx,%eax
80104d83:	8b 00                	mov    (%eax),%eax
80104d85:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80104d8a:	05 00 00 00 80       	add    $0x80000000,%eax
80104d8f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d92:	8d 0c 95 00 00 00 00 	lea    0x0(,%edx,4),%ecx
80104d99:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104d9c:	01 ca                	add    %ecx,%edx
80104d9e:	8b 12                	mov    (%edx),%edx
80104da0:	c1 ea 0c             	shr    $0xc,%edx
80104da3:	89 44 24 0c          	mov    %eax,0xc(%esp)
80104da7:	89 54 24 08          	mov    %edx,0x8(%esp)
80104dab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dae:	89 44 24 04          	mov    %eax,0x4(%esp)
80104db2:	c7 04 24 e0 8d 10 80 	movl   $0x80108de0,(%esp)
80104db9:	e8 e2 b5 ff ff       	call   801003a0 <cprintf>
    	if ((pgdir[i] & PTE_P) && (pgdir[i] & PTE_U) && (pgdir[i] & PTE_A) ) {	
    		cprintf("    pdir PTE %d,%d:\n",i,pgdir[i]>>12);
    		pde_t * pgtbl = P2V(PTE_ADDR(pgdir[i])); // Acesso a pagetable
    		cprintf("        memory location of page table = %p\n",pgtbl);
			// Percorremos todas as paginas
    	    for (j=0 ; j < NPTENTRIES; j++) {
80104dbe:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104dc2:	81 7d f0 ff 03 00 00 	cmpl   $0x3ff,-0x10(%ebp)
80104dc9:	0f 8e 5d ff ff ff    	jle    80104d2c <procdump+0x1c8>
    pde_t * pgdir = p -> pgdir;
    cprintf("Page Tables:\n");

    cprintf("    memory location of page directory = %p\n",pgdir);

    for (i=0 ; i < NPDENTRIES ; i++) {
80104dcf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104dd3:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80104dda:	0f 8e 90 fe ff ff    	jle    80104c70 <procdump+0x10c>
    	    		cprintf("        ptbl PTE %d,%d,%p\n",j,pgtbl[j]>>12,P2V(PTE_ADDR(pgtbl[j])));
    	    }
    	}
    }
    
	cprintf("    Port Mappings:\n");
80104de0:	c7 04 24 fb 8d 10 80 	movl   $0x80108dfb,(%esp)
80104de7:	e8 b4 b5 ff ff       	call   801003a0 <cprintf>
	for (i=0 ; i < NPDENTRIES ; i++) {
80104dec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104df3:	e9 0b 01 00 00       	jmp    80104f03 <procdump+0x39f>
		// Verificamos se é uma pagina do usuario e se ela esta presente, além de que é acessível
		if ((pgdir[i] & PTE_P) && (pgdir[i] & PTE_U) && (pgdir[i] & PTE_A)) {
80104df8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dfb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104e02:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104e05:	01 d0                	add    %edx,%eax
80104e07:	8b 00                	mov    (%eax),%eax
80104e09:	83 e0 01             	and    $0x1,%eax
80104e0c:	85 c0                	test   %eax,%eax
80104e0e:	0f 84 eb 00 00 00    	je     80104eff <procdump+0x39b>
80104e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e17:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104e1e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104e21:	01 d0                	add    %edx,%eax
80104e23:	8b 00                	mov    (%eax),%eax
80104e25:	83 e0 04             	and    $0x4,%eax
80104e28:	85 c0                	test   %eax,%eax
80104e2a:	0f 84 cf 00 00 00    	je     80104eff <procdump+0x39b>
80104e30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e33:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104e3a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104e3d:	01 d0                	add    %edx,%eax
80104e3f:	8b 00                	mov    (%eax),%eax
80104e41:	83 e0 20             	and    $0x20,%eax
80104e44:	85 c0                	test   %eax,%eax
80104e46:	0f 84 b3 00 00 00    	je     80104eff <procdump+0x39b>
			pde_t * pgtbl = P2V(PTE_ADDR(pgdir[i])); // Acessa a page table
80104e4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e4f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104e56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104e59:	01 d0                	add    %edx,%eax
80104e5b:	8b 00                	mov    (%eax),%eax
80104e5d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80104e62:	05 00 00 00 80       	add    $0x80000000,%eax
80104e67:	89 45 dc             	mov    %eax,-0x24(%ebp)
			for (j=0 ; j < NPTENTRIES; j++) {
80104e6a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104e71:	eb 7f                	jmp    80104ef2 <procdump+0x38e>
				if ((pgtbl[j] & PTE_P) && (pgtbl[j] & PTE_U) && (pgtbl[j] & PTE_A)) {
80104e73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e76:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104e7d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104e80:	01 d0                	add    %edx,%eax
80104e82:	8b 00                	mov    (%eax),%eax
80104e84:	83 e0 01             	and    $0x1,%eax
80104e87:	85 c0                	test   %eax,%eax
80104e89:	74 63                	je     80104eee <procdump+0x38a>
80104e8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e8e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104e95:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104e98:	01 d0                	add    %edx,%eax
80104e9a:	8b 00                	mov    (%eax),%eax
80104e9c:	83 e0 04             	and    $0x4,%eax
80104e9f:	85 c0                	test   %eax,%eax
80104ea1:	74 4b                	je     80104eee <procdump+0x38a>
80104ea3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ea6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104ead:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104eb0:	01 d0                	add    %edx,%eax
80104eb2:	8b 00                	mov    (%eax),%eax
80104eb4:	83 e0 20             	and    $0x20,%eax
80104eb7:	85 c0                	test   %eax,%eax
80104eb9:	74 33                	je     80104eee <procdump+0x38a>

					cprintf("        %d -> %d\n",(i<<10)|j,pgtbl[j]>>12);
80104ebb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ebe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104ec5:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104ec8:	01 d0                	add    %edx,%eax
80104eca:	8b 00                	mov    (%eax),%eax
80104ecc:	c1 e8 0c             	shr    $0xc,%eax
80104ecf:	89 c2                	mov    %eax,%edx
80104ed1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ed4:	c1 e0 0a             	shl    $0xa,%eax
80104ed7:	0b 45 f0             	or     -0x10(%ebp),%eax
80104eda:	89 54 24 08          	mov    %edx,0x8(%esp)
80104ede:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ee2:	c7 04 24 0f 8e 10 80 	movl   $0x80108e0f,(%esp)
80104ee9:	e8 b2 b4 ff ff       	call   801003a0 <cprintf>
	cprintf("    Port Mappings:\n");
	for (i=0 ; i < NPDENTRIES ; i++) {
		// Verificamos se é uma pagina do usuario e se ela esta presente, além de que é acessível
		if ((pgdir[i] & PTE_P) && (pgdir[i] & PTE_U) && (pgdir[i] & PTE_A)) {
			pde_t * pgtbl = P2V(PTE_ADDR(pgdir[i])); // Acessa a page table
			for (j=0 ; j < NPTENTRIES; j++) {
80104eee:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104ef2:	81 7d f0 ff 03 00 00 	cmpl   $0x3ff,-0x10(%ebp)
80104ef9:	0f 8e 74 ff ff ff    	jle    80104e73 <procdump+0x30f>
    	    }
    	}
    }
    
	cprintf("    Port Mappings:\n");
	for (i=0 ; i < NPDENTRIES ; i++) {
80104eff:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104f03:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80104f0a:	0f 8e e8 fe ff ff    	jle    80104df8 <procdump+0x294>
  int i,j;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f10:	83 45 ec 7c          	addl   $0x7c,-0x14(%ebp)
80104f14:	81 7d ec 54 2e 11 80 	cmpl   $0x80112e54,-0x14(%ebp)
80104f1b:	0f 82 55 fc ff ff    	jb     80104b76 <procdump+0x12>
				}
			}
		}
	}
  }
}
80104f21:	c9                   	leave  
80104f22:	c3                   	ret    

80104f23 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104f23:	55                   	push   %ebp
80104f24:	89 e5                	mov    %esp,%ebp
80104f26:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104f29:	9c                   	pushf  
80104f2a:	58                   	pop    %eax
80104f2b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104f2e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f31:	c9                   	leave  
80104f32:	c3                   	ret    

80104f33 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80104f33:	55                   	push   %ebp
80104f34:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104f36:	fa                   	cli    
}
80104f37:	5d                   	pop    %ebp
80104f38:	c3                   	ret    

80104f39 <sti>:

static inline void
sti(void)
{
80104f39:	55                   	push   %ebp
80104f3a:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104f3c:	fb                   	sti    
}
80104f3d:	5d                   	pop    %ebp
80104f3e:	c3                   	ret    

80104f3f <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80104f3f:	55                   	push   %ebp
80104f40:	89 e5                	mov    %esp,%ebp
80104f42:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104f45:	8b 55 08             	mov    0x8(%ebp),%edx
80104f48:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104f4e:	f0 87 02             	lock xchg %eax,(%edx)
80104f51:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80104f54:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f57:	c9                   	leave  
80104f58:	c3                   	ret    

80104f59 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104f59:	55                   	push   %ebp
80104f5a:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104f5c:	8b 45 08             	mov    0x8(%ebp),%eax
80104f5f:	8b 55 0c             	mov    0xc(%ebp),%edx
80104f62:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104f65:	8b 45 08             	mov    0x8(%ebp),%eax
80104f68:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104f6e:	8b 45 08             	mov    0x8(%ebp),%eax
80104f71:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104f78:	5d                   	pop    %ebp
80104f79:	c3                   	ret    

80104f7a <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104f7a:	55                   	push   %ebp
80104f7b:	89 e5                	mov    %esp,%ebp
80104f7d:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104f80:	e8 49 01 00 00       	call   801050ce <pushcli>
  if(holding(lk))
80104f85:	8b 45 08             	mov    0x8(%ebp),%eax
80104f88:	89 04 24             	mov    %eax,(%esp)
80104f8b:	e8 14 01 00 00       	call   801050a4 <holding>
80104f90:	85 c0                	test   %eax,%eax
80104f92:	74 0c                	je     80104fa0 <acquire+0x26>
    panic("acquire");
80104f94:	c7 04 24 4b 8e 10 80 	movl   $0x80108e4b,(%esp)
80104f9b:	e8 9a b5 ff ff       	call   8010053a <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80104fa0:	90                   	nop
80104fa1:	8b 45 08             	mov    0x8(%ebp),%eax
80104fa4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80104fab:	00 
80104fac:	89 04 24             	mov    %eax,(%esp)
80104faf:	e8 8b ff ff ff       	call   80104f3f <xchg>
80104fb4:	85 c0                	test   %eax,%eax
80104fb6:	75 e9                	jne    80104fa1 <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80104fb8:	8b 45 08             	mov    0x8(%ebp),%eax
80104fbb:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104fc2:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80104fc5:	8b 45 08             	mov    0x8(%ebp),%eax
80104fc8:	83 c0 0c             	add    $0xc,%eax
80104fcb:	89 44 24 04          	mov    %eax,0x4(%esp)
80104fcf:	8d 45 08             	lea    0x8(%ebp),%eax
80104fd2:	89 04 24             	mov    %eax,(%esp)
80104fd5:	e8 51 00 00 00       	call   8010502b <getcallerpcs>
}
80104fda:	c9                   	leave  
80104fdb:	c3                   	ret    

80104fdc <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104fdc:	55                   	push   %ebp
80104fdd:	89 e5                	mov    %esp,%ebp
80104fdf:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80104fe2:	8b 45 08             	mov    0x8(%ebp),%eax
80104fe5:	89 04 24             	mov    %eax,(%esp)
80104fe8:	e8 b7 00 00 00       	call   801050a4 <holding>
80104fed:	85 c0                	test   %eax,%eax
80104fef:	75 0c                	jne    80104ffd <release+0x21>
    panic("release");
80104ff1:	c7 04 24 53 8e 10 80 	movl   $0x80108e53,(%esp)
80104ff8:	e8 3d b5 ff ff       	call   8010053a <panic>

  lk->pcs[0] = 0;
80104ffd:	8b 45 08             	mov    0x8(%ebp),%eax
80105000:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105007:	8b 45 08             	mov    0x8(%ebp),%eax
8010500a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105011:	8b 45 08             	mov    0x8(%ebp),%eax
80105014:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010501b:	00 
8010501c:	89 04 24             	mov    %eax,(%esp)
8010501f:	e8 1b ff ff ff       	call   80104f3f <xchg>

  popcli();
80105024:	e8 e9 00 00 00       	call   80105112 <popcli>
}
80105029:	c9                   	leave  
8010502a:	c3                   	ret    

8010502b <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010502b:	55                   	push   %ebp
8010502c:	89 e5                	mov    %esp,%ebp
8010502e:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105031:	8b 45 08             	mov    0x8(%ebp),%eax
80105034:	83 e8 08             	sub    $0x8,%eax
80105037:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010503a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105041:	eb 38                	jmp    8010507b <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105043:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105047:	74 38                	je     80105081 <getcallerpcs+0x56>
80105049:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105050:	76 2f                	jbe    80105081 <getcallerpcs+0x56>
80105052:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105056:	74 29                	je     80105081 <getcallerpcs+0x56>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105058:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010505b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105062:	8b 45 0c             	mov    0xc(%ebp),%eax
80105065:	01 c2                	add    %eax,%edx
80105067:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010506a:	8b 40 04             	mov    0x4(%eax),%eax
8010506d:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
8010506f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105072:	8b 00                	mov    (%eax),%eax
80105074:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105077:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010507b:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010507f:	7e c2                	jle    80105043 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105081:	eb 19                	jmp    8010509c <getcallerpcs+0x71>
    pcs[i] = 0;
80105083:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105086:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010508d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105090:	01 d0                	add    %edx,%eax
80105092:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105098:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010509c:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801050a0:	7e e1                	jle    80105083 <getcallerpcs+0x58>
    pcs[i] = 0;
}
801050a2:	c9                   	leave  
801050a3:	c3                   	ret    

801050a4 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801050a4:	55                   	push   %ebp
801050a5:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
801050a7:	8b 45 08             	mov    0x8(%ebp),%eax
801050aa:	8b 00                	mov    (%eax),%eax
801050ac:	85 c0                	test   %eax,%eax
801050ae:	74 17                	je     801050c7 <holding+0x23>
801050b0:	8b 45 08             	mov    0x8(%ebp),%eax
801050b3:	8b 50 08             	mov    0x8(%eax),%edx
801050b6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801050bc:	39 c2                	cmp    %eax,%edx
801050be:	75 07                	jne    801050c7 <holding+0x23>
801050c0:	b8 01 00 00 00       	mov    $0x1,%eax
801050c5:	eb 05                	jmp    801050cc <holding+0x28>
801050c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801050cc:	5d                   	pop    %ebp
801050cd:	c3                   	ret    

801050ce <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801050ce:	55                   	push   %ebp
801050cf:	89 e5                	mov    %esp,%ebp
801050d1:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
801050d4:	e8 4a fe ff ff       	call   80104f23 <readeflags>
801050d9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
801050dc:	e8 52 fe ff ff       	call   80104f33 <cli>
  if(cpu->ncli++ == 0)
801050e1:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801050e8:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
801050ee:	8d 48 01             	lea    0x1(%eax),%ecx
801050f1:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
801050f7:	85 c0                	test   %eax,%eax
801050f9:	75 15                	jne    80105110 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
801050fb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105101:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105104:	81 e2 00 02 00 00    	and    $0x200,%edx
8010510a:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105110:	c9                   	leave  
80105111:	c3                   	ret    

80105112 <popcli>:

void
popcli(void)
{
80105112:	55                   	push   %ebp
80105113:	89 e5                	mov    %esp,%ebp
80105115:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80105118:	e8 06 fe ff ff       	call   80104f23 <readeflags>
8010511d:	25 00 02 00 00       	and    $0x200,%eax
80105122:	85 c0                	test   %eax,%eax
80105124:	74 0c                	je     80105132 <popcli+0x20>
    panic("popcli - interruptible");
80105126:	c7 04 24 5b 8e 10 80 	movl   $0x80108e5b,(%esp)
8010512d:	e8 08 b4 ff ff       	call   8010053a <panic>
  if(--cpu->ncli < 0)
80105132:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105138:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
8010513e:	83 ea 01             	sub    $0x1,%edx
80105141:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105147:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010514d:	85 c0                	test   %eax,%eax
8010514f:	79 0c                	jns    8010515d <popcli+0x4b>
    panic("popcli");
80105151:	c7 04 24 72 8e 10 80 	movl   $0x80108e72,(%esp)
80105158:	e8 dd b3 ff ff       	call   8010053a <panic>
  if(cpu->ncli == 0 && cpu->intena)
8010515d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105163:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105169:	85 c0                	test   %eax,%eax
8010516b:	75 15                	jne    80105182 <popcli+0x70>
8010516d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105173:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105179:	85 c0                	test   %eax,%eax
8010517b:	74 05                	je     80105182 <popcli+0x70>
    sti();
8010517d:	e8 b7 fd ff ff       	call   80104f39 <sti>
}
80105182:	c9                   	leave  
80105183:	c3                   	ret    

80105184 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105184:	55                   	push   %ebp
80105185:	89 e5                	mov    %esp,%ebp
80105187:	57                   	push   %edi
80105188:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105189:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010518c:	8b 55 10             	mov    0x10(%ebp),%edx
8010518f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105192:	89 cb                	mov    %ecx,%ebx
80105194:	89 df                	mov    %ebx,%edi
80105196:	89 d1                	mov    %edx,%ecx
80105198:	fc                   	cld    
80105199:	f3 aa                	rep stos %al,%es:(%edi)
8010519b:	89 ca                	mov    %ecx,%edx
8010519d:	89 fb                	mov    %edi,%ebx
8010519f:	89 5d 08             	mov    %ebx,0x8(%ebp)
801051a2:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801051a5:	5b                   	pop    %ebx
801051a6:	5f                   	pop    %edi
801051a7:	5d                   	pop    %ebp
801051a8:	c3                   	ret    

801051a9 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801051a9:	55                   	push   %ebp
801051aa:	89 e5                	mov    %esp,%ebp
801051ac:	57                   	push   %edi
801051ad:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801051ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
801051b1:	8b 55 10             	mov    0x10(%ebp),%edx
801051b4:	8b 45 0c             	mov    0xc(%ebp),%eax
801051b7:	89 cb                	mov    %ecx,%ebx
801051b9:	89 df                	mov    %ebx,%edi
801051bb:	89 d1                	mov    %edx,%ecx
801051bd:	fc                   	cld    
801051be:	f3 ab                	rep stos %eax,%es:(%edi)
801051c0:	89 ca                	mov    %ecx,%edx
801051c2:	89 fb                	mov    %edi,%ebx
801051c4:	89 5d 08             	mov    %ebx,0x8(%ebp)
801051c7:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801051ca:	5b                   	pop    %ebx
801051cb:	5f                   	pop    %edi
801051cc:	5d                   	pop    %ebp
801051cd:	c3                   	ret    

801051ce <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801051ce:	55                   	push   %ebp
801051cf:	89 e5                	mov    %esp,%ebp
801051d1:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
801051d4:	8b 45 08             	mov    0x8(%ebp),%eax
801051d7:	83 e0 03             	and    $0x3,%eax
801051da:	85 c0                	test   %eax,%eax
801051dc:	75 49                	jne    80105227 <memset+0x59>
801051de:	8b 45 10             	mov    0x10(%ebp),%eax
801051e1:	83 e0 03             	and    $0x3,%eax
801051e4:	85 c0                	test   %eax,%eax
801051e6:	75 3f                	jne    80105227 <memset+0x59>
    c &= 0xFF;
801051e8:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801051ef:	8b 45 10             	mov    0x10(%ebp),%eax
801051f2:	c1 e8 02             	shr    $0x2,%eax
801051f5:	89 c2                	mov    %eax,%edx
801051f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801051fa:	c1 e0 18             	shl    $0x18,%eax
801051fd:	89 c1                	mov    %eax,%ecx
801051ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80105202:	c1 e0 10             	shl    $0x10,%eax
80105205:	09 c1                	or     %eax,%ecx
80105207:	8b 45 0c             	mov    0xc(%ebp),%eax
8010520a:	c1 e0 08             	shl    $0x8,%eax
8010520d:	09 c8                	or     %ecx,%eax
8010520f:	0b 45 0c             	or     0xc(%ebp),%eax
80105212:	89 54 24 08          	mov    %edx,0x8(%esp)
80105216:	89 44 24 04          	mov    %eax,0x4(%esp)
8010521a:	8b 45 08             	mov    0x8(%ebp),%eax
8010521d:	89 04 24             	mov    %eax,(%esp)
80105220:	e8 84 ff ff ff       	call   801051a9 <stosl>
80105225:	eb 19                	jmp    80105240 <memset+0x72>
  } else
    stosb(dst, c, n);
80105227:	8b 45 10             	mov    0x10(%ebp),%eax
8010522a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010522e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105231:	89 44 24 04          	mov    %eax,0x4(%esp)
80105235:	8b 45 08             	mov    0x8(%ebp),%eax
80105238:	89 04 24             	mov    %eax,(%esp)
8010523b:	e8 44 ff ff ff       	call   80105184 <stosb>
  return dst;
80105240:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105243:	c9                   	leave  
80105244:	c3                   	ret    

80105245 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105245:	55                   	push   %ebp
80105246:	89 e5                	mov    %esp,%ebp
80105248:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
8010524b:	8b 45 08             	mov    0x8(%ebp),%eax
8010524e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105251:	8b 45 0c             	mov    0xc(%ebp),%eax
80105254:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105257:	eb 30                	jmp    80105289 <memcmp+0x44>
    if(*s1 != *s2)
80105259:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010525c:	0f b6 10             	movzbl (%eax),%edx
8010525f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105262:	0f b6 00             	movzbl (%eax),%eax
80105265:	38 c2                	cmp    %al,%dl
80105267:	74 18                	je     80105281 <memcmp+0x3c>
      return *s1 - *s2;
80105269:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010526c:	0f b6 00             	movzbl (%eax),%eax
8010526f:	0f b6 d0             	movzbl %al,%edx
80105272:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105275:	0f b6 00             	movzbl (%eax),%eax
80105278:	0f b6 c0             	movzbl %al,%eax
8010527b:	29 c2                	sub    %eax,%edx
8010527d:	89 d0                	mov    %edx,%eax
8010527f:	eb 1a                	jmp    8010529b <memcmp+0x56>
    s1++, s2++;
80105281:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105285:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105289:	8b 45 10             	mov    0x10(%ebp),%eax
8010528c:	8d 50 ff             	lea    -0x1(%eax),%edx
8010528f:	89 55 10             	mov    %edx,0x10(%ebp)
80105292:	85 c0                	test   %eax,%eax
80105294:	75 c3                	jne    80105259 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105296:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010529b:	c9                   	leave  
8010529c:	c3                   	ret    

8010529d <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
8010529d:	55                   	push   %ebp
8010529e:	89 e5                	mov    %esp,%ebp
801052a0:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801052a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801052a6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801052a9:	8b 45 08             	mov    0x8(%ebp),%eax
801052ac:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801052af:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052b2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801052b5:	73 3d                	jae    801052f4 <memmove+0x57>
801052b7:	8b 45 10             	mov    0x10(%ebp),%eax
801052ba:	8b 55 fc             	mov    -0x4(%ebp),%edx
801052bd:	01 d0                	add    %edx,%eax
801052bf:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801052c2:	76 30                	jbe    801052f4 <memmove+0x57>
    s += n;
801052c4:	8b 45 10             	mov    0x10(%ebp),%eax
801052c7:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801052ca:	8b 45 10             	mov    0x10(%ebp),%eax
801052cd:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801052d0:	eb 13                	jmp    801052e5 <memmove+0x48>
      *--d = *--s;
801052d2:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801052d6:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801052da:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052dd:	0f b6 10             	movzbl (%eax),%edx
801052e0:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052e3:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
801052e5:	8b 45 10             	mov    0x10(%ebp),%eax
801052e8:	8d 50 ff             	lea    -0x1(%eax),%edx
801052eb:	89 55 10             	mov    %edx,0x10(%ebp)
801052ee:	85 c0                	test   %eax,%eax
801052f0:	75 e0                	jne    801052d2 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801052f2:	eb 26                	jmp    8010531a <memmove+0x7d>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801052f4:	eb 17                	jmp    8010530d <memmove+0x70>
      *d++ = *s++;
801052f6:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052f9:	8d 50 01             	lea    0x1(%eax),%edx
801052fc:	89 55 f8             	mov    %edx,-0x8(%ebp)
801052ff:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105302:	8d 4a 01             	lea    0x1(%edx),%ecx
80105305:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105308:	0f b6 12             	movzbl (%edx),%edx
8010530b:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
8010530d:	8b 45 10             	mov    0x10(%ebp),%eax
80105310:	8d 50 ff             	lea    -0x1(%eax),%edx
80105313:	89 55 10             	mov    %edx,0x10(%ebp)
80105316:	85 c0                	test   %eax,%eax
80105318:	75 dc                	jne    801052f6 <memmove+0x59>
      *d++ = *s++;

  return dst;
8010531a:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010531d:	c9                   	leave  
8010531e:	c3                   	ret    

8010531f <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
8010531f:	55                   	push   %ebp
80105320:	89 e5                	mov    %esp,%ebp
80105322:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80105325:	8b 45 10             	mov    0x10(%ebp),%eax
80105328:	89 44 24 08          	mov    %eax,0x8(%esp)
8010532c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010532f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105333:	8b 45 08             	mov    0x8(%ebp),%eax
80105336:	89 04 24             	mov    %eax,(%esp)
80105339:	e8 5f ff ff ff       	call   8010529d <memmove>
}
8010533e:	c9                   	leave  
8010533f:	c3                   	ret    

80105340 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105340:	55                   	push   %ebp
80105341:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105343:	eb 0c                	jmp    80105351 <strncmp+0x11>
    n--, p++, q++;
80105345:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105349:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010534d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105351:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105355:	74 1a                	je     80105371 <strncmp+0x31>
80105357:	8b 45 08             	mov    0x8(%ebp),%eax
8010535a:	0f b6 00             	movzbl (%eax),%eax
8010535d:	84 c0                	test   %al,%al
8010535f:	74 10                	je     80105371 <strncmp+0x31>
80105361:	8b 45 08             	mov    0x8(%ebp),%eax
80105364:	0f b6 10             	movzbl (%eax),%edx
80105367:	8b 45 0c             	mov    0xc(%ebp),%eax
8010536a:	0f b6 00             	movzbl (%eax),%eax
8010536d:	38 c2                	cmp    %al,%dl
8010536f:	74 d4                	je     80105345 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105371:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105375:	75 07                	jne    8010537e <strncmp+0x3e>
    return 0;
80105377:	b8 00 00 00 00       	mov    $0x0,%eax
8010537c:	eb 16                	jmp    80105394 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
8010537e:	8b 45 08             	mov    0x8(%ebp),%eax
80105381:	0f b6 00             	movzbl (%eax),%eax
80105384:	0f b6 d0             	movzbl %al,%edx
80105387:	8b 45 0c             	mov    0xc(%ebp),%eax
8010538a:	0f b6 00             	movzbl (%eax),%eax
8010538d:	0f b6 c0             	movzbl %al,%eax
80105390:	29 c2                	sub    %eax,%edx
80105392:	89 d0                	mov    %edx,%eax
}
80105394:	5d                   	pop    %ebp
80105395:	c3                   	ret    

80105396 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105396:	55                   	push   %ebp
80105397:	89 e5                	mov    %esp,%ebp
80105399:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
8010539c:	8b 45 08             	mov    0x8(%ebp),%eax
8010539f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801053a2:	90                   	nop
801053a3:	8b 45 10             	mov    0x10(%ebp),%eax
801053a6:	8d 50 ff             	lea    -0x1(%eax),%edx
801053a9:	89 55 10             	mov    %edx,0x10(%ebp)
801053ac:	85 c0                	test   %eax,%eax
801053ae:	7e 1e                	jle    801053ce <strncpy+0x38>
801053b0:	8b 45 08             	mov    0x8(%ebp),%eax
801053b3:	8d 50 01             	lea    0x1(%eax),%edx
801053b6:	89 55 08             	mov    %edx,0x8(%ebp)
801053b9:	8b 55 0c             	mov    0xc(%ebp),%edx
801053bc:	8d 4a 01             	lea    0x1(%edx),%ecx
801053bf:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801053c2:	0f b6 12             	movzbl (%edx),%edx
801053c5:	88 10                	mov    %dl,(%eax)
801053c7:	0f b6 00             	movzbl (%eax),%eax
801053ca:	84 c0                	test   %al,%al
801053cc:	75 d5                	jne    801053a3 <strncpy+0xd>
    ;
  while(n-- > 0)
801053ce:	eb 0c                	jmp    801053dc <strncpy+0x46>
    *s++ = 0;
801053d0:	8b 45 08             	mov    0x8(%ebp),%eax
801053d3:	8d 50 01             	lea    0x1(%eax),%edx
801053d6:	89 55 08             	mov    %edx,0x8(%ebp)
801053d9:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
801053dc:	8b 45 10             	mov    0x10(%ebp),%eax
801053df:	8d 50 ff             	lea    -0x1(%eax),%edx
801053e2:	89 55 10             	mov    %edx,0x10(%ebp)
801053e5:	85 c0                	test   %eax,%eax
801053e7:	7f e7                	jg     801053d0 <strncpy+0x3a>
    *s++ = 0;
  return os;
801053e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801053ec:	c9                   	leave  
801053ed:	c3                   	ret    

801053ee <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801053ee:	55                   	push   %ebp
801053ef:	89 e5                	mov    %esp,%ebp
801053f1:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801053f4:	8b 45 08             	mov    0x8(%ebp),%eax
801053f7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801053fa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801053fe:	7f 05                	jg     80105405 <safestrcpy+0x17>
    return os;
80105400:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105403:	eb 31                	jmp    80105436 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80105405:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105409:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010540d:	7e 1e                	jle    8010542d <safestrcpy+0x3f>
8010540f:	8b 45 08             	mov    0x8(%ebp),%eax
80105412:	8d 50 01             	lea    0x1(%eax),%edx
80105415:	89 55 08             	mov    %edx,0x8(%ebp)
80105418:	8b 55 0c             	mov    0xc(%ebp),%edx
8010541b:	8d 4a 01             	lea    0x1(%edx),%ecx
8010541e:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105421:	0f b6 12             	movzbl (%edx),%edx
80105424:	88 10                	mov    %dl,(%eax)
80105426:	0f b6 00             	movzbl (%eax),%eax
80105429:	84 c0                	test   %al,%al
8010542b:	75 d8                	jne    80105405 <safestrcpy+0x17>
    ;
  *s = 0;
8010542d:	8b 45 08             	mov    0x8(%ebp),%eax
80105430:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105433:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105436:	c9                   	leave  
80105437:	c3                   	ret    

80105438 <strlen>:

int
strlen(const char *s)
{
80105438:	55                   	push   %ebp
80105439:	89 e5                	mov    %esp,%ebp
8010543b:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010543e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105445:	eb 04                	jmp    8010544b <strlen+0x13>
80105447:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010544b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010544e:	8b 45 08             	mov    0x8(%ebp),%eax
80105451:	01 d0                	add    %edx,%eax
80105453:	0f b6 00             	movzbl (%eax),%eax
80105456:	84 c0                	test   %al,%al
80105458:	75 ed                	jne    80105447 <strlen+0xf>
    ;
  return n;
8010545a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010545d:	c9                   	leave  
8010545e:	c3                   	ret    

8010545f <swtch>:
8010545f:	8b 44 24 04          	mov    0x4(%esp),%eax
80105463:	8b 54 24 08          	mov    0x8(%esp),%edx
80105467:	55                   	push   %ebp
80105468:	53                   	push   %ebx
80105469:	56                   	push   %esi
8010546a:	57                   	push   %edi
8010546b:	89 20                	mov    %esp,(%eax)
8010546d:	89 d4                	mov    %edx,%esp
8010546f:	5f                   	pop    %edi
80105470:	5e                   	pop    %esi
80105471:	5b                   	pop    %ebx
80105472:	5d                   	pop    %ebp
80105473:	c3                   	ret    

80105474 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
80105474:	55                   	push   %ebp
80105475:	89 e5                	mov    %esp,%ebp
  if(addr >= p->sz || addr+4 > p->sz)
80105477:	8b 45 08             	mov    0x8(%ebp),%eax
8010547a:	8b 00                	mov    (%eax),%eax
8010547c:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010547f:	76 0f                	jbe    80105490 <fetchint+0x1c>
80105481:	8b 45 0c             	mov    0xc(%ebp),%eax
80105484:	8d 50 04             	lea    0x4(%eax),%edx
80105487:	8b 45 08             	mov    0x8(%ebp),%eax
8010548a:	8b 00                	mov    (%eax),%eax
8010548c:	39 c2                	cmp    %eax,%edx
8010548e:	76 07                	jbe    80105497 <fetchint+0x23>
    return -1;
80105490:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105495:	eb 0f                	jmp    801054a6 <fetchint+0x32>
  *ip = *(int*)(addr);
80105497:	8b 45 0c             	mov    0xc(%ebp),%eax
8010549a:	8b 10                	mov    (%eax),%edx
8010549c:	8b 45 10             	mov    0x10(%ebp),%eax
8010549f:	89 10                	mov    %edx,(%eax)
  return 0;
801054a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054a6:	5d                   	pop    %ebp
801054a7:	c3                   	ret    

801054a8 <fetchstr>:
// Fetch the nul-terminated string at addr from process p.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(struct proc *p, uint addr, char **pp)
{
801054a8:	55                   	push   %ebp
801054a9:	89 e5                	mov    %esp,%ebp
801054ab:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= p->sz)
801054ae:	8b 45 08             	mov    0x8(%ebp),%eax
801054b1:	8b 00                	mov    (%eax),%eax
801054b3:	3b 45 0c             	cmp    0xc(%ebp),%eax
801054b6:	77 07                	ja     801054bf <fetchstr+0x17>
    return -1;
801054b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054bd:	eb 43                	jmp    80105502 <fetchstr+0x5a>
  *pp = (char*)addr;
801054bf:	8b 55 0c             	mov    0xc(%ebp),%edx
801054c2:	8b 45 10             	mov    0x10(%ebp),%eax
801054c5:	89 10                	mov    %edx,(%eax)
  ep = (char*)p->sz;
801054c7:	8b 45 08             	mov    0x8(%ebp),%eax
801054ca:	8b 00                	mov    (%eax),%eax
801054cc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
801054cf:	8b 45 10             	mov    0x10(%ebp),%eax
801054d2:	8b 00                	mov    (%eax),%eax
801054d4:	89 45 fc             	mov    %eax,-0x4(%ebp)
801054d7:	eb 1c                	jmp    801054f5 <fetchstr+0x4d>
    if(*s == 0)
801054d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054dc:	0f b6 00             	movzbl (%eax),%eax
801054df:	84 c0                	test   %al,%al
801054e1:	75 0e                	jne    801054f1 <fetchstr+0x49>
      return s - *pp;
801054e3:	8b 55 fc             	mov    -0x4(%ebp),%edx
801054e6:	8b 45 10             	mov    0x10(%ebp),%eax
801054e9:	8b 00                	mov    (%eax),%eax
801054eb:	29 c2                	sub    %eax,%edx
801054ed:	89 d0                	mov    %edx,%eax
801054ef:	eb 11                	jmp    80105502 <fetchstr+0x5a>

  if(addr >= p->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)p->sz;
  for(s = *pp; s < ep; s++)
801054f1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801054f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054f8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801054fb:	72 dc                	jb     801054d9 <fetchstr+0x31>
    if(*s == 0)
      return s - *pp;
  return -1;
801054fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105502:	c9                   	leave  
80105503:	c3                   	ret    

80105504 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105504:	55                   	push   %ebp
80105505:	89 e5                	mov    %esp,%ebp
80105507:	83 ec 0c             	sub    $0xc,%esp
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
8010550a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105510:	8b 40 18             	mov    0x18(%eax),%eax
80105513:	8b 50 44             	mov    0x44(%eax),%edx
80105516:	8b 45 08             	mov    0x8(%ebp),%eax
80105519:	c1 e0 02             	shl    $0x2,%eax
8010551c:	01 d0                	add    %edx,%eax
8010551e:	8d 48 04             	lea    0x4(%eax),%ecx
80105521:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105527:	8b 55 0c             	mov    0xc(%ebp),%edx
8010552a:	89 54 24 08          	mov    %edx,0x8(%esp)
8010552e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
80105532:	89 04 24             	mov    %eax,(%esp)
80105535:	e8 3a ff ff ff       	call   80105474 <fetchint>
}
8010553a:	c9                   	leave  
8010553b:	c3                   	ret    

8010553c <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010553c:	55                   	push   %ebp
8010553d:	89 e5                	mov    %esp,%ebp
8010553f:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
80105542:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105545:	89 44 24 04          	mov    %eax,0x4(%esp)
80105549:	8b 45 08             	mov    0x8(%ebp),%eax
8010554c:	89 04 24             	mov    %eax,(%esp)
8010554f:	e8 b0 ff ff ff       	call   80105504 <argint>
80105554:	85 c0                	test   %eax,%eax
80105556:	79 07                	jns    8010555f <argptr+0x23>
    return -1;
80105558:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010555d:	eb 3d                	jmp    8010559c <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
8010555f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105562:	89 c2                	mov    %eax,%edx
80105564:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010556a:	8b 00                	mov    (%eax),%eax
8010556c:	39 c2                	cmp    %eax,%edx
8010556e:	73 16                	jae    80105586 <argptr+0x4a>
80105570:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105573:	89 c2                	mov    %eax,%edx
80105575:	8b 45 10             	mov    0x10(%ebp),%eax
80105578:	01 c2                	add    %eax,%edx
8010557a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105580:	8b 00                	mov    (%eax),%eax
80105582:	39 c2                	cmp    %eax,%edx
80105584:	76 07                	jbe    8010558d <argptr+0x51>
    return -1;
80105586:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010558b:	eb 0f                	jmp    8010559c <argptr+0x60>
  *pp = (char*)i;
8010558d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105590:	89 c2                	mov    %eax,%edx
80105592:	8b 45 0c             	mov    0xc(%ebp),%eax
80105595:	89 10                	mov    %edx,(%eax)
  return 0;
80105597:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010559c:	c9                   	leave  
8010559d:	c3                   	ret    

8010559e <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010559e:	55                   	push   %ebp
8010559f:	89 e5                	mov    %esp,%ebp
801055a1:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  if(argint(n, &addr) < 0)
801055a4:	8d 45 fc             	lea    -0x4(%ebp),%eax
801055a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801055ab:	8b 45 08             	mov    0x8(%ebp),%eax
801055ae:	89 04 24             	mov    %eax,(%esp)
801055b1:	e8 4e ff ff ff       	call   80105504 <argint>
801055b6:	85 c0                	test   %eax,%eax
801055b8:	79 07                	jns    801055c1 <argstr+0x23>
    return -1;
801055ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055bf:	eb 1e                	jmp    801055df <argstr+0x41>
  return fetchstr(proc, addr, pp);
801055c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055c4:	89 c2                	mov    %eax,%edx
801055c6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801055cf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801055d3:	89 54 24 04          	mov    %edx,0x4(%esp)
801055d7:	89 04 24             	mov    %eax,(%esp)
801055da:	e8 c9 fe ff ff       	call   801054a8 <fetchstr>
}
801055df:	c9                   	leave  
801055e0:	c3                   	ret    

801055e1 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
801055e1:	55                   	push   %ebp
801055e2:	89 e5                	mov    %esp,%ebp
801055e4:	53                   	push   %ebx
801055e5:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
801055e8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055ee:	8b 40 18             	mov    0x18(%eax),%eax
801055f1:	8b 40 1c             	mov    0x1c(%eax),%eax
801055f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num >= 0 && num < SYS_open && syscalls[num]) {
801055f7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801055fb:	78 2e                	js     8010562b <syscall+0x4a>
801055fd:	83 7d f4 10          	cmpl   $0x10,-0xc(%ebp)
80105601:	7f 28                	jg     8010562b <syscall+0x4a>
80105603:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105606:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
8010560d:	85 c0                	test   %eax,%eax
8010560f:	74 1a                	je     8010562b <syscall+0x4a>
    proc->tf->eax = syscalls[num]();
80105611:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105617:	8b 58 18             	mov    0x18(%eax),%ebx
8010561a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010561d:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105624:	ff d0                	call   *%eax
80105626:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105629:	eb 73                	jmp    8010569e <syscall+0xbd>
  } else if (num >= SYS_open && num < NELEM(syscalls) && syscalls[num]) {
8010562b:	83 7d f4 10          	cmpl   $0x10,-0xc(%ebp)
8010562f:	7e 30                	jle    80105661 <syscall+0x80>
80105631:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105634:	83 f8 17             	cmp    $0x17,%eax
80105637:	77 28                	ja     80105661 <syscall+0x80>
80105639:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010563c:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105643:	85 c0                	test   %eax,%eax
80105645:	74 1a                	je     80105661 <syscall+0x80>
    proc->tf->eax = syscalls[num]();
80105647:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010564d:	8b 58 18             	mov    0x18(%eax),%ebx
80105650:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105653:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
8010565a:	ff d0                	call   *%eax
8010565c:	89 43 1c             	mov    %eax,0x1c(%ebx)
8010565f:	eb 3d                	jmp    8010569e <syscall+0xbd>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105661:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105667:	8d 48 6c             	lea    0x6c(%eax),%ecx
8010566a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  if(num >= 0 && num < SYS_open && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else if (num >= SYS_open && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105670:	8b 40 10             	mov    0x10(%eax),%eax
80105673:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105676:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010567a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010567e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105682:	c7 04 24 79 8e 10 80 	movl   $0x80108e79,(%esp)
80105689:	e8 12 ad ff ff       	call   801003a0 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
8010568e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105694:	8b 40 18             	mov    0x18(%eax),%eax
80105697:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
8010569e:	83 c4 24             	add    $0x24,%esp
801056a1:	5b                   	pop    %ebx
801056a2:	5d                   	pop    %ebp
801056a3:	c3                   	ret    

801056a4 <argfd>:
801056a4:	55                   	push   %ebp
801056a5:	89 e5                	mov    %esp,%ebp
801056a7:	83 ec 28             	sub    $0x28,%esp
801056aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
801056ad:	89 44 24 04          	mov    %eax,0x4(%esp)
801056b1:	8b 45 08             	mov    0x8(%ebp),%eax
801056b4:	89 04 24             	mov    %eax,(%esp)
801056b7:	e8 48 fe ff ff       	call   80105504 <argint>
801056bc:	85 c0                	test   %eax,%eax
801056be:	79 07                	jns    801056c7 <argfd+0x23>
801056c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056c5:	eb 50                	jmp    80105717 <argfd+0x73>
801056c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056ca:	85 c0                	test   %eax,%eax
801056cc:	78 21                	js     801056ef <argfd+0x4b>
801056ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056d1:	83 f8 0f             	cmp    $0xf,%eax
801056d4:	7f 19                	jg     801056ef <argfd+0x4b>
801056d6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056dc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801056df:	83 c2 08             	add    $0x8,%edx
801056e2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801056e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056ed:	75 07                	jne    801056f6 <argfd+0x52>
801056ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056f4:	eb 21                	jmp    80105717 <argfd+0x73>
801056f6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801056fa:	74 08                	je     80105704 <argfd+0x60>
801056fc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801056ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80105702:	89 10                	mov    %edx,(%eax)
80105704:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105708:	74 08                	je     80105712 <argfd+0x6e>
8010570a:	8b 45 10             	mov    0x10(%ebp),%eax
8010570d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105710:	89 10                	mov    %edx,(%eax)
80105712:	b8 00 00 00 00       	mov    $0x0,%eax
80105717:	c9                   	leave  
80105718:	c3                   	ret    

80105719 <fdalloc>:
80105719:	55                   	push   %ebp
8010571a:	89 e5                	mov    %esp,%ebp
8010571c:	83 ec 10             	sub    $0x10,%esp
8010571f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105726:	eb 30                	jmp    80105758 <fdalloc+0x3f>
80105728:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010572e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105731:	83 c2 08             	add    $0x8,%edx
80105734:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105738:	85 c0                	test   %eax,%eax
8010573a:	75 18                	jne    80105754 <fdalloc+0x3b>
8010573c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105742:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105745:	8d 4a 08             	lea    0x8(%edx),%ecx
80105748:	8b 55 08             	mov    0x8(%ebp),%edx
8010574b:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
8010574f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105752:	eb 0f                	jmp    80105763 <fdalloc+0x4a>
80105754:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105758:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
8010575c:	7e ca                	jle    80105728 <fdalloc+0xf>
8010575e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105763:	c9                   	leave  
80105764:	c3                   	ret    

80105765 <sys_dup>:
80105765:	55                   	push   %ebp
80105766:	89 e5                	mov    %esp,%ebp
80105768:	83 ec 28             	sub    $0x28,%esp
8010576b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010576e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105772:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105779:	00 
8010577a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105781:	e8 1e ff ff ff       	call   801056a4 <argfd>
80105786:	85 c0                	test   %eax,%eax
80105788:	79 07                	jns    80105791 <sys_dup+0x2c>
8010578a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010578f:	eb 29                	jmp    801057ba <sys_dup+0x55>
80105791:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105794:	89 04 24             	mov    %eax,(%esp)
80105797:	e8 7d ff ff ff       	call   80105719 <fdalloc>
8010579c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010579f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057a3:	79 07                	jns    801057ac <sys_dup+0x47>
801057a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057aa:	eb 0e                	jmp    801057ba <sys_dup+0x55>
801057ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057af:	89 04 24             	mov    %eax,(%esp)
801057b2:	e8 ee b7 ff ff       	call   80100fa5 <filedup>
801057b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057ba:	c9                   	leave  
801057bb:	c3                   	ret    

801057bc <sys_read>:
801057bc:	55                   	push   %ebp
801057bd:	89 e5                	mov    %esp,%ebp
801057bf:	83 ec 28             	sub    $0x28,%esp
801057c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801057c5:	89 44 24 08          	mov    %eax,0x8(%esp)
801057c9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801057d0:	00 
801057d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801057d8:	e8 c7 fe ff ff       	call   801056a4 <argfd>
801057dd:	85 c0                	test   %eax,%eax
801057df:	78 35                	js     80105816 <sys_read+0x5a>
801057e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057e4:	89 44 24 04          	mov    %eax,0x4(%esp)
801057e8:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801057ef:	e8 10 fd ff ff       	call   80105504 <argint>
801057f4:	85 c0                	test   %eax,%eax
801057f6:	78 1e                	js     80105816 <sys_read+0x5a>
801057f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057fb:	89 44 24 08          	mov    %eax,0x8(%esp)
801057ff:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105802:	89 44 24 04          	mov    %eax,0x4(%esp)
80105806:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010580d:	e8 2a fd ff ff       	call   8010553c <argptr>
80105812:	85 c0                	test   %eax,%eax
80105814:	79 07                	jns    8010581d <sys_read+0x61>
80105816:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010581b:	eb 19                	jmp    80105836 <sys_read+0x7a>
8010581d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105820:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105823:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105826:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010582a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010582e:	89 04 24             	mov    %eax,(%esp)
80105831:	e8 dc b8 ff ff       	call   80101112 <fileread>
80105836:	c9                   	leave  
80105837:	c3                   	ret    

80105838 <sys_write>:
80105838:	55                   	push   %ebp
80105839:	89 e5                	mov    %esp,%ebp
8010583b:	83 ec 28             	sub    $0x28,%esp
8010583e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105841:	89 44 24 08          	mov    %eax,0x8(%esp)
80105845:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010584c:	00 
8010584d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105854:	e8 4b fe ff ff       	call   801056a4 <argfd>
80105859:	85 c0                	test   %eax,%eax
8010585b:	78 35                	js     80105892 <sys_write+0x5a>
8010585d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105860:	89 44 24 04          	mov    %eax,0x4(%esp)
80105864:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010586b:	e8 94 fc ff ff       	call   80105504 <argint>
80105870:	85 c0                	test   %eax,%eax
80105872:	78 1e                	js     80105892 <sys_write+0x5a>
80105874:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105877:	89 44 24 08          	mov    %eax,0x8(%esp)
8010587b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010587e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105882:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105889:	e8 ae fc ff ff       	call   8010553c <argptr>
8010588e:	85 c0                	test   %eax,%eax
80105890:	79 07                	jns    80105899 <sys_write+0x61>
80105892:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105897:	eb 19                	jmp    801058b2 <sys_write+0x7a>
80105899:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010589c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010589f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058a2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801058a6:	89 54 24 04          	mov    %edx,0x4(%esp)
801058aa:	89 04 24             	mov    %eax,(%esp)
801058ad:	e8 1c b9 ff ff       	call   801011ce <filewrite>
801058b2:	c9                   	leave  
801058b3:	c3                   	ret    

801058b4 <sys_close>:
801058b4:	55                   	push   %ebp
801058b5:	89 e5                	mov    %esp,%ebp
801058b7:	83 ec 28             	sub    $0x28,%esp
801058ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058bd:	89 44 24 08          	mov    %eax,0x8(%esp)
801058c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058c4:	89 44 24 04          	mov    %eax,0x4(%esp)
801058c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801058cf:	e8 d0 fd ff ff       	call   801056a4 <argfd>
801058d4:	85 c0                	test   %eax,%eax
801058d6:	79 07                	jns    801058df <sys_close+0x2b>
801058d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058dd:	eb 24                	jmp    80105903 <sys_close+0x4f>
801058df:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058e8:	83 c2 08             	add    $0x8,%edx
801058eb:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801058f2:	00 
801058f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058f6:	89 04 24             	mov    %eax,(%esp)
801058f9:	e8 ef b6 ff ff       	call   80100fed <fileclose>
801058fe:	b8 00 00 00 00       	mov    $0x0,%eax
80105903:	c9                   	leave  
80105904:	c3                   	ret    

80105905 <sys_fstat>:
80105905:	55                   	push   %ebp
80105906:	89 e5                	mov    %esp,%ebp
80105908:	83 ec 28             	sub    $0x28,%esp
8010590b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010590e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105912:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105919:	00 
8010591a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105921:	e8 7e fd ff ff       	call   801056a4 <argfd>
80105926:	85 c0                	test   %eax,%eax
80105928:	78 1f                	js     80105949 <sys_fstat+0x44>
8010592a:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105931:	00 
80105932:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105935:	89 44 24 04          	mov    %eax,0x4(%esp)
80105939:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105940:	e8 f7 fb ff ff       	call   8010553c <argptr>
80105945:	85 c0                	test   %eax,%eax
80105947:	79 07                	jns    80105950 <sys_fstat+0x4b>
80105949:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010594e:	eb 12                	jmp    80105962 <sys_fstat+0x5d>
80105950:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105953:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105956:	89 54 24 04          	mov    %edx,0x4(%esp)
8010595a:	89 04 24             	mov    %eax,(%esp)
8010595d:	e8 61 b7 ff ff       	call   801010c3 <filestat>
80105962:	c9                   	leave  
80105963:	c3                   	ret    

80105964 <sys_link>:
80105964:	55                   	push   %ebp
80105965:	89 e5                	mov    %esp,%ebp
80105967:	83 ec 38             	sub    $0x38,%esp
8010596a:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010596d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105971:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105978:	e8 21 fc ff ff       	call   8010559e <argstr>
8010597d:	85 c0                	test   %eax,%eax
8010597f:	78 17                	js     80105998 <sys_link+0x34>
80105981:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105984:	89 44 24 04          	mov    %eax,0x4(%esp)
80105988:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010598f:	e8 0a fc ff ff       	call   8010559e <argstr>
80105994:	85 c0                	test   %eax,%eax
80105996:	79 0a                	jns    801059a2 <sys_link+0x3e>
80105998:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010599d:	e9 3d 01 00 00       	jmp    80105adf <sys_link+0x17b>
801059a2:	8b 45 d8             	mov    -0x28(%ebp),%eax
801059a5:	89 04 24             	mov    %eax,(%esp)
801059a8:	e8 78 ca ff ff       	call   80102425 <namei>
801059ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
801059b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801059b4:	75 0a                	jne    801059c0 <sys_link+0x5c>
801059b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059bb:	e9 1f 01 00 00       	jmp    80105adf <sys_link+0x17b>
801059c0:	e8 3f d8 ff ff       	call   80103204 <begin_trans>
801059c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059c8:	89 04 24             	mov    %eax,(%esp)
801059cb:	e8 aa be ff ff       	call   8010187a <ilock>
801059d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059d3:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801059d7:	66 83 f8 01          	cmp    $0x1,%ax
801059db:	75 1a                	jne    801059f7 <sys_link+0x93>
801059dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059e0:	89 04 24             	mov    %eax,(%esp)
801059e3:	e8 16 c1 ff ff       	call   80101afe <iunlockput>
801059e8:	e8 60 d8 ff ff       	call   8010324d <commit_trans>
801059ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059f2:	e9 e8 00 00 00       	jmp    80105adf <sys_link+0x17b>
801059f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059fa:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801059fe:	8d 50 01             	lea    0x1(%eax),%edx
80105a01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a04:	66 89 50 16          	mov    %dx,0x16(%eax)
80105a08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a0b:	89 04 24             	mov    %eax,(%esp)
80105a0e:	e8 ab bc ff ff       	call   801016be <iupdate>
80105a13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a16:	89 04 24             	mov    %eax,(%esp)
80105a19:	e8 aa bf ff ff       	call   801019c8 <iunlock>
80105a1e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105a21:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105a24:	89 54 24 04          	mov    %edx,0x4(%esp)
80105a28:	89 04 24             	mov    %eax,(%esp)
80105a2b:	e8 17 ca ff ff       	call   80102447 <nameiparent>
80105a30:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105a33:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a37:	75 02                	jne    80105a3b <sys_link+0xd7>
80105a39:	eb 68                	jmp    80105aa3 <sys_link+0x13f>
80105a3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a3e:	89 04 24             	mov    %eax,(%esp)
80105a41:	e8 34 be ff ff       	call   8010187a <ilock>
80105a46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a49:	8b 10                	mov    (%eax),%edx
80105a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a4e:	8b 00                	mov    (%eax),%eax
80105a50:	39 c2                	cmp    %eax,%edx
80105a52:	75 20                	jne    80105a74 <sys_link+0x110>
80105a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a57:	8b 40 04             	mov    0x4(%eax),%eax
80105a5a:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a5e:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105a61:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a68:	89 04 24             	mov    %eax,(%esp)
80105a6b:	e8 f5 c6 ff ff       	call   80102165 <dirlink>
80105a70:	85 c0                	test   %eax,%eax
80105a72:	79 0d                	jns    80105a81 <sys_link+0x11d>
80105a74:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a77:	89 04 24             	mov    %eax,(%esp)
80105a7a:	e8 7f c0 ff ff       	call   80101afe <iunlockput>
80105a7f:	eb 22                	jmp    80105aa3 <sys_link+0x13f>
80105a81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a84:	89 04 24             	mov    %eax,(%esp)
80105a87:	e8 72 c0 ff ff       	call   80101afe <iunlockput>
80105a8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a8f:	89 04 24             	mov    %eax,(%esp)
80105a92:	e8 96 bf ff ff       	call   80101a2d <iput>
80105a97:	e8 b1 d7 ff ff       	call   8010324d <commit_trans>
80105a9c:	b8 00 00 00 00       	mov    $0x0,%eax
80105aa1:	eb 3c                	jmp    80105adf <sys_link+0x17b>
80105aa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aa6:	89 04 24             	mov    %eax,(%esp)
80105aa9:	e8 cc bd ff ff       	call   8010187a <ilock>
80105aae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ab1:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105ab5:	8d 50 ff             	lea    -0x1(%eax),%edx
80105ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105abb:	66 89 50 16          	mov    %dx,0x16(%eax)
80105abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ac2:	89 04 24             	mov    %eax,(%esp)
80105ac5:	e8 f4 bb ff ff       	call   801016be <iupdate>
80105aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105acd:	89 04 24             	mov    %eax,(%esp)
80105ad0:	e8 29 c0 ff ff       	call   80101afe <iunlockput>
80105ad5:	e8 73 d7 ff ff       	call   8010324d <commit_trans>
80105ada:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105adf:	c9                   	leave  
80105ae0:	c3                   	ret    

80105ae1 <isdirempty>:
80105ae1:	55                   	push   %ebp
80105ae2:	89 e5                	mov    %esp,%ebp
80105ae4:	83 ec 38             	sub    $0x38,%esp
80105ae7:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105aee:	eb 4b                	jmp    80105b3b <isdirempty+0x5a>
80105af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105af3:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105afa:	00 
80105afb:	89 44 24 08          	mov    %eax,0x8(%esp)
80105aff:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105b02:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b06:	8b 45 08             	mov    0x8(%ebp),%eax
80105b09:	89 04 24             	mov    %eax,(%esp)
80105b0c:	e8 76 c2 ff ff       	call   80101d87 <readi>
80105b11:	83 f8 10             	cmp    $0x10,%eax
80105b14:	74 0c                	je     80105b22 <isdirempty+0x41>
80105b16:	c7 04 24 95 8e 10 80 	movl   $0x80108e95,(%esp)
80105b1d:	e8 18 aa ff ff       	call   8010053a <panic>
80105b22:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105b26:	66 85 c0             	test   %ax,%ax
80105b29:	74 07                	je     80105b32 <isdirempty+0x51>
80105b2b:	b8 00 00 00 00       	mov    $0x0,%eax
80105b30:	eb 1b                	jmp    80105b4d <isdirempty+0x6c>
80105b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b35:	83 c0 10             	add    $0x10,%eax
80105b38:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b3b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b3e:	8b 45 08             	mov    0x8(%ebp),%eax
80105b41:	8b 40 18             	mov    0x18(%eax),%eax
80105b44:	39 c2                	cmp    %eax,%edx
80105b46:	72 a8                	jb     80105af0 <isdirempty+0xf>
80105b48:	b8 01 00 00 00       	mov    $0x1,%eax
80105b4d:	c9                   	leave  
80105b4e:	c3                   	ret    

80105b4f <sys_unlink>:
80105b4f:	55                   	push   %ebp
80105b50:	89 e5                	mov    %esp,%ebp
80105b52:	83 ec 48             	sub    $0x48,%esp
80105b55:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105b58:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b5c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105b63:	e8 36 fa ff ff       	call   8010559e <argstr>
80105b68:	85 c0                	test   %eax,%eax
80105b6a:	79 0a                	jns    80105b76 <sys_unlink+0x27>
80105b6c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b71:	e9 aa 01 00 00       	jmp    80105d20 <sys_unlink+0x1d1>
80105b76:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105b79:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105b7c:	89 54 24 04          	mov    %edx,0x4(%esp)
80105b80:	89 04 24             	mov    %eax,(%esp)
80105b83:	e8 bf c8 ff ff       	call   80102447 <nameiparent>
80105b88:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b8b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b8f:	75 0a                	jne    80105b9b <sys_unlink+0x4c>
80105b91:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b96:	e9 85 01 00 00       	jmp    80105d20 <sys_unlink+0x1d1>
80105b9b:	e8 64 d6 ff ff       	call   80103204 <begin_trans>
80105ba0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ba3:	89 04 24             	mov    %eax,(%esp)
80105ba6:	e8 cf bc ff ff       	call   8010187a <ilock>
80105bab:	c7 44 24 04 a7 8e 10 	movl   $0x80108ea7,0x4(%esp)
80105bb2:	80 
80105bb3:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105bb6:	89 04 24             	mov    %eax,(%esp)
80105bb9:	e8 bc c4 ff ff       	call   8010207a <namecmp>
80105bbe:	85 c0                	test   %eax,%eax
80105bc0:	0f 84 45 01 00 00    	je     80105d0b <sys_unlink+0x1bc>
80105bc6:	c7 44 24 04 a9 8e 10 	movl   $0x80108ea9,0x4(%esp)
80105bcd:	80 
80105bce:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105bd1:	89 04 24             	mov    %eax,(%esp)
80105bd4:	e8 a1 c4 ff ff       	call   8010207a <namecmp>
80105bd9:	85 c0                	test   %eax,%eax
80105bdb:	0f 84 2a 01 00 00    	je     80105d0b <sys_unlink+0x1bc>
80105be1:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105be4:	89 44 24 08          	mov    %eax,0x8(%esp)
80105be8:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105beb:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bf2:	89 04 24             	mov    %eax,(%esp)
80105bf5:	e8 a2 c4 ff ff       	call   8010209c <dirlookup>
80105bfa:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105bfd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c01:	75 05                	jne    80105c08 <sys_unlink+0xb9>
80105c03:	e9 03 01 00 00       	jmp    80105d0b <sys_unlink+0x1bc>
80105c08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c0b:	89 04 24             	mov    %eax,(%esp)
80105c0e:	e8 67 bc ff ff       	call   8010187a <ilock>
80105c13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c16:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105c1a:	66 85 c0             	test   %ax,%ax
80105c1d:	7f 0c                	jg     80105c2b <sys_unlink+0xdc>
80105c1f:	c7 04 24 ac 8e 10 80 	movl   $0x80108eac,(%esp)
80105c26:	e8 0f a9 ff ff       	call   8010053a <panic>
80105c2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c2e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105c32:	66 83 f8 01          	cmp    $0x1,%ax
80105c36:	75 1f                	jne    80105c57 <sys_unlink+0x108>
80105c38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c3b:	89 04 24             	mov    %eax,(%esp)
80105c3e:	e8 9e fe ff ff       	call   80105ae1 <isdirempty>
80105c43:	85 c0                	test   %eax,%eax
80105c45:	75 10                	jne    80105c57 <sys_unlink+0x108>
80105c47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c4a:	89 04 24             	mov    %eax,(%esp)
80105c4d:	e8 ac be ff ff       	call   80101afe <iunlockput>
80105c52:	e9 b4 00 00 00       	jmp    80105d0b <sys_unlink+0x1bc>
80105c57:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105c5e:	00 
80105c5f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105c66:	00 
80105c67:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105c6a:	89 04 24             	mov    %eax,(%esp)
80105c6d:	e8 5c f5 ff ff       	call   801051ce <memset>
80105c72:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105c75:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105c7c:	00 
80105c7d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c81:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105c84:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c8b:	89 04 24             	mov    %eax,(%esp)
80105c8e:	e8 58 c2 ff ff       	call   80101eeb <writei>
80105c93:	83 f8 10             	cmp    $0x10,%eax
80105c96:	74 0c                	je     80105ca4 <sys_unlink+0x155>
80105c98:	c7 04 24 be 8e 10 80 	movl   $0x80108ebe,(%esp)
80105c9f:	e8 96 a8 ff ff       	call   8010053a <panic>
80105ca4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ca7:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105cab:	66 83 f8 01          	cmp    $0x1,%ax
80105caf:	75 1c                	jne    80105ccd <sys_unlink+0x17e>
80105cb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cb4:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105cb8:	8d 50 ff             	lea    -0x1(%eax),%edx
80105cbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cbe:	66 89 50 16          	mov    %dx,0x16(%eax)
80105cc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cc5:	89 04 24             	mov    %eax,(%esp)
80105cc8:	e8 f1 b9 ff ff       	call   801016be <iupdate>
80105ccd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cd0:	89 04 24             	mov    %eax,(%esp)
80105cd3:	e8 26 be ff ff       	call   80101afe <iunlockput>
80105cd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cdb:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105cdf:	8d 50 ff             	lea    -0x1(%eax),%edx
80105ce2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ce5:	66 89 50 16          	mov    %dx,0x16(%eax)
80105ce9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cec:	89 04 24             	mov    %eax,(%esp)
80105cef:	e8 ca b9 ff ff       	call   801016be <iupdate>
80105cf4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cf7:	89 04 24             	mov    %eax,(%esp)
80105cfa:	e8 ff bd ff ff       	call   80101afe <iunlockput>
80105cff:	e8 49 d5 ff ff       	call   8010324d <commit_trans>
80105d04:	b8 00 00 00 00       	mov    $0x0,%eax
80105d09:	eb 15                	jmp    80105d20 <sys_unlink+0x1d1>
80105d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d0e:	89 04 24             	mov    %eax,(%esp)
80105d11:	e8 e8 bd ff ff       	call   80101afe <iunlockput>
80105d16:	e8 32 d5 ff ff       	call   8010324d <commit_trans>
80105d1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d20:	c9                   	leave  
80105d21:	c3                   	ret    

80105d22 <create>:
80105d22:	55                   	push   %ebp
80105d23:	89 e5                	mov    %esp,%ebp
80105d25:	83 ec 48             	sub    $0x48,%esp
80105d28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105d2b:	8b 55 10             	mov    0x10(%ebp),%edx
80105d2e:	8b 45 14             	mov    0x14(%ebp),%eax
80105d31:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105d35:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105d39:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
80105d3d:	8d 45 de             	lea    -0x22(%ebp),%eax
80105d40:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d44:	8b 45 08             	mov    0x8(%ebp),%eax
80105d47:	89 04 24             	mov    %eax,(%esp)
80105d4a:	e8 f8 c6 ff ff       	call   80102447 <nameiparent>
80105d4f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d52:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d56:	75 0a                	jne    80105d62 <create+0x40>
80105d58:	b8 00 00 00 00       	mov    $0x0,%eax
80105d5d:	e9 7e 01 00 00       	jmp    80105ee0 <create+0x1be>
80105d62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d65:	89 04 24             	mov    %eax,(%esp)
80105d68:	e8 0d bb ff ff       	call   8010187a <ilock>
80105d6d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d70:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d74:	8d 45 de             	lea    -0x22(%ebp),%eax
80105d77:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d7e:	89 04 24             	mov    %eax,(%esp)
80105d81:	e8 16 c3 ff ff       	call   8010209c <dirlookup>
80105d86:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d89:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d8d:	74 47                	je     80105dd6 <create+0xb4>
80105d8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d92:	89 04 24             	mov    %eax,(%esp)
80105d95:	e8 64 bd ff ff       	call   80101afe <iunlockput>
80105d9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d9d:	89 04 24             	mov    %eax,(%esp)
80105da0:	e8 d5 ba ff ff       	call   8010187a <ilock>
80105da5:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105daa:	75 15                	jne    80105dc1 <create+0x9f>
80105dac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105daf:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105db3:	66 83 f8 02          	cmp    $0x2,%ax
80105db7:	75 08                	jne    80105dc1 <create+0x9f>
80105db9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dbc:	e9 1f 01 00 00       	jmp    80105ee0 <create+0x1be>
80105dc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dc4:	89 04 24             	mov    %eax,(%esp)
80105dc7:	e8 32 bd ff ff       	call   80101afe <iunlockput>
80105dcc:	b8 00 00 00 00       	mov    $0x0,%eax
80105dd1:	e9 0a 01 00 00       	jmp    80105ee0 <create+0x1be>
80105dd6:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105dda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ddd:	8b 00                	mov    (%eax),%eax
80105ddf:	89 54 24 04          	mov    %edx,0x4(%esp)
80105de3:	89 04 24             	mov    %eax,(%esp)
80105de6:	e8 f4 b7 ff ff       	call   801015df <ialloc>
80105deb:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105dee:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105df2:	75 0c                	jne    80105e00 <create+0xde>
80105df4:	c7 04 24 cd 8e 10 80 	movl   $0x80108ecd,(%esp)
80105dfb:	e8 3a a7 ff ff       	call   8010053a <panic>
80105e00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e03:	89 04 24             	mov    %eax,(%esp)
80105e06:	e8 6f ba ff ff       	call   8010187a <ilock>
80105e0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e0e:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105e12:	66 89 50 12          	mov    %dx,0x12(%eax)
80105e16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e19:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105e1d:	66 89 50 14          	mov    %dx,0x14(%eax)
80105e21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e24:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
80105e2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e2d:	89 04 24             	mov    %eax,(%esp)
80105e30:	e8 89 b8 ff ff       	call   801016be <iupdate>
80105e35:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105e3a:	75 6a                	jne    80105ea6 <create+0x184>
80105e3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e3f:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105e43:	8d 50 01             	lea    0x1(%eax),%edx
80105e46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e49:	66 89 50 16          	mov    %dx,0x16(%eax)
80105e4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e50:	89 04 24             	mov    %eax,(%esp)
80105e53:	e8 66 b8 ff ff       	call   801016be <iupdate>
80105e58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e5b:	8b 40 04             	mov    0x4(%eax),%eax
80105e5e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e62:	c7 44 24 04 a7 8e 10 	movl   $0x80108ea7,0x4(%esp)
80105e69:	80 
80105e6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e6d:	89 04 24             	mov    %eax,(%esp)
80105e70:	e8 f0 c2 ff ff       	call   80102165 <dirlink>
80105e75:	85 c0                	test   %eax,%eax
80105e77:	78 21                	js     80105e9a <create+0x178>
80105e79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e7c:	8b 40 04             	mov    0x4(%eax),%eax
80105e7f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e83:	c7 44 24 04 a9 8e 10 	movl   $0x80108ea9,0x4(%esp)
80105e8a:	80 
80105e8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e8e:	89 04 24             	mov    %eax,(%esp)
80105e91:	e8 cf c2 ff ff       	call   80102165 <dirlink>
80105e96:	85 c0                	test   %eax,%eax
80105e98:	79 0c                	jns    80105ea6 <create+0x184>
80105e9a:	c7 04 24 dc 8e 10 80 	movl   $0x80108edc,(%esp)
80105ea1:	e8 94 a6 ff ff       	call   8010053a <panic>
80105ea6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ea9:	8b 40 04             	mov    0x4(%eax),%eax
80105eac:	89 44 24 08          	mov    %eax,0x8(%esp)
80105eb0:	8d 45 de             	lea    -0x22(%ebp),%eax
80105eb3:	89 44 24 04          	mov    %eax,0x4(%esp)
80105eb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eba:	89 04 24             	mov    %eax,(%esp)
80105ebd:	e8 a3 c2 ff ff       	call   80102165 <dirlink>
80105ec2:	85 c0                	test   %eax,%eax
80105ec4:	79 0c                	jns    80105ed2 <create+0x1b0>
80105ec6:	c7 04 24 e8 8e 10 80 	movl   $0x80108ee8,(%esp)
80105ecd:	e8 68 a6 ff ff       	call   8010053a <panic>
80105ed2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ed5:	89 04 24             	mov    %eax,(%esp)
80105ed8:	e8 21 bc ff ff       	call   80101afe <iunlockput>
80105edd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ee0:	c9                   	leave  
80105ee1:	c3                   	ret    

80105ee2 <sys_open>:
80105ee2:	55                   	push   %ebp
80105ee3:	89 e5                	mov    %esp,%ebp
80105ee5:	83 ec 38             	sub    $0x38,%esp
80105ee8:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105eeb:	89 44 24 04          	mov    %eax,0x4(%esp)
80105eef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ef6:	e8 a3 f6 ff ff       	call   8010559e <argstr>
80105efb:	85 c0                	test   %eax,%eax
80105efd:	78 17                	js     80105f16 <sys_open+0x34>
80105eff:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f02:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f06:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105f0d:	e8 f2 f5 ff ff       	call   80105504 <argint>
80105f12:	85 c0                	test   %eax,%eax
80105f14:	79 0a                	jns    80105f20 <sys_open+0x3e>
80105f16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f1b:	e9 48 01 00 00       	jmp    80106068 <sys_open+0x186>
80105f20:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f23:	25 00 02 00 00       	and    $0x200,%eax
80105f28:	85 c0                	test   %eax,%eax
80105f2a:	74 40                	je     80105f6c <sys_open+0x8a>
80105f2c:	e8 d3 d2 ff ff       	call   80103204 <begin_trans>
80105f31:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f34:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105f3b:	00 
80105f3c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105f43:	00 
80105f44:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80105f4b:	00 
80105f4c:	89 04 24             	mov    %eax,(%esp)
80105f4f:	e8 ce fd ff ff       	call   80105d22 <create>
80105f54:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f57:	e8 f1 d2 ff ff       	call   8010324d <commit_trans>
80105f5c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f60:	75 5c                	jne    80105fbe <sys_open+0xdc>
80105f62:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f67:	e9 fc 00 00 00       	jmp    80106068 <sys_open+0x186>
80105f6c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f6f:	89 04 24             	mov    %eax,(%esp)
80105f72:	e8 ae c4 ff ff       	call   80102425 <namei>
80105f77:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f7a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f7e:	75 0a                	jne    80105f8a <sys_open+0xa8>
80105f80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f85:	e9 de 00 00 00       	jmp    80106068 <sys_open+0x186>
80105f8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f8d:	89 04 24             	mov    %eax,(%esp)
80105f90:	e8 e5 b8 ff ff       	call   8010187a <ilock>
80105f95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f98:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105f9c:	66 83 f8 01          	cmp    $0x1,%ax
80105fa0:	75 1c                	jne    80105fbe <sys_open+0xdc>
80105fa2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fa5:	85 c0                	test   %eax,%eax
80105fa7:	74 15                	je     80105fbe <sys_open+0xdc>
80105fa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fac:	89 04 24             	mov    %eax,(%esp)
80105faf:	e8 4a bb ff ff       	call   80101afe <iunlockput>
80105fb4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fb9:	e9 aa 00 00 00       	jmp    80106068 <sys_open+0x186>
80105fbe:	e8 82 af ff ff       	call   80100f45 <filealloc>
80105fc3:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105fc6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fca:	74 14                	je     80105fe0 <sys_open+0xfe>
80105fcc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fcf:	89 04 24             	mov    %eax,(%esp)
80105fd2:	e8 42 f7 ff ff       	call   80105719 <fdalloc>
80105fd7:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105fda:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105fde:	79 23                	jns    80106003 <sys_open+0x121>
80105fe0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fe4:	74 0b                	je     80105ff1 <sys_open+0x10f>
80105fe6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fe9:	89 04 24             	mov    %eax,(%esp)
80105fec:	e8 fc af ff ff       	call   80100fed <fileclose>
80105ff1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ff4:	89 04 24             	mov    %eax,(%esp)
80105ff7:	e8 02 bb ff ff       	call   80101afe <iunlockput>
80105ffc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106001:	eb 65                	jmp    80106068 <sys_open+0x186>
80106003:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106006:	89 04 24             	mov    %eax,(%esp)
80106009:	e8 ba b9 ff ff       	call   801019c8 <iunlock>
8010600e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106011:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
80106017:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010601a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010601d:	89 50 10             	mov    %edx,0x10(%eax)
80106020:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106023:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
8010602a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010602d:	83 e0 01             	and    $0x1,%eax
80106030:	85 c0                	test   %eax,%eax
80106032:	0f 94 c0             	sete   %al
80106035:	89 c2                	mov    %eax,%edx
80106037:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010603a:	88 50 08             	mov    %dl,0x8(%eax)
8010603d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106040:	83 e0 01             	and    $0x1,%eax
80106043:	85 c0                	test   %eax,%eax
80106045:	75 0a                	jne    80106051 <sys_open+0x16f>
80106047:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010604a:	83 e0 02             	and    $0x2,%eax
8010604d:	85 c0                	test   %eax,%eax
8010604f:	74 07                	je     80106058 <sys_open+0x176>
80106051:	b8 01 00 00 00       	mov    $0x1,%eax
80106056:	eb 05                	jmp    8010605d <sys_open+0x17b>
80106058:	b8 00 00 00 00       	mov    $0x0,%eax
8010605d:	89 c2                	mov    %eax,%edx
8010605f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106062:	88 50 09             	mov    %dl,0x9(%eax)
80106065:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106068:	c9                   	leave  
80106069:	c3                   	ret    

8010606a <sys_mkdir>:
8010606a:	55                   	push   %ebp
8010606b:	89 e5                	mov    %esp,%ebp
8010606d:	83 ec 28             	sub    $0x28,%esp
80106070:	e8 8f d1 ff ff       	call   80103204 <begin_trans>
80106075:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106078:	89 44 24 04          	mov    %eax,0x4(%esp)
8010607c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106083:	e8 16 f5 ff ff       	call   8010559e <argstr>
80106088:	85 c0                	test   %eax,%eax
8010608a:	78 2c                	js     801060b8 <sys_mkdir+0x4e>
8010608c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010608f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106096:	00 
80106097:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010609e:	00 
8010609f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801060a6:	00 
801060a7:	89 04 24             	mov    %eax,(%esp)
801060aa:	e8 73 fc ff ff       	call   80105d22 <create>
801060af:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060b2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060b6:	75 0c                	jne    801060c4 <sys_mkdir+0x5a>
801060b8:	e8 90 d1 ff ff       	call   8010324d <commit_trans>
801060bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060c2:	eb 15                	jmp    801060d9 <sys_mkdir+0x6f>
801060c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060c7:	89 04 24             	mov    %eax,(%esp)
801060ca:	e8 2f ba ff ff       	call   80101afe <iunlockput>
801060cf:	e8 79 d1 ff ff       	call   8010324d <commit_trans>
801060d4:	b8 00 00 00 00       	mov    $0x0,%eax
801060d9:	c9                   	leave  
801060da:	c3                   	ret    

801060db <sys_mknod>:
801060db:	55                   	push   %ebp
801060dc:	89 e5                	mov    %esp,%ebp
801060de:	83 ec 38             	sub    $0x38,%esp
801060e1:	e8 1e d1 ff ff       	call   80103204 <begin_trans>
801060e6:	8d 45 ec             	lea    -0x14(%ebp),%eax
801060e9:	89 44 24 04          	mov    %eax,0x4(%esp)
801060ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801060f4:	e8 a5 f4 ff ff       	call   8010559e <argstr>
801060f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060fc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106100:	78 5e                	js     80106160 <sys_mknod+0x85>
80106102:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106105:	89 44 24 04          	mov    %eax,0x4(%esp)
80106109:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106110:	e8 ef f3 ff ff       	call   80105504 <argint>
80106115:	85 c0                	test   %eax,%eax
80106117:	78 47                	js     80106160 <sys_mknod+0x85>
80106119:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010611c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106120:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106127:	e8 d8 f3 ff ff       	call   80105504 <argint>
8010612c:	85 c0                	test   %eax,%eax
8010612e:	78 30                	js     80106160 <sys_mknod+0x85>
80106130:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106133:	0f bf c8             	movswl %ax,%ecx
80106136:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106139:	0f bf d0             	movswl %ax,%edx
8010613c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010613f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106143:	89 54 24 08          	mov    %edx,0x8(%esp)
80106147:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
8010614e:	00 
8010614f:	89 04 24             	mov    %eax,(%esp)
80106152:	e8 cb fb ff ff       	call   80105d22 <create>
80106157:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010615a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010615e:	75 0c                	jne    8010616c <sys_mknod+0x91>
80106160:	e8 e8 d0 ff ff       	call   8010324d <commit_trans>
80106165:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010616a:	eb 15                	jmp    80106181 <sys_mknod+0xa6>
8010616c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010616f:	89 04 24             	mov    %eax,(%esp)
80106172:	e8 87 b9 ff ff       	call   80101afe <iunlockput>
80106177:	e8 d1 d0 ff ff       	call   8010324d <commit_trans>
8010617c:	b8 00 00 00 00       	mov    $0x0,%eax
80106181:	c9                   	leave  
80106182:	c3                   	ret    

80106183 <sys_chdir>:
80106183:	55                   	push   %ebp
80106184:	89 e5                	mov    %esp,%ebp
80106186:	83 ec 28             	sub    $0x28,%esp
80106189:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010618c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106190:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106197:	e8 02 f4 ff ff       	call   8010559e <argstr>
8010619c:	85 c0                	test   %eax,%eax
8010619e:	78 14                	js     801061b4 <sys_chdir+0x31>
801061a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061a3:	89 04 24             	mov    %eax,(%esp)
801061a6:	e8 7a c2 ff ff       	call   80102425 <namei>
801061ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061b2:	75 07                	jne    801061bb <sys_chdir+0x38>
801061b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061b9:	eb 57                	jmp    80106212 <sys_chdir+0x8f>
801061bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061be:	89 04 24             	mov    %eax,(%esp)
801061c1:	e8 b4 b6 ff ff       	call   8010187a <ilock>
801061c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061c9:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801061cd:	66 83 f8 01          	cmp    $0x1,%ax
801061d1:	74 12                	je     801061e5 <sys_chdir+0x62>
801061d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061d6:	89 04 24             	mov    %eax,(%esp)
801061d9:	e8 20 b9 ff ff       	call   80101afe <iunlockput>
801061de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061e3:	eb 2d                	jmp    80106212 <sys_chdir+0x8f>
801061e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061e8:	89 04 24             	mov    %eax,(%esp)
801061eb:	e8 d8 b7 ff ff       	call   801019c8 <iunlock>
801061f0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061f6:	8b 40 68             	mov    0x68(%eax),%eax
801061f9:	89 04 24             	mov    %eax,(%esp)
801061fc:	e8 2c b8 ff ff       	call   80101a2d <iput>
80106201:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106207:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010620a:	89 50 68             	mov    %edx,0x68(%eax)
8010620d:	b8 00 00 00 00       	mov    $0x0,%eax
80106212:	c9                   	leave  
80106213:	c3                   	ret    

80106214 <sys_exec>:
80106214:	55                   	push   %ebp
80106215:	89 e5                	mov    %esp,%ebp
80106217:	81 ec a8 00 00 00    	sub    $0xa8,%esp
8010621d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106220:	89 44 24 04          	mov    %eax,0x4(%esp)
80106224:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010622b:	e8 6e f3 ff ff       	call   8010559e <argstr>
80106230:	85 c0                	test   %eax,%eax
80106232:	78 1a                	js     8010624e <sys_exec+0x3a>
80106234:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
8010623a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010623e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106245:	e8 ba f2 ff ff       	call   80105504 <argint>
8010624a:	85 c0                	test   %eax,%eax
8010624c:	79 0a                	jns    80106258 <sys_exec+0x44>
8010624e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106253:	e9 de 00 00 00       	jmp    80106336 <sys_exec+0x122>
80106258:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010625f:	00 
80106260:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106267:	00 
80106268:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010626e:	89 04 24             	mov    %eax,(%esp)
80106271:	e8 58 ef ff ff       	call   801051ce <memset>
80106276:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010627d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106280:	83 f8 1f             	cmp    $0x1f,%eax
80106283:	76 0a                	jbe    8010628f <sys_exec+0x7b>
80106285:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010628a:	e9 a7 00 00 00       	jmp    80106336 <sys_exec+0x122>
8010628f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106292:	c1 e0 02             	shl    $0x2,%eax
80106295:	89 c2                	mov    %eax,%edx
80106297:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
8010629d:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
801062a0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062a6:	8d 95 68 ff ff ff    	lea    -0x98(%ebp),%edx
801062ac:	89 54 24 08          	mov    %edx,0x8(%esp)
801062b0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
801062b4:	89 04 24             	mov    %eax,(%esp)
801062b7:	e8 b8 f1 ff ff       	call   80105474 <fetchint>
801062bc:	85 c0                	test   %eax,%eax
801062be:	79 07                	jns    801062c7 <sys_exec+0xb3>
801062c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062c5:	eb 6f                	jmp    80106336 <sys_exec+0x122>
801062c7:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801062cd:	85 c0                	test   %eax,%eax
801062cf:	75 26                	jne    801062f7 <sys_exec+0xe3>
801062d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062d4:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801062db:	00 00 00 00 
801062df:	90                   	nop
801062e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062e3:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801062e9:	89 54 24 04          	mov    %edx,0x4(%esp)
801062ed:	89 04 24             	mov    %eax,(%esp)
801062f0:	e8 fa a7 ff ff       	call   80100aef <exec>
801062f5:	eb 3f                	jmp    80106336 <sys_exec+0x122>
801062f7:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801062fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106300:	c1 e2 02             	shl    $0x2,%edx
80106303:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
80106306:	8b 95 68 ff ff ff    	mov    -0x98(%ebp),%edx
8010630c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106312:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106316:	89 54 24 04          	mov    %edx,0x4(%esp)
8010631a:	89 04 24             	mov    %eax,(%esp)
8010631d:	e8 86 f1 ff ff       	call   801054a8 <fetchstr>
80106322:	85 c0                	test   %eax,%eax
80106324:	79 07                	jns    8010632d <sys_exec+0x119>
80106326:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010632b:	eb 09                	jmp    80106336 <sys_exec+0x122>
8010632d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106331:	e9 47 ff ff ff       	jmp    8010627d <sys_exec+0x69>
80106336:	c9                   	leave  
80106337:	c3                   	ret    

80106338 <sys_pipe>:
80106338:	55                   	push   %ebp
80106339:	89 e5                	mov    %esp,%ebp
8010633b:	83 ec 38             	sub    $0x38,%esp
8010633e:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80106345:	00 
80106346:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106349:	89 44 24 04          	mov    %eax,0x4(%esp)
8010634d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106354:	e8 e3 f1 ff ff       	call   8010553c <argptr>
80106359:	85 c0                	test   %eax,%eax
8010635b:	79 0a                	jns    80106367 <sys_pipe+0x2f>
8010635d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106362:	e9 9b 00 00 00       	jmp    80106402 <sys_pipe+0xca>
80106367:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010636a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010636e:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106371:	89 04 24             	mov    %eax,(%esp)
80106374:	e8 85 d8 ff ff       	call   80103bfe <pipealloc>
80106379:	85 c0                	test   %eax,%eax
8010637b:	79 07                	jns    80106384 <sys_pipe+0x4c>
8010637d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106382:	eb 7e                	jmp    80106402 <sys_pipe+0xca>
80106384:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
8010638b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010638e:	89 04 24             	mov    %eax,(%esp)
80106391:	e8 83 f3 ff ff       	call   80105719 <fdalloc>
80106396:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106399:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010639d:	78 14                	js     801063b3 <sys_pipe+0x7b>
8010639f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063a2:	89 04 24             	mov    %eax,(%esp)
801063a5:	e8 6f f3 ff ff       	call   80105719 <fdalloc>
801063aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
801063ad:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063b1:	79 37                	jns    801063ea <sys_pipe+0xb2>
801063b3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063b7:	78 14                	js     801063cd <sys_pipe+0x95>
801063b9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801063bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
801063c2:	83 c2 08             	add    $0x8,%edx
801063c5:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801063cc:	00 
801063cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801063d0:	89 04 24             	mov    %eax,(%esp)
801063d3:	e8 15 ac ff ff       	call   80100fed <fileclose>
801063d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063db:	89 04 24             	mov    %eax,(%esp)
801063de:	e8 0a ac ff ff       	call   80100fed <fileclose>
801063e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063e8:	eb 18                	jmp    80106402 <sys_pipe+0xca>
801063ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
801063ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
801063f0:	89 10                	mov    %edx,(%eax)
801063f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801063f5:	8d 50 04             	lea    0x4(%eax),%edx
801063f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063fb:	89 02                	mov    %eax,(%edx)
801063fd:	b8 00 00 00 00       	mov    $0x0,%eax
80106402:	c9                   	leave  
80106403:	c3                   	ret    

80106404 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106404:	55                   	push   %ebp
80106405:	89 e5                	mov    %esp,%ebp
80106407:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010640a:	e8 a1 de ff ff       	call   801042b0 <fork>
}
8010640f:	c9                   	leave  
80106410:	c3                   	ret    

80106411 <sys_cowfork>:

int
sys_cowfork(void)
{
80106411:	55                   	push   %ebp
80106412:	89 e5                	mov    %esp,%ebp
80106414:	83 ec 08             	sub    $0x8,%esp
  return cowfork();
80106417:	e8 f7 df ff ff       	call   80104413 <cowfork>
}
8010641c:	c9                   	leave  
8010641d:	c3                   	ret    

8010641e <sys_exit>:

int
sys_exit(void)
{
8010641e:	55                   	push   %ebp
8010641f:	89 e5                	mov    %esp,%ebp
80106421:	83 ec 08             	sub    $0x8,%esp
  exit();
80106424:	e8 4d e1 ff ff       	call   80104576 <exit>
  return 0;  // not reached
80106429:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010642e:	c9                   	leave  
8010642f:	c3                   	ret    

80106430 <sys_wait>:

int
sys_wait(void)
{
80106430:	55                   	push   %ebp
80106431:	89 e5                	mov    %esp,%ebp
80106433:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106436:	e8 53 e2 ff ff       	call   8010468e <wait>
}
8010643b:	c9                   	leave  
8010643c:	c3                   	ret    

8010643d <sys_kill>:

int
sys_kill(void)
{
8010643d:	55                   	push   %ebp
8010643e:	89 e5                	mov    %esp,%ebp
80106440:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106443:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106446:	89 44 24 04          	mov    %eax,0x4(%esp)
8010644a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106451:	e8 ae f0 ff ff       	call   80105504 <argint>
80106456:	85 c0                	test   %eax,%eax
80106458:	79 07                	jns    80106461 <sys_kill+0x24>
    return -1;
8010645a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010645f:	eb 0b                	jmp    8010646c <sys_kill+0x2f>
  return kill(pid);
80106461:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106464:	89 04 24             	mov    %eax,(%esp)
80106467:	e8 80 e6 ff ff       	call   80104aec <kill>
}
8010646c:	c9                   	leave  
8010646d:	c3                   	ret    

8010646e <sys_getpid>:

int
sys_getpid(void)
{
8010646e:	55                   	push   %ebp
8010646f:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106471:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106477:	8b 40 10             	mov    0x10(%eax),%eax
}
8010647a:	5d                   	pop    %ebp
8010647b:	c3                   	ret    

8010647c <sys_sbrk>:

int
sys_sbrk(void)
{
8010647c:	55                   	push   %ebp
8010647d:	89 e5                	mov    %esp,%ebp
8010647f:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106482:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106485:	89 44 24 04          	mov    %eax,0x4(%esp)
80106489:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106490:	e8 6f f0 ff ff       	call   80105504 <argint>
80106495:	85 c0                	test   %eax,%eax
80106497:	79 07                	jns    801064a0 <sys_sbrk+0x24>
    return -1;
80106499:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010649e:	eb 24                	jmp    801064c4 <sys_sbrk+0x48>
  addr = proc->sz;
801064a0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064a6:	8b 00                	mov    (%eax),%eax
801064a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801064ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064ae:	89 04 24             	mov    %eax,(%esp)
801064b1:	e8 55 dd ff ff       	call   8010420b <growproc>
801064b6:	85 c0                	test   %eax,%eax
801064b8:	79 07                	jns    801064c1 <sys_sbrk+0x45>
    return -1;
801064ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064bf:	eb 03                	jmp    801064c4 <sys_sbrk+0x48>
  return addr;
801064c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801064c4:	c9                   	leave  
801064c5:	c3                   	ret    

801064c6 <sys_procdump>:

void
sys_procdump(void)
{
801064c6:	55                   	push   %ebp
801064c7:	89 e5                	mov    %esp,%ebp
801064c9:	83 ec 08             	sub    $0x8,%esp
  procdump();
801064cc:	e8 93 e6 ff ff       	call   80104b64 <procdump>
}
801064d1:	c9                   	leave  
801064d2:	c3                   	ret    

801064d3 <sys_sleep>:

int
sys_sleep(void)
{
801064d3:	55                   	push   %ebp
801064d4:	89 e5                	mov    %esp,%ebp
801064d6:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
801064d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064dc:	89 44 24 04          	mov    %eax,0x4(%esp)
801064e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801064e7:	e8 18 f0 ff ff       	call   80105504 <argint>
801064ec:	85 c0                	test   %eax,%eax
801064ee:	79 07                	jns    801064f7 <sys_sleep+0x24>
    return -1;
801064f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064f5:	eb 6c                	jmp    80106563 <sys_sleep+0x90>
  acquire(&tickslock);
801064f7:	c7 04 24 60 2e 11 80 	movl   $0x80112e60,(%esp)
801064fe:	e8 77 ea ff ff       	call   80104f7a <acquire>
  ticks0 = ticks;
80106503:	a1 a0 36 11 80       	mov    0x801136a0,%eax
80106508:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010650b:	eb 34                	jmp    80106541 <sys_sleep+0x6e>
    if(proc->killed){
8010650d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106513:	8b 40 24             	mov    0x24(%eax),%eax
80106516:	85 c0                	test   %eax,%eax
80106518:	74 13                	je     8010652d <sys_sleep+0x5a>
      release(&tickslock);
8010651a:	c7 04 24 60 2e 11 80 	movl   $0x80112e60,(%esp)
80106521:	e8 b6 ea ff ff       	call   80104fdc <release>
      return -1;
80106526:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010652b:	eb 36                	jmp    80106563 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
8010652d:	c7 44 24 04 60 2e 11 	movl   $0x80112e60,0x4(%esp)
80106534:	80 
80106535:	c7 04 24 a0 36 11 80 	movl   $0x801136a0,(%esp)
8010653c:	e8 a7 e4 ff ff       	call   801049e8 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106541:	a1 a0 36 11 80       	mov    0x801136a0,%eax
80106546:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106549:	89 c2                	mov    %eax,%edx
8010654b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010654e:	39 c2                	cmp    %eax,%edx
80106550:	72 bb                	jb     8010650d <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106552:	c7 04 24 60 2e 11 80 	movl   $0x80112e60,(%esp)
80106559:	e8 7e ea ff ff       	call   80104fdc <release>
  return 0;
8010655e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106563:	c9                   	leave  
80106564:	c3                   	ret    

80106565 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106565:	55                   	push   %ebp
80106566:	89 e5                	mov    %esp,%ebp
80106568:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
8010656b:	c7 04 24 60 2e 11 80 	movl   $0x80112e60,(%esp)
80106572:	e8 03 ea ff ff       	call   80104f7a <acquire>
  xticks = ticks;
80106577:	a1 a0 36 11 80       	mov    0x801136a0,%eax
8010657c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
8010657f:	c7 04 24 60 2e 11 80 	movl   $0x80112e60,(%esp)
80106586:	e8 51 ea ff ff       	call   80104fdc <release>
  return xticks;
8010658b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010658e:	c9                   	leave  
8010658f:	c3                   	ret    

80106590 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106590:	55                   	push   %ebp
80106591:	89 e5                	mov    %esp,%ebp
80106593:	83 ec 08             	sub    $0x8,%esp
80106596:	8b 55 08             	mov    0x8(%ebp),%edx
80106599:	8b 45 0c             	mov    0xc(%ebp),%eax
8010659c:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801065a0:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801065a3:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801065a7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801065ab:	ee                   	out    %al,(%dx)
}
801065ac:	c9                   	leave  
801065ad:	c3                   	ret    

801065ae <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
801065ae:	55                   	push   %ebp
801065af:	89 e5                	mov    %esp,%ebp
801065b1:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
801065b4:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
801065bb:	00 
801065bc:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
801065c3:	e8 c8 ff ff ff       	call   80106590 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
801065c8:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
801065cf:	00 
801065d0:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801065d7:	e8 b4 ff ff ff       	call   80106590 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
801065dc:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
801065e3:	00 
801065e4:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801065eb:	e8 a0 ff ff ff       	call   80106590 <outb>
  picenable(IRQ_TIMER);
801065f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065f7:	e8 95 d4 ff ff       	call   80103a91 <picenable>
}
801065fc:	c9                   	leave  
801065fd:	c3                   	ret    

801065fe <alltraps>:
801065fe:	1e                   	push   %ds
801065ff:	06                   	push   %es
80106600:	0f a0                	push   %fs
80106602:	0f a8                	push   %gs
80106604:	60                   	pusha  
80106605:	66 b8 10 00          	mov    $0x10,%ax
80106609:	8e d8                	mov    %eax,%ds
8010660b:	8e c0                	mov    %eax,%es
8010660d:	66 b8 18 00          	mov    $0x18,%ax
80106611:	8e e0                	mov    %eax,%fs
80106613:	8e e8                	mov    %eax,%gs
80106615:	54                   	push   %esp
80106616:	e8 e3 01 00 00       	call   801067fe <trap>
8010661b:	83 c4 04             	add    $0x4,%esp

8010661e <trapret>:
8010661e:	61                   	popa   
8010661f:	0f a9                	pop    %gs
80106621:	0f a1                	pop    %fs
80106623:	07                   	pop    %es
80106624:	1f                   	pop    %ds
80106625:	83 c4 08             	add    $0x8,%esp
80106628:	cf                   	iret   

80106629 <read_cr2>:
80106629:	0f 20 d0             	mov    %cr2,%eax
8010662c:	c3                   	ret    

8010662d <flush_tlb_all>:
8010662d:	0f 20 d8             	mov    %cr3,%eax
80106630:	0f 22 d8             	mov    %eax,%cr3
80106633:	c3                   	ret    

80106634 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106634:	55                   	push   %ebp
80106635:	89 e5                	mov    %esp,%ebp
80106637:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010663a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010663d:	83 e8 01             	sub    $0x1,%eax
80106640:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106644:	8b 45 08             	mov    0x8(%ebp),%eax
80106647:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010664b:	8b 45 08             	mov    0x8(%ebp),%eax
8010664e:	c1 e8 10             	shr    $0x10,%eax
80106651:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106655:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106658:	0f 01 18             	lidtl  (%eax)
}
8010665b:	c9                   	leave  
8010665c:	c3                   	ret    

8010665d <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
8010665d:	55                   	push   %ebp
8010665e:	89 e5                	mov    %esp,%ebp
80106660:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106663:	0f 20 d0             	mov    %cr2,%eax
80106666:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106669:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010666c:	c9                   	leave  
8010666d:	c3                   	ret    

8010666e <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
8010666e:	55                   	push   %ebp
8010666f:	89 e5                	mov    %esp,%ebp
80106671:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80106674:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010667b:	e9 c3 00 00 00       	jmp    80106743 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106680:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106683:	8b 04 85 a0 c0 10 80 	mov    -0x7fef3f60(,%eax,4),%eax
8010668a:	89 c2                	mov    %eax,%edx
8010668c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010668f:	66 89 14 c5 a0 2e 11 	mov    %dx,-0x7feed160(,%eax,8)
80106696:	80 
80106697:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010669a:	66 c7 04 c5 a2 2e 11 	movw   $0x8,-0x7feed15e(,%eax,8)
801066a1:	80 08 00 
801066a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066a7:	0f b6 14 c5 a4 2e 11 	movzbl -0x7feed15c(,%eax,8),%edx
801066ae:	80 
801066af:	83 e2 e0             	and    $0xffffffe0,%edx
801066b2:	88 14 c5 a4 2e 11 80 	mov    %dl,-0x7feed15c(,%eax,8)
801066b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066bc:	0f b6 14 c5 a4 2e 11 	movzbl -0x7feed15c(,%eax,8),%edx
801066c3:	80 
801066c4:	83 e2 1f             	and    $0x1f,%edx
801066c7:	88 14 c5 a4 2e 11 80 	mov    %dl,-0x7feed15c(,%eax,8)
801066ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066d1:	0f b6 14 c5 a5 2e 11 	movzbl -0x7feed15b(,%eax,8),%edx
801066d8:	80 
801066d9:	83 e2 f0             	and    $0xfffffff0,%edx
801066dc:	83 ca 0e             	or     $0xe,%edx
801066df:	88 14 c5 a5 2e 11 80 	mov    %dl,-0x7feed15b(,%eax,8)
801066e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066e9:	0f b6 14 c5 a5 2e 11 	movzbl -0x7feed15b(,%eax,8),%edx
801066f0:	80 
801066f1:	83 e2 ef             	and    $0xffffffef,%edx
801066f4:	88 14 c5 a5 2e 11 80 	mov    %dl,-0x7feed15b(,%eax,8)
801066fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066fe:	0f b6 14 c5 a5 2e 11 	movzbl -0x7feed15b(,%eax,8),%edx
80106705:	80 
80106706:	83 e2 9f             	and    $0xffffff9f,%edx
80106709:	88 14 c5 a5 2e 11 80 	mov    %dl,-0x7feed15b(,%eax,8)
80106710:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106713:	0f b6 14 c5 a5 2e 11 	movzbl -0x7feed15b(,%eax,8),%edx
8010671a:	80 
8010671b:	83 ca 80             	or     $0xffffff80,%edx
8010671e:	88 14 c5 a5 2e 11 80 	mov    %dl,-0x7feed15b(,%eax,8)
80106725:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106728:	8b 04 85 a0 c0 10 80 	mov    -0x7fef3f60(,%eax,4),%eax
8010672f:	c1 e8 10             	shr    $0x10,%eax
80106732:	89 c2                	mov    %eax,%edx
80106734:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106737:	66 89 14 c5 a6 2e 11 	mov    %dx,-0x7feed15a(,%eax,8)
8010673e:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
8010673f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106743:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010674a:	0f 8e 30 ff ff ff    	jle    80106680 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106750:	a1 a0 c1 10 80       	mov    0x8010c1a0,%eax
80106755:	66 a3 a0 30 11 80    	mov    %ax,0x801130a0
8010675b:	66 c7 05 a2 30 11 80 	movw   $0x8,0x801130a2
80106762:	08 00 
80106764:	0f b6 05 a4 30 11 80 	movzbl 0x801130a4,%eax
8010676b:	83 e0 e0             	and    $0xffffffe0,%eax
8010676e:	a2 a4 30 11 80       	mov    %al,0x801130a4
80106773:	0f b6 05 a4 30 11 80 	movzbl 0x801130a4,%eax
8010677a:	83 e0 1f             	and    $0x1f,%eax
8010677d:	a2 a4 30 11 80       	mov    %al,0x801130a4
80106782:	0f b6 05 a5 30 11 80 	movzbl 0x801130a5,%eax
80106789:	83 c8 0f             	or     $0xf,%eax
8010678c:	a2 a5 30 11 80       	mov    %al,0x801130a5
80106791:	0f b6 05 a5 30 11 80 	movzbl 0x801130a5,%eax
80106798:	83 e0 ef             	and    $0xffffffef,%eax
8010679b:	a2 a5 30 11 80       	mov    %al,0x801130a5
801067a0:	0f b6 05 a5 30 11 80 	movzbl 0x801130a5,%eax
801067a7:	83 c8 60             	or     $0x60,%eax
801067aa:	a2 a5 30 11 80       	mov    %al,0x801130a5
801067af:	0f b6 05 a5 30 11 80 	movzbl 0x801130a5,%eax
801067b6:	83 c8 80             	or     $0xffffff80,%eax
801067b9:	a2 a5 30 11 80       	mov    %al,0x801130a5
801067be:	a1 a0 c1 10 80       	mov    0x8010c1a0,%eax
801067c3:	c1 e8 10             	shr    $0x10,%eax
801067c6:	66 a3 a6 30 11 80    	mov    %ax,0x801130a6
  
  initlock(&tickslock, "time");
801067cc:	c7 44 24 04 f8 8e 10 	movl   $0x80108ef8,0x4(%esp)
801067d3:	80 
801067d4:	c7 04 24 60 2e 11 80 	movl   $0x80112e60,(%esp)
801067db:	e8 79 e7 ff ff       	call   80104f59 <initlock>
}
801067e0:	c9                   	leave  
801067e1:	c3                   	ret    

801067e2 <idtinit>:

void
idtinit(void)
{
801067e2:	55                   	push   %ebp
801067e3:	89 e5                	mov    %esp,%ebp
801067e5:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
801067e8:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
801067ef:	00 
801067f0:	c7 04 24 a0 2e 11 80 	movl   $0x80112ea0,(%esp)
801067f7:	e8 38 fe ff ff       	call   80106634 <lidt>
}
801067fc:	c9                   	leave  
801067fd:	c3                   	ret    

801067fe <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801067fe:	55                   	push   %ebp
801067ff:	89 e5                	mov    %esp,%ebp
80106801:	57                   	push   %edi
80106802:	56                   	push   %esi
80106803:	53                   	push   %ebx
80106804:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106807:	8b 45 08             	mov    0x8(%ebp),%eax
8010680a:	8b 40 30             	mov    0x30(%eax),%eax
8010680d:	83 f8 40             	cmp    $0x40,%eax
80106810:	75 3f                	jne    80106851 <trap+0x53>
    if(proc->killed)
80106812:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106818:	8b 40 24             	mov    0x24(%eax),%eax
8010681b:	85 c0                	test   %eax,%eax
8010681d:	74 05                	je     80106824 <trap+0x26>
      exit();
8010681f:	e8 52 dd ff ff       	call   80104576 <exit>
    proc->tf = tf;
80106824:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010682a:	8b 55 08             	mov    0x8(%ebp),%edx
8010682d:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106830:	e8 ac ed ff ff       	call   801055e1 <syscall>
    if(proc->killed)
80106835:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010683b:	8b 40 24             	mov    0x24(%eax),%eax
8010683e:	85 c0                	test   %eax,%eax
80106840:	74 0a                	je     8010684c <trap+0x4e>
      exit();
80106842:	e8 2f dd ff ff       	call   80104576 <exit>
    return;
80106847:	e9 4e 02 00 00       	jmp    80106a9a <trap+0x29c>
8010684c:	e9 49 02 00 00       	jmp    80106a9a <trap+0x29c>
  }
  

  // Tratamento de exceção 
  if(tf->trapno == T_PGFLT)
80106851:	8b 45 08             	mov    0x8(%ebp),%eax
80106854:	8b 40 30             	mov    0x30(%eax),%eax
80106857:	83 f8 0e             	cmp    $0xe,%eax
8010685a:	75 16                	jne    80106872 <trap+0x74>
  {
    proc->tf = tf;
8010685c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106862:	8b 55 08             	mov    0x8(%ebp),%edx
80106865:	89 50 18             	mov    %edx,0x18(%eax)
    handle_pgflt ();
80106868:	e8 e2 1c 00 00       	call   8010854f <handle_pgflt>
    return;
8010686d:	e9 28 02 00 00       	jmp    80106a9a <trap+0x29c>
  }
  
  switch(tf->trapno){
80106872:	8b 45 08             	mov    0x8(%ebp),%eax
80106875:	8b 40 30             	mov    0x30(%eax),%eax
80106878:	83 e8 20             	sub    $0x20,%eax
8010687b:	83 f8 1f             	cmp    $0x1f,%eax
8010687e:	0f 87 bc 00 00 00    	ja     80106940 <trap+0x142>
80106884:	8b 04 85 a0 8f 10 80 	mov    -0x7fef7060(,%eax,4),%eax
8010688b:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
8010688d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106893:	0f b6 00             	movzbl (%eax),%eax
80106896:	84 c0                	test   %al,%al
80106898:	75 31                	jne    801068cb <trap+0xcd>
      acquire(&tickslock);
8010689a:	c7 04 24 60 2e 11 80 	movl   $0x80112e60,(%esp)
801068a1:	e8 d4 e6 ff ff       	call   80104f7a <acquire>
      ticks++;
801068a6:	a1 a0 36 11 80       	mov    0x801136a0,%eax
801068ab:	83 c0 01             	add    $0x1,%eax
801068ae:	a3 a0 36 11 80       	mov    %eax,0x801136a0
      wakeup(&ticks);
801068b3:	c7 04 24 a0 36 11 80 	movl   $0x801136a0,(%esp)
801068ba:	e8 02 e2 ff ff       	call   80104ac1 <wakeup>
      release(&tickslock);
801068bf:	c7 04 24 60 2e 11 80 	movl   $0x80112e60,(%esp)
801068c6:	e8 11 e7 ff ff       	call   80104fdc <release>
    }
    lapiceoi();
801068cb:	e8 02 c6 ff ff       	call   80102ed2 <lapiceoi>
    break;
801068d0:	e9 41 01 00 00       	jmp    80106a16 <trap+0x218>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801068d5:	e8 23 be ff ff       	call   801026fd <ideintr>
    lapiceoi();
801068da:	e8 f3 c5 ff ff       	call   80102ed2 <lapiceoi>
    break;
801068df:	e9 32 01 00 00       	jmp    80106a16 <trap+0x218>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801068e4:	e8 d5 c3 ff ff       	call   80102cbe <kbdintr>
    lapiceoi();
801068e9:	e8 e4 c5 ff ff       	call   80102ed2 <lapiceoi>
    break;
801068ee:	e9 23 01 00 00       	jmp    80106a16 <trap+0x218>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801068f3:	e8 97 03 00 00       	call   80106c8f <uartintr>
    lapiceoi();
801068f8:	e8 d5 c5 ff ff       	call   80102ed2 <lapiceoi>
    break;
801068fd:	e9 14 01 00 00       	jmp    80106a16 <trap+0x218>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106902:	8b 45 08             	mov    0x8(%ebp),%eax
80106905:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106908:	8b 45 08             	mov    0x8(%ebp),%eax
8010690b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010690f:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106912:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106918:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010691b:	0f b6 c0             	movzbl %al,%eax
8010691e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106922:	89 54 24 08          	mov    %edx,0x8(%esp)
80106926:	89 44 24 04          	mov    %eax,0x4(%esp)
8010692a:	c7 04 24 00 8f 10 80 	movl   $0x80108f00,(%esp)
80106931:	e8 6a 9a ff ff       	call   801003a0 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106936:	e8 97 c5 ff ff       	call   80102ed2 <lapiceoi>
    break;
8010693b:	e9 d6 00 00 00       	jmp    80106a16 <trap+0x218>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106940:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106946:	85 c0                	test   %eax,%eax
80106948:	74 11                	je     8010695b <trap+0x15d>
8010694a:	8b 45 08             	mov    0x8(%ebp),%eax
8010694d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106951:	0f b7 c0             	movzwl %ax,%eax
80106954:	83 e0 03             	and    $0x3,%eax
80106957:	85 c0                	test   %eax,%eax
80106959:	75 46                	jne    801069a1 <trap+0x1a3>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010695b:	e8 fd fc ff ff       	call   8010665d <rcr2>
80106960:	8b 55 08             	mov    0x8(%ebp),%edx
80106963:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106966:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010696d:	0f b6 12             	movzbl (%edx),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106970:	0f b6 ca             	movzbl %dl,%ecx
80106973:	8b 55 08             	mov    0x8(%ebp),%edx
80106976:	8b 52 30             	mov    0x30(%edx),%edx
80106979:	89 44 24 10          	mov    %eax,0x10(%esp)
8010697d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80106981:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106985:	89 54 24 04          	mov    %edx,0x4(%esp)
80106989:	c7 04 24 24 8f 10 80 	movl   $0x80108f24,(%esp)
80106990:	e8 0b 9a ff ff       	call   801003a0 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106995:	c7 04 24 56 8f 10 80 	movl   $0x80108f56,(%esp)
8010699c:	e8 99 9b ff ff       	call   8010053a <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801069a1:	e8 b7 fc ff ff       	call   8010665d <rcr2>
801069a6:	89 c2                	mov    %eax,%edx
801069a8:	8b 45 08             	mov    0x8(%ebp),%eax
801069ab:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801069ae:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801069b4:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801069b7:	0f b6 f0             	movzbl %al,%esi
801069ba:	8b 45 08             	mov    0x8(%ebp),%eax
801069bd:	8b 58 34             	mov    0x34(%eax),%ebx
801069c0:	8b 45 08             	mov    0x8(%ebp),%eax
801069c3:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801069c6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069cc:	83 c0 6c             	add    $0x6c,%eax
801069cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801069d2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801069d8:	8b 40 10             	mov    0x10(%eax),%eax
801069db:	89 54 24 1c          	mov    %edx,0x1c(%esp)
801069df:	89 7c 24 18          	mov    %edi,0x18(%esp)
801069e3:	89 74 24 14          	mov    %esi,0x14(%esp)
801069e7:	89 5c 24 10          	mov    %ebx,0x10(%esp)
801069eb:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801069ef:	8b 75 e4             	mov    -0x1c(%ebp),%esi
801069f2:	89 74 24 08          	mov    %esi,0x8(%esp)
801069f6:	89 44 24 04          	mov    %eax,0x4(%esp)
801069fa:	c7 04 24 5c 8f 10 80 	movl   $0x80108f5c,(%esp)
80106a01:	e8 9a 99 ff ff       	call   801003a0 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106a06:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a0c:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106a13:	eb 01                	jmp    80106a16 <trap+0x218>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106a15:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106a16:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a1c:	85 c0                	test   %eax,%eax
80106a1e:	74 24                	je     80106a44 <trap+0x246>
80106a20:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a26:	8b 40 24             	mov    0x24(%eax),%eax
80106a29:	85 c0                	test   %eax,%eax
80106a2b:	74 17                	je     80106a44 <trap+0x246>
80106a2d:	8b 45 08             	mov    0x8(%ebp),%eax
80106a30:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106a34:	0f b7 c0             	movzwl %ax,%eax
80106a37:	83 e0 03             	and    $0x3,%eax
80106a3a:	83 f8 03             	cmp    $0x3,%eax
80106a3d:	75 05                	jne    80106a44 <trap+0x246>
    exit();
80106a3f:	e8 32 db ff ff       	call   80104576 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106a44:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a4a:	85 c0                	test   %eax,%eax
80106a4c:	74 1e                	je     80106a6c <trap+0x26e>
80106a4e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a54:	8b 40 0c             	mov    0xc(%eax),%eax
80106a57:	83 f8 04             	cmp    $0x4,%eax
80106a5a:	75 10                	jne    80106a6c <trap+0x26e>
80106a5c:	8b 45 08             	mov    0x8(%ebp),%eax
80106a5f:	8b 40 30             	mov    0x30(%eax),%eax
80106a62:	83 f8 20             	cmp    $0x20,%eax
80106a65:	75 05                	jne    80106a6c <trap+0x26e>
    yield();
80106a67:	e8 1e df ff ff       	call   8010498a <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106a6c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a72:	85 c0                	test   %eax,%eax
80106a74:	74 24                	je     80106a9a <trap+0x29c>
80106a76:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a7c:	8b 40 24             	mov    0x24(%eax),%eax
80106a7f:	85 c0                	test   %eax,%eax
80106a81:	74 17                	je     80106a9a <trap+0x29c>
80106a83:	8b 45 08             	mov    0x8(%ebp),%eax
80106a86:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106a8a:	0f b7 c0             	movzwl %ax,%eax
80106a8d:	83 e0 03             	and    $0x3,%eax
80106a90:	83 f8 03             	cmp    $0x3,%eax
80106a93:	75 05                	jne    80106a9a <trap+0x29c>
    exit();
80106a95:	e8 dc da ff ff       	call   80104576 <exit>
}
80106a9a:	83 c4 3c             	add    $0x3c,%esp
80106a9d:	5b                   	pop    %ebx
80106a9e:	5e                   	pop    %esi
80106a9f:	5f                   	pop    %edi
80106aa0:	5d                   	pop    %ebp
80106aa1:	c3                   	ret    

80106aa2 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106aa2:	55                   	push   %ebp
80106aa3:	89 e5                	mov    %esp,%ebp
80106aa5:	83 ec 14             	sub    $0x14,%esp
80106aa8:	8b 45 08             	mov    0x8(%ebp),%eax
80106aab:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106aaf:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106ab3:	89 c2                	mov    %eax,%edx
80106ab5:	ec                   	in     (%dx),%al
80106ab6:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106ab9:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106abd:	c9                   	leave  
80106abe:	c3                   	ret    

80106abf <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106abf:	55                   	push   %ebp
80106ac0:	89 e5                	mov    %esp,%ebp
80106ac2:	83 ec 08             	sub    $0x8,%esp
80106ac5:	8b 55 08             	mov    0x8(%ebp),%edx
80106ac8:	8b 45 0c             	mov    0xc(%ebp),%eax
80106acb:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106acf:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106ad2:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106ad6:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106ada:	ee                   	out    %al,(%dx)
}
80106adb:	c9                   	leave  
80106adc:	c3                   	ret    

80106add <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106add:	55                   	push   %ebp
80106ade:	89 e5                	mov    %esp,%ebp
80106ae0:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106ae3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106aea:	00 
80106aeb:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106af2:	e8 c8 ff ff ff       	call   80106abf <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106af7:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106afe:	00 
80106aff:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106b06:	e8 b4 ff ff ff       	call   80106abf <outb>
  outb(COM1+0, 115200/9600);
80106b0b:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106b12:	00 
80106b13:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106b1a:	e8 a0 ff ff ff       	call   80106abf <outb>
  outb(COM1+1, 0);
80106b1f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106b26:	00 
80106b27:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106b2e:	e8 8c ff ff ff       	call   80106abf <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106b33:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106b3a:	00 
80106b3b:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106b42:	e8 78 ff ff ff       	call   80106abf <outb>
  outb(COM1+4, 0);
80106b47:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106b4e:	00 
80106b4f:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106b56:	e8 64 ff ff ff       	call   80106abf <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106b5b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106b62:	00 
80106b63:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106b6a:	e8 50 ff ff ff       	call   80106abf <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106b6f:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106b76:	e8 27 ff ff ff       	call   80106aa2 <inb>
80106b7b:	3c ff                	cmp    $0xff,%al
80106b7d:	75 02                	jne    80106b81 <uartinit+0xa4>
    return;
80106b7f:	eb 6a                	jmp    80106beb <uartinit+0x10e>
  uart = 1;
80106b81:	c7 05 4c c6 10 80 01 	movl   $0x1,0x8010c64c
80106b88:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106b8b:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106b92:	e8 0b ff ff ff       	call   80106aa2 <inb>
  inb(COM1+0);
80106b97:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106b9e:	e8 ff fe ff ff       	call   80106aa2 <inb>
  picenable(IRQ_COM1);
80106ba3:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106baa:	e8 e2 ce ff ff       	call   80103a91 <picenable>
  ioapicenable(IRQ_COM1, 0);
80106baf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106bb6:	00 
80106bb7:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106bbe:	e8 b9 bd ff ff       	call   8010297c <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106bc3:	c7 45 f4 20 90 10 80 	movl   $0x80109020,-0xc(%ebp)
80106bca:	eb 15                	jmp    80106be1 <uartinit+0x104>
    uartputc(*p);
80106bcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bcf:	0f b6 00             	movzbl (%eax),%eax
80106bd2:	0f be c0             	movsbl %al,%eax
80106bd5:	89 04 24             	mov    %eax,(%esp)
80106bd8:	e8 10 00 00 00       	call   80106bed <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106bdd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106be1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106be4:	0f b6 00             	movzbl (%eax),%eax
80106be7:	84 c0                	test   %al,%al
80106be9:	75 e1                	jne    80106bcc <uartinit+0xef>
    uartputc(*p);
}
80106beb:	c9                   	leave  
80106bec:	c3                   	ret    

80106bed <uartputc>:

void
uartputc(int c)
{
80106bed:	55                   	push   %ebp
80106bee:	89 e5                	mov    %esp,%ebp
80106bf0:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106bf3:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
80106bf8:	85 c0                	test   %eax,%eax
80106bfa:	75 02                	jne    80106bfe <uartputc+0x11>
    return;
80106bfc:	eb 4b                	jmp    80106c49 <uartputc+0x5c>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106bfe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106c05:	eb 10                	jmp    80106c17 <uartputc+0x2a>
    microdelay(10);
80106c07:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106c0e:	e8 e4 c2 ff ff       	call   80102ef7 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106c13:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106c17:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106c1b:	7f 16                	jg     80106c33 <uartputc+0x46>
80106c1d:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106c24:	e8 79 fe ff ff       	call   80106aa2 <inb>
80106c29:	0f b6 c0             	movzbl %al,%eax
80106c2c:	83 e0 20             	and    $0x20,%eax
80106c2f:	85 c0                	test   %eax,%eax
80106c31:	74 d4                	je     80106c07 <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80106c33:	8b 45 08             	mov    0x8(%ebp),%eax
80106c36:	0f b6 c0             	movzbl %al,%eax
80106c39:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c3d:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106c44:	e8 76 fe ff ff       	call   80106abf <outb>
}
80106c49:	c9                   	leave  
80106c4a:	c3                   	ret    

80106c4b <uartgetc>:

static int
uartgetc(void)
{
80106c4b:	55                   	push   %ebp
80106c4c:	89 e5                	mov    %esp,%ebp
80106c4e:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106c51:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
80106c56:	85 c0                	test   %eax,%eax
80106c58:	75 07                	jne    80106c61 <uartgetc+0x16>
    return -1;
80106c5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c5f:	eb 2c                	jmp    80106c8d <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106c61:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106c68:	e8 35 fe ff ff       	call   80106aa2 <inb>
80106c6d:	0f b6 c0             	movzbl %al,%eax
80106c70:	83 e0 01             	and    $0x1,%eax
80106c73:	85 c0                	test   %eax,%eax
80106c75:	75 07                	jne    80106c7e <uartgetc+0x33>
    return -1;
80106c77:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c7c:	eb 0f                	jmp    80106c8d <uartgetc+0x42>
  return inb(COM1+0);
80106c7e:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106c85:	e8 18 fe ff ff       	call   80106aa2 <inb>
80106c8a:	0f b6 c0             	movzbl %al,%eax
}
80106c8d:	c9                   	leave  
80106c8e:	c3                   	ret    

80106c8f <uartintr>:

void
uartintr(void)
{
80106c8f:	55                   	push   %ebp
80106c90:	89 e5                	mov    %esp,%ebp
80106c92:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106c95:	c7 04 24 4b 6c 10 80 	movl   $0x80106c4b,(%esp)
80106c9c:	e8 0c 9b ff ff       	call   801007ad <consoleintr>
}
80106ca1:	c9                   	leave  
80106ca2:	c3                   	ret    

80106ca3 <vector0>:
80106ca3:	6a 00                	push   $0x0
80106ca5:	6a 00                	push   $0x0
80106ca7:	e9 52 f9 ff ff       	jmp    801065fe <alltraps>

80106cac <vector1>:
80106cac:	6a 00                	push   $0x0
80106cae:	6a 01                	push   $0x1
80106cb0:	e9 49 f9 ff ff       	jmp    801065fe <alltraps>

80106cb5 <vector2>:
80106cb5:	6a 00                	push   $0x0
80106cb7:	6a 02                	push   $0x2
80106cb9:	e9 40 f9 ff ff       	jmp    801065fe <alltraps>

80106cbe <vector3>:
80106cbe:	6a 00                	push   $0x0
80106cc0:	6a 03                	push   $0x3
80106cc2:	e9 37 f9 ff ff       	jmp    801065fe <alltraps>

80106cc7 <vector4>:
80106cc7:	6a 00                	push   $0x0
80106cc9:	6a 04                	push   $0x4
80106ccb:	e9 2e f9 ff ff       	jmp    801065fe <alltraps>

80106cd0 <vector5>:
80106cd0:	6a 00                	push   $0x0
80106cd2:	6a 05                	push   $0x5
80106cd4:	e9 25 f9 ff ff       	jmp    801065fe <alltraps>

80106cd9 <vector6>:
80106cd9:	6a 00                	push   $0x0
80106cdb:	6a 06                	push   $0x6
80106cdd:	e9 1c f9 ff ff       	jmp    801065fe <alltraps>

80106ce2 <vector7>:
80106ce2:	6a 00                	push   $0x0
80106ce4:	6a 07                	push   $0x7
80106ce6:	e9 13 f9 ff ff       	jmp    801065fe <alltraps>

80106ceb <vector8>:
80106ceb:	6a 08                	push   $0x8
80106ced:	e9 0c f9 ff ff       	jmp    801065fe <alltraps>

80106cf2 <vector9>:
80106cf2:	6a 00                	push   $0x0
80106cf4:	6a 09                	push   $0x9
80106cf6:	e9 03 f9 ff ff       	jmp    801065fe <alltraps>

80106cfb <vector10>:
80106cfb:	6a 0a                	push   $0xa
80106cfd:	e9 fc f8 ff ff       	jmp    801065fe <alltraps>

80106d02 <vector11>:
80106d02:	6a 0b                	push   $0xb
80106d04:	e9 f5 f8 ff ff       	jmp    801065fe <alltraps>

80106d09 <vector12>:
80106d09:	6a 0c                	push   $0xc
80106d0b:	e9 ee f8 ff ff       	jmp    801065fe <alltraps>

80106d10 <vector13>:
80106d10:	6a 0d                	push   $0xd
80106d12:	e9 e7 f8 ff ff       	jmp    801065fe <alltraps>

80106d17 <vector14>:
80106d17:	6a 0e                	push   $0xe
80106d19:	e9 e0 f8 ff ff       	jmp    801065fe <alltraps>

80106d1e <vector15>:
80106d1e:	6a 00                	push   $0x0
80106d20:	6a 0f                	push   $0xf
80106d22:	e9 d7 f8 ff ff       	jmp    801065fe <alltraps>

80106d27 <vector16>:
80106d27:	6a 00                	push   $0x0
80106d29:	6a 10                	push   $0x10
80106d2b:	e9 ce f8 ff ff       	jmp    801065fe <alltraps>

80106d30 <vector17>:
80106d30:	6a 11                	push   $0x11
80106d32:	e9 c7 f8 ff ff       	jmp    801065fe <alltraps>

80106d37 <vector18>:
80106d37:	6a 00                	push   $0x0
80106d39:	6a 12                	push   $0x12
80106d3b:	e9 be f8 ff ff       	jmp    801065fe <alltraps>

80106d40 <vector19>:
80106d40:	6a 00                	push   $0x0
80106d42:	6a 13                	push   $0x13
80106d44:	e9 b5 f8 ff ff       	jmp    801065fe <alltraps>

80106d49 <vector20>:
80106d49:	6a 00                	push   $0x0
80106d4b:	6a 14                	push   $0x14
80106d4d:	e9 ac f8 ff ff       	jmp    801065fe <alltraps>

80106d52 <vector21>:
80106d52:	6a 00                	push   $0x0
80106d54:	6a 15                	push   $0x15
80106d56:	e9 a3 f8 ff ff       	jmp    801065fe <alltraps>

80106d5b <vector22>:
80106d5b:	6a 00                	push   $0x0
80106d5d:	6a 16                	push   $0x16
80106d5f:	e9 9a f8 ff ff       	jmp    801065fe <alltraps>

80106d64 <vector23>:
80106d64:	6a 00                	push   $0x0
80106d66:	6a 17                	push   $0x17
80106d68:	e9 91 f8 ff ff       	jmp    801065fe <alltraps>

80106d6d <vector24>:
80106d6d:	6a 00                	push   $0x0
80106d6f:	6a 18                	push   $0x18
80106d71:	e9 88 f8 ff ff       	jmp    801065fe <alltraps>

80106d76 <vector25>:
80106d76:	6a 00                	push   $0x0
80106d78:	6a 19                	push   $0x19
80106d7a:	e9 7f f8 ff ff       	jmp    801065fe <alltraps>

80106d7f <vector26>:
80106d7f:	6a 00                	push   $0x0
80106d81:	6a 1a                	push   $0x1a
80106d83:	e9 76 f8 ff ff       	jmp    801065fe <alltraps>

80106d88 <vector27>:
80106d88:	6a 00                	push   $0x0
80106d8a:	6a 1b                	push   $0x1b
80106d8c:	e9 6d f8 ff ff       	jmp    801065fe <alltraps>

80106d91 <vector28>:
80106d91:	6a 00                	push   $0x0
80106d93:	6a 1c                	push   $0x1c
80106d95:	e9 64 f8 ff ff       	jmp    801065fe <alltraps>

80106d9a <vector29>:
80106d9a:	6a 00                	push   $0x0
80106d9c:	6a 1d                	push   $0x1d
80106d9e:	e9 5b f8 ff ff       	jmp    801065fe <alltraps>

80106da3 <vector30>:
80106da3:	6a 00                	push   $0x0
80106da5:	6a 1e                	push   $0x1e
80106da7:	e9 52 f8 ff ff       	jmp    801065fe <alltraps>

80106dac <vector31>:
80106dac:	6a 00                	push   $0x0
80106dae:	6a 1f                	push   $0x1f
80106db0:	e9 49 f8 ff ff       	jmp    801065fe <alltraps>

80106db5 <vector32>:
80106db5:	6a 00                	push   $0x0
80106db7:	6a 20                	push   $0x20
80106db9:	e9 40 f8 ff ff       	jmp    801065fe <alltraps>

80106dbe <vector33>:
80106dbe:	6a 00                	push   $0x0
80106dc0:	6a 21                	push   $0x21
80106dc2:	e9 37 f8 ff ff       	jmp    801065fe <alltraps>

80106dc7 <vector34>:
80106dc7:	6a 00                	push   $0x0
80106dc9:	6a 22                	push   $0x22
80106dcb:	e9 2e f8 ff ff       	jmp    801065fe <alltraps>

80106dd0 <vector35>:
80106dd0:	6a 00                	push   $0x0
80106dd2:	6a 23                	push   $0x23
80106dd4:	e9 25 f8 ff ff       	jmp    801065fe <alltraps>

80106dd9 <vector36>:
80106dd9:	6a 00                	push   $0x0
80106ddb:	6a 24                	push   $0x24
80106ddd:	e9 1c f8 ff ff       	jmp    801065fe <alltraps>

80106de2 <vector37>:
80106de2:	6a 00                	push   $0x0
80106de4:	6a 25                	push   $0x25
80106de6:	e9 13 f8 ff ff       	jmp    801065fe <alltraps>

80106deb <vector38>:
80106deb:	6a 00                	push   $0x0
80106ded:	6a 26                	push   $0x26
80106def:	e9 0a f8 ff ff       	jmp    801065fe <alltraps>

80106df4 <vector39>:
80106df4:	6a 00                	push   $0x0
80106df6:	6a 27                	push   $0x27
80106df8:	e9 01 f8 ff ff       	jmp    801065fe <alltraps>

80106dfd <vector40>:
80106dfd:	6a 00                	push   $0x0
80106dff:	6a 28                	push   $0x28
80106e01:	e9 f8 f7 ff ff       	jmp    801065fe <alltraps>

80106e06 <vector41>:
80106e06:	6a 00                	push   $0x0
80106e08:	6a 29                	push   $0x29
80106e0a:	e9 ef f7 ff ff       	jmp    801065fe <alltraps>

80106e0f <vector42>:
80106e0f:	6a 00                	push   $0x0
80106e11:	6a 2a                	push   $0x2a
80106e13:	e9 e6 f7 ff ff       	jmp    801065fe <alltraps>

80106e18 <vector43>:
80106e18:	6a 00                	push   $0x0
80106e1a:	6a 2b                	push   $0x2b
80106e1c:	e9 dd f7 ff ff       	jmp    801065fe <alltraps>

80106e21 <vector44>:
80106e21:	6a 00                	push   $0x0
80106e23:	6a 2c                	push   $0x2c
80106e25:	e9 d4 f7 ff ff       	jmp    801065fe <alltraps>

80106e2a <vector45>:
80106e2a:	6a 00                	push   $0x0
80106e2c:	6a 2d                	push   $0x2d
80106e2e:	e9 cb f7 ff ff       	jmp    801065fe <alltraps>

80106e33 <vector46>:
80106e33:	6a 00                	push   $0x0
80106e35:	6a 2e                	push   $0x2e
80106e37:	e9 c2 f7 ff ff       	jmp    801065fe <alltraps>

80106e3c <vector47>:
80106e3c:	6a 00                	push   $0x0
80106e3e:	6a 2f                	push   $0x2f
80106e40:	e9 b9 f7 ff ff       	jmp    801065fe <alltraps>

80106e45 <vector48>:
80106e45:	6a 00                	push   $0x0
80106e47:	6a 30                	push   $0x30
80106e49:	e9 b0 f7 ff ff       	jmp    801065fe <alltraps>

80106e4e <vector49>:
80106e4e:	6a 00                	push   $0x0
80106e50:	6a 31                	push   $0x31
80106e52:	e9 a7 f7 ff ff       	jmp    801065fe <alltraps>

80106e57 <vector50>:
80106e57:	6a 00                	push   $0x0
80106e59:	6a 32                	push   $0x32
80106e5b:	e9 9e f7 ff ff       	jmp    801065fe <alltraps>

80106e60 <vector51>:
80106e60:	6a 00                	push   $0x0
80106e62:	6a 33                	push   $0x33
80106e64:	e9 95 f7 ff ff       	jmp    801065fe <alltraps>

80106e69 <vector52>:
80106e69:	6a 00                	push   $0x0
80106e6b:	6a 34                	push   $0x34
80106e6d:	e9 8c f7 ff ff       	jmp    801065fe <alltraps>

80106e72 <vector53>:
80106e72:	6a 00                	push   $0x0
80106e74:	6a 35                	push   $0x35
80106e76:	e9 83 f7 ff ff       	jmp    801065fe <alltraps>

80106e7b <vector54>:
80106e7b:	6a 00                	push   $0x0
80106e7d:	6a 36                	push   $0x36
80106e7f:	e9 7a f7 ff ff       	jmp    801065fe <alltraps>

80106e84 <vector55>:
80106e84:	6a 00                	push   $0x0
80106e86:	6a 37                	push   $0x37
80106e88:	e9 71 f7 ff ff       	jmp    801065fe <alltraps>

80106e8d <vector56>:
80106e8d:	6a 00                	push   $0x0
80106e8f:	6a 38                	push   $0x38
80106e91:	e9 68 f7 ff ff       	jmp    801065fe <alltraps>

80106e96 <vector57>:
80106e96:	6a 00                	push   $0x0
80106e98:	6a 39                	push   $0x39
80106e9a:	e9 5f f7 ff ff       	jmp    801065fe <alltraps>

80106e9f <vector58>:
80106e9f:	6a 00                	push   $0x0
80106ea1:	6a 3a                	push   $0x3a
80106ea3:	e9 56 f7 ff ff       	jmp    801065fe <alltraps>

80106ea8 <vector59>:
80106ea8:	6a 00                	push   $0x0
80106eaa:	6a 3b                	push   $0x3b
80106eac:	e9 4d f7 ff ff       	jmp    801065fe <alltraps>

80106eb1 <vector60>:
80106eb1:	6a 00                	push   $0x0
80106eb3:	6a 3c                	push   $0x3c
80106eb5:	e9 44 f7 ff ff       	jmp    801065fe <alltraps>

80106eba <vector61>:
80106eba:	6a 00                	push   $0x0
80106ebc:	6a 3d                	push   $0x3d
80106ebe:	e9 3b f7 ff ff       	jmp    801065fe <alltraps>

80106ec3 <vector62>:
80106ec3:	6a 00                	push   $0x0
80106ec5:	6a 3e                	push   $0x3e
80106ec7:	e9 32 f7 ff ff       	jmp    801065fe <alltraps>

80106ecc <vector63>:
80106ecc:	6a 00                	push   $0x0
80106ece:	6a 3f                	push   $0x3f
80106ed0:	e9 29 f7 ff ff       	jmp    801065fe <alltraps>

80106ed5 <vector64>:
80106ed5:	6a 00                	push   $0x0
80106ed7:	6a 40                	push   $0x40
80106ed9:	e9 20 f7 ff ff       	jmp    801065fe <alltraps>

80106ede <vector65>:
80106ede:	6a 00                	push   $0x0
80106ee0:	6a 41                	push   $0x41
80106ee2:	e9 17 f7 ff ff       	jmp    801065fe <alltraps>

80106ee7 <vector66>:
80106ee7:	6a 00                	push   $0x0
80106ee9:	6a 42                	push   $0x42
80106eeb:	e9 0e f7 ff ff       	jmp    801065fe <alltraps>

80106ef0 <vector67>:
80106ef0:	6a 00                	push   $0x0
80106ef2:	6a 43                	push   $0x43
80106ef4:	e9 05 f7 ff ff       	jmp    801065fe <alltraps>

80106ef9 <vector68>:
80106ef9:	6a 00                	push   $0x0
80106efb:	6a 44                	push   $0x44
80106efd:	e9 fc f6 ff ff       	jmp    801065fe <alltraps>

80106f02 <vector69>:
80106f02:	6a 00                	push   $0x0
80106f04:	6a 45                	push   $0x45
80106f06:	e9 f3 f6 ff ff       	jmp    801065fe <alltraps>

80106f0b <vector70>:
80106f0b:	6a 00                	push   $0x0
80106f0d:	6a 46                	push   $0x46
80106f0f:	e9 ea f6 ff ff       	jmp    801065fe <alltraps>

80106f14 <vector71>:
80106f14:	6a 00                	push   $0x0
80106f16:	6a 47                	push   $0x47
80106f18:	e9 e1 f6 ff ff       	jmp    801065fe <alltraps>

80106f1d <vector72>:
80106f1d:	6a 00                	push   $0x0
80106f1f:	6a 48                	push   $0x48
80106f21:	e9 d8 f6 ff ff       	jmp    801065fe <alltraps>

80106f26 <vector73>:
80106f26:	6a 00                	push   $0x0
80106f28:	6a 49                	push   $0x49
80106f2a:	e9 cf f6 ff ff       	jmp    801065fe <alltraps>

80106f2f <vector74>:
80106f2f:	6a 00                	push   $0x0
80106f31:	6a 4a                	push   $0x4a
80106f33:	e9 c6 f6 ff ff       	jmp    801065fe <alltraps>

80106f38 <vector75>:
80106f38:	6a 00                	push   $0x0
80106f3a:	6a 4b                	push   $0x4b
80106f3c:	e9 bd f6 ff ff       	jmp    801065fe <alltraps>

80106f41 <vector76>:
80106f41:	6a 00                	push   $0x0
80106f43:	6a 4c                	push   $0x4c
80106f45:	e9 b4 f6 ff ff       	jmp    801065fe <alltraps>

80106f4a <vector77>:
80106f4a:	6a 00                	push   $0x0
80106f4c:	6a 4d                	push   $0x4d
80106f4e:	e9 ab f6 ff ff       	jmp    801065fe <alltraps>

80106f53 <vector78>:
80106f53:	6a 00                	push   $0x0
80106f55:	6a 4e                	push   $0x4e
80106f57:	e9 a2 f6 ff ff       	jmp    801065fe <alltraps>

80106f5c <vector79>:
80106f5c:	6a 00                	push   $0x0
80106f5e:	6a 4f                	push   $0x4f
80106f60:	e9 99 f6 ff ff       	jmp    801065fe <alltraps>

80106f65 <vector80>:
80106f65:	6a 00                	push   $0x0
80106f67:	6a 50                	push   $0x50
80106f69:	e9 90 f6 ff ff       	jmp    801065fe <alltraps>

80106f6e <vector81>:
80106f6e:	6a 00                	push   $0x0
80106f70:	6a 51                	push   $0x51
80106f72:	e9 87 f6 ff ff       	jmp    801065fe <alltraps>

80106f77 <vector82>:
80106f77:	6a 00                	push   $0x0
80106f79:	6a 52                	push   $0x52
80106f7b:	e9 7e f6 ff ff       	jmp    801065fe <alltraps>

80106f80 <vector83>:
80106f80:	6a 00                	push   $0x0
80106f82:	6a 53                	push   $0x53
80106f84:	e9 75 f6 ff ff       	jmp    801065fe <alltraps>

80106f89 <vector84>:
80106f89:	6a 00                	push   $0x0
80106f8b:	6a 54                	push   $0x54
80106f8d:	e9 6c f6 ff ff       	jmp    801065fe <alltraps>

80106f92 <vector85>:
80106f92:	6a 00                	push   $0x0
80106f94:	6a 55                	push   $0x55
80106f96:	e9 63 f6 ff ff       	jmp    801065fe <alltraps>

80106f9b <vector86>:
80106f9b:	6a 00                	push   $0x0
80106f9d:	6a 56                	push   $0x56
80106f9f:	e9 5a f6 ff ff       	jmp    801065fe <alltraps>

80106fa4 <vector87>:
80106fa4:	6a 00                	push   $0x0
80106fa6:	6a 57                	push   $0x57
80106fa8:	e9 51 f6 ff ff       	jmp    801065fe <alltraps>

80106fad <vector88>:
80106fad:	6a 00                	push   $0x0
80106faf:	6a 58                	push   $0x58
80106fb1:	e9 48 f6 ff ff       	jmp    801065fe <alltraps>

80106fb6 <vector89>:
80106fb6:	6a 00                	push   $0x0
80106fb8:	6a 59                	push   $0x59
80106fba:	e9 3f f6 ff ff       	jmp    801065fe <alltraps>

80106fbf <vector90>:
80106fbf:	6a 00                	push   $0x0
80106fc1:	6a 5a                	push   $0x5a
80106fc3:	e9 36 f6 ff ff       	jmp    801065fe <alltraps>

80106fc8 <vector91>:
80106fc8:	6a 00                	push   $0x0
80106fca:	6a 5b                	push   $0x5b
80106fcc:	e9 2d f6 ff ff       	jmp    801065fe <alltraps>

80106fd1 <vector92>:
80106fd1:	6a 00                	push   $0x0
80106fd3:	6a 5c                	push   $0x5c
80106fd5:	e9 24 f6 ff ff       	jmp    801065fe <alltraps>

80106fda <vector93>:
80106fda:	6a 00                	push   $0x0
80106fdc:	6a 5d                	push   $0x5d
80106fde:	e9 1b f6 ff ff       	jmp    801065fe <alltraps>

80106fe3 <vector94>:
80106fe3:	6a 00                	push   $0x0
80106fe5:	6a 5e                	push   $0x5e
80106fe7:	e9 12 f6 ff ff       	jmp    801065fe <alltraps>

80106fec <vector95>:
80106fec:	6a 00                	push   $0x0
80106fee:	6a 5f                	push   $0x5f
80106ff0:	e9 09 f6 ff ff       	jmp    801065fe <alltraps>

80106ff5 <vector96>:
80106ff5:	6a 00                	push   $0x0
80106ff7:	6a 60                	push   $0x60
80106ff9:	e9 00 f6 ff ff       	jmp    801065fe <alltraps>

80106ffe <vector97>:
80106ffe:	6a 00                	push   $0x0
80107000:	6a 61                	push   $0x61
80107002:	e9 f7 f5 ff ff       	jmp    801065fe <alltraps>

80107007 <vector98>:
80107007:	6a 00                	push   $0x0
80107009:	6a 62                	push   $0x62
8010700b:	e9 ee f5 ff ff       	jmp    801065fe <alltraps>

80107010 <vector99>:
80107010:	6a 00                	push   $0x0
80107012:	6a 63                	push   $0x63
80107014:	e9 e5 f5 ff ff       	jmp    801065fe <alltraps>

80107019 <vector100>:
80107019:	6a 00                	push   $0x0
8010701b:	6a 64                	push   $0x64
8010701d:	e9 dc f5 ff ff       	jmp    801065fe <alltraps>

80107022 <vector101>:
80107022:	6a 00                	push   $0x0
80107024:	6a 65                	push   $0x65
80107026:	e9 d3 f5 ff ff       	jmp    801065fe <alltraps>

8010702b <vector102>:
8010702b:	6a 00                	push   $0x0
8010702d:	6a 66                	push   $0x66
8010702f:	e9 ca f5 ff ff       	jmp    801065fe <alltraps>

80107034 <vector103>:
80107034:	6a 00                	push   $0x0
80107036:	6a 67                	push   $0x67
80107038:	e9 c1 f5 ff ff       	jmp    801065fe <alltraps>

8010703d <vector104>:
8010703d:	6a 00                	push   $0x0
8010703f:	6a 68                	push   $0x68
80107041:	e9 b8 f5 ff ff       	jmp    801065fe <alltraps>

80107046 <vector105>:
80107046:	6a 00                	push   $0x0
80107048:	6a 69                	push   $0x69
8010704a:	e9 af f5 ff ff       	jmp    801065fe <alltraps>

8010704f <vector106>:
8010704f:	6a 00                	push   $0x0
80107051:	6a 6a                	push   $0x6a
80107053:	e9 a6 f5 ff ff       	jmp    801065fe <alltraps>

80107058 <vector107>:
80107058:	6a 00                	push   $0x0
8010705a:	6a 6b                	push   $0x6b
8010705c:	e9 9d f5 ff ff       	jmp    801065fe <alltraps>

80107061 <vector108>:
80107061:	6a 00                	push   $0x0
80107063:	6a 6c                	push   $0x6c
80107065:	e9 94 f5 ff ff       	jmp    801065fe <alltraps>

8010706a <vector109>:
8010706a:	6a 00                	push   $0x0
8010706c:	6a 6d                	push   $0x6d
8010706e:	e9 8b f5 ff ff       	jmp    801065fe <alltraps>

80107073 <vector110>:
80107073:	6a 00                	push   $0x0
80107075:	6a 6e                	push   $0x6e
80107077:	e9 82 f5 ff ff       	jmp    801065fe <alltraps>

8010707c <vector111>:
8010707c:	6a 00                	push   $0x0
8010707e:	6a 6f                	push   $0x6f
80107080:	e9 79 f5 ff ff       	jmp    801065fe <alltraps>

80107085 <vector112>:
80107085:	6a 00                	push   $0x0
80107087:	6a 70                	push   $0x70
80107089:	e9 70 f5 ff ff       	jmp    801065fe <alltraps>

8010708e <vector113>:
8010708e:	6a 00                	push   $0x0
80107090:	6a 71                	push   $0x71
80107092:	e9 67 f5 ff ff       	jmp    801065fe <alltraps>

80107097 <vector114>:
80107097:	6a 00                	push   $0x0
80107099:	6a 72                	push   $0x72
8010709b:	e9 5e f5 ff ff       	jmp    801065fe <alltraps>

801070a0 <vector115>:
801070a0:	6a 00                	push   $0x0
801070a2:	6a 73                	push   $0x73
801070a4:	e9 55 f5 ff ff       	jmp    801065fe <alltraps>

801070a9 <vector116>:
801070a9:	6a 00                	push   $0x0
801070ab:	6a 74                	push   $0x74
801070ad:	e9 4c f5 ff ff       	jmp    801065fe <alltraps>

801070b2 <vector117>:
801070b2:	6a 00                	push   $0x0
801070b4:	6a 75                	push   $0x75
801070b6:	e9 43 f5 ff ff       	jmp    801065fe <alltraps>

801070bb <vector118>:
801070bb:	6a 00                	push   $0x0
801070bd:	6a 76                	push   $0x76
801070bf:	e9 3a f5 ff ff       	jmp    801065fe <alltraps>

801070c4 <vector119>:
801070c4:	6a 00                	push   $0x0
801070c6:	6a 77                	push   $0x77
801070c8:	e9 31 f5 ff ff       	jmp    801065fe <alltraps>

801070cd <vector120>:
801070cd:	6a 00                	push   $0x0
801070cf:	6a 78                	push   $0x78
801070d1:	e9 28 f5 ff ff       	jmp    801065fe <alltraps>

801070d6 <vector121>:
801070d6:	6a 00                	push   $0x0
801070d8:	6a 79                	push   $0x79
801070da:	e9 1f f5 ff ff       	jmp    801065fe <alltraps>

801070df <vector122>:
801070df:	6a 00                	push   $0x0
801070e1:	6a 7a                	push   $0x7a
801070e3:	e9 16 f5 ff ff       	jmp    801065fe <alltraps>

801070e8 <vector123>:
801070e8:	6a 00                	push   $0x0
801070ea:	6a 7b                	push   $0x7b
801070ec:	e9 0d f5 ff ff       	jmp    801065fe <alltraps>

801070f1 <vector124>:
801070f1:	6a 00                	push   $0x0
801070f3:	6a 7c                	push   $0x7c
801070f5:	e9 04 f5 ff ff       	jmp    801065fe <alltraps>

801070fa <vector125>:
801070fa:	6a 00                	push   $0x0
801070fc:	6a 7d                	push   $0x7d
801070fe:	e9 fb f4 ff ff       	jmp    801065fe <alltraps>

80107103 <vector126>:
80107103:	6a 00                	push   $0x0
80107105:	6a 7e                	push   $0x7e
80107107:	e9 f2 f4 ff ff       	jmp    801065fe <alltraps>

8010710c <vector127>:
8010710c:	6a 00                	push   $0x0
8010710e:	6a 7f                	push   $0x7f
80107110:	e9 e9 f4 ff ff       	jmp    801065fe <alltraps>

80107115 <vector128>:
80107115:	6a 00                	push   $0x0
80107117:	68 80 00 00 00       	push   $0x80
8010711c:	e9 dd f4 ff ff       	jmp    801065fe <alltraps>

80107121 <vector129>:
80107121:	6a 00                	push   $0x0
80107123:	68 81 00 00 00       	push   $0x81
80107128:	e9 d1 f4 ff ff       	jmp    801065fe <alltraps>

8010712d <vector130>:
8010712d:	6a 00                	push   $0x0
8010712f:	68 82 00 00 00       	push   $0x82
80107134:	e9 c5 f4 ff ff       	jmp    801065fe <alltraps>

80107139 <vector131>:
80107139:	6a 00                	push   $0x0
8010713b:	68 83 00 00 00       	push   $0x83
80107140:	e9 b9 f4 ff ff       	jmp    801065fe <alltraps>

80107145 <vector132>:
80107145:	6a 00                	push   $0x0
80107147:	68 84 00 00 00       	push   $0x84
8010714c:	e9 ad f4 ff ff       	jmp    801065fe <alltraps>

80107151 <vector133>:
80107151:	6a 00                	push   $0x0
80107153:	68 85 00 00 00       	push   $0x85
80107158:	e9 a1 f4 ff ff       	jmp    801065fe <alltraps>

8010715d <vector134>:
8010715d:	6a 00                	push   $0x0
8010715f:	68 86 00 00 00       	push   $0x86
80107164:	e9 95 f4 ff ff       	jmp    801065fe <alltraps>

80107169 <vector135>:
80107169:	6a 00                	push   $0x0
8010716b:	68 87 00 00 00       	push   $0x87
80107170:	e9 89 f4 ff ff       	jmp    801065fe <alltraps>

80107175 <vector136>:
80107175:	6a 00                	push   $0x0
80107177:	68 88 00 00 00       	push   $0x88
8010717c:	e9 7d f4 ff ff       	jmp    801065fe <alltraps>

80107181 <vector137>:
80107181:	6a 00                	push   $0x0
80107183:	68 89 00 00 00       	push   $0x89
80107188:	e9 71 f4 ff ff       	jmp    801065fe <alltraps>

8010718d <vector138>:
8010718d:	6a 00                	push   $0x0
8010718f:	68 8a 00 00 00       	push   $0x8a
80107194:	e9 65 f4 ff ff       	jmp    801065fe <alltraps>

80107199 <vector139>:
80107199:	6a 00                	push   $0x0
8010719b:	68 8b 00 00 00       	push   $0x8b
801071a0:	e9 59 f4 ff ff       	jmp    801065fe <alltraps>

801071a5 <vector140>:
801071a5:	6a 00                	push   $0x0
801071a7:	68 8c 00 00 00       	push   $0x8c
801071ac:	e9 4d f4 ff ff       	jmp    801065fe <alltraps>

801071b1 <vector141>:
801071b1:	6a 00                	push   $0x0
801071b3:	68 8d 00 00 00       	push   $0x8d
801071b8:	e9 41 f4 ff ff       	jmp    801065fe <alltraps>

801071bd <vector142>:
801071bd:	6a 00                	push   $0x0
801071bf:	68 8e 00 00 00       	push   $0x8e
801071c4:	e9 35 f4 ff ff       	jmp    801065fe <alltraps>

801071c9 <vector143>:
801071c9:	6a 00                	push   $0x0
801071cb:	68 8f 00 00 00       	push   $0x8f
801071d0:	e9 29 f4 ff ff       	jmp    801065fe <alltraps>

801071d5 <vector144>:
801071d5:	6a 00                	push   $0x0
801071d7:	68 90 00 00 00       	push   $0x90
801071dc:	e9 1d f4 ff ff       	jmp    801065fe <alltraps>

801071e1 <vector145>:
801071e1:	6a 00                	push   $0x0
801071e3:	68 91 00 00 00       	push   $0x91
801071e8:	e9 11 f4 ff ff       	jmp    801065fe <alltraps>

801071ed <vector146>:
801071ed:	6a 00                	push   $0x0
801071ef:	68 92 00 00 00       	push   $0x92
801071f4:	e9 05 f4 ff ff       	jmp    801065fe <alltraps>

801071f9 <vector147>:
801071f9:	6a 00                	push   $0x0
801071fb:	68 93 00 00 00       	push   $0x93
80107200:	e9 f9 f3 ff ff       	jmp    801065fe <alltraps>

80107205 <vector148>:
80107205:	6a 00                	push   $0x0
80107207:	68 94 00 00 00       	push   $0x94
8010720c:	e9 ed f3 ff ff       	jmp    801065fe <alltraps>

80107211 <vector149>:
80107211:	6a 00                	push   $0x0
80107213:	68 95 00 00 00       	push   $0x95
80107218:	e9 e1 f3 ff ff       	jmp    801065fe <alltraps>

8010721d <vector150>:
8010721d:	6a 00                	push   $0x0
8010721f:	68 96 00 00 00       	push   $0x96
80107224:	e9 d5 f3 ff ff       	jmp    801065fe <alltraps>

80107229 <vector151>:
80107229:	6a 00                	push   $0x0
8010722b:	68 97 00 00 00       	push   $0x97
80107230:	e9 c9 f3 ff ff       	jmp    801065fe <alltraps>

80107235 <vector152>:
80107235:	6a 00                	push   $0x0
80107237:	68 98 00 00 00       	push   $0x98
8010723c:	e9 bd f3 ff ff       	jmp    801065fe <alltraps>

80107241 <vector153>:
80107241:	6a 00                	push   $0x0
80107243:	68 99 00 00 00       	push   $0x99
80107248:	e9 b1 f3 ff ff       	jmp    801065fe <alltraps>

8010724d <vector154>:
8010724d:	6a 00                	push   $0x0
8010724f:	68 9a 00 00 00       	push   $0x9a
80107254:	e9 a5 f3 ff ff       	jmp    801065fe <alltraps>

80107259 <vector155>:
80107259:	6a 00                	push   $0x0
8010725b:	68 9b 00 00 00       	push   $0x9b
80107260:	e9 99 f3 ff ff       	jmp    801065fe <alltraps>

80107265 <vector156>:
80107265:	6a 00                	push   $0x0
80107267:	68 9c 00 00 00       	push   $0x9c
8010726c:	e9 8d f3 ff ff       	jmp    801065fe <alltraps>

80107271 <vector157>:
80107271:	6a 00                	push   $0x0
80107273:	68 9d 00 00 00       	push   $0x9d
80107278:	e9 81 f3 ff ff       	jmp    801065fe <alltraps>

8010727d <vector158>:
8010727d:	6a 00                	push   $0x0
8010727f:	68 9e 00 00 00       	push   $0x9e
80107284:	e9 75 f3 ff ff       	jmp    801065fe <alltraps>

80107289 <vector159>:
80107289:	6a 00                	push   $0x0
8010728b:	68 9f 00 00 00       	push   $0x9f
80107290:	e9 69 f3 ff ff       	jmp    801065fe <alltraps>

80107295 <vector160>:
80107295:	6a 00                	push   $0x0
80107297:	68 a0 00 00 00       	push   $0xa0
8010729c:	e9 5d f3 ff ff       	jmp    801065fe <alltraps>

801072a1 <vector161>:
801072a1:	6a 00                	push   $0x0
801072a3:	68 a1 00 00 00       	push   $0xa1
801072a8:	e9 51 f3 ff ff       	jmp    801065fe <alltraps>

801072ad <vector162>:
801072ad:	6a 00                	push   $0x0
801072af:	68 a2 00 00 00       	push   $0xa2
801072b4:	e9 45 f3 ff ff       	jmp    801065fe <alltraps>

801072b9 <vector163>:
801072b9:	6a 00                	push   $0x0
801072bb:	68 a3 00 00 00       	push   $0xa3
801072c0:	e9 39 f3 ff ff       	jmp    801065fe <alltraps>

801072c5 <vector164>:
801072c5:	6a 00                	push   $0x0
801072c7:	68 a4 00 00 00       	push   $0xa4
801072cc:	e9 2d f3 ff ff       	jmp    801065fe <alltraps>

801072d1 <vector165>:
801072d1:	6a 00                	push   $0x0
801072d3:	68 a5 00 00 00       	push   $0xa5
801072d8:	e9 21 f3 ff ff       	jmp    801065fe <alltraps>

801072dd <vector166>:
801072dd:	6a 00                	push   $0x0
801072df:	68 a6 00 00 00       	push   $0xa6
801072e4:	e9 15 f3 ff ff       	jmp    801065fe <alltraps>

801072e9 <vector167>:
801072e9:	6a 00                	push   $0x0
801072eb:	68 a7 00 00 00       	push   $0xa7
801072f0:	e9 09 f3 ff ff       	jmp    801065fe <alltraps>

801072f5 <vector168>:
801072f5:	6a 00                	push   $0x0
801072f7:	68 a8 00 00 00       	push   $0xa8
801072fc:	e9 fd f2 ff ff       	jmp    801065fe <alltraps>

80107301 <vector169>:
80107301:	6a 00                	push   $0x0
80107303:	68 a9 00 00 00       	push   $0xa9
80107308:	e9 f1 f2 ff ff       	jmp    801065fe <alltraps>

8010730d <vector170>:
8010730d:	6a 00                	push   $0x0
8010730f:	68 aa 00 00 00       	push   $0xaa
80107314:	e9 e5 f2 ff ff       	jmp    801065fe <alltraps>

80107319 <vector171>:
80107319:	6a 00                	push   $0x0
8010731b:	68 ab 00 00 00       	push   $0xab
80107320:	e9 d9 f2 ff ff       	jmp    801065fe <alltraps>

80107325 <vector172>:
80107325:	6a 00                	push   $0x0
80107327:	68 ac 00 00 00       	push   $0xac
8010732c:	e9 cd f2 ff ff       	jmp    801065fe <alltraps>

80107331 <vector173>:
80107331:	6a 00                	push   $0x0
80107333:	68 ad 00 00 00       	push   $0xad
80107338:	e9 c1 f2 ff ff       	jmp    801065fe <alltraps>

8010733d <vector174>:
8010733d:	6a 00                	push   $0x0
8010733f:	68 ae 00 00 00       	push   $0xae
80107344:	e9 b5 f2 ff ff       	jmp    801065fe <alltraps>

80107349 <vector175>:
80107349:	6a 00                	push   $0x0
8010734b:	68 af 00 00 00       	push   $0xaf
80107350:	e9 a9 f2 ff ff       	jmp    801065fe <alltraps>

80107355 <vector176>:
80107355:	6a 00                	push   $0x0
80107357:	68 b0 00 00 00       	push   $0xb0
8010735c:	e9 9d f2 ff ff       	jmp    801065fe <alltraps>

80107361 <vector177>:
80107361:	6a 00                	push   $0x0
80107363:	68 b1 00 00 00       	push   $0xb1
80107368:	e9 91 f2 ff ff       	jmp    801065fe <alltraps>

8010736d <vector178>:
8010736d:	6a 00                	push   $0x0
8010736f:	68 b2 00 00 00       	push   $0xb2
80107374:	e9 85 f2 ff ff       	jmp    801065fe <alltraps>

80107379 <vector179>:
80107379:	6a 00                	push   $0x0
8010737b:	68 b3 00 00 00       	push   $0xb3
80107380:	e9 79 f2 ff ff       	jmp    801065fe <alltraps>

80107385 <vector180>:
80107385:	6a 00                	push   $0x0
80107387:	68 b4 00 00 00       	push   $0xb4
8010738c:	e9 6d f2 ff ff       	jmp    801065fe <alltraps>

80107391 <vector181>:
80107391:	6a 00                	push   $0x0
80107393:	68 b5 00 00 00       	push   $0xb5
80107398:	e9 61 f2 ff ff       	jmp    801065fe <alltraps>

8010739d <vector182>:
8010739d:	6a 00                	push   $0x0
8010739f:	68 b6 00 00 00       	push   $0xb6
801073a4:	e9 55 f2 ff ff       	jmp    801065fe <alltraps>

801073a9 <vector183>:
801073a9:	6a 00                	push   $0x0
801073ab:	68 b7 00 00 00       	push   $0xb7
801073b0:	e9 49 f2 ff ff       	jmp    801065fe <alltraps>

801073b5 <vector184>:
801073b5:	6a 00                	push   $0x0
801073b7:	68 b8 00 00 00       	push   $0xb8
801073bc:	e9 3d f2 ff ff       	jmp    801065fe <alltraps>

801073c1 <vector185>:
801073c1:	6a 00                	push   $0x0
801073c3:	68 b9 00 00 00       	push   $0xb9
801073c8:	e9 31 f2 ff ff       	jmp    801065fe <alltraps>

801073cd <vector186>:
801073cd:	6a 00                	push   $0x0
801073cf:	68 ba 00 00 00       	push   $0xba
801073d4:	e9 25 f2 ff ff       	jmp    801065fe <alltraps>

801073d9 <vector187>:
801073d9:	6a 00                	push   $0x0
801073db:	68 bb 00 00 00       	push   $0xbb
801073e0:	e9 19 f2 ff ff       	jmp    801065fe <alltraps>

801073e5 <vector188>:
801073e5:	6a 00                	push   $0x0
801073e7:	68 bc 00 00 00       	push   $0xbc
801073ec:	e9 0d f2 ff ff       	jmp    801065fe <alltraps>

801073f1 <vector189>:
801073f1:	6a 00                	push   $0x0
801073f3:	68 bd 00 00 00       	push   $0xbd
801073f8:	e9 01 f2 ff ff       	jmp    801065fe <alltraps>

801073fd <vector190>:
801073fd:	6a 00                	push   $0x0
801073ff:	68 be 00 00 00       	push   $0xbe
80107404:	e9 f5 f1 ff ff       	jmp    801065fe <alltraps>

80107409 <vector191>:
80107409:	6a 00                	push   $0x0
8010740b:	68 bf 00 00 00       	push   $0xbf
80107410:	e9 e9 f1 ff ff       	jmp    801065fe <alltraps>

80107415 <vector192>:
80107415:	6a 00                	push   $0x0
80107417:	68 c0 00 00 00       	push   $0xc0
8010741c:	e9 dd f1 ff ff       	jmp    801065fe <alltraps>

80107421 <vector193>:
80107421:	6a 00                	push   $0x0
80107423:	68 c1 00 00 00       	push   $0xc1
80107428:	e9 d1 f1 ff ff       	jmp    801065fe <alltraps>

8010742d <vector194>:
8010742d:	6a 00                	push   $0x0
8010742f:	68 c2 00 00 00       	push   $0xc2
80107434:	e9 c5 f1 ff ff       	jmp    801065fe <alltraps>

80107439 <vector195>:
80107439:	6a 00                	push   $0x0
8010743b:	68 c3 00 00 00       	push   $0xc3
80107440:	e9 b9 f1 ff ff       	jmp    801065fe <alltraps>

80107445 <vector196>:
80107445:	6a 00                	push   $0x0
80107447:	68 c4 00 00 00       	push   $0xc4
8010744c:	e9 ad f1 ff ff       	jmp    801065fe <alltraps>

80107451 <vector197>:
80107451:	6a 00                	push   $0x0
80107453:	68 c5 00 00 00       	push   $0xc5
80107458:	e9 a1 f1 ff ff       	jmp    801065fe <alltraps>

8010745d <vector198>:
8010745d:	6a 00                	push   $0x0
8010745f:	68 c6 00 00 00       	push   $0xc6
80107464:	e9 95 f1 ff ff       	jmp    801065fe <alltraps>

80107469 <vector199>:
80107469:	6a 00                	push   $0x0
8010746b:	68 c7 00 00 00       	push   $0xc7
80107470:	e9 89 f1 ff ff       	jmp    801065fe <alltraps>

80107475 <vector200>:
80107475:	6a 00                	push   $0x0
80107477:	68 c8 00 00 00       	push   $0xc8
8010747c:	e9 7d f1 ff ff       	jmp    801065fe <alltraps>

80107481 <vector201>:
80107481:	6a 00                	push   $0x0
80107483:	68 c9 00 00 00       	push   $0xc9
80107488:	e9 71 f1 ff ff       	jmp    801065fe <alltraps>

8010748d <vector202>:
8010748d:	6a 00                	push   $0x0
8010748f:	68 ca 00 00 00       	push   $0xca
80107494:	e9 65 f1 ff ff       	jmp    801065fe <alltraps>

80107499 <vector203>:
80107499:	6a 00                	push   $0x0
8010749b:	68 cb 00 00 00       	push   $0xcb
801074a0:	e9 59 f1 ff ff       	jmp    801065fe <alltraps>

801074a5 <vector204>:
801074a5:	6a 00                	push   $0x0
801074a7:	68 cc 00 00 00       	push   $0xcc
801074ac:	e9 4d f1 ff ff       	jmp    801065fe <alltraps>

801074b1 <vector205>:
801074b1:	6a 00                	push   $0x0
801074b3:	68 cd 00 00 00       	push   $0xcd
801074b8:	e9 41 f1 ff ff       	jmp    801065fe <alltraps>

801074bd <vector206>:
801074bd:	6a 00                	push   $0x0
801074bf:	68 ce 00 00 00       	push   $0xce
801074c4:	e9 35 f1 ff ff       	jmp    801065fe <alltraps>

801074c9 <vector207>:
801074c9:	6a 00                	push   $0x0
801074cb:	68 cf 00 00 00       	push   $0xcf
801074d0:	e9 29 f1 ff ff       	jmp    801065fe <alltraps>

801074d5 <vector208>:
801074d5:	6a 00                	push   $0x0
801074d7:	68 d0 00 00 00       	push   $0xd0
801074dc:	e9 1d f1 ff ff       	jmp    801065fe <alltraps>

801074e1 <vector209>:
801074e1:	6a 00                	push   $0x0
801074e3:	68 d1 00 00 00       	push   $0xd1
801074e8:	e9 11 f1 ff ff       	jmp    801065fe <alltraps>

801074ed <vector210>:
801074ed:	6a 00                	push   $0x0
801074ef:	68 d2 00 00 00       	push   $0xd2
801074f4:	e9 05 f1 ff ff       	jmp    801065fe <alltraps>

801074f9 <vector211>:
801074f9:	6a 00                	push   $0x0
801074fb:	68 d3 00 00 00       	push   $0xd3
80107500:	e9 f9 f0 ff ff       	jmp    801065fe <alltraps>

80107505 <vector212>:
80107505:	6a 00                	push   $0x0
80107507:	68 d4 00 00 00       	push   $0xd4
8010750c:	e9 ed f0 ff ff       	jmp    801065fe <alltraps>

80107511 <vector213>:
80107511:	6a 00                	push   $0x0
80107513:	68 d5 00 00 00       	push   $0xd5
80107518:	e9 e1 f0 ff ff       	jmp    801065fe <alltraps>

8010751d <vector214>:
8010751d:	6a 00                	push   $0x0
8010751f:	68 d6 00 00 00       	push   $0xd6
80107524:	e9 d5 f0 ff ff       	jmp    801065fe <alltraps>

80107529 <vector215>:
80107529:	6a 00                	push   $0x0
8010752b:	68 d7 00 00 00       	push   $0xd7
80107530:	e9 c9 f0 ff ff       	jmp    801065fe <alltraps>

80107535 <vector216>:
80107535:	6a 00                	push   $0x0
80107537:	68 d8 00 00 00       	push   $0xd8
8010753c:	e9 bd f0 ff ff       	jmp    801065fe <alltraps>

80107541 <vector217>:
80107541:	6a 00                	push   $0x0
80107543:	68 d9 00 00 00       	push   $0xd9
80107548:	e9 b1 f0 ff ff       	jmp    801065fe <alltraps>

8010754d <vector218>:
8010754d:	6a 00                	push   $0x0
8010754f:	68 da 00 00 00       	push   $0xda
80107554:	e9 a5 f0 ff ff       	jmp    801065fe <alltraps>

80107559 <vector219>:
80107559:	6a 00                	push   $0x0
8010755b:	68 db 00 00 00       	push   $0xdb
80107560:	e9 99 f0 ff ff       	jmp    801065fe <alltraps>

80107565 <vector220>:
80107565:	6a 00                	push   $0x0
80107567:	68 dc 00 00 00       	push   $0xdc
8010756c:	e9 8d f0 ff ff       	jmp    801065fe <alltraps>

80107571 <vector221>:
80107571:	6a 00                	push   $0x0
80107573:	68 dd 00 00 00       	push   $0xdd
80107578:	e9 81 f0 ff ff       	jmp    801065fe <alltraps>

8010757d <vector222>:
8010757d:	6a 00                	push   $0x0
8010757f:	68 de 00 00 00       	push   $0xde
80107584:	e9 75 f0 ff ff       	jmp    801065fe <alltraps>

80107589 <vector223>:
80107589:	6a 00                	push   $0x0
8010758b:	68 df 00 00 00       	push   $0xdf
80107590:	e9 69 f0 ff ff       	jmp    801065fe <alltraps>

80107595 <vector224>:
80107595:	6a 00                	push   $0x0
80107597:	68 e0 00 00 00       	push   $0xe0
8010759c:	e9 5d f0 ff ff       	jmp    801065fe <alltraps>

801075a1 <vector225>:
801075a1:	6a 00                	push   $0x0
801075a3:	68 e1 00 00 00       	push   $0xe1
801075a8:	e9 51 f0 ff ff       	jmp    801065fe <alltraps>

801075ad <vector226>:
801075ad:	6a 00                	push   $0x0
801075af:	68 e2 00 00 00       	push   $0xe2
801075b4:	e9 45 f0 ff ff       	jmp    801065fe <alltraps>

801075b9 <vector227>:
801075b9:	6a 00                	push   $0x0
801075bb:	68 e3 00 00 00       	push   $0xe3
801075c0:	e9 39 f0 ff ff       	jmp    801065fe <alltraps>

801075c5 <vector228>:
801075c5:	6a 00                	push   $0x0
801075c7:	68 e4 00 00 00       	push   $0xe4
801075cc:	e9 2d f0 ff ff       	jmp    801065fe <alltraps>

801075d1 <vector229>:
801075d1:	6a 00                	push   $0x0
801075d3:	68 e5 00 00 00       	push   $0xe5
801075d8:	e9 21 f0 ff ff       	jmp    801065fe <alltraps>

801075dd <vector230>:
801075dd:	6a 00                	push   $0x0
801075df:	68 e6 00 00 00       	push   $0xe6
801075e4:	e9 15 f0 ff ff       	jmp    801065fe <alltraps>

801075e9 <vector231>:
801075e9:	6a 00                	push   $0x0
801075eb:	68 e7 00 00 00       	push   $0xe7
801075f0:	e9 09 f0 ff ff       	jmp    801065fe <alltraps>

801075f5 <vector232>:
801075f5:	6a 00                	push   $0x0
801075f7:	68 e8 00 00 00       	push   $0xe8
801075fc:	e9 fd ef ff ff       	jmp    801065fe <alltraps>

80107601 <vector233>:
80107601:	6a 00                	push   $0x0
80107603:	68 e9 00 00 00       	push   $0xe9
80107608:	e9 f1 ef ff ff       	jmp    801065fe <alltraps>

8010760d <vector234>:
8010760d:	6a 00                	push   $0x0
8010760f:	68 ea 00 00 00       	push   $0xea
80107614:	e9 e5 ef ff ff       	jmp    801065fe <alltraps>

80107619 <vector235>:
80107619:	6a 00                	push   $0x0
8010761b:	68 eb 00 00 00       	push   $0xeb
80107620:	e9 d9 ef ff ff       	jmp    801065fe <alltraps>

80107625 <vector236>:
80107625:	6a 00                	push   $0x0
80107627:	68 ec 00 00 00       	push   $0xec
8010762c:	e9 cd ef ff ff       	jmp    801065fe <alltraps>

80107631 <vector237>:
80107631:	6a 00                	push   $0x0
80107633:	68 ed 00 00 00       	push   $0xed
80107638:	e9 c1 ef ff ff       	jmp    801065fe <alltraps>

8010763d <vector238>:
8010763d:	6a 00                	push   $0x0
8010763f:	68 ee 00 00 00       	push   $0xee
80107644:	e9 b5 ef ff ff       	jmp    801065fe <alltraps>

80107649 <vector239>:
80107649:	6a 00                	push   $0x0
8010764b:	68 ef 00 00 00       	push   $0xef
80107650:	e9 a9 ef ff ff       	jmp    801065fe <alltraps>

80107655 <vector240>:
80107655:	6a 00                	push   $0x0
80107657:	68 f0 00 00 00       	push   $0xf0
8010765c:	e9 9d ef ff ff       	jmp    801065fe <alltraps>

80107661 <vector241>:
80107661:	6a 00                	push   $0x0
80107663:	68 f1 00 00 00       	push   $0xf1
80107668:	e9 91 ef ff ff       	jmp    801065fe <alltraps>

8010766d <vector242>:
8010766d:	6a 00                	push   $0x0
8010766f:	68 f2 00 00 00       	push   $0xf2
80107674:	e9 85 ef ff ff       	jmp    801065fe <alltraps>

80107679 <vector243>:
80107679:	6a 00                	push   $0x0
8010767b:	68 f3 00 00 00       	push   $0xf3
80107680:	e9 79 ef ff ff       	jmp    801065fe <alltraps>

80107685 <vector244>:
80107685:	6a 00                	push   $0x0
80107687:	68 f4 00 00 00       	push   $0xf4
8010768c:	e9 6d ef ff ff       	jmp    801065fe <alltraps>

80107691 <vector245>:
80107691:	6a 00                	push   $0x0
80107693:	68 f5 00 00 00       	push   $0xf5
80107698:	e9 61 ef ff ff       	jmp    801065fe <alltraps>

8010769d <vector246>:
8010769d:	6a 00                	push   $0x0
8010769f:	68 f6 00 00 00       	push   $0xf6
801076a4:	e9 55 ef ff ff       	jmp    801065fe <alltraps>

801076a9 <vector247>:
801076a9:	6a 00                	push   $0x0
801076ab:	68 f7 00 00 00       	push   $0xf7
801076b0:	e9 49 ef ff ff       	jmp    801065fe <alltraps>

801076b5 <vector248>:
801076b5:	6a 00                	push   $0x0
801076b7:	68 f8 00 00 00       	push   $0xf8
801076bc:	e9 3d ef ff ff       	jmp    801065fe <alltraps>

801076c1 <vector249>:
801076c1:	6a 00                	push   $0x0
801076c3:	68 f9 00 00 00       	push   $0xf9
801076c8:	e9 31 ef ff ff       	jmp    801065fe <alltraps>

801076cd <vector250>:
801076cd:	6a 00                	push   $0x0
801076cf:	68 fa 00 00 00       	push   $0xfa
801076d4:	e9 25 ef ff ff       	jmp    801065fe <alltraps>

801076d9 <vector251>:
801076d9:	6a 00                	push   $0x0
801076db:	68 fb 00 00 00       	push   $0xfb
801076e0:	e9 19 ef ff ff       	jmp    801065fe <alltraps>

801076e5 <vector252>:
801076e5:	6a 00                	push   $0x0
801076e7:	68 fc 00 00 00       	push   $0xfc
801076ec:	e9 0d ef ff ff       	jmp    801065fe <alltraps>

801076f1 <vector253>:
801076f1:	6a 00                	push   $0x0
801076f3:	68 fd 00 00 00       	push   $0xfd
801076f8:	e9 01 ef ff ff       	jmp    801065fe <alltraps>

801076fd <vector254>:
801076fd:	6a 00                	push   $0x0
801076ff:	68 fe 00 00 00       	push   $0xfe
80107704:	e9 f5 ee ff ff       	jmp    801065fe <alltraps>

80107709 <vector255>:
80107709:	6a 00                	push   $0x0
8010770b:	68 ff 00 00 00       	push   $0xff
80107710:	e9 e9 ee ff ff       	jmp    801065fe <alltraps>

80107715 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107715:	55                   	push   %ebp
80107716:	89 e5                	mov    %esp,%ebp
80107718:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010771b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010771e:	83 e8 01             	sub    $0x1,%eax
80107721:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107725:	8b 45 08             	mov    0x8(%ebp),%eax
80107728:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010772c:	8b 45 08             	mov    0x8(%ebp),%eax
8010772f:	c1 e8 10             	shr    $0x10,%eax
80107732:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107736:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107739:	0f 01 10             	lgdtl  (%eax)
}
8010773c:	c9                   	leave  
8010773d:	c3                   	ret    

8010773e <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
8010773e:	55                   	push   %ebp
8010773f:	89 e5                	mov    %esp,%ebp
80107741:	83 ec 04             	sub    $0x4,%esp
80107744:	8b 45 08             	mov    0x8(%ebp),%eax
80107747:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010774b:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010774f:	0f 00 d8             	ltr    %ax
}
80107752:	c9                   	leave  
80107753:	c3                   	ret    

80107754 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107754:	55                   	push   %ebp
80107755:	89 e5                	mov    %esp,%ebp
80107757:	83 ec 04             	sub    $0x4,%esp
8010775a:	8b 45 08             	mov    0x8(%ebp),%eax
8010775d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107761:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107765:	8e e8                	mov    %eax,%gs
}
80107767:	c9                   	leave  
80107768:	c3                   	ret    

80107769 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80107769:	55                   	push   %ebp
8010776a:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010776c:	8b 45 08             	mov    0x8(%ebp),%eax
8010776f:	0f 22 d8             	mov    %eax,%cr3
}
80107772:	5d                   	pop    %ebp
80107773:	c3                   	ret    

80107774 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107774:	55                   	push   %ebp
80107775:	89 e5                	mov    %esp,%ebp
80107777:	8b 45 08             	mov    0x8(%ebp),%eax
8010777a:	05 00 00 00 80       	add    $0x80000000,%eax
8010777f:	5d                   	pop    %ebp
80107780:	c3                   	ret    

80107781 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107781:	55                   	push   %ebp
80107782:	89 e5                	mov    %esp,%ebp
80107784:	8b 45 08             	mov    0x8(%ebp),%eax
80107787:	05 00 00 00 80       	add    $0x80000000,%eax
8010778c:	5d                   	pop    %ebp
8010778d:	c3                   	ret    

8010778e <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010778e:	55                   	push   %ebp
8010778f:	89 e5                	mov    %esp,%ebp
80107791:	53                   	push   %ebx
80107792:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107795:	e8 e0 b6 ff ff       	call   80102e7a <cpunum>
8010779a:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801077a0:	05 20 09 11 80       	add    $0x80110920,%eax
801077a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801077a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ab:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801077b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077b4:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801077ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077bd:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801077c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077c4:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801077c8:	83 e2 f0             	and    $0xfffffff0,%edx
801077cb:	83 ca 0a             	or     $0xa,%edx
801077ce:	88 50 7d             	mov    %dl,0x7d(%eax)
801077d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077d4:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801077d8:	83 ca 10             	or     $0x10,%edx
801077db:	88 50 7d             	mov    %dl,0x7d(%eax)
801077de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077e1:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801077e5:	83 e2 9f             	and    $0xffffff9f,%edx
801077e8:	88 50 7d             	mov    %dl,0x7d(%eax)
801077eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ee:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801077f2:	83 ca 80             	or     $0xffffff80,%edx
801077f5:	88 50 7d             	mov    %dl,0x7d(%eax)
801077f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077fb:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801077ff:	83 ca 0f             	or     $0xf,%edx
80107802:	88 50 7e             	mov    %dl,0x7e(%eax)
80107805:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107808:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010780c:	83 e2 ef             	and    $0xffffffef,%edx
8010780f:	88 50 7e             	mov    %dl,0x7e(%eax)
80107812:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107815:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107819:	83 e2 df             	and    $0xffffffdf,%edx
8010781c:	88 50 7e             	mov    %dl,0x7e(%eax)
8010781f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107822:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107826:	83 ca 40             	or     $0x40,%edx
80107829:	88 50 7e             	mov    %dl,0x7e(%eax)
8010782c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010782f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107833:	83 ca 80             	or     $0xffffff80,%edx
80107836:	88 50 7e             	mov    %dl,0x7e(%eax)
80107839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010783c:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107840:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107843:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
8010784a:	ff ff 
8010784c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010784f:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107856:	00 00 
80107858:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010785b:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107862:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107865:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010786c:	83 e2 f0             	and    $0xfffffff0,%edx
8010786f:	83 ca 02             	or     $0x2,%edx
80107872:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107878:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010787b:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107882:	83 ca 10             	or     $0x10,%edx
80107885:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010788b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010788e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107895:	83 e2 9f             	and    $0xffffff9f,%edx
80107898:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010789e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a1:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801078a8:	83 ca 80             	or     $0xffffff80,%edx
801078ab:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801078b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078b4:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801078bb:	83 ca 0f             	or     $0xf,%edx
801078be:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801078c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078c7:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801078ce:	83 e2 ef             	and    $0xffffffef,%edx
801078d1:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801078d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078da:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801078e1:	83 e2 df             	and    $0xffffffdf,%edx
801078e4:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801078ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ed:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801078f4:	83 ca 40             	or     $0x40,%edx
801078f7:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801078fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107900:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107907:	83 ca 80             	or     $0xffffff80,%edx
8010790a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107910:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107913:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
8010791a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010791d:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107924:	ff ff 
80107926:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107929:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107930:	00 00 
80107932:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107935:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
8010793c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010793f:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107946:	83 e2 f0             	and    $0xfffffff0,%edx
80107949:	83 ca 0a             	or     $0xa,%edx
8010794c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107952:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107955:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010795c:	83 ca 10             	or     $0x10,%edx
8010795f:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107965:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107968:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010796f:	83 ca 60             	or     $0x60,%edx
80107972:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107978:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010797b:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107982:	83 ca 80             	or     $0xffffff80,%edx
80107985:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010798b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010798e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107995:	83 ca 0f             	or     $0xf,%edx
80107998:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010799e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a1:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801079a8:	83 e2 ef             	and    $0xffffffef,%edx
801079ab:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801079b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079b4:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801079bb:	83 e2 df             	and    $0xffffffdf,%edx
801079be:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801079c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c7:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801079ce:	83 ca 40             	or     $0x40,%edx
801079d1:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801079d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079da:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801079e1:	83 ca 80             	or     $0xffffff80,%edx
801079e4:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801079ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ed:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801079f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f7:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
801079fe:	ff ff 
80107a00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a03:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107a0a:	00 00 
80107a0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a0f:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107a16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a19:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107a20:	83 e2 f0             	and    $0xfffffff0,%edx
80107a23:	83 ca 02             	or     $0x2,%edx
80107a26:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a2f:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107a36:	83 ca 10             	or     $0x10,%edx
80107a39:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a42:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107a49:	83 ca 60             	or     $0x60,%edx
80107a4c:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a55:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107a5c:	83 ca 80             	or     $0xffffff80,%edx
80107a5f:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107a65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a68:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107a6f:	83 ca 0f             	or     $0xf,%edx
80107a72:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7b:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107a82:	83 e2 ef             	and    $0xffffffef,%edx
80107a85:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a8e:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107a95:	83 e2 df             	and    $0xffffffdf,%edx
80107a98:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa1:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107aa8:	83 ca 40             	or     $0x40,%edx
80107aab:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107ab1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab4:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107abb:	83 ca 80             	or     $0xffffff80,%edx
80107abe:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac7:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

//   // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad1:	05 b4 00 00 00       	add    $0xb4,%eax
80107ad6:	89 c3                	mov    %eax,%ebx
80107ad8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107adb:	05 b4 00 00 00       	add    $0xb4,%eax
80107ae0:	c1 e8 10             	shr    $0x10,%eax
80107ae3:	89 c1                	mov    %eax,%ecx
80107ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae8:	05 b4 00 00 00       	add    $0xb4,%eax
80107aed:	c1 e8 18             	shr    $0x18,%eax
80107af0:	89 c2                	mov    %eax,%edx
80107af2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af5:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107afc:	00 00 
80107afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b01:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0b:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80107b11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b14:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107b1b:	83 e1 f0             	and    $0xfffffff0,%ecx
80107b1e:	83 c9 02             	or     $0x2,%ecx
80107b21:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107b27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b2a:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107b31:	83 c9 10             	or     $0x10,%ecx
80107b34:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107b3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b3d:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107b44:	83 e1 9f             	and    $0xffffff9f,%ecx
80107b47:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b50:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107b57:	83 c9 80             	or     $0xffffff80,%ecx
80107b5a:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107b60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b63:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107b6a:	83 e1 f0             	and    $0xfffffff0,%ecx
80107b6d:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107b73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b76:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107b7d:	83 e1 ef             	and    $0xffffffef,%ecx
80107b80:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b89:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107b90:	83 e1 df             	and    $0xffffffdf,%ecx
80107b93:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107b99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b9c:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107ba3:	83 c9 40             	or     $0x40,%ecx
80107ba6:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107baf:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107bb6:	83 c9 80             	or     $0xffffff80,%ecx
80107bb9:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc2:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107bc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bcb:	83 c0 70             	add    $0x70,%eax
80107bce:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80107bd5:	00 
80107bd6:	89 04 24             	mov    %eax,(%esp)
80107bd9:	e8 37 fb ff ff       	call   80107715 <lgdt>
  loadgs(SEG_KCPU << 3);
80107bde:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80107be5:	e8 6a fb ff ff       	call   80107754 <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80107bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bed:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107bf3:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107bfa:	00 00 00 00 
  
  initlock(&num_of_shareslock, "sharedLock");
80107bfe:	c7 44 24 04 28 90 10 	movl   $0x80109028,0x4(%esp)
80107c05:	80 
80107c06:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
80107c0d:	e8 47 d3 ff ff       	call   80104f59 <initlock>
}
80107c12:	83 c4 24             	add    $0x24,%esp
80107c15:	5b                   	pop    %ebx
80107c16:	5d                   	pop    %ebp
80107c17:	c3                   	ret    

80107c18 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107c18:	55                   	push   %ebp
80107c19:	89 e5                	mov    %esp,%ebp
80107c1b:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;
  
  //PDX - entry that the 10 first bits points to.
  pde = &pgdir[PDX(va)];
80107c1e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c21:	c1 e8 16             	shr    $0x16,%eax
80107c24:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107c2b:	8b 45 08             	mov    0x8(%ebp),%eax
80107c2e:	01 d0                	add    %edx,%eax
80107c30:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107c33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c36:	8b 00                	mov    (%eax),%eax
80107c38:	83 e0 01             	and    $0x1,%eax
80107c3b:	85 c0                	test   %eax,%eax
80107c3d:	74 17                	je     80107c56 <walkpgdir+0x3e>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107c3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c42:	8b 00                	mov    (%eax),%eax
80107c44:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c49:	89 04 24             	mov    %eax,(%esp)
80107c4c:	e8 30 fb ff ff       	call   80107781 <p2v>
80107c51:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107c54:	eb 4b                	jmp    80107ca1 <walkpgdir+0x89>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107c56:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107c5a:	74 0e                	je     80107c6a <walkpgdir+0x52>
80107c5c:	e8 a0 ae ff ff       	call   80102b01 <kalloc>
80107c61:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107c64:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107c68:	75 07                	jne    80107c71 <walkpgdir+0x59>
      return 0;
80107c6a:	b8 00 00 00 00       	mov    $0x0,%eax
80107c6f:	eb 47                	jmp    80107cb8 <walkpgdir+0xa0>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107c71:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107c78:	00 
80107c79:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107c80:	00 
80107c81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c84:	89 04 24             	mov    %eax,(%esp)
80107c87:	e8 42 d5 ff ff       	call   801051ce <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107c8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c8f:	89 04 24             	mov    %eax,(%esp)
80107c92:	e8 dd fa ff ff       	call   80107774 <v2p>
80107c97:	83 c8 07             	or     $0x7,%eax
80107c9a:	89 c2                	mov    %eax,%edx
80107c9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c9f:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107ca1:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ca4:	c1 e8 0c             	shr    $0xc,%eax
80107ca7:	25 ff 03 00 00       	and    $0x3ff,%eax
80107cac:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb6:	01 d0                	add    %edx,%eax
}
80107cb8:	c9                   	leave  
80107cb9:	c3                   	ret    

80107cba <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107cba:	55                   	push   %ebp
80107cbb:	89 e5                	mov    %esp,%ebp
80107cbd:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107cc0:	8b 45 0c             	mov    0xc(%ebp),%eax
80107cc3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107cc8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107ccb:	8b 55 0c             	mov    0xc(%ebp),%edx
80107cce:	8b 45 10             	mov    0x10(%ebp),%eax
80107cd1:	01 d0                	add    %edx,%eax
80107cd3:	83 e8 01             	sub    $0x1,%eax
80107cd6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107cdb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107cde:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107ce5:	00 
80107ce6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce9:	89 44 24 04          	mov    %eax,0x4(%esp)
80107ced:	8b 45 08             	mov    0x8(%ebp),%eax
80107cf0:	89 04 24             	mov    %eax,(%esp)
80107cf3:	e8 20 ff ff ff       	call   80107c18 <walkpgdir>
80107cf8:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107cfb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107cff:	75 07                	jne    80107d08 <mappages+0x4e>
      return -1;
80107d01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d06:	eb 48                	jmp    80107d50 <mappages+0x96>
    if(*pte & PTE_P)
80107d08:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d0b:	8b 00                	mov    (%eax),%eax
80107d0d:	83 e0 01             	and    $0x1,%eax
80107d10:	85 c0                	test   %eax,%eax
80107d12:	74 0c                	je     80107d20 <mappages+0x66>
      panic("remap");
80107d14:	c7 04 24 33 90 10 80 	movl   $0x80109033,(%esp)
80107d1b:	e8 1a 88 ff ff       	call   8010053a <panic>
    
    
    *pte = pa | perm | PTE_P;
80107d20:	8b 45 18             	mov    0x18(%ebp),%eax
80107d23:	0b 45 14             	or     0x14(%ebp),%eax
80107d26:	83 c8 01             	or     $0x1,%eax
80107d29:	89 c2                	mov    %eax,%edx
80107d2b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d2e:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107d30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d33:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107d36:	75 08                	jne    80107d40 <mappages+0x86>
      break;
80107d38:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107d39:	b8 00 00 00 00       	mov    $0x0,%eax
80107d3e:	eb 10                	jmp    80107d50 <mappages+0x96>
    
    
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
80107d40:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107d47:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107d4e:	eb 8e                	jmp    80107cde <mappages+0x24>
  return 0;
}
80107d50:	c9                   	leave  
80107d51:	c3                   	ret    

80107d52 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm()
{
80107d52:	55                   	push   %ebp
80107d53:	89 e5                	mov    %esp,%ebp
80107d55:	53                   	push   %ebx
80107d56:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107d59:	e8 a3 ad ff ff       	call   80102b01 <kalloc>
80107d5e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107d61:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107d65:	75 0a                	jne    80107d71 <setupkvm+0x1f>
    return 0;
80107d67:	b8 00 00 00 00       	mov    $0x0,%eax
80107d6c:	e9 98 00 00 00       	jmp    80107e09 <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
80107d71:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107d78:	00 
80107d79:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107d80:	00 
80107d81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d84:	89 04 24             	mov    %eax,(%esp)
80107d87:	e8 42 d4 ff ff       	call   801051ce <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80107d8c:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
80107d93:	e8 e9 f9 ff ff       	call   80107781 <p2v>
80107d98:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80107d9d:	76 0c                	jbe    80107dab <setupkvm+0x59>
    panic("PHYSTOP too high");
80107d9f:	c7 04 24 39 90 10 80 	movl   $0x80109039,(%esp)
80107da6:	e8 8f 87 ff ff       	call   8010053a <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107dab:	c7 45 f4 a0 c4 10 80 	movl   $0x8010c4a0,-0xc(%ebp)
80107db2:	eb 49                	jmp    80107dfd <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, (uint)k->phys_start, k->perm) < 0)
80107db4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db7:	8b 48 0c             	mov    0xc(%eax),%ecx
80107dba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dbd:	8b 50 04             	mov    0x4(%eax),%edx
80107dc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc3:	8b 58 08             	mov    0x8(%eax),%ebx
80107dc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc9:	8b 40 04             	mov    0x4(%eax),%eax
80107dcc:	29 c3                	sub    %eax,%ebx
80107dce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd1:	8b 00                	mov    (%eax),%eax
80107dd3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80107dd7:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107ddb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107ddf:	89 44 24 04          	mov    %eax,0x4(%esp)
80107de3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107de6:	89 04 24             	mov    %eax,(%esp)
80107de9:	e8 cc fe ff ff       	call   80107cba <mappages>
80107dee:	85 c0                	test   %eax,%eax
80107df0:	79 07                	jns    80107df9 <setupkvm+0xa7>
      return 0;
80107df2:	b8 00 00 00 00       	mov    $0x0,%eax
80107df7:	eb 10                	jmp    80107e09 <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107df9:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107dfd:	81 7d f4 e0 c4 10 80 	cmpl   $0x8010c4e0,-0xc(%ebp)
80107e04:	72 ae                	jb     80107db4 <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80107e06:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107e09:	83 c4 34             	add    $0x34,%esp
80107e0c:	5b                   	pop    %ebx
80107e0d:	5d                   	pop    %ebp
80107e0e:	c3                   	ret    

80107e0f <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107e0f:	55                   	push   %ebp
80107e10:	89 e5                	mov    %esp,%ebp
80107e12:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107e15:	e8 38 ff ff ff       	call   80107d52 <setupkvm>
80107e1a:	a3 34 37 11 80       	mov    %eax,0x80113734
  switchkvm();
80107e1f:	e8 02 00 00 00       	call   80107e26 <switchkvm>
}
80107e24:	c9                   	leave  
80107e25:	c3                   	ret    

80107e26 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107e26:	55                   	push   %ebp
80107e27:	89 e5                	mov    %esp,%ebp
80107e29:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80107e2c:	a1 34 37 11 80       	mov    0x80113734,%eax
80107e31:	89 04 24             	mov    %eax,(%esp)
80107e34:	e8 3b f9 ff ff       	call   80107774 <v2p>
80107e39:	89 04 24             	mov    %eax,(%esp)
80107e3c:	e8 28 f9 ff ff       	call   80107769 <lcr3>
}
80107e41:	c9                   	leave  
80107e42:	c3                   	ret    

80107e43 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107e43:	55                   	push   %ebp
80107e44:	89 e5                	mov    %esp,%ebp
80107e46:	53                   	push   %ebx
80107e47:	83 ec 14             	sub    $0x14,%esp
  pushcli();
80107e4a:	e8 7f d2 ff ff       	call   801050ce <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80107e4f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107e55:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107e5c:	83 c2 08             	add    $0x8,%edx
80107e5f:	89 d3                	mov    %edx,%ebx
80107e61:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107e68:	83 c2 08             	add    $0x8,%edx
80107e6b:	c1 ea 10             	shr    $0x10,%edx
80107e6e:	89 d1                	mov    %edx,%ecx
80107e70:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107e77:	83 c2 08             	add    $0x8,%edx
80107e7a:	c1 ea 18             	shr    $0x18,%edx
80107e7d:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80107e84:	67 00 
80107e86:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
80107e8d:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
80107e93:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107e9a:	83 e1 f0             	and    $0xfffffff0,%ecx
80107e9d:	83 c9 09             	or     $0x9,%ecx
80107ea0:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107ea6:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107ead:	83 c9 10             	or     $0x10,%ecx
80107eb0:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107eb6:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107ebd:	83 e1 9f             	and    $0xffffff9f,%ecx
80107ec0:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107ec6:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107ecd:	83 c9 80             	or     $0xffffff80,%ecx
80107ed0:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107ed6:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107edd:	83 e1 f0             	and    $0xfffffff0,%ecx
80107ee0:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107ee6:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107eed:	83 e1 ef             	and    $0xffffffef,%ecx
80107ef0:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107ef6:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107efd:	83 e1 df             	and    $0xffffffdf,%ecx
80107f00:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107f06:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107f0d:	83 c9 40             	or     $0x40,%ecx
80107f10:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107f16:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107f1d:	83 e1 7f             	and    $0x7f,%ecx
80107f20:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107f26:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80107f2c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107f32:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107f39:	83 e2 ef             	and    $0xffffffef,%edx
80107f3c:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80107f42:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107f48:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80107f4e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107f54:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80107f5b:	8b 52 08             	mov    0x8(%edx),%edx
80107f5e:	81 c2 00 10 00 00    	add    $0x1000,%edx
80107f64:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80107f67:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
80107f6e:	e8 cb f7 ff ff       	call   8010773e <ltr>
  if(p->pgdir == 0)
80107f73:	8b 45 08             	mov    0x8(%ebp),%eax
80107f76:	8b 40 04             	mov    0x4(%eax),%eax
80107f79:	85 c0                	test   %eax,%eax
80107f7b:	75 0c                	jne    80107f89 <switchuvm+0x146>
    panic("switchuvm: no pgdir");
80107f7d:	c7 04 24 4a 90 10 80 	movl   $0x8010904a,(%esp)
80107f84:	e8 b1 85 ff ff       	call   8010053a <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80107f89:	8b 45 08             	mov    0x8(%ebp),%eax
80107f8c:	8b 40 04             	mov    0x4(%eax),%eax
80107f8f:	89 04 24             	mov    %eax,(%esp)
80107f92:	e8 dd f7 ff ff       	call   80107774 <v2p>
80107f97:	89 04 24             	mov    %eax,(%esp)
80107f9a:	e8 ca f7 ff ff       	call   80107769 <lcr3>
  popcli();
80107f9f:	e8 6e d1 ff ff       	call   80105112 <popcli>
}
80107fa4:	83 c4 14             	add    $0x14,%esp
80107fa7:	5b                   	pop    %ebx
80107fa8:	5d                   	pop    %ebp
80107fa9:	c3                   	ret    

80107faa <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107faa:	55                   	push   %ebp
80107fab:	89 e5                	mov    %esp,%ebp
80107fad:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80107fb0:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107fb7:	76 0c                	jbe    80107fc5 <inituvm+0x1b>
    panic("inituvm: more than a page");
80107fb9:	c7 04 24 5e 90 10 80 	movl   $0x8010905e,(%esp)
80107fc0:	e8 75 85 ff ff       	call   8010053a <panic>
  mem = kalloc();
80107fc5:	e8 37 ab ff ff       	call   80102b01 <kalloc>
80107fca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107fcd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107fd4:	00 
80107fd5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107fdc:	00 
80107fdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fe0:	89 04 24             	mov    %eax,(%esp)
80107fe3:	e8 e6 d1 ff ff       	call   801051ce <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80107fe8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107feb:	89 04 24             	mov    %eax,(%esp)
80107fee:	e8 81 f7 ff ff       	call   80107774 <v2p>
80107ff3:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80107ffa:	00 
80107ffb:	89 44 24 0c          	mov    %eax,0xc(%esp)
80107fff:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108006:	00 
80108007:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010800e:	00 
8010800f:	8b 45 08             	mov    0x8(%ebp),%eax
80108012:	89 04 24             	mov    %eax,(%esp)
80108015:	e8 a0 fc ff ff       	call   80107cba <mappages>
  memmove(mem, init, sz);
8010801a:	8b 45 10             	mov    0x10(%ebp),%eax
8010801d:	89 44 24 08          	mov    %eax,0x8(%esp)
80108021:	8b 45 0c             	mov    0xc(%ebp),%eax
80108024:	89 44 24 04          	mov    %eax,0x4(%esp)
80108028:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010802b:	89 04 24             	mov    %eax,(%esp)
8010802e:	e8 6a d2 ff ff       	call   8010529d <memmove>
}
80108033:	c9                   	leave  
80108034:	c3                   	ret    

80108035 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz,uint writeFlag)
{
80108035:	55                   	push   %ebp
80108036:	89 e5                	mov    %esp,%ebp
80108038:	53                   	push   %ebx
80108039:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;
  
  //if((uint) addr % PGSIZE != 0)
    //panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE) {
8010803c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108043:	e9 db 00 00 00       	jmp    80108123 <loaduvm+0xee>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108048:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010804b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010804e:	01 d0                	add    %edx,%eax
80108050:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108057:	00 
80108058:	89 44 24 04          	mov    %eax,0x4(%esp)
8010805c:	8b 45 08             	mov    0x8(%ebp),%eax
8010805f:	89 04 24             	mov    %eax,(%esp)
80108062:	e8 b1 fb ff ff       	call   80107c18 <walkpgdir>
80108067:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010806a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010806e:	75 0c                	jne    8010807c <loaduvm+0x47>
      panic("loaduvm: address should exist");
80108070:	c7 04 24 78 90 10 80 	movl   $0x80109078,(%esp)
80108077:	e8 be 84 ff ff       	call   8010053a <panic>

	// TASK3 Se for permitida a escrita adicionamos a FLAG de escrita, caso contrário removemos ela.
	// Essa flag é adicionada de acordo com o cabeçalho ELF
    if (writeFlag)
8010807c:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
80108080:	74 11                	je     80108093 <loaduvm+0x5e>
    	*pte |= PTE_W;
80108082:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108085:	8b 00                	mov    (%eax),%eax
80108087:	83 c8 02             	or     $0x2,%eax
8010808a:	89 c2                	mov    %eax,%edx
8010808c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010808f:	89 10                	mov    %edx,(%eax)
80108091:	eb 0f                	jmp    801080a2 <loaduvm+0x6d>
    else
    	*pte &= ~PTE_W;
80108093:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108096:	8b 00                	mov    (%eax),%eax
80108098:	83 e0 fd             	and    $0xfffffffd,%eax
8010809b:	89 c2                	mov    %eax,%edx
8010809d:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080a0:	89 10                	mov    %edx,(%eax)

	// TASK3 adiciona deslocamento para alinhamento da pagina, isso garante alinhamento !!!
    pa = PTE_ADDR(*pte) + ((uint)(addr)%PGSIZE);
801080a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080a5:	8b 00                	mov    (%eax),%eax
801080a7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080ac:	89 c2                	mov    %eax,%edx
801080ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801080b1:	25 ff 0f 00 00       	and    $0xfff,%eax
801080b6:	01 d0                	add    %edx,%eax
801080b8:	89 45 e8             	mov    %eax,-0x18(%ebp)

    if(sz - i < PGSIZE)
801080bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080be:	8b 55 18             	mov    0x18(%ebp),%edx
801080c1:	29 c2                	sub    %eax,%edx
801080c3:	89 d0                	mov    %edx,%eax
801080c5:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801080ca:	77 0f                	ja     801080db <loaduvm+0xa6>
      n = sz - i;
801080cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080cf:	8b 55 18             	mov    0x18(%ebp),%edx
801080d2:	29 c2                	sub    %eax,%edx
801080d4:	89 d0                	mov    %edx,%eax
801080d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801080d9:	eb 07                	jmp    801080e2 <loaduvm+0xad>
    else
      n = PGSIZE;
801080db:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
801080e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080e5:	8b 55 14             	mov    0x14(%ebp),%edx
801080e8:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801080eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801080ee:	89 04 24             	mov    %eax,(%esp)
801080f1:	e8 8b f6 ff ff       	call   80107781 <p2v>
801080f6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801080f9:	89 54 24 0c          	mov    %edx,0xc(%esp)
801080fd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108101:	89 44 24 04          	mov    %eax,0x4(%esp)
80108105:	8b 45 10             	mov    0x10(%ebp),%eax
80108108:	89 04 24             	mov    %eax,(%esp)
8010810b:	e8 77 9c ff ff       	call   80101d87 <readi>
80108110:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108113:	74 07                	je     8010811c <loaduvm+0xe7>
      return -1;
80108115:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010811a:	eb 18                	jmp    80108134 <loaduvm+0xff>
  uint i, pa, n;
  pte_t *pte;
  
  //if((uint) addr % PGSIZE != 0)
    //panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE) {
8010811c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108123:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108126:	3b 45 18             	cmp    0x18(%ebp),%eax
80108129:	0f 82 19 ff ff ff    	jb     80108048 <loaduvm+0x13>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
8010812f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108134:	83 c4 24             	add    $0x24,%esp
80108137:	5b                   	pop    %ebx
80108138:	5d                   	pop    %ebp
80108139:	c3                   	ret    

8010813a <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010813a:	55                   	push   %ebp
8010813b:	89 e5                	mov    %esp,%ebp
8010813d:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108140:	8b 45 10             	mov    0x10(%ebp),%eax
80108143:	85 c0                	test   %eax,%eax
80108145:	79 0a                	jns    80108151 <allocuvm+0x17>
    return 0;
80108147:	b8 00 00 00 00       	mov    $0x0,%eax
8010814c:	e9 c1 00 00 00       	jmp    80108212 <allocuvm+0xd8>
  if(newsz < oldsz)
80108151:	8b 45 10             	mov    0x10(%ebp),%eax
80108154:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108157:	73 08                	jae    80108161 <allocuvm+0x27>
    return oldsz;
80108159:	8b 45 0c             	mov    0xc(%ebp),%eax
8010815c:	e9 b1 00 00 00       	jmp    80108212 <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
80108161:	8b 45 0c             	mov    0xc(%ebp),%eax
80108164:	05 ff 0f 00 00       	add    $0xfff,%eax
80108169:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010816e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108171:	e9 8d 00 00 00       	jmp    80108203 <allocuvm+0xc9>
    mem = kalloc();
80108176:	e8 86 a9 ff ff       	call   80102b01 <kalloc>
8010817b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
8010817e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108182:	75 2c                	jne    801081b0 <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
80108184:	c7 04 24 96 90 10 80 	movl   $0x80109096,(%esp)
8010818b:	e8 10 82 ff ff       	call   801003a0 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108190:	8b 45 0c             	mov    0xc(%ebp),%eax
80108193:	89 44 24 08          	mov    %eax,0x8(%esp)
80108197:	8b 45 10             	mov    0x10(%ebp),%eax
8010819a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010819e:	8b 45 08             	mov    0x8(%ebp),%eax
801081a1:	89 04 24             	mov    %eax,(%esp)
801081a4:	e8 6b 00 00 00       	call   80108214 <deallocuvm>
      return 0;
801081a9:	b8 00 00 00 00       	mov    $0x0,%eax
801081ae:	eb 62                	jmp    80108212 <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
801081b0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801081b7:	00 
801081b8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801081bf:	00 
801081c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081c3:	89 04 24             	mov    %eax,(%esp)
801081c6:	e8 03 d0 ff ff       	call   801051ce <memset>

    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
801081cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081ce:	89 04 24             	mov    %eax,(%esp)
801081d1:	e8 9e f5 ff ff       	call   80107774 <v2p>
801081d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801081d9:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
801081e0:	00 
801081e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
801081e5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801081ec:	00 
801081ed:	89 54 24 04          	mov    %edx,0x4(%esp)
801081f1:	8b 45 08             	mov    0x8(%ebp),%eax
801081f4:	89 04 24             	mov    %eax,(%esp)
801081f7:	e8 be fa ff ff       	call   80107cba <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
801081fc:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108203:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108206:	3b 45 10             	cmp    0x10(%ebp),%eax
80108209:	0f 82 67 ff ff ff    	jb     80108176 <allocuvm+0x3c>
    memset(mem, 0, PGSIZE);

    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);

  }
  return newsz;
8010820f:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108212:	c9                   	leave  
80108213:	c3                   	ret    

80108214 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108214:	55                   	push   %ebp
80108215:	89 e5                	mov    %esp,%ebp
80108217:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
8010821a:	8b 45 10             	mov    0x10(%ebp),%eax
8010821d:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108220:	72 08                	jb     8010822a <deallocuvm+0x16>
    return oldsz;
80108222:	8b 45 0c             	mov    0xc(%ebp),%eax
80108225:	e9 ec 00 00 00       	jmp    80108316 <deallocuvm+0x102>

  a = PGROUNDUP(newsz);
8010822a:	8b 45 10             	mov    0x10(%ebp),%eax
8010822d:	05 ff 0f 00 00       	add    $0xfff,%eax
80108232:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108237:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
8010823a:	e9 c8 00 00 00       	jmp    80108307 <deallocuvm+0xf3>
	  pte = walkpgdir(pgdir, (char*)a, 0);
8010823f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108242:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108249:	00 
8010824a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010824e:	8b 45 08             	mov    0x8(%ebp),%eax
80108251:	89 04 24             	mov    %eax,(%esp)
80108254:	e8 bf f9 ff ff       	call   80107c18 <walkpgdir>
80108259:	89 45 f0             	mov    %eax,-0x10(%ebp)
	  if(!pte)
8010825c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108260:	75 0c                	jne    8010826e <deallocuvm+0x5a>
		  a += (NPTENTRIES - 1) * PGSIZE;
80108262:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80108269:	e9 92 00 00 00       	jmp    80108300 <deallocuvm+0xec>
	  else if((*pte & PTE_P) != 0) {
8010826e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108271:	8b 00                	mov    (%eax),%eax
80108273:	83 e0 01             	and    $0x1,%eax
80108276:	85 c0                	test   %eax,%eax
80108278:	0f 84 82 00 00 00    	je     80108300 <deallocuvm+0xec>
		  pa = PTE_ADDR(*pte);
8010827e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108281:	8b 00                	mov    (%eax),%eax
80108283:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108288:	89 45 ec             	mov    %eax,-0x14(%ebp)
		  if(pa == 0)
8010828b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010828f:	75 0c                	jne    8010829d <deallocuvm+0x89>
			  panic("kfree");
80108291:	c7 04 24 ae 90 10 80 	movl   $0x801090ae,(%esp)
80108298:	e8 9d 82 ff ff       	call   8010053a <panic>
		  acquire(&num_of_shareslock);
8010829d:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
801082a4:	e8 d1 cc ff ff       	call   80104f7a <acquire>
		  if (num_of_shares[pa/PGSIZE] == 0) {
801082a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082ac:	c1 e8 0c             	shr    $0xc,%eax
801082af:	0f b6 80 40 37 11 80 	movzbl -0x7feec8c0(%eax),%eax
801082b6:	84 c0                	test   %al,%al
801082b8:	75 1b                	jne    801082d5 <deallocuvm+0xc1>
			  char *v = p2v(pa);
801082ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082bd:	89 04 24             	mov    %eax,(%esp)
801082c0:	e8 bc f4 ff ff       	call   80107781 <p2v>
801082c5:	89 45 e8             	mov    %eax,-0x18(%ebp)
			  kfree(v);
801082c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801082cb:	89 04 24             	mov    %eax,(%esp)
801082ce:	e8 95 a7 ff ff       	call   80102a68 <kfree>
801082d3:	eb 16                	jmp    801082eb <deallocuvm+0xd7>
		  } else
			  num_of_shares[pa/PGSIZE]--;
801082d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082d8:	c1 e8 0c             	shr    $0xc,%eax
801082db:	0f b6 90 40 37 11 80 	movzbl -0x7feec8c0(%eax),%edx
801082e2:	83 ea 01             	sub    $0x1,%edx
801082e5:	88 90 40 37 11 80    	mov    %dl,-0x7feec8c0(%eax)

		  release(&num_of_shareslock);
801082eb:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
801082f2:	e8 e5 cc ff ff       	call   80104fdc <release>
		  *pte = 0;
801082f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082fa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108300:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108307:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010830a:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010830d:	0f 82 2c ff ff ff    	jb     8010823f <deallocuvm+0x2b>

		  release(&num_of_shareslock);
		  *pte = 0;
    }
  }
  return newsz;
80108313:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108316:	c9                   	leave  
80108317:	c3                   	ret    

80108318 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108318:	55                   	push   %ebp
80108319:	89 e5                	mov    %esp,%ebp
8010831b:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
8010831e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108322:	75 0c                	jne    80108330 <freevm+0x18>
    panic("freevm: no pgdir");
80108324:	c7 04 24 b4 90 10 80 	movl   $0x801090b4,(%esp)
8010832b:	e8 0a 82 ff ff       	call   8010053a <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108330:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108337:	00 
80108338:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
8010833f:	80 
80108340:	8b 45 08             	mov    0x8(%ebp),%eax
80108343:	89 04 24             	mov    %eax,(%esp)
80108346:	e8 c9 fe ff ff       	call   80108214 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
8010834b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108352:	eb 48                	jmp    8010839c <freevm+0x84>
    if(pgdir[i] & PTE_P){
80108354:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108357:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010835e:	8b 45 08             	mov    0x8(%ebp),%eax
80108361:	01 d0                	add    %edx,%eax
80108363:	8b 00                	mov    (%eax),%eax
80108365:	83 e0 01             	and    $0x1,%eax
80108368:	85 c0                	test   %eax,%eax
8010836a:	74 2c                	je     80108398 <freevm+0x80>
      char * v = p2v(PTE_ADDR(pgdir[i]));
8010836c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010836f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108376:	8b 45 08             	mov    0x8(%ebp),%eax
80108379:	01 d0                	add    %edx,%eax
8010837b:	8b 00                	mov    (%eax),%eax
8010837d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108382:	89 04 24             	mov    %eax,(%esp)
80108385:	e8 f7 f3 ff ff       	call   80107781 <p2v>
8010838a:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010838d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108390:	89 04 24             	mov    %eax,(%esp)
80108393:	e8 d0 a6 ff ff       	call   80102a68 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108398:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010839c:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801083a3:	76 af                	jbe    80108354 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801083a5:	8b 45 08             	mov    0x8(%ebp),%eax
801083a8:	89 04 24             	mov    %eax,(%esp)
801083ab:	e8 b8 a6 ff ff       	call   80102a68 <kfree>
}
801083b0:	c9                   	leave  
801083b1:	c3                   	ret    

801083b2 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801083b2:	55                   	push   %ebp
801083b3:	89 e5                	mov    %esp,%ebp
801083b5:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801083b8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801083bf:	00 
801083c0:	8b 45 0c             	mov    0xc(%ebp),%eax
801083c3:	89 44 24 04          	mov    %eax,0x4(%esp)
801083c7:	8b 45 08             	mov    0x8(%ebp),%eax
801083ca:	89 04 24             	mov    %eax,(%esp)
801083cd:	e8 46 f8 ff ff       	call   80107c18 <walkpgdir>
801083d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801083d5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801083d9:	75 0c                	jne    801083e7 <clearpteu+0x35>
    panic("clearpteu");
801083db:	c7 04 24 c5 90 10 80 	movl   $0x801090c5,(%esp)
801083e2:	e8 53 81 ff ff       	call   8010053a <panic>
  *pte &= ~PTE_U;
801083e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083ea:	8b 00                	mov    (%eax),%eax
801083ec:	83 e0 fb             	and    $0xfffffffb,%eax
801083ef:	89 c2                	mov    %eax,%edx
801083f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083f4:	89 10                	mov    %edx,(%eax)
}
801083f6:	c9                   	leave  
801083f7:	c3                   	ret    

801083f8 <copyuvm>:


// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz) {
801083f8:	55                   	push   %ebp
801083f9:	89 e5                	mov    %esp,%ebp
801083fb:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
801083fe:	e8 4f f9 ff ff       	call   80107d52 <setupkvm>
80108403:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108406:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010840a:	75 0a                	jne    80108416 <copyuvm+0x1e>
  return 0;
8010840c:	b8 00 00 00 00       	mov    $0x0,%eax
80108411:	e9 37 01 00 00       	jmp    8010854d <copyuvm+0x155>
  // TASK2 começamos a percorrer as paginações do processo pai a partir da segunda pagina, evitando acesso ao endereço 0
  for(i = PGSIZE; i < sz; i += PGSIZE){
80108416:	c7 45 f4 00 10 00 00 	movl   $0x1000,-0xc(%ebp)
8010841d:	e9 0a 01 00 00       	jmp    8010852c <copyuvm+0x134>
	  if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108422:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108425:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010842c:	00 
8010842d:	89 44 24 04          	mov    %eax,0x4(%esp)
80108431:	8b 45 08             	mov    0x8(%ebp),%eax
80108434:	89 04 24             	mov    %eax,(%esp)
80108437:	e8 dc f7 ff ff       	call   80107c18 <walkpgdir>
8010843c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010843f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108443:	75 0c                	jne    80108451 <copyuvm+0x59>
		  panic("copyuvm: pte should exist");
80108445:	c7 04 24 cf 90 10 80 	movl   $0x801090cf,(%esp)
8010844c:	e8 e9 80 ff ff       	call   8010053a <panic>
	  if(!(*pte & PTE_P))
80108451:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108454:	8b 00                	mov    (%eax),%eax
80108456:	83 e0 01             	and    $0x1,%eax
80108459:	85 c0                	test   %eax,%eax
8010845b:	75 0c                	jne    80108469 <copyuvm+0x71>
		  panic("copyuvm: page not present");
8010845d:	c7 04 24 e9 90 10 80 	movl   $0x801090e9,(%esp)
80108464:	e8 d1 80 ff ff       	call   8010053a <panic>
	  pa = PTE_ADDR(*pte);
80108469:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010846c:	8b 00                	mov    (%eax),%eax
8010846e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108473:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  if((mem = kalloc()) == 0)
80108476:	e8 86 a6 ff ff       	call   80102b01 <kalloc>
8010847b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010847e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108482:	75 05                	jne    80108489 <copyuvm+0x91>
		  goto bad;
80108484:	e9 b4 00 00 00       	jmp    8010853d <copyuvm+0x145>

	  // copy data
	  memmove(mem, (char*)p2v(pa), PGSIZE); 
80108489:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010848c:	89 04 24             	mov    %eax,(%esp)
8010848f:	e8 ed f2 ff ff       	call   80107781 <p2v>
80108494:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010849b:	00 
8010849c:	89 44 24 04          	mov    %eax,0x4(%esp)
801084a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801084a3:	89 04 24             	mov    %eax,(%esp)
801084a6:	e8 f2 cd ff ff       	call   8010529d <memmove>

	  // TASK3 copiamos para o filho as mesmas flags do processo pai
	  if (*pte & PTE_W) {
801084ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084ae:	8b 00                	mov    (%eax),%eax
801084b0:	83 e0 02             	and    $0x2,%eax
801084b3:	85 c0                	test   %eax,%eax
801084b5:	74 37                	je     801084ee <copyuvm+0xf6>
		  if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
801084b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801084ba:	89 04 24             	mov    %eax,(%esp)
801084bd:	e8 b2 f2 ff ff       	call   80107774 <v2p>
801084c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801084c5:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
801084cc:	00 
801084cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
801084d1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801084d8:	00 
801084d9:	89 54 24 04          	mov    %edx,0x4(%esp)
801084dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084e0:	89 04 24             	mov    %eax,(%esp)
801084e3:	e8 d2 f7 ff ff       	call   80107cba <mappages>
801084e8:	85 c0                	test   %eax,%eax
801084ea:	79 39                	jns    80108525 <copyuvm+0x12d>
			  goto bad;
801084ec:	eb 4f                	jmp    8010853d <copyuvm+0x145>
	  } else {
		  if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_U) < 0)
801084ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801084f1:	89 04 24             	mov    %eax,(%esp)
801084f4:	e8 7b f2 ff ff       	call   80107774 <v2p>
801084f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801084fc:	c7 44 24 10 04 00 00 	movl   $0x4,0x10(%esp)
80108503:	00 
80108504:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108508:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010850f:	00 
80108510:	89 54 24 04          	mov    %edx,0x4(%esp)
80108514:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108517:	89 04 24             	mov    %eax,(%esp)
8010851a:	e8 9b f7 ff ff       	call   80107cba <mappages>
8010851f:	85 c0                	test   %eax,%eax
80108521:	79 02                	jns    80108525 <copyuvm+0x12d>
			  goto bad;
80108523:	eb 18                	jmp    8010853d <copyuvm+0x145>
  char *mem;

  if((d = setupkvm()) == 0)
  return 0;
  // TASK2 começamos a percorrer as paginações do processo pai a partir da segunda pagina, evitando acesso ao endereço 0
  for(i = PGSIZE; i < sz; i += PGSIZE){
80108525:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010852c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010852f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108532:	0f 82 ea fe ff ff    	jb     80108422 <copyuvm+0x2a>
	  } else {
		  if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_U) < 0)
			  goto bad;
	  }
  }
  return d;
80108538:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010853b:	eb 10                	jmp    8010854d <copyuvm+0x155>
  
bad:
  freevm(d);
8010853d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108540:	89 04 24             	mov    %eax,(%esp)
80108543:	e8 d0 fd ff ff       	call   80108318 <freevm>
  return 0;
80108548:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010854d:	c9                   	leave  
8010854e:	c3                   	ret    

8010854f <handle_pgflt>:
void

// TASK2, TASK4
// Tratamento de exceção, para erros em paginação/memoria !!
handle_pgflt(void)
{
8010854f:	55                   	push   %ebp
80108550:	89 e5                	mov    %esp,%ebp
80108552:	53                   	push   %ebx
80108553:	83 ec 24             	sub    $0x24,%esp
  char *mem;
  pte_t *pte;
  uint pa;
  
  uint faultingAddress = read_cr2();
80108556:	e8 ce e0 ff ff       	call   80106629 <read_cr2>
8010855b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  // Tratamento de exceção para NULL pointer
  if (faultingAddress==0) {
8010855e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108562:	75 1e                	jne    80108582 <handle_pgflt+0x33>
    cprintf("NULL POINTER EXCEPTION! kill&exit\n");
80108564:	c7 04 24 04 91 10 80 	movl   $0x80109104,(%esp)
8010856b:	e8 30 7e ff ff       	call   801003a0 <cprintf>
    proc->killed = 1;
80108570:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108576:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
    exit();
8010857d:	e8 f4 bf ff ff       	call   80104576 <exit>
  }
  
  if ((pte = walkpgdir(proc->pgdir, (void*)faultingAddress , 0)) == 0)
80108582:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108585:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010858b:	8b 40 04             	mov    0x4(%eax),%eax
8010858e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108595:	00 
80108596:	89 54 24 04          	mov    %edx,0x4(%esp)
8010859a:	89 04 24             	mov    %eax,(%esp)
8010859d:	e8 76 f6 ff ff       	call   80107c18 <walkpgdir>
801085a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801085a5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801085a9:	75 0c                	jne    801085b7 <handle_pgflt+0x68>
    panic("handle_pgflt: pte should exist");
801085ab:	c7 04 24 28 91 10 80 	movl   $0x80109128,(%esp)
801085b2:	e8 83 7f ff ff       	call   8010053a <panic>
  if(!(*pte & PTE_P))
801085b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085ba:	8b 00                	mov    (%eax),%eax
801085bc:	83 e0 01             	and    $0x1,%eax
801085bf:	85 c0                	test   %eax,%eax
801085c1:	75 0c                	jne    801085cf <handle_pgflt+0x80>
      panic("handle_pgflt: page not present");
801085c3:	c7 04 24 48 91 10 80 	movl   $0x80109148,(%esp)
801085ca:	e8 6b 7f ff ff       	call   8010053a <panic>
  
  pa = PTE_ADDR(*pte);
801085cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085d2:	8b 00                	mov    (%eax),%eax
801085d4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085d9:	89 45 ec             	mov    %eax,-0x14(%ebp)

  acquire(&num_of_shareslock);
801085dc:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
801085e3:	e8 92 c9 ff ff       	call   80104f7a <acquire>
  
  // Primeiro caso, um processo que entra e é o ultimo processo que compartilha essa pagina
  if ((num_of_shares[pa/PGSIZE] == 0) && ((*pte)& PTE_WAS_WRITABLE)) {
801085e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085eb:	c1 e8 0c             	shr    $0xc,%eax
801085ee:	0f b6 80 40 37 11 80 	movzbl -0x7feec8c0(%eax),%eax
801085f5:	84 c0                	test   %al,%al
801085f7:	75 40                	jne    80108639 <handle_pgflt+0xea>
801085f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085fc:	8b 00                	mov    (%eax),%eax
801085fe:	25 00 01 00 00       	and    $0x100,%eax
80108603:	85 c0                	test   %eax,%eax
80108605:	74 32                	je     80108639 <handle_pgflt+0xea>
    *pte &= ~PTE_SH;  // Processo deixou de ser compartilhado
80108607:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010860a:	8b 00                	mov    (%eax),%eax
8010860c:	80 e4 fd             	and    $0xfd,%ah
8010860f:	89 c2                	mov    %eax,%edx
80108611:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108614:	89 10                	mov    %edx,(%eax)
    *pte &= ~PTE_WAS_WRITABLE;  // não precisamos dessa flag auxiliar podemos usar a flag PTE_W
80108616:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108619:	8b 00                	mov    (%eax),%eax
8010861b:	80 e4 fe             	and    $0xfe,%ah
8010861e:	89 c2                	mov    %eax,%edx
80108620:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108623:	89 10                	mov    %edx,(%eax)
    *pte |= PTE_W;	// Atualiza o processo para poder ser escrito 
80108625:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108628:	8b 00                	mov    (%eax),%eax
8010862a:	83 c8 02             	or     $0x2,%eax
8010862d:	89 c2                	mov    %eax,%edx
8010862f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108632:	89 10                	mov    %edx,(%eax)
    goto finish_hadle_pgflt;
80108634:	e9 06 01 00 00       	jmp    8010873f <handle_pgflt+0x1f0>
  }
  
  // Segundo caso, algum processo não compartilha mais a paginação
  if ((num_of_shares[pa/PGSIZE] > 0) && ((*pte)&PTE_WAS_WRITABLE) && ((*pte)&PTE_SH)) {
80108639:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010863c:	c1 e8 0c             	shr    $0xc,%eax
8010863f:	0f b6 80 40 37 11 80 	movzbl -0x7feec8c0(%eax),%eax
80108646:	84 c0                	test   %al,%al
80108648:	0f 84 b9 00 00 00    	je     80108707 <handle_pgflt+0x1b8>
8010864e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108651:	8b 00                	mov    (%eax),%eax
80108653:	25 00 01 00 00       	and    $0x100,%eax
80108658:	85 c0                	test   %eax,%eax
8010865a:	0f 84 a7 00 00 00    	je     80108707 <handle_pgflt+0x1b8>
80108660:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108663:	8b 00                	mov    (%eax),%eax
80108665:	25 00 02 00 00       	and    $0x200,%eax
8010866a:	85 c0                	test   %eax,%eax
8010866c:	0f 84 95 00 00 00    	je     80108707 <handle_pgflt+0x1b8>
    num_of_shares[pa >> PGSHIFT]--;  // Atualização do contador
80108672:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108675:	c1 e8 0c             	shr    $0xc,%eax
80108678:	0f b6 90 40 37 11 80 	movzbl -0x7feec8c0(%eax),%edx
8010867f:	83 ea 01             	sub    $0x1,%edx
80108682:	88 90 40 37 11 80    	mov    %dl,-0x7feec8c0(%eax)
    if((mem = kalloc()) == 0)		// Alocamos memória
80108688:	e8 74 a4 ff ff       	call   80102b01 <kalloc>
8010868d:	89 45 e8             	mov    %eax,-0x18(%ebp)
80108690:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108694:	75 0c                	jne    801086a2 <handle_pgflt+0x153>
    	panic("handle_pgflt: failed to kalloc");
80108696:	c7 04 24 68 91 10 80 	movl   $0x80109168,(%esp)
8010869d:	e8 98 7e ff ff       	call   8010053a <panic>
    memmove(mem, (char*)p2v(pa), PGSIZE);  // movemos o processo para area alocada
801086a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086a5:	89 04 24             	mov    %eax,(%esp)
801086a8:	e8 d4 f0 ff ff       	call   80107781 <p2v>
801086ad:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801086b4:	00 
801086b5:	89 44 24 04          	mov    %eax,0x4(%esp)
801086b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801086bc:	89 04 24             	mov    %eax,(%esp)
801086bf:	e8 d9 cb ff ff       	call   8010529d <memmove>
    *pte &= ~PTE_SH;	// Remove a FLAG de paginação comapritlhada
801086c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086c7:	8b 00                	mov    (%eax),%eax
801086c9:	80 e4 fd             	and    $0xfd,%ah
801086cc:	89 c2                	mov    %eax,%edx
801086ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086d1:	89 10                	mov    %edx,(%eax)
    *pte &= ~PTE_WAS_WRITABLE;	// FLAG auxiliar não é mais necessária podemos remover
801086d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086d6:	8b 00                	mov    (%eax),%eax
801086d8:	80 e4 fe             	and    $0xfe,%ah
801086db:	89 c2                	mov    %eax,%edx
801086dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086e0:	89 10                	mov    %edx,(%eax)
    *pte = (*pte & 0XFFF) | v2p(mem) | PTE_W;	// Atualizamos a entry e a FLAG de escrita do processo
801086e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086e5:	8b 00                	mov    (%eax),%eax
801086e7:	25 ff 0f 00 00       	and    $0xfff,%eax
801086ec:	89 c3                	mov    %eax,%ebx
801086ee:	8b 45 e8             	mov    -0x18(%ebp),%eax
801086f1:	89 04 24             	mov    %eax,(%esp)
801086f4:	e8 7b f0 ff ff       	call   80107774 <v2p>
801086f9:	09 d8                	or     %ebx,%eax
801086fb:	83 c8 02             	or     $0x2,%eax
801086fe:	89 c2                	mov    %eax,%edx
80108700:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108703:	89 10                	mov    %edx,(%eax)
    goto finish_hadle_pgflt;
80108705:	eb 38                	jmp    8010873f <handle_pgflt+0x1f0>
  }
  
  // Terceiro caso um processo tenta escrever em uma are originalmente somente leitura (read-only)
  if (!((*pte)&PTE_WAS_WRITABLE)) {
80108707:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010870a:	8b 00                	mov    (%eax),%eax
8010870c:	25 00 01 00 00       	and    $0x100,%eax
80108711:	85 c0                	test   %eax,%eax
80108713:	75 2a                	jne    8010873f <handle_pgflt+0x1f0>
      cprintf("ACCESS VIOLATION! tried to write to read-only page. kill&exit\n");
80108715:	c7 04 24 88 91 10 80 	movl   $0x80109188,(%esp)
8010871c:	e8 7f 7c ff ff       	call   801003a0 <cprintf>
      release(&num_of_shareslock);
80108721:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
80108728:	e8 af c8 ff ff       	call   80104fdc <release>
      proc->killed = 1;
8010872d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108733:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      exit(); 
8010873a:	e8 37 be ff ff       	call   80104576 <exit>
  }

  
finish_hadle_pgflt:
  release(&num_of_shareslock);
8010873f:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
80108746:	e8 91 c8 ff ff       	call   80104fdc <release>
  flush_tlb_all();
8010874b:	e8 dd de ff ff       	call   8010662d <flush_tlb_all>
}
80108750:	83 c4 24             	add    $0x24,%esp
80108753:	5b                   	pop    %ebx
80108754:	5d                   	pop    %ebp
80108755:	c3                   	ret    

80108756 <copyuvm_cow>:

// TASK 4
// Dado um processo pai, compartilha a area de memória com o filho
// Bem parecido com o copyuvm_cow
pde_t*
copyuvm_cow(pde_t *pgdir, uint sz) {
80108756:	55                   	push   %ebp
80108757:	89 e5                	mov    %esp,%ebp
80108759:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint i, pa, flags;
  
  if((d = setupkvm()) == 0)
8010875c:	e8 f1 f5 ff ff       	call   80107d52 <setupkvm>
80108761:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108764:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108768:	75 0a                	jne    80108774 <copyuvm_cow+0x1e>
    return 0;
8010876a:	b8 00 00 00 00       	mov    $0x0,%eax
8010876f:	e9 5d 01 00 00       	jmp    801088d1 <copyuvm_cow+0x17b>

  for(i = PGSIZE; i < sz; i += PGSIZE) {
80108774:	c7 45 f4 00 10 00 00 	movl   $0x1000,-0xc(%ebp)
8010877b:	e9 2b 01 00 00       	jmp    801088ab <copyuvm_cow+0x155>
	  if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108780:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108783:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010878a:	00 
8010878b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010878f:	8b 45 08             	mov    0x8(%ebp),%eax
80108792:	89 04 24             	mov    %eax,(%esp)
80108795:	e8 7e f4 ff ff       	call   80107c18 <walkpgdir>
8010879a:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010879d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801087a1:	75 0c                	jne    801087af <copyuvm_cow+0x59>
		  panic("copyuvm_cow: pte should exist");
801087a3:	c7 04 24 c7 91 10 80 	movl   $0x801091c7,(%esp)
801087aa:	e8 8b 7d ff ff       	call   8010053a <panic>
	  if(!(*pte & PTE_P))
801087af:	8b 45 e8             	mov    -0x18(%ebp),%eax
801087b2:	8b 00                	mov    (%eax),%eax
801087b4:	83 e0 01             	and    $0x1,%eax
801087b7:	85 c0                	test   %eax,%eax
801087b9:	75 0c                	jne    801087c7 <copyuvm_cow+0x71>
		  panic("copyuvm_cow: page not present");
801087bb:	c7 04 24 e5 91 10 80 	movl   $0x801091e5,(%esp)
801087c2:	e8 73 7d ff ff       	call   8010053a <panic>
   
	  pa = PTE_ADDR(*pte);
801087c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801087ca:	8b 00                	mov    (%eax),%eax
801087cc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    
	  // Aumentamos o contador de compartilhamento, utilizamos semaforo pois outros processos podem estar
	  // tentando fazer um compartilhameto da paginação
	  acquire(&num_of_shareslock);
801087d4:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
801087db:	e8 9a c7 ff ff       	call   80104f7a <acquire>
	  num_of_shares[pa/PGSIZE]++;
801087e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801087e3:	c1 e8 0c             	shr    $0xc,%eax
801087e6:	0f b6 90 40 37 11 80 	movzbl -0x7feec8c0(%eax),%edx
801087ed:	83 c2 01             	add    $0x1,%edx
801087f0:	88 90 40 37 11 80    	mov    %dl,-0x7feec8c0(%eax)
	  release(&num_of_shareslock);
801087f6:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
801087fd:	e8 da c7 ff ff       	call   80104fdc <release>
    

	  flags =  *pte & 0xfff;
80108802:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108805:	8b 00                	mov    (%eax),%eax
80108807:	25 ff 0f 00 00       	and    $0xfff,%eax
8010880c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	  if ((flags & PTE_W ) | (flags & PTE_WAS_WRITABLE)) {
8010880f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108812:	25 02 01 00 00       	and    $0x102,%eax
80108817:	85 c0                	test   %eax,%eax
80108819:	74 40                	je     8010885b <copyuvm_cow+0x105>
		  flags &= ~PTE_W;	      // Removemos a flag de escrita
8010881b:	83 65 f0 fd          	andl   $0xfffffffd,-0x10(%ebp)
		  flags |= PTE_SH ;		  // Adicionamos as flags e compartilhamento
8010881f:	81 4d f0 00 02 00 00 	orl    $0x200,-0x10(%ebp)
		  flags |= PTE_WAS_WRITABLE;	  // Adicionamos a flag auxilar para identificar se o processo podia ser escrito
80108826:	81 4d f0 00 01 00 00 	orl    $0x100,-0x10(%ebp)
		  if (mappages(d, (void*)i, PGSIZE, pa, flags) < 0)
8010882d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108830:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108833:	89 54 24 10          	mov    %edx,0x10(%esp)
80108837:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010883a:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010883e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108845:	00 
80108846:	89 44 24 04          	mov    %eax,0x4(%esp)
8010884a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010884d:	89 04 24             	mov    %eax,(%esp)
80108850:	e8 65 f4 ff ff       	call   80107cba <mappages>
80108855:	85 c0                	test   %eax,%eax
80108857:	79 37                	jns    80108890 <copyuvm_cow+0x13a>
			  goto bad;
80108859:	eb 66                	jmp    801088c1 <copyuvm_cow+0x16b>
	  } else {
		  flags |= PTE_SH;		  // Adicionamos as flags e compartilhamento 
8010885b:	81 4d f0 00 02 00 00 	orl    $0x200,-0x10(%ebp)
		  if (mappages(d, (void*)i, PGSIZE, pa, flags) < 0)
80108862:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108865:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108868:	89 54 24 10          	mov    %edx,0x10(%esp)
8010886c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010886f:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108873:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010887a:	00 
8010887b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010887f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108882:	89 04 24             	mov    %eax,(%esp)
80108885:	e8 30 f4 ff ff       	call   80107cba <mappages>
8010888a:	85 c0                	test   %eax,%eax
8010888c:	79 02                	jns    80108890 <copyuvm_cow+0x13a>
			  goto bad;
8010888e:	eb 31                	jmp    801088c1 <copyuvm_cow+0x16b>
	  }
    
	  // update flags
	  *pte = (*pte & ~0xfff) | flags; 
80108890:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108893:	8b 00                	mov    (%eax),%eax
80108895:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010889a:	0b 45 f0             	or     -0x10(%ebp),%eax
8010889d:	89 c2                	mov    %eax,%edx
8010889f:	8b 45 e8             	mov    -0x18(%ebp),%eax
801088a2:	89 10                	mov    %edx,(%eax)
  uint i, pa, flags;
  
  if((d = setupkvm()) == 0)
    return 0;

  for(i = PGSIZE; i < sz; i += PGSIZE) {
801088a4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801088ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ae:	3b 45 0c             	cmp    0xc(%ebp),%eax
801088b1:	0f 82 c9 fe ff ff    	jb     80108780 <copyuvm_cow+0x2a>
	  // update flags
	  *pte = (*pte & ~0xfff) | flags; 
     
  }
  
  flush_tlb_all();
801088b7:	e8 71 dd ff ff       	call   8010662d <flush_tlb_all>
  return d;
801088bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088bf:	eb 10                	jmp    801088d1 <copyuvm_cow+0x17b>

bad:
  freevm(d);
801088c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088c4:	89 04 24             	mov    %eax,(%esp)
801088c7:	e8 4c fa ff ff       	call   80108318 <freevm>
  return 0;
801088cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801088d1:	c9                   	leave  
801088d2:	c3                   	ret    

801088d3 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801088d3:	55                   	push   %ebp
801088d4:	89 e5                	mov    %esp,%ebp
801088d6:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801088d9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801088e0:	00 
801088e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801088e4:	89 44 24 04          	mov    %eax,0x4(%esp)
801088e8:	8b 45 08             	mov    0x8(%ebp),%eax
801088eb:	89 04 24             	mov    %eax,(%esp)
801088ee:	e8 25 f3 ff ff       	call   80107c18 <walkpgdir>
801088f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801088f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088f9:	8b 00                	mov    (%eax),%eax
801088fb:	83 e0 01             	and    $0x1,%eax
801088fe:	85 c0                	test   %eax,%eax
80108900:	75 07                	jne    80108909 <uva2ka+0x36>
    return 0;
80108902:	b8 00 00 00 00       	mov    $0x0,%eax
80108907:	eb 25                	jmp    8010892e <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
80108909:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010890c:	8b 00                	mov    (%eax),%eax
8010890e:	83 e0 04             	and    $0x4,%eax
80108911:	85 c0                	test   %eax,%eax
80108913:	75 07                	jne    8010891c <uva2ka+0x49>
    return 0;
80108915:	b8 00 00 00 00       	mov    $0x0,%eax
8010891a:	eb 12                	jmp    8010892e <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
8010891c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010891f:	8b 00                	mov    (%eax),%eax
80108921:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108926:	89 04 24             	mov    %eax,(%esp)
80108929:	e8 53 ee ff ff       	call   80107781 <p2v>
}
8010892e:	c9                   	leave  
8010892f:	c3                   	ret    

80108930 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108930:	55                   	push   %ebp
80108931:	89 e5                	mov    %esp,%ebp
80108933:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108936:	8b 45 10             	mov    0x10(%ebp),%eax
80108939:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010893c:	e9 87 00 00 00       	jmp    801089c8 <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
80108941:	8b 45 0c             	mov    0xc(%ebp),%eax
80108944:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108949:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010894c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010894f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108953:	8b 45 08             	mov    0x8(%ebp),%eax
80108956:	89 04 24             	mov    %eax,(%esp)
80108959:	e8 75 ff ff ff       	call   801088d3 <uva2ka>
8010895e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108961:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108965:	75 07                	jne    8010896e <copyout+0x3e>
      return -1;
80108967:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010896c:	eb 69                	jmp    801089d7 <copyout+0xa7>
    n = PGSIZE - (va - va0);
8010896e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108971:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108974:	29 c2                	sub    %eax,%edx
80108976:	89 d0                	mov    %edx,%eax
80108978:	05 00 10 00 00       	add    $0x1000,%eax
8010897d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108980:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108983:	3b 45 14             	cmp    0x14(%ebp),%eax
80108986:	76 06                	jbe    8010898e <copyout+0x5e>
      n = len;
80108988:	8b 45 14             	mov    0x14(%ebp),%eax
8010898b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010898e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108991:	8b 55 0c             	mov    0xc(%ebp),%edx
80108994:	29 c2                	sub    %eax,%edx
80108996:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108999:	01 c2                	add    %eax,%edx
8010899b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010899e:	89 44 24 08          	mov    %eax,0x8(%esp)
801089a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089a5:	89 44 24 04          	mov    %eax,0x4(%esp)
801089a9:	89 14 24             	mov    %edx,(%esp)
801089ac:	e8 ec c8 ff ff       	call   8010529d <memmove>
    len -= n;
801089b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089b4:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801089b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089ba:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801089bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089c0:	05 00 10 00 00       	add    $0x1000,%eax
801089c5:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801089c8:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801089cc:	0f 85 6f ff ff ff    	jne    80108941 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801089d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801089d7:	c9                   	leave  
801089d8:	c3                   	ret    
