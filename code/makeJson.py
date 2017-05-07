import json
import csv
import sys
import uuid

if len(sys.argv) != 2:
	print('Usage: ./makeJson.py <state>')

st = sys.argv[1]

outputFile = "../docs/data/data-%s.json" % st
linksFile = "../data/%s/weights-%s.csv" % (st, st)
senatorsFile = "../data/%s/senator-info-%s.json" % (st, st)
summaryFile = "../data/%s/summary-%s.csv" %(st, st)

maxWeight = 800
minWeight = 100

importance = 15

senatorIDs = {}

pBinFormat = "{0:.2f}"
wBinFormat = "{0:.2f}"

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

class Term:
	def __init__(self, year, numDem, numRep, numInd, numUnkOth, pbins, wbins):
		self.year = year
		self.numDem = numDem
		self.numRep = numRep
		self.numInd = numInd
		self.numUnkOth = numUnkOth
		self.pbins = pbins
		self.wbins = wbins

	def toJson(self):
		return {"year": self.year, "numDem": self.numDem, "numRep": self.numRep, "numInd": self.numInd, "numUnkOth": self.numUnkOth, "pbins": self.pbins, "wbins": self.wbins}

def getInfoStr(infoItems):
	districtStr = "Unknown"
	if "district" in infoItems and infoItems["district"] != 0:
		districtStr = infoItems["district"]
	return "District " + str(districtStr)

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

			party = "Party Unknown"
			if "party" in senatorData["info"]:
				party = "D"
				if senatorData["info"]["party"] == "Rep":
					party = "R"
				elif senatorData["info"]["party"] == "Ind":
					party = "I"

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
			for link in links:
				link.scaleWeight(minWeightsUnscaled[term], maxWeightsUnscaled[term], term)

	return links

def getTerms():
	terms = []
	with open(summaryFile, "r") as f:
		reader = csv.DictReader(f)

		numPBins = 0
		numWBins = 0
		for field in reader.fieldnames:
			if field.startswith("pbin"):
				numPBins += 1
			elif field.startswith("wbin"):
				numWBins += 1

		for row in reader:
			pBins = {}
			for i in range(1, numPBins + 1):
				colName = "pbin" + str(i)
				low = (i - 1) * float(1 / numPBins)
				high = i * float(1 / numPBins)
				newColName = pBinFormat.format(low) + " - " + pBinFormat.format(high)

				pBins[newColName] = int(row[colName])

			wBins = {}
			for i in range(1, numWBins + 1):
				colName = "wbin" + str(i)
				low = (i - 1) * float(1 / numWBins)
				high = i * float(1 / numWBins)
				newColName = wBinFormat.format(low) + " - " + wBinFormat.format(high)

				wBins[newColName] = int(row[colName])

			terms.append(Term(row[""], int(row["Dem"]), int(row["Rep"]), int(row["Ind"]), int(row["Unk"]), pBins, wBins))

	return sorted(terms, key=lambda t: t.year, reverse=True)

def writeToJson(senators, links, terms):
	data = {}
	allNodes = []
	allLinks = []
	allTerms = []

	for senator in senators:
		allNodes.append(senator.toJson())

	for link in links:
		allLinks.append(link.toJson())

	for term in terms:
		allTerms.append(term.toJson())

	data["terms"] = allTerms
	data["nodes"] = allNodes
	data["links"] = allLinks

	with open(outputFile, "w+") as f:
		f.write(json.dumps(data, indent=4))

def main():
	senators = getSenators()
	links = getLinks()
	terms = getTerms()

	writeToJson(senators, links, terms)

main()
