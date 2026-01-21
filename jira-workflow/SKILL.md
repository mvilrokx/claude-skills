---
name: jira-workflow
description: Manage development work using Jira tickets as the single source of truth. Use this skill when users want to (1) list their Jira tickets/work backlog, (2) create new Jira tickets/work items, (3) assign tickets to team members, or (4) "do work" by implementing a Jira ticket—which involves creating a feature branch, implementing the changes, committing with ticket references, and updating the Jira ticket with progress. Triggers on phrases like "list my work", "show my tickets", "create a ticket", "add work", "assign PROJ-123 to", "do work", "work on PROJ-123", or "implement ticket".
---

# Jira Workflow Skill

Manage development workflows using Jira tickets. Supports four core operations: listing work, creating work, assigning work, and doing work.

## Prerequisites

- Access to Jira via MCP Atlassian tools
- Git repository in the current workspace
- Appropriate Jira project permissions

## Quick Reference

| User Intent | Workflow |
|-------------|----------|
| "List my work" / "Show my tickets" | → [List Work](#list-work) |
| "Create a ticket" / "Add work" | → [Create Work](#create-work) |
| "Assign PROJ-123 to John" | → [Assign Work](#assign-work) |
| "Do work" / "Work on PROJ-123" | → [Do Work](#do-work) |

## List Work

Display the user's assigned Jira tickets.

**Steps:**

1. Get the Atlassian Cloud ID using `mcp_atlassian-mcp_getAccessibleAtlassianResources`
2. Get current user info using `mcp_atlassian-mcp_atlassianUserInfo`
3. Search for issues assigned to current user using the search tools (activate with `activate_search_tools_for_jira_and_confluence`)
4. Present tickets in a clear table format

**Output format:**

```
| Key | Summary | Status | Priority |
|-----|---------|--------|----------|
| PROJ-123 | Implement login | In Progress | High |
| PROJ-124 | Fix date bug | To Do | Medium |
```

## Create Work

Create a new Jira ticket.

**Required information** (prompt user if missing):

- Project key (or help user find it via `mcp_atlassian-mcp_getVisibleJiraProjects`)
- Summary (ticket title)
- Issue type (Story, Bug, Task, etc.)

**Optional information:**

- Description
- Priority
- Assignee

**Steps:**

1. Get Cloud ID if not cached
2. Gather required fields from user
3. If issue type unknown, fetch available types via issue metadata tools (activate with `activate_jira_issue_management_tools`)
4. Create issue using `mcp_atlassian-mcp_createJiraIssue`
5. Confirm creation with ticket key and link

## Assign Work

Assign a Jira ticket to a team member.

**Trigger phrases:** "assign PROJ-123 to", "give PROJ-123 to", "assign ticket to"

**Required information:**

- Ticket key (e.g., PROJ-123)
- Assignee (name or email)

**Steps:**

1. Get Cloud ID using `mcp_atlassian-mcp_getAccessibleAtlassianResources`
2. Look up the user's account ID using `mcp_atlassian-mcp_lookupJiraAccountId` with the provided name/email
3. If multiple matches, present options and ask user to clarify
4. Update the issue using `mcp_atlassian-mcp_editJiraIssue` with the assignee field:

   ```json
   {
     "fields": {
       "assignee": { "accountId": "<account-id>" }
     }
   }
   ```

5. Confirm assignment with ticket key and assignee name

**Output format:**

```
✅ PROJ-123 assigned to John Smith
```

## Do Work

Full development workflow: implement a Jira ticket with proper Git workflow and Jira updates.

**Trigger phrases:** "do work", "work on PROJ-123", "implement PROJ-123", "pick up PROJ-123"

**Prerequisites check:**

- Confirm Git repository exists in workspace
- Confirm clean working tree (no uncommitted changes)
- Verify Jira ticket exists and is accessible

### Workflow Steps

```
1. Fetch ticket details
2. Create feature branch
3. Implement the work
4. Commit changes
5. Update Jira ticket
```

See [references/do-work-workflow.md](references/do-work-workflow.md) for detailed implementation steps.

### Branch Naming

Format: `<type>/<ticket-key>-<short-description>`

Examples:

- `feature/PROJ-123-user-authentication`
- `bugfix/PROJ-456-fix-date-format`
- `chore/PROJ-789-update-dependencies`

Derive `<type>` from issue type:

- Story/Feature → `feature/`
- Bug → `bugfix/`
- Task/Chore → `chore/`

### Commit Message Format

```
<type>(<ticket-key>): <summary>

<detailed description>

Refs: <ticket-key>
```

Example:

```
feat(PROJ-123): implement JWT authentication

Add login endpoint with JWT token generation and validation
middleware for protected routes.

Refs: PROJ-123
```

### Jira Update Content

After completing work, update the Jira ticket with:

- Summary of changes made
- Files modified/created
- Any relevant technical notes
- Next steps if work is partial

Use `mcp_atlassian-mcp_addCommentToJiraIssue` for the update.

## Error Handling

| Scenario | Action |
|----------|--------|
| Cannot find Cloud ID | Prompt user to verify Jira connection |
| Ticket not found | Verify ticket key format and project access |
| User not found | Verify name/email spelling, show similar matches |
| Multiple user matches | Present options for user to select |
| Dirty working tree | Prompt user to commit/stash changes first |
| Branch already exists | Offer to checkout existing or create new |
| Create issue fails | Check required fields and permissions |

## Tool Activation Reference

This skill uses these MCP tool groups:

- `mcp_atlassian-mcp_*` - Core Jira operations (always available)
- `activate_jira_issue_management_tools` - Issue creation, editing, transitions
- `activate_search_tools_for_jira_and_confluence` - JQL search capabilities
