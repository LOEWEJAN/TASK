CLASS lhc_task DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR task RESULT result.

    METHODS get_global_features FOR GLOBAL FEATURES
      IMPORTING REQUEST requested_features FOR task RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR task RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR task RESULT result.

    METHODS precheck_create FOR PRECHECK
      IMPORTING entities FOR CREATE task.

    METHODS defaultforcreate FOR READ
      IMPORTING keys FOR FUNCTION task~defaultforcreate RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE task.

    METHODS read FOR READ
      IMPORTING keys FOR READ task RESULT result.

    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE task.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE task.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE task.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK task.

    METHODS complete FOR MODIFY
      IMPORTING keys FOR ACTION task~complete.

    METHODS refuse FOR MODIFY
      IMPORTING keys FOR ACTION task~refuse.

    METHODS forward FOR MODIFY
      IMPORTING keys FOR ACTION task~forward.

    METHODS assign FOR MODIFY
      IMPORTING keys FOR ACTION task~assign.

    METHODS rba_attachment FOR READ
      IMPORTING keys_rba FOR READ task\_attachment FULL result_requested RESULT result LINK association_links.

    METHODS cba_attachment FOR MODIFY
      IMPORTING entities_cba FOR CREATE task\_attachment.

    METHODS map_with_control
      IMPORTING is_entity  TYPE zjl_cl_task_bo=>tp_entity
                is_control TYPE any
      CHANGING  cs_entity  TYPE zjl_cl_task_bo=>tp_entity.

ENDCLASS.

