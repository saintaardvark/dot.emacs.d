#!/bin/bash

# Bletcherous hack, but hopefully it works

find ~/dev -type d -maxdepth 5 -name .git -exec dirname {} \; | \
	sed -e's/$/"/;s/^/"/;s#/Users/hubrown#~#;s#"$#/"#' | \
	grep -v pkg/dep > /tmp/dev.list

cat projectile-bookmarks.eld | tr ' ' '\n' | tr -d '(' | tr -d ')' > /tmp/existing.list

echo "("
cat /tmp/dev.list /tmp/existing.list | \
	sort | \
	uniq 
echo ")"
