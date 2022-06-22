INTERFACE /drt/if_cd_source_table_writer
  PUBLIC .


  METHODS write_source_tables_into_alv
    IMPORTING
      !tab_data_sources TYPE /ipe/ty_tabname_con_cat
      !alv_entry        TYPE REF TO data
      !alv_table        TYPE REF TO data .
ENDINTERFACE.
