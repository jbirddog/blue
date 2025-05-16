
iterate <opname, opsize>, \
	exit, 1, \
	true, 1, \
	false, 1, \
	ifelse, 1, \
	mccall, 1, \
	call, 1, \
	tor, 1, \
	fromr, 1, \
	ret, 1, \
	comp, 1, \
	endcomp, 1, \
	ip, 1, \
	setip, 1, \
	entry, 1, \
	start, 1, \
	here, 1, \
	sethere, 1, \

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
