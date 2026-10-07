USE final_project_ecommerce;

-- ============================================================
-- Q1. TOTAL GROSS REVENUE
-- ============================================================
-- Business definition:
-- Gross Revenue = Product Price × Quantity
-- Includes both returned and non-returned orders.
-- Revenue is measurable only for orders with OrderDetails.
-- ============================================================

SELECT
    ROUND(SUM(p.Price * od.Quantity), 2) AS GrossRevenue
FROM orderdetails AS od
INNER JOIN products AS p
    ON od.ProductID = p.ProductID;
    
    -- ============================================================
-- Q2. NET REVENUE EXCLUDING RETURNS
-- ============================================================
-- Net Revenue = revenue associated with non-returned orders.
-- IsReturned = 0 means the order was not returned.
-- ============================================================

SELECT
    ROUND(SUM(p.Price * od.Quantity), 2) AS NetRevenue
FROM orderdetails AS od
INNER JOIN products AS p
    ON od.ProductID = p.ProductID
INNER JOIN orders AS o
    ON od.OrderID = o.OrderID
WHERE o.IsReturned = 0;

-- ============================================================
-- Q3. GROSS REVENUE BY YEAR
-- ============================================================

SELECT
    YEAR(o.OrderDate) AS OrderYear,
    COUNT(DISTINCT o.OrderID) AS RevenueOrders,
    ROUND(SUM(p.Price * od.Quantity), 2) AS GrossRevenue
FROM orders AS o
INNER JOIN orderdetails AS od
    ON o.OrderID = od.OrderID
INNER JOIN products AS p
    ON od.ProductID = p.ProductID
GROUP BY
    YEAR(o.OrderDate)
ORDER BY
    OrderYear;
    
    -- ============================================================
-- Q4. MONTHLY GROSS REVENUE TREND
-- ============================================================

SELECT
    YEAR(o.OrderDate) AS OrderYear,
    MONTH(o.OrderDate) AS MonthNumber,
    MONTHNAME(o.OrderDate) AS OrderMonth,
    COUNT(DISTINCT o.OrderID) AS RevenueOrders,
    ROUND(SUM(p.Price * od.Quantity), 2) AS GrossRevenue
FROM orders AS o
INNER JOIN orderdetails AS od
    ON o.OrderID = od.OrderID
INNER JOIN products AS p
    ON od.ProductID = p.ProductID
GROUP BY
    YEAR(o.OrderDate),
    MONTH(o.OrderDate),
    MONTHNAME(o.OrderDate)
ORDER BY
    OrderYear,
    MonthNumber;
    
    
    
    -- ============================================================
-- Q5. REVENUE BY PRODUCT CATEGORY
-- ============================================================

WITH CategoryRevenue AS (
    SELECT
        p.Category,
        COUNT(DISTINCT p.ProductID) AS Products,
        SUM(od.Quantity) AS UnitsSold,
        SUM(p.Price * od.Quantity) AS GrossRevenue
    FROM orderdetails AS od
    INNER JOIN products AS p
        ON od.ProductID = p.ProductID
    GROUP BY
        p.Category
)

SELECT
    Category,
    Products,
    UnitsSold,
    ROUND(GrossRevenue, 2) AS GrossRevenue,
    ROUND(
        100.0 * GrossRevenue /
        SUM(GrossRevenue) OVER (),
        2
    ) AS RevenueSharePct
FROM CategoryRevenue
ORDER BY
    GrossRevenue DESC;
    
    
    -- ============================================================
-- Q6. OVERALL GROSS AVERAGE ORDER VALUE
-- ============================================================

WITH OrderTotals AS (
    SELECT
        od.OrderID,
        SUM(p.Price * od.Quantity) AS OrderRevenue
    FROM orderdetails AS od
    INNER JOIN products AS p
        ON od.ProductID = p.ProductID
    GROUP BY od.OrderID
)

SELECT
    COUNT(*) AS RevenueOrders,
    ROUND(SUM(OrderRevenue), 2) AS GrossRevenue,
    ROUND(AVG(OrderRevenue), 2) AS GrossAOV
FROM OrderTotals;


