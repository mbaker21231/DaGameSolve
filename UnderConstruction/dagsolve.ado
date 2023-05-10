*! dagsolve v1.0.1 MJBaker 21july2014
*! dagsolve v1.0.2 MJBaker 18sep2014
*! dagamesolver v1.0.3 MJBaker 8may2023
program dagsolve, rclass
	version 11.2
	syntax varlist(numeric) [if] [in], PAYoffs(varlist numeric) GROUP(varname) EQuilibria(string) ///
		    [FAST RANDOMpoints(int 50) NOISY PUREonly ///
			TOLerance(real 1e-12) MBwidth(real 1e-4) COLtol(real 1e-4) DIGITs(real 1e-8) MNits(real 100)]
	tempname details
	marksample touse
	quietly count if `touse'
	if `r(N)'==0 error 2000

	confirm new var `equilibria'_1_1_1

	if "`fast'"=="fast" {
		local method newton
		local mbwidth=`randompoints'
	}
	else {
		local method complete
	}
	
	if "`noisy'"=="noisy" {
		local noise noisy
	}
	else {
		local noise quietly
	}
	
	if "`pureonly'"=="pureonly" {
		local pureonly pureonly
	}
	else {
		local pureonly complete
	}

	mata: st_view(AA=.,.,tokens("`varlist'"),"`touse'")
	mata: st_view(PP=.,.,tokens("`payoffs'"),"`touse'")
	mata: st_view(id=.,.,"`group'","`touse'")
	
	mata: gs=panelsetup(id,1)
	mata: Asamp=panelsubmatrix(AA,1,gs)'
	mata: actVec=actCount(Asamp)
	mata: totActs=rowsum(actVec)

	tempname actVec totActs
	mata: st_matrix("actVec",actVec)
	mata: st_numscalar("totActs",totActs)

	mata: tol=strtoreal(st_local("tolerance"))
	mata: mbwidth=strtoreal(st_local("mbwidth"))
	mata: digits=strtoreal(st_local("digits"))
	mata: mnits=strtoreal(st_local("mnits"))
	mata: coltol=strtoreal(st_local("coltol"))
	mata: method=st_local("method")
	mata: noise =st_local("noise")
	mata: pureonly=st_local("pureonly")

	mata: Z=dagSolverN(AA,PP,id,tol,digits,mbwidth,coltol,mnits,method,noise,pureonly,actVec,Pays=.)
	mata: Count=rownonmissing(Z)/totActs
	mata: _editvalue(Count,0,.)
	mata: maxEqs=cols(Z)/totActs
	mata: st_numscalar("maxEqs",maxEqs)

	tempvar players acts pays
	scalar players=colsof(actVec)

	local eqs
	local pays
	forvalues i=1/`=maxEqs' {
		quietly gen `equilibria'_rets_`i'=.
		forvalues j=1/`=players' {
			forvalues k=1/`=actVec[1,`j']' {
				quietly gen `equilibria'_`i'_`j'_`k'=.
				local eqs "`eqs' `equilibria'_`i'_`j'_`k'"
			}
		}
		local pays "`pays' `equilibria'_rets_`i'"
	}
	
	quietly gen `equilibria'_count=.

	mata: st_view(EQS=.,.,"`eqs'","`touse'")
	mata: st_view(EQC=.,.,"`equilibria'_count","`touse'")
	mata: st_view(EQP=.,.,"`pays'","`touse'")

	mata: EQS[.,.]=Z
	mata: EQC[.,.]=Count
	mata: EQP[.,.]=Pays

	/* Create a variable to hold counts of equilibria */
	
	mata: mata drop Z actVec totActs maxEqs

	return clear
	return matrix playeractions=actVec
	return scalar totalactions=totActs
	return local method `method'
	return scalar maxeqs= maxEqs
	if ("`method'"=="complete") {
		return scalar mbwidth=`mbwidth'
		return scalar coltol=`coltol'
		return scalar mnits=`mnits'
		return scalar digits=`digits'
		return scalar tolerance=`tolerance'
	}
	else {
		return scalar tolerance=`tolerance'
		return scalar mnits=`mnits'
		return scalar randomeqpoints=`mbwidth'
	}
	
	/* Some other tidbits */
	
	quietly sum `equilibria'_count
	return scalar games=r(N)
	return scalar meaneqs=r(mean)
	return scalar maxeqs=r(max)
	return scalar mineqs=r(min)
	return scalar sdeqs=r(sd)	

end
