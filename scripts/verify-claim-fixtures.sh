#!/usr/bin/env bash
# Check the value claims in data/claims/ against wine's graph, which
# panschema.toml pins and panschema.lock locks.
#
# Per-file `verify --schema --data` leaves every value claim unchecked,
# because checking one needs the graph it names. Bare `verify` reads the
# files [check.cqa] lists, which must hold every claim they state.
# `verify --entry cqa` reads each file in invalid/ as the cqa entry's
# data, which must fail with exactly one finding, of the kind its
# `# expect:` line names, so a fixture that starts failing for another
# reason (a conformance error, a second claim) fails here too.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
err="$(mktemp "${TMPDIR:-/tmp}/claim-fixtures.XXXXXX")"
trap 'rm -f "$err"' EXIT

panschema fetch --check

# Every cqa file read as a benchmark with records (a file read against the
# wrong root conforms with none), at least one value claim read, and the
# error-level finding kinds exactly $kinds.
filter='
  (map(select(.reason == "dataset-read" and .entry == "cqa"))
   | length > 0 and all(.root == "Benchmark" and .records > 0))
  and (map(select(.reason == "summary" and .entry == "cqa"
                  and .family == "value-claim"))
   | .[0] | .checked + .uncheckable > 0)
  and (map(select(.reason == "finding" and .level == "error")
           | .kind) == $kinds)'

status=0

# check LABEL WANT_EXIT KINDS_JSON VERIFY_ARGS...
check() {
  local label="$1" want="$2" kinds="$3" code=0 out
  shift 3
  out="$(panschema verify "$@" --strict --message-format json 2>"$err")" ||
    code=$?
  if [[ $code -eq $want ]] &&
     jq -se --argjson kinds "$kinds" "$filter" <<<"$out" >/dev/null; then
    echo "ok, $label"
  else
    echo "FAIL: $label (exit $code, wanted $want)"
    sed 's/^/  /' "$err"
    status=1
  fi
}

check "claims hold: [check.cqa] instances" 0 '[]'

shopt -s nullglob
for f in data/claims/invalid/*.yaml; do
  expect="$(sed -n 's/^# expect: //p' "$f")"
  if [[ -z "$expect" ]]; then
    echo "FAIL: $f has no '# expect:' line naming the finding kind it must produce"
    status=1
    continue
  fi
  check "$expect: $f" 1 "[\"$expect\"]" --entry cqa --data "$f"
done
exit "$status"
