" Lexical token kinds (Phase 0 / Slice 1).
"
" The single, centralized token vocabulary for the ASL language. The lexer and
" parser must reference these constants and must not define their own conflicting
" token names.
"
" Reserved words are a single KEYWORD kind: the specific keyword is carried in
" the token's normalized value (uppercase). This keeps the vocabulary small and
" makes the lexer's keyword table the only place that lists reserved words.
"
" Trivia (LINE_COMMENT, BLOCK_COMMENT) are defined here so the formatter can
" preserve them; whether the lexer emits or skips them is a lexer-slice decision.
"
" Stateless utility class: only constants and class-methods are exposed; it is
" not instantiable.
CLASS zcl_bpc_asl_token_kind DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.

    CONSTANTS:
      co_end_of_file   TYPE string VALUE 'END_OF_FILE',
      co_identifier    TYPE string VALUE 'IDENTIFIER',
      co_keyword       TYPE string VALUE 'KEYWORD',
      co_number        TYPE string VALUE 'NUMBER',
      co_string        TYPE string VALUE 'STRING',
      co_equals        TYPE string VALUE 'EQUALS',
      co_not_equals    TYPE string VALUE 'NOT_EQUALS',
      co_less_than     TYPE string VALUE 'LESS_THAN',
      co_less_equal    TYPE string VALUE 'LESS_EQUAL',
      co_greater_than  TYPE string VALUE 'GREATER_THAN',
      co_greater_equal TYPE string VALUE 'GREATER_EQUAL',
      co_tolerance     TYPE string VALUE 'TOLERANCE',
      co_plus          TYPE string VALUE 'PLUS',
      co_minus         TYPE string VALUE 'MINUS',
      co_star          TYPE string VALUE 'STAR',
      co_slash         TYPE string VALUE 'SLASH',
      co_semicolon     TYPE string VALUE 'SEMICOLON',
      co_comma         TYPE string VALUE 'COMMA',
      co_dot           TYPE string VALUE 'DOT',
      co_left_paren    TYPE string VALUE 'LEFT_PAREN',
      co_right_paren   TYPE string VALUE 'RIGHT_PAREN',
      co_line_comment  TYPE string VALUE 'LINE_COMMENT',
      co_block_comment TYPE string VALUE 'BLOCK_COMMENT'.

    CLASS-METHODS is_valid
      IMPORTING
        !iv_kind TYPE string
      RETURNING
        VALUE(rv_flag) TYPE abap_bool.

ENDCLASS.

CLASS zcl_bpc_asl_token_kind IMPLEMENTATION.

  METHOD is_valid.
    CASE iv_kind.
      WHEN co_end_of_file OR co_identifier OR co_keyword OR co_number
        OR co_string OR co_equals OR co_not_equals OR co_less_than
        OR co_less_equal OR co_greater_than OR co_greater_equal
        OR co_tolerance OR co_plus OR co_minus OR co_star OR co_slash
        OR co_semicolon OR co_comma OR co_dot OR co_left_paren
        OR co_right_paren OR co_line_comment OR co_block_comment.
        rv_flag = abap_true.
      WHEN OTHERS.
        rv_flag = abap_false.
    ENDCASE.
  ENDMETHOD.

ENDCLASS.
