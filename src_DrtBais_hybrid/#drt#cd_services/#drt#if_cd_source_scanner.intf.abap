INTERFACE /drt/if_cd_source_scanner
  PUBLIC .
  METHODS get_tokens
    RETURNING VALUE(result) TYPE stokes_tab.
ENDINTERFACE.
