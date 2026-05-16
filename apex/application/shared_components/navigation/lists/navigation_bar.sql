prompt --application/shared_components/navigation/lists/navigation_bar
begin
--   Manifest
--     LIST: Navigation Bar
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>1467387009598820
,p_default_application_id=>100
,p_default_id_offset=>0
,p_default_owner=>'AGENT'
);
wwv_flow_imp_shared.create_list(
 p_id=>wwv_flow_imp.id(1481250797975374)
,p_name=>'Navigation Bar'
,p_list_status=>'PUBLIC'
,p_version_scn=>47628403
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(1493378101975417)
,p_list_item_display_sequence=>90
,p_list_item_link_text=>'&APP_USER.'
,p_list_item_link_target=>'#'
,p_list_item_icon=>'fa-user'
,p_list_text_02=>'has-username'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(1494220926975419)
,p_list_item_display_sequence=>30
,p_list_item_link_text=>'Sign Out'
,p_list_item_link_target=>'&LOGOUT_URL.'
,p_list_item_icon=>'fa-sign-out'
,p_list_item_disp_cond_type=>'USER_IS_NOT_PUBLIC_USER'
,p_parent_list_item_id=>wwv_flow_imp.id(1493378101975417)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(11640931670561230)
,p_list_item_display_sequence=>100
,p_list_item_link_text=>'&nbsp;'
,p_list_item_link_target=>'#'
,p_list_item_icon=>'fa-accordion'
,p_list_text_02=>'hidden-md-up'
,p_list_item_current_type=>'TARGET_PAGE'
,p_sub_list_id=>wwv_flow_imp.id(1480167705975347)
);
wwv_flow_imp.component_end;
end;
/
