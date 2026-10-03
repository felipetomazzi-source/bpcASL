" Structured diagnostic (Phase 0 / Slice 1).
"
" A diagnostic carries a severity (INFO/WARNING/ERROR), a stable code, a
" human-readable message, and an optional source range. The optional source
" location satisfies SPECIFICATION.md section 31 ("source location when
" applicable"); correlationId, stage, and partition are runtime concerns and are
" intentionally out of scope for this slice.
"
" Immutable by contract: construction is private and only read access is
" exposed.
CLASS zcl_bpc_asl_diag DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.

    CLASS-METHODS create
      IMPORTING
        !iv_severity TYPE string
        !iv_code     TYPE string
        !iv_message  TYPE string
        !io_range    TYPE REF TO zcl_bpc_asl_src_range OPTIONAL
      RETURNING
        VALUE(ro_diag) TYPE REF TO zcl_bpc_asl_diag
      RAISING
        cx_parameter_invalid_range.

    METHODS get_severity
      RETURNING
        VALUE(rv_severity) TYPE string.

    METHODS get_code
      RETURNING
        VALUE(rv_code) TYPE string.

    METHODS get_message
      RETURNING
        VALUE(rv_message) TYPE string.

    METHODS has_location
      RETURNING
        VALUE(rv_flag) TYPE abap_bool.

    METHODS get_range
      RETURNING
        VALUE(ro_range) TYPE REF TO zcl_bpc_asl_src_range.

  PRIVATE SECTION.
    DATA mv_severity TYPE string.
    DATA mv_code     TYPE string.
    DATA mv_message  TYPE string.
    DATA mo_range    TYPE REF TO zcl_bpc_asl_src_range.
ENDCLASS.

CLASS zcl_bpc_asl_diag IMPLEMENTATION.

  METHOD create.
    IF zcl_bpc_asl_severity=>is_valid( iv_severity ) = abap_false.
      RAISE EXCEPTION TYPE cx_parameter_invalid_range
        EXPORTING
          parameter = 'IV_SEVERITY'.
    ENDIF.

    IF zcl_bpc_asl_diag_code=>is_valid( iv_code ) = abap_false.
      RAISE EXCEPTION TYPE cx_parameter_invalid_range
        EXPORTING
          parameter = 'IV_CODE'.
    ENDIF.

    CREATE OBJECT ro_diag.
    ro_diag->mv_severity = iv_severity.
    ro_diag->mv_code     = iv_code.
    ro_diag->mv_message  = iv_message.
    ro_diag->mo_range    = io_range.
  ENDMETHOD.

  METHOD get_severity.
    rv_severity = mv_severity.
  ENDMETHOD.

  METHOD get_code.
    rv_code = mv_code.
  ENDMETHOD.

  METHOD get_message.
    rv_message = mv_message.
  ENDMETHOD.

  METHOD has_location.
    IF mo_range IS BOUND.
      rv_flag = abap_true.
    ELSE.
      rv_flag = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD get_range.
    ro_range = mo_range.
  ENDMETHOD.

ENDCLASS.
