*! dagrets v1.0.0 MJBaker 17July2014
program dagrets
	version 11.2
	syntax varlist(numeric) [if] [in], PAYoffs(varlist numeric) ACTions(varlist numeric) GROUP(varname) GENerate(string)

	confirm new var `generate'		
	
	marksample touse
	qui count if `touse'

	tempvar touse2
	
	quietly {
	bysort `group': egen `touse2' = total(`touse')
	}
	
	quietly tab `touse2'
	if r(N)==0 {
		error 2000
	}

	mata: st_view(id=.,.,"`group'","`touse2'")
	mata: st_view(probs=.,.,"`varlist'","`touse2'")
	mata: st_view(Pays=.,.,tokens("`payoffs'"),"`touse2'")
	mata: st_view(Acts=.,.,tokens("`actions'"),"`touse2'")
	mata: Z=payoffsN(id,Acts,Pays,probs)

	quietly generate `generate'=.
	
	mata: st_view(generated=.,.,"`generate'","`touse2'")
	mata: generated[.,.]=Z
end

