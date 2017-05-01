const fs = require('fs');

fs.readFile('../data/senator-info.json', 'utf8', function(err, data) {
    if (err) throw err;
    const senators = JSON.parse(data);
    newData = [];
    senators.forEach(function(data) {
        key = Object.keys(data)[0]
        newData.push({
            id: key,
            name: data[key].name,
            startDate: 'TODO',
            endDate: 'TODO',
            info: {
                party: data[key].party,
                location: data[key].location,
                district: Number(data[key].district),
            },
        })
    })

    jsonOutput = JSON.stringify(newData);
    fs.writeFile('../data/new-senator-info.json', jsonOutput, 'utf8', function(){
      if (err) throw err;
      console.log('File Written');
    });
});