-- ============================================================
-- Q7. GROSS AVERAGE ORDER VALUE BY YEAR
-- ============================================================

WITH OrderTotals AS (
    SELECT
        o.OrderID,
        YEAR(o.OrderDate) AS OrderYear,
        SUM(p.Price * od.Quantity) AS OrderRevenue
    FROM orders AS o
    INNER JOIN orderdetails AS od
        ON o.OrderID = od.OrderID
    INNER JOIN products AS p
        ON od.ProductID = p.ProductID
    GROUP BY
        o.OrderID,
        YEAR(o.OrderDate)
)

SELECT
    OrderYear,
    COUNT(*) AS RevenueOrders,
    ROUND(SUM(OrderRevenue), 2) AS GrossRevenue,
    ROUND(AVG(OrderRevenue), 2) AS GrossAOV
FROM OrderTotals
GROUP BY OrderYear
ORDER BY OrderYear;


-- ============================================================
-- Q8. MONTHLY GROSS AVERAGE ORDER VALUE
-- ============================================================

WITH OrderTotals AS (
    SELECT
        o.OrderID,
        YEAR(o.OrderDate) AS OrderYear,
        MONTH(o.OrderDate) AS MonthNumber,
        MONTHNAME(o.OrderDate) AS OrderMonth,
        SUM(p.Price * od.Quantity) AS OrderRevenue
    FROM orders AS o
    INNER JOIN orderdetails AS od
        ON o.OrderID = od.OrderID
    INNER JOIN products AS p
        ON od.ProductID = p.ProductID
    GROUP BY
        o.OrderID,
        YEAR(o.OrderDate),
        MONTH(o.OrderDate),
        MONTHNAME(o.OrderDate)
)

SELECT
    OrderYear,
    MonthNumber,
    OrderMonth,
    COUNT(*) AS RevenueOrders,
    ROUND(SUM(OrderRevenue), 2) AS GrossRevenue,
    ROUND(AVG(OrderRevenue), 2) AS GrossAOV
FROM OrderTotals
GROUP BY
    OrderYear,
    MonthNumber,
    OrderMonth
ORDER BY
    OrderYear,
    MonthNumber;
    
    
    -- ============================================================
-- Q9. AVERAGE ORDER SIZE BY REGION
-- ============================================================

WITH OrderTotals AS (
    SELECT
        o.OrderID,
        r.RegionName,
        r.Country,
        SUM(od.Quantity) AS UnitsPerOrder,
        SUM(p.Price * od.Quantity) AS OrderRevenue
    FROM orders AS o
    INNER JOIN customers AS c
        ON o.CustomerID = c.CustomerID
    INNER JOIN regions AS r
        ON c.RegionID = r.RegionID
    INNER JOIN orderdetails AS od
        ON o.OrderID = od.OrderID
    INNER JOIN products AS p
        ON od.ProductID = p.ProductID
    GROUP BY
        o.OrderID,
        r.RegionName,
        r.Country
)

SELECT
    RegionName,
    Country,
    COUNT(*) AS RevenueOrders,
    ROUND(AVG(UnitsPerOrder), 2) AS AvgUnitsPerOrder,
    ROUND(AVG(OrderRevenue), 2) AS GrossAOV,
    ROUND(SUM(OrderRevenue), 2) AS GrossRevenue
FROM OrderTotals
GROUP BY
    RegionName,
    Country
ORDER BY
    GrossAOV DESC;
    
    
    -- ============================================================
-- Q10. TOP 10 CUSTOMERS BY GROSS REVENUE
-- ============================================================

SELECT
    c.CustomerID,
    c.CustomerName,
    r.RegionName,
    r.Country,
    COUNT(DISTINCT o.OrderID) AS RevenueOrders,
    SUM(od.Quantity) AS UnitsPurchased,
    ROUND(SUM(p.Price * od.Quantity), 2) AS GrossRevenue
FROM customers AS c
INNER JOIN regions AS r
    ON c.RegionID = r.RegionID
INNER JOIN orders AS o
    ON c.CustomerID = o.CustomerID
INNER JOIN orderdetails AS od
    ON o.OrderID = od.OrderID
INNER JOIN products AS p
    ON od.ProductID = p.ProductID
