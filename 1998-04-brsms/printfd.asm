; -------------------------------------------------------------------- 
; BrMSX v:1.32                                                         
; Copyright (C) 1997 by Ricardo Bittencourt                            
; module: PRINTCB.ASM
; -------------------------------------------------------------------- 

        .386p
code32  segment para public use32
        assume cs:code32, ds:code32

include z80.inc
include debug.inc
include io.inc
include psetFD.inc
include psetFDCB.inc
include print.inc

extrn prinXX: near
extrn prinFDCB: near
extrn isize: dword
extrn printmsgp: near
extrn printhex2p: near
extrn printhex4p: near

public psetFDxx
public psetFDCBxx

; --------------------------------------------------------------------

PRINTOP200      FD09,'ADD IY,BC$'
PRINTOP200      FD19,'ADD IY,DE$'
PRINTOP412      FD21,'LD IY,$'
PRINTOP422      FD22,'LD ($','),IY$'
PRINTOP200      FD23,'INC IY$'
PRINTOP200      FD24,'INC IYh$'
PRINTOP200      FD25,'DEC IYh$'
PRINTOP321      FD26,'LD IYh,$','$'
PRINTOP200      FD29,'ADD IY,IY$'
PRINTOP422      FD2A,'LD IY,($',')$'
PRINTOP200      FD2B,'DEC IY$'
PRINTOP200      FD2C,'INC IYl$'
PRINTOP200      FD2D,'DEC IYl$'
PRINTOP321      FD2E,'LD IYl,$','$'
PRINTOP321      FD34,'INC (IY+$',')$'
PRINTOP321      FD35,'DEC (IY+$',')$'
PRINTOP421      FD36,'LD (IY+$','),$'
PRINTOP200      FD39,'ADD IY,SP$'
PRINTOP100      FD40,'FD null prefix$'
PRINTOP100      FD41,'FD null prefix$'
PRINTOP100      FD42,'FD null prefix$'
PRINTOP100      FD43,'FD null prefix$'
PRINTOP200      FD44,'LD B,IYh$'
PRINTOP200      FD45,'LD B,IYl$'
PRINTOP321      FD46,'LD B,(IY+$',')$'
PRINTOP100      FD47,'FD null prefix$'
PRINTOP100      FD48,'FD null prefix$'
PRINTOP100      FD49,'FD null prefix$'
PRINTOP100      FD4A,'FD null prefix$'
PRINTOP100      FD4B,'FD null prefix$'
PRINTOP200      FD4C,'LD C,IYh$'
PRINTOP200      FD4D,'LD C,IYl$'
PRINTOP321      FD4E,'LD C,(IY+$',')$'
PRINTOP100      FD4F,'FD null prefix$'
PRINTOP100      FD50,'FD null prefix$'
PRINTOP100      FD51,'FD null prefix$'
PRINTOP100      FD52,'FD null prefix$'
PRINTOP100      FD53,'FD null prefix$'
PRINTOP200      FD54,'LD D,IYh$'
PRINTOP200      FD55,'LD D,IYl$'
PRINTOP321      FD56,'LD D,(IY+$',')$'
PRINTOP100      FD57,'FD null prefix$'
PRINTOP100      FD58,'FD null prefix$'
PRINTOP100      FD59,'FD null prefix$'
PRINTOP100      FD5A,'FD null prefix$'
PRINTOP100      FD5B,'FD null prefix$'
PRINTOP200      FD5C,'LD E,IYh$'
PRINTOP200      FD5D,'LD E,IYl$'
PRINTOP321      FD5E,'LD E,(IY+$',')$'
PRINTOP100      FD5F,'FD null prefix$'
PRINTOP200      FD60,'LD IYh,B$'
PRINTOP200      FD61,'LD IYh,C$'
PRINTOP200      FD62,'LD IYh,D$'
PRINTOP200      FD63,'LD IYh,E$'
PRINTOP200      FD64,'LD IYh,IYh$'
PRINTOP200      FD65,'LD IYh,IYl$'
PRINTOP321      FD66,'LD H,(IY+$',')$'
PRINTOP200      FD67,'LD IYh,A$'
PRINTOP200      FD68,'LD IYl,B$'
PRINTOP200      FD69,'LD IYl,C$'
PRINTOP200      FD6A,'LD IYl,D$'
PRINTOP200      FD6B,'LD IYl,E$'
PRINTOP200      FD6C,'LD IYl,IYh$'
PRINTOP200      FD6D,'LD IYl,IYl$'
PRINTOP321      FD6E,'LD L,(IY+$',')$'
PRINTOP200      FD6F,'LD IYl,A$'
PRINTOP321      FD70,'LD (IY+$','),B$'
PRINTOP321      FD71,'LD (IY+$','),C$'
PRINTOP321      FD72,'LD (IY+$','),D$'
PRINTOP321      FD73,'LD (IY+$','),E$'
PRINTOP321      FD74,'LD (IY+$','),H$'
PRINTOP321      FD75,'LD (IY+$','),L$'
PRINTOP100      FD76,'FD null prefix$'
PRINTOP321      FD77,'LD (IY+$','),A$'
PRINTOP100      FD78,'FD null prefix$'
PRINTOP100      FD79,'FD null prefix$'
PRINTOP100      FD7A,'FD null prefix$'
PRINTOP100      FD7B,'FD null prefix$'
PRINTOP200      FD7C,'LD A,IYh$'
PRINTOP200      FD7D,'LD A,IYl$'
PRINTOP321      FD7E,'LD A,(IY+$',')$'
PRINTOP100      FD7F,'FD null prefix$'
PRINTOP200      FD84,'ADD A,IYh$'
PRINTOP200      FD85,'ADD A,IYl$'
PRINTOP321      FD86,'ADD A,(IY+$',')$'
PRINTOP200      FD8C,'ADC A,IYh$'
PRINTOP200      FD8D,'ADC A,IYl$'
PRINTOP321      FD8E,'ADC A,(IY+$',')$'
PRINTOP200      FD94,'SUB IYh$'
PRINTOP200      FD95,'SUB IYl$'
PRINTOP321      FD96,'SUB (IY+$',')$'
PRINTOP200      FD9C,'SBC A,IYh$'
PRINTOP200      FD9D,'SBC A,IYl$'
PRINTOP321      FD9E,'SBC A,(IY+$',')$'
PRINTOP200      FDA4,'AND IYh$'
PRINTOP200      FDA5,'AND IYl$'
PRINTOP321      FDA6,'AND (IY+$',')$'
PRINTOP200      FDAC,'XOR IYh$'
PRINTOP200      FDAD,'XOR IYl$'
PRINTOP321      FDAE,'XOR (IY+$',')$'
PRINTOP200      FDB4,'OR IYh$'
PRINTOP200      FDB5,'OR IYl$'
PRINTOP321      FDB6,'OR (IY+$',')$'
PRINTOP200      FDBC,'CP IYh$'
PRINTOP200      FDBD,'CP IYl$'
PRINTOP321      FDBE,'CP (IY+$',')$'
PRINTOP200      FDE1,'POP IY$'
PRINTOP200      FDE3,'EX (SP),IY$'
PRINTOP200      FDE5,'PUSH IY$'
PRINTOP200      FDE9,'JP (IY)$'
PRINTOP200      FDF9,'LD SP,IY$'
PRINTOP100      FDNULL,'FD null prefix$'

