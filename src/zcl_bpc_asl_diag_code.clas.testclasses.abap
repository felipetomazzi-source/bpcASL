CLASS ltcl_diag_code DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS valid_codes_accepted FOR TESTING.
    METHODS unprefixed_code_accepted FOR TESTING.
    METHODS invalid_codes_rejected FOR TESTING.
    METHODS underscore_placement_rejected FOR TESTING.
    METHODS length_boundary FOR TESTING.

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
    cl_abap_unit_assert=>assert_equals(
      act = zcl_bpc_asl_diag_code=>is_valid( 'RUN_TIMEOUT' )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_bpc_asl_diag_code=>is_valid( 'SYS_ADAPTER_ERROR' )
      exp = abap_true ).
  ENDMETHOD.

  METHOD unprefixed_code_accepted.
    " SPECIFICATION.md section 29 uses an unprefixed example code; the validator
    " is shape-only, so it must accept it.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_bpc_asl_diag_code=>is_valid( 'UNKNOWN_PROPERTY' )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_bpc_asl_diag_code=>is_valid( 'FOO_BAR' )
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

  METHOD underscore_placement_rejected.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_bpc_asl_diag_code=>is_valid( 'A__B' )
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_bpc_asl_diag_code=>is_valid( 'ABC_' )
      exp = abap_false ).
  ENDMETHOD.

  METHOD length_boundary.
    DATA lv_ok   TYPE string.
    DATA lv_long TYPE string.

    lv_ok   = 'LEX_' && repeat( val = 'A' occ = 56 ).
    lv_long = 'LEX_' && repeat( val = 'A' occ = 57 ).

    cl_abap_unit_assert=>assert_equals( act = strlen( lv_ok )
                                        exp = 60 ).
    cl_abap_unit_assert=>assert_equals( act = strlen( lv_long )
                                        exp = 61 ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_bpc_asl_diag_code=>is_valid( lv_ok )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_bpc_asl_diag_code=>is_valid( lv_long )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
