<div id="are-manchester-united-fans-more-critical-of-their-team-than-opposing-fans-about-theirs" class="section level3">
<h3>Are Manchester United fans more critical of their team than opposing fans about theirs?</h3>
<p>This was the (too ambitious) question I intended to answer when I began this piece but having discovered some of the difficulties in accessing bulk, multi-period Twitter data I have scaled it back. I certainly intend to revisit the bigger question using Twitter scraping solutions that have since become available, but for now I’ll restrict myself to the more achievable question:</p>
</div>
<div id="is-there-evidence-in-tweets-from-football-fans-during-matches-that-one-fanbase-is-more-critical-than-another" class="section level3">
<h3>Is there evidence in tweets from football fans during matches that one fanbase is more critical than another?</h3>
<p>I was born and grew up in Manchester, England. I live in the US now and I’m forced to follow the English Premier League remotely. I track my Twitter feed during games to see the opinions of other fans. One thing I noticed was the propensity of Manchester United fans to expect heroics from the team on a weekly basis and I wondered whether it was any different for fans of other clubs. One way to tackle this is to examine the sentiment of opposing fans watching the same football match but necessarily wanting different outcomes: their own team to win. As we will see, this method is very far from experimental conditions, but the approach does give a better sense of the art of the possible.</p>
</div>
<div id="method" class="section level2">
<h2>Method</h2>
<p>First, I load the packages I’ll use in R. Tidyverse and tidytext will help me format the data and prepare my analysis. The twitteR and ROauth packages are what I will use to create my sentiment data for the football teams in question. If you do not have the pacman package installed, run the line <strong>install.packages(‘pacman’)</strong> in the console.</p>
<p>Full documentation for how to use both those Twitter-related packages can be found <a href="http://geoffjentry.hexdump.org/twitteR.pdf">here in the user vignette</a>.</p>
<pre class="r"><code>#Loading the relevant packages
pacman::p_load(tidyverse, twitteR, ROAuth, tidytext, psych,lubridate, SentimentAnalysis, scales, RCurl, tm, grid, wrapr, broom)</code></pre>
<p>Next, I setup my Twitter authentication information so I can start accessing the relevant API. You will need a Twitter account to do this. Full details are included the vignette linked above.</p>
<div id="data-acquisition" class="section level3">
<h3>Data acquisition</h3>
<p>I download a set of relevant tweets from the Twitter API for Manchester United’s game against Yeovil Town in the FA Cup played on January 26, 2018. I leave the date range broad (all of January 26) so that I can later refine the inquiry to tweets an hour before the match starts and shortly after it ends to capture pre-match expectations and post-game sentiment for both sets of fans.</p>
<pre class="r"><code>mufc_tweets1 &lt;- searchTwitteR(&quot;manchesterunited&quot;, n=2000, lang=&quot;en&quot;, since=&quot;2018-01-26&quot;, until = &quot;2018-01-26&quot;) %&gt;% 
  strip_retweets(strip_manual = TRUE, strip_mt = TRUE) # ...remove manual retweets that are labeled &#39;RT&#39;.
