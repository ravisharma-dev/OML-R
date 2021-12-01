{\rtf1\ansi\ansicpg1252\cocoartf2580
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 ## Oracle Machine Learning for R (OML4R)\
\'a0\
# Oracle Machine Learning for R (OML4R) enables you to use R (a statistical programming language) for statistical analysis, data \
# exploration, machine learning, and graphical analysis of data stored in an Oracle database. This allows you to benefit from the \
# simplicity of R and the power of Oracle Database without the need to deal with the complexities of sourcing, moving, and securing \
# data.\
\'a0\
# In this workshop, you will use a dataset representing 15,000 customers of an insurance company. Each customer has about 30 \
# attributes, and the goal is to train the model to predict a given customer's life-time value (LTV) using regression algorithms, and \
# alternatively, using binned LTV categories to use classification algorithms to classify customers as asLOW, MEDIUM, HIGH, or VERY # HIGH LTV.\'a0\
\'a0\
# Note: In marketing, the life-time value (LTV) of a customer is an estimate of the net profit attributable to a given customer \
# relationship over its lifetime.\
\'a0\
# **Estimated Lab Time:** 2 hours\
\'a0\
# **Objectives**\
# In this lab, you will:\
\'a0\
# * Establish a connection from RStudio to your Oracle Database instance to prepare, explore, and visualize data.\
# * Use R for exploratory data analysis, data visualization, data organization (bucketing), \
# * Use Algorithm Selection, Feature Selection, Model Selection, and Model Tuning\
# * Use an OML4R CLASSIFICATION model for LTV_BIN assignment\
# * Use an OML4R REGRESSION model for estimating customer life-time value (LTV)\
# * Build models explicitly using OML4R API\
\
# Note:\
# * AutoML is currently not available for OML4R (it is only available for OML4Py)\
# * AutoML UI is currently available for ADB ONLY\
# * OML4R is currently not available for ADB\
\
# **Prerequisites**\
# * Oracle Database 21c, 19c, or 18c installed on-premises (or in a VM in Cloud);\
# * R, RStudio, and required libraries\
\
# **Task 1:\'a0Connect to RStudio client and establish database connection**\
\
# 1. Point browser to RStudio Web.\
\
````\
http://<ip-address>:8787\
````\
\
# Note: Alternatively, you can use RStudio Desktop.\
\
# 2. Connect to RStudio using credentials \'93oracle/<RStudio-Password-Provided>\'94\
\'a0\
# 3. Load ORE library\'a0\
\
````\
library(ORE)\
library(dplyr)\
library(OREdplyr)\
library(caTools)\
\
options(ore.warn.order=FALSE)\
````\
\
# Note: OML4R is the new name for Oracle R Enterprise.\
\
# 4. Connect to the 21c database and check connectivity\
\'a0\
````\
ore.connect(user="oml_user",\
\'a0 \'a0 \'a0 \'a0 \'a0 \'a0\'a0conn_string="MLPDB1",\
\'a0 \'a0 \'a0 \'a0 \'a0 \'a0\'a0host=\'93<\'93hostname>,\
\'a0 \'a0 \'a0 \'a0 \'a0 \'a0\'a0password=\'93<\'93password>,\
\'a0 \'a0 \'a0 \'a0 \'a0 \'a0\'a0all=TRUE)\
\'a0````\
 \
# Note: You connect to the schema. Port defaults to 1521. \
# By specifying \'93all = TRUE\'94, proxy objects are loaded for all tables in the target schema.  \
# Use ore.disconnect() to explicitly disconnect.\
\
# 5. Check if connection to database is established.\
\
ore.is.connected()\
\'a0\
# Note: ore.is.connected returns TRUE if you\'92re already connected to an Oracle Database \
\
# 6. What tables are in the database schema we connected to?\
\'a0\
ore.ls()\
\'a0\
# Note: Database tables appear as ORE frames.\
\'a0\'a0\
**Task 2:\'a0Explore data**\'a0\
\'a0\
# 7. Check class of an object (data table)\
\'a0\
class(CUST_INSUR_LTV)\
\'a0\
# Note: The database table appears as "ore.frame"\
\'a0\
# 8. Get column names in an object\
\'a0\
colnames(CUST_INSUR_LTV)\
\'a0\
# Note: The column list appears as an ordered list.\
\'a0\
# 9. Check object dimensions (row and column counts)\
\'a0\
dim(CUST_INSUR_LTV)\
\'a0\
# 10. Check data summary in the object\
\'a0\
summary(CUST_INSUR_LTV[,1:20])\
\'a0\
# Note: You can specify one or more, or a range of columns\
\'a0\
# 11. Statistical exploration: Check min(), max(), unique() etc. for different attributes\
\'a0\
min(CUST_INSUR_LTV$SALARY)\
max(CUST_INSUR_LTV$AGE)\
unique(CUST_INSUR_LTV$N_OF_DEPENDENTS)\
unique(CUST_INSUR_LTV$REGION)\
\'a0\
# 12. Statistical exploration: Check average (MEAN is statistical average)\
\'a0\
mean(CUST_INSUR_LTV$N_OF_DEPENDENTS)\
\'a0\
# 13. Statistical exploration: Check MODE (Most frequently occurring observation)\
\'a0\
x <- CUST_INSUR_LTV$N_OF_DEPENDENTS\'a0 \'a0 \'a0\
names(table(x))[table(x)==max(table(x))]\
\'a0\
# 14. Statistical exploration: Check percentiles (e.g., to identify outlier limits)\
\'a0\
lower_bound <- quantile(CUST_INSUR_LTV$SALARY, 0.025)\
lower_bound\
\'a0\'a0 \'a0 \'a0 \'a0 \'a0 \'a0\
upper_bound <- quantile(CUST_INSUR_LTV$SALARY, 0.975)\
upper_bound\
\'a0\
# 15. Data exploration: Group data, filter data\'a0\
\'a0\
CUSTBIN = aggregate(CUST_INSUR_LTV$LTV_BIN, by = list(LTV_BIN = CUST_INSUR_LTV$LTV_BIN),FUN = length)\
CUSTBIN\
\'a0\
filter(CUST_INSUR_LTV, region == \'93NORTHEAST\'94)\
CUST_INSUR_LTV %>% filter(SALARY > mean(SALARY, na.rm = TRUE))\
\'a0\'a0\
# **Task 3:\'a0Visualize data**\'a0\
\'a0\
# 16. Data visualization: Plot age using box plot\
\'a0\
boxplot(CUST_INSUR_LTV$AGE)\
\'a0\
# 17: Data visualization: Simple plot (salary)\
\'a0\
plot(CUST_INSUR_LTV$SALARY/1000)\
\'a0\
# 18. Data visualization: See data in histogram, pie chart (TBD)\
\'a0\
hist(CUST_INSUR_LTV$SALARY/1000)\
\'a0\
# 19. Data visualization: Check outliers on a box plot\
\'a0\
out <- boxplot.stats(CUST_INSUR_LTV$AGE)$out\
boxplot(CUST_INSUR_LTV$AGE, ylab = "Age")\
mtext(paste("Outliers: ", paste(unique(out), collapse = ", ")))\
\
# **Task 4:\'a0Perform exploratory data analysis**\
\'a0\
# 20. Use Attribute Importance (AI) to identify important attributes for a given dependent attribute (LTV) in the given dataset.\'a0\
\'a0\
# AI for LTV (Exclude LTV from dataset)\
\
CIL <- CUST_INSUR_LTV\
CIL$LTV <- NULL\
dim(CIL)\
\
ore.odmAI(LTV_BIN ~ ., CIL)\
\
# 21. Use Attribute Importance (AI) to identify important attributes for a given dependent attribute (LTV_BIN) in the given dataset.\'a0\
\
# AI for LTV_BIN (Exclude LTV_BIN from dataset)\
\
CIL <- CUST_INSUR_LTV\
CIL$LTV_BIN <- NULL\
dim(CIL)\
ore.odmAI(LTV ~ ., CIL)\
\'a0\
# Note: Attribute importance ranks attributes according to their significance in predicting a target.\'a0\
\'a0\
# 22. Perform principal component analysis (PCA)\
\'a0\
prc0 <- prcomp(~\'a0\'a0HOUSE_OWNERSHIP + N_MORTGAGES + MORTGAGE_AMOUNT + AGE + SALARY + N_OF_DEPENDENTS, data = CUST_INSUR_LTV, scale. = TRUE)\
summary(prc0)\
\'a0\
# Note: Principal Component Analysis (PCA) is a technique used for exploratory data analysis, and to visualize the existing variation in a dataset that has several variables.\'a0\
\'a0\
**Task 5:\'a0Prepare data for model creation **\
\'a0\
# 23. Create row names. You can use the primary key of a database table to order an ore.frame object.\uc0\u8232  \'a0\
\
set.seed(1)\
head(CUST_INSUR_LTV)\
CIL <- CUST_INSUR_LTV\
row.names(CIL) <- CIL$CUST_ID\
head(row.names(CIL))\
\
#Note: The data in an Oracle Database table is not necessarily ordered. For some R operations, ordering is useful. By ordering an #ore.frame, you are able to index the ore.frame object by using either integer or character indexes. Using an ordered ore.frame object #that is a proxy for a SQL query can be time-consuming for a large data set. Therefore, OML4R attempts to create ordered ore.frame #objects by default.\
\
# 24. Partition dataset for training and testing. Split the dataset into two buckets (training data set (~70%), and testing data set (~30%))\
\
set.seed(1) \
sampleSize <- 4600 \
ind <- sample(1:nrow(CIL),sampleSize) \
group <- as.integer(1:nrow(CIL) %in% ind) \
CIL.train <- CIL[group==FALSE,] \
dim(CIL.train) \
class(CIL.train) \
CIL.test <- CIL[group==TRUE,] \
dim(CIL.test) \
class(CIL.test) \
\
# **Task 6:\'a0Build ML models **\
\
\
#\'a0Use a REGRESSION Model for LTV Prediction\
\
# 25. Build regression model to predict customer LTV using the training data set\
\'a0\
oreFit1 <- ore.odmGLM(LTV ~ N_MORTGAGES + MORTGAGE_AMOUNT + N_OF_DEPENDENTS, data = CIL.train, ridge=TRUE)\
oreFit1 %>% print()\
class(oreFit1)\
summary(oreFit1)\
names(oreFit1)\
oreFit1$formula\
oreFit1$ridge\
\'a0\
Note: # Change TYPE parameter (check in ore.odmGLM doc)\'a0\
\
# 26. Generate predictions\
\
predA = ore.predict(oreFit1, newdata = CIL.test)\
predA\
\
# 27. Compare actual and predicted values and validate\
\
oreFit1 <- ore.odmGLM(LTV ~ N_MORTGAGES + MORTGAGE_AMOUNT + N_OF_DEPENDENTS, data = CIL.train, ridge=TRUE)\
CIL <- CUST_INSUR_LTV\
CIL_pred <- ore.predict(oreFit1, CIL, se.fit = TRUE, interval = "prediction")\
CIL <- cbind(CIL, CIL_pred)\
head(CIL) \
library(OREdplyr)\
head(select (CIL, LTV, PREDICTION))\
\
# 28. Validate predictions using RMSE\
\
ans <- predict(oreFit1, newdata = CIL.test, supplemental.cols = 'LTV')\
localPredictions <- ore.pull(ans)\
ore.rmse <- function (pred, obs) \{\
  sqrt(mean(pred-obs)^2)\
\}\
ore.rmse(localPredictions$PREDICTION, localPredictions$LTV)\
\
#Mean square error is a useful way to determine the extent to which a regression model is capable of integrating a dataset.\
#The larger the difference indicates a larger gap between the predicted and observed values, which means poor regression model fit. #In the same way, the smaller RMSE that indicates the better the model.\
#Based on RMSE we can compare the two different models with each other and be able to identify which model fits the data better.\
\
\
#\'a0Use a CLASSIFICATION Model for LTV_BIN Prediction\
\
# 29. Exclude highly correlated columns from the data frame\
\
CIL <- CUST_INSUR_LTV\
CIL$LTV_BIN <- NULL\
dim(CIL)\
\
# 30. Build regression model to predict customer LTV_BIN assignment using the training data set\
\'a0\
oreFit2 <- ore.odmDT(LTV_BIN ~ ., data = CIL.train)\
oreFit2 %>% print()\
summary(oreFit2)\
names(oreFit2)\
oreFit2$formula\
\'a0\
CIL <- CUST_INSUR_LTV\
nb <- ore.odmNB(LTV_BIN ~ N_MORTGAGES + MORTGAGE_AMOUNT + N_OF_DEPENDENTS, CIL.train)\
nb.res <- predict (nb, CIL.test, "LTV_BIN")\
head(nb.res,10)\
with(nb.res, table(LTV_BIN,PREDICTION, dnn = c("Actual","Predicted")))\
\
# 31. Generate predictions\
\'a0\
predB = ore.predict(oreFit2, newdata = CIL.test)\
predB\
\'a0\
#32. Produce confusion matrix\
\'a0\
confusion.matrix <- table(test$LTV_BIN, predB$PREDICTION)\
dim(test$LTV_BIN)\
class(test$LTV_BIN)\
dim(predB)\
class(predB)\
confusion.matrix\
summary(confusion.matrix)\
\
# Observe and evaluate accuracy of predictions\
}