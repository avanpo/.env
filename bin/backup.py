#!/usr/bin/python
#
# Borg (and external SSD) backup script.

import contextlib
import datetime
import functools
import getpass
import os
import subprocess
import sys

_BACKUP_DIR = "/home/user/files"
_MOUNT_DIR = "/mnt/backup/"
_CRYPT_NAME = "backupdevice"


def remote_backup():
    print("-------------")
    print("REMOTE BACKUP")
    print("-------------")

    repo = input("Please enter your borg repo location: ")
    borg_pass = getpass.getpass("Please enter your borg passphrase: ")

    env = os.environ.copy()
    env["BORG_PASSPHRASE"] = borg_pass

    # Get some stats.
    last_version = get_remote_stats(repo, env)
    get_remote_stats_for_version(repo, last_version, env)

    # Do the backup.
    new_version = datetime.date.today().strftime("%Y_%m_%d")
    if new_version == last_version:
        print("Already did a remote backup today! Skipping.")
    else:
        print("Performing backup...")
        cp = subprocess.run(
            [
                "borg", "create", "--progress", "--stats",
                f"{repo}::{new_version}", _BACKUP_DIR
            ],
            env=env,
        )
        handle_proc(cp)


def get_remote_stats(repo, env):
    print("Connecting...")
    cp = subprocess.run(
        [
            "borg",
            "list",
            "--format={archive},",  # use comma as delim
            f"{repo}",
        ],
        capture_output=True,
        text=True,
        env=env,
    )
    handle_proc(cp)
    versions = cp.stdout.strip(",").split(",")
    last_version = versions[-1]
    print(
        f"Found a total of {len(versions)} archives, with the last being \"{last_version}\"."
    )
    return last_version


def get_remote_stats_for_version(repo, last_version, env):
    print("Checking archive info...")
    cp = subprocess.run(
        [
            "borg",
            "info",
            f"{repo}::{last_version}",
        ],
        capture_output=True,
        text=True,
        env=env,
    )
    handle_proc(cp)
    num_files = cp.stdout.partition("Number of files: ")[2].partition("\n")[0]
    print(f"Number of files: {num_files}")
    archive_size = cp.stdout.partition("This archive:")[2].partition(
        "\n")[0].strip().partition("  ")[0]
    print(f"Uncompressed archive size: {archive_size}")
    total_size = cp.stdout.partition("All archives:")[2].partition(
        "\n")[0].rpartition("  ")[2].strip()
    print(f"All archives compressed size: {total_size}")


def local_backup():
    print("------------")
    print("LOCAL BACKUP")
    print("------------")

    print("Searching for devices...")
    cp = subprocess.run(["lsblk", "-nlp", "-I", "8", "-o", "NAME,TYPE"],
                        capture_output=True,
                        text=True)
    handle_proc(cp)
    lines = cp.stdout.split("\n")
    devices = {}
    i = 0
    for l in lines:
        if l.endswith("part"):
            devices[str(i)] = l.partition(" ")[0]
            i += 1
    if len(devices) == 0:
        print("ERROR: No devices found. Is one plugged in?")
        sys.exit()
    for i, d in devices.items():
        print(f"  {d} [{i}]")
    response = -1
    while response not in devices:
        response = input("Please choose a device: ")
    device = devices[response]

    def luks_close():
        print("Closing LUKS.")
        handle_proc(
            subprocess.run(["sudo", "cryptsetup", "luksClose", _CRYPT_NAME]))

    def unmount():
        print(f"Unmounting {_MOUNT_DIR}.")
        handle_proc(subprocess.run(["sudo", "umount", _MOUNT_DIR]))

    with contextlib.ExitStack() as stack:
        handle_proc(subprocess.run(["sudo", "mkdir", "-p", _MOUNT_DIR]))
        # Set up LUKS.
        print("Setting up LUKS.")
        handle_proc(
            subprocess.run(
                ["sudo", "cryptsetup", "luksOpen", device, _CRYPT_NAME]))
        stack.callback(luks_close)
        # Mount the drive.
        print(f"Mounting {_MOUNT_DIR}.")
        handle_proc(
            subprocess.run(
                ["sudo", "mount", f"/dev/mapper/{_CRYPT_NAME}", _MOUNT_DIR]))
        stack.callback(unmount)

        # Do the backup.
        print("Backing up with rsync...")
        handle_proc(
            subprocess.run([
                "sudo", "rsync", "-a", "--delete", "--info=progress2",
                "--info=name0", _BACKUP_DIR, _MOUNT_DIR
            ]))


def handle_proc(result):
    if result.returncode != 0:
        print(
            f"ERROR: Exit code {result.returncode} for '{' '.join(result.args)}'."
        )
        sys.exit()


remote_backup()

local_backup()
