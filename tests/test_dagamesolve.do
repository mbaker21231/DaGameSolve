clear all
set more off

*------------------------------------------------------------*
* TEST 1: sequence of three 2-player, 2-action games
*
* Game 1: coordination game -> 3 equilibria
* Game 2: dominant-strategy game -> 1 equilibrium
* Game 3: matching pennies -> 1 equilibrium
*------------------------------------------------------------*

set obs 6

gen id = ceil(_n/2)
bysort id: gen player = _n

gen acts = 2

dagamestrats acts, group(id) generate(s)

* Create payoff variables
forvalues i = 1/4 {
    gen pay`i' = .
}

* Game 1: coordination
replace pay1 = 1 if id==1
replace pay2 = 0 if id==1
replace pay3 = 0 if id==1
replace pay4 = 1 if id==1

* Game 2: action 2 strictly dominant
replace pay1 = 3 if id==2 & player==1
replace pay2 = 0 if id==2 & player==1
replace pay3 = 5 if id==2 & player==1
replace pay4 = 1 if id==2 & player==1

replace pay1 = 3 if id==2 & player==2
replace pay2 = 5 if id==2 & player==2
replace pay3 = 0 if id==2 & player==2
replace pay4 = 1 if id==2 & player==2

* Game 3: matching pennies
replace pay1 =  1 if id==3 & player==1
replace pay2 = -1 if id==3 & player==1
replace pay3 = -1 if id==3 & player==1
replace pay4 =  1 if id==3 & player==1

replace pay1 = -1 if id==3 & player==2
replace pay2 =  1 if id==3 & player==2
replace pay3 =  1 if id==3 & player==2
replace pay4 = -1 if id==3 & player==2

dagamesolve s*, group(id) payoffs(pay*) equilibria(e)

* Equilibrium counts are stored on final player row of each game
assert e_count==3 if id==1 & player==2
assert e_count==1 if id==2 & player==2
assert e_count==1 if id==3 & player==2

display "PASS: sequence of games solved correctly"