@EndUserText.label: 'JL: Meine Aufgabe'
@VDM.viewType: #COMPOSITE
@AccessControl.authorizationCheck: #NOT_REQUIRED

define table function ZJL_O_H_TASK_MY

  with parameters
    @Environment.systemField : #USER
    p_uname : syuname

returns
{
  ClientCD : abap.clnt;
  TaskID   : zjl_id;
  VersNO   : zjl_version;  

  @EndUserText.label: 'Mein Objekt'
  MyTaskFL : zjl_boolean;

}

implemented by method
  zjl_cl_task_amdp=>get_task_my;
