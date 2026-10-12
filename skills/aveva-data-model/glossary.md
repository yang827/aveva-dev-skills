# Glossary — AVEVA Data Model Reference Manual

**ACR (Access Control Right)** — Security policy element regulating read, write, modify, or delete operations on databases or element classes (Ch 12).
**ACRL (Access Control Link)** — Administrative link element binding an ACR policy to a specific user or team (Ch 12).
**ACRULE (Annotation Change Rule)** — Dynamic rule governing how drawing labels and dimensions adapt when 3D geometry shifts (Ch 6).
**ACSTYLE (Annotation Change Style)** — Graphic styling template defining fonts, arrowheads, colors, and layers for 2D drafting (Ch 6).
**ALIST (Attribute List)** — Dynamic pseudo attribute returning the complete array of valid attributes on the current element (Ch 15).
**ARRI (Arrive P-point)** — Integer designation identifying the flow entry port of a piping or HVAC inline component (Ch 4, Ch 15).
**ATTCOLUMN** — Column projection element defining attribute representation in database views (Ch 5).
**ATTFILTER** — Logical filtering rule element restricting which elements match a database view (Ch 5).
**AWELD (Attached Weld)** — Explicit tagged weld element carrying unique traceability and inspection IDs (Ch 11).
**BBOX (Bounding Box)** — Dynamic pseudo attribute returning the minimum and maximum 3D spatial extents of an element (Ch 15).
**BLIST (Bolt List)** — Catalogue element defining permissible bolt sets for a bolt table (Ch 2).
**BLTABLE (Bolt Table)** — Master catalogue lookup table defining bolt sizes, quantities, and lengths for flanged joints (Ch 2).
**BRAN (Branch)** — Secondary piping element representing a continuous flow route between head and tail termini (Ch 4).
**BRTAB (Branch Table)** — Catalogue decision matrix selecting branch reinforcement fittings based on header and branch bores (Ch 2).
**CABDATA (Cable Data)** — Property database record defining physical and electrical ratings of a cable type (Ch 9).
**CATA (Catalogue Database)** — Core repository holding dimensional, geometric, bolting, and connection templates (Ch 2).
**CATEGORY** — Catalogue container grouping parametric component definitions sharing geometry and point sets (Ch 2).
**CCTABLE (Connection Compatibility Table)** — Catalogue lookup table defining permissible mating connection pairs (Ch 2).
**CE (Current Element)** — Active contextual database element against which unqualified commands and queries execute (Ch 1).
**CLOSEFLAG** — Boolean pseudo attribute indicating whether a piping branch forms a closed fluid loop (Ch 15).
**COCO (Connection Compatibility)** — Individual compatibility rule element linking connection types (Ch 2).
**COMM (Communication Element)** — Inter-process messaging channel or daemon endpoint in the communications database (Ch 3).
**CPIN (Pin Element)** — Adjustable hydraulic pin record specifying height and inclination on curved plate assembly beds (Ch 8).
**CPINJG (Pin Jig)** — Manufacturing assembly bed element containing rows of adjustable pins for shell plate bending (Ch 8).
**CRFA (Coordinates Relative to Father)** — Dynamic pseudo attribute returning an element's position relative to its owner (Ch 15).
**CUTL (Cut Length)** — Dynamic pseudo attribute returning the exact fabrication length of straight pipe or structural steel (Ch 15).
**DBALL (Database Allocation)** — Global database element assigning primary write ownership of a database to a specific site (Ch 7).
**DBLOC (Database Location)** — Global database record representing an individual engineering office node (Ch 7).
**DBVW (Database View)** — Dictionary definition compiling element attribute projections for structured reporting (Ch 5).
**DEPT (Department)** — Top-level discipline container in the Draft database hierarchy (Ch 6).
**DESI (Design Database)** — Core 3D spatial database housing equipment, piping, structural, and electrical models (Ch 4).
**DICT (Dictionary Database)** — Schema catalog defining User-Defined Attributes (UDAs) and custom views (Ch 5).
**DIR (Direction)** — Spatial vector attribute defining 3D pointing direction (Ch 16).
**DRAF (Draft Database)** — Repository for 2D engineering drawings, projection views, and associative annotations (Ch 6).
**DRWG (Drawing)** — Master drawing container holding one or more drafting sheets (Ch 6).
**DTABLE (Diameter Table)** — Catalogue lookup table for nominal diameter conversions and bore mappings (Ch 2).
**ENGGRP (Engineering Group)** — Classification group container in the Engineering Database (Ch 14).
**ENGITE (Engineering Item)** — Master engineering tag record acting as the single cross-discipline source of truth (Ch 14).
**EQUI (Equipment)** — Primary mechanical equipment container in the Design database (Ch 4).
**FIELD (Field Joint)** — Erection joint designation indicating a weld or connection completed on site (Ch 11).
**GLOB (Global Database)** — Multi-site administrative database managing distributed replication and ownership (Ch 7).
**GMSE (Geometry Set)** — Catalogue container holding 3D geometric primitives that form component envelopes (Ch 2).
**HREF / TREF (Head / Tail Reference)** — Pointers to elements where a piping branch connects at its start and end (Ch 4).
**IWELD (Implicit Weld)** — Workshop shop weld element connecting fittings within a pipe spool (Ch 11).
**LEAV (Leave P-point)** — Integer designation identifying the flow exit port of a piping or HVAC component (Ch 4, Ch 15).
**LOCK** — Administrative boolean attribute preventing accidental editing or deletion of an element (Ch 16).
**MANPKG (Manufacturing Package)** — Work package container grouping plates and profiles for cutting and assembly (Ch 8).
**MANU (Manu Database)** — Shipyard and fabrication database managing NC cutting, bending, and assembly data (Ch 8).
**MDB (Multiple Database)** — Session profile specifying the collection of active project databases (Ch 1, Ch 12).
**MBURN (Burn Element)** — Cutting contour definition including cutting speed and edge bevel preparations (Ch 8).
**NAME** — Unique system-wide identifier attribute starting with a forward slash (Ch 16).
**NOZZ (Nozzle)** — Equipment connection port carrying bore, rating, and P-point definition (Ch 4).
**ORI (Orientation)** — Rotational attitude attribute defined by two orthogonal axis vectors (Ch 16).
**OWNER** — Upward lineage reference pointing to an element's direct parent in the database tree (Ch 1).
**P-point (Point)** — Parametric connection port (`P0` to `Pn`) defining position, bore, connection type, and direction (Ch 2, Ch 4).
**PANE (Panel)** — Planar structural plate boundary representing decks, bulkheads, or floors (Ch 4).
**PIPE** — Primary piping container owning one or more continuous flow branches (`BRAN`) (Ch 4).
**POS (Position)** — 3D Cartesian coordinates expressed as Easting, Northing, and Elevation (Ch 16).
**Primary Element** — Major administrative or discipline element that can exist directly under world or zone parents (Ch 1).
**PROP (Property Database)** — Catalog of physical material properties, cable sizing charts, and engineering data (Ch 9).
**PTSE (Point Set)** — Catalogue container defining P-points for component connection and alignment (Ch 2).
**SCDIAGRAM** — Master drawing sheet container for 2D P&ID and schematic diagrams (Ch 10).
**SCHE (Schematic Database)** — Repository for 2D process stream topology and schematic instrument loops (Ch 10).
**SCPIPE / SCBRANCH** — Schematic process stream and branch records capturing fluid connectivity without 3D geometry (Ch 10).
**SCTN (Section)** — Extruded structural steel member referencing catalogue profile cross-sections (Ch 4).
**Secondary Element** — Sub-element or component that can only exist inside a valid primary element owner (Ch 1).
**SHEE (Sheet)** — Drawing sheet element specifying page dimensions and title block format (Ch 6).
**SITE** — Top-level geographic or project area container in the Design database (Ch 4).
**SPOO (Spooler Database)** — Fabrication database managing pipe spool breakdowns and fabrication isometrics (Ch 11).
**SPOOL** — Prefabricated pipe sub-assembly shippable as a single unit to the site (Ch 11).
**SPREF (Specification Reference)** — Pointer from a design component to its governing piping specification and catalogue item (Ch 2, Ch 4).
**STRU (Structure)** — Primary structural framework container in the Design database (Ch 4).
**SYST (System Database)** — Administrative database managing users, teams, security, and project access rights (Ch 12).
**TEAM** — Administrative discipline group in the System database (Ch 12).
**TRAN (Transaction Database)** — Audit repository logging chronological modification history and commit events (Ch 13).
**TRDAY / TRMONTH** — Calendar elements organizing database transaction history (Ch 13).
**UDA (User Defined Attribute)** — Custom engineering attribute defined in Lexicon and prefixed with a colon (Ch 5).
**USER** — Account profile record in the System database (Ch 12).
**VIEW** — 2D projection camera in the Draft database rendering a scaled view of 3D design geometry (Ch 6).
**WORL (World)** — Root ancestor node of an AVEVA database tree (Ch 1, Ch 4).
**WVOL (World Volume)** — Dynamic pseudo attribute computing total geometric volume of an element (Ch 15).
**ZONE** — Functional sub-area container in the Design database owned by a Site (Ch 4).