CLASS lhc_task IMPLEMENTATION.

  METHOD get_instance_features.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_keys>).

      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<ls_result>).
      <ls_result>-%key = <ls_keys>-%key.
      IF requested_features-%update EQ if_abap_behv=>mk-on.
        <ls_result>-%features-%update = zjl_cl_task_bo=>get_instance( )->get_instance_features( EXPORTING i_taskid  = <ls_keys>-%key-taskid
                                                                                                          i_versno  = <ls_keys>-%key-versno
                                                                                                          i_feature = zjl_if_rap=>co_feature_update ).
      ENDIF.
      IF requested_features-%delete EQ if_abap_behv=>mk-on.
        <ls_result>-%features-%delete = zjl_cl_task_bo=>get_instance( )->get_instance_features( EXPORTING i_taskid  = <ls_keys>-%key-taskid
                                                                                                          i_versno  = <ls_keys>-%key-versno
                                                                                                          i_feature = zjl_if_rap=>co_feature_delete ).
      ENDIF.
      IF requested_features-%assoc-_attachment EQ if_abap_behv=>mk-on.
        <ls_result>-%features-%assoc-_attachment = zjl_cl_task_bo=>get_instance( )->get_instance_features( EXPORTING i_taskid  = <ls_keys>-%key-taskid
                                                                                                                         i_versno  = <ls_keys>-%key-versno
                                                                                                                         i_feature = zjl_cl_task_bo=>co_feature_assoc_attach ).
      ENDIF.
      IF requested_features-%action-refuse EQ if_abap_behv=>mk-on.
        <ls_result>-%features-%action-refuse = zjl_cl_task_bo=>get_instance( )->get_instance_features( EXPORTING i_taskid  = <ls_keys>-%key-taskid
                                                                                                          i_versno  = <ls_keys>-%key-versno
                                                                                                          i_feature = zjl_cl_task_bo=>co_feature_refuse ).
      ENDIF.
      IF requested_features-%action-assign EQ if_abap_behv=>mk-on.
        <ls_result>-%features-%action-assign = zjl_cl_task_bo=>get_instance( )->get_instance_features( EXPORTING i_taskid  = <ls_keys>-%key-taskid
                                                                                                          i_versno  = <ls_keys>-%key-versno
                                                                                                          i_feature = zjl_cl_task_bo=>co_feature_assign ).
      ENDIF.
      IF requested_features-%action-complete EQ if_abap_behv=>mk-on.
        <ls_result>-%features-%action-complete = zjl_cl_task_bo=>get_instance( )->get_instance_features( EXPORTING i_taskid  = <ls_keys>-%key-taskid
                                                                                                          i_versno  = <ls_keys>-%key-versno
                                                                                                          i_feature = zjl_cl_task_bo=>co_feature_complete ).
      ENDIF.
      IF requested_features-%action-forward EQ if_abap_behv=>mk-on.
        <ls_result>-%features-%action-forward = zjl_cl_task_bo=>get_instance( )->get_instance_features( EXPORTING i_taskid  = <ls_keys>-%key-taskid
                                                                                                          i_versno  = <ls_keys>-%key-versno
                                                                                                          i_feature = zjl_cl_task_bo=>co_feature_forward ).
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD create.

    DATA ls_entity_in  TYPE zjl_cl_task_bo=>tp_entity.
    DATA ls_entity_out TYPE zjl_cl_task_bo=>tp_entity.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entity>).

      MOVE-CORRESPONDING <ls_entity> TO ls_entity_in.

      zjl_cl_task_bo=>get_instance( )->create( EXPORTING is_entity  = ls_entity_in
                                               IMPORTING es_entity  = ls_entity_out
                                                         et_message = DATA(lt_message) ).

      IF NOT lt_message IS INITIAL.
        zjl_cl_task_bo=>handle_messages( EXPORTING i_cid      = <ls_entity>-%cid
                                                   i_taskid   = <ls_entity>-%key-taskid
                                                   i_versno   = <ls_entity>-%key-versno
                                                   it_message = lt_message
                                          CHANGING failed     = failed-task
                                                   reported   = reported-task ).
      ELSE.
        APPEND INITIAL LINE TO mapped-task ASSIGNING FIELD-SYMBOL(<ls_mapped>).
        <ls_mapped>-%cid = <ls_entity>-%cid.
        <ls_mapped>-%key = <ls_entity>-%key.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD update.

    DATA: ls_entity TYPE zjl_cl_task_bo=>tp_entity.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entity>).

      zjl_cl_task_bo=>get_instance( )->read( EXPORTING i_taskid  = <ls_entity>-%key-taskid
                                                       i_versno  = <ls_entity>-%key-versno
                                             IMPORTING es_entity  = DATA(ls_entity_in)
                                                       et_message = DATA(lt_message) ).

      MOVE-CORRESPONDING <ls_entity> TO ls_entity.

      map_with_control( EXPORTING is_entity  = ls_entity
                                  is_control = <ls_entity>-%control
                        CHANGING  cs_entity  =  ls_entity_in ).

      zjl_cl_task_bo=>get_instance( )->update( EXPORTING is_entity  = ls_entity_in
                                               IMPORTING es_entity  = DATA(ls_etity_out)
                                                         et_message = lt_message ).

      IF NOT lt_message IS INITIAL.
        zjl_cl_attach_bo=>handle_messages( EXPORTING i_cid      = <ls_entity>-%cid_ref
        i_taskid  = <ls_entity>-%key-taskid
        i_versno  = <ls_entity>-%key-versno
        it_message = lt_message
        CHANGING failed     = failed-attachment
        reported   = reported-attachment ).
      ELSE.
        APPEND INITIAL LINE TO mapped-task ASSIGNING FIELD-SYMBOL(<ls_mapped>).
        <ls_mapped>-%cid = <ls_entity>-%cid_ref.
        <ls_mapped>-%key = <ls_entity>-%key.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD delete.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      zjl_cl_task_bo=>get_instance( )->delete( EXPORTING i_taskid  = <ls_key>-%key-taskid
      i_versno  = <ls_key>-%key-versno
      IMPORTING et_message = DATA(lt_message) ).

      IF NOT lt_message IS INITIAL.
        zjl_cl_task_bo=>handle_messages( EXPORTING i_cid      = space
        i_taskid  = <ls_key>-%key-taskid
        i_versno  = <ls_key>-%key-versno
        it_message = lt_message
        CHANGING failed     = failed-task
        reported   = reported-task ).
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD read.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      zjl_cl_task_bo=>get_instance( )->read( EXPORTING i_taskid  = <ls_key>-%key-taskid
      i_versno  = <ls_key>-%key-versno
      IMPORTING es_entity  = DATA(ls_entity)
      et_message = DATA(lt_message) ).

      IF NOT lt_message IS INITIAL.
        zjl_cl_attach_bo=>handle_messages( EXPORTING i_cid      = space
        i_taskid  = <ls_key>-%key-taskid
        i_versno  = <ls_key>-%key-versno
        it_message = lt_message
        CHANGING failed     = failed-attachment
        reported   = reported-attachment ).
      ELSE.
        APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<ls_result>).
        MOVE-CORRESPONDING ls_entity TO <ls_result>.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD lock.

    DATA: ls_entity TYPE zjl_cl_task_bo=>tp_entity.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      zjl_cl_task_bo=>get_instance( )->lock( EXPORTING i_taskid  = <ls_key>-taskid
                                             IMPORTING et_message = DATA(lt_message) ).

      IF NOT lt_message IS INITIAL.
        zjl_cl_task_bo=>handle_messages( EXPORTING i_cid      = space
                                                   i_taskid   = <ls_key>-taskid
                                                   i_versno   = <ls_key>-versno
                                                   it_message = lt_message
                                         CHANGING failed      = failed-task
                                                  reported    = reported-task ).
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD precheck_update.

    DATA: ls_entity TYPE zjl_cl_task_bo=>tp_entity.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entity>).

      zjl_cl_task_bo=>get_instance( )->read( EXPORTING i_taskid  = <ls_entity>-%key-taskid
                                                       i_versno  = <ls_entity>-%key-versno
                                             IMPORTING es_entity  = DATA(ls_entity_in)
                                                       et_message = DATA(lt_message) ).

      MOVE-CORRESPONDING <ls_entity> TO ls_entity.

      map_with_control( EXPORTING is_entity  = ls_entity
                                  is_control = <ls_entity>-%control
                        CHANGING  cs_entity  =  ls_entity_in ).

      IF lt_message IS INITIAL.
        lt_message = zjl_cl_task_bo=>get_instance( )->precheck_update( EXPORTING is_entity = ls_entity_in ).
      ENDIF.


      IF NOT lt_message IS INITIAL.
        zjl_cl_task_bo=>handle_messages( EXPORTING i_cid      = <ls_entity>-%cid_ref
                                                   i_taskid   = <ls_entity>-%key-taskid
                                                   i_versno   = <ls_entity>-%key-versno
                                                   it_message = lt_message
                                          CHANGING failed     = failed-task
                                                   reported   = reported-task ).
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_global_authorizations.

  ENDMETHOD.

  METHOD precheck_create.

    DATA ls_entity  TYPE zjl_cl_task_bo=>tp_entity.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entity>).

      MOVE-CORRESPONDING <ls_entity> TO ls_entity.

      map_with_control( EXPORTING is_entity  = ls_entity
                                  is_control = <ls_entity>-%control
                        CHANGING  cs_entity  =  ls_entity ).

      DATA(lt_message) = zjl_cl_task_bo=>get_instance( )->precheck_update( EXPORTING is_entity = ls_entity ).

      IF NOT lt_message IS INITIAL.
        zjl_cl_task_bo=>handle_messages( EXPORTING i_cid      = <ls_entity>-%cid
                                                   i_taskid   = <ls_entity>-%key-taskid
                                                   i_versno   = <ls_entity>-%key-versno
                                                   it_message = lt_message
                                          CHANGING failed     = failed-task
                                                   reported   = reported-task ).
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD defaultforcreate.

    DATA(ls_entity) = zjl_cl_task_bo=>get_instance( )->default_for_create( ).

    APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<ls_result>).
    <ls_result>-%cid = keys[ 1 ]-%cid.

    MOVE-CORRESPONDING ls_entity TO <ls_result>-%param.

  ENDMETHOD.

  METHOD assign.

    DATA: ls_entity        TYPE zjl_cl_task_bo=>tp_entity.
    DATA: lt_attach_read   TYPE TABLE FOR READ IMPORT zjl_o_d_task\_attachment.
    DATA: lt_attach_create TYPE TABLE FOR CREATE      zjl_o_d_task\_attachment.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      zjl_cl_task_bo=>get_instance( )->facact_assign( EXPORTING i_taskid        = <ls_key>-%key-taskid
                                                                i_versno        = <ls_key>-%key-versno
                                                                i_businessobjcd = <ls_key>-%param-businessobjcd
                                                                i_businessobjid = <ls_key>-%param-businessobjid
                                                      IMPORTING et_entity       = DATA(lt_entity)
                                                                et_message      = DATA(lt_message) ).

      IF NOT lt_message IS INITIAL.
        zjl_cl_task_bo=>handle_messages( EXPORTING i_cid      = space
                                                   i_taskid   = <ls_key>-%key-taskid
                                                   i_versno   = <ls_key>-%key-versno
                                                   it_message = lt_message
                                          CHANGING failed     = failed-task
                                                   reported   = reported-task ).
        CONTINUE.
      ENDIF.

      LOOP AT lt_entity INTO ls_entity.

