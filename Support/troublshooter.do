* Identify the game at observation 204
local badid = id[204]
display "Problematic game ID: `badid'"

preserve
keep if id == `badid'

* Save the problematic game and its original solutions
save "problem_game.dta", replace

* Solve again with a tighter consolidation tolerance
timer clear 99
timer on 99

dagamesolve s*, group(id) pay(pay*) eq(q) coltol(1e-6)

timer off 99
timer list 99

* Compare original and new counts
list id e_count q_count if !missing(q_count), noobs

use "problem_game.dta", clear

timer clear 99
timer on 99

dagamesolve s*, group(id) pay(pay*) eq(m5) ///
    coltol(1e-4) mbwidth(1e-4)

timer off 99
timer list 99

list id e_count m5_count if !missing(e_count), noobs