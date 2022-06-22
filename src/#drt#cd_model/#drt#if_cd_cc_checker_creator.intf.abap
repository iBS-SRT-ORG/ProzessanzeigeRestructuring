INTERFACE /drt/if_cd_cc_checker_creator
  PUBLIC .


  METHODS create_cash_comp_activ_checker
    IMPORTING
      !selection_screen_selection   TYPE /drt/s_cd_selection_screen
      !pp_group                     TYPE /ipe/e_pp_grp
    RETURNING
      VALUE(cash_component_checker) TYPE REF TO /ibs/if_bs_as_check_comp_is_ac .
ENDINTERFACE.
