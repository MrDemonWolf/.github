# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is the **GitHub Organization `.github` repository** for [MrDemonWolf, Inc.](https://github.com/MrDemonWolf). It serves as the organization-level configuration repo that displays the public profile on the GitHub organization homepage.

## Structure

- `profile/README.md` — Organization profile README displayed at https://github.com/MrDemonWolf
- `logo_text.png` — Organization logo, light-mode variant with navy wordmark (1294x281px)
- `logo_text_dark.png` — Organization logo, dark-mode variant with white wordmark (1294x281px)
- `scripts/update-pinned-repos.sh` — Shell script that queries GitHub GraphQL API for a curated list of repos and updates the README
- `.github/workflows/update-readme.yml` — GitHub Actions workflow that runs the script daily at 06:00 UTC

## Key Details

- There are no build, lint, or test commands — this repo contains Markdown, PNG assets, and automation scripts.
- The profile README is the primary artifact; changes here directly affect the public-facing GitHub organization page.
- The logo is a `<picture>` element at the top of the README with a `prefers-color-scheme` source for each variant, plus `logo_text.png` as the `<img>` fallback. Paths are root-relative (`/logo_text.png`), resolved by GitHub.
- Both logo variants are rendered from the brand SVGs in the website repo (`apps/stack/public/logo-text-brand.svg` for light, `logo-text-white.svg` for dark). Regenerate both together so the framing stays identical when the theme switches.

## Auto-Update Mechanism

The "Key Repositories" section in `profile/README.md` is automatically updated by a GitHub Actions workflow:

- **Marker comments**: The auto-updated content lives between `<!-- PINNED-REPOS:START -->` and `<!-- PINNED-REPOS:END -->` markers. Do not remove these markers.
- **Script**: `scripts/update-pinned-repos.sh` fetches a curated list of repositories from the GitHub GraphQL API and builds an HTML table (2 per row) with name (linked), description, language, and star count. Descriptions are truncated on a word boundary at 100 characters.
- **Changing the featured projects**: edit the `REPOS` array at the top of `scripts/update-pinned-repos.sh`. The list is ordered and drives display order. GitHub's own "pinned repositories" setting is no longer used, so re-pinning in the GitHub UI has no effect here. Repos the token cannot read (private, renamed, deleted) are skipped with a warning rather than failing the run.
- **Workflow**: `.github/workflows/update-readme.yml` runs daily at 06:00 UTC and on manual dispatch. It only commits if the README content actually changed.
- **Token**: The workflow uses the default `GITHUB_TOKEN` provided by GitHub Actions.
