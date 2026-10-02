" Stable diagnostic-code convention (Phase 0 / Slice 1).
"
" Diagnostic codes are stable UPPER_SNAKE_CASE strings. The first segment is a
" category prefix that reserves a namespace for each compiler/runtime layer:
"
"   LEX_   lexical errors     (unexpected character, unterminated literal)
"   SYN_   syntax errors      (unexpected token, missing semicolon)
"   SEM_   semantic/type/binding errors
"   RUN_   runtime/execution errors
"   SYS_   adapter / infrastructure errors
"
" Rules (see DECISIONS.md ADR-021):
"   - A code is made of uppercase alphanumeric segments separated by '_'.
"   - It starts with a letter and contains at least one underscore.
"   - Length is between 2 and 60 characters.
"   - New codes may be added freely; an existing code must never be renamed or
"     repurposed, because codes are part of the stable diagnostic contract.
"
" Stateless utility class: only class-methods are exposed; it is not
" instantiable.
CLASS zcl_bpc_asl_diag_code DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.

    CLASS-METHODS is_valid
      IMPORTING
        !iv_code TYPE string
      RETURNING
        VALUE(rv_flag) TYPE abap_bool.

ENDCLASS.

CLASS zcl_bpc_asl_diag_code IMPLEMENTATION.

  METHOD is_valid.
    DATA lv_code TYPE string.

    lv_code = iv_code.

    IF strlen( lv_code ) < 2 OR strlen( lv_code ) > 60.
      rv_flag = abap_false.
      RETURN.
    ENDIF.

    FIND REGEX '^[A-Z][A-Z0-9]*(_[A-Z0-9]+)+$' IN lv_code.
    IF sy-subrc = 0.
      rv_flag = abap_true.
    ELSE.
      rv_flag = abap_false.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
