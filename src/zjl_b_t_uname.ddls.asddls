@EndUserText.label: 'JL: Basis View auf Texte (UNAME)'
@ObjectModel.dataCategory: #TEXT
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
@VDM.viewType: #BASIC

define view entity ZJL_B_T_UNAME

  as select distinct from usr21
    inner join            adrp on adrp.persnumber = usr21.persnumber

{

      @Semantics.language: true
  key $session.system_language as LanguageCD,

      @Search.defaultSearchElement: true
  key usr21.bname              as code,

      @Semantics.text: true
      @EndUserText.label: 'Parameterwert - Kurztext'
      @UI.hidden: true
      adrp.name_last           as Short,

      @Semantics.text: true
      @EndUserText.label: 'Parameterwert - Langtext'
      @UI.hidden: true
      adrp.name_text           as Large
}
