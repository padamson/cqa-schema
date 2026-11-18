#!/usr/bin/env bash
# Verify each frozen benchmark listing against the schema it was written
# for, not against schema/cqa.yaml on main. A frozen benchmark is a
# snapshot of a consumer's data at one cqa version, and the chapter that
# embeds it claims it conforms to that version. Checking it against main
# would fail every edition the moment the schema moves on, and checking
# nothing would let the claim rot.
#
# Every frozen *-benchmark-*.yaml must appear in PAIRS, so a newly frozen
# benchmark cannot go unchecked. Run by the frozen-benchmarks-verify hook
# and by docs.yml.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

# frozen benchmark listing | schema it conforms to
# Edition 2 still embeds wine's 0.1 benchmark until wine is re-encoded
# for 0.2, so it is held to the frozen v0.1.1 schema.
PAIRS=(
  "book/editions/1/src/listings/wine-benchmark-v1.yaml|book/editions/1/src/listings/cqa-yaml-v10.yaml"
  "book/editions/2/src/listings/wine-benchmark-v1.yaml|book/editions/1/src/listings/cqa-yaml-v10.yaml"
)

schema_for() {
  local pair
  for pair in "${PAIRS[@]}"; do
    if [[ "${pair%%|*}" == "$1" ]]; then
      echo "${pair#*|}"
      return
    fi
  done
}

shopt -s nullglob
status=0
for f in book/editions/*/src/listings/*-benchmark-*.yaml; do
  schema="$(schema_for "$f")"
  if [[ -z "$schema" ]]; then
    echo "FAIL: $f has no schema in scripts/verify-frozen-benchmarks.sh PAIRS"
    status=1
    continue
  fi
  echo "verify $f against $schema"
  panschema verify --schema "$schema" --data "$f" || status=1
done
exit "$status"
