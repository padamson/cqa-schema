# Instances and Validation

This chapter applies **Step 7** of *Ontology Development 101* (Noy &
McGuinness, 2001) to cqa.

```admonish quote title="Noy & McGuinness 2001 — §Step 7"
The last step is creating individual instances of classes in the
hierarchy. Defining an individual instance of a class requires (1)
choosing a class, (2) creating an individual instance of that class, and
(3) filling in the slot values.
```

Step 7 instantiates the schema and validates the result. One of the worked
example's questions could not be encoded without a schema change, and that
change is the substance of this chapter.

## The test case: wine

cqa's instance data is always a consumer's. A benchmark record carries IRIs
into the graph it evaluates, and cqa declares no such graph.
[Chapter 4](ch04-classes-and-hierarchy.md) left `DomainRecord` ungrounded for
that reason.

The test case is wine: the worked example that the
[ontology-authoring-template](https://github.com/padamson/ontology-authoring-template)
repository builds by the same method this book follows, and cqa's demand
driver since Step 1. That repository is the template this one was created
from, and wine was built there before cqa existed, for its own purposes. Its
benchmark is authored there too, beside the catalog its anchors resolve into,
and frozen here as [Appendix A](appendix-a-worked-example.md) at
[commit `9f898b2`](https://github.com/padamson/ontology-authoring-template/commit/9f898b2cde87bf760602a8499661fc8208d13d75).

## What the encoding found

{{#diff cqa-yaml-v5 cqa-yaml-v6 context=16 caption="Step 7: what encoding demanded"}}

Six of wine's seven questions are encoded here. Five went in without
touching the schema; CQ-wine 3 did not.

In [Chapter 1](ch01-domain-and-scope.md) we argued that a correct answer of
"nothing on record" still has to retrieve something (the records whose
missing connection is the answer), and [Chapter 5](ch05-slots.md) gave those
records a slot. Encoding the question showed the argument was right and
incomplete. The record named `cabernet-sauvignon` and `seafood-dish`, and
`answer_kind` said the answer was a closed-world negative, and between them
they still did not say *what* was missing. The claim that makes the ground
truth true (that no pairing recommendation joins those two) was nowhere in
the record. It was a hand-written Python check in wine's repository, with
wine's class names hard-coded into it, so it worked for wine and no other
graph.

A benchmark that cannot state its own claim cannot have it checked
generically. Every adopter with a negative question would write that check
again, in their own terms, against their own graph.

So the negative gained a way to say what it claims {{#callout absence}}.
`unconnected_anchors` names the anchors no single record joins, and
`connecting_class` optionally narrows the claim to one kind of joining
record: "no `PairingRecommendation` joins these" instead of "no record of
any kind does."

`unconnected_anchors` specializes `expected_anchors`, the same relation
Chapter 6 gave `expected_citations`. A claim about a record retrieval was
never required to reach cannot be checked against what was retrieved, so the
absence must be drawn from the anchors. The subslot makes that structural.

Stating the absence is not enough on its own, because a benchmark can
declare a negative and then omit it, which is the state this section started
in. So a question whose `answer_kind` includes `closed-world-negative` must
carry `unconnected_anchors`, enforced by a rule {{#callout rule}}. That is
the rung Chapter 6 named and had no use for at the time.

```admonish warning title="A slot that arrived at Step 7"
`unconnected_anchors` was added at Step 7. It should have been added
earlier.

The method says the worked example drives the schema from Step 1: a class or
slot exists because a competency question needs it. A slot that first appears
while the data is being written is a warning sign, because it can mean the
schema was shaped to fit the data instead of the questions.

Here the cause was narrower. Chapter 1 identified the negative case and chose
its anchors correctly. What nobody noticed, until a negative was actually
encoded, was that the record still never said which connection it claimed was
absent.
```

## Three more promises the enum was making

Writing that rule showed the same defect three more times, in the place it
was least visible: the `AnswerKindEnum` definitions.

Each permissible value describes what its kind of answer involves, and three
of those descriptions are requirements. `attribution` is "an answer that must
carry the source it rests on." `comparison` is "two or more records set
against each other on a shared slot." `synthesis` is "a pattern across
several records that no single record states." An attribution with no
citation, or a comparison anchoring one record, contradicts the definition of
the kind it claims to be, and until now nothing said so.

These are the same shape as the citation rule Chapter 6 chased and the
absence rule above: a requirement asserted in prose that a reader could
believe was enforced. Three rules now hold each kind to the promise its own
definition makes.

`lookup` is deliberately left alone. Its description, "a value read from a
single record," reads like a maximum of one anchor, but a lookup may have to
traverse records to reach the one it reads, and anchoring those is honest
retrieval rather than padding. The enum describes where the answer is found,
not how few records a correct retrieval touches.

## Validation happens in two places, and cannot happen in one

`panschema validate` reports that the benchmark conforms: every required slot
present, every `answer_kind` a permissible value, every id matching the
pattern [Chapter 6](ch06-slot-usage-and-facets.md) set, every citation and
every stated absence drawn from the anchors, every answer kind holding to the
promise its own definition makes, and every value carrying the type its slot
declares.

One of those checks rests on a convention that can look like an omission.
Eight of this schema's ten datatype slots declare no `range:` at all, taking
their type from `default_range` instead, so a reader might reasonably wonder
whether an untyped slot is an unchecked one. It is checked: `question: 42`
is rejected as "an integer, but the slot's range `string` expects a string."
The type is stated once and enforced everywhere it applies.

What it cannot report is whether the anchors exist. Every one of them is an
absolute IRI into a graph that is not here, and a cross-graph reference is
exempt from the dangling-reference check by design; without that exemption
every benchmark would be one long list of errors. Conformance and resolution
are different questions, and only the first can be answered in this
repository.

The second is answered where both graphs sit together. In wine's repository
the benchmark and the catalog are siblings in one manifest, so the same
toolchain resolves each anchor against the records wine actually mints, and
checks each stated absence by looking for a record that joins the anchors it
claims are unjoined. A false claim fails there. Both checks are three lines
of manifest configuration, and the hand-written script they replaced has been
deleted.

The division follows from what a benchmark is: a set of claims about
someone else's graph, well-formed here and true only there.

## The litmus

Chapter 1 stated its cross-check plainly as a by-eye reading of wine's
prose, and promised this step would make the same claims testable. Run
against the frozen benchmark, all eight questions are answered by a slot
carrying a value:

| | answered by | in the encoded benchmark |
|---|---|---|
| CQ-cqa 1 | `question`, `ground_truth` | all six carry both |
| CQ-cqa 2 | `expected_anchors` | all six carry them, one to six records each |
| CQ-cqa 3 | `unconnected_anchors`, `connecting_class` | `cq-03`, the one negative |
| CQ-cqa 4 | `expected_citations` | three of the six: `cq-04`, `cq-05`, `cq-07` |
| CQ-cqa 5 | `answer_kind` | all five kinds used |
| CQ-cqa 6 | `target_dataset` | `worked-example` |
| CQ-cqa 7 | benchmark `id`, question `id` | `wine-benchmark`, six questions |
| CQ-cqa 8 | `target_schema`, `target_schema_version`, `target_dataset`, `target_dataset_version` | all four present |

**All five answer kinds are exercised by six questions**, which is the
closest thing to evidence that the enum is neither too coarse nor padded.
`cq-07` carries two of them, which is why Chapter 5 made `answer_kind`
multivalued.

**CQ-cqa 3 is the row Chapter 1 could not have written.** It asked how a
benchmark says the correct answer is "the graph records no such thing," and
at the time the answer was the anchors plus a label. The answer now includes
the claim itself. A litmus that only confirmed the original design would not
have been worth running.

One question is absent from the benchmark rather than failing in it. CQ-wine
1 asks which characteristics to consider when choosing a wine, which wine's
schema answers before any instance exists. [Chapter
4](ch04-classes-and-hierarchy.md) ruled that questions a schema answers are
out of scope for a retrieval benchmark, and the encoding is where that
ruling either holds or shows itself to be an evasion. It holds: there is no
record to anchor, and inventing one would produce a question that scores a
retrieval that no correct answer performs.

## The four target slots, checked against a real target

Chapter 5 gave `Benchmark` four slots to say what it is asked against:
`target_schema` and `target_schema_version` name the vocabulary the records
conform to and the release of it, `target_dataset` and
`target_dataset_version` name which body of records the anchors resolve in
and which state of it. Chapter 5 also recorded that a dataset carrying its
own IRI would need only one of the four, and Chapter 6 could not settle that,
because no facet collapses four slots into one.

Encoding wine's benchmark answers that question for now, in the negative.
`WineCatalog` is a `tree_root` holding collections, and it carries no
identifier, so neither of wine's two graphs has an IRI a benchmark could
point at. All four facts have to be written into the benchmark itself.

Chapter 5 accepted that cost deliberately. When a benchmark ships beside the
schema it targets, two of the four slots repeat what the package already
records. The return is that a reader can tell what a benchmark targets
without also knowing where the file came from.

## What the schema is for

A benchmark holds IRIs, not the records they name. Load it alongside the
graph it evaluates and those references resolve, so the question, its
expected answer, and the records the answer rests on all sit in one graph,
addressable in the same vocabulary as the data being evaluated. While a set 
of competency questions in a design document cannot be run, this one can be.

## What running it changed

Everything above was written before anyone had used cqa. Adopting it for wine,
which meant wiring the checks in that repository against that graph, found
three places where the contract was underspecified, and the schema changed
before its first release.

{{#diff cqa-yaml-v6 cqa-yaml-v7 context=22 caption="What adoption demanded"}}

**The absence claim moved onto the slot.** Wine's manifest had been telling
the toolchain which slot carried absence claims and which slot narrowed them.
That is a fact about what `unconnected_anchors` *means*, and it was living in
one consumer's configuration, where the next adopter would restate it and
could restate it more weakly. Omitting the narrowing slot silently widens the
check from "no `PairingRecommendation` joins these" to "no record of any
kind". The slot now says it itself.

**`required` moved from the slot to the class.** `expected_anchors` was
required, and `expected_citations` specializes it. Under LinkML, a
specialization inherits its parent's `required`, so the citation slot was
optional only by accident of how the toolchain resolved it, and a
closed-world negative cites nothing. Declaring the requirement on
`CompetencyQuestionAnswer` instead {{#callout obliged}} removes the inherited
value rather than cancelling it, so a slot added to that family later is
optional by default.
It is also the truer statement: a competency question answer must name
anchors, which is a fact about the question, not about the slot wherever it
appears.

**`target_dataset` says where its value comes from.** Wine's benchmark says
`target_dataset: worked-example`. The slot already described what it was for,
which instance graph the anchors resolve in, but not what kind of name that is
or who assigns it. It now says: a dataset name as the target package publishes
it, from that package's publish manifest. That is a refinement to a
description, not a check. Whether the tooling resolves anchors against the
dataset a benchmark names, rather than against every dataset the target
publishes, is a separate question and still open.

## What the checks cannot see

The checks confirm the benchmark is well formed and that its claims still
hold against the graph. They do not confirm the answers are right.

Chapter 5 predicted how that fails: correct a vintage assessment's verdict,
and every anchor still resolves, every citation still resolves, validation
passes, and the ground truth is false. We tried it. One line of
`data/wine-instances.yaml`, in the repository that holds both graphs:

```diff
   - id: va-napa-zin-2018
     wine: napa-zinfandel-2018
-    verdict: good
+    verdict: average
```

`cq-07` cites that assessment, and its ground truth says the chart rates 2018
good. The chart now rates it average. The checks report:

```console
$ panschema validate --strict
note: schema `cqa`: 28 of 28 cross-graph reference(s) into `wine` namespace(s) resolve
note: schema `cqa`: 1 of 1 stated absence claim(s) hold against `wine`
```

Exit code zero. Every anchor resolves, the absence claim holds, and the
benchmark states something the graph contradicts.

The version slots do not help here. `target_dataset_version` records which
release of the data a benchmark was written against, and this correction did
not change the release; it changed a record inside one. A benchmark can be
conformant, resolve every anchor, and still be wrong about what the graph
says.

One prediction did not hold. Wine's benchmark anchors twelve judgment-side
records, and scoping their classes to their container was expected to move
those records and break three of the six questions. It leaves the generated
graph byte-identical, because a scoped record mints beneath its container's
IRI and wine's catalog carries no identifier. Giving the catalog one would
collapse the four target slots into one, which Chapter 6 wanted, and move half
the benchmark's anchors at the same time.

## What is left

No system has been evaluated against this benchmark. Everything here checks
the benchmark itself: that it is well formed, that its anchors exist, that
what it claims is absent is absent. None of it scores an answer, which is what
a benchmark is for. That needs a retrieval system to run against, and cqa does
not have one yet.
