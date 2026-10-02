CLASS ltcl_token DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS create_with_value FOR TESTING.
    METHODS create_without_value FOR TESTING.
    METHODS keyword_token_normalized FOR TESTING.
    METHODS invalid_kind_rejected FOR TESTING.
    METHODS missing_range_rejected FOR TESTING.
    METHODS create_with_empty_value FOR TESTING.
    METHODS numeric_zero_value FOR TESTING.
    METHODS preserves_quoted_mixed_case FOR TESTING.
    METHODS preserves_whitespace_lexeme FOR TESTING.
    METHODS preserves_trailing_space FOR TESTING.
    METHODS preserves_unicode_lexeme FOR TESTING.
    METHODS eof_token_policy FOR TESTING.

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

  METHOD create_with_empty_value.
    DATA lo_range TYPE REF TO zcl_bpc_asl_src_range.
    DATA lo_token TYPE REF TO zcl_bpc_asl_token.

    lo_range = zcl_bpc_asl_src_range=>create( iv_start_line   = 1
                                              iv_start_column = 1
                                              iv_end_line     = 1
                                              iv_end_column   = 3 ).
    lo_token = zcl_bpc_asl_token=>create(
                 iv_kind   = zcl_bpc_asl_token_kind=>co_string
                 iv_lexeme = '""'
                 io_range  = lo_range
                 iv_value  = '' ).

    cl_abap_unit_assert=>assert_equals( act = lo_token->has_value( )
                                        exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = lo_token->get_value( )
                                        exp = '' ).
    cl_abap_unit_assert=>assert_equals( act = lo_token->get_lexeme( )
                                        exp = '""' ).
  ENDMETHOD.

  METHOD numeric_zero_value.
    DATA lo_range TYPE REF TO zcl_bpc_asl_src_range.
    DATA lo_token TYPE REF TO zcl_bpc_asl_token.

    lo_range = zcl_bpc_asl_src_range=>create( iv_start_line   = 1
                                              iv_start_column = 1
                                              iv_end_line     = 1
                                              iv_end_column   = 2 ).
    lo_token = zcl_bpc_asl_token=>create(
                 iv_kind   = zcl_bpc_asl_token_kind=>co_number
                 iv_lexeme = '0'
                 io_range  = lo_range
                 iv_value  = '0' ).

    cl_abap_unit_assert=>assert_equals( act = lo_token->has_value( )
                                        exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = lo_token->get_value( )
                                        exp = '0' ).
  ENDMETHOD.

  METHOD preserves_quoted_mixed_case.
    DATA lo_range TYPE REF TO zcl_bpc_asl_src_range.
    DATA lo_token TYPE REF TO zcl_bpc_asl_token.

    lo_range = zcl_bpc_asl_src_range=>create( iv_start_line   = 1
                                              iv_start_column = 1
                                              iv_end_line     = 1
                                              iv_end_column   = 9 ).
    lo_token = zcl_bpc_asl_token=>create(
                 iv_kind   = zcl_bpc_asl_token_kind=>co_string
                 iv_lexeme = '"FooBar"'
                 io_range  = lo_range
                 iv_value  = 'FooBar' ).

    cl_abap_unit_assert=>assert_equals( act = lo_token->get_lexeme( )
                                        exp = '"FooBar"' ).
    cl_abap_unit_assert=>assert_equals( act = lo_token->get_value( )
                                        exp = 'FooBar' ).
  ENDMETHOD.

  METHOD preserves_whitespace_lexeme.
    DATA lo_range  TYPE REF TO zcl_bpc_asl_src_range.
    DATA lo_token  TYPE REF TO zcl_bpc_asl_token.
    DATA lv_lexeme TYPE string.

    lo_range = zcl_bpc_asl_src_range=>create( iv_start_line   = 1
                                              iv_start_column = 1
                                              iv_end_line     = 1
                                              iv_end_column   = 10 ).
    lv_lexeme = |  SCRIPT |. " 2 leading + 1 trailing space (9 chars)
    lo_token = zcl_bpc_asl_token=>create(
                 iv_kind   = zcl_bpc_asl_token_kind=>co_keyword
                 iv_lexeme = lv_lexeme
                 io_range  = lo_range
                 iv_value  = 'SCRIPT' ).

    cl_abap_unit_assert=>assert_equals( act = strlen( lv_lexeme ) exp = 9 ).
    " The factory must not trim the original lexeme.
    cl_abap_unit_assert=>assert_equals( act = lo_token->get_lexeme( )
                                        exp = |  SCRIPT | ).
    " The final character must remain the trailing space.
    cl_abap_unit_assert=>assert_equals(
      act = substring( val = lo_token->get_lexeme( )
                       off = strlen( lo_token->get_lexeme( ) ) - 1
                       len = 1 )
      exp = ' ' ).
  ENDMETHOD.

  METHOD preserves_trailing_space.
    DATA lo_range  TYPE REF TO zcl_bpc_asl_src_range.
    DATA lo_token  TYPE REF TO zcl_bpc_asl_token.
    DATA lv_lexeme TYPE string.

    lo_range = zcl_bpc_asl_src_range=>create( iv_start_line   = 1
                                              iv_start_column = 1
                                              iv_end_line     = 1
                                              iv_end_column   = 8 ).
    lv_lexeme = |SCRIPT |. " actual string fixture with one trailing space (7 chars)
    lo_token = zcl_bpc_asl_token=>create(
                 iv_kind   = zcl_bpc_asl_token_kind=>co_keyword
                 iv_lexeme = lv_lexeme
                 io_range  = lo_range
                 iv_value  = 'SCRIPT' ).

    cl_abap_unit_assert=>assert_equals( act = strlen( lv_lexeme ) exp = 7 ).
    cl_abap_unit_assert=>assert_equals( act = lo_token->get_lexeme( )
                                        exp = |SCRIPT | ).
    cl_abap_unit_assert=>assert_equals( act = strlen( lo_token->get_lexeme( ) )
                                        exp = 7 ).
    " The final character must remain the trailing space.
    cl_abap_unit_assert=>assert_equals(
      act = substring( val = lo_token->get_lexeme( )
                       off = strlen( lo_token->get_lexeme( ) ) - 1
                       len = 1 )
      exp = ' ' ).
  ENDMETHOD.

  METHOD preserves_unicode_lexeme.
    DATA lo_range TYPE REF TO zcl_bpc_asl_src_range.
    DATA lo_token TYPE REF TO zcl_bpc_asl_token.

    lo_range = zcl_bpc_asl_src_range=>create( iv_start_line   = 1
                                              iv_start_column = 1
                                              iv_end_line     = 1
                                              iv_end_column   = 5 ).
    lo_token = zcl_bpc_asl_token=>create(
                 iv_kind   = zcl_bpc_asl_token_kind=>co_identifier
                 iv_lexeme = 'café'
                 io_range  = lo_range
                 iv_value  = 'CAFÉ' ).

    cl_abap_unit_assert=>assert_equals( act = lo_token->get_lexeme( )
                                        exp = 'café' ).
    cl_abap_unit_assert=>assert_equals( act = lo_token->get_value( )
                                        exp = 'CAFÉ' ).
  ENDMETHOD.

  METHOD eof_token_policy.
    DATA lo_range TYPE REF TO zcl_bpc_asl_src_range.
    DATA lo_token TYPE REF TO zcl_bpc_asl_token.

    " End-of-file is a zero-width token with an empty lexeme and no value.
    lo_range = zcl_bpc_asl_src_range=>create( iv_start_line   = 3
                                              iv_start_column = 9
                                              iv_end_line     = 3
                                              iv_end_column   = 9 ).
    lo_token = zcl_bpc_asl_token=>create(
                 iv_kind   = zcl_bpc_asl_token_kind=>co_end_of_file
                 iv_lexeme = ''
                 io_range  = lo_range ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_token->get_kind( )
      exp = zcl_bpc_asl_token_kind=>co_end_of_file ).
    cl_abap_unit_assert=>assert_equals( act = lo_token->get_lexeme( )
                                        exp = '' ).
    cl_abap_unit_assert=>assert_equals( act = lo_token->has_value( )
                                        exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
