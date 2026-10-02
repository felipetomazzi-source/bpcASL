CLASS ltcl_diag_code DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS valid_codes_accepted FOR TESTING.
    METHODS invalid_codes_rejected FOR TESTING.

ENDCLASS.

CLASS ltcl_diag_code IMPLEMENTATION.

  METHOD valid_codes_accepted.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_bpc_asl_diag_code=>is_valid( 'LEX_UNEXPECTED_CHARACTER' )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_bpc_asl_diag_code=>is_valid( 'SYN_MISSING_SEMICOLON' )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_bpc_asl_diag_code=>is_valid( 'SEM_UNKNOWN_PROPERTY' )
      exp = abap_true ).
  ENDMETHOD.

  METHOD invalid_codes_rejected.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_bpc_asl_diag_code=>is_valid( 'lowercase_name' )
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_bpc_asl_diag_code=>is_valid( 'NOUNDERSCORE' )
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_bpc_asl_diag_code=>is_valid( '1_LEADING_DIGIT' )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
