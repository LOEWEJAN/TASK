@EndUserText.label: 'JL: Customizing "Empfänger"'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
@Metadata.allowExtensions: true

define root view entity ZJL_C_A_RECIPIENT
  provider contract transactional_query
  as projection on ZJL_O_D_RECIPIENT
{

      @ObjectModel.text.element: ['RecipientGroupTX']
  key RecipientGroupCD,

      @ObjectModel.text.element: ['RecipientTX']
  key RecipientCD,

      _RecipientGroupTX.Short as RecipientGroupTX : localized,
      _RecipientTX.Short      as RecipientTX      : localized,

      VersEtagTS,

      CreateUserCD,
      CreateTS,
      ChangeUserCD,
      ChangeTS,

      DeleteFl

}
