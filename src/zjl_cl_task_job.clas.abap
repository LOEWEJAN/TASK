CLASS zjl_cl_task_job DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_apj_dt_exec_object.
    INTERFACES if_apj_rt_exec_object.
    INTERFACES if_apj_jt_check.
    INTERFACES if_oo_adt_classrun.

  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS: co_selopt_id  TYPE c LENGTH 8 VALUE 'S_ID'.
    CONSTANTS: co_param_test TYPE c LENGTH 8 VALUE 'P_TEST'.
    CONSTANTS: co_param_prot TYPE c LENGTH 8 VALUE 'P_PROT'.
    CONSTANTS: co_param_days TYPE c LENGTH 8 VALUE 'P_DAYS'.

    CONSTANTS: co_log  TYPE if_bali_header_setter=>ty_object VALUE 'ZJL_TASK_JOB'.
    CONSTANTS: co_log_item TYPE if_bali_header_setter=>ty_subobject VALUE 'ITEM'.
    CONSTANTS: co_log_parameter TYPE if_bali_header_setter=>ty_subobject VALUE 'PARAMETER'.
    CONSTANTS: co_log_runtime TYPE if_bali_header_setter=>ty_subobject VALUE 'RUNTIME'.

    DATA: ot_task_id TYPE RANGE OF zjl_id.
    DATA: o_test     TYPE abap_boolean.
    DATA: o_days     TYPE n LENGTH 3.
    DATA: o_prot     TYPE abap_boolean.

    DATA: o_job_catalog  TYPE cl_apj_rt_api=>ty_catalog_name.
    DATA: o_job_template TYPE cl_apj_rt_api=>ty_template_name.
    DATA: o_job_spoolid  TYPE c LENGTH 100.

    DATA: or_log TYPE REF TO if_bali_log.

    METHODS: run  EXPORTING e_selected TYPE i
                            e_skipped  TYPE i
                            e_failed   TYPE i
                  RAISING   cx_bali_runtime .

ENDCLASS.

CLASS zjl_cl_task_job IMPLEMENTATION.

  METHOD if_apj_jt_check~adjust_metadata.

*Is called when the job scheduling framework requires the metadata of the job catalog entry parameters. The method provides two possibilities:
*Hide a parameter (hidden_ind = 'X')
*Make a parameter mandatory (mandatory_ind = 'X')
*The method returns the parameters where the metadata must be adjusted during runtime.

  ENDMETHOD.

  METHOD if_apj_jt_check~check_before_schedule.

* Is called when the user clicks Schedule Job and checks, but doesn't change the parameter values from the selection screen. Parameters that are set to hidden either in the report or in the job catalog entry can be changed.

  ENDMETHOD.

  METHOD if_apj_jt_check~get_additional_parameters.

  ENDMETHOD.

  METHOD if_apj_jt_check~check_and_adjust.

* Is called on request by the user. It checks and changes the parameter values that are entered on the selection screen. Parameters that are set to hidden either in the report or in the job catalog entry cannot be changed.

  ENDMETHOD.

  METHOD if_apj_jt_check~get_dynamic_properties.

  ENDMETHOD.

  METHOD if_apj_jt_check~initialize.

* Is called when a job template is opened and initializes parameter values on the selection screen.

  ENDMETHOD.

  METHOD if_apj_dt_exec_object~get_parameters.

* ************************************************************************************
* Definition of Parameters (used via Job Template)
* ************************************************************************************
    APPEND INITIAL LINE TO et_parameter_def ASSIGNING FIELD-SYMBOL(<ls_param_def>).
    <ls_param_def>-selname        = co_selopt_id.
    <ls_param_def>-kind           = if_apj_dt_exec_object=>select_option.
    <ls_param_def>-datatype       = 'ZJL_ID'.
*    <ls_param_def>-length         = .
    <ls_param_def>-param_text     = 'Aufgabe'.
    <ls_param_def>-changeable_ind = abap_true.

    APPEND INITIAL LINE TO et_parameter_def ASSIGNING <ls_param_def>.
    <ls_param_def>-selname        = co_param_days.
    <ls_param_def>-kind           = if_apj_dt_exec_object=>parameter.
    <ls_param_def>-datatype       = 'N'.
    <ls_param_def>-length         = 3.
    <ls_param_def>-param_text     = 'Vorlauf (Tage)'.
    <ls_param_def>-changeable_ind = abap_true.

    APPEND INITIAL LINE TO et_parameter_def ASSIGNING <ls_param_def>.
    <ls_param_def>-selname        = co_param_test.
    <ls_param_def>-kind           = if_apj_dt_exec_object=>parameter.
    <ls_param_def>-datatype       = 'C'.
    <ls_param_def>-length         = 1.
    <ls_param_def>-param_text     = 'Testlauf'.
    <ls_param_def>-changeable_ind = abap_true.

    APPEND INITIAL LINE TO et_parameter_def ASSIGNING <ls_param_def>.
    <ls_param_def>-selname        = co_param_prot.
    <ls_param_def>-kind           = if_apj_dt_exec_object=>parameter.
    <ls_param_def>-datatype       = 'C'.
    <ls_param_def>-length         = 1.
    <ls_param_def>-param_text     = 'Protokoll erzeugen'.
    <ls_param_def>-changeable_ind = abap_true.

