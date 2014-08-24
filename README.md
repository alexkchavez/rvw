rvw
===

Converts data sets in Vowpal Wabbit's sparse format to sparse lists and dense data frames in R.

### Demo
[http://alexkchavez.shinyapps.io/rvw-demo/](http://alexkchavez.shinyapps.io/rvw-demo/)

### Getting Started
From R, `install.packages("devtools")` and then install the version `>= 1.9.3` of `data.table` using the instructions below (copied from [https://github.com/Rdatatable/data.table](https://github.com/Rdatatable/data.table)):

    # check and update to latest version on CRAN
    update.packages()
    
    # try latest development version from GitHub
    # ( Windows users should first install Rtools
    #   http://cran.r-project.org/bin/windows/Rtools/ )
    require(devtools)
    install_github("data.table", "Rdatatable")
    
    # if you get pdflatex or texi2dvi errors during installation, want a 
    # quick way out and don't mind skipping building vignettes:
    install_github("data.table", "Rdatatable", build_vignettes=FALSE)
    
Finally, install rvw: `install_github("rvw", "alexkchavez")`.

### Usage

    > require(rvw)
    > vw <- c(
      "1 1.0 |MetricFeatures:3.0 height:1.5 length:2.0 |Has stripe |Other Legs:4.0 IsAnimal",
      "1 1.0 zebra|MetricFeatures:3.0 height:1.5 length:2.0 |Has stripe |Other Legs:4.0 IsAnimal",
      "1 1.0 zebra|MetricFeatures:1.5 length:2.0 |Has a white stripe |Other Legs:4.0 IsAlive",
      "1 2 'tag|a:2 b:3",
      "0 |f:.23 sqft:.25 age:.05 2006"
    )

    > fromVw(vw, dense = T)
      label importance   tag MetricFeatures_height MetricFeatures_length Has_stripe Other_Legs Other_IsAnimal Has_a Has_white
    1     1          1  <NA>                   4.5                     6          1          4              1    NA        NA
    2     1          1 zebra                   4.5                     6          1          4              1    NA        NA
    3     1          1 zebra                    NA                     3          1          4             NA     1         1
    4     1          2  'tag                    NA                    NA         NA         NA             NA    NA        NA
    5     0          1  <NA>                    NA                    NA         NA         NA             NA    NA        NA
      Other_IsAlive a_b f_sqft  f_age f_2006
    1            NA  NA     NA     NA     NA
    2            NA  NA     NA     NA     NA
    3             1  NA     NA     NA     NA
    4            NA   6     NA     NA     NA
    5            NA  NA 0.0575 0.0115   0.23

    > fromVw(vw, dense = F)
    [[1]]
      label importance  tag MetricFeatures_height MetricFeatures_length Has_stripe Other_Legs Other_IsAnimal
    1     1          1 <NA>                   4.5                     6          1          4              1
    
    [[2]]
      label importance   tag MetricFeatures_height MetricFeatures_length Has_stripe Other_Legs Other_IsAnimal
    1     1          1 zebra                   4.5                     6          1          4              1
    
    [[3]]
      label importance   tag MetricFeatures_length Has_a Has_white Has_stripe Other_Legs Other_IsAlive
    1     1          1 zebra                     3     1         1          1          4             1
    
    [[4]]
      label importance  tag a_b
    1     1          2 'tag   6
    
    [[5]]
      label importance  tag f_sqft  f_age f_2006
    1     0          1 <NA> 0.0575 0.0115   0.23
