import json

outputFile = "data/data.json"

class Senator:
	def __init__(self, name, ID, info, startDate, endDate, importance, parity=0):
		self.name = name
		self.ID = ID
		self.info = info
		self.startDate = startDate
		self.endDate = endDate
		self.importance = importance
		self.parity = parity

	def toJson(self):
		return {"name": self.name, "id": self.ID, "info": self.info, "startDate": self.startDate, "endDate": self.endDate, "importance": self.importance, "parity": self.parity}

class Link:
	def __init__(self, source, target, weight):
		self.source = source
		self.target = target
		self.weight = weight

	def toJson(self):
		return {"source": self.source, "target": self.target, "weight": self.weight}

def getSenators():
	return [Senator("myName", "myID", "myInfo", "myStartDate", "myEndDate", 5)]

def getLinks():
	return [Link("senator1", "senator2", 500)]

def getParity(senator, links):
	return 20

def writeToJson(senators, links):
	data = {}
	allNodes = []
	allLinks = []

	for senator in senators:
		allNodes.append(senator.toJson())

	for link in links:
		allLinks.append(link.toJson())

	data["nodes"] = allNodes
	data["links"] = allLinks

	with open(outputFile, "w+") as f:
		f.write(json.dumps(data, indent=4))

def main():
	senators = getSenators()
	links = getLinks()

	for senator in senators:
		senator.parity = getParity(senator, links)

	writeToJson(senators, links)

main()