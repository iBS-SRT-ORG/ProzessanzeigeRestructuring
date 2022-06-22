CLASS /drt/cl_cd_grid_event_handler DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES /ruif/if_cc_event_handler.
    METHODS constructor.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA model TYPE REF TO /ruif/if_model.
    DATA view TYPE REF TO /ruif/if_view.
    DATA event_handler_factory TYPE REF TO /drt/if_cd_evt_hndlr_abs_fctry.
    METHODS handle_row_double_click
          FOR EVENT double_click OF cl_gui_alv_grid
      IMPORTING
          !e_row
          !e_column
          !es_row_no .
    METHODS handle_toolbar
        FOR EVENT toolbar OF cl_gui_alv_grid IMPORTING e_interactive e_object.
    METHODS handle_user_command
        FOR EVENT user_command OF cl_gui_alv_grid IMPORTING e_ucomm.

ENDCLASS.

CLASS /drt/cl_cd_grid_event_handler IMPLEMENTATION.
  METHOD /ruif/if_cc_event_handler~set_controlled_model.
    me->model = model.
    " DRINGEND: ToDO: unbedingt anpassen, das ist so sehr unschön!! Nach Umstellung, dass EventHandler global Friends mit
    " Controller ist, kann Event-Handler-Factory-Instanziierung in den Constructor. Dann wieder OK.
    me->event_handler_factory = /drt/cl_cd_event_hnldr_s_fctry=>create_correct_abstrct_factory( me->model ).
  ENDMETHOD.

  METHOD /ruif/if_cc_event_handler~set_controlled_view.
    me->view = view.
  ENDMETHOD.

  METHOD /ruif/if_cc_event_handler~set_handlers.
    SET HANDLER handle_row_double_click FOR CAST cl_gui_alv_grid( CAST /ruif/if_view_custom_control( view )->get_view_object( ) ).
    SET HANDLER handle_toolbar FOR CAST cl_gui_alv_grid( CAST /ruif/if_view_custom_control( view )->get_view_object( ) ).
  ENDMETHOD.

  METHOD handle_row_double_click.
    "ToDo: noch nicht refaktorisiert, aus altem Report kopiert.
    DATA: value       TYPE char30,
          obj_test    TYPE REF TO data,
          bdcdata_wa  TYPE bdcdata,
          bdcdata_tab TYPE TABLE OF bdcdata,
          str_col     TYPE lvc_s_col.

    DATA navtab_entry TYPE navtab.
    DATA(alv_grid) = CAST cl_gui_alv_grid( CAST /ruif/if_view_custom_control( view )->get_view_object( ) ).

* Ermittle den Wert in dem Feld
    alv_grid->get_current_cell( IMPORTING e_value = value ).

*    DATA(row_double_click_handler) = /drt/cl_cd_row_click_s_factory=>get_row_double_click_handler( e_column-fieldname ).
    "ToDo: IF-Bedingung durch ErrorHandling ersetzen und in Try-Catch setzen!
    IF me->event_handler_factory IS BOUND.
      "ToDO: eventuell Singleton, weil sonst jedes Mal Neuinstanziierung.
      DATA(row_double_click_handler) = me->event_handler_factory->create_row_double_click_hndlr( e_column-fieldname ).
      IF row_double_click_handler IS BOUND.
        "ToDo: IF-Bedingung durch ErrorHandling ersetzen und in Try-Catch setzen!
        row_double_click_handler->handle_row_double_click(
                                        clicked_row_information = VALUE #(
                                                                     row_that_was_clicked = e_row
                                                                     column_that_was_clicked_in_row = e_column
                                                                     row_no_that_was_clicked  = es_row_no )
                                        view            = view
                                        model           = model ).
      ENDIF.
    ENDIF.

    "ToDo: komplettes CASE mit Simple Factory + Strategy-Pattern ersetzen. Siehe die bereits umgesetzten Klassen /drt/cl_cd_row_clck_logname und
    "/drt/cl_cd_row_clck_param_srv
    CASE e_column.
      WHEN 'CUSTOMIZING_IMG_IDS_ICONIZED'.
        FIELD-SYMBOLS: <alv_data> TYPE STANDARD TABLE.
        FIELD-SYMBOLS: <model_data> TYPE /drt/s_cd_model_data.
        DATA(ref_model_data) = me->model->get_model_data( ).
        ASSIGN ref_model_data->* TO <model_data>.
        DATA(alv_data) = <model_data>-tab_alv_data_to_display.
        ASSIGN alv_data->* TO <alv_data>.
        ASSIGN <alv_data>[ e_row-index ] TO FIELD-SYMBOL(<row_that_was_double_clicked>).
        ASSIGN COMPONENT 'CUSTOMIZING_IMG_IDS_ONLY_TEXT' OF STRUCTURE <row_that_was_double_clicked> TO FIELD-SYMBOL(<customizing_img_id_only_text>).
        DATA doktitle TYPE doku_title.

        IF <customizing_img_id_only_text> IS INITIAL.
          MESSAGE 'Kein Pflegeobjekt vorhanden' TYPE 'S' DISPLAY LIKE 'W'.
          RETURN.
        ENDIF.

        CALL FUNCTION 'DOKU_OBJECT_TITLE'
          EXPORTING
            dokclass = 'SIMG'
            doklangu = sy-langu
            dokname  = <customizing_img_id_only_text>
          IMPORTING
            doktitle = doktitle
          EXCEPTIONS
            no_title = 1
            OTHERS   = 2.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

        CALL FUNCTION 'DSYS_SHOW'
          EXPORTING
