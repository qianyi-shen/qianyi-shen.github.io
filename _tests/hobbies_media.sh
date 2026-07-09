#!/bin/sh

set -eu

fail() {
  echo "hobbies_media.sh: $1" >&2
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

hobbies_page="_pages/hobbies.md"
content_styles="_sass/layout/_academic-content.scss"
max_bytes=614400

assert_file "$hobbies_page"
assert_file "$content_styles"

for image in images/mclaren.jpg images/lh44.jpg; do
  assert_file "$image"
  bytes=$(wc -c < "$image" | tr -d ' ')
  [ "$bytes" -lt "$max_bytes" ] || fail "$image is ${bytes} bytes, expected under ${max_bytes}"
done

for image in mclaren.jpg lh44.jpg ferrari.jpg cuihua.jpg; do
  grep -Eq "src=\"/images/${image}\"[^>]*loading=\"lazy\"" "$hobbies_page" \
    || fail "$image should be lazy-loaded in $hobbies_page"
done

assert_not_contains "$hobbies_page" "lh44.png"
assert_not_contains "$hobbies_page" "style="
assert_not_contains "$hobbies_page" "display: flex"
assert_not_contains "$hobbies_page" "width: 32%"

assert_contains "$hobbies_page" 'class="hobby-gallery"'
assert_contains "$hobbies_page" 'class="hobby-feature"'
assert_contains "$content_styles" ".hobby-gallery"
assert_contains "$content_styles" ".hobby-feature"
assert_contains "$content_styles" "max-width: 420px"
assert_contains "$content_styles" "aspect-ratio: 16 / 9"

echo "hobbies_media.sh: ok"
