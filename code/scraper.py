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
    except KeyboardInterrupt:
        # Don't ignore CTRL-C
        raise
    except Exception as e:
        # Ignore all other exceptions
        print ('ERROR: Could not fetch or parse id: ', id, '[', e, ']')
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

def write_to_csv(file, all_data):
    senators = set()
    for bill in all_data:
        for vote in bill['votes']:
            senators.add(vote['senator'])
    headers = ['description', 'date']
    headers.extend(senators)

    with open(file, 'w') as csvfile:
         writer = csv.DictWriter(csvfile, fieldnames=headers, restval='N/A')
         writer.writeheader()
         for bill in all_data:
             row = {
             'description': bill['description'],
             'date': bill['date'].replace(',', '/')
             }
             row.update({b['senator']: b['voted'] for b in bill['votes']})
             writer.writerow(row)

def write_to_json(file, all_data):
    with open(file, 'w') as outfile:
        json.dump(all_data, outfile)


desc_to_ignore=['ROLL CALL', 'CONSENT CALENDARAdoption']
all_data = scrape_all( DATES['2014'], DATES['TODAY']+1, desc_to_ignore)
write_to_json('../data/data.json', all_data)
write_to_csv('../data/data.csv', all_data)
