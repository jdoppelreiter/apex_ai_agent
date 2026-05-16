prompt --application/pages/page_00300
begin
--   Manifest
--     PAGE: 00300
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
 p_id=>300
,p_name=>'Conversations'
,p_alias=>'CONVERSATIONS'
,p_step_title=>'Conversations'
,p_autocomplete_on_off=>'OFF'
,p_inline_css=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('/* \2500\2500 Desktop: hide inline label spans \2500\2500 */'),
'.t-Report-cell span.c-header {',
'  display: none;',
'}',
'',
unistr('/* \2500\2500 Mobile: < 768px \2500\2500 */'),
'@media (max-width: 767px) {',
'',
'  .t-Report-report thead {',
'    display: none;',
'  }',
'',
'  .t-Report-report tbody {',
'    display: flex;',
'    flex-direction: column;',
'    gap: 0.5rem;',
'  }',
'',
'  .t-Report-report tbody tr {',
'    display: flex;',
'    flex-direction: column;',
'    border-bottom: 1px solid rgba(0,0,0,0.1);',
'    padding: 0.5rem 0;',
'  }',
'',
'  .t-Report-report tbody td {',
'    display: flex;',
'    flex-direction: row;',
'    align-items: baseline;',
'    padding: 0.2rem 0;',
'    /* Remove any alignment overrides from inline align attribute */',
'    text-align: left !important;',
'  }',
'',
'  /* Label span: fixed width, bold, inherit color */',
'  .t-Report-report tbody td span.c-header {',
'    display: inline;',
'    font-weight: 700;',
'    flex: 0 0 9rem;',
'    min-width: 9rem;',
'  }',
'}',
''))
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'24'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(1499259476984023)
,p_name=>'History'
,p_template=>4072358936313175081
,p_display_sequence=>10
,p_region_template_options=>'#DEFAULT#:t-Region--noPadding:t-Region--scrollBody:margin-top-lg'
,p_component_template_options=>'#DEFAULT#:t-Report--stretch:t-Report--staticRowColors:t-Report--rowHighlight'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select null as action, ',
'       ai.ai_conversation_id,',
'       ai.ai_agent_id,',
'       ai.ai_service_id,',
'       ai.creation_ts,',
'       ai.model,',
'       ai.tools,',
'       ai.execution_type,',
'       ai.history_mode,',
'       ai.status,',
'       ais.name as ai_service_name',
'  from ai_conversations ai ',
'  left join ai_services ais on ai.ai_service_id = ais.ai_service_id  '))
,p_ajax_enabled=>'Y'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>15
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_num_rows_type=>'NEXT_PREVIOUS_LINKS'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(10471880516285708)
,p_query_column_id=>1
,p_column_alias=>'ACTION'
,p_column_display_sequence=>10
,p_column_heading=>'Action'
,p_column_link=>'f?p=&APP_ID.:310:&SESSION.::&DEBUG.:310:P310_AI_CONVERSATION_ID:#AI_CONVERSATION_ID#'
,p_column_linktext=>'<span role="img" aria-label="Edit" class="fa fa-edit" title="Edit"></span> Open Conversation'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9437261496456748)
,p_query_column_id=>2
,p_column_alias=>'AI_CONVERSATION_ID'
,p_column_display_sequence=>20
,p_column_heading=>'Ai Conversation Id'
,p_column_html_expression=>'<span class="c-header">AI Conversation ID</span>#AI_CONVERSATION_ID#'
,p_column_css_class=>'test'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9437359635456749)
,p_query_column_id=>3
,p_column_alias=>'AI_AGENT_ID'
,p_column_display_sequence=>40
,p_column_heading=>'Ai Agent Id'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
,p_required_patch=>wwv_flow_imp.id(1479095642975344)
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9437428989456750)
,p_query_column_id=>4
,p_column_alias=>'AI_SERVICE_ID'
,p_column_display_sequence=>50
,p_column_heading=>'Ai Service Id'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
,p_required_patch=>wwv_flow_imp.id(1479095642975344)
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(10471137542285701)
,p_query_column_id=>5
,p_column_alias=>'CREATION_TS'
,p_column_display_sequence=>60
,p_column_heading=>'Creation Ts'
,p_column_format=>'DD.MM.YYYY HH24:MI:SS'
,p_column_html_expression=>'<span class="c-header">Creation at</span>#CREATION_TS#'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(10471213883285702)
,p_query_column_id=>6
,p_column_alias=>'MODEL'
,p_column_display_sequence=>70
,p_column_heading=>'Model'
,p_column_html_expression=>'<span class="c-header">Model</span>#MODEL#'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(10471315048285703)
,p_query_column_id=>7
,p_column_alias=>'TOOLS'
,p_column_display_sequence=>80
,p_column_heading=>'Tools'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
,p_required_patch=>wwv_flow_imp.id(1479095642975344)
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(10471416917285704)
,p_query_column_id=>8
,p_column_alias=>'EXECUTION_TYPE'
,p_column_display_sequence=>90
,p_column_heading=>'Execution Type'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
,p_required_patch=>wwv_flow_imp.id(1479095642975344)
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(10471541410285705)
,p_query_column_id=>9
,p_column_alias=>'HISTORY_MODE'
,p_column_display_sequence=>100
,p_column_heading=>'History Mode'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
,p_required_patch=>wwv_flow_imp.id(1479095642975344)
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(10471691855285706)
,p_query_column_id=>10
,p_column_alias=>'STATUS'
,p_column_display_sequence=>110
,p_column_heading=>'Status'
,p_column_html_expression=>'<span class="c-header">Status</span>#STATUS#'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(10471711272285707)
,p_query_column_id=>11
,p_column_alias=>'AI_SERVICE_NAME'
,p_column_display_sequence=>30
,p_column_heading=>'Ai Service Name'
,p_column_html_expression=>'<span class="c-header">AI Service</span>#AI_SERVICE_NAME#'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(10474829367285738)
,p_plug_name=>'New'
,p_parent_plug_id=>wwv_flow_imp.id(1499259476984023)
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>10
,p_location=>null
,p_plug_source_type=>'NATIVE_SMART_FILTERS'
,p_filtered_region_id=>wwv_flow_imp.id(1499259476984023)
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'compact_numbers_threshold', '10000',
  'more_filters_suggestion_chip', 'N',
  'show_total_row_count', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(2673655636107766)
,p_plug_name=>'Breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2531463326621247859
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_menu_id=>wwv_flow_imp.id(1479605748975345)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>4072363345357175094
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(2732272241080707)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(1499259476984023)
,p_button_name=>'START'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Start new conversation'
,p_button_position=>'EDIT'
,p_button_redirect_url=>'f?p=&APP_ID.:305:&SESSION.::&DEBUG.:305::'
,p_button_css_classes=>'fab-add-to-actions'
,p_icon_css_classes=>'fa-ai-generative'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(10474984184285739)
,p_name=>'P300_SEARCH'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(10474829367285738)
,p_prompt=>'Search'
,p_source_type=>'FACET_COLUMN'
,p_display_as=>'NATIVE_SEARCH'
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'collapsed_search_field', 'N',
  'search_type', 'ROW')).to_clob
,p_fc_show_chart=>false
);
wwv_flow_imp.component_end;
end;
/
