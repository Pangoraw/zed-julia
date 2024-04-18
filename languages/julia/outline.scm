(import_statement
  ["using" "import"] @context
  [
   (selected_import (_) @name ":" @context)
   (( [(identifier) (scoped_identifier) (import_path)] @name  "," @context)*
      [(identifier) (scoped_identifier) (import_path)] @name)
  ]) @item

(module_definition
  ["module" "baremodule"] @context
  name: (identifier) @name) @item

(primitive_definition
  "primitive" @context
  "type" @context
  name: (identifier) @name) @item

(abstract_definition
  "abstract" @context
  "type" @context
  name: (identifier) @name
  (type_clause)? @context) @item

(function_definition
  "function" @context
  (signature
    (call_expression
      [
        (identifier) @name ; match foo()
        (field_expression _+ @context (identifier) @name .) ; match Base.foo()
      ]
      (argument_list)? @context)
    (_)* @context ; match the rest of the signature e.g., return_type and/or where_clause
  )) @item

; Match short function definitions like foo(x) = 2x.
; These don't have signatures so, we need to match eight different nested combinations
; of call_expressions with return types and/or where clauses.
; TODO: there may be an elegant way to handle nested combinations.
(assignment
  .
  [
    ; match `foo()` or `foo()::T` or `foo() where...` or `foo()::T where...`
    (call_expression . (identifier) @name (argument_list) @context)
    (typed_expression . (call_expression . (identifier) @name (argument_list) @context) "::" @context (_) @context)
    (where_expression . (call_expression . (identifier) @name (argument_list) @context) "where" @context (_) @context)
    (where_expression . (typed_expression . (call_expression . (identifier) @name (argument_list) @context) "::" @context (_) @context) "where" @context (_) @context)
    ; match `Base.foo()` or `Base.foo()::T` or `Base.foo() where...` or `Base.foo()::T where...`
    (call_expression . (field_expression _+ @context (identifier) @name .) (argument_list) @context)
    (typed_expression . (call_expression . (field_expression _+ @context (identifier) @name .) (argument_list) @context) "::" @context (_) @context)
    (where_expression . (call_expression . (field_expression _+ @context (identifier) @name .) (argument_list) @context) "where" @context (_) @context)
    (where_expression . (typed_expression . (call_expression . (field_expression _+ @context (identifier) @name .) (argument_list) @context) "::" @context (_) @context) "where" @context (_) @context)
  ]) @item

(macro_definition
  "macro" @context
  (signature
    (call_expression
      [
        (identifier) @name ; match foo()
        (field_expression _+ @context (identifier) @name .) ; match Base.foo()
      ]
      (argument_list)? @context)
    (_)* @context ; match the rest of the signature e.g., return_type
  )) @item

(struct_definition
  "mutable"? @context
  "struct" @context
  name: (_) @name
  (type_parameter_list)? @context) @item

(const_statement
  "const" @context
  (assignment
    (_) @name
    (operator)
    (_))) @item
