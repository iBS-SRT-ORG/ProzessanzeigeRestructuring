CLASS /drt/cl_cd_cc_checker_creator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES /drt/if_cd_cc_checker_creator .
  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS cast_cc_checker
      IMPORTING
        !uncasted_cc_checker     TYPE REF TO /ipe/if_pp
        !error_text              TYPE string
      RETURNING
        VALUE(casted_cc_checker) TYPE REF TO /ibs/if_bs_as_check_comp_is_ac .
    METHODS get_cc_checker_from_engine
      IMPORTING
        !selection_screen_selection TYPE /drt/s_cd_selection_screen
      EXPORTING
        !error_text                 TYPE string
      RETURNING
        VALUE(uncasted_cc_checker)  TYPE REF TO /ipe/if_pp .
ENDCLASS.



CLASS /drt/cl_cd_cc_checker_creator IMPLEMENTATION.

  METHOD /drt/if_cd_cc_checker_creator~create_cash_comp_activ_checker.
    DATA error_text TYPE string.
    "Hier leider zusätzlicher EXPORTING-Parameter benötigt (error_text),
    "da error_text in nächster Methode gebraucht wird
    DATA(uncasted_cc_checker) = get_cc_checker_from_engine(
                                  EXPORTING
                                    selection_screen_selection = selection_screen_selection
                                  IMPORTING
                                    error_text                 = error_text
                                ).

    cash_component_checker = cast_cc_checker(
                               uncasted_cc_checker = uncasted_cc_checker
                               error_text          = error_text ).

  ENDMETHOD.

  METHOD cast_cc_checker.
    TRY.
        casted_cc_checker ?= uncasted_cc_checker.
      CATCH cx_sy_move_cast_error INTO DATA(oref_root).
        MESSAGE e035(/ibs/bs_as)
        WITH 'Objekttyp /IBS/IF_BS_AS_CHECK_COMP_IS_AC'(001) error_text.
*      RAISING data_error.
    ENDTRY.
  ENDMETHOD.

  METHOD get_cc_checker_from_engine.
    TRY.
        /ipe/cl_pp_factory=>get_obj_pp(
            EXPORTING
              im_business_date = selection_screen_selection-business_date
              im_ro_cat        = selection_screen_selection-reporting_obj_category
              im_run_type      = selection_screen_selection-run_type
              im_pp_grp        = 'BS_CC'
            IMPORTING
              ex_obj_pp        = uncasted_cc_checker ).
      CATCH /ipe/cx_abstract INTO DATA(oref_root) .
        error_text = oref_root->get_text( ).
        MESSAGE e035(/ibs/bs_as)
        WITH 'Objekt in der Engine'(001) error_text.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
