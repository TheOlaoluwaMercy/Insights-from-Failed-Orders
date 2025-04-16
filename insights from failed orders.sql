--How many total failed orders occurred?
SELECT COUNT(*) AS total_falied_orders
FROM orders;

--Who cancelled the orders — client or system?
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

--What is the proportion of each cancellation type?
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



/* The rest of the analysis narrows down to orders that were cancelled by client. 
For ease of accessing this subset of the data, a VIEW called orders_client_cancelled was created. */

CREATE VIEW orders_client_cancelled AS SELECT *
FROM orders
WHERE order_status_key = 4;

--What hour of the day has the highest client cancellations?
SELECT 
	DATEPART(HOUR, order_time) AS order_hour,
	COUNT(*) AS failed_orders
FROM orders_client_cancelled
GROUP BY DATEPART(HOUR, order_time)
ORDER BY DATEPART(HOUR, order_time);

--How do cancellations vary across parts of the day (morning, afternoon, evening, night)?
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

--Which addresses have the most client-cancelled orders?
SELECT 
    CAST(location.Adress AS NVARCHAR(MAX)) AS Adress,
    COUNT(*) AS failed_orders
FROM orders_client_cancelled
LEFT JOIN location
    ON ROUND(orders_client_cancelled.origin_latitude, 2) = location.latitude 
    AND ROUND(orders_client_cancelled.origin_longitude, 2) = location.longitude
GROUP BY CAST(location.Adress AS NVARCHAR(MAX))
ORDER BY COUNT(*) DESC;

--Which city has the highest number of failed orders?
SELECT 
	CAST(location.city AS NVARCHAR(MAX)) AS city,
    COUNT(*) AS failed_orders
FROM orders_client_cancelled
LEFT JOIN location
    ON ROUND(orders_client_cancelled.origin_latitude, 2) = location.latitude 
    AND ROUND(orders_client_cancelled.origin_longitude, 2) = location.longitude
GROUP BY CAST(location.city AS NVARCHAR(MAX)) 
ORDER BY COUNT(*) DESC;

---how long does it take to reach our clients
--Descriptive analysis of Drive ETA(min)
SELECT 
	ROUND( CAST(MAX(m_order_eta) AS FLOAT)/60, 2) AS max_eta,
	ROUND( CAST( MIN(m_order_eta) AS FLOAT)/60, 2) AS min_eta,
	ROUND( CAST( AVG(m_order_eta) AS FLOAT) /60, 2) AS avg_eta
FROM orders_client_cancelled;

--Failed orders by ETA group
SELECT CASE
			WHEN m_order_eta BETWEEN 0 AND 600 THEN '0 - 10 min'
			WHEN m_order_eta BETWEEN 601 AND 1200 THEN '11 - 20 min'
			WHEN m_order_eta BETWEEN 1201 AND 1800 THEN '21 - 30 min'
			END AS ETA,
		COUNT(*) AS failed_orders
FROM orders_client_cancelled
GROUP BY CASE
			WHEN m_order_eta BETWEEN 0 AND 600 THEN '0 - 10 min'
			WHEN m_order_eta BETWEEN 601 AND 1200 THEN '11 - 20 min'
			WHEN m_order_eta BETWEEN 1201 AND 1800 THEN '21 - 30 min'
			END
ORDER BY CASE
			WHEN m_order_eta BETWEEN 0 AND 600 THEN '0 - 10 min'
			WHEN m_order_eta BETWEEN 601 AND 1200 THEN '11 - 20 min'
			WHEN m_order_eta BETWEEN 1201 AND 1800 THEN '21 - 30 min'
			END;

--How long (min) before the client cancels the order?
SELECT ROUND(CAST(MAX(cancellations_time_in_seconds) AS FLOAT)/60, 2) AS max_cancellation_time,
	   ROUND(CAST(MIN(cancellations_time_in_seconds) AS FLOAT)/60,2) AS min_cancellation_time,
	   ROUND(CAST(AVG(cancellations_time_in_seconds) AS FLOAT)/60,2) AS AVG_cancellation_time
FROM orders_client_cancelled;

--Do clients tend to cancel before a driver is assigned or after?
SELECT 
	CASE WHEN is_driver_assigned_key = 1 THEN 'Yes'
		 WHEN is_driver_assigned_key = 0 THEN 'No'
	END as driver_assigned, 
	COUNT(*) as failed_count
FROM orders_client_cancelled
GROUP BY is_driver_assigned_key;