CLASS /drt/cl_cd_row_clck_param_srv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES /drt/if_cd_row_dble_clck_hndlr .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /drt/cl_cd_row_clck_param_srv IMPLEMENTATION.
  METHOD /drt/if_cd_row_dble_clck_hndlr~handle_row_double_click.
    "Egal welche Einstellung gewaehlt wurde --> Transaktion zur Pflege aufrufen
    CALL TRANSACTION '/IPE/PARAMETER' AND SKIP FIRST SCREEN.
  ENDMETHOD.

ENDCLASS.
