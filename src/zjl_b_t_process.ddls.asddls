@EndUserText.label: 'JL: Basis View auf Texte (PROCESS)'
@ObjectModel.dataCategory: #TEXT
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
@VDM.viewType: #BASIC

define view entity ZJL_B_T_PROCESS

  as select distinct from dd07t
{

      @Semantics.language: true
  key ddlanguage as LanguageCD,

      @Search.defaultSearchElement: true
  key domvalue_l as code,

      @Semantics.text: true
      @EndUserText.label: 'Vorgang - Kurztext'
      @UI.hidden: true
      ddtext     as Short,

      @Semantics.text: true
      @EndUserText.label: 'Vorgang - Langtext'
      @UI.hidden: true
      ddtext     as Large
}
where
      domname  = 'ZJL_PROCESS'
  and as4local = 'A'
  and as4vers  = '0000'
