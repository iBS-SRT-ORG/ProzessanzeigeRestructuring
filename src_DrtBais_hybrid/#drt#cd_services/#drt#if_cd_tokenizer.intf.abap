INTERFACE /drt/if_cd_tokenizer
  PUBLIC.
  METHODS tokenize_given_class
    IMPORTING class_name TYPE char30.
  METHODS tokenize_given_classes
    IMPORTING class_names TYPE /drt/ty_cd_clss_names_in_entry.
  METHODS get_sorted_tkns_no_duplicates
    RETURNING VALUE(result) TYPE stokes_tab.
  METHODS get_unaltered_tokens
    RETURNING VALUE(result) TYPE stokes_tab.
  METHODS filter_tkns_that_match_pattern
    IMPORTING pattern       TYPE string
    RETURNING VALUE(result) TYPE stokes_tab.
  METHODS filter_cmpnts_with_assgn_comp
    RETURNING VALUE(result) TYPE stokes_tab.
  METHODS get_value_of_given_constant
    IMPORTING name_of_constant TYPE string
    RETURNING VALUE(result)    TYPE stokes_tab.
ENDINTERFACE.
