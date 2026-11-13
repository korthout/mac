# Dangers — areas with no owning domain skill

Where to aim review minutes in areas that have no domain skill to delegate to. This file exists
only to fill that gap; anything with an owner is delegated instead, never copied here.

Entries are phrased as **questions to check against the code**, not as assertions. Seeds below
were inferred from the module's role, not verified against its documentation — confirm on first
use and rewrite the entry with what you learn. When entries for one area accumulate, propose a
proper domain skill rather than growing this file.

## `clients/java`

- Does this change the public API surface (signatures, return types, removed methods)? Client
  code compiles against these — a source- or binary-incompatible change breaks users on upgrade
  and cannot be walked back once released.
- Is there an automated compatibility gate (revapi or similar) covering this, or is the change
  invisible to CI?

## `zeebe/exporters`

- Does the record → index mapping change? A changed or added field usually needs a schema
  migration for existing installations; without one, exporting fails or the field is silently
  dropped.
- Is re-export idempotent? Exporters resume from a stored position after restart, so records can
  be seen twice.
- Can a record now be skipped rather than exported? A skipped record is **silent data loss** in
  everything downstream that reads the index.

## `zeebe/protocol-impl`, `zeebe/protocol`

- Does a persisted record's serialized shape change? Old logs must still deserialize — replay and
  rolling upgrade read records written by earlier versions.
- Are added fields optional with a defined default for records written before they existed?

## `zeebe/gateway-protocol`, `zeebe/gateway-grpc`, `zeebe/gateway-rest`

- Is this a backwards-compatible change to a published contract? Clients on older versions keep
  calling the old shape.
- Do gRPC and REST stay consistent where they expose the same operation?

## `db/rdbms`, `db/rdbms-schema`

- Does the schema change? Existing installations need a migration; a changed or dropped column
  breaks them on startup.
- Is the migration reversible, and does it hold for every supported database vendor?

## `qa/acceptance-tests`

- Was an existing assertion weakened or removed rather than a new case added? That fails silently
  and hides the regression it used to catch.
