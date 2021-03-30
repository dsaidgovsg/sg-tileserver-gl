# `sg-tileserver-gl`

Builds Docker image with TileServer GL for Singapore tiles only.

The repository is split into two main sections:

- [MBTiles creation](#MBTiles-creation) (to be manually run)
- [Docker set-up](#Docker-set-up) (run by CI)

All the submodules are required to be checked out. Run the following command to do so:

```bash
git submodule update --init --recursive
```

The submodules will appear in the `vendor` directory.

## MBTiles creation

**WARNING: This section takes very long to run.**

Also this section is not required to be run unless you are intending to update the details of the
maps (e.g. updated landmarks / buildings due to Singapore rapid progress, and not about the
styling!).

This section is to be manually run. A fully maxed out max zoom of 18 takes about 4.5 hours on AMD
Ryzen 7 5800H to generate.

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

You may set the `MAX_ZOOM` value to be very low for testing purposes.

### Uploading of MBTiles

The generate `.mbtiles` file is to be manually uploaded as GitHub Release assets, under the
`mbtiles` release tag.

To upload the `.mbtiles` file, simply go to:
<https://github.com/dsaidgovsg/sg-tileserver-gl/releases/edit/mbtiles>.

Once the file is uploaded, please DO NOT remove the asset to prevent any possible Docker image build
breakage in the following section, unless the uploaded asset is erroneous.

This repository set-up does not provide any script to automatically upload the generated MBTiles,
because it is simple enough to do it manually, and the script would require many assumptions such as
user already has the credentials + has the rights to perform an upload of release asset.

## Docker set-up

This step includes performing the following:

- Fonts generation
- Sprites generation
- Styles generation
- Downloading of uploaded MBTiles

This step has been greatly automated, and all that is required is to do either of the following.

### Native build

You will need to have `npm` installed, preferably the stable versions 12 or 14.

Simply run:

```bash
npm ci
```

to install all the required dependencies for the set-up.

Next run:

```bash
# Check out <https://github.com/dsaidgovsg/sg-tileserver-gl/releases/tag/mbtiles> for the possible tags
MBTILES_TAG=0-18_20210325T212157Z ./setup.sh
```

This will get all the files placed into `data/` (git ignored), ready for the final Docker build step
to copy in this directory, which is all it needed to locally host the tileserver.

Proceed to the [final step](#Final-Docker-build-step) to finish up the Docker image.

### Docker alternative build

This alternative method is good if you do not like to install `npm`, or have alternative versions
of `npm` on your machine if you already have some `npm` version installed.

You will need to have the latest `docker` CLI installed.

First run:

```bash
docker build . -f Dockerfile-builder -t sg-tileserver-gl-builder
```

to get your builder image.

Then run the following to run the above image to run the build:

```bash
docker run --rm -it \
    -v "${PWD}:/app" \
    -u "$(id -u):$(id -g)" \
    -e "MBTILES_TAG=0-18_20210325T212157Z" \
    sg-tileserver-gl-builder:latest \
    ./setup.sh
```

The generated files here in `data/` should have no problem co-existing with those generated from the
native build, because the command here is run using your current host user/group.

Proceed to [next step](#Final-Docker-build-step) to finish up the Docker image.

### Final Docker build step

With the files in `data/`, run:

```bash
TILESERVER_GL_VERSION=v3.1.1
docker build . \
    --build-arg TILESERVER_GL_VERSION="${TILESERVER_GL_VERSION}" \
    -t "sg-tileserver-gl:${TILESERVER_GL_VERSION}"
```

To run the image, run:

```bash
TILESERVER_GL_VERSION=v3.1.1
docker run --rm -it -p 8080:80 "sg-tileserver-gl:${TILESERVER_GL_VERSION}"
```

### Build details (for reading)

*Feel free to skip this section if you are not interested in the details.*

As mentioned, the overall step is broken down into 4 parts:

#### Fonts generation

Corresponds to `setup-scripts/generate-fonts.sh`.

This requires the submodule `openmaptiles-fonts`, which we are using a fork variant of it:
<https://github.com/dsaidgovsg/fonts>, because the newer map styles requires Nunito fonts, not
provided by the original repository.

This step runs through the NodeJS generation script from the said repository, to generate the fonts,
into `pbf` format.

The built fonts can be found in `data/fonts`.

#### Sprites generation

Corresponds to `setup-scripts/generate-sprites.sh`.

This sets up this repo's `package.json` to be equipped with
<https://github.com/mapbox/spritezero-cli> to perform the sprites generation.

It simply runs through all the SVGs icons and be repackaged as sprites JSONs and PNGs.

The built sprites can be found in `data/sprites`.

The original guide can be found here:
<https://openmaptiles.org/docs/style/mapbox-gl-style-spec/>

#### Styles generation

Corresponds to `setup-scripts/generate-styles.sh`.

The styles files are already present in all the styles submodules. This step actually reformats the
JSON and remove the boundary line layer (and also some layers that require external HTTP access).

The layers to target to remove are done manually before setting it into the script. This can be done
via custom loading the styles JSON here in <https://maputnik.github.io/editor>, and clicking on
layers to identify the `id` to remove.

The final generated styles JSON can be found in `data/styles`.

#### Downloading of uploaded MBTiles

Corresponds to `setup-scripts/download-mbtiles.sh`.

This step simply downloads the uploaded release asset MBTiles, and apply the `TAG` interpolation
into [`template/config.json`](template/config.json). It is preferable to mark and name the MBTiles
to easily identify the original input paramters used to build the MBTiles.

The uploading steps is already described in the [earlier section](#MBTiles-creation).

## How to Apply Template for CI build

For Linux user, you can download Tera CLI v0.4 at <https://github.com/guangie88/tera-cli/releases>
and place it in `PATH`.

Otherwise, you will need `cargo`, which can be installed via [rustup](https://rustup.rs/).

Once `cargo` is installed, simply run `cargo install tera-cli --version=^0.4.0`.

After which, run `.github-templates/apply-vars.sh` to generate `.github/workflows/ci.yml`.

## Acknowledgement

### Previous repositories set-up

- <https://github.com/GovTechSG/iOneMySgMap>
- <https://github.com/GovTechSG/openmaptiles-styles>

## Extra content set-up

- <https://github.com/GovTechSG/several-shades-of-gray-gl-style>
- <https://fonts.google.com/specimen/Nunito>
- <https://fonts.google.com/specimen/Nunito+Sans>
