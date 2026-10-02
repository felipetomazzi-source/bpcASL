# AI Review — Phase 0 Slice 1

## Review metadata

- Reviewer: Codex
- Date: 2026-10-02 (Pacific/Auckland), independent re-review.
- Branch: `feature/asl-001-token-diagnostics`
- Base: `main`, `9c696f9248b46dc9a8931cd367aa5c3b86c023a3`; also the merge base.
- Reviewed commits: `6c31f5f097bceae284bb48a70d521444dcdc594f` (initial implementation), `1ee507f01ff07afc627db41173491afd16067342` (corrections), and `067a0069bb21d3d3228655a04c59548a1c2f1fa1` (implementation-agent review edits). These are all commits reachable from the reviewed HEAD but not main.
- Requirements: partial ASL-OPS-001 (§31) and foundation for ASL-LANG-001 (§8). These are the slice mappings recorded by the commit and changed implementation-status rows, checked against the requirements themselves. No separate authoritative Slice 1 allocation exists. ASL-PROD-023, ASL-PROD-024, ASL-PROD-026, and ASL-PROD-028 are cross-cutting constraints; ASL-PROD-044/§36 governs testing. ASL-UI-003 and ASL-API-005 are downstream consumers, not UI/HTTP deliverables in this slice.
- SAP validation status: no ADT operations or SAP checks performed in this re-review. The first review's read-only standard exception/package inspection remains historical evidence, not compilation or execution validation. Import, slice syntax, activation, and ABAP Unit remain Not run.
- Initial working tree: tracked files/index clean, with pre-existing untracked `AGENTS.md` and `docs/CODEX-HANDOFF.md`. These remain untouched. The current user explicitly requests a local review commit, superseding the first review's clean-tree condition.
- Evidence rule: statuses below are independently checked against current files. Resolved means the particular local source/documentation defect is corrected, not that SAP validation succeeded. Original Problem/Consequence paragraphs are retained as historical context; re-review evidence records the current state.

## Verdict

**CHANGES REQUIRED**

REVIEW-001, REVIEW-002, and REVIEW-005 are resolved at the local source/static level. REVIEW-003 and REVIEW-004 remain Open, both MEDIUM. No open BLOCKER, HIGH, or LOW finding is established. Q-012 still has no accepted answer, and the test correction leaves meaningful gaps. Commit `067a006` prematurely marked those two findings resolved; this re-review corrects their statuses. No additional production-code regression was found in the complete diff from main.

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

- Independent re-review evidence: All seven class XML files parse and now declare WITH_UNIT_TESTS=X at line 14. Source/XML/filename names, companion test files, serializer and existing flags match; the local metadata check reports zero issues. This closes the metadata omission. Actual SAP import, generated test discovery and execution remain pending; the reviewed branch now authors 40 tests.

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

- Independent re-review evidence: Current token source lines 75 and 98–104 retain private presence separately from content; lines 115–116 return that flag. The empty-value test at line 120 asserts present-empty content and preserved `""` lexeme; the numeric-zero case at line 144 asserts present `0`. Omitted and nonempty cases remain. The old implementation would fail the authored explicit-empty presence assertion, so the source fix and regression case are meaningful. No ABAP execution is claimed.

### REVIEW-003 — Source-coordinate contract remains unresolved and underspecified

- Severity: MEDIUM
- Status: Open
- Requirements: ASL-OPS-001; ASL-LANG-001 foundation; downstream ASL-UI-003/ASL-API-005; AGENTS.md questions protocol.
- File: `docs/AI-QUESTIONS.md`; `src/zcl_bpc_asl_src_pos.clas.abap`; `src/zcl_bpc_asl_src_range.clas.abap`
- Line: 354 (Q-012), 3 (position convention), and 3 (range convention), respectively.
- Problem: Q-012 is still Open and Blocking: Yes, with finalizing the coordinate contract explicitly blocked. The classes and tests adopt its recommendation, so provisional implementation is disclosed rather than silently hidden, but final acceptance of this slice's source contract lacks an agreed decision. In addition, neither class defines the column counting unit or treatment of tabs and line endings. A Unicode column may mean string indexing units, Unicode scalar values, or display cells; these are not interchangeable. The position header also presents §29 as establishing 1-based coordinates while Q-012 acknowledges that it does not formally do so.
- Consequence: Later lexer/parser/editor implementations can interpret the same range differently, particularly for non-ASCII text, combining characters, supplementary characters, tabs, or CRLF input. Positive coordinates and ordered endpoints alone do not settle that contract.
- Required correction: Obtain and record an explicit answer to Q-012 before declaring the contract accepted. Extend the decision/question evidence to cover column units, tab counting, LF/CRLF handling, and the policy for supported Unicode input. Align comments and tracking with the agreed convention. Work on independent corrections can continue while this decision is pending; the reviewer is not choosing the answer.
- Verification required: Contract examples for first character, insertion/EOF positions, a one-character half-open range, multiline ranges, tabs, line endings, non-ASCII text, and the selected supplementary-character policy. Validate the relevant ABAP string behavior on 7.52 when SAP tests are authorized. Lexer execution and HTTP serialization remain later-slice work.
- Partial correction: Corrected the §29 overclaim in both SRC_POS and SRC_RANGE headers and extended Q-012 to enumerate base/end, column unit, tabs, CRLF and Unicode questions. This improves disclosure; it does not obtain the decision required by the finding.
- Evidence: AI-QUESTIONS.md Q-012 and both class headers reviewed; no decision fabricated.
- Correction commit: `1ee507f`