PRINTOP42X      FDCB00,'LD B,RLC (IY+$',')$'
PRINTOP42X      FDCB01,'LD C,RLC (IY+$',')$'
PRINTOP42X      FDCB02,'LD D,RLC (IY+$',')$'
PRINTOP42X      FDCB03,'LD E,RLC (IY+$',')$'
PRINTOP42X      FDCB04,'LD H,RLC (IY+$',')$'
PRINTOP42X      FDCB05,'LD L,RLC (IY+$',')$'
PRINTOP42X      FDCB06,'RLC (IY+$',')$'
PRINTOP42X      FDCB07,'LD A,RLC (IY+$',')$'

PRINTOP42X      FDCB08,'LD B,RRC (IY+$',')$'
PRINTOP42X      FDCB09,'LD C,RRC (IY+$',')$'
PRINTOP42X      FDCB0A,'LD D,RRC (IY+$',')$'
PRINTOP42X      FDCB0B,'LD E,RRC (IY+$',')$'
PRINTOP42X      FDCB0C,'LD H,RRC (IY+$',')$'
PRINTOP42X      FDCB0D,'LD L,RRC (IY+$',')$'
PRINTOP42X      FDCB0E,'RRC (IY+$',')$'
PRINTOP42X      FDCB0F,'LD A,RRC (IY+$',')$'

