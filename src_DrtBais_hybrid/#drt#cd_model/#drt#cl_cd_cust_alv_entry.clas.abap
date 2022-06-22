CLASS /drt/cl_cd_cust_alv_entry DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES /drt/if_cd_cust_alv_entry .
    METHODS constructor
      IMPORTING
        str_alv_entry           TYPE any
        cust_display_alv_scheme TYPE REF TO cl_abap_structdescr.
    TYPES: BEGIN OF diff_criteria_value,
             diff_criteria_value TYPE char30,
           END OF diff_criteria_value.
    TYPES diff_criteria_values TYPE SORTED TABLE OF diff_criteria_value WITH NON-UNIQUE KEY diff_criteria_value.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA cust_display_alv_entry TYPE REF TO data.
    DATA cust_display_alv_entry_key TYPE /ibs/sbs_pp_cus_disp_check_key.
    DATA all_class_names_in_alv_entry TYPE /drt/ty_cd_clss_names_in_entry.
    DATA model_data TYPE /drt/s_cd_model_data.
    METHODS fill_cash_component
      IMPORTING model_data                  TYPE /drt/s_cd_model_data
                currently_iterated_pp_entry TYPE REF TO /drt/if_cd_pp_cust_entry.
    METHODS collct_all_clss_names_in_entry
      IMPORTING model_data TYPE /drt/s_cd_model_data.
    METHODS is_class_name
      IMPORTING value_present_in_alv_entry TYPE c
      RETURNING VALUE(result)              TYPE flag.
    METHODS collect_all_dif_crteria_values
      IMPORTING model_data    TYPE /drt/s_cd_model_data
      RETURNING VALUE(result) TYPE diff_criteria_values.
    METHODS determine_logname
      IMPORTING
        model_data TYPE /drt/s_cd_model_data
        tokenizer  TYPE REF TO /drt/if_cd_tokenizer.
    METHODS determine_cust_tab_info
      IMPORTING
        model_data TYPE /drt/s_cd_model_data.
    METHODS det_parameter_service_info
      IMPORTING
        model_data TYPE /drt/s_cd_model_data.
    METHODS dtrmine_values_fitting_pattern
      IMPORTING
        tokenizer        TYPE REF TO /drt/if_cd_tokenizer
        field_name       TYPE char30
        pattern_to_match TYPE string.
    METHODS determine_mapping_components
      IMPORTING
        tokenizer TYPE REF TO /drt/if_cd_tokenizer.
    METHODS determine_mapping_string
      IMPORTING
        tokenizer TYPE REF TO /drt/if_cd_tokenizer.
    METHODS determine_mapping_table
      IMPORTING
        tokenizer TYPE REF TO /drt/if_cd_tokenizer.
    METHODS determine_customizing_ids
      IMPORTING
        tokenizer TYPE REF TO /drt/if_cd_tokenizer.
    METHODS determine_rapis
      IMPORTING
        tokenizer TYPE REF TO /drt/if_cd_tokenizer.
ENDCLASS.

