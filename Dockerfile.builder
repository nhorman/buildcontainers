FROM fedora:38

ENV TARCH="arm64"
ENV TARGET="aarch64-linux"
ENV HOST="x86_64-pc-linux-gnu"
ENV PREFIX="/opt"
ENV PATH="$PREFIX/bin:$PATH"

RUN dnf install -y libxcrypt-devel xz bzip2 wget mercurial glibc-devel.i686 rsync diffutils git-core gcc gcc-c++ make bison flex gmp-devel libmpc-devel mpfr-devel texinfo cloog-devel isl-devel

RUN mkdir /stage

#build binutils and gdb
RUN cd /stage && \
git clone git://sourceware.org/git/binutils-gdb.git && \
cd binutils-gdb && git checkout binutils-2_41-release && \
./configure --host=$HOST --target=$TARGET --prefix=$PREFIX --disable-nls --disable-werror --disable-multilib && \
make -j && make install && cd .. 

#install kernel headers
RUN cd /stage && \
git clone git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git && cd linux && \
make ARCH=$TARCH INSTALL_HDR_PATH=$PREFIX/$TARGET headers_install 

#build gcc
RUN cd /stage && git clone git://gcc.gnu.org/git/gcc.git && \
cd gcc && git checkout releases/gcc-13.2.0 && \
git clone https://gitlab.inria.fr/mpfr/mpfr.git mpfr && cd mpfr && git checkout 4.2.0 && cd .. && \
hg clone https://gmplib.org/repo/gmp/ gmp && cd gmp && hg up gmp-6.1.0 && cd .. && \ 
git clone https://gitlab.inria.fr/mpc/mpc.git mpc && cd mpc && git checkout 1.3.1 && cd .. && \
git clone https://repo.or.cz/isl.git isl && cd isl && git checkout isl-0.26 && cd .. && \
git clone git://repo.or.cz/cloog.git cloog && cd cloog && git checkout cloog-0.18.4 && cd .. && \
mkdir gcc-build && cd gcc-build && \
../configure --disable-threads --target=$TARGET --prefix=$PREFIX --disable-multilib --disable-nls --enable-languages=c,c++ && \
make -j all-gcc && make -j install-gcc

#build glibc stubs
RUN cd /stage && \
git clone https://sourceware.org/git/glibc.git && cd glibc && git checkout glibc-2.38 && \
mkdir build && cd build && \
../configure --prefix=$PREFIX/$TARGET --build=$MACHTYPE --host=$TARGET --target=$TARGET --with-headers=$PREFIX/$TARGET/include --disable-multilib libc_cv_forced_unwind=yes && \
make install-bootstrap-headers=yes install-headers && \
make -j csu/subdir_lib && \
mkdir -p $PREFIX/$TARGET/lib && \
install csu/crt1.o csu/crti.o csu/crtn.o $PREFIX/$TARGET/lib && \
$TARGET-gcc -nostdlib -nostartfiles -shared -x c /dev/null -o $PREFIX/$TARGET/lib/libc.so && \
mkdir -p $PREFIX/$TARGET/include/gnu && \
touch $PREFIX/$TARGET/include/gnu/stubs.h

#rebuild gcc with libgcc
RUN cd /stage/gcc/gcc-build && \
make -j all-gcc && make -j install-gcc

RUN cd /stage/gcc/gcc-build && \
rm -rf * && \
../configure --includedir=$PREFIX/$TARGET/include --target=$TARGET --prefix=$PREFIX --disable-multilib --disable-nls --enable-languages=c,c++ && \
cd /stage/gcc/gcc-build && \
make all-target-libgcc && \
make install-target-libgcc

#
#finish glibc
RUN cd /stage/glibc/build && \
make -j && \
make install 

#build gcc one more time to get a working compiler for applications 
RUN cd /stage/gcc/gcc-build && \
rm -rf * && \
../configure --includedir=$PREFIX/$TARGET/include --target=$TARGET --prefix=$PREFIX --disable-multilib --disable-nls --enable-languages=c,c++ && \
mkdir -p /stage/gcc/gcc-build/gcc/../lib/gcc/aarch64-linux/13.2.0/ && \
cd /stage/gcc/gcc-build/gcc/../lib/gcc/aarch64-linux/13.2.0/ && \
ln -s /usr/include . && \
cd /stage/gcc/gcc-build && \
make && \
make install

#clean up
RUN rm -rf /stage 
RUN dnf clean all





