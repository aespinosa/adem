type file;
type DockIn;
type DockOut;

(file t,DockOut tarout) dockcompute (DockIn infile, string targetlist) {
  app {
    rundock @infile targetlist stdout=@filename(t) @tarout;
    }
}

type params {
      string  ligandsfile;
      string  targetlist;
}

#params pset[] <csv_mapper;file="paramslist.txt">;
doall(params pset[])
{
  foreach params,i in pset {
  DockIn infile < single_file_mapper; file=@strcat("/disks/tp-gpfs/scratch/houzx/dock-run/databases/KEGG_and_Drugs/",pset[i].ligandsfile)>;
  file sout <single_file_mapper; file=@strcat("/disks/tp-gpfs/scratch/houzx/dock-run/databases/results/stdout/",pset[i].targetlist,"-",i,"-stdout.txt")>; 
  DockOut tout <single_file_mapper; file=@strcat(pset[i].ligandsfile,"-result.tar.gz")>;
#  DockOut tout <"result.tar.gz">;
#  sout =  dockcompute(infile,pset[i].targetlist);
  (sout,tout) =  dockcompute(infile,pset[i].targetlist); 

 }
}

params p[];
p = readdata("paramslist.txt");
doall(p);

