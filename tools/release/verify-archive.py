"""Verify the release layout and exact Git blob contents without extracting files."""

import hashlib
from pathlib import PurePosixPath
import subprocess
import sys
import tarfile


def verify(archive):
    tree = subprocess.check_output(["git", "ls-tree", "-rz", "HEAD"])
    expected = {}
    for record in tree.split(b"\0"):
        if not record:
            continue
        metadata, path = record.split(b"\t", 1)
        mode, kind, blob = metadata.split()
        if kind != b"blob" or mode not in (b"100644", b"100755"):
            raise ValueError(f"Unsupported release entry: {path!r}")
        expected[path.decode("utf-8")] = blob.decode("ascii")

    actual = {}
    with tarfile.open(archive, "r:gz") as package:
        for entry in package:
            path = PurePosixPath(entry.name)
            if path.is_absolute() or ".." in path.parts or path.parts[0] != "bob74_ipl":
                raise ValueError(f"Invalid archive path: {entry.name}")
            if entry.isdir():
                continue
            if not entry.isfile():
                raise ValueError(f"Unsupported archive entry: {entry.name}")
            relative = path.relative_to("bob74_ipl").as_posix()
            if relative in actual:
                raise ValueError(f"Duplicate archive entry: {entry.name}")
            content = package.extractfile(entry).read()
            header = f"blob {len(content)}\0".encode("ascii")
            actual[relative] = hashlib.sha1(header + content).hexdigest()

    if actual != expected:
        raise ValueError("Archive file list or content differs from checked-out Git revision")
    for required in ("fxmanifest.lua", "client.lua", "lib/common.lua", "dlc_doomsday/facility.lua"):
        if required not in actual:
            raise ValueError(f"Missing runtime file: {required}")
    print(f"Verified {len(actual)} files: bob74_ipl/ layout and exact Git blob contents")


if __name__ == "__main__":
    verify(sys.argv[1])
