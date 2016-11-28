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

' Longueur de la clef '
LK = 64

''' Variable display permet d'exécuter et d'afficher tous les tests '''
display = false

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
	for i in range(LK):
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
def a5_2(K,IV,nb_bits):
	r1, r2, r3, r4 = init(K, IV)
	return production (nb_bits, r1, r2, r3, r4)




''' QUESTION 1 '''

print "\n* * * * Question 1 * * * *\n"

# les variables displayX permettent d'afficher les tests pour la question X
display1 = false or display
# Avec la clef
k = Sequence([GF(2)(0), 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1])
# et l'IV
iv = Sequence([GF(2)(1), 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
# On obtient la suite chiffrante
z = Sequence([GF(2)(1), 1, 1, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 1, 0, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 1, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 0, 0, 1, 1, 0, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 0, 0, 1, 0, 1, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0])


if display1:
        my_z = a5_2(k, iv, 228)
        if my_z != z:
                print "Error, you have found:\n", my_z
        else:
                print "You have produced the correct cipher bits."




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
BPRX = BooleanPolynomialRing(64,'x')
v = BPRX.gens()
def equations_lineaires(R4, s):
    R1_q3 = vector(v[:19])
    R2_q3 = vector(v[19:41])
    R3_q3 = vector(v[41:])
    r4 = vector(copy(R4))
    # on veut les équations a l'etape s
    for i in range(s):
        m = maj (r4[6],r4[13],r4[9])
        if r4[6] == m:
            R1_q3 = M1 * R1_q3
        if r4[13] == m:
            R2_q3 = M2 * R2_q3
        if r4[9] == m:
            R3_q3 = M3 * R3_q3
        r4 = M4 * r4
    return R1_q3, R2_q3, R3_q3, r4

display3 = false or display
R4_connu = Sequence([GF(2)(0), 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1])

if display3:
        s = 2
        r1_eq, r2_eq, r3_eq, r4_eq = equations_lineaires(R4_connu, s)
        print "A l'etape",s, "\n"
        print "R1=", r1_eq,  "\n"
        print "R2=", r2_eq,  "\n"
        print "R3=", r3_eq,  "\n"



        
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


display5 = false or display
N = 228
eq_quad = equations_quadratiques(R4_connu, N)
if display5:
        i = randint(0,N-1)
        print "z[",i,"] = ",eq_quad[i], "\n"        
        
        
        

''' QUESTION 6 '''

print "\n* * * * Question 6 * * * *\n"

display6 = false or display
M = set
for i in range(N):
        M = M.union(set(eq_quad[i].monomials()))
M.remove(BPRX(1))
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

def linear_mat_vect(num_lines, num_cols, eq_quadratique, monoms):
        Linear_Matrix = Matrix(GF(2), num_lines, num_cols)
        Linear_Vector = vector(GF(2), num_lines)
        for i in range(num_lines):
                tmp = eq_quadratique[i].monomials()
                if tmp[len(tmp)-1].degree() == 0:
                        Linear_Vector[i] = GF(2)(1)
                for j in range(num_cols):
                        if monoms[j] in tmp:
                                Linear_Matrix[i,j] = GF(2)(1)
        return Linear_Matrix, Linear_Vector

print "Linearisation of equations linking z to the registers after initialisation.\n"


''' QUESTION 8 '''

print "\n* * * * Question 8 * * * *\n"


# On considere une execution de A5/2 donnant N=700 bits de suite chiffrante avec  IV = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
N = 700
# Valeur de R4 apres la phase d'initialisation
R4 =  Sequence([GF(2)(0), 0, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1])
# Les 700 bits de suite chiffrante
z = Sequence([GF(2)(0), 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1, 1, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 1, 0, 1, 1, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 0, 0, 1, 1, 1, 0, 1, 0, 1, 1, 0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 1])

Lin_Matrix, Lin_Vector = linear_mat_vect(700,L, equations_quadratiques(R4, 700),M)
Result = Lin_Matrix.solve_right(Lin_Vector + vector(z))

Registers = [0] * 64
for i in range(len(M_deg1)):
    Registers[i] = Result[M_deg1[i][0]]
Registers[3] = GF(2)(1)
Registers[24] = GF(2)(1)
Registers[45] = GF(2)(1)

R1_q8 = Registers[:19]
R2_q8 = Registers[19:41]
R3_q8 = Registers[41:]
R4_q8 = R4	

display8 = false or display
if display8:
	z_test = production (N,R1_q8,R2_q8,R3_q8,R4_q8)		
	if z_test == z:
		print "You have successfully found the correct registers after initialisation."


''' QUESTION 9 '''

print "\n* * * * Question 9 * * * *\n"
print "Proof made in the report."


''' QUESTION 10 '''

print "\n* * * * Question 10 * * * *\n"

# Creation de variables pour la clef k

BPRK = BooleanPolynomialRing(64,'k')
k_bits = BPRK.gens()
iv_q10 = Sequence([GF(2)(0) for i in range(LK)])

# Etats des LFSRs apres la premiere boucle for de init 

X1 = sum(M1^j*vector([0 for i in range(L1-1)]+[k_bits[63-j]]) for j in range (64))
X2 = sum(M2^j*vector([0 for i in range(L2-1)]+[k_bits[63-j]]) for j in range (64))
X3 = sum(M3^j*vector([0 for i in range(L3-1)]+[k_bits[63-j]]) for j in range (64))
X4 = sum(M4^j*vector([0 for i in range(L4-1)]+[k_bits[63-j]]) for j in range (64))

# Etats des LFSRs apres la deuxieme boucle for de init,
# IV est null donc on ignore la somme dans l'expression du registre

R1_q10 = M1^22*X1
R2_q10 = M2^22*X2
R3_q10 = M3^22*X3
R4_q10 = M4^22*X4

eq_k = list(R1_q10) + list(R2_q10) + list(R3_q10) + list(R4_q10)

# Creation d'une matrice qui a un 1 en position i,j
# si la coordonnée j de k_bits apparaît dans l'equation i

nb_lin = L1 + L2 + L3 + L4
K_Matrix, K_Vector = linear_mat_vect(nb_lin, LK, eq_k, k_bits)

display10 = false or display
V = VectorSpace	(GF(2),4)
for vec in V:	
	R1_q8[3] = vec[0]
	R2_q8[5] = vec[1]
	R3_q8[4] = vec[2]
	R4_q8[6] = vec[3]
	Registers_q10 = list(R1_q8) + list(R2_q8) + list(R3_q8) + list(R4_q8)
	try:
		K_Result = K_Matrix.solve_right(K_Vector + vector(Registers_q10))
		z_test = a5_2(K_Result,iv_q10,N)
		if z_test == z:
			if display10:
				print "You have successfully found the key."	
			break
	except ValueError:
		continue
    

''' QUESTION 11 '''

print "\n* * * * Question 11 * * * *\n"
print "Proof made in the report."



''' QUESTION 12 '''

print "\n* * * * Question 12 * * * *\n"
print "Proof made in the report."



''' QUESTION 13 '''

print "\n* * * * Question 13 * * * *\n"

# suite chiffrante de 228 bits produite par A_5/2 clef K et IV = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
# Valeur de R4 après la phase d'initialisation
R40_q13 =  Sequence([GF(2)(1), 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 1, 0, 0, 1])

z0 = Sequence([GF(2)(1), 1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 1, 0, 1, 0, 1, 1, 1, 0, 0, 1, 0, 1, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 1, 0, 1, 0, 1, 1, 1, 1, 0, 1, 0, 0, 0, 1, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 0, 0, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 1, 1, 0, 0, 0, 1, 1, 0, 1])

# suite chiffrante de 228 bits produite par A_5/2 clef K et IV = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]
z1 = Sequence([GF(2)(0), 1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 1, 0, 0, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 1, 0, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 1, 0, 0])

# suite chiffrante de 228 bits produite par A_5/2 clef K et IV = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0]
z2 = Sequence([GF(2)(0), 1, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 1, 1, 1, 0, 1, 1, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 0, 1, 0, 0, 0, 1, 1, 0, 1, 1, 1, 0])

# taille des chiffrés
N = 228

''' Déduction des xi à partir de R4 '''
timing = cputime()
# génération des équations quadratiques avec modifications des Registres 4
R41_q13 = copy(R40_q13)
R41_q13[len(R41_q13)-1] += 1
R42_q13 = copy(R40_q13)
R42_q13[len(R42_q13)-2] += 1
eq_quad_q12_iv0 = equations_quadratiques(R40_q13, N)
eq_quad_q12_iv1 = equations_quadratiques(R41_q13, N)
eq_quad_q12_iv2 = equations_quadratiques(R42_q13, N)

# remplacement des monômes impactés par les diffèrences d'IV entre les sites chiffrantes
# et ce, pour les res rgistres 1, 2 et 3
for i in range(N):
	eq_quad_q12_iv1[i] = eq_quad_q12_iv1[i].subs(x18 = v[18] + 1, x40 = v[40] + 1, x63 = v[63] + 1)
	eq_quad_q12_iv2[i] = eq_quad_q12_iv2[i].subs(x17 = v[17] + 1 ,x39 = v[39] + 1, x62 = v[62] + 1)
if eq_quad_q12_iv1 == eq_quad_q12_iv0:
	print "Error generating quadratic equations\n"

# génération des Matrices et Vecteurs pour les calculs
Lin_Matrix_z0, Lin_Vector1_z0 = linear_mat_vect(N, L, eq_quad_q12_iv0, M)
Lin_Matrix_z1, Lin_Vector1_z1 = linear_mat_vect(N, L, eq_quad_q12_iv1, M)
Lin_Matrix_z2, Lin_Vector1_z2 = linear_mat_vect(N, L, eq_quad_q12_iv2, M)
Lin_Matrix_z0_z1_z2 = Lin_Matrix_z0.stack(Lin_Matrix_z1.stack(Lin_Matrix_z2))
Lin_Vector_z0_z1_z2 =  vector(list(Lin_Vector1_z0) + list(Lin_Vector1_z1) + list(Lin_Vector1_z2) )
z0_z1_z2 = vector( z0 + z1 + z2 )
tmp = Lin_Vector_z0_z1_z2 + z0_z1_z2

# test pour trouver la solution 
try:	
    Result = Lin_Matrix_z0_z1_z2.solve_right(tmp )
    recover_reg_time = cputime(timing)
except ValueError:
	print "Aucune solution\n"

Registers = [0] * 64
for i in range(len(M_deg1)):
    Registers[i] = Result[M_deg1[i][0]]
Registers[3] = GF(2)(1)
Registers[24] = GF(2)(1)
Registers[45] = GF(2)(1)

# définition des regitres de cahcune des suites chiffrantes: R{registres}{suite}
R10_q13 = Registers[:19]
R20_q13 = Registers[19:41]
R30_q13 = Registers[41:64]

R11_q13 = copy(R10_q13)
R21_q13 = copy(R20_q13)
R31_q13 = copy(R30_q13)
R11_q13[len(R11_q13)-1] += GF(2)(1)
R21_q13[len(R21_q13)-1] += GF(2)(1)
R31_q13[len(R31_q13)-1] += GF(2)(1)

R12_q13 = copy(R10_q13)
R22_q13 = copy(R20_q13)
R32_q13 = copy(R30_q13)
R12_q13[len(R12_q13)-2] += GF(2)(1)
R22_q13[len(R22_q13)-2] += GF(2)(1)
R32_q13[len(R32_q13)-2] += GF(2)(1)

display13 = true or display

if display13:
    if (production(N, R10_q13, R20_q13, R30_q13, R40_q13) == z0) \
        and (production(N, R11_q13, R21_q13, R31_q13, R41_q13) == z1) \
        and (production(N, R12_q13, R22_q13, R32_q13, R42_q13) == z2):
        print "You have sucessfully recovered all the registers."        
        print "Time taken to recover the registers: ",recover_reg_time , "\n"

''' Déduction de la clef à partir des xi '''

        
# Creation de variables pour la clef k
k_bits_q13 = BPRK.gens()
iv_q13 = Sequence([GF(2)(0) for i in range(LK)])

X1 = sum(M1^j*vector([0 for i in range(L1-1)]+[k_bits_q13[63-j]]) for j in range (64))
X2 = sum(M2^j*vector([0 for i in range(L2-1)]+[k_bits_q13[63-j]]) for j in range (64))
X3 = sum(M3^j*vector([0 for i in range(L3-1)]+[k_bits_q13[63-j]]) for j in range (64))
X4 = sum(M4^j*vector([0 for i in range(L4-1)]+[k_bits_q13[63-j]]) for j in range (64))

# Etats des LFSRs apres la deuxieme boucle for de init,
# IV est null donc on ignore la somme dans l'expression du registre

R1_q13 = M1^22*X1
R2_q13 = M2^22*X2
R3_q13 = M3^22*X3
R4_q13 = M4^22*X4

eq_k_q13 = list(R1_q13) + list(R2_q13) + list(R3_q13) + list(R4_q13)      

# Creation d'une matrice qui a un 1 en position i,j
# si la coordonnée j de k_bits_q13 apparaît dans l'equation i

K_Matrix, K_Vector = linear_mat_vect(nb_lin, LK, eq_k_q13, k_bits_q13)

for vec in V:	
	R10_q13[3] = vec[0]
	R20_q13[5] = vec[1]
	R30_q13[4] = vec[2]
	R40_q13[6] = vec[3]
	Registers_q13 = list(R10_q13) + list(R20_q13) + list(R30_q13) + list(R40_q13)
	try:
		K_Result = K_Matrix.solve_right(K_Vector + vector(Registers_q13))
                recover_key_time = cputime(timing)
		z_test = a5_2(K_Result,iv_q13,N)
		if z_test == z0:
                       	if display13:
                                print "You have successfully found the key."
                                print "Time taken to recover the key: ", recover_key_time, "\n"	
			break
	except ValueError:
		continue


