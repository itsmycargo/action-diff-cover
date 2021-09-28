#!/usr/bin/env python

import json
import sys


def group_consecutives(vals, step=1):
    """Return list of consecutive lists of numbers from vals (number list)."""
    run = []
    result = [run]
    expect = None
    for v in vals:
        if (v == expect) or (expect is None):
            run.append(v)
        else:
            run = [v]
            result.append(run)
        expect = v + step
    return result


with open(sys.argv[1]) as file:
    report = json.load(file)

rdjson = {
    "source": {
        "name": "diff-cover",
        "url": "https://github.com/Bachmann1234/diff_cover",
    },
    "severity": "ERROR",
    "diagnostics": [],
}

for path in report["src_stats"]:
    stats = report["src_stats"][path]
    if stats["percent_covered"] == 100:
        break

    for range in group_consecutives(stats["violation_lines"]):
        rdjson["diagnostics"].append(
            {
                "message": f"Missing test coverage for lines {range[0]}-{range[-1]}",
                "location": {
                    "path": path,
                    "range": {"start": {"line": range[0]}, "end": {"line": range[-1]}},
                },
                "severity": "ERROR",
            }
        )

print(rdjson)
