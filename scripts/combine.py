#!/usr/bin/env python3
"""
combine.py - Cross-Platform AetherOS ISO Part Merger & SHA256 Verifier.
Works out of the box on Windows, macOS, and Linux with standard Python 3.
"""

import os
import sys
import glob
import hashlib
import time

BUFFER_SIZE = 32 * 1024 * 1024  # 32 MB

def format_size(size_bytes):
    for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
        if size_bytes < 1024.0:
            return f"{size_bytes:.2f} {unit}"
        size_bytes /= 1024.0
    return f"{size_bytes:.2f} PB"

def compute_sha256(filepath, total_size=None):
    sha = hashlib.sha256()
    read_bytes = 0
    start_time = time.time()
    with open(filepath, "rb") as f:
        while True:
            chunk = f.read(BUFFER_SIZE)
            if not chunk:
                break
            sha.update(chunk)
            read_bytes += len(chunk)
            if total_size:
                pct = (read_bytes / total_size) * 100
                elapsed = time.time() - start_time
                speed = (read_bytes / (1024 * 1024)) / max(elapsed, 0.001)
                sys.stdout.write(f"\r    -> Verifying: {pct:5.1f}% ({format_size(read_bytes)}/{format_size(total_size)}) [{speed:.1f} MB/s]")
                sys.stdout.flush()
    if total_size:
        sys.stdout.write("\n")
    return sha.hexdigest()

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)

    print("=" * 60)
    print("        AetherOS ISO Recombination & Verification Tool        ")
    print("=" * 60)

    # Search for .iso.part* files
    part_files = sorted(glob.glob("*.iso.part*"))
    if not part_files:
        print("\n[-] Error: No '*.iso.part*' files found in directory:")
        print(f"    {script_dir}")
        print("Please place the downloaded part files and sha256sum.txt in this folder.")
        sys.exit(1)

    # Target ISO name is derived by trimming .part*
    first_part = part_files[0]
    target_iso = first_part.split(".part")[0]

    print(f"\n[*] Target ISO Name : {target_iso}")
    print(f"[*] Found Part Files: {len(part_files)}")

    total_expected_size = 0
    for p in part_files:
        sz = os.path.getsize(p)
        total_expected_size += sz
        print(f"    -> {p} ({format_size(sz)})")
    print(f"[*] Total Restored Size will be: {format_size(total_expected_size)}")

    # Load checksums if sha256sum.txt exists
    checksums = {}
    if os.path.exists("sha256sum.txt"):
        with open("sha256sum.txt", "r", encoding="utf-8", errors="ignore") as f:
            for line in f:
                parts = line.strip().split()
                if len(parts) >= 2:
                    h = parts[0].strip()
                    fn = os.path.basename(parts[-1].strip().lstrip("*"))
                    checksums[fn] = h
        print(f"[*] Loaded {len(checksums)} checksums from sha256sum.txt")

    # Step 1: Verify each part before combining
    if checksums:
        print("\n[*] Step 1/3: Verifying integrity of individual parts...")
        for p in part_files:
            expected = checksums.get(p)
            if expected:
                sys.stdout.write(f"    Checking {p}...\n")
                actual = compute_sha256(p, os.path.getsize(p))
                if actual.lower() != expected.lower():
                    print(f"\n[-] CRITICAL ERROR: Hash mismatch for '{p}'!")
                    print(f"    Expected: {expected}")
                    print(f"    Actual:   {actual}")
                    print("Aborting. Please re-download this corrupted part.")
                    sys.exit(1)
                print(f"    [OK] {p} verified.")
            else:
                print(f"    [?] No checksum entry for {p}, continuing...")

    # Step 2: Combine the parts
    print(f"\n[*] Step 2/3: Merging parts into '{target_iso}'...")
    written_bytes = 0
    start_time = time.time()
    sha_out = hashlib.sha256()

    with open(target_iso, "wb") as out_f:
        for p in part_files:
            with open(p, "rb") as in_f:
                while True:
                    buf = in_f.read(BUFFER_SIZE)
                    if not buf:
                        break
                    out_f.write(buf)
                    sha_out.update(buf)
                    written_bytes += len(buf)
                    pct = (written_bytes / total_expected_size) * 100
                    elapsed = time.time() - start_time
                    speed = (written_bytes / (1024 * 1024)) / max(elapsed, 0.001)
                    sys.stdout.write(f"\r    Merging: {pct:5.1f}% ({format_size(written_bytes)}/{format_size(total_expected_size)}) [{speed:.1f} MB/s]")
                    sys.stdout.flush()

    sys.stdout.write("\n")
    final_hash = sha_out.hexdigest()
    print(f"[+] Reassembly complete! Final size: {format_size(written_bytes)}")

    # Step 3: Final verification
    print("\n[*] Step 3/3: Verifying final reassembled ISO...")
    expected_iso_hash = checksums.get(target_iso)
    if expected_iso_hash:
        print(f"    Calculated SHA256: {final_hash}")
        print(f"    Expected SHA256  : {expected_iso_hash}")
        if final_hash.lower() == expected_iso_hash.lower():
            print("\n" + "=" * 60)
            print(" [SUCCESS] Reassembled ISO matches expected SHA256 checksum!")
            print(f" File: {os.path.abspath(target_iso)}")
            print(" Ready to flash to USB or boot in VMware / VirtualBox / QEMU!")
            print("=" * 60)
        else:
            print("\n[-] ERROR: Final ISO hash does not match sha256sum.txt!")
            sys.exit(1)
    else:
        print(f"    Generated SHA256: {final_hash}")
        print(f"\n[+] Created: {os.path.abspath(target_iso)}")

if __name__ == "__main__":
    main()
