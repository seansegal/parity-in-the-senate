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

	def scaleWeight(self, minWeightUnscaled, maxWeightUnscaled):
		oldRange = maxWeightUnscaled - minWeightUnscaled
		newRange = maxWeight - minWeight
		self.weight = (((1 - self.weight) * newRange) / oldRange) + minWeight
		print(self.weight)

	def toJson(self):
		return {"source": self.source, "target": self.target, "weight": self.weight}

def getInfoStr(infoItems):
	return "District " + str(infoItems["district"]) + ": " + infoItems["location"]

def getNameStr(senatorData):
	return senatorData["name"]
	# return senatorData["name"] + (" (R)" if senatorData["info"]["party"] == "Rep" else " (D)")

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
			name = getNameStr(senatorData)

			senators.append(Senator(name, senatorUUID, info, senatorData["startDate"], senatorData["endDate"], importance))

	return senators

def getLinks():
	links = []
	with open(linksFile, "r") as f:
		reader = csv.DictReader(f)

		minWeightUnscaled = float("inf")
		maxWeightUnscaled = float("-inf")
		for row in reader:
			weight = row["weight"]
			if weight != "NA":
				weight = float(weight)
				minWeightUnscaled = min(minWeightUnscaled, weight)
				maxWeightUnscaled = max(maxWeightUnscaled, weight)

				id1 = senatorIDs[row["Senator1"]]
				id2 = senatorIDs[row["Senator2"]]
				if id1 == None or id2 == None:
					print("ERROR: Mismatch between senator info IDs and sentor link IDs. Data must be reconciled.")
					sys.exit()

				links.append(Link(id1, id2, weight))

		for link in links:
			link.scaleWeight(minWeightUnscaled, maxWeightUnscaled)

	return links

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