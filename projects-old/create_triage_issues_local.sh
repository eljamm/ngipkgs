#!/bin/env bash

REPO="ngi-nix/ngipkgs"
DRY_RUN=true

create_triage_issue() {
    TITLE="Triage data for \`$1\`"
    BODY=$(
        cat <<-EOF
	 Follow the instructions for [triaging an NGI project](https://github.com/ngi-nix/ngipkgs/blob/main/CONTRIBUTING.md#triaging-an-ngi-project) and collect some relevant information about this project, which will later be used to expose its packaging state.
	EOF
    )

    if $DRY_RUN; then
        >&2 echo "==="
        >&2 echo "${TITLE}"
        >&2 echo "---"
        >&2 echo "${BODY}"
    else
        echo "Creating triaging issue for '$project' in $REPO"
        gh issue create \
            --repo "$REPO" \
            --title "$TITLE" \
            --body "$BODY" \
            --label "good first issue"
    fi
}

echo "Creating triaging issues"
while read -r project; do
    create_triage_issue "$project"
done <./not-triaged.txt
