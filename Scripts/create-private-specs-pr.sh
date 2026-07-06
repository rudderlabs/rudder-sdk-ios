#!/usr/bin/env bash
set -euo pipefail

pod_version="$(jq -r .version package.json)"
pr_title="deploy: Rudder ${pod_version}"
specs_repo="${SPECS_REPO_PATH:-${HOME}/.cocoapods/repos/rudderlabs}"
specs_gh_repo="rudderlabs/Specs"

cd "$specs_repo"

git fetch origin +refs/heads/master:refs/remotes/origin/master

if git diff --quiet origin/master...HEAD; then
  echo "No private Specs changes detected for Rudder ${pod_version}."
  exit 0
fi

existing_pr="$(gh pr list --repo "$specs_gh_repo" --state open --json title,url --limit 100 | jq -r --arg title "$pr_title" 'map(select(.title == $title))[0].url // empty')"
if [ -n "$existing_pr" ]; then
  echo "A Specs PR already exists for Rudder ${pod_version}: $existing_pr"
  exit 0
fi

branch_name="deploy/rudder-${pod_version}-${GITHUB_RUN_ID}-${GITHUB_RUN_ATTEMPT}"
git checkout -B "$branch_name"
git push origin "HEAD:refs/heads/${branch_name}"

pr_body="$(cat <<BODY
Adds Rudder ${pod_version} to the private CocoaPods Specs repo.

Created by ${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}. A human review is required by the Specs repository ruleset before merge.
BODY
)"

gh pr create \
  --repo "$specs_gh_repo" \
  --base master \
  --head "$branch_name" \
  --title "$pr_title" \
  --body "$pr_body"
