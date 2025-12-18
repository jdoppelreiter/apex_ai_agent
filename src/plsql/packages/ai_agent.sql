create or replace package ai_agent as

  -- constants
  c_version                  constant varchar2(10) := '1.0.0';
  c_archive_developer_prompt constant boolean := true;
  c_max_conv_message_count   constant integer := 10; 

  c_http_method_completion          constant varchar2(4) := 'POST';                    
  c_http_endpoint_code_completions  constant varchar2(200) := 'COMPLETION';
  c_http_endpoint_completions       constant varchar2(200) := '/v1/chat/completions';

  c_history_mode_table       constant varchar2(20) := 'TABLE';
  c_history_mode_collection  constant varchar2(20) := 'COLLECTION';

  c_ai_role_system      constant varchar2(20) := 'system';
  c_ai_role_developer   constant varchar2(20) := 'developer';
  c_ai_role_user        constant varchar2(20) := 'user';
  c_ai_role_assistant   constant varchar2(20) := 'assistant';
  c_ai_role_tool        constant varchar2(20) := 'tool';


  c_conv_status_created   constant varchar2(20) := 'CREATED';
  c_conv_status_running   constant varchar2(20) := 'RUNNING';
  c_conv_status_finished  constant varchar2(20) := 'FINISHED';
  c_conv_status_user_question   constant varchar2(20) := 'USER_QUESTION';
  c_conv_status_max_message     constant varchar2(20) := 'MAX_MESSAGES_REACHED';


  c_conv_exec_type_user    constant varchar2(10) := 'USER';
  c_conv_exec_type_system  constant varchar2(10) := 'SYSTEM';

  c_conv_msg_type_message    constant varchar2(20) := 'MESSAGE';
  c_conv_msg_type_exception  constant varchar2(20) := 'EXCEPTION';

  c_conv_msg_direction_in   constant varchar2(3) := 'IN';
  c_conv_msg_direction_out  constant varchar2(3) := 'OUT';

  -- types
  type t_clob_list is table of clob;

  -- exceptions 
  e_no_model_in_ai_service  exception;
  e_no_model_in_ai_service_int  constant number := -20200;
  pragma exception_init (e_no_model_in_ai_service , e_no_model_in_ai_service_int); 

  e_not_implemented_collections  exception;
  e_not_implemented_collections_int  constant number := -20201;
  pragma exception_init (e_not_implemented_collections , e_not_implemented_collections_int);

  e_prompt_arg_not_translateable exception;
  e_prompt_arg_not_translateable_int  constant number := -20301;
  pragma exception_init (e_prompt_arg_not_translateable , e_prompt_arg_not_translateable_int);

  e_message_empty exception;
  e_message_empty_int  constant number := -20302;
  pragma exception_init (e_message_empty , e_message_empty_int);

  e_conv_status_wrong  exception;
  e_conv_status_wrong_int  constant number := -20303;
  pragma exception_init (e_conv_status_wrong , e_conv_status_wrong_int );


  -- system prompts
  c_master_prompt_end_task  constant clob := 'You are an AI Agent. When your task is done answer with: "##FINISHED##".'||chr(10)
                                           ||'Important: Dont ask any unnecessary information in the content attribute, only important questions for continuing the task, or the finish marker.'||chr(10)
                                           ||'If you cannot complete the task tell it to the user and dont use the finish-marker';

  -- functions / procedures
  function get_version return varchar2;

  procedure send_prompt( p_ai_conversation_id  ai_conversations.ai_conversation_id%type
                       , p_prompt         json_object_t );

  /* Used for first message / service start 
   * If parameters are set to null or left empty 
   * the defaults specified in the ai_agents table are used.
  */
  function start_agent(  p_ai_agent_id     ai_agents.ai_agent_id%type
                       , p_execution_type  ai_conversations.execution_type%type default ai_agent.c_conv_exec_type_user
                       , p_ai_service_id   ai_services.ai_service_id%type default null
                       , p_model           ai_services.model%type default null
                       , p_system_prompt   ai_agents.system_prompt%type default null
                       , p_user_prompt     clob default null -- text
                       , p_tools           clob default null -- json array
                       , p_history_mode    ai_conversations.history_mode%type default ai_agent.c_history_mode_table ) -- TABLE / COLLECTION 
    return ai_conversations.ai_conversation_id%type;
  
  function get_conversation_status( p_ai_conversation_id  ai_conversations.ai_conversation_id%type )
    return varchar2;

  function get_user_question( p_ai_conversation_id  ai_conversations.ai_conversation_id%type )
    return clob;

  procedure continue_conversation( p_ai_conversation_id  ai_conversations.ai_conversation_id%type
                                 , p_user_message        clob );
end ai_agent;
/
