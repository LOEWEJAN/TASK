@EndUserText.label: 'JL: Composite View auf Versionen'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@AbapCatalog.extensibility.extensible: true
@Metadata.allowExtensions: true

define root view entity ZJL_O_D_TASKVERS
  as select from ZJL_B_O_TAK

{

  key TaskId,
  key VersNO,
      VersFromDT,
      VersToDT,
      VersInactiveFL,
      VersEtagTS,
      VersOriginNO,
      CreateUserCD,
      CreateTS,
      ChangeUserCD,
      ChangeTS,
      ReleaseUserCD,
      ReleaseTS,
      ProcessCD,
      StatusCD,
      BusinessObjCD,
      BusinessObjID,
      RecipientCD,
      RecipientGroupCD,
      ReSubmissDT,
      TargetDT,
      CompletedFL,
      Descr,
      Note,

      /* Associations */
      _BusinessObjTX,
      _ChangeUserTX,
      _CreateUserTX,
      _ProcessTX,
      _RecipientGroupTX,
      _RecipientTX,
      _ReleaseUserTX,
      _StatusTX

}
