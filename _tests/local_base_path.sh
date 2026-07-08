#!/usr/bin/env sh
set -eu

dest="$(mktemp -d "${TMPDIR:-/tmp}/jekyll-local-base-path.XXXXXX")"
trap 'rm -rf "$dest"' EXIT

JEKYLL_ENV=development bundle exec jekyll build --destination "$dest" --quiet

index="$dest/index.html"

if grep -Eq 'https://qianyi-shen\.github\.io/(assets|images|publications|year-archive|cv|hobbies|zh_cn)/' "$index"; then
  echo "development build contains absolute site.url links:" >&2
  grep -En 'https://qianyi-shen\.github\.io/(assets|images|publications|year-archive|cv|hobbies|zh_cn)/' "$index" >&2
  exit 1
fi

grep -q 'href="/assets/css/main.css"' "$index"
grep -q 'src="/assets/js/main.min.js"' "$index"
grep -q 'href="/publications/"' "$index"
grep -q 'src="/images/profile-avatar.jpg"' "$index"
