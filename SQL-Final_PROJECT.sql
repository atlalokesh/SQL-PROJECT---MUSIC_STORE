create database MUSIC_STORE;
use MUSIC_STORE;

-- 1. Genre
CREATE TABLE Genre (
	genre_id INT PRIMARY KEY auto_increment,
	name VARCHAR(120)
);
-- 2. MediaType
CREATE TABLE MediaType (
	media_type_id INT PRIMARY KEY auto_increment,
	name VARCHAR(120)
);
-- 3. Employee
CREATE TABLE Employee (
	employee_id INT PRIMARY KEY auto_increment,
	last_name VARCHAR(120),
	first_name VARCHAR(120),
	title VARCHAR(120),
	reports_to int,
  levels VARCHAR(255),
	birthdate DATE,
	hire_date DATE,
	address VARCHAR(255),
	city VARCHAR(100),
	state VARCHAR(100),
	country VARCHAR(100),
	postal_code VARCHAR(20),
	phone VARCHAR(50),
	fax VARCHAR(50),
	email VARCHAR(100)
);
-- 4. Customer
CREATE TABLE Customer (
	customer_id INT PRIMARY KEY auto_increment,
	first_name VARCHAR(120),
	last_name VARCHAR(120),
	company VARCHAR(120),
	address VARCHAR(255),
	city VARCHAR(100),
	state VARCHAR(100),
	country VARCHAR(100),
	postal_code VARCHAR(20),
	phone VARCHAR(50),
	fax VARCHAR(50),
	email VARCHAR(100),
	support_rep_id INT,
	FOREIGN KEY (support_rep_id) REFERENCES Employee(employee_id)
);
-- 5. Artist
CREATE TABLE Artist (
	artist_id INT PRIMARY KEY auto_increment,
	name VARCHAR(120)
);
-- 6. Album
CREATE TABLE Album (
	album_id INT PRIMARY KEY auto_increment,
	title VARCHAR(160),
	artist_id INT,
	FOREIGN KEY (artist_id) REFERENCES Artist(artist_id)
);
-- 7. Track
CREATE TABLE Track (
	track_id INT PRIMARY KEY auto_increment,
	name VARCHAR(200),
	album_id INT,
	media_type_id INT,
	genre_id INT,
	composer VARCHAR(220),
	milliseconds INT,
	bytes INT,
	unit_price DECIMAL(10,2),
	FOREIGN KEY (album_id) REFERENCES Album(album_id),
	FOREIGN KEY (media_type_id) REFERENCES MediaType(media_type_id),
	FOREIGN KEY (genre_id) REFERENCES Genre(genre_id)
);
-- 8. Invoice
CREATE TABLE Invoice (
	invoice_id INT PRIMARY KEY auto_increment,
	customer_id INT,
	invoice_date DATE,
	billing_address VARCHAR(255),
	billing_city VARCHAR(100),
	billing_state VARCHAR(100),
	billing_country VARCHAR(100),
	billing_postal_code VARCHAR(20),
	total DECIMAL(10,2),
	FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);
-- 9. InvoiceLine
CREATE TABLE InvoiceLine (
	invoice_line_id INT PRIMARY KEY auto_increment,
	invoice_id INT,
	track_id INT,
	unit_price DECIMAL(10,2),
	quantity INT,
	FOREIGN KEY (invoice_id) REFERENCES Invoice(invoice_id),
	FOREIGN KEY (track_id) REFERENCES Track(track_id)
);
-- 10. Playlist
CREATE TABLE Playlist (
 	playlist_id INT PRIMARY KEY auto_increment,
	name VARCHAR(255)
);
-- 11. PlaylistTrack
CREATE TABLE PlaylistTrack (
	playlist_id INT,
	track_id INT,
	PRIMARY KEY (playlist_id, track_id),
	FOREIGN KEY (playlist_id) REFERENCES Playlist(playlist_id),
	FOREIGN KEY (track_id) REFERENCES Track(track_id)
);

SHOW VARIABLES LIKE 'secure_file_priv';
LOAD DATA infile  'C:\Users\ADMIN\Downloads\track.csv'
INTO TABLE  track
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(track_id, name, album_id, media_type_id, genre_id, composer, milliseconds, bytes, unit_price);

select * from Genre;
select * from MediaType;
select * from Employee;
select * from Customer;
select * from Artist;
select * from Album;
select * from Track;
select * from Invoice;
select * from InvoiceLine;
select * from Playlist;
select * from PlaylistTrack;   

drop database music_store;
SET SQL_SAFE_UPDATES = 0;

-- 1. Who is the senior most employee based on job title? 
select*from employee;
SELECT 
    CONCAT(last_name, ' ', first_name) AS senior_most_employee,TITLE
FROM
    employee
ORDER BY hire_date ASC;

-- 2, Which countries have the most Invoices?
select*from customer;
select*from invoice;
SELECT 
    country, COUNT(*) AS most_invoices
FROM
    customer
        INNER JOIN
    invoice USING (customer_id)
GROUP BY country
ORDER BY most_invoices DESC;
------ or
SELECT 
    billing_country, COUNT(*) AS most_invoices
FROM
    invoice
GROUP BY billing_country
ORDER BY most_invoices DESC;

