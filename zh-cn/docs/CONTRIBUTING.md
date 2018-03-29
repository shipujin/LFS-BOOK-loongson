## Participate in the contribution
Contributor [list](https://github.com/yeasy/blockchain_guide/graphs/contributors).

Building a system from source code is a cool thing to do, and you're welcome to try to compile Linux using the loongson host MIPS architecture.

Source open source hosted on Github, welcome to participate in maintenance:[https://github.com/lina-not-linus/LFS-BOOK-loongson](https://github.com/lina-not-linus/LFS-BOOK-loongson).

First, in making `fork` to your warehouse, such as `everyone/LFS-BOOK-loongson`，then `clone` To local, and set user information.

```sh
$ git clone https://github.com/lina-not-linus/LFS-BOOK-loongson.git
$ cd LFS-BOOK-loongson
$ git config user.name "yourname"
$ git config user.email "youremail"
```

Update the content and submit it to your warehouse.

```sh
$ git commit -m "add compil content"
$ git push originLFS master
```

Finally, you can submit a pull request on GitHub.

In addition, it is recommended to periodically update the contents of your warehouse with project warehouse contents.
```sh
$ git remote add originLFS https://github.com/lina-not-linus/LFS-BOOK-loongson
$ git push originLFS master
```

