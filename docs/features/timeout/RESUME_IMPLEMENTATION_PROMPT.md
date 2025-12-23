# Resume Implementation Prompt Template

Use this prompt template to resume the timeout implementation from any point in the task list.

---

## Basic Resume Prompt

```
I'm implementing timeout support for ShellSpec following the tasks in TIMEOUT_IMPLEMENTATION_TASKS.md.

Current status:
- Phase 1: [COMPLETE/IN_PROGRESS/NOT_STARTED]
- Phase 2: [COMPLETE/IN_PROGRESS/NOT_STARTED]
- Phase 3: [COMPLETE/IN_PROGRESS/NOT_STARTED]
- Phase 4: [COMPLETE/IN_PROGRESS/NOT_STARTED]
- Phase 5: [COMPLETE/IN_PROGRESS/NOT_STARTED]

Last completed task: [Task X.Y: Task Name]

Please continue from the next task: [Task X.Y+1: Next Task Name]

Refer to TIMEOUT_IMPLEMENTATION_TASKS.md and TIMEOUT_SUPPORT_PLAN.md for implementation details.
```

---

## Detailed Resume Prompt (Recommended)

```
I'm implementing per-test timeout support for ShellSpec. I need to resume implementation from where I left off.

## Context
- Implementation plan: See TIMEOUT_SUPPORT_PLAN.md
- Task list: See TIMEOUT_IMPLEMENTATION_TASKS.md
- Architecture: Background watchdog process pattern (similar to profiler)

## Current Progress

### Completed Tasks:
✅ Task 1.1: Create timeout parser utility (lib/libexec/timeout-parser.sh)
✅ Task 1.2: Create watchdog script (libexec/shellspec-timeout-watchdog.sh)
✅ Task 1.3: Add command-line options
   - Modified lib/libexec/optparser/parser_definition.sh
   - Modified lib/libexec/optparser/optparser.sh
   - Modified lib/libexec/optparser/parser_definition_generated.sh

### Last Completed Task:
Task 1.3: Add command-line options

### Current State:
- Files created: 2 (timeout-parser.sh, shellspec-timeout-watchdog.sh)
- Files modified: 3 (parser files)
- Implementation phase: Phase 1 complete, starting Phase 2

## Next Steps
Please continue with:
1. Task 2.1: Add grammar directive (lib/libexec/grammar/directives)
2. Task 2.2: Update translator to extract timeout metadata
3. Task 2.3: Update translation output

## Requirements
- Follow the exact implementation details in TIMEOUT_IMPLEMENTATION_TASKS.md
- Maintain POSIX shell compatibility
- Use existing ShellSpec patterns and conventions
- Test each task before moving to the next

Please proceed with Task 2.1.
```

---

## Example Resume Prompts by Phase

### Resume from Phase 2

```
Resume timeout implementation from Phase 2 (DSL/Grammar Integration).

Completed: Phase 1 (all tasks)
- ✅ Timeout parser created
- ✅ Watchdog script created
- ✅ Command-line options added
- ✅ Options tested and working

Next: Phase 2 - DSL/Grammar Integration
Start with Task 2.1: Add %timeout directive to lib/libexec/grammar/directives

Reference: TIMEOUT_IMPLEMENTATION_TASKS.md (Phase 2 section)
```

### Resume from Phase 3

```
Resume timeout implementation from Phase 3 (Runtime Integration).

Completed:
- ✅ Phase 1: Foundation (parser, watchdog, CLI options)
- ✅ Phase 2: DSL/Grammar (directive added, translator updated, translation output modified)

Next: Phase 3 - Runtime Integration
Start with Task 3.1: Integrate watchdog into lib/core/dsl.sh shellspec_example() function

This is the most complex task. Key points:
- Modify shellspec_example() at lines 168-216
- Add timeout setup after dryrun check
- Replace subshell execution with background + watchdog
- Handle timeout results

Reference: TIMEOUT_IMPLEMENTATION_TASKS.md (Task 3.1 detailed steps)
```

### Resume from Specific Task

```
Resume timeout implementation from Task 3.1 (Integrate watchdog into test execution).

Status:
- ✅ Phase 1: Complete
- ✅ Phase 2: Complete
- ⏸️ Phase 3: In progress
  - ⏸️ Task 3.1: Partially complete
    - ✅ Added timeout setup code
    - ❌ Need to replace subshell execution with watchdog version
  - ⏳ Task 3.2: Not started
  - ⏳ Task 3.3: Not started

Current issue: Need to modify lib/core/dsl.sh lines 200-207 to:
1. Background the test subshell
2. Start watchdog
3. Wait for completion
4. Check for timeout

Please complete Task 3.1 following the detailed steps in TIMEOUT_IMPLEMENTATION_TASKS.md, then proceed to Task 3.2.
```

### Resume After Testing Failure

```
Resume timeout implementation - tests are failing.

Completed: All implementation tasks (Phases 1-3)
Current: Phase 4 - Testing & Validation

Issue: Tests show [describe the specific issue]

Last working state:
- Basic functionality works: ✅
- Per-test override: ❌ (failing)
- Parallel execution: ⏳ (not tested yet)

Debug needed:
1. Check translation output with --translate flag
2. Verify SHELLSPEC_EXAMPLE_TIMEOUT is set correctly
3. Check if timeout metadata is being extracted

Please help debug and fix the issue, then continue with remaining tests.

Reference: TIMEOUT_IMPLEMENTATION_TASKS.md (Task 4.2 - Manual Testing)
```

---

