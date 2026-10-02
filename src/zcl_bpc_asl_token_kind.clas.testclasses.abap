CLASS ltcl_token_kind DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS every_kind_valid FOR TESTING.
    METHODS all_kinds_unique FOR TESTING.
    METHODS unknown_kind_invalid FOR TESTING.
    METHODS keywords_are_single_kind FOR TESTING.
    METHODS all_kinds
      RETURNING
        VALUE(rt_kinds) TYPE string_table.

ENDCLASS.

CLASS ltcl_token_kind IMPLEMENTATION.

  METHOD all_kinds.
    APPEND zcl_bpc_asl_token_kind=>co_end_of_file   TO rt_kinds.
    APPEND zcl_bpc_asl_token_kind=>co_identifier    TO rt_kinds.
    APPEND zcl_bpc_asl_token_kind=>co_keyword       TO rt_kinds.
    APPEND zcl_bpc_asl_token_kind=>co_number        TO rt_kinds.
    APPEND zcl_bpc_asl_token_kind=>co_string        TO rt_kinds.
    APPEND zcl_bpc_asl_token_kind=>co_equals        TO rt_kinds.
    APPEND zcl_bpc_asl_token_kind=>co_not_equals    TO rt_kinds.
    APPEND zcl_bpc_asl_token_kind=>co_less_than     TO rt_kinds.
    APPEND zcl_bpc_asl_token_kind=>co_less_equal    TO rt_kinds.
    APPEND zcl_bpc_asl_token_kind=>co_greater_than  TO rt_kinds.
    APPEND zcl_bpc_asl_token_kind=>co_greater_equal TO rt_kinds.
    APPEND zcl_bpc_asl_token_kind=>co_tolerance     TO rt_kinds.
    APPEND zcl_bpc_asl_token_kind=>co_plus          TO rt_kinds.
    APPEND zcl_bpc_asl_token_kind=>co_minus         TO rt_kinds.
    APPEND zcl_bpc_asl_token_kind=>co_star          TO rt_kinds.
    APPEND zcl_bpc_asl_token_kind=>co_slash         TO rt_kinds.
    APPEND zcl_bpc_asl_token_kind=>co_semicolon     TO rt_kinds.
    APPEND zcl_bpc_asl_token_kind=>co_comma         TO rt_kinds.
    APPEND zcl_bpc_asl_token_kind=>co_dot           TO rt_kinds.
    APPEND zcl_bpc_asl_token_kind=>co_left_paren    TO rt_kinds.
    APPEND zcl_bpc_asl_token_kind=>co_right_paren   TO rt_kinds.
    APPEND zcl_bpc_asl_token_kind=>co_line_comment  TO rt_kinds.
    APPEND zcl_bpc_asl_token_kind=>co_block_comment TO rt_kinds.
  ENDMETHOD.

  METHOD every_kind_valid.
    DATA lt_kinds TYPE string_table.
    DATA lv_kind  TYPE string.

    lt_kinds = all_kinds( ).
    cl_abap_unit_assert=>assert_equals( act = lines( lt_kinds )
                                        exp = 23 ).
    LOOP AT lt_kinds INTO lv_kind.
      cl_abap_unit_assert=>assert_equals(
        act = zcl_bpc_asl_token_kind=>is_valid( lv_kind )
        exp = abap_true
        msg = |Kind { lv_kind } must be valid| ).
    ENDLOOP.
  ENDMETHOD.

  METHOD all_kinds_unique.
    DATA lt_kinds TYPE string_table.

    lt_kinds = all_kinds( ).
    SORT lt_kinds.
    DELETE ADJACENT DUPLICATES FROM lt_kinds COMPARING table_line.

    cl_abap_unit_assert=>assert_equals( act = lines( lt_kinds )
                                        exp = 23 ).
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
