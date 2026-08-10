# Slot Usage and Facets

This chapter applies **Step 6** of *Ontology Development 101* (Noy &
McGuinness, 2001) to cqa.

```admonish quote title="Noy & McGuinness 2001 — §Step 6"
Slots can have different facets describing the value type, allowed values,
the number of the values (cardinality), and other features of the values
the slot can take.
```

```admonish quote title="Noy & McGuinness 2001 — §Step 6, cardinality"
Sometimes it may be useful to set the maximum cardinality to 0. This setting
would indicate that the slot cannot have any values for a particular subclass.
```

<!--
CHARTER: Narrow the inherited slots per class via slot_usage — tighten
ranges, bound values, sweep cardinality, and declare property
characteristics — without ever widening what the slot already allows.

SECTION OUTLINE:
  - Per-class narrowing (slot_usage refinements).
  - Value bounds (minimum/maximum_value, patterns, enums).
  - The cardinality sweep (required/optional, max-cardinality-0).
  - Property characteristics (symmetric, transitive, ...).

CARRIED-IN DEFERRALS -> this step:
  [ ] Enforce "every citation is also an anchor", or record why not.
      ch05 states it as a fact in `expected_citations`' description and
      nothing checks it, so a benchmark can cite a record it never
      required retrieving — which would pass validation and be
      meaningless to an evaluator. A class-level `rules` block is the
      candidate (panschema enforces rules natively as of `6339b40`);
      the alternative is to leave it to the reference validator and say
      so. (source: ch05, "The anchors carry two readings")
  [ ] Reconsider the three target slots if the target dataset is
      identified. ch05 records target_schema, target_version and
      target_dataset because wine's `WineCatalog` is a vessel and its
      datasets have no IRI to point at. A dataset whose root carries an
      identifier is a node, and for those a single reference says all
      three. Do not add a second way to express the same thing on
      speculation — this is a note for when a real target arrives
      identified, most likely a schema that already publishes its data
      for citation. (source: ch05, "What the target should be, and what
      it is")

  NOTE (verified 2026-08-08, so nobody re-checks it): `answer_kind`
  needs no `minimum_cardinality`. On a multivalued slot, `required`
  already rejects an empty list —
  `answer_kind: []` fails with "required slot `answer_kind` is absent".
  The citation rule above is a real hole; this one is not.

AUTHORING CHECKLIST:
  [ ] freeze a new cqa-yaml-vN listing tag in the same change
  [ ] {{#diff}} from the prior tag, with context=N sized so each hunk
      shows its enclosing class/section header (note: stripped # CALLOUT
      lines consume context, so add a couple extra)
  [ ] jargon blocks at first use; every # CALLOUT gets a {{#callout}}
  [ ] sweep for constraints a per-slot facet CANNOT express: slots that
      must travel together (amount + unit; an all-or-none group) or that
      hang on a state value (a decided verdict requires its reviewer) are
      RULES, not facets — LinkML class `rules` with preconditions /
      postconditions and `value_presence`. A constraint spanning several
      NODES (uniqueness across records) is an INVARIANT — it belongs to
      validation (SHACL) at Step 7.
  [ ] LESSON (Step 6): know which rung a constraint lives on. FACET —
      one slot, one node (N&M's Step 6; a facet only restricts, never
      widens; OWL-DL "simple property" rule: a transitive property cannot
      also be irreflexive/asymmetric or carry cardinality). RULE —
      several slots, one node, via LinkML `rules`. INVARIANT — several
      nodes; SHACL validation at Step 7.
  [ ] demand check: what does the worked example need at this step?
-->
