# Appendix A: The Worked Example

Wine's competency questions, encoded as a cqa benchmark. Six of wine's seven
are here; [Chapter 7](ch07-instances-and-validation.md) explains the seventh's
absence.

This file is authored in the
[ontology-authoring-template](https://github.com/padamson/ontology-authoring-template)
repository, beside the graph its anchors point into, and frozen here at
[commit `20cac5f`](https://github.com/padamson/ontology-authoring-template/commit/20cac5fc7996f05be24ab84e96d463b655452216).
Its anchors are written bare {{#callout anchor}} and expand against the
target schema it declares once {{#callout target}};
[Chapter 7](ch07-instances-and-validation.md#what-running-it-changed) records
why the contract says so. Reading the file in that repository shows something
this copy cannot: every anchor below resolves to a record wine actually mints,
and `cq-03`'s stated absence {{#callout absence}} is checked against wine's
catalog rather than taken on trust.

Each question names the kinds of answering it calls for {{#callout kind}},
and `cq-07` names two {{#callout two-kinds}}, which is why
[Chapter 5](ch05-slots.md) made the slot multivalued. Where an answer must
rest on a record rather than only reach it, the citation is one of the
anchors {{#callout citation}}. The one negative narrows its claim to the
class of record that would have joined the anchors {{#callout via}}.

{{#include listings/wine-benchmark-v1.yaml}}
