# ECON1660 Final Project
Created By: Sean Segal, Nate Myers, Ben Wesner

## Introduction

# Initial goals:
- Create a publicly available data set that contains the information from http://webserver.rilin.state.ri.us/votes/ in a more easy to use form (currently only one bill is viewable at a time).
- Create an accompanying website using D3 to present the data in an informative manner. Ideally the website will give and understanding of voting networks in the Rhode Island Senate as well as the partisanship present in the senate.
- Try and generalize this process to other states.

# Process:

1. Scraping
	We began scraping data from http://webserver.rilin.state.ri.us/votes/. Initially, we found that we could only get data from 2014 onwards, but after playing around with an index on the website url, we found that we could view Senate votes from as early as 2003. Scraping proved to be a pretty difficult process; in addition to having to figure out how the indexing worked, we also had to figure out which votes were relevant (we needed to identify and exclude roll calls, etc.) and account for changes in the format the information was presented in.
	Part way through the project, and after a lot of the scraping had been completed, we found a website called https://openstates.org/. Openstates collects data from every state senate and compiles it into a publicly available API. Initially, we felt silly for overlooking this massive website, but after trying to use the API we found some severe limitations and confusing errors. Of these, the two biggest problems were shorter data ranges (the earliest available data in most states was 2011) and data integrity (for some reason, when we pulled data for the Montana senate only contained votes in odd years, and when we pulled data for the Connecticut senate, we found only 28 senators when there should have been 36). While we like the idea behind Openstates, we hope their issues can be resolved in the near future, and we didn't feel comfortable making their API the centerpiece of the project.
	In terms of mechanics, we used Beautiful Soup in python to scrape from the RI Senate website, and we used the official Openstate python package to make requests from the API.
	
2. Data Cleaning and Calculations
	After scraping the data from the RI Senate website, we used R to reformat the data to be input into our website. In addition to 
	

## Documentation
