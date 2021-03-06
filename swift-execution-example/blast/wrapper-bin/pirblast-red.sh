#!/bin/bash

PATH=/fuse/bin:/fuse/usr/bin:$PATH

unset LANG

#TMP=`mktemp -d /dev/shm/pir.blast.d.XXXXXX`
TMP=`pwd`
cd $TMP

SEQID=$1
SEQUENCE=$2

PIR=/opt/osg/data/osg/houzx/pir
blastapp=/opt/osg/app/osg/houzx/work-pac/blast-2.2.10/bin/blastall

OUTDIR=/tmp/out

DB="$PIR/UNIPROT_for_blast_14.0.seq.00 $PIR/UNIPROT_for_blast_14.0.seq.01 $PIR/UNIPROT_for_blast_14.0.seq.02"

echo ">"${SEQID} >blast.query
echo $SEQUENCE >>blast.query

unset LD_LIBRARY_PATH
if [ ! -d $OUTDIR ]
then
  mkdir -p $OUTDIR
fi
time $blastapp -p blastp -F F -d "$DB" -i blast.query -v 300 -b 300 -m8 -o $OUTDIR/$SEQID.out 2>$OUTDIR/$SEQID.err

cd $OUTDIR
tar zcf result.tar.gz *
/bin/mv result.tar.gz $TMP/$SEQID-result.tar.gz
/bin/rm -rf $OUTDIR
