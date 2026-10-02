# abapGit serialization conventions

This repository stores abapGit objects with the following byte-level conventions,
matching abapGit's own serialization output:

| File kind | Encoding | BOM | Line endings | Final newline |
| --- | --- | --- | --- | --- |
| Metadata XML (`*.xml`) | UTF-8 | **with** BOM (`EF BB BF`) | CRLF | exactly one final CRLF |
| ABAP source/test (`*.abap`) | UTF-8 | **without** BOM | CRLF | exactly one final CRLF |

These conventions are enforced by `.gitattributes` (`-text` for `*.abap` and
`*.xml`), which disables Git line-ending normalization so the committed blobs
preserve the exact bytes (BOM + CRLF). Without this, `core.autocrlf` would
normalize CRLF to LF on `git add`, silently undoing the convention.

## Check

A repeatable byte-level check is provided:

```powershell
pwsh tools/check-abapgit-bytes.ps1        # verify (exit 1 on violations)
pwsh tools/check-abapgit-bytes.ps1 -Fix   # correct in place (idempotent)
```

The check verifies, per file: the BOM presence/absence, CRLF-only line endings,
and exactly one final CRLF (no trailing blank line).
