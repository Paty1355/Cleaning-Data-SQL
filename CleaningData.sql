USE [Housing Data]

--Showing Data
SELECT * FROM NashvilleHousing

--Standardize Date Format
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM NashvilleHousing

UPDATE NashvilleHousing SET SaleDate = CONVERT(Date, SaleDate) --not working

SELECT SaleDate
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted --working
FROM NashvilleHousing

--Populate Property Address data
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a 
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a 
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

SELECT PropertyAddress
FROM NashvilleHousing

--Creating indyvidual Address, City
SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) AS City,
FROM NashvilleHousing 

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255)

ALTER TABLE NashvilleHousing
ADD PropertySplitState Nvarchar(255)

UPDATE NashvilleHousing SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)
UPDATE NashvilleHousing SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))

--Creating indyvidual Address, City - Owner - faster way
SELECT OwnerAddress
FROM NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS Address,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS City,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS State
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

UPDATE NashvilleHousing SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)
UPDATE NashvilleHousing SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)
UPDATE NashvilleHousing SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--Change Y to Yes And N to No in Sold as Vacant
SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
END
FROM NashvilleHousing

UPDATE NashvilleHousing SET SoldAsVacant =
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
END

--Remove Duplicates
With DuplicatesCTE
AS
(
SELECT * ,
	ROW_NUMBER() OVER (PARTITION BY ParcelID,
									PropertyAddress,
									SalePrice,
									SaleDate,
									LegalReference
									ORDER BY UniqueID) row_num
FROM NashvilleHousing
)
DELETE 
FROM DuplicatesCTE
WHERE row_num > 1

--Delete Unused Columns
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate