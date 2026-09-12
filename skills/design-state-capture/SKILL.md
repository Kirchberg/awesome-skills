---
name: design-state-capture
description: Prepare a set of real application screenshots and a local HTML gallery for viewing specified screens and UI states. Use when the user explicitly asks to capture application UI states or prepare them for design review.
---

# Design State Capture

Deliverable: a separate, portable folder containing original PNGs, `cases.json`, and `index.html`. The user defines what to capture; choose how to obtain those states and prepare the gallery yourself.

For building and launching, use the applicable instructions and available skills in the current project. The capture and gallery workflows are described below.

## Inputs

Before building or substituting data, establish:

- **What to capture:** specific screens or elements and their expected states or scenario steps. An explicit request to capture the current view also defines a state. If only a screen with multiple states is named, ask which states are needed instead of choosing them yourself.
- **Device:** iPhone or iPad; the specific model, if the user specified one.
- **Application / project:** use the explicitly provided context; ask if multiple applications could apply.

Account for answers already given in the current conversation. If required information is missing, collect the missing parameters in one short question and wait for the answer. Do not choose screens or states from the diff, code, or your own judgment. First turn “all states” into a concrete list for approval.

**Additional conditions are optional:** language, theme, orientation, and test data. Use the application's current settings by default; do not multiply variants. If only the device type is specified, choose an available simulator of that type and report the model before capturing. Do not substitute an iPhone for an iPad or vice versa. If the required device is unavailable, ask what substitution is acceptable.

Once the information is sufficient, briefly list what will be captured and proceed without asking for confirmation again. Do not add new states unless the user requests them.

## Obtaining States

1. Read the applicable project instructions. Inspect only the code needed for the specified states and the existing build, launch, and navigation mechanisms.
2. Before making temporary changes, record the initial state of affected files and save backups outside the repository. Create a new output folder outside the codebase, named after the task and a date or iteration number; do not overwrite existing results.
3. Build and launch the application on the selected simulator. Use simulator automation tools, such as `simctl` for launching, deep links, and screenshots, and available UI automation tools for navigation. Do not take over the cursor or switch the user's window focus. Check tool capabilities and syntax against the available help.
4. Prefer existing scenarios, test data, and debug mechanisms. If a state is difficult to obtain, temporarily substituting a response or UI model is acceptable when using the application's real components. Do not draw a replacement screen or create a separate imitation of its layout.
5. When capturing many states, switch temporary data without rebuilding for each frame where possible. Keep substitutions local and reversible; do not change global settings or shared data for capture convenience.
6. Capture real simulator screenshots after the intended screen appears and incidental transitions finish. Deliberately reproduce loading or error states when those are requested. Keep data, scroll position, and settings consistent across comparable states. Do not scale or edit the original PNGs.
7. After each capture, verify that it shows the specified state rather than the previous screen, a system dialog, or an incidental overlay. If a state is unavailable, record the reason; do not substitute another state or claim it was captured.

## Gallery

Read the [cases.json format](references/cases-format.md). Record only states that were actually captured and relative paths to the original PNGs. Metadata about how a state was obtained may be stored there, but do not display it on the viewing page.

Create the gallery with the bundled generator:

```text
python3 <skill-path>/scripts/build_gallery.py <output-folder>/cases.json
```

Use `--replace` to deliberately update the HTML within the same iteration; create a new folder for a new capture session. The generator does not capture the application or verify screenshot content.

Page requirements:

- A simple heading, a short description, and clear state names grouped meaningfully.
- No internal explanations, identifiers, filenames, or substitution notes on the page itself.
- A responsive grid, a consistent scale for screens from the same device, and preserved aspect ratios. Do not stretch a small number of cards across the full width: limit phone previews to 320 CSS px and tablet previews to 480 CSS px.
- Clicking opens the original PNG. All resources are local; the folder must work after being moved to another computer.

Open the HTML using an available method that does not take over the cursor, and check rendering, labels, grouping, and preview sizes. Static HTML checks do not prove correct rendering: if viewing is unavailable, state this explicitly in the report.

## Restoration and Completion

- Remove only the code and data substitutions introduced for the capture. Compare affected files against their saved initial state; preserve other people's changes and pre-existing changes. If a file was modified concurrently, remove your own changes selectively instead of restoring the entire file.
- If you modified the application for the capture, build and launch the normal version after restoring it. Do not commit temporary code. After a failure or interruption, first check the current state and remove any remaining substitutions, then continue.
- Verify that all claimed PNGs exist, each matches its label, incidental overlays are absent, and text clipping and the elements of interest to the user have been checked. Deliver the entire folder, not just the HTML file.
- Provide links to the gallery and folder. Separately and briefly report uncaptured states, any substitutions used, discrepancies noticed, and the application restoration result. Visual inspection does not confirm business logic or conformity to designs without a separate check.

Example request:

> Use $design-state-capture. Capture the profile screen on iPhone: loaded data, loading, and error. Light theme, Russian language. The project is specified in the current task.
