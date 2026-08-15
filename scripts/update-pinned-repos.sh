#!/usr/bin/env bash
set -euo pipefail

ORG="MrDemonWolf"
README="profile/README.md"
START_MARKER="<!-- PINNED-REPOS:START -->"
END_MARKER="<!-- PINNED-REPOS:END -->"
DESC_LIMIT=100

# Featured projects, in display order. Edit this list to change what the
# profile README shows. These must be repositories the token can read.
REPOS=(fluffboost wolfwave conpaws linkden howlbox dirework)

if [ -z "${GITHUB_TOKEN:-}" ]; then
  echo "Error: GITHUB_TOKEN is not set." >&2
  exit 1
fi

# Build one aliased GraphQL query (r0, r1, ...) so this stays a single API call
QUERY="{"
for i in "${!REPOS[@]}"; do
  QUERY="${QUERY} r${i}: repository(owner: \\\"${ORG}\\\", name: \\\"${REPOS[$i]}\\\") { name url description primaryLanguage { name } stargazerCount }"
done
QUERY="${QUERY} }"

RESPONSE=$(curl -sf -H "Authorization: bearer ${GITHUB_TOKEN}" \
  -H "Content-Type: application/json" \
  -X POST https://api.github.com/graphql \
  -d "{\"query\": \"${QUERY}\"}")

# Truncate on a word boundary rather than mid-word
truncate_desc() {
  local text="$1"
  if [ "${#text}" -le "${DESC_LIMIT}" ]; then
    printf '%s' "${text}"
    return
  fi
  local cut="${text:0:${DESC_LIMIT}}"
  cut="${cut% *}"
  # Drop any dangling punctuation or connector left at the cut point
  cut=$(printf '%s' "${cut}" | sed -E 's/[[:space:],.;:+&/—-]+$//')
  printf '%s…' "${cut}"
}

# Escape the characters that would break the HTML table
escape_html() {
  printf '%s' "$1" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'
}

CELLS=()

for i in "${!REPOS[@]}"; do
  NODE=$(echo "${RESPONSE}" | jq -c ".data.r${i} // empty")

  if [ -z "${NODE}" ]; then
    echo "Warning: ${ORG}/${REPOS[$i]} not found or not readable. Skipping." >&2
    continue
  fi

  NAME=$(echo "${NODE}" | jq -r '.name')
  URL=$(echo "${NODE}" | jq -r '.url')
  DESC=$(echo "${NODE}" | jq -r '.description // ""')
  LANG=$(echo "${NODE}" | jq -r '.primaryLanguage.name // ""')
  STARS=$(echo "${NODE}" | jq -r '.stargazerCount')

  DESC=$(escape_html "$(truncate_desc "${DESC}")")

  # Build language badge if language exists
  if [ -n "${LANG}" ]; then
    LANG_BADGE="<code>${LANG}</code>"
  else
    LANG_BADGE=""
  fi

  CELLS+=("<td width=\"50%\">
<h3><a href=\"${URL}\">${NAME}</a></h3>
<p>${DESC}</p>
<p>${LANG_BADGE} ⭐ ${STARS}</p>
</td>")
done

REPO_COUNT=${#CELLS[@]}

if [ "${REPO_COUNT}" -eq 0 ]; then
  echo "No repositories resolved for ${ORG}. Skipping update."
  exit 0
fi

# Build an HTML table with 2 repos per row
TABLE="${START_MARKER}
<table>"

for i in $(seq 0 $((REPO_COUNT - 1))); do
  # Open a new row on even indices (0, 2, 4)
  if [ $((i % 2)) -eq 0 ]; then
    TABLE="${TABLE}
<tr>"
  fi

  TABLE="${TABLE}
${CELLS[$i]}"

  # Close the row on odd indices or if it's the last repo
  if [ $((i % 2)) -eq 1 ] || [ "${i}" -eq $((REPO_COUNT - 1)) ]; then
    # If last repo lands on an even index, add an empty cell
    if [ $((i % 2)) -eq 0 ]; then
      TABLE="${TABLE}
<td width=\"50%\"></td>"
    fi
    TABLE="${TABLE}
</tr>"
  fi
done

TABLE="${TABLE}
</table>
${END_MARKER}"

# Replace the section between markers using awk
awk -v start="${START_MARKER}" -v end="${END_MARKER}" -v table="${TABLE}" '
  $0 ~ start { print table; skip=1; next }
  $0 ~ end { skip=0; next }
  !skip { print }
' "${README}" > "${README}.tmp"

mv "${README}.tmp" "${README}"

echo "README updated with ${REPO_COUNT} repositories."
