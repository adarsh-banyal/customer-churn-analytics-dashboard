--Query 1 — High Risk Customer Segmentation

SELECT
    customerID,
    tenure,
    MonthlyCharges,
    Contract,
    Churn,

    CASE
        WHEN tenure <= 12 THEN 'High Risk'
        WHEN tenure <= 24 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS Risk_Segment

FROM churn_data;

--Query 2 — Revenue At Risk By Segment

SELECT
    CASE
        WHEN tenure <= 12 THEN 'High Risk'
        WHEN tenure <= 24 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS Risk_Segment,

    COUNT(*) AS Customers,

    ROUND(
        SUM(MonthlyCharges),
        2
    ) AS Revenue_At_Risk

FROM churn_data

WHERE Churn='Yes'

GROUP BY 1

ORDER BY Revenue_At_Risk DESC;

--Query 3 — Contract Ranking

SELECT
    Contract,

    COUNT(*) AS Customers,

    ROUND(
        AVG(MonthlyCharges),
        2
    ) AS Avg_Monthly_Revenue,

    RANK() OVER(
        ORDER BY AVG(MonthlyCharges) DESC
    ) AS Revenue_Rank

FROM churn_data

GROUP BY Contract;

--Query 4 — Churn Rate By Internet Service

SELECT
    InternetService,

    COUNT(*) AS Customers,

    SUM(
        CASE
            WHEN Churn='Yes'
            THEN 1
            ELSE 0
        END
    ) AS Churned_Customers,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN Churn='Yes'
                THEN 1
                ELSE 0
            END
        )
        /
        COUNT(*),
        2
    ) AS Churn_Rate

FROM churn_data

GROUP BY InternetService

ORDER BY Churn_Rate DESC;

--Query 5 — Top Revenue Customers

WITH customer_revenue AS
(
    SELECT
        customerID,

        TotalCharges,

        ROW_NUMBER() OVER(
            ORDER BY TotalCharges DESC
        ) AS Revenue_Rank

    FROM churn_data
)

SELECT *
FROM customer_revenue
WHERE Revenue_Rank <= 10;

--Query 6 — Churn Trend By Tenure Group

WITH tenure_segments AS
(
    SELECT
        CASE
            WHEN tenure <= 12 THEN '0-12 Months'
            WHEN tenure <= 24 THEN '13-24 Months'
            WHEN tenure <= 48 THEN '25-48 Months'
            ELSE '49+ Months'
        END AS Tenure_Group,

        Churn

    FROM churn_data
)

SELECT
    Tenure_Group,

    COUNT(*) AS Customers,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN Churn='Yes'
                THEN 1
                ELSE 0
            END
        )
        /
        COUNT(*),
        2
    ) AS Churn_Rate

FROM tenure_segments

GROUP BY Tenure_Group

ORDER BY Churn_Rate DESC;

-- =========================================================
-- Customer Churn Analytics Dashboard
-- Author: Adarsh Banyal
-- Description:
-- Advanced SQL analysis for customer churn analytics.
-- Demonstrates CTEs, Window Functions, CASE WHEN,
-- Aggregations, Segmentation, and KPI Reporting.
-- =========================================================