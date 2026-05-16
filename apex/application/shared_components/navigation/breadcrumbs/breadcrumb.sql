prompt --application/shared_components/navigation/breadcrumbs/breadcrumb
begin
--   Manifest
--     MENU: Breadcrumb
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>1467387009598820
,p_default_application_id=>100
,p_default_id_offset=>0
,p_default_owner=>'AGENT'
);
wwv_flow_imp_shared.create_menu(
 p_id=>wwv_flow_imp.id(1479605748975345)
,p_name=>'Breadcrumb'
);
wwv_flow_imp_shared.create_menu_option(
 p_id=>wwv_flow_imp.id(1479850026975346)
,p_short_name=>'Home'
,p_link=>'f?p=&APP_ID.:1:&APP_SESSION.::&DEBUG.:::'
,p_page_id=>1
);
wwv_flow_imp_shared.create_menu_option(
 p_id=>wwv_flow_imp.id(1496628390982342)
,p_short_name=>'Agents'
,p_link=>'f?p=&APP_ID.:100:&APP_SESSION.::&DEBUG.:::'
,p_page_id=>100
);
wwv_flow_imp_shared.create_menu_option(
 p_id=>wwv_flow_imp.id(2674163172107768)
,p_short_name=>'Conversations'
,p_link=>'f?p=&APP_ID.:300:&APP_SESSION.::&DEBUG.:::'
,p_page_id=>300
);
wwv_flow_imp_shared.create_menu_option(
 p_id=>wwv_flow_imp.id(2680365767401600)
,p_parent_id=>wwv_flow_imp.id(2674163172107768)
,p_short_name=>'Conversation History'
,p_link=>'f?p=&APP_ID.:310:&SESSION.::&DEBUG.:::'
,p_page_id=>310
);
wwv_flow_imp_shared.create_menu_option(
 p_id=>wwv_flow_imp.id(2763806552715281)
,p_short_name=>'Tools'
,p_link=>'f?p=&APP_ID.:200:&APP_SESSION.::&DEBUG.:::'
,p_page_id=>200
);
wwv_flow_imp_shared.create_menu_option(
 p_id=>wwv_flow_imp.id(2770499179735435)
,p_short_name=>'Services'
,p_link=>'f?p=&APP_ID.:50:&APP_SESSION.::&DEBUG.:::'
,p_page_id=>50
);
wwv_flow_imp.component_end;
end;
/
