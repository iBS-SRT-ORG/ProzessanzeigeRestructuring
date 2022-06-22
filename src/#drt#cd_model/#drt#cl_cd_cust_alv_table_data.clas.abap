CLASS /drt/cl_cd_cust_alv_table_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING alv_table_scheme TYPE REF TO cl_abap_structdescr.
    INTERFACES /drt/if_cd_cust_alv_table_data .
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA ref_alv_table_data TYPE REF TO data.
    DATA cust_display_alv_table_scheme TYPE REF TO cl_abap_structdescr.
    METHODS write_source_tables_into_alv
      IMPORTING model_data TYPE /drt/s_cd_model_data.
    METHODS
      transfer_pp_cus_disp_to_alv
        IMPORTING
          cust_display_alv_scheme    TYPE REF TO cl_abap_structdescr
          selection_screen_selection TYPE /drt/s_cd_selection_screen
          model_data                 TYPE /drt/s_cd_model_data.
    METHODS i_have_no_clue_what_this_does
      IMPORTING
        tab_differentiation_criteria TYPE /ibs/tybs_proddis.
    METHODS fill_remaining_diff_criteria
      IMPORTING
        tab_differentiation_criteria TYPE /ibs/tybs_proddis.
    METHODS is_first_iterated_entry
      IMPORTING tabix         TYPE sy-tabix
      RETURNING VALUE(result) TYPE flag.
    METHODS fill_cash_comp_of_alv_entry
      IMPORTING tab_model_data               TYPE /drt/s_cd_model_data
                cash_comp_from_current_entry TYPE /ibs/ebs_cash_comp
                currently_iterated_pp_entry  TYPE /ibs/sbs_pp_cus_display
                ref_cash_comp_from_alv       TYPE REF TO data.
    METHODS
      insert_new_entry_to_alv_table
        IMPORTING entry_to_insert TYPE REF TO data.
    METHODS create_int_and_ext_dif_tables
      IMPORTING
        model_data          TYPE /drt/s_cd_model_data
      EXPORTING
        tab_prod_dif_intern TYPE /ibs/tybs_proddis
        tab_prod_dif_extern TYPE /ibs/tybs_proddis.
    METHODS append_target_info
      IMPORTING
        !im_str_write_d TYPE /ibs/cbs_write_d
      CHANGING
        !ch_str_alv     TYPE any
        !ch_counter     TYPE int4 .
    METHODS append_dupl_info
      IMPORTING
        !im_str_prod_dif_i TYPE /ibs/vbs_proddis
        model_data         TYPE /drt/s_cd_model_data
      CHANGING
        !ch_str_alv        TYPE any .
ENDCLASS.

