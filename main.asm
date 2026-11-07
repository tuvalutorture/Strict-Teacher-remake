; Strict Teacher, improved by ya boy tuvalutorture :D

bits 64

global main
extern printf, scanf, rand, srand, time
; for rand, number stored in EAX
; for time, in RAX


section .text
    ; So basically, I want to do an addition question.
    ; If its wrong, it prints msg 3
    ; If its right, it prints msg 4
    ; At the start, it prints msg 1
    ; At the end, it prints msg 5
; Farhan babar the goat
    main:
        ; these four registers are free to use (non-volatile) so that's yum
        push r12 ; the first number
        push r13 ; the second number
        push r14 ; the symbol in play
        push r15 ; the current running streak

        sub rsp, 40

        xor eax, eax ; clears eax register to 0 
        lea rcx, [rel msg1] ; rcx is index register
        call printf

        ; question section
        ; prepares randomisation of seed
        xor ecx, ecx
        call time
        mov ecx, eax
        call srand ; sets seed as time

        mov [rel rightAnswers], 0
        mov [rel questionsAsked], 0

        xor r14, r14

        loop:
            .get_nums: ; while (r12d == r13d && r12d && r13d).
                ; 1st random
                call randomiser
                mov r12d, edx
                ; 2nd random
                call randomiser
                mov r13d, edx
                cmp r12d, r13d ; this prevents us from getting equality (which means subtraction won't equal 0)
                je .get_nums 
                xor edx, edx
                cmp r12d, edx ; or zeros (which means mult could be zero)
                je .get_nums
                cmp r13d, edx ; quite hackey but eh it works so screw it we ball
                je .get_nums

            ; printing question
            lea rcx, [rel msg2]
            mov edx, r12d ; 1st argument (1st num)
            lea rbx, [rel operations]
            lea r8, [rbx + r14 * 8] ; 2nd argument (the name of the operation we're committing)
            mov r9d, r13d ; 3rd argument (2nd num)
            call printf ; prints the question out

            ; scanning for question

            lea rcx, [rel format] ; loads format string
            lea rdx, [rel numb] ; sets input
            call scanf

            cmp [rel numb], 0
            stc ; set the bailout flag
            je done

            inc [rel questionsAsked] ; question went through, so we inc
            
            lea rbx, [rel operationFuncs]
            call [rbx + r14 * 8] ; math to get the current math function
            cmp r12d, [rel numb] ; compare it to the input
            clc ; clear carry just in case so we don't quit early
            je is_correct

            xor r15, r15
            lea rcx, [rel msg3] ; sets to msg3 if it isn't right
            call printf

            jmp done

            is_correct:
                lea rcx, [rel msg4] ; sets print to msg 4
                inc [rel rightAnswers]
                call printf
                inc r15
            
            done: jnc loop
        
        ; taunt the user a lil bit
        lea rcx, [rel endingMessage]
        mov edx, [rel questionsAsked]
        mov r8d, [rel rightAnswers]
        mov r9d, [rel questionsAsked]
        call printf

        add rsp, 40

        ; pops our pushed regs so that we don't accidentally destroy something up above us that may use them
        pop r15
        pop r14
        pop r13
        pop r12

        ret 

    randomiser:
        call rand
        xor rdx, rdx
        mov ecx, [rel divisor]
        div ecx
        ret

    ; getting actual answer and comparing to user answer
    addition:
        add r12d, r13d
        ret

    subtraction: 
        sub r12d, r13d
        ret

    multiplication: 
        mov eax, r12d
        mul r13d
        mov r12d, eax
        ret

section .data
    msg1: db "Boy, you better get these questions right >:( (or press 0 to chicken out)", 10, 0
    msg2: db "What is %d %s %d?: ", 10, 0
    msg3: db "nahhhhh!!!", 10, 0
    msg4: db "hmm, too easy.", 10, 0

    endingMessage: 
        db "Are you really chickening out? After %d question(s)?", 10
        db "Fine. You got %d/%d correct.", 10
        db "Come back tmr, or else...", 10, 0

    format: db "%d", 0

    divisor: dd 100

    operations:
        db "plus", 0
        db "minus", 0
        db "times", 0

    operationFuncs:
        dq addition
        dq subtraction
        dq multiplication

section .bss
    numb: resd 1
    rightAnswers: resd 1
    questionsAsked: resd 1
