# AI Markdown Folder Workflow Rule

You are an AI coding agent supporting software development tasks and tickets.

Your responsibility is not only to modify code, but also to organize Markdown documentation using a standard workflow so that humans or future AI agents can read, understand, maintain, and continue the task later.

---

## 1. Purpose

For every coding task or ticket, create a dedicated folder that stores all related Markdown documents.

The purpose of this workflow is to:

* Preserve the original requirement.
* Preserve the Vietnamese translation or summary if needed.
* Record technical context.
* Record analysis before coding.
* Record implementation details.
* Record problems and debugging history.
* Record build/test/verification results.
* Record completion summary.
* Record final handover for future maintainers or AI agents.

---

## 2. Standard Folder Structure

Each ticket must be stored under:

```txt
docs/<ticket-id>/
```

Example:

```txt
docs/123/
```

Standard structure:

```txt
docs/<ticket-id>/
├── README.md
├── 00_original/
│   ├── index.md
│   └── index_vi.md
├── 01_context/
│   └── context.md
├── 02_analysis/
│   └── plan-and-analysis_YYYYMMDD_00.md
├── 03_implementation/
│   └── implementation_YYYYMMDD_00.md
├── 04_problem/
│   └── problem_YYYYMMDD_00.md
├── 05_test/
│   └── test-result_YYYYMMDD_00.md
├── 06_resolved/
│   └── resolved_YYYYMMDD_00.md
└── 99_handover/
    └── handover.md
```

---

## 3. Folder Meaning

| Folder              | Purpose                                                         |
| ------------------- | --------------------------------------------------------------- |
| `00_original`       | Original ticket content and Vietnamese translation              |
| `01_context`        | System, branch, module, API, database, and related file context |
| `02_analysis`       | Requirement analysis and implementation plan before coding      |
| `03_implementation` | Implementation log, changed files, and reasons for changes      |
| `04_problem`        | Errors, problems, blockers, logs, root causes, and solutions    |
| `05_test`           | Build, test, and verification results                           |
| `06_resolved`       | Final completion summary                                        |
| `99_handover`       | Final handover for future developers or AI agents               |

---

## 4. File Naming Rules

Stable files:

```txt
README.md
00_original/index.md
00_original/index_vi.md
01_context/context.md
99_handover/handover.md
```

Versioned files:

```txt
02_analysis/plan-and-analysis_YYYYMMDD_COUNTER.md
03_implementation/implementation_YYYYMMDD_COUNTER.md
04_problem/problem_YYYYMMDD_COUNTER.md
05_test/test-result_YYYYMMDD_COUNTER.md
06_resolved/resolved_YYYYMMDD_COUNTER.md
```

Counter starts from:

```txt
00, 01, 02, 03...
```

Examples:

```txt
plan-and-analysis_20260529_00.md
plan-and-analysis_20260529_01.md
problem_20260529_00.md
problem_20260529_01.md
test-result_20260529_00.md
```

Important rules:

* Do not overwrite previous versioned files.
* If the same document type is created multiple times on the same day, increment the counter.
* Do not use vague file names such as `final.md`, `new.md`, `note.md`, `latest.md`, or `fix.md`.

---

## 5. Mandatory Lifecycle

The AI agent must process each task in the following order:

```txt
1. Create the ticket folder
2. Save the original requirement into 00_original/index.md
3. Create Vietnamese translation or summary in 00_original/index_vi.md if needed
4. Create technical context in 01_context/context.md
5. Create analysis and plan in 02_analysis/
6. Implement the code
7. Record implementation details in 03_implementation/
8. If any problem occurs, record it in 04_problem/
9. Record build/test results in 05_test/
10. Record completion summary in 06_resolved/
11. Update 99_handover/handover.md
12. Update README.md
```

---

## 6. Mandatory Rule Before Coding

Before modifying any code, the following files must exist:

```txt
00_original/index.md
01_context/context.md
02_analysis/plan-and-analysis_YYYYMMDD_00.md
```

Do not start coding without analysis.

The `plan-and-analysis` file must clearly describe:

* What the requirement is.
* What the current behavior is.
* What the expected behavior is.
* The impact scope.
* Related files, modules, APIs, and database tables.
* Proposed solution.
* Implementation steps.
* Test plan.
* Risks.
* Open questions or confirmation points if any.

---

## 7. Rule During Coding

During implementation, record details in `03_implementation/`.

The implementation log must include:

* Changed files.
* What was changed.
* Why it was changed.
* Main logic changes.
* API/database/UI/config impact if any.
* Important technical notes.

If any error, blocker, build issue, test failure, runtime issue, dependency issue, or unexpected behavior occurs, create a file under `04_problem/`.

Each problem file must include:

* When the problem happened.
* Full error log.
* Root cause if found.
* Investigation steps.
* Solution or workaround.
* Current status.

---

## 8. Rule After Coding

After coding, create or update:

```txt
05_test/test-result_YYYYMMDD_COUNTER.md
06_resolved/resolved_YYYYMMDD_COUNTER.md
99_handover/handover.md
README.md
```

The `test-result` file must include:

* Test environment.
* Build/test commands executed.
* Test cases.
* Expected result.
* Actual result.
* Status.
* Evidence if available.

The `resolved` file must include:

* What has been completed.
* Which files were changed.
* Final behavior after the change.
* Test results.
* Remaining issues if any.
* Follow-up tasks if any.

The `handover` file must contain enough information for another developer or AI agent to continue the task without asking from the beginning.

---

## 9. README.md Rule

Each ticket folder must contain `README.md`.

`README.md` acts as the navigation map for the ticket.

Required content:

```md
# Ticket <ticket-id>

## Status

In Progress / Done / Blocked / Waiting Confirmation

## Summary

Short task summary.

## Reading Order

1. `00_original/index.md`
2. `00_original/index_vi.md`
3. `01_context/context.md`
4. `02_analysis/plan-and-analysis_YYYYMMDD_00.md`
5. `03_implementation/implementation_YYYYMMDD_00.md`
6. `04_problem/problem_YYYYMMDD_00.md`
7. `05_test/test-result_YYYYMMDD_00.md`
8. `06_resolved/resolved_YYYYMMDD_00.md`
9. `99_handover/handover.md`

## Latest Important Files

| Type | File |
|---|---|
| Latest analysis | `02_analysis/...` |
| Latest implementation | `03_implementation/...` |
| Latest problem | `04_problem/...` |
| Latest test result | `05_test/...` |
| Latest resolved | `06_resolved/...` |
| Final handover | `99_handover/handover.md` |

## Current Status

Write current status here.

## Next Action

Write next action here.
```

---

## 10. Final Mandatory Principles

The AI agent must follow these principles:

* Do not only code.
* Analyze before coding.
* Document while coding.
* Record problems when they happen.
* Record test results after testing.
* Summarize after completion.
* Create handover before finishing.
* Do not overwrite old versioned Markdown files.
* Keep all documents specific to the ticket.
* If information is missing, write it into `Open Questions` or `Confirmation Needed`.
* The final folder must be understandable by both humans and future AI agents.
