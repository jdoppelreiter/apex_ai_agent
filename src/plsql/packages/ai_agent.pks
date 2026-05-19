create or replace package ai_agent as

  -- types
  type t_clob_list is table of clob;

  -- functions / procedures
  function get_version return varchar2;

  procedure send_prompt( p_ai_conversation_id  ai_conversations.ai_conversation_id%type
                       , p_prompt              json_object_t );

  /* Setting up a run 
   * If parameters are set to null or left empty 
   * the defaults specified in the ai_agents table are used.
  */
  procedure setup_run (  p_ai_agent_id     ai_agents.ai_agent_id%type
                       , p_execution_type  ai_conversations.execution_type%type default ai_constants.c_conv_exec_type_user
                       , p_ai_service_id   ai_services.ai_service_id%type default null
                       , p_model           ai_services.model%type default null
                       , p_system_prompt   ai_agents.system_prompt%type default null
                       , p_user_prompt     clob default null -- text
                       , p_tools           clob default null -- json array
                       , p_history_mode    ai_conversations.history_mode%type default ai_constants.c_history_mode_table -- TABLE / COLLECTION 
                       , p_ai_conversation_id_o  out ai_conversations.ai_conversation_id%type
                       , p_prompt_o              out clob );

  procedure start_run_job( p_ai_conversation_id  ai_conversations.ai_conversation_id%type
                         , p_prompt              clob );

  procedure start_run( p_ai_conversation_id  ai_conversations.ai_conversation_id%type
                     , p_prompt              clob );
  
end ai_agent;
/
