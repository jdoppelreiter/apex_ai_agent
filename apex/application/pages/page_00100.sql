prompt --application/pages/page_00100
begin
--   Manifest
--     PAGE: 00100
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
 p_id=>100
,p_name=>'Agents'
,p_alias=>'AGENTS'
,p_step_title=>'Agents'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'23'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(1496147079982340)
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
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(1497051970984001)
,p_plug_name=>'Agents'
,p_region_template_options=>'#DEFAULT#:t-CardsRegion--hideHeader js-addHiddenHeadingRoleDesc:margin-top-lg'
,p_plug_template=>2072724515482255512
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select aia.AI_AGENT_ID,',
'       aia.AI_SERVICE_ID,',
'       aia.NAME,',
'       aia.DESCRIPTION,',
'       case when length(aia.system_prompt)>100 then substr(aia.SYSTEM_PROMPT,1,100)||''...'' else aia.system_prompt end as SYSTEM_PROMPT,',
'       aia.DEVELOPER_PROMPT,',
'       aia.EXAMPLES,',
'       aia.DEFAULT_HISTORY_MODE,',
'       ais.name as ai_service',
'  from AI_AGENTS aia',
'  join ai_services ais on aia.ai_service_id = ais.ai_service_id'))
,p_lazy_loading=>false
,p_plug_source_type=>'NATIVE_CARDS'
,p_plug_query_num_rows_type=>'SCROLL'
,p_show_total_row_count=>false
);
wwv_flow_imp_page.create_card(
 p_id=>wwv_flow_imp.id(9434060883456716)
,p_region_id=>wwv_flow_imp.id(1497051970984001)
,p_layout_type=>'GRID'
,p_title_adv_formatting=>false
,p_title_column_name=>'NAME'
,p_sub_title_adv_formatting=>false
,p_body_adv_formatting=>true
,p_body_html_expr=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<div style="display: flex; flex-direction: column; gap: 0.5rem;">',
'',
'  <div style="display: flex; gap: 0.5rem;">',
'    <div style="font-weight: bold; min-width: 120px;">Description:</div>',
'    <div style="flex: 1;">&DESCRIPTION!HTML.</div>',
'  </div>',
'',
'  <div style="display: flex; gap: 0.5rem;">',
'    <div style="font-weight: bold; min-width: 120px;">AI-Service:</div>',
'    <div style="flex: 1;">&AI_SERVICE!HTML.</div>',
'  </div>',
'',
'  <div style="display: flex; gap: 0.5rem;">',
'    <div style="font-weight: bold; min-width: 120px;">History-Mode:</div>',
'    <div style="flex: 1;">&DEFAULT_HISTORY_MODE!HTML.</div>',
'  </div>',
'',
'  <div style="display: flex; gap: 0.5rem;">',
'    <div style="font-weight: bold; min-width: 120px;">System-Prompt:</div>',
'    <div style="flex: 1;">&SYSTEM_PROMPT!HTML.</div>',
'  </div>',
'',
'</div>',
''))
,p_second_body_adv_formatting=>false
,p_media_adv_formatting=>false
,p_pk1_column_name=>'AI_AGENT_ID'
);
wwv_flow_imp_page.create_card_action(
 p_id=>wwv_flow_imp.id(9434199231456717)
,p_card_id=>wwv_flow_imp.id(9434060883456716)
,p_action_type=>'BUTTON'
,p_position=>'PRIMARY'
,p_display_sequence=>10
,p_label=>'Edit'
,p_link_target_type=>'REDIRECT_PAGE'
,p_link_target=>'f?p=&APP_ID.:110:&SESSION.::&DEBUG.:110:P110_AI_AGENT_ID:&AI_AGENT_ID.'
,p_button_display_type=>'TEXT_WITH_ICON'
,p_icon_css_classes=>'fa-edit'
,p_is_hot=>true
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(11639565715502902)
,p_button_sequence=>10
,p_button_name=>'CREATE_AGENT'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Create Agent'
,p_button_redirect_url=>'f?p=&APP_ID.:110:&SESSION.::&DEBUG.:110::'
,p_icon_css_classes=>'fa-edit'
,p_grid_new_row=>'Y'
);
wwv_flow_imp.component_end;
end;
/
