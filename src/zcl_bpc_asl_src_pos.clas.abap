" Source position in an ASL script (Phase 0 / Slice 1).
"
" Lines and columns are 1-based: the first character of the first line is
" position (1,1). This matches the diagnostic envelope in SPECIFICATION.md
" section 29, where line and column are reported 1-based.
"
" The exact base (1 vs 0) is recorded as an open question (Q-012) because the
" specification does not state it formally; this class implements the
" recommended 1-based convention and is the single point that would change if
" the answer differs.
"
" Immutable by contract: construction is private, values are set once, and only
" read access is exposed.
CLASS zcl_bpc_asl_src_pos DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.

    CLASS-METHODS create
      IMPORTING
        !iv_line   TYPE i
        !iv_column TYPE i
      RETURNING
        VALUE(ro_pos) TYPE REF TO zcl_bpc_asl_src_pos
      RAISING
        cx_parameter_invalid_range.

    METHODS get_line
      RETURNING
        VALUE(rv_line) TYPE i.

    METHODS get_column
      RETURNING
        VALUE(rv_column) TYPE i.

  PRIVATE SECTION.
    DATA mv_line TYPE i.
    DATA mv_column TYPE i.
ENDCLASS.

CLASS zcl_bpc_asl_src_pos IMPLEMENTATION.

  METHOD create.
    IF iv_line < 1.
      RAISE EXCEPTION TYPE cx_parameter_invalid_range
        EXPORTING
          parameter = 'IV_LINE'.
    ENDIF.

    IF iv_column < 1.
      RAISE EXCEPTION TYPE cx_parameter_invalid_range
        EXPORTING
          parameter = 'IV_COLUMN'.
    ENDIF.

    CREATE OBJECT ro_pos.
    ro_pos->mv_line   = iv_line.
    ro_pos->mv_column = iv_column.
  ENDMETHOD.

  METHOD get_line.
    rv_line = mv_line.
  ENDMETHOD.

  METHOD get_column.
    rv_column = mv_column.
  ENDMETHOD.

ENDCLASS.