* *************************************************************************************
* Attachments kopieren
* *************************************************************************************
* Attachments zur Ursprungsversion lesen
        CLEAR lt_attach_read.
        APPEND INITIAL LINE TO lt_attach_read ASSIGNING FIELD-SYMBOL(<ls_attach_read>).
        <ls_attach_read>-taskid = <ls_key>-%key-taskid.
        <ls_attach_read>-versno = <ls_key>-%key-versno.

        READ ENTITIES OF zjl_o_d_task IN LOCAL MODE
        ENTITY task BY \_attachment
        FROM lt_attach_read
        RESULT   DATA(lt_attach_result)
        FAILED   DATA(lt_attach_failed)
        REPORTED DATA(lt_attach_reported).

* Attachments in neuer Version anlegen
        CLEAR lt_attach_create.
        APPEND INITIAL LINE TO lt_attach_create ASSIGNING FIELD-SYMBOL(<ls_attach_create>).
        <ls_attach_create>-taskid = ls_entity-taskid.
        <ls_attach_create>-versno = ls_entity-taskid .
        <ls_attach_create>-%key-taskid = ls_entity-taskid.
        <ls_attach_create>-%key-versno = ls_entity-versno.
        <ls_attach_create>-%cid_ref = <ls_key>-%cid_ref.

        LOOP AT lt_attach_result ASSIGNING FIELD-SYMBOL(<ls_attach_result>).
          APPEND INITIAL LINE TO  <ls_attach_create>-%target ASSIGNING FIELD-SYMBOL(<ls_attach_target>).
          MOVE-CORRESPONDING <ls_attach_result> TO <ls_attach_target>.
          <ls_attach_target>-taskid = <ls_attach_result>-taskid.
          <ls_attach_target>-versno = <ls_attach_result>-versno.
          <ls_attach_target>-atacno = <ls_attach_result>-atacno.
          <ls_attach_target>-%key-taskid = <ls_attach_result>-taskid.
          <ls_attach_target>-%key-versno = <ls_attach_result>-versno.
          <ls_attach_target>-%key-atacno = <ls_attach_result>-atacno.
          <ls_attach_target>-%cid = sy-tabix.
        ENDLOOP.

        MODIFY ENTITIES OF zjl_o_d_task IN LOCAL MODE
        ENTITY task CREATE BY \_attachment
        FROM lt_attach_create
        MAPPED DATA(lt_attach_mapped)
        FAILED lt_attach_failed
        REPORTED lt_attach_reported.

        CLEAR lt_attach_result.
        CLEAR lt_attach_failed.
        CLEAR lt_attach_reported.

        APPEND INITIAL LINE TO mapped-task ASSIGNING FIELD-SYMBOL(<ls_mapped>).
        <ls_mapped>-%cid             = <ls_key>-%cid.
        <ls_mapped>-taskid           = ls_entity-taskid.
        <ls_mapped>-versno           = ls_entity-versno.
        <ls_mapped>-%tky-%key-taskid = ls_entity-taskid.
        <ls_mapped>-%tky-%key-versno = ls_entity-versno.
        <ls_mapped>-%tky-taskid      = ls_entity-taskid.
        <ls_mapped>-%tky-versno      = ls_entity-versno.

      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

  METHOD forward.

    DATA: ls_entity        TYPE zjl_cl_task_bo=>tp_entity.
    DATA: lt_attach_read   TYPE TABLE FOR READ IMPORT zjl_o_d_task\_attachment.
    DATA: lt_attach_create TYPE TABLE FOR CREATE      zjl_o_d_task\_attachment.

    READ TABLE keys WITH KEY %cid = '' INTO DATA(lt_empty_cid).

    ASSERT lt_empty_cid IS INITIAL.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      zjl_cl_task_bo=>get_instance( )->facact_forward( EXPORTING i_taskid            = <ls_key>-%key-taskid
                                                                 i_versno            = <ls_key>-%key-versno
                                                                 i_recipientcd       = <ls_key>-%param-recipientcd
                                                                 i_recipientgroupcd  = <ls_key>-%param-recipientgroupcd
                                                       IMPORTING et_entity           = DATA(lt_entity)
                                                                 et_message          = DATA(lt_message) ).

      IF NOT lt_message IS INITIAL.
        zjl_cl_task_bo=>handle_messages( EXPORTING i_cid      = space
                                                   i_taskid   = <ls_key>-%key-taskid
                                                   i_versno   = <ls_key>-%key-versno
                                                   it_message = lt_message
                                          CHANGING failed     = failed-task
                                                   reported   = reported-task ).
        CONTINUE.
      ENDIF.

      LOOP AT lt_entity INTO ls_entity.

