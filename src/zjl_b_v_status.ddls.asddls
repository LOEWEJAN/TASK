@EndUserText.label: 'JL: Basis View auf Werte (STATUS)'
@ObjectModel.dataCategory: #VALUE_HELP
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
@VDM.viewType: #BASIC

define view entity ZJL_B_V_STATUS
  as select from ZJL_B_T_STATUS as TXT

{

  key TXT.code,

      @EndUserText.label: 'Kurztext'
      @UI.hidden: false
      TXT.Short,

      @EndUserText.label: 'Langtext'
      TXT.Large

}
