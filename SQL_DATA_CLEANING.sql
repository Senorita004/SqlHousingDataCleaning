/*

Data Cleaning With SQL Queries

*/

Select * 
From PortfolioProject.dbo.NashvilleHousing

--Standardising date Format
Select SaleDate, CONVERT(Date, SaleDate)
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

-- Populating Property Address data
Select *
From PortfolioProject..NashvilleHousing
Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULl(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID]<> b.[UniqueID]
Where a.PropertyAddress is null

UPDATE a
Set PropertyAddress = ISNULl(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID]<> b.[UniqueID]
Where a.PropertyAddress is null

--Breaking out Property Address into Individual Columns (Address, City) Using Substring
Select PropertyAddress
From PortfolioProject..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as city
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress NVARCHAR(250);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity NVARCHAR(250);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

--Breaking out Owner Address into Individual Columns (Address, City, State) Using ParseName
Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select OwnerAddress
ParseName(REPLACE(OwnerAddress, ',', '.'),3 )
ParseName(REPLACE(OwnerAddress, ',', '.'),2 )
ParseName(REPLACE(OwnerAddress, ',', '.'),1 )

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress NVARCHAR(250);

Update NashvilleHousing
Set OwnerSplitAddress = ParseName(REPLACE(OwnerAddress, ',', '.'),3 )

ALTER TABLE NashvilleHousing
Add OwnerSplitCity NVARCHAR(250);

Update NashvilleHousing
Set OwnerSplitCity = ParseName(REPLACE(OwnerAddress, ',', '.'),2 )

ALTER TABLE NashvilleHousing
Add OwnerSplitState NVARCHAR(250);

Update NashvilleHousing
Set OwnerSplitState = ParseName(REPLACE(OwnerAddress, ',', '.'),1 )

-- Changing Y and N to Yes and No in "Sold as Vacant" field
Select DISTINCT(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group By SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
       END
From PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
       END
From PortfolioProject..NashvilleHousing

-- Removing Duplicates
With RowNumCTE AS (
Select *, 
    ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
                PropertyAddress,
                SalePrice,
                SaleDate,
                LegalReference
                Order BY
                    UniqueID
                    ) as row_num
    
From PortfolioProject..NashvilleHousing
)
Delete
From RowNumCTE
Where row_num >1

-- Deleting Unused Columns
Select *
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
