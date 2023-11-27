@EndUserText.label: 'JL: Composite View auf Anlage'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@AbapCatalog.extensibility.extensible: true
@Metadata.allowExtensions: true

define view entity ZJL_O_D_ATTACHMENT
  as select from ZJL_B_O_ATA

  association to parent ZJL_O_D_TASK as _Task on  $projection.TaskID = _Task.TaskId
                                              and $projection.VersNO = _Task.VersNO

{

  key TaskID,
  key VersNO,
  key AtacNO,
      CreateUserCD,
      CreateTS,
      ChangeUserCD,
      ChangeTS,
      Mimetype,
      Filename,
      FileDescr,
      Attachment,

      /* Associations */
      _ChangeUserTX,
      _CreateUserTX,

      _Task

}
