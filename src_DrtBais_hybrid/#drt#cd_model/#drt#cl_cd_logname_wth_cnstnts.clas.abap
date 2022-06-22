CLASS /drt/cl_cd_logname_wth_cnstnts DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES /drt/if_cd_alv_field.
    METHODS constructor
      IMPORTING tokenizer TYPE REF TO /drt/if_cd_tokenizer.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA tokenizer TYPE REF TO /drt/if_cd_tokenizer.
    DATA logname_field_value TYPE /ibs/ebs_logname.
ENDCLASS.



CLASS /drt/cl_cd_logname_wth_cnstnts IMPLEMENTATION.
  METHOD /drt/if_cd_alv_field~detrmine_field_value_for_entry.
    DATA(token_with_logical_name_in_tab) = tokenizer->get_value_of_given_constant( 'CO_LOGICAL_NAME'  ).
    ASSIGN token_with_logical_name_in_tab[ 1 ] TO FIELD-SYMBOL(<logical_name>).
    IF <logical_name> IS NOT ASSIGNED.
      RETURN.
    ENDIF.
    me->logname_field_value = <logical_name>-str.
    REPLACE ALL OCCURRENCES OF ''''   IN me->logname_field_value WITH space.
  ENDMETHOD.

  METHOD /drt/if_cd_alv_field~get_field_value.
    result = me->logname_field_value.
  ENDMETHOD.

  METHOD constructor.
    me->tokenizer = tokenizer.
  ENDMETHOD.

ENDCLASS.
