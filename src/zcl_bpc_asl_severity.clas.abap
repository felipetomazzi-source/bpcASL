" Diagnostic severity (Phase 0 / Slice 1).
"
" The three severities required by SPECIFICATION.md section 31: INFO, WARNING,
" and ERROR. Values are stable strings shared by the whole compiler pipeline so
" that the lexer, parser, and runtime cannot define conflicting severities.
"
" Stateless utility class: only constants and class-methods are exposed; it is
" not instantiable.
CLASS zcl_bpc_asl_severity DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.

    CONSTANTS:
      co_info    TYPE string VALUE 'INFO',
      co_warning TYPE string VALUE 'WARNING',
      co_error   TYPE string VALUE 'ERROR'.

    CLASS-METHODS is_valid
      IMPORTING
        !iv_severity TYPE string
      RETURNING
        VALUE(rv_flag) TYPE abap_bool.

    CLASS-METHODS is_info
      IMPORTING
        !iv_severity TYPE string
      RETURNING
        VALUE(rv_flag) TYPE abap_bool.

    CLASS-METHODS is_warning
      IMPORTING
        !iv_severity TYPE string
      RETURNING
        VALUE(rv_flag) TYPE abap_bool.

    CLASS-METHODS is_error
      IMPORTING
        !iv_severity TYPE string
      RETURNING
        VALUE(rv_flag) TYPE abap_bool.

ENDCLASS.

CLASS zcl_bpc_asl_severity IMPLEMENTATION.

  METHOD is_valid.
    CASE iv_severity.
      WHEN co_info OR co_warning OR co_error.
        rv_flag = abap_true.
      WHEN OTHERS.
        rv_flag = abap_false.
    ENDCASE.
  ENDMETHOD.

  METHOD is_info.
    IF iv_severity = co_info.
      rv_flag = abap_true.
    ELSE.
      rv_flag = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD is_warning.
    IF iv_severity = co_warning.
      rv_flag = abap_true.
    ELSE.
      rv_flag = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD is_error.
    IF iv_severity = co_error.
      rv_flag = abap_true.
    ELSE.
      rv_flag = abap_false.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
