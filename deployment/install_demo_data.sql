prompt # install packages
@@test_utils/packages/ai_tool.pks
@@test_utils/packages/ai_tool.pkb

prompt # install demo dataset
@@test_utils/demo_dataset.sql

begin 
  dbms_utility.compile_schema(user, false);
end;
/