// Examples - 3 player games
*Normal games first
set seed 5150
clear all
set more off
mata: id=(1::1000)#J(3,1,1)
getmata id
bysort id: gen player = _n

gen acts=2
dagamestrats acts, group(id) gen(s)
scalar profiles=r(profiles)

forvalues i=1/`=profiles' {
	gen pay`i'=rnormal(0,1)
}

timer clear 99
timer on 99

dagamesolve s*, group(id) pay(pay*) eq(e) 

timer off 99
timer list 99

/* Test for oddness */

bysort id: gen last = _n == _N
sum e_count if last
tab e_count if last


* Now, make a 2-3-2 action 3 player game
drop pay* e* s*
replace acts=3 if player==2
dagamestrats acts, group(id) gen(s)
scalar profiles=r(profiles)
forvalues i=1/`=profiles' {
	gen pay`i'=rnormal(0,1)
}

timer clear 99
timer on 99

dagamesolve s*, group(id) pay(pay*) eq(e) noisy

timer off 99
timer list 99

sum e_count if last
tab e_count if last


*How about a four player game, each player with two strategies?
clear all
mata: id=(1::1000)#J(4,1,1)
getmata id
bysort id: gen player = _n
gen acts=2
dagamestrats acts, group(id) gen(s)
scalar profiles=r(profiles)
forvalues i=1/`=profiles' {
	gen pay`i'=runiform()
}

timer clear 99
timer on 99

dagamesolve s*, group(id) pay(pay*) eq(e) noisy
sum e_count
tab e_count

timer off 99
timer list 99





set more off
*Four player game, one player with three strategies:
drop pay* e* s* player
bysort id: gen player=_n
replace acts=3 if player==3
replace acts=3
dagamestrats acts, group(id) gen(s)
scalar profiles=r(profiles)
forvalues i=1/`=profiles' {
	gen pay`i'=rnormal(0,1)
}
set more off
dagamesolve s*, group(id) pay(pay*) eq(e) noisy fast randompoints(600)
sum e_count
tab e_count