CLASS /drt/cl_cd_cust_alv_entry IMPLEMENTATION.

  METHOD constructor.
    CREATE DATA me->cust_display_alv_entry TYPE HANDLE cust_display_alv_scheme.
    ASSIGN cust_display_alv_entry->* TO FIELD-SYMBOL(<cust_display_entry>).

    <cust_display_entry> = CORRESPONDING #( str_alv_entry ).
    me->cust_display_alv_entry_key = CORRESPONDING #( str_alv_entry ).

  ENDMETHOD.

  METHOD /drt/if_cd_cust_alv_entry~fill_iterated_dif_crit_field.
    ASSIGN me->cust_display_alv_entry->* TO FIELD-SYMBOL(<cust_display_alv_entry>).
    ASSIGN COMPONENT currently_iterated_pp_entry->get_differentiation_criteria( ) OF STRUCTURE <cust_display_alv_entry> TO FIELD-SYMBOL(<differentiation_criteria>).
    DATA(str_crrently_iterated_pp_entry) = currently_iterated_pp_entry->get_pp_customizing_entry( ).

    IF <differentiation_criteria> IS NOT ASSIGNED.
      RETURN.
    ENDIF.
    IF currently_iterated_pp_entry->is_diff_criteria_inactive( ).
      <differentiation_criteria> = 'AUSGESCHALTET'(001).
      RETURN.
    ENDIF.
    IF currently_iterated_pp_entry->is_cash_comp_exists_but_deact( ).
      <differentiation_criteria> = 'inaktive Cash-Komponente'(002).
      RETURN.
    ENDIF.
    IF currently_iterated_pp_entry->is_function_set_exists( ).
      <differentiation_criteria> = str_crrently_iterated_pp_entry-classname && ' (' && str_crrently_iterated_pp_entry-func_set && ')'.
      RETURN.
    ENDIF.
    IF me->/drt/if_cd_cust_alv_entry~is_diff_cls_not_eq_to_std_cls( str_crrently_iterated_pp_entry-classname ).
      <differentiation_criteria> = str_crrently_iterated_pp_entry-classname.
      me->fill_cash_component(
             model_data                  = model_data
             currently_iterated_pp_entry = currently_iterated_pp_entry ).
    ENDIF.
  ENDMETHOD.

  METHOD fill_cash_component.
    ASSIGN cust_display_alv_entry->* TO FIELD-SYMBOL(<cust_display_alv_entry>).
    ASSIGN COMPONENT /drt/co_cd_general_constants=>cash_component OF STRUCTURE <cust_display_alv_entry> TO FIELD-SYMBOL(<cash_comp_from_alv>).
    DATA(cash_comp_from_current_entry) = currently_iterated_pp_entry->get_cash_component( ).
    IF <cash_comp_from_alv> IS NOT ASSIGNED.
      RETURN.
    ENDIF.
    IF cash_comp_from_current_entry IS NOT INITIAL.
      <cash_comp_from_alv> = cash_comp_from_current_entry.
    ENDIF.
    "Erweiterung Cash-Component Informationen über Systemtabelle
    ASSIGN model_data-tab_cash_component_ids[ dfval = currently_iterated_pp_entry->get_differentiation_criteria( ) ] TO FIELD-SYMBOL(<component_id>).
    IF sy-subrc NE 0.
      RETURN.
    ENDIF.
    IF <cash_comp_from_alv> IS INITIAL.
      <cash_comp_from_alv> = <component_id>-cash_comp.
    ELSE.
      IF <cash_comp_from_alv> NS <component_id>-cash_comp.
        <cash_comp_from_alv> = <cash_comp_from_alv> && ',' && <component_id>-cash_comp.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD /drt/if_cd_cust_alv_entry~get_cust_display_alv_entry.
    result = me->cust_display_alv_entry.
  ENDMETHOD.

  METHOD /drt/if_cd_cust_alv_entry~is_key_identical_to.
    IF pp_customizing_entry->get_pp_customizing_entry( )-pp_grp = me->cust_display_alv_entry_key-pp_grp AND pp_customizing_entry->get_pp_customizing_entry( )-stepno = me->cust_display_alv_entry_key-stepno.
      result = abap_true.
    ELSE.
      result = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD /drt/if_cd_cust_alv_entry~is_diff_cls_not_eq_to_std_cls.
    ASSIGN me->cust_display_alv_entry->* TO FIELD-SYMBOL(<cust_display_alv_entry>).
    ASSIGN COMPONENT /drt/co_cd_general_constants=>pp_standard_classname OF STRUCTURE <cust_display_alv_entry> TO FIELD-SYMBOL(<std_classname>).
    IF diff_criteria_class_name NE <std_classname>.
      result = abap_true.
    ELSE.
      result = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD /drt/if_cd_cust_alv_entry~is_diff_criteria_inactive.
    ASSIGN cust_display_alv_entry->* TO FIELD-SYMBOL(<pp_customizing_entry>).
    ASSIGN COMPONENT diff_criteria_field_name OF STRUCTURE me->cust_display_alv_entry TO FIELD-SYMBOL(<diff_criteria_field_name>).
  ENDMETHOD.

  METHOD /drt/if_cd_cust_alv_entry~read_pp_group_std_clss.
    ASSIGN cust_display_alv_entry->* TO FIELD-SYMBOL(<cust_display_entry>).
    ASSIGN COMPONENT /drt/co_cd_general_constants=>class_ohne_differenzierung OF STRUCTURE <cust_display_entry> TO FIELD-SYMBOL(<class_name_ohne_diff>).
    TRY.
        ASSIGN model_data-tab_pp_groups[ pp_grp = currently_iterated_pp_entry->get_pp_customizing_entry( )-pp_grp ] TO FIELD-SYMBOL(<pp_group>).
        IF <pp_group>-classname IS INITIAL.
          RETURN.
        ENDIF.
        IF <pp_group>-classname = <class_name_ohne_diff>.
          CLEAR <class_name_ohne_diff>.
        ENDIF.
        ASSIGN COMPONENT /drt/co_cd_general_constants=>pp_standard_classname OF STRUCTURE <cust_display_entry> TO FIELD-SYMBOL(<alv_entry_std_classname>).
        <alv_entry_std_classname> = <pp_group>-classname.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.
  ENDMETHOD.

  METHOD collect_all_dif_crteria_values.
    DATA diff_criteria_to_insert TYPE diff_criteria_value.
    LOOP AT model_data-tab_differentiation_criteria ASSIGNING FIELD-SYMBOL(<differentation_criteria>).
      diff_criteria_to_insert = me->/drt/if_cd_cust_alv_entry~get_differentiation_criteria( <differentation_criteria>-prod_dif_cat ).
      IF diff_criteria_to_insert IS NOT INITIAL.
        INSERT diff_criteria_to_insert INTO TABLE result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD /drt/if_cd_cust_alv_entry~dtrmn_yet_missing_column_info.

    me->determine_cust_tab_info( model_data ).
    me->det_parameter_service_info( model_data ).
    me->collct_all_clss_names_in_entry( model_data ).

    DATA tokenizer TYPE REF TO /drt/if_cd_tokenizer.
    tokenizer = NEW /drt/cl_cd_tokenizer( ).
    tokenizer->tokenize_given_classes( me->all_class_names_in_alv_entry ).
    me->determine_logname(
            model_data = model_data
            tokenizer  = tokenizer ).
    me->determine_customizing_ids( tokenizer ).
    me->determine_rapis( tokenizer ).
    me->determine_mapping_components( tokenizer ).
  ENDMETHOD.

  METHOD determine_logname.
    ASSIGN me->cust_display_alv_entry->* TO FIELD-SYMBOL(<alv_cust_display_entry>).
    ASSIGN COMPONENT /drt/co_cd_general_constants=>logname OF STRUCTURE <alv_cust_display_entry> TO FIELD-SYMBOL(<logname>).
    IF <logname> IS NOT INITIAL.
      RETURN.
    ENDIF.
    DATA(logname_object) = /drt/cl_cd_logname_s_factory=>get_logname_class( logname_factory_im_params = VALUE /drt/s_cd_logname_fctry_params(
                                                                                                                    alv_entry  = REF #( <alv_cust_display_entry> )
                                                                                                                    model_data = model_data
                                                                                                                    tokenizer  = tokenizer ) ).
    logname_object->detrmine_field_value_for_entry( ).
    <logname> = logname_object->get_field_value( ).
  ENDMETHOD.

  METHOD determine_cust_tab_info.
    "ToDo: noch nicht refaktorisiert, aus altem Report kopiert. -> auch hier: eigene determine_cust_tab_info-Klasse erstellen
    DATA:
      value_cust_tab_info     TYPE /ibs/ebs_cust_tab_info,
      tab_cust_tab_info       TYPE TABLE OF /ibs/ebs_cust_tab_info,
      tab_tmp_cust_tab_info   TYPE TABLE OF /ibs/ebs_cust_tab_info,
      str_tmp_cust_tab_info   TYPE /ibs/ebs_cust_tab_info,
      str_cust_tab_info       TYPE /ibs/ebs_cust_tab_info,
      count_tab_cust_tab_info TYPE int4,
      str_prod_dif_disp       TYPE /ibs/vbs_proddis,
      msg_cx_root             TYPE REF TO cx_root,
      str_error_text          TYPE string.

    FIELD-SYMBOLS:
      <comp_classnamestd>   TYPE any,
      <comp_classnameodiff> TYPE any,
      <comp_classnamediff>  TYPE any,
      <comp_cust_tab_info>  TYPE /ibs/ebs_cust_tab_info.
    ASSIGN me->cust_display_alv_entry->* TO FIELD-SYMBOL(<alv_cust_display_entry>).

    TRY.
        ASSIGN COMPONENT /drt/co_cd_general_constants=>customizing_tables_info OF STRUCTURE <alv_cust_display_entry> TO <comp_cust_tab_info>.

        IF sy-subrc = 0.
