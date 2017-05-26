
[![Project Status: WIP - Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip) [![MIT Licensed - Copyright 2016 Noam Ross and Jenny Bryan](https://img.shields.io/badge/license-MIT-blue.svg)](https://badges.mit-license.org/) [![Linux Build Status](https://travis-ci.org/noamross/checkers.svg?branch=master)](https://travis-ci.org/noamross/checkers) [![Coverage Status](https://img.shields.io/codecov/c/github/ropenscilabs/checkers/master.svg)](https://codecov.io/github/ropenscilabs/checkers?branch=master)

checkers
========

Checkers is a framework for reviewing and automated checking of best practices for [research compendia](https://github.com/ropensci/rrrpkg).

## Package to assess analysis + review guide for analysis best practice
 
`checkers` is an extension of `goodpractice` (for building R packages) but for your analysis workflow. This package will provide both automatized checks for best practises as well as a descriptive guide for best practises. The guide categorizes best practises in terms of their importance (Tier 1-3) and whether they are automatable.


Goals
-----
-   What is the equivalent of R CMD check? What is the equivalent to the ROpenSci package onboarding process? What is code coverage for data?
-   What can be automated? What needs human review?
-   Working product vs. final product?
-   What are the typical parts/phases of an analysis? This can help you know where you are. How do you get there from where you are now? The carrot (i.e a sticker/badge) vs. the stick.
-   Can you evaluate the git commit messages?
-   How can I assess my analysis process from data to code to analysis to reporting?

# Overview of Analysis 'Best Practise' Guidelines
 
### Phases of Analysis
 
Types of Test/Checks/Assessment groups
 
* Data
* Script/Code (organization/structure)
* Package/Organisational
* Analysis Tasks
* Visualisation/Reporting

## [Full list of checks available](https://docs.google.com/document/d/1OYcWJUk-MiM2C1TIHB1Rn6rXoF5fHwRX-7_C12Blx8g/edit#)
 
 
## Examples
Example best practices in terms of their importance (y-axis) and the degree they can be automated (x-axis).
![](https://github.com/ropenscilabs/checkers/blob/master/figs/compendium.png)
 
### 1. **Automatable & "Must have"**
- **Research phase :** Data
- **Name :** Commenting
- **Description :** It is important to comment your code so that you can remember what you have written and created. It also allows you to share with other people.
- **Example :** Check to see if you have commented each code chunk. What is the % of comments contained in your code?
- **checker packages:** YES could be automated
 
### 2.  **Automatable & "Nice to have"**
 
- **Research phase :** Package/Organisational     
- **Name :** Version control    
- **Description :** It is important to store versions of your code as you program so you can go back to old versions of your analysis. This is important to help you debug and also help with collabration with others using tools like git/github or other version control providers.    
- **Example :** Check to see if you have a git file    
- **CheckR packages :** YES could be automated
 
### 3.  **Automatable & "Recommended"**
 
- **Research phase :** Visualisation/Reporting   
- **Name :** Grammar/Spelling    
- **Description :** It is important that you have correct spelling and grammar in code and reporting.     
- **Example :** Check that you have installed gramR *new* packag     
- **CheckR packages :** YES gramR is in development


# Vignettes examples
 
example vignettes ....


<br><br>

# checkers

Installation
------------

``` r
devtools::install_github("noamross/checkers")
```

Usage
-----

``` r
library(checkers)
```

License
-------

MIT + file LICENSE ©
