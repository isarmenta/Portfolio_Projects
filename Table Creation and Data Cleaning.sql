SELECT *
FROM SQL.dbo.Nashville_Housing_Data
-------------------------------------------
--Standardize Date Format

ALTER TABLE SQL.dbo.Nashville_Housing_Data
Add SaleDateConverted Date;

UPDATE SQL.dbo.Nashville_Housing_Data
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM SQL.dbo.Nashville_Housing_Data

--Populate Property Address Data
SELECT *
FROM SQL.dbo.Nashville_Housing_Data
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress,b.PropertyAddress)
FROM SQL.dbo.Nashville_Housing_Data a
JOIN SQL.dbo.Nashville_Housing_Data b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is NUll

UPDATE a
SET PropertyAddress = ISNULL (a.PropertyAddress,b.PropertyAddress)
FROM SQL.dbo.Nashville_Housing_Data a
JOIN SQL.dbo.Nashville_Housing_Data b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is NUll

--- Breaking out Address into Indivudal columns (Address, City, State

SELECT PropertyAddress
FROM SQL.dbo.Nashville_Housing_Data

 SELECT
 SUBSTRING (PropertyAddress, 1, CHARINDEX(',',  PropertyAddress) -1)  as Address
, SUBSTRING (PropertyAddress, CHARINDEX(',',  PropertyAddress) +1, LEN (PropertyAddress)) as Address
 FROM SQL.dbo.Nashville_Housing_Data
 ---Update table, add two new columns
 ALTER TABLE SQL.dbo.Nashville_Housing_Data
Add PropertySplitAddress Nvarchar(255);

UPDATE SQL.dbo.Nashville_Housing_Data
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',',  PropertyAddress) -1)

 ALTER TABLE SQL.dbo.Nashville_Housing_Data
Add PropertySplitCity Nvarchar(255);

UPDATE SQL.dbo.Nashville_Housing_Data
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',',  PropertyAddress) +1, LEN (PropertyAddress))

SELECT*
FROM SQL.dbo.Nashville_Housing_Data

---Update Owner Address
SELECT
PARSENAME (REPLACE(OwnerAddress,',','.'),3)
,PARSENAME (REPLACE(OwnerAddress,',','.'),2)
,PARSENAME (REPLACE(OwnerAddress,',','.'),1)
FROM SQL.dbo.Nashville_Housing_Data
---

ALTER TABLE SQL.dbo.Nashville_Housing_Data
Add OwnerSplitAddress Nvarchar(255);

UPDATE SQL.dbo.Nashville_Housing_Data
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE SQL.dbo.Nashville_Housing_Data
Add OwnerSplitCity Nvarchar(255);

UPDATE SQL.dbo.Nashville_Housing_Data
SET OwnerSplitCity  = PARSENAME (REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE SQL.dbo.Nashville_Housing_Data
Add OwnerSplitState Nvarchar(255);

UPDATE SQL.dbo.Nashville_Housing_Data
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress,',','.'),1)

--- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT (SoldAsVacant), Count (SoldAsVacant)
FROM SQL.dbo.Nashville_Housing_Data
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM SQL.dbo.Nashville_Housing_Data

UPDATE SQL.dbo.Nashville_Housing_Data
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

---Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER () OVER (
	PARTITION BY ParcelID,
	PropertyAddress,
	SaleDate,
	LegalReference
	ORDER BY
	UniqueID
	) row_num

FROM SQL.dbo.Nashville_Housing_Data
)
SELECT *
FROM RowNumCTE
Where row_num > 1


--- Delete Unsed Columns

SELECT *
FROM SQL.dbo.Nashville_Housing_Data

ALTER TABLE SQL.dbo.Nashville_Housing_Data
DROP COLUMN OwnerAddress, TaxDistrict,PropertyAddress

ALTER TABLE SQL.dbo.Nashville_Housing_Data
DROP COLUMN SaleDate
