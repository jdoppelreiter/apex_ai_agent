# YAAA – Yet another AI Agent

An AI Agent built **purely with SQL, PL/SQL and Oracle APEX**. No external frameworks are used for LLM interaction – every API call, tool dispatch and conversation history is handled inside the database.

The project doubles as a playground for Oracle APEX theme styles and template components.

## Requirements

- Oracle Database 19c+ (JSON / `apex_web_service` support)
- Oracle APEX 24.2+
- A parsing schema (e.g. `AGENT`) with APEX privileges and ACL access to your LLM endpoint

## Install

Connect to the parsing schema with SQL*Plus / SQLcl and run:

```sql
-- 1. database objects (tables, views, macros, packages)
@deployment/install_core_scratch.sql
```

Then import the APEX application from the `apex` directory:

```sql
-- 2. APEX application (App ID 100 – YAAA)
@apex/install.sql
```

Use `@deployment/uninstall.sql` to drop all objects, configuration and conversation history.

## Install test data and demo tools

The demo dataset installs a working agent configuration plus the `ai_tool` package containing dummy functions that are referenced by the demo tools:

```sql
@deployment/install_demo_data.sql
```

Shortcut to install core + demo in one go:

```sql
@deployment/install_all.sql
```

## Starting an agent

The entry point is the `ai_agent` package. A run is created in two steps – first set it up, then start it (synchronous or as a background job):

1. `ai_agent.setup_run` – creates a new `ai_conversation` from an agent configuration. Parameters left `NULL` fall back to the values stored on the agent; passing values overrides them (e.g. different service, model or system prompt).
2. `ai_agent.start_run` (synchronous) or `ai_agent.start_run_job` (asynchronous via DBMS_SCHEDULER) – executes the conversation using the prompt returned by `setup_run`.

While a conversation is active you can:

- check progress with `ai_agent.get_conversation_status`
- read the agent's last question with `ai_conv_history.get_user_question`
- send a user reply with `ai_conv.continue_conversation` when the status is `USER_QUESTION`

Ready-to-run examples for all four calls are in **`deployment/test_utils/sample_calls.sql`**.

## Repository layout

```
apex/         APEX application export (App 100 – YAAA)
deployment/   SQL install / uninstall scripts and demo data
src/ddl/      Table DDL (QuickSQL)
src/plsql/    Packages, views and SQL macros
src/nodejs/   Optional WebSocket helper
```

## License

Public repository – see source files for details.
