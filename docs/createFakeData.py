import json
import random

def main():
	data = {}
	allNodes = []
	allLinks = []

	importance = 12
	names = ["senator1", "senator2", "senator3", "senator4", "senator5", "senator6", "senator7", "senator8", "senator9", "senator10"]
	startDates = ["01/01/12", "01/01/10", "01/01/13"]
	endDates = ["current", "01/01/14", "01/01/15", "01/01/16"]
	demNames = []
	repubNames = []
	bothNames = []

	for n in range(4):
		thisNode = {}

		nameChoice = random.choice(names)
		names.remove(nameChoice)
		demNames.append(nameChoice)

		thisNode["name"] = nameChoice
		thisNode["id"] = nameChoice
		thisNode["info"] = "info on this person"
		thisNode["startDate"] = random.choice(startDates)
		thisNode["endDate"] = random.choice(endDates)
		thisNode["importance"] = importance
		thisNode["parity"] = random.uniform(0.0, 0.2)

		allNodes.append(thisNode)

	thisNode = {}
	nameChoice = random.choice(names)
	names.remove(nameChoice)
	bothNames.append(nameChoice)
	thisNode["name"] = nameChoice
	thisNode["id"] = nameChoice
	thisNode["info"] = "info on this person"
	thisNode["startDate"] = random.choice(startDates)
	thisNode["endDate"] = random.choice(endDates)
	thisNode["importance"] = importance
	thisNode["parity"] = random.uniform(0.45, 0.55)
	allNodes.append(thisNode)

	thisNode = {}
	nameChoice = random.choice(names)
	names.remove(nameChoice)
	bothNames.append(nameChoice)
	thisNode["name"] = nameChoice
	thisNode["id"] = nameChoice
	thisNode["info"] = "info on this person"
	thisNode["startDate"] = random.choice(startDates)
	thisNode["endDate"] = random.choice(endDates)
	thisNode["importance"] = importance
	thisNode["parity"] = random.uniform(0.45, 0.55)
	allNodes.append(thisNode)

	for n in range(4):
		thisNode = {}

		nameChoice = random.choice(names)
		names.remove(nameChoice)
		repubNames.append(nameChoice)

		thisNode["name"] = nameChoice
		thisNode["id"] = nameChoice
		thisNode["info"] = "info on this person"
		thisNode["startDate"] = random.choice(startDates)
		thisNode["endDate"] = random.choice(endDates)
		thisNode["importance"] = importance
		thisNode["parity"] = random.uniform(0.8, 1.0)

		allNodes.append(thisNode)

	for name in demNames:
		for otherName in demNames:
			if not (name == otherName):
				thisLink = {}

				thisLink["source"] = name
				thisLink["target"] = otherName
				thisLink["weight"] = random.randint(50, 80)

				allLinks.append(thisLink)

		for otherName in repubNames:
			thisLink = {}

			thisLink["source"] = name
			thisLink["target"] = otherName
			thisLink["weight"] = random.randint(350, 380)

			allLinks.append(thisLink)

		for otherName in bothNames:
			thisLink = {}

			thisLink["source"] = name
			thisLink["target"] = otherName
			thisLink["weight"] = random.randint(200, 230)

			allLinks.append(thisLink)

	for name in repubNames:
		for otherName in repubNames:
			if not (name == otherName):
				thisLink = {}

				thisLink["source"] = name
				thisLink["target"] = otherName
				thisLink["weight"] = random.randint(50, 80)

				allLinks.append(thisLink)

		for otherName in bothNames:
			thisLink = {}

			thisLink["source"] = name
			thisLink["target"] = otherName
			thisLink["weight"] = random.randint(200, 230)

			allLinks.append(thisLink)

	thisLink = {}

	thisLink["source"] = bothNames[0]
	thisLink["target"] = bothNames[1]
	thisLink["weight"] = random.randint(50, 80)

	allLinks.append(thisLink)
	
	data["nodes"] = allNodes
	data["links"] = allLinks
	
	with open("data/fakeData.json", "w+") as f:
		f.write(json.dumps(data, indent=4))

main()