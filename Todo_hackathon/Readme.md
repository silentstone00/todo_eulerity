# GACS - Eulerity iOS Take-Home Exercise

# Today-Only Todo App

## Overview

Thank you for taking the time to complete this take-home exercise as part of our iOS interview process.

### The goal of this exercise is to understand how you approach:
1. iOS architecture and fundamentals
2. Product constraints and tradeoffs
3. Code clarity and organization
4. Handling of time, state, and persistence

## Time Expectation

1. Expected Effort ~6 hours
2. You may spend less if you choose

We value focus, prioritization, and clear decision-making over feature count or visual polish.

## The App

### Build a small iOS todo/reminder app with one central constraint:
1. The app only cares about today.
2. Tasks belong to the current day
3. Tasks expire at the end of the day
4. Each new day starts with a clean slate
5. There are intentionally no future dates, backlogs, or overdue tasks. This constraint is intentional and should guide your product and technical decisions.

## Technical Requirements

1. The app should be built using Swift and SwiftUI. 
2. The project’s minimum deployment target must be iOS 16.
3. Additionally, the app should be fully offline, with no network requests. 


### Must-Have Features
1. Today-Only Tasks
    > Users can add tasks for the current day
    > Tasks from previous days are not shown
    > Expiration happens automatically (no manual cleanup required)
2. Task Interaction
    > Add a task
    > Mark a task as complete
    > Persist tasks locally (e.g., SwiftData, CoreData, file storage, etc.)
3. Automatic Day Reset
    When a new day begins, old tasks should no longer appear in the main list

### Optional Enhancements (Not Required)

You may choose to implement any of the following, but none are required:

### UX / UI
1. Option to set a task expiration time (same day only)
2. Completed Task animations
3. Haptic feedback
4. Thoughtful empty states
5. Light/Dark mode support

### iOS Platform Features
1. Local notifications (must occur before end of day)
2. Widgets
3. App Intents / Siri

### Engineering / Architecture
1. Clear separation of concerns
2. View models or similar patterns
3. Unit tests for business logic
4. Date / time abstractions

We do not expect all of these. A small, clean implementation is perfectly acceptable.

### Out of Scope

To keep the exercise focused and fair, please do not implement:
1. User accounts or authentication
2. Scheduling tasks for future days
3. Complex settings screens

## Submission Instructions

Please submit the following:
1. A Git repository link
2. A README that includes:
    > Your overall approach
    > Key decisions or tradeoffs
    > What would you improve with more time
3. A short demo video (30–60 seconds)

### Questions

If anything in this document is unclear or you need clarification while working on the exercise, please reach out. We’re happy to help and want the expectations to be clear.


# Thank you again for your time and effort!
