#!/usr/bin/env bash
cd source_ExampleCode
GEN_DIR=LLVMBackendTutorialExampleCode
rm -rf 3 4 5 6 7 8 9
rm -rf ${GEN_DIR}
mkdir ${GEN_DIR}
mkdir ${GEN_DIR}/3
mkdir ${GEN_DIR}/4
mkdir ${GEN_DIR}/6
mkdir ${GEN_DIR}/7
mkdir ${GEN_DIR}/8
mkdir ${GEN_DIR}/9
cp -rf 2 ${GEN_DIR}/.
patch -fp0 < 3-1.patch
mkdir 3
mv 2 3/1
cp -rf 3/1 ${GEN_DIR}/3/.
patch -fp0 < 3-2.patch
mv 3/1 3/2
cp -rf 3/2 ${GEN_DIR}/3/.
patch -fp0 < 3-3.patch
mv 3/2 3/3
cp -rf 3/3 ${GEN_DIR}/3/.
patch -fp0 < 3-4.patch
mv 3/3 3/4
cp -rf 3/4 ${GEN_DIR}/3/.
patch -fp0 < 3-5.patch
mv 3/4 3/5
cp -rf 3/5 ${GEN_DIR}/3/.
patch -fp0 < 4-1.patch
mkdir 4
mv 3/5 4/1
cp -rf 4/1 ${GEN_DIR}/4/.
patch -fp0 < 4-2.patch
mv 4/1 4/2
cp -rf 4/2 ${GEN_DIR}/4/.
patch -fp0 < 4-4.patch
mv 4/2 4/4
cp -rf 4/4 ${GEN_DIR}/4/.
patch -fp0 < 4-4_2.patch
mv 4/4 4/4_2
cp -rf 4/4_2 ${GEN_DIR}/4/.
patch -fp0 < 4-5.patch
mv 4/4_2 4/5
cp -rf 4/5 ${GEN_DIR}/4/.
patch -fp0 < 4-6_1.patch
mv 4/5 4/6_1
cp -rf 4/6_1 ${GEN_DIR}/4/.
patch -fp0 < 4-6_2.patch
mv 4/6_1 4/6_2
cp -rf 4/6_2 ${GEN_DIR}/4/.
patch -fp0 < 4-6_4.patch
mv 4/6_2 4/6_4
cp -rf 4/6_4 ${GEN_DIR}/4/.
patch -fp0 < 5.patch
mv 4/6_4 5
cp -rf 5 ${GEN_DIR}/.
patch -fp0 < 6-1.patch
mkdir 6
mv 5 6/1
cp -rf 6/1 ${GEN_DIR}/6/.
patch -fp0 < 6-2.patch
mv 6/1 6/2
cp -rf 6/2 ${GEN_DIR}/6/.
patch -fp0 < 7-1.patch
mkdir 7
mv 6/2 7/1
cp -rf 7/1 ${GEN_DIR}/7/.
patch -fp0 < 8-2.patch
mkdir 8
mv 7/1 8/2
cp -rf 8/2 ${GEN_DIR}/8/.
patch -fp0 < 8-3.patch
mv 8/2 8/3
cp -rf 8/3 ${GEN_DIR}/8/.
patch -fp0 < 8-4.patch
mv 8/3 8/4
cp -rf 8/4 ${GEN_DIR}/8/.
patch -fp0 < 8-5.patch
mv 8/4 8/5
cp -rf 8/5 ${GEN_DIR}/8/.
patch -fp0 < 8-6.patch
mv 8/5 8/6
cp -rf 8/6 ${GEN_DIR}/8/.
patch -fp0 < 8-7.patch
mv 8/6 8/7
cp -rf 8/7 ${GEN_DIR}/8/.
patch -fp0 < 9-1.patch
mkdir 9
mv 8/7 9/1
cp -rf 9/1 ${GEN_DIR}/9/.
cp -rf ${GEN_DIR}/2 .
rm -rf 3 4 6 7 8 9
cp -rf InputFiles src_files_modify ${GEN_DIR}/.
cp -rf InputFiles 3.2_src_files_modify ${GEN_DIR}/.
mv ${GEN_DIR} ../.
rm -f `find . -name .DS_Store`
cd ..


