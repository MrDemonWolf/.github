#!/usr/bin/env bash
set -euo pipefail

ORG="MrDemonWolf"
README="profile/README.md"
START_MARKER="<!-- PINNED-REPOS:START -->"
END_MARKER="<!-- PINNED-REPOS:END -->"

if [ -z "${GITHUB_TOKEN:-}" ]; then
  echo "Error: GITHUB_TOKEN is not set." >&2
  exit 1
fi

# Query GitHub GraphQL API for pinned repos
RESPONSE=$(curl -sf -H "Authorization: bearer ${GITHUB_TOKEN}" \
  -H "Content-Type: application/json" \
  -X POST https://api.github.com/graphql \
  -d "$(cat <<GRAPHQL
{
  "query": "{ organization(login: \"${ORG}\") { pinnedItems(first: 4, types: REPOSITORY) { nodes { ... on Repository { name url description primaryLanguage { name } stargazerCount } } } } }"
}
GRAPHQL
)")

# Extract repo count
REPO_COUNT=$(echo "${RESPONSE}" | jq '.data.organization.pinnedItems.nodes | length')

if [ "${REPO_COUNT}" -eq 0 ] || [ "${REPO_COUNT}" = "null" ]; then
  echo "No pinned repos found for ${ORG}. Skipping update."
  exit 0
fi

# Build the markdown table
TABLE="${START_MARKER}
| Repository | Description | Language | Stars |
|---|---|---|---|"

for i in $(seq 0 $((REPO_COUNT - 1))); do
  NAME=$(echo "${RESPONSE}" | jq -r ".data.organization.pinnedItems.nodes[${i}].name")
  URL=$(echo "${RESPONSE}" | jq -r ".data.organization.pinnedItems.nodes[${i}].url")
  DESC=$(echo "${RESPONSE}" | jq -r ".data.organization.pinnedItems.nodes[${i}].description // \"\"" | cut -c1-80 | sed 's/|/-/g')
  LANG=$(echo "${RESPONSE}" | jq -r ".data.organization.pinnedItems.nodes[${i}].primaryLanguage.name // \"—\"")
  STARS=$(echo "${RESPONSE}" | jq -r ".data.organization.pinnedItems.nodes[${i}].stargazerCount")

  TABLE="${TABLE}
| [${NAME}](${URL}) | ${DESC} | ${LANG} | ${STARS} |"
done

TABLE="${TABLE}
${END_MARKER}"

# Replace the section between markers using awk
awk -v start="${START_MARKER}" -v end="${END_MARKER}" -v table="${TABLE}" '
  $0 ~ start { print table; skip=1; next }
  $0 ~ end { skip=0; next }
  !skip { print }
' "${README}" > "${README}.tmp"

mv "${README}.tmp" "${README}"

echo "README updated with ${REPO_COUNT} pinned repos."
