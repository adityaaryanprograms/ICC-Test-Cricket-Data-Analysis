-- -------------------------------------------------------------------------------------
# Part – A
-- -------------------------------------------------------------------------------------

# Tasks to be performed:

# 1. Import the csv file to a table in the database.
create database cricket;
use cricket;
update test_batting set 
inn=nullif(inn,'-'),
no=nullif(no,'-'),
runs=nullif(runs,'-'),
hs=nullif(hs,'-'),
avg=nullif(avg,'-'),
`100`=nullif(`100`,'-'),
`50`=nullif(`50`,'-'),
`0`=nullif(`0`,'-');
-- Since the data had missing values represented as hyphens (-), we first imported the columns as text and then replaced the hyphens with null
alter table test_batting 
modify inn int,
modify no int,
modify runs int,
modify avg float,
modify `100` int,
modify `50` int,
modify `0` int; -- converting text columns back into integer

# 2. Remove the column 'Player Profile' from the table.
alter table test_batting drop `player profile`;

# 3. Extract the country name and player names from the given data and store it in separate columns for further usage.
alter table test_batting add country char(10) generated always as 
(trim(')' from right(player,length(player)-(length(player)-instr(reverse(player),'('))-1))),
-- extracting strings from the right of last occurence of '(' in 'Player' column and removing ')' from the end to get country names
add name char(30) generated always as (left(player,instr(player,'(')-2));
-- extracting strings from the left of '(' in 'Player' column to get player names

# 4. From the column 'Span' extract the start_year and end_year and store them in separate columns for further usage.
alter table test_batting add start_year year generated always as (left(span,4)),add end_year year generated always as (right(span,4)); 
-- extracting start years from left and end years from right

# 5. The column 'HS' has the highest score scored by the player so far in any given match. The column also has details if the player had completed the match in a NOT OUT status. Extract the data and store the highest runs and the NOT OUT status in different columns.
alter table test_batting add highest int generated always as 
(if(hs like '%*',left(hs,length(hs)-1),hs)),
-- extracting digits from left of '*' if HS has '*',else taking whole into new column
add not_out int generated always as (if(hs like '%*',1,0));
-- inserting 1 for not-outs and 0 for outs in highest scoring match

# 6. Using the data given, considering the players who were active in the year of 2019, create a set of batting order of best 6 players using the selection criteria of those who have a good average score across all matches for India.
select name 
from test_batting 
where ('2019' between start_year and end_year) and country='INDIA'
order by avg desc
limit 6;

# 7. Using the data given, considering the players who were active in the year of 2019, create a set of batting order of best 6 players using the selection criteria of those who have the highest number of 100s across all matches for India.
select name 
from test_batting 
where ('2019' between start_year and end_year) and country='INDIA'
order by `100` desc
limit 6;

# 8. Using the data given, considering the players who were active in the year of 2019, create a set of batting order of best 6 players using 2 selection criteria of your own for India.
select name 
from test_batting 
where ('2019' between start_year and end_year) and country='INDIA'
order by highest desc,`50` desc
limit 6;

# 9. Create a View named ‘Batting_Order_GoodAvgScorers_SA’ using the data given, considering the players who were active in the year of 2019, create a set of batting order of best 6 players using the selection criteria of those who have a good average score across all matches for South Africa.
create view Batting_Order_GoodAvgScorers_SA as
select name 
from test_batting 
where ('2019' between start_year and end_year) and country='SA'
order by avg desc
limit 6;

# 10. Create a View named ‘Batting_Order_HighestCenturyScorers_SA’ Using the data given, considering the players who were active in the year of 2019, create a set of batting order of best 6 players using the selection criteria of those who have highest number of 100s across all matches for South Africa.
create view Batting_Order_HighestCenturyScorers_SA as
select name 
from test_batting 
where ('2019' between start_year and end_year) and country='SA'
order by `100` desc
limit 6;

# 11. Using the data given, Give the number of player_played for each country.
select country,count(name) players from test_batting group by country;

# 12. Using the data given, Give the number of player_played for Asian and Non-Asian continent
select count(name) Asian_players from test_batting where country like '%INDIA%' or country like '%PAK%' or country like '%AFG%' or country like '%BDESH%' or country like '%SL%';
-- returning count of players for whom Asian countries exist in 'country' column
select count(name) Non_Asian_players from test_batting where !(country like '%INDIA%' or country like '%PAK%' or country like '%AFG%' or country like '%BDESH%' or country like '%SL%'); 
-- returning count of players for whom Asian countries don't exist in 'country' column

