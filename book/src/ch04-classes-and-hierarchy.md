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

Step 3 listed eleven terms. Three of them become classes here; the rest
describe a competency question answer rather than standing on their own, and
they become slots in Step 5.

## The three classes

{{#diff cqa-yaml-v2 cqa-yaml-v3 context=4 caption="Step 4: the classes"}}

**`CompetencyQuestionAnswer`** {{#callout item}} is the central class, and its
name is a decision rather than a description. It names the data you evaluate
*against*, so a scored attempt at answering stays a separate thing that an
evaluation run produces. A name like `CompetencyQuestionEval` would have
claimed the opposite, and ch01 put the scored attempt out of scope precisely
so one benchmark can outlive many attempts at it.

**`Benchmark`** {{#callout set}} is the set of them, and it exists as a class
because CQ-cqa 7 asked for one.

**`DomainRecord`** {{#callout placeholder}} stands for a record in the graph
being evaluated. Nothing here ever instantiates it.

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

`CompetencyQuestionAnswer` and `Benchmark` both ground in
`cco:ont00000958`, Information Content Entity, as ch02's reuse table
committed them to, with the EARL correspondences recorded as
`skos:closeMatch`. Both fit: a question with its answer is content, and a set
of them is content too.

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

In ch01 we found that CQ-wine 1 ("which wine characteristics should I
consider when choosing a wine?") gets no row in the table, because wine's
*schema* answers it and no record in wine's graph does. Wine's own chapter 7
says as much when it answers the question: "the `Wine` class carries `color`,
`body`, `flavor`, and `sugar`" — the class, before any instance. ch01 left
the choice to this step: either the classes grow a way to name a schema
element, or such questions are out of scope.

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

## A target is not a class

CQ-cqa 6 asks which graph a benchmark is asked against, and Step 3 turned
that into a single term, *target schema*. Checking whether it needed a class
of its own showed that the term was too small, in two ways that can both be
demonstrated against wine.

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

Neither failure is hypothetical, and neither is visible to a benchmark that
records only a schema. So the question list is short one question again:

> **CQ-cqa 8.** Which graph are these anchors valid against — which schema,
> at which version, and which dataset?

**The answer is not a class.** A target has no identity apart from the
benchmark that names it: one benchmark, one target, and nothing else in the
model refers to a target on its own. Making it a class would add a join no
query would traverse. What it needs is for `Benchmark` to say three things
instead of one, which is a slot question, and Step 5 takes it.

## The hierarchy, such as it is

There is no `is_a` hierarchy among the three. They are siblings: two grounded
at the same CCO node, one grounded nowhere. N&M describe top-down, bottom-up,
and combination approaches to building a hierarchy, and cqa has too few
classes for the question to arise.

A flat model is the right outcome here rather than a stage to grow out of.
The domain has one thing (a question with its answer), one collection of that
thing, and one placeholder for something it does not own. Specialization
would come from answer kinds if they became classes, and Step 5 keeps them as
values of a slot instead, since a subclass per kind would multiply classes
without adding anything a query could use.

One check comes up nearly empty at this step, honestly so: the class graph.
With no slots, nothing connects the three classes, so the island test — a
disconnected node is a bug to explain or remove — has nothing to catch until
Chapter 5, when the anchor and citation slots wire `CompetencyQuestionAnswer`
to `DomainRecord` and `Benchmark` to its questions. The classes are in place;
Chapter 5 connects them.
