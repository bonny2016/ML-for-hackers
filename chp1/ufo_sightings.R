###
# Anthony Doan
# Going through the Machine Learning for Hackers 
# by Drew Conway & John Myles White
# Chapter 1
###

###
# Library
###
library(ggplot2)

###
# Load data from text file ufo_awesome.tsv
###
ufo<-read.delim("data/ufo/ufo_awesome.tsv",sep="\t", stringsAsFactors=FALSE,
		 header=FALSE, na.strings="")
# sep
# The ufo_awesome.tsv is a tab-delimited file so we set sep to Tab character
#
# stringsAsFactors
# Default setting for read.delim is to convert all string to factor type. 
# Factor type make number strings into identifier so R doesn't see those number
# as number. An example is each subjects are know as number or id (those should
# be convert to factor).
#
# header
# There is no header in this file.
#
# na.strings
# Any empty elements in the data will be set to R special value NA
#
# ufo
# The dataframe that holds our data.

###
# Checking out our data
###
#names(ufo)
#head(ufo)

###
# Add some Column names (there were no header in the data)
###
headers<-c("DateOccurred","DateReported","Location","ShortDescription","Duration","LongDescription")
names(ufo)<-headers

###
# Checkout our new headers
###
#names(ufo)

###
# Checkout the first row 
###
#ufo[1,]

###
# Checkout our new headers with some data 
# (ignoring the last column because it's hard to see in terminal)
###
#head(ufo[, !names(ufo) %in% headers[6]])

###
# Convert string that represent date to type Date
###
# ufo$DateOccurred<-as.Date(ufo$DateOccurred,format="%Y%m%d")
###
# Output
# Error in strptime(x, format, tz = "GMT") : input string is too long
# Calls: as.Date -> as.Date.character -> strptime
# Execution halted
#
# Some of the date in the records are bad or mistyped.
###

###
# Let see some of the corrupted Date rows
###
#head(ufo[which(nchar(ufo$DateOccurred)!=8 | nchar(ufo$DateReported)!=8),1])
#                                                                        ^
#                                                                        |
#                                 This is the first column the DateOcurred

###
# Constructing a vector of true/false. True for correct date format,
# False if the date format is incorrect in DateOccurred or DateReported column
###
good.rows<-ifelse(nchar(ufo$DateOccurred)!=8 | nchar(ufo$DateReported)!=8,FALSE,TRUE)

# good.rows 
# a vector of true/false telling us which rows are good and which are bad
# in term of date format
#
# ifelse 
# is a vectorized form of if else. For more info ?ifelse in R console
#
# nchar
# return number of chracters
#
# So basically this ifelse loop checks each row in ufo to see if the DateOccurred
# or DateReported is not equal to 8. If it's not equal to eight then set that vector
# row to False else set it to True

###
# See the number of bad rows
###
#length(which(!good.rows))
#length(which(good.rows))
#'% of bad rows in the overall data'
#percent.of.bad<-length(which(!good.rows))/length(which(good.rows))*100
#paste(percent.of.bad,'%')

###
# Let's just keep the good rows and throw away the bad ones
###
ufo<-ufo[good.rows,]

###
# Now we can format the DateOccurred and DateReported columns to date
###
ufo$DateOccurred<-as.Date(ufo$DateOccurred,"%Y%m%d")
ufo$DateReported<-as.Date(ufo$DateReported,"%Y%m%d")

###
# Function we're going to use to split city and state of the location column
###
# see wtf this does
# strsplit(ufo[1,3],",")[[1]]
get.location<-function(l) {
  # strsplit 
  # take a string and split it by the first comma character ","
  # strsplit returns a list with one index [[1]] but we just want the result not a list 
  # therefore after getting the result as [[1]] we access it right away 
  # which just returns a one dimension vector.
  #
  # tryCatch will try the strsplit function if not return a vector of NA,NA
  split.location<-tryCatch(strsplit(l,",")[[1]], error= function(e) return(c(NA, NA)))
  # so the previous statement will split the ufo$Location to the format city state.
  # but there are spaces in front of it an example is " Iowa City" " WA"
  # so we need to clean it up substituting the beginning space with nothing
  # the ^ in reg expression is the beginning of string
  # "^ " means the first space at the beginning at the string and replace it with ""
  clean.location<-gsub("^ ","",split.location)
  # the if statment checks if there is only two columns in the vector
  # so if there are more than 2 comma and the strsplit splits it into more than 2 element 
  if (length(clean.location)>2) {
    return(c(NA,NA))
  } 
  else {
    return(clean.location)
  }
}

###
# Time to use the function above for ufo$Location
###
# lapply short for list apply, so we're going to apply the function get.location to
# ufo$Lcation and store the return result to the dataframe city.state
city.state<-lapply(ufo$Location, get.location) # return a list
# check out the list
#head(city.state)

###
# Add two new column city and state to the ufo dataframe
###
# Convert city.state list to a two column matrix *x2
location.matrix<-do.call(rbind, city.state)
# do.call executes a function call over a list
# see it 
# head(location.matrix) 
# to get the columns into the ufo data frame
ufo<-transform(ufo, USCity=location.matrix[,1], USState=tolower(location.matrix[,2]),
stringsAsFactors=FALSE)
# Created two column USCity and USState
# USCity = location.matrix[,1] first column of the location.matrix
# USState = location.matrix[,2] second column of the location.matrix
# check the modified ufo
#names(ufo)

###
# Canada are in the ufo dataframe we want just us data need to get rid
###
# list ca 
us.states<-c("ak","al","ar","az","ca","co","ct","de","fl","ga","hi","ia","id","il",
"in","ks","ky","la","ma","md","me","mi","mn","mo","ms","mt","nc","nd","ne","nh",
"nj","nm","nv","ny","oh","ok","or","pa","ri","sc","sd","tn","tx","ut","va","vt",
"wa","wi","wv","wy")
# list of usa state 
ufo$USState<-us.states[match(ufo$USState,us.states)]
# match
# To find the entries in the USState column that do not match a US state abbreviation
# 1st arg -> to match
# 2nd arg -> to match against
# if it doesn't match any element in the list us.states 
# then we'll set the value to NA
ufo$USCity[is.na(ufo$USState)]<-NA
# set all USCity to NA if the USState column value isn't in the
# usa state list using is.na function 

# So we basically set anything that isn't a valid US state to NA
# for USCity and USState column

###
# USA only dataframe of ufo
###
ufo.us<-subset(ufo,!is.na(USState))
#let see the ufo.us data
#head(ufo.us[, !names(ufo.us) %in% c(headers[6],headers[4])])


######
######
# Analyze the Data 
######
######

# Summary Statistics
summary(ufo.us)