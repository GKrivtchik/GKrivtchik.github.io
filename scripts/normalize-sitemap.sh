#!/usr/bin/env sh
set -eu

output_dir="${QUARTO_PROJECT_OUTPUT_DIR:-docs}"
sitemap="$output_dir/sitemap.xml"

if [ -f "$sitemap" ]; then
  # Quarto writes sitemap locs from output filenames, e.g. /index.html, while
  # canonical-url: true emits clean directory URLs, e.g. /. Keep those aligned.
  perl -0pi -e 's#(<loc>[^<]*)/index\.html(</loc>)#$1/$2#g' "$sitemap"
else
  echo "No sitemap found at $sitemap; skipping sitemap URL normalization."
fi

# Quarto also writes internal navigation and listing links to index.html, then
# cleans them in the browser with JavaScript. Normalize the HTML source so
# crawlers see the canonical directory URLs immediately. Leave external URLs
# untouched and preserve query strings and fragments.
find "$output_dir" -type f -name '*.html' -exec \
  perl -0pi -e 's{(\bhref=["'\''])(?![A-Za-z][A-Za-z0-9+.-]*:|//)([^"'\'']*)index\.html(?=([?#][^"'\'']*)?["'\''])}{$1$2}g' {} +
