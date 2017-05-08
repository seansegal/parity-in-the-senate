root = exports ? this

majorityColor = "#1f77b4"
minorityColor = "#d62728"

# majorityColor = "#3182bd"
# minorityColor = "#fa9fb5"

Network = () ->
  # width and height of visualization (should be based off css spacing on page)
  container = document.getElementById("page-content-wrapper")
  width = container.offsetWidth + 200
  height = screen.height

  nodePadding = 2.0
  maxRadius = 0

  maxScale = 2.0
  minScale = 0.4

  # allData will store the unfiltered data
  fullJson = null
  allData = []
  curLinksData = []
  curNodesData = []
  linkedByIndex = {}

  # these will hold the svg groups for accessing the nodes and links display
  nodesG = null
  linksG = null

  # these will point to the circles and lines of the nodes and links
  node = null
  link = null

  # variables to refect the current settings of the visualization
  filter = "all"
  currTerm = "2017"
  currState = "Rhode Island"

  # our force directed layout
  force = d3.layout.force().gravity(.05)
  vis = null  
  child = null
  zoom = null

  # color function used to color nodes
  nodeColors = d3.scale.linear().domain([0.0, 1.0]).range([majorityColor, minorityColor])

  # tooltip used to display details
  tooltip = Tooltip("vis-tooltip", 230)

  # Starting point for network visualization -- initializes visualization and starts force layout
  network = (selection, data) ->
    # format our data
    fullJson = data
    updateTerms(fullJson)
    allData = setupData(data)

    zoom = d3.behavior.zoom().translate([width/15, height/8]).scale(0.6).scaleExtent([minScale, maxScale]).on("zoom", redraw)

    # create our svg and groups
    vis = d3.select(selection).append("svg")
      .attr("width", width)
      .attr("height", height)
      .attr("align", "center")
      .call(zoom)
    child = vis.append("g")
    linksG = child.append("g").attr("id", "links")
    nodesG = child.append("g").attr("id", "nodes")

    child.attr("transform", "translate(" + width/4 + "," + height/8 + ")scale(0.6)")

    # setup the size of the force environment
    force.size([width, height])

    # setup link weight functionality
    force.on("tick", forceTick)
      .charge(-200)
      .linkDistance((link) -> 
        link.weight)

    setFilter("all")

    # perform rendering and start force layout
    update()

  network.resetSize = ->
    width = container.offsetWidth
    height = screen.height
    force.size([width, height])
    vis.attr("width", width).attr("height", height)

  redraw = ->
    # console.log 'here', d3.event.translate, d3.event.scale
    child.attr 'transform', 'translate(' + d3.event.translate + ')' + ' scale(' + d3.event.scale + ')'
    return

  # The update() function performs the bulk of the
  # work to setup our visualization based on the
  # current layout/sort/filter.
  #
  # update() is called everytime a parameter changes
  # and the network needs to be reset.
  update = () ->
    # filter data to show based on current filter settings.
    curNodesData = filterNodes(allData.nodes)
    curLinksData = filterLinks(allData.links, curNodesData)

    # reset nodes in force layout
    force.nodes(curNodesData)

    # enter / exit for nodes
    updateNodes()

    # always show links in force layout
    force.links(curLinksData)
    updateLinks()

    # start me up!
    force.start()

  # Public function to switch between filter options
  network.toggleFilter = (newFilter) ->
    force.stop()
    setFilter(newFilter)
    update()

  # Public function to update highlighted nodes from search
  network.updateSearch = (searchTerm) ->
    searchRegEx = new RegExp(searchTerm.toLowerCase())
    node.each (d) ->
      element = d3.select(this)
      match = d.name.toLowerCase().search(searchRegEx)
      if searchTerm.length > 0 and match >= 0
        element.style("fill", "#F38630")
          .style("stroke-width", 2.0)
          .style("stroke", "#555")
        d.searched = true
      else
        d.searched = false
        element.style("fill", (d) -> nodeColors(d.parities[currTerm]))
          .style("stroke-width", 1.0)

  # Public function to update data
  network.updateData = (newData) ->
    fullJson = newData
    updateTerms(fullJson)
    allData = setupData(newData)
    link.remove()
    node.remove()
    update()

  network.updateDataForTerm = (newTerm) ->
    currTerm = newTerm
    allData = setupData(fullJson)
    link.remove()
    node.remove()
    update()

  network.setCurrState = (newState) ->
    currState = newState

  updateTerms = (data) ->
    # change term dropdown
    $("#terms").empty()
    first = true
    data.terms.forEach (t) ->
      if first
        first = false
        $("#terms").append $('<li class="active">' + t["year"] + '</li>')
        currTerm = t["year"]
      else
        $("#terms").append $('<li>' + t["year"] + '</li>')
    setUpTermsClick()

  updateInfo = (data) ->
    $("#currStateTerm").text(currState + " - " + currTerm)
    
    data.terms.forEach (t) ->
      if t["year"] == currTerm
        numDem = t["numDem"]
        numRep = t["numRep"]
        if numDem > numRep
          $("#numDem").css("color", majorityColor)
          $("#numRep").css("color", minorityColor)
        else if numRep > numDem
          $("#numRep").css("color", majorityColor)
          $("#numDem").css("color", minorityColor)
        else
          mixedColor = getMixedColor(majorityColor, minorityColor, 0.5)
          $("#numDem").css("color", mixedColor)
          $("#numRep").css("color", mixedColor)

        $("#numDem").text(numDem + " ")
        $("#numRep").text(numRep + " ")
        $("#numInd").text(t["numInd"] + " ")
        $("#numUnkOth").text(t["numUnkOth"])
        makeHistograms("#parityHistogram", "#weightHistogram", t["pbins"], t["wbins"])

  # called once to clean up raw data and switch links to point to node instances
  # Returns modified data
  setupData = (data) ->
    # clone the data
    data = JSON.parse(JSON.stringify(data))

    # update the side panel
    updateInfo(data)

    # filter all data to only include nodes and links of the current term
    data.nodes = data.nodes.filter (n) ->
      n.parities.hasOwnProperty(currTerm)

    minParity = Number.MAX_SAFE_INTEGER
    maxParity = -Number.MAX_SAFE_INTEGER
    data.nodes.forEach (n) ->
      # get the parity of the node in the current term
      parity = n.parities[currTerm]

      minParity = Math.min(minParity, parity)
      maxParity = Math.max(maxParity, parity)

      # set initial x/y to values within the width/height of the visualization (make dems on left)
      if parity < 0.3
        n.x = randomnumber=Math.floor(Math.random() * 1.5) + (width / 4)
      else
        n.x = randomnumber=Math.floor(Math.random() * 1.5) + ((3 * width) / 4)
      n.y = Math.floor(Math.random() * 1.5) + (height / 2)

      # Set radius
      n.radius = n.importance
      maxRadius = Math.max(maxRadius, n.radius)

    # id's -> node objects
    nodesMap = mapNodes(data.nodes)

    data.links = data.links.filter (l) ->
      nodesMap.get(l.source) and nodesMap.get(l.target) and (l.term == currTerm)

    # switch links to point to node objects instead of id's
    data.links.forEach (l) ->
      l.source = nodesMap.get(l.source)
      l.target = nodesMap.get(l.target)

      # linkedByIndex is used for link sorting
      linkedByIndex["#{l.source.id},#{l.target.id}"] = 1

    # uncomment this line to make parities relative within the current visualization, as opposed to relative across all the data
    # nodeColors.domain([minParity, maxParity])

    data

  # Helper function to map node id's to node objects.
  # Returns d3.map of ids -> nodes
  mapNodes = (nodes) ->
    nodesMap = d3.map()
    nodes.forEach (n) ->
      nodesMap.set(n.id, n)
    nodesMap

  # Given two nodes a and b, returns true if there is a link between them.
  # Uses linkedByIndex initialized in setupData
  neighboring = (a, b) ->
    linkedByIndex[a.id + "," + b.id] or
      linkedByIndex[b.id + "," + a.id]

  # Removes nodes from input array based on current filter setting.
  # Returns array of nodes
  filterNodes = (allNodes) ->
    filteredNodes = allNodes

    # for dateFilter, get all senators who have a parity for the term
    if filter == "termFilter"
      filteredNodes = allNodes.filter (n) ->
        (n.parities.hasOwnProperty(currTerm))

    filteredNodes

  # Removes links from allLinks whose source or target is not present in curNodes
  # Returns array of links
  filterLinks = (allLinks, curNodes) ->
    curNodes = mapNodes(curNodes)
    allLinks.filter (l) ->
      curNodes.get(l.source.id) and curNodes.get(l.target.id) and (l.term == currTerm)

  # enter/exit display for nodes
  updateNodes = () ->
    node = nodesG.selectAll("circle.node")
      .data(curNodesData, (d) -> d.id)

    node.enter().append("circle")
      .attr("class", "node")
      .attr("cx", (d) -> d.x)
      .attr("cy", (d) -> d.y)
      .attr("r", (d) -> d.radius)
      .style("fill", (d) -> nodeColors(d.parities[currTerm]))
      .style("stroke", (d) -> strokeFor(d))
      .style("stroke-width", 1.0)

    node.on("mouseover", showDetails)
      .on("mouseout", hideDetails)

    node.exit().remove()

  # enter/exit display for links
  updateLinks = () ->
    link = linksG.selectAll("line.link")
      .data(curLinksData, (d) -> "#{d.source.id}_#{d.target.id}")
    link.enter().append("line")
      .attr("class", "link")
      .attr("stroke", "#ddd")
      .attr("stroke-opacity", 0.8)
      .attr("x1", (d) -> d.source.x)
      .attr("y1", (d) -> d.source.y)
      .attr("x2", (d) -> d.target.x)
      .attr("y2", (d) -> d.target.y)

    link.exit().remove()

  # switches filter option to new filter
  setFilter = (newFilter) ->
    filter = newFilter

  # tick function for force directed layout
  forceTick = (e) ->
    node
      .each(dontCollide(0.5))
      .attr("cx", (d) -> d.x)
      .attr("cy", (d) -> d.y)

    link
      .attr("x1", (d) -> d.source.x)
      .attr("y1", (d) -> d.source.y)
      .attr("x2", (d) -> d.target.x)
      .attr("y2", (d) -> d.target.y)

  dontCollide = (alpha) ->
    quadtree = d3.geom.quadtree(allData.nodes)
    (d) ->
      r = d.radius + maxRadius + nodePadding
      nx1 = d.x - r
      nx2 = d.x + r
      ny1 = d.y - r
      ny2 = d.y + r
      quadtree.visit (quad, x1, y1, x2, y2) ->
        if quad.point and quad.point != d
          x = d.x - (quad.point.x)
          y = d.y - (quad.point.y)
          l = Math.sqrt(x * x + y * y)
          r = d.radius + quad.point.radius + nodePadding
          if l < r
            l = (l - r) / l * alpha
            d.x -= x *= l
            d.y -= y *= l
            quad.point.x += x
            quad.point.y += y
        x1 > nx2 or x2 < nx1 or y1 > ny2 or y2 < ny1
      return

  # Helper function that returns stroke color for particular node.
  strokeFor = (d) ->
    d3.rgb(nodeColors(d.parities[currTerm])).darker().toString()

  # Mouseover tooltip function
  showDetails = (d,i) ->
    content = '<p class="main">' + d.name + ' (' + d.party + ')</span></p>'
    content += '<hr class="tooltip-hr">'
    content += '<p class="main">' + d.info + '</span></p>'
    tooltip.showTooltip(content,d3.event)

    # higlight connected links
    if link
      link.attr("stroke", (l) ->
        if l.source == d or l.target == d then "#555" else "#ddd"
      )
        .attr("stroke-opacity", (l) ->
          if l.source == d or l.target == d then 1.0 else 0.5
        )

    # highlight neighboring nodes
    # watch out - don't mess with node if search is currently matching
    node.style("stroke", (n) ->
      if (n.searched or neighboring(d, n)) then "#555" else strokeFor(n))
      .style("stroke-width", (n) ->
        if (n.searched or neighboring(d, n)) then 2.0 else 1.0)
  
    # highlight the node being moused over
    d3.select(this).style("stroke","black")
      .style("stroke-width", 2.0)

  # Mouseout function
  hideDetails = (d,i) ->
    tooltip.hideTooltip()

    # watch out - don't mess with node if search is currently matching
    node.style("stroke", (n) -> if !n.searched then strokeFor(n) else "#555")
      .style("stroke-width", (n) -> if !n.searched then 1.0 else 2.0)
    if link
      link.attr("stroke", "#ddd")
        .attr("stroke-opacity", 0.8)

  # Final act of Network() function is to return the inner 'network()' function.
  return network

