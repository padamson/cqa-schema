# Important Terms

This chapter applies **Step 3** of *Ontology Development 101* (Noy &
McGuinness, 2001) to cqa.

```admonish quote title="Noy & McGuinness 2001 — §Step 3"
It is useful to write down a list of all terms we would like either to
make statements about or to explain to a user. What are the terms we
would like to talk about? What properties do those terms have? What
would we like to say about those terms? [...] Initially, it is
important to get a comprehensive list of terms without worrying about
overlap between concepts they represent, relations among the terms, or
any properties that the concepts may have, or whether the concepts are
classes or slots.
```

Anything can propose a term: the domain statement, the worked example,
ordinary usage. A term reaches the list below only when some competency
question needs it, so proposing is free and the questions decide. A term that
plainly belongs and has no question behind it means the question list was
incomplete, and we found one while writing this chapter.

Nothing below is sorted into classes or slots. That is Steps 4 and 5.

## Terms the competency questions need

| Term | Needed by |
|---|---|
| question | CQ-cqa 1 |
| ground truth (the correct answer, in prose) | CQ-cqa 1 |
| record | CQ-cqa 2, 4 |
| retrieve | CQ-cqa 2 |
| expected anchor (a record a correct answer must retrieve) | CQ-cqa 2 |
| cite | CQ-cqa 4 |
| expected citation (a record a correct answer must rest on) | CQ-cqa 4 |
| answer kind | CQ-cqa 5 |
| lookup, closed-world negative, comparison, synthesis, attribution | CQ-cqa 5 |
| graph | CQ-cqa 2, 6 |
| target schema | CQ-cqa 6 |

Three of these need saying more precisely than the questions said them.

**Anchor and citation are different things, and CQ-cqa 4 exists to say so.**
An anchor is a record a correct answer has to reach; a citation is a record
the answer rests on. Every citation is an anchor, and most anchors are not
citations: [CQ-wine 4](https://padamson.github.io/ontology-authoring-template/ch01-domain-and-scope.html#competency-questions)
("what is the best choice of wine for grilled meat?") reaches the wine, the
food, and the recommendation, but only the recommendation carries the
rationale and the source, so only it gets cited. Two terms rather than one,
because collapsing them would lose the distinction between what a system had
to find and what it had to use.

**"Ground truth" is the prose answer, not the anchors.** Both describe what a
correct answer contains, and the retrieval check never reads the prose. Keeping
the names apart keeps the two levels of evaluation apart.

**The answer kinds are terms, not just values.** Each names a different check.
`lookup` reads a value off one record; `closed-world negative` asserts that no
record connects two others; `comparison` sets records against each other;
`synthesis` reads a pattern across several; `attribution` requires the answer
to carry a source. An evaluator switches on the kind to decide what passing
means, so the five are part of the vocabulary rather than an enum of
convenience.

## What the worked example proposes

CQ-wine proposes two terms that the questions above do not.

**Source** appears throughout CQ-wine 4 and CQ-wine 7 ("what were good
vintages for Napa Zinfandel?") — the sommelier, the vintage chart, the
confidence attached to each. It does not become a cqa term. The
source is a property of the wine record being cited, and it lives in wine's
schema. cqa needs only to say *which record must be cited*; whatever
attribution that record carries is the domain's business. This is the ch01
scoping decision doing its work: the graph is named, not modeled.

**Rationale** proposes itself the same way through CQ-wine 4 and CQ-wine 5
("which characteristics of a wine affect its appropriateness for a dish?"),
and is declined for the same reason.

## A term with no question behind it

**Benchmark** is the term for a set of these records taken together — the
thing a consumer authors, names, and hands to an evaluation tool. It is in
ch01's domain statement, in the ch02 reuse table as `earl:TestRequirement`, and
it is the word this book has used since the Introduction.

No competency question asks anything about it. CQ-cqa 1 through 5 are all
about a single record. CQ-cqa 6 mentions a benchmark only to ask which graph
it targets. Nothing asks what a benchmark is called, how one is told from
another, or what holds them together.

That gap is not cosmetic. Two domains will both write `cq-01`, and those are
different questions that must not merge into one record when their benchmarks
are loaded together. Keeping them apart requires the benchmark to be a named
thing in its own right rather than a bare container, which is a modeling
requirement that no question in ch01 asks for.

So the question list was incomplete. Adding it:

> **CQ-cqa 7.** What identifies a benchmark, and what distinguishes one
> benchmark's questions from another's?

This is Step 1 work arriving at Step 3, which N&M anticipate — they call the
competency questions a sketch, and the term brainstorm is what catches where
the sketch was thin. ch01 stays as written, because the book is a log rather
than a summary. The question is recorded here, where we found it, and Step 7
tests all seven.

## Terms we explain but do not model

N&M's list includes terms to *explain to a user* as well as terms to make
statements about. Three sit in that first group and nowhere in the schema.

**Evaluator** is whatever runs a benchmark. CQ-cqa 5 mentions one, and ch01
put it out of scope: cqa says what a correct answer must contain, not what
software checks it.

**Retrieval** is how a system reaches the anchors. cqa specifies which records
must be reached, never how, so that a benchmark stays neutral about the
implementation being tested.

**Evaluation result** is a system's scored attempt. ch01 excluded it, and in
ch02 we found that EARL agrees, modeling `earl:Assertion` separately from its
test criteria.

## What Step 3 produced

No schema change. The terms become classes and slots in Steps 4 and 5, and
until then a list in prose is the whole deliverable.

What did change is the question list, which is one longer than it was in
ch01. In Step 4, we build classes for these terms, and the first thing we have
to decide is which of them are classes at all.
