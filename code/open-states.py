# import pyopenstates
import myapi
import csv
import pprint
import json

pp = pprint.PrettyPrinter(indent=4)

fb = myapi.get_bill(uid='NEB00005643');
pp.pprint(fb)

st = 'mt'
OUTFILE = '../data/montana-votes.csv'

#
bills = myapi.search_bills(state=st, search_window='session', fields=['id', 'bill_id'])
print('BILLS: ', len(bills))

legislators = set()
votes = []
count = 0
for bill in bills:
    count = count + 1
    if 'SB' not in bill['bill_id']:
        continue
    print('Requesting: ', bill['bill_id'], 'Count: ', count)
    fullBill = myapi.get_bill(uid=bill['id'])
    for vote in fullBill['votes']:
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


# UNCOMMENT TO WRITE VOTES TO FILE
# with open(OUTFILE, 'w') as csvfile:
#     print('Writing Dataset...')
#     headers = ['date', 'description']
#     headers.extend(list(legislators))
#     print(len(list(legislators)))
#     writer = csv.DictWriter(csvfile, fieldnames=headers, restval='N/A')
#     writer.writeheader()
#     for vote in votes:
#         writer.writerow(vote)

# UNCOMMENT TO WRITE SENATOR INFO TO FILE
senators = {}
for leg in legislators:
    try:
        fullLeg = myapi.get_legislator(leg)
        party, district = None, None
        try:
            district = fullLeg['roles'][0]['district']
        except Exception as e:
            pass
        try:
            party = fullLeg['party'][:3]
        except Exception as e:
            pass
        # pp = pprint.PrettyPrinter(indent=4)
        # pp.pprint(fullLeg)
        senator = {
            'name': "%s %s" % (fullLeg['first_name'], fullLeg['last_name']),
            'party': party,
            'district': district
        }
        senators[leg] = senator
    except Exception as e:
        print('ERROR: ' + str(e))

filename = '../data/senator-info-raw-%s.json' % st
with open(filename, 'w') as outfile:
    json.dump(senators, outfile)
