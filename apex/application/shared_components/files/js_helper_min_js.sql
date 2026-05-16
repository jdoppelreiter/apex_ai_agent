prompt --application/shared_components/files/js_helper_min_js
begin
--   Manifest
--     APP STATIC FILES: 100
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>1467387009598820
,p_default_application_id=>100
,p_default_id_offset=>0
,p_default_owner=>'AGENT'
);
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2428646F63756D656E74292E7265616479282866756E6374696F6E28297B242822236170657843424D44756D6D7953656C656374696F6E22292E617474722822617269612D68696464656E222C227472756522292E617474722822617269612D6C616265';
wwv_flow_imp.g_varchar2_table(2) := '6C222C2244756D6D792073656C656374696F6E22292C73657454696D656F7574282866756E6374696F6E28297B636F6E737420743D2428222E742D4865616465722D6E61762D6C697374202E612D4D656E752D2D63757272656E7422293B742E6C656E67';
wwv_flow_imp.g_varchar2_table(3) := '74683E302626742E617474722822746162696E646578222C223022297D292C323030297D29293B';
wwv_flow_imp_shared.create_app_static_file(
 p_id=>wwv_flow_imp.id(13236201318274192)
,p_file_name=>'js/helper.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content => wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
wwv_flow_imp.component_end;
end;
/
