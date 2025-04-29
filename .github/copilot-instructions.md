## Guidelines for Creating or Updating a Plan

- When creating a plan, organize it into numbered phases (e.g., "Phase 1: Setup Dependencies")
- Break down each phase into specific tasks with numeric identifiers (e.g., "Task 1.1: Add Dependencies")
- Please only create one document per plan
- Mark phases and tasks as `- [ ]` while not complete and `- [x]` once completed
- End the plan with success criteria that define when the implementation is complete
- Plans and architectures that you produce should go under `docs/plans`
- Use a consistent naming convention `YYYYMMDD-<short-description>.md` for plan files
- Prior to creating a plan, review existing decision records in `docs/decisions` to understand previous decisions and their implications for proposed work
- Include prior decisions in your thinking: "Related prior decisions: [key findings]"

## Guidelines for Implementing a Plan

- Code you write should go under `src`
- When coding you need to follow the plan and check off phases and tasks as they are completed
- As you complete a task, update the plan by marking that task as complete before you begin the next task
- As you complete a phase, update the plan by marking that phase as complete before you begin the next phase
- Tasks that involve tests should not be marked complete until the tests pass.
- Create decision records for any significant decisions made during the implementation of a plan
   - Choice of technology
   - Choice of pattern or abstraction
   - Choice of data structure
   - Choice of algorithm
   - Choice of design principles
   - Etc.
- Update existing decision records if the decision is being revisited or if new information changes the context of the decision

## Guidelines for Creating Decision Records

- Decision records should be created in the `docs/decisions` folder
- Decision records should be named in the format `YYYYMMDD-<short-description>.md`
- Decision records should be in the following format:

   ```markdown
   # _Title of the decision_
   ## Status
      _What is the status, such as proposed, accepted, rejected, deprecated, superseded, etc.?_
   ## Context
      _What is the context of the decision? What is the core issue in question? What are the forces at play? What are the requirements and constraints?_
   ## Decision
      _What is the decision? What are the options considered? What are the pros and cons of each option? What is the rationale for the decision?_
   ## Consequences
      _What are the consequences of the decision? What are the implications for the system? What are the risks and trade-offs?_
   ## Updates
      _Add any updates to the decision record over time, here. This can include changes in status, context, decision, or consequences. Include a timestamp for each update._
   ```

- Only create decision records for decisions that are significant and have a lasting impact on the project
- Decision records should be created when a decision is made, not when it is implemented
- Decision records should be updated as the project evolves and new information becomes available
