#!/bin/bash

# Finds contributions in a commit range based for an author

# Make sure foreground process group can be terminated
trap 'echo Terminated $0; exit' INT;

if [ "$#" -eq "0" ]; then
  echo "Finds pull request contributions in a commit range based for an author"
  echo ""
  echo "Usage: fcontribpr.sh <range> <author>"
  echo ""
  echo "For example, to check the contributions between 8.1.0 and 8.2.0 by @korthout:"
  echo "  $ fcontribpr.sh 8.1.0..8.2.0 nico.korthout@camunda.com"
  echo ""
  echo "This tool requires both git and gh"
  echo "See https://cli.github.com/" 
  exit 0
fi

range=$1
author=$2

# Find commits shas in range by author
commits=$(git log "$range" --author="$author" --oneline | cut -c -10)

# Find pull requests by commit sha
prs=()
for c in $commits
do
  pr=$(gh api \
    -H "Accept: application/vnd.github+json" \
    --jq '.[].html_url' \
    /repos/camunda/zeebe/commits/"$c"/pulls)

  prs+=( "$pr" )
done

# Filter for unique entries and print them
for pr in "${prs[@]}"; do echo "${pr}"; done | sort | uniq
