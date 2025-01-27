import sys
from collections import namedtuple
from dataclasses import dataclass, field

sys.path.append("..")

from bluevm import lit_by_len, op_byte

#
# custom opcodes
#

op_byte["blue:word_addr!"] = b"\x81"
op_byte["blue:word_addr"] = b"\x82"

#
# parse
#

BlueVMOp = namedtuple("BlueVMOp", ["op"])
CallWord = namedtuple("CallWord", ["word", "idx"])
LitInt = namedtuple("LitInt", ["val"])

TopLevel = namedtuple("TopLevel", ["nodes"])
WordDecl = namedtuple("WordDecl", ["idx", "nodes"])

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
    idx = len(ctx.words)
    word = WordDecl(idx, [])
    ctx.word_idx[name] = idx
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

def pound(ctx):
    next_token(ctx, "\n")

kw = {
    ":": colon,
    "((": double_lparen,
    ";": semi,
    "#": pound,
}
    
def next_token(ctx, sep=None):
    parts = ctx.prog.split(sep, maxsplit=1)
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
            lowered.extend([LitInt(idx), BlueVMOp("blue:word_addr"), BlueVMOp("mccall")])
        case _:
            raise Exception(f"Unsupported node: {node}")

def lower(nodes):
    lowered = []
    for node in nodes:
        match node:
            case TopLevel(nodes):
                for node in nodes:
                    lower_node(node, lowered)
            case WordDecl(idx, nodes):
                lowered.extend([LitInt(idx), BlueVMOp("blue:word_addr!")])
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
    return [
        # Custom opcode 80 - get pointer to addr for word N
        LitInt(0x80), BlueVMOp("entry"),
        LitInt(0x06), BlueVMOp("b!+"),
        LitInt(0x01), BlueVMOp("b!+"),
        # inline bytecode
        BlueVMOp("litb"), BlueVMOp("litb"), BlueVMOp("b!+"),
        BlueVMOp("litb"), LitInt(0x03), BlueVMOp("b!+"),
        BlueVMOp("litb"), BlueVMOp("shl"), BlueVMOp("b!+"),
        BlueVMOp("litb"), BlueVMOp("start"), BlueVMOp("b!+"),
        BlueVMOp("litb"), BlueVMOp("+"), BlueVMOp("b!+"),
        BlueVMOp("litb"), BlueVMOp("ret"), BlueVMOp("b!+"),
        BlueVMOp("drop"),

        # Custom opcode 81 - set addr for word N
        LitInt(0x81), BlueVMOp("entry"),
        LitInt(0x06), BlueVMOp("b!+"),
        LitInt(0x01), BlueVMOp("b!+"),
        # inline bytecode
        BlueVMOp("litb"), LitInt(0x80), BlueVMOp("b!+"),
        BlueVMOp("litb"), BlueVMOp("here"), BlueVMOp("b!+"),
        BlueVMOp("litb"), BlueVMOp("!+"), BlueVMOp("b!+"),
        BlueVMOp("litb"), BlueVMOp("drop"), BlueVMOp("b!+"),
        BlueVMOp("litb"), BlueVMOp("ret"), BlueVMOp("b!+"),
        BlueVMOp("drop"),

        # Custom opcode 82 - get addr for word N
        LitInt(0x81), BlueVMOp("entry"),
        LitInt(0x06), BlueVMOp("b!+"),
        LitInt(0x01), BlueVMOp("b!+"),
        # inline bytecode
        BlueVMOp("litb"), LitInt(0x80), BlueVMOp("b!+"),
        BlueVMOp("litb"), BlueVMOp("@"), BlueVMOp("b!+"),
        BlueVMOp("litb"), BlueVMOp("ret"), BlueVMOp("b!+"),
        BlueVMOp("drop"),

        # alloc space for N word addrs
        BlueVMOp("here"), LitInt(len(ctx.words)),
        LitInt(0x03), BlueVMOp("shl"),
        BlueVMOp("+"), BlueVMOp("here!"),
    ]

if __name__ == "__main__":
    prog = sys.stdin.read()
    parser_ctx = ParserCtx(prog)

    parse(parser_ctx)
    lowered = lower(parser_ctx.nodes)
    unit = preamble(parser_ctx) + lowered + [BlueVMOp("depth"), BlueVMOp("exit")]

    output = compile(lowered)
    
    sys.stdout.buffer.write(output)
