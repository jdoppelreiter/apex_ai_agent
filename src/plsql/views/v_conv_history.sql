create or replace force view v_conv_history as 
with t_conv as (select * from ai_conversation_histories h)
   , t_in as (
        select ai_conversation_history_id
             , ai_conversation_id 
             , id as tool_id 
             , name
             , msg_role
             , msg_direction
             , creation_ts
             , json_serialize(jarguments returning clob pretty) AS content
          from t_conv
             , json_table(content, '$.tool_calls[*]'
                          columns (
                                    id        varchar2 path '$.id',
                                    name      varchar2 path '$.function.name',
                                    jarguments clob     path '$.function.arguments'
                                  )
                         )
          where msg_role = 'ASSISTANT' )
   , t_finished as (
          select ai_conversation_history_id
               , ai_conversation_id 
               , null as tool_id
               , null as name
               , msg_role
               , msg_direction
               , creation_ts
               , 'FINISHED' as content
            from t_conv
            where msg_role = 'ASSISTANT' 
              and json_value(content, '$.content') = '##FINISHED##'
    )
  , t_out as (
          select ai_conversation_history_id
               , ai_conversation_id 
               , json_value(content,'$.tool_call_id') as tool_id
               , msg_role
               , msg_direction
               , creation_ts
               , json_value( content, '$.content') as content
            from t_conv 
            where msg_role in ('SYSTEM','USER','TOOL')
    )
select * 
  from (
          select ai_conversation_history_id, ai_conversation_id, tool_id, creation_ts, msg_direction, msg_role, to_clob(content) as content
            from t_out
          union all
          select ai_conversation_history_id, ai_conversation_id, tool_id, creation_ts, msg_direction, msg_role, to_clob(content)
            from t_finished
          union all
          select ai_conversation_history_id, ai_conversation_id, tool_id, creation_ts, msg_direction, msg_role, to_clob('arguments:'||chr(10)||content)
            from t_in
  );
/