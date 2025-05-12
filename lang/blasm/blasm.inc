
iterate <opname, opsize>, \
	exit, 1, \
	true, 1, \
	false, 1, \
	ifelse, 1, \
	mccall, 1, \
	call, 1, \
	tor, 1, \
	fromr, 1, \
	compile, 1, \
	interpret, 1, \
	ip, 1, \
	setip, 1, \
	entry, 1, \
	start, 1, \
	here, 1, \
	sethere, 1, \
	litb, 2, \
	litw, 3, \
	litd, 5, \
	litq, 9, \

	match =1, opsize
		calminstruction #opname
			emit 1, % - 1
		end calminstruction
	else
		calminstruction #opname val
			;emit 1, % - 1
			emit 1, 33
			emit (opsize - 1), val
		end calminstruction
	end match
end iterate
