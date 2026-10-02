" Source range in an ASL script (Phase 0 / Slice 1).
"
" A range is a half-open interval [start, end): the start position is included
" and the end position is excluded. A zero-width range has start = end.
" The start/end ordering is compared by line first, then column.
"
" The half-open convention is recorded in DECISIONS.md ADR-022 (AI-QUESTIONS.md
" Q-012). A one-character range spans [c, c+1); an insertion point or end-of-file
" is a zero-width range where start = end.
"
" Immutable by contract: construction is private and only read access is
" exposed.
CLASS zcl_bpc_asl_src_range DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.

    CLASS-METHODS create
      IMPORTING
        !iv_start_line   TYPE i
        !iv_start_column TYPE i
        !iv_end_line     TYPE i
        !iv_end_column   TYPE i
      RETURNING
        VALUE(ro_range) TYPE REF TO zcl_bpc_asl_src_range
      RAISING
        cx_parameter_invalid_range.

    METHODS get_start
      RETURNING
        VALUE(ro_start) TYPE REF TO zcl_bpc_asl_src_pos.

    METHODS get_end
      RETURNING
        VALUE(ro_end) TYPE REF TO zcl_bpc_asl_src_pos.

    METHODS get_start_line
      RETURNING
        VALUE(rv_line) TYPE i.

    METHODS get_start_column
      RETURNING
        VALUE(rv_column) TYPE i.

    METHODS get_end_line
      RETURNING
        VALUE(rv_line) TYPE i.

    METHODS get_end_column
      RETURNING
        VALUE(rv_column) TYPE i.

    METHODS is_zero_width
      RETURNING
        VALUE(rv_flag) TYPE abap_bool.

  PRIVATE SECTION.
    DATA mo_start TYPE REF TO zcl_bpc_asl_src_pos.
    DATA mo_end   TYPE REF TO zcl_bpc_asl_src_pos.
ENDCLASS.

CLASS zcl_bpc_asl_src_range IMPLEMENTATION.

  METHOD create.
    DATA lo_start TYPE REF TO zcl_bpc_asl_src_pos.
    DATA lo_end   TYPE REF TO zcl_bpc_asl_src_pos.

    lo_start = zcl_bpc_asl_src_pos=>create( iv_line   = iv_start_line
                                            iv_column = iv_start_column ).
    lo_end   = zcl_bpc_asl_src_pos=>create( iv_line   = iv_end_line
                                            iv_column = iv_end_column ).

    IF lo_end->get_line( ) < lo_start->get_line( )
       OR ( lo_end->get_line( ) = lo_start->get_line( )
            AND lo_end->get_column( ) < lo_start->get_column( ) ).
      RAISE EXCEPTION TYPE cx_parameter_invalid_range
        EXPORTING
          parameter = 'IV_END_LINE/IV_END_COLUMN'.
    ENDIF.

    CREATE OBJECT ro_range.
    ro_range->mo_start = lo_start.
    ro_range->mo_end   = lo_end.
  ENDMETHOD.

  METHOD get_start.
    ro_start = mo_start.
  ENDMETHOD.

  METHOD get_end.
    ro_end = mo_end.
  ENDMETHOD.

  METHOD get_start_line.
    rv_line = mo_start->get_line( ).
  ENDMETHOD.

  METHOD get_start_column.
    rv_column = mo_start->get_column( ).
  ENDMETHOD.

  METHOD get_end_line.
    rv_line = mo_end->get_line( ).
  ENDMETHOD.

  METHOD get_end_column.
    rv_column = mo_end->get_column( ).
  ENDMETHOD.

  METHOD is_zero_width.
    IF mo_start->get_line( ) = mo_end->get_line( )
       AND mo_start->get_column( ) = mo_end->get_column( ).
      rv_flag = abap_true.
    ELSE.
      rv_flag = abap_false.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
