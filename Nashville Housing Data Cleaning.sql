/*
Nashville Housing Data Cleaning

Skills Used: Data Manipulation Language (DML), Data Query Language (DQL), Data Definition Lanuage (DDL)

*/

-- Cleaning Data in SQL Queries


SELECT saledate
FROM portfolio_project.nashvillehousing


-- Standardizing Date Format

ALTER TABLE portfolio_project.nashvillehousing
ADD updatedsaledate DATE;

UPDATE portfolio_project.nashvillehousing
SET updatedsalesate = CONVERT(saledate,DATE)

SELECT saledate, updatedsaledate
FROM portfolio_project.nashvillehousing


-- Populate Property Addresses
-- Updated NULL Property Addresses by Joining table to itself based off redundant ParcelIDs

SELECT *
FROM portfolio_project.nashvillehousing
-- WHERE propertyaddress IS NULL
ORDER BY parcelid

SELECT a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, IFNULL(a.propertyaddress, b.propertyaddress)
FROM portfolio_project.nashvillehousing a 
JOIN portfolio_project.nashvillehousing b 
	ON a.parcelid = b.parcelid
    AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress IS NULL

UPDATE portfolio_project.nashvillehousing a
INNER JOIN portfolio_project.nashvillehousing b 
	ON a.parcelid = b.parcelid
    AND a.uniqueid <> b.uniqueid
SET a.propertyaddress = IFNULL(a.propertyaddress, b.propertyaddress)     
WHERE a.propertyaddress IS NULL

SELECT propertyaddress
FROM portfolio_project.nashvillehousing
WHERE propertyaddress IS NULL


-- Triming extra spaces between PropertyAddress string

SELECT propertyaddress
FROM portfolio_project.nashvillehousing

ALTER TABLE portfolio_project.nashvillehousing
ADD updatedpropertyaddress TEXT;

UPDATE portfolio_project.nashvillehousing
SET updatedpropertyaddress = REPLACE(propertyaddress,'  ',' ')


-- Breaking down Address into Individual Columns (Address, City, State)

-- Property Address

SELECT updatedpropertyaddress
FROM portfolio_project.nashvillehousing

SELECT SUBSTRING(updatedpropertyaddress, 1, LOCATE(',', updatedpropertyaddress) -1) AS propertyaddressstreet
		SUBSTRING(updatedpropertyaddress, LOCATE(',', updatedpropertyaddress) + 1, CHAR_LENGTH(updatedpropertyaddress)) as propertyaddresscity
FROM portfolio_project.nashvillehousing

ALTER TABLE portfolio_project.nashvillehousing
ADD propertyaddressstreet NVARCHAR(255);

UPDATE portfolio_project.nashvillehousing
SET propertyaddressstreet = SUBSTRING(updatedpropertyaddress, 1, LOCATE(',', updatedpropertyaddress) -1)

ALTER TABLE portfolio_project.nashvillehousing
ADD propertyaddresscity NVARCHAR(255);

UPDATE portfolio_project.nashvillehousing
SET propertyaddresscity = SUBSTRING(updatedpropertyaddress, LOCATE(',', updatedpropertyaddress) + 1, CHAR_LENGTH(updatedpropertyaddress))

SELECT *
FROM portfolio_project.nashvillehousing

-- Owner Address

SELECT SUBSTRING_INDEX(owneraddress, ',', 1) AS owneraddressstreet,
		SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 2), ',', -1) AS owneraddresscity,
		SUBSTRING_INDEX(owneraddress, ',', -1) AS owneraddressstate
FROM portfolio_project.nashvillehousing

ALTER TABLE portfolio_project.nashvillehousing
ADD owneraddressstreet NVARCHAR(255);

UPDATE portfolio_project.nashvillehousing
SET owneraddressstreet = SUBSTRING_INDEX(owneraddress, ',', 1)

ALTER TABLE portfolio_project.nashvillehousing
ADD owneraddresscity NVARCHAR(255);

UPDATE portfolio_project.nashvillehousing
SET owneraddresscity = SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 2), ',', -1)

ALTER TABLE portfolio_project.nashvillehousing
ADD owneraddressstate NVARCHAR(255);

UPDATE portfolio_project.nashvillehousing
SET owneraddressstate = SUBSTRING_INDEX(owneraddress, ',', -1)


-- Change Y and N to Yes and No in the "Sold as Vacant" field

SELECT DISTINCT soldasvacant
FROM portfolio_project.nashvillehousing

SELECT soldasvacant, 
CASE WHEN soldasvacant = 'Y' THEN 'Yes'
	WHEN soldasvacant = 'N' THEN 'No'
	ELSE soldasvacant
	END
FROM portfolio_project.nashvillehousing

UPDATE portfolio_project.nashvillehousing
SET soldasvacant = CASE WHEN soldasvacant = 'Y' THEN 'Yes'
	WHEN soldasvacant = 'N' THEN 'No'
	ELSE soldasvacant
	END;


-- Deleting Unused Columns
-- DISCLAIMER: For project purposes only; not standard practice to delete raw data

SELECT *
FROM portfolio_project.nashvillehousing

ALTER TABLE portfolio_project.nashvillehousing
DROP COLUMN saledate,
DROP COLUMN owneraddress,
DROP COLUMN taxdistrict,
DROP COLUMN propertyaddress
DROP COLUMN updatedpropertyaddress;

