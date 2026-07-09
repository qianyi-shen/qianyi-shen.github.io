#!/bin/sh

set -eu

fail() {
  echo "site_hygiene.sh: $1" >&2
  exit 1
}

assert_file_missing() {
  [ ! -e "$1" ] || fail "unexpected generated file: $1"
}

assert_generated_not_contains() {
  pattern=$1
  if grep -R -Fq "$pattern" "$build_dir"; then
    fail "did not expect generated output to contain: $pattern"
  fi
}

assert_source_not_contains() {
  file=$1
  pattern=$2
  if grep -Fq "$pattern" "$file"; then
    fail "did not expect $file to contain: $pattern"
  fi
}

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
build_dir=$(mktemp -d "${TMPDIR:-/tmp}/qianyi-site-hygiene.XXXXXX")

cd "$repo_root"

JEKYLL_ENV=production bundle exec jekyll build --destination "$build_dir" --quiet

assert_file_missing "$build_dir/AGENTS.md"
assert_file_missing "$build_dir/.DS_Store"
assert_file_missing "$build_dir/_config.yml"
assert_file_missing "$build_dir/Gemfile"
assert_file_missing "$build_dir/Gemfile.lock"
assert_file_missing "$build_dir/package.json"
assert_file_missing "$build_dir/package-lock.json"
assert_file_missing "$build_dir/_tests"
assert_file_missing "$build_dir/_sass"
assert_file_missing "$build_dir/assets/js/_main.js"
assert_file_missing "$build_dir/assets/js/plugins"
assert_file_missing "$build_dir/vendor"
assert_file_missing "$build_dir/.bundle"
assert_file_missing "$build_dir/node_modules"
assert_file_missing "$build_dir/_site"
assert_generated_not_contains '<p class="archive__item-excerpt" itemprop="description"><p>'
assert_generated_not_contains '"sameAs" : null'
assert_generated_not_contains 'href="#" class="pagination--pager disabled"'
assert_source_not_contains "_includes/paginator.html" 'href="#" class="disabled"'
assert_source_not_contains "_includes/paginator.html" 'href="#" class="disabled current"'

echo "site_hygiene.sh: ok"
