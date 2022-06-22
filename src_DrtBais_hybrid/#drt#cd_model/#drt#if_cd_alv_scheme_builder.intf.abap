interface /DRT/IF_CD_ALV_SCHEME_BUILDER
  public .


  methods BUILD_ALV_TABLE_SCHEME
    importing
      !TAB_MODEL_DATA type /DRT/S_CD_MODEL_DATA
    returning
      value(rtts_alv_table_scheme) type ref to cl_abap_structdescr  .
endinterface.
