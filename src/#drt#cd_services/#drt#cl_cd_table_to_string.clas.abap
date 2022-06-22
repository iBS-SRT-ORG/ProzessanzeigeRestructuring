CLASS /drt/cl_cd_table_to_string DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS concatenate_entrys_to_string
      IMPORTING table_to_concatenate TYPE ANY TABLE
                field_name           TYPE char30
      RETURNING VALUE(result)        TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS /drt/cl_cd_table_to_string IMPLEMENTATION.
  METHOD concatenate_entrys_to_string.
    LOOP AT table_to_concatenate ASSIGNING FIELD-SYMBOL(<table_entry>).
      ASSIGN COMPONENT field_name OF STRUCTURE <table_entry> TO FIELD-SYMBOL(<field_value_to_concatenate>).
      IF result IS INITIAL.
        result = |{ <field_value_to_concatenate> }|.
      ELSE.
        result = |{ result } , { <field_value_to_concatenate> }|.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
