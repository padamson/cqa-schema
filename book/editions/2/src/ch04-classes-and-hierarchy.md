# Classes and Hierarchy

This chapter applies **Step 4** of *Ontology Development 101* (Noy &
McGuinness, 2001) to cqa.

```admonish quote title="Noy & McGuinness 2001 — §Step 4"
There are several possible approaches in developing a class hierarchy
(Uschold and Gruninger 1996): A *top-down* development process starts
with the definition of the most general concepts in the domain and
subsequent specialization of the concepts. A *bottom-up* development
process starts with the definition of the most specific classes, the
leaves of the hierarchy, with subsequent grouping of these classes into
more general concepts. A *combination* development process [...] defines
the more salient concepts first and then generalizes and specializes
them appropriately.
```

Step 3 listed eleven terms. Three of them become classes here. A fourth
comes from finding that one term, *target schema*, names more than one thing,
and a fifth from finding that another, *ground truth*, cannot be checked as
written. The rest describe a competency question answer rather than standing on their
own, and they become slots in Step 5.

## The five classes

<!-- LISTING cqa-yaml-v3: diff from cqa-yaml-v2, context 4, caption "Step 4: the classes". Placeholder until the forward freeze. -->

**`CompetencyQuestionAnswer`** <!-- callout item --> is the central class, and its
name is a decision rather than a description. It names the data you evaluate
*against*, so a scored attempt at answering stays a separate thing that an
evaluation run produces. A name like `CompetencyQuestionEval` would have
claimed the opposite, and [Chapter 1](ch01-domain-and-scope.md) put the
scored attempt out of scope precisely so one benchmark can outlive many
attempts at it.

**`Benchmark`** <!-- callout set --> is the set of them, and it exists as a class
because CQ-cqa 7 asked for one.

**`DomainRecord`** <!-- callout placeholder --> stands for a record in the graph
being evaluated. Nothing here ever instantiates it.

**`TargetDataset`** <!-- callout dataset --> is one of the instance graphs a
benchmark is asked against. Why it is a class, and why it has no identifier,
is under "The target, and the datasets in it" below.

**`ExpectedValue`** <!-- callout claim --> is one value a correct answer
states: a record of the target graph, one of its slots, and the value the
record carries there. It is derived under "The answer, in a form a tool can
check" below.

## Why the benchmark is a class

CQ-cqa 7 asks what identifies a benchmark and what distinguishes one
benchmark's questions from another's. A container that merely holds records
answers neither.

The concrete failure is identifier collision. Wine's benchmark will hold a
question called `cq-01`, and so will the next domain's, and they are
different questions. If a benchmark is a bare container, both mint the same
identifier and the two records merge into one the moment anything loads
both. Making the benchmark a named thing gives each question somewhere to
belong, so one benchmark's `cq-01` and another's stay apart.

That is a class-level decision, which is why it lands here. The mechanism
that carries it — which slot bears the identifier, and what that does to the
identifiers beneath it — is a slot question, and we will deal with it
in Step 5.

## The one class we cannot ground

`CompetencyQuestionAnswer` and `Benchmark` both ground in `cco:ont00000958`,
Information Content Entity, as [Chapter
2](ch02-reusing-existing-ontologies.md)'s reuse table committed them to,
with the EARL correspondences recorded as `skos:closeMatch`. Both fit: a
question with its answer is content, and a set of them is content too.
`TargetDataset` grounds in the same node. A dataset is a body of records,
which is content as well, and EARL has no term for it to correspond to.
`ExpectedValue` grounds there too, since a statement that a record carries a
value is content about that record.

`DomainRecord` has no `subclass_of` at all, and that absence is the honest
answer rather than an omission. The reason is what `subclass_of` does once
the anchors are in place.

`subclass_of` emits `rdfs:subClassOf`, which every instance of the class
inherits. The anchor and citation slots will be ranged on `DomainRecord`, and
a class-ranged slot emits `rdfs:range` on an `owl:ObjectProperty`. Put those
together and a benchmark that says

```turtle
cqa:cq-02  cqa:expected_anchors  wine:bordeaux-wine .
```

entails that `wine:bordeaux-wine` is a `DomainRecord`, and so an instance of
whatever `DomainRecord` is a subclass of.

That record already has a type, given to it by the schema it conforms to.
Grounding `DomainRecord` would assign it a second one, asserted by a schema
that has never seen the record and does not import the schema defining it.
For some consumer the two types would be incompatible, and the benchmark
would be making a claim about their data that they never agreed to.

The only grounding safe for every consumer is one general enough to assert
nothing. So the class stays ungrounded: the graph is named, not modeled.

```admonish warning title="A class that exists for the tooling"
`DomainRecord` is not a domain concept. It is in the model because the
anchors need a class to be ranged on, and it is named here so Step 5 does not
introduce an uninstantiated, ungrounded class without explanation.
```

## Not every competency question fits a benchmark

