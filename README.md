# Class Election App

Built on Labs 4, 8, and 9.

## Features
- **Vote Screen**: Type voter name and cast a vote for any candidate. Includes an option to undo the last vote.
- **Results Screen**: Displays ranked candidates, vote counts, percentage of total votes (1 decimal place), progress bars, winner/tie banner, and class turnout calculation based on configurable class size.
- **Candidates Screen**: Add new candidates or remove candidates who have zero votes. Reset all votes with confirmation.

---

## 思考 (Reflection Questions)

### 1. Why must names be cleaned before they are compared? Give an example of what goes wrong otherwise.
Names must be cleaned (trimming whitespace, collapsing multiple spaces into a single space, and converting to Title Case) before they are compared or stored to ensure uniqueness and prevent duplicate entries caused by typos or formatting differences.
- **Example of what goes wrong otherwise**: If User A votes as `"  aline  "` and later tries to vote again as `"ALINE"` or `"Aline"`, without cleaning and case-normalization, the system would treat them as two different voters and allow User A to vote multiple times. Cleaning ensures that variations like `" aLINE "` and `"Aline"` normalize to `"Aline"` and are correctly recognized as already having voted.

### 2. How does your app decide between a winner and a tie? Explain it in plain words.
The app first checks the total number of votes. If no votes have been cast, it displays "No votes yet".
When votes exist, it finds the maximum number of votes received by any candidate in the election. It then filters all candidates to see how many have that exact maximum score:
- **Winner**: If exactly one candidate has the highest score, that candidate is declared the winner (`Winner: [Name]`).
- **Tie**: If two or more candidates share the highest score, all tied candidates are listed together along with their vote count (`Tie between [Name1] and [Name2] ([X] votes each)`).
