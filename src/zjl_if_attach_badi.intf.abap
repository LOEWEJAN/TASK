INTERFACE zjl_if_attach_badi
  PUBLIC .


  INTERFACES if_badi_interface .

  METHODS determine
    IMPORTING
      !i_change_mode TYPE zjl_mode
    CHANGING
      !cs_entity     TYPE zjl_cl_attach_bo=>tp_entity .

  METHODS check
    IMPORTING
      !is_entity        TYPE zjl_cl_attach_bo=>tp_entity
      !i_change_mode    TYPE zjl_mode
    EXPORTING
      !et_message       TYPE zjl_if_rap=>tpt_message
    CHANGING
      VALUE(c_is_valid) TYPE abap_bool .

  METHODS default_for_create
    CHANGING
      !cs_entity TYPE zjl_cl_attach_bo=>tp_entity .

  METHODS map_to_entity
    IMPORTING
      !is_db     TYPE zjl_cl_attach_da=>tp_db
    CHANGING
      !cs_entity TYPE zjl_cl_attach_bo=>tp_entity .

  METHODS map_to_db
    IMPORTING
      !is_entity TYPE zjl_cl_attach_bo=>tp_entity
    CHANGING
      !cs_db     TYPE zjl_cl_attach_da=>tp_db .

ENDINTERFACE.
