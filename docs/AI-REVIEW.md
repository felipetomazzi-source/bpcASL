# AI Review — Phase 0 Slice 1

## Review metadata

- Reviewer: Codex
- Date: 2026-10-02 (Pacific/Auckland)
- Branch: `feature/asl-001-token-diagnostics`
- Base: `main`, `9c696f9248b46dc9a8931cd367aa5c3b86c023a3` (also merge base).
- Reviewed commits: all seven commits above main, through `c9e5ac264eeb7325f59d74ed31a6f1ac5d2e9a0d`:
  - `6c31f5f097bceae284bb48a70d521444dcdc594f`: initial implementation.
  - `1ee507f01ff07afc627db41173491afd16067342`: source, metadata and test corrections.
  - `067a0069bb21d3d3228655a04c59548a1c2f1fa1`: implementation-agent review edits, independently checked rather than trusted.
  - `07e81fca45380595c48e8e304b43b4a75189521c`: previous independent review.
  - `df9237eef6b914a66f6b1c25e23c90102500cd74`: remaining test coverage.
  - `a71dfe22aee7c03170cd1490f20153225191f9cc`: trailing-character assertions.
  - `c9e5ac264eeb7325f59d74ed31a6f1ac5d2e9a0d`: approved coordinate contract and range example test.
- Requirements: partial ASL-OPS-001 (§31), foundation for ASL-LANG-001 (§8). These are the slice mappings supported by commits and implementation tracking; no separate authoritative Slice 1 allocation exists. ASL-PROD-023/024/026/028 are cross-cutting constraints; ASL-PROD-044/§36 governs testing. ASL-UI-003 and ASL-API-005 are downstream consumers, not UI/HTTP deliverables here.
- SAP validation status: Not run. No SAP compilation, activation, ABAP Unit or import success is claimed. One read-only ADT source request failed; no SAP change was attempted.
- Initial working tree: tracked files/index clean; pre-existing untracked `AGENTS.md` and `docs/CODEX-HANDOFF.md`. Only this review is changed and committed.
- Evidence rule: Resolved means the identified local defect is corrected. It does not mean SAP validation succeeded. The original problems below are historical.

## Verdict

**APPROVED**

Approved for the local Phase 0 Slice 1 source/documentation review. The five original findings are resolved; no open BLOCKER, HIGH or MEDIUM finding remains. Follow-up REVIEW-006 is LOW and does not block the local source approval. SAP validation is still required before claiming an activated, executable implementation. The complete diff from main reveals no additional regression or excluded-scope implementation.

## Findings

### REVIEW-001 — abapGit metadata drops local test classes

- Severity: HIGH
- Status: Resolved
- Requirements: ASL-PROD-023; ASL-PROD-044/§36.
- File: all seven `src/zcl_bpc_asl_*.clas.xml` files.
- Line: 14 (`WITH_UNIT_TESTS`).
- Problem: Originally, test companions existed but the class metadata omitted the unit-test flag, allowing abapGit import to discard their source.
- Consequence: Import could produce classes without the intended tests.
- Required correction: Retain test companions and set `WITH_UNIT_TESTS=X` consistently.
- Verification required: XML consistency locally; actual import, generated test discovery and ABAP Unit in SAP.
- Resolution evidence: All seven current class XML files parse, match filename/object names and contain the flag. The correction in `1ee507f` remains intact. No SAP import or execution is claimed.

### REVIEW-002 — Empty normalized value is indistinguishable from absence

- Severity: HIGH
- Status: Resolved
- Requirements: ASL-LANG-001 foundation; optional normalized-value contract.
- File: `src/zcl_bpc_asl_token.clas.abap`; accompanying test class.
- Line: 75 and 98–116 in source; explicit-empty test at 120.
- Problem: Originally, `has_value` inferred presence from noninitial string content.
- Consequence: A present empty decoded value was indistinguishable from omission.
- Required correction: Store presence independently from content and preserve the original lexeme.
- Verification required: Omitted, explicit-empty, nonempty and numeric-text-zero cases, including lexeme assertions.
- Resolution evidence: Factory captures `iv_value IS SUPPLIED` into private state; `has_value` returns that state. All four cases have independent expected assertions. The explicit-empty presence assertion would detect the original defect. No executable test result is claimed.

