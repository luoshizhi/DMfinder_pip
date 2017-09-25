import os,sys
if len(sys.argv) != 4:
    print "Usage: python %s dmfinder_result sv sample_name \n" % sys.argv[0] 
    sys.exit()
infile=sys.argv[1]
sv=sys.argv[2]
scriptpath=os.path.split(os.path.realpath(__file__))[0]
def mkdir(PATH):
    if not os.path.exists(PATH):
        os.makedirs(PATH)

f=open(infile)

infos=''
if not f.readline().startswith('There'):
    for ii in f:
        if ii.startswith('SEG'):
            first=ii.strip().split(":")[1].split()[0:3]
            second=ii.strip().split(":")[1].split()[3:6]
            infos=infos+("\t".join(first)+"\n")
            infos=infos+("\t".join(second)+"\n")
f.close()

if not len(infos)==0:
    mkdir('plot')
    b=open('plot/%s' % sys.argv[3],'w')
    b.write(infos)
    b.close()
else:
    sys.stderr.write("%s found No area!\n" % sys.argv[3])
    sys.exit()
#aaa='''source /ifshk4/BC_PUB/biosoft/newblc/01.Usr/environment.sh
#export R_LIBS="/ifshk7/BC_PS/wangmengyao/software/R_lib/:$R_LIBS"
#/ifshk4/BC_PUB/biosoft/newblc/03.Soft_ALL/R-3.4.0/bin/Rscript /ifshk4/BC_PUB/biosoft/pipe/bc_tumor/newblc/DMFinder/example/plot_dm.r plot/%s %s %s'''%(sys.argv[3],sv,sys.argv[3])
#print aaa
os.chdir('./plot')
os.system('%s/../bin/Rscript %s/plot_dm.r %s %s %s'%(scriptpath,sys.path[0],sys.argv[3],sv,sys.argv[3]))
os.chdir('../')
