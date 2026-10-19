# MrDemonWolf Organization GitHub Configuration

[![Pinned repository updater](https://github.com/MrDemonWolf/.github/actions/workflows/update-readme.yml/badge.svg)](https://github.com/MrDemonWolf/.github/actions/workflows/update-readme.yml)

This repository holds the public profile content and repository-list automation
for the [MrDemonWolf organization](https://github.com/MrDemonWolf).

## Public profile ![GitHub Octicon: organization](./icons/organization.svg)

GitHub renders [`profile/README.md`](profile/README.md) on the organization
homepage. It uses the official light and dark wordmarks in this repository.

## Automation ![GitHub Octicon: workflow](./icons/workflow.svg)

The **Update README Pinned Repos** workflow runs daily at 06:00 UTC and can be
started manually. It updates only the content between the
`PINNED-REPOS` markers in the profile README.

## Repository files ![GitHub Octicon: repository](./icons/repo.svg)

- `profile/README.md` — public organization profile content.
- `logo_text.png` and `logo_text_dark.png` — light and dark wordmarks.
- `scripts/update-pinned-repos.sh` — builds the pinned repository section.
- `.github/workflows/update-readme.yml` — scheduled and manual automation.

## Icon source

The small blue icons are GitHub [Primer Octicons](https://github.com/primer/octicons),
licensed under MIT. Their fill color is adapted for readability on GitHub's light
and dark themes.
