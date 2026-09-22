**Generate day variables

**original SPSS file has this in seconds since reference point

*dateint/86400 converts to days; 13775 refers to a day count from a baseline

gen interview_date = dateint/86400 - 137775

format interview_date %td

 

 

*this version uses start of coup as break; omits day of commencement

gen postcoup = .

replace postcoup = 0 if interview_date < td(30sep2022)

replace postcoup = 1 if interview_date > td(30sep2022)

 

*this verion uses coup's resolution as break; no omitted day since no data oct3

gen postcoup1 = .

replace postcoup1 = 0 if interview_date < td(2oct2022)

replace postcoup1 = 1 if interview_date > td(3oct2022)

 

*this version omits days coup is uncertain

gen postcoup2 = .

replace postcoup2 = 0 if interview_date < td(30sep2022)

replace postcoup2 = 1 if interview_date > td(3oct2022)

 

label define q22blbl ///

    1 "Strongly disapprove" ///

    2 "Disapprove" ///

    3 "Neither approve nor disapprove" ///

    4 "Approve" ///

    5 "Strongly approve" ///

    8 "Refused" ///

    9 "Don't know"

 

label values q22b q22blbl

 

**t-tests (no weights for these)

ttest q22b if inrange(q22b,1,5), by(postcoup)

ttest q22b if inrange(q22b,1,5), by(postcoup1)

ttest q22b if inrange(q22b,1,5), by(postcoup2)

 

*testing equal variance

sdtest q22b if inrange(q22b,1,5), by(postcoup)

*insig

sdtest q22b if inrange(q22b,1,5), by(postcoup1)

*sig at .1

sdtest q22b if inrange(q22b,1,5), by(postcoup2)

*sig at .05

 

*Welch's t-test

ttest q22b if inrange(q22b,1,5), by(postcoup) unequal

ttest q22b if inrange(q22b,1,5), by(postcoup1) unequal

ttest q22b if inrange(q22b,1,5), by(postcoup2) unequal

 

*weights

tab q22b [aw=v375_a]

 

*naive model with weights

reg q22b i.postcoup [pw=v375_a] if inrange(q22b,1,5), vce(robust)

testparm i.postcoup

margins postcoup

margins postcoup, pwcompare(effects)

 

 

reg q22b i.postcoup1 [pw=v375_a] if inrange(q22b,1,5), vce(robust)

testparm i.postcoup1

margins postcoup1

margins postcoup1, pwcompare(effects)

 

reg q22b i.postcoup2 [pw=v375_a] if inrange(q22b,1,5), vce(robust)

testparm i.postcoup2

margins postcoup2

margins postcoup2, pwcompare(effects)

 

*Additional controls

/*region is region in country - this is important since the timing of the survey in

different regions is not random, so a pre/post different could be driven by regional

variable

 

q84a is an ethnicity variable; like region, different groups are not surveyed

at random times, so this will help address the potential impact of this

 

q37h is a variable gauging trust in the armed forces; this helps us isolate

feelings about army rule from thoughts about the military more broadly

 

*/

 

replace q37h=. if q37h>3

 

*trust in army as control, region and ethnic group fixed effects

reg q22b i.postcoup i.region i.q84a [pw=v375_a] if inrange(q22b,1,5), vce(robust)

testparm i.postcoup

margins postcoup

margins postcoup, pwcompare(effects)

 

reg q22b i.postcoup q37h i.region i.q84a [pw=v375_a] if inrange(q22b,1,5), vce(robust)

testparm i.postcoup

margins postcoup

margins postcoup, pwcompare(effects)

 

*adding control for urban vs rural area

reg q22b i.postcoup q37h urbrur i.region i.q84a [pw=v375_a] if inrange(q22b,1,5), vce(robust)

testparm i.postcoup

margins postcoup

margins postcoup, pwcompare(effects)

 

*ordered logit

 

ologit q22b i.postcoup i.region i.q84a  [pw=v375_a] if inrange(q22b,1,5), vce(robust)

ologit q22b i.postcoup q37h i.region i.q84a  [pw=v375_a] if inrange(q22b,1,5), vce(robust)

ologit q22b i.postcoup i.region i.q84a  [pw=v375_a] if inrange(q22b,1,5), vce(robust)

 

 

 

 

*plot support by day

 

*strong support for military rule

preserve

keep if inrange(q22b,1,5)

gen strongsupport = (q22b==5)

collapse (mean) strongsupport [pw=v375_a], by(interview_date)

replace strongsupport = strongsupport*100

