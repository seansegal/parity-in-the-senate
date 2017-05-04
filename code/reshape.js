const fs = require('fs');

dates = {}




parities = {}
fs.readFile('../data/votesagainstall.csv', 'utf8', function(err, lines) {
  lines.split('\n').forEach(function(line) {
    elements = line.split(',');
    if(elements.length != 16){
      return;
    }
    parity = {}
    for(let year = 2003; year <= 2017; year++){
      if(elements[year - 2003 + 1] !== 'NA'){
        parity[String(year)] = elements[year - 2003 + 1];
      }
    }

    console.log(parity);

    parities[elements[0].substring(1, elements[0].length - 1)] = parity;

  })


  fs.readFile('../data/senator-info.json', 'utf8', function(err, data) {
    if (err) throw err;
    const senators = JSON.parse(data);
    newData = [];
    senators.forEach(function(data) {
      key = Object.keys(data)[0]
      newData.push({
        id: key,
        name: data[key].name,
        parities: parities[key],
        info: {
          party: data[key].party,
          location: data[key].location,
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