### REVIEW-003 — Source-coordinate contract unresolved and underspecified

- Severity: MEDIUM
- Status: Resolved
- Requirements: ASL-OPS-001; ASL-LANG-001 foundation; downstream ASL-UI-003/ASL-API-005; questions protocol.
- File: `docs/AI-QUESTIONS.md`; `docs/DECISIONS.md`; source-position/range class headers and range tests.
- Line: 354 (Q-012); 209 (ADR-022); 3 (source headers).
- Problem: Originally, Q-012 remained blocking and lacked accepted counting, tab, line-ending and Unicode semantics.
- Consequence: Future coordinate producers and consumers could interpret identical ranges differently.
- Required correction: Record the user's answer, examples and producer responsibilities; align comments and tracking.
- Verification required: Origin, one-unit range, zero-width insertion/EOF, multiline, tab, line-ending, combining-mark and supplementary-character examples; later verify relevant string behavior on ABAP 7.52.
- Resolution evidence: The user explicitly confirmed the convention. Q-012 is now Resolved/Blocking: No; ADR-022 records exactly that answer: 1-based coordinates, half-open ranges, UTF-16 code-unit columns, tab=one unit, CRLF/CR normalized to LF, supplementary characters=two units and combining marks counted separately. All requested examples are documented. Class headers and status tracking agree; a new one-character range test asserts all endpoints and nonzero width. Producer counting/normalization belongs to the future lexer, not these coordinate containers. This closes the decision/documentation defect without claiming Unicode runtime validation.

### REVIEW-004 — Tests omit essential range and vocabulary behavior

- Severity: MEDIUM
- Status: Resolved
- Requirements: ASL-OPS-001; ASL-LANG-001 foundation; ASL-PROD-044/§36.
- File: source-range, source-position, token-kind and token `.clas.testclasses.abap` files.
- Line: range declarations 6–16; token preservation fixtures from 183; token-kind `kind_names_correct` method.
- Problem: Originally, meaningful ordering, endpoint, vocabulary and preservation cases were absent. The previous independent review retained gaps for actual-string trailing spaces, independent kind names and invalid end columns.
- Consequence: Ordering, renaming, trimming and argument-forwarding defects could escape the authored suite.
- Required correction: Keep prior meaningful additions; add genuine string fixtures, length/content/final-character assertions, independent names for all 23 kinds, and zero/negative end-column rejection.
- Verification required: Inspect regression sensitivity and later execute the complete imported suite in SAP.
- Resolution evidence: String-template fixtures retain trailing spaces; assertions check expected content and lengths, and explicitly inspect the last character. An additional `SCRIPT ` fixture asserts output length seven. `kind_names_correct` compares each of the 23 constants to independent expected public strings; validity and uniqueness checks remain. New zero/negative end-column cases use a later end line, preventing reversed-range rejection from masking lost column validation. Earlier cross-line ordering, negative-position, quoted mixed-case, BMP Unicode and EOF cases remain. Together these assertions detect the identified defects by inspection. There are 45 authored methods across seven includes; none were executed locally or in SAP. Mutation tests were not run.

### REVIEW-005 — Diagnostic prefix policy and validator disagree

- Severity: LOW
- Status: Resolved
- Requirements: ASL-OPS-001; downstream ASL-API-005.
- File: `src/zcl_bpc_asl_diag_code.clas.abap`; `docs/DECISIONS.md`.
- Line: source header 20–25 and validator 48; ADR-021 at 190.
- Problem: Originally, the documented category convention appeared stricter than shape-only validation.
- Consequence: Consumers could mistakenly rely on validation to enforce category ownership.
- Required correction: Clarify validation scope and test its documented boundaries.
- Verification required: Recommended/unknown prefixes, case/digit/underscore rules and 60/61-character boundaries.
- Resolution evidence: Header and ADR-021 consistently document shape-only validation, with category ownership enforced by convention/review. The regex and authored cases match that policy. Existing codes must not be renamed or repurposed. Actual SAP regex execution remains pending.

## Requirement coverage

