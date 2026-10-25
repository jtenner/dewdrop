
.tmp/wago-next-gc-perf/post-read-regions-profile/profile/native-code.bin:     file format binary


Disassembly of section .data:

0000000000645dd0 <.data+0x645dd0>:
  645dd0:	48 81 ec 18 01 00 00 	sub    rsp,0x118
  645dd7:	48 8b 73 b8          	mov    rsi,QWORD PTR [rbx-0x48]
  645ddb:	48 39 f4             	cmp    rsp,rsi
  645dde:	0f 82 cb 0f 00 00    	jb     0x646daf
  645de4:	49 89 c1             	mov    r9,rax
  645de7:	49 89 cb             	mov    r11,rcx
  645dea:	89 54 24 10          	mov    DWORD PTR [rsp+0x10],edx
  645dee:	31 c0                	xor    eax,eax
  645df0:	45 31 d2             	xor    r10d,r10d
  645df3:	89 44 24 20          	mov    DWORD PTR [rsp+0x20],eax
  645df7:	31 ed                	xor    ebp,ebp
  645df9:	48 89 44 24 30       	mov    QWORD PTR [rsp+0x30],rax
  645dfe:	89 44 24 38          	mov    DWORD PTR [rsp+0x38],eax
  645e02:	89 44 24 40          	mov    DWORD PTR [rsp+0x40],eax
  645e06:	45 31 e4             	xor    r12d,r12d
  645e09:	48 89 44 24 50       	mov    QWORD PTR [rsp+0x50],rax
  645e0e:	45 31 ed             	xor    r13d,r13d
  645e11:	89 44 24 60          	mov    DWORD PTR [rsp+0x60],eax
  645e15:	89 44 24 68          	mov    DWORD PTR [rsp+0x68],eax
  645e19:	89 44 24 70          	mov    DWORD PTR [rsp+0x70],eax
  645e1d:	4c 89 df             	mov    rdi,r11
  645e20:	48 89 7c 24 78       	mov    QWORD PTR [rsp+0x78],rdi
  645e25:	48 8b 7c 24 78       	mov    rdi,QWORD PTR [rsp+0x78]
  645e2a:	48 89 f8             	mov    rax,rdi
  645e2d:	ba a0 09 00 00       	mov    edx,0x9a0
  645e32:	b9 18 00 00 00       	mov    ecx,0x18
  645e37:	be 00 00 00 00       	mov    esi,0x0
  645e3c:	e8 f4 0d 00 00       	call   0x646c35
  645e41:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  645e45:	48 89 84 24 e8 00 00 	mov    QWORD PTR [rsp+0xe8],rax
  645e4c:	00 
  645e4d:	4c 89 0c 24          	mov    QWORD PTR [rsp],r9
  645e51:	4c 89 5c 24 08       	mov    QWORD PTR [rsp+0x8],r11
  645e56:	44 89 54 24 18       	mov    DWORD PTR [rsp+0x18],r10d
  645e5b:	89 6c 24 28          	mov    DWORD PTR [rsp+0x28],ebp
  645e5f:	44 89 64 24 48       	mov    DWORD PTR [rsp+0x48],r12d
  645e64:	44 89 6c 24 58       	mov    DWORD PTR [rsp+0x58],r13d
  645e69:	44 8b 94 24 e8 00 00 	mov    r10d,DWORD PTR [rsp+0xe8]
  645e70:	00 
  645e71:	bf 00 00 00 00       	mov    edi,0x0
  645e76:	89 7c 24 20          	mov    DWORD PTR [rsp+0x20],edi
  645e7a:	89 7c 24 70          	mov    DWORD PTR [rsp+0x70],edi
  645e7e:	44 89 54 24 18       	mov    DWORD PTR [rsp+0x18],r10d
  645e83:	66 0f 1f 84 00 00 00 	nop    WORD PTR [rax+rax*1+0x0]
  645e8a:	00 00 
  645e8c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
  645e90:	8b 6c 24 70          	mov    ebp,DWORD PTR [rsp+0x70]
  645e94:	48 89 ac 24 e8 00 00 	mov    QWORD PTR [rsp+0xe8],rbp
  645e9b:	00 
  645e9c:	4c 89 cf             	mov    rdi,r9
  645e9f:	48 89 f8             	mov    rax,rdi
  645ea2:	ba 2f 0e 00 00       	mov    edx,0xe2f
  645ea7:	b9 14 00 00 00       	mov    ecx,0x14
  645eac:	be 00 00 00 00       	mov    esi,0x0
  645eb1:	e8 7f 0d 00 00       	call   0x646c35
  645eb6:	8b 40 10             	mov    eax,DWORD PTR [rax+0x10]
  645eb9:	ba b9 10 00 00       	mov    edx,0x10b9
  645ebe:	b9 1c 00 00 00       	mov    ecx,0x1c
  645ec3:	be 00 00 00 00       	mov    esi,0x0
  645ec8:	e8 68 0d 00 00       	call   0x646c35
  645ecd:	8b 40 18             	mov    eax,DWORD PTR [rax+0x18]
  645ed0:	48 89 84 24 80 00 00 	mov    QWORD PTR [rsp+0x80],rax
  645ed7:	00 
  645ed8:	48 8b bc 24 80 00 00 	mov    rdi,QWORD PTR [rsp+0x80]
  645edf:	00 
  645ee0:	48 89 f8             	mov    rax,rdi
  645ee3:	ba a0 09 00 00       	mov    edx,0x9a0
  645ee8:	b9 18 00 00 00       	mov    ecx,0x18
  645eed:	be 00 00 00 00       	mov    esi,0x0
  645ef2:	e8 3e 0d 00 00       	call   0x646c35
  645ef7:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  645efb:	48 89 84 24 f0 00 00 	mov    QWORD PTR [rsp+0xf0],rax
  645f02:	00 
  645f03:	89 6c 24 28          	mov    DWORD PTR [rsp+0x28],ebp
  645f07:	8b bc 24 f0 00 00 00 	mov    edi,DWORD PTR [rsp+0xf0]
  645f0e:	89 bc 24 90 00 00 00 	mov    DWORD PTR [rsp+0x90],edi
  645f15:	8b bc 24 e8 00 00 00 	mov    edi,DWORD PTR [rsp+0xe8]
  645f1c:	89 bc 24 88 00 00 00 	mov    DWORD PTR [rsp+0x88],edi
  645f23:	8b bc 24 88 00 00 00 	mov    edi,DWORD PTR [rsp+0x88]
  645f2a:	8b b4 24 90 00 00 00 	mov    esi,DWORD PTR [rsp+0x90]
  645f31:	39 f7                	cmp    edi,esi
  645f33:	0f 83 c3 01 00 00    	jae    0x6460fc
  645f39:	4c 89 cf             	mov    rdi,r9
  645f3c:	48 89 f8             	mov    rax,rdi
  645f3f:	ba 2f 0e 00 00       	mov    edx,0xe2f
  645f44:	b9 14 00 00 00       	mov    ecx,0x14
  645f49:	be 00 00 00 00       	mov    esi,0x0
  645f4e:	e8 e2 0c 00 00       	call   0x646c35
  645f53:	8b 40 10             	mov    eax,DWORD PTR [rax+0x10]
  645f56:	ba b9 10 00 00       	mov    edx,0x10b9
  645f5b:	b9 1c 00 00 00       	mov    ecx,0x1c
  645f60:	be 00 00 00 00       	mov    esi,0x0
  645f65:	e8 cb 0c 00 00       	call   0x646c35
  645f6a:	8b 40 18             	mov    eax,DWORD PTR [rax+0x18]
  645f6d:	89 ef                	mov    edi,ebp
  645f6f:	89 bc 24 a0 00 00 00 	mov    DWORD PTR [rsp+0xa0],edi
  645f76:	48 89 84 24 98 00 00 	mov    QWORD PTR [rsp+0x98],rax
  645f7d:	00 
  645f7e:	8b bc 24 a0 00 00 00 	mov    edi,DWORD PTR [rsp+0xa0]
  645f85:	48 89 bc 24 e8 00 00 	mov    QWORD PTR [rsp+0xe8],rdi
  645f8c:	00 
  645f8d:	48 8b bc 24 98 00 00 	mov    rdi,QWORD PTR [rsp+0x98]
  645f94:	00 
  645f95:	48 89 f8             	mov    rax,rdi
  645f98:	ba a0 09 00 00       	mov    edx,0x9a0
  645f9d:	b9 18 00 00 00       	mov    ecx,0x18
  645fa2:	be 00 00 00 00       	mov    esi,0x0
  645fa7:	e8 89 0c 00 00       	call   0x646c35
  645fac:	48 89 84 24 a8 00 00 	mov    QWORD PTR [rsp+0xa8],rax
  645fb3:	00 
  645fb4:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  645fb8:	8b bc 24 e8 00 00 00 	mov    edi,DWORD PTR [rsp+0xe8]
  645fbf:	39 c7                	cmp    edi,eax
  645fc1:	0f 82 05 00 00 00    	jb     0x645fcc
  645fc7:	e9 5c 0d 00 00       	jmp    0x646d28
  645fcc:	48 8b bc 24 a8 00 00 	mov    rdi,QWORD PTR [rsp+0xa8]
  645fd3:	00 
  645fd4:	8b 7f 10             	mov    edi,DWORD PTR [rdi+0x10]
  645fd7:	48 89 f8             	mov    rax,rdi
  645fda:	8b bc 24 a0 00 00 00 	mov    edi,DWORD PTR [rsp+0xa0]
  645fe1:	89 f9                	mov    ecx,edi
  645fe3:	ba 3d 23 00 00       	mov    edx,0x233d
  645fe8:	be 00 00 00 00       	mov    esi,0x0
  645fed:	e8 4f 08 00 00       	call   0x646841
  645ff2:	8b 04 20             	mov    eax,DWORD PTR [rax+riz*1]
  645ff5:	48 89 84 24 e8 00 00 	mov    QWORD PTR [rsp+0xe8],rax
  645ffc:	00 
  645ffd:	48 8b bc 24 e8 00 00 	mov    rdi,QWORD PTR [rsp+0xe8]
  646004:	00 
  646005:	48 89 7c 24 50       	mov    QWORD PTR [rsp+0x50],rdi
  64600a:	48 8b 7c 24 50       	mov    rdi,QWORD PTR [rsp+0x50]
  64600f:	48 89 f8             	mov    rax,rdi
  646012:	ba 9d 10 00 00       	mov    edx,0x109d
  646017:	b9 00 00 00 00       	mov    ecx,0x0
  64601c:	be 14 00 00 00       	mov    esi,0x14
  646021:	e8 97 0a 00 00       	call   0x646abd
  646026:	85 c0                	test   eax,eax
  646028:	0f 84 a6 00 00 00    	je     0x6460d4
  64602e:	8b 7a 10             	mov    edi,DWORD PTR [rdx+0x10]
  646031:	48 89 7c 24 30       	mov    QWORD PTR [rsp+0x30],rdi
  646036:	48 8b 7c 24 50       	mov    rdi,QWORD PTR [rsp+0x50]
  64603b:	48 89 f8             	mov    rax,rdi
  64603e:	ba 9d 10 00 00       	mov    edx,0x109d
  646043:	b9 18 00 00 00       	mov    ecx,0x18
  646048:	be 00 00 00 00       	mov    esi,0x0
  64604d:	e8 e3 0b 00 00       	call   0x646c35
  646052:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  646056:	89 44 24 38          	mov    DWORD PTR [rsp+0x38],eax
  64605a:	8b 7c 24 10          	mov    edi,DWORD PTR [rsp+0x10]
  64605e:	89 bc 24 b8 00 00 00 	mov    DWORD PTR [rsp+0xb8],edi
  646065:	89 84 24 b0 00 00 00 	mov    DWORD PTR [rsp+0xb0],eax
  64606c:	8b bc 24 b0 00 00 00 	mov    edi,DWORD PTR [rsp+0xb0]
  646073:	8b b4 24 b8 00 00 00 	mov    esi,DWORD PTR [rsp+0xb8]
  64607a:	39 f7                	cmp    edi,esi
  64607c:	0f 85 26 00 00 00    	jne    0x6460a8
  646082:	4c 89 cf             	mov    rdi,r9
  646085:	4c 89 de             	mov    rsi,r11
  646088:	48 89 f8             	mov    rax,rdi
  64608b:	48 89 f2             	mov    rdx,rsi
  64608e:	48 8b 4c 24 30       	mov    rcx,QWORD PTR [rsp+0x30]
  646093:	e8 4c d6 ff ff       	call   0x6436e4
  646098:	48 89 c7             	mov    rdi,rax
  64609b:	48 89 bc 24 e8 00 00 	mov    QWORD PTR [rsp+0xe8],rdi
  6460a2:	00 
  6460a3:	e9 0d 00 00 00       	jmp    0x6460b5
  6460a8:	bf 00 00 00 00       	mov    edi,0x0
  6460ad:	48 89 bc 24 e8 00 00 	mov    QWORD PTR [rsp+0xe8],rdi
  6460b4:	00 
  6460b5:	8b bc 24 e8 00 00 00 	mov    edi,DWORD PTR [rsp+0xe8]
  6460bc:	85 ff                	test   edi,edi
  6460be:	0f 84 0b 00 00 00    	je     0x6460cf
  6460c4:	8b 6c 24 28          	mov    ebp,DWORD PTR [rsp+0x28]
  6460c8:	89 e8                	mov    eax,ebp
  6460ca:	e9 6a 07 00 00       	jmp    0x646839
  6460cf:	e9 00 00 00 00       	jmp    0x6460d4
  6460d4:	8b 6c 24 28          	mov    ebp,DWORD PTR [rsp+0x28]
  6460d8:	8d 7d 01             	lea    edi,[rbp+0x1]
  6460db:	89 7c 24 70          	mov    DWORD PTR [rsp+0x70],edi
  6460df:	4c 8b 0c 24          	mov    r9,QWORD PTR [rsp]
  6460e3:	4c 8b 5c 24 08       	mov    r11,QWORD PTR [rsp+0x8]
  6460e8:	44 8b 54 24 18       	mov    r10d,DWORD PTR [rsp+0x18]
  6460ed:	44 8b 64 24 48       	mov    r12d,DWORD PTR [rsp+0x48]
  6460f2:	44 8b 6c 24 58       	mov    r13d,DWORD PTR [rsp+0x58]
  6460f7:	e9 94 fd ff ff       	jmp    0x645e90
  6460fc:	4c 89 cf             	mov    rdi,r9
  6460ff:	48 89 f8             	mov    rax,rdi
  646102:	ba 2f 0e 00 00       	mov    edx,0xe2f
  646107:	b9 14 00 00 00       	mov    ecx,0x14
  64610c:	be 00 00 00 00       	mov    esi,0x0
  646111:	e8 1f 0b 00 00       	call   0x646c35
  646116:	8b 40 10             	mov    eax,DWORD PTR [rax+0x10]
  646119:	ba b9 10 00 00       	mov    edx,0x10b9
  64611e:	b9 20 00 00 00       	mov    ecx,0x20
  646123:	be 00 00 00 00       	mov    esi,0x0
  646128:	e8 08 0b 00 00       	call   0x646c35
  64612d:	8b 40 1c             	mov    eax,DWORD PTR [rax+0x1c]
  646130:	48 89 44 24 78       	mov    QWORD PTR [rsp+0x78],rax
  646135:	48 8b 7c 24 78       	mov    rdi,QWORD PTR [rsp+0x78]
  64613a:	48 89 f8             	mov    rax,rdi
  64613d:	ba a0 09 00 00       	mov    edx,0x9a0
  646142:	b9 18 00 00 00       	mov    ecx,0x18
  646147:	be 00 00 00 00       	mov    esi,0x0
  64614c:	e8 e4 0a 00 00       	call   0x646c35
  646151:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  646155:	48 89 84 24 e8 00 00 	mov    QWORD PTR [rsp+0xe8],rax
  64615c:	00 
  64615d:	8b bc 24 e8 00 00 00 	mov    edi,DWORD PTR [rsp+0xe8]
  646164:	89 7c 24 40          	mov    DWORD PTR [rsp+0x40],edi
  646168:	41 bd 00 00 00 00    	mov    r13d,0x0
  64616e:	44 89 6c 24 58       	mov    DWORD PTR [rsp+0x58],r13d
  646173:	66 0f 1f 84 00 00 00 	nop    WORD PTR [rax+rax*1+0x0]
  64617a:	00 00 
  64617c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
  646180:	45 89 ec             	mov    r12d,r13d
  646183:	44 89 d7             	mov    edi,r10d
  646186:	89 bc 24 90 00 00 00 	mov    DWORD PTR [rsp+0x90],edi
  64618d:	44 89 e7             	mov    edi,r12d
  646190:	89 bc 24 88 00 00 00 	mov    DWORD PTR [rsp+0x88],edi
  646197:	8b bc 24 88 00 00 00 	mov    edi,DWORD PTR [rsp+0x88]
  64619e:	8b b4 24 90 00 00 00 	mov    esi,DWORD PTR [rsp+0x90]
  6461a5:	44 89 64 24 48       	mov    DWORD PTR [rsp+0x48],r12d
  6461aa:	39 f7                	cmp    edi,esi
  6461ac:	0f 83 12 01 00 00    	jae    0x6462c4
  6461b2:	4c 89 cf             	mov    rdi,r9
  6461b5:	48 89 f8             	mov    rax,rdi
  6461b8:	ba 2f 0e 00 00       	mov    edx,0xe2f
  6461bd:	b9 14 00 00 00       	mov    ecx,0x14
  6461c2:	be 00 00 00 00       	mov    esi,0x0
  6461c7:	e8 69 0a 00 00       	call   0x646c35
  6461cc:	8b 40 10             	mov    eax,DWORD PTR [rax+0x10]
  6461cf:	ba b9 10 00 00       	mov    edx,0x10b9
  6461d4:	b9 20 00 00 00       	mov    ecx,0x20
  6461d9:	be 00 00 00 00       	mov    esi,0x0
  6461de:	e8 52 0a 00 00       	call   0x646c35
  6461e3:	8b 40 1c             	mov    eax,DWORD PTR [rax+0x1c]
  6461e6:	44 89 e7             	mov    edi,r12d
  6461e9:	89 bc 24 d8 00 00 00 	mov    DWORD PTR [rsp+0xd8],edi
  6461f0:	4c 89 df             	mov    rdi,r11
  6461f3:	48 89 bc 24 d0 00 00 	mov    QWORD PTR [rsp+0xd0],rdi
  6461fa:	00 
  6461fb:	48 89 84 24 e8 00 00 	mov    QWORD PTR [rsp+0xe8],rax
  646202:	00 
  646203:	8b bc 24 d8 00 00 00 	mov    edi,DWORD PTR [rsp+0xd8]
  64620a:	48 89 bc 24 f0 00 00 	mov    QWORD PTR [rsp+0xf0],rdi
  646211:	00 
  646212:	48 8b bc 24 d0 00 00 	mov    rdi,QWORD PTR [rsp+0xd0]
  646219:	00 
  64621a:	48 89 f8             	mov    rax,rdi
  64621d:	ba a0 09 00 00       	mov    edx,0x9a0
  646222:	b9 18 00 00 00       	mov    ecx,0x18
  646227:	be 00 00 00 00       	mov    esi,0x0
  64622c:	e8 04 0a 00 00       	call   0x646c35
  646231:	48 89 84 24 e0 00 00 	mov    QWORD PTR [rsp+0xe0],rax
  646238:	00 
  646239:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  64623d:	8b bc 24 f0 00 00 00 	mov    edi,DWORD PTR [rsp+0xf0]
  646244:	39 c7                	cmp    edi,eax
  646246:	0f 82 05 00 00 00    	jb     0x646251
  64624c:	e9 04 0b 00 00       	jmp    0x646d55
  646251:	48 8b bc 24 e0 00 00 	mov    rdi,QWORD PTR [rsp+0xe0]
  646258:	00 
  646259:	8b 7f 10             	mov    edi,DWORD PTR [rdi+0x10]
  64625c:	48 89 f8             	mov    rax,rdi
  64625f:	8b bc 24 d8 00 00 00 	mov    edi,DWORD PTR [rsp+0xd8]
  646266:	89 f9                	mov    ecx,edi
  646268:	ba 3a 23 00 00       	mov    edx,0x233a
  64626d:	be 00 00 00 00       	mov    esi,0x0
  646272:	e8 ca 05 00 00       	call   0x646841
  646277:	8b 04 20             	mov    eax,DWORD PTR [rax+riz*1]
  64627a:	48 89 84 24 f0 00 00 	mov    QWORD PTR [rsp+0xf0],rax
  646281:	00 
  646282:	48 8b bc 24 e8 00 00 	mov    rdi,QWORD PTR [rsp+0xe8]
  646289:	00 
  64628a:	8b b4 24 f0 00 00 00 	mov    esi,DWORD PTR [rsp+0xf0]
  646291:	48 89 f8             	mov    rax,rdi
  646294:	48 89 f1             	mov    rcx,rsi
  646297:	e8 54 3c 9c ff       	call   0x9ef0
  64629c:	44 8b 64 24 48       	mov    r12d,DWORD PTR [rsp+0x48]
  6462a1:	45 89 e5             	mov    r13d,r12d
  6462a4:	41 83 c5 01          	add    r13d,0x1
  6462a8:	44 89 6c 24 58       	mov    DWORD PTR [rsp+0x58],r13d
  6462ad:	4c 8b 0c 24          	mov    r9,QWORD PTR [rsp]
  6462b1:	4c 8b 5c 24 08       	mov    r11,QWORD PTR [rsp+0x8]
  6462b6:	44 8b 54 24 18       	mov    r10d,DWORD PTR [rsp+0x18]
  6462bb:	8b 6c 24 28          	mov    ebp,DWORD PTR [rsp+0x28]
  6462bf:	e9 bc fe ff ff       	jmp    0x646180
  6462c4:	e9 00 00 00 00       	jmp    0x6462c9
  6462c9:	4c 89 cf             	mov    rdi,r9
  6462cc:	48 89 f8             	mov    rax,rdi
  6462cf:	ba 2f 0e 00 00       	mov    edx,0xe2f
  6462d4:	b9 14 00 00 00       	mov    ecx,0x14
  6462d9:	be 00 00 00 00       	mov    esi,0x0
  6462de:	e8 52 09 00 00       	call   0x646c35
  6462e3:	8b 40 10             	mov    eax,DWORD PTR [rax+0x10]
  6462e6:	ba b9 10 00 00       	mov    edx,0x10b9
  6462eb:	b9 1c 00 00 00       	mov    ecx,0x1c
  6462f0:	be 00 00 00 00       	mov    esi,0x0
  6462f5:	e8 3b 09 00 00       	call   0x646c35
  6462fa:	8b 40 18             	mov    eax,DWORD PTR [rax+0x18]
  6462fd:	8b 7c 24 40          	mov    edi,DWORD PTR [rsp+0x40]
  646301:	89 7c 24 60          	mov    DWORD PTR [rsp+0x60],edi
  646305:	44 89 d7             	mov    edi,r10d
  646308:	89 7c 24 68          	mov    DWORD PTR [rsp+0x68],edi
  64630c:	48 89 84 24 e8 00 00 	mov    QWORD PTR [rsp+0xe8],rax
  646313:	00 
  646314:	8b 7c 24 60          	mov    edi,DWORD PTR [rsp+0x60]
  646318:	48 89 bc 24 f0 00 00 	mov    QWORD PTR [rsp+0xf0],rdi
  64631f:	00 
  646320:	8b 7c 24 68          	mov    edi,DWORD PTR [rsp+0x68]
  646324:	48 89 bc 24 f8 00 00 	mov    QWORD PTR [rsp+0xf8],rdi
  64632b:	00 
  64632c:	bf 3d 0d 00 00       	mov    edi,0xd3d
  646331:	48 89 bc 24 00 01 00 	mov    QWORD PTR [rsp+0x100],rdi
  646338:	00 
  646339:	41 50                	push   r8
  64633b:	41 51                	push   r9
  64633d:	41 52                	push   r10
  64633f:	41 53                	push   r11
  646341:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  646348:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  64634c:	41 8b 92 f4 34 00 00 	mov    edx,DWORD PTR [r10+0x34f4]
  646353:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  646357:	41 83 b8 a0 00 00 00 	cmp    DWORD PTR [r8+0xa0],0x18
  64635e:	18 
  64635f:	0f 86 43 01 00 00    	jbe    0x6464a8
  646365:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  64636c:	4d 85 d2             	test   r10,r10
  64636f:	0f 84 33 01 00 00    	je     0x6464a8
  646375:	41 8b 4a 04          	mov    ecx,DWORD PTR [r10+0x4]
  646379:	41 8b 42 08          	mov    eax,DWORD PTR [r10+0x8]
  64637d:	81 f8 00 02 00 00    	cmp    eax,0x200
  646383:	0f 87 1f 01 00 00    	ja     0x6464a8
  646389:	39 c1                	cmp    ecx,eax
  64638b:	0f 83 17 01 00 00    	jae    0x6464a8
  646391:	49 8d 44 8a 20       	lea    rax,[r10+rcx*4+0x20]
  646396:	8b 30                	mov    esi,DWORD PTR [rax]
  646398:	89 f0                	mov    eax,esi
  64639a:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  64639e:	48 c1 e0 04          	shl    rax,0x4
  6463a2:	49 01 c1             	add    r9,rax
  6463a5:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  6463ac:	48 85 c0             	test   rax,rax
  6463af:	0f 84 f3 00 00 00    	je     0x6464a8
  6463b5:	8b 08                	mov    ecx,DWORD PTR [rax]
  6463b7:	83 c1 07             	add    ecx,0x7
  6463ba:	83 e1 f8             	and    ecx,0xfffffff8
  6463bd:	41 8b 40 7c          	mov    eax,DWORD PTR [r8+0x7c]
  6463c1:	39 c1                	cmp    ecx,eax
  6463c3:	0f 87 df 00 00 00    	ja     0x6464a8
  6463c9:	29 c8                	sub    eax,ecx
  6463cb:	83 f8 18             	cmp    eax,0x18
  6463ce:	0f 82 d4 00 00 00    	jb     0x6464a8
  6463d4:	4d 8b 58 28          	mov    r11,QWORD PTR [r8+0x28]
  6463d8:	4d 85 db             	test   r11,r11
  6463db:	0f 84 c7 00 00 00    	je     0x6464a8
  6463e1:	49 01 cb             	add    r11,rcx
  6463e4:	49 8b 80 98 00 00 00 	mov    rax,QWORD PTR [r8+0x98]
  6463eb:	48 85 c0             	test   rax,rax
  6463ee:	0f 84 b4 00 00 00    	je     0x6464a8
  6463f4:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  6463fb:	41 8b 52 04          	mov    edx,DWORD PTR [r10+0x4]
  6463ff:	48 8b 83 e8 fe ff ff 	mov    rax,QWORD PTR [rbx-0x118]
  646406:	48 8b 40 10          	mov    rax,QWORD PTR [rax+0x10]
  64640a:	8b 80 f4 34 00 00    	mov    eax,DWORD PTR [rax+0x34f4]
  646410:	41 89 03             	mov    DWORD PTR [r11],eax
  646413:	41 c7 43 04 18 00 00 	mov    DWORD PTR [r11+0x4],0x18
  64641a:	00 
  64641b:	41 c7 43 08 00 00 00 	mov    DWORD PTR [r11+0x8],0x0
  646422:	00 
  646423:	41 c7 43 0c 01 00 00 	mov    DWORD PTR [r11+0xc],0x1
  64642a:	00 
  64642b:	8b 84 24 10 01 00 00 	mov    eax,DWORD PTR [rsp+0x110]
  646432:	41 89 43 10          	mov    DWORD PTR [r11+0x10],eax
  646436:	8b 84 24 18 01 00 00 	mov    eax,DWORD PTR [rsp+0x118]
  64643d:	41 89 43 14          	mov    DWORD PTR [r11+0x14],eax
  646441:	41 89 09             	mov    DWORD PTR [r9],ecx
  646444:	41 c7 41 04 18 00 00 	mov    DWORD PTR [r9+0x4],0x18
  64644b:	00 
  64644c:	41 c7 41 08 00 00 00 	mov    DWORD PTR [r9+0x8],0x0
  646453:	00 
  646454:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  64645b:	41 89 ca             	mov    r10d,ecx
  64645e:	41 83 c2 18          	add    r10d,0x18
  646462:	44 89 10             	mov    DWORD PTR [rax],r10d
  646465:	41 c7 41 0c 00 00 01 	mov    DWORD PTR [r9+0xc],0x10000
  64646c:	00 
  64646d:	83 c2 01             	add    edx,0x1
  646470:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  646477:	41 89 52 04          	mov    DWORD PTR [r10+0x4],edx
  64647b:	41 83 7a 18 00       	cmp    DWORD PTR [r10+0x18],0x0
  646480:	0f 84 11 00 00 00    	je     0x646497
  646486:	4d 8b 90 98 00 00 00 	mov    r10,QWORD PTR [r8+0x98]
  64648d:	49 8b 02             	mov    rax,QWORD PTR [r10]
  646490:	48 83 c0 01          	add    rax,0x1
  646494:	49 89 02             	mov    QWORD PTR [r10],rax
  646497:	89 f0                	mov    eax,esi
  646499:	d1 e0                	shl    eax,1
  64649b:	48 89 84 24 10 01 00 	mov    QWORD PTR [rsp+0x110],rax
  6464a2:	00 
  6464a3:	e9 05 00 00 00       	jmp    0x6464ad
  6464a8:	b8 00 00 00 00       	mov    eax,0x0
  6464ad:	85 c0                	test   eax,eax
  6464af:	41 5b                	pop    r11
  6464b1:	41 5a                	pop    r10
  6464b3:	41 59                	pop    r9
  6464b5:	41 58                	pop    r8
  6464b7:	0f 85 68 00 00 00    	jne    0x646525
  6464bd:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  6464c1:	8b 84 24 f0 00 00 00 	mov    eax,DWORD PTR [rsp+0xf0]
  6464c8:	49 89 40 48          	mov    QWORD PTR [r8+0x48],rax
  6464cc:	8b 84 24 f8 00 00 00 	mov    eax,DWORD PTR [rsp+0xf8]
  6464d3:	49 89 40 50          	mov    QWORD PTR [r8+0x50],rax
  6464d7:	8b 84 24 00 01 00 00 	mov    eax,DWORD PTR [rsp+0x100]
  6464de:	49 89 40 58          	mov    QWORD PTR [r8+0x58],rax
  6464e2:	41 c7 40 40 0b 22 16 	mov    DWORD PTR [r8+0x40],0x4016220b
  6464e9:	40 
  6464ea:	41 c7 40 44 03 00 01 	mov    DWORD PTR [r8+0x44],0x10003
  6464f1:	00 
  6464f2:	41 ff 50 38          	call   QWORD PTR [r8+0x38]
  6464f6:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  6464fa:	49 8b 80 48 02 00 00 	mov    rax,QWORD PTR [r8+0x248]
  646501:	48 89 84 24 f0 00 00 	mov    QWORD PTR [rsp+0xf0],rax
  646508:	00 
  646509:	4c 8b 0c 24          	mov    r9,QWORD PTR [rsp]
  64650d:	4c 8b 5c 24 08       	mov    r11,QWORD PTR [rsp+0x8]
  646512:	44 8b 54 24 18       	mov    r10d,DWORD PTR [rsp+0x18]
  646517:	8b 6c 24 28          	mov    ebp,DWORD PTR [rsp+0x28]
  64651b:	44 8b 64 24 48       	mov    r12d,DWORD PTR [rsp+0x48]
  646520:	44 8b 6c 24 58       	mov    r13d,DWORD PTR [rsp+0x58]
  646525:	48 8b bc 24 f0 00 00 	mov    rdi,QWORD PTR [rsp+0xf0]
  64652c:	00 
  64652d:	48 89 f8             	mov    rax,rdi
  646530:	ba 3d 0d 00 00       	mov    edx,0xd3d
  646535:	b9 00 00 00 00       	mov    ecx,0x0
  64653a:	be 00 00 00 00       	mov    esi,0x0
  64653f:	e8 27 04 00 00       	call   0x64696b
  646544:	48 89 84 24 f0 00 00 	mov    QWORD PTR [rsp+0xf0],rax
  64654b:	00 
  64654c:	8b 7c 24 10          	mov    edi,DWORD PTR [rsp+0x10]
  646550:	48 89 bc 24 f8 00 00 	mov    QWORD PTR [rsp+0xf8],rdi
  646557:	00 
  646558:	bf 9d 10 00 00       	mov    edi,0x109d
  64655d:	48 89 bc 24 00 01 00 	mov    QWORD PTR [rsp+0x100],rdi
  646564:	00 
  646565:	41 54                	push   r12
  646567:	41 50                	push   r8
  646569:	41 51                	push   r9
  64656b:	41 52                	push   r10
  64656d:	41 53                	push   r11
  64656f:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  646576:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  64657a:	41 8b 92 74 42 00 00 	mov    edx,DWORD PTR [r10+0x4274]
  646581:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  646585:	41 83 b8 a0 00 00 00 	cmp    DWORD PTR [r8+0xa0],0x18
  64658c:	18 
  64658d:	0f 86 f3 01 00 00    	jbe    0x646786
  646593:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  64659a:	4d 85 d2             	test   r10,r10
  64659d:	0f 84 e3 01 00 00    	je     0x646786
  6465a3:	41 8b 4a 04          	mov    ecx,DWORD PTR [r10+0x4]
  6465a7:	41 8b 42 08          	mov    eax,DWORD PTR [r10+0x8]
  6465ab:	81 f8 00 02 00 00    	cmp    eax,0x200
  6465b1:	0f 87 cf 01 00 00    	ja     0x646786
  6465b7:	39 c1                	cmp    ecx,eax
  6465b9:	0f 83 c7 01 00 00    	jae    0x646786
  6465bf:	49 8d 44 8a 20       	lea    rax,[r10+rcx*4+0x20]
  6465c4:	8b 30                	mov    esi,DWORD PTR [rax]
  6465c6:	89 f0                	mov    eax,esi
  6465c8:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  6465cc:	48 c1 e0 04          	shl    rax,0x4
  6465d0:	49 01 c1             	add    r9,rax
  6465d3:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  6465da:	48 85 c0             	test   rax,rax
  6465dd:	0f 84 a3 01 00 00    	je     0x646786
  6465e3:	8b 08                	mov    ecx,DWORD PTR [rax]
  6465e5:	83 c1 07             	add    ecx,0x7
  6465e8:	83 e1 f8             	and    ecx,0xfffffff8
  6465eb:	41 8b 40 7c          	mov    eax,DWORD PTR [r8+0x7c]
  6465ef:	39 c1                	cmp    ecx,eax
  6465f1:	0f 87 8f 01 00 00    	ja     0x646786
  6465f7:	29 c8                	sub    eax,ecx
  6465f9:	83 f8 18             	cmp    eax,0x18
  6465fc:	0f 82 84 01 00 00    	jb     0x646786
  646602:	4d 8b 58 28          	mov    r11,QWORD PTR [r8+0x28]
  646606:	4d 85 db             	test   r11,r11
  646609:	0f 84 77 01 00 00    	je     0x646786
  64660f:	49 01 cb             	add    r11,rcx
  646612:	49 8b 80 98 00 00 00 	mov    rax,QWORD PTR [r8+0x98]
  646619:	48 85 c0             	test   rax,rax
  64661c:	0f 84 64 01 00 00    	je     0x646786
  646622:	41 89 cc             	mov    r12d,ecx
  646625:	8b 84 24 18 01 00 00 	mov    eax,DWORD PTR [rsp+0x118]
  64662c:	85 c0                	test   eax,eax
  64662e:	0f 84 52 01 00 00    	je     0x646786
  646634:	89 c2                	mov    edx,eax
  646636:	83 e2 01             	and    edx,0x1
  646639:	85 d2                	test   edx,edx
  64663b:	0f 85 45 01 00 00    	jne    0x646786
  646641:	d1 e8                	shr    eax,1
  646643:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  646647:	0f 83 39 01 00 00    	jae    0x646786
  64664d:	4d 8b 50 08          	mov    r10,QWORD PTR [r8+0x8]
  646651:	48 c1 e0 04          	shl    rax,0x4
  646655:	49 01 c2             	add    r10,rax
  646658:	41 8b 42 0c          	mov    eax,DWORD PTR [r10+0xc]
  64665c:	c1 e8 10             	shr    eax,0x10
  64665f:	81 e0 ff 00 00 00    	and    eax,0xff
  646665:	85 c0                	test   eax,eax
  646667:	0f 84 19 01 00 00    	je     0x646786
  64666d:	83 f8 04             	cmp    eax,0x4
  646670:	0f 87 10 01 00 00    	ja     0x646786
  646676:	48 6b c0 10          	imul   rax,rax,0x10
  64667a:	4c 01 c0             	add    rax,r8
  64667d:	8b 50 20             	mov    edx,DWORD PTR [rax+0x20]
  646680:	41 8b 0a             	mov    ecx,DWORD PTR [r10]
  646683:	39 d1                	cmp    ecx,edx
  646685:	0f 83 fb 00 00 00    	jae    0x646786
  64668b:	29 ca                	sub    edx,ecx
  64668d:	45 8b 52 04          	mov    r10d,DWORD PTR [r10+0x4]
  646691:	41 39 d2             	cmp    r10d,edx
  646694:	0f 87 ec 00 00 00    	ja     0x646786
  64669a:	41 83 fa 10          	cmp    r10d,0x10
  64669e:	0f 82 e2 00 00 00    	jb     0x646786
  6466a4:	48 8b 40 18          	mov    rax,QWORD PTR [rax+0x18]
  6466a8:	48 85 c0             	test   rax,rax
  6466ab:	0f 84 d5 00 00 00    	je     0x646786
  6466b1:	48 01 c8             	add    rax,rcx
  6466b4:	8b 00                	mov    eax,DWORD PTR [rax]
  6466b6:	48 8b 93 e8 fe ff ff 	mov    rdx,QWORD PTR [rbx-0x118]
  6466bd:	48 8b 52 10          	mov    rdx,QWORD PTR [rdx+0x10]
  6466c1:	8b 92 f4 34 00 00    	mov    edx,DWORD PTR [rdx+0x34f4]
  6466c7:	39 d0                	cmp    eax,edx
  6466c9:	0f 85 b7 00 00 00    	jne    0x646786
  6466cf:	44 89 e1             	mov    ecx,r12d
  6466d2:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  6466d9:	41 8b 52 04          	mov    edx,DWORD PTR [r10+0x4]
  6466dd:	48 8b 83 e8 fe ff ff 	mov    rax,QWORD PTR [rbx-0x118]
  6466e4:	48 8b 40 10          	mov    rax,QWORD PTR [rax+0x10]
  6466e8:	8b 80 74 42 00 00    	mov    eax,DWORD PTR [rax+0x4274]
  6466ee:	41 89 03             	mov    DWORD PTR [r11],eax
  6466f1:	41 c7 43 04 18 00 00 	mov    DWORD PTR [r11+0x4],0x18
  6466f8:	00 
  6466f9:	41 c7 43 08 00 00 00 	mov    DWORD PTR [r11+0x8],0x0
  646700:	00 
  646701:	41 c7 43 0c 00 00 00 	mov    DWORD PTR [r11+0xc],0x0
  646708:	00 
  646709:	8b 84 24 18 01 00 00 	mov    eax,DWORD PTR [rsp+0x118]
  646710:	41 89 43 10          	mov    DWORD PTR [r11+0x10],eax
  646714:	8b 84 24 20 01 00 00 	mov    eax,DWORD PTR [rsp+0x120]
  64671b:	41 89 43 14          	mov    DWORD PTR [r11+0x14],eax
  64671f:	41 89 09             	mov    DWORD PTR [r9],ecx
  646722:	41 c7 41 04 18 00 00 	mov    DWORD PTR [r9+0x4],0x18
  646729:	00 
  64672a:	41 c7 41 08 00 00 00 	mov    DWORD PTR [r9+0x8],0x0
  646731:	00 
  646732:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  646739:	41 89 ca             	mov    r10d,ecx
  64673c:	41 83 c2 18          	add    r10d,0x18
  646740:	44 89 10             	mov    DWORD PTR [rax],r10d
  646743:	41 c7 41 0c 00 00 01 	mov    DWORD PTR [r9+0xc],0x10000
  64674a:	00 
  64674b:	83 c2 01             	add    edx,0x1
  64674e:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  646755:	41 89 52 04          	mov    DWORD PTR [r10+0x4],edx
  646759:	41 83 7a 18 00       	cmp    DWORD PTR [r10+0x18],0x0
  64675e:	0f 84 11 00 00 00    	je     0x646775
  646764:	4d 8b 90 98 00 00 00 	mov    r10,QWORD PTR [r8+0x98]
  64676b:	49 8b 02             	mov    rax,QWORD PTR [r10]
  64676e:	48 83 c0 01          	add    rax,0x1
  646772:	49 89 02             	mov    QWORD PTR [r10],rax
  646775:	89 f0                	mov    eax,esi
  646777:	d1 e0                	shl    eax,1
  646779:	48 89 84 24 18 01 00 	mov    QWORD PTR [rsp+0x118],rax
  646780:	00 
  646781:	e9 05 00 00 00       	jmp    0x64678b
  646786:	b8 00 00 00 00       	mov    eax,0x0
  64678b:	85 c0                	test   eax,eax
  64678d:	41 5b                	pop    r11
  64678f:	41 5a                	pop    r10
  646791:	41 59                	pop    r9
  646793:	41 58                	pop    r8
  646795:	41 5c                	pop    r12
  646797:	0f 85 69 00 00 00    	jne    0x646806
  64679d:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  6467a1:	48 8b 84 24 f0 00 00 	mov    rax,QWORD PTR [rsp+0xf0]
  6467a8:	00 
  6467a9:	49 89 40 48          	mov    QWORD PTR [r8+0x48],rax
  6467ad:	8b 84 24 f8 00 00 00 	mov    eax,DWORD PTR [rsp+0xf8]
  6467b4:	49 89 40 50          	mov    QWORD PTR [r8+0x50],rax
  6467b8:	8b 84 24 00 01 00 00 	mov    eax,DWORD PTR [rsp+0x100]
  6467bf:	49 89 40 58          	mov    QWORD PTR [r8+0x58],rax
  6467c3:	41 c7 40 40 0b 23 16 	mov    DWORD PTR [r8+0x40],0x4016230b
  6467ca:	40 
  6467cb:	41 c7 40 44 03 00 01 	mov    DWORD PTR [r8+0x44],0x10003
  6467d2:	00 
  6467d3:	41 ff 50 38          	call   QWORD PTR [r8+0x38]
  6467d7:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  6467db:	49 8b 80 48 02 00 00 	mov    rax,QWORD PTR [r8+0x248]
  6467e2:	48 89 84 24 f0 00 00 	mov    QWORD PTR [rsp+0xf0],rax
  6467e9:	00 
  6467ea:	4c 8b 0c 24          	mov    r9,QWORD PTR [rsp]
  6467ee:	4c 8b 5c 24 08       	mov    r11,QWORD PTR [rsp+0x8]
  6467f3:	44 8b 54 24 18       	mov    r10d,DWORD PTR [rsp+0x18]
  6467f8:	8b 6c 24 28          	mov    ebp,DWORD PTR [rsp+0x28]
  6467fc:	44 8b 64 24 48       	mov    r12d,DWORD PTR [rsp+0x48]
  646801:	44 8b 6c 24 58       	mov    r13d,DWORD PTR [rsp+0x58]
  646806:	48 8b bc 24 e8 00 00 	mov    rdi,QWORD PTR [rsp+0xe8]
  64680d:	00 
  64680e:	48 8b b4 24 f0 00 00 	mov    rsi,QWORD PTR [rsp+0xf0]
  646815:	00 
  646816:	48 89 f8             	mov    rax,rdi
  646819:	48 89 f1             	mov    rcx,rsi
  64681c:	e8 df 04 9c ff       	call   0x6d00
  646821:	8b 6c 24 28          	mov    ebp,DWORD PTR [rsp+0x28]
  646825:	48 89 ac 24 e8 00 00 	mov    QWORD PTR [rsp+0xe8],rbp
  64682c:	00 
  64682d:	e9 00 00 00 00       	jmp    0x646832
  646832:	8b 84 24 e8 00 00 00 	mov    eax,DWORD PTR [rsp+0xe8]
  646839:	48 81 c4 18 01 00 00 	add    rsp,0x118
  646840:	c3                   	ret
  646841:	41 51                	push   r9
  646843:	41 52                	push   r10
  646845:	41 53                	push   r11
  646847:	49 89 c2             	mov    r10,rax
  64684a:	49 c1 ea 20          	shr    r10,0x20
  64684e:	4d 85 d2             	test   r10,r10
  646851:	0f 85 f3 00 00 00    	jne    0x64694a
  646857:	85 c0                	test   eax,eax
  646859:	0f 85 0d 00 00 00    	jne    0x64686c
  64685f:	85 f6                	test   esi,esi
  646861:	0f 84 e3 00 00 00    	je     0x64694a
  646867:	e9 e9 00 00 00       	jmp    0x646955
  64686c:	89 ce                	mov    esi,ecx
  64686e:	41 89 c2             	mov    r10d,eax
  646871:	41 83 e2 01          	and    r10d,0x1
  646875:	45 85 d2             	test   r10d,r10d
  646878:	0f 85 cc 00 00 00    	jne    0x64694a
  64687e:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  646885:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  646889:	48 6b d2 04          	imul   rdx,rdx,0x4
  64688d:	41 8b 14 12          	mov    edx,DWORD PTR [r10+rdx*1]
  646891:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  646895:	d1 e8                	shr    eax,1
  646897:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  64689b:	0f 83 a9 00 00 00    	jae    0x64694a
  6468a1:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  6468a5:	48 c1 e0 04          	shl    rax,0x4
  6468a9:	49 01 c1             	add    r9,rax
  6468ac:	45 0f b6 54 21 0e    	movzx  r10d,BYTE PTR [r9+riz*1+0xe]
  6468b2:	45 85 d2             	test   r10d,r10d
  6468b5:	0f 84 8f 00 00 00    	je     0x64694a
  6468bb:	41 83 fa 04          	cmp    r10d,0x4
  6468bf:	0f 87 85 00 00 00    	ja     0x64694a
  6468c5:	4d 6b d2 10          	imul   r10,r10,0x10
  6468c9:	4d 8d 40 18          	lea    r8,[r8+0x18]
  6468cd:	4d 01 d0             	add    r8,r10
  6468d0:	4d 8b 18             	mov    r11,QWORD PTR [r8]
  6468d3:	45 8b 40 08          	mov    r8d,DWORD PTR [r8+0x8]
  6468d7:	41 8b 01             	mov    eax,DWORD PTR [r9]
  6468da:	44 39 c0             	cmp    eax,r8d
  6468dd:	0f 87 67 00 00 00    	ja     0x64694a
  6468e3:	41 29 c0             	sub    r8d,eax
  6468e6:	41 8b 49 04          	mov    ecx,DWORD PTR [r9+0x4]
  6468ea:	44 39 c1             	cmp    ecx,r8d
  6468ed:	0f 87 57 00 00 00    	ja     0x64694a
  6468f3:	83 f9 10             	cmp    ecx,0x10
  6468f6:	0f 82 4e 00 00 00    	jb     0x64694a
  6468fc:	49 01 c3             	add    r11,rax
  6468ff:	41 8b 0b             	mov    ecx,DWORD PTR [r11]
  646902:	39 d1                	cmp    ecx,edx
  646904:	0f 85 40 00 00 00    	jne    0x64694a
  64690a:	45 8b 53 08          	mov    r10d,DWORD PTR [r11+0x8]
  64690e:	44 39 d6             	cmp    esi,r10d
  646911:	0f 83 49 00 00 00    	jae    0x646960
  646917:	48 6b f6 04          	imul   rsi,rsi,0x4
  64691b:	45 8b 53 04          	mov    r10d,DWORD PTR [r11+0x4]
  64691f:	49 89 f0             	mov    r8,rsi
  646922:	49 83 c0 14          	add    r8,0x14
  646926:	41 8b 51 04          	mov    edx,DWORD PTR [r9+0x4]
  64692a:	49 39 d0             	cmp    r8,rdx
  64692d:	0f 87 17 00 00 00    	ja     0x64694a
  646933:	4d 39 d0             	cmp    r8,r10
  646936:	0f 87 0e 00 00 00    	ja     0x64694a
  64693c:	49 8d 43 10          	lea    rax,[r11+0x10]
  646940:	48 01 f0             	add    rax,rsi
  646943:	41 5b                	pop    r11
  646945:	41 5a                	pop    r10
  646947:	41 59                	pop    r9
  646949:	c3                   	ret
  64694a:	41 5b                	pop    r11
  64694c:	41 5a                	pop    r10
  64694e:	41 59                	pop    r9
  646950:	e9 af 04 00 00       	jmp    0x646e04
  646955:	41 5b                	pop    r11
  646957:	41 5a                	pop    r10
  646959:	41 59                	pop    r9
  64695b:	e9 7c 04 00 00       	jmp    0x646ddc
  646960:	41 5b                	pop    r11
  646962:	41 5a                	pop    r10
  646964:	41 59                	pop    r9
  646966:	e9 17 04 00 00       	jmp    0x646d82
  64696b:	41 51                	push   r9
  64696d:	41 52                	push   r10
  64696f:	41 53                	push   r11
  646971:	49 89 c2             	mov    r10,rax
  646974:	49 c1 ea 20          	shr    r10,0x20
  646978:	4d 85 d2             	test   r10,r10
  64697b:	0f 85 31 01 00 00    	jne    0x646ab2
  646981:	85 c0                	test   eax,eax
  646983:	0f 85 0d 00 00 00    	jne    0x646996
  646989:	85 c9                	test   ecx,ecx
  64698b:	0f 84 21 01 00 00    	je     0x646ab2
  646991:	e9 15 01 00 00       	jmp    0x646aab
  646996:	89 c7                	mov    edi,eax
  646998:	41 89 c2             	mov    r10d,eax
  64699b:	41 83 e2 01          	and    r10d,0x1
  64699f:	45 85 d2             	test   r10d,r10d
  6469a2:	0f 85 0a 01 00 00    	jne    0x646ab2
  6469a8:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  6469af:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  6469b3:	48 6b d2 04          	imul   rdx,rdx,0x4
  6469b7:	41 8b 14 12          	mov    edx,DWORD PTR [r10+rdx*1]
  6469bb:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  6469bf:	d1 e8                	shr    eax,1
  6469c1:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  6469c5:	0f 83 e7 00 00 00    	jae    0x646ab2
  6469cb:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  6469cf:	48 c1 e0 04          	shl    rax,0x4
  6469d3:	49 01 c1             	add    r9,rax
  6469d6:	45 0f b6 54 21 0e    	movzx  r10d,BYTE PTR [r9+riz*1+0xe]
  6469dc:	45 85 d2             	test   r10d,r10d
  6469df:	0f 84 cd 00 00 00    	je     0x646ab2
  6469e5:	41 83 fa 04          	cmp    r10d,0x4
  6469e9:	0f 87 c3 00 00 00    	ja     0x646ab2
  6469ef:	41 c1 e2 04          	shl    r10d,0x4
  6469f3:	4f 8b 5c 10 18       	mov    r11,QWORD PTR [r8+r10*1+0x18]
  6469f8:	47 8b 44 10 20       	mov    r8d,DWORD PTR [r8+r10*1+0x20]
  6469fd:	41 8b 01             	mov    eax,DWORD PTR [r9]
  646a00:	44 39 c0             	cmp    eax,r8d
  646a03:	0f 87 a9 00 00 00    	ja     0x646ab2
  646a09:	41 29 c0             	sub    r8d,eax
  646a0c:	41 8b 49 04          	mov    ecx,DWORD PTR [r9+0x4]
  646a10:	44 39 c1             	cmp    ecx,r8d
  646a13:	0f 87 99 00 00 00    	ja     0x646ab2
  646a19:	83 f9 10             	cmp    ecx,0x10
  646a1c:	0f 82 90 00 00 00    	jb     0x646ab2
  646a22:	49 01 c3             	add    r11,rax
  646a25:	41 8b 0b             	mov    ecx,DWORD PTR [r11]
  646a28:	39 d1                	cmp    ecx,edx
  646a2a:	0f 84 74 00 00 00    	je     0x646aa4
  646a30:	85 f6                	test   esi,esi
  646a32:	0f 85 7a 00 00 00    	jne    0x646ab2
  646a38:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  646a3f:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  646a43:	89 c8                	mov    eax,ecx
  646a45:	41 3b 80 a4 00 00 00 	cmp    eax,DWORD PTR [r8+0xa4]
  646a4c:	0f 83 60 00 00 00    	jae    0x646ab2
  646a52:	89 d0                	mov    eax,edx
  646a54:	41 3b 80 a4 00 00 00 	cmp    eax,DWORD PTR [r8+0xa4]
  646a5b:	0f 83 51 00 00 00    	jae    0x646ab2
  646a61:	4d 8b 90 a8 00 00 00 	mov    r10,QWORD PTR [r8+0xa8]
  646a68:	4d 85 d2             	test   r10,r10
  646a6b:	0f 84 41 00 00 00    	je     0x646ab2
  646a71:	89 c8                	mov    eax,ecx
  646a73:	48 6b c0 08          	imul   rax,rax,0x8
  646a77:	4d 8b 0c 02          	mov    r9,QWORD PTR [r10+rax*1]
  646a7b:	89 d0                	mov    eax,edx
  646a7d:	48 6b c0 08          	imul   rax,rax,0x8
  646a81:	4d 8b 14 02          	mov    r10,QWORD PTR [r10+rax*1]
  646a85:	4c 89 c8             	mov    rax,r9
  646a88:	48 c1 e8 20          	shr    rax,0x20
  646a8c:	4c 89 d1             	mov    rcx,r10
  646a8f:	48 c1 e9 20          	shr    rcx,0x20
  646a93:	39 c8                	cmp    eax,ecx
  646a95:	0f 82 17 00 00 00    	jb     0x646ab2
  646a9b:	45 39 d1             	cmp    r9d,r10d
  646a9e:	0f 87 0e 00 00 00    	ja     0x646ab2
  646aa4:	89 f8                	mov    eax,edi
  646aa6:	e9 00 00 00 00       	jmp    0x646aab
  646aab:	41 5b                	pop    r11
  646aad:	41 5a                	pop    r10
  646aaf:	41 59                	pop    r9
  646ab1:	c3                   	ret
  646ab2:	41 5b                	pop    r11
  646ab4:	41 5a                	pop    r10
  646ab6:	41 59                	pop    r9
  646ab8:	e9 47 03 00 00       	jmp    0x646e04
  646abd:	41 51                	push   r9
  646abf:	41 52                	push   r10
  646ac1:	41 53                	push   r11
  646ac3:	49 89 c2             	mov    r10,rax
  646ac6:	49 c1 ea 20          	shr    r10,0x20
  646aca:	4d 85 d2             	test   r10,r10
  646acd:	0f 85 46 01 00 00    	jne    0x646c19
  646ad3:	85 c0                	test   eax,eax
  646ad5:	0f 85 0c 00 00 00    	jne    0x646ae7
  646adb:	89 c8                	mov    eax,ecx
  646add:	ba 00 00 00 00       	mov    edx,0x0
  646ae2:	e9 3c 01 00 00       	jmp    0x646c23
  646ae7:	41 89 c2             	mov    r10d,eax
  646aea:	41 83 e2 01          	and    r10d,0x1
  646aee:	45 85 d2             	test   r10d,r10d
  646af1:	0f 85 22 01 00 00    	jne    0x646c19
  646af7:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  646afe:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  646b02:	48 6b d2 04          	imul   rdx,rdx,0x4
  646b06:	41 8b 14 12          	mov    edx,DWORD PTR [r10+rdx*1]
  646b0a:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  646b0e:	d1 e8                	shr    eax,1
  646b10:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  646b14:	0f 83 10 01 00 00    	jae    0x646c2a
  646b1a:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  646b1e:	48 c1 e0 04          	shl    rax,0x4
  646b22:	49 01 c1             	add    r9,rax
  646b25:	45 0f b6 54 21 0e    	movzx  r10d,BYTE PTR [r9+riz*1+0xe]
  646b2b:	45 85 d2             	test   r10d,r10d
  646b2e:	0f 84 f6 00 00 00    	je     0x646c2a
  646b34:	41 83 fa 04          	cmp    r10d,0x4
  646b38:	0f 87 ec 00 00 00    	ja     0x646c2a
  646b3e:	41 c1 e2 04          	shl    r10d,0x4
  646b42:	4f 8b 5c 10 18       	mov    r11,QWORD PTR [r8+r10*1+0x18]
  646b47:	47 8b 44 10 20       	mov    r8d,DWORD PTR [r8+r10*1+0x20]
  646b4c:	41 8b 01             	mov    eax,DWORD PTR [r9]
  646b4f:	44 39 c0             	cmp    eax,r8d
  646b52:	0f 87 d2 00 00 00    	ja     0x646c2a
  646b58:	41 29 c0             	sub    r8d,eax
  646b5b:	41 8b 49 04          	mov    ecx,DWORD PTR [r9+0x4]
  646b5f:	44 39 c1             	cmp    ecx,r8d
  646b62:	0f 87 c2 00 00 00    	ja     0x646c2a
  646b68:	83 f9 10             	cmp    ecx,0x10
  646b6b:	0f 82 b9 00 00 00    	jb     0x646c2a
  646b71:	89 cf                	mov    edi,ecx
  646b73:	49 01 c3             	add    r11,rax
  646b76:	41 8b 0b             	mov    ecx,DWORD PTR [r11]
  646b79:	39 d1                	cmp    ecx,edx
  646b7b:	0f 84 6c 00 00 00    	je     0x646bed
  646b81:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  646b88:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  646b8c:	89 c8                	mov    eax,ecx
  646b8e:	41 3b 80 a4 00 00 00 	cmp    eax,DWORD PTR [r8+0xa4]
  646b95:	0f 83 8f 00 00 00    	jae    0x646c2a
  646b9b:	89 d0                	mov    eax,edx
  646b9d:	41 3b 80 a4 00 00 00 	cmp    eax,DWORD PTR [r8+0xa4]
  646ba4:	0f 83 80 00 00 00    	jae    0x646c2a
  646baa:	4d 8b 90 a8 00 00 00 	mov    r10,QWORD PTR [r8+0xa8]
  646bb1:	4d 85 d2             	test   r10,r10
  646bb4:	0f 84 70 00 00 00    	je     0x646c2a
  646bba:	89 c8                	mov    eax,ecx
  646bbc:	48 6b c0 08          	imul   rax,rax,0x8
  646bc0:	4d 8b 0c 02          	mov    r9,QWORD PTR [r10+rax*1]
  646bc4:	89 d0                	mov    eax,edx
  646bc6:	48 6b c0 08          	imul   rax,rax,0x8
  646bca:	4d 8b 14 02          	mov    r10,QWORD PTR [r10+rax*1]
  646bce:	4c 89 c8             	mov    rax,r9
  646bd1:	48 c1 e8 20          	shr    rax,0x20
  646bd5:	4c 89 d1             	mov    rcx,r10
  646bd8:	48 c1 e9 20          	shr    rcx,0x20
  646bdc:	39 c8                	cmp    eax,ecx
  646bde:	0f 82 35 00 00 00    	jb     0x646c19
  646be4:	45 39 d1             	cmp    r9d,r10d
  646be7:	0f 87 2c 00 00 00    	ja     0x646c19
  646bed:	41 8b 03             	mov    eax,DWORD PTR [r11]
  646bf0:	39 d0                	cmp    eax,edx
  646bf2:	0f 85 32 00 00 00    	jne    0x646c2a
  646bf8:	39 f7                	cmp    edi,esi
  646bfa:	0f 82 2a 00 00 00    	jb     0x646c2a
  646c00:	41 8b 43 04          	mov    eax,DWORD PTR [r11+0x4]
  646c04:	39 f0                	cmp    eax,esi
  646c06:	0f 82 1e 00 00 00    	jb     0x646c2a
  646c0c:	4c 89 da             	mov    rdx,r11
  646c0f:	b8 01 00 00 00       	mov    eax,0x1
  646c14:	e9 0a 00 00 00       	jmp    0x646c23
  646c19:	b8 00 00 00 00       	mov    eax,0x0
  646c1e:	ba 00 00 00 00       	mov    edx,0x0
  646c23:	41 5b                	pop    r11
  646c25:	41 5a                	pop    r10
  646c27:	41 59                	pop    r9
  646c29:	c3                   	ret
  646c2a:	41 5b                	pop    r11
  646c2c:	41 5a                	pop    r10
  646c2e:	41 59                	pop    r9
  646c30:	e9 cf 01 00 00       	jmp    0x646e04
  646c35:	41 51                	push   r9
  646c37:	41 52                	push   r10
  646c39:	41 53                	push   r11
  646c3b:	89 cf                	mov    edi,ecx
  646c3d:	49 89 c2             	mov    r10,rax
  646c40:	49 c1 ea 20          	shr    r10,0x20
  646c44:	4d 85 d2             	test   r10,r10
  646c47:	0f 85 c5 00 00 00    	jne    0x646d12
  646c4d:	85 c0                	test   eax,eax
  646c4f:	0f 85 0d 00 00 00    	jne    0x646c62
  646c55:	85 f6                	test   esi,esi
  646c57:	0f 84 b5 00 00 00    	je     0x646d12
  646c5d:	e9 bb 00 00 00       	jmp    0x646d1d
  646c62:	41 89 c2             	mov    r10d,eax
  646c65:	41 83 e2 01          	and    r10d,0x1
  646c69:	45 85 d2             	test   r10d,r10d
  646c6c:	0f 85 a0 00 00 00    	jne    0x646d12
  646c72:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  646c79:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  646c7d:	48 6b d2 04          	imul   rdx,rdx,0x4
  646c81:	41 8b 14 12          	mov    edx,DWORD PTR [r10+rdx*1]
  646c85:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  646c89:	d1 e8                	shr    eax,1
  646c8b:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  646c8f:	0f 83 7d 00 00 00    	jae    0x646d12
  646c95:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  646c99:	48 c1 e0 04          	shl    rax,0x4
  646c9d:	49 01 c1             	add    r9,rax
  646ca0:	45 0f b6 54 21 0e    	movzx  r10d,BYTE PTR [r9+riz*1+0xe]
  646ca6:	45 85 d2             	test   r10d,r10d
  646ca9:	0f 84 63 00 00 00    	je     0x646d12
  646caf:	41 83 fa 04          	cmp    r10d,0x4
  646cb3:	0f 87 59 00 00 00    	ja     0x646d12
  646cb9:	41 c1 e2 04          	shl    r10d,0x4
  646cbd:	4f 8b 5c 10 18       	mov    r11,QWORD PTR [r8+r10*1+0x18]
  646cc2:	47 8b 44 10 20       	mov    r8d,DWORD PTR [r8+r10*1+0x20]
  646cc7:	41 8b 01             	mov    eax,DWORD PTR [r9]
  646cca:	44 39 c0             	cmp    eax,r8d
  646ccd:	0f 87 3f 00 00 00    	ja     0x646d12
  646cd3:	41 29 c0             	sub    r8d,eax
  646cd6:	41 8b 49 04          	mov    ecx,DWORD PTR [r9+0x4]
  646cda:	44 39 c1             	cmp    ecx,r8d
  646cdd:	0f 87 2f 00 00 00    	ja     0x646d12
  646ce3:	39 f9                	cmp    ecx,edi
  646ce5:	0f 82 27 00 00 00    	jb     0x646d12
  646ceb:	49 01 c3             	add    r11,rax
  646cee:	41 8b 0b             	mov    ecx,DWORD PTR [r11]
  646cf1:	39 d1                	cmp    ecx,edx
  646cf3:	0f 85 19 00 00 00    	jne    0x646d12
  646cf9:	41 8b 4b 04          	mov    ecx,DWORD PTR [r11+0x4]
  646cfd:	39 f9                	cmp    ecx,edi
  646cff:	0f 82 0d 00 00 00    	jb     0x646d12
  646d05:	4c 89 de             	mov    rsi,r11
  646d08:	41 5b                	pop    r11
  646d0a:	41 5a                	pop    r10
  646d0c:	41 59                	pop    r9
  646d0e:	48 89 f0             	mov    rax,rsi
  646d11:	c3                   	ret
  646d12:	41 5b                	pop    r11
  646d14:	41 5a                	pop    r10
  646d16:	41 59                	pop    r9
  646d18:	e9 e7 00 00 00       	jmp    0x646e04
  646d1d:	41 5b                	pop    r11
  646d1f:	41 5a                	pop    r10
  646d21:	41 59                	pop    r9
  646d23:	e9 b4 00 00 00       	jmp    0x646ddc
  646d28:	b8 13 00 00 00       	mov    eax,0x13
  646d2d:	e9 00 00 00 00       	jmp    0x646d32
  646d32:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  646d36:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  646d39:	44 89 36             	mov    DWORD PTR [rsi],r14d
  646d3c:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  646d40:	c7 46 10 a9 01 00 00 	mov    DWORD PTR [rsi+0x10],0x1a9
  646d47:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  646d4a:	c7 06 01 00 00 00    	mov    DWORD PTR [rsi],0x1
  646d50:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  646d54:	c3                   	ret
  646d55:	b8 13 00 00 00       	mov    eax,0x13
  646d5a:	e9 00 00 00 00       	jmp    0x646d5f
  646d5f:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  646d63:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  646d66:	44 89 36             	mov    DWORD PTR [rsi],r14d
  646d69:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  646d6d:	c7 46 10 c2 01 00 00 	mov    DWORD PTR [rsi+0x10],0x1c2
  646d74:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  646d77:	c7 06 01 00 00 00    	mov    DWORD PTR [rsi],0x1
  646d7d:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  646d81:	c3                   	ret
  646d82:	b8 ff ff ff ff       	mov    eax,0xffffffff
  646d87:	e9 00 00 00 00       	jmp    0x646d8c
  646d8c:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  646d90:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  646d93:	44 89 36             	mov    DWORD PTR [rsi],r14d
  646d96:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  646d9a:	c7 46 10 13 09 00 00 	mov    DWORD PTR [rsi+0x10],0x913
  646da1:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  646da4:	c7 06 02 00 00 00    	mov    DWORD PTR [rsi],0x2
  646daa:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  646dae:	c3                   	ret
  646daf:	b8 00 00 00 00       	mov    eax,0x0
  646db4:	e9 00 00 00 00       	jmp    0x646db9
  646db9:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  646dbd:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  646dc0:	44 89 36             	mov    DWORD PTR [rsi],r14d
  646dc3:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  646dc7:	c7 46 10 13 09 00 00 	mov    DWORD PTR [rsi+0x10],0x913
  646dce:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  646dd1:	c7 06 0d 00 00 00    	mov    DWORD PTR [rsi],0xd
  646dd7:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  646ddb:	c3                   	ret
  646ddc:	b8 ff ff ff ff       	mov    eax,0xffffffff
  646de1:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  646de5:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  646de8:	44 89 36             	mov    DWORD PTR [rsi],r14d
  646deb:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  646def:	c7 46 10 13 09 00 00 	mov    DWORD PTR [rsi+0x10],0x913
  646df6:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  646df9:	c7 06 10 00 00 00    	mov    DWORD PTR [rsi],0x10
  646dff:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  646e03:	c3                   	ret
  646e04:	b8 ff ff ff ff       	mov    eax,0xffffffff
  646e09:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  646e0d:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  646e10:	44 89 36             	mov    DWORD PTR [rsi],r14d
  646e13:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  646e17:	c7 46 10 13 09 00 00 	mov    DWORD PTR [rsi+0x10],0x913
  646e1e:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  646e21:	c7 06 12 00 00 00    	mov    DWORD PTR [rsi],0x12
  646e27:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  646e2b:	c3                   	ret
