; Strict Teacher, improved by ya boy tuvalutorture :D

bits 64

global main
extern printf, scanf, puts, rand, srand, time
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
        ; these five registers are free to use (non-volatile) so that's yum
        push r12 ; the first number
        push r13 ; the second number
        push r14 ; the difficulty
        push r15 ; the current running streak
        push rbx ; the "oh shoot we need to LEA an addr for some math"
        
        sub rsp, 80

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
        xor r15, r15

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
                
                cmp r14, 2
                jne ask_the_darn_question
                cmp r13d, r12d
                jna ask_the_darn_question  
                xchg r12d, r13d
            
            ask_the_darn_question:
                ; printing question
                lea rcx, [rel msg2]
                mov edx, r12d ; 1st argument (1st num)
                lea rbx, [rel operations]
                mov r8, [rbx + r14 * 8] ; 2nd argument (the name of the operation we're committing)
                mov r9d, r13d ; 3rd argument (2nd num)
                call printf ; prints the question out

                ; scanning for question

                lea rcx, [rel format] ; loads format string
                lea rdx, [rel numb] ; sets input
                call scanf

                cmp [rel numb], 0
                stc ; set the bailout flag
                je bail

                inc [rel questionsAsked] ; question went through, so we inc
                
                lea rbx, [rel operationFuncs]
                call [rbx + r14 * 8] ; math to get the current math function
                cmp r12d, [rel numb] ; compare it to the input
                clc ; clear carry just in case so we don't quit early
                je is_correct

                xor r15, r15
                lea rbx, [rel roasts]

                jmp done

            is_correct:
                inc [rel rightAnswers]
                call printf
                inc r15
                call check_bump
                clc
                lea rbx, [rel backhandedCompliments]
                cmp eax, 0
                jne bail
            
            done: 
                call rand
                xor rdx, rdx
                mov rcx, 10
                div rcx
                mov rcx, [rbx + rdx * 8]
                call puts
                lea rax, [rel roasts]
                cmp rbx, rax
                jne bail
                lea rcx, [rel roastGiveAnswer]
                mov edx, r12d
                mov r8d, [rel numb]
                call printf

            bail:
                jnc loop
        
        ; taunt the user a lil bit
        lea rcx, [rel endingMessage]
        mov edx, [rel questionsAsked]
        mov r8d, [rel rightAnswers]
        mov r9d, [rel questionsAsked]
        call printf

        add rsp, 80

        ; pops our pushed regs so that we don't accidentally destroy something up above us that may use them
        pop rbx
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

    check_bump:
        xor eax, eax
        sub rsp, 40 ; i hate windows stack
        cmp r14, 5
        ja .return
        .bumpIsPossible:
            cmp r15, [rel streakForBump]
            jnae .return
            .performBump:
                lea rbx, [rel bumps]
                mov rcx, [rbx + r14 * 8]
                call puts
                lea rbx, [rel bumpFuncs]
                call [rbx + r14 * 8]
                inc r14
                xor r15, r15
                mov eax, 1
        .return:
            add rsp, 40
            ret

    bumpToHardAddition:
        mov qword [rel streakForBump], 10
        mov dword [rel divisor], 100
        ret

    bumpToSubtraction:
        mov qword [rel streakForBump], 5
        mov dword [rel divisor], 20
        ret

    bumpToHardSubtraction: 
        mov qword [rel streakForBump], 15
        mov dword [rel divisor], 500
        ret

    bumpToMultiplication:
        mov qword [rel streakForBump], 10
        mov dword [rel divisor], 10
        ret

    bumpToHardMultiplication: 
        mov qword [rel streakForBump], 20
        mov dword [rel divisor], 100
        ret

    bumpToNoMoreWorldsToConquer:
        mov qword [rel streakForBump], 0
        mov dword [rel divisor], 1000 ; quite devilish if i do say so myself
        ret

section .data
    msg1: db "Boy, you better get these questions right >:( (or press 0 to chicken out)", 10, 0
    msg2: db "What is %d %s %d?: ", 10, 0

    endingMessage: 
        db "Are you really chickening out? After %d question(s)?", 10
        db "Fine. You got %d/%d correct.", 10
        db "Come back tmr, or else... (you'll be reported truant if you don't :3)", 10, 0

    format: db "%d", 0

    divisor: dd 10

    streakForBump: dq 5

    operation_plus: db "plus", 0
    operation_minus: db "minus", 0
    operation_times: db "times", 0

    operations:
        dq operation_plus
        dq operation_plus
        dq operation_minus
        dq operation_minus
        dq operation_times
        dq operation_times
        dq operation_times

    operationFuncs:
        dq addition
        dq addition
        dq subtraction
        dq subtraction
        dq multiplication
        dq multiplication
        dq multiplication

    bump1: db "Hmpf. If that's so easy, let's crank it up a notch.", 0
    bump2: db "Alright, smart guy. Try this on for size, eh?", 0
    bump3: db "I didn't want to have to do this, but it's time to break out the big guns.", 0
    bump4: db "You're more resilient than I thought, huh? Well, we'll see if that continues.", 0
    bump5: db "Alright, fine. You've proved you're smarter than a second grader. But are you sure you can keep up?", 0
    bump6: db "Fine. Fine. I concede. You've beaten me. Continue as long as you want, I don't have anything harder for you.", 0

    bumps:
        dq bump1
        dq bump2
        dq bump3
        dq bump4
        dq bump5
        dq bump6
    
    bumpFuncs:
        dq bumpToHardAddition
        dq bumpToSubtraction
        dq bumpToHardSubtraction
        dq bumpToMultiplication
        dq bumpToHardMultiplication
        dq bumpToNoMoreWorldsToConquer

    ; chatgpt ahh feature but it's mine
    roast0: db "My god, are you even TRYING?", 0
    roast1: db "Please, for both of our sakes, just stop.", 0
    roast2: db "Who taught you math!? Oh, wait, I did. Nevermind.", 0
    roast3: db "Did your parents like, drop you on your head as a child?", 0
    roast4: db "Can someone check if he's drunk? No, like, genuinely.", 0
    roast5: db "Wrong-o, bucko! Try again. Or don't. Your choice, really.", 0
    roast6: db "I do NOT get paid enough to try correcting this behaviour.", 0
    roast7: db "I think I need hazard pay... reading this is genuinely reducing my thinking capacity.", 0
    roast8: db "nahhhhh!!!", 0
    roast9: db "*the teacher says nothing and takes a sip from a nondescript metal container*", 0

    roasts:
        dq roast0
        dq roast1
        dq roast2
        dq roast3
        dq roast4
        dq roast5
        dq roast6
        dq roast7
        dq roast8
        dq roast9

    roastGiveAnswer: db "The answer, FYI, was %d. Not whatever %d is supposed to be. Just so you know, dingus.", 10, 0

    backhandedCompliment0: db "Really? I'd'a never guessed!", 0
    backhandedCompliment1: db "That's nice, dear. Don't mess up further.", 0
    backhandedCompliment2: db "Keep it up, and you might get a nice scholarship to the local community college.", 0
    backhandedCompliment3: db "hmm, too easy.", 0
    backhandedCompliment4: db "You know the idea of ", 34, "stumbling through life", 34, "? Somehow, you're doing it. Congrats.", 0
    backhandedCompliment5: db "The local preschoolers marvel at your vast intellect, I'm sure.", 0
    backhandedCompliment6: db "Oh, dear. Did the lone brain cell finally activate?", 0
    backhandedCompliment7: db "Well, colour me surprised. Didn't think you'd get it, honestly.", 0
    backhandedCompliment8: db "Genuinely, who are you trying to impress? Not me, that's for sure.", 0
    backhandedCompliment9: db "You know, I'm almost proud of you. Almost.", 0

    backhandedCompliments:
        dq backhandedCompliment0
        dq backhandedCompliment1
        dq backhandedCompliment2
        dq backhandedCompliment3
        dq backhandedCompliment4
        dq backhandedCompliment5
        dq backhandedCompliment6
        dq backhandedCompliment7
        dq backhandedCompliment8
        dq backhandedCompliment9

section .bss
    numb: resd 1
    rightAnswers: resd 1
    questionsAsked: resd 1