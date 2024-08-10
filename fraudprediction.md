Which transactional and customer features are the strongest predictors of fraud?

## Exploratory Data Analysis
The relevant variables for transaction features could be: amount, time of day, day of week, month, and transaction category. 
For customer features it could be age.

Transaction category: the most common in fraud.

most common time, day, month for fraud. MAKE DASHBOARD

Most common age for fraud.

## Feature engineering
Amount is divided into thresholds seeing to low, middle and high amounts. The highest amount lost in fraud is 21 128 and the lowest is 0,49. (table). The thresholds are 
therefore 0-7000 for low, 7001-14000 for middle, and >14000 for high. 
Time of day is rounded to nearest hour.
Day of the week and month are extracted from the timestamp.
Previous victimisation of fraud?

## Random forest algorithm
