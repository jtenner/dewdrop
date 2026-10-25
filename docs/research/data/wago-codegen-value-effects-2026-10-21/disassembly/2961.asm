
.tmp/wago-next-gc-perf/post-read-regions-profile/profile/native-code.bin:     file format binary


Disassembly of section .data:

00000000009679a4 <.data+0x9679a4>:
  9679a4:	48 81 ec 98 00 00 00 	sub    rsp,0x98
  9679ab:	48 8b 73 b8          	mov    rsi,QWORD PTR [rbx-0x48]
  9679af:	48 39 f4             	cmp    rsp,rsi
  9679b2:	0f 82 5a 05 00 00    	jb     0x967f12
  9679b8:	48 89 c5             	mov    rbp,rax
  9679bb:	49 89 ca             	mov    r10,rcx
  9679be:	49 89 d3             	mov    r11,rdx
  9679c1:	31 c0                	xor    eax,eax
  9679c3:	45 31 c9             	xor    r9d,r9d
  9679c6:	45 31 e4             	xor    r12d,r12d
  9679c9:	45 31 ed             	xor    r13d,r13d
  9679cc:	4c 89 d7             	mov    rdi,r10
  9679cf:	48 89 f8             	mov    rax,rdi
  9679d2:	ba 3d 0d 00 00       	mov    edx,0xd3d
  9679d7:	b9 18 00 00 00       	mov    ecx,0x18
  9679dc:	be 00 00 00 00       	mov    esi,0x0
  9679e1:	e8 e4 03 00 00       	call   0x967dca
  9679e6:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  9679ea:	4c 89 df             	mov    rdi,r11
  9679ed:	48 89 7c 24 30       	mov    QWORD PTR [rsp+0x30],rdi
  9679f2:	48 89 84 24 80 00 00 	mov    QWORD PTR [rsp+0x80],rax
  9679f9:	00 
  9679fa:	48 8b 7c 24 30       	mov    rdi,QWORD PTR [rsp+0x30]
  9679ff:	48 89 f8             	mov    rax,rdi
  967a02:	ba a0 09 00 00       	mov    edx,0x9a0
  967a07:	b9 18 00 00 00       	mov    ecx,0x18
  967a0c:	be 00 00 00 00       	mov    esi,0x0
  967a11:	e8 b4 03 00 00       	call   0x967dca
  967a16:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  967a1a:	48 89 84 24 88 00 00 	mov    QWORD PTR [rsp+0x88],rax
  967a21:	00 
  967a22:	48 89 2c 24          	mov    QWORD PTR [rsp],rbp
  967a26:	4c 89 54 24 08       	mov    QWORD PTR [rsp+0x8],r10
  967a2b:	4c 89 5c 24 10       	mov    QWORD PTR [rsp+0x10],r11
  967a30:	44 89 4c 24 18       	mov    DWORD PTR [rsp+0x18],r9d
  967a35:	44 89 64 24 20       	mov    DWORD PTR [rsp+0x20],r12d
  967a3a:	44 89 6c 24 28       	mov    DWORD PTR [rsp+0x28],r13d
  967a3f:	8b bc 24 88 00 00 00 	mov    edi,DWORD PTR [rsp+0x88]
  967a46:	89 7c 24 40          	mov    DWORD PTR [rsp+0x40],edi
  967a4a:	8b bc 24 80 00 00 00 	mov    edi,DWORD PTR [rsp+0x80]
  967a51:	89 7c 24 38          	mov    DWORD PTR [rsp+0x38],edi
  967a55:	8b 7c 24 38          	mov    edi,DWORD PTR [rsp+0x38]
  967a59:	8b 74 24 40          	mov    esi,DWORD PTR [rsp+0x40]
  967a5d:	39 f7                	cmp    edi,esi
  967a5f:	0f 84 12 00 00 00    	je     0x967a77
  967a65:	bf 00 00 00 00       	mov    edi,0x0
  967a6a:	48 89 bc 24 80 00 00 	mov    QWORD PTR [rsp+0x80],rdi
  967a71:	00 
  967a72:	e9 1a 02 00 00       	jmp    0x967c91
  967a77:	41 b9 01 00 00 00    	mov    r9d,0x1
  967a7d:	41 bd 00 00 00 00    	mov    r13d,0x0
  967a83:	44 89 4c 24 18       	mov    DWORD PTR [rsp+0x18],r9d
  967a88:	44 89 6c 24 28       	mov    DWORD PTR [rsp+0x28],r13d
  967a8d:	66 0f 1f 84 00 00 00 	nop    WORD PTR [rax+rax*1+0x0]
  967a94:	00 00 
  967a96:	66 90                	xchg   ax,ax
  967a98:	45 89 ec             	mov    r12d,r13d
  967a9b:	4c 89 a4 24 80 00 00 	mov    QWORD PTR [rsp+0x80],r12
  967aa2:	00 
  967aa3:	4c 89 d7             	mov    rdi,r10
  967aa6:	48 89 f8             	mov    rax,rdi
  967aa9:	ba 3d 0d 00 00       	mov    edx,0xd3d
  967aae:	b9 18 00 00 00       	mov    ecx,0x18
  967ab3:	be 00 00 00 00       	mov    esi,0x0
  967ab8:	e8 0d 03 00 00       	call   0x967dca
  967abd:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  967ac1:	89 44 24 50          	mov    DWORD PTR [rsp+0x50],eax
  967ac5:	8b bc 24 80 00 00 00 	mov    edi,DWORD PTR [rsp+0x80]
  967acc:	89 7c 24 48          	mov    DWORD PTR [rsp+0x48],edi
  967ad0:	8b 7c 24 48          	mov    edi,DWORD PTR [rsp+0x48]
  967ad4:	8b 74 24 50          	mov    esi,DWORD PTR [rsp+0x50]
  967ad8:	44 89 64 24 20       	mov    DWORD PTR [rsp+0x20],r12d
  967add:	39 f7                	cmp    edi,esi
  967adf:	0f 83 9f 01 00 00    	jae    0x967c84
  967ae5:	48 89 ef             	mov    rdi,rbp
  967ae8:	48 89 f8             	mov    rax,rdi
  967aeb:	ba ba 10 00 00       	mov    edx,0x10ba
  967af0:	b9 18 00 00 00       	mov    ecx,0x18
  967af5:	be 00 00 00 00       	mov    esi,0x0
  967afa:	e8 cb 02 00 00       	call   0x967dca
  967aff:	8b 40 14             	mov    eax,DWORD PTR [rax+0x14]
  967b02:	48 89 84 24 80 00 00 	mov    QWORD PTR [rsp+0x80],rax
  967b09:	00 
  967b0a:	4c 89 d7             	mov    rdi,r10
  967b0d:	48 89 f8             	mov    rax,rdi
  967b10:	ba 3d 0d 00 00       	mov    edx,0xd3d
  967b15:	b9 14 00 00 00       	mov    ecx,0x14
  967b1a:	be 00 00 00 00       	mov    esi,0x0
  967b1f:	e8 a6 02 00 00       	call   0x967dca
  967b24:	8b 44 20 10          	mov    eax,DWORD PTR [rax+riz*1+0x10]
  967b28:	44 89 e7             	mov    edi,r12d
  967b2b:	89 7c 24 60          	mov    DWORD PTR [rsp+0x60],edi
  967b2f:	89 44 24 58          	mov    DWORD PTR [rsp+0x58],eax
  967b33:	8b 7c 24 58          	mov    edi,DWORD PTR [rsp+0x58]
  967b37:	8b 74 24 60          	mov    esi,DWORD PTR [rsp+0x60]
  967b3b:	01 f7                	add    edi,esi
  967b3d:	89 7c 24 70          	mov    DWORD PTR [rsp+0x70],edi
  967b41:	48 8b bc 24 80 00 00 	mov    rdi,QWORD PTR [rsp+0x80]
  967b48:	00 
  967b49:	48 89 7c 24 68       	mov    QWORD PTR [rsp+0x68],rdi
  967b4e:	8b 7c 24 70          	mov    edi,DWORD PTR [rsp+0x70]
  967b52:	48 89 bc 24 80 00 00 	mov    QWORD PTR [rsp+0x80],rdi
  967b59:	00 
  967b5a:	48 8b 7c 24 68       	mov    rdi,QWORD PTR [rsp+0x68]
  967b5f:	48 89 f8             	mov    rax,rdi
  967b62:	ba a0 09 00 00       	mov    edx,0x9a0
  967b67:	b9 18 00 00 00       	mov    ecx,0x18
  967b6c:	be 00 00 00 00       	mov    esi,0x0
  967b71:	e8 54 02 00 00       	call   0x967dca
  967b76:	48 89 44 24 78       	mov    QWORD PTR [rsp+0x78],rax
  967b7b:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  967b7f:	8b bc 24 80 00 00 00 	mov    edi,DWORD PTR [rsp+0x80]
  967b86:	39 c7                	cmp    edi,eax
  967b88:	0f 82 05 00 00 00    	jb     0x967b93
  967b8e:	e9 2a 03 00 00       	jmp    0x967ebd
  967b93:	48 8b 7c 24 78       	mov    rdi,QWORD PTR [rsp+0x78]
  967b98:	8b 7f 10             	mov    edi,DWORD PTR [rdi+0x10]
  967b9b:	48 89 f8             	mov    rax,rdi
  967b9e:	8b 7c 24 70          	mov    edi,DWORD PTR [rsp+0x70]
  967ba2:	89 f9                	mov    ecx,edi
  967ba4:	ba 3a 23 00 00       	mov    edx,0x233a
  967ba9:	be 00 00 00 00       	mov    esi,0x0
  967bae:	e8 ed 00 00 00       	call   0x967ca0
  967bb3:	8b 04 20             	mov    eax,DWORD PTR [rax+riz*1]
  967bb6:	48 89 84 24 80 00 00 	mov    QWORD PTR [rsp+0x80],rax
  967bbd:	00 
  967bbe:	44 89 e7             	mov    edi,r12d
  967bc1:	89 7c 24 70          	mov    DWORD PTR [rsp+0x70],edi
  967bc5:	4c 89 df             	mov    rdi,r11
  967bc8:	48 89 7c 24 68       	mov    QWORD PTR [rsp+0x68],rdi
  967bcd:	8b 7c 24 70          	mov    edi,DWORD PTR [rsp+0x70]
  967bd1:	48 89 bc 24 88 00 00 	mov    QWORD PTR [rsp+0x88],rdi
  967bd8:	00 
  967bd9:	48 8b 7c 24 68       	mov    rdi,QWORD PTR [rsp+0x68]
  967bde:	48 89 f8             	mov    rax,rdi
  967be1:	ba a0 09 00 00       	mov    edx,0x9a0
  967be6:	b9 18 00 00 00       	mov    ecx,0x18
  967beb:	be 00 00 00 00       	mov    esi,0x0
  967bf0:	e8 d5 01 00 00       	call   0x967dca
  967bf5:	48 89 44 24 78       	mov    QWORD PTR [rsp+0x78],rax
  967bfa:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  967bfe:	8b bc 24 88 00 00 00 	mov    edi,DWORD PTR [rsp+0x88]
  967c05:	39 c7                	cmp    edi,eax
  967c07:	0f 82 05 00 00 00    	jb     0x967c12
  967c0d:	e9 ab 02 00 00       	jmp    0x967ebd
  967c12:	48 8b 7c 24 78       	mov    rdi,QWORD PTR [rsp+0x78]
  967c17:	8b 7f 10             	mov    edi,DWORD PTR [rdi+0x10]
  967c1a:	48 89 f8             	mov    rax,rdi
  967c1d:	8b 7c 24 70          	mov    edi,DWORD PTR [rsp+0x70]
  967c21:	89 f9                	mov    ecx,edi
  967c23:	ba 3a 23 00 00       	mov    edx,0x233a
  967c28:	be 00 00 00 00       	mov    esi,0x0
  967c2d:	e8 6e 00 00 00       	call   0x967ca0
  967c32:	8b 04 20             	mov    eax,DWORD PTR [rax+riz*1]
  967c35:	48 89 84 24 88 00 00 	mov    QWORD PTR [rsp+0x88],rax
  967c3c:	00 
  967c3d:	8b bc 24 88 00 00 00 	mov    edi,DWORD PTR [rsp+0x88]
  967c44:	89 7c 24 40          	mov    DWORD PTR [rsp+0x40],edi
  967c48:	8b bc 24 80 00 00 00 	mov    edi,DWORD PTR [rsp+0x80]
  967c4f:	89 7c 24 38          	mov    DWORD PTR [rsp+0x38],edi
  967c53:	8b 7c 24 38          	mov    edi,DWORD PTR [rsp+0x38]
  967c57:	8b 74 24 40          	mov    esi,DWORD PTR [rsp+0x40]
  967c5b:	39 f7                	cmp    edi,esi
  967c5d:	0f 84 10 00 00 00    	je     0x967c73
  967c63:	41 b9 00 00 00 00    	mov    r9d,0x0
  967c69:	44 89 4c 24 18       	mov    DWORD PTR [rsp+0x18],r9d
  967c6e:	e9 00 00 00 00       	jmp    0x967c73
  967c73:	45 89 e5             	mov    r13d,r12d
  967c76:	41 83 c5 01          	add    r13d,0x1
  967c7a:	44 89 6c 24 28       	mov    DWORD PTR [rsp+0x28],r13d
  967c7f:	e9 14 fe ff ff       	jmp    0x967a98
  967c84:	e9 00 00 00 00       	jmp    0x967c89
  967c89:	4c 89 8c 24 80 00 00 	mov    QWORD PTR [rsp+0x80],r9
  967c90:	00 
  967c91:	8b 84 24 80 00 00 00 	mov    eax,DWORD PTR [rsp+0x80]
  967c98:	48 81 c4 98 00 00 00 	add    rsp,0x98
  967c9f:	c3                   	ret
  967ca0:	41 51                	push   r9
  967ca2:	41 52                	push   r10
  967ca4:	41 53                	push   r11
  967ca6:	49 89 c2             	mov    r10,rax
  967ca9:	49 c1 ea 20          	shr    r10,0x20
  967cad:	4d 85 d2             	test   r10,r10
  967cb0:	0f 85 f3 00 00 00    	jne    0x967da9
  967cb6:	85 c0                	test   eax,eax
  967cb8:	0f 85 0d 00 00 00    	jne    0x967ccb
  967cbe:	85 f6                	test   esi,esi
  967cc0:	0f 84 e3 00 00 00    	je     0x967da9
  967cc6:	e9 e9 00 00 00       	jmp    0x967db4
  967ccb:	89 ce                	mov    esi,ecx
  967ccd:	41 89 c2             	mov    r10d,eax
  967cd0:	41 83 e2 01          	and    r10d,0x1
  967cd4:	45 85 d2             	test   r10d,r10d
  967cd7:	0f 85 cc 00 00 00    	jne    0x967da9
  967cdd:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  967ce4:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  967ce8:	48 6b d2 04          	imul   rdx,rdx,0x4
  967cec:	41 8b 14 12          	mov    edx,DWORD PTR [r10+rdx*1]
  967cf0:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  967cf4:	d1 e8                	shr    eax,1
  967cf6:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  967cfa:	0f 83 a9 00 00 00    	jae    0x967da9
  967d00:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  967d04:	48 c1 e0 04          	shl    rax,0x4
  967d08:	49 01 c1             	add    r9,rax
  967d0b:	45 0f b6 54 21 0e    	movzx  r10d,BYTE PTR [r9+riz*1+0xe]
  967d11:	45 85 d2             	test   r10d,r10d
  967d14:	0f 84 8f 00 00 00    	je     0x967da9
  967d1a:	41 83 fa 04          	cmp    r10d,0x4
  967d1e:	0f 87 85 00 00 00    	ja     0x967da9
  967d24:	4d 6b d2 10          	imul   r10,r10,0x10
  967d28:	4d 8d 40 18          	lea    r8,[r8+0x18]
  967d2c:	4d 01 d0             	add    r8,r10
  967d2f:	4d 8b 18             	mov    r11,QWORD PTR [r8]
  967d32:	45 8b 40 08          	mov    r8d,DWORD PTR [r8+0x8]
  967d36:	41 8b 01             	mov    eax,DWORD PTR [r9]
  967d39:	44 39 c0             	cmp    eax,r8d
  967d3c:	0f 87 67 00 00 00    	ja     0x967da9
  967d42:	41 29 c0             	sub    r8d,eax
  967d45:	41 8b 49 04          	mov    ecx,DWORD PTR [r9+0x4]
  967d49:	44 39 c1             	cmp    ecx,r8d
  967d4c:	0f 87 57 00 00 00    	ja     0x967da9
  967d52:	83 f9 10             	cmp    ecx,0x10
  967d55:	0f 82 4e 00 00 00    	jb     0x967da9
  967d5b:	49 01 c3             	add    r11,rax
  967d5e:	41 8b 0b             	mov    ecx,DWORD PTR [r11]
  967d61:	39 d1                	cmp    ecx,edx
  967d63:	0f 85 40 00 00 00    	jne    0x967da9
  967d69:	45 8b 53 08          	mov    r10d,DWORD PTR [r11+0x8]
  967d6d:	44 39 d6             	cmp    esi,r10d
  967d70:	0f 83 49 00 00 00    	jae    0x967dbf
  967d76:	48 6b f6 04          	imul   rsi,rsi,0x4
  967d7a:	45 8b 53 04          	mov    r10d,DWORD PTR [r11+0x4]
  967d7e:	49 89 f0             	mov    r8,rsi
  967d81:	49 83 c0 14          	add    r8,0x14
  967d85:	41 8b 51 04          	mov    edx,DWORD PTR [r9+0x4]
  967d89:	49 39 d0             	cmp    r8,rdx
  967d8c:	0f 87 17 00 00 00    	ja     0x967da9
  967d92:	4d 39 d0             	cmp    r8,r10
  967d95:	0f 87 0e 00 00 00    	ja     0x967da9
  967d9b:	49 8d 43 10          	lea    rax,[r11+0x10]
  967d9f:	48 01 f0             	add    rax,rsi
  967da2:	41 5b                	pop    r11
  967da4:	41 5a                	pop    r10
  967da6:	41 59                	pop    r9
  967da8:	c3                   	ret
  967da9:	41 5b                	pop    r11
  967dab:	41 5a                	pop    r10
  967dad:	41 59                	pop    r9
  967daf:	e9 b3 01 00 00       	jmp    0x967f67
  967db4:	41 5b                	pop    r11
  967db6:	41 5a                	pop    r10
  967db8:	41 59                	pop    r9
  967dba:	e9 80 01 00 00       	jmp    0x967f3f
  967dbf:	41 5b                	pop    r11
  967dc1:	41 5a                	pop    r10
  967dc3:	41 59                	pop    r9
  967dc5:	e9 1b 01 00 00       	jmp    0x967ee5
  967dca:	41 51                	push   r9
  967dcc:	41 52                	push   r10
  967dce:	41 53                	push   r11
  967dd0:	89 cf                	mov    edi,ecx
  967dd2:	49 89 c2             	mov    r10,rax
  967dd5:	49 c1 ea 20          	shr    r10,0x20
  967dd9:	4d 85 d2             	test   r10,r10
  967ddc:	0f 85 c5 00 00 00    	jne    0x967ea7
  967de2:	85 c0                	test   eax,eax
  967de4:	0f 85 0d 00 00 00    	jne    0x967df7
  967dea:	85 f6                	test   esi,esi
  967dec:	0f 84 b5 00 00 00    	je     0x967ea7
  967df2:	e9 bb 00 00 00       	jmp    0x967eb2
  967df7:	41 89 c2             	mov    r10d,eax
  967dfa:	41 83 e2 01          	and    r10d,0x1
  967dfe:	45 85 d2             	test   r10d,r10d
  967e01:	0f 85 a0 00 00 00    	jne    0x967ea7
  967e07:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  967e0e:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  967e12:	48 6b d2 04          	imul   rdx,rdx,0x4
  967e16:	41 8b 14 12          	mov    edx,DWORD PTR [r10+rdx*1]
  967e1a:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  967e1e:	d1 e8                	shr    eax,1
  967e20:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  967e24:	0f 83 7d 00 00 00    	jae    0x967ea7
  967e2a:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  967e2e:	48 c1 e0 04          	shl    rax,0x4
  967e32:	49 01 c1             	add    r9,rax
  967e35:	45 0f b6 54 21 0e    	movzx  r10d,BYTE PTR [r9+riz*1+0xe]
  967e3b:	45 85 d2             	test   r10d,r10d
  967e3e:	0f 84 63 00 00 00    	je     0x967ea7
  967e44:	41 83 fa 04          	cmp    r10d,0x4
  967e48:	0f 87 59 00 00 00    	ja     0x967ea7
  967e4e:	41 c1 e2 04          	shl    r10d,0x4
  967e52:	4f 8b 5c 10 18       	mov    r11,QWORD PTR [r8+r10*1+0x18]
  967e57:	47 8b 44 10 20       	mov    r8d,DWORD PTR [r8+r10*1+0x20]
  967e5c:	41 8b 01             	mov    eax,DWORD PTR [r9]
  967e5f:	44 39 c0             	cmp    eax,r8d
  967e62:	0f 87 3f 00 00 00    	ja     0x967ea7
  967e68:	41 29 c0             	sub    r8d,eax
  967e6b:	41 8b 49 04          	mov    ecx,DWORD PTR [r9+0x4]
  967e6f:	44 39 c1             	cmp    ecx,r8d
  967e72:	0f 87 2f 00 00 00    	ja     0x967ea7
  967e78:	39 f9                	cmp    ecx,edi
  967e7a:	0f 82 27 00 00 00    	jb     0x967ea7
  967e80:	49 01 c3             	add    r11,rax
  967e83:	41 8b 0b             	mov    ecx,DWORD PTR [r11]
  967e86:	39 d1                	cmp    ecx,edx
  967e88:	0f 85 19 00 00 00    	jne    0x967ea7
  967e8e:	41 8b 4b 04          	mov    ecx,DWORD PTR [r11+0x4]
  967e92:	39 f9                	cmp    ecx,edi
  967e94:	0f 82 0d 00 00 00    	jb     0x967ea7
  967e9a:	4c 89 de             	mov    rsi,r11
  967e9d:	41 5b                	pop    r11
  967e9f:	41 5a                	pop    r10
  967ea1:	41 59                	pop    r9
  967ea3:	48 89 f0             	mov    rax,rsi
  967ea6:	c3                   	ret
  967ea7:	41 5b                	pop    r11
  967ea9:	41 5a                	pop    r10
  967eab:	41 59                	pop    r9
  967ead:	e9 b5 00 00 00       	jmp    0x967f67
  967eb2:	41 5b                	pop    r11
  967eb4:	41 5a                	pop    r10
  967eb6:	41 59                	pop    r9
  967eb8:	e9 82 00 00 00       	jmp    0x967f3f
  967ebd:	b8 ff ff ff ff       	mov    eax,0xffffffff
  967ec2:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  967ec6:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  967ec9:	44 89 36             	mov    DWORD PTR [rsi],r14d
  967ecc:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  967ed0:	c7 46 10 c2 01 00 00 	mov    DWORD PTR [rsi+0x10],0x1c2
  967ed7:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  967eda:	c7 06 01 00 00 00    	mov    DWORD PTR [rsi],0x1
  967ee0:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  967ee4:	c3                   	ret
  967ee5:	b8 ff ff ff ff       	mov    eax,0xffffffff
  967eea:	e9 00 00 00 00       	jmp    0x967eef
  967eef:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  967ef3:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  967ef6:	44 89 36             	mov    DWORD PTR [rsi],r14d
  967ef9:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  967efd:	c7 46 10 92 0b 00 00 	mov    DWORD PTR [rsi+0x10],0xb92
  967f04:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  967f07:	c7 06 02 00 00 00    	mov    DWORD PTR [rsi],0x2
  967f0d:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  967f11:	c3                   	ret
  967f12:	b8 00 00 00 00       	mov    eax,0x0
  967f17:	e9 00 00 00 00       	jmp    0x967f1c
  967f1c:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  967f20:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  967f23:	44 89 36             	mov    DWORD PTR [rsi],r14d
  967f26:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  967f2a:	c7 46 10 92 0b 00 00 	mov    DWORD PTR [rsi+0x10],0xb92
  967f31:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  967f34:	c7 06 0d 00 00 00    	mov    DWORD PTR [rsi],0xd
  967f3a:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  967f3e:	c3                   	ret
  967f3f:	b8 ff ff ff ff       	mov    eax,0xffffffff
  967f44:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  967f48:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  967f4b:	44 89 36             	mov    DWORD PTR [rsi],r14d
  967f4e:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  967f52:	c7 46 10 92 0b 00 00 	mov    DWORD PTR [rsi+0x10],0xb92
  967f59:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  967f5c:	c7 06 10 00 00 00    	mov    DWORD PTR [rsi],0x10
  967f62:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  967f66:	c3                   	ret
  967f67:	b8 ff ff ff ff       	mov    eax,0xffffffff
  967f6c:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  967f70:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  967f73:	44 89 36             	mov    DWORD PTR [rsi],r14d
  967f76:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  967f7a:	c7 46 10 92 0b 00 00 	mov    DWORD PTR [rsi+0x10],0xb92
  967f81:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  967f84:	c7 06 12 00 00 00    	mov    DWORD PTR [rsi],0x12
  967f8a:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  967f8e:	c3                   	ret
