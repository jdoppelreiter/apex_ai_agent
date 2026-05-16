prompt # install tables
@@../src/database/quicksql_table_creation.sql

prompt # install views 
@@install_views.sql

prompt # install macros 
@@install_macros.sql‚

prompt # install packages
@@install_packages.sql

begin 
  dbms_utility.compile_schema(user, false);
end;
/