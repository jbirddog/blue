import sys
from collections import namedtuple
from dataclasses import dataclass, field

kw = """
    exit
    true false
    if-else
    mccall call
    >r r>
    ret
    [ ]
    ip ip!
    op
    start
    here here!
    b@+ w@+ d@+ @+
    b@ w@ d@ @
    b!+ w!+ d!+ !+
    b, w, d, ,
    litb litw litd lit

    depth dup drop swap
    not = + -
    shl shr
""".split()

op_byte = {e: bytes([i]) for i, e in enumerate(kw)}

lit_by_len = { 1: "litb", 2: "litw", 4: "litd", 8: "lit", }

#
# custom opcodes
#

op_byte["blue:word_addr!"] = b"\x81"
op_byte["blue:word_addr"] = b"\x82"
op_byte["blue:interpret_word"] = b"\x83"
op_byte["blue:compile_word"] = b"\x85"

#
# parse
#

BlueVMOp = namedtuple("BlueVMOp", ["op"])
LitInt = namedtuple("LitInt", ["val"])
WordRef = namedtuple("WordRef", ["word", "idx", "compile"])

TopLevel = namedtuple("TopLevel", ["nodes"])
WordDecl = namedtuple("WordDecl", ["idx", "ins", "outs", "nodes"])

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
    word = WordDecl(idx, [], [], [])
    ctx.word_idx[name] = idx
    ctx.words.append(word)
    ctx.latest = word
    ctx.nodes.append(word)
    ctx.compiling = True

def double_lparen(ctx):
    effects = ctx.latest.ins
    while ctx.prog:
        token = next_token(ctx)
        if token == "))":
            break
        if token == "--":
            effects = ctx.latest.outs
            continue
        if token == "noret":
            continue

        effect = next_token(ctx)
        effects.append(effect)

def fslash(ctx):
    next_token(ctx, "\n")

def semi(ctx):
    ctx.latest.nodes.extend([LitInt(0xC3), BlueVMOp("b,")])
    ctx.nodes.append(TopLevel([]))
    ctx.compiling = False

