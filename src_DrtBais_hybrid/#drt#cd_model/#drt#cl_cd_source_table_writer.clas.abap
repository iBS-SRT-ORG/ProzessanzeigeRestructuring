CLASS /drt/cl_cd_source_table_writer DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES /drt/if_cd_source_table_writer .
  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS append_source_table_info
      IMPORTING
        !counter           TYPE int4
        !data_source_table TYPE /ipe/s_tabname_con_cat
        !alv_entry         TYPE REF TO data .
ENDCLASS.



CLASS /drt/cl_cd_source_table_writer IMPLEMENTATION.


  METHOD /drt/if_cd_source_table_writer~write_source_tables_into_alv.
    DATA counter TYPE i VALUE 0.
    FIELD-SYMBOLS: <alv_table> TYPE ANY TABLE.
    ASSIGN alv_table->* TO <alv_table>.
    ASSIGN alv_entry->* TO FIELD-SYMBOL(<alv_entry>).

    LOOP AT tab_data_sources ASSIGNING FIELD-SYMBOL(<data_source>).
      counter = counter + 1.
      me->append_source_table_info(
             counter           = counter
             data_source_table = <data_source>
             alv_entry         = REF #( <alv_entry> ) ).
      INSERT <alv_entry> INTO TABLE <alv_table>.
    ENDLOOP.
  ENDMETHOD.


  METHOD append_source_table_info.

    FIELD-SYMBOLS: <logname> TYPE /ibs/esr_logname.
    ASSIGN alv_entry->* TO FIELD-SYMBOL(<alv_entry>).
    TRY.
        ASSIGN COMPONENT 'LOGNAME' OF STRUCTURE <alv_entry> TO <logname>.
        DATA(temporary_counter) = counter.
*        temporary_counter = temporary_counter && '.'.
        <logname> = temporary_counter && '. Quelltabelle' && '>>>' && data_source_table-tablename.
      CATCH cx_root INTO DATA(msg_cx_root).
        DATA(error_text) = msg_cx_root->get_text( ).
        error_text = error_text && 'cx_root'.
        MESSAGE i398(00) WITH error_text space space space.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