## Mid-Task Resume Prompt

For resuming in the middle of a complex task:

```
Resume timeout implementation - currently working on Task 3.1 (Integrate watchdog).

Progress on Task 3.1:
- ✅ Added timeout setup code (lines 193-202)
- ✅ Added timeout signal/result files
- ❌ Still need to: Modify subshell execution (lines 200-207)
- ❌ Still need to: Add timeout check after file descriptors close
- ❌ Still need to: Test the integration

Current file state:
- lib/core/dsl.sh has timeout setup but not execution changes

Next steps (from Task 3.1 checklist):
1. Replace lines 200-207 with timeout-aware execution
2. Add timeout check after line 208
3. Verify variable scoping

Please continue with the remaining sub-tasks of Task 3.1.

Reference: TIMEOUT_IMPLEMENTATION_TASKS.md (Task 3.1 - detailed checklist)
```

---

## Resume with Git Status

```
Resume timeout implementation based on current git status.

Git status shows:
Modified:
  - lib/bootstrap.sh
  - lib/core/dsl.sh
  - lib/core/outputs.sh
  - lib/libexec/grammar/directives
  - lib/libexec/optparser/optparser.sh
  - lib/libexec/optparser/parser_definition.sh
  - lib/libexec/optparser/parser_definition_generated.sh
  - lib/libexec/translator.sh
  - libexec/shellspec-translate.sh

Untracked:
  - lib/libexec/timeout-parser.sh
  - libexec/shellspec-timeout-watchdog.sh

Based on these changes, it appears:
✅ Phase 1: Complete (parser, watchdog, options)
✅ Phase 2: Complete (grammar, translator, translation)
✅ Phase 3: Complete (runtime, output, bootstrap)
⏳ Phase 4: Testing - Not started

Please verify the implementation is complete by:
1. Checking each modified file against the task list
2. Running basic tests (Task 4.2)
3. If tests pass, proceed with Phase 4 (Testing & Validation)

Reference: Use git diff to compare with TIMEOUT_IMPLEMENTATION_TASKS.md
```

---

## Template Variables

When using these prompts, replace:
- `[Task X.Y]` → Actual task number (e.g., Task 2.1)
- `[Task Name]` → Actual task name
- `[COMPLETE/IN_PROGRESS/NOT_STARTED]` → Current status
- `[describe the specific issue]` → Actual error or issue
- File paths → Actual file paths from your implementation
- Line numbers → Actual line numbers

---

## Best Practices

1. **Be Specific**: Include the exact task number and name
2. **Provide Context**: List what's completed and what's next
3. **Reference Documents**: Always mention TIMEOUT_IMPLEMENTATION_TASKS.md
4. **Include State**: Show git status or file changes
5. **Mention Issues**: If debugging, describe the exact problem
6. **Set Expectations**: Clearly state what you want to accomplish

---

## Quick Resume Commands

```bash
# Check current progress
git status
git diff --name-only

# Identify last completed task
grep -n "✅\|❌\|⏸️" TIMEOUT_IMPLEMENTATION_TASKS.md

# Review implementation plan
cat TIMEOUT_SUPPORT_PLAN.md | less

# Check what's working
./shellspec --help | grep timeout
./shellspec --timeout 5 --version
```

---

## Example: Full Context Resume

```
I'm resuming implementation of ShellSpec timeout support. Let me provide full context:

## Repository State
Branch: master
Last commit: [commit hash]
Working directory: /mnt/wsl/workspace/shellspec

## Implementation Status

### Phase 1: Foundation ✅ COMPLETE
- ✅ Task 1.1: timeout-parser.sh created and tested
- ✅ Task 1.2: shellspec-timeout-watchdog.sh created and tested
- ✅ Task 1.3: CLI options added, parser regenerated

### Phase 2: DSL/Grammar ✅ COMPLETE
- ✅ Task 2.1: %timeout directive added to grammar
- ✅ Task 2.2: Translator extracts timeout metadata
- ✅ Task 2.3: Translation output includes SHELLSPEC_EXAMPLE_TIMEOUT

### Phase 3: Runtime 🔄 IN PROGRESS
- ✅ Task 3.1: Watchdog integrated into shellspec_example()
- ❌ Task 3.2: TIMEOUT output handler - NOT STARTED
- ❌ Task 3.3: Bootstrap loader - NOT STARTED

### Phases 4-5: NOT STARTED

## Files Modified So Far
1. lib/libexec/timeout-parser.sh (new)
2. libexec/shellspec-timeout-watchdog.sh (new)
3. lib/libexec/optparser/*.sh (3 files)
4. lib/libexec/grammar/directives
5. lib/libexec/translator.sh
6. libexec/shellspec-translate.sh
7. lib/core/dsl.sh

## Current Task
Task 3.2: Add TIMEOUT output handler to lib/core/outputs.sh

This task requires:
1. Adding shellspec_output_TIMEOUT() function
2. Following the pattern of existing output handlers (e.g., ABORTED)
3. Including proper tagging and failure messages

## Request
Please implement Task 3.2 following the details in TIMEOUT_IMPLEMENTATION_TASKS.md.
After completion, I'll test it before moving to Task 3.3.

Reference files:
- Implementation details: TIMEOUT_IMPLEMENTATION_TASKS.md (Task 3.2)
- Architecture: TIMEOUT_SUPPORT_PLAN.md (Section 7: Output Handler)
- Example pattern: lib/core/outputs.sh (shellspec_output_ABORTED function)
```

---

Save this file and use the appropriate prompt template when resuming work!
