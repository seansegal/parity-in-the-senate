"""
    This script fetches data fromt the Open States API. It currently searches
    for all Bills in the State's upper house (Senate).
    Usage: python open-states.py <state>
    <state> should be two-letter state code: 'fl' for Flordia

    Requires the 'pyopenstates' python module to run and Python 3.
"""

import pyopenstates
import csv
import pprint
import json
import sys

# Useful for debugging
pp = pprint.PrettyPrinter(indent=4)

default_st = 'mt'
st = sys.argv[1] if len(sys.argv) > 1 else default_st

OUTFILE_VOTES = '../data/%s/votes-%s.csv' % (st, st)
OUTFILE_SENATOR_INFO = '../data/%s/senator-info-raw-%s.json' % (st, st)

# Get all general information of all bills
bills = pyopenstates.search_bills(
    state=st, search_window='all', chamber='upper', per_page=10000, fields=['id', 'bill_id'])
print('TOTAL BILLS: ', len(bills))

# Fetches extra information on each bill (voting information)
legislators = set()
votes = []
count = 0
for bill in bills:
    count = count + 1
    print('Requesting: ', bill['bill_id'], 'Count: ', count)
    fullBill = pyopenstates.get_bill(uid=bill['id'])
    for vote in fullBill['votes']:
        if not vote:
            continue
        # Only fetch senate votes (lower house votes on senate bills sometimes)
        if 'upper' not in vote['chamber']:
            continue
        # Specical cases of bad data from the API.
        if (vote['date'].startswith('2011') and st == 'al') or (vote['date'].startswith('2014') and st == 'fl'):
            continue
        voteRecord = {
            'description': fullBill['title'],
            'date': vote['date']
        }
        for yes in vote['yes_votes']:
            if yes['leg_id']:
                legislators.add(yes['leg_id'])
                voteRecord[yes['leg_id']] = 'Y'

        for no in vote['no_votes']:
            if no['leg_id']:
                legislators.add(no['leg_id'])
                voteRecord[no['leg_id']] = 'N'

        for other in vote['other_votes']:
            if other['leg_id']:
                legislators.add(other['leg_id'])
                voteRecord[other['leg_id']] = 'NV'
        votes.append(voteRecord)

# Fetches information on each senator (name, party, district ..etc)
senators = []
for leg in legislators:
    try:
        fullLeg = pyopenstates.get_legislator(leg)
        party, district = None, None
        try:
            district = fullLeg['roles'][0]['district']
        except Exception as e:
            pass
        try:
            party = fullLeg['party'][:3]
        except Exception as e:
            jsonAsString = str(fullLeg)
            republican = 'Republican' in jsonAsString
            democrat = 'Democrat' in jsonAsString
            indepdent = 'Independent' in jsonAsString
            if republican and not democrat:
                party = 'Rep'
            if not republican and democrat:
                party = 'Dem'
            if indepdent:
                party = 'Ind'
            pass
        senator = {
            'name': "%s %s" % (fullLeg['first_name'], fullLeg['last_name']),
            'party': party,
            'district': district
        }
        senators.append({
            leg: senator
        })
    except Exception as e:
        print('ERROR: ' + str(e))


# Write vote information to CSV file
with open(OUTFILE_VOTES, 'w') as csvfile:
    print('Writing votes to %s' % OUTFILE_VOTES)
    headers = ['date', 'description']
    headers.extend(list(legislators))
    print('Senators: ', len(list(legislators)))
    writer = csv.DictWriter(csvfile, fieldnames=headers, restval='N/A')
    writer.writeheader()
    for vote in votes:
        writer.writerow(vote)

# Write senator information to JSON file
with open(OUTFILE_SENATOR_INFO, 'w') as outfile:
    print('Writing senator information to %s' % OUTFILE_SENATOR_INFO)
    json.dump(senators, outfile)
