import sys

sys.path.insert(0, "..")

from bluevm import op_hex

prog = " ".join([l for l in sys.stdin.readlines() if not l.startswith("#")])
tokens = prog.split()
output = b"".join([bytes.fromhex(op_hex.get(t, t)) for t in tokens])

sys.stdout.buffer.write(output)