* ...anhand der Standardklasse
          ASSIGN COMPONENT /drt/co_cd_general_constants=>pp_standard_classname OF STRUCTURE <alv_cust_display_entry> TO <comp_classnamestd>.
          SELECT COUNT(*) FROM seoclass WHERE clsname = <comp_classnamestd>.

          IF sy-subrc = 0.
            SELECT SINGLE cust_tab_info FROM /ibs/cbs_logname INTO value_cust_tab_info WHERE classname = <comp_classnamestd>.
            IF sy-subrc = 0 AND value_cust_tab_info IS NOT INITIAL.
* Prüfen auf Dublikate der Customizingtabellen Information (CUST_TAB_INFO)
* Inhalt wird gespiltet, damit jede Customizingtabelle einzelnd steht
              SPLIT value_cust_tab_info AT space INTO TABLE tab_tmp_cust_tab_info.
* In einem Loop wird verglichen ob die Customizingtabelle schon in das, für den Prozessschritt, vorgeschrieben Feld steht.
* Falls Ja wird die Tabelle nicht erneut aufgenommen
              LOOP AT tab_tmp_cust_tab_info INTO str_tmp_cust_tab_info.
                READ TABLE tab_cust_tab_info INTO value_cust_tab_info WITH TABLE KEY table_line = str_tmp_cust_tab_info.
                IF sy-subrc <> 0.
                  APPEND str_tmp_cust_tab_info TO tab_cust_tab_info.
                  CONCATENATE <comp_cust_tab_info> str_tmp_cust_tab_info INTO <comp_cust_tab_info> SEPARATED BY space.
                ENDIF.
              ENDLOOP.
            ENDIF.
          ENDIF.

