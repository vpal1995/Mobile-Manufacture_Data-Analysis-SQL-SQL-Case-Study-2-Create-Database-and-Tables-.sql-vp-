--SQL Advance Case Study


--Q1--BEGIN 
	SELECT [State] 
FROM FACT_TRANSACTIONS T1
INNER JOIN DIM_LOCATION T2 ON T1.IDLOCATION= T2.IDLOCATION
 INNER JOIN DIM_MODEL T3 ON T1.IDMODEL= T3.IDMODEL
 WHERE Date BETWEEN '01-01-2005' AND GETDATE()
 group by State

--Q1--END

--Q2--BEGIN

SELECT TOP 1 
STATE FROM DIM_LOCATION as g
INNER JOIN FACT_TRANSACTIONS as f ON g.IDLOCATION=f.IDLOCATION
INNER JOIN DIM_MODEL d ON f.IDMODEL =d.IDModel
INNER JOIN DIM_MANUFACTURER  as m ON m.IDMANUFACTURER= d.IDMANUFACTURER
WHERE MANUFACTURER_NAME = 'Samsung'
GROUP BY STATE
ORDER BY SUM(QUANTITY) DESC

--Q2--END

--Q3--BEGIN   


SELECT MODEL_NAME, ZIPCODE, STATE, COUNT(IDCUSTOMER) AS NO_OF_TRANSACTIONS FROM DIM_LOCATION AS D
INNER JOIN FACT_TRANSACTIONS AS F ON D.IDLOCATION=F.IDLOCATION
INNER JOIN DIM_MODEL AS G ON F.IDMODEL = G.IDMODEL
GROUP BY MODEL_NAME, ZIPCODE, STATE

--Q3--END

--Q4--BEGIN


SELECT TOP 1 
IDMODEL, MODEL_NAME,min(unit_price) as price FROM DIM_MODEL
group by Model_Name,IDModel
ORDER BY price

--Q4--END

--Q5--BEGIN

SELECT MODEL_NAME, AVG(UNIT_PRICE) AS AVG_PRICE FROM DIM_MODEL
INNER JOIN DIM_MANUFACTURER ON DIM_MANUFACTURER.IDMANUFACTURER = DIM_MODEL.IDMANUFACTURER
WHERE MANUFACTURER_NAME IN 
(
SELECT TOP 5 MANUFACTURER_NAME FROM FACT_TRANSACTIONS AS F
INNER JOIN DIM_MODEL AS d ON F.IDMODEL = d.IDMODEL
INNER JOIN DIM_MANUFACTURER AS DIM ON DIM.IDMANUFACTURER = d.IDMANUFACTURER
GROUP BY MANUFACTURER_NAME
ORDER BY SUM(QUANTITY)desc
)
GROUP BY MODEL_NAME
ORDER BY AVG(UNIT_PRICE) DESC

--Q5--END

--Q6--BEGIN


SELECT CUSTOMER_NAME, AVG(TOTALPRICE) AVG_SPENT
FROM DIM_CUSTOMER as d
INNER JOIN FACT_TRANSACTIONS as f ON d.IDCUSTOMER = f.IDCUSTOMER
WHERE YEAR(Date) = 2009 
GROUP BY CUSTOMER_NAME
HAVING AVG(TOTALPRICE)>500

--Q6--END
	
--Q7--BEGIN  
SELECT *
FROM (
SELECT  top 5  Model_Name FROM FACT_TRANSACTIONS t3
INNER JOIN DIM_MODEL T2 ON T2.IDMODEL= T3.IDMODEL
INNER JOIN DIM_MANUFACTURER T1 ON T1.IDMANUFACTURER= T2.IDMANUFACTURER
WHERE YEAR(DATE) = 2008
group by t3.IDModel,Model_Name
ORDER BY SUM(Quantity) DESC
intersect
select   top 5 Model_Name FROM FACT_TRANSACTIONS t3
INNER JOIN DIM_MODEL T2 ON T2.IDMODEL= T3.IDMODEL
INNER JOIN DIM_MANUFACTURER T1 ON T1.IDMANUFACTURER= T2.IDMANUFACTURER
WHERE YEAR(DATE) = 2009
group by t3.IDModel,Model_Name
order by  sum(Quantity)desc
intersect
   SELECT  top 5 Model_Name FROM FACT_TRANSACTIONS t3
INNER JOIN DIM_MODEL T2 ON T2.IDMODEL= T3.IDMODEL
INNER JOIN DIM_MANUFACTURER T1 ON T1.IDMANUFACTURER= T2.IDMANUFACTURER
WHERE YEAR(DATE) = 2010
group by t3.IDModel,Model_Name
order by  sum(Quantity)desc) AS X

