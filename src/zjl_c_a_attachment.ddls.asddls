@EndUserText.label: 'JL: Anlage'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
@Metadata.allowExtensions: true

define view entity ZJL_C_A_ATTACHMENT
  as projection on ZJL_O_D_ATTACHMENT

{

  key TaskID,
  key VersNO,
  key AtacNO,
      CreateUserCD,
      CreateTS,
      ChangeUserCD,
      ChangeTS,
      Mimetype,
      @Search.defaultSearchElement: true
      Filename,
      @Search.defaultSearchElement: true
      FileDescr,
      Attachment,

      /* Associations */
      _Task : redirected to parent ZJL_C_A_TASK

}
