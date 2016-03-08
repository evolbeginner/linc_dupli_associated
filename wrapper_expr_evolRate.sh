#! /bin/bash


tool_dir=~/project/linc/plant_species/rice/tools
get_methylationLevel=$tool_dir/get_methylationLevel.rb
calculate_correl=calculate_correl.py
obtain_correlList_basedOnPairs=$tool_dir/obtain_correlList_basedOnPairs.rb
get_correl_with_replicates=$tool_dir/get_correl_with_replicates.rb
shared_expr=$tool_dir/shared_expr.rb
methylationLevel_evolRate=$tool_dir/methylationLevel_evolRate.rb 

min_count_each=30
sep="\t"


#############################################################################
while [ $# -gt 0 ]; do
	case $1 in
		--expr_outdir)
			expr_outdir=$2
			shift
			;;
		--prefix)
			prefix=$2
			shift
			;;
		--pair)
			pair_file=$2
			shift
			;;
		--sep)
			sep=$2
			shift
			;;
		--read_infile|--read_infiles)
			read_infile=$2
			shift
			;;
		--evolRate|--evolRate_file|--rate_file|--rate)
			evolRate_file=$2
			shift
			;;
	esac
	shift
done


[ -z $expr_outdir ] && echo "expr_outdir not given. Exiting ......" && exit 1

correl_outdir=$expr_outdir/correl
[ ! -d $correl_outdir ] && mkdir -p $correl_outdir
shared_tissue_outdir=$expr_outdir/shared_tissue
[ ! -d $shared_tissue_outdir ] && mkdir -p $shared_tissue_outdir
rate_outdir=$expr_outdir/rate
[ ! -d $rate_outdir ] && mkdir -p $rate_outdir


#############################################################################
ruby2.1 $get_correl_with_replicates --read_infiles $read_infile --gene_name --pair $pair_file --sep "-" --mode Spearman_correl > $correl_outdir/$prefix.expr_correl

ruby2.1 $get_correl_with_replicates --read_infiles $read_infile --gene_name --pair $pair_file --sep "-" --mode Spearman > $correl_outdir/$prefix.expr_Spearman_distance

ruby2.1 $get_correl_with_replicates --read_infiles $read_infile --gene_name --pair $pair_file --sep "-" --mode Euclidean > $correl_outdir/$prefix.expr_Euclidean_distance

ruby2.1 $shared_expr --read_infiles $read_infile --pair $pair_file --sep "-" --gene_name > $shared_tissue_outdir/$prefix.shared_tissue


if [ ! -z $evolRate_file ]; then
	sort $evolRate_file | join - $correl_outdir/$prefix.expr_Euclidean_distance | sed 's/ /\t/g' > $rate_outdir/$prefix.rate-expr_Euclidean.correl
	sort $evolRate_file | join - $correl_outdir/$prefix.expr_correl | sed 's/ /\t/g' > $rate_outdir/$prefix.rate-expr_correl.correl
fi


