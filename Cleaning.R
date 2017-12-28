traindata <- read.csv("~/train.csv",na.strings=c("NA","NaN",""," "))
testdata <- read.csv("~/test.csv",na.strings=c("NA","NaN",""," "))

testdata$return_customer = NA 

df1 = rbind(traindata,testdata) 
##########

# Dates

##########



df1$order_date = as.Date(df1$order_date, format = "%Y/%m/%d")



df1$account_creation_date = as.Date(df1$account_creation_date, format = "%Y/%m/%d")



# changing the "0000/00/00" dates to order_date + 1

# these are primarily electronic items and other_count

default_gap = 1

tmp_deliv_0_idx = which(df1$deliverydate_actual == "0000/00/00")

df1$deliverydate_actual[tmp_deliv_0_idx] = NA

df1$deliverydate_actual = as.Date(df1$deliverydate_actual, format = "%Y/%m/%d")

df1$deliverydate_actual[tmp_deliv_0_idx] = df1$order_date[tmp_deliv_0_idx] + default_gap



# substituting the year 4746 with 2013

# replacing 2010/ with 2014/, because all purchases made on late in 2013

df1$deliverydate_estimated = sapply(df1$deliverydate_estimated, function(x){gsub(x, pattern = '4746', replacement = '2013')})

df1$deliverydate_estimated = sapply(df1$deliverydate_estimated, function(x){gsub(x, pattern = '2010/', replacement = '2014/')})

df1$deliverydate_estimated = as.Date(df1$deliverydate_estimated, format = "%Y/%m/%d")



# this is a relatively aggressive change.  It looks like certain actual delivery times have been 

# keyed-in incorrectly.

tmp_devord_diff = as.numeric(difftime(df1$deliverydate_estimated ,df1$order_date , units = c("days")))

tmp_delivery_time = as.numeric(difftime(df1$deliverydate_actual, df1$order_date , units = c("days")))

tmp_date_input_error_idx = which(tmp_delivery_time > 365 & tmp_devord_diff < 50)

tmp_date_input_error = df1$deliverydate_actual[tmp_date_input_error_idx]

# Changing the deliverydate_actual of those entries by -365 days...
##########

# Misc

##########



levels(df1$form_of_address) = c(levels(df1$form_of_address), "Other")

df1$form_of_address[is.na(df1$form_of_address)] = "Other"



# Changing the blank "" factor to an NA

tmp_ad_levs = levels(df1$advertising_code)

tmp_ad_levs[which(tmp_ad_levs=="")] = "Other"

levels(df1$advertising_code) = tmp_ad_levs



# clean up postal_delivery and postcode_invoice codes

# combining 00 and 0, and combining the non-number codes

tmp_pcode_levels = levels(df1$postcode_delivery)

tmp_pcode_levels[which(tmp_pcode_levels=="")] = -1

tmp_pcode_levels[which(tmp_pcode_levels=="00")] = tmp_pcode_levels[which(tmp_pcode_levels=="0")]

tmp_pcode_levels[!grepl("[0-9]+",tmp_pcode_levels)] = -2

levels(df1$postcode_delivery) = as.numeric(tmp_pcode_levels)



# Making the postcode_delivery and postcode_invoice the same type

df1$postcode_invoice = factor(df1$postcode_invoice)

levels(df1$postcode_invoice)[!grepl("[0-9]+",levels(df1$postcode_invoice))] = -2

levels(df1$postcode_invoice) = as.numeric(levels(df1$postcode_invoice))


df1$deliverydate_actual[tmp_date_input_error_idx] = tmp_date_input_error - 365

train <- df1[c(1:51884),]

test <- df1[-c(1:51884),]

write.csv(train,file='~/Desktop/train.csv')
write.csv(test,file='~/Desktop/test.csv')
