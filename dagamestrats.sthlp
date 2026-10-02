{smcl}
{* *! version 2.0.0 02oct2026}{...}
{cmd:help dagamestrats}
{hline}

{title:Title}

{p2colset 5 19 21 2}{...}
{p2col:{hi:dagamestrats}{hline 2}} Create pure-strategy action profiles for N-player discrete-action games{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 14 2}
{cmd:dagamestrats} {varname} {ifin}{cmd:,}
{cmdab:group(}{varname}{cmd:)}
{cmdab:gen:erate(}{it:stub}{cmd:)}


{title:Description}

{pstd}
{cmd:dagamestrats} generates all pure-strategy action profiles for one or more
finite, discrete-action games. It is intended primarily as a utility for preparing
data for {help dagamesolve}.
{p_end}

{pstd}
The required {varname} contains the number of actions available to each player.
There must be one observation for each player in each game. The variable specified
in {cmd:group()} identifies the game to which each observation belongs.
{p_end}

{pstd}
For example, suppose a three-player game has two actions available to player 1,
three actions available to player 2, and two actions available to player 3.
The action-count variable would contain the values
{cmd:2}, {cmd:3}, and {cmd:2} in the three observations belonging to that game.
There are then
{cmd:2*3*2 = 12}
possible pure-strategy profiles.
{p_end}

{pstd}
{cmd:dagamestrats} creates one new variable for each possible pure-strategy
profile. If {cmd:generate(a)} is specified, the variables are named
{cmd:a1}, {cmd:a2}, ..., up to the total number of profiles. Within a game,
each observation corresponds to a player and each generated variable corresponds
to one complete action profile.
{p_end}

{pstd}
When several games are supplied in one call, the games must have the same number
of players. In addition, corresponding players must have the same number of
available actions across games. Thus, the command is designed for sequences of
games with a common action structure but potentially different payoffs or other
game-specific characteristics.
{p_end}

{pstd}
If {cmd:if} or {cmd:in} is used, the selected sample should contain complete
games with the required player structure.
{p_end}


{title:Required options}

{phang}
{cmd:group(}{varname}{cmd:)}
specifies the variable identifying each game. All games must contain the same
number of player observations.
{p_end}

{phang}
{cmd:generate(}{it:stub}{cmd:)}
specifies the stub used to name the generated action-profile variables.
For example, {cmd:generate(a)} creates variables {cmd:a1}, {cmd:a2}, and so on.
The specified names must not already exist.
{p_end}


{title:Data organization}

{pstd}
{cmd:dagamestrats} uses the "list" representation of a finite game employed by
{help dagamesolve}. To illustrate, consider a two-player, two-action game.
The four possible pure-strategy profiles are
{p_end}

        player 1:    1   1   2   2
        player 2:    1   2   1   2

{pstd}
In a Stata dataset, the two players occupy two observations and the four profiles
occupy four generated variables:
{p_end}

        {c TLC}{hline 31}{c TRC}
{txt}        {c |}{res} id   acts   a1   a2   a3   a4 {c |}
        {c LT}{hline 31}{c RT}
{txt}     1. {c |}{res}  1      2    1    1    2    2 {c |}
{txt}     2. {c |}{res}  1      2    1    2    1    2 {c |}
        {c BLC}{hline 31}{c BRC}
{txt}

{pstd}
Corresponding payoff variables may then be created in the same profile order and
passed to {help dagamesolve}.
{p_end}

{pstd}
As a larger example, suppose player 1 has two actions, player 2 has three actions,
and player 3 has four actions. The 24 pure-strategy profiles are represented by
the columns of
{p_end}

    1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2
    1,1,1,1,2,2,2,2,3,3,3,3,1,1,1,1,2,2,2,2,3,3,3,3
    1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4

{pstd}
{cmd:dagamestrats} constructs this list automatically.
{p_end}


{title:Examples}

{pstd}{it:Example 1: A single three-player game}{p_end}

{pstd}
Create the pure-strategy profiles for a game in which player 1 has two actions,
player 2 has three actions, and player 3 has two actions:
{p_end}

