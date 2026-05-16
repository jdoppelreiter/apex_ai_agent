create or replace package body ai_error 
as 

  function is_in_custom_error_range( p_sqlcode number )
    return boolean
  as 
  begin
    return (p_sqlcode between -20500 and -20000);
  end is_in_custom_error_range;

  ----------------------------------------------------------------------------------------
  
  procedure handle( p_sqlcode   number
                  , p_errormsg  clob )
  as 
    l_message    clob;
  begin

    apex_debug.enter( 'handle'
                    , 'p_sqlcode', p_sqlcode
                    , 'p_errormsg', dbms_lob.substr(p_errormsg,4000,1));

    case p_sqlcode
      when e_no_model_in_ai_service_int then 
        l_message := 'No Default AI Service found';
      when e_not_implemented_collections_int then 
        l_message := 'collection storage not supported yet, use table storage instead';
      when e_prompt_arg_not_translateable_int then
        l_message := 'parameter in tool call not translateable'; 
      when e_message_empty_int then 
        l_message := 'all parameters of message are empty';
      when e_conv_status_wrong_int then 
        l_message := 'conversation in wrong status';
      else 
        l_message := 'Unhandled custom error';
    end case;
    
    raise_application_error( p_sqlcode, l_message );

  end handle;

end ai_error;
/