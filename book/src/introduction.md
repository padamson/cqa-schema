# Introduction

This book documents building **cqa**: an ontology taken from nothing to a
validated artifact, one step at a time, following Noy & McGuinness's
[*Ontology Development 101*](https://protege.stanford.edu/publications/ontology_development/ontology101-noy-mcguinness.html)
(2001 — "N&M") adapted to [LinkML](https://linkml.io). There is one chapter
per N&M step. The schema grows incrementally, and each chapter embeds a
*frozen listing* of it as it stood at that point — a snapshot pinned by hash
with [mdbook-listings](https://github.com/padamson/mdbook-listings), so
editing the schema later can't silently change what an earlier chapter
shows.

The ontology is grounded in BFO 2020 (ISO/IEC 21838-2:2020) and the Common
Core Ontologies (CCO). Grounding is by URI: each class is referenced through
`subclass_of` and the prefixes, not pulled in with LinkML `imports:` (which
is reserved for other LinkML schemas).

<a id="jargon-bfo-and-cco"></a>

```admonish note title="Jargon: BFO and CCO"
**BFO** (the Basic Formal Ontology, ISO/IEC 21838-2:2020) is a small
top-level ontology of the most general categories: objects, qualities,
processes, and the like. **CCO** (the Common Core Ontologies) is a
mid-level layer built on top of BFO. We *ground* the ontology in them by
pointing its terms at BFO/CCO IRIs instead of inventing categories from
scratch.
```

## Competency questions: CQ-cqa and CQ-wine

N&M's method begins with competency questions. At Step 1 you sketch the
questions the ontology ought to be able to answer, which is how the domain
gets bounded; at Step 7 you check whether it can, which is the litmus test.

<a id="jargon-competency-question"></a>

```admonish note title="Jargon: competency question"
A **competency question** is a question the ontology exists to answer.
N&M introduce them at Step 1 as a way of bounding the domain, and treat
them as a sketch: write down what the knowledge base should be able to
answer, then check at the end whether it can.
```

Every ontology built with the
[ontology-authoring-template](https://github.com/padamson/ontology-authoring-template)
sketches competency questions for its own schema, and this one is no
different — `cqa` itself is built from that template. What `cqa` adds is only
that its subject *is* competency questions and their answers, so the
questions driving the build and the thing being built are about the same kind
of object, and "the competency questions" stops being an unambiguous phrase.

Two labels keep them apart, used throughout:

- **CQ-cqa** — this ontology's own competency questions: what a schema for
  benchmarks must be able to express. The ordinary Step 1 output, sketched
  in [Chapter 1](ch01-domain-and-scope.md).
- **CQ-wine** — the worked example's, about wine. Not questions this book
  asks: they are its *data*, each becoming a record that conforms to `cqa`.
  They stay in that same template repository (which ships wine as its worked
  showcase), beside the graph they are asked against.

Individual questions take a number — CQ-wine 4, CQ-cqa 2.

CQ-wine drives the build, and it stays where it is for a reason: a benchmark
names records in the graph it is asked against, and `cqa` has no graph. An
example invented here could be made to justify whatever the schema already
wanted, so instead a class or slot exists only because some real question
about wine could not be expressed without it.

The dependency runs one way. Nothing here fetches the wine schema — CQ-wine
is a design input, and the copy a later chapter embeds is a frozen snapshot.
Ontologies depend on this contract; it depends on none of them.

## Reading this book, and reading the schema

The two audiences want different things, and get different artifacts.

If you are **integrating** `cqa` — wiring it into a repository so your own
competency questions become a checkable benchmark — the generated schema
documentation is your reference. It is published next to this book under
[`schema/`](schema/main/), with every class, slot, and enumerated value laid
out, and it stays current with the artifact rather than with the narrative.

If you want to know **why the schema is shaped the way it is**, read on. This
book is a chronological log, not a snapshot: where a decision was reversed,
the chapter that reversed it says so rather than the earlier chapter being
quietly corrected. That makes it a poor lookup table and a good explanation.

What `cqa` covers, what it is for, and what it deliberately leaves out are
[Chapter 1](ch01-domain-and-scope.md)'s subject.
