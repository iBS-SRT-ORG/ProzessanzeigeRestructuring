CLASS /drt/cl_cd_source_scanner DEFINITION
  PUBLIC
  INHERITING FROM cl_source_scanner
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES /drt/if_cd_source_scanner .
    METHODS constructor
      IMPORTING classname TYPE seoclsname.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA classname TYPE seoclsname.
ENDCLASS.



CLASS /drt/cl_cd_source_scanner IMPLEMENTATION.

  METHOD constructor.
    super->constructor( ).
    me->classname = classname.
    cl_oo_factory=>create_instance( )->create_clif_source( me->classname )->get_source( IMPORTING source = me->source ).
    TRY.
        me->scan( ).
      CATCH cx_oo_clif_scan_error INTO DATA(cx_scan_error).
    ENDTRY.
  ENDMETHOD.

  METHOD /drt/if_cd_source_scanner~get_tokens.
    result = me->tokens.
  ENDMETHOD.

ENDCLASS.
