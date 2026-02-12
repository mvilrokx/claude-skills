# Agent Configurations

Prompt templates for each review agent. Customize the directory paths per project.

## Core Prompts (All Languages)

### code-reviewer

```
Perform a general code review of the entire codebase at {path}.

Review ALL files including source, config, build files. Focus on:
architecture, API design, error handling consistency, testing strategy,
configuration, documentation, build/CI, middleware, code organization.

For each finding: Priority (P0/P1/P2), file reference, description, recommendation.
```

### database-reviewer

```
Perform a thorough database review of the codebase at {path}.

Review all migration files, query files, store implementations, and config. Focus on:
schema design, query performance, migration safety, SQL injection, connection management,
transaction safety, data integrity, timestamps, pagination efficiency,
database-specific settings (PRAGMAs for SQLite, pooling for Postgres).

For each finding: Severity (CRITICAL/HIGH/MEDIUM/LOW), file and line, issue with impact, fix.
```

### architect

```
Perform an architectural review of the codebase at {path}.

Evaluate: architectural patterns, scalability, extensibility, separation of concerns,
configuration management, observability, resilience, API versioning, middleware architecture,
domain modeling, dependency management, migration paths.

For each finding: Impact (HIGH/MEDIUM/LOW), category, description, concrete steps.
```

## Go-Specific Prompts

### go-reviewer

```
Perform a thorough Go code review of the entire codebase at {path}.

Focus on: idiomatic Go, error handling (%w wrapping, sentinel errors, errors.Is/As),
concurrency (context, goroutine leaks, graceful shutdown), interface design (small, consumer-site),
package organization, code quality, testing, HTTP patterns, database patterns.

For each finding: Severity (CRITICAL/HIGH/MEDIUM/LOW), file and line, what's wrong and WHY, suggested fix.
```

### go-security-reviewer

```
Perform a comprehensive security review of the Go codebase at {path}.

Check: input validation, SQL injection, auth/authz, secrets management, CORS, security headers,
error information disclosure, rate limiting, request size limits, path traversal,
dependency vulnerabilities, SSRF, logging of sensitive data, TLS/HTTPS, database security.

For each finding: Severity, OWASP category, file and line, exploitation scenario, remediation with code.
```

### go-refactor-cleaner

```
Analyze the Go codebase at {path} for dead code, duplication, and refactoring opportunities.

Look for: unused functions/types/variables/imports, duplicate logic, overly complex functions,
unused dependencies, consolidation opportunities, code smells, generated code issues.

Run analysis tools (go vet, staticcheck) if available. Do NOT make changes — analysis only.

For each finding: Category (DEAD_CODE/DUPLICATION/COMPLEXITY/UNUSED_DEP/REFACTOR), file and line, suggested action.
```

## Python-Specific Prompts

### python-reviewer

```
Perform a thorough Python code review of the entire codebase at {path}.

Focus on: PEP 8 compliance, Pythonic idioms, type hints, error handling,
async patterns, class design, module organization, testing, dependency management.

For each finding: Severity (CRITICAL/HIGH/MEDIUM/LOW), file and line, what's wrong and WHY, suggested fix.
```

### python-security-reviewer

```
Perform a comprehensive security review of the Python codebase at {path}.

Check: input validation, SQL injection, auth/authz, secrets management, CORS, security headers,
deserialization, SSRF, command injection, dependency vulnerabilities (pip-audit),
logging of sensitive data, path traversal, eval/exec usage.

For each finding: Severity, OWASP category, file and line, exploitation scenario, remediation with code.
```

### python-refactor-cleaner

```
Analyze the Python codebase at {path} for dead code, duplication, and refactoring opportunities.

Run analysis tools (vulture, pylint, autoflake) if available. Do NOT make changes — analysis only.

For each finding: Category (DEAD_CODE/DUPLICATION/COMPLEXITY/UNUSED_DEP/REFACTOR), file and line, suggested action.
```

## JS/TS-Specific Prompts

### js-security-reviewer

```
Perform a comprehensive security review of the JS/TS codebase at {path}.

Check: XSS, CSRF, input validation, SQL/NoSQL injection, auth/authz, secrets management,
CORS, CSP headers, dependency vulnerabilities (npm audit), prototype pollution,
unsafe eval/innerHTML, SSRF, path traversal.

For each finding: Severity, OWASP category, file and line, exploitation scenario, remediation with code.
```

### js-refactor-cleaner

```
Analyze the JS/TS codebase at {path} for dead code, duplication, and refactoring opportunities.

Run analysis tools (knip, depcheck, ts-prune) if available. Do NOT make changes — analysis only.

For each finding: Category (DEAD_CODE/DUPLICATION/COMPLEXITY/UNUSED_DEP/REFACTOR), file and line, suggested action.
```

## Debate Re-invocation Template

Use this when two agents disagree:

```
You are participating in a multi-agent debate review.

{agent_a_name} found: {agent_a_position_with_reasoning}
{agent_b_name} found: {agent_b_position_with_reasoning}

Review the actual code at {path}. Specifically examine:
- {file_1} — {what to look for}
- {file_2} — {what to look for}

Give your FINAL POSITION in 3-8 sentences. Acknowledge what the other agent got right.
```
