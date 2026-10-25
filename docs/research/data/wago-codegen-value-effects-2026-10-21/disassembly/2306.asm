
.tmp/wago-next-gc-perf/post-read-regions-profile/profile/native-code.bin:     file format binary


Disassembly of section .data:

000000000063e900 <.data+0x63e900>:
  63e900:	48 81 ec e8 00 00 00 	sub    rsp,0xe8
  63e907:	48 8b 73 b8          	mov    rsi,QWORD PTR [rbx-0x48]
  63e90b:	48 39 f4             	cmp    rsp,rsi
  63e90e:	0f 82 d9 09 00 00    	jb     0x63f2ed
  63e914:	48 89 04 24          	mov    QWORD PTR [rsp],rax
  63e918:	89 4c 24 08          	mov    DWORD PTR [rsp+0x8],ecx
  63e91c:	31 c0                	xor    eax,eax
  63e91e:	45 31 e4             	xor    r12d,r12d
  63e921:	45 31 ed             	xor    r13d,r13d
  63e924:	45 31 c9             	xor    r9d,r9d
  63e927:	45 31 d2             	xor    r10d,r10d
  63e92a:	45 31 db             	xor    r11d,r11d
  63e92d:	31 ed                	xor    ebp,ebp
  63e92f:	89 44 24 40          	mov    DWORD PTR [rsp+0x40],eax
  63e933:	48 89 44 24 48       	mov    QWORD PTR [rsp+0x48],rax
  63e938:	89 44 24 50          	mov    DWORD PTR [rsp+0x50],eax
  63e93c:	89 44 24 58          	mov    DWORD PTR [rsp+0x58],eax
  63e940:	48 8b 3c 24          	mov    rdi,QWORD PTR [rsp]
  63e944:	48 89 7c 24 60       	mov    QWORD PTR [rsp+0x60],rdi
  63e949:	8b 7c 24 08          	mov    edi,DWORD PTR [rsp+0x8]
  63e94d:	48 89 bc 24 90 00 00 	mov    QWORD PTR [rsp+0x90],rdi
  63e954:	00 
  63e955:	48 8b 7c 24 60       	mov    rdi,QWORD PTR [rsp+0x60]
  63e95a:	48 89 f8             	mov    rax,rdi
  63e95d:	ba a0 09 00 00       	mov    edx,0x9a0
  63e962:	b9 18 00 00 00       	mov    ecx,0x18
  63e967:	be 00 00 00 00       	mov    esi,0x0
  63e96c:	e8 02 08 00 00       	call   0x63f173
  63e971:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  63e975:	48 89 84 24 98 00 00 	mov    QWORD PTR [rsp+0x98],rax
  63e97c:	00 
  63e97d:	4c 89 64 24 10       	mov    QWORD PTR [rsp+0x10],r12
  63e982:	4c 89 6c 24 18       	mov    QWORD PTR [rsp+0x18],r13
  63e987:	4c 89 4c 24 20       	mov    QWORD PTR [rsp+0x20],r9
  63e98c:	4c 89 54 24 28       	mov    QWORD PTR [rsp+0x28],r10
  63e991:	4c 89 5c 24 30       	mov    QWORD PTR [rsp+0x30],r11
  63e996:	48 89 6c 24 38       	mov    QWORD PTR [rsp+0x38],rbp
  63e99b:	8b bc 24 98 00 00 00 	mov    edi,DWORD PTR [rsp+0x98]
  63e9a2:	89 7c 24 70          	mov    DWORD PTR [rsp+0x70],edi
  63e9a6:	8b bc 24 90 00 00 00 	mov    edi,DWORD PTR [rsp+0x90]
  63e9ad:	89 7c 24 68          	mov    DWORD PTR [rsp+0x68],edi
  63e9b1:	8b 7c 24 68          	mov    edi,DWORD PTR [rsp+0x68]
  63e9b5:	8b 74 24 70          	mov    esi,DWORD PTR [rsp+0x70]
  63e9b9:	39 f7                	cmp    edi,esi
  63e9bb:	0f 82 05 00 00 00    	jb     0x63e9c6
  63e9c1:	e9 cd 08 00 00       	jmp    0x63f293
  63e9c6:	8b 7c 24 08          	mov    edi,DWORD PTR [rsp+0x8]
  63e9ca:	89 bc 24 80 00 00 00 	mov    DWORD PTR [rsp+0x80],edi
  63e9d1:	48 8b 3c 24          	mov    rdi,QWORD PTR [rsp]
  63e9d5:	48 89 7c 24 78       	mov    QWORD PTR [rsp+0x78],rdi
  63e9da:	8b bc 24 80 00 00 00 	mov    edi,DWORD PTR [rsp+0x80]
  63e9e1:	48 89 bc 24 90 00 00 	mov    QWORD PTR [rsp+0x90],rdi
  63e9e8:	00 
  63e9e9:	48 8b 7c 24 78       	mov    rdi,QWORD PTR [rsp+0x78]
  63e9ee:	48 89 f8             	mov    rax,rdi
  63e9f1:	ba a0 09 00 00       	mov    edx,0x9a0
  63e9f6:	b9 18 00 00 00       	mov    ecx,0x18
  63e9fb:	be 00 00 00 00       	mov    esi,0x0
  63ea00:	e8 6e 07 00 00       	call   0x63f173
  63ea05:	48 89 84 24 88 00 00 	mov    QWORD PTR [rsp+0x88],rax
  63ea0c:	00 
  63ea0d:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  63ea11:	8b bc 24 90 00 00 00 	mov    edi,DWORD PTR [rsp+0x90]
  63ea18:	39 c7                	cmp    edi,eax
  63ea1a:	0f 82 05 00 00 00    	jb     0x63ea25
  63ea20:	e9 41 08 00 00       	jmp    0x63f266
  63ea25:	48 8b bc 24 88 00 00 	mov    rdi,QWORD PTR [rsp+0x88]
  63ea2c:	00 
  63ea2d:	8b 7f 10             	mov    edi,DWORD PTR [rdi+0x10]
  63ea30:	48 89 f8             	mov    rax,rdi
  63ea33:	8b bc 24 80 00 00 00 	mov    edi,DWORD PTR [rsp+0x80]
  63ea3a:	89 f9                	mov    ecx,edi
  63ea3c:	ba 3d 23 00 00       	mov    edx,0x233d
  63ea41:	be 00 00 00 00       	mov    esi,0x0
  63ea46:	e8 fe 05 00 00       	call   0x63f049
  63ea4b:	8b 04 20             	mov    eax,DWORD PTR [rax+riz*1]
  63ea4e:	48 89 84 24 90 00 00 	mov    QWORD PTR [rsp+0x90],rax
  63ea55:	00 
  63ea56:	4c 8b a4 24 90 00 00 	mov    r12,QWORD PTR [rsp+0x90]
  63ea5d:	00 
  63ea5e:	4c 89 e7             	mov    rdi,r12
  63ea61:	48 89 f8             	mov    rax,rdi
  63ea64:	ba 2b 0e 00 00       	mov    edx,0xe2b
  63ea69:	b9 18 00 00 00       	mov    ecx,0x18
  63ea6e:	be 00 00 00 00       	mov    esi,0x0
  63ea73:	e8 fb 06 00 00       	call   0x63f173
  63ea78:	48 8b 44 20 10       	mov    rax,QWORD PTR [rax+riz*1+0x10]
  63ea7d:	49 89 c5             	mov    r13,rax
  63ea80:	4c 89 e7             	mov    rdi,r12
  63ea83:	48 89 f8             	mov    rax,rdi
  63ea86:	ba 2b 0e 00 00       	mov    edx,0xe2b
  63ea8b:	b9 1c 00 00 00       	mov    ecx,0x1c
  63ea90:	be 00 00 00 00       	mov    esi,0x0
  63ea95:	e8 d9 06 00 00       	call   0x63f173
  63ea9a:	8b 40 18             	mov    eax,DWORD PTR [rax+0x18]
  63ea9d:	49 89 c1             	mov    r9,rax
  63eaa0:	4c 89 e7             	mov    rdi,r12
  63eaa3:	48 89 f8             	mov    rax,rdi
  63eaa6:	ba 2b 0e 00 00       	mov    edx,0xe2b
  63eaab:	b9 20 00 00 00       	mov    ecx,0x20
  63eab0:	be 00 00 00 00       	mov    esi,0x0
  63eab5:	e8 b9 06 00 00       	call   0x63f173
  63eaba:	8b 40 1c             	mov    eax,DWORD PTR [rax+0x1c]
  63eabd:	49 89 c2             	mov    r10,rax
  63eac0:	4c 89 e7             	mov    rdi,r12
  63eac3:	48 89 f8             	mov    rax,rdi
  63eac6:	ba 2b 0e 00 00       	mov    edx,0xe2b
  63eacb:	b9 24 00 00 00       	mov    ecx,0x24
  63ead0:	be 00 00 00 00       	mov    esi,0x0
  63ead5:	e8 99 06 00 00       	call   0x63f173
  63eada:	8b 40 20             	mov    eax,DWORD PTR [rax+0x20]
  63eadd:	49 89 c3             	mov    r11,rax
  63eae0:	4c 89 e7             	mov    rdi,r12
  63eae3:	48 89 f8             	mov    rax,rdi
  63eae6:	ba 2b 0e 00 00       	mov    edx,0xe2b
  63eaeb:	b9 28 00 00 00       	mov    ecx,0x28
  63eaf0:	be 00 00 00 00       	mov    esi,0x0
  63eaf5:	e8 79 06 00 00       	call   0x63f173
  63eafa:	8b 40 24             	mov    eax,DWORD PTR [rax+0x24]
  63eafd:	48 89 c5             	mov    rbp,rax
  63eb00:	4c 89 e7             	mov    rdi,r12
  63eb03:	48 89 f8             	mov    rax,rdi
  63eb06:	ba 2b 0e 00 00       	mov    edx,0xe2b
  63eb0b:	b9 2c 00 00 00       	mov    ecx,0x2c
  63eb10:	be 00 00 00 00       	mov    esi,0x0
  63eb15:	e8 59 06 00 00       	call   0x63f173
  63eb1a:	8b 44 20 28          	mov    eax,DWORD PTR [rax+riz*1+0x28]
  63eb1e:	89 44 24 40          	mov    DWORD PTR [rsp+0x40],eax
  63eb22:	4c 89 e7             	mov    rdi,r12
  63eb25:	48 89 f8             	mov    rax,rdi
  63eb28:	ba 2b 0e 00 00       	mov    edx,0xe2b
  63eb2d:	b9 30 00 00 00       	mov    ecx,0x30
  63eb32:	be 00 00 00 00       	mov    esi,0x0
  63eb37:	e8 37 06 00 00       	call   0x63f173
  63eb3c:	8b 40 2c             	mov    eax,DWORD PTR [rax+0x2c]
  63eb3f:	48 89 44 24 48       	mov    QWORD PTR [rsp+0x48],rax
  63eb44:	4c 89 e7             	mov    rdi,r12
  63eb47:	48 89 f8             	mov    rax,rdi
  63eb4a:	ba 2b 0e 00 00       	mov    edx,0xe2b
  63eb4f:	b9 34 00 00 00       	mov    ecx,0x34
  63eb54:	be 00 00 00 00       	mov    esi,0x0
  63eb59:	e8 15 06 00 00       	call   0x63f173
  63eb5e:	8b 44 20 30          	mov    eax,DWORD PTR [rax+riz*1+0x30]
  63eb62:	89 44 24 50          	mov    DWORD PTR [rsp+0x50],eax
  63eb66:	4c 89 e7             	mov    rdi,r12
  63eb69:	48 89 f8             	mov    rax,rdi
  63eb6c:	ba 2b 0e 00 00       	mov    edx,0xe2b
  63eb71:	b9 38 00 00 00       	mov    ecx,0x38
  63eb76:	be 00 00 00 00       	mov    esi,0x0
  63eb7b:	e8 f3 05 00 00       	call   0x63f173
  63eb80:	8b 44 20 34          	mov    eax,DWORD PTR [rax+riz*1+0x34]
  63eb84:	89 44 24 58          	mov    DWORD PTR [rsp+0x58],eax
  63eb88:	4c 89 ac 24 90 00 00 	mov    QWORD PTR [rsp+0x90],r13
  63eb8f:	00 
  63eb90:	4c 89 8c 24 98 00 00 	mov    QWORD PTR [rsp+0x98],r9
  63eb97:	00 
  63eb98:	4c 89 94 24 a0 00 00 	mov    QWORD PTR [rsp+0xa0],r10
  63eb9f:	00 
  63eba0:	4c 89 9c 24 a8 00 00 	mov    QWORD PTR [rsp+0xa8],r11
  63eba7:	00 
  63eba8:	48 89 ac 24 b0 00 00 	mov    QWORD PTR [rsp+0xb0],rbp
  63ebaf:	00 
  63ebb0:	8b 7c 24 40          	mov    edi,DWORD PTR [rsp+0x40]
  63ebb4:	48 89 bc 24 b8 00 00 	mov    QWORD PTR [rsp+0xb8],rdi
  63ebbb:	00 
  63ebbc:	48 8b 7c 24 48       	mov    rdi,QWORD PTR [rsp+0x48]
  63ebc1:	48 89 bc 24 c0 00 00 	mov    QWORD PTR [rsp+0xc0],rdi
  63ebc8:	00 
  63ebc9:	8b 7c 24 50          	mov    edi,DWORD PTR [rsp+0x50]
  63ebcd:	48 89 bc 24 c8 00 00 	mov    QWORD PTR [rsp+0xc8],rdi
  63ebd4:	00 
  63ebd5:	8b 7c 24 58          	mov    edi,DWORD PTR [rsp+0x58]
  63ebd9:	48 89 bc 24 d0 00 00 	mov    QWORD PTR [rsp+0xd0],rdi
  63ebe0:	00 
  63ebe1:	bf 2b 0e 00 00       	mov    edi,0xe2b
  63ebe6:	48 89 bc 24 d8 00 00 	mov    QWORD PTR [rsp+0xd8],rdi
  63ebed:	00 
  63ebee:	41 50                	push   r8
  63ebf0:	41 51                	push   r9
  63ebf2:	41 52                	push   r10
  63ebf4:	41 53                	push   r11
  63ebf6:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  63ebfd:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  63ec01:	41 8b 92 ac 38 00 00 	mov    edx,DWORD PTR [r10+0x38ac]
  63ec08:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  63ec0c:	41 83 b8 a0 00 00 00 	cmp    DWORD PTR [r8+0xa0],0x38
  63ec13:	38 
  63ec14:	0f 86 26 03 00 00    	jbe    0x63ef40
  63ec1a:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  63ec21:	4d 85 d2             	test   r10,r10
  63ec24:	0f 84 16 03 00 00    	je     0x63ef40
  63ec2a:	41 8b 4a 04          	mov    ecx,DWORD PTR [r10+0x4]
  63ec2e:	41 8b 42 08          	mov    eax,DWORD PTR [r10+0x8]
  63ec32:	81 f8 00 02 00 00    	cmp    eax,0x200
  63ec38:	0f 87 02 03 00 00    	ja     0x63ef40
  63ec3e:	39 c1                	cmp    ecx,eax
  63ec40:	0f 83 fa 02 00 00    	jae    0x63ef40
  63ec46:	49 8d 44 8a 20       	lea    rax,[r10+rcx*4+0x20]
  63ec4b:	8b 30                	mov    esi,DWORD PTR [rax]
  63ec4d:	89 f0                	mov    eax,esi
  63ec4f:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  63ec53:	48 c1 e0 04          	shl    rax,0x4
  63ec57:	49 01 c1             	add    r9,rax
  63ec5a:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  63ec61:	48 85 c0             	test   rax,rax
  63ec64:	0f 84 d6 02 00 00    	je     0x63ef40
  63ec6a:	8b 08                	mov    ecx,DWORD PTR [rax]
  63ec6c:	83 c1 07             	add    ecx,0x7
  63ec6f:	83 e1 f8             	and    ecx,0xfffffff8
  63ec72:	41 8b 40 7c          	mov    eax,DWORD PTR [r8+0x7c]
  63ec76:	39 c1                	cmp    ecx,eax
  63ec78:	0f 87 c2 02 00 00    	ja     0x63ef40
  63ec7e:	29 c8                	sub    eax,ecx
  63ec80:	83 f8 38             	cmp    eax,0x38
  63ec83:	0f 82 b7 02 00 00    	jb     0x63ef40
  63ec89:	4d 8b 58 28          	mov    r11,QWORD PTR [r8+0x28]
  63ec8d:	4d 85 db             	test   r11,r11
  63ec90:	0f 84 aa 02 00 00    	je     0x63ef40
  63ec96:	49 01 cb             	add    r11,rcx
  63ec99:	49 8b 80 98 00 00 00 	mov    rax,QWORD PTR [r8+0x98]
  63eca0:	48 85 c0             	test   rax,rax
  63eca3:	0f 84 97 02 00 00    	je     0x63ef40
  63eca9:	8b 84 24 b8 00 00 00 	mov    eax,DWORD PTR [rsp+0xb8]
  63ecb0:	85 c0                	test   eax,eax
  63ecb2:	0f 84 42 00 00 00    	je     0x63ecfa
  63ecb8:	89 c2                	mov    edx,eax
  63ecba:	83 e2 01             	and    edx,0x1
  63ecbd:	85 d2                	test   edx,edx
  63ecbf:	0f 85 35 00 00 00    	jne    0x63ecfa
  63ecc5:	d1 e8                	shr    eax,1
  63ecc7:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  63eccb:	0f 83 6f 02 00 00    	jae    0x63ef40
  63ecd1:	4d 8b 50 08          	mov    r10,QWORD PTR [r8+0x8]
  63ecd5:	48 c1 e0 04          	shl    rax,0x4
  63ecd9:	49 01 c2             	add    r10,rax
  63ecdc:	41 8b 42 0c          	mov    eax,DWORD PTR [r10+0xc]
  63ece0:	c1 e8 10             	shr    eax,0x10
  63ece3:	81 e0 ff 00 00 00    	and    eax,0xff
  63ece9:	85 c0                	test   eax,eax
  63eceb:	0f 84 4f 02 00 00    	je     0x63ef40
  63ecf1:	83 f8 04             	cmp    eax,0x4
  63ecf4:	0f 87 46 02 00 00    	ja     0x63ef40
  63ecfa:	8b 84 24 c0 00 00 00 	mov    eax,DWORD PTR [rsp+0xc0]
  63ed01:	85 c0                	test   eax,eax
  63ed03:	0f 84 42 00 00 00    	je     0x63ed4b
  63ed09:	89 c2                	mov    edx,eax
  63ed0b:	83 e2 01             	and    edx,0x1
  63ed0e:	85 d2                	test   edx,edx
  63ed10:	0f 85 35 00 00 00    	jne    0x63ed4b
  63ed16:	d1 e8                	shr    eax,1
  63ed18:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  63ed1c:	0f 83 1e 02 00 00    	jae    0x63ef40
  63ed22:	4d 8b 50 08          	mov    r10,QWORD PTR [r8+0x8]
  63ed26:	48 c1 e0 04          	shl    rax,0x4
  63ed2a:	49 01 c2             	add    r10,rax
  63ed2d:	41 8b 42 0c          	mov    eax,DWORD PTR [r10+0xc]
  63ed31:	c1 e8 10             	shr    eax,0x10
  63ed34:	81 e0 ff 00 00 00    	and    eax,0xff
  63ed3a:	85 c0                	test   eax,eax
  63ed3c:	0f 84 fe 01 00 00    	je     0x63ef40
  63ed42:	83 f8 04             	cmp    eax,0x4
  63ed45:	0f 87 f5 01 00 00    	ja     0x63ef40
  63ed4b:	8b 84 24 c8 00 00 00 	mov    eax,DWORD PTR [rsp+0xc8]
  63ed52:	85 c0                	test   eax,eax
  63ed54:	0f 84 42 00 00 00    	je     0x63ed9c
  63ed5a:	89 c2                	mov    edx,eax
  63ed5c:	83 e2 01             	and    edx,0x1
  63ed5f:	85 d2                	test   edx,edx
  63ed61:	0f 85 35 00 00 00    	jne    0x63ed9c
  63ed67:	d1 e8                	shr    eax,1
  63ed69:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  63ed6d:	0f 83 cd 01 00 00    	jae    0x63ef40
  63ed73:	4d 8b 50 08          	mov    r10,QWORD PTR [r8+0x8]
  63ed77:	48 c1 e0 04          	shl    rax,0x4
  63ed7b:	49 01 c2             	add    r10,rax
  63ed7e:	41 8b 42 0c          	mov    eax,DWORD PTR [r10+0xc]
  63ed82:	c1 e8 10             	shr    eax,0x10
  63ed85:	81 e0 ff 00 00 00    	and    eax,0xff
  63ed8b:	85 c0                	test   eax,eax
  63ed8d:	0f 84 ad 01 00 00    	je     0x63ef40
  63ed93:	83 f8 04             	cmp    eax,0x4
  63ed96:	0f 87 a4 01 00 00    	ja     0x63ef40
  63ed9c:	8b 84 24 d0 00 00 00 	mov    eax,DWORD PTR [rsp+0xd0]
  63eda3:	85 c0                	test   eax,eax
  63eda5:	0f 84 42 00 00 00    	je     0x63eded
  63edab:	89 c2                	mov    edx,eax
  63edad:	83 e2 01             	and    edx,0x1
  63edb0:	85 d2                	test   edx,edx
  63edb2:	0f 85 35 00 00 00    	jne    0x63eded
  63edb8:	d1 e8                	shr    eax,1
  63edba:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  63edbe:	0f 83 7c 01 00 00    	jae    0x63ef40
  63edc4:	4d 8b 50 08          	mov    r10,QWORD PTR [r8+0x8]
  63edc8:	48 c1 e0 04          	shl    rax,0x4
  63edcc:	49 01 c2             	add    r10,rax
  63edcf:	41 8b 42 0c          	mov    eax,DWORD PTR [r10+0xc]
  63edd3:	c1 e8 10             	shr    eax,0x10
  63edd6:	81 e0 ff 00 00 00    	and    eax,0xff
  63eddc:	85 c0                	test   eax,eax
  63edde:	0f 84 5c 01 00 00    	je     0x63ef40
  63ede4:	83 f8 04             	cmp    eax,0x4
  63ede7:	0f 87 53 01 00 00    	ja     0x63ef40
  63eded:	8b 84 24 e0 00 00 00 	mov    eax,DWORD PTR [rsp+0xe0]
  63edf4:	85 c0                	test   eax,eax
  63edf6:	0f 84 42 00 00 00    	je     0x63ee3e
  63edfc:	89 c2                	mov    edx,eax
  63edfe:	83 e2 01             	and    edx,0x1
  63ee01:	85 d2                	test   edx,edx
  63ee03:	0f 85 35 00 00 00    	jne    0x63ee3e
  63ee09:	d1 e8                	shr    eax,1
  63ee0b:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  63ee0f:	0f 83 2b 01 00 00    	jae    0x63ef40
  63ee15:	4d 8b 50 08          	mov    r10,QWORD PTR [r8+0x8]
  63ee19:	48 c1 e0 04          	shl    rax,0x4
  63ee1d:	49 01 c2             	add    r10,rax
  63ee20:	41 8b 42 0c          	mov    eax,DWORD PTR [r10+0xc]
  63ee24:	c1 e8 10             	shr    eax,0x10
  63ee27:	81 e0 ff 00 00 00    	and    eax,0xff
  63ee2d:	85 c0                	test   eax,eax
  63ee2f:	0f 84 0b 01 00 00    	je     0x63ef40
  63ee35:	83 f8 04             	cmp    eax,0x4
  63ee38:	0f 87 02 01 00 00    	ja     0x63ef40
  63ee3e:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  63ee45:	41 8b 52 04          	mov    edx,DWORD PTR [r10+0x4]
  63ee49:	48 8b 83 e8 fe ff ff 	mov    rax,QWORD PTR [rbx-0x118]
  63ee50:	48 8b 40 10          	mov    rax,QWORD PTR [rax+0x10]
  63ee54:	8b 80 ac 38 00 00    	mov    eax,DWORD PTR [rax+0x38ac]
  63ee5a:	41 89 03             	mov    DWORD PTR [r11],eax
  63ee5d:	41 c7 43 04 38 00 00 	mov    DWORD PTR [r11+0x4],0x38
  63ee64:	00 
  63ee65:	41 c7 43 08 00 00 00 	mov    DWORD PTR [r11+0x8],0x0
  63ee6c:	00 
  63ee6d:	41 c7 43 0c 00 00 00 	mov    DWORD PTR [r11+0xc],0x0
  63ee74:	00 
  63ee75:	48 8b 84 24 b0 00 00 	mov    rax,QWORD PTR [rsp+0xb0]
  63ee7c:	00 
  63ee7d:	49 89 43 10          	mov    QWORD PTR [r11+0x10],rax
  63ee81:	8b 84 24 b8 00 00 00 	mov    eax,DWORD PTR [rsp+0xb8]
  63ee88:	41 89 43 18          	mov    DWORD PTR [r11+0x18],eax
  63ee8c:	8b 84 24 c0 00 00 00 	mov    eax,DWORD PTR [rsp+0xc0]
  63ee93:	41 89 43 1c          	mov    DWORD PTR [r11+0x1c],eax
  63ee97:	8b 84 24 c8 00 00 00 	mov    eax,DWORD PTR [rsp+0xc8]
  63ee9e:	41 89 43 20          	mov    DWORD PTR [r11+0x20],eax
  63eea2:	8b 84 24 d0 00 00 00 	mov    eax,DWORD PTR [rsp+0xd0]
  63eea9:	41 89 43 24          	mov    DWORD PTR [r11+0x24],eax
  63eead:	8b 84 24 d8 00 00 00 	mov    eax,DWORD PTR [rsp+0xd8]
  63eeb4:	41 89 43 28          	mov    DWORD PTR [r11+0x28],eax
  63eeb8:	8b 84 24 e0 00 00 00 	mov    eax,DWORD PTR [rsp+0xe0]
  63eebf:	41 89 43 2c          	mov    DWORD PTR [r11+0x2c],eax
  63eec3:	8b 84 24 e8 00 00 00 	mov    eax,DWORD PTR [rsp+0xe8]
  63eeca:	41 89 43 30          	mov    DWORD PTR [r11+0x30],eax
  63eece:	8b 84 24 f0 00 00 00 	mov    eax,DWORD PTR [rsp+0xf0]
  63eed5:	41 89 43 34          	mov    DWORD PTR [r11+0x34],eax
  63eed9:	41 89 09             	mov    DWORD PTR [r9],ecx
  63eedc:	41 c7 41 04 38 00 00 	mov    DWORD PTR [r9+0x4],0x38
  63eee3:	00 
  63eee4:	41 c7 41 08 00 00 00 	mov    DWORD PTR [r9+0x8],0x0
  63eeeb:	00 
  63eeec:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
  63eef3:	41 89 ca             	mov    r10d,ecx
  63eef6:	41 83 c2 38          	add    r10d,0x38
  63eefa:	44 89 10             	mov    DWORD PTR [rax],r10d
  63eefd:	41 c7 41 0c 00 00 01 	mov    DWORD PTR [r9+0xc],0x10000
  63ef04:	00 
  63ef05:	83 c2 01             	add    edx,0x1
  63ef08:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
  63ef0f:	41 89 52 04          	mov    DWORD PTR [r10+0x4],edx
  63ef13:	41 83 7a 18 00       	cmp    DWORD PTR [r10+0x18],0x0
  63ef18:	0f 84 11 00 00 00    	je     0x63ef2f
  63ef1e:	4d 8b 90 98 00 00 00 	mov    r10,QWORD PTR [r8+0x98]
  63ef25:	49 8b 02             	mov    rax,QWORD PTR [r10]
  63ef28:	48 83 c0 01          	add    rax,0x1
  63ef2c:	49 89 02             	mov    QWORD PTR [r10],rax
  63ef2f:	89 f0                	mov    eax,esi
  63ef31:	d1 e0                	shl    eax,1
  63ef33:	48 89 84 24 b0 00 00 	mov    QWORD PTR [rsp+0xb0],rax
  63ef3a:	00 
  63ef3b:	e9 05 00 00 00       	jmp    0x63ef45
  63ef40:	b8 00 00 00 00       	mov    eax,0x0
  63ef45:	85 c0                	test   eax,eax
  63ef47:	41 5b                	pop    r11
  63ef49:	41 5a                	pop    r10
  63ef4b:	41 59                	pop    r9
  63ef4d:	41 58                	pop    r8
  63ef4f:	0f 85 e4 00 00 00    	jne    0x63f039
  63ef55:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  63ef59:	48 8b 84 24 90 00 00 	mov    rax,QWORD PTR [rsp+0x90]
  63ef60:	00 
  63ef61:	49 89 40 48          	mov    QWORD PTR [r8+0x48],rax
  63ef65:	48 8b 84 24 98 00 00 	mov    rax,QWORD PTR [rsp+0x98]
  63ef6c:	00 
  63ef6d:	49 89 40 50          	mov    QWORD PTR [r8+0x50],rax
  63ef71:	48 8b 84 24 a0 00 00 	mov    rax,QWORD PTR [rsp+0xa0]
  63ef78:	00 
  63ef79:	49 89 40 58          	mov    QWORD PTR [r8+0x58],rax
  63ef7d:	48 8b 84 24 a8 00 00 	mov    rax,QWORD PTR [rsp+0xa8]
  63ef84:	00 
  63ef85:	49 89 40 60          	mov    QWORD PTR [r8+0x60],rax
  63ef89:	48 8b 84 24 b0 00 00 	mov    rax,QWORD PTR [rsp+0xb0]
  63ef90:	00 
  63ef91:	49 89 40 68          	mov    QWORD PTR [r8+0x68],rax
  63ef95:	8b 84 24 b8 00 00 00 	mov    eax,DWORD PTR [rsp+0xb8]
  63ef9c:	49 89 40 70          	mov    QWORD PTR [r8+0x70],rax
  63efa0:	48 8b 84 24 c0 00 00 	mov    rax,QWORD PTR [rsp+0xc0]
  63efa7:	00 
  63efa8:	49 89 40 78          	mov    QWORD PTR [r8+0x78],rax
  63efac:	8b 84 24 c8 00 00 00 	mov    eax,DWORD PTR [rsp+0xc8]
  63efb3:	49 89 80 80 00 00 00 	mov    QWORD PTR [r8+0x80],rax
  63efba:	8b 84 24 d0 00 00 00 	mov    eax,DWORD PTR [rsp+0xd0]
  63efc1:	49 89 80 88 00 00 00 	mov    QWORD PTR [r8+0x88],rax
  63efc8:	8b 84 24 d8 00 00 00 	mov    eax,DWORD PTR [rsp+0xd8]
  63efcf:	49 89 80 90 00 00 00 	mov    QWORD PTR [r8+0x90],rax
  63efd6:	4c 89 64 24 10       	mov    QWORD PTR [rsp+0x10],r12
  63efdb:	4c 89 6c 24 18       	mov    QWORD PTR [rsp+0x18],r13
  63efe0:	4c 89 4c 24 20       	mov    QWORD PTR [rsp+0x20],r9
  63efe5:	4c 89 54 24 28       	mov    QWORD PTR [rsp+0x28],r10
  63efea:	4c 89 5c 24 30       	mov    QWORD PTR [rsp+0x30],r11
  63efef:	48 89 6c 24 38       	mov    QWORD PTR [rsp+0x38],rbp
  63eff4:	41 c7 40 40 0b 16 16 	mov    DWORD PTR [r8+0x40],0x4016160b
  63effb:	40 
  63effc:	41 c7 40 44 0a 00 01 	mov    DWORD PTR [r8+0x44],0x1000a
  63f003:	00 
  63f004:	41 ff 50 38          	call   QWORD PTR [r8+0x38]
  63f008:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
  63f00c:	49 8b 80 48 02 00 00 	mov    rax,QWORD PTR [r8+0x248]
  63f013:	48 89 84 24 90 00 00 	mov    QWORD PTR [rsp+0x90],rax
  63f01a:	00 
  63f01b:	4c 8b 64 24 10       	mov    r12,QWORD PTR [rsp+0x10]
  63f020:	4c 8b 6c 24 18       	mov    r13,QWORD PTR [rsp+0x18]
  63f025:	4c 8b 4c 24 20       	mov    r9,QWORD PTR [rsp+0x20]
  63f02a:	4c 8b 54 24 28       	mov    r10,QWORD PTR [rsp+0x28]
  63f02f:	4c 8b 5c 24 30       	mov    r11,QWORD PTR [rsp+0x30]
  63f034:	48 8b 6c 24 38       	mov    rbp,QWORD PTR [rsp+0x38]
  63f039:	48 8b 84 24 90 00 00 	mov    rax,QWORD PTR [rsp+0x90]
  63f040:	00 
  63f041:	48 81 c4 e8 00 00 00 	add    rsp,0xe8
  63f048:	c3                   	ret
  63f049:	41 51                	push   r9
  63f04b:	41 52                	push   r10
  63f04d:	41 53                	push   r11
  63f04f:	49 89 c2             	mov    r10,rax
  63f052:	49 c1 ea 20          	shr    r10,0x20
  63f056:	4d 85 d2             	test   r10,r10
  63f059:	0f 85 f3 00 00 00    	jne    0x63f152
  63f05f:	85 c0                	test   eax,eax
  63f061:	0f 85 0d 00 00 00    	jne    0x63f074
  63f067:	85 f6                	test   esi,esi
  63f069:	0f 84 e3 00 00 00    	je     0x63f152
  63f06f:	e9 e9 00 00 00       	jmp    0x63f15d
  63f074:	89 ce                	mov    esi,ecx
  63f076:	41 89 c2             	mov    r10d,eax
  63f079:	41 83 e2 01          	and    r10d,0x1
  63f07d:	45 85 d2             	test   r10d,r10d
  63f080:	0f 85 cc 00 00 00    	jne    0x63f152
  63f086:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  63f08d:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  63f091:	48 6b d2 04          	imul   rdx,rdx,0x4
  63f095:	41 8b 14 12          	mov    edx,DWORD PTR [r10+rdx*1]
  63f099:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  63f09d:	d1 e8                	shr    eax,1
  63f09f:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  63f0a3:	0f 83 a9 00 00 00    	jae    0x63f152
  63f0a9:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  63f0ad:	48 c1 e0 04          	shl    rax,0x4
  63f0b1:	49 01 c1             	add    r9,rax
  63f0b4:	45 0f b6 54 21 0e    	movzx  r10d,BYTE PTR [r9+riz*1+0xe]
  63f0ba:	45 85 d2             	test   r10d,r10d
  63f0bd:	0f 84 8f 00 00 00    	je     0x63f152
  63f0c3:	41 83 fa 04          	cmp    r10d,0x4
  63f0c7:	0f 87 85 00 00 00    	ja     0x63f152
  63f0cd:	4d 6b d2 10          	imul   r10,r10,0x10
  63f0d1:	4d 8d 40 18          	lea    r8,[r8+0x18]
  63f0d5:	4d 01 d0             	add    r8,r10
  63f0d8:	4d 8b 18             	mov    r11,QWORD PTR [r8]
  63f0db:	45 8b 40 08          	mov    r8d,DWORD PTR [r8+0x8]
  63f0df:	41 8b 01             	mov    eax,DWORD PTR [r9]
  63f0e2:	44 39 c0             	cmp    eax,r8d
  63f0e5:	0f 87 67 00 00 00    	ja     0x63f152
  63f0eb:	41 29 c0             	sub    r8d,eax
  63f0ee:	41 8b 49 04          	mov    ecx,DWORD PTR [r9+0x4]
  63f0f2:	44 39 c1             	cmp    ecx,r8d
  63f0f5:	0f 87 57 00 00 00    	ja     0x63f152
  63f0fb:	83 f9 10             	cmp    ecx,0x10
  63f0fe:	0f 82 4e 00 00 00    	jb     0x63f152
  63f104:	49 01 c3             	add    r11,rax
  63f107:	41 8b 0b             	mov    ecx,DWORD PTR [r11]
  63f10a:	39 d1                	cmp    ecx,edx
  63f10c:	0f 85 40 00 00 00    	jne    0x63f152
  63f112:	45 8b 53 08          	mov    r10d,DWORD PTR [r11+0x8]
  63f116:	44 39 d6             	cmp    esi,r10d
  63f119:	0f 83 49 00 00 00    	jae    0x63f168
  63f11f:	48 6b f6 04          	imul   rsi,rsi,0x4
  63f123:	45 8b 53 04          	mov    r10d,DWORD PTR [r11+0x4]
  63f127:	49 89 f0             	mov    r8,rsi
  63f12a:	49 83 c0 14          	add    r8,0x14
  63f12e:	41 8b 51 04          	mov    edx,DWORD PTR [r9+0x4]
  63f132:	49 39 d0             	cmp    r8,rdx
  63f135:	0f 87 17 00 00 00    	ja     0x63f152
  63f13b:	4d 39 d0             	cmp    r8,r10
  63f13e:	0f 87 0e 00 00 00    	ja     0x63f152
  63f144:	49 8d 43 10          	lea    rax,[r11+0x10]
  63f148:	48 01 f0             	add    rax,rsi
  63f14b:	41 5b                	pop    r11
  63f14d:	41 5a                	pop    r10
  63f14f:	41 59                	pop    r9
  63f151:	c3                   	ret
  63f152:	41 5b                	pop    r11
  63f154:	41 5a                	pop    r10
  63f156:	41 59                	pop    r9
  63f158:	e9 e5 01 00 00       	jmp    0x63f342
  63f15d:	41 5b                	pop    r11
  63f15f:	41 5a                	pop    r10
  63f161:	41 59                	pop    r9
  63f163:	e9 b2 01 00 00       	jmp    0x63f31a
  63f168:	41 5b                	pop    r11
  63f16a:	41 5a                	pop    r10
  63f16c:	41 59                	pop    r9
  63f16e:	e9 4d 01 00 00       	jmp    0x63f2c0
  63f173:	41 51                	push   r9
  63f175:	41 52                	push   r10
  63f177:	41 53                	push   r11
  63f179:	89 cf                	mov    edi,ecx
  63f17b:	49 89 c2             	mov    r10,rax
  63f17e:	49 c1 ea 20          	shr    r10,0x20
  63f182:	4d 85 d2             	test   r10,r10
  63f185:	0f 85 c5 00 00 00    	jne    0x63f250
  63f18b:	85 c0                	test   eax,eax
  63f18d:	0f 85 0d 00 00 00    	jne    0x63f1a0
  63f193:	85 f6                	test   esi,esi
  63f195:	0f 84 b5 00 00 00    	je     0x63f250
  63f19b:	e9 bb 00 00 00       	jmp    0x63f25b
  63f1a0:	41 89 c2             	mov    r10d,eax
  63f1a3:	41 83 e2 01          	and    r10d,0x1
  63f1a7:	45 85 d2             	test   r10d,r10d
  63f1aa:	0f 85 a0 00 00 00    	jne    0x63f250
  63f1b0:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  63f1b7:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  63f1bb:	48 6b d2 04          	imul   rdx,rdx,0x4
  63f1bf:	41 8b 14 12          	mov    edx,DWORD PTR [r10+rdx*1]
  63f1c3:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  63f1c7:	d1 e8                	shr    eax,1
  63f1c9:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  63f1cd:	0f 83 7d 00 00 00    	jae    0x63f250
  63f1d3:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  63f1d7:	48 c1 e0 04          	shl    rax,0x4
  63f1db:	49 01 c1             	add    r9,rax
  63f1de:	45 0f b6 54 21 0e    	movzx  r10d,BYTE PTR [r9+riz*1+0xe]
  63f1e4:	45 85 d2             	test   r10d,r10d
  63f1e7:	0f 84 63 00 00 00    	je     0x63f250
  63f1ed:	41 83 fa 04          	cmp    r10d,0x4
  63f1f1:	0f 87 59 00 00 00    	ja     0x63f250
  63f1f7:	41 c1 e2 04          	shl    r10d,0x4
  63f1fb:	4f 8b 5c 10 18       	mov    r11,QWORD PTR [r8+r10*1+0x18]
  63f200:	47 8b 44 10 20       	mov    r8d,DWORD PTR [r8+r10*1+0x20]
  63f205:	41 8b 01             	mov    eax,DWORD PTR [r9]
  63f208:	44 39 c0             	cmp    eax,r8d
  63f20b:	0f 87 3f 00 00 00    	ja     0x63f250
  63f211:	41 29 c0             	sub    r8d,eax
  63f214:	41 8b 49 04          	mov    ecx,DWORD PTR [r9+0x4]
  63f218:	44 39 c1             	cmp    ecx,r8d
  63f21b:	0f 87 2f 00 00 00    	ja     0x63f250
  63f221:	39 f9                	cmp    ecx,edi
  63f223:	0f 82 27 00 00 00    	jb     0x63f250
  63f229:	49 01 c3             	add    r11,rax
  63f22c:	41 8b 0b             	mov    ecx,DWORD PTR [r11]
  63f22f:	39 d1                	cmp    ecx,edx
  63f231:	0f 85 19 00 00 00    	jne    0x63f250
  63f237:	41 8b 4b 04          	mov    ecx,DWORD PTR [r11+0x4]
  63f23b:	39 f9                	cmp    ecx,edi
  63f23d:	0f 82 0d 00 00 00    	jb     0x63f250
  63f243:	4c 89 de             	mov    rsi,r11
  63f246:	41 5b                	pop    r11
  63f248:	41 5a                	pop    r10
  63f24a:	41 59                	pop    r9
  63f24c:	48 89 f0             	mov    rax,rsi
  63f24f:	c3                   	ret
  63f250:	41 5b                	pop    r11
  63f252:	41 5a                	pop    r10
  63f254:	41 59                	pop    r9
  63f256:	e9 e7 00 00 00       	jmp    0x63f342
  63f25b:	41 5b                	pop    r11
  63f25d:	41 5a                	pop    r10
  63f25f:	41 59                	pop    r9
  63f261:	e9 b4 00 00 00       	jmp    0x63f31a
  63f266:	b8 13 00 00 00       	mov    eax,0x13
  63f26b:	e9 00 00 00 00       	jmp    0x63f270
  63f270:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  63f274:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  63f277:	44 89 36             	mov    DWORD PTR [rsi],r14d
  63f27a:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  63f27e:	c7 46 10 a9 01 00 00 	mov    DWORD PTR [rsi+0x10],0x1a9
  63f285:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  63f288:	c7 06 01 00 00 00    	mov    DWORD PTR [rsi],0x1
  63f28e:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  63f292:	c3                   	ret
  63f293:	b8 19 00 00 00       	mov    eax,0x19
  63f298:	e9 00 00 00 00       	jmp    0x63f29d
  63f29d:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  63f2a1:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  63f2a4:	44 89 36             	mov    DWORD PTR [rsi],r14d
  63f2a7:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  63f2ab:	c7 46 10 03 09 00 00 	mov    DWORD PTR [rsi+0x10],0x903
  63f2b2:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  63f2b5:	c7 06 01 00 00 00    	mov    DWORD PTR [rsi],0x1
  63f2bb:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  63f2bf:	c3                   	ret
  63f2c0:	b8 ff ff ff ff       	mov    eax,0xffffffff
  63f2c5:	e9 00 00 00 00       	jmp    0x63f2ca
  63f2ca:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  63f2ce:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  63f2d1:	44 89 36             	mov    DWORD PTR [rsi],r14d
  63f2d4:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  63f2d8:	c7 46 10 03 09 00 00 	mov    DWORD PTR [rsi+0x10],0x903
  63f2df:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  63f2e2:	c7 06 02 00 00 00    	mov    DWORD PTR [rsi],0x2
  63f2e8:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  63f2ec:	c3                   	ret
  63f2ed:	b8 00 00 00 00       	mov    eax,0x0
  63f2f2:	e9 00 00 00 00       	jmp    0x63f2f7
  63f2f7:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  63f2fb:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  63f2fe:	44 89 36             	mov    DWORD PTR [rsi],r14d
  63f301:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  63f305:	c7 46 10 03 09 00 00 	mov    DWORD PTR [rsi+0x10],0x903
  63f30c:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  63f30f:	c7 06 0d 00 00 00    	mov    DWORD PTR [rsi],0xd
  63f315:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  63f319:	c3                   	ret
  63f31a:	b8 ff ff ff ff       	mov    eax,0xffffffff
  63f31f:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  63f323:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  63f326:	44 89 36             	mov    DWORD PTR [rsi],r14d
  63f329:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  63f32d:	c7 46 10 03 09 00 00 	mov    DWORD PTR [rsi+0x10],0x903
  63f334:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  63f337:	c7 06 10 00 00 00    	mov    DWORD PTR [rsi],0x10
  63f33d:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  63f341:	c3                   	ret
  63f342:	b8 ff ff ff ff       	mov    eax,0xffffffff
  63f347:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  63f34b:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  63f34e:	44 89 36             	mov    DWORD PTR [rsi],r14d
  63f351:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  63f355:	c7 46 10 03 09 00 00 	mov    DWORD PTR [rsi+0x10],0x903
  63f35c:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  63f35f:	c7 06 12 00 00 00    	mov    DWORD PTR [rsi],0x12
  63f365:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  63f369:	c3                   	ret
