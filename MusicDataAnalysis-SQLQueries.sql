USE [MusicStoreDataAnalysisYT]
--Question 1--
select top 1 * from dbo.employee order by levels desc 

--Question 2-- select the countries with most invoices
select top 3 count(*) as Total_Count,billing_country from dbo.invoice group by billing_country order by Total_Count desc

select *from dbo.invoice

--Question 3 --what are top3 vslues of total invoices

select top 3 total,billing_country from dbo.invoice order by total desc

--Question 4--
select sum(total) as total_invoices , billing_city from dbo.invoice group by billing_city order by total_invoices desc

--Question 5--who is the best customer? the customer who has spent the most money is the best
	select * from dbo.customer where customer_id= 5
	--select top 1 customer_id, SUM(total) as total from dbo.invoice group by customer_id
	--order by total desc
select top 1 customer.first_name, customer.last_name,SUM(dbo.invoice.total) as total
from customer
join dbo.invoice 
on customer.customer_id = invoice.customer_id 
group by customer.customer_id, customer.last_name,customer.first_name
order by total desc

-----------------MODERATE-------------------
--Question 1 

--select track_id, track.name from dbo.track join dbo.genre
--on track.genre_id = genre.genre_id 
--where genre.name = 'Rock'
--order by track.name asc

select distinct email,last_name, first_name  from dbo.customer
join dbo.invoice 
on invoice.customer_id = customer.customer_id
join invoice_line on
invoice.invoice_id = invoice_line.invoice_id
where invoice_line.track_id in
	(select track_id from dbo.track
	join genre on
	genre.genre_id= track.genre_id
	where genre.name = 'Rock')
order by email asc

--Question 2--
select distinct t.genre_id,t.album_id,g.name from track  t
join genre g
on t.genre_id = g.genre_id
where g.name like 'Rock'
select * from dbo.artist

SELECT top 10 artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id, artist.name
ORDER BY number_of_songs DESC
;

--Question 3--
select name, milliseconds from dbo.track 
where milliseconds> 
	(select AVG(milliseconds) from dbo.track)
	order by milliseconds desc

--Advance--
--question 1--
--the with clause here helps us with creating a temporary table also known as CT common table expression
WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY artist.artist_id, artist.name
	)
SELECT top 1 c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.artist_name
ORDER BY amount_spent DESC;

--select top 4 artist.artist_id,artist.name,SUM(il.unit_price*il.quantity) as total_spent from dbo.invoice_line as il
--join track ON track.track_id = il.track_id
--join album on album.album_id = track.album_id
--join artist on artist.artist_id = album.artist_id
--group by artist.artist_id, artist.name
--order by total_spent desc

--question 2--
WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY customer.country, genre.name, genre.genre_id
	
)
SELECT * FROM popular_genre WHERE RowNo <= 1 ORDER BY purchases DESC

--Question 3--

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY customer.customer_id,first_name,last_name,billing_country)
SELECT * FROM Customter_with_country WHERE RowNo <= 1 ORDER BY total_spending DESC

-------------------------------------------------------------------------------------------------------------
select patients.first_name , patients.last_name, province_names.province_name from patients
join province_names on patients.province_id = province_names.province_id
select count(*) from patients where birth_date like '2010%'
SELECT COUNT(*) AS total_patients
FROM patients
WHERE YEAR(birth_date) = 2010;
select first_name, last_name, height from patients where height in(select max(height) from patients)
/*or 
SELECT
  first_name,
  last_name,
  MAX(height) AS height
FROM patients;*/
select * from patients where patient_id in (1,45,534,879,1000)
select count(*) from admissions
select* from admissions where admission_date = discharge_date
select count(*) as total_no_of_admissions, patient_id from admissions where patient_id ='579'
select * from patients where province_id like 'ns'group by city
select distinct city from patients where province_id like 'ns'
select first_name, last_name, birth_date from patients where height> 160 and weight >70
select first_name,last_name,allergies from patients where allergies is not null and city like 'hamilton'
/*medium questions*/
select distinct(year(birth_date)) as Distinct_Dates from patients order by Distinct_Dates asc
select first_name from patients group by first_name having count(first_name) =1


SELECT
  COUNT(*) AS patients_in_group,
  FLOOR(weight / 10) * 10 AS weight_group
FROM patients
GROUP BY weight_group
ORDER BY weight_group DESC;
SELECT
  ROUND(weight, -1) AS weight_group,
  COUNT(*) AS total_patients
FROM
  patients
GROUP BY
  weight_group
ORDER BY
  weight_group DESC;
select first_name  from patients order by length(first_name), first_name
select * from patients
SELECT
  COUNT(CASE WHEN gender like 'm' THEN 1 END) AS male_count,
  COUNT(CASE WHEN gender like 'f' THEN 1 END) AS female_count
FROM patients;
select 
	sum(gender ='M') as male_count,
    sum(gender = 'F') as female_count
    from patients
select first_name, last_name,allergies from patients where allergies in('Morphine','Penicillin') order by allergies , first_name, last_name

select * from admissions
select patient_id, diagnosis from admissions
group by patient_id, diagnosis
having count(*) >1

select city, count(*) as total_number from patients group by city order by total_number desc, city asc
select first_name,last_name , 'Patient' as role from patients 
	union all
    select first_name, last_name, 'Doctor' from doctors
select allergies, count(*) as total_diagnosis from patients 
where allergies is not null
	group by allergies 
	order by total_diagnosis desc and allergies not null
                                           















 