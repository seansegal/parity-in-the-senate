root = exports ? this

Network = () ->
  # width and height of visualization
  width = 960
  height = 500

  # allData will store the unfiltered data
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
  start = new Date("01/01/1500")
  end = new Date()

  # our force directed layout
  force = d3.layout.force().gravity(.05).distance(100)

  # drag currently doesn't work...
  drag = force.drag

  # color function used to color nodes
  nodeColors = d3.scale.linear().domain([0.0, 1.0]).range(["#1f77b4", "#d62728"])

  # tooltip used to display details
  tooltip = Tooltip("vis-tooltip", 230)

  # Starting point for network visualization -- initializes visualization and starts force layout
  network = (selection, data) ->
    # format our data
    allData = setupData(data)

    # create our svg and groups
    vis = d3.select(selection).append("svg")
      .attr("width", width)
      .attr("height", height)
    linksG = vis.append("g").attr("id", "links")
    nodesG = vis.append("g").attr("id", "nodes")

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

  # Public function to switch start/end dates
  network.setDates = (startNew, endNew) ->
    start = startNew
    end = endNew

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
        element.style("fill", (d) -> nodeColors(d.parity))
          .style("stroke-width", 1.0)

  # Public function to update data
  network.updateData = (newData) ->
    allData = setupData(newData)
    link.remove()
    node.remove()
    update()

  # called once to clean up raw data and switch links to point to node instances
  # Returns modified data
  setupData = (data) ->
    data.nodes.forEach (n) ->
      # set initial x/y to values within the width/height
      # of the visualization
      n.x = randomnumber=Math.floor(Math.random()*width)
      n.y = randomnumber=Math.floor(Math.random()*height)

      # Set radius
      n.radius = n.importance

    # id's -> node objects
    nodesMap = mapNodes(data.nodes)

    # switch links to point to node objects instead of id's
    data.links.forEach (l) ->
      l.source = nodesMap.get(l.source)
      l.target = nodesMap.get(l.target)

      # linkedByIndex is used for link sorting
      linkedByIndex["#{l.source.id},#{l.target.id}"] = 1

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

    # for dateFilter, get all senators who servered for at least one day in the current date range
    if filter == "dateFilter"
      filteredNodes = allNodes.filter (n) ->
        (new Date(n.startDate)) <= end and ((n.endDate == "current") or (new Date(n.endDate)) >= start)

    filteredNodes

  # Removes links from allLinks whose source or target is not present in curNodes
  # Returns array of links
  filterLinks = (allLinks, curNodes) ->
    curNodes = mapNodes(curNodes)
    allLinks.filter (l) ->
      curNodes.get(l.source.id) and curNodes.get(l.target.id)

  # enter/exit display for nodes
  updateNodes = () ->
    node = nodesG.selectAll("circle.node")
      .data(curNodesData, (d) -> d.id).call(drag)

    node.enter().append("circle")
      .attr("class", "node")
      .attr("cx", (d) -> d.x)
      .attr("cy", (d) -> d.y)
      .attr("r", (d) -> d.radius)
      .style("fill", (d) -> nodeColors(d.parity))
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
      .attr("cx", (d) -> d.x)
      .attr("cy", (d) -> d.y)

    link
      .attr("x1", (d) -> d.source.x)
      .attr("y1", (d) -> d.source.y)
      .attr("x2", (d) -> d.target.x)
      .attr("y2", (d) -> d.target.y)

  # Helper function that returns stroke color for particular node.
  strokeFor = (d) ->
    d3.rgb(nodeColors(d.parity)).darker().toString()

  # Mouseover tooltip function
  showDetails = (d,i) ->
    content = '<p class="main">' + d.name + '</span></p>'
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

# Returns whether or not the given start and end dates comprise a valid date range
isValidDateRange = (start, end) ->
  Object::toString.call(start) == '[object Date]' and (not isNaN(start.getTime())) and Object::toString.call(end) == '[object Date]' and (not isNaN(end.getTime())) and end >= start

$ ->
  myNetwork = Network()

  # change state file
  $("#state_select").on "change", (e) ->
    stateFile = $(this).val()
    d3.json "data/#{stateFile}", (json) ->
      myNetwork.updateData(json)
  
  # search for a senator
  $("#search").keyup () ->
    searchTerm = $(this).val()
    myNetwork.updateSearch(searchTerm)

  # change start date
  $("#startDate").on "change", (e) ->
    start = new Date($(this).val())
    end = new Date($("#endDate").val())

    if isValidDateRange(start, end)
      myNetwork.setDates(start, end)
      myNetwork.toggleFilter("dateFilter")

  # change end date
  $("#endDate").on "change", (e) ->
    end = new Date($(this).val())
    start = new Date($("#startDate").val())

    if isValidDateRange(start, end)
      myNetwork.setDates(start, end)
      myNetwork.toggleFilter("dateFilter")

  # start our visualization
  d3.json "data/fakeData.json", (json) ->
    myNetwork("#vis", json)
