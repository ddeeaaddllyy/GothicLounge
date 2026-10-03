"""Select an installed iPhone on the newest available iOS runtime for CI."""
import json
import re
import subprocess

payload = subprocess.check_output(["xcrun", "simctl", "list", "devices", "available", "--json"])
devices = json.loads(payload)["devices"]
candidates = []
for runtime, entries in devices.items():
    if ".iOS-" not in runtime:
        continue
    version = tuple(int(part) for part in re.findall(r"\d+", runtime.rsplit("iOS-", 1)[1]))
    for device in entries:
        if device.get("isAvailable") and device["name"].startswith("iPhone"):
            candidates.append((version, device["name"], device["udid"]))
if not candidates:
    raise SystemExit("No available iPhone simulator. Install an iOS runtime in Xcode.")
print("id=" + max(candidates)[2])
