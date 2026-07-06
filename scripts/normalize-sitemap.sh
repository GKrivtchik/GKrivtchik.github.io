#!/usr/bin/env sh
set -eu

sitemap="${QUARTO_PROJECT_OUTPUT_DIR:-docs}/sitemap.xml"

if [ ! -f "$sitemap" ]; then
  echo "No sitemap found at $sitemap; skipping sitemap URL normalization."
  exit 0
fi

# Quarto writes sitemap locs from output filenames, e.g. /index.html, while
# canonical-url: true emits clean directory URLs, e.g. /. Keep those aligned.
perl -0pi -e 's#(<loc>[^<]*)/index\.html(</loc>)#$1/$2#g' "$sitemap"
