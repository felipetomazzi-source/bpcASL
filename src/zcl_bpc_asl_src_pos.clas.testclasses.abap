CLASS ltcl_src_pos DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS create_valid FOR TESTING.
    METHODS zero_line_rejected FOR TESTING.
    METHODS zero_column_rejected FOR TESTING.
    METHODS negative_line_rejected FOR TESTING.
    METHODS negative_column_rejected FOR TESTING.

ENDCLASS.

CLASS ltcl_src_pos IMPLEMENTATION.

  METHOD create_valid.
    DATA lo_pos TYPE REF TO zcl_bpc_asl_src_pos.

    lo_pos = zcl_bpc_asl_src_pos=>create( iv_line = 1 iv_column = 1 ).

    cl_abap_unit_assert=>assert_equals( act = lo_pos->get_line( )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lo_pos->get_column( )
                                        exp = 1 ).
  ENDMETHOD.

  METHOD zero_line_rejected.
    TRY.
        zcl_bpc_asl_src_pos=>create( iv_line = 0 iv_column = 1 ).
        cl_abap_unit_assert=>fail( msg = 'Expected CX_PARAMETER_INVALID_RANGE' ).
      CATCH cx_parameter_invalid_range.
        " Expected: line 0 violates the 1-based invariant.
    ENDTRY.
  ENDMETHOD.

  METHOD zero_column_rejected.
    TRY.
        zcl_bpc_asl_src_pos=>create( iv_line = 1 iv_column = 0 ).
        cl_abap_unit_assert=>fail( msg = 'Expected CX_PARAMETER_INVALID_RANGE' ).
      CATCH cx_parameter_invalid_range.
        " Expected: column 0 violates the 1-based invariant.
    ENDTRY.
  ENDMETHOD.

  METHOD negative_line_rejected.
    TRY.
        zcl_bpc_asl_src_pos=>create( iv_line = -1 iv_column = 1 ).
        cl_abap_unit_assert=>fail( msg = 'Expected CX_PARAMETER_INVALID_RANGE' ).
      CATCH cx_parameter_invalid_range.
        " Expected: a negative line violates the 1-based invariant.
    ENDTRY.
  ENDMETHOD.

  METHOD negative_column_rejected.
    TRY.
        zcl_bpc_asl_src_pos=>create( iv_line = 1 iv_column = -1 ).
        cl_abap_unit_assert=>fail( msg = 'Expected CX_PARAMETER_INVALID_RANGE' ).
      CATCH cx_parameter_invalid_range.
        " Expected: a negative column violates the 1-based invariant.
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
