class ZJL_CL_TASK_BADI_DEFAULT definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces ZJL_IF_TASK_BADI .
protected section.
private section.
ENDCLASS.



CLASS ZJL_CL_TASK_BADI_DEFAULT IMPLEMENTATION.


  method ZJL_IF_TASK_BADI~CHECK.
  endmethod.


  METHOD zjl_if_task_badi~default_for_create.

  ENDMETHOD.


  method ZJL_IF_TASK_BADI~DETERMINE.
  endmethod.


  method ZJL_IF_TASK_BADI~GET_GLOBAL_FEATURES.
  endmethod.


  method ZJL_IF_TASK_BADI~GET_INSTANCE_AUTHORIZATIONS.
  endmethod.


  method ZJL_IF_TASK_BADI~GET_INSTANCE_FEATURES.
  endmethod.


  method ZJL_IF_TASK_BADI~MAP_TO_DB.
  endmethod.


  method ZJL_IF_TASK_BADI~MAP_TO_ENTITY.
  endmethod.


  method ZJL_IF_TASK_BADI~PRECHECK_CREATE.
  endmethod.


  method ZJL_IF_TASK_BADI~PRECHECK_UPDATE.
  endmethod.
ENDCLASS.
