create or replace package ai_notification as

  procedure send_update_to_client;

  procedure update_background_process( p_message  varchar2 );

end ai_notification;