A Small Legal Data Warehouse
================
Michael Anderson
12/6/2021

## New York City Rules

Many city agencies in New York City have governing rules and regulations
that are posted on the agency’s website. The official rules are printed
on paper and bound in books, and published around the
[Internet](https://rules.cityofnewyork.us/recently-adopted-rules/) and
at [NYC Rules](https://rules.cityofnewyork.us/). Some agencies, like the
The Taxi and Limousin Commission (TLC), also include electronic copies
of their rules on the [agency
website](https://www1.nyc.gov/site/tlc/about/tlc-rules.page).

## Taxi and Limousine Rules

While working at the Taxi and Limousine Commission I came to realize
that the presentation and format at these electronic resources can make
time-series analysis of rule changes a pain to track and evaluate. A
first step to evaluate rule changes over time is to take snapshots of
these rules. This is a small bit of code to download and save all TLC
rules using the package `XML`, `RCurl`, and `rvest`. This was set to run
monthly using the package `taskscheduleR`.

### Set Up

Load libraries, create list of files to archive, and create an archive
file.

``` r
# load libraries
library(XML)
library(RCurl)
library(rvest)
```

#### Generate a List of Files to Download

I then reviewed the TLC’s website to locate the rules and zero in on
files that I wanted to backup. There are 21 files and each chapter
exists as a single file.

``` r
# pull links to rule pdfs
url <- "https://www1.nyc.gov/site/tlc/about/tlc-rules.page"
page   <- getURL(url)
parsed <- htmlParse(page)
links  <- xpathSApply(parsed, path="//a", xmlGetAttr, "href")
inds   <- grep("*.pdf", links)
links  <- links[inds]
base <- "https://www1.nyc.gov"
```

#### Create Folders to Hold the Files

Now it’s time to set up working file to hold the backups. Each backup is
time stamped.

``` r
# set up working directories
destination <- rstudioapi::getSourceEditorContext()$path
setwd(dirname(destination))

# set up file to hold links
location <- paste0(getwd(),
                   "/TLC_Rules_",
                   as.character(Sys.time(), format="%Y-%m-%d"),
                   "_",
                   as.character(Sys.time(), format="%H%M%S%p")
                   )
dir.create(location)
setwd(location)
```

### Archive Files

Now that we have a list of files and links, I’ll loop through and
download each PDF.

``` r
# set up links to loop through
origin_rules <- vector("list", length(links))
# loop through links
for(i in seq_along(links)){
  origin_rules[[i]]<-paste0(base,links[i])
}

# set up file names
file_names <- vector("list", length(origin_rules))
# loop through file names
for(i in seq_along(origin_rules)){
  file_names[[i]]<-substr(origin_rules[i], 
                          tail(unlist(gregexpr('/',origin_rules[i])), n=1)+1, 
                          nchar(origin_rules[i]))
}

# set up destination file
destination_rules <- vector("list", length(links))
# loop through destinations
for(i in seq_along(links)){
  destination_rules[[i]]<-paste0(location,'/',file_names[i])
}

# download files
for(i in seq_along(origin_rules)){
  download.file(unlist(origin_rules[i]), unlist(destination_rules[i]),mode="wb")
}
```

The script downloads each file to the archive folder.

<img src="ch51.PNG" width="75%" />

### Output Preview

We downloaded all 20 chapters in a few seconds.

<img src="rule_book_current_chapter_51_pg1.JPG" width="65%" />

## Next Steps

In the office I used `taskscheduleR` to run this script once a month.
This is a rough draft project, and there’s more to do to make this
archive more useful. Some ideas for next time include (1) Email
notification when the script completes, or (2) Review the text of the
PDFs to look for text changes in each PDF and only archive cases where
there were any text changes.
