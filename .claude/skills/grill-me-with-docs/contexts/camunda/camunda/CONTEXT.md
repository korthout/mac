# camunda/camunda

Camunda 8 monorepo. Terms are grouped by module path.

## zeebe/gateway

How the gateway handles `ActivateJobs` requests from job workers.

### Language

**Long poll**:
An `ActivateJobs` request that the gateway keeps open when no jobs are available, instead of responding right away.
_Avoid_: job poll, activation request (these also cover requests that are answered right away)

**Job activation sweep**:
One go over all partitions, asking each to activate jobs for the request.
_Avoid_: pass, round, round-robin (that's the algorithm that orders the sweep)

**requestTimeout**:
How long the gateway keeps a **Long poll** open before it sends an **Empty response**; 0 means the gateway default (10s), negative means no **Long poll**.
_Avoid_: long polling timeout, long poll duration

**Client deadline**:
The point in time at which the client cancels the request, counted from when the client sends it.
_Avoid_: "a 10s deadline" (that's the `grpc-timeout`, the duration the client sends to set the deadline)

**Gateway deadline**:
The gateway's copy of the **Client deadline**, counted from `grpc-timeout` when the request arrives, and so a little later than the **Client deadline**.

**Empty response**:
The OK response without jobs that the gateway sends when a **Long poll**'s **requestTimeout** passes.
_Avoid_: timed out (also used for a passed deadline)

**Margin**:
How much earlier than its **requestTimeout** the gateway ends a **Long poll**: a fixed duration (50ms by default, configurable by operators), because the time it covers (the gateway's own work, and for nearby clients the round trip) does not grow with the **requestTimeout**.
_Avoid_: buffer, offset, a share of the requestTimeout

**Cancelled call**:
A request that ends with no response because a **Client deadline** or **Gateway deadline** passed first.
_Avoid_: timed out, deadline exceeded (only names the gRPC status, not who cancelled)

### Relationships

- An `ActivateJobs` request becomes a **Long poll** only if the first **Job activation sweep** finds no jobs and **requestTimeout** is not negative.
- A **Long poll** runs another **Job activation sweep** each time a broker says jobs of its type are available.
- The **requestTimeout** clock starts after the first **Job activation sweep**. The **Gateway deadline** clock starts when the request arrives. The **Client deadline** clock starts when the client sends it.
- A **Long poll** ends in an **Empty response** only if that response reaches the client before the **Client deadline**; otherwise it is a **Cancelled call**.
- A **Long poll** ends a **Margin** before its **requestTimeout**, over REST and gRPC alike.
- Over gRPC, a **Long poll** also ends before the **Gateway deadline** if that comes first.
- A **Margin** m adds about m / (**requestTimeout** − m) more **Empty responses** for a client that finds no jobs and whose deadline is longer than its **requestTimeout**; clients that hit the bug already poll again after each **Cancelled call**, so they don't poll more.
- A **Cancelled call** shows as 502 (counted by the server-error rate alert) only when the gateway-side time exceeds the **Margin**; the round trip only decides whether the client also sees `DEADLINE_EXCEEDED`.
- A **Cancelled call** shows as nginx 499 when the **Client deadline** cancels it, and as 502 when the **Gateway deadline** cancels it.

### Example dialogue

> **Dev:** "The C# worker sends a 10s `grpc-timeout` and leaves **requestTimeout** at 0. What happens when there are no jobs?"
> **Domain expert:** "The request becomes a **Long poll** with the 10s default **requestTimeout**. That clock starts after the first **Job activation sweep**, so both deadlines pass first. It's a **Cancelled call**, never an **Empty response**."
> **Dev:** "So the gateway should send the **Empty response** just before the **Gateway deadline**?"
> **Domain expert:** "Before the **Client deadline**, which is earlier. The gateway can only read the **Gateway deadline**, so it must leave room for the trip both ways."

### Flagged ambiguities

- "deadline" was used both for a duration and for a point in time, and for both the client's and the gateway's copy. Resolved: a deadline is always a point in time; the duration the client sends is the `grpc-timeout`; the **Client deadline** and **Gateway deadline** are separate terms.
- "long poll" was used both for the request and for its length. Resolved: a **Long poll** is the request; its length is the **requestTimeout**.
- "timed out" was used for both endings. Resolved: **Empty response** vs **Cancelled call**.
