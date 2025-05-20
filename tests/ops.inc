; Generated from ops.inc.tmpl

iterate <opname, opsize>, \
	asrt, 1, \

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