PRINTOP42X      FDCB10,'LD B,RL (IY+$',')$'
PRINTOP42X      FDCB11,'LD C,RL (IY+$',')$'
PRINTOP42X      FDCB12,'LD D,RL (IY+$',')$'
PRINTOP42X      FDCB13,'LD E,RL (IY+$',')$'
PRINTOP42X      FDCB14,'LD H,RL (IY+$',')$'
PRINTOP42X      FDCB15,'LD L,RL (IY+$',')$'
PRINTOP42X      FDCB16,'RL (IY+$',')$'
PRINTOP42X      FDCB17,'LD A,RL (IY+$',')$'

PRINTOP42X      FDCB18,'LD B,RR (IY+$',')$'
PRINTOP42X      FDCB19,'LD C,RR (IY+$',')$'
PRINTOP42X      FDCB1A,'LD D,RR (IY+$',')$'
PRINTOP42X      FDCB1B,'LD E,RR (IY+$',')$'
PRINTOP42X      FDCB1C,'LD H,RR (IY+$',')$'
PRINTOP42X      FDCB1D,'LD L,RR (IY+$',')$'
PRINTOP42X      FDCB1E,'RR (IY+$',')$'
PRINTOP42X      FDCB1F,'LD A,RR (IY+$',')$'

PRINTOP42X      FDCB20,'LD B,SLA (IY+$',')$'
PRINTOP42X      FDCB21,'LD C,SLA (IY+$',')$'
PRINTOP42X      FDCB22,'LD D,SLA (IY+$',')$'
PRINTOP42X      FDCB23,'LD E,SLA (IY+$',')$'
PRINTOP42X      FDCB24,'LD H,SLA (IY+$',')$'
PRINTOP42X      FDCB25,'LD L,SLA (IY+$',')$'
PRINTOP42X      FDCB26,'SLA (IY+$',')$'
PRINTOP42X      FDCB27,'LD A,SLA (IY+$',')$'

PRINTOP42X      FDCB28,'LD B,SRA (IY+$',')$'
PRINTOP42X      FDCB29,'LD C,SRA (IY+$',')$'
PRINTOP42X      FDCB2A,'LD D,SRA (IY+$',')$'
PRINTOP42X      FDCB2B,'LD E,SRA (IY+$',')$'
PRINTOP42X      FDCB2C,'LD H,SRA (IY+$',')$'
PRINTOP42X      FDCB2D,'LD L,SRA (IY+$',')$'
PRINTOP42X      FDCB2E,'SRA (IY+$',')$'
PRINTOP42X      FDCB2F,'LD A,SRA (IY+$',')$'

PRINTOP42X      FDCB30,'LD B,SLL (IY+$',')$'
PRINTOP42X      FDCB31,'LD C,SLL (IY+$',')$'
PRINTOP42X      FDCB32,'LD D,SLL (IY+$',')$'
PRINTOP42X      FDCB33,'LD E,SLL (IY+$',')$'
PRINTOP42X      FDCB34,'LD H,SLL (IY+$',')$'
PRINTOP42X      FDCB35,'LD L,SLL (IY+$',')$'
PRINTOP42X      FDCB36,'SLL (IY+$',')$'
PRINTOP42X      FDCB37,'LD A,SLL (IY+$',')$'

PRINTOP42X      FDCB38,'LD B,SRL (IY+$',')$'
PRINTOP42X      FDCB39,'LD C,SRL (IY+$',')$'
PRINTOP42X      FDCB3A,'LD D,SRL (IY+$',')$'
PRINTOP42X      FDCB3B,'LD E,SRL (IY+$',')$'
PRINTOP42X      FDCB3C,'LD H,SRL (IY+$',')$'
PRINTOP42X      FDCB3D,'LD L,SRL (IY+$',')$'
PRINTOP42X      FDCB3E,'SRL (IY+$',')$'
PRINTOP42X      FDCB3F,'LD A,SRL (IY+$',')$'

