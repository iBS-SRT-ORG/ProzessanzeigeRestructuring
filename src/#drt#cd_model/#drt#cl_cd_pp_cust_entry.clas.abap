CLASS /drt/cl_cd_pp_cust_entry DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING pp_customizing_entry       TYPE /ibs/sbs_pp_cus_display
                selection_screen_selection TYPE /drt/s_cd_selection_screen.

    INTERFACES /drt/if_cd_pp_cust_entry .
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA pp_customizing_entry TYPE /ibs/sbs_pp_cus_display.
    DATA selection_screen_selection TYPE /drt/s_cd_selection_screen.
    DATA cash_component TYPE /ibs/ebs_cash_comp.
    DATA flag_active_cash_component TYPE flag.
    DATA differentiation_criteria TYPE /ipe/e_dfval.
ENDCLASS.



CLASS /drt/cl_cd_pp_cust_entry IMPLEMENTATION.

  METHOD /drt/if_cd_pp_cust_entry~get_cash_component.
    result = me->cash_component.
  ENDMETHOD.


  METHOD /drt/if_cd_pp_cust_entry~get_differentiation_criteria.
    result = differentiation_criteria.
  ENDMETHOD.


  METHOD /drt/if_cd_pp_cust_entry~get_flag_active_cash_component.
    result = flag_active_cash_component.
  ENDMETHOD.


  METHOD /drt/if_cd_pp_cust_entry~get_pp_customizing_entry.
    result = me->pp_customizing_entry.
  ENDMETHOD.


  METHOD /drt/if_cd_pp_cust_entry~has_cash_component.
    IF cash_component IS NOT INITIAL.
      result = abap_true.
    ELSE.
      result = abap_false.
    ENDIF.
  ENDMETHOD.


  METHOD /drt/if_cd_pp_cust_entry~is_cash_comp_exists_but_deact.
    IF flag_active_cash_component EQ abap_false AND cash_component IS NOT INITIAL.
      result = abap_true.
    ELSE.
      result = abap_false.
    ENDIF.
  ENDMETHOD.


  METHOD /drt/if_cd_pp_cust_entry~is_diff_criteria_inactive.
    IF me->pp_customizing_entry-flg_active IS INITIAL.
      result = abap_true.
    ELSE.
      result = abap_false.
    ENDIF.
  ENDMETHOD.


  METHOD /drt/if_cd_pp_cust_entry~is_function_set_exists.
    IF me->pp_customizing_entry-func_set IS NOT INITIAL.
      result = abap_true.
    ELSE.
      result = abap_false.
    ENDIF.
  ENDMETHOD.


  METHOD constructor.
    me->pp_customizing_entry = pp_customizing_entry.
    me->selection_screen_selection = selection_screen_selection.
"Bais-spezifische Logik!
*    SPLIT me->pp_customizing_entry-dfval_orig AT '!' INTO differentiation_criteria cash_component.
*    me->pp_customizing_entry-cash_comp = cash_component.
*    DATA(cash_component_checker) = NEW /drt/cl_cd_cc_checker_creator( )->/drt/if_cd_cc_checker_creator~create_cash_comp_activ_checker(
*                                                                                                   selection_screen_selection = selection_screen_selection
*                                                                                                   pp_group                   = 'BS_CC' ).
*    me->flag_active_cash_component = cash_component_checker->check_comp_is_active( cash_component ).
  ENDMETHOD.
ENDCLASS.
