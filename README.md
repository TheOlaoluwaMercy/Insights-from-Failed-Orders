# Insights-from-Failed-Orders
This project involves the analysis and exploration of failed orders, with a specific focus on understanding orders cancelled by the client (excluding those cancelled by the system). The goal is to uncover what, when, and where these cancellations are happening.
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
etyk'l









