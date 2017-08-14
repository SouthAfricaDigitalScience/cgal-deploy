#!/bin/bash -e
# this should be run after check-build finishes.
. /etc/profile.d/modules.sh
module add deploy
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
echo "All tests have passed, will now build into ${SOFT_DIR}"
rm -rf
cmake ../ -G"Unix Makefiles" \
-DCMAKE_INSTALL_PREFIX=${SOFT_DIR}-gcc-${GCC_VERSION} \
-DWITH_LAPACK=ON \
-DWITH_ZLIB=ON \
-DZLIB_INCLUDE_DIR=${ZLIB_DIR}/include \
-DZLIB_LIBRARY_RELEASE=${ZLIB_DIR}/lib/libz.so

make install
echo "Creating the modules file directory ${LIBRARIES}"
mkdir -p ${LIBRARIES}/${NAME}
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION : See https://github.com/SouthAfricaDigitalScience/CGAL-deploy"
setenv CGAL_VERSION       $VERSION
setenv CGAL_DIR           $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION-gcc-${GCC_VERSION}
prepend-path LD_LIBRARY_PATH   $::env(CGAL_DIR)/lib
setenv CFLAGS            "-I$::env(CGAL_DIR)/include $CPPFLAGS"
setenv LDFLAGS           "-L$::env(CGAL_DIR)/lib ${LDFLAGS}"
MODULE_FILE
) > ${LIBRARIES}/${NAME}/${VERSION}
