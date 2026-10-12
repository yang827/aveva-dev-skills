# Chapter 7: Global Database

## Core Idea
The Global Database (`GLOB`) manages multi-site project replication, distributed database allocations, communication routing, and data ownership across geographically dispersed design teams.

## Frameworks Introduced
- **Multi-Location Hub-and-Spoke Replication Framework**:
  - When to use: Coordinating work across distributed engineering offices (e.g. London Hub with Houston and Singapore Satellite sites).
  - How: The `GLOB` database defines locations (`GLOCWL`, `DBLOC`), database allocations (`DBALL`), and replication daemon channels. Primary ownership of database files or element ranges is assigned to specific physical project sites.
- **Data Allocation and Claiming Model**:
  - When to use: Modifying elements in replicated databases while preventing merge conflicts.
  - How: Only the location holding the write allocation (`DBALL`) or element claim can commit modifications. Satellite offices receive updates via background transaction extract daemons.

## Key Concepts
- **`GLOCWL` (Global Location World)**: Administrative root container for all registered physical project sites.
- **`DBLOC` (Database Location)**: Represents a specific design office, server, or engineering location in the Global network.
- **`DBALL` (Global Database Allocation)**: Record binding a project database to a designated primary location.
- **`DB` / `DBLI`**: Database definitions and database list allocations within the project.
- **`GRP` (Global Group)**: Grouping mechanism for managing access and replication policies across multiple project databases.
- **Hub Site**: Central administrative location responsible for schema changes, user management, and global synchronization.
- **Satellite Site**: Distributed engineering node that synchronizes with the Hub and holds local write permissions for allocated databases.

## Mental Models
- **Think of Global as a Distributed Version Control Branching Model with Token Ownership**: Multiple offices can read all data, but only the location holding the database token can modify and commit changes.

## Anti-patterns
- **Attempting Local Writes on Remote-Allocated Databases**: Modifying elements allocated to a remote satellite site without transferring allocation causes immediate command rejection.
- **Direct Filesystem Syncing of Replicated DBs**: Using external tools (like rsync or OneDrive) to sync active AVEVA database files corrupts internal Global transaction counters.

## Code Examples
```pml
-- Querying current site location in Global
Q CURRENT LOCATION
Q ALL DBLOC
Q DBNAME FOR ALL DB

-- Checking database allocation
Q ALLOC FOR /DESI-PIPING-01
```
- **What it demonstrates**: Administrative queries for verifying active project site locations and database allocations.

## Reference Tables
| Element Mnemonic | Full Name | Primary Owner | Purpose |
|:---|:---|:---|:---|
| `GLOCWL` | Global Location World | Root | Root container for all physical sites |
| `DBLOC` | Database Location | `GLOCWL` | Specific engineering office node |
| `DBALL` | Global DB Allocation | `DBLOC` | Assigns write ownership of a DB to a site |
| `DB` | Database Definition | Administrative | Individual database file registration |
| `GRP` | Global Group | `GLOCWL` | Collection of synchronized databases |

## Worked Example
Transferring write allocation of a piping database from London to Singapore:
1. Administrator at London Hub checks active allocation:
   - `Q ALLOC FOR /PIPING_AREA3_DB` -> returns `/LONDON_OFFICE`.
2. Administrator executes allocation transfer command:
   - Allocation token marked for export to `/SINGAPORE_OFFICE`.
3. Communication daemon transfers transaction packet:
   - Singapore node receives update and accepts allocation.
4. Singapore designers now hold read-write status; London designers switch to read-only for that specific DB.

## Key Takeaways
1. Global Database (`GLOB`) enables seamless multi-site global engineering execution.
2. Every database is allocated to a specific physical location (`DBLOC`) to prevent conflicting writes.
3. Hub-and-satellite architectures ensure unified data integrity across international teams.
4. Data transfers occur strictly via internal transaction messaging protocols.

## Connects To
- **Ch 3 (Communications Database)**: Interfaces with network communication daemons.
- **Ch 13 (Transaction Database)**: Relies on transaction logs for inter-site data packets.
