两个参数
    --with-abi=64   \
    --with-endlan=little

###1-binutils
../configure --prefix=/tools            \
             --with-sysroot=$LFS        \
             --with-lib-path=/tools/lib \
             --target=$LFS_TGT          \
             --disable-nls              \
             --disable-werror \
    --with-abi=64   \
    --with-endlan=little
###
case $(uname -m) in
  mips64) mkdir -v /tools/lib && ln -sv lib /tools/lib64 ;;
esac

###1-gcc
for file in gcc/config/{linux,mips/linux{,64}}.h
do
  cp -uv $file{,.orig}
  sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
      -e 's@/usr@/tools@g' $file.orig > $file
  echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
  touch $file.orig
done
###
case $(uname -m) in
  mips64)
    sed -e 's/lib64/lib/g' \
        -i.orig gcc/config/mips/t-linux64
 ;;
esac
###
../configure                                       \
    --target=$LFS_TGT                              \
    --prefix=/tools                                \
    --with-glibc-version=2.11                      \
    --with-sysroot=$LFS                            \
    --with-newlib                                  \
    --without-headers                              \
    --with-local-prefix=/tools                     \
    --with-native-system-header-dir=/tools/include \
    --disable-nls                                  \
    --disable-shared                               \
    --disable-multilib                             \
    --disable-decimal-float                        \
    --disable-threads                              \
    --disable-libatomic                            \
    --disable-libgomp                              \
    --disable-libmpx                               \
    --disable-libquadmath                          \
    --disable-libssp                               \
    --disable-libvtv                               \
    --disable-libstdcxx                            \
    --enable-languages=c,c++ \
    --with-abi=64   \
    --with-endlan=little

###glibc
../configure                             \
      --prefix=/tools                    \
      --host=$LFS_TGT                    \
      --build=$(../scripts/config.guess) \
      --enable-kernel=3.2             \
      --with-headers=/tools/include      \
      libc_cv_forced_unwind=yes          \
      libc_cv_c_cleanup=yes \
    --with-abi=64   \
    --with-endlan=little

###2-binytils
CC=$LFS_TGT-gcc                \
AR=$LFS_TGT-ar                 \
RANLIB=$LFS_TGT-ranlib         \
../configure                   \
    --prefix=/tools            \
    --disable-nls              \
    --disable-werror           \
    --with-lib-path=/tools/lib \
    --with-sysroot \
    --with-abi=64   \
    --with-endlan=little
###
for file in gcc/config/{linux,mips/linux{,64}}.h
do
  cp -uv $file{,.orig}
  sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
      -e 's@/usr@/tools@g' $file.orig > $file
  echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
  touch $file.orig
done
###
case $(uname -m) in
  mips64)
    sed -e 's/lib64/lib/g' \
        -i.orig gcc/config/mips/t-linux64
 ;;
esac
###
CC=$LFS_TGT-gcc                                    \
CXX=$LFS_TGT-g++                                   \
AR=$LFS_TGT-ar                                     \
RANLIB=$LFS_TGT-ranlib                             \
../configure                                       \
    --prefix=/tools                                \
    --with-local-prefix=/tools                     \
    --with-native-system-header-dir=/tools/include \
    --enable-languages=c,c++                       \
    --disable-libstdcxx-pch                        \
    --disable-multilib                             \
    --disable-bootstrap                            \
    --disable-libgomp \
    --with-abi=64   \
    --with-endlan=little

###tcl
./configure --prefix=/tools \
    --with-abi=64   \
    --with-endlan=little

###expect
./configure --prefix=/tools       \
            --with-tcl=/tools/lib \
            --with-tclinclude=/tools/include \
    --with-abi=64   \
    --with-endlan=little


###dejagnu
./configure --prefix=/tools \
    --with-abi=64   \
    --with-endlan=little

###ncurses
./configure --prefix=/tools \
            --with-shared   \
            --without-debug \
            --without-ada   \
            --enable-widec  \
            --enable-overwrite \
    --with-abi=64   \
    --with-endlan=little
###gawk
./configure --prefix=/tools \
    --with-abi=64   \
    --with-endlan=little
###gettext
EMACS="no" ./configure --prefix=/tools --disable-shared \
    --with-abi=64   \
    --with-endlan=little
