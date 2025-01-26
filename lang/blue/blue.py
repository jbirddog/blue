import sys

sys.path.insert(0, "..")

from bluevm import lit_by_len, op_byte

milestone = """
: syscall (( num eax -- res eax )) 0F b, 05 b, ;
: exit (( status edi -- noret )) 3C syscall ;
: bye (( -- noret )) 00 exit ;

bye
"""

prog = sys.stdin.read()
output = []


def next_token():
    parts = prog.split(maxsplit=1)
    return parts if len(parts) == 2 else [parts[0], ""]

def compile_number(n):
    b = [bytes([b]) for b in bytes.fromhex(n)]
    op = lit_by_len[len(b)]
    return [op_byte[op]] + b

while prog:
    token, prog = next_token()

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
