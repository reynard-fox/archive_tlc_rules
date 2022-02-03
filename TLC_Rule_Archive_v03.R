# Created by: Michael Anderson
# Created on: 03/09/2019
# Purpose: Create historical log of Taxi and Limousine Commission rules

###############################################
##  Set Up
###############################################

# clean up
rm(list=ls())

# load libraries
library(XML)
library(RCurl)
library(rvest)

###############################################
##  Read website links 
###############################################

# pull links to rule pdfs
url <- "https://www1.nyc.gov/site/tlc/about/tlc-rules.page"
page   <- getURL(url)
parsed <- htmlParse(page)
links  <- xpathSApply(parsed, path="//a", xmlGetAttr, "href")
inds   <- grep("*.pdf", links)
links  <- links[inds]
base <- "https://www1.nyc.gov"

###############################################
##  Prepare folders
###############################################

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

###############################################
##  Run loops
###############################################

# set up links
origin_rules <- vector("list", length(links))
# LOOP through links
for(i in  seq_along(links)){
  origin_rules[[i]]<-paste0(base,links[i])
}

# set up file names
file_names <- vector("list", length(origin_rules))
# LOOP through file names
for(i in seq_along(origin_rules)){
  file_names[[i]]<-substr(origin_rules[i], 
                          tail(unlist(gregexpr('/',origin_rules[i])), n=1)+1, 
                          nchar(origin_rules[i]))
}

# set up destination file
destination_rules <- vector("list", length(links))
# LOOP through destinations
for(i in  seq_along(links)){
  destination_rules[[i]]<-paste0(location,'/',file_names[i])
}

# download files
for(i in seq_along(origin_rules)){
  download.file(unlist(origin_rules[i]), unlist(destination_rules[i]),mode="wb")
}

###############################################
##  Stop
###############################################
