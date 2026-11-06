# Contributing

## Releasing for a new macOS version

Versions track macOS. Tag the Spoon with the macOS version it works on.

1. Confirm the Spoon works on the new macOS version. Fix UI paths in `init.lua` if needed and commit those changes first.
2. Commit or stash everything. The release script refuses a dirty tree.
3. Run:

   ```sh
   ./scripts/release.sh
   ```

   This updates the macOS version in `README.md` and `init.lua`, commits if anything changed, and creates a lightweight tag with the macOS version (for example `27.2`).
4. Push the branch and tags:

   ```sh
   git push && git push --tags
   ```

Re-running the script for the same macOS version moves its tag to the new HEAD. Moving a tag that's already on the remote needs a force push of tags, so `git push && git push --tags` will be rejected for it. Use `git push --force --tags` for that case.
