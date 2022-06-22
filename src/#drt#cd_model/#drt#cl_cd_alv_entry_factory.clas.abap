CLASS /drt/cl_cd_alv_entry_factory DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS
      create_alv_entry_from_pp_entry
        IMPORTING pp_cus_entry            TYPE REF TO /drt/if_cd_pp_cust_entry
                  cust_display_alv_scheme TYPE REF TO cl_abap_structdescr
                  model_data              TYPE /drt/s_cd_model_data
        RETURNING VALUE(result)           TYPE REF TO /drt/if_cd_cust_alv_entry.
    CLASS-METHODS
      create_alv_entry_frm_passd_str
        IMPORTING received_structure      TYPE any
                  cust_display_alv_scheme TYPE REF TO cl_abap_structdescr
        RETURNING VALUE(result)           TYPE REF TO /drt/if_cd_cust_alv_entry.
    CLASS-METHODS
      create_alv_entry_with_src_tab
        IMPORTING
                  cust_display_alv_scheme TYPE REF TO cl_abap_structdescr
                  counter                 TYPE i
                  source_table_name       TYPE tabname
        RETURNING VALUE(result)           TYPE REF TO /drt/if_cd_cust_alv_entry.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /drt/cl_cd_alv_entry_factory IMPLEMENTATION.
  METHOD create_alv_entry_from_pp_entry.
    DATA cust_display_alv_entry TYPE REF TO data.
    CREATE DATA cust_display_alv_entry TYPE HANDLE cust_display_alv_scheme.
    ASSIGN cust_display_alv_entry->* TO FIELD-SYMBOL(<cust_display_entry>).

    DATA(str_currntly_iterated_pp_entry) = pp_cus_entry->get_pp_customizing_entry( ).

    <cust_display_entry> = CORRESPONDING #( str_currntly_iterated_pp_entry ).
    result = NEW /drt/cl_cd_cust_alv_entry(
                  str_alv_entry           = <cust_display_entry>
                  cust_display_alv_scheme = cust_display_alv_scheme ).

    DATA(just_created_alv_entry) = result->get_cust_display_alv_entry( ).
    ASSIGN just_created_alv_entry->* TO FIELD-SYMBOL(<just_created_alv_entry>).
    ASSIGN COMPONENT 'FLG_ACTIVE' OF STRUCTURE <just_created_alv_entry> TO FIELD-SYMBOL(<flag_of_alv_entry_is_active>).

    IF <flag_of_alv_entry_is_active> IS INITIAL.
      ASSIGN COMPONENT 'CLASSNAME' OF STRUCTURE <just_created_alv_entry> TO FIELD-SYMBOL(<class_name_ohne_diff>).
      <class_name_ohne_diff> = 'AUSGESCHALTET'(001).
    ELSE.
      result->read_pp_group_std_clss(
                  model_data                  = model_data
                  currently_iterated_pp_entry = pp_cus_entry ).
    ENDIF.
  ENDMETHOD.

  METHOD create_alv_entry_frm_passd_str.
    result = NEW /drt/cl_cd_cust_alv_entry(
                  str_alv_entry           = received_structure
                  cust_display_alv_scheme = cust_display_alv_scheme ).
  ENDMETHOD.

  METHOD create_alv_entry_with_src_tab.
    DATA alv_entry TYPE REF TO data.
    CREATE DATA alv_entry TYPE HANDLE cust_display_alv_scheme.
    ASSIGN alv_entry->* TO FIELD-SYMBOL(<alv_entry>).
    FIELD-SYMBOLS: <logname> TYPE /drt/e_logname.

    TRY.
        ASSIGN COMPONENT 'LOGNAME' OF STRUCTURE <alv_entry> TO <logname>.
        <logname> = counter && '. Quelltabelle' && '>>>' && source_table_name.
        result = NEW /drt/cl_cd_cust_alv_entry(
                      str_alv_entry           = <alv_entry>
                      cust_display_alv_scheme = cust_display_alv_scheme ).
      CATCH cx_root INTO DATA(msg_cx_root).
        DATA(error_text) = msg_cx_root->get_text( ).
        error_text = error_text && 'cx_root'.
        MESSAGE i398(00) WITH error_text space space space.
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
