#!/usr/bin/env bash
#
# validate.sh — build-time invariants for the content "writing" standard.
#
# Runs against the already-built ./public directory. Verifies that the surfaces
# driven by partials/writing.html (the canonical feed and llms.txt) stay
# consistent and link only to pages that actually exist. Exits non-zero on any
# failure so it can gate the Vercel build (see buildCommand in vercel.json).
#
# Usage: bash scripts/validate.sh   (run `hugo --gc --minify` first)

set -uo pipefail

PUBLIC="${1:-public}"
FEED="$PUBLIC/blog/index.xml"
LLMS="$PUBLIC/llms.txt"
fail=0

err() { echo "  ✗ $*"; fail=1; }
ok()  { echo "  ✓ $*"; }

# Map a site URL/path to the file Hugo generated for it (pretty URLs).
path_to_file() {
  local p="$1"
  p="${p#https://codehakase.com}"   # strip host if present
  p="${p#/}"                        # strip leading slash
  p="${p%/}"                        # strip trailing slash
  echo "$PUBLIC/$p/index.html"
}

echo "Validating $PUBLIC against the writing standard..."

# 0. The artifacts must exist at all.
[ -f "$FEED" ] || err "missing canonical feed: $FEED"
[ -f "$LLMS" ] || err "missing generated llms.txt: $LLMS"
if [ "$fail" -ne 0 ]; then echo "FAILED"; exit 1; fi

# 1. Every writing link in llms.txt resolves to a real built page.
echo "[1] llms.txt links resolve"
llms_links=$(grep -oE 'https://codehakase\.com/(blog|shorts)/[a-z0-9._/-]+' "$LLMS" | sort -u)
dead=0
while IFS= read -r url; do
  [ -z "$url" ] && continue
  f=$(path_to_file "$url")
  [ -f "$f" ] || { err "dead link in llms.txt: $url"; dead=1; }
done <<< "$llms_links"
[ "$dead" -eq 0 ] && ok "all llms.txt writing links resolve"

# 2. Every <link> in the feed resolves (skip the channel's own <link>).
echo "[2] feed item links resolve"
feed_links=$(grep -oE '<link>[^<]+</link>' "$FEED" \
  | sed -E 's#</?link>##g' \
  | grep -E '/(blog|shorts)/.+' | sort -u)
dead=0
while IFS= read -r url; do
  [ -z "$url" ] && continue
  f=$(path_to_file "$url")
  [ -f "$f" ] || { err "dead link in feed: $url"; dead=1; }
done <<< "$feed_links"
[ "$dead" -eq 0 ] && ok "all feed item links resolve"

# 3. No non-writing pages leaked into the feed (only /blog/ and /shorts/, plus
#    the channel's own /blog/ link).
echo "[3] feed contains only writing pages"
leaks=$(grep -oE '<link>[^<]+</link>' "$FEED" \
  | sed -E 's#</?link>##g' \
  | grep -vE 'codehakase\.com/blog/?($|[a-z0-9._/-])|codehakase\.com/shorts/[a-z0-9._/-]' || true)
if [ -n "$leaks" ]; then
  err "non-writing page(s) leaked into feed:"; echo "$leaks" | sed 's/^/      /'
else
  ok "feed is blog/shorts only"
fi

# 4. The surfaces agree on item count (feed items == llms.txt writing links).
echo "[4] surfaces agree on count"
feed_count=$(grep -o '<item>' "$FEED" | grep -c . || true)
llms_count=$(printf '%s\n' "$llms_links" | grep -c . || true)
if [ "$feed_count" != "$llms_count" ]; then
  err "count drift: feed=$feed_count llms=$llms_count (both derive from partials/writing.html)"
else
  ok "feed and llms.txt agree: $feed_count items"
fi

echo
if [ "$fail" -ne 0 ]; then
  echo "VALIDATION FAILED"
  exit 1
fi
echo "VALIDATION PASSED"
