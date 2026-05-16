prompt --application/shared_components/user_interface/theme_style
begin
--   Manifest
--     THEME STYLE: 100
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>1467387009598820
,p_default_application_id=>100
,p_default_id_offset=>0
,p_default_owner=>'AGENT'
);
wwv_flow_imp_shared.create_theme_style(
 p_id=>wwv_flow_imp.id(9240199621002640)
,p_theme_id=>42
,p_name=>'Tech Dark'
,p_css_file_urls=>wwv_flow_string.join(wwv_flow_t_varchar2(
'#APP_FILES#css/dark/custom_styles#MIN#.css',
'#APP_FILES#fonts/font.css'))
,p_is_public=>true
,p_is_accessible=>false
,p_theme_roller_input_file_urls=>'#THEME_FILES#less/theme/Vita-Dark.less'
,p_theme_roller_config=>'{"classes":[],"vars":{"@g_Accent-BG":"#055f76","@g_Accent-OG":"#181414","@g_Danger-BG":"#f87171","@g_Danger-FG":"#ffffff","@g_Warning-BG":"#fbbf24","@g_Warning-FG":"#000000","@g_Success-BG":"#198960","@g_Success-FG":"#ffffff","@g_Info-BG":"#38bdf8","'
||'@g_Info-FG":"#ffffff","@g_Region-Header-BG":"#111d2b","@g_Region-Header-FG":"#f0f6ff","@g_Region-BG":"#111d2b","@g_Region-FG":"#e7fbff","@g_Container-BorderRadius":"10px","@g_Body-Content-Max-Width":"1440px","@g_Button-BorderRadius":"8px","@g_Link-Ba'
||'se":"#0cbbe7","@g_Nav-BG":"#060d14","@g_Nav-FG":"#d4d8d9","@g_Nav-Active-BG":"#055f76","@g_Nav-Active-FG":"#f2f2f2"},"customCSS":"","useCustomLess":"N"}'
,p_theme_roller_output_file_url=>'#THEME_DB_FILES#9240199621002640.css'
,p_theme_roller_read_only=>false
);
wwv_flow_imp.component_end;
end;
/