CLASS /drt/cl_cd_cust_alv_table_data IMPLEMENTATION.

  METHOD constructor.
    me->cust_display_alv_table_scheme = alv_table_scheme.
    DATA alv_entry TYPE REF TO data.
    CREATE DATA alv_entry TYPE HANDLE alv_table_scheme.
    ASSIGN alv_entry->* TO FIELD-SYMBOL(<alv_entry>).
    CREATE DATA ref_alv_table_data LIKE TABLE OF <alv_entry>.
  ENDMETHOD.

  METHOD /drt/if_cd_cust_alv_table_data~create_alv_data.
    write_source_tables_into_alv( model_data ).
    transfer_pp_cus_disp_to_alv(
          cust_display_alv_scheme    = me->cust_display_alv_table_scheme
          selection_screen_selection = selection_screen_selection
          model_data                 = model_data ).
    i_have_no_clue_what_this_does( model_data-tab_differentiation_criteria ).
    fill_remaining_diff_criteria( model_data-tab_differentiation_criteria ).
  ENDMETHOD.

  METHOD write_source_tables_into_alv.
    DATA counter TYPE i VALUE 0.

    LOOP AT model_data-tab_data_sources ASSIGNING FIELD-SYMBOL(<data_source>).
      counter = counter + 1.
      DATA(source_table_to_add_to_alv) = /drt/cl_cd_alv_entry_factory=>create_alv_entry_with_src_tab(
                                                                              cust_display_alv_scheme = cust_display_alv_table_scheme
                                                                              counter                 = counter
                                                                              source_table_name       = <data_source>-tablename ).

      me->insert_new_entry_to_alv_table( source_table_to_add_to_alv->get_cust_display_alv_entry( ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD transfer_pp_cus_disp_to_alv.
    DATA currently_iterated_pp_entry TYPE REF TO /drt/if_cd_pp_cust_entry.
    DATA alv_entry_to_add TYPE REF TO /drt/if_cd_cust_alv_entry.

    LOOP AT model_data-tab_pp_cus_display ASSIGNING FIELD-SYMBOL(<currently_iterated_pp_entry>).
      DATA(table_index) = sy-tabix.
      currently_iterated_pp_entry = NEW /drt/cl_cd_pp_cust_entry(
                                            pp_customizing_entry       = <currently_iterated_pp_entry>
                                            selection_screen_selection = selection_screen_selection ).

      IF is_first_iterated_entry( table_index ).
        alv_entry_to_add = /drt/cl_cd_alv_entry_factory=>create_alv_entry_from_pp_entry(
                                                            pp_cus_entry            = currently_iterated_pp_entry
                                                            cust_display_alv_scheme = cust_display_alv_scheme
                                                            model_data              = model_data ).
        CONTINUE.
      ENDIF.

      IF alv_entry_to_add->is_key_identical_to( currently_iterated_pp_entry ).
        "Key ist identisch, heißt: kein neuer Prozessschritt, sodnern Differenzierungsmerkmal liegt vor -> in hinzuzufügenden ALV-Eintrag das gerade iterierte Diff.merkmal korrekt befüllen
        alv_entry_to_add->fill_iterated_dif_crit_field(
                              model_data                  = model_data
                              currently_iterated_pp_entry = currently_iterated_pp_entry ).
        "hier verstehe ich den fachlihen Hintergrund nicht. Liegt eine Cash-Component vor, wird gsechaut, ob das Diff-merkmal in der Diffmerkmal-Customizingtabelle vorkommt. Wenn nicht
        "wird zur Prozessanzeige ein neuer Eintrag hinzugefügt.
        IF NOT currently_iterated_pp_entry->has_cash_component( ).
          CONTINUE.
        ENDIF.
        IF NOT line_exists( model_data-tab_differentiation_criteria[ prod_dif_cat = currently_iterated_pp_entry->get_differentiation_criteria( ) ] ).
          DATA(new_entry_to_be_inserted) = /drt/cl_cd_alv_entry_factory=>create_alv_entry_from_pp_entry(
                                                                              pp_cus_entry            = currently_iterated_pp_entry
                                                                              cust_display_alv_scheme = cust_display_alv_scheme
                                                                              model_data              = model_data ).
          me->insert_new_entry_to_alv_table( new_entry_to_be_inserted->get_cust_display_alv_entry( ) ).
        ENDIF.

      ELSE.
        "Key nicht identisch -> neuer Prozesschritt -> Datensatz wegschreiben, Infos merken (für nächste Iteration)
        me->insert_new_entry_to_alv_table( alv_entry_to_add->get_cust_display_alv_entry( ) ).
        FREE alv_entry_to_add.
        alv_entry_to_add = /drt/cl_cd_alv_entry_factory=>create_alv_entry_from_pp_entry(
                                                             pp_cus_entry            = currently_iterated_pp_entry
                                                             cust_display_alv_scheme = cust_display_alv_scheme
                                                             model_data              = model_data ).
      ENDIF.
      FREE currently_iterated_pp_entry.
    ENDLOOP.
    me->insert_new_entry_to_alv_table( alv_entry_to_add->get_cust_display_alv_entry( ) ).
    FREE alv_entry_to_add.
  ENDMETHOD.

  METHOD is_first_iterated_entry.
    IF tabix = 1.
      result = abap_true.
    ELSE.
      result = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD i_have_no_clue_what_this_does.
    "ToDo: noch nicht refaktorisiert, aus altem Report kopiert.
    FIELD-SYMBOLS: <tab_alv_cust_display> TYPE STANDARD TABLE.
    ASSIGN ref_alv_table_data->* TO <tab_alv_cust_display>.
    LOOP AT <tab_alv_cust_display> ASSIGNING FIELD-SYMBOL(<alv_entry>).

      ASSIGN COMPONENT 'DFVAL' OF STRUCTURE <tab_alv_cust_display> TO FIELD-SYMBOL(<differentiation_crtieria>).
      IF sy-subrc = 0 AND <differentiation_crtieria> IS NOT INITIAL.
*     DFVAL vom Typ XX_PRODDIF versorgen
        SPLIT <differentiation_crtieria> AT '_' INTO DATA(prefix_of_diff_criteria) DATA(differentiation_criteria).
        IF differentiation_criteria IS INITIAL.
          differentiation_criteria = prefix_of_diff_criteria.
        ENDIF.
        IF line_exists( tab_differentiation_criteria[ prod_dif_cat = differentiation_criteria ] ).
          DELETE <tab_alv_cust_display>.
        ENDIF.
      ENDIF.
      CLEAR: prefix_of_diff_criteria, differentiation_criteria.
    ENDLOOP.
  ENDMETHOD.

  METHOD fill_remaining_diff_criteria.
    "ToDo: noch nicht refaktorisiert, aus altem Report kopiert.
    DATA undef_classname  TYPE /ipe/e_pp_classname.
    DATA tab_dd07v TYPE TABLE OF dd07v.
    CONSTANTS  co_source_step_no TYPE n VALUE 000000 ##NO_TEXT.
*  * Textfestwerte auslesen
    CALL FUNCTION 'DDIF_DOMA_GET'
      EXPORTING
        name          = '/IPE/O_PP_GRP_CAT'
        langu         = sy-langu
      TABLES
        dd07v_tab     = tab_dd07v
      EXCEPTIONS
        illegal_input = 1
        OTHERS        = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    FIELD-SYMBOLS: <tab_alv_cust_display> TYPE STANDARD TABLE.
    ASSIGN me->ref_alv_table_data->* TO <tab_alv_cust_display>.

    LOOP AT <tab_alv_cust_display> ASSIGNING FIELD-SYMBOL(<alv_cust_display_entry>).

      LOOP AT tab_differentiation_criteria ASSIGNING FIELD-SYMBOL(<str_prod_dif_disp>).
        ASSIGN COMPONENT <str_prod_dif_disp>-prod_dif_cat OF STRUCTURE <alv_cust_display_entry> TO FIELD-SYMBOL(<iterated_diff_criteria>).
        ASSIGN COMPONENT /drt/co_cd_general_constants=>is_active OF STRUCTURE <alv_cust_display_entry> TO FIELD-SYMBOL(<is_process_step_active>).
        ASSIGN COMPONENT /drt/co_cd_general_constants=>class_ohne_differenzierung  OF STRUCTURE <alv_cust_display_entry> TO FIELD-SYMBOL(<classname_of_diff_criteria>).
        ASSIGN COMPONENT 'DFVAL' OF STRUCTURE <alv_cust_display_entry> TO FIELD-SYMBOL(<str_alv_dfval>).
        ASSIGN COMPONENT /drt/co_cd_general_constants=>pp_group OF STRUCTURE <alv_cust_display_entry> TO FIELD-SYMBOL(<pp_group>).
        ASSIGN COMPONENT /drt/co_cd_general_constants=>process_step_number OF STRUCTURE <alv_cust_display_entry> TO FIELD-SYMBOL(<process_stepno>).

        IF <iterated_diff_criteria> IS INITIAL AND <is_process_step_active> IS NOT INITIAL.
          IF <classname_of_diff_criteria> IS INITIAL.
            <iterated_diff_criteria> = 'STD'.
          ELSE.
            ASSIGN COMPONENT /drt/co_cd_general_constants=>orig_differentiation_criteria  OF STRUCTURE <alv_cust_display_entry> TO FIELD-SYMBOL(<diff_criteria_original>).


            SPLIT <diff_criteria_original> AT '!' INTO DATA(str_dfval) DATA(str_cash_comp).    " XX_PRODDIFCAT!CC => XX_PRODDIFCAT + CC
            IF str_dfval EQ <str_alv_dfval>.                                            " PRODDIFCAT!CC    => PRODDIFCAT +  CC
              SPLIT str_dfval AT '_' INTO DATA(str_prefix) DATA(prod_dif).           " XX_PRODDIFCAT    => XX + PRODDIFCAT
            ENDIF.

            IF <diff_criteria_original> IS ASSIGNED AND <diff_criteria_original> IS NOT INITIAL.
              IF <str_prod_dif_disp>-prod_dif_cat EQ <diff_criteria_original>.
                <iterated_diff_criteria> =  <classname_of_diff_criteria>.
              ELSEIF <str_prod_dif_disp>-prod_dif_cat EQ prod_dif.

                LOOP AT <tab_alv_cust_display> ASSIGNING FIELD-SYMBOL(<str_alv_cc>).
                  ASSIGN COMPONENT /drt/co_cd_general_constants=>pp_group OF STRUCTURE <str_alv_cc> TO FIELD-SYMBOL(<str_pp_grp_cc>).
                  ASSIGN COMPONENT /drt/co_cd_general_constants=>process_step_number OF STRUCTURE <str_alv_cc> TO FIELD-SYMBOL(<stepno_cc>).
                  ASSIGN COMPONENT 'DFVAL' OF STRUCTURE <str_alv_cc> TO FIELD-SYMBOL(<dfval_cc>).
                  ASSIGN COMPONENT /drt/co_cd_general_constants=>class_ohne_differenzierung OF STRUCTURE <str_alv_cc> TO FIELD-SYMBOL(<cl_name_cc>).
                  IF <str_pp_grp_cc> = <pp_group> AND
                     <stepno_cc>     = <process_stepno> AND
                     <dfval_cc>      = str_dfval.
                    <iterated_diff_criteria> =  <classname_of_diff_criteria>.
                    CLEAR: <cl_name_cc>.
                  ENDIF.
                ENDLOOP.
                EXIT.
              ELSE.
                <iterated_diff_criteria> = 'UNDEFINIERT'(003).
                undef_classname = 'Eintrag bitte prüfen !'(007).
              ENDIF.
            ELSE.
              <iterated_diff_criteria> = 'OHNE DIFF.'(004).
            ENDIF.
            CLEAR: str_dfval, str_cash_comp, prod_dif, str_prefix.
          ENDIF.
        ELSEIF <iterated_diff_criteria> IS INITIAL.
          <iterated_diff_criteria> = 'AUSGESCHALTET'(001).
        ENDIF.
*     Prüfen, ob die Schrittnummer auf default steht; dann handelt es sich
*     um eine Quelltabelle und es muss nichts in die Diff.Felder geschrieben werden
        ASSIGN COMPONENT /drt/co_cd_general_constants=>process_step_number OF STRUCTURE <alv_cust_display_entry> TO <process_stepno>.
        IF <process_stepno> EQ co_source_step_no.
          CLEAR <iterated_diff_criteria>.
        ENDIF.
        UNASSIGN: <iterated_diff_criteria>,
                  <is_process_step_active>,
                  <str_alv_cc>,
                  <process_stepno>,
                  <pp_group>.
      ENDLOOP.
      ASSIGN COMPONENT /drt/co_cd_general_constants=>pp_group_category      OF STRUCTURE <alv_cust_display_entry> TO FIELD-SYMBOL(<pp_grp_cat>).
      ASSIGN COMPONENT /drt/co_cd_general_constants=>pp_group_category_name OF STRUCTURE <alv_cust_display_entry> TO FIELD-SYMBOL(<pp_grp_cat_name>).
      TRY.
          DATA(str_dd07v) = tab_dd07v[ domvalue_l = <pp_grp_cat> ].
          <pp_grp_cat_name> = str_dd07v-ddtext.
        CATCH cx_sy_itab_line_not_found.
      ENDTRY.
      IF undef_classname IS NOT INITIAL.
        <classname_of_diff_criteria> = undef_classname.
      ENDIF.
      CLEAR undef_classname.
    ENDLOOP.
  ENDMETHOD.

  METHOD fill_cash_comp_of_alv_entry.
    ASSIGN ref_cash_comp_from_alv->* TO FIELD-SYMBOL(<cash_comp_from_alv>).
    IF <cash_comp_from_alv> IS NOT ASSIGNED.
      RETURN.
    ENDIF.
    IF cash_comp_from_current_entry IS NOT INITIAL.
      <cash_comp_from_alv> = cash_comp_from_current_entry.
    ENDIF.
    "Erweiterung Cash-Component Informationen über Systemtabelle
    TRY.
        ASSIGN tab_model_data-tab_cash_component_ids[ dfval = currently_iterated_pp_entry-dfval ] TO FIELD-SYMBOL(<component_id>).
        IF <cash_comp_from_alv> IS INITIAL.
          <cash_comp_from_alv> = <component_id>-cash_comp.
        ELSE.
          IF <cash_comp_from_alv> NS <component_id>-cash_comp.
            <cash_comp_from_alv> = <cash_comp_from_alv> && ',' && <component_id>-cash_comp.
          ENDIF.
        ENDIF.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.
  ENDMETHOD.

  METHOD /drt/if_cd_cust_alv_table_data~enrich_alv_data.
    DATA cust_display_entry TYPE REF TO /drt/if_cd_cust_alv_entry.
    FIELD-SYMBOLS <tab_alv_cust_display> TYPE STANDARD TABLE.

    create_int_and_ext_dif_tables(
      EXPORTING
        model_data          = model_data
      IMPORTING
        tab_prod_dif_intern = DATA(tab_prod_dif_extern)
        tab_prod_dif_extern = DATA(tab_prod_dif_intern) ).

    DATA(obj_color_rows) = NEW /ibs/cl_src_cus_disp_alv_out(
                                  im_tab_prod_dif_intern = tab_prod_dif_intern
                                  im_tab_prod_dif_extern = tab_prod_dif_extern
                                  im_tab_pp_grp_as       = model_data-tab_pp_groups_assigned
                                  im_tab_proddif_disp    = model_data-tab_differentiation_criteria
                                  im_tab_pp_grp          = model_data-tab_pp_groups
                                  im_tab_pp_cus_disp_alt = model_data-tab_pp_cus_display_old ).

    ASSIGN me->ref_alv_table_data->* TO <tab_alv_cust_display>.

    LOOP AT <tab_alv_cust_display> ASSIGNING FIELD-SYMBOL(<cust_display_entry_in_loop>).
      cust_display_entry = NEW /drt/cl_cd_cust_alv_entry(
                                    str_alv_entry           = <cust_display_entry_in_loop>
                                    cust_display_alv_scheme = me->cust_display_alv_table_scheme ).

      DATA(ref_cust_display_entry) = cust_display_entry->get_cust_display_alv_entry( ).
      ASSIGN ref_cust_display_entry->* TO FIELD-SYMBOL(<cust_display_entry>).

      obj_color_rows->prepare_data( CHANGING ch_str_alv = <cust_display_entry> ).
      cust_display_entry->dtrmn_yet_missing_column_info( model_data ).
      <cust_display_entry_in_loop> = <cust_display_entry>.
    ENDLOOP.
    "ToDo: ab hier -> noch nicht refaktorisiert, aus altem Report kopiert.
**********************************************************************************
* Erweiterung um Zieltabellen Info bei WRITER Eintrag
**********************************************************************************
    DATA: struct     TYPE REF TO cl_abap_structdescr,
          tab_strucs TYPE cl_abap_structdescr=>component_table,
          tab_ckf    TYPE STANDARD TABLE OF /ipe/c_ro_cat,
          ckf_name   TYPE /ipe/e_ckf_strucname.

    FIELD-SYMBOLS:
      <str_ckf> TYPE /ipe/c_ro_cat,
      <strucs>  TYPE abap_componentdescr.
    DATA counter TYPE int4 VALUE 0.

* Über ro_cat die CKF-Struktur des aktuellen ARO ermitteln
    SELECT * FROM /ipe/c_ro_cat INTO TABLE tab_ckf WHERE ro_cat = selection_screen_selection-reporting_obj_category.
    READ TABLE tab_ckf ASSIGNING <str_ckf> INDEX 1.
    ckf_name = <str_ckf>-ckf_struc.

    IF  ckf_name IS NOT INITIAL.

*In der CKF-Struktur enthaltene Strukturen auslesen
      struct ?= cl_abap_typedescr=>describe_by_name( ckf_name ).
      tab_strucs = struct->get_components( ).

* Zieltabellen abgleichen und in die ALV übernehmen
* mögliche Duplikate entfernen
      DATA(tab_writer_destinations) = model_data-tab_write_destinations.
      DELETE ADJACENT DUPLICATES FROM tab_writer_destinations COMPARING tabname.
      LOOP AT model_data-tab_write_destinations ASSIGNING FIELD-SYMBOL(<write_destination>) WHERE flg_is_target EQ /ibs/co_bs_general=>flg_true.
        LOOP AT tab_strucs TRANSPORTING NO FIELDS
          WHERE name EQ <write_destination>-komp_name
          OR    name CS <write_destination>-tabname.
          APPEND INITIAL LINE TO <tab_alv_cust_display> ASSIGNING <cust_display_entry>.
          me->append_target_info(
            EXPORTING
              im_str_write_d = <write_destination>
            CHANGING
              ch_str_alv = <cust_display_entry>
              ch_counter = counter
          ).
          EXIT.
        ENDLOOP.
      ENDLOOP.
**********************************************************************************
* Erweiterung um Duplikatinformationen
**********************************************************************************
      LOOP AT model_data-tab_differentiation_criteria ASSIGNING FIELD-SYMBOL(<str_prod_dif_disp>) WHERE flg_int_ext EQ 'I'.
        APPEND INITIAL LINE TO <tab_alv_cust_display> ASSIGNING <cust_display_entry>.
        me->append_dupl_info(
          EXPORTING
            im_str_prod_dif_i = <str_prod_dif_disp>
            model_data    = model_data
          CHANGING
            ch_str_alv        = <cust_display_entry>
        ).
      ENDLOOP.
    ENDIF. "  ckf_name is not INITIAL.
  ENDMETHOD.

  METHOD append_target_info.
    "ToDo: noch nicht refaktorisiert, aus altem Report kopiert.
    DATA: msg_cx_root    TYPE REF TO cx_root,
          str_error_text TYPE string,
          tmp_count      TYPE c LENGTH 3.
    DATA: tabname_ddtext TYPE dd02t-ddtext,
          sel_tabname    TYPE tabname.

    FIELD-SYMBOLS: <logname>   TYPE /ibs/ebs_logname.

    TRY.

        ch_counter = ch_counter + 1.
        ASSIGN COMPONENT /drt/co_cd_general_constants=>logname OF STRUCTURE ch_str_alv TO <logname>.
        tmp_count = ch_counter.
        CONCATENATE tmp_count '.' INTO tmp_count.
        CONCATENATE '/IBS/SBS_'  im_str_write_d-tabname  INTO sel_tabname.

* Hier noch die Langbeschreibung lesen--> Das ist DDTEXT aus der Tabelle DD02T
* und mit an die Ausgabe <logname anfuegen>
        SELECT SINGLE ddtext FROM dd02t INTO tabname_ddtext
          WHERE tabname = sel_tabname.

        IF sy-subrc = 0.
          CONCATENATE tmp_count 'Zieltabelle' '>>>' im_str_write_d-tabname ' ' tabname_ddtext
           INTO <logname> SEPARATED BY space.
        ENDIF.
      CATCH cx_root INTO msg_cx_root.
        str_error_text = msg_cx_root->get_text( ).
        CONCATENATE  str_error_text 'cx_root'
        INTO  str_error_text.
        MESSAGE i398(00) WITH str_error_text space space space.

    ENDTRY.
  ENDMETHOD.

  METHOD append_dupl_info.
    "ToDo: noch nicht refaktorisiert, aus altem Report kopiert.
    DATA: msg_cx_root    TYPE REF TO cx_root,
          str_error_text TYPE string..

    FIELD-SYMBOLS: <logname>   TYPE /ibs/ebs_logname.

    TRY.
        ASSIGN COMPONENT /drt/co_cd_general_constants=>logname OF STRUCTURE ch_str_alv TO <logname>.

*       Prüfen auf nicht zugewiesenes Duplikat
        IF model_data-tab_differentiation_criteria IS NOT INITIAL.
          READ TABLE  model_data-tab_differentiation_criteria TRANSPORTING NO FIELDS WITH KEY prod_dif_cat = im_str_prod_dif_i-prod_dif_cat.
          IF sy-subrc EQ 0.
            CONCATENATE 'Duplikaterzeugung' im_str_prod_dif_i-prod_dif_cat 'nicht eingestellt' INTO <logname> SEPARATED BY space.
            RETURN.
          ENDIF.
        ENDIF.

*       Ausgabe der das Duplikat erzeugenden Klasse
        CONCATENATE 'Duplikat' im_str_prod_dif_i-prod_dif_cat 'erzeugt durch' im_str_prod_dif_i-clas_create_dup
        INTO <logname> SEPARATED BY space.

      CATCH cx_root INTO msg_cx_root.
        str_error_text = msg_cx_root->get_text( ).
        CONCATENATE  str_error_text 'cx_root'
        INTO  str_error_text.
        MESSAGE i398(00) WITH str_error_text space space space.
    ENDTRY.
  ENDMETHOD.

  METHOD create_int_and_ext_dif_tables.
    LOOP AT model_data-tab_differentiation_criteria ASSIGNING FIELD-SYMBOL(<diff_criteria>).
      IF <diff_criteria>-flg_int_ext EQ 'E'.
        INSERT <diff_criteria> INTO TABLE tab_prod_dif_extern.
      ELSEIF <diff_criteria>-flg_int_ext EQ 'I'.
        INSERT <diff_criteria> INTO TABLE tab_prod_dif_intern.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD /drt/if_cd_cust_alv_table_data~get_ref_alv_table_data.
    result = me->ref_alv_table_data.
  ENDMETHOD.

  METHOD insert_new_entry_to_alv_table.
    FIELD-SYMBOLS: <alv_table_data> TYPE STANDARD TABLE.
    ASSIGN me->ref_alv_table_data->* TO <alv_table_data>.
    ASSIGN entry_to_insert->* TO FIELD-SYMBOL(<entry_to_insert>).
    INSERT <entry_to_insert> INTO TABLE <alv_table_data>.
  ENDMETHOD.

ENDCLASS.
