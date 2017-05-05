const fs = require('fs');
const districts = require('../data/districts');

HEADERS_START = '"VotesAgainst'
dates = {}
parities = {}
fs.readFile('../data/votesagainstall.csv', 'utf8', function(err, linesFull) {
  lines = linesFull.split('\n');
  header = lines[0].split(',');
  for (let i = 1; i < lines.length; i++) {
    console.log('LINE' + lines[i])
    elements = lines[i].split(',');
    if (elements.length <= 1) {
      continue;
    }
    parity = {}

    header.forEach(function(col, index) {
      if (col.startsWith(HEADERS_START)) {
        year = col.substring(HEADERS_START.length)
        year = year.substring(0, year.length -1);
        parity[String(year)] = Number(elements[index]) || undefined
      }
    });

    console.log('PARITY')
    console.log(parity);
    parities[elements[0].substring(1, elements[0].length - 1)] = parity;
  }






  fs.readFile('../data/senator-info.json', 'utf8', function(err, data) {
    if (err) throw err;
    const senators = JSON.parse(data);
    newData = [];
    senators.forEach(function(data) {
      key = Object.keys(data)[0];
      console.log(key)
      senatorInfo = data[key] || data[key.toLowerCase()]
      if (!senatorInfo) {
        console.log('No found for ' + key);
        return
      }
      newData.push({
        id: key.toLowerCase(),
        name: senatorInfo.name,
        parities: parities[key.toLowerCase()],
        info: {
          party: senatorInfo.party,
          location: senatorInfo.location || districts[senatorInfo.district],
          district: Number(data[key].district),
        },
      })
    })

    jsonOutput = JSON.stringify(newData);
    fs.writeFile('../data/new-senator-info.json', jsonOutput, 'utf8', function() {
      if (err) throw err;
      console.log('File Written');
    });
  });
})
