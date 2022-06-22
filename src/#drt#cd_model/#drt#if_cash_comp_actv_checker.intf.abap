*"* components of interface /IBS/IF_BS_AS_CHECK_COMP_IS_AC
INTERFACE /drt/if_cash_comp_actv_checker
  PUBLIC .


  constants CO_CC_DEPOSIT_GUARANTEE type /IBS/EBS_CASH_COMP value 'DG' ##NO_TEXT.
  constants CO_CC_EMI_FROM_2013 type /IBS/EBS_CASH_COMP value 'EM' ##NO_TEXT.
  constants CO_CC_ULTIMATE_RISK type /IBS/EBS_CASH_COMP value 'UR' ##NO_TEXT.
  constants CO_CC_FINREP type /IBS/EBS_CASH_COMP value 'FR' ##NO_TEXT.
  constants CO_CC_ANACREDIT type /IBS/EBS_CASH_COMP value 'AC' ##NO_TEXT.
  constants CO_PP_GRP type /IPE/E_PP_GRP value 'BS_CC' ##NO_TEXT.
  constants CO_CC_STAT_WP_INVEST type /IBS/EBS_CASH_COMP value 'SI' ##NO_TEXT.
  constants CO_CC_WP_INVEST type /IBS/EBS_CASH_COMP value 'SISIA' ##NO_TEXT.
  constants CO_CC_CMS type /IBS/EBS_CASH_COMP value 'CMS' ##NO_TEXT.
  constants CO_CC_SACCR type /IBS/EBS_CASH_COMP value 'SACCR' ##NO_TEXT.
  constants CO_CC_WI type /IBS/EBS_CASH_COMP value 'WI' ##NO_TEXT.

  methods CHECK_COMP_IS_ACTIVE
    importing
      !IM_CASH_COMP type /IBS/EBS_CASH_COMP
    returning
      value(RE_ACTIVE) type FLAG .
endinterface.
