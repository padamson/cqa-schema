# Domain and Scope

This chapter applies **Step 1** of *Ontology Development 101* (Noy &
McGuinness, 2001) to cqa.

```admonish quote title="Noy & McGuinness 2001 — §Step 1"
We suggest starting the development of an ontology by defining its
domain and scope. That is, answer several basic questions:

- What is the domain that the ontology will cover?
- For what we are going to use the ontology?
- For what types of questions the information in the ontology should
  provide answers?
- Who will use and maintain the ontology?

The answers to these questions may change during the ontology-design
process, but at any given time they help limit the scope of the model.
```

## The domain

The domain is the **evaluation of a knowledge graph against the questions it
was built to answer**. Not the graph, and not the act of answering: the
questions, and a specification of what a correct answer to each one is.

Concretely, one record holds a **question**, its **correct answer in prose**,
the **records in the graph** a correct answer has to retrieve, and which of
those it has to **cite**.

The graph being evaluated is out of scope. It belongs to whoever is being
evaluated, conforms to its own schema, and is referred to here only by the
IRIs of the records a benchmark points at. That split (the benchmark modeled
in detail, the graph named but not modeled) is the scoping decision the rest
of the book leans on.

## What it is for

Two kinds of consumer.

An **ontology author** writes a benchmark for their own schema. A competency
question is usually written once, in a design document, checked informally at
the end, and never run again. The vocabulary is meant to make the set
executable instead, so a machine re-checks it whenever the schema or the data
moves.

An **evaluation tool** reads the benchmark and scores a system against it.
There are two levels, and only the first has to work for the vocabulary to
earn its keep: a deterministic retrieval check (did the system reach the
records a correct answer needs?), and optionally a judgment of a generated
answer against the prose ground truth. The first needs no language model and
runs in CI, which is why we model correct answers as fields rather than
notes.

```admonish quote title="Noy & McGuinness 2001 — §Step 1, Competency questions"
One of the ways to determine the scope of the ontology is to sketch a
list of questions that a knowledge base based on the ontology should
be able to answer, **competency questions** ([Gruninger and Fox 1995](http://www.eil.utoronto.ca/wp-content/uploads/enterprise-modelling/papers/gruninger-ijcai95.pdf)).
These questions will serve as the litmus test later: Does the
ontology contain enough information to answer these types of
questions? Do the answers require a particular level of detail or
representation of a particular area? These competency questions are
just a sketch and do not need to be exhaustive.
```

## Competency questions

These are **CQ-cqa**, the questions this ontology has to answer about a
benchmark. (CQ-wine, used below, is the worked example's own set, about wine;
the Introduction sets out both labels.)

1. What is being asked, and what is the correct answer?
2. Which records must a correct answer retrieve from the graph?
3. How does a benchmark say that the correct answer is "the graph records no
   such thing"?
4. Which records must a correct answer cite, as opposed to merely reach?
5. What kind of answering does the question call for, so an evaluator knows
   which check to run?
6. Which graph is the benchmark asked against?

### Checking them against a real set

N&M call competency questions a sketch, and a sketch can still be wrong.
[Wine's seven competency
questions](https://padamson.github.io/ontology-authoring-template/ch01-domain-and-scope.html#competency-questions)
are already written and already answered in prose, so each question above can
be checked against them: does some real question demand it?

| CQ-cqa | What in CQ-wine demands it |
|---|---|
| 1 | All seven. Nothing is a benchmark without a question and an answer. |
| 2 | CQ-wine 2 reaches one record; CQ-wine 5 needs three at once. |
| 3 | CQ-wine 3, "does Cabernet Sauvignon go well with seafood?" The correct answer is that nothing on record says so. |
| 4 | CQ-wine 4 and 7 answer on someone's authority, with a confidence. An answer that drops the source is worse, not shorter. |
| 5 | The seven do not answer alike: one is a lookup, one a negative, one a comparison across vintages, one a pattern across three rationales. |
| 6 | Every anchor above is a record in wine's graph, named by an IRI this schema does not own. |

Every row has a real demand behind it, so the check passes.

```admonish warning title="This check is by eye, not by machine"
We read wine's prose answers and decided that each one needs what its row
claims. Nothing here is machine-checked, and nothing can be yet: CQ-wine is
prose at this point rather than records, and there is no schema to conform it
to. Step 7 encodes CQ-wine against the finished schema, and these same claims
become testable: an anchor either resolves or it does not, and a question
either carries the fields its answer kind needs or it fails. Until then the
table is an argument, not a test.
```

Running the check turned up two other things.

**CQ-wine 1 gets no row.** "Which wine characteristics should I consider when
choosing a wine?" is answered by wine's *schema* (the slots a `Wine`
declares), not by any record in its graph. A benchmark built out of record
references cannot express it, because there are no records to retrieve.
Either the vocabulary grows a way to point at a schema element, or questions
of that kind are out of scope and the book says so. Step 4 decides, once
there are classes to decide with.

