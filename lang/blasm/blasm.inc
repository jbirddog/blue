
iterate <opname, opsize>, \
	exit, 1, \
	true, 1, \
	false, 1, \

	#opname.code = % - 1

	match =1, opsize
		calminstruction #opname
			emit 1, % - 1
		end calminstruction
	else
		calminstruction #opname val
			emit 1, % - 1
			emit (opsize - 1), val
		end calminstruction
	end match
end iterate

calminstruction callop op
	emit 1, op
end calminstruction
