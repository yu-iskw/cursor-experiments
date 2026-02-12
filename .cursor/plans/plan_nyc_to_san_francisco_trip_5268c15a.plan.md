---
name: Update Trip Planner Orchestrator
overview: Update the trip-planner agent to act as a pure orchestrator that delegates research to specialized agents and synthesizes their reports.
todos: []
isProject: false
---

### 1. Update Trip Planner Agent Definition

- Modify [.cursor/agents/trip-planner.md](.cursor/agents/trip-planner.md) to explicitly define its role as an **Orchestrator**.
- Add a **Workstream/Workflow** section that guides the agent through:
  1. Parsing user input.
  2. Delegating to sub-agents.
  3. Integrating results into a final report.
- Add a **Constraints** section to prevent original research.

### 2. Refine Delegation Instructions

- Ensure the agent knows it must wait for and use the outputs from [@flight-researcher](.cursor/agents/flight-researcher.md) and [@hotel-researcher](.cursor/agents/hotel-researcher.md).
- Define the expected final output format (e.g., "Integrated Itinerary").