*           application      = 'SO70'
            dokclass         = 'SIMG'
            doklangu         = sy-langu
            dokname          = <customizing_img_id_only_text>
            hometext         = doktitle
*           outline          = space
*           viewname         = 'STANDARD'
*           z_original_outline = space
*           called_from_so70 = ' '
*           structure_id     =
*           no_german        = 'X'
*          IMPORTING
*           appl             =
*           pf03             =
*           pf15             =
*           pf12             =
          EXCEPTIONS
            class_unknown    = 1
            object_not_found = 2
            OTHERS           = 3.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

      WHEN 'MAPPINGS_STRING'.
        DATA tokenizer TYPE REF TO /drt/if_cd_tokenizer.
*        FIELD-SYMBOLS: <alv_data> TYPE STANDARD TABLE.
*        FIELD-SYMBOLS: <model_data> TYPE /drt/s_cd_model_data.
        ref_model_data = me->model->get_model_data( ).
        ASSIGN ref_model_data->* TO <model_data>.
        alv_data = <model_data>-tab_alv_data_to_display.
        ASSIGN alv_data->* TO <alv_data>.
        ASSIGN <alv_data>[ e_row-index ] TO <row_that_was_double_clicked>.
        /ruif/cl_screen_handle_wrapper=>set_screen_change_data( REF #( <row_that_was_double_clicked> ) ).
        /ruif/cl_screen_handle_wrapper=>call_screen_as_popup(
                                            screen_number      = '2200'
                                            column_starting_at = 0
                                            line_starting_at   = 500 ).

      WHEN OTHERS.
        IF value = 'STD'.
          str_col-fieldname = 'STD_CLASSNAME'.
          alv_grid->set_current_cell_via_id(
                          is_row_id    = e_row
                          is_column_id = str_col
                          is_row_no    = es_row_no ).
          alv_grid->get_current_cell( IMPORTING e_value = value ).
        ELSEIF value = 'OHNE DIFF.'.
          str_col-fieldname = 'CLASSNAME'.
          alv_grid->set_current_cell_via_id(
                         is_row_id    = e_row
                         is_column_id = str_col
                         is_row_no    = es_row_no ).
          alv_grid->get_current_cell( IMPORTING e_value = value ).
        ENDIF.
    ENDCASE.

* Prüfe ob die Klasse existiert
    TRY.
        CREATE DATA obj_test TYPE REF TO (value).
      CATCH cx_root.
    ENDTRY.
    IF obj_test IS BOUND.

      navtab_entry-objekttyp = 'CLAS'.
      navtab_entry-objektinf = value.

      CALL FUNCTION 'RS_NAVIGATION_CLAS_ENTRY'
        EXPORTING
          navtab_entry    = navtab_entry
        EXCEPTIONS
          internal_error  = 1
          parameter_error = 2
          OTHERS          = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD handle_toolbar.
    ASSIGN e_object->mt_toolbar[ function = '&FIND_MORE' ] TO FIELD-SYMBOL(<button_find_more>).
    <button_find_more>-disabled = abap_false.
    DELETE e_object->mt_toolbar WHERE function EQ cl_gui_alv_grid=>mc_fc_print_back.
    DELETE e_object->mt_toolbar WHERE function EQ cl_gui_alv_grid=>mc_mb_sum.
    DELETE e_object->mt_toolbar WHERE function EQ cl_gui_alv_grid=>mc_mb_view.
    DELETE e_object->mt_toolbar WHERE function EQ cl_gui_alv_grid=>mc_mb_subtot.
    DELETE e_object->mt_toolbar WHERE function EQ cl_gui_alv_grid=>mc_fc_graph.
    DELETE e_object->mt_toolbar WHERE function EQ cl_gui_alv_grid=>mc_fc_info.
  ENDMETHOD.

  METHOD handle_user_command.
    DATA(user_command_handler) = /drt/cl_cd_user_cmmnd_s_factry=>get_user_command_handler( e_ucomm ).
    user_command_handler->handle_user_command(
                            view  = view
                            model = model ).
  ENDMETHOD.

  METHOD constructor.

  ENDMETHOD.

ENDCLASS.
