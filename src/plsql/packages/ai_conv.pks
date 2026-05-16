create or replace package ai_conv
as


  function create_conversation( p_ai_agent       ai_conversations.ai_agent_id%type 
                              , p_ai_service_id  ai_conversations.ai_service_id%type
                              , p_model          ai_conversations.model%type
                              , p_tools          ai_conversations.tools%type
                              , p_execution_type ai_conversations.execution_type%type -- USER / SYSTEM
                              , p_history_mode   ai_conversations.history_mode%type )
    return ai_conversations.ai_conversation_id%type;

  function get_conversation_status( p_ai_conversation_id  ai_conversations.ai_conversation_id%type )
    return varchar2;

  procedure update_conversation_status ( p_ai_conversation_id  ai_conversations.ai_conversation_id%type
                                       , p_status              ai_conversations.status%type );

  procedure continue_conversation( p_ai_conversation_id  ai_conversations.ai_conversation_id%type
                                 , p_user_message        clob );


end ai_conv;
/