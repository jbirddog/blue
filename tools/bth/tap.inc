; Generated from inc.tmpl

iterate <opname, opsize>, \
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

	op_##opname##_code = % - 1 + 0xC0

	calminstruction #opname
		emit 1, op_##opname##_code
	end calminstruction
end iterate
