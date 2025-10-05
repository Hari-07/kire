# kire

CLI helper aimed at smoothing day-to-day git workflows in a monorepo. It reads package ownership rules from `kire.toml` 


## Usage

Currently only `commit` is supported

```
kire commit "<MESSAGE>"
```

- `kire` looks for `kire.toml` in the working directory.
- Each `[packages]` entry maps a package name to the path prefix it owns.
- Any staged file that doesn’t match a package path falls into the `root` bucket.

Example `kire.toml`:

```toml
[packages]
api = "packages/api"
web = "packages/web"
shared = "packages/shared"
```

For a fuller sample, see `examples/example-1.toml`.

Example session (with the sample config and these staged files: `packages/api/lib.rs`, `packages/api/service.rs`, `packages/web/home.tsx`, `README.md`, `zig-out/kire.log`):

```
$ kire commit "Tidy dependencies"
```
Will create these 3 commits with those files respectively
```
[api] Tidy dependencies
  packages/api/lib.rs
  packages/api/service.rs

[web] Tidy dependencies
  packages/web/home.tsx

[root] Tidy dependencies
  README.md
  zig-out/kire.log
```


## Building from Source

Requirements: Zig 0.14.1 and git.

```bash
zig build                 # compile the kire binary into zig-out/bin
zig build run -- commit "Initial commit"
```

Both commands assume you’re running from the repository root with your staged changes set up.

### Running From Another Directory

If you want to try the tool from a sibling project, install the build output somewhere discoverable:

```bash
zig build -p zig-out
../kire/zig-out/bin/kire commit "Initial commit" // Or the directory where kire is cloned
```
