## Statistics

### Types of variables
SS Stevens. On the theory of scales measurements is a classic paper on statistics. That is where the 4 different types of variables were defined.

* **Nominal**. To name types of instances. Assign individual cases to categories. For example, country of origin would be a nominal variable.
* **Ordinal**. These variables are used to rank order cases. Rank countries according to population. 
* **Interval**. Used to rank order cases but the distance, or interval between each value is equal. For example longitude or latitude are interval variables.
* **Ratio**. The same as interval but these type of variables have a true Zero point.

### Scales of measurement
In statistics there is a standard scale called the Z scale.

* Any score from any scale can be converted to a Z scale, which eases interpretation

$$  z = \frac{X - M}{SD} $$

where X is a score on an original scale (raw score)
M is the mean and SD is the standard deviation.

The mean Z score is going to be 0. $Z = 0$. So a positive Z score means that the observation was above average, whereas a negative Z score means that the observation was below average.

* Percentile ranking
We can easily get percentile rank. If something has Z = 0 then 50% of the distribution falls below the mean.

### Summary statistics

#### Measures of central tendency
All measures of central tendency try to capture the center point of a distribution.

* **Mean** 
$$ M = \frac{\sum{X}}{N} $$

* **Median** The middle value in a distribution. If you line up all the values from the highest ranking to the lowest ranking the one at the 50% is the median. When you have a non-normal distribution with extreme values then it might be better to use the median.

* **Mode**. The value that occurs most often in the distribution.

#### Measures of variability
Measures of variability try to capture the spread, or how wide a distribution is.

* **Standard deviation**. The average deviation from the mean in a distribution.

$$  SD^2 = \frac{\sum{(X - M)^2}}{N}  $$

* **Variance**. The square of the standard deviation.


### Correlation
A statistical analysis that is used to describe and measure the relationship between two variables.

The correlation ranges from -1 to 1. 0 means no correlation, 1 perfect correlation and -1 perfect anti-correlation.

#### Caution about correlation
* **Correlation does not imply causation**. Variable X doesn't cause Y and Y doesn't cause X. There could be a lot of intervening variables that could cause X or Y.
* **The magnitude of the correlation depends on sampling**. The correlation presupposes random and representative sampling.
* **Just a sample statistic**
A correlation coefficient is a sample statistic and is therefore not representative of every individual from the population.
* **Several types of correlation coefficients**
There are several types of correlation coefficients depending on what type of variable you are dealing with. Pearson product moment correlation is the most common one, but there are other ones like the Phi correlation.

#### Calculating the correlation coefficient r

There are two ways to calculate it
* Raw score formula
* Z-score formula


Conceptually the correlation r is the degree to which X and Y very together (covariance), relative to the degree to which they vary independently (variance of X and Y).

#### Raw score formula

$$ Variance = SD^2 = MS (Mean Squares) = SS (Sum of Squares)/N $$

Deviation, how much does each observation differ from the average.
$$ Deviation = X_i - \bar{X}$$

We can't sum the deviations because they would add up to zero. To fix that, we square the deviations and that is the **Sum of Squares (SS)**. 

To calculate the correlation coefficient between X and Y we need to calculate the **Sum of cross Products (SP)**. 
* For each row, calculate the deviation score of X from it's mean
* For each row, calculate the deviation score of Y from it's mean
* Take the product of each row
* Sum all the rows. 

$$ SP_{XY} = \sum{(X_i - \bar{X}) \times (Y_i - \bar{Y})} $$

$$ r = \frac{SP}{\sqrt{SS_X \times SS_Y}} $$


#### Z-score formula
If everything is already in z-score format then the formula for the correlation coefficient is:

$$ r = \sum{\frac{Z_X \times Z_Y}{N}} $$

#### Assumptions in correlation analysis
* **Normal Distributions for X and Y**. How do we detect violations of this assumption. Plot the histograms. If it's hard to detect by eye, run summary statistics and see if they agree with a normal distribution.
* **Linear Relationship between X and Y**.
* **Homoscedasticity**. In a scatterplot the vertical distance between a dot and the regression line reflects the amount of prediction error (known as the residual). The idea of homoscedasticity is that the residuals are not related to X, i.e. they are not systematic but random. The classic example to illustrate several of the assumptions underlying correlation and regression are in 1973 Dr. Frank Anscombe. He created 4 artificial examples where the correlation was exactly the same, but clearly some assumptions were violated.
* Reliability of X and Y.
* Validity of X and Y.
* Random and representative sampling.


#### When to divide by N or N-1.
In general, when doing descriptive statistics divide by N. When doing inferential statistics like regression divide by N-1