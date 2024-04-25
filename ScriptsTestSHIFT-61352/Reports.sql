-- Запрос на получение товаров, по которым не было покупок
DECLARE @start_date DATE = DATEADD(MONTH, -1, GETDATE());
SELECT P.CODE, P.NAME
FROM PRODUCTS P
LEFT JOIN PURCHASE_RECEIPTS PR ON P.ID = PR.PRODUCT_ID
LEFT JOIN PURCHASES PU ON PR.PURCHASE_ID = PU.ID
EXCEPT
SELECT P.CODE, P.NAME
FROM PRODUCTS P
LEFT JOIN PURCHASE_RECEIPTS PR ON P.ID = PR.PRODUCT_ID
JOIN PURCHASES PU ON PR.PURCHASE_ID = PU.ID
WHERE PU.DATETIME >= @start_date;

-- Продавцы, которые не совершили ни одной продажи
DECLARE @start_date DATE = DATEADD(MONTH, -1, GETDATE());
SELECT E.FIRST_NAME, E.LAST_NAME, S.NAME
FROM EMPLOYEES E
LEFT JOIN PURCHASES P ON E.ID = P.SELLER_ID
LEFT JOIN SHOPS S ON E.SHOP_ID = S.ID
Where E.JOB_NAME = 'Продавец-консультант'
EXCEPT
SELECT E.FIRST_NAME, E.LAST_NAME, S.NAME
FROM EMPLOYEES E
LEFT JOIN PURCHASES P ON E.ID = P.SELLER_ID
JOIN SHOPS S ON E.SHOP_ID = S.ID
Where P.DATETIME >= @start_date
AND E.JOB_NAME = 'Продавец-консультант';

-- Самые эффективные продавцы в предыдущем календарном месяце
DECLARE @start_date DATE = DATEADD(MONTH, -1, GETDATE());
SELECT E.FIRST_NAME, E.LAST_NAME, S.NAME AS SHOP, SUM(PR.AMOUNT_FULL) AS TOTAL_SALES
FROM EMPLOYEES E
INNER JOIN PURCHASES P ON E.ID = P.SELLER_ID
INNER JOIN SHOPS S ON E.SHOP_ID = S.ID
INNER JOIN PURCHASE_RECEIPTS PR ON P.ID = PR.PURCHASE_ID
WHERE P.DATETIME >= @start_date
AND E.JOB_NAME = 'Продавец-консультант'
GROUP BY E.FIRST_NAME, E.LAST_NAME, S.NAME
ORDER BY TOTAL_SALES DESC;

-- Выручка в разрезе регионов за предыдущий календарный месяц
DECLARE @start_date DATE = DATEADD(MONTH, -1, GETDATE());
SELECT S.REGION, SUM(PR.AMOUNT_FULL) AS TOTAL_INCOME
FROM SHOPS S
LEFT JOIN EMPLOYEES E ON S.ID = E.SHOP_ID
LEFT JOIN PURCHASES P ON E.ID = P.SELLER_ID
LEFT JOIN PURCHASE_RECEIPTS PR ON P.ID = PR.PURCHASE_ID
WHERE P.DATETIME >= @start_date
GROUP BY S.REGION
ORDER BY TOTAL_INCOME DESC;

-- Магазины и дни, в которых случился сбой
SELECT
    S.NAME As NAME_SHOP,
    P.DATETIME AS DATE_OF_PURCHASE,
    SUM(DISTINCT P.AMOUNT) - SUM(PR.AMOUNT_FULL) AS DISCREPANCY_AMOUNT
FROM PURCHASES P
LEFT JOIN PURCHASE_RECEIPTS PR ON P.ID = PR.PURCHASE_ID
LEFt JOIN EMPLOYEES E ON P.SELLER_ID = E.ID
JOIN SHOPS S ON E.SHOP_ID = S.ID
GROUP BY  P.DATETIME, S.NAME
HAVING SUM(DISTINCT P.AMOUNT) != SUM(PR.AMOUNT_FULL);
