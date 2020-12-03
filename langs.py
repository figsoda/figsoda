#!/usr/bin/env python3

import functools, json

xss = json.load(open(".langs.json"))
ys = {}
total = 0

for xs in xss:
    for k, v in xs.items():
        total += v
        if k in ys:
            ys[k] += v
        else:
            ys[k] = v

for k, v in sorted(ys.items(), key = lambda x: x[1], reverse = True):
    v = round(v / total * 100, 2)
    print(f"<tr><td>{k}</td><td>{v}%</td></tr>")
