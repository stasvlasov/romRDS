
# `romRDS` an R package to read or make RDS

[![R-CMD-check](https://github.com/stasvlasov/romRDS/workflows/R-CMD-check/badge.svg)](https://github.com/stasvlasov/romRDS/actions)
[![codecov](https://codecov.io/gh/stasvlasov/romRDS/branch/master/graph/badge.svg?token=DIUS28A7US)](https://codecov.io/gh/stasvlasov/romRDS)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/stasvlasov/romRDS)

The `romRDS` package provides a wrapper that handles assignment of the code's resulting value to an object. The wrapper automatically saves the value in .rds and for later invocations can use this file to skip evaluation. Basically the wrapper either Reads from the disk Or Makes RDS files for later reuse (hence `romRDS` name). The main motivation is to avoid unnecessary reevaluation of some computationally expensive code chunks (e.g., when your R session crashed and you lost all the objects) and free up from frequent snapshots of the entire environment to the .Rdata.


## Usage

    ## consider some evaluation with subsequent assignment to object
    my_object_name <- Sys.sleep(5)
    
    ## the above will take 5 sec every time
    
    ## the romRDS package provides the romRDS function (its infix equivalent is %<--%)
    romRDS("my_object_name", Sys.sleep(5))
    
    ## the equivalent of the above in infix form
    my_object_name %<--% Sys.sleep(5)
    
    ## multiple commands can be wrapped in {} as usual
    my_object_name %<--% {
        Sys.sleep(5)
        data.frame(1:10, runif(10))
    }
    
    ## or you can use R pipes introduced since R v4.0
    ## note that maggritr pipes probably won't work
    my_object_name %<--%
        Sys.sleep(5) |>
        paste0("Sys.sleep returns NULL so prepending it to this string does not change it.")


## Installation

    devtools::install_github("stasvlasov/romRDS")

By default the package installation does not rely on any dependencies. However, if you need to some additional features (e.g., robust parameters checking and working with STATA's dta files) you need to install it with extra suggested dependencies.

    devtools::install_github("stasvlasov/romRDS", dependencies = TRUE)


## Dependencies

<table id="org5ee9a7a" border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-right" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">name</th>
<th scope="col" class="org-right">version</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">R</td>
<td class="org-right">4.2.0</td>
</tr>
</tbody>
</table>

<table id="org0c4aa60" border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-right" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">name</th>
<th scope="col" class="org-right">version</th>
<th scope="col" class="org-left">comment</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left"><a href="https://github.com/markvanderloo/tinytest/blob/master/pkg/README.md">tinytest</a></td>
<td class="org-right">1.3.1</td>
<td class="org-left">for testing</td>
</tr>


<tr>
<td class="org-left">humanFormat</td>
<td class="org-right">1.0</td>
<td class="org-left">for formatting messages</td>
</tr>


<tr>
<td class="org-left">checkmate</td>
<td class="org-right">2.1.0</td>
<td class="org-left">for checking arguments</td>
</tr>


<tr>
<td class="org-left">haven</td>
<td class="org-right">2.5.0</td>
<td class="org-left">for reading STATA .dta files</td>
</tr>
</tbody>
</table>

<table id="orgcde6e12" border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-right" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">name</th>
<th scope="col" class="org-right">version</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left"><a href="https://www.rarlab.com/">unrar</a></td>
<td class="org-right">6.12</td>
</tr>
</tbody>
</table>