* ...anhand der Klasse ohne Differenzierung
          ASSIGN COMPONENT /drt/co_cd_general_constants=>class_ohne_differenzierung OF STRUCTURE <alv_cust_display_entry> TO <comp_classnameodiff>.
          SELECT COUNT(*) FROM seoclass WHERE clsname = <comp_classnameodiff>.

          IF sy-subrc = 0.
            SELECT SINGLE cust_tab_info FROM /ibs/cbs_logname INTO value_cust_tab_info WHERE classname = <comp_classnameodiff>.
            IF sy-subrc = 0 AND value_cust_tab_info IS NOT INITIAL.

              SPLIT value_cust_tab_info AT space INTO TABLE tab_tmp_cust_tab_info.

              LOOP AT tab_tmp_cust_tab_info INTO str_tmp_cust_tab_info.
                READ TABLE tab_cust_tab_info INTO value_cust_tab_info WITH TABLE KEY table_line = str_tmp_cust_tab_info.
                IF sy-subrc <> 0.
                  APPEND str_tmp_cust_tab_info TO tab_cust_tab_info.
                  CONCATENATE <comp_cust_tab_info> str_tmp_cust_tab_info INTO <comp_cust_tab_info> SEPARATED BY space.
                ENDIF.
              ENDLOOP.
            ENDIF.
          ENDIF.

* ...anhand der ersten Klasse mit Differenzierung
          LOOP AT model_data-tab_differentiation_criteria INTO str_prod_dif_disp.
            ASSIGN COMPONENT str_prod_dif_disp-prod_dif_cat OF STRUCTURE <alv_cust_display_entry> TO <comp_classnamediff>.
            SELECT COUNT(*) FROM seoclass WHERE clsname = <comp_classnamediff>.

            IF sy-subrc = 0.
              SELECT SINGLE cust_tab_info FROM /ibs/cbs_logname INTO value_cust_tab_info WHERE classname = <comp_classnamediff>.

              IF sy-subrc = 0 AND value_cust_tab_info IS NOT INITIAL.

                SPLIT value_cust_tab_info AT space INTO TABLE tab_tmp_cust_tab_info.

                LOOP AT tab_tmp_cust_tab_info INTO str_tmp_cust_tab_info.
                  READ TABLE tab_cust_tab_info INTO value_cust_tab_info WITH TABLE KEY table_line = str_tmp_cust_tab_info.
                  IF sy-subrc <> 0.
                    APPEND str_tmp_cust_tab_info TO tab_cust_tab_info.
                    CONCATENATE <comp_cust_tab_info> str_tmp_cust_tab_info INTO <comp_cust_tab_info> SEPARATED BY space.
                  ENDIF.
                ENDLOOP.
              ENDIF.
            ENDIF.
          ENDLOOP.

        ENDIF.
      CATCH cx_root INTO msg_cx_root.
