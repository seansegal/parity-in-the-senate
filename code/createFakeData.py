import json
import random

def main():
	data = {}
	allNodes = []
	allLinks = []

	importance = 12
	names = ["senator1", "senator2", "senator3", "senator4", "senator5", "senator6", "senator7", "senator8", "senator9", "senator10"]
	terms = ["2012", "2013", "2014"]
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
		thisNode["importance"] = importance

		randNum = random.uniform(0, 1)
		thisTerms = list(terms)
		if randNum < 0.33:
			choice1 = random.choice(thisTerms)
			thisTerms.remove(choice1)
			thisNode["parities"] = {choice1:random.uniform(0.0, 0.2)}
		elif randNum >= 0.33 and randNum < 0.66:
			choice1 = random.choice(thisTerms)
			thisTerms.remove(choice1)
			choice2 = random.choice(thisTerms)
			thisTerms.remove(choice2)
			thisNode["parities"] = {choice1:random.uniform(0.0, 0.2), choice2:random.uniform(0.0, 0.2)}
		else:
			choice1 = random.choice(thisTerms)
			thisTerms.remove(choice1)
			choice2 = random.choice(thisTerms)
			thisTerms.remove(choice2)
			choice3 = random.choice(thisTerms)
			thisTerms.remove(choice3)
			thisNode["parities"] = {choice1:random.uniform(0.0, 0.2), choice2:random.uniform(0.0, 0.2), choice3:random.uniform(0.0, 0.2)}

		allNodes.append(thisNode)

	thisNode = {}
	nameChoice = random.choice(names)
	names.remove(nameChoice)
	bothNames.append(nameChoice)
	thisNode["name"] = nameChoice
	thisNode["id"] = nameChoice
	thisNode["info"] = "info on this person"
	thisNode["importance"] = importance
	
	randNum = random.uniform(0, 1)
	thisTerms = list(terms)
	if randNum < 0.33:
		choice1 = random.choice(thisTerms)
		thisTerms.remove(choice1)
		thisNode["parities"] = {choice1:random.uniform(0.45, 0.55)}
	elif randNum >= 0.33 and randNum < 0.66:
		choice1 = random.choice(thisTerms)
		thisTerms.remove(choice1)
		choice2 = random.choice(thisTerms)
		thisTerms.remove(choice2)
		thisNode["parities"] = {choice1:random.uniform(0.45, 0.55), choice2:random.uniform(0.45, 0.55)}
	else:
		choice1 = random.choice(thisTerms)
		thisTerms.remove(choice1)
		choice2 = random.choice(thisTerms)
		thisTerms.remove(choice2)
		choice3 = random.choice(thisTerms)
		thisTerms.remove(choice3)
		thisNode["parities"] = {choice1:random.uniform(0.45, 0.55), choice2:random.uniform(0.45, 0.55), choice3:random.uniform(0.45, 0.55)}

	allNodes.append(thisNode)

	thisNode = {}
	nameChoice = random.choice(names)
	names.remove(nameChoice)
	bothNames.append(nameChoice)
	thisNode["name"] = nameChoice
	thisNode["id"] = nameChoice
	thisNode["info"] = "info on this person"
	thisNode["importance"] = importance
	
	randNum = random.uniform(0, 1)
	thisTerms = list(terms)
	if randNum < 0.33:
		choice1 = random.choice(thisTerms)
		thisTerms.remove(choice1)
		thisNode["parities"] = {choice1:random.uniform(0.45, 0.55)}
	elif randNum >= 0.33 and randNum < 0.66:
		choice1 = random.choice(thisTerms)
		thisTerms.remove(choice1)
		choice2 = random.choice(thisTerms)
		thisTerms.remove(choice2)
		thisNode["parities"] = {choice1:random.uniform(0.45, 0.55), choice2:random.uniform(0.45, 0.55)}
	else:
		choice1 = random.choice(thisTerms)
		thisTerms.remove(choice1)
		choice2 = random.choice(thisTerms)
		thisTerms.remove(choice2)
		choice3 = random.choice(thisTerms)
		thisTerms.remove(choice3)
		thisNode["parities"] = {choice1:random.uniform(0.45, 0.55), choice2:random.uniform(0.45, 0.55), choice3:random.uniform(0.45, 0.55)}

	allNodes.append(thisNode)

	for n in range(4):
		thisNode = {}

		nameChoice = random.choice(names)
		names.remove(nameChoice)
		repubNames.append(nameChoice)

		thisNode["name"] = nameChoice
		thisNode["id"] = nameChoice
		thisNode["info"] = "info on this person"
		thisNode["importance"] = importance
		
		randNum = random.uniform(0, 1)
		thisTerms = list(terms)
		if randNum < 0.33:
			choice1 = random.choice(thisTerms)
			thisTerms.remove(choice1)
			thisNode["parities"] = {choice1:random.uniform(0.8, 0.1)}
		elif randNum >= 0.33 and randNum < 0.66:
			choice1 = random.choice(thisTerms)
			thisTerms.remove(choice1)
			choice2 = random.choice(thisTerms)
			thisTerms.remove(choice2)
			thisNode["parities"] = {choice1:random.uniform(0.8, 0.1), choice2:random.uniform(0.8, 0.1)}
		else:
			choice1 = random.choice(thisTerms)
			thisTerms.remove(choice1)
			choice2 = random.choice(thisTerms)
			thisTerms.remove(choice2)
			choice3 = random.choice(thisTerms)
			thisTerms.remove(choice3)
			thisNode["parities"] = {choice1:random.uniform(0.8, 0.1), choice2:random.uniform(0.8, 0.1), choice3:random.uniform(0.8, 0.1)}

		allNodes.append(thisNode)

	for name in demNames:
		for otherName in demNames:
			if not (name == otherName):
				thisLink = {}

				thisLink["source"] = name
				thisLink["target"] = otherName
				thisLink["weight"] = random.randint(50, 80)
				thisLink["term"] = random.choice(terms)

				allLinks.append(thisLink)

		for otherName in repubNames:
			thisLink = {}

			thisLink["source"] = name
			thisLink["target"] = otherName
			thisLink["weight"] = random.randint(350, 380)
			thisLink["term"] = random.choice(terms)

			allLinks.append(thisLink)

		for otherName in bothNames:
			thisLink = {}

			thisLink["source"] = name
			thisLink["target"] = otherName
			thisLink["weight"] = random.randint(200, 230)
			thisLink["term"] = random.choice(terms)

			allLinks.append(thisLink)

	for name in repubNames:
		for otherName in repubNames:
			if not (name == otherName):
				thisLink = {}

				thisLink["source"] = name
				thisLink["target"] = otherName
				thisLink["weight"] = random.randint(50, 80)
				thisLink["term"] = random.choice(terms)

				allLinks.append(thisLink)

		for otherName in bothNames:
			thisLink = {}

			thisLink["source"] = name
			thisLink["target"] = otherName
			thisLink["weight"] = random.randint(200, 230)
			thisLink["term"] = random.choice(terms)

			allLinks.append(thisLink)

	thisLink = {}

	thisLink["source"] = bothNames[0]
	thisLink["target"] = bothNames[1]
	thisLink["weight"] = random.randint(50, 80)
	thisLink["term"] = random.choice(terms)

	allLinks.append(thisLink)
	
	data["nodes"] = allNodes
	data["links"] = allLinks
	
	with open("../docs/data/fakeData.json", "w+") as f:
		f.write(json.dumps(data, indent=4))

main()