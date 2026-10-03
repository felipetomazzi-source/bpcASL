# abapGit serialization conventions

Use UTF-8 with BOM for object metadata XML and `.abapgit.xml`;
use UTF-8 without BOM for ABAP main and test source. Preserve LF endings and
one final LF. `.gitattributes` disables normalization so Git retains these bytes.

The previous blanket CRLF convention copied from bpcIO was not established
for this installation and caused whole-file differences. bpcIO remains unchanged.

On 2026-10-02, read-only ADT inspection of the installed serializer established:

- `ZCL_ABAPGIT_OBJECTS_FILES->ADD_ABAP` joins lines with
  `CL_ABAP_CHAR_UTILITIES=>NEWLINE`, appends one newline, then converts to UTF-8
  without adding a BOM.
- `ADD_XML`, `ZCL_ABAPGIT_DOT_ABAPGIT->SERIALIZE`, and
  `ZCL_ABAPGIT_CONVERT=>STRING_TO_XSTRING_UTF8_BOM` explicitly add an XML BOM.
- `ZCL_ABAPGIT_XML->TO_XML` uses the normalized iXML renderer. Its raw output
  was not executed/exported by this task. Restoring XML LF is based on the
  whole-file SAP diff after CRLF conversion; confirm with an SAP refresh.

No SAP write, activation, syntax check or ABAP Unit operation was performed.
Source inspection is not a successful round-trip test. If XML differences remain,
compare a raw export from the installed abapGit before making further changes.

Run `powershell -NoProfile -File tools/check-abapgit-bytes.ps1` to check current
files. Add `-Fix` to repair them. The helper strictly validates UTF-8, BOM rules,
LF endings and the final newline, and revalidates repairs before writing.
It covers `.abapgit.xml` and ABAP/XML under `src`, not future BSP content formats.
Check staged/committed Git blobs separately; a working-file check does not prove
what was committed.
