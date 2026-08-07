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

<!--
CHARTER: Promote the Step 3 terms into classes and an is_a hierarchy,
each domain class grounded in its BFO/CCO category via subclass_of
(rdfs:subClassOf to the external term — the Biolink-established
pattern), not a wrapper class.

SECTION OUTLINE:
  - Foundational anchors (abstract classes grounded in BFO/CCO).
  - The is_a hierarchy (domain classes specialize the anchors).
  - The grounding pattern (subclass_of to the external URI).

CARRIED-IN DEFERRALS -> this step:
  [ ] Apply ch02's reuse table. Attach `subclass_of: cco:ont00000958`
      to the benchmark-item and benchmark-set classes, and the EARL
      alignments as `close_mappings` (earl:TestCase on the item,
      earl:TestRequirement on the set). ch02 committed to those
      strengths on the strength of the definitions; if a grounding does
      not fit once there is a real class under it, say so here rather
      than quietly using a different one — ch02 ends by promising
      exactly that. (source: ch02, "What Step 2 produced")
  [ ] Decide whether a question can anchor to a *schema element* rather
      than to a record. CQ-wine 1 ("which characteristics should I
      consider?") is answered by wine's schema, not by anything in its
      graph, so a record-anchored benchmark cannot express it. Either
      the classes grow a way to name a T-box element, or such questions
      are declared out of scope and the book says so plainly. Do not
      leave it silently uncovered. (source: ch01, "Testing the questions
      against a real set")

AUTHORING CHECKLIST:
  [ ] freeze a new cqa-yaml-vN listing tag in the same change
  [ ] {{#diff}} from the prior tag, with context=N sized so each hunk
      shows its enclosing class/section header (note: stripped # CALLOUT
      lines consume context, so add a couple extra)
  [ ] jargon blocks at first use; every # CALLOUT gets a {{#callout}}
  [ ] LESSON (Step 4): verify upper-ontology CATEGORY fit, not just IRI
      existence (the Quality-in-ICE error); build the graph viz and
      treat island nodes as bugs.
  [ ] demand check: what does the worked example need at this step?
-->
