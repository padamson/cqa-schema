# cqa

A [LinkML](https://linkml.io) ontology grounded in BFO 2020 (ISO/IEC
21838-2:2020) and the Common Core Ontologies (CCO), authored via Noy &
McGuinness's *Ontology Development 101* (N&M) method, with the build
documented chapter by chapter as an mdbook.

`cqa` is a vocabulary for **competency question benchmarks**. A competency
question is a question an ontology exists to answer. Most projects write
them down once, in a design document, and never check them again; this
schema is for the other approach — pair each question with the full
specification of its correct answer, and the set becomes something you can
run.

The build is in progress. See [the book](book/editions/) for how far it has got.

## Authoring the ontology

Work one N&M step at a time with the **`ontology-authoring-advance-step`**
skill (*"do Step 1"*; install it per `CLAUDE.md` "Agent skills"): write `introduction.md`, then `ch01`…
`ch07` in the authoring edition's `src/`, so the rendered Chapter N is N&M Step N. Each step advances
`schema/cqa.yaml` only as its worked example demands and freezes a
listing snapshot the chapter embeds. Grounding is by URI — reference reuse
vocabularies as prefixes, never LinkML `imports:`.

## Building the book

The book is published in editions, each a directory under
`book/editions/` covering a span of releases (`[editions]` in
`panschema-publish.toml`). New chapters go into the authoring edition,
whose directory `mdbook-panschema editions --authoring` prints:

```
mdbook serve "$(mdbook-panschema editions --authoring)"   # local preview with live reload
mdbook build "$(mdbook-panschema editions --authoring)"   # output to its build/
mdbook-panschema editions   # every edition from main into site/, as CI does
```

Preprocessors must be on `PATH`: `mdbook-listings`, the `mdbook-admonish`
fork, and `mdbook-panschema`. `scripts/install-assets.sh` generates their
book assets in every edition. CI (`.github/workflows/docs.yml`) verifies
the frozen worked example and the benchmarks in `data/`
(`scripts/verify-fixtures.sh`), generates the machine-readable formats
(via `panschema.toml`), builds every edition, and deploys the combined
site to Pages.

`./scripts/dev.sh` serves every edition and the versioned schema docs from
the working tree at http://localhost:8000/, laid out as published, and
rebuilds on any save in `schema/`, an edition's `src/` or `*.toml`, or
`panschema-publish.toml`.

## Dogfooding the tooling

This repo exercises [panschema](https://github.com/padamson/panschema),
`mdbook-listings`, and the `mdbook-admonish` fork. The scripts call each
producer by name and resolve it through `$PATH`, the same contract CI
uses, and every rebuild prints the binary that answered and its version,
which is what exposes a stale install. They never build a producer: you
build it in its own checkout.

### Using local debug builds

To have the scripts, `mdbook`'s preprocessors, the pre-commit hooks, and
your shell all run your local debug builds, put each producer's
`target/debug` on `PATH`. An alias is not enough. It reaches only the
commands you type, while `mdbook build` spawns `mdbook-listings` and
`mdbook-admonish` itself and reads `PATH`.

```zsh
# ~/.zshrc
export PRODUCER_ROOT="/path/to/producers"   # wherever you cloned them
for p in panschema mdbook-listings mdbook-admonish; do
  d="$PRODUCER_ROOT/$p/target/debug"
  [[ -d $d ]] || continue
  (( ${path[(Ie)$d]} )) && continue   # already on PATH
  i=${path[(ie)$HOME/.cargo/bin]}     # one past the end if absent
  path[i,i-1]=("$d")                  # insert just ahead of ~/.cargo/bin
done
```

The directories go just ahead of `~/.cargo/bin` rather than at the front,
because a producer workspace builds other binaries into the same directory
and one with a common name would shadow a system command. So the loop has
to come after whatever puts `~/.cargo/bin` on `PATH` (a
`. "$HOME/.cargo/env"` line, say); run before it, the directories land at
the end of `PATH`. panschema's `target/debug` holds `mdbook-panschema`
too. If a `cargo install`ed copy of a producer is still in
`~/.cargo/bin`, a missing debug build silently falls through to it;
uninstall it to make that fail loudly instead. To check what a script will
see, ask a non-interactive shell:

```bash
bash -c 'for t in panschema mdbook-panschema mdbook-listings mdbook-admonish; do command -v $t; $t --version; done'
```

CI installs `panschema` and the fork from their branch tips, so a debug
build of each tip is what CI runs. `mdbook-listings` comes from the
crates.io release pinned in `docs.yml`, so a debug build of its `main` can
be ahead of CI, and the published book can render a listing differently
from your preview.

### Seams for external tooling

`scripts/dev.sh` honors two optional environment variables, so a wrapper
that manages producer binaries can drive the loop without the repo
knowing about it:

- **`DEV_WATCH_EXTRA`** — space-separated extra paths to watch; edits
  there trigger a rebuild like any watched source. Never hand it a
  directory containing build output (a `target/`), which would loop the
  watcher.
- **`REBUILD_CMD`** — what to run on each change (default
  `scripts/rebuild.sh`). A wrapper that resolves producer binaries can
  point this back through itself so every cycle re-resolves — that is
  how edit-producer → site-rebuilds loops are wired.

> **panschema wasm note:** editing `panschema-viz/src` (the graph viz) does
> not rebuild the embedded wasm via `cargo build` — `build.rs` only runs
> `wasm-pack` when `panschema-viz/pkg/` is missing. Rebuild it with
> `wasm-pack build` in `panschema-viz`, or `rm -rf panschema-viz/pkg`.

## Layout

```
schema/
  cqa.yaml           # source of truth (LinkML)
book/editions/<id>/       # the mdbook documenting the N&M build, one per edition
scripts/                  # dev loop, rebuild, line-width + schema-path helpers
panschema.toml            # panschema generate manifest (ttl/shacl/json-schema/...)
panschema-publish.toml    # panschema's release + publish manifest
.github/workflows/docs.yml
```

The schema path is read from `panschema-publish.toml` (`[files].main`), so
CI, the pre-commit hooks, and the scripts follow the rename automatically —
nothing hardcodes the schema filename.
