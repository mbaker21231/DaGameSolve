/* Test out my dagsolve command in all its glory */

clear all
set seed 522150
set more off
mata: ids=(1::20)#J(3,1,1)
getmata ids

gen acts=3
dagstrats acts, group(id) gen(a)

scalar P=r(profiles)

forvalues i=1/`=P' {
	gen p`i'=runiform()
}

dagsolve a1-a`=P', group(id) payoffs(p1-p`=P') equilibria(f) fast noisy randompoints(5)
dagsolve a1-a`=P', group(id) payoffs(p1-p`=P') equilibria(g) fast noisy randompoints(10)
dagsolve a1-a`=P', group(id) payoffs(p1-p`=P') equilibria(h) fast noisy randompoints(20)
dagsolve a1-a`=P', group(id) payoffs(p1-p`=P') equilibria(i) fast noisy randompoints(45)
dagsolve a1-a`=P', group(id) payoffs(p1-p`=P') equilibria(j) fast noisy randompoints(70)
dagsolve a1-a`=P', group(id) payoffs(p1-p`=P') equilibria(k) fast noisy randompoints(100)
dagsolve a1-a`=P', group(id) payoffs(p1-p`=P') equilibria(l) fast noisy randompoints(200)

dagsolve a1-a`=P' if id==18, group(id) payoffs(p1-p`=P') equilibria(m) fast noisy randompoints(1000)
dagsolve a1-a`=P' if id==18, group(id) payoffs(p1-p`=P') equilibria(p) coltol(1e-8) fast noisy randompoints(500)
dagsolve a1-a`=P' if id==18, group(id) payoffs(p1-p`=P') equilibria(q) coltol(1e-12) fast noisy randompoints(3000)
dagsolve a1-a`=P' if id==18, group(id) payoffs(p1-p`=P') equilibria(r) coltol(1e-12) noisy


scalar meqs=`r(maxeqs)'

forvalues i=1/`=meqs' {
	dagreshape foo_`i'*, actlist(acts) group(id) gen(rse`i')
}


drop a1-a`=P'
drop p1-p`=P'
/* Seems to work */

replace acts=4 in 2
replace acts=4 in 5
replace acts=4 in 8
replace acts=4 in 11

dagstrats acts, group(id) gen(a)

scalar P=r(profiles)

forvalues i=1/`=P' {
	gen p`i'=runiform()
}

dagsolve a1-a`=P', group(id) payoffs(p1-p`=P') equilibria(goo) noisy fast randompoints(10)
dagreshape goo_1*, actlist(acts) group(id) gen(rs)
dagrets goo_1*, payoffs(p1-p`=P') actions(a1-a`=P') group(id) gen(shoo)
