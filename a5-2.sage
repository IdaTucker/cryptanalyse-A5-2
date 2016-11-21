''' Définition de l'environnement '''

P.<x> = PolynomialRing(GF(2))
' LFSR1 '
P1 = x^19 + x^18 + x^17 + x^14 + 1
L1 = 19
' LFSR2 '
P2 = x^22 + x^21 + 1
L2 = 22
' LFSR3 '
P3 = x^23 + x^22 + x^21 + x^8 + 1
L3 = 23
' LFSR4 '
P4 = x^17 + x^12 + 1	
L4 = 17

''' Fonctions Générales sur les LFSR '''

' Tour de LFSR "simple" '
def lfsr_step(p,state):
	l = p.degree()
	out = state[0]
	state = state[1:] + [sum([p[l-i]*state[i] for i in range(l)])]
	return state, out

' Génére la matrice associée au polynôme P '
def lfsr_matrix(P):
	l = P.degree()
	M = Matrix(GF(2),l,l)
	for i in range(l-1):
		M[i,i+1] = 1
	coeffs = list(P)
	coeffs.reverse()
	M[l-1] = coeffs[:l]
	return M

' Calcul du terme majorant '
def maj(a,b,c):
	sum = lift (a) + lift (b) + lift (c)
	if sum >= 2:
		return GF(2)(1)
	else:
		return GF(2)(0)

' Initialisation du LFSR A5-2'    
def init(K, IV):
	R1 = [0 for i in range(L1)]
	R2 = [0 for i in range(L2)]
	R3 = [0 for i in range(L3)]
	R4 = [0 for i in range(L4)]
	for i in range(64):
		R1, _ = lfsr_step(P1,R1)
		R2, _ = lfsr_step(P2,R2)
		R3, _ = lfsr_step(P3,R3)
		R4, _ = lfsr_step(P4,R4)
		R1[18] = R1[18] + K[i]
		R2[21] = R2[21] + K[i]
		R3[22] = R3[22] + K[i]
		R4[16] = R4[16] + K[i]
	for i in range(22):
		R1, _ = lfsr_step(P1,R1)
		R2, _ = lfsr_step(P2,R2)
		R3, _ = lfsr_step(P3,R3)
		R4, _ = lfsr_step(P4,R4)
		R1[18] = R1[18] + IV[i]
		R2[21] = R2[21] + IV[i]
		R3[22] = R3[22] + IV[i]
		R4[16] = R4[16] + IV[i]
	R1[3] = GF(2)(1)
	R2[5] = GF(2)(1)
	R3[4] = GF(2)(1)
	R4[6] = GF(2)(1)
	return R1, R2, R3, R4

' Tour du LFSR A5-2 '
def a5_2_step(R1,R2,R3,R4):
	r1 = copy(R1)
	r2 = copy(R2)
	r3 = copy(R3)
	r4 = copy(R4)
	m = maj (r4[6],r4[13],r4[9])
	if r4[6] == m:
		r1, _ = lfsr_step(P1,r1)
	if r4[13] == m:
		r2, _ = lfsr_step(P2,r2)
	if r4[9] == m:
		r3, _ = lfsr_step(P3,r3)
	r4, out4 = lfsr_step(P4,r4)
	y1 = r1[0] + maj(r1[3], r1[4]+GF(2)(1), r1[6])
	y2 = r2[0] + maj(r2[8], r2[5]+GF(2)(1), r2[12])
	y3 = r3[0] + maj(r3[4], r3[9]+GF(2)(1), r3[6])
	y = y1 + y2 + y3
	return r1, r2, r3, r4, y

' Production de suite chiffrante du LFSR A5-2 de longueur N '
def production(N,R1,R2,R3,R4):
	z = []
	r1 = copy(R1)
	r2 = copy(R2)
	r3 = copy(R3)
	r4 = copy(R4)
	for i in range(99):
	        r1,r2,r3,r4, out = a5_2_step(r1,r2,r3,r4)
	for i in range(N):
		r1,r2,r3,r4, out = a5_2_step(r1,r2,r3,r4)
		z.append(out)
	return z

