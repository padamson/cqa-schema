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

The build is in progress. See [the book](book/src/) for how far it has got.

## Authoring the ontology

Work one N&M step at a time with the **`advance-step`** skill
(*"do Step 1"*): write `book/src/introduction.md`, then `book/src/ch01`…
`ch07`, so the rendered Chapter N is N&M Step N. Each step advances
`schema/cqa.yaml` only as its worked example demands and freezes a
listing snapshot the chapter embeds. Grounding is by URI — reference reuse
vocabularies as prefixes, never LinkML `imports:`.

## Building the book

```
cd book && mdbook serve   # local preview with live reload
cd book && mdbook build   # output to book/build/
```

Preprocessors must be on `PATH`: `mdbook-listings`, the `mdbook-admonish`
fork, and `mdbook-panschema` — `scripts/install-assets.sh` installs all
three. CI (`.github/workflows/docs.yml`) verifies the instance data,
generates the machine-readable formats (via `panschema.toml`), builds the
book, and deploys the combined site to Pages.

## Layout

```
schema/
  cqa.yaml           # source of truth (LinkML)
book/                     # mdbook documenting the N&M build
scripts/                  # dev loop, rebuild, line-width + schema-path helpers
panschema.toml            # panschema generate manifest (ttl/shacl/json-schema/...)
panschema-publish.toml    # panschema's release + publish manifest
.github/workflows/docs.yml
```

The schema path is read from `panschema-publish.toml` (`[files].main`), so
CI, the pre-commit hooks, and the scripts follow the rename automatically —
nothing hardcodes the schema filename.
