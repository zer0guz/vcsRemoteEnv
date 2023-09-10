#!/usr/bin/env python3
from pwn import *
import time

{bindings}


context.binary = {bin_name}
context.terminal = ["tmux", "splitw", "-v"]




if args.HOST:
    host = args.HOST
    port = int(args.PORT)
    p = remote(host, port)
else:
    current_second = time.time()
    if args.GDB:
        p = gdb.debug(binary.path, '''
            break _start
            continue

            break *main
            continue
            ''')
    else:
        p = process(binary.path)
