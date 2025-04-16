# Insights-from-Failed-Orders
This project involves the analysis and exploration of failed orders of a taxi hailing company, with a specific focus on understanding orders cancelled by the client (excluding those cancelled by the system). The goal is to uncover what, when, and where these cancellations are happening.
## The following questions would be answered:
1. Understanding Failed Orders
    - How many total failed orders occurred?
    - Who cancelled the orders — client or system?
    - What is the proportion of each cancellation type?
2.  When Do Client-Cancelled Orders Happen?
    - What hours of the day has the highest client cancellations?
    - How do cancellations vary across parts of the day (morning, afternoon, evening, night)?
3. Where Do Client-Cancelled Orders Occur?
    - Which addresses have the most client-cancelled orders?
    - Which cities show the highest number of failed orders?
4. How Does Time Influence Cancellations?
    - What is the average ETA (Estimated Time of Arrival) at the time of order?
    - How long (in seconds) before the client cancels the order?
5. Do clients tend to cancel before a driver is assigned or after?
## Analysis and Report
### Understanding Failed Orders
A total of 10,716 orders failed, the majority of which were cancelled by the clients. 7,307 orders (representing 68.2%) were cancelled by clients, while 3,409 orders (or 31.8%) were cancelled by the system.

How many total failed orders occurred?

> **10716** failed orders were recorded.
<details>
  <summary>View Code</summary>
  
  ```sql
  SELECT COUNT(*) AS total_failed_orders
  FROM orders;
  ```
</details>

Who cancelled the orders — client or system?
| order_status            | failed_order |
|-------------------------|--------------|
| cancelled by client     | 7307         |
| cancelled by system     | 3409         |
<details>
  <summary>View Code</summary>
  
  ```sql
 SELECT 
    CASE    
        WHEN order_status_key = 4 THEN 'cancelled by client'
        WHEN order_status_key = 9 THEN 'cancelled by system'
    END AS order_status,
    COUNT(*) AS failed_order
FROM orders
GROUP BY 
    CASE    
        WHEN order_status_key = 4 THEN 'cancelled by client'
        WHEN order_status_key = 9 THEN 'cancelled by system'
    END;
  ```
</details>
What is the proportion of each cancellation type?

| order_status            | percentage_of_total |
|-------------------------|---------------------|
| cancelled by client     | 68.20               |
| cancelled by system     | 31.80               |
<details>
  <summary>View Code</summary>
  
  ```sql
SELECT 
    CASE    
        WHEN order_status_key = 4 THEN 'cancelled by client'
        WHEN order_status_key = 9 THEN 'cancelled by system'
    END AS order_status,
	ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders), 1) AS percentage_of_total
FROM orders
GROUP BY 
    CASE    
        WHEN order_status_key = 4 THEN 'cancelled by client'
        WHEN order_status_key = 9 THEN 'cancelled by system'
    END;
  ```
</details>

### Focusing on orders cancelled by clients
The rest of the analysis narrows down to orders that were cancelled by client. For ease of accessing this subset of the data, a VIEW called orders_client_cancelled was created. 

<details>
  <summary>View Code</summary>
  
  ```sql
CREATE VIEW orders_client_cancelled AS SELECT *
FROM orders
WHERE order_status_key = 4;
  ```
</details>

###  When Do Client-Cancelled Failed Orders Happen?
Evenings recorded the highest proportion of failed orders at 31.3%, while afternoons had the lowest at 17.3%. The hourly trend chart showed noticeable spikes at 8:00 AM, 5:00 PM, 9:00 PM, 10:00 PM, and 11:00 PM — key hours when people are commuting to work or school in the morning, and returning home, attending social events, or heading out for the night in the evening.

What hour of the day has the highest client cancellations?


