blogdown::new_site("raiswell", theme = "eueung/hugo-casper-two")
library(blogdown)
?new_site
?hugo_build # local = TRUE call to make sure it drags in all new drafts 
?serve_site # does not rebuild the site but starts a web server
?stop_server
olOwOlo/hugo-theme-even

#Git code for terminal

# git commit -m "first commit"
# git remote add origin https://github.com/timraiswell/blogdown.git
# git push -u origin master

setwd("/Users/timraiswell/Blog")

# blogdown::new_site("raiswell", theme = "olOwOlo/hugo-theme-even")
blogdown::stop_server()
blogdown::serve_site()

###Log in
setwd("/Users/timraiswell/Blog/raiswell")
blogdown::hugo_build(local=FALSE)
blogdown::serve_site()


