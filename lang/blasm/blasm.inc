
calminstruction exit
	arrange opcode, =db 0
	assemble opcode
end calminstruction

calminstruction litb b
	arrange opcode, =db 33
	arrange val, =db b
	assemble opcode
	assemble val
end calminstruction
