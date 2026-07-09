#!/bin/sh

set -eu

fail() {
  echo "local_base_path.sh: $1" >&2
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
build_dir=$(mktemp -d "${TMPDIR:-/tmp}/qianyi-local-base-path.XXXXXX")

cd "$repo_root"

JEKYLL_ENV=development bundle exec jekyll build --destination "$build_dir" --quiet

index="$build_dir/index.html"
zh="$build_dir/zh_cn/index.html"
cv="$build_dir/cv/index.html"
hobbies="$build_dir/hobbies/index.html"
blog="$build_dir/year-archive/index.html"
publications="$build_dir/publications/index.html"

for file in "$index" "$zh" "$cv" "$hobbies" "$blog" "$publications"; do
  assert_file "$file"
done

assert_contains "$index" 'href="/assets/css/main.css"'
assert_contains "$index" 'src="/assets/js/main.min.js"'
assert_contains "$index" 'href="/publications/"'
assert_contains "$index" 'src="/images/profile-avatar.jpg"'

assert_not_contains "$index" 'https://qianyi-shen.github.io/assets/css/main.css'
assert_not_contains "$index" 'https://qianyi-shen.github.io/assets/js/main.min.js'
assert_not_contains "$index" 'https://qianyi-shen.github.io/images/profile-avatar.jpg'
assert_not_contains "$index" 'https://qianyi-shen.github.io/publications/'

assert_contains "$index" 'class="academic-home"'
assert_contains "$zh" 'class="academic-home"'
assert_contains "$cv" 'class="academic-page academic-cv"'
assert_contains "$hobbies" 'class="academic-page academic-hobbies"'
assert_contains "$hobbies" 'class="hobby-gallery"'
assert_contains "$hobbies" 'class="hobby-feature"'
assert_contains "$blog" 'class="blog-index"'
assert_contains "$blog" 'class="post-tags"'
assert_contains "$publications" 'class="publication-meta publication-meta--'
assert_contains "$publications" 'publication-meta--published'
assert_contains "$publications" 'publication-meta--submitted'
assert_contains "$publications" 'Submitted'
assert_contains "$publications" 'under review'
assert_not_contains "$publications" '<i>Submitted (under review)</i>'

assert_file "_includes/publication-links.html"
assert_contains "_includes/archive-single.html" "{% include publication-links.html item=post %}"

echo "local_base_path.sh: ok"
