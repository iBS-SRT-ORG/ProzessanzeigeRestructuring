CLASS /drt/cl_cd_row_clck_lognme_drt DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES /drt/if_cd_row_dble_clck_hndlr .
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS display_docu_in_website
      IMPORTING
        value TYPE char30.
ENDCLASS.



CLASS /drt/cl_cd_row_clck_lognme_drt IMPLEMENTATION.
  METHOD /drt/if_cd_row_dble_clck_hndlr~handle_row_double_click.
    DATA(alv_grid) = CAST cl_gui_alv_grid( CAST /ruif/if_view_custom_control( view )->get_view_object( ) ).
    DATA value TYPE char30.

    alv_grid->set_current_cell_via_id(
                is_row_id    = clicked_row_information-row_that_was_clicked
                is_column_id = VALUE lvc_s_col( fieldname = 'LOGNAME')
                is_row_no    = clicked_row_information-row_no_that_was_clicked ).
    alv_grid->get_current_cell( IMPORTING e_value = value ).
    display_docu_in_website( value ).
  ENDMETHOD.

  METHOD display_docu_in_website.
    IF value IS NOT INITIAL.
    DATA(website_docu) = |https://intranet.ibs-banking.com/display/IP/{ value }|.
      cl_gui_frontend_services=>execute(
        EXPORTING
          document               = website_docu
        EXCEPTIONS
          cntl_error             = 1
          error_no_gui           = 2
          bad_parameter          = 3
          file_not_found         = 4
          path_not_found         = 5
          file_extension_unknown = 6
          error_execute_failed   = 7
          synchronous_failed     = 8
          not_supported_by_gui   = 9
          OTHERS                 = 10 ).
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
