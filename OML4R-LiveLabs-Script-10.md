# Oracle Machine Learning for R (OML4R)
 
Oracle Machine Learning for R (OML4R) enables you to use R (a statistical programming language) for statistical analysis, data 
exploration, machine learning, and graphical analysis of data stored in an Oracle database. This allows you to benefit from the 
simplicity of R and the power of Oracle Database without the need to deal with the complexities of sourcing, moving, and securing 
data.
 
 
In this workshop, you will use a dataset representing about 15,000 customers of an insurance company. Each customer has about 30 
attributes, and the goal is to train the model to predict a given customer's life-time value (LTV) using regression algorithms, and 
additionally, use classification algorithms to classify customers as as LOW, MEDIUM, HIGH, or VERY # HIGH LTV (using binned LTV categories). 
  
Note: In marketing, the life-time value (LTV) of a customer is an estimate of the net profit attributable to a given customer 
relationship over its lifetime.
 
 
# Estimated Lab Time

2 hours
 
 
# Objectives


In this lab, you will:
 
* Establish a connection from RStudio to your Oracle Database instance to prepare, explore, and visualize data.
* Use R for exploratory data analysis, data visualization, data organization (bucketing of data in train and test buckets), 
* Use Attribute Importance(AI), Principle Component Analysis, Model Building, and Model Validations techniques
* Use an OML4R REGRESSION models for estimating customer life-time value (LTV)
* Use an OML4R CLASSIFICATION models for LTV_BIN assignment for unassigned customers
* Validate predictions using RMSE (Root Mean Squared Error) and Confusion Matrix methods

Note:
* AutoML is currently not available for OML4R (it is only available for OML4Py)
* AutoML UI is currently available for ADB ONLY
* OML4R is currently not available for ADB
* Therefore, we will not be using AutoML in this lab

** Prerequisites **
* Oracle Database 21c, 19c, or 18c installed on-premises (or in a VM in Cloud);
* R, RStudio, and required libraries


# Task 1: Connect to RStudio client and establish database connection


1. RStudio provides a GUI/BUI as an IDE for R. RStudio has been pre-configured on your database server. Point browser to RStudio Web to connect.

````
http://<ip-address>:8787
````

Note: Alternatively, you can use RStudio Desktop, if you prefer.

2. Connect to RStudio. <New details to be included here.>

 
3. Load useful ORE libraries. The ORE library is a package that contains many useful R functions. 
 
 The standard dplyr R package provides grammar of data manipulation, which gives a consistent set of verbs that help you solve the most common data manipulation challenges

 OREdplyr is an overloaded package provides much of the dplyr functionality extending the ORE transparency layer for in-database execution of dplyr function calls. OREdplyr allows users to avoid costly movement of data while scaling to larger data volumes because operations are not constrained by R client memory, the latency of data movement, or single-threaded execution, but leverage Oracle Database as a high performance compute engine. 
 
 The caTools package contains several basic utility functions including: moving (rolling, running) window statistic functions, read/write for GIF and ENVI binary files, fast calculation of AUC, LogitBoost classifier, base64 encoder/decoder, round-off-error-free sum and cumsum, etc.

````
library(ORE)
library(dplyr)
library(OREdplyr)
library(caTools)

options(ore.warn.order=FALSE)
````

Note: OML4R is the new name for Oracle R Enterprise.

4. A Oracle 21c database instance (MLPDB1) has been provisioned for your to run this lab. Connect to the provided database.
 
````
ore.connect(user="oml_user",
            conn_string="MLPDB1",
            host=“<“hostname>,
            password=“<“password>,
            all=TRUE)
````
 
Note: Your database connection is to the database schema where the data resides. The connection port defaults to 1521. 


By specifying “all = TRUE”, proxy objects are loaded for all tables in the target schema. You can use ore.disconnect() to explicitly disconnect the database session.

 
5. Check if connection to database is established.

````
ore.is.connected()
````

 Note: ore.is.connected returns TRUE if you are connected to an Oracle Database. 

 
6. Use the ore.ls function call to check which tables are in the database schema you are connected to.

````
ore.ls()
````

Note: Database tables appear as ORE frames.

 

# Task 2: Explore data 

 In this section, we will do basic data exploration, looking at database objects, and understanding the data to some extent.
 
7. Check class of an object (data table)
 
````
 class(CUST_INSUR_LTV)
````
 
Note: The database table appears as "ore.frame"
 

 8. Get column names of a table
 
