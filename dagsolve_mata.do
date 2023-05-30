mata:
mata clear
mata set matastrict on
struct gameDescription {
	real matrix act,pay,actDesc,
		actKey,actKeyFocs,actKeyMax,
		psNeqs,mixedEqs,domHist,
		redPay,redActDesc,focCount,
		redAct,redActKey,redActKeyFocs,
		redActKeyMax, nEqRows, redPsNeqs,
		redMixedEqs, redNEqRows, initPts, lyapVals
	real scalar players, solved, reduced, domSolved, newton,
		digits, mbwidth, tol, tolsols, maxit, noise, pureonly	
	/* Collection of information about the game */
	/* Note that actKey is the NKX2 list of actions */
	/* actDesc is an N-rowvector with action count */
}

struct gameDescription gameInit(real matrix Act,real matrix Pay)
{
 
	real matrix actKeyFoc,actKeyMax
	
	struct gameDescription scalar G

	G.act=Act
	G.pay=Pay
	G.players=cols(Act)
	G.actKey=actKeyCreate(Act)
	G.actDesc=actCount(Act)

	actKeyConvert(G.actKey,actKeyFoc=.,actKeyMax=.)
	G.actKeyFocs=actKeyFoc
	G.actKeyMax=actKeyMax
	
	G.solved=0
	G.domSolved=0
	G.reduced=0
	G.newton=0
	G.noise=0
	G.pureonly=0
	
	G.digits=1e-8
	G.mbwidth=1e-4
	G.tol=1e-12
	G.tolsols=1e-4
	G.maxit=100
	
	return(G)
	/* Game initiated without solutions */
}
void gameSolutionDigits(struct gameDescription G, real scalar digits) G.digits=digits
void gameSolutionMbwidth(struct gameDescription G, real scalar mbwidth) G.mbwidth=mbwidth
void gameSolutionTol(struct gameDescription G, real scalar tol) G.tol=tol
void gameSolutionTolSols(struct gameDescription G, real scalar tolsols) G.tolsols=tolsols
void gameSolutionMaxit(struct gameDescription G, real scalar maxit) G.maxit=maxit

real matrix gameSolutionsReturn(struct gameDescription G)
{
	if (rows(G.psNeqs)==0 & rows(G.mixedEqs)!=0) return(G.mixedEqs)
	else if (rows(G.psNeqs)!=0 & rows(G.mixedEqs)==0) return(G.psNeqs)
	else if (rows(G.psNeqs)!=0 & rows(G.mixedEqs)!=0) return(G.psNeqs \ G.mixedEqs)
	else return(-99)
}

real matrix gameLyapValsReturn(struct gameDescription G) return(G.lyapVals)
real matrix gameSolutionMethod(struct gameDescription G, string scalar newton, real matrix initPts) 
{
	if (newton=="newton") {
		G.newton=1
		G.initPts=initPts
	}
}
real matrix gameSolutionNoise(struct gameDescription G, string scalar noise)
{
	if (noise=="noisy") {
		G.noise=1
	}	
}
real matrix gamePureOnly(struct gameDescription G, string scalar pureonly) {
	if (pureonly=="pureonly") {
		G.pureonly=1
	}
}
real scalar gameDomSolved(struct gameDescription G) return(G.domSolved)
real matrix gameActProfiles(real vector K)
{
	real matrix S
	real scalar i,n
	
	n=length(K)
	S=1::K[1]
	for (i=2;i<=n;i++) S=S#J(K[i],1,1),J(rows(S),1,1)#(1::K[i])
	return(S)
	
	/* Utility tool: makes action profiles where # of 
	   strategies for each player is listed in K, while
	   size of K indicates size of game - the "list" form 
	   Example: K=3,3,3 gives a 3x3x3 list of potential actions */
}
real matrix dagStrats(real matrix ids, real matrix acts, real scalar maxacts)
{
	real matrix S,StoAdd,panels,actsp
	real scalar i

	panels=panelsetup(ids,1)
	S=J(rows(ids),maxacts,.)
	
	for (i=1;i<=rows(panels);i++) {
		actsp=panelsubmatrix(acts,i,panels)
		StoAdd=gameActProfiles(actsp)'
		S[panels[i,1]::panels[i,2],1::cols(StoAdd)]=StoAdd
	}
	return(S)
}
real matrix actKeyCreate(real matrix A)
{
	real scalar j
	real matrix actkey, filler
	actkey=J(0,2,.)
	for (j=1;j<=cols(A);j++) {
		filler=rows(uniqrows(A[,j]))
		actkey=actkey\J(filler,1,j),(1::filler)
	}
	return(actkey)
	/* Builds an action key out of a matrix of actions */
	/* Matrix has #actions rows and 2 colums - first   */
	/* player, then action number. Kind of an inverse  */
	/* for dg_actprofs */
}

real matrix actList(real vector K)
{
	real matrix List
	real scalar i
	i=1
	List=J(0,2,.)
	do {
		List=List \ (J(K[i],1,i),(1::K[i]))
		i=i+1
		} while (i<=length(K))
	return(List)
	/* Utility that creates a column vector naming actions and players 
	   The idea kind of mirrors panelsetup in some ways, but not exactly.
	   Creates something that conforms with actkey_create The three functions 
	   kind of go together */
}
real matrix actCount(real matrix A)
{
	real scalar i
	real matrix count
	
	count=J(1,cols(A),.)
	for (i=1;i<=cols(A);i++) count[i]=rows(uniqrows(A[,i]))
	return(count)
	/* given an action list, returns the "K" vector going with it (inverse of GameActProfiles */
}

