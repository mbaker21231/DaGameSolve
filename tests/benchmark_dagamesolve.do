clear all
set more off
set seed 5150

*------------------------------------------------------------*
* BENCHMARK 1
* 100 three-player games, two actions per player
* Random normal payoffs
* Complete solver
*------------------------------------------------------------*

mata: id=(1::100)#J(3,1,1)
getmata id

gen acts = 2
dagamestrats acts, group(id) generate(s)

scalar profiles = r(profiles)

forvalues i=1/`=profiles' {
    gen pay`i' = rnormal()
}

timer clear 1
timer on 1

dagamesolve s*, group(id) payoffs(pay*) equilibria(e)

timer off 1
timer list 1

summarize e_count