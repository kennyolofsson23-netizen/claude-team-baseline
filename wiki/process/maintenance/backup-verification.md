# Backup Verification

> A backup you haven't restored is a rumour, not a backup.

## The monthly drill — per product

First Monday of each month. ~30 minutes per product.

1. **Pick a backup** — most recent automated backup from Azure SQL (automated backups are on by default for Azure SQL Database; confirm enabled).
2. **Restore to a scratch database** — name it `<project>_restore_test_YYYYMMDD`. Same Azure SQL server, different DB name.
3. **Run a smoke query** — pick 3-5 key tables, `SELECT COUNT(*) FROM dbo.<Table>` + 1-2 representative rows.
4. **Compare** — do the counts and sample rows match what you'd expect for that backup time? (A backup that restored an empty schema is a failed backup.)
5. **Record** — append a line to `docs/runbook.md` under the `## Backups` section: `YYYY-MM-DD | <backup-time> | restored OK | counts: ...`.
6. **Clean up** — delete the scratch database to avoid extra cost.

## What a PASS looks like

- Scratch DB restored without errors
- Schema is present (Alembic migrations reflected)
- Row counts match the real DB within reasonable bounds (allow for delta since the backup)
- At least one sample row of sample data reads correctly

## What a FAIL looks like

- Restore fails (bad backup file, permission issue, storage issue)
- Schema missing or corrupted
- Data missing
- Row counts way off from prod

**A failed verification is an incident.** Use `incident-response.md`, investigate, fix before the next business day.

## Azure SQL backup defaults — what's on by default

- **Automated backups** — yes, included in the service
- **Point-in-time restore** — up to 7 days (configurable up to 35)
- **Long-term retention** — NOT enabled by default; configure per product if needed (regulated-data classification usually requires it)
- **Geo-redundant backups** — on for most tiers; verify in product setup

See `ARCHITECTURE.md` of each product for the project-specific retention decision.

## What this doesn't cover

- **Non-MSSQL stores** — if a product uses Blob Storage for files, verify those separately (Azure has native versioning + soft delete; test the restore path).
- **Config / secrets** — Key Vault has its own restore mechanism; not part of this drill.
- **Code** — GitHub is the backup for code. Tagged releases are the rollback points. No separate verification needed.

## Once we have 3+ products

Manual per-product verification gets painful. Gap-register entry already exists for **automating** the verification: a scripted job that does the restore + smoke query + records the result per product. ARB prioritises when we hit the pain point.
