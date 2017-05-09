// Makes the parity and weight histograms
function makeHistograms(selection1, selection2, pbins, wbins) {
	makeHistogramsHelper(selection1, pbins, 480, "Parity Distribution", false, (Object.keys(pbins).length == 100));
	makeHistogramsHelper(selection2, wbins, 480, "Senator Similarity Distribution", false, (Object.keys(wbins).length == 100))
}

// Makes one histogram, given the parameters
function makeHistogramsHelper(selection, bins, thisWidth, thisTitle, makeRelative, make20From100) {
	// remove the current histogram
	d3.select(selection).selectAll("svg").remove()

	// base color of the bars
	var color = "steelblue";

	// get the keys and values from the given dictionary
	var keys = [];
	var values = [];
	Object.keys(bins).forEach(function(key) {
		keys.push(key);
		values.push(bins[key]);
	});

	// if the histogram should be relative to just this senate, then delete all '0' values on both sides
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

	// if the histogram needs to go from 100 buckets to 20 buckets
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

	// get the min and max for the x axis, and the tick values
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

	// generate the 'fake' data points based on the given data
	dataPoints = [];
	for (var i = 0; i < values.length; i++) {
		nums = keys[i].replace(" ", "").split("-");
		low = parseFloat(nums[0]);
		high = parseFloat(nums[1]);
		for (var j = 0; j < values[i]; j++) {
			dataPoints.push((Math.random() * (high - low) + low));
		}
	}

	var values = dataPoints;

	// formatter for counts
	var formatCount = d3.format(",.0f");

	// margin and width/height
	var margin = {top: 40, right: 30, bottom: 30, left: 20},
	    width = thisWidth - margin.left - margin.right,
	    height = 200 - margin.top - margin.bottom;

	// x axis scale
	var x = d3.scale.linear()
	      .domain([min, max])
	      .range([0, width]);

	// make histogram with given tick values and data points
	var data = d3.layout.histogram()
	    .bins(tickVals)
	    (values);

	// determine coloring
	var yMax = d3.max(data, function(d){return d.length});
	var yMin = d3.min(data, function(d){return d.length});
	var colorScale = d3.scale.linear()
	            .domain([yMin, yMax])
	            .range([d3.rgb(color).brighter(), d3.rgb(color).darker()]);

	// get the y axis scale
	var y = d3.scale.linear()
	    .domain([0, yMax])
	    .range([height, 0]);

	// instantiate the x axis
	var xAxis = d3.svg.axis()
	    .scale(x)
	    .tickValues(tickVals)
	    .tickFormat(d3.format(".2f"))
	    .orient("bottom");

	// create the base visualization
	var svg = d3.select(selection).append("svg")
	    .attr("width", width + margin.left + margin.right)
	    .attr("height", height + margin.top + margin.bottom)
	  .append("g")
	    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

	// create the base bar graph
	var bar = svg.selectAll(".bar")
	    .data(data)
	  .enter().append("g")
	    .attr("class", "bar")
	    .attr("transform", function(d) { return "translate(" + x(d.x) + "," + y(d.y) + ")"; });

	// include the actual bars
	bar.append("rect")
	    .attr("x", 1)
	    .attr("width", (x(data[0].dx) - x(0)) - 1)
	    .attr("height", function(d) { return height - y(d.y); })
	    .attr("fill", function(d) { return colorScale(d.y) });

	// include the text above the bars
	bar.append("text")
	    .attr("dy", ".75em")
	    .attr("y", -12)
	    .attr("x", (x(data[0].dx) - x(0)) / 2)
	    .attr("text-anchor", "middle")
	    .text(function(d) { return formatCount(d.y); });

	// include the x axis
	svg.append("g")
	    .attr("class", "x axis")
	    .attr("transform", "translate(0," + height + ")")
	    .call(xAxis);

	// include the title
	svg.append("text")
        .attr("x", (width / 2))             
        .attr("y", 0 - (margin.top / 2))
        .attr("text-anchor", "middle")  
        .attr("class", "title")
        .text(thisTitle);
}

// Returns whether or not the object this function is called on contains the given needle
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

// Returns the color that is a mix of the given two colors, at the given ratio
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