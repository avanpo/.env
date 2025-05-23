#!/usr/bin/env python3
#
# Manages monitors.
#
# I should probably use the python-xlib library here but that's too much work
# to figure out right now.

import subprocess
import sys
import time

from dataclasses import dataclass

MM_TO_INCH = 25.4


@dataclass
class Monitor:
    name: str
    connected: bool
    primary: bool

    res_x: int = 0
    res_y: int = 0
    physical_mm_x: float = 0
    physical_mm_y: float = 0

    def is_active(self) -> bool:
        if self.connected or (self.res_x and self.res_y):
            return True
        return False

    def dpi(self) -> int:
        if not self.physical_mm_x or not self.physical_mm_y:
            return 0
        dpi_x = self.res_x / (self.physical_mm_x / MM_TO_INCH)
        dpi_y = self.res_y / (self.physical_mm_y / MM_TO_INCH)
        return round((dpi_x + dpi_y) / 2.0)


def primary():
    monitors = parse_xrandr()
    if len(monitors) == 0:
        print(f"No monitors found.")
        sys.exit()
    primary = monitors[0]

    args = []
    # Turn off all other monitors.
    for m in monitors[1:]:
        args.extend(["--output", m.name, "--off"])
    args.extend(["--output", primary.name, "--auto"])

    print(f"Enabling {primary.name}, disabling all others.")
    if not run_xrandr(args):
        return False

    # Watch to get dpi info, since dimensions aren't present when the monitor
    # is off.
    primary = watch(primary)
    print(f"Setting dpi to {primary.dpi()}.")
    run_xrandr(["--dpi", str(primary.dpi())])

    return True


def external():
    monitors = parse_xrandr()

    primary = None
    externals = []
    for m in monitors:
        if m.primary:
            primary = m
        else:
            externals.append(m)

    if len(externals) == 0:
        print(f"Failed to find external monitor: {monitors}")
        sys.exit()

    args = ["--output", primary.name, "--off"]
    previous = None
    for e in externals:
        args.extend(["--output", e.name, "--auto"])
        if previous:
            args.extend(["--right-of", previous.name])
        previous = e

    externals_str = ",".join(map(lambda x: x.name, externals))
    print(f"Enabling {externals_str}, disabling {primary.name}.")
    if not run_xrandr(args):
        return False

    # Watch to get dpi info, since dimensions aren't present when the monitor
    # is off. Use the highest dpi.
    dpi = 0
    for i, e in enumerate(externals):
        externals[i] = watch(e)
        if externals[i].dpi() > dpi:
            dpi = externals[i].dpi()
    print(f"Setting dpi to {dpi}.")
    run_xrandr(["--dpi", str(dpi)])

    # Then scale other monitors. For now, hardcoded.
    for e in externals:
        if e.dpi() < dpi:
            print(f"Scaling {e.name} by 1.333x1.333.")
            run_xrandr(["--output", e.name, "--scale", "1.333x1.333"])

    return True


def reset():
    print("Resetting monitor configuration.")
    return run_xrandr(["-s", "0"])


def run_xrandr(args):
    cp = subprocess.run(["xrandr"] + args,
                        stdout=sys.stdout,
                        stderr=sys.stderr)
    if cp.returncode != 0:
        print(f"Got {cp.returncode} status code from xrandr.")
        return False
    return True


def extract_monitor(tokens):
    name = tokens[0]
    connected = False
    if "connected" in tokens:
        connected = True

    # What a terrible hack...
    primary = False
    resolution = tokens[2]
    if "primary" in tokens:
        primary = True
        resolution = tokens[3]

    result = Monitor(name, connected, primary)

    # Get resolution
    if "x" in resolution:
        res_x, res_y = [int(d) for d in resolution.split("+")[0].split("x")]
        result.res_x = res_x
        result.res_y = res_y

    # Get physical dimensions
    if tokens[-1].endswith("mm") and tokens[-3].endswith("mm"):
        result.physical_mm_x = float(tokens[-3][:-2])
        result.physical_mm_y = float(tokens[-1][:-2])

    return result


def watch(m):
    start = time.time()

    no_dimensions = True
    while no_dimensions:
        cp = subprocess.run(["xrandr", "-q"], capture_output=True)
        if cp.returncode != 0:
            print(f"Failed to run xrandr: {completed_process.stderr}")
        lines = cp.stdout.decode('utf-8').splitlines()

        for line in lines:
            if m.name not in line:
                continue

            m = extract_monitor(line.strip().split())
            if m.res_x and m.res_y and m.physical_mm_x and m.physical_mm_y:
                print(m)
                no_dimensions = False
                break
        if no_dimensions:
            # Don't wait forever.
            if time.time() - start > 10:
                print(f"Waited, but no monitor {name} dimensions found.")
                return m
            time.sleep(0.1)

    elapsed = time.time() - start
    print(f"Monitor {m.name} dimensions took {elapsed:.2f} seconds.")
    return m


def parse_xrandr():
    cp = subprocess.run(["xrandr", "-q"], capture_output=True)
    if cp.returncode != 0:
        print(f"Failed to run xrandr: {completed_process.stderr}")
        sys.exit()
    lines = cp.stdout.decode('utf-8').splitlines()

    result = []
    for line in lines:
        tokens = line.strip().split()
        if len(tokens) < 2 or not tokens[1].endswith("connected"):
            continue
        m = extract_monitor(tokens)
        if m.is_active():
            result.append(m)

    return result


COMMANDS = {"primary": primary, "external": external, "reset": reset}

if len(sys.argv) != 2 or sys.argv[1] not in COMMANDS:
    print(f"First argument must be one of {COMMANDS.keys()}.\n")

    # Print monitors for debugging purposes.
    print("Monitors found:")
    for m in parse_xrandr():
        print(f"{m} DPI: '{m.dpi()}'")
    sys.exit()

restart_i3 = COMMANDS[sys.argv[1]]()
if restart_i3:
    print("Sending 'restart' to i3-msg...")
    subprocess.run(["i3-msg", "restart"], stdout=sys.stdout, stderr=sys.stderr)
