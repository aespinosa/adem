type database;
type query;
type output;
type error;

(output out, error err) blastall(query i, database db) {
  app {
    blastall "-p" "blastp" "-F" "F" "-d" @filename(db) "-i"
@filename(i) "-v" "300" "-b" "300" "-m8" "-o" @filename(out)
stderr=@filename(err);
  }
}

database pir <simple_mapper;prefix="/disks/ci-gpfs/swift/blast/pir/UNIPROT_for_blast_14.0.seq">;
output out <"test.out">;
query i <"test.in">;
error err <"test.err">;
(out,err) = blastall(i, pir);
