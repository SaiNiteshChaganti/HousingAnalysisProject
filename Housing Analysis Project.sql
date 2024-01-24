SELECT * 
FROM HousingAnalysis..Housingdata

-- 1) Sale date

-- Converting SaleDate format
Select SaleDate, Convert(date,SaleDate)
From HousingAnalysis..Housingdata

-- Tried altering SaleDate column but it didn't work so let's create new column 'SaleDate2' and add the converted format into the column
--Update HousingAnalysis..Housingdata
--SET SaleDate = Convert(date,SaleDate)

Select SaleDate
From HousingAnalysis..Housingdata

Alter Table HousingAnalysis..Housingdata
Add SaleDate2 Date;

Update HousingAnalysis..Housingdata
Set SaleDate2 = Convert(Date,SaleDate)


Select SaleDate2
From HousingAnalysis..Housingdata

-- 2) Property Address

-- Comparing 'ParcelID' and 'PropertyAddress' to populate the missing data
Select *
From HousingAnalysis..Housingdata
Where PropertyAddress is null
order by ParcelID

-- Comparing the missing coulmns with the ones that we need to populate
Select a.ParcelID, a.PropertyAddress, b.ParcelID,  b.PropertyAddress
From HousingAnalysis..Housingdata a
Join HousingAnalysis..Housingdata b
 on a.ParcelID = b.ParcelID
 and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL

-- Populating the null values

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From HousingAnalysis..Housingdata a
Join HousingAnalysis..Housingdata b
 on a.ParcelID = b.ParcelID
 and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL


-- 3) Dividing the 'PropertyAddress' into different columns

Select SUBSTRING (PropertyAddress, 1, CHARINDEX (',', PropertyAddress) -1) as Address
, SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From HousingAnalysis..Housingdata

Alter Table HousingAnalysis..Housingdata
Add PropertyAddressNumber Nvarchar(255);

Update HousingAnalysis..Housingdata
Set PropertyAddressNumber = SUBSTRING (PropertyAddress, 1, CHARINDEX (',', PropertyAddress) -1)

Alter Table HousingAnalysis..Housingdata
Add PropertyAddressSuburb Nvarchar(255);

Update HousingAnalysis..Housingdata
Set PropertyAddressSuburb = SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From HousingAnalysis..Housingdata

-- 4) Owner Address

Select OwnerAddress
From HousingAnalysis..Housingdata

Select
 PARSENAME(Replace(OwnerAddress,',','.'), 3),
 PARSENAME(Replace(OwnerAddress,',','.'), 2),
 PARSENAME(Replace(OwnerAddress,',','.'), 1)
From HousingAnalysis..Housingdata

Alter Table HousingAnalysis..Housingdata
Add OwnerAddressNumber Nvarchar(255);

Update HousingAnalysis..Housingdata
Set OwnerAddressNumber = PARSENAME(Replace(OwnerAddress,',','.'), 3)

Alter Table HousingAnalysis..Housingdata
Add OwnerAddressSuburb Nvarchar(255);

Update HousingAnalysis..Housingdata
Set OwnerAddressSuburb = PARSENAME(Replace(OwnerAddress,',','.'), 2)

Alter Table HousingAnalysis..Housingdata
Add OwnerAddressState Nvarchar(255);

Update HousingAnalysis..Housingdata
Set OwnerAddressState = PARSENAME(Replace(OwnerAddress,',','.'), 1)

Select *
From HousingAnalysis..Housingdata

-- 5) Change 'Y' and 'N' to 'Yes' and 'No' in 'SoldAsVacant' column

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From HousingAnalysis..Housingdata
Group By SoldAsVacant
Order by 2 DESC

Select SoldAsVacant,
 Case When SoldAsVacant = 'Y' Then 'Yes'
      When SoldAsVacant = 'N' Then 'No'
	  Else SoldAsVacant
	  End
From HousingAnalysis..Housingdata

Update HousingAnalysis..Housingdata
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
      When SoldAsVacant = 'N' Then 'No'
	  Else SoldAsVacant
	  End

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From HousingAnalysis..Housingdata
Group By SoldAsVacant
Order by 2 DESC

-- 6) Remove Duplicates

With RowNumCTE as (
Select *,
 Row_Number() Over(
 Partition By ParcelID,
              PropertyAddress,
			  SaleDate,
			  SalePrice,
			  LegalReference
              Order by
			  UniqueID
			  ) row_num
From HousingAnalysis..Housingdata
)
Delete
From RowNumCTE
where row_num>1

-- 7) Delete Unused Columns

Select *
From HousingAnalysis..Housingdata

Alter Table HousingAnalysis..Housingdata
Drop Column SaleDate, PropertyAddress, OwnerAddress, TaxDistrict