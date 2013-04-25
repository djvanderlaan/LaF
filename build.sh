#!/bin/sh

export package=LaF
export builddir=build

if [ -d $builddir ]
then 
  echo "Removing previous package directory in build directory."
  rm -r -f $builddir/$package
  rm -r -f $builddir/$package.Rcheck
else
  echo "Build directory does not exist. Creating build directory."
  mkdir $builddir
fi

echo "Copying package directory to build directory"
cp -r $package/ $builddir/
cd $builddir
rm -f -r $package/work

echo "Building source package..."
R CMD build $package

# Check last package in directory. 
export sourcepackage=`ls LaF*.tar.gz | tail -n 1`
echo "Testing package $sourcepackage ..."
R CMD check --as-cran $sourcepackage

rm -f *.tar

cd ..

