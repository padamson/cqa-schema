# cqa

A [LinkML](https://linkml.io) ontology grounded in BFO 2020 (ISO/IEC
21838-2:2020) and the Common Core Ontologies (CCO), authored following
*Ontology Development 101* (Noy & McGuinness, 2001 — "N&M") adapted to
LinkML.

`cqa` is a vocabulary for **competency question benchmarks**: the questions
a knowledge graph exists to answer, each paired with the full specification
of its correct answer, so a set of them can be *run* as an evaluation rather
than filed as a design note.

The repo is two things at once:

- **`schema/cqa.yaml`** — the schema artifact itself.
- **`book/editions/<id>/`** — *Building cqa*, an mdbook that is the
  public log of building the schema from scratch, following N&M adapted
  to LinkML, published in editions ("Book editions" below). Each N&M
  step gets a chapter; the schema grows incrementally with **frozen
  listings** embedded at each stage.

The schema starts at `version: 0.1.0-dev`; prior releases, once cut, are
reachable via their git tags.

## Chapter ↔ N&M step

Chapters map to the seven N&M steps and live at
`book/editions/<id>/src/chNN-<kebab-title>.md`, listed in that
edition's `src/SUMMARY.md`:

1. Determine domain and scope · 2. Reuse existing ontologies ·
3. Enumerate important terms · 4. Define classes and hierarchy ·
5. Define slots · 6. Facets (`slot_usage`) · 7. Instances + validate

(The Introduction is the unnumbered prefix chapter `introduction.md`;
the seven steps are `ch01`–`ch07`, so the rendered Chapter N is N&M
Step N.) Match the existing voice: design discussion aimed at a reader
comfortable with LinkML and ontology basics, N&M quotes in
`admonish quote` blocks,
external claims backed by citations.

## Authoring with mdbook-listings

This repo uses **mdbook-listings**. Its `mdbook-listings` skill
(installed per "Agent skills" below) documents the full mechanics — `freeze`/`list`, the `{{#include}}` / `{{#callout}}`
/ `{{#diff}}` directives, inline `# CALLOUT:` markers vs. sidecar
TOML, and the tag/SHA-256 identity model. **Consult that skill
(`references/cli.md`, `references/directives.md`) for how the tool
works** — this section records only what's specific to *this* repo.

The book embeds **frozen snapshots** of `schema/cqa.yaml` so a
later edit can't silently change what a chapter renders. Repo
conventions on top of the tool:

- **Freeze from the authoring edition's book root**, source
  `../../../schema/cqa.yaml`, tag `cqa-yaml-v<N>`. Each chapter that
  advances the schema bumps the tag so earlier chapters keep pointing
  at the snapshot they froze:
  `cd "$(mdbook-panschema editions --authoring)" && mdbook-listings freeze ../../../schema/cqa.yaml --tag cqa-yaml-v2 --force`
  Each edition has its own `listings.toml`, so tags cannot collide
  across editions. This replaces the `cd book` form of the freeze and
  build commands in the installed authoring skill.
- **Callouts on files we author here** (e.g. `schema/cqa.yaml`)
  go *inline* as `# CALLOUT:` markers — never sidecar TOML, which is
  reserved for generated/third-party/no-comment-syntax listings.
- **Integrity check:** two gates run. `mdbook-listings verify
  --book-root book/editions/<id>`, run for every edition, fails on a
  frozen snapshot whose bytes no longer
  match `listings.toml` (edited but not re-frozen) or a broken
  `{{#include}}` / `{{#callout}}`; it is wired into both the
  `.pre-commit-config.yaml` hook and the `docs.yml` CI (before the
  build). `mdbook build` exiting 0 additionally fails on a missing
  `{{#callout}}` label or a broken `{{#include}}`.

### Dev loop (`scripts/dev.sh`) and the freeze foot-gun

