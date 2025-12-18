create or replace function m_ai_agent_tools(p_ai_agent_id  number)
  return varchar2
  sql_macro 
is
 begin
  return q'{ select 
            json_arrayagg( t.json_val returning clob pretty ) as tool_definition
            from ai_agents a
            join ai_agent_tools at on a.ai_agent_id = at.ai_agent_id
            join v_tool_definitions t on at.ai_tool_id = t.ai_tool_id
            where a.ai_agent_id = p_ai_agent_id }';
end;
/