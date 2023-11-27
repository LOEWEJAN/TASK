@EndUserText.label: 'JL: Basis View auf Texte (BO)'
@ObjectModel.dataCategory: #TEXT
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
@VDM.viewType: #BASIC

define view entity ZJL_B_T_BO

  as select from dd07t
{

      @Semantics.language: true
  key ddlanguage as LanguageCD,

      @Search.defaultSearchElement: true
  key domvalue_l as code,

      @Semantics.text: true
      @EndUserText.label: 'Geschäftsobjekt - Kurztext'
      @UI.hidden: true
      ddtext     as Short,

      @Semantics.text: true
      @EndUserText.label: 'Geschäftsobjekt - Langtext'
      @UI.hidden: true
      ddtext     as Large
}
where
      domname  = 'ZJL_BO'
  and as4local = 'A'
  and as4vers  = '0000'
