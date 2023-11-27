INTERFACE zjl_if_task_badi
  PUBLIC .

  INTERFACES if_badi_interface .

  METHODS determine
    IMPORTING
      !i_change_mode TYPE zjl_mode
    CHANGING
      !cs_entity     TYPE zjl_cl_task_bo=>tp_entity .
  METHODS check
    IMPORTING
      !is_entity        TYPE zjl_cl_task_bo=>tp_entity
      !i_change_mode    TYPE zjl_mode
    EXPORTING
      !et_message       TYPE zjl_if_rap=>tpt_message
    CHANGING
      VALUE(c_is_valid) TYPE abap_bool .
  METHODS get_global_features
    IMPORTING
      !i_feature TYPE zjl_feature
    CHANGING
      !c_flag    TYPE zjl_enable .
  METHODS get_instance_features
    IMPORTING
      !i_taskid  TYPE zjl_id
      !i_versno  TYPE zjl_version
      !i_feature TYPE zjl_feature
    CHANGING
      !c_flag    TYPE zjl_enable .
  METHODS get_instance_authorizations
    IMPORTING
      !i_taskid  TYPE zjl_id
      !i_versno  TYPE zjl_version
      !i_feature TYPE zjl_feature
    CHANGING
      !c_flag    TYPE zjl_enable .
  METHODS default_for_create
    CHANGING
      !cs_entity TYPE zjl_cl_task_bo=>tp_entity .
  METHODS precheck_create
    IMPORTING
      !is_entity  TYPE zjl_cl_task_bo=>tp_entity
    EXPORTING
      !et_message TYPE zjl_if_rap=>tpt_message .
  METHODS precheck_update
    IMPORTING
      !is_entity  TYPE zjl_cl_task_bo=>tp_entity
    EXPORTING
      !et_message TYPE zjl_if_rap=>tpt_message .
  METHODS map_to_entity
    IMPORTING
      !is_db     TYPE zjl_cl_task_da=>tp_db
    CHANGING
      !cs_entity TYPE zjl_cl_task_bo=>tp_entity .
  METHODS map_to_db
    IMPORTING
      !is_entity TYPE zjl_cl_task_bo=>tp_entity
    CHANGING
      !cs_db     TYPE zjl_cl_task_da=>tp_db .

ENDINTERFACE.
