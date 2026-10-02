# Phase 0 — Language Prototype

Executable language prototype with no BPC dependency. Validates the grammar, the
scalar type system, the in-memory dataset model, and in-memory execution against
representative scripts.

## Requirement IDs

- ASL-LANG-001..ASL-LANG-012 (grammar, parameters, member-set expressions)
- ASL-TYPE-001..ASL-TYPE-013 (scalar/composite types, parameters, dataset shape)
- ASL-DATA-001..ASL-DATA-008, ASL-DATA-010..ASL-DATA-019 (dataset transforms and reads)
- ASL-META-001, ASL-META-005, ASL-META-006, ASL-META-010 (binding, metadata signature, test adapter)
- ASL-PROD-044 (tests for parser/semantic/execution)

Full per-requirement mapping is in [../IMPLEMENTATION-STATUS.md](../IMPLEMENTATION-STATUS.md).

## Scope

- Tokens and source-location diagnostics.
- Lexer for keywords, identifiers, quoted values, numbers, dates, and comments.
- Parser producing an AST with syntax-error recovery.
- Deterministic formatter.
- Scalar type system (NUMBER, INTEGER, TEXT, BOOLEAN, DATE, PERIOD, MEMBER OF, MEMBERS OF, DATASET, REGION).
- In-memory dataset model with schema, grain, and lineage.
- In-memory executor for FILTER, CALCULATE, MAP, TRANSPOSE, GROUP BY, JOIN (with cardinality), UNION, and GENERATE.
- Test metadata adapter returning fixture dimensions, properties, hierarchies, and members.
- Representative language examples from §8, §11, §12, §13, §15, §16, §18.

## Excluded scope

- BPC/BW calls, write-back, persistence, UI, HTTP API, extension registry, background runs, allocation/time-series libraries beyond prototype fixtures.

## Expected objects or files

- ABAP: lexer, parser, AST, formatter, binder/type checker, in-memory dataset executor, test metadata adapter (proposed names in §25; naming may change).
- Test data: fixture metadata and representative `.asl` scripts.

## Acceptance criteria

- All representative scripts tokenize, parse, bind, and execute in memory.
- Syntax and type errors carry source locations.
- Formatter output is deterministic.
- Dataset transforms preserve schema, grain, and lineage; writes validate one-value-per-key.

## Required tests

- Lexer/parser, formatter, type checking, in-memory dataset execution, joins and cardinality (see [../TEST-PLAN.md](../TEST-PLAN.md) §1–§6).

## Dependencies

- None beyond the repository skeleton and SPECIFICATION.md.


