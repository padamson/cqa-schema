#!/usr/bin/env bash
# The jq program below names jq variables ($kind, $entry), not shell ones.
# shellcheck disable=SC2016
# Check every benchmark in data/: the ones meant to fail fail for the
# reason they were written to show, and the value claims hold.
#
# Each file in an invalid/ directory must fail with exactly one
# error-level finding, named in its leading comments:
#
#   # expect: <kind> [<text the finding's message contains>]
#
# The text tells apart fixtures whose findings share a kind, so a fixture
# that starts failing for another reason fails here too.
#
# data/invalid/ holds benchmarks that do not conform to cqa, read on
# their own with `verify --schema --data`.
#
# data/claims/ holds value claims against wine's graph, which
# panschema.toml pins and panschema.lock locks. Per-file `verify --schema
# --data` leaves every value claim unchecked, because checking one needs
# the graph it names. Bare `verify` reads the files [check.cqa] lists,
# which must hold every claim they state, and `verify --entry cqa` reads
# each file in data/claims/invalid/ as the cqa entry's data.
#
# A YAML file in data/ that none of these reads fails the script, so a
# benchmark cannot sit there unchecked.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
err="$(mktemp "${TMPDIR:-/tmp}/fixtures.XXXXXX")"
trap 'rm -f "$err"' EXIT

schema="$(scripts/schema-path.sh)"

# One line per way verify's output differs from what was expected: every
# file read as a benchmark with records (a file read against the wrong
# root conforms with none), the error-level findings exactly the one
# $kind (none when it is empty) saying $text, and, when $claims is set,
# at least one value claim read. $entry, when set, is the manifest entry
# the file is read as.
problems='
  (map(select(.reason == "dataset-read"
              and ($entry == "" or .entry == $entry)))
   | if length == 0 then "no file was read"
     elif all(.root == "Benchmark" and .records > 0) then empty
     else "read as " + (map("\(.root) with \(.records) record(s)")
                        | join(", ")) + ", not a benchmark with records"
     end),
  (map(select(.reason == "finding" and .level == "error"))
   | map(.kind) as $got
   | (if $kind == "" then [] else [$kind] end) as $want
   | if $got != $want
     then "error findings \($got | tojson), expected \($want | tojson)"
     elif $text != "" and (.[0].message | contains($text) | not)
     then "the finding does not say \($text | tojson): \(.[0].message)"
     else empty end),
  (if $claims == "" then empty
   else map(select(.reason == "summary" and .entry == $entry
                   and .family == "value-claim")) | .[0]
     | if . == null or .checked + .uncheckable == 0
       then "no value claim was read" else empty end
   end)'

status=0
checked=""   # the files in data/ a check has read, one per line
out=""       # verify's JSON output from the last check

fail() {
  echo "FAIL: $1"
  status=1
}

# check LABEL KIND TEXT CLAIMS ENTRY VERIFY_ARGS...: verify exits 0 when
# KIND is empty, else 1.
check() {
  local label="$1" kind="$2" text="$3" claims="$4" entry="$5"
  local want=1 code=0 found
  shift 5
  [[ -z $kind ]] && want=0
  out="$(panschema verify "$@" --message-format json 2>"$err")" ||
    code=$?
  found="$(jq -sr --arg kind "$kind" --arg text "$text" \
    --arg claims "$claims" --arg entry "$entry" "$problems" <<<"$out")"
  [[ $code -eq $want ]] ||
    found+="${found:+$'\n'}exit $code, expected $want"
  if [[ -z $found ]]; then
    echo "ok, $label"
  else
    fail "$label"
    printf '  %s\n' "${found//$'\n'/$'\n'  }"
    sed 's/^/  | /' "$err"
  fi
}

# fixtures DIR CLAIMS ENTRY VERIFY_ARGS...
fixtures() {
  local dir="$1" claims="$2" entry="$3" count=0 f line kind text
  shift 3
  for f in "$dir"/*.yaml; do
    count=$((count + 1))
    checked+="$f"$'\n'
    line="$(sed -n '/^[^#]/q; s/^# expect: *//p' "$f" | tr -d '\r')"
    read -r kind text <<<"$line" || true
    if [[ -z $kind || $line == *$'\n'* ]]; then
      fail "$f needs one '# expect: <kind>' line in its leading comments"
      continue
    fi
    check "$kind: $f" "$kind" "$text" "$claims" "$entry" "$@" --data "$f"
  done
  [[ $count -gt 0 ]] || fail "no fixture in $dir"
}

shopt -s nullglob
fixtures data/invalid "" "" --schema "$schema"

# The claims need wine's graph, which the conformance checks above do not.
panschema fetch --check
check "claims hold: [check.cqa] instances" "" "" claims cqa --strict
checked+="$(jq -sr --arg root "$PWD/" '.[]
  | select(.reason == "dataset-read" and .entry == "cqa")
  | .file | ltrimstr($root)' <<<"$out")"$'\n'
fixtures data/claims/invalid claims cqa --entry cqa --strict

while IFS= read -r f; do
  grep -qxF "$f" <<<"$checked" ||
    fail "$f is read by no check: put it in data/invalid/ or data/claims/invalid/, or list it in [check.cqa] instances"
done < <(find data -type f \( -name '*.yaml' -o -name '*.yml' \) | sort)
exit "$status"
