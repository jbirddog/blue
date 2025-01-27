import sys
from collections import namedtuple
from dataclasses import dataclass, field

sys.path.append("..")

from bluevm import lit_by_len, op_byte

#
# custom opcodes
#

op_byte["blue:wa!"] = 0x81
op_byte["blue:wa"] = 0x82

#
# parse
#

BlueVMOp = namedtuple("BlueVMOp", ["op"])
CallWord = namedtuple("CallWord", ["word", "idx"])
LitInt = namedtuple("LitInt", ["val"])

TopLevel = namedtuple("TopLevel", ["nodes"])
WordDecl = namedtuple("WordDecl", ["nodes"])

@dataclass
class ParserCtx:
    prog: str
    base: int = 16
    compiling: bool = False
    latest: WordDecl = None
    words: list = field(default_factory=list)
    word_idx: dict = field(default_factory=dict)
    nodes: list = field(default_factory=list)


def colon(ctx):
    name = next_token(ctx)
    word = WordDecl([])
    ctx.word_idx[name] = len(ctx.words)
    ctx.words.append(word)
    ctx.latest = word
    ctx.nodes.append(word)
    ctx.compiling = True

def double_lparen(ctx):
    while ctx.prog:
        token = next_token(ctx)
        if token == "))":
            break

def semi(ctx):
    ctx.latest.nodes.extend([LitInt(0xC3), BlueVMOp("b,")])
    ctx.nodes.append(TopLevel([]))
    ctx.compiling = False

kw = {
    ":": colon,
    "((": double_lparen,
    ";": semi,
}
    
def next_token(ctx):
    parts = ctx.prog.split(maxsplit=1)
    ctx.prog = parts[1] if len(parts) == 2 else None
    return parts[0]

def parse(ctx):
    ctx.nodes.append(TopLevel([]))
    
    while ctx.prog:
        token = next_token(ctx)
        nodes = ctx.nodes[-1].nodes

        if token in ctx.word_idx:
            idx = ctx.word_idx[token]
            nodes.append(CallWord(ctx.words[idx], idx))
        elif token in kw:
            kw[token](ctx)
        elif token in op_byte:
            nodes.append(BlueVMOp(token))
        else:
            nodes.append(LitInt(int(token, ctx.base)))

#
# lower
#

def lower_node(node, lowered):
    match node:
        case BlueVMOp(_) | LitInt(_):
            lowered.append(node)
        case CallWord(word, idx):
            lowered.extend([LitInt(idx), BlueVMOp("start"), BlueVMOp("+"), BlueVMOp("mccall")])
        case _:
            raise Exception(f"Unsupported node: {node}")

def lower(nodes):
    lowered = []
    for node in nodes:
        match node:
            case TopLevel(nodes):
                for node in nodes:
                    lower_node(node, lowered)
            case WordDecl(nodes):
                for node in nodes:
                    lower_node(node, lowered)
            case _:
                raise Exception(f"Unsupported node: {node}") 
    return lowered

def lower_str(prog):
    parser_ctx = ParserCtx(prog)
    parse(parser_ctx)
    return lower(parser_ctx.nodes)

#
# compile
#

def compile(lowered):
    output = []
    for node in lowered:
        match node:
            case BlueVMOp(op):
                output.append(op_byte[op])
            case LitInt(val):
                b = bytes([val])
                op = lit_by_len[len(b)]
                output.extend([op_byte[op], b])
            case _:
                raise Exception(f"Unsupported node: {node}")
    return b"".join(output)

#
# 
#


def preamble(ctx):
    return []

if __name__ == "__main__":
    prog = sys.stdin.read()
    parser_ctx = ParserCtx(prog)

    parse(parser_ctx)
    lowered = lower_str(prog)
    unit = preamble(parser_ctx) + lowered + lower_str("depth exit")

    output = compile(lowered)
    
    sys.stdout.buffer.write(output)
