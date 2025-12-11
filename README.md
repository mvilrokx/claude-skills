# My Claude Skills

A collection of custom Claude skills for use with VS Code's GitHub Copilot and other Claude-compatible tools.

## What are Claude Skills?

[Skills](https://code.claude.com/docs/en/skills) are capabilities that an agent can load on-demand. Each skill comes with a description that advertises the skill to the agent. If useful, the agent decides to read the full skill instructions along with any supporting files like scripts and templates.

VS Code 1.107+ supports reusing Claude skills natively. See the [official announcement](https://code.visualstudio.com/updates/v1_107#_reuse-your-claude-skills-experimental).

## Skills

| Skill | Description |
|-------|-------------|
| [fastapi-code-review](fastapi-code-review/) | Comprehensive code review for FastAPI projects. Analyzes async patterns, project structure, Pydantic usage, dependency injection, database patterns, testing, and performance. Generates prioritized refactor plans. |
| [hpe-copyright](hpe-copyright/) | Check, add, or fix HPE copyright headers in source files. Includes a Python script for batch processing and CI integration. |
| [skill-creator](skill-creator/) | Guide for creating effective Claude skills. Covers skill anatomy, progressive disclosure patterns, and best practices for extending Claude's capabilities. |

## Installation

### Prerequisites

- macOS or Linux with `zsh` and `rsync` installed
- Git
- VS Code 1.107+ with GitHub Copilot

### Quick Install

1. **Clone the repository:**

   ```bash
   git clone https://github.com/mvilrokx/my-claude-skills.git
   cd my-claude-skills
   ```

2. **Run the bootstrap script:**

   ```bash
   ./bootstrap.sh
   ```

   This will sync all skills to `~/.claude/skills/`.

3. **Force install (skip confirmation):**

   ```bash
   ./bootstrap.sh -f
   ```

### Manual Installation

If you prefer to install manually:

```bash
mkdir -p ~/.claude/skills
cp -r fastapi-code-review ~/.claude/skills/
cp -r hpe-copyright ~/.claude/skills/
cp -r skill-creator ~/.claude/skills/
```

### Updating

To pull the latest changes and update your installed skills:

```bash
cd /path/to/my-claude-skills
./bootstrap.sh
```

The script automatically runs `git pull` before syncing.

## Enabling Skills in VS Code

1. Open VS Code Settings
2. Search for `chat.useClaudeSkills`
3. Enable the setting

![Enable Claude Skills](https://code.visualstudio.com/assets/updates/1_107/use-claude-skills.png)

VS Code discovers skills from two locations:

- **Personal skills:** `~/.claude/skills/<skill-name>/SKILL.md`
- **Project skills:** `<workspace>/.claude/skills/<skill-name>/SKILL.md`

## Usage

Once installed and enabled, skills are automatically available in VS Code's agent mode. The agent reads skill descriptions and decides when to use them based on your prompts.

### Verify Skills are Loaded

In agent mode with the `read-file` tool enabled, ask:

> "What skills do you have?"

### Example Prompts

**FastAPI Code Review:**
> "Review this FastAPI project for best practices and generate a refactor plan"

**HPE Copyright:**
> "Check all Python files for missing copyright headers"

**Skill Creator:**
> "Help me create a new skill for database migration workflows"

> **Tip:** If the agent doesn't use a skill when expected, try nudging it: "Use your skills to help with this task."

## Directory Structure

After installation:

```
~/.claude/skills/
├── fastapi-code-review/
│   ├── SKILL.md
│   └── references/
│       └── best-practices.md
├── hpe-copyright/
│   ├── SKILL.md
│   └── scripts/
│       └── copyright_check.py
└── skill-creator/
    ├── SKILL.md
    ├── references/
    │   ├── output-patterns.md
    │   └── workflows.md
    └── scripts/
        ├── init_skill.py
        ├── package_skill.py
        └── quick_validate.py
```

## Contributing

1. Fork this repository
2. Create a new skill directory following the [skill-creator](skill-creator/) guidelines
3. Add your `SKILL.md` with proper frontmatter (`name` and `description`)
4. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
