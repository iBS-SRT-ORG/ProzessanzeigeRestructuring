INTERFACE /drt/if_cd_alv_data_builder
  PUBLIC .


  METHODS build_alv_data
    IMPORTING
      !rtts_alv_table_scheme      TYPE REF TO cl_abap_structdescr
      !model_data                 TYPE /drt/s_cd_model_data
      !selection_screen_selection TYPE /drt/s_cd_selection_screen
    RETURNING
      VALUE(tab_alv_data)         TYPE REF TO data .
ENDINTERFACE.
