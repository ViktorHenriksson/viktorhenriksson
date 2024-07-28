## SQL queries in fraud database

[Back to main page](https://viktorhenriksson.github.io/viktorhenriksson/)

```
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
| Year | Average transaction amount | Total transactions | Number of fraud cases | Percentage of fraud cases | Total amount lost in fraud | Average amount lost in fraud |
| -------- | ------- | -------- | ------- | -------- | ------- | ------- |
| 2022	| 5007	| 1006,11	| 261	| 5.21	| 217517,32 | 833,4 |
| 2023	| 4993	| 1068,53	| 248	| 4.97	| 157403,4 | 634,69 |

2022 had around 39 % more monetary value lost to fraud compared to 2023. The fraud cases themselves did not drop that much, which infers that the monetary value of the fraud cases were much higher than the ones in 2023. This is also seen in the average amount. <br>
If we look closer to highest amounts lost, we see that 2022 have two amounts that are clearly higher than 2023:s cases.
```
SELECT year, amount
FROM (SELECT YEAR(timestamp) year, amount, ROW_NUMBER() OVER (PARTITION BY YEAR(timestamp) ORDER BY amount DESC) row_no
FROM transaction_metadata t_m
JOIN fraud_indicators f_i ON t_m.TransactionID = f_i.TransactionID
JOIN transaction_records t_r ON t_r.TransactionID = t_m.TransactionID
WHERE  f_i.FraudIndicator = 1) t1
WHERE row_no <= 5;
```
| 2022 |	2023 |
| ---- | ---- |
| 21128,4  | 15748,35 |
| 18960,91 |	15533,5 |
| 10463,82 | 9988,9 |
| 10418,43 | 7583,59 |
| 6005,8 | 5388,52 |

Let's look closer at the two highest fraudulent transactions of 2022. 
| Timestamp                 | Amount    | Category | Age |
|---------------------------|-----------|----------|-----|
| 2022-03-28 16:28:56.813   | 18,960.91 | Food     | 22  |
| 2022-06-22 08:28:04.970   | 21,128.40 | Travel   | 83  |

The 21 000 transaction is belonging to travel and an older person, which usually is the case for fraud. The other transaction is interesting, as it is a young person and the category is fraud. This might be a case of a new fraud modus, and necessitates a closer look. 





