/+  primitive-rsa, *test
=*  rsa  primitive-rsa
|%
++  test-rsakey
  =/  primes=(list @)
    :~    2    3    5    7   11   13   17   19   23   29   31   37   41   43
         47   53   59   61   67   71   73   79   83   89   97  101  103  107
        109  113  127  131  137  139  149  151  157  163  167  173  179  181
        191  193  197  199  211  223  227  229  233  239  241  251  257  263
        269  271  277  281  283  293  307  311  313  317  331  337  347  349
        353  359  367  373  379  383  389  397  401  409  419  421  431  433
        439  443  449  457  461  463  467  479  487  491  499  503  509  521
        523  541  547  557  563  569  571  577  587  593  599  601  607  613
        617  619  631  641  643  647  653  659  661  673  677  683  691  701
        709  719  727  733  739  743  751
    ==
  =/  k1  (new-key:rsa 2.048 0xdead.beef)
  ::
  =/  k2=key:rsa
    =/  p  0x1837.be57.1286.bf6a.3cf8.4716.634f.ef85.f947.c654.da6e.e222.
        5654.9466.0ab0.a2ef.1985.1095.e3c3.9e74.9478.e3f3.ee92.f885.ec3c.
        84c3.6b3c.9731.65f9.9d1d.f743.646f.37d7.82d8.3f4a.856c.6453.b2c8.
        28d5.d720.145e.c7ab.4ba9.a9c2.6b8e.8819.7aa8.69b3.420f.dbfa.1ddb.
        4d1a.9c2e.e25a.d4de.d351.945f.d7ca.74a4.815d.5f0e.9f44.df64.39bd
    =/  q  0xf1bc.ec8f.d238.32d9.afb8.8083.76b3.82da.6274.f56e.1b5b.662b.
        ab1b.1e01.fbd5.86c5.ba98.b246.b621.f190.2425.25ea.b39f.efa2.4fb8.
        0d6b.c3c4.460d.e7df.d2f5.6604.51e0.415b.db60.db5a.6601.16c7.46ec.
        5e67.9195.f3c9.80d3.47c5.fe24.fbfd.43c3.380a.40bd.c4f5.d65e.b93b.
        60ca.5f26.4ed7.9c64.d26d.b0fe.985d.7be3.1308.34dd.b8c5.4d7c.d8a5
    =/  n  (mul p q)
    =/  e  0x1.0001
    =/  d  (~(inv fo (elcm:rsa (dec p) (dec q))) e)
    [[n e] `[d p q]]
  ::
  |^  ^-  tang
      ;:  weld
          (check-primes k1)
          (check-primes k2)
      ==
  ++  check-primes
    =,  number
    |=  k=key:rsa
    ?>  ?=(^ sek.k)
    %+  roll  primes
    |=  [p=@ a=tang]
    ?^  a  a
    ?:  =(0 (mod n.pub.k p))
      :~  leaf+"{(scow %ux n.pub.k)}"
          :-  %leaf
          %+  weld
            "n.pub.key (prime? {(scow %f (pram n.pub.k))})"
          " divisible by {(scow %ud p)}:"
      ==
    ?:  =(0 (mod p.u.sek.k p))
      :~  leaf+"{(scow %ux p.u.sek.k)}"
          :-  %leaf
          %+  weld
            "p.u.sek.key (prime? {(scow %f (pram p.u.sek.k))})"
          " divisible by {(scow %ud p)}:"
      ==
    ?:  =(0 (mod q.u.sek.k p))
      :~  leaf+"{(scow %ux q.u.sek.k)}"
          :-  %leaf
          %+  weld
            "q.u.sek.key (prime? {(scow %f (pram q.u.sek.k))})"
          " divisible by {(scow %ud p)}:"
      ==
    ~
  --
::
++  test-rsa
  =/  k1=key:rsa
    =/  p  `@ux`61
    =/  q  `@ux`53
    =/  e  `@ux`17
    =/  n  (mul p q)
    =/  d  (~(inv fo (elcm:rsa (dec p) (dec q))) e)
    [[n e] `[d p q]]
  ::
  =/  k2=key:rsa
    :-  [`@ux`143 `@ux`7]
    [~ `@ux`103 `@ux`11 `@ux`13]
  ::
  :: ex from http://doctrina.org/How-RSA-Works-With-Examples.html
  =/  k3=key:rsa
    =/  p
  12.131.072.439.211.271.897.323.671.531.612.440.428.472.427.633.701.410.
     925.634.549.312.301.964.373.042.085.619.324.197.365.322.416.866.541.
     017.057.361.365.214.171.711.713.797.974.299.334.871.062.829.803.541
    =/  q
  12.027.524.255.478.748.885.956.220.793.734.512.128.733.387.803.682.075.
     433.653.899.983.955.179.850.988.797.899.869.146.900.809.131.611.153.
     346.817.050.832.096.022.160.146.366.346.391.812.470.987.105.415.233
    =/  n  (mul p q)
    =/  e  65.537
    =/  d  (~(inv fo (elcm:rsa (dec p) (dec q))) e)
    [[`@ux`n `@ux`e] `[`@ux`d `@ux`p `@ux`q]]
  =/  m3  (swp 3 'attack at dawn')
  =/  c3
    35.052.111.338.673.026.690.212.423.937.053.328.511.880.760.811.579.981.
       620.642.802.346.685.810.623.109.850.235.943.049.080.973.386.241.113.
       784.040.794.704.193.978.215.378.499.765.413.083.646.438.784.740.952.
       306.932.534.945.195.080.183.861.574.225.226.218.879.827.232.453.912.
       820.596.886.440.377.536.082.465.681.750.074.417.459.151.485.407.445.
       862.511.023.472.235.560.823.053.497.791.518.928.820.272.257.787.786
  ::
  ?>  ?=(^ sek.k1)
  ;:  weld
    %+  expect-eq
      !>  `@ux`413
      !>  d.u.sek.k1
  ::
    %+  expect-eq
      !>  2.790
      !>  (en:rsa 65 k1)
  ::
    %+  expect-eq
      !>  65
      !>  (de:rsa 2.790 k1)
  ::
    %+  expect-eq
      !>  48
      !>  (en:rsa 9 k2)
  ::
    %+  expect-eq
      !>  9
      !>  (de:rsa 48 k2)
  ::
    %+  expect-eq
      !>  c3
      !>  (en:rsa m3 k3)
  ::
    %+  expect-eq
      !>  m3
      !>  (de:rsa c3 k3)
  ==
--
