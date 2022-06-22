CLASS /drt/cl_cd_fcat_ext_strategy DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES /ruif/if_fct_dynamic_strategy .
  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS extend_fcat_hard_coded
      IMPORTING
        !tab_field_catalog TYPE REF TO lvc_t_fcat .
    METHODS extend_fcat_dynamically
      IMPORTING
        !tab_field_catalog TYPE REF TO lvc_t_fcat
        !model             TYPE REF TO /ruif/if_model .
ENDCLASS.



CLASS /drt/cl_cd_fcat_ext_strategy IMPLEMENTATION.

  METHOD /ruif/if_fct_dynamic_strategy~dynamically_extend_field_ct.
    DATA(tab_field_catalog) = field_catalog->get_field_catalog( ).

    "hier Frage: warum werden hartgecodete Felder geaddet, warum nicht einfach neue Struktur mit diesen Feldern anlegen?
    extend_fcat_hard_coded( tab_field_catalog = tab_field_catalog ).
    extend_fcat_dynamically( tab_field_catalog = tab_field_catalog model = model ).
  ENDMETHOD.


  METHOD extend_fcat_dynamically.
    DATA type TYPE REF TO cl_abap_datadescr.
    DATA field_text TYPE lvc_txtcol.

    FIELD-SYMBOLS: <tab_extended_field_catalog> TYPE lvc_t_fcat.
    FIELD-SYMBOLS: <tab_model_data> TYPE /drt/s_cd_model_data.

    DATA(ref_tab_model_data) = model->get_model_data( ).
    ASSIGN ref_tab_model_data->* TO <tab_model_data>.
    DATA(tab_diff_criteria) = <tab_model_data>-tab_differentiation_criteria.

    ASSIGN tab_field_catalog->* TO <tab_extended_field_catalog>.
    DATA(counter_field_catalog) = lines( <tab_extended_field_catalog> ).

    IF tab_diff_criteria IS NOT INITIAL.
      type ?= cl_abap_typedescr=>describe_by_name( 'CHAR_50' ).
      LOOP AT tab_diff_criteria ASSIGNING FIELD-SYMBOL(<prod_dif_disp>).
        counter_field_catalog = counter_field_catalog + 1.
        DATA(text_of_field) = |{ <prod_dif_disp>-prod_dif_cat } - { <prod_dif_disp>-pdc_name }|.
        INSERT VALUE lvc_s_fcat(
          col_pos    = counter_field_catalog
          inttype    = 'C'
          outputlen  = 30
          key        = space
          fieldname  = <prod_dif_disp>-prod_dif_cat
          indx_field = counter_field_catalog
          coltext    = text_of_field
          seltext    = <prod_dif_disp>-prod_dif_cat ) INTO TABLE <tab_extended_field_catalog>.
      ENDLOOP.
    ELSE.
      MESSAGE s339(/ibs/bs_as) DISPLAY LIKE 'I'.
*   Keine Differenzierungsmerkmale selektiert.
    ENDIF.
  ENDMETHOD.


  METHOD extend_fcat_hard_coded.
    "ToDO: Methode aus altem Report übernommen, aber ist diese nicht theoretisch obsolet?
    "statt Feldkatalog hart gecodet zu erweitern -> Struktur anlegen?
    FIELD-SYMBOLS: <tab_extended_field_catalog> TYPE lvc_t_fcat.
    ASSIGN tab_field_catalog->* TO <tab_extended_field_catalog>.

    DATA(counter_fieldcat) = lines( <tab_extended_field_catalog> ).
    INSERT VALUE lvc_s_fcat(
                   inttype = 'C'
                   outputlen = 30
                   key = space
                   fieldname = /drt/co_cd_general_constants=>pp_standard_classname
                   indx_field = ( counter_fieldcat + 1 )
                   coltext = 'PP-Standardklasse'(005)
                   seltext = 'PP-Standardklasse' ) INTO TABLE <tab_extended_field_catalog>.
    INSERT VALUE lvc_s_fcat(
                   inttype = 'C'
                   outputlen = 40
                   key = space
                   fieldname = /drt/co_cd_general_constants=>pp_group_category_name
                   indx_field = ( counter_fieldcat + 2 )
                   coltext = 'PP-Verarbeitungstyp'
                   seltext = 'PP-Verarbeitungstyp' ) INTO TABLE <tab_extended_field_catalog>.
    INSERT VALUE lvc_s_fcat(
                   key = space
                   fieldname = /drt/co_cd_general_constants=>customizing_img_ids_iconized
                   indx_field = ( counter_fieldcat + 3 )
                   icon = abap_true
                   coltext = 'Customizing-Tabellen-IDs'
                   seltext = 'Customizing-Tabellen-IDs' ) INTO TABLE <tab_extended_field_catalog>.
    INSERT VALUE lvc_s_fcat(
                    key = space
                    fieldname = /drt/co_cd_general_constants=>customizing_img_ids_only_text
                    indx_field = ( counter_fieldcat + 4 )
                    icon = abap_true
                    coltext = 'Customizing-Tabellen-IDs'
                    seltext = 'Customizing-Tabellen-IDs' ) INTO TABLE <tab_extended_field_catalog>.
    INSERT VALUE lvc_s_fcat(
                   key = space
                   fieldname = /drt/co_cd_general_constants=>rapis
                   indx_field = ( counter_fieldcat + 5 )
                   coltext = 'RAPIs'
                   seltext = 'RAPIs' ) INTO TABLE <tab_extended_field_catalog>.
    INSERT VALUE lvc_s_fcat(
                   key = space
                   fieldname = /drt/co_cd_general_constants=>mappings_string
                   indx_field = ( counter_fieldcat + 6 )
                   coltext = 'Mappings'
                   seltext = 'Mappings' ) INTO TABLE <tab_extended_field_catalog>.
  ENDMETHOD.
ENDCLASS.
