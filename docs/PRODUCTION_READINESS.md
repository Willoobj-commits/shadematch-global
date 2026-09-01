# Production Readiness Gates

These gates are mandatory before store release or live backend activation.

## Database migration safety

- Use expand-and-contract changes; add before removing.
- Preserve compatibility across the currently released and immediately previous mobile client.
- Write rollback and data-recovery steps before migration code.
- Test migration and rollback/forward repair in staging with production-scale data.
- Verify integrity, locks, query plans, sync compatibility, and backup restoration.
- Remove old columns or tables only after telemetry confirms no active client depends on them.
- The included destructive down migration is limited to empty staging/local databases.

## API usage and cost protection

- Per-user, device, IP, endpoint, and admin-ingestion limits.
- Pagination and maximum result/image sizes.
- Concurrency caps for image processing, measurement imports, and match recomputation.
- Bounded retries with exponential backoff and jitter.
- Timeouts, idempotency keys, deduplication hashes, caching, circuit breakers, and dead-letter handling.
- Provider spending caps, internal budgets, cost-velocity alarms, dashboards, audit logs, key rotation, and automatic pause controls.
- Burst and failure-mode tests in staging.

## SOC 2 readiness

- Governance, risk register, access reviews, least privilege, MFA, and joiner/mover/leaver controls.
- Secure SDLC, peer review, protected branches, dependency scanning, vulnerability/patch SLAs, and change evidence.
- Centralized logs, alerts, incident response, backups, restore tests, disaster recovery, and business continuity.
- Vendor and subprocessor register, data classification, retention/deletion, privacy/confidentiality, and staff security training.
- Customer-facing security overview, incident contacts, availability commitments, and evidence inventory.

## Global regulatory and EU readiness

- Assess territorial scope based on actual offering, monitoring, and establishments; do not assume geography from company location.
- Document lawful basis, notices, consent, data-subject rights, processor contracts, subprocessors, transfers, retention, deletion, and records of processing.
- Complete DPIAs for camera-assisted shade analysis or other higher-risk processing.
- Obtain valid consent for optional user captures; make withdrawal and deletion practical.
- Apply appropriate children’s-data controls if the product is offered to minors.
- Maintain cookie/tracking consent for any companion website.
- Prepare breach assessment and jurisdiction-specific notification procedures.

## Image rights and privacy

- Do not redistribute manufacturer images without a recorded right or licence.
- Keep source, attribution, licence reference, expiry, hash, and withdrawal state.
- Remove EXIF and unrelated metadata from uploaded user images.
- Use private storage, short-lived signed URLs, encryption, and strict ownership policies.
- Process on-device where possible; do not use captures for model training by default.

## Mobile release gate

- Flutter analysis and all unit/widget/integration tests pass.
- VoiceOver and TalkBack announce shade name, depth, undertone, and evidence type.
- Text remains readable at large accessibility sizes; colour is never the only signal.
- Offline startup, corrupt-cache recovery, slow network, image failure, and empty-result states pass.
- iOS and Android permissions, privacy manifests, data-safety forms, screenshots, and store disclosures match actual behavior.
- Crash reporting, performance monitoring, versioned configuration, staged rollout, and rollback are active.
