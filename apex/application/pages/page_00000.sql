prompt --application/pages/page_00000
begin
--   Manifest
--     PAGE: 00000
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
 p_id=>0
,p_name=>'Global Page'
,p_step_title=>'Global Page'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'14'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(8669079718121642)
,p_plug_name=>'FAB'
,p_region_name=>'ACTIONS_MENU'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>3371237801798025892
,p_plug_display_sequence=>10
,p_plug_grid_row_css_classes=>'fab-container-row'
,p_plug_display_point=>'REGION_POSITION_05'
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select ''https://www.solicon-it.com'' as url',
'     , ''_blank'' as target',
'     , ''fa-globe'' as icon',
'     , ''Homepage'' as label',
'     , 10 as seq',
'  from dual',
' union all',
'select ''mailto:joerg.doppelreiter@solicon-it.com''',
'     , ''self''',
'     , ''fa-envelope-o''',
'     , ''Send E-Mail''',
'     , 20',
'  from dual',
' union all',
'select ''https://www.solicon-it.com''',
'     , ''_blank''',
'     , ''fa-question-circle-o''',
'     , ''Get Support''',
'     , 40',
'  from dual'))
,p_template_component_type=>'REPORT'
,p_lazy_loading=>false
,p_plug_source_type=>'TMPL_DEV.JNMR.FLOATING_BUTTON'
,p_plug_query_num_rows=>15
,p_plug_query_num_rows_type=>'SET'
,p_show_total_row_count=>false
,p_landmark_type=>'region'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'ADD_TO_ACTIONS', 'fab-add-to-actions',
  'BUTTON_ICON', 'fa-gear',
  'ICON', 'ICON',
  'LABEL', 'LABEL',
  'REGION_STATIC_ID', 'ACTIONS_MENU',
  'SUB_ICON_COLOR', '#f7f7f7',
  'TARGET', 'TARGET',
  'URL', 'URL')).to_clob
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(8669115423121643)
,p_name=>'URL'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'URL'
,p_data_type=>'VARCHAR2'
,p_display_sequence=>10
,p_is_group=>false
,p_use_as_row_header=>false
,p_is_primary_key=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(8669208699121644)
,p_name=>'TARGET'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'TARGET'
,p_data_type=>'VARCHAR2'
,p_display_sequence=>20
,p_is_group=>false
,p_use_as_row_header=>false
,p_is_primary_key=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(8669383348121645)
,p_name=>'ICON'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'ICON'
,p_data_type=>'VARCHAR2'
,p_display_sequence=>30
,p_is_group=>false
,p_use_as_row_header=>false
,p_is_primary_key=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(8669470114121646)
,p_name=>'SEQ'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'SEQ'
,p_data_type=>'NUMBER'
,p_display_sequence=>40
,p_is_group=>false
,p_use_as_row_header=>false
,p_is_primary_key=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(11637473042497633)
,p_name=>'LABEL'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'LABEL'
,p_data_type=>'VARCHAR2'
,p_display_sequence=>50
,p_is_group=>false
,p_use_as_row_header=>false
,p_is_primary_key=>false
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(19898375305060311)
,p_plug_name=>'Progress Tracker'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>3371237801798025892
,p_plug_display_sequence=>20
,p_plug_display_point=>'REGION_POSITION_05'
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select  null as process_id',
'      , null as process_name',
'      , null as status_message',
'      , null as state',
'      , null as last_updated_on',
'      , ''false'' as render',
'  from dual',
'union all',
'select process_id',
'     , process_name',
'     , case when status_code = ''SUCCESS'' then ''Task finished'' else status_message end as status_message',
'     , decode(status_code, ''EXECUTING'', ''running''',
'                         , ''SUCCESS'', ''success''',
'                         , status_code',
'             ) as state',
'     , last_updated_on',
'     , ''true'' as render',
'from apex_appl_page_bg_proc_status b',
'where status_code in (''EXECUTING'',''SUCCESS'')',
'  and last_updated_on > sysdate - 10/3600',
''))
,p_query_order_by_type=>'STATIC'
,p_query_order_by=>'last_updated_on desc  fetch first 3 rows only'
,p_template_component_type=>'REPORT'
,p_lazy_loading=>false
,p_plug_source_type=>'TMPL_DEV.PROGRESS_TRACKER'
,p_plug_query_num_rows=>15
,p_plug_query_num_rows_type=>'SET'
,p_plug_query_no_data_found=>'<div class="hide-no-data-found"></div>'
,p_show_total_row_count=>false
,p_landmark_type=>'region'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'APP_USER', '&APP_USER.',
  'BUTTON_ICON', 'fa-person-running-fast',
  'MAX_VISIBLE', '5',
  'NAME', 'PROCESS_NAME',
  'PROCESS_ID', 'PROCESS_ID',
  'RENDER', '&RENDER.',
  'STATE', 'STATE',
  'STATUS_MESSAGE', 'STATUS_MESSAGE',
  'WS_URL', 'ws://localhost:8090/ws')).to_clob
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(10475180865285741)
,p_name=>'LAST_UPDATED_ON'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'LAST_UPDATED_ON'
,p_data_type=>'TIMESTAMP_TZ'
,p_display_sequence=>50
,p_is_group=>false
,p_use_as_row_header=>false
,p_is_primary_key=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(10475277945285742)
,p_name=>'PROCESS_NAME'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'PROCESS_NAME'
,p_data_type=>'VARCHAR2'
,p_display_sequence=>60
,p_is_group=>false
,p_use_as_row_header=>false
,p_is_primary_key=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(10475318174285743)
,p_name=>'RENDER'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'RENDER'
,p_data_type=>'VARCHAR2'
,p_display_sequence=>70
,p_is_group=>false
,p_use_as_row_header=>false
,p_is_primary_key=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(19898524860060312)
,p_name=>'PROCESS_ID'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'PROCESS_ID'
,p_data_type=>'NUMBER'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>10
,p_is_group=>false
,p_use_as_row_header=>false
,p_is_primary_key=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(19898756152060314)
,p_name=>'STATUS_MESSAGE'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'STATUS_MESSAGE'
,p_data_type=>'VARCHAR2'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>30
,p_is_group=>false
,p_use_as_row_header=>false
,p_is_primary_key=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(20661463037395365)
,p_name=>'STATE'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'STATE'
,p_data_type=>'VARCHAR2'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>40
,p_is_group=>false
,p_use_as_row_header=>false
,p_is_primary_key=>false
);
wwv_flow_imp.component_end;
end;
/
