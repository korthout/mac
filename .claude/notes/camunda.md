# camunda/camunda notes

My additions to the `engine-expert` skill and to running `zeebe/qa` integration tests. Where they disagree with `engine-expert` or `AGENTS.md`, these win.

**Share when used.** These notes are not in the repo yet. When one of them shapes your work in a session, say so in one line and ask whether to propose it to the repo. Name where it would go (the file in brackets after each heading).

## Engine tests (`engine-expert/testing.md`, `AGENTS.md`)

- **Assert event intents, not command intents.** Assert `JobIntent.TIMED_OUT`, not `TIME_OUT`. A command only asks for something, and can be written more than once (e.g. the timeout checker re-issues `TIME_OUT` under a jumped clock; the processor rejects the duplicate). Events are the outcome. Filter with `withRecordType(RecordType.EVENT)`.
- **Drive `EngineRule` tests with commands, not seeded events.** To avoid state reads, send commands (engine client, or `writeRecords` with commands) and assert on records or on what a client gets back. A seeded event copies what the processor writes today, so the test keeps passing when production changes. Seeding is fine now and then, with a good reason. Refines `engine-expert`'s "never assert on state": tests that check a system property, like `ProcessExecutionCleanStateTest` (no state left behind), check state by design.
- **Verify claims about a test class yourself** before suggesting changes to it. Don't relay an author's summary.
- **`.describedAs`, not `// then` comments.** Keep `// given`, `// when`, `// then` as bare markers. Put what an assertion checks in AssertJ `.describedAs("...")`, so it shows in the failure message. Example: `MigrateServiceTaskTest#shouldWriteMigratedEventForJob`.

## Engine processing (`zeebe/engine/README.md` do's and don'ts, `engine-expert/processors.md`)

- **Follow-up commands share the transaction.** `ProcessingStateMachine.batchProcessing` drains appended commands in the same `zeebeDbTransaction` and write batch. A loop that appends a follow-up per K mutations can put 100×K mutations in one batch. Limits: `DEFAULT_MAX_COMMANDS_IN_BATCH = 100`, and the 4 MiB `maxFragmentSize` (rolls back and retries smaller). To force a later transaction, override `TypedRecordProcessor#shouldProcessResultsInSeparateBatches()` (per processor, whole result; `BatchOperationExecutionExecuteProcessor` does). `MessageBatchExpireProcessor` doesn't, which may explain #50155.
- **No range delete in Zeebe state.** `WriteBatchWithIndex` rejects `deleteRange` at runtime (`DeleteRange unsupported in WriteBatchWithIndex`), though `javap` suggests it works. `deleteRange` on the `RocksDB` handle bypasses the batch and breaks rollback and read-your-own-writes. All `ZbColumnFamilies` share one physical column family with an 8-byte ordinal prefix, so a wrong range bound deletes another feature's state.
- **Measure before designing a drain loop.** Key-by-key delete is cheap and linear (laptop: 10k keys ≈ 12ms, 100k ≈ 84ms). Capping how much state builds up is often simpler than draining it in steps.
- **Review gap: `TypedResponseWriter.writeEventOnCommand`.** Such calls look like they meet "a processor must append an event or a rejection", but they don't.
- **Review gap: new properties on hot-path records.** A new declared property on a record like `JobRecord` costs on every record, forever. Weigh it against reusing a field with clear command and event meanings.

## QA integration tests (new `zeebe/qa/README.md`)

- **They run with Failsafe, not Surefire.** `zeebe/qa/pom.xml` skips Surefire, even for `*Test` classes. `-Dtest=` runs nothing and still reports BUILD SUCCESS.
- **Break the skip chain.** Failsafe's skip binds to `skipITs` → `skipTests` → `quickly`. With `-Dquickly`, `-DskipITs=false` alone still skips. Add `-DskipTests=false`.
- **They load installed JARs.** The broker uses the artifacts in `~/.m2`, not your sources. `install` changed modules first, or you test stale code. Check with `unzip -l <jar> | grep <NewClass>`.
- **Invocation:**
  ```
  mvn install -pl zeebe/qa/integration-tests -am -Dquickly -T1C
  mvn verify -pl zeebe/qa/integration-tests -Dit.test='Class#method' \
    -DskipITs=false -DskipTests=false -DskipUTs=true \
    -Dfailsafe.failIfNoSpecifiedTests=false -Dquickly -DskipChecks=true -T1C
  ```
  Confirm it ran: look for `Tests run: N` with N ≥ 1, not "Tests are skipped".
