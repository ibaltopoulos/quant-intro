## Statistics

### Types of variables
SS Stevens. On the theory of scales measurements is a classic paper on statistics. That is where the 4 different types of variables were defined.

* **Nominal**. To name types of instances. Assign individual cases to categories. For example, country of origin would be a nominal variable.
* **Ordinal**. These variables are used to rank order cases. Rank countries according to population. 
* **Interval**. Used to rank order cases but the distance, or interval between each value is equal. For example longitude or latitude are interval variables.
* **Ratio**. The same as interval but these type of variables have a true Zero point.


### Measurement issues
#### Reliability
Reliability estimate - if I use an instrument to measure one property at one time and then use the same instrument to measure the same property at another time, then the measurements from time 1 to time 2 should be stable (e.g. think of a scale).

* **Classical test theory** (or true score theory). In a perfect world it would be possible to obtain a "true score" absent of any measurement error. So any raw score X is a combination of the true score, some bias and some chance error.
$$ X (raw score) = true score + bias + chance error $$

  This is also known as true score theory. 

  As a measure (X) approaches the true score, it is considered to be reliable. The problem is that we don't know what the true score is. So we estimate reliability. 
* **Reliability measures**.
  * Test / retest
  * Parallel test
  * Inter-item estimates


#### Validity
TBD 

#### Sampling
TBD

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


### Inferential statistics.

Regression is a statistical analysis used to predict scores on an outcome variable, based on one or multiple predictor variables.





#### Basics of regression
* Simple regression vs. multiple regression. The number of predictor variables. If there is only a single predictor variable we call the regression a simple one. When you have multiple predictors you talk about multiple regression. 

  In the case of simple regression you can plot the predicted line in 2D scatter plot. However when you have more than 2 predictor variables it's more difficult to visualise the results. 

* Components of the regression equation 
$$ Y = m + bX + e  $$

  Y is a linear function of X, m is the intercept and b is the slope. b is the rise over run. The notation above should be familiar from high school algebra, but the following notation is more common in statistics.

$$ Y = B_0 + B_1 X_1 + e $$

  B is the regression coefficient, \\( B_0 \\) is the intercept known as the regression constant, \\( B_1 \\) is the slope known as the regression coefficient.

  Model $R$. The correlation between the predicted scores and the observed scores.
  
  Model $R^2$. The proportion of variance in Y explained by the model.

* Evaluate a regression model

  The goal of inferential statistics is to produce better models so we can generate more accurate predictions. We can do this by:
  * Adding more predictor variables, or
  * Develop better predictor variables

#### Estimate the coefficients
The values of the coefficients are estimated such that the regression model yields optimal predictions. Minimise the residuals. This is done by:
1) calculating the residual (observed score - predicted score), 
2) square them to take away the sign (some will be over-predictions and some will be under-predictions, and 
3) Sum them all up 

$$ \text{SS.Residual} = \sum_i{ (Y_i - \hat{Y_i})^2 } $$


#### Assumptions underlying a basic linear regression
* Normal distribution for Y
* Linear relationship between X and Y
* Homoscedasticity


### Null hypothesis significance testing
NHST is a game we play as scientists. It is a general procedure that can be applied to several analyses. For example we can apply it to:
* **Correlation analysis** Is the correlation significantly different from zero?
* **Regression analysis** Is the slope of the regression line for X significantly different from zero? 

#### Formulation
Before we conduct a study or an experiment we construct 2 hypotheses
1) Null hypothesis \\( N_0 \\): e.g. The regression coefficient is zero \\( B_i = 0 \\) 
2) Alternative hypothesis \\( N_A \\): e.g. The regression coefficient is greater than zero \\( B_i \\gt 0 \\)

Depending on how you formulate the alternative hypothesis you can predict the direction of the relationship between X and Y (positive or negative).
* **Directional tests or one tail test**. In a directional test, the alternative hypothesis attempts to predict the direction of the relationship between X and Y. For example, \\( H_0 = 0 \\ \text{vs.}\\ H_A \gt 0 \\)
* **Non-directional test or two tail test**. If we are more agnostic and we don't predict the direction, we are performing a non-directional test. For example, \\( H_0 = 0 \\ \text{vs.}\\ H_A \ne 0 \\)

