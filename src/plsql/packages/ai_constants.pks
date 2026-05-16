create or replace package ai_constants as

  -- constants
  c_version                  constant varchar2(10) := '1.0.0';
  c_archive_developer_prompt constant boolean := true;
  c_max_conv_message_count   constant integer := 10; 

  c_http_method_completion          constant varchar2(4) := 'POST';                    
  c_http_endpoint_code_completions  constant varchar2(200) := 'COMPLETION';
  c_http_endpoint_completions       constant varchar2(200) := '/v1/chat/completions';

  c_ai_role_system      constant varchar2(20) := 'system';
  c_ai_role_developer   constant varchar2(20) := 'developer';
  c_ai_role_user        constant varchar2(20) := 'user';
  c_ai_role_assistant   constant varchar2(20) := 'assistant';
  c_ai_role_tool        constant varchar2(20) := 'tool';

  -- system prompts
  c_master_prompt_end_task  constant clob := 'You are an AI Agent. When your task is done answer with: "##FINISHED##".'||chr(10)
                                           ||'Important: Dont ask any unnecessary information in the content attribute, only important questions for continuing the task, or the finish marker.'||chr(10)
                                           ||'If you cannot complete the task tell it to the user and dont use the finish-marker';
  
  -- AI Conversation Constants

  c_history_mode_table       constant varchar2(20) := 'TABLE';
  c_history_mode_collection  constant varchar2(20) := 'COLLECTION';

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
end ai_constants;
/