' Suite chiffrante de longueur 228 du LFSR A5-2 '
def a5_2(K,IV):
	r1, r2, r3, r4 = init(K, IV)
	return production (228, r1, r2, r3, r4)




''' QUESTION 1 '''

print "\n* * * * Question 1 * * * *\n"

# les variables displayX permettent d'afficher les tests pour la question X
display1 = true
# Avec la clef
k = Sequence([GF(2)(0), 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1])
# et l'IV
iv = Sequence([GF(2)(1), 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
# On obtient la suite chiffrante
z = Sequence([GF(2)(1), 1, 1, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 1, 0, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 1, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 0, 0, 1, 1, 0, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 0, 0, 1, 0, 1, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0])

my_z = a5_2(k,iv)
if display1:
        if my_z != z:
                print "Error, you have found:\n", my_z
        else:
                print "You have successfully found the correct cipher bits."




''' QUESTION 2 '''

print "\n* * * * Question 2 * * * *\n"
print "Proof made in the report."




''' QUESTION 3 '''

print "\n* * * * Question 3 * * * *\n"

' Matrices correspondant aux polynomes du LFSR A5-2 '
M1 = lfsr_matrix(P1)
M2 = lfsr_matrix(P2)
M3 = lfsr_matrix(P3)
M4 = lfsr_matrix(P4)

'''
equations_lineaires
entrée: le registre connu R4 et l'etape de la production à laquelle on s'interesse s
sortie: les registres R1, R2, R3 dont les contenus sont exprimés au moyens d'équations linéaires en les x_i
'''
BPR = BooleanPolynomialRing(64,'x')
v = BPR.gens()
def equations_lineaires(R4, s):
    R1_inconnu = vector(v[:19])
    R2_inconnu = vector(v[19:41])
    R3_inconnu = vector(v[41:])
    r4 = vector(copy(R4))
    # on veut les équations a l'etape s
    for i in range(s):
        m = maj (r4[6],r4[13],r4[9])
        if r4[6] == m:
            R1_inconnu = M1 * R1_inconnu
        if r4[13] == m:
            R2_inconnu = M2 * R2_inconnu
        if r4[9] == m:
            R3_inconnu = M3 * R3_inconnu
        r4 = M4 * r4
    return R1_inconnu, R2_inconnu, R3_inconnu, r4

display3 = false
s = 2
R4_connu = Sequence([GF(2)(0), 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1])
r1_eq, r2_eq, r3_eq, r4_eq = equations_lineaires(R4_connu, s)
if display3:
        print "A l'etape",s, ":\n"
        print "R1=", r1_eq, ":\n"
        print "R2=", r2_eq, ":\n"
        print "R3=", r3_eq, ":\n"



        
''' QUESTION 4 '''

print "\n* * * * Question 4 * * * *\n"
print "Proof made in the report."




''' QUESTION 5 '''

print "\n* * * * Question 5 * * * *\n"
'''
equations_quadratiques
entrée: le registre connu R4 et N le nombre de bits de z produit
sortie: les registres R1, R2, R3 dont les contenus sont exprimés au moyens d'équations linéaires en les x_i
'''
def equations_quadratiques(R4, N):
    # on fait 99 tours en ignorant le bit de sortie
    r1, r2, r3, r4 = equations_lineaires(R4, 99)
    equations_quadratiques = []
    # les N tours produisant la suite chiffrante
    for i in range(N):
        m = maj (r4[6],r4[13],r4[9])
        if r4[6] == m:
            r1 = M1 * r1
        if r4[13] == m:
            r2 = M2 * r2
        if r4[9] == m:
            r3 = M3 * r3
        r4 = M4 * r4
        y1 = r1[0] + (r1[3]*(r1[4]+1) + r1[3]*r1[6] + r1[6]*(r1[4]+1))
        y2 = r2[0] + (r2[8]*(r2[5]+1) + r2[8]*r2[12] + r2[12]*(r2[5]+1))
        y3 = r3[0] + (r3[4]*(r3[9]+1) + r3[4]*r3[6] + r3[6] * (r3[9]+1))
        z = y1 + y2 + y3
        # les monomes x3, x24 et x45 sont egaux a 1
        z = z.subs(x3 = 1, x24 = 1, x45 = 1)
        equations_quadratiques.append(z)
    return equations_quadratiques


display5 = false
N = 228
eq_quad = equations_quadratiques(R4_connu, N)
for i in range(N):
        if display5: print "z[",i,"] = ",eq_quad[i], "\n"        
        
        
        

''' QUESTION 6 '''

print "\n* * * * Question 6 * * * *\n"

display6 = false
M = set
for i in range(N):
        M = M.union(set(eq_quad[i].monomials()))
M.remove(BPR(1))
M = list(M)
M.sort()
M.reverse()

# Création d'un vecteur mappant les monomes de degre 1 avec les indices de notre matrice M
# Pour des questions d'implémentations, les monomes connus sont mappés à l'indice 0
# Mais comme leurs valeurs sont connues, ils seront remis à 1 plus tard
M_deg1 = [[i,M[i]] for i in range(len(M)) if M[i].deg() == 1]
M_deg1.insert(3,[0,v[3]])
M_deg1.insert(24,[0,v[24]])
M_deg1.insert(45,[0,v[45]])

L = len(M)	

if display6:
	print "La liste des monomes de degré au plus deux est:\n", M
	print "Il y a exactement ", L, "monomes distincts.\n"


''' QUESTION 7 '''

print "\n* * * * Question 7 * * * *\n"
print "TODO: Améliorer la compléxité && vérifier pour le test du vecteur!!"

def linear_mat_vect(N, eq_quadratique):
        Linear_Matrix = Matrix(GF(2), N, L)
        Linear_Vector = vector(GF(2), N)
        for i in range(N):
                tmp = eq_quadratique[i].monomials()
                if tmp[len(tmp)-1].degree() == 0:
                        Linear_Vector[i] = GF(2)(1)
                for j in range(len(M)):
                        if M[j] in tmp:
                                Linear_Matrix[i,j] = GF(2)(1)
        return Linear_Matrix, Linear_Vector
            


''' QUESTION 8 '''

print "\n* * * * Question 8 * * * *\n"
print "-----------TODO-----------"

# On considÃ¨re une exÃ©cution de A5/2 donnant N=700 bits de suite chiffrante avec  IV = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
N = 700
# Valeur de R4 aprÃ¨s la phase d'initialisation
R4 =  Sequence([GF(2)(0), 0, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1])
# Les 700 bits de suite chiffrante
z = Sequence([GF(2)(0), 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1, 1, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 1, 0, 1, 1, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 0, 0, 1, 1, 1, 0, 1, 0, 1, 1, 0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 1])

Lin_Matrix, Lin_Vector = linear_mat_vect(700, equations_quadratiques(R4, 700))
Result = Lin_Matrix.solve_right(Lin_Vector + vector(z))

Registers = [0] * 64
for i in range(len(M_deg1)):
    Registers[i] = Result[M_deg1[i][0]]
Registers[3] = BPR.one()
Registers[24] = BPR.one()
Registers[45] = BPR.one()

''' QUESTION 8 '''

print "\n* * * * Question 8 * * * *\n"
print "-----------TODO-----------"




''' QUESTION 9 '''

print "\n* * * * Question 9 * * * *\n"
print "-----------TODO-----------"




''' QUESTION 10 '''

print "\n* * * * Question 10 * * * *\n"
print "-----------TODO-----------"




''' QUESTION 11 '''

print "\n* * * * Question 11 * * * *\n"
print "-----------TODO-----------"




''' QUESTION 12 '''

print "\n* * * * Question 12 * * * *\n"
print "-----------TODO-----------"




''' QUESTION 13 '''

print "\n* * * * Question 13 * * * *\n"
print "-----------TODO-----------"




''' QUESTION 14 '''

print "\n* * * * Question 14 * * * *\n"
print "-----------TODO-----------"




''' QUESTION 15 '''

print "\n* * * * Question 15 * * * *\n"
print "-----------TODO-----------\n"
