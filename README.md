# Microntrollers-Midterm-4-Bit-ALU

This program is a 4 bit ALU on the NUCLEO-F446RE board. The arithmetic functions it can perform are addition and subtraction.
The logical functions it can perform are bitwise INV, AND, OR, NAND, NOR, and XOR. 

The ALU takes input in three stages, the first being the first four-bit number, the second being the selector for the 
arithmetic/logic operation being performed, and the final being the second four-bit number. All of these inputs are taken 
sequentially using the same 4 switch dip-switch, where a button on the NUCLEO board is used to confirm the input and move 
on to the next stage. Since internal pull-up resistors are used with the switches, the inputs are then inverted to make 
them easier to work with, then have everything except the least significant nibble masked out for all three. At this stage 
a conditional ladder is used to determine which operation to perform based on the operation input.

Video of overview & verification: https://www.youtube.com/watch?v=tDFA8UCyC84&t=3s
