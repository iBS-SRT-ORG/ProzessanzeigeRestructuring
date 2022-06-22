CLASS /drt/cl_cd_alv_scheme_builder DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES /drt/if_cd_alv_scheme_builder .
  PROTECTED SECTION.
  PRIVATE SECTION.



    METHODS create_alv_scheme_foundation
      RETURNING
        VALUE(ref_cd_alv_scheme_foundation) TYPE REF TO abap_component_tab .
    METHODS extend_alv_scheme_statically
      IMPORTING
        !ref_tab_cd_alv_components TYPE REF TO abap_component_tab .
    METHODS extend_alv_scheme_dynamically
      IMPORTING
        !tab_differentiation_criteria TYPE /ibs/tybs_proddis
        !ref_tab_cd_alv_components    TYPE REF TO abap_component_tab .
    METHODS add_certain_diff_cat_component
      IMPORTING
        !ref_tab_alv_components       TYPE REF TO abap_component_tab
        !tab_pp_cus_display           TYPE /drt/ty_pp_cus_display
        !tab_differentiation_criteria TYPE /ibs/tybs_proddis.
    METHODS assure_name_stays_unambigous
      IMPORTING
        !differentiation_criteria TYPE /ipe/e_dfval
        !tab_alv_components       TYPE abap_component_tab
      RETURNING
        VALUE(alv_field_name)     TYPE char35 .
    METHODS is_dfval_in_prod_diff_tab
      IMPORTING
        !differentiation_criteria     TYPE /ipe/e_dfval
        !tab_differentiation_criteria TYPE /ibs/tybs_proddis
      RETURNING
        VALUE(result)                 TYPE /drt/e_is_dfval_in_dif_cat_tab .
    METHODS is_field_already_exists_in_alv
      IMPORTING
        !alv_field_name     TYPE char35
        !tab_alv_components TYPE abap_component_tab
      RETURNING
        VALUE(result)       TYPE flag .
    METHODS is_field_name_matches_pattern
      IMPORTING
        !alv_field_name TYPE char35
      RETURNING
        VALUE(result)   TYPE flag .
    METHODS put_given_string_in_front
      IMPORTING
        !string_to_put_at_front TYPE char35
        !string_to_extend       TYPE char35
      RETURNING
        VALUE(extended_string)  TYPE char35 .
ENDCLASS.