````
colnames(CUST_INSUR_LTV)
````

 Note: The column list appears as an ordered list.
 

 9. Check object dimensions (which are row and column counts)
 
````
dim(CUST_INSUR_LTV)
````

 10. Check data summary for a given object
 
````
summary(CUST_INSUR_LTV[,1:20])
````

 Note: You can specify one or more, or a range of columns to see the summary of only those columns.

 
11. Statistical exploration: Check min(), max(), unique() etc. for different attributes in the given table (ore.frame)

````
min(CUST_INSUR_LTV$SALARY)
max(CUST_INSUR_LTV$AGE)
unique(CUST_INSUR_LTV$N_OF_DEPENDENTS)
unique(CUST_INSUR_LTV$REGION)
````

 12. Statistical exploration: Check average value in a numeric column (note that MEAN is the statistical average)

````
 mean(CUST_INSUR_LTV$N_OF_DEPENDENTS)
````

 13. Statistical exploration: Check MODE (i.e., the most frequently occurring observation for an attribute)
 
````
x <- CUST_INSUR_LTV$N_OF_DEPENDENTS     
names(table(x))[table(x)==max(table(x))]

````

 14. Statistical exploration: Check percentiles (this may be useful to identify outlier limits)
 
````
lower_bound <- quantile(CUST_INSUR_LTV$SALARY, 0.025)
lower_bound
upper_bound <- quantile(CUST_INSUR_LTV$SALARY, 0.975)
upper_bound

````
               
15. Data exploration: Group data, filter data etc.

````
CUSTBIN = aggregate(CUST_INSUR_LTV$LTV_BIN, by = list(LTV_BIN = CUST_INSUR_LTV$LTV_BIN),FUN = length)
CUSTBIN

filter(CUST_INSUR_LTV, region == “NORTHEAST”)
CUST_INSUR_LTV %>% filter(SALARY > mean(SALARY, na.rm = TRUE))

````


# Task 3: Visualize data

In this section we will try to visualize some of the data provided in the dataset. This includes drawing plots, graphs, and histograms, etc.
 
 
16. Data visualization: Plot the age attribute using box plot. This can help see the concentration of customers in specific age bands and relative number of outliers, etc.

```` 
boxplot(CUST_INSUR_LTV$AGE)
````

17: Data visualization: Simple plot (salary). 

````
plot(CUST_INSUR_LTV$SALARY/1000)
````

18. Data visualization: Histograms help see distribution of data / attributes in range bands. R/ORE transparently identifies what it sees as appropriate band ranges. See data in histogram, pie chart (TBD)

````
hist(CUST_INSUR_LTV$SALARY/1000)
````

19. Data visualization: Check outliers on a box plot. 

````
out <- boxplot.stats(CUST_INSUR_LTV$AGE)$out
boxplot(CUST_INSUR_LTV$AGE, ylab = "Age")
mtext(paste("Outliers: ", paste(unique(out), collapse = ", ")))
````

       
# Task 4: Perform exploratory data analysis

 
20. Use Attribute Importance (ore.odmAI) function to identify important attributes (listed in order of importance) for a given dependent attribute (LTV) in the given dataset. To do this we first exclude the most significant dependent attribute from the data frame.
 


````
CIL <- CUST_INSUR_LTV
CIL$LTV <- NULL
dim(CIL)

ore.odmAI(LTV_BIN ~ ., CIL)
````

Note: The output lists all the important attributes and their relative influce on the target attribute. Since LTV_BIN is directly related to LTV for a customers, we excluded LTV from the data frame before running ore.odmAI.
           
21. Use Attribute Importance (AI) to identify important attributes for a given dependent attribute (LTV_BIN) in the given dataset. 

AI for LTV_BIN (Exclude LTV_BIN from dataset)

````
CIL <- CUST_INSUR_LTV
CIL$LTV_BIN <- NULL
dim(CIL)
ore.odmAI(LTV ~ ., CIL)
````

Note: Attribute importance ranks attributes according to their significance in predicting a target. 

 
22. Perform principal component analysis (PCA)

````
prc0 <- prcomp(~  HOUSE_OWNERSHIP + N_MORTGAGES + MORTGAGE_AMOUNT + AGE + SALARY + N_OF_DEPENDENTS, data = CUST_INSUR_LTV, scale. = TRUE)
summary(prc0)
````

Note: Principal Component Analysis (PCA) is a technique used for exploratory data analysis, and to visualize the existing variation in a dataset that has several variables. 


 
# Task 5: Prepare data for model creation 

