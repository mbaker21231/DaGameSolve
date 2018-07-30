*! dagreshape v1.0.0 MJBaker 17July2014
program dagreshape
	version 11.2
	syntax varlist(numeric) [if] [in], ACTlist(varlist numeric) GROUP(varname) GENerate(string)

	confirm new var `generate'_1	
	
	marksample touse
	tempvar touse2

	quietly {
		bysort `group': egen `touse2' = total(`touse')
	}
		
	quietly tab `touse2'
	if r(N)==0 {
		error 2000
	}	
	
	quietly sum `actlist'
	scalar max=r(max)
	
	mata: st_view(id=.,.,"`group'","`touse2'")
	mata: st_view(probs=.,.,"`varlist'","`touse2'")
	mata: st_view(Acts=.,.,tokens("`actlist'"),"`touse2'")
	
	mata: Z=probReshape(id,Acts,probs)

	local generated 
	forvalues i=1/`=max' {
		quietly generate `generate'_`i'=. 
		local generated "`generated' `generate'_`i' "
	}
	
	mata: st_view(generated=.,.,"`generated'","`touse2'")

	mata: generated[.,.]=Z
end
