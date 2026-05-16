prompt --application/pages/page_00305
begin
--   Manifest
--     PAGE: 00305
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>1467387009598820
,p_default_application_id=>100
,p_default_id_offset=>0
,p_default_owner=>'AGENT'
);
wwv_flow_imp_page.create_page(
 p_id=>305
,p_name=>'Start Conversation'
,p_alias=>'START-CONVERSATION'
,p_page_mode=>'MODAL'
,p_step_title=>'Start Conversation'
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>2100407606326202693
,p_page_template_options=>'#DEFAULT#'
,p_dialog_resizable=>'Y'
,p_protection_level=>'C'
,p_page_component_map=>'23'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(2732077635080705)
,p_plug_name=>'Setup'
,p_region_template_options=>'#DEFAULT#:t-Region--noPadding:t-Region--removeHeader js-removeLandmark:t-Region--noBorder:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(4244355554150898)
,p_plug_name=>'Agent Tools'
,p_region_template_options=>'#DEFAULT#:t-Region--noPadding:t-Region--noBorder:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select ait.ai_tool_id',
'      ,ait.name',
'      ,ait.description',
'      ,ait.function_name',
'      ,ait.parameters',
'      ,ait.parameters_required',
'  from ai_tools ait ',
'  join ai_agent_tools aiat on ait.ai_tool_id = aiat.ai_tool_id',
'  where aiat.ai_agent_id = :P305_AI_AGENT'))
,p_lazy_loading=>false
,p_plug_source_type=>'NATIVE_CARDS'
,p_ajax_items_to_submit=>'P305_AI_AGENT'
,p_plug_query_num_rows_type=>'SCROLL'
,p_show_total_row_count=>false
,p_ai_enabled=>false
);
wwv_flow_imp_page.create_card(
 p_id=>wwv_flow_imp.id(2745604601166881)
,p_region_id=>wwv_flow_imp.id(4244355554150898)
,p_layout_type=>'GRID'
,p_title_adv_formatting=>false
,p_title_column_name=>'NAME'
,p_sub_title_adv_formatting=>false
,p_sub_title_column_name=>'DESCRIPTION'
,p_body_adv_formatting=>true
,p_body_html_expr=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Function: &FUNCTION_NAME.<br/>',
'Parameters required: &PARAMETERS_REQUIRED.'))
,p_second_body_adv_formatting=>false
,p_media_adv_formatting=>false
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(2733281526080717)
,p_button_sequence=>30
,p_button_name=>'Start'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Start'
,p_icon_css_classes=>'fa-play-circle'
,p_grid_new_row=>'N'
,p_grid_new_column=>'N'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(2734000118080725)
,p_branch_action=>'f?p=&APP_ID.:310:&SESSION.::&DEBUG.:310:P310_AI_CONVERSATION_ID:&P305_CONVERSATION_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_when_button_id=>wwv_flow_imp.id(2733281526080717)
,p_branch_sequence=>10
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(2732198636080706)
,p_name=>'P305_AI_AGENT'
,p_is_required=>true
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(2732077635080705)
,p_prompt=>'Agent'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name, ai_agent_id from ai_agents'
,p_lov_display_null=>'YES'
,p_cHeight=>1
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(2732379004080708)
,p_name=>'P305_MODEL'
,p_is_required=>true
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(2732077635080705)
,p_prompt=>'Model'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(2732422608080709)
,p_name=>'P305_SERVICE'
,p_is_required=>true
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(2732077635080705)
,p_prompt=>'Service'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name, ai_service_id from ai_services'
,p_lov_cascade_parent_items=>'P305_AI_AGENT'
,p_ajax_optimize_refresh=>'Y'
,p_cHeight=>1
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_lov_display_extra=>'NO'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(2733844970080723)
,p_name=>'P305_USER_PROMPT'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(2732077635080705)
,p_item_default=>'https://docs.oracle.com/en/database/oracle/apex/24.2/aeapi/APEX_DEBUG.html'
,p_prompt=>'User Prompt'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>30
,p_cHeight=>10
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'N',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(2733941122080724)
,p_name=>'P305_CONVERSATION_ID'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(2732077635080705)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(2734329807080728)
,p_name=>'P305_PROMPT'
,p_data_type=>'CLOB'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(2732077635080705)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(10475079820285740)
,p_name=>'P305_BG_PROCESS_ID'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(2732077635080705)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(2732542531080710)
,p_name=>'Set model'
,p_event_sequence=>10
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P305_SERVICE'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(2732621126080711)
,p_event_id=>wwv_flow_imp.id(2732542531080710)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_EXECUTE_PLSQL_CODE'
,p_attribute_01=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select max(model)',
'  into :P305_MODEL ',
'  from ai_services',
'  where ai_service_id = :P305_SERVICE;'))
,p_attribute_02=>'P305_SERVICE'
,p_attribute_03=>'P305_MODEL'
,p_attribute_04=>'N'
,p_attribute_05=>'PLSQL'
,p_wait_for_result=>'Y'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(2732929879080714)
,p_event_id=>wwv_flow_imp.id(2732542531080710)
,p_event_result=>'TRUE'
,p_action_sequence=>20
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(4244355554150898)
,p_attribute_01=>'N'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(2733575338080720)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Setup'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'  p_ai_agent_id number;',
'  p_execution_type varchar2(120);',
'  p_ai_service_id number;',
'  p_model varchar2(800); ',
'  p_system_prompt clob;',
'  p_user_prompt clob;',
'  p_tools clob;',
'  p_history_mode varchar2(100);',
'begin',
'  p_ai_agent_id := :P305_AI_AGENT;',
'  p_execution_type := ai_constants.c_conv_exec_type_user;',
'  p_ai_service_id := :P305_SERVICE;',
'  p_model := :P305_MODEL;  ',
'  p_system_prompt := null;',
'  p_user_prompt := :P305_USER_PROMPT;',
'  p_tools := null;',
'  p_history_mode := ai_constants.c_history_mode_table;',
'',
'  ai_agent.setup_run( p_ai_agent_id => p_ai_agent_id',
'                    , p_execution_type => p_execution_type',
'                    , p_ai_service_id => p_ai_service_id',
'                    , p_model => p_model',
'                    , p_system_prompt => p_system_prompt',
'                    , p_user_prompt => p_user_prompt',
'                    , p_tools => p_tools',
'                    , p_history_mode => p_history_mode',
'                    , p_ai_conversation_id_o  => :P305_CONVERSATION_ID',
'                    , p_prompt_o => :P305_PROMPT);',
'',
' ',
'end;',
''))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(2733281526080717)
,p_internal_uid=>2733575338080720
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(2965575288013817)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_EXECUTION_CHAIN'
,p_process_name=>'Knowledge Base Update'
,p_attribute_01=>'Y'
,p_attribute_02=>'N'
,p_attribute_03=>'P305_BG_PROCESS_ID'
,p_attribute_04=>'IGNORE'
,p_attribute_09=>'N'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>2965575288013817
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(2965685429013818)
,p_process_sequence=>10
,p_parent_process_id=>wwv_flow_imp.id(2965575288013817)
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Run'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
' ai_agent.start_run( p_ai_conversation_id => :P305_CONVERSATION_ID',
'                   , p_prompt             => :P305_PROMPT );'))
,p_process_clob_language=>'PLSQL'
,p_internal_uid=>2965685429013818
);
wwv_flow_imp.component_end;
end;
/
