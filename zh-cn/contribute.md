## 参与贡献
贡献者 [名单](https://github.com/yeasy/blockchain_guide/graphs/contributors)。

从源码编译构建一个系统来说是一个非常酷的事情，欢迎大家来尝试在loongson主机MIPS架构上去编译使用Linux。

本书源码开源托管在 Github 上，欢迎参与维护：[https://github.com/lina-not-linus/LFS-BOOK-loongson](https://github.com/lina-not-linus/LFS-BOOK-loongson)。

首先，在 GitHub 上 `fork` 到自己的仓库，如 `everyone/LFS-BOOK-loongson`，然后 `clone` 到本地，并设置用户信息。

```sh
$ git clone https://github.com/lina-not-linus/LFS-BOOK-loongson.git
$ cd LFS-BOOK-loongson
$ git config user.name "yourname"
$ git config user.email "youremail"
```

更新内容后提交，并推送到自己的仓库。

```sh
$ git commit -m "add compil content"
$ git push originLFS master
```

最后，在 GitHub 网站上提交 pull request 即可。

另外，建议定期使用项目仓库内容更新自己仓库内容。
```sh
$ git remote add originLFS https://github.com/lina-not-linus/LFS-BOOK-loongson
$ git push originLFS master
```

