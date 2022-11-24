#!/usr/bin/env python3
#
# Manages monitors.
#
# I should probably use the python-xlib library here but that's too much work
# to figure out right now.

import subprocess
import sys

MM_TO_INCH = 25.4


def all_monitors():
    print("not yet implemented")


def external():
    print("Getting monitors and calculating dpi...")
    monitors = get_monitors()
    if len(monitors) < 2:
        print(f"Failed to find external monitor: {monitors}")
        sys.exit()
    primary = monitors[0]
    external = monitors[1]
    dpi = calc_dpi(external)
    print(f"Enabling {external['name']}, disabling {primary['name']}.")
    cp = subprocess.run([
        "xrandr", "--dpi",
        str(dpi), "--output", primary["name"], "--off", "--output",
        external["name"]
    ],
                        stdout=sys.stdout,
                        stderr=sys.stderr)
    if cp.returncode == 0:
        return True
    return False


def laptop():
    print("not yet implemented")
    return False


def reset():
    print("Resetting monitor configuration.")
    cp = subprocess.run(["xrandr", "-s", "0"],
                        stdout=sys.stdout,
                        stderr=sys.stderr)
    if cp.returncode == 0:
        return True
    return False


def calc_dpi(monitor):
    dpi_x = monitor["resolution-x"] / (monitor["physical-mm-x"] / MM_TO_INCH)
    dpi_y = monitor["resolution-y"] / (monitor["physical-mm-y"] / MM_TO_INCH)
    return round((dpi_x + dpi_y) / 2.0)


def get_monitors():
    cp = subprocess.run(["xrandr", "--listmonitors"], capture_output=True)
    if cp.returncode != 0:
        print(f"Failed to run xrandr: {completed_process.stderr}")
        sys.exit()
    lines = cp.stdout.decode('utf-8').splitlines()
    result = []
    for line in lines[1:]:
        tokens = line.strip().split()
        try:
            dimensions = [
                d.split("/") for d in tokens[-2].split("+")[0].split("x")
            ]
        except:
            print(f"Failed to parse dimensions: {tokens[-2]}")
            sys.exit()

        result.append({
            "name": tokens[-1],
            "resolution-x": int(dimensions[0][0]),
            "resolution-y": int(dimensions[1][0]),
            "physical-mm-x": float(dimensions[0][1]),
            "physical-mm-y": float(dimensions[1][1]),
        })
    return result


COMMANDS = {
    "all": all_monitors,
    "external": external,
    "laptop": laptop,
    "reset": reset
}

if len(sys.argv) != 2 or sys.argv[1] not in COMMANDS:
    print(f"First argument must be one of {COMMANDS}.")
    sys.exit()

restart_i3 = COMMANDS[sys.argv[1]]()
if restart_i3:
    print("Sending 'restart' to i3-msg...")
    subprocess.run(["i3-msg", "restart"], stdout=sys.stdout, stderr=sys.stderr)
