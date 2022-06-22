CLASS /drt/cl_cd_row_click_s_factory DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS get_row_double_click_handler
      IMPORTING column_name   TYPE char30
      RETURNING VALUE(result) TYPE REF TO /drt/if_cd_row_dble_clck_hndlr.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /drt/cl_cd_row_click_s_factory IMPLEMENTATION.
  METHOD get_row_double_click_handler.
    CASE column_name.
      WHEN 'PARAM_SERVICE'.
        result = NEW /drt/cl_cd_row_clck_param_srv( ).

      WHEN 'LOGNAME'.
        result = NEW /drt/cl_cd_clck_logname_nondrt( ).
    ENDCASE.
  ENDMETHOD.

ENDCLASS.