###texinfo
./configure --prefix=/tools \
    --with-abi=64   \
    --with-endlan=little

=====================================================================
=====================================================================
###chroot

###
case $(uname -m) in
 mips64) mkdir -v /lib64 ;;
esac
###
测试链接的文件都有哪些：
for lib in blkid lzma mount uuid
do
    ls -al /tools/lib/lib$lib.so*
done
###实际操作
for lib in blkid lzma mount uuid
do
    ln -sv /tools/lib/lib$lib.so* /usr/lib
done

###linux-4.15.3
ln -sv /tools/bin/gawk /usr/bin/awk

###glibc
case $(uname -m) in
    mips64) GCC_INCDIR=/usr/lib/gcc/$(gcc -dumpmachine)/7.3.0/include
            ln -sfv /lib/ld.so.1 /lib64
    ;;
esac
###
CC="gcc -isystem $GCC_INCDIR -isystem /usr/include" \
../configure --prefix=/usr                          \
             --disable-werror                       \
             --enable-kernel=3.2                    \
             --enable-stack-protector=strong        \
             libc_cv_slibdir=/lib \
    --with-abi=64   \
    --with-endlan=little

unset GCC_INCDIR
###adjusting
mv -v /tools/bin/{ld,ld-old}
mv -v /tools/$(gcc -dumpmachine)/bin/{ld,ld-old}
mv -v /tools/bin/{ld-new,ld}
ln -sv /tools/bin/ld /tools/$(gcc -dumpmachine)/bin/ld
###binutils
../configure --prefix=/usr       \
             --enable-gold       \
             --enable-ld=default \
             --enable-plugins    \
             --enable-shared     \
             --disable-werror    \
             --enable-64-bit-bfd \
             --with-system-zlib \
    --with-abi=64   \
    --with-endlan=little
###gmp
ABI=64 ./configure --prefix=/usr    \
            --enable-cxx     \
            --disable-static \
            --docdir=/usr/share/doc/gmp-6.1.2
###gcc
case $(uname -m) in
  mips64)
    sed -e 's/lib64/lib/g' \
        -i.orig gcc/config/mips/t-linux64
  ;;
esac
###
SED=sed                               \
../configure --prefix=/usr            \
             --enable-languages=c,c++ \
             --disable-multilib       \
             --disable-bootstrap      \
             --with-system-zlib \
    --with-abi=64   \
    --with-endlan=little
###链接/usr/lib/ctr*三个.o文件链接到/lib/下，因在临时编译链和目的编译链gcc配置里的t-linux64文件lib64替换为lib原因
ln -sv /usr/lib/xxx.o /lib/


###pkg-config
./configure --prefix=/usr              \
            --with-internal-glib       \
            --disable-host-tool        \
            --docdir=/usr/share/doc/pkg-config-0.29.2 \
    --with-abi=64   \
    --with-endlan=little
###ncurses
./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-debug         \
            --without-normal        \
            --enable-pc-files       \
            --enable-widec \
    --with-abi=64   \
    --with-endlan=little
###gperf
./configure --prefix=/usr --disable-static \
    --with-abi=64   \
    --with-endlan=little
###inetutils
ln -sv /usr/bin/{hostname,ping,ping6,traceroute} /bin
ln -sv /usr/bin/ifconfig /sbin
###xz
ln -sv   /usr/bin/{lzma,unlzma,lzcat,xz,unxz,xzcat} /bin
ln -sv /usr/lib/liblzma.so.* /lib
###修改以下一行：
```
ln -svf ../../lib/$(readlink /usr/lib/liblzma.so) /usr/lib/liblzma.so
###因为看/usr/lib/下ls -al liblzma*可以看到liblzma.so是个软链接指向$(readlink /usr/lib/liblzma.so)，所以为了一致，修改如下：
cp - /usr/lib/liblzma.so /lib/ 
```
###kmod
```
for target in depmod insmod lsmod modinfo modprobe rmmod; do
  ln -sfv /bin/kmod /sbin/$target
done
###kmod在编译目录的tools/下
ln -sfv tools/kmod /bin/lsmod
```
###gettext
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-0.19.8.1 \
    --with-abi=64   \
    --with-endlan=little
###openssl
./Configure linux64-mips64 --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic 
###























