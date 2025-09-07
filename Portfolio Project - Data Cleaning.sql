/*

Cleaning Data in SQL Queries

*/

SELECT 
*
FROM PortfolioProjectSQL1.dbo.NashvilleHousingData

-----------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT 
SaleDate
FROM PortfolioProjectSQL1.dbo.NashvilleHousingData 

SELECT 
CONVERT(Date, SaleDate)
FROM PortfolioProjectSQL1.dbo.NashvilleHousingData 

Update PortfolioProjectSQL1.dbo.NashvilleHousingData 
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE PortfolioProjectSQL1.dbo.NashvilleHousingData  ALTER COLUMN SaleDate DATE

SELECT 
SaleDate
FROM PortfolioProjectSQL1.dbo.NashvilleHousingData


------------------------------------------------------------------------------------------

--Populate Property Address data


SELECT 
PropertyAddress
FROM PortfolioProjectSQL1.dbo.NashvilleHousingData
WHERE PropertyAddress IS NULL

SELECT 
*
FROM PortfolioProjectSQL1.dbo.NashvilleHousingData
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From PortfolioProjectSQL1.dbo.NashvilleHousingData a
JOIN PortfolioProjectSQL1.dbo.NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)	   
From PortfolioProjectSQL1.dbo.NashvilleHousingData a
JOIN PortfolioProjectSQL1.dbo.NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a	 
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)  
From PortfolioProjectSQL1.dbo.NashvilleHousingData a
JOIN PortfolioProjectSQL1.dbo.NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)



Select PropertyAddress
From PortfolioProjectSQL1.dbo.NashvilleHousingData
--Where PropertyAddress is null
--order by ParcelID


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Adress
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress))  as Adress
From PortfolioProjectSQL1.dbo.NashvilleHousingData


ALTER TABLE PortfolioProjectSQL1.dbo.NashvilleHousingData
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProjectSQL1.dbo.NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE PortfolioProjectSQL1.dbo.NashvilleHousingData
Add PropertySplitCity Nvarchar(255);

Update PortfolioProjectSQL1.dbo.NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select *
From PortfolioProjectSQL1.dbo.NashvilleHousingData


---------------------------------------------------
--OWNER ADRESS
Select OwnerAddress
From PortfolioProjectSQL1.dbo.NashvilleHousingData


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
From PortfolioProjectSQL1.dbo.NashvilleHousingData

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProjectSQL1.dbo.NashvilleHousingData

--ADDRESS
ALTER TABLE PortfolioProjectSQL1.dbo.NashvilleHousingData
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProjectSQL1.dbo.NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

 --CITY
ALTER TABLE PortfolioProjectSQL1.dbo.NashvilleHousingData
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProjectSQL1.dbo.NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


--STATE
ALTER TABLE PortfolioProjectSQL1.dbo.NashvilleHousingData
Add OwnerSplitState Nvarchar(255);

Update PortfolioProjectSQL1.dbo.NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


Select *
From PortfolioProjectSQL1.dbo.NashvilleHousingData


-------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant)
From PortfolioProjectSQL1.dbo.NashvilleHousingData

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProjectSQL1.dbo.NashvilleHousingData
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProjectSQL1.dbo.NashvilleHousingData

Update PortfolioProjectSQL1.dbo.NashvilleHousingData
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



------------------------------------------------------------------
-- Remove Duplicates


Select *
From PortfolioProjectSQL1.dbo.NashvilleHousingData

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProjectSQL1.dbo.NashvilleHousingData
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


Select *
From PortfolioProjectSQL1.dbo.NashvilleHousingData
----------------------------------------------------------------
-- Delete Duplicates 
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProjectSQL1.dbo.NashvilleHousingData
--order by ParcelID
)
Delete 
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress
------------------------
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProjectSQL1.dbo.NashvilleHousingData
--order by ParcelID
)
Select  *
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

-----------------------------------------------------------------------------------------------
-- Delete Unused Columns



Select *
From PortfolioProjectSQL1.dbo.NashvilleHousingData


ALTER TABLE PortfolioProjectSQL1.dbo.NashvilleHousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate