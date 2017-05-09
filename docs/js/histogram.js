function makeHistograms(selection1, selection2, pbins, wbins) {
	makeHistogramsHelper(selection1, pbins, 480, "Parity Distribution", false, (Object.keys(pbins).length == 100));
	makeHistogramsHelper(selection2, wbins, 480, "Senator Similarity Distribution", false, (Object.keys(wbins).length == 100))
}

function makeHistogramsHelper(selection, bins, thisWidth, thisTitle, makeRelative, make20From100) {
	d3.select(selection).selectAll("svg").remove()

	var color = "steelblue";

	var keys = [];
	var values = [];
	Object.keys(bins).forEach(function(key) {
		keys.push(key);
		values.push(bins[key]);
	});

	if (makeRelative) {
		len = values.length
		for (var i = 0; i < len; i++) {
			if (values[i] == 0) {
				values.splice(i, 1);
				keys.splice(i, 1);
				i--;
				len--;
			} else {
				break;
			}
		}
		for (var i = values.length - 1; i > 0; i--) {
			if (values[i] == 0) {
				values.splice(i, 1);
				keys.splice(i, 1);
			} else {
				break;
			}
		}
	}

	if (make20From100) {
		newKeys = []
		newValues = []

		for (var i = 0; i < values.length; i+=5) {
			newValue = values[i] + values[i + 1] + values[i + 2] + values[i + 3] + values[i + 4];
			key1 = keys[i].replace(" ", "").split("-")[0];
			key2 = keys[i + 4].replace(" ", "").split("-")[1];
			newKey = key1 + " - " + key2;
			newValues.push(newValue);
			newKeys.push(newKey);
		}
		values = newValues;
		keys = newKeys;
	}

	var min = Number.MAX_SAFE_INTEGER;
	var max = Number.MIN_SAFE_INTEGER;
	tickVals = []
	keys.forEach(function(key) {
		nums = key.replace(" ", "").split("-");
		low = parseFloat(nums[0]);
		high = parseFloat(nums[1]);

		min = Math.min(min, low);
		max = Math.max(max, high);
		if (!contains.call(tickVals, low)) {
			tickVals.push(low)
		}
		if (!contains.call(tickVals, high)) {
			tickVals.push(high)
		}
	});

	dataPoints = [];
	for (var i = 0; i < values.length; i++) {
		nums = keys[i].replace(" ", "").split("-");
		low = parseFloat(nums[0]);
		high = parseFloat(nums[1]);
		for (var j = 0; j < values[i]; j++) {
			dataPoints.push((Math.random() * (high - low) + low));
		}
	}

	// Generate a 1000 data points using normal distribution with mean=20, deviation=5
	var values = dataPoints;

	// A formatter for counts.
	var formatCount = d3.format(",.0f");

	var margin = {top: 40, right: 30, bottom: 30, left: 20},
	    width = thisWidth - margin.left - margin.right,
	    height = 200 - margin.top - margin.bottom;

	var x = d3.scale.linear()
	      .domain([min, max])
	      .range([0, width]);

	var data = d3.layout.histogram()
	    .bins(tickVals)
	    (values);

	var yMax = d3.max(data, function(d){return d.length});
	var yMin = d3.min(data, function(d){return d.length});
	var colorScale = d3.scale.linear()
	            .domain([yMin, yMax])
	            .range([d3.rgb(color).brighter(), d3.rgb(color).darker()]);

	var y = d3.scale.linear()
	    .domain([0, yMax])
	    .range([height, 0]);

	var xAxis = d3.svg.axis()
	    .scale(x)
	    .tickValues(tickVals)
	    .tickFormat(d3.format(".2f"))
	    .orient("bottom");

	var svg = d3.select(selection).append("svg")
	    .attr("width", width + margin.left + margin.right)
	    .attr("height", height + margin.top + margin.bottom)
	  .append("g")
	    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

	var bar = svg.selectAll(".bar")
	    .data(data)
	  .enter().append("g")
	    .attr("class", "bar")
	    .attr("transform", function(d) { return "translate(" + x(d.x) + "," + y(d.y) + ")"; });

	bar.append("rect")
	    .attr("x", 1)
	    .attr("width", (x(data[0].dx) - x(0)) - 1)
	    .attr("height", function(d) { return height - y(d.y); })
	    .attr("fill", function(d) { return colorScale(d.y) });

	bar.append("text")
	    .attr("dy", ".75em")
	    .attr("y", -12)
	    .attr("x", (x(data[0].dx) - x(0)) / 2)
	    .attr("text-anchor", "middle")
	    .text(function(d) { return formatCount(d.y); });

	svg.append("g")
	    .attr("class", "x axis")
	    .attr("transform", "translate(0," + height + ")")
	    .call(xAxis);

	svg.append("text")
        .attr("x", (width / 2))             
        .attr("y", 0 - (margin.top / 2))
        .attr("text-anchor", "middle")  
        .attr("class", "title")
        .text(thisTitle);
}

var contains = function(needle) {
    // Per spec, the way to identify NaN is that it is not equal to itself
    var findNaN = needle !== needle;
    var indexOf;

    if(!findNaN && typeof Array.prototype.indexOf === 'function') {
        indexOf = Array.prototype.indexOf;
    } else {
        indexOf = function(needle) {
            var i = -1, index = -1;

            for(i = 0; i < this.length; i++) {
                var item = this[i];

                if((findNaN && item !== item) || item === needle) {
                    index = i;
                    break;
                }
            }

            return index;
        };
    }

    return indexOf.call(this, needle) > -1;
};

function getMixedColor(color1, color2, ratio) {
	var hex = function(x) {
	    x = x.toString(16);
	    return (x.length == 1) ? '0' + x : x;
	};

	var r = Math.ceil(parseInt(color1.substring(0,2), 16) * ratio + parseInt(color2.substring(0,2), 16) * (1-ratio));
	var g = Math.ceil(parseInt(color1.substring(2,4), 16) * ratio + parseInt(color2.substring(2,4), 16) * (1-ratio));
	var b = Math.ceil(parseInt(color1.substring(4,6), 16) * ratio + parseInt(color2.substring(4,6), 16) * (1-ratio));

	return "#" + hex(r) + hex(g) + hex(b);
}