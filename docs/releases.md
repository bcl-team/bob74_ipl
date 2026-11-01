# Releasing this fork

Push a new `v*` tag (for example `v2.6.4`) on a commit containing
`.github/workflows/release.yml`. GitHub Actions packages that tagged revision and
publishes a GitHub Release with `bob74_ipl.tar.gz`. Lua and streamed assets need
no compilation. The archive contains a single `bob74_ipl/` resource directory,
including `fxmanifest.lua`, scripts and streamed files.

The same packaging and byte-for-byte Git verification run on pull requests and
pushes to `master`, without publishing a release. Only tag pushes can publish;
the workflow uses `GITHUB_TOKEN`, so no extra secret is required. Download the
`release-archive` Actions artifact to inspect a PR's candidate archive.

Docker expects the asset name `bob74_ipl.tar.gz` and resolves `bob74_ipl:latest`
from published, non-prerelease releases in its selected channel. A new release
is picked up by the next Docker image build, not by already-running containers.
Coordinate Shelter releases with the matching mapping and bcl-core versions.

`enhanced-*` tags are also supported, as full releases, but do not replace the
Legacy release's GitHub `Latest` marker. Cut them from the appropriate Enhanced
codebase: the workflow does not convert assets or port changes between branches.
That branch/tag must contain this workflow too.

Existing tags (including the manually published `v2.6.3`) are not retroactively
processed when this workflow is merged. Use a new version tag after merging.
Retry a failed tag run from Actions; the release action updates the release and
its named asset on rerun. Do not move published tags to different commits.
