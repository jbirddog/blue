import sys

kw = """
    exit
    true false
    if-else
    mccall call
    >r r>
    ret
    [ ]
    ip ip!
    entry
    start
    here here!
    b@ @
    b!+ w!+ d!+ !+
    b, w, d, ,
    litb litw litd lit

    depth dup drop swap
    not = + -
""".split()

op = {e: format(i, "02x") for i, e in enumerate(kw)}
prog = " ".join([l for l in sys.stdin.readlines() if not l.startswith("#")])
tokens = prog.split()
output = b"".join([bytes.fromhex(op.get(t, t)) for t in tokens])

sys.stdout.buffer.write(output)
