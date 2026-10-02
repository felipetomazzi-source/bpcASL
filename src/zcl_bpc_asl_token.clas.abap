" Lexical token (Phase 0 / Slice 1).
"
" A token carries:
"   - kind:             one of ZCL_BPC_ASL_TOKEN_KIND's constants;
"   - lexeme:           the original source text, preserved for diagnostics and
"                       formatting (never normalized or trimmed);
"   - normalized value: optional; empty string means "absent". For KEYWORD and
"                       IDENTIFIER it is the uppercase lexeme; for NUMBER it is a
"                       canonical numeric text; for STRING it is the unescaped
"                       content. Operators and punctuation carry no value.
"   - range:            the half-open source range [start, end).
"
" Immutable by contract: construction is private and only read access is
" exposed.
CLASS zcl_bpc_asl_token DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.

    CLASS-METHODS create
      IMPORTING
        !iv_kind   TYPE string
        !iv_lexeme TYPE string
        !io_range  TYPE REF TO zcl_bpc_asl_src_range
        !iv_value  TYPE string OPTIONAL
      RETURNING
        VALUE(ro_token) TYPE REF TO zcl_bpc_asl_token
      RAISING
        cx_parameter_invalid_range.

    METHODS get_kind
      RETURNING
        VALUE(rv_kind) TYPE string.

    METHODS get_lexeme
      RETURNING
        VALUE(rv_lexeme) TYPE string.

    METHODS has_value
      RETURNING
        VALUE(rv_flag) TYPE abap_bool.

    METHODS get_value
      RETURNING
        VALUE(rv_value) TYPE string.

    METHODS get_range
      RETURNING
        VALUE(ro_range) TYPE REF TO zcl_bpc_asl_src_range.

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

  PRIVATE SECTION.
    DATA mv_kind   TYPE string.
    DATA mv_lexeme TYPE string.
    DATA mv_value  TYPE string.
    DATA mo_range  TYPE REF TO zcl_bpc_asl_src_range.
ENDCLASS.

CLASS zcl_bpc_asl_token IMPLEMENTATION.

  METHOD create.
    IF zcl_bpc_asl_token_kind=>is_valid( iv_kind ) = abap_false.
      RAISE EXCEPTION TYPE cx_parameter_invalid_range
        EXPORTING
          parameter = 'IV_KIND'.
    ENDIF.

    IF io_range IS NOT BOUND.
      RAISE EXCEPTION TYPE cx_parameter_invalid_range
        EXPORTING
          parameter = 'IO_RANGE'.
    ENDIF.

    CREATE OBJECT ro_token.
    ro_token->mv_kind   = iv_kind.
    ro_token->mv_lexeme = iv_lexeme.
    ro_token->mv_value  = iv_value.
    ro_token->mo_range  = io_range.
  ENDMETHOD.

  METHOD get_kind.
    rv_kind = mv_kind.
  ENDMETHOD.

  METHOD get_lexeme.
    rv_lexeme = mv_lexeme.
  ENDMETHOD.

  METHOD has_value.
    IF mv_value IS NOT INITIAL.
      rv_flag = abap_true.
    ELSE.
      rv_flag = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD get_value.
    rv_value = mv_value.
  ENDMETHOD.

  METHOD get_range.
    ro_range = mo_range.
  ENDMETHOD.

  METHOD get_start_line.
    rv_line = mo_range->get_start_line( ).
  ENDMETHOD.

  METHOD get_start_column.
    rv_column = mo_range->get_start_column( ).
  ENDMETHOD.

  METHOD get_end_line.
    rv_line = mo_range->get_end_line( ).
  ENDMETHOD.

  METHOD get_end_column.
    rv_column = mo_range->get_end_column( ).
  ENDMETHOD.

ENDCLASS.
