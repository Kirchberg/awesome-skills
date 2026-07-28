# Design principles

Use these principles to decide what to build and what to remove. Treat them as
competing lenses, not as a visual recipe.

## Frame the decision

Before proposing a screen or component, write:

- the person and context the design serves;
- the outcome they need, in their language;
- the information and actions required to reach that outcome;
- the risk, constraint, or failure that matters most;
- the observable evidence that would show the design works.

If the purpose is unclear, investigate it before styling the interface. Do not
use polish to conceal an unresolved product decision.

## Apply the principle lenses

- **Purpose:** Prioritize the product's core value and remove features that do
  not strengthen it.
- **Agency:** Keep people informed, preserve meaningful choice, provide exits,
  and make consequential actions reversible when possible.
- **Responsibility:** Minimize data and attention demands, explain consequences,
  protect safety and privacy, and keep a useful path when consent is declined.
- **Familiarity:** Reuse platform concepts, language, components, and behavior
  unless a different model produces demonstrably better understanding.
- **Flexibility:** Support relevant devices, windows, appearances, input modes,
  languages, abilities, and content variation without losing context.
- **Simplicity:** Keep necessary capability while removing competing choices,
  redundant decoration, and implementation detail from the primary path.
- **Craft:** Make state, wording, alignment, feedback, transitions, and edge
  cases feel like one intentional system.
- **Delight:** Add character that reinforces the product's purpose; never delay,
  obscure, or compete with the task for effect alone.

## Resolve tradeoffs

1. Protect people from harm, deception, lost work, and avoidable privacy risk.
2. Preserve the core outcome and the person's control over it.
3. Prefer the familiar, recoverable option when alternatives perform equally.
4. Adapt the solution to each supported platform instead of forcing identical
   layouts or interactions everywhere.
5. Add expressive detail only after structure and comprehension hold.

Record the principle gained and the principle weakened by a meaningful
compromise. Do not claim that every principle improved.

## Guardrails

- Keep content primary and let controls support it.
- Express brand through content, writing, imagery, typography, color, sound,
  and interaction character before replacing familiar control behavior.
- Treat simplicity as clear organization, not as hiding necessary capability.
- Provide a visible or otherwise discoverable path for important actions; do
  not make a gesture, color, animation, or haptic the only carrier.
- Preserve user-created work through cancellation, undo, confirmation, drafts,
  or recovery appropriate to the risk.
- Ask for permissions and sensitive data in context, after explaining the
  benefit, and design the declined state.
- Treat accessibility, localization, and adaptation as inputs to the concept,
  not final compliance passes.

## Evidence and validation

For each major decision, retain:

- a one-sentence purpose and prioritized task list;
- rejected alternatives and the principle-based reason for rejection;
- a prototype covering success, interruption, cancellation, and recovery;
- evidence from representative people completing the task without coaching;
- current HIG and platform-resource checks for conventions affected by the
  decision.

Reject or revise a design when people cannot identify where they are, what they
can do, what will happen, or how to recover. Mark untested assumptions
explicitly; visual approval alone is not task validation.
