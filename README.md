# Parity in the Senate
A data visualization of State Senate voting data created for a ECON1660 (Big Data)
final project at Brown University.  
Created By: Sean Segal, Nate Meyers, Ben Wesner

Checkout the final product at https://seansegal.github.io/parity-in-the-senate/

![both_houses](https://github.com/seansegal/parity-in-the-senate/blob/master/docs/images/both_houses.png "Both Senate and House")

# Project Report
## Introduction
TODO: explain basic visualization, process etc.

## Initial goals:
- Create a publicly available data set that contains the information from http://webserver.rilin.state.ri.us/votes/ in a more easy to use form (currently only one bill is viewable at a time).
- Create an accompanying website using [D3](https://d3js.org/) to present the data in an informative manner. Ideally the website will give and understanding of voting networks in the [Rhode Island Senate](https://en.wikipedia.org/wiki/Rhode_Island_Senate) as well as the partisanship present in the senate.
- Try and generalize this process to other states.

## Process and Reflections:
1. Web Scraping

	We began scraping data from [the RI Legislature website](http://webserver.rilin.state.ri.us/votes/). Initially, we found that we could only get data from 2014 onwards, but after playing around with an index on the website url, we found that we could view Senate votes from as early as 2003. Scraping proved to be a pretty difficult process; in addition to having to figure out how the indexing worked, we also had to figure out which votes were relevant (we needed to identify and exclude roll calls, etc.) and account for changes in the format the information was presented in.

	Part way through the project, and after a lot of the scraping had been completed, we found a website called https://openstates.org/. Openstates collects data from every state senate and compiles it into a publicly available API. Initially, we felt silly for overlooking this massive website, but after trying to use the API we found some severe limitations and confusing errors. Of these, the two biggest problems were shorter data ranges (the earliest available data in most states was 2011) and data integrity (for some reason, when we pulled data for the Montana senate only contained votes in odd years, and when we pulled data for the Connecticut senate, we found only 28 senators when there should have been 36). While we like the idea behind Openstates, we hope their issues can be resolved in the near future, and we didn't feel comfortable making their API the centerpiece of the project.

	In terms of mechanics, we used [Beautiful Soup](https://www.crummy.com/software/BeautifulSoup/) in Python to scrape from the RI Senate website, and we used the official Openstate python package ([pyopenstates]()http://docs.openstates.org/projects/pyopenstates/en/latest/) to make requests from the API (all other states).

2. Data Cleaning and Calculations

	After scraping the data from the RI Senate website, we used R to reformat the data to be input into our website, the scripts can be found in the repository. In addition to reshaping the data, we also calculated a "weight" between each senator. The weight represents how many times a pair of senators agreed on a bill over the total number of times they voted together. This would result in senators with similar voting habits would have high weights (think two Democratic senators, for example) and senators with different voting habits would have low weights (think a Democratic Senator and a Republican Senator).

	We soon realized that while this metric conveys some information, it is not particularly informative within the RI Senate. This is because the RI Senate is overwhelming dominated by Democrats (there are 38 active senators, and only 33 are Democrats), Democrats propose almost all of the bills in the data set, and Democrats almost always vote yes on the bills they propose. As a result, the weights we generated were almost always close to 1, and even for the most conservative senators, the weights were still pretty high. Below is a histogram demonstrating how the average Senate bill in our data set receives well over the 20 votes needed to pass legislation.

	In addition to the weights, we also calculated a parity statistic to see how frequently the Senator went against the will of the majority. The idea behind this statistic was to determine how willing the senator is to go against the majority opinion in the senate. This was calculated by taking the number of votes the senator went against the majority over the total number of votes that the senator participated in. Similarly to the weights statistic, this wasn't a very revealing statistic in RI; most times Democrats sided with the majority, and the people who sided with the majority less were almost always republicans. Still, it appeared that most Republican RI Senators voted for Democratic bills the vast majority of the time.

![YesVotesHist](https://github.com/seansegal/parity-in-the-senate/blob/master/docs/images/yes_votes_hist.png "Histogram of Yes Votes")

3. Data Visualization Website

	At the beginning of the project, we sat down and brainstormed a bunch of ideas we had for how to effectively visualize the Senate voting data. All three of use were interested in networks, and decided that the core visualization should be a graph with connections that would mimic some of the visualizations we had seen about the US Senate and Congress during the election. Outside of that, we wanted to be able to select specific date ranges for the visualization, have a couple panels of summary information surrounding the visualization, and also have ways to zoom in on different bills, senators, and networks.

	As all grand visions go, we faced many significant challenges implementing these ideas, and were forced to make many compromises, though we do feel like we were able to deliver on most of our initial vision. The core network is nearly exactly how we had imagined; we even played around with different ways to make the visualization feel more alive and less static (notice how the nodes bounce into place when initialized).

	Additionally, we wanted to show some summary statistics about the makeup of each senate term. We included the number of senators from each party, and then to see how polarized the senate is, we included histograms showing the distribution of parities and weights in the Senate. Below are the histograms we generate for Montana. The parity histogram shows what seems to be a bimodal distribution: there are a lot of senators who almost always vote with the majority (parity between 0-0.2, probably center-right politicians) and a group of senators that tend to oppose the majority more frequently (parity between 0.2-0.4, probably left and far-right politicians). The weight histogram for 2011 shows a more clear example of the bimodal distribution we expect from a senate with a near 50/50 right/left split.
	
![parity_hist](https://github.com/seansegal/parity-in-the-senate/blob/master/docs/images/mt_parity_hist2017.png "Parity Hist")	

![weight_hist](https://github.com/seansegal/parity-in-the-senate/blob/master/docs/images/mt_weight_hist2011.png "Weight Hist")

	When we started to think about how we could work with a date range, we initially wanted to make something where you could put in any range the user wanted to, and the visualization and summary panels would update accordingly. After playing around with a few options, we came to the conclusion that the easiest way to make that dynamic of a visualization would take a lot of time and involve some sort of backend that would update the weights and partisanship scores according to the input date range. As a result, we decided to limit the possible selections to the available years, and pre-compute the statistics for each year ahead of time so the results would be viewable instantly. We acknowledge that this is kind of cheating but we didn't have unlimited time to make all of our features perfect!!!!

	We were able to get some information for each senator that pops up when you mouse over one of the nodes on the graph. Unfortunately, much of the data was unavailable or incomplete, so we had to do some data entry and support less fields


## Analysis
There are many applications of our final data visualization.
<!-- TODO -->

### Case Study: Montata vs Rhode Island
<!-- TODO  -->

### Figures
<!-- TODO -->

## Future Directions (Wishes)
- We would like to learn more about backend development and how some of the more dynamic visualizations we see on websites like 538 and NYTimes update so fast. This seems like a major obstacle for making dynamic visualizations, and would definitely improve our visualization if we knew how to do it.

- Figuring out the issues with the openstates API would allow us to add more data to our visualization which would allow users to compare Senate networks across states.

- Finding a better method to get text data from bills.

## Setup

### The Website

To run the website locally, go to the `docs` directory (`cd docs`) and run:

`python -m http.server 3000`

This will setup a local server for the website. You should now be able to visit http://localhost:3000 in your web browser and see our visualization running locally.

### Web Scraper/APIs
To generate a complete dataset for a state using the open states API as a datasource, run `./generate-complete-dataset` from your terminal.
You will need to install a few R packages and the pyopenstates package for python.

## Contributing
Contributions are welcome from anyone! Please read our setup guide above to get started and open pull requests with any new additional features or bug fixes.

## License
MIT © Sean Segal, Nate Meyers, Ben Wesner 2017
