INTERFACE /drt/if_cd_cust_alv_entry
  PUBLIC .
  METHODS get_std_pp_group_class_name
    RETURNING VALUE(result) TYPE char30.
  METHODS get_class_name_ohne_dffrnzrng
    RETURNING VALUE(result) TYPE /ipe/e_pp_classname .
  METHODS get_differentiation_criteria
    IMPORTING
              diff_criteria_field_name TYPE /ibs/ebs_prod_dif_cat_intern
    RETURNING VALUE(result)            TYPE char30.
  METHODS get_cash_component
    RETURNING VALUE(result) TYPE /ibs/ebs_cash_comp_txt.
  METHODS is_key_identical_to
    IMPORTING
              pp_customizing_entry TYPE REF TO /drt/if_cd_pp_cust_entry
    RETURNING VALUE(result)        TYPE flag.
  METHODS get_cust_display_alv_entry
    RETURNING VALUE(result) TYPE REF TO data.
  METHODS is_diff_cls_not_eq_to_std_cls
    IMPORTING
              diff_criteria_class_name TYPE char30
    RETURNING VALUE(result)            TYPE flag.
  METHODS is_diff_criteria_inactive
    IMPORTING
              diff_criteria_field_name TYPE char30
    RETURNING VALUE(result)            TYPE flag.
  METHODS read_pp_group_std_clss
    IMPORTING
      model_data                  TYPE /drt/s_cd_model_data
      currently_iterated_pp_entry TYPE REF TO /drt/if_cd_pp_cust_entry.
  METHODS fill_iterated_dif_crit_field
    IMPORTING model_data                  TYPE /drt/s_cd_model_data
              currently_iterated_pp_entry TYPE REF TO /drt/if_cd_pp_cust_entry.
  METHODS
    dtrmn_yet_missing_column_info
      IMPORTING model_data TYPE /drt/s_cd_model_data.
  METHODS get_all_clsnames_in_entry
    IMPORTING model_data    TYPE /drt/s_cd_model_data
    RETURNING VALUE(result) TYPE /drt/ty_cd_clss_names_in_entry.
ENDINTERFACE.
