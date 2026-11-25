# Slot Usage and Facets

This chapter applies **Step 6** of *Ontology Development 101* (Noy &
McGuinness, 2001) to cqa.

```admonish quote title="Noy & McGuinness 2001 — §Step 6"
Slots can have different facets describing the value type, allowed values,
the number of the values (cardinality), and other features of the values
the slot can take.
```

In this process, we focus on narrowing what existing slots accept, never
widening them or adding new slots. Few slots needed narrowing. Most of the
work went to four things [Chapter 5](ch05-slots.md) left here: every
citation must also be an anchor, so must every record an expected value is
read from, an ordered answer must state values to order, and no question
may have more anchors than the benchmark's budget. None of them turned out
to be a facet.

<!-- LISTING cqa-yaml-v5: diff from cqa-yaml-v4, context 20, caption "Step 6: facets". Placeholder until the forward freeze. -->

## Every citation is an anchor

Chapter 5 put "always among the anchors" in the description of
`expected_citations` and left enforcing it to this step. A description
enforces nothing, so a benchmark can cite a record it never listed as an
anchor. That benchmark validates, and it is incoherent: it asks an evaluator
to score an answer against a record that retrieval was never required to
reach.

Enforcing the rule means choosing the right kind of constraint, and LinkML
offers three.

```admonish note title="Jargon: facets, rules, invariants"
A **facet** restricts one slot on one node — a pattern, a bound, a
cardinality. This is Step 6's vocabulary.

A **rule** spans several slots on one node: LinkML's class-level `rules`,
with preconditions and postconditions.

An **invariant** spans several nodes — uniqueness across records, say — and
belongs to validation.
```

By that reading the constraint is a rule: two slots, one record. So we went
looking for the rule that expresses it, and did not find one.

