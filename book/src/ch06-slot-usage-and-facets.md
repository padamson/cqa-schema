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
work went to what [Chapter 5](ch05-slots.md) deferred here: every citation
must also be an anchor. That turned out not to be a facet at all.

{{#diff cqa-yaml-v4 cqa-yaml-v5 context=20 caption="Step 6: facets"}}

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
{{#callout subset}}, and the schema now states the relation instead of
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

## One `id` slot, two patterns

All three classes take the same `id` slot. Their identifiers do not have the
same shape.

`Benchmark` and `CompetencyQuestionAnswer` hold identifiers cqa mints into
IRIs — Chapter 5 showed `alpha/cq-01` and `beta/cq-01` resolving apart
beneath the benchmarks holding them. An identifier with a space or a slash
in it either breaks that or silently changes what it means, so both classes
narrow `id` to lower-case words joined by hyphens {{#callout minted}}.

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
and making `expected_citations` a subslot did not quietly change it. A
subslot inherits its parent's unset fields, such as `range` and `pattern`,
but not whether the parent is required.

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

Chapter 5 gave `Benchmark` four slots to say what it is asked against: the
schema, the schema's version, the dataset, and the dataset's version. It also
recorded why four is more than it should take. A dataset with an IRI of its
own would declare its schema and version itself, and a benchmark could name
it once.

Wine's datasets have no such IRI. Its `WineCatalog` root deliberately carries
no identifier, so that the graphs it holds can merge instead of being scoped
apart, and a benchmark has to spell out all four facts for itself.

Step 6 cannot settle this. No facet collapses four slots into one — a facet
narrows what a single slot accepts, and this is a question about how a
dataset is published. It stays open until a target arrives that publishes
itself differently.
