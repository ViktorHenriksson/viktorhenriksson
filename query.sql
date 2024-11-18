-- Query for summarising the data

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

-- Query for the finding the top five fraudulent transactions per year by amount

SELECT year, amount
FROM (SELECT YEAR(timestamp) year, amount, ROW_NUMBER() OVER (PARTITION BY YEAR(timestamp) ORDER BY amount DESC) row_no
FROM transaction_metadata t_m
JOIN fraud_indicators f_i ON t_m.TransactionID = f_i.TransactionID
JOIN transaction_records t_r ON t_r.TransactionID = t_m.TransactionID
WHERE  f_i.FraudIndicator = 1) t1
WHERE row_no <= 5;

-- Query for summarising amount and fraud cases per age group

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
