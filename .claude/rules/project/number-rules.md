## Numeric Comparisons

Prohibited: `>`, `>=`

Validation process:
1. Extract the comparison operator
2. Check if the operator is `>` or `>=`
3. If no → the code does not violate this rule
4. If yes:
   4-1. Double-check: does the code actually contain `>` or `>=`?
   4-2. If yes → REJECT and rewrite using `<` or `<=`

Important:
Some languages prefer placing constants on the left-hand side (e.g., Yoda conditions).
However, under this rule, constants and variables may appear on either side—
the key requirement is to use `<` or `<=` instead of `>` or `>=`.

Examples:
`x > 0` → REJECT → `0 < x`
`x >= 5` → REJECT → `5 <= x`
`0 < x` → ACCEPT (operator is `<`)
`max <= 100` → ACCEPT (operator is `<=`)
