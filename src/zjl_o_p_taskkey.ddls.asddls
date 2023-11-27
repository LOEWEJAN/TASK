@EndUserText.label: 'JL: Comp View auf Aufgabe'
@VDM.viewType: #COMPOSITE
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ClientHandling.type: #CLIENT_DEPENDENT
@ClientHandling.algorithm: #SESSION_VARIABLE

define table function ZJL_O_P_TASKKEY

  with parameters
    @Environment.systemField: #CLIENT
    p_client  : abap.clnt,
    @Environment.systemField : #SYSTEM_DATE
    p_ValidDT : abap.dats

returns
{

  ClientCD : abap.clnt;
  TaskID   : zjl_id;
  VersNO   : zjl_version;

}
implemented by method
  ZJL_CL_VT_AMDP=>GET_FUNC_TASKKEY;
