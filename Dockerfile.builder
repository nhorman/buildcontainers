FROM fedora:38

ENV TARCH="arm64"
ENV TARGET="aarch64-linux-gnu"
ENV PRETARGET="aarch64-elf"
ENV HOST="x86_64-pc-linux-gnu"
ENV PREFIX="/opt"
ENV PATH="$PREFIX/bin:$PATH"

RUN dnf install -y glibc-devel.i686 rsync diffutils git-core gcc gcc-c++ make bison flex gmp-devel libmpc-devel mpfr-devel texinfo cloog-devel isl-devel

#build binutils and gdb
RUN git clone git://sourceware.org/git/binutils-gdb.git && \
cd binutils-gdb && git checkout binutils-2_41-release && \
./configure --host=$HOST --target=$PRETARGET --prefix=$PREFIX --with-sysroot --disable-nls --disable-werror && \
make && make install && cd .. && rm -rf binutils-gdb

#install kernel headers
RUN git clone git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git && cd linux && \
make ARCH=$TARCH INSTALL_HDR_PATH=$PREFIX/$TARGET headers_install && cd .. && rm -rf linux 

#install needed headers into cross arch sysroot
RUN cd $PREFIX/$TARGET/include && sh -c "for i in unistd.h sched.h pthread.h features-time64.h features.h stdc-predef.h time.h; do ln -s /usr/include/\$i .; done;"
RUN cd $PREFIX/$TARGET/include && sh -c "ln -s /usr/include/gnu ."
RUN cd $PREFIX/$TARGET/include  && sh -c "ln -s /usr/include/bits ."
RUN cd $PREFIX/$TARGET/include && sh -c "ln -s /usr/include/sys ."

#build gcc
RUN git clone git://gcc.gnu.org/git/gcc.git && \
cd gcc && git checkout releases/gcc-13.2.0 && mkdir gcc-build && cd gcc-build && \
../configure --host=$HOST --target=$PRETARGET --prefix=$PREFIX --disable-multilib --disable-nls --enable-languages=c,c++ --without-headers && \
make all-gcc && make all-target-libgcc && make install-gcc && make install-target-libgcc && \
cd .. && rm -rf gcc




