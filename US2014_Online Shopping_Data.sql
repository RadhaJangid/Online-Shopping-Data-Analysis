show databases;
use onlineshopping;
show tables;
/* ABOUT DATASET-
	This is US 2014 data about online shopping which is available in .xlsx format and in that workbook the data is in two different tabs, the first tab contains customer information and the second contains purchase details. */

# 1. Load the data file 
	CREATE TABLE Purchase_Details(Credit_Card INT, Product_ID INT, P_Category VARCHAR(16), P_Condition VARCHAR(11), Brand VARCHAR(5), Price DOUBLE, Selling_Price DOUBLE, Coupon_ID VARCHAR(5), Purchase_Date date, Purchase_Time time, GTIN INT, MPN INT, Merchant_Name VARCHAR(20), M_ID VARCHAR(6), Payment_Method VARCHAR(22), Transaction_ID INT, Return_Indicator BOOLEAN, Return_Date date);
	SELECT *  FROM Purchase_Details;
    
                                                     -- BASIC DATA ANALYSIS --  
                                                     
-- Table:- "Cust_Info"
SELECT * FROM Cust_Info;

# Display Top & Bottom 5 Rows
	SELECT * FROM Cust_Info LIMIT 5;
	SELECT * FROM Cust_Info LIMIT 5 OFFSET 193;
    
# Check the various attributes of data like shape (rows and columns), Columns, datatypes
	SELECT COUNT(*) No_of_Rows FROM Cust_Info;
	SELECT COUNT(*) NO_OF_COLUMNS FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME="Cust_Info";
	SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME="Cust_Info";
	SELECT COLUMN_NAME,DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME="Cust_Info";
	   
#  Schema of table
    DESC Cust_Info;
    # Altering table to add primary key.
		ALTER TABLE Cust_Info ADD PRIMARY KEY (C_ID);

# Check the Value Count for required column 
		  SELECT Gender, count(Gender) Value_count FROM Cust_Info GROUP BY Gender;
		  SELECT City, count(City) Value_count FROM Cust_Info GROUP BY City ORDER BY City;
		  SELECT State, count(State) Value_count FROM Cust_Info GROUP BY State ORDER BY State Desc;
          
# Null or Missing Value Check
	SELECT sum(CASE WHEN Address IS NULL THEN 1 ELSE 0 END) AS NULL_COUNT FROM Cust_Info;
		#NOTE:- The address column shows zero entries for null (NAN) values ​​but it includes all NaN values ​​that may occur while reading the data.

# Missing Value Treatement
	-- General Thumb Rules:- For features with very high number of missing values- it is better to drop those columns as they give very less insight on analysis.
	ALTER TABLE Cust_Info DROP COLUMN Address;



# 5-Number Summery of Data for numerical column only
    /*  
        1. Minimum
		2. Maximum
		3. Count
		4. Average
		5. Quartiles: 1) Q1
					  2) Q3
					  3) Median(Q2)     */
	SELECT round(std(Age),2) Standard_deviation , min(Age) Minimum_Age, max(Age) Maximum_Age, count(Age) Age_Count, round(avg(Age),2) Average_Age FROM Cust_Info;


# Handling Invalid Data 
	/* 
		There are some invalid values in Age column. Here the AGE of the customer are 15,16,17 years which is an invalid value for holding a credit card, But the C_ID(credit card ID) is there which means credit card has been used for online shopping.
		Invalid values for Age could be of multiple reasons:-
			1. Either the customer does not want to reveal his true age.
			2. The customer is using someone else credit card as it is noramally happens in the case of families, And there could be some other reason also.
        So we have to impute these invalid values:-
			By Replacing with the mean age in Male and Female    */
 
		  SELECT AVG(Age) AS Male_Avg_Age FROM Cust_Info WHERE  Age >= 18 AND Gender="M"; 
			-- 61.4719
		  SELECT AVG(Age) AS Female_Avg_Age FROM Cust_Info WHERE  Age >= 18 AND Gender="F";
			-- 59.0408
		  UPDATE  Cust_Info set Age = floor(61.4719) WHERE Age < 18 AND Gender="M"; 
		  UPDATE  Cust_Info set Age =floor(59.0408)  WHERE Age < 18 AND Gender="F"; 
   
