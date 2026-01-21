# Do Work - Detailed Workflow

Complete implementation guide for the "do work" operation.

## Table of Contents

1. [Pre-flight Checks](#pre-flight-checks)
2. [Fetch Ticket Details](#fetch-ticket-details)
3. [Create Feature Branch](#create-feature-branch)
4. [Implement the Work](#implement-the-work)
5. [Commit Changes](#commit-changes)
6. [Update Jira Ticket](#update-jira-ticket)
7. [Optional: Transition Ticket](#optional-transition-ticket)

---

## Pre-flight Checks

Before starting work, verify:

```bash
# Verify git repository
git rev-parse --is-inside-work-tree

# Check for clean working tree
git status --porcelain
```

**If working tree is dirty:**

```
⚠️ You have uncommitted changes. Please commit or stash them before starting new work:
- `git stash` to temporarily save changes
- `git commit` to commit current work
```

**If not a git repo:**

```
⚠️ Current directory is not a Git repository. Navigate to a repository or initialize one.
```

## Fetch Ticket Details

1. Get Cloud ID:

   ```
   mcp_atlassian-mcp_getAccessibleAtlassianResources
   ```

2. Activate issue management tools:

   ```
   activate_jira_issue_management_tools
   ```

3. Fetch issue details using the issue key (e.g., PROJ-123)

4. Extract and display:
   - Summary (title)
   - Description
   - Issue type
   - Priority
   - Acceptance criteria (if present)
   - Linked issues/dependencies

**Present to user:**

```
📋 PROJ-123: Implement user authentication

Type: Story | Priority: High | Status: To Do

Description:
As a user, I want to log in with my credentials so that I can access
my personalized dashboard.

Acceptance Criteria:
- [ ] Login form with email/password
- [ ] JWT token generation
- [ ] Protected route middleware
- [ ] Error handling for invalid credentials

Ready to proceed? (Y/n)
```

## Create Feature Branch

1. Determine branch type from issue type:
   - Story/Feature/Epic → `feature/`
   - Bug/Defect → `bugfix/`
   - Task/Sub-task/Chore → `chore/`
   - Improvement → `improvement/`

2. Generate branch name:

   ```
   <type>/<ticket-key>-<slugified-summary>
   ```

   Slugify rules:
   - Lowercase
   - Replace spaces with hyphens
   - Remove special characters
   - Truncate to ~50 chars

3. Create and checkout branch:

   ```bash
   git checkout -b feature/PROJ-123-user-authentication
   ```

4. Confirm to user:

   ```
   ✅ Created branch: feature/PROJ-123-user-authentication
   ```

## Implement the Work

This is the core development phase. Apply standard development practices:

1. **Analyze requirements** from ticket description and acceptance criteria

2. **Plan implementation** - identify files to create/modify

3. **Implement changes** following project conventions:
   - Code style consistency
   - Error handling
   - Documentation/comments where needed
   - Tests if applicable

4. **Verify implementation** - run relevant tests/linters:

   ```bash
   # Language-specific verification
   npm test        # Node.js
   pytest          # Python
   go test ./...   # Go
   ```

5. **Track changes** for the Jira update:
   - Files created
   - Files modified
   - Key decisions made
   - Any deviations from original requirements

## Commit Changes

1. Stage changes:

   ```bash
   git add -A
   ```

2. Create commit with proper format:

   ```bash
   git commit -m "<type>(<ticket-key>): <summary>

   <body>

   Refs: <ticket-key>
   Co-authored-by: GitHub Copilot <noreply@github.com>"
   ```

   **Type mapping:**
   - Story/Feature → `feat`
   - Bug → `fix`
   - Task/Chore → `chore`
   - Documentation → `docs`
   - Refactor → `refactor`
   - Test → `test`

   **Co-authored-by:** Always include this trailer. GitHub recognizes it and displays Copilot as a contributor in the commit history.

3. Example commit:

   ```bash
   git commit -m "feat(PROJ-123): implement JWT authentication

   - Add login endpoint at POST /api/auth/login
   - Create JWT token generation utility
   - Add authentication middleware for protected routes
   - Handle invalid credentials with proper error responses

   Refs: PROJ-123
   Co-authored-by: GitHub Copilot <noreply@github.com>"
   ```

4. Confirm to user:

   ```
   ✅ Committed: feat(PROJ-123): implement JWT authentication
   ```

## Update Jira Ticket

Add a comment summarizing the work done:

```
mcp_atlassian-mcp_addCommentToJiraIssue
```

**Comment template:**

```markdown
## Implementation Complete

### Changes Made
- Added login endpoint (`POST /api/auth/login`)
- Created JWT token utility (`src/utils/jwt.ts`)
- Implemented auth middleware (`src/middleware/auth.ts`)

### Files Modified
- `src/routes/auth.ts` (new)
- `src/utils/jwt.ts` (new)
- `src/middleware/auth.ts` (new)
- `src/routes/index.ts` (updated to include auth routes)

### Technical Notes
- Using HS256 algorithm for JWT signing
- Token expiry set to 24 hours
- Refresh token support planned for future iteration

### Branch
`feature/PROJ-123-user-authentication`

### Next Steps
- Push branch and create PR
- Await code review
```

## Optional: Transition Ticket

If user wants to update ticket status:

1. Get available transitions:

   ```
   mcp_atlassian-mcp_getTransitionsForJiraIssue
   ```

2. Show options to user:

   ```
   Available transitions for PROJ-123:
   1. In Progress
   2. In Review
   3. Done

   Move ticket? (Enter number or skip)
   ```

3. Execute transition if requested:

   ```
   mcp_atlassian-mcp_transitionJiraIssue
   ```

---

## Complete Workflow Summary

```
┌─────────────────────────────────────────────────────────┐
│                    DO WORK WORKFLOW                      │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  1. PRE-FLIGHT                                          │
│     ├── Verify git repo                                 │
│     └── Check clean working tree                        │
│                                                          │
│  2. FETCH TICKET                                        │
│     ├── Get Cloud ID                                    │
│     ├── Fetch issue details                             │
│     └── Display & confirm with user                     │
│                                                          │
│  3. CREATE BRANCH                                       │
│     ├── Determine type from issue                       │
│     ├── Generate branch name                            │
│     └── git checkout -b <branch>                        │
│                                                          │
│  4. IMPLEMENT                                           │
│     ├── Analyze requirements                            │
│     ├── Code changes                                    │
│     ├── Verify (tests/lint)                            │
│     └── Track changes for update                        │
│                                                          │
│  5. COMMIT                                              │
│     ├── Stage all changes                               │
│     └── Commit with ticket reference                    │
│                                                          │
│  6. UPDATE JIRA                                         │
│     ├── Add implementation comment                      │
│     └── (Optional) Transition status                    │
│                                                          │
└─────────────────────────────────────────────────────────┘
```