PRINTOP42X      FDCB40,'BIT 0,(IY+$',')$'
PRINTOP42X      FDCB41,'BIT 0,(IY+$',')$'
PRINTOP42X      FDCB42,'BIT 0,(IY+$',')$'
PRINTOP42X      FDCB43,'BIT 0,(IY+$',')$'
PRINTOP42X      FDCB44,'BIT 0,(IY+$',')$'
PRINTOP42X      FDCB45,'BIT 0,(IY+$',')$'
PRINTOP42X      FDCB46,'BIT 0,(IY+$',')$'
PRINTOP42X      FDCB47,'BIT 0,(IY+$',')$'

PRINTOP42X      FDCB48,'BIT 1,(IY+$',')$'
PRINTOP42X      FDCB49,'BIT 1,(IY+$',')$'
PRINTOP42X      FDCB4A,'BIT 1,(IY+$',')$'
PRINTOP42X      FDCB4B,'BIT 1,(IY+$',')$'
PRINTOP42X      FDCB4C,'BIT 1,(IY+$',')$'
PRINTOP42X      FDCB4D,'BIT 1,(IY+$',')$'
PRINTOP42X      FDCB4E,'BIT 1,(IY+$',')$'
PRINTOP42X      FDCB4F,'BIT 1,(IY+$',')$'

PRINTOP42X      FDCB50,'BIT 2,(IY+$',')$'
PRINTOP42X      FDCB51,'BIT 2,(IY+$',')$'
PRINTOP42X      FDCB52,'BIT 2,(IY+$',')$'
PRINTOP42X      FDCB53,'BIT 2,(IY+$',')$'
PRINTOP42X      FDCB54,'BIT 2,(IY+$',')$'
PRINTOP42X      FDCB55,'BIT 2,(IY+$',')$'
PRINTOP42X      FDCB56,'BIT 2,(IY+$',')$'
PRINTOP42X      FDCB57,'BIT 2,(IY+$',')$'

PRINTOP42X      FDCB58,'BIT 3,(IY+$',')$'
PRINTOP42X      FDCB59,'BIT 3,(IY+$',')$'
PRINTOP42X      FDCB5A,'BIT 3,(IY+$',')$'
PRINTOP42X      FDCB5B,'BIT 3,(IY+$',')$'
PRINTOP42X      FDCB5C,'BIT 3,(IY+$',')$'
PRINTOP42X      FDCB5D,'BIT 3,(IY+$',')$'
PRINTOP42X      FDCB5E,'BIT 3,(IY+$',')$'
PRINTOP42X      FDCB5F,'BIT 3,(IY+$',')$'

PRINTOP42X      FDCB60,'BIT 4,(IY+$',')$'
PRINTOP42X      FDCB61,'BIT 4,(IY+$',')$'
PRINTOP42X      FDCB62,'BIT 4,(IY+$',')$'
PRINTOP42X      FDCB63,'BIT 4,(IY+$',')$'
PRINTOP42X      FDCB64,'BIT 4,(IY+$',')$'
PRINTOP42X      FDCB65,'BIT 4,(IY+$',')$'
PRINTOP42X      FDCB66,'BIT 4,(IY+$',')$'
PRINTOP42X      FDCB67,'BIT 4,(IY+$',')$'

PRINTOP42X      FDCB68,'BIT 5,(IY+$',')$'
PRINTOP42X      FDCB69,'BIT 5,(IY+$',')$'
PRINTOP42X      FDCB6A,'BIT 5,(IY+$',')$'
PRINTOP42X      FDCB6B,'BIT 5,(IY+$',')$'
PRINTOP42X      FDCB6C,'BIT 5,(IY+$',')$'
PRINTOP42X      FDCB6D,'BIT 5,(IY+$',')$'
PRINTOP42X      FDCB6E,'BIT 5,(IY+$',')$'
PRINTOP42X      FDCB6F,'BIT 5,(IY+$',')$'