# Feature Binning
	/*	
       Customer_Segmentation -
		* Young Females
		* Mid age Females
		* Old Females
		* Young Males
		* Mid age Males
		* Old Males 
        
        */
		ALTER TABLE Cust_Info ADD Customer_Segmentation VARCHAR(20);
		UPDATE Cust_Info SET Customer_Segmentation = CASE 
																WHEN Age >= 18 AND Age <= 36 THEN
																	CASE 
																		WHEN Gender = 'F' THEN 'Young Females' 
																		WHEN Gender = 'M' THEN 'Young Males' 
																	END
																WHEN Age > 36 AND Age <= 55 THEN
																	CASE
																		WHEN Gender = 'F' THEN 'Mid Age Females' 
																		WHEN Gender = 'M' THEN 'Mid Age Males' 
																	END
																WHEN Age > 55 THEN 
																	CASE
																		WHEN Gender = 'F' THEN 'Old Females' 
																		WHEN Gender = 'M' THEN 'Old Males' 
																	END
															END
															WHERE Customer_Segmentation IS NULL;
                                                            
                                                            
-- Table:- "Purchase Table"
  SELECT * FROM Purchase_Details;
  
# Display Top & Bottom 5 Rows
	 SELECT * FROM Purchase_Details LIMIT 5;
     
# Check the various attributes of data like shape (rows and columns), Columns, datatypes
		SELECT COUNT(*) No_of_Rows FROM Purchase_Details;
		SELECT COUNT(*) NO_OF_COLUMNS FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME="Purchase_Details";
		SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME="Purchase_Details";
		SELECT COLUMN_NAME,DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME="Purchase_Details";
	   
# Info of Data / Schema of table
		DESC Purchase_Details;

# Check the Value Count for required column 
		  SELECT P_Category, count(P_Category) Value_count FROM Purchase_Details GROUP BY P_Category ORDER BY Value_count DESC;
		  SELECT P_Condition, count(P_Condition) Value_count FROM Purchase_Details GROUP BY P_Condition ORDER BY Value_count DESC;
		  SELECT Return_Indicator, count(Return_Indicator) Value_count FROM Purchase_Details GROUP BY Return_Indicator ORDER BY Value_count DESC;
          SELECT Merchant_Name, count(Merchant_Name) Value_count FROM Purchase_Details GROUP BY Merchant_Name ORDER BY Value_count DESC;
          SELECT Payment_Method, count(Payment_Method) Value_count FROM Purchase_Details GROUP BY Payment_Method ORDER BY Value_count DESC;
          
# NULL Check
  SELECT
	SUM(CASE WHEN Coupon_ID IS NULL OR Coupon_ID='' THEN 1 ELSE 0 END) AS "Null Count Coupon_ID",
    SUM(CASE WHEN Credit_Card IS NULL OR Credit_Card='' THEN 1 ELSE 0 END) AS "Null Count C_ID",
	SUM(CASE WHEN Return_Date IS NULL or Return_Date = 0000-00-00 THEN 1 ELSE 0 END) AS "Null Count Return_Date" FROM 
    Purchase_Details;
  /*  
    As we can see in result table:-
	* In Purchase_Details table we had 5 missing values ​​in Credit_Card column.
	* 20 missing values in Coupon_ID column.
	* 8462 missing values in Return_Date column.
                                                   */
    
# Altering column size -
		ALTER TABLE Purchase_Details MODIFY Coupon_ID VARCHAR(12);
  
  
# Missing Value Treatement 
	/* 
		(1).Since the % of these records compared to total dataset is very low ie 0.20% in coupon_ID column, it is safe to ignore them from further processing.
            Customers having no Coupon, will obviously have Coupon_ID as NaN (null), but that doesn't make this column useless, so decisions has to be taken wisely.
			In this case we are not removing them, we can just impute them by 'No discount'. As it is a categorical column. */
        
			UPDATE Purchase_Details SET  Coupon_ID = COALESCE(NULLIF(Coupon_ID,''), 'No_discount');
             
	/* 
        (2).Imputing C_ID with a random number */
			UPDATE Purchase_Details SET  Credit_Card = 99999 WHERE Credit_Card='';
            
	/*  (3).The % of (0000-00-00) records compared to total dataset is very high ie 84.67% in Return_Date column.
            Customers not returning the product, will obviously have Return_Date as NaN (null) or 0000-00-00 , but that doesn't make this column useless, so decisions has to be taken wisely.*/
			UPDATE Purchase_Details SET `Return_Date` = NULL WHERE `Return_Date` = 0000-00-00;
        
# Sanity Checks / Data Cleaning
	# (1). Identity where Price is equal to Selling Price even after having a Coupon Code, apply an automatic discount of 5% for those entries.
	# (2). If the Coupon ID is NULL, make sure that NO discount is given, the Selling Price should be equal to Price.
    
			UPDATE Purchase_Details SET Selling_Price = 
												IF(Coupon_ID <>'No_discount',
																			IF(Selling_Price = Price, Price-Price*0.05,Selling_Price),
                                                                            IF(Coupon_ID ='No_discount',Price,Selling_Price)
                                                                            );
                                                                            
    # (3). Make sure that the return date is after the Purchase Date.
			SELECT SUM(CASE WHEN Return_Date < Purchase_Date THEN 1 ELSE 0 END) AS Return_Date_Before_the_Purchase_Date FROM purchase_Details WHERE Return_Date IS NOT NULL;                                                                        
			UPDATE Purchase_Details SET Return_Date = DATE_ADD(Return_Date, INTERVAL 1 YEAR)  WHERE Purchase_Date > Return_Date AND Return_Date IS NOT NULL;                                                               

    
