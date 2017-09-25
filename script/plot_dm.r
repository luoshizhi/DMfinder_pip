args<-commandArgs(T)
if(length(args) != 3){
  cat("plot_dm.r  <dm_seg.file> <sv.file> <sample_name> \n")
  q()
}
dm_seg=args[1]
sv_file=args[2]
sample_name=args[3]
spdf=paste(sample_name,'.pdf',sep="")
library('circlize')
cnv<-read.table(dm_seg,header=F)
names(cnv)<-c('chr','start','end')
fa<-as.character(unique(cnv[,'chr']))
xl<-c()
for (i in fa){
  xl<-c(xl,min(subset(cnv,chr==i)[,'start'])-1000000,max(subset(cnv,chr==i)[,'end'])+1000000)
}

sv<-read.table(sv_file,header=F,sep="\t")[,c('V4','V5','V9','V10')]
names(sv)<-c('chr1','bp1','chr2','bp2')
cnv_edge1<-data.frame(chr<-cnv[,c('chr')],left<-cnv[,'start']-30000,right<-cnv[,'start']+30000)
names(cnv_edge1)<-c('chr','left','right')
cnv_edge2<-data.frame(chr<-cnv[,c('chr')],left<-cnv[,'end']-30000,right<-cnv[,'end']+30000)
names(cnv_edge2)<-c('chr','left','right')
cnv_edge<-rbind(cnv_edge1,cnv_edge2)
sv$chr1<-as.character(sv$chr1)
sv$chr2<-as.character(sv$chr2)
dm_sv<-data.frame()
for (i in 1:length(sv[,1])){
  if(length(subset(cnv_edge,chr==sv[i,'chr1']&left<=sv[i,'bp1']&right>=sv[i,'bp1'])[,1])>0&length(subset(cnv_edge,chr==sv[i,'chr2']&left<=sv[i,'bp2']&right>=sv[i,'bp2'])[,1])>0){
    dm_sv<-rbind(dm_sv,sv[i,])
  }
}

gene<-read.table('/ifshk4/BC_PUB/biosoft/pipe/bc_tumor/newblc/DMFinder/example/gene_table.bed.new',header=T,sep="\t")[,c('chr','tx_start','tx_end','name')]
gene$chr<-as.character(gene$chr)
gene$name<-as.character(gene$name)
gene_bed<-data.frame()
for (i in 1:length(gene[,1])){
  if (length(subset(cnv,chr==gene[i,'chr']&start<=gene[i,'tx_start']&end>=gene[i,'tx_end'])[,1])>0){
    gene_bed<-rbind(gene_bed,gene[i,])
  }
}
names(gene_bed)<-c('chr','start','end','value1')

pdf(spdf)
circos.clear()
circos.initialize(factors=fa, xlim=matrix(xl,nrow = length(fa),ncol = 2,byrow = T))
circos.genomicLabels(gene_bed,labels.column = 4, side = "outside")
circos.genomicTrackPlotRegion(cnv,ylim = c(0, 1), panel.fun = function(region, value , ...){
  for (i in row.names(region)){
    circos.rect(region[i,'start'],0,region[i,'end'],1,col='red',border=NA)
  }
  
}, bg.border = NA, track.height = 0.1,bg.col='gray')
for (i in 1:length(dm_sv[,1])) {
  circos.link(dm_sv[i,'chr1'],dm_sv[i,'bp1'],dm_sv[i,'chr2'],dm_sv[i,'bp2'],h.ratio=0.8,col='green3')
}
text(0,0,labels=sample_name)
dev.off()
