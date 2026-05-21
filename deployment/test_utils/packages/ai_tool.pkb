create or replace package body ai_tool as

  -- functions
  function get_version return varchar2 is
  begin
    return ai_constants.c_version;
  end get_version;

  ----------------------------------------------------------------------------------------
  function get_data_from_url ( p_url  varchar2)
    return clob
  as
    l_content CLOB;
  begin
    
    return q'§23 APEX_DEBUG
                The APEX_DEBUG package provides utility functions for managing the debug message log. Specifically, this package provides the necessary APIs to instrument and debug PL/SQL code contained within your Oracle APEX application as well as PL/SQL code in database stored procedures and functions. Instrumenting your PL/SQL code makes it much easier to track down bugs and isolate unexpected behavior more quickly.

                      The package also provides the means to enable and disable debugging at different debug levels and utility procedures to clean up the message log.

                      You can view the message log either as described in the Accessing Debugging Mode section of the Oracle APEX App Builder User’s Guide or by querying the APEX_DEBUG_MESSAGES view.

                      For further information, see the individual API descriptions.

                      Note
                      In APEX release 4.2, the APEX_DEBUG_MESSAGE package was renamed to APEX_DEBUG. The APEX_DEBUG_MESSAGE package name is still supported to provide backward compatibility. As a best practice, however, use the new APEX_DEBUG package for new applications unless you plan to run them in an earlier version of APEX.

                      Constants
                      DISABLE Procedure
                      DISABLE_DBMS_OUTPUT Procedure
                      ENABLE Procedure
                      ENTER Procedure
                      ENABLE_DBMS_OUTPUT Procedure
                      ERROR Procedure
                      GET_LAST_MESSAGE_ID Function
                      GET_PAGE_VIEW_ID Function
                      INFO Procedure
                      LOG_DBMS_OUTPUT Procedure
                      LOG_LONG_MESSAGE Procedure
                      LOG_MESSAGE Procedure (Deprecated)
                      LOG_PAGE_SESSION_STATE Procedure
                      MESSAGE Procedure
                      REMOVE_DEBUG_BY_AGE Procedure
                      REMOVE_DEBUG_BY_APP Procedure
                      REMOVE_DEBUG_BY_VIEW Procedure
                      REMOVE_SESSION_MESSAGES Procedure
                      TOCHAR Function
                      TRACE Procedure
                      WARN Procedure§';
      RETURN TRIM(l_content);
    

    apex_debug.info('p_url: %s',p_url );
    l_content := APEX_WEB_SERVICE.make_rest_request(
                    p_url => p_url,
                    p_http_method => 'GET');

    -- Remove script/style/html tags
    l_content := REGEXP_REPLACE(l_content, '<script[^>]*>.*?</script>', '', 1, 0, 'im');
    l_content := REGEXP_REPLACE(l_content, '<style[^>]*>.*?</style>', '', 1, 0, 'im');
    l_content := REGEXP_REPLACE(l_content, '<[^>]+>', ' ');

    l_content := REGEXP_REPLACE(l_content, '\s+', ' ');

    RETURN TRIM(l_content);
  end get_data_from_url;
  
  ----------------------------------------------------------------------------------------

  function kb_create(  p_title              varchar2 
                     , p_content            clob )
    return clob
  as
  begin
    return 'Knowledge Base updated';
  end kb_create;

  ----------------------------------------------------------------------------------------
  
end ai_tool;
/
