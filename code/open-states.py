import pyopenstates
import csv
import pprint
import json

# Useful for debugging
pp = pprint.PrettyPrinter(indent=4)


st = 'mt'
OUTFILE_VOTES = '../data/votes-%s.csv' % st
OUTFILE_SENATOR_INFO = '../data/senator-info-raw-%s.json' % st

# Get all general information of all bills
bills = pyopenstates.search_bills(state=st, search_window='all', fields=['id', 'bill_id'])
print('TOTAL BILLS: ', len(bills))

# Fetches extra information on each bill (voting information)
legislators = set()
votes = []
count = 0
for bill in bills:
    count = count + 1
    if 'SB' not in bill['bill_id']:
        continue
    print('Requesting: ', bill['bill_id'], 'Count: ', count)
    fullBill = pyopenstates.get_bill(uid=bill['id'])
    for vote in fullBill['votes']:
        if not vote:
            continue
        voteRecord = {
            'description': fullBill['title'],
            'date': vote['date']
        }
        for yes in vote['yes_votes']:
            legislators.add(yes['leg_id'])
            voteRecord[yes['leg_id']] = 'Y'

        for no in vote['no_votes']:
            legislators.add(no['leg_id'])
            voteRecord[no['leg_id']] = 'N'

        for other in vote['other_votes']:
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


# WRITE INFORMATION TO FILE #

# Write vote information to CSV file
with open(OUTFILE_VOTES, 'w') as csvfile:
    print('Writing votes to %s' % OUTFILE_VOTES)
    headers = ['date', 'description']
    headers.extend(list(legislators))
    print(len(list(legislators)))
    writer = csv.DictWriter(csvfile, fieldnames=headers, restval='N/A')
    writer.writeheader()
    for vote in votes:
        writer.writerow(vote)

# Write senator information to JSON file
with open(OUTFILE_SENATOR_INFO, 'w') as outfile:
    print('Writing senator information to %s' % OUTFILE_SENATOR_INFO)
    json.dump(senators, outfile)
