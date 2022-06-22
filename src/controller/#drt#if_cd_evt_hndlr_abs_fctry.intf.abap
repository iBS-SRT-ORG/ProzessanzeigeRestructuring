INTERFACE /drt/if_cd_evt_hndlr_abs_fctry
  PUBLIC.
  METHODS create_row_double_click_hndlr
    IMPORTING column_name   TYPE char30
    RETURNING VALUE(result) TYPE REF TO /drt/if_cd_row_dble_clck_hndlr.
  METHODS create_user_command_hndlr
    IMPORTING user_command  TYPE sy-ucomm
    RETURNING VALUE(result) TYPE REF TO /drt/if_cd_user_command_handlr.

ENDINTERFACE.
