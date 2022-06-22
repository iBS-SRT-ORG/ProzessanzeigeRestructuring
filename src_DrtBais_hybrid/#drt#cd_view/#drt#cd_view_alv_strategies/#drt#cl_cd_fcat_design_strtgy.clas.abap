CLASS /drt/cl_cd_fcat_design_strtgy DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES /ruif/if_fct_design_strategy .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS /drt/cl_cd_fcat_design_strtgy IMPLEMENTATION.
  METHOD /ruif/if_fct_design_strategy~design_field_catalog.
    FIELD-SYMBOLS: <tab_extended_field_catalog> TYPE lvc_t_fcat.

    DATA(ref_tab_field_catalog) = field_catalog->get_field_catalog( ).
    ASSIGN ref_tab_field_catalog->* TO <tab_extended_field_catalog>.
    DATA counter_field_catalog TYPE int2 VALUE 0.

    LOOP AT <tab_extended_field_catalog> ASSIGNING FIELD-SYMBOL(<field_catalog_entry>).
      IF <field_catalog_entry>-fieldname = /drt/co_cd_general_constants=>pp_group_category.
        "Verarbeitungsgruppentyp standardmäßig ausgeblendet
        <field_catalog_entry>-no_out = /ipe/co_general=>flg_true.
        <field_catalog_entry>-tech   = /ipe/co_general=>flg_false.
      ENDIF.
      IF <field_catalog_entry>-fieldname = /drt/co_cd_general_constants=>is_active.
        "Aktivkennzeichen standardmäßig ausgeblendet
        <field_catalog_entry>-no_out = /ipe/co_general=>flg_true.
        <field_catalog_entry>-tech   = /ipe/co_general=>flg_false.
      ENDIF.
      IF <field_catalog_entry>-fieldname = /drt/co_cd_general_constants=>class_ohne_differenzierung.
        "Feldbezeichnung angepasst
        <field_catalog_entry>-scrtext_l = 'ohne Differenzierung'.
        <field_catalog_entry>-scrtext_m = 'ohne Differenzierung'.
        <field_catalog_entry>-scrtext_s = 'ohne Dif.'.
        <field_catalog_entry>-emphasize = 'C410'.
      ENDIF.
      IF <field_catalog_entry>-fieldname = /drt/co_cd_general_constants=>pp_group.
        <field_catalog_entry>-emphasize = 'C410'.
      ENDIF.
      IF <field_catalog_entry>-fieldname = /drt/co_cd_general_constants=>process_step_number.
        <field_catalog_entry>-emphasize = 'C410'.
      ENDIF.
      IF <field_catalog_entry>-fieldname = /drt/co_cd_general_constants=>function_set.
        <field_catalog_entry>-emphasize = 'C410'.
      ENDIF.
      IF <field_catalog_entry>-fieldname = /drt/co_cd_general_constants=>orig_differentiation_criteria.
        <field_catalog_entry>-no_out = /ipe/co_general=>flg_true.
        <field_catalog_entry>-tech  = /ipe/co_general=>flg_false.
      ENDIF.
      IF <field_catalog_entry>-fieldname = /drt/co_cd_general_constants=>logname.
        <field_catalog_entry>-emphasize = 'C410'.
      ENDIF.
      IF <field_catalog_entry>-fieldname = /drt/co_cd_general_constants=>pp_standard_classname.
        <field_catalog_entry>-emphasize = 'C410'.
      ENDIF.
      IF <field_catalog_entry>-fieldname = /drt/co_cd_general_constants=>pp_group_category_name.
        <field_catalog_entry>-emphasize = 'C410'.
      ENDIF.
      IF <field_catalog_entry>-fieldname = /drt/co_cd_general_constants=>customizing_img_ids_only_text.
        <field_catalog_entry>-no_out = /ipe/co_general=>flg_true.
      ENDIF.
      IF <field_catalog_entry>-fieldname = /drt/co_cd_general_constants=>rapi_category.
        <field_catalog_entry>-no_out = /ipe/co_general=>flg_true.
      ENDIF.
      IF <field_catalog_entry>-fieldname = /drt/co_cd_general_constants=>data_source.
        <field_catalog_entry>-no_out = /ipe/co_general=>flg_true.
      ENDIF.
    ENDLOOP.

    LOOP AT <tab_extended_field_catalog> ASSIGNING <field_catalog_entry>.
      counter_field_catalog = counter_field_catalog + 1.

      IF counter_field_catalog = 4.
        counter_field_catalog = counter_field_catalog + 1.
      ENDIF.

      IF <field_catalog_entry>-fieldname = /drt/co_cd_general_constants=>logname.
        <field_catalog_entry>-col_pos = 4.
        counter_field_catalog = counter_field_catalog - 1.
      ELSE.
        <field_catalog_entry>-col_pos = counter_field_catalog.
      ENDIF.
    ENDLOOP.

    DATA(number_of_fields) = lines( <tab_extended_field_catalog> ).
    ASSIGN <tab_extended_field_catalog>[ fieldname = /drt/co_cd_general_constants=>customizing_tables_info ] TO FIELD-SYMBOL(<cust_tab_info_field>).
    number_of_fields = number_of_fields + 1.
    <cust_tab_info_field>-col_pos = number_of_fields.
    ASSIGN <tab_extended_field_catalog>[ fieldname = /drt/co_cd_general_constants=>parameter_service ] TO FIELD-SYMBOL(<parameter_service_field>).
    number_of_fields = number_of_fields + 1.
    <parameter_service_field>-col_pos = number_of_fields.
    ASSIGN <tab_extended_field_catalog>[ fieldname = /drt/co_cd_general_constants=>cash_component ] TO FIELD-SYMBOL(<cash_component_field>).
    number_of_fields = number_of_fields + 1.
    <cash_component_field>-col_pos = number_of_fields.
    ASSIGN <tab_extended_field_catalog>[ fieldname = /drt/co_cd_general_constants=>customizing_img_ids_iconized ] TO FIELD-SYMBOL(<customizing_img_ids>).
    number_of_fields = number_of_fields + 1.
    <customizing_img_ids>-col_pos = number_of_fields.
    ASSIGN <tab_extended_field_catalog>[ fieldname = /drt/co_cd_general_constants=>rapis ] TO FIELD-SYMBOL(<rapis>).
    number_of_fields = number_of_fields + 1.
    <rapis>-col_pos = number_of_fields.
    ASSIGN <tab_extended_field_catalog>[ fieldname = /drt/co_cd_general_constants=>mappings_string ] TO FIELD-SYMBOL(<mappings_string>).
    number_of_fields = number_of_fields + 1.
    <mappings_string>-col_pos = number_of_fields.
  ENDMETHOD.
ENDCLASS.