* *************************************************************************************
* Attachments kopieren
* *************************************************************************************
* Attachments zur Ursprungsversion lesen
        CLEAR lt_attach_read.
        APPEND INITIAL LINE TO lt_attach_read ASSIGNING FIELD-SYMBOL(<ls_attach_read>).
        <ls_attach_read>-taskid = <ls_key>-%key-taskid.
        <ls_attach_read>-versno = <ls_key>-%key-versno.

        READ ENTITIES OF zjl_o_d_task IN LOCAL MODE
        ENTITY task BY \_attachment
        FROM lt_attach_read
        RESULT   DATA(lt_attach_result)
        FAILED   DATA(lt_attach_failed)
        REPORTED DATA(lt_attach_reported).

* Attachments in neuer Version anlegen
        CLEAR lt_attach_create.
        APPEND INITIAL LINE TO lt_attach_create ASSIGNING FIELD-SYMBOL(<ls_attach_create>).
        <ls_attach_create>-taskid = ls_entity-taskid.
        <ls_attach_create>-versno = ls_entity-taskid .
        <ls_attach_create>-%key-taskid = ls_entity-taskid.
        <ls_attach_create>-%key-versno = ls_entity-versno.
        <ls_attach_create>-%cid_ref = <ls_key>-%cid_ref.

        LOOP AT lt_attach_result ASSIGNING FIELD-SYMBOL(<ls_attach_result>).
          APPEND INITIAL LINE TO  <ls_attach_create>-%target ASSIGNING FIELD-SYMBOL(<ls_attach_target>).
          MOVE-CORRESPONDING <ls_attach_result> TO <ls_attach_target>.
          <ls_attach_target>-taskid = <ls_attach_result>-taskid.
          <ls_attach_target>-versno = <ls_attach_result>-versno.
          <ls_attach_target>-atacno = <ls_attach_result>-atacno.
          <ls_attach_target>-%key-taskid = <ls_attach_result>-taskid.
          <ls_attach_target>-%key-versno = <ls_attach_result>-versno.
          <ls_attach_target>-%key-atacno = <ls_attach_result>-atacno.
          <ls_attach_target>-%cid = sy-tabix.
        ENDLOOP.

        MODIFY ENTITIES OF zjl_o_d_task IN LOCAL MODE
        ENTITY task CREATE BY \_attachment
        FROM lt_attach_create
        MAPPED DATA(lt_attach_mapped)
        FAILED lt_attach_failed
        REPORTED lt_attach_reported.

        IF NOT lt_attach_failed IS INITIAL.
          CONTINUE.
        ENDIF.

        CLEAR lt_attach_result.
        CLEAR lt_attach_failed.
        CLEAR lt_attach_reported.

