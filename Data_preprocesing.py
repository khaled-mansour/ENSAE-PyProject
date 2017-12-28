## import liabrires #####
import pandas as pd
import numpy as np
from sklearn import svm, linear_model, datasets, metrics
from sklearn.preprocessing import LabelEncoder, scale
import seaborn as sns
import matplotlib.pyplot as plt
%matplotlib inline

###### import train and test data ####
train = pd.read_csv("Data/train_clean.csv" , sep =",", index_col="ID")
test = pd.read_csv("Data/test_clean.csv" , sep =",", index_col = "ID")
train = train.drop('Unnamed: 0', 1)
test = test.drop('Unnamed: 0', 1)

train.head(10)
test.head()
train.info()
print("----------------------------")
test.info()

print(train)
train.columns

## First we add return cutomers column to test data filled with NA
test['return_csutomer'] = np.nan
test.head()

## we visualize missing values Vs observed values in both train and test data 
import missingno as msno
msno.bar(train)
msno.bar(test)

## in both train and test postcode_delivery and advertising code are missing more than 70% of the observations 
## form_of_address and weight are missing 20% and 10% respectively of the observations

## binding test and train for data preprocessing
comdata= pd.concat([train,test])
comdata.describe
comdata.info()
comdata.return_customer.describe()

## dealing with missing values

#1. Postcode_delivery is missing more than 90% of observations. Imputing these values will be a strong assumption. 
#However, one possible assumption behind this large amount of missing values is that postcode_delivery is same as postcode_invoice. 
#Therefore this variable will be dropped from the next analysis and predictions and only postcode_invoice will be taken into consideration
comdata = comdata.drop('postcode_delivery', 1)
#2. weight : this varaible will be dropped as well assuming that it has no effect on customer churn or retention 
#since the information of weight is provided on the website and it is the customer willingness to choose the product knowing the weight
# thus it should not prevent him from returning. Also many products are downloadable and dont have any weight which explains the missing values
comdata = comdata.drop('weight', 1)
#3. Advertising code : a dummy variable will be created instead taking the value 1 if an advertising code as been used and 0 if not
comdata.advertising_code.loc[~comdata.advertising_code.isnull()] = 1  # not nan
comdata.advertising_code.loc[comdata.advertising_code.isnull()] = 0 #nan
comdata.advertising_code.describe
comdata.columns[comdata.isnull().any()]


## Dates 
comdata.order_date = pd.to_datetime(comdata.order_date, format='%Y-%m-%d')
comdata.account_creation_date = pd.to_datetime(comdata.account_creation_date , format='%Y-%m-%d')

comdata['timelapse_to_order'] = (comdata['order_date'] - comdata['account_creation_date']).abs().dt.days
