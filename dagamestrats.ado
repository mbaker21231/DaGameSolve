*! dagstrats v1.0.0 MJBaker 17July2014
*! dagamestrats v2.0.0 MJBaker 50May2023
program dagamestrats, rclass
	version 11.2
	syntax varname(numeric) [if] [in], GROUP(varname) GENerate(string) 
	marksample touse
	qui count if `touse'
	
	if r(N)==0 {
		error 2000
	}
	
	tempvar groupcounter
	quietly bysort `group': egen `groupcounter'=count(`group')
	quietly tab `groupcounter'
	
	if r(r)!=1 {
		di "{err}Unbalanced game sizes - all games must have the same # of players!"
		exit 
	}
	
	tempvar idno idnoN
	bysort `group': gen `idno'=_n

	quietly sum `idno'
	local idnoN=r(max)

	forvalues i=1/`idnoN' {
		quietly tab `varlist' if `idno'==`i'
		if r(r)!=1 {
			display "{err}Error: # actions must conform across players and games!"
			exit
		}
	}
	tempvar totals logs 
	tempname maxtot strats

	quietly {
		gen `logs'=ln(`varlist')
		bysort `group': egen `totals'=total(`logs')
		replace `totals'=round(exp(`totals'))
		sum `totals'
		local maxtot=r(max)
	}

	local strats 
	forvalues i=1/`maxtot' {
		quietly gen `generate'`i'=.
		local strats "`strats' `generate'`i'"
	}
	
	mata: st_view(id=.,.,"`group'","`touse'")
	mata: st_view(acts=.,.,"`varlist'","`touse'")
	mata: st_view(S=.,.,tokens("`strats'"),"`touse'")
	mata: maxtot=strtoreal(st_local("maxtot"))
	mata: S[.,.]=dagStrats(id,acts,maxtot)
	
	/* Fill in values for return */
	quietly tab `group'
	local groups=r(r)

	return clear
	return scalar groups=`groups'
	return scalar profiles=`maxtot'
end