| Assigned requirement | Coverage | Evidence | Verification level |
| --- | --- | --- | --- |
| ASL-OPS-001, Slice 1 portion | Implemented for the assigned portion; full requirement partially implemented | Positive immutable positions, ordered half-open ranges, INFO/WARNING/ERROR, stable code convention, structured diagnostics and optional location. ADR-022 settles coordinates. Stage/partition/correlation ID remain deferred. | Independent local source, documentation, metadata and authored-test inspection; no SAP execution. |
| ASL-LANG-001, Slice 1 foundation | Implemented foundation; full requirement partially implemented | Central 23-kind vocabulary; original lexeme, separate normalized presence/content, mandatory source range. No lexer or keyword recognition is implemented or claimed. | Independent local static inspection and meaningful authored assertions; tests not executed. |

Cross-cutting constraints were checked: abapGit layout/names (ASL-PROD-023), apparent release-compatible syntax (ASL-PROD-024/026), repository boundary (ASL-PROD-028), and authored behavior tests (ASL-PROD-044). No full language/runtime requirement is declared complete.

Contract inspection confirms private construction, public final classes, private state and no setters. Factories validate before returning objects. Coordinates must be positive; ranges use line-major ordering, reject reversed endpoints and allow zero width. Immutable endpoint references do not expose mutation. Tokens require valid centrally defined kinds and bound ranges; lexemes are copied without trimming/case folding. Normalized absence is separate from content. Diagnostics validate severity/code and represent absent location by an unbound reference. Tests compare scalar accessor values; no object-identity equality contract is needed for this slice. Containers intentionally do not check coordinates against a source string.

The complete diff has 25 files: seven class source/XML/test triplets plus questions, decisions, implementation status and review. Object names are 16–22 characters, within the 30-character limit. No lexer, parser/AST, formatter, execution, adapter, BSP/HTTP, persistence, write-back or SAP-side implementation was added. Implementation tracking reconciles to 218 requirements: 217 Planned, one Review required, zero Done. It accurately labels partial source delivery and pending SAP/ABAP Unit checks. Q-012 is the only added question; previous answers were not ignored. The unchanged README documentation-only wording predates this slice and is not a new regression.

## Verification performed

| Category | Actual result |
| --- | --- |
| Repository inspection | Checked branch, working tree, main/merge base, all seven branch-only commits and complete diff. Inspected current implementation/metadata/tests and changed documentation against the specification, requirements, architecture and other required documents read in the original review. Verified every finding, including earlier fixes. |
| Local static checks | `git diff --check main HEAD` passed. XML/name/companion/serializer/flag checks passed; final class XML check reported zero issues. Confirmed seven test includes, 45 authored methods, 23 centralized kinds and independent expected-name assertions. Inspected invariants, visibility, release syntax and regression sensitivity. |
| Locally executed tests | Not run. No local ABAP runtime, installed abaplint, lint configuration, package manifest or applicable test runner is available. PowerShell checks are static checks, not ABAP tests. No dependencies were installed. |
| abapGit structure checks | Parsed class/package/repository XML and checked source/XML names, test companions, layout and flags. Actual SAP import: Not run. |
| ADT source inspection | One read-only `getObjectSource` request for `CL_ABAP_UNIT_ASSERT` failed; no source was returned or relied upon. Historical initial-review standard exception/package reads are supporting evidence only. No other ADT operation was performed in this re-review. |
| SAP syntax check | Not run. No available syntax-tool guarantee established that a check would be non-mutating; no source upload occurred. Static inspection found no obvious post-7.52 syntax, which is not compilation proof. |
| SAP activation | Not run; no SAP changes authorized or performed. |
| ABAP Unit | Not run. Authored methods are not executed tests. |
| BPC integration tests | Not run; excluded and unnecessary for these independent contracts. |
| Repository boundary | bpcIO was clean before and after inspection, using command-scoped safe.directory for read-only status. Its configuration and files were not modified. |

No SAP create, modify, lock, activation, transport, configuration or SAP-side abapGit operation occurred. No credentials or connection configuration are recorded here.

## SAP validation still required

Under separate authorization for SAP changes:

