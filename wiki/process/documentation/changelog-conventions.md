# Changelog Conventions

> We use [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format and [Semantic Versioning](https://semver.org/).

## Format

Every product has a `CHANGELOG.md` at the repo root. New entries go at the top. Format:

```markdown
# Changelog

All notable changes to this product are documented here.

## [Unreleased]
### Added
- Feature X for Y
### Changed
- Behavior Z now happens differently
### Fixed
- Bug in W

## [1.2.0] - 2026-05-15
### Added
- Bulk export of customers to CSV (#42)
### Security
- Patched CVE-2026-12345 in httpx (severity: High)

## [1.1.1] - 2026-05-01
### Fixed
- Date parsing crashed on empty input (#38)

## [1.0.0] - 2026-04-15
### Added
- Initial release
```

## Change categories (use these exact names)

- **Added** — new features
- **Changed** — changes to existing behavior
- **Deprecated** — soon-to-be-removed features (give users notice)
- **Removed** — features removed in this release
- **Fixed** — bug fixes
- **Security** — vulnerability patches (always mention CVE / severity)

Skip categories that don't apply; don't write `### Added: none`.

## Version numbering — SemVer

`MAJOR.MINOR.PATCH`:

- **MAJOR** bump: breaking change — an API contract broke, a user workflow changed in an incompatible way, or a config option was removed. For internal tools, this is rare — reserve for deliberate redesigns.
- **MINOR** bump: new feature added without breaking anything.
- **PATCH** bump: bug fix, security patch, performance improvement.

## When to cut a release

- When the `Unreleased` section has enough changes to notice
- Or when you need to deploy a specific fix
- Or on a time cadence (weekly / biweekly) if that suits the product

Tag the release in git (`git tag v1.2.0`) and push the tag.

## What to exclude

- Internal refactors that users don't notice (still in the changelog if they changed something runtime-observable, but skip for pure name-changes)
- Typo fixes in docs
- Dependency bumps (unless security or user-visible)
- CI / tooling changes

The changelog is **for users** of the product. Engineering-internal churn belongs in the git log, not here.

## Who writes the changelog

The person opening the PR updates `Unreleased`. Reviewer checks the entry is accurate.

At release time, the releaser moves entries from `Unreleased` to the new version section and adds the date.

## Linking to issues / PRs

Use `(#42)` for GitHub issues / PRs — GitHub auto-renders these as links. Makes archaeology easy.

## Internal-tool specifics

Since our products are internal, the changelog is read by:

- Other engineers on the team (for upstream / downstream awareness)
- Product owners tracking what shipped
- Users if they want to see what changed (link from the app's about/help page)
- Future-you when trying to remember when a feature landed

Keep it accessible — no jargon that outsiders wouldn't understand.
