log using further_experiments.log
clear all
mata: id = (1::200)#J(2,1,1)
getmata id
gen acts = 4
dagamestrats acts, gen(s) group(id)
set seed 134256
forvalues i=1/16 {
	gen pay`i'=rnormal(0, 1)
}
dagamesolve s*, group(id) pay(pay*) eq(eq) noisy
tab eq_count
log close