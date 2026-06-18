#!/bin/sh

set -eu

if [ $# -ne 1 ]; then
    echo "Usage: $0 <kubernetes_minor_version>" >&2
    exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
    echo "python3 is required to resolve the k3s image tag" >&2
    exit 1
fi

K8S_MINOR_VERSION="$1"

K3S_IMAGE_TAG=$(K8S_MINOR_VERSION="$K8S_MINOR_VERSION" python3 - <<'PY'
import json
import os
import re
import urllib.request

minor = os.environ["K8S_MINOR_VERSION"]
tag_pattern = re.compile(rf"^v{re.escape(minor)}\.(\d+)-k3s(\d+)$")
url = "https://hub.docker.com/v2/repositories/rancher/k3s/tags?page_size=100"
best_match = None

while url:
    with urllib.request.urlopen(url, timeout=20) as response:
        payload = json.load(response)

    for tag in payload.get("results", []):
        name = tag["name"]
        match = tag_pattern.match(name)
        if not match:
            continue

        candidate = (int(match.group(1)), int(match.group(2)), name)
        if best_match is None or candidate[:2] > best_match[:2]:
            best_match = candidate

    if best_match is not None:
        break

    url = payload.get("next")

print(best_match[2] if best_match else "")
PY
)

if [ -z "$K3S_IMAGE_TAG" ]; then
    echo "Failed to resolve a published stable rancher/k3s image for Kubernetes $K8S_MINOR_VERSION" >&2
    exit 1
fi

# K3s patch releases can lag upstream Kubernetes patch releases.
printf 'rancher/k3s:%s\n' "$K3S_IMAGE_TAG"