CLASS /drt/cl_cd_alv_scheme_builder IMPLEMENTATION.

  METHOD /drt/if_cd_alv_scheme_builder~build_alv_table_scheme.
    DATA(ref_tab_cd_alv_components) = create_alv_scheme_foundation( ).
    "ToDo: mMn könnte dieser Schritt - wie auch beim Feldkatalog - obsolet sein. Einfach die passende Struktur anlegen.
    extend_alv_scheme_statically( ref_tab_cd_alv_components ).

    extend_alv_scheme_dynamically(
        tab_differentiation_criteria = tab_model_data-tab_differentiation_criteria
        ref_tab_cd_alv_components    = ref_tab_cd_alv_components ).

    add_certain_diff_cat_component(
        ref_tab_alv_components       = ref_tab_cd_alv_components
        tab_pp_cus_display           = tab_model_data-tab_pp_cus_display
        tab_differentiation_criteria = tab_model_data-tab_differentiation_criteria
    ).
    TRY.
        rtts_alv_table_scheme = cl_abap_structdescr=>create( ref_tab_cd_alv_components->* ).
      CATCH cx_sy_struct_creation.
    ENDTRY.
  ENDMETHOD.

  METHOD create_alv_scheme_foundation.
    DATA rtts_structdescr TYPE REF TO cl_abap_structdescr.
    DATA tab_cd_alv_scheme_foundation TYPE abap_component_tab.
    FIELD-SYMBOLS: <cd_alv_scheme_foundation> TYPE abap_component_tab.

    CREATE DATA ref_cd_alv_scheme_foundation TYPE abap_component_tab.
    ASSIGN ref_cd_alv_scheme_foundation->* TO <cd_alv_scheme_foundation>.


    rtts_structdescr ?= cl_abap_structdescr=>describe_by_name( '/DRT/S_PP_CUS_DISPLAY' ).
    DATA(tab_components) = rtts_structdescr->get_included_view( ).
    <cd_alv_scheme_foundation> = VALUE #(
                                     FOR <component> IN tab_components ( name = <component>-name
                                                                         type = <component>-type ) ).
  ENDMETHOD.

  METHOD extend_alv_scheme_statically.
    FIELD-SYMBOLS: <alv_components> TYPE abap_component_tab.
    ASSIGN ref_tab_cd_alv_components->* TO <alv_components>.

    INSERT VALUE abap_componentdescr(
                   name = /drt/co_cd_general_constants=>pp_standard_classname
                   type = CAST cl_abap_datadescr( cl_abap_typedescr=>describe_by_name( '/IPE/E_PP_CLASSNAME' ) )
                   ) INTO TABLE <alv_components>.

    INSERT VALUE abap_componentdescr(
                   name = /drt/co_cd_general_constants=>pp_group_category_name
                   type = CAST cl_abap_datadescr( cl_abap_typedescr=>describe_by_name( '/DRT/E_PP_GROUP_CAT_NAME' ) )
                   ) INTO TABLE <alv_components>.

    INSERT VALUE abap_componentdescr(
                   name = 'LINE_COLOR'
                   type = CAST cl_abap_datadescr( cl_abap_elemdescr=>get_c( 4 ) )
                   ) INTO TABLE <alv_components>.

    INSERT VALUE abap_componentdescr(
                   name = 'CELLCOLOR'
                   type = CAST cl_abap_datadescr( cl_abap_typedescr=>describe_by_name( 'LVC_T_SCOL' ) )
                   ) INTO TABLE <alv_components>.

    INSERT VALUE abap_componentdescr(
                   name = /drt/co_cd_general_constants=>customizing_img_ids_iconized
                   type = CAST cl_abap_datadescr( cl_abap_typedescr=>describe_by_name( '/DRT/E_CUST_IMG_IDS_ICON' ) )
                   ) INTO TABLE <alv_components>.

    INSERT VALUE abap_componentdescr(
                    name = /drt/co_cd_general_constants=>customizing_img_ids_only_text
                    type = CAST cl_abap_datadescr( cl_abap_typedescr=>describe_by_name( '/DRT/E_CUST_IMG_IDS_TEXT' ) )
                    ) INTO TABLE <alv_components>.

    INSERT VALUE abap_componentdescr(
                   name = /drt/co_cd_general_constants=>rapis
                   type = CAST cl_abap_datadescr( cl_abap_typedescr=>describe_by_name( '/DRT/E_RAPIS' ) )
                   ) INTO TABLE <alv_components>.

    INSERT VALUE abap_componentdescr(
                   name = /drt/co_cd_general_constants=>mappings_string
                   type = CAST cl_abap_datadescr( cl_abap_typedescr=>describe_by_name( '/DRT/E_MAPPINGS_STRING' ) )
                   ) INTO TABLE <alv_components>.

    INSERT VALUE abap_componentdescr(
                   name = /drt/co_cd_general_constants=>mapping_table
                   type = CAST cl_abap_datadescr( cl_abap_typedescr=>describe_by_name( '/DRT/TY_CD_MAPPING_POPUP' ) )
                   ) INTO TABLE <alv_components>.
  ENDMETHOD.

  METHOD extend_alv_scheme_dynamically.
    DATA alv_field_type TYPE REF TO cl_abap_datadescr.
    FIELD-SYMBOLS: <tab_alv_components> TYPE abap_component_tab.

    IF tab_differentiation_criteria IS NOT INITIAL.
      ASSIGN ref_tab_cd_alv_components->* TO <tab_alv_components>.
      alv_field_type ?= cl_abap_typedescr=>describe_by_name( 'CHAR_50' ).
      <tab_alv_components> = VALUE #( BASE <tab_alv_components>
                                      FOR <differentiation_criteria>
                                      IN tab_differentiation_criteria ( name = <differentiation_criteria>-prod_dif_cat
                                                                        type = alv_field_type ) ) .
    ELSE.
      MESSAGE s001(/drt/cd_messages) DISPLAY LIKE 'I'.
    ENDIF.
  ENDMETHOD.

  METHOD add_certain_diff_cat_component.
    FIELD-SYMBOLS: <tab_alv_components> TYPE abap_component_tab.
    ASSIGN ref_tab_alv_components->* TO <tab_alv_components>.
    DATA alv_field_type TYPE REF TO cl_abap_datadescr.

    IF tab_pp_cus_display IS NOT INITIAL.
      LOOP AT tab_pp_cus_display ASSIGNING FIELD-SYMBOL(<pp_cus_disp_fc>).
        IF <pp_cus_disp_fc>-dfval IS INITIAL OR is_dfval_in_prod_diff_tab(
             differentiation_criteria     = <pp_cus_disp_fc>-dfval
             tab_differentiation_criteria = tab_differentiation_criteria ).
          CONTINUE.
        ENDIF.
        DELETE ADJACENT DUPLICATES FROM <tab_alv_components>.
        TRY.
            ASSIGN <tab_alv_components>[ name =  <pp_cus_disp_fc>-dfval ] TO FIELD-SYMBOL(<alv_field>).
          CATCH cx_sy_itab_line_not_found.
            "wegen DFVAL 001 und 006 im Prozess BS_ARO_COLL_A
            DATA(alv_field_name) = assure_name_stays_unambigous(
                                     differentiation_criteria = <pp_cus_disp_fc>-dfval
                                     tab_alv_components       = <tab_alv_components>
                                   ).
            alv_field_type ?= cl_abap_typedescr=>describe_by_name( 'CHAR_50' ).
            <alv_field>-name = alv_field_name.
            <alv_field>-type = alv_field_type.
            INSERT <alv_field> INTO TABLE <tab_alv_components>.
            CLEAR <alv_field>.
        ENDTRY.
      ENDLOOP.
    ELSE.
      MESSAGE s001(/drt/cd_messages) DISPLAY LIKE 'I'.
