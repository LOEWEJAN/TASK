@EndUserText.label: 'JL: Basis View auf Tabelle (TAK)'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@AbapCatalog.extensibility.extensible: true
@Metadata.allowExtensions: true

define view entity ZJL_B_O_TAK
  as select from zjl_tako

  association [0..*] to ZJL_B_T_STATUS  as _StatusTX         on _StatusTX.code = $projection.StatusCD

  association [0..*] to ZJL_B_T_GROUP   as _RecipientGroupTX on _RecipientGroupTX.code = $projection.RecipientGroupCD

  association [0..*] to ZJL_B_T_PROCESS as _ProcessTX        on _ProcessTX.code = $projection.ProcessCD

  association [0..*] to ZJL_B_T_BO as _BusinessObjTX        on _BusinessObjTX.code = $projection.BusinessObjCD
  
  association [0..*] to ZJL_B_T_UNAME   as _CreateUserTX     on _CreateUserTX.code = $projection.CreateUserCD

  association [0..*] to ZJL_B_T_UNAME   as _ChangeUserTX     on _ChangeUserTX.code = $projection.ChangeUserCD

  association [0..*] to ZJL_B_T_UNAME   as _ReleaseUserTX    on _ReleaseUserTX.code = $projection.ReleaseUserCD

  association [0..*] to ZJL_B_T_UNAME   as _RecipientTX      on _RecipientTX.code = $projection.RecipientCD

{

      @EndUserText.label: 'Aufgabe'
  key task_id            as TaskId,

      @EndUserText.label: 'Version'
  key vers_no            as VersNO,

      @EndUserText.label: 'Gültig-von'
      vers_from_dt       as VersFromDT,

      @EndUserText.label: 'Gültig-bis'
      vers_to_dt         as VersToDT,

      @EndUserText.label: 'Gültig'
      vers_inactive_fl   as VersInactiveFL,

      @EndUserText.label: 'ETAG'
      vers_etag_ts       as VersEtagTS,

      @EndUserText.label: 'Usprungsversion'
      vers_origin_no     as VersOriginNO,

      @EndUserText.label: 'Anlagebenutzer'
      @ObjectModel.text.association: '_CreateUserTX'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZJL_B_V_UNAME', element: 'code' } }]
      create_user_cd     as CreateUserCD,
      _CreateUserTX,

      @EndUserText.label: 'Anlagezeitpunkt'
      create_ts          as CreateTS,

      @EndUserText.label: 'Änderungsbenutzer'
      @ObjectModel.text.association: '_ChangeUserTX'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZJL_B_V_UNAME', element: 'code' } }]
      change_user_cd     as ChangeUserCD,
      _ChangeUserTX,

      @EndUserText.label: 'Änderungszeitpunkt'
      change_ts          as ChangeTS,

      @EndUserText.label: 'Freigabebenutzer'
      @ObjectModel.text.association: '_ReleaseUserTX'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZJL_B_V_UNAME', element: 'code' } }]
      release_user_cd    as ReleaseUserCD,
      _ReleaseUserTX,

      @EndUserText.label: 'Freigabezeitpunkt'
      release_ts         as ReleaseTS,

      @ObjectModel.text.association: '_ProcessTX'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZJL_B_V_PROCESS', element: 'code' } }]
      process_cd         as ProcessCD,
      _ProcessTX,

      @EndUserText.label: 'Bearbeitungsstatus'
      @ObjectModel.text.association: '_StatusTX'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZJL_B_V_STATUS', element: 'code' } }]
      status_cd          as StatusCD,
      _StatusTX,

      @ObjectModel.text.association: '_BusinessObjTX'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZJL_B_V_BO', element: 'code' } }]      
      businessobj_cd     as BusinessObjCD,
      _BusinessObjTX,

      @EndUserText.label: 'Geschäftsobjekt ID'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZJL_B_O_GOB', element: 'BusinessObjID' } }]           
      businessobj_id     as BusinessObjID,

      @EndUserText.label: 'Empfänger'
      @ObjectModel.text.association: '_RecipientTX'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZJL_B_V_UNAME', element: 'code' } }]
      recipient_cd       as RecipientCD,
      _RecipientTX,

      @EndUserText.label: 'Empfängergruppe'
      @ObjectModel.text.association: '_RecipientGroupTX'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZJL_B_V_GROUP', element: 'code' } }]
      recipient_group_cd as RecipientGroupCD,
      _RecipientGroupTX,

      @EndUserText.label: 'Wiedervorlagedatum'
      resubmiss_dt       as ReSubmissDT,

      @EndUserText.label: 'Zieldatum'
      target_dt          as TargetDT,

      @EndUserText.label: 'Erledigt'
      completed_fl       as CompletedFL,

      @EndUserText.label: 'Beschreibung'
      descr              as Descr,

      @EndUserText.label: 'Notiz'
      note               as Note

}
