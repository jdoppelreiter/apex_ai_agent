prompt --application/pages/page_05000
begin
--   Manifest
--     PAGE: 05000
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
 p_id=>5000
,p_name=>'test'
,p_alias=>'TEST'
,p_step_title=>'test'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'27'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(8669511884121647)
,p_plug_name=>'New'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>3371237801798025892
,p_plug_display_sequence=>30
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT ''EXPORT_001'' AS process_id,',
'       ''Nightly customer export''     AS name,',
'       ''Processing batch 12 of 50''   AS status_message,',
'       ''running''                     AS state',
'  FROM dual',
'UNION ALL',
'SELECT ''BACKUP_DB'',  ''Database backup'',',
'       ''Completed in 00:04:12'',              ''success'' FROM dual',
'UNION ALL',
'SELECT ''ARCHIVE_07'', ''Archive run #7'',',
'       ''ORA-20010: source table locked'',     ''error''   FROM dual'))
,p_template_component_type=>'REPORT'
,p_lazy_loading=>false
,p_plug_source_type=>'TMPL_DEV.PROGRESS_TRACKER'
,p_plug_query_num_rows=>15
,p_plug_query_num_rows_type=>'SET'
,p_show_total_row_count=>false
,p_landmark_type=>'region'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'APP_USER', '&APP_USER.',
  'BUTTON_ICON', 'fa-american-sign-language-interpreting',
  'MAX_VISIBLE', '5',
  'NAME', 'NAME',
  'PROCESS_ID', 'PROCESS_ID',
  'STATE', 'STATE',
  'STATUS_MESSAGE', 'STATUS_MESSAGE',
  'WS_URL', 'ws://localhost:8090/ws')).to_clob
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(8669661439121648)
,p_name=>'PROCESS_ID'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'PROCESS_ID'
,p_data_type=>'VARCHAR2'
,p_display_sequence=>10
,p_is_group=>false
,p_use_as_row_header=>false
,p_is_primary_key=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(8669773598121649)
,p_name=>'NAME'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'NAME'
,p_data_type=>'VARCHAR2'
,p_display_sequence=>20
,p_is_group=>false
,p_use_as_row_header=>false
,p_is_primary_key=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(8669892731121650)
,p_name=>'STATUS_MESSAGE'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'STATUS_MESSAGE'
,p_data_type=>'VARCHAR2'
,p_display_sequence=>30
,p_is_group=>false
,p_use_as_row_header=>false
,p_is_primary_key=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(9432599616456701)
,p_name=>'STATE'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'STATE'
,p_data_type=>'VARCHAR2'
,p_display_sequence=>40
,p_is_group=>false
,p_use_as_row_header=>false
,p_is_primary_key=>false
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9432823556456704)
,p_name=>'P5000_NEW'
,p_item_sequence=>10
,p_prompt=>'New'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp.component_end;
end;
/
