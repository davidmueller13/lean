s = sexpr(1, 2, 3)
print(s)
s = sexpr(1, 2, 3, nil)
print(s)
s = sexpr(sexpr(1, 2), sexpr(3, 4), nil)
print(s)
s = sexpr(mpz("100000000000000"), mpq(3)/2, sexpr(1, 2, 3, nil), nil)
print(s)