![hourly trend](https://github.com/user-attachments/assets/147072b3-6b9b-4f5c-a771-2dbf06d17b2a)

<details>
  <summary>View Code</summary>
  
  ```sql
SELECT 
	DATEPART(HOUR, order_time) AS order_hour,
	COUNT(*) AS failed_orders
FROM orders_client_cancelled
GROUP BY DATEPART(HOUR, order_time)
ORDER BY DATEPART(HOUR, order_time);
  ```
</details>
How do cancellations vary across parts of the day (morning, afternoon, evening, night)?

![timeofday](https://github.com/user-attachments/assets/67ffdcdc-ac58-4bdd-92ca-7d5ed68bc938)


<details>
  <summary>View Code</summary>
  
  ```sql
SELECT 
	CASE WHEN DATEPART(HOUR, order_time) BETWEEN 5 AND 11 THEN 'Morning'
		 WHEN DATEPART(HOUR, order_time) BETWEEN 12 AND 16 THEN 'Afternoon'
		 WHEN DATEPART(HOUR, order_time) BETWEEN 17 AND 22 THEN 'Evening'
		 ELSE 'Night'
		 END AS 'time_of_day',
	COUNT(*) AS failed_orders
FROM orders_client_cancelled
GROUP BY CASE WHEN DATEPART(HOUR, order_time) BETWEEN 5 AND 11 THEN 'Morning'
		 WHEN DATEPART(HOUR, order_time) BETWEEN 12 AND 16 THEN 'Afternoon'
		 WHEN DATEPART(HOUR, order_time) BETWEEN 17 AND 22 THEN 'Evening'
		 ELSE 'Night'
		 END;
  ```
</details>

### Where Do Client-Cancelled Failed Orders Occur?
> Out of 10,716 failed orders, there were over 4,000 unique coordinates. These were grouped into 125 distinct location clusters through coordinate rounding and spatial grouping. Reverse geocoding was then applied to extract meaningful location details such as address, district, suburb, and city.

Which addresses have the most client-cancelled orders?
The top 5 addresses clusters where failed orders originates from are: 
| Address                                                                | Failed Orders |
|------------------------------------------------------------------------|---------------|
| Reading Railway Station Car Park, Trooper Potts Way, Reading          | 950           |
| 86 Southampton Street, Reading                                         | 814           |
| 98 Blenheim Road, Reading                                              | 652           |
| University of Reading, London Road Campus, Acacia Road, Reading       | 578           |
| 259 Chancellors Building, Chancellors Way, Reading                    | 423           |

<details>
  <summary>View Code</summary>
  
  ```sql
SELECT 
    CAST(location.Adress AS NVARCHAR(MAX)) AS Adress,
    COUNT(*) AS failed_orders
FROM orders_client_cancelled
LEFT JOIN location
    ON ROUND(orders_client_cancelled.origin_latitude, 2) = location.latitude 
    AND ROUND(orders_client_cancelled.origin_longitude, 2) = location.longitude
GROUP BY CAST(location.Adress AS NVARCHAR(MAX))
ORDER BY COUNT(*) DESC;
  ```
</details>

Which city has the highest number of failed orders?
> **Reading**  recorded the highest number(96%) of failed orders

| City                  | Failed Orders |
|-----------------------|---------------|
| Reading               | 7048          |
| Shinfield             | 63            |
| Woodley               | 49            |
| Sindlesham            | 28            |
| Holybrook             | 24            |
| Sonning               | 21            |
| Mapledurham           | 14            |
| Purley on Thames      | 13            |
| South Oxfordshire     | 13            |
| Three Mile Cross      | 11            |
| Burghfield            | 7             |
| Tilehurst             | 5             |
| Theale                | 4             |
| Eye and Dunsden       | 4             |
| Winnersh              | 1             |
| St. Nicholas, Hurst   | 1             |
| Charvil               | 1             |

<details>
  <summary>View Code</summary>
  
  ```sql
SELECT 
	CAST(location.city AS NVARCHAR(MAX)) AS city,
    COUNT(*) AS failed_orders
FROM orders_client_cancelled
LEFT JOIN location
    ON ROUND(orders_client_cancelled.origin_latitude, 2) = location.latitude 
    AND ROUND(orders_client_cancelled.origin_longitude, 2) = location.longitude
GROUP BY CAST(location.city AS NVARCHAR(MAX)) 
ORDER BY COUNT(*) DESC;
  ```
</details>
























