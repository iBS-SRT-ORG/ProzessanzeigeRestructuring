CLASS /drt/cl_cd_event_hnldr_s_fctry DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS create_correct_abstrct_factory
      IMPORTING model         TYPE REF TO /ruif/if_model
      RETURNING VALUE(result) TYPE REF TO /drt/if_cd_evt_hndlr_abs_fctry.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /drt/cl_cd_event_hnldr_s_fctry IMPLEMENTATION.
  METHOD create_correct_abstrct_factory.
    FIELD-SYMBOLS:<model_data> TYPE /drt/s_cd_model_data.
    DATA(ref_model_data) = model->get_model_data( ).

    ASSIGN ref_model_data->* TO <model_data>.
    DATA(reporting_object_category) = <model_data>-selection_screen_selection-reporting_obj_category.
"ToDO: eindeutigen Identifier finden, anhand dem Factory erstellt wird.
    IF reporting_object_category CP 'DRT*'.
      result = NEW /drt/cl_cd_drt_evt_hndlr_fctry( ).
      RETURN.
    ENDIF.
    result = NEW /drt/cl_cd_nondrt_ehndlr_fctry( ).
  ENDMETHOD.

ENDCLASS.
