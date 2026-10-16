"""Native multicolor pixel art: carved slate, aged bronze, articulated armour."""
from PIL import Image,ImageDraw
def artwork(font):
    font.update(Q=['010','101','101','111','011'],X=['101','101','010','101','101'],K=['101','101','110','101','101'],W=['101','101','111','111','101'])
    im=Image.new('P',(160,200),11);d=ImageDraw.Draw(im)
    def text(x,y,s,c=15):
        for letter in s:
            for yy,row in enumerate(font.get(letter,['000']*5)):
                for xx,v in enumerate(row):
                    if v=='1':d.point((x+xx,y+yy),fill=c)
            x+=4
    def stone(box):
        x0,y0,x1,y1=box;d.rectangle(box,fill=11)
        # Repeated fine grain is restrained and compresses efficiently.
        if x1-x0>80 or y1-y0>100:
            for y in range((y0//16)*16+3,y1,16):
                for x in range((x0//16)*16+2,x1,16):
                    if x>=x0 and y>=y0:d.line((x,y,min(x+1,x1),y),fill=12)
        d.rectangle(box,outline=0)
        d.line((x0+1,y0+1,x1-1,y0+1),fill=12)
        d.line((x0+1,y0+1,x0+1,y1-1),fill=12)
        d.line((x0+1,y1-1,x1-1,y1-1),fill=0)
        d.line((x1-1,y0+1,x1-1,y1-1),fill=0)
    def recess(box):
        x0,y0,x1,y1=box;d.rectangle(box,fill=0,outline=12)
        d.line((x0,y0,x1,y0),fill=0);d.line((x0,y0,x0,y1),fill=0)
        d.line((x0+1,y1,x1,y1),fill=15)
    def stud(x,y):
        d.rectangle((x,y,x+1,y+2),fill=9);d.point((x,y),fill=8)
    # Architecture: original screen/viewport proportions and exact cell bounds.
    stone((0,0,20,134));stone((124,0,159,134));stone((0,135,159,199))
    d.rectangle((21,1,123,133),fill=9,outline=0)
    d.rectangle((22,3,122,131),outline=8)
    d.line((23,5,121,5),fill=12);d.line((23,5,23,129),fill=12)
    d.line((23,129,121,129),fill=0);d.line((121,5,121,129),fill=0)
    d.rectangle((24,8,119,127),fill=0)
    for x,y in [(22,3),(121,3),(22,128),(121,128),(1,2),(17,2),(126,2),(156,2)]:stud(x,y)
    # Carved title plate and bronze corner fittings remain outside the viewport.
    d.rectangle((52,1,92,6),fill=0)
    text(55,1,'LABIRINTO',15)
    for x,y in [(22,6),(121,6),(22,130),(121,130)]:
        d.line((x,y,x,y+1),fill=8);d.point((x,y),fill=15)
    # Action strip. Inset buttons replace the bright rectangular gold rails.
    for i in range(5):
        y=8+i*24;stone((2,y,17,y+22));d.rectangle((4,y+4,15,y+18),fill=0)
        if i==0:
            d.polygon([(4,y+11),(7,y+7),(11,y+6),(15,y+11),(11,y+15),(7,y+15)],fill=12)
            d.polygon([(5,y+11),(8,y+8),(12,y+8),(14,y+11),(11,y+14),(8,y+13)],fill=15)
            d.ellipse((8,y+8,11,y+13),fill=3);d.line((10,y+9,10,y+12),fill=0)
        elif i==1:
            d.rounded_rectangle((5,y+5,14,y+14),radius=2,fill=12)
            d.rounded_rectangle((5,y+5,13,y+12),radius=2,fill=15)
            d.polygon([(7,y+12),(6,y+17),(10,y+12)],fill=12)
            d.line((7,y+8,11,y+8),fill=11);d.line((7,y+10,10,y+10),fill=11)
        elif i==2:
            d.polygon([(6,y+10),(8,y+11),(8,y+6),(9,y+5),(10,y+10),(10,y+4),(11,y+4),(12,y+10),(13,y+6),(14,y+7),(14,y+14),(11,y+18),(8,y+17)],fill=8)
            d.line((8,y+13,11,y+13),fill=9);d.line((9,y+15,12,y+15),fill=9)
            d.line((6,y+10,6,y+13),fill=9)
            d.line((9,y+7,9,y+10),fill=0);d.line((11,y+6,11,y+10),fill=0);d.line((13,y+8,13,y+11),fill=0)
        elif i==3:
            d.polygon([(7,y+13),(12,y+4),(13,y+5),(9,y+15)],fill=12)
            d.line((8,y+12,12,y+5),fill=15)
            d.line((6,y+12,11,y+16),fill=8);d.line((6,y+17,8,y+14),fill=9)
            d.point((6,y+17),fill=8)
        else:
            d.rounded_rectangle((5,y+7,14,y+17),radius=2,fill=9,outline=8)
            d.arc((7,y+3,12,y+10),180,360,fill=8)
            d.polygon([(6,y+8),(13,y+8),(11,y+12),(8,y+12)],fill=8)
            d.line((9,y+11,10,y+11),fill=0);d.line((7,y+14,12,y+14),fill=0)
    # Steel knight, not a rectangular mannequin: visor, pauldrons, articulated
    # elbows, tapered cuirass, mail skirt, knee guards and boots.
    recess((128,6,155,85));d.rectangle((130,8,153,82),fill=0)
    # Burgundy cloak behind the articulated steel silhouette.
    d.polygon([(138,27),(146,27),(151,64),(153,78),(146,76),(142,70),(136,77),(131,78),(134,61)],fill=2)
    d.line((134,64,132,76),fill=0);d.line((150,64,151,75),fill=0)
    d.ellipse((138,10,146,23),fill=12)
    d.polygon([(138,15),(140,11),(144,11),(146,15),(145,23),(141,25),(138,21)],fill=12)
    d.line((140,12,143,12),fill=15);d.line((139,14,139,19),fill=15)
    d.line((139,17,145,17),fill=0);d.point((142,18),fill=15)
    d.line((143,20,145,20),fill=11);d.line((141,22,144,22),fill=11)
    d.polygon([(140,24),(145,24),(148,28),(137,28)],fill=11)
    d.line((139,25,145,25),fill=15)
    d.polygon([(138,27),(147,27),(149,33),(147,43),(145,48),(139,48),(136,38),(136,32)],fill=12)
    d.polygon([(139,28),(142,29),(141,40),(138,36)],fill=15)
    d.line((144,29,144,42),fill=11);d.line((139,44,146,44),fill=11)
    for left in (True,False):
        if left:
            d.polygon([(136,27),(132,29),(131,33),(133,37),(137,35),(138,29)],fill=12)
            d.line((133,29,136,28),fill=15)
            d.polygon([(132,36),(135,36),(136,44),(134,48),(132,45)],fill=11)
            d.line((133,37,133,42),fill=15)
            d.ellipse((132,44,136,49),fill=12)
            d.polygon([(133,49),(136,48),(135,57),(132,59),(131,55)],fill=12)
            d.line((133,50,132,54),fill=15)
            d.rectangle((131,58,134,62),fill=11)
        else:
            d.polygon([(148,27),(152,29),(154,34),(152,37),(148,35),(146,29)],fill=12)
            d.line((149,28,152,30),fill=15)
            d.polygon([(150,36),(153,36),(152,46),(149,47)],fill=11)
            d.line((152,37,152,42),fill=12)
            d.ellipse((148,44,152,49),fill=12)
            d.polygon([(149,48),(152,49),(153,57),(151,60),(149,57)],fill=12)
            d.line((150,50,151,55),fill=15)
            d.rectangle((150,59,153,62),fill=11)
    d.rectangle((138,47,146,49),fill=9);d.rectangle((141,47,143,49),fill=8)
    d.polygon([(138,50),(146,50),(149,58),(135,58)],fill=11)
    for y in range(51,58,2):
        for x in range(137+(y//2)%2,148,2):d.point((x,y),fill=12)
    for x,dx in [(137,-1),(144,1)]:
        d.polygon([(x,58),(x+4,58),(x+3,65),(x+2,72),(x+2+dx,78),(x-1+dx,78),(x,69)],fill=12)
        d.line((x+1,59,x+1,64),fill=15)
        d.ellipse((x-1,64,x+3,69),fill=11);d.line((x,65,x+2,65),fill=15)
        d.line((x+1,70,x,76),fill=15)
        d.polygon([(x-1+dx,77),(x+2+dx,77),(x+3+dx,81),(x-2+dx,81)],fill=11)
        d.line((x-1+dx,78,x+2+dx,78),fill=12)
    # A leather-faced shield and a slender steel sword make the paper doll readable.
    d.polygon([(132,35),(137,38),(136,51),(133,57),(129,51),(128,38)],fill=12)
    d.polygon([(132,38),(135,40),(134,49),(132,53),(130,49),(130,40)],fill=9)
    d.line((132,39,132,49),fill=8);d.ellipse((131,42,133,46),fill=15)
    d.line((151,34,153,58),fill=12);d.line((151,34,152,50),fill=15)
    d.line((149,51,154,51),fill=8);d.line((152,52,153,57),fill=9)
    text(132,89,'EQUIP',15)
    # Symmetrical inventory sockets with small metal/leather objects.
    for row in range(2):
        for col in range(3):
            x=128+10*col;y=99+14*row;stone((x,y,x+8,y+11));d.rectangle((x+2,y+3,x+6,y+8),fill=0)
            if (row,col)==(0,0):d.ellipse((x+3,y+4,x+5,y+8),outline=8)
            elif (row,col)==(0,1):d.polygon([(x+4,y+3),(x+2,y+7),(x+4,y+9),(x+6,y+7)],fill=12);d.point((x+4,y+4),fill=15)
            elif (row,col)==(0,2):d.rectangle((x+2,y+4,x+6,y+8),fill=9);d.line((x+3,y+4,x+5,y+4),fill=8)
            elif col==0:
                d.polygon([(x+2,y+3),(x+4,y+3),(x+4,y+6),(x+6,y+7),(x+6,y+9),(x+2,y+9)],fill=8)
                d.line((x+2,y+9,x+6,y+9),fill=9)
            elif col==1:
                d.rectangle((x+2,y+3,x+6,y+9),fill=15);d.line((x+3,y+5,x+5,y+5),fill=11);d.line((x+3,y+7,x+4,y+7),fill=11)
            else:
                d.ellipse((x+2,y+3,x+6,y+9),fill=12);d.line((x+2,y+6,x+6,y+6),fill=0);d.point((x+3,y+4),fill=15)
    # Bottom toolbar: quieter stone, graduated meters and two-tone symbols.
    d.line((2,138,157,138),fill=12);d.line((2,139,157,139),fill=0)
    stone((3,145,44,194));d.rectangle((5,147,42,192),fill=0)
    text(6,149,'VITA');text(30,149,'100')
    recess((6,157,40,163));d.rectangle((7,158,39,161),fill=2);d.line((8,158,38,158),fill=10)
    for x in (15,23,31):d.line((x,159,x,161),fill=0)
    text(6,172,'MANA');text(30,172,'72')
    recess((6,180,40,186));d.rectangle((7,181,30,184),fill=6);d.line((8,181,29,181),fill=14)
    for x in (15,23,31):d.line((x,182,x,184),fill=0)
    # Small heart and mana-drop emblems, with glints above the filled gauges.
    d.polygon([(24,149),(25,150),(26,149),(27,151),(25,154),(23,151)],fill=2)
    d.point((24,150),fill=10)
    d.polygon([(25,171),(27,175),(25,177),(23,175)],fill=6);d.point((24,174),fill=14)
    # Compass in a bronze mounting, slim rose and cardinal points.
    stone((47,145,77,194));d.ellipse((52,151,72,189),fill=9,outline=8)
    d.ellipse((54,154,70,186),fill=0,outline=12)
    text(61,147,'N');text(49,169,'O',12);text(73,169,'E',12);text(61,188,'S',12)
    d.line((62,158,62,183),fill=11);d.line((55,171,69,171),fill=11)
    d.polygon([(62,157),(65,173),(62,170),(59,173)],fill=15)
    d.polygon([(62,183),(59,168),(62,171),(65,168)],fill=8)
    d.point((62,171),fill=7)
    for x,y in [(62,153),(55,158),(69,158),(54,170),(70,170),(55,182),(69,182),(62,187)]:d.point((x,y),fill=15)
    # Commands: key, spell, journal / map, inventory, rest. No letter clutter.
    for x in (80,94,108):
        for y in (147,172):stone((x,y,x+11,y+19));d.rectangle((x+2,y+3,x+9,y+16),fill=0)
    d.ellipse((83,151,88,157),outline=8);d.line((86,157,86,163),fill=8);d.line((86,162,89,162),fill=8)
    d.polygon([(100,150),(102,155),(105,157),(101,159),(100,163),(98,158),(96,157),(99,155)],fill=3)
    d.rectangle((111,151,117,162),fill=9);d.line((112,151,112,162),fill=8);d.line((114,154,116,154),fill=15);d.line((114,157,116,157),fill=12)
    d.polygon([(83,177),(85,176),(87,178),(89,176),(89,185),(87,187),(85,185),(83,186)],fill=12)
    d.line((85,178,85,184),fill=15);d.line((87,180,87,185),fill=11)
    d.rounded_rectangle((97,179,103,187),radius=1,fill=9,outline=8);d.arc((98,175,102,182),180,360,fill=8)
    d.rectangle((111,182,117,187),fill=12);d.line((111,178,111,189),fill=15);d.line((112,182,116,182),fill=15)
    # Glass flasks: corks, narrow necks, colored liquid and clear silhouettes.
    recess((123,145,158,188))
    for x,c,light in [(128,2,10),(141,6,14),(154,5,13)]:
        d.ellipse((x-5,184,x+4,188),fill=0)
        d.rectangle((x-2,147,x+1,150),fill=9);d.line((x-2,147,x+1,147),fill=8)
        d.rectangle((x-1,151,x+1,159),fill=12);d.line((x-1,152,x-1,157),fill=15)
        d.polygon([(x-1,158),(x+1,158),(x+4,165),(x+4,179),(x+2,184),(x-3,184),(x-5,180),(x-5,166)],fill=11)
        d.polygon([(x-3,167),(x+2,167),(x+3,170),(x+3,178),(x+1,182),(x-2,182),(x-4,178),(x-4,171)],fill=c)
        d.line((x-3,170,x-3,176),fill=light);d.point((x-2,168),fill=light)
    d.ellipse((125,191,129,197),fill=8,outline=9);d.line((127,192,127,196),fill=7)
    text(132,192,'124',8)
    return im
