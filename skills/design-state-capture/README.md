# Design State Capture

Prepare a set of screenshots and an HTML gallery for viewing specified screens and UI states.

## Local Installation

Extract the archive and copy the entire `design-state-capture` folder into `~/.codex/skills/`. If the skill is already installed, back up the old folder and replace it with the new one. For another agent, use its user skills directory.

Invoke with `$design-state-capture`. This version is self-contained and does not require a neighboring `setup-ios-project` skill; application builds use the current project's instructions.

## Usage

> Use $design-state-capture. Capture the profile screen: loaded data, loading, and error. Device: iPhone. Conditions: Russian language, light theme. Application: [path to your project].

Explicitly specify the screens/states and device type — iPhone or iPad. If these are missing, the agent will ask for the missing parameters in one question. Additional conditions are optional; current settings are used. The skill must not expand the set of states on its own.

## Requirements

Capturing requires a working project, its build tools, and an available simulator; Apple Simulator requires macOS with the appropriate tools. The agent needs a way to launch the application, obtain the specified states, and capture the simulator without taking over the cursor. If a state is difficult to obtain, temporary data substitutions in the real application are allowed, followed by restoration.

The gallery generator uses Python 3.9+ and only the standard library. The gallery opens locally without a server or external dependencies. To share a capture, send the entire output folder, including the PNGs.
