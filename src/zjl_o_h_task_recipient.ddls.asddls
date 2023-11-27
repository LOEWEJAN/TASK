@EndUserText.label: 'Aufgabe verwalten - Popup 1'

define abstract entity ZJL_O_H_TASK_RECIPIENT
{

  @Consumption.valueHelpDefinition: [{ entity: {name: 'ZJL_B_V_UNAME' , element: 'code' }}]
  @EndUserText.label: 'Empfänger'
  RecipientCD      : syuname;

  @Consumption.valueHelpDefinition: [{ entity: {name: 'ZJL_B_V_GROUP' , element: 'code' }}]
  @EndUserText.label: 'Empfängergruppe'
  RecipientGroupCD : zjl_group;

}