real matrix payoffs(real matrix A, real matrix P, real matrix act_desc, real matrix problist)
{
	real matrix probs,Payoffs,Probs,Total

	probs=outcomeProbs(act_desc,problist)
	Payoffs=J(1,rows(problist),1)#P
	Probs=probs#J(1,cols(P),1)
	Total=colsum(Payoffs:*Probs)

	return(rowshape(Total,rows(problist)))

	/* Utility tool: Takes a vector (really many row vectors) of probabilities - action profiles -
	   and then computes expected payoffs. */
}
void actKeyConvert(real matrix actkey,
				 transmorphic actkey_foc,
				 transmorphic maxact_foc)
{
	real scalar j 
	real matrix players,maxpos,maxposint 
	players = uniqrows( actkey[,1] )
	maxact_foc=J(0,2,.)
	for (j=1; j<=rows(players); j++) {
		maxact_foc = maxact_foc \ 
			(players[j], max( select(actkey[,2],actkey[,1]:==players[j])))
			}

	maxpos=J(rows(maxact_foc),1,.)
	for (j=1;j<=rows(maxact_foc);j++) {
		maxpos[j]=mm_which(rowsum(actkey:==maxact_foc[j,]):==2)
		}

	maxposint=J(rows(actkey),1,1)
	maxposint[maxpos,1]=J(rows(maxpos),1,0)
	
	actkey_foc=select(actkey,maxposint)	
	
	/* Creates little panel id style things holding the first n-1 actions for
	   each player (which are used in forming focs) , and then the positions 
	   of every nth action. */
}

