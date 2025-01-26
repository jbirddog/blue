import sys

sys.path.insert(0, "..")

from bluevm import lit_by_len, op_byte

milestone = """
: syscall (( num eax -- res eax )) 0F b, 05 b, ;
: exit (( status edi -- noret )) 3C syscall ;
: bye (( -- noret )) 00 exit ;

bye
"""

class ParserCtx:
    def __init__(self, prog):
        self.prog = prog

output = []


def next_token(ctx):
    parts = ctx.prog.split(maxsplit=1)
    l = len(parts)
    ctx.prog = parts[1] if l == 2 else None
    return parts[0]

def compile_number(n):
    b = bytes.fromhex(n)
    op = lit_by_len[len(b)]
    return [op_byte[op], b]

if __name__ == "__main__":
    prog = sys.stdin.read()
    parser_ctx = ParserCtx(prog)
    
    while parser_ctx.prog:
        token = next_token(parser_ctx)

        if token in op_byte:
            output.append(op_byte[token])
        else:
            output.extend(compile_number(token))
    
    output.extend([
        op_byte["here"], op_byte["litb"], bytes([12]), op_byte["-"], op_byte["mccall"],

        op_byte["depth"],
        op_byte["exit"],
    ])

    sys.stdout.buffer.write(b"".join(output))
