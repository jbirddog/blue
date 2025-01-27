import sys
from collections import namedtuple
from dataclasses import dataclass, field

sys.path.append("..")

from bluevm import lit_by_len, op_byte

#
# parse
#

LitInt = namedtuple("LitInt", ["val"])
BlueVMOp = namedtuple("BlueVMOp", ["op"])

#WordDecl = namedtuple("WordDecl", ["name", "flags", "ins", "outs", "nodes"])
TopLevel = namedtuple("TopLevel", ["nodes"])

@dataclass
class ParserCtx:
    prog: str
    base: int = 16
    #compiling: bool = False
    #latest: WordDecl = None
    #words: dict = field(default_factory=dict)
    nodes: list = field(default_factory=list)

def next_token(ctx):
    parts = ctx.prog.split(maxsplit=1)
    ctx.prog = parts[1] if len(parts) == 2 else None
    return parts[0]

def parse(ctx):
    ctx.nodes.append(TopLevel([]))
    
    while ctx.prog:
        token = next_token(ctx)
        nodes = ctx.nodes[-1].nodes

        if token in op_byte:
            nodes.append(BlueVMOp(token))
        else:
            nodes.append(LitInt(int(token, ctx.base)))

#
# lower
#

def lower_node(node, lowered):
    match node:
        case BlueVMOp(op):
            lowered.append(node)
        case LitInt(val):
            lowered.append(node)
        case _:
            raise Exception(f"Unsupported nodes: {node}")

def lower(nodes):
    lowered = []
    for node in nodes:
        match node:
            case TopLevel(nodes):
                for node in nodes:
                    lower_node(node, lowered)
            case _:
                raise Exception(f"Unsupported node: {node}") 
    return lowered

#
# compile
#

def compile(lowered):
    output = []
    for l in lowered:
        match l:
            case BlueVMOp(op):
                output.append(op_byte[op])
            case LitInt(val):
                b = bytes([val])
                op = lit_by_len[len(b)]
                output.extend([op_byte[op], b])
            case _:
                raise Exception(f"Unsupported nodes: {node}")
    return b"".join(output)


if __name__ == "__main__":
    prog = sys.stdin.read()
    parser_ctx = ParserCtx(prog)

    parse(parser_ctx)
    lowered = lower(parser_ctx.nodes)

    lowered.extend([
        #BlueVMOp("here"),
        #LitInt(12),
        #BlueVMOp("-"),
        #BlueVMOp("mccall"),
        
        BlueVMOp("depth"),
        BlueVMOp("exit"),
    ])

    output = compile(lowered)
    
    sys.stdout.buffer.write(output)
