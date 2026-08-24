# Building Emacs from git with mise

Personal build tooling for a Savannah Emacs checkout. Two files travel
together: `mise.toml` and this readme. Nothing here is part of GNU Emacs;
do not include either file in a patch sent upstream.

## Quick start

Three commands on a fresh machine, assuming [mise](https://mise.jdx.dev)
is installed and you are in a clone of
`https://git.savannah.gnu.org/git/emacs.git` with `mise.toml` copied in:

    mise trust
    mise run world                    # desktop build
    EMACS_PROFILE=nox mise run world  # ...or headless server build

`world` installs the Debian packages (via sudo), pulls, configures,
verifies the configuration, bootstraps, installs to `~/.local`, and prints
what it built. The bootstrap is the slow part; native compilation of the
Lisp tree dominates it.

Make sure `~/.local/bin` is on your `PATH` afterwards.

On subsequent days, `mise run refresh` is usually all you want: it pulls
and re-bootstraps using the configuration already recorded in
`config.status`.

## Profiles

`EMACS_PROFILE` picks the build. It defaults to `gtk`.

- `gtk` -- GTK3 on X11, with images, D-Bus, sound and HarfBuzz.

- `nox` -- `--without-x`, for a server with no GUI. Drops all image
  libraries, sound and the X development headers. Keeps native
  compilation, tree-sitter, SQLite, ACLs, GnuTLS, libxml2 and modules.

Export it for the session if you are working on a server:

    export EMACS_PROFILE=nox

The choice is deliberate rather than auto-detected. Guessing "no GTK
headers, therefore headless" would silently produce a nox build on a
desktop machine that simply had not installed its dependencies yet.

## Tasks

    mise tasks            # list them all

| Task | Does |
| --- | --- |
| `world` | deps, pull, reconfigure, bootstrap, install, version |
| `refresh` | pull, then bootstrap with the existing configuration |
| `reconfigure` | pull, autogen, configure, verify, bootstrap |
| `deps` | apt install the packages this profile needs |
| `deps-check` | report missing packages, exit non-zero if any |
| `deps-list` | print the resolved package list |
| `pull` | `git pull --ff-only origin master` |
| `autogen` | `./autogen.sh` |
| `configure` | `./configure` with this profile's options |
| `verify` | confirm the features actually reached `src/config.h` |
| `bootstrap` | `make bootstrap -j$(nproc)` |
| `build` | incremental `make -j$(nproc)` |
| `install` | `make install` into `$EMACS_PREFIX` |
| `check` | `make check` |
| `clean`, `distclean` | as the names suggest |
| `version` | what the built binary reports |

`EMACS_PREFIX` defaults to `~/.local`; override it in the environment.

## Notes

### Run verify, not just configure

Most optional features fail open. `configure.ac` hard-errors on only
xpm, jpeg, png, gif and tiff (those five only when X is enabled), plus
dbus, gnutls and tree-sitter. Everything else -- rsvg, webp, sqlite3,
ACLs, SELinux -- silently sets itself to "off" when a development package
is absent, and the build succeeds.

That is how `--with-rsvg` can sit in a configure line for months while
producing an Emacs with no SVG support. `mise run verify` greps
`src/config.h` for each feature the profile expects and exits non-zero on
any gap. `reconfigure` runs it between configure and bootstrap so a miss
costs seconds instead of a full rebuild.

### SELinux needs an explicit flag

Gnulib defaults `with_selinux` to `maybe`, not `yes`
(`m4/selinux-selinux-h.m4`), while Emacs tests for exactly `yes`
(`configure.ac`, the `HAVE_LIBSELINUX` block). So SELinux support is off
unless `--with-selinux` is passed, even with `libselinux-dev` installed.
Both profiles pass it. Drop it if you do not use SELinux -- Debian ships
AppArmor by default and the support is inert without it.

### libgccjit must match gcc

Native compilation breaks if they disagree, and the right package name
differs per release: Debian 13 stable ships gcc 14, testing ships gcc 15.
The `deps` task derives it rather than hardcoding:

    libgccjit-$(gcc -dumpversion | cut -d. -f1)-dev

### tree-sitter

`libtree-sitter-dev` is in the base package list so this works on any
machine. If you also have a self-built tree-sitter under `/usr/local`, the
`PKG_CONFIG_PATH` set in `mise.toml` is searched first, so that copy wins.

### Options deliberately left out

`--with-json` and `--with-libxml` are not real options and configure warns
about them; JSON is built in since Emacs 30 and the XML flag is spelled
`--with-xml2`. `--with-xft` does nothing once Cairo is in use.

Not enabled, available if wanted: `libtiff-dev` for TIFF, `libgpm-dev` for
a console mouse (worth it on a server), `libwebkit2gtk-4.1-dev` for
`--with-xwidgets`, `libmagickwand-dev` for `--with-imagemagick`. The last
two are off upstream by default for good reasons.

### Keeping git quiet

    echo /mise.toml >> .git/info/exclude
    echo /HUGH_README.md >> .git/info/exclude
