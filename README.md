# Installation

deployment/install_core_scratch.sql - Installs all necessary database objects (tables, views, packages, ...)
deployment/install_demo_data.sql - Installs a demo dataset to be used for configuration demonstration + dummy functions for tool definition (ai_tool - package)

deployment/uninstall.sql - Removes all objects from database. Includes configuration and conversation histories

# Test case collection

It's recommended to install the sample data set for getting an overview of the configuration settings

deployment/test_utils/sample_calls.sql

provides sample scripts for: 
- starting an agent
- getting the status of the conversation
- get the user question of a conversation with status USER_QUESTION
- updating conversation with user prompt

# Agent Start

Parameters that set to "default null" can be used to overrule the configuration of the agent. 
E.g. executing the Agent Call with a different model or service

Package: AI_AGENT
Function: START_AGENT
Parameters: 
  - p_ai_agent_id     ai_agents.ai_agent_id%type
  - p_execution_type  ai_conversations.execution_type%type default ai_agent.c_conv_exec_type_user
  - p_ai_service_id   ai_services.ai_service_id%type default null
  - p_model           ai_services.model%type default null
  - p_system_prompt   ai_agents.system_prompt%type default null
  - p_user_prompt     clob default null 
  - p_tools           clob default null -- json array
  - p_history_mode    ai_conversations.history_mode%type default ai_agent.c_history_mode_table ) -- TABLE / COLLECTION 
Returns: 
  - ai_conversations.ai_conversation_id%type 

## Restrictions
  - p_history_mode: Only *TABLE* is currently supported

# Tables

## ai_services
Service Definition for Inference API

## ai_service_additional_headers
Used for http request header that needs to be send to the API. E.g.: for OpenAI - Bearer Token, Project, Organisation Information
An example is installed with the demo dataset

## ai_service_custom_endpoints
Possibility for custom endpoints in case the "standard" API endpoint for completion is different. 
Standard: /v1/chat/completions

## ai_tools
Definition of tools inside the database. Function Name must be fully qualified if necessary (Schema, Package)
*parameters* are added as json object, *parameters_required* as json array

## ai_agents
Agent definition. 
*ai_service_id* is used as default service for the agent. Can be overwritten with the API Call

## ai_agent_tools
Assigns tools to agents

## ai_conversations
Every Agent Start creates a new conversation including the settings of the setup for Service and used Tools

## ai_conversation_histories
Stores all activities between System, User and AI Service
