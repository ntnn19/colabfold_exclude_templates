import os
import pandas as pd

def get_wildcards(path):
    df = pd.read_csv(path)
    return df["id"].tolist()

MULTIMERS = config["input_csv"]
TEMPLATES_TO_EXCLUDE = config["templates_to_exclude"]
CONTAINER = config["container"]
OUTDIR = config["output_dir"]

MULTIMERS_WC = get_wildcards(MULTIMERS)

#CONTAINER = "../../singularity_containers/colabfold/colabfold_1.5.9-cuda12.2.2_parallel_fix_2bec5c7_relax_merged_to_latest.sif" 

rule all:
    input:
        expand(os.path.join(OUTDIR,"predictions","COLABFOLD_BATCH_TEMPLATE_BASED_MULTIMERS","{q}","{q}.done.txt"),q=MULTIMERS_WC),



rule COLABFOLD_SEARCH_TEMPLATE_BASED_MULTIMERS:
    input:
        MULTIMERS
    output:
        expand(os.path.join(OUTDIR,"predictions","COLABFOLD_SEARCH_TEMPLATE_BASED_MULTIMERS","{q}.a3m"),q=MULTIMERS_WC),
    container:
        CONTAINER
    shell:
        """
        colabfold_search --mmseqs /usr/local/envs/colabfold/bin/mmseqs {input} /database /predictions/COLABFOLD_SEARCH_TEMPLATE_BASED_MULTIMERS --use-templates 1 --db2 pdb100_230517 --use-env 1
        """



rule CREATE_SUBDIRS_AND_COPY_FILES_MULTIMERS:
    input:
        os.path.join(OUTDIR,"predictions","COLABFOLD_SEARCH_TEMPLATE_BASED_MULTIMERS","{q}.a3m")
    output:
         os.path.join(OUTDIR,"predictions","COLABFOLD_SEARCH_TEMPLATE_BASED_MULTIMERS","{q}","{q}.a3m")
    shell:
        """
        python create_compatible_dir_structure.py {wildcards.q} output/predictions/COLABFOLD_SEARCH_TEMPLATE_BASED_MULTIMERS --use-templates
        """


rule FILTER_OUT_TEMPLATES:
    input:
        os.path.join(OUTDIR,"predictions","COLABFOLD_SEARCH_TEMPLATE_BASED_MULTIMERS","{q}","{q}_pdb100_230517.m8")
    output:
        os.path.join(OUTDIR,"predictions","COLABFOLD_BATCH_TEMPLATE_BASED_MULTIMERS","{q}","{q}_pdb100_230517_filtered.m8")
    params:
        templates_to_exclude = TEMPLATES_TO_EXCLUDE
    shell:
        """
        grep -vFf <(tr ',' '\n' < {params.templates_to_exclude}) {input} > {output} 
        """

rule COLABFOLD_BATCH_TEMPLATE_BASED_MULTIMERS:
    input:
        a3m = os.path.join(OUTDIR,"predictions","COLABFOLD_SEARCH_TEMPLATE_BASED_MULTIMERS","{q}","{q}.a3m"),
        m8 = os.path.join(OUTDIR,"predictions","COLABFOLD_BATCH_TEMPLATE_BASED_MULTIMERS","{q}","{q}_pdb100_230517_filtered.m8")
    output:
        os.path.join(OUTDIR,"predictions","COLABFOLD_BATCH_TEMPLATE_BASED_MULTIMERS","{q}","{q}.done.txt")
    container:
        CONTAINER
    shell:
        """
        colabfold_batch /predictions/COLABFOLD_SEARCH_TEMPLATE_BASED_MULTIMERS/{wildcards.q}/{wildcards.q}.a3m /predictions/COLABFOLD_BATCH_TEMPLATE_BASED_MULTIMERS/{wildcards.q} --templates --pdb-hit-file /predictions/COLABFOLD_SEARCH_TEMPLATE_BASED_MULTIMERS/{wildcards.q}/{wildcards.q}_pdb100_230517_filtered.m8 --local-pdb-path /mmcif_dir
        """