GROUP BY
    c.CustomerID,
    c.CustomerName,
    r.RegionName,
    r.Country
ORDER BY
    GrossRevenue DESC
LIMIT 10;


-- ============================================================
-- Q11. REPEAT CUSTOMER RATE
-- ============================================================

WITH CustomerOrders AS (
    SELECT
        CustomerID,
        COUNT(*) AS OrderCount
    FROM orders
    GROUP BY CustomerID
)

SELECT
    COUNT(*) AS ActiveCustomers,
    SUM(CASE WHEN OrderCount > 1 THEN 1 ELSE 0 END)
        AS RepeatCustomers,
    SUM(CASE WHEN OrderCount = 1 THEN 1 ELSE 0 END)
        AS OneTimeCustomers,
    ROUND(
        100.0 *
        SUM(CASE WHEN OrderCount > 1 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS RepeatCustomerRatePct
FROM CustomerOrders;

-- ============================================================
-- Q12. AVERAGE DAYS BETWEEN CONSECUTIVE ORDERS BY REGION
-- ============================================================

WITH OrderSequence AS (
    SELECT
        o.CustomerID,
        c.RegionID,
        o.OrderID,
        o.OrderDate,

        LAG(o.OrderDate) OVER (
            PARTITION BY o.CustomerID
            ORDER BY o.OrderDate, o.OrderID
        ) AS PreviousOrderDate

    FROM orders AS o
    INNER JOIN customers AS c
        ON o.CustomerID = c.CustomerID
),

OrderGaps AS (
    SELECT
        CustomerID,
        RegionID,
        DATEDIFF(OrderDate, PreviousOrderDate) AS DaysBetweenOrders
    FROM OrderSequence
    WHERE PreviousOrderDate IS NOT NULL
)

SELECT
    r.RegionName,
    r.Country,
    COUNT(*) AS RepeatOrderIntervals,
    ROUND(AVG(og.DaysBetweenOrders), 2)
        AS AvgDaysBetweenOrders
FROM OrderGaps AS og
INNER JOIN regions AS r
    ON og.RegionID = r.RegionID
GROUP BY
    r.RegionID,
    r.RegionName,
    r.Country
ORDER BY
    AvgDaysBetweenOrders ASC;
    
    
    -- ============================================================
-- Q13. CUSTOMER SEGMENTATION BY HISTORICAL GROSS SPEND
-- ============================================================

WITH CustomerSpend AS (
    SELECT
        c.CustomerID,
        c.CustomerName,
        COALESCE(SUM(p.Price * od.Quantity), 0) AS GrossSpend
    FROM customers AS c
    LEFT JOIN orders AS o
        ON c.CustomerID = o.CustomerID
    LEFT JOIN orderdetails AS od
        ON o.OrderID = od.OrderID
    LEFT JOIN products AS p
        ON od.ProductID = p.ProductID
    GROUP BY
        c.CustomerID,
        c.CustomerName
),

CustomerSegments AS (
    SELECT
        CustomerID,
        CustomerName,
        GrossSpend,
        CASE
            WHEN GrossSpend > 1500 THEN 'Platinum'
            WHEN GrossSpend >= 1000 THEN 'Gold'
            WHEN GrossSpend >= 500 THEN 'Silver'
            ELSE 'Bronze'
        END AS CustomerSegment
    FROM CustomerSpend
)

SELECT
    CustomerSegment,
    COUNT(*) AS Customers,
    ROUND(SUM(GrossSpend), 2) AS GrossRevenue,
    ROUND(AVG(GrossSpend), 2) AS AvgCustomerSpend
FROM CustomerSegments
GROUP BY CustomerSegment
ORDER BY
    CASE CustomerSegment
        WHEN 'Platinum' THEN 1
        WHEN 'Gold' THEN 2
        WHEN 'Silver' THEN 3
        WHEN 'Bronze' THEN 4
    END;
    
    
 
-- ============================================================
-- Q14. HISTORICAL CUSTOMER LIFETIME VALUE PROXY
-- ============================================================
-- Historical value only; NOT predictive CLV.
--
-- RevenueOrders counts only orders with available line-item
-- details because only those orders have measurable revenue.
-- ============================================================

WITH CustomerValue AS (
    SELECT
        c.CustomerID,
        c.CustomerName,
        r.RegionName,
        r.Country,

        COUNT(DISTINCT od.OrderID) AS RevenueOrders,

        COALESCE(
            SUM(p.Price * od.Quantity),
            0
        ) AS HistoricalGrossRevenue

    FROM customers AS c

    INNER JOIN regions AS r
        ON c.RegionID = r.RegionID

    LEFT JOIN orders AS o
        ON c.CustomerID = o.CustomerID

    LEFT JOIN orderdetails AS od
        ON o.OrderID = od.OrderID

    LEFT JOIN products AS p
        ON od.ProductID = p.ProductID

    GROUP BY
        c.CustomerID,
        c.CustomerName,
        r.RegionName,
        r.Country
)

SELECT
    CustomerID,
    CustomerName,
    RegionName,
    Country,
    RevenueOrders,

    ROUND(
        HistoricalGrossRevenue,
        2
    ) AS HistoricalCLVProxy,

    ROUND(
        HistoricalGrossRevenue /
        NULLIF(RevenueOrders, 0),
        2
    ) AS CustomerAOV

FROM CustomerValue

ORDER BY
    HistoricalCLVProxy DESC

LIMIT 10;


-- ============================================================
-- Q15. TOP 10 PRODUCTS BY QUANTITY SOLD
-- ============================================================

SELECT
    p.ProductID,
    p.ProductName,
    p.Category,
    SUM(od.Quantity) AS UnitsSold,
    COUNT(DISTINCT od.OrderID) AS RevenueOrders,
    ROUND(SUM(p.Price * od.Quantity), 2) AS GrossRevenue
FROM products AS p
INNER JOIN orderdetails AS od
    ON p.ProductID = od.ProductID
GROUP BY
    p.ProductID,
    p.ProductName,
    p.Category
ORDER BY
    UnitsSold DESC,
    GrossRevenue DESC
LIMIT 10;


-- ============================================================
-- Q16. TOP 10 PRODUCTS BY GROSS REVENUE
-- ============================================================

SELECT
    p.ProductID,
    p.ProductName,
    p.Category,
    SUM(od.Quantity) AS UnitsSold,
    ROUND(p.Price, 2) AS UnitPrice,
    ROUND(SUM(p.Price * od.Quantity), 2) AS GrossRevenue
FROM products AS p
INNER JOIN orderdetails AS od
    ON p.ProductID = od.ProductID
GROUP BY
    p.ProductID,
    p.ProductName,
    p.Category,
    p.Price
ORDER BY
    GrossRevenue DESC
LIMIT 10;

-- ============================================================
-- Q17. PRODUCT RETURN RATE
-- ============================================================
-- Quantity Return Rate =
-- returned units / total units sold
-- ============================================================

SELECT
    p.ProductID,
    p.ProductName,
    p.Category,

    SUM(od.Quantity) AS UnitsSold,

    SUM(
        CASE
            WHEN o.IsReturned = 1
            THEN od.Quantity
            ELSE 0
        END
    ) AS ReturnedUnits,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN o.IsReturned = 1
                THEN od.Quantity
                ELSE 0
            END
        ) /
        NULLIF(SUM(od.Quantity), 0),
        2
    ) AS QuantityReturnRatePct

