# Schema Airlock

> **Autonomous database migration rehearsal and safety gate**

Schema Airlock is an AI-powered migration safety agent that evaluates database schema changes before they can affect production.

Instead of allowing an agent or developer to directly apply a migration, Schema Airlock rehearses the change inside an isolated sandbox, measures its impact, verifies recovery, generates evidence, and stops at a human approval gate before any production action.

---

## The Problem

Database migrations can cause:

- Data loss
- Constraint failures
- Broken foreign-key relationships
- Unexpected schema changes
- Integrity regressions
- Irreversible production damage

A migration that succeeds syntactically is not necessarily safe.

Schema Airlock provides a controlled rehearsal before production.

---

## How It Works

```text
GitHub Migration / PR
        |
        v
Schema Airlock Agent
        |
        v
Inspect Migration
        |
        v
Isolated TrueForge Sandbox
        |
        v
Execute Migration
        |
        v
Integrity Analysis
        |
        +------------------+
        |                  |
        v                  v
     BLOCKED            VERIFIED
        |                  |
        +--------+---------+
                 |
                 v
          Evidence Report
                 |
                 v
        HUMAN APPROVAL GATE
                 |
          +------+------+
          |             |
        REJECT        APPROVE
          |             |
         STOP     Production Action



What the Agent Checks

Schema Airlock evaluates:

Migration execution success or failure
Row-count changes
NULL values
Duplicate values
Foreign-key violations
Schema changes
Integrity regressions
Database restoration
Whether production was mutated



Safety Boundary

The agent never modifies production during rehearsal.
The workflow is:Inspect
   ↓
Sandbox
   ↓
Execute
   ↓
Verify
   ↓
Generate Evidence
   ↓
STOP
   ↓
Human Approval
   ↓
Production Action

Human approval is mandatory before the irreversible production action.

Demo Scenarios
Scenario 1 — Unsafe Migration

The deliberately unsafe migration attempts to enforce a NOT NULL constraint while existing customer records contain NULL email values.

Migration:demo/migrations/001_enforce_email_integrity.sql
run:
python demo/seed.py
python demo/rehearse.py demo/migrations/001_enforce_email_integrity.sql


Expected result:
Decision: BLOCKED
Error: NOT NULL constraint failed
Schema changed: NO
Integrity regression: NO
The migration is stopped because the existing data does not satisfy the new constraint.

Scenario 2 — Safe Migration

The safe migration adds a last_verified_at field without damaging existing data.

Migration:
demo/migrations/002_add_last_verified_at.sql
python demo/seed.py
python demo/rehearse.py demo/migrations/002_add_last_verified_at.sql
Expected result:Decision: VERIFIED
Schema changed: YES
Integrity regression: NO

Even after verification, the agent stops at the human approval boundary instead of automatically changing production.

Recovery Verification

Schema Airlock also verifies that the database can be restored to its original state.

Run:python demo/rollback_check.py
Restoration verified: True
Production DB mutated: NO


This provides evidence that the rehearsal did not damage the original database state.

Why This Is an Agent

Schema Airlock does more than generate an answer.

The agent:

Reaches a real software repository.
Inspects the proposed migration.
Uses an isolated execution environment.
Executes the migration in the sandbox.
Collects before/after evidence.
Analyzes database integrity.
Determines VERIFIED or BLOCKED.
Generates an evidence report.
Stops before production.
Requires explicit human approval before production action.
TrueForge Integration

TrueForge provides the agent runtime and isolated execution environment.

The intended runtime flow is:
GitHub
   ↓
Schema Airlock Agent
   ↓
Schema Airlock Skill
   ↓
TrueForge Sandbox
   ↓
Migration Rehearsal
   ↓
Integrity Verification
   ↓
Evidence Report
   ↓
Human Approval
GitHub integration provides access to the migration source, while the TrueForge sandbox provides isolated execution.

Project Structure
schema-airlock/
│
├── agent/
│   ├── README.md
│   └── SKILL.md
│
├── demo/
│   ├── seed.py
│   ├── rehearse.py
│   ├── rollback_check.py
│   ├── PR_DESCRIPTION.md
│   └── migrations/
│       ├── 001_enforce_email_integrity.sql
│       ├── 002_add_last_verified_at.sql
│       └── README.md
│
├── docs/
│   └── judge-demo.md
│
├── scripts/
│   ├── run-practice.ps1
│   └── run-practice.sh
│
├── trueforge/
│   ├── agent-instructions.md
│   ├── agent-spec.json
│   └── README.md
│
├── README.md
└── .gitignore

Local Verification
Requirements
Python 3
SQLite
TrueForge for the agent runtime
Unsafe migration
python demo/seed.py
python demo/rehearse.py demo/migrations/001_enforce_email_integrity.sql
python demo/rollback_check.py
Expected:
BLOCKED
Safe migration
python demo/seed.py
python demo/rehearse.py demo/migrations/002_add_last_verified_at.sql
Expected:

VERIFIED
Technology
TrueForge
GitHub MCP
Python
SQLite
SQL
AI Agent / LLM
Isolated Sandbox Execution
Demo

The final demonstration shows two outcomes:

Unsafe migration

The agent detects a real integrity problem and blocks the migration.

Safe migration

The agent successfully rehearses the migration, verifies database integrity, generates evidence, and stops at the human approval boundary.

This demonstrates that the agent can act on a real software task while maintaining a clear safety boundary.

AI Tools Used
TrueForge
ChatGPT
AI coding assistance
GitHub MCP
Safety Principle

Rehearse first. Prove the impact. Stop before production

### After replacing it

Save the file, then run **only these two commands**:

```powershell
git add README.md
git commit -m "Polish hackathon README"
Then:git push
