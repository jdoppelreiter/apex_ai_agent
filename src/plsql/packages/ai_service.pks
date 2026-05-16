create or replace package ai_service 
as 

  procedure setup_headers( p_ai_service_id  ai_services.ai_service_id%type);
  
  function get_auth_cred_static_id( p_ai_service_id  ai_services.ai_service_id%type)
    return ai_services.apex_ws_cred_static_id%type;

end ai_service;
/