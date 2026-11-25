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

<!-- LISTING cqa-yaml-v4: diff from cqa-yaml-v3, context 7, caption "Step 5: the slots". Placeholder until the forward freeze. -->

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
the same `id` slot <!-- callout scoped -->, refined on
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
<!-- callout anchors --> names what retrieval must reach and stays silent about
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

So the slot is multivalued <!-- callout kinds -->, and every kind named is a
check that must pass. That changes what Chapter 3 said. Later steps learn
things earlier steps could not, so Chapter 3 stays as written and the change
is recorded here.

## The target takes three slots

CQ-cqa 6 asked which graph a benchmark is asked against. CQ-cqa 8 is that
question made precise, and Chapter 4 answered it: which schema, at which
version, and which datasets, each at which version. It also made each target
dataset a record of its own, so a dataset's name and its version travel
together.

That leaves one part to settle here: why a dataset needs a version separate
from the schema's. Sometimes they are the same. A schema published together
with its own curated datasets releases them under one version, and that
single version number describes both the model and the records.

Sometimes they are not, and this is the ordinary case for anyone building on
someone else's published schema. Their data lives in their own repository and
moves on their own cadence, so the schema's version says nothing about which
records exist in their graph. The two versions are independent, and so are
the versions of two datasets published apart.

Here they are as slots on `Benchmark` <!-- callout target -->, and the two
that describe each `TargetDataset`.

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
identifiers are minted. `target_datasets` lists the bodies of records the
anchors resolve in, inline, since a target dataset has no identifier to
refer to it by. Each names its dataset in `dataset` and the state of it in
`version`, since records can be added, removed or corrected without the
schema moving at all.

