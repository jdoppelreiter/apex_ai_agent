create or replace force view v_tool_definitions as
  select 
    t.ai_tool_id,
      json_object('type' VALUE 'function',
                  'function' VALUE
         json_object( 'name': t.identifier, 
                            'description': t.description,
                            'parameters': t.parameters format json,
                             'required': t.parameters_required format json,
                             'additionalProperties': 'false'
    
                            returning json )
          returning clob pretty )
         as json_val
  from ai_tools t 
  ;