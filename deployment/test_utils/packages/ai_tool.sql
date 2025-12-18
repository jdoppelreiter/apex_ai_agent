create or replace package ai_tool as

  c_version constant varchar2(10) := '1.0.0';

  function get_version return varchar2;

  function get_data_from_url ( p_url  varchar2)
    return clob; 
    
  function kb_create(  p_title              varchar2 
                     , p_content            clob )
    return clob;

end ai_tool;
/
