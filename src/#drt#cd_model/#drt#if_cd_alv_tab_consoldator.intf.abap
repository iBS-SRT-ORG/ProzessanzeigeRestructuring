INTERFACE /drt/if_cd_alv_tab_consoldator
  PUBLIC .
  METHODS consolidate_alv_table_data
    IMPORTING
      ref_alv_table              TYPE REF TO data
      cust_display_alv_scheme    TYPE REF TO cl_abap_structdescr OPTIONAL
      ref_alv_entry              TYPE REF TO data
      selection_screen_selection TYPE /drt/s_cd_selection_screen
      model_data                 TYPE /drt/s_cd_model_data.
ENDINTERFACE.