* *************************************************************************************
*
* *************************************************************************************

        APPEND INITIAL LINE TO mapped-task ASSIGNING FIELD-SYMBOL(<ls_mapped>).
        <ls_mapped>-%cid             = <ls_key>-%cid.
        <ls_mapped>-taskid           = ls_entity-taskid.
        <ls_mapped>-versno           = ls_entity-versno.
        <ls_mapped>-%tky-%key-taskid = ls_entity-taskid.
        <ls_mapped>-%tky-%key-versno = ls_entity-versno.
        <ls_mapped>-%tky-taskid      = ls_entity-taskid.
        <ls_mapped>-%tky-versno      = ls_entity-versno.

      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

  METHOD refuse.

    DATA: ls_entity        TYPE zjl_cl_task_bo=>tp_entity.
    DATA: lt_attach_read   TYPE TABLE FOR READ IMPORT zjl_o_d_task\_attachment.
    DATA: lt_attach_create TYPE TABLE FOR CREATE      zjl_o_d_task\_attachment.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      zjl_cl_task_bo=>get_instance( )->facact_refuse( EXPORTING i_taskid  = <ls_key>-%key-taskid
                                                                    i_versno  = <ls_key>-%key-versno
                                                          IMPORTING et_entity      = DATA(lt_entity)
                                                                    et_message = DATA(lt_message) ).

      IF NOT lt_message IS INITIAL.
        zjl_cl_task_bo=>handle_messages( EXPORTING i_cid      = space
                                                   i_taskid   = <ls_key>-%key-taskid
                                                   i_versno   = <ls_key>-%key-versno
                                                   it_message = lt_message
                                          CHANGING failed     = failed-task
                                                   reported   = reported-task ).
        CONTINUE.
      ENDIF.

      LOOP AT lt_entity INTO ls_entity.

* *************************************************************************************
* Attachments kopieren
* *************************************************************************************
* Attachments zur Ursprungsversion lesen
        CLEAR lt_attach_read.
        APPEND INITIAL LINE TO lt_attach_read ASSIGNING FIELD-SYMBOL(<ls_attach_read>).
        <ls_attach_read>-taskid = <ls_key>-%key-taskid.
        <ls_attach_read>-versno = <ls_key>-%key-versno.

        READ ENTITIES OF zjl_o_d_task IN LOCAL MODE
        ENTITY task BY \_attachment
        FROM lt_attach_read
        RESULT   DATA(lt_attach_result)
        FAILED   DATA(lt_attach_failed)
        REPORTED DATA(lt_attach_reported).

