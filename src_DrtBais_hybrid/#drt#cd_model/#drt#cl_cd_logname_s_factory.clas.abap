CLASS /drt/cl_cd_logname_s_factory DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS get_logname_class
      IMPORTING logname_factory_im_params TYPE /drt/s_cd_logname_fctry_params
      RETURNING VALUE(result)             TYPE REF TO /drt/if_cd_alv_field.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /drt/cl_cd_logname_s_factory IMPLEMENTATION.
  METHOD get_logname_class.
    ASSIGN logname_factory_im_params-alv_entry->* TO FIELD-SYMBOL(<alv_entry>).
    ASSIGN COMPONENT  /drt/co_cd_general_constants=>pp_standard_classname OF STRUCTURE <alv_entry> TO FIELD-SYMBOL(<pp_standard_class_name>).
    IF <pp_standard_class_name> CP '/DRT/*'.
      result = NEW /drt/cl_cd_logname_wth_cnstnts( logname_factory_im_params-tokenizer ).
      RETURN.
    ENDIF.
    result = NEW /drt/cl_cd_logname_wth_cstmzng(
                  alv_entry  = REF #( <alv_entry> )
                  model_data = logname_factory_im_params-model_data ).
  ENDMETHOD.

ENDCLASS.
