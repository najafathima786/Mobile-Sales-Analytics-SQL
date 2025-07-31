
SELECT TOP 2 * FROM DIM_CUSTOMER
SELECT TOP 2 * FROM DIM_DATE
SELECT TOP 2 * FROM DIM_LOCATION
SELECT TOP 2 * FROM DIM_MANUFACTURER
SELECT TOP 2 * FROM DIM_MODEL
SELECT TOP 2 * FROM FACT_TRANSACTIONS


--SQL Advance Case Study

/* Q1  List all the states in which we have customers who have bought cellphones  
 from 2005 till today.*/
--Q1--BEGIN 
Select distinct State from(
	select q1.State, sum(quantity) as QNT, Year(q2.Date) as Years  from DIM_LOCATION as q1 
	join FACT_TRANSACTIONS as q2
	on q1.IDLocation =q2.IDLocation
	where Year(q2.Date) >= 2005
	group by q1.State, Year(q2.Date)
) as A

--Q1--END
/* Q2 . What state in the US is buying the most 'Samsung' cell phones? */
--Q2--BEGIN
	
	select State ,  count(*) as cnt from DIM_LOCATION as d1
	join FACT_TRANSACTIONS as d2 
	on d1.IDLocation = d2.IDLocation
	join DIM_MODEL as d3
	on d3.IDModel = d2.IDModel
	join DIM_MANUFACTURER as d4
	on d4. IDManufacturer = d3.IDManufacturer
	where Country = 'US' and Manufacturer_Name = 'Samsung'
	group by State
	order by cnt desc

--Q2--END
/* Q3 . Show the number of transactions for each model per zip code per state. */
--Q3--BEGIN      
	
	select IDModel, State, ZipCode,count(*) as tot_trans 
	from DIM_LOCATION as d1
	join FACT_TRANSACTIONS as d2
	on d1.IDLocation = d2.IDLocation
	group by IDModel, State, ZipCode

--Q3--END
-- Q4 . Show the cheapest cellphone (Output should contain the price also) 
--Q4--BEGIN
	select top 1 Model_Name, Unit_price from DIM_MODEL
	order by Unit_price asc

--Q4--END
/* Q5 . Find out the average price for each model in the top5 manufacturers in  
terms of sales quantity and order by average price. */
--Q5--BEGIN

select d2.IDModel, avg(TotalPrice) as avg_price ,sum(Quantity) as qnt from FACT_TRANSACTIONS as d2
join DIM_MODEL as d1
on d1.IDModel = d2.IDModel
join DIM_MANUFACTURER as d3
on d3.IDManufacturer = d1.IDManufacturer

where Manufacturer_Name In (select top 5 Manufacturer_Name from DIM_MODEL as d1
							join FACT_TRANSACTIONS as d2 
							on d1.IDModel = d2.IDModel
							join DIM_MANUFACTURER as d3
							on d1.IDManufacturer = d3.IDManufacturer
							group by Manufacturer_Name
							order by sum(TotalPrice) desc)
group by d2.IDModel
order by avg_price desc

--Q5--END
/* Q6 . List the names of the customers and the average amount spent in 2009,  
where the average is higher than 500  */
--Q6--BEGIN

 select Customer_Name,avg(TotalPrice) as avg_amount from DIM_CUSTOMER as d1
 join FACT_TRANSACTIONS as d2
 on d1.IDCustomer = d2.IDCustomer
 where year(Date) = 2009 
 group by Customer_Name
 having avg(TotalPrice) >= 500

--Q6--END
/* Q7 . List if there is any model that was in the top 5 in terms of quantity,  
simultaneously in 2008, 2009 and 2010 */
--Q7--BEGIN  

select * from(
Select TOP 5 IDModel from FACT_TRANSACTIONS
where year(Date) = 2008 
group by IDModel, year(Date)
ORDER BY sum(Quantity) DESC
) as A
intersect
select * from(
Select TOP 5 IDModel from FACT_TRANSACTIONS
where year(Date) = 2009
group by IDModel, year(Date)
ORDER BY sum(Quantity) DESC
) as B
intersect
select * from (
Select TOP 5 IDModel from FACT_TRANSACTIONS
where year(Date) = 2010 
group by IDModel, year(Date)
ORDER BY sum(Quantity) DESC
) as C

--Q7--END
/* Q8 . Show the manufacturer with the 2nd top sales in the year of 2009 and the  
manufacturer with the 2nd top sales in the year of 2010. */
--Q8--BEGIN
SELECT * FROM (
	SELECT TOP 1 * FROM (
		SELECT TOP 2 Manufacturer_Name, YEAR(Date) AS YEARS, SUM(TotalPrice) AS TOTAL_SALES FROM FACT_TRANSACTIONS AS D1
		JOIN DIM_MODEL AS D2
		ON D1.IDModel = D2.IDModel
		JOIN DIM_MANUFACTURER AS D3
		ON D2.IDManufacturer= D3.IDManufacturer
		WHERE YEAR(DATE) = 2009
		GROUP BY Manufacturer_Name, YEAR(DATE)
		ORDER BY TOTAL_SALES DESC
	    ) AS A
	ORDER BY TOTAL_SALES ASC) AS C
UNION
SELECT * FROM(
	SELECT TOP 1 * FROM (
		SELECT TOP 2 Manufacturer_Name, YEAR(Date) AS YEARS, SUM(TotalPrice) AS TOTAL_SALES FROM FACT_TRANSACTIONS AS D1
		JOIN DIM_MODEL AS D2
		ON D1.IDModel = D2.IDModel
		JOIN DIM_MANUFACTURER AS D3
		ON D2.IDManufacturer= D3.IDManufacturer
		WHERE YEAR(DATE) = 2010
		GROUP BY Manufacturer_Name, YEAR(DATE)
		ORDER BY TOTAL_SALES DESC
	    ) AS B
	ORDER BY TOTAL_SALES ASC ) AS D
ORDER BY YEARS ASC

--Q8--END
/* Q9 . Show the manufacturers that sold cellphones in 2010 but did not in 2009.*/
--Q9--BEGIN
	
SELECT  Manufacturer_Name FROM FACT_TRANSACTIONS AS D1
	JOIN DIM_MODEL AS D2
	ON D1.IDModel = D2.IDModel
	JOIN DIM_MANUFACTURER AS D3
	ON D2.IDManufacturer= D3.IDManufacturer
	WHERE YEAR(DATE) = 2010
	GROUP BY Manufacturer_Name
EXCEPT
SELECT  Manufacturer_Name FROM FACT_TRANSACTIONS AS D1
	JOIN DIM_MODEL AS D2
	ON D1.IDModel = D2.IDModel
	JOIN DIM_MANUFACTURER AS D3
	ON D2.IDManufacturer= D3.IDManufacturer
	WHERE YEAR(DATE) = 2009
	GROUP BY Manufacturer_Name

--Q9--END
/* Q10 . Find top 100 customers and their average spend, average quantity by each  
year. Also find the percentage of change in their spend. */
--Q10--BEGIN
select * , ((avg_price - lag_price)/lag_price) as percentage_change from(
	select * , lag (avg_price,1) over(partition by idcustomer order by year) as lag_price from(
		SELECT Idcustomer, year(date) as year, avg(totalprice) as avg_price , sum(quantity) as qty from FACT_TRANSACTIONS
		Where IDCustomer in ( Select  top 10 idcustomer from FACT_TRANSACTIONS
								group by idcustomer
								order by sum(totalprice) desc)
		group by Idcustomer, year(date)
	) as A
) as B


--Q10--END