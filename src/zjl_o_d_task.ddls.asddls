@EndUserText.label: 'JL: Composite View auf Aufgabe'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@AbapCatalog.extensibility.extensible: true
@Metadata.allowExtensions: true

define root view entity ZJL_O_D_TASK
  as select from           ZJL_O_P_TASKKEY( p_client: $session.client, p_ValidDT: $session.system_date ) as KEYS

    left outer to one join ZJL_B_O_TAK                                                                   as DATA on  DATA.TaskId = KEYS.TaskID
                                                                                                                 and DATA.VersNO = KEYS.VersNO

    left outer to one join ZJL_O_H_TASK_MY( p_uname: $session.user )                                     as USER on  USER.TaskID = KEYS.TaskID
                                                                                                                 and USER.VersNO = KEYS.VersNO

  association [1..*] to ZJL_O_D_TASKVERS   as _HIS on _HIS.TaskId = DATA.TaskId

  composition [0..*] of ZJL_O_D_ATTACHMENT as _Attachment

{
  key DATA.TaskId,
  key DATA.VersNO,

      DATA.VersFromDT,
      DATA.VersToDT,
      DATA.VersInactiveFL,
      DATA.VersEtagTS,
      DATA.VersOriginNO,

      DATA.CreateUserCD,
      DATA.CreateTS,
      DATA.ChangeUserCD,
      DATA.ChangeTS,
      DATA.ReleaseUserCD,
      DATA.ReleaseTS,

      DATA.StatusCD,
      DATA.ProcessCD,

      DATA.BusinessObjCD,
      DATA.BusinessObjID,
      DATA.RecipientCD,
      DATA.RecipientGroupCD,
      DATA.ReSubmissDT,
      DATA.TargetDT,
      DATA.CompletedFL,
      DATA.Descr,
      DATA.Note,

      USER.MyTaskFL,

      case
      when DATA.ReSubmissDT < $session.system_date and DATA.CompletedFL <> 'X' then 1
      when DATA.ReSubmissDT = $session.system_date and DATA.CompletedFL <> 'X' then 2
      when DATA.ReSubmissDT > $session.system_date and DATA.CompletedFL <> 'X' then 3
      else 0
      end as CalcCriticality,

      /* Associations */
      DATA._ChangeUserTX,
      DATA._CreateUserTX,
      DATA._ProcessTX,
      DATA._BusinessObjTX,
      DATA._RecipientGroupTX,
      DATA._RecipientTX,
      DATA._StatusTX,

      _Attachment,
      _HIS

}
