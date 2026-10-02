CLASS ltcl_severity DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS all_severities_valid FOR TESTING.
    METHODS unknown_severity_invalid FOR TESTING.
    METHODS error_and_warning_predicates FOR TESTING.

ENDCLASS.

CLASS ltcl_severity IMPLEMENTATION.

  METHOD all_severities_valid.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_bpc_asl_severity=>is_valid( zcl_bpc_asl_severity=>co_info )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_bpc_asl_severity=>is_valid( zcl_bpc_asl_severity=>co_warning )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_bpc_asl_severity=>is_valid( zcl_bpc_asl_severity=>co_error )
      exp = abap_true ).
  ENDMETHOD.

  METHOD unknown_severity_invalid.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_bpc_asl_severity=>is_valid( 'FATAL' )
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_bpc_asl_severity=>is_valid( 'warning' )
      exp = abap_false ).
  ENDMETHOD.

  METHOD error_and_warning_predicates.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_bpc_asl_severity=>is_error( zcl_bpc_asl_severity=>co_error )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_bpc_asl_severity=>is_warning( zcl_bpc_asl_severity=>co_warning )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_bpc_asl_severity=>is_error( zcl_bpc_asl_severity=>co_info )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
