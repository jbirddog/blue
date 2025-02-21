
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
    shl shr
""".split()

op_byte = {e: bytes([i]) for i, e in enumerate(kw)}
op_hex = {e: format(i, "02x") for i, e in enumerate(kw)}

lit_by_len = { 1: "litb", 2: "litw", 4: "litd", 8: "lit", }
