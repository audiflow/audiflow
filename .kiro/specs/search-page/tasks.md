# Implementation Plan

> **Parallel marker**: Append ` (P)` only to tasks that can be executed in parallel. Omit the marker when running in `--sequential` mode.
>
> **Optional test coverage**: When a sub-task is deferrable test work tied to acceptance criteria, mark the checkbox as `- [ ]*` and explain the referenced requirements in the detail bullets.

---

## Phase 1: Skeleton and Wiring

- [ ] 1. Establish search feature skeleton with controller stub and routing
- [x] 1.1 Create search state models and controller stub
  - Define sealed class hierarchy for search states: initial, loading, success, error
  - Implement SearchController with Riverpod annotation returning initial state
  - Add stub search method that immediately returns error state
  - Add stub retry method that delegates to search
  - _Requirements: 1.3, 1.4, 3.2, 5.3_

- [x] 1.2 Create search screen skeleton with input field wiring
  - Build stateless screen widget that watches SearchController
  - Add text input field with text editing controller
  - Add submit button with search icon next to input
  - Wire submit button tap to call controller search method
  - Wire keyboard submit action to call controller search method
  - Implement keyboard dismissal when search is initiated
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [x] 1.3 Register search route in application navigation
  - Add search page route definition to go_router configuration
  - Ensure route is accessible from main navigation
  - _Requirements: 2.3_

## Phase 2: Core Implementation

- [ ] 2. Implement search controller with full state management
- [x] 2.1 Implement search execution with state transitions
  - Connect to PodcastSearchService from audiflow_search package
  - Transition state from initial to loading when search starts
  - Transition to success state with results on successful response
  - Transition to error state with exception details on failure
  - Store last query for retry functionality
  - Write unit tests: search transitions through correct states
  - _Requirements: 1.3, 1.4, 3.2_

- [x] 2.2 Implement duplicate submission prevention
  - Guard search method to reject calls when already loading
  - Guard search method to reject empty or whitespace-only queries
  - Write unit tests: duplicate calls during loading are ignored
  - Write unit tests: empty queries do not trigger API call
  - _Requirements: 3.2_

- [x] 2.3 Implement retry functionality
  - Use stored last query to re-execute search on retry call
  - Handle case where no previous query exists
  - Write unit tests: retry re-executes last query
  - _Requirements: 5.3_

- [ ] 3. Build search result tile widget
- [x] 3.1 (P) Implement result tile with podcast metadata display
  - Display podcast artwork with placeholder for missing images
  - Show podcast title with appropriate text styling
  - Show author name below title
  - Show first genre from genres list
  - Show truncated summary/description
  - Handle tap gesture with callback to parent
  - Write widget tests: tile renders all metadata fields
  - Write widget tests: tap triggers callback
  - _Requirements: 2.1_

- [ ] 4. Implement search screen UI states
- [ ] 4.1 Implement initial empty state display
  - Show empty state view when controller state is initial
  - Display appropriate messaging for pre-search state
  - Write widget test: initial state renders empty view
  - _Requirements: 4.1_

- [ ] 4.2 Implement loading state with indicator
  - Show loading indicator when controller state is loading
  - Disable submit button during loading to prevent visual confusion
  - Write widget test: loading state shows indicator
  - _Requirements: 3.1, 3.2_

- [ ] 4.3 Implement results list display
  - Render scrollable list of results using lazy builder
  - Use PodcastSearchResultTile for each result item
  - Position results below search input area
  - Write widget test: results state renders correct item count
  - _Requirements: 2.1, 2.2_

- [ ] 4.4 Implement no results found state
  - Show not-found icon when search returns empty results
  - Display explanatory text indicating no podcasts matched
  - Write widget test: empty results state shows not-found UI
  - _Requirements: 4.2_

- [ ] 4.5 Implement error state with retry option
  - Display error message describing the issue
  - Show retry button below error message
  - Wire retry button to call controller retry method
  - Write widget test: error state shows message and retry button
  - Write widget test: retry button tap triggers retry
  - _Requirements: 5.1, 5.2, 5.3_

## Phase 3: Integration and Scenario Tests

- [ ] 5. Complete navigation and end-to-end integration
- [ ] 5.1 Implement navigation to podcast detail
  - Handle tap on search result tile
  - Extract podcast identifier from tapped result
  - Navigate to podcast detail screen via go_router
  - Write integration test: tapping result navigates to detail
  - _Requirements: 2.3_

- [ ] 5.2 Verify keyboard dismissal behavior
  - Ensure keyboard is dismissed before search request begins
  - Write integration test: keyboard hides on search submission
  - _Requirements: 1.5_

- [ ] 5.3 End-to-end search flow scenario tests
  - Test complete flow: enter query, submit, receive results, tap result
  - Test error flow: enter query, submit, receive error, tap retry, receive results
  - Test empty results flow: enter query, submit, receive empty response
  - Use mocked API responses for deterministic testing
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 2.1, 2.2, 2.3, 3.1, 3.2, 4.2, 5.1, 5.2, 5.3_

---

## Requirements Coverage Matrix

| Requirement | Task(s) |
|-------------|---------|
| 1.1 | 1.2, 5.3 |
| 1.2 | 1.2, 5.3 |
| 1.3 | 1.1, 1.2, 2.1, 5.3 |
| 1.4 | 1.1, 1.2, 2.1, 5.3 |
| 1.5 | 1.2, 5.2, 5.3 |
| 2.1 | 3.1, 4.3, 5.3 |
| 2.2 | 4.3, 5.3 |
| 2.3 | 1.3, 5.1, 5.3 |
| 3.1 | 4.2, 5.3 |
| 3.2 | 1.1, 2.1, 2.2, 4.2, 5.3 |
| 4.1 | 4.1 |
| 4.2 | 4.4, 5.3 |
| 5.1 | 4.5, 5.3 |
| 5.2 | 4.5, 5.3 |
| 5.3 | 1.1, 2.3, 4.5, 5.3 |
