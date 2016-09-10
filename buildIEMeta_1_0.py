#USAGE: python buildIEMeta_X_X.py <file which holds the ASP program> <domain-atoms>
#       <domain-atoms> is of the form: "a,b,c,d" where a,b,c and d are atoms which shall be in the domain
#The output is generated automatically by "n.meta" where n is the name of the <file which holds the ASP program>.

#Example: python buildIEMeta_1_0.py aspProg.txt "a,b,d,z"
#Output: aspProg.txt.meta

#There are some restrictions how the passed ASP program must look like.
#The program must not contain:
# -) strong-negation (E.g., a and -a must be replaced by the rule "b :- a, na, not b" where b is a new atom and na is -a)
# -) constraints of the form " :- a" (They must be replaced by the rule "b :- a, not b", where b is a new atom)
# -) atoms of the name: "rX", where X = 1...#rules since these names are reserved for rule-names created by this meta program.

import sys
from sets import Set

try:
    ifile = open(sys.argv[1], "r")
except IOError:
    print "Error: File not found"
    sys.exit()
    
try:
    ofile = open(sys.argv[1]+".meta", "w")
except IOError:
    print "Could not create file"
    sys.exit()
    
domainAtoms = Set()

#Determine domain atoms
try:
    argdomainAtoms = sys.argv[2]
    argdomainAtomsSplit = argdomainAtoms.split(",")
    
    for a in argdomainAtomsSplit:
        domainAtoms.add(a)
except IOError:
    print "Could not create file"
    sys.exit()

ruleCount = 1

ifileContent = [line.strip() for line in ifile if line.strip()]

#Output original program as comments in meta program
for line in ifileContent:
    
    ofile.write("% "+line+"\n")
    
ofile.write("\n")

atoms = Set()

#pi_in
ofile.write("%pi_in\n")
#Add head and bodyP/N rules as facts (and determine atoms for python)
for line in ifileContent:
    if len(line.split(":-")) == 1:
        head = line.split(".")[0]
        ofile.write("head(r"+`ruleCount`+","+head.strip()+"). ")
    else:
        head = line.split(":-")[0]
        body = line.split(":-")[1]
        body = body[:-1]
        ofile.write("head(r"+`ruleCount`+","+head.strip()+"). ")
        atoms.add(head.strip())
        bodyElements = body.split(",")
        for bodyE in bodyElements:
            if not bodyE.strip().startswith("not"):
                ofile.write("bodyP(r"+`ruleCount`+","+bodyE.strip()+"). ")
                atoms.add(bodyE.strip())
            else:
                bodyE = bodyE.strip()[3:].strip()
                ofile.write("bodyN(r"+`ruleCount`+","+bodyE+"). ")
                atoms.add(bodyE)
    ruleCount = ruleCount + 1
    ofile.write("\n")
    
ofile.write("\n")

#Count atoms
atomCount = len(atoms)      
        
#RULE + ATOM
#pi_auxFacts
ofile.write("%pi_auxFacts\n")
ofile.write("atom(A) :- head(_,A).\n")
ofile.write("atom(A) :- bodyP(_,A).\n")
ofile.write("atom(A) :- bodyN(_,A).\n\n")
ofile.write("rule(R) :- head(R,_).\n")
ofile.write("rule(R) :- bodyP(R,_).\n")
ofile.write("rule(R) :- bodyN(R,_).\n\n")
#\RULE + ATOM

#pi_guessInt
ofile.write("%pi_guessInt\n")
ofile.write("true(A) v false(A) :- atom(A).\n")

ofile.write("\n")

#pi_reduct
ofile.write("%pi_reduct\n")
ruleCount = 1
for line in ifileContent:
    toBeWritten = "inReduct(r"+`ruleCount` + ") :- "
    
    if not len(line.split(":-")) == 1:
        body = line.split(":-")[1]
        body = body[:-1]
        bodyElements = body.split(",")
        for bodyE in bodyElements:
            if bodyE.strip().startswith("not"):
                bodyE = bodyE.strip()[3:].strip()
                toBeWritten = toBeWritten + "false("+bodyE+"), "
            
        if not len(toBeWritten) == len("inReduct(r"+`ruleCount` + ") :- "):
            ofile.write(toBeWritten[:-2] + ".\n")
    ruleCount = ruleCount + 1

toBeWritten = "inReduct(R) :- rule(R), "
for a in atoms:
    toBeWritten = toBeWritten + "not bodyN(R,"+a+"), "
