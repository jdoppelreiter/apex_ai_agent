create or replace package ai_prompt 
as 

  procedure prepare( p_prompt_io  in out nocopy json_object_t 
                   , p_model      ai_services.model%type
                   , p_tools      clob default null 
                   , p_ai_conversation_id  ai_conversations.ai_conversation_id%type default null );

  procedure update_prompt( p_prompt_io  in out nocopy json_object_t
                         , p_message                  json_object_t 
                         , p_ai_conversation_id       ai_conversation_histories.ai_conversation_id%type default null
                         , p_msg_direction            ai_conversation_histories.msg_direction%type default ai_constants.c_conv_msg_direction_out);

  function build_message( p_role          varchar2
                        , p_content       clob default null
                        , p_tool_call_id  varchar2 default null
                        , p_tool_calls    json_array_t default null)
    return json_object_t ;

end ai_prompt;
/