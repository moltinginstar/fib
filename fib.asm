section .rdata

int_format db "%d", 0xa, 0
input_prompt db "Enter an upper bound: ", 0
input_prompt_size equ $ - input_prompt

section .bss

upper_bound resb 18

section .text

default rel
extern atoi
; extern puts
extern printf
global main

main:
push rbx                            ; 16-byte align stack to be able to call C functions (as required by the System V AMD64 ABI)
                                    ; this is because after the C runtime calls main the stack is misaligned by 8 bytes
                                    ; as CALL places a return pointer on the stack (see https://stackoverflow.com/a/38335743)

; xor rax, rax                        ; RAX = 0: passing non-variable arguments to puts
; lea rdi, [rel input_prompt]         ; output prompt
; call puts                           ; by calling the C puts function

mov rax, 1                          ; write(2)
mov rdi, 1                          ; to stdout
lea rsi, [rel input_prompt]         ; the input prompt,
mov rdx, input_prompt_size          ; which is of length input_prompt_size
syscall

mov rax, 0                          ; read(1)
mov rdi, 0                          ; from stdin
lea rsi, [rel upper_bound]          ; the desired upper bound
mov rdx, 18                         ; into a 18-char buffer in memory
syscall

xor rax, rax                        ; RAX = 0: passing non-variable arguments to atoi
lea rdi, [rel upper_bound]          ; convert the string
call atoi                           ; entered by the user
mov rbx, rax                        ; to an integer

mov rcx, 0                          ; F(0) = 0
mov rdx, 1                          ; F(1) = 1

fib:
mov rdi, rcx                        ; save current F(n - 2)
mov rcx, rdx                        ; save current F(n - 1)
add rdx, rdi                        ; compute F(n) [RDX] = F(n - 1) [RDX = RCX] + F(n - 2) [RDI]

xor rax, rax                        ; passing non-variable arguments to printf
lea rdi, [rel int_format]           ; output current F(n - 1) [RCX]
mov rsi, rcx                        ; formatted as an integer
push rcx                            ; preserve both RCX and RDX
push rdx                            ; because these are clobbered
call printf                         ; by the printf call and to keep the stack aligned
pop rdx                             ; restore RDX and RCX
pop rcx                             ; to enable the algorithm to continue

cmp rdx, rbx                        ; loop until F(n) [RDX; the next element]
jle fib                             ; exceeds the desired value [R8]

pop rbx                             ; restore RBX and stack pointer
xor rax, rax                        ; exit with status 0
ret
