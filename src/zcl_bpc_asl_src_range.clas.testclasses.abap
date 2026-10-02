CLASS ltcl_src_range DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS create_valid FOR TESTING.
    METHODS one_character_range FOR TESTING.
    METHODS zero_width FOR TESTING.
    METHODS end_before_start_rejected FOR TESTING.
    METHODS start_bad_line_rejected FOR TESTING.
    METHODS end_line_earlier_rejected FOR TESTING.
    METHODS end_line_later_accepted FOR TESTING.
    METHODS negative_start_column_rejected FOR TESTING.
    METHODS negative_end_line_rejected FOR TESTING.
    METHODS zero_end_column_rejected FOR TESTING.
    METHODS negative_end_column_rejected FOR TESTING.

ENDCLASS.

CLASS ltcl_src_range IMPLEMENTATION.

  METHOD create_valid.
    DATA lo_range TYPE REF TO zcl_bpc_asl_src_range.

    lo_range = zcl_bpc_asl_src_range=>create( iv_start_line   = 2
                                              iv_start_column = 3
                                              iv_end_line     = 2
                                              iv_end_column   = 9 ).

    cl_abap_unit_assert=>assert_equals( act = lo_range->get_start_line( )
                                        exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lo_range->get_start_column( )
                                        exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lo_range->get_end_line( )
                                        exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lo_range->get_end_column( )
                                        exp = 9 ).
    cl_abap_unit_assert=>assert_equals( act = lo_range->is_zero_width( )
                                        exp = abap_false ).
  ENDMETHOD.

  METHOD one_character_range.
    DATA lo_range TYPE REF TO zcl_bpc_asl_src_range.

    " ADR-022: a single code unit spans the half-open range [1,1) to [1,2).
    lo_range = zcl_bpc_asl_src_range=>create( iv_start_line   = 1
                                              iv_start_column = 1
                                              iv_end_line     = 1
                                              iv_end_column   = 2 ).

    cl_abap_unit_assert=>assert_equals( act = lo_range->get_start_line( )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lo_range->get_start_column( )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lo_range->get_end_line( )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lo_range->get_end_column( )
                                        exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lo_range->is_zero_width( )
                                        exp = abap_false ).
  ENDMETHOD.

  METHOD zero_width.
    DATA lo_range TYPE REF TO zcl_bpc_asl_src_range.

    lo_range = zcl_bpc_asl_src_range=>create( iv_start_line   = 1
                                              iv_start_column = 1
                                              iv_end_line     = 1
                                              iv_end_column   = 1 ).

    cl_abap_unit_assert=>assert_equals( act = lo_range->is_zero_width( )
                                        exp = abap_true ).
  ENDMETHOD.

  METHOD end_before_start_rejected.
    TRY.
        zcl_bpc_asl_src_range=>create( iv_start_line   = 2
                                       iv_start_column = 5
                                       iv_end_line     = 2
                                       iv_end_column   = 1 ).
        cl_abap_unit_assert=>fail( msg = 'Expected CX_PARAMETER_INVALID_RANGE' ).
      CATCH cx_parameter_invalid_range.
        " Expected: end precedes start on the same line.
    ENDTRY.
  ENDMETHOD.

  METHOD start_bad_line_rejected.
    TRY.
        zcl_bpc_asl_src_range=>create( iv_start_line   = 0
                                       iv_start_column = 1
                                       iv_end_line     = 1
                                       iv_end_column   = 1 ).
        cl_abap_unit_assert=>fail( msg = 'Expected CX_PARAMETER_INVALID_RANGE' ).
      CATCH cx_parameter_invalid_range.
        " Expected: invalid start line propagates from SRC_POS.
    ENDTRY.
  ENDMETHOD.

  METHOD end_line_earlier_rejected.
    " End is on an earlier line even though its column is larger: still invalid.
    TRY.
        zcl_bpc_asl_src_range=>create( iv_start_line   = 2
                                       iv_start_column = 1
                                       iv_end_line     = 1
                                       iv_end_column   = 99 ).
        cl_abap_unit_assert=>fail( msg = 'Expected CX_PARAMETER_INVALID_RANGE' ).
      CATCH cx_parameter_invalid_range.
        " Expected: line ordering dominates column ordering.
    ENDTRY.
  ENDMETHOD.

  METHOD end_line_later_accepted.
    DATA lo_range TYPE REF TO zcl_bpc_asl_src_range.

    " End is on a later line even though its column is smaller: valid.
    lo_range = zcl_bpc_asl_src_range=>create( iv_start_line   = 2
                                              iv_start_column = 99
                                              iv_end_line     = 3
                                              iv_end_column   = 1 ).

    cl_abap_unit_assert=>assert_equals( act = lo_range->get_end_line( )
                                        exp = 3 ).
  ENDMETHOD.

  METHOD negative_start_column_rejected.
    TRY.
        zcl_bpc_asl_src_range=>create( iv_start_line   = 1
                                       iv_start_column = -1
                                       iv_end_line     = 1
                                       iv_end_column   = 1 ).
        cl_abap_unit_assert=>fail( msg = 'Expected CX_PARAMETER_INVALID_RANGE' ).
      CATCH cx_parameter_invalid_range.
        " Expected: a negative start column propagates from SRC_POS.
    ENDTRY.
  ENDMETHOD.

  METHOD negative_end_line_rejected.
    TRY.
        zcl_bpc_asl_src_range=>create( iv_start_line   = 1
                                       iv_start_column = 1
                                       iv_end_line     = -1
                                       iv_end_column   = 1 ).
        cl_abap_unit_assert=>fail( msg = 'Expected CX_PARAMETER_INVALID_RANGE' ).
      CATCH cx_parameter_invalid_range.
        " Expected: a negative end line propagates from SRC_POS.
    ENDTRY.
  ENDMETHOD.

  METHOD zero_end_column_rejected.
    " End line is later than start line, so ordering passes; the rejection
    " isolates the invalid end column (0 violates the 1-based invariant).
    TRY.
        zcl_bpc_asl_src_range=>create( iv_start_line   = 1
                                       iv_start_column = 1
                                       iv_end_line     = 2
                                       iv_end_column   = 0 ).
        cl_abap_unit_assert=>fail( msg = 'Expected CX_PARAMETER_INVALID_RANGE' ).
      CATCH cx_parameter_invalid_range.
        " Expected: end column 0 violates the 1-based invariant.
    ENDTRY.
  ENDMETHOD.

  METHOD negative_end_column_rejected.
    TRY.
        zcl_bpc_asl_src_range=>create( iv_start_line   = 1
                                       iv_start_column = 1
                                       iv_end_line     = 2
                                       iv_end_column   = -1 ).
        cl_abap_unit_assert=>fail( msg = 'Expected CX_PARAMETER_INVALID_RANGE' ).
      CATCH cx_parameter_invalid_range.
        " Expected: a negative end column violates the 1-based invariant.
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