1. Confirm target ABAP/NetWeaver 7.52 and actual abapGit version.
2. Import all seven classes into the intended package; verify package assignment, generated class/test includes and WITH_UNIT_TESTS flags. Confirm discovery of all 45 authored methods.
3. Syntax-check every main source and test include, including functional chaining, exception construction, IS SUPPLIED, string templates/helpers and regex behavior.
4. Activate the complete dependency set and test includes, recording activation separately from syntax results.
5. Execute all seven ABAP Unit classes. Verify empty-value presence, whitespace retention, range validation, kind names and diagnostic boundaries. Verify UTF-16/STRLEN behavior for combining and supplementary input on the target release against ADR-022. Producer normalization/counting execution remains future lexer work.

BPC integration tests belong to later adapter/runtime slices.

## Unresolved questions

- Q-012: Resolved, Blocking: No. Explicit user approval is recorded consistently; it no longer blocks this slice.
- Q-011: Open, Blocking: Yes for production object creation. Does not block this local prototype review; resolve before creating production objects.
- Q-010: Open, Blocking: No. Final library vocabulary is later work, not a blocker for the generic token contract.
- Q-001–Q-009: Open with persistence/runtime/write-back/governance scopes outside this slice. No unanswered question blocks this source review.

## Conclusion

DeepSeek has corrected all identified local defects. Retain the partial implementation tracking and pending SAP labels. Arrange separately authorized 7.52 import, syntax, activation and ABAP Unit validation before claiming executable completion. No further Slice 1 source correction is required by this review; future work must continue under its own assigned scope.

Only `docs/AI-REVIEW.md` is updated and committed locally. Pre-existing untracked files remain untouched. No implementation edit, SAP change, branch switch, push or merge is performed. The review commit hash is reported separately.

## Follow-up review — OpenCode assertion and serialization fixes

- Date: 2026-10-02
- Reviewed HEAD: `5de1309`; additional commits `26ae9cb` and `5de1309` above previous review commit `2db197e`.
- Verdict: **APPROVED** for these local corrections, with one LOW helper finding. Successful SAP execution remains unverified.
- User-provided SAP evidence: screenshot shows failures in PRESERVES_TRAILING_SPACE and PRESERVES_WHITESPACE_LEXEME. This is evidence that the previous suite did not pass, not evidence of a complete 45-test result or of the latest fixes passing. The earlier source approval did not certify SAP execution.
- Assertion correction: both final-character expectations now use the string template `| |` instead of the text-field literal `' '`. Actual and expected values now both represent strings containing one space. Content and length assertions remain intact. This corrects the identified type mismatch without changing token storage. Failure details were not supplied, so the screenshot alone does not establish that this was the only runtime cause.
- Serialization correction: seven class metadata files now have BOMs; all 14 ABAP main/test sources have no BOM and CRLF with one final CRLF. Repository/package XML also conforms. Independent raw Git-blob inspection checked all 23 committed ABAP/XML files, validated strict UTF-8 and BOM/EOL rules, and compared normalized content with `2db197e`: only the two assertion expressions changed. Production logic and XML object metadata are otherwise unchanged.
- Git attributes: `*.abap -text` and `*.xml -text` disable normalization, and `git check-attr` confirms these settings. Current metadata/source file coverage is appropriate; future BSP content serialization requires its own rules rather than treating every XML file as metadata.
- Local checks actually executed: default PowerShell helper checked 23 working files with zero violations; independent Node raw-blob checks passed; `git -c core.whitespace=cr-at-eol diff --check 2db197e HEAD` passed. The CR-aware setting is necessary for deliberately stored CRLF and is not a test execution. bpcIO status remains clean.
- No ADT operation, SAP syntax check, activation, ABAP Unit or BPC integration test was performed in this follow-up. No implementation source was edited by the reviewer.

### REVIEW-006 — Repair mode leaves lone CR line endings unchanged