A rule's conditions compare a slot to a *literal* — a string, a number, a
bound, whether a value is present at all. None of them compares a slot to
another slot, so "the values here are among the values there" has nothing to
be written with. LinkML's one expression-valued condition,
[`equals_expression`](https://linkml.io/linkml-model/latest/docs/equals_expression/),
does not reach it either: it derives a single value from an arithmetic
expression over other slots, in the manner of a `length` computed as
`(end-start)+1`. That is equality on one value, not containment between two
lists.

SHACL was the obvious fallback, and it fails the same way. The property pair
constraints in [SHACL](https://www.w3.org/TR/shacl/) §4.5 are `sh:equals`,
`sh:disjoint`, `sh:lessThan` and `sh:lessThanOrEquals`. There is no subset.
Two vocabularies designed for constraints, and neither expresses this one.

That is usually a sign the constraint is unusual. Here it was a sign we were
asking the wrong question.

## It was never a constraint

"Every citation is also an anchor" does not restrict the data. It says what
the two slots *mean*: a citation is a kind of anchor — the kind an answer
rests on rather than merely reaches. That is a fact about the vocabulary,
and it belongs in the model rather than in a check bolted alongside it.

RDF has said this since RDFS.

```admonish note title="Jargon: subproperty and entailment"
**`is_a` on a slot** makes one slot a specialization of another, emitted as
`rdfs:subPropertyOf`. Every pair the child slot relates, the parent relates
too. It is the slot-level counterpart of the class hierarchy from [Chapter
4](ch04-classes-and-hierarchy.md).

**Entailment** is what follows from a statement without being written down.
Given that subproperty, data listing a record as a citation entails that the
record is also an anchor, whether or not anyone wrote the second fact. A
reasoner reads the entailment and adds the missing triple.
```

So `expected_citations` becomes a subslot of `expected_anchors`
<!-- callout subset -->, and the schema now states the relation instead of
describing it:

```turtle
cqa:expected_citations rdfs:subPropertyOf cqa:expected_anchors.
```

The sentence Chapter 5 wrote in a description is now a triple.

Two things follow, and they are not the same thing. Read as RDF, a citation
outside the anchors entails that it is an anchor, and a reasoner adds it.
Read as YAML, no reasoner runs, so `validate` checks the containment directly
and reports the citation that sits outside its parent. Entailment adds;
validation rejects. Both are defensible readings of one relation, and which
one a consumer gets depends on how it reads the benchmark — worth knowing
before trusting either.

## Every value is read from an anchor

The record an expected value names must be among the question's anchors. A
value a correct answer depends on comes from a record the answer has to
retrieve, and a value read from a record retrieval was never required to
reach is a fact no correct retrieval would have found.

The citation rule became a subslot, and this one cannot. `record` sits on
the `ExpectedValue`, one record down from the question that holds the
anchors, so the two slots are on different nodes and `is_a` between them
would relate nothing. By the jargon above this is an invariant: it spans two
nodes. LinkML's rules cannot state it either, since a rule's conditions read
the slots of the record it is declared on and not those of the record
containing it.

It is still a fact about what the slot means, so the slot declares it, as
`unconnected_anchors` declares its absence claim in [Chapter
7](ch07-instances-and-validation.md). `expected_values` carries an
annotation <!-- callout values --> naming which of an entry's slots holds the
record, which the slot, and which the value, and its `among` names the slot
on the containing question the record must be found in. A citation counts,
because `expected_citations` specializes `expected_anchors`. The annotation is
read where the benchmark and the target graph sit together, by the same
check that compares each value with the graph, and Chapter 7 shows what that
check reports.

## An order needs values to order

A question that names `ordered_by` and states fewer than two expected
values claims an order with nothing in it, since one value is in order
however it is given. That constraint relates two slots on one record,
`ordered_by` and `expected_values`, which makes it a rule. A rule
<!-- callout order --> requires two or more expected values whenever
`ordered_by` is present, the same shape as the one that holds a comparison
to two anchors.

The rule counts entries, not the entries at the ordering slot. Which slot an
entry names is a value one record down, in the `ExpectedValue`, so the
constraint the order really needs spans nodes, and a rule cannot state it. A
question with two values at other slots and `ordered_by` naming a third
passes, and so does one whose two values sit on the same record. We left
that open: like the limits in Chapter 5, it makes an order say less and
never fails a correct answer.

## A budget no question exceeds

The two slots we put on `Benchmark` in Chapter 5 take ordinary facets. The budget
is a whole number of at least one (`range: integer`, `minimum_value: 1`),
since a budget of zero admits no answer. The floor is a share, a `float`
between `0` and `1`. Each narrows what one slot accepts, so here the facet is
the whole of it.

The budget also has to fit the questions. A correct answer reaches every
anchor, so a question with more anchors than the budget cannot be answered
within it, and the benchmark contradicts itself. Nothing would say so until
a grader failed a correct system on that question, and the fault would look
like the system's.

That constraint relates the budget on the benchmark to a count on each
question it holds, so it spans two nodes, like the one on expected values
above, and neither a facet nor a rule can state it. The slot declares it
instead. `retrieval_budget` carries an annotation
<!-- callout bound --> naming the slot whose values it bounds,
`expected_anchors`, and a check counts the distinct values at that slot on
every question beneath the benchmark. Citations and stated absences count
with them, since both specialize `expected_anchors`, and a record listed
twice counts once. A question that exceeds the budget fails, and the finding
names the question, its count, and the budget.

The check finds a budget no answer can meet, not one that is enough. The
anchors are the least a correct answer must retrieve, and an answer can
read records that are not anchors on its way to them, so a benchmark can
pass this check with a budget that fails correct answers.

Unlike the value claims, this check needs no target graph: a count of
anchors is in the benchmark file. So the per-file `verify` that reports
conformance reports it too, wherever the file is. The bound comes from the
nearest record that sets the budget, which today is always the benchmark. A
budget on a question, if one is ever needed, would take precedence for that
question and need only a schema change.

The floor has no such constraint. An answer that cites only anchors scores
one, whatever the question, so no question can make a floor unreachable.

## One `id` slot, two patterns

All three classes take the same `id` slot. Their identifiers do not have the
same shape.

`Benchmark` and `CompetencyQuestionAnswer` hold identifiers cqa mints into
IRIs — Chapter 5 showed `alpha/cq-01` and `beta/cq-01` resolving apart
beneath the benchmarks holding them. An identifier with a space or a slash
in it either breaks that or silently changes what it means, so both classes
narrow `id` to lower-case words joined by hyphens <!-- callout minted -->.

`DomainRecord` gets no pattern: its identifiers are absolute IRIs from the
graph being evaluated, which the pattern would reject.

## The cardinality sweep

We added no cardinality facets. Three were considered.

`answer_kind` is required and multivalued. A question with no answer kind
cannot be checked at all, so we looked at adding `minimum_cardinality: 1` to
reject an empty list. It is unnecessary: on a multivalued slot, `required`
already rejects `answer_kind: []`.

`expected_anchors` is required and `expected_citations` is not. That is
deliberate — a closed-world negative cites nothing and must still validate —
and making `expected_citations` a subslot did not quietly change it.

N&M raise a third case.

```admonish quote title="Noy & McGuinness 2001 — §Step 6, cardinality"
Sometimes it may be useful to set the maximum cardinality to 0. This setting
would indicate that the slot cannot have any values for a particular subclass.
```

That is a subclass forbidden a slot its parent allows. It does not arise
here: cqa has one class narrowing another's slot, and that narrowing tightens
a pattern rather than forbidding a value.

## Property characteristics: nothing to declare

LinkML can mark a slot `symmetric`, `asymmetric`, `reflexive`, `irreflexive`
or `transitive`, and can pair two slots with `inverse`. cqa declares none of
them, and the reason is structural rather than an oversight.

Those characteristics describe a relation between two things of the same
kind, where composing or reversing the relation is meaningful. cqa's object
slots do not do that. `expected_anchors` runs from a question to a record in
another graph; `competency_question_answers` runs from a benchmark to the
questions it holds. Neither relates two records of a kind, so there is
nothing for transitivity to compose or for an inverse to reverse.

`expected_citations` is the one slot that stands in a relation to another
slot, and that relation is specialization, which `is_a` already carries.

## What Step 6 could not settle

Chapter 5 gave `Benchmark` two slots for the schema it is asked against and a
list of target datasets, each a dataset's name and its version. It also
recorded that a name is a fallback. A dataset with an IRI of its own would
declare its schema and version itself, and a benchmark could point at it.

Wine's datasets have no such IRI. Its `WineCatalog` root deliberately carries
no identifier, so that the graphs it holds can merge instead of being scoped
apart, and a benchmark has to name each dataset and state its version for
itself.

Step 6 cannot settle this. No facet turns a name into a reference — a facet
narrows what a single slot accepts, and this is a question about how a
dataset is published. It stays open until a target arrives that publishes
its datasets with identifiers.
