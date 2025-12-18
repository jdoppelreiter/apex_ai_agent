prompt # drop tables
drop table ai_conversation_histories;
drop table ai_conversations;
drop table ai_agent_tools;
drop table ai_agents;
drop table ai_tools;
drop table ai_service_custom_endpoints;
drop table ai_service_additional_headers;
drop table ai_services;

prompt # drop macros
drop function m_ai_agent_tools;

prompt # drop views 
drop view v_tool_definitions;

prompt # drop packages 
drop package ai_agent;
drop package ai_tool;