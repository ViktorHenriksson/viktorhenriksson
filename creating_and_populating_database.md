``` sql
CREATE DATABASE fraud_detection;
GO

USE fraud_detection;
GO


CREATE TABLE customer_data(
    CustomerID INTEGER NOT NULL,
    Name VARCHAR(50),
    Age INTEGER,
	Address VARCHAR(50),
    PRIMARY KEY (CustomerID)
);

CREATE TABLE transaction_records(
    TransactionID INTEGER NOT NULL,
    Amount DECIMAL(10, 2),
    CustomerID INTEGER NOT NULL,
    PRIMARY KEY (TransactionID),
    FOREIGN KEY (CustomerID) REFERENCES customer_data(CustomerID)
);

CREATE TABLE account_activity(
    CustomerID INTEGER NOT NULL,
    AccountBalance DECIMAL(10, 2),
    LastLogin DATE,
    FOREIGN KEY (CustomerID) REFERENCES customer_data(CustomerID)
);

CREATE TABLE fraud_indicators(
    TransactionID INTEGER NOT NULL,
    FraudIndicator BIT DEFAULT 0, -- binary, boolean value
    FOREIGN KEY (TransactionID) REFERENCES transaction_records(TransactionID)
);

CREATE TABLE suspicious_activity(
    CustomerID INTEGER NOT NULL,
    SuspiciousFlag BIT DEFAULT 0, -- binary, boolean value
    FOREIGN KEY (CustomerID) REFERENCES customer_data(CustomerID)
);

CREATE TABLE merchant_data(
    MerchantID INTEGER NOT NULL,
    MerchantName VARCHAR(50),
    Location VARCHAR(50),
    PRIMARY KEY (MerchantID)
);

CREATE TABLE transaction_category_labels(
    TransactionID INTEGER NOT NULL,
    Category VARCHAR(50),
    FOREIGN KEY (TransactionID) REFERENCES transaction_records(TransactionID)
);

CREATE TABLE amount_data (
    TransactionID INTEGER NOT NULL,
    TransactionAmount DECIMAL(10, 2),
    FOREIGN KEY (TransactionID) REFERENCES transaction_records(TransactionID)
);

CREATE TABLE anomaly_scores(
    TransactionID INTEGER NOT NULL,
    AnomalyScore DECIMAL(3, 2),
    FOREIGN KEY (TransactionID) REFERENCES transaction_records(TransactionID)
);

CREATE TABLE transaction_metadata(
    TransactionID INTEGER NOT NULL,
    Timestamp DATE,
    MerchantID INTEGER NOT NULL,
    FOREIGN KEY (TransactionID) REFERENCES transaction_records(TransactionID),
    FOREIGN KEY (MerchantID) REFERENCES merchant_data(MerchantID)
);
```

Python code for randomly populating the database.

``` python 
import pandas as pd
import numpy as np
from faker import Faker
from sqlalchemy import create_engine

# Initialize Faker
fake = Faker()

# Database connection details
server = 'LAPTOP-S2K7040D\\SQLEXPRESS'
database = 'test'

# Create a database connection
# For Windows Authentication
engine = create_engine(f'mssql+pyodbc://{server}/{database}?driver=ODBC+Driver+17+for+SQL+Server')

# Generate Transaction Data
num_records = 10000

# Using log-normal distribution for transaction amounts
transaction_records = pd.DataFrame({
    'TransactionID': range(1, num_records + 1),
        'Amount': np.round(np.random.lognormal(mean=5, sigma=2, size=num_records), 2),
    'CustomerID': np.random.randint(1001, 2001, num_records)  # Customers with IDs between 1001 and 2000
})


transaction_metadata = pd.DataFrame({
    'TransactionID': range(1, num_records + 1),
    'Timestamp': pd.date_range('2022-01-01', '2023-12-31', periods=num_records),  # Randomly spread over 2 years
    'MerchantID': np.random.randint(2001, 3001, num_records)  # Merchants with IDs between 2001 and 2501
})

# Generate Customer Profiles
num_customers = 1000
customer_data = pd.DataFrame({
    'CustomerID': range(1001, 2001),
    'Name': [fake.name() for _ in range(num_customers)],
    'Age': np.random.randint(18, 85, num_customers),
    'Address': [fake.address().replace('\n', ', ') for _ in range(num_customers)]
})

account_activity = pd.DataFrame({
    'CustomerID': range(1001, 2001),
    'AccountBalance': np.random.uniform(1000, 10000, num_customers),
    'LastLogin': pd.date_range('2022-01-01', '2023-12-31', periods=num_customers)
})

# Generate Fraudulent Patterns
fraud_indicators = pd.DataFrame({
    'TransactionID': range(1, num_records + 1),
    'FraudIndicator': np.random.choice([0, 1], num_records, p=[0.95, 0.05])
})

suspicious_activity = pd.DataFrame({
    'CustomerID': range(1001, 2001),
    'SuspiciousFlag': np.random.choice([0, 1], num_customers, p=[0.98, 0.02])
})

anomaly_scores = pd.DataFrame({
    'TransactionID': range(1, num_records + 1),
    'AnomalyScore': np.random.uniform(0, 1, num_records)
})

# Generate Merchant Information
num_merchants = 1000
merchant_data = pd.DataFrame({
    'MerchantID': range(2001, 3001),
    'MerchantName': [fake.company() for _ in range(num_merchants)],
    'Location': [fake.city() for _ in range(num_merchants)]
})

transaction_category_labels = pd.DataFrame({
    'TransactionID': range(1, num_records + 1),
    'Category': np.random.choice(['Food', 'Retail', 'Travel', 'Online', 'Other'], num_records)
})

# Save DataFrames to SQL Server
transaction_records.to_sql('transaction_records', engine, if_exists='replace', index=False)
transaction_metadata.to_sql('transaction_metadata', engine, if_exists='replace', index=False)
customer_data.to_sql('customer_data', engine, if_exists='replace', index=False)
account_activity.to_sql('account_activity', engine, if_exists='replace', index=False)
fraud_indicators.to_sql('fraud_indicators', engine, if_exists='replace', index=False)
suspicious_activity.to_sql('suspicious_activity', engine, if_exists='replace', index=False)
anomaly_scores.to_sql('anomaly_scores', engine, if_exists='replace', index=False)
merchant_data.to_sql('merchant_data', engine, if_exists='replace', index=False)
transaction_category_labels.to_sql('transaction_category_labels', engine, if_exists='replace', index=False)
```
