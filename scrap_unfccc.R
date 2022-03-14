##

#UNFCCC 
#start RSelenium
remDr <- remoteDriver(
  remoteServerAdd = "localhost",
  port = 4445L,
  browser = "chrome"
)

remDr$open()

#navigate to your page
remDr$navigate("https://unfccc.int/topics/capacity-building/workstreams/capacity-building-portal/capacity-building-e-learning#eq-1")

#scroll down 5 times, waiting for the page to load at each time
for(i in 1:5){      
  remDr$executeScript(paste("scroll(0,",i*10000,");"))
  Sys.sleep(3)    
}

#get the page html
page_source <-remDr$getPageSource()

#pageEls  <- remDr$findElements(using = "css", "#contents #details #meta")

unfccc <- read_html(page_source[[1]])


##**Step 3.** Extract information.


body_nodes <- unfccc %>% 
  html_node("body") %>% 
  html_children()

body_nodes %>% 
  html_children()

##
parsed_nodes <- html_nodes(unfccc, 
                           xpath = '//*[contains(concat( " ", @class, " " ), concat( " ", "text-align-left", " " )) and (((count(preceding-sibling::*) + 1) = 1) and parent::*)]')
titles_unfccc <- html_text(parsed_nodes)
titles_unfccc


titles_unfccc <- as.data.frame(titles_unfccc)
titles_unfccc[titles_unfccc == "Climate Responsive Budgeting(link is external)Short info: This tutorial introduces how governments can respond to the climate change challenge through better budgeting, which integrates climate change risks and opportunities into budget preparation."] <- "Climate Responsive Budgeting"


titles_unfccc <- as.data.frame(titles_unfccc)
titles_unfccc[titles_unfccc == "\nREDD+ Learning Session 69: #NDCsWeWant - NDC Policy Recommendations on Forests and Food\n\n(link is external) \n\n\nShort info: In this learning session, presenters will provide decision-makers with joint policy recommendations to maximize forest and food related NBS as they revise their NDCs to meet the ambition of the Paris Agreement. Amanda McKee from the NDC Partnership will introduce the webinar and set the scene, Fernanda de Carvalho from WWF will present the organization’s checklist for assessing the #NDCsWeWant, and Franziska Haupt and Haseeb Bakhtary from Climate Focus will discuss key findings from “Enhancing NDCs for Food Systems” and a forthcoming report “Enhancing forest targets and measures in NDCs.”Providing Institution:  WWF Forest and ClimateRegion: GlobalType of Activities: Online Course(link is external)Learn more\n"] <- " "

titles_unfccc




#remove repeat/ mistake row
titles_unfccc <- as.data.frame(titles_unfccc)
titles_unfccc2 <- titles_unfccc[-c(40),]

#remove blank row


```


```{r}
#pull in text from website as large chunk
parsed_nodes <- html_nodes(unfccc, 
                           xpath = '//*[contains(concat( " ", @class, " " ), concat( " ", "table-container", " " )) ]')
text_unfccc <- html_text(parsed_nodes)
text_unfccc
```

```{r}
#set up dataframe and standardize capitazlisation (to lowercase)

unfccc_df_mess <- text_unfccc %>% enframe("id", "text")

unfccc_df_mess$text = tolower(unfccc_df_mess$text)

#separate title text from body
unfccc_df <- str_split_fixed(unfccc_df_mess$text, "short info:", 2)

unfccc_df <-as.data.frame(unfccc_df)

unfccc_df <- data.frame(do.call('rbind', strsplit(as.character(unfccc_df$V2),'providing institution',fixed=TRUE)))

unfccc_df <- separate(data = unfccc_df_mess, col = text, into = c("left", "keywords"), sep = "short info:")

unfccc_df <- separate(data = unfccc_df, col = keywords, into = c("keywords", "author"), sep = "providing institution:")

unfccc_df <- separate(data = unfccc_df, col = author, into = c("author", "region"), sep = "region:")

unfccc_df <- separate(data = unfccc_df, col = region, into = c("region", "dump"), sep = "type of activities:")

#remove redundant cols
unfccc_df <- mutate(unfccc_df, id=NULL, left=NULL, dump=NULL)



#extract the links

body_nodes <- unfccc %>% 
  html_node("body") %>% 
  html_children()

body_nodes %>% 
  html_children()

weblink <- unfccc  %>% html_nodes("div.embedded-entity-content > a") %>% html_attr("href")

weblink

weblink

weblinks2 <- weblink %>%  enframe("id", "weblink")

#subset for coursera
coursera_subset <- weblinks2 %>%
  filter(str_detect(weblink, "coursera"))

#subset for elearning
elearning_subset <- weblinks2 %>%
  filter(str_detect(weblink, "elearning"))

#subset for unccelearn
unccelearn_subset <- weblinks2 %>%
  filter(str_detect(weblink, "unccelearn.org"))

#subset for worldbank
worldbank_subset <- weblinks2 %>%
  filter(str_detect(weblink, "olc.worldbank.org"))


titles_unfccc
weblink

#chart_df <- merge(titles_unfccc, unfccc_df, by="id")

chart_df <- data.frame(titles_unfccc, authors, tags, SDGs, weblink)

knitr::kable(chart_df  %>% head(10))

chart_df <- tibble::rowid_to_column(chart_df, "id")


#not working?
#system("sudo docker pull selenium/standalone-chrome",wait=T)
#Sys.sleep(5)
#system("sudo docker run -d -p 4445:4444 selenium/standalone-chrome",wait=T)
#Sys.sleep(5)
#remDr <- remoteDriver(port=4445L, browserName="chrome")
#Sys.sleep(15)
#remDr$open()

```