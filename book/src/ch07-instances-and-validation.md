# Instances and Validation

This chapter applies **Step 7** of *Ontology Development 101* (Noy &
McGuinness, 2001) to cqa.

```admonish quote title="Noy & McGuinness 2001 — §Step 7"
The last step is creating individual instances of classes in the
hierarchy. Defining an individual instance of a class requires (1)
choosing a class, (2) creating an individual instance of that class, and
(3) filling in the slot values.
```

<!--
CHARTER: Instantiate the worked example as a LinkML data file under
data/ (NOT hand-authored OWL/TTL — panschema's instance reader ingests
LinkML data: a tree_root container class whose multivalued collections
hold records conforming to the schema). Validate natively with
`panschema validate --schema schema/cqa.yaml --data data/<file>.yaml`.
Publish the instance graph(s) via [[instances]] in panschema-publish.toml
so they render on the schema page behind the in-page selector. Run each
Step-1 competency question as the litmus test. Refine the schema where
instantiation surfaces a gap — validation and refinement are one
interleaved activity (a class or slot that only earns its keep here is a
smell; see the LESSON).

What a data file needs that the schema so far did not (add as the data
demands): a tree_root CONTAINER class holding a multivalued collection
per record kind; an IDENTIFIER slot (`id`, `identifier: true`) distinct
from a human `name`, because records reference each other by a short,
stable key. Narrate these as honest adaptations of the method to a
file-based workflow — not modeling insights about the domain.

SECTION OUTLINE:
  - A small instance-graph PREVIEW first: a separate, tiny LinkML data
    file (2-4 records with a couple of edges) that introduces
    individual / node / edge, DISTINCT from the full worked example.
    State the distinction in prose — the preview teaches the vocabulary;
    the worked example is the larger data file the chapter builds.
  - What a data file needs that the schema did not (container + id),
    shown as a {{#diff}} against the prior tag with callouts.
  - The worked example: the full catalog, large enough to answer every
    competency question, reproduced in Appendix A. Both graphs publish
    behind the selector (mark one exemplar = the default panel).
  - Validation: `panschema validate` against the schema — the constraints
    Step 6 declared are what it now enforces.
  - The competency-question litmus, each answered by tracing the catalog
    (and, where the graphRAG story is told, as a retrieved subgraph).
  - Close on the knowledge graph the schema was always for: RDF T-box +
    A-box are one graph; any reified judgment class carries the rationale
    a bare edge cannot.

CARRIED-IN DEFERRALS -> this step:
  [ ] Re-run ch01's CQ-cqa/CQ-wine cross-check as a real test. ch01 states
      plainly that its table is a by-eye reading of wine's prose, not a
      machine check, and promises this step will make the same claims
      testable: anchors resolve or they do not, and a question either
      carries the fields its answer kind needs or it fails. Report what
      the encoding actually found, including any row ch01 got wrong.
      (source: ch01, "Checking them against a real set")
  [ ] Run the litmus over **eight** CQ-cqa, not six. ch01 sketched six;
      ch03 added CQ-cqa 7 (what identifies a benchmark) after the term
      brainstorm found a term no question asked for, and ch04 added
      CQ-cqa 8 (which schema, version and dataset the anchors are valid
      against) after asking whether the target deserved a class. Both
      late arrivals are about the benchmark as a whole rather than any
      record in it, which is what makes them the two most likely to be
      under-tested. (source: ch03, "A term with no question behind it";
      ch04, "A target is not a class")
  [ ] Confirm the target still needs four slots when wine is encoded.
      ch05 recorded target_schema, target_schema_version, target_dataset
      and target_dataset_version because wine's `WineCatalog` is a vessel
      whose graphs deliberately carry no identifier, so the benchmark has
      to state what the dataset cannot say about itself. ch06 could not
      settle it — no facet expresses "these four collapse to one" — so
      the check belongs here, where a real target is encoded for the
      first time. If wine's catalog turns out to carry an identifier, or
      gains one, say so: a single reference then replaces the four, and
      the redundancy ch05 accepted on purpose stops being worth its cost.
      (source: ch05, "What the target should be, and what it is";
      re-deferred from ch06, "What Step 6 could not settle")
  [ ] Re-check that slot types are enforced. Six of eight datatype slots
      take their type from `default_range` rather than an explicit
      `range:`, which is deliberate. Add a wrong-typed record to the
      negative fixtures and confirm `question: 42` is rejected — and
      that it is rejected in every output that should carry the type,
      not only the one that happens to.
      (source: ch05, and the schema-authoring convention in CLAUDE.md)

AUTHORING CHECKLIST:
  [ ] worked example is a LinkML data file under data/, validated by
      `panschema validate` (conforms) — NOT hand-authored TTL
  [ ] a small preview data file, distinct from the worked example,
      introduced in the intro with the distinction stated in prose
  [ ] both graphs wired into panschema-publish.toml [[instances]] (name
      labels the selector tab; mark one exemplar = the default panel)
  [ ] Appendix A embeds the frozen worked-example data listing
  [ ] freeze a new cqa-yaml-vN tag for the schema additions
      (container + id + any refinement); {{#diff}} from the prior tag,
      context=N sized so each hunk shows its enclosing header
  [ ] jargon blocks at first use; every # CALLOUT gets a {{#callout}}
  [ ] LESSON (Step 7): the worked example should have driven the build
      FROM Step 1 — if a class or slot only validates here, that is the
      smell of reasoning backward from the data.
  [ ] demand check: does every Step-1 competency question get an answer?
      If not, iterate (N&M's second rule) — refine, don't reverse.
-->
