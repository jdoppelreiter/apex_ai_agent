declare 
  l_ai_service_id_local   ai_services.ai_service_id%type;
  l_ai_service_id_openai  ai_services.ai_service_id%type;
  l_ai_tool_id_url  ai_tools.ai_tool_id%type;
  l_ai_tool_id_kb   ai_tools.ai_tool_id%type;
  l_ai_agent_id_kb  ai_agents.ai_agent_id%type;
begin
  
  insert into ai_services( name, identifier, description, base_url, model )
    values ( 'LM Studio', 'LM_STUDIO', 'local setup', 'http://host.containers.internal:1234', 'openai/gpt-oss-20b')
    returning ai_service_id into l_ai_service_id_local;
    
  insert into ai_services( name, identifier, description, base_url, model )
    values ( 'OpenAI', 'OPENAI', 'cloud access', 'https://api.openai.com', 'gpt-5-mini')
    returning ai_service_id into l_ai_service_id_openai;
  
  insert into ai_service_additional_headers (ai_service_id, header_name, header_value)
    values( l_ai_service_id_openai, 'Authorization', 'Bearer ...');
  insert into ai_service_additional_headers (ai_service_id, header_name, header_value)
    values( l_ai_service_id_openai, 'OpenAI-Organization', 'org-...');
  insert into ai_service_additional_headers (ai_service_id, header_name, header_value)
    values( l_ai_service_id_openai, 'OpenAI-Project', 'proj_...');
  
  insert into ai_tools ( name, description, identifier, function_name, parameters, parameters_required)
    values('Get Data from URL','Gets Data from url','GET_DATA_FROM_URL','ai_tool.get_data_from_url'
          ,'{
                "type" : "object",
                "properties" :
                {
                  "url": {
                      "type": "string",
                      "description": "URL of the website"
                    }
                }
          }'
        , '["url"]' )
      returning ai_tool_id into l_ai_tool_id_url;
      
  insert into ai_tools ( name, description, identifier, function_name, parameters, parameters_required)
    values('Knowledge Base - Article','Creates a new article in the knowledge base','KB_CREATE','ai_tool.kb_create'
          ,'{
                "type" : "object",
                "properties" :
                {
                  "title" :
                  {
                    "type" : "string",
                    "description" : "Title of the article"
                  },
                  "content" :
                  {
                    "type" : "string",
                    "description" : "Content of the article in Markdown format"
                  }
                }
          }'
        , '["title","content"]' )
      returning ai_tool_id into l_ai_tool_id_kb;
  
  insert into ai_agents( name, description, system_prompt, default_history_mode, ai_service_id, developer_prompt )
    values( 'Knowledge Base Article Management', 'Creates / Updates Articles'
          , 'You are an AI Agent to keep an internal Knowledge Base updated. 
              Your task is to summarise text and add it to the current base. 
              You should use markdown for formatting text. 
              The audience for this articles are technicians. 
              Be precise and dont add unnecessary context.
              Take any text the content the user is providing and create a knowledge base article out of it.'
          , 'TABLE'
          , l_ai_service_id_local
          , null)
    returning ai_agent_id into l_ai_agent_id_kb;
  
  insert into ai_agent_tools( ai_agent_id, ai_tool_id )
    values( l_ai_agent_id_kb, l_ai_tool_id_url);

  insert into ai_agent_tools( ai_agent_id, ai_tool_id )
    values( l_ai_agent_id_kb, l_ai_tool_id_kb);
  
  commit;
end;
/