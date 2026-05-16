create or replace package ai_error 
as 

  e_no_model_in_ai_service  exception;
  e_no_model_in_ai_service_int  constant number := -20200;
  pragma exception_init (e_no_model_in_ai_service , e_no_model_in_ai_service_int); 

  e_not_implemented_collections  exception;
  e_not_implemented_collections_int  constant number := -20201;
  pragma exception_init (e_not_implemented_collections , e_not_implemented_collections_int);

  e_prompt_arg_not_translateable exception;
  e_prompt_arg_not_translateable_int  constant number := -20301;
  pragma exception_init (e_prompt_arg_not_translateable , e_prompt_arg_not_translateable_int);

  e_message_empty exception;
  e_message_empty_int  constant number := -20302;
  pragma exception_init (e_message_empty , e_message_empty_int);

  e_conv_status_wrong  exception;
  e_conv_status_wrong_int  constant number := -20303;
  pragma exception_init (e_conv_status_wrong , e_conv_status_wrong_int );

  function is_in_custom_error_range( p_sqlcode number )
    return boolean;

  procedure handle( p_sqlcode   number
                  , p_errormsg  clob );

end ai_error;
/