create or replace package body ai_conv
as

  function create_conversation( p_ai_agent       ai_conversations.ai_agent_id%type 
                              , p_ai_service_id  ai_conversations.ai_service_id%type
                              , p_model          ai_conversations.model%type
                              , p_tools          ai_conversations.tools%type
                              , p_execution_type ai_conversations.execution_type%type -- USER / SYSTEM
                              , p_history_mode   ai_conversations.history_mode%type )
    return ai_conversations.ai_conversation_id%type
  as 
    pragma autonomous_transaction;
    l_ai_conversation_id  ai_conversations.ai_conversation_id%type;
    l_conv_status_created varchar2(20) := ai_constants.c_conv_status_created;
  begin
    apex_debug.enter( 'create_conversation'
                    , 'p_ai_agent', p_ai_agent
                    , 'p_ai_service_id', p_ai_service_id
                    , 'p_model', p_model
                    , 'p_tools', dbms_lob.substr(p_tools, 4000,1)
                    , 'p_execution_type', p_execution_type
                    , 'p_history_mode', p_history_mode );

    if p_history_mode = ai_constants.c_history_mode_collection then 
      raise ai_error.e_not_implemented_collections;
    end if;
    
    insert into ai_conversations  
              ( ai_agent_id
              , ai_service_id
              , creation_ts
              , model
              , tools
              , execution_type
              , history_mode
              , status )
      values  ( p_ai_agent
              , p_ai_service_id
              , systimestamp
              , p_model 
              , p_tools
              , p_execution_type 
              , p_history_mode
              , l_conv_status_created )
      returning ai_conversation_id 
           into l_ai_conversation_id;

    apex_debug.info('conversation created: %s', l_ai_conversation_id);

    commit;
    
    return l_ai_conversation_id;

    exception 
      when others then 
        rollback;
        raise;
  end create_conversation;

  ----------------------------------------------------------------------------------------

  function get_conversation_status( p_ai_conversation_id  ai_conversations.ai_conversation_id%type )
    return varchar2
  as 
    l_status  ai_conversations.status%type;
  begin
    select status 
      into l_status 
      from ai_conversations
      where ai_conversation_id = p_ai_conversation_id;
    return l_status;
  end get_conversation_status;

  ----------------------------------------------------------------------------------------

  procedure update_conversation_status ( p_ai_conversation_id  ai_conversations.ai_conversation_id%type
                                       , p_status              ai_conversations.status%type )
  as 
    pragma autonomous_transaction;
  begin
    update ai_conversations 
       set status = upper(p_status)
       where ai_conversation_id = p_ai_conversation_id;
    commit;
    exception 
      when others then 
        rollback;
        raise;
  end update_conversation_status;                          

  ----------------------------------------------------------------------------------------
  
  ----------------------------------------------------------------------------------------

  procedure continue_conversation( p_ai_conversation_id  ai_conversations.ai_conversation_id%type
                                 , p_user_message        clob )
  as 
    rec_ai_conversation  ai_conversations%rowtype;
    l_prompt json_object_t;
  begin 
    apex_debug.enter( 'continue_conversation'
                    , 'p_ai_conversation_id', p_ai_conversation_id
                    , 'p_user_message', dbms_lob.substr(p_user_message, 4000, 1));

    select * 
      into rec_ai_conversation
      from ai_conversations
      where ai_conversation_id = p_ai_conversation_id;

    ai_prompt.prepare( p_prompt_io  => l_prompt
                     , p_model      => rec_ai_conversation.model
                     , p_tools      => rec_ai_conversation.tools
                     , p_ai_conversation_id => p_ai_conversation_id );

    ai_prompt.update_prompt( p_prompt_io => l_prompt
                           , p_message   => ai_prompt.build_message( p_role => ai_constants.c_ai_role_user
                                                                   , p_content => p_user_message )
                           , p_ai_conversation_id => p_ai_conversation_id );
    
    -- send out the updated prompt
    apex_debug.trace('generated prompt:');
    apex_debug.log_long_message(l_prompt.to_clob);

    ai_agent.send_prompt( p_ai_conversation_id  => p_ai_conversation_id
                        , p_prompt              => l_prompt );

    exception 
      when others then
        if ai_error.is_in_custom_error_range( p_sqlcode => SQLCODE ) then
          ai_error.handle( p_sqlcode   => SQLCODE
                         , p_errormsg  => SQLERRM );
        else 
          raise;
        end if;
  end continue_conversation;     

end ai_conv;
/