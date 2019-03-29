#!/usr/bin/env ruby

term2so = Hash[*[
  "3prime_overlapping_ncrna", "",
  "antisense", "",
  "bidirectional_promoter_lncrna", "",
  "IG_C_gene", "",
  "IG_C_pseudogene", "",
  "IG_D_gene", "SO_0000510",
  "IG_J_gene", "",
  "IG_J_pseudogene", "",
  "IG_V_gene", "",
  "IG_V_pseudogene", "",
  "lincRNA", "SO_0001641",
  "LRG_gene", "",
  "macro_lncRNA", "",
  "miRNA", "SO_0001265",
  "misc_RNA", "SO_0000356",
  "Mt_rRNA", "",
  "Mt_tRNA", "SO_0000088",
  "non_coding", "",
  "nonsense_mediated_decay", "SO_0001621",
  "non_stop_decay", "",
  "polymorphic_pseudogene", "SO_0000336",
  "processed_pseudogene", "",
  "processed_transcript", "SO_0001503",
  "protein", "",
  "protein_coding", "SO_0001217",
  "pseudogene", "SO_0000336",
  "retained_intron", "SO_0000681",
  "ribozyme", "",
  "rRNA", "SO_0001637",
  "scaRNA", "",
  "sense_intronic", "",
  "sense_overlapping", "",
  "snoRNA", "SO_0001267",
  "snRNA", "SO_0001268",
  "sRNA", "",
  "TEC", "",
  "transcribed_processed_pseudogene", "",
  "transcribed_unitary_pseudogene", "",
  "transcribed_unprocessed_pseudogene", "",
  "translated_unprocessed_pseudogene", "",
  "TR_C_gene", "SO_0000478",
  "TR_D_gene", "",
  "TR_J_gene", "SO_0000470",
  "TR_J_pseudogene", "",
  "TR_V_gene", "SO_0000466",
  "TR_V_pseudogene", "",
  "unitary_pseudogene", "",
  "unprocessed_pseudogene", "",
  "vaultRNA", "" ]]


print "@prefix m2r: <http://med2rdf.org/ontology/med2rdf#> .\n"
print "@prefix cvo: <http://purl.jp/bio/10/clinvar/> .\n"
print "@prefix faldo: <http://biohackathon.org/resource/faldo#> .\n"
print "@prefix ens: <http://rdf.ebi.ac.uk/resource/ensembl/> .\n"
print "@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .\n"
print "@prefix dcterms: <http://purl.org/dc/terms/> .\n"
print "@prefix hco: <http://identifiers.org/hco/> .\n"
print "@prefix ensgido: <http://identifiers.org/ensembl/> .\n"
print "@prefix exon: <http://rdf.ebi.ac.uk/resource/ensembl.exon/> .\n"
print "@prefix transcript: <http://rdf.ebi.ac.uk/resource/ensembl.transcript/> .\n"
print "@prefix term: <http://rdf.ebi.ac.uk/terms/ensembl/> .\n"
print "@prefix identifiers: <http://identifiers.org/> .\n"
print "@prefix obo: <http://purl.obolibrary.org/obo/> .\n"
print "@prefix so: <http://purl.obolibrary.org/obo/so#> .\n"
print "@prefix sio: <http://semanticscience.org/resource/> .\n"
print "\n"

ENST = "http://rdf.ebi.ac.uk/resource/ensembl.transcript/"

f_genes = open(ARGV.shift) # genes
f_exons = open(ARGV.shift) # structures
keys = f_genes.gets.chomp.split("\t", -1).map{|e| e.gsub("(", "").gsub(")","").gsub("/", " ").gsub(" ", "_").downcase}
exon_keys = f_exons.gets.chomp.split("\t", -1).map{|e| e.gsub("(", "").gsub(")","").gsub("/", " ").gsub(" ", "_").downcase}

gene_hash = {}
gene2transcripts = {}
transcript_hash = {}

while line = f_genes.gets
  vals = line.chomp.split("\t", -1)
  h = Hash[[keys, vals].transpose]
  unless gene_hash.key?(h["gene_stable_id"])
    gene_hash[h["gene_stable_id"]] = [h["gene_name"],
                                      h["gene_type"],
                                      h["gene_description"],
                                      h["chromosome_scaffold_name"],
                                      h["gene_start_bp"].to_i,
                                      h["gene_end_bp"].to_i,
                                      h["strand"].to_i,
                                      h["protein_stable_id"],
                                      h["hgnc_id"]]
  end
  unless gene2transcripts.key?(h["gene_stable_id"])
    gene2transcripts[h["gene_stable_id"]] = [h["transcript_stable_id"]]
  else
    gene2transcripts[h["gene_stable_id"]] << h["transcript_stable_id"]
  end
  unless transcript_hash.key?(h["transcript_stable_id"])
    transcript_hash[h["transcript_stable_id"]] = [[h["exon_stable_id"]],
                                                  h["chromosome_scaffold_name"],
                                                  h["transcript_start_bp"].to_i,
                                                  h["transcript_end_bp"].to_i,
                                                  h["strand"].to_i]
  else
    transcript_hash[h["transcript_stable_id"]][0] << h["exon_stable_id"]
  end
end

exon_hash = {}

while line = f_exons.gets
  vals = line.chomp.split("\t", -1)
  h = Hash[[exon_keys, vals].transpose]
  unless exon_hash.key?(h["transcript_stable_id"])
    exon_hash[h["transcript_stable_id"]] = [[h["exon_stable_id"],
                                             h["exon_region_start_bp"].to_i,
                                             h["exon_region_end_bp"].to_i,
                                             h["exon_rank_in_transcript"].to_i]]
  else
    exon_hash[h["transcript_stable_id"]] << [h["exon_stable_id"],
                                             h["exon_region_start_bp"].to_i,
                                             h["exon_region_end_bp"].to_i,
                                             h["exon_rank_in_transcript"].to_i]

  end
