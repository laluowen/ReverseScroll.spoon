#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

version=$(sw_vers -productVersion)
build=$(sw_vers -buildVersion)

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Working tree is dirty. Commit or stash first." >&2
  exit 1
fi

if git rev-parse -q --verify "refs/tags/${version}" >/dev/null; then
  echo "Tag ${version} exists. Moving it to HEAD."
fi

sed -i '' -E "s/^Working on macOS .*\.\$/Working on macOS ${version} (${build})./" README.md
sed -i '' -E "s/Spoon version \`[^\`]*\`/Spoon version \`${version}\`/" README.md
sed -i '' -E "s/^obj\.version = \".*\"\$/obj.version = \"${version}\"/" init.lua

git add README.md init.lua
if ! git diff --cached --quiet; then
  git commit -m "chore: target macOS ${version}"
fi

git tag --force "${version}"
echo "Tagged ${version}. Push with: git push && git push --tags"
