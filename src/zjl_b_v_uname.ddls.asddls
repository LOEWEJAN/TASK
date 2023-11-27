@EndUserText.label: 'JL: Basis View auf Werte (UNAME)'
@ObjectModel.dataCategory: #VALUE_HELP
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
@VDM.viewType: #BASIC

/*+[hideWarning] { "IDS" : [ "KEY_CHECK" ]  } */
define view entity ZJL_B_V_UNAME
  as select distinct from ZJL_B_T_UNAME as TXT

{

  key TXT.code,

      @EndUserText.label: 'Kurztext'
      @UI.hidden: false
      TXT.Short,

      @EndUserText.label: 'Langtext'
      TXT.Large

}
