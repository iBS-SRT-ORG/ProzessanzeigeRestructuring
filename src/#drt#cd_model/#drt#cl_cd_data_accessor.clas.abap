CLASS /drt/cl_cd_data_accessor DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES /drt/if_cd_model_data_accessor .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /drt/cl_cd_data_accessor IMPLEMENTATION.


  METHOD /drt/if_cd_model_data_accessor~read_cash_components_assgnment.
    SELECT * FROM /ibs/cbs_comp_id INTO TABLE tab_component_ids.
  ENDMETHOD.


  METHOD /drt/if_cd_model_data_accessor~read_differentiation_criteria.
    SELECT * FROM /ibs/vbs_proddis INTO TABLE tab_product_differentiation
    WHERE ro_cat = selection_screen_selection-reporting_obj_category
    AND   prod_dif_cat IN selection_screen_selection-prod_dif_cat_ran[].
  ENDMETHOD.


  METHOD /drt/if_cd_model_data_accessor~read_pp_groups.
    SELECT * FROM /ipe/c_pp_grp INTO TABLE tab_pp_groups.
  ENDMETHOD.


  METHOD /drt/if_cd_model_data_accessor~read_pp_group_assigns.
    SELECT * FROM /ipe/c_pp_grp_as INTO TABLE tab_pp_group_assigns
    WHERE run_type = selection_screen_selection-run_type AND
    ro_cat   = selection_screen_selection-reporting_obj_category.
  ENDMETHOD.


  METHOD /drt/if_cd_model_data_accessor~read_source_tables.
    /ipe/cl_con_factory=>get_data_source(
      EXPORTING
        im_run_type        = selection_screen_selection-run_type
        im_ro_cat          = selection_screen_selection-reporting_obj_category
        im_business_date   = selection_screen_selection-business_date
        im_package_size    = 100
        im_also_inactive   = abap_true
       IMPORTING
        ex_tab_data_source = tab_data_sources ).
  ENDMETHOD.


  METHOD /drt/if_cd_model_data_accessor~read_srt_documentation.
    SELECT * FROM /ibs/csr_wdoku INTO TABLE tab_wdoku.
  ENDMETHOD.


  METHOD /drt/if_cd_model_data_accessor~read_target_config_frm_buffer.
    tab_write_destinations = /ibs/cl_bs_as_write_d_sao=>get_instance( )->get_tab_write_d( ).
  ENDMETHOD.
ENDCLASS.
