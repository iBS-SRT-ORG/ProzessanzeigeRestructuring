INTERFACE /drt/if_cd_row_dble_clck_hndlr
  PUBLIC .
  METHODS handle_row_double_click
    IMPORTING clicked_row_information TYPE /drt/s_row_dble_clck_im_params
              view                     TYPE REF TO /ruif/if_view
              model                    TYPE REF TO /ruif/if_model.
ENDINTERFACE.