--Q7--END	
--Q8--BEGIN
 WITH RANK1 AS 
    (
        SELECT MANUFACTURER_NAME,YEAR(DATE) AS YEAR,
        DENSE_RANK() OVER (PARTITION BY YEAR(DATE) ORDER BY SUM(TOTALPRICE)DESC) AS RANK
        FROM FACT_TRANSACTIONS AS T1
        INNER JOIN DIM_MODEL AS T2
        ON T1.IDMODEL = T2.IDModel
        INNER JOIN DIM_MANUFACTURER AS T3
        ON T3.IDManufacturer = T2.IDManufacturer
        GROUP BY Manufacturer_Name, YEAR(DATE)
    )
    SELECT YEAR, MANUFACTURER_NAME
    FROM RANK1
    WHERE YEAR IN ('2009','2010') AND RANK='2'

--Q8--END
--Q9--BEGIN
	SELECT MANUFACTURER_NAME FROM DIM_MANUFACTURER T1
INNER JOIN DIM_MODEL T2 ON T1.IDMANUFACTURER= T2.IDMANUFACTURER
INNER JOIN FACT_TRANSACTIONS T3 ON T2.IDMODEL= T3.IDMODEL
WHERE YEAR(DATE) = 2010 
EXCEPT 
SELECT MANUFACTURER_NAME FROM DIM_MANUFACTURER T1
INNER JOIN DIM_MODEL T2 ON T1.IDMANUFACTURER= T2.IDMANUFACTURER
INNER JOIN FACT_TRANSACTIONS T3 ON T2.IDMODEL= T3.IDMODEL
WHERE YEAR(DATE) = 2009

--Q9--END

--Q10--BEGIN
SELECT
    T1.Customer_Name, T1.Year, T1.Avg_Price,T1.Avg_Qty,
    CASE
        WHEN T2.Year IS NOT NULL
        THEN FORMAT(CONVERT(DECIMAL(8,2),(T1.Avg_Price-T2.Avg_Price))/CONVERT(DECIMAL(8,2),T2.Avg_Price),'p') ELSE NULL 
        END AS 'YEARLY_%_CHANGE'
    FROM
        (SELECT t2.Customer_Name, YEAR(t1.DATE) AS YEAR, AVG(t1.TotalPrice) AS Avg_Price, AVG(t1.Quantity) AS Avg_Qty FROM FACT_TRANSACTIONS AS t1 
        left join DIM_CUSTOMER as t2 ON t1.IDCustomer=t2.IDCustomer
        where t1.IDCustomer in (select top 10 IDCustomer from FACT_TRANSACTIONS group by IDCustomer order by SUM(TotalPrice) desc)
        group by t2.Customer_Name, YEAR(t1.Date) 
        )T1
    left join
        (SELECT t2.Customer_Name, YEAR(t1.DATE) AS YEAR, AVG(t1.TotalPrice) AS Avg_Price, AVG(t1.Quantity) AS Avg_Qty FROM FACT_TRANSACTIONS AS t1 
        left join DIM_CUSTOMER as t2 ON t1.IDCustomer=t2.IDCustomer
        where t1.IDCustomer in (select top 10 IDCustomer from FACT_TRANSACTIONS group by IDCustomer order by SUM(TotalPrice) desc)
        group by t2.Customer_Name, YEAR(t1.Date) 
        )T2
        on T1.Customer_Name=T2.Customer_Name and T2.YEAR=T1.YEAR-1 -- self join`


--Q10--END
	