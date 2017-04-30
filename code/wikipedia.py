import requests
from bs4 import BeautifulSoup
import csv
import json


# Map from last name --> all information
info = {}

url = "https://en.wikipedia.org/wiki/Rhode_Island_Senate"
response = requests.request("GET", url)
soup = BeautifulSoup(response.text, 'html.parser')
table = soup.find_all('table')[3]
for row in table.find_all('tr'):
    data = row.find_all('td')
    if len(data) != 4:
        continue
    data_map = {
        'district': data[0].get_text(),
        'name': data[1].get_text(),
        'party': data[2].get_text(),
        'location': data[3].get_text()
    }
    info[data_map['name'].split(' ')[-1]] = data_map

useful_data = []
with open('../data/data.csv') as csvfile:
    reader = csv.DictReader(csvfile)
    count = 0
    for name in reader.fieldnames:
        name = name.split(' ')[-1]
        if name in info:
            useful_data.append({name: info[name]})
            count = count + 1
        else:
            print(name)

with open('../data/senator-info.json', 'w') as outfile:
    json.dump(useful_data, outfile)