setUpTermsClick = ->
  $("#terms li").on "click", (e) ->
    if not ($(this).text() == $("#terms .active").text())

      # change the active list item
      $("#terms li").removeClass("active")
      $(this).addClass("active")

      myNetwork.updateDataForTerm($(this).text())

createColorBar = (selection) ->
  myScale = d3.scale.linear().range([majorityColor, minorityColor]).domain([0, 100])
  colorbar = Colorbar().origin([0, 0]).scale(myScale).orient('horizontal').thickness(20).barlength(481).margin({top: 0, right: 0, bottom: 0, left: 0})
  colorbarObject = d3.select(selection).call(colorbar)

myNetwork = null
$ ->
  myNetwork = Network()

  # change state file
  $("#states li").on "click", (e) ->
    # if this list item is the active one
    if not ($(this).text() == $("#states .active").text())
      stateFile = $(this).attr("id")

      # change the active list item
      $("#states li").removeClass("active")
      $(this).addClass("active")

      # set current state and update info
      myNetwork.setCurrState($(this).text())

      d3.json "data/#{stateFile}.json", (json) ->
        myNetwork.updateData(json)
  
  # search for a senator
  $("#search").keyup () ->
    searchTerm = $(this).val()
    myNetwork.updateSearch(searchTerm)

  $(window).resize ->
    myNetwork.resetSize()

  # start our visualization
  d3.json "data/data-ri.json", (json) ->
    myNetwork("#vis", json)

  createColorBar("#colorBar")

  # show more info
  $("#more_info").collapse("show")
