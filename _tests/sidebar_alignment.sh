#!/bin/sh

set -eu

fail() {
  echo "sidebar_alignment.sh: $1" >&2
  exit 1
}

assert_file() {
  [ -f "$1" ] || fail "missing expected file: $1"
}

assert_contains() {
  file=$1
  pattern=$2
  grep -Fq "$pattern" "$file" || fail "expected '$pattern' in $file"
}

assert_not_contains() {
  file=$1
  pattern=$2
  if grep -Fq "$pattern" "$file"; then
    fail "did not expect '$pattern' in $file"
  fi
}

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_root"

profile="_includes/author-profile.html"
sidebar_styles="_sass/layout/_sidebar.scss"

assert_file "$profile"
assert_file "$sidebar_styles"

assert_contains "$profile" 'class="author__desktop"'
assert_contains "$profile" 'class="author__wechat-trigger"'
assert_contains "$profile" 'fab fa-google-scholar fa-fw icon-pad-right'
assert_not_contains "$profile" 'author__url-row'

if grep -n '<li><a class=' "$profile" >/dev/null; then
  fail "sidebar author links should not need row-only classes"
fi

if grep -Fq 'ai ai-google-scholar' "$profile"; then
  fail "Google Scholar should use the Font Awesome brand icon, not Academicons"
fi

assert_not_contains "$sidebar_styles" ".author__url-row"
assert_contains "$sidebar_styles" ".author__urls a,"
assert_contains "$sidebar_styles" ".author__urls .author__wechat-trigger,"
assert_contains "$sidebar_styles" ".sidebar .author__desktop"
assert_contains "$sidebar_styles" "grid-template-columns: 1.25em auto"
assert_contains "$sidebar_styles" ".author__urls .icon-pad-right"
assert_contains "$sidebar_styles" "padding-right: 0"
assert_contains "$sidebar_styles" "margin-right: 0"

echo "sidebar_alignment.sh: ok"