In Chapter 1 we found that CQ-wine 1 ("which wine characteristics should I
consider when choosing a wine?") gets no row in the table, because wine's
*schema* answers it and no record in wine's graph does. Wine's own chapter 7
says as much when it answers the question: "the `Wine` class carries
`color`, `body`, `flavor`, and `sugar`" — the class, before any instance.
Chapter 1 left the choice to this step: either the classes grow a way to
name a schema element, or such questions are out of scope.

**They are out of scope, and the framework should say so rather than
half-cover them.**

An anchor names a record a correct answer must retrieve. A class definition
is not a record; it is part of the contract the records conform to. A system
could answer CQ-wine 1 perfectly by reading `wine.yaml` and never touching
the graph, so a retrieval check has nothing to check. Adding schema-element
anchors would let such a question be written down, and the deterministic
check still could not evaluate it — the appearance of coverage without the
substance.

Answer kinds make the same point from the other side. Every kind Step 3
listed describes an operation over records: read one, compare several, find
none connecting two. None describes reading a schema. A question answered by
the T-box is a different kind of evaluation, and mixing it in would blur what
`answer_kind` means.

So a benchmark covers the competency questions a graph answers, and not the
ones its schema answers.

## The target, and the datasets in it

CQ-cqa 6 asks which graph a benchmark is asked against, and Step 3 turned
that into a single term, *target schema*. Checking whether it needed a class
of its own showed that the term was too small, in three ways.

**A schema is not a version.** Wine's identifiers are not fixed. A later wine
release scopes its judgment records — the pairing recommendations and vintage
assessments — beneath their catalog, which changes their IRIs. Those are
exactly the records that carry rationale, source, and confidence, so they are
exactly the records a question with an `attribution` answer must cite. Three
of wine's seven have to cite them. Their citations are correct against one
version of wine and wrong against the next, and naming only the schema
records nothing about which.

**A version is not a dataset.** Wine publishes two curated graphs against one
schema: a four-record teaching preview and a thirty-seven-record worked
example, the preview a strict subset of the other. `wine:bordeaux-wine` is in
the worked example and not in the preview. A benchmark anchoring to it
resolves against one and fails against the other, with the schema and the
version identical in both cases.

**A target is not always one dataset.** Wine's records are of two kinds.
Grapes, regions, wineries, wines, and foods are reference facts. Pairing
recommendations and vintage assessments are judgments about them, each with
a source, a confidence, and a rationale, and judgments are corrected on a
schedule of their own: a verdict is revised, or a second critic's assessments
of the same vintages are added. Wine publishes both kinds in one dataset, so
correcting one verdict moves the version of the whole graph. Published as a
dataset of their own over the reference records, the judgments could move
without the reference records moving with them. Two of the graphs cqa
already benchmarks are published that way, a shared catalog of reference
records in one dataset and each owner's records over it in another. A
question that cites a judgment and anchors the record it judges then has
anchors in both datasets, and each dataset has its own version.

The first two failures can be shown against wine as published, and the third
against any graph published in parts. None of them is visible to a benchmark
that records only a schema. So the question list is short one question again:

> **CQ-cqa 8.** Which graph are these anchors valid against — which schema,
> at which version, and which datasets, each at which version?

**The schema is not a class.** It has no identity apart from the benchmark
that names it: one benchmark, one schema, and nothing else in the model
refers to it on its own. Making it a class would add a join no query would
traverse. `Benchmark` needs to say which schema and which version, which is a
slot question, and Step 5 takes it.

**Each dataset is.** A benchmark can name several, and each comes with two
facts that belong together, its name and its version. Written as two lists on
`Benchmark`, which version goes with which dataset would rest on the order of
the lists, and nothing checks an order. So a target dataset is a record of
its own, holding both. It still has no identity apart from the benchmark that
names it, so it carries no identifier and is written inside the benchmark,
as a blank node rather than a record with an IRI of its own.

## The answer, in a form a tool can check

CQ-cqa 1 asks what the correct answer is, and Step 3 gave it one term,
*ground truth*: the answer in prose. Prose is the form Chapter 1 chose for
judging a generated answer, and the only form a reader needs. It is also a
form nothing can compare with the graph. CQ-wine 7's ground truth says the
regional vintage chart rates 2018 good, and if the chart's verdict in wine's
graph changes, the prose goes on saying good.
[Chapter 5](ch05-slots.md) shows that a corrected record can pass every
other check, and the dataset versions do not catch it either.

Most of wine's answers rest on a value one record carries at one slot.
CQ-wine 2's whole answer is one enumerated value, `color: red` on
`bordeaux-wine`. CQ-wine 6 is `body: medium` on the 2017 Napa Zinfandel
against `body: full` on the 2018. CQ-wine 7 is the two verdicts. A value at
a slot is a fact the graph either carries or does not, so a benchmark that
states it can be checked against the graph, as an anchor is.

Each such fact has three parts that belong together: the record, the slot,
and the value. The previous section made a target dataset a record of its
own for the same reason, since parallel lists would pair their entries by
order. So an expected value is a record too. It has no identity apart from
the question that states it, so like `TargetDataset` it carries no
identifier and is written inside the question as a blank node.

There is one class, not one per answer kind. A lookup states one value, a
comparison two or more, and an attribution a value alongside the citation it
rests on. Classes for each would differ only in how many values they hold,
which a list already says, and `answer_kind` already says which check
applies.

## The hierarchy, such as it is

There is no `is_a` hierarchy among the five. They are siblings: four grounded
at the same CCO node, one grounded nowhere. N&M describe top-down, bottom-up,
and combination approaches to building a hierarchy, and cqa has too few
classes for the question to arise.

A flat model is the right outcome here rather than a stage to grow out of.
The domain has one thing (a question with its answer), one collection of that
thing, one placeholder for something it does not own, one record of where
the collection is asked, and one statement of a value an answer reads.
Specialization
would come from answer kinds if they became classes, and Step 5 keeps them as
values of a slot instead, since a subclass per kind would multiply classes
without adding anything a query could use.

One check comes up nearly empty at this step, honestly so: the class graph.
With no slots, nothing connects the five classes, so the island test — a
disconnected node is a bug to explain or remove — has nothing to catch until
Chapter 5. There the anchor and citation slots wire `CompetencyQuestionAnswer`
to `DomainRecord` and to the values it states, and `Benchmark` to its
questions and its target datasets. The classes are in place; Chapter 5
connects them.