end


gene_hash.keys.each do |gene_id|
  print "ens:#{gene_id} a term:#{gene_hash[gene_id][1]} ;\n"
  print "    a obo:#{term2so[gene_hash[gene_id][1]]} ;\n" unless term2so[gene_hash[gene_id][1]] == ""
  print "    rdfs:label \"#{gene_hash[gene_id][0]}\" ;\n"
  print "    dcterms:identifier \"#{gene_id}\" ;\n"
  print "    rdfs:seeAlso <http://identifiers.org/ensembl/#{gene_id}> ;\n"
  print "    faldo:location [\n"
  print "        a faldo:Region ;\n"
  print "        faldo:begin [\n"
  print "            a faldo:ExactPosition ;\n"
  if gene_hash[gene_id][6] == 1
  print "            a faldo:ForwardStrandPosition ;\n"
  else
  print "            a faldo:ReverseStrandPosition ;\n"
  end
  print "            faldo:position #{gene_hash[gene_id][4]} ;\n"
  print "            faldo:reference hco:#{gene_hash[gene_id][3]}\#GRCh37\n"
  print "        ] ;\n"
  print "        faldo:end [\n"
  print "            a faldo:ExactPosition ;\n"
  if gene_hash[gene_id][6] == 1
  print "            a faldo:ForwardStrandPosition ;\n"
  else
  print "            a faldo:ReverseStrandPosition ;\n"
  end
  print "            faldo:position #{gene_hash[gene_id][5]} ;\n"
  print "            faldo:reference hco:#{gene_hash[gene_id][3]}\#GRCh37\n"
  print "        ]\n"
  print "    ] .\n"
  print "\n"
  gene2transcripts[gene_id].each do |transcript_id|
    print "transcript:#{transcript_id} a term:#{gene_hash[gene_id][1]} ;\n"
    print "    a ens:#{term2so[gene_hash[gene_id][1]]} ;\n" unless term2so[gene_hash[gene_id][1]] == ""
    print "    dcterms:identifier \"#{transcript_id}\" ;\n"
    print "    so:part_of ens:#{gene_id} ;\n"
    print "    so:transcribed_from ens:#{gene_id} ;\n"
    print "    faldo:location [\n"
    print "        a faldo:Region ;\n"
    print "        faldo:begin [\n"
    print "            a faldo:ExactPosition ;\n"
    if gene_hash[gene_id][6] == 1
    print "            a faldo:ForwardStrandPosition ;\n"
    else
    print "            a faldo:ReverseStrandPosition ;\n"
    end
    print "            faldo:position #{transcript_hash[transcript_id][2]} ;\n"
    print "            faldo:reference hco:#{gene_hash[gene_id][3]}\\#GRCh37\n"
    print "        ] ;\n"
    print "        faldo:end [\n"
    print "            a faldo:ExactPosition ;\n"
    if gene_hash[gene_id][6] == 1
    print "            a faldo:ForwardStrandPosition ;\n"
    else
    print "            a faldo:ReverseStrandPosition ;\n"
    end
    print "            faldo:position #{transcript_hash[transcript_id][3]} ;\n"
    print "            faldo:reference hco:#{gene_hash[gene_id][3]}\\#GRCh37\n"
    print "        ]\n"
    print "    ] .\n"
    print "\n"
    exon_hash[transcript_id].each do |exon|
      print "transcript:#{transcript_id} so:has_part exon:#{exon[0]} .\n"
      print "transcript:#{transcript_id} sio:SIO_000974 <#{ENST}#{transcript_id}#Exon_#{exon[3]}> .\n"
      print "<#{ENST}#{transcript_id}#Exon_#{exon[3]}> a sio:SIO_001261 ;\n"
      print "    sio:SIO_000628 exon:#{exon[0]} ;\n"
      print "    sio:SIO_000300 #{exon[3]} .\n"
      print "exon:#{exon[0]} a obo:SO_0000147 ;\n" # so:exon
      print "    rdfs:label \"#{exon[0]}\" ;\n"
      print "    dcterms:identifiers \"#{exon[0]}\" ;\n"
      print "    so:part_of transcript:#{transcript_id} ;\n"
      print "    faldo:location [\n"
      print "        a faldo:Region ;\n"
      print "        faldo:begin [\n"
      print "            a faldo:ExactPosition ;\n"
      if gene_hash[gene_id][6] == 1
      print "            a faldo:ForwardStrandPosition ;\n"
      else
      print "            a faldo:ReverseStrandPosition ;\n"
      end
      print "            faldo:position #{exon[1]} ;\n"
      print "            faldo:reference hco:#{gene_hash[gene_id][3]}\\#GRCh37\n"
      print "        ] ;\n"
      print "        faldo:end [\n"
      print "            a faldo:ExactPosition ;\n"
      if gene_hash[gene_id][6] == 1
      print "            a faldo:ForwardStrandPosition ;\n"
      else
      print "            a faldo:ReverseStrandPosition ;\n"
      end
      print "            faldo:position #{exon[2]} ;\n"
      print "            faldo:reference hco:#{gene_hash[gene_id][3]}\\#GRCh37\n"
      print "        ] \n"
      print "    ] .\n"
      print "\n"
    end
  end
  print "<http://identifiers.org/ensembl/#{gene_id}> a identifiers:ensembl .\n"
  print "\n"
end