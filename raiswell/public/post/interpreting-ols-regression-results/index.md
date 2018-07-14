<p>I recommend this book to help you understand where ordinary least squares (OLS) regression fits within the most common stastistical learning approaches.</p>
<p><a href="https://www.amazon.com/Introduction-Statistical-Learning-Applications-Statistics/dp/1461471370">James et al., <em>An Introduction to Statistical Learning: with Applications in R</em> (Springer Texts in Statistics) 1st ed. 2013, Corr. 7th printing 2017 Edition</a></p>
<p>With so many options available to students and practitioners it is rare to find a books that takes both an accessible-theoretical and practical approach to econometrics and machine learning.</p>
<div id="why-write-about-linear-regression-when-everyone-is-building-deep-learning-models" class="section level2">
<h2>Why write about linear regression when everyone is building deep learning models?</h2>
<p>The data come from the excellent <a href="https://archive.ics.uci.edu/ml/index.php">UCI Machine Learning Repository</a>. I browsed ‘Data Area/Business’. They are originally from a demand forecasting study involving a Brazilian logistics provider that delivers parcels for the financial services sector (amongst other sectors one would assume). I have included the original study reference below in the resources section. It is in Portuguese but can be translated online.</p>
<p>The researchers were using a neural network to predict total daily orders for delivery using the</p>
<pre class="r"><code>library(tidyverse) # load in tidyverse libraries for data manipulation</code></pre>
<pre><code>## ── Attaching packages ───────────────────── tidyverse 1.2.1 ──</code></pre>
<pre><code>## ✔ tibble  1.4.2     ✔ purrr   0.2.5
## ✔ tidyr   0.8.1     ✔ stringr 1.3.1
## ✔ readr   1.1.1     ✔ forcats 0.3.0</code></pre>
<pre><code>## ── Conflicts ──────────────────────── tidyverse_conflicts() ──
## ✖ stats::filter() masks dplyr::filter()
## ✖ stats::lag()    masks dplyr::lag()</code></pre>
<pre class="r"><code>full_data &lt;- read_csv2(&#39;https://archive.ics.uci.edu/ml/machine-learning-databases/00409/Daily_Demand_Forecasting_Orders.csv&#39;) # note we use read_csv2 not plain read_csv because the separators are semicolons not commas, which is evidently popular in Europe...and Brazil!</code></pre>
<p>Let’s change the names of some of the variables as they’re verbose. We’re interested in the target variable, which in this case is the total daily orders. I assume that because the data were used in a forecasting experiment, the orders by sector are known some time in advance of final daily orders. This matters less for our purposes as we are conducting inferential (why something happens) not predictive analyses. I also chose traffic controllers orders (renamed to ‘tcs’), and orders from the banking sector (2) (renamed to ‘bo2’).</p>
<pre class="r"><code>names(full_data)</code></pre>
<pre><code>##  [1] &quot;Week of the month (first week, second, third, fourth or fifth week&quot;
##  [2] &quot;Day of the week (Monday to Friday)&quot;                                
##  [3] &quot;Non-urgent order&quot;                                                  
##  [4] &quot;Urgent order&quot;                                                      
##  [5] &quot;Order type A&quot;                                                      
##  [6] &quot;Order type B&quot;                                                      
##  [7] &quot;Order type C&quot;                                                      
##  [8] &quot;Fiscal sector orders&quot;                                              
##  [9] &quot;Orders from the traffic controller sector&quot;                         
## [10] &quot;Banking orders (1)&quot;                                                
## [11] &quot;Banking orders (2)&quot;                                                
## [12] &quot;Banking orders (3)&quot;                                                
## [13] &quot;Target (Total orders)&quot;</code></pre>
<pre class="r"><code>full_data &lt;- full_data %&gt;% #renaming our variables of interest
  rename(tcs = &quot;Orders from the traffic controller sector&quot;,
         bo2 = &quot;Banking orders (2)&quot;,
         total_orders = &quot;Target (Total orders)&quot;)


data &lt;- full_data %&gt;% # reduce our dataframe to just the variables of interest
  select(total_orders, tcs, bo2)</code></pre>
<p>Let’s examine some basic properties of the variables by starting with the descriptive statistics using the <code>describe()</code> function from the ‘psych’ package. The three variables are all integers: numbers of packages. We have their means, standard deviations, medians, trimmed mean (defaults to 0.1), median absolute deviation (mad), the minimum value, the maximum value, range, skew, kurtosis, and the standard error. You may not be familiar with some of those terms. The trimmed mean is designed to remove outliers (top and bottom deciles by default). This is useful for understanding the distribution of the data, but outlier removal generally is not recommended as outlier observations contain information too, sometimes critical to our ultimate understanding of variable relationships. The median absolute deviation is the average of each variable’s variance from the mean. Unlike standard deviation, to avoid negative variance, the figures are rendered absolute (negatives made positive) rather than squared. The skew is the shape of the distribution of the data. Positive skew indicates a right-skew. Skew close to zero indicates a normal distribution. Negative skew indicates a left-skew. Kurtosis is how sharp or ‘pointy’ the distribution curve is. The standard error is - in full - the standard error of the mean, which is the square-root of the variance divided by the number of observations (60 in this case), e.g. for total orders the SE calculation is <code>sqrt(var(data$total_orders)/length(data$total_orders))</code>.</p>
<pre class="r"><code>library(psych) # load the &#39;psych&#39; package</code></pre>
<pre><code>## 
## Attaching package: &#39;psych&#39;</code></pre>
<pre><code>## The following objects are masked from &#39;package:ggplot2&#39;:
## 
##     %+%, alpha</code></pre>
<pre class="r"><code>describe(data)</code></pre>
<pre><code>##              vars  n      mean       sd   median   trimmed      mad    min
## total_orders    1 60 300873.32 89602.04 288034.5 289399.85 72681.50 129412
## tcs             2 60  44504.35 12197.91  44312.0  44328.92 13533.91  11992
## bo2             3 60  79401.48 40504.42  67181.0  75135.38 29116.04  16411
##                 max  range skew kurtosis       se
## total_orders 616453 487041 1.32     2.08 11567.57
## tcs           71772  59780 0.04    -0.34  1574.74
## bo2          188411 172000 0.90     0.14  5229.10</code></pre>
<pre class="r"><code>sqrt(var(data$total_orders)/60)</code></pre>
<pre><code>## [1] 11567.57</code></pre>
<p><strong>So what do these numbers tell us about our package data?</strong></p>
<pre class="r"><code>multi.hist(data, bcol = &quot;pink&quot;)</code></pre>
<p><img src="/post/2018-07-02-interpreting-ols-regression-results_files/figure-html/unnamed-chunk-6-1.png" width="672" /></p>
<pre class="r"><code>ggplot(data, aes(tcs, total_orders)) +
  geom_point() +
  geom_smooth(method = &quot;lm&quot;)</code></pre>
<p><img src="/post/2018-07-02-interpreting-ols-regression-results_files/figure-html/unnamed-chunk-7-1.png" width="672" /></p>
</div>
