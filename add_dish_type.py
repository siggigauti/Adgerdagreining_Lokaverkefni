with open('text.txt', encoding='utf-8') as f:
    lines = f.read().splitlines()
res = []
counter = 0
for line in lines:
	counter += 1
	variable = line.split(' ')
	if counter < 101:
		variable.insert(1, 0)
	elif counter >100 and counter <201:
		variable.insert(1, 1)
	elif counter >200:
		variable.insert(1, 2)
	res2 = [str(variable[0]), str(variable[1])]
	res.append(res2)
print(res)

f = open('dish_types.txt', 'w')
for item in res:
	line = (' ').join(item)
	a=line+'\n'
	f.write(a)
f.close()