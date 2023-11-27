@EndUserText.label: 'JL: Basis View auf Tabelle (REC)'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@AbapCatalog.extensibility.extensible: true
@Metadata.allowExtensions: true

define view entity ZJL_B_O_REC
  as select from zjl_reco

  association [0..*] to ZJL_B_T_GROUP  as _RecipientGroupTX on _RecipientGroupTX.code = $projection.RecipientGroupCD
  association [0..*] to ZJL_B_T_UNAME  as _RecipientTX      on _RecipientTX.code = $projection.RecipientCD
  association [0..*] to ZJL_B_T_UNAME  as _CreateUserTX     on _CreateUserTX.code = $projection.CreateUserCD
  association [0..*] to ZJL_B_T_UNAME  as _ChangeUserTX     on _ChangeUserTX.code = $projection.ChangeUserCD
  association [0..*] to ZJL_B_T_XFIELD as _DeleteTX         on _DeleteTX.code = $projection.DeleteFl

{

      @EndUserText.label: 'Empfängergruppe'
      @ObjectModel.text.association: '_RecipientGroupTX'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZJL_B_V_GROUP', element: 'code' } }]
  key zjl_reco.recipient_group_cd as RecipientGroupCD,
      _RecipientGroupTX,

      @EndUserText.label: 'Empfänger'
      @ObjectModel.text.association: '_RecipientTX'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZJL_B_V_UNAME', element: 'code' } }]
  key zjl_reco.recipient_cd       as RecipientCD,
      _RecipientTX,

      @EndUserText.label: 'ETAG'
      vers_etag_ts                as VersEtagTS,

      @EndUserText.label: 'Anlagebenutzer'
      @ObjectModel.text.association: '_CreateUserTX'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZJL_B_V_UNAME', element: 'code' } }]
      zjl_reco.create_user_cd     as CreateUserCD,
      _CreateUserTX,

      @EndUserText.label: 'Anlagezeitpunkt'
      zjl_reco.create_ts          as CreateTS,

      @EndUserText.label: 'Änderungsbenutzer'
      @ObjectModel.text.association: '_ChangeUserTX'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZJL_B_V_UNAME', element: 'code' } }]
      zjl_reco.change_user_cd     as ChangeUserCD,
      _ChangeUserTX,

      @EndUserText.label: 'Änderungszeitpunkt'
      zjl_reco.change_ts          as ChangeTS,

      @ObjectModel.text.association: '_ChangeUserTX'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZJL_B_V_XFIELD', element: 'code' } }]
      @EndUserText.label: 'Löschkennzeichen'
      zjl_reco.delete_fl          as DeleteFl,
      _DeleteTX

}
