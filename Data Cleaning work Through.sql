/*

Cleaning Data in SQL Queries

*/


Select *
from PotfolioProject.dbo.NashvileHousing

--------------------------------------------------------------------------------------

--Standardize Data Fomart


Select SaleDateConverted, CONVERT(Date,SaleDate)
from PotfolioProject.dbo.NashvileHousing

Update NashvileHousing
SET SaleDate = CONVERT(Date,SaleDate)

-------------------------------------------

--Coverte to stardarlize fomart 2

ALTER TABLE NashvileHousing
Add SaleDateConverted Date;

Update NashvileHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-------------------------------------------------------------

--Populate PropertyAddress Data

Select PropertyAddress
from PotfolioProject.dbo.NashvileHousing
where PropertyAddress is Null


--Check for duplicate Propertyaddress

Select *
from PotfolioProject.dbo.NashvileHousing
order by ParcelID


--Populated the propertyaddresss using the ParcelID by Joining

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PotfolioProject.dbo.NashvileHousing a
JOIN PotfolioProject.dbo.NashvileHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	Where a.PropertyAddress is Null

Update a
SET PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress)
from PotfolioProject.dbo.NashvileHousing a
JOIN PotfolioProject.dbo.NashvileHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	Where a.PropertyAddress is Null

------------------------------------------------------------------------------

--Breaking out the address into individual columns (Address, City, State)

Select PropertyAddress
from PotfolioProject.dbo.NashvileHousing


 Select
 SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) - 1) as Address,
 SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

 from PotfolioProject.dbo.NashvileHousing


 ALTER TABLE NashvileHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvileHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) - 1)


ALTER TABLE NashvileHousing
Add PropertySplitCity Nvarchar(255);

Update NashvileHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) + 1 , LEN(PropertyAddress))


--- To Vefify the new coloumn created

Select *
from PotfolioProject.dbo.NashvileHousing


Select OwnerAddress
from PotfolioProject.dbo.NashvileHousing


-- Another method for Breaking out the address into individual columns (Address, City, State)

Select
PARSENAME(REPLACE(OwnerAddress, ',' , '.'),  3)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)
From PotfolioProject.dbo.NashvileHousing


--Update the Table using the queris below


 ALTER TABLE NashvileHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvileHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),  3)


ALTER TABLE NashvileHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvileHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2)

ALTER TABLE NashvileHousing
Add OwnerSplitState Nvarchar(255);

Update NashvileHousing
SET OwnerSplitState =PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)


--- To Vefify the new coloumn created

Select *
from PotfolioProject.dbo.NashvileHousing


--------------------------------------------------------------

--Change Y and N in 'Sold as Vacant' Field


Select Distinct(SoldAsVacant), count(SoldAsVacant) as Result
from PotfolioProject.dbo.NashvileHousing
Group by SoldAsVacant
Order by 2



Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'YES'
	 When SoldAsVacant = 'N' THEN 'NO'
	 Else SoldAsVacant
	 END
from PotfolioProject.dbo.NashvileHousing

Update NashvileHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
	 When SoldAsVacant = 'N' THEN 'NO'
	 ElSE SoldAsVacant
	 END
from PotfolioProject.dbo.NashvileHousing


-----------------------------------------------------------------------------------

--Remove Duplicates


WITH RownumCTE  AS(
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

from PotfolioProject.dbo.NashvileHousing
--Order by ParcelID
)


/*

Delete duplicates rows using this queries

DELETE
from RowNumCTE
WHERE ROW_num > 1
--order by PropertyAddress

*/

Select *
from RowNumCTE
WHERE ROW_num > 1
order by PropertyAddress

 ------------------------------------------------

 --Deleted Unused Coloumns


 select *
 from PotfolioProject.dbo.NashvileHousing


 ALTER TABLE PotfolioProject.dbo.NashvileHousing
		DROP COLUMN Owneraddress,
					TaxDistrict,
					PropertyAddress,
					SaleDate 