/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
  FROM [PortfolioProject2].[dbo].[NashvilleHousing]

--------------------------------------------------

--Standardize Date Format

SELECT SaleDate, Convert(date,SaleDate)
  FROM [PortfolioProject2].[dbo].[NashvilleHousing]

Update NashvilleHousing
set SaleDate =Convert(date,SaleDate)

Alter table NashvilleHousing
add SaleDate2 date;

Update NashvilleHousing
set SaleDate2 =Convert(date,SaleDate)
SELECT SaleDate2
  FROM [PortfolioProject2].[dbo].[NashvilleHousing]

---------------------------------------------------------------------

-- Populate Property Address Data

SELECT *
  FROM [PortfolioProject2].[dbo].[NashvilleHousing]
  where PropertyAddress is null


SELECT a.ParcelID, a.PropertyAddress,b.PropertyAddress,b.ParcelID, ISNULL(a.PropertyAddress,b.PropertyAddress)
  FROM [PortfolioProject2].[dbo].[NashvilleHousing] a
  join [PortfolioProject2].[dbo].[NashvilleHousing] b
  on a.ParcelID=b.ParcelID
  and a.UniqueID<>b.UniqueID
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [PortfolioProject2].[dbo].[NashvilleHousing] a
  join [PortfolioProject2].[dbo].[NashvilleHousing] b
  on a.ParcelID=b.ParcelID
  and a.UniqueID<>b.UniqueID

---------------------------------------------------------------------------------

--Breaking Address into Individual Columns(Address,City,State)

SELECT PropertyAddress
  FROM [PortfolioProject2].[dbo].[NashvilleHousing]

SELECT 
substring(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) ,
substring(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))
  FROM [PortfolioProject2].[dbo].[NashvilleHousing]


Alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
set PropertySplitAddress =substring(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

Alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

Update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))

SELECT 
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
  FROM [PortfolioProject2].[dbo].[NashvilleHousing]

Alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
set OwnerSplitAddress =PARSENAME(replace(OwnerAddress,',','.'),3)

Alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)

Alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

Update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)

SELECT *
  FROM [PortfolioProject2].[dbo].[NashvilleHousing]

-------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT distinct(SoldAsVacant),count(SoldAsVacant)
  FROM [PortfolioProject2].[dbo].[NashvilleHousing]
  group by SoldAsVacant
  order by 2


SELECT SoldAsVacant,
case 
	when SoldAsVacant='Y' then 'Yes'
	when SoldAsVacant='N' then 'No'
	else SoldAsVacant
  end
  FROM [PortfolioProject2].[dbo].[NashvilleHousing]
  
Update NashvilleHousing
set SoldAsVacant = case 
	when SoldAsVacant='Y' then 'Yes'
	when SoldAsVacant='N' then 'No'
	else SoldAsVacant
  end

 ----------------------------------------------------------------------

 --Remove Duplicates
With RowNumCTE as(
Select *, ROW_NUMBER()over(partition by ParcelID, PropertyAddress,SalePrice,SaleDate,LegalReference
							order by UniqueID) row_num
FROM [PortfolioProject2].[dbo].[NashvilleHousing]
)
delete
from RowNumCTE
where row_num>1
--order by PropertyAddress

With RowNumCTE as(
Select *, ROW_NUMBER()over(partition by ParcelID, PropertyAddress,SalePrice,SaleDate,LegalReference
							order by UniqueID) row_num
FROM [PortfolioProject2].[dbo].[NashvilleHousing]
)
Select *
from RowNumCTE
where row_num>1
order by PropertyAddress

---------------------------------------------------------------------------------------------------------------

---Delete Unused Columns
Select *
FROM PortfolioProject2.dbo.NashvilleHousing

Alter table PortfolioProject2.dbo.NashvilleHousing
Drop Column OwnerAddress, PropertyAddress, TaxDistrict

Alter table PortfolioProject2.dbo.NashvilleHousing
Drop Column SaleDate

----------------------------------------------------------------------------------------------------------------





