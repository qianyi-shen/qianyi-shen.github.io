#!/usr/bin/env sh
set -eu

dest="$(mktemp -d "${TMPDIR:-/tmp}/jekyll-google-discovery.XXXXXX")"
trap 'rm -rf "$dest"' EXIT

JEKYLL_ENV=production bundle exec jekyll build --destination "$dest" --quiet

sitemap="$dest/sitemap.xml"
robots="$dest/robots.txt"
verification="$dest/google7ccebb56736f6b44.html"

require_file() {
  if ! test -f "$1"; then
    echo "Missing expected file: $1" >&2
    exit 1
  fi
}

require_pattern() {
  file="$1"
  pattern="$2"
  if ! grep -q "$pattern" "$file"; then
    echo "Missing expected pattern in $file: $pattern" >&2
    exit 1
  fi
}

require_file "$sitemap"
require_pattern "$sitemap" '<loc>https://qianyi-shen.github.io/</loc>'
require_pattern "$sitemap" '<loc>https://qianyi-shen.github.io/publications/</loc>'
require_pattern "$sitemap" '<loc>https://qianyi-shen.github.io/cv/</loc>'

require_file "$robots"
require_pattern "$robots" '^User-agent: \*$'
require_pattern "$robots" '^Allow: /$'
require_pattern "$robots" '^Sitemap: https://qianyi-shen\.github\.io/sitemap\.xml$'

require_file "$verification"
require_pattern "$verification" '^google-site-verification: google7ccebb56736f6b44\.html$'