real matrix payGrad(real matrix p, 
					real matrix A, 
					real matrix P,
					real matrix actkey,
					real matrix actkey_foc,
					real matrix maxact_foc,
					real scalar i)
{
	real scalar player,pactno,pm1,pm0,j,k
	real matrix plistmod, problist, part1, part2, Klist, pother, zeros

	player=actkey_foc[i,1]
	pactno=select(maxact_foc[,2],maxact_foc[,1]:==player)

	pm0=mm_which(rowsum(actkey:==(player,actkey_foc[i,2])):==2)
	pm1=mm_which(rowsum(actkey:==(player,pactno)):==2)
	pother=mm_which((actkey[,1]:==player):*
				    (actkey[,2]:!=actkey_foc[i,2]):*
					 (actkey[,2]:!=pactno))
	
	problist=J(rows(p),0,.)

	j=uniqrows(actkey[,1])
	for (k=1;k<=rows(j);k++) {
		part1=select(p',actkey_foc[,1]:==J(rows(actkey_foc),1,j[k]))'
		part2=1:-rowsum(part1)
		problist=problist,part1,part2
	}

	plistmod=problist

	plistmod[,pm0]=J(rows(plistmod),1,1)
	plistmod[,pm1]=J(rows(plistmod),1,-1)
	
	if (rows(pother)>0) {
		zeros=rowshape(pother,1)
		plistmod[,zeros]=J(rows(plistmod),cols(zeros),0)
	}

	Klist=J(1,cols(A),.)
	for (k=1;k<=cols(A);k++) Klist[k]=rows(uniqrows(A[,k]))
	
    return(payoffs(A,P,Klist,plistmod)[,player])
	
	/* The tricky thing here is that j should refer to an equation number! Not an action */
	/* This is producing an error for anything greater than the number of players. Clearly, i */
	/* Should roll over actions, not players! Note that the program translates the probabilities */
	/* into a "full" list of probabilities for use with payoffs/profprobs (working correctly now?) */

}
real matrix payGradWrapper(real matrix p,
						 real scalar i,
						 transmorphic Z)
{
	real matrix A, P, actkey, actkey_foc, maxact_foc
	A=*Z[1]
	P=*Z[2]
	actkey=*Z[3]
	actkey_foc=*Z[4]
	maxact_foc=*Z[5]
	return(payGrad(p,A,P,actkey,actkey_foc,maxact_foc,i))
	
	/* Wraps paygrad for use with intsolver package */
}
real matrix payJac(real matrix p,
				   real matrix A,
				   real matrix P,
				   real matrix actkey,
				   real matrix actkey_foc,
				   real matrix maxact_foc,
				   real scalar i, real scalar j)
{
	real scalar playeri,playerj,pactnoi,pactnoj,pmi,pmj,pmi0,pmj0,k,R
	real matrix plistmod, problist, part1, part2, Klist, potheri, potherj, zeros

	playeri=actkey_foc[i,1]
	playerj=actkey_foc[j,1]	
	
	if (playeri==playerj) return(J(rows(p),1,0))

	problist=J(rows(p),0,.)

	R=uniqrows(actkey[,1])
	for (k=1;k<=rows(R);k++) {
		part1=select(p',actkey_foc[,1]:==J(rows(actkey_foc),1,R[k]))'
		part2=1:-rowsum(part1)
		problist=problist,part1,part2
		}

	pactnoi=select(maxact_foc[,2],maxact_foc[,1]:==playeri)		/* Select the "minus one" action for first player */
	pactnoj=select(maxact_foc[,2],maxact_foc[,1]:==playerj)		/* select the "minus one" action for secnd player */
		
	pmi=mm_which(rowsum(actkey:==(playeri,actkey_foc[i,2])):==2)
	pmj=mm_which(rowsum(actkey:==(playerj,actkey_foc[j,2])):==2)
	pmi0=mm_which(rowsum(actkey:==(playeri,pactnoi)):==2)	
	pmj0=mm_which(rowsum(actkey:==(playerj,pactnoj)):==2)

	potheri=mm_which((actkey[,1]:==playeri):*					/* For each of the two players, find        */
				    (actkey[,2]:!=actkey_foc[i,2]):*			/* actions that are NOT the selected one or */
					 (actkey[,2]:!=pactnoi))					/* the "minus one" action */
	potherj=mm_which((actkey[,1]:==playerj):*
				    (actkey[,2]:!=actkey_foc[j,2]):*
					 (actkey[,2]:!=pactnoj))

	plistmod=problist
	plistmod[,(pmi,pmj)]=J(rows(plistmod),2,1)
	plistmod[,(pmi0,pmj0)]=J(rows(plistmod),2,-1)

	if (cols(potheri)&cols(potherj)>0)	{
		zeros=rowshape(potheri,1),rowshape(potherj,1)
		plistmod[,zeros]=J(rows(plistmod),cols(zeros),0)
	}
	else if (cols(potheri)>0 & cols(potherj)==0) plistmod[,potheri]=J(rows(plistmod),rows(potheri),0)	/*Since the off-actions are listed as rowvectors, we need their length */
	else if (cols(potherj)>0 & cols(potheri)==0) plistmod[,potherj]=J(rows(plistmod),rows(potherj),0)   /*Likewise */

	Klist=J(1,cols(A),.)
	for (k=1;k<=cols(A);k++) Klist[k]=rows(uniqrows(A[,k]))	
	return(payoffs(A,P,Klist,plistmod)[,playeri])
	
	/* This function works as the above. The first part translates a vector of probabilities */
	/* into a full vector by adding in the Nth action for each player as "all other a's - 1  */
	/* It then puts ones and negative ones in the right places to get the derivatives. Note  */
	/* that whenever the player is the same (as can happen when there are more than two      */
	/* actions per player, the jacobian is zero                                              */
}
real matrix payJacWrapper(real matrix p,
						 real scalar i,
						 real scalar j,
						 transmorphic Z)
{
	real matrix A, P, actkey, actkey_foc, maxact_foc
	A=*Z[1]
	P=*Z[2]
	actkey=*Z[3]
	actkey_foc=*Z[4]
	maxact_foc=*Z[5]
	return(payJac(p,A,P,actkey,actkey_foc,maxact_foc,i,j))
	
	/* Wrapper for the above function to work with the intsolver */
}

real vector uniDevPayoffs(real vector p,real matrix profiles) 
{
	return(mm_which(rowsum((profiles:-p):!=0):==1))

	/* Utility tool: takes an action profile and finds
	   the position of the unilateral deviations */
}
real scalar isPureNash(real scalar j,real matrix profiles,real matrix payoffs)
{
	real matrix profile,payoff,Devs,prohat,
				payhat,ind,check
				
	profile=profiles[j,]
	payoff=payoffs[j,]
	Devs=uniDevPayoffs(profile,profiles)
	prohat=profiles[Devs,]
	payhat=payoffs[Devs,]
	ind=(profile:-prohat):!=0
	check=ind:*(payoff:-payhat)
	return(1:-any(check:<0))
	
	/* Analytic tool: takes a particular strategy profile # j
	   and asks whether or not it is a Nash equilbrium; returns 0 if not
	   1 if it is */
}
void psNashEqs(struct gameDescription G)
{
	real scalar i
	real matrix PS,profiles,payoffs,neqs

	profiles=G.redAct
	payoffs=G.redPay
	PS=J(0,1,.)
	for (i=1;i<=rows(profiles);i++) {
		if (isPureNash(i,profiles,payoffs)) PS=PS \ i
	}
	G.redNEqRows=PS
	if (rows(PS)>0) {
		neqs=J(rows(PS),sum(G.redActDesc),.)
		for (i=1;i<=rows(PS);i++) {
			neqs[i,]=placeNEqs(profiles[PS[i],],G.redActKey,G.redActKeyMax)
		}
	G.redPsNeqs=neqs
	}
	/* Analytic tool: takes all strategy profiles and tests whether or not it is
	   a pure-strategy Nash equilibrium. */
}
void iterDomDel(real matrix A,
				  real matrix P,
				  transmorphic An,
				  transmorphic Pn,
				  transmorphic domhist)
{
	real scalar i,j,change
	real matrix AnPn,Aold,res

	An=A
	Pn=P
	domhist=J(0,3,.)
	
	do {
		Aold=An
			for (i=1;i<=cols(A);i++) {
			res=domTest(An,Pn,i)
			domhist=domhist \ (J(rows(res),1,i),res)
				for (j=1;j<=rows(res);j++) {
					AnPn=An,Pn
					AnPn=select(AnPn,AnPn[,i]:!=res[j,2])		
					An=AnPn[,1::cols(An)]
					Pn=AnPn[,cols(Pn)+1::2*cols(Pn)]
				}
			}
	} while (An!=Aold)
	/* Analytic tool: first step in complete solution algorithm. 
	   Iterates through players, tests for dominated strategies, 
	   and submits modified payoff matrices/action profiles with
	   dominated strategies removed. "domhist" contains the dominance 
	   history */
} 
real matrix domTest(real matrix profiles,real matrix payoffs,player)
{
	real matrix pros,acts,pays,pairs,dompair,ptest,pay1,pay2
	real scalar i,j

	pros=profiles[,player]
	acts=uniqrows(pros)
	
	if (rows(acts)<=1) return(J(0,2,.))	/* Only one strategy - out! */
	pays=payoffs[,player]
	pairs=J(0,2,.)
	for (i=1;i <length(acts);i++) {
	for (j=1;j<=length(acts);j++) {
		if(j>i) pairs=pairs \(acts[i],acts[j])
								}
								} /* exhausts pairs of actions */
	
	dompair=J(0,2,.)

	do {
		ptest=pairs[1,]      /* pops top of list */
		pairs=listEdit(pairs,1)
		pay1=select(pays,pros:==ptest[1,1])
		pay2=select(pays,pros:==ptest[1,2])	/* Problem is that there is sometimes */
		if (all(pay1:>pay2)) {				/* Nothing left in the list */
			dompair=dompair \ ptest
		if (rows(pairs)>0)	pairs=select(pairs,pairs[,2]:!=ptest[1,2])	/* Problem here */
							 }
		else if (all(pay2:>pay1)) {
			dompair=dompair \ (ptest[1,2],ptest[1,1])
		if (rows(pairs)>0)	pairs=select(pairs,pairs[,1]:!=ptest[1,1])
								  }
	   } while (rows(pairs)>0)
	  return(dompair)
	  
	  /* Analyic tool: returns a list - of players and actions - that are 
	     _dominated_ strategies. More useful than dominance. 
		 The idea is to use this to 
		 pare down the things that have to be considered */ /*Output is <player><this doms><this>*/
}
transmorphic listEdit(transmorphic list, real scalar edit)
{
	real scalar n
	n=rows(list)
	if (edit>n | edit<1) return(list)
	else if (edit==1 & n>1) return(list[2::n,])
	else if (edit==n & n>1) return(list[1::n-1,])
	else if (n>1) return((list[(1..edit-1,edit+1..n),]))
	else if (n==1 & edit==1) return(J(0,0,.))
	else return(list)
	
	/* Utility tool: takes a list of objects and removes the edit-th
	   item from this list if possible. Returns an empty list if the 
	   first item of a one item list is removed */
}
real matrix simplexDraw(real scalar n, real scalar draws)
{
	real matrix X
	
	X=rgamma(draws,n,1,1)
	return(X:/rowsum(X))
	
	/* Utility tool: takes draws from the unit simplex - not really needed for this! More
	   useful for the "Heuristic" part of our solver */
}
real matrix dg_restacts(real matrix A,real scalar player)
{
	real scalar st,i
	real matrix set,Z,newadd,stnew,stold
	transmorphic info
	
	st=rows(uniqrows(A[,player]))	
	Z=J(0,st,.)
	
	for (i=1;i<=st;i++) {
	info=mm_subsetsetup(st,i)
	while ((set=mm_subset(info)) != J(0,1,.)) {
		set=set'
		newadd=(set,J(1,st-cols(set),.))
		Z=Z\newadd		
						}
						}
						
/*	stnew=uniqrows(Z[,1])
	stold=uniqrows(A[,player])
	
	for (i=rows(stnew);i>=1;i--) _editvalue(Z,stnew[i],stold[i]) */
	return(Z)					
}

real matrix rowcat(real matrix A,real matrix B)
{
	real scalar i,j
	real matrix C
	C=J(0,cols(A)+cols(B),.)
	for (i=1;i<=rows(A);i++) {
	for (j=1;j<=rows(B);j++) {	
		C=C\(A[i,],B[j,])
							}
							}
	/* Catenates two matrices row-by-row - useful for 
	   calculating "all possible restricted games" for 
	   sets of two players */
	return(C)
}

real matrix dg_allrest(real matrix A,|transmorphic key)
{
	real scalar i
	real matrix A1,A2
	A1=dg_restacts(A,1)
	if (args()==2) {
		key=J(1,cols(A1),1)
	}
	
	for (i=2;i<=cols(A);i++) {
		A2=dg_restacts(A,i)
		A1=rowcat(A1,A2)
	if (args()==2) key=key,J(1,cols(A2),i)	
							 }
	return(A1)
}

/* How about using the above to figure out which are subgames with an 
   action fixed at a particular value? */
real matrix createSubGameList(real matrix A, transmorphic key)
{
	real scalar i
	real matrix Ap,B,Ind,Test1
	Ap=dg_allrest(A,key)
	
	B=J(0,cols(Ap),.)
	for (i=1;i<=cols(Ap);i++) B=B\select(Ap,rownonmissing(Ap):==i)
	
	B=select(B,rowsum(B:!=.):!=cols(A))
	
	Ind=J(rows(B),cols(A),.)
	for (i=1;i<=cols(A);i++) {
		Test1=select(B',key':==i)'
		Ind[,i]=rownonmissing(Test1)
	}
	
	Ind=rowsum(Ind:>1):>1

	return(select(B,Ind))
	
	/* Utility function: returns lists of actions for 
	   defining subgames. Only profiles where at least two  
	   players have more than one action are included */
	
}
		
void dg_subgame(real matrix A,
			    real matrix P,
				real vector Actrow, 
				real matrix key, 
				transmorphic As, 
				transmorphic Ps, 
				| string dropSuperfluous)
{
	real scalar i
	real matrix selector, AsPs, colPicker

	selector=J(rows(A),0,0)
	for (i=1;i<=cols(key);i++) {
			selector=selector,rowsum(A[,key[i]]:==Actrow[i])
							}
	selector=rowsum(selector):==cols(A)
	AsPs=select((A,P),selector)
	As=AsPs[,1::cols(A)]
	Ps=AsPs[,cols(A)+1::2*cols(A)]
	
	if (args()==7) {
		colPicker = J(1,0,.)
		for (i=1;i<=cols(As);i++) {
			selector=mm_nunique(As[,i])
				if (selector>1) colPicker=colPicker,i
		}
		As=As[,colPicker]
		Ps=Ps[,colPicker]
	}
	
	/* Takes an action list and a corresponding key - as created by the dg_fixedacts 
	   routine, and returns a subgame. The optional argument, allows one to get rid
	   of rows which don't actually vary, so it is really a formal subgame.           */
}		
real matrix outcomeProbsI(real matrix K,real matrix pI, real scalar digits)
{
	real scalar i,j,count
	real matrix pPrime, KMult, payMat, payMatp, add1
		
	count=1
	for (i=1;i<=cols(K);i++) {
		pPrime=int_transpose(pI[,count::count+2*K[i]-1])
		if (i==1) {
				payMat=pPrime
		}
		else if (i==cols(K)) {
				KMult=ceil(exp(rowsum(ln(K[1::cols(K)-1]))))
				pPrime=J(KMult,1,1)#pPrime
				payMat=payMat#J(K[i],1,1)
				payMatp=J(rows(payMat),cols(payMat),.)
				for (j=1;j<=rows(payMat);j++) {
					add1=int_mult(colshape(payMat[j,],2),colshape(pPrime[j,],2),digits)
					payMatp[j,]=rowshape(add1,1)
				}
				payMat=payMatp
		}
		else {
			KMult=ceil(exp(rowsum(ln(K[1::i-1]))))
			pPrime=J(KMult,1,1)#pPrime
			payMat=payMat#J(K[i],1,1)
			payMatp=J(rows(payMat),cols(payMat),.)	
			for (j=1;j<=rows(payMat);j++) {
				add1=int_mult(colshape(payMat[j,],2),colshape(pPrime[j,],2),digits)
				payMatp[j,]=rowshape(add1,1)
			}
				payMat=payMatp
		
		
					}
		count=count+2*K[i]
	}	
	return(payMat)
/* Returns probabilities of actions */
/* Each row is a probability of corresponding action profile */
/* Columns count multiple probability vectors */
}
real matrix payoffsI(real matrix A, real matrix P, real matrix actkey, real matrix problistI, digits)
{
	real scalar k,j
	real matrix probs,Payoffs,Klist,PayoffsPrime,probsPrime,Total1,Total2
	
	Klist=J(1,cols(A),.)
	for (k=1;k<=cols(A);k++) Klist[k]=rows(uniqrows(A[,k]))	/* same as dg_actcount */

	probs=outcomeProbsI(Klist,problistI,digits)	/* A list of probabilities of each outcome (intervals) */
	Payoffs=P#J(1,2,1)
	
	Total1=J(rows(probs),0,.)
	
	for (j=1;j<=cols(probs);j=j+2) {
		for (k=1;k<=cols(Payoffs);k=k+2) {
			Total1=Total1,int_mult(Payoffs[,k::k+1],probs[,j::j+1],digits)
		}
	}

	Total1=int_transpose(Total1)
	Total2=J(rows(Total1),2,0)
	for (j=1;j<=cols(Total1);j=j+2) {
		Total2=int_add(Total1[,j::j+1],Total2,digits)
	}
	
	return(rowshape(Total2,rows(problistI)))

	/* Utility tool: Takes a vector (really many vectors) of probabilities and then computes
	   the expected payoffs. Note that there might be some advantage to doing this so that
	   we don't have to do this every time! */
}
real matrix payGradI(real matrix pI, 
					 real matrix A, 
					 real matrix P,
					 real matrix actkey,
					 real matrix actkey_foc,
					 real matrix maxact_foc,
					 real scalar i,
					 real scalar digits)
{
	real scalar player,pactno,pm1,pm0,j,k
	real matrix plistmod, problist, part1, part2, pother

	player=actkey_foc[i,1]

	pactno=select(maxact_foc[,2],maxact_foc[,1]:==player)
	pm0=mm_which(rowsum(actkey#J(2,1,1):==(player,actkey_foc[i,2])):==2)
	pm1=mm_which(rowsum(actkey#J(2,1,1):==(player,pactno)):==2)
	
		pother=mm_which((actkey[,1]#J(2,1,1):==player):*
				    (actkey[,2]#J(2,1,1):!=actkey_foc[i,2]):*
					 (actkey[,2]#J(2,1,1):!=pactno))
	
	problist=J(rows(pI),0,.)

	j=uniqrows(actkey[,1])
	for (k=1;k<=rows(j);k++) {
		part1=select(pI',actkey_foc[,1]#J(2,1,1):==J(2*rows(actkey_foc),1,j[k]))'
		part2=int_sub(J(rows(part1),2,1),int_rowadd(part1),digits)
		problist=problist,part1,part2
	}

	plistmod=problist
	
	plistmod[,pm0]=J(rows(plistmod),2,1)
	plistmod[,pm1]=J(rows(plistmod),2,-1)
	
	if (rows(pother)>0) plistmod[,pother]=J(rows(plistmod),cols(pother'),0)
	
    return(payoffsI(A,P,actkey,plistmod,digits)[,2*player-1::2*player])
	
	/* The tricky thing here is that j should refer to an equation number! Not an action */
	/* This is producing an error for anything greater than the number of players. Clearly, i */
	/* Should roll over actions, not players! */
	
}
real matrix payGradIWrapper(real matrix pI,
						 real scalar i,
						 real scalar digits,
						 transmorphic Z)
{
	real matrix A, P, actkey, actkey_foc, maxact_foc
	A=*Z[1]
	P=*Z[2]
	actkey=*Z[3]
	actkey_foc=*Z[4]
	maxact_foc=*Z[5]
	return(payGradI(pI,A,P,actkey,actkey_foc,maxact_foc,i,digits))
}
real matrix payJacI(real matrix pI,
				    real matrix A,
				    real matrix P,
				    real matrix actkey,
				    real matrix actkey_foc,
				    real matrix maxact_foc,
				    real scalar i, real scalar j,
				    real scalar digits)
{
	real scalar playeri,playerj,pactnoi,pactnoj,pmi,pmj,pmi0,pmj0,k,R
	real matrix plistmod, problist, part1, part2, potheri, potherj

	playeri=actkey_foc[i,1]
	playerj=actkey_foc[j,1]
	
	if (playeri==playerj) return(J(rows(pI),2,0))
	
	problist=J(rows(pI),0,.)

	R=uniqrows(actkey[,1])
	for (k=1;k<=rows(R);k++) {
		part1=select(pI',actkey_foc[,1]#J(2,1,1):==J(2*rows(actkey_foc),1,R[k]))'
		part2=int_sub(J(rows(part1),2,1),int_rowadd(part1))
		problist=problist,part1,part2
		}

	pactnoi=select(maxact_foc[,2],maxact_foc[,1]:==playeri)	
	pactnoj=select(maxact_foc[,2],maxact_foc[,1]:==playerj)
		
	pmi=mm_which(rowsum(actkey#J(2,1,1):==(playeri,actkey_foc[i,2])):==2)
	pmj=mm_which(rowsum(actkey#J(2,1,1):==(playerj,actkey_foc[j,2])):==2)
	pmi0=mm_which(rowsum(actkey#J(2,1,1):==(playeri,pactnoi)):==2)	
	pmj0=mm_which(rowsum(actkey#J(2,1,1):==(playerj,pactnoj)):==2)
	
	potheri=mm_which((actkey[,1]#J(2,1,1):==playeri):*
			    (actkey[,2]#J(2,1,1):!=actkey_foc[i,2]):*
				 (actkey[,2]#J(2,1,1):!=pactnoi))	
	
	potherj=mm_which((actkey[,1]#J(2,1,1):==playerj):*
		    (actkey[,2]#J(2,1,1):!=actkey_foc[j,2]):*
			 (actkey[,2]#J(2,1,1):!=pactnoj))	
	
	plistmod=problist
	plistmod[,(pmi\pmj)]=J(rows(plistmod),4,1)
	plistmod[,(pmi0\pmj0)]=J(rows(plistmod),4,-1)	

	if (rows((potheri \ potherj))>0) plistmod[,(potheri\potherj)]=J(rows(plistmod),rows((potheri\potherj)),0)

	return(payoffsI(A,P,actkey,plistmod,digits)[,2*playeri-1::2*playeri])
	
	/* This function works as the above. The first part translates a vector of probabilities */
	/* into a full vector by adding in the Nth action for each player as "all other a's - 1  */
	/* It then puts ones and negative ones in the right places to get the derivatives */
}
real matrix payJacIWrapper(real matrix pI,
						 real scalar i,
						 real scalar j,
						 real scalar digits,
						 transmorphic Z)
{
	real matrix A, P, actkey, actkey_foc, maxact_foc
	A=*Z[1]
	P=*Z[2]
	actkey=*Z[3]
	actkey_foc=*Z[4]
	maxact_foc=*Z[5]
	return(payJacI(pI,A,P,actkey,actkey_foc,maxact_foc,i,j,digits))
	/* Wrapper for the above so it works with intsolver */
}
real rowvector placeSolProbs(real rowvector sets, 
							 real rowvector key, 
							 real matrix p)
{
	real scalar k, z
	real matrix mp,pa,posma,psolna,posoa,psoln
	real rowvector pvec
	
	mp=panelsetup(key',1)		/* One row for each player */
	pvec=J(1,cols(sets),0)		/* placeholder for finished vector */
	psoln=p						/* initialize psoln to the given p */

	for (k=1;k<=rows(mp);k++) {	/* loop over players */
		pa=panelsubmatrix(sets',k,mp)	/* positions in pvec of player's actions */
		pa=select(pa,rownonmissing(pa):==1)	/* nonmissing actions in subgame */
		if (rows(pa)==1) {					/* If only one action, fill in */
			pvec[mp[k,1]+pa-1]=1			/* the position with a one */
		}
		else if (rows(pa)>1) {	/* if more than one action */
			posma=pa[rows(pa)]	/* identify the "minus one" action  */			
			posoa=pa[1::rows(pa)-1] /* the rest of the actions */
			psolna=psoln[1::rows(posoa)]	/* Everything in psoln up to that point */
	/*		if (rows(psoln)>rows(psolna)) {
				psoln=psoln[rows(psolna)+1::rows(psoln)]
			}	*/
			for (z=1;z<=rows(posoa);z++) {
				pvec[mp[k,1]+posoa[z]-1]=psolna[z]
			}
			pvec[mp[k,1]+posma-1]=1-sum(psolna)

			if ((k<rows(mp) & cols(psoln)>1) & psolna!=psoln) { /* not at end, and psoln still there */
				psoln=psoln[rows(posoa)+1::cols(psoln)]
			}
		
		}
	}
	return(pvec)

	/* Utility that takes the results of a solved system and translates */
	/* it back into the form that works best with the solver            */
}

real matrix placeNEqs(real matrix neq, real matrix actKey, actKeyMax)
{
	real scalar i, j
	real matrix probs, list
	
	list=uniqrows(actKey[,1])
	
	probs=J(1,rows(actKey),0)
	j=1

	for (i=1;i<=rows(actKey);i++) {
			if (actKey[i,]==(list[j],neq[j])) probs[i]=1
			if (actKey[i,]==actKeyMax[j,]) j++
	}
	return(probs)
}
void domProcess(struct gameDescription Game) 
{
	real matrix Ahat,A,P,domhist,actKeyRed, 
		actKeyFocs, actKeyMax,
		dumRow, labs, K
	real scalar i,j
	
	iterDomDel(Game.act,Game.pay,Ahat=.,P=.,domhist=.)			/* Start by eliminating dominated strategies */
	Game.domHist=domhist
	if (rows(Ahat)==1) {
		Game.psNeqs=placeNEqs(Ahat,Game.actKey,
				Game.actKeyMax)
		Game.solved=1
		Game.domSolved=1
	}

	if (rows(Ahat)<rows(Game.act) & rows(Ahat)>1) {
		A=Ahat
		for (i=1;i<=cols(Ahat);i++) {
			if (uniqrows(Ahat[,i])!=(1::rows(uniqrows(Ahat[,i])))) {
				dumRow=A[,i]:+.1111
				labs=uniqrows(dumRow)
				for (j=1;j<=rows(labs);j++) _editvalue(dumRow,labs[j],j)
				A[,i]=dumRow
			}
		}
		K=actCount(A)
	
		actKeyRed=actKeyCreate(A)
		actKeyConvert(actKeyRed,actKeyFocs=.,actKeyMax=.)	
		Game.redAct=A
		Game.redPay=P
		Game.redActKey=actKeyRed
		Game.redActKeyFocs=actKeyFocs
		Game.redActKeyMax=actKeyMax
		Game.redActDesc=actCount(A)
		Game.reduced=1
	}	
	else {
		Game.redAct=Game.act
		Game.redPay=Game.pay
		Game.redActKey=Game.actKey
		Game.redActKeyFocs=Game.actKeyFocs
		Game.redActKeyMax=Game.actKeyMax
		Game.redActDesc=Game.actDesc
		Game.reduced=0
	}
}
void mixedStratSolve(struct gameDescription G)
{
	real matrix Sets, mixedEqs, As, Ps, dh, key, Solns,
			Cands, Cands2, CandsInd, Focs, K, actKey, actKeyFoc,
			actKeyMax, draws, drawComp, players
	transmorphic junk, crap, i, GameSolver, Z, z 
			
	Sets=createSubGameList(G.redAct,key=.)
	
	/* Create noise if noisy option selected */
	
	if (G.noise==1) {
		printf("Subgames:%9.0f\n", rows(Sets));displayflush()
	}

	mixedEqs=J(0,cols(Sets),.)

	/* Loop for mixed strategies */

	for (i=1;i<=rows(Sets);i++) {
		dg_subgame(G.redAct,G.redPay,Sets[i,],key,As=.,Ps=.,"junk")	/* Create subgames        */
		iterDomDel(As,Ps,junk=.,crap=.,dh=.)
		
		if (rows(dh)==0) {

			actKey=actKeyCreate(As)
			actKeyConvert(actKey,actKeyFoc=.,actKeyMax=.)
			
			GameSolver=int_prob_init()
			int_prob_f_Iform(GameSolver,&payGradIWrapper())
			int_prob_jac_Iform(GameSolver,&payJacIWrapper())
			int_prob_f(GameSolver,&payGradWrapper())
			int_prob_jac(GameSolver,&payJacWrapper())			/* Here is where options must be fiddled with */
	
			int_prob_mbwidth(GameSolver,G.mbwidth)
			int_prob_maxit(GameSolver,G.maxit)
			int_prob_digits(GameSolver,G.digits)
			int_prob_tol(GameSolver,G.tol)
			int_prob_tolsols(GameSolver,G.tolsols)	/* Options for controlling solution process */

			Focs=rows(actKeyFoc)								/* Get argument count     */

			int_prob_ival(GameSolver,J(1,Focs,(0,1)))			/* Set up intervals       */
			int_prob_args(GameSolver,Focs)	

			Z=J(5,1,NULL)

			Z[1]=&As		
			Z[2]=&Ps
			Z[3]=&actKey
			Z[4]=&actKeyFoc
			Z[5]=&actKeyMax

			int_prob_addinfo(GameSolver,Z)

			if (G.newton==1) {
				int_prob_method(GameSolver,"newton")
				draws=J(G.initPts,0,.)
				players=uniqrows(actKeyFoc[,1])
			
				for (z=1;z<=rows(players);z++) {
					drawComp=simplexDraw(colsum(actKeyFoc[,1]:==players[z])+1,G.initPts)
					drawComp=drawComp[,1::cols(drawComp)-1]
					draws=draws,drawComp
				}

				int_prob_init_pts(GameSolver,draws)

				int_newton_iter(GameSolver)

				Solns=int_prob_pts_vals(GameSolver)
			}
			else {
				int_solve(GameSolver)							/* Solve the problem      */
				int_newton_iter(GameSolver)								/* Iterate solutions      */
				Solns=int_prob_pts_vals(GameSolver)
			}

			if (rows(Solns)>0) {									/* Arrange solutions in readable form */
				Cands=J(0,cols(Sets),.)
				for (z=1;z<=rows(Solns);z++) {
					Cands=Cands \ placeSolProbs(Sets[i,],key,Solns[z,])				
				}

				CandsInd=lyapFun(G.redAct,G.redPay,Cands,G.redActDesc,G.redActKey)
				
				CandsInd=rowsum((CandsInd:<1e-10):*(Cands:>=0))		/*Shouldn't this be user-defined? */
				if (CandsInd==cols(Cands)) mixedEqs=mixedEqs \ Cands
			}
		}					/* Completes outer if-block */
		if (G.noise==1) {
			if (i/50==floor(i/50)) {
				printf(" %9.0f\n",i);displayflush()
			}
			else {
				printf(".");displayflush()	/*Make noise*/
			}
		}
	}					/* Completes the for loop checking for mixedEqs */

	G.redMixedEqs=mixedEqs
}
void assembleEqs(struct gameDescription Game)
{
	real scalar i,j
	real matrix Stack,Ak,ind,which,places,Neqs
	
	Ak=Game.actKey'

	if (rows(Game.redPsNeqs)!=0 & rows(Game.redMixedEqs)!=0) {
		Stack=Game.redPsNeqs \ Game.redMixedEqs
	}
	else if (rows(Game.redPsNeqs)!=0 & rows(Game.redMixedEqs)==0) {
		Stack=Game.redPsNeqs
	}
	else if (rows(Game.redPsNeqs)==0 & Game.pureonly==0) {
		Stack=Game.redMixedEqs
	}
	else Stack=0

	ind=Game.domHist[,(1,3)]'

	/* Note if we are here without equilibria, cols(ind)=0 and the loop doesn't start */
	
	which=J(1,cols(Ak),1)
	for (i=1;i<=cols(ind);i++) {
		for (j=1;j<=cols(Ak);j++) {
			if (colsum(ind[,i]:==Ak[,j])==2) which[j]=0
		}
	}

	places=mm_which(which)

	if (Stack!=0) {
		Neqs=J(rows(Stack),cols(Ak),0)
		Neqs[,places]=Stack
	}
	else Neqs=J(1,cols(which),0)

	if (rows(Game.redPsNeqs)!=0 & rows(Game.redMixedEqs)!=0) {

		Game.psNeqs=Neqs[1::rows(Game.redPsNeqs),]
		Game.mixedEqs=Neqs[rows(Game.redPsNeqs)+1::rows(Neqs),]
	}
	else if (rows(Game.redPsNeqs)!=0 & rows(Game.redMixedEqs)==0) {
		Game.psNeqs=Neqs
	}
	else {
		Game.mixedEqs=Neqs
	}
}
void discreteGameSolver(struct gameDescription Game) {

	/* Preprocess the game to get rationlizable strategies and payoffs */
	real matrix Neqs
	
	domProcess(Game)
	
	/* Move to the next step if game not dominance-solveable */
	/* The "main" solution block */
	
	if (Game.solved!=1) {
		Neqs=psNashEqs(Game)
		if (rows(Neqs)>0) {
			Game.redPsNeqs=placeNEqs(Neqs,Game.redActKey,Game.redActKeyMax)
		}
		if (Game.pureonly==0) mixedStratSolve(Game) 
	}
}
/* Called by solver */
real matrix dagSolverN(real matrix AA,real matrix PP,real matrix id,
	real scalar tol,real scalar digits,real scalar mbwidth, real scalar coltol,
	real scalar mnits, string scalar method, string scalar noise, 
	string scalar pureonly, real vector K,
	transmorphic Pays)
{
	real matrix gs,Ap,Pp,Sols,EqMat,keys,maxNo,actCount,
		actNo,keysp,eqsToAdd,payToAdd
	struct gameDescription scalar G	
	real scalar i,maxCols,check,maxVars,z,zs,nondegen
	transmorphic EQs
	
	EQs=asarray_create("real",2)	/* Group, equilibrium, rows */

	gs=panelsetup(id,1)

	maxVars=0
	for (i=1;i<=rows(gs);i++) {
		Ap=panelsubmatrix(AA,i,gs)'
		Pp=panelsubmatrix(PP,i,gs)'
		G=gameInit(Ap,Pp)
		gameSolutionDigits(G,digits)
		gameSolutionMbwidth(G,mbwidth)
		gameSolutionTol(G,tol)
		gameSolutionTolSols(G,coltol)
		gameSolutionMaxit(G,mnits)
		if (method=="newton") gameSolutionMethod(G,"newton",mbwidth)
		if (noise=="noisy") gameSolutionNoise(G,noise)
		if (pureonly=="pureonly") gamePureOnly(G,"pureonly") 
		discreteGameSolver(G)
		if (gameDomSolved(G)==0) assembleEqs(G)
		Sols=gameSolutionsReturn(G)
		Pays=payoffs(Ap,Pp,K,Sols)
		
		nondegen=sum(rowsum(Sols):>0)
		
		check=cols(Sols)*rows(Sols)
		if (check>maxVars) maxVars=check
		asarray(EQs,(i,1),Sols)
		asarray(EQs,(i,2),Pays)
		
		
		if (noise=="noisy") printf("\n Game Solved. Equilibria: %9.0f\n", nondegen)
	}

	/* Games Should be solved at this point - next step is simply to arrange things so they can be returned */
	/* Unpack solutions */
	
	EqMat=J(rows(id),maxVars,.)
	Pays=J(rows(id),maxVars/cols(Sols),.)	/* Just reuse this since we can */

	for (i=1;i<=rows(gs);i++) {
		eqsToAdd=rowshape(asarray(EQs,(i,1)),1)
		payToAdd=asarray(EQs,(i,2))'
		Pays[gs[i,1]::gs[i,2],1::cols(payToAdd)]=payToAdd
		EqMat[gs[i,2],1::cols(eqsToAdd)]=eqsToAdd
	}
	return(EqMat)
}	
real matrix outcomeProbs(real matrix K,real matrix p)
{
	real scalar i,count
	real matrix pPrime, KMult,payMat

	count=1
	for (i=1;i<=cols(K);i++) {
		pPrime=p[,count::count+K[i]-1]'
		if (i==1) {
				payMat=pPrime
		}
		else if (i==cols(K)) {
				KMult=round(exp(rowsum(ln(K[1::cols(K)-1]))))
				pPrime=J(KMult,1,1)#pPrime
				payMat=payMat#J(K[i],1,1)
				payMat=payMat:*pPrime
		}
		else {
			KMult=round(exp(rowsum(ln(K[1::i-1]))))
			pPrime=J(KMult,1,1)#pPrime
			payMat=payMat#J(K[i],1,1)
			payMat=payMat:*pPrime
		}
		count=count+K[i]		/* Position in the action list */
	}	
	return(payMat)
/* Returns probabilities of actions */
/* Each row is a probability of corresponding action profile */
/* Columns count multiple probability vectors */
}
real matrix lyapFun(real matrix A, real matrix P,
				        real matrix p, real matrix K,
						real matrix actkey)
{						
	real matrix Pays,Check,CheckPay,chooser,newp,newpp
	real scalar i,j,actno

	Pays=payoffs(A,P,K,p)

	Check=J(rows(p),cols(p),0)
	actno=1
	
	for (i=1;i<=cols(K);i++) {
		chooser=actkey[,1]:!=i
		newp=chooser':*p
			
		for (j=actno;j<=actno+K[i]-1;j++) {
			newpp=newp
			newpp[,j]=J(rows(newpp),1,1)
			CheckPay=payoffs(A,P,K,newpp)[,i]
			Check[,j]=(CheckPay:-Pays[,i])
			Check[,j]=rowmax((Check[,j],J(rows(Check),1,0))):^2
		}
		actno=actno+K[i]
	}
	return(Check)
}
void gameLyapVals(struct gameDescription G)
{
	real matrix Eqs, A, P, p, K, actkey
	
	if (rows(G.psNeqs)==0 & rows(G.mixedEqs)!=0) Eqs=G.mixedEqs
	else if (rows(G.psNeqs)!=0 & rows(G.mixedEqs)==0) Eqs=G.psNeqs
	else if (rows(G.psNeqs)!=0 & rows(G.mixedEqs)!=0) Eqs= G.psNeqs \ G.mixedEqs
	else Eqs=-99
	
	if (Eqs!=-99)	{
		A=G.act
		P=G.pay
		p=Eqs
		K=actCount(A)
		actkey=G.actKey
		G.lyapVals=lyapFun(A,P,p,K,actkey)
	}
}
real matrix payoffsN(real matrix id, real matrix AA, real matrix PP, real matrix p)
{
	real matrix mp,pHold,Ap,Pp,pp,Kp
	real scalar i
	
	mp=panelsetup(id,1)
	pHold=J(rows(id),1,.)

	for (i=1;i<=rows(mp);i++) {
		Ap=panelsubmatrix(AA,i,mp)'
		Pp=panelsubmatrix(PP,i,mp)'
		pp=p[mp[i,2],]
		Kp=actCount(Ap)
		pHold[mp[i,1]::mp[i,2]]=payoffs(Ap,Pp,Kp,pp)'
	}
	return(pHold)
}
real matrix probReshape(real matrix id, real matrix acts, real matrix prob)
{
	real matrix mp,fo,pHold,places,pPos
	real scalar kc,i,counter
	
	mp=panelsetup(id,1)
	fo=panelsubmatrix(acts,1,mp)
	kc=max(fo)

	places=colshape(1::rows(id),rows(fo))

	pPos=mm_which(prob[,1]:!=.)

	pHold=J(rows(id),kc,.)
	counter=1

	for (i=1;i<=rows(fo);i++) {
		pHold[places[,i],1::fo[i]]=prob[pPos,counter::counter+fo[i]-1]
		counter=counter+fo[i]
	}	
	return(pHold)
}
mata mlib create ldagamesolve, dir(PERSONAL) replace
mata mlib add ldagamesolve *()
mata mlib index
end
