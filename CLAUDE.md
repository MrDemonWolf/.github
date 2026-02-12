# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is the **GitHub Organization `.github` repository** for [MrDemonWolf, Inc.](https://github.com/MrDemonWolf). It serves as the organization-level configuration repo that displays the public profile on the GitHub organization homepage.

## Structure

- `profile/README.md` — Organization profile README displayed at https://github.com/MrDemonWolf
- `logo_text.png` — Organization logo (647x100px) referenced in the profile README
- `scripts/update-pinned-repos.sh` — Shell script that queries GitHub GraphQL API for pinned repos and updates the README
- `.github/workflows/update-readme.yml` — GitHub Actions workflow that runs the script daily at 06:00 UTC

## Key Details

- There are no build, lint, or test commands — this repo contains Markdown, a PNG asset, and automation scripts.
- The profile README is the primary artifact; changes here directly affect the public-facing GitHub organization page.
- The logo is referenced in the README as `/logo_text.png` (root-relative path, resolved by GitHub).

## Auto-Update Mechanism

The "Key Repositories" section in `profile/README.md` is automatically updated by a GitHub Actions workflow:

- **Marker comments**: The auto-updated content lives between `<!-- PINNED-REPOS:START -->` and `<!-- PINNED-REPOS:END -->` markers. Do not remove these markers.
- **Script**: `scripts/update-pinned-repos.sh` queries the GitHub GraphQL API for the org's top 6 pinned repositories and builds an HTML table (2 per row) with name (linked), description, language, and star count.
- **Workflow**: `.github/workflows/update-readme.yml` runs daily at 06:00 UTC and on manual dispatch. It only commits if the README content actually changed.
- **Token**: The workflow uses the default `GITHUB_TOKEN` provided by GitHub Actions.
