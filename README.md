# release

Tools for managing pbdR releases.

* Source releases can be found [here](https://pbdr.org/releases/).
* Docker builds of pbdR releases can be found [here](https://hub.docker.com/u/rbigdata/).


## Creating a release

This should only interest you if you are part of the pbdR core team.

Setup:
* This probably only works from a Linux OS.
* Install the pbdRelease package.

To create a release:
* Update release files:
    - Add a concise list of changes to `assets/CHANGELOG`.
    - Update `assets/AUTHORS` and `assets/README.in` as necessary.
*  Set the version number in `make_release.r`.
* Make sure `clobber` is set appropriately in `make_src_dist()`. Run `make_release.r`.

TODO: docker, etc.
