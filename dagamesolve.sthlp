{smcl}
{* *! version 1.0.0 15sep2014}{...}
{cmd:help dagamesolve}
{hline}

{title:Title}

{p2colset 5 19 21 2}{...}
{p2col:{hi:dagamesolve}{hline 2}} Find all equilibria of N-player discrete action games{p_end}
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
{cmd:dagamesolve} can find all equilibria - mixed-strategy and pure-strategy - of sequences of 
similar games. Players in a game are identified 
by the variable {cmdab:group(}{varname}{cmd:)}, which also serves as a game identifier.
Strategy profiles are passed to {cmd:dagamesolve} in a {varlist}, 
while corresponding payoffs indicated by {cmdab:pay:offs(}varlist{cmd:)}. 
{cmdab:eq:uilibria(}varlist{cmd:)} generates an exhaustive list of values for the grouping variable
listed in {cmdab:group(}{varname}{cmd:)}. Each grouping variable contains a strategy profile. The user might wish to consult some
of the qualifying {help dagamesolve##rems:remarks} before using {cmd:dagamesolve}. 
{p_end}

{pstd}
To be processed by {cmd:dagamesolve}, games should be written in what can be called a
"list" form. As an example, consider the following two-player, two-action game written in normal form, 
where player one chooses rows, player two chooses columns, and player one's payoffs are
listed first in the normal-form payoff matrix:{p_end}

        {txt}             strategy 1  strategy 2
        {txt}{hline 38}
        {txt}strategy 1  |   1,2        0,0.1
        {txt}strategy 2  |   0,0        3,1
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

{pstd} The game can now be solved by passing action and payoff information to {cmd:dagamesolve}:{p_end}

{phang}{cmd:. dagamesolve a1 a2 a3 a4, group(id) pay(pay1 pay2 pay3 pay4) eq(e)}{p_end}

{pstd} Equilibria are now collected in newly generated variables {cmd:e*}, which are numbered by equilibrium, player, 
and then probability that each strategy is played in equilibrium:{p_end}

{phang}{cmd:. format e* %9.2f}{p_end}
{phang}{cmd:. list e*}{p_end}

        {c TLC}{hline 131}{c TRC}
{txt}        {c |}{res} e_rets_1 e_1_1_1 e_1_1_2 e_1_2_1 e_1_2_2 e_rets_1 e_2_1_1 e_2_1_2 e_2_2_1 e_2_2_2 e_rets_3 e_3_1_1 e_3_1_2 e_3_2_1 e_3_2_2 e_count{c |}
        {c LT}{hline 131}{c RT}
{txt}     1. {c |}{res}     1.00       .       .       .       .     3.00       .       .       .       .     0.75       .       .       .       .       .{c |}
{txt}     2. {c |}{res}     2.00    1.00    0.00    1.00    0.00     1.00    0.00    1.00    0.00    1.00     0.69    0.34    0.66    0.75    0.25    3.00{c |}
        {c BLC}{hline 131}{c BRC}
{txt}

{pstd} Equilibria are described in additional column variables aligned with the last observation of the grouping variable ({cmd:id}
in this case). The new entries are labled according to the equilibrium number, the player, and then the probability that
the player plays the given strategy. The {cmd:e_rets_i} variable collects the expected returns to each player at the given strategy, and
the very last vaiable, {cmd:e_count} contains a simple count of the equilibria. Evidently, the game in question has three
equilibria. The first two equilibria are pure-strategy equilibria, while the third equilibrium is a mixed-strategy equilibrium in which
player one plays strategy one with a probability of ~.34 and strategy two with probability ~.66, and player two plays strategy one
with probability ~.75 and strategy two with probability ~.25.{p_end}

{pstd}As a further, more expansive example, consider a three-player game in which player one has two actions to choose from, 
player two has three actions to choose from, and player three has four actions to choose from. Then, the list form
	of the game would begin by specifying actions as:{p_end}
	
    1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2
    1,1,1,1,2,2,2,2,3,3,3,3,1,1,1,1,2,2,2,2,3,3,3,3
    1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4
	
{pstd}So, all possible actions profiles are created and can be read as columns.{p_end}

{pstd}{help dagamestrats} automates the production of lists of actions like those above as new stata variables, 
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

{pstd}Randomly generated standard normal payoffs for the above strategy profiles.{p_end} 

{phang}{cmd:. set seed 5150}{p_end}
{phang}{cmd:. forvalues i=1/12 {c -(}}{p_end}
{phang}2. {cmd:gen pay`i'=rnormal()}{p_end}
{phang}3. {cmd:{c )-}}{p_end}

{pstd}Compute all the equilibria of the game, using the {cmd:noisy} option to get 
some feedback on how the solution is progressing.:{p_end}

{phang}{cmd:. dagamesolve a1-a12, group(id) pay(pay1-pay12) eq(eqs) noisy}{p_end}
{phang}{cmd:Subgames:        23}{p_end}
{phang}{cmd:.......................}{p_end}
{phang}{cmd:Game Solved. Equilibria:        1}{p_end}

{pstd}This game, it seems has a single equilibrium.{p_end}

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

{pstd}To see how {cmd:dagamestrats} might be useful in assembling payoffs, suppose one is interested 
in modelling an entry game, where any of the four players might decide to enter the market or not. Suppose that action 1 denotes
staying out of the market, where action 2 denotes entry. Suppose further that firms' profits consist
 of a random constant that is normally distributed with a mean of 2 and a standard deviation
of one, and that profits are decreasing in the number of entrants besides the firm, so that profits are K-#(other entrants). Generating a count
of the number of total entering firms might go as follows:{p_end}

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
{phang}Subgames:        7{p_end}
{phang}.......{p_end}
{phang} Game Solved. Equilibria:         1{p_end}
{phang}Subgames:       33{p_end}
{phang}.................................{p_end}
{phang} Game Solved. Equilibria:         1{p_end}
{phang}{p_end}
{phang} Game Solved. Equilibria:         1{p_end}

{pstd}The above output generated by the {cmd:noisy} option conveys a little bit of information about the underlying game. FOr example,
the first game, after elimination of dominated strategies, had to solve 7 remaining subgames, and once this was done, there was
1 equilibrium left. The second game pared down solution to 33 different subgames once dominated strategies were eliminated, yet
was still able to narrow down the resulting set to a single equilibrium. The last game, evidently, was completely dominance-solvable.{p_end}

{pstd}One way of viewing results is to look at the resulting entry rates of the firms (if we can indeed think about the first observation
in each group as corresponding to a consistent entity across the games). {p_end}

{phang}{cmd:. sum eqs_1_*_2}{p_end}


{txt}    Variable   {c |}  Obs       Mean    Std. dev.     Min       Max 
     {hline 10}{c LT}{hline 48}
{txt}     eqs_1_1_2 {c |}{res}    3          1           0        1         1   
{txt}     eqs_1_2_2 {c |}{res}    3   .3333333    .5773503        0         1
{txt}     eqs_1_3_2 {c |}{res}    3   .3333333    .5773503        0         1
{txt}     eqs_1_4_2 {c |}{res}    3   .6666667    .5773503        0         1	  
{txt}

It appears that across the sequence of the three games, the first firm always enters, the second and third firm enters only one of the three
markets, while the fourth firm enters two of the three markets. 

{pstd}{it: Example three: solving sequence of games and counting equilibria}{p_end}

{pstd}One can also solve a large number of games, but this might take awhile. In this example, 20 three-player games are solved, 
where each player has three possible actions. This should generate 27 possible action profiles, for which random payoffs are 
generated. A count of the profiles is generated by {cmd:dagamestrats}, which is used to create a local and generate random payoffs.{p_end}

{phang}{cmd:. clear all}{p_end}
{phang}{cmd:. set seed 522150}{p_end}
{phang}{cmd:. set more off}{p_end}
{phang}{cmd:. mata: ids = (1::20)#J(3, 1, 1)}{p_end}
{phang}{cmd:. getmata ids}{p_end}
{phang}{cmd:. gen acts = 3}{p_end}
{phang}{cmd:. dagamestrats acts, group(id) gen(a)}{p_end}
{phang}{cmd:. scalar P = r(profiles)}{p_end}
{phang}{cmd:. forvalues i=1/16 {c -(}}{p_end}
{phang}{txt:  2. }{cmd:bysort id: egen entrants`i'=total(profiles`i'==2)}{p_end}
{phang}{txt:  3. }{cmd:{c )-}}{p_end}