PRINTOP42X      FDCB70,'BIT 6,(IY+$',')$'
PRINTOP42X      FDCB71,'BIT 6,(IY+$',')$'
PRINTOP42X      FDCB72,'BIT 6,(IY+$',')$'
PRINTOP42X      FDCB73,'BIT 6,(IY+$',')$'
PRINTOP42X      FDCB74,'BIT 6,(IY+$',')$'
PRINTOP42X      FDCB75,'BIT 6,(IY+$',')$'
PRINTOP42X      FDCB76,'BIT 6,(IY+$',')$'
PRINTOP42X      FDCB77,'BIT 6,(IY+$',')$'

PRINTOP42X      FDCB78,'BIT 7,(IY+$',')$'
PRINTOP42X      FDCB79,'BIT 7,(IY+$',')$'
PRINTOP42X      FDCB7A,'BIT 7,(IY+$',')$'
PRINTOP42X      FDCB7B,'BIT 7,(IY+$',')$'
PRINTOP42X      FDCB7C,'BIT 7,(IY+$',')$'
PRINTOP42X      FDCB7D,'BIT 7,(IY+$',')$'
PRINTOP42X      FDCB7E,'BIT 7,(IY+$',')$'
PRINTOP42X      FDCB7F,'BIT 7,(IY+$',')$'

PRINTOP42X      FDCB80,'LD B,RES 0,(IY+$',')$'
PRINTOP42X      FDCB81,'LD C,RES 0,(IY+$',')$'
PRINTOP42X      FDCB82,'LD D,RES 0,(IY+$',')$'
PRINTOP42X      FDCB83,'LD E,RES 0,(IY+$',')$'
PRINTOP42X      FDCB84,'LD H,RES 0,(IY+$',')$'
PRINTOP42X      FDCB85,'LD L,RES 0,(IY+$',')$'
PRINTOP42X      FDCB86,'RES 0,(IY+$',')$'
PRINTOP42X      FDCB87,'LD A,RES 0,(IY+$',')$'

PRINTOP42X      FDCB88,'LD B,RES 1,(IY+$',')$'
PRINTOP42X      FDCB89,'LD C,RES 1,(IY+$',')$'
PRINTOP42X      FDCB8A,'LD D,RES 1,(IY+$',')$'
PRINTOP42X      FDCB8B,'LD E,RES 1,(IY+$',')$'
PRINTOP42X      FDCB8C,'LD H,RES 1,(IY+$',')$'
PRINTOP42X      FDCB8D,'LD L,RES 1,(IY+$',')$'
PRINTOP42X      FDCB8E,'RES 1,(IY+$',')$'
PRINTOP42X      FDCB8F,'LD A,RES 1,(IY+$',')$'

PRINTOP42X      FDCB90,'LD B,RES 2,(IY+$',')$'
PRINTOP42X      FDCB91,'LD C,RES 2,(IY+$',')$'
PRINTOP42X      FDCB92,'LD D,RES 2,(IY+$',')$'
PRINTOP42X      FDCB93,'LD E,RES 2,(IY+$',')$'
PRINTOP42X      FDCB94,'LD H,RES 2,(IY+$',')$'
PRINTOP42X      FDCB95,'LD L,RES 2,(IY+$',')$'
PRINTOP42X      FDCB96,'RES 2,(IY+$',')$'
PRINTOP42X      FDCB97,'LD A,RES 2,(IY+$',')$'

PRINTOP42X      FDCB98,'LD B,RES 3,(IY+$',')$'
PRINTOP42X      FDCB99,'LD C,RES 3,(IY+$',')$'
PRINTOP42X      FDCB9A,'LD D,RES 3,(IY+$',')$'
PRINTOP42X      FDCB9B,'LD E,RES 3,(IY+$',')$'
PRINTOP42X      FDCB9C,'LD H,RES 3,(IY+$',')$'
PRINTOP42X      FDCB9D,'LD L,RES 3,(IY+$',')$'
PRINTOP42X      FDCB9E,'RES 3,(IY+$',')$'
PRINTOP42X      FDCB9F,'LD A,RES 3,(IY+$',')$'

