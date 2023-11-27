@EndUserText.label: 'Aufgabe verwalten - Popup 2'

define abstract entity ZJL_O_H_TASK_BUSINESSOBJ
{
  @Consumption.valueHelpDefinition: [{ entity: {name: 'ZJL_B_V_GOBO', element: 'BusinessObjCD' },
                                       additionalBinding: [{ element: 'BusinessObjID', localElement: 'BusinessObjID' }]} ]
  BusinessObjCD : zjl_bo;

  @Consumption.valueHelpDefinition: [{ entity: {name: 'ZJL_B_V_GOBO', element: 'BusinessObjID' },
                                       additionalBinding: [{ element: 'BusinessObjCD', localElement: 'BusinessObjCD' }]} ]
  BusinessObjID : zjl_id;
}