kw = {
    ":": colon,
    "((": double_lparen,
    "\\": fslash,
    ";": semi,
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
            nodes.append(WordRef(ctx.words[idx], idx, ctx.compiling))
        elif token in kw:
            kw[token](ctx)
        elif token in op_byte:
            nodes.append(BlueVMOp(token))
        else:
            nodes.append(LitInt(int(token, ctx.base)))

#
# flow
#

def flow_in(word, lowered):
    for effect in reversed(word.ins):
        reg_code = 0xB8 if effect == "eax" else 0xBF
        lowered.extend([LitInt(reg_code), BlueVMOp("b,"), BlueVMOp("d,")])
            
#
# lower
#

def lower_node(node, lowered):
    match node:
        case BlueVMOp(_) | LitInt(_):
            lowered.append(node)
        case WordRef(word, idx, compile=False):
            lowered.extend([LitInt(idx), BlueVMOp("blue:interpret_word")])
        case WordRef(word, idx, compile=True):
            flow_in(word, lowered)
            lowered.extend([LitInt(idx), BlueVMOp("blue:compile_word")])
        case _:
            raise Exception(f"Unsupported node: {node}")

def lower(nodes):
    lowered = []
    for node in nodes:
        match node:
            case TopLevel(nodes):
                for node in nodes:
                    lower_node(node, lowered)
            case WordDecl(idx, ins, outs, nodes):
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

def bluevm_setup(ctx):
    return [
        # Custom opcode 80 - get pointer to addr for word N
        LitInt(0x80), BlueVMOp("op"),
        LitInt(0x06), BlueVMOp("b!+"),
        LitInt(0x01), BlueVMOp("b!+"),
        # inline bytecode
        BlueVMOp("litb"), BlueVMOp("litb"), BlueVMOp("b!+"),
        LitInt(0x03), BlueVMOp("b!+"),
        BlueVMOp("litb"), BlueVMOp("shl"), BlueVMOp("b!+"),
        BlueVMOp("litb"), BlueVMOp("start"), BlueVMOp("b!+"),
        BlueVMOp("litb"), BlueVMOp("+"), BlueVMOp("b!+"),
        BlueVMOp("litb"), BlueVMOp("ret"), BlueVMOp("b!+"),
        BlueVMOp("drop"),

        # Custom opcode 81 - set addr for word N
        LitInt(0x81), BlueVMOp("op"),
        LitInt(0x06), BlueVMOp("b!+"),
        LitInt(0x01), BlueVMOp("b!+"),
        # inline bytecode
        LitInt(0x80), BlueVMOp("b!+"),
        BlueVMOp("litb"), BlueVMOp("here"), BlueVMOp("b!+"),
        BlueVMOp("litb"), BlueVMOp("!+"), BlueVMOp("b!+"),
        BlueVMOp("litb"), BlueVMOp("drop"), BlueVMOp("b!+"),
        BlueVMOp("litb"), BlueVMOp("ret"), BlueVMOp("b!+"),
        BlueVMOp("drop"),

        # Custom opcode 82 - get addr for word N
        LitInt(0x82), BlueVMOp("op"),
        LitInt(0x06), BlueVMOp("b!+"),
        LitInt(0x01), BlueVMOp("b!+"),
        # inline bytecode
        LitInt(0x80), BlueVMOp("b!+"),
        BlueVMOp("litb"), BlueVMOp("@"), BlueVMOp("b!+"),
        BlueVMOp("litb"), BlueVMOp("ret"), BlueVMOp("b!+"),
        BlueVMOp("drop"),

        # Custom opcode 83 - interpret word N
        LitInt(0x83), BlueVMOp("op"),
        LitInt(0x06), BlueVMOp("b!+"),
        LitInt(0x01), BlueVMOp("b!+"),
        # inline bytecode
        LitInt(0x82), BlueVMOp("b!+"),
        BlueVMOp("litb"), BlueVMOp("mccall"), BlueVMOp("b!+"),
        BlueVMOp("litb"), BlueVMOp("ret"), BlueVMOp("b!+"),
        BlueVMOp("drop"),

        # Custom opcode 84 - call distance from word N
        LitInt(0x84), BlueVMOp("op"),
        LitInt(0x06), BlueVMOp("b!+"),
        LitInt(0x01), BlueVMOp("b!+"),
        # inline bytecode
        LitInt(0x82), BlueVMOp("b!+"),
        BlueVMOp("litb"), BlueVMOp("here"), BlueVMOp("b!+"),
        BlueVMOp("litb"), BlueVMOp("-"), BlueVMOp("b!+"),
        BlueVMOp("litb"), BlueVMOp("litb"), BlueVMOp("b!+"),
        LitInt(0x04), BlueVMOp("b!+"),
        BlueVMOp("litb"), BlueVMOp("-"), BlueVMOp("b!+"),
        BlueVMOp("litb"), BlueVMOp("ret"), BlueVMOp("b!+"),
        BlueVMOp("drop"),

        # Custom opcode 85 - compile word N
        LitInt(0x85), BlueVMOp("op"),
        LitInt(0x06), BlueVMOp("b!+"),
        LitInt(0x01), BlueVMOp("b!+"),
        # inline bytecode
        # when called will compile machine code for `call rel32`
        BlueVMOp("litb"), BlueVMOp("litb"), BlueVMOp("b!+"),
        LitInt(0xE8), BlueVMOp("b!+"),
        BlueVMOp("litb"), BlueVMOp("b,"), BlueVMOp("b!+"),
        LitInt(0x84), BlueVMOp("b!+"),
        BlueVMOp("litb"), BlueVMOp("d,"), BlueVMOp("b!+"),        
        BlueVMOp("litb"), BlueVMOp("ret"), BlueVMOp("b!+"),
        BlueVMOp("drop"),
        
        # alloc space for N word addrs
        BlueVMOp("here"),
        LitInt(len(ctx.words)), LitInt(0x03), BlueVMOp("shl"), BlueVMOp("+"),
        BlueVMOp("here!"),
    ]

def bluevm_teardown():
    return [BlueVMOp("depth"), BlueVMOp("exit")]

if __name__ == "__main__":
    prog = sys.stdin.read()
    parser_ctx = ParserCtx(prog)

    parse(parser_ctx)
    lowered = lower(parser_ctx.nodes)
    unit = bluevm_setup(parser_ctx) + lowered + bluevm_teardown()

    output = compile(unit)
    
    sys.stdout.buffer.write(output)
