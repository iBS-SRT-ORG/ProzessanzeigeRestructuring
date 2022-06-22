interface /DRT/IF_CD_MODEL_DATA_ACCESSOR
  public .


  methods READ_DIFFERENTIATION_CRITERIA
    importing
      !SELECTION_SCREEN_SELECTION type /DRT/S_CD_SELECTION_SCREEN
    returning
      value(TAB_PRODUCT_DIFFERENTIATION) type /IBS/TYBS_PRODDIS .
  methods READ_PP_GROUPS
    returning
      value(TAB_PP_GROUPS) type /IPE/TY_PP_GRP .
  methods READ_PP_GROUP_ASSIGNS
    importing
      !SELECTION_SCREEN_SELECTION type /DRT/S_CD_SELECTION_SCREEN
    returning
      value(TAB_PP_GROUP_ASSIGNS) type /IPE/TY_PP_GRP_AS .
  methods READ_SRT_DOCUMENTATION
    returning
      value(TAB_WDOKU) type /IBS/TYSR_WDOKU .
  methods READ_SOURCE_TABLES
    importing
      !SELECTION_SCREEN_SELECTION type /DRT/S_CD_SELECTION_SCREEN
    returning
      value(TAB_DATA_SOURCES) type /IPE/TY_TABNAME_CON_CAT
    raising
      /IPE/CX_CON_FACTORY
      /IPE/CX_ABSTRACT .
  methods READ_TARGET_CONFIG_FRM_BUFFER
    returning
      value(TAB_WRITE_DESTINATIONS) type /IBS/TYBS_WRITE_D .
  methods READ_CASH_COMPONENTS_ASSGNMENT
    returning
      value(TAB_COMPONENT_IDS) type /IBS/TYBS_COMP_ID .
endinterface.
