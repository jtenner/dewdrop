
.tmp/wago-next-gc-perf/post-read-regions-profile/profile/native-code.bin:     file format binary


Disassembly of section .data:

00000000006292f0 <.data+0x6292f0>:
  6292f0:	48 81 ec b8 03 00 00 	sub    rsp,0x3b8
  6292f7:	48 8b 73 b8          	mov    rsi,QWORD PTR [rbx-0x48]
  6292fb:	48 39 f4             	cmp    rsp,rsi
  6292fe:	0f 82 10 45 00 00    	jb     0x62d814
  629304:	48 89 04 24          	mov    QWORD PTR [rsp],rax
  629308:	48 89 4c 24 08       	mov    QWORD PTR [rsp+0x8],rcx
  62930d:	31 c0                	xor    eax,eax
  62930f:	48 89 44 24 10       	mov    QWORD PTR [rsp+0x10],rax
  629314:	89 44 24 18          	mov    DWORD PTR [rsp+0x18],eax
  629318:	89 44 24 20          	mov    DWORD PTR [rsp+0x20],eax
  62931c:	89 44 24 28          	mov    DWORD PTR [rsp+0x28],eax
  629320:	48 89 44 24 30       	mov    QWORD PTR [rsp+0x30],rax
  629325:	48 89 44 24 38       	mov    QWORD PTR [rsp+0x38],rax
  62932a:	89 44 24 40          	mov    DWORD PTR [rsp+0x40],eax
  62932e:	48 89 44 24 48       	mov    QWORD PTR [rsp+0x48],rax
  629333:	48 89 44 24 50       	mov    QWORD PTR [rsp+0x50],rax
  629338:	89 44 24 58          	mov    DWORD PTR [rsp+0x58],eax
  62933c:	89 44 24 60          	mov    DWORD PTR [rsp+0x60],eax
  629340:	89 44 24 68          	mov    DWORD PTR [rsp+0x68],eax
  629344:	89 44 24 70          	mov    DWORD PTR [rsp+0x70],eax
  629348:	48 89 44 24 78       	mov    QWORD PTR [rsp+0x78],rax
  62934d:	48 89 84 24 80 00 00 	mov    QWORD PTR [rsp+0x80],rax
  629354:	00 
  629355:	48 89 84 24 88 00 00 	mov    QWORD PTR [rsp+0x88],rax
  62935c:	00 
  62935d:	48 89 84 24 90 00 00 	mov    QWORD PTR [rsp+0x90],rax
  629364:	00 
  629365:	89 84 24 98 00 00 00 	mov    DWORD PTR [rsp+0x98],eax
  62936c:	89 84 24 a0 00 00 00 	mov    DWORD PTR [rsp+0xa0],eax
  629373:	48 89 84 24 a8 00 00 	mov    QWORD PTR [rsp+0xa8],rax
  62937a:	00 
  62937b:	89 84 24 b0 00 00 00 	mov    DWORD PTR [rsp+0xb0],eax
  629382:	89 84 24 b8 00 00 00 	mov    DWORD PTR [rsp+0xb8],eax
  629389:	48 89 84 24 c0 00 00 	mov    QWORD PTR [rsp+0xc0],rax
  629390:	00 
  629391:	89 84 24 c8 00 00 00 	mov    DWORD PTR [rsp+0xc8],eax
  629398:	89 84 24 d0 00 00 00 	mov    DWORD PTR [rsp+0xd0],eax
  62939f:	48 89 84 24 d8 00 00 	mov    QWORD PTR [rsp+0xd8],rax
  6293a6:	00 
  6293a7:	89 84 24 e0 00 00 00 	mov    DWORD PTR [rsp+0xe0],eax
  6293ae:	89 84 24 e8 00 00 00 	mov    DWORD PTR [rsp+0xe8],eax
  6293b5:	48 89 84 24 f0 00 00 	mov    QWORD PTR [rsp+0xf0],rax
  6293bc:	00 
  6293bd:	48 89 84 24 f8 00 00 	mov    QWORD PTR [rsp+0xf8],rax
  6293c4:	00 
  6293c5:	48 89 84 24 00 01 00 	mov    QWORD PTR [rsp+0x100],rax
  6293cc:	00 
  6293cd:	89 84 24 08 01 00 00 	mov    DWORD PTR [rsp+0x108],eax
  6293d4:	89 84 24 10 01 00 00 	mov    DWORD PTR [rsp+0x110],eax
  6293db:	89 84 24 18 01 00 00 	mov    DWORD PTR [rsp+0x118],eax
  6293e2:	48 89 84 24 20 01 00 	mov    QWORD PTR [rsp+0x120],rax
  6293e9:	00 
  6293ea:	48 89 84 24 28 01 00 	mov    QWORD PTR [rsp+0x128],rax
  6293f1:	00 
  6293f2:	48 89 84 24 30 01 00 	mov    QWORD PTR [rsp+0x130],rax
  6293f9:	00 
  6293fa:	48 89 84 24 38 01 00 	mov    QWORD PTR [rsp+0x138],rax
  629401:	00 
  629402:	89 84 24 40 01 00 00 	mov    DWORD PTR [rsp+0x140],eax
  629409:	89 84 24 48 01 00 00 	mov    DWORD PTR [rsp+0x148],eax
  629410:	48 89 84 24 50 01 00 	mov    QWORD PTR [rsp+0x150],rax
  629417:	00 
  629418:	89 84 24 58 01 00 00 	mov    DWORD PTR [rsp+0x158],eax
  62941f:	48 89 84 24 60 01 00 	mov    QWORD PTR [rsp+0x160],rax
  629426:	00 
  629427:	48 89 84 24 68 01 00 	mov    QWORD PTR [rsp+0x168],rax
  62942e:	00 
  62942f:	89 84 24 70 01 00 00 	mov    DWORD PTR [rsp+0x170],eax
  629436:	89 84 24 78 01 00 00 	mov    DWORD PTR [rsp+0x178],eax
  62943d:	48 89 84 24 80 01 00 	mov    QWORD PTR [rsp+0x180],rax
  629444:	00 
  629445:	89 84 24 88 01 00 00 	mov    DWORD PTR [rsp+0x188],eax
  62944c:	48 89 84 24 90 01 00 	mov    QWORD PTR [rsp+0x190],rax
  629453:	00 
  629454:	48 89 84 24 98 01 00 	mov    QWORD PTR [rsp+0x198],rax
  62945b:	00 
  62945c:	48 89 84 24 a0 01 00 	mov    QWORD PTR [rsp+0x1a0],rax
  629463:	00 
  629464:	48 89 84 24 a8 01 00 	mov    QWORD PTR [rsp+0x1a8],rax
  62946b:	00 
  62946c:	48 89 84 24 b0 01 00 	mov    QWORD PTR [rsp+0x1b0],rax
  629473:	00 
  629474:	48 89 84 24 b8 01 00 	mov    QWORD PTR [rsp+0x1b8],rax
  62947b:	00 
  62947c:	48 89 84 24 c0 01 00 	mov    QWORD PTR [rsp+0x1c0],rax
  629483:	00 
  629484:	89 84 24 c8 01 00 00 	mov    DWORD PTR [rsp+0x1c8],eax
  62948b:	48 89 84 24 d0 01 00 	mov    QWORD PTR [rsp+0x1d0],rax
  629492:	00 
  629493:	48 89 84 24 d8 01 00 	mov    QWORD PTR [rsp+0x1d8],rax
  62949a:	00 
  62949b:	89 84 24 e0 01 00 00 	mov    DWORD PTR [rsp+0x1e0],eax
  6294a2:	89 84 24 e8 01 00 00 	mov    DWORD PTR [rsp+0x1e8],eax
  6294a9:	89 84 24 f0 01 00 00 	mov    DWORD PTR [rsp+0x1f0],eax
  6294b0:	89 84 24 f8 01 00 00 	mov    DWORD PTR [rsp+0x1f8],eax
  6294b7:	89 84 24 00 02 00 00 	mov    DWORD PTR [rsp+0x200],eax
  6294be:	48 89 84 24 08 02 00 	mov    QWORD PTR [rsp+0x208],rax
  6294c5:	00 
  6294c6:	89 84 24 10 02 00 00 	mov    DWORD PTR [rsp+0x210],eax
  6294cd:	89 84 24 18 02 00 00 	mov    DWORD PTR [rsp+0x218],eax
  6294d4:	89 84 24 20 02 00 00 	mov    DWORD PTR [rsp+0x220],eax
  6294db:	89 84 24 28 02 00 00 	mov    DWORD PTR [rsp+0x228],eax
  6294e2:	48 89 84 24 30 02 00 	mov    QWORD PTR [rsp+0x230],rax
  6294e9:	00 
  6294ea:	48 89 84 24 38 02 00 	mov    QWORD PTR [rsp+0x238],rax
  6294f1:	00 
  6294f2:	89 84 24 40 02 00 00 	mov    DWORD PTR [rsp+0x240],eax
  6294f9:	89 84 24 48 02 00 00 	mov    DWORD PTR [rsp+0x248],eax
  629500:	89 84 24 50 02 00 00 	mov    DWORD PTR [rsp+0x250],eax
  629507:	48 89 84 24 58 02 00 	mov    QWORD PTR [rsp+0x258],rax
  62950e:	00 
  62950f:	48 89 84 24 60 02 00 	mov    QWORD PTR [rsp+0x260],rax
  629516:	00 
  629517:	48 89 84 24 68 02 00 	mov    QWORD PTR [rsp+0x268],rax
  62951e:	00 
  62951f:	48 89 84 24 70 02 00 	mov    QWORD PTR [rsp+0x270],rax
  629526:	00 
  629527:	89 84 24 78 02 00 00 	mov    DWORD PTR [rsp+0x278],eax
  62952e:	48 89 84 24 80 02 00 	mov    QWORD PTR [rsp+0x280],rax
  629535:	00 
  629536:	89 84 24 88 02 00 00 	mov    DWORD PTR [rsp+0x288],eax
  62953d:	89 84 24 90 02 00 00 	mov    DWORD PTR [rsp+0x290],eax
  629544:	89 84 24 98 02 00 00 	mov    DWORD PTR [rsp+0x298],eax
  62954b:	89 84 24 a0 02 00 00 	mov    DWORD PTR [rsp+0x2a0],eax
  629552:	48 89 84 24 a8 02 00 	mov    QWORD PTR [rsp+0x2a8],rax
  629559:	00 
  62955a:	48 89 84 24 b0 02 00 	mov    QWORD PTR [rsp+0x2b0],rax
  629561:	00 
  629562:	48 89 84 24 b8 02 00 	mov    QWORD PTR [rsp+0x2b8],rax
  629569:	00 
  62956a:	89 84 24 c0 02 00 00 	mov    DWORD PTR [rsp+0x2c0],eax
  629571:	89 84 24 c8 02 00 00 	mov    DWORD PTR [rsp+0x2c8],eax
  629578:	89 84 24 d0 02 00 00 	mov    DWORD PTR [rsp+0x2d0],eax
  62957f:	89 84 24 d8 02 00 00 	mov    DWORD PTR [rsp+0x2d8],eax
  629586:	89 84 24 e0 02 00 00 	mov    DWORD PTR [rsp+0x2e0],eax
  62958d:	89 84 24 e8 02 00 00 	mov    DWORD PTR [rsp+0x2e8],eax
  629594:	48 8b 3c 24          	mov    rdi,QWORD PTR [rsp]
  629598:	48 89 bc 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rdi
  62959f:	00 
  6295a0:	48 8b 7c 24 08       	mov    rdi,QWORD PTR [rsp+0x8]
  6295a5:	48 89 f8             	mov    rax,rdi
  6295a8:	ba 2c 0e 00 00       	mov    edx,0xe2c
  6295ad:	b9 1c 00 00 00       	mov    ecx,0x1c
  6295b2:	be 00 00 00 00       	mov    esi,0x0
  6295b7:	e8 d3 40 00 00       	call   0x62d68f
  6295bc:	8b 40 18             	mov    eax,DWORD PTR [rax+0x18]
  6295bf:	48 89 84 24 60 03 00 	mov    QWORD PTR [rsp+0x360],rax
  6295c6:	00 
  6295c7:	48 8b 7c 24 08       	mov    rdi,QWORD PTR [rsp+0x8]
  6295cc:	48 89 bc 24 68 03 00 	mov    QWORD PTR [rsp+0x368],rdi
  6295d3:	00 
  6295d4:	bf 97 09 00 00       	mov    edi,0x997
  6295d9:	48 89 bc 24 70 03 00 	mov    QWORD PTR [rsp+0x370],rdi
  6295e0:	00 
  6295e1:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  6295e5:	48 8b 84 24 68 03 00 	mov    rax,QWORD PTR [rsp+0x368]
  6295ec:	00 
  6295ed:	49 89 40 48          	mov    QWORD PTR [r8+0x48],rax
  6295f1:	8b 84 24 70 03 00 00 	mov    eax,DWORD PTR [rsp+0x370]
  6295f8:	49 89 40 50          	mov    QWORD PTR [r8+0x50],rax
  6295fc:	41 50                	push   r8
  6295fe:	4c 89 c7             	mov    rdi,r8
  629601:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  629608:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  62960c:	41 8b 92 5c 26 00 00 	mov    edx,DWORD PTR [r10+0x265c]
  629613:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  629617:	41 83 b8 a0 00 00 00 	cmp    DWORD PTR [r8+0xa0],0x18
  62961e:	18 
  62961f:	0f 86 80 01 00 00    	jbe    0x6297a5
  629625:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  62962c:	4d 85 d2             	test   r10,r10
  62962f:	0f 84 70 01 00 00    	je     0x6297a5
  629635:	41 8b 4a 04          	mov    ecx,DWORD PTR [r10+0x4]
  629639:	41 8b 42 08          	mov    eax,DWORD PTR [r10+0x8]
  62963d:	81 f8 00 02 00 00    	cmp    eax,0x200
  629643:	0f 87 5c 01 00 00    	ja     0x6297a5
  629649:	39 c1                	cmp    ecx,eax
  62964b:	0f 83 54 01 00 00    	jae    0x6297a5
  629651:	49 8d 44 8a 20       	lea    rax,[r10+rcx*4+0x20]
  629656:	8b 30                	mov    esi,DWORD PTR [rax]
  629658:	89 f0                	mov    eax,esi
  62965a:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  62965e:	48 c1 e0 04          	shl    rax,0x4
  629662:	49 01 c1             	add    r9,rax
  629665:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  62966c:	48 85 c0             	test   rax,rax
  62966f:	0f 84 30 01 00 00    	je     0x6297a5
  629675:	8b 08                	mov    ecx,DWORD PTR [rax]
  629677:	83 c1 07             	add    ecx,0x7
  62967a:	83 e1 f8             	and    ecx,0xfffffff8
  62967d:	41 8b 40 7c          	mov    eax,DWORD PTR [r8+0x7c]
  629681:	39 c1                	cmp    ecx,eax
  629683:	0f 87 1c 01 00 00    	ja     0x6297a5
  629689:	29 c8                	sub    eax,ecx
  62968b:	83 f8 18             	cmp    eax,0x18
  62968e:	0f 82 11 01 00 00    	jb     0x6297a5
  629694:	4d 8b 58 28          	mov    r11,QWORD PTR [r8+0x28]
  629698:	4d 85 db             	test   r11,r11
  62969b:	0f 84 04 01 00 00    	je     0x6297a5
  6296a1:	49 01 cb             	add    r11,rcx
  6296a4:	49 8b 80 98 00 00 00 	mov    rax,QWORD PTR [r8+0x98]
  6296ab:	48 85 c0             	test   rax,rax
  6296ae:	0f 84 f1 00 00 00    	je     0x6297a5
  6296b4:	8b 47 48             	mov    eax,DWORD PTR [rdi+0x48]
  6296b7:	85 c0                	test   eax,eax
  6296b9:	0f 84 42 00 00 00    	je     0x629701
  6296bf:	89 c2                	mov    edx,eax
  6296c1:	83 e2 01             	and    edx,0x1
  6296c4:	85 d2                	test   edx,edx
  6296c6:	0f 85 35 00 00 00    	jne    0x629701
  6296cc:	d1 e8                	shr    eax,1
  6296ce:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  6296d2:	0f 83 cd 00 00 00    	jae    0x6297a5
  6296d8:	4d 8b 50 08          	mov    r10,QWORD PTR [r8+0x8]
  6296dc:	48 c1 e0 04          	shl    rax,0x4
  6296e0:	49 01 c2             	add    r10,rax
  6296e3:	41 8b 42 0c          	mov    eax,DWORD PTR [r10+0xc]
  6296e7:	c1 e8 10             	shr    eax,0x10
  6296ea:	81 e0 ff 00 00 00    	and    eax,0xff
  6296f0:	85 c0                	test   eax,eax
  6296f2:	0f 84 ad 00 00 00    	je     0x6297a5
  6296f8:	83 f8 04             	cmp    eax,0x4
  6296fb:	0f 87 a4 00 00 00    	ja     0x6297a5
  629701:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  629708:	41 8b 52 04          	mov    edx,DWORD PTR [r10+0x4]
  62970c:	48 8b 83 e8 fe ff ff 	mov    rax,QWORD PTR [rbx-0x118]
  629713:	48 8b 40 10          	mov    rax,QWORD PTR [rax+0x10]
  629717:	8b 80 5c 26 00 00    	mov    eax,DWORD PTR [rax+0x265c]
  62971d:	41 89 03             	mov    DWORD PTR [r11],eax
  629720:	41 c7 43 04 18 00 00 	mov    DWORD PTR [r11+0x4],0x18
  629727:	00 
  629728:	41 c7 43 08 00 00 00 	mov    DWORD PTR [r11+0x8],0x0
  62972f:	00 
  629730:	41 c7 43 0c 00 00 00 	mov    DWORD PTR [r11+0xc],0x0
  629737:	00 
  629738:	8b 47 48             	mov    eax,DWORD PTR [rdi+0x48]
  62973b:	41 89 43 10          	mov    DWORD PTR [r11+0x10],eax
  62973f:	41 89 09             	mov    DWORD PTR [r9],ecx
  629742:	41 c7 41 04 18 00 00 	mov    DWORD PTR [r9+0x4],0x18
  629749:	00 
  62974a:	41 c7 41 08 00 00 00 	mov    DWORD PTR [r9+0x8],0x0
  629751:	00 
  629752:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  629759:	41 89 ca             	mov    r10d,ecx
  62975c:	41 83 c2 18          	add    r10d,0x18
  629760:	44 89 10             	mov    DWORD PTR [rax],r10d
  629763:	41 c7 41 0c 00 00 01 	mov    DWORD PTR [r9+0xc],0x10000
  62976a:	00 
  62976b:	83 c2 01             	add    edx,0x1
  62976e:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  629775:	41 89 52 04          	mov    DWORD PTR [r10+0x4],edx
  629779:	41 83 7a 18 00       	cmp    DWORD PTR [r10+0x18],0x0
  62977e:	0f 84 11 00 00 00    	je     0x629795
  629784:	4d 8b 90 98 00 00 00 	mov    r10,QWORD PTR [r8+0x98]
  62978b:	49 8b 02             	mov    rax,QWORD PTR [r10]
  62978e:	48 83 c0 01          	add    rax,0x1
  629792:	49 89 02             	mov    QWORD PTR [r10],rax
  629795:	89 f0                	mov    eax,esi
  629797:	d1 e0                	shl    eax,1
  629799:	48 89 87 48 02 00 00 	mov    QWORD PTR [rdi+0x248],rax
  6297a0:	e9 05 00 00 00       	jmp    0x6297aa
  6297a5:	b8 00 00 00 00       	mov    eax,0x0
  6297aa:	85 c0                	test   eax,eax
  6297ac:	41 58                	pop    r8
  6297ae:	0f 85 14 00 00 00    	jne    0x6297c8
  6297b4:	41 c7 40 40 0b c8 15 	mov    DWORD PTR [r8+0x40],0x4015c80b
  6297bb:	40 
  6297bc:	41 c7 40 44 02 00 01 	mov    DWORD PTR [r8+0x44],0x10002
  6297c3:	00 
  6297c4:	41 ff 50 38          	call   QWORD PTR [r8+0x38]
  6297c8:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  6297cc:	49 8b b8 48 02 00 00 	mov    rdi,QWORD PTR [r8+0x248]
  6297d3:	4c 8b bb e0 fe ff ff 	mov    r15,QWORD PTR [rbx-0x120]
  6297da:	48 8b b4 24 58 03 00 	mov    rsi,QWORD PTR [rsp+0x358]
  6297e1:	00 
  6297e2:	48 8b ac 24 60 03 00 	mov    rbp,QWORD PTR [rsp+0x360]
  6297e9:	00 
  6297ea:	48 89 f0             	mov    rax,rsi
  6297ed:	48 89 e9             	mov    rcx,rbp
  6297f0:	48 89 fa             	mov    rdx,rdi
  6297f3:	e8 f8 86 ff ff       	call   0x621ef0
  6297f8:	48 89 c7             	mov    rdi,rax
  6297fb:	48 89 7c 24 10       	mov    QWORD PTR [rsp+0x10],rdi
  629800:	48 8b 7c 24 10       	mov    rdi,QWORD PTR [rsp+0x10]
  629805:	48 89 f8             	mov    rax,rdi
  629808:	ba 1a 0e 00 00       	mov    edx,0xe1a
  62980d:	b9 1c 00 00 00       	mov    ecx,0x1c
  629812:	be 00 00 00 00       	mov    esi,0x0
  629817:	e8 73 3e 00 00       	call   0x62d68f
  62981c:	8b 40 18             	mov    eax,DWORD PTR [rax+0x18]
  62981f:	48 89 84 24 f0 02 00 	mov    QWORD PTR [rsp+0x2f0],rax
  629826:	00 
  629827:	48 8b bc 24 f0 02 00 	mov    rdi,QWORD PTR [rsp+0x2f0]
  62982e:	00 
  62982f:	48 89 f8             	mov    rax,rdi
  629832:	ba a0 09 00 00       	mov    edx,0x9a0
  629837:	b9 18 00 00 00       	mov    ecx,0x18
  62983c:	be 00 00 00 00       	mov    esi,0x0
  629841:	e8 49 3e 00 00       	call   0x62d68f
  629846:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  62984a:	48 89 84 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rax
  629851:	00 
  629852:	8b bc 24 58 03 00 00 	mov    edi,DWORD PTR [rsp+0x358]
  629859:	89 7c 24 18          	mov    DWORD PTR [rsp+0x18],edi
  62985d:	bf 00 00 00 00       	mov    edi,0x0
  629862:	89 7c 24 20          	mov    DWORD PTR [rsp+0x20],edi
  629866:	89 bc 24 a0 02 00 00 	mov    DWORD PTR [rsp+0x2a0],edi
  62986d:	0f 1f 00             	nop    DWORD PTR [rax]
  629870:	8b bc 24 a0 02 00 00 	mov    edi,DWORD PTR [rsp+0x2a0]
  629877:	89 7c 24 28          	mov    DWORD PTR [rsp+0x28],edi
  62987b:	48 89 bc 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rdi
  629882:	00 
  629883:	48 8b 7c 24 08       	mov    rdi,QWORD PTR [rsp+0x8]
  629888:	48 89 f8             	mov    rax,rdi
  62988b:	ba 2c 0e 00 00       	mov    edx,0xe2c
  629890:	b9 3c 00 00 00       	mov    ecx,0x3c
  629895:	be 00 00 00 00       	mov    esi,0x0
  62989a:	e8 f0 3d 00 00       	call   0x62d68f
  62989f:	8b 40 38             	mov    eax,DWORD PTR [rax+0x38]
  6298a2:	48 89 84 24 f0 02 00 	mov    QWORD PTR [rsp+0x2f0],rax
  6298a9:	00 
  6298aa:	48 8b bc 24 f0 02 00 	mov    rdi,QWORD PTR [rsp+0x2f0]
  6298b1:	00 
  6298b2:	48 89 f8             	mov    rax,rdi
  6298b5:	ba a0 09 00 00       	mov    edx,0x9a0
  6298ba:	b9 18 00 00 00       	mov    ecx,0x18
  6298bf:	be 00 00 00 00       	mov    esi,0x0
  6298c4:	e8 c6 3d 00 00       	call   0x62d68f
  6298c9:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  6298cd:	48 89 84 24 60 03 00 	mov    QWORD PTR [rsp+0x360],rax
  6298d4:	00 
  6298d5:	8b bc 24 60 03 00 00 	mov    edi,DWORD PTR [rsp+0x360]
  6298dc:	89 bc 24 00 03 00 00 	mov    DWORD PTR [rsp+0x300],edi
  6298e3:	8b bc 24 58 03 00 00 	mov    edi,DWORD PTR [rsp+0x358]
  6298ea:	89 bc 24 f8 02 00 00 	mov    DWORD PTR [rsp+0x2f8],edi
  6298f1:	8b bc 24 f8 02 00 00 	mov    edi,DWORD PTR [rsp+0x2f8]
  6298f8:	8b b4 24 00 03 00 00 	mov    esi,DWORD PTR [rsp+0x300]
  6298ff:	39 f7                	cmp    edi,esi
  629901:	0f 83 ba 26 00 00    	jae    0x62bfc1
  629907:	48 8b 7c 24 08       	mov    rdi,QWORD PTR [rsp+0x8]
  62990c:	48 89 f8             	mov    rax,rdi
  62990f:	ba 2c 0e 00 00       	mov    edx,0xe2c
  629914:	b9 3c 00 00 00       	mov    ecx,0x3c
  629919:	be 00 00 00 00       	mov    esi,0x0
  62991e:	e8 6c 3d 00 00       	call   0x62d68f
  629923:	8b 40 38             	mov    eax,DWORD PTR [rax+0x38]
  629926:	8b 7c 24 28          	mov    edi,DWORD PTR [rsp+0x28]
  62992a:	89 bc 24 10 03 00 00 	mov    DWORD PTR [rsp+0x310],edi
  629931:	48 89 84 24 08 03 00 	mov    QWORD PTR [rsp+0x308],rax
  629938:	00 
  629939:	8b bc 24 10 03 00 00 	mov    edi,DWORD PTR [rsp+0x310]
  629940:	48 89 bc 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rdi
  629947:	00 
  629948:	48 8b bc 24 08 03 00 	mov    rdi,QWORD PTR [rsp+0x308]
  62994f:	00 
  629950:	48 89 f8             	mov    rax,rdi
  629953:	ba a0 09 00 00       	mov    edx,0x9a0
  629958:	b9 18 00 00 00       	mov    ecx,0x18
  62995d:	be 00 00 00 00       	mov    esi,0x0
  629962:	e8 28 3d 00 00       	call   0x62d68f
  629967:	48 89 c5             	mov    rbp,rax
  62996a:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  62996e:	8b bc 24 58 03 00 00 	mov    edi,DWORD PTR [rsp+0x358]
  629975:	39 c7                	cmp    edi,eax
  629977:	0f 82 05 00 00 00    	jb     0x629982
  62997d:	e9 e8 3d 00 00       	jmp    0x62d76a
  629982:	8b 7d 10             	mov    edi,DWORD PTR [rbp+0x10]
  629985:	48 89 f8             	mov    rax,rdi
  629988:	8b bc 24 10 03 00 00 	mov    edi,DWORD PTR [rsp+0x310]
  62998f:	89 f9                	mov    ecx,edi
  629991:	ba 3d 23 00 00       	mov    edx,0x233d
  629996:	be 00 00 00 00       	mov    esi,0x0
  62999b:	e8 05 38 00 00       	call   0x62d1a5
  6299a0:	8b 04 20             	mov    eax,DWORD PTR [rax+riz*1]
  6299a3:	48 89 84 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rax
  6299aa:	00 
  6299ab:	48 8b bc 24 58 03 00 	mov    rdi,QWORD PTR [rsp+0x358]
  6299b2:	00 
  6299b3:	48 89 7c 24 30       	mov    QWORD PTR [rsp+0x30],rdi
  6299b8:	48 8b 7c 24 08       	mov    rdi,QWORD PTR [rsp+0x8]
  6299bd:	48 89 f8             	mov    rax,rdi
  6299c0:	ba 2c 0e 00 00       	mov    edx,0xe2c
  6299c5:	b9 1c 00 00 00       	mov    ecx,0x1c
  6299ca:	be 00 00 00 00       	mov    esi,0x0
  6299cf:	e8 bb 3c 00 00       	call   0x62d68f
  6299d4:	8b 40 18             	mov    eax,DWORD PTR [rax+0x18]
  6299d7:	48 89 84 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rax
  6299de:	00 
  6299df:	48 8b 7c 24 30       	mov    rdi,QWORD PTR [rsp+0x30]
  6299e4:	48 89 f8             	mov    rax,rdi
  6299e7:	ba 28 0e 00 00       	mov    edx,0xe28
  6299ec:	b9 2c 00 00 00       	mov    ecx,0x2c
  6299f1:	be 00 00 00 00       	mov    esi,0x0
  6299f6:	e8 94 3c 00 00       	call   0x62d68f
  6299fb:	8b 44 20 28          	mov    eax,DWORD PTR [rax+riz*1+0x28]
  6299ff:	48 8b bc 24 58 03 00 	mov    rdi,QWORD PTR [rsp+0x358]
  629a06:	00 
  629a07:	48 89 c1             	mov    rcx,rax
  629a0a:	48 89 f8             	mov    rax,rdi
  629a0d:	e8 fe fb fd ff       	call   0x609610
  629a12:	48 89 c7             	mov    rdi,rax
  629a15:	48 89 7c 24 38       	mov    QWORD PTR [rsp+0x38],rdi
  629a1a:	48 8b 7c 24 38       	mov    rdi,QWORD PTR [rsp+0x38]
  629a1f:	48 89 bc 24 90 01 00 	mov    QWORD PTR [rsp+0x190],rdi
  629a26:	00 
  629a27:	48 8b bc 24 90 01 00 	mov    rdi,QWORD PTR [rsp+0x190]
  629a2e:	00 
  629a2f:	48 89 f8             	mov    rax,rdi
  629a32:	ba f1 0d 00 00       	mov    edx,0xdf1
  629a37:	b9 00 00 00 00       	mov    ecx,0x0
  629a3c:	e8 16 3b 00 00       	call   0x62d557
  629a41:	85 c0                	test   eax,eax
  629a43:	0f 84 0a 00 00 00    	je     0x629a53
  629a49:	bd 01 00 00 00       	mov    ebp,0x1
  629a4e:	e9 05 00 00 00       	jmp    0x629a58
  629a53:	bd 00 00 00 00       	mov    ebp,0x0
  629a58:	85 ed                	test   ebp,ebp
  629a5a:	0f 85 4e 25 00 00    	jne    0x62bfae
  629a60:	48 8b 7c 24 30       	mov    rdi,QWORD PTR [rsp+0x30]
  629a65:	48 89 f8             	mov    rax,rdi
  629a68:	ba 28 0e 00 00       	mov    edx,0xe28
  629a6d:	b9 28 00 00 00       	mov    ecx,0x28
  629a72:	be 00 00 00 00       	mov    esi,0x0
  629a77:	e8 13 3c 00 00       	call   0x62d68f
  629a7c:	8b 40 24             	mov    eax,DWORD PTR [rax+0x24]
  629a7f:	48 89 84 24 a0 01 00 	mov    QWORD PTR [rsp+0x1a0],rax
  629a86:	00 
  629a87:	48 8b bc 24 a0 01 00 	mov    rdi,QWORD PTR [rsp+0x1a0]
  629a8e:	00 
  629a8f:	48 89 f8             	mov    rax,rdi
  629a92:	ba 97 09 00 00       	mov    edx,0x997
  629a97:	b9 00 00 00 00       	mov    ecx,0x0
  629a9c:	be 14 00 00 00       	mov    esi,0x14
  629aa1:	e8 4b 39 00 00       	call   0x62d3f1
  629aa6:	85 c0                	test   eax,eax
  629aa8:	0f 84 6a 04 00 00    	je     0x629f18
  629aae:	8b 7a 10             	mov    edi,DWORD PTR [rdx+0x10]
  629ab1:	48 89 f8             	mov    rax,rdi
  629ab4:	ba 46 23 00 00       	mov    edx,0x2346
  629ab9:	b9 14 00 00 00       	mov    ecx,0x14
  629abe:	be 00 00 00 00       	mov    esi,0x0
  629ac3:	e8 c7 3b 00 00       	call   0x62d68f
  629ac8:	8b 44 20 10          	mov    eax,DWORD PTR [rax+riz*1+0x10]
  629acc:	89 44 24 40          	mov    DWORD PTR [rsp+0x40],eax
  629ad0:	48 8b 7c 24 08       	mov    rdi,QWORD PTR [rsp+0x8]
  629ad5:	48 89 f8             	mov    rax,rdi
  629ad8:	ba 2c 0e 00 00       	mov    edx,0xe2c
  629add:	b9 1c 00 00 00       	mov    ecx,0x1c
  629ae2:	be 00 00 00 00       	mov    esi,0x0
  629ae7:	e8 a3 3b 00 00       	call   0x62d68f
  629aec:	8b 40 18             	mov    eax,DWORD PTR [rax+0x18]
  629aef:	8b 4c 24 40          	mov    ecx,DWORD PTR [rsp+0x40]
  629af3:	e8 78 0a fe ff       	call   0x60a570
  629af8:	48 89 c7             	mov    rdi,rax
  629afb:	48 89 bc 24 98 01 00 	mov    QWORD PTR [rsp+0x198],rdi
  629b02:	00 
  629b03:	48 8b bc 24 98 01 00 	mov    rdi,QWORD PTR [rsp+0x198]
  629b0a:	00 
  629b0b:	48 89 f8             	mov    rax,rdi
  629b0e:	ba 97 09 00 00       	mov    edx,0x997
  629b13:	b9 00 00 00 00       	mov    ecx,0x0
  629b18:	be 14 00 00 00       	mov    esi,0x14
  629b1d:	e8 cf 38 00 00       	call   0x62d3f1
  629b22:	85 c0                	test   eax,eax
  629b24:	0f 84 f3 01 00 00    	je     0x629d1d
  629b2a:	8b 7a 10             	mov    edi,DWORD PTR [rdx+0x10]
  629b2d:	48 89 f8             	mov    rax,rdi
  629b30:	ba 47 23 00 00       	mov    edx,0x2347
  629b35:	b9 18 00 00 00       	mov    ecx,0x18
  629b3a:	be 00 00 00 00       	mov    esi,0x0
  629b3f:	e8 4b 3b 00 00       	call   0x62d68f
  629b44:	48 8b 44 20 10       	mov    rax,QWORD PTR [rax+riz*1+0x10]
  629b49:	48 89 44 24 48       	mov    QWORD PTR [rsp+0x48],rax
  629b4e:	48 8b 7c 24 48       	mov    rdi,QWORD PTR [rsp+0x48]
  629b53:	48 89 bc 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rdi
  629b5a:	00 
  629b5b:	bf fa 0d 00 00       	mov    edi,0xdfa
  629b60:	48 89 bc 24 60 03 00 	mov    QWORD PTR [rsp+0x360],rdi
  629b67:	00 
  629b68:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  629b6c:	48 8b 84 24 58 03 00 	mov    rax,QWORD PTR [rsp+0x358]
  629b73:	00 
  629b74:	49 89 40 48          	mov    QWORD PTR [r8+0x48],rax
  629b78:	8b 84 24 60 03 00 00 	mov    eax,DWORD PTR [rsp+0x360]
  629b7f:	49 89 40 50          	mov    QWORD PTR [r8+0x50],rax
  629b83:	41 50                	push   r8
  629b85:	4c 89 c7             	mov    rdi,r8
  629b88:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  629b8f:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  629b93:	41 8b 92 e8 37 00 00 	mov    edx,DWORD PTR [r10+0x37e8]
  629b9a:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  629b9e:	41 83 b8 a0 00 00 00 	cmp    DWORD PTR [r8+0xa0],0x18
  629ba5:	18 
  629ba6:	0f 86 34 01 00 00    	jbe    0x629ce0
  629bac:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  629bb3:	4d 85 d2             	test   r10,r10
  629bb6:	0f 84 24 01 00 00    	je     0x629ce0
  629bbc:	41 8b 4a 04          	mov    ecx,DWORD PTR [r10+0x4]
  629bc0:	41 8b 42 08          	mov    eax,DWORD PTR [r10+0x8]
  629bc4:	81 f8 00 02 00 00    	cmp    eax,0x200
  629bca:	0f 87 10 01 00 00    	ja     0x629ce0
  629bd0:	39 c1                	cmp    ecx,eax
  629bd2:	0f 83 08 01 00 00    	jae    0x629ce0
  629bd8:	49 8d 44 8a 20       	lea    rax,[r10+rcx*4+0x20]
  629bdd:	8b 30                	mov    esi,DWORD PTR [rax]
  629bdf:	89 f0                	mov    eax,esi
  629be1:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  629be5:	48 c1 e0 04          	shl    rax,0x4
  629be9:	49 01 c1             	add    r9,rax
  629bec:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  629bf3:	48 85 c0             	test   rax,rax
  629bf6:	0f 84 e4 00 00 00    	je     0x629ce0
  629bfc:	8b 08                	mov    ecx,DWORD PTR [rax]
  629bfe:	83 c1 07             	add    ecx,0x7
  629c01:	83 e1 f8             	and    ecx,0xfffffff8
  629c04:	41 8b 40 7c          	mov    eax,DWORD PTR [r8+0x7c]
  629c08:	39 c1                	cmp    ecx,eax
  629c0a:	0f 87 d0 00 00 00    	ja     0x629ce0
  629c10:	29 c8                	sub    eax,ecx
  629c12:	83 f8 18             	cmp    eax,0x18
  629c15:	0f 82 c5 00 00 00    	jb     0x629ce0
  629c1b:	4d 8b 58 28          	mov    r11,QWORD PTR [r8+0x28]
  629c1f:	4d 85 db             	test   r11,r11
  629c22:	0f 84 b8 00 00 00    	je     0x629ce0
  629c28:	49 01 cb             	add    r11,rcx
  629c2b:	49 8b 80 98 00 00 00 	mov    rax,QWORD PTR [r8+0x98]
  629c32:	48 85 c0             	test   rax,rax
  629c35:	0f 84 a5 00 00 00    	je     0x629ce0
  629c3b:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  629c42:	41 8b 52 04          	mov    edx,DWORD PTR [r10+0x4]
  629c46:	48 8b 83 e8 fe ff ff 	mov    rax,QWORD PTR [rbx-0x118]
  629c4d:	48 8b 40 10          	mov    rax,QWORD PTR [rax+0x10]
  629c51:	8b 80 e8 37 00 00    	mov    eax,DWORD PTR [rax+0x37e8]
  629c57:	41 89 03             	mov    DWORD PTR [r11],eax
  629c5a:	41 c7 43 04 18 00 00 	mov    DWORD PTR [r11+0x4],0x18
  629c61:	00 
  629c62:	41 c7 43 08 00 00 00 	mov    DWORD PTR [r11+0x8],0x0
  629c69:	00 
  629c6a:	41 c7 43 0c 01 00 00 	mov    DWORD PTR [r11+0xc],0x1
  629c71:	00 
  629c72:	48 8b 47 48          	mov    rax,QWORD PTR [rdi+0x48]
  629c76:	49 89 43 10          	mov    QWORD PTR [r11+0x10],rax
  629c7a:	41 89 09             	mov    DWORD PTR [r9],ecx
  629c7d:	41 c7 41 04 18 00 00 	mov    DWORD PTR [r9+0x4],0x18
  629c84:	00 
  629c85:	41 c7 41 08 00 00 00 	mov    DWORD PTR [r9+0x8],0x0
  629c8c:	00 
  629c8d:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  629c94:	41 89 ca             	mov    r10d,ecx
  629c97:	41 83 c2 18          	add    r10d,0x18
  629c9b:	44 89 10             	mov    DWORD PTR [rax],r10d
  629c9e:	41 c7 41 0c 00 00 01 	mov    DWORD PTR [r9+0xc],0x10000
  629ca5:	00 
  629ca6:	83 c2 01             	add    edx,0x1
  629ca9:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  629cb0:	41 89 52 04          	mov    DWORD PTR [r10+0x4],edx
  629cb4:	41 83 7a 18 00       	cmp    DWORD PTR [r10+0x18],0x0
  629cb9:	0f 84 11 00 00 00    	je     0x629cd0
  629cbf:	4d 8b 90 98 00 00 00 	mov    r10,QWORD PTR [r8+0x98]
  629cc6:	49 8b 02             	mov    rax,QWORD PTR [r10]
  629cc9:	48 83 c0 01          	add    rax,0x1
  629ccd:	49 89 02             	mov    QWORD PTR [r10],rax
  629cd0:	89 f0                	mov    eax,esi
  629cd2:	d1 e0                	shl    eax,1
  629cd4:	48 89 87 48 02 00 00 	mov    QWORD PTR [rdi+0x248],rax
  629cdb:	e9 05 00 00 00       	jmp    0x629ce5
  629ce0:	b8 00 00 00 00       	mov    eax,0x0
  629ce5:	85 c0                	test   eax,eax
  629ce7:	41 58                	pop    r8
  629ce9:	0f 85 14 00 00 00    	jne    0x629d03
  629cef:	41 c7 40 40 0b c9 15 	mov    DWORD PTR [r8+0x40],0x4015c90b
  629cf6:	40 
  629cf7:	41 c7 40 44 02 00 01 	mov    DWORD PTR [r8+0x44],0x10002
  629cfe:	00 
  629cff:	41 ff 50 38          	call   QWORD PTR [r8+0x38]
  629d03:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  629d07:	49 8b b8 48 02 00 00 	mov    rdi,QWORD PTR [r8+0x248]
  629d0e:	4c 8b bb e0 fe ff ff 	mov    r15,QWORD PTR [rbx-0x120]
  629d15:	48 89 fd             	mov    rbp,rdi
  629d18:	e9 f6 01 00 00       	jmp    0x629f13
  629d1d:	48 8b bc 24 98 01 00 	mov    rdi,QWORD PTR [rsp+0x198]
  629d24:	00 
  629d25:	48 89 f8             	mov    rax,rdi
  629d28:	ba 95 09 00 00       	mov    edx,0x995
  629d2d:	b9 00 00 00 00       	mov    ecx,0x0
  629d32:	e8 20 38 00 00       	call   0x62d557
  629d37:	85 c0                	test   eax,eax
  629d39:	0f 84 cf 01 00 00    	je     0x629f0e
  629d3f:	bf 00 00 00 00       	mov    edi,0x0
  629d44:	48 89 bc 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rdi
  629d4b:	00 
  629d4c:	bf fa 0d 00 00       	mov    edi,0xdfa
  629d51:	48 89 bc 24 60 03 00 	mov    QWORD PTR [rsp+0x360],rdi
  629d58:	00 
  629d59:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  629d5d:	48 8b 84 24 58 03 00 	mov    rax,QWORD PTR [rsp+0x358]
  629d64:	00 
  629d65:	49 89 40 48          	mov    QWORD PTR [r8+0x48],rax
  629d69:	8b 84 24 60 03 00 00 	mov    eax,DWORD PTR [rsp+0x360]
  629d70:	49 89 40 50          	mov    QWORD PTR [r8+0x50],rax
  629d74:	41 50                	push   r8
  629d76:	4c 89 c7             	mov    rdi,r8
  629d79:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  629d80:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  629d84:	41 8b 92 e8 37 00 00 	mov    edx,DWORD PTR [r10+0x37e8]
  629d8b:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  629d8f:	41 83 b8 a0 00 00 00 	cmp    DWORD PTR [r8+0xa0],0x18
  629d96:	18 
  629d97:	0f 86 34 01 00 00    	jbe    0x629ed1
  629d9d:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  629da4:	4d 85 d2             	test   r10,r10
  629da7:	0f 84 24 01 00 00    	je     0x629ed1
  629dad:	41 8b 4a 04          	mov    ecx,DWORD PTR [r10+0x4]
  629db1:	41 8b 42 08          	mov    eax,DWORD PTR [r10+0x8]
  629db5:	81 f8 00 02 00 00    	cmp    eax,0x200
  629dbb:	0f 87 10 01 00 00    	ja     0x629ed1
  629dc1:	39 c1                	cmp    ecx,eax
  629dc3:	0f 83 08 01 00 00    	jae    0x629ed1
  629dc9:	49 8d 44 8a 20       	lea    rax,[r10+rcx*4+0x20]
  629dce:	8b 30                	mov    esi,DWORD PTR [rax]
  629dd0:	89 f0                	mov    eax,esi
  629dd2:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  629dd6:	48 c1 e0 04          	shl    rax,0x4
  629dda:	49 01 c1             	add    r9,rax
  629ddd:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  629de4:	48 85 c0             	test   rax,rax
  629de7:	0f 84 e4 00 00 00    	je     0x629ed1
  629ded:	8b 08                	mov    ecx,DWORD PTR [rax]
  629def:	83 c1 07             	add    ecx,0x7
  629df2:	83 e1 f8             	and    ecx,0xfffffff8
  629df5:	41 8b 40 7c          	mov    eax,DWORD PTR [r8+0x7c]
  629df9:	39 c1                	cmp    ecx,eax
  629dfb:	0f 87 d0 00 00 00    	ja     0x629ed1
  629e01:	29 c8                	sub    eax,ecx
  629e03:	83 f8 18             	cmp    eax,0x18
  629e06:	0f 82 c5 00 00 00    	jb     0x629ed1
  629e0c:	4d 8b 58 28          	mov    r11,QWORD PTR [r8+0x28]
  629e10:	4d 85 db             	test   r11,r11
  629e13:	0f 84 b8 00 00 00    	je     0x629ed1
  629e19:	49 01 cb             	add    r11,rcx
  629e1c:	49 8b 80 98 00 00 00 	mov    rax,QWORD PTR [r8+0x98]
  629e23:	48 85 c0             	test   rax,rax
  629e26:	0f 84 a5 00 00 00    	je     0x629ed1
  629e2c:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  629e33:	41 8b 52 04          	mov    edx,DWORD PTR [r10+0x4]
  629e37:	48 8b 83 e8 fe ff ff 	mov    rax,QWORD PTR [rbx-0x118]
  629e3e:	48 8b 40 10          	mov    rax,QWORD PTR [rax+0x10]
  629e42:	8b 80 e8 37 00 00    	mov    eax,DWORD PTR [rax+0x37e8]
  629e48:	41 89 03             	mov    DWORD PTR [r11],eax
  629e4b:	41 c7 43 04 18 00 00 	mov    DWORD PTR [r11+0x4],0x18
  629e52:	00 
  629e53:	41 c7 43 08 00 00 00 	mov    DWORD PTR [r11+0x8],0x0
  629e5a:	00 
  629e5b:	41 c7 43 0c 01 00 00 	mov    DWORD PTR [r11+0xc],0x1
  629e62:	00 
  629e63:	48 8b 47 48          	mov    rax,QWORD PTR [rdi+0x48]
  629e67:	49 89 43 10          	mov    QWORD PTR [r11+0x10],rax
  629e6b:	41 89 09             	mov    DWORD PTR [r9],ecx
  629e6e:	41 c7 41 04 18 00 00 	mov    DWORD PTR [r9+0x4],0x18
  629e75:	00 
  629e76:	41 c7 41 08 00 00 00 	mov    DWORD PTR [r9+0x8],0x0
  629e7d:	00 
  629e7e:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  629e85:	41 89 ca             	mov    r10d,ecx
  629e88:	41 83 c2 18          	add    r10d,0x18
  629e8c:	44 89 10             	mov    DWORD PTR [rax],r10d
  629e8f:	41 c7 41 0c 00 00 01 	mov    DWORD PTR [r9+0xc],0x10000
  629e96:	00 
  629e97:	83 c2 01             	add    edx,0x1
  629e9a:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  629ea1:	41 89 52 04          	mov    DWORD PTR [r10+0x4],edx
  629ea5:	41 83 7a 18 00       	cmp    DWORD PTR [r10+0x18],0x0
  629eaa:	0f 84 11 00 00 00    	je     0x629ec1
  629eb0:	4d 8b 90 98 00 00 00 	mov    r10,QWORD PTR [r8+0x98]
  629eb7:	49 8b 02             	mov    rax,QWORD PTR [r10]
  629eba:	48 83 c0 01          	add    rax,0x1
  629ebe:	49 89 02             	mov    QWORD PTR [r10],rax
  629ec1:	89 f0                	mov    eax,esi
  629ec3:	d1 e0                	shl    eax,1
  629ec5:	48 89 87 48 02 00 00 	mov    QWORD PTR [rdi+0x248],rax
  629ecc:	e9 05 00 00 00       	jmp    0x629ed6
  629ed1:	b8 00 00 00 00       	mov    eax,0x0
  629ed6:	85 c0                	test   eax,eax
  629ed8:	41 58                	pop    r8
  629eda:	0f 85 14 00 00 00    	jne    0x629ef4
  629ee0:	41 c7 40 40 0b ca 15 	mov    DWORD PTR [r8+0x40],0x4015ca0b
  629ee7:	40 
  629ee8:	41 c7 40 44 02 00 01 	mov    DWORD PTR [r8+0x44],0x10002
  629eef:	00 
  629ef0:	41 ff 50 38          	call   QWORD PTR [r8+0x38]
  629ef4:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  629ef8:	49 8b b8 48 02 00 00 	mov    rdi,QWORD PTR [r8+0x248]
  629eff:	4c 8b bb e0 fe ff ff 	mov    r15,QWORD PTR [rbx-0x120]
  629f06:	48 89 fd             	mov    rbp,rdi
  629f09:	e9 05 00 00 00       	jmp    0x629f13
  629f0e:	e9 ac 38 00 00       	jmp    0x62d7bf
  629f13:	e9 d5 01 00 00       	jmp    0x62a0ed
  629f18:	48 8b bc 24 a0 01 00 	mov    rdi,QWORD PTR [rsp+0x1a0]
  629f1f:	00 
  629f20:	48 89 f8             	mov    rax,rdi
  629f23:	ba 95 09 00 00       	mov    edx,0x995
  629f28:	b9 00 00 00 00       	mov    ecx,0x0
  629f2d:	e8 25 36 00 00       	call   0x62d557
  629f32:	85 c0                	test   eax,eax
  629f34:	0f 84 ae 01 00 00    	je     0x62a0e8
  629f3a:	bf f8 0d 00 00       	mov    edi,0xdf8
  629f3f:	48 89 bc 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rdi
  629f46:	00 
  629f47:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  629f4b:	8b 84 24 58 03 00 00 	mov    eax,DWORD PTR [rsp+0x358]
  629f52:	49 89 40 48          	mov    QWORD PTR [r8+0x48],rax
  629f56:	41 50                	push   r8
  629f58:	4c 89 c7             	mov    rdi,r8
  629f5b:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  629f62:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  629f66:	41 8b 92 e0 37 00 00 	mov    edx,DWORD PTR [r10+0x37e0]
  629f6d:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  629f71:	41 83 b8 a0 00 00 00 	cmp    DWORD PTR [r8+0xa0],0x10
  629f78:	10 
  629f79:	0f 86 2c 01 00 00    	jbe    0x62a0ab
  629f7f:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  629f86:	4d 85 d2             	test   r10,r10
  629f89:	0f 84 1c 01 00 00    	je     0x62a0ab
  629f8f:	41 8b 4a 04          	mov    ecx,DWORD PTR [r10+0x4]
  629f93:	41 8b 42 08          	mov    eax,DWORD PTR [r10+0x8]
  629f97:	81 f8 00 02 00 00    	cmp    eax,0x200
  629f9d:	0f 87 08 01 00 00    	ja     0x62a0ab
  629fa3:	39 c1                	cmp    ecx,eax
  629fa5:	0f 83 00 01 00 00    	jae    0x62a0ab
  629fab:	49 8d 44 8a 20       	lea    rax,[r10+rcx*4+0x20]
  629fb0:	8b 30                	mov    esi,DWORD PTR [rax]
  629fb2:	89 f0                	mov    eax,esi
  629fb4:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  629fb8:	48 c1 e0 04          	shl    rax,0x4
  629fbc:	49 01 c1             	add    r9,rax
  629fbf:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  629fc6:	48 85 c0             	test   rax,rax
  629fc9:	0f 84 dc 00 00 00    	je     0x62a0ab
  629fcf:	8b 08                	mov    ecx,DWORD PTR [rax]
  629fd1:	83 c1 07             	add    ecx,0x7
  629fd4:	83 e1 f8             	and    ecx,0xfffffff8
  629fd7:	41 8b 40 7c          	mov    eax,DWORD PTR [r8+0x7c]
  629fdb:	39 c1                	cmp    ecx,eax
  629fdd:	0f 87 c8 00 00 00    	ja     0x62a0ab
  629fe3:	29 c8                	sub    eax,ecx
  629fe5:	83 f8 10             	cmp    eax,0x10
  629fe8:	0f 82 bd 00 00 00    	jb     0x62a0ab
  629fee:	4d 8b 58 28          	mov    r11,QWORD PTR [r8+0x28]
  629ff2:	4d 85 db             	test   r11,r11
  629ff5:	0f 84 b0 00 00 00    	je     0x62a0ab
  629ffb:	49 01 cb             	add    r11,rcx
  629ffe:	49 8b 80 98 00 00 00 	mov    rax,QWORD PTR [r8+0x98]
  62a005:	48 85 c0             	test   rax,rax
  62a008:	0f 84 9d 00 00 00    	je     0x62a0ab
  62a00e:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  62a015:	41 8b 52 04          	mov    edx,DWORD PTR [r10+0x4]
  62a019:	48 8b 83 e8 fe ff ff 	mov    rax,QWORD PTR [rbx-0x118]
  62a020:	48 8b 40 10          	mov    rax,QWORD PTR [rax+0x10]
  62a024:	8b 80 e0 37 00 00    	mov    eax,DWORD PTR [rax+0x37e0]
  62a02a:	41 89 03             	mov    DWORD PTR [r11],eax
  62a02d:	41 c7 43 04 10 00 00 	mov    DWORD PTR [r11+0x4],0x10
  62a034:	00 
  62a035:	41 c7 43 08 00 00 00 	mov    DWORD PTR [r11+0x8],0x0
  62a03c:	00 
  62a03d:	41 c7 43 0c 01 00 00 	mov    DWORD PTR [r11+0xc],0x1
  62a044:	00 
  62a045:	41 89 09             	mov    DWORD PTR [r9],ecx
  62a048:	41 c7 41 04 10 00 00 	mov    DWORD PTR [r9+0x4],0x10
  62a04f:	00 
  62a050:	41 c7 41 08 00 00 00 	mov    DWORD PTR [r9+0x8],0x0
  62a057:	00 
  62a058:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  62a05f:	41 89 ca             	mov    r10d,ecx
  62a062:	41 83 c2 10          	add    r10d,0x10
  62a066:	44 89 10             	mov    DWORD PTR [rax],r10d
  62a069:	41 c7 41 0c 00 00 01 	mov    DWORD PTR [r9+0xc],0x10000
  62a070:	00 
  62a071:	83 c2 01             	add    edx,0x1
  62a074:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  62a07b:	41 89 52 04          	mov    DWORD PTR [r10+0x4],edx
  62a07f:	41 83 7a 18 00       	cmp    DWORD PTR [r10+0x18],0x0
  62a084:	0f 84 11 00 00 00    	je     0x62a09b
  62a08a:	4d 8b 90 98 00 00 00 	mov    r10,QWORD PTR [r8+0x98]
  62a091:	49 8b 02             	mov    rax,QWORD PTR [r10]
  62a094:	48 83 c0 01          	add    rax,0x1
  62a098:	49 89 02             	mov    QWORD PTR [r10],rax
  62a09b:	89 f0                	mov    eax,esi
  62a09d:	d1 e0                	shl    eax,1
  62a09f:	48 89 87 48 02 00 00 	mov    QWORD PTR [rdi+0x248],rax
  62a0a6:	e9 05 00 00 00       	jmp    0x62a0b0
  62a0ab:	b8 00 00 00 00       	mov    eax,0x0
  62a0b0:	85 c0                	test   eax,eax
  62a0b2:	41 58                	pop    r8
  62a0b4:	0f 85 14 00 00 00    	jne    0x62a0ce
  62a0ba:	41 c7 40 40 0b cb 15 	mov    DWORD PTR [r8+0x40],0x4015cb0b
  62a0c1:	40 
  62a0c2:	41 c7 40 44 01 00 01 	mov    DWORD PTR [r8+0x44],0x10001
  62a0c9:	00 
  62a0ca:	41 ff 50 38          	call   QWORD PTR [r8+0x38]
  62a0ce:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  62a0d2:	49 8b b8 48 02 00 00 	mov    rdi,QWORD PTR [r8+0x248]
  62a0d9:	4c 8b bb e0 fe ff ff 	mov    r15,QWORD PTR [rbx-0x120]
  62a0e0:	48 89 fd             	mov    rbp,rdi
  62a0e3:	e9 05 00 00 00       	jmp    0x62a0ed
  62a0e8:	e9 d2 36 00 00       	jmp    0x62d7bf
  62a0ed:	48 89 6c 24 50       	mov    QWORD PTR [rsp+0x50],rbp
  62a0f2:	48 8b 7c 24 10       	mov    rdi,QWORD PTR [rsp+0x10]
  62a0f7:	48 89 f8             	mov    rax,rdi
  62a0fa:	ba 1a 0e 00 00       	mov    edx,0xe1a
  62a0ff:	b9 20 00 00 00       	mov    ecx,0x20
  62a104:	be 00 00 00 00       	mov    esi,0x0
  62a109:	e8 81 35 00 00       	call   0x62d68f
  62a10e:	8b 40 1c             	mov    eax,DWORD PTR [rax+0x1c]
  62a111:	48 89 84 24 f0 02 00 	mov    QWORD PTR [rsp+0x2f0],rax
  62a118:	00 
  62a119:	48 8b bc 24 f0 02 00 	mov    rdi,QWORD PTR [rsp+0x2f0]
  62a120:	00 
  62a121:	48 89 f8             	mov    rax,rdi
  62a124:	ba a0 09 00 00       	mov    edx,0x9a0
  62a129:	b9 18 00 00 00       	mov    ecx,0x18
  62a12e:	be 00 00 00 00       	mov    esi,0x0
  62a133:	e8 57 35 00 00       	call   0x62d68f
  62a138:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  62a13c:	48 89 84 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rax
  62a143:	00 
  62a144:	8b bc 24 58 03 00 00 	mov    edi,DWORD PTR [rsp+0x358]
  62a14b:	89 7c 24 58          	mov    DWORD PTR [rsp+0x58],edi
  62a14f:	48 8b 7c 24 10       	mov    rdi,QWORD PTR [rsp+0x10]
  62a154:	48 89 f8             	mov    rax,rdi
  62a157:	ba 1a 0e 00 00       	mov    edx,0xe1a
  62a15c:	b9 1c 00 00 00       	mov    ecx,0x1c
  62a161:	be 00 00 00 00       	mov    esi,0x0
  62a166:	e8 24 35 00 00       	call   0x62d68f
  62a16b:	8b 40 18             	mov    eax,DWORD PTR [rax+0x18]
  62a16e:	48 89 84 24 f0 02 00 	mov    QWORD PTR [rsp+0x2f0],rax
  62a175:	00 
  62a176:	48 8b bc 24 f0 02 00 	mov    rdi,QWORD PTR [rsp+0x2f0]
  62a17d:	00 
  62a17e:	48 89 f8             	mov    rax,rdi
  62a181:	ba a0 09 00 00       	mov    edx,0x9a0
  62a186:	b9 18 00 00 00       	mov    ecx,0x18
  62a18b:	be 00 00 00 00       	mov    esi,0x0
  62a190:	e8 fa 34 00 00       	call   0x62d68f
  62a195:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  62a199:	48 89 84 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rax
  62a1a0:	00 
  62a1a1:	8b bc 24 58 03 00 00 	mov    edi,DWORD PTR [rsp+0x358]
  62a1a8:	89 7c 24 60          	mov    DWORD PTR [rsp+0x60],edi
  62a1ac:	bf 00 00 00 00       	mov    edi,0x0
  62a1b1:	89 7c 24 68          	mov    DWORD PTR [rsp+0x68],edi
  62a1b5:	89 bc 24 40 02 00 00 	mov    DWORD PTR [rsp+0x240],edi
  62a1bc:	66 0f 1f 84 00 00 00 	nop    WORD PTR [rax+rax*1+0x0]
  62a1c3:	00 00 
  62a1c5:	0f 1f 00             	nop    DWORD PTR [rax]
  62a1c8:	8b bc 24 40 02 00 00 	mov    edi,DWORD PTR [rsp+0x240]
  62a1cf:	89 7c 24 70          	mov    DWORD PTR [rsp+0x70],edi
  62a1d3:	48 89 bc 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rdi
  62a1da:	00 
  62a1db:	48 8b 7c 24 08       	mov    rdi,QWORD PTR [rsp+0x8]
  62a1e0:	48 89 f8             	mov    rax,rdi
  62a1e3:	ba 2c 0e 00 00       	mov    edx,0xe2c
  62a1e8:	b9 24 00 00 00       	mov    ecx,0x24
  62a1ed:	be 00 00 00 00       	mov    esi,0x0
  62a1f2:	e8 98 34 00 00       	call   0x62d68f
  62a1f7:	8b 40 20             	mov    eax,DWORD PTR [rax+0x20]
  62a1fa:	48 89 84 24 f0 02 00 	mov    QWORD PTR [rsp+0x2f0],rax
  62a201:	00 
  62a202:	48 8b bc 24 f0 02 00 	mov    rdi,QWORD PTR [rsp+0x2f0]
  62a209:	00 
  62a20a:	48 89 f8             	mov    rax,rdi
  62a20d:	ba a0 09 00 00       	mov    edx,0x9a0
  62a212:	b9 18 00 00 00       	mov    ecx,0x18
  62a217:	be 00 00 00 00       	mov    esi,0x0
  62a21c:	e8 6e 34 00 00       	call   0x62d68f
  62a221:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  62a225:	48 89 84 24 60 03 00 	mov    QWORD PTR [rsp+0x360],rax
  62a22c:	00 
  62a22d:	8b bc 24 60 03 00 00 	mov    edi,DWORD PTR [rsp+0x360]
  62a234:	89 bc 24 00 03 00 00 	mov    DWORD PTR [rsp+0x300],edi
  62a23b:	8b bc 24 58 03 00 00 	mov    edi,DWORD PTR [rsp+0x358]
  62a242:	89 bc 24 f8 02 00 00 	mov    DWORD PTR [rsp+0x2f8],edi
  62a249:	8b bc 24 f8 02 00 00 	mov    edi,DWORD PTR [rsp+0x2f8]
  62a250:	8b b4 24 00 03 00 00 	mov    esi,DWORD PTR [rsp+0x300]
  62a257:	39 f7                	cmp    edi,esi
  62a259:	0f 83 bc 15 00 00    	jae    0x62b81b
  62a25f:	48 8b 7c 24 08       	mov    rdi,QWORD PTR [rsp+0x8]
  62a264:	48 89 f8             	mov    rax,rdi
  62a267:	ba 2c 0e 00 00       	mov    edx,0xe2c
  62a26c:	b9 24 00 00 00       	mov    ecx,0x24
  62a271:	be 00 00 00 00       	mov    esi,0x0
  62a276:	e8 14 34 00 00       	call   0x62d68f
  62a27b:	8b 40 20             	mov    eax,DWORD PTR [rax+0x20]
  62a27e:	8b 7c 24 70          	mov    edi,DWORD PTR [rsp+0x70]
  62a282:	89 bc 24 10 03 00 00 	mov    DWORD PTR [rsp+0x310],edi
  62a289:	48 89 84 24 08 03 00 	mov    QWORD PTR [rsp+0x308],rax
  62a290:	00 
  62a291:	8b bc 24 10 03 00 00 	mov    edi,DWORD PTR [rsp+0x310]
  62a298:	48 89 bc 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rdi
  62a29f:	00 
  62a2a0:	48 8b bc 24 08 03 00 	mov    rdi,QWORD PTR [rsp+0x308]
  62a2a7:	00 
  62a2a8:	48 89 f8             	mov    rax,rdi
  62a2ab:	ba a0 09 00 00       	mov    edx,0x9a0
  62a2b0:	b9 18 00 00 00       	mov    ecx,0x18
  62a2b5:	be 00 00 00 00       	mov    esi,0x0
  62a2ba:	e8 d0 33 00 00       	call   0x62d68f
  62a2bf:	48 89 c5             	mov    rbp,rax
  62a2c2:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  62a2c6:	8b bc 24 58 03 00 00 	mov    edi,DWORD PTR [rsp+0x358]
  62a2cd:	39 c7                	cmp    edi,eax
  62a2cf:	0f 82 05 00 00 00    	jb     0x62a2da
  62a2d5:	e9 90 34 00 00       	jmp    0x62d76a
  62a2da:	8b 7d 10             	mov    edi,DWORD PTR [rbp+0x10]
  62a2dd:	48 89 f8             	mov    rax,rdi
  62a2e0:	8b bc 24 10 03 00 00 	mov    edi,DWORD PTR [rsp+0x310]
  62a2e7:	89 f9                	mov    ecx,edi
  62a2e9:	ba 3d 23 00 00       	mov    edx,0x233d
  62a2ee:	be 00 00 00 00       	mov    esi,0x0
  62a2f3:	e8 ad 2e 00 00       	call   0x62d1a5
  62a2f8:	8b 04 20             	mov    eax,DWORD PTR [rax+riz*1]
  62a2fb:	48 89 84 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rax
  62a302:	00 
  62a303:	48 8b bc 24 58 03 00 	mov    rdi,QWORD PTR [rsp+0x358]
  62a30a:	00 
  62a30b:	48 89 7c 24 78       	mov    QWORD PTR [rsp+0x78],rdi
  62a310:	48 8b 7c 24 78       	mov    rdi,QWORD PTR [rsp+0x78]
  62a315:	48 89 f8             	mov    rax,rdi
  62a318:	ba 2b 0e 00 00       	mov    edx,0xe2b
  62a31d:	b9 20 00 00 00       	mov    ecx,0x20
  62a322:	be 00 00 00 00       	mov    esi,0x0
  62a327:	e8 63 33 00 00       	call   0x62d68f
  62a32c:	8b 40 1c             	mov    eax,DWORD PTR [rax+0x1c]
  62a32f:	48 89 84 24 a8 01 00 	mov    QWORD PTR [rsp+0x1a8],rax
  62a336:	00 
  62a337:	48 8b bc 24 a8 01 00 	mov    rdi,QWORD PTR [rsp+0x1a8]
  62a33e:	00 
  62a33f:	48 89 f8             	mov    rax,rdi
  62a342:	ba 75 0f 00 00       	mov    edx,0xf75
  62a347:	b9 00 00 00 00       	mov    ecx,0x0
  62a34c:	be 18 00 00 00       	mov    esi,0x18
  62a351:	e8 9b 30 00 00       	call   0x62d3f1
  62a356:	85 c0                	test   eax,eax
  62a358:	0f 84 ed 03 00 00    	je     0x62a74b
  62a35e:	48 8b 7c 22 10       	mov    rdi,QWORD PTR [rdx+riz*1+0x10]
  62a363:	48 89 bc 24 80 00 00 	mov    QWORD PTR [rsp+0x80],rdi
  62a36a:	00 
  62a36b:	48 8b bc 24 80 00 00 	mov    rdi,QWORD PTR [rsp+0x80]
  62a372:	00 
  62a373:	48 89 bc 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rdi
  62a37a:	00 
  62a37b:	bf 47 23 00 00       	mov    edi,0x2347
  62a380:	48 89 bc 24 60 03 00 	mov    QWORD PTR [rsp+0x360],rdi
  62a387:	00 
  62a388:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  62a38c:	48 8b 84 24 58 03 00 	mov    rax,QWORD PTR [rsp+0x358]
  62a393:	00 
  62a394:	49 89 40 48          	mov    QWORD PTR [r8+0x48],rax
  62a398:	8b 84 24 60 03 00 00 	mov    eax,DWORD PTR [rsp+0x360]
  62a39f:	49 89 40 50          	mov    QWORD PTR [r8+0x50],rax
  62a3a3:	41 50                	push   r8
  62a3a5:	4c 89 c7             	mov    rdi,r8
  62a3a8:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  62a3af:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  62a3b3:	41 8b 92 1c 8d 00 00 	mov    edx,DWORD PTR [r10+0x8d1c]
  62a3ba:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  62a3be:	41 83 b8 a0 00 00 00 	cmp    DWORD PTR [r8+0xa0],0x18
  62a3c5:	18 
  62a3c6:	0f 86 34 01 00 00    	jbe    0x62a500
  62a3cc:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  62a3d3:	4d 85 d2             	test   r10,r10
  62a3d6:	0f 84 24 01 00 00    	je     0x62a500
  62a3dc:	41 8b 4a 04          	mov    ecx,DWORD PTR [r10+0x4]
  62a3e0:	41 8b 42 08          	mov    eax,DWORD PTR [r10+0x8]
  62a3e4:	81 f8 00 02 00 00    	cmp    eax,0x200
  62a3ea:	0f 87 10 01 00 00    	ja     0x62a500
  62a3f0:	39 c1                	cmp    ecx,eax
  62a3f2:	0f 83 08 01 00 00    	jae    0x62a500
  62a3f8:	49 8d 44 8a 20       	lea    rax,[r10+rcx*4+0x20]
  62a3fd:	8b 30                	mov    esi,DWORD PTR [rax]
  62a3ff:	89 f0                	mov    eax,esi
  62a401:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  62a405:	48 c1 e0 04          	shl    rax,0x4
  62a409:	49 01 c1             	add    r9,rax
  62a40c:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  62a413:	48 85 c0             	test   rax,rax
  62a416:	0f 84 e4 00 00 00    	je     0x62a500
  62a41c:	8b 08                	mov    ecx,DWORD PTR [rax]
  62a41e:	83 c1 07             	add    ecx,0x7
  62a421:	83 e1 f8             	and    ecx,0xfffffff8
  62a424:	41 8b 40 7c          	mov    eax,DWORD PTR [r8+0x7c]
  62a428:	39 c1                	cmp    ecx,eax
  62a42a:	0f 87 d0 00 00 00    	ja     0x62a500
  62a430:	29 c8                	sub    eax,ecx
  62a432:	83 f8 18             	cmp    eax,0x18
  62a435:	0f 82 c5 00 00 00    	jb     0x62a500
  62a43b:	4d 8b 58 28          	mov    r11,QWORD PTR [r8+0x28]
  62a43f:	4d 85 db             	test   r11,r11
  62a442:	0f 84 b8 00 00 00    	je     0x62a500
  62a448:	49 01 cb             	add    r11,rcx
  62a44b:	49 8b 80 98 00 00 00 	mov    rax,QWORD PTR [r8+0x98]
  62a452:	48 85 c0             	test   rax,rax
  62a455:	0f 84 a5 00 00 00    	je     0x62a500
  62a45b:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  62a462:	41 8b 52 04          	mov    edx,DWORD PTR [r10+0x4]
  62a466:	48 8b 83 e8 fe ff ff 	mov    rax,QWORD PTR [rbx-0x118]
  62a46d:	48 8b 40 10          	mov    rax,QWORD PTR [rax+0x10]
  62a471:	8b 80 1c 8d 00 00    	mov    eax,DWORD PTR [rax+0x8d1c]
  62a477:	41 89 03             	mov    DWORD PTR [r11],eax
  62a47a:	41 c7 43 04 18 00 00 	mov    DWORD PTR [r11+0x4],0x18
  62a481:	00 
  62a482:	41 c7 43 08 00 00 00 	mov    DWORD PTR [r11+0x8],0x0
  62a489:	00 
  62a48a:	41 c7 43 0c 01 00 00 	mov    DWORD PTR [r11+0xc],0x1
  62a491:	00 
  62a492:	48 8b 47 48          	mov    rax,QWORD PTR [rdi+0x48]
  62a496:	49 89 43 10          	mov    QWORD PTR [r11+0x10],rax
  62a49a:	41 89 09             	mov    DWORD PTR [r9],ecx
  62a49d:	41 c7 41 04 18 00 00 	mov    DWORD PTR [r9+0x4],0x18
  62a4a4:	00 
  62a4a5:	41 c7 41 08 00 00 00 	mov    DWORD PTR [r9+0x8],0x0
  62a4ac:	00 
  62a4ad:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  62a4b4:	41 89 ca             	mov    r10d,ecx
  62a4b7:	41 83 c2 18          	add    r10d,0x18
  62a4bb:	44 89 10             	mov    DWORD PTR [rax],r10d
  62a4be:	41 c7 41 0c 00 00 01 	mov    DWORD PTR [r9+0xc],0x10000
  62a4c5:	00 
  62a4c6:	83 c2 01             	add    edx,0x1
  62a4c9:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  62a4d0:	41 89 52 04          	mov    DWORD PTR [r10+0x4],edx
  62a4d4:	41 83 7a 18 00       	cmp    DWORD PTR [r10+0x18],0x0
  62a4d9:	0f 84 11 00 00 00    	je     0x62a4f0
  62a4df:	4d 8b 90 98 00 00 00 	mov    r10,QWORD PTR [r8+0x98]
  62a4e6:	49 8b 02             	mov    rax,QWORD PTR [r10]
  62a4e9:	48 83 c0 01          	add    rax,0x1
  62a4ed:	49 89 02             	mov    QWORD PTR [r10],rax
  62a4f0:	89 f0                	mov    eax,esi
  62a4f2:	d1 e0                	shl    eax,1
  62a4f4:	48 89 87 48 02 00 00 	mov    QWORD PTR [rdi+0x248],rax
  62a4fb:	e9 05 00 00 00       	jmp    0x62a505
  62a500:	b8 00 00 00 00       	mov    eax,0x0
  62a505:	85 c0                	test   eax,eax
  62a507:	41 58                	pop    r8
  62a509:	0f 85 14 00 00 00    	jne    0x62a523
  62a50f:	41 c7 40 40 0b cc 15 	mov    DWORD PTR [r8+0x40],0x4015cc0b
  62a516:	40 
  62a517:	41 c7 40 44 02 00 01 	mov    DWORD PTR [r8+0x44],0x10002
  62a51e:	00 
  62a51f:	41 ff 50 38          	call   QWORD PTR [r8+0x38]
  62a523:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  62a527:	49 8b b8 48 02 00 00 	mov    rdi,QWORD PTR [r8+0x248]
  62a52e:	4c 8b bb e0 fe ff ff 	mov    r15,QWORD PTR [rbx-0x120]
  62a535:	48 89 bc 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rdi
  62a53c:	00 
  62a53d:	bf 97 09 00 00       	mov    edi,0x997
  62a542:	48 89 bc 24 60 03 00 	mov    QWORD PTR [rsp+0x360],rdi
  62a549:	00 
  62a54a:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  62a54e:	48 8b 84 24 58 03 00 	mov    rax,QWORD PTR [rsp+0x358]
  62a555:	00 
  62a556:	49 89 40 48          	mov    QWORD PTR [r8+0x48],rax
  62a55a:	8b 84 24 60 03 00 00 	mov    eax,DWORD PTR [rsp+0x360]
  62a561:	49 89 40 50          	mov    QWORD PTR [r8+0x50],rax
  62a565:	41 50                	push   r8
  62a567:	4c 89 c7             	mov    rdi,r8
  62a56a:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  62a571:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  62a575:	41 8b 92 5c 26 00 00 	mov    edx,DWORD PTR [r10+0x265c]
  62a57c:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  62a580:	41 83 b8 a0 00 00 00 	cmp    DWORD PTR [r8+0xa0],0x18
  62a587:	18 
  62a588:	0f 86 80 01 00 00    	jbe    0x62a70e
  62a58e:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  62a595:	4d 85 d2             	test   r10,r10
  62a598:	0f 84 70 01 00 00    	je     0x62a70e
  62a59e:	41 8b 4a 04          	mov    ecx,DWORD PTR [r10+0x4]
  62a5a2:	41 8b 42 08          	mov    eax,DWORD PTR [r10+0x8]
  62a5a6:	81 f8 00 02 00 00    	cmp    eax,0x200
  62a5ac:	0f 87 5c 01 00 00    	ja     0x62a70e
  62a5b2:	39 c1                	cmp    ecx,eax
  62a5b4:	0f 83 54 01 00 00    	jae    0x62a70e
  62a5ba:	49 8d 44 8a 20       	lea    rax,[r10+rcx*4+0x20]
  62a5bf:	8b 30                	mov    esi,DWORD PTR [rax]
  62a5c1:	89 f0                	mov    eax,esi
  62a5c3:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  62a5c7:	48 c1 e0 04          	shl    rax,0x4
  62a5cb:	49 01 c1             	add    r9,rax
  62a5ce:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  62a5d5:	48 85 c0             	test   rax,rax
  62a5d8:	0f 84 30 01 00 00    	je     0x62a70e
  62a5de:	8b 08                	mov    ecx,DWORD PTR [rax]
  62a5e0:	83 c1 07             	add    ecx,0x7
  62a5e3:	83 e1 f8             	and    ecx,0xfffffff8
  62a5e6:	41 8b 40 7c          	mov    eax,DWORD PTR [r8+0x7c]
  62a5ea:	39 c1                	cmp    ecx,eax
  62a5ec:	0f 87 1c 01 00 00    	ja     0x62a70e
  62a5f2:	29 c8                	sub    eax,ecx
  62a5f4:	83 f8 18             	cmp    eax,0x18
  62a5f7:	0f 82 11 01 00 00    	jb     0x62a70e
  62a5fd:	4d 8b 58 28          	mov    r11,QWORD PTR [r8+0x28]
  62a601:	4d 85 db             	test   r11,r11
  62a604:	0f 84 04 01 00 00    	je     0x62a70e
  62a60a:	49 01 cb             	add    r11,rcx
  62a60d:	49 8b 80 98 00 00 00 	mov    rax,QWORD PTR [r8+0x98]
  62a614:	48 85 c0             	test   rax,rax
  62a617:	0f 84 f1 00 00 00    	je     0x62a70e
  62a61d:	8b 47 48             	mov    eax,DWORD PTR [rdi+0x48]
  62a620:	85 c0                	test   eax,eax
  62a622:	0f 84 42 00 00 00    	je     0x62a66a
  62a628:	89 c2                	mov    edx,eax
  62a62a:	83 e2 01             	and    edx,0x1
  62a62d:	85 d2                	test   edx,edx
  62a62f:	0f 85 35 00 00 00    	jne    0x62a66a
  62a635:	d1 e8                	shr    eax,1
  62a637:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  62a63b:	0f 83 cd 00 00 00    	jae    0x62a70e
  62a641:	4d 8b 50 08          	mov    r10,QWORD PTR [r8+0x8]
  62a645:	48 c1 e0 04          	shl    rax,0x4
  62a649:	49 01 c2             	add    r10,rax
  62a64c:	41 8b 42 0c          	mov    eax,DWORD PTR [r10+0xc]
  62a650:	c1 e8 10             	shr    eax,0x10
  62a653:	81 e0 ff 00 00 00    	and    eax,0xff
  62a659:	85 c0                	test   eax,eax
  62a65b:	0f 84 ad 00 00 00    	je     0x62a70e
  62a661:	83 f8 04             	cmp    eax,0x4
  62a664:	0f 87 a4 00 00 00    	ja     0x62a70e
  62a66a:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  62a671:	41 8b 52 04          	mov    edx,DWORD PTR [r10+0x4]
  62a675:	48 8b 83 e8 fe ff ff 	mov    rax,QWORD PTR [rbx-0x118]
  62a67c:	48 8b 40 10          	mov    rax,QWORD PTR [rax+0x10]
  62a680:	8b 80 5c 26 00 00    	mov    eax,DWORD PTR [rax+0x265c]
  62a686:	41 89 03             	mov    DWORD PTR [r11],eax
  62a689:	41 c7 43 04 18 00 00 	mov    DWORD PTR [r11+0x4],0x18
  62a690:	00 
  62a691:	41 c7 43 08 00 00 00 	mov    DWORD PTR [r11+0x8],0x0
  62a698:	00 
  62a699:	41 c7 43 0c 00 00 00 	mov    DWORD PTR [r11+0xc],0x0
  62a6a0:	00 
  62a6a1:	8b 47 48             	mov    eax,DWORD PTR [rdi+0x48]
  62a6a4:	41 89 43 10          	mov    DWORD PTR [r11+0x10],eax
  62a6a8:	41 89 09             	mov    DWORD PTR [r9],ecx
  62a6ab:	41 c7 41 04 18 00 00 	mov    DWORD PTR [r9+0x4],0x18
  62a6b2:	00 
  62a6b3:	41 c7 41 08 00 00 00 	mov    DWORD PTR [r9+0x8],0x0
  62a6ba:	00 
  62a6bb:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  62a6c2:	41 89 ca             	mov    r10d,ecx
  62a6c5:	41 83 c2 18          	add    r10d,0x18
  62a6c9:	44 89 10             	mov    DWORD PTR [rax],r10d
  62a6cc:	41 c7 41 0c 00 00 01 	mov    DWORD PTR [r9+0xc],0x10000
  62a6d3:	00 
  62a6d4:	83 c2 01             	add    edx,0x1
  62a6d7:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  62a6de:	41 89 52 04          	mov    DWORD PTR [r10+0x4],edx
  62a6e2:	41 83 7a 18 00       	cmp    DWORD PTR [r10+0x18],0x0
  62a6e7:	0f 84 11 00 00 00    	je     0x62a6fe
  62a6ed:	4d 8b 90 98 00 00 00 	mov    r10,QWORD PTR [r8+0x98]
  62a6f4:	49 8b 02             	mov    rax,QWORD PTR [r10]
  62a6f7:	48 83 c0 01          	add    rax,0x1
  62a6fb:	49 89 02             	mov    QWORD PTR [r10],rax
  62a6fe:	89 f0                	mov    eax,esi
  62a700:	d1 e0                	shl    eax,1
  62a702:	48 89 87 48 02 00 00 	mov    QWORD PTR [rdi+0x248],rax
  62a709:	e9 05 00 00 00       	jmp    0x62a713
  62a70e:	b8 00 00 00 00       	mov    eax,0x0
  62a713:	85 c0                	test   eax,eax
  62a715:	41 58                	pop    r8
  62a717:	0f 85 14 00 00 00    	jne    0x62a731
  62a71d:	41 c7 40 40 0b cd 15 	mov    DWORD PTR [r8+0x40],0x4015cd0b
  62a724:	40 
  62a725:	41 c7 40 44 02 00 01 	mov    DWORD PTR [r8+0x44],0x10002
  62a72c:	00 
  62a72d:	41 ff 50 38          	call   QWORD PTR [r8+0x38]
  62a731:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  62a735:	49 8b b8 48 02 00 00 	mov    rdi,QWORD PTR [r8+0x248]
  62a73c:	4c 8b bb e0 fe ff ff 	mov    r15,QWORD PTR [rbx-0x120]
  62a743:	48 89 fd             	mov    rbp,rdi
  62a746:	e9 a9 01 00 00       	jmp    0x62a8f4
  62a74b:	bf 95 09 00 00       	mov    edi,0x995
  62a750:	48 89 bc 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rdi
  62a757:	00 
  62a758:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  62a75c:	8b 84 24 58 03 00 00 	mov    eax,DWORD PTR [rsp+0x358]
  62a763:	49 89 40 48          	mov    QWORD PTR [r8+0x48],rax
  62a767:	41 50                	push   r8
  62a769:	4c 89 c7             	mov    rdi,r8
  62a76c:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  62a773:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  62a777:	41 8b 92 54 26 00 00 	mov    edx,DWORD PTR [r10+0x2654]
  62a77e:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  62a782:	41 83 b8 a0 00 00 00 	cmp    DWORD PTR [r8+0xa0],0x10
  62a789:	10 
  62a78a:	0f 86 2c 01 00 00    	jbe    0x62a8bc
  62a790:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  62a797:	4d 85 d2             	test   r10,r10
  62a79a:	0f 84 1c 01 00 00    	je     0x62a8bc
  62a7a0:	41 8b 4a 04          	mov    ecx,DWORD PTR [r10+0x4]
  62a7a4:	41 8b 42 08          	mov    eax,DWORD PTR [r10+0x8]
  62a7a8:	81 f8 00 02 00 00    	cmp    eax,0x200
  62a7ae:	0f 87 08 01 00 00    	ja     0x62a8bc
  62a7b4:	39 c1                	cmp    ecx,eax
  62a7b6:	0f 83 00 01 00 00    	jae    0x62a8bc
  62a7bc:	49 8d 44 8a 20       	lea    rax,[r10+rcx*4+0x20]
  62a7c1:	8b 30                	mov    esi,DWORD PTR [rax]
  62a7c3:	89 f0                	mov    eax,esi
  62a7c5:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  62a7c9:	48 c1 e0 04          	shl    rax,0x4
  62a7cd:	49 01 c1             	add    r9,rax
  62a7d0:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  62a7d7:	48 85 c0             	test   rax,rax
  62a7da:	0f 84 dc 00 00 00    	je     0x62a8bc
  62a7e0:	8b 08                	mov    ecx,DWORD PTR [rax]
  62a7e2:	83 c1 07             	add    ecx,0x7
  62a7e5:	83 e1 f8             	and    ecx,0xfffffff8
  62a7e8:	41 8b 40 7c          	mov    eax,DWORD PTR [r8+0x7c]
  62a7ec:	39 c1                	cmp    ecx,eax
  62a7ee:	0f 87 c8 00 00 00    	ja     0x62a8bc
  62a7f4:	29 c8                	sub    eax,ecx
  62a7f6:	83 f8 10             	cmp    eax,0x10
  62a7f9:	0f 82 bd 00 00 00    	jb     0x62a8bc
  62a7ff:	4d 8b 58 28          	mov    r11,QWORD PTR [r8+0x28]
  62a803:	4d 85 db             	test   r11,r11
  62a806:	0f 84 b0 00 00 00    	je     0x62a8bc
  62a80c:	49 01 cb             	add    r11,rcx
  62a80f:	49 8b 80 98 00 00 00 	mov    rax,QWORD PTR [r8+0x98]
  62a816:	48 85 c0             	test   rax,rax
  62a819:	0f 84 9d 00 00 00    	je     0x62a8bc
  62a81f:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  62a826:	41 8b 52 04          	mov    edx,DWORD PTR [r10+0x4]
  62a82a:	48 8b 83 e8 fe ff ff 	mov    rax,QWORD PTR [rbx-0x118]
  62a831:	48 8b 40 10          	mov    rax,QWORD PTR [rax+0x10]
  62a835:	8b 80 54 26 00 00    	mov    eax,DWORD PTR [rax+0x2654]
  62a83b:	41 89 03             	mov    DWORD PTR [r11],eax
  62a83e:	41 c7 43 04 10 00 00 	mov    DWORD PTR [r11+0x4],0x10
  62a845:	00 
  62a846:	41 c7 43 08 00 00 00 	mov    DWORD PTR [r11+0x8],0x0
  62a84d:	00 
  62a84e:	41 c7 43 0c 01 00 00 	mov    DWORD PTR [r11+0xc],0x1
  62a855:	00 
  62a856:	41 89 09             	mov    DWORD PTR [r9],ecx
  62a859:	41 c7 41 04 10 00 00 	mov    DWORD PTR [r9+0x4],0x10
  62a860:	00 
  62a861:	41 c7 41 08 00 00 00 	mov    DWORD PTR [r9+0x8],0x0
  62a868:	00 
  62a869:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  62a870:	41 89 ca             	mov    r10d,ecx
  62a873:	41 83 c2 10          	add    r10d,0x10
  62a877:	44 89 10             	mov    DWORD PTR [rax],r10d
  62a87a:	41 c7 41 0c 00 00 01 	mov    DWORD PTR [r9+0xc],0x10000
  62a881:	00 
  62a882:	83 c2 01             	add    edx,0x1
  62a885:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  62a88c:	41 89 52 04          	mov    DWORD PTR [r10+0x4],edx
  62a890:	41 83 7a 18 00       	cmp    DWORD PTR [r10+0x18],0x0
  62a895:	0f 84 11 00 00 00    	je     0x62a8ac
  62a89b:	4d 8b 90 98 00 00 00 	mov    r10,QWORD PTR [r8+0x98]
  62a8a2:	49 8b 02             	mov    rax,QWORD PTR [r10]
  62a8a5:	48 83 c0 01          	add    rax,0x1
  62a8a9:	49 89 02             	mov    QWORD PTR [r10],rax
  62a8ac:	89 f0                	mov    eax,esi
  62a8ae:	d1 e0                	shl    eax,1
  62a8b0:	48 89 87 48 02 00 00 	mov    QWORD PTR [rdi+0x248],rax
  62a8b7:	e9 05 00 00 00       	jmp    0x62a8c1
  62a8bc:	b8 00 00 00 00       	mov    eax,0x0
  62a8c1:	85 c0                	test   eax,eax
  62a8c3:	41 58                	pop    r8
  62a8c5:	0f 85 14 00 00 00    	jne    0x62a8df
  62a8cb:	41 c7 40 40 0b ce 15 	mov    DWORD PTR [r8+0x40],0x4015ce0b
  62a8d2:	40 
  62a8d3:	41 c7 40 44 01 00 01 	mov    DWORD PTR [r8+0x44],0x10001
  62a8da:	00 
  62a8db:	41 ff 50 38          	call   QWORD PTR [r8+0x38]
  62a8df:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  62a8e3:	49 8b b8 48 02 00 00 	mov    rdi,QWORD PTR [r8+0x248]
  62a8ea:	4c 8b bb e0 fe ff ff 	mov    r15,QWORD PTR [rbx-0x120]
  62a8f1:	48 89 fd             	mov    rbp,rdi
  62a8f4:	48 89 ac 24 88 00 00 	mov    QWORD PTR [rsp+0x88],rbp
  62a8fb:	00 
  62a8fc:	48 8b bc 24 88 00 00 	mov    rdi,QWORD PTR [rsp+0x88]
  62a903:	00 
  62a904:	48 89 bc 24 38 02 00 	mov    QWORD PTR [rsp+0x238],rdi
  62a90b:	00 
  62a90c:	48 8b bc 24 38 02 00 	mov    rdi,QWORD PTR [rsp+0x238]
  62a913:	00 
  62a914:	48 89 f8             	mov    rax,rdi
  62a917:	ba 97 09 00 00       	mov    edx,0x997
  62a91c:	b9 00 00 00 00       	mov    ecx,0x0
  62a921:	be 14 00 00 00       	mov    esi,0x14
  62a926:	e8 c6 2a 00 00       	call   0x62d3f1
  62a92b:	85 c0                	test   eax,eax
  62a92d:	0f 84 a9 0e 00 00    	je     0x62b7dc
  62a933:	8b 7a 10             	mov    edi,DWORD PTR [rdx+0x10]
  62a936:	48 89 f8             	mov    rax,rdi
  62a939:	ba 47 23 00 00       	mov    edx,0x2347
  62a93e:	b9 18 00 00 00       	mov    ecx,0x18
  62a943:	be 00 00 00 00       	mov    esi,0x0
  62a948:	e8 42 2d 00 00       	call   0x62d68f
  62a94d:	48 8b 44 20 10       	mov    rax,QWORD PTR [rax+riz*1+0x10]
  62a952:	48 89 84 24 90 00 00 	mov    QWORD PTR [rsp+0x90],rax
  62a959:	00 
  62a95a:	48 8b bc 24 90 00 00 	mov    rdi,QWORD PTR [rsp+0x90]
  62a961:	00 
  62a962:	48 89 bc 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rdi
  62a969:	00 
  62a96a:	48 8b 7c 24 30       	mov    rdi,QWORD PTR [rsp+0x30]
  62a96f:	48 89 f8             	mov    rax,rdi
  62a972:	ba 28 0e 00 00       	mov    edx,0xe28
  62a977:	b9 18 00 00 00       	mov    ecx,0x18
  62a97c:	be 00 00 00 00       	mov    esi,0x0
  62a981:	e8 09 2d 00 00       	call   0x62d68f
  62a986:	48 8b 44 20 10       	mov    rax,QWORD PTR [rax+riz*1+0x10]
  62a98b:	48 8b bc 24 58 03 00 	mov    rdi,QWORD PTR [rsp+0x358]
  62a992:	00 
  62a993:	48 89 c1             	mov    rcx,rax
  62a996:	48 89 f8             	mov    rax,rdi
  62a999:	e8 ef 6c 9d ff       	call   0x168d
  62a99e:	48 89 c7             	mov    rdi,rax
  62a9a1:	85 ff                	test   edi,edi
  62a9a3:	0f 84 2e 0e 00 00    	je     0x62b7d7
  62a9a9:	48 8b 7c 24 78       	mov    rdi,QWORD PTR [rsp+0x78]
  62a9ae:	48 89 f8             	mov    rax,rdi
  62a9b1:	ba 2b 0e 00 00       	mov    edx,0xe2b
  62a9b6:	b9 30 00 00 00       	mov    ecx,0x30
  62a9bb:	be 00 00 00 00       	mov    esi,0x0
  62a9c0:	e8 ca 2c 00 00       	call   0x62d68f
  62a9c5:	8b 40 2c             	mov    eax,DWORD PTR [rax+0x2c]
  62a9c8:	ba 3d 0d 00 00       	mov    edx,0xd3d
  62a9cd:	b9 18 00 00 00       	mov    ecx,0x18
  62a9d2:	be 00 00 00 00       	mov    esi,0x0
  62a9d7:	e8 b3 2c 00 00       	call   0x62d68f
  62a9dc:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  62a9e0:	b9 00 00 00 00       	mov    ecx,0x0
  62a9e5:	e8 d2 6a 9d ff       	call   0x14bc
  62a9ea:	48 89 c7             	mov    rdi,rax
  62a9ed:	85 ff                	test   edi,edi
  62a9ef:	0f 84 f3 00 00 00    	je     0x62aae8
  62a9f5:	48 8b 7c 24 08       	mov    rdi,QWORD PTR [rsp+0x8]
  62a9fa:	48 89 f8             	mov    rax,rdi
  62a9fd:	ba 2c 0e 00 00       	mov    edx,0xe2c
  62aa02:	b9 38 00 00 00       	mov    ecx,0x38
  62aa07:	be 00 00 00 00       	mov    esi,0x0
  62aa0c:	e8 7e 2c 00 00       	call   0x62d68f
  62aa11:	8b 40 34             	mov    eax,DWORD PTR [rax+0x34]
  62aa14:	48 89 84 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rax
  62aa1b:	00 
  62aa1c:	48 8b 7c 24 78       	mov    rdi,QWORD PTR [rsp+0x78]
  62aa21:	48 89 f8             	mov    rax,rdi
  62aa24:	ba 2b 0e 00 00       	mov    edx,0xe2b
  62aa29:	b9 30 00 00 00       	mov    ecx,0x30
  62aa2e:	be 00 00 00 00       	mov    esi,0x0
  62aa33:	e8 57 2c 00 00       	call   0x62d68f
  62aa38:	8b 40 2c             	mov    eax,DWORD PTR [rax+0x2c]
  62aa3b:	ba 3d 0d 00 00       	mov    edx,0xd3d
  62aa40:	b9 14 00 00 00       	mov    ecx,0x14
  62aa45:	be 00 00 00 00       	mov    esi,0x0
  62aa4a:	e8 40 2c 00 00       	call   0x62d68f
  62aa4f:	8b 44 20 10          	mov    eax,DWORD PTR [rax+riz*1+0x10]
  62aa53:	89 84 24 28 03 00 00 	mov    DWORD PTR [rsp+0x328],eax
  62aa5a:	48 8b bc 24 58 03 00 	mov    rdi,QWORD PTR [rsp+0x358]
  62aa61:	00 
  62aa62:	48 89 bc 24 20 03 00 	mov    QWORD PTR [rsp+0x320],rdi
  62aa69:	00 
  62aa6a:	8b bc 24 28 03 00 00 	mov    edi,DWORD PTR [rsp+0x328]
  62aa71:	48 89 bc 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rdi
  62aa78:	00 
  62aa79:	48 8b bc 24 20 03 00 	mov    rdi,QWORD PTR [rsp+0x320]
  62aa80:	00 
  62aa81:	48 89 f8             	mov    rax,rdi
  62aa84:	ba a0 09 00 00       	mov    edx,0x9a0
  62aa89:	b9 18 00 00 00       	mov    ecx,0x18
  62aa8e:	be 00 00 00 00       	mov    esi,0x0
  62aa93:	e8 f7 2b 00 00       	call   0x62d68f
  62aa98:	48 89 c5             	mov    rbp,rax
  62aa9b:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  62aa9f:	8b bc 24 58 03 00 00 	mov    edi,DWORD PTR [rsp+0x358]
  62aaa6:	39 c7                	cmp    edi,eax
  62aaa8:	0f 82 05 00 00 00    	jb     0x62aab3
  62aaae:	e9 df 2c 00 00       	jmp    0x62d792
  62aab3:	8b 7d 10             	mov    edi,DWORD PTR [rbp+0x10]
  62aab6:	48 89 f8             	mov    rax,rdi
  62aab9:	8b bc 24 28 03 00 00 	mov    edi,DWORD PTR [rsp+0x328]
  62aac0:	89 f9                	mov    ecx,edi
  62aac2:	ba 3a 23 00 00       	mov    edx,0x233a
  62aac7:	be 00 00 00 00       	mov    esi,0x0
  62aacc:	e8 d4 26 00 00       	call   0x62d1a5
  62aad1:	8b 04 20             	mov    eax,DWORD PTR [rax+riz*1]
  62aad4:	48 89 84 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rax
  62aadb:	00 
  62aadc:	8b ac 24 58 03 00 00 	mov    ebp,DWORD PTR [rsp+0x358]
  62aae3:	e9 05 00 00 00       	jmp    0x62aaed
  62aae8:	bd 00 00 00 00       	mov    ebp,0x0
  62aaed:	89 ac 24 98 00 00 00 	mov    DWORD PTR [rsp+0x98],ebp
  62aaf4:	48 8b 7c 24 10       	mov    rdi,QWORD PTR [rsp+0x10]
  62aaf9:	48 89 f8             	mov    rax,rdi
  62aafc:	ba 1a 0e 00 00       	mov    edx,0xe1a
  62ab01:	b9 20 00 00 00       	mov    ecx,0x20
  62ab06:	be 00 00 00 00       	mov    esi,0x0
  62ab0b:	e8 7f 2b 00 00       	call   0x62d68f
  62ab10:	8b 40 1c             	mov    eax,DWORD PTR [rax+0x1c]
  62ab13:	48 89 84 24 f0 02 00 	mov    QWORD PTR [rsp+0x2f0],rax
  62ab1a:	00 
  62ab1b:	48 8b bc 24 f0 02 00 	mov    rdi,QWORD PTR [rsp+0x2f0]
  62ab22:	00 
  62ab23:	48 89 f8             	mov    rax,rdi
  62ab26:	ba a0 09 00 00       	mov    edx,0x9a0
  62ab2b:	b9 18 00 00 00       	mov    ecx,0x18
  62ab30:	be 00 00 00 00       	mov    esi,0x0
  62ab35:	e8 55 2b 00 00       	call   0x62d68f
  62ab3a:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  62ab3e:	48 89 84 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rax
  62ab45:	00 
  62ab46:	8b bc 24 58 03 00 00 	mov    edi,DWORD PTR [rsp+0x358]
  62ab4d:	89 bc 24 a0 00 00 00 	mov    DWORD PTR [rsp+0xa0],edi
  62ab54:	48 8b 7c 24 10       	mov    rdi,QWORD PTR [rsp+0x10]
  62ab59:	48 89 f8             	mov    rax,rdi
  62ab5c:	ba 1a 0e 00 00       	mov    edx,0xe1a
  62ab61:	b9 20 00 00 00       	mov    ecx,0x20
  62ab66:	be 00 00 00 00       	mov    esi,0x0
  62ab6b:	e8 1f 2b 00 00       	call   0x62d68f
  62ab70:	8b 40 1c             	mov    eax,DWORD PTR [rax+0x1c]
  62ab73:	48 89 84 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rax
  62ab7a:	00 
  62ab7b:	48 8b 7c 24 78       	mov    rdi,QWORD PTR [rsp+0x78]
  62ab80:	48 89 f8             	mov    rax,rdi
  62ab83:	ba 2b 0e 00 00       	mov    edx,0xe2b
  62ab88:	b9 18 00 00 00       	mov    ecx,0x18
  62ab8d:	be 00 00 00 00       	mov    esi,0x0
  62ab92:	e8 f8 2a 00 00       	call   0x62d68f
  62ab97:	48 8b 44 20 10       	mov    rax,QWORD PTR [rax+riz*1+0x10]
  62ab9c:	48 89 84 24 b8 01 00 	mov    QWORD PTR [rsp+0x1b8],rax
  62aba3:	00 
  62aba4:	48 8b 7c 24 50       	mov    rdi,QWORD PTR [rsp+0x50]
  62aba9:	48 89 bc 24 b0 01 00 	mov    QWORD PTR [rsp+0x1b0],rdi
  62abb0:	00 
  62abb1:	48 8b bc 24 b0 01 00 	mov    rdi,QWORD PTR [rsp+0x1b0]
  62abb8:	00 
  62abb9:	48 89 f8             	mov    rax,rdi
  62abbc:	ba fa 0d 00 00       	mov    edx,0xdfa
  62abc1:	b9 00 00 00 00       	mov    ecx,0x0
  62abc6:	be 18 00 00 00       	mov    esi,0x18
  62abcb:	e8 21 28 00 00       	call   0x62d3f1
  62abd0:	48 89 84 24 60 03 00 	mov    QWORD PTR [rsp+0x360],rax
  62abd7:	00 
  62abd8:	8b bc 24 60 03 00 00 	mov    edi,DWORD PTR [rsp+0x360]
  62abdf:	85 ff                	test   edi,edi
  62abe1:	0f 84 72 00 00 00    	je     0x62ac59
  62abe7:	48 8b 7c 22 10       	mov    rdi,QWORD PTR [rdx+riz*1+0x10]
  62abec:	48 89 bc 24 a8 00 00 	mov    QWORD PTR [rsp+0xa8],rdi
  62abf3:	00 
  62abf4:	48 8b 7c 24 08       	mov    rdi,QWORD PTR [rsp+0x8]
  62abf9:	48 89 bc 24 60 03 00 	mov    QWORD PTR [rsp+0x360],rdi
  62ac00:	00 
  62ac01:	48 8b bc 24 a8 00 00 	mov    rdi,QWORD PTR [rsp+0xa8]
  62ac08:	00 
  62ac09:	48 89 bc 24 68 03 00 	mov    QWORD PTR [rsp+0x368],rdi
  62ac10:	00 
  62ac11:	48 8b 7c 24 78       	mov    rdi,QWORD PTR [rsp+0x78]
  62ac16:	48 89 f8             	mov    rax,rdi
  62ac19:	ba 2b 0e 00 00       	mov    edx,0xe2b
  62ac1e:	b9 1c 00 00 00       	mov    ecx,0x1c
  62ac23:	be 00 00 00 00       	mov    esi,0x0
  62ac28:	e8 62 2a 00 00       	call   0x62d68f
  62ac2d:	8b 40 18             	mov    eax,DWORD PTR [rax+0x18]
  62ac30:	48 8b bc 24 60 03 00 	mov    rdi,QWORD PTR [rsp+0x360]
  62ac37:	00 
  62ac38:	48 8b b4 24 68 03 00 	mov    rsi,QWORD PTR [rsp+0x368]
  62ac3f:	00 
  62ac40:	48 89 f1             	mov    rcx,rsi
  62ac43:	48 89 c2             	mov    rdx,rax
  62ac46:	48 89 f8             	mov    rax,rdi
  62ac49:	e8 92 d2 ff ff       	call   0x627ee0
  62ac4e:	48 89 c7             	mov    rdi,rax
  62ac51:	48 89 fd             	mov    rbp,rdi
  62ac54:	e9 e4 01 00 00       	jmp    0x62ae3d
  62ac59:	48 8b bc 24 b0 01 00 	mov    rdi,QWORD PTR [rsp+0x1b0]
  62ac60:	00 
  62ac61:	48 89 f8             	mov    rax,rdi
  62ac64:	ba f8 0d 00 00       	mov    edx,0xdf8
  62ac69:	b9 00 00 00 00       	mov    ecx,0x0
  62ac6e:	e8 e4 28 00 00       	call   0x62d557
  62ac73:	48 89 84 24 60 03 00 	mov    QWORD PTR [rsp+0x360],rax
  62ac7a:	00 
  62ac7b:	8b bc 24 60 03 00 00 	mov    edi,DWORD PTR [rsp+0x360]
  62ac82:	85 ff                	test   edi,edi
  62ac84:	0f 84 ae 01 00 00    	je     0x62ae38
  62ac8a:	bf 95 09 00 00       	mov    edi,0x995
  62ac8f:	48 89 bc 24 60 03 00 	mov    QWORD PTR [rsp+0x360],rdi
  62ac96:	00 
  62ac97:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  62ac9b:	8b 84 24 60 03 00 00 	mov    eax,DWORD PTR [rsp+0x360]
  62aca2:	49 89 40 48          	mov    QWORD PTR [r8+0x48],rax
  62aca6:	41 50                	push   r8
  62aca8:	4c 89 c7             	mov    rdi,r8
  62acab:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  62acb2:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  62acb6:	41 8b 92 54 26 00 00 	mov    edx,DWORD PTR [r10+0x2654]
  62acbd:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  62acc1:	41 83 b8 a0 00 00 00 	cmp    DWORD PTR [r8+0xa0],0x10
  62acc8:	10 
  62acc9:	0f 86 2c 01 00 00    	jbe    0x62adfb
  62accf:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  62acd6:	4d 85 d2             	test   r10,r10
  62acd9:	0f 84 1c 01 00 00    	je     0x62adfb
  62acdf:	41 8b 4a 04          	mov    ecx,DWORD PTR [r10+0x4]
  62ace3:	41 8b 42 08          	mov    eax,DWORD PTR [r10+0x8]
  62ace7:	81 f8 00 02 00 00    	cmp    eax,0x200
  62aced:	0f 87 08 01 00 00    	ja     0x62adfb
  62acf3:	39 c1                	cmp    ecx,eax
  62acf5:	0f 83 00 01 00 00    	jae    0x62adfb
  62acfb:	49 8d 44 8a 20       	lea    rax,[r10+rcx*4+0x20]
  62ad00:	8b 30                	mov    esi,DWORD PTR [rax]
  62ad02:	89 f0                	mov    eax,esi
  62ad04:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  62ad08:	48 c1 e0 04          	shl    rax,0x4
  62ad0c:	49 01 c1             	add    r9,rax
  62ad0f:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  62ad16:	48 85 c0             	test   rax,rax
  62ad19:	0f 84 dc 00 00 00    	je     0x62adfb
  62ad1f:	8b 08                	mov    ecx,DWORD PTR [rax]
  62ad21:	83 c1 07             	add    ecx,0x7
  62ad24:	83 e1 f8             	and    ecx,0xfffffff8
  62ad27:	41 8b 40 7c          	mov    eax,DWORD PTR [r8+0x7c]
  62ad2b:	39 c1                	cmp    ecx,eax
  62ad2d:	0f 87 c8 00 00 00    	ja     0x62adfb
  62ad33:	29 c8                	sub    eax,ecx
  62ad35:	83 f8 10             	cmp    eax,0x10
  62ad38:	0f 82 bd 00 00 00    	jb     0x62adfb
  62ad3e:	4d 8b 58 28          	mov    r11,QWORD PTR [r8+0x28]
  62ad42:	4d 85 db             	test   r11,r11
  62ad45:	0f 84 b0 00 00 00    	je     0x62adfb
  62ad4b:	49 01 cb             	add    r11,rcx
  62ad4e:	49 8b 80 98 00 00 00 	mov    rax,QWORD PTR [r8+0x98]
  62ad55:	48 85 c0             	test   rax,rax
  62ad58:	0f 84 9d 00 00 00    	je     0x62adfb
  62ad5e:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  62ad65:	41 8b 52 04          	mov    edx,DWORD PTR [r10+0x4]
  62ad69:	48 8b 83 e8 fe ff ff 	mov    rax,QWORD PTR [rbx-0x118]
  62ad70:	48 8b 40 10          	mov    rax,QWORD PTR [rax+0x10]
  62ad74:	8b 80 54 26 00 00    	mov    eax,DWORD PTR [rax+0x2654]
  62ad7a:	41 89 03             	mov    DWORD PTR [r11],eax
  62ad7d:	41 c7 43 04 10 00 00 	mov    DWORD PTR [r11+0x4],0x10
  62ad84:	00 
  62ad85:	41 c7 43 08 00 00 00 	mov    DWORD PTR [r11+0x8],0x0
  62ad8c:	00 
  62ad8d:	41 c7 43 0c 01 00 00 	mov    DWORD PTR [r11+0xc],0x1
  62ad94:	00 
  62ad95:	41 89 09             	mov    DWORD PTR [r9],ecx
  62ad98:	41 c7 41 04 10 00 00 	mov    DWORD PTR [r9+0x4],0x10
  62ad9f:	00 
  62ada0:	41 c7 41 08 00 00 00 	mov    DWORD PTR [r9+0x8],0x0
  62ada7:	00 
  62ada8:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  62adaf:	41 89 ca             	mov    r10d,ecx
  62adb2:	41 83 c2 10          	add    r10d,0x10
  62adb6:	44 89 10             	mov    DWORD PTR [rax],r10d
  62adb9:	41 c7 41 0c 00 00 01 	mov    DWORD PTR [r9+0xc],0x10000
  62adc0:	00 
  62adc1:	83 c2 01             	add    edx,0x1
  62adc4:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  62adcb:	41 89 52 04          	mov    DWORD PTR [r10+0x4],edx
  62adcf:	41 83 7a 18 00       	cmp    DWORD PTR [r10+0x18],0x0
  62add4:	0f 84 11 00 00 00    	je     0x62adeb
  62adda:	4d 8b 90 98 00 00 00 	mov    r10,QWORD PTR [r8+0x98]
  62ade1:	49 8b 02             	mov    rax,QWORD PTR [r10]
  62ade4:	48 83 c0 01          	add    rax,0x1
  62ade8:	49 89 02             	mov    QWORD PTR [r10],rax
  62adeb:	89 f0                	mov    eax,esi
  62aded:	d1 e0                	shl    eax,1
  62adef:	48 89 87 48 02 00 00 	mov    QWORD PTR [rdi+0x248],rax
  62adf6:	e9 05 00 00 00       	jmp    0x62ae00
  62adfb:	b8 00 00 00 00       	mov    eax,0x0
  62ae00:	85 c0                	test   eax,eax
  62ae02:	41 58                	pop    r8
  62ae04:	0f 85 14 00 00 00    	jne    0x62ae1e
  62ae0a:	41 c7 40 40 0b cf 15 	mov    DWORD PTR [r8+0x40],0x4015cf0b
  62ae11:	40 
  62ae12:	41 c7 40 44 01 00 01 	mov    DWORD PTR [r8+0x44],0x10001
  62ae19:	00 
  62ae1a:	41 ff 50 38          	call   QWORD PTR [r8+0x38]
  62ae1e:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  62ae22:	49 8b b8 48 02 00 00 	mov    rdi,QWORD PTR [r8+0x248]
  62ae29:	4c 8b bb e0 fe ff ff 	mov    r15,QWORD PTR [rbx-0x120]
  62ae30:	48 89 fd             	mov    rbp,rdi
  62ae33:	e9 05 00 00 00       	jmp    0x62ae3d
  62ae38:	e9 82 29 00 00       	jmp    0x62d7bf
  62ae3d:	48 89 ac 24 c0 01 00 	mov    QWORD PTR [rsp+0x1c0],rbp
  62ae44:	00 
  62ae45:	8b bc 24 98 00 00 00 	mov    edi,DWORD PTR [rsp+0x98]
  62ae4c:	89 bc 24 c8 01 00 00 	mov    DWORD PTR [rsp+0x1c8],edi
  62ae53:	48 8b bc 24 b8 01 00 	mov    rdi,QWORD PTR [rsp+0x1b8]
  62ae5a:	00 
  62ae5b:	48 89 bc 24 60 03 00 	mov    QWORD PTR [rsp+0x360],rdi
  62ae62:	00 
  62ae63:	48 8b bc 24 c0 01 00 	mov    rdi,QWORD PTR [rsp+0x1c0]
  62ae6a:	00 
  62ae6b:	48 89 bc 24 68 03 00 	mov    QWORD PTR [rsp+0x368],rdi
  62ae72:	00 
  62ae73:	8b bc 24 c8 01 00 00 	mov    edi,DWORD PTR [rsp+0x1c8]
  62ae7a:	48 89 bc 24 70 03 00 	mov    QWORD PTR [rsp+0x370],rdi
  62ae81:	00 
  62ae82:	bf fb 0d 00 00       	mov    edi,0xdfb
  62ae87:	48 89 bc 24 78 03 00 	mov    QWORD PTR [rsp+0x378],rdi
  62ae8e:	00 
  62ae8f:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  62ae93:	48 8b 84 24 60 03 00 	mov    rax,QWORD PTR [rsp+0x360]
  62ae9a:	00 
  62ae9b:	49 89 40 48          	mov    QWORD PTR [r8+0x48],rax
  62ae9f:	48 8b 84 24 68 03 00 	mov    rax,QWORD PTR [rsp+0x368]
  62aea6:	00 
  62aea7:	49 89 40 50          	mov    QWORD PTR [r8+0x50],rax
  62aeab:	8b 84 24 70 03 00 00 	mov    eax,DWORD PTR [rsp+0x370]
  62aeb2:	49 89 40 58          	mov    QWORD PTR [r8+0x58],rax
  62aeb6:	8b 84 24 78 03 00 00 	mov    eax,DWORD PTR [rsp+0x378]
  62aebd:	49 89 40 60          	mov    QWORD PTR [r8+0x60],rax
  62aec1:	41 50                	push   r8
  62aec3:	4c 89 c7             	mov    rdi,r8
  62aec6:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  62aecd:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  62aed1:	41 8b 92 ec 37 00 00 	mov    edx,DWORD PTR [r10+0x37ec]
  62aed8:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  62aedc:	41 83 b8 a0 00 00 00 	cmp    DWORD PTR [r8+0xa0],0x20
  62aee3:	20 
  62aee4:	0f 86 8f 01 00 00    	jbe    0x62b079
  62aeea:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  62aef1:	4d 85 d2             	test   r10,r10
  62aef4:	0f 84 7f 01 00 00    	je     0x62b079
  62aefa:	41 8b 4a 04          	mov    ecx,DWORD PTR [r10+0x4]
  62aefe:	41 8b 42 08          	mov    eax,DWORD PTR [r10+0x8]
  62af02:	81 f8 00 02 00 00    	cmp    eax,0x200
  62af08:	0f 87 6b 01 00 00    	ja     0x62b079
  62af0e:	39 c1                	cmp    ecx,eax
  62af10:	0f 83 63 01 00 00    	jae    0x62b079
  62af16:	49 8d 44 8a 20       	lea    rax,[r10+rcx*4+0x20]
  62af1b:	8b 30                	mov    esi,DWORD PTR [rax]
  62af1d:	89 f0                	mov    eax,esi
  62af1f:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  62af23:	48 c1 e0 04          	shl    rax,0x4
  62af27:	49 01 c1             	add    r9,rax
  62af2a:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  62af31:	48 85 c0             	test   rax,rax
  62af34:	0f 84 3f 01 00 00    	je     0x62b079
  62af3a:	8b 08                	mov    ecx,DWORD PTR [rax]
  62af3c:	83 c1 07             	add    ecx,0x7
  62af3f:	83 e1 f8             	and    ecx,0xfffffff8
  62af42:	41 8b 40 7c          	mov    eax,DWORD PTR [r8+0x7c]
  62af46:	39 c1                	cmp    ecx,eax
  62af48:	0f 87 2b 01 00 00    	ja     0x62b079
  62af4e:	29 c8                	sub    eax,ecx
  62af50:	83 f8 20             	cmp    eax,0x20
  62af53:	0f 82 20 01 00 00    	jb     0x62b079
  62af59:	4d 8b 58 28          	mov    r11,QWORD PTR [r8+0x28]
  62af5d:	4d 85 db             	test   r11,r11
  62af60:	0f 84 13 01 00 00    	je     0x62b079
  62af66:	49 01 cb             	add    r11,rcx
  62af69:	49 8b 80 98 00 00 00 	mov    rax,QWORD PTR [r8+0x98]
  62af70:	48 85 c0             	test   rax,rax
  62af73:	0f 84 00 01 00 00    	je     0x62b079
  62af79:	8b 47 50             	mov    eax,DWORD PTR [rdi+0x50]
  62af7c:	85 c0                	test   eax,eax
  62af7e:	0f 84 42 00 00 00    	je     0x62afc6
  62af84:	89 c2                	mov    edx,eax
  62af86:	83 e2 01             	and    edx,0x1
  62af89:	85 d2                	test   edx,edx
  62af8b:	0f 85 35 00 00 00    	jne    0x62afc6
  62af91:	d1 e8                	shr    eax,1
  62af93:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  62af97:	0f 83 dc 00 00 00    	jae    0x62b079
  62af9d:	4d 8b 50 08          	mov    r10,QWORD PTR [r8+0x8]
  62afa1:	48 c1 e0 04          	shl    rax,0x4
  62afa5:	49 01 c2             	add    r10,rax
  62afa8:	41 8b 42 0c          	mov    eax,DWORD PTR [r10+0xc]
  62afac:	c1 e8 10             	shr    eax,0x10
  62afaf:	81 e0 ff 00 00 00    	and    eax,0xff
  62afb5:	85 c0                	test   eax,eax
  62afb7:	0f 84 bc 00 00 00    	je     0x62b079
  62afbd:	83 f8 04             	cmp    eax,0x4
  62afc0:	0f 87 b3 00 00 00    	ja     0x62b079
  62afc6:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  62afcd:	41 8b 52 04          	mov    edx,DWORD PTR [r10+0x4]
  62afd1:	48 8b 83 e8 fe ff ff 	mov    rax,QWORD PTR [rbx-0x118]
  62afd8:	48 8b 40 10          	mov    rax,QWORD PTR [rax+0x10]
  62afdc:	8b 80 ec 37 00 00    	mov    eax,DWORD PTR [rax+0x37ec]
  62afe2:	41 89 03             	mov    DWORD PTR [r11],eax
  62afe5:	41 c7 43 04 20 00 00 	mov    DWORD PTR [r11+0x4],0x20
  62afec:	00 
  62afed:	41 c7 43 08 00 00 00 	mov    DWORD PTR [r11+0x8],0x0
  62aff4:	00 
  62aff5:	41 c7 43 0c 00 00 00 	mov    DWORD PTR [r11+0xc],0x0
  62affc:	00 
  62affd:	48 8b 47 48          	mov    rax,QWORD PTR [rdi+0x48]
  62b001:	49 89 43 10          	mov    QWORD PTR [r11+0x10],rax
  62b005:	8b 47 50             	mov    eax,DWORD PTR [rdi+0x50]
  62b008:	41 89 43 18          	mov    DWORD PTR [r11+0x18],eax
  62b00c:	8b 47 58             	mov    eax,DWORD PTR [rdi+0x58]
  62b00f:	41 89 43 1c          	mov    DWORD PTR [r11+0x1c],eax
  62b013:	41 89 09             	mov    DWORD PTR [r9],ecx
  62b016:	41 c7 41 04 20 00 00 	mov    DWORD PTR [r9+0x4],0x20
  62b01d:	00 
  62b01e:	41 c7 41 08 00 00 00 	mov    DWORD PTR [r9+0x8],0x0
  62b025:	00 
  62b026:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  62b02d:	41 89 ca             	mov    r10d,ecx
  62b030:	41 83 c2 20          	add    r10d,0x20
  62b034:	44 89 10             	mov    DWORD PTR [rax],r10d
  62b037:	41 c7 41 0c 00 00 01 	mov    DWORD PTR [r9+0xc],0x10000
  62b03e:	00 
  62b03f:	83 c2 01             	add    edx,0x1
  62b042:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  62b049:	41 89 52 04          	mov    DWORD PTR [r10+0x4],edx
  62b04d:	41 83 7a 18 00       	cmp    DWORD PTR [r10+0x18],0x0
  62b052:	0f 84 11 00 00 00    	je     0x62b069
  62b058:	4d 8b 90 98 00 00 00 	mov    r10,QWORD PTR [r8+0x98]
  62b05f:	49 8b 02             	mov    rax,QWORD PTR [r10]
  62b062:	48 83 c0 01          	add    rax,0x1
  62b066:	49 89 02             	mov    QWORD PTR [r10],rax
  62b069:	89 f0                	mov    eax,esi
  62b06b:	d1 e0                	shl    eax,1
  62b06d:	48 89 87 48 02 00 00 	mov    QWORD PTR [rdi+0x248],rax
  62b074:	e9 05 00 00 00       	jmp    0x62b07e
  62b079:	b8 00 00 00 00       	mov    eax,0x0
  62b07e:	85 c0                	test   eax,eax
  62b080:	41 58                	pop    r8
  62b082:	0f 85 14 00 00 00    	jne    0x62b09c
  62b088:	41 c7 40 40 0b d0 15 	mov    DWORD PTR [r8+0x40],0x4015d00b
  62b08f:	40 
  62b090:	41 c7 40 44 04 00 01 	mov    DWORD PTR [r8+0x44],0x10004
  62b097:	00 
  62b098:	41 ff 50 38          	call   QWORD PTR [r8+0x38]
  62b09c:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  62b0a0:	49 8b b8 48 02 00 00 	mov    rdi,QWORD PTR [r8+0x248]
  62b0a7:	4c 8b bb e0 fe ff ff 	mov    r15,QWORD PTR [rbx-0x120]
  62b0ae:	48 8b b4 24 58 03 00 	mov    rsi,QWORD PTR [rsp+0x358]
  62b0b5:	00 
  62b0b6:	48 89 f0             	mov    rax,rsi
  62b0b9:	48 89 f9             	mov    rcx,rdi
  62b0bc:	e8 3f bc 9d ff       	call   0x6d00
  62b0c1:	48 8b 3c 24          	mov    rdi,QWORD PTR [rsp]
  62b0c5:	48 89 bc 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rdi
  62b0cc:	00 
  62b0cd:	48 8b 7c 24 78       	mov    rdi,QWORD PTR [rsp+0x78]
  62b0d2:	48 89 f8             	mov    rax,rdi
  62b0d5:	ba 2b 0e 00 00       	mov    edx,0xe2b
  62b0da:	b9 1c 00 00 00       	mov    ecx,0x1c
  62b0df:	be 00 00 00 00       	mov    esi,0x0
  62b0e4:	e8 a6 25 00 00       	call   0x62d68f
  62b0e9:	8b 40 18             	mov    eax,DWORD PTR [rax+0x18]
  62b0ec:	48 8b bc 24 58 03 00 	mov    rdi,QWORD PTR [rsp+0x358]
  62b0f3:	00 
  62b0f4:	48 89 c1             	mov    rcx,rax
  62b0f7:	48 89 f8             	mov    rax,rdi
  62b0fa:	e8 81 c7 ff ff       	call   0x627880
  62b0ff:	48 89 c7             	mov    rdi,rax
  62b102:	89 bc 24 b0 00 00 00 	mov    DWORD PTR [rsp+0xb0],edi
  62b109:	48 8b 7c 24 50       	mov    rdi,QWORD PTR [rsp+0x50]
  62b10e:	48 89 bc 24 d0 01 00 	mov    QWORD PTR [rsp+0x1d0],rdi
  62b115:	00 
  62b116:	48 8b bc 24 d0 01 00 	mov    rdi,QWORD PTR [rsp+0x1d0]
  62b11d:	00 
  62b11e:	48 89 f8             	mov    rax,rdi
  62b121:	ba f8 0d 00 00       	mov    edx,0xdf8
  62b126:	b9 00 00 00 00       	mov    ecx,0x0
  62b12b:	e8 27 24 00 00       	call   0x62d557
  62b130:	85 c0                	test   eax,eax
  62b132:	0f 84 0a 00 00 00    	je     0x62b142
  62b138:	bd 01 00 00 00       	mov    ebp,0x1
  62b13d:	e9 05 00 00 00       	jmp    0x62b147
  62b142:	bd 00 00 00 00       	mov    ebp,0x0
  62b147:	89 ac 24 b8 00 00 00 	mov    DWORD PTR [rsp+0xb8],ebp
  62b14e:	48 8b 7c 24 10       	mov    rdi,QWORD PTR [rsp+0x10]
  62b153:	48 89 f8             	mov    rax,rdi
  62b156:	ba 1a 0e 00 00       	mov    edx,0xe1a
  62b15b:	b9 24 00 00 00       	mov    ecx,0x24
  62b160:	be 00 00 00 00       	mov    esi,0x0
  62b165:	e8 25 25 00 00       	call   0x62d68f
  62b16a:	8b 40 20             	mov    eax,DWORD PTR [rax+0x20]
  62b16d:	48 8b 7c 24 38       	mov    rdi,QWORD PTR [rsp+0x38]
  62b172:	48 89 bc 24 d8 01 00 	mov    QWORD PTR [rsp+0x1d8],rdi
  62b179:	00 
  62b17a:	8b bc 24 b0 00 00 00 	mov    edi,DWORD PTR [rsp+0xb0]
  62b181:	89 bc 24 e0 01 00 00 	mov    DWORD PTR [rsp+0x1e0],edi
  62b188:	8b bc 24 b8 00 00 00 	mov    edi,DWORD PTR [rsp+0xb8]
  62b18f:	89 bc 24 e8 01 00 00 	mov    DWORD PTR [rsp+0x1e8],edi
  62b196:	8b bc 24 98 00 00 00 	mov    edi,DWORD PTR [rsp+0x98]
  62b19d:	89 bc 24 f0 01 00 00 	mov    DWORD PTR [rsp+0x1f0],edi
  62b1a4:	8b 7c 24 60          	mov    edi,DWORD PTR [rsp+0x60]
  62b1a8:	89 bc 24 f8 01 00 00 	mov    DWORD PTR [rsp+0x1f8],edi
  62b1af:	8b bc 24 a0 00 00 00 	mov    edi,DWORD PTR [rsp+0xa0]
  62b1b6:	89 bc 24 00 02 00 00 	mov    DWORD PTR [rsp+0x200],edi
  62b1bd:	48 89 84 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rax
  62b1c4:	00 
  62b1c5:	48 8b bc 24 d8 01 00 	mov    rdi,QWORD PTR [rsp+0x1d8]
  62b1cc:	00 
  62b1cd:	48 89 bc 24 60 03 00 	mov    QWORD PTR [rsp+0x360],rdi
  62b1d4:	00 
  62b1d5:	8b bc 24 e0 01 00 00 	mov    edi,DWORD PTR [rsp+0x1e0]
  62b1dc:	48 89 bc 24 68 03 00 	mov    QWORD PTR [rsp+0x368],rdi
  62b1e3:	00 
  62b1e4:	8b bc 24 e8 01 00 00 	mov    edi,DWORD PTR [rsp+0x1e8]
  62b1eb:	48 89 bc 24 70 03 00 	mov    QWORD PTR [rsp+0x370],rdi
  62b1f2:	00 
  62b1f3:	8b bc 24 f0 01 00 00 	mov    edi,DWORD PTR [rsp+0x1f0]
  62b1fa:	48 89 bc 24 78 03 00 	mov    QWORD PTR [rsp+0x378],rdi
  62b201:	00 
  62b202:	8b bc 24 f8 01 00 00 	mov    edi,DWORD PTR [rsp+0x1f8]
  62b209:	48 89 bc 24 80 03 00 	mov    QWORD PTR [rsp+0x380],rdi
  62b210:	00 
  62b211:	8b bc 24 00 02 00 00 	mov    edi,DWORD PTR [rsp+0x200]
  62b218:	48 89 bc 24 88 03 00 	mov    QWORD PTR [rsp+0x388],rdi
  62b21f:	00 
  62b220:	bf fc 0d 00 00       	mov    edi,0xdfc
  62b225:	48 89 bc 24 90 03 00 	mov    QWORD PTR [rsp+0x390],rdi
  62b22c:	00 
  62b22d:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  62b231:	48 8b 84 24 60 03 00 	mov    rax,QWORD PTR [rsp+0x360]
  62b238:	00 
  62b239:	49 89 40 48          	mov    QWORD PTR [r8+0x48],rax
  62b23d:	8b 84 24 68 03 00 00 	mov    eax,DWORD PTR [rsp+0x368]
  62b244:	49 89 40 50          	mov    QWORD PTR [r8+0x50],rax
  62b248:	8b 84 24 70 03 00 00 	mov    eax,DWORD PTR [rsp+0x370]
  62b24f:	49 89 40 58          	mov    QWORD PTR [r8+0x58],rax
  62b253:	8b 84 24 78 03 00 00 	mov    eax,DWORD PTR [rsp+0x378]
  62b25a:	49 89 40 60          	mov    QWORD PTR [r8+0x60],rax
  62b25e:	8b 84 24 80 03 00 00 	mov    eax,DWORD PTR [rsp+0x380]
  62b265:	49 89 40 68          	mov    QWORD PTR [r8+0x68],rax
  62b269:	8b 84 24 88 03 00 00 	mov    eax,DWORD PTR [rsp+0x388]
  62b270:	49 89 40 70          	mov    QWORD PTR [r8+0x70],rax
  62b274:	8b 84 24 90 03 00 00 	mov    eax,DWORD PTR [rsp+0x390]
  62b27b:	49 89 40 78          	mov    QWORD PTR [r8+0x78],rax
  62b27f:	41 50                	push   r8
  62b281:	4c 89 c7             	mov    rdi,r8
  62b284:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  62b28b:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  62b28f:	41 8b 92 f0 37 00 00 	mov    edx,DWORD PTR [r10+0x37f0]
  62b296:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  62b29a:	41 83 b8 a0 00 00 00 	cmp    DWORD PTR [r8+0xa0],0x28
  62b2a1:	28 
  62b2a2:	0f 86 a3 01 00 00    	jbe    0x62b44b
  62b2a8:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  62b2af:	4d 85 d2             	test   r10,r10
  62b2b2:	0f 84 93 01 00 00    	je     0x62b44b
  62b2b8:	41 8b 4a 04          	mov    ecx,DWORD PTR [r10+0x4]
  62b2bc:	41 8b 42 08          	mov    eax,DWORD PTR [r10+0x8]
  62b2c0:	81 f8 00 02 00 00    	cmp    eax,0x200
  62b2c6:	0f 87 7f 01 00 00    	ja     0x62b44b
  62b2cc:	39 c1                	cmp    ecx,eax
  62b2ce:	0f 83 77 01 00 00    	jae    0x62b44b
  62b2d4:	49 8d 44 8a 20       	lea    rax,[r10+rcx*4+0x20]
  62b2d9:	8b 30                	mov    esi,DWORD PTR [rax]
  62b2db:	89 f0                	mov    eax,esi
  62b2dd:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  62b2e1:	48 c1 e0 04          	shl    rax,0x4
  62b2e5:	49 01 c1             	add    r9,rax
  62b2e8:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  62b2ef:	48 85 c0             	test   rax,rax
  62b2f2:	0f 84 53 01 00 00    	je     0x62b44b
  62b2f8:	8b 08                	mov    ecx,DWORD PTR [rax]
  62b2fa:	83 c1 07             	add    ecx,0x7
  62b2fd:	83 e1 f8             	and    ecx,0xfffffff8
  62b300:	41 8b 40 7c          	mov    eax,DWORD PTR [r8+0x7c]
  62b304:	39 c1                	cmp    ecx,eax
  62b306:	0f 87 3f 01 00 00    	ja     0x62b44b
  62b30c:	29 c8                	sub    eax,ecx
  62b30e:	83 f8 28             	cmp    eax,0x28
  62b311:	0f 82 34 01 00 00    	jb     0x62b44b
  62b317:	4d 8b 58 28          	mov    r11,QWORD PTR [r8+0x28]
  62b31b:	4d 85 db             	test   r11,r11
  62b31e:	0f 84 27 01 00 00    	je     0x62b44b
  62b324:	49 01 cb             	add    r11,rcx
  62b327:	49 8b 80 98 00 00 00 	mov    rax,QWORD PTR [r8+0x98]
  62b32e:	48 85 c0             	test   rax,rax
  62b331:	0f 84 14 01 00 00    	je     0x62b44b
  62b337:	8b 47 48             	mov    eax,DWORD PTR [rdi+0x48]
  62b33a:	85 c0                	test   eax,eax
  62b33c:	0f 84 42 00 00 00    	je     0x62b384
  62b342:	89 c2                	mov    edx,eax
  62b344:	83 e2 01             	and    edx,0x1
  62b347:	85 d2                	test   edx,edx
  62b349:	0f 85 35 00 00 00    	jne    0x62b384
  62b34f:	d1 e8                	shr    eax,1
  62b351:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  62b355:	0f 83 f0 00 00 00    	jae    0x62b44b
  62b35b:	4d 8b 50 08          	mov    r10,QWORD PTR [r8+0x8]
  62b35f:	48 c1 e0 04          	shl    rax,0x4
  62b363:	49 01 c2             	add    r10,rax
  62b366:	41 8b 42 0c          	mov    eax,DWORD PTR [r10+0xc]
  62b36a:	c1 e8 10             	shr    eax,0x10
  62b36d:	81 e0 ff 00 00 00    	and    eax,0xff
  62b373:	85 c0                	test   eax,eax
  62b375:	0f 84 d0 00 00 00    	je     0x62b44b
  62b37b:	83 f8 04             	cmp    eax,0x4
  62b37e:	0f 87 c7 00 00 00    	ja     0x62b44b
  62b384:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  62b38b:	41 8b 52 04          	mov    edx,DWORD PTR [r10+0x4]
  62b38f:	48 8b 83 e8 fe ff ff 	mov    rax,QWORD PTR [rbx-0x118]
  62b396:	48 8b 40 10          	mov    rax,QWORD PTR [rax+0x10]
  62b39a:	8b 80 f0 37 00 00    	mov    eax,DWORD PTR [rax+0x37f0]
  62b3a0:	41 89 03             	mov    DWORD PTR [r11],eax
  62b3a3:	41 c7 43 04 28 00 00 	mov    DWORD PTR [r11+0x4],0x28
  62b3aa:	00 
  62b3ab:	41 c7 43 08 00 00 00 	mov    DWORD PTR [r11+0x8],0x0
  62b3b2:	00 
  62b3b3:	41 c7 43 0c 00 00 00 	mov    DWORD PTR [r11+0xc],0x0
  62b3ba:	00 
  62b3bb:	8b 47 48             	mov    eax,DWORD PTR [rdi+0x48]
  62b3be:	41 89 43 10          	mov    DWORD PTR [r11+0x10],eax
  62b3c2:	8b 47 50             	mov    eax,DWORD PTR [rdi+0x50]
  62b3c5:	41 89 43 14          	mov    DWORD PTR [r11+0x14],eax
  62b3c9:	8b 47 58             	mov    eax,DWORD PTR [rdi+0x58]
  62b3cc:	41 89 43 18          	mov    DWORD PTR [r11+0x18],eax
  62b3d0:	8b 47 60             	mov    eax,DWORD PTR [rdi+0x60]
  62b3d3:	41 89 43 1c          	mov    DWORD PTR [r11+0x1c],eax
  62b3d7:	8b 47 68             	mov    eax,DWORD PTR [rdi+0x68]
  62b3da:	41 89 43 20          	mov    DWORD PTR [r11+0x20],eax
  62b3de:	8b 47 70             	mov    eax,DWORD PTR [rdi+0x70]
  62b3e1:	41 89 43 24          	mov    DWORD PTR [r11+0x24],eax
  62b3e5:	41 89 09             	mov    DWORD PTR [r9],ecx
  62b3e8:	41 c7 41 04 28 00 00 	mov    DWORD PTR [r9+0x4],0x28
  62b3ef:	00 
  62b3f0:	41 c7 41 08 00 00 00 	mov    DWORD PTR [r9+0x8],0x0
  62b3f7:	00 
  62b3f8:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  62b3ff:	41 89 ca             	mov    r10d,ecx
  62b402:	41 83 c2 28          	add    r10d,0x28
  62b406:	44 89 10             	mov    DWORD PTR [rax],r10d
  62b409:	41 c7 41 0c 00 00 01 	mov    DWORD PTR [r9+0xc],0x10000
  62b410:	00 
  62b411:	83 c2 01             	add    edx,0x1
  62b414:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  62b41b:	41 89 52 04          	mov    DWORD PTR [r10+0x4],edx
  62b41f:	41 83 7a 18 00       	cmp    DWORD PTR [r10+0x18],0x0
  62b424:	0f 84 11 00 00 00    	je     0x62b43b
  62b42a:	4d 8b 90 98 00 00 00 	mov    r10,QWORD PTR [r8+0x98]
  62b431:	49 8b 02             	mov    rax,QWORD PTR [r10]
  62b434:	48 83 c0 01          	add    rax,0x1
  62b438:	49 89 02             	mov    QWORD PTR [r10],rax
  62b43b:	89 f0                	mov    eax,esi
  62b43d:	d1 e0                	shl    eax,1
  62b43f:	48 89 87 48 02 00 00 	mov    QWORD PTR [rdi+0x248],rax
  62b446:	e9 05 00 00 00       	jmp    0x62b450
  62b44b:	b8 00 00 00 00       	mov    eax,0x0
  62b450:	85 c0                	test   eax,eax
  62b452:	41 58                	pop    r8
  62b454:	0f 85 14 00 00 00    	jne    0x62b46e
  62b45a:	41 c7 40 40 0b d1 15 	mov    DWORD PTR [r8+0x40],0x4015d10b
  62b461:	40 
  62b462:	41 c7 40 44 07 00 01 	mov    DWORD PTR [r8+0x44],0x10007
  62b469:	00 
  62b46a:	41 ff 50 38          	call   QWORD PTR [r8+0x38]
  62b46e:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  62b472:	49 8b b8 48 02 00 00 	mov    rdi,QWORD PTR [r8+0x248]
  62b479:	4c 8b bb e0 fe ff ff 	mov    r15,QWORD PTR [rbx-0x120]
  62b480:	48 8b b4 24 58 03 00 	mov    rsi,QWORD PTR [rsp+0x358]
  62b487:	00 
  62b488:	48 89 f0             	mov    rax,rsi
  62b48b:	48 89 f9             	mov    rcx,rdi
  62b48e:	e8 6d b8 9d ff       	call   0x6d00
  62b493:	48 8b 7c 24 50       	mov    rdi,QWORD PTR [rsp+0x50]
  62b498:	48 89 bc 24 30 02 00 	mov    QWORD PTR [rsp+0x230],rdi
  62b49f:	00 
  62b4a0:	48 8b bc 24 30 02 00 	mov    rdi,QWORD PTR [rsp+0x230]
  62b4a7:	00 
  62b4a8:	48 89 f8             	mov    rax,rdi
  62b4ab:	ba fa 0d 00 00       	mov    edx,0xdfa
  62b4b0:	b9 00 00 00 00       	mov    ecx,0x0
  62b4b5:	be 18 00 00 00       	mov    esi,0x18
  62b4ba:	e8 32 1f 00 00       	call   0x62d3f1
  62b4bf:	85 c0                	test   eax,eax
  62b4c1:	0f 84 df 02 00 00    	je     0x62b7a6
  62b4c7:	48 8b 7c 22 10       	mov    rdi,QWORD PTR [rdx+riz*1+0x10]
  62b4cc:	48 89 bc 24 c0 00 00 	mov    QWORD PTR [rsp+0xc0],rdi
  62b4d3:	00 
  62b4d4:	48 8b 7c 24 10       	mov    rdi,QWORD PTR [rsp+0x10]
  62b4d9:	48 89 f8             	mov    rax,rdi
  62b4dc:	ba 1a 0e 00 00       	mov    edx,0xe1a
  62b4e1:	b9 28 00 00 00       	mov    ecx,0x28
  62b4e6:	be 00 00 00 00       	mov    esi,0x0
  62b4eb:	e8 9f 21 00 00       	call   0x62d68f
  62b4f0:	8b 40 24             	mov    eax,DWORD PTR [rax+0x24]
  62b4f3:	48 8b bc 24 c0 00 00 	mov    rdi,QWORD PTR [rsp+0xc0]
  62b4fa:	00 
  62b4fb:	48 89 bc 24 08 02 00 	mov    QWORD PTR [rsp+0x208],rdi
  62b502:	00 
  62b503:	8b bc 24 b0 00 00 00 	mov    edi,DWORD PTR [rsp+0xb0]
  62b50a:	89 bc 24 10 02 00 00 	mov    DWORD PTR [rsp+0x210],edi
  62b511:	8b bc 24 98 00 00 00 	mov    edi,DWORD PTR [rsp+0x98]
  62b518:	89 bc 24 18 02 00 00 	mov    DWORD PTR [rsp+0x218],edi
  62b51f:	8b 7c 24 60          	mov    edi,DWORD PTR [rsp+0x60]
  62b523:	89 bc 24 20 02 00 00 	mov    DWORD PTR [rsp+0x220],edi
  62b52a:	8b bc 24 a0 00 00 00 	mov    edi,DWORD PTR [rsp+0xa0]
  62b531:	89 bc 24 28 02 00 00 	mov    DWORD PTR [rsp+0x228],edi
  62b538:	48 89 84 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rax
  62b53f:	00 
  62b540:	48 8b bc 24 08 02 00 	mov    rdi,QWORD PTR [rsp+0x208]
  62b547:	00 
  62b548:	48 89 bc 24 60 03 00 	mov    QWORD PTR [rsp+0x360],rdi
  62b54f:	00 
  62b550:	8b bc 24 10 02 00 00 	mov    edi,DWORD PTR [rsp+0x210]
  62b557:	48 89 bc 24 68 03 00 	mov    QWORD PTR [rsp+0x368],rdi
  62b55e:	00 
  62b55f:	8b bc 24 18 02 00 00 	mov    edi,DWORD PTR [rsp+0x218]
  62b566:	48 89 bc 24 70 03 00 	mov    QWORD PTR [rsp+0x370],rdi
  62b56d:	00 
  62b56e:	8b bc 24 20 02 00 00 	mov    edi,DWORD PTR [rsp+0x220]
  62b575:	48 89 bc 24 78 03 00 	mov    QWORD PTR [rsp+0x378],rdi
  62b57c:	00 
  62b57d:	8b bc 24 28 02 00 00 	mov    edi,DWORD PTR [rsp+0x228]
  62b584:	48 89 bc 24 80 03 00 	mov    QWORD PTR [rsp+0x380],rdi
  62b58b:	00 
  62b58c:	bf fd 0d 00 00       	mov    edi,0xdfd
  62b591:	48 89 bc 24 88 03 00 	mov    QWORD PTR [rsp+0x388],rdi
  62b598:	00 
  62b599:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  62b59d:	48 8b 84 24 60 03 00 	mov    rax,QWORD PTR [rsp+0x360]
  62b5a4:	00 
  62b5a5:	49 89 40 48          	mov    QWORD PTR [r8+0x48],rax
  62b5a9:	8b 84 24 68 03 00 00 	mov    eax,DWORD PTR [rsp+0x368]
  62b5b0:	49 89 40 50          	mov    QWORD PTR [r8+0x50],rax
  62b5b4:	8b 84 24 70 03 00 00 	mov    eax,DWORD PTR [rsp+0x370]
  62b5bb:	49 89 40 58          	mov    QWORD PTR [r8+0x58],rax
  62b5bf:	8b 84 24 78 03 00 00 	mov    eax,DWORD PTR [rsp+0x378]
  62b5c6:	49 89 40 60          	mov    QWORD PTR [r8+0x60],rax
  62b5ca:	8b 84 24 80 03 00 00 	mov    eax,DWORD PTR [rsp+0x380]
  62b5d1:	49 89 40 68          	mov    QWORD PTR [r8+0x68],rax
  62b5d5:	8b 84 24 88 03 00 00 	mov    eax,DWORD PTR [rsp+0x388]
  62b5dc:	49 89 40 70          	mov    QWORD PTR [r8+0x70],rax
  62b5e0:	41 50                	push   r8
  62b5e2:	4c 89 c7             	mov    rdi,r8
  62b5e5:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  62b5ec:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  62b5f0:	41 8b 92 f4 37 00 00 	mov    edx,DWORD PTR [r10+0x37f4]
  62b5f7:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  62b5fb:	41 83 b8 a0 00 00 00 	cmp    DWORD PTR [r8+0xa0],0x28
  62b602:	28 
  62b603:	0f 86 50 01 00 00    	jbe    0x62b759
  62b609:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  62b610:	4d 85 d2             	test   r10,r10
  62b613:	0f 84 40 01 00 00    	je     0x62b759
  62b619:	41 8b 4a 04          	mov    ecx,DWORD PTR [r10+0x4]
  62b61d:	41 8b 42 08          	mov    eax,DWORD PTR [r10+0x8]
  62b621:	81 f8 00 02 00 00    	cmp    eax,0x200
  62b627:	0f 87 2c 01 00 00    	ja     0x62b759
  62b62d:	39 c1                	cmp    ecx,eax
  62b62f:	0f 83 24 01 00 00    	jae    0x62b759
  62b635:	49 8d 44 8a 20       	lea    rax,[r10+rcx*4+0x20]
  62b63a:	8b 30                	mov    esi,DWORD PTR [rax]
  62b63c:	89 f0                	mov    eax,esi
  62b63e:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  62b642:	48 c1 e0 04          	shl    rax,0x4
  62b646:	49 01 c1             	add    r9,rax
  62b649:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  62b650:	48 85 c0             	test   rax,rax
  62b653:	0f 84 00 01 00 00    	je     0x62b759
  62b659:	8b 08                	mov    ecx,DWORD PTR [rax]
  62b65b:	83 c1 07             	add    ecx,0x7
  62b65e:	83 e1 f8             	and    ecx,0xfffffff8
  62b661:	41 8b 40 7c          	mov    eax,DWORD PTR [r8+0x7c]
  62b665:	39 c1                	cmp    ecx,eax
  62b667:	0f 87 ec 00 00 00    	ja     0x62b759
  62b66d:	29 c8                	sub    eax,ecx
  62b66f:	83 f8 28             	cmp    eax,0x28
  62b672:	0f 82 e1 00 00 00    	jb     0x62b759
  62b678:	4d 8b 58 28          	mov    r11,QWORD PTR [r8+0x28]
  62b67c:	4d 85 db             	test   r11,r11
  62b67f:	0f 84 d4 00 00 00    	je     0x62b759
  62b685:	49 01 cb             	add    r11,rcx
  62b688:	49 8b 80 98 00 00 00 	mov    rax,QWORD PTR [r8+0x98]
  62b68f:	48 85 c0             	test   rax,rax
  62b692:	0f 84 c1 00 00 00    	je     0x62b759
  62b698:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  62b69f:	41 8b 52 04          	mov    edx,DWORD PTR [r10+0x4]
  62b6a3:	48 8b 83 e8 fe ff ff 	mov    rax,QWORD PTR [rbx-0x118]
  62b6aa:	48 8b 40 10          	mov    rax,QWORD PTR [rax+0x10]
  62b6ae:	8b 80 f4 37 00 00    	mov    eax,DWORD PTR [rax+0x37f4]
  62b6b4:	41 89 03             	mov    DWORD PTR [r11],eax
  62b6b7:	41 c7 43 04 28 00 00 	mov    DWORD PTR [r11+0x4],0x28
  62b6be:	00 
  62b6bf:	41 c7 43 08 00 00 00 	mov    DWORD PTR [r11+0x8],0x0
  62b6c6:	00 
  62b6c7:	41 c7 43 0c 01 00 00 	mov    DWORD PTR [r11+0xc],0x1
  62b6ce:	00 
  62b6cf:	48 8b 47 48          	mov    rax,QWORD PTR [rdi+0x48]
  62b6d3:	49 89 43 10          	mov    QWORD PTR [r11+0x10],rax
  62b6d7:	8b 47 50             	mov    eax,DWORD PTR [rdi+0x50]
  62b6da:	41 89 43 18          	mov    DWORD PTR [r11+0x18],eax
  62b6de:	8b 47 58             	mov    eax,DWORD PTR [rdi+0x58]
  62b6e1:	41 89 43 1c          	mov    DWORD PTR [r11+0x1c],eax
  62b6e5:	8b 47 60             	mov    eax,DWORD PTR [rdi+0x60]
  62b6e8:	41 89 43 20          	mov    DWORD PTR [r11+0x20],eax
  62b6ec:	8b 47 68             	mov    eax,DWORD PTR [rdi+0x68]
  62b6ef:	41 89 43 24          	mov    DWORD PTR [r11+0x24],eax
  62b6f3:	41 89 09             	mov    DWORD PTR [r9],ecx
  62b6f6:	41 c7 41 04 28 00 00 	mov    DWORD PTR [r9+0x4],0x28
  62b6fd:	00 
  62b6fe:	41 c7 41 08 00 00 00 	mov    DWORD PTR [r9+0x8],0x0
  62b705:	00 
  62b706:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  62b70d:	41 89 ca             	mov    r10d,ecx
  62b710:	41 83 c2 28          	add    r10d,0x28
  62b714:	44 89 10             	mov    DWORD PTR [rax],r10d
  62b717:	41 c7 41 0c 00 00 01 	mov    DWORD PTR [r9+0xc],0x10000
  62b71e:	00 
  62b71f:	83 c2 01             	add    edx,0x1
  62b722:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  62b729:	41 89 52 04          	mov    DWORD PTR [r10+0x4],edx
  62b72d:	41 83 7a 18 00       	cmp    DWORD PTR [r10+0x18],0x0
  62b732:	0f 84 11 00 00 00    	je     0x62b749
  62b738:	4d 8b 90 98 00 00 00 	mov    r10,QWORD PTR [r8+0x98]
  62b73f:	49 8b 02             	mov    rax,QWORD PTR [r10]
  62b742:	48 83 c0 01          	add    rax,0x1
  62b746:	49 89 02             	mov    QWORD PTR [r10],rax
  62b749:	89 f0                	mov    eax,esi
  62b74b:	d1 e0                	shl    eax,1
  62b74d:	48 89 87 48 02 00 00 	mov    QWORD PTR [rdi+0x248],rax
  62b754:	e9 05 00 00 00       	jmp    0x62b75e
  62b759:	b8 00 00 00 00       	mov    eax,0x0
  62b75e:	85 c0                	test   eax,eax
  62b760:	41 58                	pop    r8
  62b762:	0f 85 14 00 00 00    	jne    0x62b77c
  62b768:	41 c7 40 40 0b d2 15 	mov    DWORD PTR [r8+0x40],0x4015d20b
  62b76f:	40 
  62b770:	41 c7 40 44 06 00 01 	mov    DWORD PTR [r8+0x44],0x10006
  62b777:	00 
  62b778:	41 ff 50 38          	call   QWORD PTR [r8+0x38]
  62b77c:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  62b780:	49 8b b8 48 02 00 00 	mov    rdi,QWORD PTR [r8+0x248]
  62b787:	4c 8b bb e0 fe ff ff 	mov    r15,QWORD PTR [rbx-0x120]
  62b78e:	48 8b b4 24 58 03 00 	mov    rsi,QWORD PTR [rsp+0x358]
  62b795:	00 
  62b796:	48 89 f0             	mov    rax,rsi
  62b799:	48 89 f9             	mov    rcx,rdi
  62b79c:	e8 5f b5 9d ff       	call   0x6d00
  62b7a1:	e9 2c 00 00 00       	jmp    0x62b7d2
  62b7a6:	48 8b bc 24 30 02 00 	mov    rdi,QWORD PTR [rsp+0x230]
  62b7ad:	00 
  62b7ae:	48 89 f8             	mov    rax,rdi
  62b7b1:	ba f8 0d 00 00       	mov    edx,0xdf8
  62b7b6:	b9 00 00 00 00       	mov    ecx,0x0
  62b7bb:	e8 97 1d 00 00       	call   0x62d557
  62b7c0:	85 c0                	test   eax,eax
  62b7c2:	0f 84 05 00 00 00    	je     0x62b7cd
  62b7c8:	e9 05 00 00 00       	jmp    0x62b7d2
  62b7cd:	e9 ed 1f 00 00       	jmp    0x62d7bf
  62b7d2:	e9 00 00 00 00       	jmp    0x62b7d7
  62b7d7:	e9 2c 00 00 00       	jmp    0x62b808
  62b7dc:	48 8b bc 24 38 02 00 	mov    rdi,QWORD PTR [rsp+0x238]
  62b7e3:	00 
  62b7e4:	48 89 f8             	mov    rax,rdi
  62b7e7:	ba 95 09 00 00       	mov    edx,0x995
  62b7ec:	b9 00 00 00 00       	mov    ecx,0x0
  62b7f1:	e8 61 1d 00 00       	call   0x62d557
  62b7f6:	85 c0                	test   eax,eax
  62b7f8:	0f 84 05 00 00 00    	je     0x62b803
  62b7fe:	e9 05 00 00 00       	jmp    0x62b808
  62b803:	e9 b7 1f 00 00       	jmp    0x62d7bf
  62b808:	8b 7c 24 70          	mov    edi,DWORD PTR [rsp+0x70]
  62b80c:	83 c7 01             	add    edi,0x1
  62b80f:	89 bc 24 40 02 00 00 	mov    DWORD PTR [rsp+0x240],edi
  62b816:	e9 ad e9 ff ff       	jmp    0x62a1c8
  62b81b:	e9 00 00 00 00       	jmp    0x62b820
  62b820:	48 8b 7c 24 10       	mov    rdi,QWORD PTR [rsp+0x10]
  62b825:	48 89 f8             	mov    rax,rdi
  62b828:	ba 1a 0e 00 00       	mov    edx,0xe1a
  62b82d:	b9 1c 00 00 00       	mov    ecx,0x1c
  62b832:	be 00 00 00 00       	mov    esi,0x0
  62b837:	e8 53 1e 00 00       	call   0x62d68f
  62b83c:	8b 40 18             	mov    eax,DWORD PTR [rax+0x18]
  62b83f:	48 89 84 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rax
  62b846:	00 
  62b847:	48 8b 7c 24 30       	mov    rdi,QWORD PTR [rsp+0x30]
  62b84c:	48 89 f8             	mov    rax,rdi
  62b84f:	ba 28 0e 00 00       	mov    edx,0xe28
  62b854:	b9 18 00 00 00       	mov    ecx,0x18
  62b859:	be 00 00 00 00       	mov    esi,0x0
  62b85e:	e8 2c 1e 00 00       	call   0x62d68f
  62b863:	48 8b 44 20 10       	mov    rax,QWORD PTR [rax+riz*1+0x10]
  62b868:	48 89 84 24 58 02 00 	mov    QWORD PTR [rsp+0x258],rax
  62b86f:	00 
  62b870:	48 8b 7c 24 50       	mov    rdi,QWORD PTR [rsp+0x50]
  62b875:	48 89 bc 24 60 02 00 	mov    QWORD PTR [rsp+0x260],rdi
  62b87c:	00 
  62b87d:	48 8b 7c 24 38       	mov    rdi,QWORD PTR [rsp+0x38]
  62b882:	48 89 bc 24 68 02 00 	mov    QWORD PTR [rsp+0x268],rdi
  62b889:	00 
  62b88a:	48 8b 7c 24 30       	mov    rdi,QWORD PTR [rsp+0x30]
  62b88f:	48 89 f8             	mov    rax,rdi
  62b892:	ba 28 0e 00 00       	mov    edx,0xe28
  62b897:	b9 28 00 00 00       	mov    ecx,0x28
  62b89c:	be 00 00 00 00       	mov    esi,0x0
  62b8a1:	e8 e9 1d 00 00       	call   0x62d68f
  62b8a6:	8b 40 24             	mov    eax,DWORD PTR [rax+0x24]
  62b8a9:	48 89 84 24 70 02 00 	mov    QWORD PTR [rsp+0x270],rax
  62b8b0:	00 
  62b8b1:	48 8b 7c 24 30       	mov    rdi,QWORD PTR [rsp+0x30]
  62b8b6:	48 89 f8             	mov    rax,rdi
  62b8b9:	ba 28 0e 00 00       	mov    edx,0xe28
  62b8be:	b9 2c 00 00 00       	mov    ecx,0x2c
  62b8c3:	be 00 00 00 00       	mov    esi,0x0
  62b8c8:	e8 c2 1d 00 00       	call   0x62d68f
  62b8cd:	8b 44 20 28          	mov    eax,DWORD PTR [rax+riz*1+0x28]
  62b8d1:	89 84 24 78 02 00 00 	mov    DWORD PTR [rsp+0x278],eax
  62b8d8:	8b 7c 24 58          	mov    edi,DWORD PTR [rsp+0x58]
  62b8dc:	89 bc 24 48 02 00 00 	mov    DWORD PTR [rsp+0x248],edi
  62b8e3:	48 8b 7c 24 10       	mov    rdi,QWORD PTR [rsp+0x10]
  62b8e8:	48 89 f8             	mov    rax,rdi
  62b8eb:	ba 1a 0e 00 00       	mov    edx,0xe1a
  62b8f0:	b9 20 00 00 00       	mov    ecx,0x20
  62b8f5:	be 00 00 00 00       	mov    esi,0x0
  62b8fa:	e8 90 1d 00 00       	call   0x62d68f
  62b8ff:	8b 40 1c             	mov    eax,DWORD PTR [rax+0x1c]
  62b902:	48 89 84 24 f0 02 00 	mov    QWORD PTR [rsp+0x2f0],rax
  62b909:	00 
  62b90a:	48 8b bc 24 f0 02 00 	mov    rdi,QWORD PTR [rsp+0x2f0]
  62b911:	00 
  62b912:	48 89 f8             	mov    rax,rdi
  62b915:	ba a0 09 00 00       	mov    edx,0x9a0
  62b91a:	b9 18 00 00 00       	mov    ecx,0x18
  62b91f:	be 00 00 00 00       	mov    esi,0x0
  62b924:	e8 66 1d 00 00       	call   0x62d68f
  62b929:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  62b92d:	48 89 84 24 60 03 00 	mov    QWORD PTR [rsp+0x360],rax
  62b934:	00 
  62b935:	8b 7c 24 58          	mov    edi,DWORD PTR [rsp+0x58]
  62b939:	89 bc 24 50 03 00 00 	mov    DWORD PTR [rsp+0x350],edi
  62b940:	8b bc 24 60 03 00 00 	mov    edi,DWORD PTR [rsp+0x360]
  62b947:	89 bc 24 48 03 00 00 	mov    DWORD PTR [rsp+0x348],edi
  62b94e:	8b bc 24 48 03 00 00 	mov    edi,DWORD PTR [rsp+0x348]
  62b955:	8b b4 24 50 03 00 00 	mov    esi,DWORD PTR [rsp+0x350]
  62b95c:	29 f7                	sub    edi,esi
  62b95e:	89 bc 24 50 02 00 00 	mov    DWORD PTR [rsp+0x250],edi
  62b965:	8b bc 24 48 02 00 00 	mov    edi,DWORD PTR [rsp+0x248]
  62b96c:	48 89 bc 24 60 03 00 	mov    QWORD PTR [rsp+0x360],rdi
  62b973:	00 
  62b974:	8b bc 24 50 02 00 00 	mov    edi,DWORD PTR [rsp+0x250]
  62b97b:	48 89 bc 24 68 03 00 	mov    QWORD PTR [rsp+0x368],rdi
  62b982:	00 
  62b983:	bf 3d 0d 00 00       	mov    edi,0xd3d
  62b988:	48 89 bc 24 70 03 00 	mov    QWORD PTR [rsp+0x370],rdi
  62b98f:	00 
  62b990:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  62b994:	8b 84 24 60 03 00 00 	mov    eax,DWORD PTR [rsp+0x360]
  62b99b:	49 89 40 48          	mov    QWORD PTR [r8+0x48],rax
  62b99f:	8b 84 24 68 03 00 00 	mov    eax,DWORD PTR [rsp+0x368]
  62b9a6:	49 89 40 50          	mov    QWORD PTR [r8+0x50],rax
  62b9aa:	8b 84 24 70 03 00 00 	mov    eax,DWORD PTR [rsp+0x370]
  62b9b1:	49 89 40 58          	mov    QWORD PTR [r8+0x58],rax
  62b9b5:	41 50                	push   r8
  62b9b7:	4c 89 c7             	mov    rdi,r8
  62b9ba:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  62b9c1:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  62b9c5:	41 8b 92 f4 34 00 00 	mov    edx,DWORD PTR [r10+0x34f4]
  62b9cc:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  62b9d0:	41 83 b8 a0 00 00 00 	cmp    DWORD PTR [r8+0xa0],0x18
  62b9d7:	18 
  62b9d8:	0f 86 3a 01 00 00    	jbe    0x62bb18
  62b9de:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  62b9e5:	4d 85 d2             	test   r10,r10
  62b9e8:	0f 84 2a 01 00 00    	je     0x62bb18
  62b9ee:	41 8b 4a 04          	mov    ecx,DWORD PTR [r10+0x4]
  62b9f2:	41 8b 42 08          	mov    eax,DWORD PTR [r10+0x8]
  62b9f6:	81 f8 00 02 00 00    	cmp    eax,0x200
  62b9fc:	0f 87 16 01 00 00    	ja     0x62bb18
  62ba02:	39 c1                	cmp    ecx,eax
  62ba04:	0f 83 0e 01 00 00    	jae    0x62bb18
  62ba0a:	49 8d 44 8a 20       	lea    rax,[r10+rcx*4+0x20]
  62ba0f:	8b 30                	mov    esi,DWORD PTR [rax]
  62ba11:	89 f0                	mov    eax,esi
  62ba13:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  62ba17:	48 c1 e0 04          	shl    rax,0x4
  62ba1b:	49 01 c1             	add    r9,rax
  62ba1e:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  62ba25:	48 85 c0             	test   rax,rax
  62ba28:	0f 84 ea 00 00 00    	je     0x62bb18
  62ba2e:	8b 08                	mov    ecx,DWORD PTR [rax]
  62ba30:	83 c1 07             	add    ecx,0x7
  62ba33:	83 e1 f8             	and    ecx,0xfffffff8
  62ba36:	41 8b 40 7c          	mov    eax,DWORD PTR [r8+0x7c]
  62ba3a:	39 c1                	cmp    ecx,eax
  62ba3c:	0f 87 d6 00 00 00    	ja     0x62bb18
  62ba42:	29 c8                	sub    eax,ecx
  62ba44:	83 f8 18             	cmp    eax,0x18
  62ba47:	0f 82 cb 00 00 00    	jb     0x62bb18
  62ba4d:	4d 8b 58 28          	mov    r11,QWORD PTR [r8+0x28]
  62ba51:	4d 85 db             	test   r11,r11
  62ba54:	0f 84 be 00 00 00    	je     0x62bb18
  62ba5a:	49 01 cb             	add    r11,rcx
  62ba5d:	49 8b 80 98 00 00 00 	mov    rax,QWORD PTR [r8+0x98]
  62ba64:	48 85 c0             	test   rax,rax
  62ba67:	0f 84 ab 00 00 00    	je     0x62bb18
  62ba6d:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  62ba74:	41 8b 52 04          	mov    edx,DWORD PTR [r10+0x4]
  62ba78:	48 8b 83 e8 fe ff ff 	mov    rax,QWORD PTR [rbx-0x118]
  62ba7f:	48 8b 40 10          	mov    rax,QWORD PTR [rax+0x10]
  62ba83:	8b 80 f4 34 00 00    	mov    eax,DWORD PTR [rax+0x34f4]
  62ba89:	41 89 03             	mov    DWORD PTR [r11],eax
  62ba8c:	41 c7 43 04 18 00 00 	mov    DWORD PTR [r11+0x4],0x18
  62ba93:	00 
  62ba94:	41 c7 43 08 00 00 00 	mov    DWORD PTR [r11+0x8],0x0
  62ba9b:	00 
  62ba9c:	41 c7 43 0c 01 00 00 	mov    DWORD PTR [r11+0xc],0x1
  62baa3:	00 
  62baa4:	8b 47 48             	mov    eax,DWORD PTR [rdi+0x48]
  62baa7:	41 89 43 10          	mov    DWORD PTR [r11+0x10],eax
  62baab:	8b 47 50             	mov    eax,DWORD PTR [rdi+0x50]
  62baae:	41 89 43 14          	mov    DWORD PTR [r11+0x14],eax
  62bab2:	41 89 09             	mov    DWORD PTR [r9],ecx
  62bab5:	41 c7 41 04 18 00 00 	mov    DWORD PTR [r9+0x4],0x18
  62babc:	00 
  62babd:	41 c7 41 08 00 00 00 	mov    DWORD PTR [r9+0x8],0x0
  62bac4:	00 
  62bac5:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  62bacc:	41 89 ca             	mov    r10d,ecx
  62bacf:	41 83 c2 18          	add    r10d,0x18
  62bad3:	44 89 10             	mov    DWORD PTR [rax],r10d
  62bad6:	41 c7 41 0c 00 00 01 	mov    DWORD PTR [r9+0xc],0x10000
  62badd:	00 
  62bade:	83 c2 01             	add    edx,0x1
  62bae1:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  62bae8:	41 89 52 04          	mov    DWORD PTR [r10+0x4],edx
  62baec:	41 83 7a 18 00       	cmp    DWORD PTR [r10+0x18],0x0
  62baf1:	0f 84 11 00 00 00    	je     0x62bb08
  62baf7:	4d 8b 90 98 00 00 00 	mov    r10,QWORD PTR [r8+0x98]
  62bafe:	49 8b 02             	mov    rax,QWORD PTR [r10]
  62bb01:	48 83 c0 01          	add    rax,0x1
  62bb05:	49 89 02             	mov    QWORD PTR [r10],rax
  62bb08:	89 f0                	mov    eax,esi
  62bb0a:	d1 e0                	shl    eax,1
  62bb0c:	48 89 87 48 02 00 00 	mov    QWORD PTR [rdi+0x248],rax
  62bb13:	e9 05 00 00 00       	jmp    0x62bb1d
  62bb18:	b8 00 00 00 00       	mov    eax,0x0
  62bb1d:	85 c0                	test   eax,eax
  62bb1f:	41 58                	pop    r8
  62bb21:	0f 85 14 00 00 00    	jne    0x62bb3b
  62bb27:	41 c7 40 40 0b d3 15 	mov    DWORD PTR [r8+0x40],0x4015d30b
  62bb2e:	40 
  62bb2f:	41 c7 40 44 03 00 01 	mov    DWORD PTR [r8+0x44],0x10003
  62bb36:	00 
  62bb37:	41 ff 50 38          	call   QWORD PTR [r8+0x38]
  62bb3b:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  62bb3f:	49 8b b8 48 02 00 00 	mov    rdi,QWORD PTR [r8+0x248]
  62bb46:	4c 8b bb e0 fe ff ff 	mov    r15,QWORD PTR [rbx-0x120]
  62bb4d:	48 89 bc 24 80 02 00 	mov    QWORD PTR [rsp+0x280],rdi
  62bb54:	00 
  62bb55:	bf 01 00 00 00       	mov    edi,0x1
  62bb5a:	89 bc 24 88 02 00 00 	mov    DWORD PTR [rsp+0x288],edi
  62bb61:	bf 01 00 00 00       	mov    edi,0x1
  62bb66:	89 bc 24 90 02 00 00 	mov    DWORD PTR [rsp+0x290],edi
  62bb6d:	bf 00 00 00 00       	mov    edi,0x0
  62bb72:	89 bc 24 98 02 00 00 	mov    DWORD PTR [rsp+0x298],edi
  62bb79:	48 8b bc 24 58 02 00 	mov    rdi,QWORD PTR [rsp+0x258]
  62bb80:	00 
  62bb81:	48 89 bc 24 60 03 00 	mov    QWORD PTR [rsp+0x360],rdi
  62bb88:	00 
  62bb89:	48 8b bc 24 60 02 00 	mov    rdi,QWORD PTR [rsp+0x260]
  62bb90:	00 
  62bb91:	48 89 bc 24 68 03 00 	mov    QWORD PTR [rsp+0x368],rdi
  62bb98:	00 
  62bb99:	48 8b bc 24 68 02 00 	mov    rdi,QWORD PTR [rsp+0x268]
  62bba0:	00 
  62bba1:	48 89 bc 24 70 03 00 	mov    QWORD PTR [rsp+0x370],rdi
  62bba8:	00 
  62bba9:	48 8b bc 24 70 02 00 	mov    rdi,QWORD PTR [rsp+0x270]
  62bbb0:	00 
  62bbb1:	48 89 bc 24 78 03 00 	mov    QWORD PTR [rsp+0x378],rdi
  62bbb8:	00 
  62bbb9:	8b bc 24 78 02 00 00 	mov    edi,DWORD PTR [rsp+0x278]
  62bbc0:	48 89 bc 24 80 03 00 	mov    QWORD PTR [rsp+0x380],rdi
  62bbc7:	00 
  62bbc8:	48 8b bc 24 80 02 00 	mov    rdi,QWORD PTR [rsp+0x280]
  62bbcf:	00 
  62bbd0:	48 89 bc 24 88 03 00 	mov    QWORD PTR [rsp+0x388],rdi
  62bbd7:	00 
  62bbd8:	8b bc 24 88 02 00 00 	mov    edi,DWORD PTR [rsp+0x288]
  62bbdf:	48 89 bc 24 90 03 00 	mov    QWORD PTR [rsp+0x390],rdi
  62bbe6:	00 
  62bbe7:	8b bc 24 90 02 00 00 	mov    edi,DWORD PTR [rsp+0x290]
  62bbee:	48 89 bc 24 98 03 00 	mov    QWORD PTR [rsp+0x398],rdi
  62bbf5:	00 
  62bbf6:	8b bc 24 98 02 00 00 	mov    edi,DWORD PTR [rsp+0x298]
  62bbfd:	48 89 bc 24 a0 03 00 	mov    QWORD PTR [rsp+0x3a0],rdi
  62bc04:	00 
  62bc05:	bf fe 0d 00 00       	mov    edi,0xdfe
  62bc0a:	48 89 bc 24 a8 03 00 	mov    QWORD PTR [rsp+0x3a8],rdi
  62bc11:	00 
  62bc12:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  62bc16:	48 8b 84 24 60 03 00 	mov    rax,QWORD PTR [rsp+0x360]
  62bc1d:	00 
  62bc1e:	49 89 40 48          	mov    QWORD PTR [r8+0x48],rax
  62bc22:	48 8b 84 24 68 03 00 	mov    rax,QWORD PTR [rsp+0x368]
  62bc29:	00 
  62bc2a:	49 89 40 50          	mov    QWORD PTR [r8+0x50],rax
  62bc2e:	48 8b 84 24 70 03 00 	mov    rax,QWORD PTR [rsp+0x370]
  62bc35:	00 
  62bc36:	49 89 40 58          	mov    QWORD PTR [r8+0x58],rax
  62bc3a:	48 8b 84 24 78 03 00 	mov    rax,QWORD PTR [rsp+0x378]
  62bc41:	00 
  62bc42:	49 89 40 60          	mov    QWORD PTR [r8+0x60],rax
  62bc46:	8b 84 24 80 03 00 00 	mov    eax,DWORD PTR [rsp+0x380]
  62bc4d:	49 89 40 68          	mov    QWORD PTR [r8+0x68],rax
  62bc51:	48 8b 84 24 88 03 00 	mov    rax,QWORD PTR [rsp+0x388]
  62bc58:	00 
  62bc59:	49 89 40 70          	mov    QWORD PTR [r8+0x70],rax
  62bc5d:	8b 84 24 90 03 00 00 	mov    eax,DWORD PTR [rsp+0x390]
  62bc64:	49 89 40 78          	mov    QWORD PTR [r8+0x78],rax
  62bc68:	8b 84 24 98 03 00 00 	mov    eax,DWORD PTR [rsp+0x398]
  62bc6f:	49 89 80 80 00 00 00 	mov    QWORD PTR [r8+0x80],rax
  62bc76:	8b 84 24 a0 03 00 00 	mov    eax,DWORD PTR [rsp+0x3a0]
  62bc7d:	49 89 80 88 00 00 00 	mov    QWORD PTR [r8+0x88],rax
  62bc84:	8b 84 24 a8 03 00 00 	mov    eax,DWORD PTR [rsp+0x3a8]
  62bc8b:	49 89 80 90 00 00 00 	mov    QWORD PTR [r8+0x90],rax
  62bc92:	41 50                	push   r8
  62bc94:	4c 89 c7             	mov    rdi,r8
  62bc97:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  62bc9e:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  62bca2:	41 8b 92 f8 37 00 00 	mov    edx,DWORD PTR [r10+0x37f8]
  62bca9:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  62bcad:	41 83 b8 a0 00 00 00 	cmp    DWORD PTR [r8+0xa0],0x38
  62bcb4:	38 
  62bcb5:	0f 86 a6 02 00 00    	jbe    0x62bf61
  62bcbb:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  62bcc2:	4d 85 d2             	test   r10,r10
  62bcc5:	0f 84 96 02 00 00    	je     0x62bf61
  62bccb:	41 8b 4a 04          	mov    ecx,DWORD PTR [r10+0x4]
  62bccf:	41 8b 42 08          	mov    eax,DWORD PTR [r10+0x8]
  62bcd3:	81 f8 00 02 00 00    	cmp    eax,0x200
  62bcd9:	0f 87 82 02 00 00    	ja     0x62bf61
  62bcdf:	39 c1                	cmp    ecx,eax
  62bce1:	0f 83 7a 02 00 00    	jae    0x62bf61
  62bce7:	49 8d 44 8a 20       	lea    rax,[r10+rcx*4+0x20]
  62bcec:	8b 30                	mov    esi,DWORD PTR [rax]
  62bcee:	89 f0                	mov    eax,esi
  62bcf0:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  62bcf4:	48 c1 e0 04          	shl    rax,0x4
  62bcf8:	49 01 c1             	add    r9,rax
  62bcfb:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  62bd02:	48 85 c0             	test   rax,rax
  62bd05:	0f 84 56 02 00 00    	je     0x62bf61
  62bd0b:	8b 08                	mov    ecx,DWORD PTR [rax]
  62bd0d:	83 c1 07             	add    ecx,0x7
  62bd10:	83 e1 f8             	and    ecx,0xfffffff8
  62bd13:	41 8b 40 7c          	mov    eax,DWORD PTR [r8+0x7c]
  62bd17:	39 c1                	cmp    ecx,eax
  62bd19:	0f 87 42 02 00 00    	ja     0x62bf61
  62bd1f:	29 c8                	sub    eax,ecx
  62bd21:	83 f8 38             	cmp    eax,0x38
  62bd24:	0f 82 37 02 00 00    	jb     0x62bf61
  62bd2a:	4d 8b 58 28          	mov    r11,QWORD PTR [r8+0x28]
  62bd2e:	4d 85 db             	test   r11,r11
  62bd31:	0f 84 2a 02 00 00    	je     0x62bf61
  62bd37:	49 01 cb             	add    r11,rcx
  62bd3a:	49 8b 80 98 00 00 00 	mov    rax,QWORD PTR [r8+0x98]
  62bd41:	48 85 c0             	test   rax,rax
  62bd44:	0f 84 17 02 00 00    	je     0x62bf61
  62bd4a:	8b 47 50             	mov    eax,DWORD PTR [rdi+0x50]
  62bd4d:	85 c0                	test   eax,eax
  62bd4f:	0f 84 42 00 00 00    	je     0x62bd97
  62bd55:	89 c2                	mov    edx,eax
  62bd57:	83 e2 01             	and    edx,0x1
  62bd5a:	85 d2                	test   edx,edx
  62bd5c:	0f 85 35 00 00 00    	jne    0x62bd97
  62bd62:	d1 e8                	shr    eax,1
  62bd64:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  62bd68:	0f 83 f3 01 00 00    	jae    0x62bf61
  62bd6e:	4d 8b 50 08          	mov    r10,QWORD PTR [r8+0x8]
  62bd72:	48 c1 e0 04          	shl    rax,0x4
  62bd76:	49 01 c2             	add    r10,rax
  62bd79:	41 8b 42 0c          	mov    eax,DWORD PTR [r10+0xc]
  62bd7d:	c1 e8 10             	shr    eax,0x10
  62bd80:	81 e0 ff 00 00 00    	and    eax,0xff
  62bd86:	85 c0                	test   eax,eax
  62bd88:	0f 84 d3 01 00 00    	je     0x62bf61
  62bd8e:	83 f8 04             	cmp    eax,0x4
  62bd91:	0f 87 ca 01 00 00    	ja     0x62bf61
  62bd97:	8b 47 58             	mov    eax,DWORD PTR [rdi+0x58]
  62bd9a:	85 c0                	test   eax,eax
  62bd9c:	0f 84 42 00 00 00    	je     0x62bde4
  62bda2:	89 c2                	mov    edx,eax
  62bda4:	83 e2 01             	and    edx,0x1
  62bda7:	85 d2                	test   edx,edx
  62bda9:	0f 85 35 00 00 00    	jne    0x62bde4
  62bdaf:	d1 e8                	shr    eax,1
  62bdb1:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  62bdb5:	0f 83 a6 01 00 00    	jae    0x62bf61
  62bdbb:	4d 8b 50 08          	mov    r10,QWORD PTR [r8+0x8]
  62bdbf:	48 c1 e0 04          	shl    rax,0x4
  62bdc3:	49 01 c2             	add    r10,rax
  62bdc6:	41 8b 42 0c          	mov    eax,DWORD PTR [r10+0xc]
  62bdca:	c1 e8 10             	shr    eax,0x10
  62bdcd:	81 e0 ff 00 00 00    	and    eax,0xff
  62bdd3:	85 c0                	test   eax,eax
  62bdd5:	0f 84 86 01 00 00    	je     0x62bf61
  62bddb:	83 f8 04             	cmp    eax,0x4
  62bdde:	0f 87 7d 01 00 00    	ja     0x62bf61
  62bde4:	8b 47 60             	mov    eax,DWORD PTR [rdi+0x60]
  62bde7:	85 c0                	test   eax,eax
  62bde9:	0f 84 42 00 00 00    	je     0x62be31
  62bdef:	89 c2                	mov    edx,eax
  62bdf1:	83 e2 01             	and    edx,0x1
  62bdf4:	85 d2                	test   edx,edx
  62bdf6:	0f 85 35 00 00 00    	jne    0x62be31
  62bdfc:	d1 e8                	shr    eax,1
  62bdfe:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  62be02:	0f 83 59 01 00 00    	jae    0x62bf61
  62be08:	4d 8b 50 08          	mov    r10,QWORD PTR [r8+0x8]
  62be0c:	48 c1 e0 04          	shl    rax,0x4
  62be10:	49 01 c2             	add    r10,rax
  62be13:	41 8b 42 0c          	mov    eax,DWORD PTR [r10+0xc]
  62be17:	c1 e8 10             	shr    eax,0x10
  62be1a:	81 e0 ff 00 00 00    	and    eax,0xff
  62be20:	85 c0                	test   eax,eax
  62be22:	0f 84 39 01 00 00    	je     0x62bf61
  62be28:	83 f8 04             	cmp    eax,0x4
  62be2b:	0f 87 30 01 00 00    	ja     0x62bf61
  62be31:	8b 47 70             	mov    eax,DWORD PTR [rdi+0x70]
  62be34:	85 c0                	test   eax,eax
  62be36:	0f 84 42 00 00 00    	je     0x62be7e
  62be3c:	89 c2                	mov    edx,eax
  62be3e:	83 e2 01             	and    edx,0x1
  62be41:	85 d2                	test   edx,edx
  62be43:	0f 85 35 00 00 00    	jne    0x62be7e
  62be49:	d1 e8                	shr    eax,1
  62be4b:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  62be4f:	0f 83 0c 01 00 00    	jae    0x62bf61
  62be55:	4d 8b 50 08          	mov    r10,QWORD PTR [r8+0x8]
  62be59:	48 c1 e0 04          	shl    rax,0x4
  62be5d:	49 01 c2             	add    r10,rax
  62be60:	41 8b 42 0c          	mov    eax,DWORD PTR [r10+0xc]
  62be64:	c1 e8 10             	shr    eax,0x10
  62be67:	81 e0 ff 00 00 00    	and    eax,0xff
  62be6d:	85 c0                	test   eax,eax
  62be6f:	0f 84 ec 00 00 00    	je     0x62bf61
  62be75:	83 f8 04             	cmp    eax,0x4
  62be78:	0f 87 e3 00 00 00    	ja     0x62bf61
  62be7e:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  62be85:	41 8b 52 04          	mov    edx,DWORD PTR [r10+0x4]
  62be89:	48 8b 83 e8 fe ff ff 	mov    rax,QWORD PTR [rbx-0x118]
  62be90:	48 8b 40 10          	mov    rax,QWORD PTR [rax+0x10]
  62be94:	8b 80 f8 37 00 00    	mov    eax,DWORD PTR [rax+0x37f8]
  62be9a:	41 89 03             	mov    DWORD PTR [r11],eax
  62be9d:	41 c7 43 04 38 00 00 	mov    DWORD PTR [r11+0x4],0x38
  62bea4:	00 
  62bea5:	41 c7 43 08 00 00 00 	mov    DWORD PTR [r11+0x8],0x0
  62beac:	00 
  62bead:	41 c7 43 0c 00 00 00 	mov    DWORD PTR [r11+0xc],0x0
  62beb4:	00 
  62beb5:	48 8b 47 48          	mov    rax,QWORD PTR [rdi+0x48]
  62beb9:	49 89 43 10          	mov    QWORD PTR [r11+0x10],rax
  62bebd:	8b 47 50             	mov    eax,DWORD PTR [rdi+0x50]
  62bec0:	41 89 43 18          	mov    DWORD PTR [r11+0x18],eax
  62bec4:	8b 47 58             	mov    eax,DWORD PTR [rdi+0x58]
  62bec7:	41 89 43 1c          	mov    DWORD PTR [r11+0x1c],eax
  62becb:	8b 47 60             	mov    eax,DWORD PTR [rdi+0x60]
  62bece:	41 89 43 20          	mov    DWORD PTR [r11+0x20],eax
  62bed2:	8b 47 68             	mov    eax,DWORD PTR [rdi+0x68]
  62bed5:	41 89 43 24          	mov    DWORD PTR [r11+0x24],eax
  62bed9:	8b 47 70             	mov    eax,DWORD PTR [rdi+0x70]
  62bedc:	41 89 43 28          	mov    DWORD PTR [r11+0x28],eax
  62bee0:	8b 47 78             	mov    eax,DWORD PTR [rdi+0x78]
  62bee3:	41 89 43 2c          	mov    DWORD PTR [r11+0x2c],eax
  62bee7:	8b 87 80 00 00 00    	mov    eax,DWORD PTR [rdi+0x80]
  62beed:	41 89 43 30          	mov    DWORD PTR [r11+0x30],eax
  62bef1:	8b 87 88 00 00 00    	mov    eax,DWORD PTR [rdi+0x88]
  62bef7:	41 89 43 34          	mov    DWORD PTR [r11+0x34],eax
  62befb:	41 89 09             	mov    DWORD PTR [r9],ecx
  62befe:	41 c7 41 04 38 00 00 	mov    DWORD PTR [r9+0x4],0x38
  62bf05:	00 
  62bf06:	41 c7 41 08 00 00 00 	mov    DWORD PTR [r9+0x8],0x0
  62bf0d:	00 
  62bf0e:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  62bf15:	41 89 ca             	mov    r10d,ecx
  62bf18:	41 83 c2 38          	add    r10d,0x38
  62bf1c:	44 89 10             	mov    DWORD PTR [rax],r10d
  62bf1f:	41 c7 41 0c 00 00 01 	mov    DWORD PTR [r9+0xc],0x10000
  62bf26:	00 
  62bf27:	83 c2 01             	add    edx,0x1
  62bf2a:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  62bf31:	41 89 52 04          	mov    DWORD PTR [r10+0x4],edx
  62bf35:	41 83 7a 18 00       	cmp    DWORD PTR [r10+0x18],0x0
  62bf3a:	0f 84 11 00 00 00    	je     0x62bf51
  62bf40:	4d 8b 90 98 00 00 00 	mov    r10,QWORD PTR [r8+0x98]
  62bf47:	49 8b 02             	mov    rax,QWORD PTR [r10]
  62bf4a:	48 83 c0 01          	add    rax,0x1
  62bf4e:	49 89 02             	mov    QWORD PTR [r10],rax
  62bf51:	89 f0                	mov    eax,esi
  62bf53:	d1 e0                	shl    eax,1
  62bf55:	48 89 87 48 02 00 00 	mov    QWORD PTR [rdi+0x248],rax
  62bf5c:	e9 05 00 00 00       	jmp    0x62bf66
  62bf61:	b8 00 00 00 00       	mov    eax,0x0
  62bf66:	85 c0                	test   eax,eax
  62bf68:	41 58                	pop    r8
  62bf6a:	0f 85 14 00 00 00    	jne    0x62bf84
  62bf70:	41 c7 40 40 0b d4 15 	mov    DWORD PTR [r8+0x40],0x4015d40b
  62bf77:	40 
  62bf78:	41 c7 40 44 0a 00 01 	mov    DWORD PTR [r8+0x44],0x1000a
  62bf7f:	00 
  62bf80:	41 ff 50 38          	call   QWORD PTR [r8+0x38]
  62bf84:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  62bf88:	49 8b b8 48 02 00 00 	mov    rdi,QWORD PTR [r8+0x248]
  62bf8f:	4c 8b bb e0 fe ff ff 	mov    r15,QWORD PTR [rbx-0x120]
  62bf96:	48 8b b4 24 58 03 00 	mov    rsi,QWORD PTR [rsp+0x358]
  62bf9d:	00 
  62bf9e:	48 89 f0             	mov    rax,rsi
  62bfa1:	48 89 f9             	mov    rcx,rdi
  62bfa4:	e8 57 ad 9d ff       	call   0x6d00
  62bfa9:	e9 00 00 00 00       	jmp    0x62bfae
  62bfae:	8b 7c 24 28          	mov    edi,DWORD PTR [rsp+0x28]
  62bfb2:	83 c7 01             	add    edi,0x1
  62bfb5:	89 bc 24 a0 02 00 00 	mov    DWORD PTR [rsp+0x2a0],edi
  62bfbc:	e9 af d8 ff ff       	jmp    0x629870
  62bfc1:	e9 00 00 00 00       	jmp    0x62bfc6
  62bfc6:	8b 7c 24 18          	mov    edi,DWORD PTR [rsp+0x18]
  62bfca:	89 bc 24 c8 00 00 00 	mov    DWORD PTR [rsp+0xc8],edi
  62bfd1:	89 bc 24 c8 02 00 00 	mov    DWORD PTR [rsp+0x2c8],edi
  62bfd8:	66 0f 1f 84 00 00 00 	nop    WORD PTR [rax+rax*1+0x0]
  62bfdf:	00 00 
  62bfe1:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
  62bfe8:	8b bc 24 c8 02 00 00 	mov    edi,DWORD PTR [rsp+0x2c8]
  62bfef:	89 bc 24 d0 00 00 00 	mov    DWORD PTR [rsp+0xd0],edi
  62bff6:	48 89 bc 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rdi
  62bffd:	00 
  62bffe:	48 8b 7c 24 10       	mov    rdi,QWORD PTR [rsp+0x10]
  62c003:	48 89 f8             	mov    rax,rdi
  62c006:	ba 1a 0e 00 00       	mov    edx,0xe1a
  62c00b:	b9 1c 00 00 00       	mov    ecx,0x1c
  62c010:	be 00 00 00 00       	mov    esi,0x0
  62c015:	e8 75 16 00 00       	call   0x62d68f
  62c01a:	8b 40 18             	mov    eax,DWORD PTR [rax+0x18]
  62c01d:	48 89 84 24 f0 02 00 	mov    QWORD PTR [rsp+0x2f0],rax
  62c024:	00 
  62c025:	48 8b bc 24 f0 02 00 	mov    rdi,QWORD PTR [rsp+0x2f0]
  62c02c:	00 
  62c02d:	48 89 f8             	mov    rax,rdi
  62c030:	ba a0 09 00 00       	mov    edx,0x9a0
  62c035:	b9 18 00 00 00       	mov    ecx,0x18
  62c03a:	be 00 00 00 00       	mov    esi,0x0
  62c03f:	e8 4b 16 00 00       	call   0x62d68f
  62c044:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  62c048:	48 89 84 24 60 03 00 	mov    QWORD PTR [rsp+0x360],rax
  62c04f:	00 
  62c050:	8b bc 24 60 03 00 00 	mov    edi,DWORD PTR [rsp+0x360]
  62c057:	89 bc 24 00 03 00 00 	mov    DWORD PTR [rsp+0x300],edi
  62c05e:	8b bc 24 58 03 00 00 	mov    edi,DWORD PTR [rsp+0x358]
  62c065:	89 bc 24 f8 02 00 00 	mov    DWORD PTR [rsp+0x2f8],edi
  62c06c:	8b bc 24 f8 02 00 00 	mov    edi,DWORD PTR [rsp+0x2f8]
  62c073:	8b b4 24 00 03 00 00 	mov    esi,DWORD PTR [rsp+0x300]
  62c07a:	39 f7                	cmp    edi,esi
  62c07c:	0f 83 74 0a 00 00    	jae    0x62caf6
  62c082:	48 8b 7c 24 10       	mov    rdi,QWORD PTR [rsp+0x10]
  62c087:	48 89 f8             	mov    rax,rdi
  62c08a:	ba 1a 0e 00 00       	mov    edx,0xe1a
  62c08f:	b9 1c 00 00 00       	mov    ecx,0x1c
  62c094:	be 00 00 00 00       	mov    esi,0x0
  62c099:	e8 f1 15 00 00       	call   0x62d68f
  62c09e:	8b 40 18             	mov    eax,DWORD PTR [rax+0x18]
  62c0a1:	8b bc 24 d0 00 00 00 	mov    edi,DWORD PTR [rsp+0xd0]
  62c0a8:	89 bc 24 10 03 00 00 	mov    DWORD PTR [rsp+0x310],edi
  62c0af:	48 89 84 24 08 03 00 	mov    QWORD PTR [rsp+0x308],rax
  62c0b6:	00 
  62c0b7:	8b bc 24 10 03 00 00 	mov    edi,DWORD PTR [rsp+0x310]
  62c0be:	48 89 bc 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rdi
  62c0c5:	00 
  62c0c6:	48 8b bc 24 08 03 00 	mov    rdi,QWORD PTR [rsp+0x308]
  62c0cd:	00 
  62c0ce:	48 89 f8             	mov    rax,rdi
  62c0d1:	ba a0 09 00 00       	mov    edx,0x9a0
  62c0d6:	b9 18 00 00 00       	mov    ecx,0x18
  62c0db:	be 00 00 00 00       	mov    esi,0x0
  62c0e0:	e8 aa 15 00 00       	call   0x62d68f
  62c0e5:	48 89 c5             	mov    rbp,rax
  62c0e8:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  62c0ec:	8b bc 24 58 03 00 00 	mov    edi,DWORD PTR [rsp+0x358]
  62c0f3:	39 c7                	cmp    edi,eax
  62c0f5:	0f 82 05 00 00 00    	jb     0x62c100
  62c0fb:	e9 6a 16 00 00       	jmp    0x62d76a
  62c100:	8b 7d 10             	mov    edi,DWORD PTR [rbp+0x10]
  62c103:	48 89 f8             	mov    rax,rdi
  62c106:	8b bc 24 10 03 00 00 	mov    edi,DWORD PTR [rsp+0x310]
  62c10d:	89 f9                	mov    ecx,edi
  62c10f:	ba 3d 23 00 00       	mov    edx,0x233d
  62c114:	be 00 00 00 00       	mov    esi,0x0
  62c119:	e8 87 10 00 00       	call   0x62d1a5
  62c11e:	8b 04 20             	mov    eax,DWORD PTR [rax+riz*1]
  62c121:	48 89 84 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rax
  62c128:	00 
  62c129:	48 8b bc 24 58 03 00 	mov    rdi,QWORD PTR [rsp+0x358]
  62c130:	00 
  62c131:	48 89 bc 24 d8 00 00 	mov    QWORD PTR [rsp+0xd8],rdi
  62c138:	00 
  62c139:	bf 00 00 00 00       	mov    edi,0x0
  62c13e:	89 bc 24 e0 00 00 00 	mov    DWORD PTR [rsp+0xe0],edi
  62c145:	89 bc 24 c0 02 00 00 	mov    DWORD PTR [rsp+0x2c0],edi
  62c14c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
  62c150:	8b bc 24 c0 02 00 00 	mov    edi,DWORD PTR [rsp+0x2c0]
  62c157:	89 bc 24 e8 00 00 00 	mov    DWORD PTR [rsp+0xe8],edi
  62c15e:	8b b4 24 d0 00 00 00 	mov    esi,DWORD PTR [rsp+0xd0]
  62c165:	89 b4 24 00 03 00 00 	mov    DWORD PTR [rsp+0x300],esi
  62c16c:	89 bc 24 f8 02 00 00 	mov    DWORD PTR [rsp+0x2f8],edi
  62c173:	8b bc 24 f8 02 00 00 	mov    edi,DWORD PTR [rsp+0x2f8]
  62c17a:	8b b4 24 00 03 00 00 	mov    esi,DWORD PTR [rsp+0x300]
  62c181:	39 f7                	cmp    edi,esi
  62c183:	0f 83 52 09 00 00    	jae    0x62cadb
  62c189:	48 8b 7c 24 10       	mov    rdi,QWORD PTR [rsp+0x10]
  62c18e:	48 89 f8             	mov    rax,rdi
  62c191:	ba 1a 0e 00 00       	mov    edx,0xe1a
  62c196:	b9 1c 00 00 00       	mov    ecx,0x1c
  62c19b:	be 00 00 00 00       	mov    esi,0x0
  62c1a0:	e8 ea 14 00 00       	call   0x62d68f
  62c1a5:	8b 40 18             	mov    eax,DWORD PTR [rax+0x18]
  62c1a8:	8b bc 24 e8 00 00 00 	mov    edi,DWORD PTR [rsp+0xe8]
  62c1af:	89 bc 24 10 03 00 00 	mov    DWORD PTR [rsp+0x310],edi
  62c1b6:	48 89 84 24 08 03 00 	mov    QWORD PTR [rsp+0x308],rax
  62c1bd:	00 
  62c1be:	8b bc 24 10 03 00 00 	mov    edi,DWORD PTR [rsp+0x310]
  62c1c5:	48 89 bc 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rdi
  62c1cc:	00 
  62c1cd:	48 8b bc 24 08 03 00 	mov    rdi,QWORD PTR [rsp+0x308]
  62c1d4:	00 
  62c1d5:	48 89 f8             	mov    rax,rdi
  62c1d8:	ba a0 09 00 00       	mov    edx,0x9a0
  62c1dd:	b9 18 00 00 00       	mov    ecx,0x18
  62c1e2:	be 00 00 00 00       	mov    esi,0x0
  62c1e7:	e8 a3 14 00 00       	call   0x62d68f
  62c1ec:	48 89 c5             	mov    rbp,rax
  62c1ef:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  62c1f3:	8b bc 24 58 03 00 00 	mov    edi,DWORD PTR [rsp+0x358]
  62c1fa:	39 c7                	cmp    edi,eax
  62c1fc:	0f 82 05 00 00 00    	jb     0x62c207
  62c202:	e9 63 15 00 00       	jmp    0x62d76a
  62c207:	8b 7d 10             	mov    edi,DWORD PTR [rbp+0x10]
  62c20a:	48 89 f8             	mov    rax,rdi
  62c20d:	8b bc 24 10 03 00 00 	mov    edi,DWORD PTR [rsp+0x310]
  62c214:	89 f9                	mov    ecx,edi
  62c216:	ba 3d 23 00 00       	mov    edx,0x233d
  62c21b:	be 00 00 00 00       	mov    esi,0x0
  62c220:	e8 80 0f 00 00       	call   0x62d1a5
  62c225:	8b 04 20             	mov    eax,DWORD PTR [rax+riz*1]
  62c228:	48 89 84 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rax
  62c22f:	00 
  62c230:	48 8b bc 24 58 03 00 	mov    rdi,QWORD PTR [rsp+0x358]
  62c237:	00 
  62c238:	48 89 bc 24 f0 00 00 	mov    QWORD PTR [rsp+0xf0],rdi
  62c23f:	00 
  62c240:	48 8b bc 24 f0 00 00 	mov    rdi,QWORD PTR [rsp+0xf0]
  62c247:	00 
  62c248:	48 89 f8             	mov    rax,rdi
  62c24b:	ba fe 0d 00 00       	mov    edx,0xdfe
  62c250:	b9 1c 00 00 00       	mov    ecx,0x1c
  62c255:	be 00 00 00 00       	mov    esi,0x0
  62c25a:	e8 30 14 00 00       	call   0x62d68f
  62c25f:	8b 40 18             	mov    eax,DWORD PTR [rax+0x18]
  62c262:	48 89 84 24 b0 02 00 	mov    QWORD PTR [rsp+0x2b0],rax
  62c269:	00 
  62c26a:	48 8b bc 24 b0 02 00 	mov    rdi,QWORD PTR [rsp+0x2b0]
  62c271:	00 
  62c272:	48 89 f8             	mov    rax,rdi
  62c275:	ba fa 0d 00 00       	mov    edx,0xdfa
  62c27a:	b9 00 00 00 00       	mov    ecx,0x0
  62c27f:	be 18 00 00 00       	mov    esi,0x18
  62c284:	e8 68 11 00 00       	call   0x62d3f1
  62c289:	85 c0                	test   eax,eax
  62c28b:	0f 84 94 00 00 00    	je     0x62c325
  62c291:	48 8b 7c 22 10       	mov    rdi,QWORD PTR [rdx+riz*1+0x10]
  62c296:	48 89 bc 24 f8 00 00 	mov    QWORD PTR [rsp+0xf8],rdi
  62c29d:	00 
  62c29e:	48 8b bc 24 d8 00 00 	mov    rdi,QWORD PTR [rsp+0xd8]
  62c2a5:	00 
  62c2a6:	48 89 f8             	mov    rax,rdi
  62c2a9:	ba fe 0d 00 00       	mov    edx,0xdfe
  62c2ae:	b9 1c 00 00 00       	mov    ecx,0x1c
  62c2b3:	be 00 00 00 00       	mov    esi,0x0
  62c2b8:	e8 d2 13 00 00       	call   0x62d68f
  62c2bd:	8b 40 18             	mov    eax,DWORD PTR [rax+0x18]
  62c2c0:	48 89 84 24 a8 02 00 	mov    QWORD PTR [rsp+0x2a8],rax
  62c2c7:	00 
  62c2c8:	48 8b bc 24 a8 02 00 	mov    rdi,QWORD PTR [rsp+0x2a8]
  62c2cf:	00 
  62c2d0:	48 89 f8             	mov    rax,rdi
  62c2d3:	ba fa 0d 00 00       	mov    edx,0xdfa
  62c2d8:	b9 00 00 00 00       	mov    ecx,0x0
  62c2dd:	be 18 00 00 00       	mov    esi,0x18
  62c2e2:	e8 0a 11 00 00       	call   0x62d3f1
  62c2e7:	85 c0                	test   eax,eax
  62c2e9:	0f 84 2c 00 00 00    	je     0x62c31b
  62c2ef:	48 8b 7c 22 10       	mov    rdi,QWORD PTR [rdx+riz*1+0x10]
  62c2f4:	48 89 bc 24 00 01 00 	mov    QWORD PTR [rsp+0x100],rdi
  62c2fb:	00 
  62c2fc:	48 8b 84 24 f8 00 00 	mov    rax,QWORD PTR [rsp+0xf8]
  62c303:	00 
  62c304:	48 8b 8c 24 00 01 00 	mov    rcx,QWORD PTR [rsp+0x100]
  62c30b:	00 
  62c30c:	e8 7c 53 9d ff       	call   0x168d
  62c311:	48 89 c7             	mov    rdi,rax
  62c314:	89 fd                	mov    ebp,edi
  62c316:	e9 05 00 00 00       	jmp    0x62c320
  62c31b:	bd 00 00 00 00       	mov    ebp,0x0
  62c320:	e9 05 00 00 00       	jmp    0x62c32a
  62c325:	bd 00 00 00 00       	mov    ebp,0x0
  62c32a:	89 ac 24 08 01 00 00 	mov    DWORD PTR [rsp+0x108],ebp
  62c331:	48 8b bc 24 f0 00 00 	mov    rdi,QWORD PTR [rsp+0xf0]
  62c338:	00 
  62c339:	48 89 f8             	mov    rax,rdi
  62c33c:	ba fe 0d 00 00       	mov    edx,0xdfe
  62c341:	b9 30 00 00 00       	mov    ecx,0x30
  62c346:	be 00 00 00 00       	mov    esi,0x0
  62c34b:	e8 3f 13 00 00       	call   0x62d68f
  62c350:	8b 44 20 2c          	mov    eax,DWORD PTR [rax+riz*1+0x2c]
  62c354:	85 c0                	test   eax,eax
  62c356:	0f 84 2a 00 00 00    	je     0x62c386
  62c35c:	48 8b bc 24 f0 00 00 	mov    rdi,QWORD PTR [rsp+0xf0]
  62c363:	00 
  62c364:	48 89 f8             	mov    rax,rdi
  62c367:	ba fe 0d 00 00       	mov    edx,0xdfe
  62c36c:	b9 34 00 00 00       	mov    ecx,0x34
  62c371:	be 00 00 00 00       	mov    esi,0x0
  62c376:	e8 14 13 00 00       	call   0x62d68f
  62c37b:	8b 44 20 30          	mov    eax,DWORD PTR [rax+riz*1+0x30]
  62c37f:	89 c5                	mov    ebp,eax
  62c381:	e9 05 00 00 00       	jmp    0x62c38b
  62c386:	bd 00 00 00 00       	mov    ebp,0x0
  62c38b:	85 ed                	test   ebp,ebp
  62c38d:	0f 84 2a 00 00 00    	je     0x62c3bd
  62c393:	48 8b bc 24 d8 00 00 	mov    rdi,QWORD PTR [rsp+0xd8]
  62c39a:	00 
  62c39b:	48 89 f8             	mov    rax,rdi
  62c39e:	ba fe 0d 00 00       	mov    edx,0xdfe
  62c3a3:	b9 30 00 00 00       	mov    ecx,0x30
  62c3a8:	be 00 00 00 00       	mov    esi,0x0
  62c3ad:	e8 dd 12 00 00       	call   0x62d68f
  62c3b2:	8b 44 20 2c          	mov    eax,DWORD PTR [rax+riz*1+0x2c]
  62c3b6:	89 c5                	mov    ebp,eax
  62c3b8:	e9 05 00 00 00       	jmp    0x62c3c2
  62c3bd:	bd 00 00 00 00       	mov    ebp,0x0
  62c3c2:	85 ed                	test   ebp,ebp
  62c3c4:	0f 84 2a 00 00 00    	je     0x62c3f4
  62c3ca:	48 8b bc 24 d8 00 00 	mov    rdi,QWORD PTR [rsp+0xd8]
  62c3d1:	00 
  62c3d2:	48 89 f8             	mov    rax,rdi
  62c3d5:	ba fe 0d 00 00       	mov    edx,0xdfe
  62c3da:	b9 34 00 00 00       	mov    ecx,0x34
  62c3df:	be 00 00 00 00       	mov    esi,0x0
  62c3e4:	e8 a6 12 00 00       	call   0x62d68f
  62c3e9:	8b 44 20 30          	mov    eax,DWORD PTR [rax+riz*1+0x30]
  62c3ed:	89 c5                	mov    ebp,eax
  62c3ef:	e9 05 00 00 00       	jmp    0x62c3f9
  62c3f4:	bd 00 00 00 00       	mov    ebp,0x0
  62c3f9:	85 ed                	test   ebp,ebp
  62c3fb:	0f 84 0c 00 00 00    	je     0x62c40d
  62c401:	8b ac 24 08 01 00 00 	mov    ebp,DWORD PTR [rsp+0x108]
  62c408:	e9 05 00 00 00       	jmp    0x62c412
  62c40d:	bd 00 00 00 00       	mov    ebp,0x0
  62c412:	85 ed                	test   ebp,ebp
  62c414:	0f 84 69 00 00 00    	je     0x62c483
  62c41a:	48 8b bc 24 f0 00 00 	mov    rdi,QWORD PTR [rsp+0xf0]
  62c421:	00 
  62c422:	48 89 f8             	mov    rax,rdi
  62c425:	ba fe 0d 00 00       	mov    edx,0xdfe
  62c42a:	b9 20 00 00 00       	mov    ecx,0x20
  62c42f:	be 00 00 00 00       	mov    esi,0x0
  62c434:	e8 56 12 00 00       	call   0x62d68f
  62c439:	8b 40 1c             	mov    eax,DWORD PTR [rax+0x1c]
  62c43c:	48 89 84 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rax
  62c443:	00 
  62c444:	48 8b bc 24 d8 00 00 	mov    rdi,QWORD PTR [rsp+0xd8]
  62c44b:	00 
  62c44c:	48 89 f8             	mov    rax,rdi
  62c44f:	ba fe 0d 00 00       	mov    edx,0xdfe
  62c454:	b9 20 00 00 00       	mov    ecx,0x20
  62c459:	be 00 00 00 00       	mov    esi,0x0
  62c45e:	e8 2c 12 00 00       	call   0x62d68f
  62c463:	8b 40 1c             	mov    eax,DWORD PTR [rax+0x1c]
  62c466:	48 8b bc 24 58 03 00 	mov    rdi,QWORD PTR [rsp+0x358]
  62c46d:	00 
  62c46e:	48 89 c1             	mov    rcx,rax
  62c471:	48 89 f8             	mov    rax,rdi
  62c474:	e8 77 f5 fd ff       	call   0x60b9f0
  62c479:	48 89 c7             	mov    rdi,rax
  62c47c:	89 fd                	mov    ebp,edi
  62c47e:	e9 05 00 00 00       	jmp    0x62c488
  62c483:	bd 00 00 00 00       	mov    ebp,0x0
  62c488:	85 ed                	test   ebp,ebp
  62c48a:	0f 84 28 00 00 00    	je     0x62c4b8
  62c490:	48 8b 04 24          	mov    rax,QWORD PTR [rsp]
  62c494:	48 8b 4c 24 08       	mov    rcx,QWORD PTR [rsp+0x8]
  62c499:	48 8b 94 24 f0 00 00 	mov    rdx,QWORD PTR [rsp+0xf0]
  62c4a0:	00 
  62c4a1:	4c 8b 84 24 d8 00 00 	mov    r8,QWORD PTR [rsp+0xd8]
  62c4a8:	00 
  62c4a9:	e8 22 98 fe ff       	call   0x615cd0
  62c4ae:	48 89 c7             	mov    rdi,rax
  62c4b1:	89 fd                	mov    ebp,edi
  62c4b3:	e9 05 00 00 00       	jmp    0x62c4bd
  62c4b8:	bd 00 00 00 00       	mov    ebp,0x0
  62c4bd:	85 ed                	test   ebp,ebp
  62c4bf:	0f 84 00 06 00 00    	je     0x62cac5
  62c4c5:	48 8b 04 24          	mov    rax,QWORD PTR [rsp]
  62c4c9:	48 8b 4c 24 08       	mov    rcx,QWORD PTR [rsp+0x8]
  62c4ce:	48 8b 94 24 f0 00 00 	mov    rdx,QWORD PTR [rsp+0xf0]
  62c4d5:	00 
  62c4d6:	4c 8b 84 24 d8 00 00 	mov    r8,QWORD PTR [rsp+0xd8]
  62c4dd:	00 
  62c4de:	e8 4d aa fe ff       	call   0x616f30
  62c4e3:	48 89 c7             	mov    rdi,rax
  62c4e6:	89 bc 24 10 01 00 00 	mov    DWORD PTR [rsp+0x110],edi
  62c4ed:	48 8b 04 24          	mov    rax,QWORD PTR [rsp]
  62c4f1:	48 8b 4c 24 08       	mov    rcx,QWORD PTR [rsp+0x8]
  62c4f6:	48 8b 94 24 d8 00 00 	mov    rdx,QWORD PTR [rsp+0xd8]
  62c4fd:	00 
  62c4fe:	4c 8b 84 24 f0 00 00 	mov    r8,QWORD PTR [rsp+0xf0]
  62c505:	00 
  62c506:	e8 25 aa fe ff       	call   0x616f30
  62c50b:	48 89 c7             	mov    rdi,rax
  62c50e:	89 bc 24 18 01 00 00 	mov    DWORD PTR [rsp+0x118],edi
  62c515:	8b bc 24 10 01 00 00 	mov    edi,DWORD PTR [rsp+0x110]
  62c51c:	48 89 bc 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rdi
  62c523:	00 
  62c524:	8b bc 24 58 03 00 00 	mov    edi,DWORD PTR [rsp+0x358]
  62c52b:	85 ff                	test   edi,edi
  62c52d:	0f 84 16 00 00 00    	je     0x62c549
  62c533:	8b bc 24 18 01 00 00 	mov    edi,DWORD PTR [rsp+0x118]
  62c53a:	85 ff                	test   edi,edi
  62c53c:	40 0f 94 c5          	sete   bpl
  62c540:	40 0f b6 ed          	movzx  ebp,bpl
  62c544:	e9 05 00 00 00       	jmp    0x62c54e
  62c549:	bd 00 00 00 00       	mov    ebp,0x0
  62c54e:	85 ed                	test   ebp,ebp
  62c550:	0f 84 30 00 00 00    	je     0x62c586
  62c556:	48 8b 7c 24 10       	mov    rdi,QWORD PTR [rsp+0x10]
  62c55b:	48 89 f8             	mov    rax,rdi
  62c55e:	ba 1a 0e 00 00       	mov    edx,0xe1a
  62c563:	b9 1c 00 00 00       	mov    ecx,0x1c
  62c568:	be 00 00 00 00       	mov    esi,0x0
  62c56d:	e8 1d 11 00 00       	call   0x62d68f
  62c572:	8b 40 18             	mov    eax,DWORD PTR [rax+0x18]
  62c575:	8b 8c 24 d0 00 00 00 	mov    ecx,DWORD PTR [rsp+0xd0]
  62c57c:	e8 3f d9 fe ff       	call   0x619ec0
  62c581:	e9 3a 05 00 00       	jmp    0x62cac0
  62c586:	8b bc 24 18 01 00 00 	mov    edi,DWORD PTR [rsp+0x118]
  62c58d:	48 89 bc 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rdi
  62c594:	00 
  62c595:	8b bc 24 58 03 00 00 	mov    edi,DWORD PTR [rsp+0x358]
  62c59c:	85 ff                	test   edi,edi
  62c59e:	0f 84 16 00 00 00    	je     0x62c5ba
  62c5a4:	8b bc 24 10 01 00 00 	mov    edi,DWORD PTR [rsp+0x110]
  62c5ab:	85 ff                	test   edi,edi
  62c5ad:	40 0f 94 c5          	sete   bpl
  62c5b1:	40 0f b6 ed          	movzx  ebp,bpl
  62c5b5:	e9 05 00 00 00       	jmp    0x62c5bf
  62c5ba:	bd 00 00 00 00       	mov    ebp,0x0
  62c5bf:	85 ed                	test   ebp,ebp
  62c5c1:	0f 84 30 00 00 00    	je     0x62c5f7
  62c5c7:	48 8b 7c 24 10       	mov    rdi,QWORD PTR [rsp+0x10]
  62c5cc:	48 89 f8             	mov    rax,rdi
  62c5cf:	ba 1a 0e 00 00       	mov    edx,0xe1a
  62c5d4:	b9 1c 00 00 00       	mov    ecx,0x1c
  62c5d9:	be 00 00 00 00       	mov    esi,0x0
  62c5de:	e8 ac 10 00 00       	call   0x62d68f
  62c5e3:	8b 40 18             	mov    eax,DWORD PTR [rax+0x18]
  62c5e6:	8b 8c 24 e8 00 00 00 	mov    ecx,DWORD PTR [rsp+0xe8]
  62c5ed:	e8 ce d8 fe ff       	call   0x619ec0
  62c5f2:	e9 c9 04 00 00       	jmp    0x62cac0
  62c5f7:	48 8b 7c 24 10       	mov    rdi,QWORD PTR [rsp+0x10]
  62c5fc:	48 89 f8             	mov    rax,rdi
  62c5ff:	ba 1a 0e 00 00       	mov    edx,0xe1a
  62c604:	b9 1c 00 00 00       	mov    ecx,0x1c
  62c609:	be 00 00 00 00       	mov    esi,0x0
  62c60e:	e8 7c 10 00 00       	call   0x62d68f
  62c613:	8b 40 18             	mov    eax,DWORD PTR [rax+0x18]
  62c616:	8b 8c 24 e8 00 00 00 	mov    ecx,DWORD PTR [rsp+0xe8]
  62c61d:	e8 ce ce fe ff       	call   0x6194f0
  62c622:	48 8b 7c 24 10       	mov    rdi,QWORD PTR [rsp+0x10]
  62c627:	48 89 f8             	mov    rax,rdi
  62c62a:	ba 1a 0e 00 00       	mov    edx,0xe1a
  62c62f:	b9 1c 00 00 00       	mov    ecx,0x1c
  62c634:	be 00 00 00 00       	mov    esi,0x0
  62c639:	e8 51 10 00 00       	call   0x62d68f
  62c63e:	8b 40 18             	mov    eax,DWORD PTR [rax+0x18]
  62c641:	8b 8c 24 d0 00 00 00 	mov    ecx,DWORD PTR [rsp+0xd0]
  62c648:	e8 a3 ce fe ff       	call   0x6194f0
  62c64d:	48 8b bc 24 d8 00 00 	mov    rdi,QWORD PTR [rsp+0xd8]
  62c654:	00 
  62c655:	48 89 f8             	mov    rax,rdi
  62c658:	ba fe 0d 00 00       	mov    edx,0xdfe
  62c65d:	b9 1c 00 00 00       	mov    ecx,0x1c
  62c662:	be 00 00 00 00       	mov    esi,0x0
  62c667:	e8 23 10 00 00       	call   0x62d68f
  62c66c:	8b 40 18             	mov    eax,DWORD PTR [rax+0x18]
  62c66f:	48 89 84 24 b8 02 00 	mov    QWORD PTR [rsp+0x2b8],rax
  62c676:	00 
  62c677:	48 8b bc 24 b8 02 00 	mov    rdi,QWORD PTR [rsp+0x2b8]
  62c67e:	00 
  62c67f:	48 89 f8             	mov    rax,rdi
  62c682:	ba fa 0d 00 00       	mov    edx,0xdfa
  62c687:	b9 00 00 00 00       	mov    ecx,0x0
  62c68c:	be 18 00 00 00       	mov    esi,0x18
  62c691:	e8 5b 0d 00 00       	call   0x62d3f1
  62c696:	85 c0                	test   eax,eax
  62c698:	0f 84 1a 00 00 00    	je     0x62c6b8
  62c69e:	48 8b 7c 22 10       	mov    rdi,QWORD PTR [rdx+riz*1+0x10]
  62c6a3:	48 89 bc 24 20 01 00 	mov    QWORD PTR [rsp+0x120],rdi
  62c6aa:	00 
  62c6ab:	48 8b ac 24 20 01 00 	mov    rbp,QWORD PTR [rsp+0x120]
  62c6b2:	00 
  62c6b3:	e9 05 00 00 00       	jmp    0x62c6bd
  62c6b8:	bd 00 00 00 00       	mov    ebp,0x0
  62c6bd:	48 89 ac 24 28 01 00 	mov    QWORD PTR [rsp+0x128],rbp
  62c6c4:	00 
  62c6c5:	48 8b 7c 24 10       	mov    rdi,QWORD PTR [rsp+0x10]
  62c6ca:	48 89 f8             	mov    rax,rdi
  62c6cd:	ba 1a 0e 00 00       	mov    edx,0xe1a
  62c6d2:	b9 2c 00 00 00       	mov    ecx,0x2c
  62c6d7:	be 00 00 00 00       	mov    esi,0x0
  62c6dc:	e8 ae 0f 00 00       	call   0x62d68f
  62c6e1:	8b 40 28             	mov    eax,DWORD PTR [rax+0x28]
  62c6e4:	48 89 84 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rax
  62c6eb:	00 
  62c6ec:	48 8b bc 24 d8 00 00 	mov    rdi,QWORD PTR [rsp+0xd8]
  62c6f3:	00 
  62c6f4:	48 89 f8             	mov    rax,rdi
  62c6f7:	ba fe 0d 00 00       	mov    edx,0xdfe
  62c6fc:	b9 18 00 00 00       	mov    ecx,0x18
  62c701:	be 00 00 00 00       	mov    esi,0x0
  62c706:	e8 84 0f 00 00       	call   0x62d68f
  62c70b:	48 8b 44 20 10       	mov    rax,QWORD PTR [rax+riz*1+0x10]
  62c710:	48 89 84 24 60 03 00 	mov    QWORD PTR [rsp+0x360],rax
  62c717:	00 
  62c718:	48 8b bc 24 f0 00 00 	mov    rdi,QWORD PTR [rsp+0xf0]
  62c71f:	00 
  62c720:	48 89 f8             	mov    rax,rdi
  62c723:	ba fe 0d 00 00       	mov    edx,0xdfe
  62c728:	b9 18 00 00 00       	mov    ecx,0x18
  62c72d:	be 00 00 00 00       	mov    esi,0x0
  62c732:	e8 58 0f 00 00       	call   0x62d68f
  62c737:	48 8b 44 20 10       	mov    rax,QWORD PTR [rax+riz*1+0x10]
  62c73c:	48 89 84 24 68 03 00 	mov    QWORD PTR [rsp+0x368],rax
  62c743:	00 
  62c744:	48 8b bc 24 28 01 00 	mov    rdi,QWORD PTR [rsp+0x128]
  62c74b:	00 
  62c74c:	48 89 bc 24 70 03 00 	mov    QWORD PTR [rsp+0x370],rdi
  62c753:	00 
  62c754:	48 8b bc 24 d8 00 00 	mov    rdi,QWORD PTR [rsp+0xd8]
  62c75b:	00 
  62c75c:	48 89 f8             	mov    rax,rdi
  62c75f:	ba fe 0d 00 00       	mov    edx,0xdfe
  62c764:	b9 20 00 00 00       	mov    ecx,0x20
  62c769:	be 00 00 00 00       	mov    esi,0x0
  62c76e:	e8 1c 0f 00 00       	call   0x62d68f
  62c773:	8b 40 1c             	mov    eax,DWORD PTR [rax+0x1c]
  62c776:	ba ef 0d 00 00       	mov    edx,0xdef
  62c77b:	b9 00 00 00 00       	mov    ecx,0x0
  62c780:	be 00 00 00 00       	mov    esi,0x0
  62c785:	e8 27 0b 00 00       	call   0x62d2b1
  62c78a:	48 89 84 24 78 03 00 	mov    QWORD PTR [rsp+0x378],rax
  62c791:	00 
  62c792:	bf 00 00 00 00       	mov    edi,0x0
  62c797:	48 89 bc 24 80 03 00 	mov    QWORD PTR [rsp+0x380],rdi
  62c79e:	00 
  62c79f:	bf 07 0e 00 00       	mov    edi,0xe07
  62c7a4:	48 89 bc 24 88 03 00 	mov    QWORD PTR [rsp+0x388],rdi
  62c7ab:	00 
  62c7ac:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  62c7b0:	48 8b 84 24 60 03 00 	mov    rax,QWORD PTR [rsp+0x360]
  62c7b7:	00 
  62c7b8:	49 89 40 48          	mov    QWORD PTR [r8+0x48],rax
  62c7bc:	48 8b 84 24 68 03 00 	mov    rax,QWORD PTR [rsp+0x368]
  62c7c3:	00 
  62c7c4:	49 89 40 50          	mov    QWORD PTR [r8+0x50],rax
  62c7c8:	48 8b 84 24 70 03 00 	mov    rax,QWORD PTR [rsp+0x370]
  62c7cf:	00 
  62c7d0:	49 89 40 58          	mov    QWORD PTR [r8+0x58],rax
  62c7d4:	48 8b 84 24 78 03 00 	mov    rax,QWORD PTR [rsp+0x378]
  62c7db:	00 
  62c7dc:	49 89 40 60          	mov    QWORD PTR [r8+0x60],rax
  62c7e0:	8b 84 24 80 03 00 00 	mov    eax,DWORD PTR [rsp+0x380]
  62c7e7:	49 89 40 68          	mov    QWORD PTR [r8+0x68],rax
  62c7eb:	8b 84 24 88 03 00 00 	mov    eax,DWORD PTR [rsp+0x388]
  62c7f2:	49 89 40 70          	mov    QWORD PTR [r8+0x70],rax
  62c7f6:	41 54                	push   r12
  62c7f8:	41 50                	push   r8
  62c7fa:	4c 89 c7             	mov    rdi,r8
  62c7fd:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  62c804:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  62c808:	41 8b 92 1c 38 00 00 	mov    edx,DWORD PTR [r10+0x381c]
  62c80f:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  62c813:	41 83 b8 a0 00 00 00 	cmp    DWORD PTR [r8+0xa0],0x30
  62c81a:	30 
  62c81b:	0f 86 55 02 00 00    	jbe    0x62ca76
  62c821:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  62c828:	4d 85 d2             	test   r10,r10
  62c82b:	0f 84 45 02 00 00    	je     0x62ca76
  62c831:	41 8b 4a 04          	mov    ecx,DWORD PTR [r10+0x4]
  62c835:	41 8b 42 08          	mov    eax,DWORD PTR [r10+0x8]
  62c839:	81 f8 00 02 00 00    	cmp    eax,0x200
  62c83f:	0f 87 31 02 00 00    	ja     0x62ca76
  62c845:	39 c1                	cmp    ecx,eax
  62c847:	0f 83 29 02 00 00    	jae    0x62ca76
  62c84d:	49 8d 44 8a 20       	lea    rax,[r10+rcx*4+0x20]
  62c852:	8b 30                	mov    esi,DWORD PTR [rax]
  62c854:	89 f0                	mov    eax,esi
  62c856:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  62c85a:	48 c1 e0 04          	shl    rax,0x4
  62c85e:	49 01 c1             	add    r9,rax
  62c861:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  62c868:	48 85 c0             	test   rax,rax
  62c86b:	0f 84 05 02 00 00    	je     0x62ca76
  62c871:	8b 08                	mov    ecx,DWORD PTR [rax]
  62c873:	83 c1 07             	add    ecx,0x7
  62c876:	83 e1 f8             	and    ecx,0xfffffff8
  62c879:	41 8b 40 7c          	mov    eax,DWORD PTR [r8+0x7c]
  62c87d:	39 c1                	cmp    ecx,eax
  62c87f:	0f 87 f1 01 00 00    	ja     0x62ca76
  62c885:	29 c8                	sub    eax,ecx
  62c887:	83 f8 30             	cmp    eax,0x30
  62c88a:	0f 82 e6 01 00 00    	jb     0x62ca76
  62c890:	4d 8b 58 28          	mov    r11,QWORD PTR [r8+0x28]
  62c894:	4d 85 db             	test   r11,r11
  62c897:	0f 84 d9 01 00 00    	je     0x62ca76
  62c89d:	49 01 cb             	add    r11,rcx
  62c8a0:	49 8b 80 98 00 00 00 	mov    rax,QWORD PTR [r8+0x98]
  62c8a7:	48 85 c0             	test   rax,rax
  62c8aa:	0f 84 c6 01 00 00    	je     0x62ca76
  62c8b0:	41 89 cc             	mov    r12d,ecx
  62c8b3:	8b 47 60             	mov    eax,DWORD PTR [rdi+0x60]
  62c8b6:	85 c0                	test   eax,eax
  62c8b8:	0f 84 b8 01 00 00    	je     0x62ca76
  62c8be:	89 c2                	mov    edx,eax
  62c8c0:	83 e2 01             	and    edx,0x1
  62c8c3:	85 d2                	test   edx,edx
  62c8c5:	0f 85 ab 01 00 00    	jne    0x62ca76
  62c8cb:	d1 e8                	shr    eax,1
  62c8cd:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  62c8d1:	0f 83 9f 01 00 00    	jae    0x62ca76
  62c8d7:	4d 8b 50 08          	mov    r10,QWORD PTR [r8+0x8]
  62c8db:	48 c1 e0 04          	shl    rax,0x4
  62c8df:	49 01 c2             	add    r10,rax
  62c8e2:	41 8b 42 0c          	mov    eax,DWORD PTR [r10+0xc]
  62c8e6:	c1 e8 10             	shr    eax,0x10
  62c8e9:	81 e0 ff 00 00 00    	and    eax,0xff
  62c8ef:	85 c0                	test   eax,eax
  62c8f1:	0f 84 7f 01 00 00    	je     0x62ca76
  62c8f7:	83 f8 04             	cmp    eax,0x4
  62c8fa:	0f 87 76 01 00 00    	ja     0x62ca76
  62c900:	48 6b c0 10          	imul   rax,rax,0x10
  62c904:	4c 01 c0             	add    rax,r8
  62c907:	8b 50 20             	mov    edx,DWORD PTR [rax+0x20]
  62c90a:	41 8b 0a             	mov    ecx,DWORD PTR [r10]
  62c90d:	39 d1                	cmp    ecx,edx
  62c90f:	0f 83 61 01 00 00    	jae    0x62ca76
  62c915:	29 ca                	sub    edx,ecx
  62c917:	45 8b 52 04          	mov    r10d,DWORD PTR [r10+0x4]
  62c91b:	41 39 d2             	cmp    r10d,edx
  62c91e:	0f 87 52 01 00 00    	ja     0x62ca76
  62c924:	41 83 fa 10          	cmp    r10d,0x10
  62c928:	0f 82 48 01 00 00    	jb     0x62ca76
  62c92e:	48 8b 40 18          	mov    rax,QWORD PTR [rax+0x18]
  62c932:	48 85 c0             	test   rax,rax
  62c935:	0f 84 3b 01 00 00    	je     0x62ca76
  62c93b:	48 01 c8             	add    rax,rcx
  62c93e:	8b 00                	mov    eax,DWORD PTR [rax]
  62c940:	48 8b 93 e8 fe ff ff 	mov    rdx,QWORD PTR [rbx-0x118]
  62c947:	48 8b 52 10          	mov    rdx,QWORD PTR [rdx+0x10]
  62c94b:	8b 92 bc 37 00 00    	mov    edx,DWORD PTR [rdx+0x37bc]
  62c951:	41 89 c2             	mov    r10d,eax
  62c954:	45 3b 90 a4 00 00 00 	cmp    r10d,DWORD PTR [r8+0xa4]
  62c95b:	0f 83 15 01 00 00    	jae    0x62ca76
  62c961:	41 89 d2             	mov    r10d,edx
  62c964:	45 3b 90 a4 00 00 00 	cmp    r10d,DWORD PTR [r8+0xa4]
  62c96b:	0f 83 05 01 00 00    	jae    0x62ca76
  62c971:	4d 8b 90 a8 00 00 00 	mov    r10,QWORD PTR [r8+0xa8]
  62c978:	4d 85 d2             	test   r10,r10
  62c97b:	0f 84 f5 00 00 00    	je     0x62ca76
  62c981:	48 6b c0 08          	imul   rax,rax,0x8
  62c985:	49 8b 04 02          	mov    rax,QWORD PTR [r10+rax*1]
  62c989:	48 6b d2 08          	imul   rdx,rdx,0x8
  62c98d:	49 8b 14 12          	mov    rdx,QWORD PTR [r10+rdx*1]
  62c991:	48 89 c1             	mov    rcx,rax
  62c994:	48 c1 e9 20          	shr    rcx,0x20
  62c998:	49 89 d2             	mov    r10,rdx
  62c99b:	49 c1 ea 20          	shr    r10,0x20
  62c99f:	44 39 d1             	cmp    ecx,r10d
  62c9a2:	0f 82 ce 00 00 00    	jb     0x62ca76
  62c9a8:	39 d0                	cmp    eax,edx
  62c9aa:	0f 87 c6 00 00 00    	ja     0x62ca76
  62c9b0:	44 89 e1             	mov    ecx,r12d
  62c9b3:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  62c9ba:	41 8b 52 04          	mov    edx,DWORD PTR [r10+0x4]
  62c9be:	48 8b 83 e8 fe ff ff 	mov    rax,QWORD PTR [rbx-0x118]
  62c9c5:	48 8b 40 10          	mov    rax,QWORD PTR [rax+0x10]
  62c9c9:	8b 80 1c 38 00 00    	mov    eax,DWORD PTR [rax+0x381c]
  62c9cf:	41 89 03             	mov    DWORD PTR [r11],eax
  62c9d2:	41 c7 43 04 30 00 00 	mov    DWORD PTR [r11+0x4],0x30
  62c9d9:	00 
  62c9da:	41 c7 43 08 00 00 00 	mov    DWORD PTR [r11+0x8],0x0
  62c9e1:	00 
  62c9e2:	41 c7 43 0c 00 00 00 	mov    DWORD PTR [r11+0xc],0x0
  62c9e9:	00 
  62c9ea:	48 8b 47 48          	mov    rax,QWORD PTR [rdi+0x48]
  62c9ee:	49 89 43 10          	mov    QWORD PTR [r11+0x10],rax
  62c9f2:	48 8b 47 50          	mov    rax,QWORD PTR [rdi+0x50]
  62c9f6:	49 89 43 18          	mov    QWORD PTR [r11+0x18],rax
  62c9fa:	48 8b 47 58          	mov    rax,QWORD PTR [rdi+0x58]
  62c9fe:	49 89 43 20          	mov    QWORD PTR [r11+0x20],rax
  62ca02:	8b 47 60             	mov    eax,DWORD PTR [rdi+0x60]
  62ca05:	41 89 43 28          	mov    DWORD PTR [r11+0x28],eax
  62ca09:	8b 47 68             	mov    eax,DWORD PTR [rdi+0x68]
  62ca0c:	41 89 43 2c          	mov    DWORD PTR [r11+0x2c],eax
  62ca10:	41 89 09             	mov    DWORD PTR [r9],ecx
  62ca13:	41 c7 41 04 30 00 00 	mov    DWORD PTR [r9+0x4],0x30
  62ca1a:	00 
  62ca1b:	41 c7 41 08 00 00 00 	mov    DWORD PTR [r9+0x8],0x0
  62ca22:	00 
  62ca23:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  62ca2a:	41 89 ca             	mov    r10d,ecx
  62ca2d:	41 83 c2 30          	add    r10d,0x30
  62ca31:	44 89 10             	mov    DWORD PTR [rax],r10d
  62ca34:	41 c7 41 0c 00 00 01 	mov    DWORD PTR [r9+0xc],0x10000
  62ca3b:	00 
  62ca3c:	83 c2 01             	add    edx,0x1
  62ca3f:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  62ca46:	41 89 52 04          	mov    DWORD PTR [r10+0x4],edx
  62ca4a:	41 83 7a 18 00       	cmp    DWORD PTR [r10+0x18],0x0
  62ca4f:	0f 84 11 00 00 00    	je     0x62ca66
  62ca55:	4d 8b 90 98 00 00 00 	mov    r10,QWORD PTR [r8+0x98]
  62ca5c:	49 8b 02             	mov    rax,QWORD PTR [r10]
  62ca5f:	48 83 c0 01          	add    rax,0x1
  62ca63:	49 89 02             	mov    QWORD PTR [r10],rax
  62ca66:	89 f0                	mov    eax,esi
  62ca68:	d1 e0                	shl    eax,1
  62ca6a:	48 89 87 48 02 00 00 	mov    QWORD PTR [rdi+0x248],rax
  62ca71:	e9 05 00 00 00       	jmp    0x62ca7b
  62ca76:	b8 00 00 00 00       	mov    eax,0x0
  62ca7b:	85 c0                	test   eax,eax
  62ca7d:	41 58                	pop    r8
  62ca7f:	41 5c                	pop    r12
  62ca81:	0f 85 14 00 00 00    	jne    0x62ca9b
  62ca87:	41 c7 40 40 0b d5 15 	mov    DWORD PTR [r8+0x40],0x4015d50b
  62ca8e:	40 
  62ca8f:	41 c7 40 44 06 00 01 	mov    DWORD PTR [r8+0x44],0x10006
  62ca96:	00 
  62ca97:	41 ff 50 38          	call   QWORD PTR [r8+0x38]
  62ca9b:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  62ca9f:	49 8b b8 48 02 00 00 	mov    rdi,QWORD PTR [r8+0x248]
  62caa6:	4c 8b bb e0 fe ff ff 	mov    r15,QWORD PTR [rbx-0x120]
  62caad:	48 8b b4 24 58 03 00 	mov    rsi,QWORD PTR [rsp+0x358]
  62cab4:	00 
  62cab5:	48 89 f0             	mov    rax,rsi
  62cab8:	48 89 f9             	mov    rcx,rdi
  62cabb:	e8 40 a2 9d ff       	call   0x6d00
  62cac0:	e9 00 00 00 00       	jmp    0x62cac5
  62cac5:	8b bc 24 e8 00 00 00 	mov    edi,DWORD PTR [rsp+0xe8]
  62cacc:	83 c7 01             	add    edi,0x1
  62cacf:	89 bc 24 c0 02 00 00 	mov    DWORD PTR [rsp+0x2c0],edi
  62cad6:	e9 75 f6 ff ff       	jmp    0x62c150
  62cadb:	e9 00 00 00 00       	jmp    0x62cae0
  62cae0:	8b bc 24 d0 00 00 00 	mov    edi,DWORD PTR [rsp+0xd0]
  62cae7:	83 c7 01             	add    edi,0x1
  62caea:	89 bc 24 c8 02 00 00 	mov    DWORD PTR [rsp+0x2c8],edi
  62caf1:	e9 f2 f4 ff ff       	jmp    0x62bfe8
  62caf6:	e9 00 00 00 00       	jmp    0x62cafb
  62cafb:	b8 00 00 00 00       	mov    eax,0x0
  62cb00:	e8 77 7f 9d ff       	call   0x4a7c
  62cb05:	48 89 c7             	mov    rdi,rax
  62cb08:	48 89 bc 24 30 01 00 	mov    QWORD PTR [rsp+0x130],rdi
  62cb0f:	00 
  62cb10:	48 8b bc 24 30 01 00 	mov    rdi,QWORD PTR [rsp+0x130]
  62cb17:	00 
  62cb18:	48 89 bc 24 38 01 00 	mov    QWORD PTR [rsp+0x138],rdi
  62cb1f:	00 
  62cb20:	bf 00 00 00 00       	mov    edi,0x0
  62cb25:	89 bc 24 40 01 00 00 	mov    DWORD PTR [rsp+0x140],edi
  62cb2c:	89 bc 24 d0 02 00 00 	mov    DWORD PTR [rsp+0x2d0],edi
  62cb33:	66 0f 1f 84 00 00 00 	nop    WORD PTR [rax+rax*1+0x0]
  62cb3a:	00 00 
  62cb3c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
  62cb40:	8b bc 24 d0 02 00 00 	mov    edi,DWORD PTR [rsp+0x2d0]
  62cb47:	89 bc 24 48 01 00 00 	mov    DWORD PTR [rsp+0x148],edi
  62cb4e:	48 89 bc 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rdi
  62cb55:	00 
  62cb56:	48 8b 7c 24 10       	mov    rdi,QWORD PTR [rsp+0x10]
  62cb5b:	48 89 f8             	mov    rax,rdi
  62cb5e:	ba 1a 0e 00 00       	mov    edx,0xe1a
  62cb63:	b9 24 00 00 00       	mov    ecx,0x24
  62cb68:	be 00 00 00 00       	mov    esi,0x0
  62cb6d:	e8 1d 0b 00 00       	call   0x62d68f
  62cb72:	8b 40 20             	mov    eax,DWORD PTR [rax+0x20]
  62cb75:	48 89 84 24 f0 02 00 	mov    QWORD PTR [rsp+0x2f0],rax
  62cb7c:	00 
  62cb7d:	48 8b bc 24 f0 02 00 	mov    rdi,QWORD PTR [rsp+0x2f0]
  62cb84:	00 
  62cb85:	48 89 f8             	mov    rax,rdi
  62cb88:	ba a0 09 00 00       	mov    edx,0x9a0
  62cb8d:	b9 18 00 00 00       	mov    ecx,0x18
  62cb92:	be 00 00 00 00       	mov    esi,0x0
  62cb97:	e8 f3 0a 00 00       	call   0x62d68f
  62cb9c:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  62cba0:	48 89 84 24 60 03 00 	mov    QWORD PTR [rsp+0x360],rax
  62cba7:	00 
  62cba8:	8b bc 24 60 03 00 00 	mov    edi,DWORD PTR [rsp+0x360]
  62cbaf:	89 bc 24 00 03 00 00 	mov    DWORD PTR [rsp+0x300],edi
  62cbb6:	8b bc 24 58 03 00 00 	mov    edi,DWORD PTR [rsp+0x358]
  62cbbd:	89 bc 24 f8 02 00 00 	mov    DWORD PTR [rsp+0x2f8],edi
  62cbc4:	8b bc 24 f8 02 00 00 	mov    edi,DWORD PTR [rsp+0x2f8]
  62cbcb:	8b b4 24 00 03 00 00 	mov    esi,DWORD PTR [rsp+0x300]
  62cbd2:	39 f7                	cmp    edi,esi
  62cbd4:	0f 83 fb 01 00 00    	jae    0x62cdd5
  62cbda:	48 8b 7c 24 10       	mov    rdi,QWORD PTR [rsp+0x10]
  62cbdf:	48 89 f8             	mov    rax,rdi
  62cbe2:	ba 1a 0e 00 00       	mov    edx,0xe1a
  62cbe7:	b9 24 00 00 00       	mov    ecx,0x24
  62cbec:	be 00 00 00 00       	mov    esi,0x0
  62cbf1:	e8 99 0a 00 00       	call   0x62d68f
  62cbf6:	8b 40 20             	mov    eax,DWORD PTR [rax+0x20]
  62cbf9:	8b bc 24 48 01 00 00 	mov    edi,DWORD PTR [rsp+0x148]
  62cc00:	89 bc 24 10 03 00 00 	mov    DWORD PTR [rsp+0x310],edi
  62cc07:	48 89 84 24 08 03 00 	mov    QWORD PTR [rsp+0x308],rax
  62cc0e:	00 
  62cc0f:	8b bc 24 10 03 00 00 	mov    edi,DWORD PTR [rsp+0x310]
  62cc16:	48 89 bc 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rdi
  62cc1d:	00 
  62cc1e:	48 8b bc 24 08 03 00 	mov    rdi,QWORD PTR [rsp+0x308]
  62cc25:	00 
  62cc26:	48 89 f8             	mov    rax,rdi
  62cc29:	ba a0 09 00 00       	mov    edx,0x9a0
  62cc2e:	b9 18 00 00 00       	mov    ecx,0x18
  62cc33:	be 00 00 00 00       	mov    esi,0x0
  62cc38:	e8 52 0a 00 00       	call   0x62d68f
  62cc3d:	48 89 c5             	mov    rbp,rax
  62cc40:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  62cc44:	8b bc 24 58 03 00 00 	mov    edi,DWORD PTR [rsp+0x358]
  62cc4b:	39 c7                	cmp    edi,eax
  62cc4d:	0f 82 05 00 00 00    	jb     0x62cc58
  62cc53:	e9 12 0b 00 00       	jmp    0x62d76a
  62cc58:	8b 7d 10             	mov    edi,DWORD PTR [rbp+0x10]
  62cc5b:	48 89 f8             	mov    rax,rdi
  62cc5e:	8b bc 24 10 03 00 00 	mov    edi,DWORD PTR [rsp+0x310]
  62cc65:	89 f9                	mov    ecx,edi
  62cc67:	ba 3d 23 00 00       	mov    edx,0x233d
  62cc6c:	be 00 00 00 00       	mov    esi,0x0
  62cc71:	e8 2f 05 00 00       	call   0x62d1a5
  62cc76:	8b 04 20             	mov    eax,DWORD PTR [rax+riz*1]
  62cc79:	48 89 84 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rax
  62cc80:	00 
  62cc81:	48 8b bc 24 58 03 00 	mov    rdi,QWORD PTR [rsp+0x358]
  62cc88:	00 
  62cc89:	48 89 f8             	mov    rax,rdi
  62cc8c:	e8 ff b7 fd ff       	call   0x608490
  62cc91:	48 89 c7             	mov    rdi,rax
  62cc94:	48 89 bc 24 50 01 00 	mov    QWORD PTR [rsp+0x150],rdi
  62cc9b:	00 
  62cc9c:	48 8b 7c 24 10       	mov    rdi,QWORD PTR [rsp+0x10]
  62cca1:	48 89 f8             	mov    rax,rdi
  62cca4:	ba 1a 0e 00 00       	mov    edx,0xe1a
  62cca9:	b9 1c 00 00 00       	mov    ecx,0x1c
  62ccae:	be 00 00 00 00       	mov    esi,0x0
  62ccb3:	e8 d7 09 00 00       	call   0x62d68f
  62ccb8:	8b 40 18             	mov    eax,DWORD PTR [rax+0x18]
  62ccbb:	48 89 84 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rax
  62ccc2:	00 
  62ccc3:	48 8b bc 24 50 01 00 	mov    rdi,QWORD PTR [rsp+0x150]
  62ccca:	00 
  62cccb:	48 89 f8             	mov    rax,rdi
  62ccce:	ba fc 0d 00 00       	mov    edx,0xdfc
  62ccd3:	b9 24 00 00 00       	mov    ecx,0x24
  62ccd8:	be 00 00 00 00       	mov    esi,0x0
  62ccdd:	e8 ad 09 00 00       	call   0x62d68f
  62cce2:	8b 44 20 20          	mov    eax,DWORD PTR [rax+riz*1+0x20]
  62cce6:	89 84 24 10 03 00 00 	mov    DWORD PTR [rsp+0x310],eax
  62cced:	48 8b bc 24 58 03 00 	mov    rdi,QWORD PTR [rsp+0x358]
  62ccf4:	00 
  62ccf5:	48 89 bc 24 08 03 00 	mov    QWORD PTR [rsp+0x308],rdi
  62ccfc:	00 
  62ccfd:	8b bc 24 10 03 00 00 	mov    edi,DWORD PTR [rsp+0x310]
  62cd04:	48 89 bc 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rdi
  62cd0b:	00 
  62cd0c:	48 8b bc 24 08 03 00 	mov    rdi,QWORD PTR [rsp+0x308]
  62cd13:	00 
  62cd14:	48 89 f8             	mov    rax,rdi
  62cd17:	ba a0 09 00 00       	mov    edx,0x9a0
  62cd1c:	b9 18 00 00 00       	mov    ecx,0x18
  62cd21:	be 00 00 00 00       	mov    esi,0x0
  62cd26:	e8 64 09 00 00       	call   0x62d68f
  62cd2b:	48 89 c5             	mov    rbp,rax
  62cd2e:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  62cd32:	8b bc 24 58 03 00 00 	mov    edi,DWORD PTR [rsp+0x358]
  62cd39:	39 c7                	cmp    edi,eax
  62cd3b:	0f 82 05 00 00 00    	jb     0x62cd46
  62cd41:	e9 24 0a 00 00       	jmp    0x62d76a
  62cd46:	8b 7d 10             	mov    edi,DWORD PTR [rbp+0x10]
  62cd49:	48 89 f8             	mov    rax,rdi
  62cd4c:	8b bc 24 10 03 00 00 	mov    edi,DWORD PTR [rsp+0x310]
  62cd53:	89 f9                	mov    ecx,edi
  62cd55:	ba 3d 23 00 00       	mov    edx,0x233d
  62cd5a:	be 00 00 00 00       	mov    esi,0x0
  62cd5f:	e8 41 04 00 00       	call   0x62d1a5
  62cd64:	8b 04 20             	mov    eax,DWORD PTR [rax+riz*1]
  62cd67:	48 89 84 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rax
  62cd6e:	00 
  62cd6f:	48 8b bc 24 58 03 00 	mov    rdi,QWORD PTR [rsp+0x358]
  62cd76:	00 
  62cd77:	48 89 f8             	mov    rax,rdi
  62cd7a:	e8 41 c1 fd ff       	call   0x608ec0
  62cd7f:	48 89 c7             	mov    rdi,rax
  62cd82:	48 89 f8             	mov    rax,rdi
  62cd85:	ba fe 0d 00 00       	mov    edx,0xdfe
  62cd8a:	b9 34 00 00 00       	mov    ecx,0x34
  62cd8f:	be 00 00 00 00       	mov    esi,0x0
  62cd94:	e8 f6 08 00 00       	call   0x62d68f
  62cd99:	8b 44 20 30          	mov    eax,DWORD PTR [rax+riz*1+0x30]
  62cd9d:	85 c0                	test   eax,eax
  62cd9f:	0f 84 1a 00 00 00    	je     0x62cdbf
  62cda5:	48 8b 84 24 38 01 00 	mov    rax,QWORD PTR [rsp+0x138]
  62cdac:	00 
  62cdad:	48 8b 8c 24 50 01 00 	mov    rcx,QWORD PTR [rsp+0x150]
  62cdb4:	00 
  62cdb5:	e8 46 9f 9d ff       	call   0x6d00
  62cdba:	e9 00 00 00 00       	jmp    0x62cdbf
  62cdbf:	8b bc 24 48 01 00 00 	mov    edi,DWORD PTR [rsp+0x148]
  62cdc6:	83 c7 01             	add    edi,0x1
  62cdc9:	89 bc 24 d0 02 00 00 	mov    DWORD PTR [rsp+0x2d0],edi
  62cdd0:	e9 6b fd ff ff       	jmp    0x62cb40
  62cdd5:	e9 00 00 00 00       	jmp    0x62cdda
  62cdda:	48 8b 7c 24 10       	mov    rdi,QWORD PTR [rsp+0x10]
  62cddf:	48 89 f8             	mov    rax,rdi
  62cde2:	ba 1a 0e 00 00       	mov    edx,0xe1a
  62cde7:	b9 24 00 00 00       	mov    ecx,0x24
  62cdec:	be 00 00 00 00       	mov    esi,0x0
  62cdf1:	e8 99 08 00 00       	call   0x62d68f
  62cdf6:	8b 40 20             	mov    eax,DWORD PTR [rax+0x20]
  62cdf9:	e8 cb 02 9e ff       	call   0xd0c9
  62cdfe:	bf 00 00 00 00       	mov    edi,0x0
  62ce03:	89 bc 24 40 01 00 00 	mov    DWORD PTR [rsp+0x140],edi
  62ce0a:	89 bc 24 d8 02 00 00 	mov    DWORD PTR [rsp+0x2d8],edi
  62ce11:	66 0f 1f 84 00 00 00 	nop    WORD PTR [rax+rax*1+0x0]
  62ce18:	00 00 
  62ce1a:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
  62ce20:	8b bc 24 d8 02 00 00 	mov    edi,DWORD PTR [rsp+0x2d8]
  62ce27:	89 bc 24 58 01 00 00 	mov    DWORD PTR [rsp+0x158],edi
  62ce2e:	48 89 bc 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rdi
  62ce35:	00 
  62ce36:	48 8b 84 24 38 01 00 	mov    rax,QWORD PTR [rsp+0x138]
  62ce3d:	00 
  62ce3e:	e8 e9 9c 9d ff       	call   0x6b2c
  62ce43:	48 89 c7             	mov    rdi,rax
  62ce46:	89 bc 24 00 03 00 00 	mov    DWORD PTR [rsp+0x300],edi
  62ce4d:	8b bc 24 58 03 00 00 	mov    edi,DWORD PTR [rsp+0x358]
  62ce54:	89 bc 24 f8 02 00 00 	mov    DWORD PTR [rsp+0x2f8],edi
  62ce5b:	8b bc 24 f8 02 00 00 	mov    edi,DWORD PTR [rsp+0x2f8]
  62ce62:	8b b4 24 00 03 00 00 	mov    esi,DWORD PTR [rsp+0x300]
  62ce69:	39 f7                	cmp    edi,esi
  62ce6b:	0f 83 72 00 00 00    	jae    0x62cee3
  62ce71:	48 8b 7c 24 10       	mov    rdi,QWORD PTR [rsp+0x10]
  62ce76:	48 89 f8             	mov    rax,rdi
  62ce79:	ba 1a 0e 00 00       	mov    edx,0xe1a
  62ce7e:	b9 24 00 00 00       	mov    ecx,0x24
  62ce83:	be 00 00 00 00       	mov    esi,0x0
  62ce88:	e8 02 08 00 00       	call   0x62d68f
  62ce8d:	8b 40 20             	mov    eax,DWORD PTR [rax+0x20]
  62ce90:	48 89 84 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rax
  62ce97:	00 
  62ce98:	48 8b 84 24 38 01 00 	mov    rax,QWORD PTR [rsp+0x138]
  62ce9f:	00 
  62cea0:	8b 8c 24 58 01 00 00 	mov    ecx,DWORD PTR [rsp+0x158]
  62cea7:	e8 34 83 9d ff       	call   0x51e0
  62ceac:	48 89 c7             	mov    rdi,rax
  62ceaf:	48 89 f8             	mov    rax,rdi
  62ceb2:	e8 d9 b5 fd ff       	call   0x608490
  62ceb7:	48 89 c7             	mov    rdi,rax
  62ceba:	48 8b b4 24 58 03 00 	mov    rsi,QWORD PTR [rsp+0x358]
  62cec1:	00 
  62cec2:	48 89 f0             	mov    rax,rsi
  62cec5:	48 89 f9             	mov    rcx,rdi
  62cec8:	e8 33 9e 9d ff       	call   0x6d00
  62cecd:	8b bc 24 58 01 00 00 	mov    edi,DWORD PTR [rsp+0x158]
  62ced4:	83 c7 01             	add    edi,0x1
  62ced7:	89 bc 24 d8 02 00 00 	mov    DWORD PTR [rsp+0x2d8],edi
  62cede:	e9 3d ff ff ff       	jmp    0x62ce20
  62cee3:	e9 00 00 00 00       	jmp    0x62cee8
  62cee8:	b8 00 00 00 00       	mov    eax,0x0
  62ceed:	e8 8a 7b 9d ff       	call   0x4a7c
  62cef2:	48 89 c7             	mov    rdi,rax
  62cef5:	48 89 bc 24 60 01 00 	mov    QWORD PTR [rsp+0x160],rdi
  62cefc:	00 
  62cefd:	48 8b bc 24 60 01 00 	mov    rdi,QWORD PTR [rsp+0x160]
  62cf04:	00 
  62cf05:	48 89 bc 24 68 01 00 	mov    QWORD PTR [rsp+0x168],rdi
  62cf0c:	00 
  62cf0d:	bf 00 00 00 00       	mov    edi,0x0
  62cf12:	89 bc 24 70 01 00 00 	mov    DWORD PTR [rsp+0x170],edi
  62cf19:	89 bc 24 e0 02 00 00 	mov    DWORD PTR [rsp+0x2e0],edi
  62cf20:	8b bc 24 e0 02 00 00 	mov    edi,DWORD PTR [rsp+0x2e0]
  62cf27:	89 bc 24 78 01 00 00 	mov    DWORD PTR [rsp+0x178],edi
  62cf2e:	48 89 bc 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rdi
  62cf35:	00 
  62cf36:	48 8b 7c 24 10       	mov    rdi,QWORD PTR [rsp+0x10]
  62cf3b:	48 89 f8             	mov    rax,rdi
  62cf3e:	ba 1a 0e 00 00       	mov    edx,0xe1a
  62cf43:	b9 28 00 00 00       	mov    ecx,0x28
  62cf48:	be 00 00 00 00       	mov    esi,0x0
  62cf4d:	e8 3d 07 00 00       	call   0x62d68f
  62cf52:	8b 40 24             	mov    eax,DWORD PTR [rax+0x24]
  62cf55:	e8 d2 9b 9d ff       	call   0x6b2c
  62cf5a:	48 89 c7             	mov    rdi,rax
  62cf5d:	89 bc 24 00 03 00 00 	mov    DWORD PTR [rsp+0x300],edi
  62cf64:	8b bc 24 58 03 00 00 	mov    edi,DWORD PTR [rsp+0x358]
  62cf6b:	89 bc 24 f8 02 00 00 	mov    DWORD PTR [rsp+0x2f8],edi
  62cf72:	8b bc 24 f8 02 00 00 	mov    edi,DWORD PTR [rsp+0x2f8]
  62cf79:	8b b4 24 00 03 00 00 	mov    esi,DWORD PTR [rsp+0x300]
  62cf80:	39 f7                	cmp    edi,esi
  62cf82:	0f 83 ff 00 00 00    	jae    0x62d087
  62cf88:	48 8b 7c 24 10       	mov    rdi,QWORD PTR [rsp+0x10]
  62cf8d:	48 89 f8             	mov    rax,rdi
  62cf90:	ba 1a 0e 00 00       	mov    edx,0xe1a
  62cf95:	b9 28 00 00 00       	mov    ecx,0x28
  62cf9a:	be 00 00 00 00       	mov    esi,0x0
  62cf9f:	e8 eb 06 00 00       	call   0x62d68f
  62cfa4:	8b 40 24             	mov    eax,DWORD PTR [rax+0x24]
  62cfa7:	8b 8c 24 78 01 00 00 	mov    ecx,DWORD PTR [rsp+0x178]
  62cfae:	e8 2d 82 9d ff       	call   0x51e0
  62cfb3:	48 89 c7             	mov    rdi,rax
  62cfb6:	48 89 f8             	mov    rax,rdi
  62cfb9:	e8 32 ba fd ff       	call   0x6089f0
  62cfbe:	48 89 c7             	mov    rdi,rax
  62cfc1:	48 89 bc 24 80 01 00 	mov    QWORD PTR [rsp+0x180],rdi
  62cfc8:	00 
  62cfc9:	48 8b 7c 24 10       	mov    rdi,QWORD PTR [rsp+0x10]
  62cfce:	48 89 f8             	mov    rax,rdi
  62cfd1:	ba 1a 0e 00 00       	mov    edx,0xe1a
  62cfd6:	b9 1c 00 00 00       	mov    ecx,0x1c
  62cfdb:	be 00 00 00 00       	mov    esi,0x0
  62cfe0:	e8 aa 06 00 00       	call   0x62d68f
  62cfe5:	8b 40 18             	mov    eax,DWORD PTR [rax+0x18]
  62cfe8:	48 89 84 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rax
  62cfef:	00 
  62cff0:	48 8b bc 24 80 01 00 	mov    rdi,QWORD PTR [rsp+0x180]
  62cff7:	00 
  62cff8:	48 89 f8             	mov    rax,rdi
  62cffb:	ba fd 0d 00 00       	mov    edx,0xdfd
  62d000:	b9 24 00 00 00       	mov    ecx,0x24
  62d005:	be 00 00 00 00       	mov    esi,0x0
  62d00a:	e8 80 06 00 00       	call   0x62d68f
  62d00f:	8b 44 20 20          	mov    eax,DWORD PTR [rax+riz*1+0x20]
  62d013:	48 8b bc 24 58 03 00 	mov    rdi,QWORD PTR [rsp+0x358]
  62d01a:	00 
  62d01b:	48 89 c1             	mov    rcx,rax
  62d01e:	48 89 f8             	mov    rax,rdi
  62d021:	e8 ba 81 9d ff       	call   0x51e0
  62d026:	48 89 c7             	mov    rdi,rax
  62d029:	48 89 f8             	mov    rax,rdi
  62d02c:	e8 8f be fd ff       	call   0x608ec0
  62d031:	48 89 c7             	mov    rdi,rax
  62d034:	48 89 f8             	mov    rax,rdi
  62d037:	ba fe 0d 00 00       	mov    edx,0xdfe
  62d03c:	b9 34 00 00 00       	mov    ecx,0x34
  62d041:	be 00 00 00 00       	mov    esi,0x0
  62d046:	e8 44 06 00 00       	call   0x62d68f
  62d04b:	8b 44 20 30          	mov    eax,DWORD PTR [rax+riz*1+0x30]
  62d04f:	85 c0                	test   eax,eax
  62d051:	0f 84 1a 00 00 00    	je     0x62d071
  62d057:	48 8b 84 24 68 01 00 	mov    rax,QWORD PTR [rsp+0x168]
  62d05e:	00 
  62d05f:	48 8b 8c 24 80 01 00 	mov    rcx,QWORD PTR [rsp+0x180]
  62d066:	00 
  62d067:	e8 94 9c 9d ff       	call   0x6d00
  62d06c:	e9 00 00 00 00       	jmp    0x62d071
  62d071:	8b bc 24 78 01 00 00 	mov    edi,DWORD PTR [rsp+0x178]
  62d078:	83 c7 01             	add    edi,0x1
  62d07b:	89 bc 24 e0 02 00 00 	mov    DWORD PTR [rsp+0x2e0],edi
  62d082:	e9 99 fe ff ff       	jmp    0x62cf20
  62d087:	e9 00 00 00 00       	jmp    0x62d08c
  62d08c:	48 8b 7c 24 10       	mov    rdi,QWORD PTR [rsp+0x10]
  62d091:	48 89 f8             	mov    rax,rdi
  62d094:	ba 1a 0e 00 00       	mov    edx,0xe1a
  62d099:	b9 28 00 00 00       	mov    ecx,0x28
  62d09e:	be 00 00 00 00       	mov    esi,0x0
  62d0a3:	e8 e7 05 00 00       	call   0x62d68f
  62d0a8:	8b 40 24             	mov    eax,DWORD PTR [rax+0x24]
  62d0ab:	e8 19 00 9e ff       	call   0xd0c9
  62d0b0:	bf 00 00 00 00       	mov    edi,0x0
  62d0b5:	89 bc 24 70 01 00 00 	mov    DWORD PTR [rsp+0x170],edi
  62d0bc:	89 bc 24 e8 02 00 00 	mov    DWORD PTR [rsp+0x2e8],edi
  62d0c3:	66 0f 1f 84 00 00 00 	nop    WORD PTR [rax+rax*1+0x0]
  62d0ca:	00 00 
  62d0cc:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
  62d0d0:	8b bc 24 e8 02 00 00 	mov    edi,DWORD PTR [rsp+0x2e8]
  62d0d7:	89 bc 24 88 01 00 00 	mov    DWORD PTR [rsp+0x188],edi
  62d0de:	48 89 bc 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rdi
  62d0e5:	00 
  62d0e6:	48 8b 84 24 68 01 00 	mov    rax,QWORD PTR [rsp+0x168]
  62d0ed:	00 
  62d0ee:	e8 39 9a 9d ff       	call   0x6b2c
  62d0f3:	48 89 c7             	mov    rdi,rax
  62d0f6:	89 bc 24 00 03 00 00 	mov    DWORD PTR [rsp+0x300],edi
  62d0fd:	8b bc 24 58 03 00 00 	mov    edi,DWORD PTR [rsp+0x358]
  62d104:	89 bc 24 f8 02 00 00 	mov    DWORD PTR [rsp+0x2f8],edi
  62d10b:	8b bc 24 f8 02 00 00 	mov    edi,DWORD PTR [rsp+0x2f8]
  62d112:	8b b4 24 00 03 00 00 	mov    esi,DWORD PTR [rsp+0x300]
  62d119:	39 f7                	cmp    edi,esi
  62d11b:	0f 83 72 00 00 00    	jae    0x62d193
  62d121:	48 8b 7c 24 10       	mov    rdi,QWORD PTR [rsp+0x10]
  62d126:	48 89 f8             	mov    rax,rdi
  62d129:	ba 1a 0e 00 00       	mov    edx,0xe1a
  62d12e:	b9 28 00 00 00       	mov    ecx,0x28
  62d133:	be 00 00 00 00       	mov    esi,0x0
  62d138:	e8 52 05 00 00       	call   0x62d68f
  62d13d:	8b 40 24             	mov    eax,DWORD PTR [rax+0x24]
  62d140:	48 89 84 24 58 03 00 	mov    QWORD PTR [rsp+0x358],rax
  62d147:	00 
  62d148:	48 8b 84 24 68 01 00 	mov    rax,QWORD PTR [rsp+0x168]
  62d14f:	00 
  62d150:	8b 8c 24 88 01 00 00 	mov    ecx,DWORD PTR [rsp+0x188]
  62d157:	e8 84 80 9d ff       	call   0x51e0
  62d15c:	48 89 c7             	mov    rdi,rax
  62d15f:	48 89 f8             	mov    rax,rdi
  62d162:	e8 89 b8 fd ff       	call   0x6089f0
  62d167:	48 89 c7             	mov    rdi,rax
  62d16a:	48 8b b4 24 58 03 00 	mov    rsi,QWORD PTR [rsp+0x358]
  62d171:	00 
  62d172:	48 89 f0             	mov    rax,rsi
  62d175:	48 89 f9             	mov    rcx,rdi
  62d178:	e8 83 9b 9d ff       	call   0x6d00
  62d17d:	8b bc 24 88 01 00 00 	mov    edi,DWORD PTR [rsp+0x188]
  62d184:	83 c7 01             	add    edi,0x1
  62d187:	89 bc 24 e8 02 00 00 	mov    DWORD PTR [rsp+0x2e8],edi
  62d18e:	e9 3d ff ff ff       	jmp    0x62d0d0
  62d193:	e9 00 00 00 00       	jmp    0x62d198
  62d198:	48 8b 44 24 10       	mov    rax,QWORD PTR [rsp+0x10]
  62d19d:	48 81 c4 b8 03 00 00 	add    rsp,0x3b8
  62d1a4:	c3                   	ret
  62d1a5:	49 89 c2             	mov    r10,rax
  62d1a8:	49 c1 ea 20          	shr    r10,0x20
  62d1ac:	4d 85 d2             	test   r10,r10
  62d1af:	0f 85 ed 00 00 00    	jne    0x62d2a2
  62d1b5:	85 c0                	test   eax,eax
  62d1b7:	0f 85 0d 00 00 00    	jne    0x62d1ca
  62d1bd:	85 f6                	test   esi,esi
  62d1bf:	0f 84 dd 00 00 00    	je     0x62d2a2
  62d1c5:	e9 dd 00 00 00       	jmp    0x62d2a7
  62d1ca:	89 ce                	mov    esi,ecx
  62d1cc:	41 89 c2             	mov    r10d,eax
  62d1cf:	41 83 e2 01          	and    r10d,0x1
  62d1d3:	45 85 d2             	test   r10d,r10d
  62d1d6:	0f 85 c6 00 00 00    	jne    0x62d2a2
  62d1dc:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  62d1e3:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  62d1e7:	48 6b d2 04          	imul   rdx,rdx,0x4
  62d1eb:	41 8b 14 12          	mov    edx,DWORD PTR [r10+rdx*1]
  62d1ef:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  62d1f3:	d1 e8                	shr    eax,1
  62d1f5:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  62d1f9:	0f 83 a3 00 00 00    	jae    0x62d2a2
  62d1ff:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  62d203:	48 c1 e0 04          	shl    rax,0x4
  62d207:	49 01 c1             	add    r9,rax
  62d20a:	45 0f b6 54 21 0e    	movzx  r10d,BYTE PTR [r9+riz*1+0xe]
  62d210:	45 85 d2             	test   r10d,r10d
  62d213:	0f 84 89 00 00 00    	je     0x62d2a2
  62d219:	41 83 fa 04          	cmp    r10d,0x4
  62d21d:	0f 87 7f 00 00 00    	ja     0x62d2a2
  62d223:	4d 6b d2 10          	imul   r10,r10,0x10
  62d227:	4d 8d 40 18          	lea    r8,[r8+0x18]
  62d22b:	4d 01 d0             	add    r8,r10
  62d22e:	4d 8b 18             	mov    r11,QWORD PTR [r8]
  62d231:	45 8b 40 08          	mov    r8d,DWORD PTR [r8+0x8]
  62d235:	41 8b 01             	mov    eax,DWORD PTR [r9]
  62d238:	44 39 c0             	cmp    eax,r8d
  62d23b:	0f 87 61 00 00 00    	ja     0x62d2a2
  62d241:	41 29 c0             	sub    r8d,eax
  62d244:	41 8b 49 04          	mov    ecx,DWORD PTR [r9+0x4]
  62d248:	44 39 c1             	cmp    ecx,r8d
  62d24b:	0f 87 51 00 00 00    	ja     0x62d2a2
  62d251:	83 f9 10             	cmp    ecx,0x10
  62d254:	0f 82 48 00 00 00    	jb     0x62d2a2
  62d25a:	49 01 c3             	add    r11,rax
  62d25d:	41 8b 0b             	mov    ecx,DWORD PTR [r11]
  62d260:	39 d1                	cmp    ecx,edx
  62d262:	0f 85 3a 00 00 00    	jne    0x62d2a2
  62d268:	45 8b 53 08          	mov    r10d,DWORD PTR [r11+0x8]
  62d26c:	44 39 d6             	cmp    esi,r10d
  62d26f:	0f 83 37 00 00 00    	jae    0x62d2ac
  62d275:	48 6b f6 04          	imul   rsi,rsi,0x4
  62d279:	45 8b 53 04          	mov    r10d,DWORD PTR [r11+0x4]
  62d27d:	49 89 f0             	mov    r8,rsi
  62d280:	49 83 c0 14          	add    r8,0x14
  62d284:	41 8b 51 04          	mov    edx,DWORD PTR [r9+0x4]
  62d288:	49 39 d0             	cmp    r8,rdx
  62d28b:	0f 87 11 00 00 00    	ja     0x62d2a2
  62d291:	4d 39 d0             	cmp    r8,r10
  62d294:	0f 87 08 00 00 00    	ja     0x62d2a2
  62d29a:	49 8d 43 10          	lea    rax,[r11+0x10]
  62d29e:	48 01 f0             	add    rax,rsi
  62d2a1:	c3                   	ret
  62d2a2:	e9 c2 05 00 00       	jmp    0x62d869
  62d2a7:	e9 95 05 00 00       	jmp    0x62d841
  62d2ac:	e9 36 05 00 00       	jmp    0x62d7e7
  62d2b1:	49 89 c2             	mov    r10,rax
  62d2b4:	49 c1 ea 20          	shr    r10,0x20
  62d2b8:	4d 85 d2             	test   r10,r10
  62d2bb:	0f 85 2b 01 00 00    	jne    0x62d3ec
  62d2c1:	85 c0                	test   eax,eax
  62d2c3:	0f 85 0d 00 00 00    	jne    0x62d2d6
  62d2c9:	85 c9                	test   ecx,ecx
  62d2cb:	0f 84 1b 01 00 00    	je     0x62d3ec
  62d2d1:	e9 15 01 00 00       	jmp    0x62d3eb
  62d2d6:	89 c7                	mov    edi,eax
  62d2d8:	41 89 c2             	mov    r10d,eax
  62d2db:	41 83 e2 01          	and    r10d,0x1
  62d2df:	45 85 d2             	test   r10d,r10d
  62d2e2:	0f 85 04 01 00 00    	jne    0x62d3ec
  62d2e8:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  62d2ef:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  62d2f3:	48 6b d2 04          	imul   rdx,rdx,0x4
  62d2f7:	41 8b 14 12          	mov    edx,DWORD PTR [r10+rdx*1]
  62d2fb:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  62d2ff:	d1 e8                	shr    eax,1
  62d301:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  62d305:	0f 83 e1 00 00 00    	jae    0x62d3ec
  62d30b:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  62d30f:	48 c1 e0 04          	shl    rax,0x4
  62d313:	49 01 c1             	add    r9,rax
  62d316:	45 0f b6 54 21 0e    	movzx  r10d,BYTE PTR [r9+riz*1+0xe]
  62d31c:	45 85 d2             	test   r10d,r10d
  62d31f:	0f 84 c7 00 00 00    	je     0x62d3ec
  62d325:	41 83 fa 04          	cmp    r10d,0x4
  62d329:	0f 87 bd 00 00 00    	ja     0x62d3ec
  62d32f:	41 c1 e2 04          	shl    r10d,0x4
  62d333:	4f 8b 5c 10 18       	mov    r11,QWORD PTR [r8+r10*1+0x18]
  62d338:	47 8b 44 10 20       	mov    r8d,DWORD PTR [r8+r10*1+0x20]
  62d33d:	41 8b 01             	mov    eax,DWORD PTR [r9]
  62d340:	44 39 c0             	cmp    eax,r8d
  62d343:	0f 87 a3 00 00 00    	ja     0x62d3ec
  62d349:	41 29 c0             	sub    r8d,eax
  62d34c:	41 8b 49 04          	mov    ecx,DWORD PTR [r9+0x4]
  62d350:	44 39 c1             	cmp    ecx,r8d
  62d353:	0f 87 93 00 00 00    	ja     0x62d3ec
  62d359:	83 f9 10             	cmp    ecx,0x10
  62d35c:	0f 82 8a 00 00 00    	jb     0x62d3ec
  62d362:	49 01 c3             	add    r11,rax
  62d365:	41 8b 0b             	mov    ecx,DWORD PTR [r11]
  62d368:	39 d1                	cmp    ecx,edx
  62d36a:	0f 84 74 00 00 00    	je     0x62d3e4
  62d370:	85 f6                	test   esi,esi
  62d372:	0f 85 74 00 00 00    	jne    0x62d3ec
  62d378:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  62d37f:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  62d383:	89 c8                	mov    eax,ecx
  62d385:	41 3b 80 a4 00 00 00 	cmp    eax,DWORD PTR [r8+0xa4]
  62d38c:	0f 83 5a 00 00 00    	jae    0x62d3ec
  62d392:	89 d0                	mov    eax,edx
  62d394:	41 3b 80 a4 00 00 00 	cmp    eax,DWORD PTR [r8+0xa4]
  62d39b:	0f 83 4b 00 00 00    	jae    0x62d3ec
  62d3a1:	4d 8b 90 a8 00 00 00 	mov    r10,QWORD PTR [r8+0xa8]
  62d3a8:	4d 85 d2             	test   r10,r10
  62d3ab:	0f 84 3b 00 00 00    	je     0x62d3ec
  62d3b1:	89 c8                	mov    eax,ecx
  62d3b3:	48 6b c0 08          	imul   rax,rax,0x8
  62d3b7:	4d 8b 0c 02          	mov    r9,QWORD PTR [r10+rax*1]
  62d3bb:	89 d0                	mov    eax,edx
  62d3bd:	48 6b c0 08          	imul   rax,rax,0x8
  62d3c1:	4d 8b 14 02          	mov    r10,QWORD PTR [r10+rax*1]
  62d3c5:	4c 89 c8             	mov    rax,r9
  62d3c8:	48 c1 e8 20          	shr    rax,0x20
  62d3cc:	4c 89 d1             	mov    rcx,r10
  62d3cf:	48 c1 e9 20          	shr    rcx,0x20
  62d3d3:	39 c8                	cmp    eax,ecx
  62d3d5:	0f 82 11 00 00 00    	jb     0x62d3ec
  62d3db:	45 39 d1             	cmp    r9d,r10d
  62d3de:	0f 87 08 00 00 00    	ja     0x62d3ec
  62d3e4:	89 f8                	mov    eax,edi
  62d3e6:	e9 00 00 00 00       	jmp    0x62d3eb
  62d3eb:	c3                   	ret
  62d3ec:	e9 78 04 00 00       	jmp    0x62d869
  62d3f1:	49 89 c2             	mov    r10,rax
  62d3f4:	49 c1 ea 20          	shr    r10,0x20
  62d3f8:	4d 85 d2             	test   r10,r10
  62d3fb:	0f 85 46 01 00 00    	jne    0x62d547
  62d401:	85 c0                	test   eax,eax
  62d403:	0f 85 0c 00 00 00    	jne    0x62d415
  62d409:	89 c8                	mov    eax,ecx
  62d40b:	ba 00 00 00 00       	mov    edx,0x0
  62d410:	e9 3c 01 00 00       	jmp    0x62d551
  62d415:	41 89 c2             	mov    r10d,eax
  62d418:	41 83 e2 01          	and    r10d,0x1
  62d41c:	45 85 d2             	test   r10d,r10d
  62d41f:	0f 85 22 01 00 00    	jne    0x62d547
  62d425:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  62d42c:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  62d430:	48 6b d2 04          	imul   rdx,rdx,0x4
  62d434:	41 8b 14 12          	mov    edx,DWORD PTR [r10+rdx*1]
  62d438:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  62d43c:	d1 e8                	shr    eax,1
  62d43e:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  62d442:	0f 83 0a 01 00 00    	jae    0x62d552
  62d448:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  62d44c:	48 c1 e0 04          	shl    rax,0x4
  62d450:	49 01 c1             	add    r9,rax
  62d453:	45 0f b6 54 21 0e    	movzx  r10d,BYTE PTR [r9+riz*1+0xe]
  62d459:	45 85 d2             	test   r10d,r10d
  62d45c:	0f 84 f0 00 00 00    	je     0x62d552
  62d462:	41 83 fa 04          	cmp    r10d,0x4
  62d466:	0f 87 e6 00 00 00    	ja     0x62d552
  62d46c:	41 c1 e2 04          	shl    r10d,0x4
  62d470:	4f 8b 5c 10 18       	mov    r11,QWORD PTR [r8+r10*1+0x18]
  62d475:	47 8b 44 10 20       	mov    r8d,DWORD PTR [r8+r10*1+0x20]
  62d47a:	41 8b 01             	mov    eax,DWORD PTR [r9]
  62d47d:	44 39 c0             	cmp    eax,r8d
  62d480:	0f 87 cc 00 00 00    	ja     0x62d552
  62d486:	41 29 c0             	sub    r8d,eax
  62d489:	41 8b 49 04          	mov    ecx,DWORD PTR [r9+0x4]
  62d48d:	44 39 c1             	cmp    ecx,r8d
  62d490:	0f 87 bc 00 00 00    	ja     0x62d552
  62d496:	83 f9 10             	cmp    ecx,0x10
  62d499:	0f 82 b3 00 00 00    	jb     0x62d552
  62d49f:	89 cf                	mov    edi,ecx
  62d4a1:	49 01 c3             	add    r11,rax
  62d4a4:	41 8b 0b             	mov    ecx,DWORD PTR [r11]
  62d4a7:	39 d1                	cmp    ecx,edx
  62d4a9:	0f 84 6c 00 00 00    	je     0x62d51b
  62d4af:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  62d4b6:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  62d4ba:	89 c8                	mov    eax,ecx
  62d4bc:	41 3b 80 a4 00 00 00 	cmp    eax,DWORD PTR [r8+0xa4]
  62d4c3:	0f 83 89 00 00 00    	jae    0x62d552
  62d4c9:	89 d0                	mov    eax,edx
  62d4cb:	41 3b 80 a4 00 00 00 	cmp    eax,DWORD PTR [r8+0xa4]
  62d4d2:	0f 83 7a 00 00 00    	jae    0x62d552
  62d4d8:	4d 8b 90 a8 00 00 00 	mov    r10,QWORD PTR [r8+0xa8]
  62d4df:	4d 85 d2             	test   r10,r10
  62d4e2:	0f 84 6a 00 00 00    	je     0x62d552
  62d4e8:	89 c8                	mov    eax,ecx
  62d4ea:	48 6b c0 08          	imul   rax,rax,0x8
  62d4ee:	4d 8b 0c 02          	mov    r9,QWORD PTR [r10+rax*1]
  62d4f2:	89 d0                	mov    eax,edx
  62d4f4:	48 6b c0 08          	imul   rax,rax,0x8
  62d4f8:	4d 8b 14 02          	mov    r10,QWORD PTR [r10+rax*1]
  62d4fc:	4c 89 c8             	mov    rax,r9
  62d4ff:	48 c1 e8 20          	shr    rax,0x20
  62d503:	4c 89 d1             	mov    rcx,r10
  62d506:	48 c1 e9 20          	shr    rcx,0x20
  62d50a:	39 c8                	cmp    eax,ecx
  62d50c:	0f 82 35 00 00 00    	jb     0x62d547
  62d512:	45 39 d1             	cmp    r9d,r10d
  62d515:	0f 87 2c 00 00 00    	ja     0x62d547
  62d51b:	41 8b 03             	mov    eax,DWORD PTR [r11]
  62d51e:	39 d0                	cmp    eax,edx
  62d520:	0f 85 2c 00 00 00    	jne    0x62d552
  62d526:	39 f7                	cmp    edi,esi
  62d528:	0f 82 24 00 00 00    	jb     0x62d552
  62d52e:	41 8b 43 04          	mov    eax,DWORD PTR [r11+0x4]
  62d532:	39 f0                	cmp    eax,esi
  62d534:	0f 82 18 00 00 00    	jb     0x62d552
  62d53a:	4c 89 da             	mov    rdx,r11
  62d53d:	b8 01 00 00 00       	mov    eax,0x1
  62d542:	e9 0a 00 00 00       	jmp    0x62d551
  62d547:	b8 00 00 00 00       	mov    eax,0x0
  62d54c:	ba 00 00 00 00       	mov    edx,0x0
  62d551:	c3                   	ret
  62d552:	e9 12 03 00 00       	jmp    0x62d869
  62d557:	49 89 c2             	mov    r10,rax
  62d55a:	49 c1 ea 20          	shr    r10,0x20
  62d55e:	4d 85 d2             	test   r10,r10
  62d561:	0f 85 1d 01 00 00    	jne    0x62d684
  62d567:	85 c0                	test   eax,eax
  62d569:	0f 85 07 00 00 00    	jne    0x62d576
  62d56f:	89 c8                	mov    eax,ecx
  62d571:	e9 13 01 00 00       	jmp    0x62d689
  62d576:	41 89 c2             	mov    r10d,eax
  62d579:	41 83 e2 01          	and    r10d,0x1
  62d57d:	45 85 d2             	test   r10d,r10d
  62d580:	0f 85 fe 00 00 00    	jne    0x62d684
  62d586:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  62d58d:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  62d591:	48 6b d2 04          	imul   rdx,rdx,0x4
  62d595:	41 8b 14 12          	mov    edx,DWORD PTR [r10+rdx*1]
  62d599:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  62d59d:	d1 e8                	shr    eax,1
  62d59f:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  62d5a3:	0f 83 e1 00 00 00    	jae    0x62d68a
  62d5a9:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  62d5ad:	48 c1 e0 04          	shl    rax,0x4
  62d5b1:	49 01 c1             	add    r9,rax
  62d5b4:	45 0f b6 54 21 0e    	movzx  r10d,BYTE PTR [r9+riz*1+0xe]
  62d5ba:	45 85 d2             	test   r10d,r10d
  62d5bd:	0f 84 c7 00 00 00    	je     0x62d68a
  62d5c3:	41 83 fa 04          	cmp    r10d,0x4
  62d5c7:	0f 87 bd 00 00 00    	ja     0x62d68a
  62d5cd:	41 c1 e2 04          	shl    r10d,0x4
  62d5d1:	4f 8b 5c 10 18       	mov    r11,QWORD PTR [r8+r10*1+0x18]
  62d5d6:	47 8b 44 10 20       	mov    r8d,DWORD PTR [r8+r10*1+0x20]
  62d5db:	41 8b 01             	mov    eax,DWORD PTR [r9]
  62d5de:	44 39 c0             	cmp    eax,r8d
  62d5e1:	0f 87 a3 00 00 00    	ja     0x62d68a
  62d5e7:	41 29 c0             	sub    r8d,eax
  62d5ea:	41 8b 49 04          	mov    ecx,DWORD PTR [r9+0x4]
  62d5ee:	44 39 c1             	cmp    ecx,r8d
  62d5f1:	0f 87 93 00 00 00    	ja     0x62d68a
  62d5f7:	83 f9 10             	cmp    ecx,0x10
  62d5fa:	0f 82 8a 00 00 00    	jb     0x62d68a
  62d600:	49 01 c3             	add    r11,rax
  62d603:	41 8b 0b             	mov    ecx,DWORD PTR [r11]
  62d606:	39 d1                	cmp    ecx,edx
  62d608:	0f 84 6c 00 00 00    	je     0x62d67a
  62d60e:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  62d615:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  62d619:	89 c8                	mov    eax,ecx
  62d61b:	41 3b 80 a4 00 00 00 	cmp    eax,DWORD PTR [r8+0xa4]
  62d622:	0f 83 62 00 00 00    	jae    0x62d68a
  62d628:	89 d0                	mov    eax,edx
  62d62a:	41 3b 80 a4 00 00 00 	cmp    eax,DWORD PTR [r8+0xa4]
  62d631:	0f 83 53 00 00 00    	jae    0x62d68a
  62d637:	4d 8b 90 a8 00 00 00 	mov    r10,QWORD PTR [r8+0xa8]
  62d63e:	4d 85 d2             	test   r10,r10
  62d641:	0f 84 43 00 00 00    	je     0x62d68a
  62d647:	89 c8                	mov    eax,ecx
  62d649:	48 6b c0 08          	imul   rax,rax,0x8
  62d64d:	4d 8b 0c 02          	mov    r9,QWORD PTR [r10+rax*1]
  62d651:	89 d0                	mov    eax,edx
  62d653:	48 6b c0 08          	imul   rax,rax,0x8
  62d657:	4d 8b 14 02          	mov    r10,QWORD PTR [r10+rax*1]
  62d65b:	4c 89 c8             	mov    rax,r9
  62d65e:	48 c1 e8 20          	shr    rax,0x20
  62d662:	4c 89 d1             	mov    rcx,r10
  62d665:	48 c1 e9 20          	shr    rcx,0x20
  62d669:	39 c8                	cmp    eax,ecx
  62d66b:	0f 82 13 00 00 00    	jb     0x62d684
  62d671:	45 39 d1             	cmp    r9d,r10d
  62d674:	0f 87 0a 00 00 00    	ja     0x62d684
  62d67a:	b8 01 00 00 00       	mov    eax,0x1
  62d67f:	e9 05 00 00 00       	jmp    0x62d689
  62d684:	b8 00 00 00 00       	mov    eax,0x0
  62d689:	c3                   	ret
  62d68a:	e9 da 01 00 00       	jmp    0x62d869
  62d68f:	89 cf                	mov    edi,ecx
  62d691:	49 89 c2             	mov    r10,rax
  62d694:	49 c1 ea 20          	shr    r10,0x20
  62d698:	4d 85 d2             	test   r10,r10
  62d69b:	0f 85 bf 00 00 00    	jne    0x62d760
  62d6a1:	85 c0                	test   eax,eax
  62d6a3:	0f 85 0d 00 00 00    	jne    0x62d6b6
  62d6a9:	85 f6                	test   esi,esi
  62d6ab:	0f 84 af 00 00 00    	je     0x62d760
  62d6b1:	e9 af 00 00 00       	jmp    0x62d765
  62d6b6:	41 89 c2             	mov    r10d,eax
  62d6b9:	41 83 e2 01          	and    r10d,0x1
  62d6bd:	45 85 d2             	test   r10d,r10d
  62d6c0:	0f 85 9a 00 00 00    	jne    0x62d760
  62d6c6:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  62d6cd:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  62d6d1:	48 6b d2 04          	imul   rdx,rdx,0x4
  62d6d5:	41 8b 14 12          	mov    edx,DWORD PTR [r10+rdx*1]
  62d6d9:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  62d6dd:	d1 e8                	shr    eax,1
  62d6df:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  62d6e3:	0f 83 77 00 00 00    	jae    0x62d760
  62d6e9:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  62d6ed:	48 c1 e0 04          	shl    rax,0x4
  62d6f1:	49 01 c1             	add    r9,rax
  62d6f4:	45 0f b6 54 21 0e    	movzx  r10d,BYTE PTR [r9+riz*1+0xe]
  62d6fa:	45 85 d2             	test   r10d,r10d
  62d6fd:	0f 84 5d 00 00 00    	je     0x62d760
  62d703:	41 83 fa 04          	cmp    r10d,0x4
  62d707:	0f 87 53 00 00 00    	ja     0x62d760
  62d70d:	41 c1 e2 04          	shl    r10d,0x4
  62d711:	4f 8b 5c 10 18       	mov    r11,QWORD PTR [r8+r10*1+0x18]
  62d716:	47 8b 44 10 20       	mov    r8d,DWORD PTR [r8+r10*1+0x20]
  62d71b:	41 8b 01             	mov    eax,DWORD PTR [r9]
  62d71e:	44 39 c0             	cmp    eax,r8d
  62d721:	0f 87 39 00 00 00    	ja     0x62d760
  62d727:	41 29 c0             	sub    r8d,eax
  62d72a:	41 8b 49 04          	mov    ecx,DWORD PTR [r9+0x4]
  62d72e:	44 39 c1             	cmp    ecx,r8d
  62d731:	0f 87 29 00 00 00    	ja     0x62d760
  62d737:	39 f9                	cmp    ecx,edi
  62d739:	0f 82 21 00 00 00    	jb     0x62d760
  62d73f:	49 01 c3             	add    r11,rax
  62d742:	41 8b 0b             	mov    ecx,DWORD PTR [r11]
  62d745:	39 d1                	cmp    ecx,edx
  62d747:	0f 85 13 00 00 00    	jne    0x62d760
  62d74d:	41 8b 4b 04          	mov    ecx,DWORD PTR [r11+0x4]
  62d751:	39 f9                	cmp    ecx,edi
  62d753:	0f 82 07 00 00 00    	jb     0x62d760
  62d759:	4c 89 de             	mov    rsi,r11
  62d75c:	48 89 f0             	mov    rax,rsi
  62d75f:	c3                   	ret
  62d760:	e9 04 01 00 00       	jmp    0x62d869
  62d765:	e9 d7 00 00 00       	jmp    0x62d841
  62d76a:	b8 ff ff ff ff       	mov    eax,0xffffffff
  62d76f:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  62d773:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  62d776:	44 89 36             	mov    DWORD PTR [rsi],r14d
  62d779:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  62d77d:	c7 46 10 a9 01 00 00 	mov    DWORD PTR [rsi+0x10],0x1a9
  62d784:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  62d787:	c7 06 01 00 00 00    	mov    DWORD PTR [rsi],0x1
  62d78d:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  62d791:	c3                   	ret
  62d792:	b8 13 00 00 00       	mov    eax,0x13
  62d797:	e9 00 00 00 00       	jmp    0x62d79c
  62d79c:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  62d7a0:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  62d7a3:	44 89 36             	mov    DWORD PTR [rsi],r14d
  62d7a6:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  62d7aa:	c7 46 10 c2 01 00 00 	mov    DWORD PTR [rsi+0x10],0x1c2
  62d7b1:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  62d7b4:	c7 06 01 00 00 00    	mov    DWORD PTR [rsi],0x1
  62d7ba:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  62d7be:	c3                   	ret
  62d7bf:	b8 ff ff ff ff       	mov    eax,0xffffffff
  62d7c4:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  62d7c8:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  62d7cb:	44 89 36             	mov    DWORD PTR [rsi],r14d
  62d7ce:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  62d7d2:	c7 46 10 f7 08 00 00 	mov    DWORD PTR [rsi+0x10],0x8f7
  62d7d9:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  62d7dc:	c7 06 01 00 00 00    	mov    DWORD PTR [rsi],0x1
  62d7e2:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  62d7e6:	c3                   	ret
  62d7e7:	b8 ff ff ff ff       	mov    eax,0xffffffff
  62d7ec:	e9 00 00 00 00       	jmp    0x62d7f1
  62d7f1:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  62d7f5:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  62d7f8:	44 89 36             	mov    DWORD PTR [rsi],r14d
  62d7fb:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  62d7ff:	c7 46 10 f7 08 00 00 	mov    DWORD PTR [rsi+0x10],0x8f7
  62d806:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  62d809:	c7 06 02 00 00 00    	mov    DWORD PTR [rsi],0x2
  62d80f:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  62d813:	c3                   	ret
  62d814:	b8 00 00 00 00       	mov    eax,0x0
  62d819:	e9 00 00 00 00       	jmp    0x62d81e
  62d81e:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  62d822:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  62d825:	44 89 36             	mov    DWORD PTR [rsi],r14d
  62d828:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  62d82c:	c7 46 10 f7 08 00 00 	mov    DWORD PTR [rsi+0x10],0x8f7
  62d833:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  62d836:	c7 06 0d 00 00 00    	mov    DWORD PTR [rsi],0xd
  62d83c:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  62d840:	c3                   	ret
  62d841:	b8 ff ff ff ff       	mov    eax,0xffffffff
  62d846:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  62d84a:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  62d84d:	44 89 36             	mov    DWORD PTR [rsi],r14d
  62d850:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  62d854:	c7 46 10 f7 08 00 00 	mov    DWORD PTR [rsi+0x10],0x8f7
  62d85b:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  62d85e:	c7 06 10 00 00 00    	mov    DWORD PTR [rsi],0x10
  62d864:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  62d868:	c3                   	ret
  62d869:	b8 ff ff ff ff       	mov    eax,0xffffffff
  62d86e:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  62d872:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  62d875:	44 89 36             	mov    DWORD PTR [rsi],r14d
  62d878:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  62d87c:	c7 46 10 f7 08 00 00 	mov    DWORD PTR [rsi+0x10],0x8f7
  62d883:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  62d886:	c7 06 12 00 00 00    	mov    DWORD PTR [rsi],0x12
  62d88c:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  62d890:	c3                   	ret