*   Keine Differenzierungsmerkmale selektiert.
    ENDIF.
  ENDMETHOD.

  METHOD is_dfval_in_prod_diff_tab.
    TRY.
        DATA(dummy) = tab_differentiation_criteria[ prod_dif_cat = differentiation_criteria ].
        result = abap_true.
      CATCH cx_sy_itab_line_not_found.
        result = abap_false.
    ENDTRY.
  ENDMETHOD.

  METHOD assure_name_stays_unambigous.
    alv_field_name = differentiation_criteria.
    IF is_field_name_matches_pattern( alv_field_name ).
      alv_field_name = put_given_string_in_front(
                          string_to_put_at_front = 'C'
                          string_to_extend       = alv_field_name
      ).
      IF is_field_already_exists_in_alv(
           alv_field_name     = alv_field_name
           tab_alv_components = tab_alv_components
         ).
        alv_field_name = put_given_string_in_front(
                    string_to_put_at_front = 'X'
                    string_to_extend       = alv_field_name ).
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD is_field_name_matches_pattern.
    IF ( alv_field_name(1) CN 'ABCDEFGHIJKLMNOPQRSTUVWXYZ_/' ).
      result = abap_true.
    ELSE.
      result = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD is_field_already_exists_in_alv.
    READ TABLE tab_alv_components TRANSPORTING NO FIELDS WITH KEY name = alv_field_name.
    IF sy-subrc = 0.
      result = abap_true.
    ELSE.
      result = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD put_given_string_in_front.
    extended_string = string_to_extend.
    extended_string = string_to_put_at_front && string_to_extend.
  ENDMETHOD.
ENDCLASS.
