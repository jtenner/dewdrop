
.tmp/wago-next-gc-perf/post-read-regions-profile/profile/native-code.bin:     file format binary


Disassembly of section .data:

0000000000627ee0 <.data+0x627ee0>:
  627ee0:	48 81 ec d8 00 00 00 	sub    rsp,0xd8
  627ee7:	48 8b 73 b8          	mov    rsi,QWORD PTR [rbx-0x48]
  627eeb:	48 39 f4             	cmp    rsp,rsi
  627eee:	0f 82 fc 12 00 00    	jb     0x6291f0
  627ef4:	48 89 04 24          	mov    QWORD PTR [rsp],rax
  627ef8:	48 89 4c 24 08       	mov    QWORD PTR [rsp+0x8],rcx
  627efd:	48 89 54 24 10       	mov    QWORD PTR [rsp+0x10],rdx
  627f02:	31 c0                	xor    eax,eax
  627f04:	45 31 db             	xor    r11d,r11d
  627f07:	48 89 44 24 20       	mov    QWORD PTR [rsp+0x20],rax
  627f0c:	45 31 e4             	xor    r12d,r12d
  627f0f:	31 ed                	xor    ebp,ebp
  627f11:	48 89 44 24 38       	mov    QWORD PTR [rsp+0x38],rax
  627f16:	89 44 24 40          	mov    DWORD PTR [rsp+0x40],eax
  627f1a:	45 31 c9             	xor    r9d,r9d
  627f1d:	45 31 d2             	xor    r10d,r10d
  627f20:	45 31 ed             	xor    r13d,r13d
  627f23:	bf 95 09 00 00       	mov    edi,0x995
  627f28:	48 89 7c 24 70       	mov    QWORD PTR [rsp+0x70],rdi
  627f2d:	41 50                	push   r8
  627f2f:	41 51                	push   r9
  627f31:	41 52                	push   r10
  627f33:	41 53                	push   r11
  627f35:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  627f3c:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  627f40:	41 8b 92 54 26 00 00 	mov    edx,DWORD PTR [r10+0x2654]
  627f47:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  627f4b:	41 83 b8 a0 00 00 00 	cmp    DWORD PTR [r8+0xa0],0x10
  627f52:	10 
  627f53:	0f 86 2d 01 00 00    	jbe    0x628086
  627f59:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  627f60:	4d 85 d2             	test   r10,r10
  627f63:	0f 84 1d 01 00 00    	je     0x628086
  627f69:	41 8b 4a 04          	mov    ecx,DWORD PTR [r10+0x4]
  627f6d:	41 8b 42 08          	mov    eax,DWORD PTR [r10+0x8]
  627f71:	81 f8 00 02 00 00    	cmp    eax,0x200
  627f77:	0f 87 09 01 00 00    	ja     0x628086
  627f7d:	39 c1                	cmp    ecx,eax
  627f7f:	0f 83 01 01 00 00    	jae    0x628086
  627f85:	49 8d 44 8a 20       	lea    rax,[r10+rcx*4+0x20]
  627f8a:	8b 30                	mov    esi,DWORD PTR [rax]
  627f8c:	89 f0                	mov    eax,esi
  627f8e:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  627f92:	48 c1 e0 04          	shl    rax,0x4
  627f96:	49 01 c1             	add    r9,rax
  627f99:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  627fa0:	48 85 c0             	test   rax,rax
  627fa3:	0f 84 dd 00 00 00    	je     0x628086
  627fa9:	8b 08                	mov    ecx,DWORD PTR [rax]
  627fab:	83 c1 07             	add    ecx,0x7
  627fae:	83 e1 f8             	and    ecx,0xfffffff8
  627fb1:	41 8b 40 7c          	mov    eax,DWORD PTR [r8+0x7c]
  627fb5:	39 c1                	cmp    ecx,eax
  627fb7:	0f 87 c9 00 00 00    	ja     0x628086
  627fbd:	29 c8                	sub    eax,ecx
  627fbf:	83 f8 10             	cmp    eax,0x10
  627fc2:	0f 82 be 00 00 00    	jb     0x628086
  627fc8:	4d 8b 58 28          	mov    r11,QWORD PTR [r8+0x28]
  627fcc:	4d 85 db             	test   r11,r11
  627fcf:	0f 84 b1 00 00 00    	je     0x628086
  627fd5:	49 01 cb             	add    r11,rcx
  627fd8:	49 8b 80 98 00 00 00 	mov    rax,QWORD PTR [r8+0x98]
  627fdf:	48 85 c0             	test   rax,rax
  627fe2:	0f 84 9e 00 00 00    	je     0x628086
  627fe8:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  627fef:	41 8b 52 04          	mov    edx,DWORD PTR [r10+0x4]
  627ff3:	48 8b 83 e8 fe ff ff 	mov    rax,QWORD PTR [rbx-0x118]
  627ffa:	48 8b 40 10          	mov    rax,QWORD PTR [rax+0x10]
  627ffe:	8b 80 54 26 00 00    	mov    eax,DWORD PTR [rax+0x2654]
  628004:	41 89 03             	mov    DWORD PTR [r11],eax
  628007:	41 c7 43 04 10 00 00 	mov    DWORD PTR [r11+0x4],0x10
  62800e:	00 
  62800f:	41 c7 43 08 00 00 00 	mov    DWORD PTR [r11+0x8],0x0
  628016:	00 
  628017:	41 c7 43 0c 01 00 00 	mov    DWORD PTR [r11+0xc],0x1
  62801e:	00 
  62801f:	41 89 09             	mov    DWORD PTR [r9],ecx
  628022:	41 c7 41 04 10 00 00 	mov    DWORD PTR [r9+0x4],0x10
  628029:	00 
  62802a:	41 c7 41 08 00 00 00 	mov    DWORD PTR [r9+0x8],0x0
  628031:	00 
  628032:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  628039:	41 89 ca             	mov    r10d,ecx
  62803c:	41 83 c2 10          	add    r10d,0x10
  628040:	44 89 10             	mov    DWORD PTR [rax],r10d
  628043:	41 c7 41 0c 00 00 01 	mov    DWORD PTR [r9+0xc],0x10000
  62804a:	00 
  62804b:	83 c2 01             	add    edx,0x1
  62804e:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  628055:	41 89 52 04          	mov    DWORD PTR [r10+0x4],edx
  628059:	41 83 7a 18 00       	cmp    DWORD PTR [r10+0x18],0x0
  62805e:	0f 84 11 00 00 00    	je     0x628075
  628064:	4d 8b 90 98 00 00 00 	mov    r10,QWORD PTR [r8+0x98]
  62806b:	49 8b 02             	mov    rax,QWORD PTR [r10]
  62806e:	48 83 c0 01          	add    rax,0x1
  628072:	49 89 02             	mov    QWORD PTR [r10],rax
  628075:	89 f0                	mov    eax,esi
  628077:	d1 e0                	shl    eax,1
  628079:	48 89 84 24 90 00 00 	mov    QWORD PTR [rsp+0x90],rax
  628080:	00 
  628081:	e9 05 00 00 00       	jmp    0x62808b
  628086:	b8 00 00 00 00       	mov    eax,0x0
  62808b:	85 c0                	test   eax,eax
  62808d:	41 5b                	pop    r11
  62808f:	41 5a                	pop    r10
  628091:	41 59                	pop    r9
  628093:	41 58                	pop    r8
  628095:	0f 85 6c 00 00 00    	jne    0x628107
  62809b:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  62809f:	8b 44 24 70          	mov    eax,DWORD PTR [rsp+0x70]
  6280a3:	49 89 40 48          	mov    QWORD PTR [r8+0x48],rax
  6280a7:	4c 89 5c 24 18       	mov    QWORD PTR [rsp+0x18],r11
  6280ac:	4c 89 64 24 28       	mov    QWORD PTR [rsp+0x28],r12
  6280b1:	48 89 6c 24 30       	mov    QWORD PTR [rsp+0x30],rbp
  6280b6:	4c 89 4c 24 48       	mov    QWORD PTR [rsp+0x48],r9
  6280bb:	4c 89 54 24 50       	mov    QWORD PTR [rsp+0x50],r10
  6280c0:	4c 89 6c 24 58       	mov    QWORD PTR [rsp+0x58],r13
  6280c5:	41 c7 40 40 0b c3 15 	mov    DWORD PTR [r8+0x40],0x4015c30b
  6280cc:	40 
  6280cd:	41 c7 40 44 01 00 01 	mov    DWORD PTR [r8+0x44],0x10001
  6280d4:	00 
  6280d5:	41 ff 50 38          	call   QWORD PTR [r8+0x38]
  6280d9:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  6280dd:	49 8b 80 48 02 00 00 	mov    rax,QWORD PTR [r8+0x248]
  6280e4:	48 89 44 24 70       	mov    QWORD PTR [rsp+0x70],rax
  6280e9:	4c 8b 5c 24 18       	mov    r11,QWORD PTR [rsp+0x18]
  6280ee:	4c 8b 64 24 28       	mov    r12,QWORD PTR [rsp+0x28]
  6280f3:	48 8b 6c 24 30       	mov    rbp,QWORD PTR [rsp+0x30]
  6280f8:	4c 8b 4c 24 48       	mov    r9,QWORD PTR [rsp+0x48]
  6280fd:	4c 8b 54 24 50       	mov    r10,QWORD PTR [rsp+0x50]
  628102:	4c 8b 6c 24 58       	mov    r13,QWORD PTR [rsp+0x58]
  628107:	4c 8b 5c 24 70       	mov    r11,QWORD PTR [rsp+0x70]
  62810c:	48 8b 3c 24          	mov    rdi,QWORD PTR [rsp]
  628110:	48 89 f8             	mov    rax,rdi
  628113:	ba 2c 0e 00 00       	mov    edx,0xe2c
  628118:	b9 24 00 00 00       	mov    ecx,0x24
  62811d:	be 00 00 00 00       	mov    esi,0x0
  628122:	e8 ae 0f 00 00       	call   0x6290d5
  628127:	8b 40 20             	mov    eax,DWORD PTR [rax+0x20]
  62812a:	4c 89 5c 24 18       	mov    QWORD PTR [rsp+0x18],r11
  62812f:	4c 89 64 24 28       	mov    QWORD PTR [rsp+0x28],r12
  628134:	48 89 6c 24 30       	mov    QWORD PTR [rsp+0x30],rbp
  628139:	4c 89 4c 24 48       	mov    QWORD PTR [rsp+0x48],r9
  62813e:	4c 89 54 24 50       	mov    QWORD PTR [rsp+0x50],r10
  628143:	4c 89 6c 24 58       	mov    QWORD PTR [rsp+0x58],r13
  628148:	e8 2f 13 9e ff       	call   0x947c
  62814d:	48 89 c7             	mov    rdi,rax
  628150:	48 89 7c 24 20       	mov    QWORD PTR [rsp+0x20],rdi
  628155:	48 8b 44 24 20       	mov    rax,QWORD PTR [rsp+0x20]
  62815a:	e8 dd 15 9e ff       	call   0x973c
  62815f:	48 89 c7             	mov    rdi,rax
  628162:	49 89 fd             	mov    r13,rdi
  628165:	4c 8b 5c 24 18       	mov    r11,QWORD PTR [rsp+0x18]
  62816a:	4c 8b 64 24 28       	mov    r12,QWORD PTR [rsp+0x28]
  62816f:	48 8b 6c 24 30       	mov    rbp,QWORD PTR [rsp+0x30]
  628174:	4c 8b 4c 24 48       	mov    r9,QWORD PTR [rsp+0x48]
  628179:	4c 8b 54 24 50       	mov    r10,QWORD PTR [rsp+0x50]
  62817e:	4c 89 6c 24 58       	mov    QWORD PTR [rsp+0x58],r13
  628183:	66 0f 1f 84 00 00 00 	nop    WORD PTR [rax+rax*1+0x0]
  62818a:	00 00 
  62818c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
  628190:	4c 89 ef             	mov    rdi,r13
  628193:	48 89 f8             	mov    rax,rdi
  628196:	ba 97 09 00 00       	mov    edx,0x997
  62819b:	b9 00 00 00 00       	mov    ecx,0x0
  6281a0:	be 14 00 00 00       	mov    esi,0x14
  6281a5:	e8 69 0c 00 00       	call   0x628e13
  6281aa:	85 c0                	test   eax,eax
  6281ac:	0f 84 c2 09 00 00    	je     0x628b74
  6281b2:	8b 7a 10             	mov    edi,DWORD PTR [rdx+0x10]
  6281b5:	49 89 fc             	mov    r12,rdi
  6281b8:	4c 89 e7             	mov    rdi,r12
  6281bb:	48 89 f8             	mov    rax,rdi
  6281be:	ba 2b 0e 00 00       	mov    edx,0xe2b
  6281c3:	b9 20 00 00 00       	mov    ecx,0x20
  6281c8:	be 00 00 00 00       	mov    esi,0x0
  6281cd:	e8 03 0f 00 00       	call   0x6290d5
  6281d2:	8b 40 1c             	mov    eax,DWORD PTR [rax+0x1c]
  6281d5:	49 89 c2             	mov    r10,rax
  6281d8:	4c 89 d7             	mov    rdi,r10
  6281db:	48 89 f8             	mov    rax,rdi
  6281de:	ba 73 0f 00 00       	mov    edx,0xf73
  6281e3:	b9 00 00 00 00       	mov    ecx,0x0
  6281e8:	be 18 00 00 00       	mov    esi,0x18
  6281ed:	e8 21 0c 00 00       	call   0x628e13
  6281f2:	4c 89 64 24 28       	mov    QWORD PTR [rsp+0x28],r12
  6281f7:	4c 89 54 24 50       	mov    QWORD PTR [rsp+0x50],r10
  6281fc:	85 c0                	test   eax,eax
  6281fe:	0f 84 3d 09 00 00    	je     0x628b41
  628204:	48 8b 7c 22 10       	mov    rdi,QWORD PTR [rdx+riz*1+0x10]
  628209:	48 89 fd             	mov    rbp,rdi
  62820c:	48 8b 7c 24 08       	mov    rdi,QWORD PTR [rsp+0x8]
  628211:	48 89 7c 24 68       	mov    QWORD PTR [rsp+0x68],rdi
  628216:	48 89 ef             	mov    rdi,rbp
  628219:	48 89 7c 24 60       	mov    QWORD PTR [rsp+0x60],rdi
  62821e:	48 8b 7c 24 60       	mov    rdi,QWORD PTR [rsp+0x60]
  628223:	48 8b 74 24 68       	mov    rsi,QWORD PTR [rsp+0x68]
  628228:	48 89 6c 24 30       	mov    QWORD PTR [rsp+0x30],rbp
  62822d:	48 39 f7             	cmp    rdi,rsi
  628230:	0f 85 34 00 00 00    	jne    0x62826a
  628236:	4c 89 e7             	mov    rdi,r12
  628239:	48 89 f8             	mov    rax,rdi
  62823c:	ba 2b 0e 00 00       	mov    edx,0xe2b
  628241:	b9 1c 00 00 00       	mov    ecx,0x1c
  628246:	be 00 00 00 00       	mov    esi,0x0
  62824b:	e8 85 0e 00 00       	call   0x6290d5
  628250:	8b 40 18             	mov    eax,DWORD PTR [rax+0x18]
  628253:	48 8b 4c 24 10       	mov    rcx,QWORD PTR [rsp+0x10]
  628258:	e8 13 87 ae ff       	call   0x110970
  62825d:	48 89 c7             	mov    rdi,rax
  628260:	48 89 7c 24 70       	mov    QWORD PTR [rsp+0x70],rdi
  628265:	e9 0a 00 00 00       	jmp    0x628274
  62826a:	bf 00 00 00 00       	mov    edi,0x0
  62826f:	48 89 7c 24 70       	mov    QWORD PTR [rsp+0x70],rdi
  628274:	8b 7c 24 70          	mov    edi,DWORD PTR [rsp+0x70]
  628278:	85 ff                	test   edi,edi
  62827a:	0f 84 bc 08 00 00    	je     0x628b3c
  628280:	4c 8b 5c 24 18       	mov    r11,QWORD PTR [rsp+0x18]
  628285:	4d 89 d9             	mov    r9,r11
  628288:	4c 89 cf             	mov    rdi,r9
  62828b:	48 89 f8             	mov    rax,rdi
  62828e:	ba 97 09 00 00       	mov    edx,0x997
  628293:	b9 00 00 00 00       	mov    ecx,0x0
  628298:	be 14 00 00 00       	mov    esi,0x14
  62829d:	e8 71 0b 00 00       	call   0x628e13
  6282a2:	4c 89 4c 24 48       	mov    QWORD PTR [rsp+0x48],r9
  6282a7:	85 c0                	test   eax,eax
  6282a9:	0f 84 46 04 00 00    	je     0x6286f5
  6282af:	8b 7a 10             	mov    edi,DWORD PTR [rdx+0x10]
  6282b2:	48 89 f8             	mov    rax,rdi
  6282b5:	ba 47 23 00 00       	mov    edx,0x2347
  6282ba:	b9 18 00 00 00       	mov    ecx,0x18
  6282bf:	be 00 00 00 00       	mov    esi,0x0
  6282c4:	e8 0c 0e 00 00       	call   0x6290d5
  6282c9:	48 8b 44 20 10       	mov    rax,QWORD PTR [rax+riz*1+0x10]
  6282ce:	48 89 44 24 38       	mov    QWORD PTR [rsp+0x38],rax
  6282d3:	4c 8b 64 24 28       	mov    r12,QWORD PTR [rsp+0x28]
  6282d8:	48 8b 7c 24 38       	mov    rdi,QWORD PTR [rsp+0x38]
  6282dd:	48 89 7c 24 70       	mov    QWORD PTR [rsp+0x70],rdi
  6282e2:	4c 89 e7             	mov    rdi,r12
  6282e5:	48 89 f8             	mov    rax,rdi
  6282e8:	ba 2b 0e 00 00       	mov    edx,0xe2b
  6282ed:	b9 18 00 00 00       	mov    ecx,0x18
  6282f2:	be 00 00 00 00       	mov    esi,0x0
  6282f7:	e8 d9 0d 00 00       	call   0x6290d5
  6282fc:	48 8b 44 20 10       	mov    rax,QWORD PTR [rax+riz*1+0x10]
  628301:	48 89 44 24 68       	mov    QWORD PTR [rsp+0x68],rax
  628306:	48 8b 7c 24 70       	mov    rdi,QWORD PTR [rsp+0x70]
  62830b:	48 89 7c 24 60       	mov    QWORD PTR [rsp+0x60],rdi
  628310:	48 8b 7c 24 60       	mov    rdi,QWORD PTR [rsp+0x60]
  628315:	48 8b 74 24 68       	mov    rsi,QWORD PTR [rsp+0x68]
  62831a:	f3 0f 6f 05 50 0f 00 	movdqu xmm0,XMMWORD PTR [rip+0xf50]        # 0x629272
  628321:	00 
  628322:	f3 0f 6f 0d 58 0f 00 	movdqu xmm1,XMMWORD PTR [rip+0xf58]        # 0x629282
  628329:	00 
  62832a:	f3 0f 6f 15 60 0f 00 	movdqu xmm2,XMMWORD PTR [rip+0xf60]        # 0x629292
  628331:	00 
  628332:	f3 0f 6f 1d 68 0f 00 	movdqu xmm3,XMMWORD PTR [rip+0xf68]        # 0x6292a2
  628339:	00 
  62833a:	48 39 f7             	cmp    rdi,rsi
  62833d:	40 0f 94 c7          	sete   dil
  628341:	40 0f b6 ff          	movzx  edi,dil
  628345:	48 89 7c 24 70       	mov    QWORD PTR [rsp+0x70],rdi
  62834a:	c4 e1 7a 7f 44 24 78 	vmovdqu XMMWORD PTR [rsp+0x78],xmm0
  628351:	c4 e1 7a 7f 8c 24 88 	vmovdqu XMMWORD PTR [rsp+0x88],xmm1
  628358:	00 00 00 
  62835b:	c4 e1 7a 7f 94 24 98 	vmovdqu XMMWORD PTR [rsp+0x98],xmm2
  628362:	00 00 00 
  628365:	c4 e1 7a 7f 9c 24 a8 	vmovdqu XMMWORD PTR [rsp+0xa8],xmm3
  62836c:	00 00 00 
  62836f:	bf 34 23 00 00       	mov    edi,0x2334
  628374:	48 89 bc 24 b8 00 00 	mov    QWORD PTR [rsp+0xb8],rdi
  62837b:	00 
  62837c:	bf 04 00 00 00       	mov    edi,0x4
  628381:	48 89 bc 24 c0 00 00 	mov    QWORD PTR [rsp+0xc0],rdi
  628388:	00 
  628389:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  62838d:	c4 e1 7a 6f 44 24 78 	vmovdqu xmm0,XMMWORD PTR [rsp+0x78]
  628394:	c4 c1 7a 7f 40 48    	vmovdqu XMMWORD PTR [r8+0x48],xmm0
  62839a:	c4 e1 7a 6f 84 24 88 	vmovdqu xmm0,XMMWORD PTR [rsp+0x88]
  6283a1:	00 00 00 
  6283a4:	c4 c1 7a 7f 40 58    	vmovdqu XMMWORD PTR [r8+0x58],xmm0
  6283aa:	c4 e1 7a 6f 84 24 98 	vmovdqu xmm0,XMMWORD PTR [rsp+0x98]
  6283b1:	00 00 00 
  6283b4:	c4 c1 7a 7f 40 68    	vmovdqu XMMWORD PTR [r8+0x68],xmm0
  6283ba:	c4 e1 7a 6f 84 24 a8 	vmovdqu xmm0,XMMWORD PTR [rsp+0xa8]
  6283c1:	00 00 00 
  6283c4:	c4 c1 7a 7f 40 78    	vmovdqu XMMWORD PTR [r8+0x78],xmm0
  6283ca:	8b 84 24 b8 00 00 00 	mov    eax,DWORD PTR [rsp+0xb8]
  6283d1:	49 89 80 88 00 00 00 	mov    QWORD PTR [r8+0x88],rax
  6283d8:	8b 84 24 c0 00 00 00 	mov    eax,DWORD PTR [rsp+0xc0]
  6283df:	49 89 80 90 00 00 00 	mov    QWORD PTR [r8+0x90],rax
  6283e6:	e8 bb 07 00 00       	call   0x628ba6
  6283eb:	0f 85 14 00 00 00    	jne    0x628405
  6283f1:	41 c7 40 40 22 c4 15 	mov    DWORD PTR [r8+0x40],0x4015c422
  6283f8:	40 
  6283f9:	41 c7 40 44 0a 00 01 	mov    DWORD PTR [r8+0x44],0x1000a
  628400:	00 
  628401:	41 ff 50 38          	call   QWORD PTR [r8+0x38]
  628405:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  628409:	49 8b b8 48 02 00 00 	mov    rdi,QWORD PTR [r8+0x248]
  628410:	4c 8b bb e0 fe ff ff 	mov    r15,QWORD PTR [rbx-0x120]
  628417:	48 89 7c 24 78       	mov    QWORD PTR [rsp+0x78],rdi
  62841c:	bf 00 00 00 00       	mov    edi,0x0
  628421:	48 89 bc 24 80 00 00 	mov    QWORD PTR [rsp+0x80],rdi
  628428:	00 
  628429:	bf 35 00 00 00       	mov    edi,0x35
  62842e:	48 89 bc 24 88 00 00 	mov    QWORD PTR [rsp+0x88],rdi
  628435:	00 
  628436:	bf 35 23 00 00       	mov    edi,0x2335
  62843b:	48 89 bc 24 90 00 00 	mov    QWORD PTR [rsp+0x90],rdi
  628442:	00 
  628443:	41 54                	push   r12
  628445:	41 50                	push   r8
  628447:	41 51                	push   r9
  628449:	41 52                	push   r10
  62844b:	41 53                	push   r11
  62844d:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  628454:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  628458:	41 8b 92 d4 8c 00 00 	mov    edx,DWORD PTR [r10+0x8cd4]
  62845f:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  628463:	41 83 b8 a0 00 00 00 	cmp    DWORD PTR [r8+0xa0],0x20
  62846a:	20 
  62846b:	0f 86 fe 01 00 00    	jbe    0x62866f
  628471:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  628478:	4d 85 d2             	test   r10,r10
  62847b:	0f 84 ee 01 00 00    	je     0x62866f
  628481:	41 8b 4a 04          	mov    ecx,DWORD PTR [r10+0x4]
  628485:	41 8b 42 08          	mov    eax,DWORD PTR [r10+0x8]
  628489:	81 f8 00 02 00 00    	cmp    eax,0x200
  62848f:	0f 87 da 01 00 00    	ja     0x62866f
  628495:	39 c1                	cmp    ecx,eax
  628497:	0f 83 d2 01 00 00    	jae    0x62866f
  62849d:	49 8d 44 8a 20       	lea    rax,[r10+rcx*4+0x20]
  6284a2:	8b 30                	mov    esi,DWORD PTR [rax]
  6284a4:	89 f0                	mov    eax,esi
  6284a6:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  6284aa:	48 c1 e0 04          	shl    rax,0x4
  6284ae:	49 01 c1             	add    r9,rax
  6284b1:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  6284b8:	48 85 c0             	test   rax,rax
  6284bb:	0f 84 ae 01 00 00    	je     0x62866f
  6284c1:	8b 08                	mov    ecx,DWORD PTR [rax]
  6284c3:	83 c1 07             	add    ecx,0x7
  6284c6:	83 e1 f8             	and    ecx,0xfffffff8
  6284c9:	41 8b 40 7c          	mov    eax,DWORD PTR [r8+0x7c]
  6284cd:	39 c1                	cmp    ecx,eax
  6284cf:	0f 87 9a 01 00 00    	ja     0x62866f
  6284d5:	29 c8                	sub    eax,ecx
  6284d7:	83 f8 20             	cmp    eax,0x20
  6284da:	0f 82 8f 01 00 00    	jb     0x62866f
  6284e0:	4d 8b 58 28          	mov    r11,QWORD PTR [r8+0x28]
  6284e4:	4d 85 db             	test   r11,r11
  6284e7:	0f 84 82 01 00 00    	je     0x62866f
  6284ed:	49 01 cb             	add    r11,rcx
  6284f0:	49 8b 80 98 00 00 00 	mov    rax,QWORD PTR [r8+0x98]
  6284f7:	48 85 c0             	test   rax,rax
  6284fa:	0f 84 6f 01 00 00    	je     0x62866f
  628500:	41 89 cc             	mov    r12d,ecx
  628503:	8b 84 24 a0 00 00 00 	mov    eax,DWORD PTR [rsp+0xa0]
  62850a:	85 c0                	test   eax,eax
  62850c:	0f 84 5d 01 00 00    	je     0x62866f
  628512:	89 c2                	mov    edx,eax
  628514:	83 e2 01             	and    edx,0x1
  628517:	85 d2                	test   edx,edx
  628519:	0f 85 50 01 00 00    	jne    0x62866f
  62851f:	d1 e8                	shr    eax,1
  628521:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  628525:	0f 83 44 01 00 00    	jae    0x62866f
  62852b:	4d 8b 50 08          	mov    r10,QWORD PTR [r8+0x8]
  62852f:	48 c1 e0 04          	shl    rax,0x4
  628533:	49 01 c2             	add    r10,rax
  628536:	41 8b 42 0c          	mov    eax,DWORD PTR [r10+0xc]
  62853a:	c1 e8 10             	shr    eax,0x10
  62853d:	81 e0 ff 00 00 00    	and    eax,0xff
  628543:	85 c0                	test   eax,eax
  628545:	0f 84 24 01 00 00    	je     0x62866f
  62854b:	83 f8 04             	cmp    eax,0x4
  62854e:	0f 87 1b 01 00 00    	ja     0x62866f
  628554:	48 6b c0 10          	imul   rax,rax,0x10
  628558:	4c 01 c0             	add    rax,r8
  62855b:	8b 50 20             	mov    edx,DWORD PTR [rax+0x20]
  62855e:	41 8b 0a             	mov    ecx,DWORD PTR [r10]
  628561:	39 d1                	cmp    ecx,edx
  628563:	0f 83 06 01 00 00    	jae    0x62866f
  628569:	29 ca                	sub    edx,ecx
  62856b:	45 8b 52 04          	mov    r10d,DWORD PTR [r10+0x4]
  62856f:	41 39 d2             	cmp    r10d,edx
  628572:	0f 87 f7 00 00 00    	ja     0x62866f
  628578:	41 83 fa 10          	cmp    r10d,0x10
  62857c:	0f 82 ed 00 00 00    	jb     0x62866f
  628582:	48 8b 40 18          	mov    rax,QWORD PTR [rax+0x18]
  628586:	48 85 c0             	test   rax,rax
  628589:	0f 84 e0 00 00 00    	je     0x62866f
  62858f:	48 01 c8             	add    rax,rcx
  628592:	8b 00                	mov    eax,DWORD PTR [rax]
  628594:	48 8b 93 e8 fe ff ff 	mov    rdx,QWORD PTR [rbx-0x118]
  62859b:	48 8b 52 10          	mov    rdx,QWORD PTR [rdx+0x10]
  62859f:	8b 92 d0 8c 00 00    	mov    edx,DWORD PTR [rdx+0x8cd0]
  6285a5:	39 d0                	cmp    eax,edx
  6285a7:	0f 85 c2 00 00 00    	jne    0x62866f
  6285ad:	44 89 e1             	mov    ecx,r12d
  6285b0:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  6285b7:	41 8b 52 04          	mov    edx,DWORD PTR [r10+0x4]
  6285bb:	48 8b 83 e8 fe ff ff 	mov    rax,QWORD PTR [rbx-0x118]
  6285c2:	48 8b 40 10          	mov    rax,QWORD PTR [rax+0x10]
  6285c6:	8b 80 d4 8c 00 00    	mov    eax,DWORD PTR [rax+0x8cd4]
  6285cc:	41 89 03             	mov    DWORD PTR [r11],eax
  6285cf:	41 c7 43 04 20 00 00 	mov    DWORD PTR [r11+0x4],0x20
  6285d6:	00 
  6285d7:	41 c7 43 08 00 00 00 	mov    DWORD PTR [r11+0x8],0x0
  6285de:	00 
  6285df:	41 c7 43 0c 00 00 00 	mov    DWORD PTR [r11+0xc],0x0
  6285e6:	00 
  6285e7:	8b 84 24 a0 00 00 00 	mov    eax,DWORD PTR [rsp+0xa0]
  6285ee:	41 89 43 10          	mov    DWORD PTR [r11+0x10],eax
  6285f2:	8b 84 24 a8 00 00 00 	mov    eax,DWORD PTR [rsp+0xa8]
  6285f9:	41 89 43 14          	mov    DWORD PTR [r11+0x14],eax
  6285fd:	8b 84 24 b0 00 00 00 	mov    eax,DWORD PTR [rsp+0xb0]
  628604:	41 89 43 18          	mov    DWORD PTR [r11+0x18],eax
  628608:	41 89 09             	mov    DWORD PTR [r9],ecx
  62860b:	41 c7 41 04 20 00 00 	mov    DWORD PTR [r9+0x4],0x20
  628612:	00 
  628613:	41 c7 41 08 00 00 00 	mov    DWORD PTR [r9+0x8],0x0
  62861a:	00 
  62861b:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  628622:	41 89 ca             	mov    r10d,ecx
  628625:	41 83 c2 20          	add    r10d,0x20
  628629:	44 89 10             	mov    DWORD PTR [rax],r10d
  62862c:	41 c7 41 0c 00 00 01 	mov    DWORD PTR [r9+0xc],0x10000
  628633:	00 
  628634:	83 c2 01             	add    edx,0x1
  628637:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  62863e:	41 89 52 04          	mov    DWORD PTR [r10+0x4],edx
  628642:	41 83 7a 18 00       	cmp    DWORD PTR [r10+0x18],0x0
  628647:	0f 84 11 00 00 00    	je     0x62865e
  62864d:	4d 8b 90 98 00 00 00 	mov    r10,QWORD PTR [r8+0x98]
  628654:	49 8b 02             	mov    rax,QWORD PTR [r10]
  628657:	48 83 c0 01          	add    rax,0x1
  62865b:	49 89 02             	mov    QWORD PTR [r10],rax
  62865e:	89 f0                	mov    eax,esi
  628660:	d1 e0                	shl    eax,1
  628662:	48 89 84 24 a0 00 00 	mov    QWORD PTR [rsp+0xa0],rax
  628669:	00 
  62866a:	e9 05 00 00 00       	jmp    0x628674
  62866f:	b8 00 00 00 00       	mov    eax,0x0
  628674:	85 c0                	test   eax,eax
  628676:	41 5b                	pop    r11
  628678:	41 5a                	pop    r10
  62867a:	41 59                	pop    r9
  62867c:	41 58                	pop    r8
  62867e:	41 5c                	pop    r12
  628680:	0f 85 52 00 00 00    	jne    0x6286d8
  628686:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  62868a:	48 8b 44 24 78       	mov    rax,QWORD PTR [rsp+0x78]
  62868f:	49 89 40 48          	mov    QWORD PTR [r8+0x48],rax
  628693:	8b 84 24 80 00 00 00 	mov    eax,DWORD PTR [rsp+0x80]
  62869a:	49 89 40 50          	mov    QWORD PTR [r8+0x50],rax
  62869e:	8b 84 24 88 00 00 00 	mov    eax,DWORD PTR [rsp+0x88]
  6286a5:	49 89 40 58          	mov    QWORD PTR [r8+0x58],rax
  6286a9:	8b 84 24 90 00 00 00 	mov    eax,DWORD PTR [rsp+0x90]
  6286b0:	49 89 40 60          	mov    QWORD PTR [r8+0x60],rax
  6286b4:	41 c7 40 40 0b c5 15 	mov    DWORD PTR [r8+0x40],0x4015c50b
  6286bb:	40 
  6286bc:	41 c7 40 44 04 00 01 	mov    DWORD PTR [r8+0x44],0x10004
  6286c3:	00 
  6286c4:	41 ff 50 38          	call   QWORD PTR [r8+0x38]
  6286c8:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  6286cc:	49 8b 80 48 02 00 00 	mov    rax,QWORD PTR [r8+0x248]
  6286d3:	48 89 44 24 78       	mov    QWORD PTR [rsp+0x78],rax
  6286d8:	48 8b 7c 24 70       	mov    rdi,QWORD PTR [rsp+0x70]
  6286dd:	48 8b 74 24 78       	mov    rsi,QWORD PTR [rsp+0x78]
  6286e2:	48 89 f8             	mov    rax,rdi
  6286e5:	48 89 f1             	mov    rcx,rsi
  6286e8:	e8 b3 cd af ff       	call   0x1254a0
  6286ed:	48 89 c7             	mov    rdi,rax
  6286f0:	e9 42 04 00 00       	jmp    0x628b37
  6286f5:	4c 89 cf             	mov    rdi,r9
  6286f8:	48 89 f8             	mov    rax,rdi
  6286fb:	ba 95 09 00 00       	mov    edx,0x995
  628700:	b9 00 00 00 00       	mov    ecx,0x0
  628705:	e8 81 08 00 00       	call   0x628f8b
  62870a:	85 c0                	test   eax,eax
  62870c:	0f 84 20 04 00 00    	je     0x628b32
  628712:	4c 8b 64 24 28       	mov    r12,QWORD PTR [rsp+0x28]
  628717:	4c 89 e7             	mov    rdi,r12
  62871a:	48 89 f8             	mov    rax,rdi
  62871d:	ba 2b 0e 00 00       	mov    edx,0xe2b
  628722:	b9 18 00 00 00       	mov    ecx,0x18
  628727:	be 00 00 00 00       	mov    esi,0x0
  62872c:	e8 a4 09 00 00       	call   0x6290d5
  628731:	48 8b 44 20 10       	mov    rax,QWORD PTR [rax+riz*1+0x10]
  628736:	48 89 44 24 70       	mov    QWORD PTR [rsp+0x70],rax
  62873b:	bf 47 23 00 00       	mov    edi,0x2347
  628740:	48 89 7c 24 78       	mov    QWORD PTR [rsp+0x78],rdi
  628745:	41 50                	push   r8
  628747:	41 51                	push   r9
  628749:	41 52                	push   r10
  62874b:	41 53                	push   r11
  62874d:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  628754:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  628758:	41 8b 92 1c 8d 00 00 	mov    edx,DWORD PTR [r10+0x8d1c]
  62875f:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  628763:	41 83 b8 a0 00 00 00 	cmp    DWORD PTR [r8+0xa0],0x18
  62876a:	18 
  62876b:	0f 86 39 01 00 00    	jbe    0x6288aa
  628771:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  628778:	4d 85 d2             	test   r10,r10
  62877b:	0f 84 29 01 00 00    	je     0x6288aa
  628781:	41 8b 4a 04          	mov    ecx,DWORD PTR [r10+0x4]
  628785:	41 8b 42 08          	mov    eax,DWORD PTR [r10+0x8]
  628789:	81 f8 00 02 00 00    	cmp    eax,0x200
  62878f:	0f 87 15 01 00 00    	ja     0x6288aa
  628795:	39 c1                	cmp    ecx,eax
  628797:	0f 83 0d 01 00 00    	jae    0x6288aa
  62879d:	49 8d 44 8a 20       	lea    rax,[r10+rcx*4+0x20]
  6287a2:	8b 30                	mov    esi,DWORD PTR [rax]
  6287a4:	89 f0                	mov    eax,esi
  6287a6:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  6287aa:	48 c1 e0 04          	shl    rax,0x4
  6287ae:	49 01 c1             	add    r9,rax
  6287b1:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  6287b8:	48 85 c0             	test   rax,rax
  6287bb:	0f 84 e9 00 00 00    	je     0x6288aa
  6287c1:	8b 08                	mov    ecx,DWORD PTR [rax]
  6287c3:	83 c1 07             	add    ecx,0x7
  6287c6:	83 e1 f8             	and    ecx,0xfffffff8
  6287c9:	41 8b 40 7c          	mov    eax,DWORD PTR [r8+0x7c]
  6287cd:	39 c1                	cmp    ecx,eax
  6287cf:	0f 87 d5 00 00 00    	ja     0x6288aa
  6287d5:	29 c8                	sub    eax,ecx
  6287d7:	83 f8 18             	cmp    eax,0x18
  6287da:	0f 82 ca 00 00 00    	jb     0x6288aa
  6287e0:	4d 8b 58 28          	mov    r11,QWORD PTR [r8+0x28]
  6287e4:	4d 85 db             	test   r11,r11
  6287e7:	0f 84 bd 00 00 00    	je     0x6288aa
  6287ed:	49 01 cb             	add    r11,rcx
  6287f0:	49 8b 80 98 00 00 00 	mov    rax,QWORD PTR [r8+0x98]
  6287f7:	48 85 c0             	test   rax,rax
  6287fa:	0f 84 aa 00 00 00    	je     0x6288aa
  628800:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  628807:	41 8b 52 04          	mov    edx,DWORD PTR [r10+0x4]
  62880b:	48 8b 83 e8 fe ff ff 	mov    rax,QWORD PTR [rbx-0x118]
  628812:	48 8b 40 10          	mov    rax,QWORD PTR [rax+0x10]
  628816:	8b 80 1c 8d 00 00    	mov    eax,DWORD PTR [rax+0x8d1c]
  62881c:	41 89 03             	mov    DWORD PTR [r11],eax
  62881f:	41 c7 43 04 18 00 00 	mov    DWORD PTR [r11+0x4],0x18
  628826:	00 
  628827:	41 c7 43 08 00 00 00 	mov    DWORD PTR [r11+0x8],0x0
  62882e:	00 
  62882f:	41 c7 43 0c 01 00 00 	mov    DWORD PTR [r11+0xc],0x1
  628836:	00 
  628837:	48 8b 84 24 90 00 00 	mov    rax,QWORD PTR [rsp+0x90]
  62883e:	00 
  62883f:	49 89 43 10          	mov    QWORD PTR [r11+0x10],rax
  628843:	41 89 09             	mov    DWORD PTR [r9],ecx
  628846:	41 c7 41 04 18 00 00 	mov    DWORD PTR [r9+0x4],0x18
  62884d:	00 
  62884e:	41 c7 41 08 00 00 00 	mov    DWORD PTR [r9+0x8],0x0
  628855:	00 
  628856:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  62885d:	41 89 ca             	mov    r10d,ecx
  628860:	41 83 c2 18          	add    r10d,0x18
  628864:	44 89 10             	mov    DWORD PTR [rax],r10d
  628867:	41 c7 41 0c 00 00 01 	mov    DWORD PTR [r9+0xc],0x10000
  62886e:	00 
  62886f:	83 c2 01             	add    edx,0x1
  628872:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  628879:	41 89 52 04          	mov    DWORD PTR [r10+0x4],edx
  62887d:	41 83 7a 18 00       	cmp    DWORD PTR [r10+0x18],0x0
  628882:	0f 84 11 00 00 00    	je     0x628899
  628888:	4d 8b 90 98 00 00 00 	mov    r10,QWORD PTR [r8+0x98]
  62888f:	49 8b 02             	mov    rax,QWORD PTR [r10]
  628892:	48 83 c0 01          	add    rax,0x1
  628896:	49 89 02             	mov    QWORD PTR [r10],rax
  628899:	89 f0                	mov    eax,esi
  62889b:	d1 e0                	shl    eax,1
  62889d:	48 89 84 24 90 00 00 	mov    QWORD PTR [rsp+0x90],rax
  6288a4:	00 
  6288a5:	e9 05 00 00 00       	jmp    0x6288af
  6288aa:	b8 00 00 00 00       	mov    eax,0x0
  6288af:	85 c0                	test   eax,eax
  6288b1:	41 5b                	pop    r11
  6288b3:	41 5a                	pop    r10
  6288b5:	41 59                	pop    r9
  6288b7:	41 58                	pop    r8
  6288b9:	0f 85 48 00 00 00    	jne    0x628907
  6288bf:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  6288c3:	48 8b 44 24 70       	mov    rax,QWORD PTR [rsp+0x70]
  6288c8:	49 89 40 48          	mov    QWORD PTR [r8+0x48],rax
  6288cc:	8b 44 24 78          	mov    eax,DWORD PTR [rsp+0x78]
  6288d0:	49 89 40 50          	mov    QWORD PTR [r8+0x50],rax
  6288d4:	41 c7 40 40 0b c6 15 	mov    DWORD PTR [r8+0x40],0x4015c60b
  6288db:	40 
  6288dc:	41 c7 40 44 02 00 01 	mov    DWORD PTR [r8+0x44],0x10002
  6288e3:	00 
  6288e4:	41 ff 50 38          	call   QWORD PTR [r8+0x38]
  6288e8:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  6288ec:	49 8b 80 48 02 00 00 	mov    rax,QWORD PTR [r8+0x248]
  6288f3:	48 89 44 24 70       	mov    QWORD PTR [rsp+0x70],rax
  6288f8:	4c 8b 5c 24 18       	mov    r11,QWORD PTR [rsp+0x18]
  6288fd:	4c 8b 64 24 28       	mov    r12,QWORD PTR [rsp+0x28]
  628902:	4c 8b 4c 24 48       	mov    r9,QWORD PTR [rsp+0x48]
  628907:	bf 97 09 00 00       	mov    edi,0x997
  62890c:	48 89 7c 24 78       	mov    QWORD PTR [rsp+0x78],rdi
  628911:	41 50                	push   r8
  628913:	41 51                	push   r9
  628915:	41 52                	push   r10
  628917:	41 53                	push   r11
  628919:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  628920:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  628924:	41 8b 92 5c 26 00 00 	mov    edx,DWORD PTR [r10+0x265c]
  62892b:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  62892f:	41 83 b8 a0 00 00 00 	cmp    DWORD PTR [r8+0xa0],0x18
  628936:	18 
  628937:	0f 86 89 01 00 00    	jbe    0x628ac6
  62893d:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  628944:	4d 85 d2             	test   r10,r10
  628947:	0f 84 79 01 00 00    	je     0x628ac6
  62894d:	41 8b 4a 04          	mov    ecx,DWORD PTR [r10+0x4]
  628951:	41 8b 42 08          	mov    eax,DWORD PTR [r10+0x8]
  628955:	81 f8 00 02 00 00    	cmp    eax,0x200
  62895b:	0f 87 65 01 00 00    	ja     0x628ac6
  628961:	39 c1                	cmp    ecx,eax
  628963:	0f 83 5d 01 00 00    	jae    0x628ac6
  628969:	49 8d 44 8a 20       	lea    rax,[r10+rcx*4+0x20]
  62896e:	8b 30                	mov    esi,DWORD PTR [rax]
  628970:	89 f0                	mov    eax,esi
  628972:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  628976:	48 c1 e0 04          	shl    rax,0x4
  62897a:	49 01 c1             	add    r9,rax
  62897d:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  628984:	48 85 c0             	test   rax,rax
  628987:	0f 84 39 01 00 00    	je     0x628ac6
  62898d:	8b 08                	mov    ecx,DWORD PTR [rax]
  62898f:	83 c1 07             	add    ecx,0x7
  628992:	83 e1 f8             	and    ecx,0xfffffff8
  628995:	41 8b 40 7c          	mov    eax,DWORD PTR [r8+0x7c]
  628999:	39 c1                	cmp    ecx,eax
  62899b:	0f 87 25 01 00 00    	ja     0x628ac6
  6289a1:	29 c8                	sub    eax,ecx
  6289a3:	83 f8 18             	cmp    eax,0x18
  6289a6:	0f 82 1a 01 00 00    	jb     0x628ac6
  6289ac:	4d 8b 58 28          	mov    r11,QWORD PTR [r8+0x28]
  6289b0:	4d 85 db             	test   r11,r11
  6289b3:	0f 84 0d 01 00 00    	je     0x628ac6
  6289b9:	49 01 cb             	add    r11,rcx
  6289bc:	49 8b 80 98 00 00 00 	mov    rax,QWORD PTR [r8+0x98]
  6289c3:	48 85 c0             	test   rax,rax
  6289c6:	0f 84 fa 00 00 00    	je     0x628ac6
  6289cc:	8b 84 24 90 00 00 00 	mov    eax,DWORD PTR [rsp+0x90]
  6289d3:	85 c0                	test   eax,eax
  6289d5:	0f 84 42 00 00 00    	je     0x628a1d
  6289db:	89 c2                	mov    edx,eax
  6289dd:	83 e2 01             	and    edx,0x1
  6289e0:	85 d2                	test   edx,edx
  6289e2:	0f 85 35 00 00 00    	jne    0x628a1d
  6289e8:	d1 e8                	shr    eax,1
  6289ea:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  6289ee:	0f 83 d2 00 00 00    	jae    0x628ac6
  6289f4:	4d 8b 50 08          	mov    r10,QWORD PTR [r8+0x8]
  6289f8:	48 c1 e0 04          	shl    rax,0x4
  6289fc:	49 01 c2             	add    r10,rax
  6289ff:	41 8b 42 0c          	mov    eax,DWORD PTR [r10+0xc]
  628a03:	c1 e8 10             	shr    eax,0x10
  628a06:	81 e0 ff 00 00 00    	and    eax,0xff
  628a0c:	85 c0                	test   eax,eax
  628a0e:	0f 84 b2 00 00 00    	je     0x628ac6
  628a14:	83 f8 04             	cmp    eax,0x4
  628a17:	0f 87 a9 00 00 00    	ja     0x628ac6
  628a1d:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  628a24:	41 8b 52 04          	mov    edx,DWORD PTR [r10+0x4]
  628a28:	48 8b 83 e8 fe ff ff 	mov    rax,QWORD PTR [rbx-0x118]
  628a2f:	48 8b 40 10          	mov    rax,QWORD PTR [rax+0x10]
  628a33:	8b 80 5c 26 00 00    	mov    eax,DWORD PTR [rax+0x265c]
  628a39:	41 89 03             	mov    DWORD PTR [r11],eax
  628a3c:	41 c7 43 04 18 00 00 	mov    DWORD PTR [r11+0x4],0x18
  628a43:	00 
  628a44:	41 c7 43 08 00 00 00 	mov    DWORD PTR [r11+0x8],0x0
  628a4b:	00 
  628a4c:	41 c7 43 0c 00 00 00 	mov    DWORD PTR [r11+0xc],0x0
  628a53:	00 
  628a54:	8b 84 24 90 00 00 00 	mov    eax,DWORD PTR [rsp+0x90]
  628a5b:	41 89 43 10          	mov    DWORD PTR [r11+0x10],eax
  628a5f:	41 89 09             	mov    DWORD PTR [r9],ecx
  628a62:	41 c7 41 04 18 00 00 	mov    DWORD PTR [r9+0x4],0x18
  628a69:	00 
  628a6a:	41 c7 41 08 00 00 00 	mov    DWORD PTR [r9+0x8],0x0
  628a71:	00 
  628a72:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  628a79:	41 89 ca             	mov    r10d,ecx
  628a7c:	41 83 c2 18          	add    r10d,0x18
  628a80:	44 89 10             	mov    DWORD PTR [rax],r10d
  628a83:	41 c7 41 0c 00 00 01 	mov    DWORD PTR [r9+0xc],0x10000
  628a8a:	00 
  628a8b:	83 c2 01             	add    edx,0x1
  628a8e:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  628a95:	41 89 52 04          	mov    DWORD PTR [r10+0x4],edx
  628a99:	41 83 7a 18 00       	cmp    DWORD PTR [r10+0x18],0x0
  628a9e:	0f 84 11 00 00 00    	je     0x628ab5
  628aa4:	4d 8b 90 98 00 00 00 	mov    r10,QWORD PTR [r8+0x98]
  628aab:	49 8b 02             	mov    rax,QWORD PTR [r10]
  628aae:	48 83 c0 01          	add    rax,0x1
  628ab2:	49 89 02             	mov    QWORD PTR [r10],rax
  628ab5:	89 f0                	mov    eax,esi
  628ab7:	d1 e0                	shl    eax,1
  628ab9:	48 89 84 24 90 00 00 	mov    QWORD PTR [rsp+0x90],rax
  628ac0:	00 
  628ac1:	e9 05 00 00 00       	jmp    0x628acb
  628ac6:	b8 00 00 00 00       	mov    eax,0x0
  628acb:	85 c0                	test   eax,eax
  628acd:	41 5b                	pop    r11
  628acf:	41 5a                	pop    r10
  628ad1:	41 59                	pop    r9
  628ad3:	41 58                	pop    r8
  628ad5:	0f 85 48 00 00 00    	jne    0x628b23
  628adb:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  628adf:	48 8b 44 24 70       	mov    rax,QWORD PTR [rsp+0x70]
  628ae4:	49 89 40 48          	mov    QWORD PTR [r8+0x48],rax
  628ae8:	8b 44 24 78          	mov    eax,DWORD PTR [rsp+0x78]
  628aec:	49 89 40 50          	mov    QWORD PTR [r8+0x50],rax
  628af0:	41 c7 40 40 0b c7 15 	mov    DWORD PTR [r8+0x40],0x4015c70b
  628af7:	40 
  628af8:	41 c7 40 44 02 00 01 	mov    DWORD PTR [r8+0x44],0x10002
  628aff:	00 
  628b00:	41 ff 50 38          	call   QWORD PTR [r8+0x38]
  628b04:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  628b08:	49 8b 80 48 02 00 00 	mov    rax,QWORD PTR [r8+0x248]
  628b0f:	48 89 44 24 70       	mov    QWORD PTR [rsp+0x70],rax
  628b14:	4c 8b 5c 24 18       	mov    r11,QWORD PTR [rsp+0x18]
  628b19:	4c 8b 64 24 28       	mov    r12,QWORD PTR [rsp+0x28]
  628b1e:	4c 8b 4c 24 48       	mov    r9,QWORD PTR [rsp+0x48]
  628b23:	4c 8b 5c 24 70       	mov    r11,QWORD PTR [rsp+0x70]
  628b28:	4c 89 5c 24 18       	mov    QWORD PTR [rsp+0x18],r11
  628b2d:	e9 05 00 00 00       	jmp    0x628b37
  628b32:	e9 91 06 00 00       	jmp    0x6291c8
  628b37:	e9 00 00 00 00       	jmp    0x628b3c
  628b3c:	e9 00 00 00 00       	jmp    0x628b41
  628b41:	48 8b 44 24 20       	mov    rax,QWORD PTR [rsp+0x20]
  628b46:	e8 f1 0b 9e ff       	call   0x973c
  628b4b:	48 89 c7             	mov    rdi,rax
  628b4e:	49 89 fd             	mov    r13,rdi
  628b51:	4c 89 6c 24 58       	mov    QWORD PTR [rsp+0x58],r13
  628b56:	4c 8b 5c 24 18       	mov    r11,QWORD PTR [rsp+0x18]
  628b5b:	4c 8b 64 24 28       	mov    r12,QWORD PTR [rsp+0x28]
  628b60:	48 8b 6c 24 30       	mov    rbp,QWORD PTR [rsp+0x30]
  628b65:	4c 8b 4c 24 48       	mov    r9,QWORD PTR [rsp+0x48]
  628b6a:	4c 8b 54 24 50       	mov    r10,QWORD PTR [rsp+0x50]
  628b6f:	e9 1c f6 ff ff       	jmp    0x628190
  628b74:	4c 89 ef             	mov    rdi,r13
  628b77:	48 89 f8             	mov    rax,rdi
  628b7a:	ba 95 09 00 00       	mov    edx,0x995
  628b7f:	b9 00 00 00 00       	mov    ecx,0x0
  628b84:	e8 02 04 00 00       	call   0x628f8b
  628b89:	85 c0                	test   eax,eax
  628b8b:	0f 84 05 00 00 00    	je     0x628b96
  628b91:	e9 05 00 00 00       	jmp    0x628b9b
  628b96:	e9 2d 06 00 00       	jmp    0x6291c8
  628b9b:	4c 89 d8             	mov    rax,r11
  628b9e:	48 81 c4 d8 00 00 00 	add    rsp,0xd8
  628ba5:	c3                   	ret
  628ba6:	41 50                	push   r8
  628ba8:	41 51                	push   r9
  628baa:	41 52                	push   r10
  628bac:	41 53                	push   r11
  628bae:	41 54                	push   r12
  628bb0:	41 55                	push   r13
  628bb2:	41 56                	push   r14
  628bb4:	41 57                	push   r15
  628bb6:	4d 89 c4             	mov    r12,r8
  628bb9:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  628bc0:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  628bc4:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  628bcb:	49 8b 80 88 00 00 00 	mov    rax,QWORD PTR [r8+0x88]
  628bd2:	4d 85 d2             	test   r10,r10
  628bd5:	0f 84 20 02 00 00    	je     0x628dfb
  628bdb:	48 85 c0             	test   rax,rax
  628bde:	0f 84 17 02 00 00    	je     0x628dfb
  628be4:	8b 10                	mov    edx,DWORD PTR [rax]
  628be6:	41 8b 02             	mov    eax,DWORD PTR [r10]
  628be9:	39 d0                	cmp    eax,edx
  628beb:	0f 85 0a 02 00 00    	jne    0x628dfb
  628bf1:	41 8b 4a 04          	mov    ecx,DWORD PTR [r10+0x4]
  628bf5:	41 8b 42 08          	mov    eax,DWORD PTR [r10+0x8]
  628bf9:	81 f8 00 02 00 00    	cmp    eax,0x200
  628bff:	0f 87 f6 01 00 00    	ja     0x628dfb
  628c05:	39 c1                	cmp    ecx,eax
  628c07:	0f 83 ee 01 00 00    	jae    0x628dfb
  628c0d:	41 8b 72 0c          	mov    esi,DWORD PTR [r10+0xc]
  628c11:	85 f6                	test   esi,esi
  628c13:	0f 84 08 00 00 00    	je     0x628c21
  628c19:	8d 34 0e             	lea    esi,[rsi+rcx*1]
  628c1c:	e9 07 00 00 00       	jmp    0x628c28
  628c21:	49 8d 44 8a 20       	lea    rax,[r10+rcx*4+0x20]
  628c26:	8b 30                	mov    esi,DWORD PTR [rax]
  628c28:	85 f6                	test   esi,esi
  628c2a:	0f 84 cb 01 00 00    	je     0x628dfb
  628c30:	89 f0                	mov    eax,esi
  628c32:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  628c36:	0f 83 bf 01 00 00    	jae    0x628dfb
  628c3c:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  628c40:	48 c1 e0 04          	shl    rax,0x4
  628c44:	49 01 c1             	add    r9,rax
  628c47:	41 8b 41 0c          	mov    eax,DWORD PTR [r9+0xc]
  628c4b:	c1 e8 10             	shr    eax,0x10
  628c4e:	81 e0 ff 00 00 00    	and    eax,0xff
  628c54:	85 c0                	test   eax,eax
  628c56:	0f 85 9f 01 00 00    	jne    0x628dfb
  628c5c:	41 bd 04 00 00 00    	mov    r13d,0x4
  628c62:	41 81 fd fe ff ff 0f 	cmp    r13d,0xffffffe
  628c69:	0f 87 8c 01 00 00    	ja     0x628dfb
  628c6f:	45 89 ee             	mov    r14d,r13d
  628c72:	41 c1 e6 04          	shl    r14d,0x4
  628c76:	41 83 c6 17          	add    r14d,0x17
  628c7a:	41 83 e6 f8          	and    r14d,0xfffffff8
  628c7e:	41 8b 80 a0 00 00 00 	mov    eax,DWORD PTR [r8+0xa0]
  628c85:	85 c0                	test   eax,eax
  628c87:	0f 84 6e 01 00 00    	je     0x628dfb
  628c8d:	41 83 7a 18 00       	cmp    DWORD PTR [r10+0x18],0x0
  628c92:	0f 85 34 00 00 00    	jne    0x628ccc
  628c98:	41 8b 80 a0 00 00 00 	mov    eax,DWORD PTR [r8+0xa0]
  628c9f:	41 39 c6             	cmp    r14d,eax
  628ca2:	0f 83 53 01 00 00    	jae    0x628dfb
  628ca8:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  628caf:	48 85 c0             	test   rax,rax
  628cb2:	0f 84 43 01 00 00    	je     0x628dfb
  628cb8:	44 8b 38             	mov    r15d,DWORD PTR [rax]
  628cbb:	41 83 c7 0f          	add    r15d,0xf
  628cbf:	41 83 e7 f0          	and    r15d,0xfffffff0
  628cc3:	41 8b 40 7c          	mov    eax,DWORD PTR [r8+0x7c]
  628cc7:	e9 10 00 00 00       	jmp    0x628cdc
  628ccc:	45 8b 7a 14          	mov    r15d,DWORD PTR [r10+0x14]
  628cd0:	41 83 c7 0f          	add    r15d,0xf
  628cd4:	41 83 e7 f0          	and    r15d,0xfffffff0
  628cd8:	41 8b 42 18          	mov    eax,DWORD PTR [r10+0x18]
  628cdc:	41 39 c7             	cmp    r15d,eax
  628cdf:	0f 87 16 01 00 00    	ja     0x628dfb
  628ce5:	44 29 f8             	sub    eax,r15d
  628ce8:	44 39 f0             	cmp    eax,r14d
  628ceb:	0f 82 0a 01 00 00    	jb     0x628dfb
  628cf1:	4d 8b 58 28          	mov    r11,QWORD PTR [r8+0x28]
  628cf5:	4d 85 db             	test   r11,r11
  628cf8:	0f 84 fd 00 00 00    	je     0x628dfb
  628cfe:	4d 01 fb             	add    r11,r15
  628d01:	49 8b 80 98 00 00 00 	mov    rax,QWORD PTR [r8+0x98]
  628d08:	48 85 c0             	test   rax,rax
  628d0b:	0f 84 ea 00 00 00    	je     0x628dfb
  628d11:	48 8b 83 e8 fe ff ff 	mov    rax,QWORD PTR [rbx-0x118]
  628d18:	48 8b 40 10          	mov    rax,QWORD PTR [rax+0x10]
  628d1c:	8b 80 d0 8c 00 00    	mov    eax,DWORD PTR [rax+0x8cd0]
  628d22:	41 89 03             	mov    DWORD PTR [r11],eax
  628d25:	45 89 73 04          	mov    DWORD PTR [r11+0x4],r14d
  628d29:	45 89 6b 08          	mov    DWORD PTR [r11+0x8],r13d
  628d2d:	41 c7 43 0c 01 00 00 	mov    DWORD PTR [r11+0xc],0x1
  628d34:	00 
  628d35:	31 d2                	xor    edx,edx
  628d37:	49 8b 44 24 48       	mov    rax,QWORD PTR [r12+0x48]
  628d3c:	49 89 43 10          	mov    QWORD PTR [r11+0x10],rax
  628d40:	49 8b 44 24 50       	mov    rax,QWORD PTR [r12+0x50]
  628d45:	49 89 43 18          	mov    QWORD PTR [r11+0x18],rax
  628d49:	49 8b 44 24 58       	mov    rax,QWORD PTR [r12+0x58]
  628d4e:	49 89 43 20          	mov    QWORD PTR [r11+0x20],rax
  628d52:	49 8b 44 24 60       	mov    rax,QWORD PTR [r12+0x60]
  628d57:	49 89 43 28          	mov    QWORD PTR [r11+0x28],rax
  628d5b:	49 8b 44 24 68       	mov    rax,QWORD PTR [r12+0x68]
  628d60:	49 89 43 30          	mov    QWORD PTR [r11+0x30],rax
  628d64:	49 8b 44 24 70       	mov    rax,QWORD PTR [r12+0x70]
  628d69:	49 89 43 38          	mov    QWORD PTR [r11+0x38],rax
  628d6d:	49 8b 44 24 78       	mov    rax,QWORD PTR [r12+0x78]
  628d72:	49 89 43 40          	mov    QWORD PTR [r11+0x40],rax
  628d76:	49 8b 84 24 80 00 00 	mov    rax,QWORD PTR [r12+0x80]
  628d7d:	00 
  628d7e:	49 89 43 48          	mov    QWORD PTR [r11+0x48],rax
  628d82:	45 89 39             	mov    DWORD PTR [r9],r15d
  628d85:	45 89 71 04          	mov    DWORD PTR [r9+0x4],r14d
  628d89:	41 c7 41 08 00 00 00 	mov    DWORD PTR [r9+0x8],0x0
  628d90:	00 
  628d91:	44 89 f8             	mov    eax,r15d
  628d94:	44 01 f0             	add    eax,r14d
  628d97:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  628d9e:	41 83 7a 18 00       	cmp    DWORD PTR [r10+0x18],0x0
  628da3:	0f 85 0e 00 00 00    	jne    0x628db7
  628da9:	49 8b 90 90 00 00 00 	mov    rdx,QWORD PTR [r8+0x90]
  628db0:	89 02                	mov    DWORD PTR [rdx],eax
  628db2:	e9 04 00 00 00       	jmp    0x628dbb
  628db7:	41 89 42 14          	mov    DWORD PTR [r10+0x14],eax
  628dbb:	41 c7 41 0c 00 00 01 	mov    DWORD PTR [r9+0xc],0x10000
  628dc2:	00 
  628dc3:	41 8b 52 04          	mov    edx,DWORD PTR [r10+0x4]
  628dc7:	83 c2 01             	add    edx,0x1
  628dca:	41 89 52 04          	mov    DWORD PTR [r10+0x4],edx
  628dce:	41 83 7a 18 00       	cmp    DWORD PTR [r10+0x18],0x0
  628dd3:	0f 84 11 00 00 00    	je     0x628dea
  628dd9:	4d 8b 90 98 00 00 00 	mov    r10,QWORD PTR [r8+0x98]
  628de0:	49 8b 02             	mov    rax,QWORD PTR [r10]
  628de3:	48 83 c0 01          	add    rax,0x1
  628de7:	49 89 02             	mov    QWORD PTR [r10],rax
  628dea:	89 f0                	mov    eax,esi
  628dec:	d1 e0                	shl    eax,1
  628dee:	49 89 84 24 48 02 00 	mov    QWORD PTR [r12+0x248],rax
  628df5:	00 
  628df6:	e9 05 00 00 00       	jmp    0x628e00
  628dfb:	b8 00 00 00 00       	mov    eax,0x0
  628e00:	85 c0                	test   eax,eax
  628e02:	41 5f                	pop    r15
  628e04:	41 5e                	pop    r14
  628e06:	41 5d                	pop    r13
  628e08:	41 5c                	pop    r12
  628e0a:	41 5b                	pop    r11
  628e0c:	41 5a                	pop    r10
  628e0e:	41 59                	pop    r9
  628e10:	41 58                	pop    r8
  628e12:	c3                   	ret
  628e13:	41 51                	push   r9
  628e15:	41 52                	push   r10
  628e17:	41 53                	push   r11
  628e19:	49 89 c2             	mov    r10,rax
  628e1c:	49 c1 ea 20          	shr    r10,0x20
  628e20:	4d 85 d2             	test   r10,r10
  628e23:	0f 85 46 01 00 00    	jne    0x628f6f
  628e29:	85 c0                	test   eax,eax
  628e2b:	0f 85 0c 00 00 00    	jne    0x628e3d
  628e31:	89 c8                	mov    eax,ecx
  628e33:	ba 00 00 00 00       	mov    edx,0x0
  628e38:	e9 3c 01 00 00       	jmp    0x628f79
  628e3d:	41 89 c2             	mov    r10d,eax
  628e40:	41 83 e2 01          	and    r10d,0x1
  628e44:	45 85 d2             	test   r10d,r10d
  628e47:	0f 85 22 01 00 00    	jne    0x628f6f
  628e4d:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  628e54:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  628e58:	48 6b d2 04          	imul   rdx,rdx,0x4
  628e5c:	41 8b 14 12          	mov    edx,DWORD PTR [r10+rdx*1]
  628e60:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  628e64:	d1 e8                	shr    eax,1
  628e66:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  628e6a:	0f 83 10 01 00 00    	jae    0x628f80
  628e70:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  628e74:	48 c1 e0 04          	shl    rax,0x4
  628e78:	49 01 c1             	add    r9,rax
  628e7b:	45 0f b6 54 21 0e    	movzx  r10d,BYTE PTR [r9+riz*1+0xe]
  628e81:	45 85 d2             	test   r10d,r10d
  628e84:	0f 84 f6 00 00 00    	je     0x628f80
  628e8a:	41 83 fa 04          	cmp    r10d,0x4
  628e8e:	0f 87 ec 00 00 00    	ja     0x628f80
  628e94:	41 c1 e2 04          	shl    r10d,0x4
  628e98:	4f 8b 5c 10 18       	mov    r11,QWORD PTR [r8+r10*1+0x18]
  628e9d:	47 8b 44 10 20       	mov    r8d,DWORD PTR [r8+r10*1+0x20]
  628ea2:	41 8b 01             	mov    eax,DWORD PTR [r9]
  628ea5:	44 39 c0             	cmp    eax,r8d
  628ea8:	0f 87 d2 00 00 00    	ja     0x628f80
  628eae:	41 29 c0             	sub    r8d,eax
  628eb1:	41 8b 49 04          	mov    ecx,DWORD PTR [r9+0x4]
  628eb5:	44 39 c1             	cmp    ecx,r8d
  628eb8:	0f 87 c2 00 00 00    	ja     0x628f80
  628ebe:	83 f9 10             	cmp    ecx,0x10
  628ec1:	0f 82 b9 00 00 00    	jb     0x628f80
  628ec7:	89 cf                	mov    edi,ecx
  628ec9:	49 01 c3             	add    r11,rax
  628ecc:	41 8b 0b             	mov    ecx,DWORD PTR [r11]
  628ecf:	39 d1                	cmp    ecx,edx
  628ed1:	0f 84 6c 00 00 00    	je     0x628f43
  628ed7:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  628ede:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  628ee2:	89 c8                	mov    eax,ecx
  628ee4:	41 3b 80 a4 00 00 00 	cmp    eax,DWORD PTR [r8+0xa4]
  628eeb:	0f 83 8f 00 00 00    	jae    0x628f80
  628ef1:	89 d0                	mov    eax,edx
  628ef3:	41 3b 80 a4 00 00 00 	cmp    eax,DWORD PTR [r8+0xa4]
  628efa:	0f 83 80 00 00 00    	jae    0x628f80
  628f00:	4d 8b 90 a8 00 00 00 	mov    r10,QWORD PTR [r8+0xa8]
  628f07:	4d 85 d2             	test   r10,r10
  628f0a:	0f 84 70 00 00 00    	je     0x628f80
  628f10:	89 c8                	mov    eax,ecx
  628f12:	48 6b c0 08          	imul   rax,rax,0x8
  628f16:	4d 8b 0c 02          	mov    r9,QWORD PTR [r10+rax*1]
  628f1a:	89 d0                	mov    eax,edx
  628f1c:	48 6b c0 08          	imul   rax,rax,0x8
  628f20:	4d 8b 14 02          	mov    r10,QWORD PTR [r10+rax*1]
  628f24:	4c 89 c8             	mov    rax,r9
  628f27:	48 c1 e8 20          	shr    rax,0x20
  628f2b:	4c 89 d1             	mov    rcx,r10
  628f2e:	48 c1 e9 20          	shr    rcx,0x20
  628f32:	39 c8                	cmp    eax,ecx
  628f34:	0f 82 35 00 00 00    	jb     0x628f6f
  628f3a:	45 39 d1             	cmp    r9d,r10d
  628f3d:	0f 87 2c 00 00 00    	ja     0x628f6f
  628f43:	41 8b 03             	mov    eax,DWORD PTR [r11]
  628f46:	39 d0                	cmp    eax,edx
  628f48:	0f 85 32 00 00 00    	jne    0x628f80
  628f4e:	39 f7                	cmp    edi,esi
  628f50:	0f 82 2a 00 00 00    	jb     0x628f80
  628f56:	41 8b 43 04          	mov    eax,DWORD PTR [r11+0x4]
  628f5a:	39 f0                	cmp    eax,esi
  628f5c:	0f 82 1e 00 00 00    	jb     0x628f80
  628f62:	4c 89 da             	mov    rdx,r11
  628f65:	b8 01 00 00 00       	mov    eax,0x1
  628f6a:	e9 0a 00 00 00       	jmp    0x628f79
  628f6f:	b8 00 00 00 00       	mov    eax,0x0
  628f74:	ba 00 00 00 00       	mov    edx,0x0
  628f79:	41 5b                	pop    r11
  628f7b:	41 5a                	pop    r10
  628f7d:	41 59                	pop    r9
  628f7f:	c3                   	ret
  628f80:	41 5b                	pop    r11
  628f82:	41 5a                	pop    r10
  628f84:	41 59                	pop    r9
  628f86:	e9 bf 02 00 00       	jmp    0x62924a
  628f8b:	41 51                	push   r9
  628f8d:	41 52                	push   r10
  628f8f:	41 53                	push   r11
  628f91:	49 89 c2             	mov    r10,rax
  628f94:	49 c1 ea 20          	shr    r10,0x20
  628f98:	4d 85 d2             	test   r10,r10
  628f9b:	0f 85 1d 01 00 00    	jne    0x6290be
  628fa1:	85 c0                	test   eax,eax
  628fa3:	0f 85 07 00 00 00    	jne    0x628fb0
  628fa9:	89 c8                	mov    eax,ecx
  628fab:	e9 13 01 00 00       	jmp    0x6290c3
  628fb0:	41 89 c2             	mov    r10d,eax
  628fb3:	41 83 e2 01          	and    r10d,0x1
  628fb7:	45 85 d2             	test   r10d,r10d
  628fba:	0f 85 fe 00 00 00    	jne    0x6290be
  628fc0:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  628fc7:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  628fcb:	48 6b d2 04          	imul   rdx,rdx,0x4
  628fcf:	41 8b 14 12          	mov    edx,DWORD PTR [r10+rdx*1]
  628fd3:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  628fd7:	d1 e8                	shr    eax,1
  628fd9:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  628fdd:	0f 83 e7 00 00 00    	jae    0x6290ca
  628fe3:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  628fe7:	48 c1 e0 04          	shl    rax,0x4
  628feb:	49 01 c1             	add    r9,rax
  628fee:	45 0f b6 54 21 0e    	movzx  r10d,BYTE PTR [r9+riz*1+0xe]
  628ff4:	45 85 d2             	test   r10d,r10d
  628ff7:	0f 84 cd 00 00 00    	je     0x6290ca
  628ffd:	41 83 fa 04          	cmp    r10d,0x4
  629001:	0f 87 c3 00 00 00    	ja     0x6290ca
  629007:	41 c1 e2 04          	shl    r10d,0x4
  62900b:	4f 8b 5c 10 18       	mov    r11,QWORD PTR [r8+r10*1+0x18]
  629010:	47 8b 44 10 20       	mov    r8d,DWORD PTR [r8+r10*1+0x20]
  629015:	41 8b 01             	mov    eax,DWORD PTR [r9]
  629018:	44 39 c0             	cmp    eax,r8d
  62901b:	0f 87 a9 00 00 00    	ja     0x6290ca
  629021:	41 29 c0             	sub    r8d,eax
  629024:	41 8b 49 04          	mov    ecx,DWORD PTR [r9+0x4]
  629028:	44 39 c1             	cmp    ecx,r8d
  62902b:	0f 87 99 00 00 00    	ja     0x6290ca
  629031:	83 f9 10             	cmp    ecx,0x10
  629034:	0f 82 90 00 00 00    	jb     0x6290ca
  62903a:	49 01 c3             	add    r11,rax
  62903d:	41 8b 0b             	mov    ecx,DWORD PTR [r11]
  629040:	39 d1                	cmp    ecx,edx
  629042:	0f 84 6c 00 00 00    	je     0x6290b4
  629048:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  62904f:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  629053:	89 c8                	mov    eax,ecx
  629055:	41 3b 80 a4 00 00 00 	cmp    eax,DWORD PTR [r8+0xa4]
  62905c:	0f 83 68 00 00 00    	jae    0x6290ca
  629062:	89 d0                	mov    eax,edx
  629064:	41 3b 80 a4 00 00 00 	cmp    eax,DWORD PTR [r8+0xa4]
  62906b:	0f 83 59 00 00 00    	jae    0x6290ca
  629071:	4d 8b 90 a8 00 00 00 	mov    r10,QWORD PTR [r8+0xa8]
  629078:	4d 85 d2             	test   r10,r10
  62907b:	0f 84 49 00 00 00    	je     0x6290ca
  629081:	89 c8                	mov    eax,ecx
  629083:	48 6b c0 08          	imul   rax,rax,0x8
  629087:	4d 8b 0c 02          	mov    r9,QWORD PTR [r10+rax*1]
  62908b:	89 d0                	mov    eax,edx
  62908d:	48 6b c0 08          	imul   rax,rax,0x8
  629091:	4d 8b 14 02          	mov    r10,QWORD PTR [r10+rax*1]
  629095:	4c 89 c8             	mov    rax,r9
  629098:	48 c1 e8 20          	shr    rax,0x20
  62909c:	4c 89 d1             	mov    rcx,r10
  62909f:	48 c1 e9 20          	shr    rcx,0x20
  6290a3:	39 c8                	cmp    eax,ecx
  6290a5:	0f 82 13 00 00 00    	jb     0x6290be
  6290ab:	45 39 d1             	cmp    r9d,r10d
  6290ae:	0f 87 0a 00 00 00    	ja     0x6290be
  6290b4:	b8 01 00 00 00       	mov    eax,0x1
  6290b9:	e9 05 00 00 00       	jmp    0x6290c3
  6290be:	b8 00 00 00 00       	mov    eax,0x0
  6290c3:	41 5b                	pop    r11
  6290c5:	41 5a                	pop    r10
  6290c7:	41 59                	pop    r9
  6290c9:	c3                   	ret
  6290ca:	41 5b                	pop    r11
  6290cc:	41 5a                	pop    r10
  6290ce:	41 59                	pop    r9
  6290d0:	e9 75 01 00 00       	jmp    0x62924a
  6290d5:	41 51                	push   r9
  6290d7:	41 52                	push   r10
  6290d9:	41 53                	push   r11
  6290db:	89 cf                	mov    edi,ecx
  6290dd:	49 89 c2             	mov    r10,rax
  6290e0:	49 c1 ea 20          	shr    r10,0x20
  6290e4:	4d 85 d2             	test   r10,r10
  6290e7:	0f 85 c5 00 00 00    	jne    0x6291b2
  6290ed:	85 c0                	test   eax,eax
  6290ef:	0f 85 0d 00 00 00    	jne    0x629102
  6290f5:	85 f6                	test   esi,esi
  6290f7:	0f 84 b5 00 00 00    	je     0x6291b2
  6290fd:	e9 bb 00 00 00       	jmp    0x6291bd
  629102:	41 89 c2             	mov    r10d,eax
  629105:	41 83 e2 01          	and    r10d,0x1
  629109:	45 85 d2             	test   r10d,r10d
  62910c:	0f 85 a0 00 00 00    	jne    0x6291b2
  629112:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  629119:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  62911d:	48 6b d2 04          	imul   rdx,rdx,0x4
  629121:	41 8b 14 12          	mov    edx,DWORD PTR [r10+rdx*1]
  629125:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  629129:	d1 e8                	shr    eax,1
  62912b:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  62912f:	0f 83 7d 00 00 00    	jae    0x6291b2
  629135:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  629139:	48 c1 e0 04          	shl    rax,0x4
  62913d:	49 01 c1             	add    r9,rax
  629140:	45 0f b6 54 21 0e    	movzx  r10d,BYTE PTR [r9+riz*1+0xe]
  629146:	45 85 d2             	test   r10d,r10d
  629149:	0f 84 63 00 00 00    	je     0x6291b2
  62914f:	41 83 fa 04          	cmp    r10d,0x4
  629153:	0f 87 59 00 00 00    	ja     0x6291b2
  629159:	41 c1 e2 04          	shl    r10d,0x4
  62915d:	4f 8b 5c 10 18       	mov    r11,QWORD PTR [r8+r10*1+0x18]
  629162:	47 8b 44 10 20       	mov    r8d,DWORD PTR [r8+r10*1+0x20]
  629167:	41 8b 01             	mov    eax,DWORD PTR [r9]
  62916a:	44 39 c0             	cmp    eax,r8d
  62916d:	0f 87 3f 00 00 00    	ja     0x6291b2
  629173:	41 29 c0             	sub    r8d,eax
  629176:	41 8b 49 04          	mov    ecx,DWORD PTR [r9+0x4]
  62917a:	44 39 c1             	cmp    ecx,r8d
  62917d:	0f 87 2f 00 00 00    	ja     0x6291b2
  629183:	39 f9                	cmp    ecx,edi
  629185:	0f 82 27 00 00 00    	jb     0x6291b2
  62918b:	49 01 c3             	add    r11,rax
  62918e:	41 8b 0b             	mov    ecx,DWORD PTR [r11]
  629191:	39 d1                	cmp    ecx,edx
  629193:	0f 85 19 00 00 00    	jne    0x6291b2
  629199:	41 8b 4b 04          	mov    ecx,DWORD PTR [r11+0x4]
  62919d:	39 f9                	cmp    ecx,edi
  62919f:	0f 82 0d 00 00 00    	jb     0x6291b2
  6291a5:	4c 89 de             	mov    rsi,r11
  6291a8:	41 5b                	pop    r11
  6291aa:	41 5a                	pop    r10
  6291ac:	41 59                	pop    r9
  6291ae:	48 89 f0             	mov    rax,rsi
  6291b1:	c3                   	ret
  6291b2:	41 5b                	pop    r11
  6291b4:	41 5a                	pop    r10
  6291b6:	41 59                	pop    r9
  6291b8:	e9 8d 00 00 00       	jmp    0x62924a
  6291bd:	41 5b                	pop    r11
  6291bf:	41 5a                	pop    r10
  6291c1:	41 59                	pop    r9
  6291c3:	e9 55 00 00 00       	jmp    0x62921d
  6291c8:	b8 ff ff ff ff       	mov    eax,0xffffffff
  6291cd:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  6291d1:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  6291d4:	44 89 36             	mov    DWORD PTR [rsi],r14d
  6291d7:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  6291db:	c7 46 10 f6 08 00 00 	mov    DWORD PTR [rsi+0x10],0x8f6
  6291e2:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  6291e5:	c7 06 01 00 00 00    	mov    DWORD PTR [rsi],0x1
  6291eb:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  6291ef:	c3                   	ret
  6291f0:	b8 00 00 00 00       	mov    eax,0x0
  6291f5:	e9 00 00 00 00       	jmp    0x6291fa
  6291fa:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  6291fe:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  629201:	44 89 36             	mov    DWORD PTR [rsi],r14d
  629204:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  629208:	c7 46 10 f6 08 00 00 	mov    DWORD PTR [rsi+0x10],0x8f6
  62920f:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  629212:	c7 06 0d 00 00 00    	mov    DWORD PTR [rsi],0xd
  629218:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  62921c:	c3                   	ret
  62921d:	b8 ff ff ff ff       	mov    eax,0xffffffff
  629222:	e9 00 00 00 00       	jmp    0x629227
  629227:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  62922b:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  62922e:	44 89 36             	mov    DWORD PTR [rsi],r14d
  629231:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  629235:	c7 46 10 f6 08 00 00 	mov    DWORD PTR [rsi+0x10],0x8f6
  62923c:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  62923f:	c7 06 10 00 00 00    	mov    DWORD PTR [rsi],0x10
  629245:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  629249:	c3                   	ret
  62924a:	b8 ff ff ff ff       	mov    eax,0xffffffff
  62924f:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  629253:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  629256:	44 89 36             	mov    DWORD PTR [rsi],r14d
  629259:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  62925d:	c7 46 10 f6 08 00 00 	mov    DWORD PTR [rsi+0x10],0x8f6
  629264:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  629267:	c7 06 12 00 00 00    	mov    DWORD PTR [rsi],0x12
  62926d:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  629271:	c3                   	ret
