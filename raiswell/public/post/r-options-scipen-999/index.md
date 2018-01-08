<p><code>options(scipen = 999) # this command turns off scientific notation in R output</code></p>
<p>But why would you want to turn off scientific notation?</p>
<p>Scientific notation is shorthand for large number sequences. For example:</p>
<blockquote>
<p>The number <code>0.00000000002</code> is written in R output in the scientific notation format as <strong>2e-11</strong></p>
</blockquote>
<p>Basically, this approach takes the integer “2”, puts a decimal point in front of it (1 of the 11), and counts off remainder of the e-number (10) as decimal places. So, zero-point-ten-zeros-two. The number <strong>4e-16</strong> would be zero-point-fifteen-zeros-four.</p>
<p>If you build a predictive model like a linear regression (using the lm() function in R) and then summarise its output, R will use scientific notation in the output. For a fast example of what I mean, run this code in R’s console, substituting the number for anything you like.</p>
<p><code>x &lt;- 0.00000000002</code></p>
<p><code>format(x, scientific = TRUE)</code></p>
<p>Perhaps because I have humanities training and, like many, arrived a little later in my career to the data science party, I prefer to view and compare full number strings when I’m examining data mining results. There’s something satisfying to me about feeling the weight of all the zeroes in the p-values of a model I have built.</p>
<p>For a demonstration of what I’m talking about, let’s build a simple linear model using an accessible dataset, and view the output using the broom package’s ‘tidy’ function.</p>
<p>First I use an R package called <a href="https://cran.r-project.org/web/packages/pacman/vignettes/Introduction_to_pacman.html">‘pacman’</a> to load in the libraries I need for the project. As package authors Tyler W. Rinker &amp; Dason Kurkiewicz say in the package vignette documentation:</p>
<blockquote>
<p>“The function p_load is particularly well suited for help forums and blog posts, as it will load and, if necessary, install missing packages.”</p>
</blockquote>
<pre class="r"><code>#install.packages(&quot;pacman&quot;) -this line is commented because I already have the pacman package installed. 
pacman::p_load(broom, ggplot2)</code></pre>
<p>Okay, a linear model. First, I visualize the data with ggplot2.</p>
<pre class="r"><code>ggplot(data = cars, aes(x = speed, y = dist)) + geom_point() + geom_smooth(method = &quot;lm&quot;, 
    se = FALSE) + labs(title = &quot;Faster-moving cars have greater stopping distances&quot;, 
    subtitle = &quot;There is a positive linear relationship in the data between car speed and stopping distance.&quot;, 
    x = &quot;Speed of car (MPH)&quot;, y = &quot;Stopping\ndistance (feet)&quot;) + theme_classic() + 
    theme(axis.title.y = element_text(angle = 0, vjust = 1))</code></pre>
<p><img src="/post/2018-01-04-r-options-scipen-999_files/figure-html/unnamed-chunk-2-1.png" width="672" /></p>
<p>Then I build the linear regression using the lm() function in R. Stopping distance is the target variable we want to predict, using car speed at time of breaking as the descriptive variable we want to employ in the prediction.</p>
<p>Here is how I view a description of the data. Enter this short string into your R console. Putting a question mark before a package name or function results in help documentation in R. One reason I love the language.</p>
<p><code>?cars</code></p>
<p>Now, the code for the model:</p>
<p>Let’s take a look at the results of the regression analysis. Becuase we set the ‘scipen’ option to a large number earlier (999), we can see the p-values in their full glory. In a future post, I will cover how to interpret R’s output for the lm() function and the simple linear regression.</p>

<pre class="r"><code>tidy(car_lm)
</code></pre>

<pre><code>
##          term   estimate std.error statistic              p.value
## 1 (Intercept) -17.579095 6.7584402 -2.601058 0.012318816153809090
## 2       speed   3.932409 0.4155128  9.463990 0.000000000001489836
</code></pre>
