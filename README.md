# Jakarta to javax: Spring 5/6 + Hibernate 5/6 Compatibility Demo

This repository demonstrates a single shared library that works across both generations of Spring and Hibernate:

- `sharedLib` is written using Jakarta APIs (`jakarta.*`).
- `spring6app` consumes the library directly and runs on Spring Boot 3 / Spring 6 / Hibernate 6.
- `spring5app` consumes a transformed classifier artifact (`spring5`) where Jakarta bytecode is rewritten to `javax.*`, running on Spring Boot 2.7 / Spring 5 / Hibernate 5.

## What This Now Demonstrates

In addition to lifecycle annotations, the project now includes a shared JPA entity used in both apps:

- Shared entity: `com.example.shared.entity.SharedNote`
- Source annotations: `jakarta.persistence.*`
- Spring 5 runtime annotation after transformation: `javax.persistence.Entity`
- Spring 6 runtime annotation: `jakarta.persistence.Entity`

## Module Overview

### `sharedLib/`

- `SharedService` with Jakarta lifecycle annotations.
- `SharedNote` entity with Jakarta JPA annotations.
- Eclipse Transformer plugin creates an additional `-spring5` classifier JAR.

### `spring5app/`

- Spring Boot `2.7.18` (Spring 5, Hibernate 5).
- Depends on `com.example:shared-lib:1.0.0-SNAPSHOT:spring5`.
- Includes `spring-boot-starter-data-jpa` and H2.
- Default port: `8085`.

### `spring6app/`

- Spring Boot `3.2.4` (Spring 6, Hibernate 6).
- Depends on `com.example:shared-lib:1.0.0-SNAPSHOT`.
- Includes `spring-boot-starter-data-jpa` and H2.
- Default port: `8086`.

## Endpoints

Both applications expose the same endpoints:

- `GET /api/hello` - shared service/lifecycle demo.
- `GET /api/hibernate?message=...` - persists and reads `SharedNote`, then returns Hibernate + annotation info.

## Build Output from `sharedLib`

- `shared-lib-1.0.0-SNAPSHOT.jar` (Jakarta, Spring 6 compatible)
- `shared-lib-1.0.0-SNAPSHOT-spring5.jar` (transformed javax, Spring 5 compatible)

## Quick Start

### 1) Build shared library

```bash
cd /Users/jwraxall/code/github/spring5libtest/sharedLib
mvn clean install
```

### 2) Build both applications

```bash
cd /Users/jwraxall/code/github/spring5libtest/spring5app
mvn clean package
cd /Users/jwraxall/code/github/spring5libtest/spring6app
mvn clean package
```

### 3) Run both applications

```bash
cd /Users/jwraxall/code/github/spring5libtest/spring5app
java -jar target/spring5-app-1.0.0-SNAPSHOT.jar
```

```bash
cd /Users/jwraxall/code/github/spring5libtest/spring6app
java -jar target/spring6-app-1.0.0-SNAPSHOT.jar
```

### 4) Verify shared entity in both runtimes

```bash
curl -s "http://localhost:8085/api/hibernate?message=shared-entity"
curl -s "http://localhost:8086/api/hibernate?message=shared-entity"
```

## Example Verified Responses

Spring 5 app (Hibernate 5, transformed annotation):

```json
{
  "hibernateVersion": "5.6.15.Final",
  "entityClass": "com.example.shared.entity.SharedNote",
  "entityAnnotation": "javax.persistence.Entity",
  "application": "Spring 5 App",
  "savedMessage": "shared-entity"
}
```

Spring 6 app (Hibernate 6, native annotation):

```json
{
  "hibernateVersion": "6.4.4.Final",
  "entityClass": "com.example.shared.entity.SharedNote",
  "entityAnnotation": "jakarta.persistence.Entity",
  "application": "Spring 6 App",
  "savedMessage": "shared-entity"
}
```

## Expected Output Checklist (30-Second Validation)

After starting both apps and hitting `GET /api/hibernate?message=shared-entity`, you should see:

- [ ] Spring 5 endpoint (`http://localhost:8085/api/hibernate`) returns HTTP 200.
- [ ] Spring 6 endpoint (`http://localhost:8086/api/hibernate`) returns HTTP 200.
- [ ] Both responses include `"entityClass": "com.example.shared.entity.SharedNote"`.
- [ ] Spring 5 response includes `"entityAnnotation": "javax.persistence.Entity"`.
- [ ] Spring 6 response includes `"entityAnnotation": "jakarta.persistence.Entity"`.
- [ ] Spring 5 response reports a Hibernate `5.x` version string.
- [ ] Spring 6 response reports a Hibernate `6.x` version string.

Quick checks:

```bash
curl -s "http://localhost:8085/api/hibernate?message=shared-entity" | jq -r '.hibernateVersion, .entityAnnotation'
curl -s "http://localhost:8086/api/hibernate?message=shared-entity" | jq -r '.hibernateVersion, .entityAnnotation'
```

## Why This Pattern Is Useful

- Keep one modern Jakarta codebase.
- Support legacy Spring/Hibernate stacks via build-time transformation.
- Avoid duplicated source trees for `javax` and `jakarta`.
- Provide a practical migration path from Spring 5/Hibernate 5 to Spring 6/Hibernate 6.