{phang}{cmd:. clear}{p_end}
{phang}{cmd:. set obs 3}{p_end}
{phang}{cmd:. gen id = 1}{p_end}
{phang}{cmd:. gen acts = 2}{p_end}
{phang}{cmd:. replace acts = 3 in 2}{p_end}
{phang}{cmd:. dagamestrats acts, group(id) generate(a)}{p_end}
{phang}{cmd:. list acts a*}{p_end}

        {c TLC}{hline 57}{c TRC}
{txt}        {c |}{res} acts  a1  a2  a3  a4  a5  a6  a7  a8  a9  a10  a11  a12 {c |}
        {c LT}{hline 57}{c RT}
{txt}     1. {c |}{res}    2   1   1   1   1   1   1   2   2   2    2    2    2 {c |}
{txt}     2. {c |}{res}    3   1   1   2   2   3   3   1   1   2    2    3    3 {c |}
{txt}     3. {c |}{res}    2   1   2   1   2   1   2   1   2   1    2    1    2 {c |}
        {c BLC}{hline 57}{c BRC}
{txt}

{pstd}
Because {cmd:2*3*2 = 12}, the command creates 12 profile variables.
{p_end}


{pstd}{it:Example 2: A sequence of three four-player games}{p_end}

{pstd}
Create profiles for three games, each containing four players with two actions:
{p_end}

{phang}{cmd:. clear}{p_end}
{phang}{cmd:. set obs 12}{p_end}
{phang}{cmd:. gen id = 1}{p_end}
{phang}{cmd:. replace id = 2 in 5/8}{p_end}
{phang}{cmd:. replace id = 3 in 9/12}{p_end}
{phang}{cmd:. gen acts = 2}{p_end}
{phang}{cmd:. dagamestrats acts, group(id) generate(profiles)}{p_end}

{pstd}
Each game has {cmd:2^4 = 16} pure-strategy profiles, so the command creates
{cmd:profiles1} through {cmd:profiles16}.
{p_end}

{pstd}
The resulting profiles can be used when constructing payoffs. For example,
suppose action 1 means staying out of a market and action 2 means entering.
The number of entrants under each profile can be calculated as follows:
{p_end}

{phang}{cmd:. forvalues i = 1/16 {c -(}}{p_end}
{phang}{txt:  2. }{cmd:bysort id: egen entrants`i' = total(profiles`i' == 2)}{p_end}
{phang}{txt:  3. }{cmd:{c )-}}{p_end}

{pstd}
Suppose further that each firm's payoff from staying out is zero and that the
payoff from entering is a game-specific return {cmd:K} minus the number of other
entrants:
{p_end}

{phang}{cmd:. set seed 5150}{p_end}
{phang}{cmd:. gen K = rnormal(2,1)}{p_end}
{phang}{cmd:. forvalues i = 1/16 {c -(}}{p_end}
{phang}{txt:  2. }{cmd:gen payoff`i' = 0}{p_end}
{phang}{txt:  3. }{cmd:quietly replace payoff`i' = K - (entrants`i' - 1) if profiles`i' == 2}{p_end}
{phang}{txt:  4. }{cmd:{c )-}}{p_end}

{pstd}
The generated action profiles and payoff variables are now in the list form
required by {help dagamesolve}.
{p_end}


{title:Stored results}

{pstd}
{cmd:dagamestrats} stores the following in {cmd:r()}:
{p_end}

{synoptset 20 tabbed}{...}
{synopt:{cmd:r(groups)}}number of games represented by {cmd:group()}{p_end}
{synopt:{cmd:r(profiles)}}number of pure-strategy profiles generated for each game{p_end}


{title:Remarks}

{pstd}
The number of generated variables equals the product of the numbers of actions
available to the players. Consequently, the number of profiles can grow quickly
with the number of players and actions.
{p_end}

{pstd}
{cmd:dagamestrats} is distributed as part of the {cmd:DaGameSolve} package and
uses the Mata library {cmd:ldagamesolve.mlib}. The full package also depends on
{help moremata}, {help int_utils}, {help rowmat_utils}, and {help intsolver}.
The repository's {cmd:dependency.do} file installs these dependencies.
{p_end}

{pstd}
Additional source code and development materials are available from the
{browse "https://github.com/mbaker21231/DaGameSolve":DaGameSolve GitHub repository}.
{p_end}


{title:Author}

{phang}
Matthew J. Baker{break}
Hunter College and the Graduate Center, CUNY{break}
matthew.baker@hunter.cuny.edu
{p_end}


{title:Also see}

{psee}
{space 2}Help:  {help dagamesolve}

