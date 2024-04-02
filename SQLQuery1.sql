SELECT *
FROM Project1.dbo.Nashville_Housing_Data

---------------------------------------------------------------
--Removing time and standradising the SaleDate

SELECT SaleDate,CONVERT(DATE,SaleDate) AS Date
FROM Project1.dbo.Nashville_Housing_Data

UPDATE Project1.dbo.Nashville_Housing_Data
SET SaleDate = CONVERT(DATE,SaleDate)

ALTER TABLE Project1.dbo.Nashville_Housing_Data
ALTER COLUMN SaleDate DATE

------------------------------------------------------------------
--Cleaning and populate the property address column
--Self join for removing the null values

SELECT *
FROM Project1.dbo.Nashville_Housing_Data
WHERE PropertyAddress IS NULL

SELECT a.ParcelID, a.[UniqueID ], a.PropertyAddress, b.ParcelID, b.[UniqueID ],b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Project1.dbo.Nashville_Housing_Data a
JOIN Project1.dbo.Nashville_Housing_Data b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Project1.dbo.Nashville_Housing_Data a
JOIN Project1.dbo.Nashville_Housing_Data b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-------------------------------------------------------------------
--Seperating the address in seperate fields (ADDRESS , City, State)

SELECT PropertyAddress
FROM Project1.dbo.Nashville_Housing_Data

SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS address,
	SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS City
FROM Project1.dbo.Nashville_Housing_Data

ALTER TABLE Project1.dbo.Nashville_Housing_Data
ADD PropertySplitAddress NVARCHAR(255);

UPDATE Project1.dbo.Nashville_Housing_Data
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);

ALTER TABLE Project1.dbo.Nashville_Housing_Data
ADD PropertySplitCity NVARCHAR(255);

UPDATE Project1.dbo.Nashville_Housing_Data
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT *
FROM Project1.dbo.Nashville_Housing_Data

SELECT OwnerAddress,PARSENAME(REPLACE(OwnerAddress,',','.'),3),
			PARSENAME(REPLACE(OwnerAddress,',','.'),2),
			PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM Project1.dbo.Nashville_Housing_Data

ALTER TABLE Project1.dbo.Nashville_Housing_Data
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE Project1.dbo.Nashville_Housing_Data
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);

ALTER TABLE Project1.dbo.Nashville_Housing_Data
ADD OwnerSplitCity NVARCHAR(255);

UPDATE Project1.dbo.Nashville_Housing_Data
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);

ALTER TABLE Project1.dbo.Nashville_Housing_Data
ADD OwnerSplitState NVARCHAR(255);

UPDATE Project1.dbo.Nashville_Housing_Data
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);

------------------------------------------------------------------------
--Replacing Y adn N as Yes and No in sold/vacant

SELECT SoldAsVacant,COUNT(SoldAsVacant)
FROM Project1.dbo.Nashville_Housing_Data
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,CASE
			WHEN SoldAsVacant = 'N' THEN 'No'
			WHEN SoldAsVacant = 'Y' THEN 'Yes'
			ELSE SoldAsVacant
	  END
FROM Project1.dbo.Nashville_Housing_Data
GROUP BY SoldAsVacant

UPDATE Project1.dbo.Nashville_Housing_Data
SET SoldAsVacant = CASE
			WHEN SoldAsVacant = 'N' THEN 'No'
			WHEN SoldAsVacant = 'Y' THEN 'Yes'
			ELSE SoldAsVacant
	  END

--------------------------------------------------
--Removing Duplicate

WITH RowNumCTE AS(
SELECT *, ROW_NUMBER() OVER (PARTITION BY 
								ParcelID,
								PropertyAddress,
								SalePrice,
								SaleDate,
								LegalReference
								ORDER BY
								UniqueID) AS row_num
FROM Project1.dbo.Nashville_Housing_Data
)

DELETE 
FROM RowNumCTE
WHERE Row_num > 1

----------------------------------------------------------------------
--Delete the unused coloumns

SELECT *
FROM Project1.dbo.Nashville_Housing_Data

ALTER TABLE Project1.dbo.Nashville_Housing_Data
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict,SaleDate