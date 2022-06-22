INTERFACE /drt/if_cd_alv_field
  PUBLIC .
  METHODS get_field_value
    RETURNING VALUE(result) TYPE /ibs/ebs_logname.
  METHODS detrmine_field_value_for_entry.
ENDINTERFACE.
