@EndUserText.label: 'JL: Aufgabe'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
@Metadata.allowExtensions: true

define root view entity ZJL_C_A_TASK
  provider contract transactional_query
  as projection on ZJL_O_D_TASK

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

      @ObjectModel.text.element: ['ProcessTX']
      ProcessCD,

      _ProcessTX.Short        as ProcessTX        : localized,

      @ObjectModel.text.element: ['StatusTX']
      StatusCD,

      _StatusTX.Short         as StatusTX         : localized,

      @ObjectModel.text.element: ['BusinessObjTX']
      BusinessObjCD,

      _BusinessObjTX.Short    as BusinessObjTX    : localized,

      BusinessObjID,

      @ObjectModel.text.element: ['RecipientTX']
      RecipientCD,

      _RecipientTX.Short      as RecipientTX      : localized,

      @ObjectModel.text.element: ['RecipientGroupTX']
      RecipientGroupCD,

      _RecipientGroupTX.Short as RecipientGroupTX : localized,

      CompletedFL,
      ReSubmissDT,
      TargetDT,
      Descr,
      Note,
      MyTaskFL,

      CalcCriticality,

      //* Associations */
      _ProcessTX,
      _BusinessObjTX,
      _RecipientGroupTX,
      _RecipientTX,
      _StatusTX,
      
      _HIS,

      _Attachment : redirected to composition child ZJL_C_A_ATTACHMENT
}
