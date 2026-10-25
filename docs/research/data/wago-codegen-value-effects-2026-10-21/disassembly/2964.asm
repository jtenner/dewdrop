
.tmp/wago-next-gc-perf/post-read-regions-profile/profile/native-code.bin:     file format binary


Disassembly of section .data:

000000000096ad80 <.data+0x96ad80>:
  96ad80:	48 81 ec 68 01 00 00 	sub    rsp,0x168
  96ad87:	48 8b 73 b8          	mov    rsi,QWORD PTR [rbx-0x48]
  96ad8b:	48 39 f4             	cmp    rsp,rsi
  96ad8e:	0f 82 d6 16 00 00    	jb     0x96c46a
  96ad94:	49 89 c1             	mov    r9,rax
  96ad97:	49 89 ca             	mov    r10,rcx
  96ad9a:	89 54 24 10          	mov    DWORD PTR [rsp+0x10],edx
  96ad9e:	31 c0                	xor    eax,eax
  96ada0:	48 89 44 24 18       	mov    QWORD PTR [rsp+0x18],rax
  96ada5:	45 31 db             	xor    r11d,r11d
  96ada8:	89 44 24 28          	mov    DWORD PTR [rsp+0x28],eax
  96adac:	89 44 24 30          	mov    DWORD PTR [rsp+0x30],eax
  96adb0:	89 44 24 38          	mov    DWORD PTR [rsp+0x38],eax
  96adb4:	89 44 24 40          	mov    DWORD PTR [rsp+0x40],eax
  96adb8:	31 ed                	xor    ebp,ebp
  96adba:	48 89 44 24 50       	mov    QWORD PTR [rsp+0x50],rax
  96adbf:	89 44 24 58          	mov    DWORD PTR [rsp+0x58],eax
  96adc3:	89 44 24 60          	mov    DWORD PTR [rsp+0x60],eax
  96adc7:	45 31 e4             	xor    r12d,r12d
  96adca:	89 44 24 70          	mov    DWORD PTR [rsp+0x70],eax
  96adce:	48 89 44 24 78       	mov    QWORD PTR [rsp+0x78],rax
  96add3:	48 89 84 24 80 00 00 	mov    QWORD PTR [rsp+0x80],rax
  96adda:	00 
  96addb:	45 31 ed             	xor    r13d,r13d
  96adde:	89 84 24 90 00 00 00 	mov    DWORD PTR [rsp+0x90],eax
  96ade5:	89 84 24 98 00 00 00 	mov    DWORD PTR [rsp+0x98],eax
  96adec:	89 84 24 a0 00 00 00 	mov    DWORD PTR [rsp+0xa0],eax
  96adf3:	bf 09 00 00 00       	mov    edi,0x9
  96adf8:	48 89 bc 24 38 01 00 	mov    QWORD PTR [rsp+0x138],rdi
  96adff:	00 
  96ae00:	4c 89 cf             	mov    rdi,r9
  96ae03:	48 89 f8             	mov    rax,rdi
  96ae06:	ba ba 10 00 00       	mov    edx,0x10ba
  96ae0b:	b9 24 00 00 00       	mov    ecx,0x24
  96ae10:	be 00 00 00 00       	mov    esi,0x0
  96ae15:	e8 8b 14 00 00       	call   0x96c2a5
  96ae1a:	8b 40 20             	mov    eax,DWORD PTR [rax+0x20]
  96ae1d:	8b 7c 24 10          	mov    edi,DWORD PTR [rsp+0x10]
  96ae21:	89 bc 24 b0 00 00 00 	mov    DWORD PTR [rsp+0xb0],edi
  96ae28:	48 89 84 24 a8 00 00 	mov    QWORD PTR [rsp+0xa8],rax
  96ae2f:	00 
  96ae30:	8b bc 24 b0 00 00 00 	mov    edi,DWORD PTR [rsp+0xb0]
  96ae37:	48 89 bc 24 40 01 00 	mov    QWORD PTR [rsp+0x140],rdi
  96ae3e:	00 
  96ae3f:	48 8b bc 24 a8 00 00 	mov    rdi,QWORD PTR [rsp+0xa8]
  96ae46:	00 
  96ae47:	48 89 f8             	mov    rax,rdi
  96ae4a:	ba a0 09 00 00       	mov    edx,0x9a0
  96ae4f:	b9 18 00 00 00       	mov    ecx,0x18
  96ae54:	be 00 00 00 00       	mov    esi,0x0
  96ae59:	e8 47 14 00 00       	call   0x96c2a5
  96ae5e:	48 89 84 24 b8 00 00 	mov    QWORD PTR [rsp+0xb8],rax
  96ae65:	00 
  96ae66:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  96ae6a:	4c 89 0c 24          	mov    QWORD PTR [rsp],r9
  96ae6e:	4c 89 54 24 08       	mov    QWORD PTR [rsp+0x8],r10
  96ae73:	44 89 5c 24 20       	mov    DWORD PTR [rsp+0x20],r11d
  96ae78:	89 6c 24 48          	mov    DWORD PTR [rsp+0x48],ebp
  96ae7c:	44 89 64 24 68       	mov    DWORD PTR [rsp+0x68],r12d
  96ae81:	44 89 ac 24 88 00 00 	mov    DWORD PTR [rsp+0x88],r13d
  96ae88:	00 
  96ae89:	8b bc 24 40 01 00 00 	mov    edi,DWORD PTR [rsp+0x140]
  96ae90:	39 c7                	cmp    edi,eax
  96ae92:	0f 82 05 00 00 00    	jb     0x96ae9d
  96ae98:	e9 50 15 00 00       	jmp    0x96c3ed
  96ae9d:	48 8b bc 24 b8 00 00 	mov    rdi,QWORD PTR [rsp+0xb8]
  96aea4:	00 
  96aea5:	8b 7f 10             	mov    edi,DWORD PTR [rdi+0x10]
  96aea8:	48 89 f8             	mov    rax,rdi
  96aeab:	8b bc 24 b0 00 00 00 	mov    edi,DWORD PTR [rsp+0xb0]
  96aeb2:	89 f9                	mov    ecx,edi
  96aeb4:	ba 3b 23 00 00       	mov    edx,0x233b
  96aeb9:	be 00 00 00 00       	mov    esi,0x0
  96aebe:	e8 a4 0e 00 00       	call   0x96bd67
  96aec3:	48 8b 04 20          	mov    rax,QWORD PTR [rax+riz*1]
  96aec7:	48 89 84 24 40 01 00 	mov    QWORD PTR [rsp+0x140],rax
  96aece:	00 
  96aecf:	48 8b bc 24 38 01 00 	mov    rdi,QWORD PTR [rsp+0x138]
  96aed6:	00 
  96aed7:	48 8b b4 24 40 01 00 	mov    rsi,QWORD PTR [rsp+0x140]
  96aede:	00 
  96aedf:	48 89 f8             	mov    rax,rdi
  96aee2:	48 89 f1             	mov    rcx,rsi
  96aee5:	e8 63 3f ff ff       	call   0x95ee4d
  96aeea:	48 89 c7             	mov    rdi,rax
  96aeed:	48 89 7c 24 18       	mov    QWORD PTR [rsp+0x18],rdi
  96aef2:	4c 8b 54 24 08       	mov    r10,QWORD PTR [rsp+0x8]
  96aef7:	4c 89 d7             	mov    rdi,r10
  96aefa:	48 89 bc 24 c0 00 00 	mov    QWORD PTR [rsp+0xc0],rdi
  96af01:	00 
  96af02:	48 8b bc 24 c0 00 00 	mov    rdi,QWORD PTR [rsp+0xc0]
  96af09:	00 
  96af0a:	48 89 f8             	mov    rax,rdi
  96af0d:	ba a0 09 00 00       	mov    edx,0x9a0
  96af12:	b9 18 00 00 00       	mov    ecx,0x18
  96af17:	be 00 00 00 00       	mov    esi,0x0
  96af1c:	e8 84 13 00 00       	call   0x96c2a5
  96af21:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  96af25:	48 89 84 24 38 01 00 	mov    QWORD PTR [rsp+0x138],rax
  96af2c:	00 
  96af2d:	44 8b 9c 24 38 01 00 	mov    r11d,DWORD PTR [rsp+0x138]
  96af34:	00 
  96af35:	bf 00 00 00 00       	mov    edi,0x0
  96af3a:	89 7c 24 70          	mov    DWORD PTR [rsp+0x70],edi
  96af3e:	4c 8b 0c 24          	mov    r9,QWORD PTR [rsp]
  96af42:	44 89 5c 24 20       	mov    DWORD PTR [rsp+0x20],r11d
  96af47:	8b 6c 24 48          	mov    ebp,DWORD PTR [rsp+0x48]
  96af4b:	44 8b 64 24 68       	mov    r12d,DWORD PTR [rsp+0x68]
  96af50:	44 8b ac 24 88 00 00 	mov    r13d,DWORD PTR [rsp+0x88]
  96af57:	00 
  96af58:	66 0f 1f 84 00 00 00 	nop    WORD PTR [rax+rax*1+0x0]
  96af5f:	00 00 
  96af61:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
  96af68:	8b 7c 24 70          	mov    edi,DWORD PTR [rsp+0x70]
  96af6c:	89 7c 24 28          	mov    DWORD PTR [rsp+0x28],edi
  96af70:	44 89 de             	mov    esi,r11d
  96af73:	89 b4 24 d0 00 00 00 	mov    DWORD PTR [rsp+0xd0],esi
  96af7a:	89 bc 24 c8 00 00 00 	mov    DWORD PTR [rsp+0xc8],edi
  96af81:	8b bc 24 c8 00 00 00 	mov    edi,DWORD PTR [rsp+0xc8]
  96af88:	8b b4 24 d0 00 00 00 	mov    esi,DWORD PTR [rsp+0xd0]
  96af8f:	39 f7                	cmp    edi,esi
  96af91:	0f 83 af 01 00 00    	jae    0x96b146
  96af97:	8b 7c 24 28          	mov    edi,DWORD PTR [rsp+0x28]
  96af9b:	89 bc 24 e0 00 00 00 	mov    DWORD PTR [rsp+0xe0],edi
  96afa2:	4c 89 d7             	mov    rdi,r10
  96afa5:	48 89 bc 24 d8 00 00 	mov    QWORD PTR [rsp+0xd8],rdi
  96afac:	00 
  96afad:	8b bc 24 e0 00 00 00 	mov    edi,DWORD PTR [rsp+0xe0]
  96afb4:	48 89 bc 24 38 01 00 	mov    QWORD PTR [rsp+0x138],rdi
  96afbb:	00 
  96afbc:	48 8b bc 24 d8 00 00 	mov    rdi,QWORD PTR [rsp+0xd8]
  96afc3:	00 
  96afc4:	48 89 f8             	mov    rax,rdi
  96afc7:	ba a0 09 00 00       	mov    edx,0x9a0
  96afcc:	b9 18 00 00 00       	mov    ecx,0x18
  96afd1:	be 00 00 00 00       	mov    esi,0x0
  96afd6:	e8 ca 12 00 00       	call   0x96c2a5
  96afdb:	48 89 84 24 e8 00 00 	mov    QWORD PTR [rsp+0xe8],rax
  96afe2:	00 
  96afe3:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  96afe7:	8b bc 24 38 01 00 00 	mov    edi,DWORD PTR [rsp+0x138]
  96afee:	39 c7                	cmp    edi,eax
  96aff0:	0f 82 05 00 00 00    	jb     0x96affb
  96aff6:	e9 ca 13 00 00       	jmp    0x96c3c5
  96affb:	48 8b bc 24 e8 00 00 	mov    rdi,QWORD PTR [rsp+0xe8]
  96b002:	00 
  96b003:	8b 7f 10             	mov    edi,DWORD PTR [rdi+0x10]
  96b006:	48 89 f8             	mov    rax,rdi
  96b009:	8b bc 24 e0 00 00 00 	mov    edi,DWORD PTR [rsp+0xe0]
  96b010:	89 f9                	mov    ecx,edi
  96b012:	ba 3a 23 00 00       	mov    edx,0x233a
  96b017:	be 00 00 00 00       	mov    esi,0x0
  96b01c:	e8 1c 0c 00 00       	call   0x96bc3d
  96b021:	8b 04 20             	mov    eax,DWORD PTR [rax+riz*1]
  96b024:	48 89 84 24 38 01 00 	mov    QWORD PTR [rsp+0x138],rax
  96b02b:	00 
  96b02c:	8b bc 24 38 01 00 00 	mov    edi,DWORD PTR [rsp+0x138]
  96b033:	89 7c 24 30          	mov    DWORD PTR [rsp+0x30],edi
  96b037:	48 8b 7c 24 18       	mov    rdi,QWORD PTR [rsp+0x18]
  96b03c:	48 89 bc 24 38 01 00 	mov    QWORD PTR [rsp+0x138],rdi
  96b043:	00 
  96b044:	4c 89 cf             	mov    rdi,r9
  96b047:	48 89 f8             	mov    rax,rdi
  96b04a:	ba ba 10 00 00       	mov    edx,0x10ba
  96b04f:	b9 24 00 00 00       	mov    ecx,0x24
  96b054:	be 00 00 00 00       	mov    esi,0x0
  96b059:	e8 47 12 00 00       	call   0x96c2a5
  96b05e:	8b 40 20             	mov    eax,DWORD PTR [rax+0x20]
  96b061:	8b 7c 24 30          	mov    edi,DWORD PTR [rsp+0x30]
  96b065:	89 bc 24 b0 00 00 00 	mov    DWORD PTR [rsp+0xb0],edi
  96b06c:	48 89 84 24 a8 00 00 	mov    QWORD PTR [rsp+0xa8],rax
  96b073:	00 
  96b074:	8b bc 24 b0 00 00 00 	mov    edi,DWORD PTR [rsp+0xb0]
  96b07b:	48 89 bc 24 40 01 00 	mov    QWORD PTR [rsp+0x140],rdi
  96b082:	00 
  96b083:	48 8b bc 24 a8 00 00 	mov    rdi,QWORD PTR [rsp+0xa8]
  96b08a:	00 
  96b08b:	48 89 f8             	mov    rax,rdi
  96b08e:	ba a0 09 00 00       	mov    edx,0x9a0
  96b093:	b9 18 00 00 00       	mov    ecx,0x18
  96b098:	be 00 00 00 00       	mov    esi,0x0
  96b09d:	e8 03 12 00 00       	call   0x96c2a5
  96b0a2:	48 89 84 24 b8 00 00 	mov    QWORD PTR [rsp+0xb8],rax
  96b0a9:	00 
  96b0aa:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  96b0ae:	8b bc 24 40 01 00 00 	mov    edi,DWORD PTR [rsp+0x140]
  96b0b5:	39 c7                	cmp    edi,eax
  96b0b7:	0f 82 05 00 00 00    	jb     0x96b0c2
  96b0bd:	e9 2b 13 00 00       	jmp    0x96c3ed
  96b0c2:	48 8b bc 24 b8 00 00 	mov    rdi,QWORD PTR [rsp+0xb8]
  96b0c9:	00 
  96b0ca:	8b 7f 10             	mov    edi,DWORD PTR [rdi+0x10]
  96b0cd:	48 89 f8             	mov    rax,rdi
  96b0d0:	8b bc 24 b0 00 00 00 	mov    edi,DWORD PTR [rsp+0xb0]
  96b0d7:	89 f9                	mov    ecx,edi
  96b0d9:	ba 3b 23 00 00       	mov    edx,0x233b
  96b0de:	be 00 00 00 00       	mov    esi,0x0
  96b0e3:	e8 7f 0c 00 00       	call   0x96bd67
  96b0e8:	48 8b 04 20          	mov    rax,QWORD PTR [rax+riz*1]
  96b0ec:	48 89 84 24 40 01 00 	mov    QWORD PTR [rsp+0x140],rax
  96b0f3:	00 
  96b0f4:	48 8b bc 24 38 01 00 	mov    rdi,QWORD PTR [rsp+0x138]
  96b0fb:	00 
  96b0fc:	48 8b b4 24 40 01 00 	mov    rsi,QWORD PTR [rsp+0x140]
  96b103:	00 
  96b104:	48 89 f8             	mov    rax,rdi
  96b107:	48 89 f1             	mov    rcx,rsi
  96b10a:	e8 3e 3d ff ff       	call   0x95ee4d
  96b10f:	48 89 c7             	mov    rdi,rax
  96b112:	48 89 7c 24 18       	mov    QWORD PTR [rsp+0x18],rdi
  96b117:	8b 7c 24 28          	mov    edi,DWORD PTR [rsp+0x28]
  96b11b:	83 c7 01             	add    edi,0x1
  96b11e:	89 7c 24 70          	mov    DWORD PTR [rsp+0x70],edi
  96b122:	4c 8b 0c 24          	mov    r9,QWORD PTR [rsp]
  96b126:	4c 8b 54 24 08       	mov    r10,QWORD PTR [rsp+0x8]
  96b12b:	44 8b 5c 24 20       	mov    r11d,DWORD PTR [rsp+0x20]
  96b130:	8b 6c 24 48          	mov    ebp,DWORD PTR [rsp+0x48]
  96b134:	44 8b 64 24 68       	mov    r12d,DWORD PTR [rsp+0x68]
  96b139:	44 8b ac 24 88 00 00 	mov    r13d,DWORD PTR [rsp+0x88]
  96b140:	00 
  96b141:	e9 22 fe ff ff       	jmp    0x96af68
  96b146:	e9 00 00 00 00       	jmp    0x96b14b
  96b14b:	44 89 df             	mov    edi,r11d
  96b14e:	48 89 f9             	mov    rcx,rdi
  96b151:	48 8b 44 24 18       	mov    rax,QWORD PTR [rsp+0x18]
  96b156:	e8 f2 3c ff ff       	call   0x95ee4d
  96b15b:	48 89 c7             	mov    rdi,rax
  96b15e:	48 89 7c 24 18       	mov    QWORD PTR [rsp+0x18],rdi
  96b163:	4c 8b 0c 24          	mov    r9,QWORD PTR [rsp]
  96b167:	4c 89 cf             	mov    rdi,r9
  96b16a:	48 89 f8             	mov    rax,rdi
  96b16d:	ba ba 10 00 00       	mov    edx,0x10ba
  96b172:	b9 1c 00 00 00       	mov    ecx,0x1c
  96b177:	be 00 00 00 00       	mov    esi,0x0
  96b17c:	e8 24 11 00 00       	call   0x96c2a5
  96b181:	8b 40 18             	mov    eax,DWORD PTR [rax+0x18]
  96b184:	48 8b 4c 24 18       	mov    rcx,QWORD PTR [rsp+0x18]
  96b189:	e8 02 af 6b ff       	call   0x26090
  96b18e:	48 89 c7             	mov    rdi,rax
  96b191:	48 89 7c 24 78       	mov    QWORD PTR [rsp+0x78],rdi
  96b196:	48 8b 7c 24 78       	mov    rdi,QWORD PTR [rsp+0x78]
  96b19b:	48 89 f8             	mov    rax,rdi
  96b19e:	ba 97 09 00 00       	mov    edx,0x997
  96b1a3:	b9 00 00 00 00       	mov    ecx,0x0
  96b1a8:	be 14 00 00 00       	mov    esi,0x14
  96b1ad:	e8 31 0e 00 00       	call   0x96bfe3
  96b1b2:	85 c0                	test   eax,eax
  96b1b4:	0f 84 2f 00 00 00    	je     0x96b1e9
  96b1ba:	8b 7a 10             	mov    edi,DWORD PTR [rdx+0x10]
  96b1bd:	48 89 f8             	mov    rax,rdi
  96b1c0:	ba 46 23 00 00       	mov    edx,0x2346
  96b1c5:	b9 14 00 00 00       	mov    ecx,0x14
  96b1ca:	be 00 00 00 00       	mov    esi,0x0
  96b1cf:	e8 d1 10 00 00       	call   0x96c2a5
  96b1d4:	8b 44 20 10          	mov    eax,DWORD PTR [rax+riz*1+0x10]
  96b1d8:	89 44 24 38          	mov    DWORD PTR [rsp+0x38],eax
  96b1dc:	48 89 84 24 38 01 00 	mov    QWORD PTR [rsp+0x138],rax
  96b1e3:	00 
  96b1e4:	e9 36 00 00 00       	jmp    0x96b21f
  96b1e9:	48 8b 7c 24 78       	mov    rdi,QWORD PTR [rsp+0x78]
  96b1ee:	48 89 f8             	mov    rax,rdi
  96b1f1:	ba 95 09 00 00       	mov    edx,0x995
  96b1f6:	b9 00 00 00 00       	mov    ecx,0x0
  96b1fb:	e8 5b 0f 00 00       	call   0x96c15b
  96b200:	85 c0                	test   eax,eax
  96b202:	0f 84 12 00 00 00    	je     0x96b21a
  96b208:	bf ff ff ff ff       	mov    edi,0xffffffff
  96b20d:	48 89 bc 24 38 01 00 	mov    QWORD PTR [rsp+0x138],rdi
  96b214:	00 
  96b215:	e9 05 00 00 00       	jmp    0x96b21f
  96b21a:	e9 f6 11 00 00       	jmp    0x96c415
  96b21f:	8b bc 24 38 01 00 00 	mov    edi,DWORD PTR [rsp+0x138]
  96b226:	89 7c 24 40          	mov    DWORD PTR [rsp+0x40],edi
  96b22a:	89 bc 24 a0 00 00 00 	mov    DWORD PTR [rsp+0xa0],edi
  96b231:	4c 8b 0c 24          	mov    r9,QWORD PTR [rsp]
  96b235:	4c 8b 54 24 08       	mov    r10,QWORD PTR [rsp+0x8]
  96b23a:	44 8b 5c 24 20       	mov    r11d,DWORD PTR [rsp+0x20]
  96b23f:	8b 6c 24 48          	mov    ebp,DWORD PTR [rsp+0x48]
  96b243:	44 8b 64 24 68       	mov    r12d,DWORD PTR [rsp+0x68]
  96b248:	44 8b ac 24 88 00 00 	mov    r13d,DWORD PTR [rsp+0x88]
  96b24f:	00 
  96b250:	8b ac 24 a0 00 00 00 	mov    ebp,DWORD PTR [rsp+0xa0]
  96b257:	bf ff ff ff ff       	mov    edi,0xffffffff
  96b25c:	89 bc 24 08 01 00 00 	mov    DWORD PTR [rsp+0x108],edi
  96b263:	89 ef                	mov    edi,ebp
  96b265:	89 bc 24 00 01 00 00 	mov    DWORD PTR [rsp+0x100],edi
  96b26c:	8b bc 24 00 01 00 00 	mov    edi,DWORD PTR [rsp+0x100]
  96b273:	8b b4 24 08 01 00 00 	mov    esi,DWORD PTR [rsp+0x108]
  96b27a:	89 6c 24 48          	mov    DWORD PTR [rsp+0x48],ebp
  96b27e:	39 f7                	cmp    edi,esi
  96b280:	0f 84 72 02 00 00    	je     0x96b4f8
  96b286:	4c 89 cf             	mov    rdi,r9
  96b289:	48 89 f8             	mov    rax,rdi
  96b28c:	ba ba 10 00 00       	mov    edx,0x10ba
  96b291:	b9 14 00 00 00       	mov    ecx,0x14
  96b296:	be 00 00 00 00       	mov    esi,0x0
  96b29b:	e8 05 10 00 00       	call   0x96c2a5
  96b2a0:	8b 40 10             	mov    eax,DWORD PTR [rax+0x10]
  96b2a3:	89 ef                	mov    edi,ebp
  96b2a5:	89 bc 24 18 01 00 00 	mov    DWORD PTR [rsp+0x118],edi
  96b2ac:	48 89 84 24 10 01 00 	mov    QWORD PTR [rsp+0x110],rax
  96b2b3:	00 
  96b2b4:	8b bc 24 18 01 00 00 	mov    edi,DWORD PTR [rsp+0x118]
  96b2bb:	48 89 bc 24 38 01 00 	mov    QWORD PTR [rsp+0x138],rdi
  96b2c2:	00 
  96b2c3:	48 8b bc 24 10 01 00 	mov    rdi,QWORD PTR [rsp+0x110]
  96b2ca:	00 
  96b2cb:	48 89 f8             	mov    rax,rdi
  96b2ce:	ba a0 09 00 00       	mov    edx,0x9a0
  96b2d3:	b9 18 00 00 00       	mov    ecx,0x18
  96b2d8:	be 00 00 00 00       	mov    esi,0x0
  96b2dd:	e8 c3 0f 00 00       	call   0x96c2a5
  96b2e2:	48 89 84 24 20 01 00 	mov    QWORD PTR [rsp+0x120],rax
  96b2e9:	00 
  96b2ea:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  96b2ee:	8b bc 24 38 01 00 00 	mov    edi,DWORD PTR [rsp+0x138]
  96b2f5:	39 c7                	cmp    edi,eax
  96b2f7:	0f 82 05 00 00 00    	jb     0x96b302
  96b2fd:	e9 96 10 00 00       	jmp    0x96c398
  96b302:	48 8b bc 24 20 01 00 	mov    rdi,QWORD PTR [rsp+0x120]
  96b309:	00 
  96b30a:	8b 7f 10             	mov    edi,DWORD PTR [rdi+0x10]
  96b30d:	48 89 f8             	mov    rax,rdi
  96b310:	8b bc 24 18 01 00 00 	mov    edi,DWORD PTR [rsp+0x118]
  96b317:	89 f9                	mov    ecx,edi
  96b319:	ba 3d 23 00 00       	mov    edx,0x233d
  96b31e:	be 00 00 00 00       	mov    esi,0x0
  96b323:	e8 15 09 00 00       	call   0x96bc3d
  96b328:	8b 04 20             	mov    eax,DWORD PTR [rax+riz*1]
  96b32b:	48 89 84 24 38 01 00 	mov    QWORD PTR [rsp+0x138],rax
  96b332:	00 
  96b333:	48 8b bc 24 38 01 00 	mov    rdi,QWORD PTR [rsp+0x138]
  96b33a:	00 
  96b33b:	48 89 bc 24 80 00 00 	mov    QWORD PTR [rsp+0x80],rdi
  96b342:	00 
  96b343:	48 8b bc 24 80 00 00 	mov    rdi,QWORD PTR [rsp+0x80]
  96b34a:	00 
  96b34b:	48 89 f8             	mov    rax,rdi
  96b34e:	ba 9d 10 00 00       	mov    edx,0x109d
  96b353:	b9 00 00 00 00       	mov    ecx,0x0
  96b358:	be 14 00 00 00       	mov    esi,0x14
  96b35d:	e8 81 0c 00 00       	call   0x96bfe3
  96b362:	85 c0                	test   eax,eax
  96b364:	0f 84 af 00 00 00    	je     0x96b419
  96b36a:	8b 7a 10             	mov    edi,DWORD PTR [rdx+0x10]
  96b36d:	48 89 7c 24 50       	mov    QWORD PTR [rsp+0x50],rdi
  96b372:	48 8b bc 24 80 00 00 	mov    rdi,QWORD PTR [rsp+0x80]
  96b379:	00 
  96b37a:	48 89 f8             	mov    rax,rdi
  96b37d:	ba 9d 10 00 00       	mov    edx,0x109d
  96b382:	b9 18 00 00 00       	mov    ecx,0x18
  96b387:	be 00 00 00 00       	mov    esi,0x0
  96b38c:	e8 14 0f 00 00       	call   0x96c2a5
  96b391:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  96b395:	89 44 24 58          	mov    DWORD PTR [rsp+0x58],eax
  96b399:	8b 7c 24 10          	mov    edi,DWORD PTR [rsp+0x10]
  96b39d:	89 bc 24 30 01 00 00 	mov    DWORD PTR [rsp+0x130],edi
  96b3a4:	89 84 24 28 01 00 00 	mov    DWORD PTR [rsp+0x128],eax
  96b3ab:	8b bc 24 28 01 00 00 	mov    edi,DWORD PTR [rsp+0x128]
  96b3b2:	8b b4 24 30 01 00 00 	mov    esi,DWORD PTR [rsp+0x130]
  96b3b9:	39 f7                	cmp    edi,esi
  96b3bb:	0f 85 26 00 00 00    	jne    0x96b3e7
  96b3c1:	4c 89 cf             	mov    rdi,r9
  96b3c4:	4c 89 d6             	mov    rsi,r10
  96b3c7:	48 89 f8             	mov    rax,rdi
  96b3ca:	48 89 f2             	mov    rdx,rsi
  96b3cd:	48 8b 4c 24 50       	mov    rcx,QWORD PTR [rsp+0x50]
  96b3d2:	e8 cd c5 ff ff       	call   0x9679a4
  96b3d7:	48 89 c7             	mov    rdi,rax
  96b3da:	48 89 bc 24 38 01 00 	mov    QWORD PTR [rsp+0x138],rdi
  96b3e1:	00 
  96b3e2:	e9 0d 00 00 00       	jmp    0x96b3f4
  96b3e7:	bf 00 00 00 00       	mov    edi,0x0
  96b3ec:	48 89 bc 24 38 01 00 	mov    QWORD PTR [rsp+0x138],rdi
  96b3f3:	00 
  96b3f4:	8b bc 24 38 01 00 00 	mov    edi,DWORD PTR [rsp+0x138]
  96b3fb:	85 ff                	test   edi,edi
  96b3fd:	0f 84 11 00 00 00    	je     0x96b414
  96b403:	8b 6c 24 48          	mov    ebp,DWORD PTR [rsp+0x48]
  96b407:	48 89 ac 24 38 01 00 	mov    QWORD PTR [rsp+0x138],rbp
  96b40e:	00 
  96b40f:	e9 1a 08 00 00       	jmp    0x96bc2e
  96b414:	e9 00 00 00 00       	jmp    0x96b419
  96b419:	4c 8b 0c 24          	mov    r9,QWORD PTR [rsp]
  96b41d:	4c 89 cf             	mov    rdi,r9
  96b420:	48 89 f8             	mov    rax,rdi
  96b423:	ba ba 10 00 00       	mov    edx,0x10ba
  96b428:	b9 20 00 00 00       	mov    ecx,0x20
  96b42d:	be 00 00 00 00       	mov    esi,0x0
  96b432:	e8 6e 0e 00 00       	call   0x96c2a5
  96b437:	8b 40 1c             	mov    eax,DWORD PTR [rax+0x1c]
  96b43a:	8b 6c 24 48          	mov    ebp,DWORD PTR [rsp+0x48]
  96b43e:	89 ef                	mov    edi,ebp
  96b440:	89 bc 24 e0 00 00 00 	mov    DWORD PTR [rsp+0xe0],edi
  96b447:	48 89 84 24 d8 00 00 	mov    QWORD PTR [rsp+0xd8],rax
  96b44e:	00 
  96b44f:	8b bc 24 e0 00 00 00 	mov    edi,DWORD PTR [rsp+0xe0]
  96b456:	48 89 bc 24 38 01 00 	mov    QWORD PTR [rsp+0x138],rdi
  96b45d:	00 
  96b45e:	48 8b bc 24 d8 00 00 	mov    rdi,QWORD PTR [rsp+0xd8]
  96b465:	00 
  96b466:	48 89 f8             	mov    rax,rdi
  96b469:	ba a0 09 00 00       	mov    edx,0x9a0
  96b46e:	b9 18 00 00 00       	mov    ecx,0x18
  96b473:	be 00 00 00 00       	mov    esi,0x0
  96b478:	e8 28 0e 00 00       	call   0x96c2a5
  96b47d:	48 89 84 24 e8 00 00 	mov    QWORD PTR [rsp+0xe8],rax
  96b484:	00 
  96b485:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  96b489:	8b bc 24 38 01 00 00 	mov    edi,DWORD PTR [rsp+0x138]
  96b490:	39 c7                	cmp    edi,eax
  96b492:	0f 82 05 00 00 00    	jb     0x96b49d
  96b498:	e9 28 0f 00 00       	jmp    0x96c3c5
  96b49d:	48 8b bc 24 e8 00 00 	mov    rdi,QWORD PTR [rsp+0xe8]
  96b4a4:	00 
  96b4a5:	8b 7f 10             	mov    edi,DWORD PTR [rdi+0x10]
  96b4a8:	48 89 f8             	mov    rax,rdi
  96b4ab:	8b bc 24 e0 00 00 00 	mov    edi,DWORD PTR [rsp+0xe0]
  96b4b2:	89 f9                	mov    ecx,edi
  96b4b4:	ba 3a 23 00 00       	mov    edx,0x233a
  96b4b9:	be 00 00 00 00       	mov    esi,0x0
  96b4be:	e8 7a 07 00 00       	call   0x96bc3d
  96b4c3:	8b 04 20             	mov    eax,DWORD PTR [rax+riz*1]
  96b4c6:	48 89 84 24 38 01 00 	mov    QWORD PTR [rsp+0x138],rax
  96b4cd:	00 
  96b4ce:	8b bc 24 38 01 00 00 	mov    edi,DWORD PTR [rsp+0x138]
  96b4d5:	89 bc 24 a0 00 00 00 	mov    DWORD PTR [rsp+0xa0],edi
  96b4dc:	4c 8b 54 24 08       	mov    r10,QWORD PTR [rsp+0x8]
  96b4e1:	44 8b 5c 24 20       	mov    r11d,DWORD PTR [rsp+0x20]
  96b4e6:	44 8b 64 24 68       	mov    r12d,DWORD PTR [rsp+0x68]
  96b4eb:	44 8b ac 24 88 00 00 	mov    r13d,DWORD PTR [rsp+0x88]
  96b4f2:	00 
  96b4f3:	e9 58 fd ff ff       	jmp    0x96b250
  96b4f8:	4c 89 cf             	mov    rdi,r9
  96b4fb:	48 89 f8             	mov    rax,rdi
  96b4fe:	ba ba 10 00 00       	mov    edx,0x10ba
  96b503:	b9 18 00 00 00       	mov    ecx,0x18
  96b508:	be 00 00 00 00       	mov    esi,0x0
  96b50d:	e8 93 0d 00 00       	call   0x96c2a5
  96b512:	8b 40 14             	mov    eax,DWORD PTR [rax+0x14]
  96b515:	48 89 84 24 c0 00 00 	mov    QWORD PTR [rsp+0xc0],rax
  96b51c:	00 
  96b51d:	48 8b bc 24 c0 00 00 	mov    rdi,QWORD PTR [rsp+0xc0]
  96b524:	00 
  96b525:	48 89 f8             	mov    rax,rdi
  96b528:	ba a0 09 00 00       	mov    edx,0x9a0
  96b52d:	b9 18 00 00 00       	mov    ecx,0x18
  96b532:	be 00 00 00 00       	mov    esi,0x0
  96b537:	e8 69 0d 00 00       	call   0x96c2a5
  96b53c:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  96b540:	48 89 84 24 38 01 00 	mov    QWORD PTR [rsp+0x138],rax
  96b547:	00 
  96b548:	8b bc 24 38 01 00 00 	mov    edi,DWORD PTR [rsp+0x138]
  96b54f:	89 7c 24 60          	mov    DWORD PTR [rsp+0x60],edi
  96b553:	41 bd 00 00 00 00    	mov    r13d,0x0
  96b559:	44 89 ac 24 88 00 00 	mov    DWORD PTR [rsp+0x88],r13d
  96b560:	00 
  96b561:	66 0f 1f 84 00 00 00 	nop    WORD PTR [rax+rax*1+0x0]
  96b568:	00 00 
  96b56a:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
  96b570:	45 89 ec             	mov    r12d,r13d
  96b573:	44 89 df             	mov    edi,r11d
  96b576:	89 bc 24 d0 00 00 00 	mov    DWORD PTR [rsp+0xd0],edi
  96b57d:	44 89 e7             	mov    edi,r12d
  96b580:	89 bc 24 c8 00 00 00 	mov    DWORD PTR [rsp+0xc8],edi
  96b587:	8b bc 24 c8 00 00 00 	mov    edi,DWORD PTR [rsp+0xc8]
  96b58e:	8b b4 24 d0 00 00 00 	mov    esi,DWORD PTR [rsp+0xd0]
  96b595:	44 89 64 24 68       	mov    DWORD PTR [rsp+0x68],r12d
  96b59a:	39 f7                	cmp    edi,esi
  96b59c:	0f 83 fe 00 00 00    	jae    0x96b6a0
  96b5a2:	4c 89 cf             	mov    rdi,r9
  96b5a5:	48 89 f8             	mov    rax,rdi
  96b5a8:	ba ba 10 00 00       	mov    edx,0x10ba
  96b5ad:	b9 18 00 00 00       	mov    ecx,0x18
  96b5b2:	be 00 00 00 00       	mov    esi,0x0
  96b5b7:	e8 e9 0c 00 00       	call   0x96c2a5
  96b5bc:	8b 40 14             	mov    eax,DWORD PTR [rax+0x14]
  96b5bf:	44 89 e7             	mov    edi,r12d
  96b5c2:	89 bc 24 e0 00 00 00 	mov    DWORD PTR [rsp+0xe0],edi
  96b5c9:	4c 89 d7             	mov    rdi,r10
  96b5cc:	48 89 bc 24 d8 00 00 	mov    QWORD PTR [rsp+0xd8],rdi
  96b5d3:	00 
  96b5d4:	48 89 84 24 38 01 00 	mov    QWORD PTR [rsp+0x138],rax
  96b5db:	00 
  96b5dc:	8b bc 24 e0 00 00 00 	mov    edi,DWORD PTR [rsp+0xe0]
  96b5e3:	48 89 bc 24 40 01 00 	mov    QWORD PTR [rsp+0x140],rdi
  96b5ea:	00 
  96b5eb:	48 8b bc 24 d8 00 00 	mov    rdi,QWORD PTR [rsp+0xd8]
  96b5f2:	00 
  96b5f3:	48 89 f8             	mov    rax,rdi
  96b5f6:	ba a0 09 00 00       	mov    edx,0x9a0
  96b5fb:	b9 18 00 00 00       	mov    ecx,0x18
  96b600:	be 00 00 00 00       	mov    esi,0x0
  96b605:	e8 9b 0c 00 00       	call   0x96c2a5
  96b60a:	48 89 84 24 e8 00 00 	mov    QWORD PTR [rsp+0xe8],rax
  96b611:	00 
  96b612:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  96b616:	8b bc 24 40 01 00 00 	mov    edi,DWORD PTR [rsp+0x140]
  96b61d:	39 c7                	cmp    edi,eax
  96b61f:	0f 82 05 00 00 00    	jb     0x96b62a
  96b625:	e9 9b 0d 00 00       	jmp    0x96c3c5
  96b62a:	48 8b bc 24 e8 00 00 	mov    rdi,QWORD PTR [rsp+0xe8]
  96b631:	00 
  96b632:	8b 7f 10             	mov    edi,DWORD PTR [rdi+0x10]
  96b635:	48 89 f8             	mov    rax,rdi
  96b638:	8b bc 24 e0 00 00 00 	mov    edi,DWORD PTR [rsp+0xe0]
  96b63f:	89 f9                	mov    ecx,edi
  96b641:	ba 3a 23 00 00       	mov    edx,0x233a
  96b646:	be 00 00 00 00       	mov    esi,0x0
  96b64b:	e8 ed 05 00 00       	call   0x96bc3d
  96b650:	8b 04 20             	mov    eax,DWORD PTR [rax+riz*1]
  96b653:	48 89 84 24 40 01 00 	mov    QWORD PTR [rsp+0x140],rax
  96b65a:	00 
  96b65b:	48 8b bc 24 38 01 00 	mov    rdi,QWORD PTR [rsp+0x138]
  96b662:	00 
  96b663:	8b b4 24 40 01 00 00 	mov    esi,DWORD PTR [rsp+0x140]
  96b66a:	48 89 f8             	mov    rax,rdi
  96b66d:	48 89 f1             	mov    rcx,rsi
  96b670:	e8 7b e8 69 ff       	call   0x9ef0
  96b675:	44 8b 64 24 68       	mov    r12d,DWORD PTR [rsp+0x68]
  96b67a:	45 89 e5             	mov    r13d,r12d
  96b67d:	41 83 c5 01          	add    r13d,0x1
  96b681:	44 89 ac 24 88 00 00 	mov    DWORD PTR [rsp+0x88],r13d
  96b688:	00 
  96b689:	4c 8b 0c 24          	mov    r9,QWORD PTR [rsp]
  96b68d:	4c 8b 54 24 08       	mov    r10,QWORD PTR [rsp+0x8]
  96b692:	44 8b 5c 24 20       	mov    r11d,DWORD PTR [rsp+0x20]
  96b697:	8b 6c 24 48          	mov    ebp,DWORD PTR [rsp+0x48]
  96b69b:	e9 d0 fe ff ff       	jmp    0x96b570
  96b6a0:	e9 00 00 00 00       	jmp    0x96b6a5
  96b6a5:	8b 7c 24 60          	mov    edi,DWORD PTR [rsp+0x60]
  96b6a9:	89 bc 24 90 00 00 00 	mov    DWORD PTR [rsp+0x90],edi
  96b6b0:	4c 89 d7             	mov    rdi,r10
  96b6b3:	48 89 bc 24 c0 00 00 	mov    QWORD PTR [rsp+0xc0],rdi
  96b6ba:	00 
  96b6bb:	4c 89 8c 24 38 01 00 	mov    QWORD PTR [rsp+0x138],r9
  96b6c2:	00 
  96b6c3:	48 8b bc 24 c0 00 00 	mov    rdi,QWORD PTR [rsp+0xc0]
  96b6ca:	00 
  96b6cb:	48 89 f8             	mov    rax,rdi
  96b6ce:	ba a0 09 00 00       	mov    edx,0x9a0
  96b6d3:	b9 18 00 00 00       	mov    ecx,0x18
  96b6d8:	be 00 00 00 00       	mov    esi,0x0
  96b6dd:	e8 c3 0b 00 00       	call   0x96c2a5
  96b6e2:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  96b6e6:	48 89 84 24 40 01 00 	mov    QWORD PTR [rsp+0x140],rax
  96b6ed:	00 
  96b6ee:	8b bc 24 40 01 00 00 	mov    edi,DWORD PTR [rsp+0x140]
  96b6f5:	89 bc 24 98 00 00 00 	mov    DWORD PTR [rsp+0x98],edi
  96b6fc:	8b bc 24 90 00 00 00 	mov    edi,DWORD PTR [rsp+0x90]
  96b703:	48 89 bc 24 40 01 00 	mov    QWORD PTR [rsp+0x140],rdi
  96b70a:	00 
  96b70b:	8b bc 24 98 00 00 00 	mov    edi,DWORD PTR [rsp+0x98]
  96b712:	48 89 bc 24 48 01 00 	mov    QWORD PTR [rsp+0x148],rdi
  96b719:	00 
  96b71a:	bf 3d 0d 00 00       	mov    edi,0xd3d
  96b71f:	48 89 bc 24 50 01 00 	mov    QWORD PTR [rsp+0x150],rdi
  96b726:	00 
  96b727:	41 50                	push   r8
  96b729:	41 51                	push   r9
  96b72b:	41 52                	push   r10
  96b72d:	41 53                	push   r11
  96b72f:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  96b736:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  96b73a:	41 8b 92 f4 34 00 00 	mov    edx,DWORD PTR [r10+0x34f4]
  96b741:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  96b745:	41 83 b8 a0 00 00 00 	cmp    DWORD PTR [r8+0xa0],0x18
  96b74c:	18 
  96b74d:	0f 86 43 01 00 00    	jbe    0x96b896
  96b753:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  96b75a:	4d 85 d2             	test   r10,r10
  96b75d:	0f 84 33 01 00 00    	je     0x96b896
  96b763:	41 8b 4a 04          	mov    ecx,DWORD PTR [r10+0x4]
  96b767:	41 8b 42 08          	mov    eax,DWORD PTR [r10+0x8]
  96b76b:	81 f8 00 02 00 00    	cmp    eax,0x200
  96b771:	0f 87 1f 01 00 00    	ja     0x96b896
  96b777:	39 c1                	cmp    ecx,eax
  96b779:	0f 83 17 01 00 00    	jae    0x96b896
  96b77f:	49 8d 44 8a 20       	lea    rax,[r10+rcx*4+0x20]
  96b784:	8b 30                	mov    esi,DWORD PTR [rax]
  96b786:	89 f0                	mov    eax,esi
  96b788:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  96b78c:	48 c1 e0 04          	shl    rax,0x4
  96b790:	49 01 c1             	add    r9,rax
  96b793:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  96b79a:	48 85 c0             	test   rax,rax
  96b79d:	0f 84 f3 00 00 00    	je     0x96b896
  96b7a3:	8b 08                	mov    ecx,DWORD PTR [rax]
  96b7a5:	83 c1 07             	add    ecx,0x7
  96b7a8:	83 e1 f8             	and    ecx,0xfffffff8
  96b7ab:	41 8b 40 7c          	mov    eax,DWORD PTR [r8+0x7c]
  96b7af:	39 c1                	cmp    ecx,eax
  96b7b1:	0f 87 df 00 00 00    	ja     0x96b896
  96b7b7:	29 c8                	sub    eax,ecx
  96b7b9:	83 f8 18             	cmp    eax,0x18
  96b7bc:	0f 82 d4 00 00 00    	jb     0x96b896
  96b7c2:	4d 8b 58 28          	mov    r11,QWORD PTR [r8+0x28]
  96b7c6:	4d 85 db             	test   r11,r11
  96b7c9:	0f 84 c7 00 00 00    	je     0x96b896
  96b7cf:	49 01 cb             	add    r11,rcx
  96b7d2:	49 8b 80 98 00 00 00 	mov    rax,QWORD PTR [r8+0x98]
  96b7d9:	48 85 c0             	test   rax,rax
  96b7dc:	0f 84 b4 00 00 00    	je     0x96b896
  96b7e2:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  96b7e9:	41 8b 52 04          	mov    edx,DWORD PTR [r10+0x4]
  96b7ed:	48 8b 83 e8 fe ff ff 	mov    rax,QWORD PTR [rbx-0x118]
  96b7f4:	48 8b 40 10          	mov    rax,QWORD PTR [rax+0x10]
  96b7f8:	8b 80 f4 34 00 00    	mov    eax,DWORD PTR [rax+0x34f4]
  96b7fe:	41 89 03             	mov    DWORD PTR [r11],eax
  96b801:	41 c7 43 04 18 00 00 	mov    DWORD PTR [r11+0x4],0x18
  96b808:	00 
  96b809:	41 c7 43 08 00 00 00 	mov    DWORD PTR [r11+0x8],0x0
  96b810:	00 
  96b811:	41 c7 43 0c 01 00 00 	mov    DWORD PTR [r11+0xc],0x1
  96b818:	00 
  96b819:	8b 84 24 60 01 00 00 	mov    eax,DWORD PTR [rsp+0x160]
  96b820:	41 89 43 10          	mov    DWORD PTR [r11+0x10],eax
  96b824:	8b 84 24 68 01 00 00 	mov    eax,DWORD PTR [rsp+0x168]
  96b82b:	41 89 43 14          	mov    DWORD PTR [r11+0x14],eax
  96b82f:	41 89 09             	mov    DWORD PTR [r9],ecx
  96b832:	41 c7 41 04 18 00 00 	mov    DWORD PTR [r9+0x4],0x18
  96b839:	00 
  96b83a:	41 c7 41 08 00 00 00 	mov    DWORD PTR [r9+0x8],0x0
  96b841:	00 
  96b842:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  96b849:	41 89 ca             	mov    r10d,ecx
  96b84c:	41 83 c2 18          	add    r10d,0x18
  96b850:	44 89 10             	mov    DWORD PTR [rax],r10d
  96b853:	41 c7 41 0c 00 00 01 	mov    DWORD PTR [r9+0xc],0x10000
  96b85a:	00 
  96b85b:	83 c2 01             	add    edx,0x1
  96b85e:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  96b865:	41 89 52 04          	mov    DWORD PTR [r10+0x4],edx
  96b869:	41 83 7a 18 00       	cmp    DWORD PTR [r10+0x18],0x0
  96b86e:	0f 84 11 00 00 00    	je     0x96b885
  96b874:	4d 8b 90 98 00 00 00 	mov    r10,QWORD PTR [r8+0x98]
  96b87b:	49 8b 02             	mov    rax,QWORD PTR [r10]
  96b87e:	48 83 c0 01          	add    rax,0x1
  96b882:	49 89 02             	mov    QWORD PTR [r10],rax
  96b885:	89 f0                	mov    eax,esi
  96b887:	d1 e0                	shl    eax,1
  96b889:	48 89 84 24 60 01 00 	mov    QWORD PTR [rsp+0x160],rax
  96b890:	00 
  96b891:	e9 05 00 00 00       	jmp    0x96b89b
  96b896:	b8 00 00 00 00       	mov    eax,0x0
  96b89b:	85 c0                	test   eax,eax
  96b89d:	41 5b                	pop    r11
  96b89f:	41 5a                	pop    r10
  96b8a1:	41 59                	pop    r9
  96b8a3:	41 58                	pop    r8
  96b8a5:	0f 85 6b 00 00 00    	jne    0x96b916
  96b8ab:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  96b8af:	8b 84 24 40 01 00 00 	mov    eax,DWORD PTR [rsp+0x140]
  96b8b6:	49 89 40 48          	mov    QWORD PTR [r8+0x48],rax
  96b8ba:	8b 84 24 48 01 00 00 	mov    eax,DWORD PTR [rsp+0x148]
  96b8c1:	49 89 40 50          	mov    QWORD PTR [r8+0x50],rax
  96b8c5:	8b 84 24 50 01 00 00 	mov    eax,DWORD PTR [rsp+0x150]
  96b8cc:	49 89 40 58          	mov    QWORD PTR [r8+0x58],rax
  96b8d0:	41 c7 40 40 0b 5e 25 	mov    DWORD PTR [r8+0x40],0x40255e0b
  96b8d7:	40 
  96b8d8:	41 c7 40 44 03 00 01 	mov    DWORD PTR [r8+0x44],0x10003
  96b8df:	00 
  96b8e0:	41 ff 50 38          	call   QWORD PTR [r8+0x38]
  96b8e4:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  96b8e8:	49 8b 80 48 02 00 00 	mov    rax,QWORD PTR [r8+0x248]
  96b8ef:	48 89 84 24 40 01 00 	mov    QWORD PTR [rsp+0x140],rax
  96b8f6:	00 
  96b8f7:	4c 8b 0c 24          	mov    r9,QWORD PTR [rsp]
  96b8fb:	4c 8b 54 24 08       	mov    r10,QWORD PTR [rsp+0x8]
  96b900:	44 8b 5c 24 20       	mov    r11d,DWORD PTR [rsp+0x20]
  96b905:	8b 6c 24 48          	mov    ebp,DWORD PTR [rsp+0x48]
  96b909:	44 8b 64 24 68       	mov    r12d,DWORD PTR [rsp+0x68]
  96b90e:	44 8b ac 24 88 00 00 	mov    r13d,DWORD PTR [rsp+0x88]
  96b915:	00 
  96b916:	48 8b bc 24 40 01 00 	mov    rdi,QWORD PTR [rsp+0x140]
  96b91d:	00 
  96b91e:	48 89 f8             	mov    rax,rdi
  96b921:	ba 3d 0d 00 00       	mov    edx,0xd3d
  96b926:	b9 00 00 00 00       	mov    ecx,0x0
  96b92b:	be 00 00 00 00       	mov    esi,0x0
  96b930:	e8 5c 05 00 00       	call   0x96be91
  96b935:	48 89 84 24 40 01 00 	mov    QWORD PTR [rsp+0x140],rax
  96b93c:	00 
  96b93d:	8b 7c 24 10          	mov    edi,DWORD PTR [rsp+0x10]
  96b941:	48 89 bc 24 48 01 00 	mov    QWORD PTR [rsp+0x148],rdi
  96b948:	00 
  96b949:	bf 9d 10 00 00       	mov    edi,0x109d
  96b94e:	48 89 bc 24 50 01 00 	mov    QWORD PTR [rsp+0x150],rdi
  96b955:	00 
  96b956:	41 54                	push   r12
  96b958:	41 50                	push   r8
  96b95a:	41 51                	push   r9
  96b95c:	41 52                	push   r10
  96b95e:	41 53                	push   r11
  96b960:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  96b967:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  96b96b:	41 8b 92 74 42 00 00 	mov    edx,DWORD PTR [r10+0x4274]
  96b972:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  96b976:	41 83 b8 a0 00 00 00 	cmp    DWORD PTR [r8+0xa0],0x18
  96b97d:	18 
  96b97e:	0f 86 f3 01 00 00    	jbe    0x96bb77
  96b984:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  96b98b:	4d 85 d2             	test   r10,r10
  96b98e:	0f 84 e3 01 00 00    	je     0x96bb77
  96b994:	41 8b 4a 04          	mov    ecx,DWORD PTR [r10+0x4]
  96b998:	41 8b 42 08          	mov    eax,DWORD PTR [r10+0x8]
  96b99c:	81 f8 00 02 00 00    	cmp    eax,0x200
  96b9a2:	0f 87 cf 01 00 00    	ja     0x96bb77
  96b9a8:	39 c1                	cmp    ecx,eax
  96b9aa:	0f 83 c7 01 00 00    	jae    0x96bb77
  96b9b0:	49 8d 44 8a 20       	lea    rax,[r10+rcx*4+0x20]
  96b9b5:	8b 30                	mov    esi,DWORD PTR [rax]
  96b9b7:	89 f0                	mov    eax,esi
  96b9b9:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  96b9bd:	48 c1 e0 04          	shl    rax,0x4
  96b9c1:	49 01 c1             	add    r9,rax
  96b9c4:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  96b9cb:	48 85 c0             	test   rax,rax
  96b9ce:	0f 84 a3 01 00 00    	je     0x96bb77
  96b9d4:	8b 08                	mov    ecx,DWORD PTR [rax]
  96b9d6:	83 c1 07             	add    ecx,0x7
  96b9d9:	83 e1 f8             	and    ecx,0xfffffff8
  96b9dc:	41 8b 40 7c          	mov    eax,DWORD PTR [r8+0x7c]
  96b9e0:	39 c1                	cmp    ecx,eax
  96b9e2:	0f 87 8f 01 00 00    	ja     0x96bb77
  96b9e8:	29 c8                	sub    eax,ecx
  96b9ea:	83 f8 18             	cmp    eax,0x18
  96b9ed:	0f 82 84 01 00 00    	jb     0x96bb77
  96b9f3:	4d 8b 58 28          	mov    r11,QWORD PTR [r8+0x28]
  96b9f7:	4d 85 db             	test   r11,r11
  96b9fa:	0f 84 77 01 00 00    	je     0x96bb77
  96ba00:	49 01 cb             	add    r11,rcx
  96ba03:	49 8b 80 98 00 00 00 	mov    rax,QWORD PTR [r8+0x98]
  96ba0a:	48 85 c0             	test   rax,rax
  96ba0d:	0f 84 64 01 00 00    	je     0x96bb77
  96ba13:	41 89 cc             	mov    r12d,ecx
  96ba16:	8b 84 24 68 01 00 00 	mov    eax,DWORD PTR [rsp+0x168]
  96ba1d:	85 c0                	test   eax,eax
  96ba1f:	0f 84 52 01 00 00    	je     0x96bb77
  96ba25:	89 c2                	mov    edx,eax
  96ba27:	83 e2 01             	and    edx,0x1
  96ba2a:	85 d2                	test   edx,edx
  96ba2c:	0f 85 45 01 00 00    	jne    0x96bb77
  96ba32:	d1 e8                	shr    eax,1
  96ba34:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  96ba38:	0f 83 39 01 00 00    	jae    0x96bb77
  96ba3e:	4d 8b 50 08          	mov    r10,QWORD PTR [r8+0x8]
  96ba42:	48 c1 e0 04          	shl    rax,0x4
  96ba46:	49 01 c2             	add    r10,rax
  96ba49:	41 8b 42 0c          	mov    eax,DWORD PTR [r10+0xc]
  96ba4d:	c1 e8 10             	shr    eax,0x10
  96ba50:	81 e0 ff 00 00 00    	and    eax,0xff
  96ba56:	85 c0                	test   eax,eax
  96ba58:	0f 84 19 01 00 00    	je     0x96bb77
  96ba5e:	83 f8 04             	cmp    eax,0x4
  96ba61:	0f 87 10 01 00 00    	ja     0x96bb77
  96ba67:	48 6b c0 10          	imul   rax,rax,0x10
  96ba6b:	4c 01 c0             	add    rax,r8
  96ba6e:	8b 50 20             	mov    edx,DWORD PTR [rax+0x20]
  96ba71:	41 8b 0a             	mov    ecx,DWORD PTR [r10]
  96ba74:	39 d1                	cmp    ecx,edx
  96ba76:	0f 83 fb 00 00 00    	jae    0x96bb77
  96ba7c:	29 ca                	sub    edx,ecx
  96ba7e:	45 8b 52 04          	mov    r10d,DWORD PTR [r10+0x4]
  96ba82:	41 39 d2             	cmp    r10d,edx
  96ba85:	0f 87 ec 00 00 00    	ja     0x96bb77
  96ba8b:	41 83 fa 10          	cmp    r10d,0x10
  96ba8f:	0f 82 e2 00 00 00    	jb     0x96bb77
  96ba95:	48 8b 40 18          	mov    rax,QWORD PTR [rax+0x18]
  96ba99:	48 85 c0             	test   rax,rax
  96ba9c:	0f 84 d5 00 00 00    	je     0x96bb77
  96baa2:	48 01 c8             	add    rax,rcx
  96baa5:	8b 00                	mov    eax,DWORD PTR [rax]
  96baa7:	48 8b 93 e8 fe ff ff 	mov    rdx,QWORD PTR [rbx-0x118]
  96baae:	48 8b 52 10          	mov    rdx,QWORD PTR [rdx+0x10]
  96bab2:	8b 92 f4 34 00 00    	mov    edx,DWORD PTR [rdx+0x34f4]
  96bab8:	39 d0                	cmp    eax,edx
  96baba:	0f 85 b7 00 00 00    	jne    0x96bb77
  96bac0:	44 89 e1             	mov    ecx,r12d
  96bac3:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  96baca:	41 8b 52 04          	mov    edx,DWORD PTR [r10+0x4]
  96bace:	48 8b 83 e8 fe ff ff 	mov    rax,QWORD PTR [rbx-0x118]
  96bad5:	48 8b 40 10          	mov    rax,QWORD PTR [rax+0x10]
  96bad9:	8b 80 74 42 00 00    	mov    eax,DWORD PTR [rax+0x4274]
  96badf:	41 89 03             	mov    DWORD PTR [r11],eax
  96bae2:	41 c7 43 04 18 00 00 	mov    DWORD PTR [r11+0x4],0x18
  96bae9:	00 
  96baea:	41 c7 43 08 00 00 00 	mov    DWORD PTR [r11+0x8],0x0
  96baf1:	00 
  96baf2:	41 c7 43 0c 00 00 00 	mov    DWORD PTR [r11+0xc],0x0
  96baf9:	00 
  96bafa:	8b 84 24 68 01 00 00 	mov    eax,DWORD PTR [rsp+0x168]
  96bb01:	41 89 43 10          	mov    DWORD PTR [r11+0x10],eax
  96bb05:	8b 84 24 70 01 00 00 	mov    eax,DWORD PTR [rsp+0x170]
  96bb0c:	41 89 43 14          	mov    DWORD PTR [r11+0x14],eax
  96bb10:	41 89 09             	mov    DWORD PTR [r9],ecx
  96bb13:	41 c7 41 04 18 00 00 	mov    DWORD PTR [r9+0x4],0x18
  96bb1a:	00 
  96bb1b:	41 c7 41 08 00 00 00 	mov    DWORD PTR [r9+0x8],0x0
  96bb22:	00 
  96bb23:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  96bb2a:	41 89 ca             	mov    r10d,ecx
  96bb2d:	41 83 c2 18          	add    r10d,0x18
  96bb31:	44 89 10             	mov    DWORD PTR [rax],r10d
  96bb34:	41 c7 41 0c 00 00 01 	mov    DWORD PTR [r9+0xc],0x10000
  96bb3b:	00 
  96bb3c:	83 c2 01             	add    edx,0x1
  96bb3f:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  96bb46:	41 89 52 04          	mov    DWORD PTR [r10+0x4],edx
  96bb4a:	41 83 7a 18 00       	cmp    DWORD PTR [r10+0x18],0x0
  96bb4f:	0f 84 11 00 00 00    	je     0x96bb66
  96bb55:	4d 8b 90 98 00 00 00 	mov    r10,QWORD PTR [r8+0x98]
  96bb5c:	49 8b 02             	mov    rax,QWORD PTR [r10]
  96bb5f:	48 83 c0 01          	add    rax,0x1
  96bb63:	49 89 02             	mov    QWORD PTR [r10],rax
  96bb66:	89 f0                	mov    eax,esi
  96bb68:	d1 e0                	shl    eax,1
  96bb6a:	48 89 84 24 68 01 00 	mov    QWORD PTR [rsp+0x168],rax
  96bb71:	00 
  96bb72:	e9 05 00 00 00       	jmp    0x96bb7c
  96bb77:	b8 00 00 00 00       	mov    eax,0x0
  96bb7c:	85 c0                	test   eax,eax
  96bb7e:	41 5b                	pop    r11
  96bb80:	41 5a                	pop    r10
  96bb82:	41 59                	pop    r9
  96bb84:	41 58                	pop    r8
  96bb86:	41 5c                	pop    r12
  96bb88:	0f 85 6c 00 00 00    	jne    0x96bbfa
  96bb8e:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  96bb92:	48 8b 84 24 40 01 00 	mov    rax,QWORD PTR [rsp+0x140]
  96bb99:	00 
  96bb9a:	49 89 40 48          	mov    QWORD PTR [r8+0x48],rax
  96bb9e:	8b 84 24 48 01 00 00 	mov    eax,DWORD PTR [rsp+0x148]
  96bba5:	49 89 40 50          	mov    QWORD PTR [r8+0x50],rax
  96bba9:	8b 84 24 50 01 00 00 	mov    eax,DWORD PTR [rsp+0x150]
  96bbb0:	49 89 40 58          	mov    QWORD PTR [r8+0x58],rax
  96bbb4:	41 c7 40 40 0b 5f 25 	mov    DWORD PTR [r8+0x40],0x40255f0b
  96bbbb:	40 
  96bbbc:	41 c7 40 44 03 00 01 	mov    DWORD PTR [r8+0x44],0x10003
  96bbc3:	00 
  96bbc4:	41 ff 50 38          	call   QWORD PTR [r8+0x38]
  96bbc8:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  96bbcc:	49 8b 80 48 02 00 00 	mov    rax,QWORD PTR [r8+0x248]
  96bbd3:	48 89 84 24 40 01 00 	mov    QWORD PTR [rsp+0x140],rax
  96bbda:	00 
  96bbdb:	4c 8b 0c 24          	mov    r9,QWORD PTR [rsp]
  96bbdf:	4c 8b 54 24 08       	mov    r10,QWORD PTR [rsp+0x8]
  96bbe4:	44 8b 5c 24 20       	mov    r11d,DWORD PTR [rsp+0x20]
  96bbe9:	8b 6c 24 48          	mov    ebp,DWORD PTR [rsp+0x48]
  96bbed:	44 8b 64 24 68       	mov    r12d,DWORD PTR [rsp+0x68]
  96bbf2:	44 8b ac 24 88 00 00 	mov    r13d,DWORD PTR [rsp+0x88]
  96bbf9:	00 
  96bbfa:	48 8b bc 24 38 01 00 	mov    rdi,QWORD PTR [rsp+0x138]
  96bc01:	00 
  96bc02:	48 8b b4 24 40 01 00 	mov    rsi,QWORD PTR [rsp+0x140]
  96bc09:	00 
  96bc0a:	48 89 f8             	mov    rax,rdi
  96bc0d:	48 89 f1             	mov    rcx,rsi
  96bc10:	48 8b 54 24 18       	mov    rdx,QWORD PTR [rsp+0x18]
  96bc15:	e8 ea 93 ff ff       	call   0x965004
  96bc1a:	48 89 c7             	mov    rdi,rax
  96bc1d:	48 89 bc 24 38 01 00 	mov    QWORD PTR [rsp+0x138],rdi
  96bc24:	00 
  96bc25:	8b 6c 24 48          	mov    ebp,DWORD PTR [rsp+0x48]
  96bc29:	e9 00 00 00 00       	jmp    0x96bc2e
  96bc2e:	8b 84 24 38 01 00 00 	mov    eax,DWORD PTR [rsp+0x138]
  96bc35:	48 81 c4 68 01 00 00 	add    rsp,0x168
  96bc3c:	c3                   	ret
  96bc3d:	41 51                	push   r9
  96bc3f:	41 52                	push   r10
  96bc41:	41 53                	push   r11
  96bc43:	49 89 c2             	mov    r10,rax
  96bc46:	49 c1 ea 20          	shr    r10,0x20
  96bc4a:	4d 85 d2             	test   r10,r10
  96bc4d:	0f 85 f3 00 00 00    	jne    0x96bd46
  96bc53:	85 c0                	test   eax,eax
  96bc55:	0f 85 0d 00 00 00    	jne    0x96bc68
  96bc5b:	85 f6                	test   esi,esi
  96bc5d:	0f 84 e3 00 00 00    	je     0x96bd46
  96bc63:	e9 e9 00 00 00       	jmp    0x96bd51
  96bc68:	89 ce                	mov    esi,ecx
  96bc6a:	41 89 c2             	mov    r10d,eax
  96bc6d:	41 83 e2 01          	and    r10d,0x1
  96bc71:	45 85 d2             	test   r10d,r10d
  96bc74:	0f 85 cc 00 00 00    	jne    0x96bd46
  96bc7a:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  96bc81:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  96bc85:	48 6b d2 04          	imul   rdx,rdx,0x4
  96bc89:	41 8b 14 12          	mov    edx,DWORD PTR [r10+rdx*1]
  96bc8d:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  96bc91:	d1 e8                	shr    eax,1
  96bc93:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  96bc97:	0f 83 a9 00 00 00    	jae    0x96bd46
  96bc9d:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  96bca1:	48 c1 e0 04          	shl    rax,0x4
  96bca5:	49 01 c1             	add    r9,rax
  96bca8:	45 0f b6 54 21 0e    	movzx  r10d,BYTE PTR [r9+riz*1+0xe]
  96bcae:	45 85 d2             	test   r10d,r10d
  96bcb1:	0f 84 8f 00 00 00    	je     0x96bd46
  96bcb7:	41 83 fa 04          	cmp    r10d,0x4
  96bcbb:	0f 87 85 00 00 00    	ja     0x96bd46
  96bcc1:	4d 6b d2 10          	imul   r10,r10,0x10
  96bcc5:	4d 8d 40 18          	lea    r8,[r8+0x18]
  96bcc9:	4d 01 d0             	add    r8,r10
  96bccc:	4d 8b 18             	mov    r11,QWORD PTR [r8]
  96bccf:	45 8b 40 08          	mov    r8d,DWORD PTR [r8+0x8]
  96bcd3:	41 8b 01             	mov    eax,DWORD PTR [r9]
  96bcd6:	44 39 c0             	cmp    eax,r8d
  96bcd9:	0f 87 67 00 00 00    	ja     0x96bd46
  96bcdf:	41 29 c0             	sub    r8d,eax
  96bce2:	41 8b 49 04          	mov    ecx,DWORD PTR [r9+0x4]
  96bce6:	44 39 c1             	cmp    ecx,r8d
  96bce9:	0f 87 57 00 00 00    	ja     0x96bd46
  96bcef:	83 f9 10             	cmp    ecx,0x10
  96bcf2:	0f 82 4e 00 00 00    	jb     0x96bd46
  96bcf8:	49 01 c3             	add    r11,rax
  96bcfb:	41 8b 0b             	mov    ecx,DWORD PTR [r11]
  96bcfe:	39 d1                	cmp    ecx,edx
  96bd00:	0f 85 40 00 00 00    	jne    0x96bd46
  96bd06:	45 8b 53 08          	mov    r10d,DWORD PTR [r11+0x8]
  96bd0a:	44 39 d6             	cmp    esi,r10d
  96bd0d:	0f 83 49 00 00 00    	jae    0x96bd5c
  96bd13:	48 6b f6 04          	imul   rsi,rsi,0x4
  96bd17:	45 8b 53 04          	mov    r10d,DWORD PTR [r11+0x4]
  96bd1b:	49 89 f0             	mov    r8,rsi
  96bd1e:	49 83 c0 14          	add    r8,0x14
  96bd22:	41 8b 51 04          	mov    edx,DWORD PTR [r9+0x4]
  96bd26:	49 39 d0             	cmp    r8,rdx
  96bd29:	0f 87 17 00 00 00    	ja     0x96bd46
  96bd2f:	4d 39 d0             	cmp    r8,r10
  96bd32:	0f 87 0e 00 00 00    	ja     0x96bd46
  96bd38:	49 8d 43 10          	lea    rax,[r11+0x10]
  96bd3c:	48 01 f0             	add    rax,rsi
  96bd3f:	41 5b                	pop    r11
  96bd41:	41 5a                	pop    r10
  96bd43:	41 59                	pop    r9
  96bd45:	c3                   	ret
  96bd46:	41 5b                	pop    r11
  96bd48:	41 5a                	pop    r10
  96bd4a:	41 59                	pop    r9
  96bd4c:	e9 6e 07 00 00       	jmp    0x96c4bf
  96bd51:	41 5b                	pop    r11
  96bd53:	41 5a                	pop    r10
  96bd55:	41 59                	pop    r9
  96bd57:	e9 3b 07 00 00       	jmp    0x96c497
  96bd5c:	41 5b                	pop    r11
  96bd5e:	41 5a                	pop    r10
  96bd60:	41 59                	pop    r9
  96bd62:	e9 db 06 00 00       	jmp    0x96c442
  96bd67:	41 51                	push   r9
  96bd69:	41 52                	push   r10
  96bd6b:	41 53                	push   r11
  96bd6d:	49 89 c2             	mov    r10,rax
  96bd70:	49 c1 ea 20          	shr    r10,0x20
  96bd74:	4d 85 d2             	test   r10,r10
  96bd77:	0f 85 f3 00 00 00    	jne    0x96be70
  96bd7d:	85 c0                	test   eax,eax
  96bd7f:	0f 85 0d 00 00 00    	jne    0x96bd92
  96bd85:	85 f6                	test   esi,esi
  96bd87:	0f 84 e3 00 00 00    	je     0x96be70
  96bd8d:	e9 e9 00 00 00       	jmp    0x96be7b
  96bd92:	89 ce                	mov    esi,ecx
  96bd94:	41 89 c2             	mov    r10d,eax
  96bd97:	41 83 e2 01          	and    r10d,0x1
  96bd9b:	45 85 d2             	test   r10d,r10d
  96bd9e:	0f 85 cc 00 00 00    	jne    0x96be70
  96bda4:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  96bdab:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  96bdaf:	48 6b d2 04          	imul   rdx,rdx,0x4
  96bdb3:	41 8b 14 12          	mov    edx,DWORD PTR [r10+rdx*1]
  96bdb7:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  96bdbb:	d1 e8                	shr    eax,1
  96bdbd:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  96bdc1:	0f 83 a9 00 00 00    	jae    0x96be70
  96bdc7:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  96bdcb:	48 c1 e0 04          	shl    rax,0x4
  96bdcf:	49 01 c1             	add    r9,rax
  96bdd2:	45 0f b6 54 21 0e    	movzx  r10d,BYTE PTR [r9+riz*1+0xe]
  96bdd8:	45 85 d2             	test   r10d,r10d
  96bddb:	0f 84 8f 00 00 00    	je     0x96be70
  96bde1:	41 83 fa 04          	cmp    r10d,0x4
  96bde5:	0f 87 85 00 00 00    	ja     0x96be70
  96bdeb:	4d 6b d2 10          	imul   r10,r10,0x10
  96bdef:	4d 8d 40 18          	lea    r8,[r8+0x18]
  96bdf3:	4d 01 d0             	add    r8,r10
  96bdf6:	4d 8b 18             	mov    r11,QWORD PTR [r8]
  96bdf9:	45 8b 40 08          	mov    r8d,DWORD PTR [r8+0x8]
  96bdfd:	41 8b 01             	mov    eax,DWORD PTR [r9]
  96be00:	44 39 c0             	cmp    eax,r8d
  96be03:	0f 87 67 00 00 00    	ja     0x96be70
  96be09:	41 29 c0             	sub    r8d,eax
  96be0c:	41 8b 49 04          	mov    ecx,DWORD PTR [r9+0x4]
  96be10:	44 39 c1             	cmp    ecx,r8d
  96be13:	0f 87 57 00 00 00    	ja     0x96be70
  96be19:	83 f9 10             	cmp    ecx,0x10
  96be1c:	0f 82 4e 00 00 00    	jb     0x96be70
  96be22:	49 01 c3             	add    r11,rax
  96be25:	41 8b 0b             	mov    ecx,DWORD PTR [r11]
  96be28:	39 d1                	cmp    ecx,edx
  96be2a:	0f 85 40 00 00 00    	jne    0x96be70
  96be30:	45 8b 53 08          	mov    r10d,DWORD PTR [r11+0x8]
  96be34:	44 39 d6             	cmp    esi,r10d
  96be37:	0f 83 49 00 00 00    	jae    0x96be86
  96be3d:	48 6b f6 08          	imul   rsi,rsi,0x8
  96be41:	45 8b 53 04          	mov    r10d,DWORD PTR [r11+0x4]
  96be45:	49 89 f0             	mov    r8,rsi
  96be48:	49 83 c0 18          	add    r8,0x18
  96be4c:	41 8b 51 04          	mov    edx,DWORD PTR [r9+0x4]
  96be50:	49 39 d0             	cmp    r8,rdx
  96be53:	0f 87 17 00 00 00    	ja     0x96be70
  96be59:	4d 39 d0             	cmp    r8,r10
  96be5c:	0f 87 0e 00 00 00    	ja     0x96be70
  96be62:	49 8d 43 10          	lea    rax,[r11+0x10]
  96be66:	48 01 f0             	add    rax,rsi
  96be69:	41 5b                	pop    r11
  96be6b:	41 5a                	pop    r10
  96be6d:	41 59                	pop    r9
  96be6f:	c3                   	ret
  96be70:	41 5b                	pop    r11
  96be72:	41 5a                	pop    r10
  96be74:	41 59                	pop    r9
  96be76:	e9 44 06 00 00       	jmp    0x96c4bf
  96be7b:	41 5b                	pop    r11
  96be7d:	41 5a                	pop    r10
  96be7f:	41 59                	pop    r9
  96be81:	e9 11 06 00 00       	jmp    0x96c497
  96be86:	41 5b                	pop    r11
  96be88:	41 5a                	pop    r10
  96be8a:	41 59                	pop    r9
  96be8c:	e9 b1 05 00 00       	jmp    0x96c442
  96be91:	41 51                	push   r9
  96be93:	41 52                	push   r10
  96be95:	41 53                	push   r11
  96be97:	49 89 c2             	mov    r10,rax
  96be9a:	49 c1 ea 20          	shr    r10,0x20
  96be9e:	4d 85 d2             	test   r10,r10
  96bea1:	0f 85 31 01 00 00    	jne    0x96bfd8
  96bea7:	85 c0                	test   eax,eax
  96bea9:	0f 85 0d 00 00 00    	jne    0x96bebc
  96beaf:	85 c9                	test   ecx,ecx
  96beb1:	0f 84 21 01 00 00    	je     0x96bfd8
  96beb7:	e9 15 01 00 00       	jmp    0x96bfd1
  96bebc:	89 c7                	mov    edi,eax
  96bebe:	41 89 c2             	mov    r10d,eax
  96bec1:	41 83 e2 01          	and    r10d,0x1
  96bec5:	45 85 d2             	test   r10d,r10d
  96bec8:	0f 85 0a 01 00 00    	jne    0x96bfd8
  96bece:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  96bed5:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  96bed9:	48 6b d2 04          	imul   rdx,rdx,0x4
  96bedd:	41 8b 14 12          	mov    edx,DWORD PTR [r10+rdx*1]
  96bee1:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  96bee5:	d1 e8                	shr    eax,1
  96bee7:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  96beeb:	0f 83 e7 00 00 00    	jae    0x96bfd8
  96bef1:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  96bef5:	48 c1 e0 04          	shl    rax,0x4
  96bef9:	49 01 c1             	add    r9,rax
  96befc:	45 0f b6 54 21 0e    	movzx  r10d,BYTE PTR [r9+riz*1+0xe]
  96bf02:	45 85 d2             	test   r10d,r10d
  96bf05:	0f 84 cd 00 00 00    	je     0x96bfd8
  96bf0b:	41 83 fa 04          	cmp    r10d,0x4
  96bf0f:	0f 87 c3 00 00 00    	ja     0x96bfd8
  96bf15:	41 c1 e2 04          	shl    r10d,0x4
  96bf19:	4f 8b 5c 10 18       	mov    r11,QWORD PTR [r8+r10*1+0x18]
  96bf1e:	47 8b 44 10 20       	mov    r8d,DWORD PTR [r8+r10*1+0x20]
  96bf23:	41 8b 01             	mov    eax,DWORD PTR [r9]
  96bf26:	44 39 c0             	cmp    eax,r8d
  96bf29:	0f 87 a9 00 00 00    	ja     0x96bfd8
  96bf2f:	41 29 c0             	sub    r8d,eax
  96bf32:	41 8b 49 04          	mov    ecx,DWORD PTR [r9+0x4]
  96bf36:	44 39 c1             	cmp    ecx,r8d
  96bf39:	0f 87 99 00 00 00    	ja     0x96bfd8
  96bf3f:	83 f9 10             	cmp    ecx,0x10
  96bf42:	0f 82 90 00 00 00    	jb     0x96bfd8
  96bf48:	49 01 c3             	add    r11,rax
  96bf4b:	41 8b 0b             	mov    ecx,DWORD PTR [r11]
  96bf4e:	39 d1                	cmp    ecx,edx
  96bf50:	0f 84 74 00 00 00    	je     0x96bfca
  96bf56:	85 f6                	test   esi,esi
  96bf58:	0f 85 7a 00 00 00    	jne    0x96bfd8
  96bf5e:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  96bf65:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  96bf69:	89 c8                	mov    eax,ecx
  96bf6b:	41 3b 80 a4 00 00 00 	cmp    eax,DWORD PTR [r8+0xa4]
  96bf72:	0f 83 60 00 00 00    	jae    0x96bfd8
  96bf78:	89 d0                	mov    eax,edx
  96bf7a:	41 3b 80 a4 00 00 00 	cmp    eax,DWORD PTR [r8+0xa4]
  96bf81:	0f 83 51 00 00 00    	jae    0x96bfd8
  96bf87:	4d 8b 90 a8 00 00 00 	mov    r10,QWORD PTR [r8+0xa8]
  96bf8e:	4d 85 d2             	test   r10,r10
  96bf91:	0f 84 41 00 00 00    	je     0x96bfd8
  96bf97:	89 c8                	mov    eax,ecx
  96bf99:	48 6b c0 08          	imul   rax,rax,0x8
  96bf9d:	4d 8b 0c 02          	mov    r9,QWORD PTR [r10+rax*1]
  96bfa1:	89 d0                	mov    eax,edx
  96bfa3:	48 6b c0 08          	imul   rax,rax,0x8
  96bfa7:	4d 8b 14 02          	mov    r10,QWORD PTR [r10+rax*1]
  96bfab:	4c 89 c8             	mov    rax,r9
  96bfae:	48 c1 e8 20          	shr    rax,0x20
  96bfb2:	4c 89 d1             	mov    rcx,r10
  96bfb5:	48 c1 e9 20          	shr    rcx,0x20
  96bfb9:	39 c8                	cmp    eax,ecx
  96bfbb:	0f 82 17 00 00 00    	jb     0x96bfd8
  96bfc1:	45 39 d1             	cmp    r9d,r10d
  96bfc4:	0f 87 0e 00 00 00    	ja     0x96bfd8
  96bfca:	89 f8                	mov    eax,edi
  96bfcc:	e9 00 00 00 00       	jmp    0x96bfd1
  96bfd1:	41 5b                	pop    r11
  96bfd3:	41 5a                	pop    r10
  96bfd5:	41 59                	pop    r9
  96bfd7:	c3                   	ret
  96bfd8:	41 5b                	pop    r11
  96bfda:	41 5a                	pop    r10
  96bfdc:	41 59                	pop    r9
  96bfde:	e9 dc 04 00 00       	jmp    0x96c4bf
  96bfe3:	41 51                	push   r9
  96bfe5:	41 52                	push   r10
  96bfe7:	41 53                	push   r11
  96bfe9:	49 89 c2             	mov    r10,rax
  96bfec:	49 c1 ea 20          	shr    r10,0x20
  96bff0:	4d 85 d2             	test   r10,r10
  96bff3:	0f 85 46 01 00 00    	jne    0x96c13f
  96bff9:	85 c0                	test   eax,eax
  96bffb:	0f 85 0c 00 00 00    	jne    0x96c00d
  96c001:	89 c8                	mov    eax,ecx
  96c003:	ba 00 00 00 00       	mov    edx,0x0
  96c008:	e9 3c 01 00 00       	jmp    0x96c149
  96c00d:	41 89 c2             	mov    r10d,eax
  96c010:	41 83 e2 01          	and    r10d,0x1
  96c014:	45 85 d2             	test   r10d,r10d
  96c017:	0f 85 22 01 00 00    	jne    0x96c13f
  96c01d:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  96c024:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  96c028:	48 6b d2 04          	imul   rdx,rdx,0x4
  96c02c:	41 8b 14 12          	mov    edx,DWORD PTR [r10+rdx*1]
  96c030:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  96c034:	d1 e8                	shr    eax,1
  96c036:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  96c03a:	0f 83 10 01 00 00    	jae    0x96c150
  96c040:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  96c044:	48 c1 e0 04          	shl    rax,0x4
  96c048:	49 01 c1             	add    r9,rax
  96c04b:	45 0f b6 54 21 0e    	movzx  r10d,BYTE PTR [r9+riz*1+0xe]
  96c051:	45 85 d2             	test   r10d,r10d
  96c054:	0f 84 f6 00 00 00    	je     0x96c150
  96c05a:	41 83 fa 04          	cmp    r10d,0x4
  96c05e:	0f 87 ec 00 00 00    	ja     0x96c150
  96c064:	41 c1 e2 04          	shl    r10d,0x4
  96c068:	4f 8b 5c 10 18       	mov    r11,QWORD PTR [r8+r10*1+0x18]
  96c06d:	47 8b 44 10 20       	mov    r8d,DWORD PTR [r8+r10*1+0x20]
  96c072:	41 8b 01             	mov    eax,DWORD PTR [r9]
  96c075:	44 39 c0             	cmp    eax,r8d
  96c078:	0f 87 d2 00 00 00    	ja     0x96c150
  96c07e:	41 29 c0             	sub    r8d,eax
  96c081:	41 8b 49 04          	mov    ecx,DWORD PTR [r9+0x4]
  96c085:	44 39 c1             	cmp    ecx,r8d
  96c088:	0f 87 c2 00 00 00    	ja     0x96c150
  96c08e:	83 f9 10             	cmp    ecx,0x10
  96c091:	0f 82 b9 00 00 00    	jb     0x96c150
  96c097:	89 cf                	mov    edi,ecx
  96c099:	49 01 c3             	add    r11,rax
  96c09c:	41 8b 0b             	mov    ecx,DWORD PTR [r11]
  96c09f:	39 d1                	cmp    ecx,edx
  96c0a1:	0f 84 6c 00 00 00    	je     0x96c113
  96c0a7:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  96c0ae:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  96c0b2:	89 c8                	mov    eax,ecx
  96c0b4:	41 3b 80 a4 00 00 00 	cmp    eax,DWORD PTR [r8+0xa4]
  96c0bb:	0f 83 8f 00 00 00    	jae    0x96c150
  96c0c1:	89 d0                	mov    eax,edx
  96c0c3:	41 3b 80 a4 00 00 00 	cmp    eax,DWORD PTR [r8+0xa4]
  96c0ca:	0f 83 80 00 00 00    	jae    0x96c150
  96c0d0:	4d 8b 90 a8 00 00 00 	mov    r10,QWORD PTR [r8+0xa8]
  96c0d7:	4d 85 d2             	test   r10,r10
  96c0da:	0f 84 70 00 00 00    	je     0x96c150
  96c0e0:	89 c8                	mov    eax,ecx
  96c0e2:	48 6b c0 08          	imul   rax,rax,0x8
  96c0e6:	4d 8b 0c 02          	mov    r9,QWORD PTR [r10+rax*1]
  96c0ea:	89 d0                	mov    eax,edx
  96c0ec:	48 6b c0 08          	imul   rax,rax,0x8
  96c0f0:	4d 8b 14 02          	mov    r10,QWORD PTR [r10+rax*1]
  96c0f4:	4c 89 c8             	mov    rax,r9
  96c0f7:	48 c1 e8 20          	shr    rax,0x20
  96c0fb:	4c 89 d1             	mov    rcx,r10
  96c0fe:	48 c1 e9 20          	shr    rcx,0x20
  96c102:	39 c8                	cmp    eax,ecx
  96c104:	0f 82 35 00 00 00    	jb     0x96c13f
  96c10a:	45 39 d1             	cmp    r9d,r10d
  96c10d:	0f 87 2c 00 00 00    	ja     0x96c13f
  96c113:	41 8b 03             	mov    eax,DWORD PTR [r11]
  96c116:	39 d0                	cmp    eax,edx
  96c118:	0f 85 32 00 00 00    	jne    0x96c150
  96c11e:	39 f7                	cmp    edi,esi
  96c120:	0f 82 2a 00 00 00    	jb     0x96c150
  96c126:	41 8b 43 04          	mov    eax,DWORD PTR [r11+0x4]
  96c12a:	39 f0                	cmp    eax,esi
  96c12c:	0f 82 1e 00 00 00    	jb     0x96c150
  96c132:	4c 89 da             	mov    rdx,r11
  96c135:	b8 01 00 00 00       	mov    eax,0x1
  96c13a:	e9 0a 00 00 00       	jmp    0x96c149
  96c13f:	b8 00 00 00 00       	mov    eax,0x0
  96c144:	ba 00 00 00 00       	mov    edx,0x0
  96c149:	41 5b                	pop    r11
  96c14b:	41 5a                	pop    r10
  96c14d:	41 59                	pop    r9
  96c14f:	c3                   	ret
  96c150:	41 5b                	pop    r11
  96c152:	41 5a                	pop    r10
  96c154:	41 59                	pop    r9
  96c156:	e9 64 03 00 00       	jmp    0x96c4bf
  96c15b:	41 51                	push   r9
  96c15d:	41 52                	push   r10
  96c15f:	41 53                	push   r11
  96c161:	49 89 c2             	mov    r10,rax
  96c164:	49 c1 ea 20          	shr    r10,0x20
  96c168:	4d 85 d2             	test   r10,r10
  96c16b:	0f 85 1d 01 00 00    	jne    0x96c28e
  96c171:	85 c0                	test   eax,eax
  96c173:	0f 85 07 00 00 00    	jne    0x96c180
  96c179:	89 c8                	mov    eax,ecx
  96c17b:	e9 13 01 00 00       	jmp    0x96c293
  96c180:	41 89 c2             	mov    r10d,eax
  96c183:	41 83 e2 01          	and    r10d,0x1
  96c187:	45 85 d2             	test   r10d,r10d
  96c18a:	0f 85 fe 00 00 00    	jne    0x96c28e
  96c190:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  96c197:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  96c19b:	48 6b d2 04          	imul   rdx,rdx,0x4
  96c19f:	41 8b 14 12          	mov    edx,DWORD PTR [r10+rdx*1]
  96c1a3:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  96c1a7:	d1 e8                	shr    eax,1
  96c1a9:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  96c1ad:	0f 83 e7 00 00 00    	jae    0x96c29a
  96c1b3:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  96c1b7:	48 c1 e0 04          	shl    rax,0x4
  96c1bb:	49 01 c1             	add    r9,rax
  96c1be:	45 0f b6 54 21 0e    	movzx  r10d,BYTE PTR [r9+riz*1+0xe]
  96c1c4:	45 85 d2             	test   r10d,r10d
  96c1c7:	0f 84 cd 00 00 00    	je     0x96c29a
  96c1cd:	41 83 fa 04          	cmp    r10d,0x4
  96c1d1:	0f 87 c3 00 00 00    	ja     0x96c29a
  96c1d7:	41 c1 e2 04          	shl    r10d,0x4
  96c1db:	4f 8b 5c 10 18       	mov    r11,QWORD PTR [r8+r10*1+0x18]
  96c1e0:	47 8b 44 10 20       	mov    r8d,DWORD PTR [r8+r10*1+0x20]
  96c1e5:	41 8b 01             	mov    eax,DWORD PTR [r9]
  96c1e8:	44 39 c0             	cmp    eax,r8d
  96c1eb:	0f 87 a9 00 00 00    	ja     0x96c29a
  96c1f1:	41 29 c0             	sub    r8d,eax
  96c1f4:	41 8b 49 04          	mov    ecx,DWORD PTR [r9+0x4]
  96c1f8:	44 39 c1             	cmp    ecx,r8d
  96c1fb:	0f 87 99 00 00 00    	ja     0x96c29a
  96c201:	83 f9 10             	cmp    ecx,0x10
  96c204:	0f 82 90 00 00 00    	jb     0x96c29a
  96c20a:	49 01 c3             	add    r11,rax
  96c20d:	41 8b 0b             	mov    ecx,DWORD PTR [r11]
  96c210:	39 d1                	cmp    ecx,edx
  96c212:	0f 84 6c 00 00 00    	je     0x96c284
  96c218:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  96c21f:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  96c223:	89 c8                	mov    eax,ecx
  96c225:	41 3b 80 a4 00 00 00 	cmp    eax,DWORD PTR [r8+0xa4]
  96c22c:	0f 83 68 00 00 00    	jae    0x96c29a
  96c232:	89 d0                	mov    eax,edx
  96c234:	41 3b 80 a4 00 00 00 	cmp    eax,DWORD PTR [r8+0xa4]
  96c23b:	0f 83 59 00 00 00    	jae    0x96c29a
  96c241:	4d 8b 90 a8 00 00 00 	mov    r10,QWORD PTR [r8+0xa8]
  96c248:	4d 85 d2             	test   r10,r10
  96c24b:	0f 84 49 00 00 00    	je     0x96c29a
  96c251:	89 c8                	mov    eax,ecx
  96c253:	48 6b c0 08          	imul   rax,rax,0x8
  96c257:	4d 8b 0c 02          	mov    r9,QWORD PTR [r10+rax*1]
  96c25b:	89 d0                	mov    eax,edx
  96c25d:	48 6b c0 08          	imul   rax,rax,0x8
  96c261:	4d 8b 14 02          	mov    r10,QWORD PTR [r10+rax*1]
  96c265:	4c 89 c8             	mov    rax,r9
  96c268:	48 c1 e8 20          	shr    rax,0x20
  96c26c:	4c 89 d1             	mov    rcx,r10
  96c26f:	48 c1 e9 20          	shr    rcx,0x20
  96c273:	39 c8                	cmp    eax,ecx
  96c275:	0f 82 13 00 00 00    	jb     0x96c28e
  96c27b:	45 39 d1             	cmp    r9d,r10d
  96c27e:	0f 87 0a 00 00 00    	ja     0x96c28e
  96c284:	b8 01 00 00 00       	mov    eax,0x1
  96c289:	e9 05 00 00 00       	jmp    0x96c293
  96c28e:	b8 00 00 00 00       	mov    eax,0x0
  96c293:	41 5b                	pop    r11
  96c295:	41 5a                	pop    r10
  96c297:	41 59                	pop    r9
  96c299:	c3                   	ret
  96c29a:	41 5b                	pop    r11
  96c29c:	41 5a                	pop    r10
  96c29e:	41 59                	pop    r9
  96c2a0:	e9 1a 02 00 00       	jmp    0x96c4bf
  96c2a5:	41 51                	push   r9
  96c2a7:	41 52                	push   r10
  96c2a9:	41 53                	push   r11
  96c2ab:	89 cf                	mov    edi,ecx
  96c2ad:	49 89 c2             	mov    r10,rax
  96c2b0:	49 c1 ea 20          	shr    r10,0x20
  96c2b4:	4d 85 d2             	test   r10,r10
  96c2b7:	0f 85 c5 00 00 00    	jne    0x96c382
  96c2bd:	85 c0                	test   eax,eax
  96c2bf:	0f 85 0d 00 00 00    	jne    0x96c2d2
  96c2c5:	85 f6                	test   esi,esi
  96c2c7:	0f 84 b5 00 00 00    	je     0x96c382
  96c2cd:	e9 bb 00 00 00       	jmp    0x96c38d
  96c2d2:	41 89 c2             	mov    r10d,eax
  96c2d5:	41 83 e2 01          	and    r10d,0x1
  96c2d9:	45 85 d2             	test   r10d,r10d
  96c2dc:	0f 85 a0 00 00 00    	jne    0x96c382
  96c2e2:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  96c2e9:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  96c2ed:	48 6b d2 04          	imul   rdx,rdx,0x4
  96c2f1:	41 8b 14 12          	mov    edx,DWORD PTR [r10+rdx*1]
  96c2f5:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  96c2f9:	d1 e8                	shr    eax,1
  96c2fb:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  96c2ff:	0f 83 7d 00 00 00    	jae    0x96c382
  96c305:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  96c309:	48 c1 e0 04          	shl    rax,0x4
  96c30d:	49 01 c1             	add    r9,rax
  96c310:	45 0f b6 54 21 0e    	movzx  r10d,BYTE PTR [r9+riz*1+0xe]
  96c316:	45 85 d2             	test   r10d,r10d
  96c319:	0f 84 63 00 00 00    	je     0x96c382
  96c31f:	41 83 fa 04          	cmp    r10d,0x4
  96c323:	0f 87 59 00 00 00    	ja     0x96c382
  96c329:	41 c1 e2 04          	shl    r10d,0x4
  96c32d:	4f 8b 5c 10 18       	mov    r11,QWORD PTR [r8+r10*1+0x18]
  96c332:	47 8b 44 10 20       	mov    r8d,DWORD PTR [r8+r10*1+0x20]
  96c337:	41 8b 01             	mov    eax,DWORD PTR [r9]
  96c33a:	44 39 c0             	cmp    eax,r8d
  96c33d:	0f 87 3f 00 00 00    	ja     0x96c382
  96c343:	41 29 c0             	sub    r8d,eax
  96c346:	41 8b 49 04          	mov    ecx,DWORD PTR [r9+0x4]
  96c34a:	44 39 c1             	cmp    ecx,r8d
  96c34d:	0f 87 2f 00 00 00    	ja     0x96c382
  96c353:	39 f9                	cmp    ecx,edi
  96c355:	0f 82 27 00 00 00    	jb     0x96c382
  96c35b:	49 01 c3             	add    r11,rax
  96c35e:	41 8b 0b             	mov    ecx,DWORD PTR [r11]
  96c361:	39 d1                	cmp    ecx,edx
  96c363:	0f 85 19 00 00 00    	jne    0x96c382
  96c369:	41 8b 4b 04          	mov    ecx,DWORD PTR [r11+0x4]
  96c36d:	39 f9                	cmp    ecx,edi
  96c36f:	0f 82 0d 00 00 00    	jb     0x96c382
  96c375:	4c 89 de             	mov    rsi,r11
  96c378:	41 5b                	pop    r11
  96c37a:	41 5a                	pop    r10
  96c37c:	41 59                	pop    r9
  96c37e:	48 89 f0             	mov    rax,rsi
  96c381:	c3                   	ret
  96c382:	41 5b                	pop    r11
  96c384:	41 5a                	pop    r10
  96c386:	41 59                	pop    r9
  96c388:	e9 32 01 00 00       	jmp    0x96c4bf
  96c38d:	41 5b                	pop    r11
  96c38f:	41 5a                	pop    r10
  96c391:	41 59                	pop    r9
  96c393:	e9 ff 00 00 00       	jmp    0x96c497
  96c398:	b8 13 00 00 00       	mov    eax,0x13
  96c39d:	e9 00 00 00 00       	jmp    0x96c3a2
  96c3a2:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  96c3a6:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  96c3a9:	44 89 36             	mov    DWORD PTR [rsi],r14d
  96c3ac:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  96c3b0:	c7 46 10 a9 01 00 00 	mov    DWORD PTR [rsi+0x10],0x1a9
  96c3b7:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  96c3ba:	c7 06 01 00 00 00    	mov    DWORD PTR [rsi],0x1
  96c3c0:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  96c3c4:	c3                   	ret
  96c3c5:	b8 ff ff ff ff       	mov    eax,0xffffffff
  96c3ca:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  96c3ce:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  96c3d1:	44 89 36             	mov    DWORD PTR [rsi],r14d
  96c3d4:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  96c3d8:	c7 46 10 c2 01 00 00 	mov    DWORD PTR [rsi+0x10],0x1c2
  96c3df:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  96c3e2:	c7 06 01 00 00 00    	mov    DWORD PTR [rsi],0x1
  96c3e8:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  96c3ec:	c3                   	ret
  96c3ed:	b8 ff ff ff ff       	mov    eax,0xffffffff
  96c3f2:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  96c3f6:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  96c3f9:	44 89 36             	mov    DWORD PTR [rsi],r14d
  96c3fc:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  96c400:	c7 46 10 c9 01 00 00 	mov    DWORD PTR [rsi+0x10],0x1c9
  96c407:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  96c40a:	c7 06 01 00 00 00    	mov    DWORD PTR [rsi],0x1
  96c410:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  96c414:	c3                   	ret
  96c415:	b8 bf 00 00 00       	mov    eax,0xbf
  96c41a:	e9 00 00 00 00       	jmp    0x96c41f
  96c41f:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  96c423:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  96c426:	44 89 36             	mov    DWORD PTR [rsi],r14d
  96c429:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  96c42d:	c7 46 10 95 0b 00 00 	mov    DWORD PTR [rsi+0x10],0xb95
  96c434:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  96c437:	c7 06 01 00 00 00    	mov    DWORD PTR [rsi],0x1
  96c43d:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  96c441:	c3                   	ret
  96c442:	b8 ff ff ff ff       	mov    eax,0xffffffff
  96c447:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  96c44b:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  96c44e:	44 89 36             	mov    DWORD PTR [rsi],r14d
  96c451:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  96c455:	c7 46 10 95 0b 00 00 	mov    DWORD PTR [rsi+0x10],0xb95
  96c45c:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  96c45f:	c7 06 02 00 00 00    	mov    DWORD PTR [rsi],0x2
  96c465:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  96c469:	c3                   	ret
  96c46a:	b8 00 00 00 00       	mov    eax,0x0
  96c46f:	e9 00 00 00 00       	jmp    0x96c474
  96c474:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  96c478:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  96c47b:	44 89 36             	mov    DWORD PTR [rsi],r14d
  96c47e:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  96c482:	c7 46 10 95 0b 00 00 	mov    DWORD PTR [rsi+0x10],0xb95
  96c489:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  96c48c:	c7 06 0d 00 00 00    	mov    DWORD PTR [rsi],0xd
  96c492:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  96c496:	c3                   	ret
  96c497:	b8 ff ff ff ff       	mov    eax,0xffffffff
  96c49c:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  96c4a0:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  96c4a3:	44 89 36             	mov    DWORD PTR [rsi],r14d
  96c4a6:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  96c4aa:	c7 46 10 95 0b 00 00 	mov    DWORD PTR [rsi+0x10],0xb95
  96c4b1:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  96c4b4:	c7 06 10 00 00 00    	mov    DWORD PTR [rsi],0x10
  96c4ba:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  96c4be:	c3                   	ret
  96c4bf:	b8 ff ff ff ff       	mov    eax,0xffffffff
  96c4c4:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  96c4c8:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  96c4cb:	44 89 36             	mov    DWORD PTR [rsi],r14d
  96c4ce:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  96c4d2:	c7 46 10 95 0b 00 00 	mov    DWORD PTR [rsi+0x10],0xb95
  96c4d9:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  96c4dc:	c7 06 12 00 00 00    	mov    DWORD PTR [rsi],0x12
  96c4e2:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  96c4e6:	c3                   	ret
