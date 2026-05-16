create or replace package body ai_service 
as 

  procedure setup_headers( p_ai_service_id  ai_services.ai_service_id%type)
  as 
  begin 
    apex_debug.enter( 'setup_headers' 
                    , 'p_ai_service_id', p_ai_service_id);

    apex_web_service.clear_request_headers;
    apex_web_service.g_request_headers(1).name := 'Content-Type';
    apex_web_service.g_request_headers(1).value := 'application/json';

    for rec in (select rownum+1 as rn, header_name, header_value 
                  from ai_service_additional_headers 
                  where ai_service_id = p_ai_service_id )
    loop
      apex_web_service.g_request_headers(rec.rn).name := rec.header_name;
      apex_web_service.g_request_headers(rec.rn).value := rec.header_value;
    end loop;     

  end setup_headers;

  function get_auth_cred_static_id( p_ai_service_id  ai_services.ai_service_id%type)
    return ai_services.apex_ws_cred_static_id%type
  as 
    p_apex_ws_cred_static_id  ai_services.apex_ws_cred_static_id%type;
  begin 
    apex_debug.enter( 'get_auth_cred_static_id' 
                    , 'p_ai_service_id', p_ai_service_id);

    select max(apex_ws_cred_static_id) 
      into p_apex_ws_cred_static_id
      from ai_services
      where ai_service_id = p_ai_service_id;
    
    return p_apex_ws_cred_static_id;
    
  end get_auth_cred_static_id;

end ai_service;
/