- Severity: LOW
- Status: Open
- Requirements: supporting abapGit serialization tooling; ASL-PROD-023.
- File: `tools/check-abapgit-bytes.ps1`
- Line: 41–47 (`Convert-ToCrlf`); repair branch at 116–119.
- Problem: The CR branch appends LF only when LF already follows CR. A lone CR is preserved. Repair mode writes the result without rerunning validation, so it can print FIXED while the file still violates its own rules.
- Consequence: The helper cannot repair every detected line-ending violation. Current committed files are valid, so this does not block importing the reviewed correction.
- Required correction: Convert lone CR to CRLF as well as lone LF, and validate the repaired bytes before reporting success; fail if a violation remains.
- Verification required: Pure-function cases for CR-only and mixed line endings, plus revalidation of repaired bytes. The reviewer executed an in-memory A/CR/B case through Fix-Bytes and Get-Violations and reproduced `non-CRLF line ending`; no repository fixture or source was changed.

Next action: push/pull these corrected implementation commits through the authorized workflow and rerun all 45 tests in SAP. Record actual discovery, failure and execution results before marking SAP validation complete. OpenCode may address REVIEW-006 separately; no further production-code correction is established by this follow-up.
## Serialization correction after SAP round-trip evidence

The prior CRLF approval was incorrect for the installed serializer. Read-only ADT
searchObject located ZCL_ABAPGIT_OBJECTS_FILES; getObjectSource read that class,
ZCL_ABAPGIT_CONVERT, ZCL_ABAPGIT_DOT_ABAPGIT and ZCL_ABAPGIT_XML. ABAP uses LF
plus one final newline without BOM; metadata explicitly uses a BOM. XML rendering
is delegated to iXML and was not executed. XML LF restoration requires SAP
round-trip confirmation, as documented in ABAPGIT-SERIALIZATION.md.

Repository ABAP/XML line endings were converted to LF with existing BOM policies
preserved. Normalized source/XML contents are unchanged. The checker now uses
strict UTF-8 decoding and revalidates repairs; eight in-memory empty/LF/CR/CRLF
cases with both BOM policies passed, including idempotence. REVIEW-006 is Resolved.
Working-file byte checks (23 files) and git diff --check passed. No SAP changes,
syntax checks, activations or test executions occurred. The user screenshot's
zero-test result is not accepted as a passing suite. SAP XML refresh and all 45
ABAP Unit methods still require validation; do not infer that line endings alone
explain the discovery failure. bpcIO remains unchanged and clean.

## Follow-up review — VERSION metadata correction (2026-10-03)

- Reviewed commit: `b9811ce681ac18c508d20058c9c3d29525bd6851` on
  `feature/asl-001-token-diagnostics`, parent `1387d76`.
- Verdict: APPROVED for the local serialization-only correction. Actual SAP
  export/round-trip confirmation is pending; this is not a claim of a clean
  SAP comparison for all seven objects.
- Independently inspected complete commit diff: seven class XML files each
  delete only `<VERSION>1</VERSION>`. No source/test changes or unrelated edits.
- Checks executed: XML parse, filename/CLSNAME consistency, WITH_UNIT_TESTS=X
  in all seven files; worktree checker (23 files, zero violations); independent
  HEAD blob strict UTF-8/BOM/LF/final-newline checks (23 passed);
  `git diff --check 1387d76 b9811ce` passed. bpcIO status remains clean.
- Actual export: Not obtained. Available ADT tools expose no abapGit export
  operation. A read-only getObjectSource request for
  ZCL_ABAPGIT_OBJECT_CLAS failed and returned no usable source. No source or
  export claim from the implementation agent is treated as independent proof.
  The user's SAP DIAG diff does independently show omission of VERSION for
  that class only. Refresh/export all seven classes to confirm exact equality.
- ABAP Unit: User-provided later screenshot says completed with 0 errors
  (8 objects, 0.05 seconds). This supersedes treating the earlier zero-discovery
  screen as the latest known result. The screenshot does not expose all 45
  methods or identify the eighth object. No new run or reproduction was
  performed by Codex. Active includes, even if confirmed, would not alone
  prove the historical discovery failure's cause; stale scope/state remains
  a hypothesis, not an established diagnosis.
- No SAP write, activation, syntax check, ABAP Unit execution or integration
  operation was performed in this follow-up. Slice 2 and BSP remain excluded.

Next: confirm b9811ce is pushed, refresh the seven objects in SAP and inspect
any remaining differences. Obtain the full successful test list/count if
recording all 45 methods as passed. Investigate discovery only if a fresh run
reproduces it; do not repeat fixes for an unreproduced historical result.
