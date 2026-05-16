create or replace package ai_conv_history 
as 

  function has_history_entries( p_ai_conversation_id  ai_conversations.ai_conversation_id%type )
    return boolean;

  function get_user_question( p_ai_conversation_id  ai_conversations.ai_conversation_id%type )
    return clob;
  
  procedure add_to_history( p_ai_conversation_id   ai_conversations.ai_conversation_id%type
                          , p_msg_type             ai_conversation_histories.msg_type%type default ai_constants.c_conv_msg_type_message
                          , p_msg_direction        ai_conversation_histories.msg_direction%type default ai_constants.c_conv_msg_direction_out
                          , p_msg_role             ai_conversation_histories.msg_role%type
                          , p_content              ai_conversation_histories.content%type);

  function get_message_history( p_ai_conversation_id  ai_conversations.ai_conversation_id%type )
    return json_array_t ;

end ai_conv_history;
