# Preface to the Second Edition

The second edition covers `cqa` from `v0.2.0`, which is not yet released.
The first edition covers `v0.1.0` and `v0.1.1`.

<!--
CHARTER
What changed from the first edition, in a page: which decisions the
chapters now derive differently, and why a reader of the first edition
would otherwise build a model the schema no longer has. Written last,
once the v0.2.0 constructs below have landed in the chapters.

CARRIED-IN DEFERRALS (v0.2.0 scope, ruled 2026-11-15)
Each item lands as its own change: schema, re-frozen listing, and the
chapters it touches, all in this edition.
- [x] A benchmark over more than one target dataset
      (target_dataset / target_dataset_version; ch04, ch05). Landed as
      target_datasets, a list of TargetDataset (dataset, version), in
      ch04-ch07.
- [ ] Re-freeze wine's benchmark for 0.2.0 into Appendix A once wine is
      re-encoded (target_datasets, closed_world_negative); drop Appendix
      A's "encoded for cqa 0.1.1" paragraph; re-pair the frozen benchmark
      in scripts/verify-frozen-benchmarks.sh to the 0.2.0 listing; re-read
      ch07's litmus table and target section against it. If wine's
      re-encoded cq-07 states its verdicts, rewrite ch07's "What the checks
      cannot see" reproduction against wine's benchmark instead of
      data/claims/holds.yaml, and add expected_values to the litmus table's
      CQ-cqa 1 row. Wine keeps one dataset (ruled 2026-11-18: panschema
      versions every dataset by its package, so a judgments dataset could
      never move apart from the rest). ch04 and ch05 illustrate the third
      failure on wine split hypothetically into reference and judgments
      datasets (CQ-wine 4); the book does not name the private graphs
      that drove it. From the multi-dataset slice.
- [x] Expected values: an anchor, a slot of the target schema, and the
      value it carries, including an enumerated value as the answer.
      Landed as expected_values, a list of ExpectedValue (record, slot,
      value), in ch04-ch07, checked by bare verify against wine 0.2.1
      (data/claims/).
- [ ] An absence narrowed by a slot value, and an empty slot as an
      answer.
- [x] An ordering claim over anchors. Landed as ordered_by, naming the
      target slot whose expected values order the answer, ascending, with
      a rule requiring two or more expected values; ch05-ch07. Bare verify
      checks the values against wine 0.2.1 (data/claims/holds.yaml); no
      check reads ordered_by itself, by ruling 2026-11-25.
- [x] A retrieval budget and a citation-precision floor, as slots on
      Benchmark. Landed as retrieval_budget (integer >= 1, annotated
      bounds_count_of expected_anchors, so per-file verify fails a
      question with more anchors than the budget) and
      citation_precision_floor (0-1, the share of cited records among the
      question's anchors, by ruling 2026-11-25); ch05-ch07.
- [ ] Alternative evidence sets, only if a consumer record rests on two
      sets of records; otherwise dropped, with the reason.
- [x] closed-world-negative -> closed_world_negative, the spelling
      LinkML's standard_naming lint expects of a permissible value.
      Breaking for every 0.1 record that uses it, so the preface, when
      written, names it for first-edition readers.
- [ ] ch01: re-derive CQ-cqa from the new demand; decide the worked
      example's labels and what Appendix A embeds. ch04 hangs expected
      values on CQ-cqa 1 ("what is the correct answer?"); decide whether
      that holds or a question of its own asks for a checkable answer.
Out of scope for v0.2.0, by ruling: quantities with tolerance and unit,
an answer kind for closures, marking a record partial.

REWIND (2026-11-17): listings from cqa-yaml-v3 on are placeholders. The
slices above change the schema and prose only; none of them freezes.
- [ ] Forward freeze, ch04 to ch07, once the v0.2.0 model is final:
      each `LISTING` comment becomes its include or diff directive again
      and each `callout` comment its badge, the prose that names a diff
      or a listing re-read against what was frozen. Before the release
      slice.
- [ ] After the forward freeze, decide whether scripts/check-line-width.sh
      and its schema-line-width hook stay. Kept beside book.toml's
      max-line-width by ruling 2026-11-26 (b87ba90), because the budget
      checks only at freeze and this edition freezes nothing until then.
-->
