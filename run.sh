input_dir=$1
output_dir=$2
weights_dir=$3
database_dir=$4
mmcif_dir=$5
mkdir -p $output_dir/predictions
snakemake -p --workflow-profile profile -s luca.smk --configfile config/config.yaml --use-singularity --singularity-args "--nv -B $(realpath $database_dir):/database -B $(realpath $input_dir):/input -B $(realpath $output_dir)/predictions:/predictions  -B $(realpath $weights_dir):/cache -B $(realpath $mmcif_dir):/mmcif_dir" -j 1