* ************************************************************************************
* Definition of Default Values
* ************************************************************************************
    APPEND INITIAL LINE TO et_parameter_val ASSIGNING FIELD-SYMBOL(<ls_param_val>).
    <ls_param_val>-selname = co_param_test.
    <ls_param_val>-kind    = if_apj_dt_exec_object=>parameter.
    <ls_param_val>-sign    = 'I' .
    <ls_param_val>-option  = 'EQ' .
    <ls_param_val>-low     = abap_true.

    APPEND INITIAL LINE TO et_parameter_val ASSIGNING <ls_param_val>.
    <ls_param_val>-selname = co_param_days.
    <ls_param_val>-kind    = if_apj_dt_exec_object=>parameter.
    <ls_param_val>-sign    = 'I' .
    <ls_param_val>-option  = 'EQ' .
    <ls_param_val>-low     = 3.

    APPEND INITIAL LINE TO et_parameter_val ASSIGNING <ls_param_val>.
    <ls_param_val>-selname = co_param_prot.
    <ls_param_val>-kind    = if_apj_dt_exec_object=>parameter.
    <ls_param_val>-sign    = 'I' .
    <ls_param_val>-option  = 'EQ' .
    <ls_param_val>-low     = abap_true.

  ENDMETHOD.

  METHOD if_apj_rt_exec_object~execute.

    DATA: l_dummy TYPE c.

* ************************************************************************************
* Get Input Values
* ************************************************************************************
    LOOP AT it_parameters ASSIGNING FIELD-SYMBOL(<ls_param>).
      CASE <ls_param>-selname.
        WHEN co_selopt_id.
          APPEND VALUE #( sign   = <ls_param>-sign option = <ls_param>-option low = <ls_param>-low high = <ls_param> ) TO ot_task_id.
        WHEN co_param_days.
          o_days = <ls_param>-low.
        WHEN co_param_test.
          o_test = <ls_param>-low.
        WHEN co_param_prot.
          o_prot = <ls_param>-low.
      ENDCASE.
    ENDLOOP.

    TRY.

* ************************************************************************************
* Set Job-ID
* ************************************************************************************
        o_job_spoolid = utclong_current( ).

* ************************************************************************************
* Create Item Log
* ************************************************************************************
        or_log = cl_bali_log=>create_with_header( cl_bali_header_setter=>create( object      = co_log subobject = co_log_item
                                                                                 external_id = o_job_spoolid ) ).

* ************************************************************************************
* Business
* ************************************************************************************
        DATA(l_start) = utclong_current( ).

        run( IMPORTING e_selected = DATA(l_selected)
                       e_skipped  = DATA(l_skipped)
                       e_failed   = DATA(l_failed) ).

        DATA(l_end) = utclong_current( ).

* ************************************************************************************
* Save Item Log
* ************************************************************************************
        IF o_prot EQ abap_true.
          cl_bali_log_db=>get_instance( )->save_log( log = or_log ).
        ENDIF.

      CATCH cx_bali_runtime INTO DATA(lr_exeption_runtime_1).
* Error-Handling for Log

    ENDTRY.

* ************************************************************************************
* Create Parameter Log
* ************************************************************************************
    TRY.

        or_log = cl_bali_log=>create_with_header( cl_bali_header_setter=>create( object      = co_log subobject = co_log_parameter
                                                                                 external_id = o_job_spoolid ) ).

* ************************************************************************************
* Log Parameter
* ************************************************************************************
        MESSAGE i012(zjl_rap) WITH co_param_test o_test INTO l_dummy.
        or_log->add_item( item = cl_bali_message_setter=>create_from_sy( ) ).

        MESSAGE i012(zjl_rap) WITH co_param_prot o_prot INTO l_dummy.
        or_log->add_item( item = cl_bali_message_setter=>create_from_sy( ) ).

        MESSAGE i012(zjl_rap) WITH co_param_days o_days INTO l_dummy.
        or_log->add_item( item = cl_bali_message_setter=>create_from_sy( ) ).

        LOOP AT ot_task_id ASSIGNING FIELD-SYMBOL(<ls_task_id>).
          MESSAGE i013(zjl_rap) WITH co_selopt_id <ls_task_id>-low <ls_task_id>-high INTO l_dummy.
          or_log->add_item( item = cl_bali_message_setter=>create_from_sy( ) ).
        ENDLOOP.

* ************************************************************************************
* Save Parameter Log
* ************************************************************************************
        cl_bali_log_db=>get_instance( )->save_log( log = or_log ).

      CATCH cx_bali_runtime INTO DATA(lr_exeption_runtime_2).