FROM products AS p

INNER JOIN orderdetails AS od
    ON p.ProductID = od.ProductID

INNER JOIN orders AS o
    ON od.OrderID = o.OrderID

GROUP BY
    p.ProductID,
    p.ProductName,
    p.Category

ORDER BY
    QuantityReturnRatePct DESC,
    UnitsSold DESC;
    
    
    -- ============================================================
-- Q18. RETURN RATE BY PRODUCT CATEGORY
-- ============================================================

SELECT
    p.Category,

    SUM(od.Quantity) AS UnitsSold,

    SUM(
        CASE
            WHEN o.IsReturned = 1
            THEN od.Quantity
            ELSE 0
        END
    ) AS ReturnedUnits,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN o.IsReturned = 1
                THEN od.Quantity
                ELSE 0
            END
        ) /
        NULLIF(SUM(od.Quantity), 0),
        2
    ) AS QuantityReturnRatePct,

    ROUND(
        SUM(
            CASE
                WHEN o.IsReturned = 1
                THEN p.Price * od.Quantity
                ELSE 0
            END
        ),
        2
    ) AS ReturnedRevenue

FROM orderdetails AS od

INNER JOIN products AS p
    ON od.ProductID = p.ProductID

INNER JOIN orders AS o
    ON od.OrderID = o.OrderID

