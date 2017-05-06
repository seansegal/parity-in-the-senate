import json
import csv
import sys
import uuid

outputFile = "../data/data-ri.json"
linksFile = "../../data/weights-ri.csv"
senatorsFile = "../../data/senator-info-ri.json"

maxWeight = 800
minWeight = 100

importance = 15

senatorIDs = {}

terms = set()

class Senator:
	def __init__(self, name, ID, info, party, importance, parities):
		self.name = name
		self.ID = ID
		self.info = info
		self.party = party
		self.importance = importance
		self.parities = parities

	def toJson(self):
		return {"name": self.name, "id": self.ID, "info": self.info, "party": self.party, "importance": self.importance, "parities": self.parities}

class Link:
	def __init__(self, source, target, weight, term):
		self.source = source
		self.target = target
		self.weight = weight
		self.term = term

	def scaleWeight(self, minWeightUnscaled, maxWeightUnscaled, term):
		if self.term == term:
			oldRange = maxWeightUnscaled - minWeightUnscaled
			newRange = maxWeight - minWeight
			self.weight = (((1 - self.weight) * newRange) / oldRange) + minWeight

	def toJson(self):
		return {"source": self.source, "target": self.target, "weight": self.weight, "term": self.term}

def getInfoStr(infoItems):
	districtStr = "Unknown district"
	locationStr = "Unknown location"
	if "district" in infoItems:
		districtStr = infoItems["district"]
	if "location" in infoItems:
		locationStr = infoItems["location"]
	return "District " + str(districtStr) + ": " + locationStr

def getSenators():
	senators = []
	with open(senatorsFile, "r") as f:
		senatorsData = json.load(f)

		for senatorData in senatorsData:
			senatorID = senatorData["id"]
			if senatorID in senatorIDs:
				print("ERROR: Duplicate ID found: " + senatorID + ". Data must be reconciled.")
				sys.exit()
			senatorUUID = str(uuid.uuid4())
			senatorIDs[senatorID] = senatorUUID

			info = getInfoStr(senatorData["info"])

			party = "Unknown Party"
			if "party" in senatorData["info"]:
				party = "D"
				if senatorData["info"]["party"] == "Rep":
					party = "R"
				elif senatorData["info"]["party"] == "Ind":
					party = "I"

			for term in senatorData["parities"]:
				terms.add(term)

			senators.append(Senator(senatorData["name"], senatorUUID, info, party, importance, senatorData["parities"]))

	return senators

def getLinks():
	links = []
	with open(linksFile, "r") as f:
		reader = csv.DictReader(f)

		minWeightsUnscaled = {}
		maxWeightsUnscaled = {}
		for row in reader:
			id1 = senatorIDs[row["Senator1"]]
			id2 = senatorIDs[row["Senator2"]]

			if id1 == None or id2 == None:
				print("ERROR: Mismatch between senator info IDs and sentor link IDs. Data must be reconciled.")
				sys.exit()

			for key in row:
				if key != "Senator1" and key != "Senator2":
					term = key[6:]
					weight = row[key]

					if weight != "NA":
						weight = float(weight)

						if term not in minWeightsUnscaled:
							minWeightsUnscaled[term] = weight
						else:
							minWeightsUnscaled[term] = min(minWeightsUnscaled[term], weight)

						if term not in maxWeightsUnscaled:
							maxWeightsUnscaled[term] = weight
						else:
							maxWeightsUnscaled[term] = max(maxWeightsUnscaled[term], weight)

						links.append(Link(id1, id2, weight, term))

		for term in minWeightsUnscaled:
			terms.add(term)

			for link in links:
				link.scaleWeight(minWeightsUnscaled[term], maxWeightsUnscaled[term], term)

	return links

def writeToJson(senators, links):
	data = {}
	allNodes = []
	allLinks = []

	for senator in senators:
		allNodes.append(senator.toJson())

	for link in links:
		allLinks.append(link.toJson())

	termsList = list(terms)
	termsList.sort(reverse=True)

	data["terms"] = termsList
	data["nodes"] = allNodes
	data["links"] = allLinks

	with open(outputFile, "w+") as f:
		f.write(json.dumps(data, indent=4))

def main():
	senators = getSenators()
	links = getLinks()

	writeToJson(senators, links)

main()