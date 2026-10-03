CLASS ltcl_diag DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS create_without_location FOR TESTING.
    METHODS create_with_location FOR TESTING.
    METHODS invalid_severity_rejected FOR TESTING.
    METHODS invalid_code_rejected FOR TESTING.

ENDCLASS.

CLASS ltcl_diag IMPLEMENTATION.

  METHOD create_without_location.
    DATA lo_diag TYPE REF TO zcl_bpc_asl_diag.

    lo_diag = zcl_bpc_asl_diag=>create(
                iv_severity = zcl_bpc_asl_severity=>co_error
                iv_code     = 'LEX_UNEXPECTED_CHARACTER'
                iv_message  = 'Unexpected character' ).

    cl_abap_unit_assert=>assert_equals( act = lo_diag->get_severity( )
                                        exp = zcl_bpc_asl_severity=>co_error ).
    cl_abap_unit_assert=>assert_equals( act = lo_diag->get_code( )
                                        exp = 'LEX_UNEXPECTED_CHARACTER' ).
    cl_abap_unit_assert=>assert_equals( act = lo_diag->get_message( )
                                        exp = 'Unexpected character' ).
    cl_abap_unit_assert=>assert_equals( act = lo_diag->has_location( )
                                        exp = abap_false ).
  ENDMETHOD.

  METHOD create_with_location.
    DATA lo_range TYPE REF TO zcl_bpc_asl_src_range.
    DATA lo_diag  TYPE REF TO zcl_bpc_asl_diag.

    lo_range = zcl_bpc_asl_src_range=>create( iv_start_line   = 3
                                              iv_start_column = 7
                                              iv_end_line     = 3
                                              iv_end_column   = 8 ).
    lo_diag = zcl_bpc_asl_diag=>create(
                iv_severity = zcl_bpc_asl_severity=>co_warning
                iv_code     = 'LEX_UNTERMINATED_STRING'
                iv_message  = 'Unterminated string'
                io_range    = lo_range ).

    cl_abap_unit_assert=>assert_equals( act = lo_diag->has_location( )
                                        exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = lo_diag->get_range( )->get_start_line( )
                                        exp = 3 ).
  ENDMETHOD.

  METHOD invalid_severity_rejected.
    TRY.
        zcl_bpc_asl_diag=>create( iv_severity = 'FATAL'
                                  iv_code     = 'LEX_UNEXPECTED_CHARACTER'
                                  iv_message  = 'x' ).
        cl_abap_unit_assert=>fail( msg = 'Expected CX_PARAMETER_INVALID_RANGE' ).
      CATCH cx_parameter_invalid_range.
        " Expected: severity must be INFO/WARNING/ERROR.
    ENDTRY.
  ENDMETHOD.

  METHOD invalid_code_rejected.
    TRY.
        zcl_bpc_asl_diag=>create( iv_severity = zcl_bpc_asl_severity=>co_error
                                  iv_code     = 'bad code'
                                  iv_message  = 'x' ).
        cl_abap_unit_assert=>fail( msg = 'Expected CX_PARAMETER_INVALID_RANGE' ).
      CATCH cx_parameter_invalid_range.
        " Expected: code must follow the stable convention.
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
