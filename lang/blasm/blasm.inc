; Generated from blasm.inc.tmpl

iterate <opname, opsize>, \
	halt, 1, \
	argc, 1, \
	argv, 1, \
	scall0, 1, \
	scall1, 1, \
	scall2, 1, \
	scall3, 1, \
	scall4, 1, \
	scall5, 1, \
	scall6, 1, \
	blk, 1, \
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
	opentry, 1, \
	setvarb, 1, \
	setvarw, 1, \
	setvard, 1, \
	setvarq, 1, \
	ip, 1, \
	setip, 1, \
	here, 1, \
	atincb, 1, \
	atincw, 1, \
	atincd, 1, \
	atincq, 1, \
	setincb, 1, \
	setincw, 1, \
	setincd, 1, \
	setincq, 1, \
	cb, 1, \
	cw, 1, \
	cd, 1, \
	cq, 1, \
	litb, 2, \
	litw, 3, \
	litd, 5, \
	litq, 9, \
	depth, 1, \
	dup, 1, \
	drop, 1, \
	swap, 1, \
	not, 1, \
	eq, 1, \
	add, 1, \
	sub, 1, \
	and, 1, \
	or, 1, \
	shl, 1, \
	shr, 1, \

	op_##opname##_code = % - 1 

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

calminstruction litop op
	emit 1, op
end calminstruction

postpone
	db (1024 - $) dup 0
end postpone
