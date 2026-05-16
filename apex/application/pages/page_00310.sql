prompt --application/pages/page_00310
begin
--   Manifest
--     PAGE: 00310
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
 p_id=>310
,p_name=>'Conversation History'
,p_alias=>'CONVERSATION-HISTORY'
,p_step_title=>'Conversation History'
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_inline_css=>wwv_flow_string.join(wwv_flow_t_varchar2(
'.progress-wrapper {',
'    width: 150px;',
'    height: 10px;',
'    background: #eee;',
'    border-radius: 5px;',
'    margin-top: 10px;',
'    overflow: hidden;',
'  }',
'  #progress-bar {',
'    width: 0%;',
'    height: 100%;',
'    background: #4caf50;',
'    transition: width 0.1s linear;',
'  }'))
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'27'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(2679823843401599)
,p_plug_name=>'Breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2531463326621247859
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(1479605748975345)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>4072363345357175094
,p_required_patch=>wwv_flow_imp.id(1479095642975344)
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(2690692090681629)
,p_plug_name=>'&P310_AI_AGENT_NAME.'
,p_region_name=>'INFO-STATUS-REGION'
,p_region_template_options=>'#DEFAULT#:t-HeroRegion--hideIcon'
,p_plug_template=>2674017834225413037
,p_plug_display_sequence=>40
,p_plug_item_display_point=>'BELOW'
,p_location=>null
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Started at <b>&P310_CONVERSATION_CREATED.</b><br/>',
'using model <b>&P310_CONVERSATION_MODEL.</b></br>',
'using service <b>&P310_CONVERSATION_SERVICE.</b>',
'<br/>',
'status: <b><span id="info-status">&P310_CONVERSATION_STATUS.</span></b>',
'<br/>',
'<c-ticker id="info-status-ticker" interval="3000" status="disabled" event="checkLastMessage"></c-ticker> '))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
,p_plug_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<div id="status">',
'  <div>Next check in: <span id="countdown"></span>s</div>',
'  <div class="progress-wrapper">',
'    <div id="progress-bar"></div>',
'  </div>',
'</div>'))
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(2690712650681630)
,p_plug_name=>'Status'
,p_plug_display_sequence=>30
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(2968246559013844)
,p_plug_name=>'Conversation History (TC)'
,p_region_name=>'AI_CONV_HISTORY'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>3371237801798025892
,p_plug_display_sequence=>60
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select ai_conversation_history_id',
'',
'     , msg_direction',
'     , creation_ts',
'     , msg_role',
'     , tool_id',
'     , dbms_lob.substr(content,400,1)|| case when dbms_lob.getlength(content) > 400 then ''...'' end as content',
'     , case when msg_role = ''TOOL'' then ''SUCCESS'' ',
'            when msg_role = ''ASSISTANT'' then ''WARN'' ',
'            else ''INFO'' ',
'       end as card_type',
'  from V_CONV_HISTORY',
'  where ai_conversation_id = :P310_AI_CONVERSATION_ID'))
,p_query_order_by_type=>'STATIC'
,p_query_order_by=>'creation_ts '
,p_template_component_type=>'REPORT'
,p_lazy_loading=>false
,p_plug_source_type=>'TMPL_TC_YAAA_CONVERSATION_HISTORY'
,p_ajax_items_to_submit=>'P310_AI_CONVERSATION_ID'
,p_plug_query_num_rows=>15
,p_plug_query_num_rows_type=>'SET'
,p_show_total_row_count=>false
,p_landmark_type=>'region'
,p_row_selection_type=>'SINGLE'
,p_current_selection_page_item=>'P310_TIMELINE_SELECTED'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'CONTENT', 'CONTENT',
  'DATETIME', 'CREATION_TS',
  'DATETIME_ISO', 'CREATION_TS',
  'DIRECTION', 'MSG_DIRECTION',
  'ID', 'AI_CONVERSATION_HISTORY_ID',
  'ROLE', 'MSG_ROLE',
  'TOOL_ID', 'TOOL_ID',
  'TOOL_ID_BADGE_CLASS', 'AI_CONVERSATION_HISTORY_ID',
  'TYPE', 'CARD_TYPE')).to_clob
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(2968893733013850)
,p_name=>'AI_CONVERSATION_HISTORY_ID'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'AI_CONVERSATION_HISTORY_ID'
,p_data_type=>'NUMBER'
,p_display_sequence=>10
,p_is_group=>false
,p_use_as_row_header=>false
,p_is_primary_key=>true
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(4776991826248101)
,p_name=>'MSG_DIRECTION'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'MSG_DIRECTION'
,p_data_type=>'VARCHAR2'
,p_display_sequence=>20
,p_is_group=>false
,p_is_primary_key=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(4777003406248102)
,p_name=>'CREATION_TS'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'CREATION_TS'
,p_data_type=>'TIMESTAMP_TZ'
,p_display_sequence=>30
,p_format_mask=>'DD.MM.YYYY HH24:MI:SS'
,p_is_group=>false
,p_use_as_row_header=>false
,p_is_primary_key=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(4777179010248103)
,p_name=>'MSG_ROLE'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'MSG_ROLE'
,p_data_type=>'VARCHAR2'
,p_display_sequence=>40
,p_is_group=>false
,p_is_primary_key=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(4777268958248104)
,p_name=>'CONTENT'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'CONTENT'
,p_data_type=>'VARCHAR2'
,p_display_sequence=>50
,p_is_group=>false
,p_use_as_row_header=>false
,p_is_primary_key=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(4777343120248105)
,p_name=>'CARD_TYPE'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'CARD_TYPE'
,p_data_type=>'VARCHAR2'
,p_display_sequence=>60
,p_is_group=>false
,p_use_as_row_header=>false
,p_is_primary_key=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(4778525461248117)
,p_name=>'TOOL_ID'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'TOOL_ID'
,p_data_type=>'VARCHAR2'
,p_display_sequence=>70
,p_is_group=>false
,p_use_as_row_header=>false
,p_is_primary_key=>false
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(10472086833285710)
,p_branch_name=>'Go To Page 200'
,p_branch_action=>'f?p=&APP_ID.:320:&SESSION.::&DEBUG.:320:P320_AI_CONVERSATION_HISTORY_ID:&P310_TIMELINE_SELECTED.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(1500764273984038)
,p_name=>'P310_AI_CONVERSATION_ID'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(2690712650681630)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(2690287941681625)
,p_name=>'P310_CONVERSATION_CREATED'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(2690712650681630)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(2690362901681626)
,p_name=>'P310_CONVERSATION_STATUS'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(2690712650681630)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(2690855225681631)
,p_name=>'P310_CONVERSATION_MODEL'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(2690712650681630)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(2690937544681632)
,p_name=>'P310_CONVERSATION_SERVICE'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(2690712650681630)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(2691080614681633)
,p_name=>'P310_LAST_LOADED_CONV_HIST_ID'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(2690712650681630)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(2692364237681646)
,p_name=>'P310_DO_RELOAD'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(2968246559013844)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(2692535109681648)
,p_name=>'P310_TIMELINE_SELECTED'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(2968246559013844)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(2734421877080729)
,p_name=>'P310_IS_FINISHED'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(2968246559013844)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(10473258484285722)
,p_name=>'P310_AI_AGENT_NAME'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(2690712650681630)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(1501909474984050)
,p_name=>'Selected ID Is null'
,p_event_sequence=>10
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P310_SELECTED_ID'
,p_condition_element=>'P310_SELECTED_ID'
,p_triggering_condition_type=>'NULL'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(2689771283681620)
,p_event_id=>wwv_flow_imp.id(1501909474984050)
,p_event_result=>'FALSE'
,p_action_sequence=>60
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_EXECUTE_PLSQL_CODE'
,p_attribute_01=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select content ',
'  into :P310_CONTENT ',
'  from v_conv_history',
'  where ai_conversation_history_id = :P310_SELECTED_ID;'))
,p_attribute_02=>'P310_SELECTED_ID'
,p_attribute_03=>'P310_CONTENT'
,p_attribute_04=>'N'
,p_attribute_05=>'PLSQL'
,p_wait_for_result=>'Y'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(2691195248681634)
,p_name=>'Check last message'
,p_event_sequence=>30
,p_triggering_element_type=>'JAVASCRIPT_EXPRESSION'
,p_triggering_element=>'document'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'custom'
,p_bind_event_type_custom=>'checkLastMessage'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(2691246264681635)
,p_event_id=>wwv_flow_imp.id(2691195248681634)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_EXECUTE_PLSQL_CODE'
,p_attribute_01=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare ',
'  l_current_id  ai_conversation_histories.ai_conversation_history_id%type;',
'  l_status      ai_conversations.status%type;',
'begin ',
'',
'  select ai_conversation_history_id ',
'    into l_current_id',
'    from ai_conversation_histories ',
'    where ai_conversation_id = :P310_AI_CONVERSATION_ID',
'    order by creation_ts desc ',
'    fetch first 1 row only;  ',
'',
'  if nvl(:P310_LAST_LOADED_CONV_HIST_ID,-1) != nvl(l_current_id,-1) then ',
'    :P310_LAST_LOADED_CONV_HIST_ID := l_current_id;',
'    :P310_DO_RELOAD := ''Y'';',
'',
'    :P310_CONVERSATION_STATUS := ai_conv.get_conversation_status( p_ai_conversation_id => :P310_AI_CONVERSATION_ID ); ',
'    ',
'  else ',
'    :P310_DO_RELOAD := ''N'';',
'  end if;',
'end;'))
,p_attribute_02=>'P310_AI_CONVERSATION_ID'
,p_attribute_03=>'P310_LAST_LOADED_CONV_HIST_ID,P310_DO_RELOAD,P310_CONVERSATION_STATUS'
,p_attribute_04=>'N'
,p_attribute_05=>'PLSQL'
,p_wait_for_result=>'Y'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(2692234994681645)
,p_event_id=>wwv_flow_imp.id(2691195248681634)
,p_event_result=>'TRUE'
,p_action_sequence=>20
,p_execute_on_page_init=>'Y'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>wwv_flow_string.join(wwv_flow_t_varchar2(
'if( apex.items.P310_DO_RELOAD.getValue() == ''Y'' ){',
'  apex.items.P310_DO_RELOAD.setValue(''N'');',
'  apex.regions.AI_CONV_HISTORY.refresh();',
'}',
'',
'if( apex.items.P310_CONVERSATION_STATUS.getValue() == ''FINISHED'' ){',
'  $("#info-status-ticker").attr(''status'', ''disabled'');',
'  $("#info-status").text("FINISHED");',
'} else if ( $("#info-status-ticker").attr(''status'') === ''disabled'') {',
'  $("#info-status-ticker").attr(''status'', ''enabled'');',
'}'))
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(2692635784681649)
,p_name=>'Check changed selection'
,p_event_sequence=>60
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P310_TIMELINE_SELECTED'
,p_triggering_condition_type=>'JAVASCRIPT_EXPRESSION'
,p_triggering_expression=>'apex.items.P310_TIMELINE_SELECTED.getValue() != "" '
,p_bind_type=>'live'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(10471946945285709)
,p_event_id=>wwv_flow_imp.id(2692635784681649)
,p_event_result=>'TRUE'
,p_action_sequence=>40
,p_execute_on_page_init=>'N'
,p_name=>'OPEN_MODAL'
,p_action=>'NATIVE_SUBMIT_PAGE'
,p_attribute_01=>'OPEN_MODAL'
,p_attribute_02=>'N'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(2690442814681627)
,p_process_sequence=>10
,p_process_point=>'AFTER_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load Infos'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select to_char(c.creation_ts,''DD.MM.YYYY HH24:MI:SS'') as created_at',
'     , c.model',
'     , s.name as service',
'     , c.status',
'     , a.name',
'  into :P310_CONVERSATION_CREATED',
'     , :P310_CONVERSATION_MODEL',
'     , :P310_CONVERSATION_SERVICE',
'     , :P310_CONVERSATION_STATUS',
'     , :P310_AI_AGENT_NAME',
'  from ai_conversations c',
'  join ai_services s on c.ai_service_id = s.ai_service_id ',
'  join ai_agents a on c.ai_agent_id = a.ai_agent_id',
'  where c.ai_conversation_id = :P310_AI_CONVERSATION_ID;',
'  ',
'',
''))
,p_process_clob_language=>'PLSQL'
,p_internal_uid=>2690442814681627
);
wwv_flow_imp.component_end;
end;
/
