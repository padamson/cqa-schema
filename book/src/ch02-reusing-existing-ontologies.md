# Reusing Existing Ontologies

This chapter applies **Step 2** of *Ontology Development 101* (Noy &
McGuinness, 2001) to cqa.

```admonish quote title="Noy & McGuinness 2001 — §Step 2"
It is almost always worth considering what someone else has done and
checking if we can refine and extend existing sources for our
particular domain and task. Reusing existing ontologies may be a
requirement if our system needs to interact with other applications
that have already committed to particular ontologies or controlled
vocabularies. [...] There are libraries of reusable ontologies on the
Web and in the literature. [...]
```

N&M give this advice and then assume, for their own example, that nothing
relevant exists. cqa reuses three vocabularies, each in a different way. CCO
supplies the taxonomic parent for every class. EARL supplies terms that
correspond to what cqa models without being its parent. SKOS supplies the
predicates that state how strong each of those correspondences is.

## Candidates

Four vocabularies were surveyed, plus the foundational layer every schema in
this family grounds in.

**BFO and CCO.** The [Basic Formal Ontology](https://basic-formal-ontology.org/)
and the [Common Core Ontologies](https://www.commoncoreontologies.org/) are
where the taxonomic grounding comes from. Everything cqa models is an
*information content entity*: a question is content, a prose answer is
content, a set of them is content about content. CCO's ICE branch is
therefore the parent, and the only question is which node in it.

**EARL**, the [Evaluation and Report Language](https://www.w3.org/TR/EARL10-Schema/),
was built for reporting web-accessibility conformance results. Its abstraction
is not specific to accessibility: an assertor asserts that a test subject
passed or failed a test criterion. A competency-question benchmark has the
same structure, so several EARL terms correspond to cqa's.

**SKOS**, the [Simple Knowledge Organization System](https://www.w3.org/TR/skos-reference/),
supplies the mapping predicates rather than any term cqa grounds in. Nothing
in cqa is a kind of SKOS anything. SKOS is how one vocabulary states that a
term of its own corresponds to a term elsewhere, and how strong that
correspondence is.

**DCAT** and **PROV-O** were considered and set aside, for reasons in "What
we are not reusing yet" below.

<a id="jargon-earl"></a>

```admonish note title="Jargon: EARL"
**EARL** is a small RDF vocabulary for stating test outcomes: who ran a
test (`Assertor`), what was tested (`TestSubject`), what it was tested
against (`TestCriterion`), and how it came out (`TestResult`).

EARL is a W3C **Working Group Note** of 2 February 2017, not a
Recommendation. It was published as a Note because the Evaluation and Repair
Tools Working Group reached the end of its charter, and its
[Developer Guide](https://www.w3.org/TR/EARL10-Guide/) says the work is
"fairly complete but at this time there are not sufficient implementations to
finalize this work." Nothing has superseded it since.
```

<a id="jargon-skos"></a>

```admonish note title="Jargon: SKOS mapping properties"
**SKOS** is a W3C **Recommendation** (18 August 2009) for publishing
vocabularies. Only its *mapping properties* are used here, and they are
graded by how interchangeable two terms are:

- **`skos:exactMatch`** — usable interchangeably "across a wide range of
  information retrieval applications." Transitive, so it chains.
- **`skos:closeMatch`** — usable interchangeably in *some* applications.
  Not transitive.
- **`skos:relatedMatch`** — an associative link, weaker than either.

The grading lets a schema state how far a correspondence goes, not only
that one exists.
```

## How the reuse was checked

An IRI resolving is not the same as an IRI fitting: a term can exist, be
stable, and still be the wrong category for what it is attached to. Each term
below was checked three ways.

**Does the IRI resolve to what we think?** Every CCO IRI was resolved through
panschema's label lookup and its label read back. `cco:ont00000958` is
recorded here as *Information Content Entity* because that is the label it
returned.

**Does the definition fit?** Every EARL and SKOS term was taken from its
published schema together with its definition. The EARL definitions are quoted
in the table below so the fit is visible; the SKOS ones are in the jargon block
above, and they are what set the last column.

**What is each vocabulary's standing?** BFO 2020 is ISO/IEC 21838-2:2020 and
SKOS is a W3C Recommendation. EARL is a Working Group Note from a working
group that closed, as the jargon block above records. That difference is one
reason the EARL correspondences are recorded as mappings rather than as
groundings.

## The reuse table

| cqa concept | Grounding (`subclass_of`) | EARL correspondence | Recorded as |
|---|---|---|---|
| A competency question with its answer | `cco:ont00000958` *Information Content Entity* | `earl:TestCase` — "an atomic test, usually one that is a partial test for a requirement" | `skos:closeMatch` |
| The benchmark holding them | `cco:ont00000958` *Information Content Entity* | `earl:TestRequirement` — "a higher-level requirement that is tested by executing one or more sub-tests" | `skos:closeMatch` |
| A system's scored attempt (not modeled) | — | `earl:Assertion` — "a statement that embodies the results of a test" | nothing — not modeled here |
| The graph under evaluation (not modeled) | — | `earl:TestSubject` — "the class of things that have been tested against some test criterion" | nothing — not modeled here |
| A question's answer kind | — | no EARL counterpart | invented here |

**The grounding sits at the general ICE, not below it.** CCO splits
information content into a *descriptive* branch (`cco:ont00000853`, content
that describes) and a *prescriptive* one (`cco:ont00000965`, content that
directs), and they are disjoint. A benchmark record is both: its prose ground
truth describes what is true, and its list of records a correct answer must
retrieve prescribes what a system has to do. A class that spans two disjoint
siblings belongs at their common parent, so the general ICE is where it goes.

**EARL is an alignment, not a parent.** `subclass_of` is single-valued and
already used for the CCO grounding, so the EARL correspondence has to be a
mapping. Of the three mapping predicates, `closeMatch` is the accurate one,
for two reasons.

The first is what it means. A benchmark record and an accessibility test case
are interchangeable when the subject is reporting test outcomes, and not
otherwise, which is `closeMatch`'s definition and not `exactMatch`'s.

The second is that `exactMatch` is transitive, so it chains. If cqa asserted
`exactMatch` to `earl:TestCase`, and some third vocabulary later asserted
`exactMatch` between `earl:TestCase` and a term of its own, then cqa's class
and that third term would be exact matches as well — inferred automatically,
from an assertion made by people who have never seen this schema.
`closeMatch` is not transitive, so it cannot chain that way, and the alignment
stays a statement about exactly the two terms it names.

**The two out-of-scope rows.** ch01 excluded a system's attempt at an answer
and the graph under evaluation, on the argument that a benchmark should
outlive many attempts at it. EARL has terms for both, and models them
separately from its test criteria, so it draws its boundary in the same two
places. That does not prove ch01's exclusions are correct, but it does mean
they match an existing vocabulary's rather than only an argument made here.

## The grounding-by-URI pattern

Reuse here never means importing. The distinction is visible in the schema:

{{#include listings/cqa-yaml-v2.yaml:14:30 caption="The prefix manifest and the one import"}}

Every reused vocabulary is declared as a prefix {{#callout reuse}} and
reached by URI from there. The `imports:` list {{#callout imports}} stays at
`linkml:types` alone.

The reason is that the two mechanisms mean different things. LinkML
`imports:` pulls another **LinkML schema** into this one, and its classes
become part of what this schema defines. BFO, CCO, and EARL are not LinkML
schemas, and their classes are not ours to define. Referring to
`cco:ont00000958` by URI asserts a relationship to a term that stays where it
is, owned by the people who maintain it.

The choice of relationship then matters, and there are three:

- **`subclass_of`** emits `rdfs:subClassOf`, and says what we are: a narrower
  kind of the external term.
- **`class_uri`** would say the class *is* the external term, adopting its
  identity. That is a much stronger claim than cqa can support for anything
  it models, so it is unused here.
- **the SKOS mapping slots** (`exact_mappings`, `close_mappings`,
  `related_mappings`) emit `skos:exactMatch` and friends, and record
  correspondence without either claiming identity or asserting a taxonomic
  parent. This is where EARL lands.

Having all three available is what lets the table above carry two different
strengths in two different columns rather than flattening them into one
relationship that would be wrong for half the rows.

## What we are not reusing yet

**DCAT.** A published benchmark is, in a real sense, a dataset, and
`dcat:Dataset` would say so. But DCAT is a cataloguing vocabulary, concerned
with distributions, access URLs, and publishers, and none of the competency
questions in ch01 asks for any of that. It becomes worth adding when
benchmarks are published and catalogued rather than authored and read.

**PROV-O.** Who wrote a benchmark, when, and from what source is real
provenance, and PROV-O is the standard answer. No CQ-cqa asks for it. The
demand-driven rule this book follows says a term does not enter the schema
because it might be useful, so it stays out until a question needs it.

## What Step 2 produced

Step 2 adds no classes. What it adds is the two prefixes the alignments will
need, recording the decisions above where the tooling can read them:

{{#diff cqa-yaml-v1 cqa-yaml-v2 caption="Step 2: the reuse decisions, recorded as prefixes"}}

The groundings and mappings cannot be written yet, since there are no classes
to attach them to. The reuse table is this chapter's deliverable. Step 4
attaches its groundings to the classes it builds, and reports any row that
turns out not to fit once there is a real class under it.