PRINTOP42X      FDCBA0,'LD B,RES 4,(IY+$',')$'
PRINTOP42X      FDCBA1,'LD C,RES 4,(IY+$',')$'
PRINTOP42X      FDCBA2,'LD D,RES 4,(IY+$',')$'
PRINTOP42X      FDCBA3,'LD E,RES 4,(IY+$',')$'
PRINTOP42X      FDCBA4,'LD H,RES 4,(IY+$',')$'
PRINTOP42X      FDCBA5,'LD L,RES 4,(IY+$',')$'
PRINTOP42X      FDCBA6,'RES 4,(IY+$',')$'
PRINTOP42X      FDCBA7,'LD A,RES 4,(IY+$',')$'

PRINTOP42X      FDCBA8,'LD B,RES 5,(IY+$',')$'
PRINTOP42X      FDCBA9,'LD C,RES 5,(IY+$',')$'
PRINTOP42X      FDCBAA,'LD D,RES 5,(IY+$',')$'
PRINTOP42X      FDCBAB,'LD E,RES 5,(IY+$',')$'
PRINTOP42X      FDCBAC,'LD H,RES 5,(IY+$',')$'
PRINTOP42X      FDCBAD,'LD L,RES 5,(IY+$',')$'
PRINTOP42X      FDCBAE,'RES 5,(IY+$',')$'
PRINTOP42X      FDCBAF,'LD A,RES 5,(IY+$',')$'

PRINTOP42X      FDCBB0,'LD B,RES 6,(IY+$',')$'
PRINTOP42X      FDCBB1,'LD C,RES 6,(IY+$',')$'
PRINTOP42X      FDCBB2,'LD D,RES 6,(IY+$',')$'
PRINTOP42X      FDCBB3,'LD E,RES 6,(IY+$',')$'
PRINTOP42X      FDCBB4,'LD H,RES 6,(IY+$',')$'
PRINTOP42X      FDCBB5,'LD L,RES 6,(IY+$',')$'
PRINTOP42X      FDCBB6,'RES 6,(IY+$',')$'
PRINTOP42X      FDCBB7,'LD A,RES 6,(IY+$',')$'

PRINTOP42X      FDCBB8,'LD B,RES 7,(IY+$',')$'
PRINTOP42X      FDCBB9,'LD C,RES 7,(IY+$',')$'
PRINTOP42X      FDCBBA,'LD D,RES 7,(IY+$',')$'
PRINTOP42X      FDCBBB,'LD E,RES 7,(IY+$',')$'
PRINTOP42X      FDCBBC,'LD H,RES 7,(IY+$',')$'
PRINTOP42X      FDCBBD,'LD L,RES 7,(IY+$',')$'
PRINTOP42X      FDCBBE,'RES 7,(IY+$',')$'
PRINTOP42X      FDCBBF,'LD A,RES 7,(IY+$',')$'

PRINTOP42X      FDCBC0,'LD B,SET 0,(IY+$',')$'
PRINTOP42X      FDCBC1,'LD C,SET 0,(IY+$',')$'
PRINTOP42X      FDCBC2,'LD D,SET 0,(IY+$',')$'
PRINTOP42X      FDCBC3,'LD E,SET 0,(IY+$',')$'
PRINTOP42X      FDCBC4,'LD H,SET 0,(IY+$',')$'
PRINTOP42X      FDCBC5,'LD L,SET 0,(IY+$',')$'
PRINTOP42X      FDCBC6,'SET 0,(IY+$',')$'
PRINTOP42X      FDCBC7,'LD A,SET 0,(IY+$',')$'

PRINTOP42X      FDCBC8,'LD B,SET 1,(IY+$',')$'
PRINTOP42X      FDCBC9,'LD C,SET 1,(IY+$',')$'
PRINTOP42X      FDCBCA,'LD D,SET 1,(IY+$',')$'
PRINTOP42X      FDCBCB,'LD E,SET 1,(IY+$',')$'
PRINTOP42X      FDCBCC,'LD H,SET 1,(IY+$',')$'
PRINTOP42X      FDCBCD,'LD L,SET 1,(IY+$',')$'
PRINTOP42X      FDCBCE,'SET 1,(IY+$',')$'
PRINTOP42X      FDCBCF,'LD A,SET 1,(IY+$',')$'

