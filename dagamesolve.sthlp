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

{phang}{cmd:. describe e*}

Variable	Storage	Display	Value
name	type	format	label	Variable	label
						
e_rets_1	float	%9.0g		     
e_1_1_1	float	%9.0g		     
e_1_1_2	float	%9.0g		     
e_1_2_1	float	%9.0g		     
e_1_2_2	float	%9.0g		     
e_rets_2	float	%9.0g		     
e_2_1_1	float	%9.0g		     
e_2_1_2	float	%9.0g		     
e_2_2_1	float	%9.0g		     
e_2_2_2	float	%9.0g		     
e_rets_3	float	%9.0g		     
e_3_1_1	float	%9.0g		     
e_3_1_2	float	%9.0g		     
e_3_2_1	float	%9.0g		     
e_3_2_2	float	%9.0g		     
e_count	float	%9.0g		     



{pstd}As a further, more expansive example, consider a three-player game in which player one has two actions to choose from, 
player two has three actions to choose from, and player three has four actions to choose from. Then, the list form
	of the game would begin by specifying actions as:{p_end}
	
    1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2
    1,1,1,1,2,2,2,2,3,3,3,3,1,1,1,1,2,2,2,2,3,3,3,3
    1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4
	
{pstd}So, all possible actions profiles are created and can be read as columns.{p_end} 

{pstd}{help dagamestrats} automates the production of lists of actions like those above as new stata variables, 
which can also be handy in characterizing the payoffs to games.{p_end} 

{pstd}To use {cmd:dagamesolve} each pure-strategy profile should be contained in its own stata variable, and corresponding
to each strategy profile should be a stata variable containing payoffs to each player. 
	
{title:Examples}

{pstd}Pure-strategy profiles for a single 3-player game in which player one has two actions, player two has three actions, 
and player three has two actions: {p_end}

{phang}{cmd:. set obs 3}{p_end}
{phang}{cmd:. gen id=1}{p_end}
{phang}{cmd:. gen acts=2{p_end}
{phang}{cmd:. replace acts=3 in 2}{p_end}
{phang}{cmd:. dagamestrats, group(id) actions(acts) gen(a)}{p_end}
{phang}{cmd:. list a*}{p_end}
    
        {c TLC}{hline 57}{c TRC}
{txt}        {c |}{res} acts  a1  a2  a3  a4  a5  a6  a7  a8  a9  a10  a11  a12 {c |}
        {c LT}{hline 57}{c RT}
{txt}     1. {c |}{res}    2   1   1   1   1   1   1   2   2   2    2    2    2 {c |}
{txt}     2. {c |}{res}    3   1   1   2   2   3   3   1   1   2    2    3    3 {c |}
{txt}     3. {c |}{res}    2   1   2   1   2   1   2   1   2   1    2    1    2 {c |}		  
        {c BLC}{hline 57}{c BRC}
{txt}

{pstd}Pure-strategy profiles for 3 4-player where each player has two strategies: {p_end}

{phang}{cmd:. set obs 12}{p_end}
{phang}{cmd:. gen id=1}{p_end}
{phang}{cmd:. gen acts=2}{p_end}
{phang}{cmd:. replace id=2 in 5/8}{p_end}
{phang}{cmd:. replace id=3 in 9/12}{p_end}
{phang}{cmd:. dagamestrats, group(id) actions(acts) gen(profiles) }{p_end}

{pstd}To see how {cmd:dagamestrats} might be useful in assembling payoffs, suppose that the previous scenario is designed
to model an entry game, where any of the four players might be entrants into a market. Suppose that action 1 denotes
staying out of the market, where action 2 denotes entering the market. Suppose further that firms' profits consist
 of a random constant that is normally distributed with a mean of 2 and a standard deviation
of one, and that profits are decreasing in the number of entrants besides the firm, so that profits are K-#(other entrants). Generating a count
of the number of total entering firms might go as follows:{p_end}

{phang}{cmd:. forvalues i=1/16 {c -(}}{p_end}
{phang}{txt:  2. }{cmd:bysort id: egen entrants`i'=total(profiles`i'==2)}{p_end}
{phang}{txt:  3. }{cmd:{c )-}}{p_end}

{pstd}The loop runs over 16 observations, as in this case there are 2^4=16 distinct action profiles for the game.
Generating payoffs for each firm given the parameterization:{p_end}

{phang}{cmd:. gen K=rnormal(2,1)}{p_end}
{phang}{cmd:. forvalues i=1/16 {c -(}}{p_end}
{phang}{txt:  2. }{cmd:gen payoffs`i'=0}{p_end}
{phang}{txt:  3. }{cmd:quietly replace payoffs`i'=K-(entrants`i'-1) if profiles`i'==2}{p_end}
{phang}{txt:  4. }{cmd:{c )-}}{p_end}

{pstd}After running the above code, one has the payoffs from three random entry games, with the desired payoffs. The payoffs and action profiles
are written in a format that is compatible with the command {bf:{help dagamesolve}}.{p_end}

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

