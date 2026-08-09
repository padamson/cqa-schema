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

<!--
CHARTER: Give the classes their properties — overwhelmingly N&M's
fourth kind, relationships to other individuals. Settle the
per-relation policies (typing, inverses, store-vs-derive, naming) once,
then walk the relations cluster by cluster.

SECTION OUTLINE:
  - The policies (name vs. genericize; inverse; store vs. derive).
  - Relations (the provenance wiring), walked cluster by cluster.
  - Ranges for each slot.
  - Cardinality derived from the competency questions.

CARRIED-IN DEFERRALS -> this step:
  [ ] Keep the negative case expressible. For a "nothing on record"
      answer (CQ-wine 3) the records a question names are not evidence
      *for* the answer — they are the ground the absence is observed
      against, and they must still be retrieved or an evaluator cannot
      tell a correct negative from a system that retrieved nothing and
      guessed. Whatever the retrieval slot is called, it has to carry
      both readings. (source: ch01, "Testing the questions against a
      real set")
  [ ] Carry CQ-cqa 7 into the slots. ch04 made `Benchmark` a class so
      one benchmark's `cq-01` and another's stay distinct, and left the
      mechanism here: which slot bears the identifier, and what that
      does to the identifiers of the questions beneath it. Note the
      charter's rule — the root's id is `identifier: true` (globally one
      thing) and a question's id is `key: true` (unique within its
      benchmark), which is what makes questions mint beneath their
      benchmark. panschema honours `key` set through `slot_usage` as of
      `fdf7632`, so a shared `id` slot refined per class works.
      (source: ch04, "Why the benchmark is a class")
  [ ] Decide whether `answer_kind` is single- or multivalued. Choosing
      kinds for wine's questions turned up a question that is genuinely
      two kinds at once: CQ-wine 7 ("what were good vintages for Napa
      Zinfandel?") is an `attribution` — the answer is worse without
      "the regional vintage chart rates 2018 good" — and also a
      `comparison`, since 2018 `good` against 2017 `average` is what
      makes a vintage good. CQ-wine 4 has the same shape at lower
      stakes. ch03 wrote "an evaluator switches on the kind", which
      implies single-valued. Single is defensible if the rule is "name
      the strictest check", but then that rule has to be in the slot's
      description rather than left to the author to guess.
      (source: wine's answer-kind selection, 2026-08-07)
  [ ] Answer CQ-cqa 8 with slots on `Benchmark`: which schema, at which
      version, and which dataset the anchors are valid against. ch04
      ruled out a target class (no identity apart from the benchmark
      naming it) and left the slots here. Both failure modes are real —
      wine's later release moves the judgment IRIs that three of its
      questions must cite, and wine's four-record preview is a strict
      subset of its thirty-seven-record worked example, so
      `wine:bordeaux-wine` resolves against one dataset and not the
      other with schema and version identical. Decide whether the
      version is the schema's or the dataset's, since they can differ.
      (source: ch04, "A target is not a class")
  [ ] Discharge the island check ch04 deferred. With the anchor and
      citation slots in place the class graph should have edges, and
      every class should be reachable — `CompetencyQuestionAnswer` to
      `DomainRecord`, `Benchmark` to its questions. A node still
      disconnected at the end of Step 5 is a bug to explain or remove.
      (source: ch04, "The hierarchy, such as it is")

AUTHORING CHECKLIST:
  [ ] freeze a new cqa-yaml-vN listing tag in the same change
  [ ] {{#diff}} from the prior tag, with context=N sized so each hunk
      shows its enclosing class/section header (note: stripped # CALLOUT
      lines consume context, so add a couple extra)
  [ ] jargon blocks at first use; every # CALLOUT gets a {{#callout}}
  [ ] LESSON (Step 5): derive cardinality/required from the CQs;
      lenient by default (PROV-O stance).
  [ ] demand check: what does the worked example need at this step?
-->
