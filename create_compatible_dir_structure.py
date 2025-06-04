import os
import shutil
import click
@click.command()
@click.argument('protein_id', type=str, nargs=-1, required=True)
@click.argument('msa_dir', type=click.Path(), required=True)
@click.option('--use-templates', is_flag=True)
@click.option('--suffix', type=str,default='_pdb100_230517')
def main(protein_id,msa_dir,use_templates,suffix):
    for prot_id in protein_id:
        os.makedirs(os.path.join(msa_dir,prot_id), exist_ok=True)
        shutil.copy2(os.path.join(msa_dir,prot_id+".a3m"), os.path.join(msa_dir,prot_id,prot_id+".a3m"))
        if use_templates:
            shutil.copy2(os.path.join(msa_dir,prot_id+f"{suffix}.m8"), os.path.join(msa_dir,prot_id,prot_id+f"{suffix}.m8"))



if __name__ == '__main__':
    main()