`scripts/dev.sh` watches `schema/` and each edition's `src/` and
`*.toml`, and on change rebuilds the authoring edition from the working
tree into the combined `site/` (via `scripts/rebuild.sh`, which also
runs `mdbook-listings install` to refresh callout CSS/JS).
But **editing `schema/cqa.yaml` does not re-freeze the listing**
— a frozen listing is a point-in-time snapshot by design. The watcher
will rebuild from the *old* frozen bytes, so callout/listing changes
won't appear until you re-freeze. The loop:

1. Edit `schema/cqa.yaml` (markers and all).
2. `cd "$(mdbook-panschema editions --authoring)" && mdbook-listings freeze ../../../schema/cqa.yaml --tag <tag> --force`
   (writing `src/listings/<tag>.yaml` — itself watched — triggers the rebuild).
3. Hard-refresh the browser (Cmd+Shift+R) to bust cached CSS/JS/HTML.

If callouts seem missing, suspect a **stale `site/`** first: confirm
the freshly built `book/editions/<id>/build/<chapter>.html` has `callout-badge`
elements before debugging anything deeper.

For anything not covered above, defer to the installed `mdbook-listings`
skill, then `mdbook-listings <cmd> --help`.

## Building

```
mdbook serve "$(mdbook-panschema editions --authoring)"   # local preview with live reload
mdbook build "$(mdbook-panschema editions --authoring)"   # output to its build/
mdbook-panschema editions   # every edition from main, as CI publishes it
```

Preprocessors must be on `PATH`: `mdbook-listings`, and the
`mdbook-admonish` fork (`feat/mdbook-0.5-compat`); `mdbook-panschema`
(from the panschema workspace) must be there too — it generates the
gitignored book→schema toolbar-link assets that `book.toml` references
(`scripts/install-assets.sh` runs all three installers in every
edition). `mdbook-panschema editions` builds from the committed `main`,
never the working tree, and runs those installs in its own checkout.
The published docs site (schema HTML + every edition) is built and
deployed by `.github/workflows/docs.yml` via the panschema toolchain on
push to `main`. A pull request into `main` runs the same steps but
deploys nothing. The checks that read the checkout see the PR's
changes, while `panschema publish` and `mdbook-panschema editions` build
`main`, so a green PR run tests its tools against `main`'s content, not
its own book. That is what a Dependabot PR needs tested.
`.github/dependabot.yml` proposes action bumps once a week, grouped
into one PR, merged by hand once it is green. CI installs mdbook and
wasm-pack through `taiki-e/install-action` with no version, so the
action's pinned SHA is their pin, and a Dependabot PR that moves it
names the tools that moved in its release notes. A new release can
change the rendered book: install it locally, rebuild, and compare
before merging. mdbook-listings is not in the action's manifest and
keeps an exact `env:` pin in `docs.yml`, which nothing watches. The
release list is read from the tags, so a release is the version bump on
`main` plus its tag, pushed together: `git push --atomic origin main
<tag>`.

Math is **opt-in** and not shipped in the stock template: to write `$…$`
in chapters, enable `mdbook-katex` (pin `0.10.0-alpha`, ordered
`after = ["admonish"]`) per the README "Math (optional)" section. Once
enabled it becomes a required preprocessor, so also add it to CI.

## Agent skills

Agent skills are pinned dependencies, like the schema dependencies in
`panschema.lock`. `skills-lock.json` (committed) records each skill's
source and a content hash; `npx skills add` fetches the content into
`.claude/skills/<name>/`, which is gitignored. Run the install once
after cloning, from a plain terminal (Claude Code's sandbox denies
writes under `.claude/skills/`, and the CLI then exits without
installing):

```
npx skills add padamson/mdbook-listings -s mdbook-listings -a claude-code -y
npx skills add padamson/ontology-authoring-template -s ontology-authoring-advance-step -a claude-code -y
npx skills add padamson/panschema -s panschema-usage -a claude-code -y
```

