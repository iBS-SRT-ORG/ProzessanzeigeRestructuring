CLASS /drt/cl_cd_model_mapping_popup DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES /ruif/if_model .
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA model_data TYPE /drt/s_cd_mapping_popup_model.
ENDCLASS.

CLASS /drt/cl_cd_model_mapping_popup IMPLEMENTATION.
  METHOD /ruif/if_model~get_model.
    model = me.
  ENDMETHOD.

  METHOD /ruif/if_model~get_model_data.
    model_data = REF #( me->model_data ).
  ENDMETHOD.

  METHOD /ruif/if_model~get_model_data_to_display.
    model_data_to_display = REF #( me->model_data-model_data_to_display ).
  ENDMETHOD.

  METHOD /ruif/if_model~load_model.

  ENDMETHOD.
  METHOD /ruif/if_model~load_model_with_data.
    ASSIGN data->* TO FIELD-SYMBOL(<row_that_was_double_clicked>).

    ASSIGN COMPONENT 'STD_CLASSNAME' OF STRUCTURE <row_that_was_double_clicked> TO FIELD-SYMBOL(<popup_title>).
    me->model_data-popup_title = <popup_title>.

    ASSIGN COMPONENT 'MAPPING_TABLE' OF STRUCTURE <row_that_was_double_clicked> TO FIELD-SYMBOL(<mapping_table>).
    me->model_data-model_data_to_display = <mapping_table>.
  ENDMETHOD.
ENDCLASS.
