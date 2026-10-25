
.tmp/wago-next-gc-perf/post-read-regions-profile/profile/native-code.bin:     file format binary


Disassembly of section .data:

000000000000973c <.data+0x973c>:
    973c:	48 81 ec 38 00 00 00 	sub    rsp,0x38
    9743:	48 8b 73 b8          	mov    rsi,QWORD PTR [rbx-0x48]
    9747:	48 39 f4             	cmp    rsp,rsi
    974a:	0f 82 11 05 00 00    	jb     0x9c61
    9750:	49 89 c4             	mov    r12,rax
    9753:	4c 89 e7             	mov    rdi,r12
    9756:	48 89 7c 24 08       	mov    QWORD PTR [rsp+0x8],rdi
    975b:	48 8b 7c 24 08       	mov    rdi,QWORD PTR [rsp+0x8]
    9760:	48 89 f8             	mov    rax,rdi
    9763:	ba a1 09 00 00       	mov    edx,0x9a1
    9768:	b9 18 00 00 00       	mov    ecx,0x18
    976d:	be 00 00 00 00       	mov    esi,0x0
    9772:	e8 0f 04 00 00       	call   0x9b86
    9777:	48 89 c5             	mov    rbp,rax
    977a:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
    977e:	8b 7d 10             	mov    edi,DWORD PTR [rbp+0x10]
    9781:	48 89 44 24 18       	mov    QWORD PTR [rsp+0x18],rax
    9786:	48 89 f8             	mov    rax,rdi
    9789:	ba a0 09 00 00       	mov    edx,0x9a0
    978e:	b9 18 00 00 00       	mov    ecx,0x18
    9793:	be 00 00 00 00       	mov    esi,0x0
    9798:	e8 e9 03 00 00       	call   0x9b86
    979d:	8b 44 20 14          	mov    eax,DWORD PTR [rax+riz*1+0x14]
    97a1:	8b 7c 24 18          	mov    edi,DWORD PTR [rsp+0x18]
    97a5:	39 c7                	cmp    edi,eax
    97a7:	40 0f 92 c7          	setb   dil
    97ab:	40 0f b6 ff          	movzx  edi,dil
    97af:	48 89 7c 24 18       	mov    QWORD PTR [rsp+0x18],rdi
    97b4:	4c 89 24 24          	mov    QWORD PTR [rsp],r12
    97b8:	8b 7c 24 18          	mov    edi,DWORD PTR [rsp+0x18]
    97bc:	85 ff                	test   edi,edi
    97be:	0f 84 15 02 00 00    	je     0x99d9
    97c4:	4c 89 e7             	mov    rdi,r12
    97c7:	48 89 f8             	mov    rax,rdi
    97ca:	e8 2d 6b 00 00       	call   0x102fc
    97cf:	48 89 c7             	mov    rdi,rax
    97d2:	48 89 7c 24 18       	mov    QWORD PTR [rsp+0x18],rdi
    97d7:	bf 97 09 00 00       	mov    edi,0x997
    97dc:	48 89 7c 24 20       	mov    QWORD PTR [rsp+0x20],rdi
    97e1:	41 50                	push   r8
    97e3:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
    97ea:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
    97ee:	41 8b 92 5c 26 00 00 	mov    edx,DWORD PTR [r10+0x265c]
    97f5:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
    97f9:	41 83 b8 a0 00 00 00 	cmp    DWORD PTR [r8+0xa0],0x18
    9800:	18 
    9801:	0f 86 80 01 00 00    	jbe    0x9987
    9807:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
    980e:	4d 85 d2             	test   r10,r10
    9811:	0f 84 70 01 00 00    	je     0x9987
    9817:	41 8b 4a 04          	mov    ecx,DWORD PTR [r10+0x4]
    981b:	41 8b 42 08          	mov    eax,DWORD PTR [r10+0x8]
    981f:	81 f8 00 02 00 00    	cmp    eax,0x200
    9825:	0f 87 5c 01 00 00    	ja     0x9987
    982b:	39 c1                	cmp    ecx,eax
    982d:	0f 83 54 01 00 00    	jae    0x9987
    9833:	49 8d 44 8a 20       	lea    rax,[r10+rcx*4+0x20]
    9838:	8b 30                	mov    esi,DWORD PTR [rax]
    983a:	89 f0                	mov    eax,esi
    983c:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
    9840:	48 c1 e0 04          	shl    rax,0x4
    9844:	49 01 c1             	add    r9,rax
    9847:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
    984e:	48 85 c0             	test   rax,rax
    9851:	0f 84 30 01 00 00    	je     0x9987
    9857:	8b 08                	mov    ecx,DWORD PTR [rax]
    9859:	83 c1 07             	add    ecx,0x7
    985c:	83 e1 f8             	and    ecx,0xfffffff8
    985f:	41 8b 40 7c          	mov    eax,DWORD PTR [r8+0x7c]
    9863:	39 c1                	cmp    ecx,eax
    9865:	0f 87 1c 01 00 00    	ja     0x9987
    986b:	29 c8                	sub    eax,ecx
    986d:	83 f8 18             	cmp    eax,0x18
    9870:	0f 82 11 01 00 00    	jb     0x9987
    9876:	4d 8b 58 28          	mov    r11,QWORD PTR [r8+0x28]
    987a:	4d 85 db             	test   r11,r11
    987d:	0f 84 04 01 00 00    	je     0x9987
    9883:	49 01 cb             	add    r11,rcx
    9886:	49 8b 80 98 00 00 00 	mov    rax,QWORD PTR [r8+0x98]
    988d:	48 85 c0             	test   rax,rax
    9890:	0f 84 f1 00 00 00    	je     0x9987
    9896:	8b 44 24 20          	mov    eax,DWORD PTR [rsp+0x20]
    989a:	85 c0                	test   eax,eax
    989c:	0f 84 42 00 00 00    	je     0x98e4
    98a2:	89 c2                	mov    edx,eax
    98a4:	83 e2 01             	and    edx,0x1
    98a7:	85 d2                	test   edx,edx
    98a9:	0f 85 35 00 00 00    	jne    0x98e4
    98af:	d1 e8                	shr    eax,1
    98b1:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
    98b5:	0f 83 cc 00 00 00    	jae    0x9987
    98bb:	4d 8b 50 08          	mov    r10,QWORD PTR [r8+0x8]
    98bf:	48 c1 e0 04          	shl    rax,0x4
    98c3:	49 01 c2             	add    r10,rax
    98c6:	41 8b 42 0c          	mov    eax,DWORD PTR [r10+0xc]
    98ca:	c1 e8 10             	shr    eax,0x10
    98cd:	81 e0 ff 00 00 00    	and    eax,0xff
    98d3:	85 c0                	test   eax,eax
    98d5:	0f 84 ac 00 00 00    	je     0x9987
    98db:	83 f8 04             	cmp    eax,0x4
    98de:	0f 87 a3 00 00 00    	ja     0x9987
    98e4:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
    98eb:	41 8b 52 04          	mov    edx,DWORD PTR [r10+0x4]
    98ef:	48 8b 83 e8 fe ff ff 	mov    rax,QWORD PTR [rbx-0x118]
    98f6:	48 8b 40 10          	mov    rax,QWORD PTR [rax+0x10]
    98fa:	8b 80 5c 26 00 00    	mov    eax,DWORD PTR [rax+0x265c]
    9900:	41 89 03             	mov    DWORD PTR [r11],eax
    9903:	41 c7 43 04 18 00 00 	mov    DWORD PTR [r11+0x4],0x18
    990a:	00 
    990b:	41 c7 43 08 00 00 00 	mov    DWORD PTR [r11+0x8],0x0
    9912:	00 
    9913:	41 c7 43 0c 00 00 00 	mov    DWORD PTR [r11+0xc],0x0
    991a:	00 
    991b:	8b 44 24 20          	mov    eax,DWORD PTR [rsp+0x20]
    991f:	41 89 43 10          	mov    DWORD PTR [r11+0x10],eax
    9923:	41 89 09             	mov    DWORD PTR [r9],ecx
    9926:	41 c7 41 04 18 00 00 	mov    DWORD PTR [r9+0x4],0x18
    992d:	00 
    992e:	41 c7 41 08 00 00 00 	mov    DWORD PTR [r9+0x8],0x0
    9935:	00 
    9936:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
    993d:	41 89 ca             	mov    r10d,ecx
    9940:	41 83 c2 18          	add    r10d,0x18
    9944:	44 89 10             	mov    DWORD PTR [rax],r10d
    9947:	41 c7 41 0c 00 00 01 	mov    DWORD PTR [r9+0xc],0x10000
    994e:	00 
    994f:	83 c2 01             	add    edx,0x1
    9952:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
    9959:	41 89 52 04          	mov    DWORD PTR [r10+0x4],edx
    995d:	41 83 7a 18 00       	cmp    DWORD PTR [r10+0x18],0x0
    9962:	0f 84 11 00 00 00    	je     0x9979
    9968:	4d 8b 90 98 00 00 00 	mov    r10,QWORD PTR [r8+0x98]
    996f:	49 8b 02             	mov    rax,QWORD PTR [r10]
    9972:	48 83 c0 01          	add    rax,0x1
    9976:	49 89 02             	mov    QWORD PTR [r10],rax
    9979:	89 f0                	mov    eax,esi
    997b:	d1 e0                	shl    eax,1
    997d:	48 89 44 24 20       	mov    QWORD PTR [rsp+0x20],rax
    9982:	e9 05 00 00 00       	jmp    0x998c
    9987:	b8 00 00 00 00       	mov    eax,0x0
    998c:	85 c0                	test   eax,eax
    998e:	41 58                	pop    r8
    9990:	0f 85 39 00 00 00    	jne    0x99cf
    9996:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
    999a:	48 8b 44 24 18       	mov    rax,QWORD PTR [rsp+0x18]
    999f:	49 89 40 48          	mov    QWORD PTR [r8+0x48],rax
    99a3:	8b 44 24 20          	mov    eax,DWORD PTR [rsp+0x20]
    99a7:	49 89 40 50          	mov    QWORD PTR [r8+0x50],rax
    99ab:	41 c7 40 40 0b 0a 00 	mov    DWORD PTR [r8+0x40],0x40000a0b
    99b2:	40 
    99b3:	41 c7 40 44 02 00 01 	mov    DWORD PTR [r8+0x44],0x10002
    99ba:	00 
    99bb:	41 ff 50 38          	call   QWORD PTR [r8+0x38]
    99bf:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
    99c3:	49 8b 80 48 02 00 00 	mov    rax,QWORD PTR [r8+0x248]
    99ca:	48 89 44 24 18       	mov    QWORD PTR [rsp+0x18],rax
    99cf:	48 8b 6c 24 18       	mov    rbp,QWORD PTR [rsp+0x18]
    99d4:	e9 a2 01 00 00       	jmp    0x9b7b
    99d9:	bf 95 09 00 00       	mov    edi,0x995
    99de:	48 89 7c 24 18       	mov    QWORD PTR [rsp+0x18],rdi
    99e3:	41 50                	push   r8
    99e5:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
    99ec:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
    99f0:	41 8b 92 54 26 00 00 	mov    edx,DWORD PTR [r10+0x2654]
    99f7:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
    99fb:	41 83 b8 a0 00 00 00 	cmp    DWORD PTR [r8+0xa0],0x10
    9a02:	10 
    9a03:	0f 86 2a 01 00 00    	jbe    0x9b33
    9a09:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
    9a10:	4d 85 d2             	test   r10,r10
    9a13:	0f 84 1a 01 00 00    	je     0x9b33
    9a19:	41 8b 4a 04          	mov    ecx,DWORD PTR [r10+0x4]
    9a1d:	41 8b 42 08          	mov    eax,DWORD PTR [r10+0x8]
    9a21:	81 f8 00 02 00 00    	cmp    eax,0x200
    9a27:	0f 87 06 01 00 00    	ja     0x9b33
    9a2d:	39 c1                	cmp    ecx,eax
    9a2f:	0f 83 fe 00 00 00    	jae    0x9b33
    9a35:	49 8d 44 8a 20       	lea    rax,[r10+rcx*4+0x20]
    9a3a:	8b 30                	mov    esi,DWORD PTR [rax]
    9a3c:	89 f0                	mov    eax,esi
    9a3e:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
    9a42:	48 c1 e0 04          	shl    rax,0x4
    9a46:	49 01 c1             	add    r9,rax
    9a49:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
    9a50:	48 85 c0             	test   rax,rax
    9a53:	0f 84 da 00 00 00    	je     0x9b33
    9a59:	8b 08                	mov    ecx,DWORD PTR [rax]
    9a5b:	83 c1 07             	add    ecx,0x7
    9a5e:	83 e1 f8             	and    ecx,0xfffffff8
    9a61:	41 8b 40 7c          	mov    eax,DWORD PTR [r8+0x7c]
    9a65:	39 c1                	cmp    ecx,eax
    9a67:	0f 87 c6 00 00 00    	ja     0x9b33
    9a6d:	29 c8                	sub    eax,ecx
    9a6f:	83 f8 10             	cmp    eax,0x10
    9a72:	0f 82 bb 00 00 00    	jb     0x9b33
    9a78:	4d 8b 58 28          	mov    r11,QWORD PTR [r8+0x28]
    9a7c:	4d 85 db             	test   r11,r11
    9a7f:	0f 84 ae 00 00 00    	je     0x9b33
    9a85:	49 01 cb             	add    r11,rcx
    9a88:	49 8b 80 98 00 00 00 	mov    rax,QWORD PTR [r8+0x98]
    9a8f:	48 85 c0             	test   rax,rax
    9a92:	0f 84 9b 00 00 00    	je     0x9b33
    9a98:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
    9a9f:	41 8b 52 04          	mov    edx,DWORD PTR [r10+0x4]
    9aa3:	48 8b 83 e8 fe ff ff 	mov    rax,QWORD PTR [rbx-0x118]
    9aaa:	48 8b 40 10          	mov    rax,QWORD PTR [rax+0x10]
    9aae:	8b 80 54 26 00 00    	mov    eax,DWORD PTR [rax+0x2654]
    9ab4:	41 89 03             	mov    DWORD PTR [r11],eax
    9ab7:	41 c7 43 04 10 00 00 	mov    DWORD PTR [r11+0x4],0x10
    9abe:	00 
    9abf:	41 c7 43 08 00 00 00 	mov    DWORD PTR [r11+0x8],0x0
    9ac6:	00 
    9ac7:	41 c7 43 0c 01 00 00 	mov    DWORD PTR [r11+0xc],0x1
    9ace:	00 
    9acf:	41 89 09             	mov    DWORD PTR [r9],ecx
    9ad2:	41 c7 41 04 10 00 00 	mov    DWORD PTR [r9+0x4],0x10
    9ad9:	00 
    9ada:	41 c7 41 08 00 00 00 	mov    DWORD PTR [r9+0x8],0x0
    9ae1:	00 
    9ae2:	49 8b 80 90 00 00 00 	mov    rax,QWORD PTR [r8+0x90]
    9ae9:	41 89 ca             	mov    r10d,ecx
    9aec:	41 83 c2 10          	add    r10d,0x10
    9af0:	44 89 10             	mov    DWORD PTR [rax],r10d
    9af3:	41 c7 41 0c 00 00 01 	mov    DWORD PTR [r9+0xc],0x10000
    9afa:	00 
    9afb:	83 c2 01             	add    edx,0x1
    9afe:	4d 8b 90 80 00 00 00 	mov    r10,QWORD PTR [r8+0x80]
    9b05:	41 89 52 04          	mov    DWORD PTR [r10+0x4],edx
    9b09:	41 83 7a 18 00       	cmp    DWORD PTR [r10+0x18],0x0
    9b0e:	0f 84 11 00 00 00    	je     0x9b25
    9b14:	4d 8b 90 98 00 00 00 	mov    r10,QWORD PTR [r8+0x98]
    9b1b:	49 8b 02             	mov    rax,QWORD PTR [r10]
    9b1e:	48 83 c0 01          	add    rax,0x1
    9b22:	49 89 02             	mov    QWORD PTR [r10],rax
    9b25:	89 f0                	mov    eax,esi
    9b27:	d1 e0                	shl    eax,1
    9b29:	48 89 44 24 20       	mov    QWORD PTR [rsp+0x20],rax
    9b2e:	e9 05 00 00 00       	jmp    0x9b38
    9b33:	b8 00 00 00 00       	mov    eax,0x0
    9b38:	85 c0                	test   eax,eax
    9b3a:	41 58                	pop    r8
    9b3c:	0f 85 34 00 00 00    	jne    0x9b76
    9b42:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
    9b46:	8b 44 24 18          	mov    eax,DWORD PTR [rsp+0x18]
    9b4a:	49 89 40 48          	mov    QWORD PTR [r8+0x48],rax
    9b4e:	41 c7 40 40 0b 0b 00 	mov    DWORD PTR [r8+0x40],0x40000b0b
    9b55:	40 
    9b56:	41 c7 40 44 01 00 01 	mov    DWORD PTR [r8+0x44],0x10001
    9b5d:	00 
    9b5e:	41 ff 50 38          	call   QWORD PTR [r8+0x38]
    9b62:	4c 8b 43 d8          	mov    r8,QWORD PTR [rbx-0x28]
    9b66:	49 8b 80 48 02 00 00 	mov    rax,QWORD PTR [r8+0x248]
    9b6d:	48 89 44 24 18       	mov    QWORD PTR [rsp+0x18],rax
    9b72:	4c 8b 24 24          	mov    r12,QWORD PTR [rsp]
    9b76:	48 8b 6c 24 18       	mov    rbp,QWORD PTR [rsp+0x18]
    9b7b:	48 89 e8             	mov    rax,rbp
    9b7e:	48 81 c4 38 00 00 00 	add    rsp,0x38
    9b85:	c3                   	ret
    9b86:	89 cf                	mov    edi,ecx
    9b88:	49 89 c2             	mov    r10,rax
    9b8b:	49 c1 ea 20          	shr    r10,0x20
    9b8f:	4d 85 d2             	test   r10,r10
    9b92:	0f 85 bf 00 00 00    	jne    0x9c57
    9b98:	85 c0                	test   eax,eax
    9b9a:	0f 85 0d 00 00 00    	jne    0x9bad
    9ba0:	85 f6                	test   esi,esi
    9ba2:	0f 84 af 00 00 00    	je     0x9c57
    9ba8:	e9 af 00 00 00       	jmp    0x9c5c
    9bad:	41 89 c2             	mov    r10d,eax
    9bb0:	41 83 e2 01          	and    r10d,0x1
    9bb4:	45 85 d2             	test   r10d,r10d
    9bb7:	0f 85 9a 00 00 00    	jne    0x9c57
    9bbd:	4c 8b 83 e8 fe ff ff 	mov    r8,QWORD PTR [rbx-0x118]
    9bc4:	4d 8b 50 10          	mov    r10,QWORD PTR [r8+0x10]
    9bc8:	48 6b d2 04          	imul   rdx,rdx,0x4
    9bcc:	41 8b 14 12          	mov    edx,DWORD PTR [r10+rdx*1]
    9bd0:	4d 8b 40 08          	mov    r8,QWORD PTR [r8+0x8]
    9bd4:	d1 e8                	shr    eax,1
    9bd6:	41 3b 40 10          	cmp    eax,DWORD PTR [r8+0x10]
    9bda:	0f 83 77 00 00 00    	jae    0x9c57
    9be0:	4d 8b 48 08          	mov    r9,QWORD PTR [r8+0x8]
    9be4:	48 c1 e0 04          	shl    rax,0x4
    9be8:	49 01 c1             	add    r9,rax
    9beb:	45 0f b6 54 21 0e    	movzx  r10d,BYTE PTR [r9+riz*1+0xe]
    9bf1:	45 85 d2             	test   r10d,r10d
    9bf4:	0f 84 5d 00 00 00    	je     0x9c57
    9bfa:	41 83 fa 04          	cmp    r10d,0x4
    9bfe:	0f 87 53 00 00 00    	ja     0x9c57
    9c04:	41 c1 e2 04          	shl    r10d,0x4
    9c08:	4f 8b 5c 10 18       	mov    r11,QWORD PTR [r8+r10*1+0x18]
    9c0d:	47 8b 44 10 20       	mov    r8d,DWORD PTR [r8+r10*1+0x20]
    9c12:	41 8b 01             	mov    eax,DWORD PTR [r9]
    9c15:	44 39 c0             	cmp    eax,r8d
    9c18:	0f 87 39 00 00 00    	ja     0x9c57
    9c1e:	41 29 c0             	sub    r8d,eax
    9c21:	41 8b 49 04          	mov    ecx,DWORD PTR [r9+0x4]
    9c25:	44 39 c1             	cmp    ecx,r8d
    9c28:	0f 87 29 00 00 00    	ja     0x9c57
    9c2e:	39 f9                	cmp    ecx,edi
    9c30:	0f 82 21 00 00 00    	jb     0x9c57
    9c36:	49 01 c3             	add    r11,rax
    9c39:	41 8b 0b             	mov    ecx,DWORD PTR [r11]
    9c3c:	39 d1                	cmp    ecx,edx
    9c3e:	0f 85 13 00 00 00    	jne    0x9c57
    9c44:	41 8b 4b 04          	mov    ecx,DWORD PTR [r11+0x4]
    9c48:	39 f9                	cmp    ecx,edi
    9c4a:	0f 82 07 00 00 00    	jb     0x9c57
    9c50:	4c 89 de             	mov    rsi,r11
    9c53:	48 89 f0             	mov    rax,rsi
    9c56:	c3                   	ret
    9c57:	e9 5f 00 00 00       	jmp    0x9cbb
    9c5c:	e9 2d 00 00 00       	jmp    0x9c8e
    9c61:	b8 00 00 00 00       	mov    eax,0x0
    9c66:	e9 00 00 00 00       	jmp    0x9c6b
    9c6b:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
    9c6f:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
    9c72:	44 89 36             	mov    DWORD PTR [rsi],r14d
    9c75:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
    9c79:	c7 46 10 d2 01 00 00 	mov    DWORD PTR [rsi+0x10],0x1d2
    9c80:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
    9c83:	c7 06 0d 00 00 00    	mov    DWORD PTR [rsi],0xd
    9c89:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
    9c8d:	c3                   	ret
    9c8e:	b8 ff ff ff ff       	mov    eax,0xffffffff
    9c93:	e9 00 00 00 00       	jmp    0x9c98
    9c98:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
    9c9c:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
    9c9f:	44 89 36             	mov    DWORD PTR [rsi],r14d
    9ca2:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
    9ca6:	c7 46 10 d2 01 00 00 	mov    DWORD PTR [rsi+0x10],0x1d2
    9cad:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
    9cb0:	c7 06 10 00 00 00    	mov    DWORD PTR [rsi],0x10
    9cb6:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
    9cba:	c3                   	ret
    9cbb:	b8 ff ff ff ff       	mov    eax,0xffffffff
    9cc0:	e9 00 00 00 00       	jmp    0x9cc5
    9cc5:	48 8b 73 90          	mov    rsi,QWORD PTR [rbx-0x70]
    9cc9:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
    9ccc:	44 89 36             	mov    DWORD PTR [rsi],r14d
    9ccf:	48 8b 73 98          	mov    rsi,QWORD PTR [rbx-0x68]
    9cd3:	c7 46 10 d2 01 00 00 	mov    DWORD PTR [rsi+0x10],0x1d2
    9cda:	89 46 14             	mov    DWORD PTR [rsi+0x14],eax
    9cdd:	c7 06 12 00 00 00    	mov    DWORD PTR [rsi],0x12
    9ce3:	48 8b 63 e8          	mov    rsp,QWORD PTR [rbx-0x18]
    9ce7:	c3                   	ret
