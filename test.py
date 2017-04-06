import csv

endlist = []
with open('text.txt') as f:
    lines = f.read().splitlines()
for line in lines:
	res = line.split()
	res = [res[0], res[1], float(res[2])*1.5]
	res = [res[0], res[1], str(res[2])]
	#print(res)
	endlist.append(res)
#print(endlist)

f = open('margfaldadnut.txt', 'w')
for item in endlist:
	line = (' ').join(item)
	a=line+'\n'
	f.write(a)
f.close()