@EndUserText.label: 'JL: Basis View auf Tabelle (ATA)'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@AbapCatalog.extensibility.extensible: true
@Metadata.allowExtensions: true

define view entity ZJL_B_O_ATA
  as select from zjl_atao


  association [0..*] to ZJL_B_T_UNAME as _CreateUserTX on _CreateUserTX.code = $projection.CreateUserCD

  association [0..*] to ZJL_B_T_UNAME as _ChangeUserTX on _ChangeUserTX.code = $projection.ChangeUserCD

{

      @EndUserText.label: 'Aufgabe'
  key task_id        as TaskID,

      @EndUserText.label: 'Version'
  key vers_no        as VersNO,

      @EndUserText.label: 'Anlage'
  key atac_no        as AtacNO,
      
      @EndUserText.label: 'Anlagebenutzer'
      @ObjectModel.text.association: '_CreateUserTX'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZJL_B_V_UNAME', element: 'code' } }]
      create_user_cd as CreateUserCD,
      _CreateUserTX,

      @EndUserText.label: 'Anlagezeitpunkt'
      create_ts      as CreateTS,

      @EndUserText.label: 'Änderungsbenutzer'
      @ObjectModel.text.association: '_ChangeUserTX'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZJL_B_V_UNAME', element: 'code' } }]
      change_user_cd as ChangeUserCD,
      _ChangeUserTX,

      @EndUserText.label: 'Änderungszeitpunkt'
      change_ts      as ChangeTS,

      @EndUserText.label: 'Mime Type'
      @Semantics.mimeType: true
      mimetype       as Mimetype,

      @EndUserText.label: 'Dateiname'
      filename       as Filename,

      @EndUserText.label: 'Beschreibung'
      file_descr     as FileDescr,

      @EndUserText.label: 'Datei'
      @Semantics.largeObject: { mimeType: 'Mimetype', fileName: 'Filename', contentDispositionPreference: #INLINE }
      attachment     as Attachment

}