Name the skill with `-s`: a bare `npx skills add <repo>` installs every
skill the repo offers. The CLI prints a success line even when the write
was denied, so check the install rather than the message: `ls
.claude/skills/` shows one directory per skill above, and
`metadata.version` in each `SKILL.md` is the version installed. Refresh
with `npx skills update`, choosing **Project** at its prompt (it
defaults to Global), then re-read `metadata.version`. `git ls-files
.claude/skills/ .agents/` must print nothing.

The authoring skill is installed, not copied: ontology-authoring-template
publishes it as `ontology-authoring-advance-step`, so this repo keeps no
copy of it to fall out of date.

## Conventions

- **Trunk-based on `main`.** Commit directly to `main`; don't propose
  feature branches as a workflow.
- **Two sets of competency questions: `CQ-cqa` and `CQ-wine`.** Every ontology
  built with the ontology-authoring-template sketches competency questions for
  its own schema, and this one is no different — the only wrinkle is that
  `cqa`'s subject *is* competency questions, so "the competency questions" is
  ambiguous unless labelled. **`CQ-cqa`** is this ontology's own Step 1 output (what a schema
  for benchmarks must express); **`CQ-wine`** is the worked example's, which
  are *data* — records conforming to `cqa`. Individual questions take a
  number: `CQ-wine 4`, `CQ-cqa 2`. Use the labels wherever both could be
  meant, including commits and notes.

  Hyphen, not a subscript: the labels have to survive YAML record names,
  commit messages, and cross-repo notes, and a subscript copies out as
  "CQcqa" — ambiguous again. The form also matches the schema's own
  kebab-case id pattern, so a prose label and a record id can be one string.
- **The worked example lives in the consuming repo, not here.** A benchmark
  is meaningless without the graph it benchmarks, and this schema has no
  domain graph — its instances are always a consumer's. So the demand driver
  for every class and slot is the wine benchmark authored in
  `ontology-authoring-template`, consumed during development with
  `path = "../ontology-authoring-template"` and by version at release.
  Appendix A embeds it as a listing frozen from that repo; `mdbook-listings
  verify` checks frozen bytes against the manifest, never the original
  source, so CI stays green without it.

  **Placeholder anchors are not an acceptable substitute.** An invented IRI
  can be minted to justify whatever slot was already wanted, which is the
  reasoning-backward failure the method exists to prevent. Illustrative
  snippets in spec prose may use them; nothing that drives the model may.
- **`spike/` is a reference target, not a source.** It holds an earlier
  throwaway build of the schema and is gitignored. Chapters may consult it
  to see where the design landed, but nothing is copied from it wholesale —
  each step reintroduces only what that step's competency questions demand.
  If a chapter's questions don't move the design off the spike, the
  questions weren't doing any work.
- **Schema edits are chapter-scoped.** When a chapter advances the
  schema, freeze a new listing tag in the same change so the prose and
  the snapshot stay consistent.
- **Demand-driven dogfood.** The schema grows because the worked
  example needs it, not speculatively. The worked example
  should drive the build from Step 1 — if a class or slot only earns
  its keep at validation (Step 7), that is a smell. Here the worked
  example is cross-repo; see "The worked example lives in the consuming
  repo" above.
- **Schema comments explain why, not what.** The YAML is self-documenting
  about what a line does: a prefix named `linkml` obviously declares the
  LinkML metamodel, and an empty `classes:` is obviously empty. A comment
  earns its place only when it records a decision or heads off a plausible
  mistake — why BFO and CCO are reached by URI rather than added to
  `imports:`, for instance. This bites harder here than in ordinary source,
  because the schema ships as a frozen listing: every comment costs lines in
  a listing that exists to show something else, and the scaffold's own
  fill-in-the-blank comments are meant to be deleted once discharged (wine
  keeps none of them).
- **Declare `default_range`; do not repeat it per slot.** An explicit
  `range:` appears only where a slot differs from the default — an enum, a
  class, a `uri`, a number. Stating the default once keeps it from drifting,
  and a slot list where every string slot repeats `range: string` buries the
  two or three slots whose range is the interesting part. This is deliberate
  and differs from wine's style, which declares a range on every slot.