GROUP BY
    p.Category

ORDER BY
    QuantityReturnRatePct DESC;
    
    
    -- ============================================================
-- Q19. WEIGHTED AVERAGE PRODUCT PRICE BY REGION
-- ============================================================
-- Weighted Avg Unit Price =
-- total gross revenue / total units purchased
-- ============================================================

SELECT
    r.RegionName,
    r.Country,
    SUM(od.Quantity) AS UnitsPurchased,

    ROUND(
        SUM(p.Price * od.Quantity) /
        NULLIF(SUM(od.Quantity), 0),
        2
    ) AS WeightedAvgUnitPrice

FROM regions AS r

INNER JOIN customers AS c
    ON r.RegionID = c.RegionID

INNER JOIN orders AS o
    ON c.CustomerID = o.CustomerID

INNER JOIN orderdetails AS od
    ON o.OrderID = od.OrderID

INNER JOIN products AS p
    ON od.ProductID = p.ProductID

GROUP BY
    r.RegionID,
    r.RegionName,
    r.Country

ORDER BY
    WeightedAvgUnitPrice DESC;
    
    
    -- ============================================================
-- Q20. MONTHLY CATEGORY REVENUE TREND
-- ============================================================

SELECT
    YEAR(o.OrderDate) AS OrderYear,
    MONTH(o.OrderDate) AS MonthNumber,
    MONTHNAME(o.OrderDate) AS OrderMonth,
    p.Category,

    SUM(od.Quantity) AS UnitsSold,

    ROUND(
        SUM(p.Price * od.Quantity),
        2
    ) AS GrossRevenue

FROM orders AS o

INNER JOIN orderdetails AS od
    ON o.OrderID = od.OrderID

INNER JOIN products AS p
    ON od.ProductID = p.ProductID

GROUP BY
    YEAR(o.OrderDate),
    MONTH(o.OrderDate),
    MONTHNAME(o.OrderDate),
    p.Category

ORDER BY
    OrderYear,
    MonthNumber,
    GrossRevenue DESC;
    
    -- ============================================================
-- Q21. AVERAGE ORDER VALUE BY DAY OF WEEK
-- ============================================================

WITH OrderTotals AS (
    SELECT
        o.OrderID,
        DAYOFWEEK(o.OrderDate) AS DayNumber,
        DAYNAME(o.OrderDate) AS DayName,
        SUM(p.Price * od.Quantity) AS OrderRevenue

    FROM orders AS o

    INNER JOIN orderdetails AS od
        ON o.OrderID = od.OrderID

    INNER JOIN products AS p
        ON od.ProductID = p.ProductID

    GROUP BY
        o.OrderID,
        DAYOFWEEK(o.OrderDate),
        DAYNAME(o.OrderDate)
)

SELECT
    DayNumber,
    DayName,
    COUNT(*) AS RevenueOrders,
    ROUND(SUM(OrderRevenue), 2) AS GrossRevenue,
    ROUND(AVG(OrderRevenue), 2) AS GrossAOV

FROM OrderTotals

GROUP BY
    DayNumber,
    DayName

ORDER BY
    DayNumber;
    
    -- ============================================================
-- Q22. REGIONAL ORDER VOLUME AND REVENUE
-- ============================================================

WITH RegionalOrders AS (
    SELECT
        r.RegionID,
        r.RegionName,
        r.Country,
        COUNT(DISTINCT o.OrderID) AS TotalOrders

    FROM regions AS r

    INNER JOIN customers AS c
        ON r.RegionID = c.RegionID

    INNER JOIN orders AS o
        ON c.CustomerID = o.CustomerID

    GROUP BY
        r.RegionID,
        r.RegionName,
        r.Country
),

