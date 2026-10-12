# Chapter 3: Communications Database

## Core Idea
The Communications Database (`COMM`) manages inter-process communication, real-time messaging, and multi-user synchronization across distributed AVEVA processes and design sessions.

## Frameworks Introduced
- **Inter-Process Messaging Framework**:
  - When to use: Coordinating multi-user collaborative design sessions, broadcasting database change notifications, and handling lock acquisition.
  - How: The system utilizes `COMW` (Communication World) and `COMM` (Communication Element) records to route messages, status updates, and session states between local client sessions and server daemons.

## Key Concepts
- **`COMW` (Communication World Element)**: The top-level administrative root element of the Communications Database.
- **`COMM` (Communication Element)**: Represents an active communication channel, process link, or messaging endpoint within the AVEVA session network.
- **Message Dispatching**: The automated distribution of event triggers (such as element claims or release requests) across connected sessions.
- **Daemons / Communication Processes**: Background services that listen on sockets or IPC queues registered within the `COMM` database.

## Mental Models
- **Think of the Communications DB as the Switchboard**: It does not store physical engineering geometry; it maintains the active operational circuits connecting cooperating design sessions.

## Anti-patterns
- **Manual Tampering with `COMM` Records**: Direct command-line edits to active `COMM` records can desynchronize session state machines and cause ghost session locks.

## Code Examples
```pml
-- Querying communication status in administrative sessions
Q DBTYPE COMM
Q NAME FOR ALL COMM
```
- **What it demonstrates**: Administrative query of registered communication elements.

## Reference Tables
| Element Mnemonic | Full Name | Legal Owners | Legal Members | Role |
|:---|:---|:---|:---|:---|
| `COMW` | Communication World | Root | `COMM` | Root container for communication entities |
| `COMM` | Communication Element | `COMW` | None | Individual communication link/channel |

## Worked Example
When User A requests to claim an equipment item currently checked out by User B in a multi-write project:
1. User A triggers a claim request in the Design session.
2. The core system logs an event via the `COMM` network to the message queue of User B.
3. User B's session receives the notification dialog asking to release or retain the element.

## Key Takeaways
1. `COMM` database handles runtime inter-session connectivity and event dispatching.
2. Structured simply around `COMW` and `COMM` elements.
3. Essential for multi-user coordination and administrative daemons.

## Connects To
- **Ch 7 (Global Database)**: Coordinates with Global replication daemons.
- **Ch 12 (System Database)**: Interacts with user sessions and access rights.