- **panschema is a dependency we own, not a constraint to design around.**
  The book takes its capabilities for granted. It never cites panschema
  issue numbers, never reports that a feature is missing, and never explains
  a workaround in prose: when a schema needs something panschema cannot yet
  do, block here, implement it there, and come back. Naming a capability the
  work *used* is fine ("every CCO IRI was resolved through panschema's label
  lookup"); narrating what it lacked is not, and neither is letting a
  chapter read as though the tooling shaped the model. The same holds for
  scaffold TODOs — write the check to perform, not the gap to wait on.
- **External grounding is by URI, not import.** BFO/CCO/etc. are
  referenced via `subclass_of` + prefixes, *not* LinkML `imports:`
  (which is for other LinkML schemas — only `linkml:types` is
  imported). (`class_uri` asserts identity, which ch04 rejects as too
  strong; a slot uses `slot_uri` only where its meaning is the
  external property's, as `version` is `pav:version`.)
- **Schema descriptions state domain and purpose, nothing else.**
  `description:` fields ship with the artifact (generated docs, RDF,
  downstream graphs), so they carry only what a consumer of the *artifact*
  needs: what the ontology is about and what it is for. They never
  reference the book's structure (no chapter/step numbers, no "N&M", no
  CQ numbers, no "a later chapter will…") — and, just as important, they
  never carry the *method* story: no "built following Ontology
  Development 101", no "grounded in BFO/CCO", no "adapted to LinkML". The
  grounding is self-documenting in the schema structure (prefixes,
  `subclass_of`); the methodology belongs to the book.
  Book-facing and method-facing context goes in `#` comments or
  `# CALLOUT:` markers (which stay out of the artifact's data), not in
  permanent metadata.
- **Deferrals are tracked in the target chapter's scaffold.** When
  prose defers work to a later chapter or N&M step ("deferred to
  Chapter 6", "Step 5 work", "Chapter 7 will revisit"), add a
  matching `[ ]` TODO line in that chapter's `.md` scaffold,
  inside the HTML-comment `CARRIED-IN DEFERRALS` block (every step
  stub ships with one), citing the source chapter/section. Write
  the prose deferral and the scaffold TODO *together* so nothing
  promised is dropped. The HTML comments never render.
  (Within-chapter "next increment" work — not yet deferred to a
  *later* chapter — stays in the buildout plan, not these blocks.)
- **Strip a chapter's scaffold once finalized.** When a chapter is
  authored, delete its whole HTML-comment scaffold block
  (`CHARTER`/`SECTION OUTLINE`/`AUTHORING CHECKLIST`, and its own
  now-discharged `CARRIED-IN DEFERRALS`). Only *unwritten* chapters keep
  scaffolds — their `CARRIED-IN DEFERRALS` blocks still hold live TODOs
  that earlier chapters wrote forward. A finished chapter's own forward
  deferrals live in the *later* chapters' scaffolds, not its own, so
  deleting its scaffold loses nothing.

## Book editions

The book is published in editions, declared in `panschema-publish.toml`
under `[editions]`. Each edition is a book directory on `main`,
`book/editions/<id>/` (the id is the directory name; the dev loop relies
on it), covering the releases from its `from` up to the
next edition's `from`; the newest edition also covers `main`. Every
edition is published at `book/<id>/`, and the current one (the edition
holding the newest release) is copied to the site root. Edition 1 starts
at `v0.1.0`. Edition 2 starts at `v0.2.0`, unreleased, and is the
authoring edition; its chapters began as copies of edition 1's and are
revised in place.

- **Within an edition, the book is a log.** Narrate reversals and dead
  ends as they happened, and do not retro-edit earlier chapters to hide a
  path that was later abandoned. A release that needs no retelling is
  narrated in a section of its own, the way ch07's "One flag per class"
  narrates `v0.1.1`.
- **A release starts a new edition when the log would mislead.** If it
  reverses a decision earlier chapters build on, a reader who follows
  the book from Chapter 1 ends up with a model the schema no longer has,
  and a section at the back does not fix that. The new edition is a new
  directory and a new `[[editions.edition]]` whose `from` is that
  release. It derives the new model from Chapter 1, opens with a short
  preface saying what changed from the previous edition, and is a log
  from then on. The default is not to start one, and an edition can only
  start at a release.
- **A new edition's listings are rewound, then frozen forward once.** An
  edition starts as a copy of the last one, frozen listings included, but
  its schema is already ahead of every stage those listings snapshot.
  Re-freezing a stage means rebuilding what `schema/cqa.yaml` looked like
  at that chapter, and every later listing carries the same edit, so
  re-freezing per change repeats that work for each listing after it.
  Instead, pick the rewind point: the earliest listing the new model
  changes. Delete it and every listing after it from the edition's
  `listings.toml` and `src/listings/`. In the chapters, replace each
  `{{#include}}` or `{{#diff}}` that named one with an HTML comment
  starting `LISTING <tag>:` that records its parameters, and each inline
  `{{#callout X}}` with `<!-- callout X -->` where it stood (never a
  directive inside a comment, since the preprocessors may still expand
  it). Record the rewind and a forward-freeze TODO in the preface's
  `CARRIED-IN DEFERRALS`. Changes then touch the schema and prose only.
  The forward freeze, chapter by chapter from the rewind point, comes once
  the edition's model is final and before its release: for each stage,
  rewrite `schema/cqa.yaml` to that stage in the working tree, freeze it
  from there, and restore it.

  The rewind point can move earlier at any time. Authoring a new edition
  is how you find out which decisions the new model reverses, so finding
  one earlier than the rewind point is expected, not a mistake. Rewinding
  again is the same operation from the earlier listing, and it only
  deletes listings copied from the last edition, because nothing after the
  rewind point is frozen until the end. After the forward freeze, a
  further rewind is the same operation followed by another forward freeze.
- **New chapters and listings go into the authoring edition**: the one
  marked `authoring = true`, else the last. `mdbook-panschema editions
  --authoring` prints its book directory, and the dev scripts and the
  freeze commands above use it.
- **An older edition is fixed on `main`.** A commit to its directory
  republishes it for every release in its span. A schema patch to an
  older line (`v0.1.2` while `main` carries a later minor) is a commit on
  that line's newest tag, tagged and pushed on its own. A tag runs the
  workflow in its own commit, which on an older line predates the
  current one, so publish it by running the docs workflow on `main`:
  `gh workflow run docs.yml --ref main`. There is no long-lived release
  branch.

## Lessons

These are lessons-learned baked into the template; each step-chapter
stub carries the matching one as a LESSON line in its authoring
checklist.

- **Worked example as demand-driver from Step 1.** Pick the worked
  example early and let it pull every class and slot into existence; if
  something only validates at Step 7, that is a smell.
- **Verify the upper-ontology CATEGORY, not just the IRI.** A resolving
  BFO/CCO IRI is not enough — confirm the category fit (e.g. don't
  ground a Quality as an Information Content Entity).
- **Graph viz as island detector.** Build the panschema class graph and
  treat island (disconnected) nodes as bugs to explain or remove.
- **A concern that fights the layer wants a companion ontology.** If a
  concept keeps resisting the foundational grounding, that is a signal
  it belongs in a separate companion ontology, not bolted on here.
- **The book is a chronological log within an edition.** Narrate
  reversals and dead-ends as they happened; do not retro-edit earlier
  chapters to hide a path that was later abandoned. Only a new edition,
  started at a release, rewrites them ("Book editions").
- **Speculative forward-references stay in private notes.** Keep
  future-repo names, roadmap, and speculative plans out of the public
  book and commits.
