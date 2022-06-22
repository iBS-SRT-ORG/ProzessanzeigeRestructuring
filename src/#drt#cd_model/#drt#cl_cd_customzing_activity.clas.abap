CLASS /drt/cl_cd_customzing_activity DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING customizing_act_id TYPE string.

    INTERFACES /drt/if_cd_customzing_activity .
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS determine_textual_description.
    DATA customizing_activity TYPE /drt/s_cd_cus_img_activity.
ENDCLASS.



CLASS /drt/cl_cd_customzing_activity IMPLEMENTATION.
  METHOD /drt/if_cd_customzing_activity~get_customizing_activity.
    result = me->customizing_activity.
  ENDMETHOD.

  METHOD constructor.
    me->customizing_activity-customizing_img_id = customizing_act_id.
    me->determine_textual_description( ).
  ENDMETHOD.

  METHOD determine_textual_description.
    SELECT text FROM cus_imgact
    WHERE spras = @sy-langu AND activity = @me->customizing_activity-customizing_img_id
    INTO TABLE @DATA(customizing_activity_texts).
    TRY.
        me->customizing_activity-textual_description = customizing_activity_texts[ 1 ].
      CATCH cx_sy_itab_line_not_found.
        me->customizing_activity-textual_description = 'Keine Aktivitätsbeschreibung vorliegend.'.
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
