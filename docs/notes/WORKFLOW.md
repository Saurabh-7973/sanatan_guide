# Cursor + Claude Workflow Guide
> How to use both tools together without getting tangled.

## The Mental Model

Think of it as a senior/junior pair:
- **Claude** = senior architect. Designs systems, catches subtle bugs, handles
  complex logic, reviews architecture, answers "why" questions.
- **Cursor** = fast junior. Implements patterns it's been shown, generates
  boilerplate, fills in repetitive code, refactors on command.

If you let Cursor lead on architecture decisions, you'll get inconsistent,
untestable code that looks fine until you try to scale it.

---

## Session Types

### Type 1: Architecture Session (use Claude)
When: Starting a new feature, designing a new data flow, debugging a
      hard crash, deciding between approaches.

How:
1. Paste the relevant context (entity, interface, current notifier)
2. Describe the problem or decision
3. Get the design decision + sample code
4. Copy the sample into Cursor as the reference
5. Tell Cursor: "Implement the [X] feature following this pattern exactly"

### Type 2: Implementation Session (use Cursor)
When: Writing boilerplate, creating new files following an established
      pattern, generating test scaffolds, refactoring.

How:
1. Reference ARCHITECTURE.md in your Cursor chat (or @-mention the file)
2. Project rules live in `.cursor/rules/cursorrules.mdc` — Cursor loads them as project rules when enabled; @-mention if you need them explicit in a thread
3. Give precise instructions: "Create a GetFestivalsUseCase following the
   same pattern as GetVerseUseCase"
4. Review every generated file before committing — especially imports

### Type 3: Review Session (use Claude)
When: Before committing a feature, when tests are failing, when
      something smells wrong.

How:
1. Paste the complete feature code
2. Ask: "Review this for architecture violations, missing error handling,
   and testability issues"
3. Fix issues Cursor flags as trivial, bring hard ones back to Claude

---

## The TDD Loop (for every feature)

```
Claude: Design entity + interface contract
    ↓
Cursor: Generate entity.dart + i_repository.dart (from templates)
    ↓
Claude: Write use case test (the real logic test)
    ↓
Cursor: Implement use case to make test pass
    ↓
Cursor: Generate repository + DAO boilerplate
    ↓
Claude: Review repository logic for correctness
    ↓
Cursor: Wire Riverpod providers
    ↓
Claude: Review provider wiring for circular deps / leaks
    ↓
Cursor: Build UI widgets
    ↓
Claude: Final review pass
```

---

## What to paste into Claude (context)

Always include:
- The relevant domain entity
- The repository interface
- The notifier/provider being discussed
- The specific test that's failing (if debugging)
- The error message (full stack trace, not just the last line)

Don't paste:
- Generated .g.dart files
- The entire codebase
- UI widgets (unless the bug is in the UI)

---

## Red Flags to Watch For

If Cursor generates any of these, reject and redo with more specific prompt:

❌ Business logic inside a Widget or Page class
❌ Direct Drift DAO calls in a provider or widget
❌ BuildContext used after an await without mounted check
❌ A class that has 5+ public methods (probably a God object)
❌ Repository method that throws instead of returning Either<Failure, T>
❌ Hardcoded color values (Color(0xFF...) in a widget
❌ print() statement anywhere
❌ Missing error state in a .when() call
❌ Use case that directly accesses SharedPreferences or Dio

---

## Prompt Templates for Cursor

Copy-paste these into Cursor chat for consistency:

**New entity:**
"Create a [Name] entity in lib/domain/entities/[name].dart following the
pattern in verse.dart. It should be immutable using freezed with fields:
[field list]. Include equality, copyWith, and toJson/fromJson."

**New use case:**
"Create a [Name]UseCase in lib/domain/usecases/[name]_usecase.dart.
It takes [RepositoryInterface] via constructor injection, has a single
execute([ParamsClass]) method returning Future<Either<Failure, T>>.
Write the test first in test/domain/usecases/[name]_usecase_test.dart
using mocktail."

**New repository:**
"Create the interface I[Name]Repository in lib/domain/repositories/ and
its implementation [Name]Repository in lib/data/repositories/.
The implementation takes [DaoClass] via constructor and maps DTOs to
domain entities. Return Either<Failure, T> — never throw."

**New notifier:**
"Create a [Name]Notifier extending AutoDisposeAsyncNotifier<[State]> in
lib/presentation/features/[feature]/providers/[name]_provider.dart.
It should use [UseCaseClass] injected via ref.watch. Handle all three
states in build(). Add @riverpod annotation for code gen."
