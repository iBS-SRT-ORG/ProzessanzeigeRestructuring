CLASS /drt/cl_cd_nondrt_ehndlr_fctry DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES /drt/if_cd_evt_hndlr_abs_fctry .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /drt/cl_cd_nondrt_ehndlr_fctry IMPLEMENTATION.
  METHOD /drt/if_cd_evt_hndlr_abs_fctry~create_row_double_click_hndlr.
    CASE column_name.
      WHEN 'PARAM_SERVICE'.
        result = NEW /drt/cl_cd_row_clck_param_srv( ).
      WHEN 'LOGNAME'.
        result = NEW /drt/cl_cd_clck_logname_nondrt( ).
    ENDCASE.
  ENDMETHOD.

  METHOD /drt/if_cd_evt_hndlr_abs_fctry~create_user_command_hndlr.
    CASE user_command.
      WHEN 'EXTRACT_MAPPING_INTO_EXCEL_SHEET'.
        result = NEW /drt/cl_cd_extrct_mappng_hndlr( ).
    ENDCASE.
  ENDMETHOD.

ENDCLASS.