* Error-Handling for Log

    ENDTRY.

* ************************************************************************************
* Create Runtime Log
* ************************************************************************************
    TRY.
        or_log = cl_bali_log=>create_with_header( cl_bali_header_setter=>create( object      = co_log subobject = co_log_runtime
                                                                                 external_id = o_job_spoolid ) ).

* ************************************************************************************
* Log Runtime
* ************************************************************************************
        TRY.
            cl_apj_rt_api=>get_job_runtime_info( IMPORTING ev_catalog_name  = o_job_catalog
                                                           ev_template_name = o_job_template ).
          CATCH cx_apj_rt.
* No runtime information in case of online run.
        ENDTRY.

        DATA(l_processed) = l_selected - l_skipped - l_failed.

        cl_abap_utclong=>diff( EXPORTING low     = l_start
                                         high    = l_end
                               IMPORTING seconds = DATA(l_seconds) ).


        MESSAGE i018(zjl_rap) WITH o_job_catalog INTO l_dummy.
        or_log->add_item( item = cl_bali_message_setter=>create_from_sy( ) ).

        MESSAGE i019(zjl_rap) WITH o_job_template INTO l_dummy.
        or_log->add_item( item = cl_bali_message_setter=>create_from_sy( ) ).

        MESSAGE i014(zjl_rap) WITH l_selected INTO l_dummy.
        or_log->add_item( item = cl_bali_message_setter=>create_from_sy( ) ).

        MESSAGE i015(zjl_rap) WITH l_skipped INTO l_dummy.
        or_log->add_item( item = cl_bali_message_setter=>create_from_sy( ) ).

        MESSAGE i016(zjl_rap) WITH l_processed INTO l_dummy.
        or_log->add_item( item = cl_bali_message_setter=>create_from_sy( ) ).

        MESSAGE i017(zjl_rap) WITH l_failed INTO l_dummy.
        or_log->add_item( item = cl_bali_message_setter=>create_from_sy( ) ).

        MESSAGE i020(zjl_rap) WITH l_start INTO l_dummy.
        or_log->add_item( item = cl_bali_message_setter=>create_from_sy( ) ).

        MESSAGE i021(zjl_rap) WITH l_end INTO l_dummy.
        or_log->add_item( item = cl_bali_message_setter=>create_from_sy( ) ).

        MESSAGE i022(zjl_rap) WITH l_seconds INTO l_dummy.
        or_log->add_item( item = cl_bali_message_setter=>create_from_sy( ) ).

* ************************************************************************************
* Save Parameter Log
* ************************************************************************************
        cl_bali_log_db=>get_instance( )->save_log( log = or_log ).

      CATCH cx_bali_runtime INTO DATA(lr_exeption_runtime_3).
* Error-Handling for Log

    ENDTRY.

  ENDMETHOD.


  METHOD run.

    DATA: lt_tasks TYPE TABLE OF zjl_o_d_task.
    DATA: lr_item  TYPE REF TO if_bali_message_setter.
    DATA: l_dummy  TYPE c.

    DATA(l_date) = cl_abap_context_info=>get_system_date( ) - o_days.

    SELECT * FROM zjl_o_d_task INTO TABLE @lt_tasks .

    LOOP AT lt_tasks ASSIGNING FIELD-SYMBOL(<ls_tasks>).

* Selektiert
      e_selected = e_selected + 1.

* Ausgesteuert
      IF NOT <ls_tasks>-completedfl IS INITIAL
      OR     <ls_tasks>-targetdt    LT l_date.
        e_skipped = e_skipped + 1.
        CONTINUE.
      ENDIF.

* Do something

* Add a standard message (Nur Fehler/Warnung/Erfolg)
      MESSAGE s004(zjl_task) WITH <ls_tasks>-taskid INTO l_dummy.
      lr_item = cl_bali_message_setter=>create_from_sy( ).
      or_log->add_item( item = lr_item ).

    ENDLOOP.

  ENDMETHOD.

  METHOD if_oo_adt_classrun~main.

    DATA: lt_parameters TYPE if_apj_rt_exec_object=>tt_templ_val.

    APPEND INITIAL LINE TO lt_parameters ASSIGNING FIELD-SYMBOL(<ls_param>).
    <ls_param>-selname = co_param_test.
    <ls_param>-low = abap_true.

    APPEND INITIAL LINE TO lt_parameters ASSIGNING <ls_param>.
    <ls_param>-selname = co_param_prot.
    <ls_param>-low = abap_true.

    APPEND INITIAL LINE TO lt_parameters ASSIGNING <ls_param>.
    <ls_param>-selname = co_param_days.
    <ls_param>-low = 2.

    TRY.
        if_apj_rt_exec_object~execute( it_parameters = lt_parameters ).

      CATCH cx_apj_rt_content.
        "handle exception

    ENDTRY.


  ENDMETHOD.

ENDCLASS.