#### Perform the test
Entering our study we have to:
1) assume that the null hypothesis is true. 
2) Then do our study, calculate all the statistics and 
3) then reassess that assumption.

The critics of NHST argue that this step is counterintuitive as we never try to experiment to predict nothing or no relationship between two variables. It is weird and backwards that we do so in NHST.

Once we have completed the steps above, we want to estimate the probability of observing the data that we did observe given the initial assumption that the null hypothesis is true 

$$ p = P(D \mid H_0) $$

If the p value is very low then reject \\( H_0 \\), else retain \\( H_0 \\)


#### Outcomes
Once we've completed the analysis we need to decide whether we accept or reject the null hypothesis given the p-value we calculated.

Depending on the outcome there are 4 cases about whether our decision was correct or not.

<table>
<tr>
  <td>
    
  </td>
  <td>
    Accept Null Hypothesis
  </td>
  <td>
    Reject Null Hypothesis
  </td>
</tr>
<tr>
  <td>
    Null H is TRUE
  </td>
  <td>
    Correct decision
  </td>
  <td>
    Type I error (false alarm)
  </td>
</tr>
<tr>
  <td>
    Null H is FALSE
  </td>
  <td>
    Type II error (missed)
  </td>
  <td>
    Correct decision
  </td>
</tr>
</table>


On criticism of the NHST is that you have to make a binary decision to accept or reject the null hypothesis.

* **Type I error** (false alarm): 
* **Type II error** (a miss): There is an effect out there but we missed it for whatever reason.

The fact that we make errors is not a big issue since we will conduct the study several times and any individual study could lead to errors.

#### Interpreting the p-value
It is very important to understand what a p-value means.

It is the probability of obtaining the data we obtained through experimentation given the assumption that the null hypothesis is true, given the assumption that there is no relationship (no effect).

$$ p = P(D \mid H_0) $$

**CAUTION** It is not the flip of the statement above which is a very common mistake people make. 

#### Calculating the p-value
To get the p-value you first need to calculate the t-test.
The way to get the p-value for a regression analysis is to first calculate the t-value. 

Most NHST are ratios of what did you observe what do you get just due to chance. 
  
$$ Standard Error = \frac{\sqrt{SS.Residual}}{N - 2} $$

$$ t = \frac{B}{Standard Error}$$

The t-test is a ratio where B is the regression coefficient, relative to the standard error.



#### Problems with NHST
* **Biased by sample size**
  This can be seen in regression. The p-value out of the regression, depends on the t-value and the t-value depends on the sample size. N is in the denominator of the standard error equation. If N -> high, SE -> low, t -> high which is associated with a low p-value which will allow you to reject the null hypothesis regardless of what the slope of the regression is.
    
* **Arbitrary decision rule**
  We have to pick a value after which we can reject the null hypothesis. Usually in the social sciences use p < 0.05 which is completely arbitrary. 
  
* **Yokel local test**
  What you do as a common custom. People sometimes just do NHST because that is the only technique/procedure they have learned. This is a problem because it is the only thing people know and they oftentimes create weak hypothesis testing. 

* **Error prone**
  There is always a possibility of type I or type II errors. The probability of type I errors becomes higher as researchers repeat their tests on the same data.
  
  Sampling error, we get small samples out of big population which means that we are more likely to miss effects.

* **Shady logic**
  Modus tollens. If p then q. Not q, therefore not p.

  If the null hypothesis is correct, then this data cannot occur. The data has occurred so we can reject the null hypothesis.
  
  The problem is that the logic becomes probabilistic.

#### Remedies to NHST
* **Biased sample size -> Supplement all NHST with estimates of effect size**
  Whenever you report an effect, also report the magnitude of the effect. For regression always report the \\( R^2 \\)
* **Arbitrary decision rule -> Supplement NHST with estimates of effect size**
* **Learn other techniques of hypothesis testing**. Confidence intervals, Bayesian inference
* **Consider multiple alternative hypothesis**. Do model comparison after that
* **Error prone**. Replicate significant effects to avoid the long term impact of type I errors. Obtain large representative samples to avoid type II errors.



