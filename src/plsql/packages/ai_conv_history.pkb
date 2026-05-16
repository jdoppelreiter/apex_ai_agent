create or replace package body ai_conv_history 
as 

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

    if l_status != ai_constants.c_conv_status_user_question then
      raise ai_error.e_conv_status_wrong;
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
        if ai_error.is_in_custom_error_range( p_sqlcode => SQLCODE ) then
          ai_error.handle( p_sqlcode   => SQLCODE
                         , p_errormsg  => SQLERRM );
        else 
          raise;
        end if;
        
  end get_user_question;

  ----------------------------------------------------------------------------------------

  procedure add_to_history( p_ai_conversation_id   ai_conversations.ai_conversation_id%type
                          , p_msg_type             ai_conversation_histories.msg_type%type default ai_constants.c_conv_msg_type_message
                          , p_msg_direction        ai_conversation_histories.msg_direction%type default ai_constants.c_conv_msg_direction_out
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

end ai_conv_history;