`version` is the first slot in cqa whose predicate is not cqa's own. Every
other slot emits a `cqa:` property, because what it states is particular to
benchmarks. A version is not: it is the release identifier of something
published, and the [Provenance, Authoring and Versioning
ontology](https://pav-ontology.github.io/pav/) (PAV) already has the
property for it, `pav:version`. The slot declares it as its `slot_uri`, so
the generated RDF states the version with the predicate a consumer reading
provenance already knows. That is an identity claim, which Chapter 4
rejected for `class_uri` because an EARL class only corresponds to a cqa
one. Here the meaning is the same, so identity is the right strength.

[Chapter 2](ch02-reusing-existing-ontologies.md) set PROV-O aside because no
competency question asked for provenance. PAV specializes PROV-O for
authorship and versioning ([Ciccarese *et al.*,
2013](https://doi.org/10.1186/2041-1480-4-37)), and CQ-cqa 8 now asks for a
version. One property is all cqa takes from it.

The dataset half matters more than it first appears. A record that disappears
breaks an anchor loudly. A record that *changes* breaks nothing visible.
Correct a vintage assessment's verdict from `good` to
`average` and every anchor in the question about good vintages still
resolves, every citation still resolves, validation passes, and the ground
truth is quietly false. Recording the dataset's version is what lets that be
noticed when the correction is released, since the release moves the
version. A correction made within a release moves nothing, and "Values a
correct answer states" below covers that case.

Two things it does not do. It does not detect drift: an evaluator has to
compare the version recorded here against the version it actually read, and
nothing in this schema makes it. And it has nothing to say for a benchmark
aimed at a moving branch rather than a release, where there is no version to
record and no promise that anything holds still.

## Required, and often redundant

We considered making `target_schema` and `target_schema_version` optional. A
benchmark published alongside the schema it targets already carries both
facts: one package, one version. Wine's benchmark will ship beside
`wine.yaml`, and for it those two slots restate what the package says.

They are required anyway, and so is each dataset's `version`. A benchmark
should be readable without knowing where it was published. Third-party
publishing decides it: someone benchmarking a graph they do not own has no
shared package to appeal to, and neither does anyone reading that benchmark
afterwards. Requiring all of them makes every benchmark state its target in
full.

The cost is redundancy, and it is worth naming rather than explaining away.
When a benchmark, its example instance graph, and the schema all move on one
version, `target_schema_version` and the dataset's `version` hold the same
string as each other and as the package, and a reader could have derived
both. We overspecify on purpose: a fact written in the record survives the
record being moved, and a derived one does not.

Two of the slots are not redundant in any arrangement. `target_datasets` is
needed because one schema can have several datasets and a benchmark can need
more than one of them. `target_schema` is needed because the anchors are IRIs
in the schema's base namespace, so holding it lets a tool check that a
benchmark's anchors belong to the schema it claims, using nothing but the
benchmark.

## What this would look like if datasets were addressable

A target dataset is named, not referenced. If a dataset were an identified
resource — an IRI resolving to something that declares its own schema and
version — a benchmark could point at it, because those are facts about the
dataset rather than about the benchmark.

A dataset becomes a node with an IRI as soon as its root class carries an
identifier. `Benchmark` carries one, so every benchmark is already such a
resource. Wine's `WineCatalog` deliberately is not: its two curated graphs
share records and are meant to merge, and identifying the root would scope
them apart. So `dataset` holds the name the target package publishes the
dataset under, and the benchmark says what the dataset cannot say about
itself. When a target does arrive with identified datasets, `dataset` could
hold the IRI instead. That change is in how data is published, not in how
benchmarks are written.

## Values a correct answer states

`expected_values` lists the facts a correct answer states, one
`ExpectedValue` each. No check reads a system's answer against them. What
they do is keep the answer key true: each entry is a claim about the target
graph, and where the benchmark and the graph sit together, a claim the graph
contradicts fails. A correction like the one above, which no version records,
then fails a check instead of leaving the ground truth quietly false.

CQ-wine 7 states two:

```yaml
expected_values:
  - record: va-napa-zin-2018
    slot: verdict
    value: good
  - record: va-napa-zin-2017
    slot: verdict
    value: average
```

`record` is written like an anchor. It is ranged on `DomainRecord` and
expands against `target_schema` the same way, so `va-napa-zin-2018` here
names the record the question's anchors name. It must also be among them,
which [Chapter 6](ch06-slot-usage-and-facets.md) takes up.

`slot` is the slot's name as the target schema gives it and the target's
instance data writes it <!-- callout named -->: `verdict`, not wine's IRI for
the property. `connecting_class`, in the absence claim, names a class by IRI
instead, and the two conventions differ on purpose. A class is how the target
graph types its records, and a check for a joining record compares the types
records carry, which are IRIs. A slot is how the target's data is written,
and a check of a value reads it off the record by the key the record carries.
`target_schema_version` keeps the name unambiguous, since a name means one
slot within one release of one schema.

`value` is text <!-- callout quoted -->, read by the range of the slot it is
claimed at rather than by YAML. So the target schema decides how a value is
compared: `good` as a permissible value of wine's `VerdictEnum`, a number by
value, and a bare id at a class-ranged slot as the IRI the target mints for
it. Quoted, the value reaches that check as written, so `no` stays the
word "no" instead of becoming YAML's false. The cost is that a number is
written quoted:

```yaml
  - record: pr-cabsauv-grilledmeat
    slot: confidence
    value: '0.9'
```

Written as `0.9`, the value is a float, and the record fails verification
because the slot's range is text.

LinkML's own spelling for a value of any type is `range: Any`, or an
`any_of` over the scalar types. We chose text so that the target slot is the
only authority on how a value is read. That has a second cost: the generated
Turtle carries `cqa:value "0.9"` as a plain string for a fact that is a
float, and a Turtle reader cannot type it without the target schema.

All three slots of an entry are required, since an entry missing any of them
states nothing that can be checked. `expected_values` itself is optional, by
the rule this chapter opened with: a closed-world negative states no value,
because its answer is a missing connection, and a synthesis reads a pattern
across records that no single slot carries.

A question that states its values now says the same fact twice. CQ-wine 7's
ground truth says the chart rates 2018 good, and its first entry says the
assessment's `verdict` is `good`. Nothing checks one against the other, and
neither is the authority. Both are written from the source the answer rests
on, here the regional vintage chart, so when they disagree the record is
wrong. The author settles it from the source, not by copying one into the
other.

## An answer given in order

Some answers are a sequence. Wine asks for none, but two questions in
another graph cqa benchmarks do: the steps of a procedure, in order, and the
order in which a set of places is walked. A set of anchors cannot say
either, so the order was written only in `ground_truth`, where nothing reads
it.

In both, the order is already in the graph. Each record carries its
position, and the answer lists the records by it. So a question names the
slot that orders its answer, and states the values at that slot as expected
values like any other. `ordered_by` <!-- callout ordered --> names the slot
the way `slot` does, by the name the target schema gives it. A correct
answer gives the records the question's expected values name at that slot
in ascending order of their values, compared as the slot's range compares
them.

Wine asks for no order, so the example orders wine's three pairing
recommendations by confidence. It is a question this repository's tests ask
of wine, not one of wine's own:

```yaml
expected_values:
  - record: pr-cabsauv-grilledmeat
    slot: confidence
    value: '0.9'
  - record: pr-beaujolais-chicken
    slot: confidence
    value: '0.7'
  - record: pr-chardonnay-seafood
    slot: confidence
    value: '0.85'
ordered_by: confidence
```

The entries are not in order, and need not be. The values decide the
order, and each is checked against the graph as any expected value is.

We also considered listing the records in order. LinkML marks a multivalued
slot whose order matters with `list_elements_ordered: true`, and a subslot
of `expected_anchors` could carry it. The order holds in YAML and JSON and
is lost in RDF. LinkML writes a multivalued slot to RDF as one triple per
value, with no order among them. Keeping the order would take an
`rdf:List`, which OWL 2 reserves for its own syntax, so an ontology holding
its data in one is no longer OWL 2 DL. The list would also be a second copy
of the positions the graph carries, and nothing would check that the two
agree.

An order is not an answer kind. A question asking for a procedure's steps
reads each step from one record, which makes it a lookup, and its answer
comes in order. `answer_kind` says where an answer is found, and an order
can come with any kind that states values, so it is a slot of its own, and
optional.

The order is ascending only. Both questions that asked for one list their
records by increasing position, and a descending order waits for a question
that needs it.

Reading the order off the values has two limits. A record the answer lists
with no value stated at `ordered_by` has no place in the order, and two
records with equal values have no order between them. Neither stops a
correct answer from passing. Each makes the order say less than its author
meant. [Chapter 6](ch06-slot-usage-and-facets.md) adds the one requirement a
rule can check.

## The island check

Every class in the generated graph is reachable:
`CompetencyQuestionAnswer` reaches `DomainRecord` through the anchor and
citation slots and `ExpectedValue` through `expected_values`, which reaches
`DomainRecord` in turn through `record`. `Benchmark` reaches
`CompetencyQuestionAnswer` through the questions it holds and
`TargetDataset` through `target_datasets`. No class sits alone, so there is
nothing here to explain or remove.
