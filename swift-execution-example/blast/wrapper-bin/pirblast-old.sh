#!/fuse/bin/bash

PATH=/fuse/bin:/fuse/usr/bin:$PATH

unset LANG

TMP=`mktemp -d /dev/shm/pir.blast.d.XXXXXX`
cd $TMP

SEQID=$1
SEQUENCE=$2

PIR=/home/espinosa/blast/pir

RANK=`/home/espinosa/bin/rank | awk ' { printf "%0.5d", $0 } ' `
DIR=`expr $RANK / 64 | awk '{printf "%.3d", $0}'`
OUTDIR=$PIR/out/$RANK

DB="$PIR/UNIPROT_for_blast_14.0.seq.00 $PIR/UNIPROT_for_blast_14.0.seq.01 $PIR/UNIPROT_for_blast_14.0.seq.02"

echo ">"${SEQID} >blast.query
echo $SEQUENCE >>blast.query

unset LD_LIBRARY_PATH
if [ ! -d $OUTDIR ]
then
  mkdir -p $OUTDIR
fi
#time /home/wilde/blast/ncbi/bin/blastall -p blastp -F F -d "$DB" -i blast.query -v 300 -b 300 -m8 -o $OUTDIR/$SEQID.out 2>$OUTDIR/$SEQID.err
time /home/espinosa/blast/ncbi/bin/blastall -p blastp -F F -d "$DB" -i blast.query -v 300 -b 300 -m8 -o $OUTDIR/$SEQID.out 2>$OUTDIR/$SEQID.err