*        MESSAGE msg_cx_root->get_text( ) TYPE 'I'.
        str_error_text = msg_cx_root->get_text( ).
        CONCATENATE  str_error_text 'cx_root'
        INTO  str_error_text.
        MESSAGE i398(00) WITH str_error_text space space space.
    ENDTRY.

    CLEAR tab_cust_tab_info.

  ENDMETHOD.

  METHOD det_parameter_service_info.
    "ToDo: noch nicht refaktorisiert, aus altem Report kopiert. -> auch hier: eigene Param_service_info-Klasse erstellen
    DATA:
      value_param_service     TYPE /ibs/ebs_param_service_info,
      tab_param_service       TYPE TABLE OF /ibs/ebs_param_service_info,
      tab_tmp_param_service   TYPE TABLE OF /ibs/ebs_param_service_info,
      str_tmp_param_service   TYPE /ibs/ebs_param_service_info,
      str_param_service       TYPE /ibs/ebs_param_service_info,
      count_tab_param_service TYPE int4,
      str_prod_dif_disp       TYPE /ibs/vbs_proddis,
      msg_cx_root             TYPE REF TO cx_root,
      str_error_text          TYPE string.

    FIELD-SYMBOLS:
      <comp_classnamestd>   TYPE any,
      <comp_classnameodiff> TYPE any,
      <comp_classnamediff>  TYPE any,
      <comp_param_service>  TYPE /ibs/ebs_param_service_info.
    ASSIGN me->cust_display_alv_entry->* TO FIELD-SYMBOL(<alv_cust_display_entry>).


    TRY.
        ASSIGN COMPONENT /drt/co_cd_general_constants=>parameter_service OF STRUCTURE <alv_cust_display_entry> TO <comp_param_service>.

        IF sy-subrc = 0.
* ...anhand der Standardklasse
          ASSIGN COMPONENT /drt/co_cd_general_constants=>pp_standard_classname OF STRUCTURE <alv_cust_display_entry> TO <comp_classnamestd>.
          SELECT COUNT(*) FROM seoclass WHERE clsname = <comp_classnamestd>.

          IF sy-subrc = 0.
            SELECT SINGLE param_service FROM /ibs/cbs_logname INTO value_param_service WHERE classname = <comp_classnamestd>.
            IF sy-subrc = 0 AND value_param_service IS NOT INITIAL.
* Prüfen auf Dublikate der Customizingtabellen Information (PARAM_SERVICE)
* Inhalt wird gespiltet, damit jede Customizingtabelle einzelnd steht
              SPLIT value_param_service AT space INTO TABLE tab_tmp_param_service.
* In einem Loop wird verglichen ob die Customizingtabelle schon in das, für den Prozessschritt, vorgeschrieben Feld steht.
* Falls Ja wird die Tabelle nicht erneut aufgenommen
              LOOP AT tab_tmp_param_service INTO str_tmp_param_service.
                READ TABLE tab_param_service INTO value_param_service WITH TABLE KEY table_line = str_tmp_param_service.
                IF sy-subrc <> 0.
                  APPEND str_tmp_param_service TO tab_param_service.
                  CONCATENATE <comp_param_service> str_tmp_param_service INTO <comp_param_service> SEPARATED BY space.
                ENDIF.
              ENDLOOP.
            ENDIF.
          ENDIF.