mufc_tweets2 &lt;- searchTwitteR(&quot;#mufc&quot;, n=2000, lang=&quot;en&quot;, since=&quot;2018-01-26&quot;, until = &quot;2018-01-26&quot;) %&gt;% 
  strip_retweets(strip_manual = TRUE, strip_mt = TRUE) # ...remove manual retweets that are labeled &#39;RT&#39;.
mufc_tweets3 &lt;- searchTwitteR(&quot;#manu&quot;, n=2000, lang=&quot;en&quot;, since=&quot;2018-01-26&quot;, until = &quot;2018-01-26&quot;) %&gt;% 
  strip_retweets(strip_manual = TRUE, strip_mt = TRUE) # ...remove manual retweets that are labeled &#39;RT&#39;.

mufc_tweets &lt;- merge.list(mufc_tweets1, mufc_tweets2, mufc_tweets3) # I merge the three Twitter lists into a single list before conversion into a dataframe using the merge.list function from the RCurl package.</code></pre>
<p>My intent is to find tweets from Manchester United fans. This is an imperfect approach that will suffice for now. While I certainly access fan tweets, the use of football club hashtags by no means guarantees that the ‘tweeter’ is a supporter of Manchester United. Frequently, commercial tweets or rival fans use club hashtags to attract the attention of ’real fans. Let’s look at a few examples from the combined list we just created:</p>
<p>This is certainly a useful example of a fan tweet for sentiment analysis purposes. It conveys fan satisfaction with the final result.</p>
<pre><code>## [1] &quot;kartikkapadia: 4-0. Time well spent #ManchesterUnited&quot;</code></pre>
<p>This tweet before the game starts is designed to attract the attention of Manchester United and other football fans by using the ‘#ManchesterUnited’ hashtag along with a media hashtag. It is problematic because it uses the word ‘killing’, which will be picked up in our sentiment analysis as a negative sentiment associated with Manchester United fans. With more time we could create a custom stopwords dictionary that removes common media soundbites, or we might remove tweets entirely that contain media hashtags or media-related Twitter handles embedded within them.</p>
<pre><code>## [1] &quot;FTouchsoccer: Giant killing tonight? Yes please #JaredBird\n\n#Yeovil v #ManchesterUnited #FS1&quot;</code></pre>
<p>I convert the output to a data frame, which is a more intuitive format for me to work with:</p>
<pre class="r"><code>#convert output to a data frame
mufc_tweets_df &lt;- twListToDF(mufc_tweets)
dim(mufc_tweets_df) # examine dimensions, 1,106 instances with 19 variables</code></pre>
<p>I examine the column names to get a better sense of the variables in the data. The data is fairly intuitive. We are most interested in the ‘text’ variable as this contains the subject matter for our sentiment analysis.</p>
<pre class="r"><code>glimpse(mufc_tweets_df) # lists variable names, types and key stats</code></pre>
<pre><code>## Observations: 1,106
## Variables: 19
## $ text            &lt;chr&gt; &quot;Yeovil 0-4 Manchester United - Full Post Matc...
## $ favorited       &lt;lgl&gt; FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALS...
## $ favoriteCount   &lt;dbl&gt; 0, 0, 2, 1, 3, 0, 0, 4, 0, 0, 6, 0, 0, 3, 2, 3...
## $ replyToSN       &lt;chr&gt; NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA...
## $ created         &lt;dttm&gt; 2018-01-26 23:57:53, 2018-01-26 23:57:24, 201...
## $ truncated       &lt;lgl&gt; FALSE, TRUE, FALSE, FALSE, TRUE, FALSE, FALSE,...
## $ replyToSID      &lt;chr&gt; NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA...
## $ id              &lt;chr&gt; &quot;957039924506656769&quot;, &quot;957039800577593344&quot;, &quot;9...
## $ replyToUID      &lt;chr&gt; NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA...
## $ statusSource    &lt;chr&gt; &quot;&lt;a href=\&quot;http://twitter.com/download/iphone\...
## $ screenName      &lt;chr&gt; &quot;BradleyHarrin20&quot;, &quot;FanBoyos&quot;, &quot;manutdnewsonly...
## $ retweetCount    &lt;dbl&gt; 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1...
## $ isRetweet       &lt;lgl&gt; FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALS...
## $ retweeted       &lt;lgl&gt; FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALS...
## $ longitude       &lt;chr&gt; NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA...
## $ latitude        &lt;chr&gt; NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA...
## $ location        &lt;chr&gt; &quot;Billericay, East&quot;, &quot;www.fanboyos.com&quot;, &quot;&quot;, &quot;B...
## $ language        &lt;chr&gt; &quot;en&quot;, &quot;en-gb&quot;, &quot;en&quot;, &quot;en&quot;, &quot;en&quot;, &quot;en&quot;, &quot;en-gb&quot;...
## $ profileImageURL &lt;chr&gt; &quot;http://pbs.twimg.com/profile_images/900042332...</code></pre>
<p>I clean the text field of special characters and gambling references. When I first wrote this code I did not implement it as a function; when I realized I would need to reuse the approach multiple times I wrap it to make it faster for future use.</p>
<pre class="r"><code>cleantweet &lt;- function(x) { #creates the function in R
  data(&quot;stop_words&quot;) # stop words dict as a data frame from the tidytext package.
  stopwords &lt;- as.vector(stop_words$word) # use Tidytext stopwords dictionary
  x$text &lt;- removeWords(x$text, stopwords)
  replace_reg &lt;-
  &quot;https://t.co/[A-Za-z\\d]+|http://[A-Za-z\\d]+|&amp;amp;|&amp;lt;|&amp;gt;|RT|https|#039;|\n|[^\x01-\x7F]|�|  &quot; # This is a good start but can be refined.
  x &lt;-
  x %&gt;%  # regular expressions (regex) useful for cleaning twitter data
  mutate(text = str_replace_all(text, replace_reg, &quot;&quot;)) %&gt;%
  filter(
  !str_detect(text, &quot;LIVE&quot;) | # Regex specific to sports tweets that are riddled with gambling advertisements
  !str_detect(text, &quot;Betfair&quot;) |
  !str_detect(text, &quot;Stream&quot;) |
  !str_detect(text, &quot;Betting&quot;) |
  !str_detect(text, &quot;betting&quot;) |
  !str_detect(text, &quot;stream&quot;)
  ) 
  return(x)
}

mufc_tweets_df &lt;- cleantweet(mufc_tweets_df) # run the function on the Twitter dataframe</code></pre>
<p>I convert the relevant text column to a text vector so it can be used by the tm package’s removeWords function. I used this because I want to leave the tweets whole, and not disaggregate using unnest_tokens() in ‘tidytext’.</p>
<p>I run sentiment analysis on the cleaned text field, again using a function so that I can repeat this analysis quickly in the future.</p>
<pre class="r"><code>mufc_data &lt;- mufc_tweets_df %&gt;%
  select(text, favoriteCount, retweetCount, created, location) # Select the fields I will use for the sentiment analysis and for plotting the results 
  
  sentiment_tw &lt;- function(x) {
  vec &lt;- as.vector(x$text)
  sentiment &lt;- analyzeSentiment(vec)
  sentiment$SentimentQDAP &lt;- as.numeric(sentiment$SentimentQDAP)
  x &lt;- cbind(x, sentiment$SentimentQDAP)
  x &lt;- rename(x, sentiment = `sentiment$SentimentQDAP`)
  return(x)
  }
  
  mufc_data &lt;- sentiment_tw(mufc_data) # running the sentiment function on our Twitter data</code></pre>
<p>Now I use posix strings that approximate pre- and post-game time periods to help me ‘zoom in’ on the sentiment I want to examine.</p>
<pre class="r"><code>preko &lt;- as.POSIXlt(&quot;2018-01-26 19:45:00&quot;)
postgame &lt;- as.POSIXlt(&quot;2018-01-26 22:00:00&quot;)
int &lt;- interval(preko, postgame) #Creates an interval object using the lubridate package 
mufc_game &lt;- mufc_data[mufc_data$created %within% int,] #This reduces my data to tweets within the specified interval
row.names(mufc_game) &lt;- 1:nrow(mufc_game) # renumber the rows consecutively from 1 so that the goal times are easier to find later for the sentiment plot.</code></pre>
<p>We reexamine the data after these changes:</p>
<pre class="r"><code>glimpse(mufc_game) # lists variable names, types and key stats</code></pre>
<pre><code>## Observations: 414
## Variables: 6
## $ text          &lt;chr&gt; &quot;Angel Gomes,! #ManchesterUnited&quot;, &quot;Glory ! Glor...
## $ favoriteCount &lt;dbl&gt; 1, 0, 0, 0, 46, 0, 2, 1, 1, 3, 0, 0, 0, 0, 2, 0,...
## $ retweetCount  &lt;dbl&gt; 0, 0, 0, 0, 35, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0,...
## $ created       &lt;dttm&gt; 2018-01-26 21:59:56, 2018-01-26 21:59:39, 2018-...
## $ location      &lt;chr&gt; &quot;Megamind Concept Gh|@ManUtd &quot;, &quot;Kota Kinabalu, ...
## $ sentiment     &lt;dbl&gt; 0.33333333, 0.66666667, 0.00000000, 0.09090909, ...</code></pre>
<p>Now I plot the sentiment results on a timeline with ggplot. I’m using the grid package’s <strong>textGrob</strong> and <strong>annotation_custom</strong> functions to add major events to the plot, e.g. when the game starts and ends, and when each goal is scored. These events are inserted using approximate times based on tweets about the events. The plot itself is a heatmap of 2-dimensional bin counts using geom_bin2d. The color scheme is from Manchester United’s official team colors. I take the same approach with Yeovil Town. I have only displayed a selection of the grob text to prevent it overwhelming the code chunk.</p>
<pre class="r"><code>grob1 &lt;- grobTree(textGrob(&quot;Happy\nTweets&quot;, x=0.46,  y=0.90, hjust=0,
  gp=gpar(col=&quot;gray50&quot;, fontsize = 16, fontfamily = &quot;Arial&quot;, fontface = &quot;bold&quot;)))

grob2 &lt;- grobTree(textGrob(&quot;Angry\nTweets&quot;, x=0.46,  y=0.1, hjust=0,
  gp=gpar(col=&quot;gray50&quot;, fontsize = 16, fontfamily = &quot;Arial&quot;, fontface = &quot;bold&quot;)))

ggplot(data = mufc_game, aes(x = as.POSIXct(created), y = sentiment)) +
  geom_bin2d() +
  labs(x = &quot;\nTime&quot;, y = &quot;Sentiment&quot;, title = &quot;Figure 1. Manchester United Twitter fan sentiment&quot;, subtitle = &quot;Yeovil Town F.C. versus Manchester United F.C.\nFA Cup Round 4, Jan 26 2018\n&quot;, fill = &quot;Tweet\ncount&quot;, caption = &quot;Analysis: Tim Raiswell. Source: Twitter.&quot;) +
  scale_fill_gradient(low = &quot;#DA020E&quot;, high = &quot;black&quot;, space = &quot;Lab&quot;,
  na.value = &quot;grey50&quot;, guide = &quot;colourbar&quot;) +
  atheme +
  annotation_custom(grob1) +
  annotation_custom(grob2) +
  annotation_custom(grob3) +
  annotation_custom(grob4) +
  annotation_custom(grob5) +
  annotation_custom(grob6) +
  annotation_custom(grobk) +
  annotation_custom(grobf) +
  geom_hline(yintercept = 0, color = &quot;black&quot;, size = 2) +
  geom_vline(xintercept = mufc_game$created[173], color = &quot;#DA020E&quot;) +
  geom_vline(xintercept = mufc_game$created[130], color = &quot;#DA020E&quot;) +
  geom_vline(xintercept = mufc_game$created[66], color = &quot;#DA020E&quot;) +
  geom_vline(xintercept = mufc_game$created[45], color = &quot;#DA020E&quot;) +
  geom_vline(xintercept = mufc_game$created[340], color = &quot;#DA020E&quot;, size = 1.8, alpha = 0.5) +
  geom_vline(xintercept = mufc_game$created[44], color = &quot;#DA020E&quot;, size = 1.8, alpha = 0.5)</code></pre>
<p><img src="/post/2018-05-19-football-match-sentiment-analysis-on-twitter-data-as-time-series_files/figure-html/unnamed-chunk-14-1.png" width="1344" /></p>
</div>
</div>
<div id="analysis" class="section level2">
<h2>Analysis</h2>
<p><strong>Figures 1 and 2</strong> show Manchester United and Yeovil fan sentiment before, during and after the match. Both sets of fans seem equally neutral heading into the event. After the game starts, Yeovil fan sentiment in <strong>Figure 2</strong> shows greater variation. Relatively high positive and negative scores for tweets precede the first (Manchester United) goal, scored just before half-time in the 41st minute by Marcus Rashford. After the goal, as we might expect, Yeovil fan tweets seem to be more consistently angry (negative sentiment). Interestingly, Manchester United fan tweets in <strong>Figure 1</strong> - where we might expect elation - are somewhat neutral. There are several potential reasons for this:</p>
<ol style="list-style-type: decimal">
<li>Manchester United is playing a lower league club in Yeovil. The team’s fans expect the team to win the game handily. A goal as delayed as this prompts relief but not necessarily elation.</li>
<li>Related to item #1, Manchester United fans are less likely to take to Twitter to celebrate a goal against a team from a lower league.</li>
<li>Our techniques for capturing a robust sample of fan sentiment on Twitter are limited.</li>
</ol>
<p><img src="/post/2018-05-19-football-match-sentiment-analysis-on-twitter-data-as-time-series_files/figure-html/unnamed-chunk-17-1.png" width="1344" /></p>
<p>As the game progresses and as it becomes clearer that Manchester United are going to win, Yeovil fan sentiment lightens. In <strong>Figure 2</strong>, there is an observable drop in negative sentiment as the full time whistle approaches. The same cannot be said of Manchester United fans in <strong>Figure 1</strong>. United fans seem to become frustrated as their team creates chances even though four of these chances resulted in goals. I am <em>narrativizing</em> here; a sloppy method. I watched the game and felt these sentiments myself. Let’s check on the content of the tweets to see if this storyline is somewhat justified.</p>
<p>This tweet expresses frustration with a refereeing decision towards the end of the game.</p>
<pre><code>## [1] &quot;Awwwww. Offside. Why @juanmata8 smile? #MUSCbean #ManchesterUnited#mufc#RedArmy#keepgrinding&quot;</code></pre>
<p>Excuse the language. This tweet expresses frustration with Manchester United player Jesse Lingard.</p>
<pre><code>## [1] &quot;Oi fucking hell @JesseLingard #ManchesterUnited&quot;</code></pre>
<p>And while this Twitter user is frustrated with a television pundit, the sentiment is indicative of general Manchester United fan sentiment at this point in the game.</p>
<pre><code>## [1] &quot;Martin keown giving sounessrun bitter pundit #ManchesterUnited #YEOMUN #football&quot;</code></pre>
<p>So, despite the fact that Manchester United is winning, <em>some</em> of the team’s fans are unhappy. Why? To answer that question in full would require several blogs, and months - maybe years - of sentiment analysis. Like Yankees fans in baseball, Manchester United fans have very high expectations. Since the retirement of the club’s talismanic, and record-breaking manager Sir Alex Ferguson in 2014, the club and its fans have endured relative failure compared to the heady successes of the 1990s and early 2000s. The tribal nature of European football fans, and the boiling pot that is football fandom on Twitter combine into a weekly groan-zone as fans desperately try to assure themselves that the glory days will return, and attack anything and anyone that suggests they won’t.</p>
<p>Let’s take a look at the aggregate sentiment for the game in two ways. First we’ll plot a histogram of fan sentiment that will help us to compare the teams side by side. And then we’ll run a t-test to see if the differences in fan sentiment are statistically significant.</p>
<pre class="r"><code>ggplot() +
  geom_histogram(data = ytfc_game, aes(sentiment), fill = &quot;#377D22&quot;, alpha = 0.7, binwidth = 0.06) +
  geom_histogram(data = mufc_game, aes(sentiment), fill = &quot;#DA020E&quot;, alpha = 0.7, binwidth = 0.06) +
  scale_y_continuous(limits = c(0, 60)) +
  atheme +
  labs(x = &quot;Sentiment&quot;, y = &quot;Count&quot;, title = &quot;Figure 3. Histogram of Manchester United and Yeovil Town fan Twitter sentiment&quot;, subtitle = &quot;Yeovil Town F.C. versus Manchester United F.C.\nFA Cup Round 4, Jan 26 2018\n&quot;, caption = &quot;Analysis: Tim Raiswell. Source: Twitter.&quot;)</code></pre>
<p><img src="/post/2018-05-19-football-match-sentiment-analysis-on-twitter-data-as-time-series_files/figure-html/unnamed-chunk-21-1.png" width="1344" /></p>
<p>The mean sentiment of Manchester United fans for the game period is <strong>0.024</strong>; for Yeovil fans it is <strong>0.036</strong>. Does this answer our question above? Are United fans more critical of their team and less likely to enjoy a game, even if they win? Sentiment scores for both sets of fans fail a Shapiro-Wilk normality test, so we use a <a href="http://www.sthda.com/english/wiki/unpaired-two-samples-wilcoxon-test-in-r">non-parametric, two-sample Wilcoxon rank test</a>.</p>
<pre class="r"><code>tidy(wilcox.test(mufc_game$sentiment, ytfc_game$sentiment, alternative = &quot;two.sided&quot;))</code></pre>
<pre><code>##   statistic   p.value                                            method
## 1    133469 0.0107798 Wilcoxon rank sum test with continuity correction
##   alternative
## 1   two.sided</code></pre>
<p>The p-value of the Wilcox test is <strong>0.01078</strong>, lower than the alpha of 0.05 (95% significance level), which indicates that the differences in sentiment between fans are significant. But <strong>Figure 3</strong> tells a more nuanced story. First, I have limited the Y (count) axis to 60. The majority of tweets we captured are neutral, hence the gap in the middle of the chart. This filter is so we can see the extreme sentiment values (angry to the left, happy to the right). We see that Yeovil fans on Twitter actually convey a broader range of emotions, both positive and negative. But the most negative sentiments for from Yeovil fans; and the most positive sentiments are from United fans.</p>
</div>
<div id="conclusion" class="section level2">
<h2>Conclusion</h2>
<p>Yeovil Town fans express more positive sentiment than Manchester United fans on Twitter for the game time period despite getting beat by four goals to nil. There is more than one factor at play that gets us to this result. First, the data is incomplete as I outline above. Second, Yeovil fans likely never expected to win the game; as such, just playing against a Premier League club and getting this far in the competition likely buoyed their mood. Third, Manchester United fans are harder to please than Yeovil fans.</p>
<p>The comparison of an English Premier League fanbase with the fanbase of a club from a lower league is unfair and bad science in some respects, but the analysis does yield interesting results that I’d like to test in the future with sentiment analysis of multiple games and teams. Other interesting approaches might involve lagging sentiment against club events like games won and lost, or goals scored and conceded, to see if various fanbases react differently, and whether supporting a storied club with an expectant fanbase is really a cause for joy at all.</p>
</div>
<div id="references" class="section level2">
<h2>References</h2>
<ul>
<li>
Said JAI-ANDALOUSSI, Imane EL MOURABIT, Nabil MADRANE, Samia BENABDELLAH CHAOUNI, Abderrahim SEKKAKI, <a href="http://ieeexplore.ieee.org/abstract/document/7424124/z">‘Soccer Events Summarization by Using Sentiment Analysis’</a>, Computational Science and Computational Intelligence (CSCI), 2015, pps 398 - 403.
<li>
Silge J and Robinson D (2016). “tidytext: Text Mining and Analysis Using Tidy Data Principles in R.” JOSS, 1(3). <a href="http://dx.doi.org/10.21105/joss.00037">doi: 10.21105/joss.00037</a>. <a href="https://www.tidytextmining.com">Free online Bookdown version</a>.
</ul>
</div>
