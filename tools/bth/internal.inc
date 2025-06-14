; Generated from inc.tmpl

iterate <opname, opsize>, \
	atq, 1, \
	ifnot, 1, \
	chkargc, 1, \
	tfd, 1, \
	oblk, 1, \
	thr, 1, \
	setthr, 1, \
	argv1, 1, \
	opentst, 1, \
	readtst, 1, \
	runtst, 1, \
	endl, 1, \
	woka, 1, \
	tapout, 1, \

	op_##opname##_code = % - 1 + 0x80

	calminstruction #opname
		emit 1, op_##opname##_code
	end calminstruction
end iterate
