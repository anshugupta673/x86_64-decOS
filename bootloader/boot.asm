[BITS 16]   
[ORG 0x7c00]
;0000:7c0 * 16 + 0 = 0000:7c00

jmp boot_start
jmp lba_extended

boot_start:
    xor ax,ax     
    mov ss,ax   
    mov sp,0x7c00 ; Set stack space (7k) and stack segment

lba_extended:
    mov [drive_no],dl
    mov ah,0x41
    mov bx,0x55aa
    int 0x13
    cmp bx,0xaa55

    mov si,disk_add_packet
    mov word[si],0x10
    mov word[si+2],5
    mov word[si+4],0x7e00
    mov word[si+6],0
    mov dword[si+8],1
    mov dword[si+0xc],0
    mov dl,[drive_no]
    mov ah,0x42

    mov dl,[drive_no]
    jmp 0x7e00 

.hlt:
    hlt    
    jmp .hlt
    
drive_no:    db 0
disk_add_packet: times 16 db 0

times (0x1be-($-$$)) db 0
	
    times (16*3) db 0

    db 0x55
    db 0xaa