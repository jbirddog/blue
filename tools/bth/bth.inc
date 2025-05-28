; Generated from bth.inc.tmpl

iterate <opname, opsize>, \
	atq, 1, \
	ifnot, 1, \
	chkargc, 1, \
	cmovd, 1, \
	cmovq, 1, \
	cret, 1, \
	cstosd, 1, \
	csys, 1, \
	cxord, 1, \
	tfd, 1, \
	oblk, 1, \
	thr, 1, \
	setthr, 1, \
	argv1, 1, \
	cdstarg, 1, \
	cflgsro, 1, \
	csopen, 1, \
	cdsttfd, 1, \
	cfrmtfd, 1, \
	csrctib, 1, \
	cblklen, 1, \
	csread, 1, \
	opentst, 1, \
	readtst, 1, \
	runtst, 1, \
	endl, 1, \
	woka, 1, \
	wprep, 1, \
	wlen, 1, \
	waddr, 1, \
	test, 1, \
	plan, 1, \
	ok, 1, \
	notok, 1, \
	okif, 1, \
	okeq, 1, \
	okne, 1, \
	ok0, 1, \
	okn0, 1, \
	done, 1, \

	op_##opname##_code = % - 1 + 0x80 

	match =1, opsize
		calminstruction #opname
			emit 1, % - 1 + 0x80
		end calminstruction
	else
		calminstruction #opname val
			emit 1, % - 1 + 0x80
			emit (opsize - 1), val
		end calminstruction
	end match
end iterate
