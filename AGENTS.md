\## Repository boundaries



Primary writable repository:



`C:\\Users\\FelipeTomazzi\\projects\\bpcASL`



Reference-only repository:



`C:\\Users\\FelipeTomazzi\\projects\\bpcIO`



All implementation, documentation, tests, commits, and branches belong in

bpcASL.



bpcIO may be inspected only as a reference for:



\- SAPUI5 1.52 BSP structure;

\- ICF HTTP services;

\- JSON serialization and routing;

\- abapGit object serialization;

\- standard SAP BPC metadata APIs;

\- dimension members, properties, and hierarchies;

\- security-enabled BPC model reads;

\- standard BPC write-back APIs.



Rules for bpcIO:



\- Do not edit, format, create, delete, rename, move, stage, commit, push, pull, or

&#x20; switch branches in bpcIO.

\- Do not change its Git configuration.

\- Do not copy the application wholesale.

\- Do not reuse customer-specific calculation implementations.

\- Implement referenced patterns independently inside bpcASL.

\- Before completing a task, verify that bpcIO has no changes caused by the task.



\## SAP access through ABAP ADT MCP



An ABAP ADT MCP server will be provided for access to the SAP development

system.



The ADT MCP is the preferred source when implementation depends on:



\- live ABAP object definitions;

\- standard SAP class and interface signatures;

\- inherited and implemented methods;

\- DDIC types and structures;

\- SAP package contents;

\- release-specific API availability;

\- syntax validation in the SAP system;

\- object activation or ABAP Unit execution, when explicitly authorized.



Until the ADT MCP is connected:



\- Continue work that does not depend on live SAP information.

\- Use the local bpcIO repository for established standard-BPC usage patterns.

\- Do not guess an SAP API signature.

\- Do not create fake declarations solely to make local source appear complete.

\- Record a question in `docs/AI-QUESTIONS.md` when live SAP inspection is

&#x20; necessary.

\- Mark the question as `Blocking: Yes` only if no useful work in the assigned

&#x20; slice can continue.

\- State precisely which object, method, type, or behavior must be inspected.

\- Mark SAP compilation, activation, ABAP Unit, and integration validation as

&#x20; pending.



When the ADT MCP is connected, use it initially in read-only mode for:



\- repository searches;

\- package inspection;

\- object metadata;

\- source reads;

\- standard API signature verification;

\- release compatibility investigation.



The presence of ADT tools does not authorize SAP changes.



Without explicit authorization, do not use the ADT MCP to:



\- create or modify SAP objects;

\- acquire modification locks;

\- activate objects;

\- delete objects;

\- create or modify transports;

\- execute write operations;

\- change SAP configuration;

\- pull, stage, push, switch, create, or unlink abapGit repositories.



Additional rules:



\- Never expose SAP credentials, cookies, tokens, hosts, or connection details in

&#x20; source files, documentation, prompts, responses, or logs.

\- Never commit SAP connection configuration.

\- Reading a live object does not authorize copying customer-specific source.

\- Do not depend directly on generated `/BIC/`, `/B28/`, or similar tables.

\- Standard BPC and BW access must remain behind bpcASL adapter interfaces.

\- Report exactly which ADT operations were performed.

\- Distinguish reading source from running a syntax check, activating an object,

&#x20; executing ABAP Unit, and running a BPC integration test.



\## Questions protocol



Use `docs/AI-QUESTIONS.md` for ambiguities, contradictions, missing SAP details,

and architectural decisions.



For each question:



1\. Assign the next `Q-NNN` identifier.

2\. Set `Status: Open`.

3\. Include the date.

4\. Include related requirement IDs and specification sections.

5\. State whether the question blocks the current slice.

6\. Describe the exact evidence already inspected.

7\. State the precise question.

8\. List the options considered.

9\. Give a recommendation when possible.

10\. State what work can continue and what work is blocked.

11\. Do not silently answer a material architectural question yourself.

12\. Continue all independent work.


## abapGit serialization

Before creating or editing abapGit-serialized files, read
[docs/ABAPGIT-SERIALIZATION.md](docs/ABAPGIT-SERIALIZATION.md).

- Follow this repository's byte conventions: ABAP source/test files use UTF-8
  without BOM; metadata XML and `.abapgit.xml` use UTF-8 with BOM. Use LF line
  endings and exactly one final LF. XML round-trip confirmation remains pending
  as documented in the serialization guide.
- Preserve `.gitattributes`. Do not apply blanket CRLF conversion or copy
  bpcIO's byte conventions without checking the installed serializer.
- Before committing changes to serialized files, run
  `powershell -NoProfile -File tools/check-abapgit-bytes.ps1`.
- Verify staged Git blobs as well as working files; a working-file check alone
  does not establish what will be committed.
- Keep serialization-only changes separate from functional changes.
- If SAP shows identical-looking whole-file differences, compare raw BOM and
  newline bytes against the installed serializer before changing the format.
- Byte checks do not prove SAP import, activation or ABAP Unit success.