{marker rems}{title: Additional Comments}

{pstd}{cmd:dagamesolve} requires that the {bf:{help moremata}} package be installed.  Package {bf:{help dagamesolve}} also requires packages {bf:{help int_utils}},
{bf:{help rowmat_utils}}, and {bf:{help intsolver}}. All of these supporting materials can be downloaded from SSC. {p_end}

{pstd}Available on the project's github site {browse: "http://github.com/mbaker21231/dagamesolve": mbaker21231/dagamesolve} in the Support directory are files dagamesolve_examples.do, 
which contains some examples to work with that are periodically updated, and also a file dagamesolve_mata.do, which generates the mata library that supports the package.
The aim in making the latter file available is transparency, so other researchers can see how the nuts and bolts of solutions work.{p_end}

{title: Full discosure!}

{pstd}{cmd:dagamesolve} is an experimental package. While it was devised with the idea that it would facilitate integration of game-theoretic estimators with Stata more seamlessly, for a couple
of reasons it perhaps is not well-suited to this objective. For one, it is very slow for games of even moderate size (i.e., 4 players, 3 actions). Second, freely avaiable packages 
such as {browse: "http://www.gambit-project.org/": Gambit} are
now fairly easy to integrate with Stata via Python.{p_end} 

{title:Author}

{phang}Matthew J. Baker, Hunter College and the Graduate Center, CUNY
matthew.baker@hunter.cuny.edu{p_end}

{title: Also see}

{bf:{help dagamestrats}}

