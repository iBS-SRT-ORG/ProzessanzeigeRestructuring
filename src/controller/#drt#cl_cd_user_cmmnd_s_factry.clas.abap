CLASS /drt/cl_cd_user_cmmnd_s_factry DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS get_user_command_handler
      IMPORTING user_command  TYPE sy-ucomm
      RETURNING VALUE(result) TYPE REF TO /drt/if_cd_user_command_handlr.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /drt/cl_cd_user_cmmnd_s_factry IMPLEMENTATION.
  METHOD get_user_command_handler.
    CASE user_command.
      WHEN 'EXTRACT_MAPPING_INTO_EXCEL_SHEET'.
        result = NEW /drt/cl_cd_extrct_mappng_hndlr( ).
    ENDCASE.
  ENDMETHOD.

ENDCLASS.
