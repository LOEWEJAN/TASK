@EndUserText.label: 'JL: Basis View auf Werte (UNAME)'
@ObjectModel.dataCategory: #VALUE_HELP
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
@VDM.viewType: #BASIC

define view entity ZJL_B_V_GOBO
  as select distinct from ZJL_B_O_GOB

{

      @Search.defaultSearchElement: true
      @UI.hidden: false
  key BusinessObjCD,

      @Search.defaultSearchElement: true
      @UI.hidden: false
  key BusinessObjID

}
