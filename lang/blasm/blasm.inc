
iterate <opname, opsize>, \
	exit, 1, \
	true, 1, \
	false, 1, \

	calminstruction #opname
		arrange opcode, =db (% - 1)
		assemble opcode
	end calminstruction
end iterate

calminstruction litb val
	arrange opcode, =db 33
	arrange val, =db val
	assemble opcode
	assemble val
end calminstruction