twoway connected strongsupport interview_date, ///

    xline(`=td(30sep2022)', lpattern(dash)) ///

    ytitle("Percent strongly approving military rule") ///

    xtitle("Interview date") ///

    title("Strong support for military rule by interview date")

               restore

 

              

*mean support           

preserve

keep if inrange(q22b,1,5)

collapse (mean) q22b [pw=v375_a], by(interview_date)

twoway connected q22b interview_date, ///

    xline(`=td(30sep2022)', lpattern(dash)) ///

    ytitle("Mean support for military rule") ///

    xtitle("Interview date") ///

    ylabel(1(1)5) ///

    title("Daily mean support for military rule")

restore

 

*with daily ticks

preserve

keep if inrange(q22b,1,5)

collapse (mean) q22b [pw=v375_a], by(interview_date)

twoway connected q22b interview_date, ///

    xline(`=td(30sep2022)', lpattern(dash)) ///

    xlabel(`=td(20sep2022)'(1)`=td(12oct2022)', format(%tdMon_DD) angle(45)) ///

    ytitle("Mean support for military rule") ///

    xtitle("Interview date") ///

    ylabel(1(1)5) ///

    title("Daily mean support for military rule")

restore

 

 

*illustrate number of interviews by day

preserve

gen n = 1

collapse (sum) n, by(interview_date)

tsset interview_date

tsfill

replace n = 0 if missing(n)

twoway bar n interview_date, ///

    xline(`=td(30sep2022)', lpattern(dash)) ///

    xlabel(`=td(20sep2022)'(1)`=td(12oct2022)', ///

        format(%tdMon_DD) angle(45)) ///

    ytitle("Number of interviews") ///

    xtitle("Interview date") ///

    title("Afrobarometer interviews completed by day")

restore

 

*The tsfill step is useful because it ensures October 3 appears as a zero rather than simply disappearing from the graph.

 

twoway bar n interview_date || ///

    scatter n interview_date, ///

    mlabel(n) msymbol(none) mlabposition(12) ///

    xline(`=td(30sep2022)', lpattern(dash)) ///

    xlabel(`=td(20sep2022)'(1)`=td(12oct2022)', ///

        format(%tdMon_DD) angle(45)) ///

    ytitle("Number of interviews") ///

    xtitle("Interview date") ///

    title("Afrobarometer interviews completed by day") ///

    legend(off)

 

 

*------------------------------------------------------------*

* 1. CREATE THREE-PERIOD VARIABLE

*------------------------------------------------------------*

*pre-coup, during coup's uncertain outcome period, post-resolution

gen coup_period = .

replace coup_period = 0 if interview_date < td(30sep2022)

replace coup_period = 1 if inrange(interview_date, ///

    td(30sep2022), td(2oct2022))

replace coup_period = 2 if interview_date > td(2oct2022)

 

label define coup_period_lbl ///

    0 "Pre-coup" ///

    1 "Coup period: Sept 30-Oct 2" ///

    2 "Post-coup: After Oct 2"

 

label values coup_period coup_period_lbl

 

tab coup_period

 

tab coup_period if inrange(q22b,1,5)

 

mean q22b [pw=v375_a] if inrange(q22b,1,5), over(coup_period)

              

reg q22b q37h i.region i.q84a i.coup_period [pw=v375_a] if inrange(q22b,1,5), vce(robust)

              

margins coup_period

 

 

reg q22b ib0.coup_period ///

    i.region i.q4a ///

    [pw=v375_a] ///

    if inrange(q22b,1,5), vce(robust)

              

margins coup_period

 

marginsplot, ///

    recast(scatter) ///

    recastci(rcap) ///

    ytitle("Mean support for military rule") ///

    xtitle("") ///

    ylabel(1(1)5) ///

    title("Support for Military Rule Across Coup Periods")

              

              

              

              

              

              

              

              

              

              

              

              

***Trust in armed forces

mean q37h [pw=v375_a] if inrange(q37h,0,3), ///

    over(coup_period)

              

ttest q37h if inrange(q37h,0,3), by(postcoup)

 

 

*Armed forces should never intervene

***Trust in armed forces

mean q29b [pw=v375_a] if inrange(q29b,1,4), ///

    over(coup_period)

              

ttest q29b if inrange(q29b,1,4), by(postcoup)

 

 

*Blame Damiba

gen blame_damiba = .

replace blame_damiba = 1 if q81_bfo == 2

replace blame_damiba = 0 if inlist(q81_bfo,1,3,4,5,7)

 

label define blamedamibalbl ///

    0 "Did not blame Damiba regime" ///

    1 "Blamed Damiba regime"

 

label values blame_damiba blamedamibalbl

 

 

mean blame [pw=v375_a], ///

    over(coup_period)

              

ttest blame, by(postcoup)

 

reg blame  i.coup_period [pw=v375_a], vce(robust)

 

preserve

 

* Keep respondents with a valid blame_damiba value

keep if !missing(blame_damiba)

 

* Convert to percentage for easier interpretation

gen blame_pct = blame_damiba * 100

 

* Calculate weighted daily mean

collapse (mean) blame_pct [pw=v375_a], by(interview_date)

 

* Graph daily percentage blaming Damiba

twoway connected blame_pct interview_date, ///

    xline(`=td(30sep2022)', lpattern(dash)) ///

    xline(`=td(2oct2022)', lpattern(dot)) ///

    xlabel(`=td(20sep2022)'(1)`=td(12oct2022)', ///

        format(%tdMon_DD) angle(45)) ///

    ylabel(0(5)25) ///

    ytitle("Percent blaming Damiba regime") ///

    xtitle("Interview date") ///

    title("Blame for Burkina Faso's Security Crisis") ///

    subtitle("Percent identifying the Damiba regime as most responsible") ///

    legend(off)

 

restore

 

 

*Military should concentrate on fighting instead of politics

 

mean q80b_bfo [pw=v375_a] if inrange(q80b_bfo,1,5), ///

    over(coup_period)

              

ttest q80b_bfo if inrange(q80b_bfo,1,5), by(postcoup)

 

reg q80b_bfo  i.coup_period [pw=v375_a], vce(robust)

 

 

 

/*

| Variable       | Question                                                                                                                                                                                                                                                             | Responses                                                                                                                                                                                |

| -------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |

| **`q22b`**     | “There are several ways of governing a country. Would you disapprove or approve of the following alternative: **The army intervenes to govern the country**?”                                                                                                        | `1` Strongly disapprove; `2` Disapprove; `3` Neither approve nor disapprove; `4` Approve; `5` Strongly approve; `9` Don’t know                                                           |

| **`q29b`**     | Statement 1: **“The armed forces of Burkina Faso should never intervene in the political affairs of the country.”** Statement 2: **“It is legitimate for the armed forces to take control of government when elected leaders abuse power for their own interests.”** | `1` Agree very strongly with Statement 1; `2` Agree with Statement 1; `3` Agree with Statement 2; `4` Agree very strongly with Statement 2; `5` Agree with neither; `9` Don’t know       |

| **`q37h`**     | “How much do you trust each of the following institutions…? **The defence and security forces**.”                                                                                                                                                                    | `0` Not at all; `1` Just a little; `2` Somewhat; `3` A lot; `9` Don’t know / haven’t heard enough                                                                                        |

| **`q80b_bfo`** | “The military who have been in power since January 2022 should **concentrate entirely on fighting insecurity instead of also engaging in politics**.”                                                                                                                | `1` Strongly disagree; `2` Disagree; `3` Neither agree nor disagree; `4` Agree; `5` Strongly agree; `9` Don’t know                                                                       |

| **`q81_bfo`**  | “Apart from the armed terrorist groups occupying part of Burkina Faso’s territory, which of the following actors is **most responsible for the security crisis** facing our country?”                                                                                | `1` Previous Burkinabè regimes; `2` Current regime of President Damiba; `3` Burkina defence and security forces; `4` France; `5` Combination of these; `7` None of these; `9` Don’t know |

| **`q83a_bfo`** | “How useful are the following forces in helping Burkina Faso recover its territorial integrity and national unity? **The defence and security forces (FDS)**.”                                                                                                       | `1` Not useful at all; `2` Just a little useful; `3` Somewhat useful; `4` Very useful; `9` Don’t know                                                                                    |

| **`q83b_bfo`** | Same usefulness question, for **Volunteers for the Defence of the Homeland (VDP)**.                                                                                                                                                                                  | `1` Not useful at all; `2` Just a little useful; `3` Somewhat useful; `4` Very useful; `9` Don’t know                                                                                    |

| **`q83c_bfo`** | Same usefulness question, for **forces from Burkina Faso’s neighboring countries**.                                                                                                                                                                                  | `1` Not useful at all; `2` Just a little useful; `3` Somewhat useful; `4` Very useful; `9` Don’t know                                                                                    |

| **`q83d_bfo`** | Same usefulness question, for **French forces**.                                                                                                                                                                                                                     | `1` Not useful at all; `2` Just a little useful; `3` Somewhat useful; `4` Very useful; `9` Don’t know                                                                                    |

| **`q83e_bfo`** | Same usefulness question, for **Russian forces**.                                                                                                                                                                                                                    | `1` Not useful at all; `2` Just a little useful; `3` Somewhat useful; `4` Very useful; `9` Don’t know                                                                                    |

| **`q83f_bfo`** | Same usefulness question, for **American forces**.                                                                                                                                                                                                                   | `1` Not useful at all; `2` Just a little useful; `3` Somewhat useful; `4` Very useful; `9` Don’t know                                                                                    |

| **`ea_sec_b`** | Interviewer observation: “Did you or one of your colleagues see in this enumeration area **soldiers or army vehicles**?”                                                                                                                                             | `1` Yes; `0` No; `9` Don’t know                                                                                                                                                          |

| **`ea_sec_c`** | Interviewer observation: “Did you or one of your colleagues see **police/gendarmerie or army roadblocks**?”                                                                                                                                                          | `1` Yes; `0` No; `9` Don’t know                                     
