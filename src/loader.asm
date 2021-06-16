[BITS 16]
[ORG 0x7e00]

jmp init

init:
    mov [drive_no],dl

    ;check for long mode support
    mov eax,0x80000000
    cpuid

    cmp eax,0x80000001
    jb no_long_mode

    mov eax,0x80000001
    cpuid

    test edx,(1<<29)
    jz no_long_mode

    test edx,(1<<26)
    jz no_long_mode

kernel_init:
    mov si,disk_add_packet
    mov word[si],0x10
    mov word[si+2],100
    mov word[si+4],0
    mov word[si+6],0x1000
    mov dword[si+8],6
    mov dword[si+0xc],0
    mov dl,[drive_no]
    mov ah,0x42
    int 0x13
    jc  ReadError

; check_a20:
;     pushf
;     push ds
;     push es
;     push di
;     push si
 
;     cli
 
;     xor ax, ax ; ax = 0
;     mov es, ax
 
;     not ax ; ax = 0xFFFF
;     mov ds, ax
 
;     mov di, 0x0500
;     mov si, 0x0510
 
;     mov al, byte [es:di]
;     push ax
 
;     mov al, byte [ds:si]
;     push ax
 
;     mov byte [es:di], 0x00
;     mov byte [ds:si], 0xFF
 
;     cmp byte [es:di], 0xFF
 
;     pop ax
;     mov byte [ds:si], al
 
;     pop ax
;     mov byte [es:di], al
 
;     mov ax, 0
 
;     mov ax, 1

seta20:
    xor ax,ax
    mov es,ax

test_videomode:
    mov ax,3
    int 0x10
    
    cli
    lgdt [Gdt32Ptr]
    lidt [Idt32Ptr]

    mov eax,cr0
    or eax,1
    mov cr0,eax

    jmp 8:entry32

ReadError:
no_long_mode:
End:
    hlt
    jmp End


[BITS 32]
entry32:
    mov ax,0x10
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov esp,0x7c00

    cld
    mov edi,0x70000
    xor eax,eax
    mov ecx,0x10000/4
    rep stosd
    
    mov dword[0x70000],0x71007
    mov dword[0x71000],10000111b


    lgdt [Gdt64Ptr]

    mov eax,cr4
    or eax,(1<<5)
    mov cr4,eax

    mov eax,0x70000
    mov cr3,eax

    mov ecx,0xc0000080
    rdmsr
    or eax,(1<<8)
    wrmsr

    mov eax,cr0
    or eax,(1<<31)
    mov cr0,eax

    jmp 8:entry64

PEnd:
    hlt
    jmp PEnd

[BITS 64]
entry64:
    mov rsp,0x7c00

    cld
    mov rdi,0x200000
    mov rsi,0x10000
    mov rcx,51200/8
    rep movsq

    jmp 0x200000
    
LEnd:
    hlt
    jmp LEnd
    
    

drive_no:    db 0
disk_add_packet: times 16 db 0