const fs = require('fs');

dates = {}

fs.readFile('../data/minmaxdates.csv', 'utf8', function(err, lines) {
    lines.split('\n').forEach(function(line) {
        elements = line.split(',');
        dates[elements[0].substring(1,elements[0].length -1)] = {
            startDate: elements[1],
            endDate: elements[2],
        }
    })
    fs.readFile('../data/senator-info.json', 'utf8', function(err, data) {
        if (err) throw err;
        const senators = JSON.parse(data);
        newData = [];
        senators.forEach(function(data) {
            key = Object.keys(data)[0]
            console.log(key)
            newData.push({
                id: key,
                name: data[key].name,
                startDate: dates[key].startDate,
                endDate: dates[key].endDate,
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

});