**The negative case constrains the model more than expected.** A correct
answer of "nothing on record" still has to retrieve something: the wine and
the food whose missing connection *is* the answer. Without them an evaluator
cannot tell a correct negative from a system that retrieved nothing and
guessed. So the records a question names are not simply its evidence; for a
negative they are the ground the absence is observed against, and Step 5 has
to keep both readings.

## Who uses and maintains it

The vocabulary is maintained here and published with a version that consumers
pin. It is one shared contract rather than a per-repository convention, so
that benchmarks written in different projects can be compared.

The **benchmarks** are maintained by whoever maintains the graph each one is
asked against. This follows from the scoping decision above: a benchmark
names records by IRI, so it breaks exactly when those records move, and the
person who moved them is the one who can fix it.

Splitting the two works because the dependency runs one way. A benchmark
depends on this contract; the contract depends on no benchmark.

## What it does not model

- **A system's attempt at an answer.** An instance here is the question and
  its ideal answer, the thing you evaluate *against*. What some system
  actually produced, and what it scored, is a separate record produced by an
  evaluation run. Keeping it out lets one benchmark outlive many attempts at
  it.
- **The graph under evaluation.** In scope only as IRIs. This ontology has no
  opinion about what a `Wine` is.
- **How retrieval works.** Which records a correct answer must reach is in
  scope; how a system reaches them is not. Encoding an assumption about
  retrieval strategy would make this a test of one implementation.
- **How close a generated answer has to be.** The prose ground truth is in
  scope. The threshold at which a generated answer counts as correct is a
  policy of the tool doing the scoring, and reasonable tools disagree.

```admonish quote title="Noy & McGuinness 2001 — §3, three fundamental rules"
1. There is no one correct way to model a domain — there are always
   viable alternatives. The best solution almost always depends on
   the application that you have in mind and the extensions that you
   anticipate.
2. Ontology development is necessarily an iterative process.
3. Concepts in the ontology should be close to objects (physical or
   logical) and relationships in your domain of interest. These are
   most likely to be nouns (objects) or verbs (relationships) in
   sentences that describe your domain.
```

## On iteration

The two open questions above are the second rule showing up early. CQ-cqa was
written first and checked against CQ-wine immediately, and the check turned
up a gap (CQ-wine 1) and a subtlety (the negative case). Neither would have
come out of thinking about benchmarks alone. Both stay open here. Step
1 asks the question; Step 4 and Step 5 answer it or decline it.

The first rule applies to a specific temptation. A benchmark could also be
modeled as a set of test cases, or as a query paired with an expected result
set. Those are viable alternatives rather than mistakes, and the choice here
follows from the use: the answers are meant to be read by the people
authoring an ontology, and a query is not.

## The starting point

Step 1 produces no classes. It produces a statement of what the ontology is
about, recorded where it ships rather than only in this book:

{{#include listings/cqa-yaml-v1.yaml}}

The domain and scope live in the schema's own `description`
{{#callout domain}}; the `classes`, `slots`, and `enums` sections
{{#callout empty}} are declared and empty. The description says nothing about
the method, the grounding, or this book. Those belong to the narrative around
the artifact, not to metadata a consumer of it needs.
