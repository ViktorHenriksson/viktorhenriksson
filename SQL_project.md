## SQL queries in fraud database
The SQL code for creating the database can be found [here](./creating_fraud_detection_db.sql).

``` sql
WITH transaction_total AS (
	SELECT YEAR(timestamp) year, CAST(COUNT(*) AS DECIMAL) total_transactions, 
	   ROUND(AVG(t_r.Amount), 2) average_transaction_amount
	   FROM transaction_metadata t_m
	   JOIN transaction_records t_r ON t_r.TransactionID = t_m.TransactionID
	   GROUP BY YEAR(timestamp)),
	fraud_transactions AS (
	SELECT YEAR(t_m.timestamp) year, SUM(t_r.amount) fraud_lost, CAST(COUNT(*) AS DECIMAL) fraud_cases
		   FROM transaction_metadata t_m
	   JOIN transaction_records t_r ON t_r.TransactionID = t_m.TransactionID
	   JOIN fraud_indicators f_i ON f_i.TransactionID = t_r.TransactionID
	   WHERE f_i.FraudIndicator = 1
	   GROUP BY YEAR(t_m.timestamp))

SELECT 
    t.year,
    t.total_transactions,
    f.fraud_cases,
    CAST(ROUND((f.fraud_cases / t.total_transactions) * 100, 2) AS DECIMAL(5, 2)) as percentage_of_fraud,
    t.average_transaction_amount,
    f.fraud_lost
FROM 
    transaction_total t
JOIN 
    fraud_transactions f ON t.year = f.year;

```
<br>

| Year | Average Transaction Amount | Total Transactions | Number of Fraud Cases | Percentage of Fraud Cases | Total Amount Lost in Fraud | Average Amount Lost in Fraud |
|------|----------------------------|--------------------|------------------------|----------------------------|----------------------------|------------------------------|
| 2022 | 5007                       | 1006.11            | 261                    | 5.21%                      | 217,517.32                 | 833.40                       |
| 2023 | 4993                       | 1068.53            | 248                    | 4.97%                      | 157,403.40                 | 634.69                       |

<br>
2022 had around 39 % more monetary value lost to fraud compared to 2023. The fraud cases themselves did not drop that much, which infers that the monetary value of the fraud cases were much higher than the ones in 2023. This is also seen in the average amount. <br>
If we look closer to highest amounts lost, we see that 2022 have two amounts that are clearly higher than 2023:s cases.

``` sql
SELECT year, amount
FROM (SELECT YEAR(timestamp) year, amount, ROW_NUMBER() OVER (PARTITION BY YEAR(timestamp) ORDER BY amount DESC) row_no
FROM transaction_metadata t_m
JOIN fraud_indicators f_i ON t_m.TransactionID = f_i.TransactionID
JOIN transaction_records t_r ON t_r.TransactionID = t_m.TransactionID
WHERE  f_i.FraudIndicator = 1) t1
WHERE row_no <= 5;
```

<br>

| 2022 |	2023 |
| ---- | ---- |
| 21128,4  | 15748,35 |
| 18960,91 |	15533,5 |
| 10463,82 | 9988,9 |
| 10418,43 | 7583,59 |
| 6005,8 | 5388,52 |

<br>

Let's look closer at the two highest fraudulent transactions of 2022. 

| Timestamp                 | Amount    | Category | Age | Anomaly score |
|---------------------------|-----------|----------|-----| ------------- |
| 2022-03-28 16:28:56.813   | 18,960.91 | Food     | 22  | 0,88          |
| 2022-06-22 08:28:04.970   | 21,128.40 | Travel   | 83  | 0,27          |

The 21 000 transaction is belonging to travel and an older person, which usually is the case for fraud. The other transaction is interesting, as it is a young person and the category is fraud. This might be a case of a new fraud modus, and necessitates a closer look. 

This query shows which age groups are more likely to get scammed. 

``` sql
WITH t1 AS (SELECT t_r.CustomerID AS customer_id, t_r.amount AS amount
	FROM transaction_records t_r
	JOIN fraud_indicators f_i ON f_i.TransactionID =t_r.TransactionID
	WHERE f_i.FraudIndicator = 1),
	t2 AS (SELECT customerid, 
	CASE 
	    WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        WHEN age BETWEEN 46 AND 55 THEN '46-55'
        WHEN age BETWEEN 56 AND 65 THEN '56-65'
        WHEN age BETWEEN 65 AND 75 THEN '66-75'
		WHEN age BETWEEN 76 AND 85 THEN '76-85'
		WHEN age BETWEEN 86 AND 95 THEN '86-95'
        ELSE 'Unknown'
    	END AS age_groups
		FROM customer_data)

SELECT t2.age_groups, SUM(t1.amount) AS amount_lost, COUNT(*) AS num_of_fraud
FROM t1
JOIN t2 ON t1.customer_id = t2.CustomerID
GROUP BY t2.age_groups
ORDER BY SUM(t1.amount);
```

| Age Group | Amount Lost | Number of Fraud Cases |
|-----------|-------------|-----------------------|
| 76-85     | 72,828.45   | 69                    |
| 18-25     | 66,192.36   | 49                    |
| 36-45     | 66,006.92   | 68                    |
| 46-55     | 56,036.41   | 90                    |
| 26-35     | 45,295.63   | 74                    |
| 66-75     | 39,180.34   | 83                    |
| 56-65     | 29,380.61   | 76                    |

The age groups 76-85 and 18-25 correlates with the highest amount of lost monetary value of 2022, as shown before. However, for amount of fraud cases, 76-85 is the third lowest and 18-25 is the lowest victimised, which infers that when these age groups get scammed it is by higher amounts while other age groups get scammed more times with lower amounts.

- maybe UNION
- Tableau visualisation

[Back to main page](./index.md)
