section .data

entry64:
    dq 0
    dq 0x0020980000000000
    dq 0x0020f80000000000
    dq 0x0000f20000000000

d_tss:
    dw TssLen-1
    dw 0
    db 0
    db 0x89
    db 0
    db 0
    dq 0

64entry_len: equ $-Gdt64

64entry_ptr: dw Gdt64Len-1
          dq Gdt64

Tss:
    dd 0
    dq 0x190000
    times 88 db 0
    dd TssLen

tss_len: equ $-Tss

section .text
extern KMain
global start

start:
    lgdt [Gdt64Ptr]

tss_start:
    mov rax,Tss
    mov [TssDesc+2],ax
    shr rax,16
    mov [TssDesc+4],al
    shr rax,8
    mov [TssDesc+7],al
    shr rax,8
    mov [TssDesc+8],eax
    mov ax,0x20
    ltr ax

pit_start:
    mov al,(1<<2)|(3<<4)
    out 0x43,al

    mov ax,11931
    out 0x40,al
    mov al,ah
    out 0x40,al

pic_start:
    mov al,0x11
    out 0x20,al
    out 0xa0,al

    mov al,32
    out 0x21,al
    mov al,40
    out 0xa1,al

    mov al,4
    out 0x21,al
    mov al,2
    out 0xa1,al

    mov al,1
    out 0x21,al
    out 0xa1,al

    mov al,11111110b
    out 0x21,al
    mov al,11111111b
    out 0xa1,al

    push 8
    push KernelEntry
    db 0x48
    retf

entry64:
    mov rsp,0x200000
    call enter_kernel