* Attachments in neuer Version anlegen
        CLEAR lt_attach_create.
        APPEND INITIAL LINE TO lt_attach_create ASSIGNING FIELD-SYMBOL(<ls_attach_create>).
        <ls_attach_create>-taskid = ls_entity-taskid.
        <ls_attach_create>-versno = ls_entity-taskid .
        <ls_attach_create>-%key-taskid = ls_entity-taskid.
        <ls_attach_create>-%key-versno = ls_entity-versno.
        <ls_attach_create>-%cid_ref = <ls_key>-%cid_ref.

        LOOP AT lt_attach_result ASSIGNING FIELD-SYMBOL(<ls_attach_result>).
          APPEND INITIAL LINE TO  <ls_attach_create>-%target ASSIGNING FIELD-SYMBOL(<ls_attach_target>).
          MOVE-CORRESPONDING <ls_attach_result> TO <ls_attach_target>.
          <ls_attach_target>-taskid = <ls_attach_result>-taskid.
          <ls_attach_target>-versno = <ls_attach_result>-versno.
          <ls_attach_target>-atacno = <ls_attach_result>-atacno.
          <ls_attach_target>-%key-taskid = <ls_attach_result>-taskid.
          <ls_attach_target>-%key-versno = <ls_attach_result>-versno.
          <ls_attach_target>-%key-atacno = <ls_attach_result>-atacno.
          <ls_attach_target>-%cid = sy-tabix.
        ENDLOOP.

        MODIFY ENTITIES OF zjl_o_d_task IN LOCAL MODE
        ENTITY task CREATE BY \_attachment
        FROM lt_attach_create
        MAPPED DATA(lt_attach_mapped)
        FAILED lt_attach_failed
        REPORTED lt_attach_reported.

        CLEAR lt_attach_result.
        CLEAR lt_attach_failed.
        CLEAR lt_attach_reported.

        APPEND INITIAL LINE TO mapped-task ASSIGNING FIELD-SYMBOL(<ls_mapped>).
        <ls_mapped>-%cid             = <ls_key>-%cid.
        <ls_mapped>-taskid           = ls_entity-taskid.
        <ls_mapped>-versno           = ls_entity-versno.
        <ls_mapped>-%tky-%key-taskid = ls_entity-taskid.
        <ls_mapped>-%tky-%key-versno = ls_entity-versno.
        <ls_mapped>-%tky-taskid      = ls_entity-taskid.
        <ls_mapped>-%tky-versno      = ls_entity-versno.

      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

  METHOD complete.

    DATA: ls_entity        TYPE zjl_cl_task_bo=>tp_entity.
    DATA: lt_attach_read   TYPE TABLE FOR READ IMPORT zjl_o_d_task\_attachment.
    DATA: lt_attach_create TYPE TABLE FOR CREATE      zjl_o_d_task\_attachment.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      zjl_cl_task_bo=>get_instance( )->facact_complete( EXPORTING i_taskid   = <ls_key>-%key-taskid
                                                                  i_versno   = <ls_key>-%key-versno
                                                        IMPORTING et_entity  = DATA(lt_entity)
                                                                  et_message = DATA(lt_message) ).

      IF NOT lt_message IS INITIAL.
        zjl_cl_task_bo=>handle_messages( EXPORTING i_cid      = space
                                                   i_taskid   = <ls_key>-%key-taskid
                                                   i_versno   = <ls_key>-%key-versno
                                                   it_message = lt_message
                                          CHANGING failed     = failed-task
                                                   reported   = reported-task ).
        CONTINUE.
      ENDIF.

      LOOP AT lt_entity INTO ls_entity.

* *************************************************************************************
* Attachments kopieren
* *************************************************************************************
* Attachments zur Ursprungsversion lesen
        CLEAR lt_attach_read.
        APPEND INITIAL LINE TO lt_attach_read ASSIGNING FIELD-SYMBOL(<ls_attach_read>).
        <ls_attach_read>-taskid = <ls_key>-%key-taskid.
        <ls_attach_read>-versno = <ls_key>-%key-versno.

        READ ENTITIES OF zjl_o_d_task IN LOCAL MODE
        ENTITY task BY \_attachment
        FROM lt_attach_read
        RESULT   DATA(lt_attach_result)
        FAILED   DATA(lt_attach_failed)
        REPORTED DATA(lt_attach_reported).

