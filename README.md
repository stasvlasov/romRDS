
# `romRDS` an R package to read or make RDS

[![R-CMD-check](https://github.com/stasvlasov/romRDS/workflows/R-CMD-check/badge.svg)](https://github.com/stasvlasov/romRDS/actions)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/stasvlasov/romRDS)

The `romRDS` package provides a wrapper that handles assignment of the code's resulting value to an object. The wrapper automatically saves the value in .rds and for later invocations can use this file to skip evaluation. Basically the wrapper either Reads from the disk Or Makes RDS files for later reuse (hence `romRDS` name). The main motivation is to avoid unnecessary reevaluation of some computationally expensive code chunks (e.g., when your R session crashed and you lost all the objects) and free up from frequent snapshots of the entire environment to the .Rdata.

For example:

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

    devtools::install_github("nil")


## Dependencies and Suggests

<table id="orgf032e14" border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">packages</th>
<th scope="col" class="org-left">link</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">tinytest</td>
<td class="org-left"><a href="https://github.com/markvanderloo/tinytest/blob/master/pkg/README.md">https://github.com/markvanderloo/tinytest/blob/master/pkg/README.md</a></td>
</tr>


<tr>
<td class="org-left">fastmatch</td>
<td class="org-left"><a href="https://cran.r-project.org/web/packages/fastmatch/index.html">CRAN - Package fastmatch</a></td>
</tr>
</tbody>
</table>

<table id="orgd64c06a" border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-right" />

<col  class="org-right" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">packages</th>
<th scope="col" class="org-right">current<sub>version</sub></th>
<th scope="col" class="org-right">ensure<sub>version</sub></th>
<th scope="col" class="org-left">link</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">data.table</td>
<td class="org-right">1.14.2</td>
<td class="org-right">1.13.0</td>
<td class="org-left">&#xa0;</td>
</tr>


<tr>
<td class="org-left">stringi</td>
<td class="org-right">1.7.6</td>
<td class="org-right">1.6.0</td>
<td class="org-left">&#xa0;</td>
</tr>


<tr>
<td class="org-left">xml2</td>
<td class="org-right">1.3.2</td>
<td class="org-right">1.0.0</td>
<td class="org-left">&#xa0;</td>
</tr>


<tr>
<td class="org-left">checkmate</td>
<td class="org-right">2.0.0</td>
<td class="org-right">2.0.0</td>
<td class="org-left">&#xa0;</td>
</tr>
</tbody>
</table>


## Development

