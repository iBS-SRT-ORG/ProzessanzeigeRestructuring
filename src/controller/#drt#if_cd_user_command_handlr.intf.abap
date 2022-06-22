INTERFACE /drt/if_cd_user_command_handlr
  PUBLIC.
  METHODS handle_user_command
    IMPORTING view  TYPE REF TO /ruif/if_view
              model TYPE REF TO /ruif/if_model.
ENDINTERFACE.
