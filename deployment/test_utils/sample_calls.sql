/* Start a new agent 
 * parameters left null using the configured values
 * when setting parameters it will override the configuration
 *
 * This demo call will execute the first agent (id 1) and provide a url for the demo case
 */
declare
  p_ai_agent_id number;
  p_execution_type varchar2(120);
  p_ai_service_id number;
  p_model varchar2(800); 
  p_system_prompt clob;
  p_user_prompt clob;
  p_tools clob;
  p_history_mode varchar2(100);

 l_returnvalue  number;
begin
  p_ai_agent_id := 1;
  p_execution_type := ai_agent.c_conv_exec_type_user;
  p_ai_service_id := null;
  p_model := null;  
  p_system_prompt := null;
  p_user_prompt := 'https://oracle.com/12kcx0ß124mdf.html';
  p_tools := null;
  p_history_mode := ai_agent.c_history_mode_table;

  l_returnvalue := ai_agent.start_agent(p_ai_agent_id => p_ai_agent_id,
                                        p_execution_type => p_execution_type,
                                        p_ai_service_id => p_ai_service_id,
                                        p_model => p_model,
                                        p_system_prompt => p_system_prompt,
                                        p_user_prompt => p_user_prompt,
                                        p_tools => p_tools,
                                        p_history_mode => p_history_mode);
  dbms_output.put_line('l_returnvalue = ' || l_returnvalue);
end;
/

/* Get current status of a conversation
 */
declare 
  p_ai_conversation_id number;
  l_status  varchar2(100);
begin

  p_ai_conversation_id := 2;

  l_status := ai_agent.get_conversation_status( p_ai_conversation_id => p_ai_conversation_id);

  dbms_output.put_line('l_status = ' || l_status);

end;
/

/* Get the last user question asked from the AI Agent
 */
declare 
  p_ai_conversation_id number;
  l_user_question  clob;
begin

  p_ai_conversation_id := 2;

  l_user_question := ai_agent.get_user_question( p_ai_conversation_id => p_ai_conversation_id);

  dbms_output.put_line('l_user_question = ' || l_user_question);

end;
/

/* Send an answer to an conversation that is current on-hold (Status: USER_QUESTION)
 */
declare
  p_ai_conversation_id number;
  p_user_message clob;
    
begin
  p_ai_conversation_id := 2;
  p_user_message := 'I have added it to the knowledge base';
  ai_agent.continue_conversation (  p_ai_conversation_id => p_ai_conversation_id,
                                    p_user_message => p_user_message) ;  
end;
/

