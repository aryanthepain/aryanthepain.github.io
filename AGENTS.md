# AGENTS.md — Repository Operating Context & Commands

> [!NOTE]
> Global behavioral invariants (Single-task delivery contract, Ponytail anti-bloat ladder, Karpathy surgical execution, Fleet loop verification) are inherited globally from `~/.gemini/config/rules/global_rules.md`.

## 1. Project Commands & Deterministic Gates
- **Build**: `[e.g. npm run build / cargo build / poetry build]`
- **Test**: `[e.g. pytest / npm test / cargo test]`
- **Typecheck**: `[e.g. mypy . / npx tsc --noEmit]`
- **Lint & Format**: `[e.g. ruff check . / prettier --check .]`
- **Universal Verification**: `./scripts/verify.ps1 -Quick`
- **Audio & Spoken Completion Alert**: `pwsh -File ./scripts/agent-alarm.ps1 -Type Success -Message "Task complete."`


## 2. Repository Architecture & Layout
- `src/`: Core application logic.
- `tests/`: Deterministic test suites.
- `scripts/`: Local utility scripts and verification gates.

## 3. Project-Specific Invariants & Conventions
- **Language / Runtime**: [Specify version, e.g. Python 3.12+, Node 22+]
- **Package Manager**: [Specify, e.g. uv, pnpm, cargo]
- **State Management / Database**: [Specify architecture]
- **Skills & Rules**: Rely on global skills and rules (`~/.gemini/config/`) by default; project-scoped overrides in `.agents/` are used only when strictly necessary.

## 4. Ephemeral Memory (`WORKING.md`)
- Maintain active sprint objectives, test failure traces, hypotheses, and blockers in `WORKING.md`.
