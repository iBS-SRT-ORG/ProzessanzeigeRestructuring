CLASS /drt/cl_cd_model DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES /ruif/if_model.
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA model_data TYPE /drt/s_cd_model_data .

    METHODS read_model_data_frm_img_tables
      IMPORTING
        !selection_screen_selection TYPE /drt/s_cd_selection_screen .

    METHODS split_differentiation_criteria .
    METHODS create_sorted_procss_step_list
      IMPORTING
        !selection_screen_selection TYPE /drt/s_cd_selection_screen
      RAISING
        /ipe/cx_pp_factory .
    METHODS delete_not_needed_entries.
ENDCLASS.



CLASS /drt/cl_cd_model IMPLEMENTATION.
  METHOD /ruif/if_model~get_model_data.
    CREATE DATA model_data TYPE /drt/s_cd_model_data.
    FIELD-SYMBOLS:<model_data> TYPE /drt/s_cd_model_data.
    ASSIGN model_data->* TO <model_data>.
    <model_data> = me->model_data.
    model_data = REF #( <model_data> ).
  ENDMETHOD.


  METHOD /ruif/if_model~get_model_data_to_display.
    model_data_to_display = model_data-tab_alv_data_to_display.
  ENDMETHOD.


  METHOD /ruif/if_model~load_model.
  ENDMETHOD.


  METHOD /ruif/if_model~load_model_with_data.
    "ToDo SeSe 13.05.2022: NEW-Operatoren durch Dependency Injection ersetzen?
    DATA alv_scheme_builder TYPE REF TO /drt/if_cd_alv_scheme_builder.
    DATA cust_disp_alv_data_carrier TYPE REF TO /drt/if_cd_cust_alv_table_data.

    ASSIGN data->* TO FIELD-SYMBOL(<selection_screen_selection>).
    model_data-selection_screen_selection = <selection_screen_selection>.

    TRY.
        create_sorted_procss_step_list( <selection_screen_selection> ).
        split_differentiation_criteria( ).

      CATCH /ipe/cx_pp_factory INTO DATA(obj_cx_pp_factory).
        obj_cx_pp_factory->supply_syst_with_msgpar( ).
*     Nachrichtentyp "Abbruch" wird in "Fehler" umgesetzt, um das
*     Verlassen der aktuellen Transaktion, i.d.R. SPRO zu vermeiden
        IF sy-msgty EQ /ipe/cx_pp_factory=>co_msgty_abort.
          sy-msgty = /ipe/cx_pp_factory=>co_msgty_error.
        ENDIF.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDTRY.

    IF model_data-tab_pp_cus_display IS INITIAL.
      " Keine Prozessschritte dazu gefunden
      MESSAGE e002(/drt/cd_messages).
    ENDIF.
    read_model_data_frm_img_tables( <selection_screen_selection> ).
    delete_not_needed_entries( ).
    me->model_data-cust_display_alv_scheme = NEW /drt/cl_cd_alv_scheme_builder( )->/drt/if_cd_alv_scheme_builder~build_alv_table_scheme( me->model_data ).
    cust_disp_alv_data_carrier = NEW /drt/cl_cd_cust_alv_table_data( me->model_data-cust_display_alv_scheme ).
    cust_disp_alv_data_carrier->create_alv_data(
                                    selection_screen_selection = <selection_screen_selection>
                                    model_data                 = model_data ).
    "ToDo: enrich_alv_data wirklich Teil der Schnittstelle machen oder lieber private Untermethode?
    cust_disp_alv_data_carrier->enrich_alv_data(
                                    selection_screen_selection = <selection_screen_selection>
                                    model_data                 = model_data ).
    model_data-tab_alv_data_to_display = cust_disp_alv_data_carrier->get_ref_alv_table_data( ).
  ENDMETHOD.

  METHOD create_sorted_procss_step_list.
    /ipe/cl_pp_factory=>get_steplist(
      EXPORTING
        im_business_date   = selection_screen_selection-business_date
        im_ro_cat          = selection_screen_selection-reporting_obj_category
        im_run_type        = selection_screen_selection-run_type
      IMPORTING
        ex_tab_pp_cus_disp = me->model_data-tab_pp_cus_display_old ).

    SORT me->model_data-tab_pp_cus_display_old BY stepno dfval pp_grp.
  ENDMETHOD.


  METHOD read_model_data_frm_img_tables.
    DATA data_accessor TYPE REF TO /drt/if_cd_model_data_accessor.
    data_accessor = NEW /drt/cl_cd_data_accessor( ).

    me->model_data-tab_differentiation_criteria = data_accessor->read_differentiation_criteria( selection_screen_selection ).
    me->model_data-tab_pp_groups = data_accessor->read_pp_groups( ).
    me->model_data-tab_pp_groups_assigned = data_accessor->read_pp_group_assigns( selection_screen_selection ).
    me->model_data-tab_wdoku = data_accessor->read_srt_documentation( ).
    TRY.
        me->model_data-tab_data_sources = data_accessor->read_source_tables( selection_screen_selection ).
      CATCH /ipe/cx_con_factory .
      CATCH /ipe/cx_abstract .
    ENDTRY.
    me->model_data-tab_write_destinations = data_accessor->read_target_config_frm_buffer( ).
    me->model_data-tab_cash_component_ids = data_accessor->read_cash_components_assgnment( ).
  ENDMETHOD.


  METHOD split_differentiation_criteria.
    "Cash-komponenten im BAIS haben im Feld DFVAL zusätzlich die Endung !UR oder !EM (also bspw. B0100!UR).
    "Damit wir später sowohl DFVAL als auch die erweiterte DFVAL der CK (DFVAL_ORIG) zur Verfügung haben,
    "übertragen wir die Factory-Daten in eine neue Tabelle die zusätzlich das Feld DFVAL_ORIG enthält.
    "Es sind beide Felder nötig, da der Ausgabereport nur die DFVAL kennt und verwertet, wir
    "später aber noch überprüfen wollen, ob die CK beim Kunden überhaupt aktiviert ist, brauchen wir das Feld DFVAL_ORIG.

    DATA: dfval     TYPE /ipe/e_dfval,
          cash_comp TYPE /ibs/ebs_cash_comp.

    LOOP AT me->model_data-tab_pp_cus_display_old ASSIGNING FIELD-SYMBOL(<pp_cus_disp_old>).
      DATA(str_pp_cus_display) = CORRESPONDING /ibs/sbs_pp_cus_display( <pp_cus_disp_old> ).
      str_pp_cus_display-dfval_orig = str_pp_cus_display-dfval.
      SPLIT str_pp_cus_display-dfval AT '!' INTO dfval cash_comp.
      str_pp_cus_display-dfval = dfval.
      INSERT str_pp_cus_display INTO TABLE me->model_data-tab_pp_cus_display.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete_not_needed_entries.
    CONSTANTS other_pp_group VALUE 3.
    FIELD-SYMBOLS: <tab_pp_cus_display> TYPE /drt/ty_pp_cus_display.

    LOOP AT model_data-tab_pp_cus_display ASSIGNING FIELD-SYMBOL(<pp_cus_display>).
      IF <pp_cus_display>-stepno IS INITIAL AND <pp_cus_display>-pp_grp_cat EQ other_pp_group.
        DELETE model_data-tab_pp_cus_display.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD /ruif/if_model~get_model.

  ENDMETHOD.

ENDCLASS.
