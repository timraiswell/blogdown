<div id="installing-and-loading-the-reticulate-package" class="section level3">
<h3>Installing and Loading the Reticulate Package</h3>
<p>This package allows us to run Python 3 inside R Markdown chunks. You will need Python 3 installed. There are details on how to do that in the <a href="/resources/">Resources section</a> of the blog. I also needed to change Reticulate’s settings to point it at Python3 on my Mac. You can find those <a href="https://rstudio.github.io/reticulate/articles/versions.html">details here</a>.</p>
<p>Of course, you do not need to run Python from Rstudio, or within the R framework. It will be much easier for you to work through this exercise in IPython or a Jupyter Notebook via Anaconda.</p>
<pre class="r"><code>pacman::p_load(reticulate)
use_python(&#39;/usr/local/Cellar/python/3.6.5/bin/python3&#39;) # points reticulate at Python 3  </code></pre>
<p>We import the relevant Python packages for the ANOVA exercise. If you have installed Python 3 via Anaconda all of these packages will be installed already. If you installed Python3 using another method, e.g. Homebrew on MacOS, then you can run the <code>pip3 install -package_name-</code> command to install them.</p>
<pre class="python"><code>import pandas as pd # This is a common coding format in Python. The package is imported using a shorter name format so that function calls are faster to type. 
import numpy as np
import matplotlib as mpl
mpl.use(&#39;TkAgg&#39;) # I added this line as a fix to a Matplotlib error - it couldn&#39;t be imported to the python environment
import matplotlib.pyplot as plt 
import seaborn as sns
from scipy import stats
import statsmodels
import statsmodels.api as sm
from statsmodels.formula.api import ols</code></pre>
</div>
<div id="data-acquisition-and-transformation" class="section level3">
<h3>Data Acquisition and Transformation</h3>
<p>This data comes from the University of Sheffield in the UK. It is listed as an “R Dataset” but it is a .csv text file, which Python pandas can import with no problems at all. When I began on these notes I didn’t realize that the University also has an ANOVA lesson based on this data. You can access the very useful R-based <a href="https://www.sheffield.ac.uk/polopoly_fs/1.536445!/file/MASH_ANOVA_in_R.pdf">notes here</a>.</p>
<pre class="python"><code>diet = &quot;https://www.sheffield.ac.uk/polopoly_fs/1.570199!/file/stcp-Rdataset-Diet.csv&quot; # reads in data
data = pd.read_csv(diet) # gives the data the name &#39;data&#39;
data[&#39;Loss&#39;] = data[&#39;pre.weight&#39;] - data[&#39;weight6weeks&#39;] #creates a target variable of weight loss. 
print(data.head()) # reviews the modified pandas data frame.</code></pre>
<pre><code>##    Person gender  Age  Height  pre.weight  Diet  weight6weeks  Loss
## 0      25          41     171          60     2          60.0   0.0
## 1      26          32     174         103     2         103.0   0.0
## 2       1      0   22     159          58     1          54.2   3.8
## 3       2      0   46     192          60     1          54.0   6.0
## 4       3      0   55     170          64     1          63.3   0.7</code></pre>
</div>
<div id="data-description" class="section level3">
<h3>Data Description</h3>
<blockquote>
<p><em>“The data set Diet.csv contains information on 78 people who undertook one of three diets. There is background information such as age, gender (Female=0, Male=1) and height. The aim of the study was to see which diet was best for losing weight so the independent variable (group) is diet.”</em> - <strong>The University of Sheffield’s Mathematics and Statistics Help Department (MASH)</strong></p>
</blockquote>
<p>We check the data types and find that ‘Diet’ - our independent variable - is being treated as an integer rather than a categorical variable. In R we would convert it to a factor; in Python we convert it to the equivalent: a categorical variable.</p>
<pre class="python"><code>print(data.dtypes) # list variable types </code></pre>
<pre><code>## Person            int64
## gender           object
## Age               int64
## Height            int64
## pre.weight        int64
## Diet              int64
## weight6weeks    float64
## Loss            float64
## dtype: object</code></pre>
<p>This chunk of code contains the pandas conversion:</p>
<pre class="python"><code>data[&#39;Diet&#39;] = pd.Categorical(data[&#39;Diet&#39;]) # Change Diet to a categorical variable</code></pre>
<p>We check that the conversion was successful and see that Diet is now listed as ‘category’:</p>
<pre class="python"><code>print(data.dtypes) # list variable types </code></pre>
<pre><code>## Person             int64
## gender            object
## Age                int64
## Height             int64
## pre.weight         int64
## Diet            category
## weight6weeks     float64
## Loss             float64
## dtype: object</code></pre>
</div>
<div id="question-for-investigation-are-the-three-diets-equally-effective-for-weight-loss" class="section level3">
<h3>Question for investigation: Are the three diets equally effective for weight loss?</h3>
<p>ANOVA cannot <em>prove</em> causation. It can tell us whether the mean weight loss of each diet group are different at a statistically significant level. In this case, our null hypothesis is that <strong>all group mean weight losses are the same.</strong></p>
<p>We start by visualizing the impact of each diet on the weight loss variable with a box plot. We use the Seaborn data visualization package. Figure 1 tells us that Diet 3 seems to be the most effective; it has the highest mean weight loss. The standard deviations of each diet look similar.</p>
<p>Analysis of Variance or ANOVA tells us whether the differences in the variance <em>between</em> each diet group are statistically significant when compared to the differences <em>within</em> each group.</p>
<p>One of the core assumptions with ANOVA is that the dependent variable is normally distributed.</p>
<pre class="python"><code>sns.set(font_scale=1.6)  #sets font size for chart scales
ax = sns.boxplot(x = &quot;Diet&quot;, y = &quot;Loss&quot;, data = data, # calls the boxplot
                 palette=&quot;Set1&quot;, # sets color scheme 
                 linewidth = 2) # sets chart line width
ax.set_title(&quot;Figure 1. Boxplot of Weight Loss by Diet Type\n&quot;, fontsize=16) # title 
ax.set_ylabel(&quot;Weight\nLoss&quot;, rotation = 0, fontsize=16, labelpad=50) # y-axis label
ax.set_xlabel(&quot;Diet&quot;, rotation = 0, fontsize=16) # x-axis label
plt.show()</code></pre>
<p><img src="/post/2018-05-27-one-way-anova-in-python_files/figure-html/unnamed-chunk-8-1.png" width="1152" /></p>
<pre class="python"><code>plt.gcf().clear() # you do not need to use this line to flush the mpl cache if you&#39;re running this in pure Python (as opposed to through R). If I don&#39;t run this line, box chart elements merged with  histogram below. </code></pre>
<p>Create a histogram of the weight loss dependent variable:</p>
<pre class="python"><code>plt.hist(data[&#39;Loss&#39;], bins=&#39;auto&#39;) # check for variable normality in weight loss dependent variable. 
#Data looks normally distributed.
plt.title(&quot;Figure 2. Distribution of Weight Loss Variable, lbs\n&quot;)
plt.xlabel(&quot;Weight Loss - lbs&quot;)
plt.ylabel(&quot;Count\nof Dieters&quot;, rotation = 0, labelpad = 40)
plt.show()</code></pre>
<p><img src="/post/2018-05-27-one-way-anova-in-python_files/figure-html/unnamed-chunk-9-1.png" width="1152" /></p>
<p>We now confirm our intuition from the visualization that the weight loss data is normally distributed. The p-score is higher than our alpha of 0.05, showing our intuition to be correct.</p>
<pre class="python"><code>print(stats.normaltest(data[&#39;Loss&#39;], axis=0))
# statistical normality test to check the visual test. 
# P &gt; 0.05 therefore We cannot reject the hypothesis that the sample comes from a population which has a normal distribution</code></pre>
<pre><code>## NormaltestResult(statistic=0.8256032683724894, pvalue=0.6617935470237468)</code></pre>
<p>Now we create an Ordinary Least Squares (OLS) model as a precursor to the ANOVA. I won’t print the results as I’ll be writing about interpreting OLS results in a future note.</p>
<pre class="python"><code>model = ols(&quot;Loss ~ Diet&quot;, data).fit()  # builds the OLS model, predicting weight loss with diet type.</code></pre>
<p>Before the ANOVA, we check the OLS residuals are normally distributed. This is another important prior assumption. The residuals look approximately normal.</p>
<pre class="python"><code>resids = statsmodels.regression.linear_model.RegressionResults.resid(model) # grabs the residual values from the OLS model
hist2 = plt.hist(resids, bins = &#39;auto&#39;, color=&#39;dodgerblue&#39;) # check for variable normality in weight loss dependent variable. 
#Data looks normally distributed.
plt.title(&quot;Figure 3. Distribution of OLS Model Residuals&quot;)
plt.xlabel(&quot;Residual Values&quot;)
plt.ylabel(&quot;Count&quot;, rotation = 0, labelpad = 40)
plt.show()</code></pre>
<p><img src="/post/2018-05-27-one-way-anova-in-python_files/figure-html/unnamed-chunk-13-1.png" width="1152" /></p>
<p>We now call the ANOVA function, applying it to the linear model. We are looking for a p-score lower than 0.05, which will show a statistically significant difference between mean weight losses. It will not tell us <em>where</em> those differences exist, just <em>whether</em> they exist. The p-score of <strong>0.003229</strong> shows that they do.</p>
<pre class="python"><code>table = sm.stats.anova_lm(model, typ=2) # Type 2 ANOVA DataFrame
print(table) 
# In a one-way ANOVA the null hypothesis is that the means of the Diet types are equal. We can reject that hypothesis
# because P &lt; 0.05 </code></pre>
<pre><code>##               sum_sq    df         F    PR(&gt;F)
## Diet       71.093689   2.0  6.197447  0.003229
## Residual  430.179259  75.0       NaN       NaN</code></pre>
</div>
<div id="but-which-diet-is-the-best-one-for-weight-loss" class="section level3">
<h3>But which diet is the best one for weight loss?</h3>
<p>This question is out of the scope of the ANOVA, though our analysis is an important precursor to answering this more specific question. We can check with a <em>post hoc</em> Tukey test.</p>
<pre class="python"><code>from statsmodels.stats.multicomp import pairwise_tukeyhsd
from statsmodels.stats.multicomp import MultiComparison
mc = MultiComparison(data[&#39;Loss&#39;], data[&#39;Diet&#39;])
tkresult = mc.tukeyhsd()
 
print(tkresult)</code></pre>
<pre><code>## Multiple Comparison of Means - Tukey HSD,FWER=0.05
## ============================================
## group1 group2 meandiff  lower  upper  reject
## --------------------------------------------
##   1      2    -0.2741  -1.8806 1.3325 False 
##   1      3     1.8481   0.2416 3.4547  True 
##   2      3     2.1222   0.5636 3.6808  True 
## --------------------------------------------</code></pre>
<p>It looks like the Diet 3 group lost the most weight. The second row of results shows a <strong>1.85</strong> mean difference in weight loss between Diets 2 and 3. The third row shows the mean difference for those on Diet 2 after we subtract the second row results from it: <code>2.12 - 1.85 = 0.27</code>. So the Diet 2 group only lost an average of <strong>0.27 lbs</strong> more than the Diet 1 group. Again, let me stress that this is not a definitive causal analysis. All we have established is that the three dieting groups differ in weight loss performance from one another, and by what average margin.There may well be other confounding factors at play causing the weight loss.</p>
</div>
<div id="references" class="section level3">
<h3>References</h3>
<ul>
<li>
<a href="http://cleverowl.uk/2015/07/01/using-one-way-anova-and-tukeys-test-to-compare-data-sets/">‘Using One-way ANOVA and Tukey’s test to compare data sets’</a>, Clever Owl, July 1, 2015
<li>
<a href="https://www.sheffield.ac.uk/mash/statistics2/anova">‘ANOVA’</a>, University of Sheffield, December 2015.
<li>
D.L. Couturier, R. Nicholls, M. Fernandes, <a href="https://bioinformatics-core-shared-training.github.io/linear-models-r/ANOVA.html">‘ANOVA with R: analysis of the diet dataset’</a>, Bioinformatics Training Materials, May 10, 2018.
</ul>
</div>
