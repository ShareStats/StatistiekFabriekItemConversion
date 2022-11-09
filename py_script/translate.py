"""Script translates file:

usage: option "--no-dryrun" to apply changes

(c) O. Lindemann
"""

import json
import os
import sys
from os import path
from pathlib import Path

import chardet
import pandas as pd


def get_filelist(folder, ignore_error=False):
    file_list = []
    multiple_rmd = {}
    for (dirpath, _, filenames) in os.walk(folder):
        multiple_rmd[dirpath] = []
        for flname in filenames:
            if flname.lower().endswith(".rmd"):
                file_list.append(path.join(dirpath, flname))
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
                rtn[nl.strip().lower()] = en_all[0].strip()
        else:
            for nl, en in zip(nl_all, en_all):
                rtn[nl.strip().lower()] = en.strip()

    return rtn

class RmdFile(object):

    def __init__(self, file_path):
        self.file_path = Path(file_path)
        self.content = []

        if self.file_path.is_file():
            with open(self.file_path, "rb") as fl:
                result = chardet.detect(fl.read())
            self.guess_encoding = result['encoding']
            self.encoding_confidence = result['confidence']
        else:
            self.guess_encoding = None
            self.encoding_confidence = None

    def parse(self, encoding="utf-8"):
        self.content = []
        if self.file_path.is_file():
            with open(self.file_path, "r", encoding=encoding) as fl:
                self.content = fl.readlines()

    def save(self):
        with open(self.file_path, "w", encoding="utf-8") as fl:
            fl.writelines(self.content)

if __name__ == "__main__":

    try:
        dryrun = sys.argv[1] != "--no-dryrun"
    except:
        dryrun = True

    item_folder = "./MultipleChoice"
    transl = read_translation_file("Taxonomie ShareStats Nederlands.xlsx")
    #print(transl)
    log = open("translate_log.md", "w", encoding="utf-8")


    unknown_sections = set()
    for fl in get_filelist(item_folder):

        rmd = RmdFile(fl)
        if rmd.guess_encoding == "ascii":
            rmd.parse(encoding="utf-8")
        else:
            rmd.parse(encoding=rmd.guess_encoding)

        for cnt, txt in enumerate(rmd.content):

            if txt.startswith("exsection:"):
                #get exsections
                sections = []
                issues = []
                tmp = txt.split(":")
                if len(tmp) >1:
                    sections = [x.strip() for x in tmp[1].split(",")]

                if len(sections):
                   # translate sections
                    transl_sections = []
                    for sec in sections:
                        if sec.lower() in transl:
                            transl_sections.append(transl[sec.lower()])
                        else:
                            transl_sections.append(sec)
                            if sec not in transl.values():
                                issues.append(f"unknown: '{sec}'")
                                unknown_sections.add(sec)

                else:
                    issues.append("No exsections defined")

                #feedback
                if len(issues):
                    log.write(f"* {fl}\n")
                    for iss in issues:
                        log.write(f"   - {iss}\n")

                rmd.content[cnt] = "exsection: " + "/".join(transl_sections)
                if not dryrun:
                    rmd.save()

    log.write("\n\n# Summary:\n")
    log.write(json.dumps({"unknown_sections": list(unknown_sections)}, indent=2))
    log.write(json.dumps({"all_known_sections": list(transl.keys())}, indent=2))
    log.close()