RegionalRevenue AS (
    SELECT
        r.RegionID,
        COUNT(DISTINCT o.OrderID) AS RevenueOrders,
        SUM(p.Price * od.Quantity) AS GrossRevenue

    FROM regions AS r

    INNER JOIN customers AS c
        ON r.RegionID = c.RegionID

    INNER JOIN orders AS o
        ON c.CustomerID = o.CustomerID

    INNER JOIN orderdetails AS od
        ON o.OrderID = od.OrderID

    INNER JOIN products AS p
        ON od.ProductID = p.ProductID

    GROUP BY
        r.RegionID
)

SELECT
    ro.RegionName,
    ro.Country,
    ro.TotalOrders,
    rr.RevenueOrders,

    ROUND(
        100.0 * rr.RevenueOrders /
        NULLIF(ro.TotalOrders, 0),
        2
    ) AS DetailCoveragePct,

    ROUND(rr.GrossRevenue, 2) AS GrossRevenue

FROM RegionalOrders AS ro

INNER JOIN RegionalRevenue AS rr
    ON ro.RegionID = rr.RegionID

ORDER BY
    GrossRevenue DESC;
    
    
    -- ============================================================
-- Q23. ORDER RETURN RATE BY REGION
-- ============================================================

SELECT
    r.RegionName,
    r.Country,

    COUNT(o.OrderID) AS TotalOrders,

    SUM(
        CASE
            WHEN o.IsReturned = 1 THEN 1
            ELSE 0
        END
    ) AS ReturnedOrders,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN o.IsReturned = 1 THEN 1
                ELSE 0
            END
        ) /
        NULLIF(COUNT(o.OrderID), 0),
        2
    ) AS OrderReturnRatePct

FROM regions AS r

INNER JOIN customers AS c
    ON r.RegionID = c.RegionID

INNER JOIN orders AS o
    ON c.CustomerID = o.CustomerID

GROUP BY
    r.RegionID,
    r.RegionName,
    r.Country

ORDER BY
    OrderReturnRatePct DESC;
    
    
    -- ============================================================
-- Q24. CATEGORY ORDER RETURN EXPOSURE
-- ============================================================
-- Measures the percentage of category-containing orders
-- associated with returned orders.
-- ============================================================

SELECT
    p.Category,

    COUNT(DISTINCT o.OrderID) AS CategoryOrders,

    COUNT(
        DISTINCT CASE
            WHEN o.IsReturned = 1
            THEN o.OrderID
        END
    ) AS ReturnedCategoryOrders,

    ROUND(
        100.0 *
        COUNT(
            DISTINCT CASE
                WHEN o.IsReturned = 1
                THEN o.OrderID
            END
        ) /
        NULLIF(COUNT(DISTINCT o.OrderID), 0),
        2
    ) AS CategoryOrderReturnRatePct

FROM products AS p

INNER JOIN orderdetails AS od
    ON p.ProductID = od.ProductID

INNER JOIN orders AS o
    ON od.OrderID = o.OrderID

GROUP BY
    p.Category

ORDER BY
    CategoryOrderReturnRatePct DESC;
    
    
    -- ============================================================
-- Q25. CUSTOMERS WITH FREQUENT RETURNS
-- ============================================================

SELECT
    c.CustomerID,
    c.CustomerName,
    r.RegionName,
    r.Country,

    COUNT(o.OrderID) AS TotalOrders,

    SUM(
        CASE
            WHEN o.IsReturned = 1 THEN 1
            ELSE 0
        END
    ) AS ReturnedOrders,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN o.IsReturned = 1 THEN 1
                ELSE 0
            END
        ) /
        NULLIF(COUNT(o.OrderID), 0),
        2
    ) AS CustomerReturnRatePct

FROM customers AS c

INNER JOIN regions AS r
    ON c.RegionID = r.RegionID

INNER JOIN orders AS o
    ON c.CustomerID = o.CustomerID

GROUP BY
    c.CustomerID,
    c.CustomerName,
    r.RegionName,
    r.Country

HAVING
    ReturnedOrders >= 2

ORDER BY
    ReturnedOrders DESC,
    CustomerReturnRatePct DESC,
    TotalOrders DESC;