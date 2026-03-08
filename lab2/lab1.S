// if (a − b) > 0, (a - b) * 3 + 2^c
// elif (a | c) == 0, (a & b) + c 
// else a + b


.syntax unified
.cpu cortex-m4
.thumb
.global lab1
.type lab1, %function
.type calculate, %function

#define a #0
#define b #3
#define c #0
lab1:
  push {lr}
  mov r0, a
  mov r1, b
  mov r2, c
  bl calculate
  pop {pc}

calculate:
  push {r4, r5, lr}

  subs r4, r0, r1 //(a − b), r0-r1, 5-2=3
  bgt branch_1

  orrs r4, r0, r2 //(a | c)
  bne branch_3 

  and r0, r0, r1 //(a & b)
  add r0, r0, r2 //(a & b) + c 
  pop {r4, r5, pc}

branch_1:
  mov r5, #3
  mul r4, r5, r4 //(a − b)*3
  mov r5, #1
  lsl r5, r5, r2  //2^c
  add r0, r4, r5 //(a − b)*3+2^c
  pop {r4, r5, pc}

branch_3:
  add r0, r0, r1 //a+b
  pop {r4, r5, pc}


//#define a #5
//#define b #2
//#define c #3
//r0 = 17

//#define a #0
//#define b #3
//#define c #0
//r0 = 0

//#define a #1
//#define b #3
//#define c #1
//r0 = 4