23. Create row names. You can use the primary key of a database table to order an ore.frame object.   

````
set.seed(1)
head(CUST_INSUR_LTV)
CIL <- CUST_INSUR_LTV
row.names(CIL) <- CIL$CUST_ID
head(row.names(CIL))
````

Note: The data in an Oracle Database table is not necessarily ordered. For some R operations, ordering is useful. By ordering an #ore.frame, you are able to index the ore.frame object by using either integer or character indexes. Using an ordered ore.frame object #that is a proxy for a SQL query can be time-consuming for a large data set. Therefore, OML4R attempts to create ordered ore.frame #objects by default.

24. Partition dataset for training and testing. Split the dataset into two buckets (training data set (~70%), and testing data set (~30%))

````
set.seed(1) 
sampleSize <- 4600 
ind <- sample(1:nrow(CIL),sampleSize) 
group <- as.integer(1:nrow(CIL) %in% ind) 
CIL.train <- CIL[group==FALSE,] 
dim(CIL.train) 
class(CIL.train) 
CIL.test <- CIL[group==TRUE,] 
dim(CIL.test) 
class(CIL.test) 
````

            
# Task 6: Build ML models


Use a REGRESSION Model for LTV Prediction

25. Build regression model to predict customer LTV using the training data set

````
oreFit1 <- ore.odmGLM(LTV ~ N_MORTGAGES + MORTGAGE_AMOUNT + N_OF_DEPENDENTS, data = CIL.train, ridge=TRUE)
oreFit1 %>% print()
class(oreFit1)
summary(oreFit1)
names(oreFit1)
oreFit1$formula
oreFit1$ridge
````

 Note: # Change TYPE parameter (check in ore.odmGLM doc) 


26. Generate predictions
 
````
predA = ore.predict(oreFit1, newdata = CIL.test)
predA
````

27. Compare actual and predicted values and validate

````
oreFit1 <- ore.odmGLM(LTV ~ N_MORTGAGES + MORTGAGE_AMOUNT + N_OF_DEPENDENTS, data = CIL.train, ridge=TRUE)
CIL <- CUST_INSUR_LTV
CIL_pred <- ore.predict(oreFit1, CIL, se.fit = TRUE, interval = "prediction")
CIL <- cbind(CIL, CIL_pred)
head(CIL) 
library(OREdplyr)
head(select (CIL, LTV, PREDICTION))
````

 
 Use a CLASSIFICATION Model for LTV_BIN Prediction

 
28. Exclude highly correlated columns from the data frame

````
CIL <- CUST_INSUR_LTV
CIL$LTV_BIN <- NULL
dim(CIL)
````

29. Build regression model to predict customer LTV_BIN assignment using the training data set

````
oreFit2 <- ore.odmDT(LTV_BIN ~ ., data = CIL.train)
oreFit2 %>% print()
summary(oreFit2)
names(oreFit2)
oreFit2$formula
 
CIL <- CUST_INSUR_LTV
nb <- ore.odmNB(LTV_BIN ~ N_MORTGAGES + MORTGAGE_AMOUNT + N_OF_DEPENDENTS, CIL.train)
nb.res <- predict (nb, CIL.test, "LTV_BIN")
head(nb.res,10)
with(nb.res, table(LTV_BIN,PREDICTION, dnn = c("Actual","Predicted")))
````

30. Generate predictions

````
predB = ore.predict(oreFit2, newdata = CIL.test)
predB
````

          
 
 # Task 7: Validate predictions
 
 
31. Validate LTV predictions using RMSE

````
ans <- predict(oreFit1, newdata = CIL.test, supplemental.cols = 'LTV')
localPredictions <- ore.pull(ans)
ore.rmse <- function (pred, obs) {
  sqrt(mean(pred-obs)^2)
}
ore.rmse(localPredictions$PREDICTION, localPredictions$LTV)
````

Mean square error is a useful way to determine the extent to which a regression model is capable of integrating a dataset.
The larger the difference indicates a larger gap between the predicted and observed values, which means poor regression model fit. #In the same way, the smaller RMSE that indicates the better the model.
Based on RMSE we can compare the two different models with each other and be able to identify which model fits the data better.



32. Produce confusion matrix for LTV_BIN predictions

````
confusion.matrix <- table(test$LTV_BIN, predB$PREDICTION)
dim(test$LTV_BIN)
class(test$LTV_BIN)
dim(predB)
class(predB)
confusion.matrix
summary(confusion.matrix)
````

33. Observe and evaluate accuracy of predictions
