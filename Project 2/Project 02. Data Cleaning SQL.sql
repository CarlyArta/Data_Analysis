													-- Project 03 --
									-- Data Cleaning (Nashville Housing Dataset) --
											-- By: Carly Marshanda Arta MS -- 


-- Data Cleaning in SQL Queries --

select *
from Portfolio_Project..NashvilleHousing
-----------------------------------------------------------------------------------------------------------------

-- Standardize Date Format --

select saleDateConverted, CONVERT(Date,SaleDate)
from Portfolio_Project..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDataConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-----------------------------------------------------------------------------------------------------------------

-- Populate property addres data

select *
from Portfolio_Project..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

-----------------------------------------------------------------------------------------------------------------

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from Portfolio_Project..NashvilleHousing a
join Portfolio_Project..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Portfolio_Project..NashvilleHousing a
join Portfolio_Project..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-----------------------------------------------------------------------------------------------------------

-- Breaking out Address into individual columns (addres, city, state)

select PropertyAddress
from Portfolio_Project..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID
----------------------------------------------------------------------------------------------------

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress), LEN(PropertyAddress)) as Address
from Portfolio_Project..NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress) +1, LEN(PropertyAddress))

-------------------------------------------------------------------------------------------------------------

select *
from Portfolio_Project..NashvilleHousing

select OwnerAddress
from Portfolio_Project..NashvilleHousing

select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from Portfolio_Project..NashvilleHousing

----------------------------------------------------------------------------------------------------------

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = parsename(REPLACE(OwnerAddress,',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = parsename(REPLACE(OwnerAddress,',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = parsename(REPLACE(OwnerAddress,',', '.'), 1)

---------------------------------------------------------------------------
select*
from Portfolio_Project..NashvilleHousing

=======================================================================================================
-- Change Y and N to YES and NO in "sold as vacant" field

select distinct(SoldAsVacant),count(SoldAsVacant)
from Portfolio_Project..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant
, Case when SoldAsVacant = 'Y' Then 'Yes'
	   when SoldAsVacant = 'N' Then 'No'
	   else
	   end
from Portfolio_Project..NashvilleHousing
-------------------------------------------
update NashvilleHousing
set SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end

=========================================================================================================

-- Remove Duplicates

with RowNumCTE AS(
select*,
	row_number() over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
					UniqueID
					) row_num

from Portfolio_Project..NashvilleHousing
--order by ParcelID
)
select*
from RowNumCTE
where row_num > 1
order by PropertyAddress


select*
from Portfolio_Project..NashvilleHousing

=======================================================================================================

-- Delete unused columns

select*
from Portfolio_Project..NashvilleHousing

alter table Portfolio_Project..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table Portfolio_Project..NashvilleHousing
drop column SaleData
