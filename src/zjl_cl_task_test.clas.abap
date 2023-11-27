CLASS zjl_cl_task_test DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS test_01.


  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zjl_cl_task_test IMPLEMENTATION.

  METHOD test_01.

    DATA: lt_data TYPE TABLE OF zjl_o_d_task.

    DATA: lt_eml_read        TYPE TABLE    FOR READ IMPORT   zjl_o_d_task.
    DATA: lt_eml_result      TYPE TABLE    FOR READ RESULT   zjl_o_d_task.
    DATA: lt_eml_reported    TYPE RESPONSE FOR REPORTED      zjl_o_d_task.
    DATA: lt_eml_failed      TYPE RESPONSE FOR FAILED        zjl_o_d_task.
    DATA: lt_eml_mapped      TYPE RESPONSE FOR MAPPED        zjl_o_d_task.
    DATA: lt_eml_create      TYPE TABLE    FOR CREATE        zjl_o_d_task.
    DATA: lt_eml_update      TYPE TABLE    FOR UPDATE        zjl_o_d_task.
    DATA: lt_eml_delete      TYPE TABLE    FOR DELETE        zjl_o_d_task.
    DATA: lt_eml_act_forward TYPE TABLE    FOR ACTION IMPORT zjl_o_d_task~forward.

    SELECT * FROM zjl_o_d_task INTO TABLE @lt_data.

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<ls_data>).

      READ ENTITIES OF zjl_o_d_task
      ENTITY task ALL FIELDS WITH lt_eml_read
      RESULT   lt_eml_result
      FAILED   lt_eml_failed
      REPORTED lt_eml_reported.

    ENDLOOP.

    MODIFY ENTITIES OF zjl_o_d_task
    ENTITY task CREATE SET FIELDS WITH lt_eml_create
          MAPPED   lt_eml_mapped
          FAILED   lt_eml_failed
          REPORTED lt_eml_reported.

    MODIFY ENTITIES OF zjl_o_d_task
    ENTITY task UPDATE SET FIELDS WITH lt_eml_update
          MAPPED   lt_eml_mapped
          FAILED   lt_eml_failed
          REPORTED lt_eml_reported.

    MODIFY ENTITIES OF zjl_o_d_task
    ENTITY task DELETE FROM lt_eml_delete
          MAPPED   lt_eml_mapped
          FAILED   lt_eml_failed
          REPORTED lt_eml_reported.

    MODIFY ENTITIES OF zjl_o_d_task
    ENTITY task EXECUTE forward FROM lt_eml_act_forward
          MAPPED   lt_eml_mapped
          FAILED   lt_eml_failed
          REPORTED lt_eml_reported.

    COMMIT ENTITIES.

  ENDMETHOD.

ENDCLASS.