-- -------------------------------------------------------------------------------------
# Part – B
-- -------------------------------------------------------------------------------------

# 1. Company sells the product at different discounted rates. Refer actual product price in product table and selling price in the order item table. Write a query to find out total amount saved in each order then display the orders from highest to lowest amount saved.
select OrderId,sum(p.unitprice*quantity)-sum(o.unitprice*quantity) Saving 
-- finding total amount according to actual price and total amount according to discounted price and subtracting them
from product p join orderitem o 
on p.id=productid
group by orderid -- to find savings per order
order by saving desc;

# 2. Mr. Kavin want to become a supplier. He got the database of "Richard's Supply" for reference. Help him to pick: 
# a. List few products that he should choose based on demand.
select ProductName
from product p join orderitem
on p.id=productid
group by p.id -- to find count of orders product-wise
order by count(orderid) desc -- to display products with the most number of orders
limit 5; -- displaying top five products with highest demand
# b. Who will be the competitors for him for the products suggested in above questions.
with t as 
(select supplierid
from product p join orderitem on p.id=productid
group by p.id
order by count(orderid) desc
limit 5) 
-- common table expression contains ID of suppliers selling top five products with highest demand
select distinct CompanyName
from supplier join t 
on id=supplierid;
-- joining with common table expression to find companies having ID in common table expression

# 3. Create a combined list to display customers and suppliers details considering the following criteria 
# ●	Both customer and supplier belong to the same country
select c.*,s.* -- displaying all columns from both customer and supplier tables
from supplier s join product p on s.id=supplierid
join orderitem on p.id=productid
join orders o on orderid=o.id
join customer c on customerid=c.id
where c.country=s.country;
# ●	Customer who does not have supplier in their country
select * from customer where country not in(select country from supplier); 
-- Subquery returns all countries with suppliers present. Main query fetches details of customers living in countries not listed by the subquery.
# ●	Supplier who does not have customer in their country
select * from supplier where country not in(select country from customer);
-- Subquery returns all countries where customers live. Main query fetches details of suppliers present in countries not listed by the subquery.

# 4. Every supplier supplies specific products to the customers. Create a view of suppliers and total sales made by their products and write a query on this view to find out top 2 suppliers (using windows function) in each country by total sales done by the products.
create view sales as
select CompanyName,Country,sum(o.unitprice*quantity) Sales 
-- unitprice*quantity gives sale per product per order
-- Country is needed to partition
from supplier s join product p on s.id=supplierid
join orderitem o on  p.id=productid
group by s.id;
select * from 
(select Country,CompanyName,rank() over(partition by country order by sales desc) `Rank`
from sales) t -- Subquery ranks suppliers by country on the basis of their sales
where `rank`<=2; -- limiting upto the second ranks

# 5. Find out for which products, UK is dependent on other countries for the supply. List the countries which are supplying these products in the same list.
select distinct ProductName,s.Country
from customer c join orders o on c.id=customerid
join orderitem on o.id=orderid
join product p on productid=p.id
join supplier s on supplierid=s.id
where c.country='UK' and s.country!='UK';
-- Query displays products ordered by customers in UK but for which suppliers are not in UK.

# 6. Create two tables as ‘customer’ and ‘customer_backup’ as follow - 
# ‘customer’ table attributes -
# Id, FirstName,LastName,Phone
# ‘customer_backup’ table attributes - 
# Id, FirstName,LastName,Phone
# Create a trigger in such a way that It should insert the details into the  ‘customer_backup’ table when you delete the record from the ‘customer’ table automatically.
create table customers1(
Id int not null,
FirstName varchar(200) not null,
LastName varchar(200) not null,
phone varchar(12) not null,
primary key(id)
);
create table customers_backup(
Id int not null,
FirstName varchar(200) not null,
LastName varchar(200) not null,
phone varchar(12) not null);
DELIMITER //
create trigger customer_del
after delete
on customers1 for each row
begin
insert into customers_backup values(old.Id,old.FirstName,old.LastName,old.phone);
end //
-- Trigger inserts record from 'customers1' into 'customers_backup' when it is deleted.
insert into customers1(Id,FirstName,LastName,phone) values
(1,'Ankit','Gupta','8545963214'),
(2,'Bhavana','Pandey','7456982143'),
(3,'Karan','Malhotra','9873615498');
select * from customers1;
delete from customers1;
select * from customers1;
select * from customers_backup;
