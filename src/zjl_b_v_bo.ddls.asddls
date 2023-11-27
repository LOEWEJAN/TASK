@EndUserText.label: 'JL: Basis View auf Werte (BO)'
@ObjectModel.dataCategory: #VALUE_HELP
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
@VDM.viewType: #BASIC

define view entity ZJL_B_V_BO
  as select from ZJL_B_T_BO as TXT

{

  key TXT.code,

      @EndUserText.label: 'Kurztext'
      @UI.hidden: false
      TXT.Short,

      @EndUserText.label: 'Langtext'
      TXT.Large

}
