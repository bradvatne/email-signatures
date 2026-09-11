#!/usr/bin/env bash
# Push to both remotes and wait for the images to actually be live.
#
# The canonical repo (origin, clubtechglobal) is where the team looks; the mirror
# (pages, bradvatne) is what serves the images. Pushing only one leaves the
# signature loading a stale or missing headshot. See README -> Image hosting.
set -euo pipefail

cd "$(dirname "$0")"

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Working tree is dirty — commit first:" >&2
  git status --short >&2
  exit 1
fi

for remote in origin pages; do
  echo "==> pushing $remote"
  git push "$remote" main
done

# Pages republishes asynchronously; confirm before anyone installs a signature.
#
# Wait on the Pages BUILD reaching this exact commit — not on an image URL
# returning 200. Most files in images/ already exist, so a URL probe passes
# instantly against the previous build and reports success while the new content
# is still deploying.
echo "==> waiting for GitHub Pages to build $(git rev-parse --short HEAD)"
head_sha=$(git rev-parse HEAD)

for _ in $(seq 1 60); do
  read -r status commit <<<"$(gh api repos/bradvatne/email-signatures/pages/builds/latest \
    --jq '"\(.status) \(.commit)"' 2>/dev/null || echo "unknown none")"

  if [[ "$status" == "built" && "$commit" == "$head_sha" ]]; then
    echo "live: https://bradvatne.github.io/email-signatures/ (at ${head_sha:0:7})"
    exit 0
  fi
  if [[ "$status" == "errored" ]]; then
    gh api repos/bradvatne/email-signatures/pages/builds/latest --jq '.error.message' >&2
    exit 1
  fi
  sleep 5
done

echo "TIMED OUT — the new content may not be live; don't install a signature yet." >&2
echo "Check https://github.com/bradvatne/email-signatures/settings/pages" >&2
exit 1
