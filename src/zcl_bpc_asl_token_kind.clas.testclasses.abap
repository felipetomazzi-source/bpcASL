CLASS ltcl_token_kind DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS every_kind_valid FOR TESTING.
    METHODS unknown_kind_invalid FOR TESTING.
    METHODS keywords_are_single_kind FOR TESTING.

ENDCLASS.

CLASS ltcl_token_kind IMPLEMENTATION.

  METHOD every_kind_valid.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_bpc_asl_token_kind=>is_valid( zcl_bpc_asl_token_kind=>co_end_of_file )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_bpc_asl_token_kind=>is_valid( zcl_bpc_asl_token_kind=>co_identifier )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_bpc_asl_token_kind=>is_valid( zcl_bpc_asl_token_kind=>co_keyword )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_bpc_asl_token_kind=>is_valid( zcl_bpc_asl_token_kind=>co_number )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_bpc_asl_token_kind=>is_valid( zcl_bpc_asl_token_kind=>co_string )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_bpc_asl_token_kind=>is_valid( zcl_bpc_asl_token_kind=>co_equals )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_bpc_asl_token_kind=>is_valid( zcl_bpc_asl_token_kind=>co_semicolon )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_bpc_asl_token_kind=>is_valid( zcl_bpc_asl_token_kind=>co_line_comment )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_bpc_asl_token_kind=>is_valid( zcl_bpc_asl_token_kind=>co_block_comment )
      exp = abap_true ).
  ENDMETHOD.

  METHOD unknown_kind_invalid.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_bpc_asl_token_kind=>is_valid( 'BOGUS' )
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_bpc_asl_token_kind=>is_valid( 'SCRIPT' )
      exp = abap_false ).
  ENDMETHOD.

  METHOD keywords_are_single_kind.
    " Reserved words are not distinct kinds: 'SCRIPT' is carried as the value of
    " a single KEYWORD token, so the kind vocabulary itself has no SCRIPT entry.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_bpc_asl_token_kind=>is_valid( 'SCRIPT' )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
