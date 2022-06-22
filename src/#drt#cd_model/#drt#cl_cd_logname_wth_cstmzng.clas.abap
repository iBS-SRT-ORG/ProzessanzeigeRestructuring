CLASS /drt/cl_cd_logname_wth_cstmzng DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES /drt/if_cd_alv_field.
    METHODS constructor
      IMPORTING alv_entry  TYPE REF TO data
                model_data TYPE /drt/s_cd_model_data.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA logname_field_value TYPE /ibs/ebs_logname.
    DATA alv_entry TYPE REF TO data.
    DATA model_data TYPE /drt/s_cd_model_data.
    METHODS is_logname_not_assigned
      IMPORTING sy_subrc      TYPE sy-subrc
      RETURNING VALUE(result) TYPE flag.
    METHODS std_pp_group_class_exists
      IMPORTING sy_subrc      TYPE sy-subrc
      RETURNING VALUE(result) TYPE flag.
    METHODS class_ohne_differnzrung_exists
      IMPORTING sy_subrc      TYPE sy-subrc
      RETURNING VALUE(result) TYPE flag.
    METHODS logname_was_found
      IMPORTING sy_subrc      TYPE sy-subrc
      RETURNING VALUE(result) TYPE flag.
ENDCLASS.

CLASS /drt/cl_cd_logname_wth_cstmzng IMPLEMENTATION.
  METHOD /drt/if_cd_alv_field~detrmine_field_value_for_entry.
    ASSIGN me->alv_entry->* TO FIELD-SYMBOL(<alv_entry>).
    TRY.
        ASSIGN COMPONENT 'LOGNAME' OF STRUCTURE <alv_entry> TO FIELD-SYMBOL(<logname>).
        IF is_logname_not_assigned( sy-subrc ).
          RETURN.
        ENDIF.

        ASSIGN COMPONENT 'CLASSNAME' OF STRUCTURE <alv_entry> TO FIELD-SYMBOL(<class_name_ohne_differenz>).
        SELECT COUNT(*) FROM seoclass INTO @DATA(entrys_found) WHERE clsname = @<class_name_ohne_differenz>.
        IF class_ohne_differnzrung_exists( sy-subrc ).
          SELECT SINGLE logname FROM /ibs/cbs_logname INTO me->logname_field_value WHERE classname = <class_name_ohne_differenz>.
          RETURN.
        ENDIF.

        ASSIGN COMPONENT 'STD_CLASSNAME' OF STRUCTURE <alv_entry> TO FIELD-SYMBOL(<std_pp_group_classname>).
        SELECT COUNT(*) FROM seoclass INTO @entrys_found WHERE clsname = @<std_pp_group_classname>.
        IF std_pp_group_class_exists( sy-subrc ).
          SELECT SINGLE logname FROM /ibs/cbs_logname INTO me->logname_field_value WHERE classname = <std_pp_group_classname>.
          RETURN.
        ENDIF.

        "...anhand der ersten Klasse mit Differenzierung
        LOOP AT model_data-tab_differentiation_criteria ASSIGNING FIELD-SYMBOL(<differentiation_criteria>).
          ASSIGN COMPONENT <differentiation_criteria>-prod_dif_cat OF STRUCTURE <alv_entry> TO FIELD-SYMBOL(<class_name_dif_criteria>).
          SELECT COUNT(*) FROM seoclass WHERE clsname = <class_name_dif_criteria>.
          IF sy-subrc = 0.
            SELECT SINGLE logname FROM /ibs/cbs_logname INTO me->logname_field_value WHERE classname = <class_name_dif_criteria>.
            "Falls eine Klasse gefunden wurde, soll die Schleife verlassen werden,
            "da die einzelnen Klassen mit Differenzierung denselben logischen Namen haben
            RETURN.
          ENDIF.
        ENDLOOP.

        "wenn keine Eintraege in der Tabelle gefunden sind, dann wird noch in der Tabelle /IPE/C_PP_GRP gesucht
        ASSIGN COMPONENT 'PP_GRP'     OF STRUCTURE <alv_entry> TO FIELD-SYMBOL(<pp_group_from_alv_entry>).
        ASSIGN COMPONENT 'PP_GRP_CAT' OF STRUCTURE <alv_entry> TO FIELD-SYMBOL(<pp_group_cat>).
        ASSIGN COMPONENT 'STEPNO'     OF STRUCTURE <alv_entry> TO FIELD-SYMBOL(<stepno>).

        LOOP AT model_data-tab_pp_cus_display_old ASSIGNING FIELD-SYMBOL(<pp_cus_display_old>)
         WHERE    pp_grp      = <pp_group_from_alv_entry>  AND
                  pp_grp_cat  = <pp_group_cat>  AND
                  stepno      = <stepno>.

          IF <pp_cus_display_old>-classname IS NOT INITIAL.
            SELECT SINGLE logname FROM /ibs/cbs_logname INTO me->logname_field_value WHERE classname = <pp_cus_display_old>-classname.
            IF me->logname_field_value IS NOT INITIAL.
              RETURN.
            ENDIF.
          ENDIF.
        ENDLOOP.

        READ TABLE model_data-tab_pp_groups ASSIGNING FIELD-SYMBOL(<pp_group_frm_model>) WITH KEY pp_grp = <pp_group_from_alv_entry>.
        IF sy-subrc = 0.
          SELECT SINGLE logname FROM /ibs/cbs_logname INTO me->logname_field_value WHERE classname = <pp_group_frm_model>-classname.
        ENDIF.

      CATCH cx_root INTO DATA(msg_cx_root).
        DATA(error_text) = msg_cx_root->get_text( ).
        error_text = |{ error_text }'cx_root'|.
        MESSAGE i398(00) WITH error_text space space space.
    ENDTRY.
  ENDMETHOD.

  METHOD /drt/if_cd_alv_field~get_field_value.
    result = me->logname_field_value.
  ENDMETHOD.
  METHOD is_logname_not_assigned.
    IF sy_subrc NE 0.
      result = abap_true.
    ELSE.
      result = abap_false.
    ENDIF.
  ENDMETHOD.
  METHOD std_pp_group_class_exists.
    IF sy_subrc EQ 0.
      result = abap_true.
    ELSE.
      result = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD class_ohne_differnzrung_exists.
    IF sy_subrc EQ 0.
      result = abap_true.
    ELSE.
      result = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD logname_was_found.
    IF sy_subrc EQ 0.
      result = abap_true.
    ELSE.
      result = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD constructor.
    me->alv_entry = alv_entry.
    me->model_data = model_data.
  ENDMETHOD.

ENDCLASS.
