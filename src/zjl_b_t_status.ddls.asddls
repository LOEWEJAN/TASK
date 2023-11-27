@EndUserText.label: 'JL: Basis View auf Texte (STATUS)'
@ObjectModel.dataCategory: #TEXT
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
@VDM.viewType: #BASIC

define view entity ZJL_B_T_STATUS

  as select distinct from dd07t
{

      @Semantics.language: true
  key ddlanguage as LanguageCD,

      @Search.defaultSearchElement: true
  key domvalue_l as code,

      @Semantics.text: true
      @EndUserText.label: 'Aufgabenstatus - Kurztext'
      @UI.hidden: false
      ddtext     as Short,

      @Semantics.text: false
      @EndUserText.label: 'Aufgabenstatus - Langtext'
      @UI.hidden: true
      ddtext     as Large
}
where
      domname  = 'ZJL_STATUS'
  and as4local = 'A'
  and as4vers  = '0000'
