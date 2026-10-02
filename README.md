# BPC Advanced Script Language

BPC Advanced Script Language (ASL) is a proposed SAP BPC Standard calculation
application. It combines a consultant-friendly calculation language with a
governed ABAP runtime built on standard SAP BPC and BW APIs.

## Documentation

- [docs/SPECIFICATION.md](docs/SPECIFICATION.md) — authoritative product and technical specification.
- [docs/REQUIREMENTS.md](docs/REQUIREMENTS.md) — extracted normative requirements with stable IDs.
- [docs/IMPLEMENTATION-STATUS.md](docs/IMPLEMENTATION-STATUS.md) — traceability status per requirement.
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — layered architecture and dependency direction.
- [docs/DECISIONS.md](docs/DECISIONS.md) — architecture/design decision log (ADRs) and open questions.
- [docs/TEST-PLAN.md](docs/TEST-PLAN.md) — test strategy across compiler, runtime, and SAP integration.
- Phase slices: [Phase 0](docs/phases/PHASE-0-LANGUAGE-PROTOTYPE.md), [Phase 1](docs/phases/PHASE-1-WORKBENCH.md), [Phase 2](docs/phases/PHASE-2-WRITEBACK.md), [Phase 3](docs/phases/PHASE-3-CALCULATIONS.md), [Phase 4](docs/phases/PHASE-4-HIGH-VOLUME.md).

The repository currently contains the specification and project-management
documentation only; no runtime code has been implemented. Implementation must
remain compatible with SAP BPC 10.1 on SAP NetWeaver 7.52 and SAPUI5 1.52.