- Independent re-review evidence: Q-012 at lines 354–411 still says Status: Open and Blocking: Yes. Source headers explicitly say the contract is not accepted. The implementation-status row correctly qualifies semantics as provisional. No accepted answer, agreed contract examples, or SAP Unicode/string behavior evidence was added. The implementation agent's Resolved label is unsupported. REVIEW-003 remains open until the explicit decision and required examples exist; independent repairs can continue. The user confirmed the MCP connection, not the coordinate convention.

### REVIEW-004 — Tests omit essential range and vocabulary behavior

- Severity: MEDIUM
- Status: Open
- Requirements: ASL-OPS-001; ASL-LANG-001 foundation; ASL-PROD-044/§36; Slice 1 behavior tests.
- File: `src/zcl_bpc_asl_src_range.clas.testclasses.abap`; `src/zcl_bpc_asl_src_pos.clas.testclasses.abap`; `src/zcl_bpc_asl_token_kind.clas.testclasses.abap`; `src/zcl_bpc_asl_token.clas.testclasses.abap`
- Line: range declarations 6–13 and methods 101–123; token-kind fixtures/assertions 18–68; token whitespace fixture 183–199; position declarations 6–10.
- Problem: Range tests cover same-line validity/reversal, zero width, and one invalid start line, but never exercise the different-line ordering branch. A regression that ignores line numbers or compares columns across different lines would escape them. Negative positions and invalid end coordinates are also absent. `every_kind_valid` checks only nine of the 23 kinds; most comparison/arithmetic/punctuation entries are untested. Token fixtures contain only ASCII keywords and a semicolon, leaving quoted case, authored whitespace, Unicode text, and EOF representation unverified. The empty-value regression is addressed separately in REVIEW-002.
- Consequence: Meaningful invariant regressions can pass the authored suite even after the import metadata is fixed. Test names overstate vocabulary coverage.
- Required correction: Add behavioral cases for an earlier end line despite a larger column, a later end line despite a smaller column, invalid/negative endpoint coordinates, and all supported kinds with explicit expected public names and uniqueness. Add token preservation fixtures for quoted mixed-case text, whitespace using actual string values, Unicode, and the documented EOF policy. No lexer/parser implementation is needed.
- Verification required: Verify the new cases would fail for incorrect line ordering, a missing kind, a duplicated kind value, trimming/case-folding of lexemes, and invalid endpoint acceptance. Run the complete imported ABAP Unit suite later; source inspection alone is not execution.
- Partial correction: Added meaningful range-ordering cases, negative start-column/end-line rejection, full 23-kind validity and uniqueness checks, and quoted mixed-case/BMP Unicode/EOF token fixtures. These additions are credited; residual gaps below prevent closure.
- Evidence: ABAP Unit method count grew from 24 to 40; token-kind constants verified unique (23) by script. Static inspection only; ABAP Unit execution pending.
- Correction commit: `1ee507f`

- Independent re-review evidence and residual problem:
  - `preserves_whitespace_lexeme` supplies and expects the single-quoted text-field literal `'  SCRIPT '`. It does not establish preservation of trailing spaces in a real string. SAP's [ABAP literals documentation](https://help.sap.com/doc/43e4215eb12c497daaa58382a0411b17/7.51.4/en-US/bd03c01a63884d52bd81148b5ca6226d.html) explains that trailing blanks are ignored in text-field literals, whereas string literals retain them. Both fixture and expectation use the problematic literal, with no length or final-character assertion.
  - All 23 kinds now appear in the test list and are checked for validity/uniqueness, but no independent expected public string names are asserted. A unique-but-renamed constant value would pass both tests, contrary to the original correction request.
  - Range tests still omit zero/negative end columns. A regression that substitutes a valid column when constructing the end position could escape the suite; SRC_POS tests alone do not verify SRC_RANGE forwards that argument.
