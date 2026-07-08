#!/usr/bin/env sh
set -eu

dest="$(mktemp -d "${TMPDIR:-/tmp}/jekyll-hobbies-media.XXXXXX")"
trap 'rm -rf "$dest"' EXIT

JEKYLL_ENV=production bundle exec jekyll build --destination "$dest" --quiet

hobbies="$dest/hobbies/index.html"

grep -q 'src="/images/mclaren.jpg"[^>]*loading="lazy"' "$hobbies"
grep -q 'src="/images/lh44.jpg"[^>]*loading="lazy"' "$hobbies"
grep -q 'src="/images/ferrari.jpg"[^>]*loading="lazy"' "$hobbies"
grep -q 'src="/images/cuihua.jpg"[^>]*loading="lazy"' "$hobbies"

test -f "$dest/images/lh44.jpg"
test ! -f "$dest/images/lh44.png"

lh44_bytes="$(wc -c < "$dest/images/lh44.jpg" | tr -d ' ')"
mclaren_bytes="$(wc -c < "$dest/images/mclaren.jpg" | tr -d ' ')"

test "$lh44_bytes" -lt 600000
test "$mclaren_bytes" -lt 600000
