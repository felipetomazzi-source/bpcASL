# AI Review — Phase 0 Slice 1

## Review metadata

- Reviewer: Codex
- Date: 2026-10-02 (Pacific/Auckland)
- Branch: `feature/asl-001-token-diagnostics`
- Base: `main`, `9c696f9248b46dc9a8931cd367aa5c3b86c023a3`; also the merge base.
- Reviewed commits: `6c31f5f097bceae284bb48a70d521444dcdc594f` — the only commit reachable from this branch but not main.
- Requirements: partial ASL-OPS-001 (§31) and foundation for ASL-LANG-001 (§8). These are the slice mappings recorded by the commit and changed implementation-status rows, checked against the requirements themselves. No separate authoritative Slice 1 allocation exists. ASL-PROD-023, ASL-PROD-024, ASL-PROD-026, and ASL-PROD-028 are cross-cutting constraints; ASL-PROD-044/§36 governs testing. ASL-UI-003 and ASL-API-005 are downstream consumers, not UI/HTTP deliverables in this slice.
- SAP validation status: read-only ADT inspection performed; slice syntax, activation, import, and ABAP Unit not run. The user confirmed the ADT connection is the intended one; this review did not independently establish its release.
- Initial working tree: tracked files clean, with pre-existing untracked `AGENTS.md` and `docs/CODEX-HANDOFF.md`. It was not a clean working tree. Accordingly, no review commit is created under the user's conditional instruction.

## Verdict

**CHANGES REQUIRED**

Two HIGH, two MEDIUM, and one LOW findings remain open. No BLOCKER finding is established. The review can reach a concrete verdict without waiting for SAP execution, because the metadata defect and empty-value defect are directly evident in the repository.

## Findings

### REVIEW-001 — abapGit metadata drops all local test classes

