# `sg-tileserver-gl`

Repackaged repository to build Docker image for Singapore tiles only.

## Docker builder command

```bash
docker build . -f Dockerfile-builder -t sg-tileserver-gl-builder
```

## Steps

### Step 1

You will need to check out all the submodules. If you haven't so, run this command to check out all
submodules:

```bash
git submodule update --init --recursive
```

The submodules will appear in the `vendor` directory.

### Step 2

<https://maputnik.github.io/editor/>

This repository prefers the map styles that do not show boundaries.

TODO

### Step 3

We need to generate the font assets used by the map styles.

TODO

Finally either move or copy over the generated fonts assets:

```bash
# Move
mv vendor/openmaptiles-fonts/_output/* app/fonts/

# OR copy over
cp -r vendor/openmaptiles-fonts/_output/* app/fonts/
```