* Attachments in neuer Version anlegen
        CLEAR lt_attach_create.
        APPEND INITIAL LINE TO lt_attach_create ASSIGNING FIELD-SYMBOL(<ls_attach_create>).
        <ls_attach_create>-taskid = ls_entity-taskid.
        <ls_attach_create>-versno = ls_entity-versno.
        <ls_attach_create>-%key-taskid = ls_entity-taskid.
        <ls_attach_create>-%key-versno = ls_entity-versno.
        <ls_attach_create>-%cid_ref = <ls_key>-%cid_ref.

        LOOP AT lt_attach_result ASSIGNING FIELD-SYMBOL(<ls_attach_result>).
          APPEND INITIAL LINE TO  <ls_attach_create>-%target ASSIGNING FIELD-SYMBOL(<ls_attach_target>).
          MOVE-CORRESPONDING <ls_attach_result> TO <ls_attach_target>.
          <ls_attach_target>-taskid = <ls_attach_result>-taskid.
          <ls_attach_create>-versno = ls_entity-taskid .
          <ls_attach_target>-atacno = <ls_attach_result>-atacno.
          <ls_attach_target>-%key-taskid = <ls_attach_result>-taskid.
          <ls_attach_target>-%key-versno = <ls_attach_result>-versno.
          <ls_attach_target>-%key-atacno = <ls_attach_result>-atacno.
          <ls_attach_target>-%cid = sy-tabix.
        ENDLOOP.

        MODIFY ENTITIES OF zjl_o_d_task IN LOCAL MODE
        ENTITY task CREATE BY \_attachment
        FROM lt_attach_create
        MAPPED DATA(lt_attach_mapped)
        FAILED lt_attach_failed
        REPORTED lt_attach_reported.

        CLEAR lt_attach_result.
        CLEAR lt_attach_failed.
        CLEAR lt_attach_reported.

        APPEND INITIAL LINE TO mapped-task ASSIGNING FIELD-SYMBOL(<ls_mapped>).
        <ls_mapped>-%cid             = <ls_key>-%cid.
        <ls_mapped>-taskid           = ls_entity-taskid.
        <ls_mapped>-versno           = ls_entity-versno.
        <ls_mapped>-%tky-%key-taskid = ls_entity-taskid.
        <ls_mapped>-%tky-%key-versno = ls_entity-versno.
        <ls_mapped>-%tky-taskid      = ls_entity-taskid.
        <ls_mapped>-%tky-versno      = ls_entity-versno.

      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

  METHOD rba_attachment.

    LOOP AT keys_rba ASSIGNING FIELD-SYMBOL(<ls_key>).

      zjl_cl_attach_bo=>get_instance( )->read_by_assoc(
        EXPORTING
          i_taskid        = <ls_key>-%key-taskid
          i_versno        = <ls_key>-%key-versno
        IMPORTING
          et_entity       = DATA(lt_entity)
          et_message      = DATA(lt_message)
      ).

      IF NOT lt_message IS INITIAL.
        zjl_cl_task_bo=>handle_messages( EXPORTING i_cid      = space
                                                       i_taskid  = <ls_key>-%key-taskid
                                                       i_versno  = <ls_key>-%key-versno
                                                       it_message = lt_message
                                              CHANGING failed     = failed-task
                                                       reported   = reported-task ).
      ELSE.

        LOOP AT lt_entity ASSIGNING FIELD-SYMBOL(<ls_entity>).
          APPEND INITIAL LINE TO association_links ASSIGNING FIELD-SYMBOL(<ls_assoc>).
          <ls_assoc>-source-%key = <ls_key>-%key.
          <ls_assoc>-target-%key-taskid = <ls_entity>-taskid.
          <ls_assoc>-target-%key-versno = <ls_entity>-versno.
          <ls_assoc>-target-%key-atacno = <ls_entity>-atacno.

          APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<ls_result>).
          MOVE-CORRESPONDING <ls_entity> TO  <ls_result>.

        ENDLOOP.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD cba_attachment.

    DATA: ls_entity  TYPE zjl_cl_attach_bo=>tp_entity.

    LOOP AT entities_cba ASSIGNING FIELD-SYMBOL(<ls_entity>).

      LOOP AT <ls_entity>-%target ASSIGNING FIELD-SYMBOL(<ls_data>).

        MOVE-CORRESPONDING <ls_data> TO ls_entity.

        ls_entity-taskid = <ls_entity>-taskid.
        ls_entity-versno = <ls_entity>-versno.

        zjl_cl_attach_bo=>get_instance( )->create( EXPORTING is_entity  = ls_entity
                                                   IMPORTING es_entity  = DATA(ls_entity_out)
                                                             et_message = DATA(lt_message) ).

        IF NOT lt_message IS INITIAL.
          zjl_cl_task_bo=>handle_messages( EXPORTING i_cid      = space
                                                     i_taskid   = <ls_entity>-taskid
                                                     i_versno   = <ls_entity>-versno
                                                     it_message = lt_message
                                            CHANGING failed     = failed-task
                                                     reported   = reported-task ).
        ELSE.
          APPEND INITIAL LINE TO mapped-attachment ASSIGNING FIELD-SYMBOL(<ls_mapped>).
          <ls_mapped>-%cid   = <ls_data>-%cid.
          <ls_mapped>-taskid = ls_entity_out-taskid.
          <ls_mapped>-versno = ls_entity_out-versno.
          <ls_mapped>-atacno = ls_entity_out-atacno.
        ENDIF.

      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_global_features.

    IF requested_features-%create EQ if_abap_behv=>mk-on.
      result-%create = zjl_cl_task_bo=>get_instance( )->get_global_features( EXPORTING i_feature = zjl_if_rap=>co_feature_create ).
    ENDIF.

  ENDMETHOD.

  METHOD get_instance_authorizations.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_keys>).

      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<ls_result>).
      <ls_result>-%key = <ls_keys>-%key.

      IF requested_authorizations-%update EQ if_abap_behv=>mk-on.
        <ls_result>-%update = zjl_cl_task_bo=>get_instance( )->get_instance_authorizations( EXPORTING i_taskid  = <ls_keys>-%key-taskid
                                                                                                          i_versno  = <ls_keys>-%key-versno
                                                                                                          i_feature = zjl_if_rap=>co_feature_update ).
      ENDIF.

      IF requested_authorizations-%update EQ if_abap_behv=>mk-on.
        <ls_result>-%delete = zjl_cl_task_bo=>get_instance( )->get_instance_authorizations( EXPORTING i_taskid  = <ls_keys>-%key-taskid
                                                                                                          i_versno  = <ls_keys>-%key-versno
                                                                                                          i_feature = zjl_if_rap=>co_feature_delete ).
      ENDIF.

      IF requested_authorizations-%action-assign EQ if_abap_behv=>mk-on.
        <ls_result>-%action-assign = zjl_cl_task_bo=>get_instance( )->get_instance_authorizations( EXPORTING i_taskid  = <ls_keys>-%key-taskid
                                                                                                                 i_versno  = <ls_keys>-%key-versno
                                                                                                                 i_feature = zjl_cl_task_bo=>co_feature_assign ).
      ENDIF.

      IF requested_authorizations-%action-complete EQ if_abap_behv=>mk-on.
        <ls_result>-%action-complete = zjl_cl_task_bo=>get_instance( )->get_instance_authorizations( EXPORTING i_taskid  = <ls_keys>-%key-taskid
                                                                                                                   i_versno  = <ls_keys>-%key-versno
                                                                                                                   i_feature = zjl_cl_task_bo=>co_feature_complete ).
      ENDIF.

      IF requested_authorizations-%action-forward EQ if_abap_behv=>mk-on.
        <ls_result>-%action-forward = zjl_cl_task_bo=>get_instance( )->get_instance_authorizations( EXPORTING i_taskid  = <ls_keys>-%key-taskid
                                                                                                                  i_versno  = <ls_keys>-%key-versno
                                                                                                                  i_feature = zjl_cl_task_bo=>co_feature_forward ).
      ENDIF.

      IF requested_authorizations-%action-refuse EQ if_abap_behv=>mk-on.
        <ls_result>-%action-refuse = zjl_cl_task_bo=>get_instance( )->get_instance_authorizations( EXPORTING i_taskid  = <ls_keys>-%key-taskid
                                                                                                                 i_versno  = <ls_keys>-%key-versno
                                                                                                                 i_feature = zjl_cl_task_bo=>co_feature_refuse ).
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD map_with_control.

    DATA: lr_control       TYPE REF TO data.
    DATA: lr_control_descr TYPE REF TO cl_abap_structdescr.
    DATA: l_name           TYPE abap_compname.

    FIELD-SYMBOLS: <l_field>     TYPE any.
    FIELD-SYMBOLS: <l_field_in>  TYPE any.
    FIELD-SYMBOLS: <l_field_out> TYPE any.

    CLEAR: lr_control.
    CLEAR: lr_control_descr.

    CREATE DATA lr_control LIKE is_control.

    lr_control_descr ?= cl_abap_structdescr=>describe_by_data_ref( p_data_ref = lr_control ).

    LOOP AT lr_control_descr->components ASSIGNING FIELD-SYMBOL(<l_component>).

      ASSIGN COMPONENT <l_component>-name OF STRUCTURE is_control TO <l_field>.

      IF  <l_field> IS ASSIGNED
      AND <l_field> EQ if_abap_behv=>mk-on.

        ASSIGN COMPONENT <l_component>-name OF STRUCTURE is_entity TO <l_field_in>.
        ASSIGN COMPONENT <l_component>-name OF STRUCTURE cs_entity TO <l_field_out>.

        IF  <l_field_in>  IS ASSIGNED
        AND <l_field_out> IS ASSIGNED.
          <l_field_out> = <l_field_in>.
        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_task DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS adjust_numbers REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_task IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD adjust_numbers.

    DATA: lt_task_failed   TYPE zjl_cl_task_bo=>tpt_failed.
    DATA: lt_task_reported TYPE zjl_cl_task_bo=>tpt_reported.

    zjl_cl_task_da=>get_instance( )->adjust_numbers( IMPORTING e_task_id  = DATA(l_taskid)
                                                               e_vers_no  = DATA(l_versno)
                                                               et_message = DATA(lt_message) ).

    IF NOT lt_message IS INITIAL.
      zjl_cl_task_bo=>handle_messages( EXPORTING i_cid      = space
                                                 it_message = lt_message
                                       CHANGING  failed     = lt_task_failed
                                                 reported   = lt_task_reported ).
    ELSE.
      APPEND INITIAL LINE TO mapped-task ASSIGNING FIELD-SYMBOL(<ls_mapped>).
      <ls_mapped>-%key-taskid = l_taskid.
      <ls_mapped>-%key-versno = l_versno.
    ENDIF.

  ENDMETHOD.

  METHOD save.

    zjl_cl_task_da=>get_instance( )->save( ).
    zjl_cl_attach_da=>get_instance( )->save( ).

  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
