
.tmp/wago-next-gc-perf/post-read-regions-profile/profile/native-code.bin:     file format binary


Disassembly of section .data:

00000000006436e4 <.data+0x6436e4>:
  6436e4:	48 81 ec 98 00 00 00 	sub    rsp,0x98
  6436eb:	48 8b 73 b8          	mov    rsi,QWORD PTR [rbx-0x48]
  6436ef:	48 39 f4             	cmp    rsp,rsi
  6436f2:	0f 82 82 05 00 00    	jb     0x643c7a
  6436f8:	48 89 c5             	mov    rbp,rax
  6436fb:	49 89 ca             	mov    r10,rcx
  6436fe:	49 89 d3             	mov    r11,rdx
  643701:	31 c0                	xor    eax,eax
  643703:	45 31 c9             	xor    r9d,r9d
  643706:	45 31 e4             	xor    r12d,r12d
  643709:	45 31 ed             	xor    r13d,r13d
  64370c:	4c 89 d7             	mov    rdi,r10
  64370f:	48 89 f8             	mov    rax,rdi
  643712:	ba 3d 0d 00 00       	mov    edx,0xd3d
  643717:	b9 18 00 00 00       	mov    ecx,0x18
  64371c:	be 00 00 00 00       	mov    esi,0x0
  643721:	e8 0c 04 00 00       	call   0x643b32
  643726:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  64372a:	4c 89 df             	mov    rdi,r11
  64372d:	48 89 7c 24 30       	mov    QWORD PTR [rsp+0x30],rdi
  643732:	48 89 84 24 80 00 00 	mov    QWORD PTR [rsp+0x80],rax
  643739:	00 
  64373a:	48 8b 7c 24 30       	mov    rdi,QWORD PTR [rsp+0x30]
  64373f:	48 89 f8             	mov    rax,rdi
  643742:	ba a0 09 00 00       	mov    edx,0x9a0
  643747:	b9 18 00 00 00       	mov    ecx,0x18
  64374c:	be 00 00 00 00       	mov    esi,0x0
  643751:	e8 dc 03 00 00       	call   0x643b32
  643756:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  64375a:	48 89 84 24 88 00 00 	mov    QWORD PTR [rsp+0x88],rax
  643761:	00 
  643762:	48 89 2c 24          	mov    QWORD PTR [rsp],rbp
  643766:	4c 89 54 24 08       	mov    QWORD PTR [rsp+0x8],r10
  64376b:	4c 89 5c 24 10       	mov    QWORD PTR [rsp+0x10],r11
  643770:	44 89 4c 24 18       	mov    DWORD PTR [rsp+0x18],r9d
  643775:	44 89 64 24 20       	mov    DWORD PTR [rsp+0x20],r12d
  64377a:	44 89 6c 24 28       	mov    DWORD PTR [rsp+0x28],r13d
  64377f:	8b bc 24 88 00 00 00 	mov    edi,DWORD PTR [rsp+0x88]
  643786:	89 7c 24 40          	mov    DWORD PTR [rsp+0x40],edi
  64378a:	8b bc 24 80 00 00 00 	mov    edi,DWORD PTR [rsp+0x80]
  643791:	89 7c 24 38          	mov    DWORD PTR [rsp+0x38],edi
  643795:	8b 7c 24 38          	mov    edi,DWORD PTR [rsp+0x38]
  643799:	8b 74 24 40          	mov    esi,DWORD PTR [rsp+0x40]
  64379d:	39 f7                	cmp    edi,esi
  64379f:	0f 84 12 00 00 00    	je     0x6437b7
  6437a5:	bf 00 00 00 00       	mov    edi,0x0
  6437aa:	48 89 bc 24 80 00 00 	mov    QWORD PTR [rsp+0x80],rdi
  6437b1:	00 
  6437b2:	e9 42 02 00 00       	jmp    0x6439f9
  6437b7:	41 b9 01 00 00 00    	mov    r9d,0x1
  6437bd:	41 bd 00 00 00 00    	mov    r13d,0x0
  6437c3:	44 89 4c 24 18       	mov    DWORD PTR [rsp+0x18],r9d
  6437c8:	44 89 6c 24 28       	mov    DWORD PTR [rsp+0x28],r13d
  6437cd:	66 0f 1f 84 00 00 00 	nop    WORD PTR [rax+rax*1+0x0]
  6437d4:	00 00 
  6437d6:	66 90                	xchg   ax,ax
  6437d8:	45 89 ec             	mov    r12d,r13d
  6437db:	4c 89 a4 24 80 00 00 	mov    QWORD PTR [rsp+0x80],r12
  6437e2:	00 
  6437e3:	4c 89 d7             	mov    rdi,r10
  6437e6:	48 89 f8             	mov    rax,rdi
  6437e9:	ba 3d 0d 00 00       	mov    edx,0xd3d
  6437ee:	b9 18 00 00 00       	mov    ecx,0x18
  6437f3:	be 00 00 00 00       	mov    esi,0x0
  6437f8:	e8 35 03 00 00       	call   0x643b32
  6437fd:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  643801:	89 44 24 50          	mov    DWORD PTR [rsp+0x50],eax
  643805:	8b bc 24 80 00 00 00 	mov    edi,DWORD PTR [rsp+0x80]
  64380c:	89 7c 24 48          	mov    DWORD PTR [rsp+0x48],edi
  643810:	8b 7c 24 48          	mov    edi,DWORD PTR [rsp+0x48]
  643814:	8b 74 24 50          	mov    esi,DWORD PTR [rsp+0x50]
  643818:	44 89 64 24 20       	mov    DWORD PTR [rsp+0x20],r12d
  64381d:	39 f7                	cmp    edi,esi
  64381f:	0f 83 c7 01 00 00    	jae    0x6439ec
  643825:	48 89 ef             	mov    rdi,rbp
  643828:	48 89 f8             	mov    rax,rdi
  64382b:	ba 2f 0e 00 00       	mov    edx,0xe2f
  643830:	b9 14 00 00 00       	mov    ecx,0x14
  643835:	be 00 00 00 00       	mov    esi,0x0
  64383a:	e8 f3 02 00 00       	call   0x643b32
  64383f:	8b 40 10             	mov    eax,DWORD PTR [rax+0x10]
  643842:	ba b9 10 00 00       	mov    edx,0x10b9
  643847:	b9 20 00 00 00       	mov    ecx,0x20
  64384c:	be 00 00 00 00       	mov    esi,0x0
  643851:	e8 dc 02 00 00       	call   0x643b32
  643856:	8b 40 1c             	mov    eax,DWORD PTR [rax+0x1c]
  643859:	48 89 84 24 80 00 00 	mov    QWORD PTR [rsp+0x80],rax
  643860:	00 
  643861:	4c 89 d7             	mov    rdi,r10
  643864:	48 89 f8             	mov    rax,rdi
  643867:	ba 3d 0d 00 00       	mov    edx,0xd3d
  64386c:	b9 14 00 00 00       	mov    ecx,0x14
  643871:	be 00 00 00 00       	mov    esi,0x0
  643876:	e8 b7 02 00 00       	call   0x643b32
  64387b:	8b 44 20 10          	mov    eax,DWORD PTR [rax+riz*1+0x10]
  64387f:	44 89 e7             	mov    edi,r12d
  643882:	48 89 f9             	mov    rcx,rdi
  643885:	e8 b6 dc 9b ff       	call   0x1540
  64388a:	48 89 c7             	mov    rdi,rax
  64388d:	89 7c 24 60          	mov    DWORD PTR [rsp+0x60],edi
  643891:	48 8b bc 24 80 00 00 	mov    rdi,QWORD PTR [rsp+0x80]
  643898:	00 
  643899:	48 89 7c 24 58       	mov    QWORD PTR [rsp+0x58],rdi
  64389e:	8b 7c 24 60          	mov    edi,DWORD PTR [rsp+0x60]
  6438a2:	48 89 bc 24 80 00 00 	mov    QWORD PTR [rsp+0x80],rdi
  6438a9:	00 
  6438aa:	48 8b 7c 24 58       	mov    rdi,QWORD PTR [rsp+0x58]
  6438af:	48 89 f8             	mov    rax,rdi
  6438b2:	ba a0 09 00 00       	mov    edx,0x9a0
  6438b7:	b9 18 00 00 00       	mov    ecx,0x18
  6438bc:	be 00 00 00 00       	mov    esi,0x0
  6438c1:	e8 6c 02 00 00       	call   0x643b32
  6438c6:	48 89 44 24 68       	mov    QWORD PTR [rsp+0x68],rax
  6438cb:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  6438cf:	8b bc 24 80 00 00 00 	mov    edi,DWORD PTR [rsp+0x80]
  6438d6:	39 c7                	cmp    edi,eax
  6438d8:	0f 82 05 00 00 00    	jb     0x6438e3
  6438de:	e9 42 03 00 00       	jmp    0x643c25
  6438e3:	48 8b 7c 24 68       	mov    rdi,QWORD PTR [rsp+0x68]
  6438e8:	8b 7f 10             	mov    edi,DWORD PTR [rdi+0x10]
  6438eb:	48 89 f8             	mov    rax,rdi
  6438ee:	8b 7c 24 60          	mov    edi,DWORD PTR [rsp+0x60]
  6438f2:	89 f9                	mov    ecx,edi
  6438f4:	ba 3a 23 00 00       	mov    edx,0x233a
  6438f9:	be 00 00 00 00       	mov    esi,0x0
  6438fe:	e8 05 01 00 00       	call   0x643a08
  643903:	8b 04 20             	mov    eax,DWORD PTR [rax+riz*1]
  643906:	48 89 84 24 80 00 00 	mov    QWORD PTR [rsp+0x80],rax
  64390d:	00 
  64390e:	4c 8b 5c 24 10       	mov    r11,QWORD PTR [rsp+0x10]
  643913:	44 8b 64 24 20       	mov    r12d,DWORD PTR [rsp+0x20]
  643918:	44 89 e7             	mov    edi,r12d
  64391b:	89 7c 24 60          	mov    DWORD PTR [rsp+0x60],edi
  64391f:	4c 89 df             	mov    rdi,r11
  643922:	48 89 7c 24 58       	mov    QWORD PTR [rsp+0x58],rdi
  643927:	8b 7c 24 60          	mov    edi,DWORD PTR [rsp+0x60]
  64392b:	48 89 bc 24 88 00 00 	mov    QWORD PTR [rsp+0x88],rdi
  643932:	00 
  643933:	48 8b 7c 24 58       	mov    rdi,QWORD PTR [rsp+0x58]
  643938:	48 89 f8             	mov    rax,rdi
  64393b:	ba a0 09 00 00       	mov    edx,0x9a0
  643940:	b9 18 00 00 00       	mov    ecx,0x18
  643945:	be 00 00 00 00       	mov    esi,0x0
  64394a:	e8 e3 01 00 00       	call   0x643b32
  64394f:	48 89 44 24 68       	mov    QWORD PTR [rsp+0x68],rax
  643954:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
  643958:	8b bc 24 88 00 00 00 	mov    edi,DWORD PTR [rsp+0x88]
  64395f:	39 c7                	cmp    edi,eax
  643961:	0f 82 05 00 00 00    	jb     0x64396c
  643967:	e9 b9 02 00 00       	jmp    0x643c25
  64396c:	48 8b 7c 24 68       	mov    rdi,QWORD PTR [rsp+0x68]
  643971:	8b 7f 10             	mov    edi,DWORD PTR [rdi+0x10]
  643974:	48 89 f8             	mov    rax,rdi
  643977:	8b 7c 24 60          	mov    edi,DWORD PTR [rsp+0x60]
  64397b:	89 f9                	mov    ecx,edi
  64397d:	ba 3a 23 00 00       	mov    edx,0x233a
  643982:	be 00 00 00 00       	mov    esi,0x0
  643987:	e8 7c 00 00 00       	call   0x643a08
  64398c:	8b 04 20             	mov    eax,DWORD PTR [rax+riz*1]
  64398f:	48 89 84 24 88 00 00 	mov    QWORD PTR [rsp+0x88],rax
  643996:	00 
  643997:	8b bc 24 88 00 00 00 	mov    edi,DWORD PTR [rsp+0x88]
  64399e:	89 7c 24 40          	mov    DWORD PTR [rsp+0x40],edi
  6439a2:	8b bc 24 80 00 00 00 	mov    edi,DWORD PTR [rsp+0x80]
  6439a9:	89 7c 24 38          	mov    DWORD PTR [rsp+0x38],edi
  6439ad:	8b 7c 24 38          	mov    edi,DWORD PTR [rsp+0x38]
  6439b1:	8b 74 24 40          	mov    esi,DWORD PTR [rsp+0x40]
  6439b5:	39 f7                	cmp    edi,esi
  6439b7:	0f 84 10 00 00 00    	je     0x6439cd
  6439bd:	41 b9 00 00 00 00    	mov    r9d,0x0
  6439c3:	44 89 4c 24 18       	mov    DWORD PTR [rsp+0x18],r9d
  6439c8:	e9 05 00 00 00       	jmp    0x6439d2
  6439cd:	44 8b 4c 24 18       	mov    r9d,DWORD PTR [rsp+0x18]
  6439d2:	45 89 e5             	mov    r13d,r12d
  6439d5:	41 83 c5 01          	add    r13d,0x1
  6439d9:	44 89 6c 24 28       	mov    DWORD PTR [rsp+0x28],r13d
  6439de:	48 8b 2c 24          	mov    rbp,QWORD PTR [rsp]
  6439e2:	4c 8b 54 24 08       	mov    r10,QWORD PTR [rsp+0x8]
  6439e7:	e9 ec fd ff ff       	jmp    0x6437d8
  6439ec:	e9 00 00 00 00       	jmp    0x6439f1
  6439f1:	4c 89 8c 24 80 00 00 	mov    QWORD PTR [rsp+0x80],r9
  6439f8:	00 
  6439f9:	8b 84 24 80 00 00 00 	mov    eax,DWORD PTR [rsp+0x80]
  643a00:	48 81 c4 98 00 00 00 	add    rsp,0x98
  643a07:	c3                   	ret
  643a08:	41 51                	push   r9
  643a0a:	41 52                	push   r10
  643a0c:	41 53                	push   r11
  643a0e:	49 89 c2             	mov    r10,rax
  643a11:	49 c1 ea 20          	shr    r10,0x20
  643a15:	4d 85 d2             	test   r10,r10
  643a18:	0f 85 f3 00 00 00    	jne    0x643b11
  643a1e:	85 c0                	test   eax,eax
  643a20:	0f 85 0d 00 00 00    	jne    0x643a33
  643a26:	85 f6                	test   esi,esi
  643a28:	0f 84 e3 00 00 00    	je     0x643b11
  643a2e:	e9 e9 00 00 00       	jmp    0x643b1c
  643a33:	89 ce                	mov    esi,ecx
  643a35:	41 89 c2             	mov    r10d,eax
  643a38:	41 83 e2 01          	and    r10d,0x1
  643a3c:	45 85 d2             	test   r10d,r10d
  643a3f:	0f 85 cc 00 00 00    	jne    0x643b11
  643a45:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  643a4c:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  643a50:	48 6b d2 04          	imul   rdx,rdx,0x4
  643a54:	41 8b 14 12          	mov    edx,DWORD PTR [r10+rdx*1]
  643a58:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  643a5c:	d1 e8                	shr    eax,1
  643a5e:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  643a62:	0f 83 a9 00 00 00    	jae    0x643b11
  643a68:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  643a6c:	48 c1 e0 04          	shl    rax,0x4
  643a70:	49 01 c1             	add    r9,rax
  643a73:	45 0f b6 54 21 0e    	movzx  r10d,BYTE PTR [r9+riz*1+0xe]
  643a79:	45 85 d2             	test   r10d,r10d
  643a7c:	0f 84 8f 00 00 00    	je     0x643b11
  643a82:	41 83 fa 04          	cmp    r10d,0x4
  643a86:	0f 87 85 00 00 00    	ja     0x643b11
  643a8c:	4d 6b d2 10          	imul   r10,r10,0x10
  643a90:	4d 8d 40 18          	lea    r8,[r8+0x18]
  643a94:	4d 01 d0             	add    r8,r10
  643a97:	4d 8b 18             	mov    r11,QWORD PTR [r8]
  643a9a:	45 8b 40 08          	mov    r8d,DWORD PTR [r8+0x8]
  643a9e:	41 8b 01             	mov    eax,DWORD PTR [r9]
  643aa1:	44 39 c0             	cmp    eax,r8d
  643aa4:	0f 87 67 00 00 00    	ja     0x643b11
  643aaa:	41 29 c0             	sub    r8d,eax
  643aad:	41 8b 49 04          	mov    ecx,DWORD PTR [r9+0x4]
  643ab1:	44 39 c1             	cmp    ecx,r8d
  643ab4:	0f 87 57 00 00 00    	ja     0x643b11
  643aba:	83 f9 10             	cmp    ecx,0x10
  643abd:	0f 82 4e 00 00 00    	jb     0x643b11
  643ac3:	49 01 c3             	add    r11,rax
  643ac6:	41 8b 0b             	mov    ecx,DWORD PTR [r11]
  643ac9:	39 d1                	cmp    ecx,edx
  643acb:	0f 85 40 00 00 00    	jne    0x643b11
  643ad1:	45 8b 53 08          	mov    r10d,DWORD PTR [r11+0x8]
  643ad5:	44 39 d6             	cmp    esi,r10d
  643ad8:	0f 83 49 00 00 00    	jae    0x643b27
  643ade:	48 6b f6 04          	imul   rsi,rsi,0x4
  643ae2:	45 8b 53 04          	mov    r10d,DWORD PTR [r11+0x4]
  643ae6:	49 89 f0             	mov    r8,rsi
  643ae9:	49 83 c0 14          	add    r8,0x14
  643aed:	41 8b 51 04          	mov    edx,DWORD PTR [r9+0x4]
  643af1:	49 39 d0             	cmp    r8,rdx
  643af4:	0f 87 17 00 00 00    	ja     0x643b11
  643afa:	4d 39 d0             	cmp    r8,r10
  643afd:	0f 87 0e 00 00 00    	ja     0x643b11
  643b03:	49 8d 43 10          	lea    rax,[r11+0x10]
  643b07:	48 01 f0             	add    rax,rsi
  643b0a:	41 5b                	pop    r11
  643b0c:	41 5a                	pop    r10
  643b0e:	41 59                	pop    r9
  643b10:	c3                   	ret
  643b11:	41 5b                	pop    r11
  643b13:	41 5a                	pop    r10
  643b15:	41 59                	pop    r9
  643b17:	e9 b3 01 00 00       	jmp    0x643ccf
  643b1c:	41 5b                	pop    r11
  643b1e:	41 5a                	pop    r10
  643b20:	41 59                	pop    r9
  643b22:	e9 80 01 00 00       	jmp    0x643ca7
  643b27:	41 5b                	pop    r11
  643b29:	41 5a                	pop    r10
  643b2b:	41 59                	pop    r9
  643b2d:	e9 1b 01 00 00       	jmp    0x643c4d
  643b32:	41 51                	push   r9
  643b34:	41 52                	push   r10
  643b36:	41 53                	push   r11
  643b38:	89 cf                	mov    edi,ecx
  643b3a:	49 89 c2             	mov    r10,rax
  643b3d:	49 c1 ea 20          	shr    r10,0x20
  643b41:	4d 85 d2             	test   r10,r10
  643b44:	0f 85 c5 00 00 00    	jne    0x643c0f
  643b4a:	85 c0                	test   eax,eax
  643b4c:	0f 85 0d 00 00 00    	jne    0x643b5f
  643b52:	85 f6                	test   esi,esi
  643b54:	0f 84 b5 00 00 00    	je     0x643c0f
  643b5a:	e9 bb 00 00 00       	jmp    0x643c1a
  643b5f:	41 89 c2             	mov    r10d,eax
  643b62:	41 83 e2 01          	and    r10d,0x1
  643b66:	45 85 d2             	test   r10d,r10d
  643b69:	0f 85 a0 00 00 00    	jne    0x643c0f
  643b6f:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
  643b76:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
  643b7a:	48 6b d2 04          	imul   rdx,rdx,0x4
  643b7e:	41 8b 14 12          	mov    edx,DWORD PTR [r10+rdx*1]
  643b82:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
  643b86:	d1 e8                	shr    eax,1
  643b88:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
  643b8c:	0f 83 7d 00 00 00    	jae    0x643c0f
  643b92:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
  643b96:	48 c1 e0 04          	shl    rax,0x4
  643b9a:	49 01 c1             	add    r9,rax
  643b9d:	45 0f b6 54 21 0e    	movzx  r10d,BYTE PTR [r9+riz*1+0xe]
  643ba3:	45 85 d2             	test   r10d,r10d
  643ba6:	0f 84 63 00 00 00    	je     0x643c0f
  643bac:	41 83 fa 04          	cmp    r10d,0x4
  643bb0:	0f 87 59 00 00 00    	ja     0x643c0f
  643bb6:	41 c1 e2 04          	shl    r10d,0x4
  643bba:	4f 8b 5c 10 18       	mov    r11,QWORD PTR [r8+r10*1+0x18]
  643bbf:	47 8b 44 10 20       	mov    r8d,DWORD PTR [r8+r10*1+0x20]
  643bc4:	41 8b 01             	mov    eax,DWORD PTR [r9]
  643bc7:	44 39 c0             	cmp    eax,r8d
  643bca:	0f 87 3f 00 00 00    	ja     0x643c0f
  643bd0:	41 29 c0             	sub    r8d,eax
  643bd3:	41 8b 49 04          	mov    ecx,DWORD PTR [r9+0x4]
  643bd7:	44 39 c1             	cmp    ecx,r8d
  643bda:	0f 87 2f 00 00 00    	ja     0x643c0f
  643be0:	39 f9                	cmp    ecx,edi
  643be2:	0f 82 27 00 00 00    	jb     0x643c0f
  643be8:	49 01 c3             	add    r11,rax
  643beb:	41 8b 0b             	mov    ecx,DWORD PTR [r11]
  643bee:	39 d1                	cmp    ecx,edx
  643bf0:	0f 85 19 00 00 00    	jne    0x643c0f
  643bf6:	41 8b 4b 04          	mov    ecx,DWORD PTR [r11+0x4]
  643bfa:	39 f9                	cmp    ecx,edi
  643bfc:	0f 82 0d 00 00 00    	jb     0x643c0f
  643c02:	4c 89 de             	mov    rsi,r11
  643c05:	41 5b                	pop    r11
  643c07:	41 5a                	pop    r10
  643c09:	41 59                	pop    r9
  643c0b:	48 89 f0             	mov    rax,rsi
  643c0e:	c3                   	ret
  643c0f:	41 5b                	pop    r11
  643c11:	41 5a                	pop    r10
  643c13:	41 59                	pop    r9
  643c15:	e9 b5 00 00 00       	jmp    0x643ccf
  643c1a:	41 5b                	pop    r11
  643c1c:	41 5a                	pop    r10
  643c1e:	41 59                	pop    r9
  643c20:	e9 82 00 00 00       	jmp    0x643ca7
  643c25:	b8 ff ff ff ff       	mov    eax,0xffffffff
  643c2a:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  643c2e:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  643c31:	44 89 36             	mov    DWORD PTR [rsi],r14d
  643c34:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  643c38:	c7 46 10 c2 01 00 00 	mov    DWORD PTR [rsi+0x10],0x1c2
  643c3f:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  643c42:	c7 06 01 00 00 00    	mov    DWORD PTR [rsi],0x1
  643c48:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  643c4c:	c3                   	ret
  643c4d:	b8 ff ff ff ff       	mov    eax,0xffffffff
  643c52:	e9 00 00 00 00       	jmp    0x643c57
  643c57:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  643c5b:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  643c5e:	44 89 36             	mov    DWORD PTR [rsi],r14d
  643c61:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  643c65:	c7 46 10 10 09 00 00 	mov    DWORD PTR [rsi+0x10],0x910
  643c6c:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  643c6f:	c7 06 02 00 00 00    	mov    DWORD PTR [rsi],0x2
  643c75:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  643c79:	c3                   	ret
  643c7a:	b8 00 00 00 00       	mov    eax,0x0
  643c7f:	e9 00 00 00 00       	jmp    0x643c84
  643c84:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  643c88:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  643c8b:	44 89 36             	mov    DWORD PTR [rsi],r14d
  643c8e:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  643c92:	c7 46 10 10 09 00 00 	mov    DWORD PTR [rsi+0x10],0x910
  643c99:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  643c9c:	c7 06 0d 00 00 00    	mov    DWORD PTR [rsi],0xd
  643ca2:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  643ca6:	c3                   	ret
  643ca7:	b8 ff ff ff ff       	mov    eax,0xffffffff
  643cac:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  643cb0:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  643cb3:	44 89 36             	mov    DWORD PTR [rsi],r14d
  643cb6:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  643cba:	c7 46 10 10 09 00 00 	mov    DWORD PTR [rsi+0x10],0x910
  643cc1:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  643cc4:	c7 06 10 00 00 00    	mov    DWORD PTR [rsi],0x10
  643cca:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  643cce:	c3                   	ret
  643ccf:	b8 ff ff ff ff       	mov    eax,0xffffffff
  643cd4:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
  643cd8:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
  643cdb:	44 89 36             	mov    DWORD PTR [rsi],r14d
  643cde:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
  643ce2:	c7 46 10 10 09 00 00 	mov    DWORD PTR [rsi+0x10],0x910
  643ce9:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
  643cec:	c7 06 12 00 00 00    	mov    DWORD PTR [rsi],0x12
  643cf2:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
  643cf6:	c3                   	ret
