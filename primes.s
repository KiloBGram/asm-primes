.global main

.data # Read and write permissions


.text # Read-only part of code

templateNewline: .asciz "%ld\n"
template: .asciz "%ld"
enterLower: .asciz "|PRIME NUMBER FINDER|\nEnter lower search bound: "
enterUpper: .asciz "Enter upper search bound: "

main:
    # Prologue
    pushq %rbp
    movq %rsp, %rbp

    movq $enterLower, %rdi # sets first param for printf to welcome message
    xorq %rax, %rax # sets %rax to 0 for printf
    call printf

    subq $16, %rsp 
    #    ^ moves the stack pointer 16 bytes down. You have to do this to get 16 byte alignment, otherwise subroutine calls will segfault.
    # The free space is used for the two numbers we ask the user for. The nearest 8 bytes are for the lower bound and the furthest for the upper.
    
    
    leaq (%rsp), %rsi # the adress of the stack pointer is now the adress of the upperBound variable
    movq $template, %rdi # template string as first arg for scanf
    xorq %rax, %rax # set %rax to 0 for scanf reasons
    call scanf #scanf(templateString, pointerToStore)

    movq $enterUpper, %rdi # sets first param for printf to welcome message
    xorq %rax, %rax # sets %rax to 0 for printf
    call printf

    leaq 8(%rsp), %rsi # the lowerBound variable is 8 bytes higher than the stack pointer
    movq $template, %rdi # move the template string into the first argument
    xorq %rax, %rax # sets %rax to 0 for scanf
    call scanf

    popq %rdi # pop the lower bound into first arg
    popq %rsi # pop the upper bound into secod arg

    cmpq %rdi, %rsi # if the upperBound is less than or equal to lowerBound, then there are no primes to find
    jle end

    call primesBetween # primesBetween(lowerBound, upperBound)

end:
    # Epilogue
    movq %rbp, %rsp
    popq %rbp

    movq $0, %rdi
    call exit

/*
void primesBetween(int start, int end) {
    while(start != end) {
        if(isPrime(start)) {
            printf("%ld\n", start);
        }

        start = start + 1;
    }
}
*/
primesBetween:
    # Prologue
    pushq %rbp
    movq %rsp, %rbp

primesBetweenLoop:
    cmpq %rdi, %rsi # If start == end, then exit the loop
    je primesBetweenEnd

    # Push variables to stack to avoid losing them during subroutine call
    pushq %rdi # start
    pushq %rsi # end

    call isPrime

    # Pop variables from stack in reverse order
    popq %rsi # end
    popq %rdi # start

    cmpq $1, %rax
    je primesBetweenPrint

primesBetweenReturn:
    incq %rdi # start = start + 1;
    jmp primesBetweenLoop # Jump back to start of loop

primesBetweenEnd:
    # Epilogue
    movq %rbp, %rsp
    popq %rbp
    ret

primesBetweenPrint:
    # Push variables to stack to avoid losing them during printf call
    pushq %rdi # start
    pushq %rsi # end

    movq %rdi, %rsi # Move the start variable into the second argument register
    movq $templateNewline, %rdi # Move the template string pointer into the first argument register
    xorq %rax, %rax #XORing a register with itself sets it to zero. Sets %rax to zero so that printf doesn't use the 128bit registers
    call printf

    # Pop variables from stack in reverse order
    popq %rsi # end
    popq %rdi # start

    jmp primesBetweenReturn
/*
bool isPrime(int number) {
    int index = 2;
    bool isPrime = true;

    if(number < 2) return false;
    if(number == 2) return true;

    while((index * index) < number) {
        if(number % index == 0) {
            isPrime = false;
            break;
        }
        index = index + 1;
    }

    return isPrime;
}
*/
isPrime:
    # Prologue
    pushq %rbp
    movq %rsp, %rbp

    pushq %r12 #save the previous value of %r12 just in case something else needs it

    movq $2, %r12 # Sets index to 2
    movq $1, %rcx # bool isPrime = true

    cmpq $2, %rdi # compares the passed number to 2
    jl isPrimeFalse # if it is less than 2, the number is not prime
    je isPrimeTrue # if it is equal to 2, the number is prime
    # otherwise, continue executing

isPrimeLoop:
    movq %r12, %rax # move the index into %rax because multiplication happens with %rax and the parameter
    imul %rax, %rax # square the index and store the result in %rax
    cmpq %rax, %rdi # if the squared index is greater than the number, exit the loop

    jl isPrimeEnd
    je isPrimeFalse # if the numbers are equal, then the number has a square root and is therefore not prime

    movq %rdi, %rax # move the number into %rax for dividing
    movq $0, %rdx
    divq %r12 # %rdx = number % index
    cmpq $0, %rdx # if the result is 0 the number is not prime

    je isPrimeFalse

    # Else continue executing
    incq %r12 #index = index + 1
    jmp isPrimeLoop

isPrimeTrue:
    movq $1, %rcx
    jmp isPrimeEnd

isPrimeFalse: # if the program gets here the number is not prime. 
    movq $0, %rcx # isPrime = false;$

isPrimeEnd:
    movq %rcx, %rax # return isPrime;

    # Epilogue
    popq %r12 # Return the value of %r12 to its state before the subroutine was called
    movq %rbp, %rsp
    popq %rbp
    ret
