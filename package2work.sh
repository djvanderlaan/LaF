#!/bin/sh

export package=LaF
export workdir=work

if [ -d $workdir ]
then
  echo "Removing old files from work directory"
  rm -f $workdir/src/*.cpp
  rm -f $workdir/src/*.h
  rm -f $workdir/tmp/*.o
  rm -f $workdir/tmp/*.d
  rm -f $workdir/R/*.R
else
  echo "Work directory does not exist."
  exit 1
fi

echo "Copying C++ source files to work directory"
cp $package/src/* $workdir/src

echo "Copying R scripts to work directory"
cp $package/R/*.R $workdir/R

echo ""
echo "All files have now been copied. You can now do"
echo "  cd ${workdir}"
echo "  make"
echo "to build the library. To load the library and source all R-files"
echo "you can start R and source LaF.R."

