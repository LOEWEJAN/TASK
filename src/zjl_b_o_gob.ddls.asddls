@EndUserText.label: 'JL: Basis View auf Tabelle (GOB)'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@AbapCatalog.extensibility.extensible: true
@Metadata.allowExtensions: true

define view entity ZJL_B_O_GOB
  as select from zjl_gobo

  association [0..*] to ZJL_B_T_BO as _BusinessObjTX on _BusinessObjTX.code = $projection.BusinessObjCD

{

  key businessobj_cd as BusinessObjCD,
      _BusinessObjTX,

  key businessobj_id as BusinessObjID

}
