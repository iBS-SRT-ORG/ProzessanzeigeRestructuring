INTERFACE /drt/if_cd_pp_cust_entry
  PUBLIC .

  METHODS is_function_set_exists
    RETURNING VALUE(result) TYPE flag.
  METHODS get_cash_component
    RETURNING VALUE(result) TYPE /ibs/ebs_cash_comp.
  METHODS is_cash_comp_exists_but_deact
    RETURNING VALUE(result) TYPE flag.
  METHODS get_pp_customizing_entry
    RETURNING VALUE(result) TYPE /ibs/sbs_pp_cus_display.
  METHODS get_flag_active_cash_component
    RETURNING VALUE(result) TYPE flag.
  METHODS is_diff_criteria_inactive
    RETURNING VALUE(result) TYPE flag.
  METHODS get_differentiation_criteria
    RETURNING VALUE(result) TYPE /ipe/e_dfval.
  METHODS has_cash_component
    RETURNING VALUE(result) TYPE flag.
ENDINTERFACE.
