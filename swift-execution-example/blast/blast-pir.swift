type file;
type BlastOut;

(BlastOut tarout) blastcompute (string seqid, string infile) {
  app {
    pirblast seqid infile @tarout;
    }
}

type params {
      string  seqid;
      string  seqfile;
}

doall(params pset[])
{
  foreach params,i in pset {
  
  BlastOut tout <single_file_mapper; file=@strcat(pset[i].seqid,"-result.tar.gz")>;
  
  (tout) =  blastcompute(pset[i].seqid,pset[i].seqfile); 

 }
}

params p[];
p = readData("seqlist-500k.txt");
doall(p);
