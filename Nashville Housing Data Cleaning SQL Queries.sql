/*

Cleaning Data with SQL Queries

*/

select *
from PortfolioProject.dbo.NashvilleHousing

--Standardize date format

select SaleDateConverted,convert(Date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing


update NashvilleHousing
SET SaleDate=convert(Date,SaleDate)

alter table NashvilleHousing
Add SaleDateConverted Date;

update NashvilleHousing
SET SaleDateConverted=convert(Date,SaleDate)


--Populate Property Addres data


select *
from PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null 
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]!= b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]!= b.[UniqueID ]
where a.PropertyAddress is null



--Breaking out Address into Individual Columns(Address,City,State)

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null 
--order by ParcelID

select 
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress) -1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress )+1, LEN(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET  PropertySplitAddress =SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress) -1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity=SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress )+1, LEN(PropertyAddress))

select *
from PortfolioProject.dbo.NashvilleHousing

select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

Select
PARSENAME(replace(OwnerAddress,',','.'),3)
,PARSENAME(replace(OwnerAddress,',','.'),2)
,PARSENAME(replace(OwnerAddress,',','.'),1)
from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET  OwnerSplitAddress =PARSENAME(replace(OwnerAddress,',','.'),3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity=PARSENAME(replace(OwnerAddress,',','.'),2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState=PARSENAME(replace(OwnerAddress,',','.'),1)

select *
from PortfolioProject.dbo.NashvilleHousing


--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant),count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

select SoldAsVacant
,case when SoldAsVacant='Y' then 'Yes'
	  When SoldAsVacant ='N' then 'No'
	  else SoldAsVacant
	  end
from PortfolioProject.dbo.NashvilleHousing


update NashvilleHousing
SET SoldAsVacant=case when SoldAsVacant='Y' then 'Yes'
	  When SoldAsVacant ='N' then 'No'
	  else SoldAsVacant
	  end


--Remove Duplicates

WITH RowNumCTE as(
select *,
	ROW_NUMBER() over(
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
				 UniqueID
				 ) row_num
from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)

DELETE 
from RowNumCTE
where row_num >1
--order by PropertyAddress



--Delete Unused Columns

select *
from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Drop column OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Drop column SaleDate