* ...anhand der Klasse ohne Differenzierung
          ASSIGN COMPONENT /drt/co_cd_general_constants=>class_ohne_differenzierung OF STRUCTURE <alv_cust_display_entry> TO <comp_classnameodiff>.
          SELECT COUNT(*) FROM seoclass WHERE clsname = <comp_classnameodiff>.

          IF sy-subrc = 0.
            SELECT SINGLE param_service FROM /ibs/cbs_logname INTO value_param_service WHERE classname = <comp_classnameodiff>.
            IF sy-subrc = 0 AND value_param_service IS NOT INITIAL.

              SPLIT value_param_service AT space INTO TABLE tab_tmp_param_service.

              LOOP AT tab_tmp_param_service INTO str_tmp_param_service.
                READ TABLE tab_param_service INTO value_param_service WITH TABLE KEY table_line = str_tmp_param_service.
                IF sy-subrc <> 0.
                  APPEND str_tmp_param_service TO tab_param_service.
                  CONCATENATE <comp_param_service> str_tmp_param_service INTO <comp_param_service> SEPARATED BY space.
                ENDIF.
              ENDLOOP.
            ENDIF.
          ENDIF.

* ...anhand der ersten Klasse mit Differenzierung
          LOOP AT model_data-tab_differentiation_criteria INTO str_prod_dif_disp.
            ASSIGN COMPONENT str_prod_dif_disp-prod_dif_cat OF STRUCTURE <alv_cust_display_entry> TO <comp_classnamediff>.
            SELECT COUNT(*) FROM seoclass WHERE clsname = <comp_classnamediff>.

            IF sy-subrc = 0.
              SELECT SINGLE param_service FROM /ibs/cbs_logname INTO value_param_service WHERE classname = <comp_classnamediff>.

              IF sy-subrc = 0 AND value_param_service IS NOT INITIAL.

                SPLIT value_param_service AT space INTO TABLE tab_tmp_param_service.

                LOOP AT tab_tmp_param_service INTO str_tmp_param_service.
                  READ TABLE tab_param_service INTO value_param_service WITH TABLE KEY table_line = str_tmp_param_service.
                  IF sy-subrc <> 0.
                    APPEND str_tmp_param_service TO tab_param_service.
                    CONCATENATE <comp_param_service> str_tmp_param_service INTO <comp_param_service> SEPARATED BY space.
                  ENDIF.
                ENDLOOP.
              ENDIF.
            ENDIF.
          ENDLOOP.

        ENDIF.
      CATCH cx_root INTO msg_cx_root.
        str_error_text = msg_cx_root->get_text( ).
        CONCATENATE  str_error_text 'cx_root'
        INTO  str_error_text.
        MESSAGE i398(00) WITH str_error_text space space space.
    ENDTRY.
    CLEAR tab_param_service.
  ENDMETHOD.

  METHOD collct_all_clss_names_in_entry.
    IF is_class_name( me->/drt/if_cd_cust_alv_entry~get_std_pp_group_class_name( ) ).
      INSERT CONV char30( me->/drt/if_cd_cust_alv_entry~get_std_pp_group_class_name( ) ) INTO TABLE me->all_class_names_in_alv_entry.
    ENDIF.
    IF is_class_name( me->/drt/if_cd_cust_alv_entry~get_class_name_ohne_dffrnzrng( ) ).
      INSERT CONV char30( me->/drt/if_cd_cust_alv_entry~get_class_name_ohne_dffrnzrng( ) ) INTO TABLE me->all_class_names_in_alv_entry.
    ENDIF.
    DATA(all_diff_criteria_values) = me->collect_all_dif_crteria_values( model_data ).
    LOOP AT all_diff_criteria_values ASSIGNING FIELD-SYMBOL(<diff_criteria_value>).
      IF is_class_name( <diff_criteria_value>-diff_criteria_value ).
        INSERT CONV char30( <diff_criteria_value>-diff_criteria_value ) INTO TABLE me->all_class_names_in_alv_entry.
      ENDIF.
    ENDLOOP.
    DELETE ADJACENT DUPLICATES FROM me->all_class_names_in_alv_entry.
  ENDMETHOD.

  METHOD is_class_name.
    IF value_present_in_alv_entry IS INITIAL.
      RETURN.
    ENDIF.
    IF substring( val = value_present_in_alv_entry off = 0 len = 1 ) EQ '/'.
      result = abap_true.
    ELSE.
      result = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD /drt/if_cd_cust_alv_entry~get_std_pp_group_class_name.
    ASSIGN me->cust_display_alv_entry->* TO FIELD-SYMBOL(<cust_display_alv_entry>).
    ASSIGN COMPONENT /drt/co_cd_general_constants=>pp_standard_classname OF STRUCTURE <cust_display_alv_entry> TO FIELD-SYMBOL(<result>).
    IF <result> IS ASSIGNED.
      result = <result>.
    ENDIF.
  ENDMETHOD.
  METHOD /drt/if_cd_cust_alv_entry~get_differentiation_criteria.
    ASSIGN me->cust_display_alv_entry->* TO FIELD-SYMBOL(<cust_display_alv_entry>).
    ASSIGN COMPONENT diff_criteria_field_name OF STRUCTURE <cust_display_alv_entry> TO FIELD-SYMBOL(<result>).
    IF <result> IS ASSIGNED.
      result = <result>.
    ENDIF.
  ENDMETHOD.

  METHOD /drt/if_cd_cust_alv_entry~get_class_name_ohne_dffrnzrng.
    ASSIGN me->cust_display_alv_entry->* TO FIELD-SYMBOL(<cust_display_alv_entry>).
    ASSIGN COMPONENT /drt/co_cd_general_constants=>class_ohne_differenzierung OF STRUCTURE <cust_display_alv_entry> TO FIELD-SYMBOL(<result>).
    IF <result> IS ASSIGNED.
      result = <result>.
    ENDIF.
  ENDMETHOD.

  METHOD /drt/if_cd_cust_alv_entry~get_cash_component.
    ASSIGN me->cust_display_alv_entry->* TO FIELD-SYMBOL(<cust_display_alv_entry>).
    ASSIGN COMPONENT /drt/co_cd_general_constants=>cash_component OF STRUCTURE <cust_display_alv_entry> TO FIELD-SYMBOL(<result>).
    IF <result> IS ASSIGNED.
      result = <result>.
    ENDIF.
  ENDMETHOD.

  METHOD dtrmine_values_fitting_pattern.
    ASSIGN me->cust_display_alv_entry->* TO FIELD-SYMBOL(<cust_display_alv_entry>).
    ASSIGN COMPONENT field_name OF STRUCTURE <cust_display_alv_entry> TO FIELD-SYMBOL(<field_to_find_values_for>).
    DATA(tokens_that_match_pattern) = tokenizer->filter_tkns_that_match_pattern( pattern_to_match ).
    LOOP AT tokens_that_match_pattern ASSIGNING FIELD-SYMBOL(<token>).
      ASSIGN (<token>-str) TO FIELD-SYMBOL(<value_of_constant>).
      <token>-str = <value_of_constant>.
    ENDLOOP.
    <field_to_find_values_for> = /drt/cl_cd_table_to_string=>concatenate_entrys_to_string(
                                                                  table_to_concatenate = tokens_that_match_pattern
                                                                  field_name           = 'str' ).
  ENDMETHOD.


  METHOD determine_mapping_components.
    me->determine_mapping_string( tokenizer ).
    me->determine_mapping_table( tokenizer ).
  ENDMETHOD.

  METHOD /drt/if_cd_cust_alv_entry~get_all_clsnames_in_entry.
    me->collct_all_clss_names_in_entry( model_data ).
    result = me->all_class_names_in_alv_entry.
  ENDMETHOD.


  METHOD determine_mapping_string.
    ASSIGN me->cust_display_alv_entry->* TO FIELD-SYMBOL(<cust_display_alv_entry>).
    ASSIGN COMPONENT /drt/co_cd_general_constants=>mappings_string OF STRUCTURE <cust_display_alv_entry> TO FIELD-SYMBOL(<mapping_components>).

    DATA(mapping_components) = tokenizer->filter_cmpnts_with_assgn_comp( ).
    <mapping_components> = /drt/cl_cd_table_to_string=>concatenate_entrys_to_string(
                                                                  table_to_concatenate = mapping_components
                                                                  field_name           = 'str' ).
  ENDMETHOD.

  METHOD determine_mapping_table.
    "ToDo: Refactor -> wohl am besten eigene Mapping-Klasse zu erstellen und auszulagern!
    FIELD-SYMBOLS: <mapping_table> TYPE /drt/ty_cd_mapping_popup.
    ASSIGN me->cust_display_alv_entry->* TO FIELD-SYMBOL(<cust_display_alv_entry>).
    ASSIGN COMPONENT /drt/co_cd_general_constants=>mapping_table OF STRUCTURE <cust_display_alv_entry> TO <mapping_table>.
    DATA(tokenized_mapping_components) = tokenizer->filter_cmpnts_with_assgn_comp( ).
    DATA(helper_index) = 1.
    DATA(source_index) = 1.
    DATA(target_index) = 1.
    LOOP AT tokenized_mapping_components ASSIGNING FIELD-SYMBOL(<mapping_component>).
      IF <mapping_component>-str CP '*HELPER*'.
        ASSIGN <mapping_table>[ helper_index ] TO FIELD-SYMBOL(<mapping_entry>).
        IF <mapping_entry> IS ASSIGNED.
          <mapping_entry>-helper = <mapping_component>-str.
        ELSE.
          INSERT VALUE /drt/s_cd_mapping_popup(
                          source      = ''
                          helper      = <mapping_component>-str
                          target      = '' ) INTO TABLE <mapping_table>.
        ENDIF.
        helper_index = helper_index + 1.
        CONTINUE.
      ENDIF.
      IF <mapping_component>-str CP '*SOURCE*'.
        ASSIGN <mapping_table>[ source_index ] TO <mapping_entry>.
        IF <mapping_entry> IS ASSIGNED.
          <mapping_entry>-source = <mapping_component>-str.
        ELSE.

          INSERT VALUE /drt/s_cd_mapping_popup(
                          source      = <mapping_component>-str
                          helper      = ''
                          target      = '' ) INTO TABLE <mapping_table>.
        ENDIF.
        source_index = source_index + 1.
        CONTINUE.
      ENDIF.
      IF <mapping_component>-str CP '*TARGET*'.

        ASSIGN <mapping_table>[ target_index ] TO <mapping_entry>.
        IF <mapping_entry> IS ASSIGNED.
          <mapping_entry>-target = <mapping_component>-str.
        ELSE.
          INSERT VALUE /drt/s_cd_mapping_popup(
                          source      = ''
                          helper      = ''
                          target      = <mapping_component>-str ) INTO TABLE <mapping_table>.
        ENDIF.
        target_index = target_index + 1.
        CONTINUE.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD determine_customizing_ids.
    me->dtrmine_values_fitting_pattern(
           tokenizer  = tokenizer
           field_name = 'CUSTOMIZING_IMG_IDS_ICONIZED'
           pattern_to_match    = '/DRT/IF_CAO=>*').

    DATA customizing_activity TYPE REF TO /drt/if_cd_customzing_activity.
    ASSIGN me->cust_display_alv_entry->* TO FIELD-SYMBOL(<cust_display_alv_entry>).
    ASSIGN COMPONENT  /drt/co_cd_general_constants=>customizing_img_ids_iconized  OF STRUCTURE <cust_display_alv_entry> TO FIELD-SYMBOL(<customizing_img_id_iconized>).
    customizing_activity = NEW /drt/cl_cd_customzing_activity( <customizing_img_id_iconized> ).

    CALL FUNCTION 'ICON_CREATE'
      EXPORTING
        name                  = 'ICON_SPACE'
        text                  = customizing_activity->get_customizing_activity( )-customizing_img_id
        info                  = customizing_activity->get_customizing_activity( )-textual_description
        add_stdinf            = 'X'
      IMPORTING
        result                = <customizing_img_id_iconized>
      EXCEPTIONS
        icon_not_found        = 1
        outputfield_too_short = 2
        OTHERS                = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    ASSIGN COMPONENT  /drt/co_cd_general_constants=>customizing_img_ids_only_text OF STRUCTURE <cust_display_alv_entry> TO FIELD-SYMBOL(<customizing_img_id_only_text>).
    <customizing_img_id_only_text> = customizing_activity->get_customizing_activity( )-customizing_img_id.
  ENDMETHOD.


  METHOD determine_rapis.
    me->dtrmine_values_fitting_pattern(
            tokenizer  = tokenizer
            field_name = 'RAPIS'
            pattern_to_match    = '/DRT/CO_RAPI_CAT=>*').
  ENDMETHOD.

ENDCLASS.
