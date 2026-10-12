# Chapter 12: System Database

## Core Idea
The System Database (`SYST`) governs enterprise project security, user authentication, team structures, module access permissions, and fine-grained Access Control Rights (ACR).

## Frameworks Introduced
- **Role-Based Access Control (RBAC) & Team Security Framework**:
  - When to use: Managing user permissions, preventing unauthorized database modifications, and enforcing discipline segregation.
  - How: Users (`USER`) are assigned to Teams (`TEAM`). Databases are allocated read-write permissions per team. Access Control Rights (`ACR`, `ACRL`) specify granular rights (e.g. read, write, claim, modify, delete) down to individual element types.
- **Module and Operation Locking Model**:
  - When to use: Restricting administrative actions (like Lexicon dictionary editing or catalogue modification) to authorized lead engineers.
  - How: Command permissions (`CMMA`, `CMMO`, `CMOP`) regulate which CLI commands and GUI modules can be launched by a given user profile.

## Key Concepts
- **`ACR` (Access Control Right)**: Policy element defining read, write, or modify rules for target databases or element types.
- **`ACRL` (Access Control Right Reference)**: Link element attaching an `ACR` rule to a specific user or team.
- **`ACRW` (Access Control World)**: Top-level container for project security rules.
- **`USER`**: User account record holding login credentials, default MDB, and home directory.
- **`TEAM`**: Administrative group representing an engineering discipline or contractor team.
- **`MDB` (Multiple Database)**: Defined work profile packaging specific design, catalogue, and draft databases for a given project phase.
- **`CMOP` (Command Operation)**: Element restricting execution of sensitive commands.

## Mental Models
- **Think of `SYST` as the Gatekeeper and Passport Office**: It validates identity upon login and issues security credentials that determine which elements can be touched across all other databases.

## Anti-patterns
- **Assigning General Designers to Master Admin Teams**: Granting unrestricted write access to catalogue or system databases risks accidental schema corruption.
- **Ignoring Granular ACR on Replicated Sites**: Omitting access control rules on satellite sites can permit unauthorized local edits to shared databases.

## Code Examples
```pml
-- Checking active user and team credentials
Q USER
Q TEAM
Q MDB

-- Querying access rights on the current database
Q DBWRITE
Q CLAIMSTATUS
```
- **What it demonstrates**: Querying active user permissions, team allocation, and database write authorization.

## Reference Tables
| Element Mnemonic | Full Name | Primary Owner | Function |
|:---|:---|:---|:---|
| `ACRW` | Access Control World | Root | Root container for project security rules |
| `ACR` | Access Control Right | `ACRW` | Specific permission policy definition |
| `ACRL` | Access Control Link | `USER` / `TEAM` | Maps an `ACR` policy to a user or team |
| `USER` | User Element | Administrative | User account profile |
| `TEAM` | Team Element | Administrative | User discipline grouping |
| `MDB` | Multiple Database | Administrative | Project database collection profile |
| `CMOP` | Command Operation | Administrative | Command-level restriction rule |

## Worked Example
Restricting Catalogue modification rights to the Piping Materials Lead:
1. Project administrator accesses `SYST` database in Admin mode.
2. Identifies Catalogue database: `/CATA-MASTER-PIPING`.
3. Checks team allocations:
   - Team `/PIPING-DESIGN`: Assigned Read-Only (`ACR-READONLY`).
   - Team `/CATA-ADMIN`: Assigned Full Read-Write (`ACR-FULLWRITE`).
4. User `/J_DOE` belongs to `/PIPING-DESIGN`:
   - Logs into Design session: can select components from spec.
   - Attempts command `NEW CATEGORY`: System rejects with `Insufficient Access Rights`.

## Key Takeaways
1. The System Database (`SYST`) manages project security, users, and teams.
2. Access Control Rights (`ACR`) provide granular read/write security per element type and database.
3. Multiple Database profiles (`MDB`) configure the exact suite of databases opened per session.
4. Prevents unauthorized tampering with master catalogue and project schema definitions.

## Connects To
- **Ch 7 (Global Database)**: Coordinates with Global site administration.
- **Ch 1 (Introduction)**: Dictates whether commands can write to target databases.
