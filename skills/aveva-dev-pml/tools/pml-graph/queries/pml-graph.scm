; ---------------------------------------------------------------------------
; pml-graph.scm -- single tree-sitter query feeding tools/pml-graph/build-pml-graph.ps1
;
; Grammar: ../pml-parse/bin/pml.dll (tree-sitter-pml, language ABI 15, 249 symbols).
;
; IMPORTANT: build-pml-graph.ps1 dispatches on the *capture name*, never on the
; pattern index, so patterns may be reordered or appended freely. The capture
; names are the contract between this file and the builder.
;
; Only captures the builder consumes are declared. Extra "root" captures (a
; trailing @x per pattern) are deliberately omitted: they would multiply the CLI
; output without adding information, and a full-corpus run already streams
; ~750k captures.
;
; Node shapes verified against the bundled PMLLIB snapshot:
;   function_definition name: (global_variable)      !!name
;   object_definition  name: (identifier)            NAME
;   form_definition    name: (global_variable)       !!name
;   method_definition  name: (dot_identifier)        .name
;   member_declaration name: (dynamic_member_name)   .name
;   ui_control type: (ui_control_type) name: (control_name) (callback_clause target: (string))
;   command_statement name: (command_name (identifier)) (string)            -- title/init/okcall/...
;   command_statement name: (command_name (dollar_variable)) (identifier)   -- $GOTO/$LABEL
;   slash_path                                                              -- /TT/... CDB path
;   object_instantiation type: (_)                                          -- object NETGRIDCONTROL()
; ---------------------------------------------------------------------------

; --- definitions ----------------------------------------------------------
; Two captures per definition on purpose: @def.* is the *name* node (whose text
; identifies the callable), @span.* is the whole definition, whose start/end rows
; let the builder attribute every call in the body to its owner. The name node's
; own span covers a single line, so it cannot serve that purpose.
(function_definition name: (global_variable) @def.function) @span.function
(object_definition name: (identifier) @def.object) @span.object
(form_definition name: (global_variable) @def.form) @span.form
(method_definition name: (dot_identifier) @def.method) @span.method

; --- object members -------------------------------------------------------
(member_declaration name: (dynamic_member_name) @member)

; --- calls ----------------------------------------------------------------
; A `!!` target is a global function, resolvable to a .pmlfnc file.
(call_expression function: (global_variable) @ref.global)
; A bare identifier is a runtime built-in: STRING(), array(), undefined(), ...
(call_expression function: (identifier) @ref.builtin)

; --- form gadgets and the callback literal they own -----------------------
; One pattern yields type + name + raw callback text, so every callback stays
; attributed to the control that fires it.
(ui_control type: (ui_control_type) @ui.type name: (control_name) @ui.name (callback_clause target: (string) @ui.callback))

; --- form level clauses (title / init / okcall / cancelcall / ...) ---------
(command_statement name: (command_name (identifier) @cmd.name) (string) @cmd.string)

; --- interop --------------------------------------------------------------
(import_statement dll: (string) @import.dll)
(using_statement namespace: (string) @import.namespace)

; --- CDB element paths ----------------------------------------------------
(slash_path) @ref.dbpath

; --- access to a system global (!!ce.mcount(), !pml.getpathname(...), ...) --
; The write-capable shapes are listed first so the builder sees mark.write
; before the plain-member fallback for the same node.
(assignment target: (member_access object: (global_variable) @gm.object property: (identifier) @gm.property)) @mark.write

(member_access object: (global_variable) @gm.object property: (identifier) @gm.property)

; --- object instantiation -------------------------------------------------
(object_instantiation type: (_) @ref.new.type)

; --- PML 1 control flow ($GOTO / $LABEL are command statements) ----------
(command_statement name: (command_name (dollar_variable) @cmd.dollar) (identifier) @cmd.arg)

; --- syntax recovery nodes (still leaves a usable tree) -------------------
(ERROR) @parse.error
