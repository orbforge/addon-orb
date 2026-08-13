#!/bin/sh

set -eu

TEST_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$TEST_DIR/../docker/mqtt-summary.sh"

TEST_TMP=$(mktemp -d "${TMPDIR:-/tmp}/mqtt-summary-test.XXXXXX")
trap 'rm -rf "$TEST_TMP"' EXIT HUP INT TERM

TEST_NUMBER=0

orb_stub() {
  if [ "$#" -ne 1 ] || [ "$1" != "summary" ]; then
    printf 'unexpected orb arguments\n' >&2
    return 99
  fi

  [ -n "$STUB_STDOUT" ] && printf '%s\n' "$STUB_STDOUT"
  [ -n "$STUB_STDERR" ] && printf '%s\n' "$STUB_STDERR" >&2
  return "$STUB_STATUS"
}

fail() {
  printf 'not ok %s - %s\n' "$TEST_NUMBER" "$1"
  exit 1
}

assert_file() {
  ASSERT_NAME=$1
  ASSERT_FILE=$2
  ASSERT_EXPECTED=$3
  EXPECTED_FILE="$TEST_TMP/expected"

  printf '%b' "$ASSERT_EXPECTED" >"$EXPECTED_FILE"
  if ! cmp -s "$EXPECTED_FILE" "$ASSERT_FILE"; then
    printf '%s mismatch:\n' "$ASSERT_NAME" >&2
    diff -u "$EXPECTED_FILE" "$ASSERT_FILE" >&2 || true
    return 1
  fi
}

run_case() {
  CASE_NAME=$1
  DEBUG_MODE=$2
  STUB_STATUS=$3
  STUB_STDOUT=$4
  STUB_STDERR=$5
  EXPECTED_STDOUT=$6
  EXPECTED_STDERR=$7
  TEST_NUMBER=$((TEST_NUMBER + 1))

  if ! emit_orb_summary orb_stub >"$TEST_TMP/stdout" 2>"$TEST_TMP/stderr"; then
    fail "$CASE_NAME returned a non-zero status"
  fi

  assert_file stdout "$TEST_TMP/stdout" "$EXPECTED_STDOUT" || fail "$CASE_NAME stdout"
  assert_file stderr "$TEST_TMP/stderr" "$EXPECTED_STDERR" || fail "$CASE_NAME stderr"
  printf 'ok %s - %s\n' "$TEST_NUMBER" "$CASE_NAME"
}

printf '1..4\n'

run_case \
  'success suppresses stderr when debug is off' \
  false 0 \
  '{"orb_score":42}' \
  'Starting Orb
Config directory: /data' \
  '{"orb_score":42}\n' \
  ''

run_case \
  'success replays stderr when debug is on' \
  true 0 \
  '{"orb_score":42}' \
  'Starting Orb
Config directory: /data' \
  '{"orb_score":42}\n' \
  'Starting Orb\nConfig directory: /data\n'

run_case \
  'failure logs diagnostics when debug is off' \
  false 7 \
  '' \
  'summary unavailable
connection refused' \
  '{}\n' \
  'orb summary failed (exit 7):\nsummary unavailable\nconnection refused\n'

run_case \
  'failure logs diagnostics when debug is on' \
  true 7 \
  '' \
  'summary unavailable
connection refused' \
  '{}\n' \
  'orb summary failed (exit 7):\nsummary unavailable\nconnection refused\n'
