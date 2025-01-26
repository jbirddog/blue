import sys
from collections import namedtuple

sys.path.append("..")

from bluevm import lit_by_len, op_byte

milestone = """
: syscall (( num eax -- res eax )) 0F b, 05 b, ;
: exit (( status edi -- noret )) 3C syscall ;
: bye (( -- noret )) 00 exit ;

bye
"""

MaybeLitNum = namedtuple("MaybeLitNum", ["val"])
BlueVMOp = namedtuple("BlueVMOp", ["op"])

class ParserCtx:
    def __init__(self, prog):
        self.prog = prog
        self.nodes = []

def next_token(ctx):
    parts = ctx.prog.split(maxsplit=1)
    ctx.prog = parts[1] if len(parts) == 2 else None
    return parts[0]

def parse(ctx):
    while ctx.prog:
        token = next_token(ctx)

        if token in op_byte:
            ctx.nodes.append(BlueVMOp(token))
        else:
            ctx.nodes.append(MaybeLitNum(token))

def compile_number(n):
    b = bytes.fromhex(n)
    op = lit_by_len[len(b)]
    return [op_byte[op], b]

if __name__ == "__main__":
    prog = sys.stdin.read()
    parser_ctx = ParserCtx(prog)
    output = []

    parse(parser_ctx)
    
    output.extend([
        #op_byte["here"], op_byte["litb"], bytes([12]), op_byte["-"], op_byte["mccall"],

        op_byte["depth"],
        op_byte["depth"],
        op_byte["exit"],
    ])

    sys.stdout.buffer.write(b"".join(output))
