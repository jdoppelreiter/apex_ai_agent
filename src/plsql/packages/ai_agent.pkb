create or replace package body ai_agent as

  function get_version return varchar2 is
  begin
    return c_version;
  end get_version;
  
  ----------------------------------------------------------------------------------------

  function is_in_custom_error_range( p_sqlcode number )
    return boolean
  as 
  begin
    return (p_sqlcode between -20500 and -20000);
  end is_in_custom_error_range;

  procedure handle_error( p_sqlcode   number
                        , p_errormsg  clob )
  as 
    l_message    clob;
  begin

    apex_debug.enter( 'handle_error'
                    , 'p_sqlcode', p_sqlcode
                    , 'p_errormsg', dbms_lob.substr(p_errormsg,4000,1));

    case p_sqlcode
      when e_no_model_in_ai_service_int then 
        l_message := 'No Default AI Service found';
      when e_not_implemented_collections_int then 
        l_message := 'collection storage not supported yet, use table storage instead';
      when e_prompt_arg_not_translateable_int then
        l_message := 'parameter in tool call not translateable'; 
      when e_message_empty_int then 
        l_message := 'all parameters of message are empty';
      when e_conv_status_wrong_int then 
        l_message := 'conversation in wrong status';
      else 
        l_message := 'Unhandled custom error';
    end case;
    
    raise_application_error( p_sqlcode, l_message );

  end handle_error;
  
  ----------------------------------------------------------------------------------------

  procedure process_output(p_clob clob) is
  begin
    null;
  end process_output;

  ----------------------------------------------------------------------------------------

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
  begin
    apex_debug.enter( 'create_conversation'
                    , 'p_ai_agent', p_ai_agent
                    , 'p_ai_service_id', p_ai_service_id
                    , 'p_model', p_model
                    , 'p_tools', dbms_lob.substr(p_tools, 4000,1)
                    , 'p_execution_type', p_execution_type
                    , 'p_history_mode', p_history_mode );

    if p_history_mode = ai_agent.c_history_mode_collection then 
      raise e_not_implemented_collections;
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
              , ai_agent.c_conv_status_created )
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

  procedure add_to_history( p_ai_conversation_id   ai_conversations.ai_conversation_id%type
                          , p_msg_type             ai_conversation_histories.msg_type%type default ai_agent.c_conv_msg_type_message
                          , p_msg_direction        ai_conversation_histories.msg_direction%type default ai_agent.c_conv_msg_direction_out
                          , p_msg_role             ai_conversation_histories.msg_role%type
                          , p_content              ai_conversation_histories.content%type)
  as
    pragma autonomous_transaction;
  begin
    insert into ai_conversation_histories
              ( ai_conversation_id
              , creation_ts
              , msg_type 
              , msg_direction
              , msg_role 
              , content)
      values  ( p_ai_conversation_id
              , systimestamp
              , p_msg_type
              , p_msg_direction
              , upper(p_msg_role)
              , p_content );
    commit;

    exception 
      when others then 
        rollback;
        raise;
  end add_to_history;

  ----------------------------------------------------------------------------------------

  function get_message_history( p_ai_conversation_id  ai_conversations.ai_conversation_id%type )
    return json_array_t 
  as
    l_messages  json_array_t;
  begin
    l_messages := json_array_t();

    for rec in (select content 
                  from ai_conversation_histories
                  where ai_conversation_id = p_ai_conversation_id 
                  order by creation_ts asc )
    loop
      l_messages.append( json_object_t.parse(rec.content) );
    end loop;
    return l_messages;
  end get_message_history;
  
  ----------------------------------------------------------------------------------------

  function has_history_entries( p_ai_conversation_id  ai_conversations.ai_conversation_id%type )
    return boolean
  as  
    l_count  pls_integer;
  begin
    select count(*) 
      into l_count
      from ai_conversation_histories 
      where ai_conversation_id = p_ai_conversation_id;
    return (l_count > 0);
  end has_history_entries;

  ----------------------------------------------------------------------------------------

  procedure build_prompt( p_prompt_io  in out nocopy json_object_t 
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

    if p_ai_conversation_id is not null and has_history_entries( p_ai_conversation_id => p_ai_conversation_id ) then 
      -- load previous stored messages
      p_prompt_io.put('messages', get_message_history( p_ai_conversation_id => p_ai_conversation_id));
    else 
      p_prompt_io.put('messages', json_array_t());
    end if;

    apex_debug.info('prompt built (lenght: %s)', dbms_lob.getlength(p_prompt_io.to_clob));
    apex_debug.trace('prompt: %s', dbms_lob.substr(p_prompt_io.to_clob, 4000,1));

  end build_prompt;

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
      raise e_message_empty;
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



  ----------------------------------------------------------------------------------------

  procedure update_prompt( p_prompt_io  in out nocopy json_object_t
                         , p_message                  json_object_t 
                         , p_ai_conversation_id       ai_conversation_histories.ai_conversation_id%type default null
                         , p_msg_direction            ai_conversation_histories.msg_direction%type default ai_agent.c_conv_msg_direction_out)
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
      add_to_history( p_ai_conversation_id   => p_ai_conversation_id
                    , p_msg_type             => ai_agent.c_conv_msg_type_message
                    , p_msg_direction        => p_msg_direction
                    , p_msg_role             => p_message.get_string('role')
                    , p_content              => p_message.to_clob);
    end if;

    apex_debug.info('prompt updated (lenght: %s)', dbms_lob.getlength(p_prompt_io.to_clob));
    apex_debug.trace('prompt: %s', dbms_lob.substr(p_prompt_io.to_clob, 4000,1));

  end update_prompt;

  ----------------------------------------------------------------------------------------

  function get_ai_service_default_model( p_ai_service_id  ai_services.ai_service_id%type )
    return varchar2
  as
    l_model  ai_services.model%type;
  begin
    if p_ai_service_id is null then 
      return null;
    end if;

    select model 
      into l_model 
      from ai_services 
      where ai_service_id = p_ai_service_id;
    
    return l_model;

    exception 
      when no_data_found then
        raise e_no_model_in_ai_service;
  end get_ai_service_default_model;
  
  ----------------------------------------------------------------------------------------

  function get_agent_tools( p_ai_agent_id  ai_agents.ai_agent_id%type )
    return clob
  as
    l_tools clob;
  begin

    select tool_definition 
      into l_tools 
      from m_ai_agent_tools( p_ai_agent_id => p_ai_agent_id );
    
    return l_tools;

    exception 
      when no_data_found then 
        return '[]';

  end get_agent_tools;

  ----------------------------------------------------------------------------------------

  function get_endpoint( p_ai_service_id  ai_services.ai_service_id%type
                       , p_endpoint_code  ai_service_custom_endpoints.code%type )
    return varchar2
  as
    l_base_url  ai_services.base_url%type;
    l_url       varchar2(1000);
    l_endpoint  varchar2(400);
  begin

    apex_debug.enter( 'get_endpoint' 
                    , 'p_ai_service_id', to_char(p_ai_service_id)
                    , p_endpoint_code, p_endpoint_code );

    select ais.base_url, aice.endpoint 
      into l_base_url, l_endpoint
      from ai_services ais 
      left join ai_service_custom_endpoints aice on ais.ai_service_id = aice.ai_service_id and aice.code = p_endpoint_code
      where ais.ai_service_id = p_ai_service_id;

    l_url := l_base_url || coalesce(l_endpoint, ai_agent.c_http_endpoint_completions);

    apex_debug.trace( 'url: %s', l_url );
    
    return l_url;
    
  end get_endpoint;                  

  ----------------------------------------------------------------------------------------

  procedure exec_function ( p_func_call    in  varchar2
                          , p_binds        in  t_clob_list
                          , p_result_clob  out clob )
  as
    l_cursor   integer;
    l_status   integer;
    l_res clob := empty_clob();
  begin

    apex_debug.enter( 'exec_function'
                    , 'p_func_call', p_func_call
                    , 'p_binds.count', p_binds.count );

    l_cursor := dbms_sql.open_cursor;

    dbms_sql.parse(
      l_cursor,
      'begin :res := ' || p_func_call || '; end;',
      dbms_sql.native
    );
    
    dbms_sql.bind_variable(l_cursor, ':res', l_res);

    if p_binds.count > 0 then
      for i in 1 .. p_binds.count loop
        dbms_sql.bind_variable(l_cursor, ':x' || i, p_binds(i));
      end loop;
    end if;
  
    l_status := dbms_sql.execute(l_cursor);

    dbms_sql.variable_value(l_cursor, ':res',        p_result_clob);

    dbms_sql.close_cursor(l_cursor);

  exception
    when others then
      if dbms_sql.is_open(l_cursor) then
        dbms_sql.close_cursor(l_cursor);
      end if;
      raise;
  end exec_function;

  ----------------------------------------------------------------------------------------

  procedure process_prompt( p_ai_conversation_id  ai_conversations.ai_conversation_id%type
                          , p_prompt         clob )
  as 
    rec_ai_conversation  ai_conversations%rowtype;

    l_tool_calls        json_array_t;
    l_tool_jo           json_object_t;
    l_tool_id           varchar2(100);
    l_tool_function_jo  json_object_t;
    l_function_name     varchar2(200);
    l_function_args     json_object_t;
    l_function_db_name  varchar2(100);
    l_function_input    t_clob_list;
    l_function_input_parameters  apex_application_global.vc_arr2;

    l_function_call_result  clob;
    l_tool_output           clob;
    l_prompt_content        clob;

    l_prompt_out  json_object_t;
    
    ------ <inline functions> -------
    procedure i_read_tool_info 
    as
    begin
      l_tool_id := l_tool_jo.get_string('id');
      apex_debug.trace('tool id: %s', l_tool_id);

      l_tool_function_jo  := treat(l_tool_jo.get('function') as json_object_t);  
      l_function_name     := l_tool_function_jo.get_string('name');
      apex_debug.trace('function name: %s', l_function_name);

      l_function_args := json_object_t.parse(l_tool_function_jo.get_clob('arguments'));
      apex_debug.trace('l_function_args: %s', l_function_args.to_clob);
    end i_read_tool_info;

    procedure i_prepare_arguments_list
    as 
      l_args_jo   json_object_t;
      l_keys      json_key_list;
      l_element   json_element_t;
    begin
      l_function_input := ai_agent.t_clob_list();

      l_keys := l_function_args.get_keys;

      if l_keys is null then
        return;
      end if;

      for i in 1 .. l_keys.count loop

        l_function_input.extend;    
        l_element := l_function_args.get( l_keys(i) );
        l_function_input_parameters(i) := ':x'||i;

        if l_element.is_string then
          l_function_input(i) := json_scalar_t(l_element).to_string;
        elsif l_element.is_number then
          l_function_input(i) := to_char(json_scalar_t(l_element).to_number);
        elsif l_element.is_boolean then
          l_function_input(i) := case when json_scalar_t(l_element).to_boolean then 'true' else 'false' end;
        elsif l_element.is_null then
          l_function_input(i) := 'null';
        elsif l_element.is_array then
          l_function_input(i) := json_array_t(l_element).to_string;
        elsif l_element.is_object then
          l_function_input(i) := json_object_t(l_element).to_string;
        else
          raise ai_agent.e_prompt_arg_not_translateable;
        end if;

      end loop;

    end i_prepare_arguments_list;

    function i_get_message_count
      return pls_integer
    as
      l_count  pls_integer; 
    begin 
      select count(*) 
        into l_count
        from ai_conversation_histories 
        where ai_conversation_id = p_ai_conversation_id;
      return l_count;
    end i_get_message_count;
    ------ </inline functions> -------
  begin

    apex_debug.enter( 'process_prompt' 
                    , 'p_ai_conversation_id', p_ai_conversation_id
                    , 'p_prompt', dbms_lob.substr(p_prompt, 100, 1) );
    apex_debug.log_long_message(p_prompt);

    if i_get_message_count > ai_agent.c_max_conv_message_count then 
      update_conversation_status( p_ai_conversation_id => p_ai_conversation_id
                                , p_status => 'MAX_MESSAGES_REACHED' );
      return;
    end if;

    select * 
      into rec_ai_conversation
      from ai_conversations
      where ai_conversation_id = p_ai_conversation_id;

    -- investigate prompt
    -- if the last prompt is the "finish marker" end the conversation
    -- if the max message count is reached end the conversation
    -- if the prompt includes a function call execute the corresponding function
    -- if the prompt includes a message for the user set status "USER_QUESTION" and pause conversation

    -- add the tool calls first to the history 
    build_prompt( p_prompt_io  => l_prompt_out
                , p_model      => rec_ai_conversation.model
                , p_tools      => rec_ai_conversation.tools 
                , p_ai_conversation_id => p_ai_conversation_id);

    l_tool_calls := treat(
                      treat(
                        treat(json_object_t.parse(p_prompt).get_array('choices').get(0) as json_object_t)
                        .get('message')
                        as json_object_t
                      ).get('tool_calls')
                      as json_array_t
                    );
    
    if l_tool_calls is not null and l_tool_calls.get_Size > 0 then
      update_prompt( p_prompt_io => l_prompt_out
                  , p_message   => build_message( p_role       => ai_agent.c_ai_role_assistant
                                                , p_tool_calls => l_tool_calls )
                  , p_ai_conversation_id => p_ai_conversation_id 
                  , p_msg_direction      => ai_agent.c_conv_msg_direction_in );
    end if;

    for rec in ( select tool_call
                  from json_table( p_prompt, '$.choices[*].message.tool_calls[*]'
                          columns ( tool_call clob format json path '$' ))
               )
    loop

      apex_debug.info('l_tool_call: %s', rec.tool_call);
      l_tool_jo := json_object_t.parse(rec.tool_call);

      i_read_tool_info;
      
      i_prepare_arguments_list;
    
      select function_name 
        into l_function_db_name
        from ai_tools 
        where upper(identifier) = upper(l_function_name);
        
      apex_debug.info('function: %s - Parameter Count: %s', l_function_db_name, l_function_input.count );
      
      exec_function( p_func_call   => l_function_db_name
                                      ||'('
                                      || apex_string.table_to_string(l_function_input_parameters,',')
                                      ||')'
                   , p_binds       => l_function_input
                   , p_result_clob => l_function_call_result );

      apex_debug.trace('function call result:');
      apex_debug.log_long_message( l_function_call_result );

      -- add the tool call and the tool result to the history
      -- build the complete message-stack before and add new messages at the end
      update_prompt( p_prompt_io => l_prompt_out
                   , p_message   => build_message( p_role         => ai_agent.c_ai_role_tool
                                                 , p_tool_call_id => l_tool_id
                                                 , p_content      => l_function_call_result )
                   , p_ai_conversation_id => p_ai_conversation_id );
      
     

    end loop;

    -- check now if there is some other information ("content" in the prompt)
    -- this is either the end of the conversaton (special prompt) or a question for the user. 
    -- if it's combined with a tool call the functions are executed first before the user question is registered
    l_prompt_content := treat(
                          treat(json_object_t.parse(p_prompt).get_array('choices').get(0) as json_object_t)
                          .get('message')
                          as json_object_t
                        ).get_clob('content');

    apex_debug.trace('prompt_content: ');
    apex_debug.log_long_message(l_prompt_content);

    if dbms_lob.getlength(l_prompt_content)>0 then 

       update_prompt( p_prompt_io => l_prompt_out
                    , p_message   => build_message( p_role    => ai_agent.c_ai_role_assistant
                                                  , p_content => l_prompt_content )
                    , p_ai_conversation_id => p_ai_conversation_id 
                    , p_msg_direction      => ai_agent.c_conv_msg_direction_in );

      if l_prompt_content like '%##FINISHED##%' then
        update_conversation_status( p_ai_conversation_id => p_ai_conversation_id
                                  , p_status             => ai_agent.c_conv_status_finished );

        return;
      else 
        update_conversation_status( p_ai_conversation_id => p_ai_conversation_id
                                  , p_status             => ai_agent.c_conv_status_user_question );
      end if;

      return;

    end if;

    -- send out the updated prompt
    apex_debug.trace('send new prompt:');
    apex_debug.log_long_message(l_prompt_out.to_clob);

    send_prompt( p_ai_conversation_id  => p_ai_conversation_id
               , p_prompt              => l_prompt_out );

  end process_prompt;

  ----------------------------------------------------------------------------------------

  procedure send_prompt( p_ai_conversation_id  ai_conversations.ai_conversation_id%type
                       , p_prompt         json_object_t )
  as  
    rec_ai_conversation  ai_conversations%rowtype;
    l_response      clob;
  begin

    select * 
      into rec_ai_conversation 
      from ai_conversations 
      where ai_conversation_id = p_ai_conversation_id; 

    apex_web_service.clear_request_headers;
    apex_web_service.g_request_headers(1).name := 'Content-Type';
    apex_web_service.g_request_headers(1).value := 'application/json';

    for rec in (select rownum+1 as rn, header_name, header_value 
                  from ai_service_additional_headers 
                  where ai_service_id = rec_ai_conversation.ai_service_id )
    loop
      apex_web_service.g_request_headers(rec.rn).name := rec.header_name;
      apex_web_service.g_request_headers(rec.rn).value := rec.header_value;
    end loop;                      
    
    apex_debug.trace('prompt:');
    apex_debug.log_long_message(p_prompt.to_clob);
    l_response := apex_web_service.make_rest_request( p_url          => get_endpoint( p_ai_service_id => rec_ai_conversation.ai_service_id
                                                                                    , p_endpoint_code => ai_agent.c_http_endpoint_code_completions ) ,
                                                      p_http_method  => ai_agent.c_http_method_completion ,
                                                      p_body         => p_prompt.to_clob );      

    ai_agent.process_prompt( p_ai_conversation_id => p_ai_conversation_id, p_prompt  => l_response );

  end send_prompt;

  ----------------------------------------------------------------------------------------

  function start_agent(  p_ai_agent_id     ai_agents.ai_agent_id%type
                       , p_execution_type  ai_conversations.execution_type%type default ai_agent.c_conv_exec_type_user
                       , p_ai_service_id   ai_services.ai_service_id%type default null
                       , p_model           ai_services.model%type default null
                       , p_system_prompt   ai_agents.system_prompt%type default null
                       , p_user_prompt     clob default null -- text
                       , p_tools           clob default null -- json array
                       , p_history_mode    ai_conversations.history_mode%type default ai_agent.c_history_mode_table ) -- TABLE / COLLECTION 
    return ai_conversations.ai_conversation_id%type
  as 
    rec_ai_agent          ai_agents%rowtype;
    l_ai_conversation_id  ai_conversations.ai_conversation_id%type;
    l_prompt              json_object_t;
    l_ai_service_id   ai_services.ai_service_id%type;
    l_model           ai_services.model%type;      
    l_tools           clob;
  begin

     apex_debug.enter('start_agent'
                    , 'p_ai_agent_id', p_ai_agent_id
                    , 'p_execution_type', p_execution_type
                    , 'p_ai_service_id', p_ai_service_id
                    , 'p_model', p_model
                    , 'p_system_prompt', p_system_prompt
                    , 'p_user_prompt', p_user_prompt
                    , 'p_tools', p_tools
                    , 'p_history_mode', p_history_mode);

    -- load settings for ai agent
    select * 
      into rec_ai_agent 
      from ai_agents
      where ai_agent_id = p_ai_agent_id;

    l_ai_service_id := coalesce( p_ai_service_id
                               , rec_ai_agent.ai_service_id );
    l_model         := coalesce( p_model
                               , get_ai_service_default_model( p_ai_service_id => p_ai_service_id )
                               , get_ai_service_default_model( rec_ai_agent.ai_service_id ) );
    l_tools         := coalesce( p_tools
                               , get_agent_tools( p_ai_agent_id => p_ai_agent_id ) );

    build_prompt( p_prompt_io  => l_prompt
                , p_model      => l_model
                , p_tools      => l_tools );
    
    l_ai_conversation_id := create_conversation( p_ai_agent       => p_ai_agent_id
                                               , p_ai_service_id  => l_ai_service_id
                                               , p_model          => l_model
                                               , p_tools          => l_tools
                                               , p_execution_type => p_execution_type
                                               , p_history_mode   => p_history_mode );

    
    update_prompt( p_prompt_io => l_prompt
                 , p_message   => build_message( p_role => ai_agent.c_ai_role_system
                                               , p_content => ai_agent.c_master_prompt_end_task )
                 , p_ai_conversation_id => l_ai_conversation_id );
                
    if p_system_prompt is not null or rec_ai_agent.system_prompt is not null then 
      update_prompt( p_prompt_io => l_prompt
                   , p_message   => build_message( p_role => ai_agent.c_ai_role_system
                                                 , p_content => coalesce(p_system_prompt, rec_ai_agent.system_prompt))
                   , p_ai_conversation_id => l_ai_conversation_id );
    end if;

    -- developer prompt is not exposed to the api call (and could also be excluded from the history with package parameter)
    if rec_ai_agent.developer_prompt is not null then
      update_prompt( p_prompt_io => l_prompt
                   , p_message   => build_message( p_role    => ai_agent.c_ai_role_developer
                                                 , p_content => rec_ai_agent.developer_prompt )
                   , p_ai_conversation_id => case when c_archive_developer_prompt then l_ai_conversation_id else null end );
    end if;

    if p_user_prompt is not null then 
      update_prompt( p_prompt_io => l_prompt
                   , p_message   => build_message( p_role    => ai_agent.c_ai_role_user
                                                 , p_content => p_user_prompt )
                   , p_ai_conversation_id => l_ai_conversation_id );
    end if;

    -- send request to ai service
    update_conversation_status( p_ai_conversation_id => l_ai_conversation_id
                              , p_status             => ai_agent.c_conv_status_running );

    send_prompt( p_ai_conversation_id  => l_ai_conversation_id
               , p_prompt              => l_prompt );

    return l_ai_conversation_id;

    exception 
      when others then
        if is_in_custom_error_range( p_sqlcode => SQLCODE ) then
          handle_error( p_sqlcode   => SQLCODE
                      , p_errormsg  => SQLERRM );
        else 
          raise;
        end if;

  end start_agent;

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

  function get_user_question( p_ai_conversation_id  ai_conversations.ai_conversation_id%type )
    return clob
  as 
    l_status   ai_conversations.status%type;
    l_content_clob  ai_conversation_histories.content%type;
    l_content_jo    json_object_t;
  begin

    select status 
      into l_status 
      from ai_conversations 
      where ai_conversation_id = p_ai_conversation_id;

    if l_status != ai_agent.c_conv_status_user_question then
      raise e_conv_status_wrong;
    end if;

    select content
      into l_content_clob
      from ai_conversation_histories
    where ai_conversation_id = p_ai_conversation_id
    order by creation_ts desc
    fetch first 1 row only;

    l_content_jo := json_object_t.parse(l_content_clob);

    return l_content_jo.get_clob('content');

    exception 
      when others then
        if is_in_custom_error_range( p_sqlcode => SQLCODE ) then
          handle_error( p_sqlcode   => SQLCODE
                      , p_errormsg  => SQLERRM );
        else 
          raise;
        end if;
        
  end get_user_question;
  
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

    build_prompt( p_prompt_io  => l_prompt
                , p_model      => rec_ai_conversation.model
                , p_tools      => rec_ai_conversation.tools
                , p_ai_conversation_id => p_ai_conversation_id );

    update_prompt( p_prompt_io => l_prompt
                 , p_message   => build_message( p_role => ai_agent.c_ai_role_user
                                               , p_content => p_user_message )
                 , p_ai_conversation_id => p_ai_conversation_id );
    
    -- send out the updated prompt
    apex_debug.trace('generated prompt:');
    apex_debug.log_long_message(l_prompt.to_clob);

    send_prompt( p_ai_conversation_id  => p_ai_conversation_id
               , p_prompt              => l_prompt );

    exception 
      when others then
        if is_in_custom_error_range( p_sqlcode => SQLCODE ) then
          handle_error( p_sqlcode   => SQLCODE
                      , p_errormsg  => SQLERRM );
        else 
          raise;
        end if;
  end continue_conversation;                     

end ai_agent;
/
