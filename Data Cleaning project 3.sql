/*
CLEANING DATA IN SQL SQUERIES
*/

SELECT * FROM 
portfolioProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--STANDARDIZE DATA FORMAT

SELECT SaleDateConverted , CONVERT(Date, SaleDate)
from portfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted  Date;

UPDATE NashvilleHousing
SET SaleDateConverted = convert(Date,SaleDate)

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--POPULATE PROPERTY ADDRESS DATA

SELECT *
from portfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress is NULL

SELECT *
from portfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
from portfolioProject.dbo.NashvilleHousing a
JOIN portfolioProject.dbo.NashvilleHousing b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID] <> b.[UniqueID ]
	 WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
from portfolioProject.dbo.NashvilleHousing a
JOIN portfolioProject.dbo.NashvilleHousing b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID] <> b.[UniqueID ]
	  WHERE a.PropertyAddress is NULL

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADRESS, CITY, STATE)

SELECT PropertyAddress
from portfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is NULL
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress , 1 ,CHARINDEX(',', PropertyAddress)) as Address,
 CHARINDEX(',', PropertyAddress)
from portfolioProject.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress , 1 ,CHARINDEX(',', PropertyAddress )-1) as Address,
 SUBSTRING(PropertyAddress ,CHARINDEX(',', PropertyAddress ) +1, LEN(PropertyAddress)) as Address
from portfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress= SUBSTRING(PropertyAddress , 1 ,CHARINDEX(',', PropertyAddress )-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity  nvarchar(255);

UPDATE NashvilleHousing
SET  PropertySplitCity =  SUBSTRING(PropertyAddress ,CHARINDEX(',', PropertyAddress ) +1, LEN(PropertyAddress))

Select*
from portfolioProject.dbo.NashvilleHousing

Select OwnerAddress
from portfolioProject.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress,',','.'),1),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
from portfolioProject.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from portfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress= PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity  nvarchar(255);

UPDATE NashvilleHousing
SET  OwnerSplitCity =  PARSENAME(REPLACE(OwnerAddress,',','.'),2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET  OwnerSplitState  = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select*
from portfolioProject.dbo.NashvilleHousing

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--CHANGE Y AND N YES AND NO IN 'SOLD AS VACANT" FIELD

Select DISTINCT(SoldAsVacant), count(SoldAsVacant)
from portfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
      When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 END
from portfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
      When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 END

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--REMOVE DUPLICATES

Select*,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 Order by
			 UniqueID
			 ) row_num

from portfolioProject.dbo.NashvilleHousing

WITH RowNumCTE as(
Select*,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 Order by
			 UniqueID
			 ) row_num

from portfolioProject.dbo.NashvilleHousing
--Order by ParcelID
)
Select *
From RowNumCTE
where row_num > 1
order by PropertyAddress


-----DELETE


WITH RowNumCTE as(
Select*,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 Order by
			 UniqueID
			 ) row_num

from portfolioProject.dbo.NashvilleHousing
--Order by ParcelID
)
DELETE
From RowNumCTE
where row_num > 1
--order by PropertyAddress


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--SELECT UNUSED COLUMNS


Select*
from portfolioProject.dbo.NashvilleHousing

ALTER TABLE portfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE portfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate