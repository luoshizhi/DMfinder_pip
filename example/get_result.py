a=open('result.list','r')
b=open('result.txt.new','w')
for i in a:
    name=i.strip().split('/')[0]
    c=open(i.strip(),'r')
    for ii in c:
        if ii.startswith('SEG'):
            b.write(name+"\t"+ii.strip().split(":")[1]+"\n")
    c.close()
a.close()
b.close()
