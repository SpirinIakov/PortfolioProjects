
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
-- CLEANING DATA IN SQL QUERIES
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------
-- PREP
---------------------------------------------------------------------------------------------------------------------------
SELECT *
FROM PortfolioProject.dbo.Nashvillehousing


---------------------------------------------------------------------------------------------------------------------------
-- [1] Standarizing Date Format
---------------------------------------------------------------------------------------------------------------------------
-- Current date column consists time, need to alter it and change to only date format.
SELECT SaleDateConverted, CONVERT(DATE,SaleDate)--, SaleDate
FROM PortfolioProject.dbo.Nashvillehousing

-- Issue: need to use another method. (Used online resources)
--UPDATE Nashvillehousing
--SET SaleDate = CONVERT(DATE, SaleDate)

-- Adding column
ALTER TABLE Nashvillehousing
ADD SaleDateConverted Date;

-- Updating table with new date format. 
UPDATE Nashvillehousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)


---------------------------------------------------------------------------------------------------------------------------
-- [2] Property Address Data Population
---------------------------------------------------------------------------------------------------------------------------
-- Analyzing Data
SELECT *
FROM PortfolioProject.dbo.Nashvillehousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

-- Test Query = none of the tables has a NULL in them.
SELECT A.[UniqueID ], A.ParcelID, A.PropertyAddress, B.[UniqueID ], B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject.dbo.Nashvillehousing A
JOIN PortfolioProject.dbo.Nashvillehousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

-- Verification: Data Update -> adresses with NULL, no longer exist.  
UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject.dbo.Nashvillehousing A
JOIN PortfolioProject.dbo.Nashvillehousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


---------------------------------------------------------------------------------------------------------------------------
-- [3] Breaking out Address into Individual Columns (Address, City, State)
---------------------------------------------------------------------------------------------------------------------------
-- Analyzing PropertyAddress column. 
SELECT PropertyAddress
FROM PortfolioProject.dbo.Nashvillehousing

-- Excluding comma from the Address column & Splitting Address into 2 columns: Address & City.
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX( ',', PropertyAddress) - 1) AS AddressBeforeComma
, SUBSTRING(PropertyAddress, CHARINDEX( ',', PropertyAddress) + 1, LEN(PropertyAddress)) AS CityAfterComma
FROM PortfolioProject..Nashvillehousing

-- Updating table with 2 new columns: Address, City.
ALTER TABLE PortfolioProject..Nashvillehousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProject..Nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX( ',', PropertyAddress) - 1)

ALTER TABLE PortfolioProject..Nashvillehousing
ADD PropertySplitCity Nvarchar(255);
 
UPDATE PortfolioProject..Nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX( ',', PropertyAddress) + 1, LEN(PropertyAddress))

-- Verification
SELECT  * 
FROM PortfolioProject.dbo.Nashvillehousing
----------------------------------------------------------------------------------------------------------------

-- Analyzing OwnerAddress column. Tets Splitting address, City & State 
SELECT  OwnerAddress
FROM PortfolioProject.dbo.Nashvillehousing

-- Splitting address, City & State
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerSplitAddress 
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerSplitCity
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerSplitState
FROM PortfolioProject.dbo.Nashvillehousing

-- Updating table with 3 new columns: Address, City, State.
ALTER TABLE PortfolioProject..Nashvillehousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE PortfolioProject..Nashvillehousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject..Nashvillehousing
ADD OwnerSplitCity Nvarchar(255);
 
UPDATE PortfolioProject..Nashvillehousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject..Nashvillehousing
ADD OwnerSplitState Nvarchar(255);
 
UPDATE PortfolioProject..Nashvillehousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- Verification
SELECT  * 
FROM PortfolioProject.dbo.Nashvillehousing



---------------------------------------------------------------------------------------------------------------------------
-- [4] Change Y and N, to Yes and No in 'Sold as Vacant' field
---------------------------------------------------------------------------------------------------------------------------
-- Distinct count column SoldAsVacant
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.Nashvillehousing
GROUP BY SoldAsVacant
ORDER BY 2

-- Chnaging to yes and no
SELECT SoldASVacant
, CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant 
	END
FROM PortfolioProject.dbo.Nashvillehousing

-- Updating table
UPDATE PortfolioProject..Nashvillehousing
SET SoldAsVacant =
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant 
	END

-- Verification
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.Nashvillehousing
GROUP BY SoldAsVacant
ORDER BY 2



---------------------------------------------------------------------------------------------------------------------------
-- [5] Removing Duplicates
---------------------------------------------------------------------------------------------------------------------------
-- Creating CTE
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
	ORDER BY	 UniqueID ) row_num
FROM PortfolioProject.dbo.Nashvillehousing
)

-- Deleting duplicates
-- SELECT *
DELETE
FROM RowNumCTE 
WHERE row_num > 1
-- ORDER BY PropertyAddress

-- Verification
SELECT *
FROM RowNumCTE 
WHERE row_num > 1
ORDER BY PropertyAddress



---------------------------------------------------------------------------------------------------------------------------
-- [6] Deleting unused columns
---------------------------------------------------------------------------------------------------------------------------
-- Analyzing Data 
SELECT *
FROM PortfolioProject.dbo.Nashvillehousing

-- Deleting columns
ALTER TABLE PortfolioProject.dbo.Nashvillehousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

-- Verification
SELECT *
FROM PortfolioProject.dbo.Nashvillehousing