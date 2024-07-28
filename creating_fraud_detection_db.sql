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

BULK INSERT customer_data
FROM 'C:\Users\vikto\OneDrive\Dokument\data analysis project\Data\Customer Profiles\customer_data.csv'
WITH (
    FIELDTERMINATOR = ',',  -- Specifying the field terminator
    ROWTERMINATOR = '\n',   -- Specifying the row terminator
    FIRSTROW = 2            -- The CSV has headers, therefore the first row is skipped
);

BULK INSERT transaction_records
FROM 'C:\Users\vikto\OneDrive\Dokument\data analysis project\Data\Transaction Data\transaction_records.csv'
WITH (
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',   
    FIRSTROW = 2           
);

BULK INSERT account_activity
FROM 'C:\Users\vikto\OneDrive\Dokument\data analysis project\Data\Customer Profiles\account_activity.csv'
WITH (
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',   
    FIRSTROW = 2            
);

BULK INSERT fraud_indicators
FROM 'C:\Users\vikto\OneDrive\Dokument\data analysis project\Data\Fraudulent Patterns\fraud_indicators.csv'
WITH (
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',   
    FIRSTROW = 2            
);

BULK INSERT suspicious_activity
FROM 'C:\Users\vikto\OneDrive\Dokument\data analysis project\Data\Fraudulent Patterns\suspicious_activity.csv'
WITH (
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',   
    FIRSTROW = 2            
);

BULK INSERT merchant_data
FROM 'C:\Users\vikto\OneDrive\Dokument\data analysis project\Data\Merchant Information\merchant_data.csv'
WITH (
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',   
    FIRSTROW = 2            
);

BULK INSERT transaction_category_labels
FROM 'C:\Users\vikto\OneDrive\Dokument\data analysis project\Data\Merchant Information\transaction_category_labels.csv'
WITH (
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',   
    FIRSTROW = 2            
);

BULK INSERT anomaly_scores
FROM 'C:\Users\vikto\OneDrive\Dokument\data analysis project\Data\Transaction Amounts\anomaly_scores.csv'
WITH (
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',   
    FIRSTROW = 2            
);

BULK INSERT transaction_metadata
FROM 'C:\Users\vikto\OneDrive\Dokument\data analysis project\Data\Transaction Data\transaction_metadata.csv'
WITH (
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',   
    FIRSTROW = 2            
);
