inputfile = open('pythonInput.log','r')
line2 = inputfile.readlines()[1]
inputfile.close()

split = line2.split("\t")
instance = split[1]
publichostname = split[3]

instanceFile = open('.ec2instance', 'w')
instanceFile.write(instance)
instanceFile.close()

publichostnameFile = open('.ec2publichostname', 'w')
publichostnameFile.write(publichostname)
publichostnameFile.close()
