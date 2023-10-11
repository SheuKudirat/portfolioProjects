SELECT *
FROM PortfolioProject..[Nashville Housing]
order by 2,3

--Standardize Date Format

SELECT SaleDate, CONVERT(date,SaleDate) as salesdateconverted
FROM PortfolioProject..[Nashville Housing]

update [Nashville Housing]
set SaleDate = salesdateconverted

select salesdateconverted
from PortfolioProject..[Nashville Housing]

--Property Address

SELECT *
FROM PortfolioProject..[Nashville Housing]
--where PropertyAddress is null
order by ParcelID  

--Populate empty property address with property address of same parcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM PortfolioProject..[Nashville Housing] a
JOIN PortfolioProject..[Nashville Housing] b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..[Nashville Housing] a
JOIN PortfolioProject..[Nashville Housing] b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Breakng out address into individual columns

SELECT PropertyAddress
FROM PortfolioProject..[Nashville Housing]
--where PropertyAddress is null
order by ParcelID  

select 
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as City
from PortfolioProject..[Nashville Housing]
order by ParcelID 

ALTER TABLE PortfolioProject..[Nashville Housing]
add AddressConverted nvarchar(255);

UPDATE PortfolioProject..[Nashville Housing]
set AddressConverted = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress) -1)

alter table PortfolioProject..[Nashville Housing]
add CityConverted nvarchar(255);

UPDATE PortfolioProject..[Nashville Housing]
set CityConverted = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))


--splitting OwnerAddress

select 
parsename(replace(OwnerAddress,',','.') ,3) 
,parsename(replace(OwnerAddress,',','.') ,2) 
,parsename(replace(OwnerAddress,',','.') ,1)  
from PortfolioProject..[Nashville Housing]
ORDER BY ParcelID

ALTER TABLE PortfolioProject..[Nashville Housing]
add OwnerAddressConverted nvarchar(255);

UPDATE PortfolioProject..[Nashville Housing]
set OwnerAddressConverted = parsename(replace(OwnerAddress,',','.') ,3) 

alter table PortfolioProject..[Nashville Housing]
add OwnerCityConverted nvarchar(255);

UPDATE PortfolioProject..[Nashville Housing]
set OwnerCityConverted = parsename(replace(OwnerAddress,',','.') ,2) 

alter table PortfolioProject..[Nashville Housing]
add OwnerStateConverted nvarchar(255);

UPDATE PortfolioProject..[Nashville Housing]
set OwnerStateConverted = parsename(replace(OwnerAddress,',','.') ,1) 

--change Y and N to Yes and No in SoldAsVacant field

SELECT distinct(SoldAsVacant),count(SoldAsVacant)
FROM PortfolioProject..[Nashville Housing]
group by SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   else SoldAsVacant
	   end
FROM PortfolioProject..[Nashville Housing]

update PortfolioProject..[Nashville Housing]
set SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   else SoldAsVacant
	   end

--remove duplicates

WITH RowNumCTE AS(
select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
				UniqueID	
				) row_num

FROM PortfolioProject..[Nashville Housing]
)
select *
from   RowNumCTE
Where row_num > 1


 --delete unused columns

 select *
 FROM PortfolioProject..[Nashville Housing]
 order by ParcelID

 alter table PortfolioProject..[Nashville Housing]
 drop column OwnerAddress, TaxDistrict, PropertyAddress

  alter table PortfolioProject..[Nashville Housing]
 drop column SaleDate