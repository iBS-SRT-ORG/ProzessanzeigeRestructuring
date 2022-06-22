CLASS /drt/cl_cd_grid_layout_strtegy DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES /ruif/if_alv_layout_strategy .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /drt/cl_cd_grid_layout_strtegy IMPLEMENTATION.
  METHOD /ruif/if_alv_layout_strategy~create_layout.
  CREATE DATA layout TYPE lvc_s_layo.
  FIELD-SYMBOLS: <layout> TYPE lvc_s_layo.
  ASSIGN layout->* TO <layout>.

  FIELD-SYMBOLS:<model_data> TYPE /drt/s_cd_model_data.
  DATA(model_data) = model->get_model_data( ).
  ASSIGN model_data->* TO <model_data>.
  DATA(grid_title) = <model_data>-selection_screen_selection-reporting_obj_category.
    <layout>-grid_title = grid_title.
    <layout>-zebra      = /ipe/co_general=>flg_true.
    <layout>-cwidth_opt = /ipe/co_general=>flg_true.
    <layout>-info_fname = 'LINE_COLOR'.
    <layout>-ctab_fname = 'CELLCOLOR'.
  ENDMETHOD.
ENDCLASS.
