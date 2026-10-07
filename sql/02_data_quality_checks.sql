-- =========================================================
-- E-Commerce Sales & Customer Intelligence
-- Data Quality & Relationship Checks
-- MySQL 8+
-- =========================================================

USE final_project_ecommerce;

-- ---------------------------------------------------------
-- 1. Table row counts
-- ---------------------------------------------------------

SELECT 'Customers' AS TableName, COUNT(*) AS RowCount
FROM Customers
UNION ALL
SELECT 'Orders', COUNT(*)
FROM Orders
UNION ALL
SELECT 'OrderDetails', COUNT(*)
FROM OrderDetails
UNION ALL
SELECT 'Products', COUNT(*)
FROM Products
UNION ALL
SELECT 'Regions', COUNT(*)
FROM Regions;


-- ---------------------------------------------------------
-- 2. Order date coverage
-- ---------------------------------------------------------

SELECT
    MIN(OrderDate) AS MinOrderDate,
    MAX(OrderDate) AS MaxOrderDate,
    DATEDIFF(MAX(OrderDate), MIN(OrderDate)) AS DateSpanDays
FROM Orders;


-- ---------------------------------------------------------
-- 3. Returned vs non-returned orders
-- ---------------------------------------------------------

SELECT
    IsReturned,
    COUNT(*) AS OrderCount,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM Orders),
        2
    ) AS Percentage
FROM Orders
GROUP BY IsReturned;


-- ---------------------------------------------------------
-- 4. Orders with and without line-item details
-- ---------------------------------------------------------

SELECT
    COUNT(DISTINCT o.OrderID) AS TotalOrders,
    COUNT(DISTINCT od.OrderID) AS OrdersWithDetails,
    COUNT(DISTINCT o.OrderID)
        - COUNT(DISTINCT od.OrderID) AS OrdersWithoutDetails,
    ROUND(
        100.0 * COUNT(DISTINCT od.OrderID)
        / COUNT(DISTINCT o.OrderID),
        2
    ) AS DetailCoveragePct
FROM Orders o
LEFT JOIN OrderDetails od
    ON o.OrderID = od.OrderID;


-- ---------------------------------------------------------
-- 5. Customers with and without orders
-- ---------------------------------------------------------

SELECT
    COUNT(DISTINCT c.CustomerID) AS TotalCustomers,
    COUNT(DISTINCT o.CustomerID) AS CustomersWithOrders,
    COUNT(DISTINCT c.CustomerID)
        - COUNT(DISTINCT o.CustomerID) AS CustomersWithoutOrders
FROM Customers c
LEFT JOIN Orders o
    ON c.CustomerID = o.CustomerID;


-- ---------------------------------------------------------
-- 6. Orphan OrderDetails -> Orders
-- Expected result: 0
-- ---------------------------------------------------------

SELECT COUNT(*) AS OrphanOrderDetails
FROM OrderDetails od
LEFT JOIN Orders o
    ON od.OrderID = o.OrderID
WHERE o.OrderID IS NULL;


-- ---------------------------------------------------------
-- 7. Orphan OrderDetails -> Products
-- Expected result: 0
-- ---------------------------------------------------------

SELECT COUNT(*) AS OrphanProductReferences
FROM OrderDetails od
LEFT JOIN Products p
    ON od.ProductID = p.ProductID
WHERE p.ProductID IS NULL;


-- ---------------------------------------------------------
-- 8. Orphan Orders -> Customers
-- Expected result: 0
-- ---------------------------------------------------------

SELECT COUNT(*) AS OrphanCustomerReferences
FROM Orders o
LEFT JOIN Customers c
    ON o.CustomerID = c.CustomerID
WHERE c.CustomerID IS NULL;
