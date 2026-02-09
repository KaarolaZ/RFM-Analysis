SELECT * FROM rfm;
ALTER TABLE rfm
RENAME COLUMN "invoice_data" TO invoice_date;

--ocyzszczony widok
CREATE OR REPLACE VIEW online_retail AS 
SELECT
    customer_id,
    invoice,
    to_timestamp(invoice_date, 'MM/DD/YY HH24:MI'),   --problemy z odczytniem formatu daty, dlatego musimy wskazać konkretny format
    (CAST(quantity AS INT)* CAST(price AS NUMERIC)) AS total_price --CAST zmienia data type, ponieważ przy imporcie były niezgodności i musiałam wszytstkie elementy określić jako text
    FROM rfm
    WHERE CAST(quantity AS INT)>0
        AND customer_id IS NOT NULL
        AND CAST(price AS NUMERIC) >0

SELECT * FROM online_retail;

--widok RFM

CREATE OR REPLACE VIEW rfm_analysis AS
WITH rfm_base AS (  --określamy ile dni temu klient zrobił zakupy, ile razy je zrobił i ile pieniędzy wydał 
    SELECT 
        customer_id,
       EXTRACT(DAY FROM (SELECT MAX(invoice_date) FROM online_retail) - MAX(invoice_date)) AS recency, -- ile dni minęło od ostatniego zakupu
        COUNT(DISTINCT invoice) AS frequency, -- DISTINCT tylko bierze unikalne numery
        SUM(total_price) AS monetary
    FROM online_retail
    GROUP BY customer_id
),
rfm_score AS ( -- dzięki NTILE poszczególne grupy danych (recency, frequency, monetary) dzielone są poszczególnie na 4 grupy
    SELECT *,
    NTILE(4) OVER(ORDER BY recency DESC) AS r_score,
    NTILE(4) OVER(ORDER BY frequency ASC) AS f_score,
    NTILE(4) OVER(ORDER BY monetary ASC) AS m_score
    FROM rfm_base
)
SELECT *,   --łączymy zdobyte dane i finalnie określamy status klienta
    (r_score + f_score + m_score) AS total_score,
    CASE
        WHEN r_score = 4 AND f_score =4 THEN 'VIP'
        WHEN r_score >=3 AND f_score>=3 THEN 'Loyal Customer'
        WHEN r_score>=3 AND f_score <3 THEN 'New costumer'
        WHEN r_score =2 THEN 'At risk'
        WHEN r_score =1 THEN 'Lost costumer'
        ELSE 'Standard costumer'
    END AS costumer_segment
FROM rfm_score;

SELECT * FROM rfm_analysis;