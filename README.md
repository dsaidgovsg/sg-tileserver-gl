# `sg-tileserver-gl`

Builds Docker image with TileServer GL for Singapore tiles only.

The repository is split into two main sections:

- [MBTiles creation](#MBTiles-creation) (to be manually run)
- [Map styles generation](#Map-styles-generation) (run by CI)

All the submodules are required to be checked out. Run the following command to do so:

```bash
git submodule update --init --recursive
```

The submodules will appear in the `vendor` directory.

## MBTiles creation

**WARNING: This section takes very long to run.**

This section is to be manually run. A reasonable max zoom of 14 takes about 30 hours on AMD Ryzen 7
5800H to generate.

You are expected to have `docker` and `docker-compose` installed. Simply download the latest version
for both CLIs.

### Creation MBTiles script

Simply run

```bash
./create-mbtiles.sh  # Be prepared to run your machine overnight
```

If you wish to amend the min/max zoom details of the map, you can do the following:

```bash
MIN_ZOOM=2 MAX_ZOOM=12 ./create-mbtiles.sh
```

### Uploading of MBTiles

The generate `.mbtiles` file is to be manually uploaded as GitHub Release assets, under the
`mbtiles` release tag.

To upload the `.mbtiles` file, simply go to:
<https://github.com/dsaidgovsg/sg-tileserver-gl/releases/edit/mbtiles>.

Once the file is uploaded, please DO NOT remove the asset to prevent any possible Docker image build
breakage in the following section, unless the uploaded asset is erroneous.

## Map styles generation

TODO

We also need to generate the font assets used by the map styles.

### Docker builder command

```bash
docker build . -f Dockerfile-builder -t sg-tileserver-gl-builder
docker run --rm -it -v "${PWD}:/app" -u "$(id -u):$(id -g)" sg-tileserver-gl-builder:latest bash
```

### Native command

```bash
./setup.sh
```

### How was the styles modified

<https://maputnik.github.io/editor/>

This repository prefers the map styles that do not show boundaries.

TODO
