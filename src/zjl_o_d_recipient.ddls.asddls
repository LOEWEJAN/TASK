@EndUserText.label: 'JL: Composite View auf Empfänger'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@AbapCatalog.extensibility.extensible: true
@Metadata.allowExtensions: true

define root view entity ZJL_O_D_RECIPIENT
  as select from ZJL_B_O_REC

{

  key RecipientGroupCD,
  key RecipientCD,

      VersEtagTS,

      CreateUserCD,
      CreateTS,
      ChangeUserCD,
      ChangeTS,

      DeleteFl,

      /* Associations */
      _ChangeUserTX,
      _CreateUserTX,
      _RecipientGroupTX,
      _RecipientTX

}
