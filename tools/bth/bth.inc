; Generated from bth.inc.tmpl

iterate <opname, opsize>, \
	tst, 1, \
	thr, 1, \
	thrM, 1, \
	setthr, 1, \
	endl, 1, \
	test, 1, \
	plan, 1, \
	wokA, 1, \
	wok, 1, \
	notok, 1, \
	ok, 1, \
	okeq, 1, \
	okne, 1, \
	done, 1, \

	#opname.code = % - 1

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
