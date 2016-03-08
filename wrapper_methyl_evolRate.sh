#! /bin/env bash


tool_dir=~/project/linc/plant_species/rice/tools
get_methylationLevel=$tool_dir/get_methylationLevel.rb
calculate_correl=calculate_correl.py
obtain_correlList_basedOnPairs=$tool_dir/obtain_correlList_basedOnPairs.rb
get_correl_with_replicates=$tool_dir/get_correl_with_replicates.rb
shared_expr=$tool_dir/shared_expr.rb

min_count_each=30
sep="\t"


##################################################################
while [ $# -gt 0 ]; do
	case $1 in
		--pair)
			pair_file=$2
			shift
			;;
		--sep)
			sep=$2
			shift
			;;
		--DNA_methyl_result_dir)
			DNA_methyl_result_dir=$2
			shift
			;;
		--cufflinks)
			#for i in `perl -lne '@a=split(","); print "@a\n";' <<< $2`; do
			#	cufflinks_infiles=(${cufflinks_infiles[@]} $i)
			#done
			cufflinks_infiles=$2
			shift
			;;
		--methyl_level_output)
			methyl_level_output=$2
			shift
			;;
		--outdir)
			outdir=$2
			shift
			;;
		--force)
			is_force=1
			;;
		--no_get_methyl_level|--no_methyl_level)
			is_no_methyl_level=1
			;;
	esac
	shift
done


[ -z $outdir ] && echo "outdir not given. Exiting ......" && exit 1

if [ ! -z $is_force ]; then
	[ -d $outdir ] && rm -rf $outdir
fi

if [ ! -d $outdir ]; then
	mkdir -p $outdir
fi


##################################################################
[ -z $methyl_level_output ] && methyl_level_output=$outdir/all.each$min_count_each.methyl_level
methylLevel_exprFold_list=$outdir/"methylLevel-exprFold.list"
methyl_comparison_outdir=$outdir/methyl_comparison
mkdir -p $methyl_comparison_outdir


##################################################################
if [ -z $is_no_methyl_level ] ; then
	cd $DNA_methyl_result_dir > /dev/null
	ruby2.1 $get_methylationLevel --intersect nega.bed_intersect --intersect posi.bed_intersect --final_result $final_result --min_count_each $min_count_each > $methyl_level_output
	cd - > /dev/null
fi


ruby $obtain_correlList_basedOnPairs --i1 $methyl_level_output --i2 $cufflinks_infiles --f2 10 --pair $pair_file --sep $sep --fold 2 > $methylLevel_exprFold_list


$calculate_correl -i $methylLevel_exprFold_list -f 2,3
awk '{if($3<2){print $2}}' $methylLevel_exprFold_list > $methyl_comparison_outdir/0-2
awk '{if($3>=2){print $2}}' $methylLevel_exprFold_list > $methyl_comparison_outdir/2+
awk '{if($3<4){print $2}}' $methylLevel_exprFold_list > $methyl_comparison_outdir/0-4
awk '{if($3>=4){print $2}}' $methylLevel_exprFold_list > $methyl_comparison_outdir/4+


