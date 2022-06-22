INTERFACE /drt/if_cd_cust_alv_table_data
  PUBLIC .

  METHODS
    get_ref_alv_table_data
      RETURNING VALUE(result) TYPE REF TO data.
  METHODS
    create_alv_data
      IMPORTING
        selection_screen_selection TYPE /drt/s_cd_selection_screen
        model_data                 TYPE /drt/s_cd_model_data.
  METHODS
    enrich_alv_data
      IMPORTING
        selection_screen_selection TYPE /drt/s_cd_selection_screen
        model_data                 TYPE /drt/s_cd_model_data.
ENDINTERFACE.