PRINTOP42X      FDCBD0,'LD B,SET 2,(IY+$',')$'
PRINTOP42X      FDCBD1,'LD C,SET 2,(IY+$',')$'
PRINTOP42X      FDCBD2,'LD D,SET 2,(IY+$',')$'
PRINTOP42X      FDCBD3,'LD E,SET 2,(IY+$',')$'
PRINTOP42X      FDCBD4,'LD H,SET 2,(IY+$',')$'
PRINTOP42X      FDCBD5,'LD L,SET 2,(IY+$',')$'
PRINTOP42X      FDCBD6,'SET 2,(IY+$',')$'
PRINTOP42X      FDCBD7,'LD A,SET 2,(IY+$',')$'

PRINTOP42X      FDCBD8,'LD B,SET 3,(IY+$',')$'
PRINTOP42X      FDCBD9,'LD C,SET 3,(IY+$',')$'
PRINTOP42X      FDCBDA,'LD D,SET 3,(IY+$',')$'
PRINTOP42X      FDCBDB,'LD E,SET 3,(IY+$',')$'
PRINTOP42X      FDCBDC,'LD H,SET 3,(IY+$',')$'
PRINTOP42X      FDCBDD,'LD L,SET 3,(IY+$',')$'
PRINTOP42X      FDCBDE,'SET 3,(IY+$',')$'
PRINTOP42X      FDCBDF,'LD A,SET 3,(IY+$',')$'

PRINTOP42X      FDCBE0,'LD B,SET 4,(IY+$',')$'
PRINTOP42X      FDCBE1,'LD C,SET 4,(IY+$',')$'
PRINTOP42X      FDCBE2,'LD D,SET 4,(IY+$',')$'
PRINTOP42X      FDCBE3,'LD E,SET 4,(IY+$',')$'
PRINTOP42X      FDCBE4,'LD H,SET 4,(IY+$',')$'
PRINTOP42X      FDCBE5,'LD L,SET 4,(IY+$',')$'
PRINTOP42X      FDCBE6,'SET 4,(IY+$',')$'
PRINTOP42X      FDCBE7,'LD A,SET 4,(IY+$',')$'

PRINTOP42X      FDCBE8,'LD B,SET 5,(IY+$',')$'
PRINTOP42X      FDCBE9,'LD C,SET 5,(IY+$',')$'
PRINTOP42X      FDCBEA,'LD D,SET 5,(IY+$',')$'
PRINTOP42X      FDCBEB,'LD E,SET 5,(IY+$',')$'
PRINTOP42X      FDCBEC,'LD H,SET 5,(IY+$',')$'
PRINTOP42X      FDCBED,'LD L,SET 5,(IY+$',')$'
PRINTOP42X      FDCBEE,'SET 5,(IY+$',')$'
PRINTOP42X      FDCBEF,'LD A,SET 5,(IY+$',')$'

PRINTOP42X      FDCBF0,'LD B,SET 6,(IY+$',')$'
PRINTOP42X      FDCBF1,'LD C,SET 6,(IY+$',')$'
PRINTOP42X      FDCBF2,'LD D,SET 6,(IY+$',')$'
PRINTOP42X      FDCBF3,'LD E,SET 6,(IY+$',')$'
PRINTOP42X      FDCBF4,'LD H,SET 6,(IY+$',')$'
PRINTOP42X      FDCBF5,'LD L,SET 6,(IY+$',')$'
PRINTOP42X      FDCBF6,'SET 6,(IY+$',')$'
PRINTOP42X      FDCBF7,'LD A,SET 6,(IY+$',')$'

PRINTOP42X      FDCBF8,'LD B,SET 7,(IY+$',')$'
PRINTOP42X      FDCBF9,'LD C,SET 7,(IY+$',')$'
PRINTOP42X      FDCBFA,'LD D,SET 7,(IY+$',')$'
PRINTOP42X      FDCBFB,'LD E,SET 7,(IY+$',')$'
PRINTOP42X      FDCBFC,'LD H,SET 7,(IY+$',')$'
PRINTOP42X      FDCBFD,'LD L,SET 7,(IY+$',')$'
PRINTOP42X      FDCBFE,'SET 7,(IY+$',')$'
PRINTOP42X      FDCBFF,'LD A,SET 7,(IY+$',')$'


; --------------------------------------------------------------------

code32          ends
                end

