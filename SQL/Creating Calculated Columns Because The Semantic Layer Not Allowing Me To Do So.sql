-- =============================================
-- PART 1: Add Columns to Tables
-- =============================================

-- Add columns to FactListing
ALTER TABLE Gold.FactListing
ADD 
    [Price Tier] VARCHAR(50),
    [Is High Demand] INT,
    [Booking Potential] VARCHAR(50),
    [Price per Month] DECIMAL(18, 2);

-- Add column to DimHost
ALTER TABLE Gold.DimHost
ADD [Host Category] VARCHAR(50);

-- =============================================
-- PART 2: Populate Columns in FactListing
-- =============================================

-- Update Price Tier
UPDATE Gold.FactListing
SET [Price Tier] = CASE
    WHEN Price = 0 THEN 'Free'
    WHEN Price < 100 THEN 'Budget'
    WHEN Price < 300 THEN 'Mid-Range'
    WHEN Price < 500 THEN 'Premium'
    ELSE 'Luxury'
END;

-- Update Is High Demand (using NumberOfReviews and ReviewsPerMonth)
UPDATE Gold.FactListing
SET [Is High Demand] = CASE
    WHEN NumberOfReviews > 50 AND ReviewsPerMonth > 3 THEN 1
    ELSE 0
END;

-- Update Booking Potential (using Availability365)
UPDATE Gold.FactListing
SET [Booking Potential] = CASE
    WHEN Availability365 = 0 THEN 'Not Available'
    WHEN Availability365 < 30 THEN 'Low'
    WHEN Availability365 < 180 THEN 'Medium'
    ELSE 'High'
END;

-- Update Price per Month
UPDATE Gold.FactListing
SET [Price per Month] = Price * 30;

-- =============================================
-- PART 3: Populate Host Category in DimHost
-- =============================================

-- Update Host Category using CTE to count listings per host
WITH HostListingCounts AS (
    SELECT 
        HostID,
        COUNT(*) AS ListingCount
    FROM Gold.FactListing
    GROUP BY HostID
)
UPDATE Gold.DimHost
SET [Host Category] = 
    CASE 
        WHEN hlc.ListingCount = 1 THEN 'Single Listing'
        WHEN hlc.ListingCount <= 5 THEN 'Small Host'
        WHEN hlc.ListingCount <= 20 THEN 'Medium Host'
        ELSE 'Large Host'
    END
FROM Gold.DimHost dh
INNER JOIN HostListingCounts hlc ON dh.HostID = hlc.HostID;

-- =============================================
-- PART 4: Verify the Changes
-- =============================================

-- Check FactListing new columns
SELECT TOP 100 
    ListingID,
    Price,
    [Price Tier],
    NumberOfReviews,
    ReviewsPerMonth,
    [Is High Demand],
    Availability365,
    [Booking Potential],
    [Price per Month]
FROM Gold.FactListing
WHERE [Is High Demand] <> 0;

-- Check DimHost new column
SELECT TOP 10 
    HostID,
    HostName,
    [Host Category]
FROM Gold.DimHost;