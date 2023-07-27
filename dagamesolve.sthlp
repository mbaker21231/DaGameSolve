{smcl}
{* *! version 1.0.0 15sep2014}{...}
{cmd:help dagamesolve}
{hline}

{title:dagamesolve}

{p2colset 5 19 21 2}{...}
{phang} Find all equilibria of N-player discrete action games.{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 14 2}
{cmd:dagamesolve} {varlist} {ifin}{cmd:,} 
{cmdab:group(}{varname}{cmd:)}  
{cmdab:pay:offs(}varlist{cmd:)}
{cmdab:eq:uilibria(}varlist{cmd:)}
[{opt fast}
 {opt random:points(#)}
 {opt pure:only}
 {opt noisy}
 {opt tol:erance(#)}
 {opt mb:width(#)}
 {opt col:tol(#)}
 {opt digit:s(#)}
 {opt mn:its(#)}]

{title:Description}

{pstd}{cmd:dagamesolve} solves N-player, discrete action games, meaning that in principal
{cmd:dagamesolve} can find all equilibria - mixed-strategy, pure-strategy, and pure-mixed strategy - of sequences of 
similar games - games that have the same number of players and actions, but differ in payoffs. The participants in a game are identified 
by the variable {cmdab:group(}{varname}{cmd:)}, where each players' action profiles and payoffs are collected sequentially in rows.
Strategy profiles are passed to {cmd:dagamesolve} in a {varlist}, 
with corresponding payoffs indicated by {cmdab:pay:offs(}varlist{cmd:)}. 
{cmdab:eq:uilibria(}varlist{cmd:)} collects equilibrium strategy profiles for each game in {cmdab:group(}{varname}{cmd:)}. 
Before using {cmd:dagamesolve} the prospective user might wish to consult some
of the qualifying {help dagamesolve##rems:remarks}. 
{p_end}

{title:Options}

{pstd} Finding all Nash equilibria for a game requires finding mixed-strategy equilibria, which involves solving polynomial systems. Solving polynomial systems is not
a simple task, and {cmd:dagamesolve} solves systems using interval methods (Jaulin et al (2001)), which blends Interval methods, bisection, and Newton iteration.
All of the following options excepting {cmd:pureonly} 
are associated with numerical control over the three aspects of thegit  solution procedure.{p_end}

{pstd}{cmd:fast} skips the usual procedure by which {dagamesolve} finds mixed strategy and partially mixed-strategy equilibria. In particular, in the solution of nonlinear systems
required by mixed strategies, it skips the bisection step and proceeds directly from a randomly chosen point in the mixed-strategy simplex in an attempt to find a mixed-strategy equilibrium (see exmaples)
{p_end}

{pstd}{cmd:randompoints(#)} is used in conjunction with {cmd:fast} - it specifies the number of randomly selected points from which to perform Newton iteration (see examples) The default is {it:50}. 
{p_end}

{pstd}{cmd:pureonly} instructs {cmd:dagamesolve} to only look fore pure strategy equilibria. If {cmd:pureonly} is specified, {cmd:dagamesolve} makes no attempt to find any mixed strategy equilibria.{p_end]

{pstd}{cmd:noisy} generates output indicating how solutions are going - each time an attempt at a solution is made, a dot (.) is printed, and once solution of a game has concluded, the number of equilibria
are printed out (see examples).{p_end}

{pstd}{cmd:width(#)} is the minimum interval size used to describe a box for bisection. The default size is {it:10e-4}. 
{p_end}

{pstd}{cmd:tol(#)} specifies the tolerance at which Newton iteration is to stop, summed over the number of iterations specified by random. The default is {it:10e-4}. 
{p_end}

{pstd}{cmd:digits(#)} is used to control floating-point arithmetic and what numbers can be considered the same. The default is {it:10e-8}, which means that .051234331 and .051234334 would be considered
the same number by {cmd:dagamesolve}. This is used to eliminate double-counting equilibria that are essentially the same but have been arrived at from different starting points in Newton iteration.
{p_end}

{pstd}{cmd:mnits(#)} sets the maximum number of Newton iterations to perform. The default is {it:100}.
{p_end}

{title:Detailed Description}

{pstd}
To be processed by {cmd:dagamesolve}, games should be written in what might be called the
"list" form, in which each action variable denotes players' selection of pure strategies, and action variables
together collect all potential such selections across all players. Each action variable corresponds with a payoff variable, listing the payoffs
each player receives at the action. As an example, consider the following two-player, 
two-action game written in normal form, where player one chooses rows, player two chooses columns, and player one's payoffs are
listed first in the normal-form payoff matrix:{p_end}

        {txt}             strategy 1  strategy 2
        {txt}{hline 38}
        {txt}strategy 1  |   1,2    |    0,0.1 |
        {txt}strategy 2  |   0,0    |    3,1   | 
        {txt}{hline 38}

{pstd}The list form of the above game collects the actions into a matrix with entries{p_end}

    1, 1, 2, 2 
    1, 2, 1, 2

{pstd}payoffs are collected into a corresponding matrix, which in the example has entries{p_end}

    1, 0, 0, 3  
    2,.1, 0, 1

{pstd} One could program this game into stata using a brute force method as follows:

{phang}{cmd:. set obs 2}{p_end}
{phang}{cmd:. gen id=1}{p_end}
{phang}{cmd:. gen a1 = 1}{p_end}
{phang}{cmd:. gen a2 = 1}{p_end}
{phang}{cmd:. replace a2 = 2 in 2}{p_end}
{phang}{cmd:. gen a3 = 2}{p_end}
{phang}{cmd:. replace a3 = 1 in 2}{p_end}
{phang}{cmd:. gen a4 = 2}{p_end}

{pstd} Now that all the action profiles have been described, one describes
payoffs in an order corresponding with the action profiles:{p_end}

{phang}{cmd:. gen pay1 = 1}{p_end}
{phang}{cmd:. replace pay1 = 2 in 2}{p_end}
{phang}{cmd:. gen pay2 = 0}{p_end}
{phang}{cmd:. replace pay2 = .1 in 2}{p_end}
{phang}{cmd:. gen pay3 = 0}{p_end}
{phang}{cmd:. gen pay4 = 3}{p_end}
{phang}{cmd:. replace pay4 = 1 in 2}{p_end}
{phang}{cmd:. list}

        {c TLC}{hline 44}{c TRC}
{txt}        {c |}{res} id  a1  a2  a3  a4  pay1  pay2  pay3  pay4 {c |}
        {c LT}{hline 44}{c RT}
{txt}     1. {c |}{res}  1   1   1   2   2     1     0     0     3 {c |}
{txt}     2. {c |}{res}  1   1   2   1   2     2    .1     0     1 {c |}
        {c BLC}{hline 44}{c BRC}
{txt}

{pstd} The game can now be solved by passing action and payoff information to {cmd:dagamesolve} as follows:{p_end}

{phang}{cmd:. dagamesolve a1 a2 a3 a4, group(id) pay(pay1 pay2 pay3 pay4) eq(e)}{p_end}

{pstd} Equilibria are now collected in newly generated variables {cmd:e*}, which are numbered by equilibrium, player, 
and then probability that each strategy is played in equilibrium ({it:note - if the output below does not display correctly expand the width of the help window}):{p_end}

{phang}{cmd:. format e* %9.2f}{p_end}
{phang}{cmd:. list e*}{p_end}

        {c TLC}{hline 131}{c TRC}
{txt}        {c |}{res} e_rets_1 e_1_1_1 e_1_1_2 e_1_2_1 e_1_2_2 e_rets_1 e_2_1_1 e_2_1_2 e_2_2_1 e_2_2_2 e_rets_3 e_3_1_1 e_3_1_2 e_3_2_1 e_3_2_2 e_count{c |}
        {c LT}{hline 131}{c RT}
{txt}     1. {c |}{res}     1.00       .       .       .       .     3.00       .       .       .       .     0.75       .       .       .       .       .{c |}
{txt}     2. {c |}{res}     2.00    1.00    0.00    1.00    0.00     1.00    0.00    1.00    0.00    1.00     0.69    0.34    0.66    0.75    0.25    3.00{c |}
        {c BLC}{hline 131}{c BRC}
{txt}

{pstd} Equilibria are created as new variables collected in the last observation of the grouping variable ({cmd:id}
in the present case). The new entries are labled according to the equilibrium number, the player, and then the probability that
the player plays each possible strategy. The {cmd:e_rets_i} variable collects the expected returns to each player at the given equilibrium strategy profile, and
the very last variable, {cmd:e_count} contains a simple count of the total number of equilibria.{p_end} 

{pstd}Evidently, the game in the example has three
equilibria. The first two equilibria are pure-strategy equilibria, while the third equilibrium is a mixed-strategy equilibrium in which
player one plays strategy one with a probability of ~.34 and strategy two with probability ~.66, and player two plays strategy one
with probability ~.75 and strategy two with probability ~.25.{p_end}

{pstd}{help dagamestrats} automates the production of lists of actions like those above as new Stata variables, 
which can also be handy in characterizing the payoffs to games. This is a feature of the following examples.{p_end} 
	
{title:Examples}

{pstd}{it:Example one - solving a simple game}{p_end}

{pstd}Generate strategy profiles for a single 3-player game in which player one has two actions, player two has three actions, 
and player three has two actions: {p_end}

{phang}{cmd:. clear all}{p_end}
{phang}{cmd:. set obs 3}{p_end}
{phang}{cmd:. gen id=1}{p_end}
{phang}{cmd:. gen acts=2}{p_end}
{phang}{cmd:. replace acts=3 in 2}{p_end}
{phang}{cmd:. dagamestrats acts, group(id) gen(a)}{p_end}
{phang}{cmd:. list a*}{p_end}
    
        {c TLC}{hline 57}{c TRC}
{txt}        {c |}{res} acts  a1  a2  a3  a4  a5  a6  a7  a8  a9  a10  a11  a12 {c |}
        {c LT}{hline 57}{c RT}
{txt}     1. {c |}{res}    2   1   1   1   1   1   1   2   2   2    2    2    2 {c |}
{txt}     2. {c |}{res}    3   1   1   2   2   3   3   1   1   2    2    3    3 {c |}
{txt}     3. {c |}{res}    2   1   2   1   2   1   2   1   2   1    2    1    2 {c |}		  
        {c BLC}{hline 57}{c BRC}
{txt}

{pstd}Randomly generated standard normal payoffs for the above strategy profiles:{p_end} 

{phang}{cmd:. set seed 5150}{p_end}
{phang}{cmd:. forvalues i=1/12 {c -(}}{p_end}
{phang}2. {cmd:gen pay`i'=rnormal()}{p_end}
{phang}3. {cmd:{c )-}}{p_end}

{pstd}Compute all the equilibria of the game, using the {cmd:noisy} option to get 
some feedback on how the solution is progressing:{p_end}

{phang}{cmd:. dagamesolve a1-a12, group(id) pay(pay1-pay12) eq(eqs) noisy}{p_end}
{phang}{cmd:Subgames:        23}{p_end}
{phang}{cmd:.......................}{p_end}
{phang}{cmd:Game Solved. Equilibria:        1}{p_end}

{pstd}This game has a single equilibrium.{p_end}

{pstd}{it:Example two - solving a sequence of games}{p_end}

{pstd}One can also use {cmd:dagamestrats} and {cmd:dagamesolve} in the same way to create
sequences of similar games and solve them. Here we have three four-player games, where each
player has two strategies. Generating the pure strategy profiles: {p_end}

{phang}{cmd:. clear all}{p_end}
{phang}{cmd:. set obs 12}{p_end}
{phang}{cmd:. gen id=1}{p_end}
{phang}{cmd:. gen acts=2}{p_end}
{phang}{cmd:. replace id=2 in 5/8}{p_end}
{phang}{cmd:. replace id=3 in 9/12}{p_end}
{phang}{cmd:. dagamestrats acts, group(id) gen(profiles) }{p_end}

{pstd}Suppose one is interested 
in modelling an entry game, where any of the four players are firms deciding to enter the market or not. Suppose that action 1 denotes
staying out of the market, where action 2 denotes entry. Suppose further that firms' profits consist
 of a random constant that is normally distributed with a mean of 2 and a standard deviation
of one, and that profits are decreasing in the number of entrants besides the firm, so that profits are K-#(other entrants). A first step is to 
generate a count of the number of entrants based on action profiles:{p_end}

{phang}{cmd:. forvalues i=1/16 {c -(}}{p_end}
{phang}{txt:  2. }{cmd:bysort id: egen entrants`i'=total(profiles`i'==2)}{p_end}
{phang}{txt:  3. }{cmd:{c )-}}{p_end}

{pstd}The loop runs over 16 observations, as in this case there are 2^4=16 distinct action profiles for the game.
Generating payoffs for each firm given the parameterization:{p_end}

{phang}{cmd:. set seed 5150}{p_end}
{phang}{cmd:. gen K=rnormal(2,1)}{p_end}
{phang}{cmd:. forvalues i=1/16 {c -(}}{p_end}
{phang}{txt:  2. }{cmd:gen payoffs`i'=0}{p_end}
{phang}{txt:  3. }{cmd:quietly replace payoffs`i'=K-(entrants`i'-1) if profiles`i'==2}{p_end}
{phang}{txt:  4. }{cmd:{c )-}}{p_end}

{pstd}One has now created payoffs for three random entry games, with the desired payoffs. The payoffs and action profiles
are written in a format that is compatible with the command {com: dagamesolve}. Solving the games with the {cmd:noisy} 
option gives some feedback as solutions proceed: {p_end}

{phang}{cmd:. dagamesolve profiles*, group(id) pay(payoffs*) eq(eqs) noisy}{p_end}
{phang}{cmd:Subgames:        7}{p_end}
{phang}{cmd:.......}{p_end}
{phang}{cmd: Game Solved. Equilibria:         1}{p_end}
{phang}{cmd:Subgames:       33}{p_end}
{phang}{cmd:.................................}{p_end}
{phang}{cmd: Game Solved. Equilibria:         1}{p_end}
{phang}{cmd: }{p_end}
{phang}{cmd: Game Solved. Equilibria:         1}{p_end}

{pstd}The above output generated by the {cmd:noisy} option conveys a little bit of information about the underlying game. FOr example,
the first game, after elimination of dominated strategies, had to solve 7 remaining subgames, and once this was done, there was
1 equilibrium left. The second game pared down solution to 33 different subgames once dominated strategies were eliminated, yet
was still able to narrow down the resulting set to a single equilibrium. The last game it seems was completely dominance-solvable.{p_end}

{pstd}One way of viewing results is to look at the resulting entry rates of the firms (if we can indeed think about the first observation
in each group as corresponding to a consistent entity across the games). {p_end}

{phang}{cmd:. sum eqs_1_*_2}{p_end}


{txt}    Variable   {c |}  Obs       Mean    Std. dev.     Min       Max 
     {hline 10}{c +}{hline 48}
{txt}     eqs_1_1_2 {c |}{res}    3          1           0        1         1   
{txt}     eqs_1_2_2 {c |}{res}    3   .3333333    .5773503        0         1
{txt}     eqs_1_3_2 {c |}{res}    3   .3333333    .5773503        0         1
{txt}     eqs_1_4_2 {c |}{res}    3   .6666667    .5773503        0         1	  
{txt}

{pstd}It appears that across the sequence of the three games, the first firm always enters, the second and third firms enter only one of the three
markets, while the fourth firm enters two of the three markets.{p_end} 

{pstd}{it: Example three - solving a sequence of 100 two-player, four-action games}{p_end}

{phang}{cmd:. clear  all }{p_end}
{phang}{cmd:. mata: id=(1::100)#J(2,1,1) }{p_end}
{phang}{cmd:. getmata id } {p_end}
{phang}{cmd:. gen acts=4 }{p_end}
{phang}{cmd:. dagamestrats acts, group(id) gen(s) }{p_end}
{phang}{cmd:. scalar profiles=r(profiles)         }{p_end}
{phang}{cmd:. set seed 1000011001           }{p_end}
{phang}{cmd:. forvalues i=1/`=profiles' {c -(}}{p_end}
{phang}{txt:  2. }{cmd:gen pay`i'=runiform()}{p_end}
{phang}{txt:  3. }{cmd:{c )-}}{p_end}
{phang}{cmd:. dagamesolve s*, group(id) pay(pay*) eq(e) noisy}{p_end}

{pstd} {it:<output omitted>}{p_end}

{phang}{cmd:. tab e_count }{p_end}

{txt}   e_count {c |}{res}      Freq.     Percent     Cum.
{txt} {hline 10}{c +}{hline 35}
{txt} 1         {c |}{res}         65       65.00       65.00
{txt} 3         {c |}{res}         29       29.00       94.00
{txt} 5         {c |}{res}          5        5.00       99.00
{txt} 7         {c |}{res}          1        1.00      100.00
{txt} {hline 10}{c +}{hline 35}
{txt}     Total {c |}{res}        100      100.00
{txt}

{pstd} This example accentuates the slowness of {cmd:dagamesolve}, which owes to its brute-force approach to solving systems of nonlinear equations. 
That having been said, the above results are encouraging. The sequence of random 2-player, 4-action games
produce a variety of different sorts of equilibria, but always produce an odd number of equilibria, corrresponding with Wilson's (1971) proof that all "almost
all" discrete action, finite-player games have odd numbers of equilibria. This provides some assurance that {cmd:dagamesolve} is at least approximating its
intended goal of finding all the equilibria of sequences of games.{p_end}

{pstd}{it: Speeding up solutions (at a cost)}

{pstd}{cmd:dagamesolve} spends most of its time trying to find mixed or partially-mixed strategy equilibria. This problem involves solving sequences of nonlinear
systems of equations, which dagsolve solves by using a combination of interval methods (see Jaulin et. al. 2001), which amounts to using bisection, interval arithmetic,
and then Newton iteration. To speed up solution of these systems, one can skip the bisection step and proceed directly to the Newton iteration step. 
This is fast due to the fact that newton iteration can be done across many points in parallel. This is accomplished using the {help rowmat_utils} package, 
which must be installed for {cmd:dagamesolve} to work.{p_end}

{pstd} Bisection purposefully searches for places where mixed-strategy might lie; skipping this step and using {cmd:fast} amounts to a shotgun approach in which {cmd:dagamesolve} 
randomly guesses starting points across the strategy-space simplex, and iterate from there, hoping to find an interior resting point. This often produces results quite similar to 
full solution, but works much faster. As an illustration that extends the example, 
one might try the following:{p_end}

{cmd:. dagamesolve s*, group(id) pay(pay*) eq(ef) noisy fast random(100)}

{pstd}This chooses 100 random points in the strategy-space simplex as starting points for Newton iteration. Interior points thusly found are mixed-strategy equilibria;
one can verify that in the present example the same equilibria for the sequences of 100 equilibria are found.{p_end} 

{pstd}{it: Example four - solving a sequence of three-player, three actions games}{p_end}

{pstd}In this example, 20 three-player games are solved, where each player has three possible actions.  Three players, each with three actions, 
results in 3*3*3=27 possible strategy profiles, 
and when {cmd:dagamesolve} is confronted with problems of this size, it slows down rather drammatically. The example uses a command-generated
profile count to create random payoffs, and then solves the games.{p_end}

{phang}{cmd:. clear all}{p_end}
{phang}{cmd:. set seed 522150}{p_end}
{phang}{cmd:. set more off}{p_end}
{phang}{cmd:. mata: ids = (1::20)#J(3, 1, 1)}{p_end}
{phang}{cmd:. getmata ids}{p_end}
{phang}{cmd:. gen acts = 3}{p_end}
{phang}{cmd:. dagamestrats acts, group(id) gen(s)}{p_end}
{phang}{cmd:. scalar P = r(profiles)}{p_end}
{phang}{cmd:. forvalues i=1/`=P' {c -(}}{p_end}
{phang}{txt:  2. }{cmd:gen pay`i'=rnormal(0, 1)}{p_end}
{phang}{txt:  3. }{cmd:{c )-}}{p_end}
{phang}{cmd:. dagamesolve s*, group(id) pay(pay*) eq(eqs) noisy}{p_end}

{phang}{it:<Output ommitted>}

{phang}{cmd:. tab eqs_count }{p_end}

{txt}   e_count {c |}{res}      Freq.     Percent       Cum.
{txt} {hline 10}{c +}{hline 35}
{txt} 1         {c |}{res}         2       10.00       10.00
{txt} 3         {c |}{res}         9       45.00       55.00
{txt} 4         {c |}{res}         1        5.00       60.00
{txt} 5         {c |}{res}         3       15.00       75.00
{txt} 6         {c |}{res}         1        5.00       80.00
{txt} 7         {c |}{res}         2       10.00       90.00
{txt} 9         {c |}{res}         1        5.00       95.00
{txt} 10        {c |}{res}         1        5.00      100.00
{txt} {hline 10}{c +}{hline 35}
{txt}     Total {c |}{res}        20      100.00
{txt}


{pstd}The previous example makes it abudantly clear that {cmd:dagamesolve} is {it:slow} (the above example took about 2 hours to run on a computer with 16GB of ram. 
This is because {cmd:dagamesolve} relies on interval methods and bisection to find solutions to systems of polynomials. While interval methods are stable (for further
discussion, see {help intsolver}), they also use what is effectively brute force to solve polynomial systems. A cause for concern with the above results is that
{cmd:dagamesolve} finds 2, 6, and 10 equilibria for 3 of the 20 games, which does not conform with the expectations of Wilson's (1971) oddness theorem. Why this has happened
in these instances is not clear to the author. One might conjecture this is because the games truly fall into that small group of games that have even numbers of equilibria. 
Another possibility is that these anomalous outcomes are numerical artifacts; equilibria that are effectively the same look different to {cmd:dagamesolve} or vice versa. 
By careful and judicious use of the numerical options available, these problems
may be mitigated to some degree.{p_end}

{pstd}Of course, in these instances one might employ the {fast} option, but there is no guarantee the results are 100% accurate.{p_end} 

{marker rems}{title: Additional Comments}

{pstd}{cmd:dagamesolve} requires that the {bf:{help moremata}} package be installed.  Package {bf:{help dagamesolve}} also requires packages {bf:{help int_utils}},
{bf:{help rowmat_utils}}, and {bf:{help intsolver}}. All of these supporting materials can be downloaded from SSC. {p_end}

{pstd}Available on the project's github site {browse "http://github.com/mbaker21231/dagamesolve": mbaker21231/dagamesolve} in the Support directory are files dagamesolve_examples.do, 
which contains some examples to work with that are periodically updated, and also a file dagamesolve_mata.do, which generates the mata library that supports the package.
The aim in making the latter file available is transparency, so other researchers can see how the nuts and bolts of solutions work.{p_end}

{title: Full discosure!}

{pstd}{cmd:dagamesolve} is an experimental package. While it was devised with the idea that it would facilitate integration of game-theoretic estimators with Stata more seamlessly, for a couple
of reasons it perhaps is not well-suited to this objective. For one, it is very slow for games of even moderate size (i.e., 4 players, 3 actions). Second, freely avaiable packages 
such as {browse  "http://www.gambit-project.org/": Gambit} are
now fairly easy to integrate with Stata via Python.{p_end} 

{title:Author}

{phang}Matthew J. Baker, Hunter College and the Graduate Center, CUNY
matthew.baker@hunter.cuny.edu{p_end}

{title: References}
	
{p 8 8 2} 
	Jaulin, Luc, Michel Kieffer, Olivier Didrit, and Eric Walter. 2001. {it:Applied Interval Analysis}. London, Berlin, and Heidelberg: Spring-Verlag.

{p 8 8 2}
	McKelvey, Richard D., McLennan, Andrew M., and Turocy, Theodore L. 2016. Gambit: Software Tools for Game Theory, Version 16.0.1. {browse www.gambit-project.org: http://www.gambit-project.org}. 
	
{p 8 8 2}
	Wilson, Robert. 1971. Computing Equilibria of N-Person Games. {it:SIAM Journal on Applied Mathematics} 21(1): 80-87.

{title: Also see}

{bf:{help dagamestrats}}