ofile.write(toBeWritten[:-2] + ".\n")
ofile.write("outReduct(R) :- true(A), bodyN(R,A).\n")
ofile.write("order(A,I) v norder(A,I) :- true(A), #int(I), 0 <= I, I <= "+`atomCount-1`+".\n")

ofile.write("\n")

#pi_ap
ofile.write("%pi_ap\n")
ofile.write("notApplicable(R) :- rule(R), outReduct(R).\n")
ofile.write("notApplicable(R) :- inReduct(R), false(A), bodyP(R,A).\n")
ofile.write("notApplicable(R) :- head(R,H), order(H,I1), bodyP(R,B), order(B,I2), I2 >= I1.\n")

ofile.write("\n")

#pi_noAnswerSet
ofile.write("%pi_noAnswerSet\n")
toBeWritten = "noAnswerSet :- true(A), "
norder = "norder(A,"

for i in range(0,atomCount):
    toBeWritten = toBeWritten + norder + `i` + "), "
ofile.write(toBeWritten[:-2] + ".\n")    

ofile.write("noAnswerSet :- order(A,I1), order(A,I2), I1 != I2.\n")

for atom in atoms:
    toBeWritten = "noAnswerSet :- true("+atom+")"
    ruleCount = 1
    for line in ifileContent:
        if len(line.split(":-")) == 1:
            head = line.split(".")[0].strip()
            if head == atom:
                toBeWritten = toBeWritten + ", notApplicable(r"+`ruleCount`+")"
        else:
            head = line.split(":-")[0].strip()
            if head == atom:
                toBeWritten = toBeWritten + ", notApplicable(r"+`ruleCount`+")"
        
        ruleCount = ruleCount + 1    
        
    ofile.write(toBeWritten+", nfact("+atom+").\n")  
    
ruleCount = 1
for line in ifileContent:
    toBeWritten = "noAnswerSet :- false(A), inReduct(r"+`ruleCount`+"), head(r"+`ruleCount`+",A), "
    
    if not len(line.split(":-")) == 1:
        body = line.split(":-")[1]
        body = body[:-1]
        bodyElements = body.split(",")
        for bodyE in bodyElements:
            if not bodyE.strip().startswith("not"):
                bodyE = bodyE.strip()
                toBeWritten = toBeWritten + "true("+bodyE+"), "
            
    ofile.write(toBeWritten[:-2] + ".\n")
    ruleCount = ruleCount + 1

ofile.write("\n")


#pi_sat
ofile.write("%pi_sat\n")
ofile.write("true(A) :- noAnswerSet, atom(A).\n")
ofile.write("false(A) :- noAnswerSet, atom(A).\n")
ofile.write("order(A,I) :- noAnswerSet, atom(A), #int(I), 0 <= I, I <= "+`atomCount`+".\n")
ofile.write("norder(A,I) :- noAnswerSet, atom(A), #int(I), 0 <= I, I <= "+`atomCount`+".\n")
ofile.write("inReduct(R) :- rule(R), noAnswerSet.\n")
ofile.write("outReduct(R) :- rule(R), noAnswerSet.\n")

ofile.write("\n")

#pi_domain
#Add domain-atoms in the argument as facts to meta program
ofile.write("%pi_domain\n")
toBeWritten = ""
for d in domainAtoms:
    toBeWritten = toBeWritten + "domain("+d+"). "
ofile.write(toBeWritten + "\n\n")

#pi_guessExplanations
ofile.write("%pi_guessExplanations\n")
ofile.write("rp(A) v rm(A) v nr(A) :- domain(A).\n\n")

#pi_facts
ofile.write("%pi_facts\n")
ofile.write("fact(A) v nfact(A) :- domain(A).\n")
ofile.write("nfact(A) :- atom(A), not domain(A). %If atom A is not in domain, it must not be a fact. \n")
ofile.write("head(A,A) :- fact(A).\n\n")

#pi_invalidAnswerSet
#Result is no answer set if it is contradictory to inconsistency-explanations
ofile.write("%pi_invalidAnswerSet\n")
ofile.write("noAnswerSet :- rp(A), nfact(A).\n")
ofile.write("noAnswerSet :- rm(A), fact(A).\n")
ofile.write("noAnswerSet :- false(A), fact(A).\n")
ofile.write(":- not noAnswerSet.\n\n") #Delete all answer sets which are no explanation for an inconsistency

#pi_satFacts
ofile.write("%pi_satFacts\n")
ofile.write("fact(A) :- noAnswerSet, domain(A).\n")
ofile.write("nfact(A) :- noAnswerSet, domain(A).\n\n")

ofile.close()
ifile.close()
