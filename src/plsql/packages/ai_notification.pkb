create or replace package body ai_notification as

  procedure send_update_to_client
  as 
    l_body  clob;
    l_resp  clob;
    l_execution  apex_background_process.t_execution;
  begin
    apex_debug.enter( 'send_update_to_client');

    apex_debug.info('get execution');
    l_execution := apex_background_process.get_current_execution;

    apex_debug.info('l_execution: %s', l_execution.id);

    select json_object(
              'process_id' value execution_id,
              'app_user'   value 'JGDR',
              'name'       value process_name,
              'state'      value decode(status_code, 'EXECUTING', 'running'
                                                  , 'SUCCESS', 'success'
                                                  , status_code ),
              'message'    value status_message,
              'started_at' value to_char(created_on, 'yyyy-mm-dd"t"hh24:mi:ss.fftzh:tzm'),
              'updated_at' value to_char(last_updated_on, 'yyyy-mm-dd"t"hh24:mi:ss.fftzh:tzm')
              returning clob
            )
      into l_body
      from apex_appl_page_bg_proc_status
      where execution_id  = l_execution.id;

    apex_debug.info('l_body: %s', l_body);

    apex_web_service.g_request_headers.DELETE;
    apex_web_service.g_request_headers(1).name  := 'Content-Type';
    apex_web_service.g_request_headers(1).value := 'application/json';

    l_resp := apex_web_service.make_rest_request(
                p_url         => 'http://host.containers.internal:8090/ingest',
                p_http_method => 'POST',
                p_body        => l_body
              );

  end send_update_to_client;

  ----------------------------------------------------------------------------------------

  procedure update_background_process( p_message  varchar2 )
  as 
  begin 
    apex_debug.enter( 'update_background_process' 
                    , 'p_message', p_message );
    apex_debug.info('set status');
    apex_background_process.set_status( p_message => p_message );
    apex_debug.info('status set');
    ai_notification.send_update_to_client;

  end update_background_process;

end ai_notification;