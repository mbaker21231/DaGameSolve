# DaGameSolve

**DaGameSolve** is a Stata/Mata package for solving finite, discrete-action,
simultaneous-move games of complete information.

The package supports N-player games with differing numbers of actions and can
solve either individual games or sequences of games in a single call.

DaGameSolve searches for both pure- and mixed-strategy Nash equilibria.

## Main commands

- `dagamestrats` constructs action profiles for one or more games.
- `dagamesolve` solves the resulting games for Nash equilibria.

## Solver modes

By default, `dagamesolve` uses a complete mixed-strategy search intended to
locate all equilibria.

The `fast` option uses Newton searches from multiple starting values and can be
substantially faster, although it does not provide the same completeness
guarantee as the full search.

The `pureonly` option restricts the search to pure-strategy equilibria.

## Dependencies

DaGameSolve requires:

- `moremata`
- `int_utils`
- `rowmat_utils`
- `intsolver`

The file `dependency.do` installs the required packages.

## Status

DaGameSolve is under active development. Current work focuses on testing,
documentation, and improving the performance of the mixed-strategy solver.
