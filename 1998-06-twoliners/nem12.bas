1 DIMZ%(4100):COLOR15,0,0:SCREEN12:SETPAGE0,0:R=63:P=-1.4:FORN=0TO11:Q=224*COS(P):W=224*SIN(P):S=64*(N\3):T=64*(NMOD3):A=1/32:B=A*A:I=-1:J=I:H=-A-A:E=B+B:D=I:FORY=0TO31:FORX=0TOR:F=-(D>0)*(Q*I+W*D):C=-(F>0)*INT(F+32*RND(1))AND248:PSET(X+S,Y+T),C:I=I+A
2 D=D-H-B:H=H+E:PSET(X+S,R-Y+T),C:NEXTX:I=-1:J=J+A:D=-J*J:H=-A-A:NEXTY:P=P+.262:NEXTN:SETPAGE1,1:CLS:FORS=0TO200:FORN=0TO21:Q=N>11:F=N+(N-10+NMOD12)*Q:S=64*(F\3):T=64*(FMOD3):COPY(S,T)-(S+R,T+R),0TOZ%:COPYZ%,-QTO(-R*Q,0):NEXTN,S
