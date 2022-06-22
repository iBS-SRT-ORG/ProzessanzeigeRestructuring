CLASS /drt/cl_cd_tokenizer DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES /drt/if_cd_tokenizer.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA tokens TYPE stokes_tab.
ENDCLASS.

CLASS /drt/cl_cd_tokenizer IMPLEMENTATION.
  METHOD /drt/if_cd_tokenizer~tokenize_given_class.
    DATA source_scanner TYPE REF TO /drt/if_cd_source_scanner.
    source_scanner = NEW /drt/cl_cd_source_scanner( class_name ).
    me->tokens = source_scanner->get_tokens( ).
  ENDMETHOD.

  METHOD /drt/if_cd_tokenizer~tokenize_given_classes.
    DATA source_scanner TYPE REF TO /drt/if_cd_source_scanner.
    LOOP AT class_names ASSIGNING FIELD-SYMBOL(<class_name>).
      source_scanner = NEW /drt/cl_cd_source_scanner( <class_name>-class_name_in_alv_entry ).
      INSERT LINES OF source_scanner->get_tokens( ) INTO TABLE me->tokens.
    ENDLOOP.
  ENDMETHOD.
  METHOD /drt/if_cd_tokenizer~get_sorted_tkns_no_duplicates.
    result = me->tokens.
    SORT result.
    DELETE ADJACENT DUPLICATES FROM result.
  ENDMETHOD.

  METHOD /drt/if_cd_tokenizer~get_unaltered_tokens.
    result = me->tokens.
  ENDMETHOD.

  METHOD /drt/if_cd_tokenizer~filter_tkns_that_match_pattern.
    LOOP AT tokens ASSIGNING FIELD-SYMBOL(<token>).
      IF <token>-str CP pattern.
        INSERT <token> INTO TABLE result.
      ENDIF.
    ENDLOOP.
    SORT result.
    DELETE ADJACENT DUPLICATES FROM result.
  ENDMETHOD.
  METHOD /drt/if_cd_tokenizer~filter_cmpnts_with_assgn_comp.
    LOOP AT me->tokens ASSIGNING FIELD-SYMBOL(<token>).
      IF <token>-str EQ 'ASSIGN'.
        DATA(index_with_potential_component) = sy-tabix.
        IF me->tokens[ index_with_potential_component + 1 ]-str EQ 'COMPONENT'.
          INSERT me->tokens[ index_with_potential_component + 2 ] INTO TABLE result.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
  METHOD /drt/if_cd_tokenizer~get_value_of_given_constant.
    LOOP AT tokens ASSIGNING FIELD-SYMBOL(<token>).
      IF <token>-str EQ name_of_constant.
      DATA(start_index_of_co_definition) = sy-tabix.
      INSERT tokens[ start_index_of_co_definition + 4 ] INTO TABLE result.
      ENDIF.
    ENDLOOP.
    SORT result.
    DELETE ADJACENT DUPLICATES FROM result.
  ENDMETHOD.

ENDCLASS.