# SQL JOINS : Cust_Info and Purchase_Details
	CREATE TABLE Customer_Purchase(
		SELECT p.* ,c.Name, c.Gender, c.City, c.State, c.Customer_Segmentation FROM Purchase_Details p INNER JOIN Cust_Info c ON p.Credit_Card = c.C_ID
			);

-- MERGED TABLE: "Customer_Purchase"
SELECT * FROM Customer_Purchase;

# Display Top & Bottom 5 Rows
	SELECT * FROM Customer_Purchase LIMIT 5;
	
# Check the various attributes of data like shape (rows and columns), Columns, datatypes
		SELECT COUNT(*) No_of_Rows FROM Customer_Purchase;
		SELECT COUNT(*) NO_OF_COLUMNS FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME="Customer_Purchase";
		SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME="Customer_Purchase";
		SELECT COLUMN_NAME,DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME="Customer_Purchase";
	   
# Info of Data / Schema of table
		DESC Customer_Purchase;
        
# Descriptive Statistics for numerical column only
		/*  
			1. Minimum
			2. Maximum
			3. Count
			4. Average
			5. Quartiles: 1) Q1
						  2) Q3
						  3) Median(Q2) 
			6. Standard Deviation
		*/
        
	# 5-Number Summery
		SELECT  COUNT(Selling_Price) Number_Of,
				CONCAT(Min(Selling_Price)," $") Minimum_Selling,
                CONCAT(MAX(Selling_Price)," $") Maximum_Selling,
                CONCAT(ROUND(AVG(Selling_Price),2)," $") Average_Selling,
                CONCAT(ROUND(SUM(Selling_Price),2), " $") Total_Selling,
                CONCAT(ROUND(SUM(Price),2), " $") Total_Price
		FROM Customer_Purchase;       
				
        
											
# Dividing the data into low and high value items
		# 1 - High_value_items
		# 0 - Low_value_items
        
	   DELIMITER ||
       CREATE PROCEDURE NewColumn() 
       BEGIN
			ALTER TABLE Customer_Purchase ADD Value_Items int;
			UPDATE Customer_Purchase SET Value_Items = CASE
													WHEN Selling_Price > 2500 THEN 1 ELSE 0 
												 END
													WHERE Value_Items IS NULL;   
	   END ||
       CALL NewColumn()      
       
       
# Remove columns not required for processing
		DELIMITER //
		CREATE PROCEDURE Delete_Columns()
		BEGIN
			ALTER TABLE Customer_Purchase
									DROP COLUMN GTIN,
                                    DROP COLUMN  MPN,
                                    DROP COLUMN M_ID;
		END //
        CALL Delete_Columns();

-- Data Exploration
	# Customer Segmentation Based on Spend in Dollars, based on Swipes, segmentation??
			SELECT Customer_Segmentation, COUNT(Credit_Card) AS 'Total No. of Swipes', CONCAT(ROUND(SUM(Selling_Price),2)," $") AS Expenditure FROM Customer_Purchase GROUP BY Customer_Segmentation ORDER BY Count(Credit_Card);
                                    


/*
	INSIGHTS :- 
    1. Old Females are spending and also swiping more.
    2. Maximum Orders are from California, after that Texas and then Illinois, But the Maximum Sales are from California, after that Texas and then Kentucky.
    3. Customers returning the products are not related to discount.
    4. Computers are the most ordered product category.
    5. The decoration product category has the highest sales.
    6. Customers are spending more in the month of March but sales are less in the month of April as compared to other months.
    7. Sunday, August 3, 2014 is the day of highest sales.
    8. The trend line of sales in 2014 is in decreasing order.
    9. New products are selling more in comparision to Used, Refurbished.
   10. Both debit card and gift card payment methods are offering more discount to customers.
   11. Customers from almost every state, age group, product condition and product category are returning products.
   12. There is no Co-relation between discount and number of orders. Orders are random.
   13. Nine West is a better seller in terms of high value items, about 85.71% of orders for high value items are from Nine West.
   14. Vitamin shoppe is a better seller in terms of low value items, about 85.37% of orders for low value items are from Vitamin Shoppe.
   15. Maximum high value item orders are from BEFJD brand and low value item orders are from DCJRW brand.
    
