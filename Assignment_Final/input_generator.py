#!/usr/bin/env python3
"""
Generate input.txt for the Wiener filter MIPS assignment.

Reads a desired-file (default: the uploaded desired file).
Generates 10 noise values (default: uniform in [-1.0, 1.0]) and writes:
  - First line: 10 desired floats (1 decimal)
  - Second line: 10 noise floats (1 decimal)

Usage:
  python input_generator_from_desired.py                # uses default desired file and writes input.txt
  python input_generator_from_desired.py --desired my_desired.txt --out input.txt --seed 42 --range 0.5
"""

import argparse
from pathlib import Path
import random

# Default desired file (the one you uploaded)
DEFAULT_DESIRED = "desired19-44-21_11-Nov-25_10_10.txt"

def one_decimal(x):
    # rounds half away from zero by using round() semantics is fine here
    return f"{x:.1f}"

def read_desired(path, expect=10):
    txt = Path(path).read_text().strip().split()
    vals = [float(x) for x in txt]
    if len(vals) < expect:
        raise SystemExit(f"Desired file {path!s} contains {len(vals)} values, need at least {expect}.")
    return vals[:expect]

def generate_noise(count=10, seed=None, rng_min=-1.0, rng_max=1.0):
    if seed is not None:
        random.seed(seed)
    return [random.uniform(rng_min, rng_max) for _ in range(count)]

def write_input_file(outpath, desired, noise):
    # write 2 lines: desired line, noise line
    with open(outpath, "w", encoding="utf-8") as f:
        f.write(" ".join(one_decimal(x) for x in desired) + "\n")
        f.write(" ".join(one_decimal(x) for x in noise) + "\n")

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--desired", default=DEFAULT_DESIRED,
               help="E:/School/CA/Assignment/desired19-44-21_11-Nov-25_10_10")
    p.add_argument("--out", default="input.txt", help="Output input filename to create (default input.txt).")
    p.add_argument("--seed", type=int, default=None, help="Optional RNG seed for reproducible noise.")
    p.add_argument("--min", type=float, default=-1.0, help="Noise min (default -1.0).")
    p.add_argument("--max", type=float, default=1.0, help="Noise max (default 1.0).")

    args = p.parse_args()

    desired = read_desired(args.desired, expect=10)
    noise = generate_noise(10, seed=args.seed, rng_min=args.min, rng_max=args.max)
    write_input_file(args.out, desired, noise)

    print(f"Wrote {args.out}")
    print("Desired:", " ".join(one_decimal(x) for x in desired))
    print("Noise:  ", " ".join(one_decimal(x) for x in noise))

if __name__ == "__main__":
    main()