- Remaining correction: Use an actual string variable initialized with a backquoted literal or string template containing the trailing space. Assert exact contents, length nine, and the trailing character. Add independent expected name mappings for the 23 kinds and zero/negative end-column rejection cases. Keep the new meaningful cases; no lexer or production-code change is needed.
- Remaining verification: These cases must detect trailing-space removal, unique-but-renamed kind values, and lost end-column forwarding/validation. This review inspected the expected regression sensitivity but did not execute mutation tests or ABAP Unit. Forty authored methods are not forty executed tests.

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

- Independent re-review evidence: Source header lines 20–25 and ADR-021 agree on shape-only validation and category ownership by convention/review. The unchanged regex implements that scope. Tests include all recommended prefixes, unprefixed/unknown prefixes, invalid digit/case/underscore forms and 60/61-character boundaries. This closes the policy mismatch at the source/documentation level; actual regex execution on SAP remains pending.

## Requirement coverage

| Requirement | Status | Evidence | Verification level |
| --- | --- | --- | --- |
| ASL-OPS-001, Slice 1 portion | Partially implemented | Severity constants/predicates; diagnostic code-shape validator and clarified ADR-021; structured diagnostic with optional immutable range; positive coordinates and ordered endpoints. Stage/partition/correlation ID deferred. Q-012 and REVIEW-003/004 prevent final contract/test acceptance; XML test flags are corrected. | Independent current local source/XML/test inspection; earlier standard exception reads are historical evidence. No SAP syntax or executable behavior validation. |
| ASL-LANG-001, Slice 1 foundation | Partially implemented | Central 23-kind vocabulary; token kind, original lexeme, separate normalized presence/content, mandatory bound range. Factory copies lexeme without normalization/trimming; present-empty source defect corrected. No lexer/case recognition implemented or claimed. Residual REVIEW-004 preservation/name tests remain open. | Local static inspection and authored tests inspected; tests not executed. |

No full requirement is marked implemented by this review. The phase document assigns broad Phase 0 requirements, not all of them to Slice 1. Type checking, parsing, execution, adapters, UI, and HTTP coverage are not required here.

Cross-cutting checks:

- ASL-PROD-023: seven correctly paired class source/XML/test filenames in `/src/`, matching `CLSNAME` and source definitions; package configuration present. Actual class package assignment requires import verification.
- ASL-PROD-024/026: no obvious post-7.52 syntax found. Explicit DATA declarations, CREATE OBJECT, CASE, relational conditions, functional method calls/chaining, exceptions, and FIND REGEX are used. This is a static compatibility assessment, not proof of compilation.
- ASL-PROD-028/repository boundary: bpcIO status was clean before and after inspection; no source or configuration was changed there. The first status attempt hit Git ownership protection; the subsequent read used command-scoped `-c safe.directory=...`, without changing Git configuration.
- ASL-PROD-044/§36: seven test includes with 40 methods are authored, with corrected import flags. REVIEW-004 retains meaningful gaps. No discovery/execution evidence exists.

Other contract observations:

- All seven classes are PUBLIC FINAL CREATE PRIVATE. Four value-object factories validate before allocating the result; state is private and no setters are exposed. Returned position/range references point to similarly immutable objects. Strings are returned by value. No public mutation path was found.
- Positions reject every integer below one, including negative values, by inspection. Ranges validate both endpoints and compare line before column; equal endpoints are allowed. End exclusion is documented consistently in range/token headers, but no slicing operation exists yet to demonstrate it. Bounds against a particular source buffer are not possible with these source-independent objects and are not required here.
- Token factories reject unknown kinds and unbound ranges. They accept caller-provided normalized strings without computing or validating normalization. Clarify caller responsibilities as lexer work begins; the keyword test demonstrates storage of supplied normalization, not normalization execution. Generic KEYWORD plus normalized value is usable by a future parser. Dates and trivia emission policy remain lexer design work rather than execution implemented here.
- Severity is restricted to exact INFO/WARNING/ERROR values. Diagnostic location absence uses reference binding and is distinguishable from a zero-width location. Diagnostic messages and codes are copied as strings.
- No value-equality or ordering API is exposed for positions/ranges/tokens. Existing tests compare primitive getters, so a distinct object identity does not prevent meaningful assertions. No assigned requirement demands an `equals` method. Structural comparison should remain explicit if introduced later.
- Class names are 16–22 characters, below the 30-character limit; scanned class/method declarations do not exceed it. XML parses and uses CLAS serializer, English language, class-pool include, fixed-point, Unicode and now unit-test flags. The original missing unit-test flag is corrected.
- Implementation-status totals reconcile: 218 requirements, 217 Planned and one Review required. ASL-OPS-001 explicitly says partial and SAP/ABAP Unit pending; ASL-LANG-001 stays Planned with a foundation note. No SAP success claim exists. However, “optional source location delivered” should remain qualified by Q-012 and the review findings. README's documentation-only statement is stale but unchanged from main, so it is not an unrelated slice regression.
- The complete diff from main comprises 25 files: seven class triplets plus questions, decisions, implementation status and review. Current sources/tests/XML, cumulative documentation changes and all branch-only commits were inspected. No excluded lexer/parser/AST/formatter/runtime/adapters/BSP/HTTP/persistence/write-back implementation or unrelated implementation changes exist. Q-012 is the only added question; prior questions are unchanged. The review-edit commit's all-resolved claims and stale coverage text are corrected here. Recorded evidence remains authored source/tests and pending-validation labels, not execution logs.
- Regression inspection: The presence change retains private state, read-only access and original lexeme copying. Range guards/order, severity/diagnostic behavior and centralized vocabulary remain intact. Added IS SUPPLIED, string templates/concatenation, repeat and internal-table test helpers show no obvious post-7.52 syntax, but require real compilation. No new SAP API dependency was introduced.

