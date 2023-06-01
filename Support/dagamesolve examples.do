// Examples - 3 player games
*Normal games first
set seed 5150
clear all
set more off
mata: id=(1::100)#J(3,1,1)
getmata id
gen acts=2
dagamestrats acts, group(id) gen(s)
scalar profiles=r(profiles)
forvalues i=1/`=profiles' {
	gen pay`i'=rnormal(0,1)
}
dagamesolve s*, group(id) pay(pay*) eq(e) noisy
sum e_count

*Uniform games
drop pay* e*
forvalues i=1/`=profiles' {
	gen pay`i'=runiform()
}
dagamesolve s*, group(id) pay(pay*) eq(e) noisy
sum e_count

* Now, make a 2-3-2 action 3 player game
drop pay* e* s*
bysort id: gen player=_n
replace acts=3 if player==2
dagamestrats acts, group(id) gen(s)
scalar profiles=r(profiles)
forvalues i=1/`=profiles' {
	gen pay`i'=rnormal(0,1)
}
dagamesolve s*, group(id) pay(pay*) eq(e) noisy
sum e_count
* How about with uniform payoffs?

drop pay* e*
forvalues i=1/`=profiles' {
	gen pay`i'=runiform()
}
dagamesolve s*, group(id) pay(pay*) eq(e) noisy
sum e_count
*How about a four player game, each player with two strategies?
clear all
mata: id=(1::100)#J(4,1,1)
getmata id
gen acts=2
dagamestrats acts, group(id) gen(s)
scalar profiles=r(profiles)
forvalues i=1/`=profiles' {
	gen pay`i'=runiform()
}
dagamesolve s*, group(id) pay(pay*) eq(e) noisy
sum e_count

set more off
*Four player game, one player with three strategies:
drop pay* e* s*
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




