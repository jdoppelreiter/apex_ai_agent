prompt --application/shared_components/security/authorizations/is_active
begin
--   Manifest
--     SECURITY SCHEME: Is Active
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>1467387009598820
,p_default_application_id=>100
,p_default_id_offset=>0
,p_default_owner=>'AGENT'
);
wwv_flow_imp_shared.create_security_scheme(
 p_id=>wwv_flow_imp.id(3164924425038772)
,p_name=>'Is Active'
,p_scheme_type=>'NATIVE_FUNCTION_BODY'
,p_attribute_01=>'return false;'
,p_version_scn=>16279645
,p_caching=>'BY_USER_BY_SESSION'
);
wwv_flow_imp.component_end;
end;
/
