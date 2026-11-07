; Strict Teacher, improved by ya boy tuvalutorture :D
; sadly, clear of profanity, as i am submitting this to a club for fellow teens
; i would have loved to be quite profane
; oh well

bits 64

global main
extern printf, scanf, puts, rand, srand, time, getchar
; for rand, number stored in EAX
; for time, in RAX

section .text
    ; Farhan babar the goat
    ;          ^
    ;          |
    ;          |
    ;         ???
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
        call puts

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
            cmp [rel didJustChangeDifficulty], 0
            je .get_nums
            call printDifficulty
            mov [rel didJustChangeDifficulty], 0
            .get_nums: ; while (r12d == r13d && r12d && r13d).
                ; 1st random
                call randomiser
                inc edx ; nullifies the need for zero checking, plus sets the upper bound correctly to the divisor (rather than one below)
                mov r12d, edx
                ; 2nd random
                call randomiser
                inc edx
                mov r13d, edx
                cmp r12d, r13d ; this prevents us from getting equality (which means subtraction won't equal 0)
                je .get_nums 
                
                cmp r14, 2 ; for easy subtraction mode
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

                .get_answer:
                    ; scanning for question
                    lea rcx, [rel format] ; loads format string
                    lea rdx, [rel numb] ; sets input
                    call scanf
                    cmp eax, 0
                    jne .compare_to_quit
                    call clearStdin
                    lea rcx, [rel inputWasNotNumber]
                    call puts
                    jmp .get_answer
                
                .compare_to_quit:
                    call clearStdin
                    cmp [rel numb], 0
                    je taunt_and_bail

                inc [rel questionsAsked] ; question went through, so we inc
                
                lea rbx, [rel operationFuncs]
                call [rbx + r14 * 8] ; math to get the current math function
                cmp r12d, [rel numb] ; compare it to the input
                je is_correct

                xor r15, r15
                inc [rel hasBeenCooked]
                call debump
                lea rcx, [rel isDoingSoBadlyTheyAreBeyondSalvation]
                cmp rcx, rbx
                je dont_even_bother_printing_out
                lea rbx, [rel roasts]
                jmp done

            is_correct:
                mov [rel hasBeenCooked], 0 
                inc [rel rightAnswers]
                inc r15
                call check_bump
                lea rbx, [rel backhandedCompliments]
                cmp eax, 0
                jne loop
            
            done: 
                .pick_random:
                    call rand
                    xor edx, edx
                    mov ecx, 10
                    div ecx
                    cmp edx, [rel lastRandom] ; it's uninitialised but it should be fine, worst case we get an extra loop iter.
                    mov [rel lastRandom], edx
                    je .pick_random ; prevents same thing from printing twice in a row 
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
                jmp loop
        

        taunt_and_bail:
            ; taunt the user a lil bit
            lea rcx, [rel endingMessage]
            mov edx, [rel questionsAsked]
            mov r8d, [rel rightAnswers]
            mov r9d, [rel questionsAsked]
            call printf
        
            xor rax, rax
            mov eax, [rel rightAnswers]
            cmp eax, 0 ; nothing right at ALL
            jne .get_grade
            mov eax, 0 ; F
            jmp .print_grade
            .get_grade:
                mov ecx, 5
                mul ecx
                mov ecx, [rel questionsAsked]
                xor edx, edx
                div ecx
                cmp eax, 0 ; riiiiight, it can also be below 0 on accident. lovely
                je .print_grade 
                dec eax
            .print_grade:
                lea rbx, [rel grades]
                lea rcx, [rel gradeString]
                mov rdx, [rbx + rax * 8]
                call printf

        dont_even_bother_printing_out:
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
                inc r14
                lea rbx, [rel bumpFuncs]
                call [rbx + r14 * 8]
                xor r15, r15
                mov eax, 1
                mov [rel didJustChangeDifficulty], 1
        .return:
            add rsp, 40
            ret

    debump:
        sub rsp, 40
        cmp [rel hasBeenCooked], 5
        jnae .bail
        cmp r14, 0
        jne .decrement
        lea rcx, [rel isDoingSoBadlyTheyAreBeyondSalvation]
        mov rbx, rcx
        call puts
        mov [rel numb], 0
        jmp .bail
        .decrement:
            lea rcx, [rel isGenuinelyDoingAwful]
            call puts
            dec r14
            lea rbx, [rel bumpFuncs]
            call [rbx + r14 * 8]
            mov [rel hasBeenCooked], 0
            mov [rel didJustChangeDifficulty], 1
        .bail:
            add rsp, 40
            ret

    bumpToAddition:
        mov qword [rel streakForBump], 5
        mov dword [rel divisor], 10
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

    printDifficulty:
        sub rsp, 40
        lea rcx, [rel divider]
        call puts
        lea rbx, [rel diffs]
        mov rcx, [rbx + r14 * 8]
        mov rdx, r14
        inc rdx
        call printf
        lea rcx, [rel diffFormat]
        lea rbx, [rel operationNames]
        mov rdx, [rbx + r14 * 8]
        call printf
        lea rcx, [rel divider]
        call puts
        add rsp, 40
        ret

    clearStdin:
        sub rsp, 40
        .get_next:
            call getchar
            cmp eax, 10
            je .bail
            cmp eax, -1
            jne .get_next
        .bail:
            add rsp, 40
            ret

section .data
    msg1: db 27, "[35m", "Boy, you better get these questions right >:[", 27, "[0m", 27, "[31m", " (or press", 27, "[0m", 27, "[33m", " 0 ", 27, "[0m", 27, "[31m", "to chicken out)", 27, "[0m", 0
    msg2: db "What is %d %s %d?: ", 10, 0

    didJustChangeDifficulty: dq 1

    endingMessage: 
        db 27, "[35m"
        db "Are you really chickening out? After %d question(s)?", 10
        db "Fine. You got %d/%d correct.", 10
        db "Come back tmr, or else... (you'll be reported truant if you don't :3)", 10
        db 27, "[0m", 0

    format: db "%d", 0

    divisor: dd 10

    streakForBump: dq 5

    operation_plus: db 27, "[33m", "plus", 27, "[0m", 0
    operation_minus: db 27, "[33m", "minus", 27, "[0m", 0
    operation_times: db 27, "[33m", "times", 27, "[0m", 0

    operations:
        dq operation_plus
        dq operation_plus
        dq operation_minus
        dq operation_minus
        dq operation_times
        dq operation_times
        dq operation_times

    operation_addition: db "addition", 0
    operation_subtraction: db "subtraction", 0
    operation_multiplication: db "multiplication", 0

    operationNames:
        dq operation_addition
        dq operation_addition
        dq operation_subtraction
        dq operation_subtraction
        dq operation_multiplication
        dq operation_multiplication
        dq operation_multiplication

    operationFuncs:
        dq addition
        dq addition
        dq subtraction
        dq subtraction
        dq multiplication
        dq multiplication
        dq multiplication

    bump1: db 27, "[36m", "Hmpf. If that's so easy, let's crank it up a notch.", 27, "[0m", 0
    bump2: db 27, "[36m", "Alright, smart guy. Try this on for size, eh?", 27, "[0m", 0
    bump3: db 27, "[36m", "I didn't want to have to do this, but it's time to break out the big guns.", 27, "[0m", 0
    bump4: db 27, "[36m", "You're more resilient than I thought, huh? Well, we'll see if that continues.", 27, "[0m", 0
    bump5: db 27, "[36m", "Alright, fine. You've proved you're smarter than a second grader. But are you sure you can keep up?", 27, "[0m", 0
    bump6: db 27, "[36m", "Fine. Fine. I concede. You've beaten me. Continue as long as you want, I don't have anything harder for you.", 27, "[0m", 0

    bumps:
        dq bump1
        dq bump2
        dq bump3
        dq bump4
        dq bump5
        dq bump6
    
    bumpFuncs:
        dq bumpToAddition
        dq bumpToHardAddition
        dq bumpToSubtraction
        dq bumpToHardSubtraction
        dq bumpToMultiplication
        dq bumpToHardMultiplication
        dq bumpToNoMoreWorldsToConquer

    ; chatgpt ahh feature but it's mine
    roast0: db 27, "[31m", "My god, are you even TRYING?", 27, "[0m", 0
    roast1: db 27, "[31m", "Please, for both of our sakes, just stop.", 27, "[0m", 0
    roast2: db 27, "[31m", "Who taught you math!? Oh, wait, I did. Nevermind.", 27, "[0m", 0
    roast3: db 27, "[31m", "Did your parents like, drop you on your head as a child?", 27, "[0m", 0
    roast4: db 27, "[31m", "Can someone check if he's drunk? No, like, genuinely.", 27, "[0m", 0
    roast5: db 27, "[31m", "Wrong-o, bucko! Try again. Or don't. Your choice, really.", 27, "[0m", 0
    roast6: db 27, "[31m", "I do NOT get paid enough to try correcting this behaviour.", 27, "[0m", 0
    roast7: db 27, "[31m", "I think I need hazard pay... reading this is genuinely reducing my thinking capacity.", 27, "[0m", 0
    roast8: db 27, "[31m", "nahhhhh!!!", 27, "[0m", 0
    roast9: db 27, "[31m", "*the teacher says nothing and takes a sip from a nondescript metal container*", 27, "[0m", 0

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

    roastGiveAnswer: db 27, "[33m", "The answer, FYI, was %d. Not whatever %d is supposed to be. Just so you know, dingus.", 27, "[0m", 10, 0

    backhandedCompliment0: db 27, "[32m", "Really? I'd'a never guessed!", 27, "[0m", 0
    backhandedCompliment1: db 27, "[32m", "That's nice, dear. Don't mess up further.", 27, "[0m", 0
    backhandedCompliment2: db 27, "[32m", "Keep it up, and you might get a nice scholarship to the local community college.", 27, "[0m", 0
    backhandedCompliment3: db 27, "[32m", "hmm, too easy.", 27, "[0m", 0
    backhandedCompliment4: db 27, "[32m", "You know the idea of ", 34, "stumbling through life", 34, "? Somehow, you're doing it. Congrats.", 27, "[0m", 0
    backhandedCompliment5: db 27, "[32m", "The local preschoolers marvel at your vast intellect, I'm sure.", 27, "[0m", 0
    backhandedCompliment6: db 27, "[32m", "Oh, dear. Did the lone brain cell finally activate?", 27, "[0m", 0
    backhandedCompliment7: db 27, "[32m", "Well, colour me surprised. Didn't think you'd get it, honestly.", 27, "[0m", 0
    backhandedCompliment8: db 27, "[32m", "Genuinely, who are you trying to impress? Not me, that's for sure.", 27, "[0m", 0
    backhandedCompliment9: db 27, "[32m", "You know, I'm almost proud of you. Almost.", 27, "[0m", 0

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

    isGenuinelyDoingAwful: 
        db 27, "[32m"
        db "Dear. God. You are GENUINELY awful at this.", 10
        db "You know what? You're going backwards.", 10
        db "That's right. Because you can't seem to get *A N Y T H I N G* right!", 10
        db "So maybe a slower change of pace will help you ACTUALLY accomplish something in your god-forsaken life. How's that?"
        db 27, "[0m", 0

    isDoingSoBadlyTheyAreBeyondSalvation: 
        db 27, "[32m"
        db "How. Just. How. You are doing math at the level of a PRESCHOOLER.", 10
        db "AND YET, BY GOD'S GOOD GRACES, YOU HAVE FAILED THAT TOO.", 10
        db "Just get out. Genuinely.", 10
        db "Adios, bye, ciao, cya later, just not in MY classroom, for ritchie's sakes."
        db 27, "[0m", 0

    divider: db "---------------------------", 0

    diff1: db "%d: ez mode", 0
    diff2: db "%d: okay is warming up", 0
    diff3: db "%d: ok but have ya tried carrying the one yet?", 0
    diff4: db "%d: wow those numbers are big", 0
    diff5: db "%d: ummm, what", 0
    diff6: db "%d: quite warm in here innit fellas", 0
    diff7: db 27, "[31m", "%d: dear lord dennis ritchie, what have i gotten myself into", 27, "[0m", 0

    diffFormat: db " (", 27, "[33m", "%s", 27, "[0m", ")", 10, 0

    diffs:
        dq diff1
        dq diff2
        dq diff3
        dq diff4
        dq diff5
        dq diff6
        dq diff7

    inputWasNotNumber: db 27, "[31m", "Genuinely, what was that? That was not a number. Try again.", 27, "[0m", 0

    gradeA: db 27, "[32m", "A", 27, "[0m", 0
    gradeB: db 27, "[36m", "B", 27, "[0m", 0
    gradeC: db 27, "[33m", "C", 27, "[0m", 0
    gradeD: db 27, "[35m", "D", 27, "[0m", 0
    gradeF: db 27, "[31m", "F", 27, "[0m", 0

    gradeString: db "Your final ", 27, "[33m", "grade", 27, "[0m", ": %s", 10, 0

    grades:
        dq gradeF
        dq gradeD
        dq gradeC
        dq gradeB
        dq gradeA
        

section .bss
    numb: resd 1
    rightAnswers: resd 1
    questionsAsked: resd 1
    hasBeenCooked: resd 1
    lastRandom: resd 1

; YOU'RE SO COLD KEEP YOUR
; HAND IN MINE
; WISE MEN WONDER WHILE
; STRONG MEN DIE
; or something idk, i'm just quoting my mans Boinkout Benjamin ykyk