-- 3. What are the top 3 values of total invoice?
select * from Invoice;
SELECT 
    billing_country, MAX(total) AS top3
FROM
    invoice
GROUP BY billing_country
ORDER BY top3 DESC;
--- or
SELECT 
    *
FROM
    invoice
ORDER BY total DESC
LIMIT 3 OFFSET 2;

-- 4. Which city has the best customers? - We would like to throw a promotional Music Festival in the city we made the most money. 
-- Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals
select* from customer;
select* from invoice;
SELECT 
    city, SUM(total) AS best_customers
FROM
    customer
        INNER JOIN
    invoice USING (customer_id)
GROUP BY city
ORDER BY best_customers DESC;
--- or
SELECT 
    billing_city, SUM(total) AS best_customers_city
FROM
    invoice
GROUP BY billing_city
ORDER BY best_customers_city DESC
LIMIT 1;

-- 5. Who is the best customer? - The customer who has spent the most money will be declared the best customer.
-- Write a query that returns the person who has spent the most money
select * from customer;
select*from invoice;
SELECT 
    customer_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    SUM(total) AS spent_most_money
FROM
    customer
        INNER JOIN
    invoice USING (customer_id)
GROUP BY customer_id , full_name
ORDER BY spent_most_money DESC;
-- or
SELECT 
    (SELECT 
            CONCAT(First_Name, ' ', Last_Name)
        FROM
            customer
        WHERE
            customer.Customer_Id = invoice.Customer_Id) AS full_name,
    SUM(Total) AS spent_most_money
FROM
    invoice
GROUP BY Customer_Id
ORDER BY spent_most_money DESC
LIMIT 1;

-- 6. Write a query to return the email, first name, last name, & Genre of all Rock Music listeners.
-- Return your list ordered alphabetically by email starting with A
select*from customer;
select*from genre;
SELECT DISTINCT
    c.Email, c.First_Name, c.Last_Name, g.Name AS Genre
FROM
    Customer c
        JOIN
    Invoice i ON c.Customer_Id = i.Customer_Id
        JOIN
    InvoiceLine il ON i.Invoice_Id = il.Invoice_Id
        JOIN
    Track t ON il.Track_Id = t.Track_Id
        JOIN
    Genre g ON t.Genre_Id = g.Genre_Id
WHERE
    g.Name LIKE 'Rock%'
        AND c.Email LIKE 'A%'
ORDER BY c.Email ASC;

-- 7. Let's invite the artists who have written the most rock music in our dataset.
 -- Write a query that returns the Artist name and total track count of the top 10 rock bands 
select*from artist;
select*from album;
select*from track;
select*from genre;

SELECT 
    genre.name AS Artist_Name,
    COUNT(track.track_id) AS Track_count
FROM
    artist
        INNER JOIN
    album USING (artist_id)
        INNER JOIN
    track USING (album_id)
        INNER JOIN
    genre USING (genre_id)
WHERE
    genre.name LIKE '%ROCK%'
GROUP BY Artist_name
ORDER BY Track_count DESC;


-- 8. Return all the track names that have a song length longer than the average song length.- 
-- Return the Name and Milliseconds for each track. Order by the song length, with the longest songs listed first
select * from track;
SELECT 
    name, milliseconds AS song_length
FROM
    track
WHERE
    milliseconds > (SELECT 
            AVG(milliseconds)
        FROM
            track)
ORDER BY song_length DESC;


-- 9. Find how much amount is spent by each customer on artists? Write a query to return customer name, artist name and total spent 
select*from customer;
select*from invoice;
select*from invoiceline;
select*from track;
select*from album;
select*from artist;

   SELECT 
    CONCAT(first_name, ' ', last_name) AS customer_name,
    artist.name AS artist_name,
    SUM(total) AS total_spent
FROM
    customer
        INNER JOIN
    invoice USING (customer_id)
        INNER JOIN
    invoiceline USING (invoice_id)
        INNER JOIN
    track USING (track_id)
        INNER JOIN
    album USING (album_id)
        INNER JOIN
    artist USING (artist_id)
GROUP BY customer_name , artist_name;

-- 10. We want to find out the most popular music Genre for each country. 
-- We determine the most popular genre as the genre with the highest amount of purchases.
-- Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared, return all Genres
select*from customer;
select*from genre;
select*from invoice;
select*from invoiceline;
select*from track;

SELECT 
    customer.country, MAX(total) AS mostpopular__genre
FROM
    customer
        INNER JOIN
    invoice USING (customer_id)
        INNER JOIN
    invoiceline USING (invoice_id)
        INNER JOIN
    track USING (track_id)
        INNER JOIN
    genre USING (genre_id)
GROUP BY customer.country
ORDER BY mostpopular__genre DESC;

-- 11. Write a query that determines the customer that has spent the most on music for each country.
--  Write a query that returns the country along with the top customer and how much they spent.
 -- For countries where the top amount spent is shared, provide all customers who spent this amount
select*from customer;
select*from invoice;
SELECT 
    CONCAT(first_name, ' ', last_name) AS Customers,
    country,
    SUM(total) AS mostamount_spenton_music
FROM
    customer
        INNER JOIN
    invoice USING (customer_id)
GROUP BY customers , country
ORDER BY mostamount_spenton_music DESC;
