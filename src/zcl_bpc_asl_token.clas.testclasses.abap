CLASS ltcl_token DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS create_with_value FOR TESTING.
    METHODS create_without_value FOR TESTING.
    METHODS keyword_token_normalized FOR TESTING.
    METHODS invalid_kind_rejected FOR TESTING.
    METHODS missing_range_rejected FOR TESTING.

ENDCLASS.

CLASS ltcl_token IMPLEMENTATION.

  METHOD create_with_value.
    DATA lo_range TYPE REF TO zcl_bpc_asl_src_range.
    DATA lo_token TYPE REF TO zcl_bpc_asl_token.

    lo_range = zcl_bpc_asl_src_range=>create( iv_start_line   = 1
                                              iv_start_column = 1
                                              iv_end_line     = 1
                                              iv_end_column   = 7 ).
    lo_token = zcl_bpc_asl_token=>create(
                 iv_kind   = zcl_bpc_asl_token_kind=>co_keyword
                 iv_lexeme = 'SCRIPT'
                 io_range  = lo_range
                 iv_value  = 'SCRIPT' ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_token->get_kind( )
      exp = zcl_bpc_asl_token_kind=>co_keyword ).
    cl_abap_unit_assert=>assert_equals( act = lo_token->get_lexeme( )
                                        exp = 'SCRIPT' ).
    cl_abap_unit_assert=>assert_equals( act = lo_token->has_value( )
                                        exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = lo_token->get_value( )
                                        exp = 'SCRIPT' ).
    cl_abap_unit_assert=>assert_equals( act = lo_token->get_start_line( )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lo_token->get_end_column( )
                                        exp = 7 ).
  ENDMETHOD.

  METHOD create_without_value.
    DATA lo_range TYPE REF TO zcl_bpc_asl_src_range.
    DATA lo_token TYPE REF TO zcl_bpc_asl_token.

    lo_range = zcl_bpc_asl_src_range=>create( iv_start_line   = 1
                                              iv_start_column = 1
                                              iv_end_line     = 1
                                              iv_end_column   = 2 ).
    lo_token = zcl_bpc_asl_token=>create(
                 iv_kind   = zcl_bpc_asl_token_kind=>co_semicolon
                 iv_lexeme = ';'
                 io_range  = lo_range ).

    cl_abap_unit_assert=>assert_equals( act = lo_token->has_value( )
                                        exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = lo_token->get_value( )
                                        exp = '' ).
  ENDMETHOD.

  METHOD keyword_token_normalized.
    DATA lo_range TYPE REF TO zcl_bpc_asl_src_range.
    DATA lo_token TYPE REF TO zcl_bpc_asl_token.

    lo_range = zcl_bpc_asl_src_range=>create( iv_start_line   = 1
                                              iv_start_column = 1
                                              iv_end_line     = 1
                                              iv_end_column   = 7 ).
    " Lexeme preserves authored case; normalized value is uppercased.
    lo_token = zcl_bpc_asl_token=>create(
                 iv_kind   = zcl_bpc_asl_token_kind=>co_keyword
                 iv_lexeme = 'script'
                 io_range  = lo_range
                 iv_value  = 'SCRIPT' ).

    cl_abap_unit_assert=>assert_equals( act = lo_token->get_lexeme( )
                                        exp = 'script' ).
    cl_abap_unit_assert=>assert_equals( act = lo_token->get_value( )
                                        exp = 'SCRIPT' ).
  ENDMETHOD.

  METHOD invalid_kind_rejected.
    DATA lo_range TYPE REF TO zcl_bpc_asl_src_range.

    lo_range = zcl_bpc_asl_src_range=>create( iv_start_line   = 1
                                              iv_start_column = 1
                                              iv_end_line     = 1
                                              iv_end_column   = 2 ).
    TRY.
        zcl_bpc_asl_token=>create( iv_kind   = 'BOGUS'
                                   iv_lexeme = 'x'
                                   io_range  = lo_range ).
        cl_abap_unit_assert=>fail( msg = 'Expected CX_PARAMETER_INVALID_RANGE' ).
      CATCH cx_parameter_invalid_range.
        " Expected: kind must be a known token kind.
    ENDTRY.
  ENDMETHOD.

  METHOD missing_range_rejected.
    DATA lo_range TYPE REF TO zcl_bpc_asl_src_range.
    " lo_range is initial (not bound).
    TRY.
        zcl_bpc_asl_token=>create( iv_kind   = zcl_bpc_asl_token_kind=>co_keyword
                                   iv_lexeme = 'SCRIPT'
                                   io_range  = lo_range ).
        cl_abap_unit_assert=>fail( msg = 'Expected CX_PARAMETER_INVALID_RANGE' ).
      CATCH cx_parameter_invalid_range.
        " Expected: a token must carry a bound source range.
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