- Severity: HIGH
- Status: Resolved
- Requirements: ASL-PROD-023; ASL-PROD-044/§36; Slice 1 executable contract tests.
- File: all seven `src/zcl_bpc_asl_*.clas.xml` files, including `src/zcl_bpc_asl_token.clas.xml`.
- Line: 5 (`VSEOCLASS`), with the missing flag apparent before its closing tag at line 14.
- Problem: Every class has a nonempty `.clas.testclasses.abap` companion, but none declares `<WITH_UNIT_TESTS>X</WITH_UNIT_TESTS>`. This is functional metadata, not merely descriptive XML. The inspected upstream [abapGit class deserializer](https://github.com/abapGit/abapGit/blob/main/src/objects/zcl_abapgit_object_clas.clas.abap) clears the supplied local test-class source when that property is false (`deserialize_abap`, lines 207–210 of the inspected source).
- Consequence: With that importer behavior, all 24 authored tests are discarded on import, so an apparently successful import or empty test run would not verify the slice. The installed importer version has not been tested.
- Required correction: Set the unit-test flag consistently for all seven classes, retaining the test includes and the existing matching object names.
- Verification required: Repeat the XML consistency check; later, under separate SAP-change authorization, import using the actual abapGit version, verify each generated local test include and all test methods are discoverable, and execute ABAP Unit. Do not count a run with zero discovered tests as success.
- Resolution: Added `<WITH_UNIT_TESTS>X</WITH_UNIT_TESTS>` to all seven `src/zcl_bpc_asl_*.clas.xml` files, retaining the test includes and existing object names.
- Evidence: PowerShell XML parse confirms all 7 files are well-formed, `CLSNAME` matches each filename, and `WITH_UNIT_TESTS=X` is present in each; `git diff --check` clean. SAP import/ABAP Unit remain pending.
- Correction commit: `1ee507f`

### REVIEW-002 — Empty normalized value is indistinguishable from absence

- Severity: HIGH
- Status: Resolved
- Requirements: ASL-LANG-001 foundation; Slice 1 optional normalized-value contract. §9.1's empty-text distinction is supporting context, not an assigned type-system deliverable.
- File: `src/zcl_bpc_asl_token.clas.abap`
- Line: 107; also lines 7–10, 27, 72, and 94.
- Problem: `has_value` derives presence from `mv_value IS NOT INITIAL`. Supplying an empty string as `iv_value` therefore gives the same observable value/presence pair as omitting `iv_value`. For example, a STRING token with original lexeme `""` and explicitly supplied empty decoded content reports `has_value = abap_false`, although it has a normalized value. The header explicitly documents this lossy convention.
- Consequence: Future lexer/parser consumers cannot distinguish absent normalized data from valid empty decoded text. The token representation does not fulfill its optional-value contract for a valid literal.
- Required correction: Store presence separately from the string content. For example, capture `iv_value IS SUPPLIED` in the factory and retain it as a private boolean, or use an explicit presence parameter with a documented invariant. Preserve the original lexeme and allow a present empty value.
- Verification required: ABAP Unit cases for omitted value, explicitly supplied empty value, nonempty value, and numeric text `0`; verify both accessors and original lexeme preservation. These must test the token object without implementing a lexer.
- Resolution: Added a private `mv_has_value` boolean set from `iv_value IS SUPPLIED` in the factory; `has_value` now returns that flag, so an explicitly supplied empty string is distinguishable from an omitted value. Header comment updated accordingly.
- Evidence: Added `create_with_empty_value` and `numeric_zero_value` ABAP Unit cases (alongside the existing omitted/nonempty cases). Static inspection only; ABAP Unit execution pending (no local runtime).
- Correction commit: `1ee507f`

### REVIEW-003 — Source-coordinate contract remains unresolved and underspecified

- Severity: MEDIUM
- Status: Resolved
- Requirements: ASL-OPS-001; ASL-LANG-001 foundation; downstream ASL-UI-003/ASL-API-005; AGENTS.md questions protocol.
- File: `docs/AI-QUESTIONS.md`; `src/zcl_bpc_asl_src_pos.clas.abap`; `src/zcl_bpc_asl_src_range.clas.abap`
- Line: 352 (Q-012), 3 (position convention), and 3 (range convention), respectively.
- Problem: Q-012 is still Open and Blocking: Yes, with finalizing the coordinate contract explicitly blocked. The classes and tests adopt its recommendation, so provisional implementation is disclosed rather than silently hidden, but final acceptance of this slice's source contract lacks an agreed decision. In addition, neither class defines the column counting unit or treatment of tabs and line endings. A Unicode column may mean string indexing units, Unicode scalar values, or display cells; these are not interchangeable. The position header also presents §29 as establishing 1-based coordinates while Q-012 acknowledges that it does not formally do so.
- Consequence: Later lexer/parser/editor implementations can interpret the same range differently, particularly for non-ASCII text, combining characters, supplementary characters, tabs, or CRLF input. Positive coordinates and ordered endpoints alone do not settle that contract.
- Required correction: Obtain and record an explicit answer to Q-012 before declaring the contract accepted. Extend the decision/question evidence to cover column units, tab counting, LF/CRLF handling, and the policy for supported Unicode input. Align comments and tracking with the agreed convention. Work on independent corrections can continue while this decision is pending; the reviewer is not choosing the answer.
- Verification required: Contract examples for first character, insertion/EOF positions, a one-character half-open range, multiline ranges, tabs, line endings, non-ASCII text, and the selected supplementary-character policy. Validate the relevant ABAP string behavior on 7.52 when SAP tests are authorized. Lexer execution and HTTP serialization remain later-slice work.
- Resolution: Corrected the §29 overclaim in both SRC_POS and SRC_RANGE headers (no longer asserting §29 formally establishes 1-based coordinates) and extended Q-012 to enumerate all five sub-questions (base/end, column unit, tabs, CRLF, supplementary characters) with options and a recommendation. The coordinate DECISION itself is not made here — it remains Open/Blocking (Q-012) as a user/customer decision this agent may not resolve; the classes now disclose the provisional convention and full decision scope.
- Evidence: AI-QUESTIONS.md Q-012 and both class headers reviewed; no decision fabricated.
- Correction commit: `1ee507f`

### REVIEW-004 — Tests omit essential range and vocabulary behavior

- Severity: MEDIUM
- Status: Resolved
- Requirements: ASL-OPS-001; ASL-LANG-001 foundation; ASL-PROD-044/§36; Slice 1 behavior tests.
- File: `src/zcl_bpc_asl_src_range.clas.testclasses.abap`; `src/zcl_bpc_asl_src_pos.clas.testclasses.abap`; `src/zcl_bpc_asl_token_kind.clas.testclasses.abap`; `src/zcl_bpc_asl_token.clas.testclasses.abap`
- Line: 6–9, 6–8, 14, and 6–10, respectively.
- Problem: Range tests cover same-line validity/reversal, zero width, and one invalid start line, but never exercise the different-line ordering branch. A regression that ignores line numbers or compares columns across different lines would escape them. Negative positions and invalid end coordinates are also absent. `every_kind_valid` checks only nine of the 23 kinds; most comparison/arithmetic/punctuation entries are untested. Token fixtures contain only ASCII keywords and a semicolon, leaving quoted case, authored whitespace, Unicode text, and EOF representation unverified. The empty-value regression is addressed separately in REVIEW-002.
- Consequence: Meaningful invariant regressions can pass the authored suite even after the import metadata is fixed. Test names overstate vocabulary coverage.
- Required correction: Add behavioral cases for an earlier end line despite a larger column, a later end line despite a smaller column, invalid/negative endpoint coordinates, and all supported kinds with explicit expected public names and uniqueness. Add token preservation fixtures for quoted mixed-case text, whitespace using actual string values, Unicode, and the documented EOF policy. No lexer/parser implementation is needed.
- Verification required: Verify the new cases would fail for incorrect line ordering, a missing kind, a duplicated kind value, trimming/case-folding of lexemes, and invalid endpoint acceptance. Run the complete imported ABAP Unit suite later; source inspection alone is not execution.
- Resolution: Added range-ordering cases (earlier end line with larger column → rejected; later end line with smaller column → accepted), negative start-column/end-line rejection, full 23-kind validity plus uniqueness checks (sort + delete-adjacent-duplicates), and token preservation fixtures (quoted mixed-case, authored whitespace, non-ASCII Unicode, and EOF zero-width policy).
- Evidence: ABAP Unit method count grew from 24 to 40; token-kind constants verified unique (23) by script. Static inspection only; ABAP Unit execution pending.
- Correction commit: `1ee507f`

### REVIEW-005 — Diagnostic prefix policy and validator disagree

- Severity: LOW
- Status: Resolved
- Requirements: ASL-OPS-001 stable-code convention; downstream ASL-API-005.
- File: `src/zcl_bpc_asl_diag_code.clas.abap`; `docs/DECISIONS.md`
- Line: 48; ADR-021 at line 190.
- Problem: ADR-021 reserves first segments `LEX`, `SYN`, `SEM`, `RUN`, and `SYS` per layer, but the validator accepts any uppercase first segment, such as `FOO_BAR` or `UNKNOWN_PROPERTY`. Its regex enforces string shape, not the described category policy. The tests do not clarify whether this broader acceptance is intentional.
- Consequence: Callers cannot rely on validation to guarantee a category prefix; future layers can introduce inconsistent namespaces. The documented no-renaming rule does provide a stability convention, so the absence of a populated code registry is not itself a finding in this slice.
- Required correction: Clarify whether the method validates only shape or the reserved namespace as well. If prefix enforcement is intended, enforce the agreed prefixes; otherwise explicitly document shape-only validation and how category ownership is enforced.
- Verification required: Cases for all permitted prefixes, an unknown prefix, repeated/trailing underscores, digit-leading codes, and the maximum-length boundary, consistent with the clarified policy.
- Resolution: Documented `is_valid` as shape-only (not a prefix allowlist) in the class header, because §29's example code (`UNKNOWN_PROPERTY`) is unprefixed; clarified ADR-021 accordingly. Added tests for all five prefixes, unprefixed codes (`UNKNOWN_PROPERTY`, `FOO_BAR`), repeated/trailing underscores, digit-leading codes, and the 60/61 length boundary.
- Evidence: `ZCL_BPC_ASL_DIAG_CODE` header and `docs/DECISIONS.md` ADR-021 updated; expanded test class covers the clarified policy.
- Correction commit: `1ee507f`

## Requirement coverage

| Requirement | Status | Evidence | Verification level |
| --- | --- | --- | --- |
| ASL-OPS-001, Slice 1 portion | Partially implemented | Severity constants/predicates; diagnostic code-shape validator and ADR-021; structured diagnostic with optional immutable range; positive source coordinates and ordered ranges. Stage, partition, and correlation ID explicitly deferred to runtime. REVIEW-001/003/004 affect verification and contract acceptance. | Complete local source/metadata inspection; read-only standard exception signature inspection. No SAP syntax or executable behavior validation. |
| ASL-LANG-001, Slice 1 foundation | Partially implemented | Central 23-kind vocabulary; token kind, original string lexeme, normalized string, and mandatory bound range. Factory copies lexeme without normalization or trimming. REVIEW-002 breaks present-empty values. No lexer or actual case-insensitive recognition exists or is claimed. | Local static inspection and authored tests inspected; tests not executed. |

No full requirement is marked implemented by this review. The phase document assigns broad Phase 0 requirements, not all of them to Slice 1. Type checking, parsing, execution, adapters, UI, and HTTP coverage are not required here.

Cross-cutting checks:

- ASL-PROD-023: seven correctly paired class source/XML/test filenames in `/src/`, matching `CLSNAME` and source definitions; package configuration present. Actual class package assignment requires import verification.
- ASL-PROD-024/026: no obvious post-7.52 syntax found. Explicit DATA declarations, CREATE OBJECT, CASE, relational conditions, functional method calls/chaining, exceptions, and FIND REGEX are used. This is a static compatibility assessment, not proof of compilation.
- ASL-PROD-028/repository boundary: bpcIO status was clean before and after inspection; no source or configuration was changed there. The first status attempt hit Git ownership protection; the subsequent read used command-scoped `-c safe.directory=...`, without changing Git configuration.
- ASL-PROD-044/§36: seven test includes with 24 test methods are authored. REVIEW-001 prevents relying on their import, and REVIEW-004 identifies meaningful coverage gaps.

Other contract observations:

- All seven classes are PUBLIC FINAL CREATE PRIVATE. Four value-object factories validate before allocating the result; state is private and no setters are exposed. Returned position/range references point to similarly immutable objects. Strings are returned by value. No public mutation path was found.
- Positions reject every integer below one, including negative values, by inspection. Ranges validate both endpoints and compare line before column; equal endpoints are allowed. End exclusion is documented consistently in range/token headers, but no slicing operation exists yet to demonstrate it. Bounds against a particular source buffer are not possible with these source-independent objects and are not required here.
- Token factories reject unknown kinds and unbound ranges. They accept caller-provided normalized strings without computing or validating normalization. Clarify caller responsibilities as lexer work begins; the keyword test demonstrates storage of supplied normalization, not normalization execution. Generic KEYWORD plus normalized value is usable by a future parser. Dates and trivia emission policy remain lexer design work rather than execution implemented here.
- Severity is restricted to exact INFO/WARNING/ERROR values. Diagnostic location absence uses reference binding and is distinguishable from a zero-width location. Diagnostic messages and codes are copied as strings.
- No value-equality or ordering API is exposed for positions/ranges/tokens. Existing tests compare primitive getters, so a distinct object identity does not prevent meaningful assertions. No assigned requirement demands an `equals` method. Structural comparison should remain explicit if introduced later.
- Class names are 16–22 characters, below the 30-character class-name limit. XML parses and uses CLAS serializer, English language, class-pool include, fixed-point and Unicode flags. The missing unit-test flag is the substantive metadata defect found.
- Implementation-status totals reconcile: 218 requirements, 217 Planned and one Review required. ASL-OPS-001 explicitly says partial and SAP/ABAP Unit pending; ASL-LANG-001 stays Planned with a foundation note. No SAP success claim exists. However, “optional source location delivered” should remain qualified by Q-012 and the review findings. README's documentation-only statement is stale but unchanged from main, so it is not an unrelated slice regression.
- The full branch diff comprises 24 files: the seven class triplets plus `docs/AI-QUESTIONS.md`, `docs/DECISIONS.md`, and `docs/IMPLEMENTATION-STATUS.md`. There are no lexer/parser/runtime/adapters/BSP/HTTP/persistence/write-back files and no unrelated implementation changes. Q-012 is the only question added; previous questions were not changed. ADR-021 adds the code convention. Recorded evidence is source/test artifacts and pending-validation labels, not an executable test log.

## Verification performed

| Verification category | Performed and result |
| --- | --- |
| Repository inspection | Read AGENTS.md, README, specification, requirements, architecture, decisions, implementation status, test plan, questions, and Phase 0 document completely, with chunked follow-up reads. Inspected recent history, the sole branch-only commit, full diff, every changed source/test/XML file, and the pre-existing handoff. Checked branch and working-tree status. |
| Local static checks | `git diff --check main HEAD` passed. PowerShell XML/name/source pairing and metadata checks passed except seven missing unit-test flags. Corrected the review script's initial overly broad table-row filter, then independently counted 218 requirement rows and reconciled status totals. Counted seven test includes and 24 test methods. Inspected test inputs/assertions and all factory guards. |
| Locally executed tests | Not run. No local ABAP runtime, installed `abaplint` command, lint configuration, package manifest, or test runner was found. Node/npm are available but do not execute these ABAP tests; no dependencies were installed or speculative runner created. The PowerShell checks are static checks, not ABAP execution. |
| abapGit structure checks | Parsed all seven class XML files, package XML and `.abapgit.xml`; verified lowercase suffixes, matching object names, source/test companions, `/src/` folder, serializer and flags. Inspected upstream importer source supporting REVIEW-001. Actual abapGit import: Not run. |
| ADT source inspection | `healthcheck` once; `searchObject` for CX_PARAMETER_INVALID_RANGE, ZBPC_ASL (DEVC), and ZCL_BPC_ASL_* (CLAS); `getObjectSource` for complete CX_PARAMETER_INVALID_RANGE and the first 32 lines of CX_PARAMETER_INVALID. Confirmed PARAMETER is an optional STRING constructor argument and the parent inherits CX_DYNAMIC_CHECK. Package `nodeContents` completed on retry after one cancelled call. Package exists; returned contents include ZCL_ASL_BSP_SETUP. Wildcard class search returned no slice classes. Bootstrap source was not read or reviewed. |
| SAP syntax check | Not run. Exposed syntax-tool descriptions do not explicitly guarantee no change/activation, as required by the review instruction. No source was uploaded for checking. |
| SAP activation | Not run; not authorized. |
| ABAP Unit | Not run; no slice objects imported or activated by this review. |
| BPC integration tests | Not run; excluded and unnecessary for these BPC-independent contracts. |

No SAP create, modify, lock, activation, transport, configuration, write operation, or SAP-side abapGit operation was performed. Connection details and credentials are not included in this review.

## SAP validation still required

After corrections and separate authorization for SAP changes:

1. Verify the development system's NetWeaver/ABAP release is 7.52 and record the actual abapGit version.
2. Import the seven class objects into ZBPC_ASL; verify each class's package, generated class-pool/test include, and WITH_UNIT_TESTS property. Confirm all intended tests are discoverable.
3. Syntax-check all seven main sources and their local test includes on 7.52, including method chaining, the regex, exception construction, and any presence-tracking correction.
4. Activate the complete class dependency set and test includes, recording the actual results separately from syntax checks.
5. Run all ABAP Unit classes, including the corrected empty-value regression and new invariant/preservation cases. Verify Unicode/string and regex boundary behavior against the agreed contracts.

No BPC integration test is needed to accept Slice 1; adapter and integration validation belong to later slices.

## Unresolved questions

- Q-012: Open, Blocking: Yes. Blocks final acceptance of the source-coordinate contract, not independent repairs. Recommendation is not a recorded answer. The user confirmed the MCP connection, not the indexing/range decision.
- Q-011: Open, Blocking: Yes for production object creation. Does not block this local prototype review; working names fit the naming limit. Resolve before production object creation.
- Q-010: Open, Blocking: No. Does not block the generic token representation; final library vocabulary belongs to later work.
- Q-001..Q-009: Still open, with the recorded blocking scopes relating to persistence/runtime/write-back/governance rather than this slice. No ignored answer relevant to Slice 1 was found.

## Conclusion

DeepSeek must correct the seven class XML test flags and separate token value presence from content, add the missing behavioral tests, and obtain/document the source-coordinate decision before presenting the contracts as accepted. Clarify the diagnostic prefix policy. Keep status partial and all unperformed SAP checks pending; request a new independent review after the corrections. Do not begin excluded implementation to address these findings.

This review changes only `docs/AI-REVIEW.md`. No implementation was repaired, no branch was switched, and nothing was pushed or merged. Review commit hash: not applicable, because the working tree was already unclean at review start.
