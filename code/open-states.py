import pyopenstates
import csv

st = 'mt'
OUTFILE = '../data/montana-votes.csv'

bills = pyopenstates.search_bills(state=st, search_window='all', fields=['id', 'bill_id'])
print('BILLS: ', len(bills))

legislators = set()
votes = []
count = 0
for bill in bills:
    count = count + 1
    if count == 100:
        break
    if 'HB' in bill['bill_id']:
        continue
    print('Requesting: ', bill['bill_id'], 'Count: ', count)
    fullBill = pyopenstates.get_bill(uid=bill['id'])
    for vote in fullBill['votes']:
        voteRecord = {}
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


# Write to the file
with open(OUTFILE, 'w') as csvfile:
    print('Writing Dataset...')
    headers = list(legislators)
    print(list(legislators))
    writer = csv.DictWriter(csvfile, fieldnames=headers, restval='N/A')
    writer.writeheader()
    for vote in votes:
        writer.writerow(vote)
