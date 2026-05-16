prompt --application/shared_components/security/authentications/builder
begin
--   Manifest
--     AUTHENTICATION: Builder
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>1467387009598820
,p_default_application_id=>100
,p_default_id_offset=>0
,p_default_owner=>'AGENT'
);
wwv_flow_imp_shared.create_authentication(
 p_id=>wwv_flow_imp.id(1495355136976633)
,p_name=>'Builder'
,p_scheme_type=>'NATIVE_EXTENSION'
,p_use_secure_cookie_yn=>'N'
,p_ras_mode=>0
,p_version_scn=>16290031
);
wwv_flow_imp.component_end;
end;
/
