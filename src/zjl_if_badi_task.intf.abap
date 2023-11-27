interface ZJL_IF_BADI_TASK
  public .


  interfaces IF_BADI_INTERFACE .

  methods DETERMINE
    importing
      !I_CHANGE_MODE type ZJL_MODE
    changing
      !CS_ENTITY type ZJL_CL_TASK_BO=>TP_ENTITY .
  methods CHECK
    importing
      !IS_ENTITY type ZJL_CL_TASK_BO=>TP_ENTITY
      !I_CHANGE_MODE type ZJL_MODE
    exporting
      !ET_MESSAGE type ZJL_IF_RAP=>TPT_MESSAGE
    changing
      value(C_IS_VALID) type ABAP_BOOL .
  methods GET_GLOBAL_FEATURES
    importing
      !I_FEATURE type ZJL_FEATURE
    changing
      !C_FLAG type ZJL_ENABLE .
  methods GET_INSTANCE_FEATURES
    importing
      !I_TASKID type ZJL_ID
      !I_VERSNO type ZJL_VERSION
      !I_FEATURE type ZJL_FEATURE
    changing
      !C_FLAG type ZJL_ENABLE .
  methods GET_INSTANCE_AUTHORIZATIONS
    importing
      !I_TASKID type ZJL_ID
      !I_VERSNO type ZJL_VERSION
      !I_FEATURE type ZJL_FEATURE
    changing
      !C_FLAG type ZJL_ENABLE .
  methods DEFAULT_FOR_CREATE
    changing
      !CS_ENTITY type ZJL_CL_TASK_BO=>TP_ENTITY .
  methods PRECHECK_CREATE
    importing
      !IS_ENTITY type ZJL_CL_TASK_BO=>TP_ENTITY
    exporting
      !ET_MESSAGE type ZJL_IF_RAP=>TPT_MESSAGE .
  methods PRECHECK_UPDATE
    importing
      !IS_ENTITY type ZJL_CL_TASK_BO=>TP_ENTITY
    exporting
      !ET_MESSAGE type ZJL_IF_RAP=>TPT_MESSAGE .
  methods MAP_TO_ENTITY
    importing
      !IS_DB type ZJL_CL_TASK_DA=>TP_DB
    changing
      !CS_ENTITY type ZJL_CL_TASK_BO=>TP_ENTITY .
  methods MAP_TO_DB
    importing
      !IS_ENTITY type ZJL_CL_TASK_BO=>TP_ENTITY
    changing
      !CS_DB type ZJL_CL_TASK_DA=>TP_DB .
endinterface.
