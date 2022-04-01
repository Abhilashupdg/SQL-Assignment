Q1. Write an SQL query to report the managers with atleast five direct reports.

Solution:
SELECT name FROM Employee WHERE Id IN
(SELECT ManagerId from Employee GROUPBY ManagerId
HAVING COUNT(ManagerId) >= 5);





Q2. Write an SQL query to report the nth highest salary from the Employee table. If there is no
nth highest salary, the query should report null.

Solution:
CREATE FUNCTION getnthhighestSalary(N INT) RETURNS INT
BEGIN
SET N = N-1;
RETURNS (
    SELECT salary from Employee ORDER BY salary DESC
    LIMIT 1 OFFSET N
)
END;




Q3. Write an SQL query to find the people who have the most friends and the most friends number.

Solution:
SELECT id, count(id) as num
FROM 
(
    SELECT requester_id as id FROM RequestAccepted
    UNION ALL
    SELECT accepter_id as id from RequestAccepted
) as total_table
GROUPBY id,
ORDER BY COUNT(id) DESC
LIMIT 1;




Q4. Write an SQL query to swap the seat id of every two consecutive students. If the number of 
students is odd, the id of the last student is not swapped.

Solution:
SELECT
(CASE WHEN (SELECT max(id)%2 = 1) AND id = (SELECT MAX(id) FROM seat) then id
WHEN id%2 = 1 THEN id + 1
ELSE id - 1
END) AS id, name
FROM seat
ORDER BY id;





Q5. Write an SQL query to report the customer ids from the Customer table that bought all the
products in the Product table.

Solution:
SELECT customer_id
FROM customer
GROUP BY customer_id
HAVING count(distinct product_key) = (SELECT COUNT(*) FROM products);




Q6. Write an SQL query to find for each user, the join date and the number of orders they made
as a buyer in 2019.

Solution:
SELECT u.user_id as buyer_id, u.join_date, SUM(CASE WHEN YEAR(order_date) = 2019 THEN 1 ELSE 0 END) as orders_in_2019
FROM users u LEFT JOIN orders o
ON u.user_id = o.buyer_id
GROUP BY u.user_id, u.join_date;




Q7. Write an SQL query to reports for every date within at most 90 days from today, the
number of users that logged in for the first time on that date. Assume today is 2019-06-30.

Solution:
SELECT login_date, COUNT(*) as user_count
FROM(
    SELECT  user_id, min(activity_date) AS login_date
    FROM Traffic
    WHERE activity = 'login'
    GROUPBY user_id
)
WHERE login_date >= DATE_ADD('2019-06-30', INTERVAL 90 DAY);




Q8. Write an SQL query to find the prices of all products on 2019-08-16. Assume the price of all
products before any change is 10.

Solution:
SELECT *
FROM
(SELECT product_id, new_price AS price
FROM product
WHERE (product_id, change_date) IN (
SELECT product_id, MAX(change_date)
FROM product
WHERE change_date <= '2019-08-16'
GROUP BY product_id)

UNION

SELECT DISTINCT product_id, 10 AS price
FROM product
WHERE product_id NOT IN (SELECT product_id from product WHERE change_date <= '2019-08-16')) AS new_tab
ORDER BY price DESC;



Q9. Write an SQL query to find for each month and country: the number of approved
transactions and their total amount, the number of chargebacks, and their total amount.


Solution:
SELECT month, country, SUM(if(state='approved',1,0)) AS approved_count,
SUM(if(state='approved', amount,0)) as approved_amount,
SUM(if(state='chargeback', 1,0)) as chargeback_count,
SUM(if(state='chargeback', amount,0)) as chargeback_amount
FROM ((
SELECT date_format(trans_date, '%Y-%m') as month, country, amount, 'approved' as state
FROM transactions
WHERE state = 'approved')

UNION (

SELECT date_format(chargebacks.trans_date, '%Y-%m') as month, country, amount, 'chargeback' as state
FROM transactions 
INNER JOIN chargebacks
ON transactions.id = chargebacks.trans_id)) AS tr_tab
GROUP BY tr_tab.month, tr_tab.country;



Q10. Write an SQL query that selects the team_id, team_name and num_points of each team in
the tournament after all described matches.

Solution:
SELECT team_id, team_name,
SUM(IF(team_id = host_team AND host_goals > guest_goals, 3,0)) +
SUM(IF(team_id = guest_team AND guest_goals > host_goals, 3,0)) +
SUM(IF(team_id = host_team AND host_goals = guest_goals, 1,0)) +
IF(team_id = guest_team AND guest_goals = host_goals, 1,0) AS num_points
FROM Teams
LEFT JOIN Matches
ON Teams.team_id = Matches.host_team OR Teams.team_id = Matches.guest_team
GROUPBY team_id
ORDER BY num_points DESC, team_id ASC;
