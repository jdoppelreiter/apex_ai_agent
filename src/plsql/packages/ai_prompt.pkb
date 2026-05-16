create or replace package body ai_prompt 
as 

  procedure prepare( p_prompt_io  in out nocopy json_object_t 
                        , p_model      ai_services.model%type
                        , p_tools      clob default null 
                        , p_ai_conversation_id  ai_conversations.ai_conversation_id%type default null )
  as
    l_prompt  json_object_t;
  begin
    if p_prompt_io is null then 
      p_prompt_io := json_object_t();
    end if;

    apex_debug.enter( 'build_prompt'
                    , 'p_prompt_io', dbms_lob.substr(p_prompt_io.to_clob, 4000,1)
                    , 'p_model', p_model
                    , 'p_tools', dbms_lob.substr(p_tools, 4000,1));

    p_prompt_io.put('model', p_model);
    if p_tools is null then 
      p_prompt_io.put('tools', json_array_t() );
    else 
      p_prompt_io.put('tools', json_array_t.parse( p_tools ));
    end if;

    if p_ai_conversation_id is not null and ai_conv_history.has_history_entries( p_ai_conversation_id => p_ai_conversation_id ) then 
      -- load previous stored messages
      p_prompt_io.put('messages', ai_conv_history.get_message_history( p_ai_conversation_id => p_ai_conversation_id));
    else 
      p_prompt_io.put('messages', json_array_t());
    end if;

    apex_debug.info('prompt built (lenght: %s)', dbms_lob.getlength(p_prompt_io.to_clob));
    apex_debug.trace('prompt: %s', dbms_lob.substr(p_prompt_io.to_clob, 4000,1));

  end prepare;
  
  ----------------------------------------------------------------------------------------

  procedure update_prompt( p_prompt_io  in out nocopy json_object_t
                         , p_message                  json_object_t 
                         , p_ai_conversation_id       ai_conversation_histories.ai_conversation_id%type default null
                         , p_msg_direction            ai_conversation_histories.msg_direction%type default ai_constants.c_conv_msg_direction_out)
  as 
    l_prompt         json_object_t;
    l_message        json_object_t;
    l_messages_array json_array_t;
    
  begin

    apex_debug.enter( 'update_prompt'
                    , 'p_prompt_io', dbms_lob.substr(p_prompt_io.to_clob, 4000,1)
                    , 'p_message', p_message.to_clob
                    , 'p_ai_conversation_id', to_char(p_ai_conversation_id) );

    -- add message to end of message history inside the prompt
    l_messages_array := p_prompt_io.get_Array('messages');

    l_messages_array.append(p_message);

    if p_ai_conversation_id is not null then 
      ai_conv_history.add_to_history( p_ai_conversation_id   => p_ai_conversation_id
                                    , p_msg_type             => ai_constants.c_conv_msg_type_message
                                    , p_msg_direction        => p_msg_direction
                                    , p_msg_role             => p_message.get_string('role')
                                    , p_content              => p_message.to_clob);
    end if;

    apex_debug.info('prompt updated (lenght: %s)', dbms_lob.getlength(p_prompt_io.to_clob));
    apex_debug.trace('prompt: %s', dbms_lob.substr(p_prompt_io.to_clob, 4000,1));

  end update_prompt;

  ----------------------------------------------------------------------------------------

  function build_message( p_role          varchar2
                        , p_content       clob default null
                        , p_tool_call_id  varchar2 default null
                        , p_tool_calls    json_array_t default null)
    return json_object_t
  as
    l_message  json_object_t;
  begin

    if p_content is null and p_tool_call_id is null and p_tool_calls is null then 
      raise ai_error.e_message_empty;
    end if;

    l_message := json_object_t();
    l_message.put('role', p_role);

    if p_tool_call_id is not null then 
      l_message.put('tool_call_id', p_tool_call_id);
    end if;

    if p_content is not null then 
      l_message.put('content', p_content);
    end if;

    if p_tool_calls is not null then 
      l_message.put('tool_calls',p_tool_calls);
    end if;

    return l_message;
  end build_message;

end ai_prompt;
/