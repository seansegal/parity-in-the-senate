const fs = require('fs');
// const districts = require('../data/districts');

if(process.argv.length !== 3){
  console.log('Usage: ./reshape <state>')
}

STATE = process.argv[2]
HEADERS_START = '"VotesAgainst'
stateRegex = new RegExp('<state>', 'g')
VOTES_FILE = '../data/<state>/parity-<state>.csv'.replace(stateRegex, STATE);
SENATOR_FILE = "../data/<state>/senator-info-raw-<state>.json".replace(stateRegex, STATE);
OUTFILE = '../data/<state>/senator-info-<state>.json'.replace(stateRegex, STATE);
dates = {}
parities = {}
fs.readFile(VOTES_FILE, 'utf8', function(err, linesFull) {
  if(err){
    console.log(err)
  }
  lines = linesFull.split('\n');
  header = lines[0].split(',');
  console.log(lines.length)
  for (let i = 1; i < lines.length; i++) {
    elements = lines[i].split(',');
    if (elements.length <= 1) {
      continue;
    }
    parity = {}

    header.forEach(function(col, index) {
      if (col.startsWith(HEADERS_START)) {
        year = col.substring(HEADERS_START.length)
        year = year.substring(0, year.length - 1);
        par = Number(elements[index]);
        if(!isNaN(par)){
          parity[String(year)] = par
        }
      }
    });
    parities[elements[0].substring(1, elements[0].length - 1).toLowerCase()] = parity;
  }

  fs.readFile(SENATOR_FILE, 'utf8', function(err, data) {
    if (err) throw err;
    const senators = JSON.parse(data);

    newData = [];
    senators.forEach(function(data) {
      key = Object.keys(data)[0];

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
          location: senatorInfo.location, //|| districts[senatorInfo.district],
          district: Number(data[key].district),
        },
      })
    })

    jsonOutput = JSON.stringify(newData);
    fs.writeFile(OUTFILE, jsonOutput, 'utf8', function() {
      if (err) throw err;
      console.log('File Written');
    });
  });
})
