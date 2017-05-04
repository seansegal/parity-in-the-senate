import json
import csv
import sys
import uuid

outputFile = "../data/data.json"
linksFile = "../../data/senator_pairs.csv"
senatorsFile = "../../data/new-senator-info.json"

maxWeight = 400
minWeight = 50

importance = 12

senatorIDs = {}

terms = set()

class Senator:
	def __init__(self, name, ID, info, party, startDate, endDate, importance, parities):
		self.name = name
		self.ID = ID
		self.info = info
		self.party = party
		self.startDate = startDate
		self.endDate = endDate
		self.importance = importance
		self.parities = parities

	def toJson(self):
		return {"name": self.name, "id": self.ID, "info": self.info, "party": self.parities, "startDate": self.startDate, "endDate": self.endDate, "importance": self.importance, "parity": self.parity}

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
	return "District " + str(infoItems["district"]) + ": " + infoItems["location"]

def getSenators():
	senators = []
	with open(senatorsFile, "r") as f:
		senatorsData = json.load(f)

		for senatorData in senatorsData:
			senatorID = senatorData["id"]
			if senatorID in senatorIDs:
				print("ERROR: Duplicate ID found. Data must be reconciled.")
				sys.exit()
			senatorUUID = str(uuid.uuid4())
			senatorIDs[senatorID] = senatorUUID

			info = getInfoStr(senatorData["info"])

			party = "D"
			if senatorData["info"]["party"] == "Rep":
				party = "R"
			elif senatorData["info"]["party"] == "Ind":
				party = "I"

			for term in senatorData["parities"]
				terms.add(term)

			senators.append(Senator(senatorData["name"], senatorUUID, info, party, senatorData["startDate"], senatorData["endDate"], importance, senatorData["parities"]))

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

						minWeightUnscaled = minWeightsUnscaled[term]
						if minWeightUnscaled == None:
							minWeightsUnscaled[term] = weight
						else:
							minWeightsUnscaled[term] = min(minWeightUnscaled, weight)

						maxWeightUnscaled = maxWeightsUnscaled[term]
						if maxWeightUnscaled == None:
							maxWeightsUnscaled[term] = weight
						else:
							maxWeightsUnscaled[term] = max(maxWeightUnscaled, weight)

						links.append(Link(id1, id2, weight, term))

		for term in minWeightsUnscaled:
			terms.add(term)
			
			for link in links:
				link.scaleWeight(minWeightsUnscaled[term], maxWeightsUnscaled[term], term)

	return links

def getParity(senator, links):
	return senator.parity

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