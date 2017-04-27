import requests
from bs4 import BeautifulSoup
import json
import time
import csv


DATES = {
    '2014': 8231,
    'TODAY': 10695 # Updated April 26, 2015
}

def scrape(id):
    url = "http://webserver.rilin.state.ri.us/SVotes/votereport.asp"

    querystring = {'id': id}
    payload = "text="
    headers = {
        'content-type': "application/x-www-form-urlencoded",
        'cache-control': "no-cache"
        }

    print('Requesting: id', id)

    try:
        response = requests.request("GET", url, data=payload, headers=headers, params=querystring)

        # Error Checking
        if response.status_code != requests.codes.ok:
            print('ERROR: Could not fetch id:', id, ' Message:', response.text)

        soup = BeautifulSoup(response.text, 'html.parser')

        description = str(soup.find_all('table')[3].find_all('tr')[2].get_text())
        description = description.strip()

        date = soup.find_all('table')[3].find_all('tr')[1].get_text().strip().split('\n')[-1]

        votes = soup.find_all('span')
        votes_arr = []
        for vote in votes[3:-3]:
            votes_arr.append({'senator': str(vote.next.next).strip(), 'voted': vote.next})
        return (description, date, votes_arr, soup)
    except:
        print ('ERROR: Could not fetch or parse id: ', id)
        return None, None, None, None


def scrape_all(begin, end, desc_to_ignore=[]):
    all_data = []
    failures = 0
    for i in range(begin, end):
        desc, date, votes, _ = scrape(i)
        if desc == None:
            failures = failures + 1
            continue
        skip = False
        for d in desc_to_ignore:
            if d == desc:
                skip = True
                break
        if skip:
            continue
        data = {
            "description": desc,
            "date": date,
            "votes": votes
        }
        all_data.append(data)
    return all_data


def scrape_all_to_csv(file, begin, end, desc_to_ignore=[]):
    all_data = scrape_all(begin, end, desc_to_ignore)
    with open(file, 'w') as outfile:
        outCSV = csv.writer()


def scrape_all_to_json(file, begin, end, desc_to_ignore=[]):
    all_data = scrape_all(begin, end, desc_to_ignore)
    with open(file, 'w') as outfile:
        json.dump(all_data, outfile)

desc, _ , _, soup = scrape(10694)
print(desc)
desc_to_ignore=['ROLL CALL', 'CONSENT CALENDARAdoption']
scrape_all_to_json('../data/data.json', DATES['2014'], DATES['TODAY']+1, desc_to_ignore)
