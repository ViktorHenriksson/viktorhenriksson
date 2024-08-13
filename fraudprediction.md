Which transactional and customer features are the strongest predictors of fraud?

## Exploratory Data Analysis
Target variable is fraudindicator, i.e. if the transaction was a fraud or not. The amount of non-fraudulent transactions are 9491 and the fraudulent are 509, which is 5,1 % of all transactions. 
The relevant variables that could predict fraud for transaction features could be amount, time of day, day of week, month, and transaction category. For customer features it could be age.

[View Tableau Dashboard](https://public.tableau.com/views/sqlvisualisation/agecategoryamount?:language=sv-SE&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)
The fraudulent transactions for each age varies wildly and it is difficult to see a trend. There are three noticable spikes for ages 22, 54, and 83. The ages least affected were 23 and 43.

For the amount in fraudulent transactions, the overwhelming transactions are below 1000. It has a steep drop to the 1000-2000 range, which just gets lower and lower. Only four fraudulent transaction were above 10 000.

The fraudulent transactions are quite evenly distributed over the shopping categories. The only noticable difference is that fraud in the travel category is lower than the others. 

[View Tableau Dashboard](https://public.tableau.com/views/sqlvisualisation/amountfrauddash)

For 2022, Thurdays seems to be the day with most fraudulent transactions, and for 2023 it is Thursdays and Saturdays. The least fraudulent days are Fridays and Sundays for 2023 and 2022 respectively. 
For months, 2022 and 2023 are widely different. The most amount of fraudulent transactions happened in November for 2022 and in March for 2023.
The hours also vary quite a lot, where there are two clear spikes for the different years. In 2022, the most fraud happened during 11:00-12:00, which in 2023 most fraud happened during 17:00.


## Feature engineering
I start with selecting the relevant variables from the database:

``` python
import pandas as pd
from sqlalchemy import create_engine

# Database connection details
server = server name
database = 'fraud_database'

# Create a database connection
# For Windows Authentication
engine = create_engine(f'mssql+pyodbc://{server}/{database}?driver=ODBC+Driver+17+for+SQL+Server')

query = '''
SELECT 
    cd.customerid,
    tm.timestamp, 
    cd.age, 
    tcl.category, 
    tr.amount, 
    fi.fraudindicator
FROM 
    transaction_metadata tm
JOIN 
    transaction_records tr ON tm.transactionid = tr.transactionid
JOIN
    customer_data cd ON tr.customerid = cd.customerid
JOIN 
    transaction_category_labels tcl ON tcl.transactionid = tm.transactionid
JOIN
    fraud_indicators fi ON fi.transactionid = tm.transactionid
'''

fraud_table = pd.read_sql(query, engine)
```

Amount is divided into thresholds seeing to low, middle and high amounts. The highest amount lost in fraud is 21 128 and the lowest is 0,49. (table). The thresholds are 
therefore 0-7000 for low, 7001-14000 for middle, and >14000 for high. Also age is divided into age groups.

``` python
fraud_table["amount group"] = pd.cut(fraud_table["amount"], bins=[0,7000,14000,22000], 
                                  labels=["Low amount","Medium amount","High amount"])

fraud_table["age group"] = pd.cut(fraud_table["age"], bins=[17,25,35,45,55,65,75,85,95], 
                                 labels=["18-25","26-35","36-45","46-55","56-65","66-75","76-85","86-95"])
```

previous fraud is based on if a customer has been victimised by fraud at least once. 

``` python
#code is here
```


Day of the week and month are extracted from the timestamp. Time of day is rounded to nearest hour.

``` python
fraud_table["weekday"] = fraud_table["timestamp"].dt.dayofweek

fraud_table["month"] = fraud_table["timestamp"].dt.month

fraud_table["hour"] = fraud_table["timestamp"].dt.hour
```


## Random forest algorithm
