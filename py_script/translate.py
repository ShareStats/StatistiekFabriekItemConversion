import pandas as pd
import os
from os import path
from pathlib import Path



def get_filelist(folder, ignore_error=False):
    file_list = []
    multiple_rmd = {}
    for (dirpath, _, filenames) in os.walk(folder):
        multiple_rmd[dirpath] = []
        for flname in filenames:
            if flname.lower().endswith(".rmd"):
                file_list.append(path.abspath(path.join(dirpath, flname)))
                multiple_rmd[dirpath].append(flname)
        if len(multiple_rmd[dirpath]) < 2:
            del multiple_rmd[dirpath]

    if len(multiple_rmd) and not ignore_error:
        print("---- Multiple rmd files in one folder:")
        for key, value in multiple_rmd.items():
            print(f"   {key}: {value}")
        print("----")
        raise RuntimeError("Multiple rmd files in one folders (see list above)")
    return file_list



def read_translation_file(filename):

    df =  pd.read_excel(filename)

    rtn = {}
    for i in range(len(df)):
        nl_all = df['Taxonomie'].iloc[i].split(";")
        en_all = df['Taxonomy '].iloc[i].split(";")
        if len(nl_all) != len(en_all):
            # take first english
            for nl in nl_all:
                rtn[nl] = en_all[0]
        else:
            for nl, en in zip(nl_all, en_all):
                rtn[nl] = en

    return rtn

class RmdFile(object):

    def __init__(self, file_path):
        self.file_path = Path(file_path)
        self.content = []

    def parse(self):

        if self.file_path.is_file():
            with open(self.file_path, "r", encoding="utf-8") as fl:
                self.content = fl.readlines()


if __name__ == "__main__":

    transl = read_translation_file("Taxonomie ShareStats Nederlands.xlsx")
    #print(transl)

    for fl in get_filelist("./MultipleChoice"):
        rmd = RmdFile(fl)
        rmd.parse()
        for cnt, txt in enumerate(rmd.content):
            if txt.startswith("exsection:"):
                tag, tmp = txt.split(":")
                labels = [x.strip() for x in tmp.split(",")]
                print(tag)