## Verification performed

| Verification category | Performed and result |
| --- | --- |
| Repository inspection | Re-read AGENTS.md, checked branch/status/index/main/merge-base and all three branch-only commits. Inspected the complete current diff from main, correction diff, all current source/test/XML files and changed documents against the specification/requirements read completely in the initial review. |
| Local static checks | `git diff --check main HEAD` passed. PowerShell XML/name/source/companion/serializer/flag checks report zero issues. Independently counted 218 requirement rows (217 Planned, one Review required), seven test includes and 40 authored test methods. Verified 23 declared kinds, 23 unique values and zero missing fixture entries. Inspected factory guards, private state, method-name lengths and regression assertions. The first kind-count display was inconsistent because a PowerShell automatic regex variable was overwritten; the script was corrected and rerun with distinct variables, and only the corrected 23/23/0 result is relied upon. |
| Locally executed tests | Not run. No local ABAP runtime, installed `abaplint` command, lint configuration, package manifest, or test runner was found. Node/npm are available but do not execute these ABAP tests; no dependencies were installed or speculative runner created. The PowerShell checks are static checks, not ABAP execution. |
| abapGit structure checks | Re-parsed all class XML files, package XML and `.abapgit.xml`; checked filenames, matching names/companions, folder/serializer and flags including WITH_UNIT_TESTS. Initial-review upstream importer inspection supports the resolved metadata defect. Actual import: Not run. |
| Documentation verification | Opened official SAP 7.51 literals documentation to verify the trailing-space fixture issue. Documentary evidence, not an executed SAP check. |
| ADT source inspection | Not run in this re-review. Historical initial-review operations: healthcheck; searchObject for CX_PARAMETER_INVALID_RANGE, ZBPC_ASL and ZCL_BPC_ASL_*; getObjectSource for the exception and its parent definition; nodeContents for the package after a cancelled attempt. Those reads confirmed the standard constructor/inheritance and package existence, not current slice execution. No new signatures require inspection for these corrections. |
| SAP syntax check | Not run. Exposed syntax-tool descriptions do not explicitly guarantee no change/activation, as required by the review instruction. No source was uploaded for checking. |
| SAP activation | Not run; not authorized. |
| ABAP Unit | Not run; no slice objects imported or activated by this review. |
| BPC integration tests | Not run; excluded and unnecessary for these BPC-independent contracts. |

No SAP create, modify, lock, activation, transport, configuration, write operation, or SAP-side abapGit operation was performed. Connection details and credentials are not included in this review.

## SAP validation still required

After the remaining test corrections, coordinate decision and separate authorization for SAP changes:

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

DeepSeek should retain the independently verified corrections for REVIEW-001/002/005, finish the remaining trailing-space/name/end-column tests in REVIEW-004, and obtain/document the Q-012 decision and examples for REVIEW-003. Keep status partial and SAP validation pending; request a further independent review when both outstanding findings are addressed. Documentation of an unresolved decision and an increased authored-test count do not close those findings. Do not begin excluded implementation to address them.

This re-review changes and commits only `docs/AI-REVIEW.md`, as explicitly requested. Pre-existing untracked files remain untouched. No implementation, SAP object, branch switch, push or merge is performed. The review commit hash is reported in the completion response; it cannot be embedded in the file committed by that same commit.
