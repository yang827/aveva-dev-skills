# Chapter 13: Transaction Database

## Core Idea
The Transaction Database (`TRAN`) records chronological database history, user transaction logs, commit records, audit trails, and command histories across the lifecycle of the project.

## Frameworks Introduced
- **Database Transaction Logging & Audit Framework**:
  - When to use: Tracking who modified, created, or deleted an element, when changes occurred, and auditing engineering modifications across project milestones.
  - How: The system logs database operations under a calendar hierarchy (`TRMONTH`, `TRDAY`). Each logged entry captures the operating session, user identity, timestamp, and transaction command records (`TRINCOMMAND`, `TRMESSAGE`).
- **Failure Recovery & Rollback Model**:
  - When to use: Diagnosing session crashes, uncommitted network drops, or corrupt transaction states.
  - How: Transaction failure elements (`TRFAILURE`, `TRFLST`) document failed commit events, enabling database repair utilities to roll back partial writes to the last valid database checkpoint.

## Key Concepts
- **`TRMONTH` / `TRDAY`**: Calendar-based grouping elements partitioning transaction history by month and day.
- **`TRINCOMMAND`**: Encapsulates the specific command string or macro instruction executed during a transaction.
- **`TRMESSAGE`**: System notification or status report logged during transaction commit or sync.
- **`TRFAILURE`**: Record generated when a database write fails due to disk errors, network timeouts, or lock conflicts.
- **`TRLOCATION`**: Records the geographic project site where the transaction originated (in Global multi-site projects).
- **Session Checkpoint**: Consistent database save point to which an administrator can restore prior state.

## Mental Models
- **Think of `TRAN` as the Project's Black Box Flight Recorder**: It records every write operation, providing an immutable audit trail of how the model reached its current state.

## Anti-patterns
- **Disabling Transaction Logging During Bulk Data Imports**: While speeding up ingestion, skipping transaction logs makes selective rollbacks impossible if errors occur.
- **Treating `TRAN` as a Direct Modification Target**: Editing transaction logs manually breaks sequence checksums.

## Code Examples
```pml
-- Querying history and modification tracking on Current Element
Q SESSIONS
Q LASTMOD
Q USERMOD

-- Inspecting transaction history for an element
VAR !hist EVALUATE (HISTORY) FOR CE
Q VAR !hist
```
- **What it demonstrates**: Querying modification history, last modifier, and session timestamps for the active element.

## Reference Tables
| Element Mnemonic | Full Name | Primary Owner | Role |
|:---|:---|:---|:---|
| `TRMONTH` | Transaction Month | Transaction World | Monthly container of transaction records |
| `TRDAY` | Transaction Day | `TRMONTH` | Daily container of transactions |
| `TRINCOMMAND` | Transaction Command | `TRDAY` | Specific command string executed |
| `TRMESSAGE` | Transaction Message | `TRDAY` | System event or diagnostic message |
| `TRFAILURE` | Transaction Failure | `TRFLST` | Log of failed commit attempt |
| `TRLOCATION` | Transaction Location | `TRDAY` | Site origin of the logged transaction |

## Worked Example
Auditing unexpected changes to a critical equipment nozzle:
1. Engineer notices nozzle `/V-101-N1` orientation shifted from `DIR U` to `DIR E`.
2. Engineer queries modification history:
   ```pml
   /V-101-N1
   Q LASTMOD
   -- Returns 2026-10-10 14:22:15
   Q USERMOD
   -- Returns /USER-JSMITH
   Q SESSIONS
   -- Returns Session 42
   ```
3. Administrator inspects `TRDAY` for that date:
   - Locates `TRINCOMMAND` in Session 42: `ORI AND DIR E`.
   - Verifies the engineering change order justifying the update.

## Key Takeaways
1. The Transaction Database (`TRAN`) provides complete auditability of all model changes.
2. Changes are organized chronologically under `TRMONTH` and `TRDAY` elements.
3. Captures user identity, session ID, timestamp, and command context.
4. Failure elements (`TRFAILURE`) facilitate database recovery after crashes or network drops.

## Connects To
- **Ch 7 (Global Database)**: Feeds transaction change packets between replication sites.
- **Ch 12 (System Database)**: Associates transaction events with specific `USER` accounts.
