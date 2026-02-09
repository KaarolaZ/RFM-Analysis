SELECT * FROM rfm;
ALTER TABLE rfm
RENAME COLUMN "invoice_data" TO invoice_date;
--ocyzszczony widok
CREATE OR REPLACE VIEW online_retail AS 
SELECT
    customer_id,
    invoice,
    to_timestamp(invoice_date, 'MM/DD/YY HH24:MI'),   --problemy z odczytniem formatu daty, dlatego musimy wskazać konkretny format
    (CAST(quantity AS INT)* CAST(price AS NUMERIC)) AS total_price
    FROM rfm
    WHERE CAST(quantity AS INT)>0
        AND customer_id IS NOT NULL
        AND CAST(price AS NUMERIC) >0

SELECT * FROM online_retail;

