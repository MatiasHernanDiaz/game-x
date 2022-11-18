# game-x
This is a project for the first year of university (assembly)

Se trata de un juego sencillo creado en assembler que corre en una maquina virtual con un procesador
intel 8086

Participaron en este proyecto Diaz, Matias -  Narmontas Theo - Pabon Anyair - Perez Adrian 

Juego: Capturar las O. Gana cuando se llega a 10, pierde si deja pasar 10.

Consta de un main, una libreria de funciones y una interrupcion a instalar con tasem y tlink.

tasem.exe int.asm

tlink /t int.o

int.com

tasem.exe main.asm

tasem.exe lib.asm

tlink main.o lib.o

main.exe
