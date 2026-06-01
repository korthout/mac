---
name: reference-run-qa-integration-tests
description: "How to actually run a single test in zeebe/qa/integration-tests — they run via failsafe, not surefire"
metadata: 
  node_type: memory
  type: reference
  originSessionId: f127ddef-2e67-4459-bdd2-97c699b901e5
---

Tests under `zeebe/qa/` (e.g. `zeebe/qa/integration-tests`) run via the **failsafe** plugin, NOT surefire — `zeebe/qa/pom.xml` hardcodes `<skip>true</skip>` for surefire. This is true even for classes whose names end in `Test` (not just `*IT`); failsafe's include pattern covers `**/*Test.java` there.

**Consequence:** `-Dtest=Foo#bar -DskipITs` will report BUILD SUCCESS while *silently skipping* the test (surefire is skipped, failsafe is disabled). You think it passed; it never ran.

**Beware the skip chain:** in `parent/pom.xml`, failsafe's `<skip>` binds to `${skipITs}`, and `skipITs` → `skipTests` → `quickly`. So passing `-Dquickly` (or `-DskipTests`) forces the skip and `-DskipITs=false` alone does NOT break the chain — every failsafe phase logs "Tests are skipped" and you get a false BUILD SUCCESS. You MUST also add **`-DskipTests=false`**.

**Correct invocation** (single test, single method):
```
mvn install -pl zeebe/qa/integration-tests -am -Dquickly -T1C   # build deps first
mvn verify  -pl zeebe/qa/integration-tests -Dit.test='BrokerReprocessingTest#shouldTriggerTimerAfterRestart' \
  -DskipITs=false -DskipTests=false -DskipUTs=true -Dfailsafe.failIfNoSpecifiedTests=false -Dquickly -DskipChecks=true -T1C
```
Use `-Dit.test=` (failsafe) and BOTH `-DskipITs=false -DskipTests=false`, not `-Dtest=`. Add `-Dfailsafe.failIfNoSpecifiedTests=false` so other modules don't fail the run. Verify the test actually ran: look for a "T E S T S" block and `Tests run: N` with N>=1, not "Tests are skipped".
