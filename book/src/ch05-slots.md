# Slots

This chapter applies **Step 5** of *Ontology Development 101* (Noy &
McGuinness, 2001) to cqa.

```admonish quote title="Noy & McGuinness 2001 — §Step 5"
The classes alone will not provide enough information to answer the
competency questions from Step 1. Once we have defined some of the
classes, we must describe the internal structure of concepts. [...] In
general, there are several types of object properties that can become
slots in an ontology: "intrinsic" properties such as the flavor of a
wine; "extrinsic" properties such as a wine's name, and area it comes
from; parts, if the object is structured [...]; relationships to other
individuals; these are the relationships between individual members of
the class and other items (e.g., the maker of a wine, representing a
relationship between a wine and a winery, and the grape it is made from).
```

Step 4 left four questions open and one check undischarged. This step answers
all five, so most of the chapter is those decisions rather than a walk
through the slot list.

One rule runs underneath them. A slot is required when a competency question
cannot be answered without it, and optional otherwise; nothing is required
for tidiness.

{{#diff cqa-yaml-v3 cqa-yaml-v4 context=7 caption="Step 5: the slots"}}

## Identity: one slot, refined per class

CQ-cqa 7 asks what distinguishes one benchmark's questions from another's.
[Chapter 4](ch04-classes-and-hierarchy.md) made `Benchmark` a class; the
mechanism is here, and it turns on the difference between LinkML's
`identifier` and its `key`, which look interchangeable but are not.

```admonish note title="Jargon: identifier and key"
**`identifier: true`** marks a slot whose value is unique *globally* — the
record is the same thing wherever it appears, and its IRI is minted in the
schema's namespace.

**`key: true`** marks a slot whose value is unique *within its container* —
the record belongs to the thing holding it, and its IRI is minted beneath
the container's own IRI.
```

A benchmark is one thing everywhere, so its `id` is an `identifier`. A
question belongs to its benchmark, so its `id` is a `key`. Both classes use
the same `id` slot {{#callout scoped}}, refined on
`CompetencyQuestionAnswer` through `slot_usage`.

The result is what CQ-cqa 7 asked for. Two benchmarks each holding a `cq-01`
produce:

```turtle
<https://w3id.org/cqa/alpha/cq-01>
<https://w3id.org/cqa/beta/cq-01>
```

Distinct records, from identical local identifiers, because each mints
beneath the benchmark that holds it.

`DomainRecord` takes the plain `identifier` form. Its instances are records
in someone else's graph, named by absolute IRIs, and nothing here mints them.

## The anchors carry two readings

In [Chapter 1](ch01-domain-and-scope.md) we found that a correct answer of
"nothing on record" still has to retrieve something — the records whose
*missing* connection is the answer. Without them an evaluator cannot tell a
correct negative from a system that retrieved nothing at all.

That constrains what this slot can be called. A name like `evidence` would be
wrong for the negative case, where the records are not evidence for the
answer but the ground its absence is observed against. `expected_anchors`
{{#callout anchors}} names what retrieval must reach and stays silent about
why, so one slot covers both readings.

The description carries the rest, because a name cannot. An author writing a
closed-world negative needs to be told that the slot is not optional for
them, and that leaving it empty makes their question unevaluable rather than
lenient.

`expected_citations` is the narrower set: the records an answer must rest on,
always among the anchors. Retrieving a record is not the same as answering
from it, and only the second belongs in a citation. Empty is a real value —
a closed-world negative cites nothing, because there is nothing to cite.

## `answer_kind` is multivalued

[Chapter 3](ch03-important-terms.md) wrote that an evaluator "switches on
the kind", which assumes a question has exactly one. Choosing kinds for
CQ-wine — the seven competency questions of the wine ontology, this book's
worked example, published with the
[ontology-authoring-template](https://github.com/padamson/ontology-authoring-template)
— showed that assumption is wrong.

CQ-wine 7 asks what were good vintages for Napa Zinfandel. The answer rests
on a vintage chart's verdict, so dropping the source makes it worse: that is
`attribution`. It also reads 2018 `good` against 2017 `average`, and that
contrast is what makes a vintage a good one: that is `comparison`. Both
descriptions are accurate, and neither is a stretch to make the other fit.

Forcing a single value would need a tie-break rule, and there is no honest
one. "Name the strictest check" sounds decisive until you try to rank
`attribution` against `comparison`, which measure different things.

So the slot is multivalued {{#callout kinds}}, and every kind named is a
check that must pass. That changes what Chapter 3 said. Later steps learn
things earlier steps could not, so Chapter 3 stays as written and the change
is recorded here.

## The target takes four slots

CQ-cqa 6 asked which graph a benchmark is asked against. CQ-cqa 8 is that
question made precise, and Chapter 4 answered it in three parts: which
schema, at which version, and which dataset. At Step 5 we found a fourth
part.

Those three assume a schema and the data conforming to it move together.
Sometimes they do. A schema published together with its own curated datasets
releases them under one version, and that single version number describes
both the model and the records.

Sometimes they do not, and this is the ordinary case for anyone building on
someone else's published schema. Their data lives in their own repository and
moves on their own cadence, so the schema's version says nothing about which
records exist in their graph. The two versions are independent, and CQ-cqa 8
needs a fourth answer: at which version of that dataset.

Here they are as slots on `Benchmark` {{#callout target}}.

```admonish note title="Jargon: dataset"
A **dataset** is one instance graph — a body of records conforming to a
schema. One schema can have several. Wine publishes a four-record teaching
preview and a thirty-seven-record worked example, both conforming to
`wine.yaml`, and they do not hold the same records.

A dataset is what a benchmark is asked against. The schema matters because
it determines what IRI each record gets; the dataset determines which
records exist to be anchored at all.
```

`target_schema` names the vocabulary the records conform to, and
`target_schema_version` which release of it, since a release can change how
identifiers are minted. `target_dataset` names which body of records the
anchors resolve in, and `target_dataset_version` which state of it, since
records can be added, removed or corrected without the schema moving at
all.

Step 4 left one part of this undecided: whether the version recorded is the
schema's or the dataset's. It is both, in separate slots, for the reason
above.

The dataset half matters more than it first appears. A record that disappears
breaks an anchor loudly. A record that *changes* breaks nothing visible.
Correct a vintage assessment's verdict from `good` to
`average` and every anchor in the question about good vintages still
resolves, every citation still resolves, validation passes, and the ground
truth is quietly false. Recording the dataset's version is what lets that be
noticed at all.

Two things it does not do. It does not detect drift: an evaluator has to
compare the version recorded here against the version it actually read, and
nothing in this schema makes it. And it has nothing to say for a benchmark
aimed at a moving branch rather than a release, where there is no version to
record and no promise that anything holds still.

## Four slots, two of them often redundant

We considered making `target_schema` and `target_schema_version` optional. A
benchmark published alongside the schema it targets already carries both
facts: one package, one version. Wine's benchmark will ship beside
`wine.yaml`, and for it those two slots restate what the package says.

They are required anyway, and so is `target_dataset_version`. A benchmark
should be readable without knowing where it was published. Third-party
publishing decides it: someone benchmarking a graph they do not own has no
shared package to appeal to, and neither does anyone reading that benchmark
afterwards. Requiring all four makes every benchmark state its target in
full.

The cost is redundancy, and it is worth naming rather than explaining away.
When a benchmark, its example instance graph, and the schema all move on one
version, `target_schema_version` and `target_dataset_version` hold the same
string as each other and as the package, and a reader could have derived
both. We overspecify on purpose: a fact written in the record survives the
record being moved, and a derived one does not.

Two of the four are not redundant in any arrangement. `target_dataset` is
needed because one schema can have several graphs. `target_schema` is needed
because the anchors are IRIs in the schema's base namespace, so holding it
lets a tool check that a benchmark's anchors belong to the schema it claims,
using nothing but the benchmark.

## What this would look like if datasets were addressable

Four slots is a fallback. If a target graph were an identified resource — an
IRI resolving to something that declares its own schema and version — a
benchmark would name it once and stop, because those are facts about the
dataset rather than about the benchmark.

A dataset becomes a node with an IRI as soon as its root class carries an
identifier. `Benchmark` carries one, so every benchmark is already such a
resource. Wine's `WineCatalog` deliberately is not: its two curated graphs
share records and are meant to merge, and identifying the root would scope
them apart. So these slots say in the benchmark what the dataset cannot say
about itself, and when a target does arrive identified, one reference should
replace the four. That change is in how data is published, not in how
benchmarks are written.

## The island check

Every class in the generated graph is reachable:
`CompetencyQuestionAnswer` reaches `DomainRecord` through the anchor and
citation slots, and `Benchmark` reaches `CompetencyQuestionAnswer` through
the questions it holds. No class sits alone, so there is nothing here to
explain or remove.
